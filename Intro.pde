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
  // Add visible area height so last name scrolls fully off before restart
  float totalH = contentH + (clipBot - clipTop);

  // Scroll speed: 0.8 px/frame, start at top of clip region, loop
  float rawScroll = stateTimer * 0.8;
  float scrollY = clipTop + 10 - (rawScroll % totalH);
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

  // ── Subtle dark overlay for readability ──
  noStroke();
  fill(0, 100);
  rect(0, height * 0.34, width, height * 0.62);

  // ── "CONTENDERS" — below the header ──
  textAlign(PConstants.CENTER, PConstants.CENTER);
  float titleY = height * 0.40;
  textSize(24);
  fill(255, 0, 128, 40);
  text("C O N T E N D E R S", cx + 1, titleY + 1);
  text("C O N T E N D E R S", cx - 1, titleY - 1);
  fill(255, 0, 128, 200 + 55 * fastPulse);
  text("C O N T E N D E R S", cx, titleY);

  // ── Dividers — cyan/magenta ──
  float divY = titleY + 22;
  stroke(0, 255, 255, 70 * pulse);
  strokeWeight(1);
  line(cx - 300, divY, cx + 300, divY);
  stroke(255, 0, 255, 35 * pulse);
  line(cx - 300, divY + 3, cx + 300, divY + 3);
  noStroke();

  // ── Bot roster — centered, spacious ──
  int rosterCols = (n > 14) ? 3 : (n > 7) ? 2 : 1;
  float colW = (n > 14) ? 340 : 400;
  int perCol = (int) ceil((float) n / rosterCols);
  float rosterX = cx - (rosterCols * colW) / 2;
  float startY = divY + 30;
  float availH = height * 0.80 - startY;
  float rowH = min(52, availH / max(1, perCol));

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
    textSize(13);
    text(nf(i + 1, 2) + ".", bx - 6, by + rowH / 2);

    // Color swatch
    float swatchSz = min(22, rowH - 14);
    fill(red(entry.col), green(entry.col), blue(entry.col), 35);
    noStroke();
    rect(bx, by + (rowH - swatchSz) / 2 - 1, swatchSz + 4, swatchSz + 4, 3);
    fill(entry.col);
    rect(bx + 2, by + (rowH - swatchSz) / 2 + 1, swatchSz, swatchSz);

    // Name — large
    textSize(20);
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