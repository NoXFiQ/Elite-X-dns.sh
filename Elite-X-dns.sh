#!/bin/bash
# ============================================
# ELITE-X DNSTT AUTO INSTALL (STABLE EDITION)
# Stable • Clean • Production ready
# NO AUTO RESTART • NO AUTO REBOOT
# ============================================
set -euo pipefail

# Color codes for better output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
WHITE='\033[1;37m'
BOLD='\033[1m'
NC='\033[0m'

print_color() { echo -e "${2}${1}${NC}"; }

# Function to show banner
show_banner() {
    clear
    echo -e "${RED}"
    figlet -f slant "ELITE-X" 2>/dev/null || echo "======== ELITE-X SLOWDNS ========"
    echo -e "${GREEN}           Version 3.0 - Stable Edition${NC}"
    echo -e "${YELLOW}================================================${NC}"
    echo ""
}

# ========== ACTIVATION SYSTEM ==========
ACTIVATION_KEY="ELITEX-2026-DAN-4D-08"
TEMP_KEY="ELITE-X-TEST-0208"
ACTIVATION_FILE="/etc/elite-x/activated"
ACTIVATION_TYPE_FILE="/etc/elite-x/activation_type"
ACTIVATION_DATE_FILE="/etc/elite-x/activation_date"
EXPIRY_DAYS_FILE="/etc/elite-x/expiry_days"
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
                echo -e "${RED}═══════════════════════════════════════════════════════════════${NC}"
                echo -e "${YELLOW}⚠️  TRIAL PERIOD EXPIRED ⚠️${NC}"
                echo -e "${RED}Your 2-day trial has ended.${NC}"
                echo -e "${RED}Script will now uninstall itself...${NC}"
                echo -e "${RED}═══════════════════════════════════════════════════════════════${NC}"
                sleep 3
                
                # Self uninstall
                systemctl stop dnstt-elite-x dnstt-elite-x-proxy elite-x-traffic elite-x-cleaner 2>/dev/null || true
                systemctl disable dnstt-elite-x dnstt-elite-x-proxy elite-x-traffic elite-x-cleaner 2>/dev/null || true
                rm -f /etc/systemd/system/{dnstt-elite-x*,elite-x-*}
                rm -rf /etc/dnstt /etc/elite-x
                rm -f /usr/local/bin/{dnstt-*,elite-x*}
                sed -i '/^Banner/d' /etc/ssh/sshd_config
                systemctl restart sshd
                
                # Remove itself
                rm -f "$0"
                echo -e "${GREEN}✅ ELITE-X has been uninstalled.${NC}"
                exit 0
            else
                local days_left=$(( (expiry_date - current_date) / 86400 ))
                local hours_left=$(( ((expiry_date - current_date) % 86400) / 3600 ))
                echo -e "${YELLOW}⚠️  Trial: $days_left days $hours_left hours remaining${NC}"
            fi
        fi
    fi
}

activate_script() {
    local input_key="$1"
    mkdir -p /etc/elite-x
    
    if [ "$input_key" = "$ACTIVATION_KEY" ]; then
        echo "$ACTIVATION_KEY" > "$ACTIVATION_FILE"
        echo "lifetime" > "$ACTIVATION_TYPE_FILE"
        echo "Lifetime" > /etc/elite-x/expiry
        return 0
    elif [ "$input_key" = "$TEMP_KEY" ]; then
        echo "$TEMP_KEY" > "$ACTIVATION_FILE"
        echo "temporary" > "$ACTIVATION_TYPE_FILE"
        echo "$(date +%Y-%m-%d)" > "$ACTIVATION_DATE_FILE"
        echo "2" > "$EXPIRY_DAYS_FILE"
        echo "2 Days Trial" > /etc/elite-x/expiry
        return 0
    fi
    return 1
}

