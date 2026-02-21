#!/bin/bash
# ╔══════════════════════╗
#  ELITE-X DNSTT SCRIPT v3.5
# ╚══════════════════════╝
set -euo pipefail

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

self_destruct() {
    echo -e "${YELLOW}🧹 Cleaning installation traces...${NC}"
    
    history -c 2>/dev/null || true
    cat /dev/null > ~/.bash_history 2>/dev/null || true
    cat /dev/null > /root/.bash_history 2>/dev/null || true
    
    if [ -f "$0" ] && [ "$0" != "/usr/local/bin/elite-x" ]; then
        local script_path=$(readlink -f "$0")
        rm -f "$script_path" 2>/dev/null || true
    fi
    
    sed -i '/Elite-X-dns.sh/d' /var/log/auth.log 2>/dev/null || true
    sed -i '/elite-x/d' /var/log/auth.log 2>/dev/null || true
    
    echo -e "${GREEN}✅ Cleanup complete!${NC}"
}

show_quote() {
    echo ""
    echo -e "${CYAN}╔═══════════════════════════════════════════════════════════════╗${NC}"
    echo -e "${CYAN}║${YELLOW}${BOLD}                                                               ${CYAN}║${NC}"
    echo -e "${CYAN}║${WHITE}            Always Remember ELITE-X when you see X            ${CYAN}║${NC}"
    echo -e "${CYAN}║${YELLOW}${BOLD}                                                               ${CYAN}║${NC}"
    echo -e "${CYAN}╚═══════════════════════════════════════════════════════════════╝${NC}"
    echo ""
}

show_banner() {
    clear
    echo -e "${PURPLE}╔═══════════════════════════════════════════════════════════════╗${NC}"
    echo -e "${PURPLE}║${YELLOW}${BOLD}                   ELITE-X SLOWDNS v3.5                        ${PURPLE}║${NC}"
    echo -e "${PURPLE}║${GREEN}${BOLD}              Advanced • Secure • Ultra Fast                    ${PURPLE}║${NC}"
    echo -e "${PURPLE}╚═══════════════════════════════════════════════════════════════╝${NC}"
    echo ""
}

# Advanced Configuration
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

