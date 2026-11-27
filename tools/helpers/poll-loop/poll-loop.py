#!/usr/bin/env python3
"""Print one line only when a fix/* head or a watched download changed; otherwise print nothing."""
import argparse, json, subprocess, sys
from pathlib import Path

def main():
    p = argparse.ArgumentParser(description=__doc__)
    p.add_argument('--repo', default='.', help='git clone whose origin is polled')
    p.add_argument('--state', required=True)
    p.add_argument('--watch', action='append', default=[], help='download file whose size is tracked')
    a = p.parse_args()
    r = subprocess.run(['git', '-C', a.repo, 'ls-remote', 'origin', 'refs/heads/fix/*'],
                       capture_output=True, text=True, timeout=60)
    if r.returncode:
        sys.exit('ls-remote failed: ' + r.stderr.strip())
    now = {ref.removeprefix('refs/heads/'): sha for sha, ref in (l.split('\t') for l in r.stdout.splitlines())}
    for f in a.watch:
        path = Path(f)
        now['file:' + f] = str(path.stat().st_size) if path.exists() else 'missing'
    state = Path(a.state)
    old = json.loads(state.read_text()) if state.exists() else {}
    changed = sorted(k for k in set(old) | set(now) if old.get(k) != now.get(k))
    if changed:
        names = ['chat (fix/laptop-chat)' if k == 'fix/laptop-chat' else k for k in changed]
        print('changed: ' + ', '.join(names))
        state.write_text(json.dumps(now, indent=1))

if __name__ == '__main__':
    main()
