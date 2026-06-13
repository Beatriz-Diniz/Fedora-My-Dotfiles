#!/bin/bash

# ─── Configurações ──────────────────────────────────────────────────────────────

# Nome dos monitores (altere conforme necessário)
monitor_interno="eDP-1"         # Monitor do notebook
monitor_externo="HDMI-A-1"      # Monitor externo

# ─── Função: Mudar Modo de Visualização ─────────────────────────────────────────

mudar_modo_visualizacao() {
  # Menu interativo via rofi
  #modo=$(echo -e "Estendido\nSomente Monitor Interno\nSomente Monitor Externo" | rofi -dmenu -p "Modo de exibição")
  modo=$(echo -e "Estendido\nSomente Monitor Interno\nSomente Monitor Externo" | rofi -theme ~/.config/waybar/modules/rofi-monitor-theme.rasi -dmenu -p "Modo")

  case "$modo" in
    "Estendido")
      hyprctl keyword monitor "$monitor_interno, preferred, auto, auto"
      hyprctl keyword monitor "$monitor_externo, 2560x1080@60, 0x-1080"
      notify-send "Hyprland" "󰍺 Modo de visualização: Estendido"
      ;;

    "Somente Monitor Interno")
      hyprctl keyword monitor "$monitor_interno, preferred, auto, auto"
      hyprctl keyword monitor "$monitor_externo, disable"
      notify-send "Hyprland" "💻 Modo de visualização: Somente Monitor Interno"
      ;;

    "Somente Monitor Externo")
      hyprctl keyword monitor "$monitor_interno, disable"
      hyprctl keyword monitor "$monitor_externo, 2560x1080@60, 0x0"
      notify-send "Hyprland" "🖥️ Modo de visualização: Somente Monitor Externo"
      ;;

    *) 
      # Caso o usuário cancele o menu
      exit 0
      ;;
  esac
}

# ─── Execução ───────────────────────────────────────────────────────────────────

mudar_modo_visualizacao

