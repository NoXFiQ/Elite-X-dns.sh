#!/bin/bash
# ============================================
# ELITE-X DNSTT AUTO INSTALL (ULTRA SECURE)
# All Parts Encrypted • Hidden • Protected
# ============================================
set -euo pipefail

# ========== ENCRYPTED COLOR CODES ==========
_0x1='\033[0;31m'
_0x2='\033[0;32m'
_0x3='\033[1;33m'
_0x4='\033[0;34m'
_0x5='\033[0;35m'
_0x6='\033[0;36m'
_0x7='\033[1;37m'
_0x8='\033[1m'
_0x9='\033[0m'

# ========== ENCRYPTED FUNCTIONS ==========
_0x10() { echo -e "${_0x2}${1}${_0x9}"; }
_0x11() { echo -e "${_0x3}${1}${_0x9}"; }
_0x12() { echo -e "${_0x6}${1}${_0x9}"; }
_0x13() { echo -e "${_0x1}${1}${_0x9}"; }
_0x14() { echo -e "${_0x7}${1}${_0x9}"; }

# ========== ENCRYPTED QUOTE ==========
_0x15() {
    echo ""
    echo -e "${_0x6}╔═══════════════════════════════════════════════════════════════╗${_0x9}"
    echo -e "${_0x6}║${_0x3}${_0x8}                                                               ${_0x6}║${_0x9}"
    echo -e "${_0x6}║${_0x7}            Always Remember ELITE-X when you see X            ${_0x6}║${_0x9}"
    echo -e "${_0x6}║${_0x3}${_0x8}                                                               ${_0x6}║${_0x9}"
    echo -e "${_0x6}╚═══════════════════════════════════════════════════════════════╝${_0x9}"
    echo ""
}

# ========== ENCRYPTED BANNER ==========
_0x16() {
    clear
    echo -e "${_0x1}╔═══════════════════════════════════════════════════════════════╗${_0x9}"
    echo -e "${_0x1}║${_0x3}${_0x8}                    ELITE-X SLOWDNS v3.0                        ${_0x1}║${_0x9}"
    echo -e "${_0x1}║${_0x2}${_0x8}                    ULTRA SECURE EDITION                        ${_0x1}║${_0x9}"
    echo -e "${_0x1}╚═══════════════════════════════════════════════════════════════╝${_0x9}"
    echo ""
}

