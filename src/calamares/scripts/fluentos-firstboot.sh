#!/bin/bash
# FluentOS 安装后配置脚本
# 在首次启动时运行

set -e

echo "Running FluentOS firstboot configuration..."

# 设置默认主题
echo "Setting default theme..."
mkdir -p ~/.config
cat > ~/.config/kwinrc << 'EOF'
[Effect-settings]
GlassEffect=true
TransparentEffects=true
AnimationSpeed=3

[WindowResizing]
Enabled=true

[BorderlessMaximizedWindows]
HideBorder=true
EOF

# 设置任务栏布局
echo "Configuring taskbar..."
mkdir -p ~/.config/latte
cat > ~/.config/latte/fluentos.layout.latte << 'EOF'
[Layouts]
[Layouts][Default][Containments][1]
plugin=org.kde.latte.plasma
items=org.kde.latte.plasma.fallback
EOF

# 创建桌面快捷方式目录
mkdir -p ~/Desktop
mkdir -p ~/.local/share/applications

# 复制 Windows 程序启动器到菜单
mkdir -p ~/.local/share/kservices5
cp /usr/share/fluentos/kwin/WindowsProgramLauncher.kwinreg ~/

# 设置 SDDM 登录管理器主题
echo "Configuring SDDM..."
mkdir -p /etc/sddm.conf.d
cat > /etc/sddm.conf.d/fluentos.conf << 'EOF'
[Theme]
Current=breeze
CursorTheme=breeze_cursors
EOF

# 配置网络自动连接
echo "Configuring network..."
systemctl enable NetworkManager
systemctl start NetworkManager

# 设置时区
echo "Setting timezone..."
timedatectl set-timezone Asia/Shanghai
timedatectl set-ntp true

# 启用中文输入法
echo "Configuring input method..."
pacman -Sy --noconfirm fcitx5 fcitx5-chewing fcitx5-qt fcitx5-gtk

# 完成
echo "FluentOS firstboot completed successfully!"
