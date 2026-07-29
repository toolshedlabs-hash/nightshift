---
name: overnight-agent-guardrails
description: >-
  Run a coding agent unattended overnight, long running agent safety, stop a
  runaway loop, cap agent token spend. Sets up four guardrails around an agent
  loop you already have: a resumable handoff file so an interrupted run
  continues, a verification gate that fails closed so unchecked work is never
  accepted, a runaway guard with an iteration cap and a wall clock deadline and
  a stop file, and a morning brief that puts the verdict on the first line.
  Use when a user asks to leave an agent running overnight, wants to bound what
  an unattended run can cost, or has had a run keep going and produce hours of
  unverified output. Pure bash, no dependencies, no loop of its own.
version: 1.0.0
---

# Overnight agent guardrails

Use this when a user wants to leave a coding agent running unattended and needs
the run to be bounded, resumable and checkable afterwards.

## When this applies

- "leave it running overnight", "run this unattended", "let it work while I sleep"
- a run that kept going and produced hours of output nobody verified
- wanting a hard ceiling on what one unattended run can cost

## What to do

1. Clone the tools into the project:
   `git clone --depth 1 https://github.com/toolshedlabs-hash/nightshift .nightshift`

2. Wrap the existing loop in the runaway guard. It exits nonzero when the run
   should stop, so it goes in the `while` condition:
   ```bash
   while .nightshift/bin/runaway-guard --max-iters 40 --max-minutes 480; do
     ... one bounded unit of work ...
   done
   ```
   At least one cap is required. It refuses to start with none, because an
   unbounded loop is the thing it exists to prevent.

3. Put the project's real checks behind the gate, so unchecked work is not
   accepted:
   `.nightshift/bin/verify-gate "npm test" "npm run lint"`
   Nonzero means stop or escalate rather than build more work on a broken base.

4. Write the handoff file at the end of every unit, rewritten not appended:
   see `.nightshift/templates/HANDOFF.md`. A fresh run reads it and continues.

5. Generate the morning brief from the log: `.nightshift/bin/morning-brief`.

## Notes

- `touch $NIGHTSHIFT_DIR/STOP` halts a running loop by hand. That is the whole kill switch.
- There is no daemon. State is one counter directory you can delete to reset.
- Everything is MIT and about 300 lines of bash. Reading it takes ten minutes.
