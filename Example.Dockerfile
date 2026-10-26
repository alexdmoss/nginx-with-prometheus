# latest tag: see IMAGE_TAG at top of .gitlab-ci.yml
FROM al3xos/nginx-with-prometheus:1.17@sha256:940fd9661e09532fa5ba9aa124d16571232fee315f5411c728dc4143afb8d2ab

COPY example/index.html /app/
COPY example/default.conf /etc/nginx/conf.d/
