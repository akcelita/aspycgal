import os
import os.path
from setuptools import setup
from Cython.Build import cythonize
from distutils.extension import Extension
import numpy
from pathlib import Path
import subprocess


def parse_ldc_lines(lines):
    for line in lines:
        if ' => ' in line and line[-3:] in ('.dll', '.so'):
            p = Path(line.split(' => ')[1])
            pname = p.name.split('.')[0]
            path = str(p)
            yield pname, path

LIBS = ('libmpfr', 'libgmp')
libpaths = {
    pname: path
    for pname, path in parse_ldc_lines(subprocess.run(['ldconfig', '-p'], capture_output=True, encoding='latin-1').stdout.split('\n'))
    if pname in LIBS
}

for lib in LIBS:
    if lib in libpaths:
        print("Path for {}: {}".format(lib, libpaths[lib]))
    else:
        print("Could not find path for {}".format(lib))


def modify_extension(ext, **kwargs):
    for param, vals in kwargs.items():
        getattr(ext, param).extend(vals)

    return ext

setup(
    name='aspycgal',
    version='0.0.1',
    description='Python package wrapping and using cgal library',
    # url='https://github.com/akcelita/aspycgal',
    # author='Ackelita',
    # author_email='akcelita@gmail.com',
    # packages=['aspycgal'],
    # packages=[
    #     f.replace(os.sep, '.')
    #     for f in sorted(get_folders_having_ext('.py'))
    # ],
    # package_data={
    #     f.replace(os.sep, '.'): ['*.yaml']
    #     for f in get_folders_having_ext('.yaml')
    # },
    # install_requires=[
    #     'annoy',
    #     'munkres',
    #     'numpy',
    # ],
    zip_safe=False,
    # setup_requires=['pytest-runner'],
    # tests_require=['pytest'],
    ext_modules=[modify_extension(cext,
        sources=['src/wrapper/ascgal_wrapper.cpp'],
        include_dirs=['src'],
        extra_link_args=[
            libpaths['libmpfr'],
            libpaths['libgmp'],
        ],
    ) for cext in cythonize(
        "src/*.pyx",
        include_path=[numpy.get_include()],
        compiler_directives={'linetrace': True},
    )],
    include_dirs=[numpy.get_include()]
)
