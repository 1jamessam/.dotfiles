---
model: claude-3-5-haiku-20241022
description: Create a GitHub pull request
allowed-tools: Bash(git *), Bash(gh pr create:*)
argument-hint: [base-branch]
---

Create a GitHub pull request for the current branch.

Instructions:

1. Check git status and see if there are uncommitted changes
2. If there are uncommitted changes, ask the user if they want to commit them first
3. Ask user for the Jira ticket id
4. Check if the current branch is pushed to remote (use: git status -sb)
5. Get the base branch from $ARGUMENTS or default to "main"
6. Get all commits on this branch that aren't on the base branch (use: git log <base>...HEAD)
7. Review the git diff between base branch and HEAD (use: git diff <base>...HEAD)
8. Draft a concise PR title (under 70 characters) and detailed description based on ALL commits and changes
9. Push the branch if needed (use: git push -u origin HEAD)
10. Create the PR using: gh pr create --title "..." --body "..." --base <base-branch>
11. Return the PR URL to the user

Format PR title as:

[<Jira-ticket-id>] concise title

Format the PR body as:

### Problems

> Describe what you are trying to solve.

### Solutions

> Describe what the merge request does and why it is necessary.

### Changes

> Describe the changes included in the merge request.
