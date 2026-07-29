# HANDOFF

Copy this into your project (or your agent's working dir) and have the run rewrite it
at the end of every unit of work. It is the single file the next run reads first.

The rule that makes it work: this file always describes the CURRENT state, not a
history. Overwrite it, do not append. If the run crashes, gets rate-limited, or you
kill it, the next run starts here and loses nothing but the half-finished step.

Keep it short. If it grows past a screen, the run is tracking too much in its head and
not enough in the repo.

---

## Goal

<One or two sentences. What is this run actually trying to finish? Unchanged night to
night until the goal is met.>

## Status right now

<The one thing a fresh run needs to know to continue. "Refactor of module X is done and
tests pass; module Y is next and untouched." Be specific enough that a run with zero
memory of tonight can pick up cleanly.>

## Next action

<The very next concrete step, small enough to finish in one bounded unit. Not a plan,
one step.>

## Do not touch / known traps

<Anything that will waste the next run's time. "Test suite is flaky on network calls,
retry once before trusting a fail." "Do not upgrade package Z, it breaks the build.">

## Open decisions for a human

<Things the run cannot decide on its own. These should also be logged as `blocked`
events so they surface in the morning brief. If empty, say "none".>

## Verified

<What has actually been checked, and how. "Build passes, unit tests pass, smoke script
green as of the last gate." This is what stops the next run from re-doing settled work
or trusting unverified work.>
