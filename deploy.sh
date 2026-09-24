#!/bin/bash

# ==========================================
# LightOps-Deployer 主控脚本
# ==========================================

# 运行环境配置：local (本地Windows模拟测试) / prod (真正的Ubuntu服务器)
RUN_ENV="local"

# 获取当前脚本绝对路径
BASE_DIR="$(cd "$(dirname "$0")" && pwd)"

echo "=================================================="
echo "🚀 LightOps-Deployer 自动化部署工具启动"
echo "=================================================="

# 1. 执行镜像源切换
if [ -f "${BASE_DIR}/env_scripts/mirrors_set.sh" ]; then
    echo "【Step 1/3】正在配置高速镜像源..."
    # 将 RUN_ENV 作为参数传给子脚本
    bash "${BASE_DIR}/env_scripts/mirrors_set.sh" "$RUN_ENV"
else
    echo "[Error] 未找到 mirrors_set.sh" && exit 1
fi

# 2. 执行核心组件版本锁定
if [ -f "${BASE_DIR}/env_scripts/version_lock.sh" ]; then
    echo -e "\n【Step 2/3】正在安装并锁定核心组件版本..."
    bash "${BASE_DIR}/env_scripts/version_lock.sh" "$RUN_ENV"
else
    echo "[Error] 未找到 version_lock.sh" && exit 1
fi

# 3. 执行 VS Code 链路配置
if [ -f "${BASE_DIR}/env_scripts/vscode_link.sh" ]; then
    echo -e "\n【Step 3/3】正在打通 VS Code 编辑器配置链路..."
    bash "${BASE_DIR}/env_scripts/vscode_link.sh" "$RUN_ENV" "$BASE_DIR"
else
    echo "[Error] 未找到 vscode_link.sh" && exit 1
fi

echo -e "\n=================================================="
echo "🎉 全链路自动化部署完成！环境已达标准生产状态。"
echo "=================================================="