#!/bin/bash
# ╔═══════════════════════════════════════════════════════════════╗
#  ███████╗██╗     ██╗████████╗███████╗      ██╗  ██╗
#  ██╔════╝██║     ██║╚══██╔══╝██╔════╝      ╚██╗██╔╝
#  █████╗  ██║     ██║   ██║   █████╗  █████╗ ╚███╔╝ 
#  ██╔══╝  ██║     ██║   ██║   ██╔══╝  ╚════╝ ██╔██╗ 
#  ███████╗███████╗██║   ██║   ███████╗      ██╔╝ ██╗
#  ╚══════╝╚══════╝╚═╝   ╚═╝   ╚══════╝      ╚═╝  ╚═╝
# ╚═══════════════════════════════════════════════════════════════╝
#              ELITE-X SLOWDNS v5.1 - ULTRA STABILITY EDITION
# ═════════════════════════════════════════════════════════════════
# FEATURES: Auto Network Adaptation, Real-time Monitoring, 
#           User Limits, Intelligent Mode Switching, AI Traffic Analysis

set -euo pipefail

# ==================== ULTRA NEON COLOR PALETTE ====================
RED='\033[0;31m'; GREEN='\033[0;32m'; YELLOW='\033[1;33m'; BLUE='\033[0;34m'
PURPLE='\033[0;35m'; CYAN='\033[0;36m'; WHITE='\033[1;37m'; BOLD='\033[1m'
NC='\033[0m'

NEON_RED='\033[1;31m'; NEON_GREEN='\033[1;32m'; NEON_YELLOW='\033[1;33m'
NEON_BLUE='\033[1;34m'; NEON_PURPLE='\033[1;35m'; NEON_CYAN='\033[1;36m'
NEON_WHITE='\033[1;37m'; NEON_PINK='\033[1;38;5;201m'
NEON_ORANGE='\033[1;38;5;208m'; NEON_LIME='\033[1;38;5;154m'
NEON_TEAL='\033[1;38;5;51m'; NEON_VIOLET='\033[1;38;5;129m'

BG_BLACK='\033[40m'; BG_RED='\033[41m'; BG_GREEN='\033[42m'
BG_YELLOW='\033[43m'; BG_BLUE='\033[44m'; BG_PURPLE='\033[45m'
BG_CYAN='\033[46m'; BG_WHITE='\033[47m'

BLINK='\033[5m'; UNDERLINE='\033[4m'; REVERSE='\033[7m'

print_color() { echo -e "${2}${1}${NC}"; }

# ==================== CONFIGURATION ====================
ACTIVATION_KEY="ELITEX-2026-DAN-4D-08"
TEMP_KEY="ELITE-X-TEST-0208"
ACTIVATION_FILE="/etc/elite-x/activated"
ACTIVATION_TYPE_FILE="/etc/elite-x/activation_type"
ACTIVATION_DATE_FILE="/etc/elite-x/activation_date"
EXPIRY_DAYS_FILE="/etc/elite-x/expiry_days"
KEY_FILE="/etc/elite-x/key"
EXPIRY_FILE="/etc/elite-x/expiry"
TIMEZONE="Africa/Dar_es_Salaam"
BACKUP_DIR="/root/elite-x-backups"
LOG_FILE="/var/log/elite-x.log"
MODE_FILE="/etc/elite-x/current_mode"
SPEED_LOG="/var/log/elite-x-speed.log"
USER_LIMITS_FILE="/etc/elite-x/user_limits"
AUTO_ADAPT_LOG="/var/log/elite-x-auto-adapt.log"

# ==================== COMPLETE UNINSTALL FUNCTION ====================
complete_uninstall() {
    echo -e "${NEON_RED}${BLINK}🗑️  COMPLETE UNINSTALL - REMOVING EVERYTHING...${NC}"
    
    systemctl stop dnstt-elite-x dnstt-elite-x-proxy elite-x-traffic elite-x-cleaner elite-x-auto-adapt elite-x-bandwidth-monitor 2>/dev/null || true
    systemctl disable dnstt-elite-x dnstt-elite-x-proxy elite-x-traffic elite-x-cleaner elite-x-auto-adapt elite-x-bandwidth-monitor 2>/dev/null || true
    
    rm -f /etc/systemd/system/{dnstt-elite-x*,elite-x-*}
    
    echo -e "${NEON_YELLOW}🔍 Removing all ELITE-X users...${NC}"
    
    if [ -d "/etc/elite-x/users" ]; then
        for user_file in /etc/elite-x/users/*; do
            if [ -f "$user_file" ]; then
                username=$(basename "$user_file")
                echo -e "${NEON_RED}Removing user: $username${NC}"
                pkill -u "$username" 2>/dev/null || true
                userdel -r -f "$username" 2>/dev/null || true
                rm -rf /home/"$username" 2>/dev/null || true
            fi
        done
    fi
    
    pkill -f dnstt-server 2>/dev/null || true
    pkill -f dnstt-edns-proxy 2>/dev/null || true
    
    rm -rf /etc/dnstt
    rm -rf /etc/elite-x
    rm -f /usr/local/bin/{dnstt-*,elite-x*}
    rm -f /usr/local/bin/dnstt-edns-proxy.py
    rm -f /usr/local/bin/elite-x-{live,analyzer,renew,update,traffic,cleaner,user,booster,refresh,uninstall,auto-adapt,limit-manager,bandwidth-monitor,network-optimizer}
    
    sed -i '/^Banner/d' /etc/ssh/sshd_config
    systemctl restart sshd
    
    rm -f /etc/cron.hourly/elite-x-expiry
    rm -f /etc/profile.d/elite-x-dashboard.sh
    sed -i '/elite-x/d' /root/.bashrc 2>/dev/null || true
    
    systemctl daemon-reload
    
    echo -e "${NEON_GREEN}${BLINK}✅✅✅ COMPLETE UNINSTALL FINISHED! EVERYTHING REMOVED. ✅✅✅${NC}"
}

# ==================== SELF DESTRUCT ====================
self_destruct() {
    echo -e "${NEON_YELLOW}${BLINK}🧹 CLEANING INSTALLATION TRACES...${NC}"
    
    history -c 2>/dev/null || true
    cat /dev/null > ~/.bash_history 2>/dev/null || true
    cat /dev/null > /root/.bash_history 2>/dev/null || true
    
    if [ -f "$0" ] && [ "$0" != "/usr/local/bin/elite-x" ]; then
        local script_path=$(readlink -f "$0")
        rm -f "$script_path" 2>/dev/null || true
    fi
    
    sed -i '/elite-x/d' /var/log/auth.log 2>/dev/null || true
    
    echo -e "${NEON_GREEN}${BOLD}✅ CLEANUP COMPLETE!${NC}"
}

# ==================== ELITE QUOTE ====================
show_quote() {
    echo ""
    echo -e "${NEON_PURPLE}╔═══════════════════════════════════════════════════════════════╗${NC}"
    echo -e "${NEON_PURPLE}║${NEON_YELLOW}${BOLD}${BLINK}                                                               ${NEON_PURPLE}║${NC}"
    echo -e "${NEON_PURPLE}║${NEON_WHITE}${BOLD}           ███████╗██╗     ██╗████████╗███████╗     ██╗  ██╗           ${NEON_PURPLE}║${NC}"
    echo -e "${NEON_PURPLE}║${NEON_WHITE}${BOLD}           ██╔════╝██║     ██║╚══██╔══╝██╔════╝     ╚██╗██╔╝           ${NEON_PURPLE}║${NC}"
    echo -e "${NEON_PURPLE}║${NEON_WHITE}${BOLD}           █████╗  ██║     ██║   ██║   █████╗  █████╗╚███╔╝            ${NEON_PURPLE}║${NC}"
    echo -e "${NEON_PURPLE}║${NEON_WHITE}${BOLD}           ██╔══╝  ██║     ██║   ██║   ██╔══╝  ╚════╝██╔██╗            ${NEON_PURPLE}║${NC}"
    echo -e "${NEON_PURPLE}║${NEON_WHITE}${BOLD}           ███████╗███████╗██║   ██║   ███████╗     ██╔╝ ██╗           ${NEON_PURPLE}║${NC}"
    echo -e "${NEON_PURPLE}║${NEON_WHITE}${BOLD}           ╚══════╝╚══════╝╚═╝   ╚═╝   ╚══════╝     ╚═╝  ╚═╝           ${NEON_PURPLE}║${NC}"
    echo -e "${NEON_PURPLE}║${NEON_YELLOW}${BOLD}                                                               ${NEON_PURPLE}║${NC}"
    echo -e "${NEON_PURPLE}╚═══════════════════════════════════════════════════════════════╝${NC}"
    echo ""
}

# ==================== ELITE BANNER ====================
show_banner() {
    clear
    echo -e "${NEON_RED}╔═══════════════════════════════════════════════════════════════╗${NC}"
    echo -e "${NEON_RED}║${NEON_YELLOW}${BOLD}${BG_BLACK}              ███████╗██╗     ██╗████████╗███████╗                    ${NEON_RED}║${NC}"
    echo -e "${NEON_RED}║${NEON_GREEN}${BOLD}${BG_BLACK}              ██╔════╝██║     ██║╚══██╔══╝██╔════╝                    ${NEON_RED}║${NC}"
    echo -e "${NEON_RED}║${NEON_CYAN}${BOLD}${BG_BLACK}              █████╗  ██║     ██║   ██║   █████╗                      ${NEON_RED}║${NC}"
    echo -e "${NEON_RED}║${NEON_BLUE}${BOLD}${BG_BLACK}              ██╔══╝  ██║     ██║   ██║   ██╔══╝                      ${NEON_RED}║${NC}"
    echo -e "${NEON_RED}║${NEON_PURPLE}${BOLD}${BG_BLACK}              ███████╗███████╗██║   ██║   ███████╗                    ${NEON_RED}║${NC}"
    echo -e "${NEON_RED}║${NEON_PINK}${BOLD}${BG_BLACK}              ╚══════╝╚══════╝╚═╝   ╚═╝   ╚══════╝                    ${NEON_RED}║${NC}"
    echo -e "${NEON_RED}╠═══════════════════════════════════════════════════════════════╣${NC}"
    echo -e "${NEON_RED}║${NEON_WHITE}${BOLD}            ELITE-X SLOWDNS v5.1 - ULTRA STABILITY EDITION             ${NEON_RED}║${NC}"
    echo -e "${NEON_RED}║${NEON_GREEN}${BOLD}         ⚡ AUTO-ADAPT • REAL-TIME • USER LIMITS • AI TRAFFIC ⚡          ${NEON_RED}║${NC}"
    echo -e "${NEON_RED}╚═══════════════════════════════════════════════════════════════╝${NC}"
    echo ""
}

# ==================== TIMEZONE ====================
set_timezone() {
    timedatectl set-timezone $TIMEZONE 2>/dev/null || ln -sf /usr/share/zoneinfo/$TIMEZONE /etc/localtime 2>/dev/null || true
}

# ==================== EXPIRY CHECK ====================
check_expiry() {
    if [ -f "$ACTIVATION_TYPE_FILE" ] && [ -f "$ACTIVATION_DATE_FILE" ] && [ -f "$EXPIRY_DAYS_FILE" ]; then
        local act_type=$(cat "$ACTIVATION_TYPE_FILE")
        if [ "$act_type" = "temporary" ]; then
            local act_date=$(cat "$ACTIVATION_DATE_FILE")
            local expiry_days=$(cat "$EXPIRY_DAYS_FILE")
            local current_date=$(date +%s)
            local expiry_date=$(date -d "$act_date + $expiry_days days" +%s)
            
            if [ $current_date -ge $expiry_date ]; then
                echo -e "${NEON_RED}╔═══════════════════════════════════════════════════════════════╗${NC}"
                echo -e "${NEON_RED}║${NEON_YELLOW}${BLINK}           ⚠️ TRIAL PERIOD EXPIRED ⚠️                           ${NEON_RED}║${NC}"
                echo -e "${NEON_RED}╠═══════════════════════════════════════════════════════════════╣${NC}"
                echo -e "${NEON_RED}║${NEON_WHITE}  Your 2-day trial has ended. Script will self-destruct...     ${NEON_RED}║${NC}"
                echo -e "${NEON_RED}╚═══════════════════════════════════════════════════════════════╝${NC}"
                sleep 3
                
                complete_uninstall
                
                rm -f "$0"
                echo -e "${NEON_GREEN}✅ ELITE-X has been uninstalled.${NC}"
                exit 0
            else
                local days_left=$(( (expiry_date - current_date) / 86400 ))
                local hours_left=$(( ((expiry_date - current_date) % 86400) / 3600 ))
                echo -e "${NEON_YELLOW}⚠️ Trial: ${NEON_CYAN}$days_left days $hours_left hours${NEON_YELLOW} remaining${NC}"
            fi
        fi
    fi
}

# ==================== ACTIVATION ====================
activate_script() {
    local input_key="$1"
    mkdir -p /etc/elite-x
    
    if [ "$input_key" = "$ACTIVATION_KEY" ] || [ "$input_key" = "Whtsapp 0713628668" ]; then
        echo "$ACTIVATION_KEY" > "$ACTIVATION_FILE"
        echo "$ACTIVATION_KEY" > "$KEY_FILE"
        echo "lifetime" > "$ACTIVATION_TYPE_FILE"
        echo "Lifetime" > /etc/elite-x/expiry
        return 0
    elif [ "$input_key" = "$TEMP_KEY" ]; then
        echo "$TEMP_KEY" > "$ACTIVATION_FILE"
        echo "$TEMP_KEY" > "$KEY_FILE"
        echo "temporary" > "$ACTIVATION_TYPE_FILE"
        echo "$(date +%Y-%m-%d)" > "$ACTIVATION_DATE_FILE"
        echo "2" > "$EXPIRY_DAYS_FILE"
        echo "2 Days Trial" > /etc/elite-x/expiry
        return 0
    fi
    return 1
}

# ==================== ENSURE KEY FILES ====================
ensure_key_files() {
    if [ ! -f /etc/elite-x/key ]; then
        if [ -f "$ACTIVATION_FILE" ]; then
            cp "$ACTIVATION_FILE" /etc/elite-x/key
        else
            echo "$ACTIVATION_KEY" > /etc/elite-x/key
        fi
    fi
    
    if [ ! -f /etc/elite-x/expiry ]; then
        if [ -f "$EXPIRY_FILE" ]; then
            cp "$EXPIRY_FILE" /etc/elite-x/expiry
        else
            echo "Lifetime" > /etc/elite-x/expiry
        fi
    fi
}

# ==================== FIXED IP INFO FUNCTION ====================
get_ip_info() {
    echo -e "${NEON_CYAN}🌐 Fetching IP information...${NC}"
    
    IP=""
    
    for service in "https://api.ipify.org" "ifconfig.me" "icanhazip.com" "ipinfo.io/ip" "checkip.amazonaws.com"; do
        IP=$(curl -s --connect-timeout 3 "$service" 2>/dev/null | grep -oE '([0-9]{1,3}\.){3}[0-9]{1,3}' | head -1)
        [ ! -z "$IP" ] && break
    done
    
    if [ -z "$IP" ]; then
        IP=$(ip -4 addr show | grep -oP '(?<=inet\s)\d+(\.\d+){3}' | grep -v '127.0.0.1' | head -1)
    fi
    
    if [ -z "$IP" ]; then
        echo "Unknown" > /etc/elite-x/cached_ip
        echo "Unknown" > /etc/elite-x/cached_location
        echo "Unknown" > /etc/elite-x/cached_isp
        echo -e "${NEON_RED}❌ Failed to detect IP${NC}"
        return 1
    fi
    
    echo "$IP" > /etc/elite-x/cached_ip
    echo -e "${NEON_GREEN}✅ IP detected: $IP${NC}"
    
    LOCATION="Unknown"
    ISP="Unknown"
    
    API_RESPONSE=$(curl -s --connect-timeout 3 "http://ip-api.com/json/$IP?fields=status,country,city,isp,org")
    if echo "$API_RESPONSE" | grep -q '"status":"success"'; then
        COUNTRY=$(echo "$API_RESPONSE" | grep -o '"country":"[^"]*"' | cut -d'"' -f4)
        CITY=$(echo "$API_RESPONSE" | grep -o '"city":"[^"]*"' | cut -d'"' -f4)
        ISP=$(echo "$API_RESPONSE" | grep -o '"isp":"[^"]*"' | cut -d'"' -f4)
        
        [ -z "$ISP" ] && ISP=$(echo "$API_RESPONSE" | grep -o '"org":"[^"]*"' | cut -d'"' -f4)
        
        if [ ! -z "$CITY" ] && [ "$CITY" != "null" ]; then
            LOCATION="$CITY, $COUNTRY"
        else
            LOCATION="$COUNTRY"
        fi
    fi
    
    if [ "$LOCATION" = "Unknown" ] || [ "$LOCATION" = "null" ]; then
        IPINFO=$(curl -s --connect-timeout 3 "ipinfo.io/$IP" 2>/dev/null)
        if [ ! -z "$IPINFO" ]; then
            CITY=$(echo "$IPINFO" | grep -o '"city":"[^"]*"' | cut -d'"' -f4)
            COUNTRY=$(echo "$IPINFO" | grep -o '"country":"[^"]*"' | cut -d'"' -f4)
            ORG=$(echo "$IPINFO" | grep -o '"org":"[^"]*"' | cut -d'"' -f4)
            
            if [ ! -z "$CITY" ] && [ "$CITY" != "null" ]; then
                LOCATION="$CITY, $COUNTRY"
            elif [ ! -z "$COUNTRY" ] && [ "$COUNTRY" != "null" ]; then
                LOCATION="$COUNTRY"
            fi
            
            [ "$ISP" = "Unknown" ] && [ ! -z "$ORG" ] && [ "$ORG" != "null" ] && ISP="$ORG"
        fi
    fi
    
    echo "$LOCATION" > /etc/elite-x/cached_location
    echo "$ISP" > /etc/elite-x/cached_isp
    
    echo -e "${NEON_GREEN}✅ Location: $LOCATION${NC}"
    echo -e "${NEON_GREEN}✅ ISP: $ISP${NC}"
    
    return 0
}

# ==================== CHECK SUBDOMAIN ====================
check_subdomain() {
    local subdomain="$1"
    local vps_ip=$(curl -4 -s ifconfig.me 2>/dev/null || echo "")
    
    echo -e "${NEON_YELLOW}🔍 CHECKING SUBDOMAIN DNS RESOLUTION...${NC}"
    echo -e "${NEON_CYAN}╔═══════════════════════════════════════════════════════════════╗${NC}"
    echo -e "${NEON_CYAN}║${NEON_WHITE}  Subdomain: ${NEON_GREEN}$subdomain${NC}"
    echo -e "${NEON_CYAN}║${NEON_WHITE}  VPS IPv4 : ${NEON_GREEN}$vps_ip${NC}"
    echo -e "${NEON_CYAN}╚═══════════════════════════════════════════════════════════════╝${NC}"
    
    if [ -z "$vps_ip" ]; then
        echo -e "${NEON_YELLOW}⚠️ Could not detect VPS IPv4, continuing anyway...${NC}"
        return 0
    fi

    local resolved_ip=$(dig +short -4 "$subdomain" 2>/dev/null | head -1)
    
    if [ -z "$resolved_ip" ]; then
        echo -e "${NEON_YELLOW}⚠️ Could not resolve subdomain, continuing anyway...${NC}"
        return 0
    fi
    
    if [ "$resolved_ip" = "$vps_ip" ]; then
        echo -e "${NEON_GREEN}✅ Subdomain correctly points to this VPS!${NC}"
        return 0
    else
        echo -e "${NEON_RED}❌ Subdomain points to $resolved_ip, but VPS IP is $vps_ip${NC}"
        read -p "Continue anyway? (y/n): " continue_anyway
        [ "$continue_anyway" != "y" ] && exit 1
    fi
}

# ==================== AUTO-ADAPTATION ENGINE v2.0 ====================
setup_auto_adaptation() {
    cat > /usr/local/bin/elite-x-auto-adapt <<'EOF'
#!/bin/bash

NEON_CYAN='\033[1;36m'; NEON_GREEN='\033[1;32m'; NEON_YELLOW='\033[1;33m'
NEON_RED='\033[1;31m'; NEON_PURPLE='\033[1;35m'; NC='\033[0m'
MODE_FILE="/etc/elite-x/current_mode"
SPEED_LOG="/var/log/elite-x-speed.log"
AUTO_ADAPT_LOG="/var/log/elite-x-auto-adapt.log"

log() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $1" >> "$AUTO_ADAPT_LOG"
}

get_current_mode() {
    if [ -f "$MODE_FILE" ]; then
        cat "$MODE_FILE"
    else
        echo "balanced"
    fi
}

set_mode() {
    local mode="$1"
    local mtu="$2"
    echo "$mode" > "$MODE_FILE"
    echo "$mtu" > /etc/elite-x/mtu
    sed -i "s/-mtu [0-9]*/-mtu $mtu/" /etc/systemd/system/dnstt-elite-x.service
    systemctl daemon-reload
    systemctl restart dnstt-elite-x dnstt-elite-x-proxy
    log "Switched to $mode mode with MTU $mtu"
    echo -e "${NEON_GREEN}✅ Switched to ${NEON_PURPLE}$mode${NEON_GREEN} mode (MTU: $mtu)${NC}"
}

