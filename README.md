# 🖥️ Cursor Ubuntu X11 trên Termux

Chạy **Ubuntu 24.04** với giao diện đồ họa (XFCE4) trên thiết bị Android thông qua **Termux**.

Môi trường nhẹ, mượt, hỗ trợ **âm thanh** với PulseAudio và **hiển thị đồ họa** qua `termux-x11`.  
Chỉ cần một dòng lệnh `cursor` để bắt đầu!

---

## 🚀 Tính năng nổi bật

- ✅ Cài Ubuntu 24.04 tự động bằng `proot-distro`
- ✅ Khôi phục từ image cấu hình sẵn (có `xfce4`, `dbus`, người dùng `droidmaster`)
- ✅ Giao diện đồ họa qua `termux-x11`
- ✅ Hỗ trợ âm thanh với PulseAudio
- ✅ Một lệnh duy nhất để khởi động toàn bộ hệ thống

---

## 🛠️ Yêu cầu

- **Termux ARM64** (mới nhất [GitHub](https://github.com/termux/termux-app/releases/download/v0.118.2/termux-app_v0.118.2+github-debug_arm64-v8a.apk)) hoặc nếu gặp lỗi do Termux, hãy tải [tại đây](https://khanhnguyen9872.github.io/Ninja_Server_Termux/CONF_FILE/termux_0.118.apk)
- Android 10+ ARM64 với ít nhất **4GB RAM** trở lên
- Cài thêm app [Termux: X11 ARM64](https://github.com/termux/termux-x11/releases/download/nightly/app-arm64-v8a-debug.apk)

---

## 📦 Cài đặt

### 1. Cài đặt nhanh qua script:

```
pkg update && pkg install wget -y
wget https://raw.githubusercontent.com/<your-username>/cursor-install/main/install_cursor.sh
bash install_cursor.sh
```

> Script sẽ:
> - Cài các gói cần thiết: `proot-distro`, `termux-x11-nightly`, `pulseaudio`, ...
> - Tải image Ubuntu đã cấu hình sẵn
> - Khôi phục môi trường Ubuntu
> - Tạo lệnh `cursor` để khởi động dễ dàng

---

## ▶️ Sử dụng

Sau khi cài xong, chạy:

```
cursor
```

Môi trường đồ họa Ubuntu (XFCE4) sẽ hiển thị thông qua `Termux: X11`.

> 📱 Nhớ cài **Termux: X11** từ F-Droid:  
> https://github.com/termux/termux-x11/releases

---

## 🗂️ Cấu trúc

| Tệp/Thư mục                       | Mô tả                                     |
|----------------------------------|-------------------------------------------|
| `install_cursor.sh`              | Script cài đặt tự động                     |
| `/usr/bin/cursor`                | File khởi chạy môi trường Ubuntu          |
| `cursor_0.50_ubuntu_24.04.tar.xz`| Image Ubuntu 24.04 cấu hình sẵn            |

---

## ❓ Câu hỏi thường gặp

**Q: Không hiện giao diện sau khi chạy `cursor`?**  
A: Đảm bảo bạn đã cài Termux: X11 và đang mở nó.

**Q: Không có âm thanh?**  
A: Kiểm tra PulseAudio đã được khởi chạy. Bạn có thể thoát và chạy lại `cursor`.

**Q: Làm sao cập nhật Ubuntu bên trong?**  
A: Trong Ubuntu, chạy:
```
sudo apt update && sudo apt upgrade
```

---

## ❤️ Cảm ơn & Nguồn

- [termux/proot-distro](https://github.com/termux/proot-distro)
- [termux/termux-x11](https://github.com/termux/termux-x11)
- [LinuxDroid/Master/Termux-Desktops](https://github.com/LinuxDroidMaster/Termux-Desktops)

---

## ☕ Đóng góp

Bạn có thể mở issue hoặc pull request để cải tiến dự án!  
Mọi đóng góp đều rất được hoan nghênh 🙌

> Made with ❤️ by [KhanhNguyen9872]
