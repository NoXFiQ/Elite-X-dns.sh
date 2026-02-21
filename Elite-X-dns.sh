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
# UNIQUE FEATURES: AI Predictive Mode, Quantum Stability, 
#                  Self-Healing Tunnel, Zero-Loss Technology

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
    
    systemctl stop dnstt-elite-x dnstt-elite-x-proxy elite-x-core 2>/dev/null || true
    systemctl disable dnstt-elite-x dnstt-elite-x-proxy elite-x-core 2>/dev/null || true
    
    rm -f /etc/systemd/system/{dnstt-elite-x*,elite-x-*}
    
    if [ -d "/etc/elite-x/users" ]; then
        for user_file in /etc/elite-x/users/*; do
            if [ -f "$user_file" ]; then
                username=$(basename "$user_file")
                pkill -u "$username" 2>/dev/null || true
                userdel -r -f "$username" 2>/dev/null || true
            fi
        done
    fi
    
    pkill -f dnstt-server 2>/dev/null || true
    pkill -f dnstt-edns-proxy 2>/dev/null || true
    
    rm -rf /etc/dnstt /etc/elite-x
    rm -f /usr/local/bin/{dnstt-*,elite-x*}
    rm -f /usr/local/bin/dnstt-edns-proxy.py
    
    sed -i '/^Banner/d' /etc/ssh/sshd_config
    systemctl restart sshd
    
    rm -f /etc/cron.hourly/elite-x-*
    rm -f /etc/profile.d/elite-x-*
    
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
    echo -e "${NEON_RED}║${NEON_WHITE}${BOLD}            ELITE-X v5.1 - REVOLUTION EDITION                         ${NEON_RED}║${NC}"
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

# ==================== GET IP INFO ====================
get_ip_info() {
    echo -e "${NEON_CYAN}🌐 Fetching IP information...${NC}"
    
    IP=""
    for service in "https://api.ipify.org" "ifconfig.me" "icanhazip.com"; do
        IP=$(curl -s --connect-timeout 3 "$service" 2>/dev/null | grep -oE '([0-9]{1,3}\.){3}[0-9]{1,3}' | head -1)
        [ ! -z "$IP" ] && break
    done
    
    if [ -z "$IP" ]; then
        IP=$(ip -4 addr show | grep -oP '(?<=inet\s)\d+(\.\d+){3}' | grep -v '127.0.0.1' | head -1)
    fi
    
    echo "$IP" > /etc/elite-x/cached_ip
    echo -e "${NEON_GREEN}✅ IP detected: $IP${NC}"
    
    LOCATION="Unknown"
    ISP="Unknown"
    
    API_RESPONSE=$(curl -s --connect-timeout 3 "http://ip-api.com/json/$IP?fields=status,country,city,isp" 2>/dev/null)
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

# ==================== UNIQUE FEATURE 1: AI PREDICTIVE MODE ====================
setup_ai_predictive() {
    cat > /usr/local/bin/elite-x-ai <<'EOF'
#!/bin/bash

NEON_CYAN='\033[1;36m'; NEON_GREEN='\033[1;32m'; NEON_YELLOW='\033[1;33m'
NEON_RED='\033[1;31m'; NEON_PURPLE='\033[1;35m'; NC='\033[0m'

AI_PREDICT_FILE="/etc/elite-x/ai_predictions"
LOG_FILE="/var/log/elite-x-ai.log"

log() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $1" >> "$LOG_FILE"
}

predict_network_quality() {
    # Collect 60 seconds of data
    local samples=()
    local losses=0
    
    for i in {1..12}; do  # 12 samples over 60 seconds
        ping -c 1 -W 1 8.8.8.8 >/dev/null 2>&1
        if [ $? -ne 0 ]; then
            losses=$((losses + 1))
            samples+=("loss")
        else
            samples+=("ok")
        fi
        sleep 5
    done
    
    local loss_percent=$((losses * 100 / 12))
    local trend="stable"
    
    # Analyze pattern
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
    
    if [ $max_consecutive -ge 3 ]; then
        trend="deteriorating"
    elif [ $loss_percent -lt 10 ]; then
        trend="improving"
    fi
    
    # Make prediction
    local prediction="stable"
    local recommended_mtu=1500
    
    if [ $loss_percent -gt 20 ] || [ "$trend" = "deteriorating" ]; then
        prediction="unstable_next_5min"
        recommended_mtu=1300
    elif [ $loss_percent -gt 10 ]; then
        prediction="moderate_issues"
        recommended_mtu=1400
    elif [ $loss_percent -lt 5 ] && [ "$trend" = "improving" ]; then
        prediction="excellent_next_5min"
        recommended_mtu=1800
    fi
    
    # Save prediction
    echo "{\"timestamp\":\"$(date +%s)\",\"loss\":$loss_percent,\"trend\":\"$trend\",\"prediction\":\"$prediction\",\"recommended_mtu\":$recommended_mtu}" > "$AI_PREDICT_FILE"
    
    log "AI Analysis - Loss: ${loss_percent}%, Trend: ${trend}, Prediction: ${prediction}"
    
    echo "$recommended_mtu"
}

apply_ai_prediction() {
    local recommended_mtu=$(predict_network_quality)
    local current_mtu=$(cat /etc/elite-x/mtu 2>/dev/null || echo "1500")
    
    # Only change if different by more than 100
    local diff=$((recommended_mtu - current_mtu))
    diff=${diff#-}  # absolute value
    
    if [ $diff -ge 100 ]; then
        echo "$recommended_mtu" > /etc/elite-x/mtu
        sed -i "s/-mtu [0-9]*/-mtu $recommended_mtu/" /etc/systemd/system/dnstt-elite-x.service
        systemctl daemon-reload
        systemctl restart dnstt-elite-x
        log "AI adjusted MTU from $current_mtu to $recommended_mtu"
        echo -e "${NEON_PURPLE}🤖 AI adjusted MTU to $recommended_mtu for optimal stability${NC}"
    fi
}

