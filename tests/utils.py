import random
import time

import requests

from tests.config import *

OK = 200
CREATED = 201
NO_CONTENT = 204
UNAUTHORIZED = 401
FORBIDDEN = 403


def get_kong_version():
    r = requests.get(KONG_ADMIN)
    assert r.status_code == OK
    return r.json()['version']


def get_kc_public_key(realm_url):
    r = requests.get(realm_url)
    assert r.status_code == OK
    return r.json()['public_key']


def get_kc_token(client_id, client_secret):
    r = requests.post(KC_REALM + "/protocol/openid-connect/token", data={
        'grant_type': 'client_credentials',
        'client_id': client_id,
        'client_secret': client_secret
    })
    assert r.status_code == OK
    return r.json()['access_token']


def ensure_plugin():
    r = requests.get(KONG_ADMIN + "/jwt-keycloak")
    assert r.status_code == OK
    res = r.json()
    if len(res['data']) == 0:
        r = requests.post(KONG_ADMIN + "/jwt-keycloak", data={
            "iss": KC_REALM,
            "public_key": get_kc_public_key(KC_REALM)
        })
        assert r.status_code == CREATED
    time.sleep(0.5)


def create_consumer(client_id):
    r = requests.post(KONG_ADMIN + "/consumers", json={
        "username": client_id,
        "custom_id": client_id
    })
    assert r.status_code == CREATED or r.status_code == 409
    time.sleep(0.5)


def delete_consumer(client_id):
    r = requests.delete(KONG_ADMIN + "/consumers/" + client_id)
    assert r.status_code == NO_CONTENT
    time.sleep(0.5)


def create_api(config, expected_response=CREATED):
    def real_decorator(func):
        def wrapper(*args, **kwargs):
            api_name = "test" + str(random.randint(1, 1000000))
            r = requests.post(KONG_ADMIN + "/services", data={
                 "name": api_name,
                 "url": "http://mockbin.org/headers"
            })
            assert r.status_code == CREATED
            r = requests.post(KONG_ADMIN + "/services/" + api_name + "/routes", data={
                "name": api_name,
                "paths[]": "/" + api_name
            })
            assert r.status_code == CREATED
            r = requests.post(KONG_ADMIN + "/services/" + api_name + "/plugins", json={
                "name": "jwt-keycloak",
                "config": config
            })
            assert r.status_code == expected_response
            kwargs['api_endpoint'] = KONG_API + "/" + api_name
            time.sleep(0.5)
            result = func(*args, **kwargs)
            return result

        return wrapper

    return real_decorator


def call_api(token=None, method='get', params=None):
    def real_decorator(func):
        def wrapper(*args, **kwargs):
            if token is not None:
                headers = {"Authorization": "Bearer " + token}
            elif kwargs.get('token') is not None:
                headers = {"Authorization": "Bearer " + kwargs.get('token')}
            else:
                headers = None
            r = requests.request(method, kwargs['api_endpoint'], params=params, headers=headers)
            result = func(*args, r.status_code, r.json())
            return result

        return wrapper

    return real_decorator


def authenticate(client_id, client_secret, **kwargs):
    def real_decorator(func):
        def wrapper(*args, **kwargs):
            result = func(*args, token=get_kc_token(client_id, client_secret), **kwargs)
            return result

        return wrapper

    return real_decorator
