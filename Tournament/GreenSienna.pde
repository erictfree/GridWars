class GreenSienna extends Bot {
  GreenSienna(int x, int y, color c, String name) { super(x, y, c, name); }
  Direction getNextMove(GameInfo game) {
    int cols = game.cols, rows = game.rows, total = cols * rows;
    boolean[] visited = new boolean[total];
    int[] qx = new int[total], qy = new int[total], qd = new int[total];
    int head = 0, tail = 0;
    visited[this.y * cols + this.x] = true;
    for (int i = 0; i < DIRS.length; i++) {
      int nx = this.x + DIRS[i].dx, ny = this.y + DIRS[i].dy;
      if (game.inBounds(ny, nx)) { int idx = ny * cols + nx; if (!visited[idx]) { visited[idx] = true; if (game.isUnclaimed(ny, nx)) return DIRS[i]; qx[tail] = nx; qy[tail] = ny; qd[tail] = i; tail++; } }
    }
    while (head < tail) {
      int cx2 = qx[head], cy2 = qy[head], fd = qd[head]; head++;
      for (int i = 0; i < DIRS.length; i++) {
        int nx = cx2 + DIRS[i].dx, ny = cy2 + DIRS[i].dy;
        if (game.inBounds(ny, nx)) { int idx = ny * cols + nx; if (!visited[idx]) { visited[idx] = true; if (game.isUnclaimed(ny, nx)) return DIRS[fd]; qx[tail] = nx; qy[tail] = ny; qd[tail] = fd; tail++; } }
      }
    }
    return randomDir();
  }
}
