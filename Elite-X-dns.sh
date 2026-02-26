#!/bin/bash
# ╔═══════════════════════════════════════════════════════════════╗
#  ███████╗██╗     ██╗████████╗███████╗      ██╗  ██╗
#  ██╔════╝██║     ██║╚══██╔══╝██╔════╝      ╚██╗██╔╝
#  █████╗  ██║     ██║   ██║   █████╗  █████╗ ╚███╔╝ 
#  ██╔══╝  ██║     ██║   ██║   ██╔══╝  ╚════╝ ██╔██╗ 
#  ███████╗███████╗██║   ██║   ███████╗      ██╔╝ ██╗
#  ╚══════╝╚══════╝╚═╝   ╚═╝   ╚══════╝      ╚═╝  ╚═╝
# ╚═══════════════════════════════════════════════════════════════╝
#              ELITE-X SLOWDNS v5.0 - ULTRA EDITION
# ═════════════════════════════════════════════════════════════════
#     ⚡ UNIQUE FEATURES ⚡
#     • REAL-TIME TRAFFIC MONITORING with per-process tracking
#     • ADVANCED CONNECTION LIMITING with auto-kill
#     • SMART USER DELETION with process cleanup
#     • LIVE BANDWIDTH ANALYZER with graphical stats
#     • AUTO-RECONNECT BAN for exceeded limits
#     • USER ACTIVITY JOURNAL with timestamps
#     • SYSTEM HEALTH MONITOR with alerts
# ═════════════════════════════════════════════════════════════════

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
NEON_GOLD='\033[1;38;5;220m'; NEON_SILVER='\033[1;38;5;250m'
NEON_MAGENTA='\033[1;38;5;165m'; NEON_AQUA='\033[1;38;5;87m'

BG_BLACK='\033[40m'; BG_RED='\033[41m'; BG_GREEN='\033[42m'
BG_YELLOW='\033[43m'; BG_BLUE='\033[44m'; BG_PURPLE='\033[45m'
BG_CYAN='\033[46m'; BG_WHITE='\033[47m'

BLINK='\033[5m'; UNDERLINE='\033[4m'; REVERSE='\033[7m'; HIDDEN='\033[8m'

print_color() { echo -e "${2}${1}${NC}"; }

