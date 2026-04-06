// ── ThiefBot — Territory Denial ──────────────────────────────
//
// The trick: instead of just racing to open territory, ThiefBot
// finds the leading opponent, locates the unclaimed pocket they're
// heading toward, and races to the FAR SIDE of it — stealing cells
// the leader was about to claim.
//
// Phases:
//   1. Early (< 0.25): Greedy 2-step lookahead (same as UltimateBot)
//   2. Mid (0.25-0.7): Intercept — target the far side of the
//      leader's nearest pocket and sweep toward them
//   3. Late (> 0.7): Pure BFS — zero overhead, match FrontierBot speed

class ThiefBot extends Bot {

  // ── Reusable BFS buffers ──────────────────────────────────
  final int MAX_BFS = 90000;
  int[] bfsQx   = new int[MAX_BFS];
  int[] bfsQy   = new int[MAX_BFS];
  int[] bfsQdir = new int[MAX_BFS];
  boolean[] bfsVisited = new boolean[MAX_BFS];

  // ── Intercept targeting ───────────────────────────────────
  int targetX = -1, targetY = -1;
  boolean hasTarget = false;
  int retargetCounter = 0;

  // ── Stuck detection ───────────────────────────────────────
  int prevX = -1, prevY = -1;
  int stuckCount = 0;

  ThiefBot(int startX, int startY, color col, String name) {
    super(startX, startY, col, name);
  }

  Direction getNextMove(GameInfo game) {
    int cols = game.cols;
    int rows = game.rows;
    float progress = game.getProgress();

    // Stuck detection
    if (this.x == prevX && this.y == prevY) {
      stuckCount++;
    } else {
      stuckCount = 0;
    }
    prevX = this.x;
    prevY = this.y;

    // Always claim adjacent cells first — never waste a free claim
    ArrayList<Direction> free = getFreeDirs();

    if (progress < 0.25) {
      // ── EARLY GAME: greedy expansion ──────────────────────
      if (free.size() > 0) return greedyMove(game, free, cols, rows);
      return pureBFS(game, cols, rows);
    }

    if (progress > 0.7) {
      // ── LATE GAME: pure speed ─────────────────────────────
      if (free.size() > 0) return free.get(0);  // instant, no scoring
      return pureBFS(game, cols, rows);
    }

    // ── MID GAME: intercept ─────────────────────────────────
    return interceptMove(game, free, cols, rows);
  }

  // ────────────────────────────────────────────────────────────
  //  GREEDY MOVE — 2-step lookahead with openness scoring
  // ────────────────────────────────────────────────────────────
  Direction greedyMove(GameInfo game, ArrayList<Direction> free, int cols, int rows) {
    Direction bestDir = null;
    float bestScore = -999;

    for (Direction d : free) {
      int nx = this.x + d.dx;
      int ny = this.y + d.dy;
      float score = 0;

      // Openness: unclaimed neighbors + 2-step
      for (int j = 0; j < DIRS.length; j++) {
        int nnx = nx + DIRS[j].dx;
        int nny = ny + DIRS[j].dy;
        if (game.isUnclaimed(nny, nnx)) {
          score += 10;
          for (int k = 0; k < DIRS.length; k++) {
            if (game.isUnclaimed(nny + DIRS[k].dy, nnx + DIRS[k].dx)) {
              score += 2;
            }
          }
        }
      }

      // Opponent avoidance
      Bot nearest = game.getNearestBot(this.x, this.y, this.id);
      if (nearest != null) {
        float curDist = abs(nearest.x - this.x) + abs(nearest.y - this.y);
        if (curDist < 15) {
          float newDist = abs(nearest.x - nx) + abs(nearest.y - ny);
          score += (newDist - curDist) * 6;
        }
      }

      if (stuckCount > 3) score += random(5);

      if (score > bestScore) {
        bestScore = score;
        bestDir = d;
      }
    }

    return bestDir != null ? bestDir : free.get(0);
  }

