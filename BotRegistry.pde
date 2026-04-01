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
  testBotList.add(new BotEntry("SmithEmma",    PALETTE[0],  0));   // Random
  testBotList.add(new BotEntry("JohnsonLiam",  PALETTE[1],  1));   // Greedy
  testBotList.add(new BotEntry("WilliamsNoah", PALETTE[2],  2));   // Spiral
  testBotList.add(new BotEntry("BrownOlivia",  PALETTE[3],  3));   // Frontier
  testBotList.add(new BotEntry("JonesSophia",  PALETTE[4],  4));   // Hunter
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
