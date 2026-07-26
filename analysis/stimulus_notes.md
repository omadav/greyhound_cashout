# Stimuli — greyhound race clips

## Source

39 clips from the 2013 Cambridge study (Kate Champion Part II project; raters
Luke Clark, Kate Champion, Yin Wu). Real UK greyhound races, ~20–27 s each. The
original `.avi` files were converted to browser-ready H.264 `.mp4` (854×480); the
originals are archived untouched.

## Usable set

**Study 1 used races 1–23.** These end on the result board (1st/2nd/3rd traps +
race time visible), so the finish is verifiable. `test.avi` is the practice clip.

> **Corrected 2026-07-25:** races 24–38 were originally written off here as "cut
> off before the line". That was wrong — see *Races 24–38* below. They lack the
> trackside **result board**, not the finish. All 37 usable clips now exist with the
> board removed in `Races_noboard/`, so the whole archive is available to Study 2.

Standard UK trap jackets (1 red, 2 blue, 3 white, 4 black, 5 orange, 6 black/white
stripes) let a participant track their assigned dog. Five races ran with a vacant
trap (5 dogs): races 2, 10, 16, 19, 22 — the task offers only the dogs that
actually ran on those trials. Finishing order comes from the 2013 result sheets,
cross-checked against the scoreboard shown at the end of each clip.

## How a clip becomes a condition

Each clip is experienced from the point of view of the participant's secretly
assigned trap:

- clear race, assigned the winner → **clear win (CW)**
- clear race, assigned a back dog → **clear loss (CL)**
- close race, assigned the winner → **narrow win (NW)**
- close race, assigned the runner-up → **near miss (NM)**

So one close clip yields *both* a narrow win and a near miss depending on
assignment — NW and NM are the same footage seen from the two lead dogs.

## How the clear-vs-close labels were decided

1. **2013 coding.** The original team coded event type (winner's perspective) plus
   a "Distance" column — the finishing time-gap between 1st and 2nd, in seconds —
   and defined a *narrow win* as 2nd within 0.09 s and a *clear win* as 2nd more
   than 0.26 s. About half the pool fell in the undefined 0.09–0.26 s middle, and
   the consensus column was left blank for most races, so the 2013 classification
   was never completed.

2. **Why we didn't classify from that gap.** The gap is derived from race *times*,
   not visible closeness; checked against the footage it didn't track how close the
   finish *looked* (in places it behaved more like a 2nd-to-3rd gap). It is kept
   only as a continuous covariate, not the classifier.

3. **Eye-coding (Omar).** Each of the 23 finishes was judged by eye as **clear win
   vs close/narrow** — the axis that actually determines whether the runner-up
   experiences a near miss. Result: **11 clear, 12 close.**

4. **Agreement with 2013.** The eye split matches the 2013 raters' consensus on
   **20 of 23** races. Two races (3, 20) had no 2013 consensus to compare against.
   **Exactly one race disagrees — race 18** — read as a clear win by eye but coded
   stable/narrow in 2013 (and only 2 of 3 raters agreed even then). Race 7 was an
   initial disagreement, but on re-watch it was a genuine photo finish and was
   corrected to *close*, bringing it into line with 2013.

## Trajectory sub-coding (exploratory)

### The coding rule (Omar, 2026-07-25) — always from the LOSING dog's point of view

The trajectory describes what the **runner-up** did, i.e. the dog the participant
is assigned to on a near-miss trial. It is never described from the winner's side.

| label | what the losing dog did |
|---|---|
| **fall-back** | was ahead, then got caught before the line |
| **catch-up** | was closing on the leader, did not quite get there |
| **stable** | finished close, but the gap stayed roughly constant |

This is a fixed property of the clip: in any one race the runner-up either was
caught or was closing. It cannot be reassigned across participants the way CW /
NW / NM / CL can. Trap assignment sets *which condition* a participant gets, not
which trajectory.

**Judge it on the home straight, not the whole race** (Omar, 2026-07-25). What
matters psychologically is the expectation the participant is holding as the race
resolves. A dog that was passed on the back straight and then trailed home has not
delivered a near miss of the fall-back kind in any meaningful sense — the outcome
was settled well before the line. Likewise an early surge that fades is not a
catch-up. Only the final section builds or destroys the expectation of winning.

This is likely the source of the Kate/Yin disagreements: Kate appears to code the
race as a whole (so an early catch-up counts as catch-up), Yin codes the finish.
Races 24 and 36 are both cases where an early pass made the race look like one type
while the home straight showed another. Omar's coding follows the home straight.

**Body overlap as the visual yardstick.** Omar judges closeness by whether the dogs'
bodies overlap at the line, not by the recorded time gap (which repeatedly fails to
track the visual impression — race 16 is 0.42s yet reads close, race 30 is 0.14s yet
reads clear). A catch-up where the runner-up draws level enough to overlap the
leader is stronger than one where it closes but stays clear; race 33 is the milder
kind ("6 comes closer but not quite close enough to overlap the leader's body").
Worth recording per clip, as it may grade the size of the near-miss effect.

**Interference is a separate flag.** Race 26 contains a bump. Being baulked is an
attributional event (bad luck, unfairness) and is psychologically distinct from a
near miss; such races should probably be excluded from both pools, or at least
coded so the assumption can be checked.

### The two 2013 sources, and which one to use

There are two separate 2013 documents and they use **opposite perspectives**.
Getting these confused is what produced the mislabelling found on 2026-07-25.

1. `KateChampion/RaceComments.docx` — column header reads *"Event type (from
   perspective of **winning** dog)"*. Its "catch-up" means the WINNER came from
   behind, i.e. the loser fell back. **This is the mirror of our rule. Do not read
   it directly.**
