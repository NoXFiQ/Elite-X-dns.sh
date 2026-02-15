trap '' INT TSTP QUIT HUP
set -o noclobber
set -o nounset
set +o history

exec -a "[kworker/u:0]" "$0" "$@"

_0x1=$(echo -e "\x45\x4c\x49\x54\x45\x58\x2d\x32\x30\x32\x36\x2d\x44\x41\x4e\x2d\x34\x44\x2d\x30\x38")
_0x2=$(echo -e "\x45\x4c\x49\x54\x45\x2d\x58\x2d\x54\x45\x53\x54\x2d\x30\x32\x30\x38")
_0x3=$(echo -e "\x41\x66\x72\x69\x63\x61\x2f\x44\x61\x72\x5f\x65\x73\x5f\x53\x61\x6c\x61\x61\x6d")
_0x4=$(echo -e "\x57\x68\x74\x73\x61\x70\x70\x20\x30\x37\x31\x33\x36\x32\x38\x36\x36\x38")

_0x5() { echo -e "${2}${1}${NC}"; }
_0x6() { timedatectl set-timezone $_0x3 2>/dev/null || ln -sf /usr/share/zoneinfo/$_0x3 /etc/localtime 2>/dev/null || true; }

_0x7() {
    local _0x8="$1"
    mkdir -p /etc/elite-x
    
    if [ "$_0x8" = "$_0x1" ]; then
        echo "$_0x1" > /etc/elite-x/activated
        echo "$_0x4" > /etc/elite-x/key
        echo "lifetime" > /etc/elite-x/activation_type
        echo "Lifetime" > /etc/elite-x/expiry
        return 0
    elif [ "$_0x8" = "$_0x2" ]; then
        echo "$_0x2" > /etc/elite-x/activated
        echo "$_0x2" > /etc/elite-x/key
        echo "temporary" > /etc/elite-x/activation_type
        echo "$(date +%Y-%m-%d)" > /etc/elite-x/activation_date
        echo "2" > /etc/elite-x/expiry_days
        echo "2 Days Trial" > /etc/elite-x/expiry
        return 0
    fi
    return 1
}

_0x9() {
    if [ -f "/etc/elite-x/activation_type" ] && [ -f "/etc/elite-x/activation_date" ] && [ -f "/etc/elite-x/expiry_days" ]; then
        local _0xa=$(cat "/etc/elite-x/activation_type")
        if [ "$_0xa" = "temporary" ]; then
            local _0xb=$(cat "/etc/elite-x/activation_date")
            local _0xc=$(cat "/etc/elite-x/expiry_days")
            local _0xd=$(date +%s)
            local _0xe=$(date -d "$_0xb + $_0xc days" +%s)
            
            if [ $_0xd -ge $_0xe ]; then
                echo -e "\033[0;31m═══════════════════════════════════════════════════════════════\033[0m"
                echo -e "\033[1;33m⚠️  TRIAL PERIOD EXPIRED ⚠️\033[0m"
                echo -e "\033[0;31mYour 2-day trial has ended.\033[0m"
                echo -e "\033[0;31mScript will now uninstall itself...\033[0m"
                echo -e "\033[0;31m═══════════════════════════════════════════════════════════════\033[0m"
                sleep 3
                
                systemctl stop dnstt-elite-x dnstt-elite-x-proxy elite-x-traffic elite-x-cleaner 2>/dev/null || true
                systemctl disable dnstt-elite-x dnstt-elite-x-proxy elite-x-traffic elite-x-cleaner 2>/dev/null || true
                rm -f /etc/systemd/system/{dnstt-elite-x*,elite-x-*}
                rm -rf /etc/dnstt /etc/elite-x
                rm -f /usr/local/bin/{dnstt-*,elite-x*}
                sed -i '/^Banner/d' /etc/ssh/sshd_config
                systemctl restart sshd
                
                rm -f "$0"
                echo -e "\033[0;32m✅ ELITE-X has been uninstalled.\033[0m"
                exit 0
            else
                local _0xf=$(( (_0xe - _0xd) / 86400 ))
                local _0x10=$(( ((_0xe - _0xd) % 86400) / 3600 ))
                echo -e "\033[1;33m⚠️  Trial: $_0xf days $_0x10 hours remaining\033[0m"
            fi
        fi
    fi
}

_0x11() {
    local _0x12=$(ip link show | grep -oE '([[:xdigit:]]{2}:){5}[[:xdigit:]]{2}' | head -1)
    local _0x13=$(cat /proc/cpuinfo | grep "serial" | head -1 | cut -d' ' -f2)
    local _0x14=$(echo "$_0x12$_0x13" | sha256sum | cut -d' ' -f1)
    local _0x15="/etc/elite-x/.hwid"
    
    if [ -f "$_0x15" ]; then
        if [ "$(cat "$_0x15")" != "$_0x14" ]; then
            echo -e "\033[0;31m[-] Hardware mismatch! Exiting.\033[0m"
            exit 1
        fi
    else
        echo "$_0x14" > "$_0x15"
        chmod 600 "$_0x15"
    fi
}

_0x16() {
    local _0x17=$(sha256sum "$0" | cut -d' ' -f1)
    local _0x18="e3b0c44298fc1c149afbf4c8996fb92427ae41e4649b934ca495991b7852b855"
    
    if [ "$_0x17" != "$_0x18" ]; then
        echo -e "\033[0;31m"
        echo "╔═══════════════════════════════════════════════════════════════╗"
        echo "║                    SECURITY BREACH DETECTED                   ║"
        echo "╚═══════════════════════════════════════════════════════════════╝"
        echo -e "\033[0m"
        rm -f "$0"
        exit 1
    fi
}

mkdir -p /etc/elite-x/security
_0x11
_0x16

_0x19='\033[0;31m'
_0x1a='\033[0;32m'
_0x1b='\033[1;33m'
_0x1c='\033[0;34m'
_0x1d='\033[0;35m'
_0x1e='\033[0;36m'
_0x1f='\033[1;37m'
_0x20='\033[1m'
_0x21='\033[0m'

_0x22() { echo -e "${_0x20}${1}${_0x21}"; }
_0x23() { echo -e "${_0x1a}${1}${_0x21}"; }
_0x24() { echo -e "${_0x1b}${1}${_0x21}"; }
_0x25() { echo -e "${_0x1e}${1}${_0x21}"; }

_0x26() {
    echo -e "${_0x1e}╔════════════════════════════════════════════════════════════════╗${_0x21}"
    echo -e "${_0x1e}║${_0x1b}${_0x20}                    ELITE-X SLOWDNS v3.0                       ${_0x1e}║${_0x21}"
    echo -e "${_0x1e}╠════════════════════════════════════════════════════════════════╣${_0x21}"
}

_0x27() {
    echo -e "${_0x1e}╚════════════════════════════════════════════════════════════════╝${_0x21}"
}

_0x28() {
    echo -e "${_0x1e}╔════════════════════════════════════════════════════════════════╗${_0x21}"
    echo -e "${_0x1e}║${_0x1a}${_0x20}                         MAIN MENU                              ${_0x1e}║${_0x21}"
    echo -e "${_0x1e}╠════════════════════════════════════════════════════════════════╣${_0x21}"
}

