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
    TR_STAT="${red}[未启]${plain}"; TR_PORT="-----"; TR_SNI="-------"

    ACME_STAT="${red}未部署 ❌${plain}"
 if [[ -f "$CERT_DIR/acme.crt" ]]; then
     ACME_DOMAIN=$(cat "$CERT_DIR/acme_domain.txt" 2>/dev/null)
     ACME_STAT="${green}已部署 ✅${plain} [${purple}${ACME_DOMAIN}${plain}]"
 fi
    
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
       if jq -e '.inbounds[] | select(.tag == "trojan-in")' "$JSON_FILE" >/dev/null 2>&1; then
         TR_STAT="${green}[开启]${plain}"; TR_PORT=$(jq -r '.inbounds[] | select(.tag == "trojan-in") | .listen_port' "$JSON_FILE"); TR_SNI=$(jq -r '.inbounds[] | select(.tag == "trojan-in") | .tls.server_name' "$JSON_FILE")
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
   echo -e "   $TR_STAT Trojan-Reality| 端口: ${cyan}$TR_PORT${plain} | 伪装: ${purple}$TR_SNI${plain}"
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

# --- 智能双引擎发证机 (真实ACME/极速自签 无缝切换) ---
function generate_cert_dynamic() {
    local DOMAIN=$1
    mkdir -p $CERT_DIR
    # 检测是否匹配已申请的真实 ACME 证书
    if [[ -f "$CERT_DIR/acme.crt" && -f "$CERT_DIR/acme_domain.txt" ]]; then
        local ACME_DOMAIN=$(cat "$CERT_DIR/acme_domain.txt")
        if [[ "$DOMAIN" == "$ACME_DOMAIN" ]]; then
            echo -e "${green}>>> 智能识别到匹配的 ACME 真实证书 [${DOMAIN}]，正在挂载...${plain}"
            cp -f $CERT_DIR/acme.crt $CERT_DIR/cert.crt
            cp -f $CERT_DIR/acme.key $CERT_DIR/private.key
            return
        fi
    fi
    # 没匹配上，自动降级为极速量子自签
    echo -e "${cyan}>>> 正在为 [${DOMAIN}] 极速签发 10年期 ECC 量子自签证书...${plain}"
    rm -f $CERT_DIR/private.key $CERT_DIR/cert.crt
    openssl ecparam -genkey -name prime256v1 -out $CERT_DIR/private.key >/dev/null 2>&1
    openssl req -new -x509 -days 3650 -key $CERT_DIR/private.key -out $CERT_DIR/cert.crt -subj "/C=US/ST=California/L=Los Angeles/O=Cloudflare/OU=CDN/CN=${DOMAIN}" >/dev/null 2>&1
}

