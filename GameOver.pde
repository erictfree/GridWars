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

// Full-screen game over — shown over the background after screenshot is taken
void drawGameOverFull() {
  if (beastMode) {
    drawBeastGameOver();
    return;
  }

  float cx = width / 2.0;
  float cy = height / 2.0;
  float pulse = 0.7 + 0.3 * sin(frameCount * 0.08);
  float fastPulse = 0.5 + 0.5 * sin(frameCount * 0.15);
  float t = frameCount * 0.05;

  // Sort bots by score descending
  ArrayList<Bot> sorted = new ArrayList<Bot>(bots);
  java.util.Collections.sort(sorted, new java.util.Comparator<Bot>() {
    public int compare(Bot a, Bot b) { return b.score - a.score; }
  });

  // ── Dark overlay ──
  noStroke();
  fill(0, 180);
  rect(0, 0, width, height);

  // ── CRT scanlines ──
  for (int y = 0; y < height; y += 3) {
    fill(0, 20);
    rect(0, y, width, 1);
  }

  // ── Continuous confetti ──
  if (frameCount % 4 == 0) {
    for (int i = 0; i < 4; i++) {
      float x = random(width);
      float y = random(-50, -10);
      float vx = random(-1.5, 1.5);
      float vy = random(2, 5);
      color c;
      float roll = random(1);
      if (roll < 0.3) c = sorted.get(0).col;
      else if (roll < 0.5) c = color(255, 215, 0);
      else if (roll < 0.65) c = color(255, 0, 128);
      else if (roll < 0.8) c = color(0, 255, 255);
      else c = color(255);
      Particle p = new Particle(x, y, vx, vy, c, random(140, 220), random(3, 7));
      p.gravity = 0.03;
      p.friction = 0.998;
      particles.add(p);
    }
  }

  // ── Panel ──
  float panelW = 680;
  float panelH = 500;
  float panelX = cx - panelW / 2;
  float panelY = cy - panelH / 2 - 10;
  drawArcadePanel(panelX, panelY, panelW, panelH, sorted.get(0).col, pulse);

  // ── "WINNERS" title ──
  textAlign(PConstants.CENTER, PConstants.CENTER);
  float winY = panelY + 48;
  drawNeonText("WINNERS", cx, winY, 56, color(255, 215, 0), t, fastPulse);

  // ── Divider ──
  float divY = winY + 40;
  drawRetroDiv(cx, divY, 250, pulse);

  // ── Podium ──
  drawPodium(sorted, cx, divY + 18, panelW, t, pulse, fastPulse);

  // ── Mascot ──
  if (mascotImg != null) {
    float mascotH = panelH * 0.55;
    float mascotW = mascotH * ((float) mascotImg.width / mascotImg.height);
    float mascotX = panelX - mascotW - 10;
    float mascotY = panelY + panelH - mascotH;
    mascotY += sin(frameCount * 0.04) * 5;
    tint(255, 220);
    image(mascotImg, mascotX, mascotY, mascotW, mascotH);
    noTint();
  }

  // ── "PRESS SPACE" ──
  float promptY = panelY + panelH - 32;
  drawFlashPrompt("PRESS SPACE TO PLAY AGAIN", cx, promptY, fastPulse);
}

