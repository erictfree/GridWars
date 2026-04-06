// ── ZoneBot — "Claim a zone, own it completely" ─────────────
//
// In a 100-bot game, fighting over the whole grid is a losing
// strategy. ZoneBot picks the least-contested region of the
// grid (divides into 9 sectors, picks emptiest + fewest bots),
// races there, and systematically sweeps ONLY that zone.
// A bot that owns 100% of 1/9th of the grid beats a bot that
// owns 5% of the whole grid.

class ZoneBot extends Bot {

  // Target zone center
  int zoneX = -1, zoneY = -1;
  boolean zoneChosen = false;
  int sweepDx = 1, sweepDy = 0;

  // BFS fallback
  final int MAX_BFS = 90000;
  int[] bfsQx = new int[MAX_BFS];
  int[] bfsQy = new int[MAX_BFS];
  int[] bfsQdir = new int[MAX_BFS];
  boolean[] bfsVisited = new boolean[MAX_BFS];

  ZoneBot(int startX, int startY, color col, String name) {
    super(startX, startY, col, name);
  }

  Direction getNextMove(GameInfo game) {
    int cols = game.cols;
    int rows = game.rows;

    // Pick a zone once at start
    if (!zoneChosen) {
      pickZone(game, cols, rows);
      zoneChosen = true;
    }

    ArrayList<Direction> free = getFreeDirs();

    if (free.size() > 0) {
      // Pick direction biased toward our zone AND with most openness
      return zoneSweep(game, free, cols, rows);
    }

    // BFS to nearest unclaimed, biased toward our zone
    return zoneBFS(game, cols, rows);
  }

  void pickZone(GameInfo game, int cols, int rows) {
    // Divide grid into 3x3 sectors, find the one with most
    // unclaimed cells and fewest opponents
    int bestScore = -999;
    int sectorW = cols / 3;
    int sectorH = rows / 3;

    for (int sr = 0; sr < 3; sr++) {
      for (int sc = 0; sc < 3; sc++) {
        int r1 = sr * sectorH;
        int c1 = sc * sectorW;
        int r2 = min(rows - 1, r1 + sectorH - 1);
        int c2 = min(cols - 1, c1 + sectorW - 1);

        int unclaimed = game.countUnclaimedInRegion(r1, c1, r2, c2);

        // Count bots in this sector
        int botCount = 0;
        int centerX = (c1 + c2) / 2;
        int centerY = (r1 + r2) / 2;
        for (Bot b : game.bots) {
          if (b.id == this.id) continue;
          if (b.x >= c1 && b.x <= c2 && b.y >= r1 && b.y <= r2) {
            botCount++;
          }
        }

        // Score: lots of unclaimed, few opponents, closer is better
        int dist = abs(centerX - this.x) + abs(centerY - this.y);
        int score = unclaimed * 3 - botCount * 500 - dist * 2;

        if (score > bestScore) {
          bestScore = score;
          zoneX = centerX;
          zoneY = centerY;
        }
      }
    }
  }

  Direction zoneSweep(GameInfo game, ArrayList<Direction> free, int cols, int rows) {
    Direction bestDir = null;
    float bestScore = -999;

    for (Direction d : free) {
      int nx = this.x + d.dx;
      int ny = this.y + d.dy;
      float score = 0;

      // Openness
      for (Direction nd : DIRS) {
        if (game.isUnclaimed(ny + nd.dy, nx + nd.dx)) score += 6;
      }

      // Bias toward our zone
      float curDist = abs(zoneX - this.x) + abs(zoneY - this.y);
      float newDist = abs(zoneX - nx) + abs(zoneY - ny);
      score += (curDist - newDist) * 3;

      // Opponent avoidance
      Bot nearest = game.getNearestBot(this.x, this.y, this.id);
      if (nearest != null) {
        float oppDist = abs(nearest.x - this.x) + abs(nearest.y - this.y);
        if (oppDist < 10) {
          float newOppDist = abs(nearest.x - nx) + abs(nearest.y - ny);
          score += (newOppDist - oppDist) * 4;
        }
      }

      if (score > bestScore) { bestScore = score; bestDir = d; }
    }

    return bestDir != null ? bestDir : free.get(0);
  }

  Direction zoneBFS(GameInfo game, int cols, int rows) {
    int total = cols * rows;
    int clearLen = min(total, MAX_BFS);
    java.util.Arrays.fill(bfsVisited, 0, clearLen, false);
    int head = 0, tail = 0;
    bfsVisited[this.y * cols + this.x] = true;

    for (int i = 0; i < DIRS.length; i++) {
      int nx=this.x+DIRS[i].dx; int ny=this.y+DIRS[i].dy;
      if (!game.inBounds(ny,nx)) continue;
      int idx=ny*cols+nx;
      if (idx<0||idx>=clearLen||bfsVisited[idx]) continue;
      bfsVisited[idx]=true;
      if (game.isUnclaimed(ny,nx)) return DIRS[i];
      if (tail<MAX_BFS) { bfsQx[tail]=nx; bfsQy[tail]=ny; bfsQdir[tail]=i; tail++; }
    }

    // BFS with zone bias
    int foundDepth = -1;
    float bestScore = -999;
    int bestDir = -1;
    int waveEnd = tail, depth = 1;

    while (head < tail && head < MAX_BFS - 4) {
      if (head >= waveEnd) { depth++; waveEnd = tail; if (foundDepth >= 0 && depth > foundDepth + 2) break; }
      int cx=bfsQx[head]; int cy=bfsQy[head]; int fd=bfsQdir[head]; head++;
      for (int i = 0; i < DIRS.length; i++) {
        int nx=cx+DIRS[i].dx; int ny=cy+DIRS[i].dy;
        if (!game.inBounds(ny,nx)) continue;
        int idx=ny*cols+nx;
        if (idx<0||idx>=clearLen||bfsVisited[idx]) continue;
        bfsVisited[idx]=true;
        if (game.isUnclaimed(ny, nx)) {
          foundDepth = depth;
          float distToZone = abs(zoneX - nx) + abs(zoneY - ny);
          float score = -depth * 2 - distToZone;
          if (score > bestScore) { bestScore = score; bestDir = fd; }
          continue;
        }
        if (tail<MAX_BFS) { bfsQx[tail]=nx; bfsQy[tail]=ny; bfsQdir[tail]=fd; tail++; }
      }
    }
    if (bestDir >= 0) return DIRS[bestDir];
    return randomDir();
  }
}
