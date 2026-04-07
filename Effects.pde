// ── Particle system ─────────────────────────────────────────

class Particle {
  float x, y, vx, vy;
  float gravity, friction;
  color c;
  float life, maxLife;
  float sz;
  int type;  // 0=confetti, 1=sparkle, 2=ambient

  Particle(float x, float y, float vx, float vy, color c, float life, float sz) {
    this.x = x;  this.y = y;
    this.vx = vx; this.vy = vy;
    this.c = c;
    this.life = life;  this.maxLife = life;
    this.sz = sz;
    this.gravity = 0;
    this.friction = 0.92;
    this.type = 0;
  }

  boolean update() {
    vy += gravity;
    x += vx;
    y += vy;
    vx *= friction;
    vy *= friction;
    life--;
    return life > 0;
  }

  void show() {
    float t = life / maxLife;

    if (type == 1) {
      // Sparkle — bright cross that fades and shrinks
      float s = sz * t;
      float a = 255 * t;
      noStroke();
      fill(c, a);
      rect(x - s, y - 1, s * 2, 2);
      rect(x - 1, y - s, 2, s * 2);
      fill(255, a * 0.8);
      float d = s * 0.4;
      rect(x - d, y - d, d * 2, d * 2);
      return;
    }

    if (type == 2) {
      // Ambient — gentle floating dot that pulses
      float pulse = 0.5 + 0.5 * sin(life * 0.3);
      float a = 120 * t * pulse;
      float s = sz * (0.4 + 0.6 * pulse);
      noStroke();
      fill(c, a);
      rect(x - s / 2, y - s / 2, s, s);
      return;
    }

    // Confetti — original
    if (t < 0.15 && ((int)(life) % 3 == 0)) return;
    noStroke();
    fill(c);
    float s = max(2, sz * (0.5 + 0.5 * t));
    rect(x - s / 2, y - s / 2, s, s);
  }
}

ArrayList<Particle> particles;
int lastSparkleStep = 0;

void initEffects() {
  particles = new ArrayList<Particle>();
  lastSparkleStep = 0;
}

// ── Claim sparkle — candy crush style burst when a cell is claimed ──

void spawnClaimSparkle(float cx, float cy, color col) {
  int count = 4 + (int) random(3);
  for (int i = 0; i < count; i++) {
    float angle = random(TWO_PI);
    float speed = random(0.8, 2.5);
    float vx = cos(angle) * speed;
    float vy = sin(angle) * speed;
    color sc;
    float roll = random(1);
    if (roll < 0.5) sc = lerpColor(col, color(255), 0.6);
    else if (roll < 0.8) sc = color(255, 255, 200);
    else sc = color(255);
    Particle p = new Particle(cx, cy, vx, vy, sc, random(15, 30), random(4, 8));
    p.type = 1;
    p.friction = 0.9;
    particles.add(p);
  }
}

// ── Ambient sparkles — floating glitter across the grid during play ──

void spawnAmbientSparkles() {
  // Spawn a few ambient particles drifting across the grid
  float gridW = COLS * CELL;
  float gridH = ROWS * CELL;
  for (int i = 0; i < 2; i++) {
    float x = random(gridW);
    float y = random(gridH);
    float vx = random(-0.2, 0.2);
    float vy = random(-0.3, -0.05);
    color c;
    float roll = random(1);
    if (roll < 0.3) c = arcadeBlue;
    else if (roll < 0.6) c = color(255, 0, 255);
    else c = color(255, 255, 100);
    Particle p = new Particle(x, y, vx, vy, c, random(40, 80), random(2, 4));
    p.type = 2;
    p.friction = 1.0;
    particles.add(p);
  }
}

// ── Streak burst — when a bot claims many cells quickly ──

void spawnStreakBurst(float cx, float cy, color col) {
  for (int i = 0; i < 8; i++) {
    float angle = TWO_PI * i / 8;
    float speed = random(1.5, 3.0);
    float vx = cos(angle) * speed;
    float vy = sin(angle) * speed;
    color sc = lerpColor(col, color(255, 255, 0), 0.4);
    Particle p = new Particle(cx, cy, vx, vy, sc, random(15, 25), random(4, 7));
    p.type = 1;
    p.friction = 0.88;
    particles.add(p);
  }
}

// ── Mega burst — every 100 consecutive claims ──

