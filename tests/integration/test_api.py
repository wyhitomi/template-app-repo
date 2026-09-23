"""Integration tests: verify service contracts against a running instance."""

import json
import os
import unittest
from urllib.error import HTTPError
from urllib.request import urlopen

BASE_URL = os.getenv("BASE_URL", "http://localhost:8080").rstrip("/")


def get(path: str):
    with urlopen(f"{BASE_URL}{path}", timeout=5) as r:
        return r.status, r.headers.get("Content-Type"), json.load(r)


class ApiContractTest(unittest.TestCase):
    def test_readiness(self):
        status, ctype, body = get("/readyz")
        self.assertEqual(status, 200)
        self.assertEqual(ctype, "application/json")
        self.assertIn("version", body)

    def test_hello_contract(self):
        _, _, body = get("/api/v1/hello?name=integration")
        self.assertEqual(body, {"message": "Hello, integration!"})

    def test_unknown_route_returns_404(self):
        with self.assertRaises(HTTPError) as ctx:
            get("/does-not-exist")
        self.assertEqual(ctx.exception.code, 404)


if __name__ == "__main__":
    unittest.main()
