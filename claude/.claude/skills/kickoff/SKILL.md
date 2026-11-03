---
name: kickoff
description: Turn a Jira card into an approved plan, a Kanzo project with tasks, and a fresh git worktree to build it in.
disable-model-invocation: true
argument-hint: <JIRA-KEY or URL>
---

# Kickoff

Takes **one Jira card** from ticket to the first line of work. Six steps, in order. Two gates stop for the user: plan approval (step 2) and board review (step 5). Nothing after a gate starts until the user says so.

## 1. Read the card

Parse the key from `$ARGUMENTS` (`DTS-3259`, or the last `ABC-123` in a `…/browse/ABC-123` or `selectedIssue=ABC-123` URL). No argument → ask for one.

Fetch it with `mcp__claude_ai_Atlassian__getJiraIssue` (load via ToolSearch). Read summary, description, acceptance criteria, linked issues and comments. Fetch the parent epic and any linked card the description leans on.

Done when you can state, in one sentence each: what the card asks for, how to tell it is done, and which repo it lands in (the current repo unless the card says otherwise).

## 2. Plan in plan mode

Call `EnterPlanMode`. Explore the repo the way the project's `CLAUDE.md` says to (conventions doc, `task` targets, graft if indexed) and write the plan to the plan file:

- **Goal** — the card's ask, and its acceptance criteria as checkable bullets.
- **Approach** — the design, the files it touches, and why this way.
- **Tasks** — an ordered list of **tracer bullets**: each task a thin, independently verifiable slice with its own done-check. Mark any step only the user can do (a grant, a console change, a sign-off) as **human**.
- **Branch** — `<type>/<KEY>-<kebab-title>`, type ∈ `feat|fix|tech|revert`, title from the card summary, ≤ 6 words.
- **Risks / open questions.**

Done when every acceptance criterion maps to at least one task.

### Goldfish review

Before exiting, have a **goldfish** review the plan: a fresh `code-explorer` subagent (read-only) that has none of this conversation. Its prompt holds only:

- the card, pasted verbatim: key, URL, summary, description, acceptance criteria, and any comment the plan relies on
- the plan file's absolute path and the repo root
- the brief below, unchanged

Leave out your reasoning, the options you rejected and the parts you're unsure of. The goldfish is useful because it reads the plan cold.

> You are reviewing an implementation plan with fresh eyes. Read the plan file and the Jira card below, then check the plan against the actual code in the repo. Report findings only — do not rewrite the plan. For each finding give: the plan section, what is wrong or missing, the evidence (`file:line` or the card's words), and a severity (blocker / should-fix / nit). Check:
> 1. Every acceptance criterion maps to a task whose done-check would prove it.
> 2. Every claim the plan makes about the code (a file, function, config, convention) is true in the repo.
> 3. Each task is a thin slice that can be verified on its own, and the order works.
> 4. Assumptions the plan relies on but never states, and anything the card asks for that the plan dropped.
> 5. Conventions in the repo's `CLAUDE.md` / contributor docs the plan would break.
> If a check passes, say so in one line. End with the count of findings by severity.

Treat each finding as a claim to verify, not a verdict. Fix the plan for every confirmed one. Append a **Goldfish review** section to the plan listing each finding as *fixed*, *rejected (why)* or *open question*. Done when every finding has one of those three outcomes. Then call `ExitPlanMode`. If the user rejects, revise and exit again; re-run the goldfish only if the revision changes the Approach or Tasks.

## 3. Create the Kanzo project

`mcp__kanzo__list_projects` first. If a project for this key exists, reuse it and say so.

Otherwise `mcp__kanzo__create_project`:
- `slug`: the key lowercased, e.g. `dts-3259`
- `name`: `<KEY> <card summary>`
- `repo`: the target repo's `owner/repo` (from `git remote get-url origin`)

`mcp__kanzo__link_repo` any extra repo the plan touches.

## 4. Create the tasks

One `mcp__kanzo__create_task` per plan task, in plan order, `project` = the slug:
- `title`: imperative, short. Prefix with its order (`1. …`) so the board reads in sequence.
- `description` (Markdown): what to do, the done-check, and `Jira: <card URL>`.
- `human: true` for the human tasks.
- `tags`: the key, plus one area tag if useful.

Done when the board holds every plan task, and nothing else.

## 5. Ask for review

Post the board as a short list (`slug#n  title`, human tasks marked) with the branch name, then `AskUserQuestion`:

- **Approve** — go to step 6.
- **Adjust** — apply the user's edits to the tasks (`mcp__kanzo__update_task` / `create_task` / `delete_task`), show the board again, ask again.
- **Stop** — leave the project and tasks as they are; end here.

## 6. Start in a new worktree

From the target repo's root:

```bash
git fetch origin
git worktree add .claude/worktrees/<KEY-lower> -b <branch> origin/<default-branch>
```

Then `EnterWorktree` with `path` set to that directory. If the branch already exists, stop and ask rather than reuse or reset it.

Run the repo's one-time setup only if the project's `CLAUDE.md` calls for it in a fresh checkout. Then take the first non-human task: `mcp__kanzo__update_task` it to `doing`, and build it. Keep the board current as you go: a comment on what each task changed, `review` when a task is finished or blocked.
