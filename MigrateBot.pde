// ── MigrateBot — "Find the open plains, move there, consume" ─
//
// Scans the grid for the region with the highest density of
// unclaimed cells, then navigates there and sweeps it clean.
// Like a herd migrating to fresh grazing land.
//
// Unlike HunterBot (which targets quadrant centers) or FloodBot
// (which stays in its current blob), MigrateBot actively
// relocates to wherever the richest territory is — even if it
// means a long trek through claimed land.

class MigrateBot extends Bot {

  final int MAX_BFS = 90000;
  int[] bfsQx = new int[MAX_BFS];
  int[] bfsQy = new int[MAX_BFS];
  int[] bfsQdir = new int[MAX_BFS];
  boolean[] bfsVisited = new boolean[MAX_BFS];

  // Target: the center of the richest region
  int targetX = -1, targetY = -1;
  int scanCounter = 0;

  MigrateBot(int startX, int startY, color col, String name) {
    super(startX, startY, col, name);
  }

  Direction getNextMove(GameInfo game) {
    int cols = game.cols;
    int rows = game.rows;

    // Rescan for richest region every 60 steps
    scanCounter++;
    if (scanCounter >= 60 || targetX < 0) {
      findRichestRegion(game, cols, rows);
      scanCounter = 0;
    }

    // Always claim free neighbors first
    ArrayList<Direction> free = getFreeDirs();

    if (free.size() > 0) {
      return pickTowardTarget(game, free, cols, rows);
    }

    // Navigate through claimed territory toward target
    return bfsTowardTarget(game, cols, rows);
  }

  // Scan the grid in a coarse grid of overlapping windows
  // to find the region with the most unclaimed cells
  void findRichestRegion(GameInfo game, int cols, int rows) {
    int bestCount = -1;
    int windowR = 20;  // scan window radius
    int step = 15;     // scan step size (coarse grid)

    for (int sy = windowR; sy < rows - windowR; sy += step) {
      for (int sx = windowR; sx < cols - windowR; sx += step) {
        int count = game.countUnclaimedInRegion(
          sy - windowR, sx - windowR,
          sy + windowR, sx + windowR
        );

        // Penalize regions where opponents are closer than us
        Bot nearest = game.getNearestBot(sx, sy, this.id);
        if (nearest != null) {
          float oppDist = abs(nearest.x - sx) + abs(nearest.y - sy);
          float myDist = abs(this.x - sx) + abs(this.y - sy);
          if (oppDist < myDist) {
            count = (int)(count * 0.4);  // opponent gets there first
          }
        }

        if (count > bestCount) {
          bestCount = count;
          targetX = sx;
          targetY = sy;
        }
      }
    }
  }

  // When we have free neighbors, pick the one that moves toward
  // our target while maximizing local openness
  Direction pickTowardTarget(GameInfo game, ArrayList<Direction> free, int cols, int rows) {
    Direction bestDir = null;
    float bestScore = -999;

    for (Direction d : free) {
      int nx = this.x + d.dx;
      int ny = this.y + d.dy;
      float score = 0;

      // Openness — unclaimed neighbors
      for (Direction nd : DIRS) {
        if (game.isUnclaimed(ny + nd.dy, nx + nd.dx)) score += 8;
      }

      // Bias toward target
      float curDist = abs(targetX - this.x) + abs(targetY - this.y);
      float newDist = abs(targetX - nx) + abs(targetY - ny);
      score += (curDist - newDist) * 2;

      if (score > bestScore) {
        bestScore = score;
        bestDir = d;
      }
    }

    return bestDir != null ? bestDir : free.get(0);
  }

  // BFS toward target — find unclaimed cells, prefer ones
  // closer to our target region
  Direction bfsTowardTarget(GameInfo game, int cols, int rows) {
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
      if (game.isUnclaimed(ny, nx)) return DIRS[i];
      if (tail < MAX_BFS) { bfsQx[tail]=nx; bfsQy[tail]=ny; bfsQdir[tail]=i; tail++; }
    }

    int foundDepth = -1;
    float bestScore = -999;
    int bestDir = -1;
    int waveEnd = tail, depth = 1;

    while (head < tail && head < MAX_BFS - 4) {
      if (head >= waveEnd) {
        depth++; waveEnd = tail;
        if (foundDepth >= 0 && depth > foundDepth + 3) break;
      }
      int cx = bfsQx[head]; int cy = bfsQy[head]; int fd = bfsQdir[head]; head++;

      for (int i = 0; i < DIRS.length; i++) {
        int nx = cx + DIRS[i].dx;
        int ny = cy + DIRS[i].dy;
        if (!game.inBounds(ny, nx)) continue;
        int idx = ny * cols + nx;
        if (idx < 0 || idx >= clearLen || bfsVisited[idx]) continue;
        bfsVisited[idx] = true;

        if (game.isUnclaimed(ny, nx)) {
          foundDepth = depth;
          float distToTarget = abs(targetX - nx) + abs(targetY - ny);
          float score = -depth - distToTarget * 0.5;
          if (score > bestScore) { bestScore = score; bestDir = fd; }
          continue;
        }
        if (tail < MAX_BFS) { bfsQx[tail]=nx; bfsQy[tail]=ny; bfsQdir[tail]=fd; tail++; }
      }
    }

    if (bestDir >= 0) return DIRS[bestDir];
    return randomDir();
  }
}
