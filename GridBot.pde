import processing.sound.*;

// ── Constants ────────────────────────────────────────────────
final int NUM_THEMES = 9;
final int TARGET_ROWS = 110;  // desired row count — COLS computed to fill width
final int SIDE_W = 250;       // scoreboard width
final int BOT   = 52;
final int MARGIN = 12;        // margin around play area
final int CORNER = 16;        // rounded corner radius
final int INSET  = 4;         // inner padding so cells don't overwrite border
final int STEPS = 5;
final int SPEED = 80;          // simulation speed % (1–100)
final int FLASH_FRAMES = 8;    // cell claim flash duration (short and subtle)
final int GAME_TIME_MS = 10000;  // 10 seconds per game (testing)

// Computed in setup()
int COLS, ROWS, CELL, SIDE, LIMIT, TOP_MARGIN;

// Timer
int gameStartMillis;

// Background image
PImage bgImg;

// ── Retro arcade color palette ──────────────────────────────
// Drawn from Pac-Man, Galaga, Donkey Kong, Dig Dug, Q*bert, etc.
// 30 colours — enough for large tournaments.
color[] PALETTE;

// ── Direction constants ─────────────────────────────────────
Direction UP, DOWN, LEFT, RIGHT;
Direction[] DIRS;

// ── Mode ────────────────────────────────────────────────────
// false = TEST mode, true = TOURNAMENT mode
boolean tournamentMode = false;

// ── Game state ──────────────────────────────────────────────
int[][] grid;
int[][] claimFrame;
ArrayList<BasePainter> painters;
int stepCount;
int unclaimed;
boolean gameOver;
boolean confettiSpawned;

// ── Game state machine (test mode) ──────────────────────────
// 0=SPLASH, 1=INTRO, 2=COUNTDOWN, 3=PLAYING
int gameState = 0;
int stateTimer = 0;
final int SPLASH_FRAMES    = 120;
final int INTRO_FRAMES     = 240;
final int COUNTDOWN_FRAMES = 180;

// ── Score history (for spark lines) ─────────────────────────
final int HIST_LEN  = 50;   // number of samples kept
final int HIST_RATE = 80;   // sample every N steps
int[][] scoreHistory;        // [painterIdx][sample]
int histCount = 0;
int lastHistStep = 0;

// ── Audio ───────────────────────────────────────────────────
SoundFile music;

// ── UI colors (retro arcade) ────────────────────────────────
color unclaimedColor, sidebarBg, hudBg, arcadeBlue;

// ── Arcade font ─────────────────────────────────────────────
PFont arcadeFont;

void setup() {
  size(100, 100);  // placeholder — resized below
  pixelDensity(1);

  int winW = 1200;
  int winH = 900;

  // Equal padding on all sides
  TOP_MARGIN = MARGIN;

  SIDE = SIDE_W;
  int gridAreaH = winH - MARGIN * 3 - INSET * 2;
  int gridAreaW = winW - SIDE - MARGIN * 3 - INSET * 2;
  CELL = gridAreaH / TARGET_ROWS;
  CELL = max(CELL, 4);
  ROWS = gridAreaH / CELL;
  COLS = gridAreaW / CELL;
  LIMIT = max(8000, 8000 * COLS * ROWS / 6400);

  surface.setSize(winW, winH);
  surface.setLocation((displayWidth - winW) / 2, (displayHeight - winH) / 2);

  // Load background
  bgImg = loadImage("screen.png");

  // Init directions
  UP    = new Direction( 0, -1);
  DOWN  = new Direction( 0,  1);
  LEFT  = new Direction(-1,  0);
  RIGHT = new Direction( 1,  0);
  DIRS  = new Direction[]{ UP, DOWN, LEFT, RIGHT };

  // Init retro palette
  // Neon synthwave palette — matches the cyan/magenta background
  PALETTE = new color[] {
    color(  0, 255, 255),  // neon cyan
    color(255,   0, 128),  // hot pink
    color(255, 255,   0),  // electric yellow
    color(128,   0, 255),  // neon purple
    color(  0, 255, 128),  // neon green
    color(255, 100,   0),  // neon orange
    color(100, 140, 255),  // periwinkle blue
    color(255,   0, 255),  // magenta
    color(  0, 200, 100),  // emerald
    color(255, 180,   0),  // amber
    color(  0, 180, 255),  // sky cyan
    color(255,  60,  60),  // neon red
    color(180, 255,   0),  // lime
    color(200,   0, 200),  // violet
    color(255, 200, 100),  // peach
    color(  0, 255, 200),  // aquamarine
    color(255, 100, 200),  // pink
    color(100, 255, 100),  // bright green
    color(255, 140, 60),   // tangerine
    color(140,  80, 255),  // iris
    color(255, 220, 60),   // gold
    color( 60, 220, 220),  // teal
    color(255,  60, 160),  // rose
    color( 80, 200, 255),  // light blue
    color(220, 255, 100),  // chartreuse
    color(255,  80, 80),   // coral
    color(100, 255, 220),  // mint
    color(220, 100, 255),  // lavender
    color(255, 160, 120),  // salmon
    color(120, 255, 160)   // seafoam
  };

  // Init colors — match screen.png neon palette (cyan/magenta)
  unclaimedColor = color(0);
  sidebarBg      = color(0);
  hudBg          = color(0);
  arcadeBlue     = color(0, 220, 255);  // neon cyan from the background grid

  // 8-bit arcade font from data folder
  arcadeFont = createFont("PressStart2P-Regular.ttf", 48);
  textFont(arcadeFont);

  initEffects();

  // Register bots for both modes
  registerTestBots();
  registerTournamentBots();

  // Start in test mode by default
  tournamentMode = false;
  initGame();
}

