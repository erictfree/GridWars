// ── ScavengerBot — Endgame-focused variant ──────────────────
//
// Core idea: maximize claim efficiency (claims per move).
// Three phases:
//   1. SWEEP — when adjacent unclaimed cells exist, mow in straight
//      lines with serpentine turns. Never zigzag randomly.
//   2. NAVIGATE — when surrounded, BFS to the best pocket of
//      unclaimed cells (size/distance), not just the nearest cell.
//   3. ENDGAME — "Traveling Salesman Lite": chain pockets together,
//      avoid contested scraps, minimize wasted transit.

class ScavengerBot extends Bot {

  // ── Reusable BFS buffers ──────────────────────────────────
  final int MAX_BFS = 90000;
  int[] bfsQx   = new int[MAX_BFS];
  int[] bfsQy   = new int[MAX_BFS];
  int[] bfsQdir = new int[MAX_BFS];
  boolean[] bfsVisited = new boolean[MAX_BFS];

  // ── Sweep state ───────────────────────────────────────────
  int sweepDx = 1;
  int sweepDy = 0;
  int prevX = -1, prevY = -1;
  int stuckCount = 0;

  // ── Efficiency tracking ───────────────────────────────────
  int lastScore = 0;
  int stepsSinceCheck = 0;
  int claimsSinceCheck = 0;
  float efficiency = 1.0;  // rolling claims-per-step

  ScavengerBot(int startX, int startY, color col, String name) {
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

    // Efficiency tracking — update every 20 steps
    stepsSinceCheck++;
    int gained = this.score - lastScore;
    claimsSinceCheck += (gained > 0) ? gained : 0;
    lastScore = this.score;
    if (stepsSinceCheck >= 20) {
      efficiency = (float) claimsSinceCheck / stepsSinceCheck;
      stepsSinceCheck = 0;
      claimsSinceCheck = 0;
    }

    boolean endgame = progress > 0.6;

    // ── PHASE 1: SWEEP — claim adjacent cells ───────────────
    ArrayList<Direction> free = getFreeDirs();

    if (free.size() > 0) {
      if (endgame) {
        return pickEndgameSweep(game, free, cols, rows);
      }
      return pickSweepDir(game, free, cols, rows, progress);
    }

    // ── PHASE 2/3: NAVIGATE — BFS to best pocket ────────────
    return navigateToPocket(game, cols, rows, progress, endgame);
  }

  // ────────────────────────────────────────────────────────────
  //  SWEEP DIRECTION PICKER (early/mid game)
  //  Maintains momentum for straight-line sweeps. When blocked,
  //  does a serpentine turn (step perpendicular, reverse).
  // ────────────────────────────────────────────────────────────
  Direction pickSweepDir(GameInfo game, ArrayList<Direction> free, int cols, int rows, float progress) {

    // Try to continue current sweep direction
    Direction momentum = dirFromDelta(sweepDx, sweepDy);
    if (momentum != null && canClaim(momentum)) {
      return momentum;
    }

    // Serpentine turn
    if (sweepDx != 0) {
      Direction step = dirFromDelta(0, 1);
      if (step != null && canClaim(step)) {
        sweepDx = -sweepDx;
        return step;
      }
      step = dirFromDelta(0, -1);
      if (step != null && canClaim(step)) {
        sweepDx = -sweepDx;
        return step;
      }
    } else {
      Direction step = dirFromDelta(1, 0);
      if (step != null && canClaim(step)) {
        sweepDy = -sweepDy;
        return step;
      }
      step = dirFromDelta(-1, 0);
      if (step != null && canClaim(step)) {
        sweepDy = -sweepDy;
        return step;
      }
    }

    // Serpentine failed — pick best by runway + openness
    return pickByRunway(game, free, cols, rows, true);
  }

