#!/bin/bash
# FluentOS GRUB Theme Installer
# 安装 FluentOS GRUB 主题

set -e

THEME_DIR="/boot/grub/themes/FluentOS"
SOURCE_DIR="/usr/share/fluentos/grub-theme"

echo "Installing FluentOS GRUB theme..."

# 检查是否为 root 用户
if [ "$EUID" -ne 0 ]; then
    echo "Please run as root (use sudo)"
    exit 1
fi

# 创建主题目录
mkdir -p "$THEME_DIR"

# 复制主题文件
cp -r "$SOURCE_DIR/"* "$THEME_DIR/"

# 设置权限
chmod -R 755 "$THEME_DIR"

# 更新 GRUB 配置
echo "Updating GRUB configuration..."

# 检测配置文件位置
if [ -f /etc/default/grub ]; then
    GRUB_DEFAULT_FILE="/etc/default/grub"
elif [ -f /etc/grub/default ]; then
    GRUB_DEFAULT_FILE="/etc/grub/default"
else
    echo "Error: Could not find GRUB default file"
    exit 1
fi

# 备份原配置
cp "$GRUB_DEFAULT_FILE" "${GRUB_DEFAULT_FILE}.bak"

# 添加主题配置
if ! grep -q "GRUB_THEME=" "$GRUB_DEFAULT_FILE"; then
    echo 'GRUB_THEME="/boot/grub/themes/FluentOS/theme.txt"' >> "$GRUB_DEFAULT_FILE"
fi

# 设置分辨率
if ! grep -q "GRUB_GFXMODE=" "$GRUB_DEFAULT_FILE"; then
    echo 'GRUB_GFXMODE="1280x720"' >> "$GRUB_DEFAULT_FILE"
fi

if ! grep -q "GRUB_GFXPAYLOAD_LINUX=" "$GRUB_DEFAULT_FILE"; then
    echo 'GRUB_GFXPAYLOAD_LINUX="keep"' >> "$GRUB_DEFAULT_FILE"
fi

# 重新生成 GRUB 配置
echo "Regenerating GRUB configuration..."

if command -v update-grub &> /dev/null; then
    update-grub
elif command -v grub-mkconfig &> /dev/null; then
    if [ -f /boot/grub/grub.cfg ]; then
        grub-mkconfig -o /boot/grub/grub.cfg
    elif [ -f /boot/efi/EFI/*/grub.cfg ]; then
        grub-mkconfig -o /boot/efi/EFI/*/grub.cfg
    fi
fi

echo "FluentOS GRUB theme installed successfully!"
echo "Theme directory: $THEME_DIR"
echo "Please reboot to see the new theme."
