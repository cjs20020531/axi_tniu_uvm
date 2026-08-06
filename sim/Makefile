# =============================================================================
# File        : Makefile
# Description : axi_tniu UVM 的编译和单 testcase 仿真入口。
#
# 职责：
#   - comp  : 编译 RTL/UVM testbench，生成 simv
#   - run   : 运行一个由 TEST 指定的 testcase
#   - cov   : 生成覆盖率报告
#   - verdi : 打开波形
#
# 多 testcase 的顺序和回归汇总由 run_tests_in_order.sh 负责。
# =============================================================================

# ---- 用户可覆盖参数 ---------------------------------------------------------
TEST      ?= test_norm_rd
SEED      ?= 1
UVM_VERB  ?= UVM_MEDIUM
WAVE      ?= 1
COV       ?= 1
RUN_ARGS  ?=

# ---- 工程路径 ---------------------------------------------------------------
THIS_DIR  := $(abspath $(dir $(lastword $(MAKEFILE_LIST))))
TB_HOME   ?= $(abspath $(THIS_DIR)/../tb)
RTL_HOME  ?= $(abspath $(THIS_DIR)/../rtl)
LOG_DIR   ?= $(THIS_DIR)/log

export TB_HOME RTL_HOME

SIMV       := $(THIS_DIR)/simv
FILELIST   := axi_tniu.f
TOP        := tb_top
COMP_LOG   ?= $(LOG_DIR)/compile.log
LOG_FILE   ?= $(LOG_DIR)/$(TEST).log
COV_DIR    ?= $(THIS_DIR)/cov.vdb
COV_REPORT ?= $(THIS_DIR)/cov_report
WAVE_FILE  ?= $(THIS_DIR)/wave.fsdb

# ---- 编译/运行选项 ----------------------------------------------------------
ifeq ($(WAVE),1)
  WAVE_COMPILE_OPTS := +define+FSDB
else
  WAVE_COMPILE_OPTS :=
endif

ifeq ($(COV),1)
  COV_COMPILE_OPTS := -cm line+cond+fsm+tgl+branch+assert -cm_dir $(COV_DIR)
  COV_RUN_OPTS     := -cm line+cond+fsm+tgl+branch+assert \
                      -cm_dir $(COV_DIR) -cm_name $(TEST)_$(SEED)
else
  COV_COMPILE_OPTS :=
  COV_RUN_OPTS     :=
endif

VCS_OPTS := -full64 -sverilog -timescale=1ns/1ps \
            -ntb_opts uvm-1.2 \
            +vcs+lic+wait \
            -debug_access+all \
            -kdb \
            -lca \
            +define+UVM_NO_DEPRECATED \
            $(WAVE_COMPILE_OPTS) \
            $(COV_COMPILE_OPTS)

RUN_OPTS := +UVM_TESTNAME=$(TEST) \
            +UVM_VERBOSITY=$(UVM_VERB) \
            +ntb_random_seed=$(SEED) \
            $(COV_RUN_OPTS) \
            $(RUN_ARGS) \
            -l "$(LOG_FILE)"

# =============================================================================
# Targets
# =============================================================================
.PHONY: comp run cov verdi clean cleanall help

comp:
	@mkdir -p "$(LOG_DIR)"
	@echo "==== compile: RTL_HOME=$(RTL_HOME), COV=$(COV), WAVE=$(WAVE) ===="
	vcs $(VCS_OPTS) -f $(FILELIST) -top $(TOP) -o "$(SIMV)" -l "$(COMP_LOG)"

run:
	@test -x "$(SIMV)" || { \
	  echo "ERROR: $(SIMV) does not exist; run 'make comp' first." >&2; \
	  exit 2; \
	}
	@mkdir -p "$(LOG_DIR)"
	@echo "==== run: TEST=$(TEST), SEED=$(SEED), LOG=$(LOG_FILE) ===="
	"$(SIMV)" $(RUN_OPTS)

cov:
	@test -d "$(COV_DIR)" || { \
	  echo "ERROR: coverage database not found: $(COV_DIR)" >&2; \
	  exit 2; \
	}
	urg -full64 -dir "$(COV_DIR)" -report "$(COV_REPORT)"

verdi:
	@test -f "$(WAVE_FILE)" || { \
	  echo "ERROR: wave file not found: $(WAVE_FILE)" >&2; \
	  exit 2; \
	}
	verdi -sv -ntb_opts uvm-1.2 -f $(FILELIST) -top $(TOP) \
	      -ssf "$(WAVE_FILE)" &

clean:
	rm -rf simv simv.daidir csrc ucli.key vc_hdrs.h .vcsmx_rebuild \
	       novas.* verdiLog DVEfiles AN.DB

cleanall: clean
	rm -rf "$(COV_DIR)" "$(COV_REPORT)" "$(WAVE_FILE)" "$(LOG_DIR)"

help:
	@echo "Targets:"
	@echo "  make comp                         Compile RTL and UVM testbench"
	@echo "  make run TEST=<name>              Run one testcase"
	@echo "  make cov                          Generate coverage report"
	@echo "  make verdi                        Open $(WAVE_FILE)"
	@echo "  make clean | make cleanall        Remove generated files"
	@echo ""
	@echo "Common variables:"
	@echo "  TEST SEED UVM_VERB WAVE(0/1) COV(0/1) RUN_ARGS"
	@echo "  RTL_HOME TB_HOME LOG_DIR LOG_FILE COMP_LOG"
	@echo ""
	@echo "Example:"
	@echo "  make run TEST=test_norm_rd SEED=10 LOG_FILE=log/test_norm_rd.log"
