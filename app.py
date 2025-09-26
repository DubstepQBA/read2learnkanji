# Archivo principal para Railway - redirige al backend
import sys
import os

# Agregar el directorio del backend al path
sys.path.insert(0, os.path.join(os.path.dirname(__file__), 'src', 'furigana-api'))

# Importar la aplicación del backend
from app import app

if __name__ == "__main__":
    app.run()