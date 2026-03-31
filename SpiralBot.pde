class SpiralBot extends BasePainter {

  // Clockwise direction sequence: RIGHT → DOWN → LEFT → UP
  Direction[] _cw;
  int _di    = 0;   // current index into _cw
  int _steps = 0;   // steps taken in current leg
  int _limit = 1;   // leg length
  int _turns = 0;   // total turns made

  SpiralBot(int startX, int startY, color col, String name) {
    super(startX, startY, col, name);
  }

  Direction getNextMove(int[][] g, int cols, int rows) {
    // Lazy-init clockwise array (DIRS not available at construction)
    if (_cw == null) {
      _cw = new Direction[]{ RIGHT, DOWN, LEFT, UP };
    }

    Direction d = _cw[_di];

    // Wall bounce: if next cell is out of bounds, turn clockwise
    int nx = this.x + d.dx;
    int ny = this.y + d.dy;
    if (nx < 0 || nx >= cols || ny < 0 || ny >= rows) {
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
