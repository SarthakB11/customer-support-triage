# Experience notes

Running log of the 20-minute Lamatic.ai evaluation. Updated after each step.

## What I tried
- Built `faq-ingest` as YAML in the Config editor: API Request trigger -> Code node (5 FAQ entries -> `texts[]` + `metadata[]`) -> API Response. Tested OK. Vectorize + VectorDB Index nodes are next and need an embedding-model credential.

- Prep (before touching Studio): read the docs to map the flow onto Lamatic nodes.

## Worked first time
- `support-ticket-triage` test run: once the `prompts` shape and `searchNode` type were right, all five nodes (API Request, Classify, Search FAQ, Draft reply, API Response) passed on the first Test.
- Deploy: Deploy button -> tick the two flows -> Purpose -> Deploy; three stages (Jobs, Webhooks, Edge Deployment) finished in about a minute.
- `faq-ingest` end to end with Gemini: Code -> Vectorize (`gemini-embedding-001`, 3072 dims) -> VectorDB Index into `faq`. Test output: `recordsIndexed: 5, duplicateRecordsDeleted: 0, "Data indexed successfully"`. Per-node cost/timing shown in the execution panel (Embed FAQ 7.3s, Index 6.2s).
- Second flow (`support-ticket-triage`) built purely from YAML in the Config editor, with no clicks in node panels, once I knew the undocumented shape: trigger `values.responeType` (sic) + a `schema:` block, and `allConfigs."Config A"` mirroring `values` on every node. Saved with no errors on the first try.
- Flow **Test**: once the flow saved, Test ran the whole chain without asking for inputs and marked every node "Test Successful", with per-node timing (API Request 3.32s, Code 2.70s, Response 1.88s) and the response JSON `{ "count": 5 }`. The execution panel with Input/Output/Logs per node is good.
- The flow editor's **Config** button is a Monaco editor holding the flow as low-code YAML. Pasting YAML there and pressing Save renders the nodes on the canvas immediately. This is the fastest way to build a flow, and it is not mentioned anywhere in the quickstart.
- Creating the Vector Store: name + type + Create, toast "Context Store successfully created", store shows `0 cols · 0 rows`.

- Docs are on GitHub (`Lamatic/Lamatic-Docs`), so exact node fields could be pulled from the `.mdx` sources when the rendered pages were thin.

## Did not work (exact error / friction)
- The docs' LLM node YAML (`promptTemplate` + `systemPrompt`) is stale. Studio silently ignores those keys and Save fails with "Unconfigured Classify — Fill required field Prompts before saving the flow". The real key is `prompts: [{id, role, content}]`; I found it by reading the node registry out of Studio's JS bundle.
- Test with an API Request trigger fails with `Trigger payload type validation failed: payload.email: required field is missing` until you open Test Library and edit the JSON payload; the Test Library has no visible "new test" button, only a search box and an empty list.
- Deploy dialog: the Deploy button stayed disabled after filling Purpose programmatically; typing into Description enabled it. Minor, but form state is keystroke-driven.
- After adding a model credential, a flow editor tab opened earlier shows no credentials in the node's "Select Credential" list (only "Add Provider"); a page reload fixes it.
- YAML pasted into Config only re-renders the canvas after the editor has focus and a content change fires; a plain `setValue` from the outside left the canvas stale until nudged.
- The Vector Store page kept showing `Records: 0` right after a successful index (`recordsIndexed: 5`); needed a reload.
- Guessing the search node type from the docs pattern (`hybridSearchNode`, `fullTextSearchNode`) gave `vectorSearchNode`, which Studio rejects: "nodeType 'vectorSearchNode' does not exist for node: Search FAQ". The Vector Search docs page never shows its own YAML.
- Trigger "Response Type": YAML `responseType: realtime` is ignored. Selecting it in the node panel writes a second key, `responeType: realtime` (sic), and that misspelled key is what the save validator checks. Until then Save fails with "Unconfigured GraphQL Response Type — You have to configure graphql trigger response type before saving the flow".
- Save validation errors surface one at a time (schema, then response type, then "No GraphQL Response Node Found — You have to add a GraphQL response node before saving the flow"), each with a "Get Support" button. Three save attempts to learn three requirements.
- Saving a flow whose API Request trigger schema was set in YAML (`advance_schema`) fails with the toast "Unconfigured GraphQL Schema — You have to configure graphql trigger schema before saving the flow", with a "Get Support" button on a plain validation error. The docs' `advance_schema` key is not what the validator checks.
- New flows open with a 34-step Arcade walkthrough overlay on top of the canvas.
- Studio at a ~960px-wide window shows only "Best Viewed on Desktop" and nothing else; had to widen the window to 1600px to get past it.
- Onboarding "Skip" on the Add-a-model step did nothing on first click; navigating to the Studio root got past it.
- The docs say "Context"; the left nav says "Data" (URL is `/context`). `/data` is a 404.
- The "Help & Support" modal opens by itself on every page load in a fresh project and sits on top of the page.
- Models > Default Models: provider dropdown is empty until you add a credential, so there is no zero-key path to a first test.

- Studio login page (`studio.lamatic.ai/login`): before signing in you get a cookie modal, a Cloudflare Turnstile check, and a Featurebase NPS survey ("How likely are you to recommend us to a friend?") stacked on the same screen. Three interruptions before the first click.
- Docs: the **Vector Search Node** page is a copy of the Keyword Search page. Its Setup section says "Select the Keyword Search Node" and the low-code example is `nodeType: fullTextSearchNode`, `nodeName: Keyword Search`. It also does not say whether the node needs an embedding model or reuses the store's.
- Docs: "Mapping and Ingesting Data" (`/docs/context/vectordb/adding-data`) is conceptual. It never says how a handful of records get into a store, so a second flow (Code -> Vectorize -> VectorDB Index) had to be inferred from the node pages.
- Docs: Generate JSON output-reference syntax is only visible in the low-code YAML (`InstructorLLMNode_774`), not stated in prose.

## One concrete improvement I'd want
Make the low-code YAML a first-class, documented, validated interface. Concretely: generate the docs' YAML examples from the same node registry Studio ships in its bundle, and have the Config editor reject unknown keys and node types with the message Studio already knows ("nodeType 'vectorSearchNode' does not exist") *before* Save, instead of a red banner after. Every wrong turn I took today (`promptTemplate`, `responseType`, `vectorSearchNode`, JSON Schema vs Zod JSON) would have been a one-line editor error.
