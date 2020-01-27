# NB: don't really use latest ...
FROM nginx-with-prometheus:latest
COPY example/index.html /app/
COPY example/default.conf /etc/nginx/conf.d/
