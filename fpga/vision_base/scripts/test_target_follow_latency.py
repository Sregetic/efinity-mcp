"""CPU-measured position delay -> production scaler/control -> VBlank ROI publication."""
from pathlib import Path
import json,re,subprocess
ROOT=Path(__file__).resolve().parents[1];TASK=ROOT/'results/m7_follow_20261031';OUT=TASK/'latency';OUT.mkdir(exist_ok=True)
def w(p):return '/mnt/'+p.as_posix()[0].lower()+p.as_posix()[2:]
source=(ROOT/'sim/tb_roi_axi_scaler.sv').read_text()
controller=r'''
    reg cap_req_valid=0,cap_done_valid=0;reg[1:0]cap_done_bank=0;
    wire cap_req_ready;wire[1:0]cap_req_bank;
    wire run_valid,run_ready;wire[31:0]run_frame_id,run_config_id;
    wire presented;wire[31:0]presented_frame,presented_config;
    wire front_pending,front_done,front_error;reg writer_done=0;reg[4:0]write_delay=0;
    integer capture_number=0,cpu_delay=0,observation_cycle=0,request_cycle=0;
    reg[31:0]vs_counter=0,previous_config=0;reg vbq=0;
    wire vblank=vs_counter==3333332;
    always @(posedge clk)begin
      if(!rst_n)begin vs_counter<=0;write_delay<=0;writer_done<=0;previous_config<=0;vbq<=0;end
      else begin
       vs_counter<=vblank?0:vs_counter+1'b1;writer_done<=0;
       if(done)write_delay<=16;
       else if(write_delay!=0)begin write_delay<=write_delay-1'b1;if(write_delay==1)writer_done<=1;end
       previous_config<=presented_config;vbq<=vblank;
      end
    end
    always @(posedge clk)begin #1;if(rst_n&&presented_config!=previous_config&&!vbq)$fatal(1,"ROI publication outside VBlank");end
    frame_render_control #(.FRAME_BUDGET_CYCLES(3333333)) publication(
      .clk(clk),.rst_n(rst_n),.cap_req_valid(cap_req_valid),.cap_req_ready(cap_req_ready),.cap_req_config_id(32'd1),.cap_req_bank(cap_req_bank),
      .cap_done_valid(cap_done_valid),.cap_done_ready(),.cap_done_bank(cap_done_bank),.cap_done_ok(1'b1),
      .compute_acquire_valid(1'b0),.compute_latest(1'b0),.compute_release(1'b0),.compute_request_frame_id(32'd0),
      .compute_acquire_ready(),.compute_missing(),.compute_hold_valid(),.compute_hold_bank(),.compute_hold_frame_id(),.compute_hold_config_id(),
      .analysis_acquire_valid(1'b0),.analysis_acquire_ready(),.analysis_release(1'b0),.analysis_hold_valid(),.analysis_hold_bank(),.analysis_hold_frame_id(),.analysis_hold_config_id(),
      .pin_history(1'b0),.display_use_analysis(1'b0),.display_age(3'd0),.analysis_age(3'd0),.history_count(),.capture_frame_id(),
      .job_valid(job_valid),.job_ready(job_ready),.job_config_ok(1'b1),.freeze_source(1'b0),.release_source(1'b0),.job_config_id(config_id),
      .run_valid(run_valid),.run_ready(run_ready),.run_source_bank(),.run_frame_id(run_frame_id),.run_config_id(run_config_id),.run_result_bank(),
      .scaler_done(done),.scaler_error(error),.writer_done(writer_done),.writer_error(1'b0),.vblank(vblank),
      .display_valid(presented),.display_bank(),.display_frame_id(presented_frame),.display_config_id(presented_config),
      .done(front_done),.error(front_error),.busy(),.pending(front_pending),.last_cycles(),.deadline_misses(),.source_hold_valid(),.source_hold_bank(),.source_hold_frame_id(),.source_hold_config_id());
    task capture_source;begin
      @(negedge clk);cap_req_valid=1;while(!cap_req_ready)@(negedge clk);cap_done_bank=cap_req_bank;
      @(negedge clk);cap_req_valid=0;cap_done_valid=1;@(negedge clk);cap_done_valid=0;capture_number=capture_number+1;
    end endtask
'''
marker='    roi_axi_scaler #';assert source.count(marker)==1;source=source.replace(marker,controller+'\n'+marker)
source=source.replace('.job_valid(job_valid), .job_ready(job_ready)', '.job_valid(run_valid), .job_ready(run_ready)',1)
source=source.replace('.frame_id(frame_id),','.frame_id(run_frame_id),',1).replace('.config_id(config_id),','.config_id(run_config_id),',1)
needle='            $readmemh(vector_file,center_vectors);';assert source.count(needle)==1
source=source.replace(needle,needle+'\n            if(!$value$plusargs("delay_cycles=%d",cpu_delay))$fatal(1,"CPU delay required");')
needle='                @(negedge clk);job_valid=1;while(!job_ready)@(negedge clk);';assert source.count(needle)==1
source=source.replace(needle,'                while(capture_number<expected_frame)capture_source();\n                observation_cycle=cycle;repeat(cpu_delay)@(negedge clk);request_cycle=cycle;\n'+needle)
needle='                $fclose(output_file);$display("PASS center RTL sample=%0d pixels=%0d",sample,received);';assert source.count(needle)==1
source=source.replace(needle,needle+'\n                wait(presented_config==config_id);@(negedge clk);\n                if(!presented||front_error||presented_frame!=expected_frame)$fatal(1,"wrong ROI source/config");\n                $display("LATENCY %0d %0d %0d %0d %0d",sample,cycle-observation_cycle,cycle-request_cycle,presented_frame,presented_config);')
source=source.replace('CENTER_REPLAY?1000000000:3000000',"CENTER_REPLAY?64'd5000000000:3000000")
tb=OUT/'tb_latency.sv';tb.write_text(source)
obj=OUT/'obj';inputs=[tb,*[ROOT/'rtl'/n for n in ['axi_line_reader.sv','roi_scaler.sv','roi_axi_scaler.sv','frame_render_control.sv','frame_pool.sv']]]
cmd=['wsl.exe','-d','Ubuntu-24.04','--exec','/usr/bin/verilator','--binary','--timing','-j','4','-Wno-fatal','--top-module','tb_roi_axi_scaler','-GCENTER_REPLAY=1','--Mdir',w(obj),*[w(p)for p in inputs]]
x=subprocess.run(cmd,capture_output=True,timeout=180);(OUT/'compile.log').write_bytes(x.stdout+x.stderr);x.check_returncode()
bench=json.loads((TASK/'cpu_bench/result.json').read_text());delay=bench['raw'][17]
x=subprocess.run(['wsl.exe','-d','Ubuntu-24.04','--exec',w(obj/'Vtb_roi_axi_scaler'),'+vectors='+w(TASK/'follow_render/control/center_vectors.mem'),'+output='+w(OUT),f'+delay_cycles={delay}'],capture_output=True,timeout=180)
(OUT/'run.log').write_bytes(x.stdout+x.stderr);x.check_returncode();assert b'PASS tb_roi_axi_scaler'in x.stdout
rows=[dict(sample=int(a),observation_to_roi_ms=int(b)/1e5,request_to_roi_ms=int(c)/1e5,frame=int(d),config=int(e))for a,b,c,d,e in re.findall(rb'LATENCY (\d+) (\d+) (\d+) (\d+) (\d+)',x.stdout)]
assert len(rows)==6
result=dict(passed=True,cycles_per_second=100000000,cpu_position_delay_ms=delay/1e5,cases=rows,scope='Timed RTL replay with actual CPU worst position delay, native scaler AXI/backpressure, final write response +16 cycles, and 30Hz VBlank controller. No live camera/DDR contention/monitor timing.')
(OUT/'result.json').write_text(json.dumps(result,indent=2));print(json.dumps(result,indent=2))
