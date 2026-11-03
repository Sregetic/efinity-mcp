.section .rodata.fomo,"a"
.balign 16
.global fomo_model
fomo_model:
.incbin "F:/Project/fpga/vision_base/models/shape_fomo/shape_fomo_int8.tflite"