// ── Beast mode game over ──────────────────────────────────────
void drawBeastGameOver() {
  float cx = width / 2.0;
  float cy = height / 2.0;
  float pulse = 0.7 + 0.3 * sin(frameCount * 0.08);
  float fastPulse = 0.5 + 0.5 * sin(frameCount * 0.15);
  float t = frameCount * 0.05;

  // Sort bots by score descending
  ArrayList<Bot> sorted = new ArrayList<Bot>(bots);
  java.util.Collections.sort(sorted, new java.util.Comparator<Bot>() {
    public int compare(Bot a, Bot b) { return b.score - a.score; }
  });

  // ── Dark overlay ──
  noStroke();
  fill(0, 180);
  rect(0, 0, width, height);

  // ── CRT scanlines ──
  for (int y = 0; y < height; y += 3) {
    fill(0, 20);
    rect(0, y, width, 1);
  }

  // ── Continuous confetti ──
  if (frameCount % 3 == 0) {
    for (int i = 0; i < 5; i++) {
      float x = random(width);
      float y = random(-50, -10);
      float vx = random(-1.5, 1.5);
      float vy = random(2, 5);
      color c;
      float roll = random(1);
      if (roll < 0.3) c = sorted.get(0).col;
      else if (roll < 0.5) c = color(255, 215, 0);
      else if (roll < 0.65) c = color(255, 0, 128);
      else if (roll < 0.8) c = color(0, 255, 255);
      else c = color(255);
      Particle p = new Particle(x, y, vx, vy, c, random(140, 220), random(3, 7));
      p.gravity = 0.03;
      p.friction = 0.998;
      particles.add(p);
    }
  }

  // ── Panel ──
  float panelW = 680;
  float panelH = 560;
  float panelX = cx - panelW / 2;
  float panelY = cy - panelH / 2 - 10;
  drawArcadePanel(panelX, panelY, panelW, panelH, sorted.get(0).col, pulse);

  // ── "BEAST MODE" label ──
  textAlign(PConstants.CENTER, PConstants.CENTER);
  float bmY = panelY + 34;
  textSize(18);
  fill(255, 0, 128, 40);
  text("B E A S T   M O D E", cx + 1, bmY + 1);
  text("B E A S T   M O D E", cx - 1, bmY - 1);
  fill(255, 0, 128, 200 + 55 * fastPulse);
  text("B E A S T   M O D E", cx, bmY);

  // ── Magenta/cyan divider ──
  float divY1 = bmY + 18;
  stroke(255, 0, 128, 100 * pulse);
  strokeWeight(1);
  line(cx - 230, divY1, cx + 230, divY1);
  stroke(0, 255, 255, 50 * pulse);
  line(cx - 230, divY1 + 3, cx + 230, divY1 + 3);
  noStroke();

  // ── "WINNERS" title ──
  float winY = divY1 + 42;
  drawNeonText("WINNERS", cx, winY, 56, color(255, 215, 0), t, fastPulse);

  // ── Double divider ──
  float divY2 = winY + 40;
  drawRetroDiv(cx, divY2, 270, pulse);

  // ── Podium ──
  drawPodium(sorted, cx, divY2 + 18, panelW, t, pulse, fastPulse);

  // ── Mascot ──
  if (mascotImg != null) {
    float mascotH = panelH * 0.55;
    float mascotW = mascotH * ((float) mascotImg.width / mascotImg.height);
    float mascotX = panelX - mascotW - 10;
    float mascotY = panelY + panelH - mascotH;
    mascotY += sin(frameCount * 0.04) * 5;
    tint(255, 220);
    image(mascotImg, mascotX, mascotY, mascotW, mascotH);
    noTint();
  }

  // ── "PRESS SPACE" ──
  float promptY = panelY + panelH - 32;
  drawFlashPrompt("PRESS SPACE TO PLAY AGAIN", cx, promptY, fastPulse);
}

// ═══════════════════════════════════════════════════════════════
// ── Shared retro drawing helpers ──────────────────────────────
// ═══════════════════════════════════════════════════════════════

// 80s arcade panel: dark fill + double border (cyan outer, magenta inner)
void drawArcadePanel(float px, float py, float pw, float ph, color accentCol, float pulse) {
  noStroke();
  // Soft outer glow
  for (int layer = 3; layer >= 0; layer--) {
    fill(red(accentCol), green(accentCol), blue(accentCol), 2 + layer);
    rect(px - layer * 8, py - layer * 8,
         pw + layer * 16, ph + layer * 16, 16 + layer * 4);
  }

  // Dark fill
  fill(5, 5, 15, 230);
  rect(px, py, pw, ph, 8);

  // Outer cyan border
  noFill();
  stroke(0, 255, 255, 130 + 50 * pulse);
  strokeWeight(3);
  rect(px, py, pw, ph, 8);

  // Inner magenta border
  stroke(255, 0, 255, 60 + 30 * pulse);
  strokeWeight(1);
  rect(px + 6, py + 6, pw - 12, ph - 12, 4);
  noStroke();

  // Corner diamonds
  fill(0, 255, 255, 150);
  drawDiamond(px + 12, py + 12, 4);
  drawDiamond(px + pw - 12, py + 12, 4);
  drawDiamond(px + 12, py + ph - 12, 4);
  drawDiamond(px + pw - 12, py + ph - 12, 4);
}

void drawDiamond(float x, float y, float r) {
  noStroke();
  quad(x, y - r, x + r, y, x, y + r, x - r, y);
}

// Neon text glow — uses SAME text size for all layers (offset-based, not size-based)
void drawNeonText(String label, float x, float y, float sz, color col, float t, float fastPulse) {
  textAlign(PConstants.CENTER, PConstants.CENTER);
  textSize(sz);

  // Glow: 4 offset passes at same size, decreasing alpha
  int[][] offsets = {{-2,-2},{2,-2},{-2,2},{2,2},{-3,0},{3,0},{0,-3},{0,3}};
  fill(red(col), green(col), blue(col), 15);
  for (int[] o : offsets) {
    text(label, x + o[0], y + o[1]);
  }

  // Mid glow: tighter offsets
  fill(red(col), green(col), blue(col), 35);
  text(label, x + 1, y + 1);
  text(label, x - 1, y - 1);

  // Core with shimmer
  float shimmer = 210 + 45 * sin(t * 2);
  fill(red(col), green(col), blue(col), shimmer);
  text(label, x, y);

  // White hot center
  fill(255, 255, 240, 50 + 35 * fastPulse);
  textSize(sz - 2);
  text(label, x, y);
}

// Double horizontal divider: cyan + magenta with end diamonds
void drawRetroDiv(float cx, float y, float halfW, float pulse) {
  stroke(0, 255, 255, 110 * pulse);
  strokeWeight(2);
  line(cx - halfW, y, cx + halfW, y);

  stroke(255, 0, 255, 60 * pulse);
  strokeWeight(1);
  line(cx - halfW, y + 4, cx + halfW, y + 4);
  noStroke();

  fill(0, 255, 255, 170);
  drawDiamond(cx - halfW - 4, y + 2, 3);
  drawDiamond(cx + halfW + 4, y + 2, 3);
}

