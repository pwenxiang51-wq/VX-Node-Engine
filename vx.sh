#!/bin/bash
# =======================================================
# 项目: Velox Node Engine (VX) - 极简高阶代理核心生成器
# 作者: pwenxiang51-wq
# 博客: 222382.xyz
# 版本: V1.0.1 (加入智能自我注册唤醒指令)
# =======================================================

export LANG=en_US.UTF-8
red='\033[0;31m'
green='\033[0;32m'
yellow='\033[0;33m'
cyan='\033[0;36m'
blue='\033[0;34m'
purple='\033[0;35m'
plain='\033[0m'

CONF_DIR="/etc/velox_vne"
BIN_FILE="/usr/local/bin/sing-box"
JSON_FILE="$CONF_DIR/config.json"
SERVICE_FILE="/etc/systemd/system/vx-core.service"

[[ $EUID -ne 0 ]] && echo -e "${red}❌ 致命错误: 请使用 root 用户运行此引擎！${plain}" && exit 1

# =========================================
# 极客黑科技：全局指令自我注册模块
# =========================================
if [[ ! -f "/usr/local/bin/vx" ]]; then
    curl -sL "https://raw.githubusercontent.com/pwenxiang51-wq/VX-Node-Engine/main/vx.sh" -o /usr/local/bin/vx >/dev/null 2>&1
    chmod +x /usr/local/bin/vx
fi

function show_logo() {
    clear
    echo -e "${cyan}██╗   ██╗███████╗██╗     ██████╗ ██╗  ██╗${plain}"
    echo -e "${cyan}██║   ██║██╔════╝██║    ██╔═══██╗╚██╗██╔╝${plain}"
    echo -e "${blue}██║   ██║█████╗  ██║    ██║   ██║ ╚███╔╝ ${plain}"
    echo -e "${blue}╚██╗ ██╔╝██╔══╝  ██║    ██║   ██║ ██╔██╗ ${plain}"
    echo -e "${purple} ╚████╔╝ ███████╗███████╗╚██████╔╝██╔╝ ██╗${plain}"
    echo -e "${purple}  ╚═══╝  ╚══════╝╚══════╝ ╚═════╝ ╚═╝  ╚═╝${plain}"
    echo -e "${cyan}=======================================================${plain}"
    echo -e "      🚀 Velox Node Engine (极速节点构建引擎 V1.0) 🚀   "
    echo -e "${cyan}=======================================================${plain}"
}

function check_sys() {
    echo -e "\n${yellow}>>> [1/5] 正在执行全系统智能嗅探与依赖装载...${plain}"
    mkdir -p "$CONF_DIR"
    
    if [[ -f /etc/os-release ]]; then
        source /etc/os-release
        OS=$ID
    else
        echo -e "${red}❌ 无法识别的操作系统！${plain}" && exit 1
    fi

    if ! command -v jq &> /dev/null || ! command -v qrencode &> /dev/null; then
        echo -e "${cyan}检测到缺失底层依赖，正在为 $OS 系统自动补全...${plain}"
        if [[ "${OS}" == "debian" || "${OS}" == "ubuntu" || "${OS}" == "kali" ]]; then
            apt-get update -y >/dev/null 2>&1
            apt-get install -y jq qrencode curl wget openssl tar >/dev/null 2>&1
        elif [[ "${OS}" == "centos" || "${OS}" == "rocky" || "${OS}" == "almalinux" || "${OS}" == "rhel" ]]; then
            yum install -y epel-release >/dev/null 2>&1
            yum install -y jq qrencode curl wget openssl tar >/dev/null 2>&1
        elif [[ "${OS}" == "fedora" ]]; then
            dnf install -y jq qrencode curl wget openssl tar >/dev/null 2>&1
        else
            echo -e "${red}❌ 暂不支持自动安装依赖，请手动安装 jq, qrencode, curl。${plain}" && exit 1
        fi
    fi
}

