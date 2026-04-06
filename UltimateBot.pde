// ── UltimateBot ─────────────────────────────────────────────
// Greedy local expansion with 2-step lookahead + BFS fallback.
// Opponent-aware: steers away from nearby bots.

class UltimateBot extends Bot {

  // ── Reusable BFS buffers (allocated once, reused every call) ──
  final int MAX_BFS = 90000;
  int[] bfsQx = new int[MAX_BFS];
  int[] bfsQy = new int[MAX_BFS];
  int[] bfsQdir = new int[MAX_BFS];
  boolean[] bfsVisited = new boolean[MAX_BFS];

  // ── State tracking ────────────────────────────────────────────
  int prevX = -1, prevY = -1;
  int stuckCount = 0;

  UltimateBot(int startX, int startY, color col, String name) {
    super(startX, startY, col, name);
  }

  Direction getNextMove(GameInfo game) {
    int cols = game.cols;
    int rows = game.rows;

    // Stuck detection
    if (this.x == prevX && this.y == prevY) {
      stuckCount++;
    } else {
      stuckCount = 0;
    }
    prevX = this.x;
    prevY = this.y;

    float progress = game.getProgress();

    // Phase 1: Try immediate greedy claim
    Direction greedyDir = bestGreedyDir(game, cols, rows, progress);
    if (greedyDir != null) {
      return greedyDir;
    }

    // Phase 2: BFS to nearest unclaimed cell
    Direction bfsResult = bfsToUnclaimed(game, cols, rows, progress);
    if (bfsResult != null) {
      return bfsResult;
    }

    return randomDir();
  }

  // ────────────────────────────────────────────────────────────
  //  GREEDY DIRECTION PICKER
  //  Scores each adjacent unclaimed cell by openness, opponent
  //  avoidance, and edge distance.
  // ────────────────────────────────────────────────────────────
  Direction bestGreedyDir(GameInfo game, int cols, int rows, float progress) {
    Direction bestDir = null;
    float bestScore = -999999;

    Bot nearest = game.getNearestBot(this.x, this.y, this.id);
    int oppX = -1, oppY = -1;
    float oppDist = 999;
    if (nearest != null) {
      oppX = nearest.x;
      oppY = nearest.y;
      oppDist = abs(oppX - this.x) + abs(oppY - this.y);
    }

    for (int i = 0; i < DIRS.length; i++) {
      Direction d = DIRS[i];
      int nx = this.x + d.dx;
      int ny = this.y + d.dy;

      if (!game.isUnclaimed(ny, nx)) continue;

      float score = 0;

      // Openness: unclaimed neighbors + 2-step lookahead
      int openNeighbors = 0;
      int totalUnclaimed2 = 0;
      for (int j = 0; j < DIRS.length; j++) {
        int nnx = nx + DIRS[j].dx;
        int nny = ny + DIRS[j].dy;
        if (game.isUnclaimed(nny, nnx)) {
          openNeighbors++;
          for (int k = 0; k < DIRS.length; k++) {
            int n3x = nnx + DIRS[k].dx;
            int n3y = nny + DIRS[k].dy;
            if (game.isUnclaimed(n3y, n3x)) {
              totalUnclaimed2++;
            }
          }
        }
      }
      score += openNeighbors * 10;
      score += totalUnclaimed2 * 2;

      // Opponent avoidance
      if (nearest != null && oppDist < 20) {
        float newDistToOpp = abs(oppX - nx) + abs(oppY - ny);
        float avoidanceWeight = (progress < 0.7) ? 8.0 : 2.0;
        score += (newDistToOpp - oppDist) * avoidanceWeight;
      }

      // Edge avoidance (early game)
      if (progress < 0.3) {
        int edgeDist = min(min(nx, cols - 1 - nx), min(ny, rows - 1 - ny));
        if (edgeDist < 5) {
          score -= (5 - edgeDist) * 3;
        }
      }

      // Jitter to escape stuck loops
      if (stuckCount > 3) {
        score += random(5);
      }

      if (score > bestScore) {
        bestScore = score;
        bestDir = d;
      }
    }

    return bestDir;
  }

  // ────────────────────────────────────────────────────────────
  //  BFS TO NEAREST UNCLAIMED CELL
  //  Collects candidates at the same BFS depth and picks the
  //  one with the most open territory around it.
  // ────────────────────────────────────────────────────────────
  Direction bfsToUnclaimed(GameInfo game, int cols, int rows, float progress) {
    int total = cols * rows;
    int clearLen = min(total, MAX_BFS);
    java.util.Arrays.fill(bfsVisited, 0, clearLen, false);

    int head = 0, tail = 0;
    int startIdx = this.y * cols + this.x;
    if (startIdx >= 0 && startIdx < clearLen) {
      bfsVisited[startIdx] = true;
    }

    // Seed with immediate neighbors
    for (int i = 0; i < DIRS.length; i++) {
      int nx = this.x + DIRS[i].dx;
      int ny = this.y + DIRS[i].dy;
      if (!game.inBounds(ny, nx)) continue;
      int idx = ny * cols + nx;
      if (idx < 0 || idx >= clearLen) continue;
      if (bfsVisited[idx]) continue;
      bfsVisited[idx] = true;

      if (game.isUnclaimed(ny, nx)) {
        return DIRS[i];
      }

      if (tail < MAX_BFS) {
        bfsQx[tail] = nx;
        bfsQy[tail] = ny;
        bfsQdir[tail] = i;
        tail++;
      }
    }

    // BFS expansion with wave tracking
    int waveEnd = tail;
    int currentDepth = 1;
    int foundDepth = -1;
    float bestCandidateScore = -999999;
    int bestCandidateDir = -1;

    while (head < tail && head < MAX_BFS - 4) {
      if (head >= waveEnd) {
        currentDepth++;
        waveEnd = tail;
        if (foundDepth >= 0 && currentDepth > foundDepth) {
          break;
        }
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
        if (idx < 0 || idx >= clearLen) continue;
        if (bfsVisited[idx]) continue;
        bfsVisited[idx] = true;

        if (game.isUnclaimed(ny, nx)) {
          foundDepth = currentDepth;

          float candScore = scoreBfsCandidate(game, nx, ny, cols, rows, progress);

          if (candScore > bestCandidateScore) {
            bestCandidateScore = candScore;
            bestCandidateDir = fd;
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

    if (bestCandidateDir >= 0) {
      return DIRS[bestCandidateDir];
    }

    return null;
  }

  // ────────────────────────────────────────────────────────────
  //  SCORE A BFS CANDIDATE
  // ────────────────────────────────────────────────────────────
  float scoreBfsCandidate(GameInfo game, int cx, int cy, int cols, int rows, float progress) {
    float score = 0;

    // Local density
    int radius = 5;
    int localUnclaimed = game.countUnclaimedInRegion(
      max(0, cy - radius), max(0, cx - radius),
      min(rows - 1, cy + radius), min(cols - 1, cx + radius)
    );
    score += localUnclaimed * 3;

    // Wider density
    int bigRadius = 15;
    int wideUnclaimed = game.countUnclaimedInRegion(
      max(0, cy - bigRadius), max(0, cx - bigRadius),
      min(rows - 1, cy + bigRadius), min(cols - 1, cx + bigRadius)
    );
    score += wideUnclaimed;

    // Opponent avoidance
    if (progress < 0.7) {
      Bot nearest = game.getNearestBot(cx, cy, this.id);
      if (nearest != null) {
        float distToOpp = abs(nearest.x - cx) + abs(nearest.y - cy);
        score += min(distToOpp, 30) * 2;
      }
    }

    return score;
  }
}
