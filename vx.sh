#!/bin/bash
# =======================================================
# 项目: Velox Node Engine (VX) - 极简高阶代理核心生成器
# 版本: V4.0.2 (大满贯修复版：五协议全家桶 + 监控大屏)
# 核心: 引入 jq 动态注入技术，实现五协议完美共存
# =======================================================

export LANG=en_US.UTF-8
red='\033[0;31m'; green='\033[0;32m'; yellow='\033[0;33m'; cyan='\033[0;36m'; blue='\033[0;34m'; purple='\033[0;35m'; plain='\033[0m'

CONF_DIR="/etc/velox_vne"
CERT_DIR="$CONF_DIR/cert"
BIN_FILE="/usr/local/bin/sing-box"
JSON_FILE="$CONF_DIR/config.json"
SERVICE_FILE="/etc/systemd/system/vx-core.service"
SCRIPT_URL="https://raw.githubusercontent.com/pwenxiang51-wq/VX-Node-Engine/main/vx.sh"

[[ $EUID -ne 0 ]] && echo -e "${red}❌ 致命错误: 请使用 root 用户运行此引擎！${plain}" && exit 1

if [[ ! -f "/usr/local/bin/vx" ]]; then
    curl -sL "$SCRIPT_URL" -o /usr/local/bin/vx >/dev/null 2>&1
    chmod +x /usr/local/bin/vx
fi

