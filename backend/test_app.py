import os

os.environ.pop("CONNECTION_STRING", None)

from fastapi.testclient import TestClient
from app import api




def test_home():
    with TestClient(api) as client:
        response = client.get("/")
        assert response.status_code == 200
        assert response.json() == {"message": "Welcome to the Cloud Resume Challenge!"}


def test_visitors_count():
    with TestClient(api) as client:
        response = client.get("/visitors-count")
        assert response.status_code == 200
        assert "visitors_count" in response.json()
        assert isinstance(response.json()["visitors_count"], int)
