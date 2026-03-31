# Whistler Snow Report Automation Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Add a Ruby CLI that turns `/tmp` images plus a short summary into a finished Whistler Blackcomb snow report with low-token AI generation and validation.

**Architecture:** Keep deterministic work local in Ruby: discover the report date, resize images, choose the previous featured post, and write the markdown file. Use `codex exec` with `gpt-5.1-codex-mini` only for body generation and a second low-cost pass for style/fact review, both driven by a short style capsule and a small reference excerpt. Keep the existing `routine` skill as a thin pointer to the script so future runs are short.

**Tech Stack:** Ruby, existing `image.sh`, existing `bin/snow-report-lint`, existing `bin/snow-report-review`, Codex CLI.

---

### Task 1: Add a Ruby CLI for report creation

**Files:**
- Create: `bin/snow-report-create`

- [ ] **Step 1: Write the failing test**

```ruby
# No automated test file exists yet; this CLI will be verified by running it
# against a temporary set of /tmp images and checking the generated post.
```

- [ ] **Step 2: Run the command with no images**

Run: `bin/snow-report-create --summary "rate 4, partially sunny & cloudy, not busy"`

Expected: fail fast with a clear message explaining that `/tmp` images are required.

- [ ] **Step 3: Write minimal implementation**

```ruby
#!/usr/bin/env ruby
```

- [ ] **Step 4: Run the command with sample inputs**

Run: `bin/snow-report-create --date 2026-03-31 --summary "rate 4, partially sunny & cloudy, not busy"`

Expected: create `_posts/2026-03-31-2026-03-31-whistler-blackcomb-snow-report.md`, resize `/tmp` images into `assets/images/`, and set the previous featured report to `featured: false`.

- [ ] **Step 5: Commit**

```bash
git add bin/snow-report-create
git commit -m "Add snow report creation CLI"
```

### Task 2: Tighten the routine skill to point at the script

**Files:**
- Modify: `.agent/skills/routine/SKILL.md`

- [ ] **Step 1: Replace the long manual checklist with a short usage note**

```md
Use `bin/snow-report-create --summary "..."` after placing images in `/tmp`.
```

- [ ] **Step 2: Keep the key invariants**

```md
The script handles image conversion, featured flipping, linting, review, and commit.
```

- [ ] **Step 3: Commit**

```bash
git add .agent/skills/routine/SKILL.md
git commit -m "Simplify snow report routine"
```

### Task 3: Verify the low-token AI path

**Files:**
- Modify: `bin/snow-report-create`

- [ ] **Step 1: Run the CLI end-to-end with a small image set**

Run: `bin/snow-report-create --date 2026-03-31 --summary "rate 4, partially sunny & cloudy, not busy"`

Expected: `codex exec` runs twice with `gpt-5.1-codex-mini`, first for body generation and then for a short review pass.

- [ ] **Step 2: Run lint and review**

Run: `bin/snow-report-lint --auto-correct && bin/snow-report-review`

Expected: both commands report `ok`.

- [ ] **Step 3: Commit**

```bash
git add bin/snow-report-create _posts/2026-03-31-2026-03-31-whistler-blackcomb-snow-report.md assets/images/2026-03-31-feature.jpg .agent/skills/routine/SKILL.md
git commit -m "Automate Whistler snow report creation"
```