  // ────────────────────────────────────────────────────────────
  //  ENDGAME SWEEP (progress > 0.6)
  //  No momentum — always pick the direction leading toward
  //  the densest cluster of unclaimed cells nearby.
  // ────────────────────────────────────────────────────────────
  Direction pickEndgameSweep(GameInfo game, ArrayList<Direction> free, int cols, int rows) {
    Direction bestDir = null;
    float bestScore = -999;

    for (Direction d : free) {
      int nx = this.x + d.dx;
      int ny = this.y + d.dy;

      // Runway — consecutive unclaimed cells ahead
      int runway = 0;
      int cx = nx, cy = ny;
      while (runway < 15 && game.inBounds(cy, cx) && game.isUnclaimed(cy, cx)) {
        runway++;
        cx += d.dx;
        cy += d.dy;
      }

      // Regional density — unclaimed cells in a 20-cell forward cone
      int coneR = 10;
      int cr1 = max(0, ny - coneR);
      int cc1 = max(0, nx - coneR);
      int cr2 = min(rows - 1, ny + coneR);
      int cc2 = min(cols - 1, nx + coneR);
      // Shift cone forward in the direction of movement
      if (d.dx > 0) cc1 = nx;
      if (d.dx < 0) cc2 = nx;
      if (d.dy > 0) cr1 = ny;
      if (d.dy < 0) cr2 = ny;
      int density = game.countUnclaimedInRegion(cr1, cc1, cr2, cc2);

      float score = runway * 8 + density * 2;

      // Immediate openness
      int openness = 0;
      for (Direction nd : DIRS) {
        if (game.isUnclaimed(ny + nd.dy, nx + nd.dx)) openness++;
      }
      score += openness * 4;

      // Opponent: prefer uncontested cells
      Bot nearest = game.getNearestBot(nx, ny, this.id);
      if (nearest != null) {
        float oppDist = abs(nearest.x - nx) + abs(nearest.y - ny);
        float myDist = 1;  // we're adjacent
        if (oppDist < myDist + 2) {
          score -= 20;  // opponent will contest this
        }
      }

      if (stuckCount > 3) score += random(8);

      if (score > bestScore) {
        bestScore = score;
        bestDir = d;
      }
    }

    if (bestDir != null) {
      sweepDx = bestDir.dx;
      sweepDy = bestDir.dy;
    }
    return bestDir != null ? bestDir : free.get(0);
  }

  // ────────────────────────────────────────────────────────────
  //  RUNWAY SCORING (fallback for sweep)
  // ────────────────────────────────────────────────────────────
  Direction pickByRunway(GameInfo game, ArrayList<Direction> free, int cols, int rows, boolean avoidOpponents) {
    Direction bestDir = null;
    float bestScore = -999;

    for (Direction d : free) {
      int runway = 0;
      int cx = this.x + d.dx;
      int cy = this.y + d.dy;
      while (runway < 20 && game.inBounds(cy, cx) && game.isUnclaimed(cy, cx)) {
        runway++;
        cx += d.dx;
        cy += d.dy;
      }

      int nx = this.x + d.dx;
      int ny = this.y + d.dy;
      int openness = 0;
      for (Direction nd : DIRS) {
        if (game.isUnclaimed(ny + nd.dy, nx + nd.dx)) openness++;
      }

      float score = runway * 10 + openness * 3;

      if (avoidOpponents) {
        Bot nearest = game.getNearestBot(this.x, this.y, this.id);
        if (nearest != null) {
          float curDist = abs(nearest.x - this.x) + abs(nearest.y - this.y);
          if (curDist < 15) {
            float newDist = abs(nearest.x - nx) + abs(nearest.y - ny);
            score += (newDist - curDist) * 5;
          }
        }
      }

      if (stuckCount > 3) score += random(10);

      if (score > bestScore) {
        bestScore = score;
        bestDir = d;
      }
    }

    if (bestDir != null) {
      sweepDx = bestDir.dx;
      sweepDy = bestDir.dy;
    }
    return bestDir != null ? bestDir : free.get(0);
  }