2. `Notes on Races/ratings 2013-09-08.xlsx`, Sheet1, the Yin Wu column — uses
   *"Near Miss – Overtake finish"* / *"Near Miss – Catch up finish"* / *"near miss
   – stable"*. This is already **from the near-miss dog's side**, i.e. our rule.
   `overtake finish` = fall-back, `catch up finish` = catch-up.

The `shape_prior` column in `race_coding_sheet.csv` follows source (2), so it is in
the right frame. It agrees with Omar's own viewing on 9 of the 12 close races.

### Where Omar and Yin disagree

Omar's viewing is authoritative; Yin is recorded for reference.

| race | Omar | Yin | resolution |
|---|---|---|---|
| 3 | catch-up | ambiguous | Omar settles it — winner 3 was being caught by 4 and 5 |
| 16 | catch-up | stable | Omar + Kate vs Yin — 2 of 3 for catch-up. **Still contested.** |
| 36 | fall-back | fall-back | agreed after Omar's close viewing (first pass said catch-up) |
| 5 | fall-back | fall-back | agreed — trap 1 led, caught by 2 and 3 in the home straight |
| 38 | stable | fall-back | contested |

Every trajectory label used in fig5 is now either Omar's own call (3, 4, 16, 5) or
Yin's in the correct frame (7, 9, 15, 2, 14, 20, 21, 22). None is the assistant's
reconstruction, which is what the earlier version of this file wrongly relied on.

## Pool composition (races 1–23)

![Stimulus pool composition](stimulus_pool_distribution.png)

- **Clear: 11** (races 1, 6, 8, 10, 11, 12, 13, 17, 18, 19, 23) → supply CW and CL
- **Close: catch-up: 3** (races 3, 4, 16) → NW + catch-up NM
- **Close: fall-back: 4** (races 5, 7, 9, 15) → NW + fall-back NM
- **Close: stable: 5** (races 2, 14, 20, 21, 22) → NW + stable NM

Catch-up is the scarce type — the bottleneck for a confirmatory trajectory study.

## Races 24–38 — NOT written off (corrected 2026-07-25)

These were previously excluded on the grounds that "the finish line is not visible".
**That was the wrong test.** What those clips lack is the trackside *result board* at
the end; the finish line itself is visible, and the board is unnecessary because the
task announces the outcome on its own result screen. Confirmed by Omar on race 38:
*"it doesn't have the final display, but the finish line is clear."*

The AVI and MP4 durations match exactly for these races, so nothing was lost in
conversion — the sources simply end sooner.

Coded so far from this set (Omar, 2026-07-25):

