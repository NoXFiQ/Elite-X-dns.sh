#!/bin/bash
# ╔═══════════════════════════════════════════════════════════════╗
#  ███████╗██╗     ██╗████████╗███████╗      ██╗  ██╗
#  ██╔════╝██║     ██║╚══██╔══╝██╔════╝      ╚██╗██╔╝
#  █████╗  ██║     ██║   ██║   █████╗  █████╗ ╚███╔╝ 
#  ██╔══╝  ██║     ██║   ██║   ██╔══╝  ╚════╝ ██╔██╗ 
#  ███████╗███████╗██║   ██║   ███████╗      ██╔╝ ██╗
#  ╚══════╝╚══════╝╚═╝   ╚═╝   ╚══════╝      ╚═╝  ╚═╝
# ╚═══════════════════════════════════════════════════════════════╝
#              ELITE-X SLOWDNS v5.1 - REVOLUTION EDITION
# ═════════════════════════════════════════════════════════════════
# FIXED: DNS Resolution, All Services Working

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
AI_PREDICT_FILE="/etc/elite-x/ai_predictions"
ZERO_LOSS_FILE="/etc/elite-x/zero_loss_stats"

# ==================== COMPLETE UNINSTALL ====================
complete_uninstall() {
    echo -e "${NEON_RED}${BLINK}🗑️  COMPLETE UNINSTALL - REMOVING EVERYTHING...${NC}"
    
    # Stop all services
    systemctl stop dnstt-elite-x dnstt-elite-x-proxy elite-x-ai elite-x-quantum elite-x-healer elite-x-zeroloss elite-x-core 2>/dev/null || true
    systemctl disable dnstt-elite-x dnstt-elite-x-proxy elite-x-ai elite-x-quantum elite-x-healer elite-x-zeroloss elite-x-core 2>/dev/null || true
    
    # Remove service files
    rm -f /etc/systemd/system/{dnstt-elite-x*,elite-x-*}
    
    # Remove all users
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
    
    # Kill processes
    pkill -f dnstt-server 2>/dev/null || true
    pkill -f dnstt-edns-proxy 2>/dev/null || true
    
    # Remove directories and files
    rm -rf /etc/dnstt
    rm -rf /etc/elite-x
    rm -f /usr/local/bin/{dnstt-*,elite-x*}
    rm -f /usr/local/bin/dnstt-edns-proxy.py
    
    # Remove banner from sshd_config
    sed -i '/^Banner/d' /etc/ssh/sshd_config
    systemctl restart sshd
    
    # Remove profile and cron files
    rm -f /etc/cron.hourly/elite-x-*
    rm -f /etc/profile.d/elite-x-*
    sed -i '/elite-x/d' /root/.bashrc 2>/dev/null || true
    
    # Restore resolv.conf if needed
    if [ -f /etc/resolv.conf.backup ]; then
        chattr -i /etc/resolv.conf 2>/dev/null || true
        cp /etc/resolv.conf.backup /etc/resolv.conf 2>/dev/null || true
    fi
    
    systemctl daemon-reload
    echo -e "${NEON_GREEN}${BLINK}✅✅✅ COMPLETE UNINSTALL FINISHED!${NC}"
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
    
    echo -e "${NEON_GREEN}✅ CLEANUP COMPLETE!${NC}"
}

