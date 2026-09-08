#!/usr/bin/env bash
# Build locally with: bash sync_study6.sh --debug
# Build production once its completion URL is ready:
# STUDY6_COMPLETION_URL="https://app.prolific.com/submissions/complete?cc=..." bash sync_study6.sh
# This prepares files only. It never pushes or changes the live task.
set -euo pipefail
cd "$(dirname "$0")"
PROJECT_ID=538074
GITLAB_REMOTE="https://gitlab.pavlovia.org/omardavidperez/greyhound-cashout-v6.git"
COMPLETION_URL=${STUDY6_COMPLETION_URL:-"https://app.prolific.com/submissions/complete?cc=C1AAQL25"}
MODE=${1:-production}
if [[ "$MODE" != "--debug" && "$MODE" != "production" ]]; then
  echo "Usage: bash sync_study6.sh [--debug]" >&2
  exit 1
fi
if [[ "$MODE" == "production" && ! "$COMPLETION_URL" =~ ^https://app\.prolific\.com/submissions/complete\?cc=[A-Za-z0-9]+$ ]]; then
  echo "Set STUDY6_COMPLETION_URL to the Study 6 Prolific completion URL before building production." >&2
  exit 1
fi

mkdir -p study6-docs/assets/videos
for source in index.html styles.css app.js trial-config.js assignment.js; do
  cp "study6-task/$source" "study6-docs/$source"
done
cp -R study6-task/assets/videos/. study6-docs/assets/videos/
echo "Study 6 local preview ready in study6-docs/."
if [[ "$MODE" == "--debug" ]]; then exit 0; fi

mkdir -p study6-pavlovia/assets/videos
for source in index.html styles.css app.js trial-config.js assignment.js; do
  cp "study6-task/$source" "study6-pavlovia/$source"
done
cp -R study6-task/assets/videos/. study6-pavlovia/assets/videos/
cp study5-pavlovia/pavlovia.js study6-pavlovia/pavlovia.js
perl -0pi -e 's{<script src="\./trial-config\.js"></script>}{<script src="./pavlovia.js"></script>\n    <script src="./trial-config.js"></script>}' study6-pavlovia/index.html
perl -pi -e "s{pavlovia: \{ projectId: null, completionURL: \"\" \}}{pavlovia: { projectId: $PROJECT_ID, completionURL: \"$COMPLETION_URL\" }}" study6-pavlovia/trial-config.js
rg -q "projectId: $PROJECT_ID" study6-pavlovia/trial-config.js
rg -F -q "$COMPLETION_URL" study6-pavlovia/trial-config.js
rg -F -q 'src="./pavlovia.js"' study6-pavlovia/index.html
echo "Study 6 production build ready for project $PROJECT_ID ($GITLAB_REMOTE). Not deployed."
