#!/usr/bin/env python3
"""Read-only GitLab/Codeberg listing for the fork deep scan (Nov 28 2026). Anonymous GETs only.
Writes out/wine-mrs.tsv, out/mesa-mrs.tsv, out/codeberg.tsv, out/gitlab-search.tsv. Also saves the
diff of each Wine MR that is open or closed-unmerged and touches arm64ec/wow64/ntdll/loader/
virtual/signal (out/wine-mr-diffs/<iid>.diff) and each Mesa MR mentioning kosmickrisp/kk/
honeykrisp (out/mesa-mr-diffs/<iid>.diff)."""
import json, os, urllib.request, urllib.parse, time
os.makedirs("out/wine-mr-diffs", exist_ok=True); os.makedirs("out/mesa-mr-diffs", exist_ok=True)
def get(url):
    for a in range(4):
        try:
            with urllib.request.urlopen(urllib.request.Request(url, headers={"User-Agent":"fork-scan"}), timeout=60) as r:
                return json.loads(r.read().decode()), r.headers
        except Exception as e:
            err=e; time.sleep(5*(a+1))
    print("ERR", url, err); return None, {}
def allpages(base):
    out=[]; page=1
    while True:
        data,h = get(f"{base}&per_page=100&page={page}")
        if not data: break
        out+=data
        if not h.get("X-Next-Page"): break
        page=int(h["X-Next-Page"])
    return out
def dump(host, proj, fn, since, diffdir, want):
    mrs = allpages(f"https://{host}/api/v4/projects/{urllib.parse.quote(proj,safe='')}/merge_requests?state=all&updated_after={since}&order_by=updated_at")
    with open(fn,"w") as f:
        f.write("iid\tstate\tmerged_at\tupdated_at\tauthor\tlabels\ttitle\turl\n")
        for m in mrs:
            f.write("\t".join(str(x).replace("\t"," ").replace("\n"," ") for x in [m["iid"],m["state"],m.get("merged_at"),m["updated_at"],(m.get("author") or {}).get("username"),",".join(m.get("labels") or []),m["title"],m["web_url"]])+"\n")
    for m in mrs:
        text=(m["title"]+" "+(m.get("description") or "")).lower()
        if m["state"]!="merged" and any(w in text for w in want) or (m["state"]=="merged" and any(w in text for w in want) and m["updated_at"]>"2026-11-01"):
            data,_ = get(f"https://{host}/api/v4/projects/{urllib.parse.quote(proj,safe='')}/merge_requests/{m['iid']}/changes")
            if data:
                with open(f"{diffdir}/{m['iid']}.diff","w") as f:
                    f.write(f"# {m['title']}\n# {m['web_url']} state={m['state']}\n# {(m.get('description') or '')[:2000]}\n")
                    for c in data.get("changes",[]): f.write(f"--- {c['old_path']}\n+++ {c['new_path']}\n{c['diff']}\n")
    print(proj, len(mrs))
dump("gitlab.winehq.org","wine/wine","out/wine-mrs.tsv","2026-05-01T00:00:00Z","out/wine-mr-diffs",
     ["arm64ec","wow64","aarch64","arm64","ntdll","loader","virtual","signal","exception","macos","mac ","xstate","avx","fex","d3d12","dxgi","winemac","steam","anti","jit","tls"])
dump("gitlab.freedesktop.org","mesa/mesa","out/mesa-mrs.tsv","2026-07-01T00:00:00Z","out/mesa-mr-diffs",
     ["kosmickrisp","kk:","kk/","honeykrisp","hk:","asahi","metal","agx","64-bit atomic","int64 atomic"])
# GitLab-hosted forks / projects
with open("out/gitlab-search.tsv","w") as f:
    for host in ["gitlab.com","gitlab.winehq.org","gitlab.freedesktop.org"]:
        for q in ["madeira","FEX","dxmt","arm64ec","wine ios","kosmickrisp","winlator","proton arm64"]:
            data,_=get(f"https://{host}/api/v4/projects?search={urllib.parse.quote(q)}&per_page=100&order_by=last_activity_at")
            for p in data or []:
                f.write(f"{host}\t{q}\t{p.get('path_with_namespace')}\t{p.get('last_activity_at')}\t{(p.get('forked_from_project') or {}).get('path_with_namespace','')}\t{p.get('web_url')}\n")
with open("out/codeberg.tsv","w") as f:
    for q in ["madeira","FEX","dxmt","arm64ec","wine","winlator","proton","box64","moltenvk","kosmickrisp"]:
        data,_=get(f"https://codeberg.org/api/v1/repos/search?q={urllib.parse.quote(q)}&limit=50&sort=updated")
        for p in (data or {}).get("data",[]):
            f.write(f"{q}\t{p.get('full_name')}\t{p.get('updated_at')}\t{p.get('fork')}\t{(p.get('parent') or {}).get('full_name','')}\t{p.get('html_url')}\n")
print("DONE")
