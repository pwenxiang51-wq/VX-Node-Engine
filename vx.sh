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
VX_VERSION="4.3.0"
TEMP_UUID=$(cat /proc/sys/kernel/random/uuid)
TEMP_PASS=$(tr -dc 'a-zA-Z0-9' </dev/urandom | head -c 16)

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

    # 极速无感检测版本更新 (1.5秒超时)
    REMOTE_VER=$(curl -s -m 1.5 "https://raw.githubusercontent.com/pwenxiang51-wq/VX-Node-Engine/main/vx.sh" | grep -m 1 "^VX_VERSION=" | cut -d'"' -f2)
    UPDATE_MSG=""
    if [[ -n "$REMOTE_VER" && "$REMOTE_VER" != "$VX_VERSION" ]]; then
        UPDATE_MSG="${yellow}🔔 发现新版 v${REMOTE_VER} (请按 9 升级)${plain}"
    else
        UPDATE_MSG="${green}✅ 最新版 (v${VX_VERSION})${plain}"
    fi

    echo -e "${cyan}██╗   ██╗███████╗██╗     ██████╗ ██╗  ██╗${plain}"
    echo -e "${cyan}██║   ██║██╔════╝██║    ██╔═══██╗╚██╗██╔╝${plain}"
    echo -e "${blue}██║   ██║█████╗  ██║    ██║   ██║ ╚███╔╝ ${plain}"
    echo -e "${blue}╚██╗ ██╔╝██╔══╝  ██║    ██║   ██║ ██╔██╗ ${plain}"
    echo -e "${purple} ╚████╔╝ ███████╗███████╗╚██████╔╝██╔╝ ██╗${plain}"
    echo -e "${purple}  ╚═══╝  ╚══════╝╚══════╝ ╚═════╝ ╚═╝  ╚═╝${plain}"
    echo -e "${cyan}======================================================================${plain}"
    echo -e "       🚀 Velox Node Engine (VX) 终极控制枢纽 V${VX_VERSION} 🚀       "
    echo -e "${cyan}======================================================================${plain}"
    echo -e "   👨‍💻 作者GitHub项目 : ${blue}github.com/pwenxiang51-wq${plain}"
    echo -e "   📝 作者Velo.x博客 : ${blue}222382.xyz${plain}"
    echo -e " ⚡ 更新状态：$UPDATE_MSG"
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
    read -p "👉 节点 UUID (直接回车随机): " UUID; UUID=${UUID:-$TEMP_UUID}
    read -p "👉 伪装域名 (直接回车默认 apple.com): " SNI_DOMAIN; SNI_DOMAIN=${SNI_DOMAIN:-"apple.com"}

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
    read -p "👉 节点密码 (直接回车随机): " HYS_PASS; HYS_PASS=${HYS_PASS:-$TEMP_PASS}
    read -p "👉 绑定域名 (直接回车默认 bing.com): " SNI_DOMAIN; SNI_DOMAIN=${SNI_DOMAIN:-"bing.com"}
    
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
    read -p "👉 节点 UUID (直接回车随机): " UUID; UUID=${UUID:-$TEMP_UUID}
    read -p "👉 节点密码 (直接回车随机): " TUIC_PASS; TUIC_PASS=${TUIC_PASS:-$TEMP_PASS}
    read -p "👉 绑定域名 (直接回车默认 bing.com): " SNI_DOMAIN; SNI_DOMAIN=${SNI_DOMAIN:-"bing.com"}
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
    read -p "👉 监听端口 (直接回车随机): " LISTEN_PORT; LISTEN_PORT=${LISTEN_PORT:-$(shuf -i 10000-60000 -n 1)}
    read -p "👉 节点 UUID (直接回车随机): " UUID; UUID=${UUID:-$TEMP_UUID}
    
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
   # 5. Trojan-Reality 自定义逻辑
    read -p "👉 监听端口 (直接回车随机): " LISTEN_PORT; LISTEN_PORT=${LISTEN_PORT:-$(shuf -i 10000-60000 -n 1)}
    read -p "👉 节点密码 (直接回车随机): " TROJAN_PASS; TROJAN_PASS=${TROJAN_PASS:-$TEMP_PASS}
    read -p "👉 伪装域名 (直接回车默认 apple.com): " SNI_DOMAIN; SNI_DOMAIN=${SNI_DOMAIN:-"apple.com"}

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

    # 1. 智能发证引导
    if [[ ! -f "$CERT_DIR/acme.crt" ]]; then
        echo -e "${yellow}⚠️ 检测到您尚未申请 ACME 真实证书！${plain}"
        read -p "❓ 是否先去申请真实域名证书？(输入 y 申请，直接回车则使用自签): " DO_ACME
        if [[ "$DO_ACME" == "y" || "$DO_ACME" == "Y" ]]; then
            apply_acme_cert
            if [[ ! -f "$CERT_DIR/acme.crt" ]]; then
                echo -e "${red}❌ 证书申请失败，将降级为自签模式继续安装...${plain}"; sleep 2
            fi
        fi
    fi

    # 2. 智能域名路由
    local COMMON_SNI="apple.com"
    if [[ -f "$CERT_DIR/acme.crt" && -f "$CERT_DIR/acme_domain.txt" ]]; then
        COMMON_SNI=$(cat "$CERT_DIR/acme_domain.txt" 2>/dev/null)
        echo -e ">>> 🌐 检测到 ACME 证书，自动接管全协议域名: ${green}$COMMON_SNI${plain}"
    else
        echo -e ">>> ⚠️ 未部署真实证书，已降级为量子自签与默认伪装: ${green}$COMMON_SNI${plain}"
    fi

    # 3. 彻底核爆清空历史数据
    > "$LINK_FILE"
    echo '{"log":{"level":"info","timestamp":true},"inbounds":[],"outbounds":[{"type":"direct","tag":"direct"},{"type":"block","tag":"block"}]}' | jq . > "$JSON_FILE"

    # 4. 极速压入节点 (全部自动调用顶部的 $TEMP_UUID 和 $TEMP_PASS)
    echo -e "\n${yellow}>>> [1/5] 正在极速压入 VLESS-Reality...${plain}"
    local P1=$(shuf -i 10000-60000 -n 1); local U1=$TEMP_UUID; local K1=$($BIN_FILE generate reality-keypair); local PR1=$(echo "$K1" | awk '/PrivateKey/ {print $2}' | tr -d '\r\n'); local PU1=$(echo "$K1" | awk '/PublicKey/ {print $2}' | tr -d '\r\n'); local S1=$($BIN_FILE generate rand --hex 8 | tr -d '\r\n')
    jq --argjson p "$P1" --arg u "$U1" --arg sni "apple.com" --arg pr "$PR1" --arg sid "$S1" '.inbounds += [{"type":"vless","tag":"vless-in","listen":"::","listen_port":$p,"users":[{"uuid":$u,"flow":"xtls-rprx-vision"}],"tls":{"enabled":true,"server_name":$sni,"reality":{"enabled":true,"handshake":{"server":$sni,"server_port":443},"private_key":$pr,"short_id":[$sid]}}}]' "$JSON_FILE" > /tmp/vx.json && mv /tmp/vx.json "$JSON_FILE"
    echo "vless://${U1}@${SERVER_IP}:${P1}?encryption=none&flow=xtls-rprx-vision&security=reality&sni=apple.com&fp=chrome&pbk=${PU1}&sid=${S1}&type=tcp&headerType=none#VLESS-Reality-VeloX" >> "$LINK_FILE"

    echo -e "${yellow}>>> [2/5] 正在极速压入 Hysteria2...${plain}"
    local P2=$(shuf -i 10000-60000 -n 1); local PW2=$TEMP_PASS; generate_cert_dynamic "$COMMON_SNI" >/dev/null 2>&1
    jq --argjson p "$P2" --arg pw "$PW2" --arg crt "$CERT_DIR/cert.crt" --arg key "$CERT_DIR/private.key" '.inbounds += [{"type":"hysteria2","tag":"hy2-in","listen":"::","listen_port":$p,"users":[{"password":$pw}],"tls":{"enabled":true,"alpn":["h3"],"certificate_path":$crt,"key_path":$key}}]' "$JSON_FILE" > /tmp/vx.json && mv /tmp/vx.json "$JSON_FILE"
    echo "hysteria2://${PW2}@${SERVER_IP}:${P2}/?sni=${COMMON_SNI}&alpn=h3&insecure=1#Hys2-VeloX" >> "$LINK_FILE"

    echo -e "${yellow}>>> [3/5] 正在极速压入 TUIC v5...${plain}"
    local P3=$(shuf -i 10000-60000 -n 1); local U3=$TEMP_UUID; local PW3=$TEMP_PASS
    jq --argjson p "$P3" --arg u "$U3" --arg pw "$PW3" --arg crt "$CERT_DIR/cert.crt" --arg key "$CERT_DIR/private.key" '.inbounds += [{"type":"tuic","tag":"tuic-in","listen":"::","listen_port":$p,"users":[{"uuid":$u,"password":$pw}],"congestion_control":"bbr","tls":{"enabled":true,"alpn":["h3"],"certificate_path":$crt,"key_path":$key}}]' "$JSON_FILE" > /tmp/vx.json && mv /tmp/vx.json "$JSON_FILE"
    echo "tuic://${U3}:${PW3}@${SERVER_IP}:${P3}/?sni=${COMMON_SNI}&alpn=h3&congestion_control=bbr&insecure=1#TUIC-VeloX" >> "$LINK_FILE"

    echo -e "${yellow}>>> [4/5] 正在极速压入 VMess-WS...${plain}"
    local P4=$(shuf -i 10000-60000 -n 1); local U4=$TEMP_UUID; local W4="/vx-$(tr -dc 'a-z0-9' </dev/urandom | head -c 6)"
    jq --argjson p "$P4" --arg u "$U4" --arg w "$W4" '.inbounds += [{"type":"vmess","tag":"vmess-in","listen":"::","listen_port":$p,"users":[{"uuid":$u,"alterId":0}],"transport":{"type":"ws","path":$w}}]' "$JSON_FILE" > /tmp/vx.json && mv /tmp/vx.json "$JSON_FILE"
    local VM_J=$(jq -n -c --arg v "2" --arg ps "VMess-WS-VeloX" --arg add "$SERVER_IP" --arg port "$P4" --arg id "$U4" --arg net "ws" --arg host "" --arg path "$W4" --arg tls "" --arg sni "" '{v:$v, ps:$ps, add:$add, port:$port, id:$id, aid:"0", scy:"auto", net:$net, type:"none", host:$host, path:$path, tls:$tls, sni:$sni}')
    echo "vmess://$(echo -n "$VM_J" | base64 -w 0)" >> "$LINK_FILE"

    echo -e "${yellow}>>> [5/5] 正在极速压入 Trojan-Reality...${plain}"
    local P5=$(shuf -i 10000-60000 -n 1); local PW5=$TEMP_PASS; local K5=$($BIN_FILE generate reality-keypair); local PR5=$(echo "$K5" | awk '/PrivateKey/ {print $2}' | tr -d '\r\n'); local PU5=$(echo "$K5" | awk '/PublicKey/ {print $2}' | tr -d '\r\n'); local S5=$($BIN_FILE generate rand --hex 8 | tr -d '\r\n')
    jq --argjson p "$P5" --arg pw "$PW5" --arg sni "apple.com" --arg pr "$PR5" --arg sid "$S5" '.inbounds += [{"type":"trojan","tag":"trojan-in","listen":"::","listen_port":$p,"users":[{"password":$pw}],"tls":{"enabled":true,"server_name":$sni,"reality":{"enabled":true,"handshake":{"server":$sni,"server_port":443},"private_key":$pr,"short_id":[$sid]}}}]' "$JSON_FILE" > /tmp/vx.json && mv /tmp/vx.json "$JSON_FILE"
    echo "trojan://${PW5}@${SERVER_IP}:${P5}?security=reality&sni=apple.com&fp=chrome&pbk=${PU5}&sid=${S5}&type=tcp&headerType=none#Trojan-Reality-VeloX" >> "$LINK_FILE"

    systemctl restart vx-core.service
    echo -e "\n${green}✅ 大满贯全量装载完成！五大神级协议已全部就绪！${plain}"
    echo -e "👉 ${yellow}提示: 请按回车返回主菜单，直接按【8】提取所有节点链接！${plain}"
    read -p ""
}


