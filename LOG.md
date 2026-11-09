# Lab log

Rule: tick a box only when you actually did it. Redact tokens, secrets, chat IDs and record IDs before pasting output.

## Path A: inside Lark (no code)

- [x] Signed up and created a workspace (Mon 9 Nov 2026), Lark desktop app installed (Apple chip build)
- [ ] Created a Base "Store Issues" with fields Store, Issue, Status (New / Approved / Closed)
- [ ] Added a Form view and submitted a test row
- [ ] Built a Base automation: record created -> send message to a group
- [ ] Submitted another entry and saw the message arrive

Notes / what was confusing:

## Path B: API from Terminal

- [x] Created a custom app at open.larksuite.com/app, added the Bot, enabled scopes, released it
 Result: Token OK, valid up to 2 hours. Credentials are stored in .env (git-ignored), never in this log.
- [x] `./lark_lab.sh check` (token OK)
- [x] `./lark_lab.sh chats` (found my test group)
- [x] `./lark_lab.sh send "Hello from my terminal"` (message arrived)
- [x] `./lark_lab.sh create "Woodlands 03" "Chiller fault"` (record created)
- [x] `./lark_lab.sh search` (read it back)
- [x] `./lark_lab.sh update REC_ID "Approved"` (status changed in Base)
- [ ] Received an event via `lark-cli event +subscribe --event-types im.message.receive_v1`

For each step, paste the redacted result and any error below.

### Errors and fixes

| Step | Error | Cause | Fix |
|---|---|---|---|
| | | | |

## Key takeaways (in my own words)

1.
2.
3.

## Path B notes
- chats: the list was empty at first because the bot was not in the group. I added it in Settings > Bots and it worked. Chat ID: [redacted]
- send: message arrived in the group from my app (sender_type: app). Message ID: [redacted]
- create: record added to the Base with a single-record API call (POST .../records). It returned success and the row appeared in the Grid view. Record ID: [redacted]
- search: read the table back (POST .../records/search). Text fields return as rich-text lists, not plain strings. Also found two empty records created by the grid UI.
- update: changed a record status with PUT .../records/{record_id}. Only the Status field was sent; the other fields were left unchanged. Record ID: [redacted]
- confusing: it was not clear what the CLI was listening to. Answer: one app, over an open connection, for the events subscribed in the console, only for chats where that app bot is present. The listener app, the subscribed app and the bot in the group must all be the same app.
