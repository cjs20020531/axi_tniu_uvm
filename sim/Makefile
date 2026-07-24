# =============================================================================
# File        : Makefile
# Description : VCS + UVM build/run flow for the axi_tniu verification env.
#               Targets:
#                 make comp                compile + elaborate (build simv)
#                 make run  TEST=test_rd   run one test (default test_sanity)
#                 make all  TEST=...        comp + run
#                 make cov                 merge + report coverage (urg)
#                 make verdi               open the last FSDB in Verdi
#                 make regress             run the built-in test list
#                 make clean / cleanall    remove products
#
# Prerequisites (set in your shell or override on the command line):
#                 RTL_HOME   directory holding axi_tniu.v + all sub-modules
#                 TB_HOME    tb/ directory of this package (auto-detected)
#                 VCS_HOME, VERDI_HOME, and a valid UVM install with VCS
# =============================================================================

# ---- user-overridable knobs -------------------------------------------------
TEST      ?= test_sanity
SEED      ?= 1
UVM_VERB  ?= UVM_MEDIUM
WAVE      ?= 1                 # 1 => dump FSDB, 0 => no wave
COV       ?= 1                 # 1 => enable coverage

# ---- paths ------------------------------------------------------------------
THIS_DIR  := $(abspath $(dir $(lastword $(MAKEFILE_LIST))))
TB_HOME   ?= $(abspath $(THIS_DIR)/../tb)
RTL_HOME  ?= $(abspath $(THIS_DIR)/../rtl)
export TB_HOME RTL_HOME

SIMV      := $(THIS_DIR)/simv
FILELIST  := axi_tniu.f
TOP       := tb_top

# ---- coverage / wave switches ----------------------------------------------
ifeq ($(WAVE),1)
  WAVE_DEF := +define+FSDB
else
  WAVE_DEF :=
endif

ifeq ($(COV),1)
  COV_CMP  := -cm line+cond+fsm+tgl+branch+assert -cm_dir $(THIS_DIR)/cov.vdb
  COV_RUN  := -cm line+cond+fsm+tgl+branch+assert -cm_dir $(THIS_DIR)/cov.vdb -cm_name $(TEST)_$(SEED)
else
  COV_CMP  :=
  COV_RUN  :=
endif

# ---- VCS compile options ----------------------------------------------------
VCS_OPTS := -full64 -sverilog -timescale=1ns/1ps \
            -ntb_opts uvm-1.2 \
            +vcs+lic+wait \
            -debug_access+all \
            -kdb \
            -lca \
            +define+UVM_NO_DEPRECATED \
            $(WAVE_DEF) $(COV_CMP) \
            -l comp.log

# ---- simv run options -------------------------------------------------------
RUN_OPTS := +UVM_TESTNAME=$(TEST) \
            +UVM_VERBOSITY=$(UVM_VERB) \
            +ntb_random_seed=$(SEED) \
            $(COV_RUN) \
            -l $(TEST)_$(SEED).log

# =============================================================================
# Targets
# =============================================================================
.PHONY: all comp run regress cov verdi clean cleanall help

all: comp run

comp:
	@echo "==== VCS compile (RTL_HOME=$(RTL_HOME)) ===="
	vcs $(VCS_OPTS) -f $(FILELIST) -top $(TOP) -o simv

run:
	@echo "==== run $(TEST) (seed=$(SEED)) ===="
	$(SIMV) $(RUN_OPTS)

# run the built-in directed + random regression
REGRESS_TESTS := test_sanity test_rd test_wr test_wrap test_err \
                 test_same_addr test_axid test_ely test_mix test_random
regress: comp
	@for t in $(REGRESS_TESTS); do \
	  echo "==== regress: $$t ===="; \
	  $(SIMV) +UVM_TESTNAME=$$t +UVM_VERBOSITY=$(UVM_VERB) \
	          +ntb_random_seed=$(SEED) $(COV_RUN) -l $$t.log ; \
	done

# merge coverage and produce an HTML/urg report
cov:
	@echo "==== coverage report ===="
	urg -full64 -dir $(THIS_DIR)/cov.vdb -report $(THIS_DIR)/cov_report

# open the most recent FSDB in Verdi (interactive)
verdi:
	@echo "==== launch Verdi ===="
	verdi -sv -ntb_opts uvm-1.2 -f $(FILELIST) -top $(TOP) -ssf wave.fsdb &

clean:
	rm -rf simv simv.daidir csrc *.log ucli.key vc_hdrs.h .vcsmx_rebuild novas.* verdiLog

cleanall: clean
	rm -rf cov.vdb cov_report *.fsdb DVEfiles AN.DB

help:
	@echo "Targets: comp | run TEST=<name> | all | regress | cov | verdi | clean | cleanall"
	@echo "Knobs  : TEST SEED UVM_VERB WAVE(0/1) COV(0/1) RTL_HOME TB_HOME"
	@echo "Tests  : $(REGRESS_TESTS)"
