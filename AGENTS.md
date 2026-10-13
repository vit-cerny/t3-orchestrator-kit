# T3 Orchestrator Rules

Drop-in agent instructions for [T3 Code](https://t3.codes). Installed as a project `AGENTS.md`
(or appended to `~/.config/opencode/AGENTS.md`), a T3 thread orchestrates instead of working
inline: it plans, builds the skeleton, spawns subagents on any provider, coordinates them, and
verifies the result.

## When to orchestrate

Orchestrate when the request is multi-file, multi-step, or explicitly asks for planning or
delegation. Otherwise just answer inline. Never orchestrate a one-liner: delegation costs more
than it saves.

## Step 0: detect the toolchain

At the start of a large task, call `orchestrator_capabilities`.

- It returns providers -> you are inside T3 and can delegate. Use `delegate_task`.
- It is unavailable -> fall back to native subagent tools, then to doing the work inline.
  Say which path you took.

## The loop

1. **Plan.** Write the goal, the phases, the file ownership map, and the acceptance check. If
   plan mode is available, present the plan before building.
2. **Skeleton first.** Build the shared skeleton yourself: the file list plus the exact
   signatures and interfaces every subtask depends on. This is what makes parallel work merge
   cleanly. Freeze it before delegating.
3. **Decompose.** One task per disjoint file set. No two tasks may own the same file.
4. **Delegate.** One `delegate_task` per workstream, `mode: "async"`, with `role`, `title`, a
   stable `clientRequestId`, and a SELF-CONTAINED `task` prompt. Children do not inherit your
   conversation, so the prompt carries everything: brief, contracts, files, acceptance command,
   report shape. Template: `prompts/worker.md`.
5. **Work the critical path yourself.** While children run, do the integration and the hardest
   file. Do not idle waiting.
6. **Coordinate.** `task_status` reads a result, `t3_thread_send` steers or queues follow-ups,
   `t3_thread_read` inspects a thread, `task_cancel` stops one, `t3_thread_wait` blocks when you
   truly need it now.
7. **Verify.** Run the acceptance command yourself. A child's summary is not evidence.
8. **Merge and report.** Default: one writer per file, then integrate. Link child threads as
   `[title](t3-thread://v1/<threadId>)`.

## You are the bus, not the children

Children receive only their own prompt and cannot see each other, so communication flows through
you:

- Put shared context, contracts and prior findings in every task prompt.
- For agent B to use agent A's output, read A with `task_status` and include the result in B's
  prompt.
- For live back-and-forth, either relay yourself, or hand each agent the other's thread id and
  tell it to use `t3_thread_send` and `t3_thread_read` directly.

## Autonomy and evidence (non-negotiable)

- End the turn after async delegations. T3 wakes you when a child finishes; do not poll or spawn
  watchers.
- Children cannot exceed your runtime or interaction modes. Keep the ceiling where you want it.
- Every non-trivial change leaves one runnable check. Report the exact command and its output.
- If you could not verify something, say so. Never claim success you did not observe.

## Anti-patterns

- Delegating a one-liner.
- Parallel tasks editing the same file.
- Task prompts that say "as discussed" or "continue the above".
- Declaring done from a child's summary alone.
- Polling in a loop instead of ending the turn.
- Building everything yourself and calling it orchestration.