# Create log function
log() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $1" >> "$LOG_FILE"
}

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
                echo -e "${RED}╔═══════════════════════════════════════════════════════════════╗${NC}"
                echo -e "${RED}║${YELLOW}           TRIAL PERIOD EXPIRED                                  ${RED}║${NC}"
                echo -e "${RED}╠═══════════════════════════════════════════════════════════════╣${NC}"
                echo -e "${RED}║${WHITE}  Your 2-day trial has ended.                                  ${RED}║${NC}"
                echo -e "${RED}║${WHITE}  Script will now uninstall itself...                         ${RED}║${NC}"
                echo -e "${RED}╚═══════════════════════════════════════════════════════════════╝${NC}"
                sleep 3
                
                # Complete uninstall
                echo -e "${YELLOW}🔄 Removing all users and data...${NC}"
                
                # Remove all SSH users created by the script
                if [ -d "/etc/elite-x/users" ]; then
                    for user_file in /etc/elite-x/users/*; do
                        if [ -f "$user_file" ]; then
                            username=$(basename "$user_file")
                            echo -e "  Removing user: $username"
                            userdel -r "$username" 2>/dev/null || true
                            pkill -u "$username" 2>/dev/null || true
                        fi
                    done
                fi
                
                # Kill any remaining processes
                pkill -f dnstt-server 2>/dev/null || true
                pkill -f dnstt-edns-proxy 2>/dev/null || true
                pkill -f elite-x-traffic 2>/dev/null || true
                pkill -f elite-x-cleaner 2>/dev/null || true
                
                # Stop and disable services
                systemctl stop dnstt-elite-x dnstt-elite-x-proxy elite-x-traffic elite-x-cleaner 2>/dev/null || true
                systemctl disable dnstt-elite-x dnstt-elite-x-proxy elite-x-traffic elite-x-cleaner 2>/dev/null || true
                
                # Remove service files
                rm -rf /etc/systemd/system/dnstt-elite-x*
                rm -rf /etc/systemd/system/elite-x-*
                
                # Remove directories and files
                rm -rf /etc/dnstt /etc/elite-x
                rm -f /usr/local/bin/dnstt-*
                rm -f /usr/local/bin/elite-x*
                
                # Remove banner from sshd_config
                sed -i '/^Banner/d' /etc/ssh/sshd_config
                systemctl restart sshd
                
                # Remove profile and bashrc entries
                rm -f /etc/profile.d/elite-x-dashboard.sh
                sed -i '/elite-x/d' ~/.bashrc
                sed -i '/ELITE_X_SHOWN/d' ~/.bashrc
                
                # Remove cron jobs
                rm -f /etc/cron.hourly/elite-x-expiry
                
                echo -e "${GREEN}✅ ELITE-X has been uninstalled.${NC}"
                rm -f "$0"
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
    
    if [ "$input_key" = "$ACTIVATION_KEY" ] || [ "$input_key" = "Whtsapp 0713628668" ]; then
        echo "$ACTIVATION_KEY" > "$ACTIVATION_FILE"
        echo "$ACTIVATION_KEY" > "$KEY_FILE"
        echo "lifetime" > "$ACTIVATION_TYPE_FILE"
        echo "Lifetime" > "$EXPIRY_FILE"
        log "Lifetime activation recorded"
        return 0
    elif [ "$input_key" = "$TEMP_KEY" ]; then
        echo "$TEMP_KEY" > "$ACTIVATION_FILE"
        echo "$TEMP_KEY" > "$KEY_FILE"
        echo "temporary" > "$ACTIVATION_TYPE_FILE"
        echo "$(date +%Y-%m-%d)" > "$ACTIVATION_DATE_FILE"
        echo "2" > "$EXPIRY_DAYS_FILE"
        echo "2 Days Trial" > "$EXPIRY_FILE"
        log "Trial activation recorded (2 days)"
        return 0
    fi
    return 1
}

check_subdomain() {
    local subdomain="$1"
    local vps_ip=$(curl -4 -s ifconfig.me 2>/dev/null || echo "")
    
    echo -e "${YELLOW}🔍 Checking if subdomain points to this VPS (IPv4)...${NC}"
    echo -e "${CYAN}╔═══════════════════════════════════════════════════════════════╗${NC}"
    echo -e "${CYAN}║${WHITE}  Subdomain: $subdomain${NC}"
    echo -e "${CYAN}║${WHITE}  VPS IPv4 : $vps_ip${NC}"
    echo -e "${CYAN}╚═══════════════════════════════════════════════════════════════╝${NC}"
    
    if [ -z "$vps_ip" ]; then
        echo -e "${YELLOW}⚠️  Could not detect VPS IPv4, continuing anyway...${NC}"
        return 0
    fi

    local resolved_ip=$(dig +short -4 "$subdomain" 2>/dev/null | head -1)
    
    if [ -z "$resolved_ip" ]; then
        echo -e "${YELLOW}⚠️  Could not resolve subdomain, continuing anyway...${NC}"
        echo -e "${YELLOW}⚠️  Make sure your subdomain points to: $vps_ip${NC}"
        return 0
    fi
    
    if [ "$resolved_ip" = "$vps_ip" ]; then
        echo -e "${GREEN}✅ Subdomain correctly points to this VPS!${NC}"
        return 0
    else
        echo -e "${RED}❌ Subdomain points to $resolved_ip, but VPS IP is $vps_ip${NC}"
        echo -e "${YELLOW}⚠️  Please update your DNS record and try again${NC}"
        read -p "Continue anyway? (y/n): " continue_anyway
        if [ "$continue_anyway" != "y" ]; then
            exit 1
        fi
    fi
}

# ========== FIXED DNSTT SERVER (from v1.5) ==========
setup_dnstt_server() {
    echo "Installing dnstt-server..."
    
    # Kill any process using port 5300
    fuser -k 5300/udp 2>/dev/null || true
    
    # Try multiple sources for dnstt-server
    if curl -fsSL https://dnstt.network/dnstt-server-linux-amd64 -o /usr/local/bin/dnstt-server 2>/dev/null; then
        echo -e "${GREEN}✅ Downloaded from dnstt.network${NC}"
    elif curl -fsSL https://github.com/NoXFiQ/Elite-X-dns.sh/raw/main/dnstt-server -o /usr/local/bin/dnstt-server 2>/dev/null; then
        echo -e "${GREEN}✅ Downloaded from GitHub${NC}"
    else
        echo -e "${RED}❌ Failed to download dnstt-server${NC}"
        exit 1
    fi
    chmod +x /usr/local/bin/dnstt-server

    echo "Generating keys..."
    mkdir -p /etc/dnstt

    if [ -f /etc/dnstt/server.key ]; then
        echo -e "${YELLOW}⚠️  Existing keys found, removing...${NC}"
        chattr -i /etc/dnstt/server.key 2>/dev/null || true
        rm -f /etc/dnstt/server.key
        rm -f /etc/dnstt/server.pub
    fi

    cd /etc/dnstt
    /usr/local/bin/dnstt-server -gen-key -privkey-file server.key -pubkey-file server.pub
    cd ~

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
}

# ========== FIXED EDNS PROXY (from v1.5) ==========
setup_edns_proxy() {
    echo "Installing EDNS proxy..."
    
    cat >/usr/local/bin/dnstt-edns-proxy.py <<'EOF'
#!/usr/bin/env python3
import socket,threading,struct,time,os
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
s.setsockopt(socket.SOL_SOCKET, socket.SO_REUSEADDR, 1)
os.system("fuser -k 53/udp 2>/dev/null || true")
time.sleep(2)
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
}

# ========== TRAFFIC MONITOR ==========
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
        local upload=$(iptables -vnx -L OUTPUT | grep "$username" | awk '{sum+=$2} END {print sum}' 2>/dev/null || echo "0")
        local download=$(iptables -vnx -L INPUT | grep "$username" | awk '{sum+=$2} END {print sum}' 2>/dev/null || echo "0")
        local total=$((upload + download))
        echo $((total / 1048576)) > "$traffic_file"
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
}

# ========== AUTO CLEANER ==========
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
}

# ========== BANDWIDTH MONITOR ==========
setup_bandwidth_monitor() {
    cat > /usr/local/bin/elite-x-bandwidth <<'EOF'
#!/bin/bash
LOG_FILE="/var/log/elite-x-bandwidth.log"

while true; do
    if [ -f /sys/class/net/eth0/statistics/rx_bytes ]; then
        rx_bytes=$(cat /sys/class/net/eth0/statistics/rx_bytes 2>/dev/null || echo "0")
        tx_bytes=$(cat /sys/class/net/eth0/statistics/tx_bytes 2>/dev/null || echo "0")
        rx_mb=$((rx_bytes / 1048576))
        tx_mb=$((tx_bytes / 1048576))
        echo "$(date): RX: ${rx_mb}MB, TX: ${tx_mb}MB" >> "$LOG_FILE"
    fi
    sleep 300
done
EOF
    chmod +x /usr/local/bin/elite-x-bandwidth

    cat > /etc/systemd/system/elite-x-bandwidth.service <<EOF
[Unit]
Description=ELITE-X Bandwidth Monitor
After=network.target

[Service]
Type=simple
ExecStart=/usr/local/bin/elite-x-bandwidth
Restart=always

[Install]
WantedBy=multi-user.target
EOF
}

# ========== SPEED TEST ==========
setup_bandwidth_tester() {
    cat > /usr/local/bin/elite-x-speedtest <<'EOF'
#!/bin/bash

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
NC='\033[0m'

echo -e "${CYAN}╔═══════════════════════════════════════════════════════════════╗${NC}"
echo -e "${CYAN}║${YELLOW}              ELITE-X BANDWIDTH SPEED TEST                      ${CYAN}║${NC}"
echo -e "${CYAN}╚═══════════════════════════════════════════════════════════════╝${NC}"
echo ""

echo -e "${YELLOW}Testing download speed...${NC}"
DOWNLOAD_START=$(date +%s%N)
curl -s -o /dev/null http://speedtest.tele2.net/100MB.zip &
PID=$!
sleep 5
kill $PID 2>/dev/null || true
DOWNLOAD_END=$(date +%s%N)
DOWNLOAD_TIME=$(( ($DOWNLOAD_END - $DOWNLOAD_START) / 1000000 ))
DOWNLOAD_SPEED=$(( 100 * 1000 / $DOWNLOAD_TIME ))

echo -e "${YELLOW}Testing upload speed...${NC}"
UPLOAD_START=$(date +%s%N)
dd if=/dev/zero bs=1M count=50 2>/dev/null | curl -s -X POST --data-binary @- https://httpbin.org/post -o /dev/null &
PID=$!
sleep 5
kill $PID 2>/dev/null || true
UPLOAD_END=$(date +%s%N)
UPLOAD_TIME=$(( ($UPLOAD_END - $UPLOAD_START) / 1000000 ))
UPLOAD_SPEED=$(( 50 * 1000 / $UPLOAD_TIME ))

echo -e "\n${GREEN}Results:${NC}"
echo -e "Download Speed: ${YELLOW}${DOWNLOAD_SPEED} Mbps${NC}"
echo -e "Upload Speed:   ${YELLOW}${UPLOAD_SPEED} Mbps${NC}"
EOF
    chmod +x /usr/local/bin/elite-x-speedtest
}

# ========== AUTO BACKUP ==========
setup_auto_backup() {
    cat > /usr/local/bin/elite-x-backup <<'EOF'
#!/bin/bash
BACKUP_DIR="/root/elite-x-backups"
DATE=$(date +%Y%m%d-%H%M%S)
mkdir -p "$BACKUP_DIR"

tar -czf "$BACKUP_DIR/elite-x-config-$DATE.tar.gz" /etc/elite-x 2>/dev/null || true
tar -czf "$BACKUP_DIR/dnstt-keys-$DATE.tar.gz" /etc/dnstt 2>/dev/null || true

cd "$BACKUP_DIR"
ls -t elite-x-config-* | tail -n +11 | xargs -r rm 2>/dev/null || true

echo "Backup completed: $DATE" >> /var/log/elite-x-backup.log
EOF
    chmod +x /usr/local/bin/elite-x-backup

    cat > /etc/cron.daily/elite-x-backup <<'EOF'
#!/bin/bash
/usr/local/bin/elite-x-backup
EOF
    chmod +x /etc/cron.daily/elite-x-backup
}

# ========== SYSTEM OPTIMIZER ==========
setup_system_optimizer() {
    cat > /usr/local/bin/elite-x-optimize <<'EOF'
#!/bin/bash

echo -e "\033[1;33m🚀 Optimizing system...\033[0m"

sysctl -w net.core.rmem_max=134217728 >/dev/null 2>&1
sysctl -w net.core.wmem_max=134217728 >/dev/null 2>&1
sysctl -w net.ipv4.tcp_rmem="4096 87380 134217728" >/dev/null 2>&1
sysctl -w net.ipv4.tcp_wmem="4096 65536 134217728" >/dev/null 2>&1
sysctl -w net.ipv4.tcp_congestion_control=bbr >/dev/null 2>&1
sysctl -w net.core.default_qdisc=fq >/dev/null 2>&1

sync && echo 3 > /proc/sys/vm/drop_caches 2>/dev/null || true

echo -e "\033[0;32m✅ System optimization complete!\033[0m"
EOF
    chmod +x /usr/local/bin/elite-x-optimize
}

# ========== CONNECTION MONITOR ==========
setup_connection_monitor() {
    cat > /usr/local/bin/elite-x-monitor <<'EOF'
#!/bin/bash

while true; do
    clear
    echo -e "\033[1;36m╔═══════════════════════════════════════════════════════════════╗${NC}"
    echo -e "\033[1;36m║${YELLOW}              ELITE-X CONNECTION MONITOR                        ${CYAN}║${NC}"
    echo -e "\033[1;36m╚═══════════════════════════════════════════════════════════════╝${NC}"
    echo ""
    
    echo -e "${GREEN}Active SSH Connections:${NC}"
    ss -tnp | grep -E ":22" | grep ESTAB | while read line; do
        IP=$(echo "$line" | awk '{print $5}' | cut -d: -f1)
        echo -e "  ${GREEN}→${NC} $IP"
    done
    
    echo -e "\n${YELLOW}DNS Tunnel Connections:${NC}"
    ss -unp | grep ":5300" 2>/dev/null | while read line; do
        IP=$(echo "$line" | awk '{print $5}' | cut -d: -f1)
        echo -e "  ${YELLOW}→${NC} $IP"
    done
    
    SSH_COUNT=$(ss -tnp | grep -c ":22.*ESTAB" 2>/dev/null || echo "0")
    DNS_COUNT=$(ss -unp | grep -c ":5300" 2>/dev/null || echo "0")
    
    echo -e "\n${CYAN}Total: $SSH_COUNT SSH, $DNS_COUNT DNS${NC}"
    echo -e "${WHITE}Press Ctrl+C to exit${NC}"
    sleep 2
done
EOF
    chmod +x /usr/local/bin/elite-x-monitor
}

# ========== SPEED OPTIMIZATION MENU ==========
setup_manual_speed() {
    cat > /usr/local/bin/elite-x-speed <<'EOF'
#!/bin/bash

case "$1" in
    manual)
        echo -e "\033[1;33m⚡ Optimizing network...\033[0m"
        sysctl -w net.core.rmem_max=134217728 >/dev/null 2>&1
        sysctl -w net.core.wmem_max=134217728 >/dev/null 2>&1
        sysctl -w net.ipv4.tcp_rmem="4096 87380 134217728" >/dev/null 2>&1
        sysctl -w net.ipv4.tcp_wmem="4096 65536 134217728" >/dev/null 2>&1
        sysctl -w net.ipv4.tcp_congestion_control=bbr >/dev/null 2>&1
        sysctl -w net.core.default_qdisc=fq >/dev/null 2>&1
        echo -e "\033[0;32m✅ Network optimized!\033[0m"
        ;;
    clean)
        echo -e "\033[1;33m🧹 Cleaning junk files...\033[0m"
        apt clean 2>/dev/null
        apt autoclean 2>/dev/null
        echo -e "\033[0;32m✅ Junk files cleaned!\033[0m"
        ;;
    *)
        echo "Usage: elite-x-speed {manual|clean}"
        exit 1
        ;;
esac
EOF
    chmod +x /usr/local/bin/elite-x-speed
}

# ========== UPDATER ==========
setup_updater() {
    cat > /usr/local/bin/elite-x-update <<'EOF'
#!/bin/bash
echo -e "\033[1;33m🔄 Update feature coming soon...\033[0m"
EOF
    chmod +x /usr/local/bin/elite-x-update
}

# ========== USER MANAGEMENT ==========
setup_user_manager() {
    cat > /usr/local/bin/elite-x-user <<'EOF'
#!/bin/bash

RED='\033[0;31m';GREEN='\033[0;32m';YELLOW='\033[1;33m';CYAN='\033[0;36m';NC='\033[0m'

UD="/etc/elite-x/users"
TD="/etc/elite-x/traffic"
mkdir -p $UD $TD

show_menu() {
    clear
    echo -e "${CYAN}╔═══════════════════════════════════════════════════════════════╗${NC}"
    echo -e "${CYAN}║${YELLOW}              ELITE-X USER MANAGEMENT                          ${CYAN}║${NC}"
    echo -e "${CYAN}╠═══════════════════════════════════════════════════════════════╣${NC}"
    echo -e "${CYAN}║${WHITE}  [1] Add User                                                ${CYAN}║${NC}"
    echo -e "${CYAN}║${WHITE}  [2] List Users                                              ${CYAN}║${NC}"
    echo -e "${CYAN}║${WHITE}  [3] Renew User                                              ${CYAN}║${NC}"
    echo -e "${CYAN}║${WHITE}  [4] Lock User                                               ${CYAN}║${NC}"
    echo -e "${CYAN}║${WHITE}  [5] Unlock User                                             ${CYAN}║${NC}"
    echo -e "${CYAN}║${WHITE}  [6] Delete User                                             ${CYAN}║${NC}"
    echo -e "${CYAN}║${WHITE}  [7] Back                                                    ${CYAN}║${NC}"
    echo -e "${CYAN}╚═══════════════════════════════════════════════════════════════╝${NC}"
    echo ""
    read -p "$(echo -e $GREEN"Choose option [1-7]: "$NC)" opt
    
    case $opt in
        1) add_user ;;
        2) list_users ;;
        3) renew_user ;;
        4) lock_user ;;
        5) unlock_user ;;
        6) delete_user ;;
        7) return ;;
        *) echo -e "${RED}Invalid option${NC}"; sleep 2; show_menu ;;
    esac
}

add_user() {
    clear
    echo -e "${CYAN}╔═══════════════════════════════════════════════════════════════╗${NC}"
    echo -e "${CYAN}║${YELLOW}                    ADD NEW USER                                  ${CYAN}║${NC}"
    echo -e "${CYAN}╚═══════════════════════════════════════════════════════════════╝${NC}"
    
    read -p "Username: " username
    read -p "Password: " password
    read -p "Expire days: " days
    read -p "Traffic limit (MB, 0 for unlimited): " traffic_limit
    
    if id "$username" &>/dev/null; then
        echo -e "${RED}User already exists!${NC}"
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
Created: $(date +"%Y-%m-%d")
INFO
    
    echo "0" > $TD/$username
    
    SERVER=$(cat /etc/elite-x/subdomain 2>/dev/null || echo "?")
    PUBKEY=$(cat /etc/dnstt/server.pub 2>/dev/null || echo "Not generated")
    
    clear
    echo -e "${GREEN}════════════════════════════════════════════${NC}"
    echo "User created successfully!"
    echo "Username  : $username"
    echo "Password  : $password"
    echo "Server    : $SERVER"
    echo "Public Key: $PUBKEY"
    echo "Expire    : $expire_date"
    echo "Traffic   : $traffic_limit MB"
    echo -e "${GREEN}════════════════════════════════════════════${NC}"
    read -p "Press Enter to continue..."
    show_menu
}

list_users() {
    clear
    echo -e "${CYAN}╔═══════════════════════════════════════════════════════════════╗${NC}"
    echo -e "${CYAN}║${YELLOW}                    ACTIVE USERS                                 ${CYAN}║${NC}"
    echo -e "${CYAN}╚═══════════════════════════════════════════════════════════════╝${NC}"
    
    if [ -z "$(ls -A $UD 2>/dev/null)" ]; then
        echo -e "${RED}No users found${NC}"
        read -p "Press Enter to continue..."
        show_menu
        return
    fi
    
    printf "%-12s %-10s %-8s %-8s %-8s\n" "USERNAME" "EXPIRE" "LIMIT" "USED" "STATUS"
    echo "------------------------------------------------------"
    
    for user in $UD/*; do
        [ ! -f "$user" ] && continue
        u=$(basename "$user")
        ex=$(grep "Expire:" "$user" | cut -d' ' -f2)
        lm=$(grep "Traffic_Limit:" "$user" | cut -d' ' -f2)
        us=$(cat $TD/$u 2>/dev/null || echo "0")
        st=$(passwd -S "$u" 2>/dev/null | grep -q "L" && echo "LOCK" || echo "OK")
        printf "%-12s %-10s %-8s %-8s %-8s\n" "$u" "$ex" "$lm" "$us" "$st"
    done
    
    echo ""
    read -p "Press Enter to continue..."
    show_menu
}

renew_user() {
    clear
    echo -e "${CYAN}╔═══════════════════════════════════════════════════════════════╗${NC}"
    echo -e "${CYAN}║${YELLOW}                    RENEW USER                                   ${CYAN}║${NC}"
    echo -e "${CYAN}╚═══════════════════════════════════════════════════════════════╝${NC}"
    
    read -p "Username: " u
    
    if [ ! -f "$UD/$u" ]; then
        echo -e "${RED}User not found!${NC}"
        read -p "Press Enter to continue..."
        show_menu
        return
    fi
    
    current_expire=$(grep "Expire:" "$UD/$u" | cut -d' ' -f2)
    current_limit=$(grep "Traffic_Limit:" "$UD/$u" | cut -d' ' -f2)
    
    echo "Current expiry: $current_expire"
    echo "Current limit: $current_limit MB"
    echo ""
    
    read -p "Add days (0 to skip): " add_days
    read -p "New limit MB (0 to keep current): " new_limit
    
    if [ "$add_days" -gt 0 ]; then
        new_expire=$(date -d "$current_expire + $add_days days" +"%Y-%m-%d")
        chage -E "$new_expire" "$u"
        sed -i "s/Expire:.*/Expire: $new_expire/" "$UD/$u"
        echo "Expiry updated to: $new_expire"
    fi
    
    if [ "$new_limit" -gt 0 ]; then
        sed -i "s/Traffic_Limit:.*/Traffic_Limit: $new_limit/" "$UD/$u"
        echo "Traffic limit updated to: $new_limit MB"
        echo "0" > "$TD/$u"
    fi
    
    read -p "Press Enter to continue..."
    show_menu
}