# --- 🌐 ACME 真实证书独立申请模块 ---
function apply_acme_cert() {
    clear
    echo -e "${cyan}================ [ 🌐 ACME 真实证书极速申请 ] =================${plain}"
    echo -e "${yellow}⚠️ 警告：请确保您的域名已在控制台成功解析到本机器的 IP！${plain}"
    get_smart_ip
    echo -e "当前 VPS IP: ${green}${SERVER_IP}${plain}"
    read -p "👉 请输入您已解析的真实域名: " REAL_DOMAIN
    [[ -z "$REAL_DOMAIN" ]] && echo -e "${red}❌ 域名不能为空！${plain}" && sleep 2 && return
    
    # 依赖检查与安装 socat
    if ! command -v socat &> /dev/null; then
        echo -e "${cyan}>>> 正在补全 ACME 依赖 (socat)...${plain}"
        if [[ "$ID" == "debian" || "$ID" == "ubuntu" ]]; then apt-get install -y socat cron >/dev/null 2>&1; else yum install -y socat cron >/dev/null 2>&1; fi
    fi

    # 端口查杀：独立模式需要 80 端口
    if ss -tlpn | grep -q ":80 " || netstat -tlpn | grep -q ":80 "; then
        echo -e "${red}❌ 致命错误: 80 端口被占用！请先停止占用 80 端口的服务 (如 Nginx) 再试。${plain}"
        sleep 3 && return
    fi

    echo -e "${yellow}>>> 正在安装 acme.sh 核心组件...${plain}"
    curl -sL https://get.acme.sh | sh -s email=admin@${REAL_DOMAIN} >/dev/null 2>&1
    ~/.acme.sh/acme.sh --set-default-ca --server letsencrypt >/dev/null 2>&1

    echo -e "${yellow}>>> 正在向 Let's Encrypt 申请 [${REAL_DOMAIN}] 的 ECC 证书...${plain}"
    ~/.acme.sh/acme.sh --issue -d ${REAL_DOMAIN} --standalone -k ec-256 --force
    
    if [[ $? -ne 0 ]]; then
        echo -e "${red}❌ 申请失败！请检查域名是否解析正确，或是否被 Let's Encrypt 限流。${plain}"
        read -p "👉 按回车返回..." && return
    fi

    echo -e "${yellow}>>> 正在安装证书到 VX 引擎核心目录...${plain}"
    mkdir -p $CERT_DIR
    ~/.acme.sh/acme.sh --installcert -d ${REAL_DOMAIN} --fullchainpath $CERT_DIR/acme.crt --keypath $CERT_DIR/acme.key --ecc --force >/dev/null 2>&1
    echo "${REAL_DOMAIN}" > $CERT_DIR/acme_domain.txt
    
    echo -e "\n${green}✅ ACME 真实证书部署完成！${plain}"
    echo -e "👉 ${yellow}提示: 安装 Hys2/TUIC/Trojan 时填入此域名，将自动接管真实证书！${plain}"
    read -p "👉 按回车返回大屏..."
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
   sed -i '/^vless:\/\//d' "$LINK_FILE" 2>/dev/null
    echo "$SHARE" >> "$LINK_FILE"
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
    sed -i '/^hysteria2:\/\//d' "$LINK_FILE" 2>/dev/null
    echo "$SHARE" >> "$LINK_FILE"
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
    sed -i '/^tuic:\/\//d' "$LINK_FILE" 2>/dev/null
    echo "$SHARE" >> "$LINK_FILE"
    echo -e "\n${green}✅ TUIC v5 装载完成！${plain}"; echo -e "👉 ${yellow}提示: 请返回主菜单，按【8】提取节点链接！${plain}"
}

