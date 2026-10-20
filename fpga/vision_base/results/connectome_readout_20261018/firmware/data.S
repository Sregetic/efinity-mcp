.section .rodata.fomo,"a"
.balign 16
.global fomo_model
fomo_model:
.incbin "F:/Project/fpga/vision_base/models/shape_fomo/shape_fomo_int8.tflite"
.balign 16
.global connectome_readout_weights
connectome_readout_weights:
.incbin "F:/Project/fpga/vision_base/models/connectome_readout_bringup/connectome_readout.bin"
