#!/usr/bin/env bash
# Sync the shared task source (pilot-task/) into the two deployment copies.
#
#   docs/      GitHub Pages debug build  — no server save, local download only
#   pavlovia/  Pavlovia production build — loads pavlovia.js, has projectId +
#              Prolific completionURL
#
# The Pavlovia copy differs from the shared source in exactly two places, and a
# plain `cp` silently wipes both. This script re-applies them every time.
set -euo pipefail
cd "$(dirname "$0")"

PROJECT_ID=533864
COMPLETION_URL="https://app.prolific.com/submissions/complete?cc=CKEB0540"

for f in index.html styles.css app.js trial-config.js; do
  cp "pilot-task/$f" "docs/$f"
  cp "pilot-task/$f" "pavlovia/$f"
done

# 1. pavlovia/index.html must load the wrapper before the config
perl -0pi -e 's{(\s*)<script src="\./trial-config\.js"></script>}{$1<script src="./pavlovia.js"></script>$1<script src="./trial-config.js"></script>}' pavlovia/index.html

# 2. pavlovia/trial-config.js needs the live project id and completion URL
perl -pi -e "s{pavlovia: \{ projectId: null, completionURL: \"\" \}}{pavlovia: { projectId: $PROJECT_ID, completionURL: \"$COMPLETION_URL\" }}" pavlovia/trial-config.js

# verify
ok=1
grep -q 'src="./pavlovia.js"' pavlovia/index.html || { echo "FAIL: pavlovia.js script tag missing"; ok=0; }
grep -q "projectId: $PROJECT_ID" pavlovia/trial-config.js || { echo "FAIL: projectId not set"; ok=0; }
grep -q "cc=CKEB0540" pavlovia/trial-config.js || { echo "FAIL: completionURL not set"; ok=0; }
grep -q 'pavlovia.js' docs/index.html && { echo "FAIL: docs must NOT load pavlovia.js"; ok=0; }
[ $ok -eq 1 ] && echo "sync OK: docs/ (debug) and pavlovia/ (production) updated"
exit $((1-ok))
