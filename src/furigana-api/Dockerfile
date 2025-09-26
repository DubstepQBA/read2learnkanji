# Backend Dockerfile para Railway
FROM python:3.11-slim

# Instalar dependencias del sistema necesarias para Tesseract OCR y otras librerías
RUN apt-get update && apt-get install -y \
    tesseract-ocr \
    tesseract-ocr-jpn \
    libtesseract-dev \
    poppler-utils \
    libgl1-mesa-glx \
    libglib2.0-0 \
    libsm6 \
    libxext6 \
    libxrender-dev \
    libgomp1 \
    wget \
    curl \
    && rm -rf /var/lib/apt/lists/*

# Establecer el directorio de trabajo
WORKDIR /app

# Copiar requirements.txt primero para aprovechar la caché de Docker
COPY requirements.txt .

# Instalar dependencias de Python
RUN pip install --no-cache-dir -r requirements.txt

# Copiar el resto de los archivos del backend
COPY . .

# Exponer el puerto (Railway asignará un puerto dinámicamente)
EXPOSE 5000

# Comando para ejecutar la aplicación con gunicorn (optimizado para Railway)
CMD ["gunicorn", "--bind", "0.0.0.0:5000", "--workers", "2", "--timeout", "120", "--keep-alive", "5", "app:app"]