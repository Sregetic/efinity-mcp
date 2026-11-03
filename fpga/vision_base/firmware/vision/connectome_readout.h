#pragma once
#include "shape_model.h"
#include "connectome_data.h"
/* CRD1: fixed 80->4 readout; the circuit and its frame-reset rule stay fixed. */
struct connectome_readout_model {
 uint32_t magic,version,graph_version,training_kind;
 int32_t output_zero,multiplier,shift,bias[4];
 int8_t weights[320];
};
static unsigned connectome_readout_valid(const struct connectome_readout_model *m){
 return m->magic==0x43524431u&&m->version&&m->graph_version==CONNECTOME_VERSION&&
        (m->training_kind==1||m->training_kind==2)&&m->output_zero>=-128&&m->output_zero<=127&&
        m->multiplier>0&&m->shift>=-30&&m->shift<=-2;
}
static void connectome_readout(const struct connectome_readout_model *m,const int16_t states[80],int8_t scores[4]){
 int8_t x[80];
 for(unsigned i=0;i<80;i++){int q=((int)states[i]+64)>>7;x[i]=q<-128?-128:q>127?127:q;}
 shape_dense(x,80,m->weights,m->bias,4,0,m->output_zero,m->multiplier,m->shift,0,scores);
}
