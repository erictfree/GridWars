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

  // Find winner
  Bot winner = bots.get(0);
  for (Bot p : bots) {
    if (p.score > winner.score) winner = p;
  }

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
      if (roll < 0.3) c = winner.col;
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

  // ── Glowing panel ──
  float panelW = 700;
  float panelH = 400;
  float panelX = cx - panelW / 2;
  float panelY = cy - panelH / 2 - 10;

  for (int layer = 3; layer >= 0; layer--) {
    fill(red(winner.col), green(winner.col), blue(winner.col), 3 + layer * 2);
    rect(panelX - layer * 8, panelY - layer * 8,
         panelW + layer * 16, panelH + layer * 16, 20 + layer * 4);
  }
  fill(0, 200);
  rect(panelX, panelY, panelW, panelH, 16);
  noFill();
  stroke(winner.col, 120 + 80 * pulse);
  strokeWeight(2);
  rect(panelX, panelY, panelW, panelH, 16);
  noStroke();

  // ── "WINNER" — huge golden neon ──
  textAlign(PConstants.CENTER, PConstants.CENTER);
  float winY = panelY + panelH * 0.25;

  fill(255, 215, 0, 12);
  textSize(82);
  text("WINNER", cx + 3, winY + 3);
  text("WINNER", cx - 3, winY - 3);

  fill(255, 215, 0, 30);
  textSize(80);
  text("WINNER", cx, winY);

  float shimmer = 200 + 55 * sin(t * 2);
  fill(255, 215, 0, shimmer);
  textSize(78);
  text("WINNER", cx, winY);

  fill(255, 255, 240, 80 + 40 * fastPulse);
  textSize(76);
  text("WINNER", cx, winY);

  // ── Divider ──
  float divY = winY + 55;
  for (int layer = 2; layer >= 0; layer--) {
    stroke(255, 215, 0, (3 - layer) * 20 * pulse);
    strokeWeight(1 + layer);
    line(cx - 280, divY, cx + 280, divY);
  }
  noStroke();

  // ── Winner name — large, in winner's color ──
  float nameY = divY + 50;

  fill(0, 200);
  textSize(44);
  text(displayName(winner.name), cx + 2, nameY + 2);

  fill(red(winner.col), green(winner.col), blue(winner.col), 30);
  textSize(44);
  text(displayName(winner.name), cx + 2, nameY + 2);
  text(displayName(winner.name), cx - 2, nameY - 2);

  fill(winner.col);
  textSize(42);
  text(displayName(winner.name), cx, nameY);

  // ── Score ──
  float scoreY = nameY + 45;
  float pct = (float) winner.score / (COLS * ROWS) * 100;
  fill(255, 220);
  textSize(18);
  text(nfc(winner.score) + " CELLS  ·  " + nf(pct, 1, 1) + "%", cx, scoreY);

  // ── "PRESS SPACE" ──
  float promptY = panelY + panelH - 40;
  if ((frameCount % 50) < 35) {
    fill(255, 255, 0, 25);
    textSize(24);
    text("PRESS SPACE TO PLAY AGAIN", cx, promptY);
    fill(255, 255, 0, 180 + 75 * fastPulse);
    textSize(22);
    text("PRESS SPACE TO PLAY AGAIN", cx, promptY);
  }
}

// ── Beast mode game over — polished winner celebration ──────
void drawBeastGameOver() {
  float cx = width / 2.0;
  float cy = height / 2.0;
  float pulse = 0.7 + 0.3 * sin(frameCount * 0.08);
  float fastPulse = 0.5 + 0.5 * sin(frameCount * 0.15);
  float t = frameCount * 0.05;

  // Find winner
  Bot winner = bots.get(0);
  for (Bot p : bots) {
    if (p.score > winner.score) winner = p;
  }

  // ── Dark overlay for readability ──
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
      if (roll < 0.3) c = winner.col;
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

  // ── Glowing panel behind text ──
  float panelW = 700;
  float panelH = 440;
  float panelX = cx - panelW / 2;
  float panelY = cy - panelH / 2 - 10;

  for (int layer = 3; layer >= 0; layer--) {
    fill(red(winner.col), green(winner.col), blue(winner.col), 3 + layer * 2);
    rect(panelX - layer * 8, panelY - layer * 8,
         panelW + layer * 16, panelH + layer * 16, 20 + layer * 4);
  }
  fill(0, 200);
  rect(panelX, panelY, panelW, panelH, 16);
  noFill();
  stroke(winner.col, 120 + 80 * pulse);
  strokeWeight(2);
  rect(panelX, panelY, panelW, panelH, 16);
  noStroke();

  // ── "BEAST MODE" — top label, spaced letters ──
  textAlign(PConstants.CENTER, PConstants.CENTER);
  float bmY = panelY + 45;

  fill(255, 0, 128, 25);
  textSize(22);
  text("B E A S T   M O D E", cx, bmY);
  fill(255, 0, 128, 200 + 55 * fastPulse);
  textSize(20);
  text("B E A S T   M O D E", cx, bmY);

  // ── Top divider ──
  float divY1 = bmY + 25;
  for (int layer = 2; layer >= 0; layer--) {
    stroke(255, 0, 128, (3 - layer) * 25 * pulse);
    strokeWeight(1 + layer);
    line(cx - 250, divY1, cx + 250, divY1);
  }
  noStroke();

  // ── "WINNER" — huge golden neon ──
  float winY = panelY + panelH * 0.35;

  fill(255, 215, 0, 12);
  textSize(82);
  text("WINNER", cx + 3, winY + 3);
  text("WINNER", cx - 3, winY - 3);

  fill(255, 215, 0, 30);
  textSize(80);
  text("WINNER", cx, winY);

  float shimmer = 200 + 55 * sin(t * 2);
  fill(255, 215, 0, shimmer);
  textSize(78);
  text("WINNER", cx, winY);

  fill(255, 255, 240, 80 + 40 * fastPulse);
  textSize(76);
  text("WINNER", cx, winY);

  // ── Bottom divider ──
  float divY2 = winY + 55;
  for (int layer = 2; layer >= 0; layer--) {
    stroke(255, 215, 0, (3 - layer) * 20 * pulse);
    strokeWeight(1 + layer);
    line(cx - 280, divY2, cx + 280, divY2);
  }
  noStroke();

  // ── Winner name — large, in winner's color ──
  float nameY = divY2 + 50;

  fill(0, 200);
  textSize(44);
  text(displayName(winner.name), cx + 2, nameY + 2);

  fill(red(winner.col), green(winner.col), blue(winner.col), 30);
  textSize(44);
  text(displayName(winner.name), cx + 2, nameY + 2);
  text(displayName(winner.name), cx - 2, nameY - 2);

  fill(winner.col);
  textSize(42);
  text(displayName(winner.name), cx, nameY);

  // ── Score line ──
  float scoreY = nameY + 45;
  float pct = (float) winner.score / (COLS * ROWS) * 100;
  String scoreText = nfc(winner.score) + " CELLS  ·  " + nf(pct, 1, 1) + "%";
  fill(255, 220);
  textSize(18);
  text(scoreText, cx, scoreY);

  // ── "PRESS SPACE" — flashing yellow ──
  float promptY = panelY + panelH - 40;
  if ((frameCount % 50) < 35) {
    fill(255, 255, 0, 25);
    textSize(24);
    text("PRESS SPACE TO PLAY AGAIN", cx, promptY);
    fill(255, 255, 0, 180 + 75 * fastPulse);
    textSize(22);
    text("PRESS SPACE TO PLAY AGAIN", cx, promptY);
  }
}