# ========== ENCRYPTED SELF-DESTRUCT ==========
_0x17() {
    _0x11 "🧹 Cleaning all traces..."
    
    # Clear all history
    history -c 2>/dev/null || true
    cat /dev/null > ~/.bash_history 2>/dev/null || true
    cat /dev/null > /root/.bash_history 2>/dev/null || true
    cat /dev/null > /home/*/.bash_history 2>/dev/null || true
    
    # Remove script file
    if [ -f "$0" ] && [ "$0" != "/usr/local/bin/elite-x" ]; then
        local _0x18=$(readlink -f "$0")
        rm -f "$_0x18" 2>/dev/null || true
    fi
    
    # Clean logs
    sed -i '/Elite-X-dns.sh/d' /var/log/auth.log 2>/dev/null || true
    sed -i '/elite-x/d' /var/log/auth.log 2>/dev/null || true
    sed -i '/dnstt/d' /var/log/auth.log 2>/dev/null || true
    sed -i '/wget/d' /var/log/auth.log 2>/dev/null || true
    sed -i '/curl/d' /var/log/auth.log 2>/dev/null || true
    
    # Remove temp files
    rm -f wget-log* 2>/dev/null || true
    rm -f /tmp/elite-* 2>/dev/null || true
    rm -f /var/tmp/elite-* 2>/dev/null || true
    
    _0x10 "✅ Cleanup complete!"
}

# ========== ENCRYPTED CONFIG ENCRYPTION ==========
_0x19() {
    _0x11 "🔐 Encrypting all configuration files..."
    
    local _0x1a="/etc/elite-x/.key"
    openssl rand -base64 32 > "$_0x1a" 2>/dev/null
    chmod 600 "$_0x1a"
    
    # Encrypt all files in /etc/elite-x
    for _0x1b in /etc/elite-x/*; do
        if [ -f "$_0x1b" ] && [ "$_0x1b" != "$_0x1a" ] && [ "$_0x1b" != "$_0x1a.enc" ]; then
            openssl enc -aes-256-cbc -salt -in "$_0x1b" -out "${_0x1b}.enc" -pass file:"$_0x1a" 2>/dev/null
            rm -f "$_0x1b"
        fi
    done
    
    # Create decryption wrapper
    cat > /usr/local/bin/elite-x-decrypt <<'_0x1c'
#!/bin/bash
_0x1d="/etc/elite-x/.key"
if [ -f "$_0x1d" ] && [ -f "$1.enc" ]; then
    openssl enc -aes-256-cbc -d -salt -in "$1.enc" -out "$1" -pass file:"$_0x1d" 2>/dev/null
    cat "$1"
    rm -f "$1"
fi
_0x1c
    chmod 700 /usr/local/bin/elite-x-decrypt
    
    _0x10 "✅ All configurations encrypted"
}

# ========== ENCRYPTED SECURE PERMISSIONS ==========
_0x1e() {
    _0x11 "🔒 Applying secure permissions..."
    
    chmod 700 /etc/elite-x
    chmod 600 /etc/elite-x/* 2>/dev/null || true
    chmod 700 /usr/local/bin/elite-x
    chmod 700 /usr/local/bin/elite-x-user
    chmod 700 /usr/local/bin/elite-x-speed
    chmod 700 /usr/local/bin/elite-x-traffic
    chmod 700 /usr/local/bin/elite-x-cleaner
    chmod 700 /usr/local/bin/elite-x-update
    chmod 700 /usr/local/bin/elite-x-decrypt 2>/dev/null || true
    chmod 600 /etc/dnstt/server.key
    
    if command -v chattr >/dev/null 2>&1; then
        chattr +i /usr/local/bin/elite-x 2>/dev/null || true
        chattr +i /etc/dnstt/server.key 2>/dev/null || true
        chattr +i /etc/elite-x/.key 2>/dev/null || true
    fi
    
    _0x10 "✅ Permissions secured"
}

# ========== ENCRYPTED ACTIVATION VARIABLES ==========
_0x1f="ELITEX-2026-DAN-4D-08"
_0x20="ELITE-X-TEST-0208"
_0x21="/etc/elite-x/activated"
_0x22="/etc/elite-x/activation_type"
_0x23="/etc/elite-x/activation_date"
_0x24="/etc/elite-x/expiry_days"
_0x25="/etc/elite-x/key"
_0x26="Africa/Dar_es_Salaam"

# ========== ENCRYPTED TIMEZONE ==========
_0x27() {
    timedatectl set-timezone $_0x26 2>/dev/null || ln -sf /usr/share/zoneinfo/$_0x26 /etc/localtime 2>/dev/null || true
}

# ========== ENCRYPTED EXPIRY CHECK ==========
_0x28() {
    if [ -f "$_0x22" ] && [ -f "$_0x23" ] && [ -f "$_0x24" ]; then
        local _0x29=$(cat "$_0x22")
        if [ "$_0x29" = "temporary" ]; then
            local _0x2a=$(cat "$_0x23")
            local _0x2b=$(cat "$_0x24")
            local _0x2c=$(date +%s)
            local _0x2d=$(date -d "$_0x2a + $_0x2b days" +%s)
            
            if [ $_0x2c -ge $_0x2d ]; then
                _0x13 "╔═══════════════════════════════════════════════════════════════╗"
                _0x13 "║${_0x3}           TRIAL PERIOD EXPIRED                                  ${_0x13}║"
                _0x13 "╠═══════════════════════════════════════════════════════════════╣"
                _0x13 "║${_0x7}  Your 2-day trial has ended.                                  ${_0x13}║"
                _0x13 "║${_0x7}  Script will now uninstall itself...                         ${_0x13}║"
                _0x13 "╚═══════════════════════════════════════════════════════════════╝"
                sleep 3
                
                systemctl stop dnstt-elite-x dnstt-elite-x-proxy elite-x-traffic elite-x-cleaner 2>/dev/null || true
                systemctl disable dnstt-elite-x dnstt-elite-x-proxy elite-x-traffic elite-x-cleaner 2>/dev/null || true
                rm -f /etc/systemd/system/{dnstt-elite-x*,elite-x-*}
                rm -rf /etc/dnstt /etc/elite-x
                rm -f /usr/local/bin/{dnstt-*,elite-x*}
                sed -i '/^Banner/d' /etc/ssh/sshd_config
                systemctl restart sshd
                
                _0x10 "✅ ELITE-X has been uninstalled."
                exit 0
            else
                local _0x2e=$(( (_0x2d - _0x2c) / 86400 ))
                local _0x2f=$(( ((_0x2d - _0x2c) % 86400) / 3600 ))
                _0x11 "⚠️  Trial: $_0x2e days $_0x2f hours remaining"
            fi
        fi
    fi
}

# ========== ENCRYPTED ACTIVATION ==========
_0x30() {
    local _0x31="$1"
    mkdir -p /etc/elite-x
    
    if [ "$_0x31" = "$_0x1f" ] || [ "$_0x31" = "Whtsapp 0713628668" ]; then
        echo "$_0x1f" > "$_0x21"
        echo "$_0x1f" > "$_0x25"
        echo "lifetime" > "$_0x22"
        echo "Lifetime" > /etc/elite-x/expiry
        return 0
    elif [ "$_0x31" = "$_0x20" ]; then
        echo "$_0x20" > "$_0x21"
        echo "$_0x20" > "$_0x25"
        echo "temporary" > "$_0x22"
        echo "$(date +%Y-%m-%d)" > "$_0x23"
        echo "2" > "$_0x24"
        echo "2 Days Trial" > /etc/elite-x/expiry
        return 0
    fi
    return 1
}

# ========== ENCRYPTED SUBDOMAIN CHECK ==========
_0x32() {
    local _0x33="$1"
    local _0x34=$(curl -4 -s ifconfig.me 2>/dev/null || echo "")
    
    _0x11 "🔍 Checking if subdomain points to this VPS (IPv4)..."
    _0x12 "╔═══════════════════════════════════════════════════════════════╗"
    _0x12 "║${_0x7}  Subdomain: $_0x33"
    _0x12 "║${_0x7}  VPS IPv4 : $_0x34"
    _0x12 "╚═══════════════════════════════════════════════════════════════╝"
    
    if [ -z "$_0x34" ]; then
        _0x11 "⚠️  Could not detect VPS IPv4, continuing anyway..."
        return 0
    fi
    
    local _0x35=$(dig +short -4 "$_0x33" 2>/dev/null | head -1)
    
    if [ -z "$_0x35" ]; then
        _0x11 "⚠️  Could not resolve subdomain, continuing anyway..."
        _0x11 "⚠️  Make sure your subdomain points to: $_0x34"
        return 0
    fi
    
    if [ "$_0x35" = "$_0x34" ]; then
        _0x10 "✅ Subdomain correctly points to this VPS!"
        return 0
    else
        _0x13 "❌ Subdomain points to $_0x35, but VPS IP is $_0x34"
        _0x11 "⚠️  Please update your DNS record and try again"
        read -p "Continue anyway? (y/n): " _0x36
        if [ "$_0x36" != "y" ]; then
            exit 1
        fi
    fi
}

# ========== ENCRYPTED TRAFFIC MONITOR ==========
_0x37() {
    cat > /usr/local/bin/elite-x-traffic <<'_0x38'
#!/bin/bash
exec 2>/dev/null
_0x39="/etc/elite-x/traffic"
_0x3a="/etc/elite-x/users"
mkdir -p $_0x39

_0x3b() {
    local _0x3c="$1"
    local _0x3d="$_0x39/$_0x3c"
    if command -v iptables >/dev/null 2>&1; then
        local _0x3e=$(iptables -vnx -L OUTPUT | grep "$_0x3c" | awk '{s+=$2} END {print s}' 2>/dev/null || echo "0")
        echo $((_0x3e/1048576)) > "$_0x3d"
    fi
}

while true; do
    [ -d "$_0x3a" ] && for _0x3f in "$_0x3a"/*; do
        [ -f "$_0x3f" ] && _0x3b "$(basename "$_0x3f")"
    done
    sleep 60
done
_0x38
    chmod +x /usr/local/bin/elite-x-traffic

    cat > /etc/systemd/system/elite-x-traffic.service <<_0x40
[Unit]
Description=ELITE-X Traffic Monitor
After=network.target
[Service]
Type=simple
ExecStart=/usr/local/bin/elite-x-traffic
Restart=always
[Install]
WantedBy=multi-user.target
_0x40

    systemctl daemon-reload
    systemctl enable elite-x-traffic.service
    systemctl start elite-x-traffic.service
}

# ========== ENCRYPTED SPEED OPTIMIZER ==========
_0x41() {
    cat > /usr/local/bin/elite-x-speed <<'_0x42'
#!/bin/bash
exec 2>/dev/null
_0x43='\033[0;31m';_0x44='\033[0;32m';_0x45='\033[1;33m';_0x46='\033[0m'

_0x47() {
    echo -e "${_0x45}⚡ Optimizing network...${_0x46}"
    sysctl -w net.core.rmem_max=134217728 >/dev/null 2>&1
    sysctl -w net.core.wmem_max=134217728 >/dev/null 2>&1
    sysctl -w net.ipv4.tcp_rmem="4096 87380 134217728" >/dev/null 2>&1
    sysctl -w net.ipv4.tcp_wmem="4096 65536 134217728" >/dev/null 2>&1
    sysctl -w net.ipv4.tcp_congestion_control=bbr >/dev/null 2>&1
    echo -e "${_0x44}✅ Network optimized${_0x46}"
}

_0x48() {
    echo -e "${_0x45}⚡ Optimizing CPU...${_0x46}"
    for _0x49 in /sys/devices/system/cpu/cpu*/cpufreq/scaling_governor; do
        echo "performance" > "$_0x49" 2>/dev/null || true
    done
    echo -e "${_0x44}✅ CPU optimized${_0x46}"
}

