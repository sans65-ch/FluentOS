#!/bin/bash
# FluentOS 发布脚本
# 自动构建、测试、发布 FluentOS

set -e

# 配置
PROJECT_NAME="FluentOS"
VERSION="1.0.0"
ARCH="x86_64"
GITHUB_USER="sans65-ch"
GITHUB_REPO="FluentOS"
OUTPUT_DIR="out"
BUILD_DIR="build"
RELEASE_DIR="release"

# 颜色
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

info() { echo -e "${BLUE}[INFO]${NC} $1"; }
success() { echo -e "${GREEN}[SUCCESS]${NC} $1"; }
warn() { echo -e "${YELLOW}[WARNING]${NC} $1"; }
error() { echo -e "${RED}[ERROR]${NC} $1"; }

# 检查依赖
check_dependencies() {
    info "检查依赖..."

    local missing=()

    if ! command -v git &> /dev/null; then
        missing+=("git")
    fi

    if ! command -v gh &> /dev/null; then
        missing+=("gh (GitHub CLI)")
    fi

    if ! command -v sha256sum &> /dev/null; then
        missing+=("sha256sum")
    fi

    if [ ${#missing[@]} -gt 0 ]; then
        error "缺少依赖: ${missing[*]}"
        exit 1
    fi

    success "所有依赖已满足"
}

# 检查 Git 状态
check_git_status() {
    info "检查 Git 状态..."

    if ! git rev-parse --git-dir &> /dev/null; then
        error "当前目录不是 Git 仓库"
        exit 1
    fi

    if [ -n "$(git status --porcelain)" ]; then
        warn "存在未提交的更改"
        git status --short
        read -p "是否继续？(y/n) " -n 1 -r
        echo
        if [[ ! $REPLY =~ ^[Yy]$ ]]; then
            exit 0
        fi
    fi

    success "Git 状态检查通过"
}

# 创建发布目录
prepare_release() {
    info "准备发布目录..."

    rm -rf "${RELEASE_DIR}"
    mkdir -p "${RELEASE_DIR}"

    success "发布目录已创建: ${RELEASE_DIR}"
}

# 构建 ISO
build_iso() {
    info "构建 ISO..."

    if [ ! -f "${OUTPUT_DIR}/${PROJECT_NAME}-${VERSION}-${ARCH}.iso" ]; then
        warn "ISO 文件不存在，开始构建..."
        sudo ./iso/build.sh
    else
        info "ISO 文件已存在"
    fi

    # 复制到发布目录
    cp "${OUTPUT_DIR}/${PROJECT_NAME}-${VERSION}-${ARCH}.iso" "${RELEASE_DIR}/"
    cp "${OUTPUT_DIR}/${PROJECT_NAME}-${VERSION}-${ARCH}.iso.sha256" "${RELEASE_DIR}/"

    success "ISO 已准备好"
}

# 生成发布说明
generate_release_notes() {
    info "生成发布说明..."

    local notes_file="${RELEASE_DIR}/RELEASE_NOTES.md"

    cat > "${notes_file}" << 'EOF'
# FluentOS 1.0.0 发布说明

## 概述

FluentOS 是一个基于 Arch Linux 的仿 Windows 桌面操作系统，采用 Fluent Design 设计语言和液态玻璃效果，提供从 Windows 到 Linux 的无缝过渡体验。

## 主要特性

### 🖥️ 桌面环境
- 高度 Windows 风格的操作界面
- 任务栏、开始菜单、资源管理器完整还原
- Fluent + 液态玻璃视觉效果
- 支持浅色/深色主题切换

### ⚡ 性能优化
- 针对低配置硬件优化（4代i3可流畅运行）
- 特效默认关闭，可按需开启
- 内存占用低（空闲 < 400MB）

### 🔄 双系统支持
- 直接访问 Windows 分区和程序
- Windows 程序快速启动
- 优秀的多系统引导体验

### 🛠️ 安装程序
- 支持从 Windows 直接安装
- 支持 Live USB 安装
- 图形化安装界面 (Calamares)

### 🎨 视觉效果
- Fluent Design 主题
- 亚克力/云母材质效果
- 液态玻璃动效
- 流畅的过渡动画

## 系统要求

### 最低配置
- CPU: Intel Core i3-4xxx / AMD 同级别
- 内存: 2 GB RAM
- 显卡: 集成显卡即可
- 存储: 20 GB 可用空间
- 网络: 可选（用于更新）

### 推荐配置
- CPU: Intel Core i5-4xxx 及以上
- 内存: 4 GB RAM
- 显卡: 支持 OpenGL 3.3
- 存储: 40 GB SSD
- 网络: 宽带连接

## 下载和安装

### 方式一: Live USB 安装（推荐）
1. 下载 ISO 文件
2. 使用 Rufus/Etcher 写入 USB
3. 从 USB 启动
4. 运行安装程序

### 方式二: 从 Windows 安装
1. 下载 ISO 和安装脚本
2. 以管理员身份运行 install-from-windows.bat
3. 按提示操作

## 已知问题

- 部分 Windows 应用可能无法完美兼容
- 某些特效需要较新的硬件支持
- 双系统安装需要手动分区

## 反馈和支持

- GitHub Issues: https://github.com/sans65-ch/FluentOS/issues
- 项目主页: https://github.com/sans65-ch/FluentOS

## 许可证

FluentOS 基于 GPL-3.0 许可证开源。
EOF

    success "发布说明已生成: ${notes_file}"
}

# 创建 Git tag
create_git_tag() {
    info "创建 Git 标签 v${VERSION}..."

    if git rev-parse "v${VERSION}" &> /dev/null; then
        warn "标签 v${VERSION} 已存在"
        read -p "是否删除并重新创建？(y/n) " -n 1 -r
        echo
        if [[ $REPLY =~ ^[Yy]$ ]]; then
            git tag -d "v${VERSION}"
            git push origin ":v${VERSION}" 2>/dev/null || true
        else
            return
        fi
    fi

    git tag -a "v${VERSION}" -m "FluentOS ${VERSION} release"
    git push origin "v${VERSION}"

    success "Git 标签已创建并推送"
}

# 发布到 GitHub
publish_to_github() {
    info "发布到 GitHub..."

    local iso_file="${RELEASE_DIR}/${PROJECT_NAME}-${VERSION}-${ARCH}.iso"
    local checksum_file="${RELEASE_DIR}/${PROJECT_NAME}-${VERSION}-${ARCH}.iso.sha256"
    local notes_file="${RELEASE_DIR}/RELEASE_NOTES.md"

    # 检查文件
    if [ ! -f "$iso_file" ]; then
        error "ISO 文件不存在: $iso_file"
        exit 1
    fi

    # 创建 GitHub Release
    info "创建 GitHub Release v${VERSION}..."

    gh release create "v${VERSION}" \
        --title "FluentOS ${VERSION}" \
        --notes-file "$notes_file" \
        "$iso_file" \
        "$checksum_file"

    success "已发布到 GitHub: https://github.com/${GITHUB_USER}/${GITHUB_REPO}/releases/tag/v${VERSION}"
}

# 显示发布摘要
show_release_summary() {
    echo ""
    echo "=========================================="
    echo "  FluentOS ${VERSION} 发布完成"
    echo "=========================================="
    echo ""
    echo "  版本: ${VERSION}"
    echo "  架构: ${ARCH}"
    echo ""

    if [ -f "${RELEASE_DIR}/${PROJECT_NAME}-${VERSION}-${ARCH}.iso" ]; then
        local size=$(du -h "${RELEASE_DIR}/${PROJECT_NAME}-${VERSION}-${ARCH}.iso" | cut -f1)
        echo "  ISO 文件: ${PROJECT_NAME}-${VERSION}-${ARCH}.iso"
        echo "  文件大小: $size"
    fi

    echo ""
    echo "  下载地址: https://github.com/${GITHUB_USER}/${GITHUB_REPO}/releases/tag/v${VERSION}"
    echo ""
    echo "=========================================="
}

# 显示帮助
show_help() {
    echo "FluentOS 发布脚本"
    echo ""
    echo "用法: $0 [选项]"
    echo ""
    echo "选项:"
    echo "  --build        构建 ISO"
    echo "  --release      发布到 GitHub"
    echo "  --all          构建并发布"
    echo "  --tag-only     仅创建 Git 标签"
    echo "  --notes-only   仅生成发布说明"
    echo "  -h, --help     显示帮助信息"
    echo ""
    echo "示例:"
    echo "  $0 --all           # 构建并发布"
    echo "  $0 --build         # 仅构建"
    echo "  $0 --release       # 仅发布（需要已构建的 ISO）"
}

# 主函数
main() {
    local action="all"

    while [[ $# -gt 0 ]]; do
        case $1 in
            --build)
                action="build"
                shift
                ;;
            --release)
                action="release"
                shift
                ;;
            --all)
                action="all"
                shift
                ;;
            --tag-only)
                action="tag"
                shift
                ;;
            --notes-only)
                action="notes"
                shift
                ;;
            -h|--help)
                show_help
                exit 0
                ;;
            *)
                error "未知选项: $1"
                show_help
                exit 1
                ;;
        esac
    done

    # 切换到项目根目录
    cd "$(dirname "$0")/.."

    case $action in
        build)
            check_dependencies
            check_git_status
            prepare_release
            build_iso
            show_release_summary
            ;;
        release)
            check_dependencies
            check_git_status
            prepare_release
            build_iso
            generate_release_notes
            create_git_tag
            publish_to_github
            show_release_summary
            ;;
        all)
            check_dependencies
            check_git_status
            prepare_release
            build_iso
            generate_release_notes
            create_git_tag
            publish_to_github
            show_release_summary
            ;;
        tag)
            check_dependencies
            check_git_status
            create_git_tag
            ;;
        notes)
            prepare_release
            generate_release_notes
            ;;
    esac
}

main "$@"
