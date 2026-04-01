# Grid Wars: Student Guide

## The Challenge

You're entering a **bot tournament**. Your bot will be dropped onto a shared grid with every other student's bot. Each step, your bot moves one cell in any direction. If it lands on an unclaimed cell, that cell becomes yours. The bot that claims the most territory wins.

You don't control your bot in real time. You write the **brain** — a single method that decides which direction to move, and the game engine does the rest.

## What You're Building

You are writing a **subclass** of `BasePainter`. This is the core object-oriented concept at work:

- `BasePainter` is the **base class** — it knows how to move, render, and interact with the grid.
- Your class **extends** `BasePainter` — it inherits all of that behavior for free.
- You **override** one method — `getNextMove()` — to replace the default random walk with your own strategy.

That's inheritance in action: reuse what exists, replace what you want to change.

## Your File

You submit **one file**. Start with `MyPainter.pde` and rename the class:

```java
class EricBot extends BasePainter {

  EricBot(int startX, int startY, color col, String name) {
    super(startX, startY, col, name);
  }

  Direction getNextMove(int[][] grid, int cols, int rows) {
    // Your strategy goes here.
    // Return one of: UP, DOWN, LEFT, RIGHT
    return randomDir();
  }
}
```

That's a complete, valid submission. It walks randomly. You can do better.

## The One Method You Override

```java
Direction getNextMove(int[][] grid, int cols, int rows)
```

This is called once per simulation step. You look at the world, you pick a direction.

**Parameters:**

| Name   | Type      | What It Is |
|--------|-----------|------------|
| `grid` | `int[][]` | The full game board. `grid[row][col]` is `-1` (unclaimed) or a player ID. |
| `cols` | `int`     | Number of columns in the grid. |
| `rows` | `int`     | Number of rows in the grid. |

**What you can access inside this method:**

| Expression    | What It Gives You |
|---------------|-------------------|
| `this.x`      | Your current column |
| `this.y`      | Your current row |
| `this.id`     | Your player ID (matches values in the grid) |
| `this.score`  | How many cells you've claimed so far |
| `grid[r][c]`  | Who owns cell at row `r`, column `c` (-1 = nobody) |
| `UP, DOWN, LEFT, RIGHT` | Direction constants you can return |
| `DIRS`        | Array of all four directions |
| `randomDir()` | Helper that returns a random direction |

**You must return** one of: `UP`, `DOWN`, `LEFT`, or `RIGHT`.

## How the Grid Works

The grid is a 2D array indexed as `grid[row][col]`, which means `grid[y][x]`:

```
        col 0   col 1   col 2   ...
row 0  [  -1  ] [  -1  ] [  3  ] ...
row 1  [   0  ] [  -1  ] [  -1  ] ...
row 2  [   0  ] [   0  ] [  -1  ] ...
```

- `-1` means the cell is **unclaimed** — move there to score a point.
- Any other number is a **player ID** — that cell is taken. Moving there is legal but doesn't score.

**Important:** It's `grid[y][x]`, not `grid[x][y]`. Row first, column second.

## Strategies, Simple to Advanced

### Level 1: Random Walk (the default)
```java
return randomDir();
```
Wanders aimlessly. Claims some territory by accident. This is your baseline.

### Level 2: Greedy Neighbor
Check your four neighbors. If any are unclaimed, go there.
```java
for (Direction d : DIRS) {
  int nx = this.x + d.dx;
  int ny = this.y + d.dy;
  if (nx >= 0 && nx < cols && ny >= 0 && ny < rows
      && grid[ny][nx] == -1) {
    return d;
  }
}
return randomDir();
```
Better than random — you never waste a step when there's free territory next to you.

### Level 3: Target a Location
Pick a coordinate and move toward it. Good for claiming a specific region.
```java
int targetX = cols / 2;
int targetY = rows / 2;
if (abs(targetX - this.x) > abs(targetY - this.y)) {
  return targetX > this.x ? RIGHT : LEFT;
} else {
  return targetY > this.y ? DOWN : UP;
}
```

### Level 4: Use State
Your class can have instance variables that persist between calls. Track where you've been, plan a path, remember a strategy.

```java
class SmartBot extends BasePainter {
  boolean goingRight = true;

  SmartBot(int startX, int startY, color col, String name) {
    super(startX, startY, col, name);
  }

  Direction getNextMove(int[][] grid, int cols, int rows) {
    if (goingRight && this.x >= cols - 2) goingRight = false;
    if (!goingRight && this.x <= 1) goingRight = true;
    return goingRight ? RIGHT : LEFT;
  }
}
```

### Level 5: BFS / Pathfinding
Search the grid for the nearest unclaimed cell and take the first step toward it. Never waste a move.

### Level 6: Strategic Analysis
Count unclaimed cells in different regions. Steer toward the emptiest area. Avoid crowded zones where other bots are competing.

## The OO Concepts in Play

### Inheritance
Your class **extends** `BasePainter`. You get movement, rendering, scoring, and grid interaction without writing any of it. You only write the decision-making.

### Method Overriding
`BasePainter` has a `getNextMove()` that returns a random direction. Your class **overrides** it with a smarter version. The game engine calls `getNextMove()` — it doesn't know or care which version runs. That's **polymorphism**.

### Encapsulation
You can't see or modify the engine code. You interact through a clean interface: the grid array, your position, and the direction you return. The engine handles everything else.

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

## Rules

- The grid starts completely unclaimed.
- Every step, all bots move simultaneously.
- Landing on an unclaimed cell claims it and adds 1 to your score.
- Landing on an already-claimed cell (yours or anyone's) does nothing.
- Moving off the edge of the grid is clamped — you stay at the border.
- The game ends when the grid is full or the step limit is reached.
- Highest score wins. All bots play the full game — no elimination.

## What to Submit

One `.pde` file containing your class. Rename it from `MyPainter` to something unique (your name, a creative name — whatever you want). Make sure it extends `BasePainter` and has the constructor that calls `super()`.

Good luck. Claim everything.
