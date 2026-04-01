// ── Tournament bracket system ────────────────────────────────

class BotEntry {
  String name;
  color col;
  int botType;     // 0=Random,1=Greedy,2=Spiral,3=Frontier,4=Hunter
  boolean alive;   // still in tournament?
  int totalScore;  // accumulated across all heats

  BotEntry(String name, color col, int botType) {
    this.name = name;
    this.col = col;
    this.botType = botType;
    this.alive = true;
    this.totalScore = 0;
  }

  // Creates a bot instance — tries student class by name, falls back to type
  Bot createInstance(int x, int y) {
    // Try student bot class by name
    Bot b = createStudentBot(name, x, y, col);
    if (b != null) return b;
    // Fall back to reference bot type
    switch (botType) {
      case 0:  return new RandomBot(x, y, col, name);
      case 1:  return new GreedyBot(x, y, col, name);
      case 2:  return new SpiralBot(x, y, col, name);
      case 3:  return new FrontierBot(x, y, col, name);
      case 4:  return new HunterBot(x, y, col, name);
      default: return new RandomBot(x, y, col, name);
    }
  }
}

class Heat {
  ArrayList<BotEntry> bots;
  int[] finalScores;
  boolean completed;

  Heat() {
    bots = new ArrayList<BotEntry>();
    completed = false;
  }
}

class TournamentRound {
  ArrayList<Heat> heats;
  int advanceCount;
  String label;

  TournamentRound(String label, int advanceCount) {
    this.label = label;
    this.advanceCount = advanceCount;
    this.heats = new ArrayList<Heat>();
  }
}

// ── Tournament state ────────────────────────────────────────
final int GROUP_SIZE = 16;
final int ADVANCE_COUNT = 4;
final int HEAT_PAUSE_FRAMES = 300;  // 5 sec between heats

ArrayList<BotEntry> allBots;
ArrayList<TournamentRound> rounds;
int currentRound = 0;
int currentHeat = 0;

// Tournament phases: BRACKET, HEAT_INTRO, HEAT_PLAY, HEAT_RESULTS, CHAMPION
int tourneyPhase = 0;
int tourneyTimer = 0;

BotEntry champion = null;

void initTournament() {
  // Use tournament bot registry
  allBots = new ArrayList<BotEntry>();
  for (BotEntry src : tournamentBotList) {
    // Create fresh copies so state resets
    BotEntry entry = new BotEntry(src.name, src.col, src.botType);
    allBots.add(entry);
  }

  buildBracket();
  currentRound = 0;
  currentHeat = 0;
  tourneyPhase = 0;  // BRACKET view
  tourneyTimer = 0;
  champion = null;
}

void buildBracket() {
  rounds = new ArrayList<TournamentRound>();

  // Collect alive bots
  ArrayList<BotEntry> pool = new ArrayList<BotEntry>();
  for (BotEntry b : allBots) {
    if (b.alive) pool.add(b);
  }

  // Shuffle for fairness
  java.util.Collections.shuffle(pool);

  int roundNum = 1;
  while (pool.size() > GROUP_SIZE) {
    // Target ~GROUP_SIZE per heat, but force an even number of heats
    int numGroups = (int) ceil((float) pool.size() / GROUP_SIZE);
    if (numGroups > 2 && numGroups % 2 != 0) {
      numGroups++;  // round up to even
    }
    // Don't create more groups than bots
    numGroups = min(numGroups, pool.size() / 2);

    String label;
    if (pool.size() > 64) label = "ROUND " + roundNum;
    else if (pool.size() > 16) label = "ROUND " + roundNum;
    else if (pool.size() > 8) label = "SEMIFINALS";
    else label = "FINAL";

    TournamentRound round = new TournamentRound(label, ADVANCE_COUNT);

    // Distribute bots evenly across heats
    for (int g = 0; g < numGroups; g++) {
      Heat heat = new Heat();
      round.heats.add(heat);
    }
    for (int i = 0; i < pool.size(); i++) {
      round.heats.get(i % numGroups).bots.add(pool.get(i));
    }

    rounds.add(round);

    // Simulate advancement for bracket building
    ArrayList<BotEntry> nextPool = new ArrayList<BotEntry>();
    for (Heat h : round.heats) {
      // Take first ADVANCE_COUNT (will be sorted by score during actual play)
      int take = min(ADVANCE_COUNT, h.bots.size());
      for (int i = 0; i < take; i++) {
        nextPool.add(h.bots.get(i));
      }
    }
    pool = nextPool;
    roundNum++;
  }

  // Final round
  if (pool.size() > 1) {
    TournamentRound finalRound = new TournamentRound("GRAND FINAL", 1);
    Heat finalHeat = new Heat();
    finalHeat.bots = pool;
    finalRound.heats.add(finalHeat);
    rounds.add(finalRound);
  }
}

