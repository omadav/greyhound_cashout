# Study 6

Pavlovia project: https://pavlovia.org/omardavidperez/greyhound-cashout-v6
GitLab project ID: 538074.
Prolific completion code: C1AAQL25.

Two groups, assigned once before consent/instructions: betting on every race
(Study 4's 0–100% slider) or no betting throughout. Both receive the same race
pool, role-rotation scheme, condition counts, questions, and checks. Each session
has 20 races: 4 CW, 6 NW, 6 NM, 4 CL, with 2 NM and 2 NW per trajectory.

The primary outcome is the participant's average confidence across all 20 races.
Compare these participant averages between groups, irrespective of race outcome.
Sequence: choose dog → confidence → bet (betting group only) → race → ratings.
The betting stage adds a decision and time; this is part of the treatment, not
an exactly time-matched control. No-betting participants never see a balance or
betting availability on later trials. Both see only their own task instructions.

## Assignment

`crypto.getRandomValues` makes an independent 50/50 draw for each participant.
Save the assignment in localStorage keyed by the Prolific participant ID. Reloads
in the same browser preserve it. This gives approximate, not exact, group balance.
The draw is separate from the race-rotation index. Every trial logs group,
assignment method, assignment time, and task version. The primary analysis must
check for duplicate participants and inconsistent assignments. This client-only
setup cannot retain an assignment across browsers/devices or after storage is
cleared; do not tell participants to restart on another device.

## Payment

Keep the existing base payment. Betting bonus uses the existing formula:
`0.50 + 1.50 * min(finalBalance / 100, 1)` GBP, rounded to pennies.
The balance floor is 20, so the minimum completed-session bonus is GBP 0.80.
No-betting bonuses are assigned after collection by matching to betting bonuses;
their own outcomes never set their bonus. Their CSV therefore leaves `bonusGBP`
blank and records `bonusAssignment=matched-after-collection`. Matching/payment is
an offline step, not performed by the browser; do not use the unchanged 100-point
internal balance to calculate a no-betting bonus. Pay completed participants
regardless of their analysis exclusions. No payments are sent by these files.

## Prolific description

You'll watch 20 short greyhound race videos. For each race, choose a dog to follow,
rate how confident you are that it will win, and answer a few questions after the result.

The task also includes some decisions, which will be explained before you begin.
You'll receive a base payment plus a bonus. You will never risk your own money.

At the end, there's a short questionnaire about gambling habits.

Takes about 20–25 minutes.

Use one common study link with the Prolific participant, study, and session
placeholders. Exclude participants from Studies 1–5. Sample size and any formal
preregistration still need to be set before recruitment.

## Local preview and deployment

Run `bash sync_study6.sh --debug`, then serve this repository locally and open
`/study6-docs/?group=betting` or `/study6-docs/?group=no_betting`.
Group overrides and shortened `?reps=1` runs work only on localhost.

After deployment, use these 8-race Pavlovia checks without Prolific identifiers:

- betting: `https://run.pavlovia.org/omardavidperez/greyhound-cashout-v6/?test_mode=1&reps=1&group=betting`
- no betting: `https://run.pavlovia.org/omardavidperez/greyhound-cashout-v6/?test_mode=1&reps=1&group=no_betting`

The test parameters are ignored whenever a Prolific participant ID is present.

Set `STUDY6_COMPLETION_URL` to the new Prolific completion URL and run
`bash sync_study6.sh` to prepare `study6-pavlovia/`. The script does not deploy.
The default completion URL uses code C1AAQL25.
Do not deploy raw data, bonus matches, or analysis outputs to the public repository.
