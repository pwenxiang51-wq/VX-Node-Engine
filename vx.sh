#!/bin/bash
# =======================================================
# 项目: Velox Node Engine (VX) - 极简高阶代理核心生成器
# 版本: V6.7 (10/10满分原子版：五大协议全解锁 + 智能双栈解锁)
# =======================================================


export LANG=en_US.UTF-8

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

red='\033[0;31m'; green='\033[0;32m'; yellow='\033[0;33m'; cyan='\033[0;36m'; blue='\033[0;94m'; purple='\033[0;35m'; plain='\033[0m'
CONF_DIR="/etc/velox_vne"
CERT_DIR="$CONF_DIR/cert"
BIN_FILE="/usr/local/bin/sing-box"
JSON_FILE="$CONF_DIR/config.json"
LINK_FILE="$CONF_DIR/links.txt"
SERVICE_FILE="/etc/systemd/system/vx-core.service"
SCRIPT_URL="https://raw.githubusercontent.com/pwenxiang51-wq/VX-Node-Engine/main/vx.sh"
VX_VERSION="6.7"


[[ $EUID -ne 0 ]] && echo -e "${red}❌ 致命错误: 请使用 root 用户运行此引擎！${plain}" && exit 1

# === 👇 极客权限验证中枢 (私有化拦截) 👇 ===
if [[ "$1" != "Velox" ]]; then
    clear
    echo -e "\033[0;31m======================================================\033[0m"
    echo -e "🚫 \033[0;33mFATAL ERROR: Permission Denied. (Error Code: 403)\033[0m"
    echo -e "🔒 \033[0;36mThis VeloX Engine is locked and running in PRIVATE mode.\033[0m"
    echo -e "\033[0;31m======================================================\033[0m"
    exit 1
fi
shift # 核心魔法：密码验证通过后，将密码参数丢弃，完美兼容底层的 vx log 等指令！
# === 👆 拦截中枢结束 👆 ===

if [[ ! -f "/usr/local/bin/vx" ]]; then
    curl -sL "$SCRIPT_URL" -o /usr/local/bin/vx.new >/dev/null 2>&1

if [[ ! -f "/usr/local/bin/vx" ]]; then
    curl -sL "$SCRIPT_URL" -o /usr/local/bin/vx.new >/dev/null 2>&1
    # 增加原子级拦截：文件必须大于 0 字节才覆盖，防止断网自毁
    if [[ -s "/usr/local/bin/vx.new" ]]; then
        mv -f /usr/local/bin/vx.new /usr/local/bin/vx
        chmod +x /usr/local/bin/vx
    else
        rm -f /usr/local/bin/vx.new
    fi
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
    
   # === 👇 新增：超轻量订阅引擎探测 👇 ===
    SUB_STAT="${red}未生成 ❌${plain}"
    if systemctl is-active --quiet vx-sub.service 2>/dev/null; then
        local S_PORT=$(cat "$CONF_DIR/sub_port.txt" 2>/dev/null)
        local S_PATH=$(cat "$CONF_DIR/sub_path.txt" 2>/dev/null)
        get_smart_ip
        
        # 智能探测：如果开启了 HTTPS 装甲并且有域名
        if systemctl is-active --quiet vx-sub-https.service 2>/dev/null && [[ -f "$CERT_DIR/acme_domain.txt" ]]; then
            local S_HTTPS_PORT=$(cat "$CONF_DIR/sub_port_https.txt" 2>/dev/null)
            local S_DOMAIN=$(cat "$CERT_DIR/acme_domain.txt")
            SUB_STAT="${green}运行中 ✅${plain}\n   🔗 专属订阅: ${yellow}https://${S_DOMAIN}:${S_HTTPS_PORT}/${S_PATH}/vx_sub${plain}"
        else
            SUB_STAT="${green}运行中 ✅${plain}\n   🔗 专属订阅: ${yellow}http://${SERVER_IP}:${S_PORT}/${S_PATH}/vx_sub${plain}"
        fi
    fi
    # === 👆 新增结束 👆 ===

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

  # === ☁️ Argo 隧道细分探测 ===
ARGO_STAT="${red}未开启 ❌${plain}"
if systemctl is-active --quiet vx-argo.service 2>/dev/null; then
    # 极客嗅探: 通过检查系统守护进程的启动参数，判断是固定还是临时
    if grep -q "\-\-token" /etc/systemd/system/vx-argo.service 2>/dev/null; then
        # 【固定隧道】
        # 极客注意：Token 模式默认不在本地存域名。
        # 这里假设你在部署时把域名存在了 /usr/local/etc/vx_argo_domain.txt (请根据你脚本实际保存的路径修改)
        # 如果你没存过，这行会默认显示 ZeroTrust
        FIXED_DOMAIN=$(cat /usr/local/etc/vx_argo_domain.txt 2>/dev/null || echo "ZeroTrust")
        ARGO_STAT="${green}运行中 ✅${plain} ${purple}[固定: ${FIXED_DOMAIN}]${plain}"
    else
        # 【临时隧道】
        # 探针：直接穿透 systemd 日志，从下发的原生 log 中暴力抠出 trycloudflare 域名
        TEMP_DOMAIN=$(journalctl -u vx-argo.service -n 100 --no-pager 2>/dev/null | grep -oE "https://[a-zA-Z0-9.-]+\.trycloudflare\.com" | tail -n 1 | sed 's/https:\/\///')
        
        # 防呆容错：如果刚启动还没握手成功
        [[ -z "$TEMP_DOMAIN" ]] && TEMP_DOMAIN="分配获取中..."
        
        ARGO_STAT="${green}运行中 ✅${plain} ${yellow}[临时: ${TEMP_DOMAIN}]${plain}"
    fi
fi

   # === 🛡️ 节点矩阵加密状态动态嗅探 ===
    if [[ -f "$JSON_FILE" ]]; then
        if jq -e '.inbounds[] | select(.tag == "vless-in")' "$JSON_FILE" >/dev/null 2>&1; then
            VL_STAT="${green}[开启]${plain}"; VL_PORT=$(jq -r '.inbounds[] | select(.tag == "vless-in") | .listen_port' "$JSON_FILE"); VL_SNI=$(jq -r '.inbounds[] | select(.tag == "vless-in") | .tls.server_name' "$JSON_FILE")
            VL_TYPE="(${purple}Reality${plain}) " # 9字符+1空格=10宽
        fi
        
        if jq -e '.inbounds[] | select(.tag == "hy2-in")' "$JSON_FILE" >/dev/null 2>&1; then
            HY2_STAT="${green}[开启]${plain}"; HY2_PORT=$(jq -r '.inbounds[] | select(.tag == "hy2-in") | .listen_port' "$JSON_FILE"); HY2_SNI="自定义/自签"
            HY2_TYPE="(${blue}QUIC+TLS${plain})" # 满10宽
        fi
        
        if jq -e '.inbounds[] | select(.tag == "tuic-in")' "$JSON_FILE" >/dev/null 2>&1; then
            TUIC_STAT="${green}[开启]${plain}"; TUIC_PORT=$(jq -r '.inbounds[] | select(.tag == "tuic-in") | .listen_port' "$JSON_FILE"); TUIC_SNI="自定义/自签"
            TUIC_TYPE="(${blue}QUIC+TLS${plain})" # 满10宽
        fi
        
        if jq -e '.inbounds[] | select(.tag == "vmess-in")' "$JSON_FILE" >/dev/null 2>&1; then
            VM_STAT="${green}[开启]${plain}"; VM_PORT=$(jq -r '.inbounds[] | select(.tag == "vmess-in") | .listen_port' "$JSON_FILE")
            if jq -e '.inbounds[] | select(.tag == "vmess-in" and has("tls"))' "$JSON_FILE" >/dev/null 2>&1; then
                VM_TYPE="(${green}WS+TLS${plain})  " # 8字符+2空格=10宽
                VM_LABEL="证书"
                VM_SNI="${purple}自定义/自签${plain}"
            else
               if systemctl is-active --quiet vx-argo.service 2>/dev/null; then
            VM_TYPE="(${yellow}Argo接管${plain})" # 10宽
            VM_LABEL="状态"
            # 大佬极客精简版：上面已有详细雷达，这里统一输出极简防弹状态
            VM_SNI="${yellow}Argo 穿透保护中${plain}"
        else
            VM_TYPE="(${red}纯WS明文${plain})" # 10宽
            VM_LABEL="状态"
            VM_SNI="${red}无保护裸奔 (建议挂载 CDN)${plain}"
        fi
            fi
        else
            VM_LABEL="状态"
        fi

        if jq -e '.inbounds[] | select(.tag == "trojan-in")' "$JSON_FILE" >/dev/null 2>&1; then
            TR_STAT="${green}[开启]${plain}"; TR_PORT=$(jq -r '.inbounds[] | select(.tag == "trojan-in") | .listen_port' "$JSON_FILE"); TR_SNI=$(jq -r '.inbounds[] | select(.tag == "trojan-in") | .tls.server_name' "$JSON_FILE")
            TR_TYPE="(${purple}Reality${plain}) " # 9字符+1空格=10宽
        fi
    fi

   # 极速无感检测版本更新 (1.5秒超时)
   local REMOTE_VER=$(curl -s -m 1.5 "$SCRIPT_URL" 2>/dev/null | grep "^VX_VERSION=" | head -n 1 | cut -d'"' -f2 || true)
    UPDATE_MSG=""
    local NEW_FEAT="" # 👈 新增：专属云端探针变量
    
    if [[ -n "$REMOTE_VER" && "$REMOTE_VER" != "$VX_VERSION" ]]; then
        UPDATE_MSG="${yellow}🔔 发现新版 v${REMOTE_VER} (请按 i 升级)${plain}"
        # 🚀 动态抓取云端 Changelog 的前 3 行 (包含时间与核心更新)
        NEW_FEAT=$(curl -s -m 1.5 "https://raw.githubusercontent.com/pwenxiang51-wq/VX-Node-Engine/main/changelog.txt" 2>/dev/null | head -n 5 || true)
    else
        UPDATE_MSG="${green}✅ 最新版 (v${VX_VERSION})${plain}"
    fi
    # === 👇 极客新增：Sing-box 内核极速防卡死探针 👇 ===
    if [[ -x "/usr/local/bin/sing-box" ]]; then
        SB_CORE_VER=$(/usr/local/bin/sing-box version 2>/dev/null | head -n 1 | awk '{print $3}')
        [[ -z "$SB_CORE_VER" ]] && SB_CORE_VER="未知"
    else
        SB_CORE_VER="未安装"
    fi

    # 限时 1.5 秒抓取线上版本，超时立刻放弃，绝不卡死面板！
    SB_LATEST_VER=$(curl -s --connect-timeout 1 -m 1.5 "https://api.github.com/repos/SagerNet/sing-box/releases/latest" | grep '"tag_name":' | sed -E 's/.*"v?([^"]+)".*/\1/')

   UPDATE_TIPS=""
    if [[ -n "$SB_LATEST_VER" && "$SB_CORE_VER" != "未安装" && "$SB_CORE_VER" != "$SB_LATEST_VER" ]]; then
        UPDATE_TIPS=" ${yellow}🔥 发现新内核 v${SB_LATEST_VER}，请按 [i] 热更新！${plain}"
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
    
    # 👇 注入升级速递：只有检测到更新且抓取成功时，才在主界面炫技
    if [[ -n "$NEW_FEAT" ]]; then
        echo -e " 📢 ${purple}升级速递：${plain}"
        while IFS= read -r line; do
            [[ -n "$line" ]] && echo -e "    ${cyan}»${plain} ${yellow}$line${plain}"
        done <<< "$NEW_FEAT"
    fi
    # 👆 渲染结束

    echo -e " 🛡️ 架构认证：${yellow}全系 Linux 通杀${plain} (Ubuntu/Debian/CentOS) | ARM 神机适配"
    echo -e " ☁️ 云端穿透：${yellow}无视 1:1 NAT${plain} 深度适配 AWS / GCP / Oracle 等大厂 VPC"
    echo -e "${cyan}======================================================================${plain}"
    # 👆👆👆 ------------------------ 👆👆👆
    echo -e "⚙️  ${yellow}系统核心状态:${plain}"
    echo -e "   系统版本: ${blue}$OS_INFO${plain} | 架构: ${blue}$ARCH${plain}"
    echo -e "   内核版本: ${blue}$KERNEL_VER${plain} | 拥塞控制: ${green}${BBR_STAT^^}${plain}"
    echo -e "----------------------------------------------------------------------"
    echo -e "🌍  ${yellow}网络物理链路 (IPv6 智能双栈支持):${plain}"
    echo -e "   IPv4地址: ${green}$IPV4${plain}"
    echo -e "   IPv6地址: ${green}$IPV6${plain}"
    echo -e "   归属: ${blue}$LOC - $ISP${plain}"
    echo -e "----------------------------------------------------------------------"
    echo -e "🧩  ${yellow}高级拓展矩阵:${plain}"
    echo -e "   ACME 证书: $ACME_STAT"
    echo -e "   WARP 解锁: $WARP_STAT"
    echo -e "   Argo 隧道: $ARGO_STAT"
    echo -e "   动态订阅 : $SUB_STAT"
    echo -e "----------------------------------------------------------------------"
    echo -e "🛡️  ${yellow}代理引擎矩阵 (Sing-box 状态: $SB_STAT ${plain}|${yellow} 内核: ${cyan}v${SB_CORE_VER}${plain})${UPDATE_TIPS}${yellow}:${plain}"
    echo -e "  $VL_STAT VLESS    $VL_TYPE | 端口: ${cyan}$VL_PORT${plain} | 伪装: ${purple}$VL_SNI${plain}"
    echo -e "  $HY2_STAT Hysteria2$HY2_TYPE | 端口: ${cyan}$HY2_PORT${plain} | 证书: ${purple}$HY2_SNI${plain}"
    echo -e "  $TUIC_STAT TUIC v5  $TUIC_TYPE | 端口: ${cyan}$TUIC_PORT${plain} | 证书: ${purple}$TUIC_SNI${plain}"
    echo -e "  $VM_STAT VMess-WS $VM_TYPE | 端口: ${cyan}$VM_PORT${plain} | $VM_LABEL: $VM_SNI"
    echo -e "  $TR_STAT Trojan   $TR_TYPE | 端口: ${cyan}$TR_PORT${plain} | 伪装: ${purple}$TR_SNI${plain}"
    echo -e "----------------------------------------------------------------------"
    echo -e " 🌟 ${yellow}极客致敬：${plain}如果您觉得好用，请移步 GitHub 点个 ${cyan}Star${plain} ⭐"
    echo -e " 🔗 ${blue}https://github.com/pwenxiang51-wq/VX-Node-Engine${plain}"
    
    echo -e "${cyan}======================================================================${plain}"
}