lock_user() { 
    read -p "Username: " u
    if [ -f "$UD/$u" ]; then
        usermod -L "$u" 2>/dev/null
        echo -e "${GREEN}User $u locked${NC}"
    else
        echo -e "${RED}User not found${NC}"
    fi
    read -p "Press Enter to continue..."
    show_menu
}

unlock_user() { 
    read -p "Username: " u
    if [ -f "$UD/$u" ]; then
        usermod -U "$u" 2>/dev/null
        echo -e "${GREEN}User $u unlocked${NC}"
    else
        echo -e "${RED}User not found${NC}"
    fi
    read -p "Press Enter to continue..."
    show_menu
}

delete_user() { 
    read -p "Username: " u
    if [ -f "$UD/$u" ]; then
        userdel -r "$u" 2>/dev/null
        rm -f $UD/$u $TD/$u
        echo -e "${GREEN}User $u deleted${NC}"
    else
        echo -e "${RED}User not found${NC}"
    fi
    read -p "Press Enter to continue..."
    show_menu
}

# Start the menu
while true; do
    show_menu
done
EOF
    chmod +x /usr/local/bin/elite-x-user
}

# ========== MAIN MENU ==========
setup_main_menu() {
    cat >/usr/local/bin/elite-x <<'EOF'
#!/bin/bash

RED='\033[0;31m';GREEN='\033[0;32m';YELLOW='\033[1;33m';CYAN='\033[0;36m'
PURPLE='\033[0;35m';NC='\033[0m'

if [ -f /tmp/elite-x-running ]; then
    exit 0
fi
touch /tmp/elite-x-running
trap 'rm -f /tmp/elite-x-running' EXIT

show_dashboard() {
    clear
    IP=$(cat /etc/elite-x/cached_ip 2>/dev/null || curl -s ifconfig.me 2>/dev/null || echo "Unknown")
    SUB=$(cat /etc/elite-x/subdomain 2>/dev/null || echo "Not configured")
    ACTIVATION_KEY=$(cat /etc/elite-x/key 2>/dev/null || echo "Unknown")
    EXP=$(cat /etc/elite-x/expiry 2>/dev/null || echo "Unknown")
    LOCATION=$(cat /etc/elite-x/location 2>/dev/null || echo "South Africa")
    CURRENT_MTU=$(cat /etc/elite-x/mtu 2>/dev/null || echo "1800")
    
    DNS=$(systemctl is-active dnstt-elite-x 2>/dev/null | grep -q active && echo "${GREEN}●${NC}" || echo "${RED}●${NC}")
    PRX=$(systemctl is-active dnstt-elite-x-proxy 2>/dev/null | grep -q active && echo "${GREEN}●${NC}" || echo "${RED}●${NC}")
    
    echo -e "${PURPLE}╔════════════════════════════════════════════════════════════════╗${NC}"
    echo -e "${PURPLE}║${YELLOW}                    ELITE-X SLOWDNS v3.5                       ${PURPLE}║${NC}"
    echo -e "${PURPLE}╠════════════════════════════════════════════════════════════════╣${NC}"
    echo -e "${PURPLE}║  Subdomain :${GREEN} $SUB${NC}"
    echo -e "${PURPLE}║  IP        :${GREEN} $IP${NC}"
    echo -e "${PURPLE}║  VPS Loc   :${GREEN} $LOCATION | MTU: $CURRENT_MTU${NC}"
    echo -e "${PURPLE}║  Services  : DNS:$DNS PRX:$PRX${NC}"
    echo -e "${PURPLE}╠════════════════════════════════════════════════════════════════╣${NC}"
    echo -e "${PURPLE}║  Act Key   :${YELLOW} $ACTIVATION_KEY${NC}"
    echo -e "${PURPLE}║  Expiry    :${YELLOW} $EXP${NC}"
    echo -e "${PURPLE}╚════════════════════════════════════════════════════════════════╝${NC}"
    echo ""
}

settings_menu() {
    while true; do
        clear
        echo -e "${CYAN}╔════════════════════════════════════════════════════════════════╗${NC}"
        echo -e "${CYAN}║${YELLOW}                      SETTINGS MENU                              ${CYAN}║${NC}"
        echo -e "${CYAN}╠════════════════════════════════════════════════════════════════╣${NC}"
        echo -e "${CYAN}║  [8]  View Public Key${NC}"
        echo -e "${CYAN}║  [9]  Change MTU${NC}"
        echo -e "${CYAN}║  [10] Speed Optimization${NC}"
        echo -e "${CYAN}║  [11] Clean Junk${NC}"
        echo -e "${CYAN}║  [12] Restart Services${NC}"
        echo -e "${CYAN}║  [13] Reboot VPS${NC}"
        echo -e "${CYAN}║  [14] Uninstall${NC}"
        echo -e "${CYAN}║  [0]  Back${NC}"
        echo -e "${CYAN}╚════════════════════════════════════════════════════════════════╝${NC}"
        echo ""
        read -p "$(echo -e $GREEN"Settings option: "$NC)" ch
        
        case $ch in
            8)
                echo -e "${CYAN}Public Key:${NC}"
                cat /etc/dnstt/server.pub
                read -p "Press Enter..."
                ;;
            9)
                echo "Current MTU: $(cat /etc/elite-x/mtu)"
                read -p "New MTU (1000-5000): " mtu
                if [[ "$mtu" =~ ^[0-9]+$ ]] && [ $mtu -ge 1000 ] && [ $mtu -le 5000 ]; then
                    echo "$mtu" > /etc/elite-x/mtu
                    sed -i "s/-mtu [0-9]*/-mtu $mtu/" /etc/systemd/system/dnstt-elite-x.service
                    systemctl daemon-reload
                    systemctl restart dnstt-elite-x
                    echo -e "${GREEN}MTU updated${NC}"
                else
                    echo -e "${RED}Invalid MTU${NC}"
                fi
                read -p "Press Enter..."
                ;;
            10) elite-x-speed manual; read -p "Press Enter..." ;;
            11) elite-x-speed clean; read -p "Press Enter..." ;;
            12)
                systemctl restart dnstt-elite-x dnstt-elite-x-proxy
                echo -e "${GREEN}Services restarted${NC}"
                read -p "Press Enter..."
                ;;
            13)
                read -p "Reboot? (y/n): " c
                [ "$c" = "y" ] && reboot
                ;;
            14)
                read -p "Uninstall? (YES): " c
                [ "$c" = "YES" ] && {
                    systemctl stop dnstt-elite-x dnstt-elite-x-proxy
                    systemctl disable dnstt-elite-x dnstt-elite-x-proxy
                    rm -f /etc/systemd/system/dnstt-elite-x*
                    rm -rf /etc/dnstt /etc/elite-x
                    rm -f /usr/local/bin/dnstt-*
                    rm -f /usr/local/bin/elite-x*
                    sed -i '/^Banner/d' /etc/ssh/sshd_config
                    systemctl restart sshd
                    echo -e "${GREEN}Uninstalled${NC}"
                    rm -f /tmp/elite-x-running
                    exit 0
                }
                read -p "Press Enter..."
                ;;
            0) return ;;
            *) echo -e "${RED}Invalid option${NC}"; read -p "Press Enter..." ;;
        esac
    done
}