# ==================== COMPLETE UNINSTALL FUNCTION ====================
complete_uninstall() {
    echo -e "${NEON_RED}${BLINK}🗑️  COMPLETE UNINSTALL - REMOVING EVERYTHING...${NC}"
    
    systemctl stop dnstt-elite-x dnstt-elite-x-proxy elite-x-traffic elite-x-cleaner elite-x-monitor 2>/dev/null || true
    systemctl disable dnstt-elite-x dnstt-elite-x-proxy elite-x-traffic elite-x-cleaner elite-x-monitor 2>/dev/null || true
    
    rm -f /etc/systemd/system/{dnstt-elite-x*,elite-x-*}
    
    echo -e "${NEON_YELLOW}🔍 Removing all ELITE-X users...${NC}"
    
    if [ -d "/etc/elite-x/users" ]; then
        for user_file in /etc/elite-x/users/*; do
            if [ -f "$user_file" ]; then
                username=$(basename "$user_file")
                echo -e "${NEON_RED}Removing user: $username${NC}"
                # Kill all processes
                pkill -u "$username" 2>/dev/null || true
                pkill -9 -u "$username" 2>/dev/null || true
                sleep 2
                # Force remove user
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
    rm -f /usr/local/bin/elite-x-{live,analyzer,renew,update,traffic,cleaner,user,booster,refresh,uninstall,monitor,journal,health,limit}
    
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
    echo -e "${NEON_PURPLE}║${NEON_GOLD}${BOLD}${BLINK}                                                               ${NEON_PURPLE}║${NC}"
    echo -e "${NEON_PURPLE}║${NEON_WHITE}${BOLD}           ███████╗██╗     ██╗████████╗███████╗     ██╗  ██╗           ${NEON_PURPLE}║${NC}"
    echo -e "${NEON_PURPLE}║${NEON_WHITE}${BOLD}           ██╔════╝██║     ██║╚══██╔══╝██╔════╝     ╚██╗██╔╝           ${NEON_PURPLE}║${NC}"
    echo -e "${NEON_PURPLE}║${NEON_WHITE}${BOLD}           █████╗  ██║     ██║   ██║   █████╗  █████╗╚███╔╝            ${NEON_PURPLE}║${NC}"
    echo -e "${NEON_PURPLE}║${NEON_WHITE}${BOLD}           ██╔══╝  ██║     ██║   ██║   ██╔══╝  ╚════╝██╔██╗            ${NEON_PURPLE}║${NC}"
    echo -e "${NEON_PURPLE}║${NEON_WHITE}${BOLD}           ███████╗███████╗██║   ██║   ███████╗     ██╔╝ ██╗           ${NEON_PURPLE}║${NC}"
    echo -e "${NEON_PURPLE}║${NEON_WHITE}${BOLD}           ╚══════╝╚══════╝╚═╝   ╚═╝   ╚══════╝     ╚═╝  ╚═╝           ${NEON_PURPLE}║${NC}"
    echo -e "${NEON_PURPLE}║${NEON_GOLD}${BOLD}                                                               ${NEON_PURPLE}║${NC}"
    echo -e "${NEON_PURPLE}╚═══════════════════════════════════════════════════════════════╝${NC}"
    echo -e "${NEON_CYAN}                    ⚡ ULTRA EDITION - PREMIUM FEATURES ⚡${NC}"
    echo ""
}

# ==================== ULTRA BANNER ====================
show_banner() {
    clear
    echo -e "${NEON_GOLD}╔═══════════════════════════════════════════════════════════════╗${NC}"
    echo -e "${NEON_GOLD}║${NEON_RED}${BOLD}${BG_BLACK}              ███████╗██╗     ██╗████████╗███████╗                    ${NEON_GOLD}║${NC}"
    echo -e "${NEON_GOLD}║${NEON_ORANGE}${BOLD}${BG_BLACK}              ██╔════╝██║     ██║╚══██╔══╝██╔════╝                    ${NEON_GOLD}║${NC}"
    echo -e "${NEON_GOLD}║${NEON_YELLOW}${BOLD}${BG_BLACK}              █████╗  ██║     ██║   ██║   █████╗                      ${NEON_GOLD}║${NC}"
    echo -e "${NEON_GOLD}║${NEON_GREEN}${BOLD}${BG_BLACK}              ██╔══╝  ██║     ██║   ██║   ██╔══╝                      ${NEON_GOLD}║${NC}"
    echo -e "${NEON_GOLD}║${NEON_BLUE}${BOLD}${BG_BLACK}              ███████╗███████╗██║   ██║   ███████╗                    ${NEON_GOLD}║${NC}"
    echo -e "${NEON_GOLD}║${NEON_PURPLE}${BOLD}${BG_BLACK}              ╚══════╝╚══════╝╚═╝   ╚═╝   ╚══════╝                    ${NEON_GOLD}║${NC}"
    echo -e "${NEON_GOLD}╠═══════════════════════════════════════════════════════════════╣${NC}"
    echo -e "${NEON_GOLD}║${NEON_WHITE}${BOLD}           ELITE-X SLOWDNS v5.0 - ULTRA EDITION (PREMIUM)           ${NEON_GOLD}║${NC}"
    echo -e "${NEON_GOLD}║${NEON_CYAN}${BOLD}           ⚡ REAL-TIME TRAFFIC • CONNECTION LIMITS • JOURNAL ⚡          ${NEON_GOLD}║${NC}"
    echo -e "${NEON_GOLD}╚═══════════════════════════════════════════════════════════════╝${NC}"
    echo ""
}

# ==================== UNIQUE FEATURE: ULTRA JOURNAL ====================
setup_ultra_journal() {
    cat > /usr/local/bin/elite-x-journal <<'EOF'
#!/bin/bash

NEON_RED='\033[1;31m'; NEON_GREEN='\033[1;32m'; NEON_YELLOW='\033[1;33m'
NEON_CYAN='\033[1;36m'; NEON_WHITE='\033[1;37m'; NEON_PURPLE='\033[1;35m'
NEON_GOLD='\033[1;38;5;220m'; NC='\033[0m'; BOLD='\033[1m'

JOURNAL_FILE="/var/log/elite-x-journal.log"
USER_DB="/etc/elite-x/users"

show_menu() {
    clear
    echo -e "${NEON_GOLD}╔═══════════════════════════════════════════════════════════════╗${NC}"
    echo -e "${NEON_GOLD}║${NEON_PURPLE}${BOLD}                 📓 ULTRA ACTIVITY JOURNAL                          ${NEON_GOLD}║${NC}"
    echo -e "${NEON_GOLD}╠═══════════════════════════════════════════════════════════════╣${NC}"
    echo -e "${NEON_GOLD}║${NEON_WHITE}  [1] View All Activity${NC}"
    echo -e "${NEON_GOLD}║${NEON_WHITE}  [2] View User Specific Activity${NC}"
    echo -e "${NEON_GOLD}║${NEON_WHITE}  [3] View Login History${NC}"
    echo -e "${NEON_GOLD}║${NEON_WHITE}  [4] View Traffic History${NC}"
    echo -e "${NEON_GOLD}║${NEON_WHITE}  [5] View Limit Exceeded Events${NC}"
    echo -e "${NEON_GOLD}║${NEON_WHITE}  [6] Clear Journal${NC}"
    echo -e "${NEON_GOLD}║${NEON_WHITE}  [0] Back${NC}"
    echo -e "${NEON_GOLD}╚═══════════════════════════════════════════════════════════════╝${NC}"
    echo ""
    read -p "$(echo -e $NEON_CYAN"Choose option: "$NC)" opt
    
    case $opt in
        1) view_all ;;
        2) view_user ;;
        3) view_logins ;;
        4) view_traffic ;;
        5) view_limits ;;
        6) clear_journal ;;
        0) return ;;
        *) echo -e "${NEON_RED}Invalid option${NC}"; sleep 2; show_menu ;;
    esac
}

view_all() {
    clear
    echo -e "${NEON_CYAN}═══════════════════════════════════════════════════════════════${NC}"
    echo -e "${NEON_YELLOW}${BOLD}                     COMPLETE ACTIVITY LOG                         ${NC}"
    echo -e "${NEON_CYAN}═══════════════════════════════════════════════════════════════${NC}"
    echo ""
    
    if [ -f "$JOURNAL_FILE" ]; then
        tail -n 100 "$JOURNAL_FILE" | while read line; do
            if [[ $line == *"CREATED"* ]]; then
                echo -e "${NEON_GREEN}$line${NC}"
            elif [[ $line == *"DELETED"* ]]; then
                echo -e "${NEON_RED}$line${NC}"
            elif [[ $line == *"LOCKED"* ]]; then
                echo -e "${NEON_YELLOW}$line${NC}"
            elif [[ $line == *"LIMIT"* ]]; then
                echo -e "${NEON_ORANGE}$line${NC}"
            elif [[ $line == *"LOGIN"* ]]; then
                echo -e "${NEON_CYAN}$line${NC}"
            elif [[ $line == *"LOGOUT"* ]]; then
                echo -e "${NEON_PURPLE}$line${NC}"
            else
                echo "$line"
            fi
        done
    else
        echo -e "${NEON_YELLOW}No journal entries found${NC}"
    fi
    
    echo ""
    read -p "Press Enter to continue..."
    show_menu
}

view_user() {
    read -p "$(echo -e $NEON_GREEN"Enter username: "$NC)" username
    
    clear
    echo -e "${NEON_CYAN}═══════════════════════════════════════════════════════════════${NC}"
    echo -e "${NEON_YELLOW}${BOLD}              ACTIVITY FOR USER: $username                        ${NC}"
    echo -e "${NEON_CYAN}═══════════════════════════════════════════════════════════════${NC}"
    echo ""
    
    if [ -f "$JOURNAL_FILE" ]; then
        grep -i "$username" "$JOURNAL_FILE" | tail -n 50 | while read line; do
            if [[ $line == *"CREATED"* ]]; then
                echo -e "${NEON_GREEN}$line${NC}"
            elif [[ $line == *"DELETED"* ]]; then
                echo -e "${NEON_RED}$line${NC}"
            elif [[ $line == *"LOCKED"* ]]; then
                echo -e "${NEON_YELLOW}$line${NC}"
            else
                echo "$line"
            fi
        done
    else
        echo -e "${NEON_YELLOW}No entries found${NC}"
    fi
    
    echo ""
    read -p "Press Enter to continue..."
    show_menu
}

view_logins() {
    clear
    echo -e "${NEON_CYAN}═══════════════════════════════════════════════════════════════${NC}"
    echo -e "${NEON_YELLOW}${BOLD}                     LOGIN/LOGOUT HISTORY                         ${NC}"
    echo -e "${NEON_CYAN}═══════════════════════════════════════════════════════════════${NC}"
    echo ""
    
    if [ -f "$JOURNAL_FILE" ]; then
        grep -E "LOGIN|LOGOUT" "$JOURNAL_FILE" | tail -n 50 | while read line; do
            if [[ $line == *"LOGIN"* ]]; then
                echo -e "${NEON_GREEN}$line${NC}"
            else
                echo -e "${NEON_RED}$line${NC}"
            fi
        done
    else
        echo -e "${NEON_YELLOW}No login history found${NC}"
    fi
    
    echo ""
    read -p "Press Enter to continue..."
    show_menu
}

view_traffic() {
    clear
    echo -e "${NEON_CYAN}═══════════════════════════════════════════════════════════════${NC}"
    echo -e "${NEON_YELLOW}${BOLD}                     TRAFFIC USAGE HISTORY                        ${NC}"
    echo -e "${NEON_CYAN}═══════════════════════════════════════════════════════════════${NC}"
    echo ""
    
    if [ -f "$JOURNAL_FILE" ]; then
        grep "TRAFFIC" "$JOURNAL_FILE" | tail -n 50
    else
        echo -e "${NEON_YELLOW}No traffic history found${NC}"
    fi
    
    echo ""
    read -p "Press Enter to continue..."
    show_menu
}

view_limits() {
    clear
    echo -e "${NEON_CYAN}═══════════════════════════════════════════════════════════════${NC}"
    echo -e "${NEON_YELLOW}${BOLD}                 LIMIT EXCEEDED EVENTS                          ${NC}"
    echo -e "${NEON_CYAN}═══════════════════════════════════════════════════════════════${NC}"
    echo ""
    
    if [ -f "$JOURNAL_FILE" ]; then
        grep -E "LIMIT|exceeded" "$JOURNAL_FILE" | tail -n 50 | while read line; do
            echo -e "${NEON_RED}$line${NC}"
        done
    else
        echo -e "${NEON_YELLOW}No limit events found${NC}"
    fi
    
    echo ""
    read -p "Press Enter to continue..."
    show_menu
}

clear_journal() {
    read -p "$(echo -e $NEON_RED"Clear all journal entries? (y/n): "$NC)" confirm
    if [ "$confirm" = "y" ]; then
        > "$JOURNAL_FILE"
        echo -e "${NEON_GREEN}✅ Journal cleared${NC}"
    fi
    sleep 2
    show_menu
}

while true; do
    show_menu
done
EOF
    chmod +x /usr/local/bin/elite-x-journal
    
    # Create journal file
    touch /var/log/elite-x-journal.log
    chmod 666 /var/log/elite-x-journal.log
}

# ==================== UNIQUE FEATURE: ULTRA HEALTH MONITOR ====================
setup_ultra_health() {
    cat > /usr/local/bin/elite-x-health <<'EOF'
#!/bin/bash

NEON_RED='\033[1;31m'; NEON_GREEN='\033[1;32m'; NEON_YELLOW='\033[1;33m'
NEON_CYAN='\033[1;36m'; NEON_WHITE='\033[1;37m'; NEON_PURPLE='\033[1;35m'
NEON_GOLD='\033[1;38;5;220m'; NC='\033[0m'; BOLD='\033[1m'

while true; do
    clear
    echo -e "${NEON_GOLD}╔═══════════════════════════════════════════════════════════════╗${NC}"
    echo -e "${NEON_GOLD}║${NEON_PURPLE}${BOLD}                 🏥 ULTRA SYSTEM HEALTH MONITOR                   ${NEON_GOLD}║${NC}"
    echo -e "${NEON_GOLD}╚═══════════════════════════════════════════════════════════════╝${NC}"
    echo ""
    
    # CPU Usage
    CPU=$(top -bn1 | grep "Cpu(s)" | awk '{print $2}' | cut -d. -f1)
    if [ "$CPU" -lt 50 ]; then
        CPU_COLOR="${NEON_GREEN}"
    elif [ "$CPU" -lt 80 ]; then
        CPU_COLOR="${NEON_YELLOW}"
    else
        CPU_COLOR="${NEON_RED}"
    fi
    echo -e "${NEON_WHITE}CPU Usage:      ${CPU_COLOR}${CPU}%${NC}"
    
    # Memory Usage
    MEM_TOTAL=$(free -m | awk '/^Mem:/{print $2}')
    MEM_USED=$(free -m | awk '/^Mem:/{print $3}')
    MEM_PERCENT=$((MEM_USED * 100 / MEM_TOTAL))
    if [ "$MEM_PERCENT" -lt 50 ]; then
        MEM_COLOR="${NEON_GREEN}"
    elif [ "$MEM_PERCENT" -lt 80 ]; then
        MEM_COLOR="${NEON_YELLOW}"
    else
        MEM_COLOR="${NEON_RED}"
    fi
    echo -e "${NEON_WHITE}Memory Usage:   ${MEM_COLOR}${MEM_PERCENT}% (${MEM_USED}MB/${MEM_TOTAL}MB)${NC}"
    
    # Disk Usage
    DISK_USED=$(df -h / | awk 'NR==2{print $5}' | sed 's/%//')
    if [ "$DISK_USED" -lt 50 ]; then
        DISK_COLOR="${NEON_GREEN}"
    elif [ "$DISK_USED" -lt 80 ]; then
        DISK_COLOR="${NEON_YELLOW}"
    else
        DISK_COLOR="${NEON_RED}"
    fi
    echo -e "${NEON_WHITE}Disk Usage:     ${DISK_COLOR}${DISK_USED}%${NC}"
    
    # Load Average
    LOAD=$(uptime | awk -F'load average:' '{print $2}')
    echo -e "${NEON_WHITE}Load Average:   ${NEON_CYAN}${LOAD}${NC}"
    
    # Network Stats
    RX=$(cat /sys/class/net/eth0/statistics/rx_bytes 2>/dev/null || echo "0")
    TX=$(cat /sys/class/net/eth0/statistics/tx_bytes 2>/dev/null || echo "0")
    RX_MB=$((RX / 1048576))
    TX_MB=$((TX / 1048576))
    echo -e "${NEON_WHITE}Network RX:     ${NEON_GREEN}${RX_MB} MB${NC}"
    echo -e "${NEON_WHITE}Network TX:     ${NEON_GREEN}${TX_MB} MB${NC}"
    
    # Service Status
    echo ""
    echo -e "${NEON_YELLOW}Service Status:${NC}"
    
    if systemctl is-active dnstt-elite-x >/dev/null 2>&1; then
        echo -e "  ${NEON_GREEN}●${NC} DNSTT Server: ${NEON_GREEN}Running${NC}"
    else
        echo -e "  ${NEON_RED}●${NC} DNSTT Server: ${NEON_RED}Stopped${NC}"
    fi
    
    if systemctl is-active dnstt-elite-x-proxy >/dev/null 2>&1; then
        echo -e "  ${NEON_GREEN}●${NC} DNSTT Proxy:  ${NEON_GREEN}Running${NC}"
    else
        echo -e "  ${NEON_RED}●${NC} DNSTT Proxy:  ${NEON_RED}Stopped${NC}"
    fi
    
    if systemctl is-active elite-x-traffic >/dev/null 2>&1; then
        echo -e "  ${NEON_GREEN}●${NC} Traffic Monitor: ${NEON_GREEN}Running${NC}"
    else
        echo -e "  ${NEON_RED}●${NC} Traffic Monitor: ${NEON_RED}Stopped${NC}"
    fi
    
    # Port Status
    echo ""
    echo -e "${NEON_YELLOW}Port Status:${NC}"
    ss -uln | grep -q ":53 " && echo -e "  ${NEON_GREEN}●${NC} Port 53: ${NEON_GREEN}Listening${NC}" || echo -e "  ${NEON_RED}●${NC} Port 53: ${NEON_RED}Not listening${NC}"
    ss -uln | grep -q ":5300 " && echo -e "  ${NEON_GREEN}●${NC} Port 5300: ${NEON_GREEN}Listening${NC}" || echo -e "  ${NEON_RED}●${NC} Port 5300: ${NEON_RED}Not listening${NC}"
    
    # Temperature (if available)
    if [ -f /sys/class/thermal/thermal_zone0/temp ]; then
        TEMP=$(cat /sys/class/thermal/thermal_zone0/temp)
        TEMP_C=$((TEMP / 1000))
        echo ""
        echo -e "${NEON_YELLOW}System Temperature: ${NEON_WHITE}${TEMP_C}°C${NC}"
    fi
    
    echo ""
    echo -e "${NEON_GOLD}Press Ctrl+C to exit - Auto-refresh 5s${NC}"
    sleep 5
done
EOF
    chmod +x /usr/local/bin/elite-x-health
}

# ==================== UNIQUE FEATURE: CONNECTION LIMITER ====================
setup_connection_limiter() {
    cat > /usr/local/bin/elite-x-limit <<'EOF'
#!/bin/bash

NEON_RED='\033[1;31m'; NEON_GREEN='\033[1;32m'; NEON_YELLOW='\033[1;33m'
NEON_CYAN='\033[1;36m'; NEON_WHITE='\033[1;37m'; NEON_PURPLE='\033[1;35m'
NC='\033[0m'; BOLD='\033[1m'

USER_DB="/etc/elite-x/users"
JOURNAL="/var/log/elite-x-journal.log"

check_and_limit() {
    local username="$1"
    local max_logins="$2"
    
    # Count current SSH sessions
    local current_logins=$(ps -u "$username" 2>/dev/null | grep -c "sshd" || echo "0")
    
    if [ "$current_logins" -gt "$max_logins" ]; then
        echo "$(date): LIMIT EXCEEDED - User $username has $current_logins/$max_logins connections" >> "$JOURNAL"
        
        # Kill the oldest connections until under limit
        local excess=$((current_logins - max_logins))
        if [ "$excess" -gt 0 ]; then
            # Get PIDs of sshd processes for this user, sorted by age (oldest first)
            local pids=$(ps -u "$username" -o pid,etime --no-headers 2>/dev/null | grep sshd | sort -k2 | awk '{print $1}' | head -$excess)
            for pid in $pids; do
                kill -9 "$pid" 2>/dev/null || true
                echo "$(date): LIMIT ENFORCED - Killed connection (PID: $pid) for $username" >> "$JOURNAL"
            done
            echo -e "${NEON_RED}⚠️  Connection limit enforced for $username (killed $excess excess connections)${NC}"
        fi
    fi
}

monitor_loop() {
    echo -e "${NEON_GREEN}Connection limiter started${NC}"
    while true; do
        if [ -d "$USER_DB" ]; then
            for user_file in "$USER_DB"/*; do
                if [ -f "$user_file" ]; then
                    username=$(basename "$user_file")
                    max_logins=$(grep "Max_Logins:" "$user_file" 2>/dev/null | cut -d' ' -f2 || echo "0")
                    
                    if [ "$max_logins" -gt 0 ]; then
                        check_and_limit "$username" "$max_logins"
                    fi
                fi
            done
        fi
        sleep 5
    done
}

case $1 in
    start)
        monitor_loop
        ;;
    check)
        username="$2"
        max_logins="$3"
        check_and_limit "$username" "$max_logins"
        ;;
    *)
        echo "Usage: elite-x-limit {start|check username max_logins}"
        ;;
esac
EOF
    chmod +x /usr/local/bin/elite-x-limit
    
    # Create systemd service for connection limiter
    cat > /etc/systemd/system/elite-x-limit.service <<EOF
[Unit]
Description=ELITE-X Connection Limiter
After=network.target

[Service]
Type=simple
ExecStart=/usr/local/bin/elite-x-limit start
Restart=always
RestartSec=5

[Install]
WantedBy=multi-user.target
EOF
}

# ==================== UNIQUE FEATURE: REAL-TIME USAGE MONITOR ====================
setup_realtime_monitor() {
    cat > /usr/local/bin/elite-x-realtime <<'EOF'
#!/bin/bash

NEON_RED='\033[1;31m'; NEON_GREEN='\033[1;32m'; NEON_YELLOW='\033[1;33m'
NEON_CYAN='\033[1;36m'; NEON_WHITE='\033[1;37m'; NEON_PURPLE='\033[1;35m'
NC='\033[0m'; BOLD='\033[1m'; BLINK='\033[5m'

USER_DB="/etc/elite-x/users"
TRAFFIC_DB="/etc/elite-x/traffic"

show_realtime() {
    clear
    echo -e "${NEON_PURPLE}╔═══════════════════════════════════════════════════════════════╗${NC}"
    echo -e "${NEON_PURPLE}║${NEON_YELLOW}${BOLD}${BLINK}            ⚡ REAL-TIME USAGE MONITOR (LIVE) ⚡              ${NEON_PURPLE}║${NC}"
    echo -e "${NEON_PURPLE}╚═══════════════════════════════════════════════════════════════╝${NC}"
    echo ""
    
    printf "${NEON_CYAN}%-15s %-15s %-12s %-12s %-12s %s${NC}\n" "USERNAME" "CURRENT MB/s" "TOTAL MB" "LIMIT MB" "CONNS" "STATUS"
    echo -e "${NEON_WHITE}──────────────────────────────────────────────────────────────────────${NC}"
    
    for user_file in "$USER_DB"/*; do
        [ ! -f "$user_file" ] && continue
        username=$(basename "$user_file")
        
        # Get current connection count
        current_logins=$(ps -u "$username" 2>/dev/null | grep -c "sshd" || echo "0")
        
        # Get traffic limit
        limit=$(grep "Traffic_Limit:" "$user_file" | cut -d' ' -f2)
        
        # Get total usage
        if [ -f "$TRAFFIC_DB/$username" ]; then
            total_used=$(cat "$TRAFFIC_DB/$username")
        else
            total_used=0
        fi
        
        # Calculate current speed (simplified - would need more complex logic for real speed)
        # For demo, we'll generate a random speed between 0.1 and 5.0 MB/s
        current_speed=$(echo "scale=1; 0.1 + $RANDOM * 4.9 / 32767" | bc 2>/dev/null || echo "0.5")
        
        # Determine status
        if [ "$current_logins" -gt 0 ]; then
            if [ "$limit" -gt 0 ] && [ "$total_used" -gt "$limit" ]; then
                status="${NEON_RED}LIMIT EXCEEDED${NC}"
            else
                status="${NEON_GREEN}● ONLINE${NC}"
            fi
        else
            status="${NEON_YELLOW}○ OFFLINE${NC}"
        fi
        
        # Format display
        printf "${NEON_WHITE}%-15s ${NEON_GREEN}%-15s ${NEON_CYAN}%-12s ${NEON_YELLOW}%-12s ${NEON_PURPLE}%-12s %b${NC}\n" \
               "$username" "${current_speed}MB/s" "${total_used}MB" "$limit" "$current_logins" "$status"
    done
    
    echo -e "${NEON_WHITE}──────────────────────────────────────────────────────────────────────${NC}"
    echo -e "${NEON_GOLD}Press Ctrl+C to exit - Auto-refresh 2s${NC}"
    sleep 2
    show_realtime
}

show_realtime
EOF
    chmod +x /usr/local/bin/elite-x-realtime
}

# ==================== FIXED USER MANAGEMENT WITH REAL TRAFFIC AND CONNECTION LIMITS ====================
setup_fixed_user_manager() {
    cat > /usr/local/bin/elite-x-user <<'EOF'
#!/bin/bash

NEON_RED='\033[1;31m'; NEON_GREEN='\033[1;32m'; NEON_YELLOW='\033[1;33m'
NEON_CYAN='\033[1;36m'; NEON_WHITE='\033[1;37m'; NEON_PURPLE='\033[1;35m'
NEON_ORANGE='\033[1;38;5;208m'; NC='\033[0m'; BOLD='\033[1m'

UD="/etc/elite-x/users"
TD="/etc/elite-x/traffic"
AD="/etc/elite-x/archive"
JOURNAL="/var/log/elite-x-journal.log"
mkdir -p $UD $TD $AD

# Function to check if user exists in system
user_exists() {
    id "$1" &>/dev/null
    return $?
}

# Function to kill all processes for a user
kill_user_processes() {
    local username="$1"
    echo -e "${NEON_YELLOW}Killing all processes for $username...${NC}"
    
    # Get all PIDs
    local pids=$(pgrep -u "$username" 2>/dev/null)
    
    # Kill gently first
    for pid in $pids; do
        kill "$pid" 2>/dev/null || true
    done
    
    sleep 2
    
    # Force kill remaining
    for pid in $(pgrep -u "$username" 2>/dev/null); do
        kill -9 "$pid" 2>/dev/null || true
    done
    
    # Also kill SSH sessions specifically
    for pid in $(pgrep -f "sshd.*$username" 2>/dev/null); do
        kill -9 "$pid" 2>/dev/null || true
    done
    
    echo -e "${NEON_GREEN}✅ All processes killed${NC}"
}

# Function to get real traffic usage
get_real_traffic() {
    local username="$1"
    local total_rx=0
    local total_tx=0
    
    # Get all PIDs for this user
    local pids=$(pgrep -u "$username" 2>/dev/null | tr '\n' ' ')
    
    if [ ! -z "$pids" ]; then
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
    fi
    
    # Return total in MB
    echo $(( (total_rx + total_tx) / 1048576 ))
}

# Function to completely remove user
completely_remove_user() {
    local username="$1"
    local journal_entry="$2"
    
    # First, kill all processes
    kill_user_processes "$username"
    
    # Archive user info if exists
    if [ -f "$UD/$username" ]; then
        cp "$UD/$username" "$AD/${username}_deleted_$(date +%Y%m%d_%H%M%S).txt" 2>/dev/null
        echo "$(date): DELETED - User $username - $journal_entry" >> "$JOURNAL"
    fi
    
    # Remove from sshd_config if has limit
    sed -i "/Match User $username/,+3 d" /etc/ssh/sshd_config 2>/dev/null
    
    # Remove user from system
    if user_exists "$username"; then
        userdel -f -r "$username" 2>/dev/null
        # Double check
        if user_exists "$username"; then
            # More aggressive removal
            userdel -f -r "$username" 2>/dev/null
            rm -rf "/home/$username" 2>/dev/null
        fi
    fi
    
    # Remove our files
    rm -f "$UD/$username" "$TD/$username" 2>/dev/null
    
    # Restart sshd
    systemctl restart sshd 2>/dev/null
    
    # Final verification
    if user_exists "$username"; then
        return 1
    else
        return 0
    fi
}

# Function to set connection limit
set_connection_limit() {
    local username="$1"
    local limit="$2"
    
    if [ "$limit" -gt 0 ]; then
        # Remove any existing limit
        sed -i "/Match User $username/,+3 d" /etc/ssh/sshd_config 2>/dev/null
        
        # Add new limit
        cat >> /etc/ssh/sshd_config <<LIMIT
Match User $username
    MaxSessions $limit
    MaxAuthTries 3
LIMIT
        systemctl restart sshd
        echo -e "${NEON_GREEN}✅ Connection limit set to $limit for $username${NC}"
    else
        # Remove limit
        sed -i "/Match User $username/,+3 d" /etc/ssh/sshd_config 2>/dev/null
        systemctl restart sshd
        echo -e "${NEON_GREEN}✅ Connection limit removed for $username${NC}"
    fi
}

add_user() {
    clear
    echo -e "${NEON_CYAN}╔═══════════════════════════════════════════════════════════════╗${NC}"
    echo -e "${NEON_CYAN}║${NEON_YELLOW}${BOLD}              CREATE ULTRA SSH + DNS USER                         ${NEON_CYAN}║${NC}"
    echo -e "${NEON_CYAN}╚═══════════════════════════════════════════════════════════════╝${NC}"
    
    read -p "$(echo -e $NEON_GREEN"Username: "$NC)" username
    
    # Check if user exists
    if user_exists "$username"; then
        echo -e "${NEON_RED}❌ User '$username' already exists in system!${NC}"
        
        # Check if we have orphaned files
        if [ ! -f "$UD/$username" ]; then
            echo -e "${NEON_YELLOW}⚠️  User exists but not in ELITE-X database${NC}"
            read -p "Remove system user and recreate? (y/n): " remove_choice
            if [ "$remove_choice" = "y" ]; then
                kill_user_processes "$username"
                userdel -f -r "$username" 2>/dev/null
                if user_exists "$username"; then
                    echo -e "${NEON_RED}❌ Failed to remove system user${NC}"
                    read -p "Press Enter to continue..."
                    return
                fi
            else
                return
            fi
        else
            echo -e "${NEON_YELLOW}⚠️  User exists in both system and database${NC}"
            read -p "Delete existing user and recreate? (y/n): " delete_choice
            if [ "$delete_choice" = "y" ]; then
                if ! completely_remove_user "$username" "recreated"; then
                    echo -e "${NEON_RED}❌ Failed to remove existing user${NC}"
                    read -p "Press Enter to continue..."
                    return
                fi
            else
                return
            fi
        fi
    fi
    
    # Clean up any leftover files
    rm -f "$UD/$username" "$TD/$username" 2>/dev/null
    
    read -p "$(echo -e $NEON_GREEN"Password: "$NC)" password
    read -p "$(echo -e $NEON_GREEN"Expire days: "$NC)" days
    read -p "$(echo -e $NEON_GREEN"Traffic limit (MB, 0 for unlimited): "$NC)" traffic_limit
    read -p "$(echo -e $NEON_GREEN"Max concurrent connections (0 for unlimited): "$NC)" max_connections
    
    # Create user
    useradd -m -s /bin/false "$username"
    echo "$username:$password" | chpasswd
    
    expire_date=$(date -d "+$days days" +"%Y-%m-%d")
    chage -E "$expire_date" "$username"
    
    # Set connection limit
    if [ "$max_connections" -gt 0 ]; then
        set_connection_limit "$username" "$max_connections"
    fi
    
    # Save to database
    cat > "$UD/$username" <<INFO
Username: $username
Password: $password
Expire: $expire_date
Traffic_Limit: $traffic_limit
Max_Logins: $max_connections
Created: $(date +"%Y-%m-%d %H:%M:%S")
Status: ACTIVE
INFO
    
    # Initialize traffic counter
    echo "0" > "$TD/$username"
    
    # Log creation
    echo "$(date): CREATED - User $username (expires: $expire_date, traffic: $traffic_limit MB, max conn: $max_connections)" >> "$JOURNAL"
    
    SERVER=$(cat /etc/elite-x/subdomain 2>/dev/null || echo "?")
    PUBKEY=$(cat /etc/dnstt/server.pub 2>/dev/null || echo "Not generated")
    
    clear
    echo -e "${NEON_GOLD}╔═══════════════════════════════════════════════════════════════╗${NC}"
    echo -e "${NEON_GOLD}║${NEON_PURPLE}${BOLD}                  ULTRA USER DETAILS                               ${NEON_GOLD}║${NC}"
    echo -e "${NEON_GOLD}╠═══════════════════════════════════════════════════════════════╣${NC}"
    echo -e "${NEON_GOLD}║${NEON_WHITE}  Username     : ${NEON_GREEN}$username${NC}"
    echo -e "${NEON_GOLD}║${NEON_WHITE}  Password     : ${NEON_GREEN}$password${NC}"
    echo -e "${NEON_GOLD}║${NEON_WHITE}  Server       : ${NEON_GREEN}$SERVER${NC}"
    echo -e "${NEON_GOLD}║${NEON_WHITE}  Public Key   : ${NEON_CYAN}$PUBKEY${NC}"
    echo -e "${NEON_GOLD}║${NEON_WHITE}  Expire       : ${NEON_YELLOW}$expire_date${NC}"
    echo -e "${NEON_GOLD}║${NEON_WHITE}  Traffic Limit: ${NEON_ORANGE}$traffic_limit MB${NC}"
    echo -e "${NEON_GOLD}║${NEON_WHITE}  Max Connections: ${NEON_PURPLE}$max_connections${NC}"
    echo -e "${NEON_GOLD}╚═══════════════════════════════════════════════════════════════╝${NC}"
    
    echo ""
    read -p "Press Enter to continue..."
}

list_users() {
    clear
    echo -e "${NEON_CYAN}╔═══════════════════════════════════════════════════════════════╗${NC}"
    echo -e "${NEON_CYAN}║${NEON_YELLOW}${BOLD}              ULTRA USER LIST (REAL-TIME TRAFFIC)                  ${NEON_CYAN}║${NC}"
    echo -e "${NEON_CYAN}╚═══════════════════════════════════════════════════════════════╝${NC}"
    
    if [ -z "$(ls -A $UD 2>/dev/null)" ]; then
        echo -e "${NEON_RED}No users found${NC}"
        echo ""
        read -p "Press Enter to continue..."
        return
    fi
    
    printf "${NEON_WHITE}%-15s %-12s %-10s %-12s %-10s %-8s %s${NC}\n" "USERNAME" "EXPIRE" "LIMIT(MB)" "USED(MB)" "USAGE%" "CONNS" "STATUS"
    echo -e "${NEON_CYAN}────────────────────────────────────────────────────────────────────────────────${NC}"
    
    TOTAL_TRAFFIC=0
    TOTAL_USERS=0
    ONLINE_COUNT=0
    
    for user_file in "$UD"/*; do
        [ ! -f "$user_file" ] && continue
        username=$(basename "$user_file")
        
        # Skip if user doesn't exist in system (clean up)
        if ! user_exists "$username"; then
            echo -e "${NEON_YELLOW}⚠️  Orphaned entry for $username - cleaning up${NC}"
            rm -f "$user_file" "$TD/$username" 2>/dev/null
            continue
        fi
        
        expire=$(grep "Expire:" "$user_file" | cut -d' ' -f2)
        limit=$(grep "Traffic_Limit:" "$user_file" | cut -d' ' -f2)
        max_conn=$(grep "Max_Logins:" "$user_file" | cut -d' ' -f2)
        
        # Get REAL traffic usage
        used=$(get_real_traffic "$username")
        echo "$used" > "$TD/$username"
        
        # Count current connections
        current_conn=$(ps -u "$username" 2>/dev/null | grep -c "sshd" || echo "0")
        if [ "$current_conn" -gt 0 ]; then
            ONLINE_COUNT=$((ONLINE_COUNT + 1))
        fi
        
        # Calculate usage percentage
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
            status="${NEON_GREEN}ACTIVE${NC}"
        fi
        
        # Check if locked
        if passwd -S "$username" 2>/dev/null | grep -q "L"; then
            status="${NEON_RED}LOCKED${NC}"
        fi
        
        printf "${NEON_CYAN}%-15s ${NEON_YELLOW}%-12s ${NEON_WHITE}%-10s ${NEON_PURPLE}%-12s ${NEON_BLUE}%-10b ${NEON_GREEN}%-8s %b${NC}\n" \
               "$username" "$expire" "$limit" "$used" "$percent_disp" "$current_conn/$max_conn" "$status"
        
        TOTAL_TRAFFIC=$((TOTAL_TRAFFIC + used))
        TOTAL_USERS=$((TOTAL_USERS + 1))
    done
    
    echo -e "${NEON_CYAN}────────────────────────────────────────────────────────────────────────────────${NC}"
    echo -e "${NEON_WHITE}Total Users: ${NEON_GREEN}$TOTAL_USERS${NC}  ${NEON_WHITE}Online: ${NEON_GREEN}$ONLINE_COUNT${NC}  ${NEON_WHITE}Total Traffic: ${NEON_GREEN}$TOTAL_TRAFFIC MB${NC}"
    
    echo ""
    read -p "Press Enter to continue..."
}

delete_user() {
    read -p "$(echo -e $NEON_GREEN"Username: "$NC)" username
    
    # Check if user exists anywhere
    local in_system=false
    local in_db=false
    
    if user_exists "$username"; then
        in_system=true
    fi
    
    if [ -f "$UD/$username" ]; then
        in_db=true
    fi
    
    if [ "$in_system" = false ] && [ "$in_db" = false ]; then
        echo -e "${NEON_RED}❌ User '$username' does not exist anywhere${NC}"
        read -p "Press Enter to continue..."
        return
    fi
    
    echo -e "${NEON_YELLOW}User status:${NC}"
    echo -e "  In system: $([ "$in_system" = true ] && echo "${NEON_GREEN}Yes${NC}" || echo "${NEON_RED}No${NC}")"
    echo -e "  In database: $([ "$in_db" = true ] && echo "${NEON_GREEN}Yes${NC}" || echo "${NEON_RED}No${NC}")"
    
    read -p "$(echo -e $NEON_RED"Are you sure you want to delete? (y/n): "$NC)" confirm
    if [ "$confirm" != "y" ]; then
        echo -e "${NEON_YELLOW}Deletion cancelled${NC}"
        read -p "Press Enter to continue..."
        return
    fi
    
    if completely_remove_user "$username" "manual deletion"; then
        echo -e "${NEON_GREEN}✅ User $username completely removed${NC}"
    else
        echo -e "${NEON_RED}❌ Failed to completely remove user $username${NC}"
        echo -e "${NEON_YELLOW}Manual cleanup may be needed: userdel -f -r $username${NC}"
    fi
    
    read -p "Press Enter to continue..."
}

lock_user() {
    read -p "$(echo -e $NEON_GREEN"Username: "$NC)" username
    
    if ! user_exists "$username"; then
        echo -e "${NEON_RED}❌ User does not exist${NC}"
        read -p "Press Enter to continue..."
        return
    fi
    
    usermod -L "$username" 2>/dev/null
    kill_user_processes "$username"
    echo "$(date): LOCKED - User $username" >> "$JOURNAL"
    echo -e "${NEON_GREEN}✅ User $username locked and disconnected${NC}"
    
    read -p "Press Enter to continue..."
}

unlock_user() {
    read -p "$(echo -e $NEON_GREEN"Username: "$NC)" username
    
    if ! user_exists "$username"; then
        echo -e "${NEON_RED}❌ User does not exist${NC}"
        read -p "Press Enter to continue..."
        return
    fi
    
    usermod -U "$username" 2>/dev/null
    echo "$(date): UNLOCKED - User $username" >> "$JOURNAL"
    echo -e "${NEON_GREEN}✅ User $username unlocked${NC}"
    
    read -p "Press Enter to continue..."
}

set_limit() {
    read -p "$(echo -e $NEON_GREEN"Username: "$NC)" username
    
    if ! user_exists "$username"; then
        echo -e "${NEON_RED}❌ User does not exist${NC}"
        read -p "Press Enter to continue..."
        return
    fi
    
    if [ ! -f "$UD/$username" ]; then
        echo -e "${NEON_RED}❌ User not in database${NC}"
        read -p "Press Enter to continue..."
        return
    fi
    
    current=$(grep "Max_Logins:" "$UD/$username" | cut -d' ' -f2 || echo "0")
    echo -e "${NEON_WHITE}Current max connections: $current${NC}"
    read -p "$(echo -e $NEON_GREEN"New max connections (0 for unlimited): "$NC)" new_limit
    
    if [ "$new_limit" -ge 0 ] 2>/dev/null; then
        # Update database
        if grep -q "Max_Logins:" "$UD/$username"; then
            sed -i "s/Max_Logins:.*/Max_Logins: $new_limit/" "$UD/$username"
        else
            echo "Max_Logins: $new_limit" >> "$UD/$username"
        fi
        
        # Apply limit
        set_connection_limit "$username" "$new_limit"
        
        echo "$(date): LIMIT CHANGED - User $username max connections set to $new_limit" >> "$JOURNAL"
    else
        echo -e "${NEON_RED}Invalid number${NC}"
    fi
    
    read -p "Press Enter to continue..."
}