# ========== FIXED MTU AUTO-DETECTION FUNCTION ==========
detect_best_mtu() {
    echo -e "${YELLOW}🔍 Auto-detecting best MTU for your connection...${NC}"
    
    # Only test valid MTU sizes (standard max is 1500)
    local test_mtus="1500 1450 1400 1350 1300"
    local best_mtu=1400
    local best_time=999999
    
    for mtu in $test_mtus; do
        echo -n "  Testing MTU $mtu... "
        
        # Use timeout to prevent hanging
        if timeout 2 ping -M do -c 2 -s $((mtu-28)) 8.8.8.8 >/dev/null 2>&1; then
            # Measure response time
            local avg_time=$(ping -c 2 -s $((mtu-28)) 8.8.8.8 2>/dev/null | tail -1 | awk -F '/' '{print $5}' | cut -d. -f1)
            if [ ! -z "$avg_time" ] && [ "$avg_time" -lt "$best_time" ]; then
                best_time=$avg_time
                best_mtu=$mtu
                echo -e "${GREEN}✅ OK (${avg_time}ms)${NC}"
            else
                echo -e "${GREEN}✅ OK${NC}"
            fi
        else
            echo -e "${RED}❌ FAILED${NC}"
        fi
    done
    
    echo -e "${GREEN}✅ Best MTU selected: $best_mtu (${best_time}ms)${NC}"
    echo "$best_mtu" > /etc/elite-x/mtu
    return 0
}

# ========== LOCATION OPTIMIZATION FUNCTIONS ==========
optimize_usa_halotel() {
    echo -e "${YELLOW}🔄 Optimizing USA → Halotel connection...${NC}"
    
    # Auto-detect best MTU for this location
    detect_best_mtu
    local detected_mtu=$(cat /etc/elite-x/mtu)
    
    # Update DNSTT service with detected MTU
    sed -i "s/-mtu [0-9]*/-mtu $detected_mtu/" /etc/systemd/system/dnstt-elite-x.service
    
    # Apply USA-specific TCP optimizations
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

    # Network interface optimization
    for iface in $(ls /sys/class/net/ | grep -v lo); do
        ethtool -K $iface tx off sg off tso off 2>/dev/null || true
        ip link set dev $iface txqueuelen 10000 2>/dev/null || true
    done

    sysctl -p
    systemctl daemon-reload
    systemctl restart dnstt-elite-x dnstt-elite-x-proxy
    
    echo -e "${GREEN}✅ USA optimized with MTU $detected_mtu (auto-detected)${NC}"
}

optimize_europe_halotel() {
    echo -e "${YELLOW}🔄 Optimizing Europe → Halotel connection...${NC}"
    
    # Auto-detect best MTU for this location
    detect_best_mtu
    local detected_mtu=$(cat /etc/elite-x/mtu)
    
    # Update DNSTT service with detected MTU
    sed -i "s/-mtu [0-9]*/-mtu $detected_mtu/" /etc/systemd/system/dnstt-elite-x.service
    
    # Apply Europe-specific TCP optimizations
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
    
    echo -e "${GREEN}✅ Europe optimized with MTU $detected_mtu (auto-detected)${NC}"
}

optimize_asia_halotel() {
    echo -e "${YELLOW}🔄 Optimizing Asia → Halotel connection...${NC}"
    
    # Auto-detect best MTU for this location
    detect_best_mtu
    local detected_mtu=$(cat /etc/elite-x/mtu)
    
    # Update DNSTT service with detected MTU
    sed -i "s/-mtu [0-9]*/-mtu $detected_mtu/" /etc/systemd/system/dnstt-elite-x.service
    
    # Apply Asia-specific TCP optimizations
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
    
    echo -e "${GREEN}✅ Asia optimized with MTU $detected_mtu (auto-detected)${NC}"
}