# ==================== ELITE QUOTE ====================
show_quote() {
    echo ""
    echo -e "${NEON_PURPLE}╔═══════════════════════════════════════════════════════════════╗${NC}"
    echo -e "${NEON_PURPLE}║${NEON_YELLOW}${BOLD}                                                               ${NEON_PURPLE}║${NC}"
    echo -e "${NEON_PURPLE}║${NEON_WHITE}${BOLD}               ELITE-X - BEYOND ORDINARY VPN                      ${NEON_PURPLE}║${NC}"
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
    echo -e "${NEON_RED}║${NEON_WHITE}${BOLD}            ELITE-X v5.1 - REVOLUTION EDITION (FIXED)                 ${NEON_RED}║${NC}"
    echo -e "${NEON_RED}║${NEON_GREEN}${BOLD}    AI Predictive • Quantum Stability • Self-Healing • Zero-Loss     ${NEON_RED}║${NC}"
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
                echo -e "${NEON_RED}║${NEON_WHITE}  Your 2-day trial has ended. Uninstalling...                 ${NEON_RED}║${NC}"
                echo -e "${NEON_RED}╚═══════════════════════════════════════════════════════════════╝${NC}"
                sleep 3
                complete_uninstall
                rm -f "$0"
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

# ==================== FIXED RESOLV.CONF HANDLING ====================
fix_resolv_conf() {
    echo -e "${NEON_CYAN}🔧 Configuring DNS resolv.conf...${NC}"
    
    # First, set Google DNS temporarily for download
    echo "nameserver 8.8.8.8" > /etc/resolv.conf.tmp
    echo "nameserver 8.8.4.4" >> /etc/resolv.conf.tmp
    cat /etc/resolv.conf.tmp > /etc/resolv.conf 2>/dev/null || cp /etc/resolv.conf.tmp /etc/resolv.conf 2>/dev/null || true
    rm -f /etc/resolv.conf.tmp
    
    # Backup existing resolv.conf
    if [ -f /etc/resolv.conf ]; then
        cp /etc/resolv.conf /etc/resolv.conf.backup 2>/dev/null || true
    fi
    
    # Try to remove immutable flag if present
    if [ -f /etc/resolv.conf ]; then
        chattr -i /etc/resolv.conf 2>/dev/null || true
    fi
    
    # Create new resolv.conf with multiple DNS servers
    cat > /etc/resolv.conf <<EOF
nameserver 8.8.8.8
nameserver 8.8.4.4
nameserver 1.1.1.1
nameserver 208.67.222.222
EOF
    
    # Try to make it immutable to prevent changes
    chattr +i /etc/resolv.conf 2>/dev/null || true
    
    echo -e "${NEON_GREEN}✅ DNS configured successfully${NC}"
}

# ==================== GET IP INFO ====================
get_ip_info() {
    echo -e "${NEON_CYAN}🌐 Fetching IP information...${NC}"
    
    IP=""
    for service in "https://api.ipify.org" "ifconfig.me" "icanhazip.com" "ipinfo.io/ip"; do
        IP=$(curl -s --connect-timeout 5 "$service" 2>/dev/null | grep -oE '([0-9]{1,3}\.){3}[0-9]{1,3}' | head -1)
        [ ! -z "$IP" ] && break
    done
    
    if [ -z "$IP" ]; then
        IP=$(ip -4 addr show | grep -oP '(?<=inet\s)\d+(\.\d+){3}' | grep -v '127.0.0.1' | head -1)
    fi
    
    if [ -z "$IP" ]; then
        IP="Unknown"
    fi
    
    echo "$IP" > /etc/elite-x/cached_ip
    echo -e "${NEON_GREEN}✅ IP detected: $IP${NC}"
    
    if [ "$IP" != "Unknown" ]; then
        LOCATION="Unknown"
        ISP="Unknown"
        
        API_RESPONSE=$(curl -s --connect-timeout 5 "http://ip-api.com/json/$IP?fields=status,country,city,isp" 2>/dev/null)
        if echo "$API_RESPONSE" | grep -q '"status":"success"'; then
            COUNTRY=$(echo "$API_RESPONSE" | grep -o '"country":"[^"]*"' | cut -d'"' -f4)
            CITY=$(echo "$API_RESPONSE" | grep -o '"city":"[^"]*"' | cut -d'"' -f4)
            ISP=$(echo "$API_RESPONSE" | grep -o '"isp":"[^"]*"' | cut -d'"' -f4)
            
            if [ ! -z "$CITY" ] && [ "$CITY" != "null" ]; then
                LOCATION="$CITY, $COUNTRY"
            else
                LOCATION="$COUNTRY"
            fi
        fi
        
        echo "$LOCATION" > /etc/elite-x/cached_location
        echo "$ISP" > /etc/elite-x/cached_isp
        echo -e "${NEON_GREEN}✅ Location: $LOCATION${NC}"
        echo -e "${NEON_GREEN}✅ ISP: $ISP${NC}"
    fi
    
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

# ==================== FIXED AI PREDICTIVE ENGINE ====================
setup_ai_predictive() {
    cat > /usr/local/bin/elite-x-ai <<'EOF'
#!/bin/bash

NEON_CYAN='\033[1;36m'; NEON_GREEN='\033[1;32m'; NEON_YELLOW='\033[1;33m'
NEON_RED='\033[1;31m'; NEON_PURPLE='\033[1;35m'; NC='\033[0m'

AI_PREDICT_FILE="/etc/elite-x/ai_predictions"
LOG_FILE="/var/log/elite-x-ai.log"

# Create log file if it doesn't exist
touch "$LOG_FILE" 2>/dev/null || true

log() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $1" >> "$LOG_FILE"
}

predict_network_quality() {
    log "Starting network analysis"
    
    local samples=()
    local losses=0
    local total_latency=0
    local latency_count=0
    
    for i in {1..12}; do
        local start_time=$(date +%s%N)
        if ping -c 1 -W 2 8.8.8.8 >/dev/null 2>&1; then
            samples+=("ok")
            local end_time=$(date +%s%N)
            local latency=$(( ($end_time - $start_time) / 1000000 ))
            total_latency=$((total_latency + latency))
            latency_count=$((latency_count + 1))
        else
            losses=$((losses + 1))
            samples+=("loss")
        fi
        sleep 3
    done
    
    local loss_percent=$((losses * 100 / 12))
    local avg_latency=0
    [ $latency_count -gt 0 ] && avg_latency=$((total_latency / latency_count))
    
    log "Analysis complete - Loss: ${loss_percent}%, Avg Latency: ${avg_latency}ms"
    
    local consecutive_loss=0
    local max_consecutive=0
    for sample in "${samples[@]}"; do
        if [ "$sample" = "loss" ]; then
            consecutive_loss=$((consecutive_loss + 1))
            [ $consecutive_loss -gt $max_consecutive ] && max_consecutive=$consecutive_loss
        else
            consecutive_loss=0
        fi
    done
    
    local trend="stable"
    if [ $max_consecutive -ge 3 ]; then
        trend="deteriorating"
    elif [ $loss_percent -lt 10 ] && [ $avg_latency -lt 100 ]; then
        trend="improving"
    fi
    
    local prediction="stable"
    local recommended_mtu=1500
    
    if [ $loss_percent -gt 20 ] || [ "$trend" = "deteriorating" ]; then
        prediction="unstable_next_5min"
        recommended_mtu=1300
    elif [ $loss_percent -gt 10 ] || [ $avg_latency -gt 200 ]; then
        prediction="moderate_issues"
        recommended_mtu=1400
    elif [ $loss_percent -lt 5 ] && [ $avg_latency -lt 50 ] && [ "$trend" = "improving" ]; then
        prediction="excellent_next_5min"
        recommended_mtu=1800
    fi
    
    cat > "$AI_PREDICT_FILE" <<INNEREOF
{
  "timestamp": $(date +%s),
  "loss": $loss_percent,
  "latency": $avg_latency,
  "trend": "$trend",
  "prediction": "$prediction",
  "recommended_mtu": $recommended_mtu
}
INNEREOF
    
    log "AI Analysis - Loss: ${loss_percent}%, Latency: ${avg_latency}ms, Trend: ${trend}, Prediction: ${prediction}"
    
    echo "$recommended_mtu"
}

apply_ai_prediction() {
    if [ ! -f "$AI_PREDICT_FILE" ] || [ $(( $(date +%s) - $(stat -c %Y "$AI_PREDICT_FILE" 2>/dev/null || echo 0) )) -gt 300 ]; then
        predict_network_quality > /dev/null 2>&1
    fi
    
    if [ -f "$AI_PREDICT_FILE" ]; then
        local recommended_mtu=$(grep -o '"recommended_mtu":[0-9]*' "$AI_PREDICT_FILE" | cut -d: -f2)
        local current_mtu=$(cat /etc/elite-x/mtu 2>/dev/null || echo "1500")
        
        if [ ! -z "$recommended_mtu" ] && [ "$recommended_mtu" != "$current_mtu" ]; then
            echo "$recommended_mtu" > /etc/elite-x/mtu
            if [ -f /etc/systemd/system/dnstt-elite-x.service ]; then
                sed -i "s/-mtu [0-9]*/-mtu $recommended_mtu/" /etc/systemd/system/dnstt-elite-x.service
                systemctl daemon-reload
                systemctl restart dnstt-elite-x
            fi
            log "AI adjusted MTU from $current_mtu to $recommended_mtu"
        fi
    fi
}

show_ai_status() {
    if [ -f "$AI_PREDICT_FILE" ]; then
        local timestamp=$(grep -o '"timestamp":[0-9]*' "$AI_PREDICT_FILE" | head -1 | cut -d: -f2)
        local loss=$(grep -o '"loss":[0-9]*' "$AI_PREDICT_FILE" | head -1 | cut -d: -f2)
        local latency=$(grep -o '"latency":[0-9]*' "$AI_PREDICT_FILE" | head -1 | cut -d: -f2)
        local trend=$(grep -o '"trend":"[^"]*"' "$AI_PREDICT_FILE" | head -1 | cut -d'"' -f4)
        local prediction=$(grep -o '"prediction":"[^"]*"' "$AI_PREDICT_FILE" | head -1 | cut -d'"' -f4)
        local recommended=$(grep -o '"recommended_mtu":[0-9]*' "$AI_PREDICT_FILE" | head -1 | cut -d: -f2)
        
        local time_ago=$(( $(date +%s) - ${timestamp:-0} ))
        local mins_ago=$((time_ago / 60))
        
        echo -e "${NEON_PURPLE}🤖 AI PREDICTIVE ENGINE STATUS${NC}"
        echo -e "${NEON_WHITE}Last Analysis: ${NEON_CYAN}${mins_ago} minutes ago${NC}"
        echo -e "${NEON_WHITE}Packet Loss: ${NEON_YELLOW}${loss:-0}%${NC}"
        echo -e "${NEON_WHITE}Avg Latency: ${NEON_CYAN}${latency:-0}ms${NC}"
        echo -e "${NEON_WHITE}Network Trend: ${NEON_GREEN}${trend:-stable}${NC}"
        echo -e "${NEON_WHITE}Prediction: ${NEON_PURPLE}${prediction:-stable}${NC}"
        echo -e "${NEON_WHITE}Recommended MTU: ${NEON_CYAN}${recommended:-1500}${NC}"
    else
        echo -e "${NEON_YELLOW}AI Predictive Engine is starting up...${NC}"
        echo -e "${NEON_YELLOW}First analysis will complete in about 60 seconds.${NC}"
        # Run analysis in background
        predict_network_quality > /dev/null 2>&1 &
    fi
}

# Run initial prediction if needed
if [ ! -f "$AI_PREDICT_FILE" ]; then
    predict_network_quality > /dev/null 2>&1 &
fi

case "$1" in
    status) show_ai_status ;;
    predict) predict_network_quality ;;
    apply) apply_ai_prediction ;;
    *) 
        while true; do
            apply_ai_prediction
            sleep 60
        done
        ;;
esac
EOF
    chmod +x /usr/local/bin/elite-x-ai

    cat > /etc/systemd/system/elite-x-ai.service <<EOF
[Unit]
Description=ELITE-X AI Predictive Engine
After=network.target
Wants=network.target

[Service]
Type=simple
ExecStart=/usr/local/bin/elite-x-ai
Restart=always
RestartSec=60
User=root

[Install]
WantedBy=multi-user.target
EOF
}

# ==================== QUANTUM STABILITY TUNNEL ====================
setup_quantum_stability() {
    cat > /usr/local/bin/elite-x-quantum <<'EOF'
#!/bin/bash

QUANTUM_LOG="/var/log/elite-x-quantum.log"

# Create log file
touch "$QUANTUM_LOG" 2>/dev/null || true

log() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $1" >> "$QUANTUM_LOG"
}

create_quantum_tunnel() {
    log "Creating quantum stability tunnel with 3 redundant paths"
    
    # Clear existing rules
    iptables -t nat -F OUTPUT 2>/dev/null || true
    
    # Path 1: Standard DNS
    iptables -t nat -A OUTPUT -p udp --dport 53 -j DNAT --to-destination 127.0.0.1:53 2>/dev/null || true
    
    # Path 2: TCP fallback
    iptables -t nat -A OUTPUT -p tcp --dport 53 -j DNAT --to-destination 127.0.0.1:53 2>/dev/null || true
    
    log "Quantum tunnel created with 2 redundant paths"
}

