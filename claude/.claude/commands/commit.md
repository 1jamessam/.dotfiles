---
model: claude-3-5-haiku-20241022
description: Create a git commit
allowed-tools: Bash(git add:*), Bash(git status:*), Bash(git commit:*)
argument-hint: [message]
---

Create a git commit with message: $ARGUMENTS
