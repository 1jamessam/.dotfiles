---
description: Summarize today's GitHub work (PRs opened and merged)
allowed-tools: Bash(gh:*)
---

Summarize my GitHub work for today. Use the GitHub CLI (`gh`) to find:

1. **PRs I opened today**: Use `gh search prs --author @me --created ">=<today's date>" --json repository,title,number,state,url`
2. **PRs merged today** (may have been created earlier): Use `gh api search/issues --method GET -f q="author:@me is:pr is:merged merged:<today's date>..<today's date>" -f per_page=50 --jq '.items[] | {title, number, html_url, repository_url}'`

Present the results in two tables:

- **PRs Opened Today** — with repo, title, and status
- **PRs Merged Today** — with repo and title

End with a short **Summary** section that groups the work into themes (e.g., infra changes, new features, batch rollouts, bug fixes). If many PRs share the same title, note the count instead of listing each one individually.
