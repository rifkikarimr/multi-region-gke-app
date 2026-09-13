import unittest

from app.app import create_app


class ApplicationTest(unittest.TestCase):
    def setUp(self):
        self.client = create_app().test_client()

    def test_index(self):
        response = self.client.get("/")

        self.assertEqual(response.status_code, 200)
        self.assertEqual(response.get_json()["region"], "local")

    def test_health(self):
        response = self.client.get("/healthz")

        self.assertEqual(response.status_code, 200)
        self.assertEqual(response.get_json(), {"status": "ok"})


if __name__ == "__main__":
    unittest.main()
