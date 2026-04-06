class BasePainter {

  int x, y, id, score;
  color col;
  String name;

  // ── Appearance customization ──────────────────────────────
  float glowSize   = 1.0;
  String label     = "";
  int trailLength  = 15;

  // Game reference (set each step by the engine)
  GameInfo gameRef;

  // Trail state
  final int MAX_TRAIL = 40;
  int[] trailX = new int[MAX_TRAIL];
  int[] trailY = new int[MAX_TRAIL];
  int trailIdx = 0;
  boolean trailFull = false;

  BasePainter(int startX, int startY, color col, String name) {
    this.x    = startX;
    this.y    = startY;
    this.col  = col;
    this.name = name;
    this.id   = -1;
    this.score = 0;
  }

  // ─────────────────────────────────────────────────────────────
  //  ★  OVERRIDE THIS METHOD  ★
  //
  //  Called once per simulation step.
  //  Use the game object to query the world:
  //    game.grid[row][col]       — raw grid (-1 = unclaimed, N = owner)
  //    game.isUnclaimed(row,col) — check if a cell is free
  //    game.isClaimed(row,col)   — check if a cell is taken
  //    game.isMine(row,col,id)   — check if you own a cell
  //    game.inBounds(row,col)    — bounds check
  //    game.getOwner(row,col)    — who owns it? (-1, -2 if OOB)
  //    game.cols, game.rows      — grid dimensions
  //    game.countUnclaimed()     — total free cells
  //    game.getNearestBot(x,y,id)— find closest opponent
  //    game.getProgress()        — 0.0 → 1.0 game progress
  //
  //  Use helper methods on yourself:
  //    this.canClaim(direction)   — is the cell in that direction free?
  //    this.peekCell(direction)   — who owns the cell in that direction?
  //    this.getFreeDirs()         — list of directions with free cells
  //
  //  Must return one of:  UP | DOWN | LEFT | RIGHT
  // ─────────────────────────────────────────────────────────────
  Direction getNextMove(GameInfo game) {
    return randomDir();
  }

  // ── Helper methods — use these in getNextMove() ───────────

  /** Can moving in direction d claim an unclaimed cell? */
  boolean canClaim(Direction d) {
    int nx = x + d.dx;
    int ny = y + d.dy;
    return gameRef != null && gameRef.isUnclaimed(ny, nx);
  }

  /** Is the cell in direction d within the grid? */
  boolean isInBounds(Direction d) {
    int nx = x + d.dx;
    int ny = y + d.dy;
    return gameRef != null && gameRef.inBounds(ny, nx);
  }

  /** Returns owner of the cell in direction d. -1 = unclaimed, -2 = out of bounds. */
  int peekCell(Direction d) {
    int nx = x + d.dx;
    int ny = y + d.dy;
    if (gameRef == null) return -2;
    return gameRef.getOwner(ny, nx);
  }

  /** Returns a list of directions that lead to unclaimed cells. */
  ArrayList<Direction> getFreeDirs() {
    ArrayList<Direction> free = new ArrayList<Direction>();
    for (Direction d : DIRS) {
      if (canClaim(d)) free.add(d);
    }
    return free;
  }

  // ── Engine methods — do not override ──────────────────────

  void update(GameInfo game) {
    gameRef = game;

    int tl = constrain(trailLength, 1, MAX_TRAIL);
    trailX[trailIdx] = x;
    trailY[trailIdx] = y;
    trailIdx = (trailIdx + 1) % tl;
    if (!trailFull && trailIdx == 0) trailFull = true;

    Direction d = getNextMove(game);
    x = constrain(x + d.dx, 0, game.cols - 1);
    y = constrain(y + d.dy, 0, game.rows - 1);
    if (game.grid[y][x] == -1) {
      game.grid[y][x] = id;
      score++;
      unclaimed--;
      claimFrame[y][x] = frameCount;
    }
  }

  void show() {
    noStroke();
    float gs = glowSize;
    float cx = x * CELL + CELL / 2.0;
    float cy = y * CELL + CELL / 2.0;

    // Trail — subtle fading dots
    if (trailLength > 0) {
      int tl = constrain(trailLength, 1, MAX_TRAIL);
      int count = trailFull ? tl : trailIdx;
      for (int i = 0; i < count; i++) {
        int idx = trailFull ? (trailIdx + i) % tl : i;
        float t = (float)(i + 1) / (count + 1);
        fill(red(col), green(col), blue(col), t * 100);
        float sz = max(1, CELL * 0.35 * t);
        rect(trailX[idx] * CELL + (CELL - sz) / 2,
             trailY[idx] * CELL + (CELL - sz) / 2, sz, sz);
      }
    }

    // Bot indicator — pixel-art style
    float blink = (frameCount + id * 7) % 30 < 25 ? 1 : 0.6;

    float outerSize = CELL * 1.8 * gs;
    fill(red(col) * min(blink * 1.3, 1), green(col) * min(blink * 1.3, 1), blue(col) * min(blink * 1.3, 1));
    rect(cx - outerSize / 2, cy - outerSize / 2, outerSize, outerSize);

    fill(red(col) * blink, green(col) * blink, blue(col) * blink);
    float coreSize = CELL * 1.3;
    rect(cx - coreSize / 2, cy - coreSize / 2, coreSize, coreSize);

    fill(255, 255 * blink);
    float hotSize = max(2, CELL * 0.35);
    rect(cx - hotSize / 2, cy - hotSize / 2, hotSize, hotSize);

    if (label.length() > 0) {
      fill(255);
      textSize(CELL * 0.9);
      textAlign(PConstants.CENTER, PConstants.CENTER);
      text(label, cx, cy - 1);
    }

    fill(col);
    textSize(max(8, CELL * 0.8));
    textAlign(PConstants.CENTER, PConstants.BOTTOM);
    text(name, cx, cy - CELL * 1.4 * gs);
  }
}
