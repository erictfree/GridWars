# Territory Grab — Product Requirements Document

**Course:** AET310 Creative Coding  
**School:** School of Design & Creative Technologies, UT Austin  
**Stack:** p5.js (browser), targeting eventual port to Processing (Java)  
**Purpose:** End-of-semester tournament assignment teaching OOP inheritance

---

## 1. Concept

Territory Grab is a real-time multi-agent grid game. Each student submits a **Painter bot** — a subclass of `BasePainter` — that autonomously moves around a shared grid and claims cells by color. The bot with the most cells at the end of the round wins. All bots run simultaneously in the same sketch; students never touch the engine, only their subclass.

The pedagogical goal is identical to the Snake tournament: the base class does all the hard work, and students override exactly one method. The game has a very low floor (a random walker is a valid submission) and a high ceiling (BFS, Voronoi, influence maps, etc.).

---

## 2. Core Game Rules

- The grid is **80 columns × 80 rows** (6,400 cells total).
- Every cell starts **unclaimed** (`-1`).
- Each simulation step, every bot calls `getNextMove()` and moves one cell in the returned direction.
- If a bot moves onto an **unclaimed** cell, that cell becomes theirs and their score increments.
- If a bot moves onto an **already-claimed** cell (any owner), nothing changes — they just occupy it.
- Bots **cannot move off the grid**; out-of-bounds moves are clamped to the nearest valid position.
- The game ends after **8,000 simulation steps**. Highest score wins.
- There is no elimination — all bots run for the full duration.

---

## 3. Technical Specification

### 3.1 Constants

```javascript
const COLS = 80; // grid columns
const ROWS = 80; // grid rows
const CELL = 10; // pixels per cell → 800×800 grid area
const SIDE = 182; // sidebar width (leaderboard)
const BOT = 52; // bottom HUD height
const STEPS = 5; // simulation steps executed per draw() frame
const LIMIT = 8000; // total simulation steps per game
```

Canvas size: **982 × 852 px** (`COLS*CELL + SIDE` × `ROWS*CELL + BOT`)

### 3.2 Direction Constants

```javascript
const UP = { dx: 0, dy: -1 };
const DOWN = { dx: 0, dy: 1 };
const LEFT = { dx: -1, dy: 0 };
const RIGHT = { dx: 1, dy: 0 };
const DIRS = [UP, DOWN, LEFT, RIGHT];
```

These are the only valid return values from `getNextMove()`.

### 3.3 Grid Data Structure

```javascript
// grid[row][col]
//   -1  → unclaimed
//    N  → owned by painter with id === N
grid = Array.from({ length: ROWS }, () => new Int8Array(COLS).fill(-1));
```

The grid is passed (read-only by convention) into every `getNextMove()` call so bots can observe the full world state.

---

## 4. Base Class Specification

This is the only file students receive. Everything below `getNextMove()` is engine code they do not modify.

```javascript
class BasePainter {

  constructor(startX, startY, col, name) {
    this.x     = startX;   // current column
    this.y     = startY;   // current row
    this.col   = col;      // p5 color object — used for rendering
    this.name  = name;     // display name in leaderboard
    this.id    = -1;       // assigned by engine at game start (0-indexed)
    this.score = 0;        // cells claimed
  }

  // ─────────────────────────────────────────────────────────────
  //  ★  OVERRIDE THIS METHOD  ★
  //
  //  Called once per simulation step.
  //  grid : 2D Int8Array  —  grid[row][col]
  //                          -1 = unclaimed, N = owned by painter N
  //  cols : number of columns (80)
  //  rows : number of rows    (80)
  //
  //  Must return one of:  UP | DOWN | LEFT | RIGHT
  // ─────────────────────────────────────────────────────────────
  getNextMove(grid, cols, rows) {
    return random(DIRS);
  }

  // Engine methods — do not override
  update() { ... }   // calls getNextMove, clamps, claims cell
  show()   { ... }   // renders glowing dot at current position
}
```

### 4.1 What Students Can Access Inside `getNextMove()`

