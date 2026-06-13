#!/bin/bash
# ~/.config/hypr/lock-and-suspend.sh

# 1. Timer para suspender após inatividade
swayidle -w \
    timeout 120 'systemctl suspend' &

# 2. Salva PID
IDLE_PID=$!

# 3. Lock com hyprlock (bloqueia até desbloquear)
hyprlock

# 4. Se desbloquear antes do suspend → mata o timer
kill $IDLE_PID 2>/dev/null