auto_detect_best_settings() {
    echo -e "${YELLOW}🔍 Auto-detecting best settings for your location...${NC}"
    
    # Test latency to different regions
    echo "Testing latency to various regions..."
    
    usa_latency=$(ping -c 2 -W 2 8.8.8.8 2>/dev/null | tail -1 | awk -F '/' '{print $5}' | cut -d. -f1)
    europe_latency=$(ping -c 2 -W 2 1.1.1.1 2>/dev/null | tail -1 | awk -F '/' '{print $5}' | cut -d. -f1)
    asia_latency=$(ping -c 2 -W 2 208.67.222.222 2>/dev/null | tail -1 | awk -F '/' '{print $5}' | cut -d. -f1)
    
    echo "  USA: ${usa_latency:-Unknown}ms"
    echo "  Europe: ${europe_latency:-Unknown}ms"
    echo "  Asia: ${asia_latency:-Unknown}ms"
    
    # Auto-detect MTU first
    detect_best_mtu
    
    # Apply based on lowest latency
    if [ ! -z "${usa_latency:-}" ] && [ "${usa_latency:-999}" -lt 200 ]; then
        echo -e "${GREEN}✅ USA region detected, applying optimizations${NC}"
        optimize_usa_halotel
    elif [ ! -z "${europe_latency:-}" ] && [ "${europe_latency:-999}" -lt 250 ]; then
        echo -e "${GREEN}✅ Europe region detected, applying optimizations${NC}"
        optimize_europe_halotel
    elif [ ! -z "${asia_latency:-}" ] && [ "${asia_latency:-999}" -lt 300 ]; then
        echo -e "${GREEN}✅ Asia region detected, applying optimizations${NC}"
        optimize_asia_halotel
    else
        echo -e "${YELLOW}⚠️  Could not determine region, applying USA optimizations${NC}"
        optimize_usa_halotel
    fi
}

# ========== TRAFFIC MONITORING ==========
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

# ========== MANUAL SPEED OPTIMIZATION ONLY (NO AUTO) ==========
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

# ========== AUTO EXPIRED ACCOUNT REMOVER ==========
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

# ========== UPDATE SYSTEM ==========
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

############################
# CONFIG (Interactive)
############################
show_banner
echo -e "${YELLOW}═══════════════════════════════════════════════════════════════${NC}"
echo -e "${GREEN}                    ACTIVATION REQUIRED                          ${NC}"
echo -e "${YELLOW}═══════════════════════════════════════════════════════════════${NC}"
echo ""
echo -e "${WHITE}Available Keys:${NC}"
echo -e "${GREEN}  Lifetime : ELITEX-2026-DAN-4D-08${NC}"
echo -e "${YELLOW}  Trial    : ELITE-X-TEST-0208 (2 days)${NC}"
echo ""
read -p "$(echo -e $CYAN"Activation Key: "$NC)" ACTIVATION_INPUT

mkdir -p /etc/elite-x
if ! activate_script "$ACTIVATION_INPUT"; then
    echo -e "${RED}❌ Invalid activation key! Installation cancelled.${NC}"
    exit 1
fi

echo -e "${GREEN}✅ Activation successful!${NC}"
sleep 1

# Check if trial and show expiry info
if [ -f "$ACTIVATION_TYPE_FILE" ] && [ "$(cat "$ACTIVATION_TYPE_FILE")" = "temporary" ]; then
    echo -e "${YELLOW}⚠️  Trial version activated - expires in 2 days${NC}"
fi
sleep 2

set_timezone
read -p "$(echo -e $RED"Enter Your Subdomain (e.g., ns-ex.elitex.sbs): "$NC)" TDOMAIN

# ========== LOCATION OPTIMIZATION SELECTION ==========
# South Africa default MTU 1800 - UNCHANGED
echo -e "${YELLOW}═══════════════════════════════════════════════════════════════${NC}"
echo -e "${GREEN}           NETWORK LOCATION OPTIMIZATION                          ${NC}"
echo -e "${YELLOW}═══════════════════════════════════════════════════════════════${NC}"
echo -e "${WHITE}Select your VPS location:${NC}"
echo -e "${GREEN}  1. South Africa (Default - MTU 1800)${NC}"
echo -e "${CYAN}  2. USA (Auto-detect best MTU)${NC}"
echo -e "${BLUE}  3. Europe (Auto-detect best MTU)${NC}"
echo -e "${PURPLE}  4. Asia (Auto-detect best MTU)${NC}"
echo -e "${YELLOW}  5. Auto-detect everything${NC}"
echo ""
read -p "$(echo -e $GREEN"Select location [1-5] [default: 1]: "$NC)" LOCATION_CHOICE
LOCATION_CHOICE=${LOCATION_CHOICE:-1}

