#!/bin/bash

# Script de construcción para Railway

echo "Directorio actual: $(pwd)"
echo "Contenido del directorio:"
ls -la

# Detectar la ruta correcta al backend
if [ -d "src/furigana-api" ]; then
    BACKEND_DIR="src/furigana-api"
elif [ -d "furigana-api" ]; then
    BACKEND_DIR="furigana-api"
else
    echo "Buscando directorio furigana-api..."
    find . -name "furigana-api" -type d
    echo "ERROR: No se encontró el directorio furigana-api"
    exit 1
fi

echo "Usando backend en: $BACKEND_DIR"

echo "Instalando dependencias del sistema..."
apt-get update
apt-get install -y tesseract-ocr tesseract-ocr-jpn poppler-utils python3-pip

echo "Configurando Python..."
python3 -m ensurepip --upgrade
python3 -m pip install --upgrade pip

echo "Instalando dependencias de Python..."
if [ -f "$BACKEND_DIR/requirements.txt" ]; then
    pip3 install -r $BACKEND_DIR/requirements.txt
    pip3 install gunicorn
    echo "Dependencias instaladas exitosamente"
else
    echo "ERROR: No se encontró $BACKEND_DIR/requirements.txt"
    exit 1
fi