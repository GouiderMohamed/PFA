import socket
import time
import os
import random

socket_path = "/tmp/car_socket"

print("En attente du Dashboard...")

# On boucle jusqu'à ce que la connexion réussisse
connected = False
while not connected:
    try:
        # On crée un NOUVEAU socket à chaque tentative
        s = socket.socket(socket.AF_UNIX, socket.SOCK_STREAM)
        s.connect(socket_path)
        connected = True
    except ( FileNotFoundError, ConnectionRefusedError):
        s.close() # On ferme le socket inutile
        time.sleep(1)

with s:
    print("Connecté ! Envoi des données...")
    vitesse = 0
    while True:
        try:
            vitesse = (vitesse+2)%220
            rpm = vitesse * 20
            tmp = random.randint(0,50)
            left=random.choice([1,0])
            message = f"VITESSE:{vitesse}|RPM:{rpm}|TEMP:{tmp}|left:{left}|right:{1-left}"
            print(message)
            s.sendall(message.encode())
            time.sleep(0.3) # 10 FPS
        except BrokenPipeError:
            print("Dashboard déconnecté.")
            break
