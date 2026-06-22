# FluentOS 实现计划

> **目标:** 创建基于Arch Linux的仿Windows桌面操作系统 FluentOS
> **架构:** 基于Arch Linux定制，高度兼容Windows操作逻辑
> **技术栈:** KDE Plasma (高度定制), Calamares, pacman, KWin

---

## 项目阶段概览

| 阶段 | 名称 | 周期 | 目标 |
|------|------|------|------|
| Phase 0 | 基础搭建 | 1-2周 | 项目初始化、基础架构 |
| Phase 1 | 核心Shell | 3-4周 | 任务栏、开始菜单、文件管理器 |
| Phase 2 | 系统集成 | 2-3周 | 双系统支持、安装程序 |
| Phase 3 | 特效系统 | 2-3周 | Fluent动画、液态玻璃效果 |
| Phase 4 | 打包发布 | 2-3周 | ISO构建、测试、打包 |

**总预计工期:** 10-15周（兼职开发）

---

## Phase 0: 基础搭建

### 任务 0.1: 项目初始化

**文件:**
- 创建: `README.md`
- 创建: `LICENSE` (GPL-3.0)
- 创建: `.gitignore`

**步骤:**

- [ ] **Step 1: 创建 README.md**

```markdown
# FluentOS

基于 Arch Linux 的仿 Windows 桌面操作系统

## 特性

- Windows 操作逻辑高度兼容
- Fluent + 液态玻璃设计
- 双系统文件共享
- 低配置友好

## 许可证

GPL-3.0
```

- [ ] **Step 2: 初始化 Git 仓库**

```bash
git init
git add README.md LICENSE .gitignore
git commit -m "docs: initial project setup"
```

---

### 任务 0.2: 创建项目目录结构

**文件:**
- 创建: `src/`
- 创建: `src/shell/`
- 创建: `src/shell/taskbar/`
- 创建: `src/shell/startmenu/`
- 创建: `src/shell/filemanager/`
- 创建: `src/shell/control-panel/`
- 创建: `src/themes/`
- 创建: `src/calamares/`
- 创建: `src/grub-theme/`
- 创建: `packages/`
- 创建: `iso/`

**步骤:**

- [ ] **Step 1: 创建目录结构**

```bash
mkdir -p src/shell/{taskbar,startmenu,filemanager,control-panel}
mkdir -p src/{themes,calamares,grub-theme}
mkdir -p packages
mkdir -p iso
```

- [ ] **Step 2: 添加占位符文件**

每个目录添加 `.gitkeep` 用于保持空目录结构

```bash
find src -type d -exec touch {}/.gitkeep \;
```

---

### 任务 0.3: 创建 Calamares 安装程序基础

**文件:**
- 创建: `src/calamares/README.md`
- 创建: `src/calamares/branding/branding.desc`
- 创建: `src/calamares/modules/`

**步骤:**

- [ ] **Step 1: 创建 Calamares 配置目录结构**

```bash
mkdir -p src/calamares/{branding,modules,locale}
```

- [ ] **Step 2: 创建基础 branding.desc**

```yaml
---
componentName: FluentOS
productName: FluentOS
productVersion: 1.0.0
dashboardUrl: https://github.com/sans65-ch/FluentOS
donateUrl: https://github.com/sans65-ch/FluentOS
bugReportUrl: https://github.com/sans65-ch/FluentOS/issues
knownIssuesUrl: https://github.com/sans65-ch/FluentOS/wiki
```

---

## Phase 1: 核心 Shell 开发

### 任务 1.1: Windows 风格任务栏

**文件:**
- 创建: `src/shell/taskbar/CMakeLists.txt`
- 创建: `src/shell/taskbar/Taskbar.qml`
- 创建: `src/shell/taskbar/PinnedItem.qml`
- 创建: `src/shell/taskbar/WindowButton.qml`
- 测试: `src/shell/taskbar/test_taskbar.cpp`

**步骤:**

- [ ] **Step 1: 创建 CMakeLists.txt**

```cmake
cmake_minimum_required(VERSION 3.16)
project(fluentos-taskbar)

set(CMAKE_MODULE_PATH ${CMAKE_MODULE_PATH} "${CMAKE_CURRENT_SOURCE_DIR}/cmake")

find_package(Qt5 REQUIRED COMPONENTS Qml Quick Widgets)

add_library(fluentos-taskbar SHARED
    Taskbar.qml
    PinnedItem.qml
    WindowButton.qml
)

target_link_libraries(fluentos-taskbar
    Qt5::Qml
    Qt5::Quick
    Qt5::Widgets
)
```

