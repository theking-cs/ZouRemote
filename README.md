# ZouRemote
remote control 
# ZouRemote v1.1 📱💻

**ZouRemote** is a powerful utility for **Enigma2** receivers (Vu+, Dreambox, Zgemma, etc.) that bridges the gap between your TV and your web browser. It provides a dual-purpose service: a **Virtual Web Remote** and a **Web-based SSH Terminal**.

---

## 🚀 Key Features

- **Web Remote Control:** Control your decoder's functions (Zapping, Volume, Menu) from any smartphone, tablet, or PC on your network.
- **Integrated SSH Terminal:** Access your receiver's command line directly via a web browser using `ttyd`. No Putty or extra software required.
- **Lightweight Server:** Optimized to run in the background without affecting TV performance.
- **Real-time Status:** Easy-to-use plugin interface to start/stop services with one click.

---

## 📥 Installation

To install **ZouRemote** on your Enigma2 device, run the following command in your terminal:

```bash
wget -qO- https://raw.githubusercontent.com/theking-cs/ZouRemote/main/instalar.sh | bash

## 🖥️ Web SSH Console Dependency (ttyd)

This plugin includes a Web SSH Console feature powered by `ttyd`. Since `ttyd` cannot be installed via standard `opkg` repositories on most Enigma2 images, the plugin is designed to **automatically detect, download, and configure** the binary for ARM-based decoders (like Vu+ Solo 4K) upon its first run.

### Manual Installation (Optional / Troubleshooting)
If the automatic download fails or you prefer to set it up manually, connect to your decoder via Putty (SSH/Telnet) and run the following commands:

1. **Download the binary** matching your decoder's architecture (ARMhf):
   ```bash
   wget -O /usr/bin/ttyd [https://github.com/tsl0922/ttyd/releases/download/1.7.7/ttyd.armhf](https://github.com/tsl0922/ttyd/releases/download/1.7.7/ttyd.armhf)

permissions chmod +x /usr/bin/ttyd