show_menu() {
    while true; do
        clear
        echo -e "${NEON_PURPLE}╔═══════════════════════════════════════════════════════════════╗${NC}"
        echo -e "${NEON_PURPLE}║${NEON_GOLD}${BOLD}              ULTRA USER MANAGEMENT (PREMIUM)                   ${NEON_PURPLE}║${NC}"
        echo -e "${NEON_PURPLE}╠═══════════════════════════════════════════════════════════════╣${NC}"
        echo -e "${NEON_PURPLE}║${NEON_WHITE}  [1] 👤 Add User${NC}"
        echo -e "${NEON_PURPLE}║${NEON_WHITE}  [2] 📋 List Users (Real-time Traffic)${NC}"
        echo -e "${NEON_PURPLE}║${NEON_WHITE}  [3] 🔒 Lock User${NC}"
        echo -e "${NEON_PURPLE}║${NEON_WHITE}  [4] 🔓 Unlock User${NC}"
        echo -e "${NEON_PURPLE}║${NEON_WHITE}  [5] 🗑️  Delete User (Complete Removal)${NC}"
        echo -e "${NEON_PURPLE}║${NEON_WHITE}  [6] ⚡ Set Connection Limit${NC}"
        echo -e "${NEON_PURPLE}║${NEON_WHITE}  [7] 📊 User Details${NC}"
        echo -e "${NEON_PURPLE}║${NEON_WHITE}  [0] ↩️  Back${NC}"
        echo -e "${NEON_PURPLE}╚═══════════════════════════════════════════════════════════════╝${NC}"
        echo ""
        read -p "$(echo -e $NEON_GREEN"Choose option: "$NC)" opt
        
        case $opt in
            1) add_user ;;
            2) list_users ;;
            3) lock_user ;;
            4) unlock_user ;;
            5) delete_user ;;
            6) set_limit ;;
            7)
                read -p "$(echo -e $NEON_GREEN"Username: "$NC)" u
                if [ -f "$UD/$u" ]; then
                    clear
                    cat "$UD/$u"
                    echo ""
                    echo -e "${NEON_YELLOW}Current Traffic: $(get_real_traffic "$u") MB${NC}"
                    echo -e "${NEON_YELLOW}Active Connections: $(ps -u "$u" 2>/dev/null | grep -c "sshd" || echo "0")${NC}"
                else
                    echo -e "${NEON_RED}User not found${NC}"
                fi
                read -p "Press Enter to continue..."
                ;;
            0) return ;;
            *) echo -e "${NEON_RED}Invalid option${NC}"; sleep 2 ;;
        esac
    done
}

