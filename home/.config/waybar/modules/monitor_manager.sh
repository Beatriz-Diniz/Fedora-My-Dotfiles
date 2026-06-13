#!/bin/bash

# Nome dos monitores
monitor_interno="eDP-1" # Nome do monitor do notebook. Altere conforme necessário.
monitor_externo="HDMI-A-1" # Nome do monitor externo. Altere conforme necessário.

# Função para mudar o modo de visualização
mudar_modo_visualizacao() {
  modo=$(echo -e "Estendido\nSomente Monitor Interno\nSomente Monitor Externo" | rofi -dmenu -p "Selecione o modo de visualização")
  case "$modo" in
    "Estendido") 
      hyprctl keyword monitor "$monitor_interno, preferred, auto, auto"
      hyprctl keyword monitor "$monitor_externo,2560x1080@60,0x-1080"
      notify-send "Hyprland" "Modo de visualização: Estendido."
      ;;
    "Somente Monitor Interno")
      hyprctl keyword monitor "$monitor_interno, preferred, auto, auto"
      hyprctl keyword monitor "$monitor_externo, disable"
      notify-send "Hyprland" "Modo de visualização: Somente Monitor Interno."
      ;;
    "Somente Monitor Externo")
      hyprctl keyword monitor "$monitor_interno, disable"
      hyprctl keyword monitor "$monitor=HDMI-A-1,2560x1080@60,0x-1080"
      notify-send "Hyprland" "Modo de visualização: Somente Monitor Externo."
      ;;
    *) exit 0 ;;
  esac
}

# Executa a função para mudar o modo de visualização
mudar_modo_visualizacao
