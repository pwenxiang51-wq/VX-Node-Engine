#!/bin/bash
# =======================================================
# 项目: Velox Node Engine (VX) - 极简高阶代理核心生成器
# 版本: V4.3.0 (大满贯完全体：五大协议全解锁 + IPv6双栈支持)
# =======================================================


export LANG=en_US.UTF-8
set -euo pipefail
# === 🛡️ 零依赖原子 JSON 写入引擎 (10/10 满分防写死) ===
atomic_jq() {
    local tmp="${JSON_FILE}.tmp"
    cat > "$tmp"
    if jq . "$tmp" >/dev/null 2>&1; then
        mv -f "$tmp" "$JSON_FILE"
    else
        echo -e "${red}❌ 致命错误: JSON 格式非法，已自动回滚！${plain}"
        rm -f "$tmp" && return 1
    fi
}

red='\033[0;31m'; green='\033[0;32m'; yellow='\033[0;33m'; cyan='\033[0;36m'; blue='\033[0;34m'; purple='\033[0;35m'; plain='\033[0m'

CONF_DIR="/etc/velox_vne"
CERT_DIR="$CONF_DIR/cert"
BIN_FILE="/usr/local/bin/sing-box"
JSON_FILE="$CONF_DIR/config.json"
LINK_FILE="$CONF_DIR/links.txt"
SERVICE_FILE="/etc/systemd/system/vx-core.service"
SCRIPT_URL="https://raw.githubusercontent.com/pwenxiang51-wq/VX-Node-Engine/main/vx.sh"
VX_VERSION="4.3.1"
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

    # --- 拓展功能状态探测 ---
    ACME_STAT="${red}未部署 ❌${plain}"
    if [[ -f "$CERT_DIR/acme.crt" ]]; then
        ACME_DOMAIN=$(cat "$CERT_DIR/acme_domain.txt" 2>/dev/null)
        ACME_STAT="${green}已部署 ✅${plain} [${purple}${ACME_DOMAIN}${plain}]"
    fi

 WARP_STAT="${red}未开启 ❌${plain}"
