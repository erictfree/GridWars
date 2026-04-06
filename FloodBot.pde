// ── FloodBot — "Stay in the blob" ────────────────────────────
//
// Key insight: the most efficient claiming happens when you're
// inside a large contiguous region of unclaimed cells and never
// leave it. Every time you cross claimed territory, you waste
// steps. FloodBot treats unclaimed regions as "blobs" and always
// moves to stay inside the largest connected blob. When forced
// to cross claimed territory, it targets the biggest blob on
// the entire grid — not the nearest cell.
//
// Think of it like water flowing — always expanding into the
// largest connected pool.

class FloodBot extends Bot {

  final int MAX_BFS = 90000;
  int[] bfsQx = new int[MAX_BFS];
  int[] bfsQy = new int[MAX_BFS];
  int[] bfsQdir = new int[MAX_BFS];
  boolean[] bfsVisited = new boolean[MAX_BFS];

  FloodBot(int startX, int startY, color col, String name) {
    super(startX, startY, col, name);
  }

  Direction getNextMove(GameInfo game) {
    int cols = game.cols;
    int rows = game.rows;

    ArrayList<Direction> free = getFreeDirs();

    if (free.size() > 0) {
      // We're adjacent to unclaimed cells — stay in the blob
      return blobMove(game, free, cols, rows);
    }

    // We're surrounded by claimed cells — find the biggest blob
    return seekBiggestBlob(game, cols, rows);
  }

  // Pick the direction that keeps us inside the largest connected
  // unclaimed region. For each free neighbor, count how many
  // unclaimed cells are reachable from it (bounded flood fill).
  Direction blobMove(GameInfo game, ArrayList<Direction> free, int cols, int rows) {
    Direction bestDir = null;
    int bestBlob = -1;

    for (Direction d : free) {
      int nx = this.x + d.dx;
      int ny = this.y + d.dy;

      // Quick blob size estimate: count unclaimed in 8-cell radius
      int r = 8;
      int blobSize = game.countUnclaimedInRegion(
        max(0, ny - r), max(0, nx - r),
        min(rows - 1, ny + r), min(cols - 1, nx + r)
      );

      if (blobSize > bestBlob) {
        bestBlob = blobSize;
        bestDir = d;
      }
    }

    return bestDir != null ? bestDir : free.get(0);
  }

  // BFS to find unclaimed cells, but instead of taking the nearest,
  // take the one that's part of the biggest pocket.
  Direction seekBiggestBlob(GameInfo game, int cols, int rows) {
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

    // BFS — collect candidates, score by surrounding blob size
    int foundDepth = -1;
    float bestScore = -999;
    int bestDir = -1;
    int waveEnd = tail, depth = 1;

    while (head < tail && head < MAX_BFS - 4) {
      if (head >= waveEnd) {
        depth++;
        waveEnd = tail;
        // Search a few levels past first found to compare blobs
        if (foundDepth >= 0 && depth > foundDepth + 4) break;
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

          // Score: blob size / distance
          int r = 12;
          int blobSize = game.countUnclaimedInRegion(
            max(0, ny - r), max(0, nx - r),
            min(rows - 1, ny + r), min(cols - 1, nx + r)
          );
          float score = (float) blobSize / max(1, depth);

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
