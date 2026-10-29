#!/usr/bin/env bash
#
# Image tests for a base image: the config parses, the server answers and the
# Prometheus endpoint counts requests. Run against a locally built image.
#
# Usage: ./scripts/tests.sh <image> [docker-host]
#   docker-host: where published ports are reachable (default localhost; `docker` with dind)

set -euo pipefail

IMAGE="${1:?usage: tests.sh <image> [docker-host]}"
HOST="${2:-localhost}"
NAME="nginx-with-prometheus-test-$$"

function cleanup() {
  docker logs "${NAME}" 2>&1 | tail -20 || true
  docker rm -f "${NAME}" >/dev/null 2>&1 || true
}
trap cleanup EXIT

function status_of() {
  curl -s -o /dev/null -w '%{http_code}' "$1"
}

echo "-> nginx -t (also loads the lua modules)"
docker run --rm "${IMAGE}" nginx -t

echo "-> starting ${IMAGE}"
docker run -d --name "${NAME}" -p 8080:8080 -p 9145:9145 "${IMAGE}" >/dev/null

for _ in $(seq 1 30); do
  if [[ "$(status_of "http://${HOST}:9145/metrics")" == "200" ]]; then break; fi
  sleep 1
done

echo "-> runs as nginx, not root"
user=$(docker exec "${NAME}" id -un)
[[ "${user}" == "nginx" ]] || { echo "FAIL: running as ${user}"; exit 1; }

echo "-> default server answers"
code=$(status_of "http://${HOST}:8080/")
[[ "${code}" =~ ^(200|404)$ ]] || { echo "FAIL: / returned ${code}"; exit 1; }

echo "-> security headers set"
curl -s -D - -o /dev/null "http://${HOST}:8080/" | grep -qi '^X-Content-Type-Options: nosniff' \
  || { echo "FAIL: X-Content-Type-Options missing"; exit 1; }

echo "-> metrics endpoint counts the request"
metrics=$(curl -sf "http://${HOST}:9145/metrics")
echo "${metrics}" | grep -q "^nginx_http_requests_total{.*status=\"${code}\"}" \
  || { echo "FAIL: request not counted"; echo "${metrics}"; exit 1; }
echo "${metrics}" | grep -q '^nginx_http_connections{state="waiting"}' \
  || { echo "FAIL: connections gauge missing"; exit 1; }
echo "${metrics}" | grep -q '^nginx_metric_errors_total 0' \
  || { echo "FAIL: lua metric errors"; echo "${metrics}" | grep nginx_metric_errors; exit 1; }

echo "All image tests passed"