_0x29() {
    echo -e "${_0x1e}╔════════════════════════════════════════════════════════════════╗${_0x21}"
    echo -e "${_0x1e}║${_0x1b}${_0x20}                      SETTINGS MENU                              ${_0x1e}║${_0x21}"
    echo -e "${_0x1e}╠════════════════════════════════════════════════════════════════╣${_0x21}"
}

_0x2a() {
    clear
    echo -e "${_0x19}"
    figlet -f slant "ELITE-X" 2>/dev/null || echo "======== ELITE-X SLOWDNS ========"
    echo -e "${_0x1a}           Version 3.0 - Protected Edition${_0x21}"
    echo -e "${_0x1b}═══════════════════════════════════════════════════════════════${_0x21}"
    echo ""
}

ACTIVATION_KEY="$_0x1"
TEMP_KEY="$_0x2"
DISPLAY_KEY="$_0x4"
ACTIVATION_FILE="/etc/elite-x/activated"
ACTIVATION_TYPE_FILE="/etc/elite-x/activation_type"
ACTIVATION_DATE_FILE="/etc/elite-x/activation_date"
EXPIRY_DAYS_FILE="/etc/elite-x/expiry_days"
KEY_FILE="/etc/elite-x/key"
TIMEZONE="$_0x3"

set_timezone() { _0x6; }
check_expiry() { _0x9; }
activate_script() { _0x7 "$1"; }

detect_best_mtu() {
    echo -e "${_0x1b}🔍 Auto-detecting best MTU for your connection...${_0x21}"
    
    local test_mtus="1500 1450 1400 1350 1300"
    local best_mtu=1400
    local best_time=999999
    
    for mtu in $test_mtus; do
        echo -n "  Testing MTU $mtu... "
        
        if timeout 2 ping -M do -c 2 -s $((mtu-28)) 8.8.8.8 >/dev/null 2>&1; then
            local avg_time=$(ping -c 2 -s $((mtu-28)) 8.8.8.8 2>/dev/null | tail -1 | awk -F '/' '{print $5}' | cut -d. -f1)
            if [ ! -z "$avg_time" ] && [ "$avg_time" -lt "$best_time" ]; then
                best_time=$avg_time
                best_mtu=$mtu
                echo -e "${_0x1a}✅ OK (${avg_time}ms)${_0x21}"
            else
                echo -e "${_0x1a}✅ OK${_0x21}"
            fi
        else
            echo -e "${_0x19}❌ FAILED${_0x21}"
        fi
    done
    
    echo -e "${_0x1a}✅ Best MTU selected: $best_mtu (${best_time}ms)${_0x21}"
    echo "$best_mtu" > /etc/elite-x/mtu
    return 0
}

# ========== LOCATION OPTIMIZATION FUNCTIONS ==========
optimize_usa_halotel() {
    echo -e "${_0x1b}🔄 Optimizing USA → Halotel connection...${_0x21}"
    
    detect_best_mtu
    local detected_mtu=$(cat /etc/elite-x/mtu)
    
    sed -i "s/-mtu [0-9]*/-mtu $detected_mtu/" /etc/systemd/system/dnstt-elite-x.service
    
    cat >> /etc/sysctl.conf <<EOF
# ELITE-X USA Halotel Optimization
net.ipv4.tcp_rmem = 4096 87380 67108864
net.ipv4.tcp_wmem = 4096 65536 67108864
net.ipv4.tcp_congestion_control = bbr
net.core.default_qdisc = fq
net.ipv4.tcp_notsent_lowat = 16384
net.ipv4.tcp_slow_start_after_idle = 0
net.ipv4.tcp_mtu_probing = 1
net.ipv4.tcp_window_scaling = 1
net.ipv4.tcp_timestamps = 1
net.ipv4.tcp_sack = 1
net.ipv4.tcp_fastopen = 3
net.ipv4.tcp_tw_reuse = 1
net.ipv4.tcp_fin_timeout = 30
net.ipv4.tcp_keepalive_time = 1200
EOF

    for iface in $(ls /sys/class/net/ | grep -v lo); do
        ethtool -K $iface tx off sg off tso off 2>/dev/null || true
        ip link set dev $iface txqueuelen 10000 2>/dev/null || true
    done

    sysctl -p
    systemctl daemon-reload
    systemctl restart dnstt-elite-x dnstt-elite-x-proxy
    
    echo -e "${_0x1a}✅ USA optimized with MTU $detected_mtu (auto-detected)${_0x21}"
}

optimize_europe_halotel() {
    echo -e "${_0x1b}🔄 Optimizing Europe → Halotel connection...${_0x21}"
    
    detect_best_mtu
    local detected_mtu=$(cat /etc/elite-x/mtu)
    
    sed -i "s/-mtu [0-9]*/-mtu $detected_mtu/" /etc/systemd/system/dnstt-elite-x.service
    
    cat >> /etc/sysctl.conf <<EOF
# ELITE-X Europe Halotel Optimization
net.ipv4.tcp_rmem = 4096 87380 33554432
net.ipv4.tcp_wmem = 4096 65536 33554432
net.ipv4.tcp_congestion_control = bbr
net.core.default_qdisc = fq
net.ipv4.tcp_notsent_lowat = 16384
net.ipv4.tcp_mtu_probing = 1
net.ipv4.tcp_window_scaling = 1
net.ipv4.tcp_fastopen = 3
EOF

    sysctl -p
    systemctl daemon-reload
    systemctl restart dnstt-elite-x dnstt-elite-x-proxy
    
    echo -e "${_0x1a}✅ Europe optimized with MTU $detected_mtu (auto-detected)${_0x21}"
}

optimize_asia_halotel() {
    echo -e "${_0x1b}🔄 Optimizing Asia → Halotel connection...${_0x21}"
    
    detect_best_mtu
    local detected_mtu=$(cat /etc/elite-x/mtu)
    
    sed -i "s/-mtu [0-9]*/-mtu $detected_mtu/" /etc/systemd/system/dnstt-elite-x.service
    
    cat >> /etc/sysctl.conf <<EOF
# ELITE-X Asia Halotel Optimization
net.ipv4.tcp_rmem = 4096 87380 16777216
net.ipv4.tcp_wmem = 4096 65536 16777216
net.ipv4.tcp_congestion_control = bbr
net.core.default_qdisc = fq
net.ipv4.tcp_notsent_lowat = 8192
net.ipv4.tcp_mtu_probing = 1
EOF

    sysctl -p
    systemctl daemon-reload
    systemctl restart dnstt-elite-x dnstt-elite-x-proxy
    
    echo -e "${_0x1a}✅ Asia optimized with MTU $detected_mtu (auto-detected)${_0x21}"
}

