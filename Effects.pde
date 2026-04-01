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
      stroke(c, a);
      strokeWeight(1);
      line(x - s, y, x + s, y);
      line(x, y - s, x, y + s);
      noStroke();
      fill(255, a * 0.8);
      ellipse(x, y, s * 0.6, s * 0.6);
      return;
    }

    if (type == 2) {
      // Ambient — gentle floating dot that pulses
      float pulse = 0.5 + 0.5 * sin(life * 0.3);
      float a = 120 * t * pulse;
      float s = sz * (0.4 + 0.6 * pulse);
      noStroke();
      fill(c, a);
      ellipse(x, y, s, s);
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
  // Small burst of 3-5 sparkle particles
  int count = 3 + (int) random(3);
  for (int i = 0; i < count; i++) {
    float angle = random(TWO_PI);
    float speed = random(0.5, 2.0);
    float vx = cos(angle) * speed;
    float vy = sin(angle) * speed;
    color sc;
    float roll = random(1);
    if (roll < 0.5) sc = lerpColor(col, color(255), 0.6);
    else if (roll < 0.8) sc = color(255, 255, 200);
    else sc = color(255);
    Particle p = new Particle(cx, cy, vx, vy, sc, random(10, 20), random(3, 6));
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
}

// Draw confetti in screen coordinates
void drawEffects() {
  for (Particle p : particles) {
    if (p.type == 0) {
      p.show();
    }
  }
}
