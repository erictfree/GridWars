// ── Intro & Countdown screens ───────────────────────────────

// ── Credits data ────────────────────────────────────────────
String[] creditsHeader = { "AET310 GRID WARS" };
String[] creditsStaff = {
  "Eric Freeman, PhD, Instructor",
  "Ella Gault (Head UA)",
  "Tanmayee Bharadwaj",
  "Anoushka Chigullapalli",
  "Minjoo Jang",
  "Kel Shang"
};
String[] creditsStudents = {
  "Jahbari Allsop-Marsham", "Penny Anderson", "Jiro Andrus",
  "Camila Barcelata", "Hayden Beatty", "Ishan Bhakta",
  "Marnie Binfield", "Nathan Blackwell", "Julien Block",
  "Alyssa Bobbitt", "Madison Booker", "Taylor Buehler",
  "Ana Caballero Hernandez", "Carlo Calixco", "Dana Cano",
  "Adrian Cardenas", "Jeremiah Carranza", "Michaela Cauthen",
  "Addison Ceritelli", "Aiden Cerna", "Devon Chau",
  "Domenica Collaro", "Zenith Collins", "Nathan Dart",
  "Hailey De La Rosa", "Oz Dieckmann", "Martin Ding",
  "Michael Edson", "Skylar Evans", "Neela Farzin",
  "Alexa Field", "Bryan Flores", "Elena Garcia",
  "Jordyn Gibson", "Arielle Hernandez", "Luna Hernandez",
  "Wing Huang", "Angelina Ibarra", "Christian Ibarra",
  "Chima John", "Avery Johnson", "Genae Johnson",
  "Nicholas Kahler", "Kodi Khiraoui", "Daniel Kim",
  "Jasmine Kim", "Asher Kime", "Kjartan Knutson-Ho",
  "Ozzie Lask", "Hannah Lee", "Kade Lee",
  "Vincent Lombardo", "Jeremiah Lopez", "Davis Luce",
  "Christopher Macartney-Filgate", "Liana Manchala", "Ryan Marquez",
  "Rodolfo Martinez Martine", "Emma McGlumphy", "Alba Medina",
  "Raaj Srihan Mekala", "Nola Moore", "Paulina Mroue",
  "Johnson Nguyen", "Maya Nguyen", "Ciara Noriega",
  "Kyla Oldacre", "Sofia Ortiz", "Genieve Oviedo",
  "Marcelo Pacheco", "LB Page", "Minho Park",
  "Anshu Patel", "Yan Pena-Akens", "Victoria Perez",
  "Siddharth Ramalingam", "Analiese Ramirez", "Delilah Reiss",
  "Abigale Reyna", "Ava Rogaliner", "Jack Saladino",
  "Vianae Salinas", "Matlyn Schwebs", "Sophia Scott",
  "Ifeoluwa Senu-Oke", "Tyler Siebeneicher", "Melissa Strangis",
  "Julian Sullivan", "Lucy Townsend", "Gabriel Tran",
  "Parker Tumminello", "Conner Valdez", "Valeria Valles",
  "Emma Varan", "William Volz", "Emily Yang",
  "Emily Yao", "Hengyu Zhou"
};

void drawBeastSplash() {
  float cx = width / 2.0;
  float fastPulse = 0.5 + 0.5 * sin(stateTimer * 0.2);

  // Subtitle
  fill(0, 160);
  textSize(20);
  textAlign(PConstants.CENTER, PConstants.CENTER);
  text(tournamentBotList.size() + " BOTS  \u00b7  ONE GRID  \u00b7  NO MERCY", cx + 2, height * 0.68 + 2);
  fill(255, 220);
  text(tournamentBotList.size() + " BOTS  \u00b7  ONE GRID  \u00b7  NO MERCY", cx, height * 0.68);

  // "PRESS SPACE" — big flashing
  boolean blink = (stateTimer % 45) < 30;
  if (blink) {
    fill(255, 255, 0, 30);
    textSize(28);
    text("PRESS SPACE TO UNLEASH", cx, height * 0.90);
    fill(255, 255, 0, 200 + 55 * fastPulse);
    textSize(26);
    text("PRESS SPACE TO UNLEASH", cx, height * 0.90);
  }
}

