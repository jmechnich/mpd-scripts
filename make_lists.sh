#!/bin/sh

set -e

if [ $# != 1 ]; then
    echo "Usage: make_lists.sh top-directory"
    exit 1
fi

TOPDIR="$1"
EXTS="ogg flac m4a mp3 mpc"

ALLTRACKS=0
for e in $EXTS; do
    if ! [ -e tracks_$e.txt ]; then
        echo "Creating $e track list"
        find "$TOPDIR" -type f -name \*.$e > tracks_$e.txt
    fi
    N=`wc -l < tracks_$e.txt`
    printf "%6d $e tracks found\n" $N
    ALLTRACKS=$(($ALLTRACKS+$N))
    if ! [ -e albums_$e.txt ]; then
        echo "Creating $e album list"
        cat tracks_$e.txt | rev | cut -d/ -f2- | rev | sort | uniq > albums_$e.txt
    fi
done

if ! [ -e files.txt ]; then
    echo "Creating list of all files"
    find "$TOPDIR" -type f | sort > files.txt
fi
ALLFILES=`wc -l < files.txt`
printf "%6d handled music files found ($ALLFILES total)\n" $ALLTRACKS

if [ $ALLFILES -ne $ALLTRACKS ]; then
    echo
    cat `echo $EXTS | sed -r 's,([[:alnum:]]+),tracks_\1.txt,g'` | sort | diff files.txt -
fi
