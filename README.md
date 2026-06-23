# FluentOS

> 基于 Arch Linux 的仿 Windows 桌面操作系统，让你从 Windows 无缝过渡到 Linux

![License](https://img.shields.io/badge/license-GPL--3.0-blue)
![Version](https://img.shields.io/badge/version-1.0.0-green)
![Platform](https://img.shields.io/badge/platform-x86__64-orange)
![Base](https://img.shields.io/badge/base-Arch%20Linux-purple)

## ✨ 特性

### 🖥️ Windows 操作逻辑高度兼容
- **任务栏** - Windows 11 风格，含固定应用、运行窗口、系统托盘
- **开始菜单** - 搜索、固定应用、全部应用分类
- **文件管理器** - 仿 Windows 资源管理器，导航窗格、详情面板
- **控制面板** - Windows 风格设置界面
- **快捷键** - Super+E、Alt+Tab 等 Windows 常用快捷键

### 🎨 Fluent + 液态玻璃设计
- **Fluent Design** - Windows 11 风格视觉语言
- **液态玻璃效果** - 背景模糊、边缘高光、渐变透明度
- **亚克力材质** - 半透明 + 噪点纹理
- **云母效果** - 色调映射、微妙的不透明效果
- **动画系统** - 丝滑过渡动画（默认关闭，可自行开启）

### 🔄 双系统文件共享
- **自动挂载** - 自动检测和挂载 Windows NTFS 分区
- **程序共享** - 直接访问和启动 Windows 程序
- **文件互通** - 与 Windows 共享文档、下载等文件夹
- **多系统引导** - 美化的 GRUB 引导界面

### ⚡ 低配置友好
- **性能模式** - 特效默认关闭，4 代 i3 可流畅运行
- **内存优化** - 空闲占用 < 400MB
- **特效警告** - 开启特效前弹出性能提示

### 🛠️ 双重安装方式
- **从 Windows 安装** - 在 Windows 内运行安装程序，分配空间并安装
- **Live USB 安装** - 传统启动介质方式，支持试用和安装
- **图形化安装** - 基于 Calamares 的友好安装界面

## 📋 系统要求

### 最低配置 (性能模式)
| 组件 | 要求 |
|------|------|
| CPU | Intel Core i3 4代 / AMD 同级别 |
| 内存 | 2 GB RAM |
| 存储 | 20 GB 可用空间 |
| 显卡 | Intel HD Graphics 4000 |
| 网络 | 可选（用于更新） |

### 推荐配置 (全特效模式)
| 组件 | 要求 |
|------|------|
| CPU | Intel Core i5 4代 及以上 |
| 内存 | 4 GB+ RAM |
| 存储 | 40 GB+ SSD |
| 显卡 | 支持 OpenGL 3.3 的显卡 |
| 网络 | 宽带连接 |

## 🚀 快速开始

### 方式一：下载 ISO 安装
1. 从 [Releases](https://github.com/sans65-ch/FluentOS/releases) 下载最新 ISO
2. 使用 [Rufus](https://rufus.ie/) 或 [Etcher](https://etcher.balena.io/) 写入 USB
3. 从 USB 启动，按提示安装

### 方式二：从现有 Arch 安装
```bash
# 添加 FluentOS 仓库（待发布）
# sudo pacman -S fluentos-desktop-meta
```

### 方式三：从源码构建
```bash
# 克隆仓库
git clone https://github.com/sans65-ch/FluentOS.git
cd FluentOS

# 构建 Shell
cd src/shell
mkdir build && cd build
cmake ..
make -j$(nproc)

# 运行
./fluentos-shell --test
```

## 📁 项目结构

```
FluentOS/
├── docs/                          # 设计文档和实现计划
│   ├── superpowers/
│   │   ├── specs/                 # 设计规格
│   │   └── plans/                 # 实现计划
│
├── src/                           # 源代码
│   ├── shell/                     # 桌面 Shell
│   │   ├── taskbar/               # 任务栏
│   │   ├── startmenu/             # 开始菜单
│   │   ├── filemanager/           # 文件管理器
│   │   ├── control-panel/         # 控制面板
│   │   ├── system/                # 系统工具 (双系统支持)
│   │   ├── qml/                   # QML 界面
│   │   ├── CMakeLists.txt
│   │   └── main.cpp
│   │
│   ├── themes/                    # 主题和特效
│   │   ├── fluent-theme/          # Fluent Design 主题
│   │   └── glass-effect/          # 液态玻璃效果 (GLSL)
│   │
│   ├── calamares/                 # 安装程序配置
│   │   ├── branding/              # 品牌定制
│   │   └── scripts/               # 安装脚本
│   │
│   └── grub-theme/                # GRUB 引导主题
│
├── packages/                      # 定制软件包 (PKGBUILD)
│   ├── fluentos-desktop-meta/     # 元包
│   ├── fluentos-shell/            # Shell 包
│   └── fluentos-theme/            # 主题包
│
├── iso/                           # ISO 构建
│   ├── airootfs/                  # 根文件系统覆盖
│   ├── build.sh                   # 构建脚本
│   ├── packages.x86_64            # 软件包列表
│   ├── pacman.conf                # Pacman 配置
│   └── install-from-windows.bat   # Windows 安装程序
│
├── scripts/                       # 工具脚本
│   └── release.sh                 # 发布脚本
│
├── README.md
├── LICENSE
└── .gitignore
```

## 🎯 功能路线图

### ✅ Phase 1: 核心 Shell (已完成)
- [x] 任务栏 (Taskbar)
- [x] 开始菜单 (Start Menu)
- [x] 文件管理器 (File Manager)
- [x] 控制面板 (Control Panel)

### ✅ Phase 2: 系统集成 (已完成)
- [x] Windows 分区自动挂载
- [x] Windows 程序启动器
- [x] Calamares 安装程序配置
- [x] GRUB 引导主题

### ✅ Phase 3: 特效系统 (已完成)
- [x] Fluent Design 主题引擎
- [x] 液态玻璃效果 (GLSL Shader)
- [x] 亚克力材质效果
- [x] 云母材质效果
- [x] 性能模式切换

### ✅ Phase 4: 打包发布 (已完成)
- [x] ISO 构建配置
- [x] Arch 软件包 (PKGBUILD)
- [x] 发布脚本
- [x] Windows 安装脚本

### 🔄 Phase 5: 测试和优化 (进行中)
- [ ] ISO 构建测试
- [ ] 性能测试和优化
- [ ] 兼容性测试
- [ ] 文档完善

### 💡 未来规划
- [ ] Windows 应用商店集成
- [ ] 系统更新中心
- [ ] 备份和恢复工具
- [ ] 驱动管理
- [ ] 游戏模式

## ⚙️ 配置说明

### 特效开关
特效默认关闭。如需开启：

1. 打开 **控制面板** → **个性化** → **效果**
2. 选择你想开启的效果（亚克力/云母/液态玻璃）
3. 确认性能警告后启用

### Windows 分区配置
系统会自动检测 Windows NTFS 分区。手动管理：

```bash
# 列出 Windows 分区
fluentos-windows --list-drives

# 挂载所有 Windows 分区
fluentos-windows --mount-all

# 查找 Windows 程序
fluentos-windows --find-programs
```

### 主题切换
```bash
# 切换浅色/深色主题
fluentos-theme --toggle

# 应用 Fluent 主题
fluentos-theme --apply fluent
```

## 🤝 贡献

欢迎贡献代码、报告 Bug 或提出建议！

### 贡献方式
1. Fork 本仓库
2. 创建特性分支 (`git checkout -b feature/AmazingFeature`)
3. 提交更改 (`git commit -m 'Add some AmazingFeature'`)
4. 推送到分支 (`git push origin feature/AmazingFeature`)
5. 开启 Pull Request

### 代码规范
- C++ 代码遵循 Qt 编码规范
- QML 代码使用 4 空格缩进
- Python 代码遵循 PEP 8
- 提交信息使用 Conventional Commits 格式

## 📄 许可证

本项目采用 **GPL-3.0** 许可证开源。详见 [LICENSE](LICENSE) 文件。

## 🙏 致谢

- [Arch Linux](https://archlinux.org/) - 优秀的滚动发行版
- [KDE Plasma](https://kde.org/plasma-desktop/) - 强大的桌面环境
- [Calamares](https://calamares.io/) - 通用安装程序框架
- [Microsoft Fluent Design](https://www.microsoft.com/design/fluent/) - 设计灵感来源

## 📞 联系方式

- **GitHub Issues**: https://github.com/sans65-ch/FluentOS/issues
- **项目主页**: https://github.com/sans65-ch/FluentOS

---

**FluentOS** - 让 Linux 像 Windows 一样熟悉，让 Windows 用户自由切换。
