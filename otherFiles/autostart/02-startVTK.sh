#!/bin/bash

LOG_FILE="/storage/.config/VTK/startVTK.log"
SWAY_CONFIG="/storage/.config/sway/config"

mount --bind /storage/.config/VTK/vertical-check /usr/bin/vertical-check

run_config() {    
    echo "$(date '+%H:%M:%S') - Attesa Sway..." >> "$LOG_FILE"
    while ! swaymsg -t get_outputs >/dev/null 2>&1; do
        sleep 0.5
    done
    
    echo "$(date '+%H:%M:%S') - Sway pronto. Invio comandi..." >> "$LOG_FILE"
    sleep 1

    # Verifica se la regola è già presente per evitare duplicati
    if ! grep -q "checkVTK" "$SWAY_CONFIG"; then
        # Appende le regole in fondo al file

    	echo 'for_window [app_id="scummvm"] exec /storage/.config/VTK/checkVTK.sh "scummvm"' >> "$SWAY_CONFIG"
	echo 'for_window [app_id="^(?!emulationstation$).*"] exec /storage/.config/VTK/launchFilter.sh' >> "$SWAY_CONFIG"
	echo 'for_window [app_id="emulationstation"] exec kill -9 $(pidof vtk) 2>/dev/null; exec /storage/.config/VTK/changeDisplayCalibrationMatrix.sh' >> "$SWAY_CONFIG"
    fi

    # Forza Swig/Sway a ricaricare la configurazione senza riavviare
    swaymsg reload

    echo "$(date '+%H:%M:%S') - Fine." >> "$LOG_FILE"
}

run_config &