void drawGameOver() {
  float gridW = COLS * CELL;
  float gridH = ROWS * CELL;

  // Semi-transparent overlay on grid area
  noStroke();
  fill(0, 140);
  rect(0, 0, gridW, gridH);

  // Find winner
  BasePainter winner = painters.get(0);
  for (BasePainter p : painters) {
    if (p.score > winner.score) winner = p;
  }

  // Modal
  float mx = gridW / 2.0;
  float my = gridH / 2.0;
  float mw = 360;
  float mh = 160;

  // Outer glow in winner's color
  fill(winner.col, 20);
  rect(mx - mw / 2 - 8, my - mh / 2 - 8, mw + 16, mh + 16, 16);
  fill(winner.col, 12);
  rect(mx - mw / 2 - 16, my - mh / 2 - 16, mw + 32, mh + 32, 20);

  // Banner background
  fill(14, 16, 30, 245);
  stroke(winner.col, 100);
  strokeWeight(1.5);
  rect(mx - mw / 2, my - mh / 2, mw, mh, 12);
  noStroke();

  // "GAME OVER" with subtle glow
  float pulse = 0.8 + 0.2 * sin(frameCount * 0.06);
  fill(winner.col, 50 * pulse);
  textSize(28);
  textAlign(PConstants.CENTER, PConstants.TOP);
  text("GAME OVER", mx, my - mh / 2 + 16);
  fill(200, 210, 230);
  textSize(26);
  text("GAME OVER", mx, my - mh / 2 + 17);

  // Winner name in winner's color
  fill(winner.col);
  textSize(20);
  text(winner.name, mx, my - 12);

  // Stats
  float pct = (float) winner.score / (COLS * ROWS) * 100;
  fill(120, 125, 150);
  textSize(13);
  text(nfc(winner.score) + " cells  ·  " + nf(pct, 1, 1) + "% of map", mx, my + 22);

  // Hint
  fill(60, 65, 85);
  textSize(10);
  text("click RESTART to play again", mx, my + mh / 2 - 24);
}
