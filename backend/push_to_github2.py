import paramiko, os

HOST = "121.41.196.62"
USER = "root"
PASS = "barry*1394"

client = paramiko.SSHClient()
client.set_missing_host_key_policy(paramiko.AutoAddPolicy())
client.connect(HOST, username=USER, password=PASS, timeout=10)
sftp = client.open_sftp()

local_repo = r"C:\Users\TRaplash\projects\spendwise"

def mkdir_p(sftp, path):
    parts = path.split("/")
    p = ""
    for part in parts:
        if part:
            p += "/" + part
            try:
                sftp.stat(p)
            except:
                sftp.mkdir(p)

def is_ignored(path):
    for ign in ["venv", "__pycache__", ".pyc", ".git"]:
        if ign in path:
            return True
    return False

# Copy source files only (skip .git)
count = 0
for root, dirs, files in os.walk(local_repo):
    for f in files:
        local = os.path.join(root, f)
        rel = os.path.relpath(local, local_repo)
        if is_ignored(rel):
            continue
        remote = "/tmp/spendwise/" + rel.replace(os.sep, "/")
        mkdir_p(sftp, os.path.dirname(remote))
        try:
            sftp.put(local, remote)
            count += 1
        except Exception as e:
            print(f"  SKIP {rel}: {e}")

sftp.close()
print(f"Copied {count} files to server")

def run(client, cmd, timeout=30):
    i, o, e = client.exec_command(cmd, timeout=timeout, get_pty=True)
    ec = o.channel.recv_exit_status()
    return o.read().decode(), e.read().decode(), ec

# Init git and push via SSH
print("Initializing git and pushing...")
cmds = """
cd /tmp/spendwise
git init
git config user.name "Flash-T"
git config user.email "1938282676@qq.com"
git add -A
git commit -m "feat: project init - SpendWise backend"
git remote add origin git@github.com:Flash-T/spendwise.git
git push -u origin master 2>&1
"""
o, e, rc = run(client, cmds, 30)
print(o)
if e and "fatal" in e.lower():
    print("ERR:", e[:300])
if "done" in o.lower() or "master -> master" in o:
    print("*** PUSH SUCCESSFUL! ***")
elif "repository not found" in o.lower():
    print("*** REPO DOESN'T EXIST - need to create it first ***")
print(f"RC: {rc}")
client.close()
