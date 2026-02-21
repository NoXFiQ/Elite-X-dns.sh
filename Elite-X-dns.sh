#!/bin/bash

# ============================================================================
#                     SLOWDNS MODERN INSTALLATION SCRIPT
#                         AMOKHAN V1.5
# ============================================================================

# Ensure running as root
if [ "$EUID" -ne 0 ]; then
    echo -e "\033[0;31m[✗]\033[0m Please run this script as root"
    exit 1
fi

# ============================================================================
# CONFIGURATION
# ============================================================================
SSHD_PORT=22
SLOWDNS_PORT=5300
GITHUB_BASE="https://raw.githubusercontent.com/iddie15/SLOW-DNS-SCRIPT/main/DNSTT%20MODED"
SSH_ACCOUNTS_DIR="/etc/ssh/accounts"
ACCOUNTS_DB="/etc/ssh/accounts.db"
TRAFFIC_DB="/etc/ssh/traffic.db"

# ============================================================================
# MODERN COLORS & DESIGN
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
# ANIMATION FUNCTIONS
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
    echo -e "${BLUE}║${NC}${CYAN}          🚀 MODERN SLOWDNS INSTALLATION SCRIPT${NC}          ${BLUE}║${NC}"
    echo -e "${BLUE}║${NC}${WHITE}            Fast & Professional Configuration${NC}            ${BLUE}║${NC}"
    echo -e "${BLUE}║${NC}${YELLOW}                AMOKHAN V1.5 - Enhanced${NC}                 ${BLUE}║${NC}"
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
# TRAFFIC MONITORING FUNCTIONS (NEW FEATURE)
# ============================================================================

# Initialize traffic database
init_traffic_db() {
    mkdir -p /etc/ssh/accounts
    touch $TRAFFIC_DB
    chmod 600 $TRAFFIC_DB
}

# Convert bytes to human readable
format_bytes() {
    local bytes=$1
    if [ $bytes -lt 1024 ]; then
        echo "${bytes}B"
    elif [ $bytes -lt 1048576 ]; then
        echo "$((bytes / 1024))KB"
    elif [ $bytes -lt 1073741824 ]; then
        echo "$((bytes / 1048576))MB"
    else
        echo "$((bytes / 1073741824))GB"
    fi
}

# Update user traffic
update_user_traffic() {
    local username=$1
    local bytes_added=$2
    
    if [ -f "$TRAFFIC_DB" ]; then
        # Check if user exists in traffic DB
        if grep -q "^$username:" "$TRAFFIC_DB"; then
            # Update existing record
            local current=$(grep "^$username:" "$TRAFFIC_DB" | cut -d: -f2)
            local new=$((current + bytes_added))
            sed -i "s/^$username:.*/$username:$new/" "$TRAFFIC_DB"
        else
            # Add new record
            echo "$username:$bytes_added" >> "$TRAFFIC_DB"
        fi
    fi
}

# Get user traffic
get_user_traffic() {
    local username=$1
    if [ -f "$TRAFFIC_DB" ] && grep -q "^$username:" "$TRAFFIC_DB"; then
        grep "^$username:" "$TRAFFIC_DB" | cut -d: -f2
    else
        echo "0"
    fi
}

# Reset user traffic
reset_user_traffic() {
    local username=$1
    if [ -f "$TRAFFIC_DB" ]; then
        sed -i "/^$username:/d" "$TRAFFIC_DB"
    fi
}

# ============================================================================
# SSH ACCOUNT MANAGEMENT FUNCTIONS (NEW FEATURE)
# ============================================================================

# Initialize accounts database
init_accounts_db() {
    mkdir -p $SSH_ACCOUNTS_DIR
    touch $ACCOUNTS_DB
    chmod 600 $ACCOUNTS_DB
}

# Create SSH account
create_ssh_account() {
    local username=$1
    local password=$2
    local expire_days=$3
    local max_mb=$4
    
    # Check if user exists
    if id "$username" &>/dev/null; then
        print_error "User $username already exists"
        return 1
    fi
    
    # Create user
    useradd -m -s /bin/bash "$username"
    echo "$username:$password" | chpasswd
    
    # Set expiration
    if [ -n "$expire_days" ] && [ "$expire_days" -gt 0 ]; then
        chage -M "$expire_days" "$username"
        expire_date=$(date -d "+$expire_days days" +%Y-%m-%d)
    else
        expire_date="Never"
    fi
    
    # Save to database
    echo "$username:$password:$expire_date:$(date +%Y-%m-%d):$max_mb:0" >> $ACCOUNTS_DB
    
    print_success "Account created: $username"
    return 0
}

