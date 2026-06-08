import paramiko, os, tarfile, io

HOST = "121.41.196.62"
USER = "root"
PASS = "barry*1394"

# Create tar from local source files
buf = io.BytesIO()
local_repo = r"C:\Users\TRaplash\projects\spendwise"
skip_dirs = {"venv", ".venv", "__pycache__", ".git", ".idea", ".vscode", "node_modules"}
skip_files = {
    "backend/deploy_hermes.py", "backend/upload_to_server.py",
    "backend/create_repo.py", "backend/create_repo2.py",
    "backend/push_to_github.py", "backend/push_to_github2.py",
    "backend/repo_data.json",
}

with tarfile.open(fileobj=buf, mode="w:gz") as tar:
    for root, dirs, files in os.walk(local_repo):
        # Prune skip directories
        dirs[:] = [d for d in dirs if d not in skip_dirs]
        for f in files:
            p = os.path.join(root, f)
            rel = os.path.relpath(p, local_repo).replace(os.sep, "/")
            if rel in skip_files or rel.endswith((".pyc", ".pyo")):
                continue
            try:
                if os.path.getsize(p) > 50000:
                    continue
            except OSError:
                continue
            tar.add(p, arcname=rel)
buf.seek(0)

print(f"Tar size: {len(buf.getvalue())} bytes")

client = paramiko.SSHClient()
client.set_missing_host_key_policy(paramiko.AutoAddPolicy())
client.connect(HOST, username=USER, password=PASS, timeout=10)

# Transfer and push
stdin, stdout, stderr = client.exec_command(
    "rm -rf /tmp/spendwise && mkdir /tmp/spendwise && cd /tmp/spendwise && tar xzf -",
    timeout=30
)
stdin.write(buf.read())
stdin.flush()
stdin.channel.shutdown_write()
ec = stdout.channel.recv_exit_status()
print(f"Tar extract: {ec}")

# Init git and push
stdin, stdout, stderr = client.exec_command(
    'cd /tmp/spendwise && git init && git config user.name "Flash-T" && '
    'git config user.email "1938282676@qq.com" && git add -A && '
    'git commit -m "feat: SpendWise backend - initial commit" && '
    'git remote add origin git@github.com:Flash-T/spendwise.git && '
    'git push -f origin master 2>&1 | tail -5',
    timeout=30, get_pty=True
)
print(stdout.read().decode())
err = stderr.read().decode()
if err:
    print("ERR:", err[:200])
client.close()
