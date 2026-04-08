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

// ── Side tips for credits scroll ───────────────────────────────
String[] sideTips = {
  "> GAME TOO LARGE?\n  OPEN GridWars.pde\n  AND SET HIGH_RES\n  = false FOR A\n  SMALLER WINDOW",
  "> SAVE THE PODIUM!\n  SET THE FLAG\n  SAVE_SCREENSHOTS\n  = true IN\n  GridWars.pde TO\n  CAPTURE ENDINGS",
  "> PRESS [R]\n  RESTART YOUR\n  TEST MATCH AND\n  GO BACK TO THE\n  SPLASH SCREEN",
  "> PRESS [Z]\n  TOGGLE MAGNIFIER\n  ZOOMS IN ON THE\n  LEADING BOT SO\n  YOU CAN WATCH\n  THE ACTION CLOSE",
  "> PRESS [L]\n  TOGGLE THE LIVE\n  LEADERBOARD ON\n  THE RIGHT SIDE\n  DURING GAMEPLAY",
  "> PRESS [D]\n  DIM MODE FADES\n  NON-HALO BOTS\n  SO YOU CAN TRACK\n  YOUR BOT EASILY",
  "> getFreeDirs()\n  RETURNS A LIST OF\n  ALL DIRECTIONS\n  WHERE ADJACENT\n  CELLS ARE FREE",
  "> canClaim(dir)\n  RETURNS TRUE IF\n  THE CELL IN THAT\n  DIRECTION IS\n  UNCLAIMED",
  "> getProgress()\n  FLOAT FROM 0.0\n  AT THE START TO\n  1.0 AT THE END\n  OF THE MATCH",
  "> getNearestBot()\n  FIND THE CLOSEST\n  OPPONENT BOT BY\n  MANHATTAN DIST\n  AVOID OR CHASE!",
  "> GRID[ROW][COL]\n  SAME AS [Y][X]\n  ROW FIRST ALWAYS\n  YOUR CELL IS AT\n  grid[this.y]\n       [this.x]",
  "> INSTANCE VARS\n  ADD FIELDS TO\n  YOUR BOT CLASS\n  THEY PERSIST\n  BETWEEN MOVES",
  "> peekCell(dir)\n  CHECK WHO OWNS\n  THE CELL NEXT\n  TO YOU: -1 FREE\n  -2 OUT OF BOUNDS",
  "> TestConfig.pde\n  SET 3RD ARG TRUE\n  IN addBot() FOR\n  A TRACKING HALO\n  AROUND YOUR BOT",
  "> BOT POSITION\n  this.x = COLUMN\n  this.y = ROW\n  this.score = YOUR\n  CLAIMED CELLS",
  "> NO ELIMINATION\n  ALL BOTS PLAY\n  THE FULL GAME\n  HIGHEST SCORE\n  AT THE END WINS",
  "> getNextMove()\n  OVERRIDE THIS ONE\n  METHOD TO PLAY\n  RETURN UP DOWN\n  LEFT OR RIGHT",
  "> randomDir()\n  RETURNS A RANDOM\n  DIRECTION: GREAT\n  AS A FALLBACK\n  WHEN NO FREE CELLS",
  "> countUnclaimed()\n  TOTAL FREE CELLS\n  LEFT ON THE GRID\n  PLAN YOUR MOVES\n  ACCORDINGLY",
  "> game.bots\n  FULL LIST OF ALL\n  BOTS IN THE MATCH\n  READ THEIR SCORE\n  POSITION + COLOR",
  "> PRESS [M]\n  TOGGLE MUSIC\n  ON AND OFF\n  MUTE ICON SHOWS\n  CURRENT STATE",
  "> PRESS [T]\n  CYCLE TERRAIN:\n  GREY  DIG DUG\n  TRON  FROGGER\n  PAC-MAN GALAGA\n  SKY + CLOUDS"
};

void drawBeastSplash() {
  float cx = width / 2.0;
  float fastPulse = 0.5 + 0.5 * sin(stateTimer * 0.2);

  // ── Scanline overlay ──
  noStroke();
  for (int y = 0; y < height; y += 4) {
    fill(0, 15);
    rect(0, y, width, 2);
  }

  // ── Credits scroll — start lower to clear beast mode header ──
  drawCreditsScroll(cx, fastPulse, height * 0.48);
}

void drawTestIntro() {
  float cx = width / 2.0;
  float fastPulse = 0.5 + 0.5 * sin(stateTimer * 0.2);

  // ── Scanline overlay ──
  noStroke();
  for (int y = 0; y < height; y += 4) {
    fill(0, 15);
    rect(0, y, width, 2);
  }

  if (testIntroPhase == 0) {
    drawCreditsScroll(cx, fastPulse, height * 0.34);
  } else {
    contenderRevealTimer++;
    drawContenderReveal(cx, fastPulse);
    // Auto-start after 180 frames (~3 seconds)
    if (contenderRevealTimer > 180) {
      gameState = 1;
      playTestMusic();
      testIntroPhase = 0;
    }
  }
}

