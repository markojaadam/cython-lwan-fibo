from distutils.core import setup
from distutils.extension import Extension
from Cython.Build import cythonize
import sys

setup(
  ext_modules = cythonize([
    Extension("lwan",
              include_dirs=sys.path,
              sources=["lwan_wrapper.pyx"],
              libraries=["lwan", 'gmp', 'mpfr', 'mpc'],
              extra_link_args=['-lgmp'],
              extra_compile_args=['-lgmp']
    )
  ], compiler_directives={'language_level' : "3"}, include_path=sys.path)
)
