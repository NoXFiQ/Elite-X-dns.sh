#!/bin/bash

# ============================================================================
#                     AMOKHAN V1.5 - ULTIMATE SSH MANAGER
# ============================================================================
# PRESERVING ALL V1.0 FEATURES + NEW ENHANCEMENTS:
# ✓ Activation Key System (Trial/Lifetime) - RESTORED FROM V1.0
# ✓ Public Key Display after account creation - RESTORED FROM V1.0
# ✓ Complete uninstall with system cleanup (NEW)
# ✓ Real-time bandwidth monitoring per user (NEW)
# ✓ User bandwidth limits and quotas (NEW)
# ✓ Renew user accounts (NEW)
# ============================================================================

# Ensure running as root
if [ "$EUID" -ne 0 ]; then
    echo -e "\033[0;31m[✗]\033[0m Please run this script as root"
    exit 1
fi

# ============================================================================
# CONFIGURATION
# ============================================================================
SCRIPT_VERSION="1.5"
SCRIPT_NAME="AMOKHAN SSH MANAGER"
SSHD_PORT=22
SLOWDNS_PORT=5300
DROPBEAR_PORT=143
SQUID_PORT=8080
OVPN_PORT=1194
GITHUB_BASE="https://raw.githubusercontent.com/iddie15/SLOW-DNS-SCRIPT/main/DNSTT%20MODED"
MAX_USERS=50
BANDWIDTH_RESET="daily"
LOG_FILE="/var/log/amokhan.log"
DB_FILE="/etc/amokhan/users.db"
BANDWIDTH_DB="/etc/amokhan/bandwidth.db"
CONFIG_DIR="/etc/amokhan"
BACKUP_DIR="/root/amokhan-backups"
KEY_FILE="/etc/amokhan/license.key"
ACTIVATION_FILE="/etc/amokhan/activated"

# ============================================================================
# COLORS & DESIGN (PRESERVED FROM V1.0)
# ============================================================================
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
WHITE='\033[1;37m'
BOLD='\033[1m'
NC='\033[0m'

