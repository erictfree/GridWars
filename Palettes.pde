// ── Retro color palettes — one is randomly chosen each game ─

void randomizePalette() {
  int pick = (int) random(6);
  switch (pick) {
    case 0:  paletteSynthwave(); break;
    case 1:  palettePacMan(); break;
    case 2:  paletteNES(); break;
    case 3:  paletteCGA(); break;
    case 4:  paletteGameBoyColor(); break;
    default: paletteSega(); break;
  }
  // Max out saturation and brightness — bold, vivid colors
  pushStyle();
  colorMode(HSB, 360, 100, 100);
  for (int i = 0; i < PALETTE.length; i++) {
    float h = hue(PALETTE[i]);
    float s = saturation(PALETTE[i]);
    float b = brightness(PALETTE[i]);
    // Force full saturation and full brightness
    s = 100;
    b = 100;
    PALETTE[i] = color(h, s, b);
  }
  colorMode(RGB, 255);
  popStyle();

  // Shuffle so bots get different colors each run
  for (int i = PALETTE.length - 1; i > 0; i--) {
    int j = (int) random(i + 1);
    color tmp = PALETTE[i];
    PALETTE[i] = PALETTE[j];
    PALETTE[j] = tmp;
  }
}

// Neon synthwave (cyan/magenta/purple)
void paletteSynthwave() {
  PALETTE = new color[] {
    color(  0, 255, 255), color(255,   0, 128), color(255, 255,   0),
    color(128,   0, 255), color(  0, 255, 128), color(255, 100,   0),
    color(100, 140, 255), color(255,   0, 255), color(  0, 200, 100),
    color(255, 180,   0), color(  0, 180, 255), color(255,  60,  60),
    color(180, 255,   0), color(200,   0, 200), color(255, 200, 100),
    color(  0, 255, 200), color(255, 100, 200), color(100, 255, 100),
    color(255, 140,  60), color(140,  80, 255), color(255, 220,  60),
    color( 60, 220, 220), color(255,  60, 160), color( 80, 200, 255),
    color(220, 255, 100), color(255,  80,  80), color(100, 255, 220),
    color(220, 100, 255), color(255, 160, 120), color(120, 255, 160)
  };
}

// Pac-Man / Namco arcade
void palettePacMan() {
  PALETTE = new color[] {
    color(255, 255,   0), color(255,   0,   0), color(255, 184, 255),
    color(  0, 255, 255), color(255, 184,  82), color( 33, 33,  255),
    color( 33, 255,  33), color(255, 184, 174), color(255, 206,   0),
    color(  0, 255, 206), color(222,  50, 168), color(255, 150,   0),
    color(100, 100, 255), color(255, 255, 150), color( 60, 200, 220),
    color(200,  50,  50), color( 50, 220,  50), color(150, 100, 255),
    color(255, 200,  50), color(  0, 170, 170), color(255,  80, 150),
    color(140, 220,  60), color(255, 130,  60), color( 80, 130, 255),
    color(200, 200, 110), color(180,  60,  60), color( 60, 180, 160),
    color(230, 120, 220), color(120, 200, 255), color(210, 170,  80)
  };
}

// NES / Famicom palette
void paletteNES() {
  PALETTE = new color[] {
    color(252,  56,   0), color(  0, 168, 252), color(  0, 168,   0),
    color(252, 252,   0), color(168,   0, 252), color(252, 160,  68),
    color(248, 120,  88), color(104, 136, 252), color( 56, 216, 120),
    color(252, 196, 128), color(164,   0, 200), color(252,  84, 148),
    color(  0, 120,  88), color(228, 220, 168), color(252, 160, 200),
    color( 60, 188, 252), color(168, 204,   0), color(184, 184, 248),
    color(216, 120,  56), color(  0, 200, 168), color(252, 116, 180),
    color(104, 220, 140), color(200, 168,  60), color(120, 100, 220),
    color(252, 200,  88), color( 88, 200, 200), color(248,  88, 120),
    color(168, 228, 104), color(220, 140, 220), color(100, 180, 120)
  };
}

// CGA-inspired (high contrast, limited palette stretched)
void paletteCGA() {
  PALETTE = new color[] {
    color(255, 255,  85), color( 85, 255, 255), color(255,  85, 255),
    color(255,  85,  85), color( 85, 255,  85), color( 85,  85, 255),
    color(255, 255, 255), color(255, 170,   0), color(  0, 170, 255),
    color(170, 255,   0), color(255,   0, 170), color(  0, 255, 170),
    color(170,   0, 255), color(255, 200, 100), color(100, 200, 255),
    color(200, 255, 100), color(255, 100, 200), color(100, 255, 200),
    color(200, 100, 255), color(255, 170, 170), color(170, 255, 170),
    color(170, 170, 255), color(255, 220, 150), color(150, 220, 255),
    color(220, 255, 150), color(255, 150, 220), color(150, 255, 220),
    color(220, 150, 255), color(255, 200, 200), color(200, 255, 200)
  };
}

// Game Boy Color era
void paletteGameBoyColor() {
  PALETTE = new color[] {
    color( 56, 184, 120), color(232,  80,  48), color( 40, 120, 200),
    color(248, 200,  48), color(200,  56, 160), color( 80, 200,  80),
    color(248, 144,  32), color( 48, 168, 232), color(184, 232,  56),
    color(232,  96, 200), color( 80, 232, 168), color(248, 176,  80),
    color(120,  88, 232), color(200, 248, 120), color(248,  80, 120),
    color( 56, 216, 200), color(232, 200, 120), color(160,  56, 232),
    color(120, 232,  80), color(248, 120, 168), color( 56, 168, 120),
    color(232, 168,  56), color( 80, 120, 248), color(200, 232,  80),
    color(248,  56, 200), color( 80, 248, 120), color(232, 120,  56),
    color(120, 200, 248), color(200,  80, 120), color(168, 248, 200)
  };
}

// Sega Genesis / Mega Drive
void paletteSega() {
  PALETTE = new color[] {
    color(  0,   0, 238), color(238,   0,   0), color(  0, 238,   0),
    color(238, 238,   0), color(238,   0, 238), color(  0, 238, 238),
    color(238, 170,   0), color(170,   0, 238), color(  0, 238, 170),
    color(238, 102, 102), color(102, 238, 102), color(102, 102, 238),
    color(238, 238, 170), color(170, 238, 238), color(238, 170, 238),
    color(238, 170, 102), color(102, 238, 170), color(170, 102, 238),
    color(200, 255,  60), color(255,  60, 200), color( 60, 200, 255),
    color(255, 200,  60), color( 60, 255, 200), color(200,  60, 255),
    color(180, 220, 100), color(220, 100, 180), color(100, 180, 220),
    color(255, 140, 100), color(100, 255, 140), color(140, 100, 255)
  };
}
