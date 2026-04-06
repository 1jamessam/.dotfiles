---
description: Create a GitHub pull request
allowed-tools: Bash(git *), Bash(gh pr create:*)
argument-hint: [base-branch]
---

Create a GitHub pull request for the current branch.

Instructions:

1. Switch to a new branch with prefix `feature/` if the active branch is "main" or "master"
2. Check git status and see if there are uncommitted changes
3. If there are uncommitted changes, ask the user if they want to commit them first
4. Ask user for the Jira ticket id
5. Check if the current branch is pushed to remote (use: git status -sb)
6. Get the base branch from $ARGUMENTS or default to "main"
7. Get all commits on this branch that aren't on the base branch (use: git log <base>...HEAD)
8. Review the git diff between base branch and HEAD (use: git diff <base>...HEAD)
9. Draft a concise PR title (under 70 characters) and detailed description based on ALL commits and changes
10. Push the branch if needed (use: git push -u origin HEAD)
11. Create the PR using: gh pr create --title "..." --body "..." --base <base-branch>
12. Return the PR URL to the user

Format PR title as:

[<Jira-ticket-id>] concise title

Format the PR body as:

### Problems

> Describe what you are trying to solve.

### Solutions

> Describe what the pull request does and why it is necessary.

### Changes

> Describe the changes included in the pull request.
