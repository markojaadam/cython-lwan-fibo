# cython-lwan-fibo
A high-performant simple multicore cython-powered HTTP server computing for nth element of fibonacci series
- Based on https://www.nexedi.com/NXD-Blog.Multicore.Python.HTTP.Server

# Requirements

- python3.6+
- cython
- gcc 9+
- libgmp-dev
- zlib1g-dev
- lwan (can be installed via install_lwan.sh)

# Installation steps
1) Install dependencies
2) `mkdir wwwroot`
3) `make run`

# Usage
Note: accepts input up to 50000!
```
$ curl -l http://localhost:8080/fib?n=50
55
```
