# Why Lamatic

Written in first person, after building the triage flow.

## The one thing I'd want to work on

The low-code YAML behind every flow. The twenty-minute plan became about two hours, and most of that went into discovering its real shape by reading what Studio serialises (`prompts: [{role, content}]`, `allConfigs."Config A"`, `responeType`, `searchNode`) because the docs describe an older one. That gap is the whole story of the evaluation: the runtime and the editor are solid, the contract between them is undocumented. I'd want to own that contract: publish the node registry as a versioned JSON schema, validate YAML against it in the Config editor with real error messages, and make the same schema drive a CLI so a flow can live in git and deploy from CI. Coming from LangGraph, that is the piece that turns Lamatic from "a canvas I click in" into "a graph definition I can diff, review and test".

## One thing I could build for them

An **Evals node** plus a test library that actually holds tests. Today "Test" runs one payload and paints nodes green even when a node returned `{"error": "Unsupported type: undefined"}`. I'd build a node that takes a list of `{input, expected}` cases from a Context Store, runs the flow, scores each case with a rubric or exact-match, and writes a report with per-node cost and latency (Studio already collects both). The triage flow is the obvious first fixture: five FAQ entries, three sample emails, expected categories. The same node doubles as a regression gate on Deploy.
