/*
 * GridWars
 * Copyright (c) 2026 Eric Freeman, PhD
 * University of Texas at Austin
 * April 7, 2026
 *
 * MIT License
 *
 * Permission is hereby granted, free of charge, to any person obtaining a copy
 * of this software and associated documentation files (the "Software"), to deal
 * in the Software without restriction, including without limitation the rights
 * to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the Software is
 * furnished to do so, subject to the following conditions:
 *
 * The above copyright notice and this permission notice shall be included in all
 * copies or substantial portions of the Software.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
 * SOFTWARE.
 */

import processing.sound.*;

// ── Display — set to false for smaller screens ──────────────
boolean HIGH_RES = true;
boolean SAVE_SCREENSHOTS = false;

// ── Constants ────────────────────────────────────────────────
final int NUM_THEMES = 2;
final int TARGET_ROWS = 150;  // desired row count — COLS computed to fill width
final int SIDE_W = 250;       // scoreboard width
final int BOT   = 52;
final int MARGIN = 12;        // margin around play area
final int CORNER = 16;        // rounded corner radius
final int INSET  = 4;         // inner padding so cells don't overwrite border
final int STEPS = 1;
final int TOURNEY_STEPS = 2;  // extra steps per frame in tournament mode
final int SPEED = 100;          // simulation speed % (1–100)
final int FLASH_FRAMES = 8;    // cell claim flash duration (short and subtle)
final int GAME_TIME_MS = 120000;  // 2 minutes per game

// Computed in setup()
int COLS, ROWS, CELL, SIDE, LIMIT, TOP_MARGIN;

// Timer
int gameStartMillis;

// Background images
PImage bgImg;
PImage beastBgImg;
PImage tourneyBgImg;
boolean beastMode = false;
boolean beastSplash = false;
boolean showLeaderboard = true;
boolean showMagnifier = false;
boolean adminUnlocked = false;
String adminBuffer = "";
int adminFlashFrame = -999;
float creditsScrollX = 0;
int testIntroPhase = 0;    // 0 = credits scroll, 1 = contenders reveal
int contenderRevealTimer = 0;
boolean fadeOutMusic = false;
int fadeOutFrame = 0;
final int FADE_FRAMES = 90;  // ~1.5 sec fade
boolean fadeToPreMusic = false;  // start pre music after fade

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
boolean dimMode = false;  // D key: dim non-halo bots

// ── Game state ──────────────────────────────────────────────
int[][] grid;
int[][] claimFrame;
ArrayList<Bot> bots;
int stepCount;
int unclaimed;
boolean gameOver;
boolean confettiSpawned;
boolean needsScreenshot;

// ── Visual flair state ──────────────────────────────────────
int currentLeaderId = -1;
int leadChangeFrame = -999;
int[] milestoneFrame;        // per-bot: frame of last milestone popup
int[] milestoneValue;        // per-bot: value to display
float timePressureIntensity = 0;

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
boolean musicMuted = false;
int lastTestTrack = 0;
int lastPreTrack = 0;

// ── UI colors (retro arcade) ────────────────────────────────
color unclaimedColor, sidebarBg, hudBg, arcadeBlue;

// ── Arcade font ─────────────────────────────────────────────
PFont arcadeFont;

void setup() {
  size(100, 100);  // placeholder — resized below
  pixelDensity(1);
  frameRate(60);

  int winW = HIGH_RES ? 1770 : 1200;
  int winH = HIGH_RES ? 1100 : 750;

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

  // Load backgrounds
  bgImg = loadImage("header.png");
  beastBgImg = loadImage("beastbackground.jpg");
  if (beastBgImg != null) {
    beastBgImg.resize(winW, winH);
  }
  tourneyBgImg = loadImage("headertournament.png");
  if (tourneyBgImg != null) {
    tourneyBgImg.resize(winW, winH);
  }

  // Init directions
  UP    = new Direction( 0, -1);
  DOWN  = new Direction( 0,  1);
  LEFT  = new Direction(-1,  0);
  RIGHT = new Direction( 1,  0);
  DIRS  = new Direction[]{ UP, DOWN, LEFT, RIGHT };

  // Init retro palette — randomly chosen each run
  randomizePalette();

  // Init colors — match screen.png neon palette (cyan/magenta)
  unclaimedColor = color(0);
  sidebarBg      = color(0);
  hudBg          = color(0);
  arcadeBlue     = color(0, 220, 255);  // neon cyan from the background grid

  // 8-bit arcade font from data folder
  arcadeFont = createFont("PressStart2P-Regular.ttf", 48);
  textFont(arcadeFont);

  // Sound effects
  initEffects();

  // Register bots for both modes
  registerTestBots();
  registerTournamentBots();

  // Start in test mode by default
  tournamentMode = false;
  initGame();
  playPreMusic();
}

