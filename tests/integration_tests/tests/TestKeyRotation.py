from tests.utils import *


def delete_key_if_present(name):
    k = kc_get_key(name)
    if k is not None:
        try:
            kc_delete_key(k)
        except:
            pass


class TestKeyRotation(unittest.TestCase):

    def setUp(self):
        @create_api({
            'allowed_iss': ['http://localhost:8080/auth/realms/master'],
            'iss_key_grace_period': 1
        })
        def makeApi(**kwargs):
            self.endpoint = kwargs['api_endpoint']

        makeApi()

    def tearDown(self):
        delete_key_if_present('new_key_1')
        delete_key_if_present('new_key_2')

    @authenticate()
    def get_token(self, token=None):
        return token

    def call_api(self, token, expected_status):
        @authenticate()
        @call_api(token=token, endpoint=self.endpoint)
        def call_with_token(status, body):
            self.assertEqual(expected_status, status)

        call_with_token()

    def test_key_rotation(self):
        token_1 = self.get_token()
        self.call_api(token_1, OK)

        new_key_1 = kc_add_key('new_key_1', 120)
        time.sleep(1)

        token_2 = self.get_token()

        self.call_api(token_1, OK)
        self.call_api(token_2, OK)

        kc_add_key('new_key_2', 130)
        kc_delete_key(new_key_1)
        time.sleep(1)

        token_3 = self.get_token()

        self.call_api(token_3, OK)
        self.call_api(token_1, OK)
        self.call_api(token_2, UNAUTHORIZED)
