#include "taskbarmodel.h"
#include <QDebug>
#include <QRect>

struct WindowInfo {
    int windowId;
    QString title;
    QString icon;
    bool isActive;
    bool isMinimized;
};

TaskbarModel* TaskbarModel::s_instance = nullptr;

TaskbarModel::TaskbarModel(QObject* parent)
    : QObject(parent)
{
    Q_ASSERT(!s_instance);
    s_instance = this;

    // Load pinned apps from config
    // TODO: Load from user's pinned apps list
}

TaskbarModel::~TaskbarModel()
{
    s_instance = nullptr;
}

TaskbarModel* TaskbarModel::instance()
{
    if (!s_instance) {
        s_instance = new TaskbarModel();
    }
    return s_instance;
}

void TaskbarModel::loadRunningWindows()
{
    // On Linux, this would use KWin APIs or X11
    // For now, just emit the signal to trigger UI update
    qDebug() << "Loading running windows...";
    emit runningWindowsChanged();
}

void TaskbarModel::setPinnedApps(const QList<QObject*>& apps)
{
    m_pinnedApps = apps;
    emit pinnedAppsChanged();
}

void TaskbarModel::activateWindow(int windowId)
{
    qDebug() << "Activating window:" << windowId;
    // TODO: Implement using KWin/X11 APIs
    emit windowActivated(windowId);
}

void TaskbarModel::closeWindow(int windowId)
{
    qDebug() << "Closing window:" << windowId;
    // TODO: Implement using KWin/X11 APIs
}

void TaskbarModel::maximizeWindow(int windowId)
{
    qDebug() << "Maximizing window:" << windowId;
    // TODO: Implement using KWin/X11 APIs
}

void TaskbarModel::minimizeWindow(int windowId)
{
    qDebug() << "Minimizing window:" << windowId;
    // TODO: Implement using KWin/X11 APIs
}

void TaskbarModel::restoreWindow(int windowId)
{
    qDebug() << "Restoring window:" << windowId;
    // TODO: Implement using KWin/X11 APIs
}

void TaskbarModel::showDesktop()
{
    qDebug() << "Showing desktop";
    // TODO: Minimize all windows
}

void TaskbarModel::launchApp(const QString& appId, const QString& path)
{
    qDebug() << "Launching app:" << appId << "from" << path;
    // TODO: Implement using QProcess
    emit appLaunched(appId, path);
}

void TaskbarModel::closeApp(const QString& appId)
{
    qDebug() << "Closing app:" << appId;
    // TODO: Implement using KWin/X11 APIs
}
