# syntax=docker/dockerfile:1.7
# Build context is the repo root (see docker-compose.yml / Makefile).

# --- deps: resolve third-party packages with pip ------------------------------
FROM python:3.14-slim AS deps

WORKDIR /build
COPY app/requirements.txt ./
RUN mkdir -p /deps \
 && pip install --no-cache-dir --target /deps -r requirements.txt

# --- runtime: no package manager, non-root ------------------------------------
FROM python:3.14-slim AS runtime

ARG VERSION=dev
ARG GIT_SHA=unknown
LABEL org.opencontainers.image.version="${VERSION}" \
      org.opencontainers.image.revision="${GIT_SHA}"

ENV PYTHONDONTWRITEBYTECODE=1 \
    PYTHONUNBUFFERED=1 \
    PYTHONPATH=/app/src:/app/deps \
    APP_PORT=8080

# pip is not needed at runtime and vendors its own libraries (msgpack,
# setuptools/pkg_resources) that scanners flag; drop it with its bundled wheel.
RUN python -m pip uninstall -y pip \
 && rm -rf /usr/local/lib/python3*/ensurepip/_bundled \
 && useradd --system --uid 10001 --no-create-home appuser

WORKDIR /app
COPY --from=deps /deps ./deps
COPY app/src ./src

USER 10001

EXPOSE 8080
HEALTHCHECK --interval=10s --timeout=3s --retries=3 \
  CMD ["python", "-c", "import urllib.request,os;urllib.request.urlopen(f'http://127.0.0.1:{os.environ[\"APP_PORT\"]}/healthz')"]

ENTRYPOINT ["python", "-m", "app.main"]