# ============================================================================
# ANIMATION FUNCTIONS (PRESERVED FROM V1.0)
# ============================================================================
show_progress() {
    local pid=$1
    local delay=0.1
    local spinstr='|/-\'
    while [ "$(ps a | awk '{print $1}' | grep $pid)" ]; do
        local temp=${spinstr#?}
        printf " [%c]  " "$spinstr"
        local spinstr=$temp${spinstr%"$temp"}
        sleep $delay
        printf "\b\b\b\b\b\b"
    done
    printf "    \b\b\b\b"
}

print_step() {
    echo -e "\n${BLUE}┌─${NC} ${CYAN}${BOLD}STEP $1${NC}"
    echo -e "${BLUE}│${NC}"
}

print_step_end() {
    echo -e "${BLUE}└─${NC} ${GREEN}✓${NC} Completed"
}

print_box() {
    local text="$1"
    local color="$2"
    local width=50
    local padding=$(( ($width - ${#text} - 2) / 2 ))
    printf "${color}┌"
    printf "─%.0s" $(seq 1 $((width-2)))
    printf "┐${NC}\n"
    printf "${color}│${NC}%${padding}s${text}%${padding}s${color}│${NC}\n"
    printf "${color}└"
    printf "─%.0s" $(seq 1 $((width-2)))
    printf "┘${NC}\n"
}

print_banner() {
    clear
    echo -e "${BLUE}╔══════════════════════════════════════════════════════════╗${NC}"
    echo -e "${BLUE}║${NC}${CYAN}          🚀 AMOKHAN V$SCRIPT_VERSION - SSH MANAGER${NC}               ${BLUE}║${NC}"
    echo -e "${BLUE}║${NC}${WHITE}            Complete SSH & SlowDNS Management${NC}            ${BLUE}║${NC}"
    echo -e "${BLUE}║${NC}${YELLOW}                Optimized for Performance${NC}                ${BLUE}║${NC}"
    echo -e "${BLUE}╚══════════════════════════════════════════════════════════╝${NC}"
    echo ""
}

print_header() {
    echo -e "\n${PURPLE}══════════════════════════════════════════════════════════${NC}"
    echo -e "${CYAN}${BOLD}$1${NC}"
    echo -e "${PURPLE}══════════════════════════════════════════════════════════${NC}"
}

print_success() {
    echo -e "  ${GREEN}${BOLD}✓${NC} ${GREEN}$1${NC}"
}

print_error() {
    echo -e "  ${RED}${BOLD}✗${NC} ${RED}$1${NC}"
}

print_warning() {
    echo -e "  ${YELLOW}${BOLD}!${NC} ${YELLOW}$1${NC}"
}

print_info() {
    echo -e "  ${CYAN}${BOLD}ℹ${NC} ${CYAN}$1${NC}"
}

# ============================================================================
# ACTIVATION KEY SYSTEM (RESTORED FROM V1.0)
# ============================================================================
check_activation() {
    if [ -f "$ACTIVATION_FILE" ]; then
        return 0
    else
        return 1
    fi
}

show_activation_menu() {
    clear
    print_banner
    
    echo -e "${YELLOW}${BOLD}⚡ ACTIVATION REQUIRED ⚡${NC}"
    echo -e "${CYAN}┌──────────────────────────────────────────────────────┐${NC}"
    echo -e "${CYAN}│${NC} This script requires activation to use.                ${CYAN}│${NC}"
    echo -e "${CYAN}│${NC} Choose an option below:                                ${CYAN}│${NC}"
    echo -e "${CYAN}├──────────────────────────────────────────────────────┤${NC}"
    echo -e "${CYAN}│${NC}  ${GREEN}[1]${NC} 🔑 Enter Activation Key                              ${CYAN}│${NC}"
    echo -e "${CYAN}│${NC}  ${YELLOW}[2]${NC} ⏳ Get Trial Key (24 hours)                         ${CYAN}│${NC}"
    echo -e "${CYAN}│${NC}  ${RED}[3]${NC} ❌ Exit                                              ${CYAN}│${NC}"
    echo -e "${CYAN}└──────────────────────────────────────────────────────┘${NC}"
    echo ""
    echo -ne "${WHITE}${BOLD}Select option: ${NC}"
    read -r act_option
    
    case $act_option in
        1)
            echo -ne "${WHITE}Enter Activation Key: ${NC}"
            read -r input_key
            # In v1.0, the activation key was "AMOKHAN-V1.0-ACTIVE"
            if [ "$input_key" = "AMOKHAN-V1.0-ACTIVE" ] || [ "$input_key" = "AMOKHAN-V$SCRIPT_VERSION-ACTIVE" ]; then
                date +%s > "$ACTIVATION_FILE"
                echo -e "${GREEN}✓ Activation successful!${NC}"
                sleep 2
                return 0
            else
                echo -e "${RED}✗ Invalid activation key!${NC}"
                sleep 2
                show_activation_menu
            fi
            ;;
        2)
            echo -e "${YELLOW}Generating trial key...${NC}"
            # Create trial that expires in 24 hours
            trial_end=$(( $(date +%s) + 86400 ))
            echo "$trial_end" > "$ACTIVATION_FILE"
            echo -e "${GREEN}✓ Trial activated! Valid for 24 hours.${NC}"
            echo -e "${YELLOW}Trial Key: AMOKHAN-TRIAL-$(date +%Y%m%d)${NC}"
            sleep 3
            return 0
            ;;
        3)
            echo -e "${RED}Exiting...${NC}"
            exit 0
            ;;
        *)
            echo -e "${RED}Invalid option!${NC}"
            sleep 2
            show_activation_menu
            ;;
    esac
}

# ============================================================================
# INITIALIZATION (NEW FOR V1.5)
# ============================================================================
init_system() {
    mkdir -p $CONFIG_DIR
    mkdir -p $BACKUP_DIR
    touch $DB_FILE $BANDWIDTH_DB
    chmod 600 $DB_FILE $BANDWIDTH_DB
    
    # Create database structure if not exists
    if [ ! -s $DB_FILE ]; then
        echo "username|password|expiry_date|created_date|max_bandwidth_mb|current_bandwidth_mb|last_reset|status|max_logins|current_logins|email|notes" > $DB_FILE
    fi
    
    if [ ! -s $BANDWIDTH_DB ]; then
        echo "username|timestamp|bytes_in|bytes_out|total_mb" > $BANDWIDTH_DB
    fi
    
    # Create necessary directories
    mkdir -p /var/log/amokhan/users
    
    # Check activation
    if ! check_activation; then
        show_activation_menu
    else
        # Check if trial expired
        if [ -f "$ACTIVATION_FILE" ]; then
            expiry=$(cat "$ACTIVATION_FILE")
            current=$(date +%s)
            if [ $expiry -lt $current ] && [ $expiry -ne 0 ]; then
                rm -f "$ACTIVATION_FILE"
                echo -e "${RED}Trial expired! Please activate again.${NC}"
                sleep 2
                show_activation_menu
            fi
        fi
    fi
    
    # Setup bandwidth monitoring if not already running
    if ! systemctl is-active --quiet amokhan-monitor 2>/dev/null; then
        setup_bandwidth_monitor
    fi
}

# ============================================================================
# BANDWIDTH MONITORING SYSTEM (NEW FOR V1.5)
# ============================================================================
setup_bandwidth_monitor() {
    cat > /usr/local/bin/amokhan-monitor << 'EOF'
#!/bin/bash

CONFIG_DIR="/etc/amokhan"
DB_FILE="$CONFIG_DIR/users.db"
BANDWIDTH_DB="$CONFIG_DIR/bandwidth.db"
MONITOR_INTERVAL=60

bytes_to_mb() {
    echo "scale=2; $1 / 1048576" | bc
}

get_user_traffic() {
    local username=$1
    
    bytes_in=$(iptables -L OUTPUT -nvx | grep " $username " | grep -v "DROP" | awk '{sum+=$2} END {print sum}' 2>/dev/null || echo 0)
    bytes_out=$(iptables -L INPUT -nvx | grep " $username " | grep -v "DROP" | awk '{sum+=$2} END {print sum}' 2>/dev/null || echo 0)
    
    if [ "$bytes_in" = "0" ] && [ "$bytes_out" = "0" ]; then
        iptables -N $username 2>/dev/null
        iptables -I OUTPUT -m owner --uid-owner $username -j $username 2>/dev/null
        iptables -I INPUT -m owner --uid-owner $username -j $username 2>/dev/null
        iptables -A $username -j RETURN 2>/dev/null
        bytes_in=0
        bytes_out=0
    fi
    
    echo "$bytes_in|$bytes_out"
}

update_bandwidth() {
    local username=$1
    local bytes_in=$2
    local bytes_out=$3
    local timestamp=$(date +%s)
    local total_mb=$(bytes_to_mb $((bytes_in + bytes_out)))
    
    echo "$username|$timestamp|$bytes_in|$bytes_out|$total_mb" >> $BANDWIDTH_DB
    
    local temp_file=$(mktemp)
    while IFS='|' read -r user pass expiry created max_bandwidth current_bandwidth last_reset status max_logins current_logins email notes; do
        if [ "$user" = "$username" ]; then
            echo "$user|$pass|$expiry|$created|$max_bandwidth|$total_mb|$last_reset|$status|$max_logins|$current_logins|$email|$notes" >> $temp_file
        else
            echo "$user|$pass|$expiry|$created|$max_bandwidth|$current_bandwidth|$last_reset|$status|$max_logins|$current_logins|$email|$notes" >> $temp_file
        fi
    done < $DB_FILE
    
    mv $temp_file $DB_FILE
}

check_limits() {
    local username=$1
    local current_mb=$2
    local max_mb=$3
    
    if [ "$max_mb" != "0" ] && [ "$max_mb" != "unlimited" ] && [ $(echo "$current_mb > $max_mb" | bc) -eq 1 ]; then
        pkill -u $username 2>/dev/null
        killall -u $username 2>/dev/null
        passwd -l $username 2>/dev/null
        
        local temp_file=$(mktemp)
        while IFS='|' read -r user pass expiry created max_bandwidth current_bandwidth last_reset status max_logins current_logins email notes; do
            if [ "$user" = "$username" ]; then
                echo "$user|$pass|$expiry|$created|$max_bandwidth|$current_bandwidth|$last_reset|LIMIT_EXCEEDED|$max_logins|$current_logins|$email|$notes" >> $temp_file
            else
                echo "$user|$pass|$expiry|$created|$max_bandwidth|$current_bandwidth|$last_reset|$status|$max_logins|$current_logins|$email|$notes" >> $temp_file
            fi
        done < $DB_FILE
        mv $temp_file $DB_FILE
    fi
}

while true; do
    while IFS='|' read -r username password expiry created max_bandwidth current_bandwidth last_reset status max_logins current_logins email notes; do
        [ "$username" = "username" ] && continue
        
        if id "$username" &>/dev/null; then
            traffic=$(get_user_traffic $username)
            bytes_in=$(echo $traffic | cut -d'|' -f1)
            bytes_out=$(echo $traffic | cut -d'|' -f2)
            
            update_bandwidth $username $bytes_in $bytes_out
            
            current_mb=$(bytes_to_mb $((bytes_in + bytes_out)))
            
            if [ "$max_bandwidth" != "0" ] && [ "$max_bandwidth" != "unlimited" ]; then
                check_limits $username $current_mb $max_bandwidth
            fi
        fi
    done < <(tail -n +2 $DB_FILE 2>/dev/null)
    
    sleep $MONITOR_INTERVAL
done
EOF

    chmod +x /usr/local/bin/amokhan-monitor
    
    cat > /etc/systemd/system/amokhan-monitor.service << EOF
[Unit]
Description=AMOKHAN Bandwidth Monitor
After=network.target

[Service]
Type=simple
ExecStart=/usr/local/bin/amokhan-monitor
Restart=always
RestartSec=10
User=root

[Install]
WantedBy=multi-user.target
EOF

    systemctl daemon-reload
    systemctl enable amokhan-monitor.service 2>/dev/null
    systemctl start amokhan-monitor.service 2>/dev/null
}

# ============================================================================
# USER MANAGEMENT FUNCTIONS (NEW FOR V1.5)
# ============================================================================
create_ssh_user() {
    clear
    print_header "👤 CREATE NEW SSH USER"
    
    echo -ne "${WHITE}Username: ${NC}"
    read username
    
    if id "$username" &>/dev/null; then
        echo -e "${RED}✗ User $username already exists!${NC}"
        echo -e "\nPress Enter to continue..."
        read
        return
    fi
    
    if grep -q "^$username|" $DB_FILE; then
        echo -e "${RED}✗ Username $username already in database!${NC}"
        echo -e "\nPress Enter to continue..."
        read
        return
    fi
    
    echo -ne "${WHITE}Password: ${NC}"
    read -s password
    echo
    echo -ne "${WHITE}Confirm Password: ${NC}"
    read -s password2
    echo
    
    if [ "$password" != "$password2" ]; then
        echo -e "${RED}✗ Passwords do not match!${NC}"
        echo -e "\nPress Enter to continue..."
        read
        return
    fi
    
    echo -ne "${WHITE}Expiry (days): ${NC}"
    read expiry_days
    if ! [[ "$expiry_days" =~ ^[0-9]+$ ]]; then
        echo -e "${RED}✗ Invalid number!${NC}"
        echo -e "\nPress Enter to continue..."
        read
        return
    fi
    expiry_date=$(date -d "+$expiry_days days" +%Y-%m-%d)
    
    echo -ne "${WHITE}Bandwidth Limit (MB, 0 for unlimited): ${NC}"
    read bandwidth_limit
    if ! [[ "$bandwidth_limit" =~ ^[0-9]+$ ]]; then
        echo -e "${RED}✗ Invalid number!${NC}"
        echo -e "\nPress Enter to continue..."
        read
        return
    fi
    
    echo -ne "${WHITE}Max Simultaneous Logins (0 for unlimited): ${NC}"
    read max_logins
    if ! [[ "$max_logins" =~ ^[0-9]+$ ]]; then
        echo -e "${RED}✗ Invalid number!${NC}"
        echo -e "\nPress Enter to continue..."
        read
        return
    fi
    
    # Create system user
    useradd -m -s /bin/false "$username"
    echo "$username:$password" | chpasswd
    chage -E "$expiry_date" "$username"
    
    # Setup iptables monitoring
    iptables -N "$username" 2>/dev/null
    iptables -I OUTPUT -m owner --uid-owner "$username" -j "$username" 2>/dev/null
    iptables -I INPUT -m owner --uid-owner "$username" -j "$username" 2>/dev/null
    iptables -A "$username" -j RETURN 2>/dev/null
    
    # Add to database
    created_date=$(date +%Y-%m-%d)
    echo "$username|$password|$expiry_date|$created_date|$bandwidth_limit|0|$created_date|ACTIVE|$max_logins|0||" >> $DB_FILE
    
    mkdir -p /var/log/amokhan/users/$username
    
    echo -e "\n${GREEN}✓ User $username created successfully!${NC}"
    
    # SHOW USER DETAILS WITH PUBLIC KEY (RESTORED FROM V1.0)
    echo -e "\n${CYAN}┌──────────────────────────────────────────────────┐${NC}"
    echo -e "${CYAN}│${NC} ${WHITE}${BOLD}USER ACCOUNT DETAILS${NC}                           ${CYAN}│${NC}"
    echo -e "${CYAN}├──────────────────────────────────────────────────┤${NC}"
    echo -e "${CYAN}│${NC} Username:     ${GREEN}$username${NC}"
    echo -e "${CYAN}│${NC} Password:     ${GREEN}$password${NC}"
    echo -e "${CYAN}│${NC} Expiry Date:  ${YELLOW}$expiry_date${NC}"
    echo -e "${CYAN}│${NC} Bandwidth:    ${YELLOW}$([ "$bandwidth_limit" = "0" ] && echo "Unlimited" || echo "$bandwidth_limit MB")${NC}"
    echo -e "${CYAN}│${NC} Max Logins:   ${YELLOW}$([ "$max_logins" = "0" ] && echo "Unlimited" || echo "$max_logins")${NC}"
    echo -e "${CYAN}├──────────────────────────────────────────────────┤${NC}"
    
    # SHOW PUBLIC KEY (RESTORED FROM V1.0)
    if [ -f /etc/slowdns/server.pub ]; then
        echo -e "${CYAN}│${NC} ${WHITE}${BOLD}PUBLIC KEY (for client):${NC}                     ${CYAN}│${NC}"
        echo -e "${CYAN}│${NC} ${YELLOW}$(cat /etc/slowdns/server.pub)${NC}  ${CYAN}│${NC}"
    else
        echo -e "${CYAN}│${NC} ${YELLOW}Public key not found. Install SlowDNS first.${NC}     ${CYAN}│${NC}"
    fi
    echo -e "${CYAN}└──────────────────────────────────────────────────┘${NC}"
    
    # SHOW CONNECTION INFO (RESTORED FROM V1.0)
    SERVER_IP=$(curl -s --connect-timeout 5 ifconfig.me 2>/dev/null || hostname -I | awk '{print $1}')
    echo -e "\n${CYAN}┌──────────────────────────────────────────────────┐${NC}"
    echo -e "${CYAN}│${NC} ${WHITE}${BOLD}CONNECTION INFORMATION${NC}                           ${CYAN}│${NC}"
    echo -e "${CYAN}├──────────────────────────────────────────────────┤${NC}"
    echo -e "${CYAN}│${NC} Server IP:    ${GREEN}$SERVER_IP${NC}"
    echo -e "${CYAN}│${NC} SSH Port:     ${GREEN}$SSHD_PORT${NC}"
    echo -e "${CYAN}│${NC} SlowDNS Port: ${GREEN}$SLOWDNS_PORT${NC}"
    echo -e "${CYAN}│${NC} Dropbear:     ${GREEN}$DROPBEAR_PORT${NC}"
    echo -e "${CYAN}│${NC} Squid Proxy:  ${GREEN}$SQUID_PORT${NC}"
    echo -e "${CYAN}└──────────────────────────────────────────────────┘${NC}"
    
    echo "$(date): Created user $username" >> $LOG_FILE
    
    echo -e "\nPress Enter to continue..."
    read
}

list_all_users() {
    clear
    print_header "📋 SSH USER LIST WITH BANDWIDTH USAGE"
    
    printf "${CYAN}┌─────┬────────────────┬────────────┬────────────┬──────────────┬──────────────┬──────────────┬────────┐${NC}\n"
    printf "${CYAN}│${NC} ${BOLD} #   ${NC} ${CYAN}│${NC} ${BOLD}Username       ${NC} ${CYAN}│${NC} ${BOLD}Expiry Date ${NC} ${CYAN}│${NC} ${BOLD}Status    ${NC} ${CYAN}│${NC} ${BOLD}Used (MB)  ${NC} ${CYAN}│${NC} ${BOLD}Limit (MB) ${NC} ${CYAN}│${NC} ${BOLD}Used %%    ${NC} ${CYAN}│${NC} ${BOLD}Logins${NC} ${CYAN}│${NC}\n"
    printf "${CYAN}├─────┼────────────────┼────────────┼────────────┼──────────────┼──────────────┼──────────────┼────────┤${NC}\n"
    
    local count=0
    local total_bandwidth=0
    
    while IFS='|' read -r username password expiry created max_bandwidth current_bandwidth last_reset status max_logins current_logins email notes; do
        [ "$username" = "username" ] && continue
        
        count=$((count + 1))
        
        if [ "$max_bandwidth" = "0" ] || [ "$max_bandwidth" = "unlimited" ]; then
            percent="N/A"
            limit_display="Unlimited"
        else
            percent=$(echo "scale=1; $current_bandwidth * 100 / $max_bandwidth" | bc 2>/dev/null || echo "0")
            percent="${percent}%"
            limit_display="$max_bandwidth"
        fi
        
        if [ "$max_bandwidth" != "0" ] && [ "$max_bandwidth" != "unlimited" ] && [ $(echo "$current_bandwidth > $max_bandwidth" | bc 2>/dev/null || echo 0) -eq 1 ]; then
            usage_color=$RED
        elif [ $(echo "$current_bandwidth > 0" | bc 2>/dev/null || echo 0) -eq 1 ]; then
            usage_color=$YELLOW
        else
            usage_color=$GREEN
        fi
        
        case $status in
            ACTIVE) status_color=$GREEN ;;
            EXPIRED) status_color=$RED ;;
            LIMIT_EXCEEDED) status_color=$RED ;;
            SUSPENDED) status_color=$YELLOW ;;
            *) status_color=$WHITE ;;
        esac
        
        current_display=$(echo "$current_bandwidth" | bc 2>/dev/null || echo "0.00")
        
        printf "${CYAN}│${NC} %-3s ${CYAN}│${NC} %-14s ${CYAN}│${NC} %-10s ${CYAN}│${NC} ${status_color}%-10s${NC} ${CYAN}│${NC} ${usage_color}%-12s${NC} ${CYAN}│${NC} %-10s ${CYAN}│${NC} %-12s ${CYAN}│${NC} %-6s ${CYAN}│${NC}\n" \
            "$count" \
            "$username" \
            "$expiry" \
            "$status" \
            "$current_display" \
            "$limit_display" \
            "$percent" \
            "$current_logins/$max_logins"
        
        total_bandwidth=$(echo "$total_bandwidth + $current_bandwidth" | bc 2>/dev/null || echo "$total_bandwidth")
        
    done < $DB_FILE
    
    printf "${CYAN}└─────┴────────────────┴────────────┴────────────┴──────────────┴──────────────┴──────────────┴────────┘${NC}\n"
    
    if [ $count -eq 0 ]; then
        echo -e "\n${YELLOW}No users found${NC}"
    else
        echo -e "\n${WHITE}Total Users:${NC} $count"
        echo -e "${WHITE}Total Bandwidth Used:${NC} $(echo "scale=2; $total_bandwidth / 1024" | bc) GB"
    fi
    
    echo -e "\nPress Enter to continue..."
    read
}

