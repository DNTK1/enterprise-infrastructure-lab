import os
from datetime import UTC, datetime

from fastapi import FastAPI
from fastapi.responses import HTMLResponse

APP_VERSION = os.getenv("APP_VERSION", "dev")
GIT_SHA = os.getenv("GIT_SHA", "local")
BUILD_NUMBER = os.getenv("BUILD_NUMBER", "local")

app = FastAPI(
    title="SecureHash Status",
    version=APP_VERSION,
)


@app.get("/", response_class=HTMLResponse)
def home() -> str:
    return f"""
    <!DOCTYPE html>
    <html lang="pl">
    <head>
        <meta charset="UTF-8">
        <title>SecureHash Status</title>
    </head>
    <body>
        <h1>SecureHash Status</h1>
        <p>Aplikacja działa poprawnie.</p>

        <ul>
            <li>Wersja: {APP_VERSION}</li>
            <li>Commit: {GIT_SHA}</li>
            <li>Build: {BUILD_NUMBER}</li>
        </ul>
    </body>
    </html>
    """


@app.get("/healthz")
def health_check() -> dict[str, str]:
    return {"status": "ok"}


@app.get("/api/status")
def application_status() -> dict[str, str]:
    return {
        "application": "securehash-status",
        "status": "online",
        "version": APP_VERSION,
        "git_sha": GIT_SHA,
        "build_number": BUILD_NUMBER,
        "checked_at": datetime.now(UTC).isoformat(),
    }