function install_vne() {
    check_sys
    
    echo -e "\n${yellow}>>> [2/5] 正在拉取 Sing-box 官方最新正式版内核...${plain}"
    LATEST_VERSION=$(curl -sL https://data.jsdelivr.com/v1/package/gh/SagerNet/sing-box | jq -r '.versions | map(select(test("alpha|beta|rc") | not)) | .[0]')
    ARCH=$(uname -m)
    case $ARCH in
        x86_64) SB_ARCH="amd64" ;;
        aarch64) SB_ARCH="arm64" ;;
        *) echo -e "${red}❌ 暂不支持的 CPU 架构: $ARCH${plain}" && return 1 ;;
    esac

    DL_URL="https://github.com/SagerNet/sing-box/releases/download/v${LATEST_VERSION}/sing-box-${LATEST_VERSION}-linux-${SB_ARCH}.tar.gz"
    wget -qO sing-box.tar.gz "$DL_URL"
    tar -xzf sing-box.tar.gz
    mv sing-box-${LATEST_VERSION}-linux-${SB_ARCH}/sing-box $BIN_FILE
    chmod +x $BIN_FILE
    rm -rf sing-box.tar.gz sing-box-${LATEST_VERSION}-linux-${SB_ARCH}
    echo -e "${green}✅ 内核装载成功！当前版本: $LATEST_VERSION${plain}"

    echo -e "\n${yellow}>>> [3/5] 开启 VLESS-Reality 高防协议核心参数配置：${plain}"
    read -p "👉 请设置监听端口 (推荐 443/8443，直接回车随机防爆破): " LISTEN_PORT
    LISTEN_PORT=${LISTEN_PORT:-$(shuf -i 10000-60000 -n 1)}

    read -p "👉 请设置 Reality 伪装域名 (直接回车默认 apple.com): " SNI_DOMAIN
    SNI_DOMAIN=${SNI_DOMAIN:-"apple.com"}

    echo -e "${cyan}正在利用底层引擎生成高强度量子密钥与 UUID...${plain}"
    UUID=$($BIN_FILE generate uuid)
    KEYS=$($BIN_FILE generate reality-keypair)
    PRIVATE_KEY=$(echo "$KEYS" | awk '/PrivateKey/ {print $2}')
    PUBLIC_KEY=$(echo "$KEYS" | awk '/PublicKey/ {print $2}')
    SHORT_ID=$($BIN_FILE generate rand --hex 8)
    SERVER_IP=$(curl -s4m5 icanhazip.com || curl -s6m5 icanhazip.com)

    echo -e "\n${yellow}>>> [4/5] 正在构建极简高内聚 JSON 配置文件...${plain}"
    cat << EOF > $JSON_FILE
{
  "log": { "level": "info", "timestamp": true },
  "inbounds": [
    {
      "type": "vless",
      "tag": "vless-in",
      "listen": "::",
      "listen_port": $LISTEN_PORT,
      "users": [ { "uuid": "$UUID", "flow": "xtls-rprx-vision" } ],
      "tls": {
        "enabled": true,
        "server_name": "$SNI_DOMAIN",
        "reality": {
          "enabled": true,
          "handshake": { "server": "$SNI_DOMAIN", "server_port": 443 },
          "private_key": "$PRIVATE_KEY",
          "short_id": [ "$SHORT_ID" ]
        }
      }
    }
  ],
  "outbounds": [
    { "type": "direct", "tag": "direct" },
    { "type": "block", "tag": "block" }
  ]
}
EOF

    echo -e "\n${yellow}>>> [5/5] 正在将引擎注入系统守护进程...${plain}"
    cat << EOF > $SERVICE_FILE
[Unit]
Description=Velox Node Engine (VX) Core
After=network.target

[Service]
ExecStart=$BIN_FILE run -c $JSON_FILE
Restart=always
RestartSec=3
LimitNOFILE=infinity

[Install]
WantedBy=multi-user.target
EOF

    systemctl daemon-reload
    systemctl enable --now vx-core.service >/dev/null 2>&1

    SHARE_LINK="vless://$UUID@$SERVER_IP:$LISTEN_PORT?encryption=none&flow=xtls-rprx-vision&security=reality&sni=$SNI_DOMAIN&fp=chrome&pbk=$PUBLIC_KEY&sid=$SHORT_ID&type=tcp&headerType=none#Velox-Reality"

    echo -e "\n${cyan}=======================================================${plain}"
    echo -e " ${purple}🔥 节点构建完成！您的专属 VLESS-Reality 资产如下：${plain}"
    echo -e "${cyan}=======================================================${plain}"
    echo -e "🌐 ${yellow}节点 IP${plain}    : $SERVER_IP"
    echo -e "🚪 ${yellow}监听端口${plain}   : $LISTEN_PORT"
    echo -e "🎭 ${yellow}伪装域名${plain}   : $SNI_DOMAIN"
    echo -e "🔑 ${yellow}UUID (密码)${plain}: $UUID"
    echo -e "${cyan}-------------------------------------------------------${plain}"
    echo -e "🔗 ${green}一键导入链接 (支持 v2rayN, Nekobox, Shadowrocket)：${plain}\n"
    echo -e "${blue}${SHARE_LINK}${plain}"
    echo -e "\n${yellow}📱 扫码导入 (请将终端全屏)：${plain}"
    qrencode -o - -t ANSIUTF8 "$SHARE_LINK"
    echo -e "${cyan}=======================================================${plain}"
}

function uninstall_vne() {
    echo -e "\n${yellow}⚠️ 警告: 正在彻底销毁 Velox 引擎核心与所有数据...${plain}"
    systemctl stop vx-core.service >/dev/null 2>&1
    systemctl disable vx-core.service >/dev/null 2>&1
    rm -f $SERVICE_FILE
    systemctl daemon-reload >/dev/null 2>&1
    rm -rf $CONF_DIR $BIN_FILE
    if [[ -f "/usr/local/bin/vx" ]]; then
        rm -f /usr/local/bin/vx
    fi
    echo -e "${green}✅ 卸载绝杀完成！内核及配置痕迹已被彻底抹除，系统已恢复纯净。${plain}"
}

while true; do
    show_logo
    if systemctl is-active --quiet vx-core.service 2>/dev/null; then
        VNE_STAT="${green}运行中 ✅${plain}"
    else
        VNE_STAT="${red}未部署 ❌${plain}"
    fi
    echo -e "      ${blue}当前引擎状态: [ $VNE_STAT ]${plain}"
    echo -e "${cyan}-------------------------------------------------------${plain}"
    echo -e "  ${green}1.${plain} 🚀 一键装载 VLESS-Reality 极速节点"
    echo -e "  ${red}2.${plain} 🗑️  彻底粉碎卸载 VX 引擎 (清理无痕)"
    echo -e "  ${yellow}0.${plain} 🔙 退出脚本"
    echo -e "${cyan}-------------------------------------------------------${plain}"
    read -p "👉 请选择操作 [0-2]: " choice
    
    case "$choice" in
        1) install_vne; echo ""; read -p "👉 按【回车键】返回主菜单..." ;;
        2) uninstall_vne; echo ""; read -p "👉 按【回车键】返回主菜单..." ;;
        0) echo -e "${green}退出 Velox Node Engine。${plain}"; break ;;
        *) echo -e "${red}❌ 无效输入！${plain}"; sleep 1 ;;
    esac
done
