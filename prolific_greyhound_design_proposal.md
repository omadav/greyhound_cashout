---
title: "Prolific Greyhound Race Task: Design Proposal"
author: "Draft for Luke Clark, Steve Sharman, and Mike Aitken"
date: "2026-05-05"
---

# Prolific Greyhound Race Task: Design Proposal

## Purpose

This document proposes an online Prolific version of the greyhound race task using the existing race videos in `Races/` and the prior coding work by Luke, Kate, and Yin. The aim is to preserve the key psychological logic of the original lab task while making the design short, robust, browser-friendly, and easy to implement in a first web version.

The central idea remains the same:

1. Participants choose a dog by name.
2. The task backend maps that chosen name onto a trap number tied to a preselected race outcome.
3. Participants watch the race.
4. Mid-race, the race pauses and they receive a cash-out opportunity.
5. The race continues to the finish.
6. After the result, we measure affect, perceived luck, and motivation to continue.

## Materials Reviewed In This Workspace

This proposal is based on the existing project files:

- `Races/` contains 39 `.avi` files plus `test.avi`.
- `Notes on Races/ratings 2013-09-08.xlsx` contains race ratings and consensus coding.
- `KateChampion/RaceComments.docx` contains race-by-race descriptive notes.
- `KateChampion/Greyhound Experiment Procedure 2013-07-11.docx` and `KateChampion/EthicsSubmission/` describe the original lab rationale and procedure.
- `Sophie data/Dog race data/` contains saved data from the earlier app.
- `Source/Source  v1.1.zip` contains the older Windows task source code, including the logic that remaps the chosen dog onto a forced trap/outcome.

Two practical takeaways from these materials matter immediately:

- The original task already used rigged outcome assignment after participants chose a dog name.
- The original task already measured pre-race confidence, post-race pleasure, and post-race desire to continue playing.

## Recommended Research Question

How do close race outcomes change cash-out decisions and motivation to continue gambling-like play, relative to clear wins and clear losses?

A second question is whether the *progression* of the race matters over and above the final outcome, especially for close races:

- stable close finish
- catching-up finish
- overtake finish

## Recommended Condition Structure

For the first Prolific version, I recommend a simple participant-centric 4-condition design:

- `CW`: clear win
- `NW`: narrow win / almost caught at the end
- `NM`: near miss / almost won but lost
- `CL`: clear loss

This is cleaner for colleagues and participants than the older "near-win" versus "near-loss" terminology, while still preserving the same psychological distinction.

### How one video can generate different conditions

The condition is defined from the point of view of the participant's chosen dog, not from the video alone.

- If a participant's chosen name is mapped to the winner in a clear race, that trial becomes `CW`.
- If the chosen name is mapped to the winner in a close race, that trial becomes `NW`.
- If the chosen name is mapped to the runner-up in a close race, that trial becomes `NM`.
- If the chosen name is mapped to a clearly non-competitive finisher, that trial becomes `CL`.

This is the same basic logic used in the old app source.

## Stimulus Pool Recommendation

The ratings spreadsheet appears to contain 38 rated race videos plus a practice file. Based on the consensus/type coding, the current pool looks roughly like this:

- 12 clear-consensus races
- 16 near-consensus races
- 10 ambiguous or unresolved races

For the **main study**, I recommend using only the high-confidence pool first and holding ambiguous races back for piloting or later adjudication.

### Proposed high-confidence clear pool

Suitable starting candidates for `CW` and some filler/control trials:

- Races `1, 6, 8, 10, 12, 17, 19, 23, 26, 28, 29, 30`

### Proposed high-confidence near pool

Suitable starting candidates for `NW` and `NM`:

- Races `2, 3, 4, 5, 9, 15, 16, 21, 22, 25, 27, 31, 32, 35, 36, 38`

### Races to hold back pending review

These appear ambiguous, blank, or unresolved in the current notes/coding:

- Races `7, 11, 13, 14, 18, 20, 24, 33, 34, 37`

Before launch, I recommend a short final coding pass that produces one clean metadata table per video:

- `race_id`
- `video_file`
- `winner_trap`
- `runner_up_trap`
- `third_trap`
- `fourth_trap`
- `fifth_trap`
- `clear_vs_near`
- `progression_subtype`
- `usable_main_study` (`yes/no`)
- `cashout_pause_ms`
- `notes`

## Recommended Trial Structure

### Overview

I recommend:

- 3 practice trials using `test.avi` plus 2 easy demonstration races
- 16 critical trials total
- 4 filler trials to reduce predictability

That gives a 20-trial main block, which should still fit a typical Prolific session if the interface is efficient.

