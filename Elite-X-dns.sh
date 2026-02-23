#!/bin/bash
# ╔══════════════════════╗
#  AMOKHAN-CYBER SCRIPT v1.5
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
    echo -e "${CYAN}║${WHITE}            AMOKHAN-CYBER TECH            ${CYAN}║${NC}"
    echo -e "${CYAN}║${YELLOW}${BOLD}                                                               ${CYAN}║${NC}"
    echo -e "${CYAN}╚═══════════════════════════════════════════════════════════════╝${NC}"
    echo ""
}

show_banner() {
    clear
    echo -e "${RED}╔═══════════════════════════════════════════════════════════════╗${NC}"
    echo -e "${RED}║${YELLOW}${BOLD}                 AMOKHAN-CYBER v1.5                        ${RED}║${NC}"
    echo -e "${RED}║${GREEN}${BOLD}                    Stable Edition                              ${RED}║${NC}"
    echo -e "${RED}╚═══════════════════════════════════════════════════════════════╝${NC}"
    echo ""
}
#SEHEMU YA KUBADILISHA ACTIVATION KEY NA KUANGALIA EXPIRY YA TRIAL
ACTIVATION_KEY="AMOKHAN-CYBER"
TEMP_KEY="AMOKHAN-CYBER-0011"
ACTIVATION_FILE="/etc/elite-x/activated"
ACTIVATION_TYPE_FILE="/etc/elite-x/activation_type"
ACTIVATION_DATE_FILE="/etc/elite-x/activation_date"
EXPIRY_DAYS_FILE="/etc/elite-x/expiry_days"
KEY_FILE="/etc/elite-x/key"
EXPIRY_FILE="/etc/elite-x/expiry"
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
                echo -e "${RED}╔═══════════════════════════════════════════════════════════════╗${NC}"
                echo -e "${RED}║${YELLOW}           TRIAL PERIOD EXPIRED                                  ${RED}║${NC}"
                echo -e "${RED}╠═══════════════════════════════════════════════════════════════╣${NC}"
                echo -e "${RED}║${WHITE}  Your 2-day trial has ended.                                  ${RED}║${NC}"
                echo -e "${RED}║${WHITE}  Script will now uninstall itself...                         ${RED}║${NC}"
                echo -e "${RED}╚═══════════════════════════════════════════════════════════════╝${NC}"
                sleep 3
                
                # Enhanced uninstall - remove everything
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
                
                # Remove service files and directories
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
                
                rm -f "$0"
                echo -e "${GREEN}✅ AMOKHAN-CYBER has been uninstalled.${NC}"
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
    
    if [ "$input_key" = "$ACTIVATION_KEY" ] || [ "$input_key" = "Whtsapp 0765-566-877" ]; then
        echo "$ACTIVATION_KEY" > "$ACTIVATION_FILE"
        echo "$ACTIVATION_KEY" > "$KEY_FILE"
        echo "lifetime" > "$ACTIVATION_TYPE_FILE"
        echo "Lifetime" > "$EXPIRY_FILE"
        echo -e "${GREEN}✅ Lifetime activation recorded${NC}"
        return 0
    elif [ "$input_key" = "$TEMP_KEY" ]; then
        echo "$TEMP_KEY" > "$ACTIVATION_FILE"
        echo "$TEMP_KEY" > "$KEY_FILE"
        echo "temporary" > "$ACTIVATION_TYPE_FILE"
        echo "$(date +%Y-%m-%d)" > "$ACTIVATION_DATE_FILE"
        echo "2" > "$EXPIRY_DAYS_FILE"
        echo "2 Days Trial" > "$EXPIRY_FILE"
        echo -e "${YELLOW}⚠️  Trial activation recorded (expires in 2 days)${NC}"
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
        # Monitor both upload and download traffic
        local upload=$(iptables -vnx -L OUTPUT | grep "$username" | awk '{sum+=$2} END {print sum}' 2>/dev/null || echo "0")
        local download=$(iptables -vnx -L INPUT | grep "$username" | awk '{sum+=$2} END {print sum}' 2>/dev/null || echo "0")
        local total=$((upload + download))
        echo $((total / 1048576)) > "$traffic_file"  # Convert to MB
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
Description=AMOKHAN-CYBER Traffic Monitor
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
Description=AMOKHAN-CYBER Auto Remover
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

