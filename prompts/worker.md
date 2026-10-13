# Worker brief template

Copy into `delegate_task.task`. Children do not inherit your conversation, so this prompt must
stand alone. Keep it short and specific.

```text
ROLE: <implementation | research | review | design | test | general>

GOAL
<one sentence: the outcome this task must produce>

CONTEXT (you cannot see the parent thread)
- Project: <abs path>
- Skeleton already in place: <files and the exact signatures/interfaces you must match>
- Related work: <what other agents are doing, and what they are NOT allowed to touch>

FILES YOU OWN (do not edit anything else)
- <path>
- <path>

CONSTRAINTS
- Match the existing style in the files you touch.
- Do not add dependencies unless listed here: <...>
- Single writer: <path> is yours alone.

ACCEPTANCE (run this and paste the output)
- Command: <exact command>
- Pass means: <observable condition>

REPORT BACK
1. Status: done / blocked.
2. Files changed (paths).
3. The exact command you ran and its output.
4. Anything you could not verify.
```

Rules of thumb:

- If the task needs context you did not put in the prompt, the brief is wrong, not the child.
- If two tasks need the same file, merge them into one task.
- If the acceptance check cannot be a single command, ask for the smallest observable evidence.