# ==================================================
# 底座支撑模块
# ==================================================
function check_sys() {
    mkdir -p "$CONF_DIR"
    touch "$LINK_FILE"
    # === 🚀 自动化环境自检：补全所有极客组件 ===
    local NEED_PACKAGES=(jq qrencode curl wget openssl tar busybox socat)
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
        # 智能侦测拦截：无规则才插入，拒绝垃圾堆叠
        iptables -C INPUT -p tcp --dport $PORT -j ACCEPT 2>/dev/null || iptables -I INPUT -p tcp --dport $PORT -j ACCEPT >/dev/null 2>&1
        iptables -C INPUT -p udp --dport $PORT -j ACCEPT 2>/dev/null || iptables -I INPUT -p udp --dport $PORT -j ACCEPT >/dev/null 2>&1
        if command -v ip6tables &> /dev/null; then
            ip6tables -C INPUT -p tcp --dport $PORT -j ACCEPT 2>/dev/null || ip6tables -I INPUT -p tcp --dport $PORT -j ACCEPT >/dev/null 2>&1
            ip6tables -C INPUT -p udp --dport $PORT -j ACCEPT 2>/dev/null || ip6tables -I INPUT -p udp --dport $PORT -j ACCEPT >/dev/null 2>&1
        fi

        # 尝试保存，如果未安装保存插件也不报错，至少保证当次开机可用
        if command -v netfilter-persistent &> /dev/null; then
            netfilter-persistent save >/dev/null 2>&1
        elif command -v service &> /dev/null && [[ -f /etc/redhat-release ]]; then
            service iptables save >/dev/null 2>&1
            service ip6tables save >/dev/null 2>&1 # 顺手把 CentOS 的 v6 也保存一下
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
    IPV4_TMP=$(curl -s4m3 icanhazip.com || curl -s4m3 api.ipify.org || curl -s4m3 ipinfo.io/ip)
    IPV6_TMP=$(curl -s6m3 icanhazip.com || curl -s6m3 api6.ipify.org)
    if [[ -n "$IPV4_TMP" ]]; then
        SERVER_IP="$IPV4_TMP"
    elif [[ -n "$IPV6_TMP" ]]; then
        SERVER_IP="[$IPV6_TMP]" # 纯 IPv6 环境自动加括号以符合 URL 规范
    else
        SERVER_IP="127.0.0.1"
    fi
}


# ==================================================
# 📡 动态订阅防盗分发引擎 (极致兼容 & 自动 HTTPS 版)
# ==================================================
function update_sub() {
    local WEB_DIR="$CONF_DIR/www"
    local SUB_PORT_FILE="$CONF_DIR/sub_port.txt"
    local SUB_PATH_FILE="$CONF_DIR/sub_path.txt"

    mkdir -p "$WEB_DIR"

    if [[ ! -f "$SUB_PORT_FILE" ]]; then
        local TEMP_PORT
        while true; do
            TEMP_PORT=$(shuf -i 30000-40000 -n 1)
            if ! ss -tunlp | grep -q ":$TEMP_PORT " 2>/dev/null; then
                echo "$TEMP_PORT" > "$SUB_PORT_FILE"
                break
            fi
        done
    fi

    if [[ ! -s "$SUB_PATH_FILE" ]]; then
        local NEW_UUID=$(cat /proc/sys/kernel/random/uuid 2>/dev/null)
        if [[ -z "$NEW_UUID" ]]; then
            NEW_UUID="vx-$(date +%s)-$(shuf -i 100-999 -n 1)"
        fi
        echo "$NEW_UUID" > "$SUB_PATH_FILE"
    fi

    local SUB_PORT=$(cat "$SUB_PORT_FILE")
    local SUB_PATH=$(cat "$SUB_PATH_FILE")
    local TARGET_DIR="$WEB_DIR/$SUB_PATH"
    mkdir -p "$TARGET_DIR"

    if [[ -s "$LINK_FILE" ]]; then
        cat "$LINK_FILE" | base64 | tr -d '\n\r' > "$TARGET_DIR/vx_sub"
    else
        echo "" > "$TARGET_DIR/vx_sub"
    fi

    # --- 1. 启动基础 HTTP 服务 ---
    if ! systemctl is-active --quiet vx-sub.service 2>/dev/null; then
        local BB_PATH=$(command -v busybox)
        cat <<EOF > /etc/systemd/system/vx-sub.service
[Unit]
Description=Velox Subscription Server (HTTP)
After=network.target

[Service]
Type=simple
ExecStart=$BB_PATH httpd -f -p $SUB_PORT -h $WEB_DIR
Restart=always

[Install]
WantedBy=multi-user.target
EOF
        systemctl daemon-reload
        systemctl enable --now vx-sub.service >/dev/null 2>&1
        open_port $SUB_PORT
    fi

    # --- 2. 启动 HTTPS 加密装甲 (智能识别 ACME 证书) ---
    if [[ -f "$CERT_DIR/acme.crt" && -f "$CERT_DIR/acme.key" ]]; then
        local HTTPS_PORT=$((SUB_PORT + 1)) # 使用相邻的端口做 HTTPS
        echo "$HTTPS_PORT" > "$CONF_DIR/sub_port_https.txt"
        
        # 合并证书供 socat 使用
        cat "$CERT_DIR/acme.crt" "$CERT_DIR/acme.key" > "$CERT_DIR/socat.pem"
        
        if ! systemctl is-active --quiet vx-sub-https.service 2>/dev/null; then
            local SOCAT_PATH=$(command -v socat)
            cat <<EOF > /etc/systemd/system/vx-sub-https.service
[Unit]
Description=Velox Subscription Server (HTTPS Wrapper)
After=vx-sub.service

[Service]
Type=simple
# 核心魔法：将 HTTPS 流量解密后转发给本地的 Busybox
ExecStart=$SOCAT_PATH openssl-listen:$HTTPS_PORT,cert=$CERT_DIR/socat.pem,verify=0,fork tcp:127.0.0.1:$SUB_PORT
Restart=always

[Install]
WantedBy=multi-user.target
EOF
            systemctl daemon-reload
            systemctl enable --now vx-sub-https.service >/dev/null 2>&1
            open_port $HTTPS_PORT
        fi
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
~/.acme.sh/acme.sh --installcert -d ${REAL_DOMAIN} --fullchainpath $CERT_DIR/acme.crt --keypath $CERT_DIR/acme.key --ecc --force --reloadcmd "systemctl restart vx-core.service vx-sub-https.service vx-sub.service" >/dev/null 2>&1
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
    echo -e "\n${yellow}>>> 锻造 VLESS-Reality ：${plain}"
    read -p "👉 监听端口 (直接回车随机): " LISTEN_PORT; LISTEN_PORT=${LISTEN_PORT:-$(shuf -i 10000-60000 -n 1)}
    read -p "👉  UUID (直接回车随机): " UUID; UUID=${UUID:-$TEMP_UUID}
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
    update_sub
    echo -e "\n${green}✅ VLESS-Reality 装载完成！${plain}"; echo -e "👉 ${yellow}提示: 请返回主菜单，按【f】提取链接！${plain}"
}

function install_hysteria2() {
    check_sys && install_core && init_json && get_smart_ip
    echo -e "\n${yellow}>>> 锻造 Hysteria2 ：${plain}"
    read -p "👉 监听端口 (直接回车随机): " LISTEN_PORT; LISTEN_PORT=${LISTEN_PORT:-$(shuf -i 10000-60000 -n 1)}
    read -p "👉 密码 (直接回车随机): " HYS_PASS; HYS_PASS=${HYS_PASS:-$TEMP_PASS}
    
    # === 👇 极客级上下文感知雷达 👇 ===
    read -p "👉 绑定域名 (小白请直接回车，自动探测ACME或注入随机装甲): " INPUT_DOMAIN
    if [[ -z "$INPUT_DOMAIN" ]]; then
        # 探测是否存在真实证书
        if [[ -f "$CERT_DIR/acme.crt" && -f "$CERT_DIR/acme_domain.txt" ]]; then
            SNI_DOMAIN=$(cat "$CERT_DIR/acme_domain.txt" 2>/dev/null)
            echo -e "${green}✅ 雷达锁定！侦测到真实防弹装甲，已自动继承 ACME 域名: ${cyan}$SNI_DOMAIN${plain}"
        else
            # 保留你原本极其优秀的量子随机防御机制！
            SNI_DOMAIN="$(tr -dc 'a-z0-9' </dev/urandom | head -c 8).net"
            echo -e "${yellow}⚠️ 未挂载真实证书，UDP层已自动切换至防探针乱码装甲: ${SNI_DOMAIN}${plain}"
        fi
    else
        SNI_DOMAIN="$INPUT_DOMAIN"
        echo -e "${green}✅ 手动强控覆盖！已锁定域名: ${cyan}$SNI_DOMAIN${plain}"
    fi
    # === 👆 雷达探测结束 👆 ===
    
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
    update_sub
    echo -e "\n${green}✅ Hysteria2 装载完成！${plain}"; echo -e "👉 ${yellow}提示: 请返回主菜单，按【f】提取链接！${plain}"
}

