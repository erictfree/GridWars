// ── ShadowBot — "Follow the leader, eat their scraps" ────────
//
// Most bots leave gaps as they sweep — unclaimed cells in their
// wake. ShadowBot finds the leading opponent and follows behind
// them at ~5 cell distance, claiming everything they missed.
// Like a remora on a shark.
//
// When not shadowing (no clear leader or we ARE the leader),
// falls back to pure BFS.

class ShadowBot extends Bot {

  final int MAX_BFS = 90000;
  int[] bfsQx = new int[MAX_BFS];
  int[] bfsQy = new int[MAX_BFS];
  int[] bfsQdir = new int[MAX_BFS];
  boolean[] bfsVisited = new boolean[MAX_BFS];

  // Track the leader's previous positions to follow their trail
  int shadowTargetId = -1;
  int lastLeaderX = -1, lastLeaderY = -1;

  ShadowBot(int startX, int startY, color col, String name) {
    super(startX, startY, col, name);
  }

  Direction getNextMove(GameInfo game) {
    int cols = game.cols;
    int rows = game.rows;

    // Always claim free neighbors first
    ArrayList<Direction> free = getFreeDirs();

    if (free.size() > 0) {
      // Pick the free cell closest to the leader's trail
      Bot leader = findLeader(game);
      if (leader != null && leader.score > this.score) {
        return shadowGreedy(free, leader);
      }
      // We're leading or no target — pick by openness
      return bestOpenDir(game, free);
    }

    // No free neighbors — BFS toward the leader's area
    Bot leader = findLeader(game);
    if (leader != null && leader.score > this.score) {
      return bfsTowardBot(game, leader, cols, rows);
    }

    return pureBFS(game, cols, rows);
  }

  Bot findLeader(GameInfo game) {
    Bot leader = null;
    int best = -1;
    for (Bot b : game.bots) {
      if (b.id == this.id) continue;
      if (b.score > best) { best = b.score; leader = b; }
    }
    return leader;
  }

  // Pick the free direction that moves toward the leader (stay ~5 cells behind)
  Direction shadowGreedy(ArrayList<Direction> free, Bot leader) {
    Direction bestDir = null;
    float bestScore = -999;
    float idealDist = 5;

    for (Direction d : free) {
      int nx = this.x + d.dx;
      int ny = this.y + d.dy;
      float dist = abs(leader.x - nx) + abs(leader.y - ny);
      // Score: closest to ideal shadow distance
      float score = -abs(dist - idealDist);
      if (score > bestScore) {
        bestScore = score;
        bestDir = d;
      }
    }
    return bestDir != null ? bestDir : free.get(0);
  }

  Direction bestOpenDir(GameInfo game, ArrayList<Direction> free) {
    Direction bestDir = null;
    int bestOpen = -1;
    for (Direction d : free) {
      int nx = this.x + d.dx;
      int ny = this.y + d.dy;
      int openCount = 0;
      for (Direction nd : DIRS) {
        if (game.isUnclaimed(ny + nd.dy, nx + nd.dx)) openCount++;
      }
      if (openCount > bestOpen) { bestOpen = openCount; bestDir = d; }
    }
    return bestDir != null ? bestDir : free.get(0);
  }

  // BFS but prefer cells near the leader
  Direction bfsTowardBot(GameInfo game, Bot target, int cols, int rows) {
    int total = cols * rows;
    int clearLen = min(total, MAX_BFS);
    java.util.Arrays.fill(bfsVisited, 0, clearLen, false);
    int head = 0, tail = 0;
    bfsVisited[this.y * cols + this.x] = true;

    for (int i = 0; i < DIRS.length; i++) {
      int nx = this.x + DIRS[i].dx; int ny = this.y + DIRS[i].dy;
      if (!game.inBounds(ny, nx)) continue;
      int idx = ny * cols + nx;
      if (idx < 0 || idx >= clearLen || bfsVisited[idx]) continue;
      bfsVisited[idx] = true;
      if (game.isUnclaimed(ny, nx)) return DIRS[i];
      if (tail < MAX_BFS) { bfsQx[tail]=nx; bfsQy[tail]=ny; bfsQdir[tail]=i; tail++; }
    }

    int foundDepth = -1;
    float bestScore = -999;
    int bestDir = -1;
    int waveEnd = tail, depth = 1;

    while (head < tail && head < MAX_BFS - 4) {
      if (head >= waveEnd) { depth++; waveEnd = tail; if (foundDepth >= 0 && depth > foundDepth + 2) break; }
      int cx = bfsQx[head]; int cy = bfsQy[head]; int fd = bfsQdir[head]; head++;
      for (int i = 0; i < DIRS.length; i++) {
        int nx = cx+DIRS[i].dx; int ny = cy+DIRS[i].dy;
        if (!game.inBounds(ny,nx)) continue;
        int idx = ny*cols+nx;
        if (idx<0||idx>=clearLen||bfsVisited[idx]) continue;
        bfsVisited[idx] = true;
        if (game.isUnclaimed(ny, nx)) {
          foundDepth = depth;
          float distToLeader = abs(target.x-nx)+abs(target.y-ny);
          float score = -depth - distToLeader * 0.5;
          if (score > bestScore) { bestScore = score; bestDir = fd; }
          continue;
        }
        if (tail<MAX_BFS) { bfsQx[tail]=nx; bfsQy[tail]=ny; bfsQdir[tail]=fd; tail++; }
      }
    }
    if (bestDir >= 0) return DIRS[bestDir];
    return randomDir();
  }

  Direction pureBFS(GameInfo game, int cols, int rows) {
    int total = cols * rows;
    int clearLen = min(total, MAX_BFS);
    java.util.Arrays.fill(bfsVisited, 0, clearLen, false);
    int head = 0, tail = 0;
    bfsVisited[this.y * cols + this.x] = true;
    for (int i = 0; i < DIRS.length; i++) {
      int nx = this.x+DIRS[i].dx; int ny = this.y+DIRS[i].dy;
      if (!game.inBounds(ny,nx)) continue;
      int idx = ny*cols+nx;
      if (idx<0||idx>=clearLen||bfsVisited[idx]) continue;
      bfsVisited[idx] = true;
      if (game.isUnclaimed(ny,nx)) return DIRS[i];
      if (tail<MAX_BFS) { bfsQx[tail]=nx; bfsQy[tail]=ny; bfsQdir[tail]=i; tail++; }
    }
    while (head < tail) {
      int cx=bfsQx[head]; int cy=bfsQy[head]; int fd=bfsQdir[head]; head++;
      for (int i=0; i<DIRS.length; i++) {
        int nx=cx+DIRS[i].dx; int ny=cy+DIRS[i].dy;
        if (!game.inBounds(ny,nx)) continue;
        int idx=ny*cols+nx;
        if (idx<0||idx>=clearLen||bfsVisited[idx]) continue;
        bfsVisited[idx]=true;
        if (game.isUnclaimed(ny,nx)) return DIRS[fd];
        if (tail<MAX_BFS) { bfsQx[tail]=nx; bfsQy[tail]=ny; bfsQdir[tail]=fd; tail++; }
      }
    }
    return randomDir();
  }
}
