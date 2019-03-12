from tests.utils import *

STANDARD_JWT = 'eyJhbGciOiJSUzI1NiIsInR5cCIgOiAiSldUIiwia2lkIiA6ICJObjlsNXctQ1lORHUwUGh6MTFoWUNqQ050MGJmb2ZMQjZMcGMtWk5hUkFFIn0.eyJqdGkiOiIwZDBlODEyMy1mNjIxLTQzZWQtOTBjZS0yNWNhZDZhOGQ0MGQiLCJleHAiOjE1MzY1NzgxOTQsIm5iZiI6MCwiaWF0IjoxNTM2NTc4MTM0LCJpc3MiOiJodHRwOi8vbG9jYWxob3N0OjgwODAvYXV0aC9yZWFsbXMvbWFzdGVyIiwiYXVkIjoidGVzdCIsInN1YiI6ImIzY2RjZjcwLTljMDMtNDgwZi1hZGQwLTY4MWNkMzQyYWU1OCIsInR5cCI6IkJlYXJlciIsImF6cCI6InRlc3QiLCJhdXRoX3RpbWUiOjAsInNlc3Npb25fc3RhdGUiOiIxMGMzZWFjNC1kNzlmLTQyOGYtYmVlMC1mNDk3MTEwNTY0NDgiLCJhY3IiOiIxIiwiYWxsb3dlZC1vcmlnaW5zIjpbXSwicmVhbG1fYWNjZXNzIjp7InJvbGVzIjpbInVtYV9hdXRob3JpemF0aW9uIl19LCJyZXNvdXJjZV9hY2Nlc3MiOnsidGVzdCI6eyJyb2xlcyI6WyJ1bWFfcHJvdGVjdGlvbiJdfSwiYWNjb3VudCI6eyJyb2xlcyI6WyJtYW5hZ2UtYWNjb3VudCIsIm1hbmFnZS1hY2NvdW50LWxpbmtzIiwidmlldy1wcm9maWxlIl19fSwiY2xpZW50SG9zdCI6IjE3Mi4xNy4wLjEiLCJjbGllbnRJZCI6InRlc3QiLCJwcmVmZXJyZWRfdXNlcm5hbWUiOiJzZXJ2aWNlLWFjY291bnQtdGVzdCIsImNsaWVudEFkZHJlc3MiOiIxNzIuMTcuMC4xIiwiZW1haWwiOiJzZXJ2aWNlLWFjY291bnQtdGVzdEBwbGFjZWhvbGRlci5vcmcifQ.cFOVC_tLfyTHXB0T8MMJHizVXhDfh36ZwA6BNA3Jhjm-s-_Kt4_acZtbC-jLoch2Q-A4LPGURpG48RgWfALNaRvv6R5rWwOJ3O94bsCVbsAcY7rw-UMEyWz8sO-VObJnHayybVsnfvLzKZaWCsWIRZaMsE9OtiFfRoWgqHOCqMxFl0YX_ugZGGKKfMDjO0-ie-zzRQeUKjKfNdeJSk7OcrlZp8rpP0J616AocWd_NZTiB6RIuP4zy6z28dYY4Pgw5o-_GyoGI7NyDZxTVQ17XzTl_MFV7pTD9pvYzSpGZevcSfMGh00NHdagq9qr7jF65NYuGmZuCn0jUs9TmtLezQ'
NOT_FOUND_JWT = 'eyJhbGciOiJSUzI1NiIsInR5cCIgOiAiSldUIiwia2lkIiA6ICJLTFczaVNKQUNndkxvci1qMlAzWFdGVXZBR1dTakdGWlZ2TUNmcDhITHdnIn0.eyJqdGkiOiI1MjA5MDA1Yi02NjI2LTQ4Y2MtODg0Mi1mYzQ4MWNhZTI0MzkiLCJleHAiOjE2MjI5ODE5ODMsIm5iZiI6MCwiaWF0IjoxNTM2NTgxOTgzLCJpc3MiOiJodHRwOi8vbG9jYWxob3N0OjgwODAvYXV0aC9yZWFsbXMvTk9UX0ZPVU5EIiwiYXVkIjoidGVzdCIsInN1YiI6ImVlMTMwMWY0LTJlNmYtNGEwYi1hYjQ0LTgzNzExZGE3NWRkNyIsInR5cCI6IkJlYXJlciIsImF6cCI6InRlc3QiLCJhdXRoX3RpbWUiOjAsInNlc3Npb25fc3RhdGUiOiI4YWQ2MDNkMy1kYmYwLTQ4NmQtYWYyOC1hNmI2ZDJlODcxYzIiLCJhY3IiOiIxIiwiYWxsb3dlZC1vcmlnaW5zIjpbXSwicmVhbG1fYWNjZXNzIjp7InJvbGVzIjpbInVtYV9hdXRob3JpemF0aW9uIl19LCJyZXNvdXJjZV9hY2Nlc3MiOnsidGVzdCI6eyJyb2xlcyI6WyJ1bWFfcHJvdGVjdGlvbiJdfSwiYWNjb3VudCI6eyJyb2xlcyI6WyJtYW5hZ2UtYWNjb3VudCIsIm1hbmFnZS1hY2NvdW50LWxpbmtzIiwidmlldy1wcm9maWxlIl19fSwiY2xpZW50SG9zdCI6IjE3Mi4xNy4wLjEiLCJjbGllbnRJZCI6InRlc3QiLCJwcmVmZXJyZWRfdXNlcm5hbWUiOiJzZXJ2aWNlLWFjY291bnQtdGVzdCIsImNsaWVudEFkZHJlc3MiOiIxNzIuMTcuMC4xIiwiZW1haWwiOiJzZXJ2aWNlLWFjY291bnQtdGVzdEBwbGFjZWhvbGRlci5vcmcifQ.q5Sf3oL3i4dexGo8F7Qm4g4yzxApaAqbve1ijENg__08h_M6CBYf1b6J9bRrr4qriDWlyFW7N6nmyK5jyBMSVA_2oRoCxSFf4wUigjO1RcnMHC9w5Gd0DNfsA21kiNE2OiEEc-YNM5J7MXTOo5ueO79E8-8eVKjs25QipfZ_wF01MAF6bKKjVhOytBvRwUqPrxZ_37AhMcPEtcdSs0rvnKioZnNqQPTutNzvwfTwNO7neWI4RSJdSKJlx_yfxZbLHDtXRCPlqCfBFeiL1VfbJlpB-sRgAe7Lf8Mp28G_mAIzi2lm639QFjFZOLs8ykytmJSCdfsrwJZ6PO0kZBzAlw'
BAD_SIGNATURE = 'eyJhbGciOiJSUzI1NiIsInR5cCIgOiAiSldUIiwia2lkIiA6ICJObjlsNXctQ1lORHUwUGh6MTFoWUNqQ050MGJmb2ZMQjZMcGMtWk5hUkFFIn0.eyJqdGkiOiI0NTQwMGZiNi01MTE0LTRkNWUtOTNkOC1jYjgzYjM0MDFjMjMiLCJleHAiOjE2MjI5ODI4NjAsIm5iZiI6MCwiaWF0IjoxNTM2NTgyODYwLCJpc3MiOiJodHRwOi8vbG9jYWxob3N0OjgwODAvYXV0aC9yZWFsbXMvbWFzdGVyIiwiYXVkIjoidGVzdCIsInN1YiI6ImIzY2RjZjcwLTljMDMtNDgwZi1hZGQwLTY4MWNkMzQyYWU1OCIsInR5cCI6IkJlYXJlciIsImF6cCI6InRlc3QiLCJhdXRoX3RpbWUiOjAsInNlc3Npb25fc3RhdGUiOiJiNTNjNmZhZC0xYWJjLTRmMjYtOGUzNi01MDhkOTdjMTI4NmEiLCJhY3IiOiIxIiwiYWxsb3dlZC1vcmlnaW5zIjpbXSwicmVhbG1fYWNjZXNzIjp7InJvbGVzIjpbInVtYV9hdXRob3JpemF0aW9uIl19LCJyZXNvdXJjZV9hY2Nlc3MiOnsidGVzdCI6eyJyb2xlcyI6WyJ1bWFfcHJvdGVjdGlvbiJdfSwiYWNjb3VudCI6eyJyb2xlcyI6WyJtYW5hZ2UtYWNjb3VudCIsIm1hbmFnZS1hY2NvdW50LWxpbmtzIiwidmlldy1wcm9maWxlIl19fSwiY2xpZW50SG9zdCI6IjE3Mi4xNy4wLjEiLCJjbGllbnRJZCI6InRlc3QiLCJwcmVmZXJyZWRfdXNlcm5hbWUiOiJzZXJ2aWNlLWFjY291bnQtdGVzdCIsImNsaWVudEFkZHJlc3MiOiIxNzIuMTcuMC4xIiwiZW1haWwiOiJzZXJ2aWNlLWFjY291bnQtdGVzdEBwbGFjZWhvbGRlci5vcmcifQ.PtpAE8sCkSWuosm7chw_TH2qAQuRIugP-1688WtZ9ZpkrulZ1OxxfAtnJY1eCYk0C4LQd14eI5d-1srim96FGdgG0BKq4T0TknG5JgQsPignMy2JnJWz-ZozO8a6FMLfpGT0hUQyiDbLRs3VES8RV3N_2uxl0ihy_tJ_wvCU0GrBF5-e2z4R-99zWuOpPbDvnDlP6YfCxLsp77ng4HYB1rBSG9100mpkTBsL8Q48HBZk_qAVdHhGRxqTXDEMYPd3gsKNu184DAsE0I1Ea9D0QXijvH7SVoUJvmZwQ0hOtg1bzWxIeIW1sVDqshkaG58kkiomG7G-9RzKrWOxg3lyQ'
LONG_LASTING = 'eyJhbGciOiJSUzI1NiIsInR5cCIgOiAiSldUIiwia2lkIiA6ICJvQ084ZEZ3RWxNdVNtU2d3bXlhN05iMlJNamZOQ3pxTTVrLVozMDFZUUZRIn0.eyJqdGkiOiJiN2QwZGIyOS00ZTY0LTRkNTgtOTM5Ni1hMTBjNmI2MDUyODYiLCJleHAiOjE2MjI5OTE3MjgsIm5iZiI6MCwiaWF0IjoxNTM2NTkxNzI4LCJpc3MiOiJodHRwOi8vbG9jYWxob3N0OjgwODAvYXV0aC9yZWFsbXMvbWFzdGVyIiwiYXVkIjoidGVzdCIsInN1YiI6ImQ5YWU5NzJiLTVmYzEtNDFjNC1iN2I0LWRmMDE4NDYyZmFiZiIsInR5cCI6IkJlYXJlciIsImF6cCI6InRlc3QiLCJhdXRoX3RpbWUiOjAsInNlc3Npb25fc3RhdGUiOiI0ODc1N2I5MS0wOTQ0LTRkNzEtOGFmZS0zZDQ3MGI5MDc0MjciLCJhY3IiOiIxIiwiYWxsb3dlZC1vcmlnaW5zIjpbXSwicmVhbG1fYWNjZXNzIjp7InJvbGVzIjpbInVtYV9hdXRob3JpemF0aW9uIl19LCJyZXNvdXJjZV9hY2Nlc3MiOnsidGVzdCI6eyJyb2xlcyI6WyJ1bWFfcHJvdGVjdGlvbiJdfSwiYWNjb3VudCI6eyJyb2xlcyI6WyJtYW5hZ2UtYWNjb3VudCIsIm1hbmFnZS1hY2NvdW50LWxpbmtzIiwidmlldy1wcm9maWxlIl19fSwiY2xpZW50SWQiOiJ0ZXN0IiwiY2xpZW50SG9zdCI6IjE3Mi4xNy4wLjEiLCJwcmVmZXJyZWRfdXNlcm5hbWUiOiJzZXJ2aWNlLWFjY291bnQtdGVzdCIsImNsaWVudEFkZHJlc3MiOiIxNzIuMTcuMC4xIiwiZW1haWwiOiJzZXJ2aWNlLWFjY291bnQtdGVzdEBwbGFjZWhvbGRlci5vcmcifQ.GH9Qof8bJk--mZW6SCXKRKeHV39Qhin9QqBAdDqNQmABDnbmGN9vDaceowHUs6M5Yr4In2lGAWVGjRH_k6eajvZCVjZHQVELLzjjwEDrL-syIImYYT2VG0TV4pJ3K8VD0-M_aAbmeYXA9kndk3bsM157nPu-cH0XvDTzJTra2IVJc9LSXxOD26XQDzOp0Hs5VObyDDnZJscnfcq_OmnfrNjN6h1TujUqtMIw_ZEYtG64R9aRG2QF2rwLuX6ED4OoX23AjqfjOH21AoIXYRwp_RtxDB57U-dX-vSY9MfdHAb7FnEKNE2ciPOZ_2zyj6RdAMY5IkDOFyqmS-nIqLQRTA'