show_banner
echo -e "${YELLOW}╔═══════════════════════════════════════════════════════════════╗${NC}"
echo -e "${YELLOW}║${GREEN}                    ACTIVATION REQUIRED                          ${YELLOW}║${NC}"
echo -e "${YELLOW}╚═══════════════════════════════════════════════════════════════╝${NC}"
echo ""
echo -e "${WHITE}Available Keys:${NC}"
echo -e "${GREEN}  Lifetime : Whtsapp 0765-556-877${NC}"
echo -e "${YELLOW}  Trial    : AMOKHAN-CYBER-0011 (2 days)${NC}"
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
echo -e "${CYAN}║${WHITE}  Example: ns-ex.amokhan.com                                 ${CYAN}║${NC}"
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
echo -e "${YELLOW}║${GREEN}  1. South Africa (Default - MTU 1800)                        ${YELLOW}║${NC}"
echo -e "${YELLOW}║${CYAN}  2. USA                                                       ${YELLOW}║${NC}"
echo -e "${YELLOW}║${BLUE}  3. Europe                                                    ${YELLOW}║${NC}"
echo -e "${YELLOW}║${PURPLE}  4. Asia                                                      ${YELLOW}║${NC}"
echo -e "${YELLOW}║${YELLOW}  5. Auto-detect                                                ${YELLOW}║${NC}"
echo -e "${YELLOW}╚═══════════════════════════════════════════════════════════════╝${NC}"
echo ""
read -p "$(echo -e $GREEN"Select location [1-5] [default: 1]: "$NC)" LOCATION_CHOICE
LOCATION_CHOICE=${LOCATION_CHOICE:-1}

# Set default MTU (always 1800 - no testing)
MTU=1800
SELECTED_LOCATION="South Africa"

case $LOCATION_CHOICE in
    2)
        SELECTED_LOCATION="USA"
        echo -e "${CYAN}✅ USA selected${NC}"
        NEED_USA_OPT=1
        ;;
    3)
        SELECTED_LOCATION="Europe"
        echo -e "${BLUE}✅ Europe selected${NC}"
        NEED_EUROPE_OPT=1
        ;;
    4)
        SELECTED_LOCATION="Asia"
        echo -e "${PURPLE}✅ Asia selected${NC}"
        NEED_ASIA_OPT=1
        ;;
    5)
        SELECTED_LOCATION="Auto-detect"
        echo -e "${YELLOW}✅ Auto-detect selected${NC}"
        NEED_AUTO_OPT=1
        ;;
    *)
        SELECTED_LOCATION="South Africa"
        echo -e "${GREEN}✅ Using South Africa configuration${NC}"
        ;;
esac

echo "$SELECTED_LOCATION" > /etc/elite-x/location
echo "$MTU" > /etc/elite-x/mtu

DNSTT_PORT=5300
DNS_PORT=53

echo "==> AMOKHAN-CYBER INSTALLATION STARTING..."

if [ "$(id -u)" -ne 0 ]; then
  echo "[-] Run as root"
  exit 1
fi

# Enhanced uninstall - remove everything before fresh installation
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
pkill -f elite-x-traffic 2>/dev/null || true
pkill -f elite-x-cleaner 2>/dev/null || true

# Stop and disable services
systemctl stop dnstt-elite-x dnstt-elite-x-proxy elite-x-traffic elite-x-cleaner 2>/dev/null || true
systemctl disable dnstt-elite-x dnstt-elite-x-proxy elite-x-traffic elite-x-cleaner 2>/dev/null || true

# Remove service files and directories (using rm -rf for directories)
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

mkdir -p /etc/elite-x/{banner,users,traffic}
echo "$TDOMAIN" > /etc/elite-x/subdomain

cat > /etc/elite-x/banner/default <<'EOF'
===============================================
      WELCOME TO AMOKHAN-CYBER
===============================================
     High Speed • Secure • Unlimited
===============================================
EOF

cat > /etc/elite-x/banner/ssh-banner <<'EOF'
************************************************
*                 AMOKHAN-CYBER                 *
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

# Fix systemd-resolved configuration - FIXED VERSION
if [ -f /etc/systemd/resolved.conf ]; then
  echo "Configuring systemd-resolved..."
  sed -i 's/^#\?DNSStubListener=.*/DNSStubListener=no/' /etc/systemd/resolved.conf || true
  grep -q '^DNS=' /etc/systemd/resolved.conf \
    && sed -i 's/^DNS=.*/DNS=8.8.8.8 8.8.4.4/' /etc/systemd/resolved.conf \
    || echo "DNS=8.8.8.8 8.8.4.4" >> /etc/systemd/resolved.conf
  systemctl restart systemd-resolved 2>/dev/null || true
  
  # Fix resolv.conf - handle read-only filesystem
  echo "Setting up /etc/resolv.conf..."
  
  # Check if resolv.conf is a symlink and remove it properly
  if [ -L /etc/resolv.conf ]; then
    rm -f /etc/resolv.conf 2>/dev/null || unlink /etc/resolv.conf 2>/dev/null || true
  fi
  
  # Try to remove immutable attribute if present
  if [ -f /etc/resolv.conf ]; then
    chattr -i /etc/resolv.conf 2>/dev/null || true
  fi
  
  # Simple approach - just create the file with echo
  echo "nameserver 8.8.8.8" > /tmp/resolv.conf
  echo "nameserver 8.8.4.4" >> /tmp/resolv.conf
  cp -f /tmp/resolv.conf /etc/resolv.conf 2>/dev/null || {
    # If cp fails, try direct write with sudo
    echo "nameserver 8.8.8.8" | sudo tee /etc/resolv.conf >/dev/null 2>&1
    echo "nameserver 8.8.4.4" | sudo tee -a /etc/resolv.conf >/dev/null 2>&1
  }
  rm -f /tmp/resolv.conf
  
  chmod 644 /etc/resolv.conf 2>/dev/null || true
  echo "✅ DNS configuration complete"
