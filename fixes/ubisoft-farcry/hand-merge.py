#!/usr/bin/env python3
# Run from the Madeira source root AFTER apply.sh. Three hand merges for hunks that rejected on 0.2.180
# (context moved) plus the FEX README row. Idempotent-ish: run once.
p='build/ntdll-unix/process_ios.c'
rej=open(p+'.rej').read().split('\n')
add=[l[1:] for l in rej[3:] if l.startswith('+')]
s=open(p).read(); i=s.index('static int sc_browser_cmdline('); j=s.index('\n}\n',i)+3
s=s[:j]+'\n'.join(add[1:] if add[0]=='' else add)+'\n'+s[j:]; open(p,'w').write(s)
p='build/ntdll-unix/virtual_ios.c'; s=open(p).read()
a='        view->protect |= VPROT_X64DATA;\n        if (x64_images++ < 64)'; assert s.count(a)==1
s=s.replace(a,'        view->protect |= VPROT_X64DATA;\n        if (ios_x64_nocopy_dataimp_enabled()) ios_x64_nocopy_note( (uintptr_t)ptr, total_size );   /* [x64-data-imp] */\n        if (x64_images++ < 64)'); open(p,'w').write(s)

# 0005: the gen-config-catalog.py hunk rejected (the PAD_MODE entry differs in 0.2.180): add the xbox360 choice by hand.
p='build/tools/gen-config-catalog.py'; s=open(p).read()
a='("hid", "DirectInput / HID"), ("dualsense"'
assert s.count(a)==1, "PAD_MODE choices moved"
s=s.replace(a,'("xbox360", "XInput + Xbox 360 device"), '+a)
b='dualsense/generic force the identity. Read at session start;'
assert s.count(b)==1
s=s.replace(b,'dualsense/generic force the identity. xbox360: player 1 stays on XInput and is also the HID device Windows lists beside a wired Xbox 360 controller (045E:028E), for games that look for one first (Far Cry 4). Read at session start;')
open(p,'w').write(s)