class TestBasics(unittest.TestCase):

    @create_api({
        'allowed_iss': ['http://localhost:8080/auth/realms/master']
    })
    @call_api()
    def test_no_auth(self, status, body):
        self.assertEqual(UNAUTHORIZED, status)
        self.assertEqual('Unauthorized', body.get('message'))

    @create_api({
        'allowed_iss': ['http://localhost:8080/auth/realms/master']
    })
    @call_api()
    def test_preflight_rainy(self, status, body):
        self.assertEqual(UNAUTHORIZED, status)
        self.assertEqual('Unauthorized', body.get('message'))

    @create_api({
        'run_on_preflight': False,
        'allowed_iss': ['http://localhost:8080/auth/realms/master']
    })
    @call_api(method='options')
    def test_preflight(self, status, body):
        self.assertEqual(OK, status)

    @create_api({
        'allowed_iss': ['http://localhost:8080/auth/realms/master']
    })
    @call_api(params={"jwt": 1234})
    def test_bad_token(self, status, body):
        self.assertEqual(UNAUTHORIZED, status)

    @create_api({
        'algorithm': 'HS256',
        'allowed_iss': ['http://localhost:8080/auth/realms/master']
    })
    @call_api(token=STANDARD_JWT)
    def test_invalid_algorithm(self, status, body):
        self.assertEqual(FORBIDDEN, status)
        self.assertEqual('Invalid algorithm', body.get('message'))

    @create_api({
        'allowed_iss': ['http://localhost:8080/auth/realms/master']
    })
    @call_api(token=STANDARD_JWT)
    def test_invalid_exp(self, status, body):
        self.assertEqual(UNAUTHORIZED, status)
        self.assertEqual('Token claims invalid: ["exp"]="token expired"', body.get('message'))

    @create_api({
        'allowed_iss': ['http://localhost:8080/auth/realms/NOT_FOUND']
    })
    @call_api(token=NOT_FOUND_JWT)
    def test_invalid_iss(self, status, body):
        self.assertEqual(FORBIDDEN, status)
        self.assertEqual('Unable to get public key for issuer', body.get('message'))

    @create_api({
        'allowed_iss': ['http://localhost:8080/auth/realms/master'],
        'maximum_expiration': 5000
    })
    @call_api(token=LONG_LASTING)
    def test_max_exp(self, status, body):
        self.assertEqual(FORBIDDEN, status)
        self.assertEqual('Token claims invalid: ["exp"]="exceeds maximum allowed expiration"', body.get('message'))

    @create_api({
        'allowed_iss': ['http://localhost:8080/auth/realms/master']
    })
    @call_api(token=BAD_SIGNATURE)
    def test_bad_signature(self, status, body):
        self.assertEqual(UNAUTHORIZED, status)
        self.assertEqual('Bad token; invalid signature', body.get('message'))