void playRandomTheme() {
  if (music != null && music.isPlaying()) {
    music.stop();
  }
  int pick = (int) random(1, NUM_THEMES + 1);  // 1–9
  music = new SoundFile(this, "theme" + pick + ".mp3");
  music.loop();
}

void initGame() {
  grid = new int[ROWS][COLS];
  claimFrame = new int[ROWS][COLS];
  for (int r = 0; r < ROWS; r++) {
    java.util.Arrays.fill(grid[r], -1);
  }

  painters = new ArrayList<BasePainter>();

  // Use test bot registry
  int margin = 3;
  int numBots = testBotList.size();
  boolean[][] taken = new boolean[ROWS][COLS];

  for (int i = 0; i < numBots; i++) {
    BotEntry entry = testBotList.get(i);
    int sx, sy;
    do {
      sx = margin + (int) random(COLS - 2 * margin);
      sy = margin + (int) random(ROWS - 2 * margin);
    } while (taken[sy][sx]);
    taken[sy][sx] = true;

    // Reset entry state for reruns
    entry.alive = true;
    entry.totalScore = 0;

    BasePainter bot = entry.createInstance(sx, sy);
    addPainter(bot);
  }

  stepCount  = 0;
  unclaimed  = COLS * ROWS - painters.size();
  gameOver   = false;
  confettiSpawned = false;
  gameState  = 0;
  stateTimer = 0;
  gameStartMillis = 0;  // set when game actually starts playing

  // Init score history
  scoreHistory = new int[painters.size()][HIST_LEN];
  histCount = 0;
  lastHistStep = 0;

  initEffects();
  playRandomTheme();
}

void addPainter(BasePainter p) {
  p.id = painters.size();
  painters.add(p);
  grid[p.y][p.x] = p.id;
  p.score = 1;
}

// ── Main loop ───────────────────────────────────────────────

void draw() {
  stateTimer++;
  tourneyTimer++;

  // ── Background ────────────────────────────────────────────
  if (bgImg != null) {
    image(bgImg, 0, 0, width, height);
  } else {
    background(0);
  }

  // ── Tournament mode ───────────────────────────────────────
  if (tournamentMode) {
    drawTournamentMode();
    return;
  }

  // ── Test mode state machine ───────────────────────────────
  if (gameState == 0) {
    if (stateTimer >= SPLASH_FRAMES) { gameState = 1; stateTimer = 0; }
    return;
  }
  if (gameState == 1) {
    drawIntro();
    if (stateTimer >= INTRO_FRAMES) { gameState = 2; stateTimer = 0; }
    return;
  }
  if (gameState == 2) {
    drawCountdown();
    if (stateTimer >= COUNTDOWN_FRAMES) { gameState = 3; stateTimer = 0; }
    return;
  }

  // ── PLAYING ───────────────────────────────────────────────
  runSimulation();
  drawPlayArea();
}

