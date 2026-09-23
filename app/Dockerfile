# syntax=docker/dockerfile:1.7
# Build context is the repo root (see docker-compose.yml / Makefile).
FROM python:3.13-slim AS runtime

ARG VERSION=dev
ARG GIT_SHA=unknown
LABEL org.opencontainers.image.version="${VERSION}" \
      org.opencontainers.image.revision="${GIT_SHA}"

ENV PYTHONDONTWRITEBYTECODE=1 \
    PYTHONUNBUFFERED=1 \
    PYTHONPATH=/app/src \
    APP_PORT=8080

WORKDIR /app
COPY app/requirements.txt ./
RUN pip install --no-cache-dir -r requirements.txt

COPY app/src ./src

RUN useradd --system --uid 10001 --no-create-home appuser
USER 10001

EXPOSE 8080
HEALTHCHECK --interval=10s --timeout=3s --retries=3 \
  CMD ["python", "-c", "import urllib.request,os;urllib.request.urlopen(f'http://127.0.0.1:{os.environ[\"APP_PORT\"]}/healthz')"]

ENTRYPOINT ["python", "-m", "app.main"]