# List SSH accounts with traffic info (NEW FEATURE - ENHANCED)
list_ssh_accounts() {
    print_header "📊 SSH ACCOUNTS WITH TRAFFIC USAGE"
    
    if [ ! -f "$ACCOUNTS_DB" ] || [ ! -s "$ACCOUNTS_DB" ]; then
        print_warning "No accounts found"
        return
    fi
    
    echo -e "${CYAN}┌─────────────────────────────────────────────────────────────────────────────┐${NC}"
    echo -e "${CYAN}│${NC} ${WHITE}USERNAME     EXPIRE DATE   MAX MB    USED MB    STATUS      TRAFFIC${NC}   ${CYAN}│${NC}"
    echo -e "${CYAN}├─────────────────────────────────────────────────────────────────────────────┤${NC}"
    
    while IFS=: read -r username password expire_date created_date max_mb dummy; do
        # Get current traffic
        local used_bytes=$(get_user_traffic "$username")
        local used_mb=$((used_bytes / 1048576))
        local max_bytes=$((max_mb * 1048576))
        
        # Calculate status
        local status="${GREEN}Active${NC}"
        local traffic_status=""
        
        # Check expiration
        if [ "$expire_date" != "Never" ]; then
            if [[ "$expire_date" < $(date +%Y-%m-%d) ]]; then
                status="${RED}Expired${NC}"
            fi
        fi
        
        # Check traffic limit
        if [ "$max_mb" -gt 0 ]; then
            if [ "$used_mb" -ge "$max_mb" ]; then
                traffic_status="${RED}Limit Reached${NC}"
            else
                local percent=$((used_mb * 100 / max_mb))
                if [ "$percent" -gt 90 ]; then
                    traffic_status="${YELLOW}${percent}% used${NC}"
                elif [ "$percent" -gt 50 ]; then
                    traffic_status="${CYAN}${percent}% used${NC}"
                else
                    traffic_status="${GREEN}${percent}% used${NC}"
                fi
            fi
        else
            traffic_status="${WHITE}Unlimited${NC}"
        fi
        
        # Format max limit display
        if [ "$max_mb" -gt 0 ]; then
            max_display="${max_mb}MB"
        else
            max_display="Unlimited"
        fi
        
        printf "${CYAN}│${NC} ${WHITE}%-12s${NC} ${WHITE}%-12s${NC} ${WHITE}%-9s${NC} ${WHITE}%-9s${NC}  %-12s ${WHITE}%s${NC}  ${CYAN}│${NC}\n" \
            "$username" "$expire_date" "$max_display" "${used_mb}MB" "$status" "$traffic_status"
        
    done < "$ACCOUNTS_DB"
    
    echo -e "${CYAN}└─────────────────────────────────────────────────────────────────────────────┘${NC}"
    
    # Show top traffic users
    print_header "📈 TOP TRAFFIC USERS"
    echo -e "${CYAN}┌────────────────────────────────────┐${NC}"
    echo -e "${CYAN}│${NC} ${WHITE}USERNAME      USED MB    % OF LIMIT${NC}   ${CYAN}│${NC}"
    echo -e "${CYAN}├────────────────────────────────────┤${NC}"
    
    # Sort and display top users
    if [ -f "$TRAFFIC_DB" ] && [ -s "$TRAFFIC_DB" ]; then
        sort -t: -k2 -rn "$TRAFFIC_DB" | head -5 | while IFS=: read -r username bytes; do
            local used_mb=$((bytes / 1048576))
            local limit=0
            local percent="N/A"
            
            # Get user limit from accounts DB
            if grep -q "^$username:" "$ACCOUNTS_DB"; then
                limit=$(grep "^$username:" "$ACCOUNTS_DB" | cut -d: -f5)
                if [ "$limit" -gt 0 ]; then
                    percent="$((used_mb * 100 / limit))%"
                else
                    percent="Unlimited"
                fi
            fi
            
            printf "${CYAN}│${NC} ${WHITE}%-12s${NC} ${WHITE}%-9s${NC} ${WHITE}%-12s${NC} ${CYAN}│${NC}\n" \
                "$username" "${used_mb}MB" "$percent"
        done
    else
        printf "${CYAN}│${NC} ${YELLOW}No traffic data available${NC}               ${CYAN}│${NC}\n"
    fi
    
    echo -e "${CYAN}└────────────────────────────────────┘${NC}"
}

# Renew user account (NEW FEATURE)
renew_user_account() {
    print_header "🔄 RENEW SSH ACCOUNT"
    
    if [ ! -f "$ACCOUNTS_DB" ] || [ ! -s "$ACCOUNTS_DB" ]; then
        print_warning "No accounts found to renew"
        return
    fi
    
    # List available accounts
    echo -e "${CYAN}Available accounts:${NC}"
    local i=1
    declare -a usernames
    
    while IFS=: read -r username password expire_date created_date max_mb dummy; do
        echo -e "  ${WHITE}$i.${NC} $username (Expires: $expire_date)"
        usernames[$i]=$username
        ((i++))
    done < "$ACCOUNTS_DB"
    
    echo ""
    read -p "$(echo -e "${WHITE}${BOLD}Select account number to renew: ${NC}")" choice
    
    if [[ ! "$choice" =~ ^[0-9]+$ ]] || [ "$choice" -lt 1 ] || [ "$choice" -ge "$i" ]; then
        print_error "Invalid selection"
        return
    fi
    
    local username=${usernames[$choice]}
    
    # Get current user data
    local user_line=$(grep "^$username:" "$ACCOUNTS_DB")
    if [ -z "$user_line" ]; then
        print_error "User not found"
        return
    fi
    
    local password=$(echo "$user_line" | cut -d: -f2)
    local old_expire=$(echo "$user_line" | cut -d: -f3)
    local created=$(echo "$user_line" | cut -d: -f4)
    local max_mb=$(echo "$user_line" | cut -d: -f5)
    
    echo -e "\n${CYAN}Renewing account:${NC} $username"
    echo -e "${CYAN}Current expiry:${NC} $old_expire"
    
    # Get new expiry
    read -p "$(echo -e "${WHITE}${BOLD}Add days (30): ${NC}")" days
    days=${days:-30}
    
    if [[ ! "$days" =~ ^[0-9]+$ ]] || [ "$days" -lt 1 ]; then
        print_error "Invalid days"
        return
    fi
    
    # Update system expiry
    chage -M "$days" "$username"
    local new_expire=$(date -d "+$days days" +%Y-%m-%d)
    
    # Update database
    sed -i "s/^$username:.*/$username:$password:$new_expire:$created:$max_mb:0/" "$ACCOUNTS_DB"
    
    # Reset traffic if requested
    echo -e "\n${YELLOW}Reset traffic usage for this user?${NC}"
    read -p "$(echo -e "${WHITE}Reset traffic? [y/N]: ${NC}")" reset_traffic
    if [[ "$reset_traffic" =~ ^[Yy]$ ]]; then
        reset_user_traffic "$username"
        print_success "Traffic usage reset"
    fi
    
    print_success "Account renewed until: $new_expire"
}

# Delete SSH account
delete_ssh_account() {
    local username=$1
    
    # Kill user processes
    pkill -u "$username" 2>/dev/null
    
    # Delete user
    userdel -r "$username" 2>/dev/null
    
    # Remove from databases
    sed -i "/^$username:/d" "$ACCOUNTS_DB" 2>/dev/null
    sed -i "/^$username:/d" "$TRAFFIC_DB" 2>/dev/null
    
    print_success "Account deleted: $username"
}