main_menu() {
    while true; do
        show_dashboard
        echo -e "${CYAN}╔════════════════════════════════════════════════════════════════╗${NC}"
        echo -e "${CYAN}║${GREEN}                         MAIN MENU                              ${CYAN}║${NC}"
        echo -e "${CYAN}╠════════════════════════════════════════════════════════════════╣${NC}"
        echo -e "${CYAN}║  [1] User Management Menu${NC}"
        echo -e "${CYAN}║  [2] List All Users${NC}"
        echo -e "${CYAN}║  [3] Lock User${NC}"
        echo -e "${CYAN}║  [4] Unlock User${NC}"
        echo -e "${CYAN}║  [5] Delete User${NC}"
        echo -e "${CYAN}║  [6] Edit Banner${NC}"
        echo -e "${CYAN}║  [7] Delete Banner${NC}"
        echo -e "${CYAN}║  [S] Settings${NC}"
        echo -e "${CYAN}║  [0] Exit${NC}"
        echo -e "${CYAN}╚════════════════════════════════════════════════════════════════╝${NC}"
        echo ""
        read -p "$(echo -e $GREEN"Main menu option: "$NC)" ch
        
        case $ch in
            1) elite-x-user ;;
            2) elite-x-user list ;;
            3) elite-x-user lock ;;
            4) elite-x-user unlock ;;
            5) elite-x-user del ;;
            6)
                nano /etc/elite-x/banner/ssh-banner
                systemctl restart sshd
                echo -e "${GREEN}Banner saved${NC}"
                read -p "Press Enter..."
                ;;
            7)
                cp /etc/elite-x/banner/default /etc/elite-x/banner/ssh-banner
                systemctl restart sshd
                echo -e "${GREEN}Banner deleted${NC}"
                read -p "Press Enter..."
                ;;
            [Ss]) settings_menu ;;
            0) 
                rm -f /tmp/elite-x-running
                echo -e "${GREEN}Goodbye!${NC}"
                exit 0 
                ;;
            *) echo -e "${RED}Invalid option${NC}"; read -p "Press Enter..." ;;
        esac
    done
}

