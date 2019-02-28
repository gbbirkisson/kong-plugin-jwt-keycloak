import os

CLIENT_ID = os.environ.get("CLIENT_ID", "test")
CLIENT_SECRET = os.environ.get("CLIENT_SECRET", "c0bc799c-4dfc-4841-af01-0f1a00171c32")

KONG_API = os.environ.get("KONG_API", "http://localhost:8000")
KONG_ADMIN = os.environ.get("KONG_ADMIN", "http://localhost:8001")
KC_REALM = os.environ.get("KC_REALM", "http://localhost:8080/auth/realms/master")
