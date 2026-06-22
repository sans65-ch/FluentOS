# FluentOS

基于 Arch Linux 的仿 Windows 桌面操作系统

## 特性

- **Windows 操作逻辑高度兼容** - 任务栏、开始菜单、文件管理器完全仿Windows体验
- **Fluent + 液态玻璃设计** - 现代化丝滑动画效果（可选）
- **双系统文件共享** - 直接调用Windows分区中的程序
- **低配置友好** - 4代I3可流畅运行
- **双重安装方式** - 支持Windows内安装和Live USB安装

## 系统要求

### 最低配置 (性能模式)
- CPU: Intel Core i3 4代 或 AMD 同等
- 内存: 2GB RAM
- 存储: 20GB 可用空间
- 显卡: Intel HD Graphics

### 推荐配置 (高性能模式)
- CPU: Intel Core i5 4代 或 AMD 同等
- 内存: 4GB+ RAM
- 存储: 40GB+ 可用空间
- 显卡: Intel HD Graphics 4000+ 或独立显卡

## 快速开始

```bash
# 克隆仓库
git clone https://github.com/sans65-ch/FluentOS.git
cd FluentOS

# 查看项目结构
ls -la
```

## 项目结构

```
FluentOS/
├── docs/                       # 设计文档和实现计划
│   ├── specs/                  # 设计规格
│   └── plans/                  # 实现计划
├── src/                        # 源代码
│   ├── shell/                  # 桌面Shell定制
│   ├── themes/                 # 主题和特效
│   ├── calamares/              # 安装程序
│   └── grub-theme/             # 引导主题
├── packages/                   # 定制软件包
└── iso/                        # ISO构建配置
```

## 许可证

本项目采用 GPL-3.0 许可证开源。

## 贡献

欢迎提交 Issue 和 Pull Request！