// Start the current heat as a game
void startCurrentHeat() {
  TournamentRound round = rounds.get(currentRound);
  Heat heat = round.heats.get(currentHeat);

  // Reset grid
  grid = new int[ROWS][COLS];
  claimFrame = new int[ROWS][COLS];
  for (int r = 0; r < ROWS; r++) {
    java.util.Arrays.fill(grid[r], -1);
  }

  bots = new ArrayList<Bot>();

  int margin = 3;
  boolean[][] taken = new boolean[ROWS][COLS];

  for (int i = 0; i < heat.bots.size(); i++) {
    BotEntry entry = heat.bots.get(i);
    int sx, sy;
    do {
      sx = margin + (int) random(COLS - 2 * margin);
      sy = margin + (int) random(ROWS - 2 * margin);
    } while (taken[sy][sx]);
    taken[sy][sx] = true;

    Bot bot = entry.createInstance(sx, sy);
    addBot(bot);
  }

  stepCount = 0;
  unclaimed = COLS * ROWS - bots.size();
  gameOver = false;
  confettiSpawned = false;
  gameStartMillis = 0;

  scoreHistory = new int[bots.size()][HIST_LEN];
  histCount = 0;
  lastHistStep = 0;

  initEffects();
}

// Record results and advance winners
void finishCurrentHeat() {
  TournamentRound round = rounds.get(currentRound);
  Heat heat = round.heats.get(currentHeat);

  // Sort bots by score
  ArrayList<Bot> sorted = new ArrayList<Bot>(bots);
  java.util.Collections.sort(sorted, new java.util.Comparator<Bot>() {
    public int compare(Bot a, Bot b) {
      return b.score - a.score;
    }
  });

  // Record scores and reorder heat.bots to match
  heat.finalScores = new int[heat.bots.size()];
  ArrayList<BotEntry> reordered = new ArrayList<BotEntry>();
  for (int i = 0; i < sorted.size(); i++) {
    Bot p = sorted.get(i);
    BotEntry entry = heat.bots.get(p.id);
    entry.totalScore += p.score;
    heat.finalScores[i] = p.score;
    reordered.add(entry);
  }
  heat.bots = reordered;
  heat.completed = true;

  // Mark eliminated bots
  for (int i = round.advanceCount; i < heat.bots.size(); i++) {
    heat.bots.get(i).alive = false;
  }
}

// Advance to next heat or round
boolean advanceTournament() {
  TournamentRound round = rounds.get(currentRound);
  currentHeat++;

  if (currentHeat >= round.heats.size()) {
    // Round complete — move to next round
    currentRound++;
    currentHeat = 0;

    if (currentRound >= rounds.size()) {
      // Tournament over — find champion
      TournamentRound lastRound = rounds.get(rounds.size() - 1);
      Heat lastHeat = lastRound.heats.get(0);
      if (lastHeat.bots.size() > 0) {
        champion = lastHeat.bots.get(0);
      }
      return false;  // no more heats
    }

    // Rebuild next round's heats with actual winners
    rebuildNextRound();
  }
  return true;  // more heats to play
}