// Flashing yellow arcade prompt
void drawFlashPrompt(String label, float cx, float y, float fastPulse) {
  if ((frameCount % 50) < 35) {
    textAlign(PConstants.CENTER, PConstants.CENTER);
    fill(255, 255, 0, 20);
    textSize(20);
    text(label, cx + 1, y + 1);
    fill(255, 255, 0, 170 + 75 * fastPulse);
    text(label, cx, y);
  }
}

// ── Podium: 1st place hero + 2nd/3rd/4th runners ────────────
void drawPodium(ArrayList<Bot> sorted, float cx, float startY,
                float panelW, float t, float pulse, float fastPulse) {
  int podiumCount = min(4, sorted.size());

  color gold   = color(255, 215, 0);
  color silver = color(200, 210, 230);
  color bronze = color(220, 140, 50);
  color fourth = color(120, 140, 160);
  color[] medalColors = { gold, silver, bronze, fourth };
  String[] placeLabels = { "1ST", "2ND", "3RD", "4TH" };

  // ════════════ 1ST PLACE ════════════
  if (podiumCount >= 1) {
    Bot b = sorted.get(0);

    // "CHAMPION" label in cyan
    float champLabelY = startY;
    textAlign(PConstants.CENTER, PConstants.CENTER);
    textSize(13);
    fill(0, 255, 255, 40);
    text("CHAMPION", cx + 1, champLabelY + 1);
    text("CHAMPION", cx - 1, champLabelY - 1);
    fill(0, 255, 255, 210);
    text("CHAMPION", cx, champLabelY);

    // Name — 40px with offset-based glow
    float nameY = champLabelY + 34;
    String name = displayName(b.name);
    textSize(40);

    // Glow offsets (same size)
    int[][] offsets = {{-2,-2},{2,-2},{-2,2},{2,2}};
    fill(red(b.col), green(b.col), blue(b.col), 18);
    for (int[] o : offsets) {
      text(name, cx + o[0], nameY + o[1]);
    }

    // Shadow
    fill(0, 180);
    text(name, cx + 2, nameY + 2);

    // Core name with shimmer
    float nameShimmer = 220 + 35 * sin(t * 2.5);
    fill(red(b.col), green(b.col), blue(b.col), nameShimmer);
    text(name, cx, nameY);

    // White highlight
    fill(255, 255, 255, 40 + 25 * fastPulse);
    textSize(38);
    text(name, cx, nameY);

    // Score in gold
    float scoreY = nameY + 32;
    float pct = (float) b.score / (COLS * ROWS) * 100;
    String scoreStr = nfc(b.score) + " CELLS  \u00b7  " + nf(pct, 1, 1) + "%";
    textSize(15);
    fill(255, 215, 0, 35);
    text(scoreStr, cx + 1, scoreY + 1);
    fill(255, 215, 0, 190);
    text(scoreStr, cx, scoreY);

    // Thin separator
    float sepY = scoreY + 18;
    stroke(255, 215, 0, 35);
    strokeWeight(1);
    line(cx - 160, sepY, cx + 160, sepY);
    noStroke();
  }

  // ════════════ 2ND, 3RD, 4TH ════════════
  float[] runnerSizes  = { 26, 22, 18 };
  float[] scoreFontSz  = { 12, 11, 10 };
  float runnerStartY   = startY + 108;
  float runnerSpacing   = 62;

  for (int i = 1; i < podiumCount; i++) {
    Bot b = sorted.get(i);
    float rowTopY = runnerStartY + (i - 1) * runnerSpacing;
    color medal = medalColors[i];
    float nSize = runnerSizes[i - 1];
    String name = displayName(b.name);

    // Rank label — aligned with name
    textAlign(PConstants.RIGHT, PConstants.CENTER);
    fill(red(medal), green(medal), blue(medal), 180);
    textSize(11);
    text(placeLabels[i], cx - panelW * 0.28, rowTopY);

    // Name — centered, at top of row
    textAlign(PConstants.CENTER, PConstants.CENTER);
    textSize(nSize);

    // Subtle glow for 2nd only
    if (i == 1) {
      fill(red(b.col), green(b.col), blue(b.col), 15);
      text(name, cx + 1, rowTopY + 1);
      text(name, cx - 1, rowTopY - 1);
    }

    // Shadow
    fill(0, 140);
    text(name, cx + 1, rowTopY + 1);

    // Core name
    fill(b.col);
    textSize(nSize - 1);
    text(name, cx, rowTopY);

    // Score — fixed gap below name baseline
    float scoreLineY = rowTopY + nSize / 2 + 12;
    float pct = (float) b.score / (COLS * ROWS) * 100;
    fill(red(medal), green(medal), blue(medal), 130);
    textSize(scoreFontSz[i - 1]);
    text(nfc(b.score) + " CELLS  \u00b7  " + nf(pct, 1, 1) + "%", cx, scoreLineY);
  }
}