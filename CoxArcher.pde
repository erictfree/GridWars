class CoxArcher extends BasePainter {
  CoxArcher(int x, int y, color c, String name) { super(x, y, c, name); }
  Direction getNextMove(GameInfo game) {
    ArrayList<Direction> free = getFreeDirs();
    if (free.size() > 0) return free.get((int) random(free.size()));
    return randomDir();
  }
}
