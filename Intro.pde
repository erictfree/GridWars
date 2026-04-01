// ── Intro & Countdown screens ───────────────────────────────

void drawTestIntro() {
  float cx = width / 2.0;
  float pulse = 0.7 + 0.3 * sin(stateTimer * 0.08);
  float fastPulse = 0.5 + 0.5 * sin(stateTimer * 0.2);
  int n = bots != null ? bots.size() : testBotList.size();

  // ── Scanline overlay for CRT feel ──
  noStroke();
  for (int y = 0; y < height; y += 4) {
    fill(0, 15);
    rect(0, y, width, 2);
  }

  // ── "TEST MODE" — huge neon with glow layers ──
  textAlign(PConstants.CENTER, PConstants.CENTER);

  // Glow layers (back to front)
  fill(0, 200, 255, 20);
  textSize(56);
  text("TEST MODE", cx + 2, height * 0.24 + 2);
  text("TEST MODE", cx - 2, height * 0.24 - 2);

  fill(0, 200, 255, 40);
  textSize(54);
  text("TEST MODE", cx, height * 0.24);

  // Main text
  fill(arcadeBlue, 220 + 35 * pulse);
  textSize(52);
  text("TEST MODE", cx, height * 0.24);

  // ── Horizontal neon dividers ──
  float divY = height * 0.30;
  for (int layer = 3; layer >= 0; layer--) {
    stroke(arcadeBlue, (4 - layer) * 25 * pulse);
    strokeWeight(1 + layer * 2);
    line(cx - 350, divY, cx + 350, divY);
  }
  noStroke();

  // ── "CONTENDERS" — spaced, hot pink, with glow ──
  fill(255, 0, 128, 30);
  textSize(26);
  text("C O N T E N D E R S", cx, height * 0.345);
  fill(255, 0, 128);
  textSize(24);
  text("C O N T E N D E R S", cx, height * 0.345);

  // ── Bot roster — big names, color swatches, animated entry ──
  int cols = (n > 10) ? 3 : (n > 5) ? 2 : 1;
  int perCol = (int) ceil((float) n / cols);
  float colW = 320;
  float rosterX = cx - (cols * colW) / 2;
  float startY = height * 0.40;
  float rowH = min(38, (height * 0.30) / perCol);

  // Bots appear one by one
  int botsToShow = min(n, (int)(stateTimer * n / 50.0) + 1);

  for (int i = 0; i < botsToShow; i++) {
    int c = i / perCol;
    int row = i % perCol;
    float bx = rosterX + c * colW + 30;
    float by = startY + row * rowH;

    BotEntry entry = testBotList.get(i);

    // Entrance flash on the frame this bot appears
    int appearFrame = (int)(i * 50.0 / n);
    int age = stateTimer - appearFrame;
    if (age >= 0 && age < 8) {
      float flash = 1.0 - (float) age / 8;
      fill(entry.col, flash * 60);
      noStroke();
      rect(bx - 8, by - 2, colW - 40, rowH - 2, 4);
    }

    // Color swatch with glow
    fill(red(entry.col), green(entry.col), blue(entry.col), 40);
    noStroke();
    rect(bx - 2, by + 1, 22, 22, 2);
    fill(entry.col);
    rect(bx, by + 3, 18, 18);

    // Name
    fill(entry.col);
    textSize(16);
    textAlign(PConstants.LEFT, PConstants.TOP);
    text(displayName(entry.name), bx + 28, by + 3);
  }

  // ── "VS" badge in the center if 2 columns ──
  if (cols == 2 && botsToShow >= 2) {
    float vsY = startY + (perCol * rowH) / 2 - 10;
    fill(0, 140);
    noStroke();
    ellipse(cx, vsY, 50, 50);
    stroke(255, 255, 0, 160 * pulse);
    strokeWeight(2);
    noFill();
    ellipse(cx, vsY, 50, 50);
    noStroke();
    fill(255, 255, 0, 220 * pulse);
    textSize(16);
    textAlign(PConstants.CENTER, PConstants.CENTER);
    text("VS", cx, vsY);
  }

  // ── Tagline ──
  // Shadow
  fill(0, 160);
  textSize(20);
  textAlign(PConstants.CENTER, PConstants.CENTER);
  text(n + " BOTS ENTER  ·  1 BOT WINS", cx + 2, height * 0.78 + 2);
  // Main
  fill(255, 220);
  text(n + " BOTS ENTER  ·  1 BOT WINS", cx, height * 0.78);

  // ── "PRESS SPACE" — big flashing arcade prompt ──
  boolean blink = (stateTimer % 45) < 30;
  if (blink) {
    // Glow
    fill(255, 255, 0, 30);
    textSize(30);
    text("PRESS SPACE TO START", cx, height * 0.85);
    // Main
    fill(255, 255, 0, 200 + 55 * fastPulse);
    textSize(28);
    text("PRESS SPACE TO START", cx, height * 0.85);
  }

  // ── Controls hint ──
  fill(80);
  textSize(11);
  text("R = RESTART  |  T = TOURNAMENT MODE", cx, height * 0.93);
}

