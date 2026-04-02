class SpiralBot extends Bot {

  Direction[] _cw;
  int _di    = 0;
  int _steps = 0;
  int _limit = 1;
  int _turns = 0;

  SpiralBot(int startX, int startY, color col, String name) {
    super(startX, startY, col, name);
  }

  Direction getNextMove(GameInfo game) {
    if (_cw == null) {
      _cw = new Direction[]{ RIGHT, DOWN, LEFT, UP };
    }

    Direction d = _cw[_di];

    // Wall bounce
    int nx = this.x + d.dx;
    int ny = this.y + d.dy;
    if (!game.inBounds(ny, nx)) {
      _di = (_di + 1) % 4;
      _steps = 0;
      return _cw[_di];
    }

    _steps++;
    if (_steps >= _limit) {
      _di = (_di + 1) % 4;
      _turns++;
      _steps = 0;
      if (_turns % 2 == 0) {
        _limit++;
      }
    }
    return d;
  }
}
