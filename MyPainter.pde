// ─────────────────────────────────────────────────────────────
//  Student Bot Scaffold
//
//  Rename this class and implement your strategy in getNextMove().
//
//  Available inside getNextMove():
//    this.x, this.y   — your current column and row
//    this.id           — your painter ID
//    this.score        — cells you've claimed so far
//    grid[row][col]    — -1 = unclaimed, N = owned by painter N
//    cols, rows        — grid dimensions
//    UP, DOWN, LEFT, RIGHT  — direction constants
//    DIRS              — array of all four directions
//    randomDir()       — returns a random direction
//
//  You may add any instance variables you need in your constructor.
// ─────────────────────────────────────────────────────────────

class MyPainter extends BasePainter {

  MyPainter(int startX, int startY, color col, String name) {
    super(startX, startY, col, name);

    // ── Customize your bot's look ──────────────────────────
    // this.label       = "X";     // character drawn on your bot
    // this.glowSize    = 1.5;     // glow multiplier (0.5 – 2.0)
    // this.trailLength = 25;      // trail length (0 = off, max 40)
  }

  Direction getNextMove(int[][] grid, int cols, int rows) {

    // ── Example 1: Random walk (simplest possible bot) ──
    return randomDir();

    // ── Example 2: Prefer unclaimed neighbors ──
    // for (Direction d : DIRS) {
    //   int nx = this.x + d.dx;
    //   int ny = this.y + d.dy;
    //   if (nx >= 0 && nx < cols && ny >= 0 && ny < rows
    //       && grid[ny][nx] == -1) {
    //     return d;
    //   }
    // }
    // return randomDir();

    // ── Example 3: Move toward a target coordinate ──
    // int targetX = cols / 2, targetY = rows / 2;
    // if (abs(targetX - this.x) > abs(targetY - this.y)) {
    //   return targetX > this.x ? RIGHT : LEFT;
    // } else {
    //   return targetY > this.y ? DOWN : UP;
    // }
  }
}
