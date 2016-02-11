#!/bin/bash

# rg.sh: adds ReplayGain tags to audio files
#        supported formats are mp3, m4a, ogg, mpc and flac
#        requires album list file with name
#        albums_[mp3|m4a|ogg|mpc|flac].txt

# use GNU parallel if set to 1
parallel=1

if [ $# != 1 ]; then
    echo "Usage: rg.sh albumlistfile"
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

process_album ()
{
    filetype="$1"; shift
    album="$1"; shift
    cmd="$@"; shift
    
    #echo "Processing $album with '$cmd *.$filetype'"
    (cd "$album" && $cmd *.$filetype) > /dev/null
}
export -f process_album

process ()
{
    filelist="$1"; shift
    filetype="$1"; shift
    cmd="$1"; shift
    args="$@"; shift

    echo "File:     $filelist"
    echo "Command:  $cmd $args"
    
    real_cmd=`checkprog $cmd`
    if [  x"$real_cmd" = x ]; then
        echo "$cmd not found"
        exit 1
    fi
    
    echo "Processing `wc -l < $filelist` album(s)"
    if [ $parallel -eq 1 ]; then
        parallel --no-notice --eta -a "$filelist"  process_album "$filetype" "{}" $real_cmd $args
    else
        while read album; do
            process_album "$filetype" "$album" $real_cmd $args
        done < "$filelist"
    fi
}

FILETYPE=`basename "$LISTFILE" | sed 's,albums_\([^\.]*\)\.txt,\1,'`
echo "Filetype: $FILETYPE"

case $FILETYPE in
    mp3)
        process "$LISTFILE" "$FILETYPE" mp3gain
        ;;
    m4a)
        process "$LISTFILE" "$FILETYPE" aacgain -p -q
        ;;
    mpc)
        process "$LISTFILE" "$FILETYPE" mpcgain
        ;;
    ogg)
        process "$LISTFILE" "$FILETYPE" vorbisgain -a -f -p -q
        ;;
    flac)
        process "$LISTFILE" "$FILETYPE" metaflac --add-replay-gain --preserve-modtime
        ;;
    *)
        echo "Unhandled filetype"
        exit 1
        ;;
esac
