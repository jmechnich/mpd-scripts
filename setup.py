#!/usr/bin/env python3

import sys
if sys.version_info < (3,4):
    print("Requires python 3.4 or later")
    sys.exit(1)

from setuptools import setup
setup(
    name='mpd-scripts',
    version='1.0',
    description='',
    url='https://github.com/jmechnich/mpd-scripts',
    author='Joerg Mechnich',
    author_email='joerg.mechnich@gmail.com',
    license='MIT',
    scripts=['mpd_dynamic', 'mpd_watch', 'mp3gain'],
    data_files=[('/etc/systemd/system',
                 ['mpd_dynamic.service', 'mpd_watch.service'])],
#    install_requires=["eyed3", "mpd"],
)
