
---

name: resolve-pr
description: Fetch PR review comments, auto-fix easy issues, surface items needing discussion, reply to reviewers
---

Fetch review comments from a PR, triage them, present a resolution plan for approval, then execute fixes, reply to reviewers, and push.

## Arguments

- `<pr-number>` — PR number (uses current branch PR if omitted)
- `<repo>` — GitHub repo in `owner/repo` format (auto-detected from git remote if omitted)
- `--all` — Process PRs across all repos that have the current branch name (multi-repo workflow)

## Workflow

### Phase 1: Analyze (read-only — no edits)

#### 1. Discover PRs

Always discover PRs and confirm before proceeding — even for single-repo mode.

For the **current project directory**, and additionally for `--all` mode each repo in the session's working directories:

1. Run `git branch --show-current` to get the branch name
2. Use `mcp__github__list_pull_requests` or `mcp__github__pull_request_read` to find the open PR

**Always present a confirmation table to the user before fetching comments:**

Single-repo example:

| Repo | Branch | PR | URL |
|------|--------|----|-----|
| my-backend-service | feature/add-user-api | #42 | <https://github.com/org/my-backend-service/pull/42> |

Multi-repo example (`--all`):

| Repo | Branch | PR | URL |
|------|--------|----|-----|
| my-backend-service | feature/add-user-api | #42 | <https://github.com/org/my-backend-service/pull/42> |
| my-frontend-app | feature/add-user-api | #87 | <https://github.com/org/my-frontend-app/pull/87> |
| my-gateway | feature/add-user-api | #15 | <https://github.com/org/my-gateway/pull/15> |

Ask: "I found these PRs. Proceed with fetching comments?"

The user may remove repos from the list, add specific PR numbers, or correct anything. Only proceed after confirmation.

#### 2. Fetch comments

For each confirmed PR, use the GitHub MCP server:

- **Review comments** (inline code comments with thread context):
  `mcp__github__pull_request_read` with `method: "get_review_comments"`

- **Reviews** (overall review summaries):
  `mcp__github__pull_request_read` with `method: "get_reviews"`

Use pagination (`perPage`, `page`/`after`) if needed for PRs with many comments.

#### 2. Triage each comment

Read the relevant source files to understand context, then classify every comment:

| Category | Criteria | Action |
|----------|----------|--------|
| **Auto-fix** | Clear bug, lint violation, missing import, typo, obvious code smell with a single correct fix | Will fix after approval |
| **Discuss** | Valid concern but multiple solutions, architectural trade-off, or impacts other code | Present options to user |
| **Skip** | Informational, praise, already addressed, or incorrect (explain why wrong) | Note as skipped with reason |
| **Defer** | Valid but out of scope for this PR (e.g. "add more tests", large refactor) | Note as deferred |

**Important**: Before classifying as auto-fix, verify the comment is correct:

- If the comment suggests changing how something works, check the actual codebase behavior first
- Don't blindly trust suggestions that may be based on incorrect assumptions about the codebase
- When a reviewer says "X should be Y", verify that Y is actually correct in this codebase's context

#### 3. Present the resolution plan

Present the FULL resolution plan to the user as a single summary. Do NOT make any edits yet. The plan should include:

**For each repo** (if `--all`), show:

**Auto-fix items** — table with:

- Reviewer & comment summary
- File and line
- What will be changed (specific description of the fix)

**Discussion items** — for each:

- The reviewer's concern (quoted)
- File and line reference
- Available options (2-3 max) with pros/cons
- Your recommendation (if you have one)

**Skip items** — table with:

- Reviewer & comment summary
- Reason for skipping (e.g. "incorrect — codebase uses X pattern", "already addressed in commit abc123")

**Deferred items** — table with:

- Reviewer & comment summary
- Why it's deferred (scope, complexity, risk)

If there are deferred items, suggest at the end:
> Some items were deferred. You can run `/create-followup` to create JIRA tickets for them.

