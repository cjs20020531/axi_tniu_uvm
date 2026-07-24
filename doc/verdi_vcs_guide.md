# axi_tniu UVM 验证平台 —— VCS + Verdi 虚拟机实操指南

本文档说明如何在装有 Synopsys VCS 与 Verdi 的 Linux 虚拟机上，编译、运行并调试
本 `axi_tniu` UVM 验证平台。所有命令均在 `sim/` 目录下执行。

---

## 0. 前提条件

1. 虚拟机中已安装 **VCS**（含 UVM-1.2 库）与 **Verdi**，并可获取有效 License。
2. RTL：本包 `rtl/axi_tniu.v` 只是**顶层封装**，它例化了下列子模块，必须由你从设计仓库
   提供其 RTL 才能完成 elaboration：

   ```
   wrap_align  wrap_adjust  req_order  rsp_order  addr_map
   rreq_trans  wreq_trans   rsp_trans  watchdog   ely_rsp_detect
   ```

   把这些文件与顶层一起放入某个目录，编译时用 `RTL_HOME` 指向它（见 `sim/rtl.f`）。

---

## 1. 环境变量设置

在 shell 中（或写入 `~/.bashrc` / 项目 `setup.sh`）配置工具路径与 License：

```bash
# --- Synopsys 工具路径（按你虚拟机实际安装路径修改）---
export VCS_HOME=/tools/synopsys/vcs/T-2022.06
export VERDI_HOME=/tools/synopsys/verdi/T-2022.06
export PATH=$VCS_HOME/bin:$VERDI_HOME/bin:$PATH

# --- License ---
export LM_LICENSE_FILE=27000@your_license_server
# 或 export SNPSLMD_LICENSE_FILE=27000@your_license_server

# --- Verdi 与 VCS 联合调试所需（FSDB PLI）---
export LD_LIBRARY_PATH=$VERDI_HOME/share/PLI/VCS/LINUX64:$LD_LIBRARY_PATH
export NOVAS_HOME=$VERDI_HOME
```

验证工具可用：

```bash
which vcs verdi
vcs -ID          # 打印 VCS 版本，确认 License 正常
```

---

## 2. 编译（compile + elaborate）

`sim/Makefile` 已封装完整流程。最简单：

```bash
cd sim
make comp RTL_HOME=/path/to/your/rtl
```

它实际执行的 VCS 命令等价于：

```bash
vcs -full64 -sverilog -timescale=1ns/1ps \
    -ntb_opts uvm-1.2 \
    -debug_access+all -kdb -lca \
    +define+UVM_NO_DEPRECATED +define+FSDB \
    -cm line+cond+fsm+tgl+branch+assert -cm_dir cov.vdb \
    -f axi_tniu.f -top tb_top -o simv -l comp.log
```

关键选项说明：

| 选项 | 作用 |
|------|------|
| `-ntb_opts uvm-1.2` | 自动链接 VCS 自带 UVM-1.2 库 |
| `-debug_access+all -kdb` | 生成 Verdi 交互调试所需的 KDB 数据库 |
| `+define+FSDB` | 打开 `tb_top` 中的 `$fsdbDumpvars` 波形转储 |
| `-cm ...` | 打开覆盖率收集（line/cond/fsm/tgl/branch/assert）|
| `-f axi_tniu.f` | 顶层 filelist：先编译 `rknp_pkg` 与两个 interface，再编译 UVM 包与 `tb_top` |

若编译报 "module xxx not found"，说明子模块 RTL 未加入——请编辑 `sim/rtl.f`，
取消相应行注释并填对路径。

---

## 3. 运行仿真

运行默认冒烟测试：

```bash
make run                       # 等价 +UVM_TESTNAME=test_sanity
```

运行指定测试、指定随机种子：

```bash
make run TEST=test_random SEED=7
make run TEST=test_wrap
```

可用测试列表（对应验证计划的用例）：

```
test_sanity     混合冒烟
test_rd         顺序读 (INCR)
test_wr         顺序写 (INCR)
test_wrap       绕回读写 (WRAP 重排)
test_err        请求错误注入 (Req-Error 反射)
test_same_addr  同地址保序 (WAW/WAR/RAW)
test_axid       AXID 映射 (OrderKey 别名)
test_ely        bufferable / early response
test_mix        directed 全特性串行
test_random     大规模约束随机回归
```

直接用 simv 运行也可以：

```bash
./simv +UVM_TESTNAME=test_rd +UVM_VERBOSITY=UVM_HIGH \
       +ntb_random_seed=3 -l test_rd.log
```

一键跑内置回归：

```bash
make regress                   # 依次运行上面所有测试
```

---

## 4. 用 Verdi 看波形与调试

仿真结束会生成 `wave.fsdb`。打开 Verdi：

```bash
make verdi
```

等价命令：

```bash
verdi -sv -ntb_opts uvm-1.2 -f axi_tniu.f -top tb_top -ssf wave.fsdb &
```

在 Verdi 中：

1. 左侧 **Hierarchy** 展开 `tb_top`，把 `rknp_vif`、`axi_vif`、`dut` 拖入波形窗。
2. 建议重点观察：
   - RKNP 请求通道 `rknp_rxreq_*` 与响应通道 `rknp_txrsp_*` 的 `head/tail/valid/ready/data`；
   - AXI 五通道 `axi_m_aw*/w*/b*/ar*/r*`；
   - DUT 内部 `req_order`/`rsp_order` 的保序与 early-response 信号。
3. 使用 **nSchema / nTrace** 从某个信号反向追踪驱动源，定位转换错误。

若只想交互式带波形跑（不预生成 FSDB），也可：

```bash
./simv +UVM_TESTNAME=test_rd -gui=verdi
```

---

## 5. 覆盖率

编译与运行已带 `-cm`，数据落在 `cov.vdb`。生成报告：

```bash
make cov
```

等价：

```bash
urg -full64 -dir cov.vdb -report cov_report
```

用浏览器打开 `cov_report/dashboard.html` 查看行/条件/FSM/翻转/分支/断言覆盖率，
再结合 UVM 功能覆盖率（`axi_tniu_coverage` 里的 `cg_req/cg_axid/cg_burst/cg_err/cg_resp`）
评估验证计划中各特性的收敛情况。

---

## 6. 清理

```bash
make clean       # 删除 simv、日志等
make cleanall    # 额外删除覆盖率库与 FSDB
```

---

## 7. 常见问题

- **`Error-[UMRACC]` / vif 为 null**：检查 `tb_top` 里 `uvm_config_db#(virtual ...)::set`
  的路径是否与 env 中 agent 实例名一致（`uvm_test_top.env.rknp_agt`、`uvm_test_top.env.axi_agt`）。
- **全局超时 fatal**：某个请求没有等到响应。先看 scoreboard 的 `C-LEAK-01` 报告，
  再到 Verdi 里追 `rknp_txrsp_valid` 为何不拉高。
- **`awsize != 3` 断言失败**：说明 DUT 输出的 AXI 传输 size 与 64-bit 数据位宽不符，
  检查 `NBYTEPERWORD` 参数在 RTL 与 TB 是否都为 8。
- **子模块找不到**：见第 2 节，补全 `sim/rtl.f`。