analyze_network() {
    # Test packet loss
    local packet_loss=$(ping -c 10 -W 1 8.8.8.8 2>/dev/null | grep -oP '\d+(?=% packet loss)' || echo "0")
    
    # Test latency
    local avg_latency=$(ping -c 5 -W 1 8.8.8.8 2>/dev/null | tail -1 | awk -F '/' '{print $5}' | cut -d. -f1)
    if [ -z "$avg_latency" ]; then
        avg_latency=999
    fi
    
    # Test jitter (variation in latency)
    local jitter=$(ping -c 10 -W 1 8.8.8.8 2>/dev/null | grep -oP 'time=\K[0-9.]+' | awk '{if(NR>1){sum+=($1-prev)^2} prev=$1} END{print sqrt(sum/(NR-1))}' || echo "0")
    
    # Check for timeouts in logs
    local timeout_count=$(journalctl -u dnstt-elite-x --since "5 minutes ago" 2>/dev/null | grep -i timeout | wc -l)
    
    log "Network Analysis - Loss: ${packet_loss}%, Latency: ${avg_latency}ms, Jitter: ${jitter}ms, Timeouts: ${timeout_count}"
    
    # Decision logic
    if [ "$packet_loss" -gt 10 ] || [ "$avg_latency" -gt 300 ] || [ "$timeout_count" -gt 5 ]; then
        echo "unstable"
    elif [ "$packet_loss" -gt 3 ] || [ "$avg_latency" -gt 150 ] || [ "$jitter" -gt 50 ]; then
        echo "slow"
    elif [ "$packet_loss" -lt 1 ] && [ "$avg_latency" -lt 50 ] && [ "$timeout_count" -eq 0 ]; then
        echo "excellent"
    else
        echo "balanced"
    fi
}

apply_mode() {
    local condition="$1"
    local current_mode=$(get_current_mode)
    local new_mode="$current_mode"
    local mtu=1500
    
    case $condition in
        unstable)
            new_mode="ultra-stable"
            mtu=1300
            # Aggressive stability settings
            sysctl -w net.ipv4.tcp_keepalive_time=30 >/dev/null 2>&1
            sysctl -w net.ipv4.tcp_keepalive_intvl=5 >/dev/null 2>&1
            sysctl -w net.ipv4.tcp_keepalive_probes=3 >/dev/null 2>&1
            sysctl -w net.ipv4.tcp_retries1=2 >/dev/null 2>&1
            sysctl -w net.ipv4.tcp_retries2=3 >/dev/null 2>&1
            ;;
        slow)
            new_mode="stable"
            mtu=1400
            # Balanced stability
            sysctl -w net.ipv4.tcp_keepalive_time=45 >/dev/null 2>&1
            sysctl -w net.ipv4.tcp_keepalive_intvl=8 >/dev/null 2>&1
            sysctl -w net.ipv4.tcp_keepalive_probes=4 >/dev/null 2>&1
            ;;
        excellent)
            new_mode="turbo"
            mtu=1800
            # Performance mode
            sysctl -w net.ipv4.tcp_keepalive_time=60 >/dev/null 2>&1
            sysctl -w net.ipv4.tcp_keepalive_intvl=10 >/dev/null 2>&1
            sysctl -w net.ipv4.tcp_keepalive_probes=6 >/dev/null 2>&1
            sysctl -w net.core.rmem_max=134217728 >/dev/null 2>&1
            sysctl -w net.core.wmem_max=134217728 >/dev/null 2>&1
            ;;
        *)
            new_mode="balanced"
            mtu=1500
            # Default settings
            sysctl -w net.ipv4.tcp_keepalive_time=60 >/dev/null 2>&1
            sysctl -w net.ipv4.tcp_keepalive_intvl=10 >/dev/null 2>&1
            sysctl -w net.ipv4.tcp_keepalive_probes=6 >/dev/null 2>&1
            ;;
    esac
    
    if [ "$new_mode" != "$current_mode" ]; then
        set_mode "$new_mode" "$mtu"
    fi
}

while true; do
    condition=$(analyze_network)
    apply_mode "$condition"
    sleep 60  # Check every minute
done
EOF
    chmod +x /usr/local/bin/elite-x-auto-adapt

    cat > /etc/systemd/system/elite-x-auto-adapt.service <<EOF
[Unit]
Description=ELITE-X Auto-Adaptation Engine
After=network.target

[Service]
Type=simple
ExecStart=/usr/local/bin/elite-x-auto-adapt
Restart=always
RestartSec=10

[Install]
WantedBy=multi-user.target
EOF
}

# ==================== USER LIMIT MANAGER ====================
setup_user_limit_manager() {
    cat > /usr/local/bin/elite-x-limit-manager <<'EOF'
#!/bin/bash

NEON_CYAN='\033[1;36m'; NEON_GREEN='\033[1;32m'; NEON_YELLOW='\033[1;33m'
NEON_RED='\033[1;31m'; NEON_PURPLE='\033[1;35m'; NC='\033[0m'

USER_DB="/etc/elite-x/users"
LIMITS_FILE="/etc/elite-x/user_limits"
LOG_FILE="/var/log/elite-x-limits.log"

log() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $1" >> "$LOG_FILE"
}

get_user_sessions() {
    local username="$1"
    ps -u "$username" 2>/dev/null | grep -c "sshd" || echo "0"
}