# ============================================================================
# UNINSTALLATION FUNCTION (NEW FEATURE)
# ============================================================================
uninstall_slowdns() {
    print_header "🗑️ UNINSTALLING SLOWDNS AND ALL COMPONENTS"
    
    echo -e "${RED}${BOLD}WARNING: This will remove ALL installed components and user accounts!${NC}"
    echo -e "${YELLOW}The following will be removed:${NC}"
    echo -e "  ${WHITE}•${NC} SlowDNS server and configuration"
    echo -e "  ${WHITE}•${NC} EDNS Proxy"
    echo -e "  ${WHITE}•${NC} All SSH user accounts created by this script"
    echo -e "  ${WHITE}•${NC} Service files and configurations"
    echo -e "  ${WHITE}•${NC} Firewall rules"
    echo ""
    
    read -p "$(echo -e "${RED}${BOLD}Are you sure? (type YES to confirm): ${NC}")" confirm
    
    if [ "$confirm" != "YES" ]; then
        print_warning "Uninstallation cancelled"
        return
    fi
    
    print_step "1"
    print_info "Stopping all services"
    
    systemctl stop server-sldns 2>/dev/null
    systemctl stop edns-proxy 2>/dev/null
    systemctl disable server-sldns 2>/dev/null
    systemctl disable edns-proxy 2>/dev/null
    
    pkill -f dnstt-server 2>/dev/null
    pkill -f edns-proxy 2>/dev/null
    fuser -k 53/udp 2>/dev/null
    fuser -k 5300/udp 2>/dev/null
    
    print_success "Services stopped"
    
    print_step "2"
    print_info "Removing all SSH user accounts"
    
    if [ -f "$ACCOUNTS_DB" ]; then
        while IFS=: read -r username password expire_date created_date max_mb dummy; do
            echo -ne "  ${CYAN}Removing $username...${NC}"
            userdel -r "$username" 2>/dev/null
            echo -e "\r  ${GREEN}Removed $username${NC}"
        done < "$ACCOUNTS_DB"
    fi
    
    # Remove any remaining users created by script pattern
    for user in $(awk -F: '{if($3>=1000&&$3<60000)print $1}' /etc/passwd); do
        if grep -q "^$user:" "$ACCOUNTS_DB" 2>/dev/null; then
            userdel -r "$user" 2>/dev/null
        fi
    done
    
    print_success "All user accounts removed"
    
    print_step "3"
    print_info "Removing SlowDNS and EDNS components"
    
    rm -rf /etc/slowdns
    rm -f /usr/local/bin/edns-proxy
    rm -f /etc/systemd/system/server-sldns.service
    rm -f /etc/systemd/system/edns-proxy.service
    rm -rf $SSH_ACCOUNTS_DIR
    rm -f $ACCOUNTS_DB
    rm -f $TRAFFIC_DB
    
    print_success "Components removed"
    
    print_step "4"
    print_info "Restoring SSH configuration"
    
    if [ -f /etc/ssh/sshd_config.backup ]; then
        cp /etc/ssh/sshd_config.backup /etc/ssh/sshd_config
        systemctl restart sshd
        print_success "SSH configuration restored"
    fi
    
    print_step "5"
    print_info "Clearing firewall rules"
    
    iptables -F
    iptables -X
    iptables -t nat -F
    iptables -t nat -X
    iptables -P INPUT ACCEPT
    iptables -P FORWARD ACCEPT
    iptables -P OUTPUT ACCEPT
    
    print_success "Firewall rules cleared"
    
    print_step "6"
    print_info "System cleanup"
    
    systemctl daemon-reload
    
    # Re-enable systemd-resolved if it was disabled
    if systemctl is-enabled systemd-resolved 2>/dev/null | grep -q "disabled"; then
        systemctl enable systemd-resolved 2>/dev/null
        systemctl start systemd-resolved 2>/dev/null
    fi
    
    print_success "System cleanup completed"
    
    # Final message
    echo -e "\n${GREEN}${BOLD}══════════════════════════════════════════════════════════${NC}"
    echo -e "${GREEN}${BOLD}   ✓ SLOWDNS COMPLETELY UNINSTALLED${NC}"
    echo -e "${GREEN}${BOLD}   ✓ All components and user accounts removed${NC}"
    echo -e "${GREEN}${BOLD}   ✓ System restored to original state${NC}"
    echo -e "${GREEN}${BOLD}══════════════════════════════════════════════════════════${NC}"
    
    echo -e "\n${YELLOW}Press Enter to continue...${NC}"
    read
}

