## mpd-scripts

A collection of scripts related to the Music Player Daemon.

### Main contents

- mpd_dynamic: add random or similar songs to the current playlist dynamically (similar to a feature found in Amarok 1.4 or Clementine)
- m4a2flac: mass-convert ALAC to FLAC files using ffmpeg
- mp3gain: add ReplayGain tags to mp3 files

### Additional helper scripts

See `scripts` directory:

- check_rg.sh: check for ReplayGain tags in audio files
- make_lists.sh: create lists of supported audio files found in given directories
- rg.sh: add ReplayGain tags to mp3/m4a/ogg/mpc/flac files

### Dependencies

- python3-pylast for retrieval of similar artists from last.fm
