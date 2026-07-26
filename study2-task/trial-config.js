/*
 * Study 2 configuration: near-miss TRAJECTORY.
 *
 * Study 1 asked whether a near miss differs from a clear loss. Study 2 asks
 * whether the *shape* of the near miss matters: did your dog run out of track
 * while closing (catch-up), lead and get caught (fall-back), or finish close
 * without the gap ever changing (stable)?
 *
 * Trajectory is described from the LOSING dog's point of view — the dog a
 * near-miss participant is assigned to — and is judged on the HOME STRAIGHT,
 * because that is where the expectation of winning is built or destroyed.
 * See analysis/stimulus_notes.md for the coding rule and the rater agreement.
 *
 * Trajectory is a fixed property of the clip and cannot be reassigned. What IS
 * assigned is the role: the winner trap gives a narrow win, the runner-up trap
 * gives a near miss. So each clip supplies its own within-clip baseline.
 *
 *   CW  clear win     clear race,  chosen dog = winner trap      finishes 1st
 *   NW  narrow win    close race,  chosen dog = winner trap      finishes 1st
 *   NM  near miss     close race,  chosen dog = runner-up trap   finishes 2nd
 *   CL  clear loss    clear race,  chosen dog = a back trap      unplaced
 *
 * Roles are assigned by ROTATION on a participant index, not at random. Study 1
 * randomised and ended up with race 20 seen 27 times as NM and 11 as NW, while
 * 14% of participants never saw a catch-up near miss at all.
 */