# ============================================================================
# ACCOUNT MANAGEMENT MENU (NEW FEATURE)
# ============================================================================
account_management_menu() {
    while true; do
        clear
        print_banner
        
        echo -e "${CYAN}┌──────────────────────────────────────────────────────────┐${NC}"
        echo -e "${CYAN}│${NC} ${WHITE}${BOLD}SSH ACCOUNT MANAGEMENT${NC}                              ${CYAN}│${NC}"
        echo -e "${CYAN}├──────────────────────────────────────────────────────────┤${NC}"
        echo -e "${CYAN}│${NC} ${YELLOW}1.${NC} ${WHITE}Create SSH Account${NC}                             ${CYAN}│${NC}"
        echo -e "${CYAN}│${NC} ${YELLOW}2.${NC} ${WHITE}List SSH Accounts (with traffic)${NC}                ${CYAN}│${NC}"
        echo -e "${CYAN}│${NC} ${YELLOW}3.${NC} ${WHITE}Delete SSH Account${NC}                             ${CYAN}│${NC}"
        echo -e "${CYAN}│${NC} ${YELLOW}4.${NC} ${WHITE}Renew SSH Account${NC}                              ${CYAN}│${NC}"
        echo -e "${CYAN}│${NC} ${YELLOW}5.${NC} ${WHITE}View Traffic Usage${NC}                             ${CYAN}│${NC}"
        echo -e "${CYAN}│${NC} ${YELLOW}6.${NC} ${WHITE}Reset User Traffic${NC}                             ${CYAN}│${NC}"
        echo -e "${CYAN}│${NC} ${YELLOW}7.${NC} ${WHITE}Back to Main Menu${NC}                              ${CYAN}│${NC}"
        echo -e "${CYAN}└──────────────────────────────────────────────────────────┘${NC}"
        
        echo ""
        read -p "$(echo -e "${WHITE}${BOLD}Select option [1-7]: ${NC}")" account_option
        
        case $account_option in
            1)
                print_header "👤 CREATE SSH ACCOUNT"
                
                read -p "$(echo -e "${WHITE}Username: ${NC}")" username
                if id "$username" &>/dev/null; then
                    print_error "User already exists"
                    sleep 2
                    continue
                fi
                
                read -s -p "$(echo -e "${WHITE}Password: ${NC}")" password
                echo ""
                read -s -p "$(echo -e "${WHITE}Confirm Password: ${NC}")" password2
                echo ""
                
                if [ "$password" != "$password2" ]; then
                    print_error "Passwords don't match"
                    sleep 2
                    continue
                fi
                
                read -p "$(echo -e "${WHITE}Expire days (0 = never): ${NC}")" expire_days
                expire_days=${expire_days:-0}
                
                read -p "$(echo -e "${WHITE}Max traffic (MB, 0 = unlimited): ${NC}")" max_mb
                max_mb=${max_mb:-0}
                
                create_ssh_account "$username" "$password" "$expire_days" "$max_mb"
                echo ""
                read -p "Press Enter to continue..."
                ;;
            2)
                list_ssh_accounts
                echo ""
                read -p "Press Enter to continue..."
                ;;
            3)
                print_header "🗑️ DELETE SSH ACCOUNT"
                
                if [ ! -f "$ACCOUNTS_DB" ] || [ ! -s "$ACCOUNTS_DB" ]; then
                    print_warning "No accounts found"
                    sleep 2
                    continue
                fi
                
                echo -e "${CYAN}Available accounts:${NC}"
                local i=1
                declare -a usernames
                
                while IFS=: read -r username password expire_date created_date max_mb dummy; do
                    echo -e "  ${WHITE}$i.${NC} $username"
                    usernames[$i]=$username
                    ((i++))
                done < "$ACCOUNTS_DB"
                
                echo ""
                read -p "$(echo -e "${WHITE}Select account number to delete: ${NC}")" choice
                
                if [[ ! "$choice" =~ ^[0-9]+$ ]] || [ "$choice" -lt 1 ] || [ "$choice" -ge "$i" ]; then
                    print_error "Invalid selection"
                    sleep 2
                    continue
                fi
                
                delete_ssh_account "${usernames[$choice]}"
                echo ""
                read -p "Press Enter to continue..."
                ;;
            4)
                renew_user_account
                echo ""
                read -p "Press Enter to continue..."
                ;;
            5)
                print_header "📊 TRAFFIC USAGE DETAILS"
                
                if [ -f "$TRAFFIC_DB" ] && [ -s "$TRAFFIC_DB" ]; then
                    echo -e "${CYAN}┌────────────────────────────────────────┐${NC}"
                    echo -e "${CYAN}│${NC} ${WHITE}USERNAME      TOTAL USED    %${NC}         ${CYAN}│${NC}"
                    echo -e "${CYAN}├────────────────────────────────────────┤${NC}"
                    
                    sort -t: -k2 -rn "$TRAFFIC_DB" | while IFS=: read -r username bytes; do
                        local used_mb=$((bytes / 1048576))
                        local used_gb=$((bytes / 1073741824))
                        local limit=0
                        
                        if grep -q "^$username:" "$ACCOUNTS_DB"; then
                            limit=$(grep "^$username:" "$ACCOUNTS_DB" | cut -d: -f5)
                        fi
                        
                        if [ "$bytes" -gt 1073741824 ]; then
                            display="${used_gb}GB"
                        else
                            display="${used_mb}MB"
                        fi
                        
                        if [ "$limit" -gt 0 ]; then
                            percent="$((used_mb * 100 / limit))%"
                        else
                            percent="Unlimited"
                        fi
                        
                        printf "${CYAN}│${NC} ${WHITE}%-12s${NC} ${WHITE}%-12s${NC} ${WHITE}%-8s${NC} ${CYAN}│${NC}\n" \
                            "$username" "$display" "$percent"
                    done
                    
                    echo -e "${CYAN}└────────────────────────────────────────┘${NC}"
                else
                    print_warning "No traffic data available"
                fi
                
                echo ""
                read -p "Press Enter to continue..."
                ;;
            6)
                print_header "🔄 RESET USER TRAFFIC"
                
                if [ ! -f "$TRAFFIC_DB" ] || [ ! -s "$TRAFFIC_DB" ]; then
                    print_warning "No traffic data available"
                    sleep 2
                    continue
                fi
                
                echo -e "${CYAN}Users with traffic data:${NC}"
                local i=1
                declare -a traffic_users
                
                while IFS=: read -r username bytes; do
                    local used_mb=$((bytes / 1048576))
                    echo -e "  ${WHITE}$i.${NC} $username (${used_mb}MB)"
                    traffic_users[$i]=$username
                    ((i++))
                done < "$TRAFFIC_DB"
                
                echo ""
                read -p "$(echo -e "${WHITE}Select user number to reset: ${NC}")" choice
                
                if [[ ! "$choice" =~ ^[0-9]+$ ]] || [ "$choice" -lt 1 ] || [ "$choice" -ge "$i" ]; then
                    print_error "Invalid selection"
                    sleep 2
                    continue
                fi
                
                reset_user_traffic "${traffic_users[$choice]}"
                print_success "Traffic reset for ${traffic_users[$choice]}"
                echo ""
                read -p "Press Enter to continue..."
                ;;
            7)
                break
                ;;
            *)
                print_error "Invalid option"
                sleep 2
                ;;
        esac
    done
}

