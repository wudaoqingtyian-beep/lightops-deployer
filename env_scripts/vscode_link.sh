#!/bin/bash
RUN_ENV=$1
PROJECT_ROOT=$2

# 无论在本地还是生产，我们都直接在当前项目目录下生成一个标准的 .vscode 配置
echo "正在为当前项目注入 VS Code 自动化开发链路..."

# 1. 创建 .vscode 隐藏文件夹
mkdir -p "${PROJECT_ROOT}/.vscode"

# 2. 动态写入 settings.json
# 亮点：自动指定 Python 解释器路径、开启保存时自动格式化、绑定代码 Linter
cat << EOF > "${PROJECT_ROOT}/.vscode/settings.json"
{
    "python.defaultInterpreterPath": "/usr/bin/python3.10",
    "editor.formatOnSave": true,
    "editor.defaultFormatter": "ms-python.black-formatter",
    "python.analysis.typeCheckingMode": "basic",
    "files.exclude": {
        "**/.git": true,
        "**/__pycache__": true
    }
}
EOF

if [ "$RUN_ENV" = "prod" ]; then
    echo "[Prod] VS Code 全链路环境已打通。开发者通过 Remote-SSH 连接后即可享用标准编译链路。"
else
    echo "[Local] (本地模拟) 成功在当前目录生成 .vscode/settings.json 配置文件！"
fi