function install_vmess_ws() {
    check_sys && install_core && init_json && get_smart_ip
    echo -e "\n${yellow}>>> 锻造 VMess-WS (纯明文直连/CDN神盾) 节点：${plain}"
    read -p "👉 监听端口 (直接回车随机, 若要套CF CDN推荐填 80/8080): " LISTEN_PORT; LISTEN_PORT=${LISTEN_PORT:-8080}
    
    UUID=$($BIN_FILE generate uuid | tr -d '\r\n')
    WS_PATH="/vx-$(tr -dc 'a-z0-9' </dev/urandom | head -c 6)"

    # 移除了自签证书，改为纯净 WS 监听
    cat << EOF > /tmp/vx_tmp.json
{"type":"vmess","tag":"vmess-in","listen":"::","listen_port":$LISTEN_PORT,"users":[{"uuid":"$UUID","alterId":0}],"transport":{"type":"ws","path":"$WS_PATH"}}
EOF
    jq 'del(.inbounds[] | select(.tag == "vmess-in"))' "$JSON_FILE" > /tmp/vx_clean.json && mv /tmp/vx_clean.json "$JSON_FILE"
    jq '.inbounds += [input]' "$JSON_FILE" /tmp/vx_tmp.json > /tmp/vx_clean.json && mv /tmp/vx_clean.json "$JSON_FILE"

    systemctl restart vx-core.service
    
    # 构建无 TLS 的纯净 VMess 链接
    VMESS_JSON=$(jq -n -c --arg v "2" --arg ps "VMess-VeloX" --arg add "$SERVER_IP" --arg port "$LISTEN_PORT" --arg id "$UUID" --arg net "ws" --arg host "" --arg path "$WS_PATH" --arg tls "" --arg sni "" '{v:$v, ps:$ps, add:$add, port:$port, id:$id, aid:"0", scy:"auto", net:$net, type:"none", host:$host, path:$path, tls:$tls, sni:$sni}')
    SHARE="vmess://$(echo -n "$VMESS_JSON" | base64 -w 0)"
    sed -i '/^vmess:\/\//d' "$LINK_FILE" 2>/dev/null
    echo "$SHARE" >> "$LINK_FILE"
    echo -e "\n${green}✅ VMess-WS (纯净直连版) 装载完成！现在你可以直接把它套入 Cloudflare CDN。${plain}"
    echo -e "👉 ${yellow}提示: 请返回主菜单，按【8】提取节点链接！${plain}"
}
function install_trojan_reality() {
    check_sys && install_core && init_json && get_smart_ip
    echo -e "\n${yellow}>>> 锻造 Trojan-Reality (NPC进阶神级) 节点：${plain}"
    read -p "👉 监听端口 (直接回车随机): " LISTEN_PORT; LISTEN_PORT=${LISTEN_PORT:-$(shuf -i 10000-60000 -n 1)}
    read -p "👉 伪装域名 (直接回车默认 apple.com): " SNI_DOMAIN; SNI_DOMAIN=${SNI_DOMAIN:-"apple.com"}

    TROJAN_PASS=$($BIN_FILE generate rand --hex 16 | tr -d '\r\n')
    KEYS=$($BIN_FILE generate reality-keypair)
    PRV_KEY=$(echo "$KEYS" | awk '/PrivateKey/ {print $2}' | tr -d '\r\n')
    PUB_KEY=$(echo "$KEYS" | awk '/PublicKey/ {print $2}' | tr -d '\r\n')
    SHORT_ID=$($BIN_FILE generate rand --hex 8 | tr -d '\r\n')

    cat << EOF > /tmp/vx_tmp.json
{"type":"trojan","tag":"trojan-in","listen":"::","listen_port":$LISTEN_PORT,"users":[{"password":"$TROJAN_PASS"}],"tls":{"enabled":true,"server_name":"$SNI_DOMAIN","reality":{"enabled":true,"handshake":{"server":"$SNI_DOMAIN","server_port":443},"private_key":"$PRV_KEY","short_id":["$SHORT_ID"]}}}
EOF
    jq 'del(.inbounds[] | select(.tag == "trojan-in"))' "$JSON_FILE" > /tmp/vx_clean.json && mv /tmp/vx_clean.json "$JSON_FILE"
    jq '.inbounds += [input]' "$JSON_FILE" /tmp/vx_tmp.json > /tmp/vx_clean.json && mv /tmp/vx_clean.json "$JSON_FILE"

    systemctl restart vx-core.service

    SHARE="trojan://${TROJAN_PASS}@${SERVER_IP}:${LISTEN_PORT}?security=reality&sni=${SNI_DOMAIN}&fp=chrome&pbk=${PUB_KEY}&sid=${SHORT_ID}&type=tcp&headerType=none#Trojan-Reality-VeloX"
    sed -i '/^trojan:\/\//d' "$LINK_FILE" 2>/dev/null
    echo "$SHARE" >> "$LINK_FILE"
    echo -e "\n${green}✅ Trojan-Reality 装载完成！${plain}"; echo -e "👉 ${yellow}提示: 请返回主菜单，按【8】提取节点链接！${plain}"
}


