#!/bin/bash
# Auto-Company 限流包装脚本
# 功能：每3个产品后暂停5小时

PROJECT_DIR="/mnt/c/Users/17503/Auto-Company"
PRODUCTS_DIR="$PROJECT_DIR/projects"
LOG_FILE="$PROJECT_DIR/logs/throttle.log"

# 初始化
PRODUCTS_COUNT=0
MAX_PRODUCTS=3
COOLDOWN_HOURS=5

log() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $1" | tee -a "$LOG_FILE"
}

count_html_products() {
    find "$PRODUCTS_DIR" -name "*.html" -type f | wc -l
}

# 主循环
while true; do
    # 检查当前产品数量
    CURRENT_PRODUCTS=$(count_html_products)
    NEW_PRODUCTS=$((CURRENT_PRODUCTS - PRODUCTS_COUNT))
    
    log "当前产品: $CURRENT_PRODUCTS | 本次新增: $NEW_PRODUCTS | 上次计数: $PRODUCTS_COUNT"
    
    # 如果新增了3个或更多产品，暂停5小时
    if [ $NEW_PRODUCTS -ge $MAX_PRODUCTS ]; then
        log "✅ 已完成 $NEW_PRODUCTS 个产品，开始冷却期（$COOLDOWN_HOURS 小时）..."
        
        # 暂停 auto-loop
        if [ -f "$PROJECT_DIR/.auto-loop.pid" ]; then
            PID=$(cat "$PROJECT_DIR/.auto-loop.pid")
            kill $PID 2>/dev/null || true
            log "已暂停 Auto-Company (PID: $PID)"
        fi
        
        # 等待5小时
        COOLDOWN_SECONDS=$((COOLDOWN_HOURS * 3600))
        log "等待 $COOLDOWN_HOURS 小时后继续..."
        sleep $COOLDOWN_SECONDS
        
        # 重新启动
        log "冷却期结束，重新启动 Auto-Company..."
        PRODUCTS_COUNT=$(count_html_products)
        
        cd "$PROJECT_DIR"
        rm -f .auto-loop.pid .auto-loop-stop
        su - autoagent -c "cd $PROJECT_DIR && export LOOP_INTERVAL=600 && nohup bash scripts/core/auto-loop.sh > /tmp/auto-loop.log 2>&1 &"
        sleep 5
        log "Auto-Company 已重启 (PID: $(cat $PROJECT_DIR/.auto-loop.pid))"
    fi
    
    # 每小时检查一次
    sleep 3600
done