fi

echo "Installing dependencies..."
apt update -y
apt install -y curl python3 jq nano iptables iptables-persistent ethtool dnsutils python3-minimal net-tools

echo "Installing dnstt-server..."
# Try multiple sources like v1.0
if ! curl -fsSL https://dnstt.network/dnstt-server-linux-amd64 -o /usr/local/bin/dnstt-server 2>/dev/null; then
    echo -e "${YELLOW}⚠️  Primary download failed, trying alternative...${NC}"
    curl -fsSL https://github.com/NoXFiQ/Elite-X-dns.sh/raw/main/dnstt-server -o /usr/local/bin/dnstt-server 2>/dev/null || {
        echo -e "${RED}❌ Failed to download dnstt-server${NC}"
        exit 1
    }
fi
chmod +x /usr/local/bin/dnstt-server

echo "Generating keys..."
mkdir -p /etc/dnstt

# Remove existing keys if they exist
if [ -f /etc/dnstt/server.key ]; then
    echo -e "${YELLOW}⚠️  Existing keys found, removing...${NC}"
    chattr -i /etc/dnstt/server.key 2>/dev/null || true
    rm -f /etc/dnstt/server.key
    rm -f /etc/dnstt/server.pub
fi

# Generate new keys
cd /etc/dnstt
/usr/local/bin/dnstt-server -gen-key -privkey-file server.key -pubkey-file server.pub
cd ~

# Set proper permissions
chmod 600 /etc/dnstt/server.key
chmod 644 /etc/dnstt/server.pub

echo "Creating dnstt-elite-x.service..."
cat >/etc/systemd/system/dnstt-elite-x.service <<EOF
[Unit]
Description=ELITE-X DNSTT Server
After=network-online.target
Wants=network-online.target

[Service]
Type=simple
User=root
WorkingDirectory=/tmp
ExecStart=/usr/local/bin/dnstt-server -udp :${DNSTT_PORT} -mtu ${MTU} -privkey-file /etc/dnstt/server.key ${TDOMAIN} 127.0.0.1:22
Restart=always
RestartSec=5
KillSignal=SIGTERM
LimitNOFILE=1048576
StandardOutput=journal
StandardError=journal

[Install]
WantedBy=multi-user.target
EOF

echo "Installing EDNS proxy..."
cat >/usr/local/bin/dnstt-edns-proxy.py <<'EOF'
#!/usr/bin/env python3
import socket
import threading
import struct
import sys
import time
import os
import signal

L=5300
running = True

def signal_handler(sig, frame):
    global running
    running = False
    sys.stderr.write("\nShutting down...\n")
    sys.exit(0)

signal.signal(signal.SIGINT, signal_handler)
signal.signal(signal.SIGTERM, signal_handler)

def modify_edns(d, max_size):
    if len(d) < 12:
        return d
    try:
        q, a, n, r = struct.unpack("!HHHH", d[4:12])
    except:
        return d
    
    o = 12
    
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
    for _ in range(q):
        o = skip_name(d, o)
        o += 4
    
    # Skip authority and additional records
    for _ in range(a + n):
        o = skip_name(d, o)
        if o + 10 > len(d):
            return d
        try:
            _, _, _, l = struct.unpack("!HHIH", d[o:o+10])
        except:
            return d
        o += 10 + l
    
    # Look for EDNS0 OPT record in additional section
    modified = bytearray(d)
    for _ in range(r):
        o = skip_name(d, o)
        if o + 10 > len(d):
            return d
        t = struct.unpack("!H", d[o:o+2])[0]
        if t == 41:  # OPT record
            modified[o+2:o+4] = struct.pack("!H", max_size)
            return bytes(modified)
        _, _, l = struct.unpack("!HIH", d[o+2:o+10])
        o += 10 + l
    
    return d

def handle_request(sock, data, addr):
    client = socket.socket(socket.AF_INET, socket.SOCK_DGRAM)
    client.settimeout(5)
    try:
        # Forward to dnstt server
        modified_data = modify_edns(data, 1800)
        client.sendto(modified_data, ('127.0.0.1', L))
        response, _ = client.recvfrom(4096)
        modified_response = modify_edns(response, 512)
        sock.sendto(modified_response, addr)
    except Exception as e:
        sys.stderr.write(f"Error in handler: {e}\n")
    finally:
        client.close()

def main():
    global running
    
    # Try to bind to port 53
    server = socket.socket(socket.AF_INET, socket.SOCK_DGRAM)
    server.setsockopt(socket.SOL_SOCKET, socket.SO_REUSEADDR, 1)
    
    # Kill process using port 53 if any
    os.system("fuser -k 53/udp 2>/dev/null || true")
    time.sleep(2)
    
    # Try multiple times to bind
    for attempt in range(3):
        try:
            server.bind(('0.0.0.0', 53))
            sys.stderr.write(f"✅ EDNS Proxy started on port 53 (forwarding to {L})\n")
            sys.stderr.flush()
            break
        except Exception as e:
            if attempt < 2:
                sys.stderr.write(f"Attempt {attempt+1} failed, retrying...\n")
                time.sleep(2)
                os.system("fuser -k 53/udp 2>/dev/null || true")
            else:
                sys.stderr.write(f"❌ Failed to bind to port 53 after 3 attempts: {e}\n")
                sys.exit(1)
    
    while running:
        try:
            data, addr = server.recvfrom(4096)
            threading.Thread(target=handle_request, args=(server, data, addr), daemon=True).start()
        except Exception as e:
            if running:
                sys.stderr.write(f"Error in main loop: {e}\n")
                time.sleep(1)

