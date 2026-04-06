class SpiralBot extends Bot {

  Direction[] cw;
  int di    = 0;
  int steps = 0;
  int limit = 1;
  int turns = 0;

  SpiralBot(int startX, int startY, color col, String name) {
    super(startX, startY, col, name);
  }

  Direction getNextMove(GameInfo game) {
    if (cw == null) {
      cw = new Direction[]{ RIGHT, DOWN, LEFT, UP };
    }

    Direction d = cw[di];

    // Wall bounce
    int nx = this.x + d.dx;
    int ny = this.y + d.dy;
    if (!game.inBounds(ny, nx)) {
      di = (di + 1) % 4;
      steps = 0;
      return cw[di];
    }

    steps++;
    if (steps >= limit) {
      di = (di + 1) % 4;
      turns++;
      steps = 0;
      if (turns % 2 == 0) {
        limit++;
      }
    }
    return d;
  }
}