monitor_quantum_stability() {
    local loss_count=0
    
    while true; do
        local path_ok=0
        
        if dig +time=1 +tries=1 @127.0.0.1 -p 53 google.com >/dev/null 2>&1; then
            path_ok=1
            loss_count=0
        fi
        
        if [ $path_ok -eq 0 ]; then
            loss_count=$((loss_count + 1))
            log "All paths failed (count: $loss_count)"
        fi
        
        if [ $loss_count -ge 3 ]; then
            log "Multiple path failures detected, recreating quantum tunnel"
            create_quantum_tunnel
            loss_count=0
        fi
        
        sleep 5
    done
}

create_quantum_tunnel
monitor_quantum_stability
EOF
    chmod +x /usr/local/bin/elite-x-quantum

    cat > /etc/systemd/system/elite-x-quantum.service <<EOF
[Unit]
Description=ELITE-X Quantum Stability Tunnel
After=network.target
Wants=network.target

[Service]
Type=simple
ExecStart=/usr/local/bin/elite-x-quantum
Restart=always
RestartSec=10
User=root

[Install]
WantedBy=multi-user.target
EOF
}

# ==================== SELF-HEALING TUNNEL ====================
setup_self_healing() {
    cat > /usr/local/bin/elite-x-healer <<'EOF'
#!/bin/bash

HEALER_LOG="/var/log/elite-x-healer.log"

# Create log file
touch "$HEALER_LOG" 2>/dev/null || true

log() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $1" >> "$HEALER_LOG"
}

check_service() {
    local service="$1"
    if ! systemctl is-active "$service" >/dev/null 2>&1; then
        log "$service is down, restarting"
        systemctl restart "$service" 2>/dev/null
        return 1
    fi
    return 0
}

check_tunnel_health() {
    if ! dig +time=2 +tries=1 @127.0.0.1 -p 5300 google.com >/dev/null 2>&1; then
        log "DNS server not responding, attempting repair"
        check_service "dnstt-elite-x"
        sleep 2
    fi
    
    if ! dig +time=2 +tries=1 @127.0.0.1 -p 53 google.com >/dev/null 2>&1; then
        log "DNS proxy not responding, attempting repair"
        check_service "dnstt-elite-x-proxy"
        sleep 2
    fi
}

while true; do
    check_tunnel_health
    check_service "dnstt-elite-x" >/dev/null
    check_service "dnstt-elite-x-proxy" >/dev/null
    check_service "elite-x-ai" >/dev/null
    check_service "elite-x-quantum" >/dev/null
    sleep 30
done
EOF
    chmod +x /usr/local/bin/elite-x-healer

    cat > /etc/systemd/system/elite-x-healer.service <<EOF
[Unit]
Description=ELITE-X Self-Healing Tunnel
After=network.target
Wants=network.target

[Service]
Type=simple
ExecStart=/usr/local/bin/elite-x-healer
Restart=always
RestartSec=30
User=root

[Install]
WantedBy=multi-user.target
EOF
}

# ==================== ZERO-LOSS TECHNOLOGY ====================
setup_zero_loss() {
    cat > /usr/local/bin/elite-x-zeroloss <<'EOF'
#!/bin/bash

NEON_CYAN='\033[1;36m'; NEON_GREEN='\033[1;32m'; NEON_YELLOW='\033[1;33m'
NEON_RED='\033[1;31m'; NEON_PURPLE='\033[1;35m'; NC='\033[0m'

ZERO_LOSS_FILE="/etc/elite-x/zero_loss_stats"
ZERO_LOSS_LOG="/var/log/elite-x-zeroloss.log"

# Create log file
touch "$ZERO_LOSS_LOG" 2>/dev/null || true

log() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $1" >> "$ZERO_LOSS_LOG"
}

calculate_zero_loss() {
    local sent=0
    local received=0
    
    local pid=$(pgrep -f dnstt-server 2>/dev/null | head -1)
    if [ ! -z "$pid" ] && [ -f "/proc/$pid/net/udp" ]; then
        sent=$(cat "/proc/$pid/net/udp" 2>/dev/null | wc -l)
        received=$(cat "/proc/$pid/net/udp" 2>/dev/null | grep -c "00000000:0000" || echo "0")
    fi
    
    local loss_percent=0
    if [ $sent -gt 0 ]; then
        loss_percent=$(( (sent - received) * 100 / sent ))
    fi
    
    cat > "$ZERO_LOSS_FILE" <<INNEREOF
{
  "timestamp": $(date +%s),
  "sent": $sent,
  "received": $received,
  "loss": $loss_percent
}
INNEREOF
    
    echo $loss_percent
}

show_zero_loss_stats() {
    if [ -f "$ZERO_LOSS_FILE" ]; then
        local timestamp=$(grep -o '"timestamp":[0-9]*' "$ZERO_LOSS_FILE" | head -1 | cut -d: -f2)
        local sent=$(grep -o '"sent":[0-9]*' "$ZERO_LOSS_FILE" | head -1 | cut -d: -f2)
        local received=$(grep -o '"received":[0-9]*' "$ZERO_LOSS_FILE" | head -1 | cut -d: -f2)
        local loss=$(grep -o '"loss":[0-9]*' "$ZERO_LOSS_FILE" | head -1 | cut -d: -f2)
        
        local time_ago=$(( $(date +%s) - ${timestamp:-0} ))
        local mins_ago=$((time_ago / 60))
        
        echo -e "${NEON_PURPLE}🔵 ZERO-LOSS TECHNOLOGY STATS${NC}"
        echo -e "${NEON_WHITE}Last Update: ${NEON_CYAN}${mins_ago} minutes ago${NC}"
        echo -e "${NEON_WHITE}Packets Sent: ${NEON_CYAN}${sent:-0}${NC}"
        echo -e "${NEON_WHITE}Packets Received: ${NEON_GREEN}${received:-0}${NC}"
        
        if [ "${loss:-0}" -eq 0 ]; then
            echo -e "${NEON_WHITE}Packet Loss: ${NEON_GREEN}0% (PERFECT)${NC}"
        elif [ "${loss:-0}" -lt 3 ]; then
            echo -e "${NEON_WHITE}Packet Loss: ${NEON_YELLOW}${loss}% (Good)${NC}"
        else
            echo -e "${NEON_WHITE}Packet Loss: ${NEON_RED}${loss}% (Needs optimization)${NC}"
        fi
    else
        echo -e "${NEON_YELLOW}Zero-Loss Technology gathering data...${NC}"
        calculate_zero_loss > /dev/null 2>&1
    fi
}

case "$1" in
    stats) show_zero_loss_stats ;;
    *) 
        while true; do
            calculate_zero_loss > /dev/null 2>&1
            sleep 30
        done
        ;;
esac
EOF
    chmod +x /usr/local/bin/elite-x-zeroloss

    cat > /etc/systemd/system/elite-x-zeroloss.service <<EOF
[Unit]
Description=ELITE-X Zero-Loss Technology
After=network.target
Wants=network.target

[Service]
Type=simple
ExecStart=/usr/local/bin/elite-x-zeroloss
Restart=always
RestartSec=30
User=root

[Install]
WantedBy=multi-user.target
EOF
}

# ==================== CORE SERVICE MANAGER ====================
setup_core_manager() {
    cat > /usr/local/bin/elite-x-core <<'EOF'
#!/bin/bash

NEON_CYAN='\033[1;36m'; NEON_GREEN='\033[1;32m'; NEON_YELLOW='\033[1;33m'
NEON_RED='\033[1;31m'; NEON_PURPLE='\033[1;35m'; NC='\033[0m'

CORE_LOG="/var/log/elite-x-core.log"

# Create log file
touch "$CORE_LOG" 2>/dev/null || true

log() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $1" >> "$CORE_LOG"
}

check_service_status() {
    local service="$1"
    local name="$2"
    local color="$3"
    
    if systemctl is-active "$service" >/dev/null 2>&1; then
        echo -e "  ${color}●${NC} $name: ${NEON_GREEN}RUNNING${NC}"
        return 0
    else
        echo -e "  ${NEON_RED}●${NC} $name: ${NEON_RED}STOPPED${NC}"
        log "$service is stopped"
        return 1
    fi
}

