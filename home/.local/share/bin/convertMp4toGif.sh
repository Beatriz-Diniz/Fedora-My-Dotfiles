#!/bin/bash

# Diretórios
hydeThemeDir="/home/beatrizdiniz/.config/hyde/themes/Rosé Pine/wallpapers"
cacheDir="/home/beatrizdiniz/.cache/hyde/thumbs"

# Cria o diretório de cache se ele não existir
mkdir -p "$cacheDir"

# Converte todos os arquivos .mp4 para .gif
for videoFile in "$hydeThemeDir"/*.mp4; do
    if [ -f "$videoFile" ]; then
        # Nome do arquivo sem extensão
        baseName=$(basename "$videoFile" .mp4)
        # Caminho do arquivo de saída
        outputGif="$hydeThemeDir/$baseName.gif"
        # Converte o vídeo para gif com a mesma resolução e fps do vídeo original, e com maior qualidade e suavização
        ffmpeg -i "$videoFile" -vf "fps=15,scale=2560:1600:flags=lanczos,split[s0][s1];[s0]palettegen=max_colors=256[p];[s1][p]paletteuse=dither=bayer:bayer_scale=4" -b:v 2M -y "$outputGif" -loglevel error
        echo "Convertido: $videoFile -> $outputGif"
    fi
done

echo "Conversão concluída!"