# Set default MTU for South Africa
if [ "$LOCATION_CHOICE" = "1" ]; then
    MTU=1800
    SELECTED_LOCATION="South Africa"
    echo -e "${GREEN}✅ Using South Africa configuration (MTU: $MTU)${NC}"
else
    # For other locations, MTU will be auto-detected
    MTU=1400 # Temporary default
    case $LOCATION_CHOICE in
        2)
            SELECTED_LOCATION="USA"
            echo -e "${CYAN}✅ USA selected - will auto-detect best MTU${NC}"
            NEED_USA_OPT=1
            ;;
        3)
            SELECTED_LOCATION="Europe"
            echo -e "${BLUE}✅ Europe selected - will auto-detect best MTU${NC}"
            NEED_EUROPE_OPT=1
            ;;
        4)
            SELECTED_LOCATION="Asia"
            echo -e "${PURPLE}✅ Asia selected - will auto-detect best MTU${NC}"
            NEED_ASIA_OPT=1
            ;;
        5)
            SELECTED_LOCATION="Auto-detect"
            echo -e "${YELLOW}✅ Auto-detect selected${NC}"
            NEED_AUTO_OPT=1
            ;;
    esac
fi

echo "$SELECTED_LOCATION" > /etc/elite-x/location
echo "$MTU" > /etc/elite-x/mtu

DNSTT_PORT=5300
DNS_PORT=53
############################

echo "==> ELITE-X INSTALLATION STARTING..."

# Root check
if [ "$(id -u)" -ne 0 ]; then
  echo "[-] Run as root"
  exit 1
fi

# Create directories
mkdir -p /etc/elite-x/{banner,users,traffic}
echo "$TDOMAIN" > /etc/elite-x/subdomain

# Create default banner
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

# Configure SSH banner
if ! grep -q "^Banner" /etc/ssh/sshd_config; then
    echo "Banner /etc/elite-x/banner/ssh-banner" >> /etc/ssh/sshd_config
else
    sed -i 's|^Banner.*|Banner /etc/elite-x/banner/ssh-banner|' /etc/ssh/sshd_config
fi
systemctl restart sshd

# Stop conflicting services
echo "Stopping old services..."
for svc in dnstt dnstt-server slowdns dnstt-smart dnstt-elite-x dnstt-elite-x-proxy; do
  systemctl disable --now "$svc" 2>/dev/null || true
done

# systemd-resolved fix
if [ -f /etc/systemd/resolved.conf ]; then
  echo "Configuring systemd-resolved..."
  sed -i 's/^#\?DNSStubListener=.*/DNSStubListener=no/' /etc/systemd/resolved.conf || true
  grep -q '^DNS=' /etc/systemd/resolved.conf \
    && sed -i 's/^DNS=.*/DNS=8.8.8.8 8.8.4.4/' /etc/systemd/resolved.conf \
    || echo "DNS=8.8.8.8 8.8.4.4" >> /etc/systemd/resolved.conf
  systemctl restart systemd-resolved
  ln -sf /run/systemd/resolve/resolv.conf /etc/resolv.conf
fi

# Dependencies
echo "Installing dependencies..."
apt update -y
apt install -y curl python3 jq nano iptables iptables-persistent ethtool

# Install dnstt-server
echo "Installing dnstt-server..."
curl -fsSL https://dnstt.network/dnstt-server-linux-amd64 -o /usr/local/bin/dnstt-server
chmod +x /usr/local/bin/dnstt-server

# Keys
echo "Generating keys..."
mkdir -p /etc/dnstt
if [ ! -f /etc/dnstt/server.key ]; then
  cd /etc/dnstt
  dnstt-server -gen-key -privkey-file server.key -pubkey-file server.pub
  cd ~
fi
chmod 600 /etc/dnstt/server.key
chmod 644 /etc/dnstt/server.pub

# DNSTT service - MTU will be updated later for non-SA locations
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

