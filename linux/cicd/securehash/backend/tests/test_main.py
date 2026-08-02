from fastapi.testclient import TestClient

import main

client = TestClient(main.app)


def _mock_bcrypt(monkeypatch):
    monkeypatch.setattr(main.bcrypt, "gensalt", lambda rounds: b"test-salt")
    monkeypatch.setattr(
        main.bcrypt,
        "hashpw",
        lambda password, salt: b"$2b$14$test-hash",
    )


def test_root_returns_service_information():
    response = client.get("/")

    assert response.status_code == 200
    payload = response.json()
    assert payload["service"] == "SecureHash API"
    assert payload["status"] == "running"
    assert payload["host"]


def test_health_returns_up():
    response = client.get("/health")

    assert response.status_code == 200
    payload = response.json()
    assert payload["status"] == "UP"
    assert payload["host"]


def test_hash_returns_bcrypt_result(monkeypatch):
    _mock_bcrypt(monkeypatch)

    response = client.post("/hash", json={"password": "Lab-Test-123!"})

    assert response.status_code == 200
    payload = response.json()
    assert payload["hash"] == "$2b$14$test-hash"
    assert payload["time_ms"] >= 0
    assert payload["pod"]


def test_hash_accepts_exactly_72_utf8_bytes(monkeypatch):
    _mock_bcrypt(monkeypatch)
    password = "ą" * 36

    assert len(password.encode("utf-8")) == 72

    response = client.post("/hash", json={"password": password})

    assert response.status_code == 200


def test_hash_rejects_blank_password():
    response = client.post("/hash", json={"password": "   "})

    assert response.status_code == 422


def test_hash_rejects_more_than_72_ascii_bytes():
    response = client.post("/hash", json={"password": "a" * 73})

    assert response.status_code == 422


def test_hash_counts_utf8_bytes_not_characters():
    password = "ą" * 37

    assert len(password) == 37
    assert len(password.encode("utf-8")) == 74

    response = client.post("/hash", json={"password": password})

    assert response.status_code == 422
