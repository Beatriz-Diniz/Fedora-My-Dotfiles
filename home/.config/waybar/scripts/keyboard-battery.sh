#!/usr/bin/env bash

DEVICE="/org/freedesktop/UPower/devices/keyboard_dev_FC_AE_73_72_22_EB"

if ! upower -i "$DEVICE" &>/dev/null; then
    echo '{"text":"","tooltip":"Teclado não encontrado","class":"unknown"}'
    exit 0
fi

INFO="$(upower -i "$DEVICE")"
PERCENTAGE="$(echo "$INFO" | awk -F: '/percentage/ {gsub(/ /,"",$2); print $2}')"
STATE="$(echo "$INFO" | awk -F: '/state/ {gsub(/^ +/,"",$2); print $2}')"
MODEL="$(echo "$INFO" | awk -F: '/model/ {gsub(/^ +/,"",$2); print $2}')"

if [ -z "$PERCENTAGE" ]; then
    echo '{"text":"","tooltip":"Bateria do teclado indisponível","class":"unknown"}'
    exit 0
fi

if [ "$STATE" = "unknown" ] || [ -z "$STATE" ]; then
    STATE="indisponível"
fi

VALUE="${PERCENTAGE%\%}"

if [ "$VALUE" -le 20 ]; then
    CLASS="critical"
elif [ "$VALUE" -le 40 ]; then
    CLASS="warning"
else
    CLASS="good"
fi

echo "{\"text\":\"󰌌 $PERCENTAGE\",\"tooltip\":\"Teclado: ${MODEL:-TH108 PRO}\nBateria: $PERCENTAGE\nEstado: $STATE\",\"class\":\"$CLASS\"}"