# EDNS proxy
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

# Proxy service
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

# Firewall
command -v ufw >/dev/null && ufw allow 22/tcp && ufw allow 53/udp || true

# Start services
systemctl daemon-reload
systemctl enable dnstt-elite-x.service dnstt-elite-x-proxy.service
systemctl start dnstt-elite-x.service dnstt-elite-x-proxy.service

# ========== SETUP ADDITIONAL FEATURES ==========
setup_traffic_monitor
setup_manual_speed
setup_auto_remover
setup_updater

# ========== CREATE OPTIMIZATION HELPER SCRIPTS ==========
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

# ========== APPLY LOCATION-SPECIFIC OPTIMIZATIONS ==========
if [ ! -z "${NEED_USA_OPT:-}" ]; then
    optimize_usa_halotel
elif [ ! -z "${NEED_EUROPE_OPT:-}" ]; then
    optimize_europe_halotel
elif [ ! -z "${NEED_ASIA_OPT:-}" ]; then
    optimize_asia_halotel
elif [ ! -z "${NEED_AUTO_OPT:-}" ]; then
    auto_detect_best_settings
fi

# Create expiry checker cron job
cat > /etc/cron.hourly/elite-x-expiry <<'EOF'
#!/bin/bash
if [ -f /usr/local/bin/elite-x ]; then
    /usr/local/bin/elite-x --check-expiry
fi
EOF
chmod +x /etc/cron.hourly/elite-x-expiry

# ========== USER MANAGEMENT ==========
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

# ========== MAIN MENU ==========
cat >/usr/local/bin/elite-x <<'EOF'
#!/bin/bash

RED='\033[0;31m';GREEN='\033[0;32m';YELLOW='\033[1;33m';CYAN='\033[0;36m'
PURPLE='\033[0;35m';WHITE='\033[1;37m';BOLD='\033[1m';NC='\033[0m'

# Check expiry on menu start
check_expiry_menu() {
    if [ -f "/etc/elite-x/activation_type" ] && [ -f "/etc/elite-x/activation_date" ] && [ -f "/etc/elite-x/expiry_days" ]; then
        local act_type=$(cat "/etc/elite-x/activation_type")
        if [ "$act_type" = "temporary" ]; then
            local act_date=$(cat "/etc/elite-x/activation_date")
            local expiry_days=$(cat "/etc/elite-x/expiry_days")
            local current_date=$(date +%s)
            local expiry_date=$(date -d "$act_date + $expiry_days days" +%s)
            
            if [ $current_date -ge $expiry_date ]; then
                echo -e "${RED}═══════════════════════════════════════════════════════════════${NC}"
                echo -e "${YELLOW}⚠️  TRIAL PERIOD EXPIRED ⚠️${NC}"
                echo -e "${RED}Your 2-day trial has ended.${NC}"
                echo -e "${RED}Script will now uninstall itself...${NC}"
                echo -e "${RED}═══════════════════════════════════════════════════════════════${NC}"
                sleep 3
                
                # Self uninstall
                systemctl stop dnstt-elite-x dnstt-elite-x-proxy elite-x-traffic elite-x-cleaner 2>/dev/null || true
                systemctl disable dnstt-elite-x dnstt-elite-x-proxy elite-x-traffic elite-x-cleaner 2>/dev/null || true
                rm -f /etc/systemd/system/{dnstt-elite-x*,elite-x-*}
                rm -rf /etc/dnstt /etc/elite-x
                rm -f /usr/local/bin/{dnstt-*,elite-x*}
                sed -i '/^Banner/d' /etc/ssh/sshd_config
                systemctl restart sshd
                
                echo -e "${GREEN}✅ ELITE-X has been uninstalled.${NC}"
                exit 0
            fi
        fi
    fi
}

# Run expiry check
check_expiry_menu

