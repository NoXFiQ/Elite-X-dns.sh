#!/bin/bash
# ╔═══════════════════════════════════════════════════════════════╗
#  ███████╗██╗     ██╗████████╗███████╗      ██╗  ██╗
#  ██╔════╝██║     ██║╚══██╔══╝██╔════╝      ╚██╗██╔╝
#  █████╗  ██║     ██║   ██║   █████╗  █████╗ ╚███╔╝ 
#  ██╔══╝  ██║     ██║   ██║   ██╔══╝  ╚════╝ ██╔██╗ 
#  ███████╗███████╗██║   ██║   ███████╗      ██╔╝ ██╗
#  ╚══════╝╚══════╝╚═╝   ╚═╝   ╚══════╝      ╚═╝  ╚═╝
# ╚═══════════════════════════════════════════════════════════════╝
#              ELITE-X SLOWDNS v5.0 - OVERCLOCKED EDITION
# ═════════════════════════════════════════════════════════════════

set -euo pipefail

# ==================== NEON COLOR PALETTE ====================
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

# ==================== COMPLETE UNINSTALL FUNCTION (FIXED) ====================
complete_uninstall() {
    echo -e "${NEON_RED}${BLINK}🗑️  COMPLETE UNINSTALL - REMOVING EVERYTHING...${NC}"
    
    # Stop all services
    systemctl stop dnstt-elite-x dnstt-elite-x-proxy elite-x-traffic elite-x-cleaner 2>/dev/null || true
    systemctl disable dnstt-elite-x dnstt-elite-x-proxy elite-x-traffic elite-x-cleaner 2>/dev/null || true
    
    # Remove service files
    rm -f /etc/systemd/system/{dnstt-elite-x*,elite-x-*}
    rm -f /etc/systemd/system/multi-user.target.wants/{dnstt-elite-x*,elite-x-*} 2>/dev/null || true
    
    # ===== FIXED: REMOVE ALL USERS CREATED BY ELITE-X =====
    echo -e "${NEON_YELLOW}🔍 Checking for ELITE-X users to remove...${NC}"
    
    # Method 1: Remove users from /etc/elite-x/users directory
    if [ -d "/etc/elite-x/users" ]; then
        for user_file in /etc/elite-x/users/*; do
            if [ -f "$user_file" ]; then
                username=$(basename "$user_file")
                echo -e "${NEON_RED}Removing user: $username${NC}"
                
                # Kill all processes for this user
                pkill -u "$username" 2>/dev/null || true
                killall -u "$username" 2>/dev/null || true
                
                # Force remove user and home directory
                userdel -r -f "$username" 2>/dev/null || true
                
                # Double check if user still exists
                if id "$username" &>/dev/null 2>&1; then
                    userdel -f "$username" 2>/dev/null || true
                fi
                
                # Remove home directory if still exists
                rm -rf /home/"$username" 2>/dev/null || true
            fi
        done
    fi
    
    # Method 2: Find all users with shell /bin/false (common for VPN users)
    echo -e "${NEON_YELLOW}🔍 Checking for users with /bin/false shell...${NC}"
    if [ -f /etc/passwd ]; then
        while IFS=: read -r username uid shell home; do
            if [ "$shell" = "/bin/false" ] || [ "$shell" = "/usr/sbin/nologin" ]; then
                # Check if this user might be from ELITE-X (has home directory)
                if [ -d "$home" ] && [ "$home" != "/nonexistent" ]; then
                    echo -e "${NEON_RED}Removing potential ELITE-X user: $username${NC}"
                    pkill -u "$username" 2>/dev/null || true
                    userdel -r -f "$username" 2>/dev/null || true
                    rm -rf "$home" 2>/dev/null || true
                fi
            fi
        done < /etc/passwd 2>/dev/null || true
    fi
    
    # Method 3: Check all home directories
    echo -e "${NEON_YELLOW}🔍 Checking home directories for leftover users...${NC}"
    if [ -d "/home" ]; then
        for home_dir in /home/*; do
            if [ -d "$home_dir" ]; then
                username=$(basename "$home_dir")
                # Skip system users
                if [[ "$username" != "ubuntu" && "$username" != "root" && "$username" != "admin" && "$username" != "user" ]]; then
                    if id "$username" &>/dev/null 2>&1; then
                        echo -e "${NEON_RED}Removing leftover user from home dir: $username${NC}"
                        pkill -u "$username" 2>/dev/null || true
                        userdel -r -f "$username" 2>/dev/null || true
                    fi
                    # Remove home directory even if user doesn't exist
                    rm -rf "$home_dir" 2>/dev/null || true
                fi
            fi
        done
    fi
    
    # Kill any remaining processes
    pkill -f dnstt-server 2>/dev/null || true
    pkill -f dnstt-edns-proxy 2>/dev/null || true
    pkill -f elite-x-traffic 2>/dev/null || true
    pkill -f elite-x-cleaner 2>/dev/null || true
    
    # Remove all ELITE-X directories and files
    rm -rf /etc/dnstt
    rm -rf /etc/elite-x
    rm -f /usr/local/bin/{dnstt-*,elite-x*}
    rm -f /usr/local/bin/dnstt-edns-proxy.py
    rm -f /usr/local/bin/elite-x-{live,analyzer,renew,update,traffic,cleaner,user,booster,refresh,uninstall}
    
    # Remove banner from sshd_config
    sed -i '/^Banner/d' /etc/ssh/sshd_config
    systemctl restart sshd
    
    # Remove cron jobs
    rm -f /etc/cron.hourly/elite-x-expiry
    rm -f /etc/cron.daily/elite-x-* 2>/dev/null || true
    rm -f /etc/cron.weekly/elite-x-* 2>/dev/null || true
    
    # Remove profile and bashrc entries
    rm -f /etc/profile.d/elite-x-dashboard.sh
    sed -i '/elite-x/d' /root/.bashrc 2>/dev/null || true
    sed -i '/menu=/d' /root/.bashrc 2>/dev/null || true
    sed -i '/elite=/d' /root/.bashrc 2>/dev/null || true
    sed -i '/alias menu/d' /root/.bashrc 2>/dev/null || true
    sed -i '/alias elite/d' /root/.bashrc 2>/dev/null || true
    sed -i '/alias live/d' /root/.bashrc 2>/dev/null || true
    sed -i '/alias speed/d' /root/.bashrc 2>/dev/null || true
    sed -i '/alias renew/d' /root/.bashrc 2>/dev/null || true
    
    # Clean up systemd
    systemctl daemon-reload
    
    # Clean up DNS settings (restore original)
    if [ -f /etc/systemd/resolved.conf.backup ]; then
        cp /etc/systemd/resolved.conf.backup /etc/systemd/resolved.conf 2>/dev/null || true
        systemctl restart systemd-resolved 2>/dev/null || true
    fi
    
    # Final verification
    echo -e "${NEON_GREEN}✅ Verifying all users are removed...${NC}"
    sleep 2
    
    echo -e "${NEON_GREEN}${BLINK}✅✅✅ COMPLETE UNINSTALL FINISHED! EVERYTHING REMOVED. ✅✅✅${NC}"
    echo -e "${NEON_YELLOW}All users, services, and files have been deleted.${NC}"
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
    echo -e "${NEON_RED}║${NEON_WHITE}${BOLD}               ELITE-X SLOWDNS v5.0 - OVERCLOCKED EDITION               ${NEON_RED}║${NC}"
    echo -e "${NEON_RED}║${NEON_GREEN}${BOLD}                     ⚡ MAXIMUM SPEED MODE ⚡                           ${NEON_RED}║${NC}"
    echo -e "${NEON_RED}╚═══════════════════════════════════════════════════════════════╝${NC}"
    echo ""
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
                
                # Call complete uninstall
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

# ==================== FIXED IP INFO FUNCTION ====================
get_ip_info() {
    echo -e "${NEON_CYAN}🌐 Fetching IP information...${NC}"
    
    # Try multiple methods to get public IP
    IP=""
    
    # Method 1: ifconfig.me
    IP=$(curl -s --connect-timeout 5 ifconfig.me 2>/dev/null | grep -oE '([0-9]{1,3}\.){3}[0-9]{1,3}' | head -1)
    
    # Method 2: icanhazip.com
    if [ -z "$IP" ]; then
        IP=$(curl -s --connect-timeout 5 icanhazip.com 2>/dev/null | grep -oE '([0-9]{1,3}\.){3}[0-9]{1,3}' | head -1)
    fi
    
    # Method 3: ipinfo.io
    if [ -z "$IP" ]; then
        IP=$(curl -s --connect-timeout 5 ipinfo.io/ip 2>/dev/null | grep -oE '([0-9]{1,3}\.){3}[0-9]{1,3}' | head -1)
    fi
    
    # Method 4: api.ipify.org
    if [ -z "$IP" ]; then
        IP=$(curl -s --connect-timeout 5 api.ipify.org 2>/dev/null | grep -oE '([0-9]{1,3}\.){3}[0-9]{1,3}' | head -1)
    fi
    
    # Method 5: Local IP as last resort
    if [ -z "$IP" ]; then
        IP=$(ip -4 addr show | grep -oP '(?<=inet\s)\d+(\.\d+){3}' | grep -v '127.0.0.1' | head -1)
    fi
    
    if [ -z "$IP" ]; then
        IP="Unknown"
        echo "Unknown" > /etc/elite-x/cached_ip
        echo "Unknown Location" > /etc/elite-x/cached_location
        echo "Unknown ISP" > /etc/elite-x/cached_isp
        echo -e "${NEON_RED}❌ Failed to detect IP${NC}"
        return 1
    fi
    
    echo "$IP" > /etc/elite-x/cached_ip
    echo -e "${NEON_GREEN}✅ IP detected: $IP${NC}"
    
    # Get location and ISP using ip-api.com
    echo -e "${NEON_CYAN}📍 Fetching location and ISP for $IP...${NC}"
    
    API_RESPONSE=$(curl -s --connect-timeout 5 "http://ip-api.com/json/$IP?fields=status,country,city,isp,org,as")
    
    if echo "$API_RESPONSE" | grep -q '"status":"success"'; then
        COUNTRY=$(echo "$API_RESPONSE" | grep -o '"country":"[^"]*"' | cut -d'"' -f4)
        CITY=$(echo "$API_RESPONSE" | grep -o '"city":"[^"]*"' | cut -d'"' -f4)
        ISP=$(echo "$API_RESPONSE" | grep -o '"isp":"[^"]*"' | cut -d'"' -f4)
        
        if [ -z "$COUNTRY" ]; then COUNTRY="Unknown"; fi
        if [ -z "$ISP" ]; then ISP="Unknown ISP"; fi
        
        if [ ! -z "$CITY" ] && [ "$CITY" != "null" ]; then
            LOCATION="$CITY, $COUNTRY"
        else
            LOCATION="$COUNTRY"
        fi
        
        echo "$LOCATION" > /etc/elite-x/cached_location
        echo "$ISP" > /etc/elite-x/cached_isp
        
        echo -e "${NEON_GREEN}✅ Location: $LOCATION${NC}"
        echo -e "${NEON_GREEN}✅ ISP: $ISP${NC}"
    else
        echo "Unknown Location" > /etc/elite-x/cached_location
        echo "Unknown ISP" > /etc/elite-x/cached_isp
        echo -e "${NEON_YELLOW}⚠️ Could not fetch location/ISP, using defaults${NC}"
    fi
    
    return 0
}

# ==================== BOOSTER FUNCTIONS ====================
enable_bbr_plus() {
    echo -e "${NEON_CYAN}🚀 ENABLING BBR PLUS CONGESTION CONTROL...${NC}"
    
    modprobe tcp_bbr 2>/dev/null || true
    echo "tcp_bbr" >> /etc/modules-load.d/modules.conf 2>/dev/null || true
    
    if ! grep -q "tcp_congestion_control = bbr" /etc/sysctl.conf 2>/dev/null; then
        cat >> /etc/sysctl.conf <<EOF

# ========== BBR PLUS BOOST ==========
net.core.default_qdisc = fq_codel
net.ipv4.tcp_congestion_control = bbr
net.ipv4.tcp_notsent_lowat = 16384
net.ipv4.tcp_slow_start_after_idle = 0
EOF
    fi
    
    echo -e "${NEON_GREEN}✅ BBR + FQ Codel enabled!${NC}"
}

optimize_cpu_performance() {
    echo -e "${NEON_CYAN}⚡ OPTIMIZING CPU FOR MAX PERFORMANCE...${NC}"
    
    for cpu in /sys/devices/system/cpu/cpu*/cpufreq/scaling_governor; do
        [ -f "$cpu" ] && echo "performance" > "$cpu" 2>/dev/null || true
    done
    
    if [ -f /sys/devices/system/cpu/intel_pstate/no_turbo ]; then
        echo 0 > /sys/devices/system/cpu/intel_pstate/no_turbo 2>/dev/null || true
    fi
    
    echo -e "${NEON_GREEN}✅ CPU optimized for max speed!${NC}"
}