if __name__ == "__main__":
    main()
EOF
chmod +x /usr/local/bin/dnstt-edns-proxy.py

# Test Python script syntax
echo -e "${YELLOW}Testing Python script...${NC}"
python3 -m py_compile /usr/local/bin/dnstt-edns-proxy.py || {
    echo -e "${YELLOW}⚠️  Python syntax check failed, installing python3-full...${NC}"
    apt install -y python3-full
}

cat >/etc/systemd/system/dnstt-elite-x-proxy.service <<EOF
[Unit]
Description=ELITE-X Proxy
After=network.target
Wants=network.target

[Service]
Type=simple
User=root
ExecStart=/usr/bin/python3 /usr/local/bin/dnstt-edns-proxy.py
Restart=always
RestartSec=3
StandardOutput=journal
StandardError=journal

[Install]
WantedBy=multi-user.target
EOF

# Configure firewall
command -v ufw >/dev/null && ufw allow 22/tcp && ufw allow 53/udp || true

# Kill any process using port 53 and 5300
echo -e "${YELLOW}Cleaning up ports...${NC}"
fuser -k 53/udp 2>/dev/null || true
fuser -k 5300/udp 2>/dev/null || true
sleep 3

# Start services
systemctl daemon-reload
systemctl enable dnstt-elite-x.service dnstt-elite-x-proxy.service

# Start DNSTT Server first
echo -e "${YELLOW}Starting DNSTT Server...${NC}"
systemctl start dnstt-elite-x.service
sleep 5

# Check if DNSTT Server is running
if systemctl is-active dnstt-elite-x >/dev/null 2>&1; then
    echo -e "${GREEN}✅ DNSTT Server is running${NC}"
    
    # Start Proxy
    echo -e "${YELLOW}Starting DNSTT Proxy...${NC}"
    systemctl start dnstt-elite-x-proxy.service
    sleep 3
else
    echo -e "${YELLOW}⚠️  DNSTT Server not running, checking logs...${NC}"
    journalctl -u dnstt-elite-x -n 10 --no-pager
    echo -e "${YELLOW}Attempting to start Proxy anyway...${NC}"
    systemctl start dnstt-elite-x-proxy.service
    sleep 3
fi

# Final status check
echo -e "\n${CYAN}Service Status:${NC}"
if systemctl is-active dnstt-elite-x >/dev/null 2>&1; then
    echo -e "${GREEN}✅ DNSTT Server: Running${NC}"
else
    echo -e "${RED}❌ DNSTT Server: Failed${NC}"
fi

if systemctl is-active dnstt-elite-x-proxy >/dev/null 2>&1; then
    echo -e "${GREEN}✅ DNSTT Proxy: Running${NC}"
else
    echo -e "${RED}❌ DNSTT Proxy: Failed${NC}"
    echo -e "\n${YELLOW}Proxy logs:${NC}"
    journalctl -u dnstt-elite-x-proxy -n 20 --no-pager
fi

echo -e "\n${CYAN}Port Status:${NC}"
ss -uln | grep -q ":53 " && echo -e "${GREEN}✅ Port 53: Listening${NC}" || echo -e "${RED}❌ Port 53: Not listening${NC}"
ss -uln | grep -q ":${DNSTT_PORT} " && echo -e "${GREEN}✅ Port ${DNSTT_PORT}: Listening${NC}" || echo -e "${RED}❌ Port ${DNSTT_PORT}: Not listening${NC}"

setup_traffic_monitor
setup_manual_speed
setup_auto_remover
setup_updater

if [ ! -z "${NEED_USA_OPT:-}" ]; then
    echo -e "${YELLOW}🔄 Applying USA optimizations...${NC}"
    cat >> /etc/sysctl.conf <<EOF
# ELITE-X USA Optimization
net.ipv4.tcp_rmem = 4096 87380 67108864
net.ipv4.tcp_wmem = 4096 65536 67108864
net.ipv4.tcp_congestion_control = bbr
net.core.default_qdisc = fq
net.ipv4.tcp_notsent_lowat = 16384
net.ipv4.tcp_slow_start_after_idle = 0
net.ipv4.tcp_mtu_probing = 1
EOF
    sysctl -p
    echo -e "${GREEN}✅ USA optimizations applied${NC}"
elif [ ! -z "${NEED_EUROPE_OPT:-}" ]; then
    echo -e "${YELLOW}🔄 Applying Europe optimizations...${NC}"
    cat >> /etc/sysctl.conf <<EOF