# --- 🚀 终极杀器：一键大满贯全协议装载 ---
function install_all_nodes() {
    check_sys && install_core && init_json && get_smart_ip
    clear
    echo -e "${cyan}======================================================================${plain}"
    echo -e "          🚀 正在启动【大满贯】全协议一键全自动装载引擎 🚀"
    echo -e "${cyan}======================================================================${plain}"

    # 智能域名路由
    local COMMON_SNI="apple.com"
    if [[ -f "$CERT_DIR/acme.crt" && -f "$CERT_DIR/acme_domain.txt" ]]; then
        COMMON_SNI=$(cat "$CERT_DIR/acme_domain.txt" 2>/dev/null)
        echo -e ">>> 🌐 检测到 ACME 证书，自动接管全协议域名: ${green}$COMMON_SNI${plain}"
    else
        echo -e ">>> ⚠️ 未检测到 ACME 证书，已降级为量子自签与默认域名: ${green}$COMMON_SNI${plain}"
    fi

    # 彻底核爆清空历史数据
    > "$LINK_FILE"
    echo '{"log":{"level":"info","timestamp":true},"inbounds":[],"outbounds":[{"type":"direct","tag":"direct"},{"type":"block","tag":"block"}]}' | jq . > "$JSON_FILE"

    echo -e "\n${yellow}>>> [1/5] 正在极速压入 VLESS-Reality...${plain}"
    local P1=$(shuf -i 10000-60000 -n 1); local U1=$($BIN_FILE generate uuid | tr -d '\r\n'); local K1=$($BIN_FILE generate reality-keypair); local PR1=$(echo "$K1" | awk '/PrivateKey/ {print $2}' | tr -d '\r\n'); local PU1=$(echo "$K1" | awk '/PublicKey/ {print $2}' | tr -d '\r\n'); local S1=$($BIN_FILE generate rand --hex 8 | tr -d '\r\n')
    jq --argjson p "$P1" --arg u "$U1" --arg sni "apple.com" --arg pr "$PR1" --arg sid "$S1" '.inbounds += [{"type":"vless","tag":"vless-in","listen":"::","listen_port":$p,"users":[{"uuid":$u,"flow":"xtls-rprx-vision"}],"tls":{"enabled":true,"server_name":$sni,"reality":{"enabled":true,"handshake":{"server":$sni,"server_port":443},"private_key":$pr,"short_id":[$sid]}}}]' "$JSON_FILE" > /tmp/vx.json && mv /tmp/vx.json "$JSON_FILE"
    echo "vless://${U1}@${SERVER_IP}:${P1}?encryption=none&flow=xtls-rprx-vision&security=reality&sni=apple.com&fp=chrome&pbk=${PU1}&sid=${S1}&type=tcp&headerType=none#VLESS-Reality-VeloX" >> "$LINK_FILE"

    echo -e "${yellow}>>> [2/5] 正在极速压入 Hysteria2...${plain}"
    local P2=$(shuf -i 10000-60000 -n 1); local PW2=$($BIN_FILE generate rand --hex 16 | tr -d '\r\n'); generate_cert_dynamic "$COMMON_SNI" >/dev/null 2>&1
    jq --argjson p "$P2" --arg pw "$PW2" --arg crt "$CERT_DIR/cert.crt" --arg key "$CERT_DIR/private.key" '.inbounds += [{"type":"hysteria2","tag":"hy2-in","listen":"::","listen_port":$p,"users":[{"password":$pw}],"tls":{"enabled":true,"alpn":["h3"],"certificate_path":$crt,"key_path":$key}}]' "$JSON_FILE" > /tmp/vx.json && mv /tmp/vx.json "$JSON_FILE"
    echo "hysteria2://${PW2}@${SERVER_IP}:${P2}/?sni=${COMMON_SNI}&alpn=h3&insecure=1#Hys2-VeloX" >> "$LINK_FILE"

    echo -e "${yellow}>>> [3/5] 正在极速压入 TUIC v5...${plain}"
    local P3=$(shuf -i 10000-60000 -n 1); local U3=$($BIN_FILE generate uuid | tr -d '\r\n'); local PW3=$($BIN_FILE generate rand --hex 16 | tr -d '\r\n')
    jq --argjson p "$P3" --arg u "$U3" --arg pw "$PW3" --arg crt "$CERT_DIR/cert.crt" --arg key "$CERT_DIR/private.key" '.inbounds += [{"type":"tuic","tag":"tuic-in","listen":"::","listen_port":$p,"users":[{"uuid":$u,"password":$pw}],"congestion_control":"bbr","tls":{"enabled":true,"alpn":["h3"],"certificate_path":$crt,"key_path":$key}}]' "$JSON_FILE" > /tmp/vx.json && mv /tmp/vx.json "$JSON_FILE"
    echo "tuic://${U3}:${PW3}@${SERVER_IP}:${P3}/?sni=${COMMON_SNI}&alpn=h3&congestion_control=bbr&insecure=1#TUIC-VeloX" >> "$LINK_FILE"

    echo -e "${yellow}>>> [4/5] 正在极速压入 VMess-WS...${plain}"
    local P4=$(shuf -i 10000-60000 -n 1); local U4=$($BIN_FILE generate uuid | tr -d '\r\n'); local W4="/vx-$(tr -dc 'a-z0-9' </dev/urandom | head -c 6)"
    jq --argjson p "$P4" --arg u "$U4" --arg w "$W4" '.inbounds += [{"type":"vmess","tag":"vmess-in","listen":"::","listen_port":$p,"users":[{"uuid":$u,"alterId":0}],"transport":{"type":"ws","path":$w}}]' "$JSON_FILE" > /tmp/vx.json && mv /tmp/vx.json "$JSON_FILE"
    local VM_J=$(jq -n -c --arg v "2" --arg ps "VMess-WS-VeloX" --arg add "$SERVER_IP" --arg port "$P4" --arg id "$U4" --arg net "ws" --arg host "" --arg path "$W4" --arg tls "" --arg sni "" '{v:$v, ps:$ps, add:$add, port:$port, id:$id, aid:"0", scy:"auto", net:$net, type:"none", host:$host, path:$path, tls:$tls, sni:$sni}')
    echo "vmess://$(echo -n "$VM_J" | base64 -w 0)" >> "$LINK_FILE"

    echo -e "${yellow}>>> [5/5] 正在极速压入 Trojan-Reality...${plain}"
    local P5=$(shuf -i 10000-60000 -n 1); local PW5=$($BIN_FILE generate rand --hex 16 | tr -d '\r\n'); local K5=$($BIN_FILE generate reality-keypair); local PR5=$(echo "$K5" | awk '/PrivateKey/ {print $2}' | tr -d '\r\n'); local PU5=$(echo "$K5" | awk '/PublicKey/ {print $2}' | tr -d '\r\n'); local S5=$($BIN_FILE generate rand --hex 8 | tr -d '\r\n')
    jq --argjson p "$P5" --arg pw "$PW5" --arg sni "apple.com" --arg pr "$PR5" --arg sid "$S5" '.inbounds += [{"type":"trojan","tag":"trojan-in","listen":"::","listen_port":$p,"users":[{"password":$pw}],"tls":{"enabled":true,"server_name":$sni,"reality":{"enabled":true,"handshake":{"server":$sni,"server_port":443},"private_key":$pr,"short_id":[$sid]}}}]' "$JSON_FILE" > /tmp/vx.json && mv /tmp/vx.json "$JSON_FILE"
    echo "trojan://${PW5}@${SERVER_IP}:${P5}?security=reality&sni=apple.com&fp=chrome&pbk=${PU5}&sid=${S5}&type=tcp&headerType=none#Trojan-Reality-VeloX" >> "$LINK_FILE"

    systemctl restart vx-core.service
    echo -e "\n${green}✅ 大满贯全量装载完成！五大神级协议已全部就绪！${plain}"
    echo -e "👉 ${yellow}提示: 请按回车返回主菜单，直接按【8】提取所有节点链接！${plain}"
    read -p ""
}


