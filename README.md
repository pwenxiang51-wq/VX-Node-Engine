# 🚀 Velox Node Engine (VX) - 极速节点构建引擎 (V5.3 究极完全体)

[![Version: V5.3](https://img.shields.io/badge/Version-V5.3-blue.svg)](https://github.com/pwenxiang51-wq/VX-Node-Engine)
[![Core: Sing-box](https://img.shields.io/badge/Core-Sing--box-purple.svg)](https://github.com/SagerNet/sing-box)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
[![Language: Bash](https://img.shields.io/badge/Language-Bash-green.svg)](https://www.gnu.org/software/bash/)
[![Platform: Debian | Ubuntu | CentOS](https://img.shields.io/badge/Platform-Debian%20|%20Ubuntu%20|%20CentOS-lightgrey.svg)](https://www.kernel.org/)

> “抛弃动辄几千行的臃肿面条代码，回归极客纯粹。秉持‘胖客户端，瘦服务端’的哲学，只用不到千行的优雅架构，锻造最无解的防封节点。”

👨‍💻 **作者 GitHub**: [@pwenxiang51-wq](https://github.com/pwenxiang51-wq) | 📝 **官方博客**: [222382.xyz](https://222382.xyz) | 🐛 **报告 Bug**: [Issues](https://github.com/pwenxiang51-wq/VX-Node-Engine/issues)

---

## 📸 终端视觉大屏

*(极致极客美学的交互体验，毫秒级无感唤醒，全节点状态一目了然)*

![VX Dashboard](assets/screenshot.png)

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

## ✨ V5.3究极进化亮点
* 🛡️ **Argo 双轨引擎重构**：完美打通 Cloudflare Zero Trust 固定隧道，支持企业级内网穿透保活。
* 👻 **幽灵节点粉碎技术**：手写底层 Base64 智能解密安检，彻底消灭历史残留死链。
* 🧠 **智能域名嗅探**：临时隧道采用 `tail` 级动态抓取，永远只提取最新鲜的存活域名。

---

## 🔥 核心杀手锏

### ⚔️ “五虎神将”大满贯协议
* **VLESS-Reality**：Vision 流控，白嫖大厂域名的隐身王者。
* **Hysteria-2**：基于 UDP 协议的暴力加速，无视晚高峰网络拥塞。
* **TUIC v5**：现代 QUIC 架构，极致抗丢包。
* **VMess-WS**：纯净直连底座，专为接入 CDN 与 Argo 预留 (监听 `0.0.0.0` 全通透架构)。
* **Trojan-Reality**：传统神级协议的 Reality 究极进化版。
* *支持独立部署，更支持一键“大满贯”全量并发装载！*

### 🛡️ WARP 智能优选解锁
内置应用层 SOCKS5 分流级 WARP 挂载。精准解锁 Netflix, Disney+, ChatGPT, Claude 等流媒体与 AI 限制。**绝对不修改系统全局路由，确保 SSH 永不失联！**

### ☁️ Argo 隧道防封复活甲
当 VPS IP 惨遭 GFW 阻断？一键挂载 Cloudflare Argo 隧道。支持 **临时穿透模式** (小白免配，智能抓取域名) 与 **Zero Trust 固定 Token 模式** (极客专属，自有域名保活)，无需公网 IP 依然满血在线。

### 🔄 无感 OTA 双轨热更新
面板内置极速 1.5s 架构自适应探测。只需在面板输入 `i`，即可一键全自动同步 GitHub 最新面板代码，并智能升级 Sing-box 核心至最新版 (自动适配 AMD/ARM 架构)。

### ⚡ 原子级底层调优
* 智能嗅探 IPv4/IPv6 双栈网络。
* 自动申请/续签 ACME 真实域名证书 (智能降级量子自签保护)。
* 一键注入 BBR 底层拥塞控制狂暴加速。
* **无痕绝杀**：一键彻底卸载，不留任何守护进程与系统垃圾。

---


## 🛠️ 召唤指令 (一键极速部署)

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
🧬 焦土化清理指令 (防 NBSP 报错)
若从网页复制执行报错，请祭出这行基因净化指令，物理超度所有幽灵空格：

```bash
sed -i 's/\xC2\xA0/ /g' /usr/local/bin/vx
```

---

⚠️ NAT 服务器用户特别提示：
如果您使用的是端口受限的 NAT 服务器，请不要使用 [6] 一键大满贯 功能（因为其采用全随机端口）。请使用菜单 [1] - [5] 独立安装，并在提示时手动输入您被分配的可用端口。或者直接使用 [e] Argo 隧道 进行无视端口的内网穿透！

---

## ☕ 赞赏与支持

开源不易，如果 Velox 面板让你的折腾之旅变得更加优雅，为你节省了宝贵的时间，请务必在右上角给我点一个 **Star ⭐️**！你的点赞是我持续维护的唯一动力。

如果大佬觉得项目超赞，欢迎通过微信扫码请我喝杯冰美式，感激不尽！🚀

<div align="center">
  <img src="assets/donate.png" width="300" />
</div>

---

## ⚖️ 开源协议 & 声明

* 本项目基于 [MIT License](https://opensource.org/licenses/MIT) 开源。
* 本项目仅供网络协议底层原理研究与学术交流使用。
* 请严格遵守您所在国家和地区的法律法规，严禁将本项目用于任何非法用途，作者不对因滥用导致的任何后果负责。
* 底层核心驱动致谢：[Sing-box](https://github.com/SagerNet/sing-box) | [Cloudflare](https://cloudflare.com)