// ── Phase 0: Star Wars-style credits scroll ─────────────────
void drawCreditsScroll(float cx, float fastPulse, float clipTop) {
  textAlign(PConstants.CENTER, PConstants.CENTER);

  // Clip region — below header, above controls
  float clipBot = height * 0.90;
  clip(0, (int) clipTop, width, (int)(clipBot - clipTop));

  float lineH = 34;
  float sectionGap = 50;
  float studentLineH = lineH - 4;

  // Calculate total content height — must match actual drawing below
  float contentH = (lineH + 10) + lineH + sectionGap       // title + subtitle + gap
    + lineH + lineH + sectionGap                             // instructor section
    + lineH + (creditsStaff.length - 1) * lineH + sectionGap // TAs
    + lineH + creditsStudents.length * studentLineH;         // students
  // Full cycle: content scrolls from bottom to off the top, then restarts
  float visibleH = clipBot - clipTop;
  float totalH = contentH + visibleH + 60;

  // Scroll speed: 0.8 px/frame, enter from bottom, scroll upward
  float rawScroll = stateTimer * 0.8;
  float scrollY = clipBot - (rawScroll % totalH);
  float y = scrollY;

  // ── Title ──
  textSize(28);
  fill(255, 215, 0, 40);
  text("A E T 3 1 0", cx + 1, y + 1);
  fill(255, 215, 0);
  text("A E T 3 1 0", cx, y);
  y += lineH + 10;

  textSize(14);
  fill(0, 255, 255);
  text("Grid Wars  \u00b7  Spring 2026", cx, y);
  y += sectionGap;

  // ── Instructor ──
  textSize(12);
  fill(255, 215, 0, 150);
  text("I N S T R U C T O R", cx, y);
  y += lineH;

  textSize(20);
  fill(255, 215, 0);
  text("Eric Freeman, PhD", cx, y);
  y += sectionGap;

  // ── Teaching Assistants ──
  textSize(12);
  fill(0, 255, 255, 150);
  text("T E A C H I N G   A S S I S T A N T S", cx, y);
  y += lineH;

  textSize(18);
  fill(0, 255, 255);
  for (int i = 1; i < creditsStaff.length; i++) {
    text(creditsStaff[i], cx, y);
    y += lineH;
  }
  y += sectionGap - lineH;

  // ── Students ──
  textSize(12);
  fill(255, 0, 128, 150);
  text("S T U D E N T S", cx, y);
  y += lineH;

  textSize(16);
  fill(180, 190, 200);
  for (String name : creditsStudents) {
    text(name, cx, y);
    y += lineH - 4;
  }

  // Remove clip before drawing fixed UI
  noClip();

  // ── Side tips (retro terminal style) ──
  drawSideTips(clipTop, clipBot);

  // ── "PRESS SPACEBAR" fixed at bottom ──
  if ((frameCount % 50) < 35) {
    textAlign(PConstants.CENTER, PConstants.CENTER);
    fill(255, 255, 0, 20);
    textSize(26);
    text("PRESS SPACEBAR", cx + 1, height * 0.95 + 1);
    fill(255, 255, 0, 170 + 75 * fastPulse);
    text("PRESS SPACEBAR", cx, height * 0.95);
  }
}

