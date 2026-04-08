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

// ── Retro color palettes — pooled from all themes, deduplicated by hue ─

void randomizePalette() {
  // Pool every color from all palettes
  color[][] allPalettes = {
    paletteSynthwave(), palettePacMan(), paletteNES(),
    paletteCGA(), paletteGameBoyColor(), paletteSega(), paletteJewel()
  };

  // Collect all colors into one flat list
  ArrayList<Integer> pool = new ArrayList<Integer>();
  for (color[] pal : allPalettes) {
    for (color c : pal) {
      pool.add(c);
    }
  }

  // Max out saturation and brightness — bold, vivid colors
  pushStyle();
  colorMode(HSB, 360, 100, 100);
  for (int i = 0; i < pool.size(); i++) {
    float h = hue(pool.get(i));
    pool.set(i, color(h, 100, 100));
  }

  // Deduplicate: keep only colors whose hue is at least MIN_HUE_GAP
  // degrees away from every already-selected color
  float MIN_HUE_GAP = 8;
  ArrayList<Integer> distinct = new ArrayList<Integer>();
  ArrayList<Float> distinctHues = new ArrayList<Float>();

  // Shuffle pool first so we don't always favor the same palette order
  for (int i = pool.size() - 1; i > 0; i--) {
    int j = (int) random(i + 1);
    int tmp = pool.get(i);
    pool.set(i, pool.get(j));
    pool.set(j, tmp);
  }

  for (int i = 0; i < pool.size(); i++) {
    float h = hue(pool.get(i));
    boolean tooClose = false;
    for (int k = 0; k < distinctHues.size(); k++) {
      float diff = abs(h - distinctHues.get(k));
      if (diff > 180) diff = 360 - diff;  // wrap around hue wheel
      if (diff < MIN_HUE_GAP) { tooClose = true; break; }
    }
    if (!tooClose) {
      distinct.add(pool.get(i));
      distinctHues.add(h);
    }
  }
  colorMode(RGB, 255);
  popStyle();

  // Build final PALETTE from distinct colors
  PALETTE = new color[distinct.size()];
  for (int i = 0; i < distinct.size(); i++) {
    PALETTE[i] = distinct.get(i);
  }

  // Shuffle so bots get different colors each run
  for (int i = PALETTE.length - 1; i > 0; i--) {
    int j = (int) random(i + 1);
    color tmp = PALETTE[i];
    PALETTE[i] = PALETTE[j];
    PALETTE[j] = tmp;
  }
}

// Neon synthwave (cyan/magenta/purple)
color[] paletteSynthwave() {
  return new color[] {
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
color[] palettePacMan() {
  return new color[] {
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
color[] paletteNES() {
  return new color[] {
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
color[] paletteCGA() {
  return new color[] {
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
color[] paletteGameBoyColor() {
  return new color[] {
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
color[] paletteSega() {
  return new color[] {
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

// Deep jewel tones
color[] paletteJewel() {
  return new color[] {
    color(180,  20, 120), color(  0, 180, 160), color( 30, 110, 200),
    color(200, 160,  20), color(  0, 200, 180), color(160,  20, 160),
    color( 20, 140, 180), color(200, 100,  20), color(100,  20, 180),
    color( 20, 180, 100), color(180,  60,  80), color( 60, 160, 200),
    color(180, 140,  40), color( 40, 200, 140), color(140,  40, 180),
    color(200,  80, 140), color( 80, 180, 120), color(120,  60, 200),
    color(200, 180,  60), color( 60, 120, 180), color(180,  40, 100),
    color( 40, 200, 200), color(160, 120,  40), color(100,  40, 160),
    color( 40, 160, 160), color(200,  60, 100), color( 60, 200, 100),
    color(140,  80, 200), color(200, 140,  80), color( 80, 140, 200)
  };
}