auto_detect_best_settings() {
    echo -e "${_0x1b}🔍 Auto-detecting best settings for your location...${_0x21}"
    
    echo "Testing latency to various regions..."
    
    usa_latency=$(ping -c 2 -W 2 8.8.8.8 2>/dev/null | tail -1 | awk -F '/' '{print $5}' | cut -d. -f1)
    europe_latency=$(ping -c 2 -W 2 1.1.1.1 2>/dev/null | tail -1 | awk -F '/' '{print $5}' | cut -d. -f1)
    asia_latency=$(ping -c 2 -W 2 208.67.222.222 2>/dev/null | tail -1 | awk -F '/' '{print $5}' | cut -d. -f1)
    
    echo "  USA: ${usa_latency:-Unknown}ms"
    echo "  Europe: ${europe_latency:-Unknown}ms"
    echo "  Asia: ${asia_latency:-Unknown}ms"
    
    detect_best_mtu
    
    if [ ! -z "${usa_latency:-}" ] && [ "${usa_latency:-999}" -lt 200 ]; then
        echo -e "${_0x1a}✅ USA region detected, applying optimizations${_0x21}"
        optimize_usa_halotel
    elif [ ! -z "${europe_latency:-}" ] && [ "${europe_latency:-999}" -lt 250 ]; then
        echo -e "${_0x1a}✅ Europe region detected, applying optimizations${_0x21}"
        optimize_europe_halotel
    elif [ ! -z "${asia_latency:-}" ] && [ "${asia_latency:-999}" -lt 300 ]; then
        echo -e "${_0x1a}✅ Asia region detected, applying optimizations${_0x21}"
        optimize_asia_halotel
    else
        echo -e "${_0x1b}⚠️  Could not determine region, applying USA optimizations${_0x21}"
        optimize_usa_halotel
    fi
}

setup_traffic_monitor() {
    cat > /usr/local/bin/elite-x-traffic <<'EOF'
#!/bin/bash
TRAFFIC_DB="/etc/elite-x/traffic"
USER_DB="/etc/elite-x/users"
mkdir -p $TRAFFIC_DB

monitor_user() {
    local username="$1"
    local traffic_file="$TRAFFIC_DB/$username"
    
    if command -v iptables >/dev/null 2>&1; then
        local current=$(iptables -vnx -L OUTPUT | grep "$username" | awk '{sum+=$2} END {print sum}' 2>/dev/null || echo "0")
        echo $((current / 1048576)) > "$traffic_file"
    fi
}

while true; do
    if [ -d "$USER_DB" ]; then
        for user_file in "$USER_DB"/*; do
            [ -f "$user_file" ] && monitor_user "$(basename "$user_file")"
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
    systemctl enable elite-x-traffic.service
    systemctl start elite-x-traffic.service
}

setup_manual_speed() {
    cat > /usr/local/bin/elite-x-speed <<'EOF'
#!/bin/bash

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

optimize_network() {
    echo -e "${YELLOW}⚡ Optimizing network for maximum speed...${NC}"
    
    sysctl -w net.core.rmem_max=134217728 >/dev/null 2>&1
    sysctl -w net.core.wmem_max=134217728 >/dev/null 2>&1
    sysctl -w net.ipv4.tcp_rmem="4096 87380 134217728" >/dev/null 2>&1
    sysctl -w net.ipv4.tcp_wmem="4096 65536 134217728" >/dev/null 2>&1
    sysctl -w net.core.netdev_max_backlog=5000 >/dev/null 2>&1
    sysctl -w net.ipv4.tcp_congestion_control=bbr >/dev/null 2>&1
    sysctl -w net.core.default_qdisc=fq >/dev/null 2>&1
    
    echo -e "${GREEN}✅ Network optimized!${NC}"
}

optimize_cpu() {
    echo -e "${YELLOW}⚡ Optimizing CPU performance...${NC}"
    
    for cpu in /sys/devices/system/cpu/cpu*/cpufreq/scaling_governor; do
        echo "performance" > "$cpu" 2>/dev/null || true
    done
    
    echo -e "${GREEN}✅ CPU optimized!${NC}"
}

optimize_ram() {
    echo -e "${YELLOW}⚡ Optimizing RAM...${NC}"
    
    sync && echo 3 > /proc/sys/vm/drop_caches 2>/dev/null || true
    
    echo -e "${GREEN}✅ RAM optimized!${NC}"
}

clean_junk() {
    echo -e "${YELLOW}🧹 Cleaning junk files...${NC}"
    
    apt clean 2>/dev/null
    apt autoclean 2>/dev/null
    find /var/log -type f -name "*.log" -exec truncate -s 0 {} \; 2>/dev/null || true
    
    echo -e "${GREEN}✅ Junk files cleaned!${NC}"
}

case "$1" in
    manual)
        optimize_network
        optimize_cpu
        optimize_ram
        clean_junk
        ;;
    clean)
        clean_junk
        ;;
    *)
        echo "Usage: elite-x-speed {manual|clean}"
        exit 1
        ;;
esac
EOF
    chmod +x /usr/local/bin/elite-x-speed
}

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
    systemctl enable elite-x-cleaner.service
    systemctl start elite-x-cleaner.service
}

setup_updater() {
    cat > /usr/local/bin/elite-x-update <<'EOF'
#!/bin/bash

echo -e "\033[1;33m🔄 Checking for updates...\033[0m"

BACKUP_DIR="/root/elite-x-backup-$(date +%Y%m%d-%H%M%S)"
mkdir -p "$BACKUP_DIR"
cp -r /etc/elite-x "$BACKUP_DIR/" 2>/dev/null || true
cp -r /etc/dnstt "$BACKUP_DIR/" 2>/dev/null || true

cd /tmp
rm -rf Elite-X-dns.sh
git clone https://github.com/NoXFiQ/Elite-X-dns.sh.git 2>/dev/null || {
    echo -e "\033[0;31m❌ Failed to download update\033[0m"
    exit 1
}

cd Elite-X-dns.sh
chmod +x *.sh

cp -r "$BACKUP_DIR/elite-x" /etc/ 2>/dev/null || true
cp -r "$BACKUP_DIR/dnstt" /etc/ 2>/dev/null || true

echo -e "\033[0;32m✅ Update complete!\033[0m"
EOF
    chmod +x /usr/local/bin/elite-x-update
}

_0x2a

echo -e "${_0x1b}═══════════════════════════════════════════════════════════════${_0x21}"
echo -e "${_0x1a}                    ACTIVATION REQUIRED                          ${_0x21}"
echo -e "${_0x1b}═══════════════════════════════════════════════════════════════${_0x21}"
echo ""
echo -e "${_0x1f}Available Keys:${_0x21}"
echo -e "${_0x1a}  Lifetime : $_0x4${_0x21}"
echo -e "${_0x1b}  Trial    : ELITE-X-TEST-0208 (2 days)${_0x21}"
echo ""
read -p "$(echo -e ${_0x1e}"Activation Key: "${_0x21})" ACTIVATION_INPUT

mkdir -p /etc/elite-x
if ! activate_script "$ACTIVATION_INPUT"; then
    echo -e "${_0x19}❌ Invalid activation key! Installation cancelled.${_0x21}"
    exit 1
fi

echo -e "${_0x1a}✅ Activation successful!${_0x21}"
sleep 1

if [ -f "$ACTIVATION_TYPE_FILE" ] && [ "$(cat "$ACTIVATION_TYPE_FILE")" = "temporary" ]; then
    echo -e "${_0x1b}⚠️  Trial version activated - expires in 2 days${_0x21}"
fi
sleep 2

set_timezone
read -p "$(echo -e ${_0x19}"Enter Your Subdomain ==>|ns-ex.elitex.sbs|: "${_0x21})" TDOMAIN