void playPreMusic() {
  if (music != null && music.isPlaying()) {
    music.stop();
  }
  int pick;
  do {
    pick = (int) random(1, 3);  // 1–2
  } while (pick == lastPreTrack);
  lastPreTrack = pick;
  music = new SoundFile(this, "pre" + pick + ".mp3");
  music.amp(musicMuted ? 0 : 0.9);
  music.loop();
}

void playRandomTheme() {
  if (music != null && music.isPlaying()) {
    music.stop();
  }
  int pick = (int) random(1, NUM_THEMES + 1);
  music = new SoundFile(this, "theme" + pick + ".mp3");
  music.amp(musicMuted ? 0 : 0.9);
  music.loop();
}

void playTestMusic() {
  if (music != null && music.isPlaying()) {
    music.stop();
  }
  int pick;
  do {
    pick = (int) random(1, 8);  // 1–7
  } while (pick == lastTestTrack);
  lastTestTrack = pick;
  music = new SoundFile(this, "test" + pick + ".mp3");
  music.amp(musicMuted ? 0 : 0.9);
  music.loop();
}

void stopMusic() {
  if (music != null && music.isPlaying()) {
    music.stop();
  }
}

void initGame() {
  grid = new int[ROWS][COLS];
  claimFrame = new int[ROWS][COLS];
  for (int r = 0; r < ROWS; r++) {
    java.util.Arrays.fill(grid[r], -1);
  }

  // Fresh palette each run, then register bots with those colors
  randomizePalette();
  registerTestBots();

  bots = new ArrayList<Bot>();

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

    Bot bot = entry.createInstance(sx, sy);
    addBot(bot);
  }

  stepCount  = 0;
  unclaimed  = COLS * ROWS - bots.size();
  gameOver   = false;
  confettiSpawned = false;
  needsScreenshot = false;
  gameState  = 0;
  stateTimer = 0;
  gameStartMillis = 0;
  testIntroPhase = 0;
  contenderRevealTimer = 0;

  // Init score history
  scoreHistory = new int[bots.size()][HIST_LEN];
  histCount = 0;
  lastHistStep = 0;

  // Init visual flair
  currentLeaderId = -1;
  leadChangeFrame = -999;
  milestoneFrame = new int[bots.size()];
  milestoneValue = new int[bots.size()];
  milestoneX = new float[bots.size()];
  milestoneY = new float[bots.size()];

  initEffects();
}

void initBeastMode() {
  grid = new int[ROWS][COLS];
  claimFrame = new int[ROWS][COLS];
  for (int r = 0; r < ROWS; r++) {
    java.util.Arrays.fill(grid[r], -1);
  }

  bots = new ArrayList<Bot>();

  // Fresh palette and re-register all bots with new colors
  randomizePalette();
  registerTournamentBots();

  int margin = 3;
  int numBots = tournamentBotList.size();
  boolean[][] taken = new boolean[ROWS][COLS];

  for (int i = 0; i < numBots; i++) {
    BotEntry entry = tournamentBotList.get(i);
    int sx, sy;
    do {
      sx = margin + (int) random(COLS - 2 * margin);
      sy = margin + (int) random(ROWS - 2 * margin);
    } while (taken[sy][sx]);
    taken[sy][sx] = true;

    entry.alive = true;
    entry.totalScore = 0;

    Bot bot = entry.createInstance(sx, sy);
    addBot(bot);
  }

  stepCount  = 0;
  unclaimed  = COLS * ROWS - bots.size();
  gameOver   = false;
  confettiSpawned = false;
  needsScreenshot = false;
  gameState  = 1;  // jump straight to playing
  stateTimer = 0;
  gameStartMillis = 0;

  scoreHistory = new int[bots.size()][HIST_LEN];
  histCount = 0;
  lastHistStep = 0;

  currentLeaderId = -1;
  leadChangeFrame = -999;
  milestoneFrame = new int[bots.size()];
  milestoneValue = new int[bots.size()];
  milestoneX = new float[bots.size()];
  milestoneY = new float[bots.size()];
  timePressureIntensity = 0;

  initEffects();
  stopMusic();
  music = new SoundFile(this, "beast.mp3");
  music.amp(musicMuted ? 0 : 0.9);
  music.loop();
}

