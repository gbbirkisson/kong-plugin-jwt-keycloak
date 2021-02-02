from tests.utils import *


class TestIssuers(unittest.TestCase):

    @create_api({
        'allowed_iss': ['http://localhost:8080/auth/realms/master']
    })
    @authenticate()
    @call_api()
    def test_allow_all_iss(self, status, body):
        self.assertEqual(OK, status)

    @create_api({
        'allowed_iss': [
            'http://localhost:8080/auth/realms/not_found',
            'http://localhost:8080/auth/realms/master'
        ]
    })
    @authenticate()
    @call_api()
    def test_allow_all_iss_double(self, status, body):
        self.assertEqual(OK, status)

    @create_api({
        'allowed_iss': [
            'http://localhost:8080/auth/realms/not_found'
        ]
    })
    @authenticate()
    @call_api()
    def test_allow_all_iss_rainy(self, status, body):
        self.assertEqual(UNAUTHORIZED, status)
        self.assertEqual('Token issuer not allowed', body.get('message'))

    @create_api({
        'allowed_iss': [
            'http://localhost:8080/auth/realms/.*'
        ]
    })
    @authenticate()
    @call_api()
    def test_allow_all_iss_rainy(self, status, body):
        self.assertEqual(OK, status)
