# 基于 Shell 与 APT 的大数据开发环境自动化部署工具

新拿到一台 Ubuntu 服务器，通常要手动做一堆初始化：换镜像源、装 JDK 和 Python、配编辑器。步骤多、容易漏，每台机器做得还不太一样。

这个工具把这些步骤写成 Shell 脚本，跑一条命令全部做完，让每台机器的环境保持一致。

## 它做了哪三件事

按顺序执行三个脚本：

| 步骤 | 脚本 | 做什么 |
|---|---|---|
| 1 | `env_scripts/mirrors_set.sh` | 把系统软件源换成清华镜像（下载更快），换之前先备份原文件 |
| 2 | `env_scripts/version_lock.sh` | 安装 JDK 11 和 Python 3.10，然后**锁住版本**不让系统自动升级；同时配好 pip 国内源 |
| 3 | `env_scripts/vscode_link.sh` | 生成 `.vscode/settings.json`，指定 Python 路径、保存时自动格式化、绑定代码检查工具 |

主脚本 `deploy.sh` 在调用每个子脚本前会先检查文件是否存在，缺文件就报错退出，不会少做一步还继续往下跑。

## 为什么要锁版本

JDK 和 Python 这类基础组件，如果被系统自动升级到新版本，项目里原本能跑的代码可能直接报错。`apt-mark hold` 是系统自带的"锁版本"命令，锁上之后自动升级会跳过它们，需要升级时手动解锁即可。

## 两种运行模式

脚本里的 `RUN_ENV` 参数决定用哪种模式：

- **local**（默认）：本地模拟模式。不执行真实命令，只打印"我打算做什么"，用来在 Windows 上验证脚本逻辑是否通顺
- **prod**：真实执行。会用到 `sudo`，需要在真正的 Ubuntu 服务器上跑

## 使用方法

```bash
# 1. 把脚本放到服务器上（或 git clone 下来）
# 2. 按需修改 deploy.sh 里的 RUN_ENV
#    RUN_ENV="local"   本地模拟，先看看会做什么
#    RUN_ENV="prod"    真实执行

bash deploy.sh
```

先跑一次 local 模式确认输出符合预期，再改成 prod 在服务器上执行，是个比较稳妥的顺序。

## 目录结构

```
lightops-deployer/
├── deploy.sh                    # 主脚本，按顺序调用下面三个
└── env_scripts/
    ├── mirrors_set.sh           # 换镜像源（先备份再改）
    ├── version_lock.sh          # 装组件 + 锁版本 + 配 pip 源
    └── vscode_link.sh           # 生成 VS Code 配置
```

## 注意事项

- prod 模式需要 sudo 权限，会修改系统配置（sources.list、安装软件包）
- 换源脚本按 `sed` 替换官方源地址，如果你的系统用的不是默认的 Ubuntu 源，替换可能不生效
- 只针对 Ubuntu/Debian 系（用 apt），CentOS 等系统不适用
- 脚本没有做"重复执行"的幂等处理，反复跑会重复安装和重复写入配置
