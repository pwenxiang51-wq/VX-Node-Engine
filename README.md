# 🚀 Velox (VX) - Geek-Tier Bulletproof [Atomic-Level Encrypted Communication] Tunnel Engine

[![Version: V6.6 封神版](https://img.shields.io/badge/Version-V6.6_GodTier-blue.svg)](https://github.com/pwenxiang51-wq/VX-Node-Engine)
[![Core: Sing-box](https://img.shields.io/badge/Core-Sing--box-purple.svg)](https://github.com/SagerNet/sing-box)
[![Platform: Ubuntu 22.04+](https://img.shields.io/badge/Platform-Ubuntu_22.04+-orange.svg)](https://ubuntu.com/)
[![License: MIT](https://img.shields.io/badge/License-MIT-green.svg)](https://opensource.org/licenses/MIT)

> "Abandon the bloated, thousand-line spaghetti code and return to geek purity. Forged with less than 2000 lines of pure Bash, utilizing low-level atomic operations and state machine self-healing, we've forged a proxy hub that resurrects with full health even if the network cable is physically pulled."

👨‍💻 **Architect**: [@pwenxiang51-wq](https://github.com/pwenxiang51-wq) | 📝 **Blog**: [222382.xyz](https://222382.xyz) | 🐛 **Report Bugs**: [Issues](https://github.com/pwenxiang51-wq/VX-Node-Engine/issues)


---
💡 Introduction
---

Velox Node Engine (VX) is a lightweight, fully automated proxy node deployment engine built specifically for geeks. Based on cutting-edge anti-blocking concepts, it utilizes fully dynamic JSON build technology and a single, pure Sing-box core, completely eliminating multi-core conflicts and system garbage. Across all mainstream Linux environments, it achieves **"One-click ignition, full-payload mounting, and traceless shredding."**

### 🛡️ Cross-Platform Bulletproof Compatibility Certification

The core of this engine is injected with geek-level "dual-track sniffing" and "environment isolation" logic, perfectly adapting to the following high-tier environments:

* **🐧 Mainstream Linux Distributions:**
    * **Ubuntu 18.04+ (Native full-blood tuning, highest priority recommended!)**
    * Debian 9+ (Ultimate compatibility, flawlessly smooth)
    * CentOS 7+ / AlmaLinux / Rocky Linux (Smart switching, adaptive low-level package managers and firewalls)
    * *Note: Severely castrated Alpine or ghost systems without `systemd` daemons may suffer a "dimensional strike." Use with caution.*

* **☁️ Top-Tier Cloud VPC Penetration Support:**
    * Google Cloud Platform (GCP)
    * Amazon Web Services (AWS)
    * Oracle Cloud
    * Azure / Alibaba Cloud Int. / Tencent Cloud Int.
    * *Geek Highlight: The engine has built-in 1:1 NAT physical egress sniffing technology, completely solving the fatal flaw of lost internal IPs in massive cloud provider networks. Simply allow the corresponding security group ports in the cloud provider's web console, and you will resurrect with full health.*

* **💻 Full Hardware Architecture Coverage:**
    * `x86_64` (Traditional AMD/Intel architecture)
    * `aarch64` / `arm64` (Perfectly unleashing the nuclear-powered performance of ARM god-tier machines like Oracle, with automatic core adaptation and downloading)

* **🍎 Anti-Fool Warning for macOS:**
    * **Native direct execution is NOT supported!** The VX engine deeply relies on the Linux kernel's `systemd` process tree and network stack. If you are a noble Mac user, please spin up an Ubuntu virtual machine or use Docker for isolated deployment.

---


## ⚡ Core Architecture

This engine is not just a node building tool, but an industrial-grade network architecture equipped with **"Perception, Self-Healing, and Countermeasure"** capabilities.

### ⚛️ 10/10 Perfect Score Atomic-Level Security
- **Zero-Dirty-Write Defense (`atomic_jq`)**: All core JSON configuration modifications are performed in a `/tmp` memory-level sandbox. Only after passing syntax validation are they executed via atomic `mv` overwriting. Even in the event of a physical power outage in the server room during a write operation, the configuration files will absolutely not be corrupted.
- **Physically Isolated Certificate Issuer**: When executing a "Grand Slam" concurrent payload mount, the five god-tier protocols (VLESS/Hys2/TUIC/VMess/Trojan) will call the low-level `openssl` and kernel UUID generator to issue 100% independent credentials. This completely eliminates the risk of "clone" guilt by association; password vaults and access cards do not interfere with each other.

### 🤖 Argo State Machine Self-Healing & Physical Armor Stripping
- Exclusively developed **VMess-WS Dynamic Armor System**.
- **When mounting an Argo tunnel**: The engine instantly physically strips the underlying TLS certificate from VMess, downgrading to a pure plaintext WS protocol to seamlessly dock with the Cloudflared local gateway.
- **When dismantling an Argo tunnel**: Triggers state machine self-healing. The engine instantly retrieves the real domain certificate from the ACME vault and "welds" it back on. The native node resurrects on the spot, and the bulletproof armor is recast in one second.

### 🕵️ TG Silent Sentinel (Holographic Radar)
- Embeds a millisecond-level probe into the Ubuntu low-level system as a `systemd` daemon (`vx-tg-sentinel`).
- Dynamically sniffs the `journalctl` log stream. Once a new IP is detected connecting to the node (anti-sharing/anti-leeching), it instantly captures the invader's IP, physical geolocation, and ISP data, pushing it to Telegram in milliseconds. Your exclusive automated turret, fully armed at all times.

### 🛡️ Scorched-Earth Uninstallation Protocol
- Uninstallation is never a simple `rm -rf`. The engine reverse-parses the existing JSON database, extracts all active listening ports, and calls `iptables`/`ufw` to execute physical blocking. It then shreds all daemons, Cron tasks, and certificate wreckage, achieving true "scorched earth."

---

## ⚔️ Tactical Deployment (Quick Start)

Execute the following sacred command in your terminal to begin the ultimate penetration journey (Please ensure you run this as the **root** user):

```bash
bash <(curl -Ls https://raw.githubusercontent.com/pwenxiang51-wq/VX-Node-Engine/main/vx.sh)
```
or

```bash
bash <(wget -qO- https://raw.githubusercontent.com/pwenxiang51-wq/VX-Node-Engine/main/vx.sh)
```

---


> 💡 **Minimalist Summoning Tip**: After installation, simply type `vx` in any directory to instantly summon the interactive monitoring dashboard!

---

### 🚑 Emergency Rescue & Forced Sync (Medkit)

If you encounter syntax errors while modifying the source code or updating the panel, causing the `vx` command to completely paralyze (the panel fails to pop up); or if you want to **forcefully pull** the latest code from GitHub in seconds (penetrating CDN caches), execute the following ultimate rescue command directly in your VPS terminal:

```bash
curl -sL "https://raw.githubusercontent.com/pwenxiang51-wq/VX-Node-Engine/main/vx.sh?v=$(date +%s)" -o /usr/local/bin/vx && chmod +x /usr/local/bin/vx
```
💡 Tip: There will be no prompt upon completion. Simply type `vx` again and press Enter, and your dashboard will be resurrected with full health!

---

⚠️ Special Notice for NAT Server Users:
If you are using a port-restricted NAT server, do NOT use the [6] Grand Slam (One-Click All) function (as it utilizes fully randomized ports). Please use menus [1] - [5] for independent installation and manually input your allocated available port when prompted. Alternatively, directly use [e] Argo Tunnel for internal network penetration, ignoring port restrictions entirely!

---


## 🧩 Protocol Matrix & High-Tier Plugins

- **"Five Tiger Generals" Protocol Matrix**:
  - `VLESS-Reality` (Most stable main force, Vision flow control)
  - `Hysteria2` (QUIC UDP brutal acceleration)
  - `TUIC v5` (Ultimate anti-packet loss)
  - `VMess-WS+TLS` (Universal base, always on standby to sacrifice for Argo)
  - `Trojan-Reality` (God-tier stealth)
- **WARP Smart Routing & Unlocking**: Establishes a local SOCKS5 isolated tunnel, precisely unlocking Netflix/ChatGPT based on Sing-box neural routing. It absolutely does not pollute the system's global routing, guaranteeing SSH will never lose connection.
- **OTA Hot Reload Engine**: Supports seamless upgrades of the panel and core. Introduces the "autopsy first, possess later" mechanism; after pulling new code, it must pass a strict `bash -n` validation before being allowed to overwrite the main body, blocking any script self-destruction caused by GitHub network spasms.

---

## ⚖️ Open Source License & Disclaimer

* This project is open-sourced under the [MIT License](https://opensource.org/licenses/MIT).
* This project is solely for the study and academic exchange of low-level network protocol principles.
* Please strictly comply with the laws and regulations of your country and region. It is strictly forbidden to use this project for any illegal purposes. The author is not responsible for any consequences arising from abuse.
* Low-level core driver acknowledgments: [Sing-box](https://github.com/SagerNet/sing-box) | [Cloudflare](https://cloudflare.com)

- If this bulletproof architecture has saved you precious tinkering time, please light up a **Star ⭐️** in the top right corner.

**"Talk is cheap. Show me the code."**

---
> 🌍 **Multi-language Support**: [Simplified Chinese (中文文档)](./docs/README_zh-CN.md)
