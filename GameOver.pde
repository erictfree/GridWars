// Full-screen game over — shown over the background after screenshot is taken
void drawGameOverFull() {
  // Center on game area, not full window
  int gridW = COLS * CELL + INSET * 2;
  float cx = MARGIN + gridW / 2.0;
  float cy = height / 2.0;

  // Find winner
  Bot winner = bots.get(0);
  for (Bot p : bots) {
    if (p.score > winner.score) winner = p;
  }

  // Flashing "GAME OVER" — arcade blink
  boolean blink = (frameCount % 40) < 30;
  if (blink) {
    fill(255, 0, 0);
    textSize(36);
    textAlign(PConstants.CENTER, PConstants.CENTER);
    text("GAME OVER", cx, cy - 50);
  }

  // Winner
  fill(winner.col);
  textSize(22);
  textAlign(PConstants.CENTER, PConstants.CENTER);
  text(winner.name, cx, cy + 5);

  // Score
  float pct = (float) winner.score / (COLS * ROWS) * 100;
  fill(255);
  textSize(14);
  text(nfc(winner.score) + " CELLS  " + nf(pct, 1, 1) + "%", cx, cy + 35);

  // Insert coin prompt
  fill(arcadeBlue);
  textSize(12);
  if ((frameCount % 60) < 40) {
    text("PRESS SPACE TO PLAY AGAIN", cx, cy + 70);
  }
}
