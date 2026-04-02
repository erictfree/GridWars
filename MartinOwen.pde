class MartinOwen extends Bot {
  MartinOwen(int x, int y, color c, String name) { super(x, y, c, name); }
  Direction getNextMove(GameInfo game) {
    return randomDir();
  }
}