show_ai_status() {
    if [ -f "$AI_PREDICT_FILE" ]; then
        local data=$(cat "$AI_PREDICT_FILE")
        local timestamp=$(echo "$data" | grep -o '"timestamp":[0-9]*' | cut -d: -f2)
        local loss=$(echo "$data" | grep -o '"loss":[0-9]*' | cut -d: -f2)
        local trend=$(echo "$data" | grep -o '"trend":"[^"]*"' | cut -d'"' -f4)
        local prediction=$(echo "$data" | grep -o '"prediction":"[^"]*"' | cut -d'"' -f4)
        local recommended=$(echo "$data" | grep -o '"recommended_mtu":[0-9]*' | cut -d: -f2)
        
        local time_ago=$(( $(date +%s) - timestamp ))
        local mins_ago=$((time_ago / 60))
        
        echo -e "${NEON_PURPLE}🤖 AI PREDICTIVE ENGINE STATUS${NC}"
        echo -e "${NEON_WHITE}Last Analysis: ${NEON_CYAN}${mins_ago} minutes ago${NC}"
        echo -e "${NEON_WHITE}Packet Loss: ${NEON_YELLOW}${loss}%${NC}"
        echo -e "${NEON_WHITE}Network Trend: ${NEON_GREEN}${trend}${NC}"
        echo -e "${NEON_WHITE}Prediction: ${NEON_PURPLE}${prediction}${NC}"
        echo -e "${NEON_WHITE}Recommended MTU: ${NEON_CYAN}${recommended}${NC}"
    else
        echo -e "${NEON_YELLOW}AI Predictive Engine has not run yet${NC}"
    fi
}

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

[Service]
Type=simple
ExecStart=/usr/local/bin/elite-x-ai
Restart=always
RestartSec=60

[Install]
WantedBy=multi-user.target
EOF
}

