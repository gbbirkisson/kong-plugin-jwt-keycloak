from tests.utils import *


class TestConsumerMapping(unittest.TestCase):
    TMP_CUSTOM_ID = str(uuid.uuid4())

    @create_api({
        'allowed_iss': ['http://localhost:8080/auth/realms/master'],
        'consumer_match': True
    })
    @authenticate(create_consumer=True)
    @call_api()
    def test_map_consumer(self, status, body):
        self.assertEqual(OK, status)
        self.assertEqual(1, len([h['value'] for h in body.get('headers') if h['name'] == 'x-consumer-id']))

    @create_api({
        'allowed_iss': ['http://localhost:8080/auth/realms/master'],
        'consumer_match': True,
        'consumer_match_claim_custom_id': True
    })
    @authenticate(create_consumer=True, custom_id=TMP_CUSTOM_ID)
    @call_api()
    def test_map_consumer_custom_id(self, status, body):
        self.assertEqual(OK, status)
        self.assertEqual([self.TMP_CUSTOM_ID],
                         [h['value'] for h in body.get('headers') if h['name'] == 'x-consumer-custom-id'])

    @create_api({
        'allowed_iss': ['http://localhost:8080/auth/realms/master'],
        'consumer_match': True,
        'consumer_match_claim': 'preferred_username',
        'consumer_match_ignore_not_found': True
    })
    @authenticate()
    @call_api()
    def test_map_consumer_not_found(self, status, body):
        self.assertEqual(OK, status)
