class ButlerSterling extends Bot {
  Direction[] cw;
  int di = 0, steps = 0, limit = 1, turns = 0;
  ButlerSterling(int x, int y, color c, String name) { super(x, y, c, name); }
  Direction getNextMove(GameInfo game) {
    if (cw == null) cw = new Direction[]{RIGHT, DOWN, LEFT, UP};
    Direction d = cw[di];
    int nx = this.x + d.dx, ny = this.y + d.dy;
    if (!game.inBounds(ny, nx)) { di = (di + 1) % 4; steps = 0; return cw[di]; }
    steps++;
    if (steps >= limit) { di = (di + 1) % 4; turns++; steps = 0; if (turns % 2 == 0) limit++; }
    return d;
  }
}