# ============================================================================
# MAIN INSTALLATION (MODIFIED TO INCLUDE NEW FEATURES)
# ============================================================================
main() {
    print_banner
    
    # Initialize databases
    init_accounts_db
    init_traffic_db
    
    # Check if already installed
    if [ -f "/etc/systemd/system/server-sldns.service" ]; then
        echo -e "${YELLOW}${BOLD}SlowDNS appears to be already installed.${NC}"
        echo -e "${CYAN}What would you like to do?${NC}"
        echo -e "  ${WHITE}1.${NC} Reinstall/Update"
        echo -e "  ${WHITE}2.${NC} Manage SSH Accounts"
        echo -e "  ${WHITE}3.${NC} Uninstall SlowDNS"
        echo -e "  ${WHITE}4.${NC} Exit"
        echo ""
        read -p "$(echo -e "${WHITE}${BOLD}Select option [1-4]: ${NC}")" existing_option
        
        case $existing_option in
            1)
                print_warning "Proceeding with reinstallation..."
                ;;
            2)
                account_management_menu
                return
                ;;
            3)
                uninstall_slowdns
                return
                ;;
            4)
                exit 0
                ;;
            *)
                print_error "Invalid option"
                exit 1
                ;;
        esac
    fi
    
    # Get nameserver with modern prompt
    echo -e "${WHITE}${BOLD}Enter nameserver configuration:${NC}"
    echo -e "${CYAN}┌──────────────────────────────────────────────────────────┐${NC}"
    echo -e "${CYAN}│${NC} ${YELLOW}Default:${NC} dns.example.com                                     ${CYAN}│${NC}"
    echo -e "${CYAN}│${NC} ${YELLOW}Example:${NC} tunnel.yourdomain.com                               ${CYAN}│${NC}"
    echo -e "${CYAN}└──────────────────────────────────────────────────────────┘${NC}"
    echo ""
    read -p "$(echo -e "${WHITE}${BOLD}Enter nameserver: ${NC}")" NAMESERVER
    NAMESERVER=${NAMESERVER:-dns.example.com}
    
    print_header "📦 GATHERING SYSTEM INFORMATION"
    
    # Get Server IP with animation
    echo -ne "  ${CYAN}Detecting server IP address...${NC}"
    SERVER_IP=$(curl -s --connect-timeout 5 ifconfig.me)
    if [ -z "$SERVER_IP" ]; then
        SERVER_IP=$(hostname -I | awk '{print $1}')
    fi
    echo -e "\r  ${GREEN}Server IP:${NC} ${WHITE}${BOLD}$SERVER_IP${NC}"
    
    # ============================================================================
    # STEP 1: CONFIGURE OPENSSH
    # ============================================================================
    print_step "1"
    print_info "Configuring OpenSSH on port $SSHD_PORT"
    
    echo -ne "  ${CYAN}Backing up SSH configuration...${NC}"
    cp /etc/ssh/sshd_config /etc/ssh/sshd_config.backup 2>/dev/null &
    show_progress $!
    echo -e "\r  ${GREEN}SSH configuration backed up${NC}"
    
    cat > /etc/ssh/sshd_config << EOF
# ============================================================================
# SLOWDNS OPTIMIZED SSH CONFIGURATION
# ============================================================================
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
    
    # ============================================================================
    # STEP 2: SETUP SLOWDNS
    # ============================================================================
    print_step "2"
    print_info "Setting up SlowDNS environment"
    
    echo -ne "  ${CYAN}Creating SlowDNS directory...${NC}"
    rm -rf /etc/slowdns 2>/dev/null
    mkdir -p /etc/slowdns 2>/dev/null &
    show_progress $!
    cd /etc/slowdns
    echo -e "\r  ${GREEN}SlowDNS directory created${NC}"
    
    # Download binary
    print_info "Downloading SlowDNS binary"
    echo -ne "  ${CYAN}Fetching binary from GitHub...${NC}"
    
    # Try multiple download methods
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
    
    # Download key files
    print_info "Downloading encryption keys"
    echo -ne "  ${CYAN}Downloading server.key...${NC}"
    wget -q "$GITHUB_BASE/server.key" -O server.key 2>/dev/null &
    show_progress $!
    echo -e "\r  ${GREEN}server.key downloaded${NC}"
    
    echo -ne "  ${CYAN}Downloading server.pub...${NC}"
    wget -q "$GITHUB_BASE/server.pub" -O server.pub 2>/dev/null &
    show_progress $!
    echo -e "\r  ${GREEN}server.pub downloaded${NC}"
    
    # Test binary
    echo -ne "  ${CYAN}Validating binary...${NC}"
    if ./dnstt-server --help 2>&1 | grep -q "usage" || ./dnstt-server -h 2>&1 | head -5; then
        echo -e "\r  ${GREEN}Binary validated successfully${NC}"
    else
        echo -e "\r  ${YELLOW}Binary test inconclusive${NC}"
    fi
    
    print_success "SlowDNS components installed"
    print_step_end
    
    # ============================================================================
    # STEP 3: CREATE SLOWDNS SERVICE
    # ============================================================================
    print_step "3"
    print_info "Creating SlowDNS system service"
    
    cat > /etc/systemd/system/server-sldns.service << EOF
# ============================================================================
# SLOWDNS SERVICE CONFIGURATION
# ============================================================================
[Unit]
Description=SlowDNS Server
Description=High-performance DNS tunnel server
After=network.target sshd.service
Wants=network-online.target

[Service]
Type=simple
ExecStart=$SLOWDNS_BINARY -udp :$SLOWDNS_PORT -mtu 1500 -privkey-file /etc/slowdns/server.key $NAMESERVER 127.0.0.1:$SSHD_PORT
Restart=always
RestartSec=5
User=root
LimitNOFILE=65536
LimitCORE=infinity
TimeoutStartSec=0

