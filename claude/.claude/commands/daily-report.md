---
model: claude-sonnet-4-6
description: Generate daily work summary across rentspree org + local Claude sessions, save to Obsidian, post to Slack
allowed-tools: Bash(gh:*), Bash(mkdir:*), Bash(date:*), Bash(python3:*), Write, mcp__claude_ai_Slack__slack_send_message
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

4. **Claude sessions active today**: scan the local Claude session logs for every user prompt sent today (the machine's local day), across all projects — including sessions started on earlier days that had activity today. Run:
   ```
   python3 - <<'PY'
   import json, os, glob
   from datetime import datetime, timezone, timedelta

   ROOT = os.path.expanduser("~/.claude/projects")
   # Local "today" -> UTC window. Session timestamps are UTC (ISO-8601 Z);
   # derive the window from the machine's local zone so this is not hardcoded.
   local_tz = datetime.now().astimezone().tzinfo
   now_local = datetime.now(local_tz)
   start_local = now_local.replace(hour=0, minute=0, second=0, microsecond=0)
   end_local = start_local + timedelta(days=1)
   START, END = start_local.astimezone(timezone.utc), end_local.astimezone(timezone.utc)

   def parse_ts(s):
       try: return datetime.fromisoformat(s.replace("Z", "+00:00"))
       except Exception: return None

   def text_of(content):
       if isinstance(content, str): return content
       if isinstance(content, list):
           return "\n".join(b.get("text","") for b in content
                            if isinstance(b, dict) and b.get("type")=="text")
       return ""

   def is_tool_result(content):
       return isinstance(content, list) and any(
           isinstance(b, dict) and b.get("type")=="tool_result" for b in content)

   # Noise: tool-result carriers, meta, and harness/command wrappers.
   NOISE_PREFIXES = ("<command-name>","<command-message>","<local-command-stdout>",
                     "<bash-input>","<bash-stdout>","<task-notification>",
                     "[Request interrupted","This session is being continued")
   results = {}
   for proj_dir in sorted(glob.glob(os.path.join(ROOT, "*"))):
       proj = os.path.basename(proj_dir)
       for jf in glob.glob(os.path.join(proj_dir, "*.jsonl")):
           try:
               with open(jf) as fh:
                   for line in fh:
                       line = line.strip()
                       if not line: continue
                       try: d = json.loads(line)
                       except Exception: continue
                       if d.get("type") != "user": continue
                       ts = parse_ts(d.get("timestamp",""))
                       if not ts or not (START <= ts < END): continue
                       msg = d.get("message") or {}
                       content = msg.get("content")
                       if is_tool_result(content) or d.get("isMeta"): continue
                       txt = text_of(content).strip()
                       if not txt or txt.startswith(NOISE_PREFIXES): continue
                       if txt.startswith("<") and "system-reminder" in txt[:40]: continue
                       snippet = txt.replace("\n"," ")
                       results.setdefault(proj, []).append(
                           (ts.astimezone(local_tz).strftime("%H:%M"), snippet[:500]))
           except Exception: continue

   for proj in sorted(results, key=lambda p: -len(results[p])):
       print(f"\n### {proj}  ({len(results[proj])} prompts)")
       for hhmm, s in results[proj]:
           print(f"[{hhmm}] {s}")
   PY
   ```
   Read the grouped prompts and distill each project into 1-2 lines of what was actually accomplished (not a verbatim prompt dump). Project dir names map to repos: strip the `-Users-tanapats-jclocal-Developer-` prefix.

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

## Claude Sessions
| Repo / Project | What was done |
|----------------|---------------|
| ... | ... |

## Summary
{2-3 sentences grouping work into themes — e.g., infra, features, bug fixes, reviews. Draw on both the GitHub activity and the Claude sessions.}
```

If a section has no results, write "No activity" instead of a table. The Claude Sessions section captures work-in-progress that may not have produced a commit or PR yet, so include it even when it overlaps with the GitHub sections.

## Save to Obsidian

Write the report to:
```
/Users/tanapats.jclocal/Documents/ClaudeKnowledgeBase/DailyReports/{YYYY-MM-DD}-daily-report.md
```
Create the `DailyReports` directory if it doesn't exist.

## Post to Slack

Send the summary as a DM to yourself using the Slack MCP tool `mcp__claude_ai_Slack__slack_send_message` with `channel_id: "U090AMC4APM"`.
Format the Slack message as a concise version (no tables — use bullet points instead).
