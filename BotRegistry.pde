// ── Bot Registry ────────────────────────────────────────────
// Configure which bots run in each mode.
// All bot .pde files must be in the sketch root folder.

ArrayList<BotEntry> testBotList;
ArrayList<BotEntry> tournamentBotList;

// ─────────────────────────────────────────────────────────────
//  TEST MODE — Press R to restart
// ─────────────────────────────────────────────────────────────
void registerTestBots() {
  testBotList = new ArrayList<BotEntry>();
  // Custom bots (x2)
  testBotList.add(new BotEntry("BotUltimate",  PALETTE[0],  5));
  testBotList.add(new BotEntry("BotUltimate",  PALETTE[1],  5));
  testBotList.add(new BotEntry("BotScavenger", PALETTE[2],  6));
  testBotList.add(new BotEntry("BotScavenger", PALETTE[3],  6));
  testBotList.add(new BotEntry("BotThief",     PALETTE[4],  7));
  testBotList.add(new BotEntry("BotThief",     PALETTE[5],  7));
  testBotList.add(new BotEntry("BotWall",      PALETTE[6],  8));
  testBotList.add(new BotEntry("BotWall",      PALETTE[7],  8));
  testBotList.add(new BotEntry("BotShadow",    PALETTE[8],  9));
  testBotList.add(new BotEntry("BotShadow",    PALETTE[9],  9));
  testBotList.add(new BotEntry("BotDiagonal",  PALETTE[10], 10));
  testBotList.add(new BotEntry("BotDiagonal",  PALETTE[11], 10));
  testBotList.add(new BotEntry("BotZone",      PALETTE[12], 11));
  testBotList.add(new BotEntry("BotZone",      PALETTE[13], 11));
  testBotList.add(new BotEntry("BotPulse",     PALETTE[14], 12));
  testBotList.add(new BotEntry("BotPulse",     PALETTE[15], 12));
  testBotList.add(new BotEntry("BotFlood",     PALETTE[16], 13));
  testBotList.add(new BotEntry("BotFlood",     PALETTE[17], 13));
  testBotList.add(new BotEntry("BotMigrate",   PALETTE[18], 14));
  testBotList.add(new BotEntry("BotMigrate",   PALETTE[19], 14));
  testBotList.add(new BotEntry("BotSprint",    PALETTE[20], 15));
  testBotList.add(new BotEntry("BotSprint",    PALETTE[21], 15));
  // Reference bots (x2)
  testBotList.add(new BotEntry("BotRandom",    PALETTE[22], 0));
  testBotList.add(new BotEntry("BotRandom",    PALETTE[23], 0));
  testBotList.add(new BotEntry("BotGreedy",    PALETTE[24], 1));
  testBotList.add(new BotEntry("BotGreedy",    PALETTE[25], 1));
  testBotList.add(new BotEntry("BotSpiral",    PALETTE[26], 2));
  testBotList.add(new BotEntry("BotSpiral",    PALETTE[27], 2));
  testBotList.add(new BotEntry("BotFrontier",  PALETTE[28], 3));
  testBotList.add(new BotEntry("BotFrontier",  PALETTE[29], 3));
  testBotList.add(new BotEntry("BotHunter",    PALETTE[0],  4));
  testBotList.add(new BotEntry("BotHunter",    PALETTE[1],  4));
}

// ─────────────────────────────────────────────────────────────
//  TOURNAMENT MODE — Press T to start bracket
// ─────────────────────────────────────────────────────────────
void registerTournamentBots() {
  tournamentBotList = new ArrayList<BotEntry>();
  String[] names = {
    "DavisJames", "MillerMia", "WilsonEthan", "MooreAva", "TaylorLucas",
    "AndersonIsla", "ThomasLeo", "JacksonZara", "WhiteNoah", "HarrisLily",
    "MartinOwen", "ThompsonRuby", "GarciaHugo", "MartinezChloe", "RobinsonMax",
    "ClarkEllie", "LewisOscar", "LeeFinn", "WalkerIvy", "HallAria",
    "AllenLuke", "YoungGrace", "HernandezKai", "KingHarper", "WrightNova",
    "LopezAxel", "HillLuna", "ScottMiles", "GreenSienna", "AdamsRiver",
    "BakerWillow", "NelsonJude", "CarterStella", "MitchellFelix", "PerezHazel",
    "RobertsLeo", "TurnerViolet", "PhillipsMilo", "CampbellPiper", "ParkerDante",
    "EvansFreya", "EdwardsAtlas", "CollinsSage", "StewartOrion", "SanchezPearl",
    "MorrisCole", "RogersJasper", "ReedClara", "CookEzra", "MorganMarigold",
    "BellRonan", "MurphyWren", "BaileyTheo", "RiveraJuniper", "CooperAce",
    "RichardsonDaisy", "CoxArcher", "HowardIris", "WardKnox", "TorresSiena",
    "PetersonBlaze", "GrayElara", "RamirezCyrus", "WatsonOpal", "BrooksFinn",
    "KellyWinter", "SandersRory", "PriceAurora", "BennettZane", "WoodLuna",
    "BarnesIndigo", "RossQuinn", "HendersonSky", "ColemanJett", "JenkinsMarlow",
    "PerrySable", "PowellEmber", "LongCaspian", "PattersonLark", "HughesFable",
    "FloresHaven", "WashingtonBree", "ButlerSterling", "SimmonsFern", "FosterCove",
    "GonzalesWynn", "BryantSloane", "AlexanderReed", "RussellMeadow", "GriffinTatum",
    "DiazPeyton", "HayesCamden", "MyersCeleste", "FordKieran", "HamiltonBriar",
    "GrahamSoleil", "SullivanDevon", "WallaceRobin", "WoodsNova", "ColeMarlow",
    "WestJasmine", "OwensSage", "ReynoldsPhoenix", "FisherBlake", "EllisWinter",
    "HarrisonCove"
  };
  for (int i = 0; i < names.length; i++) {
    tournamentBotList.add(new BotEntry(names[i], PALETTE[i % PALETTE.length], i % 5));
  }
}
