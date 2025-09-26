#!/bin/bash
set -e

echo "=== INICIANDO BUILD ==="
echo "Directorio actual: $(pwd)"
echo "Contenido inicial:"
ls -la

# Buscar el directorio furigana-api
echo "Buscando furigana-api..."
if [ -d "src/furigana-api" ]; then
    echo "✓ Encontrado: src/furigana-api"
    BACKEND_DIR="src/furigana-api"
elif [ -d "furigana-api" ]; then
    echo "✓ Encontrado: furigana-api"
    BACKEND_DIR="furigana-api"
else
    echo "✗ ERROR: No se encontró furigana-api"
    echo "Buscando en todo el proyecto..."
    find . -name "furigana-api" -type d
    exit 1
fi

echo "Contenido de $BACKEND_DIR:"
ls -la "$BACKEND_DIR"

# Verificar que existe requirements.txt
if [ ! -f "$BACKEND_DIR/requirements.txt" ]; then
    echo "✗ ERROR: No se encontró requirements.txt en $BACKEND_DIR"
    exit 1
fi

echo "Instalando dependencias del sistema..."
apt-get update
apt-get install -y python3-pip python3-dev tesseract-ocr tesseract-ocr-jpn poppler-utils

echo "Configurando Python..."
python3 -m ensurepip --upgrade
python3 -m pip install --upgrade pip

echo "Instalando dependencias de Python..."
pip3 install -r "$BACKEND_DIR/requirements.txt"
pip3 install gunicorn

echo "=== BUILD COMPLETADO ==="