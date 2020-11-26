import unittest
import requests

DEPLOY_URL = "http://localhost:8080/fib"
ERRESP = 'Error: invalid input.'

def fib(n):
   a, b = 0, 1
   for i in range(n): 
     a, b = b, a + b
   return a 

class TestFib(unittest.TestCase):
    def test_fib_valid(self):
        for valid_i in range(1, 10001, 100):
            resp = requests.get(DEPLOY_URL, params={"n": valid_i})
            self.assertEqual(fib(valid_i),int(resp.content.decode()))

    def test_fib_invalid(self):
        for invalid in ['010', 'aaa', '10a', 100000, 0, -1, b'\x10']:
            resp = requests.get(DEPLOY_URL, params={"n": invalid})
            self.assertEqual(resp.content.decode(), ERRESP)


if __name__ == '__main__':
    unittest.main()
