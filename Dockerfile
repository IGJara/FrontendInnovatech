# --- Etapa 1: Construcción (Build) ---
FROM node:18-alpine AS builder
WORKDIR /app

# Copiar archivos de dependencias para aprovechar la caché de capas de Docker
COPY package*.json ./
RUN npm install

# Copiar el resto del código y compilar la aplicación para producción
COPY . .
RUN npm run build

# --- Etapa 2: Servidor de Producción Eficiente (Nginx) ---
FROM nginx:alpine

# Copiar nuestra configuración personalizada del Reverse Proxy
COPY nginx.conf /etc/nginx/conf.d/default.conf

# Copiar los archivos compilados en la etapa anterior a la ruta por defecto de Nginx
COPY --from=builder /app/dist /usr/share/nginx/html

# Modificar permisos para asegurar que corra con el mínimo privilegio requerido
RUN touch /var/run/nginx.pid && \
    chown -R nginx:nginx /var/run/nginx.pid /var/cache/nginx /var/log/nginx /usr/share/nginx/html

# Cambiar al usuario no-privilegiado (no-root) integrado en la imagen de Nginx
USER nginx

EXPOSE 80

CMD ["nginx", "-g", "daemon off;"]