#!/usr/bin/env python3
# storage-files-link (Nov 27 2026): source checks only.
from pathlib import Path
import sys
src = (Path(__file__).resolve().parents[2] / 'app' / 'Madeira' / 'StorageManager.swift').read_text(encoding='utf-8')
failed = False
def check(ok, what):
    global failed
    print(('PASS: ' if ok else 'FAIL: ') + what); failed |= not ok
check('MADEIRA_STORAGE_FILES_LINK' in src, 'off switch')
check('"shareddocuments://"' in src, 'opens Files')
check('hasPrefix("external/")' in src, 'no Files link for external drives')
check('!tappable(row)' in src, 'a row with nothing to do is not a button')
check('Show in Files' in src and 'Copy Files path' in src, 'long press: show in Files and copy path')
check('else if filesURL(row) != nil { openInFiles(row) }' in src, 'delete-first rows keep their tap')
check('MADEIRA_STORAGE_TRASH_ROWS' in src and 'clear-files-trash' in src and 'clear-wine-trash' in src, 'trash rows with their own switch')
check('hasPrefix(".")' in src, 'hidden folders get no Files link')
print('check-storage-files-link: ' + ('FAIL' if failed else 'OK')); sys.exit(1 if failed else 0)
