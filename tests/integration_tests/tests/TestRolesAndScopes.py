from tests.utils import *

class TestRoles(unittest.TestCase):

    ############################################################################
    # Test if plugin allows requests if valid token is send to the 
    # kong instance .. it needs to work
    @create_api({
        'allowed_iss': ['http://localhost:8080/auth/realms/master']
    })
    @authenticate()
    @call_api()
    def test_with_valid_token_ok(self, status, body):
        self.assertEqual(OK, status)

    ############################################################################
    # Starting from here the "roles" tests happen 
    # TODO: Need to investigate what is the exact logic behind "roles"

    @create_api({
        'allowed_iss': ['http://localhost:8080/auth/realms/master'],
        'roles': ['test_role']
    })
    @authenticate()
    @call_api()
    def test_roles_auth(self, status, body):
        if not KC_VERSION.startswith('3'):
            self.skipTest("Test not supported for " + KC_VERSION)
        self.assertEqual(OK, status)

    @create_api({
        'allowed_iss': ['http://localhost:8080/auth/realms/master'],
        'roles': ['not_found']
    })
    @authenticate()
    @call_api()
    def test_roles_auth_rainy(self, status, body):
        self.assertEqual(FORBIDDEN, status)
        self.assertEqual('Access token does not have the required scope/role: Missing required role', body.get('message'))

    @skip("Need to update tests")
    @create_api({
        'allowed_iss': ['http://localhost:8080/auth/realms/master'],
        'roles': ['test_role', 'not_found']
    })
    @authenticate()
    @call_api()
    def test_roles_auth_double(self, status, body):
        if not KC_VERSION.startswith('3'):
            self.skipTest("Test not supported for " + KC_VERSION)
        self.assertEqual(OK, status)

    ############################################################################
    # Starting from here the "realm_roles" tests happen

    @create_api({
        'allowed_iss': ['http://localhost:8080/auth/realms/master'],
        'realm_roles': ['uma_authorization']
    })
    @authenticate()
    @call_api()
    def test_realm_roles_auth(self, status, body):
        self.assertEqual(OK, status)

    @create_api({
        'allowed_iss': ['http://localhost:8080/auth/realms/master'],
        'realm_roles': ['not_found']
    })
    @authenticate()
    @call_api()
    def test_realm_roles_auth_rainy(self, status, body):
        self.assertEqual(FORBIDDEN, status)
        self.assertEqual('Access token does not have the required scope/role: Missing required realm role', body.get('message'))

    @create_api({
        'allowed_iss': ['http://localhost:8080/auth/realms/master'],
        'realm_roles': ['uma_authorization', 'not_found']
    })
    @authenticate()
    @call_api()
    def test_realm_roles_auth_double(self, status, body):
        self.assertEqual(OK, status)

    ############################################################################
    # Starting from here the "client_roles" tests happen

    ############################################################################
    # Test if plugin allows the request if role matches
    # ... here "account:manage-account" is the valid role
    @create_api({
        'allowed_iss': ['http://localhost:8080/auth/realms/master'],
        'client_roles': ['account:manage-account']
    })
    @authenticate()
    @call_api()
    def test_client_roles_auth(self, status, body):
        self.assertEqual(OK, status)

    ############################################################################
    # Test if plugin blocks the request if claim exists, but role is not
    # contained in the claim
    @create_api({
        'allowed_iss': ['http://localhost:8080/auth/realms/master'],
        'client_roles': ['account:manage-something-else']
    })
    @authenticate()
    @call_api()
    def test_client_roles_auth_rainy(self, status, body):
        self.assertEqual(FORBIDDEN, status)
        self.assertEqual('Access token does not have the required scope/role: Missing required role', body.get('message'))

    ############################################################################
    # Test if plugin allows the request if minimum one role matches
    # ... here "account:manage-account" is the valid role
    @create_api({
        'allowed_iss': ['http://localhost:8080/auth/realms/master'],
        'client_roles': ['dummy:whatever_setting', 'account:manage-account', 'account:manage-something-else']
    })
    @authenticate()
    @call_api()
    def test_client_roles_multiple_roles_oneof(self, status, body):
        self.assertEqual(OK, status)

    ############################################################################
    # Test if plugin blocks request if needed role is not contained in token 
    # Worst case check for things which are in no token claim existing at all.
    @create_api({
        'allowed_iss': ['http://localhost:8080/auth/realms/master'],
        'client_roles': ['user:do-user-stuff']
    })
    @authenticate()
    @call_api()
    def test_client_roles_unknown_claim(self, status, body):
        self.assertEqual(FORBIDDEN, status)
        self.assertEqual('Access token does not have the required scope/role: Missing required role', body.get('message'))

    ############################################################################
    # Starting from here the "scope" tests happen

    ############################################################################
    # Test if plugin allows the request if minimum one scope matches
    #
    @create_api({
        'allowed_iss': ['http://localhost:8080/auth/realms/master'],
        'scope': ['email']
    })
    @authenticate()
    @call_api()
    def test_client_scope(self, status, body):
        if KC_VERSION.startswith('3'):
            self.skipTest("Test not supported for " + KC_VERSION)
        self.assertEqual(OK, status)


    ############################################################################
    # Test if plugin allows the request if minimum one scope matches
    # ... here "email" is the valid scope
    @create_api({
        'allowed_iss': ['http://localhost:8080/auth/realms/master'],
        'scope': ['not_found', 'something_else', 'email', 'nemore_dummyscope']
    })
    @authenticate()
    @call_api()
    def test_client_multiple_scopes_oneof(self, status, body):
        if KC_VERSION.startswith('3'):
            self.skipTest("Test not supported for " + KC_VERSION)
        self.assertEqual(OK, status)


    ############################################################################
    # Test if plugin blocks request if needed scope is not contained in token 
    #
    @create_api({
        'allowed_iss': ['http://localhost:8080/auth/realms/master'],
        'scope': ['not_found']
    })
    @authenticate()
    @call_api()
    def test_client_scope_rainy(self, status, body):
        self.assertEqual(FORBIDDEN, status)
        self.assertEqual('Access token does not have the required scope/role: Missing required scope', body.get('message'))
