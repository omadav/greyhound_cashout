const PILOT_CONFIG = {
  studyTitle: "Greyhound Prolific Pilot",
  baseWinPoints: 10,
  demoVideoSrc: "./assets/videos/demo.mp4",
  dogPool: [
    {
      name: "Bobby",
      county: "Essex",
      age: "3 yrs",
      recentForm: "2-1-2",
      seasonWinPct: "31%",
      avgPos: "2.4"
    },
    {
      name: "Mabel",
      county: "Kent",
      age: "2 yrs",
      recentForm: "3-1-1",
      seasonWinPct: "28%",
      avgPos: "2.7"
    },
    {
      name: "Dash",
      county: "Surrey",
      age: "4 yrs",
      recentForm: "1-4-2",
      seasonWinPct: "34%",
      avgPos: "2.3"
    },
    {
      name: "Poppy",
      county: "Devon",
      age: "3 yrs",
      recentForm: "5-2-1",
      seasonWinPct: "26%",
      avgPos: "3.1"
    },
    {
      name: "Rex",
      county: "Leeds",
      age: "2 yrs",
      recentForm: "1-2-4",
      seasonWinPct: "29%",
      avgPos: "2.6"
    },
    {
      name: "Tilly",
      county: "Bristol",
      age: "3 yrs",
      recentForm: "2-3-2",
      seasonWinPct: "24%",
      avgPos: "3.0"
    }
  ],
  trials: [
    {
      trialId: "pilot-1",
      raceId: "demo-nw",
      label: "Demo 1",
      condition: "NW",
      conditionCopy: "Close win / almost caught at the line",
      videoSrc: "./assets/videos/demo.mp4",
      assignedTrap: 3,
      finishPosition: 1,
      finishLabel: "1st",
      finishOrder: [3, 2, 1, 4, 5, 6],
      cashoutOffer: 5,
      cashoutPauseSec: 8.5,
      notes: "Interface pilot only. Uses the demo clip as a narrow-win style trial."
    },
    {
      trialId: "pilot-2",
      raceId: "demo-nm",
      label: "Demo 2",
      condition: "NM",
      conditionCopy: "Near miss / your dog comes very close but does not win",
      videoSrc: "./assets/videos/demo.mp4",
      assignedTrap: 2,
      finishPosition: 2,
      finishLabel: "2nd",
      finishOrder: [3, 2, 1, 4, 5, 6],
      cashoutOffer: 7,
      cashoutPauseSec: 9.25,
      notes: "Interface pilot only. Uses the demo clip as a near-miss trial."
    },
    {
      trialId: "pilot-3",
      raceId: "demo-cl",
      label: "Demo 3",
      condition: "CL",
      conditionCopy: "Clear loss / your dog does not contend for the win",
      videoSrc: "./assets/videos/demo.mp4",
      assignedTrap: 1,
      finishPosition: 3,
      finishLabel: "3rd",
      finishOrder: [3, 2, 1, 4, 5, 6],
      cashoutOffer: 3,
      cashoutPauseSec: 8.75,
      notes: "Interface pilot only. Uses the demo clip as a clear-loss style placeholder."
    },
    {
      trialId: "pilot-4",
      raceId: "demo-cw",
      label: "Demo 4",
      condition: "CW",
      conditionCopy: "Clear win placeholder for the full pilot flow",
      videoSrc: "./assets/videos/demo.mp4",
      assignedTrap: 3,
      finishPosition: 1,
      finishLabel: "1st",
      finishOrder: [3, 2, 1, 4, 5, 6],
      cashoutOffer: 5,
      cashoutPauseSec: 8.25,
      notes: "Interface pilot only. Replace with a true clear-win clip once AVIs are converted."
    }
  ]
};
