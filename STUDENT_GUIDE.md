# Grid Wars: Student Guide

## The Challenge

You're entering a **bot tournament**. Your bot will be dropped onto a shared grid with every other student's bot. Each step, your bot moves one cell in any direction. If it lands on an unclaimed cell, that cell turns your color and becomes yours. The bot that claims the most territory wins.

You don't control your bot in real time. You write the **brain** — a single method that decides which direction to move, and the game engine does the rest.

## What You're Building

You are writing a **subclass** of `Bot`. This is the core object-oriented concept at work:

- `Bot` is the **base class** — it handles movement, rendering, scoring, and grid interaction.
- Your class **extends** `Bot` — it inherits all of that behavior for free.
- You **override** `getNextMove()` to replace the default random walk with your own strategy.
- But your bot is more than one method — you design a full class with its own instance variables, helper methods, and constructor logic. You're building a self-contained agent that remembers, plans, and adapts.

That's inheritance in action: reuse what exists, replace what you want to change, and build your own logic on top.

## Your File

You submit **one file** named `LastnameFirstnameBot.pde`. The class name inside must match the file name.

For example, if your name is Jane Smith, your file is `SmithJaneBot.pde`:

```java
class SmithJaneBot extends Bot {

  SmithJaneBot(int startX, int startY, color col, String name) {
    super(startX, startY, col, name);
  }

  Direction getNextMove(GameInfo game) {
    // Your strategy goes here.
    // Return one of: UP, DOWN, LEFT, RIGHT
    return randomDir();
  }
}
```

That's a complete, valid bot. It walks randomly. You can do better.

## The One Method You Override

```java
Direction getNextMove(GameInfo game)
```

This is called once per simulation step. You look at the world through the `game` object, you pick a direction.

**You must return** one of: `UP`, `DOWN`, `LEFT`, or `RIGHT`. These are global constants — predefined Direction objects available everywhere in your code, just like `true` or `false`.

---

## Understanding the Data Structures

Before you write a strategy, understand what you're working with.

### The Grid: `game.grid[row][col]`

The playing field is a 2D integer array — like a 1D array, but with rows and columns instead of just one index. You access it with two indices: `grid[row][col]`. Each cell holds either `-1` (unclaimed) or a bot's ID number.

```
        col 0   col 1   col 2   col 3   ...
row 0  [  -1  ] [  -1  ] [  3  ] [  -1  ] ...
row 1  [   0  ] [  -1  ] [  -1  ] [  -1  ] ...
row 2  [   0  ] [   0  ] [  -1  ] [   2  ] ...
```

