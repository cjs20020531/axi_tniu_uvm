#!/usr/bin/env bash
# =============================================================================
# axi_tniu UVM 验证平台 —— 环境配置脚本
#
# 用法（注意必须用 source，不能用 ./setup.sh 直接执行）：
#     source setup.sh
#     . setup.sh          # 与上面等价
#
# 为什么用 source：直接 ./setup.sh 会在一个"子 shell"里运行，
# 里面 export 的变量在脚本结束后就消失了，不会影响你当前的终端。
# source 是把脚本内容"就地"在当前 shell 执行，变量才会真正生效。
# =============================================================================

# -----------------------------------------------------------------------------
# 1) 工具安装路径（★请改成你虚拟机上的真实路径★）
#    如果你不知道路径，见 verdi_vcs_guide.md 第 1 节问题 4 的查找方法，
#    或直接跑：  which vcs   which verdi
# -----------------------------------------------------------------------------
export VCS_HOME=/tools/synopsys/vcs/T-2022.06
export VERDI_HOME=/tools/synopsys/verdi/T-2022.06

# -----------------------------------------------------------------------------
# 2) 把工具的 bin 目录加进 PATH，这样才能直接敲 vcs / verdi / urg
#    末尾的 :$PATH 保留系统原有路径，不要删。
# -----------------------------------------------------------------------------
export PATH=$VCS_HOME/bin:$VERDI_HOME/bin:$PATH

# -----------------------------------------------------------------------------
# 3) License 服务器（★请改成你公司/实验室的真实 端口@主机★）
#    格式是  端口号@服务器名或IP ，27000 是 FlexLM 默认端口。
# -----------------------------------------------------------------------------
export LM_LICENSE_FILE=27000@your_license_server
export SNPSLMD_LICENSE_FILE=$LM_LICENSE_FILE

# -----------------------------------------------------------------------------
# 4) Verdi 与 VCS 联合调试所需（FSDB 波形转储用的 PLI 动态库）
#    仿真运行时 simv 要靠 LD_LIBRARY_PATH 找到这个 .so，否则 $fsdbDumpvars 会失败。
# -----------------------------------------------------------------------------
export LD_LIBRARY_PATH=$VERDI_HOME/share/PLI/VCS/LINUX64:$LD_LIBRARY_PATH
export NOVAS_HOME=$VERDI_HOME

# -----------------------------------------------------------------------------
# 5) 自检：确认命令能找到、License 能拿到
# -----------------------------------------------------------------------------
echo "==== 环境自检 ===="
echo "VCS_HOME   = $VCS_HOME"
echo "VERDI_HOME = $VERDI_HOME"
if command -v vcs   >/dev/null 2>&1; then echo "vcs   -> $(command -v vcs)";   else echo "!! 找不到 vcs，请检查 VCS_HOME / PATH";   fi
if command -v verdi >/dev/null 2>&1; then echo "verdi -> $(command -v verdi)"; else echo "!! 找不到 verdi，请检查 VERDI_HOME / PATH"; fi
echo "=================="