show_dashboard() {
    clear
    IP=$(curl -s ifconfig.me 2>/dev/null || echo "Unknown")
    LOC=$(curl -s http://ip-api.com/json/$IP 2>/dev/null | jq -r '.city + ", " + .country' 2>/dev/null || echo "Unknown")
    ISP=$(curl -s http://ip-api.com/json/$IP 2>/dev/null | jq -r '.isp' 2>/dev/null || echo "Unknown")
    RAM=$(free -m | awk '/^Mem:/{print $3"/"$2"MB"}')
    SUB=$(cat /etc/elite-x/subdomain 2>/dev/null || echo "Not configured")
    KEY=$(cat /etc/elite-x/key 2>/dev/null || echo "Unknown")
    EXP=$(cat /etc/elite-x/expiry 2>/dev/null || echo "Unknown")
    LOCATION=$(cat /etc/elite-x/location 2>/dev/null || echo "South Africa")
    CURRENT_MTU=$(cat /etc/elite-x/mtu 2>/dev/null || echo "1800")
    
    DNS=$(systemctl is-active dnstt-elite-x 2>/dev/null | grep -q active && echo "${GREEN}●${NC}" || echo "${RED}●${NC}")
    PRX=$(systemctl is-active dnstt-elite-x-proxy 2>/dev/null | grep -q active && echo "${GREEN}●${NC}" || echo "${RED}●${NC}")
    
    echo -e "${CYAN}╔════════════════════════════════════════════════════════════════╗${NC}"
    echo -e "${CYAN}║${YELLOW}${BOLD}                    ELITE-X SLOWDNS v3.0                       ${CYAN}║${NC}"
    echo -e "${CYAN}╠════════════════════════════════════════════════════════════════╣${NC}"
    echo -e "${CYAN}║${WHITE}  Subdomain :${GREEN} $SUB${NC}"
    echo -e "${CYAN}║${WHITE}  IP        :${GREEN} $IP${NC}"
    echo -e "${CYAN}║${WHITE}  Location  :${GREEN} $LOC${NC}"
    echo -e "${CYAN}║${WHITE}  ISP       :${GREEN} $ISP${NC}"
    echo -e "${CYAN}║${WHITE}  RAM       :${GREEN} $RAM${NC}"
    echo -e "${CYAN}║${WHITE}  VPS Loc   :${GREEN} $LOCATION${NC}"
    echo -e "${CYAN}║${WHITE}  MTU       :${GREEN} $CURRENT_MTU${NC}"
    echo -e "${CYAN}║${WHITE}  Services  : DNS:$DNS PRX:$PRX${NC}"
    echo -e "${CYAN}║${WHITE}  Developer :${PURPLE} ELITE-X TEAM${NC}"
    echo -e "${CYAN}╠════════════════════════════════════════════════════════════════╣${NC}"
    echo -e "${CYAN}║${WHITE}  Key       :${YELLOW} $KEY${NC}"
    echo -e "${CYAN}║${WHITE}  Expiry    :${YELLOW} $EXP${NC}"
    echo -e "${CYAN}╚════════════════════════════════════════════════════════════════╝${NC}"
    echo ""
}

settings_menu() {
    while true; do
        clear
        echo -e "${CYAN}╔════════════════════════════════════════════════════════════════╗${NC}"
        echo -e "${CYAN}║${YELLOW}${BOLD}                      SETTINGS MENU                              ${CYAN}║${NC}"
        echo -e "${CYAN}╠════════════════════════════════════════════════════════════════╣${NC}"
        echo -e "${CYAN}║${WHITE}  [8]  🔑 View Public Key${NC}"
        echo -e "${CYAN}║${WHITE}  [9]  Change MTU Value (Manual)${NC}"
        echo -e "${CYAN}║${WHITE}  [10] ⚡ Manual Speed Optimization${NC}"
        echo -e "${CYAN}║${WHITE}  [11] 🧹 Clean Junk Files${NC}"
        echo -e "${CYAN}║${WHITE}  [12] 🔄 Auto Expired Account Remover${NC}"
        echo -e "${CYAN}║${WHITE}  [13] 📦 Update Script${NC}"
        echo -e "${CYAN}║${WHITE}  [14] Restart All Services${NC}"
        echo -e "${CYAN}║${WHITE}  [15] Reboot VPS${NC}"
        echo -e "${CYAN}║${WHITE}  [16] Uninstall Script${NC}"
        echo -e "${CYAN}║${WHITE}  [17] 🌍 Re-apply Location Optimization${NC}"
        echo -e "${CYAN}║${WHITE}  [0]  Back to Main Menu${NC}"
        echo -e "${CYAN}╚════════════════════════════════════════════════════════════════╝${NC}"
        echo ""
        read -p "$(echo -e $GREEN"Settings option: "$NC)" ch
        
        case $ch in
            8)
                echo -e "${CYAN}═══════════════════════════════════════════════════════════════${NC}"
                echo -e "${YELLOW}PUBLIC KEY (FULL):${NC}"
                echo -e "${GREEN}$(cat /etc/dnstt/server.pub)${NC}"
                echo -e "${CYAN}═══════════════════════════════════════════════════════════════${NC}"
                ;;
            9)
                echo "Current MTU: $(cat /etc/elite-x/mtu)"
                read -p "New MTU (1000-5000): " mtu
                [[ "$mtu" =~ ^[0-9]+$ ]] && [ $mtu -ge 1000 ] && [ $mtu -le 5000 ] && {
                    echo "$mtu" > /etc/elite-x/mtu
                    sed -i "s/-mtu [0-9]*/-mtu $mtu/" /etc/systemd/system/dnstt-elite-x.service
                    systemctl daemon-reload
                    systemctl restart dnstt-elite-x dnstt-elite-x-proxy
                    echo -e "${GREEN}✅ MTU updated${NC}"
                } || echo -e "${RED}❌ Invalid${NC}"
                ;;
            10) elite-x-speed manual ;;
            11) elite-x-speed clean ;;
            12)
                systemctl enable --now elite-x-cleaner.service
                echo -e "${GREEN}✅ Auto remover started${NC}"
                ;;
            13) elite-x-update ;;
            14)
                systemctl restart dnstt-elite-x dnstt-elite-x-proxy sshd
                echo -e "${GREEN}✅ Services restarted${NC}"
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
                    echo -e "${GREEN}✅ Uninstalled${NC}"
                    exit 0
                }
                ;;
            17)
                echo -e "${YELLOW}═══════════════════════════════════════════════════════════════${NC}"
                echo -e "${GREEN}           RE-APPLY LOCATION OPTIMIZATION                        ${NC}"
                echo -e "${YELLOW}═══════════════════════════════════════════════════════════════${NC}"
                echo -e "${WHITE}Select your VPS location:${NC}"
                echo -e "${GREEN}  1. South Africa (MTU 1800)${NC}"
                echo -e "${CYAN}  2. USA (Auto-detect best MTU)${NC}"
                echo -e "${BLUE}  3. Europe (Auto-detect best MTU)${NC}"
                echo -e "${PURPLE}  4. Asia (Auto-detect best MTU)${NC}"
                echo -e "${YELLOW}  5. Auto-detect everything${NC}"
                read -p "Choice: " opt_choice
                
                case $opt_choice in
                    1) echo "South Africa" > /etc/elite-x/location
                       echo "1800" > /etc/elite-x/mtu
                       sed -i "s/-mtu [0-9]*/-mtu 1800/" /etc/systemd/system/dnstt-elite-x.service
                       systemctl daemon-reload
                       systemctl restart dnstt-elite-x dnstt-elite-x-proxy
                       echo -e "${GREEN}✅ South Africa selected (MTU 1800)${NC}" ;;
                    2) echo "USA" > /etc/elite-x/location
                       /usr/local/bin/elite-x-optimize-usa ;;
                    3) echo "Europe" > /etc/elite-x/location
                       /usr/local/bin/elite-x-optimize-europe ;;
                    4) echo "Asia" > /etc/elite-x/location
                       /usr/local/bin/elite-x-optimize-asia ;;
                    5) echo "Auto-detect" > /etc/elite-x/location
                       /usr/local/bin/elite-x-optimize-auto ;;
                esac
                ;;
            0) return ;;
            *) echo -e "${RED}Invalid option${NC}" ;;
        esac
        read -p "Press Enter..."
    done
}

