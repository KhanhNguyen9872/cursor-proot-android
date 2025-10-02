#!/data/data/com.termux/files/usr/bin/bash
set -e

echo "[*] Updating and installing required packages..."
termux-setup-storage
pkg update -y || exit 64
pkg install -y x11-repo || exit 64
pkg install -y termux-x11-nightly || exit 64
pkg install -y pulseaudio || exit 64
pkg install -y virglrenderer-android || exit 64
pkg install -y angle-android || exit 64
pkg install -y proot-distro || exit 64
pkg install -y wget || exit 64

echo "[*] Downloading Cursor Ubuntu image..."
IMAGE_URL="https://github.com/KhanhNguyen9872/cursor-proot-android/releases/download/1.6.45/cursor_1.6.45_ubuntu_24.04.tar.xz"
IMAGE_NAME="cursor_1.6.45_ubuntu_24.04.tar.xz"

wget "$IMAGE_URL" -O "$IMAGE_NAME" || {
  echo "[!] Failed to download file. Exiting script."
  exit 1
}

echo "[*] Restoring image with proot-distro..."
proot-distro remove ubuntu
proot-distro restore "$IMAGE_NAME" || {
  echo "[!] Failed to restore image. Exiting script."
  rm -f "$IMAGE_NAME"
  exit 1
}

echo "[*] Removing downloaded image file..."
rm -f "$IMAGE_NAME"

echo "[*] Creating cursor executable file..."
cat > /data/data/com.termux/files/usr/bin/cursor << 'EOF'
#!/data/data/com.termux/files/usr/bin/bash

show_help() {
    echo "Cursor Proot Android - Ubuntu Desktop Environment"
    echo ""
    echo "Usage: cursor [OPTION]"
    echo ""
    echo "Options:"
    echo "  help          Show this help message"
    echo "  uninstall     Uninstall cursor (removes all data)"
    echo "  reinstall     Reinstall cursor (removes all data and reinstalls)"
    echo "  login         Open cursor shell with environment variables"
    echo ""
    echo "Default login credentials:"
    echo "  Username: droidmaster"
    echo "  Password: 123456"
    echo ""
    echo "  Username: root"
    echo "  Password: 123456"
    echo ""
    echo "Run 'cursor' without arguments to start the desktop environment."
    echo "Run 'cursor login' to open a shell with environment variables."
}

uninstall_cursor() {
    echo "This will remove all cursor data and Ubuntu distribution."
    read -p "Are you sure you want to uninstall? (yes/no): " confirm
    if [[ $confirm == "yes" || $confirm == "y" ]]; then
        echo "Uninstalling cursor..."
        proot-distro remove ubuntu
        rm -rf /data/data/com.termux/files/usr/bin/cursor 2>/dev/null
        echo "Cursor has been uninstalled."
    else
        echo "Uninstall cancelled."
    fi
}

reinstall_cursor() {
    echo "This will remove all cursor data and reinstall."
    read -p "Are you sure you want to reinstall? (yes/no): " confirm
    if [[ $confirm == "yes" || $confirm == "y" ]]; then
        echo "Reinstalling cursor..."
        proot-distro remove ubuntu
        pkg update && pkg install wget -y
        wget https://raw.githubusercontent.com/KhanhNguyen9872/cursor-proot-android/refs/heads/main/install.sh -O install.sh
        bash install.sh
    else
        echo "Reinstall cancelled."
    fi
}

login_cursor() {
    echo "Logging into cursor shell..."
    proot-distro login ubuntu --user droidmaster --shared-tmp --no-sysvipc -- /bin/bash -c '
        export DISPLAY=:0
        export PULSE_SERVER=127.0.0.1
        export XDG_RUNTIME_DIR=${TMPDIR}
        export GALLIUM_DRIVER=virpipe
        export MESA_LOADER_DRIVER_OVERRIDE=virpipe
        export MESA_GL_VERSION_OVERRIDE=4.6COMPAT
        export MESA_GLES_VERSION_OVERRIDE=3.2
        dbus-daemon --session --fork
        exec /bin/bash
    '
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
    "")
        ;;
    *)
        echo "Unknown option: $1"
        echo "Use 'cursor help' for available options."
        exit 1
        ;;
esac

kill -9 $(pgrep -f "termux.x11") 2>/dev/null
kill -9 $(pgrep -f "virgl_test_server") 2> /dev/null
kill -9 $(pgrep -f "virgl_test_server_android") 2>/dev/null
kill -9 $(pgrep -f "pulseaudio") 2>/dev/null

pulseaudio --start --load="module-native-protocol-tcp auth-ip-acl=127.0.0.1 auth-anonymous=1" --exit-idle-time=-1
pacmd load-module module-native-protocol-tcp auth-ip-acl=127.0.0.1 auth-anonymous=1
virgl_test_server_android --angle-gl &

export GALLIUM_DRIVER=virpipe
export MESA_LOADER_DRIVER_OVERRIDE=virpipe
export MESA_GL_VERSION_OVERRIDE=4.6COMPAT
export MESA_GLES_VERSION_OVERRIDE=3.2
export XDG_RUNTIME_DIR=${TMPDIR}
export PULSE_SERVER=tcp:127.0.0.1:4713
export DISPLAY=:0
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

  dbus-daemon --session --fork
  startxfce4
'

exit 0
EOF

echo "[*] Setting execute permissions for cursor file..."
chmod 777 /data/data/com.termux/files/usr/bin/cursor

echo "[✓] Installation complete! You can run the environment with: cursor"
