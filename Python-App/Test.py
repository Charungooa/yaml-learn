"""
Basic tests for the Flask microservice.
Run with: pytest test_app.py -v
"""

from app import app


def test_health_returns_200():
    """Liveness probe endpoint should always return 200."""
    client = app.test_client()
    response = client.get("/health")
    assert response.status_code == 200
    assert response.json["status"] == "healthy"


def test_ready_returns_200():
    """Readiness probe endpoint should return 200 when app is ready."""
    client = app.test_client()
    response = client.get("/ready")
    assert response.status_code == 200
    assert response.json["status"] == "ready"


def test_info_returns_hostname():
    """Info endpoint should return hostname and timestamp."""
    client = app.test_client()
    response = client.get("/info")
    assert response.status_code == 200
    data = response.json
    assert "hostname" in data
    assert "timestamp" in data
    assert "app_env" in data
    assert "version" in data


def test_root_returns_welcome():
    """Root endpoint should return welcome message with endpoint list."""
    client = app.test_client()
    response = client.get("/")
    assert response.status_code == 200
    assert "endpoints" in response.json