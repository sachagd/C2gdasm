# C → x86 asm → GDasm (Geometry Dash) — Concise Recap

## Goal
Transpile **C** into a custom assembly (**GDasm**) that runs inside **Geometry Dash (GD)**.  
Pipeline: **C → x86 asm (GCC) → parse with ocamllex/menhir → translate to GDasm ops → run via GD triggers**.

---

## GD Runtime Model (Timing & Determinism)
- GD runs at **240 ticks/sec**.
- Each tick, a self-retriggering **Spawn loop** fans out a **fixed set of triggers** laid **left→right** for deterministic sub-tick order (you can emulate “240×M” effective sub-ticks per frame).
- **One GDasm instruction per CPU tick**: each instruction expands to a **constant-size** micro-sequence of GD triggers and **finishes within that tick**.
- **No trigger may spawn itself within the same tick** (no sub-tick back-edges).

---

## Control-Flow Rules
- **Inside a tick (sub-tick window):** allow **if/else gating** (predicated paths), **no loops**.
- **Across ticks (program level):** all **loops/branches** must be explicit in the program asm using **labels + `JMP`/`Jcc`**.  
  The **PC** advances one instruction per tick (or jumps).

---

## Compiler Pipeline
1. Write **C** normally (loops, conditionals, drawing via helper calls).
2. Compile to **x86 asm** (you never link/run the binary).
3. Parse asm and map:
   - already-implemented VM ops (`mov/add/sub/mul/and/or/xor/shl/shr/cmp/jmp/jnz/jne/...`) → **GDasm core ops**,
   - **graphics/system calls** (declared below) → **GDasm device ops**,
   - `cmp/jcc/jmp` → **GDasm branches**.

> We use **stub declarations** (no definitions) so GCC emits clean `call` sites that act as **semantic markers**.

---

## Graphics / “System” Placeholders (Markers Only)
These are **declarations** (no definitions). They exist only to make GCC emit `call gd_*` with args in registers (easy to parse).

    #include <stdint.h>

    __attribute__((noinline, regparm(3))) void gd_setmode(uint32_t mode);
    __attribute__((noinline, regparm(3))) void gd_putpixel(uint32_t x, uint32_t y, uint8_t c);

    // Optional, only if you will implement them as constant-cost single-tick ops:
    __attribute__((noinline, regparm(3))) void gd_setpalette(uint8_t idx, uint8_t r, uint8_t g);
    __attribute__((noinline, regparm(3))) void gd_settarget(uint32_t id, uint32_t _, uint32_t __);
    __attribute__((noinline, regparm(3))) void gd_swapbuffers(uint32_t which, uint32_t _, uint32_t __);

- `noinline` ⇒ guarantees a literal `call` in asm.
- `regparm(3)` ⇒ first 3 args in **EAX, EDX, ECX** (very parse-friendly).

---

## What You Implement Where

### Tier A — **In-game atomic primitives** (each = 1 instruction, constant sub-tick cost)
- **Required:** `gd_putpixel(x,y,c)` — essential drawing primitive.
- **Init/Context:** `gd_setmode(mode)` — one-time init or context switch.
- **Optional:** `gd_setpalette`, `gd_settarget`, `gd_swapbuffers` — only if each can be done with a fixed, bounded sub-tick footprint.

> All scalar ALU/branch ops (`mov/add/sub/.../cmp/jmp/jcc`) are already implemented in your VM and are **not** part of this list.

### Tier B — **Compile-time helpers** (expand to program-level loops/branches using Tier A)
No sub-tick loops. GCC emits `cmp/jcc/jmp` and many `call gd_putpixel`.

- `gd_hline(x,y,len,c)` → loop `i=0..len-1`: `gd_putpixel(x+i, y, c)`
- `gd_vline(x,y,len,c)` → loop `j=0..len-1`: `gd_putpixel(x, y+j, c)`
- `gd_rect_outline(x,y,w,h,c)` → 2×hline + 2×vline
- `gd_fillrect(x,y,w,h,c)` / `gd_clear_region(...)` → nested loops calling `gd_putpixel`
- `gd_line(x0,y0,x1,y1,c)` → **Bresenham** loop
- `gd_circle(cx,cy,r,c)` / `gd_fillcircle(...)` → midpoint algorithm loops
- **Sprites/Bitmaps:**
  - `gd_blit_mono(x,y,w,h,const uint8_t* bits,c)` (per-bit conditional putpixel)
  - `gd_blit_indexed(x,y,w,h,const uint8_t* idx)` (per-texel putpixel)
- **Text (bitmap font):** `gd_putglyph_8x8`, `gd_puts_8x8` (loops over bits/chars)
- **Palette bulk:** `gd_use_palette(p)` → expands to many `gd_setpalette(...)` calls

These helpers **create explicit asm control flow** (labels + `Jcc/JMP`) and many atomic `gd_putpixel` calls, executing over **multiple ticks** as needed.  
Inside a single tick, only **bounded if/else gating** is allowed; **no loops**.

---

## Assembly Generation (for clean parsing)
Compile with predictable flags:

    gcc -m32 -O0 -fno-pic -fno-pie \
        -fno-asynchronous-unwind-tables -fno-unwind-tables -fno-stack-protector \
        -S -masm=intel your_code.c -o your_code.s

Expect patterns like:

    mov   <x expr>, eax
    mov   <y expr>, edx
    mov   <c expr>, ecx
    call  gd_putpixel          ; → map to GDasm PUTPIXEL(EAX,EDX,ECX)

    cmp   r?, r?
    jcc   .Lx                  ; → map to GDasm conditional branch
    jmp   .Ly                  ; → map to GDasm jump

---

## Notes on BIOS/graphics.h
- You do **not** need `graphics.h` or real BIOS interrupts. We use `gd_*` **placeholders** as semantic markers in asm and implement behavior **inside GD**.
- Real `int 10h, ah=00h` (set mode) would be used **once** in BIOS land; analog here is **one `gd_setmode` at init**, then draw via `gd_putpixel`.

---

## Bottom Line
- Every **GDasm instruction** has a **constant, bounded sub-tick footprint** and **finishes within one CPU tick**.  
- **Loops/branches live in the program asm** (across ticks), never inside a sub-tick.  
- Tier A = minimal **device ops** you implement in GD (e.g., `gd_putpixel`, `gd_setmode`).  
- Tier B = higher-level drawing built by **program-level loops** that call Tier A many times.
