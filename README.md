# 🚀 Velox Node Engine (VX) - 极客级防弹代理中枢

[![Version: V6.6 封神版](https://img.shields.io/badge/Version-V6.6_GodTier-blue.svg)](https://github.com/pwenxiang51-wq/VX-Node-Engine)
[![Core: Sing-box](https://img.shields.io/badge/Core-Sing--box-purple.svg)](https://github.com/SagerNet/sing-box)
[![Platform: Ubuntu 22.04+](https://img.shields.io/badge/Platform-Ubuntu_22.04+-orange.svg)](https://ubuntu.com/)
[![License: MIT](https://img.shields.io/badge/License-MIT-green.svg)](https://opensource.org/licenses/MIT)

> “抛弃动辄几千行的臃肿面条代码，回归极客纯粹。用不到 2000 行的纯净 Bash，通过底层的原子操作与状态机自愈，锻造一个被拔了网线也能满血复活的代理中枢。”

👨‍💻 **Architect**: [@pwenxiang51-wq](https://github.com/pwenxiang51-wq) | 📝 **Blog**: [222382.xyz](https://222382.xyz) | 🐛 **报告 Bug**: [Issues](https://github.com/pwenxiang51-wq/VX-Node-Engine/issues)


---
💡 简介
---

Velox Node Engine (VX) 是一款专为极客打造的轻量化、全自动化代理节点部署引擎。基于最新前沿的防封锁理念，它采用全动态 JSON 构建技术与单一 Sing-box 纯净内核，彻底告别多内核冲突与系统垃圾。在主流 Linux 环境下都能实现**“一键点火、全量装载、无痕粉碎”**。

### 🛡️ 跨平台防弹兼容性认证

本引擎底层已注入极客级“双轨嗅探”与“环境隔离”逻辑，完美适配以下高阶环境：

* **🐧 主流 Linux 发行版通杀：**
    * **Ubuntu 18.04+（原生满血调优，最高优先级推荐！）**
    * Debian 9+（极致兼容，完美丝滑）
    * CentOS 7+ / AlmaLinux / Rocky Linux（智能切轨，底层包管理器与防火墙自适应）
    * *注：极度阉割版 Alpine 或无 systemd 守护进程的灵车系统可能会遭遇“降维打击”，请谨慎使用。*

* **☁️ 顶级云大厂 VPC 穿透支持：**
    * Google Cloud Platform (GCP)
    * Amazon Web Services (AWS)
    * Oracle Cloud (甲骨文云)
    * Azure / 阿里云国际 / 腾讯云国际
    * *极客亮点：引擎内置了 1:1 NAT 物理出口嗅探技术，彻底解决云大厂内网 IP 迷失的死穴。只需在云服务商的网页控制台放行对应安全组端口，即可满血复活。*

* **💻 硬件架构全量覆盖：**
    * `x86_64` (AMD/Intel 传统架构)
    * `aarch64` / `arm64` (完美发挥甲骨文等 ARM 神机架构的核动力性能，内核自动适配下载)

* **🍎 关于 macOS 的防呆警告：**
    * **不支持原生直连运行！** VX 引擎深度依赖 Linux 内核的 `systemd` 进程树与网络栈。如果您是高贵的 Mac 用户，请开个 Ubuntu 虚拟机，或者使用 Docker 进行环境隔离部署。

---


## ⚡ 核心杀手锏 (Core Architecture)

本引擎不仅是一个节点搭建工具，更是一套具备 **“感知、自愈、反制”** 能力的工业级网络架构。

### ⚛️ 10/10 满分原子量化级安全
- **零脏写防御 (`atomic_jq`)**：所有 JSON 核心配置的修改均在 `/tmp` 内存级沙箱中进行，语法校验通过后才执行原子级 `mv` 覆盖。哪怕写入时遭遇机房物理断电，配置文件也绝对不会损坏。
- **物理隔离发证机**：在执行“大满贯”并发装载时，五大神级协议（VLESS/Hys2/TUIC/VMess/Trojan）将调用底层 `openssl` 与内核 UUID 生成器，进行 100% 独立的凭证发放。彻底杜绝“克隆人”连坐风险，密码箱与门禁卡互不干涉。

### 🤖 Argo 状态机自愈与物理脱甲
- 独家研发的 **VMess-WS 动态装甲系统**。
- **挂载 Argo 隧道时**：引擎瞬间物理剥离 VMess 底层的 TLS 证书，降维至纯明文 WS 协议，无缝对接 Cloudflared 本地网关。
- **拆除 Argo 隧道时**：触发状态机自愈，引擎瞬间从 ACME 库中调取真实域名证书并重新“焊死”，原生节点原地满血复活，防弹装甲一秒重铸。

### 🕵️ TG 静默哨兵 (全息雷达)
- 将毫秒级探针作为 `systemd` 守护进程潜伏入 Ubuntu 底层 (`vx-tg-sentinel`)。
- 动态嗅探 `journalctl` 日志流，一旦侦测到新 IP 连入节点（防分享/防白嫖），瞬间将入侵者的 IP、物理归属地、运营商数据抓取，并秒推至 Telegram。您的专属机枪塔，时刻全副武装。

### 🛡️ 焦土化卸载协议
- 卸载绝不是简单的 `rm -rf`。引擎会反向解析现存 JSON 库，提取所有正在服役的监听端口，调用 `iptables`/`ufw` 执行物理封堵。随后粉碎所有守护进程、Cron 任务与证书残骸，实现真正的“寸草不生”。

---

## ⚔️ 战术部署 (Quick Start)

在你的终端执行以下神圣指令，开启终极穿透之旅 (请务必使用 **root** 用户运行)：

```bash
bash <(curl -Ls https://raw.githubusercontent.com/pwenxiang51-wq/VX-Node-Engine/main/vx.sh)
```
或者

```bash
bash <(wget -qO- https://raw.githubusercontent.com/pwenxiang51-wq/VX-Node-Engine/main/vx.sh)
```

---


> 💡 **极简召唤提示**：安装完成后，以后在任何目录只需输入 `vx` 即可瞬间唤醒交互监控大屏！

---

### 🚑 紧急救援与强制同步 (急救包)

如果你在修改源码、更新面板时遇到语法错误，导致 `vx` 命令彻底瘫痪（面板无法弹出）；或者你想**秒级强制拉取** GitHub 上的最新代码（穿透 CDN 缓存），请在 VPS 终端直接执行以下终极抢救指令：

```bash
curl -sL "https://raw.githubusercontent.com/pwenxiang51-wq/VX-Node-Engine/main/vx.sh?v=$(date +%s)" -o /usr/local/bin/vx && chmod +x /usr/local/bin/vx
```
💡 提示：执行完毕后不会有任何提示。此时重新输入 vx 回车，你的大屏面板即可满血复活！

---

⚠️ NAT 服务器用户特别提示：
如果您使用的是端口受限的 NAT 服务器，请不要使用 [6] 一键大满贯 功能（因为其采用全随机端口）。请使用菜单 [1] - [5] 独立安装，并在提示时手动输入您被分配的可用端口。或者直接使用 [e] Argo 隧道 进行无视端口的内网穿透！

---


## 🧩 协议矩阵与高阶外挂

- **“五虎将”协议矩阵**：
  - `VLESS-Reality` (最稳主力，Vision 流控)
  - `Hysteria2` (QUIC UDP 暴力加速)
  - `TUIC v5` (极致抗丢包)
  - `VMess-WS+TLS` (万能底座，随时待命献身 Argo)
  - `Trojan-Reality` (神级隐身)
- **WARP 智能优选分流**：建立本地 SOCKS5 隔离隧道，基于 Sing-box 神经元路由精准解锁 Netflix/ChatGPT。绝对不污染系统全局路由，保障 SSH 永不失联。
- **OTA 热重载引擎**：支持无感升级面板与内核。引入“先验尸，后夺舍”机制，拉取新代码后必须通过 `bash -n` 严格校验才允许覆盖本体，阻断一切因 GitHub 抽风导致的脚本自毁。





---

## ⚖️ 开源协议 & 声明

* 本项目基于 [MIT License](https://opensource.org/licenses/MIT) 开源。
* 本项目仅供网络协议底层原理研究与学术交流使用。
* 请严格遵守您所在国家和地区的法律法规，严禁将本项目用于任何非法用途，作者不对因滥用导致的任何后果负责。
* 底层核心驱动致谢：[Sing-box](https://github.com/SagerNet/sing-box) | [Cloudflare](https://cloudflare.com)

- 如果这套防弹架构为你省下了宝贵的折腾时间，请在右上角点亮 **Star ⭐️**。

**"Talk is cheap. Show me the code."**