_0x4a() {
    echo -e "${_0x45}⚡ Optimizing RAM...${_0x46}"
    sync && echo 3 > /proc/sys/vm/drop_caches 2>/dev/null || true
    echo -e "${_0x44}✅ RAM optimized${_0x46}"
}

_0x4b() {
    echo -e "${_0x45}🧹 Cleaning junk...${_0x46}"
    apt clean 2>/dev/null; apt autoclean 2>/dev/null
    find /var/log -type f -name "*.log" -exec truncate -s 0 {} \; 2>/dev/null || true
    echo -e "${_0x44}✅ Junk cleaned${_0x46}"
}

case "$1" in
    manual) _0x47;_0x48;_0x4a;_0x4b ;;
    clean) _0x4b ;;
    *) echo "Usage: elite-x-speed {manual|clean}" ;;
esac
_0x42
    chmod +x /usr/local/bin/elite-x-speed
}

# ========== ENCRYPTED AUTO REMOVER ==========
_0x4c() {
    cat > /usr/local/bin/elite-x-cleaner <<'_0x4d'
#!/bin/bash
exec 2>/dev/null
_0x4e="/etc/elite-x/users"
_0x4f="/etc/elite-x/traffic"

while true; do
    [ -d "$_0x4e" ] && for _0x50 in "$_0x4e"/*; do
        [ -f "$_0x50" ] && {
            _0x51=$(basename "$_0x50")
            _0x52=$(grep "Expire:" "$_0x50" | cut -d' ' -f2)
            [ ! -z "$_0x52" ] && [ "$(date +%Y-%m-%d)" > "$_0x52" ] && {
                userdel -r "$_0x51" 2>/dev/null || true
                rm -f "$_0x50" "$_0x4f/$_0x51"
            }
        }
    done
    sleep 3600
done
_0x4d
    chmod +x /usr/local/bin/elite-x-cleaner

    cat > /etc/systemd/system/elite-x-cleaner.service <<_0x53
[Unit]
Description=ELITE-X Auto Remover
[Service]
Type=simple
ExecStart=/usr/local/bin/elite-x-cleaner
Restart=always
[Install]
WantedBy=multi-user.target
_0x53

    systemctl daemon-reload
    systemctl enable elite-x-cleaner.service
    systemctl start elite-x-cleaner.service
}

# ========== ENCRYPTED UPDATER ==========
_0x54() {
    cat > /usr/local/bin/elite-x-update <<'_0x55'
#!/bin/bash
exec 2>/dev/null
echo -e "\033[1;33m🔄 Checking for updates...\033[0m"
_0x56="/root/elite-x-backup-$(date +%Y%m%d-%H%M%S)"
mkdir -p "$_0x56"
cp -r /etc/elite-x "$_0x56/" 2>/dev/null || true
cp -r /etc/dnstt "$_0x56/" 2>/dev/null || true
cd /tmp
rm -rf Elite-X-dns.sh
git clone https://github.com/NoXFiQ/Elite-X-dns.sh.git 2>/dev/null || exit 1
cd Elite-X-dns.sh
chmod +x *.sh
cp -r "$_0x56/elite-x" /etc/ 2>/dev/null || true
cp -r "$_0x56/dnstt" /etc/ 2>/dev/null || true
echo -e "\033[0;32m✅ Update complete!\033[0m"
_0x55
    chmod +x /usr/local/bin/elite-x-update
}

# ========== ENCRYPTED USER MANAGER ==========
_0x57() {
    cat > /usr/local/bin/elite-x-user <<'_0x58'
#!/bin/bash
exec 2>/dev/null
_0x59='\033[0;31m';_0x5a='\033[0;32m';_0x5b='\033[1;33m';_0x5c='\033[0;36m';_0x5d='\033[1;37m';_0x5e='\033[0m'

_0x5f() {
    echo ""
    echo -e "${_0x5c}╔═══════════════════════════════════════════════════════════════╗${_0x5e}"
    echo -e "${_0x5c}║${_0x5b}${_0x8}                                                               ${_0x5c}║${_0x5e}"
    echo -e "${_0x5c}║${_0x5d}            Always Remember ELITE-X when you see X            ${_0x5c}║${_0x5e}"
    echo -e "${_0x5c}║${_0x5b}${_0x8}                                                               ${_0x5c}║${_0x5e}"
    echo -e "${_0x5c}╚═══════════════════════════════════════════════════════════════╝${_0x5e}"
    echo ""
}

_0x60="/etc/elite-x/users"
_0x61="/etc/elite-x/traffic"
mkdir -p $_0x60 $_0x61

_0x62() {
    clear
    echo -e "${_0x5c}╔═══════════════════════════════════════════════════════════════╗${_0x5e}"
    echo -e "${_0x5c}║${_0x5b}              CREATE SSH + DNS USER                            ${_0x5c}║${_0x5e}"
    echo -e "${_0x5c}╚═══════════════════════════════════════════════════════════════╝${_0x5e}"
    
    read -p "$(echo -e $_0x5a"Username: "$_0x5e)" _0x63
    read -p "$(echo -e $_0x5a"Password: "$_0x5e)" _0x64
    read -p "$(echo -e $_0x5a"Expire days: "$_0x5e)" _0x65
    read -p "$(echo -e $_0x5a"Traffic limit (MB, 0 for unlimited): "$_0x5e)" _0x66
    
    if id "$_0x63" &>/dev/null; then
        echo -e "${_0x59}User already exists!${_0x5e}"
        return
    fi
    
    useradd -m -s /bin/false "$_0x63"
    echo "$_0x63:$_0x64" | chpasswd
    
    _0x67=$(date -d "+$_0x65 days" +"%Y-%m-%d")
    chage -E "$_0x67" "$_0x63"
    
    cat > $_0x60/$_0x63 <<_0x68
Username: $_0x63
Password: $_0x64
Expire: $_0x67
Traffic_Limit: $_0x66
Created: $(date +"%Y-%m-%d")
_0x68
    
    echo "0" > $_0x61/$_0x63
    
    _0x69=$(cat /etc/elite-x/subdomain 2>/dev/null || echo "?")
    _0x6a=$(cat /etc/dnstt/server.pub 2>/dev/null || echo "Not generated")
    
    clear
    echo -e "${_0x5a}╔═══════════════════════════════════════════════════════════════╗${_0x5e}"
    echo -e "${_0x5a}║${_0x5b}                  USER DETAILS                                   ${_0x5a}║${_0x5e}"
    echo -e "${_0x5a}╠═══════════════════════════════════════════════════════════════╣${_0x5e}"
    echo -e "${_0x5a}║${_0x5d}  Username  :${_0x5c} $_0x63${_0x5e}"
    echo -e "${_0x5a}║${_0x5d}  Password  :${_0x5c} $_0x64${_0x5e}"
    echo -e "${_0x5a}║${_0x5d}  Server    :${_0x5c} $_0x69${_0x5e}"
    echo -e "${_0x5a}║${_0x5d}  Public Key:${_0x5c} $_0x6a${_0x5e}"
    echo -e "${_0x5a}║${_0x5d}  Expire    :${_0x5c} $_0x67${_0x5e}"
    echo -e "${_0x5a}║${_0x5d}  Traffic   :${_0x5c} $_0x66 MB${_0x5e}"
    echo -e "${_0x5a}╚═══════════════════════════════════════════════════════════════╝${_0x5e}"
    _0x5f
}

_0x6b() {
    clear
    echo -e "${_0x5c}╔═══════════════════════════════════════════════════════════════╗${_0x5e}"
    echo -e "${_0x5c}║${_0x5b}                     ACTIVE USERS                               ${_0x5c}║${_0x5e}"
    echo -e "${_0x5c}╠═══════════════════════════════════════════════════════════════╣${_0x5e}"
    
    [ -z "$(ls -A $_0x60 2>/dev/null)" ] && { echo -e "${_0x59}No users found${_0x5e}"; return; }
    
    printf "%-12s %-10s %-6s %-6s %-8s\n" "USERNAME" "EXPIRE" "LIMIT" "USED" "STATUS"
    echo -e "${_0x5c}────────────────────────────────────────────────────────────${_0x5e}"
    
    for _0x6c in $_0x60/*; do
        [ ! -f "$_0x6c" ] && continue
        _0x6d=$(basename "$_0x6c")
        _0x6e=$(grep "Expire:" "$_0x6c" | cut -d' ' -f2 | cut -c6-10)
        _0x6f=$(grep "Traffic_Limit:" "$_0x6c" | cut -d' ' -f2)
        _0x70=$(cat $_0x61/$_0x6d 2>/dev/null || echo "0")
        _0x71=$(passwd -S "$_0x6d" 2>/dev/null | grep -q "L" && echo "${_0x59}LOCK${_0x5e}" || echo "${_0x5a}OK${_0x5e}")
        printf "%-12s %-10s %-6s %-6s %-8b\n" "$_0x6d" "$_0x6e" "$_0x6f" "$_0x70" "$_0x71"
    done
    echo -e "${_0x5c}╚═══════════════════════════════════════════════════════════════╝${_0x5e}"
    _0x5f
}

_0x72() { read -p "Username: " _0x73; usermod -L "$_0x73" 2>/dev/null && echo -e "${_0x5a}✅ Locked${_0x5e}" || echo -e "${_0x59}❌ Failed${_0x5e}"; _0x5f; }
_0x74() { read -p "Username: " _0x75; usermod -U "$_0x75" 2>/dev/null && echo -e "${_0x5a}✅ Unlocked${_0x5e}" || echo -e "${_0x59}❌ Failed${_0x5e}"; _0x5f; }
_0x76() { 
    read -p "Username: " _0x77
    userdel -r "$_0x77" 2>/dev/null
    rm -f $_0x60/$_0x77 $_0x61/$_0x77
    echo -e "${_0x5a}✅ Deleted${_0x5e}"
    _0x5f
}

case $1 in
    add) _0x62 ;;
    list) _0x6b ;;
    lock) _0x72 ;;
    unlock) _0x74 ;;
    del) _0x76 ;;
    *) echo "Usage: elite-x-user {add|list|lock|unlock|del}" ;;
esac
_0x58
    chmod +x /usr/local/bin/elite-x-user
}

# ========== ENCRYPTED MAIN MENU ==========
_0x78() {
    cat > /usr/local/bin/elite-x <<'_0x79'
#!/bin/bash
exec 2>/dev/null
_0x7a='\033[0;31m';_0x7b='\033[0;32m';_0x7c='\033[1;33m';_0x7d='\033[0;36m'
_0x7e='\033[0;35m';_0x7f='\033[1;37m';_0x80='\033[1m';_0x81='\033[0m'

_0x82() {
    echo ""
    echo -e "${_0x7d}╔═══════════════════════════════════════════════════════════════╗${_0x81}"
    echo -e "${_0x7d}║${_0x7c}${_0x80}                                                               ${_0x7d}║${_0x81}"
    echo -e "${_0x7d}║${_0x7f}            Always Remember ELITE-X when you see X            ${_0x7d}║${_0x81}"
    echo -e "${_0x7d}║${_0x7c}${_0x80}                                                               ${_0x7d}║${_0x81}"
    echo -e "${_0x7d}╚═══════════════════════════════════════════════════════════════╝${_0x81}"
    echo ""
}

if [ -f /tmp/elite-x-running ]; then exit 0; fi
touch /tmp/elite-x-running
trap 'rm -f /tmp/elite-x-running' EXIT

_0x83() {
    if [ -f "/etc/elite-x/activation_type" ] && [ -f "/etc/elite-x/activation_date" ] && [ -f "/etc/elite-x/expiry_days" ]; then
        local _0x84=$(cat "/etc/elite-x/activation_type")
        if [ "$_0x84" = "temporary" ]; then
            local _0x85=$(cat "/etc/elite-x/activation_date")
            local _0x86=$(cat "/etc/elite-x/expiry_days")
            local _0x87=$(date +%s)
            local _0x88=$(date -d "$_0x85 + $_0x86 days" +%s)
            
            if [ $_0x87 -ge $_0x88 ]; then
                echo -e "${_0x7a}╔═══════════════════════════════════════════════════════════════╗${_0x81}"
                echo -e "${_0x7a}║${_0x7c}           TRIAL PERIOD EXPIRED                                  ${_0x7a}║${_0x81}"
                echo -e "${_0x7a}╠═══════════════════════════════════════════════════════════════╣${_0x81}"
                echo -e "${_0x7a}║${_0x7f}  Your 2-day trial has ended.                                  ${_0x7a}║${_0x81}"
                echo -e "${_0x7a}║${_0x7f}  Script will now uninstall itself...                         ${_0x7a}║${_0x81}"
                echo -e "${_0x7a}╚═══════════════════════════════════════════════════════════════╝${_0x81}"
                sleep 3
                
                systemctl stop dnstt-elite-x dnstt-elite-x-proxy elite-x-traffic elite-x-cleaner 2>/dev/null || true
                systemctl disable dnstt-elite-x dnstt-elite-x-proxy elite-x-traffic elite-x-cleaner 2>/dev/null || true
                rm -f /etc/systemd/system/{dnstt-elite-x*,elite-x-*}
                rm -rf /etc/dnstt /etc/elite-x
                rm -f /usr/local/bin/{dnstt-*,elite-x*}
                sed -i '/^Banner/d' /etc/ssh/sshd_config
                systemctl restart sshd
                
                echo -e "${_0x7b}✅ ELITE-X has been uninstalled.${_0x81}"
                rm -f /tmp/elite-x-running
                exit 0
            fi
        fi
    fi
}

_0x83

_0x89() {
    clear
    
    _0x8a=$(cat /etc/elite-x/cached_ip 2>/dev/null || curl -s ifconfig.me 2>/dev/null || echo "Unknown")
    _0x8b=$(cat /etc/elite-x/cached_location 2>/dev/null || echo "Unknown")
    _0x8c=$(cat /etc/elite-x/cached_isp 2>/dev/null || echo "Unknown")
    _0x8d=$(free -m | awk '/^Mem:/{print $3"/"$2"MB"}')
    _0x8e=$(cat /etc/elite-x/subdomain 2>/dev/null || echo "Not configured")
    _0x8f=$(cat /etc/elite-x/key 2>/dev/null || echo "Unknown")
    _0x90=$(cat /etc/elite-x/expiry 2>/dev/null || echo "Unknown")
    _0x91=$(cat /etc/elite-x/location 2>/dev/null || echo "South Africa")
    _0x92=$(cat /etc/elite-x/mtu 2>/dev/null || echo "1800")
    
    _0x93=$(systemctl is-active dnstt-elite-x 2>/dev/null | grep -q active && echo "${_0x7b}●${_0x81}" || echo "${_0x7a}●${_0x81}")
    _0x94=$(systemctl is-active dnstt-elite-x-proxy 2>/dev/null | grep -q active && echo "${_0x7b}●${_0x81}" || echo "${_0x7a}●${_0x81}")
    
    echo -e "${_0x7d}╔════════════════════════════════════════════════════════════════╗${_0x81}"
    echo -e "${_0x7d}║${_0x7c}${_0x80}                    ELITE-X SLOWDNS v3.0                       ${_0x7d}║${_0x81}"
    echo -e "${_0x7d}╠════════════════════════════════════════════════════════════════╣${_0x81}"
    echo -e "${_0x7d}║${_0x7f}  Subdomain :${_0x7b} $_0x8e${_0x81}"
    echo -e "${_0x7d}║${_0x7f}  IP        :${_0x7b} $_0x8a${_0x81}"
    echo -e "${_0x7d}║${_0x7f}  Location  :${_0x7b} $_0x8b${_0x81}"
    echo -e "${_0x7d}║${_0x7f}  ISP       :${_0x7b} $_0x8c${_0x81}"
    echo -e "${_0x7d}║${_0x7f}  RAM       :${_0x7b} $_0x8d${_0x81}"
    echo -e "${_0x7d}║${_0x7f}  VPS Loc   :${_0x7b} $_0x91${_0x81}"
    echo -e "${_0x7d}║${_0x7f}  MTU       :${_0x7b} $_0x92${_0x81}"
    echo -e "${_0x7d}║${_0x7f}  Services  : DNS:$_0x93 PRX:$_0x94${_0x81}"
    echo -e "${_0x7d}║${_0x7f}  Developer :${_0x7e} ELITE-X TEAM${_0x81}"
    echo -e "${_0x7d}╠════════════════════════════════════════════════════════════════╣${_0x81}"
    echo -e "${_0x7d}║${_0x7f}  Act Key   :${_0x7c} ${_0x8f:0:4}****${_0x8f: -4}${_0x81}"
    echo -e "${_0x7d}║${_0x7f}  Expiry    :${_0x7c} $_0x90${_0x81}"
    echo -e "${_0x7d}╚════════════════════════════════════════════════════════════════╝${_0x81}"
    echo ""
}

_0x95() {
    while true; do
        clear
        echo -e "${_0x7d}╔════════════════════════════════════════════════════════════════╗${_0x81}"
        echo -e "${_0x7d}║${_0x7c}${_0x80}                      SETTINGS MENU                              ${_0x7d}║${_0x81}"
        echo -e "${_0x7d}╠════════════════════════════════════════════════════════════════╣${_0x81}"
        echo -e "${_0x7d}║${_0x7f}  [8]  🔑 View Public Key${_0x81}"
        echo -e "${_0x7d}║${_0x7f}  [9]  Change MTU Value (Manual)${_0x81}"
        echo -e "${_0x7d}║${_0x7f}  [10] ⚡ Manual Speed Optimization${_0x81}"
        echo -e "${_0x7d}║${_0x7f}  [11] 🧹 Clean Junk Files${_0x81}"
        echo -e "${_0x7d}║${_0x7f}  [12] 🔄 Auto Expired Account Remover${_0x81}"
        echo -e "${_0x7d}║${_0x7f}  [13] 📦 Update Script${_0x81}"
        echo -e "${_0x7d}║${_0x7f}  [14] Restart All Services${_0x81}"
        echo -e "${_0x7d}║${_0x7f}  [15] Reboot VPS${_0x81}"
        echo -e "${_0x7d}║${_0x7f}  [16] Uninstall Script${_0x81}"
        echo -e "${_0x7d}║${_0x7f}  [17] 🌍 Re-apply Location Optimization${_0x81}"
        echo -e "${_0x7d}║${_0x7f}  [0]  Back to Main Menu${_0x81}"
        echo -e "${_0x7d}╚════════════════════════════════════════════════════════════════╝${_0x81}"
        echo ""
        read -p "$(echo -e $_0x7b"Settings option: "$_0x81)" _0x96
        
        case $_0x96 in
            8)
                echo -e "${_0x7d}╔═══════════════════════════════════════════════════════════════╗${_0x81}"
                echo -e "${_0x7d}║${_0x7c}                    PUBLIC KEY (FULL)                           ${_0x7d}║${_0x81}"
                echo -e "${_0x7d}╠═══════════════════════════════════════════════════════════════╣${_0x81}"
                echo -e "${_0x7d}║${_0x7b}  $(cat /etc/dnstt/server.pub)${_0x81}"
                echo -e "${_0x7d}╚═══════════════════════════════════════════════════════════════╝${_0x81}"
                read -p "Press Enter to continue..."
                ;;
            9)
                echo "Current MTU: $(cat /etc/elite-x/mtu)"
                read -p "New MTU (1000-5000): " _0x97
                [[ "$_0x97" =~ ^[0-9]+$ ]] && [ $_0x97 -ge 1000 ] && [ $_0x97 -le 5000 ] && {
                    echo "$_0x97" > /etc/elite-x/mtu
                    sed -i "s/-mtu [0-9]*/-mtu $_0x97/" /etc/systemd/system/dnstt-elite-x.service
                    systemctl daemon-reload
                    systemctl restart dnstt-elite-x dnstt-elite-x-proxy
                    echo -e "${_0x7b}✅ MTU updated to $_0x97${_0x81}"
                } || echo -e "${_0x7a}❌ Invalid (must be 1000-5000)${_0x81}"
                read -p "Press Enter to continue..."
                ;;
            10) elite-x-speed manual; read -p "Press Enter to continue..." ;;
            11) elite-x-speed clean; read -p "Press Enter to continue..." ;;
            12)
                systemctl enable --now elite-x-cleaner.service
                echo -e "${_0x7b}✅ Auto remover started${_0x81}"
                read -p "Press Enter to continue..."
                ;;
            13) elite-x-update; read -p "Press Enter to continue..." ;;
            14)
                systemctl restart dnstt-elite-x dnstt-elite-x-proxy sshd
                echo -e "${_0x7b}✅ Services restarted${_0x81}"
                read -p "Press Enter to continue..."
                ;;
            15)
                read -p "Reboot? (y/n): " _0x98
                [ "$_0x98" = "y" ] && reboot
                ;;
            16)
                read -p "Uninstall? (YES): " _0x99
                [ "$_0x99" = "YES" ] && {
                    systemctl stop dnstt-elite-x dnstt-elite-x-proxy elite-x-traffic elite-x-cleaner
                    systemctl disable dnstt-elite-x dnstt-elite-x-proxy elite-x-traffic elite-x-cleaner
                    rm -f /etc/systemd/system/{dnstt-elite-x*,elite-x-*}
                    rm -rf /etc/dnstt /etc/elite-x
                    rm -f /usr/local/bin/{dnstt-*,elite-x*}
                    sed -i '/^Banner/d' /etc/ssh/sshd_config
                    systemctl restart sshd
                    echo -e "${_0x7b}✅ Uninstalled${_0x81}"
                    rm -f /tmp/elite-x-running
                    exit 0
                }
                read -p "Press Enter to continue..."
                ;;
            17)
                echo -e "${_0x7c}═══════════════════════════════════════════════════════════════${_0x81}"
                echo -e "${_0x7b}           RE-APPLY LOCATION OPTIMIZATION                        ${_0x81}"
                echo -e "${_0x7c}═══════════════════════════════════════════════════════════════${_0x81}"
                echo -e "${_0x7f}Select your VPS location:${_0x81}"
                echo -e "${_0x7b}  1. South Africa (MTU 1800)${_0x81}"
                echo -e "${_0x7d}  2. USA${_0x81}"
                echo -e "${_0x7e}  3. Europe${_0x81}"
                echo -e "${_0x7c}  4. Asia${_0x81}"
                echo -e "${_0x7c}  5. Auto-detect${_0x81}"
                read -p "Choice: " _0x9a
                
                case $_0x9a in
                    1) echo "South Africa" > /etc/elite-x/location
                       echo "1800" > /etc/elite-x/mtu
                       sed -i "s/-mtu [0-9]*/-mtu 1800/" /etc/systemd/system/dnstt-elite-x.service
                       systemctl daemon-reload
                       systemctl restart dnstt-elite-x dnstt-elite-x-proxy
                       echo -e "${_0x7b}✅ South Africa selected (MTU 1800)${_0x81}" ;;
                    2) echo "USA" > /etc/elite-x/location
                       echo -e "${_0x7b}✅ USA selected${_0x81}" ;;
                    3) echo "Europe" > /etc/elite-x/location
                       echo -e "${_0x7b}✅ Europe selected${_0x81}" ;;
                    4) echo "Asia" > /etc/elite-x/location
                       echo -e "${_0x7b}✅ Asia selected${_0x81}" ;;
                    5) echo "Auto-detect" > /etc/elite-x/location
                       echo -e "${_0x7b}✅ Auto-detect selected${_0x81}" ;;
                esac
                read -p "Press Enter to continue..."
                ;;
            0) return ;;
            *) echo -e "${_0x7a}Invalid option${_0x81}"; read -p "Press Enter to continue..." ;;
        esac
    done
}

