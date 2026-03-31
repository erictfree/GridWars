class GreedyBot extends BasePainter {

  GreedyBot(int startX, int startY, color col, String name) {
    super(startX, startY, col, name);
  }

  Direction getNextMove(int[][] g, int c, int r) {
    // Collect unclaimed neighbors
    ArrayList<Direction> free = new ArrayList<Direction>();
    for (Direction d : DIRS) {
      int nx = this.x + d.dx;
      int ny = this.y + d.dy;
      if (nx >= 0 && nx < c && ny >= 0 && ny < r && g[ny][nx] == -1) {
        free.add(d);
      }
    }
    if (free.size() > 0) {
      return free.get((int) random(free.size()));
    }
    return randomDir();
  }
}