| Expression           | Type   | Meaning                      |
| -------------------- | ------ | ---------------------------- |
| `this.x`             | int    | bot's current column         |
| `this.y`             | int    | bot's current row            |
| `this.id`            | int    | this bot's owner ID          |
| `this.score`         | int    | cells claimed so far         |
| `grid[row][col]`     | int    | -1=unclaimed, N=owned by N   |
| `cols`, `rows`       | int    | grid dimensions              |
| `DIRS`               | Array  | [UP, DOWN, LEFT, RIGHT]      |
| `UP/DOWN/LEFT/RIGHT` | Object | `{dx, dy}` direction objects |

Students may add any instance variables they want in their subclass constructor.

---

## 5. Reference Bot Implementations

Five bots ship with the engine as examples and default tournament opponents. Ordered by sophistication:

### 5.1 RandomBot

Picks a direction uniformly at random every step. The control group baseline.

```javascript
class RandomBot extends BasePainter {
  getNextMove(g, c, r) {
    return random(DIRS);
  }
}
```

### 5.2 GreedyBot

Checks all four neighbors; moves to an unclaimed one if available, otherwise random. One local scan, no lookahead.

```javascript
class GreedyBot extends BasePainter {
  getNextMove(g, c, r) {
    let free = [];
    for (let d of DIRS) {
      let nx = this.x + d.dx,
        ny = this.y + d.dy;
      if (nx >= 0 && nx < c && ny >= 0 && ny < r && g[ny][nx] === -1)
        free.push(d);
    }
    return free.length ? random(free) : random(DIRS);
  }
}
```

### 5.3 SpiralBot

Maintains state across calls to walk a clockwise expanding spiral. Demonstrates that `getNextMove()` can be stateful via instance variables.

Key state: `_di` (direction index), `_steps`, `_limit`, `_turns`. Leg length increments every two turns. Bounces off walls by turning.

### 5.4 FrontierBot

Runs a **BFS** from the bot's current position every step to find the nearest unclaimed cell, then returns the first direction on that path. Never wastes a step on a claimed cell when an unclaimed one is reachable.

Implementation uses a flat `Uint8Array(cols * rows)` for the visited set (fast allocation, avoids GC pressure). Index formula: `ny * cols + nx`.

### 5.5 HunterBot

**Macro-strategic**: divides the map into four quadrants, counts unclaimed cells in each, and steers toward the center of the richest quadrant. Re-evaluates every step. Works well early (claims entire quadrant regions) but stalls late when all quadrants are largely claimed.

---

## 6. Engine Architecture

### 6.1 Game Loop

```
setup()
  └── initGame()
        ├── reset grid to -1
        ├── instantiate painters[], assign .id, claim starting cell

draw()  [runs ~60fps]
  ├── for STEPS iterations:
  │     ├── painters.forEach(p => p.update())
  │     └── stepCount++  →  if >= LIMIT: endGame()
  ├── drawGrid()
  ├── drawBots()
  ├── drawSidebar()
  ├── drawHUD()
  └── if gameOver: drawGameOver()
```

### 6.2 Update Order

All bots update in array order each step (index 0 first). This creates a slight first-mover advantage for the first painter in the array. For a fair tournament, rotate starting order between rounds or randomize it in `initGame()`.

### 6.3 Starting Positions (default)

| Bot         | x   | y   |
| ----------- | --- | --- |
| RandomBot   | 4   | 4   |
| GreedyBot   | 75  | 4   |
| SpiralBot   | 4   | 75  |
| FrontierBot | 75  | 75  |
| HunterBot   | 39  | 39  |

For student tournaments, assign starting positions by lottery or symmetrically around the grid perimeter.

---

## 7. Visual Design

### 7.1 Grid Area (800×800)

- Unclaimed cells: `rgb(32, 32, 48)` — dark blue-grey
- Claimed cells: painter's color, full opacity
- Grid lines: black at 28 alpha, 0.25px weight (visible but not distracting)

### 7.2 Bot Indicator (layered circles at bot position)

Three concentric circles to suggest a glowing dot:

1. Outer glow: painter color at 50 alpha, diameter `CELL * 3.0`
2. Mid glow: painter color at 110 alpha, diameter `CELL * 2.0`
3. Core: painter color at full opacity, diameter `CELL * 1.35`
4. Specular: white at 200 alpha, diameter `CELL * 0.38`, offset slightly up-left