# ==================================================
# 聚合提取中心
# ==================================================
function export_all_nodes() {
    clear
    echo -e "${cyan}================ [ 🖨️ VX 节点精准提取中心 ] =================${plain}"
    if [[ ! -s "$LINK_FILE" ]]; then
        echo -e "${red}❌ 当前没有任何节点被装载！请先返回菜单生成节点。${plain}"
        return
    fi
    
    echo -e "${yellow}>>> 📱 独立节点链接与二维码：${plain}"
    # 逐行读取链接，每个链接单独打印并生成一个小二维码
    cat "$LINK_FILE" | while read line; do 
        PROTOCOL=$(echo "$line" | cut -d ':' -f 1 | tr 'a-z' 'A-Z')
        echo -e "\n${purple}【 $PROTOCOL 协议 】${plain}"
      echo -e "${green}🔗 分享链接【双击下方链接快速纯净复制】:${plain}"
        echo -e "${yellow}${line}${plain}\n"
        echo -e "📱 专属节点二维码:"
        echo "$line" | qrencode -t UTF8
        echo -e "${cyan}-------------------------------------------------------------${plain}"
    done
    
    echo -e "${yellow}>>> 🔗 聚合 Base64 订阅编码 (供电脑端一键复制导入)：${plain}"
    B64_LINKS=$(cat "$LINK_FILE" | base64 -w 0)
    echo -e "${blue}${B64_LINKS}${plain}\n"
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
    echo -e "  ${green}5.${plain} ➕ 新增/覆写 Trojan-Reality ${cyan}[神级✨]${plain}"
    echo -e "----------------------------------------------------------------------"
    echo -e "  ${purple}6.${plain} 🌍 附加挂载: Acme 真实证书极速申请"
    echo -e "  ${purple}7.${plain} 🚀 终极大招: 一键满血装载所有协议"
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
        5) install_trojan_reality; read -p "👉 按回车返回大屏..." ;;
        6) apply_acme_cert ;;
       7) install_all_nodes ;;
        8) export_all_nodes; read -p "👉 提取完毕，按回车返回..." ;;
        9) update_vx ;;
        10) uninstall_vne; read -p "👉 按回车退出..."; break ;;
        0) break ;;
        *) echo -e "${red}❌ 无效输入！${plain}"; sleep 1 ;;
    esac
done
