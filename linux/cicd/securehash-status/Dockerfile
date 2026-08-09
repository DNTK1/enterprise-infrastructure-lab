FROM python:3.12-slim

ENV PYTHONDONTWRITEBYTECODE=1
ENV PYTHONUNBUFFERED=1

WORKDIR /app

RUN groupadd \
        --gid 10001 \
        appuser \
    && useradd \
        --uid 10001 \
        --gid 10001 \
        --no-create-home \
        --home-dir /app \
        --shell /usr/sbin/nologin \
        appuser

COPY requirements.txt .

RUN python -m pip install \
    --no-cache-dir \
    --requirement requirements.txt

COPY app ./app

RUN chown -R 10001:10001 /app

USER 10001:10001

EXPOSE 8000

CMD ["uvicorn", "app.main:app", "--host", "0.0.0.0", "--port", "8000"]
