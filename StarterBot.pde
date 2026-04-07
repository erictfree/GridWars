class StarterBot extends Bot {

  StarterBot(int startX, int startY, color col, String name) {
    super(startX, startY, col, name);
  }

  Direction getNextMove(GameInfo game) {
    return randomDir();
  }
}
