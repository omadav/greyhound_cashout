# Greyhound_NM

## Overview

This repository contains materials for the greyhound race project, including:

- race videos in `Races/`
- race notes and coding materials in `Notes on Races/` and `KateChampion/`
- prior participant data in `Sophie data/`
- the older Windows task source in `Source/`
- the current Prolific study design draft in `prolific_greyhound_design_proposal.md`
- a browser pilot prototype in `pilot-task/`
- a GitHub Pages publish copy in `docs/`
- bilingual UChile/FACSO ethics protocol drafts in `uchile_facso_ethics_protocol_greyhound_es.md` and `uchile_facso_ethics_protocol_greyhound_en.md`

## Current Goal

Adapt the earlier greyhound race task into a Prolific-compatible online experiment where participants:

1. choose a dog by name
2. are covertly mapped onto a predetermined trap/outcome condition
3. watch a race video
4. face a mid-race cash-out decision
5. see the final race outcome
6. report motivation and related responses after each race

## Session Log

### 2026-05-05

#### Work completed

- reviewed the full project structure and key subfolders
- inspected the race videos in `Races/`
- extracted and reviewed prior notes, procedure documents, ethics materials, and debrief text
- inspected the old Windows task source code to confirm how chosen dog names were remapped to forced trap/outcome assignments
- checked the older saved data files to recover the original rating questions and outcome structure
- wrote the Prolific design draft in `prolific_greyhound_design_proposal.md`
- created this `README.md` as a running session record
- built a dependency-light browser pilot in `pilot-task/` with dog choice, hidden trap assignment, confidence rating, race playback, cash-out, outcome feedback, post-race ratings, and JSON/CSV export
- packaged the pilot for one-click GitHub Pages hosting by moving the demo clip inside the app and creating a deployable `docs/` copy
- added a post-task PGSI questionnaire to both the source pilot and live Pages copy
- drafted University of Chile / FACSO ethics protocol versions in Spanish and English

#### Key findings

- the old task already implemented rigged outcome assignment after participants chose a dog name
- the older task already measured:
  - pre-race confidence
  - post-race pleasure
  - post-race desire to continue playing
- the race-coding spreadsheet appears to support a conservative first-pass stimulus set with:
  - 12 clear-consensus races
  - 16 near-consensus races
  - 10 ambiguous or unresolved races to hold back initially
- the current video files are `.avi`, so they will likely need conversion to browser-friendly formats such as `.mp4` before Prolific deployment
- the current folder is inside a larger git repository rooted at `/Users/omadav/Dropbox/Projects`, so publishing this work to GitHub will require deciding whether `Greyhound_NM` becomes its own standalone repo or remains nested in the parent tree
- GitHub Pages can now serve the demo directly from `docs/`, so colleagues can open one URL and land straight on the playable pilot

#### Main design recommendation from this session

Build a first Prolific version with:

- 4 core conditions: `CW`, `NW`, `NM`, `CL`
- a repeated-measures design
- a binary mid-race cash-out choice with randomized offer values
- post-race ratings for pleasure, luck, and motivation to keep playing
- a conservative stimulus pool using only the cleanly coded races first

#### Important files

- [prolific_greyhound_design_proposal.md](/Users/omadav/Dropbox/Projects/Greyhound_NM/prolific_greyhound_design_proposal.md)
- [pilot-task/README.md](/Users/omadav/Dropbox/Projects/Greyhound_NM/pilot-task/README.md)
- [GITHUB_PAGES_DEPLOY.md](/Users/omadav/Dropbox/Projects/Greyhound_NM/GITHUB_PAGES_DEPLOY.md)
- [Notes.txt](/Users/omadav/Dropbox/Projects/Greyhound_NM/Notes.txt)
- [DogRaceApp.exe.config](/Users/omadav/Dropbox/Projects/Greyhound_NM/DogRaceApp.exe.config)
- `Races/`
- `Notes on Races/`
- `KateChampion/`
- `Sophie data/`
- `Source/`

#### Suggested next steps