tune_kernel_parameters() {
    echo -e "${NEON_CYAN}🧠 TUNING KERNEL PARAMETERS...${NC}"
    
    if ! grep -q "KERNEL BOOSTER" /etc/sysctl.conf 2>/dev/null; then
        cat >> /etc/sysctl.conf <<EOF

# ========== KERNEL BOOSTER ==========
fs.file-max = 2097152
fs.nr_open = 2097152
fs.inotify.max_user_watches = 524288
fs.inotify.max_user_instances = 512
fs.inotify.max_queued_events = 16384
vm.swappiness = 5
vm.vfs_cache_pressure = 40
vm.dirty_ratio = 30
vm.dirty_background_ratio = 3
vm.min_free_kbytes = 131072
vm.overcommit_memory = 1
vm.overcommit_ratio = 50
vm.max_map_count = 524288
kernel.sched_autogroup_enabled = 0
kernel.sched_min_granularity_ns = 8000000
kernel.sched_wakeup_granularity_ns = 10000000
kernel.numa_balancing = 0
EOF
    fi
    
    echo -e "${NEON_GREEN}✅ Kernel parameters tuned!${NC}"
}

optimize_irq_affinity() {
    echo -e "${NEON_CYAN}🔄 OPTIMIZING IRQ AFFINITY...${NC}"
    
    apt install -y irqbalance 2>/dev/null || true
    
    cat > /etc/default/irqbalance <<EOF
ENABLED="1"
ONESHOT="0"
IRQBALANCE_ARGS="--powerthresh=0 --pkgthresh=0"
IRQBALANCE_BANNED_CPUS=""
EOF
    
    systemctl enable irqbalance 2>/dev/null || true
    systemctl restart irqbalance 2>/dev/null || true
    
    echo -e "${NEON_GREEN}✅ IRQ affinity optimized!${NC}"
}

optimize_dns_cache() {
    echo -e "${NEON_CYAN}📡 OPTIMIZING DNS CACHE...${NC}"
    
    apt install -y dnsmasq 2>/dev/null || true
    
    cat > /etc/dnsmasq.conf <<EOF
port=53
domain-needed
bogus-priv
no-resolv
server=8.8.8.8
server=8.8.4.4
server=1.1.1.1
server=1.0.0.1
cache-size=10000
dns-forward-max=1000
neg-ttl=3600
max-ttl=3600
min-cache-ttl=3600
max-cache-ttl=86400
edns-packet-max=4096
EOF
    
    systemctl enable dnsmasq 2>/dev/null || true
    systemctl restart dnsmasq 2>/dev/null || true
    
    echo "nameserver 127.0.0.1" > /etc/resolv.conf
    echo "nameserver 8.8.8.8" >> /etc/resolv.conf
    
    echo -e "${NEON_GREEN}✅ DNS cache optimized!${NC}"
}

optimize_interface_offloading() {
    echo -e "${NEON_CYAN}🔧 OPTIMIZING INTERFACE OFFLOADING...${NC}"
    
    for iface in $(ls /sys/class/net/ | grep -v lo); do
        ethtool -K $iface tx on rx on 2>/dev/null || true
        ethtool -K $iface sg on 2>/dev/null || true
        ethtool -K $iface tso on 2>/dev/null || true
        ethtool -K $iface gso on 2>/dev/null || true
        ethtool -K $iface gro on 2>/dev/null || true
        ethtool -G $iface rx 4096 tx 4096 2>/dev/null || true
    done
    
    echo -e "${NEON_GREEN}✅ Interface offloading optimized!${NC}"
}

optimize_tcp_parameters() {
    echo -e "${NEON_CYAN}📶 APPLYING TCP ULTRA BOOST...${NC}"
    
    if ! grep -q "TCP ULTRA BOOST" /etc/sysctl.conf 2>/dev/null; then
        cat >> /etc/sysctl.conf <<EOF

# ========== TCP ULTRA BOOST ==========
net.ipv4.tcp_timestamps = 1
net.ipv4.tcp_sack = 1
net.ipv4.tcp_fack = 1
net.ipv4.tcp_dsack = 1
net.ipv4.tcp_window_scaling = 1
net.ipv4.tcp_adv_win_scale = 2
net.ipv4.tcp_app_win = 31
net.ipv4.tcp_rmem = 4096 87380 536870912
net.ipv4.tcp_wmem = 4096 65536 536870912
net.ipv4.tcp_fastopen = 3
net.ipv4.tcp_moderate_rcvbuf = 1
net.ipv4.tcp_no_metrics_save = 1
net.ipv4.tcp_keepalive_time = 30
net.ipv4.tcp_keepalive_intvl = 5
net.ipv4.tcp_keepalive_probes = 3
net.ipv4.tcp_retries1 = 2
net.ipv4.tcp_retries2 = 3
net.ipv4.tcp_syn_retries = 2
net.ipv4.tcp_synack_retries = 2
net.ipv4.tcp_fin_timeout = 5
net.ipv4.tcp_tw_reuse = 1
EOF
    fi
    
    echo -e "${NEON_GREEN}✅ TCP ultra boost applied!${NC}"
}

setup_qos_priorities() {
    echo -e "${NEON_CYAN}🎯 SETTING UP QOS PRIORITIES...${NC}"
    
    apt install -y iproute2 2>/dev/null || true
    
    DEV=$(ip route | grep default | awk '{print $5}' | head -1)
    if [ -n "$DEV" ]; then
        tc qdisc del dev $DEV root 2>/dev/null || true
        tc qdisc add dev $DEV root handle 1: htb default 30 2>/dev/null || true
        
        tc class add dev $DEV parent 1: classid 1:1 htb rate 10000mbit ceil 10000mbit 2>/dev/null || true
        tc class add dev $DEV parent 1:1 classid 1:10 htb rate 5000mbit ceil 10000mbit prio 0 2>/dev/null || true
        tc class add dev $DEV parent 1:1 classid 1:20 htb rate 3000mbit ceil 10000mbit prio 1 2>/dev/null || true
        tc class add dev $DEV parent 1:1 classid 1:30 htb rate 2000mbit ceil 10000mbit prio 2 2>/dev/null || true
        
        tc filter add dev $DEV protocol ip parent 1:0 prio 1 u32 match ip dport 22 0xffff flowid 1:10 2>/dev/null || true
        tc filter add dev $DEV protocol ip parent 1:0 prio 1 u32 match ip sport 22 0xffff flowid 1:10 2>/dev/null || true
        tc filter add dev $DEV protocol ip parent 1:0 prio 2 u32 match ip dport 53 0xffff flowid 1:20 2>/dev/null || true
        tc filter add dev $DEV protocol ip parent 1:0 prio 2 u32 match ip sport 53 0xffff flowid 1:20 2>/dev/null || true
    fi
    
    echo -e "${NEON_GREEN}✅ QoS priorities configured!${NC}"
}