# ==================================================
# ⚡ 底层调优: BBR 狂暴网络加速
# ==================================================
function enable_bbr() {
    clear
    echo -e "${cyan}======================================================================${plain}"
    echo -e "               ⚡ 开启 BBR 底层网络狂暴加速 ⚡"
    echo -e "${cyan}======================================================================${plain}"
    
    # 检查内核是否已开启 BBR
    if sysctl net.ipv4.tcp_congestion_control | grep -q bbr; then
        echo -e "\n${green}✅ 检测到 BBR 加速已处于开启状态，无需重复配置！${plain}"
        read -p "👉 按回车返回大屏..." && return
    fi

    echo -e "${yellow}>>> 正在向系统内核注入 BBR 狂暴参数...${plain}"
    # 清理可能存在的旧配置
    sed -i '/net.core.default_qdisc/d' /etc/sysctl.conf
    sed -i '/net.ipv4.tcp_congestion_control/d' /etc/sysctl.conf
    
    # 写入新参数
    echo "net.core.default_qdisc=fq" >> /etc/sysctl.conf
    echo "net.ipv4.tcp_congestion_control=bbr" >> /etc/sysctl.conf
    
    # 应用生效
    sysctl -p >/dev/null 2>&1

    # 验证是否成功
    if sysctl net.ipv4.tcp_congestion_control | grep -q bbr; then
        echo -e "\n${green}✅ BBR 底层加速已成功激活！你的节点速度将获得质的飞跃！${plain}"
    else
        echo -e "\n${red}❌ BBR 激活失败，可能是当前系统的精简版内核不支持。${plain}"
    fi
    read -p "👉 按回车返回大屏..."
}