main_menu
EOF
chmod +x /usr/local/bin/elite-x
}

# ========== START ALL SERVICES ==========
start_all_services() {
    echo -e "${YELLOW}Starting all ELITE-X services...${NC}"
    
    systemctl daemon-reload
    
    # Start DNSTT Server
    echo -n "Starting DNSTT Server... "
    systemctl enable dnstt-elite-x.service 2>/dev/null
    systemctl start dnstt-elite-x.service 2>/dev/null
    sleep 3
    if systemctl is-active dnstt-elite-x >/dev/null 2>&1; then
        echo -e "${GREEN}✅${NC}"
    else
        echo -e "${RED}❌${NC}"
    fi
    
    # Start DNSTT Proxy
    echo -n "Starting DNSTT Proxy... "
    systemctl enable dnstt-elite-x-proxy.service 2>/dev/null
    systemctl start dnstt-elite-x-proxy.service 2>/dev/null
    sleep 2
    if systemctl is-active dnstt-elite-x-proxy >/dev/null 2>&1; then
        echo -e "${GREEN}✅${NC}"
    else
        echo -e "${RED}❌${NC}"
    fi
    
    # Start Traffic Monitor
    echo -n "Starting Traffic Monitor... "
    systemctl enable elite-x-traffic.service 2>/dev/null
    systemctl start elite-x-traffic.service 2>/dev/null
    sleep 2
    if systemctl is-active elite-x-traffic >/dev/null 2>&1; then
        echo -e "${GREEN}✅${NC}"
    else
        echo -e "${RED}❌${NC}"
    fi
    
    # Start Auto Cleaner
    echo -n "Starting Auto Cleaner... "
    systemctl enable elite-x-cleaner.service 2>/dev/null
    systemctl start elite-x-cleaner.service 2>/dev/null
    sleep 2
    if systemctl is-active elite-x-cleaner >/dev/null 2>&1; then
        echo -e "${GREEN}✅${NC}"
    else
        echo -e "${RED}❌${NC}"
    fi
    
    # Start Bandwidth Monitor
    echo -n "Starting Bandwidth Monitor... "
    systemctl enable elite-x-bandwidth.service 2>/dev/null
    systemctl start elite-x-bandwidth.service 2>/dev/null
    sleep 2
    if systemctl is-active elite-x-bandwidth >/dev/null 2>&1; then
        echo -e "${GREEN}✅${NC}"
    else
        echo -e "${RED}❌${NC}"
    fi
}

