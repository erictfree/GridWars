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

final int RATE_WINDOW = 5;

void drawSidebar() {
  float sw = SIDE - MARGIN;
  float sh = ROWS * CELL + INSET * 2;

  // Outer glow
  noStroke();
  fill(0, 180, 220, 18);
  rect(-3, -3, sw + 6, sh + 6, CORNER + 4);

  // Background — tinted blue-purple glass
  fill(12, 16, 38, 170);
  rect(0, 0, sw, sh, CORNER);

  // Border — bright neon glow
  stroke(arcadeBlue, 160);
  strokeWeight(2);
  noFill();
  rect(1, 1, sw - 2, sh - 2, CORNER);
  noStroke();

  // Title
  fill(arcadeBlue);
  textSize(8);
  textAlign(PConstants.CENTER, PConstants.TOP);
  text("LEADERBOARD", sw / 2, 8);

  stroke(arcadeBlue, 100);
  strokeWeight(1);
  line(8, 22, sw - 8, 22);
  noStroke();

  // Sort
  ArrayList<Bot> sorted = new ArrayList<Bot>(bots);
  java.util.Collections.sort(sorted, new java.util.Comparator<Bot>() {
    public int compare(Bot a, Bot b) {
      return b.score - a.score;
    }
  });

  int n = sorted.size();
  int leaderScore = sorted.get(0).score;

  // Compute rates
  int[] rates = new int[n];
  int maxRate = 1;
  int samples = min(histCount, HIST_LEN);
  for (int i = 0; i < n; i++) {
    int pid = sorted.get(i).id;
    if (samples >= RATE_WINDOW) {
      int oldIdx = (histCount - RATE_WINDOW + HIST_LEN) % HIST_LEN;
      rates[i] = sorted.get(i).score - scoreHistory[pid][oldIdx];
    } else if (samples > 0) {
      int oldIdx = (histCount - samples + HIST_LEN) % HIST_LEN;
      rates[i] = sorted.get(i).score - scoreHistory[pid][oldIdx];
    } else {
      rates[i] = sorted.get(i).score;
    }
    maxRate = max(maxRate, rates[i]);
  }

  // Layout — 3 rows per entry: name, score+delta, meter
  int showing = min(n, 20);  // cap at top 20
  float listTop = 28;
  float listBot = sh - 6;
  float entryH  = min(50, (listBot - listTop) / showing);  // cap height so few entries don't stretch
  float pad     = 6;
  float ex      = pad;
  float ew      = sw - pad * 2;

  // Font sizes — pixel font is wide, keep small
  float nameSz  = constrain(entryH * 0.30, 7, 10);
  float scoreSz = constrain(entryH * 0.26, 7, 9);
  float rankSz  = constrain(entryH * 0.24, 6, 8);
  float deltaSz = constrain(entryH * 0.20, 6, 8);
  float swSz    = constrain(entryH * 0.16, 4, 7);
  float barH    = constrain(entryH * 0.14, 2, 5);

  // Max name length (chars) to prevent overflow
  int maxNameLen = max(6, (int)((ew - 30) / (nameSz * 0.85)));

  for (int vi = 0; vi < showing; vi++) {
    int di = vi;
    Bot p = sorted.get(di);
    float ey = listTop + vi * entryH;

    // Alternating row bg
    if (vi % 2 == 0) {
      fill(6, 6, 16, 100);
      rect(3, ey, sw - 6, entryH);
    }

    // Top-3 highlight
    if (di == 0) {
      fill(255, 255, 0, 15);
      rect(3, ey, sw - 6, entryH);

      // Lead change flash — #1 row flashes bright on takeover
      int leadAge = frameCount - leadChangeFrame;
      if (leadAge < 30) {
        float flash = 1.0 - (float) leadAge / 30;
        float pulse = 0.5 + 0.5 * sin(leadAge * 0.8);
        fill(255, 255, 0, flash * pulse * 120);
        rect(3, ey, sw - 6, entryH);
      }
    } else if (di < 3) {
      fill(255, 255, 255, 5);
      rect(3, ey, sw - 6, entryH);
    }

    // ── Row 1: Rank + Swatch + Name ─────────────────────────
    float row1Y = ey + entryH * 0.18;

    // Rank
    color rankCol;
    if      (di == 0) rankCol = color(255, 255, 0);
    else if (di == 1) rankCol = color(200, 200, 220);
    else if (di == 2) rankCol = color(220, 150, 60);
    else              rankCol = color(60);
    fill(rankCol);
    textSize(rankSz);
    textAlign(PConstants.RIGHT, PConstants.TOP);
    text(str(di + 1), ex + 14, row1Y);

    // Color swatch
    fill(p.col);
    rect(ex + 17, row1Y + 1, swSz, swSz);

    // Name — truncated if needed
    String dn = displayName(p.name);
    if (dn.length() > maxNameLen) {
      dn = dn.substring(0, maxNameLen);
    }
    fill(p.col);
    textSize(nameSz);
    textAlign(PConstants.LEFT, PConstants.TOP);
    text(dn, ex + 20 + swSz, row1Y);

    // ── Row 2: Score + Delta ────────────────────────────────
    float row2Y = ey + entryH * 0.45;

    // Score
    fill(255);
    textSize(scoreSz);
    textAlign(PConstants.LEFT, PConstants.TOP);
    text(nfc(p.score), ex + 20 + swSz, row2Y);

    // Delta
    textSize(deltaSz);
    textAlign(PConstants.RIGHT, PConstants.TOP);
    if (di == 0) {
      fill(255, 255, 0);
      text("LEAD", ex + ew, row2Y + 1);
    } else {
      fill(60);
      text("-" + nfc(leaderScore - p.score), ex + ew, row2Y + 1);
    }

    // ── Row 3: Speed meter ──────────────────────────────────
    float meterY = ey + entryH * 0.72;
    float meterL = ex + 20 + swSz;
    float meterW = ew - 20 - swSz;
    float ratePct = (float) rates[di] / maxRate;

    fill(10, 10, 20);
    rect(meterL, meterY, meterW, barH);

    int segments = max(1, (int)(meterW / 4));
    float segW = meterW / segments;
    int litSegs = (int)(segments * ratePct);

    for (int s = 0; s < litSegs; s++) {
      float t = (float) s / segments;
      color segCol;
      if (t < 0.5) {
        segCol = lerpColor(color(0, 180, 0), color(255, 255, 0), t * 2);
      } else {
        segCol = lerpColor(color(255, 255, 0), color(255, 0, 0), (t - 0.5) * 2);
      }
      fill(segCol);
      rect(meterL + s * segW, meterY, segW - 1, barH);
    }
  }
}