function install_tuic_v5() {
    check_sys && install_core && init_json && get_smart_ip
    echo -e "\n${yellow}>>> 锻造 TUIC v5 ：${plain}"
    read -p "👉 监听端口 (直接回车随机): " LISTEN_PORT; LISTEN_PORT=${LISTEN_PORT:-$(shuf -i 10000-60000 -n 1)}
    read -p "👉  UUID (直接回车随机): " UUID; UUID=${UUID:-$TEMP_UUID}
    read -p "👉 密码 (直接回车随机): " TUIC_PASS; TUIC_PASS=${TUIC_PASS:-$TEMP_PASS}
    
    # === 👇 极客级上下文感知雷达 👇 ===
    read -p "👉 绑定域名 (小白请直接回车，自动探测ACME或注入随机装甲): " INPUT_DOMAIN
    if [[ -z "$INPUT_DOMAIN" ]]; then
        # 探测是否存在真实证书
        if [[ -f "$CERT_DIR/acme.crt" && -f "$CERT_DIR/acme_domain.txt" ]]; then
            SNI_DOMAIN=$(cat "$CERT_DIR/acme_domain.txt" 2>/dev/null)
            echo -e "${green}✅ 雷达锁定！侦测到真实防弹装甲，已自动继承 ACME 域名: ${cyan}$SNI_DOMAIN${plain}"
        else
            # 保留你原本极其优秀的量子随机防御机制！
            SNI_DOMAIN="$(tr -dc 'a-z0-9' </dev/urandom | head -c 8).net"
            echo -e "${yellow}⚠️ 未挂载真实证书，UDP层已自动切换至防探针乱码装甲: ${SNI_DOMAIN}${plain}"
        fi
    else
        SNI_DOMAIN="$INPUT_DOMAIN"
        echo -e "${green}✅ 手动强控覆盖！已锁定域名: ${cyan}$SNI_DOMAIN${plain}"
    fi
    # === 👆 雷达探测结束 👆 ===
    
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
    update_sub
    echo -e "\n${green}✅ TUIC v5 装载完成！${plain}"; echo -e "👉 ${yellow}提示: 请返回主菜单，按【f】提取链接！${plain}"
}

function install_vmess_ws() {
    check_sys && install_core && init_json && get_smart_ip
    echo -e "\n${yellow}>>> 锻造 VMess-WS+TLS (满血防弹装甲) ：${plain}"
    read -p "👉 监听端口 (直接回车随机): " LISTEN_PORT; LISTEN_PORT=${LISTEN_PORT:-$(shuf -i 10000-60000 -n 1)}
    read -p "👉  UUID (直接回车随机): " UUID; UUID=${UUID:-$TEMP_UUID}
    
    # 自动探测或注入域名装甲
    read -p "👉 绑定域名 (小白请直接回车，自动探测ACME或注入随机装甲): " INPUT_DOMAIN
    if [[ -z "$INPUT_DOMAIN" ]]; then
        if [[ -f "$CERT_DIR/acme.crt" && -f "$CERT_DIR/acme_domain.txt" ]]; then
            SNI_DOMAIN=$(cat "$CERT_DIR/acme_domain.txt" 2>/dev/null)
            echo -e "${green}✅ 雷达锁定！已自动继承 ACME 域名: ${cyan}$SNI_DOMAIN${plain}"
        else
            SNI_DOMAIN="$(tr -dc 'a-z0-9' </dev/urandom | head -c 8).net"
            echo -e "${yellow}⚠️ 未挂载真实证书，已自动注入防探针乱码装甲: ${SNI_DOMAIN}${plain}"
        fi
    else
        SNI_DOMAIN="$INPUT_DOMAIN"
        echo -e "${green}✅ 手动强控覆盖！已锁定域名: ${cyan}$SNI_DOMAIN${plain}"
    fi
    
    generate_cert_dynamic "$SNI_DOMAIN"
    WS_PATH="/vx-$(tr -dc 'a-z0-9' </dev/urandom | head -c 6)"

    # 原子压入带 TLS 的底层配置
    cat << EOF > /tmp/vx_tmp.json
{"type":"vmess","tag":"vmess-in","listen":"::","listen_port":$LISTEN_PORT,"users":[{"uuid":"$UUID","alterId":0}],"transport":{"type":"ws","path":"$WS_PATH"},"tls":{"enabled":true,"server_name":"$SNI_DOMAIN","certificate_path":"$CERT_DIR/cert.crt","key_path":"$CERT_DIR/private.key"}}
EOF
    jq 'del(.inbounds[] | select(.tag == "vmess-in"))' "$JSON_FILE" | atomic_jq
    jq '.inbounds += [input]' "$JSON_FILE" /tmp/vx_tmp.json | atomic_jq

    open_port $LISTEN_PORT
    systemctl restart vx-core.service
    
    # 构建满血带 TLS 的分享链接
    VMESS_JSON=$(jq -n -c --arg v "2" --arg ps "VMess-WS-TLS-VeloX" --arg add "$SERVER_IP" --arg port "$LISTEN_PORT" --arg id "$UUID" --arg net "ws" --arg host "$SNI_DOMAIN" --arg path "$WS_PATH" --arg tls "tls" --arg sni "$SNI_DOMAIN" '{v:$v, ps:$ps, add:$add, port:$port, id:$id, aid:"0", scy:"auto", net:$net, type:"none", host:$host, path:$path, tls:$tls, sni:$sni}')
    SHARE="vmess://$(echo -n "$VMESS_JSON" | base64 -w 0)"
    sed -i '/^vmess:\/\//d' "$LINK_FILE" 2>/dev/null
    echo "$SHARE" >> "$LINK_FILE"
    update_sub
    echo -e "\n${green}✅ VMess-WS+TLS 装载完成！已默认穿戴防弹装甲。${plain}"
    echo -e "👉 ${yellow}提示: 请返回主菜单，按【f】提取链接！${plain}"
}

