# 🧠 Cursor trên Android với Ubuntu GUI (Termux-based)

Chạy **[Cursor](https://cursor.so)** – trình soạn thảo mã AI-enhanced mạnh mẽ – **trực tiếp trên Android** thông qua môi trường **Ubuntu 24.04 + XFCE4**!

Dự án này cung cấp một giải pháp đơn giản để bạn:
- Thiết lập môi trường Ubuntu GUI hoàn chỉnh trên Termux
- Hỗ trợ âm thanh qua PulseAudio
- Giao diện đồ họa hiển thị qua Termux: X11
- Và đặc biệt: **chạy được phần mềm Cursor ngay trên thiết bị Android**

---

## 🚀 Tính năng chính

- ✅ Dựa trên Ubuntu 24.04 + XFCE4 nhẹ và mượt
- ✅ Khôi phục image Cursor cấu hình sẵn (đã cài các dependency)
- ✅ Hỗ trợ đồ họa thông qua `termux-x11`
- ✅ Có PulseAudio giúp hỗ trợ cả âm thanh
- ✅ Một lệnh duy nhất: `cursor` để khởi chạy môi trường GUI

---

## 🛠️ Yêu cầu

- **Termux ARM64** (mới nhất [GitHub](https://github.com/termux/termux-app/releases/download/v0.118.2/termux-app_v0.118.2+github-debug_arm64-v8a.apk)) hoặc nếu gặp lỗi do Termux, hãy tải [tại đây](https://khanhnguyen9872.github.io/Ninja_Server_Termux/CONF_FILE/termux_0.118.apk)
- Android 10+ ARM64 với ít nhất **4GB RAM** trở lên
- Cài thêm app [Termux: X11 ARM64](https://github.com/termux/termux-x11/releases/download/nightly/app-arm64-v8a-debug.apk)
- Kết nối Internet để tải file image lần đầu

---

## 📦 Cài đặt

### 1. Cài đặt nhanh qua script:

```bash
pkg update && pkg install wget -y
wget https://raw.githubusercontent.com/KhanhNguyen9872/cursor-proot-android/refs/heads/main/install.sh -O install.sh
bash install.sh
```
### Password user (root/droidmaster)
```bash
123456
```

⚠️ Nếu gặp lỗi mạng khi tải file hoặc cài package, hãy thử:
- Bật VPN 1.1.1.1 của Cloudflare để vượt chặn hoặc cải thiện kết nối.
👉 Tải app VPN chính chủ tại: https://1.1.1.1
- Ứng dụng hoạt động nhanh, miễn phí, không cần đăng ký – rất hữu ích khi Termux bị giới hạn mạng.

> Script sẽ:
> - Cài các gói cần thiết: `proot-distro`, `termux-x11-nightly`, `pulseaudio`, ...
> - Tải image Ubuntu đã cấu hình sẵn
> - Khôi phục môi trường Ubuntu
> - Tạo lệnh `cursor` để khởi động dễ dàng

---

## ▶️ Chạy môi trường Cursor

Sau khi cài đặt xong, chỉ cần gõ:

```bash
cursor
```

Giao diện Ubuntu + XFCE4 sẽ khởi động, và bạn có thể sử dụng phần mềm **Cursor** như trên máy tính Linux.

Lưu ý quan trọng:
- Bạn cần cài app Termux: X11 và mở ứng dụng này song song khi chạy cursor.
👉 Tải tại: https://github.com/termux/termux-x11/releases/download/nightly/app-arm64-v8a-debug.apk

🛠️ Lỗi thường gặp:
- Trong lần đầu tiên đăng nhập tài khoản Cursor, giao diện đăng nhập có thể không phản hồi.

✅ Cách khắc phục:
- Buộc dừng Termux và mở lại, sau đó gõ lại `cursor`
- Quá trình đăng nhập sẽ hoạt động bình thường.

---

## 📂 Cấu trúc file

| Tên file                        | Vai trò                                      |
|-------------------------------|----------------------------------------------|
| `install.sh`           | Script cài đặt môi trường Ubuntu + Cursor    |
| `/usr/bin/cursor`             | Lệnh khởi chạy môi trường GUI + Cursor       |
| `cursor_0.50_ubuntu_24.04.tar.xz` | Image Ubuntu + Cursor được cấu hình sẵn |

---

## ❓ Câu hỏi thường gặp

**Q: Cursor có hoạt động như trên PC không?**  
A: Có, bạn sẽ có trải nghiệm tương tự như khi chạy trên Ubuntu Desktop.

**Q: Tại sao không thấy giao diện hiển thị?**  
A: Đảm bảo bạn đã mở **Termux: X11** trước khi chạy `cursor`.

**Q: Tôi muốn cài thêm phần mềm trong Ubuntu?**  
A: Dễ dàng! Sau khi vào môi trường, dùng lệnh:
```bash
sudo apt update && sudo apt install <tên-gói>
```

---

## ❤️ Cảm ơn & Nguồn

- [Cursor.so](https://cursor.so) — trình soạn thảo mã AI-enhanced tuyệt vời
- [termux/proot-distro](https://github.com/termux/proot-distro)
- [termux/termux-x11](https://github.com/termux/termux-x11)
- [LinuxDroid/Master/Termux-Desktops](https://github.com/LinuxDroidMaster/Termux-Desktops)

---

## ☕ Đóng góp

Bạn có thể đóng góp bằng cách:
- Mở issue nếu gặp lỗi
- Gửi pull request để cải tiến
- Chia sẻ dự án đến cộng đồng yêu thích Cursor và Linux trên Android

> Made with ❤️ by [KhanhNguyen9872]
