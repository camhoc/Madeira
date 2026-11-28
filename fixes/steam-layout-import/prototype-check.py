import sys,re
def parse(text):
    toks=re.findall(r'"((?:[^"\\]|\\.)*)"|([{}])|//[^\n]*',text.lstrip('﻿'))
    pos=0
    toks=[(a,b) for a,b in toks if a!='' or b!='' ]
    # note: empty strings "" are dropped; acceptable
    def block():
        nonlocal pos
        items=[]
        while pos<len(toks):
            s,b=toks[pos]
            if b=='}': pos+=1; return items
            if b=='{': pos+=1; continue
            key=s; pos+=1
            if pos<len(toks) and toks[pos][1]=='{':
                pos+=1; items.append((key,block()))
            elif pos<len(toks):
                items.append((key,toks[pos][0])); pos+=1
        return items
    return block()
def get(items,k):
    for a,b in items:
        if a.lower()==k: return b
def vk(name):
    n=name.upper()
    if len(n)==1 and n.isalnum(): return ord(n)
    t={'SPACE':0x20,'RETURN':0x0D,'ENTER':0x0D,'ESCAPE':0x1B,'TAB':0x09,'BACKSPACE':0x08,'DELETE':0x2E,'INSERT':0x2D,'HOME':0x24,'END':0x23,'PAGE_UP':0x21,'PAGE_DOWN':0x22,
     'LEFT_SHIFT':0x10,'RIGHT_SHIFT':0x10,'LEFT_CONTROL':0x11,'RIGHT_CONTROL':0x11,'LEFT_ALT':0x12,'RIGHT_ALT':0x12,'CAPSLOCK':0x14,'CAPS_LOCK':0x14,
     'UP_ARROW':0x26,'DOWN_ARROW':0x28,'LEFT_ARROW':0x25,'RIGHT_ARROW':0x27,
     'COMMA':0xBC,'PERIOD':0xBE,'FORWARD_SLASH':0xBF,'BACK_SLASH':0xDC,'SEMICOLON':0xBA,'SINGLE_QUOTE':0xDE,'LEFT_BRACKET':0xDB,'RIGHT_BRACKET':0xDD,'DASH':0xBD,'EQUALS':0xBB,'BACK_TICK':0xC0}
    if n in t: return t[n]
    m=re.fullmatch(r'F(\d{1,2})',n)
    if m and 1<=int(m.group(1))<=12: return 0x6F+int(m.group(1))
    return None
def action(binding):
    p=binding.split(',')[0].strip().split()
    if len(p)<2: return None
    kind,arg=p[0].lower(),p[1].upper()
    if kind=='key_press':
        v=vk(arg); return ('key',v) if v else None
    if kind=='mouse_button': return {'LEFT':'mouseLeft','RIGHT':'mouseRight','MIDDLE':'mouseMiddle'}.get(arg)
    if kind=='mouse_wheel': return {'SCROLL_UP':'scrollUp','SCROLL_DOWN':'scrollDown'}.get(arg)
def first_binding(inp):
    acts=get(inp,'activators')
    if not acts: return None
    for name in ('full_press','long_press','double_press'):
        for k,v in acts:
            if k.lower()==name and isinstance(v,list):
                b=get(get(v,'bindings') or [],'binding')
                if b: return b
    return None
def convert(text):
    root=dict((k.lower(),v) for k,v in parse(text))['controller_mappings'] if False else None
    tree=parse(text); cm=[v for k,v in tree if k.lower()=='controller_mappings'][0]
    groups={}
    for k,v in cm:
        if k.lower()=='group': groups[get(v,'id')]=v
    presets=[v for k,v in cm if k.lower()=='preset']
    pre=next((p for p in presets if (get(p,'name') or '').lower()=='default'),presets[0] if presets else None)
    gsb=get(pre,'group_source_bindings') or []
    out={};skipped=[]
    def put(name,b,why):
        a=action(b) if b else None
        if a: out[name]=a
        elif b: skipped.append((name,b))
    for gid,src in gsb:
        if not src.lower().endswith(' active') or src.lower().endswith('inactive'): continue
        src=src.split()[0].lower(); g=groups.get(gid)
        if not g: continue
        mode=(get(g,'mode') or '').lower(); inputs=dict((k.lower(),v) for k,v in (get(g,'inputs') or []))
        B=lambda n: first_binding(inputs[n]) if n in inputs else None
        if src=='button_diamond':
            for n,t in (('button_a','A'),('button_b','B'),('button_x','X'),('button_y','Y')): put(t,B(n),mode)
        elif src=='switch':
            for n,t in (('left_bumper','LB'),('right_bumper','RB'),('button_escape','Menu'),('button_menu','View')): put(t,B(n),mode)
        elif src in('left_trigger','right_trigger'):
            t='LT' if src=='left_trigger' else 'RT'
            put(t,B('click') or B('edge'),mode)
        elif src=='dpad':
            for n,t in (('dpad_north','D↑'),('dpad_south','D↓'),('dpad_west','D←'),('dpad_east','D→')): put(t,B(n),mode)
        elif src in('joystick','right_joystick'):
            st='LS' if src=='joystick' else 'RS'
            if mode=='dpad':
                keys=[B(n) for n in ('dpad_north','dpad_east','dpad_south','dpad_west')]
                ks=[action(k) if k else None for k in keys]
                if ks==[('key',0x57),('key',0x44),('key',0x53),('key',0x41)]: out[st]='joystickWASD'
                elif ks==[('key',0x26),('key',0x27),('key',0x28),('key',0x25)]: out[st]='joystickArrows'
                else: skipped.append((st,'custom 4-key stick'))
            elif mode in('joystick_mouse','mouse_joystick') and st=='RS': out['RS']='mouse'
            else: skipped.append((st,'mode '+mode))
            put('L3' if st=='LS' else 'R3',B('click'),mode)
        else: skipped.append((src,'unsupported source (mode %s)'%mode))
    return out,skipped
if __name__=='__main__':
    for f in sys.argv[1:]:
        o,s=convert(open(f,encoding='utf-8').read()); print(f); print(' ',o); print('  skipped:',s)
