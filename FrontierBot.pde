class FrontierBot extends BasePainter {

  FrontierBot(int startX, int startY, color col, String name) {
    super(startX, startY, col, name);
  }

  Direction getNextMove(GameInfo game) {
    int cols = game.cols;
    int rows = game.rows;
    int total = cols * rows;
    boolean[] visited = new boolean[total];

    int[] qx = new int[total];
    int[] qy = new int[total];
    int[] qd = new int[total];
    int head = 0, tail = 0;

    visited[this.y * cols + this.x] = true;

    // Seed with immediate neighbors
    for (int i = 0; i < DIRS.length; i++) {
      int nx = this.x + DIRS[i].dx;
      int ny = this.y + DIRS[i].dy;
      if (game.inBounds(ny, nx)) {
        int idx = ny * cols + nx;
        if (!visited[idx]) {
          visited[idx] = true;
          if (game.isUnclaimed(ny, nx)) return DIRS[i];
          qx[tail] = nx;
          qy[tail] = ny;
          qd[tail] = i;
          tail++;
        }
      }
    }

    // BFS outward
    while (head < tail) {
      int cx = qx[head];
      int cy = qy[head];
      int fd = qd[head];
      head++;

      for (int i = 0; i < DIRS.length; i++) {
        int nx = cx + DIRS[i].dx;
        int ny = cy + DIRS[i].dy;
        if (game.inBounds(ny, nx)) {
          int idx = ny * cols + nx;
          if (!visited[idx]) {
            visited[idx] = true;
            if (game.isUnclaimed(ny, nx)) return DIRS[fd];
            qx[tail] = nx;
            qy[tail] = ny;
            qd[tail] = fd;
            tail++;
          }
        }
      }
    }

    return randomDir();
  }
}