[Install]
WantedBy=multi-user.target
EOF
    
    print_success "Service configuration created"
    print_step_end
    
    # ============================================================================
    # STEP 4: COMPILE EDNS PROXY
    # ============================================================================
    print_step "4"
    print_info "Compiling high-performance EDNS Proxy"
    
    # Check for gcc
    if ! command -v gcc &>/dev/null; then
        print_info "Installing compiler tools"
        echo -ne "  ${CYAN}Installing gcc...${NC}"
        apt update > /dev/null 2>&1 && apt install -y gcc > /dev/null 2>&1 &
        show_progress $!
        echo -e "\r  ${GREEN}Compiler installed${NC}"
    fi
    
    # Create optimized C code (same as before)
    cat > /tmp/edns.c << 'EOF'
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <unistd.h>
#include <fcntl.h>
#include <errno.h>
#include <signal.h>
#include <time.h>
#include <stdint.h>
#include <arpa/inet.h>
#include <sys/socket.h>
#include <sys/epoll.h>

#define LISTEN_PORT 53
#define SLOWDNS_PORT 5300
#define BUFFER_SIZE 4096
#define UPSTREAM_POOL 32
#define SOCKET_TIMEOUT 1.0
#define MAX_EVENTS 4096
#define REQ_TABLE_SIZE 65536
#define EXT_EDNS 512
#define INT_EDNS 1500

typedef struct {
    int fd;
    int busy;
    time_t last_used;
} upstream_t;

typedef struct req_entry {
    uint16_t req_id;
    int upstream_idx;
    double timestamp;
    struct sockaddr_in client_addr;
    socklen_t addr_len;
    struct req_entry *next;
} req_entry_t;

static upstream_t upstreams[UPSTREAM_POOL];
static req_entry_t *req_table[REQ_TABLE_SIZE];
static int sock, epoll_fd;
static volatile sig_atomic_t shutdown_flag = 0;

double now() {
    struct timespec ts;
    clock_gettime(CLOCK_MONOTONIC, &ts);
    return ts.tv_sec + ts.tv_nsec / 1e9;
}

uint16_t get_txid(unsigned char *b) {
    return ((uint16_t)b[0] << 8) | b[1];
}

uint32_t req_hash(uint16_t id) {
    return id & (REQ_TABLE_SIZE - 1);
}

int patch_edns(unsigned char *buf, int len, int size) {
    if (len < 12) return len;
    int off = 12;
    int qd = (buf[4] << 8) | buf[5];
    for (int i=0;i<qd;i++) {
        while (buf[off]) off++;
        off += 5;
    }
    int ar = (buf[10] << 8) | buf[11];
    for (int i=0;i<ar;i++) {
        if (buf[off]==0 && off+4<len && ((buf[off+1]<<8)|buf[off+2])==41) {
            buf[off+3]=size>>8;
            buf[off+4]=size&255;
            return len;
        }
        off++;
    }
    return len;
}

int get_upstream() {
    time_t t = time(NULL);
    for (int i=0;i<UPSTREAM_POOL;i++) {
        if (upstreams[i].busy && t - upstreams[i].last_used > 2)
            upstreams[i].busy = 0;
        if (!upstreams[i].busy) {
            upstreams[i].busy = 1;
            upstreams[i].last_used = t;
            return i;
        }
    }
    return -1;
}

void release_upstream(int i) {
    if (i>=0 && i<UPSTREAM_POOL) upstreams[i].busy = 0;
}

void insert_req(int uidx, unsigned char *buf, struct sockaddr_in *c, socklen_t l) {
    req_entry_t *e = calloc(1,sizeof(*e));
    e->upstream_idx = uidx;
    e->req_id = get_txid(buf);
    e->timestamp = now();
    e->client_addr = *c;
    e->addr_len = l;
    uint32_t h = req_hash(e->req_id);
    e->next = req_table[h];
    req_table[h] = e;
}

req_entry_t *find_req(uint16_t id) {
    uint32_t h = req_hash(id);
    for (req_entry_t *e=req_table[h]; e; e=e->next)
        if (e->req_id == id) return e;
    return NULL;
}

void delete_req(req_entry_t *e) {
    release_upstream(e->upstream_idx);
    uint32_t h = req_hash(e->req_id);
    req_entry_t **pp=&req_table[h];
    while(*pp){
        if(*pp==e){ *pp=e->next; free(e); return; }
        pp=&(*pp)->next;
    }
}

void cleanup_expired() {
    double t=now();
    for(int i=0;i<REQ_TABLE_SIZE;i++){
        req_entry_t **pp=&req_table[i];
        while(*pp){
            if(t-(*pp)->timestamp > SOCKET_TIMEOUT){
                req_entry_t *o=*pp;
                release_upstream(o->upstream_idx);
                *pp=o->next;
                free(o);
            } else pp=&(*pp)->next;
        }
    }
}

void sig_handler(int s){ shutdown_flag=1; }

