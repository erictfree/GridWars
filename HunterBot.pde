class HunterBot extends BasePainter {

  HunterBot(int startX, int startY, color col, String name) {
    super(startX, startY, col, name);
  }

  Direction getNextMove(int[][] g, int cols, int rows) {
    int halfC = cols / 2;
    int halfR = rows / 2;

    // Count unclaimed cells in each quadrant: TL, TR, BL, BR
    int[] counts = new int[4];
    for (int r = 0; r < rows; r++) {
      for (int c = 0; c < cols; c++) {
        if (g[r][c] == -1) {
          int qi = (r < halfR ? 0 : 2) + (c < halfC ? 0 : 1);
          counts[qi]++;
        }
      }
    }

    // Find richest quadrant
    int best = 0;
    for (int i = 1; i < 4; i++) {
      if (counts[i] > counts[best]) best = i;
    }

    // Target = center of richest quadrant
    int tx = (best % 2 == 0) ? cols / 4 : 3 * cols / 4;
    int ty = (best < 2)      ? rows / 4 : 3 * rows / 4;

    int dx = tx - this.x;
    int dy = ty - this.y;

    // Steer toward target — prefer the axis with larger delta
    if (abs(dx) > abs(dy)) {
      return dx > 0 ? RIGHT : LEFT;
    } else if (dy != 0) {
      return dy > 0 ? DOWN : UP;
    }
    return randomDir();
  }
}
