# nightshift

Patterns and small tools for running a coding agent unattended overnight without it
turning into a token bonfire.

Leaving Claude Code (or any coding agent) running while you sleep is a great deal when
it works. You wake up to real progress. The way it fails is worse than most people brace
for. A crash would be fine, you lose a few hours and start over. What actually happens is
it keeps going for nine hours, confident and wrong, or loops on an error it cannot see and
spends money on every retry. In the morning you have a pile of unverified output and a bill.

This repo is the boring layer that makes the good outcome the normal one. No framework,
no dependencies, no loop of its own. It assumes you already have a way to run the agent.
It gives you the four habits that decide whether an overnight run is worth doing, plus a
handful of tiny bash tools that make those habits automatic instead of aspirational.

We build developer tools and we run coding agents unattended a lot. These are the
patterns we reach for every time. They are generic on purpose. Use the ideas, use the
scripts, or read the README and write your own. All of it is MIT.

## The four patterns

### 1. A resumable handoff file

An overnight run will be interrupted. Rate limits, a crash, a quota reset, you killing
it at 2am. If the only record of where it got to lives in the agent's context window,
the interruption costs you the whole night.

The fix is one file that always describes the current state, rewritten (not appended)
at the end of every unit of work. Goal, status right now, the single next action, known
traps, what has actually been verified. A fresh run reads that file first and continues
as if nothing happened. It is the cheapest reliability you can buy.

See [`templates/HANDOFF.md`](templates/HANDOFF.md).

### 2. Verification gates

An agent will report success on code that does not compile. Not because it is lying,
because "I wrote the code" and "the code works" feel the same from the inside. If you
trust overnight output, you are building the next eight hours of work on top of things
that were never checked.

So do not trust it. Gate it. Put your real checks (build, tests, a linter, a smoke
script) behind a wrapper that fails closed. If the checks pass, accept the work and move
on. If they fail, stop or escalate instead of piling more work on a broken base.

See [`bin/verify-gate`](bin/verify-gate).

### 3. Runaway awareness

The run that costs you is the one that works perfectly and does the wrong thing for six
hours. A crash is cheap next to that. You want a hard ceiling so the worst possible night still has a
bounded cost.

Cap the loop three ways: a maximum number of iterations, a wall-clock deadline, and a
stop file you (or a failed gate) can drop to halt it immediately. Any one of the three
ends the run cleanly. A bad night becomes a small bill instead of an open question.

See [`bin/runaway-guard`](bin/runaway-guard).

### 4. A morning brief, not a scrollback

If reviewing the night means scrolling ten thousand lines of agent chatter, you will not
do it, and the whole point was to save your attention. The run should narrate itself as
it goes, in a format something can summarize. Then you wake up to a single page: the
decisions waiting on you first, then what got done, then cost and notes.

Decisions first is the important part. That is the only section that needs you before
the next run starts.

See [`bin/nightlog`](bin/nightlog) (the run narrates) and
[`bin/morning-brief`](bin/morning-brief) (you read the summary).

## Quickstart

Everything is bash with no dependencies. Clone it and run the demo to see the whole kit
work end to end in about a second:

```sh
git clone https://github.com/toolshedlabs-hash/nightshift
cd nightshift
./examples/demo.sh
```

That simulates a short night: bounded iterations under the guard, a couple of logged
events, a verification gate with one pass and one deliberate fail, and the morning brief
it all produces.

To use the tools in your own run, put `bin/` on your `PATH` (or call the scripts by
path) and wire them into however you already launch the agent:

```sh
# stop after 40 iterations or 8 hours, whichever comes first
while runaway-guard --max-iters 40 --max-minutes 480; do

  # ... your agent does one bounded unit of work here ...

  # the run narrates what happened
  nightlog done "refactored the parser and added a test"

  # only accept the work if it actually passes
  if ! verify-gate "npm test" "npm run build"; then
    nightlog blocked "tests failed after the parser change, needs a look"
    break
  fi
done

# in the morning
morning-brief > MORNING-BRIEF.md
```

To halt a running loop by hand, drop a stop file:

```sh
touch .nightshift/STOP
```

## The tools

| Tool | What it does |
|------|--------------|
| [`bin/runaway-guard`](bin/runaway-guard) | Call once per iteration. Exits nonzero when an iteration cap, a wall-clock deadline, or a stop file says the run should end. |
| [`bin/verify-gate`](bin/verify-gate) | Runs your checks and fails closed if any fail. Logs a blocker so failures surface in the brief. |
| [`bin/nightlog`](bin/nightlog) | Appends one structured event (`done`, `blocked`, `note`, `cost`) to the night log. |
| [`bin/morning-brief`](bin/morning-brief) | Turns the night log into a short brief with the decision list on top. |
| [`templates/HANDOFF.md`](templates/HANDOFF.md) | The resumable state file. Copy it in and have the run keep it current. |

State (the log, iteration counter, deadline) lives in `.nightshift/` by default. Set
`NIGHTSHIFT_DIR` to move it. That directory is gitignored, since it is per-run state and
does not belong in your history.

## Why so small

Because the hard part is the discipline, not the code, and discipline survives better as
four ideas you actually understand than as a framework you install and forget.
Every script here is short enough to read in a minute and change to fit your setup. That
is the intent. Fork it, gut it, keep the two tools you like.

## Pro pack

We built a harder version of this for our own overnight runs and packaged it as a Pro
pack. What it adds: a cost governor with a real dollar ledger and a hard ceiling that
fails closed, a supervisor that backs off and retries a rate limit or a crash instead of
losing the night, a verification gate that runs named checks from config and writes a
structured report, stuck-loop detection on top of the iteration and time caps, desktop,
email and webhook escalation, and an orchestrator that runs all of it as one loop. This
free kit is the honest core of it, not a crippled teaser.

Two limits worth knowing before you spend anything. The ledger is manual: you feed it the
numbers your run reports and it enforces the ceiling against that running total, so it
cannot read your provider's live bill for you. And because the budget is checked after
each unit is recorded, the ceiling can overshoot by up to one unit's cost.

It is 79 dollars, one payment, and you get the whole kit as a download (the tools, a
worked example that drives a real agent, tests, and a setup guide). The honest test is
simple: if the four free scripts already stop your bad nights, keep your money, you are
done. If you would rather buy the hardened version than build it, what it does and what
it does not do is written up here:

https://nightshift.pagelens.dev

If the download fails, or it is not what you expected, or you just changed your mind,
email toolshedlabs@gmail.com within 30 days and we refund it. No argument, no form to
fill in. Same address for bugs and questions.

## Who made this

Built by [toolshed](https://github.com/toolshedlabs-hash), maker pen name Cal. We make
developer tools and we operate coding agents unattended, so we care a lot about the
difference between an overnight run that pays off and one that just spends. If these
patterns save you a bad morning, good.

Issues and pull requests welcome. If you have a pattern that has saved you on an
unattended run, open one.

## License

MIT. See [LICENSE](LICENSE). Copyright toolshed.
