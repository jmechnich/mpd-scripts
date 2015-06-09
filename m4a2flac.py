#!/usr/bin/env python

# create file list first
# find $TOPDIR -type f -name \*.m4a | while read i; do (ffprobe "$i" |& grep -q alac) && echo "$i"; done > filelist.txt

import subprocess, os, sys

if len(sys.argv) != 2:
    print "Usage: m4a2flac.py filelist"
    sys.exit(1)

filelist = []
for line in open(sys.argv[1]):
    filelist.append(line.rstrip())
    
print "Processing", len(filelist), "files"

for m4apath in filelist:
    if not os.path.exists(m4apath):
        print m4apath, "does not exist"
        continue
    (m4aroot, m4aext) = os.path.splitext(m4apath)
    flacpath = m4aroot + '.flac'
    subprocess.check_call(['ffmpeg', '-y', '-i', m4apath, flacpath])
    subprocess.check_call(['touch', '-r', m4apath, flacpath])
    os.remove(m4apath)
