(function () {
  const screens = {
    intro: document.getElementById("screen-intro"),
    choice: document.getElementById("screen-choice"),
    assignment: document.getElementById("screen-assignment"),
    confidence: document.getElementById("screen-confidence"),
    attention: document.getElementById("screen-attention"),
    race: document.getElementById("screen-race"),
    outcomeCheck: document.getElementById("screen-outcome-check"),
    result: document.getElementById("screen-result"),
    postrace: document.getElementById("screen-postrace"),
    pgsi: document.getElementById("screen-pgsi"),
    finish: document.getElementById("screen-finish")
  };

  const state = {
    schedule: [],
    currentTrialIndex: -1,
    currentTrial: null,
    namePool: [],
    currentDogNames: [],
    currentDogInfo: [],
    selectedDogIndex: null,
    trapAssignments: null,
    pendingAttention: null,
    cashoutShown: false,
    cashoutChoice: "n/a",
    points: 0,
    results: [],
    startedAt: null,
    videoEndedHandler: null,
    allowVideoPause: false
  };

  const els = {
    trialStatus: document.getElementById("trial-status"),
    pointsStatus: document.getElementById("points-status"),
    startButton: document.getElementById("start-button"),
    choiceNext: document.getElementById("choice-next"),
    dogGrid: document.getElementById("dog-grid"),
    conditionChip: document.getElementById("condition-chip"),
    choiceCopy: document.getElementById("choice-copy"),
    assignmentTitle: document.getElementById("assignment-title"),
    assignmentCopy: document.getElementById("assignment-copy"),
    assignmentJacket: document.getElementById("assignment-jacket"),
    assignmentNext: document.getElementById("assignment-next"),
    confidenceSlider: document.getElementById("confidence-slider"),
    confidenceValue: document.getElementById("confidence-value"),
    confidenceNext: document.getElementById("confidence-next"),
    outcomeCheckCopy: document.getElementById("outcome-check-copy"),
    outcomeCheckOptions: document.getElementById("outcome-check-options"),
    attentionLabel: document.getElementById("attention-label"),
    attentionSlider: document.getElementById("attention-slider"),
    attentionValue: document.getElementById("attention-value"),
    attentionNext: document.getElementById("attention-next"),
    raceTitle: document.getElementById("race-title"),
    raceCopy: document.getElementById("race-copy"),
    raceVideo: document.getElementById("race-video"),
    raceIntroPanel: document.getElementById("race-intro-panel"),
    raceIntroTitle: document.getElementById("race-intro-title"),
    raceIntroCopy: document.getElementById("race-intro-copy"),
    videoFallback: document.getElementById("video-fallback"),
    cashoutPanel: document.getElementById("cashout-panel"),
    cashoutTitle: document.getElementById("cashout-title"),
    cashoutCopy: document.getElementById("cashout-copy"),
    cashoutTimer: document.getElementById("cashout-timer"),
    cashoutAccept: document.getElementById("cashout-accept"),
    cashoutReject: document.getElementById("cashout-reject"),
    raceHelper: document.getElementById("race-helper"),
    resultTitle: document.getElementById("result-title"),
    resultCopy: document.getElementById("result-copy"),
    resultDog: document.getElementById("result-dog"),
    resultTrap: document.getElementById("result-trap"),
    resultPlace: document.getElementById("result-place"),
    resultPoints: document.getElementById("result-points"),
    resultNext: document.getElementById("result-next"),
    pleasedSlider: document.getElementById("pleased-slider"),
    pleasedValue: document.getElementById("pleased-value"),
    motivationSlider: document.getElementById("motivation-slider"),
    motivationValue: document.getElementById("motivation-value"),
    luckSlider: document.getElementById("luck-slider"),
    luckValue: document.getElementById("luck-value"),
    postraceNext: document.getElementById("postrace-next"),
    pgsiForm: document.getElementById("pgsi-form"),
    pgsiNext: document.getElementById("pgsi-next"),
    finishCopy: document.getElementById("finish-copy"),
    downloadJson: document.getElementById("download-json"),
    downloadCsv: document.getElementById("download-csv"),
    restartButton: document.getElementById("restart-button"),
    returnProlific: document.getElementById("return-prolific")
  };

  const PGSI_ITEMS = [
    "Have you bet more than you could really afford to lose?",
    "Have you needed to gamble with larger amounts of money to get the same feeling of excitement?",
    "Have you gone back another day to try to win back the money you lost?",
    "Have you borrowed money or sold anything to get money to gamble?",
    "Have you felt that you might have a problem with gambling?",
    "Has gambling caused you any health problems, including stress or anxiety?",
    "Have people criticized your betting or told you that you had a gambling problem, whether or not you thought it was true?",
    "Has your gambling caused any financial problems for you or your household?",
    "Have you felt guilty about the way you gamble or what happens when you gamble?"
  ];
  const PGSI_OPTIONS = [
    { label: "Never", value: 0 },
    { label: "Sometimes", value: 1 },
    { label: "Most of the time", value: 2 },
    { label: "Almost always", value: 3 }
  ];

  const RATING_SLIDERS = [
    { slider: "confidenceSlider", value: "confidenceValue", next: "confidenceNext" },
    { slider: "pleasedSlider", value: "pleasedValue" },
    { slider: "motivationSlider", value: "motivationValue" },
    { slider: "luckSlider", value: "luckValue" }
  ];
  const ATTENTION = { slider: "attentionSlider", value: "attentionValue", next: "attentionNext" };
  const ATTENTION_TARGETS = [20, 40, 60, 80];
  const ATTENTION_TOLERANCE = 5;

  const raceIntroLights = Array.from(document.querySelectorAll(".signal-light"));
  let raceIntroTimers = [];
  let cashoutTimerInterval = null;
  let cashoutExpiryTimeout = null;
  let confShownAt = 0;
  let confidenceRT = 0;
  let postraceShownAt = 0;
  let attnShownAt = 0;
  let outcomeCheckShownAt = 0;

  // ---- helpers ----------------------------------------------------------

  function shuffle(array) {
    const a = array.slice();
    for (let i = a.length - 1; i > 0; i -= 1) {
      const j = Math.floor(Math.random() * (i + 1));
      [a[i], a[j]] = [a[j], a[i]];
    }
    return a;
  }

  function availableTraps(race) {
    const out = [];
    for (let t = 1; t <= 6; t += 1) {
      if (!race.missing.includes(t)) out.push(t);
    }
    return out;
  }

  function trapForRole(race, role) {
    if (role === "winner") return race.winner;
    if (role === "runnerUp") return race.runnerUp;
    // back: any running trap that is not in the top three
    const back = availableTraps(race).filter(
      (t) => t !== race.winner && t !== race.runnerUp && t !== race.third
    );
    return back[Math.floor(Math.random() * back.length)];
  }

  function showScreen(name) {
    Object.values(screens).forEach((screen) => screen.classList.remove("active"));
    screens[name].classList.add("active");
    // always start a screen at the top: the race video otherwise sits below the
    // fold and participants had to scroll once the race had already started.
    window.scrollTo({ top: 0, behavior: "instant" });
  }

  function updateHeader() {
    const total = state.schedule.length || STUDY.repsPerCondition * STUDY.allocation.length;
    const shownTrial = Math.max(state.currentTrialIndex + 1, 0);
    els.trialStatus.textContent = `Race ${shownTrial} / ${total}`;
    els.pointsStatus.textContent = `${state.points}`;
  }

  // ---- schedule ---------------------------------------------------------

  // Races per condition. Defaults to STUDY.repsPerCondition (5 -> 20 races), but a
  // ?reps=N url param (1-5) shortens it for testing without touching the config.
  // The real Prolific link has no param and always runs the full 5.
  function repsPerCondition() {
    const raw = new URLSearchParams(window.location.search).get("reps");
    const n = raw ? parseInt(raw, 10) : STUDY.repsPerCondition;
    return Number.isInteger(n) && n >= 1 && n <= 5 ? n : STUDY.repsPerCondition;
  }

  function buildSchedule() {
    const pools = {
      clear: shuffle(STUDY.races.filter((r) => r.kind === "clear")),
      close: shuffle(STUDY.races.filter((r) => r.kind === "close"))
    };
    const trials = [];
    const reps = repsPerCondition();

    STUDY.allocation.forEach((alloc) => {
      const cond = STUDY.conditions[alloc.condition];
      for (let i = 0; i < reps; i += 1) {
        const race = pools[alloc.pool].shift();
        if (!race) {
          throw new Error(`Not enough ${alloc.pool} races for ${alloc.condition}`);
        }
        const assignedTrap = trapForRole(race, cond.role);
        trials.push({
          condition: cond.code,
          conditionLabel: cond.label,
          role: cond.role,
          raceId: race.id,
          video: STUDY.videoDir + race.video,
          nRunners: race.nRunners,
          availableTraps: availableTraps(race),
          winnerTrap: race.winner,
          runnerUpTrap: race.runnerUp,
          thirdTrap: race.third,
          assignedTrap: assignedTrap,
          cashoutOffer: STUDY.cashoutOffers[Math.floor(Math.random() * STUDY.cashoutOffers.length)],
          cashoutPauseSec: null // set per video at run time (last third)
        });
      }
    });

    return assignAttentionChecks(orderTrials(trials));
  }

  // Two attention checks, one placed at random in races 3-10 and one in races 11-18,
  // so they are spread out, never first or last, and fall on different races per person.
  // Two further checks ask where the dog actually finished, immediately after the
  // race and BEFORE the result screen (so the answer cannot be read off it). These
  // test whether the participant watched the race, not just read the instructions.
  function assignAttentionChecks(ordered) {
    const pick = (lo, hi) => lo + Math.floor(Math.random() * (hi - lo + 1));
    [pick(2, 9), pick(10, 17)].forEach((i) => {
      if (ordered[i]) ordered[i].attention = { target: randOf(ATTENTION_TARGETS) };
    });
    // outcome checks on different races from the slider checks where possible
    [pick(1, 8), pick(9, 18)].forEach((i) => {
      if (ordered[i] && !ordered[i].attention) ordered[i].outcomeCheck = true;
      else if (ordered[i + 1] && !ordered[i + 1].attention) ordered[i + 1].outcomeCheck = true;
    });
    return ordered;
  }

  // Randomise order, but no more than two of the same condition in a row and
  // never open on a near miss or clear loss.
  function orderTrials(trials) {
    for (let attempt = 0; attempt < 500; attempt += 1) {
      const order = shuffle(trials);
      if (["NM", "CL"].includes(order[0].condition)) continue;
      let ok = true;
      for (let i = 2; i < order.length; i += 1) {
        if (
          order[i].condition === order[i - 1].condition &&
          order[i].condition === order[i - 2].condition
        ) {
          ok = false;
          break;
        }
      }
      if (ok) return order;
    }
    return shuffle(trials);
  }

  // ---- dog choice -------------------------------------------------------

  function randOf(arr) {
    return arr[Math.floor(Math.random() * arr.length)];
  }

  // One name per prefix per session: shuffle the prefixes and pair each with a
  // shuffled word. A session needs <= 120 names and there are more prefixes than
  // that, so no participant ever sees two dogs sharing a kennel prefix (which
  // reads as littermates). Words recycle, but drawDogNames keeps them distinct
  // within a race card. No full name repeats across the session.
  function buildNamePool() {
    const prefixes = shuffle(STUDY.namePrefixes);
    let words = [];
    return prefixes.map((p) => {
      if (!words.length) words = shuffle(STUDY.nameWords);
      return `${p} ${words.pop()}`;
    });
  }

  function drawDogNames(count) {
    if (state.namePool.length < count) {
      state.namePool = state.namePool.concat(buildNamePool()); // safety refill
    }
    // avoid two dogs on the same card sharing the second word
    const picked = [];
    const used = new Set();
    for (let i = 0; i < state.namePool.length && picked.length < count; i += 1) {
      const w = state.namePool[i].split(" ")[1];
      if (!used.has(w)) {
        used.add(w);
        picked.push(state.namePool.splice(i, 1)[0]);
        i -= 1;
      }
    }
    while (picked.length < count) picked.push(state.namePool.shift()); // fallback
    return picked;
  }

  // Decorative form details. Random and identically distributed across conditions,
  // so they carry no information about the (trap-determined) outcome.
  function makeDogInfo(name) {
    const form = Array.from({ length: 4 }, () => 1 + Math.floor(Math.random() * 6)).join("-");
    return {
      name: name,
      age: (1.5 + Math.random() * 2.5).toFixed(1) + "yr",
      weight: (28 + Math.random() * 7).toFixed(1) + "kg",
      form: form,
      trainer: randOf(STUDY.trainers),
      town: randOf(STUDY.towns)
    };
  }

  function buildTrapAssignments(chosenName, assignedTrap, trial) {
    const traps = {};
    traps[assignedTrap] = chosenName;
    const otherTraps = trial.availableTraps.filter((t) => t !== assignedTrap);
    const otherNames = state.currentDogNames.filter((n) => n !== chosenName);
    otherTraps.forEach((trap, i) => {
      traps[trap] = otherNames[i];
    });
    return traps;
  }

  function jacketStyle(trap) {
    const c = STUDY.trapColours[trap];
    return `background:${c.css};color:${c.text};`;
  }

  function renderDogChoices() {
    els.dogGrid.innerHTML = "";
    const names = drawDogNames(state.currentTrial.nRunners);
    state.currentDogInfo = names.map(makeDogInfo);
    state.currentDogNames = names;
    state.selectedDogIndex = null;
    els.choiceNext.disabled = true;

    // Trap numbers are deliberately NOT shown here — the trap is revealed after the
    // choice, which is where the chosen dog is mapped onto its condition trap.
    state.currentDogInfo.forEach((dog, index) => {
      const button = document.createElement("button");
      button.type = "button";
      button.className = "dog-card";
      button.innerHTML = `
        <h3>${dog.name}</h3>
        <div class="dog-stats">
          <span><em>Form</em>${dog.form}</span>
          <span><em>Trainer</em>${dog.trainer}</span>
          <span><em>Age</em>${dog.age}</span>
          <span><em>Weight</em>${dog.weight}</span>
          <span><em>Track</em>${dog.town}</span>
        </div>
        <span class="pick-tag">Back this dog</span>
      `;
      button.addEventListener("click", () => {
        state.selectedDogIndex = index;
        Array.from(els.dogGrid.children).forEach((card) => card.classList.remove("selected"));
        button.classList.add("selected");
        els.choiceNext.disabled = false;
      });
      els.dogGrid.appendChild(button);
    });
  }

  function encodeVideoPath(path) {
    return encodeURI(path);
  }

  // ---- PGSI -------------------------------------------------------------

  function renderPgsiForm() {
    els.pgsiForm.innerHTML = "";
    PGSI_ITEMS.forEach((item, index) => {
      const fieldset = document.createElement("fieldset");
      fieldset.className = "pgsi-item";
      fieldset.innerHTML = `<legend>${index + 1}. ${item}</legend>`;
      const optionsWrap = document.createElement("div");
      optionsWrap.className = "pgsi-options";
      PGSI_OPTIONS.forEach((option) => {
        const id = `pgsi-${index + 1}-${option.value}`;
        const label = document.createElement("label");
        label.className = "pgsi-option";
        label.setAttribute("for", id);
        label.innerHTML = `
          <input type="radio" id="${id}" name="pgsi-${index + 1}" value="${option.value}">
          <span>${option.label}</span>
        `;
        optionsWrap.appendChild(label);
      });
      fieldset.appendChild(optionsWrap);
      els.pgsiForm.appendChild(fieldset);
    });
  }

  function getPgsiResponses() {
    return PGSI_ITEMS.map((_, index) => {
      const checked = document.querySelector(`input[name="pgsi-${index + 1}"]:checked`);
      return checked ? Number(checked.value) : null;
    });
  }

  function getPgsiCategory(total) {
    if (total === 0) return "non-problem";
    if (total <= 2) return "low-risk";
    if (total <= 7) return "moderate-risk";
    return "problem gambling";
  }

  function resetPgsiForm() {
    document.querySelectorAll('#pgsi-form input[type="radio"]').forEach((input) => {
      input.checked = false;
    });
    els.pgsiNext.disabled = true;
  }

  function updatePgsiButtonState() {
    els.pgsiNext.disabled = getPgsiResponses().some((value) => value === null);
  }

  // ---- rating sliders (no central default) ------------------------------

  function resetRatingSlider(cfg) {
    const slider = els[cfg.slider];
    const valueNode = els[cfg.value];
    // Random start position each time, so the thumb never sits at a fixed centre
    // that would anchor responses. The participant must move it to continue.
    const start = Math.floor(Math.random() * 101);
    slider.value = String(start);
    slider.dataset.touched = "false";
    slider.dataset.start = String(start);
    slider.classList.add("untouched");
    valueNode.textContent = "–";
    if (cfg.next) els[cfg.next].disabled = true;
  }

  function wireRatingSlider(cfg) {
    const slider = els[cfg.slider];
    const valueNode = els[cfg.value];
    const mark = () => {
      slider.dataset.touched = "true";
      slider.classList.remove("untouched");
      valueNode.textContent = slider.value;
      if (cfg.next) els[cfg.next].disabled = false;
    };
    slider.addEventListener("input", mark);
    slider.addEventListener("change", mark);
  }

  function ratingValue(cfg) {
    const slider = els[cfg.slider];
    return slider.dataset.touched === "true" ? Number(slider.value) : null;
  }

  function postraceComplete() {
    return [RATING_SLIDERS[1], RATING_SLIDERS[2], RATING_SLIDERS[3]].every(
      (cfg) => els[cfg.slider].dataset.touched === "true"
    );
  }

  // ---- video chrome -----------------------------------------------------

  function lockVideoChrome() {
    els.raceVideo.controls = false;
    els.raceVideo.removeAttribute("controls");
    els.raceVideo.setAttribute(
      "controlslist",
      "nodownload nofullscreen noplaybackrate noremoteplayback"
    );
    els.raceVideo.disablePictureInPicture = true;
  }

  function clearRaceIntroTimers() {
    raceIntroTimers.forEach((timerId) => window.clearTimeout(timerId));
    raceIntroTimers = [];
  }

  function resetSignalLights() {
    raceIntroLights.forEach((light) => light.classList.remove("active", "go"));
  }

  function clearCashoutTimers() {
    if (cashoutTimerInterval) {
      window.clearInterval(cashoutTimerInterval);
      cashoutTimerInterval = null;
    }
    if (cashoutExpiryTimeout) {
      window.clearTimeout(cashoutExpiryTimeout);
      cashoutExpiryTimeout = null;
    }
  }

  // ---- trial flow -------------------------------------------------------

  function prepareTrial() {
    state.currentTrialIndex += 1;
    state.currentTrial = state.schedule[state.currentTrialIndex];
    state.cashoutShown = false;
    state.cashoutChoice = STUDY.cashout ? "pending" : "n/a";
    state.trapAssignments = null;
    state.pendingAttention = null;
    updateHeader();

    els.conditionChip.textContent =
      `Race ${state.currentTrialIndex + 1} · ${state.currentTrial.nRunners} runners`;
    els.choiceCopy.textContent = "Study the card and back a dog to win.";
    renderDogChoices();
    showScreen("choice");
  }

  function handleChoiceContinue() {
    const trial = state.currentTrial;
    const chosenName = state.currentDogNames[state.selectedDogIndex];
    state.trapAssignments = buildTrapAssignments(chosenName, trial.assignedTrap, trial);

    const colour = STUDY.trapColours[trial.assignedTrap];
    els.assignmentTitle.textContent = `${chosenName} is ready to race`;
    els.assignmentCopy.textContent =
      `${chosenName} will run from Trap ${trial.assignedTrap}, wearing the ${colour.name} jacket. ` +
      `Follow the ${colour.name} jacket during the race.`;
    if (els.assignmentJacket) {
      els.assignmentJacket.setAttribute("style", jacketStyle(trial.assignedTrap));
      els.assignmentJacket.textContent = String(trial.assignedTrap);
    }
    showScreen("assignment");
  }

  function handleAssignmentContinue() {
    resetRatingSlider(RATING_SLIDERS[0]);
    confShownAt = Date.now();
    showScreen("confidence");
  }

  function handleConfidenceContinue() {
    confidenceRT = Date.now() - confShownAt;
    if (state.currentTrial.attention) {
      showAttentionScreen();
    } else {
      startRace();
    }
  }

  function showAttentionScreen() {
    resetRatingSlider(ATTENTION);
    els.attentionLabel.textContent =
      `To show you are paying attention, please move the slider to ${state.currentTrial.attention.target}.`;
    attnShownAt = Date.now();
    showScreen("attention");
  }

  function handleAttentionContinue() {
    const t = state.currentTrial.attention;
    const resp = ratingValue(ATTENTION);
    state.pendingAttention = {
      target: t.target,
      response: resp,
      pass: resp !== null && Math.abs(resp - t.target) <= ATTENTION_TOLERANCE,
      rt: Date.now() - attnShownAt
    };
    startRace();
  }

  function startRace() {
    const trial = state.currentTrial;
    const chosenName = state.trapAssignments[trial.assignedTrap];
    const colour = STUDY.trapColours[trial.assignedTrap];

    els.raceTitle.textContent = `Follow the ${colour.name} jacket (Trap ${trial.assignedTrap})`;
    els.raceCopy.textContent = STUDY.cashout
      ? `If an offer appears, decide whether to cash out or let the full race play out.`
      : `Watch the race to the finish.`;
    state.allowVideoPause = true;
    els.cashoutPanel.classList.add("hidden");
    els.raceIntroPanel.classList.remove("hidden");
    els.videoFallback.classList.add("hidden");
    els.raceHelper.textContent = STUDY.cashout
      ? "The race begins automatically and will pause only for the cash-out offer."
      : "The race begins automatically.";
    els.raceIntroTitle.textContent = "Race starts in 3";
    els.raceIntroCopy.textContent = "Keep your eyes on your jacket. The race will begin automatically.";
    resetSignalLights();
    clearRaceIntroTimers();
    clearCashoutTimers();
    lockVideoChrome();

    if (state.videoEndedHandler) {
      els.raceVideo.removeEventListener("ended", state.videoEndedHandler);
    }

    els.raceVideo.pause();
    els.raceVideo.currentTime = 0;
    els.raceVideo.src = encodeVideoPath(trial.video);
    els.raceVideo.load();

    // Cash-out pause at ~75% of the clip once we know its duration.
    els.raceVideo.addEventListener(
      "loadedmetadata",
      () => {
        if (Number.isFinite(els.raceVideo.duration)) {
          trial.cashoutPauseSec = els.raceVideo.duration * 0.75;
        }
      },
      { once: true }
    );

    state.videoEndedHandler = () => handleRaceEnded();
    els.raceVideo.addEventListener("ended", state.videoEndedHandler, { once: true });
    els.raceVideo.controls = false;

    showScreen("race");

    raceIntroTimers.push(window.setTimeout(() => { els.raceIntroTitle.textContent = "Race starts in 3"; raceIntroLights[0].classList.add("active"); }, 0));
    raceIntroTimers.push(window.setTimeout(() => { els.raceIntroTitle.textContent = "Race starts in 2"; raceIntroLights[1].classList.add("active"); }, 700));
    raceIntroTimers.push(window.setTimeout(() => { els.raceIntroTitle.textContent = "Race starts in 1"; raceIntroLights[2].classList.add("active"); }, 1400));
    raceIntroTimers.push(
      window.setTimeout(() => {
        els.raceIntroTitle.textContent = "They're off";
        els.raceIntroCopy.textContent = `Track the ${colour.name} jacket through the run-in.`;
        raceIntroLights.forEach((light) => {
          light.classList.remove("active");
          light.classList.add("go");
        });
      }, 2100)
    );
    raceIntroTimers.push(
      window.setTimeout(() => {
        els.raceIntroPanel.classList.add("hidden");
        state.allowVideoPause = false;
        lockVideoChrome();
        const playPromise = els.raceVideo.play();
        if (playPromise && typeof playPromise.catch === "function") {
          playPromise.catch(() => {
            els.videoFallback.classList.remove("hidden");
            els.raceHelper.textContent =
              "Playback was blocked or unsupported. You can still use this build to test the flow.";
          });
        }
      }, 2500)
    );
  }

  function showCashoutPanel() {
    const trial = state.currentTrial;
    state.cashoutShown = true;
    state.allowVideoPause = true;
    els.raceVideo.pause();
    els.cashoutTitle.textContent = `Cash out now for ${trial.cashoutOffer} points?`;
    els.cashoutCopy.textContent =
      `Take a guaranteed ${trial.cashoutOffer} points now, or keep betting for the full ` +
      `${STUDY.baseWinPoints}-point outcome if your dog wins.`;
    els.cashoutTimer.textContent = "";
    els.cashoutPanel.classList.remove("hidden");
  }

  function handleRaceTimeUpdate() {
    const trial = state.currentTrial;
    if (!STUDY.cashout || !trial || state.cashoutShown || !trial.cashoutPauseSec) {
      return;
    }
    if (els.raceVideo.currentTime >= trial.cashoutPauseSec) {
      showCashoutPanel();
    }
  }

  function handleCashout(choice) {
    clearCashoutTimers();
    state.cashoutChoice = choice;
    state.allowVideoPause = false;
    els.cashoutPanel.classList.add("hidden");
    lockVideoChrome();
    els.raceVideo.play().catch(() => els.videoFallback.classList.remove("hidden"));
  }

  function handleRacePause() {
    if (state.allowVideoPause || els.raceVideo.ended || !state.currentTrial) {
      return;
    }
    els.raceVideo.play().catch(() => els.videoFallback.classList.remove("hidden"));
  }

  // finishing position of the chosen dog, from its trap
  function chosenFinishPosition(trial) {
    if (trial.assignedTrap === trial.winnerTrap) return 1;
    if (trial.assignedTrap === trial.runnerUpTrap) return 2;
    if (trial.assignedTrap === trial.thirdTrap) return 3;
    return 99; // unplaced
  }

  function placeLabel(pos) {
    if (pos === 1) return "1st";
    if (pos === 2) return "2nd";
    if (pos === 3) return "3rd";
    // Only first place pays here. Real racing has place bets on 2nd/3rd, so
    // "unplaced" reads as a betting term and confuses the outcome (Luke, 2026-07).
    return "Did not win";
  }

  function pointsForTrial(trial, pos) {
    if (STUDY.cashout && state.cashoutChoice === "accept") {
      return trial.cashoutOffer;
    }
    return pos === 1 ? STUDY.baseWinPoints : 0;
  }

  function currentTrialRecord() {
    return state.results[state.results.length - 1];
  }

  function handleRaceEnded() {
    clearRaceIntroTimers();
    clearCashoutTimers();
    state.allowVideoPause = true;
    const trial = state.currentTrial;
    const chosenName = state.trapAssignments[trial.assignedTrap];
    const pos = chosenFinishPosition(trial);
    const finishLabel = placeLabel(pos);
    const pointsWon = pointsForTrial(trial, pos);
    state.points += pointsWon;
    updateHeader();

    const topThree = [trial.winnerTrap, trial.runnerUpTrap, trial.thirdTrap].map((trap, i) => {
      return `${i + 1}. ${state.trapAssignments[trap]} (Trap ${trap})`;
    });

    state.results.push({
      studyId: STUDY.id,
      prolificPID: (typeof Pavlovia !== "undefined" && Pavlovia.prolificPID) || "",
      prolificStudyID: (typeof Pavlovia !== "undefined" && Pavlovia.prolificStudyID) || "",
      prolificSessionID: (typeof Pavlovia !== "undefined" && Pavlovia.prolificSessionID) || "",
      sessionStartedAt: state.startedAt,
      submittedAt: new Date().toISOString(),
      trialNumber: state.currentTrialIndex + 1,
      condition: trial.condition,
      raceId: trial.raceId,
      videoFile: trial.video.split("/").pop(),
      nRunners: trial.nRunners,
      chosenDog: chosenName,
      assignedTrap: trial.assignedTrap,
      trapRole: trial.role,
      winnerTrap: trial.winnerTrap,
      runnerUpTrap: trial.runnerUpTrap,
      finishPosition: pos === 99 ? "unplaced" : pos,
      finishLabel: finishLabel,
      topThree: topThree.join(" | "),
      confidence: ratingValue(RATING_SLIDERS[0]),
      confidenceStart: Number(els.confidenceSlider.dataset.start),
      confidenceRT_ms: confidenceRT,
      attentionCheck: !!trial.attention,
      attentionTarget: trial.attention ? state.pendingAttention.target : "",
      attentionResponse: trial.attention ? state.pendingAttention.response : "",
      attentionPass: trial.attention ? state.pendingAttention.pass : "",
      attentionRT_ms: trial.attention ? state.pendingAttention.rt : "",
      outcomeCheck: false,
      outcomeCheckResponse: "",
      outcomeCheckPass: "",
      outcomeCheckRT_ms: "",
      cashoutEnabled: STUDY.cashout,
      cashoutOffer: STUDY.cashout ? trial.cashoutOffer : "",
      cashoutChoice: STUDY.cashout ? (state.cashoutChoice === "pending" ? "reject" : state.cashoutChoice) : "n/a",
      pointsWon: pointsWon
    });

    const won = pos === 1;
    els.resultTitle.textContent = won ? "Your dog won the race" : "Your dog did not win";
    els.resultCopy.textContent =
      `${chosenName} finished ${finishLabel}. Top 3: ${topThree.join(" | ")}.`;
    els.resultDog.textContent = chosenName;
    els.resultTrap.textContent = `Trap ${trial.assignedTrap}`;
    els.resultPlace.textContent = finishLabel;
    els.resultPoints.textContent = pointsWon > 0 ? `+${pointsWon} ${STUDY.creditLabel}` : `0 ${STUDY.creditLabel}`;

    // On outcome-check races, ask where the dog finished BEFORE revealing the result.
    if (trial.outcomeCheck) {
      els.outcomeCheckCopy.textContent = `You were following ${chosenName} in Trap ${trial.assignedTrap}.`;
      outcomeCheckShownAt = Date.now();
      showScreen("outcomeCheck");
      return;
    }
    showScreen("result");
  }

  function handleOutcomeCheck(answer) {
    const record = currentTrialRecord();
    const actual = chosenFinishPosition(state.currentTrial);
    record.outcomeCheck = true;
    record.outcomeCheckResponse = answer === 99 ? "further back" : answer;
    record.outcomeCheckPass = answer === actual;
    record.outcomeCheckRT_ms = Date.now() - outcomeCheckShownAt;
    showScreen("result");
  }

  function handlePostraceContinue() {
    const record = currentTrialRecord();
    record.pleased = ratingValue(RATING_SLIDERS[1]);
    record.pleasedStart = Number(els.pleasedSlider.dataset.start);
    record.motivation = ratingValue(RATING_SLIDERS[2]);
    record.motivationStart = Number(els.motivationSlider.dataset.start);
    record.luck = ratingValue(RATING_SLIDERS[3]);
    record.luckStart = Number(els.luckSlider.dataset.start);
    record.postraceRT_ms = Date.now() - postraceShownAt;

    if (state.currentTrialIndex === state.schedule.length - 1) {
      showScreen("pgsi");
      return;
    }
    prepareTrial();
  }

  function showFinish() {
    updateHeader();
    const totalTrials = state.results.length;
    const pgsiResponses = getPgsiResponses();
    const pgsiTotal = pgsiResponses.reduce((sum, value) => sum + value, 0);
    const pgsiCategory = getPgsiCategory(pgsiTotal);
    els.finishCopy.textContent =
      `You completed ${totalTrials} races and won ${state.points} ${STUDY.creditLabel}, ` +
      `which convert to your cash bonus. PGSI total: ${pgsiTotal} (${pgsiCategory}). ` +
      `Download the session data below for inspection.`;
    showScreen("finish");
    saveResults();
  }

  function handlePgsiContinue() {
    const pgsiResponses = getPgsiResponses();
    const pgsiTotal = pgsiResponses.reduce((sum, value) => sum + value, 0);
    const pgsiCategory = getPgsiCategory(pgsiTotal);
    state.results.forEach((row) => {
      pgsiResponses.forEach((value, index) => {
        row[`pgsi_${index + 1}`] = value;
      });
      row.pgsi_total = pgsiTotal;
      row.pgsi_category = pgsiCategory;
    });
    showFinish();
  }

  // ---- export -----------------------------------------------------------

  function csvEscape(value) {
    const text = String(value ?? "");
    if (text.includes(",") || text.includes('"') || text.includes("\n")) {
      return `"${text.replace(/"/g, '""')}"`;
    }
    return text;
  }

  function downloadFile(name, content, type) {
    const blob = new Blob([content], { type });
    const url = URL.createObjectURL(blob);
    const link = document.createElement("a");
    link.href = url;
    link.download = name;
    document.body.appendChild(link);
    link.click();
    link.remove();
    URL.revokeObjectURL(url);
  }

  function downloadJson() {
    downloadFile(
      "greyhound-study1-session.json",
      JSON.stringify(
        { studyTitle: STUDY.title, studyId: STUDY.id, exportedAt: new Date().toISOString(), totalPoints: state.points, trials: state.results },
        null,
        2
      ),
      "application/json"
    );
  }

  function buildCsvString() {
    if (!state.results.length) return null;
    const keys = Object.keys(state.results[0]);
    return [
      keys.join(","),
      ...state.results.map((row) => keys.map((key) => csvEscape(row[key])).join(","))
    ].join("\n");
  }

  function downloadCsv() {
    const csv = buildCsvString();
    if (csv) downloadFile("greyhound-study1-session.csv", csv, "text/csv;charset=utf-8");
  }

  // When running on Pavlovia, upload the CSV to the server, close the session, and
  // offer the Prolific completion redirect. Off Pavlovia (GitHub Pages debug), this
  // is a no-op and the manual download buttons remain.
  async function saveResults() {
    if (typeof Pavlovia === "undefined" || !Pavlovia.isActive) return;
    const csv = buildCsvString();
    if (!csv) return;
    const pid = Pavlovia.prolificPID || "anon";
    const ok = await Pavlovia.saveData(`greyhound_${pid}_${Date.now()}.csv`, csv);
    if (ok) {
      await Pavlovia.finish();
      els.finishCopy.textContent += " Your data has been saved.";
      if (els.returnProlific && Pavlovia.completionURL) {
        els.returnProlific.classList.remove("hidden");
      }
    }
  }

  function startSession() {
    clearRaceIntroTimers();
    clearCashoutTimers();
    resetSignalLights();
    state.schedule = buildSchedule();
    state.namePool = buildNamePool();
    state.currentTrialIndex = -1;
    state.currentTrial = null;
    state.currentDogInfo = [];
    state.selectedDogIndex = null;
    state.trapAssignments = null;
    state.cashoutShown = false;
    state.cashoutChoice = STUDY.cashout ? "pending" : "n/a";
    state.points = STUDY.startingBalance;
    state.results = [];
    state.startedAt = new Date().toISOString();
    resetPgsiForm();
    updateHeader();
  }

  function restartTask() {
    startSession();
    showScreen("intro");
  }

  // ---- wiring -----------------------------------------------------------

  els.startButton.addEventListener("click", () => {
    startSession();
    prepareTrial();
  });
  els.choiceNext.addEventListener("click", handleChoiceContinue);
  els.assignmentNext.addEventListener("click", handleAssignmentContinue);
  els.confidenceNext.addEventListener("click", handleConfidenceContinue);
  els.attentionNext.addEventListener("click", handleAttentionContinue);
  Array.from(els.outcomeCheckOptions.querySelectorAll("button")).forEach((b) => {
    b.addEventListener("click", () => handleOutcomeCheck(Number(b.dataset.answer)));
  });
  els.cashoutAccept.addEventListener("click", () => handleCashout("accept"));
  els.cashoutReject.addEventListener("click", () => handleCashout("reject"));
  els.resultNext.addEventListener("click", () => {
    RATING_SLIDERS.slice(1).forEach(resetRatingSlider);
    els.postraceNext.disabled = true;
    postraceShownAt = Date.now();
    showScreen("postrace");
  });
  els.postraceNext.addEventListener("click", handlePostraceContinue);
  els.pgsiNext.addEventListener("click", handlePgsiContinue);
  els.downloadJson.addEventListener("click", downloadJson);
  els.downloadCsv.addEventListener("click", downloadCsv);
  els.restartButton.addEventListener("click", restartTask);
  els.raceVideo.addEventListener("pause", handleRacePause);
  els.raceVideo.addEventListener("play", lockVideoChrome);
  els.raceVideo.addEventListener("timeupdate", handleRaceTimeUpdate);
  els.raceVideo.addEventListener("contextmenu", (event) => event.preventDefault());
  els.raceVideo.addEventListener("error", () => els.videoFallback.classList.remove("hidden"));

  RATING_SLIDERS.forEach(wireRatingSlider);
  wireRatingSlider(ATTENTION);
  // Post-race Next stays disabled until all three post-race sliders are touched.
  [RATING_SLIDERS[1], RATING_SLIDERS[2], RATING_SLIDERS[3]].forEach((cfg) => {
    els[cfg.slider].addEventListener("input", () => {
      els.postraceNext.disabled = !postraceComplete();
    });
  });

  renderPgsiForm();
  els.pgsiForm.addEventListener("change", updatePgsiButtonState);

  if (els.returnProlific) {
    els.returnProlific.addEventListener("click", () => {
      if (typeof Pavlovia !== "undefined") Pavlovia.redirectToProlific();
    });
  }

  // Open the Pavlovia session on load. init() reads the Prolific URL params first,
  // then only opens a server session if a projectId is set and we are on Pavlovia
  // (no-op otherwise). Fire-and-forget: the session is ready long before finishing.
  if (typeof Pavlovia !== "undefined" && STUDY.pavlovia) {
    Pavlovia.init(STUDY.pavlovia);
  }

  updateHeader();
  lockVideoChrome();
})();