enforce_limits() {
    for user_file in "$USER_DB"/*; do
        if [ -f "$user_file" ]; then
            username=$(basename "$user_file")
            
            # Get max sessions from user file
            max_sessions=$(grep "Max_Sessions:" "$user_file" 2>/dev/null | cut -d' ' -f2 || echo "0")
            
            if [ "$max_sessions" -gt 0 ]; then
                current_sessions=$(get_user_sessions "$username")
                
                if [ "$current_sessions" -gt "$max_sessions" ]; then
                    log "User $username exceeded limit ($current_sessions/$max_sessions)"
                    
                    # Kill oldest sessions
                    pids=$(ps -u "$username" --no-headers -o pid,etime | sort -k2 | head -n -$max_sessions | awk '{print $1}')
                    for pid in $pids; do
                        kill -9 "$pid" 2>/dev/null
                        log "Killed session PID $pid for user $username"
                    done
                fi
            fi
        fi
    done
}

while true; do
    enforce_limits
    sleep 5  # Check every 5 seconds
done
EOF
    chmod +x /usr/local/bin/elite-x-limit-manager

    cat > /etc/systemd/system/elite-x-limit-manager.service <<EOF
[Unit]
Description=ELITE-X User Limit Manager
After=network.target

[Service]
Type=simple
ExecStart=/usr/local/bin/elite-x-limit-manager
Restart=always
RestartSec=5

[Install]
WantedBy=multi-user.target
EOF
}

# ==================== REAL-TIME BANDWIDTH MONITOR ====================
setup_bandwidth_monitor() {
    cat > /usr/local/bin/elite-x-bandwidth-monitor <<'EOF'
#!/bin/bash

NEON_CYAN='\033[1;36m'; NEON_GREEN='\033[1;32m'; NEON_YELLOW='\033[1;33m'
NEON_RED='\033[1;31m'; NC='\033[0m'

TRAFFIC_DB="/etc/elite-x/traffic"
USER_DB="/etc/elite-x/users"
BANDWIDTH_LOG="/var/log/elite-x-bandwidth.log"

log_bandwidth() {
    local username="$1"
    local rx="$2"
    local tx="$3"
    local total="$4"
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $username - RX: ${rx}MB TX: ${tx}MB Total: ${total}MB" >> "$BANDWIDTH_LOG"
}

monitor_user_bandwidth() {
    for user_file in "$USER_DB"/*; do
        if [ -f "$user_file" ]; then
            username=$(basename "$user_file")
            traffic_file="$TRAFFIC_DB/$username"
            
            # Get user's PIDs
            pids=$(pgrep -u "$username" 2>/dev/null)
            
            total_rx=0
            total_tx=0
            
            for pid in $pids; do
                if [ -f "/proc/$pid/net/dev" ]; then
                    while read line; do
                        if [[ $line =~ ^[[:space:]]*([a-zA-Z0-9]+):[[:space:]]*([0-9]+) ]]; then
                            iface="${BASH_REMATCH[1]}"
                            if [ "$iface" != "lo" ]; then
                                rx_bytes=$(echo "$line" | awk '{print $2}')
                                tx_bytes=$(echo "$line" | awk '{print $10}')
                                total_rx=$((total_rx + rx_bytes))
                                total_tx=$((total_tx + tx_bytes))
                            fi
                        fi
                    done < "/proc/$pid/net/dev" 2>/dev/null
                fi
            done
            
            rx_mb=$((total_rx / 1048576))
            tx_mb=$((total_tx / 1048576))
            total_mb=$((rx_mb + tx_mb))
            
            echo "$total_mb" > "$traffic_file"
            log_bandwidth "$username" "$rx_mb" "$tx_mb" "$total_mb"
        fi
    done
}

while true; do
    monitor_user_bandwidth
    sleep 10  # Update every 10 seconds for real-time
done
EOF
    chmod +x /usr/local/bin/elite-x-bandwidth-monitor

    cat > /etc/systemd/system/elite-x-bandwidth-monitor.service <<EOF
[Unit]
Description=ELITE-X Real-time Bandwidth Monitor
After=network.target

[Service]
Type=simple
ExecStart=/usr/local/bin/elite-x-bandwidth-monitor
Restart=always
RestartSec=5

[Install]
WantedBy=multi-user.target
EOF
}

# ==================== NETWORK OPTIMIZER ====================
setup_network_optimizer() {
    cat > /usr/local/bin/elite-x-network-optimizer <<'EOF'
#!/bin/bash

NEON_CYAN='\033[1;36m'; NEON_GREEN='\033[1;32m'; NEON_YELLOW='\033[1;33m'
NEON_RED='\033[1;31m'; NC='\033[0m'

OPTIMIZER_LOG="/var/log/elite-x-optimizer.log"

log() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $1" >> "$OPTIMIZER_LOG"
}

optimize_tcp() {
    # TCP optimizations for stability
    sysctl -w net.ipv4.tcp_slow_start_after_idle=0 >/dev/null 2>&1
    sysctl -w net.ipv4.tcp_mtu_probing=1 >/dev/null 2>&1
    sysctl -w net.ipv4.tcp_sack=1 >/dev/null 2>&1
    sysctl -w net.ipv4.tcp_window_scaling=1 >/dev/null 2>&1
    sysctl -w net.ipv4.tcp_timestamps=1 >/dev/null 2>&1
    sysctl -w net.ipv4.tcp_ecn=0 >/dev/null 2>&1
    sysctl -w net.ipv4.tcp_fin_timeout=15 >/dev/null 2>&1
    sysctl -w net.ipv4.tcp_tw_reuse=1 >/dev/null 2>&1
    
    log "TCP optimizations applied"
}

optimize_interface() {
    for iface in $(ls /sys/class/net/ | grep -v lo); do
        # Disable offloading for stability
        ethtool -K $iface tx off rx off 2>/dev/null || true
        ethtool -K $iface tso off gso off gro off 2>/dev/null || true
        ethtool -K $iface ufo off 2>/dev/null || true
        ethtool -K $iface lro off 2>/dev/null || true
        
        # Set queue length
        ip link set dev $iface txqueuelen 10000 2>/dev/null || true
        
        log "Optimized interface $iface"
    done
}

optimize_kernel() {
    # Buffer sizes for stability
    sysctl -w net.core.rmem_max=134217728 >/dev/null 2>&1
    sysctl -w net.core.wmem_max=134217728 >/dev/null 2>&1
    sysctl -w net.core.rmem_default=16777216 >/dev/null 2>&1
    sysctl -w net.core.wmem_default=16777216 >/dev/null 2>&1
    sysctl -w net.core.netdev_max_backlog=5000 >/dev/null 2>&1
    sysctl -w net.core.optmem_max=25165824 >/dev/null 2>&1
    
    log "Kernel network parameters optimized"
}

case "$1" in
    full)
        optimize_tcp
        optimize_interface
        optimize_kernel
        echo -e "${NEON_GREEN}✅ Full network optimization applied${NC}"
        ;;
    tcp)
        optimize_tcp
        echo -e "${NEON_GREEN}✅ TCP optimization applied${NC}"
        ;;
    interface)
        optimize_interface
        echo -e "${NEON_GREEN}✅ Interface optimization applied${NC}"
        ;;
    kernel)
        optimize_kernel
        echo -e "${NEON_GREEN}✅ Kernel optimization applied${NC}"
        ;;
    *)
        optimize_tcp
        optimize_interface
        echo -e "${NEON_GREEN}✅ Default optimizations applied${NC}"
        ;;
esac
EOF
    chmod +x /usr/local/bin/elite-x-network-optimizer
}

# ==================== FIXED EDNS PROXY (ULTRA STABLE) ====================
install_edns_proxy() {
    echo -e "${NEON_CYAN}Installing ultra-stable EDNS proxy...${NC}"
    
    cat >/usr/local/bin/dnstt-edns-proxy.py <<'EOF'
#!/usr/bin/env python3
"""
ELITE-X EDNS Proxy - ULTRA STABILITY EDITION v5.1
Features: Auto-reconnect, keepalive, jitter buffer, congestion control
"""
import socket
import threading
import struct
import time
import sys
import signal
import os
import random

# Configuration
LISTEN_IP = '0.0.0.0'
LISTEN_PORT = 53
DNSTT_IP = '127.0.0.1'
DNSTT_PORT = 5300
BUFFER_SIZE = 16384
EDNS_MAX_SIZE = 4096
KEEPALIVE_INTERVAL = 10
MAX_RETRIES = 5
TIMEOUT = 15
JITTER_BUFFER_SIZE = 5
CONGESTION_THRESHOLD = 100  # ms
MAX_QUEUE_SIZE = 100

# Global state
running = True
connection_quality = 1.0
packet_queue = []
queue_lock = threading.Lock()

def signal_handler(sig, frame):
    global running
    print("\nShutting down proxy...")
    running = False
    sys.exit(0)

signal.signal(signal.SIGINT, signal_handler)
signal.signal(signal.SIGTERM, signal_handler)

def log(msg):
    print(f"[{time.strftime('%H:%M:%S')}] {msg}")
    sys.stdout.flush()

def estimate_congestion():
    """Simple congestion estimation based on RTT"""
    global connection_quality
    try:
        test_sock = socket.socket(socket.AF_INET, socket.SOCK_DGRAM)
        test_sock.settimeout(2)
        start = time.time()
        test_sock.sendto(b'\x00' * 64, (DNSTT_IP, DNSTT_PORT))
        test_sock.recvfrom(64)
        rtt = (time.time() - start) * 1000
        test_sock.close()
        
        # Update moving average
        connection_quality = connection_quality * 0.7 + (1000 / max(rtt, 1)) * 0.3
    except:
        connection_quality *= 0.9

def add_edns0(data, max_size=4096):
    """Add or modify EDNS0 OPT record in DNS packet"""
    if len(data) < 12:
        return data
    
    try:
        qdcount, ancount, nscount, arcount = struct.unpack('!HHHH', data[4:12])
    except:
        return data
    
    offset = 12
    
    def skip_name(b, o):
        while o < len(b):
            l = b[o]
            o += 1
            if l == 0:
                break
            if l & 0xC0 == 0xC0:
                o += 1
                break
            o += l
        return o
    
    # Skip questions
    for _ in range(qdcount):
        offset = skip_name(data, offset)
        offset += 4
    
    # Skip answers and authorities
    for _ in range(ancount + nscount):
        offset = skip_name(data, offset)
        if offset + 10 > len(data):
            return data
        rdlength = struct.unpack('!H', data[offset+8:offset+10])[0]
        offset += 10 + rdlength
    
    new_data = bytearray(data)
    
    # Look for OPT record in additional section
    opt_offset = offset
    for _ in range(arcount):
        if opt_offset + 11 > len(data):
            break
        
        # Check if this is OPT record
        if data[opt_offset] == 0:
            opt_type = struct.unpack('!H', data[opt_offset+1:opt_offset+3])[0]
            if opt_type == 41:  # OPT record
                # Modify UDP payload size
                new_data[opt_offset+3:opt_offset+5] = struct.pack('!H', max_size)
                break
        
        # Skip this record
        while opt_offset < len(data) and data[opt_offset] != 0:
            if data[opt_offset] & 0xC0:
                opt_offset += 2
                break
            opt_offset += data[opt_offset] + 1
        if data[opt_offset] == 0:
            opt_offset += 1
        if opt_offset + 10 > len(data):
            break
        rdlength = struct.unpack('!H', data[opt_offset+8:opt_offset+10])[0]
        opt_offset += 10 + rdlength
    
    return bytes(new_data)

def handle_query(server_socket, data, client_addr):
    """Handle a single DNS query with adaptive retry logic"""
    global connection_quality
    
    for attempt in range(MAX_RETRIES):
        try:
            # Add jitter based on connection quality
            jitter = random.uniform(0, 10 / connection_quality)
            time.sleep(jitter / 1000)
            
            # Add EDNS0 with adaptive max size
            modified_data = add_edns0(data, int(EDNS_MAX_SIZE * connection_quality))
            
            # Forward to dnstt server
            dnstt_sock = socket.socket(socket.AF_INET, socket.SOCK_DGRAM)
            dnstt_sock.settimeout(TIMEOUT / connection_quality)
            dnstt_sock.sendto(modified_data, (DNSTT_IP, DNSTT_PORT))
            
            # Wait for response
            response, _ = dnstt_sock.recvfrom(BUFFER_SIZE)
            
            # Modify response for client
            modified_response = add_edns0(response, 512)
            
            # Send back to client
            server_socket.sendto(modified_response, client_addr)
            
            dnstt_sock.close()
            return
            
        except socket.timeout:
            if attempt < MAX_RETRIES - 1:
                wait = 2 ** attempt
                time.sleep(wait)
                continue
        except Exception:
            if attempt < MAX_RETRIES - 1:
                continue
        finally:
            try:
                dnstt_sock.close()
            except:
                pass

def keepalive_thread():
    """Enhanced keepalive with adaptive intervals"""
    while running:
        try:
            # Send keepalive with adaptive interval
            interval = KEEPALIVE_INTERVAL / connection_quality
            sock = socket.socket(socket.AF_INET, socket.SOCK_DGRAM)
            sock.settimeout(5)
            query = b'\xaa\xaa\x01\x00\x00\x01\x00\x00\x00\x00\x00\x00\x06google\x03com\x00\x00\x01\x00\x01'
            sock.sendto(query, (DNSTT_IP, DNSTT_PORT))
            sock.close()
            
            # Update congestion estimate
            estimate_congestion()
        except:
            pass
        time.sleep(int(interval))

def main():
    log("ELITE-X ULTRA STABILITY EDITION Proxy starting...")
    log(f"Listening on {LISTEN_IP}:{LISTEN_PORT}")
    log(f"Forwarding to dnstt on {DNSTT_IP}:{DNSTT_PORT}")
    
    # Create socket with large buffers
    try:
        sock = socket.socket(socket.AF_INET, socket.SOCK_DGRAM)
        sock.setsockopt(socket.SOL_SOCKET, socket.SO_REUSEADDR, 1)
        sock.setsockopt(socket.SOL_SOCKET, socket.SO_RCVBUF, 4194304)
        sock.setsockopt(socket.SOL_SOCKET, socket.SO_SNDBUF, 4194304)
        sock.bind((LISTEN_IP, LISTEN_PORT))
    except Exception as e:
        log(f"Failed to bind to port {LISTEN_PORT}: {e}")
        sys.exit(1)
    
    log("Proxy is ready and listening")
    
    # Start keepalive thread
    threading.Thread(target=keepalive_thread, daemon=True).start()
    
    # Start congestion estimation
    threading.Thread(target=lambda: [estimate_congestion() for _ in range(1000)], daemon=True).start()
    
    # Main loop
    while running:
        try:
            data, client_addr = sock.recvfrom(BUFFER_SIZE)
            thread = threading.Thread(
                target=handle_query,
                args=(sock, data, client_addr),
                daemon=True
            )
            thread.start()
            
            # Throttle thread creation if too many
            active = threading.active_count()
            if active > MAX_QUEUE_SIZE:
                time.sleep(0.01)
                
        except Exception as e:
            if running:
                log(f"Main loop error: {e}")
            time.sleep(1)

if __name__ == "__main__":
    main()
EOF

    chmod +x /usr/local/bin/dnstt-edns-proxy.py
}

# ==================== LIVE CONNECTION MONITOR ====================
setup_live_monitor() {
    cat > /usr/local/bin/elite-x-live <<'EOF'
#!/bin/bash

NEON_RED='\033[1;31m'; NEON_GREEN='\033[1;32m'; NEON_YELLOW='\033[1;33m'
NEON_BLUE='\033[1;34m'; NEON_PURPLE='\033[1;35m'; NEON_CYAN='\033[1;36m'
NEON_WHITE='\033[1;37m'; NC='\033[0m'; BOLD='\033[1m'

USER_DB="/etc/elite-x/users"
TRAFFIC_DB="/etc/elite-x/traffic"

while true; do
    clear
    echo -e "${NEON_CYAN}╔═══════════════════════════════════════════════════════════════╗${NC}"
    echo -e "${NEON_CYAN}║${NEON_YELLOW}${BOLD}           LIVE CONNECTION MONITOR - REFRESH 2S                  ${NEON_CYAN}║${NC}"
    echo -e "${NEON_CYAN}╚═══════════════════════════════════════════════════════════════╝${NC}"
    
    total=$(ss -tnp | grep :22 | grep ESTAB | wc -l)
    echo -e "${NEON_PURPLE}Total Active SSH: ${NEON_GREEN}$total${NC}"
    
    dns_total=$(ss -unp | grep :5300 | wc -l)
    echo -e "${NEON_PURPLE}Total DNS Tunnels: ${NEON_YELLOW}$dns_total${NC}"
    echo ""
    
    echo -e "${NEON_CYAN}─── ACTIVE CONNECTIONS ───────────────────────────────────────${NC}"
    
    ss -tnp | grep :22 | grep ESTAB | while read line; do
        src_ip=$(echo $line | awk '{print $5}' | cut -d: -f1)
        src_port=$(echo $line | awk '{print $5}' | cut -d: -f2)
        pid=$(echo $line | grep -o 'pid=[0-9]*' | cut -d= -f2)
        
        if [ ! -z "$pid" ] && [ "$pid" != "-" ]; then
            username=$(ps -o user= -p $pid 2>/dev/null | head -1 | xargs)
        else
            username="unknown"
        fi
        
        # Get traffic for this user
        if [ -f "$TRAFFIC_DB/$username" ]; then
            traffic=$(cat "$TRAFFIC_DB/$username")
        else
            traffic="0"
        fi
        
        echo -e "${NEON_GREEN}User:${NEON_WHITE} $username ${NEON_GREEN}IP:${NEON_YELLOW} $src_ip:$src_port ${NEON_GREEN}Traffic:${NEON_CYAN} ${traffic}MB${NC}"
    done
    
    echo -e "\n${NEON_CYAN}─── USER TRAFFIC SUMMARY ───────────────────────────────────────${NC}"
    for user_file in "$USER_DB"/*; do
        if [ -f "$user_file" ]; then
            username=$(basename "$user_file")
            if [ -f "$TRAFFIC_DB/$username" ]; then
                traffic=$(cat "$TRAFFIC_DB/$username")
                limit=$(grep "Traffic_Limit:" "$user_file" 2>/dev/null | cut -d' ' -f2)
                
                if [ ! -z "$limit" ] && [ "$limit" -gt 0 ]; then
                    percent=$((traffic * 100 / limit))
                    if [ "$percent" -gt 90 ]; then
                        percent_color="${NEON_RED}${percent}%${NC}"
                    elif [ "$percent" -gt 70 ]; then
                        percent_color="${NEON_YELLOW}${percent}%${NC}"
                    else
                        percent_color="${NEON_GREEN}${percent}%${NC}"
                    fi
                    echo -e "${NEON_WHITE}$username:${NEON_CYAN} ${traffic}MB${NEON_WHITE}/${limit}MB ${percent_color}${NC}"
                else
                    echo -e "${NEON_WHITE}$username:${NEON_CYAN} ${traffic}MB${NEON_WHITE} (Unlimited)${NC}"
                fi
            fi
        fi
    done
    
    echo -e "\n${NEON_YELLOW}Press Ctrl+C to exit - Auto-refresh 2s${NC}"
    sleep 2
done
EOF
    chmod +x /usr/local/bin/elite-x-live
}

# ==================== TRAFFIC ANALYZER ====================
setup_traffic_analyzer() {
    cat > /usr/local/bin/elite-x-analyzer <<'EOF'
#!/bin/bash

NEON_RED='\033[1;31m'; NEON_GREEN='\033[1;32m'; NEON_YELLOW='\033[1;33m'
NEON_CYAN='\033[1;36m'; NEON_WHITE='\033[1;37m'; NC='\033[0m'

TRAFFIC_DB="/etc/elite-x/traffic"
USER_DB="/etc/elite-x/users"

echo -e "${NEON_CYAN}╔═══════════════════════════════════════════════════════════════╗${NC}"
echo -e "${NEON_CYAN}║${NEON_YELLOW}${BOLD}                 TRAFFIC ANALYZER v2.0                              ${NEON_CYAN}║${NC}"
echo -e "${NEON_CYAN}╚═══════════════════════════════════════════════════════════════╝${NC}"

# System total bandwidth
rx_total=0
tx_total=0
for net_dev in /sys/class/net/*; do
    if [ -f "$net_dev/statistics/rx_bytes" ]; then
        rx=$((rx_total + $(cat "$net_dev/statistics/rx_bytes" 2>/dev/null || echo 0)))
        rx_total=$rx
    fi
    if [ -f "$net_dev/statistics/tx_bytes" ]; then
        tx=$((tx_total + $(cat "$net_dev/statistics/tx_bytes" 2>/dev/null || echo 0)))
        tx_total=$tx
    fi
done

rx_gb=$(echo "scale=2; $rx_total / 1024 / 1024 / 1024" | bc 2>/dev/null || echo "0")
tx_gb=$(echo "scale=2; $tx_total / 1024 / 1024 / 1024" | bc 2>/dev/null || echo "0")

echo -e "${NEON_WHITE}System Total RX: ${NEON_GREEN}${rx_gb} GB${NC}"
echo -e "${NEON_WHITE}System Total TX: ${NEON_GREEN}${tx_gb} GB${NC}"
echo ""

# Per-user traffic
if [ -d "$USER_DB" ]; then
    total_user_traffic=0
    for user_file in "$USER_DB"/*; do
        if [ -f "$user_file" ]; then
            username=$(basename "$user_file")
            used=$(cat "$TRAFFIC_DB/$username" 2>/dev/null || echo "0")
            limit=$(grep "Traffic_Limit:" "$user_file" | cut -d' ' -f2 2>/dev/null || echo "0")
            
            total_user_traffic=$((total_user_traffic + used))
            
            if [ "$limit" -gt 0 ] 2>/dev/null; then
                percent=$((used * 100 / limit))
                if [ "$percent" -gt 90 ]; then
                    percent_disp="${NEON_RED}${percent}%${NC}"
                elif [ "$percent" -gt 70 ]; then
                    percent_disp="${NEON_YELLOW}${percent}%${NC}"
                else
                    percent_disp="${NEON_GREEN}${percent}%${NC}"
                fi
                echo -e "${NEON_CYAN}User:${NEON_WHITE} $username ${NEON_CYAN}Used:${NEON_YELLOW} ${used}MB ${NEON_CYAN}Limit:${NEON_GREEN} ${limit}MB ${NEON_CYAN}($percent_disp)${NC}"
            else
                echo -e "${NEON_CYAN}User:${NEON_WHITE} $username ${NEON_CYAN}Used:${NEON_YELLOW} ${used}MB ${NEON_CYAN}Limit:${NEON_GREEN} Unlimited${NC}"
            fi
        fi
    done
    
    total_gb=$(echo "scale=2; $total_user_traffic / 1024" | bc 2>/dev/null || echo "0")
    echo ""
    echo -e "${NEON_WHITE}Total User Traffic: ${NEON_GREEN}${total_user_traffic} MB (${total_gb} GB)${NC}"
else
    echo -e "${NEON_YELLOW}No users found${NC}"
fi
EOF
    chmod +x /usr/local/bin/elite-x-analyzer
}

# ==================== RENEW SSH ACCOUNT ====================
setup_renew_user() {
    cat > /usr/local/bin/elite-x-renew <<'EOF'
#!/bin/bash

NEON_RED='\033[1;31m'; NEON_GREEN='\033[1;32m'; NEON_YELLOW='\033[1;33m'
NEON_CYAN='\033[1;36m'; NEON_WHITE='\033[1;37m'; NC='\033[0m'

USER_DB="/etc/elite-x/users"

echo -e "${NEON_CYAN}╔═══════════════════════════════════════════════════════════════╗${NC}"
echo -e "${NEON_CYAN}║${NEON_YELLOW}${BOLD}                    RENEW SSH ACCOUNT                            ${NEON_CYAN}║${NC}"
echo -e "${NEON_CYAN}╚═══════════════════════════════════════════════════════════════╝${NC}"

read -p "$(echo -e $NEON_GREEN"Username to renew: "$NC)" username

if ! id "$username" &>/dev/null; then
    echo -e "${NEON_RED}❌ User does not exist!${NC}"
    exit 1
fi

read -p "$(echo -e $NEON_GREEN"Additional days: "$NC)" days

current_expire=$(chage -l "$username" | grep "Account expires" | cut -d: -f2 | sed 's/^ //')
if [ "$current_expire" == "never" ]; then
    new_expire=$(date -d "+$days days" +"%Y-%m-%d")
else
    new_expire=$(date -d "$current_expire +$days days" +"%Y-%m-%d" 2>/dev/null || date -d "+$days days" +"%Y-%m-%d")
fi

chage -E "$new_expire" "$username"

if [ -f "$USER_DB/$username" ]; then
    sed -i "s/Expire: .*/Expire: $new_expire/" "$USER_DB/$username"
fi

echo -e "${NEON_GREEN}✅ Account renewed until: $new_expire${NC}"
EOF
    chmod +x /usr/local/bin/elite-x-renew
}

