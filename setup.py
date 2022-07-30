#!/usr/bin/env python3

from setuptools import find_packages, setup

with open("README.md", "r") as fh:
    long_description = fh.read()

setup(
    name='mpd-scripts',
    author='Joerg Mechnich',
    author_email='joerg.mechnich@gmail.com',
    description='A collection of scripts related to the Music Player Daemon.',
    long_description=long_description,
    long_description_content_type="text/markdown",
    url='https://github.com/jmechnich/mpd-scripts',
    license='MIT',
    use_scm_version={"local_scheme": "no-local-version"},
    setup_requires=['setuptools_scm'],
    install_requires=["python-mpd2", "eyeD3"],
    scripts=['mpd_dynamic', 'mpd_watch', 'mp3gain'],
    data_files = [
        ('share/applications', ['mpd_dynamic.desktop']),
    ],
    python_requires='>=3.6',
)
