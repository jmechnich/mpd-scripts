#!/bin/bash

# checkrg.sh: checks audio files for ReplayGain tags
#             supported formats are mp3, m4a, ogg, mpc and flac
#             requires track list file with name
#             tracks_[mp3|m4a|ogg|mpc|flac].txt

# use GNU parallel if set to 1
parallel=1
    
if [ $# != 1 ]; then
    echo "Usage: check_rg.sh tracklistfile"
    exit 1
fi

LISTFILE="$1"
shift
if ! [ -e "$LISTFILE" ]; then
    echo "$LISTFILE not found"
    exit 1
fi

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
    cmd="$@"; shift

    if ! [ -e "$track" ]; then
        echo "Track '$track' does not exist"
        return
    fi
    
    tr_count=`$cmd "$track" |& grep -aic REPLAYGAIN_TRACK`
    al_count=`$cmd "$track" |& grep -aic REPLAYGAIN_ALBUM`
    if [ $tr_count -lt 2 ] || [ $al_count -lt 2 ]; then
        if ! $cmd "$track" |& grep -q 'track *: 1/1'; then
            echo "$track missing RG info: a $al_count t $tr_count"
        fi
    fi
}
export -f process_track

process ()
{
    filelist="$1";shift
    cmd="$1"; shift
    args="$@"; shift

    echo "File:     $filelist"
    echo "Command:  $cmd $args"
    
    real_cmd=`checkprog $cmd`
    if [  x"$real_cmd" = x ]; then
        echo "$cmd not found"
        exit 1
    fi
    
    echo "Processing `wc -l < $filelist` track(s)"
    if [ $parallel -eq 1 ]; then
        parallel --no-notice --eta -a "$filelist"  process_track "{}" $real_cmd $args
    else
        while read track; do
            process_track "$track" $real_cmd $args
        done < "$filelist"
    fi
}

FILETYPE=`basename "$LISTFILE" | sed 's,tracks_\([^\.]*\)\.txt,\1,'`
echo "Filetype: $FILETYPE"

case $FILETYPE in
    mp3)
        process "$LISTFILE"  ffprobe
        #process mp3  eyeD3
        ;;
    m4a)
        process "$LISTFILE" ffprobe
        ;;
    mpc)
        process "$LISTFILE" ffprobe
        ;;
    ogg)
        process "$LISTFILE" ffprobe
        #process ogg  ogginfo
        ;;
    flac)
        process "$LISTFILE" metaflac --list --block-type VORBIS_COMMENT
        #process flac ffprobe
        ;;
    *)
        echo "Unhandled filetype"
        exit 1
        ;;
esac
