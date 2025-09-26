#!/bin/bash

# Script de construcción para Railway

echo "Instalando dependencias del sistema..."
apt-get update
apt-get install -y tesseract-ocr tesseract-ocr-jpn poppler-utils python3-pip

echo "Configurando Python..."
python3 -m ensurepip --upgrade
python3 -m pip install --upgrade pip

echo "Instalando dependencias de Python..."
pip3 install -r src/furigana-api/requirements.txt
pip3 install gunicorn

echo "Build completado exitosamente"