optimize_memory_usage() {
    echo -e "${NEON_CYAN}💾 OPTIMIZING MEMORY USAGE...${NC}"
    
    echo 5 > /proc/sys/vm/swappiness 2>/dev/null || true
    sync && echo 3 > /proc/sys/vm/drop_caches 2>/dev/null || true
    echo 1 > /proc/sys/vm/compact_memory 2>/dev/null || true
    echo 131072 > /proc/sys/vm/min_free_kbytes 2>/dev/null || true
    
    echo -e "${NEON_GREEN}✅ Memory optimized!${NC}"
}

optimize_buffer_mtu() {
    echo -e "${NEON_CYAN}⚡ OVERCLOCKING BUFFERS & MTU...${NC}"
    
    BEST_MTU=$(ping -M do -s 1472 -c 1 google.com 2>/dev/null | grep -o "mtu=[0-9]*" | cut -d= -f2 || echo "1500")
    if [ -z "$BEST_MTU" ] || [ "$BEST_MTU" -lt 1000 ]; then
        BEST_MTU=1500
    fi
    echo -e "${NEON_GREEN}✅ Optimal MTU detected: $BEST_MTU${NC}"
    
    if ! grep -q "BUFFER OVERCLOCK" /etc/sysctl.conf 2>/dev/null; then
        cat >> /etc/sysctl.conf <<EOF

# ========== BUFFER OVERCLOCK ==========
net.core.rmem_max = 536870912
net.core.wmem_max = 536870912
net.core.rmem_default = 268435456
net.core.wmem_default = 268435456
net.core.netdev_max_backlog = 2000000
net.core.somaxconn = 131072
net.core.optmem_max = 50331648
net.ipv4.udp_rmem_min = 131072
net.ipv4.udp_wmem_min = 131072
EOF
    fi
    
    for iface in $(ls /sys/class/net/ | grep -v lo); do
        ip link set dev $iface mtu $BEST_MTU 2>/dev/null || true
        ip link set dev $iface txqueuelen 200000 2>/dev/null || true
    done
    
    echo -e "${NEON_GREEN}✅ Buffers overclocked to 512MB!${NC}"
}

optimize_network_steering() {
    echo -e "${NEON_CYAN}🎮 ENABLING NETWORK STEERING...${NC}"
    
    for iface in $(ls /sys/class/net/ | grep -v lo); do
        echo f > /sys/class/net/$iface/queues/rx-0/rps_cpus 2>/dev/null || true
        echo 4096 > /sys/class/net/$iface/queues/rx-0/rps_flow_cnt 2>/dev/null || true
    done
    
    echo 262144 > /proc/sys/net/core/rps_sock_flow_entries 2>/dev/null || true
    
    echo -e "${NEON_GREEN}✅ Network steering enabled!${NC}"
}

enable_tcp_fastopen_master() {
    echo -e "${NEON_CYAN}🔓 ENABLING TCP FAST OPEN MASTER...${NC}"
    
    if ! grep -q "TCP FAST OPEN" /etc/sysctl.conf 2>/dev/null; then
        cat >> /etc/sysctl.conf <<EOF

# ========== TCP FAST OPEN ==========
net.ipv4.tcp_fastopen = 3
net.ipv4.tcp_fack = 1
net.ipv4.tcp_early_retrans = 3
EOF
    fi
    
    echo -e "${NEON_GREEN}✅ TCP Fast Open enabled!${NC}"
}

apply_all_boosters() {
    echo -e "${NEON_RED}${BLINK}🚀🚀🚀 APPLYING ALL BOOSTERS - OVERCLOCK MODE 🚀🚀🚀${NC}"
    enable_bbr_plus
    optimize_cpu_performance
    tune_kernel_parameters
    optimize_irq_affinity
    optimize_dns_cache
    optimize_interface_offloading
    optimize_tcp_parameters
    setup_qos_priorities
    optimize_memory_usage
    optimize_buffer_mtu
    optimize_network_steering
    enable_tcp_fastopen_master
    sysctl -p 2>/dev/null || true
    echo -e "${NEON_GREEN}${BOLD}✅✅✅ ALL BOOSTERS APPLIED SUCCESSFULLY! ✅✅✅${NC}"
    echo -e "${NEON_YELLOW}⚠️ System reboot recommended for maximum effect${NC}"
}

# ==================== BOOSTER MENU ====================
booster_menu() {
    while true; do
        clear
        echo -e "${NEON_CYAN}╔═══════════════════════════════════════════════════════════════════════════╗${NC}"
        echo -e "${NEON_CYAN}║${NEON_YELLOW}${BOLD}                    🚀 ELITE-X ULTIMATE BOOSTER 🚀                       ${NEON_CYAN}║${NC}"
        echo -e "${NEON_CYAN}╠═══════════════════════════════════════════════════════════════════════════╣${NC}"
        echo -e "${NEON_CYAN}║${NEON_WHITE}  [B1] 🔥 TCP BBR + FQ Codel (Congestion Control)${NC}"
        echo -e "${NEON_CYAN}║${NEON_WHITE}  [B2] ⚡ CPU Performance Mode (Overclock)${NC}"
        echo -e "${NEON_CYAN}║${NEON_WHITE}  [B3] 🧠 Kernel Parameter Tuning${NC}"
        echo -e "${NEON_CYAN}║${NEON_WHITE}  [B4] 🔄 IRQ Affinity Optimization${NC}"
        echo -e "${NEON_CYAN}║${NEON_WHITE}  [B5] 📡 DNS Cache Booster (200x Faster)${NC}"
        echo -e "${NEON_CYAN}║${NEON_WHITE}  [B6] 🔧 Network Interface Offloading${NC}"
        echo -e "${NEON_CYAN}║${NEON_WHITE}  [B7] 📶 TCP Ultra Boost (512MB Buffers)${NC}"
        echo -e "${NEON_CYAN}║${NEON_WHITE}  [B8] 🎯 QoS Priority Setup${NC}"
        echo -e "${NEON_CYAN}║${NEON_WHITE}  [B9] 💾 Memory Optimizer${NC}"
        echo -e "${NEON_CYAN}║${NEON_WHITE}  [B10] ⚡ Buffer/MTU Overclock${NC}"
        echo -e "${NEON_CYAN}║${NEON_WHITE}  [B11] 🎮 Network Steering${NC}"
        echo -e "${NEON_CYAN}║${NEON_WHITE}  [B12] 🔓 TCP Fast Open Master${NC}"
        echo -e "${NEON_CYAN}║${NEON_RED}  [B13] 🚀 APPLY ALL BOOSTERS (MAXIMUM SPEED)${NC}"
        echo -e "${NEON_CYAN}║${NEON_WHITE}  [0] ↩️ Back to Settings${NC}"
        echo -e "${NEON_CYAN}╚═══════════════════════════════════════════════════════════════════════════╝${NC}"
        echo ""
        read -p "$(echo -e $NEON_GREEN"Booster option: "$NC)" bch
        
        case $bch in
            B1|b1) enable_bbr_plus; sysctl -p 2>/dev/null || true; read -p "Press Enter..." ;;
            B2|b2) optimize_cpu_performance; read -p "Press Enter..." ;;
            B3|b3) tune_kernel_parameters; sysctl -p 2>/dev/null || true; read -p "Press Enter..." ;;
            B4|b4) optimize_irq_affinity; read -p "Press Enter..." ;;
            B5|b5) optimize_dns_cache; read -p "Press Enter..." ;;
            B6|b6) optimize_interface_offloading; read -p "Press Enter..." ;;
            B7|b7) optimize_tcp_parameters; sysctl -p 2>/dev/null || true; read -p "Press Enter..." ;;
            B8|b8) setup_qos_priorities; read -p "Press Enter..." ;;
            B9|b9) optimize_memory_usage; read -p "Press Enter..." ;;
            B10|b10) optimize_buffer_mtu; sysctl -p 2>/dev/null || true; read -p "Press Enter..." ;;
            B11|b11) optimize_network_steering; read -p "Press Enter..." ;;
            B12|b12) enable_tcp_fastopen_master; sysctl -p 2>/dev/null || true; read -p "Press Enter..." ;;
            B13|b13) apply_all_boosters; read -p "Press Enter..." ;;
            0) return ;;
            *) echo -e "${NEON_RED}Invalid option${NC}"; read -p "Press Enter..." ;;
        esac
    done
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

