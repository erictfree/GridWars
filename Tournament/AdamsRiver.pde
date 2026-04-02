class AdamsRiver extends Bot {
  AdamsRiver(int x, int y, color c, String name) { super(x, y, c, name); }
  Direction getNextMove(GameInfo game) {
    int halfC = game.cols / 2, halfR = game.rows / 2;
    int[] counts = { game.countUnclaimedInRegion(0,0,halfR-1,halfC-1), game.countUnclaimedInRegion(0,halfC,halfR-1,game.cols-1), game.countUnclaimedInRegion(halfR,0,game.rows-1,halfC-1), game.countUnclaimedInRegion(halfR,halfC,game.rows-1,game.cols-1) };
    int best = 0; for (int i = 1; i < 4; i++) if (counts[i] > counts[best]) best = i;
    int tx = (best % 2 == 0) ? game.cols/4 : 3*game.cols/4;
    int ty = (best < 2) ? game.rows/4 : 3*game.rows/4;
    int dx = tx - this.x, dy = ty - this.y;
    if (abs(dx) > abs(dy)) return dx > 0 ? RIGHT : LEFT;
    else if (dy != 0) return dy > 0 ? DOWN : UP;
    return randomDir();
  }
}
