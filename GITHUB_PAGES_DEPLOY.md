# GitHub Pages Deployment

## Goal

Publish the demo so colleagues can open one link and immediately land on the playable pilot.

The repository is set up for GitHub Pages using the `docs/` folder.

## What is already prepared

- `docs/index.html` is the landing page
- `docs/styles.css`, `docs/app.js`, and `docs/trial-config.js` are copied from the pilot
- `docs/assets/videos/demo.mp4` contains the demo clip
- `docs/.nojekyll` is included for static hosting compatibility

If GitHub Pages is enabled for the repository and pointed at `docs/`, colleagues will only need to click the resulting site URL.

## Recommended repository structure

For the cleanest GitHub setup, make `Greyhound_NM` its own standalone Git repository rather than publishing from the larger parent repository.

## Minimal manual deployment steps

1. Create a new GitHub repository, for example `greyhound-nm`.
2. Upload the contents of this `Greyhound_NM` folder to that repository.
3. In GitHub, open `Settings` -> `Pages`.
4. Under `Build and deployment`, choose:
   - `Source`: `Deploy from a branch`
   - `Branch`: your default branch
   - `Folder`: `/docs`
5. Save.
6. Wait for GitHub Pages to publish the site.
7. Share the Pages URL with colleagues.

The link will usually look like:

```text
https://YOUR-USERNAME.github.io/REPOSITORY-NAME/
```

## Before using with real participants

The current site is a **demo pilot** only.

Before Prolific use, replace or extend:

- the single demo video with a finalized stimulus set
- the placeholder trial schedule with the real metadata schedule
- local download-only data handling with server-side storage or approved survey/task infrastructure

## Updating the hosted demo

If you edit the pilot source in `pilot-task/`, copy the updated web files into `docs/` before pushing changes:

- `index.html`
- `styles.css`
- `app.js`
- `trial-config.js`
- any assets in `assets/`

At the moment, `docs/` is the deployable GitHub Pages copy.