// ── Simulation step ─────────────────────────────────────────

void runSimulation() {
  if (!gameOver) {
    // Start timer on first simulation frame
    if (gameStartMillis == 0) gameStartMillis = millis();

    int stepsThisFrame = max(1, round(STEPS * SPEED / 100.0));
    for (int s = 0; s < stepsThisFrame; s++) {
      GameInfo game = new GameInfo(grid, COLS, ROWS, painters, stepCount, LIMIT);
      for (BasePainter p : painters) {
        p.update(game);
      }
      stepCount++;

      if (stepCount - lastHistStep >= HIST_RATE) {
        lastHistStep = stepCount;
        int si = histCount % HIST_LEN;
        for (int i = 0; i < painters.size(); i++) {
          scoreHistory[i][si] = painters.get(i).score;
        }
        histCount++;
      }

      // End on time limit, step limit, or all cells claimed
      int elapsed = millis() - gameStartMillis;
      if (elapsed >= GAME_TIME_MS || stepCount >= LIMIT || unclaimed <= 0) {
        gameOver = true;
        break;
      }
    }
  }

  if (gameOver && !confettiSpawned) {
    confettiSpawned = true;
    BasePainter winner = painters.get(0);
    for (BasePainter p : painters) {
      if (p.score > winner.score) winner = p;
    }
    spawnConfetti(winner.col);
  }

  updateEffects();
}

// ── Render the play area + sidebar ──────────────────────────

void drawPlayArea() {
  int gridW = COLS * CELL + INSET * 2;
  int gridH = ROWS * CELL + INSET * 2;

  // Rounded backdrop
  noStroke();
  fill(0, 160);
  rect(MARGIN, TOP_MARGIN + MARGIN, gridW, gridH, CORNER);

  // Border
  stroke(arcadeBlue, 60);
  strokeWeight(1);
  noFill();
  rect(MARGIN + 1, TOP_MARGIN + MARGIN + 1, gridW - 2, gridH - 2, CORNER);
  noStroke();

  // Grid content
  pushMatrix();
  translate(MARGIN + INSET, TOP_MARGIN + MARGIN + INSET);

  drawGrid();
  for (BasePainter p : painters) {
    p.show();
  }
  drawHUD();
  if (gameOver) {
    drawGameOver();
  }

  popMatrix();

  roundCorners(MARGIN, TOP_MARGIN + MARGIN, gridW, gridH, CORNER);

  // Sidebar
  pushMatrix();
  translate(MARGIN + gridW + MARGIN, TOP_MARGIN + MARGIN);
  drawSidebar();
  popMatrix();

  roundCorners(MARGIN + gridW + MARGIN, TOP_MARGIN + MARGIN, SIDE - MARGIN, gridH, CORNER);

  // Confetti on top
  drawEffects();
}

// ── Tournament mode draw ────────────────────────────────────

void drawTournamentMode() {
  // tourneyPhase: 0=BRACKET, 1=COUNTDOWN, 2=PLAYING, 3=RESULTS, 4=CHAMPION
  switch (tourneyPhase) {
    case 0:  // Show bracket / upcoming heat
      drawBracketView();
      break;

    case 1:  // Countdown before heat
      drawCountdown();
      if (stateTimer >= COUNTDOWN_FRAMES) {
        tourneyPhase = 2;
        stateTimer = 0;
      }
      break;

    case 2:  // Playing a heat
      runSimulation();
      drawPlayArea();

      // When game ends, auto-advance to results after a pause
      if (gameOver) {
        if (stateTimer == 0) stateTimer = 1;  // start counting
        // Wait a beat before showing results
        if (stateTimer > 180) {
          finishCurrentHeat();
          tourneyPhase = 3;
          tourneyTimer = 0;
        }
      }
      break;

    case 3:  // Heat results
      drawHeatResults();
      break;

    case 4:  // Champion!
      drawChampionScreen();
      drawEffects();
      updateEffects();
      break;
  }
}

// ── Grid rendering ──────────────────────────────────────────

