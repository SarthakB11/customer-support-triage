# Experience notes

Running log of the 20-minute Lamatic.ai evaluation. Updated after each step.

## What I tried
- Built `faq-ingest` as YAML in the Config editor: API Request trigger -> Code node (5 FAQ entries -> `texts[]` + `metadata[]`) -> API Response. Tested OK. Vectorize + VectorDB Index nodes are next and need an embedding-model credential.

- Prep (before touching Studio): read the docs to map the flow onto Lamatic nodes.

## Worked first time
- Flow **Test**: once the flow saved, Test ran the whole chain without asking for inputs and marked every node "Test Successful", with per-node timing (API Request 3.32s, Code 2.70s, Response 1.88s) and the response JSON `{ "count": 5 }`. The execution panel with Input/Output/Logs per node is good.
- The flow editor's **Config** button is a Monaco editor holding the flow as low-code YAML. Pasting YAML there and pressing Save renders the nodes on the canvas immediately. This is the fastest way to build a flow, and it is not mentioned anywhere in the quickstart.
- Creating the Vector Store: name + type + Create, toast "Context Store successfully created", store shows `0 cols · 0 rows`.

- Docs are on GitHub (`Lamatic/Lamatic-Docs`), so exact node fields could be pulled from the `.mdx` sources when the rendered pages were thin.

## Did not work (exact error / friction)
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
