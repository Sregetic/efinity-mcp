"""Export auditable body-ID edge tables and DDR-resident fixed-point constants."""
import csv,json,sys
from pathlib import Path
ROOT=Path(__file__).resolve().parents[1];sys.path.insert(0,str(ROOT/'models'))
from connectome import GRAPH,EDGES,WEIGHTS,PRE,W,ROW,INPUT,LUT,DATA

def main():
 with (DATA/'edges.csv').open('w',newline='') as f:
  writer=csv.writer(f);writer.writerow(['pre_body_id','post_body_id','contacts','assumed_sign','normalized_weight','q14_weight'])
  for (a,b,c),(_,_,weight),q in zip(GRAPH['edges'],EDGES,WEIGHTS):writer.writerow([GRAPH['nodes'][a]['id'],GRAPH['nodes'][b]['id'],c,GRAPH['nodes'][a]['sign'],weight,q])
 with (DATA/'nodes.csv').open('w',newline='') as f:
  writer=csv.writer(f);writer.writerow(['index','body_id','type','nt','sign','role','x','y','z','input_channel'])
  for i,n in enumerate(GRAPH['nodes']):writer.writerow([i,n['id'],n['type'],n['nt'],n['sign'],n['role'],*n['position'],int(INPUT[i])])
 header='// Derived from MaleCNS v1.0/Fly Dino published subset; CC BY4.0, see models/connectome_malecns/NOTICE.md.\n#pragma once\n#include <stdint.h>\n#define CONNECTOME_VERSION 0x00010001u\n'
 for name,kind,values in [('row','uint16_t',ROW),('pre','uint8_t',PRE),('weight','int16_t',W),('input','int8_t',INPUT),('tanh','int16_t',LUT),('outputs','uint8_t',GRAPH['outputs'])]:
  header+=f'static const {kind} connectome_{name}[{len(values)}]={{'+','.join(map(str,map(int,values)))+'};\n'
 (ROOT/'firmware/vision/connectome_data.h').write_text(header)
 record=dict(nodes=80,aggregate_directed_edges=1296,synaptic_contacts=26029,inputs=32,readout_nodes=16,
  table_bytes=2*81+1296+2*1296+80+2*257+16,state_format='signed Q14',iterations=3,
  state_policy='reset for every independent ROI; no cross-object state retention',
  encoding='eight spatial bins from existing64 edge-density features; engineered, not biological receptive fields',
  graph_version=GRAPH['version'],trained_readout=False,new_fpga_modules=False)
 (DATA/'implementation.json').write_text(json.dumps(record,indent=2));print(json.dumps(record,indent=2))
if __name__=='__main__':main()
