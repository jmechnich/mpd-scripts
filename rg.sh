#!/bin/bash

# rg.sh: adds ReplayGain info to audio files
#        supported formats are mp3, m4a, ogg, mpc and flac
#        requires album list files in current working directory
#        (albums_[mp3|m4a|ogg|mpc|flac].txt)

set -e

checkprog ()
{
    if which $1 > /dev/null 2>&1; then
        echo $1
    elif [ -e $1 ]; then
        echo "`pwd`/$1"
    else
        echo ""
    fi
}

process_album ()
{
    filetype="$1"; shift
    album="$1"; shift
    cmd="$1"; shift
    
    #echo "Processing $album"
    (cd "$album" && "$cmd" $@ *.$filetype) > /dev/null
}
export -f process_album

process ()
{
    filetype=$1;shift
    cmd="$1"; shift

    filelist=albums_$filetype.txt
    if ! [ -e "$filelist" ]; then
        return
    fi
    echo "Processing `wc -l < $filelist` $filetype album(s)"
    #while read album; do
    #    process_album "$filetype" "$album" "$cmd" $@
    #done < "$filelist"
    parallel --no-notice --eta -a "$filelist"  process_album "$filetype" "{}" "$cmd" $@
}

AACGAIN=`checkprog aacgain`
if [ x"$AACGAIN" = x ]; then
    echo "aacgain not found"
    exit 1
fi
VORBISGAIN=`checkprog vorbisgain`
if [ x"$VORBISGAIN" = x ]; then
    echo "vorbisgain not found"
    exit 1
fi
METAFLAC=`checkprog metaflac`
if [ x"$METAFLAC" = x ]; then
    echo "metaflac not found"
    exit 1
fi
MP3GAIN=`checkprog mp3gain.py`
if [ x"$MP3GAIN" = x ]; then
    echo "mp3gain.py not found"
    exit 1
fi
MPCGAIN=`checkprog mpcgain`
if [ x"$MPCGAIN" = x ]; then
    echo "mpcgain not found"
    exit 1
fi

#process mpc  $MPCGAIN
#process m4a  $AACGAIN -p -q
#process ogg  $VORBISGAIN -a -f -p -q
#process flac $METAFLAC --add-replay-gain --preserve-modtime
process mp3  $MP3GAIN
