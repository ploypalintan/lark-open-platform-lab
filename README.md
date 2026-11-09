# Lark Open Platform Lab

A small hands-on lab to learn how Lark's Open Platform works end to end: authenticate, notify a group, create, read and update Base records, and receive events pushed by Lark.

**Scenario:** a store reports an issue, it is recorded in a Base, a group is notified, a manager approves, and the record is updated. It is an event-driven, human-in-the-loop business workflow, not a payments or settlement flow.

> Learning project, not production software. Every step marked done was run by me against my own Lark workspace. Built with help from Claude (an AI assistant); I ran, debugged and documented each step myself. See [`LOG.md`](LOG.md) for the step-by-step record.

## How the pieces fit

```mermaid
sequenceDiagram
    participant Me as My Mac (Terminal)
    participant API as Lark Open Platform
    participant Base as Base "Store issues"
    participant Group as Group "Store Ops Test"

    Me->>API: 1. Get tenant access token (valid 2 hours)
    Me->>API: 2. List chats the bot is in
    Me->>API: 3. Send message to group
    API-->>Group: Message from my app's bot
    Me->>API: 4. Create record
    API-->>Base: New row
    Me->>API: 5. Search records (read back)
    Me->>API: 6. Update record status
    Group-->>API: Someone @mentions the bot
    API-->>Me: 7. Event pushed over a persistent connection
```

## What I ran

| # | Step | Call | Command | Result |
|---|---|---|---|---|
| 1 | Authenticate | `POST /auth/v3/tenant_access_token/internal` | `./lark_lab.sh check` | ✅ Token OK |
| 2 | Find the group | `GET /im/v1/chats` | `./lark_lab.sh chats` | ✅ After adding the bot to the group |
| 3 | Notify the group | `POST /im/v1/messages?receive_id_type=chat_id` | `./lark_lab.sh send "text"` | ✅ Message arrived from the app |
| 4 | Create a record | `POST /bitable/v1/apps/{app}/tables/{table}/records` | `./lark_lab.sh create "Store" "Issue"` | ✅ Row appeared in the Base |
| 5 | Read it back | `POST .../records/search` | `./lark_lab.sh search` | ✅ |
| 6 |
