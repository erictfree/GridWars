class HunterBot extends BasePainter {

  HunterBot(int startX, int startY, color col, String name) {
    super(startX, startY, col, name);
  }

  Direction getNextMove(GameInfo game) {
    int halfC = game.cols / 2;
    int halfR = game.rows / 2;

    // Count unclaimed cells in each quadrant using GameInfo
    int[] counts = {
      game.countUnclaimedInRegion(0,     0,     halfR - 1, halfC - 1),  // TL
      game.countUnclaimedInRegion(0,     halfC, halfR - 1, game.cols - 1),  // TR
      game.countUnclaimedInRegion(halfR, 0,     game.rows - 1, halfC - 1),  // BL
      game.countUnclaimedInRegion(halfR, halfC, game.rows - 1, game.cols - 1)   // BR
    };

    // Find richest quadrant
    int best = 0;
    for (int i = 1; i < 4; i++) {
      if (counts[i] > counts[best]) best = i;
    }

    // Target = center of richest quadrant
    int tx = (best % 2 == 0) ? game.cols / 4 : 3 * game.cols / 4;
    int ty = (best < 2)      ? game.rows / 4 : 3 * game.rows / 4;

    int dx = tx - this.x;
    int dy = ty - this.y;

    if (abs(dx) > abs(dy)) {
      return dx > 0 ? RIGHT : LEFT;
    } else if (dy != 0) {
      return dy > 0 ? DOWN : UP;
    }
    return randomDir();
  }
}
