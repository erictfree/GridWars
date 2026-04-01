class RandomBot extends BasePainter {

  RandomBot(int startX, int startY, color col, String name) {
    super(startX, startY, col, name);
  }

  Direction getNextMove(GameInfo game) {
    return randomDir();
  }
}
