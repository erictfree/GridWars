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
