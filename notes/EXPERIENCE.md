# Experience notes

Running log of the 20-minute Lamatic.ai evaluation. Updated after each step.

## What I tried

- Prep (before touching Studio): read the docs to map the flow onto Lamatic nodes.

## Worked first time

- Docs are on GitHub (`Lamatic/Lamatic-Docs`), so exact node fields could be pulled from the `.mdx` sources when the rendered pages were thin.

## Did not work (exact error / friction)

- Studio login page (`studio.lamatic.ai/login`): before signing in you get a cookie modal, a Cloudflare Turnstile check, and a Featurebase NPS survey ("How likely are you to recommend us to a friend?") stacked on the same screen. Three interruptions before the first click.
- Docs: the **Vector Search Node** page is a copy of the Keyword Search page. Its Setup section says "Select the Keyword Search Node" and the low-code example is `nodeType: fullTextSearchNode`, `nodeName: Keyword Search`. It also does not say whether the node needs an embedding model or reuses the store's.
- Docs: "Mapping and Ingesting Data" (`/docs/context/vectordb/adding-data`) is conceptual. It never says how a handful of records get into a store, so a second flow (Code -> Vectorize -> VectorDB Index) had to be inferred from the node pages.
- Docs: Generate JSON output-reference syntax is only visible in the low-code YAML (`InstructorLLMNode_774`), not stated in prose.

## One concrete improvement I'd want
