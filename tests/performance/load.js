// k6 load test. Thresholds are the pass/fail SLO gate used by CI.
// Run locally: make test-perf   |   against an env: make test-perf BASE_URL=https://...
import http from 'k6/http';
import { check, sleep } from 'k6';

const BASE_URL = __ENV.BASE_URL || 'http://localhost:8080';

export const options = {
  scenarios: {
    ramping: {
      executor: 'ramping-vus',
      startVUs: 0,
      stages: [
        { duration: '15s', target: 10 },
        { duration: '30s', target: 10 },
        { duration: '15s', target: 0 },
      ],
    },
  },
  thresholds: {
    http_req_failed: ['rate<0.01'],   // <1% errors
    http_req_duration: ['p(95)<300'], // p95 < 300ms
    checks: ['rate>0.99'],
  },
};

export default function () {
  const res = http.get(`${BASE_URL}/api/v1/hello?name=k6`);
  check(res, {
    'status is 200': (r) => r.status === 200,
    'has message': (r) => r.json('message') !== undefined,
  });
  sleep(1);
}