### Critical trial allocation

Suggested allocation:

- 4 `CW` trials
- 4 `NW` trials
- 4 `NM` trials
- 4 `CL` trials

### Filler trials

Filler trials are useful because otherwise participants may overlearn the pattern that every trial is either a clear win, a close win, a close loss, or a clear loss.

Good filler options:

- chosen dog finishes 2nd in a non-close race
- chosen dog finishes 3rd in a clear race
- chosen dog finishes 3rd in a close race

The older Sophie dataset suggests the earlier lab version already benefited from including 3rd, 4th, and 5th place outcomes.

## Recommended Trial Timeline

### 1. Dog choice screen

Participants see six dogs by name, ideally with a small set of believable stats to preserve choice engagement:

- recent form
- season win %
- average finishing position
- age
- county or kennel

I would keep this shorter than the old lab task. On Prolific, the main objective is not detailed information search unless we explicitly want to study information sampling again.

Participants choose one dog by clicking its name.

### 2. Assignment reveal

After choice, show a brief transition screen:

> "You picked Bobby. Bobby will run from Trap 4."

This is where the chosen name is invisibly mapped onto the trap tied to the preselected condition.

### 3. Pre-race confidence

Keep the original item because it already exists in the older task:

> "How confident are you that your dog will win?"

Response format:

- 0 to 100 slider
- anchors: `Not at all confident` to `Very confident`

### 4. Race video begins

Play the race video normally.

### 5. Mid-race cash-out pause

At a pre-coded timestamp for that clip, the video pauses automatically and the participant sees a cash-out offer.

Recommended wording:

> "You can cash out now for 5 points, or keep your bet running for the full 10-point outcome."

Buttons:

- `Cash out now`
- `Keep betting`

Then the race resumes immediately after response.

### 6. Outcome screen

Show:

- finishing position of the participant's dog
- whether they cashed out or let the bet run
- points earned this trial
- cumulative points total

### 7. Post-race measures

I recommend three short post-race items:

- Pleasure / satisfaction: "How pleased were you with the outcome of this race?"
- Motivation to continue: "Right now, how much do you want to play the next race?"
- Perceived luck: "How lucky or unlucky do you feel right now?"

Recommended format:

- all on 0 to 100 sliders
- use simple anchors

If you want to stay especially close to the old task, item 2 can keep the original wording almost unchanged:

> "How much do you wish to continue playing?"

## Cash-Out Design Recommendation

### Main recommendation

The cleanest first implementation is a **binary cash-out choice with randomized offer levels**.

Each trial:

- full win if they keep betting: `10 points`
- loss if they keep betting and do not win: `0 points`
- cash-out offer: randomized across `3`, `5`, or `7` points

This gives a simple behavioral dependent variable:

- accept cash-out
- reject cash-out

and also allows us to estimate how close outcomes change willingness to give up the uncertain final result for a guaranteed partial payoff.

### Why I prefer this over a slider-only cash-out question

- It is easier to implement.
- It feels more like a real betting decision.
- It produces a behavioral choice, not just a rating.
- Randomized offer levels help avoid ceiling or floor effects.

### Timing of the cash-out pause

I strongly recommend **coding one pause time per video** rather than using one global timestamp.

Reason:

- the clips are not perfectly identical in length or pacing
- "mid-race" should still leave genuine uncertainty
- the pause should occur late enough for a cash-out to feel meaningful, but early enough that the final result is not obvious

A good target is around the last 20 to 30 percent of the clip, but the exact pause should be coded per race in metadata.

## Motivation To Keep Playing

### Primary measure

Use a direct urge/persistence item after every race:

> "Right now, how much do you want to play the next race?"

This has three advantages:

- it is very close to the old lab item
- it is quick
- it gives a trial-level measure after every outcome

### Secondary behavioral measure

If you want a stronger behavioral index of persistence, add an optional end-of-block choice:

> "You can now stop, or play up to 3 extra bonus races."

The number of optional extra races accepted can serve as a more concrete persistence measure.

I would treat this as secondary. For the first web build, the post-race urge-to-play slider is enough.

## Progression Subtypes

Once the basic web task is working, the design can be extended to distinguish:

- stable close finish
- catching-up finish
- overtake finish

I would **not** make that the primary confirmatory design in version 1 unless the final race coding is exceptionally clean.

Instead:

- primary confirmatory contrast: `NM` versus `CL`, and `NW` versus `CW`
- secondary exploratory contrast: stable versus catch-up versus overtake within close races

That keeps the first Prolific study readable and adequately powered.

## Sample and Session Length

### Recommended sample strategy