- create one clean metadata file for all usable race videos
- decide whether version 1 should use only the 4 broad conditions or also model progression subtypes
- convert the selected race videos into web-ready formats
- replace the pilot demo clip reuse with a finalized web-ready stimulus schedule
- decide whether to make `Greyhound_NM` its own git repository before pushing to GitHub
- enable GitHub Pages from `/docs` once the standalone repository exists

### 2026-07-23

Session with Luke (meeting notes) plus a full pass over the 2013 stimulus materials.

#### Study programme agreed

| Study | Content |
|---|---|
| 1 | 4 conditions, no cash-out. Tests the basic near-miss effect. **Build this first.** |
| 2 | Adds the anticipation/dynamics split (catch-up vs fallback near misses) |
| 3 | Study 1 + cash-out |
| 4 | Study 2 + cash-out |

#### Terminology (fixed, use everywhere)

All labels are written **from the point of view of the second-place dog**. The 2013
materials wrote them from the winner's point of view, which is why "overtake" was
ambiguous — it never said who overtook.

Clip shape, a fixed property of the video:

- `CLEAR` — winner never seriously challenged
- `STABLE` — close finish, no lead change, no late charge
- `FALLBACK` — the front-runner is passed near the line (2013 called this "overtake")
- `CATCHUP` — the second dog gains late but never gets there

Trial condition, what the participant experiences = clip shape x which dog they are
assigned:

| Clip | Assigned winner | Assigned runner-up | Assigned back dog |
|---|---|---|---|
| `CLEAR` | `CW` clear win | — | `CL` clear loss |
| `STABLE` | `RW` narrow win | stable near miss | `CL` |
| `FALLBACK` | narrow win | `FNM` fallback near miss | `CL` |
| `CATCHUP` | narrow win | `CNM` catch-up near miss | `CL` |

Study 1 uses `CW` / `RW` / `NM` (pooled) / `CL`. Study 2 splits `NM` into `FNM` / `CNM`.

#### Key findings this session

- **The 2013 rule was found**, in `KateChampion/EthicsSubmission/Clark_Greyhound_PREform.docx`:
  a narrow win is when the second dog finishes **under 0.09s** behind the winner; a clear
  win is **more than 0.26s**. Nearly half the pool falls in the undefined middle, which is
  why the 2013 coding was never finished.
- The spreadsheet's `Distance` column is therefore the **winner-to-runner-up gap in
  seconds** (roughly 0.08s per length). It is objective and should be used for the
  closeness axis. Judging closeness by eye proved unreliable for both of us, in both
  directions.
- The 2013 team already had the two-axis idea — closeness *and* dynamics
  (stable / catch-up / overtake), citing Kahneman & Varey (1990). They never applied it.
- **Races 1-23 end with the result board; races 24-38 do not** — they cut off with the
  dogs still running. Confirmed in the original AVIs, so this is in the source material,
  not a conversion artefact. Two different recording sessions.
- The pilot's demo clip is **race 2** (board reads `321` / `19:36`, matching Kate's file
  `NM Catch up 3 320 19.36 321 edit.mp4`). Kate considered race 2 a catch-up near miss.
- Only the **top three** finishers are ever displayed. A dog outside the top three is
  "unplaced" — which is how real racing reports it, so `CL` can be delivered as
  "unplaced" and no 4th-6th coding is needed.
- Videos converted to browser-ready H.264 MP4 (854x480, 29.97fps, faststart) in `Races/`;
  originals preserved in `Races_avi/` (gitignored). All 39 verified against source
  durations.

#### Pool, using narrow <= 0.14s and clear > 0.24s

| Set | Narrow | Clear | Middle | Unknown |
|---|---|---|---|---|
| Races 1-23 (result visible) | 11 | 7 | 4 | 1 (race 7) |
| Races 24-38 (no result shown) | 8 | 3 | 4 | 0 |

Study 1 needs 8 narrow + 4 clear per participant, so **races 1-23 are sufficient**.
Study 2 needs 12 narrow and is one race short of buildable from 1-23 alone.

#### Other decisions

- **Randomise trial order per participant.** The meeting notes said "same order for
  everyone", but the earlier slot-machine study's fixed sequence produced unexpected
  results, which is why that study moved to randomised order. Randomise, with light
  constraints (no more than two of the same condition in a row, no near miss on trial 1).
