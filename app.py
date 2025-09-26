# Archivo principal para Railway - redirige al backend
import sys
import os

print("Iniciando app.py desde:", os.path.dirname(__file__))
print("Contenido del directorio:", os.listdir(os.path.dirname(__file__)))

# Intentar diferentes rutas posibles para el backend
backend_paths = [
    os.path.join(os.path.dirname(__file__), 'src', 'furigana-api'),
    os.path.join(os.path.dirname(__file__), 'furigana-api'),
]

backend_found = False
for path in backend_paths:
    print(f"Verificando ruta: {path}")
    if os.path.exists(path):
        print(f"Encontrado backend en: {path}")
        sys.path.insert(0, path)
        backend_found = True
        break

if not backend_found:
    # Buscar en cualquier lugar
    import glob
    possible_backends = glob.glob('**/furigana-api', recursive=True)
    print(f"Backends encontrados: {possible_backends}")
    if possible_backends:
        backend_path = os.path.join(os.path.dirname(__file__), possible_backends[0])
        print(f"Usando backend encontrado: {backend_path}")
        sys.path.insert(0, backend_path)
        backend_found = True

if not backend_found:
    print("ERROR: No se encontró el directorio furigana-api")
    print("Estructura del proyecto:")
    for root, dirs, files in os.walk('.'):
        level = root.replace('.', '').count(os.sep)
        indent = ' ' * 2 * level
        print(f"{indent}{os.path.basename(root)}/")
        subindent = ' ' * 2 * (level + 1)
        for file in files[:5]:  # Mostrar solo primeros 5 archivos
            print(f"{subindent}{file}")
        if len(files) > 5:
            print(f"{subindent}... y {len(files)-5} archivos más")
    sys.exit(1)

# Importar la aplicación del backend
try:
    from app import app
    print("Aplicación importada exitosamente")
except ImportError as e:
    print(f"Error al importar app: {e}")
    print("Contenido del directorio del backend:")
    backend_dir = sys.path[0]
    print(os.listdir(backend_dir))
    sys.exit(1)

if __name__ == "__main__":
    app.run()