const STUDY = {
  id: "study2",
  title: "Greyhound Race Task — trajectory", // internal / data only
  brand: "Trackside",
  tagline: "Live Greyhound Racing",
  creditLabel: "credits",
  startingBalance: 0,
  // Payment as Study 1: £2.00 completion + £2.00 bonus.
  // A full session is 4 CW + 6 NW + 6 NM + 4 CL = 20 trials, so every participant
  // wins 10 races (4 CW + 6 NW) -> 100 credits -> a flat £2.00 at £0.02/credit.
  // Same as Study 1. NOTE: this does NOT scale from a ?reps=1 test run, where the
  // clear races drop to 1 each while the close races drop to 1 per trajectory.
  pavlovia: { projectId: null, completionURL: "" },
  cashout: false,
  baseWinPoints: 10,
  cashoutOffers: [3, 5, 7],
  videoDir: "./assets/videos/",

  trapColours: {
    1: { name: "red", css: "#d7263d", text: "#fff" },
    2: { name: "blue", css: "#1b6ca8", text: "#fff" },
    3: { name: "white", css: "#f4f4f4", text: "#222" },
    4: { name: "black", css: "#222", text: "#fff" },
    5: { name: "orange", css: "#e6791f", text: "#fff" },
    6: { name: "black and white stripes", css: "repeating-linear-gradient(45deg,#222 0 8px,#f4f4f4 8px 16px)", text: "#fff" }
  },

  conditions: {
    CW: { code: "CW", label: "Clear win", pool: "clear", role: "winner", finishPos: 1 },
    NW: { code: "NW", label: "Narrow win", pool: "close", role: "winner", finishPos: 1 },
    NM: { code: "NM", label: "Near miss", pool: "close", role: "runnerUp", finishPos: 2 },
    CL: { code: "CL", label: "Clear loss", pool: "clear", role: "back", finishPos: 99 }
  },

  /*
   * Per participant, per trajectory: 2 near misses + 2 narrow wins.
   * Equal NM counts across trajectories is what the within-participant contrast
   * needs. NW counts need not be balanced within a participant — the narrow-win
   * baseline is pooled across participants at the clip level — but keeping them
   * equal costs nothing here.
   *
   * A participant can never see the same clip twice, so 2 NM + 2 NW requires at
   * least 4 clips in every trajectory. That is why catch-up has 4.
   */
  trajectoryAllocation: { nmPerTrajectory: 2, nwPerTrajectory: 2 },
  clearAllocation: { CW: 4, CL: 4 },

  /*
   * Locked 2026-07-25. Ten of the thirteen close clips carry over from Study 1,
   * so the exploratory result and the confirmatory test share footage.
   *
   * `raters` records who supported the trajectory label in 2013 (Kate, rater B,
   * Yin) plus OP. `contested: true` marks a clip where OP and the 2013 majority
   * disagree — declared in the pre-registration, with a sensitivity analysis that
   * drops it. A mislabelled clip dilutes its cell and biases toward the null, so
   * including it makes the test harder to pass, not easier.
   */
  // Runner counts and vacant traps verified against the footage by OP on
  // 2026-07-26: races 32 and 35 ran 6 dogs with no vacant trap.
  //
  // Race 31 was dropped 2026-07-26: the 2013 raters split (stable / complex /
  // fall-back) and OP's own reading moved three times (catch-up -> uncertain ->
  // stable). Stable only needs 4 clips, so removing the least certain one costs
  // nothing and makes every clip in the study sit at an even 50/50 role split.
  races: [
    // ---- catch-up: the losing dog was closing and ran out of track ----
    { id: 3,  video: "3.mp4",  kind: "close", trajectory: "catch-up", nRunners: 6, missing: [],  winner: 3, runnerUp: 4, third: 5, raters: "OP (2013 split)", fromStudy1: true },
    { id: 4,  video: "4.mp4",  kind: "close", trajectory: "catch-up", nRunners: 6, missing: [],  winner: 3, runnerUp: 5, third: 2, raters: "unanimous", fromStudy1: true },
    { id: 16, video: "16.mp4", kind: "close", trajectory: "catch-up", nRunners: 5, missing: [2], winner: 6, runnerUp: 3, third: 1, raters: "OP + Kate; Yin says stable", fromStudy1: true, contested: true },
    { id: 32, video: "32.mp4", kind: "close", trajectory: "catch-up", nRunners: 6, missing: [], winner: 2, runnerUp: 6, third: 3, raters: "unanimous", fromStudy1: false },

    // ---- fall-back: the losing dog led and was caught ----
    { id: 5,  video: "5.mp4",  kind: "close", trajectory: "fall-back", nRunners: 6, missing: [], winner: 2, runnerUp: 3, third: 1, raters: "unanimous", fromStudy1: true },
    { id: 7,  video: "7.mp4",  kind: "close", trajectory: "fall-back", nRunners: 6, missing: [], winner: 6, runnerUp: 2, third: 3, raters: "unanimous", fromStudy1: true },
    { id: 9,  video: "9.mp4",  kind: "close", trajectory: "fall-back", nRunners: 6, missing: [], winner: 4, runnerUp: 1, third: 2, raters: "unanimous", fromStudy1: true },
    { id: 15, video: "15.mp4", kind: "close", trajectory: "fall-back", nRunners: 6, missing: [], winner: 1, runnerUp: 3, third: 4, raters: "unanimous", fromStudy1: true },

    // ---- stable: close finish, gap never changed ----
    { id: 2,  video: "2.mp4",  kind: "close", trajectory: "stable", nRunners: 5, missing: [4], winner: 3, runnerUp: 2, third: 1, raters: "unanimous", fromStudy1: true },
    { id: 20, video: "20.mp4", kind: "close", trajectory: "stable", nRunners: 6, missing: [],  winner: 1, runnerUp: 4, third: 5, raters: "OP + Yin (2013 split)", fromStudy1: true },
    { id: 21, video: "21.mp4", kind: "close", trajectory: "stable", nRunners: 6, missing: [],  winner: 3, runnerUp: 1, third: 4, raters: "unanimous", fromStudy1: true },
    { id: 35, video: "35.mp4", kind: "close", trajectory: "stable", nRunners: 6, missing: [], winner: 1, runnerUp: 2, third: 4, raters: "OP + 2013 majority", fromStudy1: false },

    // ---- clear races: supply CW and CL. Daytime only, no interference. ----
    { id: 1,  video: "1.mp4",  kind: "clear", nRunners: 6, missing: [],  winner: 1, runnerUp: 4, third: 2, fromStudy1: true },
    { id: 6,  video: "6.mp4",  kind: "clear", nRunners: 6, missing: [],  winner: 6, runnerUp: 3, third: 5, fromStudy1: true },
    { id: 8,  video: "8.mp4",  kind: "clear", nRunners: 6, missing: [],  winner: 6, runnerUp: 1, third: 3, fromStudy1: true },
    { id: 10, video: "10.mp4", kind: "clear", nRunners: 5, missing: [6], winner: 1, runnerUp: 3, third: 4, fromStudy1: true },
    { id: 11, video: "11.mp4", kind: "clear", nRunners: 6, missing: [],  winner: 4, runnerUp: 1, third: 2, fromStudy1: true },
    { id: 12, video: "12.mp4", kind: "clear", nRunners: 6, missing: [],  winner: 6, runnerUp: 3, third: 5, fromStudy1: true },
    { id: 13, video: "13.mp4", kind: "clear", nRunners: 6, missing: [],  winner: 2, runnerUp: 1, third: 3, fromStudy1: true },
    { id: 17, video: "17.mp4", kind: "clear", nRunners: 6, missing: [],  winner: 5, runnerUp: 2, third: 6, fromStudy1: true },
    { id: 18, video: "18.mp4", kind: "clear", nRunners: 6, missing: [],  winner: 4, runnerUp: 6, third: 5, fromStudy1: true },
    { id: 19, video: "19.mp4", kind: "clear", nRunners: 5, missing: [6], winner: 1, runnerUp: 3, third: 4, fromStudy1: true },
    { id: 23, video: "23.mp4", kind: "clear", nRunners: 6, missing: [],  winner: 3, runnerUp: 5, third: 1, fromStudy1: true }
  ],

  // Dog names: "<kennel prefix> <word>", greyhound-registry style. Each prefix is
  // dealt at most once per session so no two dogs read as littermates.
  namePrefixes: [
    "Ballymac", "Droopys", "Coolavanny", "Newinn", "Kilbride", "Rathcoole",
    "Clonbrien", "Skywalker", "Ballyanne", "Sidarian", "Tullymurry", "Whiteforest",
    "Bockos", "Portmageehy", "Lemon", "Swift", "Good", "Romeo", "Signet", "Jaytee",
    "Aero", "Alpine", "Amber", "Anvil", "Arden", "Ashdown", "Aurora", "Avalon",
    "Barnfield", "Beacon", "Bexley", "Birchwood", "Blackrock", "Boulder", "Bramble",
    "Brandon", "Briarwood", "Brookside", "Cairn", "Caldera", "Camden", "Carrick",
    "Cascade", "Cedar", "Chelston", "Clifden", "Cobalt", "Copperfield", "Cranmore",
    "Crestwood", "Dalton", "Danbury", "Darrow", "Deerpark", "Delmore", "Denby",
    "Dovecote", "Dunmore", "Eastgate", "Eldon", "Elmhurst", "Everton", "Fairlight",
    "Falconer", "Fenwick", "Fernhill", "Flintlock", "Foxglove", "Galleon", "Garnet",
    "Glenmore", "Granton", "Greystone", "Halcyon", "Hallmark", "Hartley", "Havenwood",
    "Hazelmere", "Highfield", "Hollybank", "Ironside", "Ivybridge", "Kelston",
    "Kenmare", "Kestrel", "Langford", "Larkspur", "Latham", "Ledbury", "Linfield",
    "Longcroft", "Lyndhurst", "Marlowe", "Mayfair", "Meadowbank", "Melrose",
    "Merrion", "Millbrook", "Monarch", "Moorland", "Netherby", "Northgate", "Oakhill",
    "Oldcastle", "Orwell", "Pembroke", "Penrose", "Quarryman", "Ravensworth",
    "Redmond", "Ridgeway", "Rosslare", "Rowanwood", "Saltmarsh", "Sandown",
    "Selby", "Sheringham", "Silverdale", "Stanfield", "Stonebridge", "Sunniside",
    "Talbot", "Thornbury", "Tideswell", "Ullswater", "Vanguard", "Wexford",
    "Whitfield", "Willowbrook", "Windermere", "Wyndham", "Yardley", "Zennor"
  ],
  nameWords: [
    "Rocket", "Bullet", "Comet", "Blaze", "Storm", "Flyer", "Arrow", "Dash",
    "Bolt", "Chief", "Ranger", "Rebel", "Gold", "Ace", "King", "Star",
    "Dancer", "Hero", "Spirit", "Thunder", "Champ", "Fury", "Jet", "Magic",
    "Legend", "Wonder", "Prince", "Rascal", "Turbo", "Vision", "Breeze", "Cruiser",
    "Dazzler", "Echo", "Falcon", "Gambit", "Harrier", "Impulse", "Jester", "Knight",
    "Lancer", "Marvel", "Nomad", "Onyx", "Pilot", "Quest", "Ripple", "Sprinter",
    "Tempest", "Vortex", "Whisper", "Zephyr"
  ],

  // Decorative only. Carry no information about the outcome.
  trainers: [
    "P. Kennedy", "R. Holt", "M. O'Donnell", "S. Cahill", "J. Mullins",
    "L. Field", "K. Boon", "T. Levers", "D. Mullins", "A. Taylor",
    "B. Foster", "G. Baggs", "N. Savva", "C. Philpott", "H. Keightley"
  ],
  towns: [
    "Romford", "Hove", "Sheffield", "Nottingham", "Sunderland", "Newcastle",
    "Crayford", "Perry Barr", "Monmore", "Yarmouth", "Doncaster", "Swindon",
    "Harlow", "Central Park", "Towcester", "Kinsley"
  ]
};

const PILOT_CONFIG = STUDY;