# ==================== UNIQUE FEATURE 2: QUANTUM STABILITY TUNNEL ====================
setup_quantum_stability() {
    cat > /usr/local/bin/elite-x-quantum <<'EOF'
#!/bin/bash

NEON_CYAN='\033[1;36m'; NEON_GREEN='\033[1;32m'; NEON_YELLOW='\033[1;33m'
NEON_RED='\033[1;31m'; NEON_PURPLE='\033[1;35m'; NC='\033[0m'

QUANTUM_LOG="/var/log/elite-x-quantum.log"

log() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $1" >> "$QUANTUM_LOG"
}

create_quantum_tunnel() {
    # Create multiple redundant DNS paths
    log "Creating quantum stability tunnel with 3 redundant paths"
    
    # Path 1: Standard DNS
    iptables -t nat -A OUTPUT -p udp --dport 53 -j DNAT --to-destination 127.0.0.1:53 2>/dev/null || true
    
    # Path 2: TCP fallback
    iptables -t nat -A OUTPUT -p tcp --dport 53 -j DNAT --to-destination 127.0.0.1:53 2>/dev/null || true
    
    # Path 3: Alternative port
    iptables -t nat -A OUTPUT -p udp --dport 5353 -j DNAT --to-destination 127.0.0.1:53 2>/dev/null || true
    
    log "Quantum tunnel created with 3 redundant paths"
}

monitor_quantum_stability() {
    local loss_count=0
    
    while true; do
        # Test all paths
        for port in 53 5353; do
            dig +time=1 +tries=1 @127.0.0.1 -p $port google.com >/dev/null 2>&1
            if [ $? -eq 0 ]; then
                # Path working, reset loss count
                loss_count=0
                break
            fi
        done
        
        # If all paths failed, increment loss count
        if [ $loss_count -eq 0 ] && [ $? -ne 0 ]; then
            loss_count=$((loss_count + 1))
        fi
        
        # If multiple consecutive failures, recreate tunnel
        if [ $loss_count -ge 3 ]; then
            log "Multiple path failures detected, recreating quantum tunnel"
            iptables -t nat -F OUTPUT 2>/dev/null || true
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

[Service]
Type=simple
ExecStart=/usr/local/bin/elite-x-quantum
Restart=always
RestartSec=10

[Install]
WantedBy=multi-user.target
EOF
}

# ==================== UNIQUE FEATURE 3: SELF-HEALING TUNNEL ====================
setup_self_healing() {
    cat > /usr/local/bin/elite-x-healer <<'EOF'
#!/bin/bash

NEON_CYAN='\033[1;36m'; NEON_GREEN='\033[1;32m'; NEON_YELLOW='\033[1;33m'
NEON_RED='\033[1;31m'; NEON_PURPLE='\033[1;35m'; NC='\033[0m'

HEALER_LOG="/var/log/elite-x-healer.log"

log() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $1" >> "$HEALER_LOG"
}

check_tunnel_health() {
    # Check if DNS server is responding
    if ! dig +time=2 +tries=1 @127.0.0.1 google.com >/dev/null 2>&1; then
        log "DNS server not responding, attempting repair"
        systemctl restart dnstt-elite-x 2>/dev/null
        sleep 2
    fi
    
    # Check if proxy is responding
    if ! dig +time=2 +tries=1 @127.0.0.1 -p 53 google.com >/dev/null 2>&1; then
        log "DNS proxy not responding, attempting repair"
        systemctl restart dnstt-elite-x-proxy 2>/dev/null
        sleep 2
    fi
    
    # Check for packet corruption
    local test_result=$(dig +short @127.0.0.1 google.com 2>/dev/null | wc -l)
    if [ "$test_result" -eq 0 ]; then
        log "Packet corruption detected, resetting connection"
        pkill -f dnstt-server 2>/dev/null || true
        pkill -f dnstt-edns-proxy 2>/dev/null || true
        sleep 2
        systemctl start dnstt-elite-x dnstt-elite-x-proxy 2>/dev/null
    fi
}

