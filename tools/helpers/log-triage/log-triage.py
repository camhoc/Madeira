#!/usr/bin/env python3
"""Summarise a Madeira or game log in at most about 40 lines. Read-only, deterministic."""
import re, sys
from collections import OrderedDict
from pathlib import Path

def patterns():
    out = {}
    for line in (Path(__file__).with_name('patterns.tsv')).read_text().splitlines():
        if line and not line.startswith('#'):
            kind, rx = line.split('\t', 1)
            out[kind] = re.compile(rx, re.I)
    return out

TIME = re.compile(r'\b(\d\d):(\d\d):(\d\d)(?:\.\d+)?\b')

def short(n, line):
    return f'  {n}: {line.strip()[:140]}'

def main():
    if len(sys.argv) != 2:
        sys.exit('usage: log-triage.py <logfile>')
    pats = patterns()
    hits = {k: [] for k in pats}
    first = last = None
    total = 0
    with open(sys.argv[1], errors='replace') as f:
        for total, line in enumerate(f, 1):
            m = TIME.search(line)
            if m:
                t = int(m[1]) * 3600 + int(m[2]) * 60 + int(m[3])
                first = t if first is None else first
                last = t
            for kind, rx in pats.items():
                if rx.search(line):
                    hits[kind].append((total, line))
    length = f'{(last - first) % 86400} s' if first is not None else 'unknown (no timestamps)'
    print(f'lines: {total}   session length: {length}')
    print('counts: ' + '  '.join(f'{k}={len(v)}' for k, v in hits.items()))
    err = hits.get('error', [])
    if err:
        print('first error:', short(*err[0]), 'last error:', short(*err[-1]), sep='\n')
        seen = OrderedDict()
        for n, line in err:
            key = re.sub(r'0x[0-9a-f]+|\d+', 'N', TIME.sub('', line)).strip()
            seen.setdefault(key, [0, n, line])[0] += 1
        print('top errors:')
        for count, n, line in sorted(seen.values(), key=lambda v: (-v[0], v[1]))[:8]:
            print(f'  x{count}' + short(n, line))
    for kind, keep in (('exit', 5), ('dock', 6), ('present', 4)):
        if hits.get(kind):
            print(f'{kind} (last {keep}):')
            for n, line in hits[kind][-keep:]:
                print(short(n, line))

if __name__ == '__main__':
    main()
