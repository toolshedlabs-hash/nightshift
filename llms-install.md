# Installing these guardrails

`npx skills add toolshedlabs-hash/nightshift`

That places `skills/overnight-agent-guardrails/SKILL.md` where your agent can read it.

The scripts themselves are plain bash in `bin/` and have no dependencies. You can also just clone the
repo and wire them in by hand:

    git clone --depth 1 https://github.com/toolshedlabs-hash/nightshift .nightshift

Nothing here runs a loop of its own. It wraps a loop you already have.
