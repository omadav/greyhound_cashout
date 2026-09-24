# Manuscript

APA7-format draft manuscript (`manuscript.tex` + `references.bib`), targeting
Journal of Gambling Studies or Journal of Behavioral Addictions. Both accept
a standard APA-style Word/LaTeX manuscript on submission and handle their own
typesetting, so this does not need to match either journal's final layout.

## Status

This is a full first-draft narrative — not a bare skeleton — filled in with
the real numbers from `analysis/greyhound_report.Rmd` as rendered on
2026-09-24. Before submitting:

- **Re-pull and re-render the report first.** Study 6 was an open pilot at
  time of writing (N=120); if more data was collected, every number in the
  Study 6 and General Discussion sections needs updating.
- Search the .tex file for `TODO` — title, author email, funding/COI/data
  statements, final Study 6 sample-size decision, and one open citation gap
  (naturalistic/dynamic near-miss stimuli in the Introduction).
- **Every reference in `references.bib` needs re-verification against the
  original source** (see the comment at the top of that file) — they were
  reconstructed from memory and earlier project lookups, not freshly checked
  when this draft was written. `persistenceTODO` is an unfilled placeholder
  for the resistance-to-extinction / continue-quit persistence literature
  cited in Future Directions; it isn't cited in the text yet.
- Decide co-authorship and author order with Luke Clark before circulating.

## Compiling

Requires a TeX distribution with `apa7`, `biblatex-apa`, and `biber`
(TeX Live / MacTeX have all three).

```bash
latexmk -pdf manuscript.tex
```

Output: `manuscript.pdf`.
