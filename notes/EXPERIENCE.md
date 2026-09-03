# Experience

Running notes from the Lamatic.ai evaluation. Planned as twenty minutes, it took about two hours.

## What I tried

1. Read the docs, and the Lamatic-Docs sources on GitHub, to map the flow onto Lamatic nodes.
2. Signed up in Studio, skipped onboarding, and created a Vector Store called `faq` under Data > Context Stores.
3. Built `faq-ingest`: API Request, a Code node with the 5 FAQ entries, Vectorize with Gemini, VectorDB Index, API Response. I wrote it as YAML in Flow > Config.
4. Built `support-ticket-triage`: API Request with an `email` field, Generate JSON for category and confidence, Vector Search with limit 2, Generate Text for the reply, API Response returning `{category, confidence, reply}`.
5. Tested in Studio, deployed to the edge, created an API key, and called `executeWorkflow` from curl with three sample emails.
6. Debugged three silent failures (the JSON schema format, a reserved `id` property, the search certainty threshold) by reading Studio's JS bundle. Five deploys in total.

## Worked first time

- The final curl calls, all three samples, about 10 seconds each. Billing came back as `{category: "billing", confidence: 1}` with the refund window and the Settings > Billing path from the FAQ. Bug came back as `bug, 0.99`, and the reply cites the request ID and the P1 rule. Feature came back as `feature_request, 1` with the roadmap policy. Every call shows up under Monitor > Logs with tokens and cost per node.
- The `support-ticket-triage` test run. Once the `prompts` shape and the `searchNode` type were right, all five nodes passed on the first Test.
- Deploy. Tick the flows, type a purpose, click Deploy. Jobs, Webhooks and Edge Deployment took about a minute.
- `faq-ingest` end to end with Gemini: Code, Vectorize (`gemini-embedding-001`, 3072 dims), VectorDB Index into `faq`. The test reported `recordsIndexed: 5` and showed cost and timing per node (Embed FAQ 7.3s, Index 6.2s).
- Building the second flow purely from YAML in the Config editor, with no clicks in node panels, once I knew the shape Studio wants: `responeType` (sic) on the trigger, a `schema:` block, and `allConfigs."Config A"` mirroring `values` on every node. It saved with no errors on the first try.
- Flow Test. It ran the whole chain without asking for inputs, marked every node, and showed timing per node plus the response JSON. The execution panel with Input, Output and Logs per node is good.
- The Config button. It is a Monaco editor holding the flow as low code YAML. Paste, Save, and the nodes appear on the canvas. It is the fastest way to build a flow, and the quickstart never mentions it.
- Creating the Vector Store: name, type, Create.
- The docs live on GitHub (`Lamatic/Lamatic-Docs`), so I could pull exact node fields from the `.mdx` sources when the rendered pages were thin.

## Did not work (exact error or friction)

