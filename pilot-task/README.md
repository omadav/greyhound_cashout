# Pilot Task

## What this is

This folder contains a lightweight browser prototype of the proposed Prolific greyhound task.

It is designed to test the **task flow**, not to serve as a finalized experiment yet.

Current flow:

1. participant chooses a dog
2. chosen dog is mapped to a forced trap
3. participant rates confidence
4. race video plays
5. task pauses for a mid-race cash-out choice
6. final outcome is shown
7. participant rates pleasure, motivation, and luck
8. session data can be downloaded as JSON or CSV

## Important limitation

This pilot now uses the internal file:

- `./assets/videos/demo.mp4`

for all demo trials.

That means:

- the pilot is suitable for testing interface logic and data capture
- the pilot is **not** yet suitable for real participant data collection
- the full study still needs a proper stimulus schedule and browser-ready converted race videos

## Files

- `index.html`: task markup
- `styles.css`: task styling
- `trial-config.js`: demo trial definitions and dog metadata
- `app.js`: task logic and local data export

## How to run locally

From the project root:

```bash
cd pilot-task
python3 -m http.server 8000
```

Then open:

```text
http://localhost:8000
```

Using a local web server is recommended because browsers are stricter about video loading from direct `file://` URLs.

## What to replace next

Before turning this into the real Prolific task, replace the demo setup with:

- converted `.mp4` versions of the chosen race videos
- one finalized stimulus metadata file
- one finalized trial schedule
- comprehension checks and consent/debrief pages if needed

## GitHub readiness

This folder is intentionally dependency-light so it can be moved into its own repository, or kept inside the larger `Greyhound_NM` project, with minimal cleanup.

For click-to-play sharing on GitHub Pages, use the prebuilt deploy copy in `../docs/`.
