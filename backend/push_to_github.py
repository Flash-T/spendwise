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

def put_recursive(sftp, local_dir, remote_base):
    for root, dirs, files in os.walk(local_dir):
        for f in files:
            local = os.path.join(root, f)
            rel = os.path.relpath(local, local_repo)
            remote = remote_base + "/" + rel.replace(os.sep, "/")
            mkdir_p(sftp, os.path.dirname(remote))
            sftp.put(local, remote)

# Copy everything
mkdir_p(sftp, "/tmp/spendwise")
put_recursive(sftp, os.path.join(local_repo, ".git"), "/tmp/spendwise")
put_recursive(sftp, local_repo, "/tmp/spendwise")
sftp.close()

print("Files copied to server")

def run(client, cmd, timeout=30):
    i, o, e = client.exec_command(cmd, timeout=timeout, get_pty=True)
    ec = o.channel.recv_exit_status()
    return o.read().decode(), e.read().decode(), ec

# Add remote and push via SSH
print("Pushing to GitHub...")
cmds = """
cd /tmp/spendwise
git remote remove origin 2>/dev/null || true
git remote add origin git@github.com:Flash-T/spendwise.git
git push -u origin master 2>&1
"""
o, e, rc = run(client, cmds, 30)
print(o)
if e:
    print("ERR:", e[:300])
print(f"RC: {rc}")
client.close()
