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
ACTIVATION_FILE="/etc/elite-x/activated"
TIMEZONE="Africa/Dar_es_Salaam"

set_timezone() {
    timedatectl set-timezone $TIMEZONE 2>/dev/null || ln -sf /usr/share/zoneinfo/$TIMEZONE /etc/localtime 2>/dev/null || true
}

activate_script() {
    local input_key="$1"
    if [ "$input_key" = "$ACTIVATION_KEY" ]; then
        mkdir -p /etc/elite-x
        echo "$ACTIVATION_KEY" > "$ACTIVATION_FILE"
        echo "$(date)" >> "$ACTIVATION_FILE"
        return 0
    fi
    return 1
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
read -p "$(echo -e $CYAN"Activation Key: "$NC)" ACTIVATION_INPUT

mkdir -p /etc/elite-x
if ! activate_script "$ACTIVATION_INPUT"; then
    echo -e "${RED}❌ Invalid activation key! Installation cancelled.${NC}"
    exit 1
fi

echo -e "${GREEN}✅ Activation successful!${NC}"
sleep 1

set_timezone
read -p "$(echo -e $RED"Enter Your Subdomain (e.g., ns-ex.elitex.sbs): "$NC)" TDOMAIN
MTU=1800
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
apt install -y curl python3 jq nano iptables iptables-persistent

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

# DNSTT service
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

# EDNS proxy (minified for stability)
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
    PUBKEY=$(cat /etc/dnstt/server.pub 2>/dev/null | cut -c1-40)
    
    clear
    echo -e "${GREEN}═══════════════════════════════════════════════════════════════${NC}"
    echo -e "${YELLOW}                  USER DETAILS                                  ${NC}"
    echo -e "${GREEN}═══════════════════════════════════════════════════════════════${NC}"
    echo -e "${WHITE}Username  :${CYAN} $username${NC}"
    echo -e "${WHITE}Password  :${CYAN} $password${NC}"
    echo -e "${WHITE}Server    :${CYAN} $SERVER${NC}"
    echo -e "${WHITE}Public Key:${CYAN} $PUBKEY...${NC}"
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

show_dashboard() {
    clear
    IP=$(curl -s ifconfig.me 2>/dev/null || echo "Unknown")
    LOC=$(curl -s http://ip-api.com/json/$IP 2>/dev/null | jq -r '.city + ", " + .country' 2>/dev/null || echo "Unknown")
    ISP=$(curl -s http://ip-api.com/json/$IP 2>/dev/null | jq -r '.isp' 2>/dev/null || echo "Unknown")
    RAM=$(free -m | awk '/^Mem:/{print $3"/"$2"MB"}')
    SUB=$(cat /etc/elite-x/subdomain 2>/dev/null || echo "Not configured")
    KEY=$(cat /etc/elite-x/key 2>/dev/null)
    
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
    echo -e "${CYAN}║${WHITE}  Services  : DNS:$DNS PRX:$PRX${NC}"
    echo -e "${CYAN}║${WHITE}  Developer :${PURPLE} ELITE-X TEAM${NC}"
    echo -e "${CYAN}╠════════════════════════════════════════════════════════════════╣${NC}"
    echo -e "${CYAN}║${WHITE}  Key       :${YELLOW} $KEY${NC}"
    echo -e "${CYAN}╚════════════════════════════════════════════════════════════════╝${NC}"
    echo ""
}

settings_menu() {
    while true; do
        clear
        echo -e "${CYAN}╔════════════════════════════════════════════════════════════════╗${NC}"
        echo -e "${CYAN}║${YELLOW}${BOLD}                      SETTINGS MENU                              ${CYAN}║${NC}"
        echo -e "${CYAN}╠════════════════════════════════════════════════════════════════╣${NC}"
        echo -e "${CYAN}║${WHITE}  [8]  Change MTU Value${NC}"
        echo -e "${CYAN}║${WHITE}  [9]  ⚡ Manual Speed Optimization${NC}"
        echo -e "${CYAN}║${WHITE}  [10] 🧹 Clean Junk Files${NC}"
        echo -e "${CYAN}║${WHITE}  [11] 🔄 Auto Expired Account Remover${NC}"
        echo -e "${CYAN}║${WHITE}  [12] 📦 Update Script${NC}"
        echo -e "${CYAN}║${WHITE}  [13] Restart All Services${NC}"
        echo -e "${CYAN}║${WHITE}  [14] Reboot VPS${NC}"
        echo -e "${CYAN}║${WHITE}  [15] Uninstall Script${NC}"
        echo -e "${CYAN}║${WHITE}  [0]  Back to Main Menu${NC}"
        echo -e "${CYAN}╚════════════════════════════════════════════════════════════════╝${NC}"
        echo ""
        read -p "$(echo -e $GREEN"Settings option: "$NC)" ch
        
        case $ch in
            8)
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
            9) elite-x-speed manual ;;
            10) elite-x-speed clean ;;
            11)
                systemctl enable --now elite-x-cleaner.service
                echo -e "${GREEN}✅ Auto remover started${NC}"
                ;;
            12) elite-x-update ;;
            13)
                systemctl restart dnstt-elite-x dnstt-elite-x-proxy sshd
                echo -e "${GREEN}✅ Services restarted${NC}"
                ;;
            14)
                read -p "Reboot? (y/n): " c
                [ "$c" = "y" ] && reboot
                ;;
            15)
                read -p "Uninstall? (YES): " c
                [ "$c" = "YES" ] && {
                    systemctl stop dnstt-elite-x dnstt-elite-x-proxy elite-x-cleaner
                    systemctl disable dnstt-elite-x dnstt-elite-x-proxy elite-x-cleaner
                    rm -f /etc/systemd/system/{dnstt-elite-x*,elite-x-*}
                    rm -rf /etc/dnstt /etc/elite-x
                    rm -f /usr/local/bin/{dnstt-*,elite-x*}
                    sed -i '/^Banner/d' /etc/ssh/sshd_config
                    systemctl restart sshd
                    echo -e "${GREEN}✅ Uninstalled${NC}"
                    exit 0
                }
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

# Aliases
echo "alias menu='elite-x'" >> ~/.bashrc
echo "alias elitex='elite-x'" >> ~/.bashrc

echo "======================================"
echo " ELITE-X INSTALLED SUCCESSFULLY "
echo "======================================"
echo "DOMAIN  : ${TDOMAIN}"
echo "MTU     : ${MTU}"
echo "PUBLIC KEY:"
cat /etc/dnstt/server.pub
echo "======================================"
echo ""
echo -e "${GREEN}Type ${YELLOW}elite-x${GREEN} or ${YELLOW}menu${GREEN} to access the management panel${NC}"
echo "======================================"

read -p "Open menu now? (y/n): " open
[ "$open" = "y" ] && /usr/local/bin/elite-x
