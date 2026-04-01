// ── Particle system (confetti only) ─────────────────────────

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
    if (t < 0.15 && ((int)(life) % 3 == 0)) return;
    noStroke();
    fill(c);
    float s = max(2, sz * (0.5 + 0.5 * t));
    rect(x - s / 2, y - s / 2, s, s);
  }
}

ArrayList<Particle> particles;

void initEffects() {
  particles = new ArrayList<Particle>();
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

void drawEffects() {
  for (Particle p : particles) {
    p.show();
  }
}
