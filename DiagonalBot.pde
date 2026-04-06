// ── DiagonalBot — "Zigzag covers 2D faster" ─────────────────
//
// Most bots sweep in straight horizontal or vertical lines.
// DiagonalBot alternates RIGHT/DOWN (or LEFT/UP) creating a
// staircase pattern. This covers 2D space more efficiently
// because each step makes progress in BOTH dimensions — like
// a bishop vs a rook. When the staircase hits a boundary,
// it shifts and reverses.

class DiagonalBot extends Bot {

  int phase = 0;  // 0 = down-right, 1 = down-left, 2 = up-left, 3 = up-right
  boolean stepX = true;  // alternate between X and Y steps

  // BFS fallback
  final int MAX_BFS = 90000;
  int[] bfsQx = new int[MAX_BFS];
  int[] bfsQy = new int[MAX_BFS];
  int[] bfsQdir = new int[MAX_BFS];
  boolean[] bfsVisited = new boolean[MAX_BFS];

  DiagonalBot(int startX, int startY, color col, String name) {
    super(startX, startY, col, name);
  }

  Direction getNextMove(GameInfo game) {
    ArrayList<Direction> free = getFreeDirs();

    if (free.size() == 0) {
      return pureBFS(game, game.cols, game.rows);
    }

    // Get the two directions for current diagonal phase
    Direction primary, secondary;
    switch (phase) {
      case 0: primary = stepX ? RIGHT : DOWN;  secondary = stepX ? DOWN : RIGHT; break;
      case 1: primary = stepX ? LEFT : DOWN;   secondary = stepX ? DOWN : LEFT; break;
      case 2: primary = stepX ? LEFT : UP;     secondary = stepX ? UP : LEFT; break;
      default: primary = stepX ? RIGHT : UP;   secondary = stepX ? UP : RIGHT; break;
    }

    // Try primary diagonal step
    if (canClaim(primary)) {
      stepX = !stepX;  // alternate
      return primary;
    }

    // Try secondary (the other half of diagonal)
    if (canClaim(secondary)) {
      stepX = !stepX;
      return secondary;
    }

    // Diagonal blocked — rotate phase 90 degrees
    phase = (phase + 1) % 4;
    stepX = true;

    // Try the new diagonal
    switch (phase) {
      case 0: primary = RIGHT; break;
      case 1: primary = LEFT; break;
      case 2: primary = LEFT; break;
      default: primary = RIGHT; break;
    }
    if (canClaim(primary)) return primary;

    // Just pick the free direction with most openness
    Direction bestDir = null;
    int bestOpen = -1;
    for (Direction d : free) {
      int nx = this.x + d.dx;
      int ny = this.y + d.dy;
      int openCount = 0;
      for (Direction nd : DIRS) {
        if (game.isUnclaimed(ny + nd.dy, nx + nd.dx)) openCount++;
      }
      if (openCount > bestOpen) { bestOpen = openCount; bestDir = d; }
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
