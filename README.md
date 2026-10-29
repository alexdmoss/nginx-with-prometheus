# nginx-with-prometheus

Instrumented open-source NGINX with Prometheus metrics from: [https://github.com/knyar/nginx-lua-prometheus/blob/master/prometheus.lua](https://github.com/knyar/nginx-lua-prometheus/blob/master/prometheus.lua)

Base Dockerfile based heavily on: [https://hub.docker.com/r/ekho/nginx-lua/dockerfile](https://hub.docker.com/r/ekho/nginx-lua/dockerfile), with tweaks to bring in up-to-date versions.

---

## Usage

Every branch builds the image and runs `scripts/tests.sh` against it; nothing is pushed. `main` publishes `IMAGE_TAG` (top of `.gitlab-ci.yml`) once the tests pass. Bump `IMAGE_TAG` to release a new version.

Renovate keeps the Alpine base (tag + digest in the `Dockerfile`) up to date and automerges the MR once the tests pass. A weekly scheduled pipeline on `main` rebuilds and republishes the same tag so Alpine package fixes land between base image releases. Apps pin `al3xos/nginx-with-prometheus:<tag>@sha256:…`, so each publish reaches them as a Renovate digest MR.

### Base Image

Build base image with `docker build -t nginx-with-prometheus:latest .` (replace with your own tag as needed).

Test it with `./scripts/tests.sh nginx-with-prometheus:latest`: it checks the config, that nginx answers on 8080 as a non-root user, and that `http://localhost:9145/metrics` counts the request.

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

Which you can then build and run as usual:

```sh
docker build -t your-website -f Example.Dockerfile .
docker run -p 8080:8080 -p 9145:9145 your-website
```
