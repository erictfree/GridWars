// ── Constants ────────────────────────────────────────────────
final int COLS  = 110;
final int ROWS  = 110;
final int CELL  = 8;
final int SIDE  = 182;
final int BOT   = 52;
final int STEPS = 5;
final int SPEED = 80;          // simulation speed % (1–100)
final int LIMIT = 8000;
final int FLASH_FRAMES = 15;   // cell claim flash duration

// ── Direction constants ─────────────────────────────────────
// Note: UP/DOWN/LEFT/RIGHT shadow Processing key-code constants.
// Use PConstants.LEFT / PConstants.RIGHT / PConstants.CENTER
// for text alignment in rendering code.
Direction UP, DOWN, LEFT, RIGHT;
Direction[] DIRS;

// ── Game state ──────────────────────────────────────────────
int[][] grid;
int[][] claimFrame;  // frameCount when each cell was claimed (0 = no anim)
ArrayList<BasePainter> painters;
int stepCount;
int unclaimed;
boolean gameOver;
boolean confettiSpawned;

// ── UI colors ───────────────────────────────────────────────
color unclaimedColor, sidebarBg, hudBg;

void setup() {
  size(982, 852);
  surface.setSize(COLS * CELL + SIDE, ROWS * CELL + BOT);
  smooth();

  // Init directions
  UP    = new Direction( 0, -1);
  DOWN  = new Direction( 0,  1);
  LEFT  = new Direction(-1,  0);
  RIGHT = new Direction( 1,  0);
  DIRS  = new Direction[]{ UP, DOWN, LEFT, RIGHT };

  // Init colors
  unclaimedColor = color(32, 32, 48);
  sidebarBg      = color(18, 20, 36);
  hudBg          = color(18, 20, 36);

  initEffects();
  initGame();
}

void initGame() {
  grid = new int[ROWS][COLS];
  claimFrame = new int[ROWS][COLS];
  for (int r = 0; r < ROWS; r++) {
    java.util.Arrays.fill(grid[r], -1);
  }

  painters = new ArrayList<BasePainter>();

  int margin = 4;
  int farX   = COLS - margin - 1;
  int farY   = ROWS - margin - 1;
  int midX   = COLS / 2;
  int midY   = ROWS / 2;

  addPainter(new RandomBot  (margin, margin, color(220, 55,  55), "RandomBot"));
  addPainter(new GreedyBot  (farX,   margin, color( 55,120, 220), "GreedyBot"));
  addPainter(new SpiralBot  (margin, farY,   color( 55,195,  90), "SpiralBot"));
  addPainter(new FrontierBot(farX,   farY,   color(220,150,  40), "FrontierBot"));
  addPainter(new HunterBot  (midX,   midY,   color(185, 60, 205), "HunterBot"));

  stepCount  = 0;
  unclaimed  = COLS * ROWS - painters.size();
  gameOver   = false;
  confettiSpawned = false;
  initEffects();
}

void addPainter(BasePainter p) {
  p.id = painters.size();
  painters.add(p);
  grid[p.y][p.x] = p.id;
  p.score = 1;
}

// ── Main loop ───────────────────────────────────────────────

void draw() {
  // Simulation
  if (!gameOver) {
    int stepsThisFrame = max(1, round(STEPS * SPEED / 100.0));
    for (int s = 0; s < stepsThisFrame; s++) {
      for (BasePainter p : painters) {
        p.update(grid, COLS, ROWS);
      }
      stepCount++;
      if (stepCount >= LIMIT || unclaimed <= 0) {
        gameOver = true;
        break;
      }
    }
  }

  // Confetti on game over (once)
  if (gameOver && !confettiSpawned) {
    confettiSpawned = true;
    BasePainter winner = painters.get(0);
    for (BasePainter p : painters) {
      if (p.score > winner.score) winner = p;
    }
    spawnConfetti(winner.col);
  }

  // Effects
  updateEffects();

  // Render
  background(0);
  drawGrid();
  drawEffects();
  for (BasePainter p : painters) {
    p.show();
  }
  drawSidebar();
  drawHUD();
  if (gameOver) {
    drawGameOver();
  }
}

// ── Grid rendering ──────────────────────────────────────────

void drawGrid() {
  noStroke();
  for (int r = 0; r < ROWS; r++) {
    for (int c = 0; c < COLS; c++) {
      int owner = grid[r][c];

      if (owner == -1) {
        // Unclaimed — animated shimmer
        float n = noise(c * 0.15, r * 0.15, frameCount * 0.012);
        float b = map(n, 0, 1, 20, 52);
        fill(b * 0.6, b * 0.6, b);
      } else {
        color base = painters.get(owner).col;

        // Two-scale noise: coarse for flowing gradients, fine for texture
        float coarse = noise(c * 0.06 + 100, r * 0.06 + 100);   // broad terrain
        float fine   = noise(c * 0.4  + 200, r * 0.4  + 200);   // subtle grain
        float v = map(coarse * 0.7 + fine * 0.3, 0, 1, 0.68, 1.22);

        // Darken cells at territory borders — natural contour effect
        boolean onBorder = false;
        if (c > 0        && grid[r][c - 1] != owner) onBorder = true;
        if (c < COLS - 1 && grid[r][c + 1] != owner) onBorder = true;
        if (r > 0        && grid[r - 1][c] != owner) onBorder = true;
        if (r < ROWS - 1 && grid[r + 1][c] != owner) onBorder = true;
        if (onBorder) v *= 0.72;

        fill(constrain(red(base) * v, 0, 255),
             constrain(green(base) * v, 0, 255),
             constrain(blue(base) * v, 0, 255));
      }
      rect(c * CELL, r * CELL, CELL, CELL);

      // Cell claim flash overlay
      if (claimFrame[r][c] > 0) {
        int age = frameCount - claimFrame[r][c];
        if (age < FLASH_FRAMES) {
          float t = 1.0 - (float) age / FLASH_FRAMES;
          t *= t;
          fill(255, t * 200);
          rect(c * CELL, r * CELL, CELL, CELL);
        }
      }
    }
  }

  // Soft territory borders — wider, semi-transparent between different claimed territories
  stroke(0, 40);
  strokeWeight(2.0);
  for (int r = 0; r < ROWS; r++) {
    for (int c = 0; c < COLS; c++) {
      int owner = grid[r][c];
      if (owner < 0) continue;
      if (c < COLS - 1 && grid[r][c + 1] >= 0 && grid[r][c + 1] != owner) {
        line((c + 1) * CELL, r * CELL, (c + 1) * CELL, (r + 1) * CELL);
      }
      if (r < ROWS - 1 && grid[r + 1][c] >= 0 && grid[r + 1][c] != owner) {
        line(c * CELL, (r + 1) * CELL, (c + 1) * CELL, (r + 1) * CELL);
      }
    }
  }
}

// ── Helpers ─────────────────────────────────────────────────

Direction randomDir() {
  return DIRS[(int) random(DIRS.length)];
}

void mousePressed() {
  // Restart button hit-test (positioned by drawHUD)
  float btnX = COLS * CELL - 90;
  float btnY = ROWS * CELL + 11;
  float btnW = 80;
  float btnH = 30;
  if (mouseX >= btnX && mouseX <= btnX + btnW &&
      mouseY >= btnY && mouseY <= btnY + btnH) {
    initGame();
  }
}