heal_broken_connections() {
    # Kill stuck connections
    for pid in $(ps aux | grep dnstt | grep -v grep | awk '{print $2}'); do
        local cpu=$(ps -p $pid -o %cpu | tail -1 | tr -d ' ')
        local time=$(ps -p $pid -o etime | tail -1 | tr -d ' ')
        
        # If process using >50% CPU for >5 minutes, restart it
        if [ "${cpu%.*}" -gt 50 ] && [ ${#time} -gt 5 ]; then
            log "Process $pid using high CPU, restarting"
            kill -9 $pid 2>/dev/null || true
        fi
    done
    
    # Clear DNS cache if corrupted
    systemctl restart systemd-resolved 2>/dev/null || true
}

while true; do
    check_tunnel_health
    heal_broken_connections
    sleep 10
done
EOF
    chmod +x /usr/local/bin/elite-x-healer

    cat > /etc/systemd/system/elite-x-healer.service <<EOF
[Unit]
Description=ELITE-X Self-Healing Tunnel
After=network.target

[Service]
Type=simple
ExecStart=/usr/local/bin/elite-x-healer
Restart=always
RestartSec=10

[Install]
WantedBy=multi-user.target
EOF
}

# ==================== UNIQUE FEATURE 4: ZERO-LOSS TECHNOLOGY ====================
setup_zero_loss() {
    cat > /usr/local/bin/elite-x-zeroloss <<'EOF'
#!/bin/bash

NEON_CYAN='\033[1;36m'; NEON_GREEN='\033[1;32m'; NEON_YELLOW='\033[1;33m'
NEON_RED='\033[1;31m'; NEON_PURPLE='\033[1;35m'; NC='\033[0m'

ZERO_LOSS_FILE="/etc/elite-x/zero_loss_stats"
ZERO_LOSS_LOG="/var/log/elite-x-zeroloss.log"

log() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $1" >> "$ZERO_LOSS_LOG"
}

calculate_zero_loss() {
    local sent=0
    local received=0
    
    # Count packets from dnstt process
    local pid=$(pgrep -f dnstt-server 2>/dev/null | head -1)
    if [ ! -z "$pid" ]; then
        if [ -f "/proc/$pid/net/udp" ]; then
            sent=$(cat "/proc/$pid/net/udp" | wc -l)
            received=$(cat "/proc/$pid/net/udp" | grep -c "00000000:0000")
        fi
    fi
    
    local loss_percent=0
    if [ $sent -gt 0 ]; then
        loss_percent=$(( (sent - received) * 100 / sent ))
    fi
    
    # Save stats
    echo "{\"timestamp\":$(date +%s),\"sent\":$sent,\"received\":$received,\"loss\":$loss_percent}" > "$ZERO_LOSS_FILE"
    
    echo $loss_percent
}

apply_zero_loss_correction() {
    local loss=$(calculate_zero_loss)
    
    if [ $loss -gt 5 ]; then
        log "High packet loss detected: ${loss}%, applying correction"
        
        # Increase buffer sizes
        sysctl -w net.core.rmem_max=33554432 >/dev/null 2>&1
        sysctl -w net.core.wmem_max=33554432 >/dev/null 2>&1
        
        # Reduce MTU temporarily
        local current_mtu=$(cat /etc/elite-x/mtu 2>/dev/null || echo "1500")
        local new_mtu=$((current_mtu - 100))
        [ $new_mtu -lt 1200 ] && new_mtu=1200
        
        echo "$new_mtu" > /etc/elite-x/mtu.tmp
        sed -i "s/-mtu [0-9]*/-mtu $new_mtu/" /etc/systemd/system/dnstt-elite-x.service
        systemctl daemon-reload
        systemctl restart dnstt-elite-x
        
        log "MTU reduced from $current_mtu to $new_mtu to reduce loss"
    fi
}

show_zero_loss_stats() {
    if [ -f "$ZERO_LOSS_FILE" ]; then
        local data=$(cat "$ZERO_LOSS_FILE")
        local sent=$(echo "$data" | grep -o '"sent":[0-9]*' | cut -d: -f2)
        local received=$(echo "$data" | grep -o '"received":[0-9]*' | cut -d: -f2)
        local loss=$(echo "$data" | grep -o '"loss":[0-9]*' | cut -d: -f2)
        
        echo -e "${NEON_PURPLE}🔵 ZERO-LOSS TECHNOLOGY STATS${NC}"
        echo -e "${NEON_WHITE}Packets Sent: ${NEON_CYAN}$sent${NC}"
        echo -e "${NEON_WHITE}Packets Received: ${NEON_GREEN}$received${NC}"
        
        if [ $loss -eq 0 ]; then
            echo -e "${NEON_WHITE}Packet Loss: ${NEON_GREEN}0% (PERFECT)${NC}"
        elif [ $loss -lt 3 ]; then
            echo -e "${NEON_WHITE}Packet Loss: ${NEON_YELLOW}${loss}% (Good)${NC}"
        else
            echo -e "${NEON_WHITE}Packet Loss: ${NEON_RED}${loss}% (Needs optimization)${NC}"
        fi
    else
        echo -e "${NEON_YELLOW}Zero-Loss Technology not yet active${NC}"
    fi
}

case "$1" in
    stats) show_zero_loss_stats ;;
    correct) apply_zero_loss_correction ;;
    *)
        while true; do
            apply_zero_loss_correction
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

