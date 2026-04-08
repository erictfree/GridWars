/*
 * GridWars
 * Copyright (c) 2026 Eric Freeman, PhD
 * University of Texas at Austin
 * April 7, 2026
 *
 * MIT License
 *
 * Permission is hereby granted, free of charge, to any person obtaining a copy
 * of this software and associated documentation files (the "Software"), to deal
 * in the Software without restriction, including without limitation the rights
 * to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the Software is
 * furnished to do so, subject to the following conditions:
 *
 * The above copyright notice and this permission notice shall be included in all
 * copies or substantial portions of the Software.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
 * SOFTWARE.
 */

// ── Bot Factory ──────────────────────────────────────────────
// Uses reflection to find bot classes automatically.
// Just drop your .pde file in the sketch folder — no registration needed.

Bot createStudentBot(String className, int x, int y, color c) {
  try {
    // Processing inner classes are named SketchName$ClassName
    Class<?> cls = Class.forName("GridWars$" + className);
    java.lang.reflect.Constructor<?> ctor = cls.getDeclaredConstructor(
      this.getClass(), int.class, int.class, int.class, String.class
    );
    return (Bot) ctor.newInstance(this, x, y, c, className);
  } catch (Exception e) {
    println("Bot not found: " + className + " — " + e);
    return null;
  }
}