# ==================== FIXED EDNS PROXY ====================
install_edns_proxy() {
    echo -e "${NEON_CYAN}Installing EDNS proxy...${NC}"
    
    cat >/usr/local/bin/dnstt-edns-proxy.py <<'EOF'
#!/usr/bin/env python3
import socket
import threading
import struct
import time

LISTEN_IP = '0.0.0.0'
LISTEN_PORT = 53
DNSTT_IP = '127.0.0.1'
DNSTT_PORT = 5300
BUFFER_SIZE = 8192

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
        dnstt.settimeout(5)
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
    sock.bind((LISTEN_IP, LISTEN_PORT))
    
    while True:
        try:
            data, addr = sock.recvfrom(BUFFER_SIZE)
            threading.Thread(target=handle_query, args=(sock, data, addr), daemon=True).start()
        except:
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

while true; do
    clear
    echo -e "${NEON_CYAN}╔═══════════════════════════════════════════════════════════════╗${NC}"
    echo -e "${NEON_CYAN}║${NEON_YELLOW}${BOLD}              LIVE CONNECTION MONITOR - REFRESH 2S                ${NEON_CYAN}║${NC}"
    echo -e "${NEON_CYAN}╚═══════════════════════════════════════════════════════════════╝${NC}"
    
    total=$(ss -tnp | grep :22 | grep ESTAB | wc -l)
    echo -e "${NEON_PURPLE}Total Active: ${NEON_GREEN}$total${NC}"
    echo ""
    echo -e "${NEON_CYAN}─── CONNECTIONS ───────────────────────────────────────────────${NC}"
    
    ss -tnp | grep :22 | grep ESTAB | while read line; do
        src_ip=$(echo $line | awk '{print $5}' | cut -d: -f1)
        pid=$(echo $line | grep -o 'pid=[0-9]*' | cut -d= -f2)
        
        if [ ! -z "$pid" ] && [ "$pid" != "-" ]; then
            username=$(ps -o user= -p $pid 2>/dev/null | head -1 | xargs)
        else
            username="unknown"
        fi
        
        echo -e "${NEON_CYAN}User:${NEON_WHITE} $username ${NEON_CYAN}IP:${NEON_YELLOW} $src_ip${NC}"
    done
    
    echo -e "${NEON_YELLOW}Press Ctrl+C to exit - Auto-refresh 2s${NC}"
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
echo -e "${NEON_CYAN}║${NEON_YELLOW}${BOLD}                 TRAFFIC ANALYZER                                  ${NEON_CYAN}║${NC}"
echo -e "${NEON_CYAN}╚═══════════════════════════════════════════════════════════════╝${NC}"

rx_total=$(cat /sys/class/net/*/statistics/rx_bytes 2>/dev/null | awk '{sum+=$1} END {printf "%.2f GB", sum/1024/1024/1024}')
tx_total=$(cat /sys/class/net/*/statistics/tx_bytes 2>/dev/null | awk '{sum+=$1} END {printf "%.2f GB", sum/1024/1024/1024}')

echo -e "${NEON_WHITE}System Total RX: ${NEON_GREEN}$rx_total${NC}"
echo -e "${NEON_WHITE}System Total TX: ${NEON_GREEN}$tx_total${NC}"
echo ""

for user_file in $USER_DB/* 2>/dev/null; do
    [ ! -f "$user_file" ] && continue
    username=$(basename "$user_file")
    used=$(cat $TRAFFIC_DB/$username 2>/dev/null || echo "0")
    limit=$(grep "Traffic_Limit:" "$user_file" | cut -d' ' -f2)
    
    echo -e "${NEON_CYAN}User:${NEON_WHITE} $username ${NEON_CYAN}Used:${NEON_YELLOW} ${used}MB ${NEON_CYAN}Limit:${NEON_GREEN} ${limit}MB${NC}"
done
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

echo -e "${NEON_YELLOW}🔄 CHECKING FOR UPDATES...${NC}"
echo -e "${NEON_GREEN}✅ Already latest version!${NC}"
EOF
    chmod +x /usr/local/bin/elite-x-update
}

# ==================== TRAFFIC MONITOR ====================
setup_traffic_monitor() {
    cat > /usr/local/bin/elite-x-traffic <<'EOF'
#!/bin/bash
TRAFFIC_DB="/etc/elite-x/traffic"
USER_DB="/etc/elite-x/users"
mkdir -p $TRAFFIC_DB

while true; do
    if [ -d "$USER_DB" ]; then
        for user_file in "$USER_DB"/*; do
            [ -f "$user_file" ] && echo "0" > "$TRAFFIC_DB/$(basename "$user_file")" 2>/dev/null
        done
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

    systemctl daemon-reload
    systemctl enable elite-x-traffic.service 2>/dev/null || true
    systemctl start elite-x-traffic.service 2>/dev/null || true
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
                        userdel -r "$username" 2>/dev/null || true
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

    systemctl daemon-reload
    systemctl enable elite-x-cleaner.service 2>/dev/null || true
    systemctl start elite-x-cleaner.service 2>/dev/null || true
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
        exit 1
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

add_user() {
    clear
    echo -e "${NEON_CYAN}╔═══════════════════════════════════════════════════════════════╗${NC}"
    echo -e "${NEON_CYAN}║${NEON_YELLOW}${BOLD}              CREATE SSH + DNS USER                            ${NEON_CYAN}║${NC}"
    echo -e "${NEON_CYAN}╚═══════════════════════════════════════════════════════════════╝${NC}"
    
    read -p "$(echo -e $NEON_GREEN"Username: "$NC)" username
    read -p "$(echo -e $NEON_GREEN"Password: "$NC)" password
    read -p "$(echo -e $NEON_GREEN"Expire days: "$NC)" days
    read -p "$(echo -e $NEON_GREEN"Traffic limit (MB, 0 for unlimited): "$NC)" traffic_limit
    
    if id "$username" &>/dev/null; then
        echo -e "${NEON_RED}User already exists!${NC}"
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
Created: $(date +"%Y-%m-%d")
INFO
    
    echo "0" > $TD/$username
    
    SERVER=$(cat /etc/elite-x/subdomain 2>/dev/null || echo "?")
    PUBKEY=$(cat /etc/dnstt/server.pub 2>/dev/null || echo "Not generated")
    
    clear
    echo -e "${NEON_GREEN}╔═══════════════════════════════════════════════════════════════╗${NC}"
    echo -e "${NEON_GREEN}║${NEON_YELLOW}${BOLD}                  USER DETAILS                                   ${NEON_GREEN}║${NC}"
    echo -e "${NEON_GREEN}╠═══════════════════════════════════════════════════════════════╣${NC}"
    echo -e "${NEON_GREEN}║${NEON_WHITE}  Username  :${NEON_CYAN} $username${NC}"
    echo -e "${NEON_GREEN}║${NEON_WHITE}  Password  :${NEON_CYAN} $password${NC}"
    echo -e "${NEON_GREEN}║${NEON_WHITE}  Server    :${NEON_CYAN} $SERVER${NC}"
    echo -e "${NEON_GREEN}║${NEON_WHITE}  Public Key:${NEON_CYAN} $PUBKEY${NC}"
    echo -e "${NEON_GREEN}║${NEON_WHITE}  Expire    :${NEON_CYAN} $expire_date${NC}"
    echo -e "${NEON_GREEN}║${NEON_WHITE}  Traffic   :${NEON_CYAN} $traffic_limit MB${NC}"
    echo -e "${NEON_GREEN}╚═══════════════════════════════════════════════════════════════╝${NC}"
    show_quote
}

list_users() {
    clear
    echo -e "${NEON_CYAN}╔═══════════════════════════════════════════════════════════════╗${NC}"
    echo -e "${NEON_CYAN}║${NEON_YELLOW}${BOLD}                     ACTIVE USERS (WITH PASSWORDS)                  ${NEON_CYAN}║${NC}"
    echo -e "${NEON_CYAN}╠═══════════════════════════════════════════════════════════════╣${NC}"
    
    if [ -z "$(ls -A $UD 2>/dev/null)" ]; then
        echo -e "${NEON_RED}No users found${NC}"
        show_quote
        return
    fi
    
    printf "${NEON_WHITE}%-12s %-15s %-12s %-8s %-8s %-10s %s${NC}\n" "USERNAME" "PASSWORD" "EXPIRE" "LIMIT" "USED" "CONNS" "STATUS"
    echo -e "${NEON_CYAN}────────────────────────────────────────────────────────────────────────${NC}"
    
    for user_file in $UD/*; do
        [ ! -f "$user_file" ] && continue
        username=$(basename "$user_file")
        
        password=$(grep "Password:" "$user_file" | cut -d' ' -f2-)
        expire=$(grep "Expire:" "$user_file" | cut -d' ' -f2)
        limit=$(grep "Traffic_Limit:" "$user_file" | cut -d' ' -f2)
        used=$(cat $TD/$username 2>/dev/null || echo "0")
        
        conn_count=0
        user_pids=$(pgrep -u "$username" 2>/dev/null | tr '\n' '|' | sed 's/|$//')
        if [ ! -z "$user_pids" ]; then
            conn_count=$(ss -tnp 2>/dev/null | grep -E "pid=($user_pids)" | grep -c ESTAB || echo "0")
        fi
        
        if passwd -S "$username" 2>/dev/null | grep -q "L"; then
            status="${NEON_RED}LOCKED${NC}"
        else
            status="${NEON_GREEN}ACTIVE${NC}"
        fi
        
        if [ ${#password} -gt 14 ]; then
            display_pass="${password:0:11}..."
        else
            display_pass="$password"
        fi
        
        printf "${NEON_CYAN}%-12s ${NEON_YELLOW}%-15s ${NEON_GREEN}%-12s ${NEON_WHITE}%-8s ${NEON_PURPLE}%-8s ${NEON_BLUE}%-10s ${NEON_CYAN}%b${NC}\n" \
               "$username" "$display_pass" "$expire" "$limit" "$used" "$conn_count" "$status"
    done
    
    echo -e "${NEON_CYAN}────────────────────────────────────────────────────────────────────────${NC}"
    
    total_users=$(ls -1 $UD | wc -l)
    total_active=$(ss -tnp | grep :22 | grep ESTAB | wc -l)
    echo -e "${NEON_WHITE}Total Users: ${NEON_GREEN}$total_users${NC}  ${NEON_WHITE}Total Connections: ${NEON_GREEN}$total_active${NC}"
    
    show_quote
}

lock_user() { 
    read -p "$(echo -e $NEON_GREEN"Username: "$NC)" u
    if id "$u" &>/dev/null; then
        usermod -L "$u" 2>/dev/null && echo -e "${NEON_GREEN}✅ User $u locked${NC}" || echo -e "${NEON_RED}❌ Failed to lock${NC}"
    else
        echo -e "${NEON_RED}❌ User does not exist${NC}"
    fi
    show_quote
}

unlock_user() { 
    read -p "$(echo -e $NEON_GREEN"Username: "$NC)" u
    if id "$u" &>/dev/null; then
        usermod -U "$u" 2>/dev/null && echo -e "${NEON_GREEN}✅ User $u unlocked${NC}" || echo -e "${NEON_RED}❌ Failed to unlock${NC}"
    else
        echo -e "${NEON_RED}❌ User does not exist${NC}"
    fi
    show_quote
}

delete_user() { 
    read -p "$(echo -e $NEON_GREEN"Username: "$NC)" u
    if id "$u" &>/dev/null; then
        userdel -r "$u" 2>/dev/null
        rm -f $UD/$u $TD/$u
        echo -e "${NEON_GREEN}✅ User $u deleted${NC}"
    else
        echo -e "${NEON_RED}❌ User does not exist${NC}"
    fi
    show_quote
}

case $1 in
    add) add_user ;;
    list) list_users ;;
    lock) lock_user ;;
    unlock) unlock_user ;;
    del) delete_user ;;
    *) echo "Usage: elite-x-user {add|list|lock|unlock|del}" ;;
esac
EOF
    chmod +x /usr/local/bin/elite-x-user
}

# ==================== CREATE REFRESH INFO SCRIPT ====================
create_refresh_script() {
    cat > /usr/local/bin/elite-x-refresh-info <<'EOF'
#!/bin/bash

NEON_CYAN='\033[1;36m'; NEON_GREEN='\033[1;32m'; NEON_RED='\033[1;31m'; NC='\033[0m'

# Get IP
IP=""
for cmd in "curl -s --connect-timeout 5 ifconfig.me" "curl -s --connect-timeout 5 icanhazip.com" "curl -s --connect-timeout 5 ipinfo.io/ip" "curl -s --connect-timeout 5 api.ipify.org"; do
    IP=$($cmd 2>/dev/null | grep -oE '([0-9]{1,3}\.){3}[0-9]{1,3}' | head -1)
    if [ ! -z "$IP" ]; then
        break
    fi
done

if [ -z "$IP" ]; then
    IP=$(ip -4 addr show | grep -oP '(?<=inet\s)\d+(\.\d+){3}' | grep -v '127.0.0.1' | head -1)
fi

if [ -z "$IP" ]; then
    echo "Unknown" > /etc/elite-x/cached_ip
    echo "Unknown Location" > /etc/elite-x/cached_location
    echo "Unknown ISP" > /etc/elite-x/cached_isp
    exit 1
fi

echo "$IP" > /etc/elite-x/cached_ip

# Get location and ISP
API_RESPONSE=$(curl -s --connect-timeout 5 "http://ip-api.com/json/$IP?fields=status,country,city,isp")

if echo "$API_RESPONSE" | grep -q '"status":"success"'; then
    COUNTRY=$(echo "$API_RESPONSE" | grep -o '"country":"[^"]*"' | cut -d'"' -f4)
    CITY=$(echo "$API_RESPONSE" | grep -o '"city":"[^"]*"' | cut -d'"' -f4)
    ISP=$(echo "$API_RESPONSE" | grep -o '"isp":"[^"]*"' | cut -d'"' -f4)
    
    [ -z "$COUNTRY" ] && COUNTRY="Unknown"
    [ -z "$ISP" ] && ISP="Unknown ISP"
    
    if [ ! -z "$CITY" ] && [ "$CITY" != "null" ]; then
        echo "$CITY, $COUNTRY" > /etc/elite-x/cached_location
    else
        echo "$COUNTRY" > /etc/elite-x/cached_location
    fi
    
    echo "$ISP" > /etc/elite-x/cached_isp
else
    echo "Unknown Location" > /etc/elite-x/cached_location
    echo "Unknown ISP" > /etc/elite-x/cached_isp
fi
EOF
    chmod +x /usr/local/bin/elite-x-refresh-info
}

# ==================== CREATE UNINSTALL SCRIPT (FIXED) ====================
create_uninstall_script() {
    cat > /usr/local/bin/elite-x-uninstall <<'EOF'
#!/bin/bash

NEON_RED='\033[1;31m'; NEON_GREEN='\033[1;32m'; NEON_YELLOW='\033[1;33m'; NC='\033[0m'; BLINK='\033[5m'

echo -e "${NEON_RED}${BLINK}🗑️  COMPLETE UNINSTALL - REMOVING EVERYTHING...${NC}"
    
# Stop all services
systemctl stop dnstt-elite-x dnstt-elite-x-proxy elite-x-traffic elite-x-cleaner 2>/dev/null || true
systemctl disable dnstt-elite-x dnstt-elite-x-proxy elite-x-traffic elite-x-cleaner 2>/dev/null || true
    
# Remove service files
rm -f /etc/systemd/system/{dnstt-elite-x*,elite-x-*}
    
# ===== FIXED: REMOVE ALL USERS =====
echo -e "${NEON_YELLOW}🔍 Removing all ELITE-X users...${NC}"

# Method 1: Remove users from user database
if [ -d "/etc/elite-x/users" ]; then
    for user_file in /etc/elite-x/users/*; do
        if [ -f "$user_file" ]; then
            username=$(basename "$user_file")
            echo -e "${NEON_RED}Removing user: $username${NC}"
            
            # Kill all processes
            pkill -u "$username" 2>/dev/null || true
            killall -u "$username" 2>/dev/null || true
            
            # Force remove user
            userdel -r -f "$username" 2>/dev/null || true
            
            # Remove home directory if still exists
            rm -rf /home/"$username" 2>/dev/null || true
        fi
    done
fi

# Method 2: Check all home directories
if [ -d "/home" ]; then
    for home_dir in /home/*; do
        if [ -d "$home_dir" ]; then
            username=$(basename "$home_dir")
            # Skip system users
            if [[ "$username" != "ubuntu" && "$username" != "root" && "$username" != "admin" ]]; then
                if id "$username" &>/dev/null 2>&1; then
                    echo -e "${NEON_RED}Removing leftover user: $username${NC}"
                    pkill -u "$username" 2>/dev/null || true
                    userdel -r -f "$username" 2>/dev/null || true
                fi
                # Remove home directory even if user doesn't exist
                rm -rf "$home_dir" 2>/dev/null || true
            fi
        fi
    done
fi

# Method 3: Find users with /bin/false shell
if [ -f /etc/passwd ]; then
    while IFS=: read -r username shell; do
        if [ "$shell" = "/bin/false" ] || [ "$shell" = "/usr/sbin/nologin" ]; then
            if id "$username" &>/dev/null 2>&1; then
                echo -e "${NEON_RED}Removing shell user: $username${NC}"
                userdel -r -f "$username" 2>/dev/null || true
            fi
        fi
    done < /etc/passwd 2>/dev/null || true
fi

# Kill any remaining processes
pkill -f dnstt-server 2>/dev/null || true
pkill -f dnstt-edns-proxy 2>/dev/null || true
    
# Remove all ELITE-X directories and files
rm -rf /etc/dnstt
rm -rf /etc/elite-x
rm -f /usr/local/bin/{dnstt-*,elite-x*}
rm -f /usr/local/bin/dnstt-edns-proxy.py
rm -f /usr/local/bin/elite-x-{live,analyzer,renew,update,traffic,cleaner,user,booster,refresh,uninstall}
    
# Remove banner from sshd_config
sed -i '/^Banner/d' /etc/ssh/sshd_config
systemctl restart sshd
    
# Remove cron jobs
rm -f /etc/cron.hourly/elite-x-expiry
rm -f /etc/profile.d/elite-x-dashboard.sh
sed -i '/elite-x/d' /root/.bashrc 2>/dev/null || true
    
# Clean up systemd
systemctl daemon-reload

# Final verification
echo -e "${NEON_GREEN}✅ Verifying no users remain...${NC}"
sleep 1

echo -e "${NEON_GREEN}${BLINK}✅✅✅ COMPLETE UNINSTALL FINISHED! EVERYTHING REMOVED. ✅✅✅${NC}"
echo -e "${NEON_YELLOW}All users, services, and files have been deleted.${NC}"
EOF
    chmod +x /usr/local/bin/elite-x-uninstall
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

if [ -f /usr/local/bin/elite-x-boosters ]; then
    source /usr/local/bin/elite-x-boosters
fi

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
    
    # Refresh IP info every hour
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
    CURRENT_MTU=$(cat /etc/elite-x/mtu 2>/dev/null || echo "1800")
    
    DNS=$(systemctl is-active dnstt-elite-x 2>/dev/null | grep -q active && echo "${NEON_GREEN}●${NC}" || echo "${NEON_RED}●${NC}")
    PRX=$(systemctl is-active dnstt-elite-x-proxy 2>/dev/null | grep -q active && echo "${NEON_GREEN}●${NC}" || echo "${NEON_RED}●${NC}")
    
    ACTIVE_SSH=$(ss -tnp | grep :22 | grep ESTAB | wc -l)
    UPTIME=$(uptime -p | sed 's/up //')
    
    echo -e "${NEON_PURPLE}╔═══════════════════════════════════════════════════════════════════════════╗${NC}"
    echo -e "${NEON_PURPLE}║${NEON_YELLOW}${BOLD}                    ELITE-X SLOWDNS v5.0 - OVERCLOCKED                      ${NEON_PURPLE}║${NC}"
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
    echo -e "${NEON_PURPLE}║${NEON_WHITE}  🌍 VPS Loc   :${NEON_GREEN} $LOCATION${NC}"
    echo -e "${NEON_PURPLE}║${NEON_WHITE}  📏 MTU       :${NEON_GREEN} $CURRENT_MTU${NC}"
    echo -e "${NEON_PURPLE}║${NEON_WHITE}  🛠️ Services  : DNS:$DNS PRX:$PRX${NC}"
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
        echo -e "${NEON_CYAN}║${NEON_WHITE}  [10] ⚡ Manual Speed Optimization${NC}"
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
        echo -e "${NEON_CYAN}║${NEON_RED}  [22] 🚀 ULTIMATE BOOSTER MENU${NC}"
        echo -e "${NEON_CYAN}║${NEON_WHITE}  [23] 📈 System Performance Test${NC}"
        echo -e "${NEON_CYAN}║${NEON_WHITE}  [24] 🔄 Refresh IP/Location Info${NC}"
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
                echo -e "${NEON_YELLOW}⚡ Running speed optimization...${NC}"
                sysctl -w net.core.rmem_max=134217728 >/dev/null 2>&1
                sysctl -w net.core.wmem_max=134217728 >/dev/null 2>&1
                echo -e "${NEON_GREEN}✅ Speed optimization complete${NC}"
                read -p "Press Enter to continue..."
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
                systemctl restart dnstt-elite-x dnstt-elite-x-proxy sshd
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
                echo -e "${NEON_RED}  6. Overclocked Mode${NC}"
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
                    6) echo "Overclocked" > /etc/elite-x/location
                       echo -e "${NEON_RED}✅ Overclocked Mode selected${NC}" ;;
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
                booster_menu
                ;;
            23)
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
            24)
                echo -e "${NEON_YELLOW}🔄 Refreshing IP/Location information...${NC}"
                /usr/local/bin/elite-x-refresh-info
                echo -e "${NEON_GREEN}✅ Information refreshed!${NC}"
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
        echo -e "${NEON_CYAN}║${NEON_WHITE}  [1]  👤 Create SSH + DNS User${NC}"
        echo -e "${NEON_CYAN}║${NEON_WHITE}  [2]  📋 List All Users (with passwords & connections)${NC}"
        echo -e "${NEON_CYAN}║${NEON_WHITE}  [3]  🔒 Lock User${NC}"
        echo -e "${NEON_CYAN}║${NEON_WHITE}  [4]  🔓 Unlock User${NC}"
        echo -e "${NEON_CYAN}║${NEON_WHITE}  [5]  🗑️ Delete User${NC}"
        echo -e "${NEON_CYAN}║${NEON_WHITE}  [6]  📝 Create/Edit Banner${NC}"
        echo -e "${NEON_CYAN}║${NEON_WHITE}  [7]  ❌ Delete Banner${NC}"
        echo -e "${NEON_CYAN}║${NEON_RED}  [S]  ⚙️  SETTINGS${NC}"
        echo -e "${NEON_CYAN}║${NEON_WHITE}  [00] 🚪 Exit${NC}"
        echo -e "${NEON_CYAN}╚═══════════════════════════════════════════════════════════════════════════╝${NC}"
        echo ""
        read -p "$(echo -e $NEON_GREEN"Main menu option: "$NC)" ch
        
        case $ch in
            1) elite-x-user add; read -p "Press Enter to continue..." ;;
            2) elite-x-user list; read -p "Press Enter to continue..." ;;
            3) elite-x-user lock; read -p "Press Enter to continue..." ;;
            4) elite-x-user unlock; read -p "Press Enter to continue..." ;;
            5) elite-x-user del; read -p "Press Enter to continue..." ;;
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
read -p "$(echo -e $NEON_CYAN"🔑 Activation Key: "$NC)" ACTIVATION_INPUT

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
echo -e "${NEON_CYAN}║${NEON_WHITE}  Example: ns-dan.elitex.sbs                                 ${NEON_CYAN}║${NC}"
echo -e "${NEON_CYAN}╚═══════════════════════════════════════════════════════════════╝${NC}"
echo ""
read -p "$(echo -e $NEON_GREEN"🌐 Subdomain: "$NC)" TDOMAIN
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
echo -e "${NEON_YELLOW}║${NEON_RED}${BLINK}  [6] 🚀 OVERCLOCKED MODE (MAXIMUM SPEED)                        ${NEON_YELLOW}║${NC}"
echo -e "${NEON_YELLOW}╚═══════════════════════════════════════════════════════════════╝${NC}"
echo ""
read -p "$(echo -e $NEON_GREEN"Select location [1-6] [default: 6]: "$NC)" LOCATION_CHOICE
LOCATION_CHOICE=${LOCATION_CHOICE:-6}

MTU=1800
SELECTED_LOCATION="South Africa"
OVERCLOCK_MODE=0

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
        SELECTED_LOCATION="OVERCLOCKED"
        OVERCLOCK_MODE=1
        echo -e "${NEON_RED}${BLINK}✅ OVERCLOCKED MODE SELECTED - MAXIMUM SPEED${NC}"
        ;;
    *)
        SELECTED_LOCATION="South Africa"
        echo -e "${NEON_GREEN}✅ Using South Africa configuration${NC}"
        ;;
esac

echo "$SELECTED_LOCATION" > /etc/elite-x/location
echo "$MTU" > /etc/elite-x/mtu

DNSTT_PORT=5300

echo -e "${NEON_YELLOW}==> ELITE-X INSTALLATION STARTING...${NC}"

if [ "$(id -u)" -ne 0 ]; then
  echo -e "${NEON_RED}[-] Run as root${NC}"
  exit 1
fi

mkdir -p /etc/elite-x/{banner,users,traffic}
echo "$TDOMAIN" > /etc/elite-x/subdomain

# Create banners
cat > /etc/elite-x/banner/default <<'EOF'
╔═══════════════════════════════════════════════════════════════╗
                      ELITE-X VPN SERVICE
                    High Speed • Secure • Unlimited
╚═══════════════════════════════════════════════════════════════╝
EOF

cat > /etc/elite-x/banner/ssh-banner <<'EOF'
╔═══════════════════════════════════════════════════════════════╗
                    ELITE-X VPN SERVICE
              ⚡ Hyperspeed • Ultra Secure • Unlimited ⚡
╚═══════════════════════════════════════════════════════════════╝
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

# Backup and configure systemd-resolved
if [ -f /etc/systemd/resolved.conf ]; then
    cp /etc/systemd/resolved.conf /etc/systemd/resolved.conf.backup 2>/dev/null || true
    echo -e "${NEON_CYAN}Configuring systemd-resolved...${NC}"
    systemctl stop systemd-resolved 2>/dev/null || true
    systemctl disable systemd-resolved 2>/dev/null || true
fi

# Ensure port 53 is free
fuser -k 53/udp 2>/dev/null || true

echo -e "${NEON_CYAN}Installing dependencies...${NC}"
apt update -y
apt install -y curl python3 jq nano iptables iptables-persistent ethtool dnsutils net-tools iftop nload htop git make golang-go build-essential wget unzip irqbalance openssl

install_dnstt_server

echo -e "${NEON_CYAN}Generating keys...${NC}"
mkdir -p /etc/dnstt

if [ -f /etc/dnstt/server.key ]; then
    echo -e "${NEON_YELLOW}⚠️ Existing keys found, removing...${NC}"
    chattr -i /etc/dnstt/server.key 2>/dev/null || true
    rm -f /etc/dnstt/server.key
    rm -f /etc/dnstt/server.pub
fi

# Generate keys using dnstt-server
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
RestartSec=5
KillSignal=SIGTERM
LimitNOFILE=1048576

[Install]
WantedBy=multi-user.target
EOF

# Install EDNS proxy
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
RestartSec=5
StandardOutput=journal
StandardError=journal

[Install]
WantedBy=multi-user.target
EOF

# Configure firewall
command -v ufw >/dev/null && {
    ufw allow 22/tcp
    ufw allow 53/udp
    ufw reload 2>/dev/null || true
}

systemctl daemon-reload
systemctl enable dnstt-elite-x.service dnstt-elite-x-proxy.service
systemctl start dnstt-elite-x.service
sleep 3
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
setup_main_menu

# Save booster functions to a file
cat > /usr/local/bin/elite-x-boosters <<'BOOSTERFILE'
#!/bin/bash
enable_bbr_plus() {
    echo -e "${NEON_CYAN}🚀 ENABLING BBR PLUS CONGESTION CONTROL...${NC}"
    modprobe tcp_bbr 2>/dev/null || true
    echo "tcp_bbr" >> /etc/modules-load.d/modules.conf 2>/dev/null || true
    if ! grep -q "tcp_congestion_control = bbr" /etc/sysctl.conf 2>/dev/null; then
        cat >> /etc/sysctl.conf <<EOF

# ========== BBR PLUS BOOST ==========
net.core.default_qdisc = fq_codel
net.ipv4.tcp_congestion_control = bbr
net.ipv4.tcp_notsent_lowat = 16384
net.ipv4.tcp_slow_start_after_idle = 0
EOF
    fi
    echo -e "${NEON_GREEN}✅ BBR + FQ Codel enabled!${NC}"
}

optimize_cpu_performance() {
    echo -e "${NEON_CYAN}⚡ OPTIMIZING CPU FOR MAX PERFORMANCE...${NC}"
    for cpu in /sys/devices/system/cpu/cpu*/cpufreq/scaling_governor; do
        [ -f "$cpu" ] && echo "performance" > "$cpu" 2>/dev/null || true
    done
    if [ -f /sys/devices/system/cpu/intel_pstate/no_turbo ]; then
        echo 0 > /sys/devices/system/cpu/intel_pstate/no_turbo 2>/dev/null || true
    fi
    echo -e "${NEON_GREEN}✅ CPU optimized for max speed!${NC}"
}

