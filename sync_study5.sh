#!/usr/bin/env bash
# Sync study5-task/ (the source you edit) into its two deployment copies.
#
#   study5-docs/      GitHub Pages debug build — no server save, local download
#   study5-pavlovia/  Pavlovia production build — loads pavlovia.js, has the
#                     projectId + Prolific completionURL
#
# Same script as sync_study4.sh, same reasons. Study 5 needs its own Pavlovia
# project and its own Prolific study (exclude Study 1-4 participants —
# they've seen this footage).
set -euo pipefail
cd "$(dirname "$0")"

# No project exists yet. Create one on Pavlovia, then either edit PROJECT_ID
# below or pass STUDY5_PROJECT_ID in the env.
GITLAB_REMOTE="https://gitlab.pavlovia.org/omardavidperez/greyhound-cashout-v5.git"
PROJECT_ID=${STUDY5_PROJECT_ID:-0}

if [ "$PROJECT_ID" = "0" ]; then
  echo "REFUSING TO SYNC: set STUDY5_PROJECT_ID to the numeric Pavlovia experiment id." >&2
  echo "Find it on the Pavlovia dashboard after creating greyhound-cashout-v5." >&2
  exit 1
fi

COMPLETION_URL=${STUDY5_COMPLETION_URL:-""}
if [ -z "$COMPLETION_URL" ]; then
  cat >&2 <<'MSG'
REFUSING TO SYNC: no Prolific completion URL set.

Create the Study 5 Prolific study, copy its completion URL, then either
  edit COMPLETION_URL at the top of this script, or run:
    STUDY5_COMPLETION_URL="https://app.prolific.com/submissions/complete?cc=XXXX" ./sync_study5.sh

Deploying without it means participants finish the task and are never credited.
MSG
  exit 1
fi

mkdir -p study5-docs study5-pavlovia

cp pavlovia/pavlovia.js study5-pavlovia/pavlovia.js

for f in index.html styles.css app.js trial-config.js; do
  cp "study5-task/$f" "study5-docs/$f"
  cp "study5-task/$f" "study5-pavlovia/$f"
done

for d in study5-docs study5-pavlovia; do
  rm -rf "$d/assets"
  cp -R "study5-task/assets" "$d/assets"
done

perl -0pi -e 's{(\s*)<script src="\./trial-config\.js"></script>}{$1<script src="./pavlovia.js"></script>$1<script src="./trial-config.js"></script>}' study5-pavlovia/index.html
perl -pi -e "s{pavlovia: \{ projectId: null, completionURL: \"\" \}}{pavlovia: { projectId: $PROJECT_ID, completionURL: \"$COMPLETION_URL\" }}" study5-pavlovia/trial-config.js

ok=1
grep -q 'src="./pavlovia.js"' study5-pavlovia/index.html || { echo "FAIL: pavlovia.js script tag missing"; ok=0; }
grep -q "projectId: $PROJECT_ID"  study5-pavlovia/trial-config.js || { echo "FAIL: projectId not set"; ok=0; }
grep -q "$COMPLETION_URL"         study5-pavlovia/trial-config.js || { echo "FAIL: completionURL not set"; ok=0; }
grep -q 'pavlovia.js' study5-docs/index.html && { echo "FAIL: debug copy must NOT load pavlovia.js"; ok=0; }
[ -f study5-pavlovia/pavlovia.js ] || { echo "FAIL: pavlovia.js wrapper missing from the build"; ok=0; }
grep -q 'unverified: true' study5-pavlovia/trial-config.js && { echo "FAIL: pool still has unverified races"; ok=0; }

if [ $ok -eq 1 ]; then
  echo "sync OK: study5-docs/ (debug) and study5-pavlovia/ (production) updated, projectId=$PROJECT_ID"
  echo
  echo "To deploy:"
  echo "  cd study5-pavlovia"
  echo "  git init && git remote add origin $GITLAB_REMOTE   # first time only"
  echo "  git add -A && git commit -m 'Study 5 task' && git push -u origin master"
  echo
  echo "NOTE: Pavlovia pulls refs/heads/MASTER, not main."
fi
exit $((1-ok))