void addBot(Bot p) {
  p.id = bots.size();
  bots.add(p);
  grid[p.y][p.x] = p.id;
  p.score = 1;
}

// ── Main loop ───────────────────────────────────────────────

void draw() {
  stateTimer++;
  tourneyTimer++;

  // ── Music fade out ──
  if (fadeOutMusic && music != null) {
    fadeOutFrame++;
    float vol = max(0, 0.9 * (1.0 - (float) fadeOutFrame / FADE_FRAMES));
    if (!musicMuted) music.amp(vol);
    if (fadeOutFrame >= FADE_FRAMES) {
      fadeOutMusic = false;
      music.stop();
      if (fadeToPreMusic) {
        fadeToPreMusic = false;
        playPreMusic();
      }
    }
  }

  // ── Background ────────────────────────────────────────────
  // Use background image on non-gameplay screens, black during gameplay
  boolean showBg = false;

  if (tournamentMode) {
    // Background on bracket, countdown, results, champion — not during play
    showBg = (tourneyPhase != 2);
  } else {
    // Background on test intro and game over — not during play
    showBg = (gameState == 0) || (gameOver && !needsScreenshot);
  }

  if (showBg && beastMode && !tournamentMode && beastBgImg != null) {
    image(beastBgImg, 0, 0);
  } else if (showBg && tournamentMode && tourneyBgImg != null) {
    image(tourneyBgImg, 0, 0);
  } else if (showBg && bgImg != null) {
    image(bgImg, 0, 0);
  } else {
    background(0);
  }

  // ── Beast mode splash ──────────────────────────────────────
  if (beastSplash) {
    if (beastBgImg != null) {
      image(beastBgImg, 0, 0);
    }
    drawBeastSplash();
    drawAdminFlash();
    drawMuteButton();
    return;
  }

  // ── Tournament mode ───────────────────────────────────────
  if (tournamentMode) {
    drawTournamentMode();
    drawAdminFlash();
    drawMuteButton();
    return;
  }

  // ── Test mode: wait for space, then play ───────────────────
  if (gameState == 0 && !beastMode) {
    drawTestIntro();
    drawAdminFlash();
    drawMuteButton();
    return;
  }

  // ── PLAYING ───────────────────────────────────────────────
  runSimulation();

  if (gameOver && !needsScreenshot) {
    // After screenshot taken, show winner over background only
    drawGameOverFull();
    drawEffects();
  } else {
    drawPlayArea();
  }
  drawAdminFlash();
  drawMuteButton();
}

// ── Simulation step ─────────────────────────────────────────