main_menu() {
    while true; do
        show_dashboard
        echo -e "${CYAN}╔════════════════════════════════════════════════════════════════╗${NC}"
        echo -e "${CYAN}║${GREEN}${BOLD}                         MAIN MENU                              ${CYAN}║${NC}"
        echo -e "${CYAN}╠════════════════════════════════════════════════════════════════╣${NC}"
        echo -e "${CYAN}║${WHITE}  [1] Create SSH + DNS User${NC}"
        echo -e "${CYAN}║${WHITE}  [2] List All Users${NC}"
        echo -e "${CYAN}║${WHITE}  [3] Lock User${NC}"
        echo -e "${CYAN}║${WHITE}  [4] Unlock User${NC}"
        echo -e "${CYAN}║${WHITE}  [5] Delete User${NC}"
        echo -e "${CYAN}║${WHITE}  [6] Create/Edit Banner${NC}"
        echo -e "${CYAN}║${WHITE}  [7] Delete Banner${NC}"
        echo -e "${CYAN}║${WHITE}  [S] ⚙️  Settings${NC}"
        echo -e "${CYAN}║${WHITE}  [00] Exit${NC}"
        echo -e "${CYAN}╚════════════════════════════════════════════════════════════════╝${NC}"
        echo ""
        read -p "$(echo -e $GREEN"Main menu option: "$NC)" ch
        
        case $ch in
            1) elite-x-user add ;;
            2) elite-x-user list ;;
            3) elite-x-user lock ;;
            4) elite-x-user unlock ;;
            5) elite-x-user del ;;
            6)
                [ -f /etc/elite-x/banner/custom ] || cp /etc/elite-x/banner/default /etc/elite-x/banner/custom
                nano /etc/elite-x/banner/custom
                cp /etc/elite-x/banner/custom /etc/elite-x/banner/ssh-banner
                systemctl restart sshd
                echo -e "${GREEN}✅ Banner saved${NC}"
                ;;
            7)
                rm -f /etc/elite-x/banner/custom
                cp /etc/elite-x/banner/default /etc/elite-x/banner/ssh-banner
                systemctl restart sshd
                echo -e "${GREEN}✅ Banner deleted${NC}"
                ;;
            [Ss]) settings_menu ;;
            00|0) exit 0 ;;
            *) echo -e "${RED}Invalid option${NC}" ;;
        esac
        read -p "Press Enter..."
    done
}