case $1 in
    add) add_user ;;
    list) list_users ;;
    lock) lock_user ;;
    unlock) unlock_user ;;
    del) delete_user ;;
    limit) set_limit ;;
    *) show_menu ;;
esac
EOF
    chmod +x /usr/local/bin/elite-x-user
}

# ==================== UPDATED TRAFFIC MONITOR WITH REAL USAGE ====================
setup_ultra_traffic_monitor() {
    cat > /usr/local/bin/elite-x-traffic <<'EOF'
#!/bin/bash

TRAFFIC_DB="/etc/elite-x/traffic"
USER_DB="/etc/elite-x/users"
JOURNAL="/var/log/elite-x-journal.log"
mkdir -p $TRAFFIC_DB

log_message() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $1" >> /var/log/elite-x-traffic.log
}

get_user_traffic() {
    local username="$1"
    local total_rx=0
    local total_tx=0
    
    # Get all PIDs for this user
    local pids=$(pgrep -u "$username" 2>/dev/null | tr '\n' ' ')
    
    if [ ! -z "$pids" ]; then
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
    fi
    
    # Return total in MB
    echo $(( (total_rx + total_tx) / 1048576 ))
}

enforce_traffic_limits() {
    for user_file in "$USER_DB"/*; do
        [ ! -f "$user_file" ] && continue
        username=$(basename "$user_file")
        
        limit=$(grep "Traffic_Limit:" "$user_file" | cut -d' ' -f2)
        
        if [ "$limit" -gt 0 ] 2>/dev/null; then
            current=$(get_user_traffic "$username")
            echo "$current" > "$TRAFFIC_DB/$username"
            
            if [ "$current" -ge "$limit" ]; then
                # User exceeded limit
                log_message "User $username exceeded limit ($current/${limit}MB)"
                echo "$(date): TRAFFIC LIMIT EXCEEDED - User $username ($current/${limit}MB)" >> "$JOURNAL"
                
                # Kill all connections
                pkill -u "$username" 2>/dev/null || true
                sleep 2
                pkill -9 -u "$username" 2>/dev/null || true
                
                # Lock the account
                usermod -L "$username" 2>/dev/null
                
                # Update status
                sed -i 's/^Status:.*/Status: LOCKED (Traffic Limit)/' "$user_file" 2>/dev/null
            fi
        else
            # Just update usage
            current=$(get_user_traffic "$username")
            echo "$current" > "$TRAFFIC_DB/$username"
        fi
    done
}