- `-1` means the cell is **unclaimed** — move there to score a point.
- `0`, `1`, `2`, etc. is the **bot ID** of whoever claimed it. Your own ID is `this.id`, so `game.grid[r][c] == this.id` means you own that cell.
- Moving onto a claimed cell (yours or anyone's) is legal but doesn't score.

**Important: it's `grid[row][col]`, which is `grid[y][x]` — row first, column second.** Your bot's position is `this.x` (column) and `this.y` (row), so to check your own cell: `game.grid[this.y][this.x]`.

The grid is roughly 150 rows tall and sized to fill the screen. Exact dimensions are in `game.rows` and `game.cols`.

### The GameInfo Object

The `game` parameter passed to `getNextMove()` is your window into the world. It wraps the grid and gives you useful query methods so you don't have to write bounds-checking yourself.

**Fields you can read:**

| Field             | Type             | What It Is                                               |
| ----------------- | ---------------- | -------------------------------------------------------- |
| `game.grid`       | `int[][]`        | The raw grid. `game.grid[row][col]` is `-1` or a bot ID. |
| `game.cols`       | `int`            | Number of columns (grid width).                          |
| `game.rows`       | `int`            | Number of rows (grid height).                            |
| `game.bots`       | `ArrayList<Bot>` | List of all bots in the game.                            |
| `game.step`       | `int`            | Current simulation step (0, 1, 2...).                    |
| `game.totalSteps` | `int`            | Step limit for the game.                                 |

**Cell query methods:**

| Method                           | Returns   | What It Does                                               |
| -------------------------------- | --------- | ---------------------------------------------------------- |
| `game.inBounds(row, col)`        | `boolean` | Is this coordinate on the grid?                            |
| `game.getOwner(row, col)`        | `int`     | Bot ID of owner, `-1` if unclaimed, `-2` if out of bounds. |
| `game.isUnclaimed(row, col)`     | `boolean` | Is this cell free to claim?                                |
| `game.isClaimed(row, col)`       | `boolean` | Has any bot claimed this cell?                             |
| `game.isMine(row, col, this.id)` | `boolean` | Did I claim this cell?                                     |

**Spatial query methods:**

| Method                                        | Returns | What It Does                                             |
| --------------------------------------------- | ------- | -------------------------------------------------------- |
| `game.countUnclaimed()`                       | `int`   | Total free cells on the entire grid.                     |
| `game.countUnclaimedInRegion(r1, c1, r2, c2)` | `int`   | Free cells in a rectangular area (inclusive).            |
| `game.getNearestBot(this.x, this.y, this.id)` | `Bot`   | Closest opponent by Manhattan distance. `null` if alone. |

**Game state methods:**

| Method               | Returns | What It Does                                |
| -------------------- | ------- | ------------------------------------------- |
| `game.getProgress()` | `float` | 0.0 at start, 1.0 at end.                   |
| `game.getBotCount()` | `int`   | Number of bots in the game.                 |
| `game.getBot(id)`    | `Bot`   | Look up any bot by ID. `null` if not found. |

**Scouting other bots:** You can read any bot's position, score, and color. Use `game.getNearestBot()` or loop through `game.bots`:

```java
Bot enemy = game.getNearestBot(this.x, this.y, this.id);
if (enemy != null) {
  int theirScore = enemy.score;   // how many cells they've claimed
  int theirX = enemy.x;           // their column
  int theirY = enemy.y;           // their row
}
```

### Your Bot: `this`

Inside `getNextMove()`, `this` is your bot. Here's what you can access:

| Expression   | Type    | What It Gives You                         |
| ------------ | ------- | ----------------------------------------- |
| `this.x`     | `int`   | Your current column.                      |
| `this.y`     | `int`   | Your current row.                         |
| `this.id`    | `int`   | Your bot ID (matches values in the grid). |
| `this.score` | `int`   | How many cells you've claimed so far.     |
| `this.col`   | `color` | Your bot's color.                         |

### Bot Helper Methods

These are built into the `Bot` class. Call them on `this` — they handle bounds-checking for you.

| Method          | Returns                | What It Does                                                                                     |
| --------------- | ---------------------- | ------------------------------------------------------------------------------------------------ |
| `canClaim(d)`   | `boolean`              | Is the cell in direction `d` unclaimed?                                                          |
| `isInBounds(d)` | `boolean`              | Is the cell in direction `d` on the grid?                                                        |
| `peekCell(d)`   | `int`                  | Who owns the cell in direction `d`? Returns `-1` (unclaimed), `-2` (out of bounds), or a bot ID. |
| `getFreeDirs()` | `ArrayList<Direction>` | All directions that lead to unclaimed cells.                                                     |

### Directions

Four global constants you can return from `getNextMove()`:

| Constant | `dx` | `dy` | Effect                 |
| -------- | ---- | ---- | ---------------------- |
| `UP`     | 0    | -1   | Move up one row.       |
| `DOWN`   | 0    | +1   | Move down one row.     |
| `LEFT`   | -1   | 0    | Move left one column.  |
| `RIGHT`  | +1   | 0    | Move right one column. |

Also available:

- `DIRS` — array of all four directions: `[UP, DOWN, LEFT, RIGHT]`
- `randomDir()` — returns a random direction

---

## Strategies, Simple to Advanced

### Level 1: Random Walk (the default)

```java
return randomDir();
```

Wanders aimlessly. Claims some territory by accident. This is your baseline.

### Level 2: Greedy Neighbor

If any neighbor is unclaimed, go there. Never waste a step when there's free territory next to you.

```java
ArrayList<Direction> free = getFreeDirs();
if (free.size() > 0) {
  return free.get((int) random(free.size()));
}
return randomDir();
```

### Level 3: Target a Location

Pick a coordinate and move toward it. Good for claiming a specific region.

```java
int targetX = game.cols / 2;
int targetY = game.rows / 2;
if (abs(targetX - this.x) > abs(targetY - this.y)) {
  return targetX > this.x ? RIGHT : LEFT;
} else {
  return targetY > this.y ? DOWN : UP;
}
```

### Level 4: Use State

Your class can have instance variables that persist between calls. Track where you've been, plan a path, remember a strategy.

```java
class SmartBot extends Bot {
  boolean goingRight = true;

  SmartBot(int startX, int startY, color col, String name) {
    super(startX, startY, col, name);
  }

  Direction getNextMove(GameInfo game) {
    if (goingRight && this.x >= game.cols - 2) goingRight = false;
    if (!goingRight && this.x <= 1) goingRight = true;
    return goingRight ? RIGHT : LEFT;
  }
}
```

### Level 5: Avoid or Chase Opponents

Use `game.getNearestBot()` to find the closest enemy and steer away from crowded areas — or toward them if you're feeling aggressive.

```java
Bot enemy = game.getNearestBot(this.x, this.y, this.id);
if (enemy != null) {
  // Move AWAY from nearest enemy
  int dx = this.x - enemy.x;
  int dy = this.y - enemy.y;
  if (abs(dx) > abs(dy)) return dx > 0 ? RIGHT : LEFT;
  else return dy > 0 ? DOWN : UP;
}
return randomDir();
```

### Level 6: BFS / Pathfinding

Search the grid for the nearest unclaimed cell and take the first step toward it. Never waste a move.

### Level 7: Strategic Analysis

Use `game.countUnclaimedInRegion()` to scan different quadrants. Steer toward the emptiest area. Adapt your strategy based on `game.getProgress()` — play aggressive early, defensive late.

## The OO Concepts in Play

### Inheritance

Your class **extends** `Bot`. You get movement, rendering, scoring, and grid interaction without writing any of it. You only write the decision-making.

### Method Overriding

`Bot` has a `getNextMove()` that returns a random direction. Your class **overrides** it with a smarter version. The game engine calls `getNextMove()` — it doesn't know or care which version runs. That's **polymorphism**. But overriding is just the entry point — the real work is all the logic you build in your class to support that decision.

### Encapsulation

You can't see or modify the engine code. You interact through a clean interface: the `GameInfo` object, your position, and the direction you return. The engine handles everything else.

### Constructors and `super()`

Your constructor calls `super(startX, startY, col, name)` to initialize the base class fields. This is constructor chaining — your subclass adds its own setup on top of what the parent already does.

### Instance Variables as State

Adding fields to your class lets your bot remember things between steps. This is object state — each bot instance has its own memory, independent of every other bot on the grid.

## Customize Your Bot's Look

Set these in your constructor:

```java
this.label       = "Z";    // character drawn on your bot
this.glowSize    = 1.5;    // glow size multiplier (0.5 – 2.0)
this.trailLength = 25;     // trail length (0 = off, max 40)
```

## Testing Your Bot

Edit `TestConfig.pde` to set up your test match. This is the only file you need to change:

```java
void configureSmartBots() {
  addBot("SmithJaneBot", 1);   // your bot
  addBot("SmartBot", 3);          // 3 tough opponents
  addBot("RandomBot", 2);       // 2 easy opponents
}
```

Add one line per bot. The second number is how many copies to add. Press **R** to restart, **Space** to start.

**Available opponent bots:**

| Bot          | Strategy                   |
| ------------ | -------------------------- |
| `SmartBot`    | Strong all-around opponent |
| `RandomBot` | Random walk (easy)         |

## Rules

- The grid starts completely unclaimed.
- Every step, all bots move simultaneously.
- Landing on an unclaimed cell claims it and adds 1 to your score.
- Landing on an already-claimed cell (yours or anyone's) does nothing.
- Moving off the edge of the grid is clamped — you stay at the border.
- The game runs for 120 seconds or until the grid is full.
- Highest score wins. All bots play the full game — no elimination.
- **Performance rule:** Your bot must not significantly degrade the game's frame rate. If your `getNextMove()` method is too computationally expensive (e.g., scanning the entire grid multiple times per step, running unbounded loops), your bot will be disqualified. Keep your logic efficient — the game needs to run smoothly for everyone.

## What to Submit

One `.pde` file named `LastnameFirstnameBot.pde` (e.g., `SmithJaneBot.pde`). The class name inside must match the file name exactly. Make sure it extends `Bot` and has the constructor that calls `super()`.

## Deadline

**Tuesday, April 21st at 8:00 AM.** No exceptions. No late submissions.

The professor and TAs have significant prep work to set up the tournament bracket, and we need your submissions to do that. If your bot isn't submitted by the deadline, it won't be in the competition.

## Prizes

**Tournament (bracket elimination):**

| Place | Prize                    |
| ----- | ------------------------ |
| 1st   | +10 points on your grade |
| 2nd   | +5 points                |
| 3rd   | +3 points                |
| 4th   | +2 points                |

**Beast Mode (all bots, one grid, no mercy):**

We run Beast Mode **3 times** — each round's winner gets **+5 points**.

**One prize per person.** If you win the tournament, you can't also claim a Beast Mode prize (it goes to the next highest finisher). If you win multiple Beast Mode rounds, you only keep one.

Good luck. Claim everything.
