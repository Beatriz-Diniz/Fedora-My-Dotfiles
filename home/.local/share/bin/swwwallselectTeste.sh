#!/bin/bash

#// set variables

scrDir="$(dirname "$(realpath "$0")")"
source "${scrDir}/globalcontrol.sh"
rofiConf="${confDir}/rofi/selector.rasi"

#// set rofi scaling

[[ "${rofiScale}" =~ ^[0-9]+$ ]] || rofiScale=10
r_scale="configuration {font: \"JetBrainsMono Nerd Font ${rofiScale}\";}"
elem_border=$(( hypr_border * 3 ))

#// scale for monitor

mon_x_res=$(hyprctl -j monitors | jq '.[] | select(.focused==true) | .width')
mon_scale=$(hyprctl -j monitors | jq '.[] | select(.focused==true) | .scale' | sed "s/\.//")
mon_x_res=$(( mon_x_res * 100 / mon_scale ))

#// generate config

elm_width=$(( (28 + 8 + 5) * rofiScale ))
max_avail=$(( mon_x_res - (4 * rofiScale) ))
col_count=$(( max_avail / elm_width ))

# Evita columns=0 caso algo falhe
if [ -z "${col_count}" ] || [ "${col_count}" -lt 1 ]; then
    col_count=1
fi

r_override="window{width:100%;} listview{columns:${col_count};spacing:5em;} element{border-radius:${elem_border}px;orientation:vertical;} element-icon{size:28em;border-radius:0em;} element-text{padding:1em;}"

#// get wallpaper files

wallPathArray=("${hydeThemeDir}")
wallPathArray+=("${wallAddCustomPath[@]}")
wallList=()
wallHash=()

# Collect all image, gif, and video files
for dir in "${wallPathArray[@]}"; do
    [ -d "${dir}" ] || continue

    while IFS= read -r -d '' file; do
        wallList+=("$(basename "$file")")
        wallHash+=("$(set_hash "$file")")
    done < <(
        find "$dir" -type f \
            \( -iname "*.jpg" -o -iname "*.png" -o -iname "*.jpeg" -o -iname "*.gif" -o -iname "*.mp4" \) \
            -print0
    )
done

# Se não encontrou wallpapers, sai sem matar o wallpaper atual
if [ "${#wallList[@]}" -eq 0 ]; then
    notify-send -u critical "Wallpaper" "Nenhum wallpaper encontrado."
    exit 1
fi

#// generate rofi menu entries

currentWall=""
if [ -L "${hydeThemeDir}/wall.set" ]; then
    currentWall="$(basename "$(readlink "${hydeThemeDir}/wall.set")")"
fi

rofiSel=$(
    parallel --link echo -en "\$(basename "{1}")"'\\x00icon\\x1f'"${thmbDir}"'/'"{2}"'.sqre\\n' \
    ::: "${wallList[@]}" ::: "${wallHash[@]}" |
    rofi -dmenu \
        -theme-str "${r_scale}" \
        -theme-str "${r_override}" \
        -config "${rofiConf}" \
        -select "${currentWall}"
)

# Se fechou o rofi ou não selecionou nada, não mata o wallpaper atual
if [ -z "${rofiSel}" ]; then
    exit 0
fi

#// find selected wallpaper

setWall=""

for i in "${!wallPathArray[@]}"; do
    [ -d "${wallPathArray[$i]}" ] || continue

    found="$(find "${wallPathArray[$i]}" -type f -name "${rofiSel}" | head -n 1)"

    if [ -n "${found}" ]; then
        setWall="${found}"
        break
    fi
done

# Se não encontrou o arquivo selecionado, não mata o wallpaper atual
if [ -z "${setWall}" ]; then
    notify-send -u critical "Wallpaper" "Arquivo não encontrado: ${rofiSel}"
    exit 1
fi

#// stop old animated/video wallpaper only after valid selection

pkill -f 'mpv' 2>/dev/null
pkill -f 'swwwanimatedwallpaper.sh' 2>/dev/null

#// ensure swww daemon is running

if ! pgrep -x awww-daemon >/dev/null; then
    awww-daemon &
    sleep 0.5
fi

#// apply wallpaper

case "${setWall,,}" in
    *.mp4)
        "${scrDir}/swwwanimatedwallpaper.sh" -s "${setWall}"
        ;;
    *.gif)
        "${scrDir}/swwwallpaper.sh" -s "${setWall}"
        ;;
    *.jpg|*.jpeg|*.png)
        "${scrDir}/swwwallpaper.sh" -s "${setWall}"
        ;;
    *)
        notify-send -u critical "Wallpaper" "Formato não suportado: ${setWall}"
        exit 1
        ;;
esac

notify-send -a "t1" -i "${thmbDir}/$(set_hash "${setWall}").sqre" " ${rofiSel}"
