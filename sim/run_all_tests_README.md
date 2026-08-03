# UVM testcase 批量运行脚本

把 `run_all_tests.sh` 放到工程根目录或 `sim/` 目录，并增加执行权限：

```bash
chmod +x run_all_tests.sh
```

默认行为：

- 从 `tb/test/` 递归查找 `test_*.sv`；
- 以文件名作为 UVM test 类名，例如 `test_sanity.sv` 对应 `TEST=test_sanity`；
- 先执行一次 `make comp`；
- 再对每个 test 执行 `make run TEST=<test> SEED=1`；
- 日志写入 `sim/log/<test>.log`；
- test 按文件名排序提交；默认 `-j 1`，因此严格串行。

## 常用命令

串行运行全部 test：

```bash
./run_all_tests.sh
```

最多并行运行 4 个 test：

```bash
./run_all_tests.sh -j 4
```

只运行指定 test：

```bash
./run_all_tests.sh -j 2 test_sanity test_raw
```

指定随机种子：

```bash
./run_all_tests.sh -j 4 --seed 123
```

只查看将要运行的 test：

```bash
./run_all_tests.sh --list
```

如果工程仍希望对每个 test 执行原来的 `make all`：

```bash
./run_all_tests.sh --no-build --run-target all -j 1
```

不建议并行执行多个 `make all`，因为多个编译任务可能同时改写 `simv`、`csrc` 等公共产物。需要并行仿真时，建议保留默认方式：先 `make comp` 一次，再并行执行 `make run`。

## 可配置项

也可以使用环境变量：

```bash
JOBS=4 SEED=123 ./run_all_tests.sh
```

主要变量：

- `JOBS`：并行度；
- `SEED`：随机种子；
- `TEST_DIR`：test 文件目录；
- `TEST_PATTERN`：文件匹配模式，默认 `test_*.sv`；
- `LOG_DIR`：日志目录，默认 `sim/log`；
- `BUILD_TARGET`：预编译目标，默认 `comp`；
- `RUN_TARGET`：单 testcase 运行目标，默认 `run`。

额外的 Make 参数可重复传递：

```bash
./run_all_tests.sh -j 4 \
  --make-arg GUI=0 \
  --make-arg COV=1
```

脚本同时向 Makefile 传入 `LOG_DIR`、`LOG`、`LOG_FILE`。即使现有 Makefile 未使用这些变量，Make 命令的标准输出和错误输出仍会保存到 `sim/log/<test>.log`。

退出码为 0 表示全部通过；任何 Make 任务返回非 0，或日志最终统计中 `UVM_ERROR/UVM_FATAL` 非 0，脚本都会返回失败。