function install_trojan_reality() {
    check_sys && install_core && init_json && get_smart_ip
    echo -e "\n${yellow}>>> 锻造 Trojan-Reality (NPC进阶神级) ：${plain}"
    read -p "👉 监听端口 (直接回车随机): " LISTEN_PORT; LISTEN_PORT=${LISTEN_PORT:-$(shuf -i 10000-60000 -n 1)}
    read -p "👉 密码 (直接回车随机): " TROJAN_PASS; TROJAN_PASS=${TROJAN_PASS:-$TEMP_PASS}
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
    update_sub
    echo -e "\n${green}✅ Trojan-Reality 装载完成！${plain}"; echo -e "👉 ${yellow}提示: 请返回主菜单，按【f】提取链接！${plain}"
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

    # 2. 智能域名与证书准备 (双轨防弹装甲)
    local TCP_SNI="apple.com"  # TCP 协议雷打不动薅大厂羊毛
    local UDP_SNI=""

    if [[ -f "$CERT_DIR/acme.crt" && -f "$CERT_DIR/acme_domain.txt" ]]; then
        UDP_SNI=$(cat "$CERT_DIR/acme_domain.txt" 2>/dev/null)
        echo -e ">>> 🌐 检测到 ACME 真实证书，UDP 协议已接管真实域名: ${green}$UDP_SNI${plain}"
    else
        # 核心防呆：没有真实证书，UDP 暴力协议强行生成无特征乱码装甲
        UDP_SNI="$(tr -dc 'a-z0-9' </dev/urandom | head -c 8).net"
        echo -e ">>> ⚠️ 未部署真实证书！TCP 隐匿层维持伪装: ${green}$TCP_SNI${plain}"
        echo -e ">>> 🛡️ UDP 暴力层 (Hy2/TUIC) 已强行隔离，注入防探针装甲: ${yellow}$UDP_SNI${plain}"
    fi

    # 证书发证机只为 UDP 协议服务，避免污染
    generate_cert_dynamic "$UDP_SNI" >/dev/null 2>&1

   # 3. 彻底核爆清空历史数据
    > "$LINK_FILE"
    echo '{"log":{"level":"info","timestamp":true},"inbounds":[],"outbounds":[{"type":"direct","tag":"direct"},{"type":"block","tag":"block"}]}' | jq . | atomic_jq

    # 4. 端口隔离生成池：智能侦测碰撞，确保大满贯端口绝对纯净！
    local BASE_PORTS=()
    while [ ${#BASE_PORTS[@]} -lt 5 ]; do
        local TEMP_PORT=$(shuf -i 10000-60000 -n 1)
        # 兼容全系 Linux：只要 ss 或 netstat 查出占用，直接物理抛弃
        if ! ss -tunlp 2>/dev/null | grep -q ":$TEMP_PORT " && ! netstat -tunlp 2>/dev/null | grep -q ":$TEMP_PORT "; then
            if [[ ! " ${BASE_PORTS[@]} " =~ " ${TEMP_PORT} " ]]; then
                BASE_PORTS+=($TEMP_PORT)
            fi
        fi
    done
    local P1=${BASE_PORTS[0]}
    local P2=${BASE_PORTS[1]}
    local P3=${BASE_PORTS[2]}
    local P4=${BASE_PORTS[3]}
    local P5=${BASE_PORTS[4]}

    # 5. 极速压入节点 (👇此处已修复克隆人 Bug，每个协议独立生成凭证)
    echo -e "\n${yellow}>>> [1/5] 正在极速压入 VLESS-Reality...${plain}"
    local U1=$(cat /proc/sys/kernel/random/uuid 2>/dev/null || echo "vx-$(date +%s)1"); local K1=$($BIN_FILE generate reality-keypair); local PR1=$(echo "$K1" | awk '/PrivateKey/ {print $2}' | tr -d '\r\n'); local PU1=$(echo "$K1" | awk '/PublicKey/ {print $2}' | tr -d '\r\n'); local S1=$($BIN_FILE generate rand --hex 8 | tr -d '\r\n')
    jq --argjson p "$P1" --arg u "$U1" --arg sni "apple.com" --arg pr "$PR1" --arg sid "$S1" '.inbounds += [{"type":"vless","tag":"vless-in","listen":"::","listen_port":$p,"users":[{"uuid":$u,"flow":"xtls-rprx-vision"}],"tls":{"enabled":true,"server_name":$sni,"reality":{"enabled":true,"handshake":{"server":$sni,"server_port":443},"private_key":$pr,"short_id":[$sid]}}}]' "$JSON_FILE" | atomic_jq
    echo "vless://${U1}@${SERVER_IP}:${P1}?encryption=none&flow=xtls-rprx-vision&security=reality&sni=apple.com&fp=chrome&pbk=${PU1}&sid=${S1}&type=tcp&headerType=none#VLESS-Reality-VeloX" >> "$LINK_FILE"
    open_port $P1

    echo -e "${yellow}>>> [2/5] 正在极速压入 Hysteria2...${plain}"
    local PW2=$(openssl rand -hex 8)
    jq --argjson p "$P2" --arg pw "$PW2" --arg crt "$CERT_DIR/cert.crt" --arg key "$CERT_DIR/private.key" '.inbounds += [{"type":"hysteria2","tag":"hy2-in","listen":"::","listen_port":$p,"users":[{"password":$pw}],"tls":{"enabled":true,"alpn":["h3"],"certificate_path":$crt,"key_path":$key}}]' "$JSON_FILE" | atomic_jq
    echo "hysteria2://${PW2}@${SERVER_IP}:${P2}/?sni=${UDP_SNI}&alpn=h3&insecure=1#Hys2-VeloX" >> "$LINK_FILE"
    open_port $P2

    echo -e "${yellow}>>> [3/5] 正在极速压入 TUIC v5...${plain}"
    local U3=$(cat /proc/sys/kernel/random/uuid 2>/dev/null || echo "vx-$(date +%s)3"); local PW3=$(openssl rand -hex 8)
    jq --argjson p "$P3" --arg u "$U3" --arg pw "$PW3" --arg crt "$CERT_DIR/cert.crt" --arg key "$CERT_DIR/private.key" '.inbounds += [{"type":"tuic","tag":"tuic-in","listen":"::","listen_port":$p,"users":[{"uuid":$u,"password":$pw}],"congestion_control":"bbr","tls":{"enabled":true,"alpn":["h3"],"certificate_path":$crt,"key_path":$key}}]' "$JSON_FILE" | atomic_jq
    echo "tuic://${U3}:${PW3}@${SERVER_IP}:${P3}/?sni=${UDP_SNI}&alpn=h3&congestion_control=bbr&insecure=1#TUIC-VeloX" >> "$LINK_FILE"
    open_port $P3

    echo -e "${yellow}>>> [4/5] 正在极速压入 VMess-WS+TLS...${plain}"
    local U4=$(cat /proc/sys/kernel/random/uuid 2>/dev/null || echo "vx-$(date +%s)4"); local W4="/vx-$(tr -dc 'a-z0-9' </dev/urandom | head -c 6)"
    jq --argjson p "$P4" --arg u "$U4" --arg w "$W4" --arg crt "$CERT_DIR/cert.crt" --arg key "$CERT_DIR/private.key" --arg sni "$UDP_SNI" '.inbounds += [{"type":"vmess","tag":"vmess-in","listen":"::","listen_port":$p,"users":[{"uuid":$u,"alterId":0}],"transport":{"type":"ws","path":$w},"tls":{"enabled":true,"server_name":$sni,"certificate_path":$crt,"key_path":$key}}]' "$JSON_FILE" | atomic_jq
    local VM_J=$(jq -n -c --arg v "2" --arg ps "VMess-WS-TLS-VeloX" --arg add "$SERVER_IP" --arg port "$P4" --arg id "$U4" --arg net "ws" --arg host "$UDP_SNI" --arg path "$W4" --arg tls "tls" --arg sni "$UDP_SNI" '{v:$v, ps:$ps, add:$add, port:$port, id:$id, aid:"0", scy:"auto", net:$net, type:"none", host:$host, path:$path, tls:$tls, sni:$sni}')
    echo "vmess://$(echo -n "$VM_J" | base64 -w 0)" >> "$LINK_FILE"
    open_port $P4

    echo -e "${yellow}>>> [5/5] 正在极速压入 Trojan-Reality...${plain}"
    local PW5=$(openssl rand -hex 8); local K5=$($BIN_FILE generate reality-keypair); local PR5=$(echo "$K5" | awk '/PrivateKey/ {print $2}' | tr -d '\r\n'); local PU5=$(echo "$K5" | awk '/PublicKey/ {print $2}' | tr -d '\r\n'); local S5=$($BIN_FILE generate rand --hex 8 | tr -d '\r\n')
    jq --argjson p "$P5" --arg pw "$PW5" --arg sni "apple.com" --arg pr "$PR5" --arg sid "$S5" '.inbounds += [{"type":"trojan","tag":"trojan-in","listen":"::","listen_port":$p,"users":[{"password":$pw}],"tls":{"enabled":true,"server_name":$sni,"reality":{"enabled":true,"handshake":{"server":$sni,"server_port":443},"private_key":$pr,"short_id":[$sid]}}}]' "$JSON_FILE"| atomic_jq
    echo "trojan://${PW5}@${SERVER_IP}:${P5}?security=reality&sni=apple.com&fp=chrome&pbk=${PU5}&sid=${S5}&type=tcp&headerType=none#Trojan-Reality-VeloX" >> "$LINK_FILE"
    open_port $P5

    systemctl restart vx-core.service
    update_sub
    echo -e "\n${green}✅ 大满贯全量装载完成！防火墙已被打穿，五大神级协议已全部就绪！${plain}"
    echo -e "\n${yellow}💡 【云大厂架构师警告】: 若您的 VPS 位于 AWS / GCP / Oracle 等云环境，请务必前往云控制台的 [安全组/VPC防火墙] 放行上述端口！否则流量将被物理阻断！${plain}"
    echo -e "👉 ${yellow}提示: 请按回车返回主菜单，直接按【f】提取所有节点链接！${plain}"
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
   
    # 强制唤醒内核模块，兼容更多阉割版系统
    modprobe tcp_bbr >/dev/null 2>&1 || true
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
                systemctl stop warp-svc >/dev/null 2>&1
                systemctl disable warp-svc >/dev/null 2>&1
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

    # 【最稳妥：神级关键词分流 + 强制底层流量嗅探】彻底解决多端 DNS 泄露导致的分流失效
jq '.outbounds = [{"type":"socks","tag":"warp-socks","server":"127.0.0.1","server_port":40000}, {"type":"direct","tag":"direct"}, {"type":"block","tag":"block"}] | .route.rules = [{"action":"sniff"}] + [{"domain_keyword":["google","youtube","gmail","openai","chatgpt","netflix","spotify","instagram","dazn","disney","prime","hulu","tiktok","reddit","discord","pixiv","bing","wiki"],"domain_suffix":["openai.com","chatgpt.com","ai.com","anthropic.com","claude.ai","google.com","googleapis.com","gstatic.com","netflix.com","disneyplus.com","amazon.com","primevideo.com","tiktok.com","instagram.com","reddit.com","discord.com","wikipedia.org"],"outbound":"warp-socks"}]' "$JSON_FILE" | atomic_jq
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
            
            # === 🚀 动态装甲恢复：Argo 拆除后，自动为 VMess 重新挂载 TLS ===
            echo -e "${yellow}>>> 正在为 VMess 重新挂载 TLS 防弹装甲...${plain}"
            local RESTORE_SNI=""
            if [[ -f "$CERT_DIR/acme.crt" && -f "$CERT_DIR/acme_domain.txt" ]]; then
                RESTORE_SNI=$(cat "$CERT_DIR/acme_domain.txt" 2>/dev/null)
            else
                RESTORE_SNI="$(tr -dc 'a-z0-9' </dev/urandom | head -c 8).net"
                generate_cert_dynamic "$RESTORE_SNI" >/dev/null 2>&1
            fi
            
            jq --arg crt "$CERT_DIR/cert.crt" --arg key "$CERT_DIR/private.key" --arg sni "$RESTORE_SNI" '(.inbounds[] | select(.tag == "vmess-in")).tls = {"enabled":true,"server_name":$sni,"certificate_path":$crt,"key_path":$key}' "$JSON_FILE" | atomic_jq
            systemctl restart vx-core.service

            # 清理旧链接，重铸满血 TLS 链接
            local V_PORT=$(jq -r '.inbounds[] | select(.tag == "vmess-in") | .listen_port' "$JSON_FILE")
            local V_PATH=$(jq -r '.inbounds[] | select(.tag == "vmess-in") | .transport.path' "$JSON_FILE")
            local V_UUID=$(jq -r '.inbounds[] | select(.tag == "vmess-in") | .users[0].uuid' "$JSON_FILE")
            get_smart_ip
            local VM_J=$(jq -n -c --arg v "2" --arg ps "VMess-WS-TLS-VeloX" --arg add "$SERVER_IP" --arg port "$V_PORT" --arg id "$V_UUID" --arg net "ws" --arg host "$RESTORE_SNI" --arg path "$V_PATH" --arg tls "tls" --arg sni "$RESTORE_SNI" '{v:$v, ps:$ps, add:$add, port:$port, id:$id, aid:"0", scy:"auto", net:$net, type:"none", host:$host, path:$path, tls:$tls, sni:$sni}')
            sed -i '/^vmess:\/\//d' "$LINK_FILE" 2>/dev/null
            echo "vmess://$(echo -n "$VM_J" | base64 -w 0)" >> "$LINK_FILE"
            
            # 智能清理遗留的节点链接 (修复Base64无法匹配的Bug)
        if [[ -f "$LINK_FILE" ]]; then
            mv "$LINK_FILE" "${LINK_FILE}.tmp"
            cat "${LINK_FILE}.tmp" | while read line; do
                if [[ "$line" == vmess://* ]]; then
                    # 强行把密码箱撬开看一眼，如果有 trycloudflare 或者 Argo 就扔掉，没有就保留
                    if ! echo "$line" | sed 's/vmess:\/\///' | base64 -d 2>/dev/null | grep -qiE "trycloudflare|Argo"; then
                        echo "$line" >> "$LINK_FILE"
                    fi
                else
                    echo "$line" >> "$LINK_FILE"
                fi
            done
            rm -f "${LINK_FILE}.tmp"
        fi
        update_sub
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
    # === 🚀 动态装甲剥离：为适配 Argo，物理剥离 VMess 的 TLS 装甲 ===
    if jq -e '.inbounds[] | select(.tag == "vmess-in" and has("tls"))' "$JSON_FILE" >/dev/null 2>&1; then
        echo -e "${yellow}>>> 正在智能剥离 VMess 底层 TLS 装甲，进行 Argo 物理适配...${plain}"
        jq 'del(.inbounds[] | select(.tag == "vmess-in").tls)' "$JSON_FILE" | atomic_jq
        systemctl restart vx-core.service
        sleep 1
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
    echo -e "  ${red}0.${plain} 返回主菜单 (安全取消操作)"
    echo ""
    
    local ARGO_MODE=""
    local ARGO_DOMAIN=""

    # === 🚀 物理级防呆死循环拦截 ===
    while true; do
        read -p "👉 请选择 [0-2] (直接回车默认取消/返回 0): " ARGO_MODE
        ARGO_MODE=${ARGO_MODE:-0} # 核心防呆：只要是空回车，强行赋予 0 触发撤退

        case "$ARGO_MODE" in
            1)
                echo -e "\n${green}>>> 探测到指令 [1]，即将建立临时反向地下隧道...${plain}"
                break # 合法指令，跳出死循环往下执行
                ;;
            2)
                echo -e "\n${green}>>> 探测到指令 [2]，即将挂载 Zero Trust 固定装甲...${plain}"
                break # 合法指令，跳出死循环往下执行
                ;;
            0)
                echo -e "\n${yellow}>>> 撤退指令确认！操作已取消，安全返回大屏。${plain}"
                sleep 1
                return 0 # 优雅切断函数，返回上级
                ;;
            *)
                echo -e "${red}❌ 致命拦截：非法参数！请收起你的测试脚本，老老实实输入 0、1 或 2！${plain}"
                ;;
        esac
    done

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
        echo -e "${yellow}提示: 如果您还没准备好，直接输入 0 回车即可安全退出。${plain}\n"

        read -p "👉 请粘贴您的 Cloudflare Tunnel Token: " ARGO_TOKEN
        # 防呆退出点 2
        if [[ "$ARGO_TOKEN" == "0" || -z "$ARGO_TOKEN" ]]; then
            echo -e "\n${red}已取消操作，安全返回主界面。${plain}"
            sleep 1
            return
        fi

        # 👑 核心优化：强行物理除垢，去掉所有可能的空格、换行符
        ARGO_TOKEN=$(echo "$ARGO_TOKEN" | tr -d ' ' | tr -d '\n' | tr -d '\r')

        read -p "👉 请输入您刚才在 CF 后台绑定的固定域名 (如 argo.xxx.com): " ARGO_DOMAIN
        ARGO_DOMAIN=$(echo "$ARGO_DOMAIN" | tr -d ' ')
        if [[ -z "$ARGO_DOMAIN" || "$ARGO_DOMAIN" == "0" ]]; then
            echo -e "\n${red}❌ 域名为空或已取消操作！${plain}"
            sleep 1
            return
        fi
        
        # 👑 联动优化：把固定域名写入本地雷达缓存，供 UI 大屏提取展示
        mkdir -p /usr/local/etc
        echo "$ARGO_DOMAIN" > /usr/local/etc/vx_argo_domain.txt 2>/dev/null

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
       ARGO_DOMAIN=$(journalctl -u vx-argo -n 50 --no-pager | grep -oE "https://[a-zA-Z0-9-]+\.trycloudflare\.com" | tail -n 1 | sed 's/https:\/\///')
        
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
    update_sub
    echo -e "\n${green}🎉 Argo 隧道挂载成功！哪怕服务器 IP 被墙，此节点依然坚挺！${plain}"
    if [[ "$ARGO_MODE" == "2" ]]; then
        echo -e "${purple}🛡️ 当前模式: 固定隧道 (Zero Trust)${plain}"
    else
        echo -e "${purple}⏱️ 当前模式: 临时穿透 (trycloudflare)${plain}"
    fi
    echo -e "${cyan}🌐 专属防御域名: ${plain}${green}${ARGO_DOMAIN}${plain}"
    echo -e "${yellow}💡 极客提示: 节点已内置高通透免流 IP (www.visa.com) 以确保小白即连即用。${plain}"
    read -p "👉 按回车返回大屏，按【f】即可提取这个复活甲节点..."
}

