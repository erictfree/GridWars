/*
 * GridWars
 * Copyright (c) 2026 Eric Freeman, PhD
 * University of Texas at Austin
 * April 7, 2026
 *
 * MIT License
 *
 * Permission is hereby granted, free of charge, to any person obtaining a copy
 * of this software and associated documentation files (the "Software"), to deal
 * in the Software without restriction, including without limitation the rights
 * to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the Software is
 * furnished to do so, subject to the following conditions:
 *
 * The above copyright notice and this permission notice shall be included in all
 * copies or substantial portions of the Software.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
 * SOFTWARE.
 */

class Bot {
  int x, y, id, score;
  color col;
  String name;
  boolean halo = false;

  float glowSize   = 1.0;
  String label     = "";
  int trailLength  = 15;

  // Game reference (set each step by the engine)
  GameInfo gameRef;

  // Trail state
  final int MAX_TRAIL = 40;
  int[] trailX = new int[MAX_TRAIL];
  int[] trailY = new int[MAX_TRAIL];
  int trailIdx = 0;
  boolean trailFull = false;

  Bot(int startX, int startY, color col, String name) {
    this.x    = startX;
    this.y    = startY;
    this.col  = col;
    this.name = name;
    this.id   = -1;
    this.score = 0;
    this.streak = 0;
  }

  int streak = 0;

  // ─────────────────────────────────────────────────────────────
  //  ★  OVERRIDE THIS METHOD  ★
  //
  //  Called once per simulation step.
  //  Use the game object to query the world:
  //    game.grid[row][col]       — bot ID that claimed this cell, or -1 if unclaimed
  //    game.isUnclaimed(row,col) — is this cell free to claim?
  //    game.isClaimed(row,col)   — has any bot claimed this cell?
  //    game.isMine(row,col,id)   — did I claim this cell? (compare with this.id)
  //    game.inBounds(row,col)    — is this coordinate on the grid?
  //    game.getOwner(row,col)    — returns bot ID of owner (-1 unclaimed, -2 out of bounds)
  //    game.cols, game.rows      — grid dimensions
  //    game.countUnclaimed()     — total free cells
  //    game.getNearestBot(x,y,id)— find closest opponent
  //    game.getProgress()        — 0.0 → 1.0 game progress
  //
  //  Use helper methods on yourself:
  //    this.canClaim(direction)   — is the cell in that direction free?
  //    this.peekCell(direction)   — who owns the cell in that direction?
  //    this.getFreeDirs()         — list of directions with free cells
  //
  //  Must return one of:  UP | DOWN | LEFT | RIGHT
  // ─────────────────────────────────────────────────────────────
  Direction getNextMove(GameInfo game) {
    return randomDir();
  }

  // ── Helper methods — use these in getNextMove() ───────────

  /** Can moving in direction d claim an unclaimed cell? */
  boolean canClaim(Direction d) {
    int nx = x + d.dx;
    int ny = y + d.dy;
    return gameRef != null && gameRef.isUnclaimed(ny, nx);
  }

  /** Is the cell in direction d within the grid? */
  boolean isInBounds(Direction d) {
    int nx = x + d.dx;
    int ny = y + d.dy;
    return gameRef != null && gameRef.inBounds(ny, nx);
  }

  /** Returns owner of the cell in direction d. -1 = unclaimed, -2 = out of bounds. */
  int peekCell(Direction d) {
    int nx = x + d.dx;
    int ny = y + d.dy;
    if (gameRef == null) return -2;
    return gameRef.getOwner(ny, nx);
  }

  /** Returns a list of directions that lead to unclaimed cells. */
  ArrayList<Direction> getFreeDirs() {
    ArrayList<Direction> free = new ArrayList<Direction>();
    for (Direction d : DIRS) {
      if (canClaim(d)) free.add(d);
    }
    return free;
  }

  // ── Engine methods — do not override ──────────────────────

