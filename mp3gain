#! /usr/bin/env python

import os, sys, subprocess
import eyeD3

# preserve file modification times ?
preserve_mtime = True

# only accept mp3 files as m4a do not use id3 tags
filelist = sys.argv[1:]
for f in filelist:
   if not f.endswith('.mp3'):
      print "Use with mp3 files only"
      sys.exit(1)

# aacgain supports mp3 and m4a with AAC-LC (no Apple Lossless / ALAC)
cmd = ["aacgain", "-o", "-s", "s", "-q"] + filelist
pipe = subprocess.Popen(cmd, stdout=subprocess.PIPE).stdout

# skip first line of output (header)
pipe.next()

# parse output
trackinfo = []
for line in pipe:
   parts = line.rstrip("\n").split("\t")
   if parts[0] == '"Album"':
      albumframes = {
            "replaygain_album_gain": "%.2f dB" % (float(parts[2])),
            "replaygain_album_peak": "%.6f"    % (float(parts[3])/32768.),
         }
   else:
      trackinfo.append(parts)

# write replay gain frames to files
for entry in trackinfo:
   filename = entry[0]
   if preserve_mtime:
      stat = os.stat(filename)
   # detect file error
   if len(entry) == 1:
      print filename
      continue
   trackframes = {
      "replaygain_track_gain": "%.2f dB" % (float( entry[2])),
      "replaygain_track_peak": "%.6f"    % (float( entry[3])/32768.),
   }
   if len(trackinfo) > 1:
      trackframes.update(albumframes)
   tag = eyeD3.Tag()
   tag.link(filename)
   for key, value in trackframes.iteritems():
      changed = False
      for frame in tag.getUserTextFrames():
         if frame.description == key:
            frame.text = value
            changed = True
      if not changed:
         tag.addUserTextFrame(key,value)
   tag.update()
   if preserve_mtime:
      os.utime(filename, (stat.st_atime, stat.st_mtime))
