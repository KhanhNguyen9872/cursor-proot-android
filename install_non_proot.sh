#!/data/data/com.termux/files/usr/bin/bash
set -e

echo "[*] Cập nhật và cài đặt các gói cần thiết..."
termux-setup-storage
pkg update -y
pkg upgrade -y
pkg update -y
pkg install -y x11-repo
pkg install -y termux-x11-nightly
pkg install -y pulseaudio
pkg install -y wget
pkg install -y xfce4 dbus
echo "[*] Cài đặt trình duyệt và công cụ cần thiết..."
pkg install -y firefox
pkg install -y thunar gvfs
pkg install -y mousepad
pkg install -y xfce4-terminal
pkg install -y ristretto
pkg install -y pavucontrol
pkg install -y wget curl git unzip htop neofetch
pkg install -y python3 which build-essential
pkg install -y nodejs
pkg install -y php

echo "[*] Tạo file deb installer..."
cat > /data/data/com.termux/files/usr/bin/deb-installer << 'EOF'
#!/data/data/com.termux/files/usr/bin/bash
file="$1"
pkg=$(basename "$file")

zenity --question --title="Install DEB" --text="Do you want to install $pkg?"
if [ $? -eq 0 ]; then
    dpkg -i "$file" 2>&1 | tee >(zenity --text-info --title="Installing $pkg")
    apt -f install -y
fi
EOF

echo "[*] Tạo file chạy xfce4..."
cat > /data/data/com.termux/files/usr/bin/startxfce << 'EOF'
#!/data/data/com.termux/files/usr/bin/bash
set -e

# Dọn X11 cũ (nếu có)
pkill -f "termux.x11" 2>/dev/null || true

# PulseAudio (âm thanh)
pulseaudio --start \
  --load="module-native-protocol-tcp auth-ip-acl=127.0.0.1 auth-anonymous=1" \
  --exit-idle-time=-1

# Biến môi trường X11 + âm thanh
export DISPLAY=:0
export PULSE_SERVER=127.0.0.1

# XDG_RUNTIME_DIR bắt buộc cho dbus trên Termux
export XDG_RUNTIME_DIR="${TMPDIR:-/data/data/com.termux/files/usr/tmp}"
mkdir -p "$XDG_RUNTIME_DIR"
chmod 700 "$XDG_RUNTIME_DIR"

# Khởi chạy Termux:X11 server
termux-x11 :0 -dpi 240 -listen tcp >/dev/null 2>&1 &

# Chờ server lên
sleep 2

# Mở app Termux:X11 Activity (màn hình)
am start --user 0 -n com.termux.x11/com.termux.x11.MainActivity >/dev/null 2>&1 || true
sleep 1

# Khởi D-Bus session (ưu tiên dbus-daemon; fallback dbus-launch nếu có)
if command -v dbus-daemon >/dev/null 2>&1; then
  # đường dẫn socket bus nằm trong XDG_RUNTIME_DIR
  export DBUS_SESSION_BUS_ADDRESS="unix:path=${XDG_RUNTIME_DIR}/bus"
  # nếu chưa có bus thì tạo
  if [ ! -S "${XDG_RUNTIME_DIR}/bus" ]; then
    dbus-daemon --session --address="${DBUS_SESSION_BUS_ADDRESS}" --fork
  fi
elif command -v dbus-launch >/dev/null 2>&1; then
  # Ít khi cần trên Termux, nhưng để dự phòng
  eval "$(dbus-launch --sh-syntax)"
fi

# Chạy XFCE
# Có thể đổi startxfce4 => xfce4-session nếu muốn
startxfce4

exit 0
EOF

echo "[*] Cấp quyền thực thi cho file startxfce..."
chmod 777 /data/data/com.termux/files/usr/bin/startxfce
chmod 777 /data/data/com.termux/files/usr/bin/deb-installer

echo "[✓] Cài đặt hoàn tất! Gõ lệnh: startxfce rồi mở ứng dụng Termux:X11 để thấy desktop."