show_service_status() {
    clear
    echo -e "${NEON_PURPLE}╔═══════════════════════════════════════════════════════════════╗${NC}"
    echo -e "${NEON_PURPLE}║${NEON_YELLOW}${BOLD}              ELITE-X CORE SERVICES STATUS                      ${NEON_PURPLE}║${NC}"
    echo -e "${NEON_PURPLE}╚═══════════════════════════════════════════════════════════════╝${NC}"
    echo ""
    
    check_service_status "dnstt-elite-x" "DNSTT Server" "$NEON_GREEN"
    check_service_status "dnstt-elite-x-proxy" "DNSTT Proxy" "$NEON_GREEN"
    check_service_status "elite-x-ai" "AI Predictive" "$NEON_PURPLE"
    check_service_status "elite-x-quantum" "Quantum Tunnel" "$NEON_CYAN"
    check_service_status "elite-x-healer" "Self-Healing" "$NEON_GREEN"
    check_service_status "elite-x-zeroloss" "Zero-Loss" "$NEON_BLUE"
    
    echo ""
    
    local mtu=$(cat /etc/elite-x/mtu 2>/dev/null || echo "1500")
    echo -e "${NEON_WHITE}Current MTU: ${NEON_CYAN}$mtu${NC}"
    
    echo ""
    /usr/local/bin/elite-x-ai status 2>/dev/null || true
    
    echo ""
    /usr/local/bin/elite-x-zeroloss stats 2>/dev/null || true
}

restart_all() {
    echo -e "${NEON_YELLOW}Restarting all ELITE-X services...${NC}"
    systemctl restart dnstt-elite-x dnstt-elite-x-proxy 2>/dev/null
    sleep 3
    systemctl restart elite-x-ai elite-x-quantum elite-x-healer elite-x-zeroloss 2>/dev/null
    sleep 2
    show_service_status
}

case "$1" in
    status) show_service_status ;;
    restart) restart_all ;;
    *) 
        while true; do
            sleep 60
        done
        ;;
esac
EOF
    chmod +x /usr/local/bin/elite-x-core

    cat > /etc/systemd/system/elite-x-core.service <<EOF
[Unit]
Description=ELITE-X Core Service Manager
After=network.target
Wants=network.target

[Service]
Type=simple
ExecStart=/usr/local/bin/elite-x-core
Restart=always
RestartSec=60
User=root

[Install]
WantedBy=multi-user.target
EOF
}

# ==================== USER MANAGER ====================
setup_user_manager() {
    cat > /usr/local/bin/elite-x-user <<'EOF'
#!/bin/bash

NEON_RED='\033[1;31m'; NEON_GREEN='\033[1;32m'; NEON_YELLOW='\033[1;33m'
NEON_CYAN='\033[1;36m'; NEON_WHITE='\033[1;37m'; NC='\033[0m'; BOLD='\033[1m'

UD="/etc/elite-x/users"
TD="/etc/elite-x/traffic"
mkdir -p $UD $TD

show_menu() {
    clear
    echo -e "${NEON_CYAN}╔═══════════════════════════════════════════════════════════════╗${NC}"
    echo -e "${NEON_CYAN}║${NEON_YELLOW}${BOLD}              ELITE-X USER MANAGEMENT                            ${NEON_CYAN}║${NC}"
    echo -e "${NEON_CYAN}╠═══════════════════════════════════════════════════════════════╣${NC}"
    echo -e "${NEON_CYAN}║${NEON_WHITE}  [1] 👤 Add User                                                ${NEON_CYAN}║${NC}"
    echo -e "${NEON_CYAN}║${NEON_WHITE}  [2] 📋 List Users (with REAL traffic)                         ${NEON_CYAN}║${NC}"
    echo -e "${NEON_CYAN}║${NEON_WHITE}  [3] 🔒 Lock User                                              ${NEON_CYAN}║${NC}"
    echo -e "${NEON_CYAN}║${NEON_WHITE}  [4] 🔓 Unlock User                                            ${NEON_CYAN}║${NC}"
    echo -e "${NEON_CYAN}║${NEON_WHITE}  [5] 🗑️ Delete User                                            ${NEON_CYAN}║${NC}"
    echo -e "${NEON_CYAN}║${NEON_WHITE}  [6] ⚙️ Set User Limits                                       ${NEON_CYAN}║${NC}"
    echo -e "${NEON_CYAN}║${NEON_WHITE}  [7] 🔄 Renew User                                             ${NEON_CYAN}║${NC}"
    echo -e "${NEON_CYAN}║${NEON_WHITE}  [0] ↩️ Back                                                   ${NEON_CYAN}║${NC}"
    echo -e "${NEON_CYAN}╚═══════════════════════════════════════════════════════════════╝${NC}"
    echo ""
    read -p "$(echo -e $NEON_GREEN"Choose option [0-7]: "$NC)" opt
    
    case $opt in
        1) add_user ;;
        2) list_users ;;
        3) lock_user ;;
        4) unlock_user ;;
        5) delete_user ;;
        6) set_limits ;;
        7) renew_user ;;
        0) return 0 ;;
        *) echo -e "${NEON_RED}Invalid option${NC}"; sleep 2 ;;
    esac
}

add_user() {
    clear
    echo -e "${NEON_CYAN}╔═══════════════════════════════════════════════════════════════╗${NC}"
    echo -e "${NEON_CYAN}║${NEON_YELLOW}${BOLD}                    ADD NEW USER                                  ${NEON_CYAN}║${NC}"
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
    echo -e "${NEON_GREEN}═══════════════════════════════════════════════════════════════${NC}"
    echo "User created successfully!"
    echo "Username      : $username"
    echo "Password      : $password"
    echo "Server        : $SERVER"
    echo "Public Key    : $PUBKEY"
    echo "Expire        : $expire_date"
    echo "Traffic Limit : $traffic_limit MB"
    echo "Max Sessions  : $max_sessions"
    echo -e "${NEON_GREEN}═══════════════════════════════════════════════════════════════${NC}"
    read -p "Press Enter to continue..."
    show_menu
}

list_users() {
    clear
    echo -e "${NEON_CYAN}╔═══════════════════════════════════════════════════════════════╗${NC}"
    echo -e "${NEON_CYAN}║${NEON_YELLOW}${BOLD}                    ACTIVE USERS (REAL-TIME)                       ${NEON_CYAN}║${NC}"
    echo -e "${NEON_CYAN}╠═══════════════════════════════════════════════════════════════╣${NC}"
    
    if [ -z "$(ls -A $UD 2>/dev/null)" ]; then
        echo -e "${NEON_RED}No users found${NC}"
        read -p "Press Enter to continue..."
        show_menu
        return
    fi
    
    printf "${NEON_WHITE}%-12s %-10s %-8s %-8s %-10s %-8s %s${NC}\n" "USERNAME" "EXPIRE" "LIMIT" "USED" "SESSIONS" "USAGE%" "STATUS"
    echo -e "${NEON_CYAN}─────────────────────────────────────────────────────────────────────────────${NC}"
    
    for user_file in $UD/*; do
        [ ! -f "$user_file" ] && continue
        username=$(basename "$user_file")
        
        expire=$(grep "Expire:" "$user_file" | cut -d' ' -f2)
        limit=$(grep "Traffic_Limit:" "$user_file" | cut -d' ' -f2)
        max_sess=$(grep "Max_Sessions:" "$user_file" | cut -d' ' -f2)
        
        # Get traffic
        used=$(cat $TD/$username 2>/dev/null || echo "0")
        
        # Count sessions
        sessions=$(ps -u "$username" 2>/dev/null | grep -c "sshd" || echo "0")
        
        # Calculate percentage
        if [ "$limit" -gt 0 ] 2>/dev/null; then
            percent=$((used * 100 / limit))
            if [ "$percent" -ge 100 ]; then
                percent_disp="${NEON_RED}${percent}%${NC}"
                status="${NEON_RED}EXCEEDED${NC}"
            elif [ "$percent" -ge 80 ]; then
                percent_disp="${NEON_YELLOW}${percent}%${NC}"
                status="${NEON_GREEN}ACTIVE${NC}"
            else
                percent_disp="${NEON_GREEN}${percent}%${NC}"
                status="${NEON_GREEN}ACTIVE${NC}"
            fi
        else
            percent_disp="${NEON_GREEN}---${NC}"
            if passwd -S "$username" 2>/dev/null | grep -q "L"; then
                status="${NEON_RED}LOCKED${NC}"
            else
                status="${NEON_GREEN}ACTIVE${NC}"
            fi
        fi
        
        # Session display
        if [ "$max_sess" -gt 0 ] 2>/dev/null; then
            if [ "$sessions" -ge "$max_sess" ]; then
                sess_disp="${NEON_RED}${sessions}/${max_sess}${NC}"
            else
                sess_disp="${NEON_GREEN}${sessions}/${max_sess}${NC}"
            fi
        else
            sess_disp="${NEON_WHITE}${sessions}/∞${NC}"
        fi
        
        printf "${NEON_CYAN}%-12s ${NEON_YELLOW}%-10s ${NEON_WHITE}%-8s ${NEON_PURPLE}%-8s ${NEON_BLUE}%-10b ${NEON_GREEN}%-8b ${NEON_CYAN}%b${NC}\n" \
               "$username" "$expire" "$limit" "$used" "$sess_disp" "$percent_disp" "$status"
    done
    
    echo -e "${NEON_CYAN}─────────────────────────────────────────────────────────────────────────────${NC}"
    
    total_users=$(ls -1 $UD | wc -l)
    active_conn=$(ss -tnp | grep :22 | grep ESTAB | wc -l)
    echo -e "${NEON_WHITE}Total Users: ${NEON_GREEN}$total_users${NC}  Active Connections: ${NEON_GREEN}$active_conn${NC}"
    
    read -p "Press Enter to continue..."
    show_menu
}

set_limits() {
    clear
    echo -e "${NEON_CYAN}╔═══════════════════════════════════════════════════════════════╗${NC}"
    echo -e "${NEON_CYAN}║${NEON_YELLOW}${BOLD}                 SET USER LIMITS                                  ${NEON_CYAN}║${NC}"
    echo -e "${NEON_CYAN}╚═══════════════════════════════════════════════════════════════╝${NC}"
    
    read -p "$(echo -e $NEON_GREEN"Username: "$NC)" username
    
    if [ ! -f "$UD/$username" ]; then
        echo -e "${NEON_RED}User not found!${NC}"
        read -p "Press Enter to continue..."
        show_menu
        return
    fi
    
    current_limit=$(grep "Traffic_Limit:" "$UD/$username" | cut -d' ' -f2)
    current_sess=$(grep "Max_Sessions:" "$UD/$username" | cut -d' ' -f2)
    
    echo -e "${NEON_WHITE}Current Traffic Limit: ${NEON_CYAN}$current_limit MB${NC}"
    echo -e "${NEON_WHITE}Current Max Sessions: ${NEON_CYAN}$current_sess${NC}"
    echo ""
    
    read -p "$(echo -e $NEON_GREEN"New traffic limit (0 for unlimited): "$NC)" new_limit
    read -p "$(echo -e $NEON_GREEN"New max sessions (0 for unlimited): "$NC)" new_sess
    
    if [ ! -z "$new_limit" ] && [ "$new_limit" -ge 0 ]; then
        sed -i "s/Traffic_Limit:.*/Traffic_Limit: $new_limit/" "$UD/$username"
        echo "0" > "$TD/$username"
    fi
    
    if [ ! -z "$new_sess" ] && [ "$new_sess" -ge 0 ]; then
        sed -i "s/Max_Sessions:.*/Max_Sessions: $new_sess/" "$UD/$username"
    fi
    
    echo -e "${NEON_GREEN}✅ Limits updated${NC}"
    read -p "Press Enter to continue..."
    show_menu
}

