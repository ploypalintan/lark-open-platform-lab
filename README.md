# Lark Open Platform Lab

A small hands-on lab I built to learn how Lark's Open Platform works end to end: authenticate, create a record, notify a group, read it back, update it, and receive events.

This is a learning project, not production software. Everything marked done in `LOG.md` was run by me; anything unchecked has not been done yet.

## The workflow (request to resolution)

Illustrative scenario: a store reports an issue, it is recorded, a group is notified, a manager approves, and the record is closed.

| Step | Direction | Call | Script command |
|---|---|---|---|
| 1. Authenticate | me -> Lark | `POST /auth/v3/tenant_access_token/internal` | `./lark_lab.sh check` |
| 2. Find the group | me -> Lark | `GET /im/v1/chats` | `./lark_lab.sh chats` |
| 3. Notify | me -> Lark | `POST /im/v1/messages?receive_id_type=chat_id` | `./lark_lab.sh send "text"` |
| 4. Create record | me -> Lark | `POST /bitable/v1/apps/{app}/tables/{table}/records` | `./lark_lab.sh create "Store" "Issue"` |
| 5. Read back | me -> Lark | `POST .../records/search` | `./lark_lab.sh search` |
| 6. Update | me -> Lark | `PUT .../records/{record_id}` | `./lark_lab.sh update REC_ID "Approved"` |
| 7. Push | Lark -> me | event subscription (`lark-cli event +subscribe`) | see LOG.md |

It is an event-driven, human-in-the-loop business-process workflow, not a payments or settlement workflow. Concerns I design for: token expiry (2 hours), duplicate events (de-duplicate by `event_id`), rate limits (5 messages per second per user or group), and idempotency (`uuid` fields).

## Setup

1. Create a custom app at https://open.larksuite.com/app (international Lark, not Feishu) and add the Bot feature.
2. Enable scopes: `im:message`, `im:message:send_as_bot`, `im:chat`, and Base read/write.
3. Release the app version, add the bot to a test group chat, and add the app as a collaborator on the Base.
4. `cp .env.example .env` and fill in the values. `.env` is git-ignored. Never commit secrets.
5. `chmod +x lark_lab.sh`

Requires `curl` and `python3`.

## Security

- Secrets live only in `.env` (ignored by git).
- Redact tokens, app secrets, chat IDs and record IDs before pasting output into `LOG.md`.

## What I learned

(Fill in after running the lab.)