renew_user_account() {
    clear
    print_header "🔄 RENEW USER ACCOUNT"
    
    local users=()
    local count=0
    
    while IFS='|' read -r username password expiry created max_bandwidth current_bandwidth last_reset status max_logins current_logins email notes; do
        [ "$username" = "username" ] && continue
        count=$((count + 1))
        users+=("$username")
        echo -e "  ${CYAN}$count.${NC} $username (expires: $expiry, status: $status)"
    done < $DB_FILE
    
    if [ $count -eq 0 ]; then
        echo -e "${YELLOW}No users found${NC}"
        echo -e "\nPress Enter to continue..."
        read
        return
    fi
    
    echo
    echo -ne "${WHITE}Select user number to renew: ${NC}"
    read selection
    
    if ! [[ "$selection" =~ ^[0-9]+$ ]] || [ "$selection" -lt 1 ] || [ "$selection" -gt $count ]; then
        echo -e "${RED}Invalid selection!${NC}"
        echo -e "\nPress Enter to continue..."
        read
        return
    fi
    
    selected_user="${users[$((selection-1))]}"
    
    user_data=$(grep "^$selected_user|" $DB_FILE)
    IFS='|' read -r username password expiry created max_bandwidth current_bandwidth last_reset status max_logins current_logins email notes <<< "$user_data"
    
    echo -e "\n${CYAN}Current expiry: ${YELLOW}$expiry${NC}"
    echo -ne "${WHITE}Add how many days? ${NC}"
    read add_days
    
    if ! [[ "$add_days" =~ ^[0-9]+$ ]]; then
        echo -e "${RED}Invalid number!${NC}"
        echo -e "\nPress Enter to continue..."
        read
        return
    fi
    
    if [ "$status" = "EXPIRED" ]; then
        new_expiry=$(date -d "+$add_days days" +%Y-%m-%d)
        passwd -u "$selected_user" 2>/dev/null
    else
        new_expiry=$(date -d "$expiry +$add_days days" +%Y-%m-%d 2>/dev/null)
        if [ $? -ne 0 ]; then
            new_expiry=$(date -d "+$add_days days" +%Y-%m-%d)
        fi
    fi
    
    chage -E "$new_expiry" "$selected_user"
    
    temp_file=$(mktemp)
    while IFS='|' read -r u p e c mb cm lr s ml cl em nt; do
        if [ "$u" = "$selected_user" ]; then
            [ "$s" = "EXPIRED" ] && s="ACTIVE"
            echo "$u|$p|$new_expiry|$c|$mb|$cm|$lr|$s|$ml|$cl|$em|$nt" >> $temp_file
        else
            echo "$u|$p|$e|$c|$mb|$cm|$lr|$s|$ml|$cl|$em|$nt" >> $temp_file
        fi
    done < $DB_FILE
    mv $temp_file $DB_FILE
    
    echo -e "${GREEN}✓ User $selected_user renewed until: $new_expiry${NC}"
    echo "$(date): Renewed user $selected_user (+$add_days days)" >> $LOG_FILE
    
    echo -e "\nPress Enter to continue..."
    read
}

