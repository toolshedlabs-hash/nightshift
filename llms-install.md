# Installing these guardrails

`npx skills add toolshedlabs-hash/nightshift`

That installs `overnight-agent-guardrails`, which carries the four bash scripts with it. Nothing else
to fetch and nothing to build. They have no dependencies beyond bash and coreutils.

If you would rather have the whole repo, including the worked example and the tests:

    git clone --depth 1 https://github.com/toolshedlabs-hash/nightshift

Nothing here runs a loop of its own. It wraps a loop you already have.