  void update(GameInfo game) {
    gameRef = game;

    int tl = constrain(trailLength, 1, MAX_TRAIL);
    trailX[trailIdx] = x;
    trailY[trailIdx] = y;
    trailIdx = (trailIdx + 1) % tl;
    if (!trailFull && trailIdx == 0) trailFull = true;

    Direction d = getNextMove(game);
    x = constrain(x + d.dx, 0, game.cols - 1);
    y = constrain(y + d.dy, 0, game.rows - 1);
    if (game.grid[y][x] == -1) {
      game.grid[y][x] = id;
      score++;
      unclaimed--;
      claimFrame[y][x] = frameCount;
      streak++;

      // Sparkle + ripple on claim
      float cx = x * CELL + CELL / 2.0;
      float cy = y * CELL + CELL / 2.0;
      if (random(1) < 0.3) {
        spawnClaimSparkle(cx, cy, col);
      }
      if (random(1) < 0.15) {
        spawnRipple(cx, cy, col);
      }
      // Streak burst every 20 consecutive claims
      if (streak % 100 == 0) {
        spawnMegaBurst(cx, cy, col);
      } else if (streak % 20 == 0) {
        spawnStreakBurst(cx, cy, col);
      }

      // Score milestones
      int[] thresholds = {100, 250, 500, 1000, 2000, 3000, 5000};
      for (int th : thresholds) {
        if (score == th) {
          milestoneFrame[id] = frameCount;
          milestoneValue[id] = th;
          milestoneX[id] = cx;
          milestoneY[id] = cy;
          spawnStreakBurst(cx, cy, col);
          break;
        }
      }
    } else {
      streak = 0;
    }
  }

  void show() {
    noStroke();
    float gs = glowSize;
    float cx = x * CELL + CELL / 2.0;
    float cy = y * CELL + CELL / 2.0;
    boolean dim = dimMode && !halo;

    if (dim) {
      // Dimmed bot — small muted dot, no trail/name/halo
      float dimSize = CELL * 1.0;
      fill(red(col) * 0.3, green(col) * 0.3, blue(col) * 0.3, 160);
      rect(cx - dimSize / 2, cy - dimSize / 2, dimSize, dimSize);
      return;
    }

    // Trail — subtle fading dots
    if (trailLength > 0) {
      int tl = constrain(trailLength, 1, MAX_TRAIL);
      int count = trailFull ? tl : trailIdx;
      for (int i = 0; i < count; i++) {
        int idx = trailFull ? (trailIdx + i) % tl : i;
        float t = (float)(i + 1) / (count + 1);
        fill(red(col), green(col), blue(col), t * 100);
        float sz = max(1, CELL * 0.35 * t);
        rect(trailX[idx] * CELL + (CELL - sz) / 2,
             trailY[idx] * CELL + (CELL - sz) / 2, sz, sz);
      }
    }

    // Halo — large pulsing ring to help track your bot
    if (halo) {
      float haloPulse = 0.5 + 0.5 * sin(frameCount * 0.08);
      float haloSize = CELL * (6 + 2 * haloPulse) * gs;
      noFill();
      // Outer glow
      stroke(red(col), green(col), blue(col), 60 * haloPulse);
      strokeWeight(6);
      ellipse(cx, cy, haloSize, haloSize);
      // Inner ring
      stroke(red(col), green(col), blue(col), 200 * (0.5 + 0.5 * haloPulse));
      strokeWeight(3);
      ellipse(cx, cy, haloSize * 0.85, haloSize * 0.85);
      noStroke();
    }

    // Bot indicator — pixel-art style
    float blink = (frameCount + id * 7) % 30 < 25 ? 1 : 0.6;

    float outerSize = CELL * 1.8 * gs;
    fill(red(col) * min(blink * 1.3, 1), green(col) * min(blink * 1.3, 1), blue(col) * min(blink * 1.3, 1));
    rect(cx - outerSize / 2, cy - outerSize / 2, outerSize, outerSize);

    fill(red(col) * blink, green(col) * blink, blue(col) * blink);
    float coreSize = CELL * 1.3;
    rect(cx - coreSize / 2, cy - coreSize / 2, coreSize, coreSize);

    fill(255, 255 * blink);
    float hotSize = max(2, CELL * 0.35);
    rect(cx - hotSize / 2, cy - hotSize / 2, hotSize, hotSize);

    if (label.length() > 0) {
      fill(255);
      textSize(CELL * 0.9);
      textAlign(PConstants.CENTER, PConstants.CENTER);
      text(label, cx, cy - 1);
    }

    // Name with dark backing for readability
    float nameSz = max(9, CELL * 1.1);
    float nameY = cy - CELL * 1.6 * gs;
    textSize(nameSz);
    textAlign(PConstants.CENTER, PConstants.BOTTOM);
    String dName = displayName(name);
    float tw = textWidth(dName);
    float pad = 3;
    fill(0, 180);
    rect(cx - tw / 2 - pad, nameY - nameSz - pad + 2, tw + pad * 2, nameSz + pad * 2 - 2, 3);
    fill(255);
    text(dName, cx, nameY);
  }
}