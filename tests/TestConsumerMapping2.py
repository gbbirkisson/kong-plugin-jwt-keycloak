import unittest

from tests.utils import *


class TestConsumerMapping2(unittest.TestCase):

    MY_CLIENT_ID = "2fc355a4-ee75-4acf-8461-8af8d7ab69e1"
    MY_CLIENT_SECRET = "ef39aeab-c31c-4192-bc42-af6603149929"

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
        '''
        self.skipTest("Manual steps required !!")
        self.assertEqual(OK, status)
        self.assertEqual([self.MY_CLIENT_ID], [h['value'] for h in body.get('headers') if h['name'] == 'x-consumer-id'])