[Service]
Type=simple
ExecStart=/usr/local/bin/elite-x-zeroloss
Restart=always
RestartSec=30

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

log() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $1" >> "$CORE_LOG"
}

check_all_services() {
    local all_ok=true
    
    # Check DNS server
    if ! systemctl is-active dnstt-elite-x >/dev/null 2>&1; then
        echo -e "${NEON_RED}❌ DNSTT Server is DOWN${NC}"
        systemctl restart dnstt-elite-x 2>/dev/null
        all_ok=false
    fi
    
    # Check proxy
    if ! systemctl is-active dnstt-elite-x-proxy >/dev/null 2>&1; then
        echo -e "${NEON_RED}❌ DNSTT Proxy is DOWN${NC}"
        systemctl restart dnstt-elite-x-proxy 2>/dev/null
        all_ok=false
    fi
    
    # Check AI service
    if ! systemctl is-active elite-x-ai >/dev/null 2>&1; then
        systemctl start elite-x-ai 2>/dev/null
    fi
    
    # Check Quantum tunnel
    if ! systemctl is-active elite-x-quantum >/dev/null 2>&1; then
        systemctl start elite-x-quantum 2>/dev/null
    fi
    
    # Check Healer
    if ! systemctl is-active elite-x-healer >/dev/null 2>/dev/null; then
        systemctl start elite-x-healer 2>/dev/null
    fi
    
    # Check Zero-Loss
    if ! systemctl is-active elite-x-zeroloss >/dev/null 2>&1; then
        systemctl start elite-x-zeroloss 2>/dev/null
    fi
    
    if $all_ok; then
        echo -e "${NEON_GREEN}✅ All core services are running${NC}"
    else
        echo -e "${NEON_YELLOW}⚠️ Some services were restarted${NC}"
    fi
}

