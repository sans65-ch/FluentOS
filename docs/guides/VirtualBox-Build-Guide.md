# FluentOS ISO 构建指南

本文档详细说明如何在 VirtualBox 中构建 FluentOS ISO。

## 准备工作

### 需要下载的文件

1. **VirtualBox** (Windows 主机需要)
   - 下载地址: https://www.virtualbox.org/wiki/Downloads
   - 选择 "Windows hosts" 版本

2. **Arch Linux ISO**
   - 下载地址: https://archlinux.org/download/
   - 选择离你最近的镜像站

3. **FluentOS 源码** (在 VirtualBox 中克隆)
   - 仓库地址: https://github.com/sans65-ch/FluentOS.git

---

## 第一步：安装 VirtualBox

### 1.1 安装 VirtualBox

1. 运行下载的 `VirtualBox-*.exe` 安装程序
2. 按照向导完成安装（保持默认设置）
3. 安装完成后启动 VirtualBox

### 1.2 安装 VirtualBox 扩展包（可选但推荐）

1. 下载地址: https://download.virtualbox.org/virtualbox/VERSION/Oracle_VM_VirtualBox_Extension_Pack
2. 打开 VirtualBox -> 文件 -> 全局设定 -> 扩展
3. 点击"添加新扩展包"按钮
4. 选择下载的扩展包文件并安装

---

## 第二步：创建虚拟机

### 2.1 新建虚拟机

1. 点击 VirtualBox 主界面的"新建"按钮
2. 配置虚拟机：

```
名称: FluentOS-Build
操作系统: Linux
版本: Arch Linux (64-bit)
内存大小: 4096 MB (推荐 4GB)
硬盘: 现在创建虚拟硬盘
```

3. 点击"下一步"

### 2.2 配置硬盘

```
硬盘文件类型: VDI (VirtualBox 磁盘镜像)
存储方式: 动态分配
文件大小: 80 GB (推荐，因为要构建 ISO)
```

4. 点击"创建"

### 2.3 配置虚拟机设置

1. 选中刚创建的虚拟机，点击"设置"
2. **系统 -> 处理器**: 分配 4 个 CPU（如果可用）
3. **系统 -> 加速**: 启用 PAE/NX
4. **存储 -> 控制器(IDE)**: 选择"空"，点击右侧光盘图标
5. 选择"选择一个虚拟光盘文件"，加载 Arch Linux ISO
6. **网络 -> 桥接模式**: 这样可以访问 GitHub
7. 点击"确定"

---

## 第三步：安装 Arch Linux

### 3.1 启动虚拟机

1. 选中 FluentOS-Build 虚拟机
2. 点击"启动"按钮
3. 等待虚拟机从 Arch Linux ISO 启动

### 3.2 分区和挂载

在虚拟机中运行以下命令：

```bash
# 查看磁盘
lsblk

# 假设使用 /dev/sda 作为系统盘
# 分区方案： EFI + Root
cfdisk /dev/sda

# 创建 GPT 分区表后，创建以下分区：
# /dev/sda1: EFI 分区, 512M, 类型 EFI System
# /dev/sda2: Root 分区, 剩余空间, 类型 Linux filesystem

# 格式化分区
mkfs.fat -F32 /dev/sda1
mkfs.ext4 /dev/sda2

# 挂载分区
mount /dev/sda2 /mnt
mkdir /mnt/boot
mount /dev/sda1 /mnt/boot
```

### 3.3 安装基础系统

```bash
# 编辑镜像源（选择较快的源）
nano /etc/pacman.d/mirrorlist

# 添加中国镜像源（在文件顶部）
Server = https://mirrors.tuna.tsinghua.edu.cn/archlinux/$repo/os/$arch
Server = https://mirrors.aliyun.com/archlinux/$repo/os/$arch

# 安装基础系统
pacstrap /mnt base base-devel linux linux-firmware vim git sudo

# 生成分区表
genfstab -U /mnt >> /mnt/etc/fstab

# 进入新系统
arch-chroot /mnt
```

### 3.4 配置新系统

```bash
# 设置时区
ln -sf /usr/share/zoneinfo/Asia/Shanghai /etc/localtime
hwclock --systohc --utc

# 设置 locale
echo "en_US.UTF-8 UTF-8" >> /etc/locale.gen
echo "zh_CN.UTF-8 UTF-8" >> /etc/locale.gen
locale-gen
echo "LANG=en_US.UTF-8" > /etc/locale.conf

# 设置主机名
echo "fluentos-build" > /etc/hostname

# 设置 root 密码
passwd

# 安装 GRUB
pacman -S --noconfirm grub efibootmgr
grub-install --target=x86_64-efi --efi-directory=/boot --bootloader-id=GRUB
grub-mkconfig -o /boot/grub/grub.cfg

# 退出并重启
exit
reboot
```

