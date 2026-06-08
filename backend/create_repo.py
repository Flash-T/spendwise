import subprocess, json

token = "ghp_Rb...pydU"

# Create repo
data = json.dumps({"name": "spendwise", "description": "SpendWise - AI 消费决策助手", "private": False})

cmd = [
    "curl", "-s", "-x", "http://127.0.0.1:10793",
    "-H", f"Authorization: Bearer {token}",
    "-H", "Accept: application/vnd.github+json",
    "-d", data,
    "https://api.github.com/user/repos",
    "-w", "\nHTTP: %{http_code}"
]

result = subprocess.run(cmd, capture_output=True, text=True, timeout=20)
print(result.stdout)

if result.returncode == 0 and '"name": "spendwise"' in result.stdout:
    print("\n=== REPO CREATED! ===")
    
    # Now push code
    import os
    os.chdir(r"C:\Users\TRaplash\projects\spendwise")
    
    remote_url = f"https://Flash-T:{token}@github.com/Flash-T/spendwise.git"
    subprocess.run(["git", "remote", "remove", "origin"], capture_output=True)
    subprocess.run(["git", "remote", "add", "origin", remote_url], capture_output=True)
    
    push = subprocess.run(
        ["git", "-c", "http.proxy=http://127.0.0.1:10793", "push", "-u", "origin", "master"],
        capture_output=True, text=True, timeout=30
    )
    print(push.stdout)
    if push.stderr:
        print("STDERR:", push.stderr)
else:
    print("Repo creation may have failed, trying git push directly...")
    import os
    os.chdir(r"C:\Users\TRaplash\projects\spendwise")
    
    remote_url = f"https://Flash-T:{token}@github.com/Flash-T/spendwise.git"
    subprocess.run(["git", "remote", "remove", "origin"], capture_output=True)
    subprocess.run(["git", "remote", "add", "origin", remote_url], capture_output=True)
    
    # Git push might work and auto-create the repo
    push = subprocess.run(
        ["git", "-c", "http.proxy=http://127.0.0.1:10793", "push", "-u", "origin", "master"],
        capture_output=True, text=True, timeout=30
    )
    print(push.stdout)
    if push.stderr:
        print("STDERR:", push.stderr)