# ==================================================
# 🛡️ 附加挂载: WARP 智能优选解锁 (流媒体/AI 专线)
# ==================================================
function enable_warp() {
    clear
    echo -e "${cyan}======================================================================${plain}"
    echo -e "         🛡️ 部署 Cloudflare WARP 官方客户端 (安全 SOCKS5 分流模式)"
    echo -e "${cyan}======================================================================${plain}"

    # 1. 安全安装官方客户端
    if ! command -v warp-cli &> /dev/null; then
        echo -e "${yellow}>>> [1/4] 正在安全拉取 Cloudflare 官方组件 (不影响系统网络)...${plain}"
        apt-get update -y >/dev/null 2>&1
        apt-get install -y curl gnupg lsb-release >/dev/null 2>&1
        curl -fsSL https://pkg.cloudflareclient.com/pubkey.gpg | sudo gpg --yes --dearmor --output /usr/share/keyrings/cloudflare-warp-archive-keyring.gpg
        echo "deb [signed-by=/usr/share/keyrings/cloudflare-warp-archive-keyring.gpg] https://pkg.cloudflareclient.com/ $(lsb_release -cs) main" | sudo tee /etc/apt/sources.list.d/cloudflare-client.list >/dev/null
        apt-get update -y >/dev/null 2>&1
        apt-get install cloudflare-warp -y >/dev/null 2>&1
    else
        echo -e "${green}✅ WARP 客户端已存在，跳过安装。${plain}"
    fi

    # 2. 隔离化配置 (绝对防失联)
    echo -e "${yellow}>>> [2/4] 正在建立本地 SOCKS5 安全隔离隧道...${plain}"
    # 强制设置为 Proxy 模式，绝对不碰系统全局路由
    warp-cli --accept-tos registration new >/dev/null 2>&1 || warp-cli registration new >/dev/null 2>&1
    warp-cli --accept-tos mode proxy >/dev/null 2>&1 || warp-cli mode proxy >/dev/null 2>&1
    warp-cli --accept-tos proxy port 40000 >/dev/null 2>&1 || warp-cli proxy port 40000 >/dev/null 2>&1
    warp-cli --accept-tos connect >/dev/null 2>&1 || warp-cli connect >/dev/null 2>&1
    
    echo -e ">>> 正在等待隧道连通，请稍候 5 秒..."
    sleep 5

    if curl -sx socks5h://127.0.0.1:40000 https://www.cloudflare.com/cdn-cgi/trace | grep -q "warp="; then
        echo -e "${green}✅ WARP 隔离通道建立成功！(本地监听端口: 40000)${plain}"
    else
        echo -e "${red}❌ WARP 通道建立失败！这可能是由于当前 VPS 架构受限 (如部分 LXC/OpenVZ 架构)。${plain}"
        echo -e "${yellow}提示: 不影响核心节点运行，按回车返回大屏...${plain}"
        read -p "" && return
    fi

    # 3. 注入 Sing-box 神经元路由
    echo -e "${yellow}>>> [3/4] 正在向 Sing-box 注入 AI 与流媒体精准分流规则...${plain}"

    # 确保 route 结构存在
    if ! jq -e '.route' "$JSON_FILE" >/dev/null; then
        jq '. += {"route": {"rules": []}}' "$JSON_FILE" > /tmp/vx.json && mv /tmp/vx.json "$JSON_FILE"
    fi

    # 清理历史规则
    jq 'del(.outbounds[] | select(.tag == "warp-socks")) | del(.route.rules[] | select(.outbound == "warp-socks"))' "$JSON_FILE" > /tmp/vx.json && mv /tmp/vx.json "$JSON_FILE"

    # 挂载 SOCKS5 出口
    jq '.outbounds += [{"type":"socks","tag":"warp-socks","server":"127.0.0.1","server_port":40000}]' "$JSON_FILE" > /tmp/vx.json && mv /tmp/vx.json "$JSON_FILE"

    # 核心分流规则：收录全网最严苛的流媒体与 AI 域名
    # 包括: ChatGPT, Claude, Gemini, Netflix, Disney+, Spotify, Hulu, HBO 等
    jq '.route.rules += [{"domain_suffix":["openai.com","chatgpt.com","ai.com","anthropic.com","claude.ai","gemini.google.com","netflix.com","netflix.net","nflximg.net","nflxvideo.net","nflxext.com","disneyplus.com","dssott.com","spotify.com","hulu.com","hbomax.com","max.com"],"outbound":"warp-socks"}]' "$JSON_FILE" > /tmp/vx.json && mv /tmp/vx.json "$JSON_FILE"

    # 4. 重启生效
    echo -e "${yellow}>>> [4/4] 正在重启引擎，激活无缝解锁矩阵...${plain}"
    systemctl restart vx-core.service

    echo -e "\n${green}🎉 WARP 智能分流部署完美竣工！${plain}"
    echo -e "${cyan}💡 开源提示: 此方案为应用层分流，绝对不会导致您的 VPS 断网或失联，请放心使用！${plain}"
    read -p "👉 按回车返回大屏..."
}


