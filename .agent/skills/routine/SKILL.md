---
name: routine
description: >
  Create a new whistler blackcomb snow report post for vancouversnowboarding.ca web page.
---

# Whistler Blackcomb Report Routine

Put the day's images in `/tmp`, then run:

```bash
bin/snow-report-create --summary "rate 4, partially sunny & cloudy, not busy"
```

Optional flags:

* `--date YYYY-MM-DD` to override today
* `--model gpt-5.1-codex-mini` to use a different Codex model
* `--reference-date 2025-04-18` to change the style sample
* `--dry-run` to stop after planning

The script handles image conversion, low-token AI drafting/review, featured flipping, linting, review, and commit.

Keep the summary short and factual. Include the rating in the summary, use digits for counts, use Canadian English, and do not talk about skiing.