- [ ] **Step 2: 创建任务栏 QML 主文件**

```qml
import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15

Rectangle {
    id: taskbar
    height: 48
    color: "#2D2D2D"
    anchors.left: parent.left
    anchors.right: parent.right
    anchors.bottom: parent.bottom

    RowLayout {
        anchors.fill: parent
        anchors.margins: 4
        spacing: 4

        // 开始菜单按钮
        Item {
            width: 48
            height: 40
            Rectangle {
                anchors.centerIn: parent
                width: 40
                height: 40
                color: startMenuHovered ? "#3D3D3D" : "transparent"
                radius: 8
            }
            Image {
                anchors.centerIn: parent
                source: "qrc:/icons/windows-logo.png"
            }
            property bool startMenuHovered: false
        }

        // 固定项目区域
        ListView {
            id: pinnedItems
            Layout.preferredWidth: contentWidth
            height: 40
            orientation: Qt.Horizontal
            model: pinnedApps
            delegate: PinnedItem {}
        }

        // 运行窗口区域
        ListView {
            id: windowItems
            Layout.fillWidth: true
            height: 40
            orientation: Qt.Horizontal
            model: runningWindows
            delegate: WindowButton {}
        }

        // 系统托盘区域
        Row {
            width: children.width
            SystemTray {}
        }
    }
}
```

- [ ] **Step 3: 创建测试文件**

```cpp
#include <QCoreApplication>
#include <QDebug>

int main(int argc, char *argv[])
{
    QCoreApplication app(argc, argv);
    qDebug() << "Taskbar component test";
    return 0;
}
```

---

### 任务 1.2: 开始菜单

**文件:**
- 创建: `src/shell/startmenu/StartMenu.qml`
- 创建: `src/shell/startmenu/StartMenuItem.qml`
- 创建: `src/shell/startmenu/SearchBar.qml`
- 创建: `src/shell/startmenu/AllAppsView.qml`

---

### 任务 1.3: 文件资源管理器 (仿 Windows Explorer)

**文件:**
- 创建: `src/shell/filemanager/FileManager.qml`
- 创建: `src/shell/filemanager/NavigationPane.qml`
- 创建: `src/shell/filemanager/FileListView.qml`
- 创建: `src/shell/filemanager/DetailsPane.qml`

---

### 任务 1.4: 控制面板

**文件:**
- 创建: `src/shell/control-panel/ControlPanel.qml`
- 创建: `src/shell/control-panel/SettingsPage.qml`
- 创建: `src/shell/control-panel/DisplaySettings.qml`
- 创建: `src/shell/control-panel/ThemeSettings.qml`

---

## Phase 2: 系统集成

### 任务 2.1: 双系统文件共享模块

**文件:**
- 创建: `src/shell/system/windwos-mounter.py` (Python脚本)
- 创建: `src/shell/system/ProgramLauncher.qml`

---

### 任务 2.2: Windows 内安装程序

**文件:**
- 创建: `src/calamares/windows-installer/` (PE环境相关)

---

### 任务 2.3: GRUB 定制主题

**文件:**
- 创建: `src/grub-theme/theme.txt`
- 创建: `src/grub-theme/background.png` (占位符)

---

## Phase 3: 特效系统

### 任务 3.1: Fluent 主题引擎

**文件:**
- 创建: `src/themes/fluent-theme/` (Qt主题)

---

### 任务 3.2: 液态玻璃效果

**文件:**
- 创建: `src/themes/glass-effect/shader.frag` (GLSL)

---

## Phase 4: 打包发布

### 任务 4.1: ISO 构建配置

**文件:**
- 创建: `iso/mkarchiso.cfg`
- 创建: `iso/airootfs/` (基础系统)

---

### 任务 4.2: 自动化构建脚本

**文件:**
- 创建: `build.sh`
- 创建: `build-iso.sh`

---

## 实施检查清单

- [ ] Phase 0 完成
  - [ ] 项目初始化
  - [ ] 目录结构
  - [ ] Calamares 基础
- [ ] Phase 1 完成
  - [ ] 任务栏
  - [ ] 开始菜单
  - [ ] 文件管理器
  - [ ] 控制面板
- [ ] Phase 2 完成
  - [ ] 双系统支持
  - [ ] 安装程序
  - [ ] 引导主题
- [ ] Phase 3 完成
  - [ ] 主题引擎
  - [ ] 特效
- [ ] Phase 4 完成
  - [ ] ISO 构建
  - [ ] 测试
  - [ ] 发布
