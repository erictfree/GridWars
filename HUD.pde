void drawHUD() {
  float hx = 0;
  float hy = ROWS * CELL;
  float hw = COLS * CELL;

  // Timer
  int elapsed = (gameStartMillis > 0) ? millis() - gameStartMillis : 0;
  int remaining = max(0, GAME_TIME_MS - elapsed);
  int secs = remaining / 1000;
  float progress = constrain((float) elapsed / GAME_TIME_MS, 0, 1);

  // Progress bar — thin strip at bottom of grid
  float barH = 4;
  fill(20, 60);
  noStroke();
  rect(hx, hy, hw, barH);

  color barColor = progress < 0.75 ? arcadeBlue : color(255, 0, 0);
  fill(barColor);
  rect(hx, hy, hw * progress, barH);

  // Time remaining — right-aligned under the grid
  fill(secs <= 10 ? color(255, 0, 0) : color(180));
  textSize(9);
  textAlign(PConstants.RIGHT, PConstants.TOP);
  String timeStr = nf(secs / 60, 1) + ":" + nf(secs % 60, 2);
  text(timeStr, hw - 4, hy + barH + 2);
}
