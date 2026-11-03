.section .rodata.fomo,"a"
.balign 16
.global fomo_model
fomo_model:
.incbin "F:/Project/fpga/vision_base/models/shape_fomo/shape_fomo_int8.tflite"
.balign 16
.global fomo_inputs
fomo_inputs:
.incbin "F:/Project/fpga/vision_base/models/shape_fomo/test_vectors/blank_input.bin"
.incbin "F:/Project/fpga/vision_base/models/shape_fomo/test_vectors/circle_input.bin"
.incbin "F:/Project/fpga/vision_base/models/shape_fomo/test_vectors/rectangle_input.bin"
.incbin "F:/Project/fpga/vision_base/models/shape_fomo/test_vectors/triangle_input.bin"
.balign 16
.global fomo_expected
fomo_expected:
.incbin "F:/Project/fpga/vision_base/models/shape_fomo/test_vectors/blank_expected_output.bin"
.incbin "F:/Project/fpga/vision_base/models/shape_fomo/test_vectors/circle_expected_output.bin"
.incbin "F:/Project/fpga/vision_base/models/shape_fomo/test_vectors/rectangle_expected_output.bin"
.incbin "F:/Project/fpga/vision_base/models/shape_fomo/test_vectors/triangle_expected_output.bin"