void rebuildNextRound() {
  if (currentRound >= rounds.size()) return;

  // Collect all surviving bots
  ArrayList<BotEntry> survivors = new ArrayList<BotEntry>();
  for (BotEntry b : allBots) {
    if (b.alive) survivors.add(b);
  }
  java.util.Collections.shuffle(survivors);

  TournamentRound round = rounds.get(currentRound);
  round.heats.clear();

  if (survivors.size() <= GROUP_SIZE) {
    // Final — one heat
    Heat h = new Heat();
    h.bots = survivors;
    round.heats.add(h);
  } else {
    int numGroups = (int) ceil((float) survivors.size() / GROUP_SIZE);
    for (int g = 0; g < numGroups; g++) {
      round.heats.add(new Heat());
    }
    for (int i = 0; i < survivors.size(); i++) {
      round.heats.get(i % numGroups).bots.add(survivors.get(i));
    }
  }
}

// ── Tournament draw functions ───────────────────────────────

void drawBracketView() {
  noStroke();
  fill(0, 190);
  rect(0, 0, width, height);

  float cx = width / 2.0;
  int numRounds = rounds.size();
  TournamentRound curRound = rounds.get(currentRound);
  Heat curHeat = curRound.heats.get(currentHeat);

  // Title
  fill(arcadeBlue);
  textSize(14);
  textAlign(PConstants.CENTER, PConstants.TOP);
  text("TOURNAMENT BRACKET", cx, 12);

  // ── Draw bracket tree ─────────────────────────────────────
  float bracketL = 30;
  float bracketR = width - 30;
  float bracketT = 40;
  float bracketB = height * 0.68;
  float bracketW = bracketR - bracketL;
  float bracketH = bracketB - bracketT;

  float colW = bracketW / numRounds;
  float boxW = colW * 0.65;

  // Pre-compute all heat box positions and centers
  float[][] heatCenterY = new float[numRounds][];
  float[][] heatBoxY    = new float[numRounds][];
  float[] boxHeights    = new float[numRounds];

  for (int ri = 0; ri < numRounds; ri++) {
    int nh = rounds.get(ri).heats.size();
    heatCenterY[ri] = new float[nh];
    heatBoxY[ri]    = new float[nh];
    float spacing = bracketH / max(1, nh);
    float boxH = min(40, spacing - 4);
    boxHeights[ri] = boxH;
    for (int hi = 0; hi < nh; hi++) {
      float by = bracketT + hi * spacing + (spacing - boxH) / 2;
      heatBoxY[ri][hi] = by;
      heatCenterY[ri][hi] = by + boxH / 2;
    }
  }

  // Draw rounds
  for (int ri = 0; ri < numRounds; ri++) {
    TournamentRound rd = rounds.get(ri);
    int nh = rd.heats.size();
    float colX = bracketL + ri * colW;
    float boxH = boxHeights[ri];
    boolean roundDone = (ri < currentRound);
    boolean roundActive = (ri == currentRound);
    boolean roundFuture = (ri > currentRound);

    for (int hi = 0; hi < nh; hi++) {
      Heat h = rd.heats.get(hi);
      float bx = colX + (colW - boxW) / 2;
      float by = heatBoxY[ri][hi];
      float byCtr = heatCenterY[ri][hi];
      boolean isThisHeat = (roundActive && hi == currentHeat);

      // Box fill
      if (h.completed) {
        fill(0, 180, 80, 40);
      } else if (isThisHeat) {
        fill(255, 255, 0, 50);
      } else {
        fill(20, 20, 35);
      }
      noStroke();
      rect(bx, by, boxW, boxH, 4);

      // Box border
      color borderCol;
      if (h.completed) borderCol = color(0, 200, 100);
      else if (isThisHeat) borderCol = color(255, 255, 0);
      else borderCol = color(50, 50, 70);
      stroke(borderCol);
      strokeWeight(1);
      noFill();
      rect(bx, by, boxW, boxH, 4);
      noStroke();

      // Content
      if (h.completed && h.bots.size() > 0) {
        // Show winners
        int showCount = min(rd.advanceCount, h.bots.size());
        float innerRowH = min(10, (boxH - 4) / max(1, showCount));
        for (int wi = 0; wi < showCount; wi++) {
          BotEntry winner = h.bots.get(wi);
          fill(winner.col);
          textSize(min(7, innerRowH - 1));
          textAlign(PConstants.LEFT, PConstants.TOP);
          text(winner.name, bx + 4, by + 2 + wi * innerRowH);
        }
      } else if (roundActive) {
        // Current round — show bot count
        fill(isThisHeat ? color(255, 255, 0) : color(100));
        textSize(min(9, boxH * 0.45));
        textAlign(PConstants.CENTER, PConstants.CENTER);
        text(h.bots.size() + " BOTS", bx + boxW / 2, byCtr);
      } else {
        // Future round — show "?"
        fill(40);
        textSize(min(10, boxH * 0.5));
        textAlign(PConstants.CENTER, PConstants.CENTER);
        text("?", bx + boxW / 2, byCtr);
      }
    }

    // Bracket-style pairing lines to next round
    if (ri < numRounds - 1) {
      int nextNh = rounds.get(ri + 1).heats.size();
      color lineCol = roundDone ? color(0, 255, 100) : arcadeBlue;
      stroke(lineCol);
      strokeWeight(2);

      float lineStartX = colX + (colW + boxW) / 2;
      float lineEndX   = bracketL + (ri + 1) * colW + (colW - boxW) / 2;
      float midX = (lineStartX + lineEndX) / 2;

      // Pair adjacent heats → feed into next round's heats
      // Each pair of current heats merges into one next-round heat
      int heatsPerGroup = max(1, (int) ceil((float) nh / max(1, nextNh)));

      for (int gi = 0; gi < nextNh; gi++) {
        int firstH = gi * heatsPerGroup;
        int lastH  = min(firstH + heatsPerGroup - 1, nh - 1);

        // Vertical center of the target in next round
        float targetY = heatCenterY[ri + 1][gi];

        // Draw horizontal stub from each heat in this group → vertical bar → horizontal to next
        for (int hi2 = firstH; hi2 <= lastH; hi2++) {
          float srcY = heatCenterY[ri][hi2];
          line(lineStartX, srcY, midX, srcY);  // horizontal from heat
        }
        // Vertical bar connecting the group
        float topY = heatCenterY[ri][firstH];
        float botY = heatCenterY[ri][lastH];
        line(midX, topY, midX, botY);  // vertical bar

        // Horizontal from midpoint to next round heat
        float mergeY = (topY + botY) / 2;
        line(midX, mergeY, lineEndX, targetY);
      }
      noStroke();

      // "TOP N" label
      fill(roundDone ? color(0, 200, 100, 80) : color(50));
      textSize(5);
      textAlign(PConstants.CENTER, PConstants.CENTER);
      text("TOP " + rd.advanceCount, midX, bracketT - 6);
    }

    // Round label + bot count below column
    fill(roundActive ? color(255, 255, 0) : (roundDone ? color(0, 200, 100) : color(50)));
    textSize(7);
    textAlign(PConstants.CENTER, PConstants.TOP);
    text(rd.label, colX + colW / 2, bracketB + 4);

    // Show total bots in this round
    int roundBots = 0;
    for (Heat h : rd.heats) roundBots += h.bots.size();
    fill(60);
    textSize(6);
    text(roundBots + " bots", colX + colW / 2, bracketB + 16);
  }

  // ── Current heat details (below bracket) ──────────────────
  float detailY = height * 0.74;

  fill(arcadeBlue);
  textSize(12);
  textAlign(PConstants.CENTER, PConstants.TOP);
  text("NEXT: " + curRound.label + " - HEAT " + (currentHeat + 1) + "/" + curRound.heats.size(), cx, detailY);

  // Competitor list — two columns
  int n = curHeat.bots.size();
  int cols = (n > 5) ? 2 : 1;
  int perCol = (int) ceil((float) n / cols);
  float listW = 160;
  float listX = cx - (cols * listW) / 2;
  float rowH = min(18, (height * 0.16) / perCol);
  float listY = detailY + 22;

  for (int i = 0; i < n; i++) {
    int col = i / perCol;
    int row = i % perCol;
    BotEntry b = curHeat.bots.get(i);
    float bx = listX + col * listW;
    float by = listY + row * rowH;

    fill(b.col);
    rect(bx, by + 2, 8, 8);
    fill(b.col);
    textSize(8);
    textAlign(PConstants.LEFT, PConstants.TOP);
    text(b.name, bx + 12, by + 1);
  }

  // Stats + prompt
  int alive = 0;
  for (BotEntry b : allBots) if (b.alive) alive++;
  fill(60);
  textSize(7);
  textAlign(PConstants.CENTER, PConstants.CENTER);
  text(alive + " BOTS ALIVE  |  TOP " + curRound.advanceCount + " ADVANCE", cx, height * 0.92);

  if ((tourneyTimer % 50) < 35) {
    fill(255, 255, 0);
    textSize(8);
    text("PRESS SPACE TO START", cx, height * 0.96);
  }
}

