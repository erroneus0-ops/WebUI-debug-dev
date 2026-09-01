# HERO Project: Claude Code Workflow — Review & Recommendations

*Written at the end of a long session, 28 Aug 2026, for review whenever you're back.*

---

## 1. "I don't know if it's me or not" — it's very likely not you

This deserves a direct answer, not a hedge: what you're describing — things slipping,
losing traction, a sense that quality degrades as a conversation grows — is a **real,
named, well-documented phenomenon**, not a sign you're doing something wrong.

Claude Code's own current documentation is explicit about this: *"Claude Code does not
have one unlimited conversation memory. A coding session accumulates prompts, tool
calls, file contents, command output, instructions... inside a model context window."*
Long sessions genuinely fill that window, and once they do, real, recognizable symptoms
show up:

- Claude starts asking for information you already gave it earlier (a retrieval
  failure from the middle of the accumulated context)
- Generated code starts contradicting earlier decisions you both already made
- It loses track of the file structure it was navigating a few minutes prior

That's the actual mechanism behind "we lose traction somehow." It's not memory failure
on your end — it's a structural property of how the tool works, and the good news is
it's now **checkable, not just felt**.

### Concrete tools to manage it (verified against current Claude Code docs)

- **`/context`** — shows you exactly what's consuming the context window right now.
  Check this periodically, not just when something already feels off.
- **A practical intervention point: 60% context utilization.** That's a real, cited
  heuristic — don't wait until things are visibly breaking down before you act.
- **`/compact <focused prompt>`** — don't just run bare `/compact`. Tell it what to
  keep: e.g. `/compact Keep only the interpreter-fidelity decisions, discard the
  packaging discussion.` This is far more reliable than an unguided compact.
- **`/clear`** — a hard reset. Use this specifically when *context is poisoned* —
  when Claude keeps reverting to an assumption you've already corrected. This is
  probably the single most useful command for exactly what you described as
  "slipping." Note: it wipes the session entirely except for `CLAUDE.md`, which
  reloads automatically — so make sure anything durable lives there first.

---

## 2. `CLAUDE.md` — the actual fix for "does this still remember what matters"

Every Claude Code session starts with a **completely fresh context window**. The two
things that survive across sessions are:

1. **`CLAUDE.md`** — instructions *you* write, loaded automatically every session
2. **Auto memory** — notes Claude writes itself based on your corrections over time

For the HERO project specifically, `CLAUDE.md` is where the *durable, non-negotiable*
facts about the project should live — not in conversation, where they're exactly the
kind of thing that gets crowded out as a session grows:

- What the original interpreted BASIC dialect's specific quirks/semantics actually are
  (the things a naive reimplementation would get subtly wrong)
- What "correct" means for this project — fidelity to the original interpreter's
  actual behavior, not just "produces plausible BASIC-like output"
- Any known-intentional deviations from the original, clearly flagged as deliberate
  so they don't get "fixed" back into a bug by mistake

**One important, verified caveat:** both `CLAUDE.md` and auto memory are treated as
context, not enforced configuration — Claude generally follows them, but isn't
*hard-blocked* by them. If there's something that must **never** happen — say, "never
overwrite the reference test programs" or "never delete anything under
`/golden-master/`" — that needs a **`PreToolUse` hook**, which can actually block an
action regardless of what Claude decides in the moment. Worth setting one up for
anything in this project where "usually respected" isn't good enough.

Keep `CLAUDE.md` **under 200 lines** — this is Anthropic's own stated guidance, not
just a stylistic preference. A bloated file competes with everything else for context
space and can actually reduce how reliably Claude follows it. Push large or
conditional detail (a full opcode reference, an exhaustive quirks list) into separate
files or skills that get loaded only when relevant, rather than jamming it all into the
one always-loaded file.

---

## 3. Your project is genuinely, structurally harder than "write a game like this" —
## not just harder in how it feels

This is worth stating plainly rather than softening: your instinct here is *correct*,
not just a feeling of difficulty.

**Greenfield generation** ("write a game like this") has a forgiving success
criterion. There's no ground truth to be unfaithful to — if something plausible and
fun comes out, it worked. That's exactly the kind of task an LLM is naturally good at,
and it's why your peers can point at Claude Code output and go "yeah, that's basically
right" without a rigorous check.

**The HERO project** — taking an existing interpreted BASIC dialect and producing a
compiled version of it — has a completely different, much less forgiving success
criterion: the output has to behave **identically** to something that already exists,
including whatever undocumented quirks, edge-case behaviors, and even "bugs" the
original interpreter has, if programs out there depend on them. That's not "generate
something plausible." That's **software archaeology plus compiler correctness** — a
genuinely harder category of problem, and one where "looks right" and "is right" can
diverge badly without you noticing, especially across a long, drifting session.

### The fix is the same discipline that ran through the rest of tonight

Almost everything that went right in this conversation — the icon DLL, the SSL
certificate, the WSL boot fix — worked because things got **verified against ground
truth**, not trusted on sight. The exact same discipline is the actual answer to your
"losing traction" problem here, and it converts a vague felt sense into an objective,
checkable fact:

1. **Build a golden-master test suite early**, not as an afterthought. Take real
   programs written in the original BASIC dialect, run them on a real (or
   authoritatively documented) reference interpreter, and capture their actual
   output — including quirky, "wrong-looking" behavior, if that's what the original
   genuinely does.
2. **Run that suite automatically against every change** to the compiler. This is
   real Continuous Integration — the thing your "cognitive insulation" joke was
   actually gesturing at, whether you meant it seriously or not. It's a completely
   legitimate, recommended practice for exactly this kind of long-running,
   drift-prone Claude Code work.
3. When a session starts sliding, the test suite tells you **immediately and
   objectively** — not "does this feel right," but "does this match the reference,
   yes or no." That removes the need to trust your own sense of whether things have
   drifted, which is exactly the uncertainty you described.

---

## 4. Tie this back to the security work from earlier tonight

You already built the right container for this. Given the HERO project needs write
*and delete* access to your repo — exactly the scenario that containment was designed
for — this work should run under:

- The scoped **`WebUIdebug`** GitHub identity (confirmed tonight: write access to
  exactly one repo, nothing else reachable)
- A hardened, no-sudo Linux account for the actual Claude Code execution, once you
  get around to building it (the `daniel` account already had sudo removed; the
  dedicated project account is the next piece, whenever you're ready for it)

No new work needed here tonight — just worth remembering this is *why* that
architecture exists, and that the HERO project is exactly the use case it was built to
contain.

---

## Summary, if you only read one section

- The drift you're feeling is real, named, and now checkable via `/context` — not a
  reflection on you.
- `CLAUDE.md` (kept lean, under 200 lines) is where durable project facts belong, not
  in conversation. Hooks are for things that must be *hard*-enforced, not just
  suggested.
- Your project really is harder than generative greenfield work, in a specific,
  well-defined way — and a golden-master test suite is the concrete answer to both
  "is this still correct" and "did we lose traction," at the same time.
