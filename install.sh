#!/data/data/com.termux/files/usr/bin/bash

set -e

echo "[*] Cập nhật và cài đặt các gói cần thiết..."
termux-setup-storage
pkg update -y
pkg install -y x11-repo
pkg install -y termux-x11-nightly
pkg install -y pulseaudio
pkg install -y virglrenderer-android
pkg install -y proot-distro
pkg install -y wget

echo "[*] Tải image Cursor Ubuntu..."
IMAGE_URL="https://github.com/KhanhNguyen9872/cursor-proot-android/releases/download/1.6.45/cursor_1.6.45_ubuntu_24.04.tar.xz"
IMAGE_NAME="cursor_1.6.45_ubuntu_24.04.tar.xz"

wget "$IMAGE_URL" -O "$IMAGE_NAME" || {
  echo "[!] Tải file thất bại. Thoát script."
  exit 1
}

echo "[*] Khôi phục image với proot-distro..."
proot-distro restore "$IMAGE_NAME" || {
  echo "[!] Khôi phục image thất bại. Thoát script."
  rm -f "$IMAGE_NAME"
  exit 1
}

echo "[*] Xoá file image đã tải..."
rm -f "$IMAGE_NAME"

echo "[*] Tạo file chạy cursor..."
cat > /data/data/com.termux/files/usr/bin/cursor << 'EOF'
#!/data/data/com.termux/files/usr/bin/bash

# Kill open X11 processes
kill -9 $(pgrep -f "termux.x11") 2>/dev/null
killall -9 termux-x11 Xwayland pulseaudio virgl_test_server_android

# Enable PulseAudio over Network
pulseaudio --start --load="module-native-protocol-tcp auth-ip-acl=127.0.0.1 auth-anonymous=1" --exit-idle-time=-1
pacmd load-module module-native-protocol-tcp auth-ip-acl=127.0.0.1 auth-anonymous=1
virgl_test_server_android &

# Prepare termux-x11 session
export XDG_RUNTIME_DIR=${TMPDIR}
export PULSE_SERVER=tcp:127.0.0.1:4713
export DISPLAY=:0
termux-x11 :0 -dpi 240 -listen tcp >/dev/null &

# Wait a bit until termux-x11 gets started.
sleep 3

# Launch Termux X11 main activity
am start --user 0 -n com.termux.x11/com.termux.x11.MainActivity > /dev/null 2>&1
sleep 1

# Login in PRoot Environment
proot-distro login ubuntu --user root --shared-tmp --no-sysvipc -- /bin/bash -c  'export GALLIUM_DRIVER=virpipe && export DISPLAY=:0 && export PULSE_SERVER=127.0.0.1 && export XDG_RUNTIME_DIR=${TMPDIR} && sudo service dbus start && su - droidmaster -c "dbus-launch --exit-with-session startxfce4"'

exit 0
EOF

echo "[*] Cấp quyền thực thi cho file cursor..."
chmod 777 /data/data/com.termux/files/usr/bin/cursor

echo "[✓] Cài đặt hoàn tất! Bạn có thể chạy môi trường bằng lệnh: cursor"
