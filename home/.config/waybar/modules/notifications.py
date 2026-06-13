#!/usr/bin/env python3

import json
import subprocess

# Ícones correspondentes ao tipo de notificação (você pode personalizar isso)
ICON_MAP = {
    "email": "email-notification",
    "chat": "chat-notification",
    "warning": "warning-notification",
    "error": "error-notification",
    "network": "network-notification",
    "battery": "battery-notification",
    "update": "update-notification",
    "music": "music-notification",
    "volume": "volume-notification",
    "default": "notification"
}

def get_notifications():
    try:
        result = subprocess.run(["dunstctl", "history"], capture_output=True, check=True, text=True)
        data = json.loads(result.stdout)

        if not data:
            return {"text": "", "icon": "none"}

        # Pegamos a notificação mais recente
        notif = data[-1]

        summary = notif.get("summary", "").lower()
        appname = notif.get("appname", "").lower()

        # Inferência de tipo de notificação
        if "mail" in appname or "mail" in summary:
            icon = ICON_MAP["email"]
        elif "chat" in appname or "message" in summary:
            icon = ICON_MAP["chat"]
        elif "error" in summary or notif.get("urgency") == "critical":
            icon = ICON_MAP["error"]
        elif "warning" in summary:
            icon = ICON_MAP["warning"]
        elif "update" in summary:
            icon = ICON_MAP["update"]
        elif "battery" in summary:
            icon = ICON_MAP["battery"]
        elif "volume" in summary:
            icon = ICON_MAP["volume"]
        elif "music" in summary:
            icon = ICON_MAP["music"]
        else:
            icon = ICON_MAP["default"]

        return {
            "text": "",  # Você pode colocar o resumo aqui se quiser exibir texto
            "icon": icon
        }

    except Exception as e:
        # Se der erro, ícone padrão
        return {"text": "", "icon": "none"}

if __name__ == "__main__":
    print(json.dumps(get_notifications()))

