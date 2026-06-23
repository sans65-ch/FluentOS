cmake_minimum_required(VERSION 3.16)

project(FluentOS-Shell VERSION 1.0.0 LANGUAGES CXX)

set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_STANDARD_REQUIRED ON)
set(CMAKE_AUTOMOC ON)
set(CMAKE_AUTORCC ON)
set(CMAKE_AUTOUIC ON)

find_package(Qt5 REQUIRED COMPONENTS
    Core
    Gui
    Qml
    Quick
    QuickControls2
    Widgets
    DBus
)

find_package(KF5 REQUIRED COMPONENTS
    WindowSystem
    Plasma
    I18n
)

# 编译选项
add_compile_options(-Wall -Wextra)

# 子目录
add_subdirectory(taskbar)
add_subdirectory(startmenu)
add_subdirectory(filemanager)
add_subdirectory(control-panel)
add_subdirectory(system)

# 资源文件
set(RESOURCES
    resources.qrc
)

# 主可执行文件
add_executable(fluentos-shell
    main.cpp
    ${RESOURCES}
)

target_link_libraries(fluentos-shell
    Qt5::Core
    Qt5::Gui
    Qt5::Qml
    Qt5::Quick
    Qt5::QuickControls2
    Qt5::DBus
    KF5::WindowSystem
    KF5::Plasma
    KF5::I18n
)

# 安装
install(TARGETS fluentos-shell DESTINATION bin)

# 安装 QML 文件
install(DIRECTORY qml/ DESTINATION share/fluentos/qml)

# 安装桌面文件
install(FILES fluentos-shell.desktop DESTINATION share/applications)

# 打包信息
set(CPACK_PACKAGE_NAME "fluentos-shell")
set(CPACK_PACKAGE_VERSION "${PROJECT_VERSION}")
set(CPACK_PACKAGE_DESCRIPTION_SUMMARY "FluentOS Desktop Shell")
set(CPACK_PACKAGE_LICENSE "GPL-3.0")
include(CPack)
