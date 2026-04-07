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
