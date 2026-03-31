class FrontierBot extends BasePainter {

  FrontierBot(int startX, int startY, color col, String name) {
    super(startX, startY, col, name);
  }

  Direction getNextMove(int[][] g, int cols, int rows) {
    int total = cols * rows;
    boolean[] visited = new boolean[total];

    // BFS queues — parallel arrays for speed
    int[] qx = new int[total];
    int[] qy = new int[total];
    int[] qd = new int[total];  // index of first direction from start
    int head = 0, tail = 0;

    visited[this.y * cols + this.x] = true;

    // Seed with immediate neighbors
    for (int i = 0; i < DIRS.length; i++) {
      int nx = this.x + DIRS[i].dx;
      int ny = this.y + DIRS[i].dy;
      if (nx >= 0 && nx < cols && ny >= 0 && ny < rows) {
        int idx = ny * cols + nx;
        if (!visited[idx]) {
          visited[idx] = true;
          if (g[ny][nx] == -1) return DIRS[i];  // adjacent unclaimed — go there
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
        if (nx >= 0 && nx < cols && ny >= 0 && ny < rows) {
          int idx = ny * cols + nx;
          if (!visited[idx]) {
            visited[idx] = true;
            if (g[ny][nx] == -1) return DIRS[fd];  // found unclaimed — follow first step
            qx[tail] = nx;
            qy[tail] = ny;
            qd[tail] = fd;
            tail++;
          }
        }
      }
    }

    return randomDir();  // all cells claimed
  }
}