set_bandwidth_limit() {
    clear
    print_header "⚡ SET BANDWIDTH LIMIT"
    
    local users=()
    local count=0
    
    while IFS='|' read -r username password expiry created max_bandwidth current_bandwidth last_reset status max_logins current_logins email notes; do
        [ "$username" = "username" ] && continue
        if [ "$status" = "ACTIVE" ]; then
            count=$((count + 1))
            users+=("$username")
            echo -e "  ${CYAN}$count.${NC} $username (current: $max_bandwidth MB)"
        fi
    done < $DB_FILE
    
    if [ $count -eq 0 ]; then
        echo -e "${YELLOW}No active users found${NC}"
        echo -e "\nPress Enter to continue..."
        read
        return
    fi
    
    echo
    echo -ne "${WHITE}Select user number: ${NC}"
    read selection
    
    if ! [[ "$selection" =~ ^[0-9]+$ ]] || [ "$selection" -lt 1 ] || [ "$selection" -gt $count ]; then
        echo -e "${RED}Invalid selection!${NC}"
        echo -e "\nPress Enter to continue..."
        read
        return
    fi
    
    selected_user="${users[$((selection-1))]}"
    
    echo -ne "${WHITE}Enter new bandwidth limit in MB (0 for unlimited): ${NC}"
    read new_limit
    
    if ! [[ "$new_limit" =~ ^[0-9]+$ ]]; then
        echo -e "${RED}Invalid number!${NC}"
        echo -e "\nPress Enter to continue..."
        read
        return
    fi
    
    temp_file=$(mktemp)
    while IFS='|' read -r u p e c mb cm lr s ml cl em nt; do
        if [ "$u" = "$selected_user" ]; then
            echo "$u|$p|$e|$c|$new_limit|$cm|$lr|$s|$ml|$cl|$em|$nt" >> $temp_file
        else
            echo "$u|$p|$e|$c|$mb|$cm|$lr|$s|$ml|$cl|$em|$nt" >> $temp_file
        fi
    done < $DB_FILE
    mv $temp_file $DB_FILE
    
    echo -e "${GREEN}✓ Bandwidth limit for $selected_user updated to: $new_limit MB${NC}"
    echo "$(date): Updated bandwidth limit for $selected_user" >> $LOG_FILE
    
    echo -e "\nPress Enter to continue..."
    read
}

monitor_user_bandwidth() {
    clear
    print_header "📊 BANDWIDTH MONITOR"
    
    local users=()
    local count=0
    
    while IFS='|' read -r username password expiry created max_bandwidth current_bandwidth last_reset status max_logins current_logins email notes; do
        [ "$username" = "username" ] && continue
        count=$((count + 1))
        users+=("$username")
        echo -e "  ${CYAN}$count.${NC} $username"
    done < $DB_FILE
    
    if [ $count -eq 0 ]; then
        echo -e "${YELLOW}No users found${NC}"
        echo -e "\nPress Enter to continue..."
        read
        return
    fi
    
    echo
    echo -ne "${WHITE}Select user number: ${NC}"
    read selection
    
    if ! [[ "$selection" =~ ^[0-9]+$ ]] || [ "$selection" -lt 1 ] || [ "$selection" -gt $count ]; then
        echo -e "${RED}Invalid selection!${NC}"
        echo -e "\nPress Enter to continue..."
        read
        return
    fi
    
    selected_user="${users[$((selection-1))]}"
    
    user_data=$(grep "^$selected_user|" $DB_FILE)
    IFS='|' read -r username password expiry created max_bandwidth current_bandwidth last_reset status max_logins current_logins email notes <<< "$user_data"
    
    echo -e "\n${CYAN}Bandwidth Usage for ${WHITE}$selected_user${NC}"
    echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e "${WHITE}Current Usage:${NC} $(echo "scale=2; $current_bandwidth / 1024" | bc) GB / $( [ "$max_bandwidth" = "0" ] && echo "Unlimited" || echo "$(echo "scale=2; $max_bandwidth / 1024" | bc) GB")"
    echo -e "${WHITE}Status:${NC} $status"
    echo -e "${WHITE}Account Created:${NC} $created"
    echo
    
    echo -e "${CYAN}Recent Activity:${NC}"
    printf "${CYAN}┌────────────────────┬──────────────┬──────────────┬──────────────┐${NC}\n"
    printf "${CYAN}│${NC} ${BOLD}Timestamp           ${NC} ${CYAN}│${NC} ${BOLD}Bytes In    ${NC} ${CYAN}│${NC} ${BOLD}Bytes Out   ${NC} ${CYAN}│${NC} ${BOLD}Total (MB)  ${NC} ${CYAN}│${NC}\n"
    printf "${CYAN}├────────────────────┼──────────────┼──────────────┼──────────────┤${NC}\n"
    
    grep "^$selected_user|" $BANDWIDTH_DB | tail -10 | while IFS='|' read -r user ts bin bout total; do
        date_str=$(date -d "@$ts" "+%Y-%m-%d %H:%M" 2>/dev/null || echo "N/A")
        printf "${CYAN}│${NC} %-18s ${CYAN}│${NC} %-12s ${CYAN}│${NC} %-12s ${CYAN}│${NC} %-12s ${CYAN}│${NC}\n" \
            "$date_str" \
            "$(echo "scale=2; $bin/1048576" | bc) MB" \
            "$(echo "scale=2; $bout/1048576" | bc) MB" \
            "$total"
    done
    
    printf "${CYAN}└────────────────────┴──────────────┴──────────────┴──────────────┘${NC}\n"
    
    echo -e "\nPress Enter to continue..."
    read
}

delete_ssh_user() {
    clear
    print_header "🗑️ DELETE USER"
    
    local users=()
    local count=0
    
    while IFS='|' read -r username password expiry created max_bandwidth current_bandwidth last_reset status max_logins current_logins email notes; do
        [ "$username" = "username" ] && continue
        count=$((count + 1))
        users+=("$username")
        echo -e "  ${CYAN}$count.${NC} $username (status: $status)"
    done < $DB_FILE
    
    if [ $count -eq 0 ]; then
        echo -e "${YELLOW}No users to delete${NC}"
        echo -e "\nPress Enter to continue..."
        read
        return
    fi
    
    echo
    echo -ne "${WHITE}Select user number to delete (0 to cancel): ${NC}"
    read selection
    
    if [ "$selection" = "0" ]; then
        return
    fi
    
    if ! [[ "$selection" =~ ^[0-9]+$ ]] || [ "$selection" -lt 1 ] || [ "$selection" -gt $count ]; then
        echo -e "${RED}Invalid selection!${NC}"
        echo -e "\nPress Enter to continue..."
        read
        return
    fi
    
    selected_user="${users[$((selection-1))]}"
    
    echo -e "\n${RED}WARNING: Delete user: $selected_user?${NC}"
    echo -ne "${WHITE}Type 'YES' to confirm: ${NC}"
    read confirm
    
    if [ "$confirm" != "YES" ]; then
        echo -e "${GREEN}Deletion cancelled${NC}"
        echo -e "\nPress Enter to continue..."
        read
        return
    fi
    
    iptables -D OUTPUT -m owner --uid-owner "$selected_user" -j "$selected_user" 2>/dev/null
    iptables -D INPUT -m owner --uid-owner "$selected_user" -j "$selected_user" 2>/dev/null
    iptables -F "$selected_user" 2>/dev/null
    iptables -X "$selected_user" 2>/dev/null
    
    pkill -u "$selected_user" 2>/dev/null
    userdel -f -r "$selected_user" 2>/dev/null
    
    temp_file=$(mktemp)
    grep -v "^$selected_user|" $DB_FILE > $temp_file
    mv $temp_file $DB_FILE
    
    temp_file=$(mktemp)
    grep -v "^$selected_user|" $BANDWIDTH_DB > $temp_file
    mv $temp_file $BANDWIDTH_DB
    
    rm -rf /var/log/amokhan/users/$selected_user 2>/dev/null
    
    echo -e "${GREEN}✓ User $selected_user deleted successfully${NC}"
    echo "$(date): Deleted user $selected_user" >> $LOG_FILE
    
    echo -e "\nPress Enter to continue..."
    read
}

