#!/bin/bash
# =======================================================
# 项目: Velox Node Engine (VX) - 极简高阶代理核心生成器
# 版本: V4.3.0 (大满贯完全体：五大协议全解锁 + IPv6双栈支持)
# =======================================================

export LANG=en_US.UTF-8
red='\033[0;31m'; green='\033[0;32m'; yellow='\033[0;33m'; cyan='\033[0;36m'; blue='\033[0;34m'; purple='\033[0;35m'; plain='\033[0m'

CONF_DIR="/etc/velox_vne"
CERT_DIR="$CONF_DIR/cert"
BIN_FILE="/usr/local/bin/sing-box"
JSON_FILE="$CONF_DIR/config.json"
LINK_FILE="$CONF_DIR/links.txt"
SERVICE_FILE="/etc/systemd/system/vx-core.service"
SCRIPT_URL="https://raw.githubusercontent.com/pwenxiang51-wq/VX-Node-Engine/main/vx.sh"

[[ $EUID -ne 0 ]] && echo -e "${red}❌ 致命错误: 请使用 root 用户运行此引擎！${plain}" && exit 1

if [[ ! -f "/usr/local/bin/vx" ]]; then
    curl -sL "$SCRIPT_URL" -o /usr/local/bin/vx >/dev/null 2>&1
    chmod +x /usr/local/bin/vx
fi

