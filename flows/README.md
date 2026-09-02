# Flow configs

Both flows as exported from Studio's **Config** editor (Flow > Config), i.e. Lamatic's low-code YAML.
Paste into a new flow's Config editor, replace `REPLACE_WITH_YOUR_CREDENTIAL_ID` with the id Studio
writes when you pick a model credential in any node, then Save.

| File                         | Flow                    | Nodes                                                                                                                                            |
| ---------------------------- | ----------------------- | ------------------------------------------------------------------------------------------------------------------------------------------------ |
| `faq-ingest.yaml`            | `faq-ingest` (run once) | API Request -> Code (`codeNode`) -> Vectorize (`vectorizeNode`) -> VectorDB Index (`IndexNode`) -> API Response                                  |
| `support-ticket-triage.yaml` | `support-ticket-triage` | API Request(`email`) -> Generate JSON (`InstructorLLMNode`) + Vector Search (`searchNode`, limit 2) -> Generate Text (`LLMNode`) -> API Response |

Models used: `gemini-3.5-flash-lite` (chat), `gemini/gemini-embedding-001(3072)` (embeddings). Any provider works; the embedding model must be the same in ingest and search.

Things the docs do not tell you, learned by reading what Studio serializes:

- The API Request trigger needs `values.responeType` (sic) and a `schema:` block, or Save fails with "Unconfigured GraphQL Response Type".
- Every node carries `allConfigs."Config A"` mirroring `values`; the canvas reads from it.
- LLM nodes take `prompts: [{id, role, content}]`, not `promptTemplate`/`systemPrompt` as in the docs' YAML.
- Generate JSON's `schema` must be standard **JSON Schema** (`type: object`, `properties`, `enum`), even though the panel labels it "Zod JSON" and displays an array form. The array form makes the node return `{"error": "Unsupported type: undefined"}` while still showing "Test Successful".
- Metadata keys: `id` is reserved in Weaviate. Objects with an `id` property are rejected, the Index node still reports `recordsIndexed: 5`. Use `faq_id`.
- Vector Search has a `certainty` input (default 0.85) that is not in the docs table; this flow uses 0.5.
- Vector Search is `nodeType: searchNode`; `vectorSearchNode` does not exist.
- Output references: `{{InstructorLLMNode_1.output.category}}`, `{{searchNode_1.output.searchResults}}`, `{{LLMNode_1.output.generatedResponse}}`.

`01-faq-ingest.md` and `02-triage.md` are the human-readable node-by-node versions.