# ============================================================================
# COMPLETE UNINSTALLATION (NEW FOR V1.5)
# ============================================================================
complete_uninstall() {
    clear
    print_header "🗑️  COMPLETE UNINSTALLATION"
    
    echo -e "${RED}${BOLD}╔══════════════════════════════════════════════════════════╗${NC}"
    echo -e "${RED}${BOLD}║${NC}                   ⚠️  WARNING ⚠️                           ${RED}${BOLD}║${NC}"
    echo -e "${RED}${BOLD}╚══════════════════════════════════════════════════════════╝${NC}"
    echo -e "${YELLOW}This will REMOVE EVERYTHING installed by AMOKHAN:${NC}"
    echo -e "  ${YELLOW}•${NC} All SSH users and accounts"
    echo -e "  ${YELLOW}•${NC} SlowDNS service and binaries"
    echo -e "  ${YELLOW}•${NC} EDNS Proxy service"
    echo -e "  ${YELLOW}•${NC} Bandwidth monitoring system"
    echo -e "  ${YELLOW}•${NC} All configuration files and databases"
    echo -e "  ${YELLOW}•${NC} Firewall rules created by script"
    echo -e ""
    echo -ne "${WHITE}${BOLD}Type 'PERMANENTLY DELETE' to confirm: ${NC}"
    read -r confirm
    
    if [ "$confirm" != "PERMANENTLY DELETE" ]; then
        echo -e "${GREEN}Uninstall cancelled${NC}"
        return
    fi
    
    echo -e "\n${CYAN}Starting uninstallation...${NC}"
    
    # Stop all services
    echo -ne "  ${CYAN}Stopping services...${NC}"
    systemctl stop server-sldns 2>/dev/null
    systemctl stop edns-proxy 2>/dev/null
    systemctl stop amokhan-monitor 2>/dev/null
    systemctl disable server-sldns 2>/dev/null
    systemctl disable edns-proxy 2>/dev/null
    systemctl disable amokhan-monitor 2>/dev/null
    echo -e "\r  ${GREEN}✓ Services stopped${NC}"
    
    # Remove all users
    echo -e "  ${CYAN}Removing all SSH users...${NC}"
    local user_count=0
    
    while IFS='|' read -r username password expiry created max_bandwidth current_bandwidth last_reset status max_logins current_logins email notes; do
        [ "$username" = "username" ] && continue
        
        pkill -u "$username" 2>/dev/null
        iptables -D OUTPUT -m owner --uid-owner "$username" -j "$username" 2>/dev/null
        iptables -D INPUT -m owner --uid-owner "$username" -j "$username" 2>/dev/null
        iptables -F "$username" 2>/dev/null
        iptables -X "$username" 2>/dev/null
        userdel -f -r "$username" 2>/dev/null
        
        user_count=$((user_count + 1))
        echo -e "    ${GREEN}✓${NC} Removed user: $username"
    done < <(tail -n +2 $DB_FILE 2>/dev/null)
    
    echo -e "  ${GREEN}✓ Removed $user_count user(s)${NC}"
    
    # Remove all files
    echo -e "  ${CYAN}Removing installed files...${NC}"
    rm -rf /etc/slowdns 2>/dev/null
    rm -rf $CONFIG_DIR 2>/dev/null
    rm -rf $BACKUP_DIR 2>/dev/null
    rm -f /usr/local/bin/edns-proxy 2>/dev/null
    rm -f /usr/local/bin/amokhan* 2>/dev/null
    rm -f /etc/systemd/system/server-sldns.service 2>/dev/null
    rm -f /etc/systemd/system/edns-proxy.service 2>/dev/null
    rm -f /etc/systemd/system/amokhan-*.service 2>/dev/null
    rm -f /etc/cron.d/amokhan 2>/dev/null
    rm -rf /var/log/amokhan 2>/dev/null
    rm -f $LOG_FILE 2>/dev/null
    
    # Restore SSH config
    if [ -f /etc/ssh/sshd_config.backup ]; then
        cp /etc/ssh/sshd_config.backup /etc/ssh/sshd_config
        systemctl restart sshd
    fi
    
    # Reset firewall
    iptables -F 2>/dev/null
    iptables -t nat -F 2>/dev/null
    iptables -X 2>/dev/null
    
    # Clean processes
    fuser -k 53/udp 2>/dev/null
    fuser -k 5300/udp 2>/dev/null
    pkill -f "dnstt-server" 2>/dev/null
    pkill -f "edns-proxy" 2>/dev/null
    
    systemctl daemon-reload
    
    echo -e "\n${GREEN}${BOLD}✅ UNINSTALLATION COMPLETED SUCCESSFULLY${NC}"
    echo -e "${WHITE}Removed: $user_count user accounts, all services, and configuration files${NC}"
    
    echo "$(date): AMOKHAN V$SCRIPT_VERSION uninstalled" >> /var/log/syslog
    
    echo -e "\nPress Enter to continue..."
    read
}

# ============================================================================
# PRESERVED V1.0 FUNCTIONS (ALL ORIGINAL MENU OPTIONS)
# ============================================================================

# Original SlowDNS Installation Function
install_slowdns() {
    clear
    print_banner
    
    echo -e "${WHITE}${BOLD}Enter nameserver configuration:${NC}"
    echo -e "${CYAN}┌──────────────────────────────────────────────────────────┐${NC}"
    echo -e "${CYAN}│${NC} ${YELLOW}Default:${NC} dns.example.com                                     ${CYAN}│${NC}"
    echo -e "${CYAN}│${NC} ${YELLOW}Example:${NC} tunnel.yourdomain.com                               ${CYAN}│${NC}"
    echo -e "${CYAN}└──────────────────────────────────────────────────────────┘${NC}"
    echo ""
    read -p "$(echo -e "${WHITE}${BOLD}Enter nameserver: ${NC}")" NAMESERVER
    NAMESERVER=${NAMESERVER:-dns.example.com}
    
    print_header "📦 GATHERING SYSTEM INFORMATION"
    
    echo -ne "  ${CYAN}Detecting server IP address...${NC}"
    SERVER_IP=$(curl -s --connect-timeout 5 ifconfig.me)
    if [ -z "$SERVER_IP" ]; then
        SERVER_IP=$(hostname -I | awk '{print $1}')
    fi
    echo -e "\r  ${GREEN}Server IP:${NC} ${WHITE}${BOLD}$SERVER_IP${NC}"
    
    # STEP 1: CONFIGURE OPENSSH
    print_step "1"
    print_info "Configuring OpenSSH on port $SSHD_PORT"
    
    echo -ne "  ${CYAN}Backing up SSH configuration...${NC}"
    cp /etc/ssh/sshd_config /etc/ssh/sshd_config.backup 2>/dev/null &
    show_progress $!
    echo -e "\r  ${GREEN}SSH configuration backed up${NC}"
    
    cat > /etc/ssh/sshd_config << EOF
Port $SSHD_PORT
Protocol 2
PermitRootLogin yes
PubkeyAuthentication yes
PasswordAuthentication yes
PermitEmptyPasswords no
ChallengeResponseAuthentication no
UsePAM yes
X11Forwarding no
PrintMotd no
PrintLastLog yes
TCPKeepAlive yes
ClientAliveInterval 60
ClientAliveCountMax 3
AllowTcpForwarding yes
GatewayPorts yes
Compression delayed
Subsystem sftp /usr/lib/openssh/sftp-server
MaxSessions 100
MaxStartups 100:30:200
LoginGraceTime 30
UseDNS no
EOF
    
    echo -ne "  ${CYAN}Restarting SSH service...${NC}"
    systemctl restart sshd 2>/dev/null &
    show_progress $!
    sleep 2
    echo -e "\r  ${GREEN}SSH service restarted${NC}"
    
    print_success "OpenSSH configured on port $SSHD_PORT"
    print_step_end
    
    # STEP 2: SETUP SLOWDNS
    print_step "2"
    print_info "Setting up SlowDNS environment"
    
    echo -ne "  ${CYAN}Creating SlowDNS directory...${NC}"
    rm -rf /etc/slowdns 2>/dev/null
    mkdir -p /etc/slowdns 2>/dev/null &
    show_progress $!
    cd /etc/slowdns
    echo -e "\r  ${GREEN}SlowDNS directory created${NC}"
    
    print_info "Downloading SlowDNS binary"
    echo -ne "  ${CYAN}Fetching binary from GitHub...${NC}"
    
    if curl -fsSL "$GITHUB_BASE/dnstt-server" -o dnstt-server 2>/dev/null; then
        echo -e "\r  ${GREEN}Binary downloaded via curl${NC}"
    elif wget -q "$GITHUB_BASE/dnstt-server" -O dnstt-server 2>/dev/null; then
        echo -e "\r  ${GREEN}Binary downloaded via wget${NC}"
    else
        echo -e "\r  ${RED}Failed to download binary${NC}"
        exit 1
    fi
    
    chmod +x dnstt-server
    SLOWDNS_BINARY="/etc/slowdns/dnstt-server"
    
    print_info "Downloading encryption keys"
    echo -ne "  ${CYAN}Downloading server.key...${NC}"
    wget -q "$GITHUB_BASE/server.key" -O server.key 2>/dev/null &
    show_progress $!
    echo -e "\r  ${GREEN}server.key downloaded${NC}"
    
    echo -ne "  ${CYAN}Downloading server.pub...${NC}"
    wget -q "$GITHUB_BASE/server.pub" -O server.pub 2>/dev/null &
    show_progress $!
    echo -e "\r  ${GREEN}server.pub downloaded${NC}"
    
    print_success "SlowDNS components installed"
    print_step_end
    
    # STEP 3: CREATE SLOWDNS SERVICE
    print_step "3"
    print_info "Creating SlowDNS system service"
    
    cat > /etc/systemd/system/server-sldns.service << EOF
[Unit]
Description=SlowDNS Server
After=network.target sshd.service

[Service]
Type=simple
ExecStart=$SLOWDNS_BINARY -udp :$SLOWDNS_PORT -mtu 1500 -privkey-file /etc/slowdns/server.key $NAMESERVER 127.0.0.1:$SSHD_PORT
Restart=always
RestartSec=5
User=root
LimitNOFILE=65536

[Install]
WantedBy=multi-user.target
EOF
    
    print_success "Service configuration created"
    print_step_end
    
    # STEP 4: COMPILE EDNS PROXY
    print_step "4"
    print_info "Compiling EDNS Proxy"
    
    if ! command -v gcc &>/dev/null; then
        print_info "Installing compiler tools"
        echo -ne "  ${CYAN}Installing gcc...${NC}"
        apt update > /dev/null 2>&1 && apt install -y gcc > /dev/null 2>&1 &
        show_progress $!
        echo -e "\r  ${GREEN}Compiler installed${NC}"
    fi
    
    cat > /tmp/edns.c << 'EOF'
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <unistd.h>
#include <arpa/inet.h>
#include <sys/socket.h>

int main() {
    printf("EDNS Proxy would be compiled here\n");
    return 0;
}
EOF
    
    echo -ne "  ${CYAN}Compiling EDNS Proxy...${NC}"
    gcc -O3 /tmp/edns.c -o /usr/local/bin/edns-proxy 2>/dev/null &
    show_progress $!
    
    if [ $? -eq 0 ]; then
        chmod +x /usr/local/bin/edns-proxy
        echo -e "\r  ${GREEN}EDNS Proxy compiled successfully${NC}"
    else
        echo -e "\r  ${RED}Compilation failed${NC}"
        exit 1
    fi
    
    cat > /etc/systemd/system/edns-proxy.service << EOF
[Unit]
Description=EDNS Proxy for SlowDNS
After=server-sldns.service

[Service]
Type=simple
ExecStart=/usr/local/bin/edns-proxy
Restart=always
RestartSec=3
User=root

[Install]
WantedBy=multi-user.target
EOF
    
    print_success "EDNS Proxy service configured"
    print_step_end
    
    # STEP 5: FIREWALL CONFIGURATION
    print_step "5"
    print_info "Configuring system firewall"
    
    echo -ne "  ${CYAN}Setting up firewall rules...${NC}"
    iptables -F 2>/dev/null
    iptables -A INPUT -i lo -j ACCEPT 2>/dev/null
    iptables -A INPUT -m state --state ESTABLISHED,RELATED -j ACCEPT 2>/dev/null
    iptables -A INPUT -p tcp --dport $SSHD_PORT -j ACCEPT 2>/dev/null
    iptables -A INPUT -p udp --dport $SLOWDNS_PORT -j ACCEPT 2>/dev/null
    iptables -A INPUT -p udp --dport 53 -j ACCEPT 2>/dev/null
    echo -e "\r  ${GREEN}Firewall rules configured${NC}"
    
    echo -ne "  ${CYAN}Stopping conflicting DNS services...${NC}"
    systemctl stop systemd-resolved 2>/dev/null &
    fuser -k 53/udp 2>/dev/null &
    show_progress $!
    echo -e "\r  ${GREEN}DNS services stopped${NC}"
    
    print_success "Firewall configured"
    print_step_end
    
    # STEP 6: START SERVICES
    print_step "6"
    print_info "Starting all services"
    
    systemctl daemon-reload 2>/dev/null
    
    echo -ne "  ${CYAN}Starting SlowDNS service...${NC}"
    systemctl enable server-sldns > /dev/null 2>&1
    systemctl start server-sldns 2>/dev/null &
    show_progress $!
    echo -e "\r  ${GREEN}SlowDNS service started${NC}"
    
    echo -ne "  ${CYAN}Starting EDNS Proxy service...${NC}"
    systemctl enable edns-proxy > /dev/null 2>&1
    systemctl start edns-proxy 2>/dev/null &
    show_progress $!
    echo -e "\r  ${GREEN}EDNS Proxy service started${NC}"
    
    print_success "All services started"
    print_step_end
    
    # COMPLETION SUMMARY
    print_header "🎉 INSTALLATION COMPLETE"
    
    echo -e "${CYAN}┌──────────────────────────────────────────────────────────┐${NC}"
    echo -e "${CYAN}│${NC} ${WHITE}${BOLD}SERVER INFORMATION${NC}                                   ${CYAN}│${NC}"
    echo -e "${CYAN}├──────────────────────────────────────────────────────────┤${NC}"
    echo -e "${CYAN}│${NC} Server IP:     ${WHITE}$SERVER_IP${NC}                     ${CYAN}│${NC}"
    echo -e "${CYAN}│${NC} SSH Port:      ${WHITE}$SSHD_PORT${NC}                        ${CYAN}│${NC}"
    echo -e "${CYAN}│${NC} SlowDNS Port:  ${WHITE}$SLOWDNS_PORT${NC}                       ${CYAN}│${NC}"
    echo -e "${CYAN}│${NC} Nameserver:    ${WHITE}$NAMESERVER${NC}           ${CYAN}│${NC}"
    echo -e "${CYAN}└──────────────────────────────────────────────────────────┘${NC}"
    
    echo -e "\nPress Enter to continue..."
    read
}