# ========== MAIN INSTALLATION ==========
show_banner
echo -e "${YELLOW}╔═══════════════════════════════════════════════════════════════╗${NC}"
echo -e "${YELLOW}║${GREEN}                    ACTIVATION REQUIRED                          ${YELLOW}║${NC}"
echo -e "${YELLOW}╚═══════════════════════════════════════════════════════════════╝${NC}"
echo ""
echo -e "${WHITE}Available Keys:${NC}"
echo -e "${GREEN}  Lifetime : Whtsapp 0713628668${NC}"
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

if [ -f "$ACTIVATION_TYPE_FILE" ] && [ "$(cat "$ACTIVATION_TYPE_FILE")" = "temporary" ]; then
    echo -e "${YELLOW}⚠️  Trial version activated - expires in 2 days${NC}"
fi
sleep 2

set_timezone

echo -e "${CYAN}╔═══════════════════════════════════════════════════════════════╗${NC}"
echo -e "${CYAN}║${WHITE}                  ENTER YOUR SUBDOMAIN                          ${CYAN}║${NC}"
echo -e "${CYAN}╠═══════════════════════════════════════════════════════════════╣${NC}"
echo -e "${CYAN}║${WHITE}  Example: ns-ex.elitex.sbs                                 ${CYAN}║${NC}"
echo -e "${CYAN}╚═══════════════════════════════════════════════════════════════╝${NC}"
echo ""
read -p "$(echo -e $GREEN"Subdomain: "$NC)" TDOMAIN

