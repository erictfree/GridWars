// ─────────────────────────────────────────────────────────────
//  TEST CONFIG — Set up your test match here!
//
//  Use addBot("BotName", count) to add bots to the test.
//
//  Available bots:
//    "TestBot"      — strong all-around opponent
//    "StarterBot"   — random walk (easy)
//    "RandomBot"    — random walk
//    "GreedyBot"    — claims nearest free cell
//    "FrontierBot"  — BFS to nearest unclaimed cell
//    "SpiralBot"    — outward spiral pattern
//    "HunterBot"    — targets richest quadrant
//
//  Your bot:
//    Use your class name, e.g. "SmithEmmaBot"
//
//  Example:
//    addBot("SmithEmmaBot", 1);   // your bot
//    addBot("TestBot", 3);         // 3 tough opponents
//    addBot("StarterBot", 2);      // 2 easy opponents
// ─────────────────────────────────────────────────────────────

void configureTestBots() {
  addBot("StarterBot", 5);
  addBot("TestBot", 5);
}
