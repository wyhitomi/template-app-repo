import json
import threading
import unittest
from http.server import ThreadingHTTPServer
from urllib.request import urlopen

from app.main import Handler, greet


class GreetTest(unittest.TestCase):
    def test_default_name(self):
        self.assertEqual(greet(None), {"message": "Hello, world!"})

    def test_custom_name(self):
        self.assertEqual(greet("Ana"), {"message": "Hello, Ana!"})


class HandlerTest(unittest.TestCase):
    @classmethod
    def setUpClass(cls):
        cls.server = ThreadingHTTPServer(("127.0.0.1", 0), Handler)
        cls.base = f"http://127.0.0.1:{cls.server.server_address[1]}"
        threading.Thread(target=cls.server.serve_forever, daemon=True).start()

    @classmethod
    def tearDownClass(cls):
        cls.server.shutdown()
        cls.server.server_close()

    def test_healthz(self):
        with urlopen(f"{self.base}/healthz") as r:
            self.assertEqual(r.status, 200)
            self.assertEqual(json.load(r)["status"], "ok")

    def test_hello(self):
        with urlopen(f"{self.base}/api/v1/hello?name=CI") as r:
            self.assertEqual(json.load(r), {"message": "Hello, CI!"})


if __name__ == "__main__":
    unittest.main()
