# Orchestrator kickoff and review prompts

## Kickoff (paste as your first message in a T3 thread)

```text
Goal: <what you want built>

Work as an orchestrator:
1. Call orchestrator_capabilities.
2. Plan: goal, phases, file ownership map, acceptance check. Show the plan first.
3. Build the shared skeleton and freeze the interfaces.
4. Delegate one task per disjoint file set with delegate_task (mode async), self-contained
   prompts, one writer per file.
5. Work the critical path yourself while they run.
6. When a child finishes, read the result, verify it, and integrate.
7. Report: what is done, the exact verification command and output, and what is outstanding.
   Link child threads with [title](t3-thread://v1/<threadId>).
```

## Review round (one child, adversarial)

```text
ROLE: review

GOAL
Attack the change below and list only load-bearing defects. Do not fix them.

CONTEXT
- Project: <abs path>
- Branch/commit: <ref>
- Diff scope: <paths>
- Original brief: <paste the brief this change was meant to satisfy>

WHAT TO CHECK
- Correctness against the brief above.
- Regressions and edge cases.
- Anything the author claimed but cannot show evidence for.

REPORT BACK
1. Defects, each with file:line and why it is load-bearing.
2. Explicitly: what you could not check.
3. Verdict: ship / fix-first.
```

Each review round is a NEW `delegate_task` call carrying the original brief plus prior findings
and unresolved objections. Track each round by its own `taskId` and a distinct
`clientRequestId`. Do not reuse `childThreadId` to run another review round.
