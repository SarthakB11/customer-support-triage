#!/usr/bin/env bash
# Usage: scripts/triage.sh samples/bug.txt
#        cat email.txt | scripts/triage.sh
# Needs: LAMATIC_ENDPOINT, LAMATIC_API_KEY, LAMATIC_PROJECT_ID, LAMATIC_WORKFLOW_ID
set -euo pipefail

for v in LAMATIC_ENDPOINT LAMATIC_API_KEY LAMATIC_PROJECT_ID LAMATIC_WORKFLOW_ID; do
  [[ -n "${!v:-}" ]] || { echo "missing env var: $v (see .env.example)" >&2; exit 1; }
done

if [[ $# -ge 1 ]]; then EMAIL="$(cat "$1")"; else EMAIL="$(cat)"; fi

QUERY='query TriageTicket($workflowId: String!, $email: String) { executeWorkflow(workflowId: $workflowId, payload: { email: $email }) { status result } }'

BODY="$(python3 - "$QUERY" "$LAMATIC_WORKFLOW_ID" "$EMAIL" <<'PY'
import json, sys
q, wid, email = sys.argv[1], sys.argv[2], sys.argv[3]
print(json.dumps({"query": q, "variables": {"workflowId": wid, "email": email}}))
PY
)"

curl -sS -X POST "$LAMATIC_ENDPOINT" \
  -H "Authorization: Bearer $LAMATIC_API_KEY" \
  -H "Content-Type: application/json" \
  -H "x-project-id: $LAMATIC_PROJECT_ID" \
  -d "$BODY" | python3 -m json.tool
