# Flow 1: `faq-ingest` (run once)

Lamatic has no "paste records" box on a Vector Store (as of this eval) — data enters through a flow.
Build this once, hit **Test**, and the 5 FAQ entries land in the `faq` store.

```
Code node  ->  Vectorize  ->  VectorDB (Index)
```

Use a plain **API Request** trigger (no inputs needed); we only run it from the editor.

## Node 1 — Code (JavaScript)
Paste `flows/ingest-code-node.js`. It sets:
- `output.texts`     — 5 strings ("<title>. <text>")
- `output.metadata`  — 5 objects `{ id, title, text }` in the same order

## Node 2 — Vectorize
| Field                | Value                                  |
|----------------------|----------------------------------------|
| Texts to vectorize   | `{{codeNode_<N>.output.texts}}`        |
| Embedding Model Name | pick one, e.g. `text-embedding-3-small`|

Remember the embedding model. Search must use the same one.

## Node 3 — VectorDB, action **Index**
| Field               | Value                                       |
|---------------------|---------------------------------------------|
| Vector DB           | `faq`                                       |
| Vectors             | `{{vectorizeNode_<M>.output.vectors}}`      |
| Metadata            | `{{codeNode_<N>.output.metadata}}`          |
| Primary Keys (JSON) | `["id"]`                                    |
| Duplication Records | `overwrite`                                 |

Click **Test**. Expected: index output reports 5 records. Then open Context > `faq` and check the object count.
