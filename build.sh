#!/bin/bash
set -e

echo "=== INICIANDO BUILD ==="
echo "Directorio actual: $(pwd)"
echo "Contenido inicial:"
ls -la

echo "=== EXPLORANDO DIRECTORIO SRC ==="
if [ -d "src" ]; then
    echo "Contenido de src/:"
    ls -la src/
    echo "Buscando furigana-api dentro de src..."
    find src -name "*furigana*" -type d 2>/dev/null || echo "No hay directorios con 'furigana'"
    find src -name "*api*" -type d 2>/dev/null || echo "No hay directorios con 'api'"
    echo "Todos los subdirectorios de src:"
    find src -type d 2>/dev/null
else
    echo "✗ ERROR: No existe el directorio src"
fi

echo "=== BUSCANDO BACKEND EN TODO EL PROYECTO ==="
echo "Buscando app.py en todo el proyecto:"
find . -name "app.py" -type f

echo "Buscando requirements.txt en todo el proyecto:"
find . -name "requirements.txt" -type f

echo "Buscando cualquier directorio con 'api' en el nombre:"
find . -name "*api*" -type d

echo "Buscando cualquier directorio con 'furigana' en el nombre:"
find . -name "*furigana*" -type d

echo "=== INTENTANDO DETECTAR BACKEND ==="
# Buscar el backend basándonos en app.py y requirements.txt
APP_PY=$(find . -name "app.py" -type f | head -1)
REQ_TXT=$(find . -name "requirements.txt" -type f | head -1)

if [ -n "$APP_PY" ] && [ -n "$REQ_TXT" ]; then
    echo "Encontrados archivos backend:"
    echo "  app.py: $APP_PY"
    echo "  requirements.txt: $REQ_TXT"
    
    # Extraer el directorio del backend
    BACKEND_DIR=$(dirname "$APP_PY")
    echo "  Backend detectado en: $BACKEND_DIR"
    
    echo "Contenido del backend detectado:"
    ls -la "$BACKEND_DIR"
else
    echo "✗ ERROR: No se pudieron detectar los archivos del backend"
    exit 1
fi

echo "=== INSTALANDO DEPENDENCIAS ==="
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