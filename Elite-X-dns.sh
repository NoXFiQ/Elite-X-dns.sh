#!/bin/bash
# ============================================
# ELITE-X DNSTT AUTO INSTALL (MOBILE OPTIMIZED)
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

# Mobile optimized banner (smaller)
show_banner() {
    clear
    echo -e "${RED}"
    echo "╔════════════════════════╗"
    echo "║      ELITE-X v3.0      ║"
    echo "║    Ultimate Edition    ║"
    echo "╚════════════════════════╝${NC}"
    echo ""
}

# ========== ACTIVATION SYSTEM ==========
ACTIVATION_KEY="ELITEX-2026-DAN-4D-08"
ACTIVATION_FILE="/etc/elite-x/activated"
TIMEZONE="Africa/Dar_es_Salaam"

set_timezone() {
    timedatectl set-timezone $TIMEZONE 2>/dev/null || 
    ln -sf /usr/share/zoneinfo/$TIMEZONE /etc/localtime 2>/dev/null || true
}

activate_script() {
    if [ "$1" = "$ACTIVATION_KEY" ]; then
        mkdir -p /etc/elite-x
        echo "$ACTIVATION_KEY" > "$ACTIVATION_FILE"
        echo "$(date)" >> "$ACTIVATION_FILE"
        return 0
    fi
    return 1
}

############################
# CONFIG (Interactive)
############################
show_banner
echo "┌────────────────────────┐"
echo "│   ACTIVATION REQUIRED  │"
echo "└────────────────────────┘"
read -p "Key: " ACTIVATION_INPUT

mkdir -p /etc/elite-x
if ! activate_script "$ACTIVATION_INPUT"; then
    echo -e "${RED}❌ Invalid key!${NC}"
    exit 1
fi
echo -e "${GREEN}✅ Activated!${NC}"
sleep 1

set_timezone
read -p "Subdomain (ns-ex.elitex.sbs): " TDOMAIN
MTU=1800
DNSTT_PORT=5300
DNS_PORT=53
############################

echo "==> ELITE-X INSTALL STARTING..."

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

# Default banner
cat > /etc/elite-x/banner/default <<'EOF'
===============================
    ELITE-X VPN SERVICE
===============================
   High Speed • Secure
===============================
EOF

cat > /etc/elite-x/banner/ssh-banner <<'EOF'
*******************************
*        ELITE-X VPN          *
*******************************
EOF

# SSH banner config
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
apt install -y curl python3 jq nano iptables iptables-persistent ethtool

# Install dnstt-server
echo "==> Installing dnstt-server..."
curl -fsSL https://dnstt.network/dnstt-server-linux-amd64 -o /usr/local/bin/dnstt-server
chmod +x /usr/local/bin/dnstt-server

# Keys
echo "==> Generating keys..."
mkdir -p /etc/dnstt
if [ ! -f /etc/dnstt/server.key ]; then
  cd /etc/dnstt
  dnstt-server -gen-key -privkey-file server.key -pubkey-file server.pub
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

[Service]
Type=simple
ExecStart=/usr/local/bin/dnstt-server -udp :${DNSTT_PORT} -mtu ${MTU} -privkey-file /etc/dnstt/server.key ${TDOMAIN} 127.0.0.1:22
Restart=no
KillSignal=SIGTERM
LimitNOFILE=1048576

[Install]
WantedBy=multi-user.target
EOF

# EDNS proxy (minified)
echo "==> Installing EDNS proxy..."
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