void drawGrid() {
  noStroke();
  for (int r = 0; r < ROWS; r++) {
    for (int c = 0; c < COLS; c++) {
      int owner = grid[r][c];

      if (owner == -1) {
        fill(0, 100);  // unclaimed — background shows through
      } else {
        color base = painters.get(owner).col;
        fill(red(base), green(base), blue(base), 235);
      }
      rect(c * CELL, r * CELL, CELL, CELL);

      // Subtle claim flash — brief brightening in the cell's own color
      if (owner >= 0 && claimFrame[r][c] > 0) {
        int age = frameCount - claimFrame[r][c];
        if (age < FLASH_FRAMES) {
          float t = 1.0 - (float) age / FLASH_FRAMES;
          fill(255, t * 80);
          rect(c * CELL, r * CELL, CELL, CELL);
        }
      }
    }
  }

  // Blue grid lines — Pac-Man maze style
  stroke(arcadeBlue, 30);
  strokeWeight(0.5);
  for (int r = 0; r <= ROWS; r++) {
    line(0, r * CELL, COLS * CELL, r * CELL);
  }
  for (int c = 0; c <= COLS; c++) {
    line(c * CELL, 0, c * CELL, ROWS * CELL);
  }

  // Territory borders
  stroke(arcadeBlue, 80);
  strokeWeight(1);
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

// ── Rounded corner masking ───────────────────────────────────
// Redraws the background image into the four corners of a rect
// to create the illusion of rounded corners over the grid.

void roundCorners(float rx, float ry, float rw, float rh, float rad) {
  if (bgImg == null) return;
  // We'll draw small corner patches by copying from the bg image
  // For each corner, draw a filled rect from the bg, then cut out the arc
  noStroke();
  for (int corner = 0; corner < 4; corner++) {
    float cx, cy;  // corner origin
    float arcCx, arcCy;  // arc center
    float startAngle;
    switch(corner) {
      case 0: cx = rx;          cy = ry;          arcCx = rx + rad;       arcCy = ry + rad;       startAngle = PI;       break; // TL
      case 1: cx = rx + rw - rad; cy = ry;        arcCx = rx + rw - rad;  arcCy = ry + rad;       startAngle = -HALF_PI; break; // TR
      case 2: cx = rx;          cy = ry + rh - rad; arcCx = rx + rad;     arcCy = ry + rh - rad;  startAngle = HALF_PI;  break; // BL
      default: cx = rx + rw - rad; cy = ry + rh - rad; arcCx = rx + rw - rad; arcCy = ry + rh - rad; startAngle = 0; break; // BR
    }
    // Draw a small square of bg in the corner
    float srcX = cx / width * bgImg.width;
    float srcY = cy / height * bgImg.height;
    float srcW = rad / width * bgImg.width;
    float srcH = rad / height * bgImg.height;
    copy(bgImg, (int)srcX, (int)srcY, (int)srcW, (int)srcH,
         (int)cx, (int)cy, (int)rad, (int)rad);
    // Then draw a filled arc to cut the round shape back out
    fill(0, 160);  // match the backdrop alpha
    arc(arcCx, arcCy, rad * 2, rad * 2, startAngle, startAngle + HALF_PI, PIE);
  }
}

// ── Helpers ─────────────────────────────────────────────────

Direction randomDir() {
  return DIRS[(int) random(DIRS.length)];
}

void keyPressed() {
  if (key == 'r' || key == 'R') {
    if (tournamentMode) {
      tournamentMode = false;
    }
    initGame();
  }

  // T = start tournament mode
  if (key == 't' || key == 'T') {
    tournamentMode = true;
    stateTimer = 0;
    tourneyTimer = 0;
    initTournament();
    playRandomTheme();
  }

  // SPACE = advance tournament
  if (key == ' ' && tournamentMode) {
    if (tourneyPhase == 0) {
      // Start the heat — new music each heat
      startCurrentHeat();
      playRandomTheme();
      tourneyPhase = 1;  // countdown
      stateTimer = 0;
    } else if (tourneyPhase == 3) {
      // Advance from results
      boolean more = advanceTournament();
      if (more) {
        tourneyPhase = 0;  // show next bracket
        tourneyTimer = 0;
      } else {
        // Tournament over
        tourneyPhase = 4;
        tourneyTimer = 0;
        if (champion != null) {
          spawnConfetti(champion.col);
        }
      }
    }
  }
}
