class RandomBot extends BasePainter {

  RandomBot(int startX, int startY, color col, String name) {
    super(startX, startY, col, name);
  }

  Direction getNextMove(int[][] g, int c, int r) {
    return randomDir();
  }
}
