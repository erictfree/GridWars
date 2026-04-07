# Grid Wars — Product Requirements Document

**Course:** AET310 Creative Coding  
**School:** Arts & Entertainment Technologies, UT Austin  
**Stack:** Processing (Java)  
**Purpose:** End-of-semester tournament assignment teaching OOP inheritance

---

## 1. Concept

Grid Wars is a real-time multi-agent territory game. Each student submits a **bot** — a subclass of `Bot` — that autonomously moves around a shared grid and claims cells by color. The bot with the most cells at the end wins. All bots run simultaneously; students never touch the engine, only their subclass.

The pedagogical goal: the base class does all the hard work, and students override one method (`getNextMove()`), then build strategy logic around it. The game has a very low floor (a random walker is valid) and a high ceiling (BFS, influence maps, opponent tracking, etc.).

---

## 2. Core Game Rules

- The grid is dynamically sized (~150 rows, columns computed to fill the screen).
- Every cell starts **unclaimed** (`-1`).
- Each simulation step, every bot calls `getNextMove()` and moves one cell in the returned direction.
- If a bot moves onto an **unclaimed** cell, it turns the bot's color and their score increments.
- If a bot moves onto an **already-claimed** cell (any owner), nothing happens.
- Bots **cannot move off the grid**; out-of-bounds moves are clamped to the border.
- The game runs for **120 seconds** or until the grid is full.
- There is no elimination — all bots play for the full duration.
- Highest score wins.

---

## 3. Technical Specification

### 3.1 Constants (GridBot.pde)

| Constant | Value | Description |
|----------|-------|-------------|
| `TARGET_ROWS` | 150 | Desired row count; COLS computed to fill width |
| `CELL` | computed | Pixel size per cell (min 4) |
| `GAME_TIME_MS` | 120000 | 2 minutes per game |
| `LIMIT` | ~8000+ | Step limit (scales with grid size) |
| `STEPS` | 1 | Simulation steps per frame (test mode) |
| `TOURNEY_STEPS` | 2 | Steps per frame (tournament mode) |

Window size: **1770 × 1100** (HIGH_RES=true) or **1200 × 750** (HIGH_RES=false).

### 3.2 Direction Constants

```java
Direction UP    = new Direction( 0, -1);
Direction DOWN  = new Direction( 0,  1);
Direction LEFT  = new Direction(-1,  0);
Direction RIGHT = new Direction( 1,  0);
Direction[] DIRS = { UP, DOWN, LEFT, RIGHT };
```

### 3.3 Grid Data Structure

```java
int[][] grid = new int[ROWS][COLS];
// grid[row][col]: -1 = unclaimed, N = bot ID
```

Accessed via the `GameInfo` object passed to `getNextMove()`.

### 3.4 GameInfo API

The `GameInfo` object provides read-only access to game state:

| Method | Returns | Description |
|--------|---------|-------------|
| `game.grid[row][col]` | `int` | Raw grid access |
| `game.cols`, `game.rows` | `int` | Grid dimensions |
| `game.inBounds(row, col)` | `boolean` | Bounds check |
| `game.isUnclaimed(row, col)` | `boolean` | Is cell free? |
| `game.isClaimed(row, col)` | `boolean` | Is cell owned? |
| `game.isMine(row, col, id)` | `boolean` | Is cell mine? |
| `game.getOwner(row, col)` | `int` | Cell owner (-1, -2 OOB, or ID) |
| `game.countUnclaimed()` | `int` | Total free cells |
| `game.countUnclaimedInRegion(r1,c1,r2,c2)` | `int` | Free cells in rect |
| `game.getNearestBot(x, y, myId)` | `Bot` | Closest opponent |
| `game.getProgress()` | `float` | 0.0 → 1.0 |
| `game.getBotCount()` | `int` | Number of bots |
| `game.getBot(id)` | `Bot` | Lookup by ID |

### 3.5 Bot Helper Methods

| Method | Returns | Description |
|--------|---------|-------------|
| `canClaim(d)` | `boolean` | Is cell in direction d free? |
| `isInBounds(d)` | `boolean` | Is cell in direction d on grid? |
| `peekCell(d)` | `int` | Owner of cell in direction d |
| `getFreeDirs()` | `ArrayList<Direction>` | Directions leading to free cells |

---

## 4. Game Modes

