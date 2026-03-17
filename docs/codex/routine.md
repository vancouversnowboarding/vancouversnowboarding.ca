# Whistler Blackcomb Report Routine

This notes the current steps for adding a same-day Whistler Blackcomb (WB) snow report so the next WB report stays in sync with recent git history.

* Review the most recent commits/`git log` entries that touch `_posts/*-whistler-blackcomb-snow-report.md` to confirm which post currently still has `featured: true`; that post needs to be flipped to `false` before the new entry becomes featured.
* Prepare the feature image(s) ahead of time by placing them in `/tmp`—the helper script expects all source images there, so you (the human teammate) must copy them before running tooling.
* Run `./image.sh YYYY-MM-DD` with the report date to resize/crop every `/tmp` image into `assets/images/`; the script prefixes each file with the date (example: `assets/images/2026-03-06-feature.jpg`) and uses ImageMagick (`magick ... -scale`/`-crop`) so the generated files are ready to be committed.
* Create `_posts/YYYY-MM-DD-YYYY-MM-DD-whistler-blackcomb-snow-report.md` with front matter matching the existing pattern: `layout: post`, `title: <date> Whistler Blackcomb snow report`, `date: "<date>T14:10:00-08:00"`, `tag: Whistler Blackcomb`, `image: assets/images/<date>-feature.jpg`, and `featured: true`.
* Write the body text describing that day's conditions (fog/visibility, snow quality, crowd/weather notes) and add any optional summary line such as `Overall rate: 4/5 ★★★★☆` if desired.
* When describing numeric details (snow totals, delays, counts, etc.), favour numeric digits (e.g., `10cm`, `10 minutes`) so reports stay concise and comparable.
* Use Canadian English spelling (e.g., `favour`, `colour`, `centre`) throughout the routine and reports.
* When you mention a past visit or another calendar day, link the text to its `_posts` report (for example, `Same as [yesterday](/2026-01-23-2026-01-23-whistler-blackcomb-snow-report.md/)`); this keeps readers able to follow your timeline.
* Double-check `_posts` to ensure only the new post still has `featured: true`; edit the previous report that was featured (usually the last one in git history) to `featured: false` so the homepage highlights just the latest entry.
* Stage `assets/images/<date>-*` plus the new `_posts` file, run `git status`, and commit with a descriptive message like "Add <date> Whistler Blackcomb snow report" so the sequence seen in `git log` stays consistent.
* This blog posts are for Vancouver Snowboarding web site. Therefore, each snow report articles must not take care of skiing at all.

* Run `bin/snow-report-lint` after preparing the markdown so any remaining `-` bullets or curly quotes are caught before commit (add `--auto-correct` to have the script fix those issues automatically); the lint targets only 2026‑onward snow reports to keep legacy posts untouched.

This routine mirrors the commits from March 2026: they added the new `_posts/2026-03-06...` file, introduced the same-date feature image, and set the 2026-03-05 post's `featured` flag to `false`, keeping only the newest report highlighted for readers.
