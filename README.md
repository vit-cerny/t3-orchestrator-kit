# T3 orchestrator kit

Make a [T3 Code](https://t3.codes) thread orchestrate: you type one prompt, it plans, builds a
skeleton, spawns subagents on any provider, coordinates them, verifies, and merges.

This is not a plugin and not a fork. T3 already ships the machinery; this kit is the operating
rules that make your agent actually use it.

## The goal, mapped to T3's real tools

| What you want | The T3 tool that does it |
| --- | --- |
| "It starts delegating the work" | `delegate_task` - creates a T3-owned child thread on any provider instance |
| "Creating subagents" | `delegate_task` with `role`: implementation / research / review / design / test / general |
| "Planning" | `interactionMode: "plan"` and the proposed-plan card, driven by the rules in `AGENTS.md` |
| "Making the skeleton" | The orchestrator builds shared interfaces first, then delegates (see `AGENTS.md` step 2) |
| "All agents can talk to each other" | `t3_thread_send` + `t3_thread_read` (agent to agent) and `task_status` (child to parent), with T3 as the hub |
| "T3 being master manager" | `orchestrator_capabilities`, `task_status`, `task_cancel`, `t3_thread_wait`, `t3_thread_launch`, `create_threads` |

T3 does not auto-swarm. Delegation happens because the agent chooses to call `delegate_task`,
which is exactly what these rules make it do.

## Install

Project scope (threads opened in that project orchestrate):

```powershell
powershell -ExecutionPolicy Bypass -File install.ps1 -Target C:\path\to\project
```

Global scope (every thread, appends one delimited block to `~/.config/opencode/AGENTS.md`):

```powershell
powershell -ExecutionPolicy Bypass -File install.ps1 -Scope Global
```

Both back up first and are idempotent. Project scope writes `AGENTS.md`; global scope appends a
block between `<!-- t3-orchestrator-kit:start -->` and `<!-- t3-orchestrator-kit:end -->` that
you can delete to undo.

## Use

Open a T3 thread and paste the kickoff prompt from `prompts/orchestrator.md`. Or just describe a
multi-file task; the installed rules make the agent plan and delegate on its own.

## How agents actually talk

Be precise about this, because it is the part people get wrong:

- A child receives **only its own task prompt**. Parent history is not copied, and children
  cannot see each other.
- So T3 is the bus. The orchestrator relays: it reads a child's result with `task_status` and
  puts it into the next child's prompt.
- For live agent-to-agent messages, the orchestrator hands each agent the other's thread id and
  tells it to use `t3_thread_send` and `t3_thread_read`. Agents reference threads as
  `[title](t3-thread://v1/<threadId>)`.

## Files

- `AGENTS.md` - the operating rules (the payload).
- `prompts/orchestrator.md` - kickoff prompt and the adversarial review round.
- `prompts/worker.md` - the self-contained brief a child needs.
- `install.ps1` - project or global install.

## Limits (no evidence, no claim)

- Verified in the T3 source: the tool surface, that children get prompt-only context, and that
  each provider with a V2 adapter can run child tasks (`docs/orchestration-v2/orchestrator-mcp-server.md`).
- Not verified by this repo: your provider's child-task success rate, cost, and latency. Those
  depend on the harness you delegate to.
- Delegation costs tokens. Do not orchestrate work a single agent finishes in one file.

## License

MIT. See [LICENSE](LICENSE).