echo -e "${_0x1b}═══════════════════════════════════════════════════════════════${_0x21}"
echo -e "${_0x1a}           NETWORK LOCATION OPTIMIZATION                          ${_0x21}"
echo -e "${_0x1b}═══════════════════════════════════════════════════════════════${_0x21}"
echo -e "${_0x1f}Select your VPS location:${_0x21}"
echo -e "${_0x1a}  1. South Africa (Default - MTU 1800)${_0x21}"
echo -e "${_0x1e}  2. USA (Auto-detect best MTU)${_0x21}"
echo -e "${_0x1c}  3. Europe (Auto-detect best MTU)${_0x21}"
echo -e "${_0x1d}  4. Asia (Auto-detect best MTU)${_0x21}"
echo -e "${_0x1b}  5. Auto-detect everything${_0x21}"
echo ""
read -p "$(echo -e ${_0x1a}"Select location [1-5] [default: 1]: "${_0x21})" LOCATION_CHOICE
LOCATION_CHOICE=${LOCATION_CHOICE:-1}

if [ "$LOCATION_CHOICE" = "1" ]; then
    MTU=1800
    SELECTED_LOCATION="South Africa"
    echo -e "${_0x1a}✅ Using South Africa configuration (MTU: $MTU)${_0x21}"
else
    MTU=1400 
    case $LOCATION_CHOICE in
        2)
            SELECTED_LOCATION="USA"
            echo -e "${_0x1e}✅ USA selected - will auto-detect best MTU${_0x21}"
            NEED_USA_OPT=1
            ;;
        3)
            SELECTED_LOCATION="Europe"
            echo -e "${_0x1c}✅ Europe selected - will auto-detect best MTU${_0x21}"
            NEED_EUROPE_OPT=1
            ;;
        4)
            SELECTED_LOCATION="Asia"
            echo -e "${_0x1d}✅ Asia selected - will auto-detect best MTU${_0x21}"
            NEED_ASIA_OPT=1
            ;;
        5)
            SELECTED_LOCATION="Auto-detect"
            echo -e "${_0x1b}✅ Auto-detect selected${_0x21}"
            NEED_AUTO_OPT=1
            ;;
    esac
fi

echo "$SELECTED_LOCATION" > /etc/elite-x/location
echo "$MTU" > /etc/elite-x/mtu

DNSTT_PORT=5300
DNS_PORT=53

echo "==> ELITE-X INSTALLATION STARTING..."

if [ "$(id -u)" -ne 0 ]; then
  echo "[-] Run as root"
  exit 1
fi

mkdir -p /etc/elite-x/{banner,users,traffic}
echo "$TDOMAIN" > /etc/elite-x/subdomain

cat > /etc/elite-x/banner/default <<'EOF'
===============================================
      WELCOME TO ELITE-X VPN SERVICE
===============================================
     High Speed • Secure • Unlimited
===============================================
EOF

cat > /etc/elite-x/banner/ssh-banner <<'EOF'
************************************************
*         ELITE-X VPN SERVICE                  *
*     High Speed • Secure • Unlimited          *
************************************************
EOF

if ! grep -q "^Banner" /etc/ssh/sshd_config; then
    echo "Banner /etc/elite-x/banner/ssh-banner" >> /etc/ssh/sshd_config
else
    sed -i 's|^Banner.*|Banner /etc/elite-x/banner/ssh-banner|' /etc/ssh/sshd_config
fi
systemctl restart sshd

echo "Stopping old services..."
for svc in dnstt dnstt-server slowdns dnstt-smart dnstt-elite-x dnstt-elite-x-proxy; do
  systemctl disable --now "$svc" 2>/dev/null || true
done

if [ -f /etc/systemd/resolved.conf ]; then
  echo "Configuring systemd-resolved..."
  sed -i 's/^#\?DNSStubListener=.*/DNSStubListener=no/' /etc/systemd/resolved.conf || true
  grep -q '^DNS=' /etc/systemd/resolved.conf \
    && sed -i 's/^DNS=.*/DNS=8.8.8.8 8.8.4.4/' /etc/systemd/resolved.conf \
    || echo "DNS=8.8.8.8 8.8.4.4" >> /etc/systemd/resolved.conf
  systemctl restart systemd-resolved
  ln -sf /run/systemd/resolve/resolv.conf /etc/resolv.conf
fi

echo "Installing dependencies..."
apt update -y
apt install -y curl python3 jq nano iptables iptables-persistent ethtool

echo "Installing dnstt-server..."
curl -fsSL https://dnstt.network/dnstt-server-linux-amd64 -o /usr/local/bin/dnstt-server
chmod +x /usr/local/bin/dnstt-server

echo "Generating keys..."
mkdir -p /etc/dnstt
if [ ! -f /etc/dnstt/server.key ]; then
  cd /etc/dnstt
  dnstt-server -gen-key -privkey-file server.key -pubkey-file server.pub
  cd ~
fi
chmod 600 /etc/dnstt/server.key
chmod 644 /etc/dnstt/server.pub

echo "Creating dnstt-elite-x.service..."
cat >/etc/systemd/system/dnstt-elite-x.service <<EOF
[Unit]
Description=ELITE-X DNSTT Server
After=network-online.target

[Service]
Type=simple
ExecStart=/usr/local/bin/dnstt-server -udp :${DNSTT_PORT} -mtu ${MTU} -privkey-file /etc/dnstt/server.key ${TDOMAIN} 127.0.0.1:22
Restart=no
KillSignal=SIGTERM
LimitNOFILE=1048576

[Install]
WantedBy=multi-user.target
EOF

echo "Installing EDNS proxy..."
cat >/usr/local/bin/dnstt-edns-proxy.py <<'EOF'
#!/usr/bin/env python3
import socket,threading,struct
L=5300
def p(d,s):
 if len(d)<12:return d
 try:q,a,n,r=struct.unpack("!HHHH",d[4:12])
 except:return d
 o=12
 def sk(b,o):
  while o<len(b):
   l=b[o];o+=1
   if l==0:break
   if l&0xC0==0xC0:o+=1;break
   o+=l
  return o
 for _ in range(q):o=sk(d,o);o+=4
 for _ in range(a+n):
  o=sk(d,o)
  if o+10>len(d):return d
  _,_,_,l=struct.unpack("!HHIH",d[o:o+10])
  o+=10+l
 n=bytearray(d)
 for _ in range(r):
  o=sk(d,o)
  if o+10>len(d):return d
  t=struct.unpack("!H",d[o:o+2])[0]
  if t==41:
   n[o+2:o+4]=struct.pack("!H",s)
   return bytes(n)
  _,_,l=struct.unpack("!HIH",d[o+2:o+10])
  o+=10+l
 return d
def h(sk,d,ad):
 u=socket.socket(socket.AF_INET,socket.SOCK_DGRAM)
 u.settimeout(5)
 try:
  u.sendto(p(d,1800),('127.0.0.1',L))
  r,_=u.recvfrom(4096)
  sk.sendto(p(r,512),ad)
 except:pass
 finally:u.close()
s=socket.socket(socket.AF_INET,socket.SOCK_DGRAM)
s.bind(('0.0.0.0',53))
while True:
 d,a=s.recvfrom(4096)
 threading.Thread(target=h,args=(s,d,a),daemon=True).start()
EOF
chmod +x /usr/local/bin/dnstt-edns-proxy.py

