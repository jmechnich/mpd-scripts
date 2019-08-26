#!/usr/bin/python3 -u

from distutils.core import setup

setup(name='mpd-scripts',
      version='1.0',
      description='',
      author='Joerg Mechnich',
      author_email='joerg.mechnich@gmail.com',
      url='https://github.com/jmechnich/mpd-scripts',
      packages=['mpd_scripts'],
      scripts=['mpd_dynamic', 'mpd_watch', 'mp3gain'],
      data_files=[('/etc/systemd/system',
                   ['mpd_dynamic.service', 'mpd_watch.service'])],
     )
