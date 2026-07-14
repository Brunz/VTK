#!/bin/bash

LOG_FILE="/storage/.config/VTK/startVTK.log"

appID="$1"
canVertical="$2"

VTK_DIR="/storage/.config/VTK"
VTK_PID_FILE="/storage/.config/VTK/vtk.pid"
OUTPUT="DSI-1"

avvia_VTK() {
    . /etc/profile #riga fondamentale

    # Controllo doppie istanze (Logica nativa)
    if [ -f "${VTK_PID_FILE}" ] && kill -0 "$(cat "${VTK_PID_FILE}" 2>/dev/null)" 2>/dev/null; then
        exit 0
    fi
    if pgrep -f 'vtk' >/dev/null 2>&1; then
        echo "$(date '+%H:%M:%S') - Processo già aperto" >> "$LOG_FILE"
        exit 0
    fi

    # Assicuriamoci che lo schermo inferiore sia alimentato
    swaymsg "output ${OUTPUT} power on" >/dev/null 2>&1
    
    # Avviamo VTK ereditando l'ambiente grafico di Sway senza export manuali
    if [ "${canVertical}" = "true" ]; then
        echo "$(date '+%H:%M:%S') - Eseguo VTK - ${appID} - canVertical is true" >> "$LOG_FILE"
	(cd "${VTK_DIR}" && exec ./vtk canVertical appID "${appID}" >/dev/null 2>&1) & echo $! > "${VTK_PID_FILE}"
    else
        echo "$(date '+%H:%M:%S') - Eseguo VTK - ${appID} - canVertical is false" >> "$LOG_FILE"
    	(cd "${VTK_DIR}" && exec ./vtk >/dev/null 2>&1) & echo $! > "${VTK_PID_FILE}"
    fi

    # Ciclo di attesa per l'indicizzazione
    for _ in $(seq 1 40); do
        if swaymsg -t get_tree 2>/dev/null | grep -q '"app_id": "VTK"'; then
            break
        fi
        sleep 0.05
    done

    # Spostamento visivo sul display corretto usando il focus ereditato
    swaymsg "[app_id=\"VTK\"] move container to output ${OUTPUT}, fullscreen enable" >/dev/null 2>&1 ||:
    exit 0
}

echo "$(date '+%H:%M:%S') - Sto preparando VTK per ${appID}" >> "$LOG_FILE"
if [ "$appID" != "" ]; then

    sleep 0.2

    # Same notes from above apply here.
    # swaymsg '[app_id="scummvm"] output DSI-2 pos 0 0, output DSI-1 power on pos 0 480'
    # swaymsg '[app_id="scummvm"] floating enable, fullscreen disable, resize set 640 960, move to output DSI-2, move absolute position 0 0'
    # swaymsg 'input "1046:911:Goodix_Capacitive_TouchScreen" calibration_matrix 1 0 0 0 0.5 0.5'

    # swaymsg "output DSI-1 power on" >/dev/null 2>&1
    # swaymsg '[app_id="scummvm"] move to output DSI-2, fullscreen enable'
    # swaymsg 'input "1046:911:Goodix_Capacitive_TouchScreen" calibration_matrix 0.5 0 0 0 1 0'
	
    avvia_VTK

else
    echo "$(date '+%H:%M:%S') - Nessun parametro valido ricevuto (ricevuto: '$appID')" >> "$LOG_FILE"
    # Comportamento di default se lo script viene avviato senza argomenti
fi


