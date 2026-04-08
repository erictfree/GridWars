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

// ─────────────────────────────────────────────────────────────
//  TEST CONFIG — Set up your test match here!
//
//  Use addBot("BotName", count) to add bots to the test.
//  Use addBot("BotName", count, true) to show a tracking halo.
//
//  Available bots:
//    "SmartBot"     — strong all-around opponent
//    "RandomBot"    — random walk (easy)
//
//  Your bot:
//    Use your class name, e.g. "SmithJaneBot"
//
//  Example:
//    addBot("LastnameFirstnameBot", 1, true);  // your bot (with halo)
//    addBot("SmartBot", 3);          // 3 tough opponents
//    addBot("RandomBot", 2);         // 2 easy opponents
// ─────────────────────────────────────────────────────────────

void configureTestBots() {
  addBot("RandomBot", 10);
  addBot("SmartBot", 10, true);
}