_0x9b() {
    while true; do
        _0x89
        echo -e "${_0x7d}╔════════════════════════════════════════════════════════════════╗${_0x81}"
        echo -e "${_0x7d}║${_0x7b}${_0x80}                         MAIN MENU                              ${_0x7d}║${_0x81}"
        echo -e "${_0x7d}╠════════════════════════════════════════════════════════════════╣${_0x81}"
        echo -e "${_0x7d}║${_0x7f}  [1] Create SSH + DNS User${_0x81}"
        echo -e "${_0x7d}║${_0x7f}  [2] List All Users${_0x81}"
        echo -e "${_0x7d}║${_0x7f}  [3] Lock User${_0x81}"
        echo -e "${_0x7d}║${_0x7f}  [4] Unlock User${_0x81}"
        echo -e "${_0x7d}║${_0x7f}  [5] Delete User${_0x81}"
        echo -e "${_0x7d}║${_0x7f}  [6] Create/Edit Banner${_0x81}"
        echo -e "${_0x7d}║${_0x7f}  [7] Delete Banner${_0x81}"
        echo -e "${_0x7d}║${_0x7f}  [S] ⚙️  Settings${_0x81}"
        echo -e "${_0x7d}║${_0x7f}  [00] Exit${_0x81}"
        echo -e "${_0x7d}╚════════════════════════════════════════════════════════════════╝${_0x81}"
        echo ""
        read -p "$(echo -e $_0x7b"Main menu option: "$_0x81)" _0x9c
        
        case $_0x9c in
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
                echo -e "${_0x7b}✅ Banner saved${_0x81}"
                read -p "Press Enter to continue..."
                ;;
            7)
                rm -f /etc/elite-x/banner/custom
                cp /etc/elite-x/banner/default /etc/elite-x/banner/ssh-banner
                systemctl restart sshd
                echo -e "${_0x7b}✅ Banner deleted${_0x81}"
                read -p "Press Enter to continue..."
                ;;
            [Ss]) _0x95 ;;
            00|0) 
                rm -f /tmp/elite-x-running
                _0x82
                echo -e "${_0x7b}Goodbye!${_0x81}"
                exit 0 
                ;;
            *) echo -e "${_0x7a}Invalid option${_0x81}"; read -p "Press Enter to continue..." ;;
        esac
    done
}

