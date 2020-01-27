# nginx-with-prometheus

Instrumented open-source NGINX with Prometheus metrics from: https://github.com/knyar/nginx-lua-prometheus/blob/master/prometheus.lua

Base Dockerfile based heavily on: https://hub.docker.com/r/ekho/nginx-lua/dockerfile, with tweaks to bring in up-to-date versions.

## Usage

### Base Image

Build base image with `docker build -t nginx-with-prometheus -f Base.Dockerfile .` (replace with your own tag as needed).

You can test this with: `docker run -p 8080:8080 -p 9145:9145 nginx-with-prometheus:latest` - `curl http://localhost:8080/` should 404, and `curl http://localhost:9145/metrics` should show you some metrics.

### Use It

Once built, you can use it for a "proper" website with a Dockerfile like this:

```Dockerfile
# NB: don't really use latest ...
FROM nginx-with-prometheus:latest
# path to where your code actually is
COPY example/index.html /app/
# customisations you'll inevitably want on base nginx
COPY example/default.conf /etc/nginx/conf.d/
```

Which you can then build and run ...

```sh
docker build -t your-website -f Example.Dockerfile .
docker run -p 8080:8080 -p 9145:9145 your-website
```