void spawnMegaBurst(float cx, float cy, color col) {
  // Ring of 16 fast sparkles
  for (int i = 0; i < 16; i++) {
    float angle = TWO_PI * i / 16;
    float speed = random(3.0, 5.0);
    float vx = cos(angle) * speed;
    float vy = sin(angle) * speed;
    color sc = lerpColor(col, color(255), 0.5);
    Particle p = new Particle(cx, cy, vx, vy, sc, random(25, 40), random(5, 9));
    p.type = 1;
    p.friction = 0.92;
    particles.add(p);
  }
  // Inner burst of white-hot sparkles
  for (int i = 0; i < 12; i++) {
    float angle = random(TWO_PI);
    float speed = random(1.0, 3.0);
    float vx = cos(angle) * speed;
    float vy = sin(angle) * speed;
    Particle p = new Particle(cx, cy, vx, vy, color(255, 255, 200), random(15, 30), random(3, 6));
    p.type = 1;
    p.friction = 0.9;
    particles.add(p);
  }
  // Colored expanding ring particles
  for (int i = 0; i < 8; i++) {
    float angle = TWO_PI * i / 8 + random(-0.2, 0.2);
    float speed = random(1.5, 2.5);
    float vx = cos(angle) * speed;
    float vy = sin(angle) * speed;
    Particle p = new Particle(cx, cy, vx, vy, col, random(30, 50), random(6, 10));
    p.type = 2;
    p.friction = 0.95;
    particles.add(p);
  }
}

// Confetti on game over — restrained, celebratory
void spawnConfetti(color winnerCol) {
  float gridW = COLS * CELL;
  for (int i = 0; i < 80; i++) {
    float x = random(width);
    float y = random(-200, -20);
    float vx = random(-1, 1);
    float vy = random(1.5, 4);
    color c;
    float roll = random(1);
    if (roll < 0.4) c = winnerCol;
    else if (roll < 0.6) c = color(255, 255, 0);
    else if (roll < 0.8) c = color(0, 255, 255);
    else c = color(255);
    Particle p = new Particle(x, y, vx, vy, c, random(120, 200), random(3, 6));
    p.gravity = 0.04;
    p.friction = 0.998;
    particles.add(p);
  }
}

void updateEffects() {
  for (int i = particles.size() - 1; i >= 0; i--) {
    if (!particles.get(i).update()) {
      particles.remove(i);
    }
  }
}

// Draw sparkle/ambient particles in grid-local coordinates
void drawGridEffects() {
  for (Particle p : particles) {
    if (p.type == 1 || p.type == 2) {
      p.show();
    }
  }
  drawCrownIndicator();
  drawProximitySparks();
  drawMilestonePopups();
}

// ── 1. Score milestone floating popups ──────────────────────

float[] milestoneX, milestoneY;  // saved position at moment of milestone

void drawMilestonePopups() {
  if (milestoneFrame == null) return;
  for (int i = 0; i < bots.size(); i++) {
    int age = frameCount - milestoneFrame[i];
    if (age < 35 && milestoneFrame[i] > 0) {
      float cx = milestoneX[i];
      float cy = milestoneY[i];
      float drift = age * 2.0;

      // Hard pop: full opacity then fast cut
      float alpha = age < 20 ? 255 : 255 * (1.0 - (float)(age - 20) / 15);

      // Big scale punch on frame 1, snaps to size fast
      float pop = age < 5 ? 1.0 + (1.0 - age / 5.0) * 1.0 : 1.0;
      float sz = constrain(20 + (milestoneValue[i] / 250) * 3, 20, 32) * pop;

      String label = nfc(milestoneValue[i]) + "!";
      textSize(sz);
      textAlign(PConstants.CENTER, PConstants.CENTER);

      // Bold shadow
      fill(0, alpha);
      text(label, cx + 2, cy - drift + 2);

      // Main text — bright white punch
      fill(255, 255, 255, alpha);
      text(label, cx, cy - drift);
    }
  }
}

// ── 6. Crown indicator over leader ──────────────────────────

