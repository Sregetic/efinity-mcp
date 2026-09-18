# Windows Ti60 Runner deployment

This connects the existing FPGA scripts; the MCP adapter and RTL are unchanged.
Repository jobs run only trusted `main` commits. No PR or `pull_request_target`
job is sent to this computer. Review and merge the deployment PR before dispatch.

## Host and installation

- Runner: `efinity-ti60-win`, labels `self-hosted,Windows,X64,efinity,ti60`.
- Install: `C:\actions-runner-efinity`; isolated jobs: `F:\efinity-ci\jobs`.
- Tools: PowerShell 7, `F:\Efinity\2026.1`, its `python311\bin\python.exe`,
  and `C:\iverilog\bin\{iverilog,vvp}.exe`.
- Use the latest Windows x64 asset from the official `actions/runner` release API.
  Compare `Get-FileHash -Algorithm SHA256` with the release asset digest before
  extraction. This deployment verified 2.337.0; do not hard-code it for upgrades.
- `scripts/runner/Install-RunnerService.ps1` registers the already verified
  installation through official `config.cmd --runasservice`, after UAC approval.
  It uses `NT AUTHORITY\NETWORK SERVICE`, not SYSTEM, and does not replace any
  existing Runner. `gh` obtains a short-lived registration token in memory.
- The machine's existing proxy is copied only into Runner `.env` after the
  direct connection test failed. No WinHTTP/TLS settings are changed. Keep that
  file, `.credentials*`, tokens and license files outside Git and artifacts.
- Runner `.env` references the existing Efinity user configuration. Host smoke
  and a real compile must pass **under the installed service identity** before
  claiming license/USB acceptance. Interactive-user success is insufficient.

After installation, dispatch **Efinity FPGA build**, `smoke_only=true`, on main.
Check the artifact `host.log` for the actual host and service identity. Then
dispatch with `smoke_only=false`. Restart only this Runner service and repeat
smoke to verify recovery; do not reboot the computer.

## Build

`Invoke-FpgaBuild.ps1` creates a unique directory, preserving relative RTL
dependencies and excluding historical `outflow`, `results`, `artifacts`, caches
and backups. Checkout skips LFS smudging: the two reference archives are not
build inputs. Any referenced source still represented by an LFS pointer causes
a precise dependency error; fetch only that path before retrying.

The three simulation scripts run in separate `pwsh -NoProfile` processes. Only
after they pass does `synthesize.ps1 -Top board -Flow compile -VideoMode camera`
run once (map/interface/pnr/pgm). A 30-minute vendor timeout and 90-minute job
timeout bound execution. Both workflows use `efinity-ti60-device` concurrency
without cancellation and the same global host mutex. An abandoned mutex fails
closed; do not kill unrelated GUI/debug processes to clear it.

Diagnostics upload even on failure. Only a successful fresh build with complete
pin/clock evidence, nonnegative final setup/hold slack and a nonempty current
bitstream produces `efinity-bitstream-<run_id>`. Outputs never commit to main.
Enable filtered main push triggers **after** manual end-to-end acceptance, for
`fpga/vision_base/rtl/**`, `board/**`, `sim/**`, `scripts/**`, and the runner
scripts/workflow. Exclude generated output paths. Push activation is deliberately
not included before that acceptance.

## SRAM: separate operator action

**Efinity SRAM program** requires an exact successful build run ID, camera mode,
currently enumerated USB URL, and literal `PROGRAM SRAM`. It verifies repository,
build workflow ID, main branch, successful conclusion and main ancestry. There
is no `latest` fallback and no repository `.bit` fallback.

The current private repository rejected Required reviewers with HTTP 422:
“billing plan supports the required reviewers protection rule”. Therefore this
deployment uses local one-use approval, not an unprotected environment label.

Before first download, present the build run/commit, bitstream hash, camera mode,
physical board/interface and **JTAG SRAM only, no Flash**, and obtain operator
confirmation. Read descriptors using `enumerate_usb.py` in the vendor environment.
Prefer serial URLs. The attached FTDI device currently exposes no serial; it
requires explicit confirmation of its current physical PnP instance and interface
2. Changed/ambiguous identities must be re-confirmed.

After confirmation, a local administrator runs `Approve-Sram.ps1` with the exact
build ID, commit, bit hash, URL, and serial or PnP identity. The resulting permit
is valid for 30 minutes under `C:\ProgramData\efinity-runner`. The service may
read and delete this one file but cannot create approvals in that directory.
The programming script validates artifacts and live identity, consumes the permit,
then invokes only `ftdi_program.py ... -m jtag` at 1 MHz. No Flash, OTP or eFuse
operation is implemented. The display controls are a separate explicit operation.

`program.json` records programmer completion independently of
`visual_acceptance: pending user`. Only the operator can confirm image quality.

## Deployment evidence (2026-09-18)

Original committed script rebuilt in a clean copy: exit 0, four stages PASS,
final WNS 0.472 ns / WHS 0.026 ns. This was an interactive-user run, not a service
or GitHub acceptance run.

The isolated deployment entrypoint also passed all three simulation suites and
completed a fresh vendor compile with exit 0, WNS 0.472 ns / WHS 0.026 ns.
Its deployment gate correctly returned failure for the 11 unconfirmed interface
pins and produced diagnostics only (no deploy directory). Python tests passed
71 cases; one Windows symlink-privilege case was skipped. The real MCP protocol
test ran. Both workflows passed actionlint with the configured custom labels.

The historical failure at 2026-09-16 16:32:29 UTC explicitly recorded
`Source changed during compilation: board/ti60f225_v4/rtl/vision/vision_hysteresis_sweep.sv`.
The failure was valid; the console file only captured the vendor pipeline, and
the old script skipped timing parsing once exit_code became nonzero. The updated
script preserves failure and records vendor exit, source mutations, exceptions
and timing diagnostics independently. No status JSON or constraint was edited.

The existing placement report lists 11 missing interface pins (unused JTAG
signals and DDR address bits 14/15). This deployment does not waive that finding.
Until the required interface coverage is confirmed, the deployment gate blocks
bitstream release/programming even if vendor timing passes. Resolving an actual
RTL/board constraint issue requires a separately reviewed change.

Tests: `pwsh -NoProfile -File tests/Test-RunnerGates.ps1` covers failure/missing
vendor status, negative/missing timing, missing pins, stale/empty bitstreams,
source mutation and missing clocks. Synthetic tests do not establish FPGA
correctness. Follow repository Python tests separately from real FPGA acceptance.
