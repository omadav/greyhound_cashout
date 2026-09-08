/* Study 6: one independent 50/50 draw per participant, retained on reload.
 * LocalStorage retains the assignment in this browser. Cross-browser duplicate
 * submissions must be checked by participant ID during collection/analysis.
 * Allocation does not use the race-rotation index or any participant responses.
 */
const Study6Assignment = (() => {
  const groups = ["no_betting", "betting"];
  const isLocal = () => ["localhost", "127.0.0.1", "::1", "[::1]"].includes(location.hostname);
  const isPavlovia = () => location.hostname.includes("pavlovia.org");
  function participantId() {
    const params = new URLSearchParams(location.search);
    return params.get("PROLIFIC_PID") || params.get("participant") || "";
  }
  function isTestMode() {
    const params = new URLSearchParams(location.search);
    return isLocal() || (isPavlovia() && params.get("test_mode") === "1" && !participantId());
  }
  function assign() {
    const params = new URLSearchParams(location.search);
    const override = params.get("group");
    if (isTestMode() && groups.includes(override)) {
      return { group: override, method: "local-test-override", assignedAt: new Date().toISOString() };
    }
    const pid = participantId();
    if (!pid && !isTestMode()) throw new Error("Please open the study using your Prolific link.");
    const key = `study6:assignment:v1:${pid || "local-preview"}`;
    const saved = localStorage.getItem(key);
    if (saved) {
      const assignment = JSON.parse(saved);
      if (!groups.includes(assignment.group) || assignment.method !== "crypto-random-1to1-v1") {
        throw new Error("Your saved study assignment could not be read. Please contact the researcher.");
      }
      return assignment;
    }
    const draw = new Uint32Array(1);
    crypto.getRandomValues(draw);
    const assignment = {
      group: groups[draw[0] % 2],
      method: "crypto-random-1to1-v1",
      assignedAt: new Date().toISOString()
    };
    // Fail before showing the task if the browser cannot preserve assignment.
    localStorage.setItem(key, JSON.stringify(assignment));
    return assignment;
  }
  return { assign, participantId, isLocal, isTestMode };
})();