void drawTestIntro() {
  float cx = width / 2.0;
  float pulse = 0.7 + 0.3 * sin(stateTimer * 0.08);
  float fastPulse = 0.5 + 0.5 * sin(stateTimer * 0.2);
  float t = stateTimer * 0.05;
  int n = testBotList.size();

  // ── Scanline overlay ──
  noStroke();
  for (int y = 0; y < height; y += 4) {
    fill(0, 15);
    rect(0, y, width, 2);
  }

  // ── Arcade panel ──
  int rosterCols = (n > 14) ? 3 : (n > 7) ? 2 : 1;
  float colW = (n > 14) ? 260 : 280;
  float panelW = max(680, rosterCols * colW + 100);
  float panelH = height * 0.48;
  float panelX = cx - panelW / 2;
  float panelY = height * 0.32;
  drawArcadePanel(panelX, panelY, panelW, panelH, arcadeBlue, pulse);

  // ── "CONTENDERS" title — neon hot pink ──
  textAlign(PConstants.CENTER, PConstants.CENTER);
  float titleY = panelY + 40;
  drawNeonText("C O N T E N D E R S", cx, titleY, 22, color(255, 0, 128), t, fastPulse);

  // ── Divider ──
  float divY = titleY + 24;
  drawRetroDiv(cx, divY, panelW / 2 - 40, pulse);

  // ── Bot roster ──
  int perCol = (int) ceil((float) n / rosterCols);
  float rosterX = cx - (rosterCols * colW) / 2;
  float startY = divY + 20;
  float rowH = min(36, (panelY + panelH - startY - 100) / max(1, perCol));

  int botsToShow = min(n, (int)(stateTimer * n / 50.0) + 1);

  for (int i = 0; i < botsToShow; i++) {
    int c = i / perCol;
    int row = i % perCol;
    float bx = rosterX + c * colW + 30;
    float by = startY + row * rowH;
    BotEntry entry = testBotList.get(i);

    // Entrance flash
    int appearFrame = (int)(i * 50.0 / n);
    int age = stateTimer - appearFrame;
    if (age >= 0 && age < 8) {
      float flash = 1.0 - (float) age / 8;
      fill(entry.col, flash * 50);
      noStroke();
      rect(bx - 8, by - 2, colW - 40, rowH - 2, 4);
    }

    // Rank number — dim cyan
    textAlign(PConstants.RIGHT, PConstants.TOP);
    fill(0, 200, 255, 100);
    textSize(11);
    text(nf(i + 1, 2) + ".", bx - 2, by + 5);

    // Color swatch with glow
    fill(red(entry.col), green(entry.col), blue(entry.col), 40);
    noStroke();
    rect(bx, by + 1, 22, 22, 2);
    fill(entry.col);
    rect(bx + 2, by + 3, 18, 18);

    // Name
    textSize(15);
    textAlign(PConstants.LEFT, PConstants.TOP);
    fill(0, 160);
    text(displayName(entry.name), bx + 29, by + 4);
    fill(entry.col);
    text(displayName(entry.name), bx + 28, by + 3);
  }

  // ── "VS" badge for 2-column layout ──
  if (rosterCols == 2 && botsToShow >= 2) {
    float vsY = startY + (perCol * rowH) / 2 - 10;
    fill(0, 140);
    noStroke();
    ellipse(cx, vsY, 46, 46);
    stroke(255, 255, 0, 150 * pulse);
    strokeWeight(2);
    noFill();
    ellipse(cx, vsY, 46, 46);
    noStroke();
    fill(255, 255, 0, 210 * pulse);
    textSize(14);
    textAlign(PConstants.CENTER, PConstants.CENTER);
    text("VS", cx, vsY);
  }

  // ── Tagline ──
  float tagY = panelY + panelH - 60;
  textAlign(PConstants.CENTER, PConstants.CENTER);
  fill(0, 140);
  textSize(18);
  text(n + " BOTS ENTER  \u00b7  1 BOT WINS", cx + 2, tagY + 2);
  fill(255, 210);
  text(n + " BOTS ENTER  \u00b7  1 BOT WINS", cx, tagY);

  // ── "PRESS SPACE" ──
  float promptY = panelY + panelH - 28;
  drawFlashPrompt("PRESS SPACE TO START", cx, promptY, fastPulse);

  // ── Controls hint ──
  fill(70);
  textSize(10);
  textAlign(PConstants.CENTER, PConstants.CENTER);
  text("R = RESTART  |  T = TOURNAMENT  |  L = LEADERBOARD", cx, panelY + panelH + 18);

  // ── Credits ticker at bottom ──
  drawCreditsTicker();
}

// ── Credits ticker — scrolling strip at bottom of screen ────
void drawCreditsTicker() {
  float stripH = 28;
  float stripY = height - stripH;
  float textY = stripY + stripH / 2;

  // Dark strip background
  noStroke();
  fill(0, 200);
  rect(0, stripY, width, stripH);

  // Thin cyan line on top
  stroke(0, 255, 255, 80);
  strokeWeight(1);
  line(0, stripY, width, stripY);
  noStroke();

  // Measure total width on first call
  textSize(10);
  float sep = textWidth("  \u2605  ");
  float totalW = measureTickerWidth(sep);

  // Init scroll position
  if (creditsScrollX == 0 && stateTimer < 2) {
    creditsScrollX = width;
  }

  // Scroll
  creditsScrollX -= 1.0;
  if (creditsScrollX < -totalW) {
    creditsScrollX += totalW;
  }

  // Draw twice for seamless loop
  drawTickerPass(creditsScrollX, textY, sep);
  drawTickerPass(creditsScrollX + totalW, textY, sep);
}

