#!/usr/bin/env bash
# Sync study3-task/ (the source you edit) into its two deployment copies.
#
#   study3-docs/      GitHub Pages debug build — no server save, local download
#   study3-pavlovia/  Pavlovia production build — loads pavlovia.js, has the
#                     projectId + Prolific completionURL
#
# Same script as sync_study2.sh, same reasons — see that file's header if you
# want the history. Study 3 needs its own Pavlovia project and its own Prolific
# study (exclude Study 1 AND Study 2 participants — they've seen this footage).
set -euo pipefail
cd "$(dirname "$0")"

# No project exists yet. Create one on Pavlovia, then either edit PROJECT_ID
# below or pass STUDY3_PROJECT_ID in the env.
GITLAB_REMOTE="https://gitlab.pavlovia.org/omardavidperez/greyhound-cashout-v3.git"
PROJECT_ID=${STUDY3_PROJECT_ID:-0}

if [ "$PROJECT_ID" = "0" ]; then
  echo "REFUSING TO SYNC: set STUDY3_PROJECT_ID to the numeric Pavlovia experiment id." >&2
  echo "Find it on the Pavlovia dashboard after creating greyhound-cashout-v3." >&2
  exit 1
fi

COMPLETION_URL=${STUDY3_COMPLETION_URL:-""}
if [ -z "$COMPLETION_URL" ]; then
  cat >&2 <<'MSG'
REFUSING TO SYNC: no Prolific completion URL set.

Create the Study 3 Prolific study, copy its completion URL, then either
  edit COMPLETION_URL at the top of this script, or run:
    STUDY3_COMPLETION_URL="https://app.prolific.com/submissions/complete?cc=XXXX" ./sync_study3.sh

Deploying without it means participants finish the task and are never credited.
MSG
  exit 1
fi

mkdir -p study3-docs study3-pavlovia

cp pavlovia/pavlovia.js study3-pavlovia/pavlovia.js

for f in index.html styles.css app.js trial-config.js; do
  cp "study3-task/$f" "study3-docs/$f"
  cp "study3-task/$f" "study3-pavlovia/$f"
done

for d in study3-docs study3-pavlovia; do
  rm -rf "$d/assets"
  cp -R "study3-task/assets" "$d/assets"
done

perl -0pi -e 's{(\s*)<script src="\./trial-config\.js"></script>}{$1<script src="./pavlovia.js"></script>$1<script src="./trial-config.js"></script>}' study3-pavlovia/index.html
perl -pi -e "s{pavlovia: \{ projectId: null, completionURL: \"\" \}}{pavlovia: { projectId: $PROJECT_ID, completionURL: \"$COMPLETION_URL\" }}" study3-pavlovia/trial-config.js

ok=1
grep -q 'src="./pavlovia.js"' study3-pavlovia/index.html || { echo "FAIL: pavlovia.js script tag missing"; ok=0; }
grep -q "projectId: $PROJECT_ID"  study3-pavlovia/trial-config.js || { echo "FAIL: projectId not set"; ok=0; }
grep -q "$COMPLETION_URL"         study3-pavlovia/trial-config.js || { echo "FAIL: completionURL not set"; ok=0; }
grep -q 'pavlovia.js' study3-docs/index.html && { echo "FAIL: debug copy must NOT load pavlovia.js"; ok=0; }
[ -f study3-pavlovia/pavlovia.js ] || { echo "FAIL: pavlovia.js wrapper missing from the build"; ok=0; }
grep -q 'unverified: true' study3-pavlovia/trial-config.js && { echo "FAIL: pool still has unverified races"; ok=0; }

if [ $ok -eq 1 ]; then
  echo "sync OK: study3-docs/ (debug) and study3-pavlovia/ (production) updated, projectId=$PROJECT_ID"
  echo
  echo "To deploy:"
  echo "  cd study3-pavlovia"
  echo "  git init && git remote add origin $GITLAB_REMOTE   # first time only"
  echo "  git add -A && git commit -m 'Study 3 task' && git push -u origin master"
  echo
  echo "NOTE: Pavlovia pulls refs/heads/MASTER, not main."
fi
exit $((1-ok))
