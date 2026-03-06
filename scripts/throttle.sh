#!/bin/bash
# 工具箱限流脚本
# 每6个产品后暂停3小时

set -euo pipefail

PROJECT_DIR="/mnt/c/Users/17503/toolbox"
TOOLS_DIR="$PROJECT_DIR/tools"
LOG_FILE="$PROJECT_DIR/logs/throttle.log"

MAX_PRODUCTS=6
COOLDOWN_HOURS=3

log() {
  echo "[$(date '+%Y-%m-%d %H:%M:%S')] $1" | tee -a "$LOG_FILE"
}

count_tools() {
  find "$TOOLS_DIR" -name "*.html" -type f 2>/dev/null | wc -l
}

# 创建日志目录
mkdir -p "$(dirname "$LOG_FILE")"

# 初始工具数
INITIAL_COUNT=$(count_tools)
log "🚀 启动限流监控 | 初始工具数: $INITIAL_COUNT"

# 启动 auto-loop
cd "$PROJECT_DIR"
rm -f .auto-loop.pid .auto-loop-stop
nohup bash scripts/core/auto-loop.sh > /tmp/toolbox-auto-loop.log 2>&1 &
sleep 5
log "✅ 工具箱已启动 (PID: $(cat .auto-loop.pid 2>/dev/null || echo 'unknown'))"

# 监控循环
while true; do
  sleep 3600  # 每小时检查一次
  
  CURRENT_COUNT=$(count_tools)
  NEW_PRODUCTS=$((CURRENT_COUNT - INITIAL_COUNT))
  
  log "📊 当前: $CURRENT_COUNT | 新增: $NEW_PRODUCTS"
  
  if [ $NEW_PRODUCTS -ge $MAX_PRODUCTS ]; then
    log "🛑 已完成 $NEW_PRODUCTS 个产品，暂停 $COOLDOWN_HOURS 小时..."
    
    # 停止 auto-loop
    pkill -f 'auto-loop.sh' || true
    sleep 2
    
    # 冷却
    sleep $((COOLDOWN_HOURS * 3600))
    
    # 重启
    log "🔄 冷却结束，重新启动..."
    INITIAL_COUNT=$(count_tools)
    cd "$PROJECT_DIR"
    rm -f .auto-loop.pid .auto-loop-stop
    nohup bash scripts/core/auto-loop.sh > /tmp/toolbox-auto-loop.log 2>&1 &
    sleep 5
    log "✅ 工具箱已重启 (PID: $(cat .auto-loop.pid 2>/dev/null || echo 'unknown'))"
  fi
done