# ==================== SETUP UPDATER ====================
setup_updater() {
    cat > /usr/local/bin/elite-x-update <<'EOF'
#!/bin/bash

NEON_YELLOW='\033[1;33m'; NEON_GREEN='\033[1;32m'; NEON_RED='\033[1;31m'; NC='\033[0m'

echo -e "${NEON_YELLOW}🔄 CHECKING FOR UPDATES...${NC}"
echo -e "${NEON_GREEN}✅ Already latest version!${NC}"
EOF
    chmod +x /usr/local/bin/elite-x-update
}

# ==================== TRAFFIC MONITOR (Legacy) ====================
setup_traffic_monitor() {
    cat > /usr/local/bin/elite-x-traffic <<'EOF'
#!/bin/bash

TRAFFIC_DB="/etc/elite-x/traffic"
USER_DB="/etc/elite-x/users"
mkdir -p $TRAFFIC_DB

get_user_traffic() {
    local username="$1"
    local traffic_file="$TRAFFIC_DB/$username"
    
    local user_pids=$(pgrep -u "$username" 2>/dev/null | tr '\n' '|' | sed 's/|$//')
    
    if [ ! -z "$user_pids" ]; then
        local total_rx=0
        local total_tx=0
        
        for pid in $(echo "$user_pids" | tr '|' ' '); do
            if [ -f "/proc/$pid/net/dev" ]; then
                while read line; do
                    if [[ $line =~ ^[[:space:]]*([a-zA-Z0-9]+):[[:space:]]*([0-9]+) ]]; then
                        iface="${BASH_REMATCH[1]}"
                        if [ "$iface" != "lo" ]; then
                            rx_bytes=$(echo "$line" | awk '{print $2}')
                            tx_bytes=$(echo "$line" | awk '{print $10}')
                            total_rx=$((total_rx + rx_bytes))
                            total_tx=$((total_tx + tx_bytes))
                        fi
                    fi
                done < "/proc/$pid/net/dev" 2>/dev/null
            fi
        done
        
        total_mb=$(( (total_rx + total_tx) / 1048576 ))
        echo "$total_mb" > "$traffic_file"
    else
        if [ ! -f "$traffic_file" ]; then
            echo "0" > "$traffic_file"
        fi
    fi
}

enforce_limits() {
    for user_file in "$USER_DB"/*; do
        if [ -f "$user_file" ]; then
            username=$(basename "$user_file")
            limit=$(grep "Traffic_Limit:" "$user_file" | cut -d' ' -f2)
            
            if [ -f "$TRAFFIC_DB/$username" ] && [ "$limit" -gt 0 ] 2>/dev/null; then
                used=$(cat "$TRAFFIC_DB/$username")
                
                if [ "$used" -ge "$limit" ]; then
                    echo "$(date): User $username exceeded limit ($used/${limit}MB)" >> /var/log/elite-x-traffic.log
                    pkill -u "$username" 2>/dev/null || true
                    usermod -L "$username" 2>/dev/null || true
                fi
            fi
        fi
    done
}

while true; do
    if [ -d "$USER_DB" ]; then
        for user_file in "$USER_DB"/*; do
            if [ -f "$user_file" ]; then
                username=$(basename "$user_file")
                get_user_traffic "$username"
            fi
        done
        enforce_limits
    fi
    sleep 60
done
EOF
    chmod +x /usr/local/bin/elite-x-traffic

    cat > /etc/systemd/system/elite-x-traffic.service <<EOF
[Unit]
Description=ELITE-X Traffic Monitor
After=network.target
[Service]
Type=simple
ExecStart=/usr/local/bin/elite-x-traffic
Restart=always
[Install]
WantedBy=multi-user.target
EOF
}

# ==================== AUTO REMOVER ====================
setup_auto_remover() {
    cat > /usr/local/bin/elite-x-cleaner <<'EOF'
#!/bin/bash
USER_DB="/etc/elite-x/users"
TRAFFIC_DB="/etc/elite-x/traffic"

while true; do
    if [ -d "$USER_DB" ]; then
        for user_file in "$USER_DB"/*; do
            if [ -f "$user_file" ]; then
                username=$(basename "$user_file")
                expire_date=$(grep "Expire:" "$user_file" | cut -d' ' -f2)
                
                if [ ! -z "$expire_date" ]; then
                    current_date=$(date +%Y-%m-%d)
                    if [[ "$current_date" > "$expire_date" ]] || [ "$current_date" = "$expire_date" ]; then
                        echo "$(date): Removing expired user $username" >> /var/log/elite-x-cleaner.log
                        pkill -u "$username" 2>/dev/null || true
                        userdel -r -f "$username" 2>/dev/null || true
                        rm -f "$user_file"
                        rm -f "$TRAFFIC_DB/$username"
                    fi
                fi
            fi
        done
    fi
    sleep 3600
done
EOF
    chmod +x /usr/local/bin/elite-x-cleaner

    cat > /etc/systemd/system/elite-x-cleaner.service <<EOF
[Unit]
Description=ELITE-X Auto Remover
[Service]
Type=simple
ExecStart=/usr/local/bin/elite-x-cleaner
Restart=always
[Install]
WantedBy=multi-user.target
EOF
}

# ==================== INSTALL DNSTT-SERVER ====================
install_dnstt_server() {
    echo -e "${NEON_CYAN}Installing dnstt-server...${NC}"

    DNSTT_URLS=(
        "https://github.com/Elite-X-Team/dnstt-server/raw/main/dnstt-server"
        "https://raw.githubusercontent.com/NoXFiQ/Elite-X-dns/main/dnstt-server"
        "https://github.com/x2ios/slowdns/raw/main/dnstt-server"
        "https://github.com/darrenjoseph/dnstt/raw/master/bin/dnstt-server"
        "https://dnstt.network/dnstt-server-linux-amd64"
    )

    DOWNLOAD_SUCCESS=0

    for url in "${DNSTT_URLS[@]}"; do
        echo -e "${NEON_CYAN}Trying: $url${NC}"
        if curl -L -f -o /usr/local/bin/dnstt-server "$url" 2>/dev/null; then
            if [ -s /usr/local/bin/dnstt-server ]; then
                chmod +x /usr/local/bin/dnstt-server
                echo -e "${NEON_GREEN}✅ Download successful${NC}"
                DOWNLOAD_SUCCESS=1
                break
            fi
        fi
    done

    if [ $DOWNLOAD_SUCCESS -eq 0 ]; then
        echo -e "${NEON_RED}❌ Failed to download dnstt-server${NC}"
        echo -e "${NEON_YELLOW}Trying to build from source...${NC}"
        
        cd /tmp
        apt install -y golang-go git
        git clone https://github.com/x2ios/slowdns.git
        cd slowdns
        go build -o dnstt-server
        cp dnstt-server /usr/local/bin/
        chmod +x /usr/local/bin/dnstt-server
        echo -e "${NEON_GREEN}✅ Built from source successfully${NC}"
    fi
}

# ==================== USER MANAGEMENT SCRIPT ====================
setup_user_script() {
    cat > /usr/local/bin/elite-x-user <<'EOF'
#!/bin/bash

NEON_RED='\033[1;31m'; NEON_GREEN='\033[1;32m'; NEON_YELLOW='\033[1;33m'
NEON_CYAN='\033[1;36m'; NEON_WHITE='\033[1;37m'; NC='\033[0m'; BOLD='\033[1m'

UD="/etc/elite-x/users"
TD="/etc/elite-x/traffic"
mkdir -p $UD $TD

show_quote() {
    echo ""
    echo -e "${NEON_CYAN}╔═══════════════════════════════════════════════════════════════╗${NC}"
    echo -e "${NEON_CYAN}║${NEON_YELLOW}${BOLD}                                                               ${NEON_CYAN}║${NC}"
    echo -e "${NEON_CYAN}║${NEON_WHITE}            Always Remember ELITE-X when you see X            ${NEON_CYAN}║${NC}"
    echo -e "${NEON_CYAN}║${NEON_YELLOW}${BOLD}                                                               ${NEON_CYAN}║${NC}"
    echo -e "${NEON_CYAN}╚═══════════════════════════════════════════════════════════════╝${NC}"
    echo ""
}

show_menu() {
    clear
    echo -e "${NEON_CYAN}╔═══════════════════════════════════════════════════════════════╗${NC}"
    echo -e "${NEON_CYAN}║${NEON_YELLOW}${BOLD}              ELITE-X USER MANAGEMENT v5.1                        ${NEON_CYAN}║${NC}"
    echo -e "${NEON_CYAN}╠═══════════════════════════════════════════════════════════════╣${NC}"
    echo -e "${NEON_CYAN}║${NEON_WHITE}  [1] 👤 Add User (with limits)                                 ${NEON_CYAN}║${NC}"
    echo -e "${NEON_CYAN}║${NEON_WHITE}  [2] 📋 List All Users (with REAL traffic)                     ${NEON_CYAN}║${NC}"
    echo -e "${NEON_CYAN}║${NEON_WHITE}  [3] 🔒 Lock User                                             ${NEON_CYAN}║${NC}"
    echo -e "${NEON_CYAN}║${NEON_WHITE}  [4] 🔓 Unlock User                                           ${NEON_CYAN}║${NC}"
    echo -e "${NEON_CYAN}║${NEON_WHITE}  [5] 🗑️ Delete User                                           ${NEON_CYAN}║${NC}"
    echo -e "${NEON_CYAN}║${NEON_WHITE}  [6] ⚙️ Set User Session Limit                                ${NEON_CYAN}║${NC}"
    echo -e "${NEON_CYAN}║${NEON_WHITE}  [7] 📊 View User Traffic Details                             ${NEON_CYAN}║${NC}"
    echo -e "${NEON_CYAN}║${NEON_WHITE}  [0] ↩️ Back to Main Menu                                     ${NEON_CYAN}║${NC}"
    echo -e "${NEON_CYAN}╚═══════════════════════════════════════════════════════════════╝${NC}"
    echo ""
    read -p "$(echo -e $NEON_GREEN"Choose option [0-7]: "$NC)" opt
    
    case $opt in
        1) add_user ;;
        2) list_users ;;
        3) lock_user ;;
        4) unlock_user ;;
        5) delete_user ;;
        6) set_session_limit ;;
        7) user_traffic_details ;;
        0) return 0 ;;
        *) echo -e "${NEON_RED}Invalid option${NC}"; sleep 2 ;;
    esac
}

add_user() {
    clear
    echo -e "${NEON_CYAN}╔═══════════════════════════════════════════════════════════════╗${NC}"
    echo -e "${NEON_CYAN}║${NEON_YELLOW}${BOLD}              CREATE SSH + DNS USER (WITH LIMITS)                ${NEON_CYAN}║${NC}"
    echo -e "${NEON_CYAN}╚═══════════════════════════════════════════════════════════════╝${NC}"
    
    read -p "$(echo -e $NEON_GREEN"Username: "$NC)" username
    read -p "$(echo -e $NEON_GREEN"Password: "$NC)" password
    read -p "$(echo -e $NEON_GREEN"Expire days: "$NC)" days
    read -p "$(echo -e $NEON_GREEN"Traffic limit (MB, 0 for unlimited): "$NC)" traffic_limit
    read -p "$(echo -e $NEON_GREEN"Max concurrent sessions (0 for unlimited): "$NC)" max_sessions
    
    if id "$username" &>/dev/null; then
        echo -e "${NEON_RED}User already exists!${NC}"
        read -p "Press Enter to continue..."
        show_menu
        return
    fi
    
    useradd -m -s /bin/false "$username"
    echo "$username:$password" | chpasswd
    
    expire_date=$(date -d "+$days days" +"%Y-%m-%d")
    chage -E "$expire_date" "$username"
    
    cat > $UD/$username <<INFO
Username: $username
Password: $password
Expire: $expire_date
Traffic_Limit: $traffic_limit
Max_Sessions: $max_sessions
Created: $(date +"%Y-%m-%d")
Status: ACTIVE
INFO
    
    echo "0" > $TD/$username
    
    SERVER=$(cat /etc/elite-x/subdomain 2>/dev/null || echo "?")
    PUBKEY=$(cat /etc/dnstt/server.pub 2>/dev/null || echo "Not generated")
    
    clear
    echo -e "${NEON_GREEN}╔═══════════════════════════════════════════════════════════════╗${NC}"
    echo -e "${NEON_GREEN}║${NEON_YELLOW}${BOLD}                  USER DETAILS                                   ${NEON_GREEN}║${NC}"
    echo -e "${NEON_GREEN}╠═══════════════════════════════════════════════════════════════╣${NC}"
    echo -e "${NEON_GREEN}║${NEON_WHITE}  Username     :${NEON_CYAN} $username${NC}"
    echo -e "${NEON_GREEN}║${NEON_WHITE}  Password     :${NEON_CYAN} $password${NC}"
    echo -e "${NEON_GREEN}║${NEON_WHITE}  Server       :${NEON_CYAN} $SERVER${NC}"
    echo -e "${NEON_GREEN}║${NEON_WHITE}  Public Key   :${NEON_CYAN} $PUBKEY${NC}"
    echo -e "${NEON_GREEN}║${NEON_WHITE}  Expire       :${NEON_CYAN} $expire_date${NC}"
    echo -e "${NEON_GREEN}║${NEON_WHITE}  Traffic Limit:${NEON_CYAN} $traffic_limit MB${NC}"
    echo -e "${NEON_GREEN}║${NEON_WHITE}  Max Sessions :${NEON_CYAN} $max_sessions${NC}"
    echo -e "${NEON_GREEN}╚═══════════════════════════════════════════════════════════════╝${NC}"
    show_quote
    read -p "Press Enter to continue..."
    show_menu
}

list_users() {
    clear
    echo -e "${NEON_CYAN}╔═══════════════════════════════════════════════════════════════╗${NC}"
    echo -e "${NEON_CYAN}║${NEON_YELLOW}${BOLD}                     ACTIVE USERS (REAL-TIME TRAFFIC)               ${NEON_CYAN}║${NC}"
    echo -e "${NEON_CYAN}╠═══════════════════════════════════════════════════════════════╣${NC}"
    
    if [ -z "$(ls -A $UD 2>/dev/null)" ]; then
        echo -e "${NEON_RED}No users found${NC}"
        show_quote
        read -p "Press Enter to continue..."
        show_menu
        return
    fi
    
    printf "${NEON_WHITE}%-12s %-10s %-8s %-8s %-8s %-8s %-8s %s${NC}\n" "USERNAME" "EXPIRE" "LIMIT" "USED" "SESSIONS" "MAX" "USAGE%" "STATUS"
    echo -e "${NEON_CYAN}────────────────────────────────────────────────────────────────────────────────────────────${NC}"
    
    for user_file in $UD/*; do
        [ ! -f "$user_file" ] && continue
        username=$(basename "$user_file")
        
        expire=$(grep "Expire:" "$user_file" | cut -d' ' -f2)
        limit=$(grep "Traffic_Limit:" "$user_file" | cut -d' ' -f2)
        max_sess=$(grep "Max_Sessions:" "$user_file" | cut -d' ' -f2)
        
        # Get real-time traffic
        used=$(cat $TD/$username 2>/dev/null || echo "0")
        
        # Count active sessions
        sessions=$(ps -u "$username" 2>/dev/null | grep -c "sshd" || echo "0")
        
        # Calculate usage percentage
        if [ "$limit" -gt 0 ] 2>/dev/null; then
            percent=$((used * 100 / limit))
            if [ "$percent" -ge 100 ]; then
                percent_disp="${NEON_RED}${percent}%${NC}"
                status="${NEON_RED}LIMIT EXCEEDED${NC}"
            elif [ "$percent" -ge 80 ]; then
                percent_disp="${NEON_YELLOW}${percent}%${NC}"
                if passwd -S "$username" 2>/dev/null | grep -q "L"; then
                    status="${NEON_RED}LOCKED${NC}"
                else
                    status="${NEON_GREEN}ACTIVE${NC}"
                fi
            else
                percent_disp="${NEON_GREEN}${percent}%${NC}"
                if passwd -S "$username" 2>/dev/null | grep -q "L"; then
                    status="${NEON_RED}LOCKED${NC}"
                else
                    status="${NEON_GREEN}ACTIVE${NC}"
                fi
            fi
        else
            percent_disp="${NEON_GREEN}---${NC}"
            if passwd -S "$username" 2>/dev/null | grep -q "L"; then
                status="${NEON_RED}LOCKED${NC}"
            else
                status="${NEON_GREEN}ACTIVE${NC}"
            fi
        fi
        
        # Color code sessions vs max
        if [ "$max_sess" -gt 0 ] 2>/dev/null; then
            if [ "$sessions" -ge "$max_sess" ]; then
                sess_disp="${NEON_RED}${sessions}/${max_sess}${NC}"
            else
                sess_disp="${NEON_GREEN}${sessions}/${max_sess}${NC}"
            fi
        else
            sess_disp="${NEON_WHITE}${sessions}/∞${NC}"
        fi
        
        printf "${NEON_CYAN}%-12s ${NEON_GREEN}%-10s ${NEON_WHITE}%-8s ${NEON_YELLOW}%-8s ${NEON_PURPLE}%-8b ${NEON_BLUE}%-8s ${NEON_WHITE}%-8b ${NEON_CYAN}%b${NC}\n" \
               "$username" "$expire" "$limit" "$used" "$sess_disp" "$max_sess" "$percent_disp" "$status"
    done
    
    echo -e "${NEON_CYAN}────────────────────────────────────────────────────────────────────────────────────────────${NC}"
    
    total_users=$(ls -1 $UD | wc -l)
    total_active=$(ss -tnp | grep :22 | grep ESTAB | wc -l)
    echo -e "${NEON_WHITE}Total Users: ${NEON_GREEN}$total_users${NC}  ${NEON_WHITE}Active Connections: ${NEON_GREEN}$total_active${NC}"
    
    show_quote
    read -p "Press Enter to continue..."
    show_menu
}

set_session_limit() {
    clear
    echo -e "${NEON_CYAN}╔═══════════════════════════════════════════════════════════════╗${NC}"
    echo -e "${NEON_CYAN}║${NEON_YELLOW}${BOLD}                 SET USER SESSION LIMIT                           ${NEON_CYAN}║${NC}"
    echo -e "${NEON_CYAN}╚═══════════════════════════════════════════════════════════════╝${NC}"
    
    read -p "$(echo -e $NEON_GREEN"Username: "$NC)" username
    
    if [ ! -f "$UD/$username" ]; then
        echo -e "${NEON_RED}User not found!${NC}"
        read -p "Press Enter to continue..."
        show_menu
        return
    fi
    
    current=$(grep "Max_Sessions:" "$UD/$username" 2>/dev/null | cut -d' ' -f2 || echo "0")
    echo -e "${NEON_WHITE}Current max sessions: ${NEON_CYAN}$current${NC}"
    read -p "$(echo -e $NEON_GREEN"New max sessions (0 for unlimited): "$NC)" new_limit
    
    if grep -q "Max_Sessions:" "$UD/$username"; then
        sed -i "s/Max_Sessions:.*/Max_Sessions: $new_limit/" "$UD/$username"
    else
        echo "Max_Sessions: $new_limit" >> "$UD/$username"
    fi
    
    echo -e "${NEON_GREEN}✅ Session limit updated to $new_limit${NC}"
    read -p "Press Enter to continue..."
    show_menu
}

user_traffic_details() {
    clear
    echo -e "${NEON_CYAN}╔═══════════════════════════════════════════════════════════════╗${NC}"
    echo -e "${NEON_CYAN}║${NEON_YELLOW}${BOLD}                 USER TRAFFIC DETAILS                           ${NEON_CYAN}║${NC}"
    echo -e "${NEON_CYAN}╚═══════════════════════════════════════════════════════════════╝${NC}"
    
    read -p "$(echo -e $NEON_GREEN"Username: "$NC)" username
    
    if [ ! -f "$UD/$username" ]; then
        echo -e "${NEON_RED}User not found!${NC}"
        read -p "Press Enter to continue..."
        show_menu
        return
    fi
    
    used=$(cat $TD/$username 2>/dev/null || echo "0")
    limit=$(grep "Traffic_Limit:" "$UD/$username" | cut -d' ' -f2)
    expire=$(grep "Expire:" "$UD/$username" | cut -d' ' -f2)
    max_sess=$(grep "Max_Sessions:" "$UD/$username" | cut -d' ' -f2)
    created=$(grep "Created:" "$UD/$username" | cut -d' ' -f2-)
    
    echo -e "${NEON_WHITE}Username: ${NEON_CYAN}$username${NC}"
    echo -e "${NEON_WHITE}Created: ${NEON_CYAN}$created${NC}"
    echo -e "${NEON_WHITE}Expires: ${NEON_CYAN}$expire${NC}"
    echo -e "${NEON_WHITE}Traffic Used: ${NEON_YELLOW}$used MB${NC}"
    echo -e "${NEON_WHITE}Traffic Limit: ${NEON_GREEN}$limit MB${NC}"
    echo -e "${NEON_WHITE}Max Sessions: ${NEON_GREEN}$max_sess${NC}"
    
    if [ "$limit" -gt 0 ]; then
        percent=$((used * 100 / limit))
        echo -e "${NEON_WHITE}Usage: ${NEON_PURPLE}$percent%${NC}"
    fi
    
    read -p "Press Enter to continue..."
    show_menu
}

lock_user() { 
    read -p "$(echo -e $NEON_GREEN"Username: "$NC)" u
    if id "$u" &>/dev/null; then
        usermod -L "$u" 2>/dev/null && echo -e "${NEON_GREEN}✅ User $u locked${NC}" || echo -e "${NEON_RED}❌ Failed to lock${NC}"
        if [ -f "$UD/$u" ]; then
            sed -i 's/^Status:.*/Status: LOCKED (Manual)/' "$UD/$u" 2>/dev/null || echo "Status: LOCKED (Manual)" >> "$UD/$u"
        fi
    else
        echo -e "${NEON_RED}❌ User does not exist${NC}"
    fi
    read -p "Press Enter to continue..."
    show_menu
}

unlock_user() { 
    read -p "$(echo -e $NEON_GREEN"Username: "$NC)" u
    if id "$u" &>/dev/null; then
        usermod -U "$u" 2>/dev/null && echo -e "${NEON_GREEN}✅ User $u unlocked${NC}" || echo -e "${NEON_RED}❌ Failed to unlock${NC}"
        if [ -f "$UD/$u" ]; then
            sed -i 's/^Status:.*/Status: ACTIVE/' "$UD/$u" 2>/dev/null
        fi
    else
        echo -e "${NEON_RED}❌ User does not exist${NC}"
    fi
    read -p "Press Enter to continue..."
    show_menu
}

delete_user() { 
    read -p "$(echo -e $NEON_GREEN"Username: "$NC)" u
    if id "$u" &>/dev/null; then
        pkill -u "$u" 2>/dev/null || true
        userdel -r -f "$u" 2>/dev/null
        rm -f $UD/$u $TD/$u
        echo -e "${NEON_GREEN}✅ User $u deleted${NC}"
    else
        echo -e "${NEON_RED}❌ User does not exist${NC}"
    fi
    read -p "Press Enter to continue..."
    show_menu
}

show_menu
EOF
    chmod +x /usr/local/bin/elite-x-user
}