// ── Phase 1: Contenders reveal (after space pressed) ────────
void drawContenderReveal(float cx, float fastPulse) {
  float pulse = 0.7 + 0.3 * sin(contenderRevealTimer * 0.08);
  int n = testBotList.size();

  // ── Bot roster — top-aligned below header ──
  int rosterCols = (n > 14) ? 3 : (n > 7) ? 2 : 1;
  float colW = (n > 14) ? 340 : 400;
  int perCol = (int) ceil((float) n / rosterCols);
  float rosterX = cx - (rosterCols * colW) / 2;
  float startY = height * 0.38;
  float botY = height * 0.80;
  float availH = botY - startY;

  // Scale up for small groups
  float maxRowH = n <= 4 ? 70 : 52;
  float rowH = min(maxRowH, availH / max(1, perCol));
  float nameSize = n <= 6 ? 24 : 20;
  float swatchBase = n <= 6 ? 28 : 22;
  float rankSize = n <= 6 ? 15 : 13;

  int botsToShow = min(n, (int)(contenderRevealTimer * n / 40.0) + 1);

  for (int i = 0; i < botsToShow; i++) {
    int c = i / perCol;
    int row = i % perCol;
    float bx = rosterX + c * colW + 50;
    float by = startY + row * rowH;
    BotEntry entry = testBotList.get(i);

    // Entrance flash
    int appearFrame = (int)(i * 40.0 / n);
    int age = contenderRevealTimer - appearFrame;
    if (age >= 0 && age < 10) {
      float flash = 1.0 - (float) age / 10;
      fill(entry.col, flash * 60);
      noStroke();
      rect(bx - 12, by + 2, colW - 70, rowH - 6, 4);
    }

    // Rank number
    textAlign(PConstants.RIGHT, PConstants.CENTER);
    fill(0, 200, 255, 80);
    textSize(rankSize);
    text(nf(i + 1, 2) + ".", bx - 6, by + rowH / 2);

    // Color swatch
    float swatchSz = min(swatchBase, rowH - 14);
    fill(red(entry.col), green(entry.col), blue(entry.col), 35);
    noStroke();
    rect(bx, by + (rowH - swatchSz) / 2 - 1, swatchSz + 4, swatchSz + 4, 3);
    fill(entry.col);
    rect(bx + 2, by + (rowH - swatchSz) / 2 + 1, swatchSz, swatchSz);

    // Name
    textSize(nameSize);
    textAlign(PConstants.LEFT, PConstants.CENTER);
    fill(0, 140);
    text(displayName(entry.name), bx + swatchSz + 14, by + rowH / 2 + 1);
    fill(entry.col);
    text(displayName(entry.name), bx + swatchSz + 13, by + rowH / 2);
  }

  // ── Tagline ──
  float tagY = height * 0.84;
  textAlign(PConstants.CENTER, PConstants.CENTER);
  fill(0, 120);
  textSize(18);
  text(n + " BOTS ENTER  \u00b7  1 BOT WINS", cx + 2, tagY + 2);
  fill(255, 200);
  text(n + " BOTS ENTER  \u00b7  1 BOT WINS", cx, tagY);

  // ── "GET READY" flashing ──
  if ((contenderRevealTimer % 45) < 30) {
    textSize(26);
    fill(255, 255, 0, 25);
    text("GET READY", cx + 1, height * 0.91 + 1);
    fill(255, 255, 0, 180 + 75 * fastPulse);
    text("GET READY", cx, height * 0.91);
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

// ── Retro terminal tips in credit scroll margins ───────────────
void drawSideTips(float clipTop, float clipBot) {
  int tipFrames = 300;   // 5 sec per tip at 60fps
  int typeRate = 2;      // frames per character
  int fadeFrames = 30;   // fade in/out duration

  // Left and right cycle independently — offset by half a cycle
  int leftCycle   = stateTimer / tipFrames;
  int leftElapsed = stateTimer % tipFrames;
  int rightShift  = tipFrames / 2;
  int rightCycle   = (stateTimer + rightShift) / tipFrames;
  int rightElapsed = (stateTimer + rightShift) % tipFrames;

  // Pick tips — multiplier 7 scatters the order
  int leftIdx  = (leftCycle * 7) % sideTips.length;
  int rightIdx = (rightCycle * 7 + sideTips.length / 2) % sideTips.length;
  if (rightIdx == leftIdx) rightIdx = (rightIdx + 1) % sideTips.length;

  // Pseudo-random y positions per tip (deterministic from index)
  float yPad = 140;  // room for tip height + margin
  float yMin = clipTop + 20;
  float yMax = clipBot - yPad;
  float leftYt  = abs(sin(leftIdx * 2.39 + 0.7));
  float rightYt = abs(sin(rightIdx * 3.17 + 1.3));
  float leftY  = lerp(yMin, yMax, leftYt);
  float rightY = lerp(yMin, yMax, rightYt);

  // Left tip — fade & type
  float leftAlpha = 1.0;
  if (leftElapsed < fadeFrames) leftAlpha = (float) leftElapsed / fadeFrames;
  else if (leftElapsed > tipFrames - fadeFrames) leftAlpha = (float)(tipFrames - leftElapsed) / fadeFrames;
  int leftChars = leftElapsed / typeRate;
  drawTypedTip(sideTips[leftIdx], 25, leftY, leftChars, leftAlpha);

  // Right tip — fade & type
  float rightAlpha = 1.0;
  if (rightElapsed < fadeFrames) rightAlpha = (float) rightElapsed / fadeFrames;
  else if (rightElapsed > tipFrames - fadeFrames) rightAlpha = (float)(tipFrames - rightElapsed) / fadeFrames;
  int rightChars = rightElapsed / typeRate;
  drawTypedTip(sideTips[rightIdx], width - 330, rightY, rightChars, rightAlpha);
}

void drawTypedTip(String tip, float x, float y, int maxChars, float alpha) {
  String[] lines = split(tip, '\n');
  textSize(12);
  textAlign(PConstants.LEFT, PConstants.TOP);

  float lineH = 22;
  int charsSoFar = 0;

  // Green phosphor terminal color
  int ga = (int)(alpha * 150);
  int gg = (int)(alpha * 35);

  for (int i = 0; i < lines.length; i++) {
    String line = lines[i];
    float ly = y + i * lineH;

    if (charsSoFar >= maxChars) break;

    String visible;
    boolean showCursor = false;
    if (charsSoFar + line.length() <= maxChars) {
      visible = line;
      charsSoFar += line.length();
    } else {
      int partial = maxChars - charsSoFar;
      visible = line.substring(0, partial);
      charsSoFar = maxChars;
      showCursor = true;
    }

    // Glow
    fill(0, 255, 70, gg);
    text(visible, x + 1, ly + 1);
    // Main text
    fill(0, 255, 70, ga);
    text(visible, x, ly);

    // Blinking cursor
    if (showCursor && (frameCount / 12) % 2 == 0) {
      float cursorX = x + textWidth(visible);
      fill(0, 255, 70, ga);
      text("_", cursorX, ly);
    }
  }
}