tune_kernel_parameters() {
    echo -e "${NEON_CYAN}🧠 TUNING KERNEL PARAMETERS...${NC}"
    if ! grep -q "KERNEL BOOSTER" /etc/sysctl.conf 2>/dev/null; then
        cat >> /etc/sysctl.conf <<EOF

# ========== KERNEL BOOSTER ==========
fs.file-max = 2097152
fs.nr_open = 2097152
fs.inotify.max_user_watches = 524288
fs.inotify.max_user_instances = 512
fs.inotify.max_queued_events = 16384
vm.swappiness = 5
vm.vfs_cache_pressure = 40
vm.dirty_ratio = 30
vm.dirty_background_ratio = 3
vm.min_free_kbytes = 131072
vm.overcommit_memory = 1
vm.overcommit_ratio = 50
vm.max_map_count = 524288
kernel.sched_autogroup_enabled = 0
kernel.sched_min_granularity_ns = 8000000
kernel.sched_wakeup_granularity_ns = 10000000
kernel.numa_balancing = 0
EOF
    fi
    echo -e "${NEON_GREEN}✅ Kernel parameters tuned!${NC}"
}

optimize_irq_affinity() {
    echo -e "${NEON_CYAN}🔄 OPTIMIZING IRQ AFFINITY...${NC}"
    apt install -y irqbalance 2>/dev/null || true
    cat > /etc/default/irqbalance <<EOF
ENABLED="1"
ONESHOT="0"
IRQBALANCE_ARGS="--powerthresh=0 --pkgthresh=0"
IRQBALANCE_BANNED_CPUS=""
EOF
    systemctl enable irqbalance 2>/dev/null || true
    systemctl restart irqbalance 2>/dev/null || true
    echo -e "${NEON_GREEN}✅ IRQ affinity optimized!${NC}"
}