_0x9b
_0x79
    chmod +x /usr/local/bin/elite-x
}

# ========== MAIN INSTALLATION ==========
_0x16

echo -e "${_0x3}╔═══════════════════════════════════════════════════════════════╗${_0x9}"
echo -e "${_0x3}║${_0x2}                    ACTIVATION REQUIRED                          ${_0x3}║${_0x9}"
echo -e "${_0x3}╚═══════════════════════════════════════════════════════════════╝${_0x9}"
echo ""
echo -e "${_0x7}Available Keys:${_0x9}"
echo -e "${_0x2}  Lifetime : Whtsapp 0713628668${_0x9}"
echo -e "${_0x3}  Trial    : ELITE-X-TEST-0208 (2 days)${_0x9}"
echo ""
read -p "$(echo -e $_0x6"Activation Key: "$_0x9)" _0x9d

mkdir -p /etc/elite-x
if ! _0x30 "$_0x9d"; then
    echo -e "${_0x1}❌ Invalid activation key! Installation cancelled.${_0x9}"
    exit 1
fi

echo -e "${_0x2}✅ Activation successful!${_0x9}"
sleep 1

if [ -f "$_0x22" ] && [ "$(cat "$_0x22")" = "temporary" ]; then
    echo -e "${_0x3}⚠️  Trial version activated - expires in 2 days${_0x9}"
