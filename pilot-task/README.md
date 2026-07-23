# Study 1 task

## What this is

Browser build of the near-miss greyhound race task (Study 1: 4 conditions, no
cash-out). Dependency-light — plain HTML/CSS/JS, no build step.

## Flow

Per race:

1. choose a dog by name
2. see which trap it runs from (with its jacket colour)
3. rate confidence (slider has no central default — must be moved)
4. watch the real race video
5. see the outcome (top 3, or "unplaced")
6. rate pleasure, motivation to continue, and luck

Then, once after the last race: the PGSI questionnaire, then JSON/CSV download.

## How the conditions work

Each participant does 20 races, 5 of each condition. The condition is set by which
race is shown and which trap the chosen dog is secretly mapped to:

| Condition | Race kind | Chosen dog's trap | Outcome |
|---|---|---|---|
| CW clear win | clear | winner | 1st |
| NW narrow win | close | winner | 1st |
| NM near miss | close | runner-up | 2nd |
| CL clear loss | clear | a back trap | unplaced |

The schedule is generated fresh per participant: races drawn from the pool, dog
names drawn from a database (fresh each race), order randomised with light
constraints (no more than two of a condition in a row; never opens on a loss).

## Files

- `index.html` — task markup
- `styles.css` — styling
- `trial-config.js` — `STUDY` object: settings, race pool (races 1-23), dog names
- `app.js` — schedule generation, task logic, data export
- `assets/videos/1.mp4 … 23.mp4` — race clips (gitignored here; the committed copy
  lives in `docs/assets/videos/` which is what GitHub Pages serves)

## Run locally

```bash
cd pilot-task
python3 -m http.server 8000
# open http://localhost:8000
```

## Turning on the cash-out (Studies 3 and 4)

Set `cashout: true` in `trial-config.js`. The cash-out machinery (offer, pause at
~75% of the clip, accept/reject, points) is already wired; it is just gated off
for Study 1.

## Still to do before real data collection

- final scale wording (Luke to confirm), then update the slider labels
- server-side data storage instead of local download
- consent and debrief pages
- comprehension checks
