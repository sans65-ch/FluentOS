# FluentOS Live 环境用户配置
# 此文件在 Live 环境启动时执行

#!/bin/bash

set -e

# ===== 配置主机名 =====
echo "fluentos-live" > /etc/hostname

# ===== 配置 hosts =====
cat > /etc/hosts << EOF
127.0.0.1   localhost
::1         localhost
127.0.1.1   fluentos-live.localdomain fluentos-live
EOF

# ===== 创建 live 用户 =====
useradd -m -G wheel,video,audio,storage,optical,network,power -s /bin/bash live
echo "live:live" | chpasswd

# ===== 配置 sudo =====
cat > /etc/sudoers.d/live << EOF
live ALL=(ALL) NOPASSWD: ALL
EOF
chmod 0440 /etc/sudoers.d/live

# ===== 配置 locale =====
sed -i 's/#en_US.UTF-8 UTF-8/en_US.UTF-8 UTF-8/' /etc/locale.gen
sed -i 's/#zh_CN.UTF-8 UTF-8/zh_CN.UTF-8 UTF-8/' /etc/locale.gen
locale-gen

echo "LANG=en_US.UTF-8" > /etc/locale.conf
echo "LC_ALL=C" >> /etc/locale.conf

# ===== 配置时区 =====
ln -sf /usr/share/zoneinfo/Asia/Shanghai /etc/localtime
hwclock --systohc --utc

# ===== 配置键盘布局 =====
echo "KEYMAP=us" > /etc/vconsole.conf

# ===== 启用网络服务 =====
systemctl enable NetworkManager
systemctl enable sshd

# ===== 配置 SDDM =====
systemctl enable sddm

# ===== 配置默认运行级别 =====
systemctl set-default graphical.target

# ===== FluentOS 自定义配置 =====

# 复制主题文件
mkdir -p /usr/share/fluentos
cp -r /root/airootfs/usr/share/fluentos/* /usr/share/fluentos/ 2>/dev/null || true

# 配置默认壁纸
mkdir -p /usr/share/backgrounds
cp /usr/share/fluentos/wallpapers/default.jpg /usr/share/backgrounds/fluentos-default.jpg 2>/dev/null || true

# 配置 KDE 全局主题
mkdir -p /etc/xdg
cat > /etc/xdg/plasma-workspace/env/fluentos.sh << EOF
#!/bin/sh
export QT_QPA_PLATFORMTHEME=kde
export KDE_FULL_SESSION=true
EOF

chmod +x /etc/xdg/plasma-workspace/env/fluentos.sh

# 配置默认面板布局
mkdir -p /etc/xdg/plasma-default-layout
cat > /etc/xdg/plasma-default-layout/org.kde.plasma.desktop-default-appletsrc << 'EOF'
[Containments][1]
activityId=
formfactor=horizontal
immutability=1
lastScreen=0
location=6
plugin=org.kde.panel
wallpaperplugin=org.kde.image

[Containments][1][Applets][1]
plugin=org.kde.plasma.kicker

[Containments][1][Applets][2]
plugin=org.kde.plasma.pager

[Containments][1][Applets][3]
plugin=org.kde.plasma.taskmanager

[Containments][1][Applets][4]
plugin=org.kde.plasma.systemtray

[Containments][1][Applets][5]
plugin=org.kde.plasma.digitalclock

[Containments][1][Applets][6]
plugin=org.kde.plasma.showdesktop

[Containments][1][General]
AppletOrder=1;2;3;4;5;6
EOF

# ===== 配置欢迎界面 =====
mkdir -p /etc/skel/.config/autostart
cat > /etc/skel/.config/autostart/fluentos-welcome.desktop << 'EOF'
[Desktop Entry]
Type=Application
Name=FluentOS Welcome
Comment=Welcome to FluentOS
Exec=fluentos-welcome
OnlyShowIn=KDE;
X-KDE-autostart-after=panel
EOF

# ===== 启用 aurman/yay =====
# 注意：AUR 助手需要在 chroot 外单独构建

echo "FluentOS Live environment configured successfully!"
