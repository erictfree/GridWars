void drawGameOver() {
  float gridW = COLS * CELL;
  float gridH = ROWS * CELL;

  // Dark overlay
  noStroke();
  fill(0, 180);
  rect(0, 0, gridW, gridH);

  // Find winner
  BasePainter winner = painters.get(0);
  for (BasePainter p : painters) {
    if (p.score > winner.score) winner = p;
  }

  float mx = gridW / 2.0;
  float my = gridH / 2.0;

  // Flashing "GAME OVER" — arcade blink
  boolean blink = (frameCount % 40) < 30;
  if (blink) {
    fill(255, 0, 0);
    textSize(36);
    textAlign(PConstants.CENTER, PConstants.CENTER);
    text("GAME OVER", mx, my - 50);
  }

  // Winner
  fill(winner.col);
  textSize(22);
  textAlign(PConstants.CENTER, PConstants.CENTER);
  text(winner.name, mx, my + 5);

  // Score
  float pct = (float) winner.score / (COLS * ROWS) * 100;
  fill(255);
  textSize(14);
  text(nfc(winner.score) + " CELLS  " + nf(pct, 1, 1) + "%", mx, my + 35);

  // Insert coin prompt
  fill(arcadeBlue);
  textSize(12);
  if ((frameCount % 60) < 40) {
    text("PRESS RESTART TO PLAY AGAIN", mx, my + 70);
  }
}