# ==================================================
# ☁️ 终极保命: Cloudflare Argo 隧道挂载 (开源防呆版)
# ==================================================
function enable_argo() {
    clear
    echo -e "${cyan}======================================================================${plain}"
    echo -e "           ☁️ 部署 Cloudflare Argo 隧道 (VMess-WS 复活甲)"
    echo -e "${cyan}======================================================================${plain}"

    # 1. 提取底层 VMess 核心参数
    local VMESS_PORT=$(jq -r '.inbounds[] | select(.tag == "vmess-in") | .listen_port' "$JSON_FILE" 2>/dev/null)
    local VMESS_PATH=$(jq -r '.inbounds[] | select(.tag == "vmess-in") | .transport.path' "$JSON_FILE" 2>/dev/null)
    local VMESS_UUID=$(jq -r '.inbounds[] | select(.tag == "vmess-in") | .users[0].uuid' "$JSON_FILE" 2>/dev/null)

    if [[ -z "$VMESS_PORT" || "$VMESS_PORT" == "null" ]]; then
        echo -e "${red}❌ 未检测到 VMess-WS 节点！Argo 必须依托 VMess 才能运行，请先部署大满贯！${plain}"
        read -p "👉 按回车返回大屏..." && return
    fi

    # 2. 安装官方 Cloudflared 核心
    if ! command -v cloudflared &> /dev/null; then
        echo -e "${yellow}>>> [1/4] 正在拉取 Cloudflare Argo 官方核心组件...${plain}"
        wget -q https://github.com/cloudflare/cloudflared/releases/latest/download/cloudflared-linux-amd64 -O /usr/local/bin/cloudflared
        chmod +x /usr/local/bin/cloudflared
    fi

    # 3. 智能双轨制选择 (小白 vs 极客)
    echo -e "\n${yellow}>>> [2/4] 请选择 Argo 隧道运行模式：${plain}"
    echo -e "  ${purple}1.${plain} 临时穿透模式 (系统自动分配随机域名，免配置，小白首选)"
    echo -e "  ${green}2.${plain} 固定保活模式 (需配置 CF Zero Trust，绑定自有域名，极客推荐)"
    echo ""
    read -p "👉 请选择 [1/2] (直接回车默认选 1): " ARGO_MODE
    ARGO_MODE=${ARGO_MODE:-1}

    local ARGO_DOMAIN=""

    if [[ "$ARGO_MODE" == "2" ]]; then
        # ⚠️ 给开源用户的保姆级教程 UI ⚠️
        clear
        echo -e "${cyan}======================================================================${plain}"
        echo -e "          🛡️ CF Zero Trust 固定隧道配置指南 (保姆级教程)"
        echo -e "${cyan}======================================================================${plain}"
        echo -e "如果您是第一次配置，请严格按照以下步骤在 Cloudflare 官网操作："
        echo -e "1. 登录 CF 后台 -> 进入 Zero Trust -> Networks -> Tunnels"
        echo -e "2. 点击 Create a tunnel -> 选择 Cloudflared -> 随便起个隧道名字"
        echo -e "3. 页面会给出一串安装命令，请复制紧跟在 ${green}--token${plain} 后面的那串超长字符！"
        echo -e "4. 点击 Next，在 Public Hostname 页面设置："
        echo -e "   - Subdomain/Domain: 填您想绑定的域名 (例如: argo.yourdomain.com)"
        echo -e "   - Service Type: ${green}HTTP${plain}"
        echo -e "   - URL: ${green}127.0.0.1:${VMESS_PORT}${plain}  <-- (极其重要，请直接复制此地址)"
        echo -e "${cyan}======================================================================${plain}"
        echo -e "${yellow}提示: 如果您还没准备好，直接按回车键即可安全退出。${plain}\n"

        read -p "👉 请粘贴您的 Cloudflare Tunnel Token: " ARGO_TOKEN
        if [[ -z "$ARGO_TOKEN" ]]; then
            echo -e "\n${red}已取消操作，安全返回主界面。${plain}"
            sleep 1
            return
        fi

        read -p "👉 请输入您刚才在 CF 后台绑定的固定域名 (如 argo.xxx.com): " ARGO_DOMAIN
        if [[ -z "$ARGO_DOMAIN" ]]; then
            echo -e "\n${red}❌ 域名不能为空，操作已取消！${plain}"
            sleep 1
            return
        fi

        echo -e "\n${yellow}>>> [3/4] 正在将 Token 注入系统守护进程...${plain}"
        cat <<EOF > /etc/systemd/system/vx-argo.service
[Unit]
Description=Cloudflare Argo Tunnel (Fixed Token) for VeloX
After=network.target

[Service]
Type=simple
ExecStart=/usr/local/bin/cloudflared tunnel run --token $ARGO_TOKEN
Restart=on-failure
RestartSec=5

[Install]
WantedBy=multi-user.target
EOF

    else
        echo -e "\n${yellow}>>> [3/4] 正在建立临时反向地下隧道...${plain}"
        cat <<EOF > /etc/systemd/system/vx-argo.service
[Unit]
Description=Cloudflare Argo Tunnel (Temp) for VeloX
After=network.target

[Service]
Type=simple
ExecStart=/usr/local/bin/cloudflared tunnel --url http://127.0.0.1:$VMESS_PORT --no-autoupdate
Restart=on-failure
RestartSec=5

[Install]
WantedBy=multi-user.target
EOF
    fi

    systemctl daemon-reload
    systemctl restart vx-argo
    systemctl enable vx-argo >/dev/null 2>&1

    # 4. 临时模式的自动化域名抓取
    if [[ "$ARGO_MODE" != "2" ]]; then
        echo -e ">>> 正在等待 CF 边缘节点下发临时域名，请耐心等待 8 秒..."
        sleep 8
        ARGO_DOMAIN=$(journalctl -u vx-argo --no-pager | grep -oE "https://[a-zA-Z0-9-]+\.trycloudflare\.com" | head -n 1 | sed 's/https:\/\///')
        
        if [[ -z "$ARGO_DOMAIN" ]]; then
            echo -e "${red}❌ 隧道域名获取失败！可能是服务器到 Cloudflare 的网络受阻。${plain}"
            read -p "👉 按回车返回大屏..." && return
        fi
    fi

    # 5. 生成终极节点链接
    echo -e "${yellow}>>> [4/4] 正在锻造 Argo 终极复活节点...${plain}"
    local VM_J=$(jq -n -c --arg v "2" --arg ps "VMess-Argo-复活甲🛡️" --arg add "$ARGO_DOMAIN" --arg port "443" --arg id "$VMESS_UUID" --arg net "ws" --arg host "$ARGO_DOMAIN" --arg path "$VMESS_PATH" --arg tls "tls" --arg sni "$ARGO_DOMAIN" '{v:$v, ps:$ps, add:$add, port:$port, id:$id, aid:"0", scy:"auto", net:$net, type:"none", host:$host, path:$path, tls:$tls, sni:$sni}')
    local ARGO_LINK="vmess://$(echo -n "$VM_J" | base64 -w 0)"

    # 无缝覆盖旧链接
    sed -i '/VMess-Argo-复活甲/d' "$LINK_FILE" 2>/dev/null
    echo "$ARGO_LINK" >> "$LINK_FILE"

    echo -e "\n${green}🎉 Argo 隧道挂载成功！哪怕服务器 IP 被墙，此节点依然坚挺！${plain}"
    if [[ "$ARGO_MODE" == "2" ]]; then
        echo -e "${purple}🛡️ 当前模式: 固定隧道 (Zero Trust)${plain}"
    else
        echo -e "${purple}⏱️ 当前模式: 临时穿透 (trycloudflare)${plain}"
    fi
    echo -e "${cyan}🌐 专属防御域名: ${plain}${green}${ARGO_DOMAIN}${plain}"
    read -p "👉 按回车返回大屏，按【8】即可提取这个复活甲节点..."
}


