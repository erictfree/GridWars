// ── Particle system ─────────────────────────────────────────

class Particle {
  float x, y, vx, vy;
  float gravity, friction;
  color c;
  float life, maxLife;
  float sz;

  Particle(float x, float y, float vx, float vy, color c, float life, float sz) {
    this.x = x;  this.y = y;
    this.vx = vx; this.vy = vy;
    this.c = c;
    this.life = life;  this.maxLife = life;
    this.sz = sz;
    this.gravity = 0;
    this.friction = 0.92;
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
    float s = sz * (0.3 + 0.7 * t);
    noStroke();
    fill(c, 255 * t);
    ellipse(x, y, s, s);
  }
}

ArrayList<Particle> particles;

void initEffects() {
  particles = new ArrayList<Particle>();
}

// Sparkles when a cell is claimed
void spawnClaimParticles(int gridCol, int gridRow, color c) {
  float cx = gridCol * CELL + CELL / 2.0;
  float cy = gridRow * CELL + CELL / 2.0;
  int count = 4 + (int) random(3);
  for (int i = 0; i < count; i++) {
    float angle = random(TWO_PI);
    float speed = random(1.5, 4.0);
    Particle p = new Particle(
      cx, cy,
      cos(angle) * speed, sin(angle) * speed,
      c, random(10, 20), random(2.5, 5.5)
    );
    p.friction = 0.90;
    particles.add(p);
  }
  // Add a couple white sparkle particles
  for (int i = 0; i < 2; i++) {
    float angle = random(TWO_PI);
    float speed = random(1.0, 2.5);
    Particle p = new Particle(
      cx, cy,
      cos(angle) * speed, sin(angle) * speed,
      color(255), random(6, 12), random(2, 4)
    );
    p.friction = 0.88;
    particles.add(p);
  }
}

// Confetti celebration on game over
void spawnConfetti(color winnerCol) {
  float gridW = COLS * CELL;
  for (int i = 0; i < 200; i++) {
    float x = random(gridW);
    float y = random(-300, -20);
    float vx = random(-1.5, 1.5);
    float vy = random(1.5, 5.0);
    color c;
    float roll = random(1);
    if (roll < 0.4) {
      c = winnerCol;
    } else if (roll < 0.6) {
      c = lerpColor(winnerCol, color(255), 0.5);
    } else {
      c = color(random(120, 255), random(120, 255), random(120, 255));
    }
    Particle p = new Particle(x, y, vx, vy, c, random(180, 300), random(4, 10));
    p.gravity = 0.05;
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

void drawEffects() {
  for (Particle p : particles) {
    p.show();
  }
}
