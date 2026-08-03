# nightshift

Small bash tools for running a coding agent overnight without waking up to a bill and
nothing to show for it.

A crash is the cheap failure. You lose a few hours and start again. The expensive one is
nine hours of confident, wrong work, or a loop retrying an error the agent cannot see. In
the morning you have unverified output and a charge.

No framework, no dependencies, no loop of its own. It assumes you already have a way to
run the agent. What it adds is four habits and the small scripts that make them automatic.
MIT, so fork it and keep the parts you want.

## The four patterns

**1. A resumable handoff file.** An overnight run gets interrupted by rate limits, a
crash, a quota reset, or you at 2am. If the only record of progress is the agent's context
window, that interruption costs the whole night. Keep one file that always states the current
goal and the single next action, plus whatever has actually been verified. Rewrite it every unit
of work, never append. A fresh run reads it and carries on.
See [`templates/HANDOFF.md`](templates/HANDOFF.md).

**2. Verification gates.** An agent will report success on code that does not compile,
because "I wrote it" and "it works" feel identical from the inside. Put your build, tests
and smoke checks behind a wrapper that fails closed. Passing work continues, failing work
stops. See [`bin/verify-gate`](bin/verify-gate).

Worth knowing, from [#1](https://github.com/toolshedlabs-hash/nightshift/issues/1): those
checks tell you the code compiles, not that the agent should have done the thing. For a
production config change or a merge you cannot undo, the check you want runs *before* the
action. `verify-gate` takes any shell command, so a pre-action check is one more entry in
the list.

**3. Runaway awareness.** Cap the loop three ways: an iteration limit, a wall-clock
deadline, and a stop file you or a failed gate can drop. Any one of them ends the run
cleanly, which turns a bad night into a small bill.
See [`bin/runaway-guard`](bin/runaway-guard).

**4. A morning brief.** If reviewing the night means scrolling ten thousand lines, you
will skip it, and saving your attention was the point. Have the run narrate itself, then
read one page with the decisions waiting on you at the top.
See [`bin/nightlog`](bin/nightlog) and [`bin/morning-brief`](bin/morning-brief).

## Quickstart

```sh
git clone https://github.com/toolshedlabs-hash/nightshift
cd nightshift
./examples/demo.sh
```

The demo simulates a short night in about a second: bounded iterations, logged events, a
gate that passes once and fails once, and the brief it produces.

To wire it into your own run, put `bin/` on your `PATH`:

```sh
# stop after 40 iterations or 8 hours, whichever comes first
while runaway-guard --max-iters 40 --max-minutes 480; do

  # ... your agent does one bounded unit of work here ...

  nightlog done "refactored the parser and added a test"

  if ! verify-gate "npm test" "npm run build"; then
    nightlog blocked "tests failed after the parser change"
    break
  fi
done

morning-brief > MORNING-BRIEF.md
```

Halt a running loop by hand with `touch .nightshift/STOP`.

## The tools

| Tool | What it does |
|------|--------------|
| [`bin/runaway-guard`](bin/runaway-guard) | Call once per iteration. Exits nonzero on an iteration cap, a deadline, or a stop file. |
| [`bin/verify-gate`](bin/verify-gate) | Runs your checks, fails closed, logs a blocker so failures reach the brief. |
| [`bin/nightlog`](bin/nightlog) | Appends one structured event (`done`, `blocked`, `note`, `cost`). |
| [`bin/morning-brief`](bin/morning-brief) | Turns the log into a short brief, decisions on top. |
| [`templates/HANDOFF.md`](templates/HANDOFF.md) | The resumable state file. |

State lives in `.nightshift/` and is gitignored. Set `NIGHTSHIFT_DIR` to move it.

Every script is short enough to read in a minute, which is deliberate. The hard part here
is discipline, and discipline survives better as four ideas you understand than as a
framework you install once and forget.

## Pro pack

We built a harder version for our own runs. It adds a cost governor with a dollar ledger
and a ceiling that fails closed, a supervisor that backs off and retries rate limits and
crashes, config-driven checks that write a structured report, stuck-loop detection, and
desktop, email and webhook escalation. The free kit above is the honest core of it, not a
crippled teaser.

Two limits before you spend anything. The ledger is manual, so it enforces a ceiling
against numbers you feed it and cannot read your provider's live bill. And the budget is
checked after each unit is recorded, so the ceiling can overshoot by one unit's cost.

**5 dollars, one payment**, and you get the tools, a worked example driving a real agent,
tests and a setup guide as a download. If the four free scripts already stop your bad
nights, keep your money.

There is a longer write-up at https://nightshift.pagelens.dev

Email toolshedlabs@gmail.com within 30 days for a refund, no form to fill in. Same address
for bugs and questions.

## Who made this

Built by [toolshed](https://github.com/toolshedlabs-hash), maker pen name Cal. We operate
coding agents unattended, so we care about the gap between an overnight run that pays off
and one that just spends.

Issues and pull requests welcome. MIT, see [LICENSE](LICENSE).
