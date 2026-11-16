#!/usr/bin/env bash
# 在鸿蒙模拟器上运行 nim-uts-sdk-demo（未签名 HAP 方案）。
#
# 背景：
#   HBuilderX 的鸿蒙运行流程在最后一步会调用 hvigor 的 SignHap，
#   当前 manifest.json 里没有可用的签名证书，所以会报
#   “签名证书资料配置错误 / Invalid storeFile value”。
#   但鸿蒙模拟器接受未签名 HAP，因此本脚本：
#     1. 调用 HBuilderX CLI 只做编译（--compile true）；
#     2. 取编译产物 entry-default-unsigned.hap；
#     3. 用 hdc 安装并通过 aa start 启动。
#
# 用法：
#   ./scripts/run-harmony-unsigned.sh [deviceId]
#   CLEAN=true ./scripts/run-harmony-unsigned.sh   # 清理缓存后重新编译
#
# 默认设备：127.0.0.1:5555（模拟器）
set -euo pipefail

PROJECT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
DEVICE="${1:-${DEVICE:-127.0.0.1:5555}}"
HX_CLI="${HX_CLI:-/Applications/HBuilderX.app/Contents/MacOS/cli}"
HDC="${HDC:-/Applications/DevEco-Studio.app/Contents/sdk/default/openharmony/toolchains/hdc}"
CLEAN="${CLEAN:-false}"

if [[ ! -x "$HX_CLI" ]]; then
  echo "找不到 HBuilderX CLI: $HX_CLI" >&2
  exit 1
fi
if [[ ! -x "$HDC" ]]; then
  echo "找不到 hdc: $HDC" >&2
  exit 1
fi

# 读取 vapor 开关和 bundleName
read -r VAPOR BUNDLE < <(python3 - "$PROJECT/manifest.json" <<'PY'
import json, sys
m = json.load(open(sys.argv[1], encoding='utf-8'))
vapor = bool(m.get('uni-app-x', {}).get('vapor', False))
bundle = m.get('app-harmony', {}).get('distribute', {}).get('bundleName', '')
print(('true' if vapor else 'false') + ' ' + bundle)
PY
)
if [[ -z "${BUNDLE:-}" ]]; then
  echo "manifest.json 中缺少 app-harmony.distribute.bundleName" >&2
  exit 1
fi

echo "==> 项目: $PROJECT"
echo "==> 设备: $DEVICE"
echo "==> 模式: $([[ "$VAPOR" == "true" ]] && echo '蒸汽模式 (vapor)' || echo 'VDOM 模式')"
echo "==> bundleName: $BUNDLE"
echo "==> 编译缓存清理: $CLEAN"

# 确保项目已在 HBuilderX 中打开（重复 open 是幂等的）
"$HX_CLI" project open --path "$PROJECT" >/dev/null 2>&1 || true

LOG="/tmp/nim-uts-sdk-demo-harmony-$(date +%H%M%S).log"
START_TS="$(date +%s)"
ARGS=(launch app-harmony --project "$PROJECT" --deviceId "$DEVICE" --compile true --cleanCache "$CLEAN")
if [[ "$VAPOR" == "true" ]]; then
  ARGS+=(--vaporRenderTarget bytecode)
fi

echo "==> 开始编译（日志: ${LOG}）"
# 编译成功后 HBuilderX 仍会因签名失败而返回非 0/打印错误；这里不中断，
# 后续直接使用它已经生成的 unsigned HAP。
"$HX_CLI" "${ARGS[@]}" 2>&1 | tee "$LOG" || true

HAP="$PROJECT/unpackage/dist/dev/app-harmony/entry/build/default/outputs/default/entry-default-unsigned.hap"
if [[ ! -f "$HAP" ]]; then
  echo "未找到 unsigned HAP: $HAP" >&2
  echo "请检查编译日志: $LOG" >&2
  tail -n 30 "$LOG" >&2 || true
  exit 1
fi

# 防止误装上一次的旧产物
HAP_TS="$(stat -f %m "$HAP")"
if (( HAP_TS < START_TS - 10 )); then
  echo "unsigned HAP 不是本次编译产物（可能是旧文件），请检查日志: $LOG" >&2
  tail -n 30 "$LOG" >&2 || true
  exit 1
fi

echo "==> 安装: $HAP"
"$HDC" -t "$DEVICE" install "$HAP"

echo "==> 启动: $BUNDLE/EntryAbility"
"$HDC" -t "$DEVICE" shell aa start -a EntryAbility -b "$BUNDLE"
sleep 3

PID="$("$HDC" -t "$DEVICE" shell pidof "$BUNDLE" 2>/dev/null | tr -d '\r' | head -n 1 || true)"
if [[ -n "$PID" ]]; then
  echo "==> 运行中，pid=$PID"
else
  echo "==> 启动命令已执行，但未查询到进程；请查看模拟器画面或 hilog。" >&2
fi
