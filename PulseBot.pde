// ── PulseBot — "Expand, then backfill" ───────────────────────
//
// Most bots push outward aggressively but leave gaps — unclaimed
// cells in their wake from zigzags and turns. PulseBot alternates:
// 10 steps of aggressive outward expansion, then reverses and
// fills in any gaps it left behind. It remembers where it's been
// and tracks which nearby cells it skipped.

class PulseBot extends Bot {

  // Track positions we've visited to find gaps nearby
  final int MEMORY_SIZE = 200;
  int[] memX = new int[MEMORY_SIZE];
  int[] memY = new int[MEMORY_SIZE];
  int memIdx = 0;
  boolean memFull = false;

  int pulseCounter = 0;
  boolean expanding = true;  // true = push out, false = backfill

  // BFS fallback
  final int MAX_BFS = 90000;
  int[] bfsQx = new int[MAX_BFS];
  int[] bfsQy = new int[MAX_BFS];
  int[] bfsQdir = new int[MAX_BFS];
  boolean[] bfsVisited = new boolean[MAX_BFS];

  PulseBot(int startX, int startY, color col, String name) {
    super(startX, startY, col, name);
  }

  Direction getNextMove(GameInfo game) {
    int cols = game.cols;
    int rows = game.rows;

    // Remember where we've been
    memX[memIdx] = this.x;
    memY[memIdx] = this.y;
    memIdx = (memIdx + 1) % MEMORY_SIZE;
    if (!memFull && memIdx == 0) memFull = true;

    pulseCounter++;

    // Switch modes every 15 steps
    if (pulseCounter >= 15) {
      pulseCounter = 0;
      expanding = !expanding;
    }

    ArrayList<Direction> free = getFreeDirs();

    if (free.size() == 0) {
      return pureBFS(game, cols, rows);
    }

    if (expanding) {
      return expandMove(game, free, cols, rows);
    } else {
      return backfillMove(game, free, cols, rows);
    }
  }

  // EXPAND: push into the direction with the most open territory ahead
  Direction expandMove(GameInfo game, ArrayList<Direction> free, int cols, int rows) {
    Direction bestDir = null;
    float bestScore = -999;

    for (Direction d : free) {
      int nx = this.x + d.dx;
      int ny = this.y + d.dy;
      float score = 0;

      // Count unclaimed in a cone ahead (10-cell depth)
      int coneR = 10;
      int r1 = max(0, ny - coneR);
      int c1 = max(0, nx - coneR);
      int r2 = min(rows - 1, ny + coneR);
      int c2 = min(cols - 1, nx + coneR);
      // Narrow cone to forward direction
      if (d.dx > 0) c1 = nx;
      if (d.dx < 0) c2 = nx;
      if (d.dy > 0) r1 = ny;
      if (d.dy < 0) r2 = ny;
      score += game.countUnclaimedInRegion(r1, c1, r2, c2);

      // Immediate openness
      for (Direction nd : DIRS) {
        if (game.isUnclaimed(ny + nd.dy, nx + nd.dx)) score += 5;
      }

      // Avoid going back to where we've been
      int revisitPenalty = 0;
      int count = memFull ? MEMORY_SIZE : memIdx;
      for (int i = 0; i < count; i++) {
        if (abs(memX[i] - nx) + abs(memY[i] - ny) <= 2) revisitPenalty++;
      }
      score -= revisitPenalty * 3;

      if (score > bestScore) { bestScore = score; bestDir = d; }
    }

    return bestDir != null ? bestDir : free.get(0);
  }

  // BACKFILL: move toward unclaimed cells near where we've been
  Direction backfillMove(GameInfo game, ArrayList<Direction> free, int cols, int rows) {
    // Find the nearest unclaimed cell that's close to our past path
    Direction bestDir = null;
    float bestScore = -999;

    for (Direction d : free) {
      int nx = this.x + d.dx;
      int ny = this.y + d.dy;
      float score = 0;

      // Bonus: how close is this cell to our memory trail?
      // (We want to fill gaps in our previous path)
      int nearMemory = 0;
      int count = memFull ? MEMORY_SIZE : memIdx;
      for (int i = 0; i < count; i++) {
        if (abs(memX[i] - nx) + abs(memY[i] - ny) <= 3) nearMemory++;
      }
      score += nearMemory * 2;

      // Still prefer cells with some openness
      for (Direction nd : DIRS) {
        if (game.isUnclaimed(ny + nd.dy, nx + nd.dx)) score += 3;
      }

      if (score > bestScore) { bestScore = score; bestDir = d; }
    }

    return bestDir != null ? bestDir : free.get(0);
  }

  Direction pureBFS(GameInfo game, int cols, int rows) {
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
    while (head<tail) {
      int cx=bfsQx[head]; int cy=bfsQy[head]; int fd=bfsQdir[head]; head++;
      for (int i=0;i<DIRS.length;i++) {
        int nx=cx+DIRS[i].dx; int ny=cy+DIRS[i].dy;
        if (!game.inBounds(ny,nx)) continue;
        int idx=ny*cols+nx;
        if (idx<0||idx>=clearLen||bfsVisited[idx]) continue;
        bfsVisited[idx]=true;
        if (game.isUnclaimed(ny,nx)) return DIRS[fd];
        if (tail<MAX_BFS) { bfsQx[tail]=nx; bfsQy[tail]=ny; bfsQdir[tail]=fd; tail++; }
      }
    }
    return randomDir();
  }
}