- Fresh dog names each trial, drawn from a name database, so no narrative accumulates
  about "my dog" across trials.
- Outcome conditions stay **within-subject**. Only the clip-to-role assignment and the
  cash-out manipulation are between-subjects. PGSI is between-subjects, so a
  within x between interaction is well powered at n~300; between x between would not be.
- Sample: pilot of 30 first, then ~300.

#### Problems to look at

- The **winning post is not identifiable** in races 24-38. Until it is, those 15 races
  cannot be used, which is what blocks Study 2.
- Race 7 has no gap recorded in the 2013 sheet; needs measuring.
- Race 16 may have a **vacant trap** — trap 2 was never seen. If a race has five
  runners the choice screen for that trial can only offer five dogs.
- The 0.14-0.24s middle band (8 races) is unused. Revisit if the pool gets tight.
- `race_coding_sheet.csv` holds the working classification. Races 3 and 16 are coded
  `CATCHUP`; 2, 14, 18, 20, 21 as `CLEAR` — but those five were judged before we knew
  closeness comes from the clock, and by that measure 2, 14 and 21 are all narrow. They
  need a dynamics label, not a closeness one.
- The PGSI questionnaire is implemented in the working tree but **not committed**, so the
  live Pages demo does not have it.
- `pilot-task/` and `docs/` are duplicate copies kept in sync by hand.

#### Study 1 built and pushed live

- The browser task is now the real 4-condition Study 1, replacing the single-clip
  demo. Per participant: 20 races, 5 each of CW / NW / NM / CL, drawn from the
  pool and randomised per participant (no more than two of a condition in a row,
  never opens on a loss). Fresh dog names each race from a name database. Chosen
  dog assigned to a trap by condition; jacket colour shown so it can be followed.
  Clear losses shown as "unplaced". Rating sliders have no central default (must
  be moved). PGSI at the end. Cash-out is built but gated off (`STUDY.cashout`).
- Race videos converted to browser MP4 and committed under `docs/assets/videos/`
  (races 1-23). Dev copy under `pilot-task/assets/videos/` is gitignored.
- Verified end to end in headless Chrome: 20 trials, correct condition counts and
  outcomes, 20 distinct races, no console errors.
- Live at https://omadav.github.io/greyhound_cashout/ (Pages serves main /docs).

#### Cash-out design for Studies 3-4 (second discussion with Luke)

- **Manipulation: offer value scaled to race state.** Real operators lower the
  cash-out value when your dog is losing. The strong version of the study makes
  the offer a function of the chosen dog's position at the pause, and tests
  whether people accept a worse-value offer when trailing (grabbing something to
  avoid the near miss) than when leading. Maps onto clip shape at the pause:
  leading = {clear win, hold-on win, fallback NM}; trailing = {overtake win,
  catch-up NM, clear loss}. This gives cash-out trials matched on visible state at
  the moment of decision.
- **Risk aversion as a separately-measured covariate.** A cash-out choice is
  ambiguous on its own (near-miss framing vs just being risk-averse). Fix this by
  measuring risk aversion in a *separate* lottery-choice block (sure amount vs
  gamble), fitting a utility-curvature parameter per participant, then entering
  that parameter into the cash-out model. Then ask whether race dynamics predict
  cashing out *over and above* individual risk aversion. Same between x within
  logic as PGSI. Must be a non-greyhound task or the estimate is circular.
- This is what Ty Hayes (Warwick, via Luke) is being consulted about — how betting
  operators actually set cash-out values.

#### Task refinements (design, payment, data quality)

Pool corrections:

- Race 7 rewatched: it is a close (photo) finish, not a clear win -> moved to the
  close pool. Race 22: only 5 dogs ran, trap 6 (striped) vacant -> the earlier fast
  count pass had it wrong. Pool is now 11 clear / 12 close.
- The fast runner-count pass can hold other errors; the symptom is a choice screen
  showing a dog that never leaves the traps. Fix as spotted (race id + empty trap).

Presentation:

- Rebranded participant-facing task as **"Trackside — Live Greyhound Racing"**.
  "Near miss" / "Study 1" appear nowhere a participant can see them (would cue the
  manipulation). Dark bookmaker visual theme.