# ==================================================
# UI: 动态监控大屏
# ==================================================
function show_dashboard() {
    clear
    OS_INFO=$(cat /etc/os-release | grep "PRETTY_NAME" | cut -d '"' -f 2)
    KERNEL_VER=$(uname -r); ARCH=$(uname -m)
    BBR_STAT=$(sysctl net.ipv4.tcp_congestion_control 2>/dev/null | awk '{print $3}' || echo "未开启")
    IPV4=$(curl -s4m3 icanhazip.com || echo "无 IPv4")
    IPV6=$(curl -s6m3 icanhazip.com || echo "无 IPv6")
    IP_INFO=$(curl -s4m3 http://ip-api.com/json/)
    LOC=$(echo "$IP_INFO" | grep -o '"country":"[^"]*' | cut -d'"' -f4)
    ISP=$(echo "$IP_INFO" | grep -o '"isp":"[^"]*' | cut -d'"' -f4)
    SB_STAT=$(systemctl is-active --quiet vx-core.service 2>/dev/null && echo -e "${green}运行中 ✅${plain}" || echo -e "${red}未部署 ❌${plain}")

    VL_STAT="${red}[未启]${plain}"; VL_PORT="-----"; VL_SNI="-------"
    HY2_STAT="${red}[未启]${plain}"; HY2_PORT="-----"; HY2_SNI="-------"
    TUIC_STAT="${red}[未启]${plain}"; TUIC_PORT="-----"; TUIC_SNI="-------"
    VM_STAT="${red}[未启]${plain}"; VM_PORT="-----"; VM_SNI="-------"
    SS_STAT="${red}[未启]${plain}"; SS_PORT="-----"

    if [[ -f "$JSON_FILE" ]]; then
        if jq -e '.inbounds[] | select(.tag == "vless-in")' "$JSON_FILE" >/dev/null 2>&1; then
            VL_STAT="${green}[开启]${plain}"; VL_PORT=$(jq -r '.inbounds[] | select(.tag == "vless-in") | .listen_port' "$JSON_FILE"); VL_SNI=$(jq -r '.inbounds[] | select(.tag == "vless-in") | .tls.server_name' "$JSON_FILE")
        fi
        if jq -e '.inbounds[] | select(.tag == "hy2-in")' "$JSON_FILE" >/dev/null 2>&1; then
            HY2_STAT="${green}[开启]${plain}"; HY2_PORT=$(jq -r '.inbounds[] | select(.tag == "hy2-in") | .listen_port' "$JSON_FILE"); HY2_SNI="自定义/自签"
        fi
        if jq -e '.inbounds[] | select(.tag == "tuic-in")' "$JSON_FILE" >/dev/null 2>&1; then
            TUIC_STAT="${green}[开启]${plain}"; TUIC_PORT=$(jq -r '.inbounds[] | select(.tag == "tuic-in") | .listen_port' "$JSON_FILE"); TUIC_SNI="自定义/自签"
        fi
        if jq -e '.inbounds[] | select(.tag == "vmess-in")' "$JSON_FILE" >/dev/null 2>&1; then
            VM_STAT="${green}[开启]${plain}"; VM_PORT=$(jq -r '.inbounds[] | select(.tag == "vmess-in") | .listen_port' "$JSON_FILE"); VM_SNI=$(jq -r '.inbounds[] | select(.tag == "vmess-in") | .tls.server_name' "$JSON_FILE")
        fi
        if jq -e '.inbounds[] | select(.tag == "ss-in")' "$JSON_FILE" >/dev/null 2>&1; then
            SS_STAT="${green}[开启]${plain}"; SS_PORT=$(jq -r '.inbounds[] | select(.tag == "ss-in") | .listen_port' "$JSON_FILE")
        fi
    fi

    echo -e "${cyan}██╗   ██╗███████╗██╗     ██████╗ ██╗  ██╗${plain}"
    echo -e "${cyan}██║   ██║██╔════╝██║    ██╔═══██╗╚██╗██╔╝${plain}"
    echo -e "${blue}██║   ██║█████╗  ██║    ██║   ██║ ╚███╔╝ ${plain}"
    echo -e "${blue}╚██╗ ██╔╝██╔══╝  ██║    ██║   ██║ ██╔██╗ ${plain}"
    echo -e "${purple} ╚████╔╝ ███████╗███████╗╚██████╔╝██╔╝ ██╗${plain}"
    echo -e "${purple}  ╚═══╝  ╚══════╝╚══════╝ ╚═════╝ ╚═╝  ╚═╝${plain}"
    echo -e "${cyan}======================================================================${plain}"
    echo -e "         🚀 Velox Node Engine (VX) 终极控制枢纽 V4.3.0 🚀       "
    echo -e "${cyan}======================================================================${plain}"
    echo -e "   👨‍💻 作者GitHub项目 : ${blue}github.com/pwenxiang51-wq${plain}"
    echo -e "   📝 作者Velo.x博客 : ${blue}222382.xyz${plain}"
    echo -e "${cyan}======================================================================${plain}"
    # 👆👆👆 ------------------------ 👆👆👆
    echo -e "⚙️  ${yellow}系统核心状态:${plain}"
    echo -e "   系统版本: ${blue}$OS_INFO${plain} | 架构: ${blue}$ARCH${plain}"
    echo -e "   内核版本: ${blue}$KERNEL_VER${plain} | 拥塞控制: ${green}${BBR_STAT^^}${plain}"
    echo -e "----------------------------------------------------------------------"
    echo -e "🌍  ${yellow}网络物理链路 (IPv6 智能双栈支持):${plain}"
    echo -e "   IPv4地址: ${green}$IPV4${plain}"
    echo -e "   IPv6地址: ${green}$IPV6${plain}"
    echo -e "   归属节点: ${blue}$LOC - $ISP${plain}"
    echo -e "----------------------------------------------------------------------"
    echo -e "🛡️  ${yellow}代理引擎矩阵 (Sing-box 状态: $SB_STAT):${plain}"
    echo -e "   $VL_STAT VLESS-Reality | 端口: ${cyan}$VL_PORT${plain} | 伪装: ${purple}$VL_SNI${plain}"
    echo -e "   $HY2_STAT Hysteria-2    | 端口: ${cyan}$HY2_PORT${plain} | 证书: ${purple}$HY2_SNI${plain}"
    echo -e "   $TUIC_STAT TUIC v5       | 端口: ${cyan}$TUIC_PORT${plain} | 证书: ${purple}$TUIC_SNI${plain}"
    echo -e "   $VM_STAT VMess-WS      | 端口: ${cyan}$VM_PORT${plain} | 伪装: ${purple}$VM_SNI${plain}"
    echo -e "   $SS_STAT SS-2022       | 端口: ${cyan}$SS_PORT${plain} | 伪装: ${purple}纯净光速直连${plain}"
    echo -e "----------------------------------------------------------------------"
    echo -e "${cyan}======================================================================${plain}"
}

# ==================================================
# 底座支撑模块
# ==================================================
function check_sys() {
    mkdir -p "$CONF_DIR"
    touch "$LINK_FILE"
    if ! command -v jq &> /dev/null || ! command -v qrencode &> /dev/null; then
        echo -e "${cyan}>>> 正在全自动补全系统依赖 (jq, qrencode, openssl)...${plain}"
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

# --- IPv6/IPv4 智能路由抓取 ---
function get_smart_ip() {
    IPV4_TMP=$(curl -s4m3 icanhazip.com)
    IPV6_TMP=$(curl -s6m3 icanhazip.com)
    if [[ -n "$IPV4_TMP" ]]; then
        SERVER_IP="$IPV4_TMP"
    elif [[ -n "$IPV6_TMP" ]]; then
        SERVER_IP="[$IPV6_TMP]" # 纯 IPv6 环境自动加括号以符合 URL 规范
    else
        SERVER_IP="127.0.0.1"
    fi
}

function generate_cert_dynamic() {
    local DOMAIN=$1
    mkdir -p $CERT_DIR
    echo -e "${cyan}>>> 正在为 [${DOMAIN}] 极速签发 10年期 ECC 量子证书...${plain}"
    rm -f $CERT_DIR/private.key $CERT_DIR/cert.crt
    openssl ecparam -genkey -name prime256v1 -out $CERT_DIR/private.key >/dev/null 2>&1
    openssl req -new -x509 -days 3650 -key $CERT_DIR/private.key -out $CERT_DIR/cert.crt -subj "/C=US/ST=California/L=Los Angeles/O=Cloudflare/OU=CDN/CN=${DOMAIN}" >/dev/null 2>&1
}

# ==================================================
# 协议库
# ==================================================
function install_vless_reality() {
    check_sys && install_core && init_json && get_smart_ip
    echo -e "\n${yellow}>>> 锻造 VLESS-Reality 节点：${plain}"
    read -p "👉 监听端口 (直接回车随机): " LISTEN_PORT; LISTEN_PORT=${LISTEN_PORT:-$(shuf -i 10000-60000 -n 1)}
    read -p "👉 伪装域名 (直接回车默认 apple.com): " SNI_DOMAIN; SNI_DOMAIN=${SNI_DOMAIN:-"apple.com"}

    UUID=$($BIN_FILE generate uuid | tr -d '\r\n')
    KEYS=$($BIN_FILE generate reality-keypair)
    PRV_KEY=$(echo "$KEYS" | awk '/PrivateKey/ {print $2}' | tr -d '\r\n')
    PUB_KEY=$(echo "$KEYS" | awk '/PublicKey/ {print $2}' | tr -d '\r\n')
    SHORT_ID=$($BIN_FILE generate rand --hex 8 | tr -d '\r\n')

    cat << EOF > /tmp/vx_tmp.json
{"type":"vless","tag":"vless-in","listen":"::","listen_port":$LISTEN_PORT,"users":[{"uuid":"$UUID","flow":"xtls-rprx-vision"}],"tls":{"enabled":true,"server_name":"$SNI_DOMAIN","reality":{"enabled":true,"handshake":{"server":"$SNI_DOMAIN","server_port":443},"private_key":"$PRV_KEY","short_id":["$SHORT_ID"]}}}
EOF
    jq 'del(.inbounds[] | select(.tag == "vless-in"))' "$JSON_FILE" > /tmp/vx_clean.json && mv /tmp/vx_clean.json "$JSON_FILE"
    jq '.inbounds += [input]' "$JSON_FILE" /tmp/vx_tmp.json > /tmp/vx_clean.json && mv /tmp/vx_clean.json "$JSON_FILE"

    systemctl restart vx-core.service
    SHARE="vless://${UUID}@${SERVER_IP}:${LISTEN_PORT}?encryption=none&flow=xtls-rprx-vision&security=reality&sni=${SNI_DOMAIN}&fp=chrome&pbk=${PUB_KEY}&sid=${SHORT_ID}&type=tcp&headerType=none#VLESS-VeloX"
    sed -i '/#VLESS-VeloX/d' "$LINK_FILE" 2>/dev/null; echo "$SHARE" >> "$LINK_FILE"
    echo -e "\n${green}✅ VLESS-Reality 装载完成！${plain}"; echo -e "👉 ${yellow}提示: 请返回主菜单，按【8】提取节点链接！${plain}"
}

function install_hysteria2() {
    check_sys && install_core && init_json && get_smart_ip
    echo -e "\n${yellow}>>> 锻造 Hysteria2 节点：${plain}"
    read -p "👉 监听端口 (直接回车随机): " LISTEN_PORT; LISTEN_PORT=${LISTEN_PORT:-$(shuf -i 10000-60000 -n 1)}
    read -p "👉 伪装域名 (直接回车默认 bing.com): " SNI_DOMAIN; SNI_DOMAIN=${SNI_DOMAIN:-"bing.com"}
    read -p "👉 核心密码 (直接回车随机): " HYS_PASS; HYS_PASS=${HYS_PASS:-$($BIN_FILE generate rand --hex 16 | tr -d '\r\n')}

    generate_cert_dynamic "$SNI_DOMAIN"
    cat << EOF > /tmp/vx_tmp.json
{"type":"hysteria2","tag":"hy2-in","listen":"::","listen_port":$LISTEN_PORT,"users":[{"password":"$HYS_PASS"}],"tls":{"enabled":true,"alpn":["h3"],"certificate_path":"$CERT_DIR/cert.crt","key_path":"$CERT_DIR/private.key"}}
EOF
    jq 'del(.inbounds[] | select(.tag == "hy2-in"))' "$JSON_FILE" > /tmp/vx_clean.json && mv /tmp/vx_clean.json "$JSON_FILE"
    jq '.inbounds += [input]' "$JSON_FILE" /tmp/vx_tmp.json > /tmp/vx_clean.json && mv /tmp/vx_clean.json "$JSON_FILE"

    systemctl restart vx-core.service
    SHARE="hysteria2://${HYS_PASS}@${SERVER_IP}:${LISTEN_PORT}/?sni=${SNI_DOMAIN}&alpn=h3&insecure=1#Hys2-VeloX"
    sed -i '/#Hys2-VeloX/d' "$LINK_FILE" 2>/dev/null; echo "$SHARE" >> "$LINK_FILE"
    echo -e "\n${green}✅ Hysteria2 装载完成！${plain}"; echo -e "👉 ${yellow}提示: 请返回主菜单，按【8】提取节点链接！${plain}"
}

function install_tuic_v5() {
    check_sys && install_core && init_json && get_smart_ip
    echo -e "\n${yellow}>>> 锻造 TUIC v5 节点：${plain}"
    read -p "👉 监听端口 (直接回车随机): " LISTEN_PORT; LISTEN_PORT=${LISTEN_PORT:-$(shuf -i 10000-60000 -n 1)}
    read -p "👉 伪装域名 (直接回车默认 cloudflare.com): " SNI_DOMAIN; SNI_DOMAIN=${SNI_DOMAIN:-"cloudflare.com"}
    read -p "👉 核心密码 (直接回车随机): " TUIC_PASS; TUIC_PASS=${TUIC_PASS:-$($BIN_FILE generate rand --hex 16 | tr -d '\r\n')}
    UUID=$($BIN_FILE generate uuid | tr -d '\r\n')

    generate_cert_dynamic "$SNI_DOMAIN"
    cat << EOF > /tmp/vx_tmp.json
{"type":"tuic","tag":"tuic-in","listen":"::","listen_port":$LISTEN_PORT,"users":[{"uuid":"$UUID","password":"$TUIC_PASS"}],"congestion_control":"bbr","tls":{"enabled":true,"alpn":["h3"],"certificate_path":"$CERT_DIR/cert.crt","key_path":"$CERT_DIR/private.key"}}
EOF
    jq 'del(.inbounds[] | select(.tag == "tuic-in"))' "$JSON_FILE" > /tmp/vx_clean.json && mv /tmp/vx_clean.json "$JSON_FILE"
    jq '.inbounds += [input]' "$JSON_FILE" /tmp/vx_tmp.json > /tmp/vx_clean.json && mv /tmp/vx_clean.json "$JSON_FILE"

    systemctl restart vx-core.service
    SHARE="tuic://${UUID}:${TUIC_PASS}@${SERVER_IP}:${LISTEN_PORT}/?sni=${SNI_DOMAIN}&alpn=h3&congestion_control=bbr&insecure=1#TUIC-VeloX"
    sed -i '/#TUIC-VeloX/d' "$LINK_FILE" 2>/dev/null; echo "$SHARE" >> "$LINK_FILE"
    echo -e "\n${green}✅ TUIC v5 装载完成！${plain}"; echo -e "👉 ${yellow}提示: 请返回主菜单，按【8】提取节点链接！${plain}"
}

function install_vmess_ws() {
    check_sys && install_core && init_json && get_smart_ip
    echo -e "\n${yellow}>>> 锻造 VMess-WS (CDN神盾) 节点：${plain}"
    read -p "👉 监听端口 (直接回车随机): " LISTEN_PORT; LISTEN_PORT=${LISTEN_PORT:-$(shuf -i 10000-60000 -n 1)}
    read -p "👉 伪装域名 (必须填真实的已解析域名，或留空用自签): " SNI_DOMAIN; SNI_DOMAIN=${SNI_DOMAIN:-"cloudflare.com"}
    UUID=$($BIN_FILE generate uuid | tr -d '\r\n')
    WS_PATH="/vx-$(tr -dc 'a-z0-9' </dev/urandom | head -c 6)"

    generate_cert_dynamic "$SNI_DOMAIN"
    cat << EOF > /tmp/vx_tmp.json
{"type":"vmess","tag":"vmess-in","listen":"::","listen_port":$LISTEN_PORT,"users":[{"uuid":"$UUID","alterId":0}],"transport":{"type":"ws","path":"$WS_PATH"},"tls":{"enabled":true,"server_name":"$SNI_DOMAIN","certificate_path":"$CERT_DIR/cert.crt","key_path":"$CERT_DIR/private.key"}}
EOF
    jq 'del(.inbounds[] | select(.tag == "vmess-in"))' "$JSON_FILE" > /tmp/vx_clean.json && mv /tmp/vx_clean.json "$JSON_FILE"
    jq '.inbounds += [input]' "$JSON_FILE" /tmp/vx_tmp.json > /tmp/vx_clean.json && mv /tmp/vx_clean.json "$JSON_FILE"

    systemctl restart vx-core.service
    
    # 构建 v2rayN 标准 VMess JSON 编码
    VMESS_JSON=$(jq -n -c --arg v "2" --arg ps "VMess-VeloX" --arg add "$SERVER_IP" --arg port "$LISTEN_PORT" --arg id "$UUID" --arg net "ws" --arg host "$SNI_DOMAIN" --arg path "$WS_PATH" --arg tls "tls" --arg sni "$SNI_DOMAIN" '{v:$v, ps:$ps, add:$add, port:$port, id:$id, aid:"0", scy:"auto", net:$net, type:"none", host:$host, path:$path, tls:$tls, sni:$sni}')
    SHARE="vmess://$(echo -n "$VMESS_JSON" | base64 -w 0)"
    sed -i '/VMess-VeloX/d' "$LINK_FILE" 2>/dev/null; echo "$SHARE" >> "$LINK_FILE"
    echo -e "\n${green}✅ VMess-WS 装载完成！${plain}"; echo -e "👉 ${yellow}提示: 请返回主菜单，按【8】提取节点链接！${plain}"
}

function install_ss_2022() {
    check_sys && install_core && init_json && get_smart_ip
    echo -e "\n${yellow}>>> 锻造 SS-2022 (纯净光速直连) 节点：${plain}"
    read -p "👉 监听端口 (直接回车随机): " LISTEN_PORT; LISTEN_PORT=${LISTEN_PORT:-$(shuf -i 10000-60000 -n 1)}
    
    # SS-2022 标准强制要求 16 位高强度 base64 Key
    METHOD="2022-blake3-aes-128-gcm"
    KEY=$(openssl rand -base64 16 | tr -d '\r\n')
    
    cat << EOF > /tmp/vx_tmp.json
{"type":"shadowsocks","tag":"ss-in","listen":"::","listen_port":$LISTEN_PORT,"method":"$METHOD","password":"$KEY"}
EOF
    jq 'del(.inbounds[] | select(.tag == "ss-in"))' "$JSON_FILE" > /tmp/vx_clean.json && mv /tmp/vx_clean.json "$JSON_FILE"
    jq '.inbounds += [input]' "$JSON_FILE" /tmp/vx_tmp.json > /tmp/vx_clean.json && mv /tmp/vx_clean.json "$JSON_FILE"

    systemctl restart vx-core.service
    
    # 构建 SS 规范链接
    B64_CRED=$(echo -n "${METHOD}:${KEY}" | base64 -w 0)
    SHARE="ss://${B64_CRED}@${SERVER_IP}:${LISTEN_PORT}#SS-2022-VeloX"
    sed -i '/SS-2022-VeloX/d' "$LINK_FILE" 2>/dev/null; echo "$SHARE" >> "$LINK_FILE"
    echo -e "\n${green}✅ SS-2022 装载完成！${plain}"; echo -e "👉 ${yellow}提示: 请返回主菜单，按【8】提取节点链接！${plain}"
}

# ==================================================
# 聚合提取中心
# ==================================================
function export_all_nodes() {
    clear
    echo -e "${cyan}================ [ 🖨️ VX 节点聚合提取中心 ] =================${plain}"
    if [[ ! -s "$LINK_FILE" ]]; then
        echo -e "${red}❌ 当前没有任何节点被装载！请先返回菜单生成节点。${plain}"
        return
    fi
    echo -e "${yellow}>>> 📝 独立明文链接：${plain}"
    cat "$LINK_FILE" | while read line; do echo -e "${green}${line}${plain}\n"; done
    echo -e "${yellow}>>> 🔗 聚合 Base64 订阅编码 (供 v2rayN/Clash 一键导入)：${plain}"
    B64_LINKS=$(cat "$LINK_FILE" | base64 -w 0)
    echo -e "${blue}${B64_LINKS}${plain}\n"
    echo -e "${yellow}>>> 📱 迷你订阅二维码 (使用客户端直接扫码导入所有节点)：${plain}"
    echo "$B64_LINKS" | qrencode -t UTF8
    echo -e "${cyan}=============================================================${plain}"
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

while true; do
    show_dashboard
    echo -e "  ${green}1.${plain} ➕ 新增/覆写 VLESS-Reality"
    echo -e "  ${green}2.${plain} ➕ 新增/覆写 Hysteria2  (支持自定域名)"
    echo -e "  ${green}3.${plain} ➕ 新增/覆写 TUIC v5    (支持自定域名)"
    echo -e "  ${green}4.${plain} ➕ 新增/覆写 VMess-WS   ${cyan}[NEW✨]${plain}"
    echo -e "  ${green}5.${plain} ➕ 新增/覆写 SS-2022    ${cyan}[NEW✨]${plain}"
    echo -e "----------------------------------------------------------------------"
    echo -e "  ${purple}6.${plain} 🌍 附加挂载: WARP 解锁  ${yellow}[待开发]${plain}"
    echo -e "  ${purple}7.${plain} ⚡ 底层调优: BBR 加速    ${yellow}[待开发]${plain}"
    echo -e "----------------------------------------------------------------------"
    echo -e "  ${cyan}8.${plain} 🖨️  ${green}一键提取全节点 (明文/Base64/二维码)${plain}"
    echo -e "  ${yellow}9.${plain} 🔄 OTA 热更新引擎       ${red}10.${plain} 🗑️  彻底粉碎卸载"
    echo -e "  ${yellow}0.${plain} 🔙 退出终端"
    echo -e "${cyan}======================================================================${plain}"
    read -p "👉 执行指令 [0-10]: " choice
    case "$choice" in
        1) install_vless_reality; read -p "👉 按回车返回大屏..." ;;
        2) install_hysteria2; read -p "👉 按回车返回大屏..." ;;
        3) install_tuic_v5; read -p "👉 按回车返回大屏..." ;;
        4) install_vmess_ws; read -p "👉 按回车返回大屏..." ;;
        5) install_ss_2022; read -p "👉 按回车返回大屏..." ;;
        6|7) echo -e "\n${yellow}🚧 架构师正在拼命打磨该模块，敬请期待！${plain}"; sleep 2 ;;
        8) export_all_nodes; read -p "👉 提取完毕，按回车返回..." ;;
        9) update_vx ;;
        10) uninstall_vne; read -p "👉 按回车退出..."; break ;;
        0) break ;;
        *) echo -e "${red}❌ 无效输入！${plain}"; sleep 1 ;;
    esac
done
