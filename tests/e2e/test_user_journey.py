"""E2E tests: exercise complete user journeys through the public entrypoint.

Replace with Playwright/Cypress when the service gains a UI.
"""

import json
import os
import unittest
from urllib.request import urlopen

BASE_URL = os.getenv("BASE_URL", "http://localhost:8080").rstrip("/")


class GreetingJourneyTest(unittest.TestCase):
    def test_visitor_is_greeted_by_name(self):
        # 1. Platform is healthy
        with urlopen(f"{BASE_URL}/healthz", timeout=5) as r:
            self.assertEqual(r.status, 200)
        # 2. Anonymous visitor gets default greeting
        with urlopen(f"{BASE_URL}/api/v1/hello", timeout=5) as r:
            self.assertEqual(json.load(r)["message"], "Hello, world!")
        # 3. Identified visitor gets personalised greeting
        with urlopen(f"{BASE_URL}/api/v1/hello?name=Maria", timeout=5) as r:
            self.assertEqual(json.load(r)["message"], "Hello, Maria!")


if __name__ == "__main__":
    unittest.main()
