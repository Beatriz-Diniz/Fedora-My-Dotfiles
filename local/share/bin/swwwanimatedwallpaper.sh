#!/bin/bash

# Função para aplicar o wallpaper usando mpvpaper com resolução dinâmica
apply_wallpaper() {
    local video_file="$1"
    local screen_resolution="2560x1600"  # Resolução da sua tela 2K

    echo "Applying wallpaper with mpvpaper: ${video_file}"
    mpvpaper '*' -o "--loop=yes --no-audio --hwdec=auto --geometry=2560x1600 --force-window --no-border --no-keepaspect --profile=gpu-hq --vo=gpu --hwdec=vaapi --framedrop=vo --vid=1 --cache-secs=5" "${video_file}"
}

# Função para gerar hash para arquivos de vídeo
set_hash_video() {
    local video_file="$1"
    sha1sum "${video_file}" | awk '{print $1}'
}

# Função para gerar cache para vídeo
cache_video() {
    local video_file="$1"
    local hash=$(set_hash_video "${video_file}")
    
    echo "Generating cache for video: ${video_file} with hash: ${hash}"

    # Diretórios de cache
    local thmbDir="${cacheDir}/thumbs"
    local dcolDir="${cacheDir}/dcols"

    # Cria diretórios se não existirem
    [ ! -d "${thmbDir}" ] && mkdir -p "${thmbDir}"
    [ ! -d "${dcolDir}" ] && mkdir -p "${dcolDir}"

    # Gera o GIF do vídeo com a mesma resolução
    local gif="${cacheDir}/${hash}.gif"
    if [ ! -e "${gif}" ]; then
        echo "GIF not found, generating: ${gif}"
        ffmpeg -i "${video_file}" -vf "fps=60,scale=2560:1600:flags=lanczos" -y "${gif}" -loglevel error
    else
        echo "GIF already exists: ${gif}"
    fi

    # Gera a miniatura do GIF
    local thumbnail="${thmbDir}/${hash}.gif"
    if [ ! -e "${thumbnail}" ]; then
        echo "Thumbnail not found, generating: ${thumbnail}"
        ffmpeg -i "${gif}" -vf "fps=1,scale=500:-1:flags=lanczos" -vframes 1 "${thumbnail}" -loglevel error
    else
        echo "Thumbnail already exists: ${thumbnail}"
    fi

    # Processa a miniatura gerada
    local square="${thmbDir}/${hash}.sqre"
    local blur="${thmbDir}/${hash}.blur"
    local quad="${thmbDir}/${hash}.quad"
    [ ! -e "${square}" ] && magick convert -strip -resize 500x500^ -gravity center -extent 500x500 "${thumbnail}" "${square}"
    [ ! -e "${blur}" ] && magick convert -strip -scale 10% -blur 0x3 -resize 100% "${square}" "${blur}"
    [ ! -e "${quad}" ] && magick convert "${square}" \( -size 500x500 xc:white -fill "rgba(0,0,0,0.7)" -draw "polygon 400,500 500,500 500,0 450,0" -fill black -draw "polygon 500,500 500,0 450,500" \) -alpha Off -compose CopyOpacity -composite "${quad}"

    # Gera a paleta de cores
    if [ ! -e "${dcolDir}/${hash}.dcol" ]; then
        echo "Generating color palette for: ${thumbnail}"
        "${scrDir}/wallbash.sh" --custom "${wallbashCustomCurve}" "${thumbnail}" "${dcolDir}/${hash}" &> /dev/null
    fi
}

# Verifica se mpvpaper está instalado
if ! command -v mpvpaper &> /dev/null; then
    echo "Error: mpvpaper is not installed or not found in PATH."
    echo "Please make sure you have installed mpvpaper correctly."
    exit 1
fi

# Define variáveis
scrDir="$(dirname "$(realpath "$0")")"
source "${scrDir}/globalcontrol.sh"
cacheDir="/home/beatrizdiniz/.cache/hyde"  # Ajuste o caminho do cache conforme necessário

# Avalia opções
while getopts ":s:" option; do
    case $option in
    s) # Define o wallpaper de entrada
        if [ ! -z "${OPTARG}" ] && [ -f "${OPTARG}" ]; then
            echo "Setting wallpaper from file: ${OPTARG}"
            # Adiciona a lógica de cache
            cache_video "${OPTARG}"
            apply_wallpaper "${OPTARG}"
        else
            echo "Error: Invalid file specified for option -s"
            exit 1
        fi
        ;;
    *) # Opção inválida
        echo "Usage: $(basename "${0}") [-s <video_file>]"
        exit 1
        ;;
    esac
done

# Se nenhuma opção for fornecida, exibe a mensagem de uso
if [ $OPTIND -eq 1 ]; then
    echo "Usage: $(basename "${0}") [-s <video_file>]"
    exit 1
fi
