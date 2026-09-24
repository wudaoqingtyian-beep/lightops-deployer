#!/bin/bash
RUN_ENV=$1

if [ "$RUN_ENV" = "prod" ]; then
    echo "[Prod] 检测到 Ubuntu 环境，正在备份原 sources.list..."
    # 工业级规范：修改核心配置前必先备份
    sudo cp /etc/apt/sources.list /etc/apt/sources.list.bak
    
    echo "[Prod] 正在一键替换为清华大学 APT 高速镜像源..."
    # 利用 cat << 'EOF' 强行覆盖写入国内源（大模型数据传输极大提速）
    sudo sed -i 's/archive.ubuntu.com/mirrors.tuna.tsinghua.edu.cn/g' /etc/apt/sources.list
    sudo sed -i 's/security.ubuntu.com/mirrors.tuna.tsinghua.edu.cn/g' /etc/apt/sources.list
    
    echo "[Prod] 正在更新系统软件源索引..."
    sudo apt-get update -y
else
    # 本地沙盒模拟
    echo "[Local] (本地模拟) 成功备份 /etc/apt/sources.list"
    echo "[Local] (本地模拟) 成功将 Ubuntu 官方源一键切换为 [清华大学TUNA高速镜像源]"
fi