void drawHeatResults() {
  // Keep game board visible behind results
  drawPlayArea();

  // Semi-transparent overlay so results are readable
  noStroke();
  fill(0, 160);
  rect(0, 0, width, height);

  TournamentRound round = rounds.get(currentRound);
  Heat heat = round.heats.get(currentHeat);

  // Center on game area, not full window
  int gridW = COLS * CELL + INSET * 2;
  float cx = MARGIN + gridW / 2.0;
  int gridH = ROWS * CELL + INSET * 2;
  float gameTop = TOP_MARGIN + MARGIN;

  // Header
  fill(arcadeBlue);
  textSize(16);
  textAlign(PConstants.CENTER, PConstants.TOP);
  text("HEAT RESULTS", cx, gameTop + gridH * 0.08);

  // Results list
  float startY = gameTop + gridH * 0.18;
  float rowH = min(30, (gridH * 0.60) / heat.bots.size());

  for (int i = 0; i < heat.bots.size(); i++) {
    BotEntry b = heat.bots.get(i);
    float by = startY + i * rowH;
    boolean advanced = i < round.advanceCount;

    // Rank
    fill(advanced ? color(255, 255, 0) : color(80));
    textSize(11);
    textAlign(PConstants.RIGHT, PConstants.TOP);
    text(str(i + 1), cx - 90, by + 2);

    // Swatch
    fill(advanced ? b.col : color(red(b.col) * 0.3, green(b.col) * 0.3, blue(b.col) * 0.3));
    rect(cx - 82, by + 3, 10, 10);

    // Name
    fill(advanced ? b.col : color(60));
    textSize(11);
    textAlign(PConstants.LEFT, PConstants.TOP);
    text(b.name, cx - 66, by + 2);

    // Score
    fill(advanced ? color(255) : color(60));
    textSize(11);
    textAlign(PConstants.RIGHT, PConstants.TOP);
    text(nfc(heat.finalScores[i]), cx + 120, by + 2);

    // ADVANCE / ELIMINATED
    if (advanced) {
      fill(0, 255, 128);
      textSize(8);
      textAlign(PConstants.LEFT, PConstants.TOP);
      text("ADVANCE", cx + 130, by + 4);
    } else {
      fill(255, 0, 0, 120);
      textSize(8);
      textAlign(PConstants.LEFT, PConstants.TOP);
      text("OUT", cx + 130, by + 4);
    }
  }

  // Next prompt
  if ((tourneyTimer % 50) < 35) {
    fill(arcadeBlue);
    textSize(10);
    textAlign(PConstants.CENTER, PConstants.CENTER);
    text("PRESS SPACE TO CONTINUE", cx, gameTop + gridH * 0.92);
  }
}

void drawChampionScreen() {
  noStroke();
  fill(0, 180);
  rect(0, 0, width, height);

  float cx = width / 2.0;
  float cy = height / 2.0;

  // Flashing champion text
  boolean blink = (tourneyTimer % 40) < 30;
  if (blink) {
    fill(255, 255, 0);
    textSize(28);
    textAlign(PConstants.CENTER, PConstants.CENTER);
    text("CHAMPION", cx, cy - 50);
  }

  if (champion != null) {
    fill(champion.col);
    textSize(20);
    textAlign(PConstants.CENTER, PConstants.CENTER);
    text(champion.name, cx, cy + 10);

    fill(255);
    textSize(12);
    text("TOTAL SCORE: " + nfc(champion.totalScore), cx, cy + 50);
  }

  fill(arcadeBlue, 80);
  textSize(9);
  textAlign(PConstants.CENTER, PConstants.CENTER);
  text("PRESS R TO RESTART", cx, height * 0.90);
}
