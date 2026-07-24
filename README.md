# axi_tniu UVM 验证平台

RKNoC 项目 **AXI Target NIU（axi_tniu）** 模块的 UVM 验证平台。该模块完成
NoC 内部 RKNP 协议与 AXI4 协议之间的双向转换。

本平台针对以下验证配置搭建：

| 配置项 | 取值 |
|--------|------|
| NBYTEPERWORD | 8（64-bit 数据） |
| HeadPenalty | 0（RKNP 固定） |
| Req-Error 处理 | 开启 |
| Wrap 重排 | 开启（WRAP_ALIGN_MODE=1） |
| Bufferable / Early-response | 开启（EARLY_RSP_MODE=1） |
| 同地址保序 | 开启（ADDR_BP_TYPE=2，粒度 64B） |
| AXID 映射 | 开启（ORDKEY_WITH=8, AXID_WITH=4） |

## 目录结构

```
axi_tniu_uvm/
├── doc/
│   ├── axi_tniu_vplan.xlsx      验证计划（7 个 sheet）
│   └── verdi_vcs_guide.md       VCS + Verdi 虚拟机实操指南
├── rtl/
│   └── axi_tniu.v               DUT 顶层（子模块需另行提供）
├── sim/
│   ├── Makefile                 VCS/Verdi 编译-运行-覆盖率流程
│   ├── rtl.f  tb.f  axi_tniu.f  filelist
├── scripts/
│   └── gen_vplan.py             验证计划生成脚本
└── tb/
    ├── common/     rknp_pkg（协议单一真源）、rknp_if、axi_if
    ├── rknp_agent/ RKNP 请求驱动 + 双通道监视器 + agent
    ├── axi_agent/  AXI slave 驱动（存储器 + 乱序 + 交织）+ 监视器 + agent
    ├── env/        cfg、refmodel、scoreboard、coverage、env、virtual_sequencer
    ├── seq_lib/    RKNP 序列库 + 虚拟序列
    ├── test/       base test + directed/random tests
    └── top/        axi_tniu_pkg（聚合包）、tb_top
```

## 快速开始

```bash
cd sim
make comp RTL_HOME=/path/to/your/rtl   # 编译（需提供子模块 RTL）
make run  TEST=test_sanity             # 运行冒烟
make regress                           # 跑全部内置测试
make cov                               # 生成覆盖率报告
make verdi                             # 打开 Verdi 看波形
```

详见 `doc/verdi_vcs_guide.md`。

## 关键说明

- `tb/common/rknp_pkg.sv` 是 flit 位域布局的**单一真源**；若子模块实际提取的字段
  偏移/位宽与此不同，只需改这一个文件，全平台随之一致。
- `rtl/axi_tniu.v` 仅是顶层封装，实例化了 `wrap_align / wrap_adjust / req_order /
  rsp_order / addr_map / rreq_trans / wreq_trans / rsp_trans / watchdog /
  ely_rsp_detect` 等子模块。**这些子模块 RTL 必须通过 `sim/rtl.f` 提供**，否则无法
  elaboration。
- `tb_top` 用本验证配置的模式参数例化 DUT（`ADDR_BP_TYPE=2`、`EARLY_RSP_MODE=1`、
  `WRAP_ALIGN_MODE=1`），与验证计划一致。
