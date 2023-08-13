from tests.utils import *


class TestConsumerMapping(unittest.TestCase):
    TMP_CUSTOM_ID = str(uuid.uuid4())

    ############################################################################
    # Test if plugin sends header "x-consumer-id" to the upstream service
    # 
    @create_api({
        'allowed_iss': ['http://localhost:8080/auth/realms/master'],
        'consumer_match': True
    })
    @authenticate(create_consumer=True)
    @call_api()
    def test_map_consumer(self, status, body):
        self.assertEqual(OK, status)
        self.assertGreater(len(parse_json_response(parse_json_response(body, "headers"), "x-consumer-id")), 1,
                           "x-consumer-id seems to be empty but is a must for the request to upstream in case authentication was successfully." )


    ############################################################################
    # Test if plugin sends header "x-consumer-custom-id" to the upstream service
    # which needs to contain the same value like we have kong configured ...
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
                         [parse_json_response(parse_json_response(body, "headers"), "x-consumer-custom-id")])


    ############################################################################
    # Test if plugin respects the setting of "consumer_match_ignore_not_found"
    # and forwards the request also to the upstream service if there is no
    # user found in kong which is equal with the value of the token claim
    # "preferred_username"
    #
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
