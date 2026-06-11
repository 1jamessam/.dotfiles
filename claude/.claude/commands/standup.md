---
description: Summarize recent work across GitHub + local repos for a standup
allowed-tools: Bash(gh:*), Bash(git:*), Bash(date:*), Bash(find:*), Bash(test:*), Bash(ls:*)
---

Generate a standup-ready summary of my recent work.

## Determine the window

Default: yesterday → today. If today is Monday, use Friday → today instead (cover the weekend gap).
If `$ARGUMENTS` is non-empty, interpret it as the window (e.g. "last 3 days", "since 2026-04-20") and override.

Compute `SINCE` (YYYY-MM-DD) and `TODAY` using `date`.

## Collect (run these in parallel)

1. **GitHub PRs updated in window**:
   `gh search prs --author @me --updated ">=$SINCE" --json repository,title,number,state,url,updatedAt --limit 50`

2. **GitHub commits in window**:
   `gh api search/commits --method GET -f q="author:@me committer-date:>=$SINCE" -f per_page=50 --jq '.items[] | {message: .commit.message, repo: .repository.full_name, sha: .sha[:7], url: .html_url}'`

3. **Local WIP** — discover git repos via `find ~/Developer -maxdepth 2 -name .git -type d` and include `~/.dotfiles` if it is a git repo. For each repo run in parallel:
   - `git -C <repo> status --short` (dirty files)
   - `git -C <repo> log '@{upstream}..HEAD' --oneline 2>/dev/null` (unpushed commits; silently skip repos without upstream)

   Only include repos with non-empty output from either command.

## Format

```markdown
# Standup — {TODAY}

### Shipped (since {SINCE})
- **{repo}** — {merged PR title} (#{num}) {url}

### In progress
- **{repo}** — {open PR title} (#{num})
- **{repo}** — {N} unpushed commits

### Local WIP
- **{repo}** — {short summary of dirty files, e.g. "3 files in sketchybar/plugins/"}

### Themes
{1–2 sentences grouping the work — infra, features, fixes, reviews}

---

**Yesterday**: {one line suitable for verbal standup}
**Today**: _fill in_
**Blockers**: _fill in_
```

## Rules

- Skip any section that would be empty. Do not print the heading.
- Don't double-list: if a commit is already represented by a PR in Shipped or In progress, don't repeat it in a commits list.
- Keep bullets terse — standup pace, not a full report. Prefer counts over enumerating when there are >5 similar items in one repo.
- If `gh` returns nothing and there is no local WIP, just say "No activity since {SINCE}."