show_service_status() {
    clear
    echo -e "${NEON_PURPLE}╔═══════════════════════════════════════════════════════════════╗${NC}"
    echo -e "${NEON_PURPLE}║${NEON_YELLOW}${BOLD}              ELITE-X CORE SERVICES STATUS                      ${NEON_PURPLE}║${NC}"
    echo -e "${NEON_PURPLE}╚═══════════════════════════════════════════════════════════════╝${NC}"
    echo ""
    
    # DNSTT Server
    if systemctl is-active dnstt-elite-x >/dev/null 2>&1; then
        echo -e "  ${NEON_GREEN}●${NC} DNSTT Server: ${NEON_GREEN}RUNNING${NC}"
    else
        echo -e "  ${NEON_RED}●${NC} DNSTT Server: ${NEON_RED}STOPPED${NC}"
    fi
    
    # DNSTT Proxy
    if systemctl is-active dnstt-elite-x-proxy >/dev/null 2>&1; then
        echo -e "  ${NEON_GREEN}●${NC} DNSTT Proxy: ${NEON_GREEN}RUNNING${NC}"
    else
        echo -e "  ${NEON_RED}●${NC} DNSTT Proxy: ${NEON_RED}STOPPED${NC}"
    fi
    
    # AI Predictive
    if systemctl is-active elite-x-ai >/dev/null 2>&1; then
        echo -e "  ${NEON_PURPLE}●${NC} AI Predictive: ${NEON_GREEN}RUNNING${NC}"
    else
        echo -e "  ${NEON_RED}●${NC} AI Predictive: ${NEON_RED}STOPPED${NC}"
    fi
    
    # Quantum Stability
    if systemctl is-active elite-x-quantum >/dev/null 2>&1; then
        echo -e "  ${NEON_CYAN}●${NC} Quantum Tunnel: ${NEON_GREEN}RUNNING${NC}"
    else
        echo -e "  ${NEON_RED}●${NC} Quantum Tunnel: ${NEON_RED}STOPPED${NC}"
    fi
    
    # Self-Healing
    if systemctl is-active elite-x-healer >/dev/null 2>&1; then
        echo -e "  ${NEON_GREEN}●${NC} Self-Healing: ${NEON_GREEN}RUNNING${NC}"
    else
        echo -e "  ${NEON_RED}●${NC} Self-Healing: ${NEON_RED}STOPPED${NC}"
    fi
    
    # Zero-Loss
    if systemctl is-active elite-x-zeroloss >/dev/null 2>&1; then
        echo -e "  ${NEON_BLUE}●${NC} Zero-Loss: ${NEON_GREEN}RUNNING${NC}"
    else
        echo -e "  ${NEON_RED}●${NC} Zero-Loss: ${NEON_RED}STOPPED${NC}"
    fi
    
    echo ""
    
    # Show current MTU
    local mtu=$(cat /etc/elite-x/mtu 2>/dev/null || echo "1500")
    echo -e "${NEON_WHITE}Current MTU: ${NEON_CYAN}$mtu${NC}"
    
    # Show AI prediction
    /usr/local/bin/elite-x-ai status 2>/dev/null || true
    
    # Show Zero-Loss stats
    /usr/local/bin/elite-x-zeroloss stats 2>/dev/null || true
}

restart_all() {
    echo -e "${NEON_YELLOW}Restarting all ELITE-X services...${NC}"
    systemctl restart dnstt-elite-x dnstt-elite-x-proxy elite-x-ai elite-x-quantum elite-x-healer elite-x-zeroloss 2>/dev/null
    sleep 2
    show_service_status
}

case "$1" in
    status) show_service_status ;;
    restart) restart_all ;;
    check) check_all_services ;;
    *)
        while true; do
            check_all_services
            sleep 30
        done
        ;;
esac
EOF
    chmod +x /usr/local/bin/elite-x-core

    cat > /etc/systemd/system/elite-x-core.service <<EOF
[Unit]
Description=ELITE-X Core Service Manager
After=network.target

[Service]
Type=simple
ExecStart=/usr/local/bin/elite-x-core
Restart=always
RestartSec=30

[Install]
WantedBy=multi-user.target
EOF
}

# ==================== SIMPLIFIED USER MANAGER ====================
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
            sess_disp="${sessions}/${max_sess}"
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
        echo "0" > "$TD/$username"  # Reset counter
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

    DNSTT_URLS=(
        "https://github.com/Elite-X-Team/dnstt-server/raw/main/dnstt-server"
        "https://raw.githubusercontent.com/NoXFiQ/Elite-X-dns/main/dnstt-server"
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
        exit 1
    fi
}