# ELITE-X Europe Optimization
net.ipv4.tcp_rmem = 4096 87380 33554432
net.ipv4.tcp_wmem = 4096 65536 33554432
net.ipv4.tcp_congestion_control = bbr
net.core.default_qdisc = fq
net.ipv4.tcp_notsent_lowat = 16384
net.ipv4.tcp_mtu_probing = 1
EOF
    sysctl -p
    echo -e "${GREEN}✅ Europe optimizations applied${NC}"
elif [ ! -z "${NEED_ASIA_OPT:-}" ]; then
    echo -e "${YELLOW}🔄 Applying Asia optimizations...${NC}"
    cat >> /etc/sysctl.conf <<EOF
# ELITE-X Asia Optimization
net.ipv4.tcp_rmem = 4096 87380 16777216
net.ipv4.tcp_wmem = 4096 65536 16777216
net.ipv4.tcp_congestion_control = bbr
net.core.default_qdisc = fq
net.ipv4.tcp_notsent_lowat = 8192
net.ipv4.tcp_mtu_probing = 1
EOF
    sysctl -p
    echo -e "${GREEN}✅ Asia optimizations applied${NC}"
elif [ ! -z "${NEED_AUTO_OPT:-}" ]; then
    echo -e "${YELLOW}🔄 Applying auto-detected optimizations...${NC}"
    # Simple latency test
    usa_latency=$(ping -c 2 -W 2 8.8.8.8 2>/dev/null | tail -1 | awk -F '/' '{print $5}' | cut -d. -f1)
    if [ ! -z "$usa_latency" ] && [ "$usa_latency" -lt 200 ]; then
        cat >> /etc/sysctl.conf <<EOF
# ELITE-X Auto USA Optimization
net.ipv4.tcp_rmem = 4096 87380 67108864
net.ipv4.tcp_wmem = 4096 65536 67108864
net.ipv4.tcp_congestion_control = bbr
net.core.default_qdisc = fq
EOF
    else
        cat >> /etc/sysctl.conf <<EOF
# ELITE-X Auto Default Optimization
net.ipv4.tcp_rmem = 4096 87380 33554432
net.ipv4.tcp_wmem = 4096 65536 33554432
net.ipv4.tcp_congestion_control = bbr
net.core.default_qdisc = fq
EOF
    fi
    sysctl -p
    echo -e "${GREEN}✅ Auto optimizations applied${NC}"
fi

for iface in $(ls /sys/class/net/ | grep -v lo); do
    ethtool -K $iface tx off sg off tso off 2>/dev/null || true
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

cat >/usr/local/bin/elite-x-user <<'EOF'
#!/bin/bash

RED='\033[0;31m';GREEN='\033[0;32m';YELLOW='\033[1;33m';CYAN='\033[0;36m';WHITE='\033[1;37m';NC='\033[0m'

# Function to show quote
show_quote() {
    echo ""
    echo -e "${CYAN}╔═══════════════════════════════════════════════════════════════╗${NC}"
    echo -e "${CYAN}║${YELLOW}${BOLD}                                                               ${CYAN}║${NC}"
    echo -e "${CYAN}║${WHITE}            Always Remember ELITE-X when you see X            ${CYAN}║${NC}"
    echo -e "${CYAN}║${YELLOW}${BOLD}                                                               ${CYAN}║${NC}"
    echo -e "${CYAN}╚═══════════════════════════════════════════════════════════════╝${NC}"
    echo ""
}

UD="/etc/elite-x/users"
TD="/etc/elite-x/traffic"
mkdir -p $UD $TD

# Function to calculate percentage
calc_percentage() {
    local used=$1
    local limit=$2
    if [ "$limit" -eq 0 ]; then
        echo "Unlimited"
    else
        local percent=$((used * 100 / limit))
        if [ $percent -ge 90 ]; then
            echo -e "${RED}${percent}%${NC}"
        elif [ $percent -ge 70 ]; then
            echo -e "${YELLOW}${percent}%${NC}"
        else
            echo -e "${GREEN}${percent}%${NC}"
        fi
    fi
}

add_user() {
    clear
    echo -e "${CYAN}╔═══════════════════════════════════════════════════════════════╗${NC}"
    echo -e "${CYAN}║${YELLOW}              CREATE SSH + DNS USER                            ${CYAN}║${NC}"
    echo -e "${CYAN}╚═══════════════════════════════════════════════════════════════╝${NC}"
    
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
    echo -e "${GREEN}╔═══════════════════════════════════════════════════════════════╗${NC}"
    echo -e "${GREEN}║${YELLOW}                  USER DETAILS                                   ${GREEN}║${NC}"
    echo -e "${GREEN}╠═══════════════════════════════════════════════════════════════╣${NC}"
    echo -e "${GREEN}║${WHITE}  Username  :${CYAN} $username${NC}"
    echo -e "${GREEN}║${WHITE}  Password  :${CYAN} $password${NC}"
    echo -e "${GREEN}║${WHITE}  Server    :${CYAN} $SERVER${NC}"
    echo -e "${GREEN}║${WHITE}  Public Key:${CYAN} $PUBKEY${NC}"
    echo -e "${GREEN}║${WHITE}  Expire    :${CYAN} $expire_date${NC}"
    echo -e "${GREEN}║${WHITE}  Traffic   :${CYAN} $traffic_limit MB${NC}"
    echo -e "${GREEN}╚═══════════════════════════════════════════════════════════════╝${NC}"
    show_quote
}

