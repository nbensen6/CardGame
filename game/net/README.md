# /net — transport-agnostic networking

Keep the netcode transport behind an interface (CLAUDE.md §5, §8) so a phone
client or a web/cast client can attach later without touching game logic.

- Authoritative host/server model (CLAUDE.md §4.4). One player hosts, or a
  headless server build.
- `/net` moves state; it does not own game rules (those live in `/core`).
- Empty until build step 2 (the client/server split).