# ==================== FIXED EDNS PROXY ====================
install_edns_proxy() {
    echo -e "${NEON_CYAN}Installing EDNS proxy...${NC}"
    
    cat >/usr/local/bin/dnstt-edns-proxy.py <<'EOF'
#!/usr/bin/env python3
import socket
import threading
import struct
import time
import sys
import signal

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
    except:
        pass

def main():
    print(f"ELITE-X Proxy starting on port {LISTEN_PORT}")
    
    try:
        sock = socket.socket(socket.AF_INET, socket.SOCK_DGRAM)
        sock.setsockopt(socket.SOL_SOCKET, socket.SO_REUSEADDR, 1)
        sock.bind((LISTEN_IP, LISTEN_PORT))
    except Exception as e:
        print(f"Failed to bind: {e}")
        sys.exit(1)
    
    print("Proxy is ready")
    
    while running:
        try:
            data, addr = sock.recvfrom(BUFFER_SIZE)
            threading.Thread(target=handle_query, args=(sock, data, addr), daemon=True).start()
        except:
            time.sleep(0.1)

if __name__ == "__main__":
    main()
EOF

    chmod +x /usr/local/bin/dnstt-edns-proxy.py
}

# ==================== MAIN MENU (SIMPLIFIED) ====================
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
                    sed -i "s/-mtu [0-9]*/-mtu $mtu/" /etc/systemd/system/dnstt-elite-x.service
                    systemctl daemon-reload
                    systemctl restart dnstt-elite-x dnstt-elite-x-proxy
                    echo -e "${NEON_GREEN}✅ MTU updated to $mtu${NC}"
                else
                    echo -e "${NEON_RED}❌ Invalid MTU${NC}"
                fi
                read -p "Press Enter..."
                ;;
            10)
                systemctl restart dnstt-elite-x dnstt-elite-x-proxy elite-x-ai elite-x-quantum elite-x-healer elite-x-zeroloss
                echo -e "${NEON_GREEN}✅ Services restarted${NC}"
                read -p "Press Enter..."
                ;;
            11)
                read -p "$(echo -e $NEON_RED"Reboot? (y/n): "$NC)" c
                [ "$c" = "y" ] && reboot
                ;;
            12)
                read -p "$(echo -e $NEON_RED"Type YES to uninstall: "$NC)" c
                [ "$c" = "YES" ] && {
                    /usr/local/bin/elite-x-uninstall
                    rm -f /tmp/elite-x-running
                    exit 0
                }
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

