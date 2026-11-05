#!/usr/bin/env python3
"""Push the current branch with curl + GitHub Git Data API.

Python urllib to api.github.com gets its TLS reset on this host; curl works.
Flow: blob -> tree -> commit -> ref, asserting every returned SHA matches the
local object, stopping at the first mismatch instead of stacking a wrong commit.
Handles the initial-commit case (no parent).
"""
import base64
import datetime
import json
import os
import subprocess
import sys

REPO = "johnson020202/enjoy-movie-english"
BRANCH = "main"


def sh(*args):
    r = subprocess.run(args, capture_output=True, cwd=os.path.dirname(os.path.abspath(__file__)))
    if r.returncode != 0:
        sys.exit("cmd failed: %s\n%s" % (" ".join(args), r.stderr.decode(errors="replace")))
    return r.stdout.decode()


def gh(method, path, body=None):
    with open("/tmp/.gh_token") as f:
        token = f.read().strip()
    cmd = ["curl", "-sS", "-m", "300", "-X", method,
           "-H", "Authorization: token " + token,
           "-H", "Accept: application/vnd.github+json",
           "-H", "Content-Type: application/json"]
    if body is not None:
        cmd += ["-d", json.dumps(body)]
    cmd.append("https://api.github.com/repos/%s%s" % (REPO, path))
    out = subprocess.run(cmd, capture_output=True).stdout.decode()
    try:
        return json.loads(out)
    except Exception:
        sys.exit("API error on %s %s: %s" % (method, path, out[:800]))


root = os.path.dirname(os.path.abspath(__file__))
head = subprocess.run(["git", "rev-parse", "HEAD"], capture_output=True, cwd=root).stdout.decode().strip()
local_tree = subprocess.run(["git", "rev-parse", "HEAD^{tree}"], capture_output=True, cwd=root).stdout.decode().strip()
parents_raw = subprocess.run(["git", "rev-list", "--parents", "-n", "1", head], capture_output=True, cwd=root).stdout.decode().split()
parent = parents_raw[1] if len(parents_raw) > 1 else None

entries = []
ls = subprocess.run(["git", "ls-tree", "-r", "-z", head], capture_output=True, cwd=root).stdout
for item in ls.split(b"\0"):
    if not item:
        continue
    meta, path_b = item.split(b"\t", 1)
    mode, kind, blob = meta.decode().split()
    path = path_b.decode("utf-8", "surrogateescape")
    if kind == "commit":  # submodule — not expected here
        entries.append({"path": path, "mode": mode, "type": "commit", "sha": blob})
        continue
    content = subprocess.run(["git", "show", "%s:%s" % (head, path)], capture_output=True, cwd=root).stdout
    created = gh("POST", "/git/blobs", {"content": base64.b64encode(content).decode(), "encoding": "base64"})
    if created.get("sha") != blob:
        sys.exit("blob sha mismatch for %s: %s != %s" % (path, created.get("sha"), blob))
    entries.append({"path": path, "mode": mode, "type": "blob", "sha": blob})

print("files: %d" % len(entries))

# Trees have a size limit per request; send in chunks under 100k entries.
tree_payload = {"tree": entries}
if parent:
    parent_tree = subprocess.run(["git", "rev-parse", parent + "^{tree}"], capture_output=True, cwd=root).stdout.decode().strip()
    tree_payload["base_tree"] = parent_tree
tree = gh("POST", "/git/trees", tree_payload)
if tree.get("sha") != local_tree:
    sys.exit("tree mismatch: %s != %s" % (tree.get("sha"), local_tree))
print("tree OK", tree["sha"])

raw = subprocess.run(["git", "cat-file", "commit", head], capture_output=True, cwd=root).stdout.decode()
hdr, body = raw.split("\n\n", 1)


def ident(prefix):
    s = next(l for l in hdr.splitlines() if l.startswith(prefix))[len(prefix):]
    name = s[:s.index(" <")]
    email = s[s.index("<") + 1:s.index(">")]
    ts, tz = s[s.index(">") + 2:].rsplit(" ", 1)
    sign = 1 if tz[0] == "+" else -1
    off = datetime.timedelta(hours=int(tz[1:3]), minutes=int(tz[3:5])) * sign
    dt = datetime.datetime.fromtimestamp(int(ts), datetime.timezone(off))
    return {"name": name, "email": email, "date": dt.isoformat()}


payload = {
    "message": body,
    "tree": tree["sha"],
    "author": ident("author "),
    "committer": ident("committer "),
}
if parent:
    payload["parents"] = [parent]
commit = gh("POST", "/git/commits", payload)
if commit.get("sha") != head:
    sys.exit("commit mismatch: %s != %s" % (commit.get("sha"), head))
print("commit OK", commit["sha"])

existing = gh("GET", "/git/ref/heads/" + BRANCH)
if existing.get("object"):
    ref = gh("PATCH", "/git/refs/heads/" + BRANCH, {"sha": head, "force": False})
else:
    ref = gh("POST", "/git/refs", {"ref": "refs/heads/" + BRANCH, "sha": head})
print("ref now", ref.get("object", {}).get("sha"))
