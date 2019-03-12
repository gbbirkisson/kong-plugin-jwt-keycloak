from tests.utils import *


class TestRoles(unittest.TestCase):

    @create_api({
        'consumer_match': False,
        'allowed_iss': ['http://localhost:8080/auth/realms/master']
    })
    @authenticate()
    @call_api()
    def test_no_auth(self, status, body):
        self.assertEqual(OK, status)

    @skip("New keycloak handles roles differently")
    @create_api({
        'consumer_match': False,
        'allowed_iss': ['http://localhost:8080/auth/realms/master'],
        'roles': ['test_role']
    })
    @authenticate()
    @call_api()
    def test_roles_auth(self, status, body):
        self.assertEqual(OK, status)

    @create_api({
        'consumer_match': False,
        'allowed_iss': ['http://localhost:8080/auth/realms/master'],
        'roles': ['not_found']
    })
    @authenticate()
    @call_api()
    def test_roles_auth_rainy(self, status, body):
        self.assertEqual(FORBIDDEN, status)
        self.assertEqual('Access token does not have the required scope/role', body.get('message'))

    @skip("New keycloak handles roles differently")
    @create_api({
        'consumer_match': False,
        'allowed_iss': ['http://localhost:8080/auth/realms/master'],
        'roles': ['test_role', 'not_found']
    })
    @authenticate()
    @call_api()
    def test_roles_auth_double(self, status, body):
        self.assertEqual(OK, status)

    @create_api({
        'consumer_match': False,
        'allowed_iss': ['http://localhost:8080/auth/realms/master'],
        'realm_roles': ['uma_authorization']
    })
    @authenticate()
    @call_api()
    def test_realm_roles_auth(self, status, body):
        self.assertEqual(OK, status)

    @create_api({
        'consumer_match': False,
        'allowed_iss': ['http://localhost:8080/auth/realms/master'],
        'realm_roles': ['not_found']
    })
    @authenticate()
    @call_api()
    def test_realm_roles_auth_rainy(self, status, body):
        self.assertEqual(FORBIDDEN, status)
        self.assertEqual('Access token does not have the required scope/role', body.get('message'))

    @create_api({
        'consumer_match': False,
        'allowed_iss': ['http://localhost:8080/auth/realms/master'],
        'realm_roles': ['uma_authorization', 'not_found']
    })
    @authenticate()
    @call_api()
    def test_realm_roles_auth_double(self, status, body):
        self.assertEqual(OK, status)

    @create_api({
        'consumer_match': False,
        'allowed_iss': ['http://localhost:8080/auth/realms/master'],
        'client_roles': ['account:manage-account']
    })
    @authenticate()
    @call_api()
    def test_client_roles_auth(self, status, body):
        self.assertEqual(OK, status)

    @create_api({
        'consumer_match': False,
        'allowed_iss': ['http://localhost:8080/auth/realms/master'],
        'client_roles': ['account:manage-something-else']
    })
    @authenticate()
    @call_api()
    def test_client_roles_auth_rainy(self, status, body):
        self.assertEqual(FORBIDDEN, status)
        self.assertEqual('Access token does not have the required scope/role', body.get('message'))

    @create_api({
        'consumer_match': False,
        'allowed_iss': ['http://localhost:8080/auth/realms/master'],
        'client_roles': ['account:manage-account', 'account:manage-something-else']
    })
    @authenticate()
    @call_api()
    def test_client_roles_auth_double(self, status, body):
        self.assertEqual(OK, status)

    @create_api({
        'consumer_match': False,
        'allowed_iss': ['http://localhost:8080/auth/realms/master'],
        'client_roles': ['user:do-user-stuff']
    })
    @authenticate()
    @call_api()
    def test_client_roles_auth(self, status, body):
        self.assertEqual(FORBIDDEN, status)
        self.assertEqual('Access token does not have the required scope/role', body.get('message'))
