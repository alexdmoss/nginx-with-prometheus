# checkov:skip=CKV_DOCKER_3:example for blog readers; the base image already sets USER nginx
# latest tag: see IMAGE_TAG at top of .gitlab-ci.yml
FROM al3xos/nginx-with-prometheus:1.17

COPY example/index.html /app/
COPY example/default.conf /etc/nginx/conf.d/
