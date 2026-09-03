# Why Lamatic

## The one thing I'd want to work on

The low code YAML behind every flow. The twenty minute plan turned into about two hours, and most of that went into working out the YAML's real shape by reading what Studio serialises (`prompts: [{role, content}]`, `allConfigs."Config A"`, `responeType`, `searchNode`), because the docs describe an older one. That gap is the whole story of the evaluation. The runtime and the editor are solid; the contract between them is undocumented. I want to own that contract: publish the node registry as a versioned JSON schema, validate YAML against it in the Config editor with real error messages, and let the same schema drive a CLI so a flow can live in git and deploy from CI. Coming from LangGraph, that is the piece that turns Lamatic from a canvas I click in into a graph definition I can diff, review and test.

## One thing I could build for them

An Evals node, plus a test library that actually holds tests. Today "Test" runs one payload and paints every node green even when a node returned `{"error": "Unsupported type: undefined"}`. I would build a node that takes a list of `{input, expected}` cases from a Context Store, runs the flow, scores each case with a rubric or an exact match, and writes a report with cost and latency per node (Studio already collects both). The triage flow is the obvious first fixture: five FAQ entries, three sample emails, expected categories. The same node can act as a regression gate on Deploy.