---

## 第四步：克隆和构建 FluentOS

### 4.1 重新启动后，登录 root

使用之前设置的 root 密码登录。

### 4.2 克隆 FluentOS 源码

```bash
# 安装网络工具（如果需要）
pacman -S --noconfirm networkmanager
systemctl enable NetworkManager
systemctl start NetworkManager

# 克隆仓库
git clone https://github.com/sans65-ch/FluentOS.git
cd FluentOS

# 或者如果你有 SSH key
git clone git@github.com:sans65-ch/FluentOS.git
cd FluentOS
```

### 4.3 安装构建依赖

```bash
# 安装 archiso
pacman -S --noconfirm archiso

# 安装 KDE 和 Qt5（用于 Shell）
pacman -S --noconfirm plasma kde-applications

# 安装编译工具
pacman -S --noconfirm cmake extra-cmake-modules gcc make
pacman -S --noconfirm qt5-base qt5-declarative qt5-quickcontrols2 qt5-graphicaleffects

# 安装其他依赖
pacman -S --noconfirm python python-pip ntfs-3g wine
```

### 4.4 构建 ISO

```bash
# 进入项目目录
cd FluentOS

# 给脚本添加执行权限
chmod +x iso/build.sh
chmod +x scripts/release.sh

# 构建 ISO
./iso/build.sh
```

构建过程可能需要 30-60 分钟，取决于网络和硬件。

### 4.5 等待构建完成

构建成功后会显示：

```
==========================================
  FluentOS ISO 构建完成
==========================================

  项目: FluentOS
  版本: 1.0.0
  架构: x86_64

  ISO 文件: out/FluentOS-1.0.0-x86_64.iso
  文件大小: X.XX GB

==========================================
```

---

## 第五步：获取 ISO 文件

### 5.1 共享文件夹（推荐）

1. 在 VirtualBox 中关闭虚拟机
2. 选中虚拟机 -> 设置 -> 共享文件夹
3. 添加一个共享文件夹，路径指向 Windows 某个目录，勾选"自动挂载"
4. 启动虚拟机

```bash
# 在虚拟机中挂载共享文件夹
mkdir /mnt/shared
mount -t vboxsf share /mnt/shared

# 复制 ISO 到共享文件夹
cp FluentOS/out/FluentOS-1.0.0-x86_64.iso /mnt/shared/
```

### 5.2 使用 SFTP 传输

```bash
# 在虚拟机中安装 openssh
pacman -S --noconfirm openssh
systemctl enable sshd
systemctl start sshd

# 获取 IP 地址
ip addr

# 在 Windows 中使用 FileZilla 或 scp 下载
scp username@IP:/home/username/FluentOS/out/FluentOS-1.0.0-x86_64.iso .
```

### 5.3 直接使用 VirtualBox 创建启动盘

1. 在 Windows 中使用 Rufus 将生成的 ISO 写入 USB
2. 虚拟机可以直接测试该 USB

---

## 第六步：测试 ISO

### 6.1 在虚拟机中测试

1. 将生成的 ISO 加载到虚拟机的虚拟光盘
2. 启动虚拟机
3. 选择 "FluentOS" 启动项
4. 测试 Live 环境

### 6.2 在真实硬件上测试

1. 使用 Rufus 将 ISO 写入 USB
2. 从 USB 启动电脑
3. 选择 "FluentOS (Default)" 或 "FluentOS (Try without installing)"

---

## 常见问题

### Q: 构建过程中网络断开？
```bash
# 重新连接网络
systemctl restart NetworkManager
# 重新克隆仓库
git pull
```

### Q: pacstrap 安装失败？
```bash
# 更新 pacman 密钥
pacman-key --init
pacman-key --populate archlinux
pacman -Sy --noconfirm archlinux-keyring
```

### Q: 构建脚本报错权限不足？
```bash
# 确保以 root 运行
sudo ./iso/build.sh
```

### Q: 如何加速构建？
- 使用 SSD 硬盘
- 增加虚拟机内存和 CPU
- 使用国内镜像源

---

## 下一步

ISO 构建完成后，你可以：

1. **创建 GitHub Release**：运行 `scripts/release.sh`
2. **测试 FluentOS**：在虚拟机或真机上运行
3. **提交贡献**：修复问题，添加功能

---

**祝构建顺利！**

FluentOS 项目: https://github.com/sans65-ch/FluentOS
