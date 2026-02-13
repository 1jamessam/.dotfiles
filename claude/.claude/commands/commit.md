---
model: claude-3-5-haiku-20241022
description: Create a git commit with auto-generated message
allowed-tools: Bash(git add:*), Bash(git status:*), Bash(git diff:*), Bash(git log:*), Bash(git commit:*)
---

Check the current changes using git status and git diff. Review recent commit messages using git log to understand the commit message style. Then generate an appropriate commit message that summarizes the changes and create a commit with that message.
