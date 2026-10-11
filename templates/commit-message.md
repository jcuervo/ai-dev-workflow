# Commit message template

Used by `/build-task` (task commits) and `/resolve-review` (review fixes). Ticket key and a colon; no task number, no brackets.

```
<KEY>: <Summary in the imperative mood>

<Optional body: what changed and why, wrapped at ~72 characters.
Leave it out when the summary says it all.>
```

## Rules

- **Subject:** `<KEY>: ` (the ticket key, a colon and a space) plus an imperative summary ("Add", "Fix", "Remove", not "Added" or "Adds"). Aim for **50 characters, 72 at most**. No trailing period.
- **Blank line** between the subject and the body.
- **Body (optional):** explain **why**, plus anything the diff doesn't show (a trade-off, a constraint, a follow-up). Wrap at about 72 characters. Don't list the files changed; the diff shows that.
- **No trailers:** no `Co-Authored-By`, no "Generated with…". A hook blocks them.
- **One task, one commit set.** The task-to-commit link lives in `tasks.md` (**Commits** field), not in the message.

## Examples

```
TODO-1: Add todos table
```

```
TODO-1: Order todos by completion, due date and creation time

Undated todos sort last within each group. SQLite sorts NULLs first,
so the scope orders by `due_on IS NULL` explicitly.
```

Review fix (from `/resolve-review`):

```
TODO-1: Address review: move overdue rule into Todo#overdue?
```
