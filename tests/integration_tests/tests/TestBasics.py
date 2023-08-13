from tests.utils import *


# Tokendetails: "iss": "http://localhost:8080/auth/realms/master", "alg": "RS256" --> Already expired !!
STANDARD_JWT = 'eyJhbGciOiJSUzI1NiIsInR5cCIgOiAiSldUIiwia2lkIiA6ICJObjlsNXctQ1lORHUwUGh6MTFoWUNqQ050MGJmb2ZMQjZMcGMtWk5hUkFFIn0.eyJqdGkiOiIwZDBlODEyMy1mNjIxLTQzZWQtOTBjZS0yNWNhZDZhOGQ0MGQiLCJleHAiOjE1MzY1NzgxOTQsIm5iZiI6MCwiaWF0IjoxNTM2NTc4MTM0LCJpc3MiOiJodHRwOi8vbG9jYWxob3N0OjgwODAvYXV0aC9yZWFsbXMvbWFzdGVyIiwiYXVkIjoidGVzdCIsInN1YiI6ImIzY2RjZjcwLTljMDMtNDgwZi1hZGQwLTY4MWNkMzQyYWU1OCIsInR5cCI6IkJlYXJlciIsImF6cCI6InRlc3QiLCJhdXRoX3RpbWUiOjAsInNlc3Npb25fc3RhdGUiOiIxMGMzZWFjNC1kNzlmLTQyOGYtYmVlMC1mNDk3MTEwNTY0NDgiLCJhY3IiOiIxIiwiYWxsb3dlZC1vcmlnaW5zIjpbXSwicmVhbG1fYWNjZXNzIjp7InJvbGVzIjpbInVtYV9hdXRob3JpemF0aW9uIl19LCJyZXNvdXJjZV9hY2Nlc3MiOnsidGVzdCI6eyJyb2xlcyI6WyJ1bWFfcHJvdGVjdGlvbiJdfSwiYWNjb3VudCI6eyJyb2xlcyI6WyJtYW5hZ2UtYWNjb3VudCIsIm1hbmFnZS1hY2NvdW50LWxpbmtzIiwidmlldy1wcm9maWxlIl19fSwiY2xpZW50SG9zdCI6IjE3Mi4xNy4wLjEiLCJjbGllbnRJZCI6InRlc3QiLCJwcmVmZXJyZWRfdXNlcm5hbWUiOiJzZXJ2aWNlLWFjY291bnQtdGVzdCIsImNsaWVudEFkZHJlc3MiOiIxNzIuMTcuMC4xIiwiZW1haWwiOiJzZXJ2aWNlLWFjY291bnQtdGVzdEBwbGFjZWhvbGRlci5vcmcifQ.cFOVC_tLfyTHXB0T8MMJHizVXhDfh36ZwA6BNA3Jhjm-s-_Kt4_acZtbC-jLoch2Q-A4LPGURpG48RgWfALNaRvv6R5rWwOJ3O94bsCVbsAcY7rw-UMEyWz8sO-VObJnHayybVsnfvLzKZaWCsWIRZaMsE9OtiFfRoWgqHOCqMxFl0YX_ugZGGKKfMDjO0-ie-zzRQeUKjKfNdeJSk7OcrlZp8rpP0J616AocWd_NZTiB6RIuP4zy6z28dYY4Pgw5o-_GyoGI7NyDZxTVQ17XzTl_MFV7pTD9pvYzSpGZevcSfMGh00NHdagq9qr7jF65NYuGmZuCn0jUs9TmtLezQ'
# Tokendetails: "iss": "http://localhost:8080/auth/realms/master", "alg": "RS256",
BAD_SIGNATURE = 'eyJhbGciOiJSUzI1NiIsInR5cCIgOiAiSldUIiwia2lkIiA6ICJObjlsNXctQ1lORHUwUGh6MTFoWUNqQ050MGJmb2ZMQjZMcGMtWk5hUkFFIn0.eyJqdGkiOiI0NTQwMGZiNi01MTE0LTRkNWUtOTNkOC1jYjgzYjM0MDFjMjMiLCJleHAiOjE2MjI5ODI4NjAsIm5iZiI6MCwiaWF0IjoxNTM2NTgyODYwLCJpc3MiOiJodHRwOi8vbG9jYWxob3N0OjgwODAvYXV0aC9yZWFsbXMvbWFzdGVyIiwiYXVkIjoidGVzdCIsInN1YiI6ImIzY2RjZjcwLTljMDMtNDgwZi1hZGQwLTY4MWNkMzQyYWU1OCIsInR5cCI6IkJlYXJlciIsImF6cCI6InRlc3QiLCJhdXRoX3RpbWUiOjAsInNlc3Npb25fc3RhdGUiOiJiNTNjNmZhZC0xYWJjLTRmMjYtOGUzNi01MDhkOTdjMTI4NmEiLCJhY3IiOiIxIiwiYWxsb3dlZC1vcmlnaW5zIjpbXSwicmVhbG1fYWNjZXNzIjp7InJvbGVzIjpbInVtYV9hdXRob3JpemF0aW9uIl19LCJyZXNvdXJjZV9hY2Nlc3MiOnsidGVzdCI6eyJyb2xlcyI6WyJ1bWFfcHJvdGVjdGlvbiJdfSwiYWNjb3VudCI6eyJyb2xlcyI6WyJtYW5hZ2UtYWNjb3VudCIsIm1hbmFnZS1hY2NvdW50LWxpbmtzIiwidmlldy1wcm9maWxlIl19fSwiY2xpZW50SG9zdCI6IjE3Mi4xNy4wLjEiLCJjbGllbnRJZCI6InRlc3QiLCJwcmVmZXJyZWRfdXNlcm5hbWUiOiJzZXJ2aWNlLWFjY291bnQtdGVzdCIsImNsaWVudEFkZHJlc3MiOiIxNzIuMTcuMC4xIiwiZW1haWwiOiJzZXJ2aWNlLWFjY291bnQtdGVzdEBwbGFjZWhvbGRlci5vcmcifQ.PtpAE8sCkSWuosm7chw_TH2qAQuRIugP-1688WtZ9ZpkrulZ1OxxfAtnJY1eCYk0C4LQd14eI5d-1srim96FGdgG0BKq4T0TknG5JgQsPignMy2JnJWz-ZozO8a6FMLfpGT0hUQyiDbLRs3VES8RV3N_2uxl0ihy_tJ_wvCU0GrBF5-e2z4R-99zWuOpPbDvnDlP6YfCxLsp77ng4HYB1rBSG9100mpkTBsL8Q48HBZk_qAVdHhGRxqTXDEMYPd3gsKNu184DAsE0I1Ea9D0QXijvH7SVoUJvmZwQ0hOtg1bzWxIeIW1sVDqshkaG58kkiomG7G-9RzKrWOxg3lyQ'

