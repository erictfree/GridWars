class BasePainter {

  int x, y, id, score;
  color col;
  String name;

  // ── Appearance customization ──────────────────────────────
  // Set these in your constructor to personalize your bot.
  float glowSize   = 1.0;    // glow radius multiplier (try 0.5 – 2.0)
  String label     = "";      // drawn on your bot (letter, symbol, etc.)
  int trailLength  = 15;      // trail length in steps (0 = no trail)

  // Trail state (internal)
  final int _MAX_TRAIL = 40;
  int[] trailX = new int[_MAX_TRAIL];
  int[] trailY = new int[_MAX_TRAIL];
  int _trailIdx = 0;
  boolean _trailFull = false;

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
  //  grid : 2D int array — grid[row][col]
  //                         -1 = unclaimed, N = owned by painter N
  //  cols : number of columns
  //  rows : number of rows
  //
  //  Must return one of:  UP | DOWN | LEFT | RIGHT
  // ─────────────────────────────────────────────────────────────
  Direction getNextMove(int[][] grid, int cols, int rows) {
    return randomDir();
  }

  // Engine methods — do not override ─────────────────────────

  void update(int[][] grid, int cols, int rows) {
    // Record trail
    int tl = constrain(trailLength, 1, _MAX_TRAIL);
    trailX[_trailIdx] = x;
    trailY[_trailIdx] = y;
    _trailIdx = (_trailIdx + 1) % tl;
    if (!_trailFull && _trailIdx == 0) _trailFull = true;

    Direction d = getNextMove(grid, cols, rows);
    x = constrain(x + d.dx, 0, cols - 1);
    y = constrain(y + d.dy, 0, rows - 1);
    if (grid[y][x] == -1) {
      grid[y][x] = id;
      score++;
      unclaimed--;
      claimFrame[y][x] = frameCount;
      spawnClaimParticles(x, y, col);
    }
  }

  void show() {
    noStroke();
    float gs = glowSize;

    // ── Trail (comet tail) ──────────────────────────────────
    if (trailLength > 0) {
      int tl = constrain(trailLength, 1, _MAX_TRAIL);
      int count = _trailFull ? tl : _trailIdx;
      for (int i = 0; i < count; i++) {
        int idx = _trailFull ? (_trailIdx + i) % tl : i;
        float t = (float)(i + 1) / (count + 1);
        fill(col, t * 55);
        float sz = CELL * 1.2 * t * gs;
        ellipse(trailX[idx] * CELL + CELL / 2.0,
                trailY[idx] * CELL + CELL / 2.0, sz, sz);
      }
    }

    // ── Main glow (with pulse) ──────────────────────────────
    float cx = x * CELL + CELL / 2.0;
    float cy = y * CELL + CELL / 2.0;
    float pulse = 1.0 + 0.12 * sin(frameCount * 0.12 + id * 1.8);

    // Outer halo
    fill(col, 30);
    ellipse(cx, cy, CELL * 4.0 * gs * pulse, CELL * 4.0 * gs * pulse);

    // Outer glow
    fill(col, 50);
    ellipse(cx, cy, CELL * 3.2 * gs * pulse, CELL * 3.2 * gs * pulse);

    // Mid glow
    fill(col, 110);
    ellipse(cx, cy, CELL * 2.2 * gs * pulse, CELL * 2.2 * gs * pulse);

    // Ring
    stroke(col, 70);
    strokeWeight(1);
    noFill();
    ellipse(cx, cy, CELL * 2.6 * gs * pulse, CELL * 2.6 * gs * pulse);
    noStroke();

    // Core
    fill(col);
    ellipse(cx, cy, CELL * 1.5, CELL * 1.5);

    // Specular highlight
    fill(255, 220);
    ellipse(cx - 1, cy - 1, CELL * 0.45, CELL * 0.45);

    // ── Label (custom text on bot) ──────────────────────────
    if (label.length() > 0) {
      fill(255, 240);
      textSize(CELL * 1.0);
      textAlign(PConstants.CENTER, PConstants.CENTER);
      text(label, cx, cy - 1);
    }

    // ── Name tag above bot ──────────────────────────────────
    fill(255, 100);
    textSize(max(8, CELL * 0.85));
    textAlign(PConstants.CENTER, PConstants.BOTTOM);
    text(name, cx, cy - CELL * 2.0 * gs);
  }
}
