from fastapi.testclient import TestClient

from app.main import app

client = TestClient(app)


def test_health_check() -> None:
    response = client.get("/healthz")

    assert response.status_code == 200
    assert response.json() == {"status": "ok"}


def test_application_status() -> None:
    response = client.get("/api/status")
    body = response.json()

    assert response.status_code == 200
    assert body["application"] == "securehash-status"
    assert body["status"] == "online"
    assert "version" in body
    assert "git_sha" in body
    assert "build_number" in body


def test_home_page() -> None:
    response = client.get("/")

    assert response.status_code == 200
    assert "SecureHash Status" in response.text
