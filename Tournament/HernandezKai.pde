class HernandezKai extends BasePainter {
  Direction[] _cw;
  int _di = 0, _steps = 0, _limit = 1, _turns = 0;
  HernandezKai(int x, int y, color c, String name) { super(x, y, c, name); }
  Direction getNextMove(GameInfo game) {
    if (_cw == null) _cw = new Direction[]{RIGHT, DOWN, LEFT, UP};
    Direction d = _cw[_di];
    int nx = this.x + d.dx, ny = this.y + d.dy;
    if (!game.inBounds(ny, nx)) { _di = (_di + 1) % 4; _steps = 0; return _cw[_di]; }
    _steps++;
    if (_steps >= _limit) { _di = (_di + 1) % 4; _turns++; _steps = 0; if (_turns % 2 == 0) _limit++; }
    return d;
  }
}
