# Flow 2: `support-ticket-triage`

```
API Request trigger (email)
  -> Generate JSON      category + confidence
  -> Vector Search      top 2 from `faq`
  -> Generate Text      reply in my tone
  -> API Response       { category, confidence, reply }
```

Node IDs (`triggerNode_1`, `InstructorLLMNode_1`, `searchNode_1`, `LLMNode_1`) are assigned by Studio. The exact config that ran is `support-ticket-triage.yaml`. Type `{{` in any field to pick them from the variable selector instead of typing IDs.

## Trigger — API Request

Advanced schema:

```json
{ "email": "string" }
```

Downstream reference: `{{triggerNode_1.output.email}}`. This name must match the `payload: { email: ... }` key in `graphql/execute.graphql`.

## Node A — Generate JSON (classify)

| Field                 | Value                                                                          |
| --------------------- | ------------------------------------------------------------------------------ |
| Generative Model Name | any chat model with a credential set up (e.g. gpt-4o-mini)                     |
| System Prompt         | `You triage customer support emails for a SaaS product. Return only the JSON.` |
| User Prompt           | see below                                                                      |
| Output Schema         | see below                                                                      |

User Prompt:

```
Classify this customer email into exactly one category: bug, billing, feature_request.
confidence is a number between 0 and 1 for how sure you are.

Email:
{{triggerNode_1.output.email}}
```

Output Schema:

```json
{
  "type": "object",
  "properties": {
    "category": {
      "type": "string",
      "enum": ["bug", "billing", "feature_request"]
    },
    "confidence": { "type": "number" }
  },
  "required": ["category", "confidence"]
}
```

Outputs: `{{InstructorLLMNode_1.output.category}}`, `{{InstructorLLMNode_1.output.confidence}}`

## Node B — Vector Search (`nodeType: searchNode`)

| Field                                  | Value                            |
| -------------------------------------- | -------------------------------- |
| Search Query                           | `{{triggerNode_1.output.email}}` |
| Vector DB                              | `faq`                            |
| Limit                                  | `2`                              |
| (Embedding model, if the field exists) | same model as in faq-ingest      |

Output: `{{searchNode_1.output.searchResults}}`

## Node C — Generate Text (reply)

System Prompt (tone; edit to taste):

```
You are <YOUR NAME>, replying to a support email. Short, direct, first person. No filler,
no "we apologise for any inconvenience". Use only facts from the FAQ snippets; if they
don't cover it, say you'll check and come back within a day. Max 120 words. Sign off with
your first name.
```

User Prompt:

```
Category: {{InstructorLLMNode_<A>.output.category}}

FAQ snippets (only source of facts):
{{vectorSearchNode_<B>.output.searchResults}}

Customer email:
{{triggerNode_1.output.email}}

Write the reply.
```

Output: `{{LLMNode_1.output.generatedResponse}}`

## API Response node

Output mapping:

```json
{
  "category": "{{InstructorLLMNode_<A>.output.category}}",
  "confidence": "{{InstructorLLMNode_<A>.output.confidence}}",
  "reply": "{{LLMNode_<C>.output.generatedResponse}}"
}
```

Save -> **Test** with `samples/bug.txt` -> **Deploy**.