- Restored engagement details on the race card (form, trainer, age, weight, track),
  random and identical across conditions so they leak nothing about the outcome.
  Trap number is withheld until after the pick, preserving the rig.
- **Odds removed**: they imply a payout/win-probability tied to the outcome, a
  confound. Dropped from card, data, and config.
- Dog names dealt without replacement across the whole session (prefix x word,
  ~600 combos), so no name is ever seen twice -> no learning effects.

Payment (set on Prolific, not in code):

- £2.00 completion + £2.00 bonus. Every participant wins exactly 10 races
  (5 CW + 5 NW), so the bonus is a flat £2 for everyone -> it is motivational
  framing, not variable pay. Effective ~£10-12/hr for a 20-25 min session
  (includes PGSI). Confirm the base against the pilot's real median time.
- In-task tally shows **credits** (100 at the end), not GBP, since it is not real
  cash; 100 credits convert to the £2 bonus. Budget ~£4/participant flat; Prolific
  fees + VAT add ~40% on top (~£1,700 all-in for 300).
- Demographics come from Prolific's database (age, sex, nationality, etc.) — do not
  re-collect; add a custom item only for something Prolific does not hold.

Data quality:

- Rating sliders start at a **random** position each time (removes the central
  anchor Luke flagged) and must be moved to continue. Start position and response
  time are logged (confidenceStart/RT, *Start, postraceRT_ms).
- **Two attention checks** per session, one at random in races 3-10 and one in
  races 11-18 (spread, never first/last, different races per person). Each is a
  **standalone screen after the confidence rating** — deliberately NOT among the
  post-race emotion sliders, so its salient wording cannot capture attention and
  perturb those DVs. Random target (20/40/60/80), pass within +/-5; logged as
  attentionTarget / attentionResponse / attentionPass / attentionRT_ms.
- Exclusion is prevention + flags, not "did not move a slider": everyone must move
  every slider to advance, and the within-subject design means careless responders
  dilute the effect rather than fake one. Use failed attention checks, implausible
  RTs, and straight-lining to exclude.

Open follow-ups:

- Slider scale wording still to be confirmed by Luke, then applied.
- Seat assignment (winner vs runner-up for close races) is currently random per
  draw; add strict counterbalancing (each close race NW for half, NM for half)
  for the main run.
- Add a straight-lining detector to the export.

### 2026-07-24

Study 1 deployed and piloted end to end.

#### Deployment

- Self-contained build pushed to Pavlovia (`gitlab.pavlovia.org/omardavidperez/
  greyhound-cashout`, project id 533864), kept in `pavlovia/` (gitignored from this
  public repo). Data-saving reuses the proven vanilla-JS wrapper from the
  in-game-betting-experiment (open session → POST results CSV → close), reads the
  Prolific URL params, and redirects to the Prolific completion URL on finish.
- Live on Prolific: £3.50 base + £1 bonus (base ≈ £11.7/hr shown, ≈ £15/hr with
  bonus; the bonus stays a bonus so in-game winnings feel consequential). URL
  parameters pass PROLIFIC_PID/STUDY_ID/SESSION_ID; completion via redirect
  (cc=CKEB0540). `?reps=N` shortens the task for testing only — the real link runs
  the full 20.
- PGSI screen heading neutralised ("A few final questions") so the scale name does
  not prime socially-desirable answering.

#### Pilot result (analysis in `analysis/analyze_pilot.R`, reproducible)

At **n≈43 completers** (auto-excluding straight-liners; 0 attention-check fails,
0 dropouts):

- **Near-miss effect confirmed:** motivation NM > CL by ~+9 points, paired
  t ≈ 5, **p < 0.001**; mixed model condition effect F ≈ 89, p < 2e-16.
- **PGSI moderation:** (NM−CL motivation) × PGSI correlation r ≈ 0.31, p ≈ 0.04;
  mixed-model condition × PGSI interaction **p < 0.01**. Higher gambling risk →
  larger near-miss motivation boost.
- **Validity check passes:** pre-race confidence is flat across conditions (rated
  before the outcome); pleasure and luck track outcome monotonically.