cat >/etc/systemd/system/dnstt-elite-x-proxy.service <<EOF
[Unit]
Description=ELITE-X Proxy
After=dnstt-elite-x.service

[Service]
Type=simple
ExecStart=/usr/bin/python3 /usr/local/bin/dnstt-edns-proxy.py
Restart=no

[Install]
WantedBy=multi-user.target
EOF

command -v ufw >/dev/null && ufw allow 22/tcp && ufw allow 53/udp || true

systemctl daemon-reload
systemctl enable dnstt-elite-x.service dnstt-elite-x-proxy.service
systemctl start dnstt-elite-x.service dnstt-elite-x-proxy.service

setup_traffic_monitor
setup_manual_speed
setup_auto_remover
setup_updater

cat > /usr/local/bin/elite-x-optimize-usa <<'EOL'
#!/bin/bash
echo -e "\033[1;33m🔍 Auto-detecting best MTU for USA...\033[0m"
best_mtu=1400
best_time=999999
for mtu in 1500 1450 1400 1350 1300; do
    echo -n "  Testing MTU $mtu... "
    if timeout 2 ping -M do -c 2 -s $((mtu-28)) 8.8.8.8 >/dev/null 2>&1; then
        avg_time=$(ping -c 2 -s $((mtu-28)) 8.8.8.8 2>/dev/null | tail -1 | awk -F '/' '{print $5}' | cut -d. -f1)
        if [ ! -z "$avg_time" ] && [ "$avg_time" -lt "$best_time" ]; then
            best_time=$avg_time
            best_mtu=$mtu
            echo -e "\033[0;32m✅ OK (${avg_time}ms)\033[0m"
        else
            echo -e "\033[0;32m✅ OK\033[0m"
        fi
    else
        echo -e "\033[0;31m❌ FAILED\033[0m"
    fi
done
echo "$best_mtu" > /etc/elite-x/mtu
sed -i "s/-mtu [0-9]*/-mtu $best_mtu/" /etc/systemd/system/dnstt-elite-x.service
cat >> /etc/sysctl.conf <<EOF
net.ipv4.tcp_rmem = 4096 87380 67108864
net.ipv4.tcp_wmem = 4096 65536 67108864
net.ipv4.tcp_congestion_control = bbr
net.core.default_qdisc = fq
EOF
sysctl -p
systemctl daemon-reload
systemctl restart dnstt-elite-x dnstt-elite-x-proxy
echo -e "\033[0;32m✅ USA optimized with MTU $best_mtu\033[0m"
EOL

cat > /usr/local/bin/elite-x-optimize-europe <<'EOL'
#!/bin/bash
echo -e "\033[1;33m🔍 Auto-detecting best MTU for Europe...\033[0m"
best_mtu=1400
best_time=999999
for mtu in 1500 1450 1400 1350 1300; do
    echo -n "  Testing MTU $mtu... "
    if timeout 2 ping -M do -c 2 -s $((mtu-28)) 8.8.8.8 >/dev/null 2>&1; then
        avg_time=$(ping -c 2 -s $((mtu-28)) 8.8.8.8 2>/dev/null | tail -1 | awk -F '/' '{print $5}' | cut -d. -f1)
        if [ ! -z "$avg_time" ] && [ "$avg_time" -lt "$best_time" ]; then
            best_time=$avg_time
            best_mtu=$mtu
            echo -e "\033[0;32m✅ OK (${avg_time}ms)\033[0m"
        else
            echo -e "\033[0;32m✅ OK\033[0m"
        fi
    else
        echo -e "\033[0;31m❌ FAILED\033[0m"
    fi
done
echo "$best_mtu" > /etc/elite-x/mtu
sed -i "s/-mtu [0-9]*/-mtu $best_mtu/" /etc/systemd/system/dnstt-elite-x.service
cat >> /etc/sysctl.conf <<EOF
net.ipv4.tcp_rmem = 4096 87380 33554432
net.ipv4.tcp_wmem = 4096 65536 33554432
net.ipv4.tcp_congestion_control = bbr
net.core.default_qdisc = fq
EOF
sysctl -p
systemctl daemon-reload
systemctl restart dnstt-elite-x dnstt-elite-x-proxy
echo -e "\033[0;32m✅ Europe optimized with MTU $best_mtu\033[0m"
EOL

cat > /usr/local/bin/elite-x-optimize-asia <<'EOL'
#!/bin/bash
echo -e "\033[1;33m🔍 Auto-detecting best MTU for Asia...\033[0m"
best_mtu=1400
best_time=999999
for mtu in 1500 1450 1400 1350 1300; do
    echo -n "  Testing MTU $mtu... "
    if timeout 2 ping -M do -c 2 -s $((mtu-28)) 8.8.8.8 >/dev/null 2>&1; then
        avg_time=$(ping -c 2 -s $((mtu-28)) 8.8.8.8 2>/dev/null | tail -1 | awk -F '/' '{print $5}' | cut -d. -f1)
        if [ ! -z "$avg_time" ] && [ "$avg_time" -lt "$best_time" ]; then
            best_time=$avg_time
            best_mtu=$mtu
            echo -e "\033[0;32m✅ OK (${avg_time}ms)\033[0m"
        else
            echo -e "\033[0;32m✅ OK\033[0m"
        fi
    else
        echo -e "\033[0;31m❌ FAILED\033[0m"
    fi
done
echo "$best_mtu" > /etc/elite-x/mtu
sed -i "s/-mtu [0-9]*/-mtu $best_mtu/" /etc/systemd/system/dnstt-elite-x.service
cat >> /etc/sysctl.conf <<EOF
net.ipv4.tcp_rmem = 4096 87380 16777216
net.ipv4.tcp_wmem = 4096 65536 16777216
net.ipv4.tcp_congestion_control = bbr
net.core.default_qdisc = fq
EOF
sysctl -p
systemctl daemon-reload
systemctl restart dnstt-elite-x dnstt-elite-x-proxy
echo -e "\033[0;32m✅ Asia optimized with MTU $best_mtu\033[0m"
EOL

cat > /usr/local/bin/elite-x-optimize-auto <<'EOL'
#!/bin/bash
echo -e "\033[1;33m🔍 Auto-detecting best location and MTU...\033[0m"
usa_latency=$(ping -c 2 -W 2 8.8.8.8 2>/dev/null | tail -1 | awk -F '/' '{print $5}' | cut -d. -f1)
europe_latency=$(ping -c 2 -W 2 1.1.1.1 2>/dev/null | tail -1 | awk -F '/' '{print $5}' | cut -d. -f1)
asia_latency=$(ping -c 2 -W 2 208.67.222.222 2>/dev/null | tail -1 | awk -F '/' '{print $5}' | cut -d. -f1)
[ ! -z "$usa_latency" ] && echo "USA: ${usa_latency}ms"
[ ! -z "$europe_latency" ] && echo "Europe: ${europe_latency}ms"
[ ! -z "$asia_latency" ] && echo "Asia: ${asia_latency}ms"
if [ ! -z "${usa_latency:-}" ] && [ "${usa_latency:-999}" -lt 200 ]; then
    /usr/local/bin/elite-x-optimize-usa
elif [ ! -z "${europe_latency:-}" ] && [ "${europe_latency:-999}" -lt 250 ]; then
    /usr/local/bin/elite-x-optimize-europe
