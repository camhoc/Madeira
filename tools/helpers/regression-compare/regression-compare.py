#!/usr/bin/env python3
"""Compare a good run folder with a new one (config, app version, key log lines). Read-only."""
import difflib, importlib.util, re, sys
from pathlib import Path

spec = importlib.util.spec_from_file_location('triage', Path(__file__).resolve().parents[1] / 'log-triage/log-triage.py')
triage = importlib.util.module_from_spec(spec)
sys.dont_write_bytecode = True
spec.loader.exec_module(triage)

def configs(d):
    out = []
    for f in sorted(d.rglob('*')):
        if f.suffix.lower() in ('.cfg', '.conf', '.ini', '.json'):
            out += [f'{f.relative_to(d)}: {l.strip()}' for l in f.read_text(errors='replace').splitlines() if l.strip()]
    return out

def logs(d):
    pats = triage.patterns()
    keys, versions = set(), set()
    for f in sorted(d.rglob('*')):
        if f.suffix.lower() not in ('.log', '.txt'):
            continue
        for line in f.read_text(errors='replace').splitlines():
            m = re.search(r'(?:version|build)[ =:]+v?(\d+(?:\.\d+)*)', line, re.I)
            if m:
                versions.add(m[0])
            if any(pats[k].search(line) for k in ('error', 'exit', 'dock') if k in pats):
                keys.add(re.sub(r'0x[0-9a-f]+|\d+', 'N', triage.TIME.sub('', line)).strip()[:140])
    return keys, versions

def main():
    if len(sys.argv) != 3 or not all(Path(p).is_dir() for p in sys.argv[1:]):
        sys.exit('usage: regression-compare.py <good-run-dir> <new-run-dir>')
    good, new = map(Path, sys.argv[1:])
    diff = [l for l in difflib.unified_diff(configs(good), configs(new), n=0, lineterm='')
            if l[:1] in '+-' and l[:3] not in ('+++', '---')]
    print('config changes:', *(diff[:20] or ['  none']), sep='\n')
    gk, gv = logs(good)
    nk, nv = logs(new)
    print(f'version: {", ".join(sorted(gv)) or "?"} -> {", ".join(sorted(nv)) or "?"}')
    print('new key log lines:', *(['  ' + l for l in sorted(nk - gk)[:15]] or ['  none']), sep='\n')
    print('gone key log lines:', *(['  ' + l for l in sorted(gk - nk)[:10]] or ['  none']), sep='\n')

if __name__ == '__main__':
    main()