  // ────────────────────────────────────────────────────────────
  //  INTERCEPT MOVE — the core trick
  //  Find the leader, locate their nearest pocket, race to the
  //  far side of it, and sweep toward them.
  // ────────────────────────────────────────────────────────────
  Direction interceptMove(GameInfo game, ArrayList<Direction> free, int cols, int rows) {

    // Retarget every 80 steps or if we reached our target
    retargetCounter++;
    int distToTarget = hasTarget ? (abs(targetX - this.x) + abs(targetY - this.y)) : 999;
    if (!hasTarget || retargetCounter > 80 || distToTarget < 3) {
      pickInterceptTarget(game, cols, rows);
      retargetCounter = 0;
    }

    // If we have free adjacent cells, pick the one biased toward target
    if (free.size() > 0) {
      return biasedGreedy(game, free, cols, rows);
    }

    // No free cells — BFS toward target, not just nearest unclaimed
    if (hasTarget) {
      return bfsTowardTarget(game, cols, rows);
    }

    // Fallback: pure BFS
    return pureBFS(game, cols, rows);
  }

  // ────────────────────────────────────────────────────────────
  //  PICK INTERCEPT TARGET
  //  Find the leader, find the densest unclaimed region near them,
  //  set our target to the far side of that region.
  // ────────────────────────────────────────────────────────────
  void pickInterceptTarget(GameInfo game, int cols, int rows) {
    // Find leading opponent
    Bot leader = null;
    int bestScore = -1;
    for (Bot b : game.bots) {
      if (b.id == this.id) continue;
      if (b.score > bestScore) {
        bestScore = b.score;
        leader = b;
      }
    }

    if (leader == null) {
      hasTarget = false;
      return;
    }

    // If we ARE the leader, just do regular BFS — no one to intercept
    if (this.score >= bestScore) {
      hasTarget = false;
      return;
    }

    // Scan 4 regions around the leader to find densest unclaimed area
    int scanR = 30;
    int lx = leader.x;
    int ly = leader.y;

    // Check 4 directions from the leader
    int bestDensity = 0;
    int bestCx = lx, bestCy = ly;

    // Right of leader
    int d = game.countUnclaimedInRegion(
      max(0, ly - scanR), min(cols - 1, lx), min(rows - 1, ly + scanR), min(cols - 1, lx + scanR * 2));
    if (d > bestDensity) { bestDensity = d; bestCx = min(cols - 1, lx + scanR); bestCy = ly; }

    // Left of leader
    d = game.countUnclaimedInRegion(
      max(0, ly - scanR), max(0, lx - scanR * 2), min(rows - 1, ly + scanR), max(0, lx));
    if (d > bestDensity) { bestDensity = d; bestCx = max(0, lx - scanR); bestCy = ly; }

    // Below leader
    d = game.countUnclaimedInRegion(
      min(rows - 1, ly), max(0, lx - scanR), min(rows - 1, ly + scanR * 2), min(cols - 1, lx + scanR));
    if (d > bestDensity) { bestDensity = d; bestCx = lx; bestCy = min(rows - 1, ly + scanR); }

    // Above leader
    d = game.countUnclaimedInRegion(
      max(0, ly - scanR * 2), max(0, lx - scanR), max(0, ly), min(cols - 1, lx + scanR));
    if (d > bestDensity) { bestDensity = d; bestCx = lx; bestCy = max(0, ly - scanR); }

    if (bestDensity < 20) {
      // Not enough unclaimed territory near leader — no point intercepting
      hasTarget = false;
      return;
    }

    // Target = far side of the pocket (opposite from leader)
    int dx = bestCx - lx;
    int dy = bestCy - ly;
    targetX = constrain(bestCx + dx / 2, 2, cols - 3);
    targetY = constrain(bestCy + dy / 2, 2, rows - 3);
    hasTarget = true;
  }

