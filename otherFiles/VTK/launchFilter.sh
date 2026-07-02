#!/bin/bash
LOG_FILE="/storage/.config/VTK/startVTK.log"

# 1. Recupera il PID della finestra che ha appena attivato la regola Sway
WINDOW_PID=$(swaymsg -t get_tree | jq -r '.. | select(.focused? == true) | .pid')

# Sicurezza: se il PID non è valido o è vuoto, interrompe subito
if [ -z "$WINDOW_PID" ] || [ "$WINDOW_PID" = "null" ]; then
    exit 0
fi

# 2. Recupera il PID del processo padre (PPID)
PARENT_PID=$(ps -o ppid= -p $WINDOW_PID | tr -d ' ')

# 3. Combina le linee di comando (cmdline) di entrambi i processi per l'ispezione
CMD_CHECK=$(cat /proc/$WINDOW_PID/cmdline /proc/$PARENT_PID/cmdline 2>/dev/null | tr '\0' ' ')

# 4. Controllo dei percorsi critici di PortMaster
if echo "$CMD_CHECK" | grep -qE "roms/ports|storage/ports|PortMaster"; then
    echo "$(date '+%H:%M:%S') - Lancio Gioco PortMaster" >> "$LOG_FILE"
    # =========================================================
    # ZONE PORTMASTER: Inserisci qui i comandi per i tuoi giochi
    # =========================================================
    /storage/.config/VTK/checkVTK.sh "portMaster"
else
    # =========================================================
    # ALTRI EMULATORI:  
    # =========================================================
    # Di qua ci passano tutti gli altri programmi eseguiti tranne che i giochi portMaster ed Emulation Station
    # Tutti i CORE RetroArch passano da vertical-check, NON inserire qui
    # Tutti i giochi di SCUMMVM hanno una loro regola separta, NON inserire qui
    exit 0
fi
