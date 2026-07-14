#!/bin/bash

LOG_FILE="/storage/.config/VTK/startVTK.log"
SWAY_CONFIG="/storage/.config/sway/config"
SERVICE_NAME="vtkdaemon"

mount --bind /storage/.config/VTK/vertical-check /usr/bin/vertical-check

check_service() {
    if systemctl is-active --quiet "$1"; then
        return 0 # Service OK
    else
        return 1 # Service KO
    fi
}

check_installation() {
    rm -f "$LOG_FILE"
    echo "$(date '+%H:%M:%S') - Check Installation..." >> "$LOG_FILE"
    if check_service "$SERVICE_NAME"; then
	echo "$(date '+%H:%M:%S') - The serice $SERVICE_NAME is active" >> "$LOG_FILE"
    else
	echo "$(date '+%H:%M:%S') - The service $SERVICE_NAME is inactive" >> "$LOG_FILE"

	cp /storage/.config/VTK/vtkdaemon.service /storage/.config/system.d/
	chmod +x /storage/.config/VTK/VTKDaemon.py
	systemctl daemon-reload
	systemctl enable --now vtkdaemon

	echo "$(date '+%H:%M:%S') - Service installed and enabled" >> "$LOG_FILE"

	chmod +x /storage/.config/VTK/changeDisplayCalibrationMatrix.sh
	chmod +x /storage/.config/VTK/checkVTK.sh
	chmod +x /storage/.config/VTK/launchFilter.sh
	chmod +x /storage/.config/VTK/vertical-check
	chmod +x /storage/.config/VTK/vtk
    fi
}

run_config() {    
    check_installation

    echo "$(date '+%H:%M:%S') - Waiting Sway..." >> "$LOG_FILE"
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