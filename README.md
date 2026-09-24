# 基于 Shell 与 APT 的大数据开发环境自动化部署工具

给新服务器做初始化的几个脚本，Ubuntu 上用的。

以前每拿到一台新机器，都要手动来一遍：换镜像源、装 JDK 和 Python、配 VS Code。步骤就那几步，但每次顺序和细节都不太一样，隔一段时间自己都记不清上次是怎么配的。后来干脆写成脚本，跑一遍就完事，换机器的时候也不用再翻笔记。

主脚本 `deploy.sh` 按顺序调三个子脚本：

1. `env_scripts/mirrors_set.sh` —— 把软件源换成清华的。改 `/etc/apt/sources.list` 之前会先复制一份备份，万一手滑还能改回来。
2. `env_scripts/version_lock.sh` —— 装 JDK 11 和 Python 3.10，装完用 `apt-mark hold` 把版本锁住，顺便把 pip 也换成清华源，不然装依赖太慢。
3. `env_scripts/vscode_link.sh` —— 在当前项目目录下生成 `.vscode/settings.json`，写上 Python 解释器路径、保存时自动格式化这些配置。

主脚本调每个子脚本之前会先看文件在不在，不在就报错退出，省得少做一步还傻傻往下跑。

## 关于锁版本

这一步是我特意加的。JDK 和 Python 被系统自动升级到新版本之后，原来能跑的代码有时候就直接报错了，排查起来还挺费劲。`apt-mark hold` 是系统自带的锁版本命令，锁上以后自动升级会跳过它们，哪天想升级再手动解锁就行。

## local 和 prod 两种模式

`deploy.sh` 开头有个 `RUN_ENV`，控制脚本是真执行还是只打印：

- `local`（默认值）：不执行真实命令，只把"我打算做什么"打出来。我平时在 Windows 上就是这么验证脚本逻辑的，不可能为了改一行脚本专门开台服务器。
- `prod`：真执行。要用 `sudo`，必须在真的 Ubuntu 机器上跑。

现在的流程是先在 local 下跑一遍看输出对不对，确认没问题再改成 prod 上服务器。

## 怎么用

```bash
git clone 下来，或者直接把文件夹拷到服务器上

# 先看看会做什么
vim deploy.sh          # 确认 RUN_ENV="local"
bash deploy.sh

# 没问题了再改成 prod 真跑
```

## 目录

```
deploy.sh                    # 主脚本，按顺序调下面三个
env_scripts/
├── mirrors_set.sh           # 换镜像源
├── version_lock.sh          # 装组件、锁版本、配 pip 源
└── vscode_link.sh           # 生成 VS Code 配置
```

## 几个没做好的地方

写的时候就图自己用着方便，有些地方没做扎实：

- prod 模式必须有 sudo，而且是真的会动系统配置（装包、改 sources.list），不是随便能试的
- 换源那步是用 `sed` 直接替换官方源地址，如果你的机器上本来就不是默认的 Ubuntu 源，替换可能没效果
- 只支持 apt 系的系统，CentOS 之类的用不了
- 没做重复执行的保护，反复跑会重复装包、重复写配置。正常也就新机器跑一次，所以一直没改
