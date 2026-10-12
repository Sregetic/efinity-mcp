#pragma once
#include <stdint.h>
#define FOMO_MODEL_ID 2u
#define FOMO_MAX_OBJECTS 144
struct fomo_detection { uint16_t left,top,right,bottom; uint8_t label,confidence; uint16_t cells,peak_cell; };
#ifdef __cplusplus
extern "C" {
#endif
extern volatile uint32_t fomo_camera_status[24];
extern volatile uint16_t fomo_packed_input[9216];
extern volatile int8_t fomo_rgb_input[27648],fomo_camera_output[576];
extern volatile struct fomo_detection fomo_detections[FOMO_MAX_OBJECTS];
void fomo_camera_init(void);
void fomo_camera_run(uint32_t source,uint32_t xy,uint32_t wh);
#ifdef __cplusplus
}
#endif
