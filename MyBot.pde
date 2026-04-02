// ─────────────────────────────────────────────────────────────
//  Student Bot Scaffold
//
//  Rename this class and implement your strategy in getNextMove().
//
//  The GameInfo object gives you access to the entire game world:
//    game.grid[row][col]            — bot ID that claimed this cell, or -1 if unclaimed
//    game.cols, game.rows           — grid dimensions
//    game.isUnclaimed(row, col)     — is this cell free to claim?
//    game.isClaimed(row, col)       — has any bot claimed this cell?
//    game.isMine(row, col, this.id) — did I claim this cell?
//    game.inBounds(row, col)        — is this coordinate on the grid?
//    game.getOwner(row, col)        — returns bot ID of owner, -1 if unclaimed
//    game.countUnclaimed()          — total free cells
//    game.getNearestBot(x, y, id)   — find closest opponent
//    game.getProgress()             — 0.0 → 1.0 game progress
//    game.getBot(id)                — look up any bot by ID
//
//  Helper methods you can call on yourself:
//    this.canClaim(direction)        — is that direction free to claim?
//    this.peekCell(direction)        — who owns the cell that way?
//    this.getFreeDirs()              — list of claimable directions
//
//  Your position:  this.x (column), this.y (row)
//  Your ID:        this.id
//  Your score:     this.score
//  Directions:     UP, DOWN, LEFT, RIGHT, DIRS, randomDir()
// ─────────────────────────────────────────────────────────────

class MyBot extends Bot {

  MyBot(int startX, int startY, color col, String name) {
    super(startX, startY, col, name);

    // ── Customize your bot's look ──────────────────────────
    // this.label       = "X";     // character drawn on your bot
    // this.glowSize    = 1.5;     // glow multiplier (0.5 – 2.0)
    // this.trailLength = 25;      // trail length (0 = off, max 40)
  }

  Direction getNextMove(GameInfo game) {

    // ── Example 1: Random walk ──
    return randomDir();

    // ── Example 2: Prefer unclaimed neighbors ──
    // ArrayList<Direction> free = getFreeDirs();
    // if (free.size() > 0) {
    //   return free.get((int) random(free.size()));
    // }
    // return randomDir();

    // ── Example 3: Move toward the center ──
    // int targetX = game.cols / 2, targetY = game.rows / 2;
    // if (abs(targetX - this.x) > abs(targetY - this.y)) {
    //   return targetX > this.x ? RIGHT : LEFT;
    // } else {
    //   return targetY > this.y ? DOWN : UP;
    // }

    // ── Example 4: Avoid the nearest opponent ──
    // Bot enemy = game.getNearestBot(this.x, this.y, this.id);
    // if (enemy != null) {
    //   int dx = this.x - enemy.x;  // move AWAY
    //   int dy = this.y - enemy.y;
    //   if (abs(dx) > abs(dy)) return dx > 0 ? RIGHT : LEFT;
    //   else return dy > 0 ? DOWN : UP;
    // }
    // return randomDir();
  }
}