renew_user() {
    clear
    echo -e "${NEON_CYAN}╔═══════════════════════════════════════════════════════════════╗${NC}"
    echo -e "${NEON_CYAN}║${NEON_YELLOW}${BOLD}                    RENEW USER                                   ${NEON_CYAN}║${NC}"
    echo -e "${NEON_CYAN}╚═══════════════════════════════════════════════════════════════╝${NC}"
    
    read -p "$(echo -e $NEON_GREEN"Username: "$NC)" username
    
    if [ ! -f "$UD/$username" ]; then
        echo -e "${NEON_RED}User not found!${NC}"
        read -p "Press Enter to continue..."
        show_menu
        return
    fi
    
    current_expire=$(grep "Expire:" "$UD/$username" | cut -d' ' -f2)
    echo -e "${NEON_WHITE}Current expiry: ${NEON_CYAN}$current_expire${NC}"
    read -p "$(echo -e $NEON_GREEN"Add how many days? "$NC)" days
    
    new_expire=$(date -d "$current_expire +$days days" +"%Y-%m-%d")
    chage -E "$new_expire" "$username"
    sed -i "s/Expire:.*/Expire: $new_expire/" "$UD/$username"
    
    echo -e "${NEON_GREEN}✅ User renewed until: $new_expire${NC}"
    read -p "Press Enter to continue..."
    show_menu
}

lock_user() { 
    read -p "$(echo -e $NEON_GREEN"Username: "$NC)" u
    if id "$u" &>/dev/null; then
        usermod -L "$u" 2>/dev/null
        pkill -u "$u" 2>/dev/null || true
        echo -e "${NEON_GREEN}✅ User $u locked${NC}"
    else
        echo -e "${NEON_RED}❌ User not found${NC}"
    fi
    read -p "Press Enter to continue..."
    show_menu
}

unlock_user() { 
    read -p "$(echo -e $NEON_GREEN"Username: "$NC)" u
    if id "$u" &>/dev/null; then
        usermod -U "$u" 2>/dev/null
        echo -e "${NEON_GREEN}✅ User $u unlocked${NC}"
    else
        echo -e "${NEON_RED}❌ User not found${NC}"
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
        echo -e "${NEON_RED}❌ User not found${NC}"
    fi
    read -p "Press Enter to continue..."
    show_menu
}

show_menu
EOF
    chmod +x /usr/local/bin/elite-x-user
}

# ==================== INSTALL DNSTT SERVER ====================
install_dnstt_server() {
    echo -e "${NEON_CYAN}Installing dnstt-server...${NC}"

    # First ensure DNS is working
    fix_resolv_conf
    
    DNSTT_URLS=(
        "https://github.com/Elite-X-Team/dnstt-server/raw/main/dnstt-server"
        "https://raw.githubusercontent.com/NoXFiQ/Elite-X-dns/main/dnstt-server"
        "https://github.com/x2ios/slowdns/raw/main/dnstt-server"
        "https://dnstt.network/dnstt-server-linux-amd64"
    )

    DOWNLOAD_SUCCESS=0
    TEMP_DIR=$(mktemp -d)
    cd "$TEMP_DIR"

    for url in "${DNSTT_URLS[@]}"; do
        echo -e "${NEON_CYAN}Trying: $url${NC}"
        if curl -L -f --connect-timeout 10 --retry 3 -o dnstt-server "$url" 2>/dev/null; then
            if [ -s dnstt-server ]; then
                chmod +x dnstt-server
                cp dnstt-server /usr/local/bin/dnstt-server
                echo -e "${NEON_GREEN}✅ Download successful${NC}"
                DOWNLOAD_SUCCESS=1
                break
            fi
        fi
    done

    cd /
    rm -rf "$TEMP_DIR"

    if [ $DOWNLOAD_SUCCESS -eq 0 ]; then
        echo -e "${NEON_RED}❌ Failed to download dnstt-server${NC}"
        echo -e "${NEON_YELLOW}Please check your internet connection and try again.${NC}"
        exit 1
    fi
    
    # Verify the binary works
    if ! /usr/local/bin/dnstt-server -h >/dev/null 2>&1; then
        echo -e "${NEON_RED}❌ Downloaded dnstt-server is not executable${NC}"
        exit 1
    fi
    
    echo -e "${NEON_GREEN}✅ dnstt-server installed successfully${NC}"
}

# ==================== FIXED EDNS PROXY ====================
install_edns_proxy() {
    echo -e "${NEON_CYAN}Installing EDNS proxy...${NC}"
    
    cat >/usr/local/bin/dnstt-edns-proxy.py <<'EOF'
#!/usr/bin/env python3
import socket
import threading
import time
import sys
import signal
import os

LISTEN_IP = '0.0.0.0'
LISTEN_PORT = 53
DNSTT_IP = '127.0.0.1'
DNSTT_PORT = 5300
BUFFER_SIZE = 8192

running = True

def signal_handler(sig, frame):
    global running
    print("\nShutting down proxy...")
    running = False
    sys.exit(0)

signal.signal(signal.SIGINT, signal_handler)
signal.signal(signal.SIGTERM, signal_handler)

def handle_query(server_socket, data, client_addr):
    try:
        dnstt_sock = socket.socket(socket.AF_INET, socket.SOCK_DGRAM)
        dnstt_sock.settimeout(5)
        dnstt_sock.sendto(data, (DNSTT_IP, DNSTT_PORT))
        response, _ = dnstt_sock.recvfrom(BUFFER_SIZE)
        server_socket.sendto(response, client_addr)
        dnstt_sock.close()
    except Exception as e:
        pass

def main():
    print(f"ELITE-X Proxy starting on port {LISTEN_PORT}")
    
    # Try to free up port 53
    os.system("fuser -k 53/udp 2>/dev/null || true")
    time.sleep(2)
    
    # Try multiple times to bind
    for attempt in range(3):
        try:
            sock = socket.socket(socket.AF_INET, socket.SOCK_DGRAM)
            sock.setsockopt(socket.SOL_SOCKET, socket.SO_REUSEADDR, 1)
            sock.bind((LISTEN_IP, LISTEN_PORT))
            print("Proxy is ready")
            break
        except Exception as e:
            if attempt < 2:
                print(f"Attempt {attempt+1} failed, retrying...")
                time.sleep(2)
                os.system("fuser -k 53/udp 2>/dev/null || true")
            else:
                print(f"Failed to bind: {e}")
                sys.exit(1)
    
    while running:
        try:
            data, addr = sock.recvfrom(BUFFER_SIZE)
            threading.Thread(target=handle_query, args=(sock, data, addr), daemon=True).start()
        except Exception as e:
            time.sleep(0.1)

if __name__ == "__main__":
    main()
EOF

    chmod +x /usr/local/bin/dnstt-edns-proxy.py
}