Then ask the user:
> Here's the resolution plan. Please review and let me know:
>
> 1. For discussion items — which option do you prefer? (or suggest your own)
> 2. Any auto-fix items you want to skip or handle differently?
> 3. Anything else you want to add or change?
>
> Once confirmed, I'll apply all fixes, reply to every comment, and push.

#### 4. Wait for user approval

Do NOT proceed to Phase 2 until the user explicitly approves the plan. The user may:

- Pick options for discussion items
- Override auto-fix decisions (e.g. "skip that one" or "defer instead")
- Add additional context or instructions
- Ask to re-triage specific comments

Incorporate all user feedback into the final plan before proceeding.

---

### Phase 2: Execute (edits happen here — only after approval)

#### 5. Apply fixes

For each approved fix:

1. Read the relevant file
2. Apply the fix
3. Verify lint passes (if applicable)
4. Track what was changed

#### 6. Commit & Push

Commit and push BEFORE replying to comments, so reviewers can see the actual changes alongside the replies.

1. Stage changed files per repo
2. Commit with message: `fix(<scope>): address PR review comments`
3. Include `Co-Authored-By` trailer with the actual model name from the session context
4. Push to remote

If working across multiple repos (`--all`), commit and push each repo separately.

#### 7. Draft and confirm replies

Before posting, present ALL draft replies to the user in a table showing what issue each reply addresses:

| # | Reviewer | Issue | Reply |
|---|----------|-------|-------|
| 1 | @gemini-code-assist | Missing email validation | Fixed — added email format validation before saving |
| 2 | @Copilot | Function should be async | Investigated — only synchronous operations, async unnecessary |
| 3 | @Copilot | Add rate limiting | Deferring — endpoint is internal-only, will revisit when public |

Ask: "Post these replies to GitHub? You can edit any reply before posting."

The user may adjust wording, add context, or approve as-is. Only post after confirmation.

#### 8. Post replies to PR comments

Reply to EVERY review comment on the PR with the confirmed resolution. This is critical for reviewer visibility.

Use `mcp__github__add_reply_to_pull_request_comment` for each comment:

- `owner`: repo owner
- `repo`: repo name
- `pullNumber`: PR number
- `commentId`: the review comment ID
- `body`: the reply message

**Reply format by category:**

All replies must start with `> Reply by Claude` on its own line (blockquote), followed by a blank line, then the `@mention` and message. This makes it clear the response was AI-assisted.

- **Auto-fix**: "> Reply by Claude\n\n@{reviewer} Fixed — {brief description of what was changed}"
- **Skip (incorrect)**: "> Reply by Claude\n\n@{reviewer} Investigated — {explanation of why the suggestion doesn't apply, citing specific code/patterns}"
- **Skip (already addressed)**: "> Reply by Claude\n\n@{reviewer} Already addressed in {commit/change}"
- **Defer**: "> Reply by Claude\n\n@{reviewer} Valid concern. Deferring — {reason}. Will track as a follow-up."
- **Discuss (after user decision)**: "> Reply by Claude\n\n@{reviewer} {explanation of chosen approach and why}"

**Important tagging rules:**

- Always `@mention` the reviewer (e.g. `@gemini-code-assist`, `@Copilot`) so they get notified
- Keep replies concise but include enough context for the reviewer to understand the resolution
- For bot reviewers (Gemini, Copilot), tagging triggers them to re-evaluate

## Guidelines

- **Plan first, edit later**: Never make edits before the user approves the resolution plan.
- **Don't over-fix**: Only fix what the reviewer asked about. Don't refactor surrounding code.
- **Verify before fixing**: Read the actual code and codebase patterns before applying a suggestion. Reviewers can be wrong.
- **Respect codebase conventions**: When a reviewer suggests a pattern that conflicts with existing codebase conventions, flag it as a discussion item rather than auto-fixing.
- **Group related comments**: If multiple reviewers mention the same issue, consolidate into one fix.
- **Be transparent**: Always show what will be changed and why before doing it.
- **Always reply**: Every review comment must get a reply. Don't leave reviewers hanging.
