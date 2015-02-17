#!/usr/bin/env python

import argparse, atexit, audioscrobbler, mpd, random, socket, urllib

def add_random_track(mpd_instance, artists, args):
    tracks = mpd_instance.find('Artist', random.choice(artists))
    track  = random.choice(tracks)
    if args.verbose:
        print "add_random_track: '%s - %s'" % (
            track['artist'], track['title'])
    mpd_instance.add(track['file'])

def fill_random(mpd_instance, artists, args):
    status = mpd_instance.status()
    pl_length = int(status['playlistlength'])
    song      = int(status.get('song',0))
    remaining = pl_length - song
    add       = args.length - remaining
    if add > 0:
        if args.verbose:
            print "fill_random: adding", add, "random tracks"
        for i in xrange(add):
            add_random_track(mpd_instance,artists,args)
    else:
        if args.verbose:
            print "fill_random: nothing to do"
    
def fill_similar(mpd_instance, artists, args):
    current = mpd_instance.currentsong()
    if not len(current):
        return
    if fill_similar.last == current['artist']:
        return
    fill_similar.last = current['artist']

    if args.verbose:
        print "fill_similar: querying similar artists for '%s'" % \
            current['artist']
    cloud = audioscrobbler.AudioScrobblerQuery(
        artist = urllib.quote_plus(current['artist']))
    similar_cloud = [ str(artist.name).decode('utf-8')
                      for artist in cloud.similar() ]
    if len(similar_cloud) == 0:
        add_random_track(mpd_instance,artists,args)
        return
    
    similar_artists = list(set(similar_cloud).intersection(artists))
    if args.verbose:
        print "fill_similar: %d/%d similar artists found" % (
            len(similar_artists), len(similar_cloud))
    if len(similar_artists) == 0:
        add_random_track(mpd_instance,artists,args)
        return

    add_random_track(mpd_instance,similar_artists,args)

fill_similar.last = ''
    
def main():
    modemap = { 'random':  fill_random,
                'similar': fill_similar
    }
    parser = argparse.ArgumentParser(
        prog='mpd_dynamic',
        description="mpd_dynamic - fill playlist dynamically")
    parser.add_argument(
        'host', type=str, nargs="?", default='localhost',
        help='hostname of MPD server (default: %(default)s)')
    parser.add_argument(
        'port', type=int, nargs="?", default=6600,
        help='port of MPD server (default: %(default)s)')
    parser.add_argument(
        '-l', '--length', type=int, default=20,
        help='number of remaining songs (default: %(default)s)')
    parser.add_argument(
        '-m', '--mode', choices=modemap.keys(), default='random',
        help="operation mode (default: %(default)s)")
    parser.add_argument(
        '-v', '--verbose', help='verbose output', action="store_true")
    args = parser.parse_args()
    
    m = mpd.MPDClient()
    try:
        if args.verbose:
            print "main: connecting to %s:%d" % (args.host,args.port)
        m.connect(args.host, args.port)
        
        def disconnect(mpd_instance, args):
            if args.verbose:
                print "main: disconnecting"
            mpd_instance.disconnect()
        atexit.register(lambda: disconnect(m,args))
        
        artists   = m.list('Artist')
        fill_random(m,artists,args)

        subsystem = []
        while True:
            if 'player' in subsystem:
                modemap[args.mode](m,artists,args)
            subsystem = m.idle()
            
    except socket.error, e:
        if args.verbose:
            print "main:",
        print e
    except KeyboardInterrupt:
        pass
    
if __name__ == "__main__":
    main()
