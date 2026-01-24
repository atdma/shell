#include <QGuiApplication>
#include <QQmlApplicationEngine>
#include <QIcon>

int main(int argc, char *argv[])
{
    QGuiApplication app(argc, argv);
    app.setApplicationName("Caelestia Welcome");
    app.setOrganizationName("Caelestia");

    QQmlApplicationEngine engine;
    const QUrl url(QStringLiteral("qrc:/caelestia/welcome/main.qml"));
    
    QObject::connect(&engine, &QQmlApplicationEngine::objectCreationFailed,
        &app, []() { QCoreApplication::exit(-1); },
        Qt::QueuedConnection);
    
    engine.load(url);

    return app.exec();
}