I suggest a 2-stage plan:

- pilot: `40-60` Prolific participants
- main study: `200-300` Prolific participants

The pilot should answer:

- Are the instructions clear?
- Are the cash-out offers well calibrated?
- Are acceptance rates away from floor and ceiling?
- Do participants understand that their chosen dog is the one to follow?
- Are the videos smooth enough online?

### Expected duration

With 20 main trials, short instructions, and brief post-race ratings, the task should be kept around:

- `12-18 minutes` total

That is a better fit for Prolific than the original longer lab session.

## Recruitment and Exclusions

Suggested criteria:

- adults aged 18+
- fluent English
- desktop/laptop only
- no mobile devices
- good approval rate on Prolific

Suggested exclusions:

- failed comprehension checks
- did not watch enough of the videos
- repeated nonresponse
- obviously random responding

Depending on ethics preferences, it may also be sensible to exclude participants who report current treatment for gambling problems.

## Deception and Debrief

The task still relies on a mild form of deception or partial concealment if we want to preserve the illusion of control:

- participants believe they are choosing a dog in a meaningful way
- in reality, the chosen name is remapped to a trap that instantiates the target condition

This is consistent with the older lab version, but for an online study it should be handled carefully:

- debrief clearly
- explain why outcomes were constrained
- explain that the study required participants to encounter a balanced range of race types
- state explicitly that the task was not a measure of personal betting skill

If the team wants a lower-deception version, we can soften this by telling participants upfront that the study uses preselected race clips and that some elements are program-controlled. That would be ethically cleaner but may weaken the illusion-of-control component.

## Outcome Variables

### Primary dependent variables

- cash-out choice (`cash out` vs `keep betting`)
- post-race motivation to continue playing

### Secondary dependent variables

- pre-race confidence
- post-race pleasure
- perceived luck
- response times
- optional extra races accepted at the end

### Useful metadata to save every trial

- participant id
- trial number
- race id
- video file
- condition (`CW`, `NW`, `NM`, `CL`, filler)
- progression subtype
- chosen dog label shown to participant
- assigned trap
- finishing position
- cash-out offer
- cash-out response
- cash-out RT
- pre-race confidence
- post-race pleasure
- post-race motivation
- post-race luck
- points won
- cumulative points

## Analysis Plan

The simplest analysis plan is:

- mixed-effects logistic model for cash-out acceptance
- mixed-effects linear model for post-race motivation to continue

Core confirmatory contrasts:

- `NM > CL` on urge to continue
- `NW != CW` on urge to continue and cash-out choices

Exploratory analyses:

- progression subtype within close races
- whether confidence predicts cash-out behavior
- whether cashing out changes the emotional impact of the final result

## Implementation Notes For The Web Build

### Important practical issue: video format

The current race files are `.avi`. These will likely need to be converted to browser-friendly formats before a Prolific launch, probably:

- `.mp4` (H.264)
- optionally `.webm` as backup

This should happen before task coding becomes serious.

### Suggested assets/config files

For the web build, I recommend creating:

- one stimulus metadata `.csv` or `.json`
- one condition schedule file
- one video folder with web-ready copies

### Practice trials

`Races/test.avi` looks like the natural practice starting point.

## Recommended First Build

If the goal is to move quickly into implementation, I would build this exact version first:

- 4 conditions: `CW`, `NW`, `NM`, `CL`
- 16 critical trials + 4 fillers
- fixed dog-choice screen with a small set of stats
- pre-race confidence slider
- one binary cash-out decision per race
- post-race pleasure, motivation, and luck sliders
- cumulative points bonus display
- clear end-of-study debrief

This is the best balance between:

- fidelity to the original task
- psychological clarity
- feasible Prolific length
- straightforward web implementation

## Open Decisions For The Team

Before coding, I think the group should decide five things:

1. Whether version 1 should focus on the broad 4-condition design or immediately model progression subtypes.
2. Whether the task should keep the stronger illusion-of-control deception or move to a partially disclosed version.
3. Whether cash-out should affect real bonus earnings or remain hypothetical.
4. Whether the information-browsing component is central or should be simplified for speed.
5. Which exact races survive the final stimulus-quality pass.

## Bottom Line

The existing folder structure already contains almost everything needed for a strong Prolific adaptation: real race videos, prior coding notes, earlier task logic, and prior outcome measures. The cleanest first online study is a short repeated-measures design where participants choose a dog name, are covertly assigned to a target trap/outcome, receive a mid-race cash-out choice, then rate their desire to keep playing after the result.

If this proposal looks right, the next step should be to create the stimulus metadata file and then build the browser task around that schedule.