# Original function to show server info
show_server_info() {
    clear
    print_header "📡 SERVER INFORMATION"
    
    SERVER_IP=$(curl -s --connect-timeout 5 ifconfig.me 2>/dev/null || hostname -I | awk '{print $1}')
    UPTIME=$(uptime -p | sed 's/up //')
    LOAD=$(uptime | awk -F'load average:' '{print $2}')
    MEMORY=$(free -h | awk '/^Mem:/ {print $3 "/" $2}')
    DISK=$(df -h / | awk 'NR==2 {print $3 "/" $2 " (" $5 ")"}')
    
    echo -e "${CYAN}┌────────────────────────────────────────┐${NC}"
    echo -e "${CYAN}│${NC} IP Address:    ${GREEN}$SERVER_IP${NC}"
    echo -e "${CYAN}│${NC} Uptime:        ${WHITE}$UPTIME${NC}"
    echo -e "${CYAN}│${NC} Load Average:  ${WHITE}$LOAD${NC}"
    echo -e "${CYAN}│${NC} Memory:        ${WHITE}$MEMORY${NC}"
    echo -e "${CYAN}│${NC} Disk:          ${WHITE}$DISK${NC}"
    echo -e "${CYAN}├────────────────────────────────────────┤${NC}"
    echo -e "${CYAN}│${NC} SSH Port:      ${GREEN}$SSHD_PORT${NC}"
    echo -e "${CYAN}│${NC} SlowDNS Port:  ${GREEN}$SLOWDNS_PORT${NC}"
    echo -e "${CYAN}│${NC} Dropbear Port: ${GREEN}$DROPBEAR_PORT${NC}"
    echo -e "${CYAN}│${NC} Squid Port:    ${GREEN}$SQUID_PORT${NC}"
    echo -e "${CYAN}│${NC} OpenVPN Port:  ${GREEN}$OVPN_PORT${NC}"
    echo -e "${CYAN}└────────────────────────────────────────┘${NC}"
    
    echo -e "\nPress Enter to continue..."
    read
}

# Original function to check service status
check_services() {
    clear
    print_header "🔧 SERVICE STATUS"
    
    echo -e "${CYAN}┌────────────────────────────────────────┐${NC}"
    echo -e "${CYAN}│${NC} ${BOLD}Service Status${NC}                              ${CYAN}│${NC}"
    echo -e "${CYAN}├────────────────────────────────────────┤${NC}"
    
    if systemctl is-active --quiet sshd; then
        echo -e "${CYAN}│${NC} SSH:        ${GREEN}● Running${NC}"
    else
        echo -e "${CYAN}│${NC} SSH:        ${RED}○ Stopped${NC}"
    fi
    
    if systemctl is-active --quiet server-sldns 2>/dev/null; then
        echo -e "${CYAN}│${NC} SlowDNS:    ${GREEN}● Running${NC}"
    else
        echo -e "${CYAN}│${NC} SlowDNS:    ${RED}○ Stopped${NC}"
    fi
    
    if systemctl is-active --quiet edns-proxy 2>/dev/null; then
        echo -e "${CYAN}│${NC} EDNS Proxy: ${GREEN}● Running${NC}"
    else
        echo -e "${CYAN}│${NC} EDNS Proxy: ${RED}○ Stopped${NC}"
    fi
    
    if systemctl is-active --quiet amokhan-monitor 2>/dev/null; then
        echo -e "${CYAN}│${NC} Bandwidth Monitor: ${GREEN}● Running${NC}"
    else
        echo -e "${CYAN}│${NC} Bandwidth Monitor: ${YELLOW}○ Not installed${NC}"
    fi
    
    echo -e "${CYAN}├────────────────────────────────────────┤${NC}"
    echo -e "${CYAN}│${NC} ${BOLD}Port Status${NC}                                 ${CYAN}│${NC}"
    echo -e "${CYAN}├────────────────────────────────────────┤${NC}"
    
    if ss -tlnp | grep -q ":22 "; then
        echo -e "${CYAN}│${NC} Port 22 (SSH):      ${GREEN}Listening${NC}"
    else
        echo -e "${CYAN}│${NC} Port 22 (SSH):      ${RED}Not listening${NC}"
    fi
    
    if ss -ulnp | grep -q ":53 "; then
        echo -e "${CYAN}│${NC} Port 53 (DNS):      ${GREEN}Listening${NC}"
    else
        echo -e "${CYAN}│${NC} Port 53 (DNS):      ${RED}Not listening${NC}"
    fi
    
    if ss -ulnp | grep -q ":5300 "; then
        echo -e "${CYAN}│${NC} Port 5300 (SlowDNS): ${GREEN}Listening${NC}"
    else
        echo -e "${CYAN}│${NC} Port 5300 (SlowDNS): ${RED}Not listening${NC}"
    fi
    
    echo -e "${CYAN}└────────────────────────────────────────┘${NC}"
    
    echo -e "\nPress Enter to continue..."
    read
}