| race | kind | trajectory | finish | vs Yin |
|---|---|---|---|---|
| 32 | close | **catch-up** | 2, 6, 4 | agrees |
| 36 | close | fall-back | 1, 6, 2 | agrees |
| 37 | clear | — | 1, 3, 5 | resolves a 2013 "disputed" |
| 38 | close | stable | 6, 1, 2 | Yin says fall-back |

Race 32 matters most: it is a catch-up that Omar and Yin both endorse, so recovering
this set is the cheapest route out of the catch-up shortage. Races 24, 25, 26, 27,
30, 31, 33, 34, 35 are still uncoded.

**Blocker:** none of 24–38 can enter the task until each has a runner count and a
list of vacant traps — `trial-config.js` needs `nRunners` and `missing` to build the
race card. These are marked `NEEDS-COUNT` in `stimulus_pool.csv`. The video files
also still need copying into `docs/assets/videos/` and the Pavlovia build.

Adding races mid-run would change the stimulus pool underneath the 44 participants
already collected, so the expanded pool belongs to Study 2, not to Study 1.

## `Races_noboard/` — the uniform stimulus set (2026-07-25)

Races 1–23 end on the trackside result board; races 24–38 do not. Mixing them in one
session would be visibly inconsistent, and the board also constrains what the task can
display (participants could read the real 1st/2nd/3rd off it).

`Races_noboard/` fixes that: **every clip now ends at the track, with no board.**

- races 1–23 — trimmed at the frame the board cut appears, minus a 0.2 s safety margin
- races 24–38 — copied unchanged (no board in the source)
- race 26 — omitted entirely (interference)

37 clips, 19.7–24.5 s each. Cut points are recorded in `video_trim_log.csv` so the set
is reproducible from `Races/`. The directory itself is gitignored, like `Races/`.

The board start was found by taking the final frame as a reference and walking backwards
until the picture changed sharply (the board is static, so board frames are near-identical
to the last frame). A fixed difference threshold failed on race 5, where the camera settles
onto the board over ~0.7 s; using the *largest* jump instead fixed it. Every cut was then
checked by eye, frame before versus frame after.

**Not yet deployed.** Swapping these into `docs/assets/videos/` would change Study 1's
stimuli underneath the 44 participants already collected. Study 1 should keep the board
versions; the trimmed set is for Study 2.

## Per-race table

`kind`: clear/close by eye. `2013`: derived from the original raters
(clear / close / no-consensus). `agree`: eye vs 2013. `trajectory`: for close
races only. Finishing order shown as winner/2nd/3rd trap.

| race | runners | order (1/2/3) | kind (eye) | 2013 | agree | trajectory |
|---|---|---|---|---|---|---|
| 1 | 6 | 1/4/2 | clear | clear | ✓ | — |
| 2 | 5 (no 4) | 3/2/1 | close | close | ✓ | stable |
| 3 | 6 | 3/4/5 | close | no-consensus | — | catch-up |
| 4 | 6 | 3/5/2 | close | close | ✓ | catch-up |
| 5 | 6 | 2/3/1 | close | close | ✓ | fall-back |
| 6 | 6 | 6/3/5 | clear | clear | ✓ | — |
| 7 | 6 | 6/2/3 | close | close | ✓ | fall-back |
| 8 | 6 | 6/1/3 | clear | clear | ✓ | — |
| 9 | 6 | 4/1/2 | close | close | ✓ | fall-back |
| 10 | 5 (no 6) | 1/3/4 | clear | clear | ✓ | — |
| 11 | 6 | 4/1/2 | clear | clear | ✓ | — |
| 12 | 6 | 6/3/5 | clear | clear | ✓ | — |
| 13 | 6 | 2/1/3 | clear | clear | ✓ | — |
| 14 | 6 | 4/6/5 | close | close | ✓ | stable |
| 15 | 6 | 1/3/4 | close | close | ✓ | fall-back |
| 16 | 5 (no 2) | 6/3/1 | close | close | ✓ | catch-up |
| 17 | 6 | 5/2/6 | clear | clear | ✓ | — |
| 18 | 6 | 4/6/5 | clear | close | ✗ (only diff) | — |
| 19 | 5 (no 6) | 1/3/4 | clear | clear | ✓ | — |
| 20 | 6 | 1/4/5 | close | no-consensus | — | stable |
| 21 | 6 | 3/1/4 | close | close | ✓ | stable |
| 22 | 5 (no 6) | 3/5/4 | close | close | ✓ | stable |
| 23 | 6 | 3/5/1 | clear | clear | ✓ | — |

