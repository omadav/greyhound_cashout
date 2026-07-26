# Study 2 — pre-registration (AsPredicted format)

**Title:** Does the shape of a near miss matter? Catch-up vs fall-back vs stable near
misses in an ecologically valid greyhound betting task

**Authors:** Omar D. Perez, Luke Clark, Steve Sharman, Mike Aitken

**Status:** draft — nothing collected. Data collection begins after this is filed.

---

## 1) Has data collection begun?

No.

Study 1 (N = 44, complete) is the exploratory motivation for this study and is
described in section 9. No Study 2 data exist.

## 2) What's the main question being asked, or hypothesis being tested?

When a gambler almost wins, does it matter *how* they almost won?

Participants bet on real greyhound races and are covertly assigned to a trap, so the
same clip delivers a narrow win to some participants and a near miss to others. Near
misses are of three kinds, defined by what the participant's dog did **in the home
straight**:

- **catch-up** — the dog was closing on the leader and ran out of track
- **fall-back** — the dog was ahead and was caught before the line
- **stable** — the finish was close but the gap never changed

**H1 (primary).** Motivation to continue playing is higher after a **catch-up** near
miss than after a **stable** near miss.

**H2.** Fall-back near misses fall between the two, and are lower than catch-up.

The reasoning: a catch-up near miss maximises the sense that winning was within reach
and was interrupted, which should sustain the urge to play again. A stable near miss
is close on the scoreboard but never felt winnable.

## 3) Describe the key dependent variable(s) specified precisely.

**Primary DV:** *"Right now, how much do you want to play the next race?"*, a 0–100
visual analogue slider presented after each race.

**Secondary DVs**, same scale and screen:

- *"How pleased were you with the outcome of this race?"* (0 = not at all pleased)
- *"How lucky did you feel in that race?"* (0 = not at all lucky)

**Control DV:** pre-race confidence, *"How confident are you that your dog will
win?"*, rated **before** the race. This cannot be affected by the outcome, so it
should show no effect of trajectory. If it does, assignment is leaking.

Sliders start at a random position and must be moved before the participant can
continue, so an unmoved slider cannot be recorded.

## 4) How many and which conditions will participants be assigned to?

Fully within-subject. 20 trials:

| condition | trials | what the participant experiences |
|---|---|---|
| catch-up near miss | 2 | finishes 2nd, was closing |
| fall-back near miss | 2 | finishes 2nd, was caught |
| stable near miss | 2 | finishes 2nd, gap constant |
| narrow win | 6 | finishes 1st in a close race (2 per trajectory) |
| clear win | 4 | finishes 1st in a clear race |
| clear loss | 4 | unplaced in a clear race |

Trial order is randomised, with the constraint that the first trial is never a near
miss or a clear loss.

**Counterbalancing.** Trajectory is a fixed property of a clip and cannot be
assigned. Role can: within each trajectory, clips are ordered and participant *i*
takes the four starting at position *i* mod *k*, the first two as near misses and the
rest as narrow wins. Over a full cycle every clip serves in both roles equally often.
No participant ever sees a clip twice.

**Stimuli (locked before collection).** 12 close clips, all daytime footage, all
ending at the finish line with the trackside result board removed:

| trajectory | races |
|---|---|
| catch-up | 3, 4, 16, 32 |
| fall-back | 5, 7, 9, 15 |
| stable | 2, 20, 21, 35 |

Clear races (CW/CL) are drawn from a pool of 11.

## 5) Specify exactly which analyses you will conduct.

**Primary.** For each participant, mean motivation across their 2 catch-up near
misses and across their 2 stable near misses. Paired *t*-test on the difference,
two-tailed, α = .05. H1 predicts catch-up > stable.

**Secondary.**

1. One-way repeated-measures ANOVA over the three trajectories on motivation, with
   planned contrasts catch-up vs stable and catch-up vs fall-back.
2. **Within-clip analysis.** For each clip, mean(near miss) − mean(narrow win) across
   participants. Because the same footage supplies both, everything about that
   particular race cancels. These per-clip differences are compared across
   trajectories. This was the analysis that produced the exploratory result.
3. Mixed model: `motivation ~ trajectory + (1 | participant) + (1 | clip)`, treating
   both participants and clips as random.
