// ── WallBot — "Claim the perimeter, then close in" ──────────
//
// Most bots spawn mid-grid and fight over the center.
// WallBot races to the nearest edge and traces the perimeter,
// claiming the entire border while everyone else competes for
// the interior. Then spirals inward, eating territory from the
// outside in — like a contracting noose.

class WallBot extends Bot {

  // Phase: 0 = race to edge, 1 = trace perimeter, 2 = spiral inward
  int phase = 0;
  int wallDir = 0;        // 0=right, 1=down, 2=left, 3=up (CW around edge)
  int inwardOffset = 0;   // how many layers deep we've gone
  int stepsOnWall = 0;

  // BFS buffers for fallback
  final int MAX_BFS = 90000;
  int[] bfsQx = new int[MAX_BFS];
  int[] bfsQy = new int[MAX_BFS];
  int[] bfsQdir = new int[MAX_BFS];
  boolean[] bfsVisited = new boolean[MAX_BFS];

  WallBot(int startX, int startY, color col, String name) {
    super(startX, startY, col, name);
  }

  Direction getNextMove(GameInfo game) {
    int cols = game.cols;
    int rows = game.rows;

    if (phase == 0) {
      return raceToEdge(game, cols, rows);
    }

    // Always claim free neighbors first
    ArrayList<Direction> free = getFreeDirs();
    if (free.size() == 0) {
      return fallbackBFS(game, cols, rows);
    }

    if (phase == 1) {
      return tracePerimeter(game, free, cols, rows);
    }

    // Phase 2: spiral inward
    return spiralInward(game, free, cols, rows);
  }

  Direction raceToEdge(GameInfo game, int cols, int rows) {
    // Find nearest edge
    int distLeft = this.x;
    int distRight = cols - 1 - this.x;
    int distTop = this.y;
    int distBottom = rows - 1 - this.y;
    int minDist = min(min(distLeft, distRight), min(distTop, distBottom));

    if (minDist <= 0) {
      // We're at an edge — start tracing
      phase = 1;
      // Set initial wall direction based on which edge we hit
      if (this.y == 0) wallDir = 0;           // top edge, go right
      else if (this.x == cols - 1) wallDir = 1; // right edge, go down
      else if (this.y == rows - 1) wallDir = 2; // bottom edge, go left
      else wallDir = 3;                         // left edge, go up
      return getNextMove(game);
    }

    // Race toward nearest edge
    if (minDist == distLeft) return LEFT;
    if (minDist == distRight) return RIGHT;
    if (minDist == distTop) return UP;
    return DOWN;
  }

  Direction tracePerimeter(GameInfo game, ArrayList<Direction> free, int cols, int rows) {
    int margin = inwardOffset;
    Direction[] cwDirs = { RIGHT, DOWN, LEFT, UP };
    Direction forward = cwDirs[wallDir];

    // Try to continue along the wall
    if (canClaim(forward)) {
      stepsOnWall++;
      return forward;
    }

    // Hit a corner or claimed cell — turn clockwise
    wallDir = (wallDir + 1) % 4;
    forward = cwDirs[wallDir];
    if (canClaim(forward)) {
      stepsOnWall++;
      return forward;
    }

    // Wall is fully traced at this depth — go inward
    phase = 2;
    inwardOffset++;
    wallDir = 0;
    stepsOnWall = 0;
    return spiralInward(game, free, cols, rows);
  }

  Direction spiralInward(GameInfo game, ArrayList<Direction> free, int cols, int rows) {
    int margin = inwardOffset;
    Direction[] cwDirs = { RIGHT, DOWN, LEFT, UP };
    Direction forward = cwDirs[wallDir];

    // Try forward along current spiral layer
    if (canClaim(forward)) {
      stepsOnWall++;
      return forward;
    }

    // Try turning clockwise
    for (int turn = 1; turn <= 3; turn++) {
      int newDir = (wallDir + turn) % 4;
      if (canClaim(cwDirs[newDir])) {
        wallDir = newDir;
        stepsOnWall = 0;
        return cwDirs[newDir];
      }
    }

    // All directions claimed — pick any free direction
    return free.get(0);
  }

  Direction fallbackBFS(GameInfo game, int cols, int rows) {
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
      if (tail < MAX_BFS) { bfsQx[tail] = nx; bfsQy[tail] = ny; bfsQdir[tail] = i; tail++; }
    }
    while (head < tail) {
      int cx = bfsQx[head]; int cy = bfsQy[head]; int fd = bfsQdir[head]; head++;
      for (int i = 0; i < DIRS.length; i++) {
        int nx = cx + DIRS[i].dx; int ny = cy + DIRS[i].dy;
        if (!game.inBounds(ny, nx)) continue;
        int idx = ny * cols + nx;
        if (idx < 0 || idx >= clearLen || bfsVisited[idx]) continue;
        bfsVisited[idx] = true;
        if (game.isUnclaimed(ny, nx)) return DIRS[fd];
        if (tail < MAX_BFS) { bfsQx[tail] = nx; bfsQy[tail] = ny; bfsQdir[tail] = fd; tail++; }
      }
    }
    return randomDir();
  }
}
