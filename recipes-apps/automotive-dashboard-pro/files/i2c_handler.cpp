#include "i2c_handler.h"
#include <fcntl.h>    // Pour open()
#include <unistd.h>   // Pour read() et close()
#include <fstream>    // Pour lire le fichier de simulation
#include <QDebug>
#include <QFile>

i2c_handler::i2c_handler(QObject *parent) : QObject(parent), m_fd(-1)
{
    // On vérifie si on est sur le BeagleBone (le bus I2C existe)
    // Sinon, on bascule en mode simulation
    /*if (QFile::exists("/dev/i2c-88")) {
        m_fd = open("/dev/i2c-1", O_RDWR);
        m_simulationMode = false;
        qDebug() << "I2C Handler: Mode RÉEL activé";
    } else {
        m_simulationMode = true;
        qDebug() << "I2C Handler: Mode SIMULATION activé (Fichier texte)";
    }*/
}

i2c_handler::~i2c_handler() {
    if (m_fd >= 0) {
        close(m_fd);
    }
}

double i2c_handler::getTemperature() {
    if (m_simulationMode) {
        qDebug() << "getTemperature CALLED";

        return readFromSimulationFile();
    } else {
        return readFromRealHardware();
    }
}

double i2c_handler::readFromSimulationFile() {
    std::ifstream file("/home/mohamed/Desktop/PFA/temp_input.txt");
    std::string line;

    if (file.is_open() && std::getline(file, line)) {
        try {
            qDebug() << "SIM TEMP FILE =" << QString::fromStdString(line);
            return std::stod(line);
        } catch (...) {
            qDebug() << "Invalid temperature format";
            return 20.0;
        }
    }

    return 20.0;
}

double i2c_handler::readFromRealHardware() {
    // Ici, vous mettrez le code ioctl() et read() spécifique au BeagleBone
    // Pour l'instant, on retourne 0.0 pour compiler
    return 22.5;
}