### 4.1 Test Mode (default)

- Students configure bots in `TestConfig.pde` using `addBot("BotName", count)`
- Press **Space** to start, **R** to restart
- Credits scroll on splash screen, contender reveal before game

### 4.2 Beast Mode (admin: type 1983, then B)

- All tournament bots on one massive grid, no elimination
- Uses `beastbackground.jpg` background
- Top 4 winners displayed on podium with 80s arcade glow effects

### 4.3 Tournament Mode (admin: type 1983, then T)

- Bracket elimination: groups of ~16, top 4 advance per heat
- Multiple rounds → semifinals → grand final
- Uses `headertournament.png` background
- Champion screen with confetti

---

## 5. Audio System

| Context | Files | Behavior |
|---------|-------|----------|
| Splash/pre-play | `pre1.mp3`, `pre2.mp3` | Loops on all splash screens |
| Test gameplay | `test1.mp3` – `test7.mp3` | Random, no back-to-back repeats |
| Tournament heats | `theme1.mp3`, `theme2.mp3` | Random per heat |
| Beast mode gameplay | `beast.mp3` | Loops during beast game |

Music fades out on screen transitions (~1.5 sec). Mute button in lower-left corner persists across modes.

---

## 6. Visual Design

### 6.1 Retro Arcade Aesthetic

- 8-bit monospace font (PressStart2P)
- CRT scanlines on splash screens
- Neon glow effects (offset-based, same-size text layers)
- Cyan/magenta double borders on panels
- Corner diamonds on arcade panels

### 6.2 Game Over (both modes)

- Top 4 podium: 1st (CHAMPION label, 4-layer glow, 46px), 2nd (28px), 3rd (24px), 4th (20px)
- Gold/silver/bronze/steel medal colors
- Confetti particles

### 6.3 Bot Rendering

- Pixel-art square indicator with blink
- Color swatch + trailing dots
- Name label with dark backing
- Customizable: `label`, `glowSize`, `trailLength`

---

## 7. File Structure

```
GridBot/
├── GridBot.pde          # Main sketch: setup, draw, game loop, constants
├── Bot.pde              # Base class — the student API
├── GameInfo.pde         # Read-only game state wrapper
├── Direction.pde        # Direction class (dx, dy)
├── BotFactory.pde       # Name → instance lookup (add student bots here)
├── BotRegistry.pde      # Bot lists for test/tournament modes
├── TestConfig.pde       # Student-editable test match config
├── Tournament.pde       # Bracket system, heat management
├── Effects.pde          # Particles, confetti, milestones, magnifier
├── GameOver.pde         # Winner podium, arcade panel helpers
├── Intro.pde            # Splash screens, credits scroll
├── HUD.pde              # Timer bar, step counter
├── Sidebar.pde          # Live leaderboard
├── Palettes.pde         # Retro color palettes
├── MyBot.pde            # Student starter scaffold
├── STUDENT_GUIDE.md     # Student-facing documentation
│
├── RandomBot.pde       # Random walk (easy opponent)
├── SmartBot.pde          # Strong opponent (obfuscated)
├── RandomBot.pde        # Random walk reference
├── GreedyBot.pde        # Greedy neighbor reference
├── FrontierBot.pde      # BFS pathfinding reference
├── SpiralBot.pde        # Spiral pattern reference
├── HunterBot.pde        # Quadrant targeting reference
├── [12 more strategy bots...]
│
└── data/
    ├── header.png             # Test mode background
    ├── headertournament.png   # Tournament background
    ├── beastbackground.jpg    # Beast mode background
    ├── PressStart2P-Regular.ttf
    ├── pre1.mp3, pre2.mp3     # Splash music
    ├── test1-7.mp3            # Test gameplay music
    ├── theme1-2.mp3           # Tournament music
    └── beast.mp3              # Beast mode music
```

---

## 8. Configuration Flags (GridBot.pde)

| Flag | Default | Description |
|------|---------|-------------|
| `HIGH_RES` | `true` | `false` for 1200×750 window |
| `SAVE_SCREENSHOTS` | `false` | Save grid image after each game |
| `adminUnlocked` | `false` | Type 1983 to enable T/B keys |

---

## 9. Admin Code

Type `1983` on any screen to unlock tournament (T) and beast mode (B) keys. "ADMIN UNLOCKED" flashes green on screen.