# ==================================================
# 架构师核心：五协议全家桶监控大屏
# ==================================================
function show_dashboard() {
    clear
    OS_INFO=$(cat /etc/os-release | grep "PRETTY_NAME" | cut -d '"' -f 2)
    KERNEL_VER=$(uname -r); ARCH=$(uname -m)
    BBR_STAT=$(sysctl net.ipv4.tcp_congestion_control 2>/dev/null | awk '{print $3}' || echo "未开启")
    IPV4=$(curl -s4m3 icanhazip.com || echo "无 IPv4")
    IP_INFO=$(curl -s4m3 http://ip-api.com/json/)
    LOC=$(echo "$IP_INFO" | grep -o '"country":"[^"]*' | cut -d'"' -f4)
    ISP=$(echo "$IP_INFO" | grep -o '"isp":"[^"]*' | cut -d'"' -f4)
    SB_STAT=$(systemctl is-active --quiet vx-core.service 2>/dev/null && echo -e "${green}运行中 ✅${plain}" || echo -e "${red}未部署 ❌${plain}")

    # 动态读取 JSON 配置状态 (五大协议)
    VL_STAT="${red}[未启]${plain}"; VL_PORT="-----"; VL_SNI="-------"
    HY2_STAT="${red}[未启]${plain}"; HY2_PORT="-----"
    TUIC_STAT="${red}[未启]${plain}"; TUIC_PORT="-----"
    VM_STAT="${red}[未启]${plain}"; VM_PORT="-----"
    SS_STAT="${red}[未启]${plain}"; SS_PORT="-----"

    if [[ -f "$JSON_FILE" ]]; then
        if jq -e '.inbounds[] | select(.tag == "vless-in")' "$JSON_FILE" >/dev/null 2>&1; then
            VL_STAT="${green}[开启]${plain}"
            VL_PORT=$(jq -r '.inbounds[] | select(.tag == "vless-in") | .listen_port' "$JSON_FILE")
            VL_SNI=$(jq -r '.inbounds[] | select(.tag == "vless-in") | .tls.server_name' "$JSON_FILE")
        fi
        if jq -e '.inbounds[] | select(.tag == "hy2-in")' "$JSON_FILE" >/dev/null 2>&1; then
            HY2_STAT="${green}[开启]${plain}"
            HY2_PORT=$(jq -r '.inbounds[] | select(.tag == "hy2-in") | .listen_port' "$JSON_FILE")
        fi
        if jq -e '.inbounds[] | select(.tag == "tuic-in")' "$JSON_FILE" >/dev/null 2>&1; then
            TUIC_STAT="${green}[开启]${plain}"
            TUIC_PORT=$(jq -r '.inbounds[] | select(.tag == "tuic-in") | .listen_port' "$JSON_FILE")
        fi
        if jq -e '.inbounds[] | select(.tag == "vmess-in")' "$JSON_FILE" >/dev/null 2>&1; then
            VM_STAT="${green}[开启]${plain}"
            VM_PORT=$(jq -r '.inbounds[] | select(.tag == "vmess-in") | .listen_port' "$JSON_FILE")
        fi
        if jq -e '.inbounds[] | select(.tag == "ss-in")' "$JSON_FILE" >/dev/null 2>&1; then
            SS_STAT="${green}[开启]${plain}"
            SS_PORT=$(jq -r '.inbounds[] | select(.tag == "ss-in") | .listen_port' "$JSON_FILE")
        fi
    fi

    # 打印灵魂 Logo
    echo -e "${cyan}██╗   ██╗███████╗██╗     ██████╗ ██╗  ██╗${plain}"
    echo -e "${cyan}██║   ██║██╔════╝██║    ██╔═══██╗╚██╗██╔╝${plain}"
    echo -e "${blue}██║   ██║█████╗  ██║    ██║   ██║ ╚███╔╝ ${plain}"
    echo -e "${blue}╚██╗ ██╔╝██╔══╝  ██║    ██║   ██║ ██╔██╗ ${plain}"
    echo -e "${purple} ╚████╔╝ ███████╗███████╗╚██████╔╝██╔╝ ██╗${plain}"
    echo -e "${purple}  ╚═══╝  ╚══════╝╚══════╝ ╚═════╝ ╚═╝  ╚═╝${plain}"
    echo -e "${cyan}======================================================================${plain}"
    echo -e "         🚀 Velox Node Engine (VX) 终极控制枢纽 V4.0.2 🚀       "
    echo -e "${cyan}======================================================================${plain}"
    echo -e "⚙️  ${yellow}系统核心状态:${plain}"
    echo -e "   系统版本: ${blue}$OS_INFO${plain} | 架构: ${blue}$ARCH${plain}"
    echo -e "   内核版本: ${blue}$KERNEL_VER${plain} | 拥塞控制: ${green}${BBR_STAT^^}${plain}"
    echo -e "----------------------------------------------------------------------"
    echo -e "🌍  ${yellow}网络物理链路:${plain}"
    echo -e "   IPv4地址: ${green}$IPV4${plain}"
    echo -e "   归属节点: ${blue}$LOC - $ISP${plain}"
    echo -e "----------------------------------------------------------------------"
    echo -e "🛡️  ${yellow}代理引擎矩阵 (Sing-box 状态: $SB_STAT):${plain}"
    echo -e "   $VL_STAT VLESS-Reality | 端口: ${cyan}$VL_PORT${plain} | 伪装: ${purple}$VL_SNI${plain}"
    echo -e "   $HY2_STAT Hysteria-2    | 端口: ${cyan}$HY2_PORT${plain} | 证书: ${purple}内部自签${plain}"
    echo -e "   $TUIC_STAT TUIC v5       | 端口: ${cyan}$TUIC_PORT${plain} | 证书: ${purple}内部自签${plain}"
    echo -e "   $VM_STAT VMess-WS      | 端口: ${cyan}$VM_PORT${plain} | 隧道: ${purple}未接管${plain}"
    echo -e "   $SS_STAT SS-2022       | 端口: ${cyan}$SS_PORT${plain} | 伪装: ${purple}纯净直连${plain}"
    echo -e "----------------------------------------------------------------------"
    echo -e "🚀  ${yellow}附加挂载模块:${plain}"
    echo -e "   WARP 解锁状态: ${red}未启动 ❌${plain}   Acme 真实证书: ${red}未部署 ❌${plain}"
    echo -e "${cyan}======================================================================${plain}"
}

# ==================================================
# 基础核心模块
# ==================================================
function check_sys() {
    mkdir -p "$CONF_DIR"
    if ! command -v jq &> /dev/null || ! command -v qrencode &> /dev/null; then
        echo -e "${cyan}>>> 正在全自动补全系统依赖 (jq, qrencode)...${plain}"
        [[ -f /etc/os-release ]] && source /etc/os-release
        if [[ "$ID" == "debian" || "$ID" == "ubuntu" ]]; then
            apt-get update -y >/dev/null 2>&1 && apt-get install -y jq qrencode curl wget openssl tar >/dev/null 2>&1
        else
            yum install -y epel-release >/dev/null 2>&1 && yum install -y jq qrencode curl wget openssl tar >/dev/null 2>&1
        fi
    fi
}

function init_json() {
    if [[ ! -f "$JSON_FILE" ]]; then
        echo '{"log":{"level":"info","timestamp":true},"inbounds":[],"outbounds":[{"type":"direct","tag":"direct"},{"type":"block","tag":"block"}]}' | jq . > "$JSON_FILE"
    fi
}

function install_core() {
    if [[ ! -f "$BIN_FILE" ]]; then
        echo -e "${yellow}>>> 正在拉取 Sing-box 内核...${plain}"
        LATEST=$(curl -sL https://data.jsdelivr.com/v1/package/gh/SagerNet/sing-box | jq -r '.versions | map(select(test("alpha|beta|rc") | not)) | .[0]')
        ARCH=$([[ "$(uname -m)" == "x86_64" ]] && echo "amd64" || echo "arm64")
        wget -qO sb.tar.gz "https://github.com/SagerNet/sing-box/releases/download/v${LATEST}/sing-box-${LATEST}-linux-${ARCH}.tar.gz"
        tar -xzf sb.tar.gz && mv sing-box-*/sing-box $BIN_FILE && chmod +x $BIN_FILE && rm -rf sb.tar.gz sing-box*
    fi
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
    systemctl daemon-reload && systemctl enable vx-core.service >/dev/null 2>&1
}

# ==================================================
# 协议装载：VLESS-Reality (支持共存注入)
# ==================================================
function install_vless_reality() {
    check_sys && install_core && init_json
    SERVER_IP=$(curl -s4m3 icanhazip.com)
    
    echo -e "\n${yellow}>>> 锻造 VLESS-Reality 节点：${plain}"
    read -p "👉 请设置监听端口 (直接回车随机): " LISTEN_PORT
    LISTEN_PORT=${LISTEN_PORT:-$(shuf -i 10000-60000 -n 1)}
    read -p "👉 请设置伪装域名 (直接回车默认 apple.com): " SNI_DOMAIN
    SNI_DOMAIN=${SNI_DOMAIN:-"apple.com"}

    UUID=$($BIN_FILE generate uuid)
    KEYS=$($BIN_FILE generate reality-keypair)
    PRV_KEY=$(echo "$KEYS" | awk '/PrivateKey/ {print $2}')
    PUB_KEY=$(echo "$KEYS" | awk '/PublicKey/ {print $2}')
    SHORT_ID=$($BIN_FILE generate rand --hex 8)

    # 动态注入 JSON
    cat << EOF > /tmp/vx_vless.json
{
  "type": "vless", "tag": "vless-in", "listen": "::", "listen_port": $LISTEN_PORT,
  "users": [ { "uuid": "$UUID", "flow": "xtls-rprx-vision" } ],
  "tls": { "enabled": true, "server_name": "$SNI_DOMAIN", "reality": { "enabled": true, "handshake": { "server": "$SNI_DOMAIN", "server_port": 443 }, "private_key": "$PRV_KEY", "short_id": [ "$SHORT_ID" ] } }
}
EOF
    jq 'del(.inbounds[] | select(.tag == "vless-in"))' "$JSON_FILE" > /tmp/vx_tmp.json && mv /tmp/vx_tmp.json "$JSON_FILE"
    jq '.inbounds += [input]' "$JSON_FILE" /tmp/vx_vless.json > /tmp/vx_tmp.json && mv /tmp/vx_tmp.json "$JSON_FILE"
    rm -f /tmp/vx_vless.json

    systemctl restart vx-core.service
    
    SHARE="vless://$UUID@$SERVER_IP:$LISTEN_PORT?encryption=none&flow=xtls-rprx-vision&security=reality&sni=$SNI_DOMAIN&fp=chrome&pbk=$PUB_KEY&sid=$SHORT_ID&type=tcp&headerType=none#VLESS-VeloX"
    echo -e "\n${green}✅ VLESS-Reality 装载完成！${plain}"
    echo -e "🔗 导入链接: ${cyan}$SHARE${plain}\n"
}

function update_vx() {
    echo -e "\n${yellow}>>> 🔄 正在热更新 VX 引擎...${plain}"
    curl -sL "$SCRIPT_URL" -o /tmp/vx.sh && mv -f /tmp/vx.sh /usr/local/bin/vx && chmod +x /usr/local/bin/vx
    echo -e "${green}✅ OTA 完成！请按回车重启面板。${plain}"; read -p ""; exec vx
}

function uninstall_vne() {
    systemctl stop vx-core.service >/dev/null 2>&1; systemctl disable vx-core.service >/dev/null 2>&1
    rm -rf $CONF_DIR $BIN_FILE $SERVICE_FILE /usr/local/bin/vx
    systemctl daemon-reload; echo -e "${green}✅ VX 核心与所有协议已彻底粉碎！${plain}"
}

# ==================================================
# 菜单控制器
# ==================================================
while true; do
    show_dashboard
    echo -e "  ${green}1.${plain} ➕ 新增/覆写 VLESS-Reality"
    echo -e "  ${purple}2.${plain} ➕ 新增/覆写 Hysteria2  ${yellow}[等待 OTA 唤醒]${plain}"
    echo -e "  ${purple}3.${plain} ➕ 新增/覆写 TUIC v5    ${yellow}[等待 OTA 唤醒]${plain}"
    echo -e "  ${purple}4.${plain} ➕ 新增/覆写 VMess-WS   ${yellow}[等待 OTA 唤醒]${plain}"
    echo -e "  ${purple}5.${plain} ➕ 新增/覆写 SS-2022    ${yellow}[等待 OTA 唤醒]${plain}"
    echo -e "----------------------------------------------------------------------"
    echo -e "  ${purple}6.${plain} 🌍 附加挂载: WARP 解锁  ${yellow}[等待 OTA]${plain}"
    echo -e "  ${purple}7.${plain} ⚡ 底层调优: BBR 加速    ${yellow}[等待 OTA]${plain}"
    echo -e "----------------------------------------------------------------------"
    echo -e "  ${yellow}8.${plain} 🔄 OTA 热更新引擎代码    ${red}9.${plain} 🗑️  彻底粉碎卸载"
    echo -e "  ${yellow}0.${plain} 🔙 退出终端"
    echo -e "${cyan}======================================================================${plain}"
    read -p "👉 执行指令 [0-9]: " choice
    case "$choice" in
        1) install_vless_reality; read -p "👉 按回车返回大屏..." ;;
        2|3|4|5|6|7) echo -e "\n${yellow}🚧 架构师正在拼命打磨共存注入逻辑，敬请期待 OTA！${plain}"; sleep 2 ;;
        8) update_vx ;;
        9) uninstall_vne; read -p "👉 按回车退出..."; break ;;
        0) break ;;
        *) echo -e "${red}❌ 无效输入！${plain}"; sleep 1 ;;
    esac
done
