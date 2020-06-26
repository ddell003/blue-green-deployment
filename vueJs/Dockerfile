FROM nginx:1.15.2-alpine

# Normally we'd run npm install here. But since docker has so
# little resources available, that leads to timeout issues.

COPY ./build/vhost.conf /etc/nginx/conf.d/default.conf
COPY ./dist /var/www/html

EXPOSE 80

ENTRYPOINT ["nginx", "-g", "daemon off;"]
