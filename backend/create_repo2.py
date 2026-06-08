#!/usr/bin/env python3
"""Create GitHub repo and push SpendWise code"""
import subprocess, json, os

TOKEN = "ghp_Rb...pydU"
REPO = "spendwise"
OWNER = "Flash-T"
PROXY = "http://127.0.0.1:10793"

def curl(*args, timeout=20):
    cmd = ["curl", "-s", "-x", PROXY] + list(args)
    r = subprocess.run(cmd, capture_output=True, text=True, timeout=timeout)
    return r.stdout, r.stderr

# 1. Create repo
print("Creating repo...")
data = json.dumps({"name": REPO, "description": "SpendWise - AI消费决策助手", "private": False})
out, err = curl(
    "-H", f"Authorization: Bearer ***-H", "Accept: application/vnd.github+json",
    "-d", data,
    f"https://api.github.com/user/repos"
)
print("Create:", out[:300])

if "Bad credentials" in out or "Problems" in out:
    print("Repo may already exist, trying push directly...")

# 2. Push code via HTTPS
os.chdir(r"C:\Users\TRaplash\projects\spendwise")
remote = f"https://{OWNER}:{TOKEN}@github.com/{OWNER}/{REPO}.git"

# Set remote
subprocess.run(["git", "remote", "remove", "origin"], capture_output=True)
subprocess.run(["git", "remote", "add", "origin", remote], capture_output=True)

# Push
env = os.environ.copy()
env["GIT_TERMINAL_PROMPT"] = "0"
env["http_proxy"] = PROXY
env["https_proxy"] = PROXY

push = subprocess.run(
    ["git", "push", "-u", "origin", "master"],
    capture_output=True, text=True, timeout=30, env=env
)
print("\nPush stdout:", push.stdout)
print("Push stderr:", push.stderr[:300] if push.stderr else "")
print("Push RC:", push.returncode)
