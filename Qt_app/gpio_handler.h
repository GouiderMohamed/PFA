#ifndef GPIO_HANDLER_H
#define GPIO_HANDLER_H

#include <QObject>

class Gpio_handler : public QObject
{
    Q_OBJECT
public:
    explicit Gpio_handler(QObject *parent = nullptr);

signals:
    void leftButtonPressed();  // Signal envoyé quand on appuie sur le bouton gauche
    void rightButtonPressed(); // Signal envoyé quand on appuie sur le bouton droit
    void warningButtonPressed();
};

#endif // GPIO_HANDLER_H