---

# Study 2 stimulus set (locked 2026-07-25)

## The set

13 close clips, all daytime, labels fixed before any data collection.

| trajectory | races | provenance |
|---|---|---|
| **catch-up** | 3, 4, 16, **32** | 3 carried over from Study 1, plus race 32 (unanimous 2013 + OP) |
| **fall-back** | 5, 7, 9, 15 | all Study 1, all unanimous across the three 2013 raters + OP |
| **stable** | 2, 20, 21, **31, 35** | 3 from Study 1 plus 2 new daytime clips |

Clear races (CW / CL) are drawn from the 16-clip clear pool.

## Why these

**Anchored on Study 1.** Ten of the thirteen were used in Study 1, so the
exploratory result and the confirmatory test rest on the same footage. Race 32 is
the one addition to the catch-up cell, and it is the strongest clip in the archive
for that label: all three 2013 raters and OP independently call it a catch-up.

**Four catch-up clips is the threshold.** A participant cannot see a clip twice, so
2 NM + 2 NW per trajectory requires at least four clips per cell. Three would have
forced 2 NM + 1 NW, and Study 1 showed that a single trial per cell is what makes
the within-participant estimate noisy (dz = 0.28).

**Excluded and why:**

| races | reason |
|---|---|
| 14, 22, 24, 25 | night / floodlit. All sat in fall-back and stable, none in catch-up — a lighting confound that extra participants cannot average away. |
| 38 | OP codes stable, 2013 majority codes fall-back. Genuine contradiction. |
| 33 | OP codes catch-up but no 2013 rater supports it (split between "complex" and "clear miss"). |
| 26 | interference (a bump). Being baulked is an attributional event, not a near miss. |
| 27, 36 | fall-back, kept in reserve; the cell only needs four and these are 2/3 rather than 3/3. |

## Race 16 — declared in advance

Race 16 is the one contested clip in the set. OP and Kate (2013) code it catch-up;
Yin codes it stable. It is included, and the pre-registration says so.

The reason it is defensible: **if race 16 is mislabelled, it dilutes the catch-up
cell and drags that mean toward stable, which biases the test toward the null.** A
possibly-wrong clip makes the study harder to pass, not easier.

What must NOT be claimed is that Study 1's data settles the label. Race 16's
within-clip delta (−5.3) does sit between the catch-up clips (+0.9, −2.1) and the
stable ones (−9.8 to −28.0), but inferring the label from the outcome and then
testing the outcome with that label is circular. The pre-registered sensitivity
analysis drops race 16 and reports the result both ways.

## What Study 1 actually supports

Under the final labelling rules, applied to Study 1's clips only:

| labelling | catch-up | stable | test |
|---|---|---|---|
| as plotted in fig5 (16 = catch-up) | −2.2 (k=3) | −18.0 (k=5) | p = 0.011 |
| 16 → stable | −0.6 (k=2) | −15.9 (k=6) | p = 0.046 |
| + drop night races | −0.6 (k=2) | −17.0 (k=3) | p = 0.111 |

The **effect size is stable at roughly 16 rating points** across every labelling;
what collapses is the number of clips available to test it with. fig5 should
therefore be reported as exploratory, with the effect size and this sensitivity
table, and **not** with the p = 0.011, which depends on a clip now flagged as
contested.

## Design

| | |
|---|---|
| per participant | 2 NM + 2 NW in each trajectory = 12 close, + 4 CW + 4 CL = **20 trials** |
| N | **100** |
| role assignment | rotation by participant index, not random draw |
| primary DV | motivation to continue |
| primary test | within-participant catch-up vs stable on NM trials |
| secondary | within-clip NM − NW by trajectory (the fig5 analysis) |

N = 100 comes from the within-participant contrast in Study 1 (dz = 0.28, needing
N ≈ 103 for 80% power). That estimate is pessimistic because most Study 1
participants had only one catch-up near miss; two per cell should raise dz.

Rotation replaces random assignment because Study 1's random draw produced badly
uneven per-clip role counts — race 20 was seen 27 times as NM and 11 times as NW,
and 14% of participants never saw a catch-up near miss at all.
