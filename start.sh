#!/bin/bash

echo "=== INICIANDO APLICACIÓN ==="
echo "Directorio actual: $(pwd)"

# Detectar el backend automáticamente
APP_PY=$(find . -name "app.py" -type f | head -1)
if [ -n "$APP_PY" ]; then
    BACKEND_DIR=$(dirname "$APP_PY")
    echo "Backend detectado en: $BACKEND_DIR"
    echo "Contenido del backend:"
    ls -la "$BACKEND_DIR"
    
    echo "Iniciando gunicorn..."
    cd "$BACKEND_DIR"
    exec gunicorn --bind 0.0.0.0:$PORT --workers 1 --timeout 120 app:app
else
    echo "ERROR: No se encontró app.py"
    exit 1
fi