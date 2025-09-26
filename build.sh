#!/bin/bash

# Instalar dependencias del sistema
apt-get update
apt-get install -y tesseract-ocr tesseract-ocr-jpn poppler-utils

# Instalar dependencias de Python
cd src/furigana-api
pip install -r requirements.txt

echo "Build completado exitosamente"