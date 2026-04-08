# Grid Wars — Game Manual

## What Is Grid Wars?

Grid Wars is a bot-vs-bot territory game. Bots move around a grid claiming cells by color. The bot with the most territory at the end wins. You don't play directly — you write the code that controls your bot.

---

## Quick Start

1. Open `GridWars.pde` in Processing
2. Click the Run button (or press Cmd+R / Ctrl+R)
3. The splash screen shows scrolling credits — press **Spacebar** to see the contenders
4. Press **Spacebar** again (or wait 3 seconds) to start the game
5. Watch your bots compete!

---

## Controls

| Key | Action |
|-----|--------|
| **Spacebar** | Start game / advance through screens |
| **R** | Restart (back to splash screen) |
| **L** | Toggle leaderboard sidebar on/off |
| **Z** | Toggle magnifier on the leading bot |
| **D** | Toggle dim mode (fades non-halo bots to focus on yours) |
| **M** | Mute/unmute music |

---

## Setting Up Your Test Match

Edit `TestConfig.pde` — this is the only file you need to change:

```java
void configureTestBots() {
  addBot("SmithJaneBot", 1, true);  // your bot (with tracking halo)
  addBot("SmartBot", 3);            // 3 tough opponents
  addBot("RandomBot", 2);          // 2 easy opponents
}
```

Each `addBot()` call adds bots to the match. The first argument is the bot class name, the second is how many. The optional third argument `true` adds a **tracking halo** — a pulsing ring around your bot so you can spot it easily. Press **D** during a game to toggle **dim mode**, which fades out non-halo bots so you can focus on yours.

### Available Opponent Bots

| Bot | Strategy |
|-----|----------|
| `SmartBot` | Strong all-around opponent |
| `RandomBot` | Random walk (easy) |

---

## Writing Your Bot

Your bot is a single `.pde` file named `LastnameFirstnameBot.pde` (e.g., `SmithJaneBot.pde`).

```java
class SmithJaneBot extends Bot {

  SmithJaneBot(int startX, int startY, color col, String name) {
    super(startX, startY, col, name);
  }

  Direction getNextMove(GameInfo game) {
    // Your strategy here
    return randomDir();
  }
}
```

Override `getNextMove()` to return `UP`, `DOWN`, `LEFT`, or `RIGHT` each step. See `STUDENT_GUIDE.md` for the full API reference.

---

## Display Settings

If the game window is too large for your screen, open `GridWars.pde` and change:

```java
boolean HIGH_RES = false;  // smaller 1200×750 window
```

---

## What You See During a Game

- **Grid**: The playing field. Black cells are unclaimed. Colored cells belong to bots.
- **Bot indicators**: Glowing squares moving around the grid.
- **Leaderboard** (right side, toggle with L): Live scores sorted by rank.
- **Timer bar** (bottom): Shows time remaining.
- **Magnifier** (toggle with Z): Zoomed view following the leader.

---

## Game Over

When the game ends, the top 4 bots are displayed on a podium:

1. **1st place** — CHAMPION, large glowing name
2. **2nd place** — silver
3. **3rd place** — bronze
4. **4th place** — steel

Press **Spacebar** to play again or **R** to return to the splash screen.