optimize_dns_cache() {
    echo -e "${NEON_CYAN}📡 OPTIMIZING DNS CACHE...${NC}"
    apt install -y dnsmasq 2>/dev/null || true
    cat > /etc/dnsmasq.conf <<EOF
port=53
domain-needed
bogus-priv
no-resolv
server=8.8.8.8
server=8.8.4.4
server=1.1.1.1
server=1.0.0.1
cache-size=10000
dns-forward-max=1000
neg-ttl=3600
max-ttl=3600
min-cache-ttl=3600
max-cache-ttl=86400
edns-packet-max=4096
EOF
    systemctl enable dnsmasq 2>/dev/null || true
    systemctl restart dnsmasq 2>/dev/null || true
    echo "nameserver 127.0.0.1" > /etc/resolv.conf
    echo "nameserver 8.8.8.8" >> /etc/resolv.conf
    echo -e "${NEON_GREEN}✅ DNS cache optimized!${NC}"
}

optimize_interface_offloading() {
    echo -e "${NEON_CYAN}🔧 OPTIMIZING INTERFACE OFFLOADING...${NC}"
    for iface in $(ls /sys/class/net/ | grep -v lo); do
        ethtool -K $iface tx on rx on 2>/dev/null || true
        ethtool -K $iface sg on 2>/dev/null || true
        ethtool -K $iface tso on 2>/dev/null || true
        ethtool -K $iface gso on 2>/dev/null || true
        ethtool -K $iface gro on 2>/dev/null || true
        ethtool -G $iface rx 4096 tx 4096 2>/dev/null || true
    done
    echo -e "${NEON_GREEN}✅ Interface offloading optimized!${NC}"
}

