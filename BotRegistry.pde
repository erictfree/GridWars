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

// ── Bot Registry ────────────────────────────────────────────
// Configure which bots run in each mode.
// All bot .pde files must be in the sketch root folder.

ArrayList<BotEntry> testBotList;
ArrayList<BotEntry> tournamentBotList;

// ─────────────────────────────────────────────────────────────
//  TEST MODE — Press R to restart
//  Students configure their test match in TestConfig.pde
// ─────────────────────────────────────────────────────────────
int addBotColorIdx = 0;

void registerTestBots() {
  testBotList = new ArrayList<BotEntry>();
  addBotColorIdx = 0;
  configureTestBots();  // defined in TestConfig.pde
}

void addBot(String name, int count) {
  for (int i = 0; i < count; i++) {
    color c = PALETTE[addBotColorIdx % PALETTE.length];
    addBotColorIdx++;
    testBotList.add(new BotEntry(name, c, 0));
  }
}

// ─────────────────────────────────────────────────────────────
//  TOURNAMENT MODE — Press T to start bracket
//  Add student bots here before tournament day
// ─────────────────────────────────────────────────────────────
void registerTournamentBots() {
  tournamentBotList = new ArrayList<BotEntry>();
}