#!/usr/bin/env pypenv
# -*- Mode: Python; tab-width: 4; py-indent-offset: 4; -*-

"""
Locate tdt tanks associated with
"""

import sys, types, string
from Numeric import *
from pype import *
from events import *
from pypedata import *

showall = 0
if sys.argv[1:] == '-all':
    showall = 1;
    sys.argv = sys.argv[2:]


for f in sys.argv[1:]:
    pf = PypeFile(f, filter=None)
    n = 1
    while 1:
        d = pf.nth(n)
        if not d: break
        if d is None:
            sys.stderr.write("Can't read %s\n" % (f,))
        else:
            if not d.params.has_key('tdt_tank'):
                print f, 'no associated tank'
                break
            elif not showall:
                print f
                print 'server:', d.params['tdt_server']
                print   'tank:', d.params['tdt_tank']
                print  'block:', d.params['tdt_block']
                print   'tnum:', int(d.params['tdt_tnum'])
                break
            else:
                # locate each trial in the tank
                d.compute()
                start = find_events(d.events, START)
                stop = find_events(d.events, STOP)
                et = stop[0] - start[0]
                print int(d.params['tdt_tnum']), \
                      d.params['tdt_block'], et/1000.0,f
        n = n + 1
    pf.close()