4. The same three tests on pleasure and on luck.
5. Does PGSI moderate the trajectory effect? `motivation ~ trajectory * PGSI +
   (1 | participant)`. Exploratory.

**Manipulation check.** Pre-race confidence must not differ by trajectory.

**Excluded clips, and why (decided before collection).** Race 31 was dropped: the
2013 raters split three ways on it (stable / complex / fall-back) and OP's own
reading changed across viewings. Race 38 was dropped because OP's label contradicts
a 2013 majority. Four floodlit night races were dropped because all sat in the
fall-back and stable cells and none in catch-up, which would have confounded
trajectory with lighting. Race 26 was dropped for interference (a dog was baulked),
which is an attributional event rather than a near miss.

**Sensitivity analysis (committed in advance).** Race 16's trajectory label is
contested — OP and one 2013 rater code it catch-up, another codes it stable. The
primary analysis includes it. We will additionally report the primary test with race
16 excluded. If the two disagree, both are reported and the result is described as
label-dependent.

## 6) Any secondary questions?

Trajectory shapes the narrow win as its mirror image: in a fall-back clip the winner
came from behind, and in a catch-up clip the winner held off a charge. We will test
whether coming from behind to win is rated higher than holding on. Exploratory; same
data, no extra trials.

## 7) How many observations will be collected?

**N = 100** UK participants via Prolific, after exclusions. We will over-recruit to
reach 100 usable datasets.

**Justification.** Study 1 gave a within-participant catch-up vs stable difference of
dz = 0.28, which needs N ≈ 103 for 80% power (two-tailed, α = .05). That estimate is
conservative: most Study 1 participants saw only **one** catch-up near miss, so each
person's estimate rested on a single trial. Study 2 gives two per cell, which should
reduce that noise and raise dz. If dz reaches 0.34, N = 72 suffices; we retain N = 100
so the study is adequately powered under the pessimistic estimate.

## 8) Anything else you would like to pre-register?

**Exclusions, applied before analysis:**

- did not complete all 20 trials
- failed any attention check. Two types: a slider instruction check ("move the slider
  to X"), and an outcome check asking where the dog finished, presented after the
  video but before the result screen so the answer cannot be read off it
- straight-lining: zero variance across trials on any rating scale
- median trial RT below 2 s

**Payment.** £2.00 completion fee plus a £2.00 bonus in in-task credits. Every
participant wins exactly 10 of the 20 races (4 clear wins + 6 narrow wins) -> 100
credits at £0.02 each, so the bonus is the same for everyone. It is motivational
framing, not variable pay.

**No cash-out.** The cash-out mechanic exists in the codebase but is disabled for
this study.

**Deception.** Outcomes are determined by covert trap assignment, but all displayed
finishing orders are the **real** results of the races. Participants are not shown
false outcomes. Debriefing explains the assignment.

**Ethics.** Approved protocol on file (FCFM, Universidad de Chile).

---

## 9) Prior work: Study 1 (exploratory, not confirmatory)

Study 1 (N = 44) tested the basic near-miss effect and found it clearly: near misses
produced lower motivation than narrow wins and higher than clear losses.

The trajectory split was added **after** the data were collected and is exploratory.
Analysed within clip, motivation fell by 2.2 points for catch-up near misses, 8.9 for
fall-back and 18.0 for stable — the ordering H1 predicts.

That result should be treated as a hypothesis, not evidence, for three reasons:

1. It was found post hoc.
2. It rested on 3 catch-up clips, and its significance depended on race 16 — the clip
   now flagged as contested. Under stricter labelling the effect size holds at ~16
   rating points but the *p*-value moves from .011 to .111 as clips drop out.
3. The trajectory labels were partly reconstructed after the fact.

Study 2 fixes all three: labels are set in advance by a stated rule, race 16 is
declared and tested both ways, and the design is balanced by construction.

**Note on race 16.** Including a possibly-mislabelled clip in the catch-up cell drags
that cell's mean toward stable, which biases the primary test **toward the null**. It
makes the study harder to pass, not easier. We are not claiming that Study 1's outcome
data settles the label — inferring a label from the outcome and then testing the
outcome with that label would be circular.
