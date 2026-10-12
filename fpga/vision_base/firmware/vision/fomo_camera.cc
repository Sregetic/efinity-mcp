#include <stdint.h>
#include "control_service.h"
#include "fomo_pixels.h"
#include "fomo_runtime.h"
extern "C" {
volatile uint32_t fomo_camera_status[24];
volatile uint16_t fomo_packed_input[9216];
volatile int8_t fomo_rgb_input[27648],fomo_camera_output[576];
volatile struct fomo_detection fomo_detections[144];
volatile uint64_t fomo_camera_layer_cycles[25];
volatile char fomo_camera_log[2048];
}
extern "C" void fomo_control_poll(){control_service_step();}
extern "C" [[noreturn]] void fomo_runtime_fail(uint32_t code){
 fomo_camera_status[17]=code;fomo_camera_status[1]=4;
 *reinterpret_cast<volatile uint32_t*>(0xf8100004u)=3;
 for(;;)control_service_step();
}
extern "C" [[noreturn]] void fomo_kernel_fail(){fomo_runtime_fail(7);}
extern "C" void DebugLog(const char *s){
 unsigned n=fomo_camera_status[18];
 while(*s&&n<sizeof(fomo_camera_log)-1)fomo_camera_log[n++]=*s++;
 if(n<sizeof(fomo_camera_log)-1)fomo_camera_log[n++]='\n';
 fomo_camera_log[n]=0;fomo_camera_status[18]=n;
}
namespace tflite {
int32_t ticks_per_second(){return 100000000;}
int32_t GetCurrentTimeTicks(){return static_cast<int32_t>(fomo_ticks());}
}
class CameraProfiler final:public tflite::MicroProfiler {
 public:
 unsigned index=0;uint64_t start=0;
 uint64_t BeginEvent(const char*) override{
  control_service_step();fomo_camera_status[19]=index;start=fomo_ticks();return index;
 }
 void EndEvent(uint64_t handle) override{fomo_camera_layer_cycles[handle]=fomo_ticks()-start;index++;}
 private:TF_LITE_REMOVE_VIRTUAL_DELETE;
};
static CameraProfiler *profiler;
static tflite::MicroInterpreter *interpreter;
extern "C" void fomo_camera_init(){
 fomo_camera_status[0]=0x464f4d32;fomo_camera_status[1]=1;
 fomo_camera_status[7]=FOMO_MODEL_ID;fomo_camera_status[15]=100000000;
 static CameraProfiler p;profiler=&p; // Bare-metal entry has no global C++ constructor loop.
 interpreter=fomo_create(profiler);fomo_camera_status[16]=interpreter->arena_used_bytes();
 fomo_camera_status[20]=128;fomo_camera_status[21]=27648;fomo_camera_status[22]=576;
 fomo_camera_status[1]=0;
}
extern "C" void fomo_camera_run(uint32_t source,uint32_t xy,uint32_t wh){
 fomo_camera_status[1]=2;
 const auto pixels=reinterpret_cast<const volatile uint16_t*>(source);
 auto input=interpreter->input(0)->data.int8;
 uint64_t begin=fomo_ticks();
 fomo_rgb_roi(pixels,xy,wh,fomo_packed_input,input);
 for(unsigned i=0;i<27648;i++)fomo_rgb_input[i]=input[i];
 uint64_t prepared=fomo_ticks();profiler->index=0;
 if(interpreter->Invoke()!=kTfLiteOk)fomo_runtime_fail(6);
 uint64_t inferred=fomo_ticks();auto output=interpreter->output(0)->data.int8;
 struct fomo_detection boxes[144];unsigned best;
 unsigned count=fomo_components(output,boxes,&best);
 for(unsigned i=0;i<576;i++)fomo_camera_output[i]=output[i];
 for(unsigned i=0;i<count*sizeof(boxes[0]);i++)((volatile uint8_t*)fomo_detections)[i]=((const uint8_t*)boxes)[i];
 uint64_t done=fomo_ticks();
 fomo_camera_status[8]=prepared-begin;fomo_camera_status[9]=inferred-prepared;
 fomo_camera_status[10]=done-inferred;fomo_camera_status[11]=done-begin;
 fomo_camera_status[12]=count;fomo_camera_status[13]=best;
 fomo_camera_status[14]=count?boxes[best].label:0;
}
