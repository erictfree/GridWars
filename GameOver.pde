// Full-screen game over — shown over the background after screenshot is taken
void drawGameOverFull() {
  // CRT scanlines
  noStroke();
  for (int y = 0; y < height; y += 4) {
    fill(0, 12);
    rect(0, y, width, 2);
  }

  int gridW = COLS * CELL + INSET * 2;
  float cx = MARGIN + gridW / 2.0;
  float cy = height / 2.0;
  float pulse = 0.7 + 0.3 * sin(frameCount * 0.1);

  // Find winner
  Bot winner = bots.get(0);
  for (Bot p : bots) {
    if (p.score > winner.score) winner = p;
  }

  // "GAME OVER" — massive red neon with glow
  boolean blink = (frameCount % 40) < 30;
  if (blink) {
    textAlign(PConstants.CENTER, PConstants.CENTER);

    // Glow layers
    fill(255, 0, 0, 15);
    textSize(62);
    text("GAME OVER", cx + 3, cy - 80 + 3);
    text("GAME OVER", cx - 3, cy - 80 - 3);

    fill(255, 0, 0, 30);
    textSize(60);
    text("GAME OVER", cx, cy - 80);

    // Main
    fill(255, 0, 0, 220 + 35 * pulse);
    textSize(58);
    text("GAME OVER", cx, cy - 80);
  }

  // Neon divider — white/gold
  for (int layer = 2; layer >= 0; layer--) {
    stroke(255, 255, 200, (3 - layer) * 30 * pulse);
    strokeWeight(1 + layer * 2);
    line(cx - 280, cy - 35, cx + 280, cy - 35);
  }
  noStroke();

  // Winner name — big, bright white with glow
  textAlign(PConstants.CENTER, PConstants.CENTER);

  fill(255, 255, 255, 30);
  textSize(38);
  text(displayName(winner.name), cx + 2, cy + 10 + 2);
  text(displayName(winner.name), cx - 2, cy + 10 - 2);

  fill(255, 255, 255, 240);
  textSize(36);
  text(displayName(winner.name), cx, cy + 10);

  // Score
  float pct = (float) winner.score / (COLS * ROWS) * 100;
  fill(255, 200);
  textSize(18);
  text(nfc(winner.score) + " CELLS  " + nf(pct, 1, 1) + "%", cx, cy + 55);

  // "PRESS SPACE" — flashing yellow with glow
  if ((frameCount % 50) < 35) {
    fill(255, 255, 0, 30);
    textSize(24);
    text("PRESS SPACE TO PLAY AGAIN", cx, cy + 110);
    fill(255, 255, 0, 200 + 55 * pulse);
    textSize(22);
    text("PRESS SPACE TO PLAY AGAIN", cx, cy + 110);
  }
}