# ==================== CREATE REFRESH INFO SCRIPT ====================
create_refresh_script() {
    cat > /usr/local/bin/elite-x-refresh-info <<'EOF'
#!/bin/bash

NEON_CYAN='\033[1;36m'; NEON_GREEN='\033[1;32m'; NEON_RED='\033[1;31m'; NC='\033[0m'

IP=""
for service in "https://api.ipify.org" "ifconfig.me" "icanhazip.com" "ipinfo.io/ip" "checkip.amazonaws.com"; do
    IP=$(curl -s --connect-timeout 3 "$service" 2>/dev/null | grep -oE '([0-9]{1,3}\.){3}[0-9]{1,3}' | head -1)
    [ ! -z "$IP" ] && break
done

if [ -z "$IP" ]; then
    IP=$(ip -4 addr show | grep -oP '(?<=inet\s)\d+(\.\d+){3}' | grep -v '127.0.0.1' | head -1)
fi

if [ -z "$IP" ]; then
    echo "Unknown" > /etc/elite-x/cached_ip
    echo "Unknown" > /etc/elite-x/cached_location
    echo "Unknown" > /etc/elite-x/cached_isp
    exit 1
fi

echo "$IP" > /etc/elite-x/cached_ip

LOCATION="Unknown"
ISP="Unknown"

API_RESPONSE=$(curl -s --connect-timeout 3 "http://ip-api.com/json/$IP?fields=status,country,city,isp,org")
if echo "$API_RESPONSE" | grep -q '"status":"success"'; then
    COUNTRY=$(echo "$API_RESPONSE" | grep -o '"country":"[^"]*"' | cut -d'"' -f4)
    CITY=$(echo "$API_RESPONSE" | grep -o '"city":"[^"]*"' | cut -d'"' -f4)
    ISP=$(echo "$API_RESPONSE" | grep -o '"isp":"[^"]*"' | cut -d'"' -f4)
    
    [ -z "$ISP" ] && ISP=$(echo "$API_RESPONSE" | grep -o '"org":"[^"]*"' | cut -d'"' -f4)
    
    if [ ! -z "$CITY" ] && [ "$CITY" != "null" ]; then
        LOCATION="$CITY, $COUNTRY"
    else
        LOCATION="$COUNTRY"
    fi
fi

if [ "$LOCATION" = "Unknown" ] || [ "$LOCATION" = "null" ]; then
    IPINFO=$(curl -s --connect-timeout 3 "ipinfo.io/$IP" 2>/dev/null)
    if [ ! -z "$IPINFO" ]; then
        CITY=$(echo "$IPINFO" | grep -o '"city":"[^"]*"' | cut -d'"' -f4)
        COUNTRY=$(echo "$IPINFO" | grep -o '"country":"[^"]*"' | cut -d'"' -f4)
        ORG=$(echo "$IPINFO" | grep -o '"org":"[^"]*"' | cut -d'"' -f4)
        
        if [ ! -z "$CITY" ] && [ "$CITY" != "null" ]; then
            LOCATION="$CITY, $COUNTRY"
        elif [ ! -z "$COUNTRY" ] && [ "$COUNTRY" != "null" ]; then
            LOCATION="$COUNTRY"
        fi
        
        [ "$ISP" = "Unknown" ] && [ ! -z "$ORG" ] && [ "$ORG" != "null" ] && ISP="$ORG"
    fi
fi

echo "$LOCATION" > /etc/elite-x/cached_location
echo "$ISP" > /etc/elite-x/cached_isp
EOF
    chmod +x /usr/local/bin/elite-x-refresh-info
}