### 7.3 Sidebar (182px wide)

- Background: `rgb(18, 20, 36)`
- Leaderboard sorted by score descending, updated every frame
- Each entry: rank badge, bot name in its color, territory bar (pct of total cells), cell count and percentage
- Footer: `extend BasePainter` label

### 7.4 Bottom HUD (52px tall)

- Progress bar spanning grid width; color lerps from blue → red as game progresses
- Step counter: `step N / 8000`
- Restart button (right side, hover state)

### 7.5 Game Over Overlay

- Semi-transparent dark overlay on grid area only
- Modal banner with: "GAME OVER", winner name in winner's color, cell count and map percentage
- Sidebar leaderboard remains live for review

### 7.6 Color Palette (reference bots)

| Bot         | Color                      |
| ----------- | -------------------------- |
| RandomBot   | `rgb(220, 55, 55)` red     |
| GreedyBot   | `rgb(55, 120, 220)` blue   |
| SpiralBot   | `rgb(55, 195, 90)` green   |
| FrontierBot | `rgb(220, 150, 40)` orange |
| HunterBot   | `rgb(185, 60, 205)` purple |

Student bots should be assigned colors from a pre-defined palette to ensure visibility against the dark background and against each other.

---

## 8. Tournament Format (Suggested)

1. **Submission:** Students submit a single `.js` file containing their subclass. No other files.
2. **Integration:** Instructor pastes all student classes into the sketch and adds them to the `painters` array in `initGame()`, assigning starting positions.
3. **Rounds:** Run 3 rounds. Average score across rounds is the final score (mitigates random walk variance).
4. **Round duration:** ~25 seconds at 60fps with current settings — fast enough to run several rounds in class.
5. **Update order fairness:** Rotate the `painters` array order between rounds so every bot gets each position once across three rounds (if ≤ 3 bots; otherwise shuffle randomly).

---

## 9. Planned Enhancements

These are out of scope for the initial build but worth designing for:

### 9.1 Reclaim Mechanic (optional rule variant)

Allow bots to reclaim opponent-owned cells by moving onto them. Would increase aggression and make HunterBot/aggressive students much more competitive. Gate behind a config flag: `const ALLOW_RECLAIM = false`.

### 9.2 Student Bot Scaffolding File

A separate `MyPainter.js` starter file with:

- The class stub with `getNextMove()` pre-declared
- Inline comments explaining each parameter
- Three commented example snippets (random, check neighbor, target a coordinate)

### 9.3 Configurable Bot Count

The sidebar layout currently assumes 5 bots. With 20+ student bots the sidebar needs a scrollable or paginated layout, or a compact single-line format.

### 9.4 Speed Slider

A UI slider to set `STEPS` between 1 (slow-motion, good for demos) and 10 (fast, good for running many rounds quickly).

### 9.5 Round Manager

Auto-run N rounds, accumulate scores, display final standings. Removes the need to manually click Restart and add up results.

### 9.6 Replay / Playback

Record grid snapshots and replay at adjustable speed — useful for post-tournament analysis of bot strategies.

### 9.7 Processing (Java) Port

The p5.js version is the primary deliverable. A Processing port for students who prefer the desktop IDE would require:

- Replace `Int8Array` with `int[][]`
- Replace `random(array)` with index-based random selection
- Replace `color()` / `red()` / `green()` / `blue()` with Processing equivalents
- BFS visited set: `boolean[]` flat array, same index formula

---

## 10. File Structure

```
territory-grab/
├── index.html              # entry point, loads p5.js and all scripts
├── sketch.js               # setup(), draw(), game loop, constants, DIRS
├── BasePainter.js          # base class — the student API
├── bots/
│   ├── RandomBot.js
│   ├── GreedyBot.js
│   ├── SpiralBot.js
│   ├── FrontierBot.js
│   └── HunterBot.js
├── ui/
│   ├── sidebar.js          # drawSidebar()
│   ├── hud.js              # drawHUD()
│   └── gameOver.js         # drawGameOver()
└── student-bots/           # one file per student submission
    └── MyPainter.js        # starter scaffold
```

For the single-file prototype (current state), all of this lives in one `<script>` block. Splitting into modules is recommended before opening submissions to students.
