# Support-ticket triage on Lamatic.ai

A small, real flow built to evaluate [Lamatic.ai](https://lamatic.ai): classify a customer email, pull the two most
relevant snippets from a five-entry FAQ (RAG over a Vector Store), draft a reply in my tone, return JSON, expose it
through Lamatic's GraphQL API, call it from curl.

**Input:** a customer email (text).
**Output:** `{ "category": "bug" | "billing" | "feature_request", "confidence": 0-1, "reply": "..." }`

## The flows (Lamatic terms)

```
faq-ingest (run once)
  API Request -> Code (5 FAQ entries) -> Vectorize (gemini-embedding-001) -> VectorDB Index -> API Response
                                                                             into Vector Store "faq"

support-ticket-triage
  API Request (email) -> Generate JSON (category, confidence)  \
                      -> Vector Search over "faq", limit 2      -> Generate Text (reply, my tone) -> API Response
```

Both flows are in `flows/` as the exact low-code YAML Studio serialises (paste into Flow > Config), plus
node-by-node notes. Models: `gemini-3.5-flash-lite` for both LLM nodes, `gemini-embedding-001` for embeddings.

## Call it

```bash
cp .env.example .env      # endpoint, project id, flow id from Flow > Setup; key from Settings > API Keys
set -a; . ./.env; set +a
scripts/triage.sh samples/billing.txt
```

```json
{
  "data": { "executeWorkflow": { "status": "success", "result": {
    "category": "billing",
    "confidence": 0.99,
    "reply": "...",
    "requestId": "..."
  } } }
}
```

The raw query is in `graphql/execute.graphql`; the payload key (`email`) must match the trigger's schema.

## Repo layout

- `flows/` — exported flow YAML, node-by-node notes, the ingest Code node
- `faq/faq.json` — the 5 FAQ entries
- `samples/` — three test emails (bug, billing, feature request)
- `graphql/execute.graphql`, `scripts/triage.sh` — the curl client
- `notes/EXPERIENCE.md` — what worked first time, what did not (with exact errors), one product improvement
- `notes/WHY-LAMATIC.md` — what I would work on, and one thing I could build for them
