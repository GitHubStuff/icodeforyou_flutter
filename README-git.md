# Git Workflow: Branch, Push, PR

Here's the standard flow.

## 1 — Clone (branch) from main

You don't actually *clone* in git terminology here — you create a **branch** off main. Cloning is what you do to get the repo onto your machine in the first place.

```bash
# Make sure main is current
git checkout main
git pull origin main

# Create and switch to a new branch off main
git checkout -b feature/my-new-thing
```

Or the modern equivalent:

```bash
git switch main
git pull
git switch -c feature/my-new-thing
```

## 2 — Push the new branch to the remote

First push needs `-u` to set the upstream tracking:

```bash
git push -u origin feature/my-new-thing
```

After that, plain `git push` knows where to go.

## 3 — Push subsequent commits

Once upstream is set, just commit and push:

```bash
git add .
git commit -m "Add the thing"
git push
```

Repeat as needed. Each push updates the remote branch with your latest commits.

## 4 — Open a PR for merging into main

PRs aren't a git feature — they're a GitHub/GitLab/Bitbucket feature on top of git. Two ways:

**Via the web UI:** After your first `git push -u`, the terminal usually prints a "Create pull request" URL. Click it. Otherwise go to the repo on GitHub and there'll be a banner offering to open a PR for the recently-pushed branch.

**Via GitHub CLI** (if you have `gh` installed — `brew install gh`):

```bash
gh pr create --base main --head feature/my-new-thing \
  --title "Add the thing" \
  --body "Description of what and why."
```

Or interactively:

```bash
gh pr create --web
```

That opens the PR creation page in your browser with the branches pre-filled.

## After the PR is merged

Clean up locally:

```bash
git switch main
git pull
git branch -d feature/my-new-thing      # delete local branch
git push origin --delete feature/my-new-thing  # delete remote branch (if not auto-deleted)
```

Many repos have "auto-delete head branches" enabled on the remote, in which case the remote branch is gone after merge and you only need the local cleanup.