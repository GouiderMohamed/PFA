#include <QGuiApplication>
#include <QQmlApplicationEngine>
#include <QQmlContext>  // Ne pas oublier cet include
#include "backend.h"

int main(int argc, char *argv[])
{
    QGuiApplication app(argc, argv);

    QQmlApplicationEngine engine;

    // 1. Créer l'instance du backend
    Backend backend;

    // 2. Injecter l'objet DANS le contexte racine de l'engine
    // C'est cette ligne qui permet au QML de faire "backend.vitesse"
    engine.rootContext()->setContextProperty("backend", &backend);

    // 3. Charger le module APRÈS avoir défini la propriété
    QObject::connect(
        &engine,
        &QQmlApplicationEngine::objectCreationFailed,
        &app,
        []() { QCoreApplication::exit(-1); },
        Qt::QueuedConnection);

    engine.loadFromModule("AutomotiveDashboard", "Main");

    return app.exec();
}
