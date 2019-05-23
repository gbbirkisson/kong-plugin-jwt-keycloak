import os

import requests

CLIENT_ID = os.environ.get("CLIENT_ID", "test")
CLIENT_SECRET = os.environ.get("CLIENT_SECRET", "c0bc799c-4dfc-4841-af01-0f1a00171c32")

KONG_API = os.environ.get("KONG_API", "http://localhost:8000")
KONG_ADMIN = os.environ.get("KONG_ADMIN", "http://localhost:8001")

KC_USER = os.environ.get("KC_USER", "admin")
KC_PASS = os.environ.get("KC_PASS", "admin")
KC_HOST = os.environ.get("KC_HOST", "http://localhost:8080/auth")
KC_REALM = KC_HOST + "/realms/master"

r = requests.post(KC_REALM + "/protocol/openid-connect/token", data={
    'grant_type': 'password',
    'client_id': 'admin-cli',
    'username': KC_USER,
    'password': KC_PASS
})

assert r.status_code == 200
KC_ADMIN_TOKEN = r.json()['access_token']

r = requests.get(KC_HOST + '/admin/serverinfo', headers={'Authorization': 'Bearer ' + KC_ADMIN_TOKEN})
assert r.status_code == 200
KC_VERSION = r.json()['systemInfo']['version']
