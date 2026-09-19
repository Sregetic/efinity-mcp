"""Generate a separate Ti60F225 I3 Sobel timing harness; never programs hardware."""
import os,sys,json
from pathlib import Path
sys.path.append(os.environ['EFXPT_HOME']+'/bin')
from api_service.design import DesignAPI
root=Path(__file__).resolve().parents[1]
out=root/'efinity'/'sobel_220'
out.mkdir(exist_ok=True)
d=DesignAPI(False)
d.create('sobel_220','Ti60F225',str(out))
d.set_iobank_voltage('1A','1.8')
d.set_iobank_voltage('BR','3.3')
d.create_input_clock_gpio('CLK_25M')
d.assign_resource('CLK_25M','GPIOL_P_08')
d.set_property('CLK_25M','IO_STANDARD','1.8_V_LVCMOS')
d.create_output_gpio('result')
d.assign_resource('result','GPIOR_21')
d.set_property('result','IO_STANDARD','3.3_V_LVCMOS')
d.create_block('sobel_pll',block_type='PLL')
d.gen_pll_ref_clock('sobel_pll',pll_res='PLL_TL0',refclk_src='CORE')
d.set_property('sobel_pll',{'CORE_CLK_PIN':'CLK_25M','REFCLK_FREQ':'25','CLKOUT0_PIN':'clk','RSTN_PIN':'pll_rstn','LOCKED_PIN':''},block_type='PLL')
# Keep a separate 100 MHz feedback output; CLK0 is the 220 MHz test clock.
d.set_property('sobel_pll',{'CLKOUT1_EN':'1','CLKOUT1_PIN':'fb','FEEDBACK_MODE':'CORE','FEEDBACK_CLK':'CLK1'},block_type='PLL')
d.set_property('sobel_pll',{'M':'4','N':'1','O':'2','CLKOUT0_DIV':'5','CLKOUT1_DIV':'11'},block_type='PLL')
d.calc_pll_clock('sobel_pll')
frequencies=d.get_property('sobel_pll',['CLKOUT0_FREQ','CLKOUT1_FREQ','VCO_FREQ','PLL_FREQ'],block_type='PLL')
print(frequencies)
assert abs(float(frequencies['CLKOUT0_FREQ'])-220)<0.001, frequencies
(out/'pll_220.json').write_text(json.dumps(frequencies,indent=2))
d.save()
d.generate(enable_bitstream=False)
print('PERIPHERY_220_GENERATED')



