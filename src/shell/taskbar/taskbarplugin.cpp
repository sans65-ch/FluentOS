#include <QQmlExtensionPlugin>
#include <QQmlEngine>
#include "taskbarmodel.h"

class FluentTaskbarPlugin : public QQmlExtensionPlugin
{
    Q_OBJECT
    Q_PLUGIN_METADATA(IID QQmlExtensionInterface_iid)

public:
    void registerTypes(const char* uri) override
    {
        Q_ASSERT(QLatin1String(uri) == QLatin1String("Fluento.Taskbar"));

        // Register TaskbarModel as singleton
        qmlRegisterSingletonType<TaskbarModel>(
            uri, 1, 0, "TaskbarModel",
            [](QQmlEngine*, QQmlEngine*, QJSEngine*) -> QObject* {
                return TaskbarModel::instance();
            }
        );

        // Register types
        qmlRegisterUncreatableType<TaskbarModel>(
            uri, 1, 0, "TaskbarModelBase",
            QStringLiteral("TaskbarModel must be created via singleton")
        );
    }
};

#include "taskbarplugin.moc"