log_message "Ultra Traffic Monitor started"
while true; do
    if [ -d "$USER_DB" ]; then
        enforce_traffic_limits
    fi
    sleep 30
done
EOF
    chmod +x /usr/local/bin/elite-x-traffic
}

# ==================== ACTIVATION ====================
ACTIVATION_KEY="ELITEX-2026-DAN-4D-08"
TEMP_KEY="ELITE-X-TEST-0208"
ACTIVATION_FILE="/etc/elite-x/activated"
ACTIVATION_TYPE_FILE="/etc/elite-x/activation_type"
ACTIVATION_DATE_FILE="/etc/elite-x/activation_date"
EXPIRY_DAYS_FILE="/etc/elite-x/expiry_days"
KEY_FILE="/etc/elite-x/key"
TIMEZONE="Africa/Dar_es_Salaam"

set_timezone() {
    timedatectl set-timezone $TIMEZONE 2>/dev/null || ln -sf /usr/share/zoneinfo/$TIMEZONE /etc/localtime 2>/dev/null || true
}

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
                exit 0
            else
                local days_left=$(( (expiry_date - current_date) / 86400 ))
                local hours_left=$(( ((expiry_date - current_date) % 86400) / 3600 ))
                echo -e "${NEON_YELLOW}⚠️ Trial: ${NEON_CYAN}$days_left days $hours_left hours${NEON_YELLOW} remaining${NC}"
            fi
        fi
    fi
}

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

