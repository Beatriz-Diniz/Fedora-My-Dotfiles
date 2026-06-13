#!/bin/bash

# Diretório onde os arquivos .mp4 estão localizados
videoDir="/home/beatrizdiniz/.config/hyde/themes/Rosé Pine/wallpapers"
# Diretório onde as miniaturas serão salvas
thumbDir="/home/beatrizdiniz/.cache/hyde/thumbs"

# Cria o diretório de miniaturas se não existir
mkdir -p "$thumbDir"

# Encontra todos os arquivos .mp4 no diretório especificado
for videoFile in "$videoDir"/*.mp4; do
    # Verifica se o arquivo realmente existe
    if [ -f "$videoFile" ]; then
        # Extrai o nome do arquivo sem a extensão
        baseName=$(basename "$videoFile" .mp4)
        # Caminho para a miniatura
        thumbFile="${thumbDir}/${baseName}.png"
        # Gera a miniatura
        ffmpeg -i "$videoFile" -vf "thumbnail,scale=512:288" -frames:v 1 "$thumbFile" -loglevel error
        # Verifica se o comando foi bem-sucedido
        if [ $? -eq 0 ]; then
            echo "Thumbnail gerada: $thumbFile"
        else
            echo "Falha ao gerar a thumbnail para $videoFile"
        fi
    else
        echo "Arquivo não encontrado: $videoFile"
    fi
done