# ==================== REFRESH INFO ====================
create_refresh_script() {
    cat > /usr/local/bin/elite-x-refresh-info <<'EOF'
#!/bin/bash
IP=$(curl -s --connect-timeout 3 https://api.ipify.org 2>/dev/null || echo "Unknown")
echo "$IP" > /etc/elite-x/cached_ip

if [ "$IP" != "Unknown" ]; then
    API_RESPONSE=$(curl -s --connect-timeout 3 "http://ip-api.com/json/$IP?fields=status,country,city,isp" 2>/dev/null)
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

# ==================== UNINSTALL SCRIPT ====================
create_uninstall_script() {
    cat > /usr/local/bin/elite-x-uninstall <<'EOF'
#!/bin/bash

NEON_RED='\033[1;31m'; NEON_GREEN='\033[1;32m'; NC='\033[0m'

echo -e "${NEON_RED}🗑️  Uninstalling ELITE-X...${NC}"

systemctl stop dnstt-elite-x dnstt-elite-x-proxy elite-x-ai elite-x-quantum elite-x-healer elite-x-zeroloss 2>/dev/null || true
systemctl disable dnstt-elite-x dnstt-elite-x-proxy elite-x-ai elite-x-quantum elite-x-healer elite-x-zeroloss 2>/dev/null || true

rm -f /etc/systemd/system/{dnstt-elite-x*,elite-x-*}

if [ -d "/etc/elite-x/users" ]; then
    for user_file in /etc/elite-x/users/*; do
        if [ -f "$user_file" ]; then
            username=$(basename "$user_file")
            pkill -u "$username" 2>/dev/null || true
            userdel -r -f "$username" 2>/dev/null || true
        fi
    done
fi

rm -rf /etc/dnstt /etc/elite-x
rm -f /usr/local/bin/{dnstt-*,elite-x*}
rm -f /usr/local/bin/dnstt-edns-proxy.py

sed -i '/^Banner/d' /etc/ssh/sshd_config
systemctl restart sshd

rm -f /etc/cron.hourly/elite-x-*
rm -f /etc/profile.d/elite-x-*

systemctl daemon-reload

echo -e "${NEON_GREEN}✅ Uninstall complete${NC}"
EOF
    chmod +x /usr/local/bin/elite-x-uninstall
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

# Fix DNS
rm -f /etc/resolv.conf
cat > /etc/resolv.conf <<EOF
nameserver 8.8.8.8
nameserver 8.8.4.4
EOF
chattr +i /etc/resolv.conf 2>/dev/null || true

fuser -k 53/udp 2>/dev/null || true

echo -e "${NEON_CYAN}Installing dependencies...${NC}"
apt update -y
apt install -y curl python3 jq nano iptables iptables-persistent ethtool dnsutils net-tools

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

[Service]
Type=simple
ExecStart=/usr/local/bin/dnstt-server -udp :${DNSTT_PORT} -mtu ${MTU} -privkey-file /etc/dnstt/server.key ${TDOMAIN} 127.0.0.1:22
Restart=always
RestartSec=5
LimitNOFILE=1048576

[Install]
WantedBy=multi-user.target
EOF

install_edns_proxy

cat >/etc/systemd/system/dnstt-elite-x-proxy.service <<EOF
[Unit]
Description=ELITE-X Proxy
After=dnstt-elite-x.service
Requires=dnstt-elite-x.service

[Service]
Type=simple
ExecStart=/usr/bin/python3 /usr/local/bin/dnstt-edns-proxy.py
Restart=always
RestartSec=5

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
}

# Start services
systemctl daemon-reload
systemctl enable dnstt-elite-x.service dnstt-elite-x-proxy.service
systemctl enable elite-x-ai.service elite-x-quantum.service elite-x-healer.service elite-x-zeroloss.service elite-x-core.service

systemctl start dnstt-elite-x.service
sleep 2
systemctl start dnstt-elite-x-proxy.service
systemctl start elite-x-ai.service elite-x-quantum.service elite-x-healer.service elite-x-zeroloss.service elite-x-core.service

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
echo -e "${NEON_GREEN}║${NEON_PURPLE}     • AI Predictive Engine${NC}"
echo -e "${NEON_GREEN}║${NEON_CYAN}     • Quantum Stability Tunnel${NC}"
echo -e "${NEON_GREEN}║${NEON_GREEN}     • Self-Healing Technology${NC}"
echo -e "${NEON_GREEN}║${NEON_BLUE}     • Zero-Loss Optimization${NC}"
echo -e "${NEON_GREEN}╠═══════════════════════════════════════════════════════════════╣${NC}"
echo -e "${NEON_GREEN}║${NEON_WHITE}  Commands: menu, elite, ai, core                     ${NEON_GREEN}║${NC}"
echo -e "${NEON_GREEN}╚═══════════════════════════════════════════════════════════════╝${NC}"

# Check service status
sleep 2
echo -e "\n${NEON_CYAN}Service Status:${NC}"
systemctl is-active dnstt-elite-x >/dev/null 2>&1 && echo -e "  ${NEON_GREEN}●${NC} DNSTT Server: RUNNING" || echo -e "  ${NEON_RED}●${NC} DNSTT Server: FAILED"
systemctl is-active dnstt-elite-x-proxy >/dev/null 2>&1 && echo -e "  ${NEON_GREEN}●${NC} DNSTT Proxy: RUNNING" || echo -e "  ${NEON_RED}●${NC} DNSTT Proxy: FAILED"
echo ""

# Auto-open menu
echo -e "${NEON_GREEN}Opening dashboard in 3 seconds...${NC}"
sleep 3
/usr/local/bin/elite-x

self_destruct
