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
  testBotList.add(new BotEntry("SmithEmma",       PALETTE[0],  0));
  testBotList.add(new BotEntry("JohnsonLiam",     PALETTE[1],  1));
  testBotList.add(new BotEntry("WilliamsNoah",    PALETTE[2],  2));
  testBotList.add(new BotEntry("BrownOlivia",     PALETTE[3],  3));
  testBotList.add(new BotEntry("JonesSophia",     PALETTE[4],  4));
  testBotList.add(new BotEntry("GarciaHugo",      PALETTE[5],  1));
  testBotList.add(new BotEntry("MartinezChloe",   PALETTE[6],  3));
  testBotList.add(new BotEntry("DavisJames",      PALETTE[7],  0));
  testBotList.add(new BotEntry("RobinsonMax",     PALETTE[8],  4));
  testBotList.add(new BotEntry("ClarkEllie",      PALETTE[9],  2));
  testBotList.add(new BotEntry("HallAria",        PALETTE[10], 1));
  testBotList.add(new BotEntry("LewisOscar",      PALETTE[11], 3));
  testBotList.add(new BotEntry("WalkerIvy",       PALETTE[12], 0));
  testBotList.add(new BotEntry("PerezHazel",      PALETTE[13], 4));
  testBotList.add(new BotEntry("HillLuna",        PALETTE[14], 2));
  testBotList.add(new BotEntry("GreenSienna",     PALETTE[15], 1));
  testBotList.add(new BotEntry("AdamsRiver",      PALETTE[16], 3));
  testBotList.add(new BotEntry("NelsonJude",      PALETTE[17], 0));
  testBotList.add(new BotEntry("CookEzra",        PALETTE[18], 4));
  testBotList.add(new BotEntry("MooreAva",        PALETTE[19], 2));
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
