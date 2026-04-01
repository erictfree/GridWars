class GreedyBot extends BasePainter {

  GreedyBot(int startX, int startY, color col, String name) {
    super(startX, startY, col, name);
  }

  Direction getNextMove(GameInfo game) {
    // Use the helper method to find unclaimed neighbors
    ArrayList<Direction> free = getFreeDirs();
    if (free.size() > 0) {
      return free.get((int) random(free.size()));
    }
    return randomDir();
  }
}