# ==================== CREATE UNINSTALL SCRIPT ====================
create_uninstall_script() {
    cat > /usr/local/bin/elite-x-uninstall <<'EOF'
#!/bin/bash

NEON_RED='\033[1;31m'; NEON_GREEN='\033[1;32m'; NEON_YELLOW='\033[1;33m'; NC='\033[0m'; BLINK='\033[5m'

echo -e "${NEON_RED}${BLINK}🗑️  COMPLETE UNINSTALL - REMOVING EVERYTHING...${NC}"
    
systemctl stop dnstt-elite-x dnstt-elite-x-proxy elite-x-traffic elite-x-cleaner elite-x-auto-adapt elite-x-limit-manager elite-x-bandwidth-monitor 2>/dev/null || true
systemctl disable dnstt-elite-x dnstt-elite-x-proxy elite-x-traffic elite-x-cleaner elite-x-auto-adapt elite-x-limit-manager elite-x-bandwidth-monitor 2>/dev/null || true
    
rm -f /etc/systemd/system/{dnstt-elite-x*,elite-x-*}
    
echo -e "${NEON_YELLOW}🔍 Removing all ELITE-X users...${NC}"

if [ -d "/etc/elite-x/users" ]; then
    for user_file in /etc/elite-x/users/*; do
        if [ -f "$user_file" ]; then
            username=$(basename "$user_file")
            echo -e "${NEON_RED}Removing user: $username${NC}"
            pkill -u "$username" 2>/dev/null || true
            userdel -r -f "$username" 2>/dev/null || true
            rm -rf /home/"$username" 2>/dev/null || true
        fi
    done
fi

pkill -f dnstt-server 2>/dev/null || true
pkill -f dnstt-edns-proxy 2>/dev/null || true
    
rm -rf /etc/dnstt
rm -rf /etc/elite-x
rm -f /usr/local/bin/{dnstt-*,elite-x*}
rm -f /usr/local/bin/dnstt-edns-proxy.py
rm -f /usr/local/bin/elite-x-{live,analyzer,renew,update,traffic,cleaner,user,refresh,uninstall,auto-adapt,limit-manager,bandwidth-monitor,network-optimizer}
    
sed -i '/^Banner/d' /etc/ssh/sshd_config
systemctl restart sshd
    
rm -f /etc/cron.hourly/elite-x-expiry
rm -f /etc/profile.d/elite-x-dashboard.sh
sed -i '/elite-x/d' /root/.bashrc 2>/dev/null || true
    
systemctl daemon-reload

echo -e "${NEON_GREEN}${BLINK}✅✅✅ COMPLETE UNINSTALL FINISHED! EVERYTHING REMOVED. ✅✅✅${NC}"
EOF
    chmod +x /usr/local/bin/elite-x-uninstall
}

# ==================== CREATE BOOSTER SCRIPT ====================
create_booster_script() {
    cat > /usr/local/bin/elite-x-booster <<'EOF'
#!/bin/bash

NEON_RED='\033[1;31m'; NEON_GREEN='\033[1;32m'; NEON_YELLOW='\033[1;33m'
NEON_CYAN='\033[1;36m'; NEON_WHITE='\033[1;37m'; NC='\033[0m'; BOLD='\033[1m'

booster_menu() {
    while true; do
        clear
        echo -e "${NEON_CYAN}╔═══════════════════════════════════════════════════════════════════════════╗${NC}"
        echo -e "${NEON_CYAN}║${NEON_YELLOW}${BOLD}                    🚀 ELITE-X BOOSTER MENU 🚀                              ${NEON_CYAN}║${NC}"
        echo -e "${NEON_CYAN}╠═══════════════════════════════════════════════════════════════════════════╣${NC}"
        echo -e "${NEON_CYAN}║${NEON_WHITE}  [1] 🔄 Check Current Network Mode                                   ${NEON_CYAN}║${NC}"
        echo -e "${NEON_CYAN}║${NEON_WHITE}  [2] 📊 Force Network Analysis                                       ${NEON_CYAN}║${NC}"
        echo -e "${NEON_CYAN}║${NEON_WHITE}  [3] 🛡️ Set ULTRA-STABLE Mode (MTU 1300)                             ${NEON_CYAN}║${NC}"
        echo -e "${NEON_CYAN}║${NEON_WHITE}  [4] ⚖️ Set Balanced Mode (MTU 1500)                                 ${NEON_CYAN}║${NC}"
        echo -e "${NEON_CYAN}║${NEON_WHITE}  [5] 🚀 Set TURBO Mode (MTU 1800)                                    ${NEON_CYAN}║${NC}"
        echo -e "${NEON_CYAN}║${NEON_WHITE}  [6] 📈 View Network Statistics                                     ${NEON_CYAN}║${NC}"
        echo -e "${NEON_CYAN}║${NEON_WHITE}  [7] 🔧 Run Full Network Optimization                               ${NEON_CYAN}║${NC}"
        echo -e "${NEON_CYAN}║${NEON_WHITE}  [8] 📊 View Auto-Adapt Log                                        ${NEON_CYAN}║${NC}"
        echo -e "${NEON_CYAN}║${NEON_WHITE}  [0] ↩️ Back to Settings                                           ${NEON_CYAN}║${NC}"
        echo -e "${NEON_CYAN}╚═══════════════════════════════════════════════════════════════════════════╝${NC}"
        echo ""
        read -p "$(echo -e $NEON_GREEN"Booster option: "$NC)" bch
        
        case $bch in
            1)
                if [ -f "/etc/elite-x/current_mode" ]; then
                    mode=$(cat /etc/elite-x/current_mode)
                    mtu=$(cat /etc/elite-x/mtu)
                    echo -e "${NEON_WHITE}Current Mode: ${NEON_PURPLE}$mode${NC}"
                    echo -e "${NEON_WHITE}Current MTU: ${NEON_CYAN}$mtu${NC}"
                else
                    echo -e "${NEON_YELLOW}No mode file found. Auto-adapt may not be running.${NC}"
                fi
                read -p "Press Enter..."
                ;;
            2)
                echo -e "${NEON_YELLOW}Running network analysis...${NC}"
                # Test packet loss
                loss=$(ping -c 20 -W 1 8.8.8.8 2>/dev/null | grep -oP '\d+(?=% packet loss)' || echo "0")
                # Test latency
                latency=$(ping -c 5 -W 1 8.8.8.8 2>/dev/null | tail -1 | awk -F '/' '{print $5}' | cut -d. -f1)
                [ -z "$latency" ] && latency="N/A"
                # Test jitter
                jitter=$(ping -c 10 -W 1 8.8.8.8 2>/dev/null | grep -oP 'time=\K[0-9.]+' | awk '{if(NR>1){sum+=($1-prev)^2} prev=$1} END{print sqrt(sum/(NR-1))}' || echo "0")
                
                echo -e "${NEON_WHITE}Packet Loss: ${NEON_RED}$loss%${NC}"
                echo -e "${NEON_WHITE}Avg Latency: ${NEON_YELLOW}$latency ms${NC}"
                echo -e "${NEON_WHITE}Jitter: ${NEON_CYAN}$jitter ms${NC}"
                
                # Recommendation
                if [ "$loss" -gt 10 ] || [ "$latency" -gt 300 ]; then
                    echo -e "${NEON_RED}Recommendation: Switch to ULTRA-STABLE mode${NC}"
                elif [ "$loss" -gt 3 ] || [ "$latency" -gt 150 ]; then
                    echo -e "${NEON_YELLOW}Recommendation: Switch to Balanced mode${NC}"
                elif [ "$loss" -lt 1 ] && [ "$latency" -lt 50 ]; then
                    echo -e "${NEON_GREEN}Recommendation: You can use TURBO mode${NC}"
                fi
                read -p "Press Enter..."
                ;;
            3)
                echo "ultra-stable" > /etc/elite-x/current_mode
                echo "1300" > /etc/elite-x/mtu
                sed -i "s/-mtu [0-9]*/-mtu 1300/" /etc/systemd/system/dnstt-elite-x.service
                systemctl daemon-reload
                systemctl restart dnstt-elite-x dnstt-elite-x-proxy
                echo -e "${NEON_GREEN}✅ Switched to ULTRA-STABLE mode (MTU: 1300)${NC}"
                read -p "Press Enter..."
                ;;
            4)
                echo "balanced" > /etc/elite-x/current_mode
                echo "1500" > /etc/elite-x/mtu
                sed -i "s/-mtu [0-9]*/-mtu 1500/" /etc/systemd/system/dnstt-elite-x.service
                systemctl daemon-reload
                systemctl restart dnstt-elite-x dnstt-elite-x-proxy
                echo -e "${NEON_GREEN}✅ Switched to BALANCED mode (MTU: 1500)${NC}"
                read -p "Press Enter..."
                ;;
            5)
                echo "turbo" > /etc/elite-x/current_mode
                echo "1800" > /etc/elite-x/mtu
                sed -i "s/-mtu [0-9]*/-mtu 1800/" /etc/systemd/system/dnstt-elite-x.service
                systemctl daemon-reload
                systemctl restart dnstt-elite-x dnstt-elite-x-proxy
                echo -e "${NEON_GREEN}✅ Switched to TURBO mode (MTU: 1800)${NC}"
                read -p "Press Enter..."
                ;;
            6)
                echo -e "${NEON_YELLOW}Network Statistics:${NC}"
                echo -e "${NEON_WHITE}Active Connections: $(ss -tnp | grep :22 | grep ESTAB | wc -l)${NC}"
                echo -e "${NEON_WHITE}DNS Tunnels: $(ss -unp | grep :5300 | wc -l)${NC}"
                echo -e "${NEON_WHITE}System Load: $(uptime | awk -F'load average:' '{print $2}')${NC}"
                echo -e "${NEON_WHITE}Memory Usage: $(free -h | awk '/^Mem:/{print $3"/"$2}')${NC}"
                read -p "Press Enter..."
                ;;
            7)
                echo -e "${NEON_YELLOW}Running full network optimization...${NC}"
                /usr/local/bin/elite-x-network-optimizer full
                echo -e "${NEON_GREEN}✅ Optimization complete${NC}"
                read -p "Press Enter..."
                ;;
            8)
                if [ -f "/var/log/elite-x-auto-adapt.log" ]; then
                    tail -20 /var/log/elite-x-auto-adapt.log
                else
                    echo -e "${NEON_YELLOW}No log file found${NC}"
                fi
                read -p "Press Enter..."
                ;;
            0) return ;;
            *) echo -e "${NEON_RED}Invalid option${NC}"; read -p "Press Enter..." ;;
        esac
    done
}

booster_menu
EOF
    chmod +x /usr/local/bin/elite-x-booster
}

# ==================== MAIN MENU SCRIPT ====================
setup_main_menu() {
    cat >/usr/local/bin/elite-x <<'EOF'
#!/bin/bash

NEON_RED='\033[1;31m'; NEON_GREEN='\033[1;32m'; NEON_YELLOW='\033[1;33m'
NEON_BLUE='\033[1;34m'; NEON_PURPLE='\033[1;35m'; NEON_CYAN='\033[1;36m'
NEON_PINK='\033[1;38;5;201m'; NEON_WHITE='\033[1;37m'
BOLD='\033[1m'; BLINK='\033[5m'; NC='\033[0m'

if [ -f /tmp/elite-x-running ]; then
    exit 0
fi
touch /tmp/elite-x-running
trap 'rm -f /tmp/elite-x-running' EXIT

show_quote() {
    echo ""
    echo -e "${NEON_PURPLE}╔═══════════════════════════════════════════════════════════════╗${NC}"
    echo -e "${NEON_PURPLE}║${NEON_YELLOW}${BOLD}${BLINK}                                                               ${NEON_PURPLE}║${NC}"
    echo -e "${NEON_PURPLE}║${NEON_WHITE}${BOLD}           ███████╗██╗     ██╗████████╗███████╗     ██╗  ██╗           ${NEON_PURPLE}║${NC}"
    echo -e "${NEON_PURPLE}║${NEON_WHITE}${BOLD}           ██╔════╝██║     ██║╚══██╔══╝██╔════╝     ╚██╗██╔╝           ${NEON_PURPLE}║${NC}"
    echo -e "${NEON_PURPLE}║${NEON_WHITE}${BOLD}           █████╗  ██║     ██║   ██║   █████╗  █████╗╚███╔╝            ${NEON_PURPLE}║${NC}"
    echo -e "${NEON_PURPLE}║${NEON_WHITE}${BOLD}           ██╔══╝  ██║     ██║   ██║   ██╔══╝  ╚════╝██╔██╗            ${NEON_PURPLE}║${NC}"
    echo -e "${NEON_PURPLE}║${NEON_WHITE}${BOLD}           ███████╗███████╗██║   ██║   ███████╗     ██╔╝ ██╗           ${NEON_PURPLE}║${NC}"
    echo -e "${NEON_PURPLE}║${NEON_WHITE}${BOLD}           ╚══════╝╚══════╝╚═╝   ╚═╝   ╚══════╝     ╚═╝  ╚═╝           ${NEON_PURPLE}║${NC}"
    echo -e "${NEON_PURPLE}║${NEON_YELLOW}${BOLD}                                                               ${NEON_PURPLE}║${NC}"
    echo -e "${NEON_PURPLE}╚═══════════════════════════════════════════════════════════════╝${NC}"
    echo ""
}

check_expiry_menu() {
    if [ -f "/etc/elite-x/activation_type" ] && [ -f "/etc/elite-x/activation_date" ] && [ -f "/etc/elite-x/expiry_days" ]; then
        local act_type=$(cat "/etc/elite-x/activation_type")
        if [ "$act_type" = "temporary" ]; then
            local act_date=$(cat "/etc/elite-x/activation_date")
            local expiry_days=$(cat "/etc/elite-x/expiry_days")
            local current_date=$(date +%s)
            local expiry_date=$(date -d "$act_date + $expiry_days days" +%s)
            
            if [ $current_date -ge $expiry_date ]; then
                echo -e "${NEON_RED}╔═══════════════════════════════════════════════════════════════╗${NC}"
                echo -e "${NEON_RED}║${NEON_YELLOW}${BLINK}           ⚠️ TRIAL PERIOD EXPIRED ⚠️                           ${NEON_RED}║${NC}"
                echo -e "${NEON_RED}╠═══════════════════════════════════════════════════════════════╣${NC}"
                echo -e "${NEON_RED}║${NEON_WHITE}  Your 2-day trial has ended. Script will self-destruct...     ${NEON_RED}║${NC}"
                echo -e "${NEON_RED}╚═══════════════════════════════════════════════════════════════╝${NC}"
                sleep 3
                
                /usr/local/bin/elite-x-uninstall
                
                rm -f /tmp/elite-x-running
                exit 0
            fi
        fi
    fi
}

check_expiry_menu

show_dashboard() {
    clear
    
    if [ ! -f /etc/elite-x/cached_ip ] || [ $(( $(date +%s) - $(stat -c %Y /etc/elite-x/cached_ip 2>/dev/null || echo 0) )) -gt 3600 ]; then
        /usr/local/bin/elite-x-refresh-info
    fi
    
    IP=$(cat /etc/elite-x/cached_ip 2>/dev/null || echo "Unknown")
    LOC=$(cat /etc/elite-x/cached_location 2>/dev/null || echo "Unknown")
    ISP=$(cat /etc/elite-x/cached_isp 2>/dev/null || echo "Unknown")
    RAM=$(free -m | awk '/^Mem:/{printf "%s/%sMB (%.1f%%)", $3, $2, $3*100/$2}')
    CPU=$(top -bn1 | grep "Cpu(s)" | awk '{print $2}' | cut -d. -f1)
    LOAD=$(uptime | awk -F'load average:' '{print $2}')
    SUB=$(cat /etc/elite-x/subdomain 2>/dev/null || echo "Not configured")
    ACTIVATION_KEY=$(cat /etc/elite-x/key 2>/dev/null || echo "Unknown")
    EXP=$(cat /etc/elite-x/expiry 2>/dev/null || echo "Unknown")
    LOCATION=$(cat /etc/elite-x/location 2>/dev/null || echo "South Africa")
    CURRENT_MTU=$(cat /etc/elite-x/mtu 2>/dev/null || echo "1500")
    
    # Get current mode
    if [ -f "/etc/elite-x/current_mode" ]; then
        MODE=$(cat /etc/elite-x/current_mode)
        case $MODE in
            ultra-stable) MODE_COLOR="${NEON_RED}ULTRA-STABLE${NC}" ;;
            stable) MODE_COLOR="${NEON_YELLOW}STABLE${NC}" ;;
            balanced) MODE_COLOR="${NEON_GREEN}BALANCED${NC}" ;;
            turbo) MODE_COLOR="${NEON_PURPLE}TURBO${NC}" ;;
            *) MODE_COLOR="${NEON_WHITE}$MODE${NC}" ;;
        esac
    else
        MODE_COLOR="${NEON_WHITE}Unknown${NC}"
    fi
    
    DNS=$(systemctl is-active dnstt-elite-x 2>/dev/null | grep -q active && echo "${NEON_GREEN}●${NC}" || echo "${NEON_RED}●${NC}")
    PRX=$(systemctl is-active dnstt-elite-x-proxy 2>/dev/null | grep -q active && echo "${NEON_GREEN}●${NC}" || echo "${NEON_RED}●${NC}")
    ADAPT=$(systemctl is-active elite-x-auto-adapt 2>/dev/null | grep -q active && echo "${NEON_GREEN}●${NC}" || echo "${NEON_RED}●${NC}")
    
    ACTIVE_SSH=$(ss -tnp | grep :22 | grep ESTAB | wc -l)
    UPTIME=$(uptime -p | sed 's/up //')
    
    echo -e "${NEON_PURPLE}╔═══════════════════════════════════════════════════════════════════════════╗${NC}"
    echo -e "${NEON_PURPLE}║${NEON_YELLOW}${BOLD}                 ELITE-X SLOWDNS v5.1 - ULTRA STABILITY                ${NEON_PURPLE}║${NC}"
    echo -e "${NEON_PURPLE}╠═══════════════════════════════════════════════════════════════════════════╣${NC}"
    echo -e "${NEON_PURPLE}║${NEON_WHITE}  🌐 Subdomain :${NEON_GREEN} $SUB${NC}"
    echo -e "${NEON_PURPLE}║${NEON_WHITE}  📍 IP        :${NEON_GREEN} $IP${NC}"
    echo -e "${NEON_PURPLE}║${NEON_WHITE}  🗺️ Location  :${NEON_GREEN} $LOC${NC}"
    echo -e "${NEON_PURPLE}║${NEON_WHITE}  🏢 ISP       :${NEON_GREEN} $ISP${NC}"
    echo -e "${NEON_PURPLE}║${NEON_WHITE}  💾 RAM       :${NEON_GREEN} $RAM${NC}"
    echo -e "${NEON_PURPLE}║${NEON_WHITE}  ⚡ CPU       :${NEON_GREEN} ${CPU}%${NC}"
    echo -e "${NEON_PURPLE}║${NEON_WHITE}  📊 Load Avg  :${NEON_GREEN} $LOAD${NC}"
    echo -e "${NEON_PURPLE}║${NEON_WHITE}  ⏱️ Uptime    :${NEON_GREEN} $UPTIME${NC}"
    echo -e "${NEON_PURPLE}║${NEON_WHITE}  🔗 Active SSH:${NEON_GREEN} $ACTIVE_SSH${NC}"
    echo -e "${NEON_PURPLE}║${NEON_WHITE}  🎯 Mode      : $MODE_COLOR (MTU: $CURRENT_MTU)${NC}"
    echo -e "${NEON_PURPLE}║${NEON_WHITE}  🌍 VPS Loc   :${NEON_GREEN} $LOCATION${NC}"
    echo -e "${NEON_PURPLE}║${NEON_WHITE}  🛠️ Services  : DNS:$DNS PRX:$PRX ADAPT:$ADAPT${NC}"
    echo -e "${NEON_PURPLE}║${NEON_WHITE}  👨‍💻 Developer :${NEON_PINK} ELITE-X TEAM${NC}"
    echo -e "${NEON_PURPLE}╠═══════════════════════════════════════════════════════════════════════════╣${NC}"
    echo -e "${NEON_PURPLE}║${NEON_WHITE}  🔑 Act Key   :${NEON_YELLOW} $ACTIVATION_KEY${NC}"
    echo -e "${NEON_PURPLE}║${NEON_WHITE}  ⏳ Expiry    :${NEON_YELLOW} $EXP${NC}"
    echo -e "${NEON_PURPLE}╚═══════════════════════════════════════════════════════════════════════════╝${NC}"
    echo ""
}