main_menu
EOF
chmod +x /usr/local/bin/elite-x

# ========== AUTO-SHOW DASHBOARD ON LOGIN ==========
# This is the key change - removes elite-x/menu requirement
cat > /etc/profile.d/elite-x-dashboard.sh <<'EOF'
#!/bin/bash
# Auto-show ELITE-X dashboard on login
if [ -f /usr/local/bin/elite-x ]; then
    /usr/local/bin/elite-x
fi
EOF
chmod +x /etc/profile.d/elite-x-dashboard.sh

# Also add to bashrc for SSH logins
cat >> ~/.bashrc <<'EOF'
# Auto-show ELITE-X dashboard
if [ -f /usr/local/bin/elite-x ] && [ -z "$ELITE_X_LOADED" ]; then
    export ELITE_X_LOADED=1
    /usr/local/bin/elite-x
fi
EOF

# Aliases (still available but not needed)
echo "alias menu='elite-x'" >> ~/.bashrc
echo "alias elitex='elite-x'" >> ~/.bashrc

echo "======================================"
echo " ELITE-X INSTALLED SUCCESSFULLY "
echo "======================================"
EXPIRY_INFO=$(cat /etc/elite-x/expiry)
FINAL_MTU=$(cat /etc/elite-x/mtu)
echo "DOMAIN  : ${TDOMAIN}"
echo "LOCATION: ${SELECTED_LOCATION}"
echo "MTU     : ${FINAL_MTU} $( [ "$SELECTED_LOCATION" = "South Africa" ] && echo "(Default)" || echo "(Auto-detected)" )"
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
