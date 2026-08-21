# axi_tniu Design Compiler pre-layout PPA flow

This directory contains a reproducible Design Compiler flow for estimating the
pre-layout performance, power and area of `rtl/axi_tniu.v`.

## 1. What the flow uses

- Top design: `axi_tniu`
- RTL inputs: the 13 synthesizable Verilog files under `rtl/`
- Clock: `aclk`
- Reset: active-low asynchronous `aresetn`
- Default target: 100 MHz (`10 ns` period)
- Default library: `/home/ic_libs/TSMC.90/aci/sc-x/libspm/typical.db`
- Default PVT: TSMC 90 nm typical, 1.0 V, 25 C
- Default synthesis: `compile_ultra -no_autoungroup`, followed by an incremental pass
- Default power mode: vectorless activity; SAIF or VCD can be supplied later

The 100 MHz clock and I/O budgets are initial engineering assumptions derived
from the current UVM clock. They are not an external interface specification.
Change them when the real system timing budget is known.

## 2. First run

Load the IC_EDA_Lite environment and verify that `dc_shell` is visible:

```bash
command -v dc_shell
echo "$SNPSLMD_LICENSE_FILE"
```

Then run from the repository root:

```bash
chmod +x ppa/run_dc_ppa.sh
./ppa/run_dc_ppa.sh
```

The launcher creates a timestamped directory:

```text
ppa/runs/dc_YYYYMMDD_HHMMSS/
├── dc_shell.log
├── resolved_configuration.txt
├── database/
│   ├── axi_tniu_elaborated.ddc
│   ├── axi_tniu_mapped.ddc
│   └── axi_tniu.svf
├── outputs/
│   ├── axi_tniu_mapped.v
│   ├── axi_tniu_mapped.sdc
│   └── axi_tniu_mapped.sdf
└── reports/
    ├── ppa_summary.rpt
    ├── qor.rpt
    ├── timing_setup.rpt
    ├── timing_hold.rpt
    ├── area_hier.rpt
    ├── power_hier.rpt
    └── constraints_all_violators.rpt
```

Start by reading `ppa_summary.rpt`, then use the detailed reports to explain the
result.

## 3. Common configurations

### Change the target frequency

Frequency in MHz is `1000 / period_ns`.

```bash
# 200 MHz
DC_CLOCK_PERIOD_NS=5.0 ./ppa/run_dc_ppa.sh

# 250 MHz
DC_CLOCK_PERIOD_NS=4.0 ./ppa/run_dc_ppa.sh
```

### Use standard DC when a DC-Ultra license is unavailable

```bash
DC_COMPILE_MODE=standard ./ppa/run_dc_ppa.sh
```

### Change I/O budgets and output load

```bash
DC_INPUT_DELAY_MAX_NS=0.8 \
DC_OUTPUT_DELAY_MAX_NS=0.8 \
DC_OUTPUT_LOAD_PF=0.03 \
./ppa/run_dc_ppa.sh
```

### Put results in a specific directory

```bash
PPA_RUN_DIR="$PWD/ppa/runs/experiment_100mhz" ./ppa/run_dc_ppa.sh
```

### Run a different library corner

The library and operating-condition names must match:

```bash
DC_TARGET_LIBRARY=/home/ic_libs/TSMC.90/aci/sc-x/libspm/slow.db \
DC_OPERATING_CONDITION=slow \
PPA_RUN_DIR="$PWD/ppa/runs/slow_100mhz" \
./ppa/run_dc_ppa.sh
```

For a fair comparison, keep all RTL, constraints and power activity identical
between corners.

## 4. Power activity modes

Power quality depends strongly on switching activity.

### Vectorless estimate

This is the default first run:

```bash
./ppa/run_dc_ppa.sh
```

Primary data inputs use a static probability of `0.5` and toggle rate of `0.10`
relative to `aclk`. DC propagates that activity through the mapped design. This
is useful for bringing up the flow, but it is not workload-accurate.

Override the assumptions with:

```bash
DC_INPUT_STATIC_PROBABILITY=0.4 \
DC_INPUT_TOGGLE_RATE=0.08 \
./ppa/run_dc_ppa.sh
```

### SAIF-based power

Once VCS generates activity for a representative UVM test:

```bash
DC_SAIF_FILE="$PWD/sim/axi_tniu.saif" \
DC_ACTIVITY_SCOPE=tb_top/dut \
./ppa/run_dc_ppa.sh
```

SAIF is preferred over vectorless estimation because it preserves workload
activity and hierarchy. The scope must match the DUT instance path recorded in
the activity file.

### VCD-based power

```bash
DC_VCD_FILE="$PWD/sim/axi_tniu.vcd" \
DC_ACTIVITY_SCOPE=tb_top/dut \
./ppa/run_dc_ppa.sh
```

Do not set both SAIF and VCD. If both are set, SAIF takes priority.

## 5. Reading the result

### Performance

Read `timing_setup.rpt` and `qor.rpt`:

- `slack >= 0`: the mapped design meets the selected period under these assumptions.
- `slack < 0`: timing fails; the absolute value is the shortfall.
- The pre-layout clock is ideal and routing parasitics are estimated, so positive
  slack should include margin.

### Area

Read `area_hier.rpt`:

- `Total cell area` is the mapped standard-cell area in the library's area units.
- Hierarchical lines identify the modules responsible for the largest area.
- This excludes placement utilization, routing channels, filler cells, clock-tree
  cells and physical-only cells.

### Power

Read `power_hier.rpt`:

- `Cell Internal Power`: internal charging and short-circuit activity.
- `Net Switching Power`: capacitive switching power.
- `Cell Leakage Power`: static leakage from the library.
- The report is meaningful only when the activity source is recorded together
  with the result. `ppa_summary.rpt` states whether vectorless, SAIF or VCD data
  was used.

## 6. What this result is not

This flow does not run placement, clock-tree synthesis or routing. It therefore
does not include extracted SPEF parasitics, clock skew, congestion, IR drop or
physical utilization. `icc2_shell` or another place-and-route tool plus LEF/
technology data is required for post-layout PPA.

