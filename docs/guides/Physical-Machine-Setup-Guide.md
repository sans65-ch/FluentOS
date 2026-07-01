# FluentOS 实体机安装配置方案

本文档提供 FluentOS 在实体机上的完整安装和优化配置方案。

---

## 目录

1. [硬件推荐配置](#1-硬件推荐配置)
2. [安装前准备](#2-安装前准备)
3. [双系统安装步骤](#3-双系统安装步骤)
4. [单系统安装步骤](#4-单系统安装步骤)
5. [安装后优化配置](#5-安装后优化配置)
6. [驱动安装指南](#6-驱动安装指南)
7. [常用软件安装](#7-常用软件安装)
8. [性能调优](#8-性能调优)
9. [故障排除](#9-故障排除)

---

## 1. 硬件推荐配置

### 最低配置（性能模式）
| 组件 | 要求 |
|------|------|
| CPU | Intel Core i3-4130 / AMD FX-6300 及以上 |
| 内存 | 4 GB DDR3 |
| 存储 | 30 GB 可用空间（推荐 SSD） |
| 显卡 | Intel HD Graphics 4400 / AMD Radeon R5 |
| 网络 | 有线或无线网卡 |

### 推荐配置（全特效模式）
| 组件 | 要求 |
|------|------|
| CPU | Intel Core i5-4590 / AMD Ryzen 3 1200 及以上 |
| 内存 | 8 GB DDR3/DDR4 |
| 存储 | 60 GB SSD |
| 显卡 | NVIDIA GTX 750Ti / AMD RX 550 及以上 |
| 网络 | 千兆有线 + WiFi |

### 高端配置
| 组件 | 要求 |
|------|------|
| CPU | Intel Core i7-4790 / AMD Ryzen 5 2600 及以上 |
| 内存 | 16 GB+ |
| 存储 | 120 GB+ NVMe SSD |
| 显卡 | NVIDIA GTX 1060 / AMD RX 580 及以上 |
| 网络 | 千兆有线 + WiFi 6 |

---

## 2. 安装前准备

### 2.1 下载 ISO

从 GitHub Releases 下载最新 ISO：
- 地址: https://github.com/sans65-ch/FluentOS/releases
- 文件名: `FluentOS-1.0.0-x86_64.iso`

### 2.2 制作启动盘

#### Windows 下使用 Rufus（推荐）
1. 下载 [Rufus](https://rufus.ie/)
2. 插入 USB 闪存盘（至少 4GB）
3. 运行 Rufus
4. 选择 FluentOS ISO 文件
5. 选择目标 USB 设备
6. 点击"开始"
7. 等待写入完成

#### Linux 下使用 dd
```bash
# 查看设备名
lsblk

# 写入 USB（注意替换 /dev/sdX）
sudo dd if=FluentOS-1.0.0-x86_64.iso of=/dev/sdX bs=4M status=progress && sync
```

### 2.3 备份数据

⚠️ **重要：安装前请备份重要数据！**

双系统安装风险较低，但仍建议：
- 备份 Windows 个人文件
- 记录重要软件的序列号
- 创建系统还原点

### 2.4 检查 BIOS 设置

重启电脑，按 `F2`/`Del`/`F10` 进入 BIOS：

| 设置项 | 推荐值 |
|--------|--------|
| Secure Boot | **关闭** (Disabled) |
| Fast Boot | **关闭** (Disabled) |
| SATA 模式 | AHCI |
| 启动顺序 | USB 优先 |

---

## 3. 双系统安装步骤

### 3.1 准备 Windows 分区

1. 右键"此电脑" → "管理" → "磁盘管理"
2. 右键 C 盘 → "压缩卷"
3. 输入压缩空间量：
   - 最低配置：30720 MB (30 GB)
   - 推荐配置：61440 MB (60 GB)
   - 重度使用：102400 MB (100 GB)
4. 点击"压缩"
5. 压缩后会出现"未分配"空间

### 3.2 从 USB 启动

1. 插入制作好的 USB 启动盘
2. 重启电脑
3. 按启动菜单快捷键（常见：`F12`、`F11`、`Esc`、`F8`）
4. 选择 USB 设备启动

### 3.3 试用 Live 环境

启动后选择 "Try FluentOS without installing"：
- 检查硬件是否正常工作
- 测试网络连接
- 体验桌面环境
- 确认无误后开始安装

### 3.4 运行安装程序

1. 双击桌面的 "Install FluentOS"
2. 按照向导操作：

#### 第1步：语言选择
- 选择"简体中文"
- 点击"下一步"

#### 第2步：位置选择
- 选择时区（上海/北京）
- 点击"下一步"

#### 第3步：键盘布局
- 选择 "cn" 或 "us"
- 点击"下一步"

#### 第4步：分区（关键！）
选择"手动分区"：

| 分区 | 大小 | 文件系统 | 挂载点 | 说明 |
|------|------|----------|--------|------|
| EFI | 512 MB | FAT32 | /boot/efi | 共享 Windows 的 EFI |
| Root | 剩余空间 | ext4 | / | 系统分区 |

⚠️ **注意**：
- 如果已有 Windows EFI 分区，**不要格式化**，直接挂载到 /boot/efi
- 根分区选择之前压缩出来的未分配空间
- 不要动 Windows 的分区！

#### 第5步：用户信息
- 输入用户名
- 输入密码
- 确认密码
- 主机名可留默认

#### 第6步：摘要
- 检查分区设置
- 确认无误后点击"安装"

### 3.5 等待安装完成

安装过程约 10-30 分钟，取决于硬件和网络。

### 3.6 重启

安装完成后：
1. 拔出 USB
2. 点击"重启"
3. 启动时会出现 GRUB 菜单
4. 选择 "FluentOS" 进入新系统

---

## 4. 单系统安装步骤

如果整台电脑只装 FluentOS：

### 4.1 启动安装程序
同双系统步骤 3.1-3.3

### 4.2 分区选择
选择"使用整个磁盘"：
- 自动分区
- 自动创建 EFI 和 Root 分区
- ⚠️ 会删除硬盘上所有数据！

### 4.3 完成安装
同双系统步骤 3.5-3.6

---

## 5. 安装后优化配置

### 5.1 第一次启动

首次启动后会看到欢迎界面：
- 连接网络
- 选择主题（浅色/深色）
- 配置输入法
- 导入 Windows 数据（可选）

### 5.2 系统更新

```bash
# 同步数据库并更新
sudo pacman -Syu

# 如果有 keyring 错误
sudo pacman -S --noconfirm archlinux-keyring
sudo pacman -Syu
```

### 5.3 配置国内镜像源

```bash
# 编辑镜像列表
sudo nano /etc/pacman.d/mirrorlist

# 将以下内容添加到最前面
## 清华大学
Server = https://mirrors.tuna.tsinghua.edu.cn/archlinux/$repo/os/$arch
## 阿里云
Server = https://mirrors.aliyun.com/archlinux/$repo/os/$arch
## 中科大
Server = https://mirrors.ustc.edu.cn/archlinux/$repo/os/$arch

# 保存并退出（Ctrl+O, Enter, Ctrl+X）
# 更新数据库
sudo pacman -Syy
```

### 5.4 启用 AUR (Arch User Repository)

```bash
# 安装 yay (AUR 助手)
sudo pacman -S --noconfirm base-devel git
cd /tmp
git clone https://aur.archlinux.org/yay.git
cd yay
makepkg -si

# 配置 AUR 国内镜像
yay --aururl "https://aur.tuna.tsinghua.edu.cn" --save
```

### 5.5 配置中文输入法

```bash
# 安装 fcitx5
sudo pacman -S --noconfirm fcitx5 fcitx5-chewing fcitx5-qt fcitx5-gtk fcitx5-configtool fcitx5-chinese-addons

# 配置环境变量
echo 'export GTK_IM_MODULE=fcitx' >> ~/.pam_environment
echo 'export QT_IM_MODULE=fcitx' >> ~/.pam_environment
echo 'export XMODIFIERS=@im=fcitx' >> ~/.pam_environment

# 启用 fcitx5 自动启动
cp /usr/share/applications/org.fcitx.Fcitx5.desktop ~/.config/autostart/
```

---

## 6. 驱动安装指南

### 6.1 Intel 显卡（核显）

```bash
# 安装 Intel 显卡驱动
sudo pacman -S --noconfirm mesa intel-media-driver libva-intel-driver vulkan-intel

# 4代 Intel (Haswell) 需要的额外包
sudo pacman -S --noconfirm xf86-video-intel
```

### 6.2 NVIDIA 显卡

```bash
# 检查显卡型号
lspci | grep -i nvidia

# 安装 NVIDIA 驱动（最新）
sudo pacman -S --noconfirm nvidia nvidia-utils nvidia-settings

# 较老显卡 (700系列及以下) 用 470xx
sudo pacman -S --noconfirm nvidia-470xx-dkms nvidia-470xx-utils

# 生成配置
sudo nvidia-xconfig
```

### 6.3 AMD 显卡

```bash
# 安装 AMD 显卡驱动
sudo pacman -S --noconfirm mesa xf86-video-amdgpu vulkan-radeon libva-mesa-driver mesa-vdpau
```

### 6.4 声卡

```bash
# 安装声卡驱动
sudo pacman -S --noconfirm alsa-utils pulseaudio pulseaudio-alsa pavucontrol

# 测试
speaker-test -c 2
```

### 6.5 无线网卡

```bash
# 查看网卡型号
lspci | grep -i network

# Broadcom
sudo pacman -S --noconfirm broadcom-wl-dkms

# Realtek
sudo pacman -S --noconfirm rtl8821cu-dkms

# Intel
sudo pacman -S --noconfirm linux-firmware iwlwifi-uci
```

### 6.6 蓝牙

```bash
# 安装蓝牙
sudo pacman -S --noconfirm bluez bluez-utils bluedevil
sudo systemctl enable --now bluetooth
```

---

## 7. 常用软件安装

### 7.1 办公软件

```bash
# LibreOffice
sudo pacman -S --noconfirm libreoffice-fresh libreoffice-fresh-zh-cn

# WPS (AUR)
yay -S wps-office ttf-wps-fonts

# 输入法
sudo pacman -S --noconfirm fcitx5 fcitx5-chewing fcitx5-chinese-addons
```

### 7.2 浏览器

```bash
# Firefox
sudo pacman -S --noconfirm firefox firefox-i18n-zh-cn

# Chrome (AUR)
yay -S google-chrome

# Edge (AUR)
yay -S microsoft-edge-stable-bin
```

### 7.3 媒体播放

```bash
# VLC
sudo pacman -S --noconfirm vlc

# MPV
sudo pacman -S --noconfirm mpv

# 音乐播放器
sudo pacman -S --noconfirm elisa audacious
```

### 7.4 图像编辑

```bash
# GIMP (PS 替代)
sudo pacman -S --noconfirm gimp

# 截图工具
sudo pacman -S --noconfirm spectacle flameshot

# 图像查看
sudo pacman -S --noconfirm gwenview
```

### 7.5 开发工具

```bash
# VS Code (AUR)
yay -S visual-studio-code-bin

# 基础开发工具
sudo pacman -S --noconfirm base-devel gcc make cmake git vim

# Python
sudo pacman -S --noconfirm python python-pip

# Node.js
sudo pacman -S --noconfirm nodejs npm

# Java
sudo pacman -S --noconfirm jdk-openjdk
```

### 7.6 聊天软件

```bash
# Discord
sudo pacman -S --noconfirm discord

# Telegram
sudo pacman -S --noconfirm telegram-desktop

# QQ (AUR)
yay -S linuxqq

# 微信 (AUR)
yay -S wechat-uos
```

### 7.7 游戏

```bash
# Steam
sudo pacman -S --noconfirm steam

# Lutris (游戏管理器)
sudo pacman -S --noconfirm lutris

# Wine
sudo pacman -S --noconfirm wine wine-mono wine-gecko winetricks
```

---

## 8. 性能调优

### 8.1 开启性能模式

打开 **控制面板 → 系统 → 性能**：
- 选择"性能模式"（默认）
- 关闭桌面特效
- 禁用动画

### 8.2 系统服务优化

```bash
# 查看启动时间
systemd-analyze blame

# 禁用不必要的服务
sudo systemctl disable avahi-daemon
sudo systemctl disable cups  # 如果不用打印机

# 启用 zram (压缩内存，适合小内存)
sudo pacman -S --noconfirm zram-generator
sudo tee /etc/systemd/zram-generator.conf << 'EOF'
[zram0]
zram-size = ram / 2
compression-algorithm = zstd
EOF
sudo systemctl daemon-reload
sudo systemctl start systemd-zram-setup@zram0.service
```

### 8.3 SSD 优化

```bash
# 启用 TRIM
sudo systemctl enable --now fstrim.timer

# 添加 noatime 挂载选项
sudo nano /etc/fstab
# 在 ext4 分区添加 noatime
# UUID=xxx / ext4 defaults,noatime 0 1
```

### 8.4 内存优化

```bash
# 调整 swappiness
echo 'vm.swappiness=10' | sudo tee /etc/sysctl.d/99-swappiness.conf

# 应用
sudo sysctl --system
```

### 8.5 内核参数优化

```bash
sudo nano /etc/sysctl.d/99-fluentos.conf

# 添加以下内容
vm.dirty_ratio = 10
vm.dirty_background_ratio = 5
vm.vfs_cache_pressure = 50
net.core.somaxconn = 1024
net.ipv4.tcp_fastopen = 3

# 应用
sudo sysctl --system
```

---

## 9. 故障排除

### 9.1 无法启动 Windows

如果 GRUB 中看不到 Windows：

```bash
# 安装 os-prober
sudo pacman -S --noconfirm os-prober

# 启用 os-prober
echo 'GRUB_DISABLE_OS_PROBER=false' | sudo tee -a /etc/default/grub

# 更新 GRUB
sudo grub-mkconfig -o /boot/grub/grub.cfg
```

### 9.2 分辨率不对

```bash
# 查看显示器信息
xrandr

# 设置分辨率
xrandr --output HDMI-1 --mode 1920x1080
```

### 9.3 没有声音

```bash
# 检查声卡
aplay -l

# 取消静音
alsamixer
# 按 M 取消静音，用方向键调整音量

# 如果是 PulseAudio
pavucontrol
```

### 9.4 网络连不上

```bash
# 查看网络接口
ip addr

# 重启网络服务
sudo systemctl restart NetworkManager

# 查看无线网卡
rfkill list
rfkill unblock wifi
```

### 9.5 系统启动慢

```bash
# 分析启动时间
systemd-analyze
systemd-analyze blame
systemd-analyze critical-chain

# 禁用慢的服务
sudo systemctl disable 服务名
```

### 9.6 进入紧急模式

如果启动失败进入紧急模式：
1. 检查 `/etc/fstab` 是否正确
2. 检查磁盘是否损坏
3. 从 Live USB 启动修复

---

## 10. 备份和恢复

### 10.1 系统备份

```bash
# 使用 timeshift 备份系统
sudo pacman -S --noconfirm timeshift
sudo timeshift --create --comments "Initial backup"
```

### 10.2 数据备份

```bash
# 使用 rsync 备份
rsync -avz /home/用户名 /mnt/backup/

# 或使用 deja-dup (图形化)
sudo pacman -S --noconfirm deja-dup
```

---

## 附录：快速命令参考

```bash
# 系统更新
sudo pacman -Syu

# 安装软件
sudo pacman -S 软件名

# 搜索软件
pacman -Ss 关键词

# 卸载软件
sudo pacman -Rns 软件名

# 清理缓存
sudo pacman -Sc

# 查看系统信息
neofetch

# 查看进程
htop

# 查看磁盘
df -h
```

---

**FluentOS 实体机配置方案 v1.0**
项目地址: https://github.com/sans65-ch/FluentOS