void drawIntro() {
  // Dark overlay so text is readable over background
  noStroke();
  fill(0, 140);
  rect(0, 0, width, height);

  // ── "GRID WARS" — show the title area from the background
  // (background is already drawn, overlay is semi-transparent)

  // ── Contenders roster ─────────────────────────────────────
  float cx = width / 2.0;
  float startY = height * 0.28;

  // "CONTENDERS" header
  fill(arcadeBlue);
  textSize(18);
  textAlign(PConstants.CENTER, PConstants.CENTER);
  text("C O N T E N D E R S", cx, startY - 30);

  // Divider line
  stroke(arcadeBlue, 80);
  strokeWeight(1);
  line(cx - 200, startY - 10, cx + 200, startY - 10);
  noStroke();

  // Bot roster — show bots appearing one by one
  int n = bots.size();
  int cols = 3;  // 3-column layout
  int perCol = (int) ceil((float) n / cols);
  float colW = 220;
  float rowH = 22;
  float rosterX = cx - (cols * colW) / 2;

  // How many bots to show (animate in one by one)
  int botsToShow = min(n, (int)(stateTimer * n / (float)(INTRO_FRAMES * 0.7)));

  for (int i = 0; i < botsToShow; i++) {
    int col = i / perCol;
    int row = i % perCol;
    float bx = rosterX + col * colW + 10;
    float by = startY + row * rowH;

    Bot p = bots.get(i);

    // Color swatch
    fill(p.col);
    rect(bx, by + 3, 10, 10);

    // Name
    fill(p.col);
    textSize(13);
    textAlign(PConstants.LEFT, PConstants.TOP);
    text(p.name, bx + 16, by + 2);
  }

  // Bottom text — pulsing
  float pulse = 0.5 + 0.5 * sin(stateTimer * 0.08);
  fill(255, 255, 0, 100 + 155 * pulse);
  textSize(14);
  textAlign(PConstants.CENTER, PConstants.CENTER);
  text(n + " BOTS ENTER  ·  1 BOT WINS", cx, height * 0.85);

  // "GET READY" flash near the end
  if (stateTimer > INTRO_FRAMES * 0.75) {
    float flash = ((stateTimer % 20) < 12) ? 1 : 0;
    fill(255, 0, 128, 255 * flash);
    textSize(22);
    text("GET READY", cx, height * 0.92);
  }
}

void drawCountdown() {
  // Dark overlay
  noStroke();
  fill(0, 160);
  rect(0, 0, width, height);

  float cx = width / 2.0;
  float cy = height / 2.0;

  // Determine which number to show
  int phase = stateTimer * 4 / COUNTDOWN_FRAMES;  // 0, 1, 2, 3
  String label;
  color numColor;

  switch (phase) {
    case 0:
      label = "3";
      numColor = color(0, 255, 255);  // cyan
      break;
    case 1:
      label = "2";
      numColor = color(255, 0, 255);  // magenta
      break;
    case 2:
      label = "1";
      numColor = color(255, 255, 0);  // yellow
      break;
    default:
      label = "GO!";
      numColor = color(255, 0, 128);  // hot pink
      break;
  }

  // Pulse/scale animation within each phase
  int phaseLen = COUNTDOWN_FRAMES / 4;
  int phaseT = stateTimer % phaseLen;
  float scale = 1.0 + 0.3 * (1.0 - (float) phaseT / phaseLen);  // starts big, shrinks

  // Shadow
  fill(0, 200);
  textSize(120 * scale);
  textAlign(PConstants.CENTER, PConstants.CENTER);
  text(label, cx + 3, cy + 3);

  // Main number
  fill(numColor);
  text(label, cx, cy);

  // Outer glow ring
  noFill();
  stroke(numColor, 60);
  strokeWeight(3);
  float ringSize = 200 * scale;
  ellipse(cx, cy, ringSize, ringSize);
  noStroke();
}
