#pragma once
#include <stdint.h>
#include "tensorflow/lite/micro/micro_error_reporter.h"
#include "tensorflow/lite/micro/micro_interpreter.h"
#include "tensorflow/lite/micro/micro_mutable_op_resolver.h"
#include "tensorflow/lite/micro/micro_profiler.h"
#include "tensorflow/lite/schema/schema_generated.h"
extern "C" const uint8_t fomo_model[];
extern uint8_t __arena_start[];
extern "C" [[noreturn]] void fomo_runtime_fail(uint32_t code);
static uint64_t fomo_ticks(){
 auto p=reinterpret_cast<volatile uint32_t*>(0xf8b0bff8u);uint32_t hi,lo,again;
 do{hi=p[1];lo=p[0];again=p[1];}while(hi!=again);
 return (uint64_t(hi)<<32)|lo;
}
/* Both applications initialize once, using the audited four-op graph. */
static tflite::MicroInterpreter *fomo_create(tflite::MicroProfiler *profiler){
 const auto model=tflite::GetModel(fomo_model);
 if(model->version()!=TFLITE_SCHEMA_VERSION)fomo_runtime_fail(2);
 static tflite::MicroErrorReporter reporter;
 static tflite::MicroMutableOpResolver<4> resolver;
 if(resolver.AddConv2D()!=kTfLiteOk||resolver.AddDepthwiseConv2D()!=kTfLiteOk||resolver.AddAdd()!=kTfLiteOk||resolver.AddSoftmax()!=kTfLiteOk)fomo_runtime_fail(3);
 static tflite::MicroInterpreter interpreter(model,resolver,__arena_start,256*1024,&reporter,profiler);
 if(interpreter.AllocateTensors()!=kTfLiteOk)fomo_runtime_fail(4);
 auto in=interpreter.input(0);auto out=interpreter.output(0);
 if(in->type!=kTfLiteInt8||in->bytes!=27648||in->params.zero_point!=-128||out->type!=kTfLiteInt8||out->bytes!=576||out->params.zero_point!=-128||out->params.scale!=0.00390625f||interpreter.operators_size()!=25)fomo_runtime_fail(5);
 return &interpreter;
}