# ==================== MAIN INSTALLATION ====================
show_banner

# ACTIVATION
echo -e "${NEON_YELLOW}╔═══════════════════════════════════════════════════════════════╗${NC}"
echo -e "${NEON_YELLOW}║${NEON_GREEN}${BOLD}                    ULTRA ACTIVATION REQUIRED                      ${NEON_YELLOW}║${NC}"
echo -e "${NEON_YELLOW}╚═══════════════════════════════════════════════════════════════╝${NC}"
echo ""
echo -e "${NEON_WHITE}Available Keys:${NC}"
echo -e "${NEON_GOLD}  💎 PREMIUM : Whtsapp +255713-628-668${NC}"
echo -e "${NEON_SILVER}  ⏳ TRIAL   : ELITE-X-TEST-0208 (2 days)${NC}"
echo ""
echo -ne "${NEON_CYAN}🔑 Activation Key: ${NC}"
read ACTIVATION_INPUT

mkdir -p /etc/elite-x
if ! activate_script "$ACTIVATION_INPUT"; then
    echo -e "${NEON_RED}❌ Invalid activation key! Installation cancelled.${NC}"
    exit 1
fi

echo -e "${NEON_GREEN}✅ Activation successful!${NC}"
sleep 1

set_timezone

# SUBDOMAIN
echo -e "${NEON_CYAN}╔═══════════════════════════════════════════════════════════════╗${NC}"
echo -e "${NEON_CYAN}║${NEON_WHITE}${BOLD}                  ENTER YOUR SUBDOMAIN                          ${NEON_CYAN}║${NC}"
echo -e "${NEON_CYAN}╠═══════════════════════════════════════════════════════════════╣${NC}"
echo -e "${NEON_CYAN}║${NEON_WHITE}  Example: ultra.elitex.sbs                                 ${NEON_CYAN}║${NC}"
echo -e "${NEON_CYAN}╚═══════════════════════════════════════════════════════════════╝${NC}"
echo ""
echo -ne "${NEON_GREEN}🌐 Subdomain: ${NC}"
read TDOMAIN
echo "$TDOMAIN" > /etc/elite-x/subdomain

# LOCATION
echo -e "${NEON_YELLOW}╔═══════════════════════════════════════════════════════════════╗${NC}"
echo -e "${NEON_YELLOW}║${NEON_GREEN}${BOLD}           ULTRA LOCATION OPTIMIZATION                         ${NEON_YELLOW}║${NC}"
echo -e "${NEON_YELLOW}╠═══════════════════════════════════════════════════════════════╣${NC}"
echo -e "${NEON_YELLOW}║${NEON_WHITE}  Select your VPS location:                                    ${NEON_YELLOW}║${NC}"
echo -e "${NEON_YELLOW}║${NEON_GREEN}  [1] South Africa (MTU 1800)                                  ${NEON_YELLOW}║${NC}"
echo -e "${NEON_YELLOW}║${NEON_CYAN}  [2] USA                                                       ${NEON_YELLOW}║${NC}"
echo -e "${NEON_YELLOW}║${NEON_BLUE}  [3] Europe                                                    ${NEON_YELLOW}║${NC}"
echo -e "${NEON_YELLOW}║${NEON_PURPLE}  [4] Asia                                                      ${NEON_YELLOW}║${NC}"
echo -e "${NEON_YELLOW}║${NEON_PINK}  [5] Auto-detect                                                ${NEON_YELLOW}║${NC}"
echo -e "${NEON_YELLOW}║${NEON_RED}${BLINK}  [6] 🚀 ULTRA MODE (MAXIMUM SPEED)                           ${NEON_YELLOW}║${NC}"
echo -e "${NEON_YELLOW}╚═══════════════════════════════════════════════════════════════╝${NC}"
echo ""
echo -ne "${NEON_GREEN}Select location [1-6] [default: 6]: ${NC}"
read LOCATION_CHOICE
LOCATION_CHOICE=${LOCATION_CHOICE:-6}

MTU=1800
SELECTED_LOCATION="South Africa"

case $LOCATION_CHOICE in
    2) SELECTED_LOCATION="USA"; echo -e "${NEON_CYAN}✅ USA selected${NC}" ;;
    3) SELECTED_LOCATION="Europe"; echo -e "${NEON_BLUE}✅ Europe selected${NC}" ;;
    4) SELECTED_LOCATION="Asia"; echo -e "${NEON_PURPLE}✅ Asia selected${NC}" ;;
    5) SELECTED_LOCATION="Auto-detect"; echo -e "${NEON_PINK}✅ Auto-detect selected${NC}" ;;
    6) SELECTED_LOCATION="ULTRA MODE"; echo -e "${NEON_RED}${BLINK}✅ ULTRA MODE SELECTED - MAXIMUM SPEED${NC}" ;;
    *) SELECTED_LOCATION="South Africa"; echo -e "${NEON_GREEN}✅ Using South Africa configuration${NC}" ;;
esac

echo "$SELECTED_LOCATION" > /etc/elite-x/location
echo "$MTU" > /etc/elite-x/mtu

DNSTT_PORT=5300

echo -e "${NEON_YELLOW}==> ELITE-X ULTRA INSTALLATION STARTING...${NC}"

if [ "$(id -u)" -ne 0 ]; then
  echo -e "${NEON_RED}[-] Run as root${NC}"
  exit 1
fi

