FROM nginx:1.25-alpine

# Копируем статическую страницу
COPY index.html /usr/share/nginx/html/index.html

# Открываем порт
EXPOSE 80

# Запускаем nginx
CMD ["nginx", "-g", "daemon off;"]
