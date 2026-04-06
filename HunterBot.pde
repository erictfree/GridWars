class HunterBot extends Bot {

  HunterBot(int startX, int startY, color col, String name) {
    super(startX, startY, col, name);
  }

  Direction getNextMove(GameInfo game) {
    int cols = game.cols;
    int rows = game.rows;

    // Always claim adjacent unclaimed cells first
    ArrayList<Direction> free = getFreeDirs();
    if (free.size() > 0) {
      // Pick the free direction toward the richest quadrant
      int halfC = cols / 2;
      int halfR = rows / 2;

      int[] counts = {
        game.countUnclaimedInRegion(0,     0,     halfR - 1, halfC - 1),
        game.countUnclaimedInRegion(0,     halfC, halfR - 1, cols - 1),
        game.countUnclaimedInRegion(halfR, 0,     rows - 1,  halfC - 1),
        game.countUnclaimedInRegion(halfR, halfC, rows - 1,  cols - 1)
      };

      int best = 0;
      for (int i = 1; i < 4; i++) {
        if (counts[i] > counts[best]) best = i;
      }

      int tx = (best % 2 == 0) ? cols / 4 : 3 * cols / 4;
      int ty = (best < 2)      ? rows / 4 : 3 * rows / 4;

      // Score free directions by openness + bias toward target
      Direction bestDir = null;
      float bestScore = -999;

      for (Direction d : free) {
        int nx = this.x + d.dx;
        int ny = this.y + d.dy;
        float score = 0;

        // Openness
        for (Direction nd : DIRS) {
          if (game.isUnclaimed(ny + nd.dy, nx + nd.dx)) score += 6;
        }

        // Bias toward richest quadrant
        float curDist = abs(tx - this.x) + abs(ty - this.y);
        float newDist = abs(tx - nx) + abs(ty - ny);
        score += (curDist - newDist) * 2;

        if (score > bestScore) { bestScore = score; bestDir = d; }
      }

      return bestDir != null ? bestDir : free.get(0);
    }

    // No free neighbors — move toward richest quadrant
    int halfC = cols / 2;
    int halfR = rows / 2;

    int[] counts = {
      game.countUnclaimedInRegion(0,     0,     halfR - 1, halfC - 1),
      game.countUnclaimedInRegion(0,     halfC, halfR - 1, cols - 1),
      game.countUnclaimedInRegion(halfR, 0,     rows - 1,  halfC - 1),
      game.countUnclaimedInRegion(halfR, halfC, rows - 1,  cols - 1)
    };

    int best = 0;
    for (int i = 1; i < 4; i++) {
      if (counts[i] > counts[best]) best = i;
    }

    int tx = (best % 2 == 0) ? cols / 4 : 3 * cols / 4;
    int ty = (best < 2)      ? rows / 4 : 3 * rows / 4;

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