int main() {
    signal(SIGINT,sig_handler);
    signal(SIGTERM,sig_handler);

    sock=socket(AF_INET,SOCK_DGRAM,0);
    fcntl(sock,F_SETFL,O_NONBLOCK);

    struct sockaddr_in a={0};
    a.sin_family=AF_INET; a.sin_port=htons(LISTEN_PORT);
    a.sin_addr.s_addr=INADDR_ANY;
    bind(sock,(void*)&a,sizeof(a));

    struct sockaddr_in slow={0};
    slow.sin_family=AF_INET; slow.sin_port=htons(SLOWDNS_PORT);
    inet_pton(AF_INET,"127.0.0.1",&slow.sin_addr);

    epoll_fd=epoll_create1(0);
    struct epoll_event ev={.events=EPOLLIN,.data.fd=sock};
    epoll_ctl(epoll_fd,EPOLL_CTL_ADD,sock,&ev);

    for(int i=0;i<UPSTREAM_POOL;i++){
        upstreams[i].fd=socket(AF_INET,SOCK_DGRAM,0);
        fcntl(upstreams[i].fd,F_SETFL,O_NONBLOCK);
        struct epoll_event ue={.events=EPOLLIN,.data.fd=upstreams[i].fd};
        epoll_ctl(epoll_fd,EPOLL_CTL_ADD,upstreams[i].fd,&ue);
    }

    struct epoll_event events[MAX_EVENTS];

    while(!shutdown_flag){
        cleanup_expired();
        int n=epoll_wait(epoll_fd,events,MAX_EVENTS,10);
        for(int i=0;i<n;i++){
            int fd=events[i].data.fd;
            if(fd==sock){
                unsigned char buf[BUFFER_SIZE];
                struct sockaddr_in c; socklen_t l=sizeof(c);
                int len=recvfrom(sock,buf,sizeof(buf),0,(void*)&c,&l);
                if(len>0){
                    patch_edns(buf,len,INT_EDNS);
                    int u=get_upstream();
                    if(u>=0){
                        insert_req(u,buf,&c,l);
                        sendto(upstreams[u].fd,buf,len,0,(void*)&slow,sizeof(slow));
                    }
                }
            } else {
                unsigned char buf[BUFFER_SIZE];
                int len=recv(fd,buf,sizeof(buf),0);
                if(len>0){
                    uint16_t id=get_txid(buf);
                    req_entry_t *e=find_req(id);
                    if(e){
                        patch_edns(buf,len,EXT_EDNS);
                        sendto(sock,buf,len,0,(void*)&e->client_addr,e->addr_len);
                        delete_req(e);
                    }
                }
            }
        }
    }
    return 0;
}
EOF
    
    # Compile with optimizations
    echo -ne "  ${CYAN}Compiling EDNS Proxy with O3 optimizations...${NC}"
    gcc -O3 -march=native -pipe /tmp/edns.c -o /usr/local/bin/edns-proxy 2>/tmp/compile.log &
    show_progress $!
    
    if [ $? -eq 0 ]; then
        chmod +x /usr/local/bin/edns-proxy
        echo -e "\r  ${GREEN}EDNS Proxy compiled successfully${NC}"
    else
        echo -e "\r  ${RED}Compilation failed${NC}"
        exit 1
    fi
    
    # Create EDNS service
    cat > /etc/systemd/system/edns-proxy.service << EOF
# ============================================================================
# EDNS PROXY SERVICE CONFIGURATION
# ============================================================================
[Unit]
Description=EDNS Proxy for SlowDNS
Description=High-performance DNS proxy with EDNS support
After=server-sldns.service
Requires=server-sldns.service

[Service]
Type=simple
ExecStart=/usr/local/bin/edns-proxy
Restart=always
RestartSec=3
User=root
LimitNOFILE=65536

[Install]
WantedBy=multi-user.target
EOF
    
    print_success "EDNS Proxy service configured"
    print_step_end
    
    # ============================================================================
    # STEP 5: FIREWALL CONFIGURATION
    # ============================================================================
    print_step "5"
    print_info "Configuring system firewall"
    
    echo -ne "  ${CYAN}Setting up firewall rules...${NC}"
    iptables -F 2>/dev/null
    iptables -X 2>/dev/null
    iptables -t nat -F 2>/dev/null
    iptables -t nat -X 2>/dev/null
    iptables -P INPUT ACCEPT 2>/dev/null
    iptables -P FORWARD ACCEPT 2>/dev/null
    iptables -P OUTPUT ACCEPT 2>/dev/null
    
    # Essential rules
    iptables -A INPUT -i lo -j ACCEPT 2>/dev/null
    iptables -A OUTPUT -o lo -j ACCEPT 2>/dev/null
    iptables -A INPUT -m state --state ESTABLISHED,RELATED -j ACCEPT 2>/dev/null
    iptables -A INPUT -p tcp --dport $SSHD_PORT -j ACCEPT 2>/dev/null
    iptables -A INPUT -p udp --dport $SLOWDNS_PORT -j ACCEPT 2>/dev/null
    iptables -A INPUT -p udp --dport 53 -j ACCEPT 2>/dev/null
    iptables -A INPUT -s 127.0.0.1 -d 127.0.0.1 -j ACCEPT 2>/dev/null
    iptables -A OUTPUT -s 127.0.0.1 -d 127.0.0.1 -j ACCEPT 2>/dev/null
    iptables -A INPUT -p icmp -j ACCEPT 2>/dev/null
    iptables -A INPUT -m state --state INVALID -j DROP 2>/dev/null
    
    # Disable IPv6
    echo 1 > /proc/sys/net/ipv6/conf/all/disable_ipv6 2>/dev/null &
    show_progress $!
    echo -e "\r  ${GREEN}Firewall rules configured${NC}"
    
    # Stop conflicting services
    echo -ne "  ${CYAN}Stopping conflicting DNS services...${NC}"
    systemctl stop systemd-resolved 2>/dev/null &
    fuser -k 53/udp 2>/dev/null &
    show_progress $!
    echo -e "\r  ${GREEN}DNS services stopped${NC}"
    
    print_success "Firewall and network configured"
    print_step_end
    
    # ============================================================================
    # STEP 6: START SERVICES
    # ============================================================================
    print_step "6"
    print_info "Starting all services"
    
    systemctl daemon-reload 2>/dev/null
    
    # Start SlowDNS
    echo -ne "  ${CYAN}Starting SlowDNS service...${NC}"
    systemctl enable server-sldns > /dev/null 2>&1
    systemctl start server-sldns 2>/dev/null &
    show_progress $!
    sleep 2
    
    if systemctl is-active --quiet server-sldns; then
        echo -e "\r  ${GREEN}SlowDNS service started${NC}"
    else
        echo -e "\r  ${YELLOW}Starting SlowDNS in background${NC}"
        $SLOWDNS_BINARY -udp :$SLOWDNS_PORT -mtu 1800 -privkey-file /etc/slowdns/server.key $NAMESERVER 127.0.0.1:$SSHD_PORT &
    fi
    
    # Start EDNS proxy
    echo -ne "  ${CYAN}Starting EDNS Proxy service...${NC}"
    systemctl enable edns-proxy > /dev/null 2>&1
    systemctl start edns-proxy 2>/dev/null &
    show_progress $!
    sleep 2
    
    if systemctl is-active --quiet edns-proxy; then
        echo -e "\r  ${GREEN}EDNS Proxy service started${NC}"
    else
        echo -e "\r  ${YELLOW}Starting EDNS Proxy manually${NC}"
        /usr/local/bin/edns-proxy &
    fi
    
    # Verify services
    echo -ne "  ${CYAN}Verifying service status...${NC}"
    sleep 3
    echo -e "\r  ${GREEN}Service verification complete${NC}"
    
    print_success "All services started successfully"
    print_step_end
    
    # ============================================================================
    # COMPLETION SUMMARY
    # ============================================================================
    print_header "🎉 INSTALLATION COMPLETE"
    
    # Show summary in a nice box
    echo -e "${CYAN}┌──────────────────────────────────────────────────────────┐${NC}"
    echo -e "${CYAN}│${NC} ${WHITE}${BOLD}SERVER INFORMATION${NC}                                   ${CYAN}│${NC}"
    echo -e "${CYAN}├──────────────────────────────────────────────────────────┤${NC}"
    echo -e "${CYAN}│${NC} ${YELLOW}●${NC} Server IP:     ${WHITE}$SERVER_IP${NC}                     ${CYAN}│${NC}"
    echo -e "${CYAN}│${NC} ${YELLOW}●${NC} SSH Port:      ${WHITE}$SSHD_PORT${NC}                        ${CYAN}│${NC}"
    echo -e "${CYAN}│${NC} ${YELLOW}●${NC} SlowDNS Port:  ${WHITE}$SLOWDNS_PORT${NC}                       ${CYAN}│${NC}"
    echo -e "${CYAN}│${NC} ${YELLOW}●${NC} EDNS Port:     ${WHITE}53${NC}                            ${CYAN}│${NC}"
    echo -e "${CYAN}│${NC} ${YELLOW}●${NC} MTU Size:      ${WHITE}1800${NC}                          ${CYAN}│${NC}"
    echo -e "${CYAN}│${NC} ${YELLOW}●${NC} Nameserver:    ${WHITE}$NAMESERVER${NC}           ${CYAN}│${NC}"
    echo -e "${CYAN}└──────────────────────────────────────────────────────────┘${NC}"
    
    echo -e "\n${CYAN}┌──────────────────────────────────────────────────────────┐${NC}"
    echo -e "${CYAN}│${NC} ${WHITE}${BOLD}AVAILABLE COMMANDS${NC}                                   ${CYAN}│${NC}"
    echo -e "${CYAN}├──────────────────────────────────────────────────────────┤${NC}"
    echo -e "${CYAN}│${NC} ${GREEN}slowdns-manage${NC} - Account management menu          ${CYAN}│${NC}"
    echo -e "${CYAN}│${NC} ${GREEN}slowdns-uninstall${NC} - Complete uninstallation        ${CYAN}│${NC}"
    echo -e "${CYAN}└──────────────────────────────────────────────────────────┘${NC}"
    
    # Create management scripts
    cat > /usr/local/bin/slowdns-manage << 'EOF'
