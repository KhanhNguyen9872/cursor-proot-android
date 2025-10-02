#!/data/data/com.termux/files/usr/bin/bash
set -e

# Color definitions
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
WHITE='\033[1;37m'
DIM='\033[2m'
NC='\033[0m'

print_status() {
    printf "${CYAN}[*]${NC} ${WHITE}%s${NC}\n" "$1"
}

print_success() {
    printf "${GREEN}[✓]${NC} ${WHITE}%s${NC}\n" "$1"
}

print_error() {
    printf "${RED}[!]${NC} ${WHITE}%s${NC}\n" "$1"
}

print_warning() {
    printf "${YELLOW}[!]${NC} ${WHITE}%s${NC}\n" "$1"
}

print_info() {
    printf "${BLUE}[i]${NC} ${DIM}%s${NC}\n" "$1"
}

print_status "Updating and installing required packages..."
termux-setup-storage
print_info "Running: pkg update -y"
pkg update -y || exit 64
print_info "Running: pkg install -y x11-repo"
pkg install -y x11-repo || exit 64
print_info "Running: pkg install -y termux-x11-nightly"
pkg install -y termux-x11-nightly || exit 64
print_info "Running: pkg install -y pulseaudio"
pkg install -y pulseaudio || exit 64
print_info "Running: pkg install -y virglrenderer-android"
pkg install -y virglrenderer-android || exit 64
print_info "Running: pkg install -y angle-android"
pkg install -y angle-android || exit 64
print_info "Running: pkg install -y proot-distro"
pkg install -y proot-distro || exit 64
print_info "Running: pkg install -y wget"
pkg install -y wget || exit 64
print_info "Running: pkg install -y p7zip"
pkg install -y p7zip || exit 64
clear

print_status "Downloading Cursor Ubuntu image..."
BASE_URL="https://github.com/KhanhNguyen9872/cursor-proot-android/releases/download/1.7.28/cursor_1.7.28_ubuntu_24.04.7z"
SPLIT_FILES=()
for i in {001..030}; do
    SPLIT_FILES+=("cursor_1.7.28_ubuntu_24.04.7z.$i")
done
FINAL_IMAGE="cursor_1.7.28_ubuntu_24.04.tar.xz"

download_with_retry() {
    local url="$1"
    local filename="$2"
    local max_retries=5
    local retry_count=0
    
    while [ $retry_count -lt $max_retries ]; do
        print_info "Running: wget $url -O $filename (attempt $((retry_count + 1))/$max_retries)"
        if wget --progress=bar:force "$url" -O "$filename"; then
            return 0
        else
            retry_count=$((retry_count + 1))
            if [ $retry_count -lt $max_retries ]; then
                print_warning "Download failed, retrying in 3 seconds..."
                sleep 3
            fi
        fi
    done
    
    print_error "Failed to download $filename after $max_retries attempts"
    printf "${YELLOW}Do you want to try downloading file $filename again?${NC} ${DIM}(yes/no):${NC} "
    read retry_choice
    if [[ $retry_choice == "yes" || $retry_choice == "y" ]]; then
        return 1
    else
        print_error "User cancelled. Cleaning up downloaded files..."
        rm -f "${SPLIT_FILES[@]}"
        exit 1
    fi
}

