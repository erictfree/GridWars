void drawHUD() {
  float hx = 0;
  float hy = ROWS * CELL;
  float hw = COLS * CELL;  // grid width only (sidebar covers the rest)
  float hh = BOT;

  // Background
  noStroke();
  fill(hudBg);
  rect(hx, hy, hw, hh);

  // Top edge highlight
  stroke(40, 44, 65);
  strokeWeight(1);
  line(hx, hy, hw, hy);
  noStroke();

  // ── Progress bar ──────────────────────────────────────────
  float barX = 14;
  float barY = hy + 12;
  float barW = hw - 120;
  float barH = 8;
  float progress = constrain((float) stepCount / LIMIT, 0, 1);

  // Bar track
  fill(28, 30, 44);
  rect(barX, barY, barW, barH, 4);

  // Bar fill — blue → red with glow
  color barStart = color(55, 120, 220);
  color barEnd   = color(220, 55, 55);
  color barColor = lerpColor(barStart, barEnd, progress);

  // Glow behind bar
  float glowPulse = 0.7 + 0.3 * sin(frameCount * 0.08);
  fill(barColor, 30 * glowPulse);
  rect(barX, barY - 2, barW * progress + 4, barH + 4, 5);

  // Fill
  fill(barColor);
  rect(barX, barY, barW * progress, barH, 4);

  // Bright leading edge
  if (progress > 0.01 && !gameOver) {
    float edgeX = barX + barW * progress;
    fill(255, 150 * glowPulse);
    ellipse(edgeX, barY + barH / 2, 6, barH + 4);
  }

  // ── Step counter ──────────────────────────────────────────
  fill(100, 105, 130);
  textSize(11);
  textAlign(PConstants.LEFT, PConstants.TOP);
  text("Step " + nfc(stepCount) + " / " + nfc(LIMIT), barX, barY + 16);

  // ── Restart button ────────────────────────────────────────
  float btnX = hw - 94;
  float btnY = hy + 11;
  float btnW = 80;
  float btnH = 30;

  boolean hover = mouseX >= btnX && mouseX <= btnX + btnW &&
                  mouseY >= btnY && mouseY <= btnY + btnH;

  // Button glow on hover
  if (hover) {
    fill(80, 90, 140, 40);
    rect(btnX - 2, btnY - 2, btnW + 4, btnH + 4, 7);
  }

  fill(hover ? color(60, 65, 90) : color(38, 40, 58));
  noStroke();
  rect(btnX, btnY, btnW, btnH, 5);

  // Subtle border
  stroke(hover ? color(100, 110, 160) : color(55, 58, 75));
  strokeWeight(0.5);
  rect(btnX, btnY, btnW, btnH, 5);
  noStroke();

  fill(hover ? 240 : 140);
  textSize(11);
  textAlign(PConstants.CENTER, PConstants.CENTER);
  text("RESTART", btnX + btnW / 2, btnY + btnH / 2 - 1);
}