#!/bin/bash
# Management script for SlowDNS accounts
if [ "$EUID" -ne 0 ]; then 
    echo "Please run as root"
    exit 1
fi
cd /etc/slowdns
source /etc/slowdns/amokhan.sh
account_management_menu
EOF
    chmod +x /usr/local/bin/slowdns-manage
    
    cat > /usr/local/bin/slowdns-uninstall << 'EOF'
#!/bin/bash
# Uninstall script for SlowDNS
if [ "$EUID" -ne 0 ]; then 
    echo "Please run as root"
    exit 1
fi
cd /etc/slowdns
source /etc/slowdns/amokhan.sh
uninstall_slowdns
EOF
    chmod +x /usr/local/bin/slowdns-uninstall
    
    # Save this script for future use
    cp "$0" /etc/slowdns/amokhan.sh
    chmod +x /etc/slowdns/amokhan.sh
    
    # Final message
    echo -e "\n${GREEN}${BOLD}╔══════════════════════════════════════════════════════════╗${NC}"
    echo -e "${GREEN}${BOLD}║${NC}    ${WHITE}🎯 SLOWDNS INSTALLATION COMPLETED SUCCESSFULLY!${NC}    ${GREEN}${BOLD}║${NC}"
    echo -e "${GREEN}${BOLD}║${NC}    ${WHITE}⚡ AMOKHAN V1.5 - Enhanced Edition${NC}                 ${GREEN}${BOLD}║${NC}"
    echo -e "${GREEN}${BOLD}║${NC}    ${WHITE}📊 Traffic monitoring enabled${NC}                      ${GREEN}${BOLD}║${NC}"
    echo -e "${GREEN}${BOLD}║${NC}    ${WHITE}🔄 Account renewal supported${NC}                       ${GREEN}${BOLD}║${NC}"
    echo -e "${GREEN}${BOLD}║${NC}    ${WHITE}🗑️ Complete uninstall available${NC}                    ${GREEN}${BOLD}║${NC}"
    echo -e "${GREEN}${BOLD}╚══════════════════════════════════════════════════════════╝${NC}"
    
    echo -e "\n${YELLOW}${BOLD}To manage SSH accounts, run: slowdns-manage${NC}"
    echo -e "${YELLOW}${BOLD}To uninstall completely, run: slowdns-uninstall${NC}"
    
    echo -e "\n${WHITE}${BOLD}Press Enter to continue to account management...${NC}"
    read -r
    
    # Show account management menu
    account_management_menu
}

# ============================================================================
# EXECUTE WITH ERROR HANDLING
# ============================================================================
trap 'echo -e "\n${RED}✗ Installation interrupted!${NC}"; exit 1' INT

if main; then
    exit 0
else
    echo -e "\n${RED}✗ Installation failed${NC}"
    exit 1
fi