# Download split files with progress
total_files=${#SPLIT_FILES[@]}
current_file=0

for file in "${SPLIT_FILES[@]}"; do
    current_file=$((current_file + 1))
    printf "${CYAN}[*]${NC} ${WHITE}Downloading file $current_file/$total_files: $file${NC}\n"
    
    while ! download_with_retry "${BASE_URL}.${file##*.}" "$file"; do
        printf "${YELLOW}[!]${NC} ${WHITE}Retrying download of $file ($current_file/$total_files)...${NC}\n"
    done
done

print_status "Extracting split files..."
print_info "Running: 7z x cursor_1.7.28_ubuntu_24.04.7z.001"
7z x cursor_1.7.28_ubuntu_24.04.7z.001 || {
    print_error "Failed to extract files. Exiting script."
    rm -f "${SPLIT_FILES[@]}"
    exit 1
}

print_info "Running: rm -f split files"
rm -f "${SPLIT_FILES[@]}"

clear
print_status "Restoring image with proot-distro..."
print_info "Running: proot-distro remove ubuntu"
proot-distro remove ubuntu
print_info "Running: proot-distro restore $FINAL_IMAGE"
proot-distro restore "$FINAL_IMAGE" || {
  print_error "Failed to restore image. Exiting script."
  rm -f "$FINAL_IMAGE"
  exit 1
}
clear
print_status "Removing downloaded image file..."
print_info "Running: rm -f $FINAL_IMAGE"
rm -f "$FINAL_IMAGE"
clear

print_status "Creating cursor executable file..."
cat > /data/data/com.termux/files/usr/bin/cursor << 'EOF'
#!/data/data/com.termux/files/usr/bin/bash

export GALLIUM_DRIVER=virpipe
export MESA_LOADER_DRIVER_OVERRIDE=virpipe
export MESA_GL_VERSION_OVERRIDE=4.6COMPAT
export MESA_GLES_VERSION_OVERRIDE=3.2
export XDG_RUNTIME_DIR=${TMPDIR}
export PULSE_SERVER=tcp:127.0.0.1:4713
export DISPLAY=:0

show_help() {
    printf "${CYAN}╔══════════════════════════════════════════════════════════════╗${NC}\n"
    printf "${CYAN}║${NC} ${WHITE}Cursor Proot Android - Ubuntu Desktop Environment${NC} ${CYAN}║${NC}\n"
    printf "${CYAN}╚══════════════════════════════════════════════════════════════╝${NC}\n"
    printf "\n"
    printf "${YELLOW}Usage:${NC} ${WHITE}cursor [OPTION]${NC}\n"
    printf "\n"
    printf "${YELLOW}Options:${NC}\n"
    printf "  ${GREEN}help${NC}          ${DIM}Show this help message${NC}\n"
    printf "  ${GREEN}uninstall${NC}     ${DIM}Uninstall cursor (removes all data)${NC}\n"
    printf "  ${GREEN}reinstall${NC}     ${DIM}Reinstall cursor (removes all data and reinstalls)${NC}\n"
    printf "  ${GREEN}login${NC}         ${DIM}Open cursor shell with environment variables${NC}\n"
    printf "  ${GREEN}agent${NC}         ${DIM}Start cursor agent with environment variables${NC}\n"
    printf "  ${GREEN}stop${NC}          ${DIM}Stop all cursor processes${NC}\n"
    printf "\n"
    printf "${YELLOW}Default login credentials:${NC}\n"
    printf "  ${BLUE}Username:${NC} ${WHITE}droidmaster${NC} ${DIM}| Password: 123456${NC}\n"
    printf "  ${BLUE}Username:${NC} ${WHITE}root${NC}        ${DIM}| Password: 123456${NC}\n"
    printf "\n"
    printf "${YELLOW}Examples:${NC}\n"
    printf "  ${DIM}cursor${NC}              ${DIM}Start the desktop environment${NC}\n"
    printf "  ${DIM}cursor login${NC}        ${DIM}Open a shell with environment variables${NC}\n"
    printf "  ${DIM}cursor agent${NC}        ${DIM}Start cursor agent with environment variables${NC}\n"
    printf "  ${DIM}cursor stop${NC}         ${DIM}Stop all cursor processes${NC}\n"
}

uninstall_cursor() {
    printf "${YELLOW}⚠️  This will remove all cursor data and Ubuntu distribution.${NC}\n"
    printf "${RED}Are you sure you want to uninstall?${NC} ${DIM}(yes/no):${NC} "
    read confirm
    if [[ $confirm == "yes" || $confirm == "y" ]]; then
        printf "${CYAN}[*]${NC} ${WHITE}Uninstalling cursor...${NC}\n"
        proot-distro remove ubuntu
        rm -rf /data/data/com.termux/files/usr/bin/cursor 2>/dev/null
        printf "${GREEN}[✓]${NC} ${WHITE}Cursor has been uninstalled.${NC}\n"
    else
        printf "${YELLOW}[!]${NC} ${WHITE}Uninstall cancelled.${NC}\n"
    fi
}

reinstall_cursor() {
    printf "${YELLOW}⚠️  This will remove all cursor data and reinstall.${NC}\n"
    printf "${RED}Are you sure you want to reinstall?${NC} ${DIM}(yes/no):${NC} "
    read confirm
    if [[ $confirm == "yes" || $confirm == "y" ]]; then
        printf "${CYAN}[*]${NC} ${WHITE}Reinstalling cursor...${NC}\n"
        proot-distro remove ubuntu
        printf "${BLUE}[i]${NC} ${DIM}Running: pkg update && pkg install wget -y${NC}\n"
        pkg update && pkg install wget -y
        printf "${BLUE}[i]${NC} ${DIM}Running: wget install script${NC}\n"
        wget https://raw.githubusercontent.com/KhanhNguyen9872/cursor-proot-android/refs/heads/main/install.sh -O install.sh
        bash install.sh
    else
        printf "${YELLOW}[!]${NC} ${WHITE}Reinstall cancelled.${NC}\n"
    fi
}

login_cursor() {
    printf "${CYAN}[*]${NC} ${WHITE}Logging into cursor shell...${NC}\n"
    start_basic_services
    proot-distro login ubuntu --user droidmaster --shared-tmp --no-sysvipc -- /bin/bash -c '
        export DISPLAY=:0
        export PULSE_SERVER=127.0.0.1
        export XDG_RUNTIME_DIR=${TMPDIR}
        export GALLIUM_DRIVER=virpipe
        export MESA_LOADER_DRIVER_OVERRIDE=virpipe
        export MESA_GL_VERSION_OVERRIDE=4.6COMPAT
        export MESA_GLES_VERSION_OVERRIDE=3.2
        
        if ! pgrep -f "dbus-daemon.*session" > /dev/null; then
            dbus-daemon --session --fork
        fi
        
        exec /bin/bash
    '
}

agent_cursor() {
    printf "${CYAN}[*]${NC} ${WHITE}Starting cursor agent...${NC}\n"
    start_basic_services
    proot-distro login ubuntu --user droidmaster --shared-tmp --no-sysvipc -- /bin/bash -c '
        export DISPLAY=:0
        export PULSE_SERVER=127.0.0.1
        export XDG_RUNTIME_DIR=${TMPDIR}
        export GALLIUM_DRIVER=virpipe
        export MESA_LOADER_DRIVER_OVERRIDE=virpipe
        export MESA_GL_VERSION_OVERRIDE=4.6COMPAT
        export MESA_GLES_VERSION_OVERRIDE=3.2
        
        if ! pgrep -f "dbus-daemon.*session" > /dev/null; then
            dbus-daemon --session --fork
        fi
        
        cursor-agent .
    '
}

start_basic_services() {
    if ! pgrep -f "pulseaudio" > /dev/null; then
        pulseaudio --start --load="module-native-protocol-tcp auth-ip-acl=127.0.0.1 auth-anonymous=1" --exit-idle-time=-1
        pacmd load-module module-native-protocol-tcp auth-ip-acl=127.0.0.1 auth-anonymous=1
    fi
    
    if ! pgrep -f "virgl_test_server_android" > /dev/null; then
        virgl_test_server_android --angle-gl &
    fi
}

stop_cursor() {
    printf "${CYAN}[*]${NC} ${WHITE}Stopping all cursor processes...${NC}\n"
    
    print_info "Running: kill -9 termux.x11 processes"
    kill -9 $(pgrep -f "termux.x11") 2>/dev/null || true
    
    print_info "Running: kill -9 virgl processes"
    kill -9 $(pgrep -f "virgl_test_server") 2>/dev/null || true
    kill -9 $(pgrep -f "virgl_test_server_android") 2>/dev/null || true
    
    print_info "Running: kill -9 pulseaudio processes"
    kill -9 $(pgrep -f "pulseaudio") 2>/dev/null || true
    
    print_info "Running: kill -9 dbus-daemon processes"
    kill -9 $(pgrep -f "dbus-daemon") 2>/dev/null || true
    
    print_info "Running: kill -9 proot processes"
    kill -9 $(pgrep -f "proot") 2>/dev/null || true
    kill -9 $(pgrep -f "proot-distro") 2>/dev/null || true
    
    print_info "Running: kill -9 XFCE processes"
    kill -9 $(pgrep -f "startxfce4") 2>/dev/null || true
    kill -9 $(pgrep -f "xfce4") 2>/dev/null || true
    
    print_info "Running: kill -9 cursor-agent processes"
    kill -9 $(pgrep -f "cursor-agent") 2>/dev/null || true
    
    print_success "All cursor processes stopped."
}

case "$1" in
    help)
        show_help
        exit 0
        ;;
    uninstall)
        uninstall_cursor
        exit 0
        ;;
    reinstall)
        reinstall_cursor
        exit 0
        ;;
    login)
        login_cursor
        exit 0
        ;;
    agent)
        agent_cursor
        exit 0
        ;;
    stop)
        stop_cursor
        exit 0
        ;;
    "")
        ;;
    *)
        printf "${RED}[!]${NC} ${WHITE}Unknown option: $1${NC}\n"
        printf "${YELLOW}[i]${NC} ${DIM}Use 'cursor help' for available options.${NC}\n"
        exit 1
        ;;
