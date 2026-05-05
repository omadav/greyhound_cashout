(function () {
  const screens = {
    intro: document.getElementById("screen-intro"),
    choice: document.getElementById("screen-choice"),
    assignment: document.getElementById("screen-assignment"),
    confidence: document.getElementById("screen-confidence"),
    race: document.getElementById("screen-race"),
    result: document.getElementById("screen-result"),
    postrace: document.getElementById("screen-postrace"),
    finish: document.getElementById("screen-finish")
  };

  const state = {
    currentTrialIndex: -1,
    currentTrial: null,
    currentDogCards: [],
    selectedDogIndex: null,
    trapAssignments: null,
    cashoutShown: false,
    cashoutChoice: "pending",
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
    assignmentNext: document.getElementById("assignment-next"),
    confidenceSlider: document.getElementById("confidence-slider"),
    confidenceValue: document.getElementById("confidence-value"),
    confidenceNext: document.getElementById("confidence-next"),
    raceTitle: document.getElementById("race-title"),
    raceCopy: document.getElementById("race-copy"),
    raceVideo: document.getElementById("race-video"),
    videoFallback: document.getElementById("video-fallback"),
    cashoutPanel: document.getElementById("cashout-panel"),
    cashoutTitle: document.getElementById("cashout-title"),
    cashoutCopy: document.getElementById("cashout-copy"),
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
    finishCopy: document.getElementById("finish-copy"),
    downloadJson: document.getElementById("download-json"),
    downloadCsv: document.getElementById("download-csv"),
    restartButton: document.getElementById("restart-button")
  };

  function showScreen(name) {
    Object.values(screens).forEach((screen) => screen.classList.remove("active"));
    screens[name].classList.add("active");
  }

  function updateHeader() {
    const total = PILOT_CONFIG.trials.length;
    const shownTrial = Math.max(state.currentTrialIndex + 1, 0);
    els.trialStatus.textContent = `Trial ${shownTrial} / ${total}`;
    els.pointsStatus.textContent = `Points: ${state.points}`;
  }

  function resetSlider(slider, valueNode, defaultValue) {
    slider.value = String(defaultValue);
    valueNode.textContent = String(defaultValue);
  }

  function wireSlider(slider, valueNode) {
    slider.addEventListener("input", () => {
      valueNode.textContent = slider.value;
    });
  }

  function cloneDogPool() {
    return PILOT_CONFIG.dogPool.map((dog) => ({ ...dog }));
  }

  function buildTrapAssignments(selectedDogIndex, assignedTrap) {
    const traps = {};
    const remainingTraps = [1, 2, 3, 4, 5, 6].filter((trap) => trap !== assignedTrap);
    const dogs = cloneDogPool();
    const selectedDog = dogs[selectedDogIndex];

    traps[assignedTrap] = selectedDog;

    let remainingDogIndex = 0;
    dogs.forEach((dog, index) => {
      if (index === selectedDogIndex) {
        return;
      }
      traps[remainingTraps[remainingDogIndex]] = dog;
      remainingDogIndex += 1;
    });

    return traps;
  }

  function renderDogChoices() {
    els.dogGrid.innerHTML = "";
    const dogs = cloneDogPool();
    state.currentDogCards = dogs;
    state.selectedDogIndex = null;
    els.choiceNext.disabled = true;

    dogs.forEach((dog, index) => {
      const button = document.createElement("button");
      button.type = "button";
      button.className = "dog-card";
      button.innerHTML = `
        <h3>${dog.name}</h3>
        <div class="dog-stats">
          <span>County: ${dog.county}</span>
          <span>Age: ${dog.age}</span>
          <span>Recent form: ${dog.recentForm}</span>
          <span>Season win %: ${dog.seasonWinPct}</span>
          <span>Avg. finish: ${dog.avgPos}</span>
        </div>
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

  function prepareTrial() {
    state.currentTrialIndex += 1;
    state.currentTrial = PILOT_CONFIG.trials[state.currentTrialIndex];
    state.cashoutShown = false;
    state.cashoutChoice = "pending";
    state.trapAssignments = null;
    updateHeader();

    els.conditionChip.textContent = `${state.currentTrial.label} - ${state.currentTrial.condition}`;
    els.choiceCopy.textContent = state.currentTrial.conditionCopy;
    renderDogChoices();
    showScreen("choice");
  }

  function handleChoiceContinue() {
    const chosenDog = state.currentDogCards[state.selectedDogIndex];
    state.trapAssignments = buildTrapAssignments(
      state.selectedDogIndex,
      state.currentTrial.assignedTrap
    );

    els.assignmentTitle.textContent = `${chosenDog.name} is ready to race`;
    els.assignmentCopy.textContent =
      `${chosenDog.name} will run from Trap ${state.currentTrial.assignedTrap}. ` +
      `Keep an eye on Trap ${state.currentTrial.assignedTrap} during the race.`;
    showScreen("assignment");
  }

  function handleAssignmentContinue() {
    resetSlider(els.confidenceSlider, els.confidenceValue, 50);
    showScreen("confidence");
  }

  function startRace() {
    const chosenDog = state.currentDogCards[state.selectedDogIndex];
    const trial = state.currentTrial;

    els.raceTitle.textContent = `Follow ${chosenDog.name} in Trap ${trial.assignedTrap}`;
    els.raceCopy.textContent =
      `If an offer appears, decide whether to cash out for ${trial.cashoutOffer} points ` +
      `or let the full race play out.`;
    state.allowVideoPause = true;
    els.cashoutPanel.classList.add("hidden");
    els.videoFallback.classList.add("hidden");
    els.raceHelper.textContent = "The race will pause automatically if a cash-out offer appears.";

    if (state.videoEndedHandler) {
      els.raceVideo.removeEventListener("ended", state.videoEndedHandler);
    }

    els.raceVideo.pause();
    els.raceVideo.currentTime = 0;
    els.raceVideo.src = encodeVideoPath(trial.videoSrc || PILOT_CONFIG.demoVideoSrc);
    els.raceVideo.load();

    state.videoEndedHandler = () => {
      handleRaceEnded();
    };

    els.raceVideo.addEventListener("ended", state.videoEndedHandler, { once: true });

    showScreen("race");
    state.allowVideoPause = false;

    const playPromise = els.raceVideo.play();
    if (playPromise && typeof playPromise.catch === "function") {
      playPromise.catch(() => {
        els.videoFallback.classList.remove("hidden");
        els.raceHelper.textContent =
          "Playback was blocked or unsupported. You can still use this pilot to test the flow.";
      });
    }
  }

  function showCashoutPanel() {
    const trial = state.currentTrial;
    state.cashoutShown = true;
    state.allowVideoPause = true;
    els.raceVideo.pause();
    els.cashoutTitle.textContent = `Cash out now for ${trial.cashoutOffer} points?`;
    els.cashoutCopy.textContent =
      `Choose a guaranteed ${trial.cashoutOffer} points now, or keep betting for the full ` +
      `${PILOT_CONFIG.baseWinPoints}-point outcome if your dog wins.`;
    els.cashoutPanel.classList.remove("hidden");
  }

  function handleRaceTimeUpdate() {
    const trial = state.currentTrial;
    if (!trial || state.cashoutShown) {
      return;
    }
    if (els.raceVideo.currentTime >= trial.cashoutPauseSec) {
      showCashoutPanel();
    }
  }

  function handleCashout(choice) {
    state.cashoutChoice = choice;
    state.allowVideoPause = false;
    els.cashoutPanel.classList.add("hidden");
    els.raceVideo.play().catch(() => {
      els.videoFallback.classList.remove("hidden");
    });
  }

  function handleRacePause() {
    if (state.allowVideoPause || els.raceVideo.ended || !state.currentTrial) {
      return;
    }
    els.raceVideo.play().catch(() => {
      els.videoFallback.classList.remove("hidden");
    });
  }

  function pointsForTrial(trial, cashoutChoice) {
    if (cashoutChoice === "accept") {
      return trial.cashoutOffer;
    }
    return trial.finishPosition === 1 ? PILOT_CONFIG.baseWinPoints : 0;
  }

  function currentTrialRecord() {
    return state.results[state.results.length - 1];
  }

  function handleRaceEnded() {
    state.allowVideoPause = true;
    const trial = state.currentTrial;
    const chosenDog = state.currentDogCards[state.selectedDogIndex];
    const pointsWon = pointsForTrial(trial, state.cashoutChoice);
    state.points += pointsWon;
    updateHeader();

    const topThree = trial.finishOrder.slice(0, 3).map((trap, index) => {
      const dog = state.trapAssignments[trap];
      return `${index + 1}. ${dog.name} (Trap ${trap})`;
    });

    state.results.push({
      participantSessionStartedAt: state.startedAt,
      submittedAt: new Date().toISOString(),
      trialNumber: state.currentTrialIndex + 1,
      trialId: trial.trialId,
      raceId: trial.raceId,
      condition: trial.condition,
      chosenDog: chosenDog.name,
      assignedTrap: trial.assignedTrap,
      finishPosition: trial.finishPosition,
      finishLabel: trial.finishLabel,
      finishOrder: trial.finishOrder.join(">"),
      topThree: topThree.join(" | "),
      confidence: Number(els.confidenceSlider.value),
      cashoutOffer: trial.cashoutOffer,
      cashoutChoice: state.cashoutChoice === "pending" ? "reject" : state.cashoutChoice,
      pointsWon
    });

    els.resultTitle.textContent =
      trial.finishPosition === 1 ? "Your dog won the race" : "Race complete";
    els.resultCopy.textContent =
      `${chosenDog.name} finished ${trial.finishLabel}. Top 3: ${topThree.join(" | ")}.`;
    els.resultDog.textContent = chosenDog.name;
    els.resultTrap.textContent = `Trap ${trial.assignedTrap}`;
    els.resultPlace.textContent = trial.finishLabel;
    els.resultPoints.textContent = String(pointsWon);

    showScreen("result");
  }

  function handlePostraceContinue() {
    const record = currentTrialRecord();
    record.pleased = Number(els.pleasedSlider.value);
    record.motivation = Number(els.motivationSlider.value);
    record.luck = Number(els.luckSlider.value);

    if (state.currentTrialIndex === PILOT_CONFIG.trials.length - 1) {
      showFinish();
      return;
    }

    prepareTrial();
  }

  function showFinish() {
    updateHeader();
    const totalTrials = state.results.length;
    const acceptedCashouts = state.results.filter((row) => row.cashoutChoice === "accept").length;
    els.finishCopy.textContent =
      `You completed ${totalTrials} demo trials and earned ${state.points} points. ` +
      `Cash-out was accepted on ${acceptedCashouts} trial(s). Download the session data ` +
      `below for inspection or upload to a shared analysis folder.`;
    showScreen("finish");
  }

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
      "greyhound-pilot-session.json",
      JSON.stringify(
        {
          studyTitle: PILOT_CONFIG.studyTitle,
          exportedAt: new Date().toISOString(),
          totalPoints: state.points,
          trials: state.results
        },
        null,
        2
      ),
      "application/json"
    );
  }

  function downloadCsv() {
    if (!state.results.length) {
      return;
    }
    const keys = Object.keys(state.results[0]);
    const rows = [
      keys.join(","),
      ...state.results.map((row) => keys.map((key) => csvEscape(row[key])).join(","))
    ];
    downloadFile("greyhound-pilot-session.csv", rows.join("\n"), "text/csv;charset=utf-8");
  }

  function restartPilot() {
    state.currentTrialIndex = -1;
    state.currentTrial = null;
    state.currentDogCards = [];
    state.selectedDogIndex = null;
    state.trapAssignments = null;
    state.cashoutShown = false;
    state.cashoutChoice = "pending";
    state.points = 0;
    state.results = [];
    state.startedAt = new Date().toISOString();
    updateHeader();
    showScreen("intro");
  }

  els.startButton.addEventListener("click", () => {
    state.startedAt = new Date().toISOString();
    prepareTrial();
  });
  els.choiceNext.addEventListener("click", handleChoiceContinue);
  els.assignmentNext.addEventListener("click", handleAssignmentContinue);
  els.confidenceNext.addEventListener("click", startRace);
  els.cashoutAccept.addEventListener("click", () => handleCashout("accept"));
  els.cashoutReject.addEventListener("click", () => handleCashout("reject"));
  els.resultNext.addEventListener("click", () => {
    resetSlider(els.pleasedSlider, els.pleasedValue, 50);
    resetSlider(els.motivationSlider, els.motivationValue, 50);
    resetSlider(els.luckSlider, els.luckValue, 50);
    showScreen("postrace");
  });
  els.postraceNext.addEventListener("click", handlePostraceContinue);
  els.downloadJson.addEventListener("click", downloadJson);
  els.downloadCsv.addEventListener("click", downloadCsv);
  els.restartButton.addEventListener("click", restartPilot);
  els.raceVideo.addEventListener("pause", handleRacePause);
  els.raceVideo.addEventListener("timeupdate", handleRaceTimeUpdate);
  els.raceVideo.addEventListener("contextmenu", (event) => {
    event.preventDefault();
  });
  els.raceVideo.addEventListener("error", () => {
    els.videoFallback.classList.remove("hidden");
  });

  wireSlider(els.confidenceSlider, els.confidenceValue);
  wireSlider(els.pleasedSlider, els.pleasedValue);
  wireSlider(els.motivationSlider, els.motivationValue);
  wireSlider(els.luckSlider, els.luckValue);

  updateHeader();
})();
