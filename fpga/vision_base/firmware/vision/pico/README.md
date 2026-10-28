pico runtime, MIT, Nenad Markus. Unmodified upstream source.
https://github.com/nenadmarkus/pico/tree/346881039e5d1f5abe64733a49886bdfd5ab2d51

M7 uses upstream detection clustering. Its unrotated window evaluator in ../geometry_face.c specializes the pinned depth-6/468-tree model and 480x270 input. The installed signed dot4 and MulHi CFU scales packed offsets and avoids serial software shifts; no new FPGA arithmetic is instantiated. The scanner/window split fits the existing 2KiB instruction-cache working loop.

The private FP32 adder accepts the pinned model's normal/zero finite scores and the scanner's bounded positive coordinates. Leaves have minimum exponent -19 and absolute value <=1: every prefix is a multiple of 2^-42, with no subnormal or overflow. It retains binary32 round-to-nearest/even at every addition. Other application floating-point code is untouched.

sim/test_geometry_face_math.c checks the model range, 2000000 finite additions (including all signed-zero pairs/cancellation), 974168 upstream window decisions and bit-exact FP32 scores, and 974168 original scanner positions. scripts/test_geometry_m7.py runs these checks with CFU software emulation plus the17 geometry/face fixtures; target RV32I results remain compared against the original saved boxes.