# ==================================================
# 🔄 OTA 热更新引擎: 脚本与内核双轨升级
# ==================================================
function update_ota() {
    clear
    echo -e "${cyan}======================================================================${plain}"
    echo -e "             🔄 VeloX OTA 智能热更新引擎"
    echo -e "${cyan}======================================================================${plain}"

    # --- 1. 更新面板脚本自身 ---
    echo -e "${yellow}>>> [1/2] 正在检测面板脚本更新...${plain}"
    curl -sL "$SCRIPT_URL" -o /tmp/vx_new.sh
    if [[ -f /tmp/vx_new.sh && -s /tmp/vx_new.sh ]]; then
        # 🚀 极客防呆：必须在 /tmp 里先验尸！语法满分才允许覆盖本体！
        if bash -n /tmp/vx_new.sh; then
            mv -f /tmp/vx_new.sh /usr/local/bin/vx
            chmod +x /usr/local/bin/vx
            echo -e "${green}✅ 面板脚本已同步至 GitHub 最新版本！${plain}"
        else
            echo -e "\n${red}❌ 致命拦截：拉取的云端代码存在语法损坏 (可能是网络中断或 GitHub 抽风)！${plain}"
            echo -e "${yellow}💡 极客装甲已强行阻断覆盖，成功保住了当前运行中的老版本！${plain}"
            rm -f /tmp/vx_new.sh
            read -p "👉 按回车键返回大屏..." && return
        fi
    else
        echo -e "${red}❌ 脚本拉取失败，请检查网络！${plain}"
        read -p "👉 按回车键返回大屏..." && return
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
    echo -e "🚀 ${green}准备就绪！正在启动热重载引擎 (Hot Reloading)...${plain}"
    sleep 1.5
    
    # 💥 既然前面已经验过尸了，这老伙计安全得很，直接夺舍进程起飞！
    exec /usr/local/bin/vx
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
   if [[ "$PROTOCOL" == "VMESS" ]]; then
            # 暴力破解：直接把当前的 vmess 链接进行 Base64 解码，看里面的核心内容
            VM_JSON=$(echo "$line" | sed 's/vmess:\/\///' | base64 -d 2>/dev/null)
            
            if [[ "$VM_JSON" == *".trycloudflare.com"* ]]; then
                echo -e "\n${purple}【 VMESS 协议 (Argo 临时隧道) 】${plain}"
            elif [[ "$VM_JSON" == *"Argo"* || "$VM_JSON" == *"argo"* ]]; then
                echo -e "\n${purple}【 VMESS 协议 (Argo 固定隧道) 】${plain}"
            else
                echo -e "\n${purple}【 VMESS 协议 (直连/常规) 】${plain}"
            fi
        else
            echo -e "\n${purple}【 $PROTOCOL 协议 】${plain}"
        fi
      echo -e "${green}🔗 分享链接【双击下方链接快速纯净复制】:${plain}"
        echo -e "${yellow}${line}${plain}\n"
        echo -e "📱 专属节点二维码:"
        echo "$line" | qrencode -t UTF8
        echo -e "${cyan}-------------------------------------------------------------${plain}"
    done
    
    echo -e "${yellow}>>> 🔗 聚合 Base64 订阅编码 (供电脑端一键复制导入)：${plain}"
    B64_LINKS=$(cat "$LINK_FILE" | base64 -w 0)
    echo -e "${blue}${B64_LINKS}${plain}\n"
    echo -e " 🚀 ${green}节点已满血复活！如果您觉得好用，请为大佬点个 Star ⭐${plain}"
    echo -e " 🔗 项目地址: ${cyan}https://github.com/pwenxiang51-wq/VX-Node-Engine${plain}"
    echo -e "${cyan}=============================================================${plain}"
}

