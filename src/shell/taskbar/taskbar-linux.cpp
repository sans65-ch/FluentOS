#include "taskbarmodel.h"
#include <KWindowSystem>
#include <KWindowInfo>
#include <NETWinInfo>
#include <QDebug>

// Linux-specific implementation using KWin
// Requires: KF5::WindowSystem

TaskbarModel::TaskbarModel(QObject* parent)
    : QObject(parent)
{
    // Watch for window changes
    connect(KWindowSystem::self(), &KWindowSystem::windowChanged,
            this, &TaskbarModel::updateRunningWindowsList);
    connect(KWindowSystem::self(), &KWindowSystem::windowAdded,
            this, &TaskbarModel::loadRunningWindows);
    connect(KWindowSystem::self(), &KWindowSystem::windowRemoved,
            this, &TaskbarModel::loadRunningWindows);
}

void TaskbarModel::updateRunningWindowsList()
{
    m_runningWindows.clear();

    const auto windows = KWindowSystem::windows();
    for (WId windowId : windows) {
        KWindowInfo info(windowId, NET::WMName | NET::WMWindowType | NET::WMState);

        // Skip desktop, dock, splash, etc.
        if (info.windowType(NET::DesktopMask) ||
            info.windowType(NET::DockMask) ||
            info.windowType(NET::SplashMask)) {
            continue;
        }

        // Skip hidden/closed windows
        if (info.state() & NET::Hidden) {
            continue;
        }

        // Create window info object
        QObject* windowObj = new QObject(this);
        windowObj->setProperty("windowId", (qlonglong)windowId);
        windowObj->setProperty("title", info.name());
        windowObj->setProperty("isActive", KWindowSystem::activeWindow() == windowId);
        windowObj->setProperty("isMinimized", info.state() & NET::Minimized);

        m_runningWindows.append(windowObj);
    }

    emit runningWindowsChanged();
}

void TaskbarModel::activateWindow(int windowId)
{
    KWindowSystem::activateWindow((WId)windowId);
}

void TaskbarModel::closeWindow(int windowId)
{
    NETRootInfo NETRoot(QX11Info::connection(), NET::CloseWindow);
    NETRoot.closeWindowRequest((WId)windowId);
}

void TaskbarModel::maximizeWindow(int windowId)
{
    KWindowSystem::setMaximize((WId)windowId, true, true);
}

void TaskbarModel::minimizeWindow(int windowId)
{
    KWindowSystem::minimizeWindow((WId)windowId);
}

void TaskbarModel::restoreWindow(int windowId)
{
    KWindowSystem::unminimizeWindow((WId)windowId);
}

void TaskbarModel::showDesktop()
{
    // Minimize all windows to show desktop
    const auto windows = KWindowSystem::windows();
    for (WId windowId : windows) {
        KWindowInfo info(windowId, NET::WMWindowType | NET::WMState);
        if (!info.windowType(NET::DesktopMask) &&
            !info.windowType(NET::DockMask) &&
            !(info.state() & NET::Hidden)) {
            KWindowSystem::minimizeWindow(windowId);
        }
    }
}

void TaskbarModel::launchApp(const QString& appId, const QString& path)
{
    // Use QProcess to launch
    QProcess::startDetached(path);
    emit appLaunched(appId, path);
}
