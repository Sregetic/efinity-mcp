# Repository instructions

- Implement the local Efinity adapter, not the FPGA competition design itself.
- Read `docs/vendor-interfaces.md`, `SECURITY.md`, and existing tests before changes.
- Do not change pins, clocks, voltage standards, programming defaults or trust flags without explicit operator approval.
- Never claim a mock build, fake bitstream, unit test or zero exit code proves FPGA correctness/timing closure.
- No arbitrary shell/Tcl tools, remote listeners, hard-coded credentials, vendor binaries or licensed IP.
- Keep Efinity's Python runtime separate from this project's Python 3.11+ virtual environment.
- Preserve the distinction: `pgm` generates files; JTAG programming uses `.bit` via a separate gated method.
- Add regression tests for command construction, cancellation, failure, stale evidence and path traversal when changing execution code.
- Run `python -m pytest -q` and `python -m compileall -q src`. CI requires the real MCP SDK protocol test.
- Do not weaken tests, skip the MCP test in CI, or fabricate report fields to make tests pass.
- Do not enable a self-hosted runner or run real hardware jobs without operator authorization.
