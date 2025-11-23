# C → x86 asm → GDasm (Geometry Dash) — Recap

## Goal
Transpile **C** into a custom assembly (**GDasm**) that runs inside **Geometry Dash (GD)**.  
Pipeline: **C → x86 asm (GCC) → parse with ocamllex/menhir → translate to GDasm ops → run via GD triggers**.

---

## Execution Model (ticks, spawn loop, CPU rate)

### GD logic tick (engine)
- GD’s engine updates at **240 Hz** (240 **GD logic ticks** per second).
- You cannot insert work *between* these engine updates.

### Main spawn loop (per GD tick)
- A self-retriggering **main spawn loop** fires **once per GD logic tick**.
- On each fire it **spawns N identical CPU-step spawns**; in your build **N = 500**.
- You **do not offset** these spawns; they are permutation-invariant in your design (each does the same “next-instruction” step). Determinism still holds; order doesn’t affect final state within the frame.

### CPU tick (a.k.a. subtick)
- Each of the N spawns performs **one full CPU step**:
  ```
  PC := PC + 1
  fetch instruction at PC
  decode + execute
  update flags / memory
  commit result
  ```
- Effective CPU rate: **240 × 500 = 120,000 Hz (120 kHz)**.

### What is / isn’t allowed **inside one CPU tick**
- **No spawn-trigger loops** within the same GD logic tick (a trigger won’t re-fire again that frame).
- **Everything else is allowed if fully unrolled**: bounded if/else gating, arithmetic chains, temporary storage, etc.  
  Each GDasm instruction is a **bounded, unrolled microsequence** that **finishes within that CPU tick**.

---

## Control-Flow Rules
- **Inside a CPU tick (subtick):** allow **bounded if/else** and feed-forward logic; **no spawn loops**.
- **Across CPU ticks (program level):** all **loops/branches** are explicit in program asm using **labels + `JMP`/`Jcc`**.  
  The **PC** advances one instruction per **CPU tick** (or jumps).

---

## Compiler Pipeline
1. Write **C** normally (loops, conditionals, drawing via helper calls).
2. Compile to **x86 asm** (you never link/run the binary).
3. Parse asm and map:
   - already-implemented VM ops (`mov/add/sub/mul/and/or/xor/shl/shr/cmp/jmp/jcc/...`) → **GDasm core ops**,
   - **device calls** (declared below) → **GDasm device ops**,
   - `cmp/jcc/jmp` → **GDasm branches**.

> We use **stub declarations** (no definitions) so GCC emits literal `call gd_*` sites that act as **semantic markers**.  
> Register-passing attributes keep arguments parse-friendly.

---

## Device / “System” Markers (current API — minimal; **will be completed later**)

```c
#include <stdint.h>
#include <stdbool.h>

/* Atomic drawing primitive: linearized pixel address */
__attribute__((noinline, regparm(2)))
void gd_putpixel_simplified(int32_t p, int32_t color);   // EAX=p, EDX=color

/* Convenience wrapper: (x,y) → p = x + 80*y */
void gd_putpixel(int32_t x, int32_t y, int32_t c){
    gd_putpixel_simplified(x + 80 * y, c);               // 80 = screen width
}

/* Input polling (atomic) */
__attribute__((noinline)) bool gd_a_pressed();   
__attribute__((noinline)) bool gd_w_pressed();  
__attribute__((noinline)) bool gd_d_pressed();     
__attribute__((noinline)) bool gd_left_pressed();
__attribute__((noinline)) bool gd_up_pressed();   
__attribute__((noinline)) bool gd_right_pressed();  

/* RNG (atomic) */
__attribute__((noinline, regparm(1)))
int32_t gd_randint(int32_t max);                    // EAX=max, returns [0,max)

__attribute__((noinline))
void gd_waitnextframe();
```

---

## Tiering: What you implement where

### Tier A — **In-game atomic primitives** (each = 1 CPU tick, constant cost)
- **Drawing:** `gd_putpixel_simplified(p,color)` (linear address).
- **Input:** the boolean `gd_*_pressed()` polls.
- **Random:** `gd_randint(max)`.
- **Timing:** `gd_waitnextframe()`.

> All scalar ALU/branch ops (`mov/add/sub/.../cmp/jmp/jcc`) are already implemented in your VM. At the C/x86 level, the Tier-A `gd_*` functions above are **declarations only** (no C bodies, never linked or implemented in C). Their sole purpose is to make GCC emit literal `call gd_*` instructions that the transpiler will reinterpret as device ops; the real semantics of these calls live entirely inside the GDasm VM/runtime, not in any C code.

### Tier B — **Compile-time helpers** (expand to program-level loops over Tier A)
No sub-tick loops. GCC emits branches/labels and many pixel writes via the Tier-A primitive(s).

- Horizontal/vertical lines, rectangle outlines, filled rectangles/clears.
- Bresenham line; circle and filled circle (midpoint algorithms).
- Sprites/bitmaps: 1-bit mono blits and indexed blits.
- Text via bitmap fonts (glyphs/strings).

*(Helper names are illustrative categories only; concrete function names are TBD and can be introduced later.)*

---

## Assembly Generation (for clean parsing)
Compile with predictable flags:

```bash
gcc -S your_code.c -m32 -fno-ident -fno-pic -fno-pie -fomit-frame-pointer -fcf-protection=none -fno-stack-protector -fno-unwind-tables -fno-asynchronous-unwind-tables -o your_code.s

```

**Mapping summary (x86 → GDasm)**
- `call gd_putpixel_simplified` → `PUTPIXEL(p=EAX, color=EDX)`
- `call gd_*_pressed` → `READ_INPUT(kind) → EAX`
- `call gd_randint` → `RAND(max=EAX) → EAX`
- `call gd_waitnextframe` → **FRAME_WAIT** (block until next 240 Hz GD logic tick; then continue)
- `cmp/jcc/jmp` → program-level control flow between instructions (across CPU ticks)

---

## Determinism & Ordering
- Triggers in GD evaluate in a deterministic, consistent order inside a GD logic tick.
- In your design, the **N CPU-step spawns are identical**, so the **order of those N subticks does not affect** final state within the frame (permutation-invariant).  
  Determinism is preserved without left→right offsets.

---

## Notes
- You do **not** need `graphics.h` or BIOS interrupts. We use `gd_*` **placeholders** purely to stamp semantic `call` sites in asm and implement behavior **inside GD**.
- The **device API above is intentionally minimal and will be completed** as additional single-tick primitives are defined.

---

## Bottom Line
- Every **GDasm instruction** is a **bounded, unrolled microsequence** that completes in **one CPU tick** (one of your N spawns inside a GD logic tick).  
- The **main spawn loop** at **240 Hz** emits **N = 500** identical CPU ticks per frame → **~120 kHz** effective CPU.  
- **No spawn-trigger loops within a frame**; program-level loops/branches live in the asm (`JMP`/`Jcc`) **across CPU ticks**.  
- Tier A = minimal atomic device ops listed above.  
- Tier B = higher-level drawing/text built by compile-time expansion into many Tier-A calls over many CPU ticks.
