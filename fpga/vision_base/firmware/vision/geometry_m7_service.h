#pragma once
/* Nonzero pauses AI scheduling while the shared M7 input/job is active; private face work does not. */
unsigned geometry_m7_service_step(unsigned available);
