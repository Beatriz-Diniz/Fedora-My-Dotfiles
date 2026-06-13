#!/bin/bash

internal_monitor="eDP-1"
external_monitor="HDMI-A-1"
last_state=""

while true; do
    # Verifica se o monitor externo está conectado
    if hyprctl monitors | grep -q "$external_monitor"; then
        current_state="external_connected"
    else
        current_state="external_disconnected"
    fi
    
    # Só aplica as mudanças se o estado do monitor mudou
    if [ "$current_state" != "$last_state" ]; then
        if [ "$current_state" == "external_connected" ]; then
            hyprctl keyword monitor "$internal_monitor, disable, auto, auto"
            hyprctl keyword monitor "$external_monitor, preferred, auto, auto"
        else
            hyprctl keyword monitor "$internal_monitor, preferred, auto, auto"
        fi
        last_state="$current_state"
    fi

    # Aguarda 5 segundos antes de verificar novamente
    sleep 5
done
