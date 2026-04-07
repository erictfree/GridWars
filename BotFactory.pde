// ── Bot Factory ──────────────────────────────────────────────
// Maps class names to instances.
// Processing doesn't support reflection, so this is a manual lookup.
// Add student bots here before the tournament.

Bot createStudentBot(String className, int x, int y, color c) {
  switch (className) {
    // ── Built-in bots ──────────────────────────────────────
    case "SmartBot":        return new SmartBot(x, y, c, className);
    case "RandomBot":       return new RandomBot(x, y, c, className);
    // ── Student bots (add before tournament) ────────────────
    default: return null;
  }
}