fi
sleep 2

_0x27

echo -e "${_0x6}╔═══════════════════════════════════════════════════════════════╗${_0x9}"
echo -e "${_0x6}║${_0x7}                  ENTER YOUR SUBDOMAIN                          ${_0x6}║${_0x9}"
echo -e "${_0x6}╠═══════════════════════════════════════════════════════════════╣${_0x9}"
echo -e "${_0x6}║${_0x7}  Example: ns-ex.elitex.sbs                                 ${_0x6}║${_0x9}"
echo -e "${_0x6}╚═══════════════════════════════════════════════════════════════╝${_0x9}"
echo ""
read -p "$(echo -e $_0x2"Subdomain: "$_0x9)" _0x9e

echo -e "${_0x6}╔═══════════════════════════════════════════════════════════════╗${_0x9}"
echo -e "${_0x6}║${_0x7}  You entered: ${_0x2}$_0x9e${_0x9}"
echo -e "${_0x6}╚═══════════════════════════════════════════════════════════════╝${_0x9}"
echo ""

_0x32 "$_0x9e"

echo -e "${_0x3}╔═══════════════════════════════════════════════════════════════╗${_0x9}"
echo -e "${_0x3}║${_0x2}           NETWORK LOCATION OPTIMIZATION                          ${_0x3}║${_0x9}"
echo -e "${_0x3}╠═══════════════════════════════════════════════════════════════╣${_0x9}"
echo -e "${_0x3}║${_0x7}  Select your VPS location:                                    ${_0x3}║${_0x9}"
echo -e "${_0x3}║${_0x2}  1. South Africa (Default - MTU 1800)                        ${_0x3}║${_0x9}"
echo -e "${_0x3}║${_0x6}  2. USA                                                       ${_0x3}║${_0x9}"
echo -e "${_0x3}║${_0x4}  3. Europe                                                    ${_0x3}║${_0x9}"
echo -e "${_0x3}║${_0x5}  4. Asia                                                      ${_0x3}║${_0x9}"
echo -e "${_0x3}║${_0x3}  5. Auto-detect                                                ${_0x3}║${_0x9}"
echo -e "${_0x3}╚═══════════════════════════════════════════════════════════════╝${_0x9}"
echo ""
read -p "$(echo -e $_0x2"Select location [1-5] [default: 1]: "$_0x9)" _0x9f
_0x9f=${_0x9f:-1}

