#!/bin/bash
set -e

# Script de construcción para Railway

echo "Directorio actual: $(pwd)"
echo "Contenido del directorio:"
ls -la

echo "Buscando directorio furigana-api..."

# Verificar si existe src y explorarlo
if [ -d "src" ]; then
    echo "Contenido de src/:"
    ls -la src/
    if [ -d "src/furigana-api" ]; then
        echo "Encontrado src/furigana-api"
        BACKEND_DIR="src/furigana-api"
    else
        # Buscar furigana-api dentro de src
        FURIGANA_IN_SRC=$(find src -name "furigana-api" -type d 2>/dev/null | head -1)
        if [ -n "$FURIGANA_IN_SRC" ]; then
            echo "Encontrado furigana-api en: $FURIGANA_IN_SRC"
            BACKEND_DIR="$FURIGANA_IN_SRC"
        fi
    fi
elif [ -d "furigana-api" ]; then
    echo "Encontrado furigana-api"
    BACKEND_DIR="furigana-api"
else
    # Buscar en cualquier lugar del proyecto
    FURIGANA_DIR=$(find . -name "furigana-api" -type d 2>/dev/null | head -1)
    if [ -n "$FURIGANA_DIR" ]; then
        echo "Encontrado furigana-api en: $FURIGANA_DIR"
        BACKEND_DIR="$FURIGANA_DIR"
    else
        echo "ERROR: No se encontró el directorio furigana-api"
        echo "Buscando requirements.txt en cualquier lugar:"
        find . -name "requirements.txt" -type f
        echo "Buscando app.py en cualquier lugar:"
        find . -name "app.py" -type f
        exit 1
    fi
fi

echo "Usando BACKEND_DIR: $BACKEND_DIR"
echo "Contenido de $BACKEND_DIR:"
ls -la "$BACKEND_DIR"

echo "Instalando dependencias del sistema..."
apt-get update
apt-get install -y tesseract-ocr tesseract-ocr-jpn poppler-utils python3-pip python3-dev

echo "Configurando Python..."
python3 -m ensurepip --upgrade
python3 -m pip install --upgrade pip

echo "Instalando dependencias de Python..."
if [ -f "${BACKEND_DIR}/requirements.txt" ]; then
    echo "Instalando desde ${BACKEND_DIR}/requirements.txt"
    pip3 install -r "${BACKEND_DIR}/requirements.txt"
    pip3 install gunicorn
    echo "Dependencias instaladas exitosamente"
else
    echo "ERROR: No se encontró requirements.txt en ${BACKEND_DIR}"
    exit 1
fi