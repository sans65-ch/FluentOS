#!/bin/bash
# Windows 分区挂载脚本
# 在 chroot 环境中运行

set -e

echo "Configuring Windows mount points..."

# 创建 Windows 挂载点
mkdir -p /mnt/windows

# 获取 Windows 分区 UUID
WINDOWS_UUID=$(blkid -s UUID -o value /dev/sda1 2>/dev/null || echo "")

if [ -n "$WINDOWS_UUID" ]; then
    # 添加到 fstab
    echo "UUID=$WINDOWS_UUID /mnt/windows ntfs-3g rw,uid=1000,gid=1000,umask=022 0 0" >> /etc/fstab
    echo "Windows partition added to fstab"
else
    echo "Warning: Windows partition not found"
fi

# 创建符号链接方便访问 Windows 程序
ln -sf /mnt/windows/Program\ Files /home/*/WindowsPrograms 2>/dev/null || true
ln -sf /mnt/windows/ProgramData/Microsoft/Windows/Start\ Menu/Programs ~/StartMenu 2>/dev/null || true

echo "Windows mount configuration completed"