# === 🗑️ [修正版] 终极自毁程序: 彻底卸载与清理 (寸草不生版) ===
function uninstall_vne() {
    clear
    echo -e "${red}======================================================================${plain}"
    echo -e "                 🗑️ 【 极客警告：终极焦土化卸载程序 】"
    echo -e "${red}======================================================================${plain}"
    echo -e "${yellow}⚠️ 警告：此操作将执行最彻底的物理级拔管！"
    echo -e "以下防弹装甲将被连根拔起，化为灰烬：${plain}"
    echo -e "  💀 核心引擎：VLESS / Hys2 / TUIC / VMess / Trojan (Sing-box/VX)"
    echo -e "  💀 战术外挂：Acme 证书 / Argo 隧道 / WARP 优选 / TG 哨兵 / 订阅服务"
    echo -e "  💀 运维残留：所有配置文件、定时任务、快捷指令"
    echo -e "${cyan}注：BBR 底层网络优化属于系统内核级增益，将为您永久保留。${plain}"
    echo -e "${red}======================================================================${plain}"
    
    read -p "👉 最后确认：是否执行终极焦土化清理？(y/N): " confirm
    if [[ "$confirm" != "y" && "$confirm" != "Y" ]]; then
        echo -e "${green}✅ 操作已取消，防弹装甲继续为您服役。${plain}"
        sleep 1
        return
    fi

    echo -e "\n${yellow}>>> 💥 [1/5] 正在启动猎杀程序，物理拔管所有核心进程...${plain}"
    # 猎杀所有可能运行的服务 (使用变量)
    systemctl stop vx-core cloudflared warp-svc vx-sub vx-sub-https vx-argo vx-tg-sentinel 2>/dev/null
    systemctl disable vx-core cloudflared warp-svc vx-sub vx-sub-https vx-argo vx-tg-sentinel 2>/dev/null
    # 清理 Systemd 守护进程文件 (使用变量精准删除)
    rm -f "$SERVICE_FILE" /etc/systemd/system/cloudflared.service /etc/systemd/system/vx-tg-sentinel.service /etc/systemd/system/vx-argo.service /etc/systemd/system/vx-sub.service /etc/systemd/system/vx-sub-https.service 2>/dev/null
    systemctl daemon-reload

   echo -e "${yellow}>>> 💥 [2/5] 正在粉碎战术外挂 (Argo / WARP / Acme)...${plain}"
    # 爆破 Argo 隧道与 Cloudflared 二进制
    rm -rf /etc/cloudflared /root/.cloudflared 2>/dev/null
    rm -f /usr/local/bin/cloudflared /usr/bin/cloudflared 2>/dev/null
    
    # 爆破 WARP 及 APT 基因污染残渣 (极客补枪)
    if command -v warp-cli &> /dev/null; then warp-cli disconnect 2>/dev/null; fi
    # 👇 剥离条件判断，无视状态进行无差别物理粉碎与除垢
    apt-get purge -y cloudflare-warp 2>/dev/null
    rm -rf /var/lib/cloudflare-warp /etc/cloudflare-warp 2>/dev/null
    
    if command -v wg-quick &> /dev/null; then wg-quick down wgcf 2>/dev/null; rm -rf /etc/wireguard/wgcf* 2>/dev/null; fi
    rm -f /usr/share/keyrings/cloudflare-warp-archive-keyring.gpg /etc/apt/sources.list.d/cloudflare-client.list 2>/dev/null
    
    # 爆破 Acme.sh
    if [[ -f ~/.acme.sh/acme.sh ]]; then ~/.acme.sh/acme.sh --uninstall 2>/dev/null; fi
    rm -rf ~/.acme.sh 2>/dev/null
    
    # 物理超度订阅引擎的底层僵尸进程 (极客补枪)
    pkill -9 -f "busybox httpd" 2>/dev/null
    pkill -9 -f "socat openssl-listen" 2>/dev/null

    echo -e "${yellow}>>> 💥 [3/5] 正在焦土化清理定时任务 (OTA与雷达哨兵)...${plain}"
    crontab -l 2>/dev/null | grep -vE "acme.sh|vx|tg" | crontab -

   echo -e "${yellow}>>> 💥 [4/5] 正在深层抹除配置文件目录与核心二进制...${plain}"
    # 【致命错误修正】：精准抹除 /etc/velox_vne，决不能硬编码写 /etc/vx
    # === 💥 极客补枪：封闭订阅引擎随机开出的端口 ===
    for SUB_F in "$CONF_DIR/sub_port.txt" "$CONF_DIR/sub_port_https.txt"; do
        if [[ -f "$SUB_F" ]]; then
            SPORT=$(cat "$SUB_F" 2>/dev/null)
            if [[ -n "$SPORT" ]]; then
                command -v ufw &> /dev/null && { ufw delete allow $SPORT/tcp >/dev/null 2>&1; }
                command -v iptables &> /dev/null && { iptables -D INPUT -p tcp --dport $SPORT -j ACCEPT 2>/dev/null; }
            fi
        fi
    done
    # ========================================================
   if [[ -f "$JSON_FILE" ]]; then
       local PORTS=$(jq -r '.inbounds[].listen_port' "$JSON_FILE" 2>/dev/null | grep -v null)
       for PORT in $PORTS; do
           if command -v ufw &> /dev/null; then
               ufw delete allow $PORT/tcp >/dev/null 2>&1
               ufw delete allow $PORT/udp >/dev/null 2>&1
           fi
           if command -v firewall-cmd &> /dev/null; then
               firewall-cmd --zone=public --remove-port=$PORT/tcp --permanent >/dev/null 2>&1
               firewall-cmd --zone=public --remove-port=$PORT/udp --permanent >/dev/null 2>&1
           fi
           if command -v iptables &> /dev/null; then
               iptables -D INPUT -p tcp --dport $PORT -j ACCEPT 2>/dev/null
               iptables -D INPUT -p udp --dport $PORT -j ACCEPT 2>/dev/null
               if command -v ip6tables &> /dev/null; then
                   ip6tables -D INPUT -p tcp --dport $PORT -j ACCEPT 2>/dev/null
                   ip6tables -D INPUT -p udp --dport $PORT -j ACCEPT 2>/dev/null
               fi
           fi
       done
       if command -v firewall-cmd &> /dev/null; then firewall-cmd --reload >/dev/null 2>&1; fi
       if command -v netfilter-persistent &> /dev/null; then netfilter-persistent save >/dev/null 2>&1; fi
   fi
   # ========================================================
    rm -rf "$CONF_DIR" # 使用 CONF_DIR 变量，决不再犯错
    rm -f "$BIN_FILE"  # 使用 BIN_FILE 变量，决不留后门
    rm -rf /usr/local/vx /tmp/sing-box* 2>/dev/null
    rm -f /usr/local/bin/vx-tg-sentinel.sh 2>/dev/null
    
    # 抹除 TG 哨兵记忆碎片与全局凭证 (极客补枪)
    rm -f /etc/velox_tg.conf /root/.vx_known_ips 2>/dev/null

    # 抹除核心控制台指令
    rm -f /usr/local/bin/vx 2>/dev/null
    rm -f /usr/bin/vx 2>/dev/null

    echo -e "\n${green}🎉 [5/5] 焦土化清理竣工！系统已恢复至出厂级纯净状态！${plain}"
    echo -e "${cyan}山高水长，江湖再见！退网保平安！${plain}"

    # 👇 极客级 UX 优化：留下复活传送门
    echo -e "${purple}----------------------------------------------------------------------${plain}"
    echo -e "${yellow}💡 若需重新满血装载 VeloX 引擎，请直接复制并执行下方指令：${plain}"
    echo -e "${green}bash <(curl -sL https://raw.githubusercontent.com/pwenxiang51-wq/VX-Node-Engine/main/vx.sh)${plain}"
    echo -e "${purple}----------------------------------------------------------------------${plain}\n"
    
    # 【极客优化版自毁】：智能侦测虚拟管道，彻底消灭 fd 报错
    unset functions
    if [[ "$0" != /dev/fd/* && -f "$0" ]]; then
        (sleep 1 && rm -f "$0") &
    fi
    exit 0
}

# ==================================================
# 📜 引擎进化编年史 (全量云端快照)
# ==================================================
function view_changelog() {
    clear
    echo -e "${cyan}======================================================================${plain}"
    echo -e "                 📜 VeloX Node Engine 进化编年史"
    echo -e "${cyan}======================================================================${plain}"
    echo -e "${yellow}>>> 正在同步云端战斗日志...${plain}\n"
    
    local FULL_LOG=$(curl -s -m 5 "https://raw.githubusercontent.com/pwenxiang51-wq/VX-Node-Engine/main/changelog.txt" 2>/dev/null)
    
    if [[ -n "$FULL_LOG" ]]; then
        echo "$FULL_LOG" | while IFS= read -r line; do
            if [[ "$line" == \[* ]]; then
                echo -e "${purple}${line}${plain}"
            else
                echo -e "${green}${line}${plain}"
            fi
        done
    else
        echo -e "${red}❌ 同步超时！请检查 GitHub RAW 连通性。${plain}"
    fi
    
    echo -e "\n${cyan}======================================================================${plain}"
    read -p "👉 阅毕，请按回车键返回指挥中心..."
}

# ==================================================
# 📖 隐藏式避坑指南与面板说明 (V5.4 扩充版)
# ==================================================
function show_help() {
    clear
    echo -e "${cyan}======================================================================${plain}"
    echo -e "                 📖 VeloX Node Engine (VX) 极客战术白皮书"
    echo -e "${cyan}======================================================================${plain}"
    
    echo -e "${yellow}💡 【核心战术 1】：底层协议矩阵该怎么选？${plain}"
    echo -e "  - ${green}VLESS / Trojan${plain}: 伪装顶级大厂域名，走 TCP 协议，属于【常驻防弹装甲】，稳如老狗。"
    echo -e "  - ${green}Hysteria2 / TUIC${plain}: 走底层的 QUIC (UDP) 协议，属于【暴力加速引擎】，专治各种跨国网络晚高峰炸裂。"
    echo -e "  - ${green}VMess-WS${plain}: 脚本内的【黄金底座】。它默认穿戴 TLS，但随时准备为 CDN 或 Argo 献身脱甲。"
    echo -e ""

    echo -e "${purple}🚀 【战术核心 2】：市面最强的 Argo 复活甲 (独家降维打击)！${plain}"
    echo -e "  与其他脚本繁琐的配置不同，VX 引擎实现了大厂网关级的【状态机自愈】逻辑："
    echo -e "  1. 先按【4】压入 VMess-WS 协议 (系统会自动给它穿上 TLS 满血装甲)。"
    echo -e "  2. IP 被墙了？直接按【e】开启 Argo！引擎会自动把 VMess 的 TLS 物理剥离，瞬间接管 CF 地下隧道！"
    echo -e "  3. Argo 不想用了？再按【e】拆除！VMess 会瞬间被脚本【重新焊回 TLS 装甲】，原地满血复活！"
    echo -e "  👉 ${cyan}全程无需手搓任何配置，物理卸甲 -> 隧道穿透 -> 拆除重铸，一气呵成！${plain}"
    echo -e ""

    echo -e "${blue}🛡️ 【战术外挂 3】：高阶极客玩法揭秘${plain}"
    echo -e "  - ${cyan}[6] 大满贯装载${plain}: 懒人终极杀器。10秒钟自动智能探测碰撞端口，5大神级协议全量部署，防火墙一次性打穿。"
    echo -e "  - ${cyan}[b] 一键换皮${plain}: UDP 协议 (Hy2/TUIC) 跑久了被墙盯上变慢？按 b 键一秒重置底层乱码 SNI，金蝉脱壳！"
    echo -e "  - ${cyan}[d] WARP 解锁${plain}: 挂载 SOCKS5 本地探针，精准分流 OpenAI 和 Netflix，且绝对不会让 VPS 物理失联。"
    echo -e "  - ${cyan}[h] 节点哨兵${plain}: 绑定 TG 机器人后，只要有新 IP 连入节点，手机立刻弹预警！谁也别想白嫖流量！"
    echo -e ""

    echo -e "${red}⚠️ 【生死红线】：NAT 小鸡 (端口受限) 警告${plain}"
    echo -e "  如果你的 VPS 是那种没有独立公网 IP、只能用几个转发端口的 NAT 机器，${red}绝对不要按【6】大满贯！${plain}"
    echo -e "  乖乖用【1-5】单独部署，并手动输入你的可用端口。或者直接用【e】挂载 Argo 强行无视 NAT 穿透！"
    echo -e "${cyan}======================================================================${plain}"
    read -p "👉 阅毕，请按回车键返回指挥中心..."
}

# ==================================================
# 📺 流媒体与 AI 智能测速中心
# ==================================================
function test_media_unlock() {
    clear
    echo -e "${cyan}======================================================================${plain}"
    echo -e "                 📺 流媒体与 AI 解锁终极检测中心"
    echo -e "${cyan}======================================================================${plain}"
    
    # 智能判断：检测是否已经挂载了 WARP
    if jq -e '.outbounds[] | select(.tag == "warp-socks")' "$JSON_FILE" >/dev/null 2>&1; then
        echo -e "${green}>>> 检测到 WARP 护盾已开启！正在通过底层 40000 端口进行深度穿透检测...${plain}"
        echo -e "${yellow}💡 提示: 测速脚本正在拉取中，大约需要 1-2 分钟，请耐心等待。${plain}\n"
        ALL_PROXY=socks5h://127.0.0.1:40000 bash <(curl -x socks5h://127.0.0.1:40000 -sL https://github.com/lmc999/RegionRestrictionCheck/raw/main/check.sh)
    else
        echo -e "${yellow}>>> 检测到当前为原机直连状态，正在测速原生 IP 解锁能力...${plain}\n"
        bash <(curl -sL https://github.com/lmc999/RegionRestrictionCheck/raw/main/check.sh)
    fi
    
    echo -e "\n${cyan}======================================================================${plain}"
    read -p "👉 测试完毕！按回车键返回大屏..."
}


# ==================================================
# 🕵️ 节点防盗哨兵 (SSH 直显大屏 + 全自动后台抓鬼)
# ==================================================
function node_sentinel() {
    while true; do
        clear
        echo -e "${cyan}======================================================================${plain}"
        echo -e "                 🕵️ 节点防盗哨兵 (全息监控与后台雷达)"
        echo -e "${cyan}======================================================================${plain}"

        if ! systemctl is-active --quiet vx-core.service; then
            echo -e "${red}❌ 致命错误：代理核心未运行，无法抓取日志！${plain}"
            read -p "👉 按回车返回主菜单..." && return
        fi

        # 动态侦测后台守护进程状态
        if systemctl is-active --quiet vx-tg-sentinel 2>/dev/null; then
            DAEMON_STAT="${green}[后台守护中]✅${plain}"
        else
            DAEMON_STAT="${yellow}[未部署]⚠️${plain}"
        fi

        echo -e "  ${green}1.${plain} 📊 极客大屏：分析过去 24 小时连接 IP 与归属地 (直接看)"
        echo -e "  ${green}2.${plain} 📺 实时滚动：全自动动态日志追踪 (按 Ctrl+C 退出)"
        echo -e "  ${cyan}3.${plain} 📡 部署/拆除：全自动 TG 雷达哨兵 ${DAEMON_STAT}"
        echo -e "      ${yellow}└─ 开启后只要有【分享的新用户 / 宽带变IP】连入，自动报警！${plain}"
        echo -e "  ${purple}4.${plain} 🧹 清理已知 IP 缓存 (让旧 IP 重新触发 TG 报警)"
        echo -e "  ${blue}5.${plain} ⚙️ 更改/删除 TG 机器人配置 (全局凭证池管理)"
        echo -e "  ${red}6.${plain} 🚫 物理拔管：一键封杀指定 IP (网络层黑洞阻断)"
        echo -e "  ${green}7.${plain} ♻️ 诈尸复活：一键解封被关小黑屋的 IP"
        echo -e "  ${yellow}0.${plain} 🔙 返回主菜单"
        echo -e "${cyan}----------------------------------------------------------------------${plain}"
        read -p "👉 请选择操作 [0-7]: " sen_choice

        case "$sen_choice" in
            1)
                echo -e "\n${yellow}>>> 正在解析 Sing-box 底层日志，提取有效人类活动 IP...${plain}"
                local raw_ips=$(journalctl -u vx-core.service --since "24 hours ago" --no-pager | grep "inbound connection from" | grep -oE "\b([0-9]{1,3}\.){3}[0-9]{1,3}\b" | grep -v -E "^(127\.|10\.|192\.168\.|172\.)" | sort -u)

                if [[ -z "$raw_ips" ]]; then
                    echo -e "${green}✅ 报告：暂未发现外部连接，节点如防空洞般清净！${plain}"
                else
                    echo -e "\n${blue} 序号 |      外部 IP      |   归属地 (国家/城市)   |   运营商/组织${plain}"
                    echo -e "${cyan}----------------------------------------------------------------------${plain}"
                    local i=1
                    for ip in $raw_ips; do
                        local info=$(curl -s4m3 "http://ip-api.com/json/$ip?lang=zh-CN")
                        local country=$(echo "$info" | jq -r '.country // "未知国家"')
                        local region=$(echo "$info" | jq -r '.regionName // "未知省份"')
                        local city=$(echo "$info" | jq -r '.city // "未知城市"')
                        local isp=$(echo "$info" | jq -r '.isp // "未知运营商"')
                        printf " ${yellow}[%02d]${plain} | %-15s | %-20s | %s\n" "$i" "$ip" "$country $region $city" "$isp"
                        let i++
                    done
                    echo -e "${cyan}----------------------------------------------------------------------${plain}"
                fi
                read -p "👉 审查完毕！按回车键返回哨兵菜单..."
                ;;
             2)
               echo -e "\n${cyan}>>> 正在进入动态日志追踪模式 (按 Ctrl+C 退出)...${plain}"
               trap 'echo -e "\n安全返回哨兵菜单..."' INT
               TZ="Asia/Shanghai" journalctl -u vx-core.service -f | grep --line-buffered "inbound connection from"
               trap - INT
               sleep 1
               ;;
             3)
                if systemctl is-active --quiet vx-tg-sentinel 2>/dev/null; then
                    echo -e "\n${yellow}>>> 正在拆除全自动后台雷达...${plain}"
                    systemctl stop vx-tg-sentinel >/dev/null 2>&1
                    systemctl disable vx-tg-sentinel >/dev/null 2>&1
                    rm -f /etc/systemd/system/vx-tg-sentinel.service
                    rm -f /usr/local/bin/vx-tg-sentinel.sh
                    systemctl daemon-reload
                    echo -e "${green}✅ 后台自动报警守护进程已彻底粉碎！${plain}"
                else
                    echo -e "\n${cyan}=== 🚀 正在部署【全自动静默监听雷达】 ===${plain}"
                    TG_CONF="/etc/velox_tg.conf"
                    if [[ -f "$TG_CONF" ]]; then source "$TG_CONF"; fi
                    if [[ -z "$GLOBAL_TG_TOKEN" || -z "$GLOBAL_TG_CHATID" ]]; then
                        echo -e "${yellow}💡 需绑定 TG 机器人，以后只要后台发现新 IP 连接，自动推送！${plain}"
                        read -p "🔑 请输入 TG Bot Token: " input_token
                        read -p "💬 请输入 TG Chat ID: " input_chatid
                        if [[ -z "$input_token" || -z "$input_chatid" ]]; then
                            echo -e "${red}❌ 输入为空，已取消部署。${plain}"; read -p "按回车返回哨兵菜单..."; continue
                        fi
                        echo "GLOBAL_TG_TOKEN=\"$input_token\"" > "$TG_CONF"
                        echo "GLOBAL_TG_CHATID=\"$input_chatid\"" >> "$TG_CONF"
                        GLOBAL_TG_TOKEN="$input_token"
                        GLOBAL_TG_CHATID="$input_chatid"
                    else
                        echo -e "${green}✅ 检测到全局公共池凭证，已自动复用！${plain}"
                    fi

                    cat << 'EOF' > /usr/local/bin/vx-tg-sentinel.sh
#!/bin/bash
export TZ="Asia/Shanghai"
source /etc/velox_tg.conf
touch /root/.vx_known_ips

journalctl -u vx-core.service -f -n 0 | grep --line-buffered "inbound connection from" | while read line; do
    IP=$(echo "$line" | grep -oE "\b([0-9]{1,3}\.){3}[0-9]{1,3}\b" | head -n 1)
    [ -z "$IP" ] && continue
    [[ "$IP" =~ ^(127\.|10\.|172\.|192\.168\.) ]] && continue
    
    if ! grep -q "^$IP$" /root/.vx_known_ips 2>/dev/null; then
        echo "$IP" >> /root/.vx_known_ips
       INFO=$(curl -s4m3 "http://ip-api.com/json/$IP?lang=zh-CN")
        COUNTRY=$(echo "$INFO" | jq -r '.country // "未知国家"')
        REGION=$(echo "$INFO" | jq -r '.regionName // "未知省份"')
        CITY=$(echo "$INFO" | jq -r '.city // "未知城市"')
        ISP=$(echo "$INFO" | jq -r '.isp // "未知运营商"')
        
HOST_NAME=$(hostname)
        MSG="🚨 <b>[VX 智能雷达触发]</b>
大佬，侦测到【全新 IP】接入您的节点！

🖥️ <b>受访阵地:</b> <code>${HOST_NAME}</code>
👉 <b>来源 IP:</b> <code>$IP</code>
🌍 <b>归属地:</b> $COUNTRY $REGION $CITY
🏢 <b>运营商:</b> $ISP
⏰ <b>北京时间:</b> $(date +'%Y-%m-%d %H:%M:%S')

<i>(注：您分享的新用户，或您的宽带动态 IP 变更，都会触发此警报)</i>"
        curl -s -X POST "https://api.telegram.org/bot${GLOBAL_TG_TOKEN}/sendMessage" -d chat_id="${GLOBAL_TG_CHATID}" -d text="$MSG" -d parse_mode="HTML" > /dev/null 2>&1
    fi
done
EOF
                    chmod +x /usr/local/bin/vx-tg-sentinel.sh

                    cat << EOF > /etc/systemd/system/vx-tg-sentinel.service
[Unit]
Description=Velox TG Sentinel Background Radar
After=vx-core.service

[Service]
Type=simple
ExecStart=/usr/local/bin/vx-tg-sentinel.sh
Restart=always
RestartSec=5

[Install]
WantedBy=multi-user.target
EOF
                    systemctl daemon-reload
                    systemctl enable --now vx-tg-sentinel >/dev/null 2>&1
                    echo -e "${green}✅ 全自动监听雷达已潜伏入系统底层！${plain}"
                fi
                read -p "👉 按回车返回哨兵菜单..."
                ;;
            4)
                echo -e "\n${yellow}正在清空已记录的 IP 白名单缓存...${plain}"
                > /root/.vx_known_ips
                systemctl restart vx-tg-sentinel 2>/dev/null
                echo -e "${green}✅ 清理完毕！你的手机当前 IP 只要再产生流量，就会被当作“新面孔”再次触发 TG 报警！${plain}"
                read -p "👉 按回车返回哨兵菜单..."
                ;;
            5)
                echo -e "\n${cyan}=== ⚙️ TG 机器人全局凭证管理 ===${plain}"
               if [[ -f "/etc/velox_tg.conf" ]]; then
            source "/etc/velox_tg.conf"
            # 🚀 开启军用级数据脱敏装甲
            MASKED_TOKEN="${GLOBAL_TG_TOKEN:0:8}********${GLOBAL_TG_TOKEN: -5}"
            MASKED_CHATID="${GLOBAL_TG_CHATID:0:3}****${GLOBAL_TG_CHATID: -2}"
            echo -e "当前绑定的 Token: ${green}${MASKED_TOKEN}${plain}"
            echo -e "当前绑定的 Chat ID: ${green}${MASKED_CHATID}${plain}"
        else
                    echo -e "${yellow}⚠️ 当前全局池为空。${plain}"
                fi
                echo -e "\n请选择操作："
                echo -e "  ${green}1.${plain} 重新输入并物理覆盖配置 (双面板联动生效)"
                echo -e "  ${red}2.${plain} 彻底删除全局凭证 (💥 将同时强拆 VX 与 Velox 的所有预警雷达)"
                echo -e "  ${yellow}0.${plain} 取消并返回"
                read -p "👉 请选择 [0-2]: " cred_choice
                case "$cred_choice" in
                    1)
                        read -p "🔑 请输入新的 TG Bot Token: " new_token
                        read -p "💬 请输入新的 TG Chat ID: " new_chatid
                        if [[ -n "$new_token" && -n "$new_chatid" ]]; then
                            echo "GLOBAL_TG_TOKEN=\"$new_token\"" > /etc/velox_tg.conf
                            echo "GLOBAL_TG_CHATID=\"$new_chatid\"" >> /etc/velox_tg.conf
                            echo -e "${green}✅ 全局凭证已物理覆写！${plain}"
                            
                            if systemctl is-active --quiet vx-tg-sentinel 2>/dev/null; then
                                systemctl restart vx-tg-sentinel
                                echo -e "${green}🔄 侦测到 VX 节点哨兵正在运行，已自动联动热重载！${plain}"
                            fi
                            echo -e "${green}🔄 若已部署 Velox 面板的警报防线，下次触发时也将自动使用新凭证！${plain}"
                        else
                            echo -e "${red}❌ 输入无效，操作已取消。${plain}"
                        fi
                        ;;
                    2)
                        rm -f /etc/velox_tg.conf
                        echo -e "${green}🗑️ 全局 TG 配置文件已被物理蒸发！${plain}"
                        
                        # 跨进程联动拆除 VX 哨兵
                        if systemctl is-active --quiet vx-tg-sentinel 2>/dev/null || [ -f "/usr/local/bin/vx-tg-sentinel.sh" ]; then
                            systemctl stop vx-tg-sentinel >/dev/null 2>&1
                            systemctl disable vx-tg-sentinel >/dev/null 2>&1
                            rm -f /etc/systemd/system/vx-tg-sentinel.service /usr/local/bin/vx-tg-sentinel.sh
                            echo -e "${yellow}⚠️ 已联动拆除 VX 节点哨兵守护进程！${plain}"
                        fi
                        
                        # 跨进程联动拆除 Velox 报警
                        if [ -f "/usr/local/bin/ssh_tg_alert.sh" ]; then
                            sudo rm -f /usr/local/bin/ssh_tg_alert.sh /usr/local/bin/tg_boot_alert.sh /etc/systemd/system/tg_boot_alert.service
                            sudo sed -i '/ssh_tg_alert.sh/d' /etc/profile /etc/bash.bashrc
                            sudo systemctl disable --now tg_boot_alert.service >/dev/null 2>&1
                            if crontab -l 2>/dev/null | grep -q "api.telegram.org"; then crontab -l 2>/dev/null | grep -v "api.telegram.org" | crontab -; fi
                            echo -e "${yellow}⚠️ 已联动物理拔管 Velox 的 SSH 与开机报警防线！${plain}"
                        fi
                        systemctl daemon-reload
                        ;;
                esac
                read -p "👉 按回车返回哨兵菜单..."
                ;;
            6)
                echo -e "\n${yellow}>>> 正在启动极客物理拔管协议 (Ubuntu 内核层拦截)...${plain}"
                # === 🚀 新增：小黑屋透视雷达 ===
                echo -e "\n${cyan}======================================================${plain}"
                echo -e "☠️  当前【小黑屋】在押囚犯名单 (内核层已被封杀 IP)："
                
                > /tmp/vx_banned_ips.txt
                # 探针：直插 iptables 底层提取 DROP 规则
                iptables -L INPUT -n 2>/dev/null | grep "DROP" | awk '{print $4}' | grep -v "0.0.0.0/0" | sort -u > /tmp/vx_banned_ips.txt

                if [[ -s /tmp/vx_banned_ips.txt ]]; then
                    cat /tmp/vx_banned_ips.txt | while read banned_ip; do
                        echo -e " ⛓️  ${red}${banned_ip}${plain}"
                    done
                else
                    echo -e " 🈳 目前小黑屋空空如也，天下太平。"
                fi
                rm -f /tmp/vx_banned_ips.txt
                echo -e "${cyan}======================================================${plain}\n"
                # ================================
                read -p "👉 请输入要封杀的 IP (直接回车取消): " kill_ip
                if [[ -n "$kill_ip" ]]; then
                    # 🛡️ 顶级安全规范：正则校验输入是否为合法 IPv4/IPv6 格式
                    if [[ "$kill_ip" =~ ^[0-9]{1,3}(\.[0-9]{1,3}){3}$ ]] || [[ "$kill_ip" =~ ^[0-9a-fA-F:]+$ ]]; then
                        iptables -I INPUT -s "$kill_ip" -j DROP 2>/dev/null
                        ip6tables -I INPUT -s "$kill_ip" -j DROP 2>/dev/null
                        echo -e "${green}✅ 成功斩断！IP: ${kill_ip} 已被强行打入冷宫，对方客户端将永久超时！${plain}"
                        if command -v netfilter-persistent &> /dev/null; then netfilter-persistent save >/dev/null 2>&1; fi
                    else
                        echo -e "${red}❌ 致命拦截：输入格式非法！VX 引擎拒绝执行污染指令！${plain}"
                        sleep 2
                    fi
                fi
                read -p "👉 按回车返回哨兵菜单..."
                ;;
            7)
                echo -e "\n${yellow}>>> 正在启动大赦天下协议 (解封 IP)...${plain}"
                # === 🚀 新增：小黑屋透视雷达 ===
                echo -e "\n${cyan}======================================================${plain}"
                echo -e "☠️  当前【小黑屋】在押囚犯名单 (内核层已被封杀 IP)："
                
                > /tmp/vx_banned_ips.txt
                # 探针：直插 iptables 底层提取 DROP 规则
                iptables -L INPUT -n 2>/dev/null | grep "DROP" | awk '{print $4}' | grep -v "0.0.0.0/0" | sort -u > /tmp/vx_banned_ips.txt

                if [[ -s /tmp/vx_banned_ips.txt ]]; then
                    cat /tmp/vx_banned_ips.txt | while read banned_ip; do
                        echo -e " ⛓️  ${red}${banned_ip}${plain}"
                    done
                else
                    echo -e " 🈳 目前小黑屋空空如也，天下太平。"
                fi
                rm -f /tmp/vx_banned_ips.txt
                echo -e "${cyan}======================================================${plain}\n"
                # ================================
                read -p "👉 请输入要释放的 IP (直接回车取消): " free_ip
                if [[ -n "$free_ip" ]]; then
                    # 🛡️ 顶级安全规范：同样进行正则强校验
                    if [[ "$free_ip" =~ ^[0-9]{1,3}(\.[0-9]{1,3}){3}$ ]] || [[ "$free_ip" =~ ^[0-9a-fA-F:]+$ ]]; then
                        iptables -D INPUT -s "$free_ip" -j DROP 2>/dev/null
                        ip6tables -D INPUT -s "$free_ip" -j DROP 2>/dev/null
                        echo -e "${green}✅ 解封成功！IP: ${free_ip} 已经被释放回阳间。${plain}"
                        if command -v netfilter-persistent &> /dev/null; then netfilter-persistent save >/dev/null 2>&1; fi
                    else
                        echo -e "${red}❌ 致命拦截：输入格式非法！VX 引擎拒绝执行污染指令！${plain}"
                        sleep 2
                    fi
                fi
                read -p "👉 按回车返回哨兵菜单..."
                ;;
            0) break ;;
            *) echo -e "${red}❌ 无效选择！${plain}"; sleep 1 ;;
        esac
    done
}

# === 🚀 极客快捷指令拦截器 (CLI 模式) ===
if [[ "$1" == "log" || "$1" == "radar" || "$1" == "sentinel" ]]; then
    trap 'echo -e "\n返回命令行..."' INT
    TZ="Asia/Shanghai" journalctl -u vx-core.service -f | grep --line-buffered "inbound connection from"
    trap - INT
    exit 0
fi

# === 🔄 降维打击：一键换皮引擎 (重置 UDP 防探针乱码装甲) [修复版] ===
function reset_random_sni() {
    clear
    echo -e "${cyan}======================================================================${plain}"
    echo -e "         🔄 正在启动 UDP 暴力层 (Hy2/TUIC) 一键换皮装甲"
    echo -e "${cyan}======================================================================${plain}"

    if [[ ! -f "$JSON_FILE" ]]; then
        echo -e "${red}❌ 致命错误: 核心配置不存在，请先装载节点！${plain}"
        read -p "👉 按回车返回大屏..." && return
    fi

    if [[ -f "$CERT_DIR/acme.crt" && -f "$CERT_DIR/acme_domain.txt" ]]; then
        echo -e "${green}✅ 系统检测到您正在使用真实域名证书，自带满血防弹属性，无需换皮！${plain}"
        read -p "👉 按回车返回大屏..." && return
    fi

    # 智能侦测：检查底层究竟有没有装载这两个协议
    if ! jq -e '.inbounds[] | select(.tag == "hy2-in" or .tag == "tuic-in")' "$JSON_FILE" >/dev/null 2>&1; then
        echo -e "${yellow}⚠️ 未检测到运行中的 Hy2/TUIC 协议，无需换皮。${plain}"
        read -p "👉 按回车返回大屏..." && return
    fi

   # 锻造新装甲
    local NEW_UDP_SNI="$(tr -dc 'a-z0-9' </dev/urandom | head -c 8).net"
    echo -e "${yellow}>>> 正在启动正则焦土化打击，注入全新随机伪装: ${NEW_UDP_SNI}${plain}"

    # 重新发证
    generate_cert_dynamic "$NEW_UDP_SNI" >/dev/null 2>&1

    # 原子级 JQ 注入：强行修改服务端底层配置
    jq --arg new_sni "$NEW_UDP_SNI" '
        (.. | select(type == "object" and .tag == "hy2-in") | .tls.server_name) = $new_sni |
        (.. | select(type == "object" and .tag == "tuic-in") | .tls.server_name) = $new_sni
    ' "$JSON_FILE" | atomic_jq

    # 核心修复点：正则精准轰炸！
    # 无视旧马甲叫什么名字，只要是 hy2 和 tuic 的链接，强制覆盖 sni 参数！
    # 同时绝不会误伤 VLESS 的 apple.com！
    sed -i -E "/^hysteria2:\/\// s/sni=[^&#]+/sni=$NEW_UDP_SNI/g" "$LINK_FILE" 2>/dev/null
    sed -i -E "/^tuic:\/\// s/sni=[^&#]+/sni=$NEW_UDP_SNI/g" "$LINK_FILE" 2>/dev/null
    update_sub

    # 物理重启核心
    systemctl restart vx-core.service

    echo -e "\n${green}🎉 换皮竣工！UDP 协议已满血复活，旧特征已被彻底物理销毁！${plain}"
    echo -e "${red}⚠️ 警告：请务必返回菜单按【f】提取最新节点，旧节点已阵亡！${plain}"
    read -p "👉 按回车返回大屏..."
}

# --- 主循环入口 ---
while true; do
    # 每次刷新菜单，重新配发独立防弹凭证，确保协议间物理隔离
    TEMP_UUID=$(cat /proc/sys/kernel/random/uuid 2>/dev/null || echo "vx-$(date +%s)")
    TEMP_PASS=$(openssl rand -hex 8)
    
    # ================= 👇 降维感知：跨面板 TG 兵符探测 👇 =================
    if [[ -f "/etc/velox_tg.conf" ]] && grep -q "GLOBAL_TG_TOKEN" "/etc/velox_tg.conf"; then
        # 终极智能探测：看看机器上有没有安装 velox 总面板本体！
        if [[ -f "/usr/local/bin/velox" ]]; then
            TG_RADAR_STAT="${green}[已联动 Velox]✅${plain}"
        else
            TG_RADAR_STAT="${green}[TG雷达已激活]✅${plain}"
        fi
    else
        TG_RADAR_STAT="${yellow}[未配置 TG]⚠️${plain}"
    fi
    # ======================================================================
    
    show_dashboard
    # 彻底粉碎冗余，保持逻辑清晰
    echo -e "                 🚀 【 vx 核心引擎装载区 】"
    echo -e "${cyan}----------------------------------------------------------------------${plain}"
    echo -e "  ${cyan}1.${plain} ➕ 新增/覆写 VLESS-Reality          ${green}[最稳主力✨]${plain}"
    echo -e "  ${cyan}2.${plain} ➕ 新增/覆写 Hysteria2              ${yellow}[暴力加速🚀]${plain}"
    echo -e "  ${cyan}3.${plain} ➕ 新增/覆写 TUIC v5                ${blue}[极致抗丢包💎]${plain}"
    echo -e "  ${cyan}4.${plain} ➕ 新增/覆写 VMess-WS+TLS           ${red}[默认全加密装甲]${plain}"
    echo -e "  ${cyan}5.${plain} ➕ 新增/覆写 Trojan-Reality         ${purple}[神级隐身✨]${plain}"
    echo -e "  ${cyan}6.${plain} 🚀 终极大招: 一键满血装载所有协议   ${cyan}[大满贯引擎]${plain}"
    echo -e "${cyan}----------------------------------------------------------------------${plain}"
    echo -e "                 🛡️  【 战术外挂与运维模块 】"
    echo -e "${cyan}----------------------------------------------------------------------${plain}"
    echo -e "  ${cyan}a.${plain} 🌍 挂载 Acme 真实证书    |  ${cyan}f.${plain} 🖨️ ${cyan}一键提取节点${plain} ${green}[核心]${plain}"
    echo -e "  ${cyan}b.${plain} 🔄 一键换皮 (防探针装甲) |  ${cyan}g.${plain} 📺 流媒体/AI 解锁测试"
    echo -e "  ${cyan}c.${plain} ⚡ 开启 BBR 狂暴加速     |  ${cyan}h.${plain} 🕵️ 节点哨兵 ${TG_RADAR_STAT}"
    echo -e "  ${cyan}d.${plain} 🛡️ 挂载 WARP 优选解锁    |  ${cyan}i.${plain} 🔄 OTA 热更新引擎"
    echo -e "  ${cyan}e.${plain} ☁️ 挂载 Argo 防封复活甲  |  ${cyan}j.${plain} 📖 避坑指南与面板说明"
    echo -e "${cyan}----------------------------------------------------------------------${plain}"
    echo -e "  ${cyan}k.${plain} 🗑️  ${red}彻底粉碎卸载${plain}         |  ${cyan}l.${plain} 📜 ${cyan}引擎更新日志${plain}"
    echo -e "  ${cyan}0.${plain} 🔙 退出终端"
    echo -e "${cyan}======================================================================${plain}"
    
    read -p "👉 执行指令 [0-6, a-l]: " choice
    case "$choice" in
        1) install_vless_reality; read -p "👉 按回车返回大屏..." ;;
        2) install_hysteria2; read -p "👉 按回车返回大屏..." ;;
        3) install_tuic_v5; read -p "👉 按回车返回大屏..." ;;
        4) install_vmess_ws; read -p "👉 按回车返回大屏..." ;;
        5) install_trojan_reality; read -p "👉 按回车返回大屏..." ;;
        6) install_all_nodes ;;
        a|A) apply_acme_cert ;;
        b|B) reset_random_sni ;;
        c|C) enable_bbr ;;
        d|D) enable_warp ;;
        e|E) enable_argo ;;
        f|F) export_all_nodes; read -p "👉 提取完毕，按回车返回..." ;;
        g|G) test_media_unlock ;;  
        h|H) node_sentinel ;;
        i|I) update_ota ;;
        j|J) show_help ;;
        k|K) uninstall_vne ;;
        l|L) view_changelog ;;
        0) break ;;
        *) echo -e "${red}❌ 无效指令，已触发物理拦截机制！${plain}"; sleep 1 ;;
    esac
done
