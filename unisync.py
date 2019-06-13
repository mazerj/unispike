#!/usr/bin/env python
# -*- Mode: Python; tab-width: 4; py-indent-offset: 4; -*-

"""
Given a list of pypefiles on the command line, use dates etc
to generate a complete set of up to date .p2m and .uni files.
"""

import sys, os, stat, string

def newer(a, b):
    """Is 'a' newer than 'b'?"""
    a = os.stat(a)
    b = os.stat(b)
    return (a[stat.ST_MTIME] > b[stat.ST_MTIME])

def exists(a):
    try:
        os.stat(a)
        return 1
    except OSError:
        return 0

def ispypefile(a):
    try:
        return open(a).read(2) == '<<'
    except:
        return 0

def main(argv):
    p2mlist = []
    unilist = []
    
    for pyfile in argv[1:]:
        if not exists(pyfile) or not ispypefile(pyfile):
            # skip anything that's not a pypefile or missing
            continue

        p2mfile = pyfile + '.p2m'
        if len(os.path.dirname(pyfile)) > 0:
            unifile = os.path.dirname(pyfile) + \
                      '/.' + os.path.basename(pyfile) + '.uni'
        else:
            unifile = '.' + os.path.basename(pyfile) + '.uni'

        if not exists(p2mfile) or newer(pyfile, p2mfile):
            print 'p2m %s' % pyfile
            p2mlist.append(pyfile)
        if not exists(unifile) or newer(p2mfile, unifile):
            if exists(unifile):
                # force complete regeneration of unifile
                os.system('/bin/rm %s' % unifile)
            print 'p2muni %s' % p2mfile
            unilist.append(p2mfile)

    if len(p2mlist):
        os.system('p2m %s' % string.join(p2mlist, ' '))
    if len(unilist):
        os.system('p2muni %s' % string.join(unilist, ' '))
        

if __name__ == '__main__':
    main(sys.argv)