# ========== TRAFFIC MONITOR ==========
cat > /usr/local/bin/elite-x-traffic <<'EOF'
#!/bin/bash
TRAFFIC_DB="/etc/elite-x/traffic"
USER_DB="/etc/elite-x/users"
mkdir -p $TRAFFIC_DB
while true; do
 if [ -d "$USER_DB" ]; then
  for uf in "$USER_DB"/*; do
   if [ -f "$uf" ]; then
    u=$(basename "$uf")
    command -v iptables >/dev/null && {
     curr=$(iptables -vnx -L OUTPUT | grep "$u" | awk '{sum+=$2} END {print sum}' 2>/dev/null || echo "0")
     echo $((curr/1048576)) > "$TRAFFIC_DB/$u"
    }
   fi
  done
 fi
 sleep 60
done
EOF
chmod +x /usr/local/bin/elite-x-traffic

cat > /etc/systemd/system/elite-x-traffic.service <<EOF
[Unit]
Description=Traffic Monitor
[Service]
Type=simple
ExecStart=/usr/local/bin/elite-x-traffic
Restart=always
[Install]
WantedBy=multi-user.target
EOF

# ========== SPEED OPTIMIZER ==========
cat > /usr/local/bin/elite-x-speed <<'EOF'
#!/bin/bash
R='\033[0;31m';G='\033[0;32m';Y='\033[1;33m';N='\033[0m'
opt() {
 sysctl -w net.core.rmem_max=134217728 >/dev/null 2>&1
 sysctl -w net.core.wmem_max=134217728 >/dev/null 2>&1
 sysctl -w net.ipv4.tcp_rmem="4096 87380 134217728" >/dev/null 2>&1
 sysctl -w net.ipv4.tcp_wmem="4096 65536 134217728" >/dev/null 2>&1
 sysctl -w net.core.netdev_max_backlog=5000 >/dev/null 2>&1
 sysctl -w net.ipv4.tcp_congestion_control=bbr >/dev/null 2>&1
 sysctl -w net.core.default_qdisc=fq >/dev/null 2>&1
 echo -e "${G}✅ Speed optimized${N}"
}
cpu() {
 for cpu in /sys/devices/system/cpu/cpu*/cpufreq/scaling_governor; do
  echo "performance" > "$cpu" 2>/dev/null || true
 done
 echo -e "${G}✅ CPU optimized${N}"
}
ram() {
 sync && echo 3 > /proc/sys/vm/drop_caches 2>/dev/null || true
 swapoff -a && swapon -a 2>/dev/null || true
 echo -e "${G}✅ RAM optimized${N}"
}
clean() {
 apt clean 2>/dev/null; apt autoclean 2>/dev/null
 find /var/log -type f -name "*.log" -exec truncate -s 0 {} \; 2>/dev/null || true
 rm -rf /tmp/* 2>/dev/null || true
 echo -e "${G}✅ Junk cleaned${N}"
}
case "$1" in
 auto) while true; do opt;cpu;ram;clean; sleep 5; done ;;
 manual) opt;cpu;ram;clean ;;
 clean) clean ;;
esac
EOF
chmod +x /usr/local/bin/elite-x-speed

cat > /etc/systemd/system/elite-x-speed.service <<EOF
[Unit]
Description=Speed Optimizer
[Service]
Type=simple
ExecStart=/usr/local/bin/elite-x-speed auto
Restart=always
RestartSec=5
[Install]
WantedBy=multi-user.target
EOF

# ========== AUTO REMOVER ==========
cat > /usr/local/bin/elite-x-cleaner <<'EOF'
#!/bin/bash
USER_DB="/etc/elite-x/users"
TRAFFIC_DB="/etc/elite-x/traffic"
while true; do
 if [ -d "$USER_DB" ]; then
  for uf in "$USER_DB"/*; do
   if [ -f "$uf" ]; then
    u=$(basename "$uf")
    ex=$(grep "Expire:" "$uf" | cut -d' ' -f2)
    [ ! -z "$ex" ] && [ "$(date +%Y-%m-%d)" > "$ex" ] && {
     userdel -r "$u" 2>/dev/null || true
     rm -f "$uf" "$TRAFFIC_DB/$u"
    }
   fi
  done
 fi
 sleep 3600
done
EOF
chmod +x /usr/local/bin/elite-x-cleaner

cat > /etc/systemd/system/elite-x-cleaner.service <<EOF
[Unit]
Description=Auto Remover
[Service]
Type=simple
ExecStart=/usr/local/bin/elite-x-cleaner
Restart=always
[Install]
WantedBy=multi-user.target
EOF

# ========== UPDATER ==========
cat > /usr/local/bin/elite-x-update <<'EOF'
#!/bin/bash
echo "🔄 Updating..."
cd /tmp
rm -rf Elite-X-dns.sh
git clone https://github.com/NoXFiQ/Elite-X-dns.sh.git 2>/dev/null || exit 1
cd Elite-X-dns.sh
chmod +x *.sh
echo "✅ Update complete!"
EOF
chmod +x /usr/local/bin/elite-x-update

# Start services
systemctl daemon-reload
systemctl enable elite-x-traffic.service elite-x-speed.service elite-x-cleaner.service
systemctl start elite-x-traffic.service elite-x-speed.service elite-x-cleaner.service

# ========== USER MANAGEMENT ==========
cat >/usr/local/bin/elite-x-user <<'EOF'
#!/bin/bash
R='\033[0;31m';G='\033[0;32m';Y='\033[1;33m';C='\033[0;36m';W='\033[1;37m';N='\033[0m'
UD="/etc/elite-x/users";TD="/etc/elite-x/traffic";mkdir -p $UD $TD
add() {
 clear; echo "┌────────────────────┐"; echo "│   CREATE USER      │"; echo "└────────────────────┘"
 read -p "Username: " u; read -p "Password: " p; read -p "Days: " d; read -p "Traffic MB (0=∞): " l
 if id "$u" &>/dev/null; then echo -e "${R}User exists${N}"; return; fi
 useradd -m -s /bin/false "$u"; echo "$u:$p" | chpasswd
 ex=$(date -d "+$d days" +%Y-%m-%d); chage -E "$ex" "$u"
 cat > $UD/$u <<INFO
Username: $u
Password: $p
Expire: $ex
Traffic_Limit: $l
Created: $(date +%Y-%m-%d)
INFO
 echo "0" > $TD/$u
 S=$(cat /etc/elite-x/subdomain 2>/dev/null || echo "?"); K=$(cat /etc/dnstt/server.pub 2>/dev/null | cut -c1-30)
 clear; echo "┌────────────────────┐"; echo "│   USER DETAILS     │"; echo "└────────────────────┘"
 echo "User:$u Pass:$p"; echo "Host:$S"; echo "Key:$K..."; echo "Exp:$ex Limit:$l MB"
}
list() {
 clear; echo "┌────────────────────┐"; echo "│   ACTIVE USERS     │"; echo "└────────────────────┘"
 [ -z "$(ls -A $UD 2>/dev/null)" ] && { echo -e "${R}No users${N}"; return; }
 printf "%-10s %-8s %-5s %-5s\n" "USER" "EXPIRE" "LMT" "USED"
 for f in $UD/*; do
  u=$(basename "$f")
  ex=$(grep "Expire:" "$f" | cut -d' ' -f2 | cut -c6-10)
  lm=$(grep "Traffic_Limit:" "$f" | cut -d' ' -f2)
  us=$(cat $TD/$u 2>/dev/null || echo "0")
  st=$(passwd -S "$u" 2>/dev/null | grep -q "L" && echo "🔒" || echo "✓")
  printf "%-10s %-8s %-5s %-5s %s\n" "$u" "$ex" "$lm" "$us" "$st"
 done
}
lock() { read -p "Username: " u; usermod -L "$u"; echo "🔒 Locked"; }
unlock() { read -p "Username: " u; usermod -U "$u"; echo "✓ Unlocked"; }
del() { 
 read -p "Username: " u
 userdel -r "$u" 2>/dev/null; rm -f $UD/$u $TD/$u
 echo "✅ Deleted"
}
case $1 in add)add;;list)list;;lock)lock;;unlock)unlock;;del)del;;esac
EOF
chmod +x /usr/local/bin/elite-x-user

# ========== MAIN MENU (MOBILE OPTIMIZED) ==========
cat >/usr/local/bin/elite-x <<'EOF'
#!/bin/bash
R='\033[0;31m';G='\033[0;32m';Y='\033[1;33m';C='\033[0;36m';P='\033[0;35m';W='\033[1;37m';B='\033[1m';N='\033[0m'
dash() {
 clear
 IP=$(curl -s ifconfig.me 2>/dev/null || echo "?")
 TM=$(free -m | awk '/^Mem:/{print $3"MB/"$2"MB"}')
 DT=$(date '+%H:%M:%S')
 SUB=$(cat /etc/elite-x/subdomain 2>/dev/null || echo "?")
 MTU=$(cat /etc/elite-x/mtu 2>/dev/null || echo "1800")
 KEY=$(cat /etc/elite-x/key 2>/dev/null)
 USRS=$(ls -1 /etc/elite-x/users 2>/dev/null | wc -l)
 DS=$(systemctl is-active dnstt-elite-x 2>/dev/null | grep -q active && echo "${G}●${N}" || echo "${R}●${N}")
 PS=$(systemctl is-active dnstt-elite-x-proxy 2>/dev/null | grep -q active && echo "${G}●${N}" || echo "${R}●${N}")
 SS=$(systemctl is-active elite-x-speed 2>/dev/null | grep -q active && echo "${G}●${N}" || echo "${R}●${N}")
 echo "┌──────────────────────┐"
 echo "│${Y}${B}   ELITE-X v3.0      ${N}│"
 echo "├──────────────────────┤"
 echo "│${W}IP:${G}$IP ${W}RAM:${G}$TM${N}"
 echo "│${W}MTU:${Y}$MTU ${W}USR:${C}$USRS${N}"
 echo "│${W}DNS: $DS PRX: $PS SPD: $SS${N}"
 echo "│${W}Time:${G}$DT${N}"
 echo "├──────────────────────┤"
 echo "│${W}Key:${Y}$KEY${N}"
 echo "│${W}Exp:${G}Lifetime${N}"
 echo "└──────────────────────┘"
}
menu() {
 while true; do
  dash
  echo "┌──────────────────────┐"
  echo "│      MAIN MENU       │"
  echo "├──────────────────────┤"
  echo "│ 1. Create User       │"
  echo "│ 2. List Users        │"
  echo "│ 3. Lock User         │"
  echo "│ 4. Unlock User       │"
  echo "│ 5. Delete User       │"
  echo "│ 6. Edit Banner       │"
  echo "│ 7. Delete Banner     │"
  echo "│ 8. Change MTU        │"
  echo "│ 9. ⚡ Auto Speed     │"
  echo "│10. 🔧 Manual Speed   │"
  echo "│11. 🧹 Clean Junk     │"
  echo "│12. 🔄 Auto Remover   │"
  echo "│13. 📦 Update Script  │"
  echo "│14. Restart Services  │"
  echo "│15. Reboot VPS        │"
  echo "│16. Uninstall         │"
  echo "│00. Exit              │"
  echo "└──────────────────────┘"
  read -p "Choice: " ch
  case $ch in
   1) elite-x-user add;;
   2) elite-x-user list;;
   3) elite-x-user lock;;
   4) elite-x-user unlock;;
   5) elite-x-user del;;
   6) nano /etc/elite-x/banner/custom 2>/dev/null || cp /etc/elite-x/banner/default /etc/elite-x/banner/custom && nano /etc/elite-x/banner/custom
      cp /etc/elite-x/banner/custom /etc/elite-x/banner/ssh-banner; systemctl restart sshd;;
   7) rm -f /etc/elite-x/banner/custom; cp /etc/elite-x/banner/default /etc/elite-x/banner/ssh-banner; systemctl restart sshd;;
   8) echo "MTU: $(cat /etc/elite-x/mtu)"; read -p "New MTU (1000-5000): " mtu
      [[ "$mtu" =~ ^[0-9]+$ ]] && [ $mtu -ge 1000 ] && [ $mtu -le 5000 ] && {
       echo "$mtu" > /etc/elite-x/mtu
       sed -i "s/-mtu [0-9]*/-mtu $mtu/" /etc/systemd/system/dnstt-elite-x.service
       systemctl daemon-reload; systemctl restart dnstt-elite-x dnstt-elite-x-proxy
       echo "✅ MTU updated"
      } || echo "❌ Invalid";;
   9) systemctl enable --now elite-x-speed.service; echo "✅ Auto speed ON";;
   10) elite-x-speed manual;;
   11) elite-x-speed clean;;
   12) systemctl enable --now elite-x-cleaner.service; echo "✅ Auto remover ON";;
   13) elite-x-update;;
   14) systemctl restart dnstt-elite-x dnstt-elite-x-proxy elite-x-speed elite-x-cleaner sshd; echo "✅ Restarted";;
   15) read -p "Reboot? (y/n): " c; [ "$c" = "y" ] && reboot;;
   16) read -p "Uninstall? (YES): " c; [ "$c" = "YES" ] && {
        systemctl stop dnstt-elite-x dnstt-elite-x-proxy elite-x-speed elite-x-cleaner
        systemctl disable dnstt-elite-x dnstt-elite-x-proxy elite-x-speed elite-x-cleaner
        rm -f /etc/systemd/system/{dnstt-elite-x*,elite-x-*}
        rm -rf /etc/dnstt /etc/elite-x
        rm -f /usr/local/bin/{dnstt-*,elite-x*}
        sed -i '/^Banner/d' /etc/ssh/sshd_config; systemctl restart sshd
        echo "✅ Uninstalled"; exit 0
      };;
   00|0) exit 0;;
  esac
  read -p "Press Enter..."
 done
}
menu
EOF
chmod +x /usr/local/bin/elite-x

# Aliases
echo "alias menu='elite-x'" >> ~/.bashrc
echo "alias elitex='elite-x'" >> ~/.bashrc

echo "================================"
echo " ELITE-X INSTALLED SUCCESSFULLY"
echo "================================"
echo "DOMAIN: ${TDOMAIN}"
echo "KEY:"
cat /etc/dnstt/server.pub
echo "================================"
echo "Type 'menu' or 'elite-x'"
echo "================================"

read -p "Open menu now? (y/n): " open
[ "$open" = "y" ] && /usr/local/bin/elite-x
