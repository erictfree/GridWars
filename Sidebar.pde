void drawSidebar() {
  float sx = COLS * CELL;
  float sw = SIDE;
  float sh = ROWS * CELL + BOT;  // extend to cover HUD corner

  // Background
  noStroke();
  fill(sidebarBg);
  rect(sx, 0, sw, sh);

  // Subtle left edge highlight
  stroke(40, 44, 65);
  strokeWeight(1);
  line(sx, 0, sx, sh);
  noStroke();

  // Title
  fill(120, 130, 170);
  textSize(11);
  textAlign(PConstants.CENTER, PConstants.TOP);
  text("L E A D E R B O A R D", sx + sw / 2, 16);

  // Divider
  stroke(40, 44, 65);
  strokeWeight(0.5);
  line(sx + 16, 36, sx + sw - 16, 36);
  noStroke();

  // Sort painters by score (descending) without mutating the original list
  ArrayList<BasePainter> sorted = new ArrayList<BasePainter>(painters);
  java.util.Collections.sort(sorted, new java.util.Comparator<BasePainter>() {
    public int compare(BasePainter a, BasePainter b) {
      return b.score - a.score;
    }
  });

  float entryX = sx + 14;
  float entryW = sw - 28;
  float entryY = 46;
  float footerH = 30;
  float entryH = min(78, (ROWS * CELL - entryY - footerH) / max(1, sorted.size()));
  int totalCells = COLS * ROWS;

  for (int i = 0; i < sorted.size(); i++) {
    BasePainter p = sorted.get(i);
    float ey = entryY + i * entryH;

    // Rank badge — gold / silver / bronze for top 3
    color badgeCol;
    if      (i == 0) badgeCol = color(255, 210, 60);
    else if (i == 1) badgeCol = color(180, 190, 210);
    else if (i == 2) badgeCol = color(205, 140, 75);
    else             badgeCol = color(55, 58, 75);

    // Badge glow for top 3
    if (i < 3) {
      fill(badgeCol, 40);
      ellipse(entryX + 10, ey + 13, 26, 26);
    }
    fill(badgeCol);
    ellipse(entryX + 10, ey + 13, 20, 20);

    // Rank number
    fill(i < 3 ? color(20) : color(140));
    textSize(11);
    textAlign(PConstants.CENTER, PConstants.CENTER);
    text(str(i + 1), entryX + 10, ey + 12);

    // Bot name in its color
    fill(p.col);
    textSize(13);
    textAlign(PConstants.LEFT, PConstants.TOP);
    text(p.name, entryX + 26, ey + 5);

    // Territory bar
    float pct = (float) p.score / totalCells;
    float barY = ey + 27;
    float barH = 8;

    // Bar track
    fill(30, 32, 48);
    rect(entryX, barY, entryW, barH, 4);

    // Bar glow (behind fill)
    fill(p.col, 35);
    rect(entryX, barY - 1, entryW * pct + 2, barH + 2, 4);

    // Bar fill
    fill(p.col, 220);
    rect(entryX, barY, entryW * pct, barH, 4);

    // Score text
    fill(110, 115, 140);
    textSize(10);
    textAlign(PConstants.LEFT, PConstants.TOP);
    String info = nfc(p.score) + " cells  ·  " + nf(pct * 100, 1, 1) + "%";
    text(info, entryX, barY + 14);
  }

  // Footer
  fill(40, 44, 60);
  textSize(9);
  textAlign(PConstants.CENTER, PConstants.BOTTOM);
  text("extend BasePainter", sx + sw / 2, ROWS * CELL - 10);
}