void runSimulation() {
  if (!gameOver) {
    // Start timer on first simulation frame
    if (gameStartMillis == 0) gameStartMillis = millis();

    int baseSteps = tournamentMode ? TOURNEY_STEPS : STEPS;
    int stepsThisFrame = max(1, round(baseSteps * SPEED / 100.0));
    for (int s = 0; s < stepsThisFrame; s++) {
      GameInfo game = new GameInfo(grid, COLS, ROWS, bots, stepCount, LIMIT);
      for (Bot p : bots) {
        p.update(game);
      }
      stepCount++;

      if (stepCount - lastHistStep >= HIST_RATE) {
        lastHistStep = stepCount;
        int si = histCount % HIST_LEN;
        for (int i = 0; i < bots.size(); i++) {
          scoreHistory[i][si] = bots.get(i).score;
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

  // Ambient sparkles during gameplay — intensify under time pressure
  if (!gameOver && frameCount % 6 == 0) {
    spawnAmbientSparkles();
    if (timePressureIntensity > 0 && frameCount % 3 == 0) {
      spawnAmbientSparkles();  // double rate in final seconds
    }
  }

  // Lead change detection
  if (!gameOver) {
    int leaderId = 0;
    for (int i = 1; i < bots.size(); i++) {
      if (bots.get(i).score > bots.get(leaderId).score) leaderId = i;
    }
    if (currentLeaderId >= 0 && leaderId != currentLeaderId) {
      leadChangeFrame = frameCount;
      Bot newLeader = bots.get(leaderId);
      spawnMegaBurst(newLeader.x * CELL + CELL / 2.0, newLeader.y * CELL + CELL / 2.0, newLeader.col);
    }
    currentLeaderId = leaderId;
  }

  // Time pressure — last 15 seconds
  if (!gameOver && gameStartMillis > 0) {
    int remaining = GAME_TIME_MS - (millis() - gameStartMillis);
    if (remaining < 15000) {
      timePressureIntensity = 1.0 - (float) remaining / 15000;
    } else {
      timePressureIntensity = 0;
    }
  }

  if (gameOver && !confettiSpawned) {
    confettiSpawned = true;
    Bot winner = bots.get(0);
    for (Bot p : bots) {
      if (p.score > winner.score) winner = p;
    }
    spawnConfetti(winner.col);
    needsScreenshot = true;
  }

  updateEffects();
}

// ── Render the play area + sidebar ──────────────────────────

void drawPlayArea() {
  int gridW = COLS * CELL + INSET * 2;
  int gridH = ROWS * CELL + INSET * 2;

  // Outer glow
  noStroke();
  fill(0, 180, 220, 18);
  rect(MARGIN - 3, TOP_MARGIN + MARGIN - 3, gridW + 6, gridH + 6, CORNER + 4);

  // Rounded backdrop
  fill(12, 16, 38, 170);
  rect(MARGIN, TOP_MARGIN + MARGIN, gridW, gridH, CORNER);

  // Border — bright neon glow, pulses red under time pressure
  color borderCol = arcadeBlue;
  float borderAlpha = 160;
  float borderWeight = 2;
  if (timePressureIntensity > 0 && !gameOver) {
    float pulse = 0.5 + 0.5 * sin(frameCount * 0.2 * (1 + timePressureIntensity));
    borderCol = lerpColor(arcadeBlue, color(255, 0, 0), timePressureIntensity * pulse);
    borderAlpha = 160 + 95 * timePressureIntensity * pulse;
    borderWeight = 2 + 2 * timePressureIntensity * pulse;
  }
  int leadAge = frameCount - leadChangeFrame;
  if (leadAge < 20) {
    float flash = 1.0 - (float) leadAge / 20;
    borderCol = lerpColor(borderCol, color(255, 255, 0), flash);
    borderAlpha = max(borderAlpha, 255 * flash);
  }
  stroke(borderCol, borderAlpha);
  strokeWeight(borderWeight);
  noFill();
  rect(MARGIN + 1, TOP_MARGIN + MARGIN + 1, gridW - 2, gridH - 2, CORNER);
  noStroke();

  // Grid content
  pushMatrix();
  translate(MARGIN + INSET, TOP_MARGIN + MARGIN + INSET);

  drawGrid();
  if (!gameOver) {
    for (Bot p : bots) {
      p.show();
    }
  }
  drawHUD();

  // Grid-local sparkle effects
  drawGridEffects();

  popMatrix();

  // Save just the game grid (no bots, no overlays)
  if (needsScreenshot) {
    needsScreenshot = false;
    if (SAVE_SCREENSHOTS) {
      int imgW = COLS * CELL;
      int imgH = ROWS * CELL;
      PImage gameImg = get(MARGIN + INSET, TOP_MARGIN + MARGIN + INSET, imgW, imgH);
      gameImg.save(sketchPath("images/game-" + year() + nf(month(),2) + nf(day(),2) + "-" + nf(hour(),2) + nf(minute(),2) + nf(second(),2) + ".png"));
    }
  }

  // Sidebar — overlays on top of grid, toggled with L
  if (showLeaderboard) {
    pushMatrix();
    translate(MARGIN + gridW + MARGIN, TOP_MARGIN + MARGIN);
    drawSidebar();
    popMatrix();
  }

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
      drawEffects();
      updateEffects();
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
  int gap = 1;                             // 1px gap between cells
  int cs = CELL - gap;                     // cell draw size

  for (int r = 0; r < ROWS; r++) {
    for (int c = 0; c < COLS; c++) {
      int owner = grid[r][c];
      int cx = c * CELL;
      int cy = r * CELL;

      if (owner == -1) {
        float n = noise(c * 0.3, r * 0.3);
        float g = 12 + n * 30;
        fill(g, g, g + 5);
        rect(cx, cy, cs, cs);
      } else {
        Bot ownerBot = bots.get(owner);
        color base = ownerBot.col;
        boolean dim = dimMode && !ownerBot.halo;
        float dimAlpha = dim ? 0.3 : 1.0;

        // Main cell fill
        fill(red(base) * dimAlpha, green(base) * dimAlpha, blue(base) * dimAlpha, dim ? 140 : 235);
        rect(cx, cy, cs, cs);

        if (!dim) {
          // Inner highlight — lighter top half for depth
          fill(255, 35);
          rect(cx, cy, cs, cs / 2);

          // Territory shimmer
          if ((r + c) % 2 == 0) {
            float wave = sin((r + c) * 0.4 + frameCount * 0.12 + owner * 2.0);
            if (wave > 0.5) {
              float scorePct = constrain((float) ownerBot.score / (COLS * ROWS * 0.1), 0, 1);
              float intensity = (wave - 0.5) * 2.0;
              fill(255, intensity * (20 + 50 * scorePct));
              rect(cx, cy, cs, cs);
            }
          }

          // Claim flash
          if (claimFrame[r][c] > 0) {
            int age = frameCount - claimFrame[r][c];
            if (age < FLASH_FRAMES) {
              float t = 1.0 - (float) age / FLASH_FRAMES;
              fill(255, t * 80);
              rect(cx, cy, cs, cs);
            }
          }
        }
      }
    }
  }

  // Territory borders — drawn as thin rects
  fill(red(arcadeBlue), green(arcadeBlue), blue(arcadeBlue), 80);
  for (int r = 0; r < ROWS; r++) {
    for (int c = 0; c < COLS; c++) {
      int owner = grid[r][c];
      if (owner < 0) continue;
      if (c < COLS - 1 && grid[r][c + 1] >= 0 && grid[r][c + 1] != owner) {
        rect((c + 1) * CELL, r * CELL, 1, CELL);
      }
      if (r < ROWS - 1 && grid[r + 1][c] >= 0 && grid[r + 1][c] != owner) {
        rect(c * CELL, (r + 1) * CELL, CELL, 1);
      }
    }
  }
}

// ── Helpers ─────────────────────────────────────────────────

// Split "LastFirst" into "First Last"
String displayName(String name) {
  // Strip "Bot" suffix if present
  String base = name.endsWith("Bot") ? name.substring(0, name.length() - 3) : name;
  // Find the second uppercase letter — that's where the first name starts
  for (int i = 1; i < base.length(); i++) {
    if (Character.isUpperCase(base.charAt(i))) {
      return base.substring(i) + " " + base.substring(0, i);
    }
  }
  return base;
}

Direction randomDir() {
  return DIRS[(int) random(DIRS.length)];
}

// ── Admin unlock flash ──────────────────────────────────────
void drawAdminFlash() {
  int age = frameCount - adminFlashFrame;
  if (age >= 0 && age < 90) {
    float alpha = age < 10 ? age * 25.5 : max(0, 255 * (1.0 - (float)(age - 10) / 80));
    textAlign(PConstants.CENTER, PConstants.CENTER);
    fill(0, 255, 128, alpha);
    textSize(22);
    text("ADMIN UNLOCKED", width / 2, height / 2);
  }
}

// ── Mute button (lower-left corner) ─────────────────────────
final int MUTE_X = 14, MUTE_Y_OFF = 14, MUTE_SZ = 22;

void drawMuteButton() {
  float bx = MUTE_X;
  float by = height - MUTE_Y_OFF - MUTE_SZ;

  // Background circle
  noStroke();
  fill(0, 120);
  ellipse(bx + MUTE_SZ / 2, by + MUTE_SZ / 2, MUTE_SZ + 8, MUTE_SZ + 8);

  stroke(255, 140);
  strokeWeight(2);
  noFill();

  if (musicMuted) {
    // Muted: speaker with X
    // Speaker body
    float sx = bx + 4, sy = by + 7;
    line(sx, sy, sx + 4, sy);
    line(sx, sy + 8, sx + 4, sy + 8);
    line(sx, sy, sx, sy + 8);
    line(sx + 4, sy, sx + 8, sy - 3);
    line(sx + 4, sy + 8, sx + 8, sy + 11);
    line(sx + 8, sy - 3, sx + 8, sy + 11);
    // X mark
    stroke(255, 80, 80, 200);
    line(bx + 13, by + 7, bx + 19, by + 15);
    line(bx + 19, by + 7, bx + 13, by + 15);
  } else {
    // Unmuted: speaker with sound waves
    float sx = bx + 4, sy = by + 7;
    line(sx, sy, sx + 4, sy);
    line(sx, sy + 8, sx + 4, sy + 8);
    line(sx, sy, sx, sy + 8);
    line(sx + 4, sy, sx + 8, sy - 3);
    line(sx + 4, sy + 8, sx + 8, sy + 11);
    line(sx + 8, sy - 3, sx + 8, sy + 11);
    // Sound waves
    noFill();
    stroke(255, 120);
    arc(bx + 14, by + MUTE_SZ / 2, 8, 10, -PI / 3, PI / 3);
    arc(bx + 14, by + MUTE_SZ / 2, 14, 16, -PI / 4, PI / 4);
  }
  noStroke();
}

void mousePressed() {
  float bx = MUTE_X;
  float by = height - MUTE_Y_OFF - MUTE_SZ;
  if (mouseX >= bx - 4 && mouseX <= bx + MUTE_SZ + 4 &&
      mouseY >= by - 4 && mouseY <= by + MUTE_SZ + 4) {
    musicMuted = !musicMuted;
    if (music != null) {
      if (musicMuted) {
        music.amp(0);
      } else {
        music.amp(0.9);
      }
    }
  }
}

void keyPressed() {
  if (key == 'r' || key == 'R') {
    tournamentMode = false;
    beastMode = false;
    beastSplash = false;
    initGame();
    if (music != null && music.isPlaying()) {
      fadeOutMusic = true;
      fadeOutFrame = 0;
      fadeToPreMusic = true;
    } else {
      fadeOutMusic = false;
      playPreMusic();
    }
  }

  // L = toggle leaderboard
  if (key == 'l' || key == 'L') {
    showLeaderboard = !showLeaderboard;
  }

  // Z = toggle magnifier on lead player
  if (key == 'z' || key == 'Z') {
    showMagnifier = !showMagnifier;
  }

  // D = toggle dim mode (dim non-halo bots)
  if (key == 'd' || key == 'D') {
    dimMode = !dimMode;
  }

  // Admin code: type 1983 to unlock T and B
  if (key >= '0' && key <= '9') {
    adminBuffer += key;
    if (adminBuffer.length() > 4) adminBuffer = adminBuffer.substring(adminBuffer.length() - 4);
    if (adminBuffer.equals("1983") && !adminUnlocked) {
      adminUnlocked = true;
      adminFlashFrame = frameCount;
    }
  }

  // B = beast mode splash (admin only, needs bots)
  if ((key == 'b' || key == 'B') && adminUnlocked && tournamentBotList.size() > 0) {
    tournamentMode = false;
    beastMode = true;
    beastSplash = true;
    stateTimer = 0;
    fadeOutMusic = true;
    fadeOutFrame = 0;
    fadeToPreMusic = true;
  }

  // T = start tournament mode (admin only, needs bots)
  if ((key == 't' || key == 'T') && adminUnlocked && tournamentBotList.size() > 1) {
    tournamentMode = true;
    beastMode = false;
    beastSplash = false;
    stateTimer = 0;
    tourneyTimer = 0;
    fadeOutMusic = true;
    fadeOutFrame = 0;
    fadeToPreMusic = true;
    initTournament();
  }

  // SPACE = beast mode launch
  if (key == ' ' && beastSplash) {
    beastSplash = false;
    initBeastMode();
    return;
  }

  // SPACE = start test / restart after game over / advance tournament
  if (key == ' ' && !tournamentMode && !beastMode && gameState == 0) {
    if (testIntroPhase == 0) {
      // Show contenders — start fade out
      testIntroPhase = 1;
      contenderRevealTimer = 0;
      fadeOutMusic = true;
      fadeOutFrame = 0;
    } else {
      // Already showing contenders — start now
      gameState = 1;
      fadeOutMusic = false;
      playTestMusic();
      testIntroPhase = 0;
    }
    return;
  }
  if (key == ' ' && beastMode && gameOver) {
    initBeastMode();
    return;
  }
  if (key == ' ' && !tournamentMode && !beastMode && gameOver) {
    initGame();
    gameState = 1;  // jump straight to playing
    playTestMusic();
    return;
  }
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
        fadeOutMusic = true;
        fadeOutFrame = 0;
        fadeToPreMusic = true;
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