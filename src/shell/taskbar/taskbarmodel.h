#ifndef TASKBARMODEL_H
#define TASKBARMODEL_H

#include <QObject>
#include <QAbstractListModel>
#include <QList>
#include <QHash>
#include <QRect>

class TaskbarModel : public QObject
{
    Q_OBJECT
    Q_PROPERTY(QList<QObject*> runningWindows READ runningWindows NOTIFY runningWindowsChanged)
    Q_PROPERTY(QList<QObject*> pinnedApps READ pinnedApps NOTIFY pinnedAppsChanged)

public:
    static TaskbarModel* instance();

    // Running windows
    QList<QObject*> runningWindows() const { return m_runningWindows; }
    void loadRunningWindows();

    // Pinned apps
    QList<QObject*> pinnedApps() const { return m_pinnedApps; }
    void setPinnedApps(const QList<QObject*>& apps);

    // Window operations
    Q_INVOKABLE void activateWindow(int windowId);
    Q_INVOKABLE void closeWindow(int windowId);
    Q_INVOKABLE void maximizeWindow(int windowId);
    Q_INVOKABLE void minimizeWindow(int windowId);
    Q_INVOKABLE void restoreWindow(int windowId);
    Q_INVOKABLE void showDesktop();

    // App operations
    Q_INVOKABLE void launchApp(const QString& appId, const QString& path);
    Q_INVOKABLE void closeApp(const QString& appId);

    // Taskbar geometry
    Q_PROPERTY(QRect taskbarGeometry READ taskbarGeometry WRITE setTaskbarGeometry NOTIFY taskbarGeometryChanged)
    QRect taskbarGeometry() const { return m_taskbarGeometry; }
    void setTaskbarGeometry(const QRect& rect) { m_taskbarGeometry = rect; }

signals:
    void runningWindowsChanged();
    void pinnedAppsChanged();
    void taskbarGeometryChanged();
    void windowActivated(int windowId);
    void appLaunched(const QString& appId, const QString& path);

private:
    explicit TaskbarModel(QObject* parent = nullptr);
    ~TaskbarModel();

    static TaskbarModel* s_instance;

    QList<QObject*> m_runningWindows;
    QList<QObject*> m_pinnedApps;
    QRect m_taskbarGeometry;

    // Internal helpers
    void updateRunningWindowsList();
};

#endif // TASKBARMODEL_H
