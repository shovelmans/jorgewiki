FROM nginx:alpine

# Copiamos el nginx.conf custom
COPY nginx.conf /etc/nginx/conf.d/default.conf

# Copiamos los ficheros estáticos
COPY index.html /usr/share/nginx/html/
COPY script.js /usr/share/nginx/html/
COPY style.css /usr/share/nginx/html/

EXPOSE 80