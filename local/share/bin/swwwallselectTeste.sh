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
r_override="window{width:100%;} listview{columns:${col_count};spacing:5em;} element{border-radius:${elem_border}px;orientation:vertical;} element-icon{size:28em;border-radius:0em;} element-text{padding:1em;}"

#// get wallpaper files

wallPathArray=("${hydeThemeDir}")
wallPathArray+=("${wallAddCustomPath[@]}")
wallList=()
wallHash=()

# Collect all image, gif, and video files
for dir in "${wallPathArray[@]}"; do
    while IFS= read -r -d '' file; do
        if [[ "$file" == *.jpg || "$file" == *.png || "$file" == *.jpeg || "$file" == *.gif || "$file" == *.mp4 ]]; then
            wallList+=("$(basename "$file")")
            wallHash+=("$(set_hash "$file")")
        fi
    done < <(find "$dir" -type f \( -iname "*.jpg" -o -iname "*.png" -o -iname "*.jpeg" -o -iname "*.gif" -o -iname "*.mp4" \) -print0)
done

# Stop any currently running MPV instance or video wallpaper
pkill -f 'mpv'
pkill -f 'swwwanimatedwallpaper.sh'

# Generate Rofi menu entries
rofiSel=$(parallel --link echo -en "\$(basename "{1}")"'\\x00icon\\x1f'"${thmbDir}"'/'"{2}"'.sqre\\n' ::: "${wallList[@]}" ::: "${wallHash[@]}" | rofi -dmenu -theme-str "${r_scale}" -theme-str "${r_override}" -config "${rofiConf}" -select "$(basename "$(readlink "${hydeThemeDir}/wall.set")")")

#// apply wallpaper

if [ ! -z "${rofiSel}" ] ; then
    for i in "${!wallPathArray[@]}" ; do
        setWall="$(find "${wallPathArray[i]}" -type f -name "${rofiSel}")"
        [ -z "${setWall}" ] || break
    done
    if [[ "${setWall}" == *.mp4 ]]; then
        # Handle video wallpaper
        "${scrDir}/swwwanimatedwallpaper.sh" -s "${setWall}"
    elif [[ "${setWall}" == *.gif ]]; then
        # Handle GIF wallpaper
        "${scrDir}/swwwanimatedwallpaper.sh" -s "${setWall}"
    else
        # Handle static image wallpaper
        "${scrDir}/swwwallpaper.sh" -s "${setWall}"
    fi
    notify-send -a "t1" -i "${thmbDir}/$(set_hash "${setWall}").sqre" " ${rofiSel}"
fi
