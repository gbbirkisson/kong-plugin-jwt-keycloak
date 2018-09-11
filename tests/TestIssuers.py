import unittest

from tests.utils import *


class TestIssuers(unittest.TestCase):

    def setUp(self):
        ensure_plugin()

    @create_api({
        'consumer_match': False,
        'allow_all_iss': True
    })
    @authenticate(client_id=CLIENT_ID, client_secret=CLIENT_SECRET)
    @call_api()
    def test_allow_all_iss(self, status, body):
        self.assertEqual(OK, status)

    @create_api({
        'consumer_match': False,
        'allowed_iss': ['http://localhost:8080/auth/realms/master']
    })
    @authenticate(client_id=CLIENT_ID, client_secret=CLIENT_SECRET)
    @call_api()
    def test_allow_all_iss(self, status, body):
        self.assertEqual(OK, status)

    @create_api({
        'consumer_match': False,
        'allowed_iss': [
            'http://localhost:8080/auth/realms/not_found',
            'http://localhost:8080/auth/realms/master'
        ]
    })
    @authenticate(client_id=CLIENT_ID, client_secret=CLIENT_SECRET)
    @call_api()
    def test_allow_all_iss_double(self, status, body):
        self.assertEqual(OK, status)

    @create_api({
        'consumer_match': False,
        'allowed_iss': [
            'http://localhost:8080/auth/realms/not_found'
        ]
    })
    @authenticate(client_id=CLIENT_ID, client_secret=CLIENT_SECRET)
    @call_api()
    def test_allow_all_iss_rainy(self, status, body):
        self.assertEqual(UNAUTHORIZED, status)
        self.assertEqual('Token issuer not allowed for this api', body.get('message'))
