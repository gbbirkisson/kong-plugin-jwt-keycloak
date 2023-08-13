import random
import time
import unittest
import uuid
import json

import tests.config
from tests.setup import *

from requests_toolbelt.utils import dump
from metadict import MetaDict

OK = 200
CREATED = 201
NO_CONTENT = 204
UNAUTHORIZED = 401
FORBIDDEN = 403

def logging_hook(logtext, *args, **kwargs):
    data = dump.dump_all(logtext)
    print(data.decode('utf-8'))

def parse_json_response(jsoninput, searchkey=None):
    jsoninput_dict = MetaDict(jsoninput)
    if searchkey is not None:
        jsoninput_dict_lower_keys = {k.lower():v for k,v in jsoninput_dict.items()}
        if searchkey.lower() in jsoninput_dict_lower_keys:
            return jsoninput_dict_lower_keys.get(searchkey.lower())
    ## TODO: Add handler for non jsoninput and handeled exceptions if searchkey is not found


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


def create_consumer(client_id, **kwargs):
    custom_id = kwargs.get('custom_id', client_id)
    r = requests.post(KONG_ADMIN + "/consumers", json={
        "username": client_id,
        "custom_id": custom_id
    })
    assert r.status_code == CREATED or r.status_code == 409
    time.sleep(0.5)
    return kwargs.get('custom_id', r.json()['id'])


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
                "url": "http://localhost:8093/anything"
            })
            assert r.status_code == CREATED
            r = requests.post(KONG_ADMIN + "/services/" + api_name + "/routes", data={
                "name": api_name,
                "paths[]": "/" + api_name
            })
            # If you face problems in unit tests you can uncomment this line 
            # to see the raw data
            # print("--------------------Debugging Start--------------------")
            # print(logging_hook(r))
            # print("--------------------Debugging End----------------------")
            assert r.status_code == CREATED
            r = requests.post(KONG_ADMIN + "/services/" + api_name + "/plugins", json={
                "name": "jwt-keycloak",
                "config": config
            })
            assert r.status_code == expected_response
            kwargs['api_endpoint'] = KONG_API + "/" + api_name
            # Wait a few seconds until kong has the changed configuration online
            # (Otherwise http 404 is returned)
            time.sleep(5)
            result = func(*args, **kwargs)
            return result

        return wrapper

    return real_decorator


def call_api(token=None, method='get', params=None, endpoint=None, authentication_type=None):
    def real_decorator(func):
        def wrapper(*args, **kwargs):
            authentication_type_json = json.dumps(authentication_type)
            if json.dumps(params) is not None:
                params_dict = json.loads(json.dumps(params))

            # Use Token Header Authentication if no query param is specified
            if "queryparam" not in authentication_type_json:
                if token is not None:
                    headers = {"Authorization": "Bearer " + token}
                elif kwargs.get('token') is not None:
                    headers = {"Authorization": "Bearer " + kwargs.get('token')}
                else:
                    headers = None
            # Use query params to add token
            else:
                authentication_type_dict = json.loads(authentication_type_json)
                headers = None
                if params_dict is None:
                    params_dict = {}
                if token is not None:
                    params_dict[authentication_type_dict['queryparam']] = token
                if kwargs.get('token') is not None:
                    params_dict[authentication_type_dict['queryparam']] = kwargs.get('token')

            if endpoint is None:
                e = kwargs['api_endpoint']
            else:
                e = endpoint

            r = requests.request(method, e, params=params_dict, headers=headers)
            # If you face problems in unit tests you can uncomment this line 
            # to see the raw data
            # print("--------------------Debugging Start--------------------")
            # print(logging_hook(r))
            # print("--------------------Debugging End----------------------")
            try:
                result = func(*args, r.status_code, r.json())
            except ValueError: # When response body is empty / no json, then return None
                result = func(*args, r.status_code, None)
            return result

        return wrapper

    return real_decorator


def create_client(client_id, **kwargs):
    id = str(uuid.uuid4())

    if client_id is None:
        client_id = str(uuid.uuid4())

    if kwargs.get('create_consumer'):
        client_id = create_consumer(client_id, **kwargs)
    client_secret = str(uuid.uuid4())
    r = requests.post(KC_HOST + "/admin/realms/master/clients",
                      headers={'Authorization': 'Bearer ' + KC_ADMIN_TOKEN},
                      json={
                          'id': id,
                          'clientId': client_id,
                          'clientAuthenticatorType': 'client-secret',
                          'secret': client_secret,
                          'serviceAccountsEnabled': True,
                          'standardFlowEnabled': False,
                          'publicClient': False,
                          'enabled': True
                      })
    # If you face problems in unit tests you can uncomment this line 
    # to see the raw data
    # print("--------------------Debugging Start--------------------")
    # print(logging_hook(r))
    # print("--------------------Debugging End----------------------")
    assert r.status_code == 201

    r = requests.post(KC_HOST + "/admin/realms/master/clients/" + id + '/roles',
                      headers={'Authorization': 'Bearer ' + KC_ADMIN_TOKEN},
                      json={
                          'name': 'test_role'
                      })

    assert r.status_code == 201

    return client_id, client_secret


def authenticate(**kwargs_outer):
    def real_decorator(func):
        def wrapper(*args, **kwargs):
            client_id, client_secret = create_client(None, **kwargs_outer)
            result = func(*args, token=get_kc_token(client_id, client_secret), **kwargs)
            return result

        return wrapper

    return real_decorator


def skip(reason):
    def real_decorator(func):
        def wrapper(*args, **kwargs):
            unittest.TestCase.skipTest(None, reason)
            return

        return wrapper

    return real_decorator


def kc_get_key(name):
    r = requests.get(KC_HOST + "/admin/realms/master/components?parent=master&type=org.keycloak.keys.KeyProvider",
                     headers={'Authorization': 'Bearer ' + KC_ADMIN_TOKEN})
    assert r.status_code == 200
    r = [a for a in r.json() if a['name'] == name]
    if len(r) == 1:
        return r[0]
    return None


def kc_delete_key(key):
    r = requests.delete(KC_HOST + "/admin/realms/master/components/" + key['id'],
                        headers={'Authorization': 'Bearer ' + KC_ADMIN_TOKEN})
    assert r.status_code == 204


def kc_add_key(name, priority):
    r = requests.post(KC_HOST + "/admin/realms/master/components",
                      headers={'Authorization': 'Bearer ' + KC_ADMIN_TOKEN},
                      json={
                          'config': {
                              'active': [True],
                              'algorithm': ['RS256'],
                              'enabled': [True],
                              'keySize': [2048],
                              'priority': [priority]
                          },
                          'name': name,
                          'parentId': 'master',
                          'providerId': 'rsa-generated',
                          'providerType': 'org.keycloak.keys.KeyProvider'
                      })

    assert r.status_code == 201

    r = requests.get(r.headers['Location'], headers={'Authorization': 'Bearer ' + KC_ADMIN_TOKEN})
    assert r.status_code == 200

    return r.json()
