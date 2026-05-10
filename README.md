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

## Future Sessions

Append future dated entries to the `Session Log` section above so this file becomes a running record of design decisions, coding progress, and open questions.
