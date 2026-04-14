# 🚀 Velox Node Engine (VX) - 极客级防弹代理中枢

[![Version: V6.6 封神版](https://img.shields.io/badge/Version-V6.6_GodTier-blue.svg)](https://github.com/pwenxiang51-wq/VX-Node-Engine)
[![Core: Sing-box](https://img.shields.io/badge/Core-Sing--box-purple.svg)](https://github.com/SagerNet/sing-box)
[![Platform: Ubuntu 22.04+](https://img.shields.io/badge/Platform-Ubuntu_22.04+-orange.svg)](https://ubuntu.com/)
[![License: MIT](https://img.shields.io/badge/License-MIT-green.svg)](https://opensource.org/licenses/MIT)

> “不要在屎山代码上缝缝补补。用不到 1000 行的纯净 Bash，通过底层的原子操作与状态机自愈，锻造一个被拔了网线也能满血复活的代理中枢。”

👨‍💻 **Architect**: [@pwenxiang51-wq](https://github.com/pwenxiang51-wq) | 📝 **Blog**: [222382.xyz](https://222382.xyz)

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

默认最高兼容 **Ubuntu 22.04+**。在 `root` 权限下执行以下指令，瞬间点火装载：

```bash
bash <(curl -Ls [https://raw.githubusercontent.com/pwenxiang51-wq/VX-Node-Engine/main/vx.sh](https://raw.githubusercontent.com/pwenxiang51-wq/VX-Node-Engine/main/vx.sh))
```

> 💡 **极客提示**：点火完成后，随时在终端敲击 `vx` 即可唤醒全息交互大屏。

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

## 🚑 紧急抢救令 (Emergency Override)

如果你在魔改源码时遭遇 `NBSP` 不可见空格污染，或是需要强行无视 CDN 缓存拉取云端最新架构，请祭出这行基因净化指令：

```bash
curl -sL "[https://raw.githubusercontent.com/pwenxiang51-wq/VX-Node-Engine/main/vx.sh?v=$(date](https://raw.githubusercontent.com/pwenxiang51-wq/VX-Node-Engine/main/vx.sh?v=$(date) +%s)" -o /tmp/vx.sh && sed -i 's/\xC2\xA0/ /g' /tmp/vx.sh && mv -f /tmp/vx.sh /usr/local/bin/vx && chmod +x /usr/local/bin/vx
```

---

## ⚖️ 极客致敬 & 声明

- 本项目基于 MIT 协议开源，底层核心由优秀的 [Sing-box](https://github.com/SagerNet/sing-box) 提供核动力支撑。
- 代码仅供 Linux 底层网络路由研究与自动化运维学术交流，严禁用于非法用途。
- 如果这套防弹架构为你省下了宝贵的折腾时间，请在右上角点亮 **Star ⭐️**。

**"Talk is cheap. Show me the code."**
