import unittest

from tests.utils import *


class TestConsumerMapping2(unittest.TestCase):

    MY_CLIENT_ID = "b6149525-b0b8-4be5-968e-87bad09e0ce5"
    MY_CLIENT_SECRET = "f6fc642e-1d85-4992-95af-ed0be5da2d9b"

    @create_api({
        'allow_all_iss': True,
        'consumer_match': True
    })
    @authenticate(client_id=MY_CLIENT_ID, client_secret=MY_CLIENT_SECRET)
    @call_api()
    def test_map_consumer(self, status, body):
        '''
        To run make this pass, you have to first create a consumer, then create a client in keycloak with the same id,
        and then run that test with those client credentials

        http POST http://localhost:8001/consumers/ username=tester

        '''
        self.assertEqual(OK, status)
        self.assertEqual([self.MY_CLIENT_ID], [h['value'] for h in body.get('headers') if h['name'] == 'x-consumer-id'])