esac

printf "${CYAN}[*]${NC} ${WHITE}Starting XFCE4...${NC}\n"
start_basic_services

termux-x11 :0 -dpi 240 -listen tcp >/dev/null &

sleep 3

am start --user 0 -n com.termux.x11/com.termux.x11.MainActivity > /dev/null 2>&1
sleep 1

proot-distro login ubuntu --user droidmaster --shared-tmp --no-sysvipc -- /bin/bash -c '
  export DISPLAY=:0
  export PULSE_SERVER=127.0.0.1
  export XDG_RUNTIME_DIR=${TMPDIR}
  export GALLIUM_DRIVER=virpipe
  export MESA_LOADER_DRIVER_OVERRIDE=virpipe
  export MESA_GL_VERSION_OVERRIDE=4.6COMPAT
  export MESA_GLES_VERSION_OVERRIDE=3.2

  if ! pgrep -f "dbus-daemon.*session" > /dev/null; then
    dbus-daemon --session --fork
  fi
  
  startxfce4
'

exit 0
EOF

print_status "Setting execute permissions for cursor file..."
print_info "Running: chmod 777 /data/data/com.termux/files/usr/bin/cursor"
chmod 777 /data/data/com.termux/files/usr/bin/cursor
clear

print_success "Installation complete! You can run the environment with: cursor"