class TestBasics(unittest.TestCase):

    ############################################################################
    # Test if plugin denies requests if completely no token is send to the 
    # kong instance .. it needs to fail
    @create_api({
        'allowed_iss': ['http://localhost:8080/auth/realms/master']
    })
    @call_api()
    def test_no_auth(self, status, body):
        self.assertEqual(UNAUTHORIZED, status)
        self.assertEqual('Unauthorized', body.get('message'))

    ############################################################################
    # Test if plugin allows preflight access without token when configured 
    # ... request is without any authentication contained
    @create_api({
        'run_on_preflight': False,
        'allowed_iss': ['http://localhost:8080/auth/realms/master']
    })
    @call_api(method='options')
    def test_preflight_success(self, status, body):
        self.assertEqual(OK, status)

    ############################################################################
    # Test if plugin denies by default preflight requests in a unauthenticated
    # way ... It needs to fail
    @create_api({
        'allowed_iss': ['http://localhost:8080/auth/realms/master']
    })
    @call_api()
    def test_preflight_failure(self, status, body):
        self.assertEqual(UNAUTHORIZED, status)
        self.assertEqual('Unauthorized', body.get('message'))

    ############################################################################
    # Test if plugin denies a request param "jwt" which contains no valid token
    # --> It needs to be denied
    @create_api({
        'allowed_iss': ['http://localhost:8080/auth/realms/master']
    })
    @call_api(params={"jwt": "SomeNonSenseJwtTokenValue.1234"})
    def test_bad_token_as_param(self, status, body):
        self.assertEqual(UNAUTHORIZED, status)

    ############################################################################
    # Test if plugin accepts a request param "jwt" a valid token
    # --> It needs to be allowed
    @create_api({
        'allowed_iss': ['http://localhost:8080/auth/realms/master']
    })
    @authenticate() # Get current requested token
    @call_api(authentication_type={"queryparam":"jwt"})
    def test_good_token_as_param(self, status, body):
        self.assertEqual(OK, status)

    ############################################################################
    # Test if plugin denies requests if token contains a different algorithm
    # as it is configured for the plugin.
    # Test-Token "STANDARD_JWT" contains 'algorithm': 'RS256'
    @create_api({
        'algorithm': 'HS256',
        'allowed_iss': ['http://localhost:8080/auth/realms/master']
    })
    @call_api(token=STANDARD_JWT)
    def test_invalid_algorithm(self, status, body):
        self.assertEqual(FORBIDDEN, status)
        self.assertEqual('Invalid algorithm', body.get('message'))


    ############################################################################
    # Test if plugin denies requests if token is issued by a different "iss"
    # Token is only valid for "master" realm
    @create_api({
        'allowed_iss': ['http://localhost:8080/auth/realms/somethingElseThenMaster']
    })
    @authenticate() # Use current requested token
    @call_api()
    def test_invalid_iss(self, status, body):
        self.assertEqual(UNAUTHORIZED, status)
        self.assertEqual('Token issuer not allowed', body.get('message'))


    ############################################################################
    # Test if plugin denies requests if token is more then 10 minutes valid
    # (in this setup here all fresh requested tokens are 20 minutes valid)
    @create_api({
        'allowed_iss': ['http://localhost:8080/auth/realms/master'],
        'maximum_expiration': 600
    })
    @authenticate() # Use current requested token
    @call_api()
    def test_max_exp(self, status, body):
        self.assertEqual(FORBIDDEN, status)
        self.assertEqual('Token claims invalid: ["exp"]="exceeds maximum allowed expiration"', body.get('message'))

    ############################################################################
    # Test if plugin denies requests if token contains a bad signature
    @create_api({
        'allowed_iss': ['http://localhost:8080/auth/realms/master']
    })
    @call_api(token=BAD_SIGNATURE)
    def test_bad_signature(self, status, body):
        self.assertEqual(UNAUTHORIZED, status)
        self.assertEqual('Bad token; invalid signature', body.get('message'))

    ############################################################################
    # Test if plugin denies requests if token is already expired
    #
    # !! Execute this as last test .. it uses a short living token which
    #    was at the beginning of this test cases requested.
    @create_api({
        'allowed_iss': ['http://localhost:8080/auth/realms/master']
    })
    @call_api(token=TD_TOKEN_EXPIRED)
    def test_invalid_exp(self, status, body):
        self.assertEqual(UNAUTHORIZED, status)
        self.assertEqual('Token claims invalid: ["exp"]="token expired"', body.get('message'))
