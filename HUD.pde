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

void drawHUD() {
  float hx = 0;
  float hy = ROWS * CELL;
  float hw = COLS * CELL;

  // Timer
  int elapsed = (gameStartMillis > 0) ? millis() - gameStartMillis : 0;
  int remaining = max(0, GAME_TIME_MS - elapsed);
  int secs = remaining / 1000;
  float progress = constrain((float) elapsed / GAME_TIME_MS, 0, 1);

  // Progress bar — thin strip at bottom of grid
  float barH = 4;
  fill(20, 60);
  noStroke();
  rect(hx, hy, hw, barH);

  color barColor = progress < 0.75 ? arcadeBlue : color(255, 0, 0);
  fill(barColor);
  rect(hx, hy, hw * progress, barH);

  // Time remaining — right-aligned under the grid
  fill(secs <= 10 ? color(255, 0, 0) : color(180));
  textSize(9);
  textAlign(PConstants.RIGHT, PConstants.TOP);
  String timeStr = nf(secs / 60, 1) + ":" + nf(secs % 60, 2);
  text(timeStr, hw - 4, hy + barH + 2);

  // FPS + particle counter
  fill(255, 255, 0, 150);
  textSize(8);
  textAlign(PConstants.LEFT, PConstants.TOP);
  text((int) frameRate + " FPS  P:" + particles.size(), 4, hy + barH + 2);
}