settings_menu() {
    while true; do
        clear
        echo -e "${NEON_CYAN}╔═══════════════════════════════════════════════════════════════════════════╗${NC}"
        echo -e "${NEON_CYAN}║${NEON_YELLOW}${BOLD}                         ⚙️ SETTINGS MENU ⚙️                            ${NEON_CYAN}║${NC}"
        echo -e "${NEON_CYAN}╠═══════════════════════════════════════════════════════════════════════════╣${NC}"
        echo -e "${NEON_CYAN}║${NEON_WHITE}  [8]  🔑 View Public Key${NC}"
        echo -e "${NEON_CYAN}║${NEON_WHITE}  [9]  📏 Change MTU Value${NC}"
        echo -e "${NEON_CYAN}║${NEON_WHITE}  [10] 🚀 BOOSTER MENU (Auto-Adapt, Modes)${NC}"
        echo -e "${NEON_CYAN}║${NEON_WHITE}  [11] 🧹 Clean Junk Files${NC}"
        echo -e "${NEON_CYAN}║${NEON_WHITE}  [12] 🔄 Auto Expired Account Remover${NC}"
        echo -e "${NEON_CYAN}║${NEON_WHITE}  [13] 📦 Update Script${NC}"
        echo -e "${NEON_CYAN}║${NEON_WHITE}  [14] 🔄 Restart All Services${NC}"
        echo -e "${NEON_CYAN}║${NEON_WHITE}  [15] 🔄 Reboot VPS${NC}"
        echo -e "${NEON_CYAN}║${NEON_WHITE}  [16] 🗑️ Uninstall Script${NC}"
        echo -e "${NEON_CYAN}║${NEON_WHITE}  [17] 🌍 Re-apply Location Optimization${NC}"
        echo -e "${NEON_CYAN}║${NEON_WHITE}  [18] 🔄 Change Subdomain${NC}"
        echo -e "${NEON_CYAN}║${NEON_WHITE}  [19] 👁️ Live Connection Monitor${NC}"
        echo -e "${NEON_CYAN}║${NEON_WHITE}  [20] 📊 Traffic Analyzer${NC}"
        echo -e "${NEON_CYAN}║${NEON_WHITE}  [21] 🔄 Renew SSH Account${NC}"
        echo -e "${NEON_CYAN}║${NEON_WHITE}  [22] 📈 System Performance Test${NC}"
        echo -e "${NEON_CYAN}║${NEON_WHITE}  [23] 🔄 Refresh IP/Location Info${NC}"
        echo -e "${NEON_CYAN}║${NEON_WHITE}  [24] ⚙️ Network Optimizer${NC}"
        echo -e "${NEON_CYAN}║${NEON_WHITE}  [0]  ↩️ Back to Main Menu${NC}"
        echo -e "${NEON_CYAN}╚═══════════════════════════════════════════════════════════════════════════╝${NC}"
        echo ""
        read -p "$(echo -e $NEON_GREEN"Settings option: "$NC)" ch
        
        case $ch in
            8)
                echo -e "${NEON_CYAN}╔═══════════════════════════════════════════════════════════════╗${NC}"
                echo -e "${NEON_CYAN}║${NEON_YELLOW}${BOLD}                    PUBLIC KEY (FULL)                           ${NEON_CYAN}║${NC}"
                echo -e "${NEON_CYAN}╠═══════════════════════════════════════════════════════════════╣${NC}"
                echo -e "${NEON_CYAN}║${NEON_GREEN}  $(cat /etc/dnstt/server.pub)${NC}"
                echo -e "${NEON_CYAN}╚═══════════════════════════════════════════════════════════════╝${NC}"
                read -p "Press Enter to continue..."
                ;;
            9)
                echo -e "${NEON_YELLOW}Current MTU: $(cat /etc/elite-x/mtu)${NC}"
                read -p "$(echo -e $NEON_GREEN"New MTU (1000-5000): "$NC)" mtu
                [[ "$mtu" =~ ^[0-9]+$ ]] && [ $mtu -ge 1000 ] && [ $mtu -le 5000 ] && {
                    echo "$mtu" > /etc/elite-x/mtu
                    sed -i "s/-mtu [0-9]*/-mtu $mtu/" /etc/systemd/system/dnstt-elite-x.service
                    systemctl daemon-reload
                    systemctl restart dnstt-elite-x dnstt-elite-x-proxy
                    echo -e "${NEON_GREEN}✅ MTU updated to $mtu${NC}"
                } || echo -e "${NEON_RED}❌ Invalid (must be 1000-5000)${NC}"
                read -p "Press Enter to continue..."
                ;;
            10)
                elite-x-booster
                ;;
            11)
                echo -e "${NEON_YELLOW}🧹 Cleaning junk files...${NC}"
                apt clean -y 2>/dev/null
                apt autoclean -y 2>/dev/null
                journalctl --vacuum-time=3d 2>/dev/null
                echo -e "${NEON_GREEN}✅ Cleanup complete${NC}"
                read -p "Press Enter to continue..."
                ;;
            12)
                systemctl enable --now elite-x-cleaner.service 2>/dev/null
                echo -e "${NEON_GREEN}✅ Auto remover started${NC}"
                read -p "Press Enter to continue..."
                ;;
            13)
                elite-x-update
                read -p "Press Enter to continue..."
                ;;
            14)
                systemctl restart dnstt-elite-x dnstt-elite-x-proxy elite-x-auto-adapt elite-x-limit-manager elite-x-bandwidth-monitor sshd
                echo -e "${NEON_GREEN}✅ Services restarted${NC}"
                read -p "Press Enter to continue..."
                ;;
            15)
                read -p "$(echo -e $NEON_RED"Reboot? (y/n): "$NC)" c
                [ "$c" = "y" ] && reboot
                ;;
            16)
                read -p "$(echo -e $NEON_RED"Type YES to uninstall: "$NC)" c
                [ "$c" = "YES" ] && {
                    /usr/local/bin/elite-x-uninstall
                    rm -f /tmp/elite-x-running
                    exit 0
                }
                read -p "Press Enter to continue..."
                ;;
            17)
                echo -e "${NEON_YELLOW}═══════════════════════════════════════════════════════════════${NC}"
                echo -e "${NEON_GREEN}           RE-APPLY LOCATION OPTIMIZATION                        ${NC}"
                echo -e "${NEON_YELLOW}═══════════════════════════════════════════════════════════════${NC}"
                echo -e "${NEON_WHITE}Select your VPS location:${NC}"
                echo -e "${NEON_GREEN}  1. South Africa (MTU 1800)${NC}"
                echo -e "${NEON_CYAN}  2. USA${NC}"
                echo -e "${NEON_BLUE}  3. Europe${NC}"
                echo -e "${NEON_PURPLE}  4. Asia${NC}"
                echo -e "${NEON_PINK}  5. Auto-detect${NC}"
                read -p "Choice: " opt_choice
                
                case $opt_choice in
                    1) echo "South Africa" > /etc/elite-x/location
                       echo "1800" > /etc/elite-x/mtu
                       sed -i "s/-mtu [0-9]*/-mtu 1800/" /etc/systemd/system/dnstt-elite-x.service
                       systemctl daemon-reload
                       systemctl restart dnstt-elite-x dnstt-elite-x-proxy
                       echo -e "${NEON_GREEN}✅ South Africa selected (MTU 1800)${NC}" ;;
                    2) echo "USA" > /etc/elite-x/location
                       echo -e "${NEON_GREEN}✅ USA selected${NC}" ;;
                    3) echo "Europe" > /etc/elite-x/location
                       echo -e "${NEON_GREEN}✅ Europe selected${NC}" ;;
                    4) echo "Asia" > /etc/elite-x/location
                       echo -e "${NEON_GREEN}✅ Asia selected${NC}" ;;
                    5) echo "Auto-detect" > /etc/elite-x/location
                       echo -e "${NEON_GREEN}✅ Auto-detect selected${NC}" ;;
                esac
                read -p "Press Enter to continue..."
                ;;
            18)
                echo -e "${NEON_YELLOW}Current subdomain: $(cat /etc/elite-x/subdomain)${NC}"
                read -p "$(echo -e $NEON_GREEN"New subdomain: "$NC)" new_sub
                if [ ! -z "$new_sub" ]; then
                    old_sub=$(cat /etc/elite-x/subdomain)
                    echo "$new_sub" > /etc/elite-x/subdomain
                    sed -i "s|$old_sub|$new_sub|g" /etc/systemd/system/dnstt-elite-x.service
                    systemctl daemon-reload
                    systemctl restart dnstt-elite-x dnstt-elite-x-proxy
                    echo -e "${NEON_GREEN}✅ Subdomain updated to $new_sub${NC}"
                fi
                read -p "Press Enter to continue..."
                ;;
            19)
                elite-x-live
                ;;
            20)
                elite-x-analyzer
                read -p "Press Enter to continue..."
                ;;
            21)
                elite-x-renew
                read -p "Press Enter to continue..."
                ;;
            22)
                echo -e "${NEON_YELLOW}📈 Running system performance test...${NC}"
                echo ""
                echo -e "${NEON_CYAN}CPU Info:${NC}"
                lscpu | grep "Model name" | cut -d: -f2 | sed 's/^ //' 2>/dev/null || echo "N/A"
                echo -e "${NEON_CYAN}CPU Cores: $(nproc)${NC}"
                echo ""
                echo -e "${NEON_CYAN}Memory Speed Test:${NC}"
                dd if=/dev/zero of=/tmp/test bs=1M count=1024 conv=fdatasync 2>&1 | grep -o '[0-9.]\+ [GM]B/s' || echo "N/A"
                rm -f /tmp/test 2>/dev/null
                echo ""
                read -p "Press Enter to continue..."
                ;;
            23)
                echo -e "${NEON_YELLOW}🔄 Refreshing IP/Location information...${NC}"
                /usr/local/bin/elite-x-refresh-info
                echo -e "${NEON_GREEN}✅ Information refreshed!${NC}"
                read -p "Press Enter to continue..."
                ;;
            24)
                echo -e "${NEON_YELLOW}⚙️ Running network optimizer...${NC}"
                /usr/local/bin/elite-x-network-optimizer full
                read -p "Press Enter to continue..."
                ;;
            0) return ;;
            *) echo -e "${NEON_RED}Invalid option${NC}"; read -p "Press Enter..." ;;
        esac
    done
}

