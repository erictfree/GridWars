# Grid Wars — Admin Manual

How to set up and run the tournament and beast mode competitions.

---

## 1. Collecting Student Submissions

Students submit one file each: `LastnameFirstnameBot.pde` (e.g., `SmithJaneBot.pde`). The class name inside must match the file name.

Verify each submission:
- File is named `LastnameFirstnameBot.pde`
- Contains `class LastnameFirstnameBot extends Bot`
- Has the constructor: `LastnameFirstnameBot(int startX, int startY, color col, String name) { super(startX, startY, col, name); }`
- Has `Direction getNextMove(GameInfo game)` that returns a direction
- No references to engine internals, no `exit()` calls, no file I/O

---

## 2. Adding Student Bots to the Project

### Step 1: Copy bot files

Place all student `.pde` files in the `GridBot/` sketch root folder (same level as `GridBot.pde`).

### Step 2: Register in BotFactory.pde

Open `BotFactory.pde` and add a case for each student bot in the switch statement:

```java
// ── Student bots (add before tournament) ────────────────
case "SmithJaneBot":  return new SmithJaneBot(x, y, c, className);
case "SmithJaneBot":    return new SmithJaneBot(x, y, c, className);
// ... one line per student
```

### Step 3: Register in BotRegistry.pde

Open `BotRegistry.pde` and add students to `registerTournamentBots()`:

```java
void registerTournamentBots() {
  tournamentBotList = new ArrayList<BotEntry>();
  
  // Use addTournamentBot(name) or build entries manually:
  String[] students = {
    "SmithJaneBot", "SmithJaneBot", "DoeJohnBot"
    // ... all student bot names
  };
  for (int i = 0; i < students.length; i++) {
    tournamentBotList.add(new BotEntry(students[i], PALETTE[i % PALETTE.length], 0));
  }
}
```

The bot type `0` is a dummy — `createStudentBot()` resolves the name from BotFactory before falling back to type.

### Step 4: Verify

Run the sketch, type `1983` to unlock admin, press **T** for tournament or **B** for beast mode. Confirm all student bots appear.

---

## 3. Admin Unlock

Tournament (T) and Beast Mode (B) keys are locked by default so students can't accidentally trigger them.

**To unlock:** Type `1983` on any screen. "ADMIN UNLOCKED" flashes green. This persists until the sketch is restarted.

---

## 4. Running Tournament Mode

1. Type `1983` to unlock
2. Press **T** — the bracket view appears
3. Press **Spacebar** to start each heat
4. After each heat, results show with advancing bots highlighted
5. Press **Spacebar** to continue to the next heat
6. Tournament progresses: heats → semifinals → grand final → champion screen

### Tournament Structure

- **Group size:** 16 bots per heat (configurable via `GROUP_SIZE` in Tournament.pde)
- **Advancement:** Top 4 per heat advance (configurable via `ADVANCE_COUNT`)
- Bots are shuffled randomly into groups
- Each round rebuilds groups from survivors
- Final round: all remaining bots in one heat, winner takes all

### Tournament Background

Uses `data/headertournament.png`. Replace this file to change the tournament header image.

---

## 5. Running Beast Mode

1. Type `1983` to unlock
2. Press **B** — the beast mode splash appears with scrolling credits
3. Press **Spacebar** — ALL tournament bots play simultaneously on one grid
4. Game runs for 120 seconds
5. Top 4 winners displayed on the podium

Beast mode uses `data/beastbackground.jpg` as the background.

### Running Multiple Beast Mode Rounds

For the 3-round prize structure:
1. Run beast mode (B → Spacebar)
2. Note the winner
3. Press **Spacebar** to play again (auto-restarts beast mode)
4. Repeat for rounds 2 and 3

---

## 6. Music

| Screen | Music Files |
|--------|-------------|
| All splash screens | `pre1.mp3`, `pre2.mp3` (random, no repeats) |
| Test gameplay | `test1.mp3` – `test7.mp3` (random, no repeats) |
| Tournament heats | `theme1.mp3`, `theme2.mp3` (random per heat) |
| Beast mode gameplay | `beast.mp3` |

Music fades between transitions. The mute button (lower-left) persists across all modes.

To add more music: drop MP3s in `data/` and update the random range in `playTestMusic()`, `playRandomTheme()`, or `playPreMusic()` in `GridBot.pde`.

---

## 7. Troubleshooting

### "Bot not found" / bot doesn't appear
- Check that the `.pde` file is in the sketch root folder (not a subfolder)
- Check that the class name in BotFactory.pde matches the file name exactly (case-sensitive)
- Check that the student's constructor calls `super(startX, startY, col, name)`

### Sketch won't compile
- A student bot has a syntax error. Check the Processing console for the error and the offending file name
- Remove the problematic bot file and its BotFactory case temporarily

### Game runs slowly with many bots
- Tournament mode uses `TOURNEY_STEPS = 2` (double speed)
- Reduce `TARGET_ROWS` in `GridBot.pde` for a smaller grid
- Set `HIGH_RES = false` for a smaller window

### Screen too large
- Set `HIGH_RES = false` in `GridBot.pde` for 1200×750

---

## 8. Prize Structure (AET310 Spring 2026)

### Tournament (bracket elimination)

| Place | Prize |
|-------|-------|
| 1st | +10 points |
| 2nd | +5 points |
| 3rd | +3 points |
| 4th | +2 points |

### Beast Mode (3 rounds)

Each round's winner: **+5 points**

**One prize per person.** If you win the tournament, beast mode prizes pass to the next finisher. Multiple beast mode wins → keep only one.

---

## 9. Quick Reference

| Action | How |
|--------|-----|
| Unlock admin | Type `1983` |
| Start tournament | T (after unlock) |
| Start beast mode | B (after unlock) |
| Start/advance | Spacebar |
| Restart to splash | R |
| Toggle leaderboard | L |
| Toggle magnifier | Z |
| Toggle dim mode | D |
| Mute/unmute | Click speaker icon (lower-left) |
| Save screenshots | Set `SAVE_SCREENSHOTS = true` in GridBot.pde |