list_users() {
    clear
    echo -e "${CYAN}╔═══════════════════════════════════════════════════════════════╗${NC}"
    echo -e "${CYAN}║${YELLOW}                     ACTIVE USERS                               ${CYAN}║${NC}"
    echo -e "${CYAN}╠═══════════════════════════════════════════════════════════════╣${NC}"
    
    if [ -z "$(ls -A $UD 2>/dev/null)" ]; then
        echo -e "${RED}No users found${NC}"
        return
    fi
    
    printf "%-12s %-10s %-8s %-8s %-10s %-8s\n" "USERNAME" "EXPIRE" "LIMIT(MB)" "USED(MB)" "USAGE%" "STATUS"
    echo -e "${CYAN}─────────────────────────────────────────────────────────────────────────${NC}"
    
    for user in $UD/*; do
        [ ! -f "$user" ] && continue
        u=$(basename "$user")
        ex=$(grep "Expire:" "$user" | cut -d' ' -f2)
        lm=$(grep "Traffic_Limit:" "$user" | cut -d' ' -f2)
        us=$(cat $TD/$u 2>/dev/null || echo "0")
        
        # Calculate usage percentage
        if [ "$lm" -eq 0 ]; then
            usage_percent="Unlimited"
        else
            percent=$((us * 100 / lm))
            if [ $percent -ge 90 ]; then
                usage_percent="${RED}${percent}%${NC}"
            elif [ $percent -ge 70 ]; then
                usage_percent="${YELLOW}${percent}%${NC}"
            else
                usage_percent="${GREEN}${percent}%${NC}"
            fi
        fi
        
        st=$(passwd -S "$u" 2>/dev/null | grep -q "L" && echo "${RED}LOCK${NC}" || echo "${GREEN}OK${NC}")
        printf "%-12s %-10s %-8s %-8s %-10b %-8b\n" "$u" "$ex" "$lm" "$us" "$usage_percent" "$st"
    done
    echo -e "${CYAN}╚═══════════════════════════════════════════════════════════════╝${NC}"
    echo ""
    echo -e "${YELLOW}Note: Traffic usage updates every 60 seconds${NC}"
    show_quote
}

lock_user() { 
    read -p "Username: " u
    usermod -L "$u" 2>/dev/null && echo -e "${GREEN}✅ Locked${NC}" || echo -e "${RED}❌ Failed${NC}"
    show_quote
}

unlock_user() { 
    read -p "Username: " u
    usermod -U "$u" 2>/dev/null && echo -e "${GREEN}✅ Unlocked${NC}" || echo -e "${RED}❌ Failed${NC}"
    show_quote
}

delete_user() { 
    read -p "Username: " u
    userdel -r "$u" 2>/dev/null
    rm -f $UD/$u $TD/$u
    echo -e "${GREEN}✅ Deleted${NC}"
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

# ========== MAIN MENU ==========
cat >/usr/local/bin/elite-x <<'EOF'
#!/bin/bash

RED='\033[0;31m';GREEN='\033[0;32m';YELLOW='\033[1;33m';CYAN='\033[0;36m'
PURPLE='\033[0;35m';WHITE='\033[1;37m';BOLD='\033[1m';NC='\033[0m'

show_quote() {
    echo ""
    echo -e "${CYAN}╔═══════════════════════════════════════════════════════════════╗${NC}"
    echo -e "${CYAN}║${YELLOW}${BOLD}                                                               ${CYAN}║${NC}"
    echo -e "${CYAN}║${WHITE}            Always Remember ELITE-X when you see X            ${CYAN}║${NC}"
    echo -e "${CYAN}║${YELLOW}${BOLD}                                                               ${CYAN}║${NC}"
    echo -e "${CYAN}╚═══════════════════════════════════════════════════════════════╝${NC}"
    echo ""
}

if [ -f /tmp/elite-x-running ]; then
    exit 0
fi
touch /tmp/elite-x-running
trap 'rm -f /tmp/elite-x-running' EXIT

check_expiry_menu() {
    if [ -f "/etc/elite-x/activation_type" ] && [ -f "/etc/elite-x/activation_date" ] && [ -f "/etc/elite-x/expiry_days" ]; then
        local act_type=$(cat "/etc/elite-x/activation_type")
        if [ "$act_type" = "temporary" ]; then
            local act_date=$(cat "/etc/elite-x/activation_date")
            local expiry_days=$(cat "/etc/elite-x/expiry_days")
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
                
                # Remove service files and directories
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
                
                echo -e "${GREEN}✅ AMOKHAN-CYBER has been uninstalled.${NC}"
                rm -f /tmp/elite-x-running
                exit 0
            fi
        fi
    fi
}

check_expiry_menu

show_dashboard() {
    clear
    
    IP=$(cat /etc/elite-x/cached_ip 2>/dev/null || curl -s ifconfig.me 2>/dev/null || echo "Unknown")
    LOC=$(cat /etc/elite-x/cached_location 2>/dev/null || echo "Unknown")
    ISP=$(cat /etc/elite-x/cached_isp 2>/dev/null || echo "Unknown")
    RAM=$(free -m | awk '/^Mem:/{print $3"/"$2"MB"}')
    SUB=$(cat /etc/elite-x/subdomain 2>/dev/null || echo "Not configured")
    ACTIVATION_KEY=$(cat /etc/elite-x/key 2>/dev/null || echo "Unknown")
    
    # Fix expiry display
    if [ -f "/etc/elite-x/expiry" ]; then
        EXP=$(cat /etc/elite-x/expiry)
    else
        EXP="Lifetime"
        echo "Lifetime" > /etc/elite-x/expiry
    fi
    
    LOCATION=$(cat /etc/elite-x/location 2>/dev/null || echo "South Africa")
    CURRENT_MTU=$(cat /etc/elite-x/mtu 2>/dev/null || echo "1800")
    
    DNS=$(systemctl is-active dnstt-elite-x 2>/dev/null | grep -q active && echo "${GREEN}●${NC}" || echo "${RED}●${NC}")
    PRX=$(systemctl is-active dnstt-elite-x-proxy 2>/dev/null | grep -q active && echo "${GREEN}●${NC}" || echo "${RED}●${NC}")
    
    echo -e "${CYAN}╔════════════════════════════════════════════════════════════════╗${NC}"
    echo -e "${CYAN}║${YELLOW}${BOLD}                    AMOKHAN-CYBER SLOWDNS v1.5                       ${CYAN}║${NC}"
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
    echo -e "${CYAN}║${WHITE}  Act Key   :${YELLOW} $ACTIVATION_KEY${NC}"
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
                echo -e "${CYAN}╔═══════════════════════════════════════════════════════════════╗${NC}"
                echo -e "${CYAN}║${YELLOW}                    PUBLIC KEY (FULL)                           ${CYAN}║${NC}"
                echo -e "${CYAN}╠═══════════════════════════════════════════════════════════════╣${NC}"
                echo -e "${CYAN}║${GREEN}  $(cat /etc/dnstt/server.pub)${NC}"
                echo -e "${CYAN}╚═══════════════════════════════════════════════════════════════╝${NC}"
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
                    echo -e "${GREEN}✅ MTU updated to $mtu${NC}"
                } || echo -e "${RED}❌ Invalid (must be 1000-5000)${NC}"
                read -p "Press Enter to continue..."
                ;;
            10) elite-x-speed manual; read -p "Press Enter to continue..." ;;
            11) elite-x-speed clean; read -p "Press Enter to continue..." ;;
            12)
                systemctl enable --now elite-x-cleaner.service
                echo -e "${GREEN}✅ Auto remover started${NC}"
                read -p "Press Enter to continue..."
                ;;
            13) elite-x-update; read -p "Press Enter to continue..." ;;
            14)
                systemctl restart dnstt-elite-x dnstt-elite-x-proxy sshd
                echo -e "${GREEN}✅ Services restarted${NC}"
                read -p "Press Enter to continue..."
                ;;
            15)
                read -p "Reboot? (y/n): " c
                [ "$c" = "y" ] && reboot
                ;;
            16)
                read -p "Uninstall? (YES): " c
                [ "$c" = "YES" ] && {
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
                    
                    # Remove service files and directories
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
                    
                    echo -e "${GREEN}✅ Uninstalled completely${NC}"
                    rm -f /tmp/elite-x-running
                    exit 0
                }
                read -p "Press Enter to continue..."
                ;;
            17)
                echo -e "${YELLOW}═══════════════════════════════════════════════════════════════${NC}"
                echo -e "${GREEN}           RE-APPLY LOCATION OPTIMIZATION                        ${NC}"
                echo -e "${YELLOW}═══════════════════════════════════════════════════════════════${NC}"
                echo -e "${WHITE}Select your VPS location:${NC}"
                echo -e "${GREEN}  1. South Africa (MTU 1800)${NC}"
                echo -e "${CYAN}  2. USA${NC}"
                echo -e "${BLUE}  3. Europe${NC}"
                echo -e "${PURPLE}  4. Asia${NC}"
                echo -e "${YELLOW}  5. Auto-detect${NC}"
                read -p "Choice: " opt_choice
                
                case $opt_choice in
                    1) echo "South Africa" > /etc/elite-x/location
                       echo "1800" > /etc/elite-x/mtu
                       sed -i "s/-mtu [0-9]*/-mtu 1800/" /etc/systemd/system/dnstt-elite-x.service
                       systemctl daemon-reload
                       systemctl restart dnstt-elite-x dnstt-elite-x-proxy
                       echo -e "${GREEN}✅ South Africa selected (MTU 1800)${NC}" ;;
                    2) echo "USA" > /etc/elite-x/location
                       echo -e "${GREEN}✅ USA selected${NC}" ;;
                    3) echo "Europe" > /etc/elite-x/location
                       echo -e "${GREEN}✅ Europe selected${NC}" ;;
                    4) echo "Asia" > /etc/elite-x/location
                       echo -e "${GREEN}✅ Asia selected${NC}" ;;
                    5) echo "Auto-detect" > /etc/elite-x/location
                       echo -e "${GREEN}✅ Auto-detect selected${NC}" ;;
                esac
                read -p "Press Enter to continue..."
                ;;
            0) return ;;
            *) echo -e "${RED}Invalid option${NC}"; read -p "Press Enter to continue..." ;;
        esac
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
        echo -e "${CYAN}║${RED}  [S] ⚙️  Settings${NC}"
        echo -e "${CYAN}║${WHITE}  [00] Exit${NC}"
        echo -e "${CYAN}╚════════════════════════════════════════════════════════════════╝${NC}"
        echo ""
        read -p "$(echo -e $GREEN"Main menu option: "$NC)" ch
        
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
                echo -e "${GREEN}✅ Banner saved${NC}"
                read -p "Press Enter to continue..."
                ;;
            7)
                rm -f /etc/elite-x/banner/custom
                cp /etc/elite-x/banner/default /etc/elite-x/banner/ssh-banner
                systemctl restart sshd
                echo -e "${GREEN}✅ Banner deleted${NC}"
                read -p "Press Enter to continue..."
                ;;
            [Ss]) settings_menu ;;
            00|0) 
                rm -f /tmp/elite-x-running
                show_quote
                echo -e "${GREEN}Goodbye!${NC}"
                exit 0 
                ;;
            *) echo -e "${RED}Invalid option${NC}"; read -p "Press Enter to continue..." ;;
        esac
    done
}

