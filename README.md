# GridWars

A real-time bot-vs-bot territory claiming game written by Eric Freeman in [Processing](https://processing.org/) for **AET 310: Creative Coding** at the University of Texas at Austin.

Students write a single bot class that moves around a shared grid, claiming cells by color. The bot with the most territory at the end wins. The game teaches object-oriented programming through practical game design — students override one method, but can build strategies as sophisticated as they want.

## How It Works

Each simulation step, every bot's `getNextMove()` is called. The bot returns a direction (UP, DOWN, LEFT, or RIGHT) and moves one cell. Landing on an **unclaimed cell** claims it and increments the bot's score. Landing on an already-claimed cell does nothing. All bots play simultaneously for the full duration — no elimination.

## Creating a Bot

Create a `.pde` file named `LastnameFirstname.pde` with a class that extends `Bot`:

```java
class LastnameFirstname extends Bot {

  LastnameFirstname(int startX, int startY, color col, String name) {
    super(startX, startY, col, name);
  }

  Direction getNextMove(GameInfo game) {
    // Your strategy here!
    return randomDir();
  }
}
```

Then register your bot in `BotFactory.pde` and test it via `TestConfig.pde`.

### GameInfo API

Query the game world inside `getNextMove()`:

| Method | Description |
|--------|-------------|
| `game.grid[row][col]` | Cell owner ID (-1 if unclaimed) |
| `game.isUnclaimed(row, col)` | Is this cell free? |
| `game.isClaimed(row, col)` | Has any bot claimed this cell? |
| `game.isMine(row, col, id)` | Did I claim this cell? |
| `game.inBounds(row, col)` | Is this coordinate on the grid? |
| `game.getOwner(row, col)` | Owner ID (-1 unclaimed, -2 out of bounds) |
| `game.cols`, `game.rows` | Grid dimensions |
| `game.countUnclaimed()` | Total free cells remaining |
| `game.getNearestBot(x, y, id)` | Find closest opponent |
| `game.getProgress()` | 0.0 to 1.0 game progress |

### Bot Helper Methods

| Method | Description |
|--------|-------------|
| `canClaim(direction)` | Is the cell in that direction free? |
| `peekCell(direction)` | Who owns the cell in that direction? |
| `getFreeDirs()` | List of directions with free cells |

### Built-in Opponents

- **SmartBot** — strong all-around opponent
- **RandomBot** — random walk (easy)

## Testing Your Bot

Edit `TestConfig.pde` to set up a test match:

```java
void configureTestBots() {
  addBot("LastnameFirstname", 1);  // your bot
  addBot("SmartBot", 3);           // 3 tough opponents
  addBot("RandomBot", 2);          // 2 easy opponents
}
```

Press **R** to restart a test match.

## Game Modes

| Mode | How to Start | Description |
|------|-------------|-------------|
| **Test** | Default on launch | Configure your match in `TestConfig.pde` |
| **Tournament** | Admin unlock, then **T** | Multi-round bracket elimination, top 4 advance per heat |
| **Beast** | Admin unlock, then **B** | All bots on one massive grid, arcade-style podium |

## Controls

| Key | Action |
|-----|--------|
| **R** | Restart test match |
| **Z** | Toggle magnifier (follows the leader) |
| **L** | Toggle live leaderboard |
| **M** | Mute/unmute music |

## Requirements

- [Processing 4](https://processing.org/download)
- Processing Sound library (install via Sketch > Import Library > Manage Libraries)

## License

MIT License. See the license header in any `.pde` file for details.

Copyright (c) 2026 Eric Freeman, PhD — University of Texas at Austin
