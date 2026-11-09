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

1. **Everything starts with a token.** Each call needs a tenant access token that expires after 2 hours, so a script fetches a fresh one before it does anything else.
2. **A bot only sees what it has been added to.** My first `chats` call returned an empty list because the bot wasn't in the group. After adding scopes or events, I also had to publish a new app version before they took effect.
3. **The IDs matter.** I took the Base token and table ID from the Grid view URL. My first copy came from the Workflow page, so the table ID was wrong.
4. **Data comes back in a different shape from how it goes in.** I wrote text fields as plain strings, but reading them back returned rich-text lists.
5. **Blank records are a real edge case.** Clicking "+" in the Base created empty rows, which I could see in the data. A workflow should check required fields are filled before it acts.
6. **Push is different from pull.** The app, the subscribed event and the bot in the group all had to be the same app. My first listener was on a second app the CLI created, so it heard nothing until I pointed it at the right one.
7. **Not everything worked first time.** My no-code Base workflow was built and activated but showed no runs in the Activity Log, and I did not find the cause. The same flow worked through the API.

The pattern matches a payments integration: authenticate, send a request, record the state, update it, receive an event. This lab does not cover retries or idempotency, which I would add next.
