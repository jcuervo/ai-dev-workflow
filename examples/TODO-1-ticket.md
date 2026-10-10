# TODO-1 — Todo lists with due dates

Made-up ticket for the dry run. Paste everything below the line when `/ticket-init` asks for the ticket.

---

**Summary:** Users can manage a simple todo list with due dates

**Type:** Story · **Reporter:** Product Owner

**Description**
We want a first version of the todo list. Users need to add tasks, see what's due, and tick things off. Overdue items should stand out so nothing is missed.

**Requirements**
- A todo has a title and an optional due date.
- The list page shows all todos, with incomplete ones first.
- Users can mark a todo as done, and undo that.
- Overdue todos are highlighted.
- Users can delete a todo.

**Acceptance criteria**
1. Given I'm on the todo list, when I add a todo with a title and an optional due date, then it appears in the list.
2. A todo can't be saved without a title; I see an error message explaining why.
3. Incomplete todos are listed before completed ones; within each group, todos are ordered by due date, earliest first.
4. When I mark a todo as done, it shows as completed and moves below the incomplete todos. I can mark it as not done again.
5. Todos whose due date has passed and that aren't done are highlighted as overdue.
6. When I delete a todo, it's removed from the list.
