#ifndef I2C_HANDLER_H
#define I2C_HANDLER_H

#include <QObject>
#include <QString>

class i2c_handler : public QObject
{
    Q_OBJECT
public:
    explicit i2c_handler(QObject *parent = nullptr);
    ~i2c_handler(); // Important pour fermer les fichiers proprement

    // Fonction principale que le Backend appellera
    double getTemperature();

private:
    int m_fd;                // Le descripteur de fichier (I2C ou Fichier Simulation)
    bool m_simulationMode;   // Flag pour savoir si on est sur PC ou BeagleBone

    // Fonctions internes
    double readFromRealHardware();
    double readFromSimulationFile();
};

#endif // I2C_HANDLER_H