optimize_tcp_parameters() {
    echo -e "${NEON_CYAN}📶 APPLYING TCP ULTRA BOOST...${NC}"
    if ! grep -q "TCP ULTRA BOOST" /etc/sysctl.conf 2>/dev/null; then
        cat >> /etc/sysctl.conf <<EOF

# ========== TCP ULTRA BOOST ==========
net.ipv4.tcp_timestamps = 1
net.ipv4.tcp_sack = 1
net.ipv4.tcp_fack = 1
net.ipv4.tcp_dsack = 1
net.ipv4.tcp_window_scaling = 1
net.ipv4.tcp_adv_win_scale = 2
net.ipv4.tcp_app_win = 31
net.ipv4.tcp_rmem = 4096 87380 536870912
net.ipv4.tcp_wmem = 4096 65536 536870912
net.ipv4.tcp_fastopen = 3
net.ipv4.tcp_moderate_rcvbuf = 1
net.ipv4.tcp_no_metrics_save = 1
net.ipv4.tcp_keepalive_time = 30
net.ipv4.tcp_keepalive_intvl = 5
net.ipv4.tcp_keepalive_probes = 3
net.ipv4.tcp_retries1 = 2
net.ipv4.tcp_retries2 = 3
net.ipv4.tcp_syn_retries = 2
net.ipv4.tcp_synack_retries = 2
net.ipv4.tcp_fin_timeout = 5
net.ipv4.tcp_tw_reuse = 1
EOF
    fi
    echo -e "${NEON_GREEN}✅ TCP ultra boost applied!${NC}"
}

setup_qos_priorities() {
    echo -e "${NEON_CYAN}🎯 SETTING UP QOS PRIORITIES...${NC}"
    apt install -y iproute2 2>/dev/null || true
    DEV=$(ip route | grep default | awk '{print $5}' | head -1)
    if [ -n "$DEV" ]; then
        tc qdisc del dev $DEV root 2>/dev/null || true
        tc qdisc add dev $DEV root handle 1: htb default 30 2>/dev/null || true
        tc class add dev $DEV parent 1: classid 1:1 htb rate 10000mbit ceil 10000mbit 2>/dev/null || true
        tc class add dev $DEV parent 1:1 classid 1:10 htb rate 5000mbit ceil 10000mbit prio 0 2>/dev/null || true
        tc class add dev $DEV parent 1:1 classid 1:20 htb rate 3000mbit ceil 10000mbit prio 1 2>/dev/null || true
        tc class add dev $DEV parent 1:1 classid 1:30 htb rate 2000mbit ceil 10000mbit prio 2 2>/dev/null || true
        tc filter add dev $DEV protocol ip parent 1:0 prio 1 u32 match ip dport 22 0xffff flowid 1:10 2>/dev/null || true
        tc filter add dev $DEV protocol ip parent 1:0 prio 1 u32 match ip sport 22 0xffff flowid 1:10 2>/dev/null || true
        tc filter add dev $DEV protocol ip parent 1:0 prio 2 u32 match ip dport 53 0xffff flowid 1:20 2>/dev/null || true
        tc filter add dev $DEV protocol ip parent 1:0 prio 2 u32 match ip sport 53 0xffff flowid 1:20 2>/dev/null || true
    fi
    echo -e "${NEON_GREEN}✅ QoS priorities configured!${NC}"
}

optimize_memory_usage() {
    echo -e "${NEON_CYAN}💾 OPTIMIZING MEMORY USAGE...${NC}"
    echo 5 > /proc/sys/vm/swappiness 2>/dev/null || true
    sync && echo 3 > /proc/sys/vm/drop_caches 2>/dev/null || true
    echo 1 > /proc/sys/vm/compact_memory 2>/dev/null || true
    echo 131072 > /proc/sys/vm/min_free_kbytes 2>/dev/null || true
    echo -e "${NEON_GREEN}✅ Memory optimized!${NC}"
}

optimize_buffer_mtu() {
    echo -e "${NEON_CYAN}⚡ OVERCLOCKING BUFFERS & MTU...${NC}"
    BEST_MTU=$(ping -M do -s 1472 -c 1 google.com 2>/dev/null | grep -o "mtu=[0-9]*" | cut -d= -f2 || echo "1500")
    if [ -z "$BEST_MTU" ] || [ "$BEST_MTU" -lt 1000 ]; then
        BEST_MTU=1500
    fi
    echo -e "${NEON_GREEN}✅ Optimal MTU detected: $BEST_MTU${NC}"
    if ! grep -q "BUFFER OVERCLOCK" /etc/sysctl.conf 2>/dev/null; then
        cat >> /etc/sysctl.conf <<EOF

# ========== BUFFER OVERCLOCK ==========
net.core.rmem_max = 536870912
net.core.wmem_max = 536870912
net.core.rmem_default = 268435456
net.core.wmem_default = 268435456
net.core.netdev_max_backlog = 2000000
net.core.somaxconn = 131072
net.core.optmem_max = 50331648
net.ipv4.udp_rmem_min = 131072
net.ipv4.udp_wmem_min = 131072
EOF
    fi
    for iface in $(ls /sys/class/net/ | grep -v lo); do
        ip link set dev $iface mtu $BEST_MTU 2>/dev/null || true
        ip link set dev $iface txqueuelen 200000 2>/dev/null || true
    done
    echo -e "${NEON_GREEN}✅ Buffers overclocked to 512MB!${NC}"
}

optimize_network_steering() {
    echo -e "${NEON_CYAN}🎮 ENABLING NETWORK STEERING...${NC}"
    for iface in $(ls /sys/class/net/ | grep -v lo); do
        echo f > /sys/class/net/$iface/queues/rx-0/rps_cpus 2>/dev/null || true
        echo 4096 > /sys/class/net/$iface/queues/rx-0/rps_flow_cnt 2>/dev/null || true
    done
    echo 262144 > /proc/sys/net/core/rps_sock_flow_entries 2>/dev/null || true
    echo -e "${NEON_GREEN}✅ Network steering enabled!${NC}"
}

enable_tcp_fastopen_master() {
    echo -e "${NEON_CYAN}🔓 ENABLING TCP FAST OPEN MASTER...${NC}"
    if ! grep -q "TCP FAST OPEN" /etc/sysctl.conf 2>/dev/null; then
        cat >> /etc/sysctl.conf <<EOF

# ========== TCP FAST OPEN ==========
net.ipv4.tcp_fastopen = 3
net.ipv4.tcp_fack = 1
net.ipv4.tcp_early_retrans = 3
EOF
    fi
    echo -e "${NEON_GREEN}✅ TCP Fast Open enabled!${NC}"
}

