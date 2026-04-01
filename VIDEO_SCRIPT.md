# Grid Wars — Intro Video Script

**Target length:** 45–75 seconds
**Tone:** Energetic, fast-paced. Game trailer meets quick tutorial.

---

## [OPENING — Game running full speed, territories spreading, retro arcade music]

**VO:**
"This is Grid Wars. Dozens of bots, one grid, thousands of cells. Every step, your bot picks a direction and moves. Land on an empty cell — it's yours. Most territory at the end wins."

## [CUT TO — Code view: MyBot.pde with "extends Bot" highlighted]

**VO:**
"You write a class that extends Bot — that's inheritance. You get movement, rendering, and scoring for free. You override one method: getNextMove. That's polymorphism — the engine calls it on every bot without knowing which class is running."

## [CUT TO — Code view: getNextMove method, grid parameter visible]

**VO:**
"Each step, the engine passes you the grid — a 2D array of who owns what — plus your position. You look around, make a decision, return a direction. Your class can have instance variables to track state between moves — where you've been, where you're headed."

## [CUT TO — Game footage: random bot vs. greedy bot vs. frontier bot side by side]

**VO:**
"A random bot takes five minutes to write. Check your neighbors first? Now you're grabbing free cells. Use BFS to find the nearest open territory? Now you never waste a move. How far you take it is up to you."

## [CUT TO — Tournament bracket, heat playing, results screen]

**VO:**
"We're running a live tournament. Heats, elimination rounds, one champion. Your bot versus everyone else's."

## [CLOSING — Champion screen with confetti]

**VO:**
"One file. One class. One method. Claim everything."

**[Title card: GRID WARS — extend Bot]**

---

## Production Notes

- Fast cuts — show early game, mid game, and full grid in the opening.
- Show code on screen long enough to read the class declaration and getNextMove signature.
- Side-by-side bot comparison: split screen or quick cuts between strategies.
- Use in-game retro music throughout.
- End on the champion confetti screen.
