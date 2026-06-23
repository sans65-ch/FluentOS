/**
 * FluentOS Shell - Main Entry Point
 *
 * 基于 Qt/QML 的仿 Windows 桌面环境
 *
 * 主要功能:
 * - 任务栏 (Taskbar)
 * - 开始菜单 (Start Menu)
 * - 文件管理器 (File Manager)
 * - 控制面板 (Control Panel)
 * - Windows 程序启动器
 * - 双系统支持
 */

#include <QApplication>
#include <QQmlApplicationEngine>
#include <QQmlContext>
#include <QtQml>
#include <QQuickStyle>
#include <QIcon>
#include <QTranslator>
#include <QLibraryInfo>
#include <QCommandLineParser>
#include <QStandardPaths>
#include <QDir>

// 系统模块
#include "system/windowsdrivemanager.h"
#include "effects/themeengine.h"

int main(int argc, char *argv[])
{
    QApplication app(argc, argv);
    app.setOrganizationName("FluentOS");
    app.setApplicationName("FluentOS Shell");
    app.setApplicationVersion("1.0.0");
    app.setDesktopFileName("fluentos-shell.desktop");

    // 命令行解析
    QCommandLineParser parser;
    parser.setApplicationDescription("FluentOS Desktop Shell");
    parser.addHelpOption();
    parser.addVersionOption();

    QCommandLineOption replaceOption(QStringList() << "r" << "replace",
        QCoreApplication::translate("main", "Replace current shell"));
    parser.addOption(replaceOption);

    QCommandLineOption testOption(QStringList() << "t" << "test",
        QCoreApplication::translate("main", "Run in test mode (windowed)"));
    parser.addOption(testOption);

    parser.process(app);

    // 设置应用样式
    QQuickStyle::setStyle("Fluent");

    // 加载翻译
    QTranslator qtTranslator;
    qtTranslator.load("qt_" + QLocale::system().name(),
        QLibraryInfo::location(QLibraryInfo::TranslationsPath));
    app.installTranslator(&qtTranslator);

    QTranslator appTranslator;
    appTranslator.load("fluentos-shell_" + QLocale::system().name(),
        "/usr/share/fluentos/translations");
    app.installTranslator(&appTranslator);

    // 初始化 QML 引擎
    QQmlApplicationEngine engine;

    // 注册 QML 类型
    qmlRegisterType<WindowsDriveManager>("FluentOS.System", 1, 0, "WindowsDriveManager");
    qmlRegisterType<ThemeEngine>("FluentOS.Effects", 1, 0, "ThemeEngine");

    // 设置上下文属性
    engine.rootContext()->setContextProperty("applicationVersion", app.applicationVersion());
    engine.rootContext()->setContextProperty("isTestMode", parser.isSet(testOption));
    engine.rootContext()->setContextProperty("isReplaceMode", parser.isSet(replaceOption));

    // 添加 QML 导入路径
    engine.addImportPath("/usr/share/fluentos/qml");
    engine.addImportPath("qrc:/qml");

    // 加载主 QML 文件
    const QUrl mainQml(QStringLiteral("qrc:/qml/main.qml"));

    QObject::connect(&engine, &QQmlApplicationEngine::objectCreated,
        &app, [mainQml](QObject *obj, const QUrl &objUrl) {
            if (!obj && mainQml == objUrl) {
                QCoreApplication::exit(-1);
            }
        }, Qt::QueuedConnection);

    engine.load(mainQml);

    return app.exec();
}