  // ────────────────────────────────────────────────────────────
  //  NAVIGATE TO BEST POCKET
  //  BFS to find unclaimed cells. In endgame, expands search
  //  beyond first found depth to evaluate multiple candidates
  //  and pick the best chain of pockets.
  // ────────────────────────────────────────────────────────────
  Direction navigateToPocket(GameInfo game, int cols, int rows, float progress, boolean endgame) {
    int total = cols * rows;
    int clearLen = min(total, MAX_BFS);
    java.util.Arrays.fill(bfsVisited, 0, clearLen, false);

    int head = 0, tail = 0;
    int startIdx = this.y * cols + this.x;
    if (startIdx >= 0 && startIdx < clearLen) {
      bfsVisited[startIdx] = true;
    }

    // Seed with neighbors
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

    // BFS with wave tracking
    int waveEnd = tail;
    int currentDepth = 1;
    int foundDepth = -1;
    float bestScore = -999;
    int bestDir = -1;

    // In endgame, search deeper to find better candidates
    int extraDepth = endgame ? 8 : 0;

    while (head < tail && head < MAX_BFS - 4) {
      if (head >= waveEnd) {
        currentDepth++;
        waveEnd = tail;
        // Stop when we've searched enough past first found depth
        if (foundDepth >= 0 && currentDepth > foundDepth + extraDepth) break;
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
          if (foundDepth < 0) foundDepth = currentDepth;

          float score = scoreCandidate(game, nx, ny, cols, rows, currentDepth, endgame);

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

    if (bestDir >= 0) {
      Direction chosen = DIRS[bestDir];
      sweepDx = chosen.dx;
      sweepDy = chosen.dy;
      return chosen;
    }

    return randomDir();
  }

  // ────────────────────────────────────────────────────────────
  //  SCORE A BFS CANDIDATE
  //  Early/mid: pocket size / distance, with opponent avoidance.
  //  Endgame: chain scoring — value of this pocket PLUS what's
  //  reachable from it. Opponent race detection.
  // ────────────────────────────────────────────────────────────
  float scoreCandidate(GameInfo game, int cx, int cy, int cols, int rows, int dist, boolean endgame) {

    // Local pocket size (10-cell radius)
    int localR = 10;
    int pocket = game.countUnclaimedInRegion(
      max(0, cy - localR), max(0, cx - localR),
      min(rows - 1, cy + localR), min(cols - 1, cx + localR)
    );

    if (!endgame) {
      // Early/mid game: pocket size / distance, avoid opponents
      float score = (float) pocket / max(1, dist);
      Bot nearest = game.getNearestBot(cx, cy, this.id);
      if (nearest != null) {
        float oppDist = abs(nearest.x - cx) + abs(nearest.y - cy);
        if (oppDist < 10) score *= 0.3;
      }
      return score;
    }

    // ── ENDGAME SCORING ──────────────────────────────────────

    // Chain bonus — what's reachable beyond this pocket?
    // Check a wider region to see if there's more territory nearby
    int wideR = 20;
    int chainCells = game.countUnclaimedInRegion(
      max(0, cy - wideR), max(0, cx - wideR),
      min(rows - 1, cy + wideR), min(cols - 1, cx + wideR)
    );
    float chainBonus = (float) (chainCells - pocket) / 3.0;

    // Total value of visiting this pocket
    float value = pocket + chainBonus;

    // Opponent race detection — is someone closer to this pocket?
    Bot nearest = game.getNearestBot(cx, cy, this.id);
    if (nearest != null) {
      float oppDist = abs(nearest.x - cx) + abs(nearest.y - cy);
      if (oppDist < dist) {
        // Opponent will get there first — heavy penalty
        value *= 0.15;
      } else if (oppDist < dist + 3) {
        // Close race — moderate penalty
        value *= 0.5;
      }
    }

    // Score = value / distance (efficiency of the trip)
    float score = value / max(1, dist);

    // When efficiency is low, prefer bigger pockets over closer ones
    // (worth traveling further for guaranteed claims)
    if (efficiency < 0.3) {
      score = value / max(1, sqrt(dist));  // sqrt dampens distance penalty
    }

    return score;
  }

  // ────────────────────────────────────────────────────────────
  //  HELPER: convert dx/dy to a Direction constant
  // ────────────────────────────────────────────────────────────
  Direction dirFromDelta(int dx, int dy) {
    for (Direction d : DIRS) {
      if (d.dx == dx && d.dy == dy) return d;
    }
    return null;
  }
}
