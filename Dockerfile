FROM alpine:3.20

LABEL maintainer="alex@alexos.dev" src="https://github.com/alexdmoss/nginx-with-prometheus"

RUN apk update
RUN apk add --no-cache nginx-mod-http-lua
RUN apk upgrade

RUN mkdir -p /var/run/nginx && \
    chown -R nginx:nginx /var/run/nginx && \
    chmod g+s /var/run/nginx

RUN mkdir -p /var/cache/nginx && \
    chown -R nginx:nginx /var/cache/nginx && \
    chmod g+s /var/cache/nginx

RUN mkdir /usr/local/lua && chown nginx /usr/local/lua
COPY conf/prometheus.lua /usr/local/lua

RUN ln -sf /dev/stdout /var/lib/nginx/logs/access.log
RUN ln -sf /dev/stderr /var/lib/nginx/logs/error.log

USER nginx

# Prometheus port
EXPOSE 9145
# Server port
EXPOSE 8080

COPY conf/nginx.conf /etc/nginx/
COPY conf/prometheus.conf /etc/nginx/
# typically replaced with own server config
COPY conf/default.conf /etc/nginx/conf.d/

STOPSIGNAL SIGTERM

CMD ["nginx", "-g", "daemon off;"]