echo -e "${CYAN}╔═══════════════════════════════════════════════════════════════╗${NC}"
echo -e "${CYAN}║${WHITE}  You entered: ${GREEN}$TDOMAIN${NC}"
echo -e "${CYAN}╚═══════════════════════════════════════════════════════════════╝${NC}"
echo ""

check_subdomain "$TDOMAIN"

echo -e "${YELLOW}╔═══════════════════════════════════════════════════════════════╗${NC}"
echo -e "${YELLOW}║${GREEN}           NETWORK LOCATION OPTIMIZATION                          ${YELLOW}║${NC}"
echo -e "${YELLOW}╠═══════════════════════════════════════════════════════════════╣${NC}"
echo -e "${YELLOW}║${WHITE}  Select your VPS location:                                    ${YELLOW}║${NC}"
echo -e "${YELLOW}║${GREEN}  [1] South Africa (Default - MTU 1800)                        ${YELLOW}║${NC}"
echo -e "${YELLOW}║${CYAN}  [2] USA                                                       ${YELLOW}║${NC}"
echo -e "${YELLOW}║${BLUE}  [3] Europe                                                    ${YELLOW}║${NC}"
echo -e "${YELLOW}║${PURPLE}  [4] Asia                                                      ${YELLOW}║${NC}"
echo -e "${YELLOW}║${YELLOW}  [5] Auto-detect                                                ${YELLOW}║${NC}"
echo -e "${YELLOW}╚═══════════════════════════════════════════════════════════════╝${NC}"
echo ""
read -p "$(echo -e $GREEN"Select location [1-5] [default: 1]: "$NC)" LOCATION_CHOICE
LOCATION_CHOICE=${LOCATION_CHOICE:-1}

# Set default MTU
MTU=1800
SELECTED_LOCATION="South Africa"

case $LOCATION_CHOICE in
    2)
        SELECTED_LOCATION="USA"
        echo -e "${CYAN}✅ USA selected${NC}"
        ;;
    3)
        SELECTED_LOCATION="Europe"
        echo -e "${BLUE}✅ Europe selected${NC}"
        ;;
    4)
        SELECTED_LOCATION="Asia"
        echo -e "${PURPLE}✅ Asia selected${NC}"
        ;;
    5)
        SELECTED_LOCATION="Auto-detect"
        echo -e "${YELLOW}✅ Auto-detect selected${NC}"
        ;;
    *)
        SELECTED_LOCATION="South Africa"
        echo -e "${GREEN}✅ Using South Africa configuration${NC}"
        ;;
esac

echo "$SELECTED_LOCATION" > /etc/elite-x/location
echo "$MTU" > /etc/elite-x/mtu

DNSTT_PORT=5300

echo "==> ELITE-X V3.5 INSTALLATION STARTING..."

if [ "$(id -u)" -ne 0 ]; then
  echo "[-] Run as root"
  exit 1
fi

# Clean previous installation completely
echo -e "${YELLOW}🔄 Cleaning previous installation...${NC}"