# ==================================================
# 🔄 OTA 热更新引擎: 脚本与内核双轨升级
# ==================================================
function update_ota() {
    clear
    echo -e "${cyan}======================================================================${plain}"
    echo -e "            🔄 VeloX OTA 智能热更新引擎"
    echo -e "${cyan}======================================================================${plain}"

    # --- 1. 更新面板脚本自身 ---
    echo -e "${yellow}>>> [1/2] 正在检测面板脚本更新...${plain}"
    curl -sL "$SCRIPT_URL" -o /tmp/vx_new.sh
    if [[ -f /tmp/vx_new.sh && -s /tmp/vx_new.sh ]]; then
        mv /tmp/vx_new.sh /usr/local/bin/vx
        chmod +x /usr/local/bin/vx
        echo -e "${green}✅ 面板脚本已同步至 GitHub 最新版本！${plain}"
    else
        echo -e "${red}❌ 脚本拉取失败，请检查网络！${plain}"
    fi

    # --- 2. 更新 Sing-box 核心 ---
    echo -e "\n${yellow}>>> [2/2] 正在检测 Sing-box 核心版本...${plain}"
    
    # 获取本地版本
    local CURRENT_VER=$($BIN_FILE version 2>/dev/null | grep "version" | awk '{print $3}')
    if [[ -z "$CURRENT_VER" ]]; then
        CURRENT_VER="未知"
    fi

    # 获取远端最新版本 (解析 GitHub API)
    local LATEST_VER=$(curl -s "https://api.github.com/repos/SagerNet/sing-box/releases/latest" | jq -r .tag_name | sed 's/v//g')

    if [[ -z "$LATEST_VER" || "$LATEST_VER" == "null" ]]; then
         echo -e "${red}❌ 无法获取 Sing-box 最新版本信息，可能是 GitHub API 限制。${plain}"
         read -p "👉 按回车返回大屏..." && return
    fi

    echo -e "当前本地内核版本: ${purple}v${CURRENT_VER}${plain}"
    echo -e "GitHub 最新版本:  ${green}v${LATEST_VER}${plain}"

    if [[ "$CURRENT_VER" == "$LATEST_VER" ]]; then
        echo -e "\n${green}🎉 您的 Sing-box 已经是最新版本，无需更新！${plain}"
    else
        echo -e "\n${yellow}💡 发现新版本，正在为您热更新核心...${plain}"
        
        # 下载最新内核 (自动适配 amd64)
        local CPU_ARCH="amd64" # 假设你的 VPS 都是主流 amd64，如果需要兼容 arm，这里可以再加个判断
        local DL_URL="https://github.com/SagerNet/sing-box/releases/download/v${LATEST_VER}/sing-box-${LATEST_VER}-linux-${CPU_ARCH}.tar.gz"
        
        wget -q "$DL_URL" -O /tmp/sing-box.tar.gz
        if [[ -f /tmp/sing-box.tar.gz ]]; then
            tar -xzf /tmp/sing-box.tar.gz -C /tmp
            # 停止服务，替换二进制，重启服务
            systemctl stop vx-core.service
            cp /tmp/sing-box-${LATEST_VER}-linux-${CPU_ARCH}/sing-box $BIN_FILE
            chmod +x $BIN_FILE
            systemctl start vx-core.service
            
            rm -rf /tmp/sing-box*
            echo -e "${green}✅ Sing-box 核心已成功升级至 v${LATEST_VER}！服务已自动重启。${plain}"
        else
            echo -e "${red}❌ 核心下载失败！${plain}"
        fi
    fi

    echo -e "\n${cyan}======================================================================${plain}"
    echo -e "提示：若面板代码有变动，请在返回后输入 ${green}vx${plain} 重新进入以加载最新菜单。"
    read -p "👉 按回车返回大屏..."
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


function uninstall_vne() {
    echo -e "${yellow}>>> 正在执行终极粉碎协议...${plain}"
    systemctl stop vx-core.service vx-argo.service >/dev/null 2>&1
    systemctl disable vx-core.service vx-argo.service >/dev/null 2>&1
    
    # 彻底删除核心目录、守护进程文件、快捷指令
    rm -rf $CONF_DIR $BIN_FILE $SERVICE_FILE /etc/systemd/system/vx-argo.service /usr/local/bin/vx
    
    systemctl daemon-reload
    echo -e "${green}✅ VX 核心、各协议节点、Argo 隧道守护进程已彻底挫骨扬灰！${plain}"
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
    echo -e "  ${green}b.${plain} ⚡ 底层调优: BBR 狂暴网络加速"
    echo -e "  ${green}w.${plain} 🛡️ 附加挂载: WARP 优选解锁 (Netflix/ChatGPT 等)"
    echo -e "  ${purple}a.${plain} ☁️ 附加挂载: Argo 隧道防封复活甲 (基于 VMess)"
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
        b|B) enable_bbr ;;
        w|W) enable_warp ;;
        a|A) enable_argo ;;
        8) export_all_nodes; read -p "👉 提取完毕，按回车返回..." ;;
        9) update_ota ;;
        10) uninstall_vne; read -p "👉 按回车退出..."; break ;;
        0) break ;;
        *) echo -e "${red}❌ 无效输入！${plain}"; sleep 1 ;;
    esac
done
