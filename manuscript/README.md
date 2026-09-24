# Manuscript

APA 7 draft for Journal of Gambling Studies / Journal of Behavioral Addictions.

## How it's built

Every number, table and figure in the paper is generated from the raw data by
`make_assets.R`, which runs the same analysis code as
`analysis/greyhound_report.Rmd` (via `knitr::purl`). Nothing is typed in by hand.

```bash
# from the project root, after pulling new data:
Rscript manuscript/make_assets.R      # -> numbers.tex, tables/, figures/
cd manuscript && latexmk -pdf manuscript.tex
```

In the .tex, numbers are inserted as `\res{key}` (e.g. `\res{s5-stat}`); keys are
defined in `numbers.tex`. A key that doesn't exist prints as **??key??** in the PDF,
so a typo can't silently drop a number. `grep 'res@' numbers.tex` lists them all.

Needs R (tidyverse, lme4, lmerTest, BayesFactor, patchwork) and TeX Live with
`apa7`, `biblatex-apa`, `biber`.

## Study numbering

| Paper   | Repo folder        | What it does |
|---------|--------------------|--------------|
| Study 1 | `pavlovia/`        | Near-miss effect with race video, not preregistered |
| Study 2 | `study2-*`         | Preregistered replication + trajectory |
| Study 3 | `study3-*`         | Adds a bet (5 fixed stakes) |
| Study 4 | `study4-*`         | Continuous stake slider (was it the discrete scale?) |
| —       | `study5-*`         | Within-subject bet-availability pilot, abandoned, not reported |
| Study 5 | `study6-*`         | Between-subjects: betting vs no betting (confidence) |

## What's in the draft

- Title page, abstract (draft), General Method, and each study's Method and
  Results with figures and tables, written out in full.
- Introduction and General Discussion are **drafting notes** (blue bullets) for
  Omar to turn into prose.
- `fig_trajectory_s345.pdf` (pleasure by trajectory, Studies 3–5) is generated
  but not placed in the text; Table 9 covers the same result.

## Open TODOs (search `TODO` in the .tex)

- Prolific details: filters, base pay per study, demographics (not in the task
  data — from the Prolific exports).
- Ethics protocol number; AsPredicted number for Study 2; ORCIDs; funding/COI;
  data/code link.
- Footage source and trajectory-coding procedure.
- Study 5 stopping rule (data collected in batches): state it plainly.
- **Verify every reference in `references.bib`** against the source (written
  from memory). Candidate refs in the Introduction notes are marked "verify".

## Findings the text reports (as of the last build)

- Near-miss effect on pleasure, luck, motivation: all five studies (motivation in
  Study 4 same direction, n.s.). Pre-race confidence never differs NM vs CL.
- Trajectory: catch-up near misses less unpleasant in Study 2 only.
- Bet size: no near-miss effect in Studies 3 or 4 (BF01 ≈ 5.4).
- Confidence lower with betting across studies (d = −0.53, confounded) and with
  random assignment in Study 5 (d = −0.47, one-tailed p = .006).
- Exploratory (Study 5): betting shrinks the near-miss effect on every rating;
  near misses rated like losses when a bet is on (not a floor effect).
