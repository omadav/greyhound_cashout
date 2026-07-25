/*
 * Study 1 configuration: near-miss greyhound race task.
 *
 * The condition a participant experiences is set by (a) which race they see and
 * (b) which trap their chosen dog is secretly assigned to:
 *
 *   CW  clear win     clear race,  chosen dog = winner trap      finishes 1st
 *   NW  narrow win    close race,  chosen dog = winner trap      finishes 1st
 *   NM  near miss     close race,  chosen dog = runner-up trap   finishes 2nd
 *   CL  clear loss    clear race,  chosen dog = a back trap      unplaced
 *
 * clear/close labels come from Omar's by-eye coding pass (race_coding_sheet.csv,
 * eye_label column). Trap numbers are the real finishing order from the 2013
 * result boards. Study 1 has no cash-out; the flag below turns it off but leaves
 * the machinery in place for Studies 3 and 4.
 */
const STUDY = {
  id: "study1",
  title: "Greyhound Race Task", // internal / data only — never shown to participants
  brand: "Trackside", // participant-facing name; neutral, does not hint at near misses
  tagline: "Live Greyhound Racing",
  creditLabel: "credits", // in-task currency shown to participants (not real money)
  startingBalance: 0,
  // Payment (set on Prolific, not here): £2.00 completion fee + up to £2.00 bonus.
  // Every participant wins 10 races -> 100 credits, so the bonus is a flat £2 for all
  // (100 credits x £0.02). Effective ~£10-12/hr for a 20-25 min session.
  // Pavlovia deployment config — only used when pavlovia.js is loaded (the pavlovia/
  // build). projectId is the numeric Pavlovia/GitLab experiment id; completionURL is
  // the Prolific "completed" redirect. Left null on the GitHub Pages debug copy, where
  // the task falls back to local CSV/JSON download.
  pavlovia: { projectId: null, completionURL: "" },
  cashout: false,
  baseWinPoints: 10,
  cashoutOffers: [3, 5, 7],
  repsPerCondition: 5,
  videoDir: "./assets/videos/",

  // Standard UK greyhound trap jacket colours, so participants can follow their dog.
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

  // How many races of each pool the schedule draws. clear pool feeds CW + CL,
  // close pool feeds NW + NM, all distinct within a participant.
  allocation: [
    { condition: "CW", pool: "clear", count: 5 },
    { condition: "CL", pool: "clear", count: 5 },
    { condition: "NW", pool: "close", count: 5 },
    { condition: "NM", pool: "close", count: 5 }
  ],

  // Races 1-23 (the ones whose finish is visible on video). winner/runnerUp/third
  // are trap numbers; missing lists vacant traps.
  races: [
    { id: 1, video: "1.mp4", kind: "clear", nRunners: 6, missing: [], winner: 1, runnerUp: 4, third: 2 },
    { id: 2, video: "2.mp4", kind: "close", nRunners: 5, missing: [4], winner: 3, runnerUp: 2, third: 1 },
    { id: 3, video: "3.mp4", kind: "close", nRunners: 6, missing: [], winner: 3, runnerUp: 4, third: 5 },
    { id: 4, video: "4.mp4", kind: "close", nRunners: 6, missing: [], winner: 3, runnerUp: 5, third: 2 },
    { id: 5, video: "5.mp4", kind: "close", nRunners: 6, missing: [], winner: 2, runnerUp: 3, third: 1 },
    { id: 6, video: "6.mp4", kind: "clear", nRunners: 6, missing: [], winner: 6, runnerUp: 3, third: 5 },
    { id: 7, video: "7.mp4", kind: "close", nRunners: 6, missing: [], winner: 6, runnerUp: 2, third: 3 },
    { id: 8, video: "8.mp4", kind: "clear", nRunners: 6, missing: [], winner: 6, runnerUp: 1, third: 3 },
    { id: 9, video: "9.mp4", kind: "close", nRunners: 6, missing: [], winner: 4, runnerUp: 1, third: 2 },
    { id: 10, video: "10.mp4", kind: "clear", nRunners: 5, missing: [6], winner: 1, runnerUp: 3, third: 4 },
    { id: 11, video: "11.mp4", kind: "clear", nRunners: 6, missing: [], winner: 4, runnerUp: 1, third: 2 },
    { id: 12, video: "12.mp4", kind: "clear", nRunners: 6, missing: [], winner: 6, runnerUp: 3, third: 5 },
    { id: 13, video: "13.mp4", kind: "clear", nRunners: 6, missing: [], winner: 2, runnerUp: 1, third: 3 },
    { id: 14, video: "14.mp4", kind: "close", nRunners: 6, missing: [], winner: 4, runnerUp: 6, third: 5 },
    { id: 15, video: "15.mp4", kind: "close", nRunners: 6, missing: [], winner: 1, runnerUp: 3, third: 4 },
    { id: 16, video: "16.mp4", kind: "close", nRunners: 5, missing: [2], winner: 6, runnerUp: 3, third: 1 },
    { id: 17, video: "17.mp4", kind: "clear", nRunners: 6, missing: [], winner: 5, runnerUp: 2, third: 6 },
    { id: 18, video: "18.mp4", kind: "clear", nRunners: 6, missing: [], winner: 4, runnerUp: 6, third: 5 },
    { id: 19, video: "19.mp4", kind: "clear", nRunners: 5, missing: [6], winner: 1, runnerUp: 3, third: 4 },
    { id: 20, video: "20.mp4", kind: "close", nRunners: 6, missing: [], winner: 1, runnerUp: 4, third: 5 },
    { id: 21, video: "21.mp4", kind: "close", nRunners: 6, missing: [], winner: 3, runnerUp: 1, third: 4 },
    { id: 22, video: "22.mp4", kind: "close", nRunners: 5, missing: [6], winner: 3, runnerUp: 5, third: 4 },
    { id: 23, video: "23.mp4", kind: "clear", nRunners: 6, missing: [], winner: 3, runnerUp: 5, third: 1 }
  ],

  // Dog names are built as "<kennel prefix> <word>", greyhound-registry style.
  // A session needs up to 6 x 20 = 120 names. The app deals each PREFIX at most
  // once per session (sampled without replacement), so no two dogs ever look like
  // littermates ("Skywalker Rebel" / "Skywalker Bullet"), which participants
  // otherwise read as family resemblance. Words may recur but never within the
  // same race card. Names are never repeated across the session (learning effects).
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

  // Purely decorative form details shown on the choice card. They carry no
  // information about the outcome (the outcome is set by trap assignment). Their
  // only job is to make the choice feel engaging, as in the original lab task.
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

// Back-compat alias so older references keep working.
const PILOT_CONFIG = STUDY;
