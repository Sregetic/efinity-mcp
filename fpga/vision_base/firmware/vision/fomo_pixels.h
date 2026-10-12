#pragma once
#include "fomo_camera.h"
/* Match vision_packed_rgb.sv, including the dark-range flag, not RGB565. */
static void fomo_rgb(uint16_t p,uint8_t rgb[3]){
 unsigned v[3]={(p>>10)&31,(p>>5)&31,p&31};
 for(unsigned c=0;c<3;c++)rgb[c]=(p&0x8000)?(v[c]<<3)|(v[c]>>2):v[c]<<1;
}
static void fomo_gray_roi(const volatile uint16_t *source,uint32_t xy,uint32_t wh,volatile uint8_t *gray){
 unsigned x=xy&65535,y=xy>>16,w=wh&65535,h=wh>>16;
 for(unsigned row=0;row<32;row++)for(unsigned col=0;col<32;col++){
  uint8_t rgb[3];fomo_rgb(source[(y+row*h/32)*1920+x+col*w/32],rgb);
  gray[row*32+col]=(77u*rgb[0]+150u*rgb[1]+29u*rgb[2])>>8;
 }
}
static void fomo_rgb_roi(const volatile uint16_t *source,uint32_t xy,uint32_t wh,volatile uint16_t *packed,int8_t *input){
 unsigned x=xy&65535,y=xy>>16,w=wh&65535,h=wh>>16;
 unsigned advance=w/96,fraction=w%96;
 for(unsigned row=0;row<96;row++){
  unsigned address=(y+row*h/96)*1920+x,step=0,remainder=0;
  for(unsigned col=0;col<96;col++){
   uint8_t rgb[3];unsigned i=row*96+col;
   uint16_t pixel=source[address+step];packed[i]=pixel;fomo_rgb(pixel,rgb);
   for(unsigned c=0;c<3;c++)input[i*3+c]=(int)rgb[c]-128;
   step+=advance;remainder+=fraction;
   if(remainder>=96){remainder-=96;step++;}
  }
 }
}
/* Eight-connected cells of the same winning class form one target. */
static unsigned fomo_components(const int8_t output[576],struct fomo_detection boxes[144],unsigned *best){
 uint8_t labels[144],seen[144]={0},queue[144];unsigned count=0;
 for(unsigned i=0;i<144;i++){
  unsigned c=0;for(unsigned j=1;j<4;j++)if(output[4*i+j]>output[4*i+c])c=j;
  labels[i]=c&&output[4*i+c]>=0?c:0;
 }
 *best=0;
 for(unsigned i=0;i<144;i++)if(labels[i]&&!seen[i]){
  unsigned head=0,tail=1,l=i%12,r=l,t=i/12,b=t,peak=0,peak_cell=i;queue[0]=i;seen[i]=1;
  while(head<tail){
   unsigned cell=queue[head++],x=cell%12,y=cell/12;
   if(x<l)l=x;if(x>r)r=x;if(y<t)t=y;if(y>b)b=y;
   unsigned score=(int)output[4*cell+labels[i]]+128;if(score>peak){peak=score;peak_cell=cell;}
   for(int dy=-1;dy<=1;dy++)for(int dx=-1;dx<=1;dx++){
    int nx=(int)x+dx,ny=(int)y+dy;
    if(nx<0||nx>=12||ny<0||ny>=12)continue;
    unsigned next=(unsigned)ny*12+(unsigned)nx;
    if(!seen[next]&&labels[next]==labels[i]){seen[next]=1;queue[tail++]=next;}
   }
  }
  boxes[count]=(struct fomo_detection){(uint16_t)(l*8),(uint16_t)(t*8),(uint16_t)((r+1)*8),(uint16_t)((b+1)*8),labels[i],(uint8_t)peak,(uint16_t)tail,(uint16_t)peak_cell};
  if(count&&(peak>boxes[*best].confidence||(peak==boxes[*best].confidence&&tail>boxes[*best].cells)))*best=count;
  count++;
 }
 return count;
}