- **Trajectory hint (exploratory):** catch-up near misses sustain motivation more
  than fall-back (catch-up 64 vs fall-back 59 vs CL 49); catch-up vs stable p≈0.04
  in a mixed model on NM trials. Underpowered (catch-up stimuli scarce) — this is
  the empirical hook for the Study 2 trajectory design.

Plots use within-subject 95% CIs (Cousineau–Morey) with significance brackets.

#### Analysis / notes committed

- `analysis/analyze_pilot.R` — the R/ggplot pipeline (pull Pavlovia CSVs → clean +
  quality flags → figures + mixed models + stats.txt). One command reruns it.
- `analysis/stimulus_notes.md` — description of the clips and the labelling
  provenance for Luke, incl. the per-race table. Eye-coding matches the 2013 raters
  on 20/23 (races 3, 20 had no 2013 consensus; race 18 is the only disagreement).
- Participant data (`pavlovia/data/`, `pilot_analysis/`) is gitignored — this repo
  is public, so raw responses + Prolific IDs + PGSI stay out of git.

#### Open follow-ups

- Study 2 trajectory design needs more catch-up footage (revisit races 24–38 if
  their finish line can be identified).
- Strict NW/NM seat counterbalancing for the main run (currently random per draw).
- Final scale wording from Luke, then apply.

### 2026-07-25 — trajectory coding rule, fig5, and races 24–38 recovered

#### Task v2 (Luke's email) shipped

Wording ("Unplaced" → "Did not win"), one kennel prefix per session, luck question
reworded with anchors, video capped to the viewport with scroll-to-top, and a new
outcome attention check ("where did your dog finish?") asked after the video but
before the result screen. Kept as a *second* check alongside the slider one, since
they catch different failures. Live on Pavlovia and GitHub Pages.

**PGSI feedback removed.** The finish screen was printing the participant's PGSI
total and risk band back at them. PGSI is a screening instrument and should not be
fed back uninterpreted. `pgsi_total` / `pgsi_category` are still recorded per row.

#### The trajectory coding rule (now written down)

Trajectory is always described **from the losing dog's point of view** — the dog a
near-miss participant is assigned to:

- **fall-back** — was ahead, got caught
- **catch-up** — was closing, didn't quite get there
- **stable** — close finish, gap roughly constant

