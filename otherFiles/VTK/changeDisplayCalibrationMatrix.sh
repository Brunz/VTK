#!/bin/sh

# Controlla se è stato passato il parametro "ABS"
if [ "$1" = "ABS" ]; then
    # Matrici da applicare in modalità ABS (Modifica i numeri se necessario)
    MATRICE_SX="0.5 0.0 0.0 0.0 1.0 0.0"
    MATRICE_DX="0.55 0.0 0.0 0.0 1.0 0.0"
else
    # Matrici da applicare in modalità normale (Default)
    MATRICE_SX="0.5 0.0 0.0 0.0 1.0 0.0"
    MATRICE_DX="0.5 0.0 0.5 0.0 1.0 0.0"
fi

# 1. Scrive la regola udev iniettando le matrici corrette
cat << EOF > /etc/udev/rules.d/99-touchscreen.rules
SUBSYSTEM=="input", ENV{ID_PATH}=="platform-fe5c0000.i2c", ENV{LIBINPUT_CALIBRATION_MATRIX}="$MATRICE_SX"
SUBSYSTEM=="input", ENV{ID_PATH}=="platform-fe5e0000.i2c", ENV{LIBINPUT_CALIBRATION_MATRIX}="$MATRICE_DX"
EOF

# 2. Ricarica udev
udevadm control --reload-rules

# 3. Disconnetti SOLO i due touchscreen puntando direttamente i loro eventi
udevadm trigger --action=remove --subsystem-match=input /dev/input/event1
udevadm trigger --action=remove --subsystem-match=input /dev/input/event2

# 4. Riconnetti SOLO i due touchscreen puntando direttamente i loro eventi
udevadm trigger --action=add --subsystem-match=input /dev/input/event1
udevadm trigger --action=add --subsystem-match=input /dev/input/event2

# 3. Disconnetti i touchscreen a livello di Kernel (Simula la rimozione fisica)
# udevadm trigger --action=remove --subsystem-match=input

# 4. Riconnetti i touchscreen (Simula l'inserimento, udev leggerà la regola!)
# udevadm trigger --action=add --subsystem-match=input

sleep 0.3

# 5. Cancella SUBITO la regola dalla cartella di sistema
# (Così al prossimo riavvio del device la cartella torna vuota e pulita!)
rm /etc/udev/rules.d/99-touchscreen.rules
udevadm control --reload-rules