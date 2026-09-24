#!/bin/bash
RUN_ENV=$1

# 预设大数据实验标准版本：Java 11 和 Python 3.10
TARGET_JAVA_VER="11"
TARGET_PY_VER="3.10"

if [ "$RUN_ENV" = "prod" ]; then
    echo "[Prod] 正在安装标准开发组件..."
    sudo apt-get install -y openjdk-${TARGET_JAVA_VER}-jdk python${TARGET_PY_VER}
    
    echo "[Prod] 【核心操作】正在执行版本锁定，防止系统自动升级引发大模型代码崩溃..."
    # apt-mark hold 是 Debian/Ubuntu 的高级运维指令，锁死当前版本不被更新
    sudo apt-mark hold openjdk-${TARGET_JAVA_VER}-jdk python${TARGET_PY_VER}
    
    # 配置 Python 的 pip 镜像源（满足 BERT/SAKT 模型下载依赖的需求）
    mkdir -p ~/.pip
    cat << EOF > ~/.pip/pip.conf
[global]
index-url = https://pypi.tuna.tsinghua.edu.cn/simple
EOF
    echo "[Prod] Python pip 镜像源已同步配置完毕。"
else
    # 本地沙盒模拟
    echo "[Local] (本地模拟) 执行命令: apt-get install openjdk-${TARGET_JAVA_VER}-jdk python${TARGET_PY_VER}"
    echo "[Local] (本地模拟) 执行核心锁版本指令: apt-mark hold，成功锁定 JDK ${TARGET_JAVA_VER} 与 Python ${TARGET_PY_VER}"
    echo "[Local] (本地模拟) 成功配置 ~/.pip/pip.conf 国内加速通道"
fi