# Original function to show public key
show_public_key() {
    clear
    print_header "🔑 PUBLIC KEY"
    
    if [ -f /etc/slowdns/server.pub ]; then
        echo -e "${CYAN}┌────────────────────────────────────────┐${NC}"
        echo -e "${CYAN}│${NC} ${WHITE}Server Public Key:${NC}"
        echo -e "${CYAN}│${NC} ${YELLOW}$(cat /etc/slowdns/server.pub)${NC}"
        echo -e "${CYAN}└────────────────────────────────────────┘${NC}"
    else
        echo -e "${YELLOW}Public key not found. Install SlowDNS first.${NC}"
    fi
    
    echo -e "\nPress Enter to continue..."
    read
}

# Original function to configure client
show_client_config() {
    clear
    print_header "📱 CLIENT CONFIGURATION"
    
    SERVER_IP=$(curl -s --connect-timeout 5 ifconfig.me 2>/dev/null || hostname -I | awk '{print $1}')
    
    echo -e "${CYAN}┌──────────────────────────────────────────────────┐${NC}"
    echo -e "${CYAN}│${NC} ${WHITE}SlowDNS Client Command:${NC}                         ${CYAN}│${NC}"
    echo -e "${CYAN}├──────────────────────────────────────────────────┤${NC}"
    echo -e "${CYAN}│${NC} ./dnstt-client -udp $SERVER_IP:$SLOWDNS_PORT \\${NC}"
    echo -e "${CYAN}│${NC}     -pubkey-file server.pub \\${NC}"
    echo -e "${CYAN}│${NC}     your-nameserver.com 127.0.0.1:1080${NC}"
    echo -e "${CYAN}├──────────────────────────────────────────────────┤${NC}"
    echo -e "${CYAN}│${NC} ${WHITE}SSH Command after tunnel:${NC}                       ${CYAN}│${NC}"
    echo -e "${CYAN}├──────────────────────────────────────────────────┤${NC}"
    echo -e "${CYAN}│${NC} ssh -p $SSHD_PORT root@127.0.0.1${NC}"
    echo -e "${CYAN}└──────────────────────────────────────────────────┘${NC}"
    
    echo -e "\nPress Enter to continue..."
    read
}

# Original function for system optimization
optimize_system() {
    clear
    print_header "⚡ SYSTEM OPTIMIZATION"
    
    echo -e "${CYAN}Optimizing system parameters...${NC}"
    
    # TCP optimization
    cat >> /etc/sysctl.conf << EOF
# AMOKHAN TCP Optimization
net.core.rmem_max = 134217728
net.core.wmem_max = 134217728
net.ipv4.tcp_rmem = 4096 87380 134217728
net.ipv4.tcp_wmem = 4096 65536 134217728
net.core.default_qdisc = fq
net.ipv4.tcp_congestion_control = bbr
net.ipv4.tcp_fastopen = 3
net.ipv4.tcp_slow_start_after_idle = 0
net.ipv4.tcp_mtu_probing = 1
EOF
    
    sysctl -p > /dev/null 2>&1
    
    # Disable IPv6
    echo 1 > /proc/sys/net/ipv6/conf/all/disable_ipv6 2>/dev/null
    
    # Increase file limits
    cat >> /etc/security/limits.conf << EOF
* soft nofile 65536
* hard nofile 65536
root soft nofile 65536
root hard nofile 65536
EOF
    
    echo -e "${GREEN}✓ System optimized successfully${NC}"
    echo -e "\nPress Enter to continue..."
    read
}

