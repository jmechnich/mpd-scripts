#!/usr/bin/env python3

import os
import shutil
import subprocess
import sys

import eyed3

# preserve file modification times ?
preserve_mtime = True

aacgain = shutil.which("aacgain")
if aacgain is None:
   print("Could not find aacgain executable")
   sys.exit(1)

# only accept mp3 files as m4a do not use id3 tags
filelist = sys.argv[1:]
for f in filelist:
   if not f.endswith('.mp3'):
      print("Use with mp3 files only")
      sys.exit(1)

# aacgain supports mp3 and m4a with AAC-LC (no Apple Lossless / ALAC)
cmd = f"{aacgain} -o -s s -q".split() + filelist
pipe = subprocess.Popen(cmd, stdout=subprocess.PIPE).stdout

# skip first line of output (header)
pipe.readline()

# parse output
trackinfo = []
for line in pipe:
   try:
      filename, _, gain, peak, _, _ = line.decode('utf-8').rstrip().split('\t')
   except ValueError as e:
      print(e)
      print(line.decode('utf-8'))
      sys.exit(1)

   gain = float(gain)
   peak = float(peak)/32768.
   if filename == '"Album"':
      albumframes = {
         u"replaygain_album_gain": u"%.2f dB" % gain,
         u"replaygain_album_peak": u"%.6f"    % peak,
      }
   else:
      trackinfo.append([filename, gain, peak])

# write replay gain frames to files
for entry in trackinfo:
   filename, gain, peak = entry
   trackframes = {
      u"replaygain_track_gain": u"%.2f dB" % gain,
      u"replaygain_track_peak": u"%.6f"    % peak,
   }
   if len(trackinfo) > 1:
      trackframes.update(albumframes)
   mp3file = eyed3.load(filename)
   for k, v in trackframes.items():
      mp3file.tag.user_text_frames.set(text=v, description=k)
   mp3file.tag.save(preserve_file_time=preserve_mtime)