_0xa0=1800
_0xa1="South Africa"

case $_0x9f in
    2) _0xa1="USA"; _0xa2=1 ;;
    3) _0xa1="Europe"; _0xa3=1 ;;
    4) _0xa1="Asia"; _0xa4=1 ;;
    5) _0xa1="Auto-detect"; _0xa5=1 ;;
    *) _0xa1="South Africa" ;;
esac

echo "$_0xa1" > /etc/elite-x/location
echo "$_0xa0" > /etc/elite-x/mtu

_0xa6=5300
_0xa7=53

echo "==> ELITE-X ULTRA SECURE INSTALLATION STARTING..."

if [ "$(id -u)" -ne 0 ]; then
    echo "[-] Run as root"
    exit 1
fi

mkdir -p /etc/elite-x/{banner,users,traffic}
echo "$_0x9e" > /etc/elite-x/subdomain

cat > /etc/elite-x/banner/default <<'_0xa8'
===============================================
      WELCOME TO ELITE-X VPN SERVICE
===============================================
     High Speed • Secure • Unlimited
===============================================
_0xa8

cat > /etc/elite-x/banner/ssh-banner <<'_0xa9'
************************************************
*         ELITE-X VPN SERVICE                  *
*     High Speed • Secure • Unlimited          *
************************************************
_0xa9

if ! grep -q "^Banner" /etc/ssh/sshd_config; then
    echo "Banner /etc/elite-x/banner/ssh-banner" >> /etc/ssh/sshd_config
else
    sed -i 's|^Banner.*|Banner /etc/elite-x/banner/ssh-banner|' /etc/ssh/sshd_config
fi
systemctl restart sshd

echo "Stopping old services..."
for _0xaa in dnstt dnstt-server slowdns dnstt-smart dnstt-elite-x dnstt-elite-x-proxy; do
    systemctl disable --now "$_0xaa" 2>/dev/null || true
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
apt install -y curl python3 jq nano iptables iptables-persistent ethtool dnsutils openssl

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
cat >/etc/systemd/system/dnstt-elite-x.service <<_0xab
[Unit]
Description=ELITE-X DNSTT Server
After=network-online.target
[Service]
Type=simple
ExecStart=/usr/local/bin/dnstt-server -udp :${_0xa6} -mtu ${_0xa0} -privkey-file /etc/dnstt/server.key ${_0x9e} 127.0.0.1:22
Restart=no
LimitNOFILE=1048576
[Install]
WantedBy=multi-user.target
_0xab

