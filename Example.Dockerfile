# latest tag: see IMAGE_TAG at top of .gitlab-ci.yml
FROM mosstech/nginx-with-prometheus:1.2

COPY example/index.html /app/
COPY example/default.conf /etc/nginx/conf.d/