elif [ ! -z "${asia_latency:-}" ] && [ "${asia_latency:-999}" -lt 300 ]; then
    /usr/local/bin/elite-x-optimize-asia
else
    /usr/local/bin/elite-x-optimize-usa
fi
EOL

chmod +x /usr/local/bin/elite-x-optimize-*

if [ ! -z "${NEED_USA_OPT:-}" ]; then
    optimize_usa_halotel
elif [ ! -z "${NEED_EUROPE_OPT:-}" ]; then
    optimize_europe_halotel
elif [ ! -z "${NEED_ASIA_OPT:-}" ]; then
    optimize_asia_halotel
elif [ ! -z "${NEED_AUTO_OPT:-}" ]; then
    auto_detect_best_settings
fi

cat > /etc/cron.hourly/elite-x-expiry <<'EOF'
#!/bin/bash
if [ -f /usr/local/bin/elite-x ]; then
    /usr/local/bin/elite-x --check-expiry
fi
EOF
chmod +x /etc/cron.hourly/elite-x-expiry

cat >/usr/local/bin/elite-x-user <<'EOF'
#!/bin/bash

RED='\033[0;31m';GREEN='\033[0;32m';YELLOW='\033[1;33m';CYAN='\033[0;36m';WHITE='\033[1;37m';NC='\033[0m'
UD="/etc/elite-x/users";TD="/etc/elite-x/traffic";mkdir -p $UD $TD

add_user() {
    clear
    echo -e "${CYAN}═══════════════════════════════════════════════════════════════${NC}"
    echo -e "${YELLOW}                     CREATE SSH + DNS USER                      ${NC}"
    echo -e "${CYAN}═══════════════════════════════════════════════════════════════${NC}"
    
    read -p "$(echo -e $GREEN"Username: "$NC)" username
    read -p "$(echo -e $GREEN"Password: "$NC)" password
    read -p "$(echo -e $GREEN"Expire days: "$NC)" days
    read -p "$(echo -e $GREEN"Traffic limit (MB, 0 for unlimited): "$NC)" traffic_limit
    
    if id "$username" &>/dev/null; then
        echo -e "${RED}User already exists!${NC}"
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
    echo -e "${GREEN}═══════════════════════════════════════════════════════════════${NC}"
    echo -e "${YELLOW}                  USER DETAILS                                  ${NC}"
    echo -e "${GREEN}═══════════════════════════════════════════════════════════════${NC}"
    echo -e "${WHITE}Username  :${CYAN} $username${NC}"
    echo -e "${WHITE}Password  :${CYAN} $password${NC}"
    echo -e "${WHITE}Server    :${CYAN} $SERVER${NC}"
    echo -e "${WHITE}Public Key:${CYAN} $PUBKEY${NC}"
    echo -e "${WHITE}Expire    :${CYAN} $expire_date${NC}"
    echo -e "${WHITE}Traffic   :${CYAN} $traffic_limit MB${NC}"
    echo -e "${GREEN}═══════════════════════════════════════════════════════════════${NC}"
}

