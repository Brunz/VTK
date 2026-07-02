# -*- coding: utf-8 -*-
import os
import fcntl
import struct
import socket
import sys
import time 

UI_SET_EVBIT    = 0x40045564
UI_SET_KEY      = 0x40045565
UI_SET_RELBIT   = 0x40045566
UI_DEV_SETUP    = 0x405c5503
UI_DEV_CREATE   = 0x5501
BUS_USB         = 0x03

fd = os.open('/dev/uinput', os.O_WRONLY | os.O_NONBLOCK)
fcntl.ioctl(fd, UI_SET_EVBIT, 1)   # EV_KEY

for key in range(1, 249):          
    fcntl.ioctl(fd, UI_SET_KEY, key)
fcntl.ioctl(fd, UI_SET_KEY, 272)   # Click Mouse standard (BTN_LEFT)

fcntl.ioctl(fd, UI_SET_EVBIT, 2)   # EV_REL (Mouse)
fcntl.ioctl(fd, UI_SET_RELBIT, 0)  # REL_X
fcntl.ioctl(fd, UI_SET_RELBIT, 1)  # REL_Y

setup_structure = struct.pack('HHHH80sI', BUS_USB, 0x1234, 0x5678, 0x1, b'VTK Virtual TK', 0)
fcntl.ioctl(fd, UI_DEV_SETUP, setup_structure)
fcntl.ioctl(fd, UI_DEV_CREATE, 0)

def send_event(event_type, code, value):
    # Genera il timestamp reale richiesto da Linux uinput (secondi e microsecondi)
    t = time.time()
    sec = int(t)
    usec = int((t - sec) * 1000000)
    # Struttura standard input_event per sistemi a 64-bit (q = long long, H = unsigned short, i = int)
    ev = struct.pack('qqHHi', sec, usec, event_type, code, value)
    os.write(fd, ev)

server = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
server.setsockopt(socket.SOL_SOCKET, socket.SO_REUSEADDR, 1)
server.setsockopt(socket.IPPROTO_TCP, socket.TCP_NODELAY, 1)
server.bind(('127.0.0.1', 65432))
server.listen(1)

# Variabile per evitare click sovrapposti troppo vicini nel tempo (Debounce)
ultimo_click_time = 0.0

try:
    while True:
        conn, _ = server.accept()
        conn.setsockopt(socket.IPPROTO_TCP, socket.TCP_NODELAY, 1)
        socket_file = conn.makefile('r', encoding='utf-8')
        
        try:
            for linea in socket_file:
                comando = linea.strip().split()
                if not comando: continue
                tipo = comando[0]
                
                if tipo == "KEY":
                    lista_tasti = [int(x) for x in comando[1].split("+")]
                    for tasto in lista_tasti:
                        send_event(1, tasto, 1)
                    send_event(0, 0, 0) # SYN_REPORT
                    
                    time.sleep(0.05) # Pausa interna di pressione
                    
                    for tasto in reversed(lista_tasti):
                        send_event(1, tasto, 0)
                    send_event(0, 0, 0) # SYN_REPORT
                    
                elif tipo == "CLICK":
                    now = time.time()
                    # Protezione: ignora il click se l'ultimo è avvenuto meno di 150ms fa
                    if now - ultimo_click_time < 0.15:
                        continue
                    ultimo_click_time = now

                    # Rimosse le coordinate relative (2,0,0) inutili se non c'è movimento
                    send_event(1, 272, 1) # BTN_LEFT Down
                    send_event(0, 0, 0)   # SYN_REPORT
                    
                    time.sleep(0.05)      # Tempo di pressione realistico (50ms)
                    
                    send_event(1, 272, 0) # BTN_LEFT Up
                    send_event(0, 0, 0)   # SYN_REPORT
                    
                    # Pausa di sicurezza post-click per stabilizzare il sistema operativo
                    time.sleep(0.05)

                elif tipo == "MOUSE":
                    x = int(comando[1])
                    y = int(comando[2])
                    send_event(2, 0, x)   # REL_X
                    send_event(2, 1, y)   # REL_Y
                    send_event(0, 0, 0)   # SYN_REPORT
        except Exception:
            pass
        finally:
            socket_file.close()
            conn.close()
except KeyboardInterrupt:
    pass
finally:
    os.close(fd)
    server.close()
