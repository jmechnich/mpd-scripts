#!/bin/sh

set -e

if [ $# != 1 ]; then
    echo "Usage: make_lists.sh top-directory"
    exit 1
fi

TOPDIR="$1"
LISTDIR=lists
EXTS="ogg flac m4a mp3 mpc"

mkdir -p $LISTDIR

ALLTRACKS=0
for e in $EXTS; do
    if ! [ -e $LISTDIR/tracks_$e.txt ]; then
        echo "Creating $e track list"
        find "$TOPDIR" -type f -name \*.$e > $LISTDIR/tracks_$e.txt
    fi
    N=`wc -l < $LISTDIR/tracks_$e.txt`
    printf "%6d $e tracks found\n" $N
    ALLTRACKS=$(($ALLTRACKS+$N))
    if ! [ -e $LISTDIR/albums_$e.txt ]; then
        echo "Creating $e album list"
        cat $LISTDIR/tracks_$e.txt | rev | cut -d/ -f2- | rev | sort | uniq > $LISTDIR/albums_$e.txt
    fi
done

if ! [ -e $LISTDIR/files.txt ]; then
    echo "Creating list of all files"
    find "$TOPDIR" -type f | sort > $LISTDIR/files.txt
fi
ALLFILES=`wc -l < $LISTDIR/files.txt`
printf "%6d handled music files found ($ALLFILES total)\n" $ALLTRACKS

if [ $ALLFILES -ne $ALLTRACKS ]; then
    echo
    cat `echo $EXTS | sed -r "s,([[:alnum:]]+),$LISTDIR/tracks_\1.txt,g"` | sort | diff $LISTDIR/files.txt -
fi
