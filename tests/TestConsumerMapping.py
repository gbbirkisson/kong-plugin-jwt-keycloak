import unittest

from tests.utils import *


class TestConsumerMapping(unittest.TestCase):

    def setUp(self):
        ensure_plugin()
        create_consumer(CLIENT_ID)

    def tearDown(self):
        delete_consumer(CLIENT_ID)

    @create_api({
        'allow_all_iss': True,
        'consumer_match': True,
        'consumer_match_claim_custom_id': True
    })
    @authenticate(client_id=CLIENT_ID, client_secret=CLIENT_SECRET)
    @call_api()
    def test_map_consumer(self, status, body):
        self.assertEqual(OK, status)
        self.assertEqual(['test'], [h['value'] for h in body.get('headers') if h['name'] == 'x-consumer-custom-id'])

    @create_api({
        'allow_all_iss': True,
        'consumer_match': True,
        'consumer_match_claim': 'preferred_username',
        'consumer_match_ignore_not_found': True
    })
    @authenticate(client_id=CLIENT_ID, client_secret=CLIENT_SECRET)
    @call_api()
    def test_map_consumer_not_found(self, status, body):
        self.assertEqual(OK, status)