Two 2013 sources use *opposite* perspectives, which caused a day of confusion:
`RaceComments.docx` is explicitly "from perspective of winning dog", while the Yin Wu
column in `ratings 2013-09-08.xlsx` ("Near Miss – Overtake finish" / "Catch up
finish" / "stable") is already in our frame. `shape_prior` follows the latter.
See `analysis/stimulus_notes.md`.

#### fig5 — within-clip near-miss effect

New figure. Because the same clip is a narrow win for some participants and a near
miss for others, subtracting NM − NW *within a clip* cancels everything about that
race and leaves the near-miss effect alone. Unit of analysis becomes the clip.

- motivation: catch-up −2.2, fall-back −8.9, stable −18.0; catch-up vs stable
  t = 3.62, **p = 0.011** (clip-level).
- pre-race confidence sits at ~0 — the built-in check that trap assignment isn't
  leaking before the race.
- pleasure and luck show no trajectory effect: this is motivation-specific.

fig4 is superseded. Its bars mixed the near-miss effect with the fact that the three
trajectory groups are different races that score differently to begin with (their
narrow-win baselines are 66.6 / 68.4 / 72.4).

**Caveat that stands:** catch-up is 3 clips in the analysed data, leave-one-out drops
it to p ≈ 0.06, and Omar and Yin disagree on race 16. Exploratory, needs replication.

#### Races 24–38 are usable after all

Previously excluded for "no visible finish line". Wrong test — they lack the trackside
*result board*, not the finish. The task announces the outcome itself, so the board is
irrelevant. Omar confirmed on race 38. Newly coded: **32 (catch-up, agreed with Yin)**,
36 (fall-back), 37 (clear), 38 (stable). Race 32 is the cheapest route out of the
catch-up shortage.

#### Data integrity check

Cross-checked `trial-config.js` against `stimulus_pool.csv`: **all 23 finishing orders
match** — nothing participants saw was mislabelled. Four rows (7, 13, 17, 22) had a
stale `band` derived from the 2013 gap that contradicted Omar's eye label; the task
always used the eye label, so no data is affected. CSV synced.

#### Open follow-ups

- **Runner count + vacant traps for races 32, 36, 37, 38** (`NEEDS-COUNT` in
  `stimulus_pool.csv`) — blocks them entering the task. Then copy the videos into
  `docs/assets/videos/` and the Pavlovia build.
- Code the remaining unused races: 24, 25, 26, 27, 30, 31, 33, 34, 35.
- Race 16 (catch-up vs stable) and race 38 (stable vs fall-back) still contested with
  Yin; a third rater would settle them.
- Study 2 scheduler: rotate rather than randomise, so each clip serves NW and NM
  equally often, and each participant gets equal numbers of each trajectory. Current
  data is badly unbalanced — race 20 is 27 NM vs 11 NW, and 14% of participants saw
  zero catch-up near misses.
- Power: ~9 clips per trajectory for a confirmatory test (planning for d = 1.5).

## Future Sessions

Append future dated entries to the `Session Log` section above so this file becomes a running record of design decisions, coding progress, and open questions.

### 2026-07-25 (cont.) — Study 2 designed and locked

#### What the pilot actually supports

Re-ran fig5's contrast under every defensible labelling. The **effect size is stable
at ~16 rating points**; what varies is how many clips are left to test it with:

| labelling | catch-up | stable | test |
|---|---|---|---|
| as plotted (16 = catch-up) | −2.2 (k=3) | −18.0 (k=5) | p = 0.011 |
| 16 → stable (2013 majority) | −0.6 (k=2) | −15.9 (k=6) | p = 0.046 |
| + drop night races | −0.6 (k=2) | −17.0 (k=3) | p = 0.111 |

**Report fig5 as exploratory with the effect size, not the p-value** — p = 0.011
depends on race 16, which is contested.

#### Correction: clip count is not the limiting factor

Earlier in the session I argued Study 2 needed ~9 clips per trajectory. That was
wrong. A variance decomposition on the pilot shows the spread of effects across
clips within a trajectory (SD 3.1 / 5.6 / 7.0) is *smaller* than the measurement
noise in those estimates (SD ≈ 9) — i.e. **no detectable clip-to-clip variation**.
Upper 95% bound on the true clip SD is 2.9 points, against a 16-point effect. Even
with 3 clips the contrast SE floor is 2.4 points.

So more **participants** is the efficient lever, exactly as Omar argued. The power
table built on the observed between-clip scatter treated sampling noise as real
variance and is superseded.

What extra participants cannot fix is a **confound**, which is why the four
floodlit night races are still excluded — they sat only in fall-back and stable.

#### Study 2 stimulus set (locked)

| trajectory | races |
|---|---|
| catch-up | 3, 4, 16, **32** |
| fall-back | 5, 7, 9, 15 |
| stable | 2, 20, 21, **31, 35** |

Ten of thirteen carry over from Study 1, so pilot and confirmatory test share
footage. Race 32 is the addition — unanimous catch-up across all three 2013 raters
plus OP. Four catch-up clips is the threshold for 2 NM + 2 NW per participant,
since nobody can see a clip twice.

Race 16 is contested (OP + Kate say catch-up, Yin says stable) and is **declared in
advance**. It is defensible because a mislabelled clip dilutes the catch-up cell and
biases toward the null — it makes the study harder to pass, not easier. The claim
that Study 1's data settles the label is circular and is not made.

#### Design

20 trials (12 close: 2 NM + 2 NW per trajectory; 8 clear), **N = 100**, roles
assigned by **rotation** rather than random draw. Study 1's random draw left race 20
at 27 NM vs 11 NW and gave 14% of participants no catch-up near miss at all.

N = 100 from the pilot's within-participant contrast (dz = 0.28 → N ≈ 103 at 80%
power); pessimistic, since most pilot participants had only one catch-up trial.

#### Open

- Runner counts and vacant traps for races 31, 32, 35 before they can enter the task.
- Videos to copy into the Study 2 build; consider re-encoding at CRF 26 (the trimmed
  set is 132 MB).