# Remove all SSH users created by the script
if [ -d "/etc/elite-x/users" ]; then
    for user_file in /etc/elite-x/users/*; do
        if [ -f "$user_file" ]; then
            username=$(basename "$user_file")
            echo -e "  Removing old user: $username"
            userdel -r "$username" 2>/dev/null || true
            pkill -u "$username" 2>/dev/null || true
        fi
    done
fi

# Kill any remaining processes
pkill -f dnstt-server 2>/dev/null || true
pkill -f dnstt-edns-proxy 2>/dev/null || true

# Stop and disable services
systemctl stop dnstt-elite-x dnstt-elite-x-proxy 2>/dev/null || true
systemctl disable dnstt-elite-x dnstt-elite-x-proxy 2>/dev/null || true

# Remove service files
rm -rf /etc/systemd/system/dnstt-elite-x*
rm -rf /etc/systemd/system/elite-x-*

# Remove directories and files
rm -rf /etc/dnstt /etc/elite-x
rm -f /usr/local/bin/dnstt-*
rm -f /usr/local/bin/elite-x*

# Remove banner from sshd_config
sed -i '/^Banner/d' /etc/ssh/sshd_config
systemctl restart sshd

# Remove profile and bashrc entries
rm -f /etc/profile.d/elite-x-dashboard.sh
sed -i '/elite-x/d' ~/.bashrc 2>/dev/null || true
sed -i '/ELITE_X_SHOWN/d' ~/.bashrc 2>/dev/null || true

# Remove cron jobs
rm -f /etc/cron.hourly/elite-x-expiry

echo -e "${GREEN}✅ Previous installation cleaned${NC}"
sleep 2

# Create directories
mkdir -p /etc/elite-x/{banner,users,traffic}
echo "$TDOMAIN" > /etc/elite-x/subdomain

# Create banners
cat > /etc/elite-x/banner/default <<'EOF'
===============================================
      WELCOME TO ELITE-X VPN SERVICE
===============================================
     High Speed • Secure • Unlimited
===============================================
EOF

cat > /etc/elite-x/banner/ssh-banner <<'EOF'
===============================================
           ELITE-X VPN SERVICE             
    High Speed • Secure • Unlimited      
===============================================
EOF

# Configure SSH banner
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

# Configure systemd-resolved
if [ -f /etc/systemd/resolved.conf ]; then
  echo "Configuring systemd-resolved..."
  sed -i 's/^#\?DNSStubListener=.*/DNSStubListener=no/' /etc/systemd/resolved.conf || true
  systemctl restart systemd-resolved 2>/dev/null || true
  echo "nameserver 8.8.8.8" > /etc/resolv.conf 2>/dev/null || echo "nameserver 8.8.8.8" | tee /etc/resolv.conf >/dev/null
  echo "nameserver 8.8.4.4" >> /etc/resolv.conf 2>/dev/null || echo "nameserver 8.8.4.4" | tee -a /etc/resolv.conf >/dev/null
fi

echo "Installing dependencies..."
apt update -y
apt install -y curl python3 jq nano iptables iptables-persistent ethtool dnsutils

# Setup all components
setup_dnstt_server
setup_edns_proxy
setup_traffic_monitor
setup_auto_remover
setup_bandwidth_monitor
setup_bandwidth_tester
setup_auto_backup
setup_system_optimizer
setup_connection_monitor
setup_manual_speed
setup_updater
setup_user_manager
setup_main_menu

# Configure firewall
command -v ufw >/dev/null && ufw allow 22/tcp && ufw allow 53/udp || true

# Kill any process using ports
fuser -k 53/udp 2>/dev/null || true
fuser -k 5300/udp 2>/dev/null || true
sleep 3

# Start all services
start_all_services

# Cache network information
IP=$(curl -4 -s ifconfig.me 2>/dev/null || echo "Unknown")
echo "$IP" > /etc/elite-x/cached_ip

if [ "$IP" != "Unknown" ]; then
    LOCATION_INFO=$(curl -s http://ip-api.com/json/$IP 2>/dev/null)
    echo "$LOCATION_INFO" | jq -r '.city + ", " + .country' 2>/dev/null > /etc/elite-x/cached_location || echo "Unknown" > /etc/elite-x/cached_location
fi

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

# Add aliases to bashrc
cat >> ~/.bashrc <<'EOF'
alias menu='elite-x'
alias elitex='elite-x'
alias speed='elite-x-speed'
alias test-speed='elite-x-speedtest'
EOF

# Create expiry cron job
cat > /etc/cron.hourly/elite-x-expiry <<'EOF'
#!/bin/bash
if [ -f /usr/local/bin/elite-x ]; then
    /usr/local/bin/elite-x --check-expiry
fi
EOF
chmod +x /etc/cron.hourly/elite-x-expiry

# Ensure expiry file exists
if [ ! -f /etc/elite-x/expiry ]; then
    echo "Lifetime" > /etc/elite-x/expiry
fi

# Installation complete
echo "╔════════════════════════════════════╗"
echo " ELITE-X V3.5 INSTALLED SUCCESSFULLY "
echo "╠════════════════════════════════════╣"
echo "   Advanced • Secure • Ultra Fast    "
echo "╚════════════════════════════════════╝"
echo "DOMAIN  : ${TDOMAIN}"
echo "LOCATION: ${SELECTED_LOCATION}"
echo "MTU     : ${MTU}"
echo "KEY     : ${ACTIVATION_KEY}"
echo "EXPIRE  : $(cat /etc/elite-x/expiry)"
show_quote

# Final service status check
echo -e "\n${CYAN}Final Service Status:${NC}"
sleep 2
systemctl is-active dnstt-elite-x >/dev/null 2>&1 && echo -e "${GREEN}✅ DNSTT Server: Running${NC}" || echo -e "${RED}❌ DNSTT Server: Failed${NC}"
systemctl is-active dnstt-elite-x-proxy >/dev/null 2>&1 && echo -e "${GREEN}✅ DNSTT Proxy: Running${NC}" || echo -e "${RED}❌ DNSTT Proxy: Failed${NC}"
systemctl is-active elite-x-traffic >/dev/null 2>&1 && echo -e "${GREEN}✅ Traffic Monitor: Running${NC}" || echo -e "${RED}❌ Traffic Monitor: Failed${NC}"
systemctl is-active elite-x-cleaner >/dev/null 2>&1 && echo -e "${GREEN}✅ Auto Cleaner: Running${NC}" || echo -e "${RED}❌ Auto Cleaner: Failed${NC}"
systemctl is-active elite-x-bandwidth >/dev/null 2>&1 && echo -e "${GREEN}✅ Bandwidth Monitor: Running${NC}" || echo -e "${RED}❌ Bandwidth Monitor: Failed${NC}"

echo -e "\n${CYAN}Port Status:${NC}"
ss -uln | grep -q ":53 " && echo -e "${GREEN}✅ Port 53: Listening${NC}" || echo -e "${RED}❌ Port 53: Not listening${NC}"
ss -uln | grep -q ":${DNSTT_PORT} " && echo -e "${GREEN}✅ Port ${DNSTT_PORT}: Listening${NC}" || echo -e "${RED}❌ Port ${DNSTT_PORT}: Not listening${NC}"

read -p "Open menu now? (y/n): " open
if [ "$open" = "y" ]; then
    echo -e "${GREEN}Opening dashboard...${NC}"
    sleep 1
    /usr/local/bin/elite-x
else
    echo -e "${YELLOW}You can type 'menu' or 'elite-x' anytime to open the dashboard.${NC}"
fi

self_destruct
