---
model: claude-sonnet-4-6
description: Generate daily work summary across rentspree org, save to Obsidian, post to Slack
allowed-tools: Bash(gh:*), Bash(mkdir:*), Bash(date:*), Write, mcp__claude_ai_Slack__slack_send_message
---

Generate a daily work summary for GitHub user `james-rsp` across the entire `rentspree` GitHub org.

Determine today's date using `date +%Y-%m-%d`.

## Data Collection

Run these in parallel:

1. **PRs opened today**:
   ```
   gh search prs --author james-rsp --owner rentspree --created ">=$(date +%Y-%m-%d)" --json repository,title,number,state,url --limit 50
   ```

2. **PRs merged today** (may have been opened earlier):
   ```
   gh api search/issues --method GET -f q="author:james-rsp org:rentspree is:pr is:merged merged:$(date +%Y-%m-%d)..$(date +%Y-%m-%d)" -f per_page=50 --jq '.items[] | {title, number, html_url, repository_url}'
   ```

3. **Commits pushed today**:
   ```
   gh api search/commits --method GET -f q="author:james-rsp org:rentspree committer-date:$(date +%Y-%m-%d)..$(date +%Y-%m-%d)" -f per_page=50 --jq '.items[] | {message: .commit.message, repo: .repository.full_name, sha: .sha[:7], url: .html_url}'
   ```

## Format

Create a markdown report:

```markdown
# Daily Work Summary — {YYYY-MM-DD}

## Commits
| Repo | SHA | Message |
|------|-----|---------|
| ... | ... | ... |

## PRs Opened
| Repo | # | Title | Status |
|------|---|-------|--------|
| ... | ... | ... | ... |

## PRs Merged
| Repo | # | Title |
|------|---|-------|
| ... | ... | ... |

## Summary
{2-3 sentences grouping work into themes — e.g., infra, features, bug fixes, reviews}
```

If a section has no results, write "No activity" instead of a table.

## Save to Obsidian

Write the report to:
```
/Users/tanapats.jclocal/Documents/ClaudeKnowledgeBase/DailyReports/{YYYY-MM-DD}-daily-report.md
```
Create the `DailyReports` directory if it doesn't exist.

## Post to Slack

Send the summary as a DM to yourself using the Slack MCP tool `mcp__claude_ai_Slack__slack_send_message` with `channel_id: "U090AMC4APM"`.
Format the Slack message as a concise version (no tables — use bullet points instead).
