# Support-ticket triage on Lamatic.ai

A small, real flow built in ~20 minutes to evaluate [Lamatic.ai](https://lamatic.ai).

**Input:** a customer email (text).
**Output:** `{ "category": "bug" | "billing" | "feature_request", "confidence": 0-1, "reply": "..." }`

## Flow (Lamatic terms)

```
API Trigger (email)
  -> Generate JSON        classify: category + confidence
  -> Vector Search        top 2 snippets from the `faq` Vector Store
  -> Generate Text        draft reply in my tone, grounded on the 2 snippets
  -> End                  return { category, confidence, reply }
```

The `faq` Vector Store (Context > Add New Store) holds the 5 entries in `faq/faq.json`.

## Call it

```bash
cp .env.example .env   # fill in from Studio: Settings > API Keys / Project, Flow > Connect
set -a; source .env; set +a
scripts/triage.sh samples/bug.txt
```

The raw GraphQL query is in `graphql/execute.graphql`.

## Repo layout

- `faq/faq.json` — the 5 FAQ entries ingested into the vector store
- `samples/` — three test emails (bug, billing, feature request)
- `graphql/execute.graphql` — the `executeWorkflow` query
- `scripts/triage.sh` — one-shot curl client
- `notes/EXPERIENCE.md` — what worked, what didn't, one product improvement
- `notes/WHY-LAMATIC.md` — why a Python/LangGraph engineer would work on this