if [[ -f "$JSON_FILE" ]] && jq -e '.outbounds[] | select(.tag == "warp-socks")' "$JSON_FILE" >/dev/null 2>&1; then
    # === 🚀 触发物理探针：极速获取 WARP 真实 IP (超时 1.5 秒防卡死) ===
    WARP_CHECK_IP=$(curl -s --max-time 1.5 -x socks5h://127.0.0.1:40000 ipinfo.io/ip 2>/dev/null)
    if [[ -n "$WARP_CHECK_IP" ]]; then
        WARP_STAT="${green}已激活 ✅${plain} (SOCKS5 分流解锁) ${cyan}➡️ [IP: ${WARP_CHECK_IP}]${plain}"
    else
        WARP_STAT="${green}已激活 ✅${plain} (SOCKS5 分流解锁) ${red}➡️ [IP获取超时/连接异常]${plain}"
    fi
fi

    ARGO_STAT="${red}未开启 ❌${plain}"
    if systemctl is-active --quiet vx-argo.service 2>/dev/null; then
        ARGO_STAT="${green}运行中 ✅${plain} (VMess 穿透保活)"
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
            VM_STAT="${green}[开启]${plain}"; VM_PORT=$(jq -r '.inbounds[] | select(.tag == "vmess-in") | .listen_port' "$JSON_FILE"); VM_SNI=$(jq -r '.inbounds[] | select(.tag == "vmess-in") | .tls.server_name' "$JSON_FILE" | sed 's/null/CDN直连/g')
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
    echo -e "       🚀 Velox Node Engine (VX) 终极控制枢纽 V${VX_VERSION} 🚀        "
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
    echo -e "🧩  ${yellow}高级拓展矩阵:${plain}"
    echo -e "   ACME 证书: $ACME_STAT"
    echo -e "   WARP 解锁: $WARP_STAT"
    echo -e "   Argo 隧道: $ARGO_STAT"
    echo -e "----------------------------------------------------------------------"
    echo -e "🛡️  ${yellow}代理引擎矩阵 (Sing-box 状态: $SB_STAT):${plain}"
    echo -e "   $VL_STAT VLESS-Reality | 端口: ${cyan}$VL_PORT${plain} | 伪装: ${purple}$VL_SNI${plain}"
    echo -e "   $HY2_STAT Hysteria-2    | 端口: ${cyan}$HY2_PORT${plain} | 证书: ${purple}$HY2_SNI${plain}"
    echo -e "   $TUIC_STAT TUIC v5        | 端口: ${cyan}$TUIC_PORT${plain} | 证书: ${purple}$TUIC_SNI${plain}"
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
    # === 🚀 自动化环境自检：补全所有极客组件 ===
    local NEED_PACKAGES=(jq qrencode curl wget openssl tar)
    local MISSING_PACKAGES=()
    for pkg in "${NEED_PACKAGES[@]}"; do
        if ! command -v "$pkg" &>/dev/null; then MISSING_PACKAGES+=("$pkg"); fi
    done

    if [ ${#MISSING_PACKAGES[@]} -gt 0 ]; then
        echo -e "${cyan}>>> 正在全自动补全系统依赖 (${MISSING_PACKAGES[*]})...${plain}"
        [[ -f /etc/os-release ]] && source /etc/os-release
        if [[ "$ID" == "debian" || "$ID" == "ubuntu" ]]; then
            apt-get update -y >/dev/null 2>&1 && apt-get install -y "${MISSING_PACKAGES[@]}" >/dev/null 2>&1
        else
            yum install -y epel-release >/dev/null 2>&1 && yum install -y "${MISSING_PACKAGES[@]}" >/dev/null 2>&1
        fi
    fi
}

# --- 智能防火墙破壁者 (全平台极致兼容适配版) ---
function open_port() {
    local PORT=$1
    # 1. 尝试 UFW (Ubuntu/Debian 常见)
    if command -v ufw &> /dev/null; then
        ufw allow $PORT/tcp >/dev/null 2>&1
        ufw allow $PORT/udp >/dev/null 2>&1
    fi
    # 2. 尝试 Firewalld (CentOS/RHEL 常见)
    if command -v firewall-cmd &> /dev/null; then
        firewall-cmd --zone=public --add-port=$PORT/tcp --permanent >/dev/null 2>&1
        firewall-cmd --zone=public --add-port=$PORT/udp --permanent >/dev/null 2>&1
        firewall-cmd --reload >/dev/null 2>&1
    fi
    # 3. 兜底方案：原生 iptables (跨平台通用)
    if command -v iptables &> /dev/null; then
        iptables -I INPUT -p tcp --dport $PORT -j ACCEPT >/dev/null 2>&1
        iptables -I INPUT -p udp --dport $PORT -j ACCEPT >/dev/null 2>&1
        # 尝试保存，如果未安装保存插件也不报错，至少保证当次开机可用
        if command -v netfilter-persistent &> /dev/null; then
            netfilter-persistent save >/dev/null 2>&1
        elif command -v service &> /dev/null && [[ -f /etc/redhat-release ]]; then
            service iptables save >/dev/null 2>&1
        fi
    fi
}

function init_json() {
    if [[ ! -f "$JSON_FILE" ]]; then
         echo '{"log":{"level":"info","timestamp":true},"inbounds":[],"outbounds":[{"type":"direct","tag":"direct"},{"type":"block","tag":"block"}]}' | jq . | atomic_jq
    fi
}

function install_core() {
    if [[ ! -f "$BIN_FILE" ]]; then
        echo -e "${yellow}>>> 正在拉取 Sing-box 内核...${plain}"
        LATEST=$(curl -sL https://data.jsdelivr.com/v1/package/gh/SagerNet/sing-box | jq -r '.versions | map(select(test("alpha|beta|rc") | not)) | .[0]')
        # 🚀 [优化] 自动识别架构，支持 amd64 和 arm64 (全平台适配)
        local CPU_ARCH=$(uname -m)
        local SB_ARCH="amd64"
        [[ "$CPU_ARCH" == "aarch64" || "$CPU_ARCH" == "arm64" ]] && SB_ARCH="arm64"
        
        echo -e "${yellow}>>> 正在从官方源拉取 Sing-box v${LATEST} (${SB_ARCH})...${plain}"
        wget -qO sb.tar.gz "https://github.com/SagerNet/sing-box/releases/download/v${LATEST}/sing-box-${LATEST}-linux-${SB_ARCH}.tar.gz"
        
        # 🚀 [新增质检] 检查文件大小，防止下到空文件或 404 页面
        if [[ ! -s sb.tar.gz ]]; then
            echo -e "${red}❌ 致命错误: 内核下载失败！请检查服务器网络或 GitHub 连通性。${plain}"
            rm -f sb.tar.gz && return 1
        fi

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
            ln -sf $CERT_DIR/acme.crt $CERT_DIR/cert.crt
            ln -sf $CERT_DIR/acme.key $CERT_DIR/private.key
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
    
    # 极致防呆：增加可回车取消的提示
    read -p "👉 请输入您已解析的真实域名 (直接按回车可取消并返回): " REAL_DOMAIN
    
    if [[ -z "$REAL_DOMAIN" ]]; then
        echo -e "\n${yellow}已取消操作，安全返回主界面。${plain}"
        sleep 1.5
        return
    fi
    
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
    # 注入无感重载命令，证书续签自动重启 Sing-box (极致防呆)
    ~/.acme.sh/acme.sh --installcert -d ${REAL_DOMAIN} --fullchainpath $CERT_DIR/acme.crt --keypath $CERT_DIR/acme.key --ecc --force --reloadcmd "systemctl restart vx-core.service" >/dev/null 2>&1
    echo "${REAL_DOMAIN}" > $CERT_DIR/acme_domain.txt
    
    echo -e "\n${green}✅ ACME 真实证书部署完成！系统将自动为您管理后续的十年续签。${plain}"
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
    jq 'del(.inbounds[] | select(.tag == "vless-in"))' "$JSON_FILE" | atomic_jq
    jq '.inbounds += [input]' "$JSON_FILE" /tmp/vx_tmp.json | atomic_jq

    open_port $LISTEN_PORT
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
    jq 'del(.inbounds[] | select(.tag == "hy2-in"))' "$JSON_FILE" | atomic_jq
    jq '.inbounds += [input]' "$JSON_FILE" /tmp/vx_tmp.json | atomic_jq

    open_port $LISTEN_PORT
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
    jq 'del(.inbounds[] | select(.tag == "tuic-in"))' "$JSON_FILE" | atomic_jq
    jq '.inbounds += [input]' "$JSON_FILE" /tmp/vx_tmp.json | atomic_jq

    open_port $LISTEN_PORT
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
    jq 'del(.inbounds[] | select(.tag == "vmess-in"))' "$JSON_FILE" | atomic_jq
    jq '.inbounds += [input]' "$JSON_FILE" /tmp/vx_tmp.json | atomic_jq

    open_port $LISTEN_PORT
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
    read -p "👉 节点密码 (直接回车随机): " TROJAN_PASS; TROJAN_PASS=${TROJAN_PASS:-$TEMP_PASS}
    read -p "👉 伪装域名 (直接回车默认 apple.com): " SNI_DOMAIN; SNI_DOMAIN=${SNI_DOMAIN:-"apple.com"}

    KEYS=$($BIN_FILE generate reality-keypair)
    PRV_KEY=$(echo "$KEYS" | awk '/PrivateKey/ {print $2}' | tr -d '\r\n')
    PUB_KEY=$(echo "$KEYS" | awk '/PublicKey/ {print $2}' | tr -d '\r\n')
    SHORT_ID=$($BIN_FILE generate rand --hex 8 | tr -d '\r\n')

    cat << EOF > /tmp/vx_tmp.json
{"type":"trojan","tag":"trojan-in","listen":"::","listen_port":$LISTEN_PORT,"users":[{"password":"$TROJAN_PASS"}],"tls":{"enabled":true,"server_name":"$SNI_DOMAIN","reality":{"enabled":true,"handshake":{"server":"$SNI_DOMAIN","server_port":443},"private_key":"$PRV_KEY","short_id":["$SHORT_ID"]}}}
EOF
    jq 'del(.inbounds[] | select(.tag == "trojan-in"))' "$JSON_FILE" | atomic_jq
    jq '.inbounds += [input]' "$JSON_FILE" /tmp/vx_tmp.json | atomic_jq

    open_port $LISTEN_PORT
    systemctl restart vx-core.service

    SHARE="trojan://${TROJAN_PASS}@${SERVER_IP}:${LISTEN_PORT}?security=reality&sni=${SNI_DOMAIN}&fp=chrome&pbk=${PUB_KEY}&sid=${SHORT_ID}&type=tcp&headerType=none#Trojan-Reality-VeloX"
    sed -i '/^trojan:\/\//d' "$LINK_FILE" 2>/dev/null
    echo "$SHARE" >> "$LINK_FILE"
    echo -e "\n${green}✅ Trojan-Reality 装载完成！${plain}"; echo -e "👉 ${yellow}提示: 请返回主菜单，按【8】提取节点链接！${plain}"
}


# --- 🚀 终极杀器：一键大满贯全协议装载 (防冲突优化版) ---
function install_all_nodes() {
    check_sys && install_core && init_json && get_smart_ip
    clear
    echo -e "${cyan}======================================================================${plain}"
    echo -e "         🚀 正在启动【大满贯】全协议一键全自动装载引擎 🚀"
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

    # 2. 智能域名与证书准备
    local COMMON_SNI="apple.com"
    if [[ -f "$CERT_DIR/acme.crt" && -f "$CERT_DIR/acme_domain.txt" ]]; then
        COMMON_SNI=$(cat "$CERT_DIR/acme_domain.txt" 2>/dev/null)
        echo -e ">>> 🌐 检测到 ACME 证书，自动接管全协议域名: ${green}$COMMON_SNI${plain}"
    else
        echo -e ">>> ⚠️ 未部署真实证书，已降级为量子自签与默认伪装: ${green}$COMMON_SNI${plain}"
    fi

    # 统一提前调用一次证书生成逻辑（真实/自签），避免后续重复调用或遗漏
    generate_cert_dynamic "$COMMON_SNI" >/dev/null 2>&1

   # 3. 彻底核爆清空历史数据
    > "$LINK_FILE"
    echo '{"log":{"level":"info","timestamp":true},"inbounds":[],"outbounds":[{"type":"direct","tag":"direct"},{"type":"block","tag":"block"}]}' | jq . | atomic_jq

    # 4. 端口隔离生成池：确保大满贯五协议端口绝对不冲突！
    local BASE_PORTS=($(shuf -i 10000-50000 -n 5 | sort -u))
    # 极低概率下如果 sort -u 导致数量不够 5 个，这里做一个强补救
    while [ ${#BASE_PORTS[@]} -lt 5 ]; do
        BASE_PORTS+=($(shuf -i 50001-60000 -n 1))
        BASE_PORTS=($(printf "%s\n" "${BASE_PORTS[@]}" | sort -u))
    done
    local P1=${BASE_PORTS[0]}
    local P2=${BASE_PORTS[1]}
    local P3=${BASE_PORTS[2]}
    local P4=${BASE_PORTS[3]}
    local P5=${BASE_PORTS[4]}

    # 5. 极速压入节点
    echo -e "\n${yellow}>>> [1/5] 正在极速压入 VLESS-Reality...${plain}"
    local U1=$TEMP_UUID; local K1=$($BIN_FILE generate reality-keypair); local PR1=$(echo "$K1" | awk '/PrivateKey/ {print $2}' | tr -d '\r\n'); local PU1=$(echo "$K1" | awk '/PublicKey/ {print $2}' | tr -d '\r\n'); local S1=$($BIN_FILE generate rand --hex 8 | tr -d '\r\n')
    jq --argjson p "$P1" --arg u "$U1" --arg sni "apple.com" --arg pr "$PR1" --arg sid "$S1" '.inbounds += [{"type":"vless","tag":"vless-in","listen":"::","listen_port":$p,"users":[{"uuid":$u,"flow":"xtls-rprx-vision"}],"tls":{"enabled":true,"server_name":$sni,"reality":{"enabled":true,"handshake":{"server":$sni,"server_port":443},"private_key":$pr,"short_id":[$sid]}}}]' "$JSON_FILE" | atomic_jq
    echo "vless://${U1}@${SERVER_IP}:${P1}?encryption=none&flow=xtls-rprx-vision&security=reality&sni=apple.com&fp=chrome&pbk=${PU1}&sid=${S1}&type=tcp&headerType=none#VLESS-Reality-VeloX" >> "$LINK_FILE"
    open_port $P1

    echo -e "${yellow}>>> [2/5] 正在极速压入 Hysteria2...${plain}"
    local PW2=$TEMP_PASS
    jq --argjson p "$P2" --arg pw "$PW2" --arg crt "$CERT_DIR/cert.crt" --arg key "$CERT_DIR/private.key" '.inbounds += [{"type":"hysteria2","tag":"hy2-in","listen":"::","listen_port":$p,"users":[{"password":$pw}],"tls":{"enabled":true,"alpn":["h3"],"certificate_path":$crt,"key_path":$key}}]' "$JSON_FILE" | atomic_jq
    echo "hysteria2://${PW2}@${SERVER_IP}:${P2}/?sni=${COMMON_SNI}&alpn=h3&insecure=1#Hys2-VeloX" >> "$LINK_FILE"
    open_port $P2

    echo -e "${yellow}>>> [3/5] 正在极速压入 TUIC v5...${plain}"
    local U3=$TEMP_UUID; local PW3=$TEMP_PASS
    jq --argjson p "$P3" --arg u "$U3" --arg pw "$PW3" --arg crt "$CERT_DIR/cert.crt" --arg key "$CERT_DIR/private.key" '.inbounds += [{"type":"tuic","tag":"tuic-in","listen":"::","listen_port":$p,"users":[{"uuid":$u,"password":$pw}],"congestion_control":"bbr","tls":{"enabled":true,"alpn":["h3"],"certificate_path":$crt,"key_path":$key}}]' "$JSON_FILE" | atomic_jq
    echo "tuic://${U3}:${PW3}@${SERVER_IP}:${P3}/?sni=${COMMON_SNI}&alpn=h3&congestion_control=bbr&insecure=1#TUIC-VeloX" >> "$LINK_FILE"
    open_port $P3

    echo -e "${yellow}>>> [4/5] 正在极速压入 VMess-WS...${plain}"
    local U4=$TEMP_UUID; local W4="/vx-$(tr -dc 'a-z0-9' </dev/urandom | head -c 6)"
    jq --argjson p "$P4" --arg u "$U4" --arg w "$W4" '.inbounds += [{"type":"vmess","tag":"vmess-in","listen":"::","listen_port":$p,"users":[{"uuid":$u,"alterId":0}],"transport":{"type":"ws","path":$w}}]' "$JSON_FILE" | atomic_jq
    local VM_J=$(jq -n -c --arg v "2" --arg ps "VMess-WS-VeloX" --arg add "$SERVER_IP" --arg port "$P4" --arg id "$U4" --arg net "ws" --arg host "" --arg path "$W4" --arg tls "" --arg sni "" '{v:$v, ps:$ps, add:$add, port:$port, id:$id, aid:"0", scy:"auto", net:$net, type:"none", host:$host, path:$path, tls:$tls, sni:$sni}')
    echo "vmess://$(echo -n "$VM_J" | base64 -w 0)" >> "$LINK_FILE"
    open_port $P4

    echo -e "${yellow}>>> [5/5] 正在极速压入 Trojan-Reality...${plain}"
    local PW5=$TEMP_PASS; local K5=$($BIN_FILE generate reality-keypair); local PR5=$(echo "$K5" | awk '/PrivateKey/ {print $2}' | tr -d '\r\n'); local PU5=$(echo "$K5" | awk '/PublicKey/ {print $2}' | tr -d '\r\n'); local S5=$($BIN_FILE generate rand --hex 8 | tr -d '\r\n')
    jq --argjson p "$P5" --arg pw "$PW5" --arg sni "apple.com" --arg pr "$PR5" --arg sid "$S5" '.inbounds += [{"type":"trojan","tag":"trojan-in","listen":"::","listen_port":$p,"users":[{"password":$pw}],"tls":{"enabled":true,"server_name":$sni,"reality":{"enabled":true,"handshake":{"server":$sni,"server_port":443},"private_key":$pr,"short_id":[$sid]}}}]' "$JSON_FILE"| atomic_jq
    echo "trojan://${PW5}@${SERVER_IP}:${P5}?security=reality&sni=apple.com&fp=chrome&pbk=${PU5}&sid=${S5}&type=tcp&headerType=none#Trojan-Reality-VeloX" >> "$LINK_FILE"
    open_port $P5

    systemctl restart vx-core.service
    echo -e "\n${green}✅ 大满贯全量装载完成！防火墙已被打穿，五大神级协议已全部就绪！${plain}"
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
# 🛡️ 附加挂载: WARP 智能优选解锁 (支持一键开/关与 IP 探针)
# ==================================================
function enable_warp() {
    clear
    echo -e "${cyan}======================================================================${plain}"
    echo -e "         🛡️ WARP 智能优选解锁引擎 (流媒体/AI 专线) 控制中心"
    echo -e "${cyan}======================================================================${plain}"

    # 🚀 [新增逻辑] 智能状态感知：检测是否已经开启 WARP
    if jq -e '.outbounds[] | select(.tag == "warp-socks")' "$JSON_FILE" >/dev/null 2>&1; then
        echo -e "${green}>>> 系统检测：当前 WARP 智能分流已处于【运行中】状态！${plain}"
        read -p "❓ 是否要一键关闭并剥离 WARP 路由规则？(y/n) [默认 n]: " close_choice
        if [[ "$close_choice" == [Yy] ]]; then
            echo -e "${yellow}>>> 正在剥离 Sing-box 神经元路由，恢复系统原生直连...${plain}"
           jq 'del(.outbounds[] | select(.tag == "warp-socks")) | del(.route.rules[] | select(.outbound == "warp-socks"))' "$JSON_FILE" | atomic_jq
            
            if command -v warp-cli &> /dev/null; then
                warp-cli --accept-tos disconnect >/dev/null 2>&1 || warp-cli disconnect >/dev/null 2>&1
            fi
            
            systemctl restart vx-core.service
            echo -e "${green}✅ WARP 智能分流已彻底关闭，全站流量已恢复原生 IP！${plain}"
        else
            echo -e "${green}>>> 操作已取消，WARP 护盾继续为您护航。${plain}"
        fi
        read -p "👉 按回车返回大屏..."
        return
    fi

    # 🚀 下方为开启流程
    # 1. 安全安装官方客户端
    if ! command -v warp-cli &> /dev/null; then
        echo -e "${yellow}>>> [1/4] 正在安全拉取 Cloudflare 官方组件 (不影响系统网络)...${plain}"
        apt-get update -y >/dev/null 2>&1
        apt-get install -y curl gnupg lsb-release jq >/dev/null 2>&1
        curl -fsSL https://pkg.cloudflareclient.com/pubkey.gpg | sudo gpg --yes --dearmor --output /usr/share/keyrings/cloudflare-warp-archive-keyring.gpg
        echo "deb [signed-by=/usr/share/keyrings/cloudflare-warp-archive-keyring.gpg] https://pkg.cloudflareclient.com/ $(lsb_release -cs) main" | sudo tee /etc/apt/sources.list.d/cloudflare-client.list >/dev/null
        apt-get update -y >/dev/null 2>&1
        apt-get install cloudflare-warp -y >/dev/null 2>&1
    else
        echo -e "${green}✅ WARP 客户端已存在，跳过安装。${plain}"
    fi

    # 2. 隔离化配置 (绝对防失联)
    echo -e "${yellow}>>> [2/4] 正在建立本地 SOCKS5 安全隔离隧道...${plain}"
    warp-cli --accept-tos registration new >/dev/null 2>&1 || warp-cli registration new >/dev/null 2>&1
    warp-cli --accept-tos mode proxy >/dev/null 2>&1 || warp-cli mode proxy >/dev/null 2>&1
    warp-cli --accept-tos proxy port 40000 >/dev/null 2>&1 || warp-cli proxy port 40000 >/dev/null 2>&1
    warp-cli --accept-tos connect >/dev/null 2>&1 || warp-cli connect >/dev/null 2>&1
    
    echo -e ">>> 正在等待隧道连通，请稍候 5 秒..."
    sleep 5

    # 🚀 [新增逻辑] 物理探针极速抓取 IP
    WARP_IP=$(curl -s --max-time 3 -x socks5h://127.0.0.1:40000 ipinfo.io/ip 2>/dev/null)
    if [[ -n "$WARP_IP" ]]; then
        echo -e "${green}✅ WARP 隔离通道建立成功！(监听端口: 40000 | 成功套取防封 IP: ${cyan}${WARP_IP}${green})${plain}"
    else
        echo -e "${red}❌ WARP 通道建立失败或响应超时！这可能是由于当前 VPS 架构受限。${plain}"
        echo -e "${yellow}提示: 核心代理服务未受影响，按回车返回大屏...${plain}"
        read -p "" && return
    fi

    # 3. 注入 Sing-box 神经元路由
    echo -e "${yellow}>>> [3/4] 正在向 Sing-box 注入 AI 与流媒体精准分流规则...${plain}"

    # 确保 route 结构存在
    if ! jq -e '.route' "$JSON_FILE" >/dev/null; then
        jq '. += {"route": {"rules": []}}' "$JSON_FILE" | atomic_jq
    fi

    # 清理历史规则
    jq 'del(.outbounds[] | select(.tag == "warp-socks")) | del(.route.rules[] | select(.outbound == "warp-socks"))' "$JSON_FILE" | atomic_jq

    # 挂载 SOCKS5 出口
    jq '.outbounds += [{"type":"socks","tag":"warp-socks","server":"127.0.0.1","server_port":40000}]' "$JSON_FILE" | atomic_jq

    # 核心分流规则 (已修复不规范的 Spotify URL Bug)
    jq '.route.rules += [{"domain_suffix":["openai.com","chatgpt.com","ai.com","anthropic.com","claude.ai","gemini.google.com","youtube.com","youtu.be","googlevideo.com","ytimg.com","netflix.com","netflix.net","nflximg.net","nflxvideo.net","nflxext.com","disneyplus.com","dssott.com","hulu.com","hbomax.com","max.com","tiktok.com","tiktokv.com","byteoversea.com","pixiv.net","piv.app","discord.com","discord.gg","scholar.google.com","sciencedirect.com"],"outbound":"warp-socks"}]' "$JSON_FILE" | atomic_jq
    # 4. 重启生效
    echo -e "${yellow}>>> [4/4] 正在重启引擎，激活无缝解锁矩阵...${plain}"
    systemctl restart vx-core.service

    echo -e "\n${green}🎉 WARP 智能分流部署完美竣工！${plain}"
    echo -e "${cyan}💡 开源提示: 此方案为应用层分流，绝对不会导致您的 VPS 断网或失联，请放心使用！${plain}"
    read -p "👉 按回车返回大屏..."
}

# ==================================================
# ☁️ 终极保命: Cloudflare Argo 隧道挂载 (全架构无雷版)
# ==================================================
function enable_argo() {
    clear
    echo -e "${cyan}======================================================================${plain}"
    echo -e "             ☁️ Argo 隧道 (VMess-WS 复活甲) 智能控制中枢"
    echo -e "${cyan}======================================================================${plain}"

    # 🚀 智能状态感知：检测 Argo 是否已在运行
    if systemctl is-active --quiet vx-argo.service 2>/dev/null || [[ -f /etc/systemd/system/vx-argo.service ]]; then
        echo -e "${green}>>> 系统检测：当前 Argo 隧道复活甲已处于【部署/运行】状态！${plain}"
        read -p "❓ 是否要一键关闭并彻底拆除 Argo 隧道？(y/n) [默认 n]: " close_choice
        if [[ "$close_choice" == [Yy] ]]; then
            echo -e "${yellow}>>> 正在拆除 Argo 隧道并清理系统守护进程...${plain}"
            systemctl stop vx-argo >/dev/null 2>&1
            systemctl disable vx-argo >/dev/null 2>&1
            rm -f /etc/systemd/system/vx-argo.service
            systemctl daemon-reload
            
            # 智能清理遗留的节点链接
            sed -i '/VMess-Argo-复活甲/d' "$LINK_FILE" 2>/dev/null
            echo -e "${green}✅ Argo 隧道已彻底拆除，复活甲节点已从本地销毁！${plain}"
        else
            echo -e "${green}>>> 操作已取消，Argo 隧道继续为您保驾护航。${plain}"
        fi
        read -p "👉 按回车返回大屏..."
        return
    fi

    # 1. 提取底层 VMess 核心参数
    local VMESS_PORT=$(jq -r '.inbounds[] | select(.tag == "vmess-in") | .listen_port' "$JSON_FILE" 2>/dev/null)
    local VMESS_PATH=$(jq -r '.inbounds[] | select(.tag == "vmess-in") | .transport.path' "$JSON_FILE" 2>/dev/null)
    local VMESS_UUID=$(jq -r '.inbounds[] | select(.tag == "vmess-in") | .users[0].uuid' "$JSON_FILE" 2>/dev/null)

    if [[ -z "$VMESS_PORT" || "$VMESS_PORT" == "null" ]]; then
        echo -e "${red}❌ 未检测到 VMess-WS 节点！Argo 必须依托 VMess 才能运行，请先部署大满贯！${plain}"
        read -p "👉 按回车返回大屏..." && return
    fi

    # 2. 安装官方 Cloudflared 核心 (👑 核心优化：全架构智能嗅探兼容)
    if ! command -v cloudflared &> /dev/null; then
        echo -e "${yellow}>>> [1/4] 正在拉取 Cloudflare Argo 官方核心组件...${plain}"
        local CPU_ARCH=$(uname -m)
        local CF_ARCH="amd64"
        if [[ "$CPU_ARCH" == "aarch64" || "$CPU_ARCH" == "arm64" ]]; then
            CF_ARCH="arm64"
        elif [[ "$CPU_ARCH" == "x86_64" ]]; then
            CF_ARCH="amd64"
        else
            echo -e "${red}❌ 致命错误: 暂不支持当前系统架构 ($CPU_ARCH) 安装 Argo！${plain}"
            read -p "👉 按回车返回大屏..." && return
        fi
        
        wget -q "https://github.com/cloudflare/cloudflared/releases/latest/download/cloudflared-linux-${CF_ARCH}" -O /usr/local/bin/cloudflared
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
        clear
        echo -e "${cyan}======================================================================${plain}"
        echo -e "         🛡️ CF Zero Trust 固定隧道配置指南 (保姆级教程)"
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
        # 👑 核心优化：强行物理除垢，去掉所有可能的空格、换行符
        ARGO_TOKEN=$(echo "$ARGO_TOKEN" | tr -d ' ' | tr -d '\n' | tr -d '\r')
        
        if [[ -z "$ARGO_TOKEN" ]]; then
            echo -e "\n${red}已取消操作，安全返回主界面。${plain}"
            sleep 1
            return
        fi

        read -p "👉 请输入您刚才在 CF 后台绑定的固定域名 (如 argo.xxx.com): " ARGO_DOMAIN
        ARGO_DOMAIN=$(echo "$ARGO_DOMAIN" | tr -d ' ')
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
    
    # 👑 核心优化：启动后睡 2 秒，如果进程报错死掉，立刻阻断并清理现场！
    sleep 2
    if ! systemctl is-active --quiet vx-argo.service; then
        echo -e "\n${red}❌ Argo 隧道核心进程启动失败！${plain}"
        echo -e "${yellow}原因排查：Token 错误、VPS 无法连接 CF 节点，或内存严重不足。${plain}"
        systemctl stop vx-argo >/dev/null 2>&1
        rm -f /etc/systemd/system/vx-argo.service
        systemctl daemon-reload
        read -p "👉 已安全回滚，按回车返回大屏..." && return
    fi

    # 4. 临时模式的自动化域名抓取
    if [[ "$ARGO_MODE" != "2" ]]; then
        echo -e ">>> 正在等待 CF 边缘节点下发临时域名，请耐心等待 8 秒..."
        sleep 8
        ARGO_DOMAIN=$(journalctl -u vx-argo --no-pager | grep -oE "https://[a-zA-Z0-9-]+\.trycloudflare\.com" | head -n 1 | sed 's/https:\/\///')
        
        if [[ -z "$ARGO_DOMAIN" ]]; then
            echo -e "${red}❌ 隧道域名获取超时！可能是当前地区连接 trycloudflare 线路受阻。${plain}"
            systemctl stop vx-argo >/dev/null 2>&1
            rm -f /etc/systemd/system/vx-argo.service
            read -p "👉 已安全中止操作，按回车返回大屏..." && return
        fi
    fi

    # 5. 生成终极节点链接
    echo -e "${yellow}>>> [4/4] 正在锻造 Argo 终极复活节点...${plain}"
    
    local ARGO_MAGIC_ADDRESS="www.visa.com"
    
    local VM_J=$(jq -n -c \
        --arg v "2" \
        --arg ps "VMess-Argo-复活甲🛡️" \
        --arg add "$ARGO_MAGIC_ADDRESS" \
        --arg port "443" \
        --arg id "$VMESS_UUID" \
        --arg net "ws" \
        --arg host "$ARGO_DOMAIN" \
        --arg path "$VMESS_PATH" \
        --arg tls "tls" \
        --arg sni "$ARGO_DOMAIN" \
        '{v:$v, ps:$ps, add:$add, port:$port, id:$id, aid:"0", scy:"auto", net:$net, type:"none", host:$host, path:$path, tls:$tls, sni:$sni}')
        
    local ARGO_LINK="vmess://$(echo -n "$VM_J" | base64 -w 0)"

    sed -i '/VMess-Argo-复活甲/d' "$LINK_FILE" 2>/dev/null
    echo "$ARGO_LINK" >> "$LINK_FILE"

    echo -e "\n${green}🎉 Argo 隧道挂载成功！哪怕服务器 IP 被墙，此节点依然坚挺！${plain}"
    if [[ "$ARGO_MODE" == "2" ]]; then
        echo -e "${purple}🛡️ 当前模式: 固定隧道 (Zero Trust)${plain}"
    else
        echo -e "${purple}⏱️ 当前模式: 临时穿透 (trycloudflare)${plain}"
    fi
    echo -e "${cyan}🌐 专属防御域名: ${plain}${green}${ARGO_DOMAIN}${plain}"
    echo -e "${yellow}💡 极客提示: 节点已内置高通透免流 IP (www.visa.com) 以确保小白即连即用。${plain}"
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
        
        # 下载最新内核 (自动适配 amd64/arm64)
        local ARCH_RAW=$(uname -m)
        case "${ARCH_RAW}" in
            x86_64) CPU_ARCH="amd64" ;;
            aarch64) CPU_ARCH="arm64" ;;
            *) CPU_ARCH="amd64" ;;
        esac
        local DL_URL="https://github.com/SagerNet/sing-box/releases/download/v${LATEST_VER}/sing-box-${LATEST_VER}-linux-${CPU_ARCH}.tar.gz"
        
        wget -q "$DL_URL" -O /tmp/sing-box.tar.gz
        if [[ -f /tmp/sing-box.tar.gz ]]; then
            tar -xzf /tmp/sing-box.tar.gz -C /tmp
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

# ==================================================
# 🗑️ 终极自毁程序: 彻底卸载与清理 (寸草不生版)
# ==================================================
function uninstall_vne() {
    clear
    echo -e "${cyan}======================================================================${plain}"
    echo -e "             🗑️ 正在执行 Velox (VX) 引擎终极粉碎协议"
    echo -e "${cyan}======================================================================${plain}"
    
    echo -e "${yellow}⚠️ 警告: 此操作将不可逆地删除本脚本产生的所有节点、证书、隧道及配置！${plain}"
    read -p "❓ 确认要彻底卸载吗？(y/n) [默认 n]: " uninstall_choice
    if [[ "$uninstall_choice" != [Yy] ]]; then
        echo -e "${green}>>> 操作已取消，感谢继续使用！${plain}"
        return
    fi

    echo -e "${yellow}>>> [1/5] 正在终止并拆除底层守护进程...${plain}"
    systemctl stop vx-core.service vx-argo.service >/dev/null 2>&1
    systemctl disable vx-core.service vx-argo.service >/dev/null 2>&1
    rm -f $SERVICE_FILE /etc/systemd/system/vx-argo.service
    systemctl daemon-reload

    echo -e "${yellow}>>> [2/5] 正在安全剥离 WARP 与 Argo 核心组件...${plain}"
    # 彻底卸载 Cloudflare WARP
    if command -v warp-cli &> /dev/null; then
        warp-cli disconnect >/dev/null 2>&1
        if command -v apt-get &> /dev/null; then
            apt-get purge -y cloudflare-warp >/dev/null 2>&1
        else
            yum remove -y cloudflare-warp >/dev/null 2>&1
        fi
        rm -rf /var/lib/cloudflare-warp
        rm -f /etc/apt/sources.list.d/cloudflare-client.list # 斩断更新源
    fi
    # 删除 Argo (Cloudflared) 二进制文件
    rm -f /usr/local/bin/cloudflared

    echo -e "${yellow}>>> [3/5] 正在注销 ACME 证书续签任务 (防流氓驻留)...${plain}"
    if [[ -d "$HOME/.acme.sh" ]]; then
        "$HOME/.acme.sh/acme.sh" --uninstall >/dev/null 2>&1
        rm -rf "$HOME/.acme.sh"
    fi

    echo -e "${yellow}>>> [4/5] 正在还原系统网络内核 (剥离 BBR 参数)...${plain}"
    sed -i '/net.core.default_qdisc/d' /etc/sysctl.conf
    sed -i '/net.ipv4.tcp_congestion_control/d' /etc/sysctl.conf
    sysctl -w net.ipv4.tcp_congestion_control=cubic >/dev/null 2>&1
    sysctl -p >/dev/null 2>&1

    echo -e "${yellow}>>> [5/5] 正在粉碎配置数据与环境变量...${plain}"
    rm -rf $CONF_DIR
    rm -f $BIN_FILE
    rm -f /usr/local/bin/vx

    echo -e "\n${green}✅ 卸载完毕！VX 核心、各协议节点、隧道、证书、源文件已彻底挫骨扬灰！系统已恢复至出厂纯净态。${plain}"
    echo -e "${cyan}💡 山高水长，江湖再见！${plain}"
    exit 0
}

# ==================================================
# 📖 隐藏式避坑指南与面板说明
# ==================================================
function show_help() {
    clear
    echo -e "${cyan}======================================================================${plain}"
    echo -e "         📖 Velox Node Engine (VX) 使用说明与避坑指南"
    echo -e "${cyan}======================================================================${plain}"
    echo -e "${yellow}💡 1. 协议选择指南：${plain}"
    echo -e "  - ${green}VLESS-Reality${plain}: 当前最稳防封协议，免域名免证书，小白无脑首选。"
    echo -e "  - ${green}Hysteria-2${plain}: 暴力协议，专治晚高峰拥堵。需配合证书使用。"
    echo -e "  - ${green}TUIC v5${plain}: 现代级 QUIC 协议，极致抗丢包。需配合证书使用。"
    echo -e "  - ${green}VMess-WS${plain}: 纯净明文基座，主要用于套用 CDN 或者挂载 Argo 复活甲。"
    echo -e "  - ${green}Trojan-Reality${plain}: 老牌神级协议的隐身进化版，抗封锁能力极强。"
    echo -e ""
    echo -e "${red}⚠️ 2. NAT 服务器用户 (端口受限) 特别避坑提示：${plain}"
    echo -e "  如果您的 VPS 是端口受限的小鸡，${red}绝对不要使用 [7] 一键大满贯功能！${plain}"
    echo -e "  (因为大满贯采用全随机端口)。请使用 ${green}[1]-[5] 独立部署${plain}，并在提示时手动"
    echo -e "  输入您的可用端口！或者直接使用 ${purple}[a] Argo 隧道${plain}，彻底无视本地端口限制！"
    echo -e ""
    echo -e "${yellow}🛡️ 3. 附加高级功能说明：${plain}"
    echo -e "  - ${green}ACME 证书申请${plain}: 填入真实域名，申请成功后，Hys2 和 TUIC 会自动挂载。"
    echo -e "  - ${green}BBR 狂暴加速${plain}: 强烈建议所有机器开启，免费提升全局网络吞吐量。"
    echo -e "  - ${green}WARP 分流解锁${plain}: 遇到 ChatGPT 拒绝访问、Netflix 无法播放时开启。"
    echo -e "  - ${green}Argo 隧道复活甲${plain}: IP 惨遭墙杀断网时的救命稻草，套上立马满血复活！"
    echo -e "${cyan}======================================================================${plain}"
    read -p "👉 阅毕，按回车键返回主菜单..."
}

# --- 主循环入口 ---
while true; do
    show_dashboard
    echo -e "  ${cyan}1.${plain} ➕ 新增/覆写 VLESS-Reality"
    echo -e "  ${cyan}2.${plain} ➕ 新增/覆写 Hysteria2  (支持自定域名)"
    echo -e "  ${cyan}3.${plain} ➕ 新增/覆写 TUIC v5    (支持自定域名)"
    echo -e "  ${cyan}4.${plain} ➕ 新增/覆写 VMess-WS   ${yellow}[NEW✨]${plain}"
    echo -e "  ${cyan}5.${plain} ➕ 新增/覆写 Trojan-Reality ${yellow}[神级✨]${plain}"
    echo -e "----------------------------------------------------------------------"
    echo -e "  ${cyan}6.${plain} 🌍 附加挂载: Acme 真实证书极速申请"
    echo -e "  ${cyan}7.${plain} 🚀 终极大招: 一键满血装载所有协议"
    echo -e "  ${cyan}b.${plain} ⚡ 底层调优: BBR 狂暴网络加速"
    echo -e "  ${cyan}w.${plain} 🛡️ 附加挂载: WARP 优选解锁 (Netflix/ChatGPT 等)"
    echo -e "  ${cyan}a.${plain} ☁️ 附加挂载: Argo 隧道防封复活甲 (基于 VMess)"
    echo -e "----------------------------------------------------------------------"
    echo -e "  ${cyan}8.${plain} 🖨️  一键提取全节点 (明文/Base64/二维码)"
    echo -e "  ${cyan}9.${plain} 🔄 OTA 热更新引擎        ${cyan}10.${plain} 🗑️  ${red}彻底粉碎卸载${plain}"
    echo -e "  ${cyan}h.${plain} 📖 面板说明与避坑指南    ${cyan}0.${plain} 🔙 退出终端"
    echo -e "${cyan}======================================================================${plain}"
    read -p "👉 执行指令 [0-10, h/b/w/a]: " choice
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
        h|H) show_help ;;
        0) break ;;
        *) echo -e "${red}❌ 无效输入！${plain}"; sleep 1 ;;
    esac
done
