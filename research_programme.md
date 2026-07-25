# Greyhound near-miss / cash-out: research programme

Working document for the Cambridge collaboration (Clark, Sharman, Aitken, Perez).
Draft — 2026-07-24.

## Unifying idea

Every study here turns on one construct: **counterfactual thinking under
unfolding uncertainty**, and its anticipatory correlates. A near miss is a
counterfactual ("I almost won"); the *route* to it, the *decision* taken during
it, and the *person* experiencing it are the manipulations. **PGSI (gambling
risk) is the moderator running through all four studies** — the individual-
difference story is that near/close events bias the at-risk gambler more.

The greyhound clips give a controlled but ecologically valid vehicle: the
participant covertly "owns" one trap, and the same footage yields wins, narrow
wins, near misses, and clear losses depending on assignment. The **run-in**
(final seconds before the line) is a natural, controlled **anticipation window**.

## Study 1 — the near-miss effect (DONE)

**Question.** Do near misses sustain the urge to keep playing more than clear
losses, in an ecologically valid race task?

**Design.** Within-subject, 20 races, 4 conditions from trap assignment:
clear win (CW), narrow win (NW), near miss (NM), clear loss (CL). Post-race
ratings: pleasure, motivation to continue, luck; pre-race confidence as a
control. PGSI at the end.

**Result (n≈44, Pavlovia/Prolific).** NM > CL on motivation, paired t ≈ 5,
**p < 1e-5**; mixed-model condition effect F ≈ 93, p < 2e-16. Confidence flat
across conditions (validity check — rated before the outcome). Pleasure and luck
track outcome monotonically. Robust from n≈20 onward. **PGSI × condition
interaction p ≈ .015** (mixed model), though the participant-level correlation is
small and marginal (r ≈ .30, p ≈ .06) — a genuine but modest moderation that a
properly powered confirmatory study should settle.

**Status.** Established. The anchor for the programme.

## Study 2 — trajectory controlled (catch-up vs fall-back)

**Question.** Does the *direction* of the counterfactual matter? Two near misses,
same 2nd place:
- **fall-back** ("from above"): led, caught at the line → loss of a possessed
  lead → regret.
- **catch-up** ("from below"): closing at the line, fell short → truncated
  reward-approach / momentum.

**Prediction.** Catch-up sustains motivation more than fall-back (a descriptive
hint already in the Study 1 data: catch-up 64 vs fall-back 59 vs CL 49). The two
recruit different mechanisms (see Neural extension).

**Design.** Trajectory-balanced stimulus set: catch-up and fall-back near misses
matched in number and finishing closeness, enough clips per cell that trajectory
is not confounded with clip identity.

**Dependency (blocking).** The current footage has only ~3 clean catch-up clips.
Trajectory is a *fixed property of the clip* — it cannot be counterbalanced across
participants the way CW/NW/NM/CL can — so this study needs **more catch-up footage**
(recover races 24–38 if their finish line can be identified, or source new clips),
not just more participants.

## Study 3 — cash-out as risk-taking

**Question.** During the race, participants can cash out (guaranteed partial
payoff) or let the bet ride. When does a person fold, and does it track race
state and gambling risk over and above their baseline risk attitude?

**Design.** Mid-race cash-out at a pre-coded pause. Manipulate offer value ×
race state at the pause. DV = accept/reject (and RT). Crucially, measure risk
aversion in a **separate lottery-choice block** (sure amount vs gamble), fit a
per-participant utility-curvature parameter, and enter it as a covariate — so a
cash-out is not simply "this person is risk-averse."

**Test.** Do race dynamics and PGSI predict folding *over and above* baseline
risk aversion? (Consult Ty Hayes, Warwick, on how operators set cash-out values,
so the offer schedule is realistic.)

## Study 4 — cash-out × near-miss

**Question.** Does the cash-out decision change the impact of the near miss?

**Rationale.** Cashing out and *then* watching your dog nearly win is the
strongest counterfactual in the whole design — "I gave it away." It should
produce sharp regret and, plausibly, *increased* subsequent persistence
(chasing). Staying in through a near miss should show the amplified near-miss
effect. The cash-out decision thus becomes a within-task manipulation of
counterfactual strength.

**Design.** Cross the cash-out decision (folded / held) with the subsequent
outcome (win / near miss / loss), and read out post-outcome affect, regret, and
motivation — plus any behavioural persistence measure.

## The connective insight

The cash-out is taken **during the run-in — inside the anticipation window**. So
the cash-out choice is the **behavioural readout of the anticipation signal**:
- catch-up (rising anticipation from below) → hold;
- fall-back (anticipated loss from above) → fold.

The same anticipatory process is expressed three ways across the programme:
as a **neural signal** (Study 2, EEG), a **behavioural choice** (Study 3,
cash-out), and a **counterfactual amplifier** (Study 4).

## Neural extension (EEG / fMRI)

- **Anticipation:** the **Stimulus-Preceding Negativity (SPN)** — a slow
  right-frontal potential that builds before feedback and indexes affective
  anticipation. Time-lock to the run-in and test catch-up (building toward a
  possible gain) vs fall-back (toward a possible loss).
- **Outcome:** fall-back → regret circuitry (lateral OFC; Coricelli, Camille);
  catch-up → win-related striatal/insula recruitment (cf. Clark et al. 2009,
  *Neuron*, gambling near-misses recruit win circuitry; Clark 2012).
- Framing: Kahneman & Varey (1990), "the loser that almost won."

## Cross-cutting design constants

1. **PGSI moderation** in every study (the at-risk-gambler individual-difference
   story). Enter as PGSI × condition in the mixed model, not a crude
   participant-level correlation.
2. **Pause timing.** The cash-out / anticipation window must sit in genuine
   uncertainty — late enough to matter, before the outcome is obvious. One coding
   decision serves the cash-out (Studies 3–4) *and* the EEG anticipation window
   (Study 2 neural).
3. **Risk-aversion covariate** (separate lottery block) for anything involving
   cash-out.
4. **Counterbalancing.** CW/NW/NM/CL are counterbalanced across videos (each clip
   serves multiple conditions across participants); trajectory cannot be, hence
   the Study 2 footage requirement.

## Status / dependencies

| Study | Question | Status | Needs |
|---|---|---|---|
| 1 | Near-miss effect | **Done** (n≈44, p<1e-5) | — |
| 2 | Catch-up vs fall-back | Designed | more catch-up footage; (EEG optional) |
| 3 | Cash-out as risk-taking | Designed | lottery block; Ty Hayes on offer values |
| 4 | Cash-out × near-miss | Sketched | Study 3 machinery + regret/persistence measures |

Confirmatory sampling: the original proposal's ~200 is right for the main effects
and gives real power for the PGSI moderation and PGSI-band splits.