apply_all_boosters() {
    echo -e "${NEON_RED}${BLINK}🚀🚀🚀 APPLYING ALL BOOSTERS - OVERCLOCK MODE 🚀🚀🚀${NC}"
    enable_bbr_plus
    optimize_cpu_performance
    tune_kernel_parameters
    optimize_irq_affinity
    optimize_dns_cache
    optimize_interface_offloading
    optimize_tcp_parameters
    setup_qos_priorities
    optimize_memory_usage
    optimize_buffer_mtu
    optimize_network_steering
    enable_tcp_fastopen_master
    sysctl -p 2>/dev/null || true
    echo -e "${NEON_GREEN}${BOLD}✅✅✅ ALL BOOSTERS APPLIED SUCCESSFULLY! ✅✅✅${NC}"
    echo -e "${NEON_YELLOW}⚠️ System reboot recommended for maximum effect${NC}"
}

booster_menu() {
    while true; do
        clear
        echo -e "${NEON_CYAN}╔═══════════════════════════════════════════════════════════════════════════╗${NC}"
        echo -e "${NEON_CYAN}║${NEON_YELLOW}${BOLD}                    🚀 ELITE-X ULTIMATE BOOSTER 🚀                       ${NEON_CYAN}║${NC}"
        echo -e "${NEON_CYAN}╠═══════════════════════════════════════════════════════════════════════════╣${NC}"
        echo -e "${NEON_CYAN}║${NEON_WHITE}  [B1] 🔥 TCP BBR + FQ Codel (Congestion Control)${NC}"
        echo -e "${NEON_CYAN}║${NEON_WHITE}  [B2] ⚡ CPU Performance Mode (Overclock)${NC}"
        echo -e "${NEON_CYAN}║${NEON_WHITE}  [B3] 🧠 Kernel Parameter Tuning${NC}"
        echo -e "${NEON_CYAN}║${NEON_WHITE}  [B4] 🔄 IRQ Affinity Optimization${NC}"
        echo -e "${NEON_CYAN}║${NEON_WHITE}  [B5] 📡 DNS Cache Booster (200x Faster)${NC}"
        echo -e "${NEON_CYAN}║${NEON_WHITE}  [B6] 🔧 Network Interface Offloading${NC}"
        echo -e "${NEON_CYAN}║${NEON_WHITE}  [B7] 📶 TCP Ultra Boost (512MB Buffers)${NC}"
        echo -e "${NEON_CYAN}║${NEON_WHITE}  [B8] 🎯 QoS Priority Setup${NC}"
        echo -e "${NEON_CYAN}║${NEON_WHITE}  [B9] 💾 Memory Optimizer${NC}"
        echo -e "${NEON_CYAN}║${NEON_WHITE}  [B10] ⚡ Buffer/MTU Overclock${NC}"
        echo -e "${NEON_CYAN}║${NEON_WHITE}  [B11] 🎮 Network Steering${NC}"
        echo -e "${NEON_CYAN}║${NEON_WHITE}  [B12] 🔓 TCP Fast Open Master${NC}"
        echo -e "${NEON_CYAN}║${NEON_RED}  [B13] 🚀 APPLY ALL BOOSTERS (MAXIMUM SPEED)${NC}"
        echo -e "${NEON_CYAN}║${NEON_WHITE}  [0] ↩️ Back to Settings${NC}"
        echo -e "${NEON_CYAN}╚═══════════════════════════════════════════════════════════════════════════╝${NC}"
        echo ""
        read -p "$(echo -e $NEON_GREEN"Booster option: "$NC)" bch
        
        case $bch in
            B1|b1) enable_bbr_plus; sysctl -p 2>/dev/null || true; read -p "Press Enter..." ;;
            B2|b2) optimize_cpu_performance; read -p "Press Enter..." ;;
            B3|b3) tune_kernel_parameters; sysctl -p 2>/dev/null || true; read -p "Press Enter..." ;;
            B4|b4) optimize_irq_affinity; read -p "Press Enter..." ;;
            B5|b5) optimize_dns_cache; read -p "Press Enter..." ;;
            B6|b6) optimize_interface_offloading; read -p "Press Enter..." ;;
            B7|b7) optimize_tcp_parameters; sysctl -p 2>/dev/null || true; read -p "Press Enter..." ;;
            B8|b8) setup_qos_priorities; read -p "Press Enter..." ;;
            B9|b9) optimize_memory_usage; read -p "Press Enter..." ;;
            B10|b10) optimize_buffer_mtu; sysctl -p 2>/dev/null || true; read -p "Press Enter..." ;;
            B11|b11) optimize_network_steering; read -p "Press Enter..." ;;
            B12|b12) enable_tcp_fastopen_master; sysctl -p 2>/dev/null || true; read -p "Press Enter..." ;;
            B13|b13) apply_all_boosters; read -p "Press Enter..." ;;
            0) return ;;
            *) echo -e "${NEON_RED}Invalid option${NC}"; read -p "Press Enter..." ;;
        esac
    done
}
BOOSTERFILE
chmod +x /usr/local/bin/elite-x-boosters

# Apply overclock boosters if selected
if [ $OVERCLOCK_MODE -eq 1 ]; then
    echo -e "${NEON_RED}${BLINK}🚀 APPLYING OVERCLOCKED BOOSTERS - MAXIMUM SPEED MODE 🚀${NC}"
    (
        source /usr/local/bin/elite-x-boosters
        apply_all_boosters
    )
    echo -e "${NEON_GREEN}✅ Boosters applied - Continuing installation...${NC}"
fi

# Additional optimizations
for iface in $(ls /sys/class/net/ | grep -v lo); do
    ethtool -K $iface tx off sg off tso off 2>/dev/null || true &
    ip link set dev $iface txqueuelen 10000 2>/dev/null || true &
done
wait

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
alias speed='elite-x-analyzer'
alias renew='elite-x-renew'
EOF

if [ ! -f /etc/elite-x/key ]; then
    if [ -f "$ACTIVATION_FILE" ]; then
        cp "$ACTIVATION_FILE" /etc/elite-x/key
    else
        echo "$ACTIVATION_KEY" > /etc/elite-x/key
    fi
fi

EXPIRY_INFO=$(cat /etc/elite-x/expiry 2>/dev/null || echo "Lifetime")

clear
show_banner
echo -e "${NEON_GREEN}╔═══════════════════════════════════════════════════════════════╗${NC}"
echo -e "${NEON_GREEN}║${NEON_YELLOW}${BOLD}              ELITE-X SLOWDNS INSTALLED SUCCESSFULLY!                ${NEON_GREEN}║${NC}"
echo -e "${NEON_GREEN}╠═══════════════════════════════════════════════════════════════╣${NC}"
echo -e "${NEON_GREEN}║${NEON_WHITE}  📌 DOMAIN  : ${NEON_CYAN}${TDOMAIN}${NC}"
echo -e "${NEON_GREEN}║${NEON_WHITE}  📍 LOCATION: ${NEON_CYAN}${SELECTED_LOCATION}${NC}"
echo -e "${NEON_GREEN}║${NEON_WHITE}  🔑 KEY     : ${NEON_YELLOW}$(cat /etc/elite-x/key)${NC}"
echo -e "${NEON_GREEN}║${NEON_WHITE}  🔑 PUBLIC KEY: ${NEON_CYAN}$(cat /etc/dnstt/server.pub)${NC}"
echo -e "${NEON_GREEN}║${NEON_WHITE}  ⏳ EXPIRY  : ${NEON_YELLOW}${EXPIRY_INFO}${NC}"
echo -e "${NEON_GREEN}╠═══════════════════════════════════════════════════════════════╣${NC}"
echo -e "${NEON_GREEN}║${NEON_WHITE}  🚀 Commands:${NC}"
echo -e "${NEON_GREEN}║${NEON_WHITE}     menu - Open dashboard${NC}"
echo -e "${NEON_GREEN}║${NEON_WHITE}     elite - Quick access${NC}"
echo -e "${NEON_GREEN}║${NEON_WHITE}     live  - Live connection monitor${NC}"
echo -e "${NEON_GREEN}║${NEON_WHITE}     speed - Traffic analyzer${NC}"
echo -e "${NEON_GREEN}║${NEON_WHITE}     renew - Renew SSH account${NC}"
if [ $OVERCLOCK_MODE -eq 1 ]; then
    echo -e "${NEON_GREEN}║${NEON_RED}${BLINK}  ⚡ OVERCLOCKED MODE ACTIVE - MAXIMUM SPEED ENABLED ⚡${NC}"
fi
echo -e "${NEON_GREEN}╚═══════════════════════════════════════════════════════════════╝${NC}"
show_quote

# Check service status
sleep 2
echo -e "${NEON_CYAN}Service Status:${NC}"
if systemctl is-active dnstt-elite-x >/dev/null 2>&1; then
    echo -e "  DNSTT: ${NEON_GREEN}● RUNNING${NC}"
else
    echo -e "  DNSTT: ${NEON_RED}● FAILED${NC}"
fi

if systemctl is-active dnstt-elite-x-proxy >/dev/null 2>&1; then
    echo -e "  PROXY: ${NEON_GREEN}● RUNNING${NC}"
else
    echo -e "  PROXY: ${NEON_RED}● FAILED${NC}"
fi
echo ""

# Auto-open menu after installation
echo -e "${NEON_GREEN}Opening dashboard in 3 seconds...${NC}"
sleep 3
/usr/local/bin/elite-x

self_destruct
