#!/usr/bin/env python3
"""Read-only GitHub listing for the fork deep scan (Nov 28 2026).
Uses the laptop's gh login (camhoc) only for GET requests. Writes TSV files into ./out/.
Nothing is posted, starred, forked or commented. Safe to re-run; it overwrites out/.
"""
import json, subprocess, os, sys, time

ROOTS = [
 "willfaust/Madeira","willfaust/FEX","willfaust/wine","willfaust/dxmt","willfaust/madeira-dock",
 "FEX-Emu/FEX","3Shain/dxmt","wine-mirror/wine","ValveSoftware/wine","ValveSoftware/Proton",
 "GameNative/proton-wine","GameNative/FEX","KhronosGroup/MoltenVK","HansKristian-Work/vkd3d-proton",
 "ptitSeb/box64","brunodev85/winlator","metalsharp/MetalSharp-Wine","Droid-Deck/DroidDeck-Proton",
 "playportdev/playport","tylerkaska112/Porthole","Dmage22/FEX-D2","tarikbc/ageofempires-android",
 "doitsujin/dxvk","Joshua-Ashton/d9vk","mesa3d/mesa",
]
PR_REPOS = [
 "willfaust/Madeira","willfaust/FEX","willfaust/wine","willfaust/dxmt","willfaust/madeira-dock",
 "3Shain/dxmt","GameNative/proton-wine","GameNative/FEX","KhronosGroup/MoltenVK",
 "HansKristian-Work/vkd3d-proton","ptitSeb/box64","brunodev85/winlator","metalsharp/MetalSharp-Wine",
 "Droid-Deck/DroidDeck-Proton","playportdev/playport","ValveSoftware/wine","ValveSoftware/Proton",
]
PR_SINCE = "2026-06-01"   # FEX-Emu/FEX PRs: only those updated since this date (FEX has thousands)
MAX_DEPTH = 4
os.makedirs("out", exist_ok=True)

def gh(path):
    for attempt in range(4):
        p = subprocess.run(["gh","api","--paginate",path], capture_output=True, text=True)
        if p.returncode == 0:
            # --paginate concatenates JSON arrays as "][": fix
            txt = p.stdout.strip().replace("]\n[", ",").replace("][", ",")
            return json.loads(txt or "[]")
        if "404" in p.stderr or "Not Found" in p.stderr:
            return None
        time.sleep(10*(attempt+1))
    print("ERR", path, p.stderr[:200], file=sys.stderr); return None

seen=set()
with open("out/forks.tsv","w") as f, open("out/errors.txt","w") as e:
    f.write("root\tdepth\tparent\tfork\tpushed_at\tcreated_at\tforks_count\tstars\tdefault_branch\tarchived\n")
    for root in ROOTS:
        queue=[(root,0)]
        while queue:
            repo,d = queue.pop(0)
            if repo.lower() in seen: continue
            seen.add(repo.lower())
            items = gh(f"repos/{repo}/forks?per_page=100&sort=newest")
            if items is None: e.write(f"{repo}\tunreachable\n"); continue
            for it in items:
                f.write("\t".join(str(x) for x in [root,d+1,repo,it["full_name"],it.get("pushed_at"),it.get("created_at"),it.get("forks_count",0),it.get("stargazers_count",0),it.get("default_branch"),it.get("archived")])+"\n")
                if it.get("forks_count",0)>0 and d+1<MAX_DEPTH: queue.append((it["full_name"],d+1))
            f.flush()
            print(root, repo, len(items), flush=True)

with open("out/prs.tsv","w") as f:
    f.write("repo\tnumber\tstate\tmerged_at\tcreated_at\tupdated_at\tauthor\thead_repo\thead_ref\ttitle\n")
    for r in PR_REPOS + ["FEX-Emu/FEX"]:
        items = gh(f"repos/{r}/pulls?state=all&per_page=100&sort=updated&direction=desc") if r!="FEX-Emu/FEX" else None
        if r=="FEX-Emu/FEX":
            items=[]; page=1
            while True:
                p = subprocess.run(["gh","api",f"repos/{r}/pulls?state=all&per_page=100&sort=updated&direction=desc&page={page}"],capture_output=True,text=True)
                if p.returncode: break
                batch=json.loads(p.stdout or "[]")
                if not batch: break
                items+=batch
                if batch[-1]["updated_at"]<PR_SINCE: break
                page+=1
        for it in items or []:
            hr = (it.get("head") or {}).get("repo") or {}
            f.write("\t".join(str(x).replace("\t"," ").replace("\n"," ") for x in [r,it["number"],it["state"],it.get("merged_at"),it.get("created_at"),it.get("updated_at"),(it.get("user") or {}).get("login"),hr.get("full_name"),(it.get("head") or {}).get("ref"),it.get("title")])+"\n")
        print("prs", r, len(items or []), flush=True)
print("DONE")
