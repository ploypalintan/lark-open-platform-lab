#!/usr/bin/env bash
# Helper for the Lark Open Platform lab. Reads secrets from .env (never committed).
# Usage: ./lark_lab.sh check | chats | send "text" | create "Store" "Issue" | search | update RECORD_ID "Status"
set -euo pipefail
cd "$(dirname "$0")"
[ -f .env ] || { echo "Missing .env: copy .env.example to .env and fill it in."; exit 1; }
set -a; . ./.env; set +a
BASE="https://open.larksuite.com/open-apis"

get_token() {
  curl -s -X POST "$BASE/auth/v3/tenant_access_token/internal" \
    -H "Content-Type: application/json" \
    -d "{\"app_id\":\"$APP_ID\",\"app_secret\":\"$APP_SECRET\"}" \
  | python3 -c "
import sys, json
d = json.load(sys.stdin)
print(d['tenant_access_token'] if d.get('code') == 0 else 'ERROR ' + json.dumps(d))
"
}

TOKEN="$(get_token)"
case "$TOKEN" in
  ERROR*) echo "$TOKEN"; exit 1;;
esac

pretty() { python3 -m json.tool; }

cmd="${1:-}"; shift || true
case "$cmd" in
  check)
    echo "Token OK (starts with ${TOKEN:0:4}..., valid up to 2 hours)";;
  chats)
    curl -s "$BASE/im/v1/chats" -H "Authorization: Bearer $TOKEN" | pretty;;
  send)
    BODY="$(python3 -c "
import json, sys
print(json.dumps({'receive_id': sys.argv[1], 'msg_type': 'text',
                  'content': json.dumps({'text': sys.argv[2]})}))
" "$CHAT_ID" "${1:?text required}")"
    curl -s -X POST "$BASE/im/v1/messages?receive_id_type=chat_id" \
      -H "Authorization: Bearer $TOKEN" -H "Content-Type: application/json" \
      -d "$BODY" | pretty;;
  create)
    BODY="$(python3 -c "
import json, sys
print(json.dumps({'fields': {'Store': sys.argv[1], 'Issue': sys.argv[2], 'Status': 'New'}}))
" "${1:?store required}" "${2:?issue required}")"
    curl -s -X POST "$BASE/bitable/v1/apps/$BASE_APP_TOKEN/tables/$BASE_TABLE_ID/records" \
      -H "Authorization: Bearer $TOKEN" -H "Content-Type: application/json" \
      -d "$BODY" | pretty;;
  search)
    curl -s -X POST "$BASE/bitable/v1/apps/$BASE_APP_TOKEN/tables/$BASE_TABLE_ID/records/search" \
      -H "Authorization: Bearer $TOKEN" -H "Content-Type: application/json" \
      -d '{}' | pretty;;
  update)
    BODY="$(python3 -c "
import json, sys
print(json.dumps({'fields': {'Status': sys.argv[1]}}))
" "${2:?status required}")"
    curl -s -X PUT "$BASE/bitable/v1/apps/$BASE_APP_TOKEN/tables/$BASE_TABLE_ID/records/${1:?record id required}" \
      -H "Authorization: Bearer $TOKEN" -H "Content-Type: application/json" \
      -d "$BODY" | pretty;;
  *)
    echo "Usage: $0 check | chats | send \"text\" | create \"Store\" \"Issue\" | search | update RECORD_ID \"Status\""
    exit 1;;
esac