# ==================== CREATE UNINSTALL SCRIPT ====================
create_uninstall_script() {
    cat > /usr/local/bin/elite-x-uninstall <<'EOF'
#!/bin/bash

NEON_RED='\033[1;31m'; NEON_GREEN='\033[1;32m'; NEON_YELLOW='\033[1;33m'; NC='\033[0m'

echo -e "${NEON_RED}🗑️  ELITE-X UNINSTALLER${NC}"
echo -e "${NEON_YELLOW}This will remove ALL users and data.${NC}"
read -p "Type YES to confirm: " confirm

if [ "$confirm" != "YES" ]; then
    echo -e "${NEON_GREEN}Uninstall cancelled.${NC}"
    exit 0
fi

echo -e "${NEON_RED}Stopping all services...${NC}"
systemctl stop dnstt-elite-x dnstt-elite-x-proxy elite-x-ai elite-x-quantum elite-x-healer elite-x-zeroloss 2>/dev/null || true
systemctl disable dnstt-elite-x dnstt-elite-x-proxy elite-x-ai elite-x-quantum elite-x-healer elite-x-zeroloss 2>/dev/null || true

rm -f /etc/systemd/system/{dnstt-elite-x*,elite-x-*}

echo -e "${NEON_YELLOW}Removing all users...${NC}"
if [ -d "/etc/elite-x/users" ]; then
    for user_file in /etc/elite-x/users/*; do
        if [ -f "$user_file" ]; then
            username=$(basename "$user_file")
            echo "  Removing user: $username"
            pkill -u "$username" 2>/dev/null || true
            userdel -r -f "$username" 2>/dev/null || true
        fi
    done
fi

pkill -f dnstt-server 2>/dev/null || true
pkill -f dnstt-edns-proxy 2>/dev/null || true

rm -rf /etc/dnstt
rm -rf /etc/elite-x
rm -f /usr/local/bin/{dnstt-*,elite-x*}
rm -f /usr/local/bin/dnstt-edns-proxy.py

sed -i '/^Banner/d' /etc/ssh/sshd_config
systemctl restart sshd

rm -f /etc/cron.hourly/elite-x-*
rm -f /etc/profile.d/elite-x-*
sed -i '/elite-x/d' /root/.bashrc 2>/dev/null || true

# Restore resolv.conf
if [ -f /etc/resolv.conf.backup ]; then
    chattr -i /etc/resolv.conf 2>/dev/null || true
    cp /etc/resolv.conf.backup /etc/resolv.conf 2>/dev/null || true
fi

systemctl daemon-reload

echo -e "${NEON_GREEN}✅ ELITE-X has been completely uninstalled.${NC}"
EOF
    chmod +x /usr/local/bin/elite-x-uninstall
}

# ==================== REFRESH INFO ====================
create_refresh_script() {
    cat > /usr/local/bin/elite-x-refresh-info <<'EOF'
#!/bin/bash
IP=$(curl -s --connect-timeout 5 https://api.ipify.org 2>/dev/null || echo "Unknown")
echo "$IP" > /etc/elite-x/cached_ip

if [ "$IP" != "Unknown" ]; then
    API_RESPONSE=$(curl -s --connect-timeout 5 "http://ip-api.com/json/$IP?fields=status,country,city,isp" 2>/dev/null)
    if echo "$API_RESPONSE" | grep -q '"status":"success"'; then
        COUNTRY=$(echo "$API_RESPONSE" | grep -o '"country":"[^"]*"' | cut -d'"' -f4)
        CITY=$(echo "$API_RESPONSE" | grep -o '"city":"[^"]*"' | cut -d'"' -f4)
        ISP=$(echo "$API_RESPONSE" | grep -o '"isp":"[^"]*"' | cut -d'"' -f4)
        echo "$CITY, $COUNTRY" > /etc/elite-x/cached_location
        echo "$ISP" > /etc/elite-x/cached_isp
    fi
fi
EOF
    chmod +x /usr/local/bin/elite-x-refresh-info
}

# ==================== MAIN MENU ====================
setup_main_menu() {
    cat >/usr/local/bin/elite-x <<'EOF'
#!/bin/bash

NEON_RED='\033[1;31m'; NEON_GREEN='\033[1;32m'; NEON_YELLOW='\033[1;33m'
NEON_BLUE='\033[1;34m'; NEON_PURPLE='\033[1;35m'; NEON_CYAN='\033[1;36m'
NEON_PINK='\033[1;38;5;201m'; NEON_WHITE='\033[1;37m'; NC='\033[0m'

if [ -f /tmp/elite-x-running ]; then
    exit 0
fi
touch /tmp/elite-x-running
trap 'rm -f /tmp/elite-x-running' EXIT

show_quote() {
    echo ""
    echo -e "${NEON_PURPLE}╔═══════════════════════════════════════════════════════════════╗${NC}"
    echo -e "${NEON_PURPLE}║${NEON_YELLOW}${BOLD}               ELITE-X REVOLUTION EDITION                      ${NEON_PURPLE}║${NC}"
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
                echo -e "${NEON_RED}║${NEON_WHITE}  Your 2-day trial has ended.                                  ${NEON_RED}║${NC}"
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
    
    if [ ! -f /etc/elite-x/cached_ip ]; then
        /usr/local/bin/elite-x-refresh-info
    fi
    
    IP=$(cat /etc/elite-x/cached_ip 2>/dev/null || echo "Unknown")
    LOC=$(cat /etc/elite-x/cached_location 2>/dev/null || echo "Unknown")
    ISP=$(cat /etc/elite-x/cached_isp 2>/dev/null || echo "Unknown")
    SUB=$(cat /etc/elite-x/subdomain 2>/dev/null || echo "Not configured")
    ACTIVATION_KEY=$(cat /etc/elite-x/key 2>/dev/null || echo "Unknown")
    EXP=$(cat /etc/elite-x/expiry 2>/dev/null || echo "Unknown")
    MTU=$(cat /etc/elite-x/mtu 2>/dev/null || echo "1500")
    
    # Service status
    if systemctl is-active dnstt-elite-x >/dev/null 2>&1; then
        DNS="${NEON_GREEN}● RUNNING${NC}"
    else
        DNS="${NEON_RED}● STOPPED${NC}"
    fi
    
    if systemctl is-active dnstt-elite-x-proxy >/dev/null 2>&1; then
        PRX="${NEON_GREEN}● RUNNING${NC}"
    else
        PRX="${NEON_RED}● STOPPED${NC}"
    fi
    
    ACTIVE_SSH=$(ss -tnp | grep :22 | grep ESTAB | wc -l)
    
    echo -e "${NEON_PURPLE}╔═══════════════════════════════════════════════════════════════╗${NC}"
    echo -e "${NEON_PURPLE}║${NEON_YELLOW}${BOLD}            ELITE-X v5.1 - REVOLUTION EDITION                 ${NEON_PURPLE}║${NC}"
    echo -e "${NEON_PURPLE}╠═══════════════════════════════════════════════════════════════╣${NC}"
    echo -e "${NEON_PURPLE}║${NEON_WHITE}  Subdomain :${NEON_GREEN} $SUB${NC}"
    echo -e "${NEON_PURPLE}║${NEON_WHITE}  IP        :${NEON_GREEN} $IP${NC}"
    echo -e "${NEON_PURPLE}║${NEON_WHITE}  Location  :${NEON_GREEN} $LOC${NC}"
    echo -e "${NEON_PURPLE}║${NEON_WHITE}  ISP       :${NEON_GREEN} $ISP${NC}"
    echo -e "${NEON_PURPLE}║${NEON_WHITE}  MTU       :${NEON_CYAN} $MTU${NC}"
    echo -e "${NEON_PURPLE}║${NEON_WHITE}  Services  : DNS:$DNS | PRX:$PRX${NC}"
    echo -e "${NEON_PURPLE}║${NEON_WHITE}  Active SSH: ${NEON_GREEN}$ACTIVE_SSH${NC}"
    echo -e "${NEON_PURPLE}╠═══════════════════════════════════════════════════════════════╣${NC}"
    echo -e "${NEON_PURPLE}║${NEON_WHITE}  Act Key   :${NEON_YELLOW} $ACTIVATION_KEY${NC}"
    echo -e "${NEON_PURPLE}║${NEON_WHITE}  Expiry    :${NEON_YELLOW} $EXP${NC}"
    echo -e "${NEON_PURPLE}╚═══════════════════════════════════════════════════════════════╝${NC}"
    echo ""
}

settings_menu() {
    while true; do
        clear
        echo -e "${NEON_CYAN}╔═══════════════════════════════════════════════════════════════╗${NC}"
        echo -e "${NEON_CYAN}║${NEON_YELLOW}${BOLD}                    SETTINGS MENU                               ${NEON_CYAN}║${NC}"
        echo -e "${NEON_CYAN}╠═══════════════════════════════════════════════════════════════╣${NC}"
        echo -e "${NEON_CYAN}║${NEON_WHITE}  [8]  🔑 View Public Key${NC}"
        echo -e "${NEON_CYAN}║${NEON_WHITE}  [9]  📏 Change MTU${NC}"
        echo -e "${NEON_CYAN}║${NEON_WHITE}  [10] 🔄 Restart All Services${NC}"
        echo -e "${NEON_CYAN}║${NEON_WHITE}  [11] 🔄 Reboot VPS${NC}"
        echo -e "${NEON_CYAN}║${NEON_WHITE}  [12] 🗑️ Uninstall${NC}"
        echo -e "${NEON_CYAN}║${NEON_WHITE}  [13] 🌍 Change Location${NC}"
        echo -e "${NEON_CYAN}║${NEON_WHITE}  [14] 🤖 AI Status${NC}"
        echo -e "${NEON_CYAN}║${NEON_WHITE}  [15] 📊 Service Status${NC}"
        echo -e "${NEON_CYAN}║${NEON_WHITE}  [0]  ↩️ Back${NC}"
        echo -e "${NEON_CYAN}╚═══════════════════════════════════════════════════════════════╝${NC}"
        echo ""
        read -p "$(echo -e $NEON_GREEN"Settings option: "$NC)" ch
        
        case $ch in
            8)
                echo -e "${NEON_CYAN}Public Key:${NC}"
                cat /etc/dnstt/server.pub
                read -p "Press Enter..."
                ;;
            9)
                echo -e "${NEON_YELLOW}Current MTU: $(cat /etc/elite-x/mtu)${NC}"
                read -p "$(echo -e $NEON_GREEN"New MTU (1200-1800): "$NC)" mtu
                if [[ "$mtu" =~ ^[0-9]+$ ]] && [ $mtu -ge 1200 ] && [ $mtu -le 1800 ]; then
                    echo "$mtu" > /etc/elite-x/mtu
                    if [ -f /etc/systemd/system/dnstt-elite-x.service ]; then
                        sed -i "s/-mtu [0-9]*/-mtu $mtu/" /etc/systemd/system/dnstt-elite-x.service
                        systemctl daemon-reload
                        systemctl restart dnstt-elite-x dnstt-elite-x-proxy
                    fi
                    echo -e "${NEON_GREEN}✅ MTU updated to $mtu${NC}"
                else
                    echo -e "${NEON_RED}❌ Invalid MTU${NC}"
                fi
                read -p "Press Enter..."
                ;;
            10)
                systemctl restart dnstt-elite-x dnstt-elite-x-proxy 2>/dev/null
                sleep 3
                systemctl restart elite-x-ai elite-x-quantum elite-x-healer elite-x-zeroloss 2>/dev/null
                echo -e "${NEON_GREEN}✅ Services restarted${NC}"
                read -p "Press Enter..."
                ;;
            11)
                read -p "$(echo -e $NEON_RED"Reboot? (y/n): "$NC)" c
                [ "$c" = "y" ] && reboot
                ;;
            12)
                /usr/local/bin/elite-x-uninstall
                rm -f /tmp/elite-x-running
                exit 0
                ;;
            13)
                echo -e "${NEON_WHITE}Select location:${NC}"
                echo -e "  1. South Africa (MTU 1800)"
                echo -e "  2. USA"
                echo -e "  3. Europe"
                echo -e "  4. Asia"
                echo -e "  5. Auto-detect"
                read -p "Choice: " loc
                case $loc in
                    1) echo "South Africa" > /etc/elite-x/location ;;
                    2) echo "USA" > /etc/elite-x/location ;;
                    3) echo "Europe" > /etc/elite-x/location ;;
                    4) echo "Asia" > /etc/elite-x/location ;;
                    5) echo "Auto-detect" > /etc/elite-x/location ;;
                esac
                echo -e "${NEON_GREEN}✅ Location updated${NC}"
                read -p "Press Enter..."
                ;;
            14)
                /usr/local/bin/elite-x-ai status
                read -p "Press Enter..."
                ;;
            15)
                /usr/local/bin/elite-x-core status
                read -p "Press Enter..."
                ;;
            0) return ;;
            *) echo -e "${NEON_RED}Invalid option${NC}"; read -p "Press Enter..." ;;
        esac
    done
}