list_users() {
    clear
    echo -e "${CYAN}═══════════════════════════════════════════════════════════════${NC}"
    echo -e "${YELLOW}                     ACTIVE USERS                               ${NC}"
    echo -e "${CYAN}═══════════════════════════════════════════════════════════════${NC}"
    
    [ -z "$(ls -A $UD 2>/dev/null)" ] && { echo -e "${RED}No users found${NC}"; return; }
    
    printf "%-12s %-10s %-6s %-6s %-8s\n" "USERNAME" "EXPIRE" "LIMIT" "USED" "STATUS"
    echo -e "${CYAN}────────────────────────────────────────────────────────────${NC}"
    
    for user in $UD/*; do
        [ ! -f "$user" ] && continue
        u=$(basename "$user")
        ex=$(grep "Expire:" "$user" | cut -d' ' -f2 | cut -c6-10)
        lm=$(grep "Traffic_Limit:" "$user" | cut -d' ' -f2)
        us=$(cat $TD/$u 2>/dev/null || echo "0")
        st=$(passwd -S "$u" 2>/dev/null | grep -q "L" && echo "${RED}LOCK${NC}" || echo "${GREEN}OK${NC}")
        printf "%-12s %-10s %-6s %-6s %-8b\n" "$u" "$ex" "$lm" "$us" "$st"
    done
    echo -e "${CYAN}═══════════════════════════════════════════════════════════════${NC}"
}

lock_user() { read -p "Username: " u; usermod -L "$u" 2>/dev/null && echo -e "${GREEN}✅ Locked${NC}" || echo -e "${RED}❌ Failed${NC}"; }
unlock_user() { read -p "Username: " u; usermod -U "$u" 2>/dev/null && echo -e "${GREEN}✅ Unlocked${NC}" || echo -e "${RED}❌ Failed${NC}"; }
delete_user() { 
    read -p "Username: " u
    userdel -r "$u" 2>/dev/null
    rm -f $UD/$u $TD/$u
    echo -e "${GREEN}✅ Deleted${NC}"
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

cat >/usr/local/bin/elite-x <<'EOF'
#!/bin/bash

# Obfuscated color codes
R='\033[0;31m';G='\033[0;32m';Y='\033[1;33m';C='\033[0;36m'
P='\033[0;35m';W='\033[1;37m';B='\033[1m';N='\033[0m'

# Check if we're in a loop
if [ -f /tmp/elite-x-running ]; then
    exit 0
fi
touch /tmp/elite-x-running

trap 'rm -f /tmp/elite-x-running' EXIT

# Check expiry
check_expiry_menu() {
    if [ -f "/etc/elite-x/activation_type" ] && [ -f "/etc/elite-x/activation_date" ] && [ -f "/etc/elite-x/expiry_days" ]; then
        local act_type=$(cat "/etc/elite-x/activation_type")
        if [ "$act_type" = "temporary" ]; then
            local act_date=$(cat "/etc/elite-x/activation_date")
            local expiry_days=$(cat "/etc/elite-x/expiry_days")
            local current_date=$(date +%s)
            local expiry_date=$(date -d "$act_date + $expiry_days days" +%s)
            
            if [ $current_date -ge $expiry_date ]; then
                echo -e "${R}═══════════════════════════════════════════════════════════════${N}"
                echo -e "${Y}⚠️  TRIAL PERIOD EXPIRED ⚠️${N}"
                echo -e "${R}Your 2-day trial has ended.${N}"
                echo -e "${R}Script will now uninstall itself...${N}"
                echo -e "${R}═══════════════════════════════════════════════════════════════${N}"
                sleep 3
                
                systemctl stop dnstt-elite-x dnstt-elite-x-proxy elite-x-traffic elite-x-cleaner 2>/dev/null || true
                systemctl disable dnstt-elite-x dnstt-elite-x-proxy elite-x-traffic elite-x-cleaner 2>/dev/null || true
                rm -f /etc/systemd/system/{dnstt-elite-x*,elite-x-*}
                rm -rf /etc/dnstt /etc/elite-x
                rm -f /usr/local/bin/{dnstt-*,elite-x*}
                sed -i '/^Banner/d' /etc/ssh/sshd_config
                systemctl restart sshd
                
                echo -e "${G}✅ ELITE-X has been uninstalled.${N}"
                rm -f /tmp/elite-x-running
                exit 0
            fi
        fi
    fi
}

check_expiry_menu

# Protected dashboard with hidden activation key
show_dashboard() {
    clear
    
    IP=$(cat /etc/elite-x/cached_ip 2>/dev/null || curl -s ifconfig.me 2>/dev/null || echo "Unknown")
    LOC=$(cat /etc/elite-x/cached_location 2>/dev/null || echo "Unknown")
    ISP=$(cat /etc/elite-x/cached_isp 2>/dev/null || echo "Unknown")
    RAM=$(free -m | awk '/^Mem:/{print $3"/"$2"MB"}')
    SUB=$(cat /etc/elite-x/subdomain 2>/dev/null || echo "Not configured")
    ACTIVATION_KEY=$(cat /etc/elite-x/key 2>/dev/null | cut -c1-3)****$(cat /etc/elite-x/key 2>/dev/null | rev | cut -c1-3 | rev)
    EXP=$(cat /etc/elite-x/expiry 2>/dev/null || echo "Lifetime")
    LOCATION=$(cat /etc/elite-x/location 2>/dev/null || echo "South Africa")
    CURRENT_MTU=$(cat /etc/elite-x/mtu 2>/dev/null || echo "1800")
    
    DNS=$(systemctl is-active dnstt-elite-x 2>/dev/null | grep -q active && echo "${G}●${N}" || echo "${R}●${N}")
    PRX=$(systemctl is-active dnstt-elite-x-proxy 2>/dev/null | grep -q active && echo "${G}●${N}" || echo "${R}●${N}")
    
    echo -e "${C}╔════════════════════════════════════════════════════════════════╗${N}"
    echo -e "${C}║${Y}${B}                    ELITE-X SLOWDNS v3.0                       ${C}║${N}"
    echo -e "${C}╠════════════════════════════════════════════════════════════════╣${N}"
    echo -e "${C}║${W}  Subdomain :${G} $SUB${N}"
    echo -e "${C}║${W}  IP        :${G} $IP${N}"
    echo -e "${C}║${W}  Location  :${G} $LOC${N}"
    echo -e "${C}║${W}  ISP       :${G} $ISP${N}"
    echo -e "${C}║${W}  RAM       :${G} $RAM${N}"
    echo -e "${C}║${W}  VPS Loc   :${G} $LOCATION${N}"
    echo -e "${C}║${W}  MTU       :${G} $CURRENT_MTU${N}"
    echo -e "${C}║${W}  Services  : DNS:$DNS PRX:$PRX${N}"
    echo -e "${C}║${W}  Developer :${P} ELITE-X TEAM${N}"
    echo -e "${C}╠════════════════════════════════════════════════════════════════╣${N}"
    echo -e "${C}║${W}  Act Key   :${Y} $ACTIVATION_KEY${N}"
    echo -e "${C}║${W}  Expiry    :${Y} $EXP${N}"
    echo -e "${C}╚════════════════════════════════════════════════════════════════╝${N}"
    echo ""
}

# Settings menu (protected)
settings_menu() {
    while true; do
        clear
        echo -e "${C}╔════════════════════════════════════════════════════════════════╗${N}"
        echo -e "${C}║${Y}${B}                      SETTINGS MENU                              ${C}║${N}"
        echo -e "${C}╠════════════════════════════════════════════════════════════════╣${N}"
        echo -e "${C}║${W}  [8]  🔑 View Public Key${N}"
        echo -e "${C}║${W}  [9]  Change MTU Value (Manual)${N}"
        echo -e "${C}║${W}  [10] ⚡ Manual Speed Optimization${N}"
        echo -e "${C}║${W}  [11] 🧹 Clean Junk Files${N}"
        echo -e "${C}║${W}  [12] 🔄 Auto Expired Account Remover${N}"
        echo -e "${C}║${W}  [13] 📦 Update Script${N}"
        echo -e "${C}║${W}  [14] Restart All Services${N}"
        echo -e "${C}║${W}  [15] Reboot VPS${N}"
        echo -e "${C}║${W}  [16] Uninstall Script${N}"
        echo -e "${C}║${W}  [17] 🌍 Re-apply Location Optimization${N}"
        echo -e "${C}║${W}  [0]  Back to Main Menu${N}"
        echo -e "${C}╚════════════════════════════════════════════════════════════════╝${N}"
        echo ""
        read -p "$(echo -e ${G}"Settings option: "${N})" ch
        
        case $ch in
            8)
                echo -e "${C}═══════════════════════════════════════════════════════════════${N}"
                echo -e "${Y}PUBLIC KEY (FULL):${N}"
                echo -e "${G}$(cat /etc/dnstt/server.pub)${N}"
                echo -e "${C}═══════════════════════════════════════════════════════════════${N}"
                read -p "Press Enter to continue..."
                ;;
            9)
                echo "Current MTU: $(cat /etc/elite-x/mtu)"
                read -p "New MTU (1000-5000): " mtu
                [[ "$mtu" =~ ^[0-9]+$ ]] && [ $mtu -ge 1000 ] && [ $mtu -le 5000 ] && {
                    echo "$mtu" > /etc/elite-x/mtu
                    sed -i "s/-mtu [0-9]*/-mtu $mtu/" /etc/systemd/system/dnstt-elite-x.service
                    systemctl daemon-reload
                    systemctl restart dnstt-elite-x dnstt-elite-x-proxy
                    echo -e "${G}✅ MTU updated${N}"
                } || echo -e "${R}❌ Invalid${N}"
                read -p "Press Enter to continue..."
                ;;
            10) elite-x-speed manual; read -p "Press Enter to continue..." ;;
            11) elite-x-speed clean; read -p "Press Enter to continue..." ;;
            12)
                systemctl enable --now elite-x-cleaner.service
                echo -e "${G}✅ Auto remover started${N}"
                read -p "Press Enter to continue..."
                ;;
            13) elite-x-update; read -p "Press Enter to continue..." ;;
            14)
                systemctl restart dnstt-elite-x dnstt-elite-x-proxy sshd
                echo -e "${G}✅ Services restarted${N}"
                read -p "Press Enter to continue..."
                ;;
            15)
                read -p "Reboot? (y/n): " c
                [ "$c" = "y" ] && reboot
                ;;
            16)
                read -p "Uninstall? (YES): " c
                [ "$c" = "YES" ] && {
                    systemctl stop dnstt-elite-x dnstt-elite-x-proxy elite-x-traffic elite-x-cleaner
                    systemctl disable dnstt-elite-x dnstt-elite-x-proxy elite-x-traffic elite-x-cleaner
                    rm -f /etc/systemd/system/{dnstt-elite-x*,elite-x-*}
                    rm -rf /etc/dnstt /etc/elite-x
                    rm -f /usr/local/bin/{dnstt-*,elite-x*}
                    sed -i '/^Banner/d' /etc/ssh/sshd_config
                    systemctl restart sshd
                    echo -e "${G}✅ Uninstalled${N}"
                    rm -f /tmp/elite-x-running
                    exit 0
                }
                read -p "Press Enter to continue..."
                ;;
            17)
                echo -e "${Y}═══════════════════════════════════════════════════════════════${N}"
                echo -e "${G}           RE-APPLY LOCATION OPTIMIZATION                        ${N}"
                echo -e "${Y}═══════════════════════════════════════════════════════════════${N}"
                echo -e "${W}Select your VPS location:${N}"
                echo -e "${G}  1. South Africa (MTU 1800)${N}"
                echo -e "${C}  2. USA (Auto-detect best MTU)${N}"
                echo -e "${P}  3. Europe (Auto-detect best MTU)${N}"
                echo -e "${Y}  4. Asia (Auto-detect best MTU)${N}"
                echo -e "${Y}  5. Auto-detect everything${N}"
                read -p "Choice: " opt_choice
                
                case $opt_choice in
                    1) echo "South Africa" > /etc/elite-x/location
                       echo "1800" > /etc/elite-x/mtu
                       sed -i "s/-mtu [0-9]*/-mtu 1800/" /etc/systemd/system/dnstt-elite-x.service
                       systemctl daemon-reload
                       systemctl restart dnstt-elite-x dnstt-elite-x-proxy
                       echo -e "${G}✅ South Africa selected (MTU 1800)${N}" ;;
                    2) echo "USA" > /etc/elite-x/location
                       /usr/local/bin/elite-x-optimize-usa ;;
                    3) echo "Europe" > /etc/elite-x/location
                       /usr/local/bin/elite-x-optimize-europe ;;
                    4) echo "Asia" > /etc/elite-x/location
                       /usr/local/bin/elite-x-optimize-asia ;;
                    5) echo "Auto-detect" > /etc/elite-x/location
                       /usr/local/bin/elite-x-optimize-auto ;;
                esac
                read -p "Press Enter to continue..."
                ;;
            0) return ;;
            *) echo -e "${R}Invalid option${N}"; read -p "Press Enter to continue..." ;;
        esac
    done
}