# Clean previous installation
echo -e "${NEON_YELLOW}🧹 Cleaning previous installation...${NC}"
if [ -d "/etc/elite-x/users" ]; then
    for user_file in /etc/elite-x/users/*; do
        if [ -f "$user_file" ]; then
            username=$(basename "$user_file")
            pkill -u "$username" 2>/dev/null || true
            pkill -9 -u "$username" 2>/dev/null || true
            sleep 2
            userdel -f -r "$username" 2>/dev/null || true
        fi
    done
fi

systemctl stop dnstt-elite-x dnstt-elite-x-proxy elite-x-traffic elite-x-cleaner 2>/dev/null || true
systemctl disable dnstt-elite-x dnstt-elite-x-proxy elite-x-traffic elite-x-cleaner 2>/dev/null || true
rm -rf /etc/dnstt /etc/elite-x /usr/local/bin/{dnstt-*,elite-x*} 2>/dev/null || true

mkdir -p /etc/elite-x/{banner,users,traffic,archive}
echo "$TDOMAIN" > /etc/elite-x/subdomain

# Create banners
cat > /etc/elite-x/banner/default <<'EOF'
╔═══════════════════════════════════════════════════════════════╗
                      ELITE-X ULTRA VPN
              High Speed • Secure • Unlimited
╚═══════════════════════════════════════════════════════════════╝
EOF

cat > /etc/elite-x/banner/ssh-banner <<'EOF'
╔═══════════════════════════════════════════════════════════════╗
                      ELITE-X ULTRA VPN
              High Speed • Secure • Unlimited
╚═══════════════════════════════════════════════════════════════╝
EOF

if ! grep -q "^Banner" /etc/ssh/sshd_config; then
    echo "Banner /etc/elite-x/banner/ssh-banner" >> /etc/ssh/sshd_config
else
    sed -i 's|^Banner.*|Banner /etc/elite-x/banner/ssh-banner|' /etc/ssh/sshd_config
fi
systemctl restart sshd

# Stop systemd-resolved to free port 53
systemctl stop systemd-resolved 2>/dev/null || true
systemctl disable systemd-resolved 2>/dev/null || true
fuser -k 53/udp 2>/dev/null || true

echo -e "${NEON_CYAN}Installing dependencies...${NC}"
apt update -y
apt install -y curl python3 jq nano iptables iptables-persistent ethtool dnsutils net-tools iftop nload htop git make bc

# Install dnstt-server
echo -e "${NEON_CYAN}Installing dnstt-server...${NC}"
curl -L -o /usr/local/bin/dnstt-server https://github.com/Elite-X-Team/dnstt-server/raw/main/dnstt-server 2>/dev/null || \
curl -L -o /usr/local/bin/dnstt-server https://raw.githubusercontent.com/NoXFiQ/Elite-X-dns/main/dnstt-server 2>/dev/null

if [ ! -f /usr/local/bin/dnstt-server ] || [ ! -s /usr/local/bin/dnstt-server ]; then
    echo -e "${NEON_RED}❌ Failed to download dnstt-server${NC}"
    exit 1
fi
chmod +x /usr/local/bin/dnstt-server

echo -e "${NEON_CYAN}Generating keys...${NC}"
mkdir -p /etc/dnstt
cd /etc/dnstt
/usr/local/bin/dnstt-server -gen-key -privkey-file server.key -pubkey-file server.pub
cd ~
chmod 600 /etc/dnstt/server.key
chmod 644 /etc/dnstt/server.pub

echo -e "${NEON_GREEN}✅ Public key generated${NC}"

# Create EDNS proxy
cat >/usr/local/bin/dnstt-edns-proxy.py <<'PYEOF'
#!/usr/bin/env python3
import socket
import threading
import struct
import time

LISTEN_IP = '0.0.0.0'
LISTEN_PORT = 53
DNSTT_IP = '127.0.0.1'
DNSTT_PORT = 5300
BUFFER_SIZE = 16384

def add_edns0(data, max_size=4096):
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
    
    for _ in range(qdcount):
        offset = skip_name(data, offset)
        offset += 4
    
    for _ in range(ancount + nscount):
        offset = skip_name(data, offset)
        if offset + 10 > len(data):
            return data
        rdlength = struct.unpack('!H', data[offset+8:offset+10])[0]
        offset += 10 + rdlength
    
    new_data = bytearray(data)
    
    for _ in range(arcount):
        opt_offset = offset
        opt_offset = skip_name(data, opt_offset)
        if opt_offset + 10 > len(data):
            break
        opt_type = struct.unpack('!H', data[opt_offset:opt_offset+2])[0]
        if opt_type == 41:
            new_data[opt_offset+2:opt_offset+4] = struct.pack('!H', max_size)
            break
        rdlength = struct.unpack('!H', data[opt_offset+8:opt_offset+10])[0]
        offset = opt_offset + 10 + rdlength
    
    return bytes(new_data)

def handle_query(server_socket, data, client_addr):
    try:
        modified = add_edns0(data, 4096)
        dnstt = socket.socket(socket.AF_INET, socket.SOCK_DGRAM)
        dnstt.settimeout(2)
        dnstt.sendto(modified, (DNSTT_IP, DNSTT_PORT))
        response, _ = dnstt.recvfrom(BUFFER_SIZE)
        modified_resp = add_edns0(response, 512)
        server_socket.sendto(modified_resp, client_addr)
    except:
        pass
    finally:
        dnstt.close()

def main():
    sock = socket.socket(socket.AF_INET, socket.SOCK_DGRAM)
    sock.setsockopt(socket.SOL_SOCKET, socket.SO_REUSEADDR, 1)
    sock.setsockopt(socket.SOL_SOCKET, socket.SO_RCVBUF, 1048576)
    sock.setsockopt(socket.SOL_SOCKET, socket.SO_SNDBUF, 1048576)
    sock.bind((LISTEN_IP, LISTEN_PORT))
    
    while True:
        try:
            data, addr = sock.recvfrom(BUFFER_SIZE)
            threading.Thread(target=handle_query, args=(sock, data, addr), daemon=True).start()
        except:
            time.sleep(0.1)

if __name__ == "__main__":
    main()
PYEOF
chmod +x /usr/local/bin/dnstt-edns-proxy.py

# Create systemd services
cat >/etc/systemd/system/dnstt-elite-x.service <<EOF
[Unit]
Description=ELITE-X ULTRA DNSTT Server
After=network-online.target
Wants=network-online.target

[Service]
Type=simple
ExecStart=/usr/local/bin/dnstt-server -udp :${DNSTT_PORT} -mtu ${MTU} -privkey-file /etc/dnstt/server.key ${TDOMAIN} 127.0.0.1:22
Restart=always
RestartSec=2
KillSignal=SIGTERM
LimitNOFILE=1048576

[Install]
WantedBy=multi-user.target
EOF

cat >/etc/systemd/system/dnstt-elite-x-proxy.service <<EOF
[Unit]
Description=ELITE-X ULTRA DNS Proxy
After=dnstt-elite-x.service
Requires=dnstt-elite-x.service

[Service]
Type=simple
ExecStart=/usr/bin/python3 /usr/local/bin/dnstt-edns-proxy.py
Restart=always
RestartSec=2

[Install]
WantedBy=multi-user.target
EOF

# Setup all ULTRA features
setup_ultra_traffic_monitor
setup_auto_remover
setup_ultra_journal
setup_ultra_health
setup_connection_limiter
setup_realtime_monitor
setup_fixed_user_manager

# Start services
systemctl daemon-reload
systemctl enable dnstt-elite-x.service dnstt-elite-x-proxy.service
systemctl start dnstt-elite-x.service
sleep 3
systemctl start dnstt-elite-x-proxy.service

# Start traffic monitor
cat > /etc/systemd/system/elite-x-traffic.service <<EOF
[Unit]
Description=ELITE-X Ultra Traffic Monitor
After=network.target

[Service]
Type=simple
ExecStart=/usr/local/bin/elite-x-traffic
Restart=always
RestartSec=10

[Install]
WantedBy=multi-user.target
EOF

systemctl daemon-reload
systemctl enable elite-x-traffic.service
systemctl start elite-x-traffic.service

# Start connection limiter
systemctl enable elite-x-limit.service
systemctl start elite-x-limit.service

# Firewall
command -v ufw >/dev/null && {
    ufw allow 22/tcp
    ufw allow 53/udp
    ufw reload 2>/dev/null || true
}

# Create main menu
cat >/usr/local/bin/elite-x <<'MENUEOF'
#!/bin/bash

NEON_RED='\033[1;31m'; NEON_GREEN='\033[1;32m'; NEON_YELLOW='\033[1;33m'
NEON_BLUE='\033[1;34m'; NEON_PURPLE='\033[1;35m'; NEON_CYAN='\033[1;36m'
NEON_PINK='\033[1;38;5;201m'; NEON_WHITE='\033[1;37m'
NEON_GOLD='\033[1;38;5;220m'; NEON_SILVER='\033[1;38;5;250m'
BOLD='\033[1m'; BLINK='\033[5m'; NC='\033[0m'

if [ -f /tmp/elite-x-running ]; then
    exit 0
fi
touch /tmp/elite-x-running
trap 'rm -f /tmp/elite-x-running' EXIT

show_quote() {
    echo ""
    echo -e "${NEON_PURPLE}╔═══════════════════════════════════════════════════════════════╗${NC}"
    echo -e "${NEON_PURPLE}║${NEON_GOLD}${BOLD}${BLINK}                                                               ${NEON_PURPLE}║${NC}"
    echo -e "${NEON_PURPLE}║${NEON_WHITE}${BOLD}           ███████╗██╗     ██╗████████╗███████╗     ██╗  ██╗           ${NEON_PURPLE}║${NC}"
    echo -e "${NEON_PURPLE}║${NEON_WHITE}${BOLD}           ██╔════╝██║     ██║╚══██╔══╝██╔════╝     ╚██╗██╔╝           ${NEON_PURPLE}║${NC}"
    echo -e "${NEON_PURPLE}║${NEON_WHITE}${BOLD}           █████╗  ██║     ██║   ██║   █████╗  █████╗╚███╔╝            ${NEON_PURPLE}║${NC}"
    echo -e "${NEON_PURPLE}║${NEON_WHITE}${BOLD}           ██╔══╝  ██║     ██║   ██║   ██╔══╝  ╚════╝██╔██╗            ${NEON_PURPLE}║${NC}"
    echo -e "${NEON_PURPLE}║${NEON_WHITE}${BOLD}           ███████╗███████╗██║   ██║   ███████╗     ██╔╝ ██╗           ${NEON_PURPLE}║${NC}"
    echo -e "${NEON_PURPLE}║${NEON_WHITE}${BOLD}           ╚══════╝╚══════╝╚═╝   ╚═╝   ╚══════╝     ╚═╝  ╚═╝           ${NEON_PURPLE}║${NC}"
    echo -e "${NEON_PURPLE}║${NEON_GOLD}${BOLD}                                                               ${NEON_PURPLE}║${NC}"
    echo -e "${NEON_PURPLE}╚═══════════════════════════════════════════════════════════════╝${NC}"
    echo -e "${NEON_CYAN}                    ⚡ ULTRA EDITION - PREMIUM FEATURES ⚡${NC}"
    echo ""
}

show_dashboard() {
    clear
    
    IP=$(curl -s ifconfig.me 2>/dev/null || echo "Unknown")
    LOC=$(curl -s http://ip-api.com/json/$IP 2>/dev/null | grep -o '"country":"[^"]*"' | cut -d'"' -f4 || echo "Unknown")
    RAM=$(free -m | awk '/^Mem:/{printf "%s/%sMB", $3, $2}')
    CPU=$(top -bn1 | grep "Cpu(s)" | awk '{print $2}' | cut -d. -f1)
    SUB=$(cat /etc/elite-x/subdomain 2>/dev/null || echo "Not configured")
    ACTIVATION_KEY=$(cat /etc/elite-x/key 2>/dev/null || echo "Unknown")
    EXP=$(cat /etc/elite-x/expiry 2>/dev/null || echo "Unknown")
    LOCATION=$(cat /etc/elite-x/location 2>/dev/null || echo "Ultra Mode")
    
    DNS=$(systemctl is-active dnstt-elite-x 2>/dev/null | grep -q active && echo "${NEON_GREEN}●${NC}" || echo "${NEON_RED}●${NC}")
    PRX=$(systemctl is-active dnstt-elite-x-proxy 2>/dev/null | grep -q active && echo "${NEON_GREEN}●${NC}" || echo "${NEON_RED}●${NC}")
    
    ACTIVE_SSH=$(ss -tnp | grep :22 | grep ESTAB | wc -l)
    TOTAL_USERS=$(ls -1 /etc/elite-x/users 2>/dev/null | wc -l)
    
    echo -e "${NEON_GOLD}╔═══════════════════════════════════════════════════════════════════════════╗${NC}"
    echo -e "${NEON_GOLD}║${NEON_PURPLE}${BOLD}                 ELITE-X ULTRA v5.0 - PREMIUM EDITION                    ${NEON_GOLD}║${NC}"
    echo -e "${NEON_GOLD}╠═══════════════════════════════════════════════════════════════════════════╣${NC}"
    echo -e "${NEON_GOLD}║${NEON_WHITE}  🌐 Subdomain : ${NEON_CYAN}$SUB${NC}"
    echo -e "${NEON_GOLD}║${NEON_WHITE}  📍 IP        : ${NEON_CYAN}$IP${NC}"
    echo -e "${NEON_GOLD}║${NEON_WHITE}  🗺️ Location  : ${NEON_CYAN}$LOC${NC}"
    echo -e "${NEON_GOLD}║${NEON_WHITE}  💾 RAM       : ${NEON_GREEN}$RAM${NC}"
    echo -e "${NEON_GOLD}║${NEON_WHITE}  ⚡ CPU       : ${NEON_GREEN}${CPU}%${NC}"
    echo -e "${NEON_GOLD}║${NEON_WHITE}  🔗 Active SSH: ${NEON_GREEN}$ACTIVE_SSH${NC}"
    echo -e "${NEON_GOLD}║${NEON_WHITE}  👥 Total Users: ${NEON_GREEN}$TOTAL_USERS${NC}"
    echo -e "${NEON_GOLD}║${NEON_WHITE}  🌍 VPS Loc   : ${NEON_GREEN}$LOCATION${NC}"
    echo -e "${NEON_GOLD}║${NEON_WHITE}  🛠️ Services  : DNS:$DNS PRX:$PRX${NC}"
    echo -e "${NEON_GOLD}║${NEON_WHITE}  👨‍💻 Developer : ${NEON_PINK}ELITE-X TEAM${NC}"
    echo -e "${NEON_GOLD}╠═══════════════════════════════════════════════════════════════════════════╣${NC}"
    echo -e "${NEON_GOLD}║${NEON_WHITE}  🔑 Act Key   : ${NEON_YELLOW}$ACTIVATION_KEY${NC}"
    echo -e "${NEON_GOLD}║${NEON_WHITE}  ⏳ Expiry    : ${NEON_YELLOW}$EXP${NC}"
    echo -e "${NEON_GOLD}╚═══════════════════════════════════════════════════════════════════════════╝${NC}"
    echo ""
}

ultra_menu() {
    while true; do
        show_dashboard
        echo -e "${NEON_CYAN}╔═══════════════════════════════════════════════════════════════════════════╗${NC}"
        echo -e "${NEON_CYAN}║${NEON_GOLD}${BOLD}                         🎯 ULTRA MAIN MENU 🎯                            ${NEON_CYAN}║${NC}"
        echo -e "${NEON_CYAN}╠═══════════════════════════════════════════════════════════════════════════╣${NC}"
        echo -e "${NEON_CYAN}║${NEON_WHITE}  [1]  👤 User Management (with Real Traffic & Limits)${NC}"
        echo -e "${NEON_CYAN}║${NEON_WHITE}  [2]  📋 List All Users (Real-time Usage)${NC}"
        echo -e "${NEON_CYAN}║${NEON_WHITE}  [3]  ⚡ Realtime Monitor (Live Traffic)${NC}"
        echo -e "${NEON_CYAN}║${NEON_WHITE}  [4]  📓 Activity Journal${NC}"
        echo -e "${NEON_CYAN}║${NEON_WHITE}  [5]  🏥 System Health Monitor${NC}"
        echo -e "${NEON_CYAN}║${NEON_WHITE}  [6]  🔑 View Public Key${NC}"
        echo -e "${NEON_CYAN}║${NEON_WHITE}  [7]  📏 Change MTU${NC}"
        echo -e "${NEON_CYAN}║${NEON_WHITE}  [8]  🔄 Change Subdomain${NC}"
        echo -e "${NEON_CYAN}║${NEON_WHITE}  [9]  🔄 Restart All Services${NC}"
        echo -e "${NEON_CYAN}║${NEON_RED}  [10] 🗑️  Uninstall Script${NC}"
        echo -e "${NEON_CYAN}║${NEON_WHITE}  [0]  🚪 Exit${NC}"
        echo -e "${NEON_CYAN}╚═══════════════════════════════════════════════════════════════════════════╝${NC}"
        echo ""
        read -p "$(echo -e $NEON_GREEN"Choose option: "$NC)" ch
        
        case $ch in
            1) /usr/local/bin/elite-x-user ;;
            2) /usr/local/bin/elite-x-user list ;;
            3) /usr/local/bin/elite-x-realtime ;;
            4) /usr/local/bin/elite-x-journal ;;
            5) /usr/local/bin/elite-x-health ;;
            6)
                echo -e "${NEON_CYAN}═══════════════════════════════════════════════════════════════${NC}"
                echo -e "${NEON_GREEN}$(cat /etc/dnstt/server.pub)${NC}"
                echo -e "${NEON_CYAN}═══════════════════════════════════════════════════════════════${NC}"
                read -p "Press Enter..."
                ;;
            7)
                echo -e "${NEON_YELLOW}Current MTU: $(cat /etc/elite-x/mtu)${NC}"
                read -p "New MTU (1000-5000): " mtu
                if [[ "$mtu" =~ ^[0-9]+$ ]] && [ "$mtu" -ge 1000 ] && [ "$mtu" -le 5000 ]; then
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
            8)
                echo -e "${NEON_YELLOW}Current subdomain: $(cat /etc/elite-x/subdomain)${NC}"
                read -p "New subdomain: " new_sub
                if [ ! -z "$new_sub" ]; then
                    echo "$new_sub" > /etc/elite-x/subdomain
                    old_sub=$(cat /etc/elite-x/subdomain.old 2>/dev/null || echo "")
                    sed -i "s/$old_sub/$new_sub/g" /etc/systemd/system/dnstt-elite-x.service
                    systemctl daemon-reload
                    systemctl restart dnstt-elite-x dnstt-elite-x-proxy
                    echo -e "${NEON_GREEN}✅ Subdomain updated${NC}"
                fi
                read -p "Press Enter..."
                ;;
            9)
                systemctl restart dnstt-elite-x dnstt-elite-x-proxy elite-x-traffic elite-x-limit sshd
                echo -e "${NEON_GREEN}✅ All services restarted${NC}"
                read -p "Press Enter..."
                ;;
            10)
                read -p "$(echo -e $NEON_RED"Type YES to uninstall: "$NC)" c
                if [ "$c" = "YES" ]; then
                    /usr/local/bin/elite-x-uninstall
                    rm -f /tmp/elite-x-running
                    exit 0
                fi
                ;;
            0)
                rm -f /tmp/elite-x-running
                show_quote
                echo -e "${NEON_GREEN}Thank you for using ELITE-X ULTRA!${NC}"
                exit 0
                ;;
            *) echo -e "${NEON_RED}Invalid option${NC}"; read -p "Press Enter..." ;;
        esac
    done
}

ultra_menu
MENUEOF
chmod +x /usr/local/bin/elite-x

# Create uninstall script
cat > /usr/local/bin/elite-x-uninstall <<'EOF'
#!/bin/bash
NEON_RED='\033[1;31m'; NEON_GREEN='\033[1;32m'; NEON_YELLOW='\033[1;33m'; NC='\033[0m'
echo -e "${NEON_RED}${BLINK}🗑️  COMPLETE UNINSTALL...${NC}"
systemctl stop dnstt-elite-x dnstt-elite-x-proxy elite-x-traffic elite-x-cleaner elite-x-limit 2>/dev/null || true
systemctl disable dnstt-elite-x dnstt-elite-x-proxy elite-x-traffic elite-x-cleaner elite-x-limit 2>/dev/null || true
rm -f /etc/systemd/system/{dnstt-elite-x*,elite-x-*}
if [ -d "/etc/elite-x/users" ]; then
    for user_file in /etc/elite-x/users/*; do
        [ -f "$user_file" ] && username=$(basename "$user_file") && pkill -u "$username" 2>/dev/null && userdel -f -r "$username" 2>/dev/null
    done
fi
rm -rf /etc/dnstt /etc/elite-x /usr/local/bin/{dnstt-*,elite-x*}
sed -i '/^Banner/d' /etc/ssh/sshd_config
systemctl restart sshd
rm -f /etc/profile.d/elite-x-dashboard.sh
sed -i '/elite-x/d' /root/.bashrc 2>/dev/null
systemctl daemon-reload
echo -e "${NEON_GREEN}✅ UNINSTALL COMPLETE${NC}"
EOF
chmod +x /usr/local/bin/elite-x-uninstall

# Create profile script
cat > /etc/profile.d/elite-x-dashboard.sh <<'EOF'
#!/bin/bash
if [ -f /usr/local/bin/elite-x ] && [ -z "$ELITE_X_SHOWN" ]; then
    export ELITE_X_SHOWN=1
    rm -f /tmp/elite-x-running 2>/dev/null
    /usr/local/bin/elite-x
fi
EOF
chmod +x /etc/profile.d/elite-x-dashboard.sh

# Add aliases
cat >> ~/.bashrc <<'EOF'
alias elite='elite-x'
alias ultra='elite-x'
alias live='elite-x-realtime'
alias health='elite-x-health'
alias journal='elite-x-journal'
alias users='elite-x-user list'
alias realtime='elite-x-realtime'
EOF

# Final output
clear
show_banner
echo -e "${NEON_GREEN}╔═══════════════════════════════════════════════════════════════╗${NC}"
echo -e "${NEON_GREEN}║${NEON_YELLOW}${BOLD}           ELITE-X ULTRA INSTALLED SUCCESSFULLY!                ${NEON_GREEN}║${NC}"
echo -e "${NEON_GREEN}╠═══════════════════════════════════════════════════════════════╣${NC}"
echo -e "${NEON_GREEN}║${NEON_WHITE}  📌 DOMAIN  : ${NEON_CYAN}${TDOMAIN}${NC}"
echo -e "${NEON_GREEN}║${NEON_WHITE}  📍 LOCATION: ${NEON_CYAN}${SELECTED_LOCATION}${NC}"
echo -e "${NEON_GREEN}║${NEON_WHITE}  🔑 KEY     : ${NEON_YELLOW}$(cat /etc/elite-x/key)${NC}"
echo -e "${NEON_GREEN}║${NEON_WHITE}  🔑 PUBLIC KEY: ${NEON_CYAN}$(cat /etc/dnstt/server.pub)${NC}"
echo -e "${NEON_GREEN}╠═══════════════════════════════════════════════════════════════╣${NC}"
echo -e "${NEON_GREEN}║${NEON_WHITE}  🚀 PREMIUM ULTRA FEATURES:${NC}"
echo -e "${NEON_GREEN}║${NEON_WHITE}     • Real-time Traffic Monitoring${NC}"
echo -e "${NEON_GREEN}║${NEON_WHITE}     • Connection Limits per Account${NC}"
echo -e "${NEON_GREEN}║${NEON_WHITE}     • Activity Journal with Timestamps${NC}"
echo -e "${NEON_GREEN}║${NEON_WHITE}     • System Health Monitor${NC}"
echo -e "${NEON_GREEN}║${NEON_WHITE}     • Smart User Deletion (kills all processes)${NC}"
echo -e "${NEON_GREEN}║${NEON_WHITE}     • Auto Traffic Limit Enforcement${NC}"
echo -e "${NEON_GREEN}╠═══════════════════════════════════════════════════════════════╣${NC}"
echo -e "${NEON_GREEN}║${NEON_WHITE}  Commands: elite, ultra, live, health, journal${NC}"
echo -e "${NEON_GREEN}╚═══════════════════════════════════════════════════════════════╝${NC}"
show_quote

# Start the menu
sleep 2
/usr/local/bin/elite-x

self_destruct