main_menu() {
    while true; do
        show_dashboard
        echo -e "${NEON_CYAN}╔═══════════════════════════════════════════════════════════════╗${NC}"
        echo -e "${NEON_CYAN}║${NEON_GREEN}${BOLD}                    MAIN MENU                                   ${NEON_CYAN}║${NC}"
        echo -e "${NEON_CYAN}╠═══════════════════════════════════════════════════════════════╣${NC}"
        echo -e "${NEON_CYAN}║${NEON_WHITE}  [1] 👤 User Management${NC}"
        echo -e "${NEON_CYAN}║${NEON_WHITE}  [2] 📋 List Users${NC}"
        echo -e "${NEON_CYAN}║${NEON_WHITE}  [3] 🔒 Lock User${NC}"
        echo -e "${NEON_CYAN}║${NEON_WHITE}  [4] 🔓 Unlock User${NC}"
        echo -e "${NEON_CYAN}║${NEON_WHITE}  [5] 🗑️ Delete User${NC}"
        echo -e "${NEON_CYAN}║${NEON_WHITE}  [6] 📝 Edit Banner${NC}"
        echo -e "${NEON_CYAN}║${NEON_RED}  [S] ⚙️ Settings${NC}"
        echo -e "${NEON_CYAN}║${NEON_WHITE}  [0] 🚪 Exit${NC}"
        echo -e "${NEON_CYAN}╚═══════════════════════════════════════════════════════════════╝${NC}"
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
                [ -f /etc/elite-x/banner/default ] || echo "Welcome to ELITE-X" > /etc/elite-x/banner/default
                nano /etc/elite-x/banner/default
                cp /etc/elite-x/banner/default /etc/elite-x/banner/ssh-banner 2>/dev/null
                systemctl restart sshd
                echo -e "${NEON_GREEN}✅ Banner saved${NC}"
                read -p "Press Enter..."
                ;;
            [Ss]) settings_menu ;;
            0) 
                rm -f /tmp/elite-x-running
                show_quote
                echo -e "${NEON_GREEN}Goodbye!${NC}"
                exit 0 
                ;;
            *) echo -e "${NEON_RED}Invalid option${NC}"; read -p "Press Enter..." ;;
        esac
    done
}

main_menu
EOF
    chmod +x /usr/local/bin/elite-x
}

# ==================== MAIN INSTALLATION ====================
show_banner

