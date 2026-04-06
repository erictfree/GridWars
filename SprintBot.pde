// ── SprintBot — "Frontier + one cheap tiebreaker" ───────────
//
// Identical to FrontierBot's zero-overhead BFS, but when multiple
// unclaimed cells are found at the same distance, picks the one
// with the most unclaimed neighbors (O(4) check). No opponent
// tracking, no region scans, no scoring formulas.

class SprintBot extends Bot {

  final int MAX_BFS = 90000;
  int[] bfsQx = new int[MAX_BFS];
  int[] bfsQy = new int[MAX_BFS];
  int[] bfsQdir = new int[MAX_BFS];
  boolean[] bfsVisited = new boolean[MAX_BFS];

  SprintBot(int startX, int startY, color col, String name) {
    super(startX, startY, col, name);
  }

  Direction getNextMove(GameInfo game) {
    int cols = game.cols;
    int rows = game.rows;

    // Greedy: if any neighbor is unclaimed, pick the one with
    // the most unclaimed neighbors behind it (O(16) total)
    int bestIdx = -1;
    int bestOpen = -1;
    for (int i = 0; i < DIRS.length; i++) {
      int nx = this.x + DIRS[i].dx;
      int ny = this.y + DIRS[i].dy;
      if (!game.isUnclaimed(ny, nx)) continue;

      int adj = 0;
      for (int j = 0; j < DIRS.length; j++) {
        if (game.isUnclaimed(ny + DIRS[j].dy, nx + DIRS[j].dx)) adj++;
      }
      if (adj > bestOpen) {
        bestOpen = adj;
        bestIdx = i;
      }
    }
    if (bestIdx >= 0) return DIRS[bestIdx];

    // BFS to nearest unclaimed — same as Frontier but with tiebreaker
    int total = cols * rows;
    int clearLen = min(total, MAX_BFS);
    java.util.Arrays.fill(bfsVisited, 0, clearLen, false);

    int head = 0, tail = 0;
    bfsVisited[this.y * cols + this.x] = true;

    for (int i = 0; i < DIRS.length; i++) {
      int nx = this.x + DIRS[i].dx;
      int ny = this.y + DIRS[i].dy;
      if (!game.inBounds(ny, nx)) continue;
      int idx = ny * cols + nx;
      if (idx < 0 || idx >= clearLen || bfsVisited[idx]) continue;
      bfsVisited[idx] = true;
      if (tail < MAX_BFS) {
        bfsQx[tail] = nx;
        bfsQy[tail] = ny;
        bfsQdir[tail] = i;
        tail++;
      }
    }

    int foundDepth = -1;
    int bestDir = -1;
    int bestAdj = -1;
    int waveEnd = tail;
    int depth = 1;

    while (head < tail) {
      if (head >= waveEnd) {
        depth++;
        waveEnd = tail;
        // Stop once we've evaluated all candidates at found depth
        if (foundDepth >= 0 && depth > foundDepth) break;
      }

      int cx = bfsQx[head];
      int cy = bfsQy[head];
      int fd = bfsQdir[head];
      head++;

      for (int i = 0; i < DIRS.length; i++) {
        int nx = cx + DIRS[i].dx;
        int ny = cy + DIRS[i].dy;
        if (!game.inBounds(ny, nx)) continue;
        int idx = ny * cols + nx;
        if (idx < 0 || idx >= clearLen || bfsVisited[idx]) continue;
        bfsVisited[idx] = true;

        if (game.isUnclaimed(ny, nx)) {
          foundDepth = depth;
          // Tiebreaker: count unclaimed neighbors (O(4))
          int adj = 0;
          for (int j = 0; j < DIRS.length; j++) {
            if (game.isUnclaimed(ny + DIRS[j].dy, nx + DIRS[j].dx)) adj++;
          }
          if (adj > bestAdj) {
            bestAdj = adj;
            bestDir = fd;
          }
          continue;
        }

        if (tail < MAX_BFS) {
          bfsQx[tail] = nx;
          bfsQy[tail] = ny;
          bfsQdir[tail] = fd;
          tail++;
        }
      }
    }

    if (bestDir >= 0) return DIRS[bestDir];
    return randomDir();
  }
}