- Vector Search returned `[]` for every query while the Index node reported `recordsIndexed: 5, "Data indexed successfully"` and the store page showed `Records: 0`. I found the cause in the Index executor in Studio's bundle: batch insert errors on the last partial batch are caught and dropped, and the node still reports success. Weaviate had rejected every object because my metadata used the reserved property name `id`. Renaming it to `faq_id` filled the store and the search returned two hits. Two hours of the platform saying "success" for a write that never happened.
- Vector Search also has a `certainty` input, default 0.85, that the docs' parameter table does not list. I lowered it to 0.5 while debugging. Worth knowing before you blame the embeddings.
- Generate JSON schema format. The panel labels the field "Output Schema (Zod JSON)" and displays `[{name, type: enum|num, ...}]`, but the executor parses JSON Schema (`type: object/string/number`, `enum`) and throws on anything else. I pasted the Zod style array and the node returned `{"error": "Unsupported type: undefined"}` while the canvas still said "Test Successful" and the API response had `category: ""`. A node that returns an error object should not be marked successful.
- The GraphQL call itself said `status: success` on the first try, which hid the empty fields.
- The docs' LLM node YAML (`promptTemplate` plus `systemPrompt`) is stale. Studio ignores those keys and Save fails with the toast "Unconfigured Classify" / "Fill required field Prompts before saving the flow". The real key is `prompts: [{id, role, content}]`. I found it in the node registry inside Studio's JS bundle.
- Test with an API Request trigger fails with `Trigger payload type validation failed: payload.email: required field is missing` until you open Test Library and edit the JSON payload. The Test Library has no visible "new test" button, only a search box and an empty list.
- In the Deploy dialog the Deploy button stayed disabled after I filled Purpose programmatically. Typing into Description enabled it. Minor, but the form state is keystroke driven.
- A flow editor tab opened before I added a model credential shows only "Add Provider" in the node's Select Credential list. A reload fixes it.
- YAML pasted into Config only re-renders the canvas after the editor has focus and a content change fires. A plain `setValue` from outside left the canvas stale until nudged.
- The Vector Store page kept showing `Records: 0` right after a successful index. It needed a reload.
- Guessing the search node type from the docs pattern (`hybridSearchNode`, `fullTextSearchNode`) gave `vectorSearchNode`, which Studio rejects: "nodeType 'vectorSearchNode' does not exist for node: Search FAQ". The Vector Search docs page never shows its own YAML. The real type is `searchNode`.
- Trigger Response Type. YAML `responseType: realtime` is ignored. Picking it in the node panel writes a second key, `responeType: realtime` (sic), and that misspelled key is what the save validator checks. Until then Save fails with "Unconfigured GraphQL Response Type" / "You have to configure graphql trigger response type before saving the flow".
- Save validation errors arrive one at a time (schema, then response type, then "No GraphQL Response Node Found" / "You have to add a GraphQL response node before saving the flow"), each with a "Get Support" button. Three save attempts to learn three requirements.
- Setting the trigger schema in YAML alone (`advance_schema`) fails with "Unconfigured GraphQL Schema" / "You have to configure graphql trigger schema before saving the flow". The docs' `advance_schema` key is not what the validator checks.
- New flows open under a 34 step Arcade walkthrough on top of the canvas.
- At about 960px wide, Studio shows only "Best Viewed on Desktop". I had to widen the window to 1600px.
- Onboarding "Skip" on the Add a model step did nothing on the first click. Going to the Studio root got past it.
- The docs say "Context", the left nav says "Data", the URL is `/context`, and `/data` is a 404.
- The "Help & Support" modal opens by itself on every page load in a fresh project and sits on top of the page.
- Models > Default Models: the provider dropdown is empty until you add a credential, so there is no zero key path to a first test.
- The login page stacks a cookie modal, a Cloudflare Turnstile check and a Featurebase NPS survey ("How likely are you to recommend us to a friend?") on the same screen. Three interruptions before the first click.
- Docs: the Vector Search Node page is a copy of the Keyword Search page. Its Setup section says "Select the Keyword Search Node" and the low code example is `nodeType: fullTextSearchNode`. It also does not say whether the node needs its own embedding model.
- Docs: "Mapping and Ingesting Data" is conceptual. It never says how a handful of records get into a store, so I had to infer the second flow (Code, Vectorize, VectorDB Index) from the node pages.
- Docs: the Generate JSON output reference syntax only appears in the low code YAML (`InstructorLLMNode_774`), never in prose.

## One concrete improvement I'd want

Make the low code YAML a documented, validated interface. Generate the docs' YAML examples from the node registry Studio already ships in its bundle, and have the Config editor reject unknown keys and node types before Save, with the message Studio already knows ("nodeType 'vectorSearchNode' does not exist"), instead of a red banner after. Every wrong turn I took (`promptTemplate`, `responseType`, `vectorSearchNode`, JSON Schema vs Zod JSON, the reserved `id`) would have been a one line editor error.
