#!/bin/bash
# ============================================
# ELITE-X DNSTT AUTO INSTALL (INTERACTIVE TDOMAIN)
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
NC='\033[0m' # No Color

# Function for colored echo
print_color() {
    echo -e "${2}${1}${NC}"
}

# Center text function
center_text() {
    local text="$1"
    local width=$(tput cols 2>/dev/null || echo 80)
    local padding=$(( (width - ${#text}) / 2 ))
    printf "%${padding}s" ''
    echo -e "$text"
}

# Function to show banner
show_banner() {
    clear
    echo -e "${RED}"
    figlet -f slant "ELITE-X" 2>/dev/null || echo "======== ELITE-X SLOWDNS ========"
    echo -e "${GREEN}           Version 3.0 - Ultimate Edition${NC}"
    echo -e "${YELLOW}================================================${NC}"
    echo ""
}

# ========== NEW: ACTIVATION SYSTEM ==========
ACTIVATION_KEY="ELITEX-2026-DAN-4D-08"
ACTIVATION_FILE="/etc/elite-x/activated"
TIMEZONE="Africa/Dar_es_Salaam"

# Set timezone to Tanzania
set_timezone() {
    timedatectl set-timezone $TIMEZONE 2>/dev/null || ln -sf /usr/share/zoneinfo/$TIMEZONE /etc/localtime 2>/dev/null || true
}

# Check activation
check_activation() {
    if [ ! -f "$ACTIVATION_FILE" ]; then
        return 1
    fi
    return 0
}

# Activate script
activate_script() {
    local input_key="$1"
    if [ "$input_key" = "$ACTIVATION_KEY" ]; then
        echo "$ACTIVATION_KEY" > "$ACTIVATION_FILE"
        echo "$(date)" >> "$ACTIVATION_FILE"
        return 0
    fi
    return 1
}

# ========== NEW: TRAFFIC MONITORING SYSTEM ==========
setup_traffic_monitor() {
    cat > /usr/local/bin/elite-x-traffic <<'EOF'
#!/bin/bash
# Traffic monitoring script

TRAFFIC_DB="/etc/elite-x/traffic"
USER_DB="/etc/elite-x/users"
mkdir -p $TRAFFIC_DB

# Function to monitor traffic for a user
monitor_user() {
    local username="$1"
    local traffic_file="$TRAFFIC_DB/$username"
    local user_file="$USER_DB/$username"
    
    if [ ! -f "$traffic_file" ]; then
        echo "0" > "$traffic_file"
    fi
    
    # Get current traffic from iptables
    if command -v iptables >/dev/null 2>&1; then
        local current=$(iptables -vnx -L OUTPUT | grep "$username" | awk '{sum+=$2} END {print sum}' 2>/dev/null || echo "0")
        current=$((current / 1048576)) # Convert to MB
        echo "$current" > "$traffic_file"
    fi
}

# Main loop
while true; do
    if [ -d "$USER_DB" ]; then
        for user_file in "$USER_DB"/*; do
            if [ -f "$user_file" ]; then
                username=$(basename "$user_file")
                monitor_user "$username"
            fi
        done
    fi
    sleep 60
done
EOF
    chmod +x /usr/local/bin/elite-x-traffic

    # Create systemd service for traffic monitoring
    cat > /etc/systemd/system/elite-x-traffic.service <<EOF
[Unit]
Description=ELITE-X Traffic Monitor
After=network.target

[Service]
Type=simple
ExecStart=/usr/local/bin/elite-x-traffic
Restart=always
RestartSec=60

[Install]
WantedBy=multi-user.target
EOF

    systemctl daemon-reload
    systemctl enable elite-x-traffic.service
    systemctl start elite-x-traffic.service
}

# ========== NEW: AUTO SPEED OPTIMIZATION ==========
setup_auto_speed() {
    cat > /usr/local/bin/elite-x-speed <<'EOF'
#!/bin/bash

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

# Optimize network for 20Mbps+
optimize_network() {
    echo -e "${YELLOW}⚡ Optimizing network for 20Mbps+ speed...${NC}"
    
    # TCP optimization
    sysctl -w net.core.rmem_max=134217728 >/dev/null 2>&1
    sysctl -w net.core.wmem_max=134217728 >/dev/null 2>&1
    sysctl -w net.ipv4.tcp_rmem="4096 87380 134217728" >/dev/null 2>&1
    sysctl -w net.ipv4.tcp_wmem="4096 65536 134217728" >/dev/null 2>&1
    sysctl -w net.core.netdev_max_backlog=5000 >/dev/null 2>&1
    sysctl -w net.ipv4.tcp_congestion_control=bbr >/dev/null 2>&1
    sysctl -w net.core.default_qdisc=fq >/dev/null 2>&1
    sysctl -w net.ipv4.tcp_notsent_lowat=16384 >/dev/null 2>&1
    sysctl -w net.ipv4.tcp_mtu_probing=1 >/dev/null 2>&1
    sysctl -w net.ipv4.tcp_slow_start_after_idle=0 >/dev/null 2>&1
    sysctl -w net.ipv4.tcp_timestamps=0 >/dev/null 2>&1
    sysctl -w net.ipv4.tcp_sack=1 >/dev/null 2>&1
    sysctl -w net.ipv4.tcp_window_scaling=1 >/dev/null 2>&1
    
    # Enable BBR if available
    if grep -q "bbr" /proc/sys/net/ipv4/tcp_available_congestion_control 2>/dev/null; then
        sysctl -w net.ipv4.tcp_congestion_control=bbr >/dev/null 2>&1
    fi
    
    # Interface optimization
    for iface in $(ls /sys/class/net/ | grep -v lo); do
        ethtool -K $iface tx off sg off tso off >/dev/null 2>&1 || true
        ip link set dev $iface mtu 9000 >/dev/null 2>&1 || true
    done
    
    # Clear cache
    sync && echo 3 > /proc/sys/vm/drop_caches 2>/dev/null || true
    
    echo -e "${GREEN}✅ Network optimized for 20Mbps+ speed!${NC}"
}

# CPU optimization
optimize_cpu() {
    echo -e "${YELLOW}⚡ Optimizing CPU performance...${NC}"
    
    # Set governor to performance
    for cpu in /sys/devices/system/cpu/cpu*/cpufreq/scaling_governor; do
        echo "performance" > "$cpu" 2>/dev/null || true
    done
    
    echo -e "${GREEN}✅ CPU optimized!${NC}"
}

# RAM optimization
optimize_ram() {
    echo -e "${YELLOW}⚡ Optimizing RAM...${NC}"
    
    # Clear cache, dentries, and inodes
    sync && echo 3 > /proc/sys/vm/drop_caches 2>/dev/null || true
    
    # Clear swap
    swapoff -a && swapon -a 2>/dev/null || true
    
    echo -e "${GREEN}✅ RAM optimized!${NC}"
}

# Clean junk files
clean_junk() {
    echo -e "${YELLOW}🧹 Cleaning junk files...${NC}"
    
    # Clean apt cache
    apt clean 2>/dev/null
    apt autoclean 2>/dev/null
    
    # Clean logs
    find /var/log -type f -name "*.log" -exec truncate -s 0 {} \; 2>/dev/null || true
    
    # Clean temp files
    rm -rf /tmp/* 2>/dev/null || true
    rm -rf /var/tmp/* 2>/dev/null || true
    
    echo -e "${GREEN}✅ Junk files cleaned!${NC}"
}

# Auto optimize every 5 seconds
auto_optimize() {
    echo -e "${GREEN}🔄 Auto optimization started (every 5 seconds)${NC}"
    while true; do
        optimize_network
        optimize_cpu
        optimize_ram
        clean_junk
        sleep 5
    done
}

case "$1" in
    auto)
        auto_optimize
        ;;
    manual)
        optimize_network
        optimize_cpu
        optimize_ram
        clean_junk
        ;;
    network)
        optimize_network
        ;;
    cpu)
        optimize_cpu
        ;;
    ram)
        optimize_ram
        ;;
    clean)
        clean_junk
        ;;
    *)
        echo "Usage: elite-x-speed {auto|manual|network|cpu|ram|clean}"
        exit 1
        ;;
esac
EOF
    chmod +x /usr/local/bin/elite-x-speed

    # Create systemd service for auto optimization
    cat > /etc/systemd/system/elite-x-speed.service <<EOF
[Unit]
Description=ELITE-X Auto Speed Optimizer
After=network.target

[Service]
Type=simple
ExecStart=/usr/local/bin/elite-x-speed auto
Restart=always
RestartSec=5

[Install]
WantedBy=multi-user.target
EOF

    systemctl daemon-reload
}

# ========== NEW: AUTO EXPIRED ACCOUNT REMOVER ==========
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
    sleep 3600 # Check every hour
done
EOF
    chmod +x /usr/local/bin/elite-x-cleaner

    # Create systemd service
    cat > /etc/systemd/system/elite-x-cleaner.service <<EOF
[Unit]
Description=ELITE-X Auto Expired Account Remover
After=network.target

[Service]
Type=simple
ExecStart=/usr/local/bin/elite-x-cleaner
Restart=always
RestartSec=3600

[Install]
WantedBy=multi-user.target
EOF

    systemctl daemon-reload
    systemctl enable elite-x-cleaner.service
    systemctl start elite-x-cleaner.service
}

# ========== NEW: UPDATE SYSTEM ==========
setup_updater() {
    cat > /usr/local/bin/elite-x-update <<'EOF'
#!/bin/bash

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

echo -e "${YELLOW}🔄 Checking for updates...${NC}"

# Backup current config
BACKUP_DIR="/root/elite-x-backup-$(date +%Y%m%d-%H%M%S)"
mkdir -p "$BACKUP_DIR"
cp -r /etc/elite-x "$BACKUP_DIR/" 2>/dev/null || true
cp -r /etc/dnstt "$BACKUP_DIR/" 2>/dev/null || true

# Download latest version
cd /tmp
rm -rf Elite-X-dns.sh
git clone https://github.com/NoXFiQ/Elite-X-dns.sh.git 2>/dev/null || {
    echo -e "${RED}❌ Failed to download update${NC}"
    exit 1
}

cd Elite-X-dns.sh
chmod +x *.sh

# Restore config
cp -r "$BACKUP_DIR/elite-x" /etc/ 2>/dev/null || true
cp -r "$BACKUP_DIR/dnstt" /etc/ 2>/dev/null || true

echo -e "${GREEN}✅ Update complete!${NC}"
echo -e "${YELLOW}Backup saved to: $BACKUP_DIR${NC}"
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
echo -e "${WHITE}Please enter activation key to continue installation${NC}"
echo ""
read -p "$(echo -e $CYAN"Activation Key: "$NC)" ACTIVATION_INPUT

# Check activation
if ! activate_script "$ACTIVATION_INPUT"; then
    echo -e "${RED}❌ Invalid activation key! Installation cancelled.${NC}"
    exit 1
fi

echo -e "${GREEN}✅ Activation successful!${NC}"
sleep 2

# Set Tanzania timezone
set_timezone

read -p "$(echo -e $RED"Enter Your Subdomain (e.g., ns-ex.elitex.sbs): "$NC)" TDOMAIN
MTU=1800
DNSTT_PORT=5300
DNS_PORT=53
############################

echo "==> ELITE-X DNSTT AUTO INSTALL STARTING..."

# Root check
if [ "$(id -u)" -ne 0 ]; then
  echo "[-] Run as root: sudo bash install.sh"
  exit 1
fi

# Create config directory
mkdir -p /etc/elite-x
mkdir -p /etc/elite-x/banner
mkdir -p /etc/elite-x/users
mkdir -p /etc/elite-x/traffic
echo "$TDOMAIN" > /etc/elite-x/subdomain
echo "$MTU" > /etc/elite-x/mtu
echo "$ACTIVATION_KEY" > /etc/elite-x/key
echo "Lifetime" > /etc/elite-x/expiry

# Create default banner
cat > /etc/elite-x/banner/default <<'EOF'
===============================================
      WELCOME TO ELITE-X VPN SERVICE
===============================================
     High Speed • Secure • Unlimited
===============================================
EOF

# Create SSH banner configuration
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
echo "==> Stopping old services..."
for svc in dnstt dnstt-server slowdns dnstt-smart dnstt-elite-x dnstt-elite-x-proxy; do
  systemctl disable --now "$svc" 2>/dev/null || true
done

# systemd-resolved fix
if [ -f /etc/systemd/resolved.conf ]; then
  echo "==> Configuring systemd-resolved..."
  sed -i 's/^#\?DNSStubListener=.*/DNSStubListener=no/' /etc/systemd/resolved.conf || true
  grep -q '^DNS=' /etc/systemd/resolved.conf \
    && sed -i 's/^DNS=.*/DNS=8.8.8.8 8.8.4.4/' /etc/systemd/resolved.conf \
    || echo "DNS=8.8.8.8 8.8.4.4" >> /etc/systemd/resolved.conf
  systemctl restart systemd-resolved
  ln -sf /run/systemd/resolve/resolv.conf /etc/resolv.conf
fi

# Dependencies
echo "==> Installing dependencies..."
apt update -y
apt install -y curl python3 figlet jq nano iptables iptables-persistent ethtool

# Install dnstt-server
echo "==> Installing dnstt-server..."
curl -fsSL https://dnstt.network/dnstt-server-linux-amd64 -o /usr/local/bin/dnstt-server
chmod +x /usr/local/bin/dnstt-server

# Keys
echo "==> Generating keys..."
mkdir -p /etc/dnstt
if [ ! -f /etc/dnstt/server.key ]; then
  cd /etc/dnstt
  dnstt-server -gen-key \
    -privkey-file /etc/dnstt/server.key \
    -pubkey-file  /etc/dnstt/server.pub
  cd ~
fi
chmod 600 /etc/dnstt/server.key
chmod 644 /etc/dnstt/server.pub

# DNSTT service
echo "==> Creating dnstt-elite-x.service..."
cat >/etc/systemd/system/dnstt-elite-x.service <<EOF
[Unit]
Description=ELITE-X DNSTT Server
After=network-online.target
Wants=network-online.target

[Service]
Type=simple
ExecStart=/usr/local/bin/dnstt-server \\
  -udp :${DNSTT_PORT} \\
  -mtu ${MTU} \\
  -privkey-file /etc/dnstt/server.key \\
  ${TDOMAIN} 127.0.0.1:22
Restart=no
KillSignal=SIGTERM
TimeoutStopSec=10
LimitNOFILE=1048576

[Install]
WantedBy=multi-user.target
EOF

# EDNS proxy
echo "==> Installing EDNS proxy..."
cat >/usr/local/bin/dnstt-edns-proxy.py <<'EOF'
#!/usr/bin/env python3
import socket, threading, struct

LISTEN_HOST="0.0.0.0"
LISTEN_PORT=53
UPSTREAM_HOST="127.0.0.1"
UPSTREAM_PORT=5300

EXTERNAL_EDNS_SIZE=512
INTERNAL_EDNS_SIZE=1800

def patch(data,size):
    if len(data)<12: return data
    try:
        qd,an,ns,ar=struct.unpack("!HHHH",data[4:12])
    except: return data
    off=12
    def skip_name(b,o):
        while o<len(b):
            l=b[o]; o+=1
            if l==0: break
            if l&0xC0==0xC0: o+=1; break
            o+=l
        return o
    for _ in range(qd):
        off=skip_name(data,off); off+=4
    for _ in range(an+ns):
        off=skip_name(data,off)
        if off+10>len(data): return data
        _,_,_,l=struct.unpack("!HHIH",data[off:off+10])
        off+=10+l
    new=bytearray(data)
    for _ in range(ar):
        off=skip_name(data,off)
        if off+10>len(data): return data
        t=struct.unpack("!H",data[off:off+2])[0]
        if t==41:
            new[off+2:off+4]=struct.pack("!H",size)
            return bytes(new)
        _,_,l=struct.unpack("!HIH",data[off+2:off+10])
        off+=10+l
    return data

def handle(sock,data,addr):
    u=socket.socket(socket.AF_INET,socket.SOCK_DGRAM)
    u.settimeout(5)
    try:
        u.sendto(patch(data,INTERNAL_EDNS_SIZE),(UPSTREAM_HOST,UPSTREAM_PORT))
        r,_=u.recvfrom(4096)
        sock.sendto(patch(r,EXTERNAL_EDNS_SIZE),addr)
    except:
        pass
    finally:
        u.close()

s=socket.socket(socket.AF_INET,socket.SOCK_DGRAM)
s.bind((LISTEN_HOST,LISTEN_PORT))
while True:
    d,a=s.recvfrom(4096)
    threading.Thread(target=handle,args=(s,d,a),daemon=True).start()
EOF

chmod +x /usr/local/bin/dnstt-edns-proxy.py

# Proxy service
echo "==> Creating dnstt-elite-x-proxy.service..."
cat >/etc/systemd/system/dnstt-elite-x-proxy.service <<EOF
[Unit]
Description=ELITE-X DNSTT EDNS Proxy
After=network-online.target dnstt-elite-x.service

[Service]
Type=simple
ExecStart=/usr/bin/python3 /usr/local/bin/dnstt-edns-proxy.py
Restart=no
KillSignal=SIGTERM
TimeoutStopSec=10

[Install]
WantedBy=multi-user.target
EOF

# Firewall
if command -v ufw >/dev/null 2>&1; then
  ufw allow 22/tcp || true
  ufw allow 53/udp || true
fi

# Start services
systemctl daemon-reload
systemctl enable dnstt-elite-x.service
systemctl enable dnstt-elite-x-proxy.service
systemctl start dnstt-elite-x.service
systemctl start dnstt-elite-x-proxy.service

# ========== SETUP NEW FEATURES ==========
setup_traffic_monitor
setup_auto_speed
setup_auto_remover
setup_updater

# Start auto speed optimization
systemctl enable elite-x-speed.service
systemctl start elite-x-speed.service

# Create user management system with traffic monitoring
cat >/usr/local/bin/elite-x-user <<'EOF'
#!/bin/bash

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
WHITE='\033[1;37m'
NC='\033[0m'

USER_DB="/etc/elite-x/users"
TRAFFIC_DB="/etc/elite-x/traffic"
mkdir -p $USER_DB
mkdir -p $TRAFFIC_DB

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
    
    # Create system user
    useradd -m -s /bin/false "$username"
    echo "$username:$password" | chpasswd
    
    # Calculate expiry date
    expire_date=$(date -d "+$days days" +"%Y-%m-%d")
    chage -E "$expire_date" "$username"
    
    # Save user info
    cat > $USER_DB/$username <<INFO
Username: $username
Password: $password
Expire: $expire_date
Traffic_Limit: $traffic_limit
Traffic_Used: 0
Created: $(date +"%Y-%m-%d %H:%M:%S")
INFO
    
    # Initialize traffic counter
    echo "0" > $TRAFFIC_DB/$username
    
    # Get server details
    SERVER=$(cat /etc/elite-x/subdomain 2>/dev/null || echo "Not configured")
    PUBKEY=$(cat /etc/dnstt/server.pub 2>/dev/null || echo "Not generated")
    
    clear
    echo -e "${GREEN}═══════════════════════════════════════════════════════════════${NC}"
    echo -e "${YELLOW}                  ELITE-X SLOW DNS DETAILS                       ${NC}"
    echo -e "${GREEN}═══════════════════════════════════════════════════════════════${NC}"
    echo -e "${WHITE}Username     :${CYAN} $username${NC}"
    echo -e "${WHITE}Password     :${CYAN} $password${NC}"
    echo -e "${WHITE}Server Name  :${CYAN} $SERVER${NC}"
    echo -e "${WHITE}Public Key   :${CYAN} $PUBKEY${NC}"
    echo -e "${WHITE}Expire Date  :${CYAN} $expire_date${NC}"
    echo -e "${WHITE}Traffic Limit:${CYAN} $traffic_limit MB${NC}"
    echo -e "${GREEN}═══════════════════════════════════════════════════════════════${NC}"
    echo -e "${YELLOW}Quote: Always Remember ELITE-X when you see X${NC}"
    echo -e "${GREEN}═══════════════════════════════════════════════════════════════${NC}"
}

list_users() {
    clear
    echo -e "${CYAN}═══════════════════════════════════════════════════════════════${NC}"
    echo -e "${YELLOW}                     LIST OF ACTIVE USERS                       ${NC}"
    echo -e "${CYAN}═══════════════════════════════════════════════════════════════${NC}"
    
    if [ -z "$(ls -A $USER_DB 2>/dev/null)" ]; then
        echo -e "${RED}No users found${NC}"
        return
    fi
    
    printf "%-15s %-12s %-12s %-12s %-10s\n" "USERNAME" "EXPIRE" "LIMIT(MB)" "USED(MB)" "STATUS"
    echo -e "${CYAN}─────────────────────────────────────────────────────────────────${NC}"
    
    for user in $USER_DB/*; do
        if [ -f "$user" ]; then
            username=$(basename "$user")
            expire=$(grep "Expire:" "$user" | cut -d' ' -f2)
            limit=$(grep "Traffic_Limit:" "$user" | cut -d' ' -f2)
            
            # Get real-time traffic usage
            if [ -f "$TRAFFIC_DB/$username" ]; then
                used=$(cat "$TRAFFIC_DB/$username" 2>/dev/null || echo "0")
            else
                used="0"
            fi
            
            # Check if user is locked
            if passwd -S "$username" 2>/dev/null | grep -q "L"; then
                status="${RED}LOCKED${NC}"
            else
                status="${GREEN}ACTIVE${NC}"
            fi
            
            printf "%-15s %-12s %-12s %-12s %-10b\n" "$username" "$expire" "$limit" "$used" "$status"
        fi
    done
    echo -e "${CYAN}═══════════════════════════════════════════════════════════════${NC}"
}

lock_user() {
    clear
    echo -e "${CYAN}═══════════════════════════════════════════════════════════════${NC}"
    echo -e "${YELLOW}                     LOCK USER                                  ${NC}"
    echo -e "${CYAN}═══════════════════════════════════════════════════════════════${NC}"
    
    read -p "$(echo -e $GREEN"Username to lock: "$NC)" username
    
    if ! id "$username" &>/dev/null; then
        echo -e "${RED}User does not exist!${NC}"
        return
    fi
    
    usermod -L "$username"
    echo -e "${GREEN}User $username has been locked!${NC}"
}

unlock_user() {
    clear
    echo -e "${CYAN}═══════════════════════════════════════════════════════════════${NC}"
    echo -e "${YELLOW}                     UNLOCK USER                                ${NC}"
    echo -e "${CYAN}═══════════════════════════════════════════════════════════════${NC}"
    
    read -p "$(echo -e $GREEN"Username to unlock: "$NC)" username
    
    if ! id "$username" &>/dev/null; then
        echo -e "${RED}User does not exist!${NC}"
        return
    fi
    
    usermod -U "$username"
    echo -e "${GREEN}User $username has been unlocked!${NC}"
}

delete_user() {
    clear
    echo -e "${CYAN}═══════════════════════════════════════════════════════════════${NC}"
    echo -e "${YELLOW}                     DELETE USER                               ${NC}"
    echo -e "${CYAN}═══════════════════════════════════════════════════════════════${NC}"
    
    read -p "$(echo -e $GREEN"Username to delete: "$NC)" username
    
    if ! id "$username" &>/dev/null; then
        echo -e "${RED}User does not exist!${NC}"
        return
    fi
    
    userdel -r "$username"
    rm -f $USER_DB/$username
    rm -f $TRAFFIC_DB/$username
    echo -e "${GREEN}User $username deleted successfully${NC}"
}

case $1 in
    add) add_user ;;
    list) list_users ;;
    lock) lock_user ;;
    unlock) unlock_user ;;
    del) delete_user ;;
    *)
        echo "Usage: elite-x-user {add|list|lock|unlock|del}"
        exit 1
        ;;
esac
EOF

chmod +x /usr/local/bin/elite-x-user

# Create management menu with all new options
cat >/usr/local/bin/elite-x <<'EOF'
#!/bin/bash

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
WHITE='\033[1;37m'
BOLD='\033[1m'
NC='\033[0m'

# Center text function
center_text() {
    local text="$1"
    local width=$(tput cols 2>/dev/null || echo 80)
    local padding=$(( (width - ${#text}) / 2 ))
    printf "%${padding}s" ''
    echo -e "$text"
}

# Banner function
show_banner() {
    clear
    echo -e "${RED}"
    figlet -f slant "ELITE-X" 2>/dev/null || echo "======== ELITE-X SLOWDNS ========"
    echo -e "${GREEN}           Version 3.0 - Ultimate Edition${NC}"
    echo -e "${YELLOW}================================================${NC}"
    echo ""
}

# Dashboard function
show_dashboard() {
    clear
    
    # Get system information
    SERVER_IP=$(curl -s ifconfig.me 2>/dev/null || echo "Unknown")
    SERVER_LOCATION=$(curl -s http://ip-api.com/json/$SERVER_IP 2>/dev/null | jq -r '.city + ", " + .country' 2>/dev/null || echo "Unknown")
    SERVER_ISP=$(curl -s http://ip-api.com/json/$SERVER_IP 2>/dev/null | jq -r '.isp' 2>/dev/null || echo "Unknown")
    TOTAL_RAM=$(free -m | awk '/^Mem:/{print $2}' 2>/dev/null || echo "0")
    USED_RAM=$(free -m | awk '/^Mem:/{print $3}' 2>/dev/null || echo "0")
    FREE_RAM=$(free -m | awk '/^Mem:/{print $4}' 2>/dev/null || echo "0")
    SERVER_TIME=$(date '+%Y-%m-%d %H:%M:%S')
    SUBDOMAIN=$(cat /etc/elite-x/subdomain 2>/dev/null || echo "Not configured")
    PUBLIC_KEY=$(cat /etc/dnstt/server.pub 2>/dev/null | cut -c1-50 || echo "Not generated")
    CURRENT_MTU=$(cat /etc/elite-x/mtu 2>/dev/null || echo "1800")
    ACTIVATION_KEY=$(cat /etc/elite-x/key 2>/dev/null || echo "ELITEX-2026-DAN-4D-08")
    EXPIRY=$(cat /etc/elite-x/expiry 2>/dev/null || echo "Lifetime")
    
    # Get running services
    DNSTT_STATUS=$(systemctl is-active dnstt-elite-x 2>/dev/null || echo "inactive")
    PROXY_STATUS=$(systemctl is-active dnstt-elite-x-proxy 2>/dev/null || echo "inactive")
    SPEED_STATUS=$(systemctl is-active elite-x-speed 2>/dev/null || echo "inactive")
    
    if [ "$DNSTT_STATUS" = "active" ]; then
        DNSTT_STATUS="${GREEN}● ACTIVE${NC}"
    else
        DNSTT_STATUS="${RED}● INACTIVE${NC}"
    fi
    
    if [ "$PROXY_STATUS" = "active" ]; then
        PROXY_STATUS="${GREEN}● ACTIVE${NC}"
    else
        PROXY_STATUS="${RED}● INACTIVE${NC}"
    fi
    
    if [ "$SPEED_STATUS" = "active" ]; then
        SPEED_STATUS="${GREEN}● ACTIVE${NC}"
    else
        SPEED_STATUS="${RED}● INACTIVE${NC}"
    fi
    
    # Count total users
    TOTAL_USERS=$(ls -1 /etc/elite-x/users 2>/dev/null | wc -l)
    
    # Main Dashboard
    echo -e "${CYAN}╔════════════════════════════════════════════════════════════════╗${NC}"
    echo -e "${CYAN}║${YELLOW}${BOLD}                    ELITE-X SLOWDNS v3.0                       ${CYAN}║${NC}"
    echo -e "${CYAN}╠════════════════════════════════════════════════════════════════╣${NC}"
    
    # System Info Box
    echo -e "${CYAN}║${WHITE}  ╔══════════════════════════════════════════════════════════════╗${CYAN}║${NC}"
    echo -e "${CYAN}║${WHITE}  ║${YELLOW}                    SYSTEM INFORMATION                       ${WHITE}║${CYAN}║${NC}"
    echo -e "${CYAN}║${WHITE}  ╠══════════════════════════════════════════════════════════════╣${CYAN}║${NC}"
    echo -e "${CYAN}║${WHITE}  ║${NC}  ${WHITE}Subdomain    :${GREEN} $SUBDOMAIN${NC}"
    echo -e "${CYAN}║${WHITE}  ║${NC}  ${WHITE}Public Key   :${GREEN} ${PUBLIC_KEY}...${NC}"
    echo -e "${CYAN}║${WHITE}  ║${NC}  ${WHITE}IP Address   :${GREEN} $SERVER_IP${NC}"
    echo -e "${CYAN}║${WHITE}  ║${NC}  ${WHITE}MTU Value    :${YELLOW} $CURRENT_MTU${NC}"
    echo -e "${CYAN}║${WHITE}  ║${NC}  ${WHITE}Location     :${GREEN} $SERVER_LOCATION${NC}"
    echo -e "${CYAN}║${WHITE}  ║${NC}  ${WHITE}ISP          :${GREEN} $SERVER_ISP${NC}"
    echo -e "${CYAN}║${WHITE}  ║${NC}  ${WHITE}Total RAM    :${GREEN} ${TOTAL_RAM} MB${NC}"
    echo -e "${CYAN}║${WHITE}  ║${NC}  ${WHITE}Used RAM     :${YELLOW} ${USED_RAM} MB${NC}"
    echo -e "${CYAN}║${WHITE}  ║${NC}  ${WHITE}Free RAM     :${GREEN} ${FREE_RAM} MB${NC}"
    echo -e "${CYAN}║${WHITE}  ║${NC}  ${WHITE}Server Time  :${GREEN} $SERVER_TIME${NC}"
    echo -e "${CYAN}║${WHITE}  ║${NC}  ${WHITE}Developer    :${PURPLE} ELITE-X TEAM${NC}"
    echo -e "${CYAN}║${WHITE}  ╚══════════════════════════════════════════════════════════════╝${CYAN}║${NC}"
    
    # Services & Users Box
    echo -e "${CYAN}║${WHITE}  ╔══════════════════════════════════════════════════════════════╗${CYAN}║${NC}"
    echo -e "${CYAN}║${WHITE}  ║${YELLOW}                    SERVICES & USERS                         ${WHITE}║${CYAN}║${NC}"
    echo -e "${CYAN}║${WHITE}  ╠══════════════════════════════════════════════════════════════╣${CYAN}║${NC}"
    echo -e "${CYAN}║${WHITE}  ║${NC}  ${WHITE}DNSTT Service : $DNSTT_STATUS${NC}"
    echo -e "${CYAN}║${WHITE}  ║${NC}  ${WHITE}Proxy Service : $PROXY_STATUS${NC}"
    echo -e "${CYAN}║${WHITE}  ║${NC}  ${WHITE}Speed Optimizer: $SPEED_STATUS${NC}"
    echo -e "${CYAN}║${WHITE}  ║${NC}  ${WHITE}Total Users  :${CYAN} $TOTAL_USERS${NC}"
    echo -e "${CYAN}║${WHITE}  ╚══════════════════════════════════════════════════════════════╝${CYAN}║${NC}"
    
    # License Box
    echo -e "${CYAN}║${WHITE}  ╔══════════════════════════════════════════════════════════════╗${CYAN}║${NC}"
    echo -e "${CYAN}║${WHITE}  ║${YELLOW}                       LICENSE INFO                           ${WHITE}║${CYAN}║${NC}"
    echo -e "${CYAN}║${WHITE}  ╠══════════════════════════════════════════════════════════════╣${CYAN}║${NC}"
    echo -e "${CYAN}║${WHITE}  ║${NC}  ${WHITE}Version      :${GREEN} 3.0 Ultimate${NC}"
    echo -e "${CYAN}║${WHITE}  ║${NC}  ${WHITE}Key          :${YELLOW} $(cat /etc/elite-x/key 2>/dev/null)${NC}"
    echo -e "${CYAN}║${WHITE}  ║${NC}  ${WHITE}Expire       :${GREEN} $(cat /etc/elite-x/expiry 2>/dev/null)${NC}"
    echo -e "${CYAN}║${WHITE}  ╚══════════════════════════════════════════════════════════════╝${CYAN}║${NC}"
    
    echo -e "${CYAN}╚════════════════════════════════════════════════════════════════╝${NC}"
    echo ""
}

# Main menu function
main_menu() {
    while true; do
        show_dashboard
        echo -e "${YELLOW}═══════════════════════════════════════════════════════════════${NC}"
        echo -e "${GREEN}${BOLD}                       MAIN MENU                                ${NC}"
        echo -e "${YELLOW}═══════════════════════════════════════════════════════════════${NC}"
        echo -e "${WHITE} [1]${CYAN} Create SSH + DNS User${NC}"
        echo -e "${WHITE} [2]${CYAN} List All Users (with real-time traffic)${NC}"
        echo -e "${WHITE} [3]${CYAN} Lock User${NC}"
        echo -e "${WHITE} [4]${CYAN} Unlock User${NC}"
        echo -e "${WHITE} [5]${CYAN} Delete User${NC}"
        echo -e "${WHITE} [6]${CYAN} Create/Edit Banner${NC}"
        echo -e "${WHITE} [7]${CYAN} Delete Banner${NC}"
        echo -e "${WHITE} [8]${CYAN} Change MTU Value${NC}"
        echo -e "${WHITE} [9]${CYAN} ⚡ Auto Speed Optimization (20Mbps+ - Every 5s)${NC}"
        echo -e "${WHITE} [10]${CYAN} 🔧 Manual Speed Optimization${NC}"
        echo -e "${WHITE} [11]${CYAN} 🧹 Clean Junk Files${NC}"
        echo -e "${WHITE} [12]${CYAN} 🔄 Auto Expired Account Remover${NC}"
        echo -e "${WHITE} [13]${CYAN} 📦 Update Script${NC}"
        echo -e "${WHITE} [14]${CYAN} Restart All Services${NC}"
        echo -e "${WHITE} [15]${CYAN} Reboot VPS${NC}"
        echo -e "${WHITE} [16]${CYAN} Uninstall Script${NC}"
        echo -e "${WHITE}[00]${RED} Exit${NC}"
        echo -e "${YELLOW}═══════════════════════════════════════════════════════════════${NC}"
        read -p "$(echo -e $GREEN"Choose option: "$NC)" choice
        
        case $choice in
            1)
                elite-x-user add
                read -p "Press Enter to continue..."
                ;;
            2)
                elite-x-user list
                read -p "Press Enter to continue..."
                ;;
            3)
                elite-x-user lock
                read -p "Press Enter to continue..."
                ;;
            4)
                elite-x-user unlock
                read -p "Press Enter to continue..."
                ;;
            5)
                elite-x-user del
                read -p "Press Enter to continue..."
                ;;
            6)
                if [ -f /etc/elite-x/banner/custom ]; then
                    nano /etc/elite-x/banner/custom
                else
                    echo -e "${YELLOW}Creating new banner file...${NC}"
                    cp /etc/elite-x/banner/default /etc/elite-x/banner/custom
                    nano /etc/elite-x/banner/custom
                fi
                cp /etc/elite-x/banner/custom /etc/elite-x/banner/ssh-banner
                systemctl restart sshd
                echo -e "${GREEN}Banner saved and applied!${NC}"
                read -p "Press Enter to continue..."
                ;;
            7)
                if [ -f /etc/elite-x/banner/custom ]; then
                    rm -f /etc/elite-x/banner/custom
                    cp /etc/elite-x/banner/default /etc/elite-x/banner/ssh-banner
                    systemctl restart sshd
                    echo -e "${GREEN}Banner deleted! Default banner restored.${NC}"
                else
                    echo -e "${YELLOW}No custom banner found.${NC}"
                fi
                read -p "Press Enter to continue..."
                ;;
            8)
                echo -e "${CYAN}═══════════════════════════════════════════════════════════════${NC}"
                echo -e "${YELLOW}Current MTU: $(cat /etc/elite-x/mtu)${NC}"
                echo -e "${WHITE}Recommended MTU values:${NC}"
                echo -e "${GREEN}1800 - Standard (Default)${NC}"
                echo -e "${GREEN}2000 - Optimized${NC}"
                echo -e "${GREEN}2200 - High Speed${NC}"
                echo -e "${GREEN}2500 - Ultra Speed${NC}"
                echo -e "${CYAN}═══════════════════════════════════════════════════════════════${NC}"
                read -p "$(echo -e $GREEN"Enter new MTU value: "$NC)" new_mtu
                
                if [[ "$new_mtu" =~ ^[0-9]+$ ]] && [ "$new_mtu" -ge 1000 ] && [ "$new_mtu" -le 5000 ]; then
                    echo "$new_mtu" > /etc/elite-x/mtu
                    sed -i "s/-mtu [0-9]*/-mtu $new_mtu/" /etc/systemd/system/dnstt-elite-x.service
                    systemctl daemon-reload
                    systemctl restart dnstt-elite-x
                    systemctl restart dnstt-elite-x-proxy
                    echo -e "${GREEN}MTU updated to $new_mtu and services restarted!${NC}"
                else
                    echo -e "${RED}Invalid MTU value! Must be between 1000-5000${NC}"
                fi
                read -p "Press Enter to continue..."
                ;;
            9)
                echo -e "${GREEN}⚡ Starting auto speed optimization (every 5 seconds)...${NC}"
                systemctl enable elite-x-speed.service
                systemctl restart elite-x-speed.service
                echo -e "${GREEN}Auto optimization activated!${NC}"
                read -p "Press Enter to continue..."
                ;;
            10)
                echo -e "${YELLOW}🔧 Running manual speed optimization...${NC}"
                elite-x-speed manual
                read -p "Press Enter to continue..."
                ;;
            11)
                echo -e "${YELLOW}🧹 Cleaning junk files...${NC}"
                elite-x-speed clean
                read -p "Press Enter to continue..."
                ;;
            12)
                echo -e "${GREEN}🔄 Auto expired account remover is running in background${NC}"
                systemctl enable elite-x-cleaner.service
                systemctl restart elite-x-cleaner.service
                echo -e "${GREEN}Service started! Expired accounts will be removed automatically.${NC}"
                read -p "Press Enter to continue..."
                ;;
            13)
                echo -e "${YELLOW}📦 Checking for updates...${NC}"
                elite-x-update
                read -p "Press Enter to continue..."
                ;;
            14)
                echo -e "${YELLOW}Restarting all services...${NC}"
                systemctl restart dnstt-elite-x
                systemctl restart dnstt-elite-x-proxy
                systemctl restart elite-x-speed
                systemctl restart elite-x-cleaner
                systemctl restart sshd
                echo -e "${GREEN}All services restarted successfully!${NC}"
                read -p "Press Enter to continue..."
                ;;
            15)
                echo -e "${RED}═══════════════════════════════════════════════════════════════${NC}"
                echo -e "${YELLOW}WARNING: This will reboot your VPS${NC}"
                echo -e "${RED}═══════════════════════════════════════════════════════════════${NC}"
                read -p "Are you sure you want to reboot? (y/n): " confirm
                if [ "$confirm" = "y" ]; then
                    echo -e "${GREEN}Rebooting in 5 seconds...${NC}"
                    sleep 5
                    reboot
                fi
                read -p "Press Enter to continue..."
                ;;
            16)
                echo -e "${RED}═══════════════════════════════════════════════════════════════${NC}"
                echo -e "${YELLOW}WARNING: This will completely uninstall ELITE-X DNSTT${NC}"
                echo -e "${RED}═══════════════════════════════════════════════════════════════${NC}"
                read -p "Are you sure you want to uninstall? (y/n): " confirm
                if [ "$confirm" = "y" ]; then
                    read -p "Type 'YES' to confirm: " confirm2
                    if [ "$confirm2" = "YES" ]; then
                        echo -e "${YELLOW}Stopping services...${NC}"
                        systemctl stop dnstt-elite-x dnstt-elite-x-proxy elite-x-speed elite-x-cleaner 2>/dev/null || true
                        systemctl disable dnstt-elite-x dnstt-elite-x-proxy elite-x-speed elite-x-cleaner 2>/dev/null || true
                        
                        echo -e "${YELLOW}Removing service files...${NC}"
                        rm -f /etc/systemd/system/dnstt-elite-x*
                        rm -f /etc/systemd/system/elite-x-*
                        
                        echo -e "${YELLOW}Removing configuration files...${NC}"
                        rm -rf /etc/dnstt
                        rm -rf /etc/elite-x
                        
                        echo -e "${YELLOW}Removing binaries...${NC}"
                        rm -f /usr/local/bin/dnstt-*
                        rm -f /usr/local/bin/elite-x*
                        
                        sed -i '/^Banner/d' /etc/ssh/sshd_config
                        systemctl restart sshd
                        
                        echo -e "${GREEN}ELITE-X DNSTT has been uninstalled successfully!${NC}"
                        exit 0
                    else
                        echo -e "${RED}Uninstall cancelled.${NC}"
                    fi
                fi
                read -p "Press Enter to continue..."
                ;;
            00|0)
                echo -e "${GREEN}Goodbye!${NC}"
                exit 0
                ;;
            *)
                echo -e "${RED}Invalid option!${NC}"
                read -p "Press Enter to continue..."
                ;;
        esac
    done
}

# Run main menu
main_menu
EOF

chmod +x /usr/local/bin/elite-x

# Create menu alias
echo "alias menu='elite-x'" >> ~/.bashrc
echo "alias elitex='elite-x'" >> ~/.bashrc

echo "======================================"
echo " ELITE-X DNSTT INSTALLED SUCCESSFULLY "
echo "======================================"
echo "DOMAIN  : ${TDOMAIN}"
echo "MTU     : ${MTU}"
echo "PUBLIC KEY:"
cat /etc/dnstt/server.pub
echo "======================================"
echo ""
echo -e "${GREEN}Type ${YELLOW}elite-x${GREEN} or ${YELLOW}menu${GREEN} to access the management panel${NC}"
echo "======================================"

# Optional: Show menu after install
read -p "Do you want to open the management menu now? (y/n): " open_menu
if [ "$open_menu" = "y" ]; then
    /usr/local/bin/elite-x
fi