  // ────────────────────────────────────────────────────────────
  //  BIASED GREEDY — claim adjacent cells, biased toward target
  // ────────────────────────────────────────────────────────────
  Direction biasedGreedy(GameInfo game, ArrayList<Direction> free, int cols, int rows) {
    Direction bestDir = null;
    float bestScore = -999;

    for (Direction d : free) {
      int nx = this.x + d.dx;
      int ny = this.y + d.dy;
      float score = 0;

      // Openness
      for (int j = 0; j < DIRS.length; j++) {
        if (game.isUnclaimed(ny + DIRS[j].dy, nx + DIRS[j].dx)) {
          score += 8;
        }
      }

      // Bias toward intercept target
      if (hasTarget) {
        float curDistToTarget = abs(targetX - this.x) + abs(targetY - this.y);
        float newDistToTarget = abs(targetX - nx) + abs(targetY - ny);
        score += (curDistToTarget - newDistToTarget) * 4;
      }

      // Opponent avoidance
      Bot nearest = game.getNearestBot(this.x, this.y, this.id);
      if (nearest != null) {
        float curDist = abs(nearest.x - this.x) + abs(nearest.y - this.y);
        if (curDist < 10) {
          float newDist = abs(nearest.x - nx) + abs(nearest.y - ny);
          score += (newDist - curDist) * 5;
        }
      }

      if (stuckCount > 3) score += random(5);

      if (score > bestScore) {
        bestScore = score;
        bestDir = d;
      }
    }

    return bestDir != null ? bestDir : free.get(0);
  }

  // ────────────────────────────────────────────────────────────
  //  BFS TOWARD TARGET — navigate through claimed territory
  //  toward our intercept point, but grab any unclaimed cell
  //  we encounter along the way.
  // ────────────────────────────────────────────────────────────
  Direction bfsTowardTarget(GameInfo game, int cols, int rows) {
    int total = cols * rows;
    int clearLen = min(total, MAX_BFS);
    java.util.Arrays.fill(bfsVisited, 0, clearLen, false);

    int head = 0, tail = 0;
    bfsVisited[this.y * cols + this.x] = true;

    // Seed
    for (int i = 0; i < DIRS.length; i++) {
      int nx = this.x + DIRS[i].dx;
      int ny = this.y + DIRS[i].dy;
      if (!game.inBounds(ny, nx)) continue;
      int idx = ny * cols + nx;
      if (idx < 0 || idx >= clearLen || bfsVisited[idx]) continue;
      bfsVisited[idx] = true;

      // Grab any unclaimed cell we find immediately
      if (game.isUnclaimed(ny, nx)) return DIRS[i];

      if (tail < MAX_BFS) {
        bfsQx[tail] = nx;
        bfsQy[tail] = ny;
        bfsQdir[tail] = i;
        tail++;
      }
    }

    // BFS — find unclaimed cells, prefer ones closer to target
    int foundDepth = -1;
    float bestScore = -999;
    int bestDir = -1;
    int waveEnd = tail;
    int currentDepth = 1;

    while (head < tail && head < MAX_BFS - 4) {
      if (head >= waveEnd) {
        currentDepth++;
        waveEnd = tail;
        if (foundDepth >= 0 && currentDepth > foundDepth + 3) break;
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
          foundDepth = currentDepth;
          // Score: prefer cells closer to our intercept target
          float distToTarget = abs(targetX - nx) + abs(targetY - ny);
          float score = -currentDepth * 2 - distToTarget;
          if (score > bestScore) {
            bestScore = score;
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

  // ────────────────────────────────────────────────────────────
  //  PURE BFS — zero overhead, maximum speed for endgame
  //  Identical to FrontierBot: find nearest unclaimed, go.
  // ────────────────────────────────────────────────────────────
  Direction pureBFS(GameInfo game, int cols, int rows) {
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
      if (tail < MAX_BFS) {
        bfsQx[tail] = nx;
        bfsQy[tail] = ny;
        bfsQdir[tail] = i;
        tail++;
      }
    }

    while (head < tail) {
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
        if (game.isUnclaimed(ny, nx)) return DIRS[fd];
        if (tail < MAX_BFS) {
          bfsQx[tail] = nx;
          bfsQy[tail] = ny;
          bfsQdir[tail] = fd;
          tail++;
        }
      }
    }

    return randomDir();
  }
}
