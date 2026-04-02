// ── GameInfo — read-only view of the game world ─────────────
// Passed to getNextMove() so bots can query the game state
// through methods rather than raw array access.

class GameInfo {

  int[][] grid;                    // grid[row][col]: -1 = unclaimed, N = owner ID
  int cols, rows;                  // grid dimensions
  ArrayList<Bot> bots;     // all bots in the game
  int step;                        // current simulation step
  int totalSteps;                  // step limit

  GameInfo(int[][] grid, int cols, int rows,
           ArrayList<Bot> bots, int step, int totalSteps) {
    this.grid       = grid;
    this.cols       = cols;
    this.rows       = rows;
    this.bots       = bots;
    this.step       = step;
    this.totalSteps = totalSteps;
  }

  // ── Cell queries ──────────────────────────────────────────

  /** True if (row, col) is within the grid. */
  boolean inBounds(int row, int col) {
    return row >= 0 && row < rows && col >= 0 && col < cols;
  }

  /** Returns the owner of the cell (-1 if unclaimed, -2 if out of bounds). */
  int getOwner(int row, int col) {
    if (!inBounds(row, col)) return -2;
    return grid[row][col];
  }

  /** True if the cell is unclaimed. */
  boolean isUnclaimed(int row, int col) {
    return inBounds(row, col) && grid[row][col] == -1;
  }

  /** True if the cell is claimed by anyone. */
  boolean isClaimed(int row, int col) {
    return inBounds(row, col) && grid[row][col] >= 0;
  }

  /** True if the cell is owned by the given player ID. */
  boolean isMine(int row, int col, int myId) {
    return inBounds(row, col) && grid[row][col] == myId;
  }

  // ── Spatial queries ───────────────────────────────────────

  /** Count all unclaimed cells on the grid. */
  int countUnclaimed() {
    int count = 0;
    for (int r = 0; r < rows; r++) {
      for (int c = 0; c < cols; c++) {
        if (grid[r][c] == -1) count++;
      }
    }
    return count;
  }

  /** Count unclaimed cells in a rectangular region (inclusive). */
  int countUnclaimedInRegion(int r1, int c1, int r2, int c2) {
    int count = 0;
    for (int r = max(0, r1); r <= min(rows - 1, r2); r++) {
      for (int c = max(0, c1); c <= min(cols - 1, c2); c++) {
        if (grid[r][c] == -1) count++;
      }
    }
    return count;
  }

  /** Find the nearest bot to (x, y) that isn't myId. Returns null if alone. */
  Bot getNearestBot(int x, int y, int myId) {
    Bot nearest = null;
    float bestDist = Float.MAX_VALUE;
    for (Bot b : bots) {
      if (b.id == myId) continue;
      float d = abs(b.x - x) + abs(b.y - y);  // Manhattan distance
      if (d < bestDist) {
        bestDist = d;
        nearest = b;
      }
    }
    return nearest;
  }

  // ── Game state ────────────────────────────────────────────

  /** Game progress from 0.0 (start) to 1.0 (end). */
  float getProgress() {
    return (float) step / totalSteps;
  }

  /** Number of bots in the game. */
  int getBotCount() {
    return bots.size();
  }

  /** Look up a bot by its ID. Returns null if not found. */
  Bot getBot(int id) {
    if (id >= 0 && id < bots.size()) return bots.get(id);
    return null;
  }
}
