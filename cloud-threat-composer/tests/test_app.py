import os

os.environ["DATABASE_URL"] = "sqlite:///./test_threat_composer.db"

from fastapi.testclient import TestClient

from app.main import app


client = TestClient(app)


def test_health_endpoint():
    response = client.get("/health")
    assert response.status_code == 200
    assert response.json() == {"status": "healthy"}


def test_home_page_loads():
    response = client.get("/")
    assert response.status_code == 200
    assert "Cloud Threat Composer" in response.text


def test_create_project_and_threat_flow():
    project_response = client.post(
        "/projects",
        data={"name": "Payment API", "description": "Public payment service"},
        follow_redirects=False,
    )
    assert project_response.status_code == 303
    project_url = project_response.headers["location"]

    threat_response = client.post(
        f"{project_url}/threats",
        data={
            "name": "Authentication bypass",
            "description": "An attacker impersonates a customer",
            "component": "API",
            "stride_category": "Spoofing",
            "likelihood": 4,
            "impact": 5,
            "mitigation": "Use short-lived tokens and MFA",
            "status": "Open",
        },
        follow_redirects=False,
    )
    assert threat_response.status_code == 303

    dashboard = client.get(project_url)
    assert dashboard.status_code == 200
    assert "Authentication bypass" in dashboard.text
    assert "Critical" in dashboard.text
    assert "20/25" in dashboard.text
