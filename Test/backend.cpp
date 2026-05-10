#include "backend.h"
#include <QDebug>

Backend::Backend(QObject *parent) : QObject(parent)
{
    // Socket Configuration
    m_server = new QLocalServer(this);
    QString socketPath = "/tmp/car_socket";
    QLocalServer::removeServer(socketPath);

    if (m_server->listen(socketPath)) {
        connect(m_server, &QLocalServer::newConnection, this, &Backend::handleNewConnection);
        qDebug() << "Serveur de simulation prêt sur" << socketPath;
    } else {
        qDebug() << "Erreur critique Socket :" << m_server->errorString();
    }

    // --- 2. MÉTRONOME POUR CLIGNOTANTS (600ms) ---
    QTimer *blinkTimer = new QTimer(this);
    connect(blinkTimer, &QTimer::timeout, [this]() {
        m_flashState = !m_flashState;
        emit leftTurnActiveChanged();
        emit rightTurnActiveChanged();
    });
    blinkTimer->start(600);

    // --- 3. CONNEXIONS HARDWARE GPIO ---
    connect(&m_gpioHandler, &Gpio_handler::leftButtonPressed, [this]() {
        m_leftActive = !m_leftActive;
        m_rightActive = false; // Désactive l'autre côté par sécurité
        emit leftTurnActiveChanged();
        emit rightTurnActiveChanged();
    });

    connect(&m_gpioHandler, &Gpio_handler::rightButtonPressed, [this]() {
        m_rightActive = !m_rightActive;
        m_leftActive = false;
        emit leftTurnActiveChanged();
        emit rightTurnActiveChanged();
    });

    connect(&m_gpioHandler, &Gpio_handler::warningButtonPressed, [this]() {
        m_hazardActive = !m_hazardActive;
        emit leftTurnActiveChanged();
        emit rightTurnActiveChanged();
    });


}

// Slot : Executed Once the python script is connected
void Backend::handleNewConnection()
{
    m_clientSocket = m_server->nextPendingConnection();
    connect(m_clientSocket, &QLocalSocket::readyRead, this, &Backend::readSocketData);
    qDebug() << "Script Python de simulation connecté !";
}

// Slot :received messages Analysis
void Backend::readSocketData()
{
    if (!m_clientSocket) return;

    QByteArray data = m_clientSocket->readAll();

    QString strData = QString::fromUtf8(data).trimmed();

    QStringList parts = strData.split('|');
    for (const QString &part : parts) {
        // Speed
        if (part.startsWith("VITESSE:")) {
            QString valueStr = part.section(':', 1); // Récupère tout ce qui est APRÈS le premier ':'
            m_vitesse = valueStr.toInt();
            qDebug() << "Nouvelle vitesse confirmée :" << m_vitesse;
            emit vitesseChanged();
        }
        // RPM
        else if (part.startsWith("RPM:")) {
            QString valueStr = part.section(':', 1);
            m_rpm = valueStr.toInt();
            qDebug() << "Nouvelle RPM confirmée :" << m_rpm;
            emit rpmChanged();
        }
        else if (part.startsWith("TEMP:")) {
            QString valueStr = part.section(':', 1);
            m_temperature = valueStr.toInt();
            qDebug() << "Nouvelle TEMP confirmée :" << m_temperature;
            emit temperatureChanged();
        }
        else if (part.startsWith("left:")) {
            QString valueStr = part.section(':', 1);
            m_leftActive = valueStr.toInt();
            qDebug() << "left torche state :" << m_leftActive;
            emit leftTurnActiveChanged();
        }
        else if (part.startsWith("right:")) {
            QString valueStr = part.section(':', 1);
            m_rightActive = valueStr.toInt();
            qDebug() << "right torche state :" <<m_rightActive ;
            emit rightTurnActiveChanged();
        }
    }
}
