import socket
import time

import bcrypt
from fastapi import FastAPI
from pydantic import BaseModel, field_validator

app = FastAPI(
    title="SecureHash API",
    version="1.1.0",
)


class PasswordRequest(BaseModel):
    password: str

    @field_validator("password")
    @classmethod
    def validate_password(cls, value: str) -> str:
        if not value.strip():
            raise ValueError("Hasło nie może być puste.")

        # bcrypt 5.x odrzuca dane dłuższe niż 72 bajty.
        if len(value.encode("utf-8")) > 72:
            raise ValueError("Hasło może mieć maksymalnie 72 bajty w UTF-8.")

        return value


@app.get("/")
def root():
    return {
        "service": "SecureHash API",
        "status": "running",
        "host": socket.gethostname(),
    }


@app.get("/health")
def health():
    return {
        "status": "UP",
        "host": socket.gethostname(),
    }


@app.post("/hash")
def generate_hash(data: PasswordRequest):
    start = time.perf_counter()

    password = data.password.encode("utf-8")
    salt = bcrypt.gensalt(rounds=14)
    hashed = bcrypt.hashpw(password, salt)

    duration = round((time.perf_counter() - start) * 1000, 2)

    return {
        "hash": hashed.decode("utf-8"),
        "time_ms": duration,
        "pod": socket.gethostname(),
    }
