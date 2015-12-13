#!/bin/bash

set -e

parallel=1
    
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

process_track ()
{
    track="$1"; shift
    cmd="$1"; shift

    if ! [ -e "$track" ]; then
        return
    fi
    
    tr_count=`"$cmd" $@ "$track" |& grep -aic REPLAYGAIN_TRACK`
    al_count=`"$cmd" $@ "$track" |& grep -aic REPLAYGAIN_ALBUM`
    if [ $tr_count -lt 2 ] || [ $al_count -lt 2 ]; then
        if ! "$cmd" $@ "$track" |& grep -q 'track *: 1/1'; then
            echo "$track missing RG info"
            echo $al_count $tr_count
        fi
    fi
}
export -f process_track

process ()
{
    filetype=$1;shift
    cmd="$1"; shift

    ret=`checkprog $cmd`
    if [  x"$ret" = x ]; then
        echo "$cmd not found"
        exit 1
    fi
    
    filelist=tracks_$filetype.txt
    if ! [ -e "$filelist" ]; then
        echo "$filelist not found"
        return
    fi
    echo "Processing `wc -l < $filelist` $filetype track(s)"
    if [ $parallel -eq 1 ]; then
        parallel --no-notice --eta -a "$filelist"  process_track "{}" "$cmd" $@
    else
        while read track; do
            process_track "$track" "$cmd" $@
        done < "$filelist"
    fi
}

process mp3  ffprobe
#process m4a  ffprobe
#process mpc  ffprobe
#process ogg  ffprobe
#process flac metaflac --list

##process mp3  eyeD3
##process flac ffprobe
##process ogg  ogginfo