float measureTickerWidth(float sep) {
  textSize(10);
  float w = 0;
  for (String s : creditsHeader)  w += textWidth(s) + sep;
  for (String s : creditsStaff)   w += textWidth(s) + sep;
  for (String s : creditsStudents) w += textWidth(s) + sep;
  return w;
}

void drawTickerPass(float startX, float y, float sep) {
  textSize(10);
  textAlign(PConstants.LEFT, PConstants.CENTER);
  float x = startX;

  color gold   = color(255, 215, 0);
  color cyan   = color(0, 220, 255);
  color silver = color(150, 160, 175);
  color dimPink = color(255, 0, 128, 80);

  // Header
  for (String s : creditsHeader) {
    if (x + textWidth(s) > 0 && x < width) {
      fill(gold);
      text(s, x, y);
    }
    x += textWidth(s);
    if (x + sep > 0 && x < width) {
      fill(dimPink);
      text("  \u2605  ", x, y);
    }
    x += sep;
  }

  // Staff
  for (String s : creditsStaff) {
    if (x + textWidth(s) > 0 && x < width) {
      fill(cyan);
      text(s, x, y);
    }
    x += textWidth(s);
    if (x + sep > 0 && x < width) {
      fill(dimPink);
      text("  \u2605  ", x, y);
    }
    x += sep;
  }

  // Students
  for (String s : creditsStudents) {
    if (x + textWidth(s) > 0 && x < width) {
      fill(silver);
      text(s, x, y);
    }
    x += textWidth(s);
    if (x + sep > 0 && x < width) {
      fill(dimPink);
      text("  \u2605  ", x, y);
    }
    x += sep;
  }
}

// ── Tournament intro (used during bracket play) ─────────────
void drawIntro() {
  noStroke();
  fill(0, 140);
  rect(0, 0, width, height);

  float cx = width / 2.0;
  float startY = height * 0.28;

  fill(arcadeBlue);
  textSize(18);
  textAlign(PConstants.CENTER, PConstants.CENTER);
  text("C O N T E N D E R S", cx, startY - 30);

  stroke(arcadeBlue, 80);
  strokeWeight(1);
  line(cx - 200, startY - 10, cx + 200, startY - 10);
  noStroke();

  int n = bots.size();
  int cols = 3;
  int perCol = (int) ceil((float) n / cols);
  float colW = 220;
  float rowH = 22;
  float rosterX = cx - (cols * colW) / 2;

  int botsToShow = min(n, (int)(stateTimer * n / (float)(INTRO_FRAMES * 0.7)));

  for (int i = 0; i < botsToShow; i++) {
    int col = i / perCol;
    int row = i % perCol;
    float bx = rosterX + col * colW + 10;
    float by = startY + row * rowH;

    Bot p = bots.get(i);

    fill(p.col);
    rect(bx, by + 3, 10, 10);

    fill(p.col);
    textSize(13);
    textAlign(PConstants.LEFT, PConstants.TOP);
    text(p.name, bx + 16, by + 2);
  }

  float pulse = 0.5 + 0.5 * sin(stateTimer * 0.08);
  fill(255, 255, 0, 100 + 155 * pulse);
  textSize(14);
  textAlign(PConstants.CENTER, PConstants.CENTER);
  text(n + " BOTS ENTER  \u00b7  1 BOT WINS", cx, height * 0.85);

  if (stateTimer > INTRO_FRAMES * 0.75) {
    float flash = ((stateTimer % 20) < 12) ? 1 : 0;
    fill(255, 0, 128, 255 * flash);
    textSize(22);
    text("GET READY", cx, height * 0.92);
  }
}

void drawCountdown() {
  noStroke();
  fill(0, 160);
  rect(0, 0, width, height);

  float cx = width / 2.0;
  float cy = height / 2.0;

  int phase = stateTimer * 4 / COUNTDOWN_FRAMES;
  String label;
  color numColor;

  switch (phase) {
    case 0:  label = "3"; numColor = color(0, 255, 255); break;
    case 1:  label = "2"; numColor = color(255, 0, 255); break;
    case 2:  label = "1"; numColor = color(255, 255, 0); break;
    default: label = "GO!"; numColor = color(255, 0, 128); break;
  }

  int phaseLen = COUNTDOWN_FRAMES / 4;
  int phaseT = stateTimer % phaseLen;
  float scale = 1.0 + 0.3 * (1.0 - (float) phaseT / phaseLen);

  fill(0, 200);
  textSize(120 * scale);
  textAlign(PConstants.CENTER, PConstants.CENTER);
  text(label, cx + 3, cy + 3);

  fill(numColor);
  text(label, cx, cy);

  noFill();
  stroke(numColor, 60);
  strokeWeight(3);
  float ringSize = 200 * scale;
  ellipse(cx, cy, ringSize, ringSize);
  noStroke();
}
