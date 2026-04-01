// ── Intro & Countdown screens ───────────────────────────────

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
  int n = painters.size();
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

    BasePainter p = painters.get(i);

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
