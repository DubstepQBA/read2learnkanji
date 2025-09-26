# Docker Deployment for Read2LearnKanji

Este proyecto incluye configuración completa de Docker para desplegar en Railway y desarrollo local.

## 📋 Requisitos Previos

- Docker y Docker Compose instalados
- Cuenta en Railway (https://railway.app)
- Git

## 🚀 Despliegue en Railway

### ⚠️ Solución al Error de Build en Railway

Si obtienes un error durante el build en Railway, prueba estos pasos:

#### Opción 1: Usar el Dockerfile Simplificado (Recomendado)

1. **Asegúrate de tener estos archivos en tu repo**:
   - `Dockerfile.railway` (creado automáticamente)
   - `railway.json` (actualizado)
   - `railway.toml` (alternativa)

2. **Conectar repositorio a Railway**:
   - Ve a https://railway.app
   - Crea un nuevo proyecto
   - Conecta tu repositorio de GitHub
   - Railway usará automáticamente `Dockerfile.railway`

#### Opción 2: Configuración Manual en Railway

Si el automático falla:

1. En Railway Dashboard:
   - Ve a Settings → Service
   - Cambia "Build Command" a: `docker build -f Dockerfile.railway -t railway-app .`
   - Cambia "Start Command" a: `gunicorn --bind 0.0.0.0:$PORT --workers 1 --timeout 120 app:app`

2. **Variables de entorno** (configura en Railway Dashboard):
   ```
   FLASK_ENV=production
   PORT=5000
   PYTHONUNBUFFERED=1
   ```

### Opción 2: Despliegue Manual con Docker

1. **Build local**:
   ```bash
   docker build -f src/furigana-api/Dockerfile -t furigana-backend ./src/furigana-api
   ```

2. **Push a Railway**:
   ```bash
   railway login
   railway init
   railway up
   ```

## 🏗️ Desarrollo Local con Docker

### Backend solo:
```bash
cd src/furigana-api
docker build -t furigana-backend .
docker run -p 5000:5000 furigana-backend
```

### Frontend + Backend con Docker Compose:
```bash
# Construir y ejecutar ambos servicios
docker-compose up --build

# Backend: http://localhost:5000
# Frontend: http://localhost:3000
```

### Detener servicios:
```bash
docker-compose down
```

## 📁 Estructura de Archivos Docker

```
├── src/furigana-api/
│   ├── Dockerfile              # Backend Flask + Tesseract OCR
│   ├── requirements.txt        # Dependencias Python
│   └── .dockerignore          # Archivos a ignorar en build
├── Dockerfile.frontend         # Frontend React + Vite
├── docker-compose.yml         # Desarrollo local
├── railway.json               # Config Railway
└── .dockerignore             # Frontend ignore rules
```

## 🔧 Configuración de Servicios

### Backend (Puerto 5000)
- **Framework**: Flask
- **OCR**: Tesseract con soporte japonés
- **Procesamiento**: SudachiPy para análisis de texto japonés
- **Base de datos**: SQLite (jmdict.db)

### Frontend (Puerto 3000)
- **Framework**: React 19 + Vite
- **Build**: Producción optimizada
- **Servidor**: Serve (estático)

## 📝 Notas Importantes

1. **Tesseract OCR**: Incluye soporte completo para japonés
2. **Base de datos**: Asegúrate de que `jmdict.db` esté presente
3. **Puertos**: Railway asigna puertos dinámicamente
4. **Health checks**: Endpoint `/health` disponible para monitoreo

## 🐛 Solución de Problemas

### Error de Tesseract OCR:
```bash
# Verificar instalación en container
docker exec -it <container_id> tesseract --version
```

### Error de base de datos:
```bash
# Verificar conexión
curl http://localhost:5000/health
```

### Logs de Railway:
```bash
railway logs
```

## 📚 Comandos Útiles

```bash
# Ver logs
docker-compose logs -f

# Rebuild sin caché
docker-compose build --no-cache

# Entrar al container
docker-compose exec backend bash

# Ver imágenes
docker images

# Limpiar containers
docker system prune -a
```

## 🎯 Próximos Pasos

1. Configurar CI/CD con GitHub Actions
2. Agregar monitoreo con Railway Analytics
3. Implementar caché con Redis
4. Optimizar imágenes Docker para menor tamaño