void drawCrownIndicator() {
  if (!showMagnifier) return;
  if (currentLeaderId < 0 || currentLeaderId >= bots.size()) return;
  Bot leader = bots.get(currentLeaderId);
  float cx = leader.x * CELL + CELL / 2.0;
  float cy = leader.y * CELL + CELL / 2.0;
  float bob = sin(frameCount * 0.1) * 1.5;

  float radius = 80;
  float bubbleX = cx;
  float bubbleY = cy - CELL * 8 + bob;

  // Clamp so bubble stays within grid
  bubbleX = constrain(bubbleX, radius + 4, COLS * CELL - radius - 4);
  bubbleY = constrain(bubbleY, radius + 4, ROWS * CELL - radius - 4);

  float pulse = 0.7 + 0.3 * sin(frameCount * 0.15);

  // How many grid cells to show across the diameter
  int viewCells = 11;
  float magCell = (radius * 2.0) / viewCells;  // size of each magnified cell

  // Clip to circle using a mask approach: draw into the circle area
  // We'll draw cell by cell, only if within the circle radius

  int startC = leader.x - viewCells / 2;
  int startR = leader.y - viewCells / 2;

  for (int dr = 0; dr < viewCells; dr++) {
    for (int dc = 0; dc < viewCells; dc++) {
      float mx = bubbleX - radius + dc * magCell;
      float my = bubbleY - radius + dr * magCell;
      float mcx = mx + magCell / 2;
      float mcy = my + magCell / 2;

      // Check if cell center is within circle
      float dist = dist(mcx, mcy, bubbleX, bubbleY);
      if (dist > radius - 2) continue;

      int gr = startR + dr;
      int gc = startC + dc;

      noStroke();
      if (gr < 0 || gr >= ROWS || gc < 0 || gc >= COLS) {
        fill(20);
      } else {
        int owner = grid[gr][gc];
        if (owner == -1) {
          fill(10, 10, 20);
        } else {
          color base = bots.get(owner).col;
          fill(base);
        }
      }
      rect(mx, my, magCell, magCell);

      // Draw the bot indicator in the center cell
      if (gr == leader.y && gc == leader.x) {
        float blink = (frameCount + leader.id * 7) % 30 < 25 ? 1 : 0.7;
        fill(255, 255 * blink);
        float dotSz = magCell * 0.5;
        rect(mcx - dotSz / 2, mcy - dotSz / 2, dotSz, dotSz);
      }

      // Grid lines
      stroke(255, 40);
      strokeWeight(0.5);
      line(mx, my, mx + magCell, my);
      line(mx, my, mx, my + magCell);
      noStroke();
    }
  }

  // Circle border — gold ring
  noFill();
  stroke(255, 255, 0, 200 * pulse);
  strokeWeight(3);
  ellipse(bubbleX, bubbleY, radius * 2, radius * 2);

  // Outer glow ring
  stroke(255, 255, 0, 60 * pulse);
  strokeWeight(6);
  ellipse(bubbleX, bubbleY, radius * 2 + 8, radius * 2 + 8);
  noStroke();

  // Connecting line from bubble to bot
  stroke(255, 255, 0, 100 * pulse);
  strokeWeight(1);
  float lineTop = bubbleY + radius + 3;
  float lineBot = cy - CELL;
  if (lineBot > lineTop) {
    line(bubbleX, lineTop, cx, lineBot);
  }
  noStroke();

  // Leader name label above bubble
  String leaderName = displayName(leader.name);
  textSize(14);
  textAlign(PConstants.CENTER, PConstants.CENTER);
  float labelW = textWidth(leaderName) + 16;
  float labelY = bubbleY - radius - 14;
  fill(0, 180);
  noStroke();
  rect(bubbleX - labelW / 2, labelY - 10, labelW, 20, 4);
  fill(0, 100);
  text(leaderName, bubbleX + 1, labelY + 1);
  fill(255, 255, 255, 230 * pulse);
  text(leaderName, bubbleX, labelY);
}

// ── 5. Proximity sparks between nearby bots ─────────────────

void drawProximitySparks() {
  if (gameOver) return;
  for (int i = 0; i < bots.size(); i++) {
    Bot a = bots.get(i);
    for (int j = i + 1; j < bots.size(); j++) {
      Bot b = bots.get(j);
      float dx = a.x - b.x;
      float dy = a.y - b.y;
      float dist = sqrt(dx * dx + dy * dy);
      if (dist < 5 && dist > 0) {
        // Electrical spark between them
        float ax = a.x * CELL + CELL / 2.0;
        float ay = a.y * CELL + CELL / 2.0;
        float bx = b.x * CELL + CELL / 2.0;
        float by = b.y * CELL + CELL / 2.0;
        float sparkAlpha = (1.0 - dist / 5) * 180;

        stroke(255, 255, 255, sparkAlpha);
        strokeWeight(1);
        // Jagged lightning line
        float mx = (ax + bx) / 2 + random(-CELL * 2, CELL * 2);
        float my = (ay + by) / 2 + random(-CELL * 2, CELL * 2);
        line(ax, ay, mx, my);
        line(mx, my, bx, by);
        noStroke();

        // Occasional spark particles
        if (random(1) < 0.1) {
          color sc = lerpColor(a.col, b.col, 0.5);
          spawnClaimSparkle(mx, my, sc);
        }
      }
    }
  }
}

// Draw confetti in screen coordinates
void drawEffects() {
  for (Particle p : particles) {
    if (p.type == 0) {
      p.show();
    }
  }
}