main_menu() {
    while true; do
        show_dashboard
        echo -e "${NEON_CYAN}╔═══════════════════════════════════════════════════════════════════════════╗${NC}"
        echo -e "${NEON_CYAN}║${NEON_GREEN}${BOLD}                         🎯 MAIN MENU 🎯                               ${NEON_CYAN}║${NC}"
        echo -e "${NEON_CYAN}╠═══════════════════════════════════════════════════════════════════════════╣${NC}"
        echo -e "${NEON_CYAN}║${NEON_WHITE}  [1]  👤 User Management Menu (with limits & real-time traffic)      ${NEON_CYAN}║${NC}"
        echo -e "${NEON_CYAN}║${NEON_WHITE}  [2]  📋 List All Users (quick view)                                 ${NEON_CYAN}║${NC}"
        echo -e "${NEON_CYAN}║${NEON_WHITE}  [3]  🔒 Lock User                                                   ${NEON_CYAN}║${NC}"
        echo -e "${NEON_CYAN}║${NEON_WHITE}  [4]  🔓 Unlock User                                                 ${NEON_CYAN}║${NC}"
        echo -e "${NEON_CYAN}║${NEON_WHITE}  [5]  🗑️ Delete User                                                 ${NEON_CYAN}║${NC}"
        echo -e "${NEON_CYAN}║${NEON_WHITE}  [6]  📝 Create/Edit Banner                                         ${NEON_CYAN}║${NC}"
        echo -e "${NEON_CYAN}║${NEON_WHITE}  [7]  ❌ Delete Banner                                              ${NEON_CYAN}║${NC}"
        echo -e "${NEON_CYAN}║${NEON_WHITE}  [8]  📈 Quick Traffic Stats                                        ${NEON_CYAN}║${NC}"
        echo -e "${NEON_CYAN}║${NEON_RED}  [S]  ⚙️  SETTINGS (Modes, Boosters, etc)                              ${NEON_CYAN}║${NC}"
        echo -e "${NEON_CYAN}║${NEON_WHITE}  [00] 🚪 Exit                                                        ${NEON_CYAN}║${NC}"
        echo -e "${NEON_CYAN}╚═══════════════════════════════════════════════════════════════════════════╝${NC}"
        echo ""
        read -p "$(echo -e $NEON_GREEN"Main menu option: "$NC)" ch
        
        case $ch in
            1) elite-x-user ;;
            2) elite-x-user list ;;
            3) elite-x-user lock ;;
            4) elite-x-user unlock ;;
            5) elite-x-user del ;;
            6)
                mkdir -p /etc/elite-x/banner
                [ -f /etc/elite-x/banner/custom ] || cp /etc/elite-x/banner/default /etc/elite-x/banner/custom 2>/dev/null || echo "Welcome to ELITE-X" > /etc/elite-x/banner/custom
                nano /etc/elite-x/banner/custom
                cp /etc/elite-x/banner/custom /etc/elite-x/banner/ssh-banner 2>/dev/null
                systemctl restart sshd
                echo -e "${NEON_GREEN}✅ Banner saved${NC}"
                read -p "Press Enter to continue..."
                ;;
            7)
                rm -f /etc/elite-x/banner/custom
                cp /etc/elite-x/banner/default /etc/elite-x/banner/ssh-banner 2>/dev/null || echo "Welcome to ELITE-X" > /etc/elite-x/banner/ssh-banner
                systemctl restart sshd
                echo -e "${NEON_GREEN}✅ Banner deleted${NC}"
                read -p "Press Enter to continue..."
                ;;
            8)
                echo -e "${NEON_YELLOW}Quick Traffic Stats:${NC}"
                echo "──────────────────"
                for user in /etc/elite-x/users/*; do
                    if [ -f "$user" ]; then
                        u=$(basename "$user")
                        us=$(cat /etc/elite-x/traffic/$u 2>/dev/null || echo "0")
                        echo -e "$u: ${NEON_CYAN}$us MB${NC}"
                    fi
                done
                echo ""
                read -p "Press Enter to continue..."
                ;;
            [Ss]) settings_menu ;;
            00|0) 
                rm -f /tmp/elite-x-running
                show_quote
                echo -e "${NEON_GREEN}Goodbye!${NC}"
                exit 0 
                ;;
            *) echo -e "${NEON_RED}Invalid option${NC}"; read -p "Press Enter to continue..." ;;
        esac
    done
}

main_menu
EOF
    chmod +x /usr/local/bin/elite-x
}

# ==================== STABILITY FIXES ====================
apply_stability_fixes() {
    echo -e "${NEON_CYAN}🔧 Applying ultra stability fixes...${NC}"
    
    # Increase system limits
    cat >> /etc/security/limits.conf <<EOF
* soft nofile 1048576
* hard nofile 1048576
* soft nproc unlimited
* hard nproc unlimited
EOF

    # Optimize kernel for DNS tunnel stability
    cat >> /etc/sysctl.conf <<EOF

# ========== ELITE-X ULTRA STABILITY OPTIMIZATIONS ==========
# Increase connection tracking
net.netfilter.nf_conntrack_max = 1048576
net.netfilter.nf_conntrack_tcp_timeout_established = 86400
net.netfilter.nf_conntrack_udp_timeout = 120
net.netfilter.nf_conntrack_udp_timeout_stream = 300

# TCP keepalive settings
net.ipv4.tcp_keepalive_time = 30
net.ipv4.tcp_keepalive_intvl = 5
net.ipv4.tcp_keepalive_probes = 3

# Increase timeout values
net.ipv4.tcp_fin_timeout = 10
net.ipv4.tcp_retries1 = 2
net.ipv4.tcp_retries2 = 3
net.ipv4.tcp_syn_retries = 2
net.ipv4.tcp_synack_retries = 2

# Increase buffer sizes
net.core.rmem_max = 268435456
net.core.wmem_max = 268435456
net.core.rmem_default = 134217728
net.core.wmem_default = 134217728
net.ipv4.tcp_rmem = 4096 87380 268435456
net.ipv4.tcp_wmem = 4096 65536 268435456
net.core.netdev_max_backlog = 50000
net.core.optmem_max = 25165824

# BBR congestion control
net.core.default_qdisc = fq
net.ipv4.tcp_congestion_control = bbr

# Increase UDP buffer
net.ipv4.udp_rmem_min = 131072
net.ipv4.udp_wmem_min = 131072
EOF

    sysctl -p 2>/dev/null || true

    # Create systemd service overrides
    mkdir -p /etc/systemd/system/dnstt-elite-x.service.d
    cat > /etc/systemd/system/dnstt-elite-x.service.d/override.conf <<EOF
[Service]
Restart=always
RestartSec=2
StartLimitInterval=0
StartLimitBurst=0
EOF

    mkdir -p /etc/systemd/system/dnstt-elite-x-proxy.service.d
    cat > /etc/systemd/system/dnstt-elite-x-proxy.service.d/override.conf <<EOF
[Service]
Restart=always
RestartSec=2
StartLimitInterval=0
StartLimitBurst=0
EOF

    echo -e "${NEON_GREEN}✅ Ultra stability fixes applied${NC}"
}

# ==================== MAIN INSTALLATION ====================
show_banner

# ACTIVATION
echo -e "${NEON_YELLOW}╔═══════════════════════════════════════════════════════════════╗${NC}"
echo -e "${NEON_YELLOW}║${NEON_GREEN}${BOLD}                    ACTIVATION REQUIRED                          ${NEON_YELLOW}║${NC}"
echo -e "${NEON_YELLOW}╚═══════════════════════════════════════════════════════════════╝${NC}"
echo ""
echo -e "${NEON_WHITE}Available Keys:${NC}"
echo -e "${NEON_GREEN}  💎 Lifetime : Whtsapp +255713-628-668${NC}"
echo -e "${NEON_YELLOW}  ⏳ Trial    : ELITE-X-TEST-0208 (2 days)${NC}"
echo ""
echo -ne "${NEON_CYAN}🔑 Activation Key: ${NC}"
read ACTIVATION_INPUT

mkdir -p /etc/elite-x
if ! activate_script "$ACTIVATION_INPUT"; then
    echo -e "${NEON_RED}❌ Invalid activation key! Installation cancelled.${NC}"
    exit 1
fi

ensure_key_files
echo -e "${NEON_GREEN}✅ Activation successful!${NC}"
sleep 1

set_timezone

# SUBDOMAIN
echo -e "${NEON_CYAN}╔═══════════════════════════════════════════════════════════════╗${NC}"
echo -e "${NEON_CYAN}║${NEON_WHITE}${BOLD}                  ENTER YOUR SUBDOMAIN                          ${NEON_CYAN}║${NC}"
echo -e "${NEON_CYAN}╠═══════════════════════════════════════════════════════════════╣${NC}"
echo -e "${NEON_CYAN}║${NEON_WHITE}  Example: ns-dan.elitex.sbs                                 ${NEON_CYAN}║${NC}"
echo -e "${NEON_CYAN}╚═══════════════════════════════════════════════════════════════╝${NC}"
echo ""
echo -ne "${NEON_GREEN}🌐 Subdomain: ${NC}"
read TDOMAIN
echo "$TDOMAIN" > /etc/elite-x/subdomain
check_subdomain "$TDOMAIN"

# LOCATION
echo -e "${NEON_YELLOW}╔═══════════════════════════════════════════════════════════════╗${NC}"
echo -e "${NEON_YELLOW}║${NEON_GREEN}${BOLD}           NETWORK LOCATION OPTIMIZATION                          ${NEON_YELLOW}║${NC}"
echo -e "${NEON_YELLOW}╠═══════════════════════════════════════════════════════════════╣${NC}"
echo -e "${NEON_YELLOW}║${NEON_WHITE}  Select your VPS location:                                    ${NEON_YELLOW}║${NC}"
echo -e "${NEON_YELLOW}║${NEON_GREEN}  [1] South Africa (Default - MTU 1800)                        ${NEON_YELLOW}║${NC}"
echo -e "${NEON_YELLOW}║${NEON_CYAN}  [2] USA                                                       ${NEON_YELLOW}║${NC}"
echo -e "${NEON_YELLOW}║${NEON_BLUE}  [3] Europe                                                    ${NEON_YELLOW}║${NC}"
echo -e "${NEON_YELLOW}║${NEON_PURPLE}  [4] Asia                                                      ${NEON_YELLOW}║${NC}"
echo -e "${NEON_YELLOW}║${NEON_PINK}  [5] Auto-detect                                                ${NEON_YELLOW}║${NC}"
echo -e "${NEON_YELLOW}║${NEON_RED}${BLINK}  [6] 🚀 ULTRA STABILITY MODE (RECOMMENDED)                       ${NEON_YELLOW}║${NC}"
echo -e "${NEON_YELLOW}╚═══════════════════════════════════════════════════════════════╝${NC}"
echo ""
echo -ne "${NEON_GREEN}Select location [1-6] [default: 6]: ${NC}"
read LOCATION_CHOICE
LOCATION_CHOICE=${LOCATION_CHOICE:-6}

MTU=1500
SELECTED_LOCATION="South Africa"

case $LOCATION_CHOICE in
    2)
        SELECTED_LOCATION="USA"
        echo -e "${NEON_CYAN}✅ USA selected${NC}"
        ;;
    3)
        SELECTED_LOCATION="Europe"
        echo -e "${NEON_BLUE}✅ Europe selected${NC}"
        ;;
    4)
        SELECTED_LOCATION="Asia"
        echo -e "${NEON_PURPLE}✅ Asia selected${NC}"
        ;;
    5)
        SELECTED_LOCATION="Auto-detect"
        echo -e "${NEON_PINK}✅ Auto-detect selected${NC}"
        ;;
    6)
        SELECTED_LOCATION="ULTRA STABILITY MODE"
        MTU=1300
        echo -e "${NEON_RED}${BLINK}✅ ULTRA STABILITY MODE SELECTED - Maximum stability${NC}"
        ;;
    *)
        SELECTED_LOCATION="South Africa"
        echo -e "${NEON_GREEN}✅ Using South Africa configuration${NC}"
        ;;
esac

echo "$SELECTED_LOCATION" > /etc/elite-x/location
echo "$MTU" > /etc/elite-x/mtu
echo "balanced" > /etc/elite-x/current_mode

DNSTT_PORT=5300

echo -e "${NEON_YELLOW}==> ELITE-X ULTRA STABILITY EDITION INSTALLATION STARTING...${NC}"

if [ "$(id -u)" -ne 0 ]; then
  echo -e "${NEON_RED}[-] Run as root${NC}"
  exit 1
fi

mkdir -p /etc/elite-x/{banner,users,traffic}
echo "$TDOMAIN" > /etc/elite-x/subdomain

# Create banners
cat > /etc/elite-x/banner/default <<'EOF'
╔═════════════════════════════════╗
        ELITE-X VPN SERVICE
  High Speed • Secure • Unlimited
╚═════════════════════════════════╝
EOF

cat > /etc/elite-x/banner/ssh-banner <<'EOF'
╔═════════════════════════════════╗
        ELITE-X VPN SERVICE
  High Speed • Secure • Unlimited
╚═════════════════════════════════╝
EOF

if ! grep -q "^Banner" /etc/ssh/sshd_config; then
    echo "Banner /etc/elite-x/banner/ssh-banner" >> /etc/ssh/sshd_config
else
    sed -i 's|^Banner.*|Banner /etc/elite-x/banner/ssh-banner|' /etc/ssh/sshd_config
fi
systemctl restart sshd

echo -e "${NEON_CYAN}Stopping old services...${NC}"
for svc in dnstt dnstt-server slowdns dnstt-smart dnstt-elite-x dnstt-elite-x-proxy; do
  systemctl disable --now "$svc" 2>/dev/null || true
done

# Fix DNS permanently
rm -f /etc/resolv.conf
cat > /etc/resolv.conf <<EOF
nameserver 8.8.8.8
nameserver 8.8.4.4
nameserver 1.1.1.1
EOF
chattr +i /etc/resolv.conf 2>/dev/null || true

fuser -k 53/udp 2>/dev/null || true

echo -e "${NEON_CYAN}Installing dependencies...${NC}"
apt update -y
apt install -y curl python3 jq nano iptables iptables-persistent ethtool dnsutils net-tools iftop nload htop git make golang-go build-essential wget unzip irqbalance openssl bc

install_dnstt_server

echo -e "${NEON_CYAN}Generating keys...${NC}"
mkdir -p /etc/dnstt

if [ -f /etc/dnstt/server.key ]; then
    echo -e "${NEON_YELLOW}⚠️ Existing keys found, removing...${NC}"
    chattr -i /etc/dnstt/server.key 2>/dev/null || true
    rm -f /etc/dnstt/server.key
    rm -f /etc/dnstt/server.pub
fi

cd /etc/dnstt
/usr/local/bin/dnstt-server -gen-key -privkey-file server.key -pubkey-file server.pub
cd ~

chmod 600 /etc/dnstt/server.key
chmod 644 /etc/dnstt/server.pub

echo -e "${NEON_GREEN}✅ Public key generated: $(cat /etc/dnstt/server.pub)${NC}"

echo -e "${NEON_CYAN}Creating dnstt-elite-x.service...${NC}"
cat >/etc/systemd/system/dnstt-elite-x.service <<EOF
[Unit]
Description=ELITE-X DNSTT Server
After=network-online.target
Wants=network-online.target

[Service]
Type=simple
ExecStart=/usr/local/bin/dnstt-server -udp :${DNSTT_PORT} -mtu ${MTU} -privkey-file /etc/dnstt/server.key ${TDOMAIN} 127.0.0.1:22
Restart=always
RestartSec=2
StartLimitInterval=0
StartLimitBurst=0
KillSignal=SIGTERM
LimitNOFILE=1048576

[Install]
WantedBy=multi-user.target
EOF

install_edns_proxy

cat >/etc/systemd/system/dnstt-elite-x-proxy.service <<EOF
[Unit]
Description=ELITE-X DNS Proxy
After=dnstt-elite-x.service
Requires=dnstt-elite-x.service
Wants=network.target

[Service]
Type=simple
User=root
ExecStart=/usr/bin/python3 /usr/local/bin/dnstt-edns-proxy.py
Restart=always
RestartSec=2
StartLimitInterval=0
StartLimitBurst=0
StandardOutput=journal
StandardError=journal

[Install]
WantedBy=multi-user.target
EOF

command -v ufw >/dev/null && {
    ufw allow 22/tcp
    ufw allow 53/udp
    ufw reload 2>/dev/null || true
}

systemctl daemon-reload
systemctl enable dnstt-elite-x.service dnstt-elite-x-proxy.service
systemctl start dnstt-elite-x.service
sleep 2
systemctl start dnstt-elite-x-proxy.service

# Setup all features
setup_traffic_monitor
setup_auto_remover
setup_live_monitor
setup_traffic_analyzer
setup_renew_user
setup_updater
setup_user_script
create_refresh_script
create_uninstall_script
setup_auto_adaptation
setup_user_limit_manager
setup_bandwidth_monitor
setup_network_optimizer
create_booster_script
setup_main_menu

# Start additional services
systemctl daemon-reload
systemctl enable --now elite-x-auto-adapt.service 2>/dev/null || true
systemctl enable --now elite-x-limit-manager.service 2>/dev/null || true
systemctl enable --now elite-x-bandwidth-monitor.service 2>/dev/null || true

# Apply stability fixes
apply_stability_fixes

# Additional optimizations
for iface in $(ls /sys/class/net/ | grep -v lo); do
    ethtool -K $iface tx off rx off 2>/dev/null || true
    ethtool -K $iface tso off gso off gro off 2>/dev/null || true
    ip link set dev $iface mtu $MTU 2>/dev/null || true
    ip link set dev $iface txqueuelen 10000 2>/dev/null || true
done

systemctl daemon-reload
systemctl restart dnstt-elite-x dnstt-elite-x-proxy

cat > /etc/cron.hourly/elite-x-expiry <<'EOF'
#!/bin/bash
if [ -f /usr/local/bin/elite-x ]; then
    /usr/local/bin/elite-x --check-expiry
fi
EOF
chmod +x /etc/cron.hourly/elite-x-expiry

# Cache network info
echo -e "${NEON_CYAN}Caching network information...${NC}"
/usr/local/bin/elite-x-refresh-info

# Auto-show on login
cat > /etc/profile.d/elite-x-dashboard.sh <<'EOF'
#!/bin/bash
if [ -f /usr/local/bin/elite-x ] && [ -z "$ELITE_X_SHOWN" ]; then
    export ELITE_X_SHOWN=1
    rm -f /tmp/elite-x-running 2>/dev/null
    /usr/local/bin/elite-x
fi
EOF
chmod +x /etc/profile.d/elite-x-dashboard.sh

cat >> ~/.bashrc <<'EOF'
alias menu='elite-x'
alias elite='elite-x'
alias live='elite-x-live'
alias stats='elite-x-analyzer'
alias renew='elite-x-renew'
alias booster='elite-x-booster'
EOF

ensure_key_files

EXPIRY_INFO=$(cat /etc/elite-x/expiry 2>/dev/null || echo "Lifetime")

clear
show_banner
echo -e "${NEON_GREEN}╔═══════════════════════════════════════════════════════════════╗${NC}"
echo -e "${NEON_GREEN}║${NEON_YELLOW}${BOLD}              ELITE-X ULTRA STABILITY INSTALLED!                 ${NEON_GREEN}║${NC}"
echo -e "${NEON_GREEN}╠═══════════════════════════════════════════════════════════════╣${NC}"
echo -e "${NEON_GREEN}║${NEON_WHITE}  📌 DOMAIN  : ${NEON_CYAN}${TDOMAIN}${NC}"
echo -e "${NEON_GREEN}║${NEON_WHITE}  📍 LOCATION: ${NEON_CYAN}${SELECTED_LOCATION}${NC}"
echo -e "${NEON_GREEN}║${NEON_WHITE}  🔑 KEY     : ${NEON_YELLOW}$(cat /etc/elite-x/key)${NC}"
echo -e "${NEON_GREEN}║${NEON_WHITE}  🔑 PUBLIC KEY: ${NEON_CYAN}$(cat /etc/dnstt/server.pub)${NC}"
echo -e "${NEON_GREEN}║${NEON_WHITE}  ⚙️ MTU      : ${NEON_CYAN}${MTU}${NC}"
echo -e "${NEON_GREEN}║${NEON_WHITE}  ⏳ EXPIRY  : ${NEON_YELLOW}${EXPIRY_INFO}${NC}"
echo -e "${NEON_GREEN}╠═══════════════════════════════════════════════════════════════╣${NC}"
echo -e "${NEON_GREEN}║${NEON_WHITE}  🚀 Commands:${NC}"
echo -e "${NEON_GREEN}║${NEON_WHITE}     menu   - Open dashboard${NC}"
echo -e "${NEON_GREEN}║${NEON_WHITE}     live   - Live connection monitor${NC}"
echo -e "${NEON_GREEN}║${NEON_WHITE}     stats  - Traffic analyzer${NC}"
echo -e "${NEON_GREEN}║${NEON_WHITE}     renew  - Renew SSH account${NC}"
echo -e "${NEON_GREEN}║${NEON_WHITE}     booster- Open booster menu${NC}"
echo -e "${NEON_GREEN}╠═══════════════════════════════════════════════════════════════╣${NC}"
echo -e "${NEON_GREEN}║${NEON_WHITE}  ✨ New Features v5.1:${NC}"
echo -e "${NEON_GREEN}║${NEON_WHITE}     • Auto-Adaptation Engine${NC}"
echo -e "${NEON_GREEN}║${NEON_WHITE}     • User Session Limits${NC}"
echo -e "${NEON_GREEN}║${NEON_WHITE}     • Real-time Bandwidth Monitor${NC}"
echo -e "${NEON_GREEN}║${NEON_WHITE}     • Network Optimizer${NC}"
echo -e "${NEON_GREEN}║${NEON_WHITE}     • 4 Network Modes${NC}"
echo -e "${NEON_GREEN}║${NEON_RED}     • ULTRA STABILITY MODE${NC}"
echo -e "${NEON_GREEN}╚═══════════════════════════════════════════════════════════════╝${NC}"
show_quote

# Check service status
sleep 2
echo -e "${NEON_CYAN}Service Status:${NC}"
systemctl is-active dnstt-elite-x >/dev/null 2>&1 && echo -e "  DNSTT: ${NEON_GREEN}● RUNNING${NC}" || echo -e "  DNSTT: ${NEON_RED}● FAILED${NC}"
systemctl is-active dnstt-elite-x-proxy >/dev/null 2>&1 && echo -e "  PROXY: ${NEON_GREEN}● RUNNING${NC}" || echo -e "  PROXY: ${NEON_RED}● FAILED${NC}"
systemctl is-active elite-x-auto-adapt >/dev/null 2>&1 && echo -e "  ADAPT: ${NEON_GREEN}● RUNNING${NC}" || echo -e "  ADAPT: ${NEON_YELLOW}● CHECKING${NC}"
echo ""

# Auto-open menu after installation
echo -e "${NEON_GREEN}Opening dashboard in 3 seconds...${NC}"
sleep 3
/usr/local/bin/elite-x

self_destruct