main_menu
EOF
chmod +x /usr/local/bin/elite-x

echo "Caching network information for fast login..."
IP=$(curl -4 -s ifconfig.me 2>/dev/null || echo "Unknown")
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
    # Clear any existing lock file
    rm -f /tmp/elite-x-running 2>/dev/null
    # Show the dashboard directly
    /usr/local/bin/elite-x
fi
EOF
chmod +x /etc/profile.d/elite-x-dashboard.sh

cat >> ~/.bashrc <<'EOF'
# Auto-show ELITE-X dashboard
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
        echo "$ACTIVATION_KEY" > /etc/elite-x/key
    fi
fi

# Ensure expiry file exists
if [ ! -f /etc/elite-x/expiry ]; then
    echo "Lifetime" > /etc/elite-x/expiry
fi

echo "╔════════════════════════════════════╗"
echo " AMOKHAN-CYBER INSTALLED SUCCESSFULLY "
echo "╚════════════════════════════════════╝"
EXPIRY_INFO=$(cat /etc/elite-x/expiry 2>/dev/null || echo "Lifetime")
FINAL_MTU=$(cat /etc/elite-x/mtu 2>/dev/null || echo "1800")
ACTIVATION_KEY=$(cat /etc/elite-x/key 2>/dev/null || echo "ELITEX-2026-DAN-4D-08")
echo "DOMAIN  : ${TDOMAIN}"
echo "LOCATION: ${SELECTED_LOCATION}"
echo "KEY : ${ACTIVATION_KEY}"
echo "KEY EXPIRE  : ${EXPIRY_INFO}"
echo "╚════════════════════════════════════╝"
show_quote

