# FluentOS - 从 Windows 安装脚本
# 此脚本允许在 Windows 环境中安装 FluentOS
# 使用方法: 在 Windows 中以管理员身份运行 install-from-windows.bat

@echo off
setlocal enabledelayedexpansion

echo ========================================
echo   FluentOS Installer for Windows
echo   基于 Arch Linux 的仿 Windows 系统
echo ========================================
echo.

:: 检查管理员权限
net session >nul 2>&1
if %errorLevel% neq 0 (
    echo [错误] 请以管理员身份运行此脚本！
    echo 右键点击文件，选择"以管理员身份运行"
    pause
    exit /b 1
)

:: 检查系统架构
if "%PROCESSOR_ARCHITECTURE%"=="AMD64" (
    set ARCH=x64
    echo [信息] 检测到 64 位系统
) else (
    echo [错误] FluentOS 仅支持 64 位系统
    pause
    exit /b 1
)

:: 检查磁盘空间
echo [信息] 检查磁盘空间...
for /f "tokens=3" %%a in ('dir /-c "%SystemDrive%\" ^| find "bytes free"') do set FREE_SPACE=%%a
set FREE_SPACE=%FREE_SPACE:,=%
set MIN_SPACE=20000000000

if %FREE_SPACE% lss %MIN_SPACE% (
    echo [警告] 可用空间不足 20GB，可能影响安装
    echo.
    set /p CONTINUE=是否继续？(y/n): 
    if /i not "!CONTINUE!"=="y" (
        echo 安装已取消
        pause
        exit /b 0
    )
) else (
    echo [信息] 磁盘空间充足
)

echo.
echo ========================================
echo   安装选项
echo ========================================
echo.
echo   1. 与 Windows 共存安装 (推荐)
echo   2. 完全替换 Windows
echo   3. 仅创建 Live USB
echo   4. 退出
echo.
set /p CHOICE=请选择安装方式 [1-4]: 

if "%CHOICE%"=="1" goto dual_boot
if "%CHOICE%"=="2" goto full_install
if "%CHOICE%"=="3" goto live_usb
if "%CHOICE%"=="4" goto end

echo [错误] 无效选项
pause
exit /b 1

:dual_boot
echo.
echo ========================================
echo   双系统安装
echo ========================================
echo.
echo [信息] 将在 Windows 旁安装 FluentOS
echo [信息] 安装完成后可通过启动菜单选择系统
echo.
echo [警告] 请确保已备份重要数据！
echo.
set /p CONFIRM=确认开始安装？(y/n): 
if /i not "%CONFIRM%"=="y" goto end

:: 检查是否有 EFI 分区
if exist "%SystemDrive%\EFI" (
    echo [信息] 检测到 EFI 系统分区
) else (
    echo [信息] 未检测到 EFI 分区，将创建新分区
)

:: 创建安装分区
echo [信息] 准备分区...
echo [信息] 建议分配至少 20GB 空间给 FluentOS

:: 使用 diskpart 收缩分区创建空间
echo list volume | diskpart >nul 2>&1

echo.
echo [信息] 请手动使用磁盘管理工具缩小 C: 盘
echo [信息] 缩小完成后重新运行此脚本
echo.
echo 提示: 右键"此电脑" -> "管理" -> "磁盘管理"
echo       右键 C: 盘 -> "压缩卷"
pause
goto end

:full_install
echo.
echo ========================================
echo   完全替换 Windows
echo ========================================
echo.
echo [警告] 此操作将删除所有 Windows 数据！
echo [警告] 请确保已备份所有重要文件！
echo.
set /p CONFIRM=确认完全替换 Windows？(yes/n): 
if /i not "%CONFIRM%"=="yes" goto end

echo [信息] 准备完全安装...
echo [信息] 系统将重启并进入 Live 环境
pause
goto end

:live_usb
echo.
echo ========================================
echo   创建 Live USB
echo ========================================
echo.
echo [信息] 请插入 USB 驱动器 (至少 4GB)
echo.
pause

:: 列出可用驱动器
echo list disk | diskpart

echo.
set /p USB_DISK=请输入 USB 驱动器编号: 

echo.
echo [警告] 将删除 USB 驱动器上的所有数据！
set /p CONFIRM=确认继续？(yes/n): 
if /i not "%CONFIRM%"=="yes" goto end

:: 使用 Rufus 或 diskpart 写入
echo [信息] 正在准备 USB 驱动器...

:: 检查 ISO 文件是否存在
set ISO_FILE=%~dp0FluentOS-1.0.0-x86_64.iso
if not exist "%ISO_FILE%" (
    echo [错误] 未找到 ISO 文件: %ISO_FILE%
    echo [信息] 请确保 ISO 文件与此脚本在同一目录
    pause
    exit /b 1
)

echo [信息] 找到 ISO 文件: %ISO_FILE%
echo [信息] ISO 文件大小: 
dir "%ISO_FILE%" | find "FluentOS"

echo.
echo [信息] 请使用 Rufus 或 Etcher 将 ISO 写入 USB
echo [信息] 下载地址:
echo       - Rufus: https://rufus.ie/
echo       - Etcher: https://etcher.balena.io/
echo.
pause
goto end

:end
echo.
echo ========================================
echo   安装程序已退出
echo ========================================
echo.
echo 感谢使用 FluentOS 安装程序
echo.
pause
exit /b 0
