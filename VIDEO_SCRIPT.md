# Grid Wars — Intro Video Script

**Target length:** 3–4 minutes
**Tone:** Energetic, competitive, clear. Think game trailer meets tutorial.

---

## [OPENING — Show the game running, zoomed in on bots claiming territory]

**VO:**
"This is Grid Wars. Five bots, one grid, thousands of cells up for grabs. Every step, each bot picks a direction — up, down, left, or right — and moves. Land on an empty cell? It's yours. The bot with the most territory at the end wins."

## [CUT TO — Full game view, leaderboard visible, colors spreading across the grid]

**VO:**
"For your end-of-semester project, you're going to build one of these bots. You'll write the brain — the code that decides where to move — and we'll drop it into the arena with everyone else's bots for a live, in-class tournament."

## [CUT TO — Code view of BasePainter.pde, highlight the class structure]

**VO:**
"Here's how it works. The game engine has a class called BasePainter. It handles everything — movement, rendering, scoring, grid interaction. You don't touch any of that."

## [CUT TO — Code view of MyPainter.pde]

**VO:**
"You write a subclass. Your class extends BasePainter. That means you inherit all of its behavior — for free. You override exactly one method: getNextMove."

**[Highlight getNextMove method]**

**VO:**
"getNextMove gets called every step of the simulation. The engine passes you the grid — a 2D array showing who owns every cell — plus the grid dimensions. You check your position, look at the grid, decide your move, and return a direction. That's it. That's your entire job."

## [CUT TO — Game running with RandomBot highlighted, wandering aimlessly]

**VO:**
"The simplest possible bot? Return a random direction. That's actually a valid submission — it'll claim some cells by accident. But it's going to lose to everyone."

## [CUT TO — Game running with GreedyBot, claiming neighbors efficiently]

**VO:**
"One step up: check your four neighbors. If any are unclaimed, go there. Now you never waste a step when there's free territory right next to you. That's a three-line upgrade and it makes a huge difference."

## [CUT TO — Game running with FrontierBot, efficiently filling territory]

**VO:**
"Want to go further? Use BFS — breadth-first search — to find the nearest unclaimed cell anywhere on the grid, then take the first step toward it. Now your bot never wastes a move. It's always heading for open territory."

## [CUT TO — Code showing instance variables in a bot constructor]

**VO:**
"Here's where it gets interesting. Your class can have instance variables — state that persists between calls. Track where you've been. Remember which direction you're sweeping. Count unclaimed cells in different regions and target the emptiest one. Your bot can learn and adapt."

## [CUT TO — OO diagram: BasePainter with arrow to student subclass]

**VO:**
"This is object-oriented programming in action. Inheritance: you extend a base class and get all its behavior. Overriding: you replace one method with your own version. Polymorphism: the engine calls getNextMove on every bot — it doesn't know or care which subclass is running. Encapsulation: you interact through a clean interface without seeing the engine code. These aren't abstract concepts. You're using them to build something that competes."

## [CUT TO — Tournament view, all bots running, leaderboard updating live]

**VO:**
"For the tournament, everyone's bots run on the same grid at the same time. We'll run three rounds and average the scores. You'll see your strategy play out in real time against everyone else's."

## [CUT TO — Customized bots with labels and different glow sizes]

**VO:**
"One more thing — you can customize how your bot looks. Set a label, change the glow size, adjust the trail length. Make it yours."

## [CLOSING — Game over screen with confetti, winner announced]

**VO:**
"You submit one file. One class. One method. The floor is low — a random walker takes five minutes. The ceiling is as high as you want to take it. Good luck. Claim everything."

**[Title card: GRID WARS — extend BasePainter]**

---

## Production Notes

- Record game footage at multiple stages: early game (lots of black), mid game (territories forming), end game (full grid).
- Zoom in on individual bots to show the pixel-art indicators and trails.
- Show code side-by-side with the running game when explaining getNextMove.
- For the OO diagram, keep it simple: one box for BasePainter, one for the student's class, an arrow labeled "extends."
- Background music: use one of the retro themes from the game itself.
- Consider ending with a quick montage of different bot strategies at 2x speed.