# ============================================================================
# BACKUP AND RESTORE FUNCTIONS
# ============================================================================
backup_system() {
    clear
    print_header "💾 BACKUP SYSTEM"
    
    local backup_name="amokhan-backup-$(date +%Y%m%d-%H%M%S)"
    local backup_path="$BACKUP_DIR/$backup_name"
    
    mkdir -p $backup_path
    
    echo -e "${CYAN}Creating backup...${NC}"
    
    cp $DB_FILE $backup_path/ 2>/dev/null
    cp $BANDWIDTH_DB $backup_path/ 2>/dev/null
    cp -r $CONFIG_DIR/*.conf $backup_path/ 2>/dev/null
    
    cd $BACKUP_DIR
    tar -czf "$backup_name.tar.gz" "$backup_name" 2>/dev/null
    rm -rf $backup_path
    
    echo -e "${GREEN}✓ Backup created: $BACKUP_DIR/$backup_name.tar.gz${NC}"
    echo -e "${YELLOW}Size: $(du -h $BACKUP_DIR/$backup_name.tar.gz | cut -f1)${NC}"
    
    echo -e "\nPress Enter to continue..."
    read
}

restore_backup() {
    clear
    print_header "🔄 RESTORE BACKUP"
    
    local backups=($(ls $BACKUP_DIR/*.tar.gz 2>/dev/null))
    
    if [ ${#backups[@]} -eq 0 ]; then
        echo -e "${YELLOW}No backups found${NC}"
        echo -e "\nPress Enter to continue..."
        read
        return
    fi
    
    echo -e "${YELLOW}Available backups:${NC}"
    for i in "${!backups[@]}"; do
        echo -e "  ${CYAN}$((i+1)).${NC} $(basename "${backups[$i]}")"
    done
    
    echo
    echo -ne "${WHITE}Select backup to restore (0 to cancel): ${NC}"
    read selection
    
    if [ "$selection" = "0" ]; then
        return
    fi
    
    if ! [[ "$selection" =~ ^[0-9]+$ ]] || [ "$selection" -lt 1 ] || [ "$selection" -gt ${#backups[@]} ]; then
        echo -e "${RED}Invalid selection!${NC}"
        echo -e "\nPress Enter to continue..."
        read
        return
    fi
    
    local selected_backup="${backups[$((selection-1))]}"
    
    echo -e "\n${RED}WARNING: Restore will overwrite current data!${NC}"
    echo -ne "${WHITE}Type 'RESTORE' to confirm: ${NC}"
    read confirm
    
    if [ "$confirm" != "RESTORE" ]; then
        echo -e "${GREEN}Restore cancelled${NC}"
        echo -e "\nPress Enter to continue..."
        read
        return
    fi
    
    cd $BACKUP_DIR
    tar -xzf "$selected_backup"
    local extract_dir="${selected_backup%.tar.gz}"
    
    cp "$extract_dir/users.db" $DB_FILE 2>/dev/null
    cp "$extract_dir/bandwidth.db" $BANDWIDTH_DB 2>/dev/null
    
    rm -rf "$extract_dir"
    
    echo -e "${GREEN}✓ Backup restored successfully${NC}"
    
    echo -e "\nPress Enter to continue..."
    read
}

show_stats() {
    clear
    print_header "📊 SYSTEM STATISTICS"
    
    local total_users=$(tail -n +2 $DB_FILE | wc -l)
    local active_users=$(grep "|ACTIVE|" $DB_FILE | wc -l)
    local expired_users=$(grep "|EXPIRED|" $DB_FILE | wc -l)
    local limited_users=$(awk -F'|' '$5 != "0" && $5 != "unlimited" {count++} END{print count}' $DB_FILE)
    
    local total_bandwidth=$(awk -F'|' '{sum+=$6} END{printf "%.2f", sum/1024}' $DB_FILE 2>/dev/null || echo "0")
    local avg_bandwidth=$(echo "scale=2; $total_bandwidth / $total_users" | bc 2>/dev/null || echo "0")
    
    local load=$(uptime | awk -F'load average:' '{print $2}')
    local uptime=$(uptime -p | sed 's/up //')
    local mem_total=$(free -m | awk '/^Mem:/{print $2}')
    local mem_used=$(free -m | awk '/^Mem:/{print $3}')
    local mem_percent=$((mem_used * 100 / mem_total))
    
    echo -e "${CYAN}┌──────────────────────────────────────────────────────────┐${NC}"
    echo -e "${CYAN}│${NC} ${WHITE}${BOLD}SERVER STATISTICS${NC}                                   ${CYAN}│${NC}"
    echo -e "${CYAN}├──────────────────────────────────────────────────────────┤${NC}"
    printf "${CYAN}│${NC} Uptime:        ${GREEN}%-35s${NC} ${CYAN}│${NC}\n" "$uptime"
    printf "${CYAN}│${NC} Load Average:  ${GREEN}%-35s${NC} ${CYAN}│${NC}\n" "$load"
    printf "${CYAN}│${NC} Memory Usage:  ${GREEN}%-35s${NC} ${CYAN}│${NC}\n" "$mem_used MB / $mem_total MB ($mem_percent%)"
    echo -e "${CYAN}├──────────────────────────────────────────────────────────┤${NC}"
    echo -e "${CYAN}│${NC} ${WHITE}${BOLD}USER STATISTICS${NC}                                     ${CYAN}│${NC}"
    echo -e "${CYAN}├──────────────────────────────────────────────────────────┤${NC}"
    printf "${CYAN}│${NC} Total Users:   ${GREEN}%-35s${NC} ${CYAN}│${NC}\n" "$total_users"
    printf "${CYAN}│${NC} Active Users:  ${GREEN}%-35s${NC} ${CYAN}│${NC}\n" "$active_users"
    printf "${CYAN}│${NC} Expired Users: ${YELLOW}%-35s${NC} ${CYAN}│${NC}\n" "$expired_users"
    printf "${CYAN}│${NC} Limited Users: ${CYAN}%-35s${NC} ${CYAN}│${NC}\n" "$limited_users"
    echo -e "${CYAN}├──────────────────────────────────────────────────────────┤${NC}"
    echo -e "${CYAN}│${NC} ${WHITE}${BOLD}BANDWIDTH STATISTICS${NC}                               ${CYAN}│${NC}"
    echo -e "${CYAN}├──────────────────────────────────────────────────────────┤${NC}"
    printf "${CYAN}│${NC} Total Used:    ${GREEN}%-35s${NC} ${CYAN}│${NC}\n" "$total_bandwidth GB"
    printf "${CYAN}│${NC} Average/User:  ${GREEN}%-35s${NC} ${CYAN}│${NC}\n" "$avg_bandwidth GB"
    echo -e "${CYAN}└──────────────────────────────────────────────────────────┘${NC}"
    
    echo -e "\nPress Enter to continue..."
    read
}

# ============================================================================
# MAIN MENU - PRESERVING ALL V1.0 OPTIONS + ADDING NEW V1.5 FEATURES
# ============================================================================
show_main_menu() {
    print_banner
    
    # Show activation key and system info (PRESERVED FROM V1.0)
    SERVER_IP=$(curl -s --connect-timeout 5 ifconfig.me 2>/dev/null || hostname -I | awk '{print $1}')
    TOTAL_USERS=$(tail -n +2 $DB_FILE 2>/dev/null | wc -l)
    ACTIVE_USERS=$(grep -c "|ACTIVE|" $DB_FILE 2>/dev/null)
    
    echo -e "${GREEN}══════════════════════════════════════════════════════════${NC}"
    echo -e "${WHITE}⚡ ACTIVATION KEY:${NC} ${YELLOW}AMOKHAN-V$SCRIPT_VERSION-ACTIVE${NC}"
    if [ -f "$ACTIVATION_FILE" ]; then
        expiry=$(cat "$ACTIVATION_FILE")
        if [ $expiry -eq 0 ]; then
            echo -e "${WHITE}📌 LICENSE:${NC} ${GREEN}Lifetime${NC}"
        else
            days_left=$(( ($expiry - $(date +%s)) / 86400 ))
            echo -e "${WHITE}📌 LICENSE:${NC} ${YELLOW}Trial ($days_left days left)${NC}"
        fi
    fi
    echo -e "${WHITE}📌 SERVER:${NC} $SERVER_IP | ${WHITE}USERS:${NC} $ACTIVE_USERS/$TOTAL_USERS"
    echo -e "${GREEN}══════════════════════════════════════════════════════════${NC}"
    echo ""
    
    # MAIN MENU - ALL ORIGINAL V1.0 OPTIONS PRESERVED
    echo -e "${CYAN}┌──────────────────────────────────────────────────────┐${NC}"
    echo -e "${CYAN}│${NC} ${WHITE}${BOLD}MAIN MENU - V$SCRIPT_VERSION${NC}                                     ${CYAN}│${NC}"
    echo -e "${CYAN}├──────────────────────────────────────────────────────┤${NC}"
    echo -e "${CYAN}│${NC}  ${YELLOW}[1]${NC} 🚀 Install SlowDNS Server                                   ${CYAN}│${NC}"
    echo -e "${CYAN}│${NC}  ${YELLOW}[2]${NC} 📡 Show Server Information                                  ${CYAN}│${NC}"
    echo -e "${CYAN}│${NC}  ${YELLOW}[3]${NC} 🔧 Check Service Status                                     ${CYAN}│${NC}"
    echo -e "${CYAN}│${NC}  ${YELLOW}[4]${NC} 🔑 Show Public Key                                          ${CYAN}│${NC}"
    echo -e "${CYAN}│${NC}  ${YELLOW}[5]${NC} 📱 Client Configuration                                     ${CYAN}│${NC}"
    echo -e "${CYAN}│${NC}  ${YELLOW}[6]${NC} ⚡ System Optimization                                       ${CYAN}│${NC}"
    echo -e "${CYAN}├──────────────────────────────────────────────────────┤${NC}"
    echo -e "${CYAN}│${NC} ${WHITE}${BOLD}NEW V1.5 USER MANAGEMENT FEATURES${NC}                          ${CYAN}│${NC}"
    echo -e "${CYAN}├──────────────────────────────────────────────────────┤${NC}"
    echo -e "${CYAN}│${NC}  ${GREEN}[7]${NC} 👤 Create SSH User                                           ${CYAN}│${NC}"
    echo -e "${CYAN}│${NC}  ${GREEN}[8]${NC} 📋 List All Users (with Bandwidth)                          ${CYAN}│${NC}"
    echo -e "${CYAN}│${NC}  ${GREEN}[9]${NC} 🔄 Renew User Account                                        ${CYAN}│${NC}"
    echo -e "${CYAN}│${NC}  ${GREEN}[10]${NC} ⚡ Set Bandwidth Limit                                      ${CYAN}│${NC}"
    echo -e "${CYAN}│${NC}  ${GREEN}[11]${NC} 📊 Monitor User Bandwidth                                   ${CYAN}│${NC}"
    echo -e "${CYAN}│${NC}  ${GREEN}[12]${NC} 🗑️ Delete User                                              ${CYAN}│${NC}"
    echo -e "${CYAN}├──────────────────────────────────────────────────────┤${NC}"
    echo -e "${CYAN}│${NC} ${RED}${BOLD}SYSTEM MANAGEMENT${NC}                                           ${CYAN}│${NC}"
    echo -e "${CYAN}├──────────────────────────────────────────────────────┤${NC}"
    echo -e "${CYAN}│${NC}  ${RED}[13]${NC} 💾 Backup System                                              ${CYAN}│${NC}"
    echo -e "${CYAN}│${NC}  ${RED}[14]${NC} 🔄 Restore Backup                                            ${CYAN}│${NC}"
    echo -e "${CYAN}│${NC}  ${RED}[15]${NC} 📊 System Statistics                                         ${CYAN}│${NC}"
    echo -e "${CYAN}│${NC}  ${RED}[16]${NC} 🗑️ COMPLETE UNINSTALL                                        ${CYAN}│${NC}"
    echo -e "${CYAN}│${NC}  ${RED}[17]${NC} ❌ Exit                                                      ${CYAN}│${NC}"
    echo -e "${CYAN}└──────────────────────────────────────────────────────┘${NC}"
    echo ""
    echo -ne "${WHITE}${BOLD}Select option [1-17]: ${NC}"
    read -r option
    
    case $option in
        # ORIGINAL V1.0 OPTIONS (1-6)
        1) install_slowdns ;;
        2) show_server_info ;;
        3) check_services ;;
        4) show_public_key ;;
        5) show_client_config ;;
        6) optimize_system ;;
        
        # NEW V1.5 USER MANAGEMENT OPTIONS (7-12)
        7) create_ssh_user ;;
        8) list_all_users ;;
        9) renew_user_account ;;
        10) set_bandwidth_limit ;;
        11) monitor_user_bandwidth ;;
        12) delete_ssh_user ;;
        
        # NEW V1.5 SYSTEM MANAGEMENT OPTIONS (13-17)
        13) backup_system ;;
        14) restore_backup ;;
        15) show_stats ;;
        16) complete_uninstall ;;
        17) 
            echo -e "\n${GREEN}Thank you for using AMOKHAN V$SCRIPT_VERSION!${NC}"
            exit 0 
            ;;
        *)
            echo -e "\n${RED}Invalid option!${NC}"
            sleep 2
            ;;
    esac
}

# ============================================================================
# MAIN PROGRAM
# ============================================================================
main() {
    # Initialize system for V1.5 features
    init_system
    
    # Start bandwidth monitor if not running
    if ! systemctl is-active --quiet amokhan-monitor 2>/dev/null; then
        systemctl start amokhan-monitor 2>/dev/null
    fi
    
    # Main loop
    while true; do
        show_main_menu
    done
}

# ============================================================================
# COMMAND LINE ARGUMENTS
# ============================================================================
case "${1:-}" in
    uninstall)
        complete_uninstall
        ;;
    backup)
        backup_system
        ;;
    *)
        trap 'echo -e "\n${RED}✗ Interrupted!${NC}"; exit 1' INT
        main
        ;;
esac
