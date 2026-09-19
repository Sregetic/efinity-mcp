
// Efinity Top-level template
// Version: 2026.1.132.3.9
// Date: 2026-09-19 02:47

// Copyright (C) 2013 - 2026 Efinix Inc. All rights reserved.

// This file may be used as a starting point for Efinity synthesis top-level target.
// The port list here matches what is expected by Efinity constraint files generated
// by the Efinity Interface Designer.

// To use this:
//     #1)  Save this file with a different name to a different directory, where source files are kept.
//              Example: you may wish to save as sobel_220.v
//     #2)  Add the newly saved file into Efinity project as design file
//     #3)  Edit the top level entity in Efinity project to:  sobel_220
//     #4)  Insert design content.


module sobel_220
(
  (* syn_peri_port = 0 *) input fb,
  (* syn_peri_port = 0 *) input clk,
  (* syn_peri_port = 0 *) input CLK_25M,
  (* syn_peri_port = 0 *) output result,
  (* syn_peri_port = 0 *) output pll_rstn
);


endmodule