# Final service status check
echo -e "\n${CYAN}Final Service Status:${NC}"
sleep 2
systemctl is-active dnstt-elite-x >/dev/null 2>&1 && echo -e "${GREEN}✅ DNSTT Server: Running${NC}" || echo -e "${RED}❌ DNSTT Server: Failed${NC}"
systemctl is-active dnstt-elite-x-proxy >/dev/null 2>&1 && echo -e "${GREEN}✅ DNSTT Proxy: Running${NC}" || echo -e "${RED}❌ DNSTT Proxy: Failed${NC}"

echo -e "\n${CYAN}Port Status:${NC}"
ss -uln | grep -q ":53 " && echo -e "${GREEN}✅ Port 53: Listening${NC}" || echo -e "${RED}❌ Port 53: Not listening${NC}"
ss -uln | grep -q ":${DNSTT_PORT} " && echo -e "${GREEN}✅ Port ${DNSTT_PORT}: Listening${NC}" || echo -e "${RED}❌ Port ${DNSTT_PORT}: Not listening${NC}"

# Show service logs if failed
if ! systemctl is-active dnstt-elite-x >/dev/null 2>&1; then
    echo -e "\n${YELLOW}DNSTT Server Logs:${NC}"
    journalctl -u dnstt-elite-x -n 5 --no-pager
fi

if ! systemctl is-active dnstt-elite-x-proxy >/dev/null 2>&1; then
    echo -e "\n${YELLOW}DNSTT Proxy Logs:${NC}"
    journalctl -u dnstt-elite-x-proxy -n 5 --no-pager
fi

read -p "Open menu now? (y/n): " open
if [ "$open" = "y" ]; then
    echo -e "${GREEN}Opening dashboard...${NC}"
    sleep 1
    /usr/local/bin/elite-x
else
    echo -e "${YELLOW}You can type 'menu' or 'elite-x' anytime to open the dashboard.${NC}"
fi

self_destruct
