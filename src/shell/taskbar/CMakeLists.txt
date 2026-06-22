cmake_minimum_required(VERSION 3.16)
project(fluentos-taskbar VERSION 1.0.0 LANGUAGES CXX)

set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_STANDARD_REQUIRED ON)
set(CMAKE_AUTOMOC ON)
set(CMAKE_AUTORCC ON)
set(CMAKE_AUTOUIC ON)

# Find Qt5 components
find_package(Qt5 REQUIRED COMPONENTS
    Core
    Qml
    Quick
    QuickControls2
    Widgets
    DBus
    X11Extras
)

# Platform-specific settings
if(WIN32)
    set(PLATFORM_SOURCES "taskbar-windows.cpp")
elseif(UNIX AND NOT APPLE)
    set(PLATFORM_SOURCES "taskbar-linux.cpp")
endif()

# Build library
add_library(fluentos-taskbar SHARED
    Taskbar.qml
    PinnedItem.qml
    WindowButton.qml
    SystemTray.qml
    NotificationArea.qml
    ${PLATFORM_SOURCES}
    taskbarplugin.cpp
)

target_include_directories(fluentos-taskbar PUBLIC
    ${CMAKE_CURRENT_SOURCE_DIR}
)

target_link_libraries(fluentos-taskbar PRIVATE
    Qt5::Core
    Qt5::Qml
    Qt5::Quick
    Qt5::QuickControls2
    Qt5::Widgets
    Qt5::DBus
)

# Install rules
install(TARGETS fluentos-taskbar
    LIBRARY DESTINATION ${CMAKE_INSTALL_LIBDIR}
    ARCHIVE DESTINATION ${CMAKE_INSTALL_LIBDIR}
)

install(FILES Taskbar.qml PinnedItem.qml WindowButton.qml SystemTray.qml NotificationArea.qml
    DESTINATION ${CMAKE_INSTALL_DATADIR}/qml/FluentOS/Taskbar
)
