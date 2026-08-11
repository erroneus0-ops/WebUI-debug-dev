# Setting up a scoped GitHub machine account for Claude

A repeatable procedure for giving Claude push/PR/workflow access to exactly
one repo, without ever pasting a personal token and without granting
account-wide access. Developed and tested end-to-end against
`erroneus0-ops/WebUI-debug-dev` on 2026-08-11. Written so either Daniel or a
fresh Claude session (in a different conversation, working on a different
repo) can follow it cold.

**Why this exists, in one sentence:** a dedicated "machine account"
(GitHub's own term for this — see
[docs](https://docs.github.com/en/get-started/learning-about-github/types-of-github-accounts))
that's only ever been added as a collaborator to one repo is automatically
as narrow as it needs to be, regardless of how broad the login grant looks —
because the account itself has nothing else to reach.

---

## Part A — Daniel's steps (one-time, per new repo/project)

1. Log into your email provider's alias/forwarding tool (for Daniel:
   `networksolutions.com/my-account/email/standard-email`, "Standard
   Email"). Add a new forwarding address with a username that names its
   purpose (e.g. `webuidebug@...`, `cocotoolsbot@...`) on whichever domain
   you use, forwarding to your real inbox. No new mailbox needed — a plain
   alias is enough.

2. In a **private/incognito browser window** (important — keeps this
   session from colliding with your main GitHub login), go to
   `github.com/signup` and create a new account using that alias address.
   GitHub emails a verification code to the alias, which forwards to your
   real inbox; paste the code back into the signup flow to confirm.

3. Pick a plain, purpose-naming username (`WebUIdebug` worked well — legible
   at a glance in commit history and collaborator lists, no cuteness).

4. On the repo you want Claude working in: **Settings → Collaborators**
   (personal repos: this may show as "Collaborators and teams" depending on
   GitHub's current UI) **→ Add people**. Search by the new account's
   username. **Note: personal repos have no role picker** — there's a
   single collaborator tier (effectively Write: push, PRs, manage existing
   workflow runs), not the Read/Triage/Write/Maintain/Admin dropdown you'd
   see on an organization repo. Admin-level actions (repo settings, deleting
   the repo, managing other collaborators) stay owner-only regardless — you
   don't get to choose that, and you don't need to.

5. In the **same private window** (logged in as the new account), accept
   the invitation.

6. Tell Claude the account is ready. Everything past this point is Claude's
   half — Claude logs the account in itself and does not need you to create
   or paste any token.

---

## Part B — Claude's steps (the actual login)

### B.0 — Why not just run `gh auth login` directly

`gh auth login`'s normal interactive flow starts a background process that
prints a one-time code, then polls GitHub until the human completes it in a
browser. **This does not survive across separate tool calls in at least
some Claude sandbox environments** — confirmed directly this session:
`nohup ... &`, `disown`, all the standard detachment tricks, still resulted
in the process being gone (verified via `ps aux`) by the next tool call,
even seconds later. Don't rely on it. Symptom if you hit this: you post a
code, the human enters it, `gh auth status` still says not logged in, and
the background process is simply gone with no error.

The fix is to stop depending on any process staying alive at all, and drive
GitHub's OAuth **Device Flow** directly via two independent, stateless HTTP
calls — nothing needs to survive in between, so it doesn't matter how much
real time passes between them.

### B.1 — Request a device code

```bash
mkdir -p /home/claude/session && cd /home/claude/session
curl -s -X POST https://github.com/login/device/code \
  -H "Accept: application/json" \
  -d "client_id=178c6fc778ccc68e1d6a&scope=repo+read:org" > device_flow.json
cat device_flow.json | python3 -m json.tool
```

`178c6fc778ccc68e1d6a` is `gh` CLI's own public, first-party OAuth client ID
— confirmed directly from real GitHub CLI bug reports showing the literal
request (e.g. `cli/cli` issues #983, #980, #12953, #13433 on github.com).
It's meant to be embedded in an open-source CLI binary, so it's not a
secret; using it doesn't require registering your own OAuth App.

**On scope:** `repo` alone is enough for git push/pull and most API calls.
Add `read:org` specifically because `gh auth login --with-token` refuses to
accept a token missing it (it validates for its own internal use, even on
an account with no organizations — harmless to include, costs nothing
real). Do **not** add `workflow` scope by default — see B.5.

This returns `device_code` (keep secret-ish, save to disk, never print),
`user_code` (safe to post in chat — meaningless without a live device-flow
session, expires in ~15 min), `verification_uri`, `expires_in` (seconds),
`interval`.

### B.2 — Hand the human the code

Post `user_code` and `verification_uri` in chat. Tell them: **use the same
private window that's logged into the machine account**, not their main
one. No urgency framing needed — the 15-minute window is generous, and
nothing needs to stay running while they go do it.

### B.3 — Redeem it (separate tool call, whenever they say done)

```bash
cd /home/claude/session
DEVICE_CODE=$(python3 -c "import json; print(json.load(open('device_flow.json'))['device_code'])")
curl -s -X POST https://github.com/login/oauth/access_token \
  -H "Accept: application/json" \
  -d "client_id=178c6fc778ccc68e1d6a&device_code=${DEVICE_CODE}&grant_type=urn:ietf:params:oauth:grant-type:device_code" \
  > token_response.json

# Never print the raw token. Redact before displaying anything.
python3 -c "
import json
d = json.load(open('token_response.json'))
safe = {k: (v if k != 'access_token' else '[REDACTED, length ' + str(len(v)) + ']') for k, v in d.items()}
print(json.dumps(safe, indent=2))
"
```

If they haven't completed it yet, this returns
`{"error": "authorization_pending", ...}` — not a failure, just means
check back after they confirm. On success, extract and save the token,
then delete the intermediate files:

```bash
python3 -c "
import json
d = json.load(open('token_response.json'))
open('gh_oauth_token.txt', 'w').write(d['access_token'])
"
chmod 600 gh_oauth_token.txt
rm -f token_response.json device_flow.json
```

### B.4 — Verify before trusting it (don't skip this)

```bash
curl -s -H "Authorization: Bearer $(cat gh_oauth_token.txt)" \
  -H "Accept: application/vnd.github+json" https://api.github.com/user
# confirm .login is the machine account, NOT the human's main account

curl -s -H "Authorization: Bearer $(cat gh_oauth_token.txt)" \
  -H "Accept: application/vnd.github+json" "https://api.github.com/user/repos?per_page=10"
# confirm exactly one repo appears, with permissions.push == true
# and permissions.admin == false
```

Then wire it into `gh` itself and the local git credential helper, so
plain `git push`/`pull` work without embedding tokens in URLs:

```bash
cat gh_oauth_token.txt | gh auth login --hostname github.com --git-protocol https --with-token
gh auth setup-git
gh auth status   # sanity check
gh repo view <owner>/<repo> --json name,viewerPermission   # real end-to-end check
```

### B.5 — The one gap: workflow files

Confirmed directly this session: pushing a **new or modified** file under
`.github/workflows/` fails with this token —

```
refusing to allow an OAuth App to create or update workflow
`.github/workflows/whatever.yml` without `workflow` scope
```

— even though the account's own Write role does **not** actually forbid
this (confirmed by creating a workflow file live through the GitHub web UI
while logged into the machine account directly — no token involved at all,
and it worked). So this is purely a property of the *credential's* scope,
not a limit on the *account*. **Deleting** a workflow file is not gated the
same way (also confirmed directly) — only adding/changing YAML content is,
which makes sense: that's the part that can run arbitrary code in CI.

If a task actually needs to create/edit a workflow file, request a fresh
device code with `scope=repo+read:org+workflow` (same B.1–B.4 procedure)
rather than carrying that scope as a standing default. It's a meaningfully
bigger trust step — worth a deliberate ask each time it's actually needed,
not baked in up front.

---

## Quick-reference: what this setup gets you, confirmed by direct testing

| Capability | Works? |
|---|---|
| Read/write repo contents, push, branches | ✅ |
| Open, comment on, merge PRs | ✅ |
| List/view/**dispatch**/**cancel** workflow runs | ✅ |
| Create/edit files anywhere **except** `.github/workflows/` | ✅ |
| Delete files under `.github/workflows/` | ✅ (not scope-gated) |
| Create/edit files under `.github/workflows/` (with only `repo read:org`) | ❌ — needs `workflow` scope added |
| Repo settings, secrets, branch protection, deleting the repo | ❌ — owner-only, personal repos have no admin tier for collaborators |
| See any other repo, even ones the human owns | ❌ — only whatever it's been individually invited to |

## Cleanup, whenever the project winds down

Either revoke from the human's side (**Settings → Applications →
Authorized OAuth Apps → GitHub CLI → revoke**, on the machine account) or
just remove it as a collaborator from the repo — either one fully closes
the loop, no expiration timer needed since this token doesn't auto-expire
the way fine-grained PATs can.
