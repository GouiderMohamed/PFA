#ifndef BACKEND_H
#define BACKEND_H

#include <QObject>
#include <QTimer>
#include <QtNetwork/QLocalServer>
#include <QtNetwork/QLocalSocket>
#include "gpio_handler.h"
#include "i2c_handler.h"

class Backend : public QObject
{
    Q_OBJECT
    // Propriétés exposées au QML
    Q_PROPERTY(int vitesse READ vitesse NOTIFY vitesseChanged)
    Q_PROPERTY(int rpm READ rpm NOTIFY rpmChanged)
    Q_PROPERTY(float temperature READ temperature NOTIFY temperatureChanged)
    Q_PROPERTY(bool leftTurnActive READ leftTurnActive NOTIFY leftTurnActiveChanged)
    Q_PROPERTY(bool rightTurnActive READ rightTurnActive NOTIFY rightTurnActiveChanged)

public:
    explicit Backend(QObject *parent = nullptr);

    // Getters pour le QML
    int vitesse() const { return m_vitesse; }
    int rpm() const { return m_rpm; }
    float temperature() const { return m_temperature; }
    bool leftTurnActive() const { return (m_leftActive || m_hazardActive) && m_flashState; }
    bool rightTurnActive() const { return (m_rightActive || m_hazardActive) && m_flashState; }

signals:
    void vitesseChanged();
    void rpmChanged();
    void temperatureChanged();
    void leftTurnActiveChanged();
    void rightTurnActiveChanged();

private slots:
    void handleNewConnection(); // Gère la connexion du script Python
    void readSocketData();      // Lit et décode les messages du socket

private:
    // Données membres
    int m_vitesse = 0;
    int m_rpm = 0;
    float m_temperature = 20.0;

    bool m_leftActive = false;
    bool m_rightActive = false;
    bool m_hazardActive = false;
    bool m_flashState = false;

    // Gestion du Socket
    QLocalServer *m_server;
    QLocalSocket *m_clientSocket = nullptr;

    // Modules Hardware
    Gpio_handler m_gpioHandler;
    i2c_handler m_i2cHandler;
};

#endif // BACKEND_H