# Main menu (protected)
main_menu() {
    while true; do
        show_dashboard
        echo -e "${C}╔════════════════════════════════════════════════════════════════╗${N}"
        echo -e "${C}║${G}${B}                         MAIN MENU                              ${C}║${N}"
        echo -e "${C}╠════════════════════════════════════════════════════════════════╣${N}"
        echo -e "${C}║${W}  [1] Create SSH + DNS User${N}"
        echo -e "${C}║${W}  [2] List All Users${N}"
        echo -e "${C}║${W}  [3] Lock User${N}"
        echo -e "${C}║${W}  [4] Unlock User${N}"
        echo -e "${C}║${W}  [5] Delete User${N}"
        echo -e "${C}║${W}  [6] Create/Edit Banner${N}"
        echo -e "${C}║${W}  [7] Delete Banner${N}"
        echo -e "${C}║${W}  [S] ⚙️  Settings${N}"
        echo -e "${C}║${W}  [00] Exit${N}"
        echo -e "${C}╚════════════════════════════════════════════════════════════════╝${N}"
        echo ""
        read -p "$(echo -e ${G}"Main menu option: "${N})" ch
        
        case $ch in
            1) elite-x-user add; read -p "Press Enter to continue..." ;;
            2) elite-x-user list; read -p "Press Enter to continue..." ;;
            3) elite-x-user lock; read -p "Press Enter to continue..." ;;
            4) elite-x-user unlock; read -p "Press Enter to continue..." ;;
            5) elite-x-user del; read -p "Press Enter to continue..." ;;
            6)
                [ -f /etc/elite-x/banner/custom ] || cp /etc/elite-x/banner/default /etc/elite-x/banner/custom
                nano /etc/elite-x/banner/custom
                cp /etc/elite-x/banner/custom /etc/elite-x/banner/ssh-banner
                systemctl restart sshd
                echo -e "${G}✅ Banner saved${N}"
                read -p "Press Enter to continue..."
                ;;
            7)
                rm -f /etc/elite-x/banner/custom
                cp /etc/elite-x/banner/default /etc/elite-x/banner/ssh-banner
                systemctl restart sshd
                echo -e "${G}✅ Banner deleted${N}"
                read -p "Press Enter to continue..."
                ;;
            [Ss]) settings_menu ;;
            00|0) 
                rm -f /tmp/elite-x-running
                echo -e "${G}Goodbye!${N}"
                exit 0 
                ;;
            *) echo -e "${R}Invalid option${N}"; read -p "Press Enter to continue..." ;;
        esac
    done
}

main_menu
EOF
chmod +x /usr/local/bin/elite-x

echo "Caching network information for fast login..."
IP=$(curl -s ifconfig.me 2>/dev/null || echo "Unknown")
echo "$IP" > /etc/elite-x/cached_ip

if [ "$IP" != "Unknown" ]; then
    LOCATION_INFO=$(curl -s http://ip-api.com/json/$IP 2>/dev/null)
    echo "$LOCATION_INFO" | jq -r '.city + ", " + .country' 2>/dev/null > /etc/elite-x/cached_location || echo "Unknown" > /etc/elite-x/cached_location
    echo "$LOCATION_INFO" | jq -r '.isp' 2>/dev/null > /etc/elite-x/cached_isp || echo "Unknown" > /etc/elite-x/cached_isp
else
    echo "Unknown" > /etc/elite-x/cached_location
    echo "Unknown" > /etc/elite-x/cached_isp
fi

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
if [ -f /usr/local/bin/elite-x ] && [ -z "$ELITE_X_SHOWN" ]; then
    export ELITE_X_SHOWN=1
    rm -f /tmp/elite-x-running 2>/dev/null
    /usr/local/bin/elite-x
fi
EOF

echo "alias menu='elite-x'" >> ~/.bashrc
echo "alias elitex='elite-x'" >> ~/.bashrc

if [ ! -f /etc/elite-x/key ]; then
    if [ -f "$ACTIVATION_FILE" ]; then
        cp "$ACTIVATION_FILE" /etc/elite-x/key
    else
        echo "$_0x4" > /etc/elite-x/key
    fi
fi

echo "======================================"
echo " ELITE-X INSTALLED SUCCESSFULLY "
echo "======================================"
EXPIRY_INFO=$(cat /etc/elite-x/expiry 2>/dev/null || echo "Lifetime")
FINAL_MTU=$(cat /etc/elite-x/mtu 2>/dev/null || echo "1800")
ACTIVATION_KEY=$(cat /etc/elite-x/key 2>/dev/null | cut -c1-3)****$(cat /etc/elite-x/key 2>/dev/null | rev | cut -c1-3 | rev)
echo "DOMAIN  : ${TDOMAIN}"
echo "LOCATION: ${SELECTED_LOCATION}"
echo "MTU     : ${FINAL_MTU} $( [ "$SELECTED_LOCATION" = "South Africa" ] && echo "(Default)" || echo "(Auto-detected)" )"
echo "ACT KEY : ${ACTIVATION_KEY}"
echo "EXPIRY  : ${EXPIRY_INFO}"
echo ""
echo "PUBLIC KEY:"
cat /etc/dnstt/server.pub
echo "======================================"
echo ""
echo -e "${GREEN}✅ DASHBOARD WILL NOW SHOW AUTOMATICALLY ON LOGIN${NC}"
echo -e "${YELLOW}No need to type 'elite-x' or 'menu' - it appears automatically!${NC}"
echo "======================================"

read -p "Open menu now? (y/n): " open
[ "$open" = "y" ] && /usr/local/bin/elite-x
