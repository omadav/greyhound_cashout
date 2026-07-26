#!/usr/bin/env bash
# Sync study2-task/ (the source you edit) into its two deployment copies.
#
#   study2-docs/      GitHub Pages debug build — no server save, local download
#   study2-pavlovia/  Pavlovia production build — loads pavlovia.js, has the
#                     projectId + Prolific completionURL
#
# The Pavlovia copy differs from the source in exactly two places, and a plain
# `cp` silently wipes both. That happened twice on Study 1: the second time data
# saving died with no console error, no redirect and zero sessions on the server.
# This script re-applies both every time and refuses to report success unless all
# four invariants hold.
set -euo pipefail
cd "$(dirname "$0")"

# Study 2 has its own Pavlovia project:
#   https://gitlab.pavlovia.org/omardavidperez/greyhound-cashout-v2
# PROJECT_ID is the NUMERIC experiment id from the Pavlovia dashboard, not the
# repo name. pavlovia.js posts to /experiments/<id>/sessions.
# (Study 1 was 533864 on .../greyhound-cashout — do not reuse it here.)
GITLAB_REMOTE="https://gitlab.pavlovia.org/omardavidperez/greyhound-cashout-v2.git"
PROJECT_ID=${STUDY2_PROJECT_ID:-534026}

# Prolific completion URL. THIS IS THE ONE THING THAT MUST BE NEW: every Prolific
# study issues its own completion code, so Study 1's (cc=CKEB0540) will not credit
# Study 2 participants. Set it here or pass STUDY2_COMPLETION_URL in the env.
COMPLETION_URL=${STUDY2_COMPLETION_URL:-"https://app.prolific.com/submissions/complete?cc=C1COEXC7"}

if [ -z "$COMPLETION_URL" ]; then
  cat >&2 <<'MSG'
REFUSING TO SYNC: no Prolific completion URL set.

Create the Study 2 Prolific study, copy its completion URL, then either
  edit COMPLETION_URL at the top of this script, or run:
    STUDY2_COMPLETION_URL="https://app.prolific.com/submissions/complete?cc=XXXX" ./sync_study2.sh

Deploying without it means participants finish the task and are never credited,
which is exactly the silent failure this script exists to prevent.
MSG
  exit 1
fi

mkdir -p study2-docs study2-pavlovia

# the wrapper is the one proven copy from Study 1 (115+ sessions). Single source
# of truth: it is never edited per study, it only reads projectId from the config.
cp pavlovia/pavlovia.js study2-pavlovia/pavlovia.js

for f in index.html styles.css app.js trial-config.js; do
  cp "study2-task/$f" "study2-docs/$f"
  cp "study2-task/$f" "study2-pavlovia/$f"
done

# assets: videos live in the task dir; symlink rather than triple the 81MB
for d in study2-docs study2-pavlovia; do
  rm -rf "$d/assets"
  cp -R "study2-task/assets" "$d/assets"
done

# 1. the Pavlovia copy must load the wrapper BEFORE the config
perl -0pi -e 's{(\s*)<script src="\./trial-config\.js"></script>}{$1<script src="./pavlovia.js"></script>$1<script src="./trial-config.js"></script>}' study2-pavlovia/index.html

# 2. and needs the live project id + completion URL
perl -pi -e "s{pavlovia: \{ projectId: null, completionURL: \"\" \}}{pavlovia: { projectId: $PROJECT_ID, completionURL: \"$COMPLETION_URL\" }}" study2-pavlovia/trial-config.js

ok=1
grep -q 'src="./pavlovia.js"' study2-pavlovia/index.html || { echo "FAIL: pavlovia.js script tag missing"; ok=0; }
grep -q "projectId: $PROJECT_ID"  study2-pavlovia/trial-config.js || { echo "FAIL: projectId not set"; ok=0; }
grep -q "$COMPLETION_URL"         study2-pavlovia/trial-config.js || { echo "FAIL: completionURL not set"; ok=0; }
grep -q 'pavlovia.js' study2-docs/index.html && { echo "FAIL: debug copy must NOT load pavlovia.js"; ok=0; }
[ -f study2-pavlovia/pavlovia.js ] || { echo "FAIL: pavlovia.js wrapper missing from the build"; ok=0; }
grep -q 'unverified: true' study2-pavlovia/trial-config.js && { echo "FAIL: pool still has unverified races"; ok=0; }

if [ $ok -eq 1 ]; then
  echo "sync OK: study2-docs/ (debug) and study2-pavlovia/ (production) updated, projectId=$PROJECT_ID"
  echo
  echo "To deploy:"
  echo "  cd study2-pavlovia"
  echo "  git init && git remote add origin $GITLAB_REMOTE   # first time only"
  echo "  git add -A && git commit -m 'Study 2 task' && git push -u origin master"
  echo
  echo "NOTE: Pavlovia pulls refs/heads/MASTER, not main. Pushing to main gives a"
  echo "      500 error when you set the experiment to Running:"
  echo "      'configuration specifies to merge with the ref refs/heads/master ...'"
fi
exit $((1-ok))
