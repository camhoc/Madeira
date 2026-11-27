#!/usr/bin/env python3
"""Run tests/host/*.py that need no Swift; print only NEW failures and a pass count."""
import argparse, re, subprocess, sys
from concurrent.futures import ThreadPoolExecutor
from pathlib import Path

HERE = Path(__file__).resolve().parent

def run(path, tree, timeout):
    try:
        r = subprocess.run([sys.executable, str(path)], cwd=tree, capture_output=True, timeout=timeout)
        return path.name, r.returncode == 0
    except subprocess.TimeoutExpired:
        return path.name, False

def main():
    p = argparse.ArgumentParser(description=__doc__)
    p.add_argument('tree', help='source tree (use a scratch copy)')
    p.add_argument('--baseline', default=str(HERE / 'known-failures.txt'))
    p.add_argument('--write-baseline', action='store_true')
    p.add_argument('--jobs', type=int, default=4)
    p.add_argument('--timeout', type=int, default=120)
    a = p.parse_args()
    tree = Path(a.tree).resolve()
    tests = [t for t in sorted((tree / 'tests/host').glob('*.py'))
             if not re.search(r'swiftc|[\'"]swift[\'"]', t.read_text(errors='replace'))]
    if not tests:
        sys.exit('no tests found')
    with ThreadPoolExecutor(a.jobs) as pool:
        results = list(pool.map(lambda t: run(t, tree, a.timeout), tests))
    failed = {n for n, ok in results if not ok}
    base = Path(a.baseline)
    if a.write_baseline:
        base.write_text(''.join(n + '\n' for n in sorted(failed)))
    known = set(base.read_text().split()) if base.exists() else set()
    for n in sorted(failed - known):
        print('NEW FAIL', n)
    print(f'{len(tests) - len(failed)}/{len(tests)} passed, {len(failed & known)} known failures, {len(failed - known)} new')
    sys.exit(1 if failed - known else 0)

if __name__ == '__main__':
    main()