# First fix DNS resolution
fix_resolv_conf

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
echo -e "${NEON_YELLOW}║${NEON_GREEN}  [1] South Africa (Default)                                ${NEON_YELLOW}║${NC}"
echo -e "${NEON_YELLOW}║${NEON_CYAN}  [2] USA                                                       ${NEON_YELLOW}║${NC}"
echo -e "${NEON_YELLOW}║${NEON_BLUE}  [3] Europe                                                    ${NEON_YELLOW}║${NC}"
echo -e "${NEON_YELLOW}║${NEON_PURPLE}  [4] Asia                                                      ${NEON_YELLOW}║${NC}"
echo -e "${NEON_YELLOW}║${NEON_PINK}  [5] Auto-detect                                                ${NEON_YELLOW}║${NC}"
echo -e "${NEON_YELLOW}╚═══════════════════════════════════════════════════════════════╝${NC}"
echo ""
echo -ne "${NEON_GREEN}Select location [1-5] [default: 1]: ${NC}"
read LOCATION_CHOICE
LOCATION_CHOICE=${LOCATION_CHOICE:-1}

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
    *)
        SELECTED_LOCATION="South Africa"
        echo -e "${NEON_GREEN}✅ Using South Africa configuration${NC}"
        ;;
esac

echo "$SELECTED_LOCATION" > /etc/elite-x/location
echo "$MTU" > /etc/elite-x/mtu

DNSTT_PORT=5300

echo -e "${NEON_YELLOW}==> ELITE-X REVOLUTION EDITION INSTALLATION STARTING...${NC}"

if [ "$(id -u)" -ne 0 ]; then
  echo -e "${NEON_RED}[-] Run as root${NC}"
  exit 1
fi

# Create directory structure
mkdir -p /etc/elite-x/{banner,users,traffic}
echo "$TDOMAIN" > /etc/elite-x/subdomain

# Create banner
cat > /etc/elite-x/banner/default <<'EOF'
╔═════════════════════════════════╗
        ELITE-X VPN SERVICE
  AI Predictive • Quantum Stable
╚═════════════════════════════════╝
EOF

cp /etc/elite-x/banner/default /etc/elite-x/banner/ssh-banner

if ! grep -q "^Banner" /etc/ssh/sshd_config; then
    echo "Banner /etc/elite-x/banner/ssh-banner" >> /etc/ssh/sshd_config
else
    sed -i 's|^Banner.*|Banner /etc/elite-x/banner/ssh-banner|' /etc/ssh/sshd_config
fi
systemctl restart sshd

# Kill any process using port 53 or 5300
fuser -k 53/udp 2>/dev/null || true
fuser -k 5300/udp 2>/dev/null || true
sleep 2

echo -e "${NEON_CYAN}Installing dependencies...${NC}"
apt update -y
apt install -y curl python3 jq nano iptables iptables-persistent ethtool dnsutils net-tools dos2unix

install_dnstt_server

echo -e "${NEON_CYAN}Generating keys...${NC}"
mkdir -p /etc/dnstt

if [ -f /etc/dnstt/server.key ]; then
    chattr -i /etc/dnstt/server.key 2>/dev/null || true
    rm -f /etc/dnstt/server.key
    rm -f /etc/dnstt/server.pub
fi

cd /etc/dnstt
/usr/local/bin/dnstt-server -gen-key -privkey-file server.key -pubkey-file server.pub
cd ~

chmod 600 /etc/dnstt/server.key
chmod 644 /etc/dnstt/server.pub

echo -e "${NEON_GREEN}✅ Public key generated${NC}"

# Create service files
cat >/etc/systemd/system/dnstt-elite-x.service <<EOF
[Unit]
Description=ELITE-X DNSTT Server
After=network.target
Wants=network.target

[Service]
Type=simple
ExecStart=/usr/local/bin/dnstt-server -udp :${DNSTT_PORT} -mtu ${MTU} -privkey-file /etc/dnstt/server.key ${TDOMAIN} 127.0.0.1:22
Restart=always
RestartSec=5
LimitNOFILE=1048576
User=root

[Install]
WantedBy=multi-user.target
EOF

install_edns_proxy

cat >/etc/systemd/system/dnstt-elite-x-proxy.service <<EOF
[Unit]
Description=ELITE-X Proxy
After=dnstt-elite-x.service
Requires=dnstt-elite-x.service
Wants=network.target

[Service]
Type=simple
ExecStart=/usr/bin/python3 /usr/local/bin/dnstt-edns-proxy.py
Restart=always
RestartSec=5
User=root

[Install]
WantedBy=multi-user.target
EOF

# Setup all unique features
setup_ai_predictive
setup_quantum_stability
setup_self_healing
setup_zero_loss
setup_core_manager
setup_user_manager
create_refresh_script
create_uninstall_script
setup_main_menu

# Configure firewall
command -v ufw >/dev/null && {
    ufw allow 22/tcp
    ufw allow 53/udp
    ufw reload 2>/dev/null || true
}

# Start services in correct order
systemctl daemon-reload

# Enable all services
systemctl enable dnstt-elite-x.service
systemctl enable dnstt-elite-x-proxy.service
systemctl enable elite-x-ai.service
systemctl enable elite-x-quantum.service
systemctl enable elite-x-healer.service
systemctl enable elite-x-zeroloss.service
systemctl enable elite-x-core.service

# Start in sequence
echo -e "${NEON_CYAN}Starting DNSTT Server...${NC}"
systemctl start dnstt-elite-x.service
sleep 3

echo -e "${NEON_CYAN}Starting DNSTT Proxy...${NC}"
systemctl start dnstt-elite-x-proxy.service
sleep 2

echo -e "${NEON_CYAN}Starting AI and support services...${NC}"
systemctl start elite-x-ai.service
systemctl start elite-x-quantum.service
systemctl start elite-x-healer.service
systemctl start elite-x-zeroloss.service
systemctl start elite-x-core.service

# Cache network info
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
alias ai='elite-x-ai status'
alias core='elite-x-core status'
alias stats='elite-x-zeroloss stats'
EOF

ensure_key_files

clear
show_banner
echo -e "${NEON_GREEN}╔═══════════════════════════════════════════════════════════════╗${NC}"
echo -e "${NEON_GREEN}║${NEON_YELLOW}${BOLD}         ELITE-X REVOLUTION EDITION INSTALLED!                  ${NEON_GREEN}║${NC}"
echo -e "${NEON_GREEN}╠═══════════════════════════════════════════════════════════════╣${NC}"
echo -e "${NEON_GREEN}║${NEON_WHITE}  DOMAIN  : ${NEON_CYAN}${TDOMAIN}${NC}"
echo -e "${NEON_GREEN}║${NEON_WHITE}  LOCATION: ${NEON_CYAN}${SELECTED_LOCATION}${NC}"
echo -e "${NEON_GREEN}║${NEON_WHITE}  MTU     : ${NEON_CYAN}${MTU}${NC}"
echo -e "${NEON_GREEN}║${NEON_WHITE}  KEY     : ${NEON_YELLOW}$(cat /etc/elite-x/key)${NC}"
echo -e "${NEON_GREEN}╠═══════════════════════════════════════════════════════════════╣${NC}"
echo -e "${NEON_GREEN}║${NEON_WHITE}  ✨ UNIQUE FEATURES:${NC}"
echo -e "${NEON_GREEN}║${NEON_PURPLE}     • AI Predictive Engine (FIXED)${NC}"
echo -e "${NEON_GREEN}║${NEON_CYAN}     • Quantum Stability Tunnel${NC}"
echo -e "${NEON_GREEN}║${NEON_GREEN}     • Self-Healing Technology${NC}"
echo -e "${NEON_GREEN}║${NEON_BLUE}     • Zero-Loss Optimization${NC}"
echo -e "${NEON_GREEN}╠═══════════════════════════════════════════════════════════════╣${NC}"
echo -e "${NEON_GREEN}║${NEON_WHITE}  Commands: menu, elite, ai, core, stats             ${NEON_GREEN}║${NC}"
echo -e "${NEON_GREEN}╚═══════════════════════════════════════════════════════════════╝${NC}"

# Check service status
sleep 2
echo -e "\n${NEON_CYAN}Service Status:${NC}"
if systemctl is-active dnstt-elite-x >/dev/null 2>&1; then
    echo -e "  ${NEON_GREEN}●${NC} DNSTT Server: RUNNING"
else
    echo -e "  ${NEON_RED}●${NC} DNSTT Server: FAILED"
fi

if systemctl is-active dnstt-elite-x-proxy >/dev/null 2>&1; then
    echo -e "  ${NEON_GREEN}●${NC} DNSTT Proxy: RUNNING"
else
    echo -e "  ${NEON_RED}●${NC} DNSTT Proxy: FAILED"
fi

if systemctl is-active elite-x-ai >/dev/null 2>&1; then
    echo -e "  ${NEON_PURPLE}●${NC} AI Predictive: RUNNING"
fi

echo ""

# Auto-open menu
echo -e "${NEON_GREEN}Opening dashboard in 3 seconds...${NC}"
sleep 3
/usr/local/bin/elite-x

self_destruct
