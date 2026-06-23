#!/bin/bash
# FluentOS ISO 构建脚本
# 基于 Arch Linux archiso 工具构建

set -e

# 颜色定义
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

# 项目配置
PROJECT_NAME="FluentOS"
PROJECT_VERSION="1.0.0"
ARCH="x86_64"
OUTPUT_DIR="out"
WORK_DIR="work"

# 路径配置
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"
ISO_PROFILE_DIR="${PROJECT_ROOT}/iso"

# 打印信息
info() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

warn() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# 检查是否为 root
check_root() {
    if [ "$EUID" -ne 0 ]; then
        error "请使用 root 权限运行此脚本"
        error "使用: sudo $0"
        exit 1
    fi
}

# 检查 archiso 是否已安装
check_archiso() {
    if ! command -v mkarchiso &> /dev/null; then
        warn "archiso 未安装，正在安装..."
        pacman -Sy --noconfirm archiso
        success "archiso 安装完成"
    else
        info "archiso 已安装"
    fi
}

# 清理旧的构建文件
clean_build() {
    info "清理旧的构建文件..."
    if [ -d "${OUTPUT_DIR}" ]; then
        rm -rf "${OUTPUT_DIR}"
    fi
    if [ -d "${WORK_DIR}" ]; then
        rm -rf "${WORK_DIR}"
    fi
    success "清理完成"
}

# 准备构建环境
prepare_build() {
    info "准备构建环境..."

    # 创建输出目录
    mkdir -p "${OUTPUT_DIR}"
    mkdir -p "${WORK_DIR}"

    # 同步系统时间
    timedatectl set-ntp true 2>/dev/null || true

    success "构建环境准备完成"
}

# 复制自定义配置到 archiso
copy_custom_config() {
    info "复制自定义配置..."

    local releng_dir="${WORK_DIR}/releng"

    # 复制基础 releng 配置
    cp -r /usr/share/archiso/configs/releng/* "${releng_dir}/"

    # 复制 FluentOS 自定义配置
    if [ -d "${ISO_PROFILE_DIR}/airootfs" ]; then
        cp -r "${ISO_PROFILE_DIR}/airootfs"/* "${releng_dir}/airootfs/"
    fi

    # 复制软件包列表
    if [ -f "${ISO_PROFILE_DIR}/packages.x86_64" ]; then
        cp "${ISO_PROFILE_DIR}/packages.x86_64" "${releng_dir}/packages.x86_64"
    fi

    # 复制 pacman 配置
    if [ -f "${ISO_PROFILE_DIR}/pacman.conf" ]; then
        cp "${ISO_PROFILE_DIR}/pacman.conf" "${releng_dir}/pacman.conf"
    fi

    # 复制引导配置
    if [ -d "${ISO_PROFILE_DIR}/efiboot" ]; then
        cp -r "${ISO_PROFILE_DIR}/efiboot"/* "${releng_dir}/efiboot/"
    fi

    if [ -d "${ISO_PROFILE_DIR}/syslinux" ]; then
        cp -r "${ISO_PROFILE_DIR}/syslinux"/* "${releng_dir}/syslinux/"
    fi

    success "自定义配置复制完成"
}

# 构建 ISO
build_iso() {
    info "开始构建 FluentOS ISO..."
    info "版本: ${PROJECT_VERSION}"
    info "架构: ${ARCH}"

    local releng_dir="${WORK_DIR}/releng"

    # 使用 mkarchiso 构建
    mkarchiso -v -w "${WORK_DIR}/build" -o "${OUTPUT_DIR}" "${releng_dir}"

    if [ $? -eq 0 ]; then
        success "ISO 构建成功！"

        # 重命名 ISO 文件
        local iso_file=$(ls "${OUTPUT_DIR}"/*.iso 2>/dev/null | head -1)
        if [ -n "$iso_file" ]; then
            local new_name="${PROJECT_NAME}-${PROJECT_VERSION}-${ARCH}.iso"
            mv "$iso_file" "${OUTPUT_DIR}/${new_name}"
            success "ISO 文件: ${OUTPUT_DIR}/${new_name}"

            # 生成 SHA256 校验和
            info "生成 SHA256 校验和..."
            sha256sum "${OUTPUT_DIR}/${new_name}" > "${OUTPUT_DIR}/${new_name}.sha256"
            success "校验和已生成: ${OUTPUT_DIR}/${new_name}.sha256"
        fi
    else
        error "ISO 构建失败！"
        exit 1
    fi
}

# 显示构建信息
show_build_info() {
    echo ""
    echo "=========================================="
    echo "  FluentOS ISO 构建完成"
    echo "=========================================="
    echo ""
    echo "  项目: ${PROJECT_NAME}"
    echo "  版本: ${PROJECT_VERSION}"
    echo "  架构: ${ARCH}"
    echo ""

    if ls "${OUTPUT_DIR}"/*.iso &> /dev/null; then
        local iso_file=$(ls "${OUTPUT_DIR}"/*.iso | head -1)
        local file_size=$(du -h "$iso_file" | cut -f1)
        echo "  ISO 文件: $iso_file"
        echo "  文件大小: $file_size"
    fi

    if ls "${OUTPUT_DIR}"/*.sha256 &> /dev/null; then
        local checksum_file=$(ls "${OUTPUT_DIR}"/*.sha256 | head -1)
        echo "  校验文件: $checksum_file"
    fi

    echo ""
    echo "=========================================="
}

# 显示帮助
show_help() {
    echo "FluentOS ISO 构建脚本"
    echo ""
    echo "用法: $0 [选项]"
    echo ""
    echo "选项:"
    echo "  -b, --build       构建 ISO (默认)"
    echo "  -c, --clean       清理构建文件"
    echo "  -r, --rebuild     清理并重新构建"
    echo "  -v, --version     显示版本信息"
    echo "  -h, --help        显示此帮助信息"
    echo ""
    echo "示例:"
    echo "  sudo $0              # 构建 ISO"
    echo "  sudo $0 --clean      # 清理构建文件"
    echo "  sudo $0 --rebuild    # 清理并重新构建"
}

# 主函数
main() {
    local action="build"

    # 解析参数
    while [[ $# -gt 0 ]]; do
        case $1 in
            -b|--build)
                action="build"
                shift
                ;;
            -c|--clean)
                action="clean"
                shift
                ;;
            -r|--rebuild)
                action="rebuild"
                shift
                ;;
            -v|--version)
                echo "${PROJECT_NAME} ${PROJECT_VERSION}"
                exit 0
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

    # 执行操作
    case $action in
        build)
            check_root
            check_archiso
            prepare_build
            copy_custom_config
            build_iso
            show_build_info
            ;;
        clean)
            check_root
            clean_build
            ;;
        rebuild)
            check_root
            check_archiso
            clean_build
            prepare_build
            copy_custom_config
            build_iso
            show_build_info
            ;;
    esac
}

main "$@"
