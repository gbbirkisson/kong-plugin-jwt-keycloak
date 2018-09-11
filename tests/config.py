import os

CLIENT_ID = os.environ.get("CLIENT_ID", "test")
CLIENT_SECRET = os.environ.get("CLIENT_SECRET", "17989aa3-ef9d-4adf-a2bd-6fbcc2848f6f")

KONG_API = os.environ.get("KONG_API", "http://localhost:8000")
KONG_ADMIN = os.environ.get("KONG_ADMIN", "http://localhost:8001")
KC_REALM = os.environ.get("KC_REALM", "http://localhost:8080/auth/realms/master")