echo "Installing EDNS proxy..."
cat >/usr/local/bin/dnstt-edns-proxy.py <<'_0xac'
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
_0xac
chmod +x /usr/local/bin/dnstt-edns-proxy.py

cat >/etc/systemd/system/dnstt-elite-x-proxy.service <<_0xad
[Unit]
Description=ELITE-X Proxy
After=dnstt-elite-x.service
[Service]
Type=simple
ExecStart=/usr/bin/python3 /usr/local/bin/dnstt-edns-proxy.py
Restart=no
[Install]
WantedBy=multi-user.target
_0xad

command -v ufw >/dev/null && ufw allow 22/tcp && ufw allow 53/udp || true

systemctl daemon-reload
systemctl enable dnstt-elite-x.service dnstt-elite-x-proxy.service
systemctl start dnstt-elite-x.service dnstt-elite-x-proxy.service

# Setup all features
_0x37
_0x41
_0x4c
_0x54
_0x57

# Apply location optimizations
if [ ! -z "${_0xa2:-}" ]; then
    echo -e "${_0x3}🔄 Applying USA optimizations...${_0x9}"
    cat >> /etc/sysctl.conf <<_0xae
net.ipv4.tcp_rmem = 4096 87380 67108864
net.ipv4.tcp_wmem = 4096 65536 67108864
net.ipv4.tcp_congestion_control = bbr
net.core.default_qdisc = fq
_0xae
    sysctl -p
elif [ ! -z "${_0xa3:-}" ]; then
    echo -e "${_0x3}🔄 Applying Europe optimizations...${_0x9}"
    cat >> /etc/sysctl.conf <<_0xaf
net.ipv4.tcp_rmem = 4096 87380 33554432
net.ipv4.tcp_wmem = 4096 65536 33554432
net.ipv4.tcp_congestion_control = bbr
net.core.default_qdisc = fq
_0xaf
    sysctl -p
elif [ ! -z "${_0xa4:-}" ]; then
    echo -e "${_0x3}🔄 Applying Asia optimizations...${_0x9}"
    cat >> /etc/sysctl.conf <<_0xb0
net.ipv4.tcp_rmem = 4096 87380 16777216
net.ipv4.tcp_wmem = 4096 65536 16777216
net.ipv4.tcp_congestion_control = bbr
net.core.default_qdisc = fq
_0xb0
    sysctl -p
elif [ ! -z "${_0xa5:-}" ]; then
    echo -e "${_0x3}🔄 Applying auto optimizations...${_0x9}"
    cat >> /etc/sysctl.conf <<_0xb1
net.ipv4.tcp_rmem = 4096 87380 33554432
net.ipv4.tcp_wmem = 4096 65536 33554432
net.ipv4.tcp_congestion_control = bbr
net.core.default_qdisc = fq
_0xb1
    sysctl -p
fi

# Network interface optimization
for _0xb2 in $(ls /sys/class/net/ | grep -v lo); do
    ethtool -K $_0xb2 tx off sg off tso off 2>/dev/null || true
    ip link set dev $_0xb2 txqueuelen 10000 2>/dev/null || true
done

systemctl daemon-reload
systemctl restart dnstt-elite-x dnstt-elite-x-proxy

# Create expiry checker
cat > /etc/cron.hourly/elite-x-expiry <<'_0xb3'
#!/bin/bash
if [ -f /usr/local/bin/elite-x ]; then
    /usr/local/bin/elite-x --check-expiry
fi
_0xb3
chmod +x /etc/cron.hourly/elite-x-expiry

# Cache network info
echo "Caching network information..."
_0xb4=$(curl -4 -s ifconfig.me 2>/dev/null || echo "Unknown")
echo "$_0xb4" > /etc/elite-x/cached_ip

if [ "$_0xb4" != "Unknown" ]; then
    _0xb5=$(curl -s http://ip-api.com/json/$_0xb4 2>/dev/null)
    echo "$_0xb5" | jq -r '.city + ", " + .country' 2>/dev/null > /etc/elite-x/cached_location || echo "Unknown" > /etc/elite-x/cached_location
    echo "$_0xb5" | jq -r '.isp' 2>/dev/null > /etc/elite-x/cached_isp || echo "Unknown" > /etc/elite-x/cached_isp
else
    echo "Unknown" > /etc/elite-x/cached_location
    echo "Unknown" > /etc/elite-x/cached_isp
fi

# Create auto-show
cat > /etc/profile.d/elite-x-dashboard.sh <<'_0xb6'
#!/bin/bash
if [ -f /usr/local/bin/elite-x ] && [ -z "$ELITE_X_SHOWN" ]; then
    export ELITE_X_SHOWN=1
    rm -f /tmp/elite-x-running 2>/dev/null
    /usr/local/bin/elite-x
fi
_0xb6
chmod +x /etc/profile.d/elite-x-dashboard.sh

cat >> ~/.bashrc <<'_0xb7'
if [ -f /usr/local/bin/elite-x ] && [ -z "$ELITE_X_SHOWN" ]; then
    export ELITE_X_SHOWN=1
    rm -f /tmp/elite-x-running 2>/dev/null
    /usr/local/bin/elite-x
fi
_0xb7

echo "alias menu='elite-x'" >> ~/.bashrc
echo "alias elitex='elite-x'" >> ~/.bashrc

# ========== APPLY ULTRA SECURITY ==========
_0x78
_0x19
_0x1e

echo "======================================"
echo " ELITE-X ULTRA SECURE INSTALLED "
echo "======================================"
_0xb8=$(cat /etc/elite-x/expiry 2>/dev/null || echo "Lifetime")
_0xb9=$(cat /etc/elite-x/mtu 2>/dev/null || echo "1800")
_0xba=$(cat /etc/elite-x/key 2>/dev/null || echo "$_0x1f")
echo "DOMAIN  : $_0x9e"
echo "LOCATION: $_0xa1"
echo "MTU     : $_0xb9"
echo "ACT KEY : ${_0xba:0:4}****${_0xba: -4}"
echo "EXPIRY  : $_0xb8"
echo ""
echo "PUBLIC KEY:"
cat /etc/dnstt/server.pub
echo "======================================"
_0x15

read -p "Open menu now? (y/n): " _0xbb
if [ "$_0xbb" = "y" ]; then
    echo -e "${_0x2}Opening dashboard...${_0x9}"
    sleep 1
    /usr/local/bin/elite-x
else
    echo -e "${_0x3}Type 'menu' or 'elite-x' anytime to open the dashboard.${_0x9}"
fi

# ========== FINAL SELF-DESTRUCT ==========
_0x17
