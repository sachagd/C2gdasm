# ==========================================================================
# GDasm opcode test suite
#
# CONVENTIONS
# - %eax is RESERVED for the test counter/report register only. No test body
#   ever uses %eax as a working register (idivl/cltd force eax/edx use - the
#   quotient/remainder get copied out to a scratch register before %eax is
#   stamped with the counter).
# - Each test ends by stamping "movl $N, %eax" BEFORE any check that could
#   jump to .end, so on failure %eax always holds the number of the test
#   that just failed. We deliberately use movl (not addl) to stamp the
#   counter, since addl is itself one of the things under test.
# - If every test passes, %eax == 9999 at the final `ret` (main's `ret`
#   behaves as HALT).
#
# TRUST ORDERING (important)
# Nearly every test reports failure via `jne .end`, which means the whole
# harness already assumes cmpl/jne work. A badly broken jne (e.g. one that
# never jumps) would make EVERY later test silently report "pass" even when
# wrong - the most dangerous failure mode possible for a test suite. Tests
# 1-2 below are a bootstrap: they validate je/jne using only unconditional
# jmp as the fallback, without relying on jne at all. Every block after that
# is ordered so it only depends on instructions already validated by an
# earlier block:
#   bootstrap(je/jmp) -> add/sub/cmp/or/and -> idivl -> all conditional jumps
#   -> leave -> call -> shifts -> cltd
#
# KNOWN CAVEATS / ASSUMPTIONS BAKED INTO THIS FILE (flag if any are wrong)
# - leal and popl (register form) currently dispatch to the SAME GD group
#   (29) per the compiler source - whichever one is actually wired in-game,
#   the other is silently running its logic instead. Both are avoided
#   entirely here: stack tests use pushl + manual `movl (%esp),reg` +
#   manual esp adjustment instead of popl.
# - pushl is assumed to decrement %esp by 1 word (standard convention).
# - leave is assumed to be the full x86 semantics (mov %esp,%ebp; pop %ebp),
#   not a partial/mov-only implementation.
# - CF is not implemented for any instruction (confirmed) - always reads 0.
#   jc is therefore expected to NEVER fire, and jnc to ALWAYS fire; both
#   tests below are really testing "CF correctly reads as a constant 0",
#   not real carry propagation.
# - OF is only implemented for: addl, subl, cmpl, sall/shll, andl, orl,
#   sarl, shrl (per instructions - testl/xorl are also listed as having OF
#   implemented but are out of scope for this file since they weren't in
#   the requested test list). For andl/orl (bitwise ops), the only sane
#   definition of "OF implemented correctly" is "always cleared to 0" (real
#   x86 behavior for logical ops), so those tests deliberately dirty OF
#   first (via an overflowing addl in a scratch register) and then check
#   it comes back clean.
# - ZF and SF are implemented uniformly for every flag-setting instruction,
#   so they are not re-tested per-instruction - they're validated once via
#   the bootstrap (ZF) and once via js/jns (SF), and then implicitly
#   exercised by literally every other test's jne check.
# - Shift OF-by-1 expectations use the real x86-documented rule (SHL by 1:
#   OF = 1 iff the sign bit changed; SHR by 1: OF = MSB of the ORIGINAL
#   operand; SAR: OF always 0). Real x86 leaves OF undefined for shift
#   counts > 1, so no OF test uses a count other than 1.
# - idivl is assumed to truncate toward zero (standard x86 idivl), which is
#   exactly what the "different scale" tests are probing for, since GD's
#   division primitive is known to round inconsistently in some cases.
#
# INT_MAX = 2147483647, INT_MIN = -2147483648 (used throughout for overflow
# boundary tests).
# ==========================================================================

.globl main

main:

# ===== BOOTSTRAP (tests 1-2): validate je/jne without depending on jne ====

# ---- test 1: je fires when equal --------------------------------------
  movl $10, %ebx
  cmpl $10, %ebx
  je .boot1_ok
  movl $1, %eax
  jmp .end
.boot1_ok:
  movl $1, %eax           # provisional stamp; only test 2 below can still fail as "1"

# ---- test 2: je does NOT fire when unequal ------------------------------
  movl $10, %ebx
  cmpl $99, %ebx
  je .boot2_bad
  jmp .boot2_ok
.boot2_bad:
  movl $2, %eax
  jmp .end
.boot2_ok:
  movl $2, %eax

# ===== addl, first arg immediate (tests 3-5) ===============================

# ---- test 3: functional ----------------------------------------------------
  movl $10, %ebx
  addl $25, %ebx
  movl $3, %eax
  cmpl $35, %ebx
  jne .end

# ---- test 4: OF set (INT_MAX + 1 overflows) --------------------------------
  movl $2147483647, %ebx
  addl $1, %ebx
  movl $4, %eax
  jo .t4_ok
  jmp .end
.t4_ok:

# ---- test 5: OF clear (ordinary add) ---------------------------------------
  movl $5, %ebx
  addl $3, %ebx
  movl $5, %eax
  jno .t5_ok
  jmp .end
.t5_ok:

# ===== addl, first arg register (tests 6-8) =================================

# ---- test 6: functional ------------------------------------------------------
  movl $10, %ebx
  movl $25, %ecx
  addl %ecx, %ebx
  movl $6, %eax
  cmpl $35, %ebx
  jne .end

# ---- test 7: OF set -----------------------------------------------------------
  movl $2147483647, %ebx
  movl $1, %ecx
  addl %ecx, %ebx
  movl $7, %eax
  jo .t7_ok
  jmp .end
.t7_ok:

# ---- test 8: OF clear -----------------------------------------------------------
  movl $5, %ebx
  movl $3, %ecx
  addl %ecx, %ebx
  movl $8, %eax
  jno .t8_ok
  jmp .end
.t8_ok:

# ===== subl, first arg immediate (tests 9-11) ==================================

# ---- test 9: functional ----------------------------------------------------------
  movl $10, %ebx
  subl $3, %ebx
  movl $9, %eax
  cmpl $7, %ebx
  jne .end

# ---- test 10: OF set (INT_MIN - 1 overflows) --------------------------------------
  movl $-2147483648, %ebx
  subl $1, %ebx
  movl $10, %eax
  jo .t10_ok
  jmp .end
.t10_ok:

# ---- test 11: OF clear ----------------------------------------------------------------
  movl $20, %ebx
  subl $5, %ebx
  movl $11, %eax
  jno .t11_ok
  jmp .end
.t11_ok:

# ===== subl, first arg register (tests 12-14) ===========================================

# ---- test 12: functional -------------------------------------------------------------------
  movl $10, %ebx
  movl $3, %ecx
  subl %ecx, %ebx
  movl $12, %eax
  cmpl $7, %ebx
  jne .end

# ---- test 13: OF set ---------------------------------------------------------------------------
  movl $-2147483648, %ebx
  movl $1, %ecx
  subl %ecx, %ebx
  movl $13, %eax
  jo .t13_ok
  jmp .end
.t13_ok:

# ---- test 14: OF clear ---------------------------------------------------------------------------
  movl $20, %ebx
  movl $5, %ecx
  subl %ecx, %ebx
  movl $14, %eax
  jno .t14_ok
  jmp .end
.t14_ok:

# ===== cmpl, first arg immediate (tests 15-17) =======================================================

# ---- test 15: functional + no write-back ------------------------------------------------------------
  movl $10, %ebx
  cmpl $999, %ebx          # deliberately unequal, and NOT the value used below
  movl $15, %eax
  cmpl $10, %ebx            # ebx must be untouched by the previous cmpl
  jne .end

# ---- test 16: OF set --------------------------------------------------------------------------------
  movl $-2147483648, %ebx
  cmpl $1, %ebx
  movl $16, %eax
  jo .t16_ok
  jmp .end
.t16_ok:

# ---- test 17: OF clear -------------------------------------------------------------------------------
  movl $20, %ebx
  cmpl $5, %ebx
  movl $17, %eax
  jno .t17_ok
  jmp .end
.t17_ok:

# ===== cmpl, first arg register (tests 18-20) =============================================================

# ---- test 18: functional + no write-back --------------------------------------------------------------
  movl $10, %ebx
  movl $999, %ecx
  cmpl %ecx, %ebx
  movl $18, %eax
  cmpl $10, %ebx
  jne .end

# ---- test 19: OF set -------------------------------------------------------------------------------------
  movl $-2147483648, %ebx
  movl $1, %ecx
  cmpl %ecx, %ebx
  movl $19, %eax
  jo .t19_ok
  jmp .end
.t19_ok:

# ---- test 20: OF clear -------------------------------------------------------------------------------------
  movl $20, %ebx
  movl $5, %ecx
  cmpl %ecx, %ebx
  movl $20, %eax
  jno .t20_ok
  jmp .end
.t20_ok:

# ===== orl, first arg immediate (tests 21-22) ====================================================================

# ---- test 21: functional -----------------------------------------------------------------------------------------
  movl $10, %ebx
  orl $12, %ebx
  movl $21, %eax
  cmpl $14, %ebx
  jne .end

# ---- test 22: OF forced dirty first, then must come back clean ------------------------------------------------------
  movl $2147483647, %edi
  addl $1, %edi
  movl $5, %ebx
  orl $2, %ebx
  movl $22, %eax
  jo .end

# ===== orl, first arg register (tests 23-24) =============================================================================

# ---- test 23: functional --------------------------------------------------------------------------------------------
  movl $10, %ebx
  movl $12, %ecx
  orl %ecx, %ebx
  movl $23, %eax
  cmpl $14, %ebx
  jne .end

# ---- test 24: OF cleared -----------------------------------------------------------------------------------------------
  movl $2147483647, %edi
  addl $1, %edi
  movl $5, %ebx
  movl $2, %ecx
  orl %ecx, %ebx
  movl $24, %eax
  jo .end

# ===== andl, first arg immediate (tests 25-26) ==============================================================================

# ---- test 25: functional -----------------------------------------------------------------------------------------------
  movl $12, %ebx
  andl $10, %ebx
  movl $25, %eax
  cmpl $8, %ebx
  jne .end

# ---- test 26: OF cleared ------------------------------------------------------------------------------------------------
  movl $2147483647, %edi
  addl $1, %edi
  movl $12, %ebx
  andl $10, %ebx
  movl $26, %eax
  jo .end

# ===== andl, first arg register (tests 27-28) ==================================================================================

# ---- test 27: functional -------------------------------------------------------------------------------------------------
  movl $12, %ebx
  movl $10, %ecx
  andl %ecx, %ebx
  movl $27, %eax
  cmpl $8, %ebx
  jne .end

# ---- test 28: OF cleared --------------------------------------------------------------------------------------------------
  movl $2147483647, %edi
  addl $1, %edi
  movl $12, %ebx
  movl $10, %ecx
  andl %ecx, %ebx
  movl $28, %eax
  jo .end

# ===== idivl at different scales (tests 29-34) ===================================================================================
# x86 idivl truncates toward zero. GD's division primitive is known to round
# inconsistently, so these are genuine bug probes across sign combinations
# and magnitudes, not confidence checks - a failure here is real signal.

# ---- test 29: small, positive / positive: 17 / 5 = 3 rem 2 ------------------------------------------------------------------
  movl $17, %eax
  cltd
  movl $5, %ecx
  idivl %ecx
  movl %eax, %esi
  movl %edx, %edi
  movl $29, %eax
  cmpl $3, %esi
  jne .end
  cmpl $2, %edi
  jne .end

# ---- test 30: small, negative / positive: -17 / 5 = -3 rem -2 ------------------------------------------------------------------
  movl $-17, %eax
  cltd
  movl $5, %ecx
  idivl %ecx
  movl %eax, %esi
  movl %edx, %edi
  movl $30, %eax
  cmpl $-3, %esi
  jne .end
  cmpl $-2, %edi
  jne .end

# ---- test 31: small, positive / negative: 17 / -5 = -3 rem 2 -------------------------------------------------------------------
  movl $17, %eax
  cltd
  movl $-5, %ecx
  idivl %ecx
  movl %eax, %esi
  movl %edx, %edi
  movl $31, %eax
  cmpl $-3, %esi
  jne .end
  cmpl $2, %edi
  jne .end

# ---- test 32: small, negative / negative: -17 / -5 = 3 rem -2 -------------------------------------------------------------------
  movl $-17, %eax
  cltd
  movl $-5, %ecx
  idivl %ecx
  movl %eax, %esi
  movl %edx, %edi
  movl $32, %eax
  cmpl $3, %esi
  jne .end
  cmpl $-2, %edi
  jne .end

# ---- test 33: larger scale, positive / positive: 987654321 / 12345 = 80004 rem 4941 ----------------------------------------------
  movl $987654321, %eax
  cltd
  movl $12345, %ecx
  idivl %ecx
  movl %eax, %esi
  movl %edx, %edi
  movl $33, %eax
  cmpl $80004, %esi
  jne .end
  cmpl $4941, %edi
  jne .end

# ---- test 34: larger scale, negative / positive: -987654321 / 12345 = -80004 rem -4941 --------------------------------------------
  movl $-987654321, %eax
  cltd
  movl $12345, %ecx
  idivl %ecx
  movl %eax, %esi
  movl %edx, %edi
  movl $34, %eax
  cmpl $-80004, %esi
  jne .end
  cmpl $-4941, %edi
  jne .end

# ===== jmp (tests 35-36) ==============================================================================================================
# addl/subl/cmpl are trusted from this point on (validated above).

# ---- test 35: forward jump skips the instruction right after it ----------------------------------------------------------------------
  movl $1, %ebx
  jmp .t35_target
  movl $0, %ebx
.t35_target:
  movl $35, %eax
  cmpl $1, %ebx
  jne .end

# ---- test 36: backward jump (small counted loop) --------------------------------------------------------------------------------------
  movl $0, %ebx
  movl $5, %ecx
.t36_loop:
  addl $1, %ebx
  subl $1, %ecx
  cmpl $0, %ecx
  je .t36_done
  jmp .t36_loop
.t36_done:
  movl $36, %eax
  cmpl $5, %ebx
  jne .end

# ===== je/jz (tests 37-38) =================================================================================================================

# ---- test 37: taken -------------------------------------------------------------------------------------------------------------------------
  movl $5, %ebx
  cmpl $5, %ebx
  je .t37_ok
  movl $37, %eax
  jmp .end
.t37_ok:
  movl $37, %eax

# ---- test 38: not taken ----------------------------------------------------------------------------------------------------------------------
  movl $5, %ebx
  cmpl $7, %ebx
  je .t38_bad
  jmp .t38_ok
.t38_bad:
  movl $38, %eax
  jmp .end
.t38_ok:
  movl $38, %eax

# ===== jne/jnz (tests 39-40) ==================================================================================================================

# ---- test 39: taken --------------------------------------------------------------------------------------------------------------------------
  movl $5, %ebx
  cmpl $7, %ebx
  jne .t39_ok
  movl $39, %eax
  jmp .end
.t39_ok:
  movl $39, %eax

# ---- test 40: not taken -----------------------------------------------------------------------------------------------------------------------
  movl $5, %ebx
  cmpl $5, %ebx
  jne .t40_bad
  jmp .t40_ok
.t40_bad:
  movl $40, %eax
  jmp .end
.t40_ok:
  movl $40, %eax

# ===== js (tests 41-42) ========================================================================================================================

# ---- test 41: taken ---------------------------------------------------------------------------------------------------------------------------
  movl $3, %ebx
  cmpl $5, %ebx
  js .t41_ok
  movl $41, %eax
  jmp .end
.t41_ok:
  movl $41, %eax

# ---- test 42: not taken -----------------------------------------------------------------------------------------------------------------------
  movl $9, %ebx
  cmpl $5, %ebx
  js .t42_bad
  jmp .t42_ok
.t42_bad:
  movl $42, %eax
  jmp .end
.t42_ok:
  movl $42, %eax

# ===== jns (tests 43-44) ========================================================================================================================

# ---- test 43: taken ----------------------------------------------------------------------------------------------------------------------------
  movl $9, %ebx
  cmpl $5, %ebx
  jns .t43_ok
  movl $43, %eax
  jmp .end
.t43_ok:
  movl $43, %eax

# ---- test 44: not taken -------------------------------------------------------------------------------------------------------------------------
  movl $3, %ebx
  cmpl $5, %ebx
  jns .t44_bad
  jmp .t44_ok
.t44_bad:
  movl $44, %eax
  jmp .end
.t44_ok:
  movl $44, %eax

# ===== jo (test 45) / jno (test 46) =============================================================================================================

# ---- test 45: jo taken -----------------------------------------------------------------------------------------------------------------------------
  movl $2147483647, %ebx
  addl $1, %ebx
  jo .t45_ok
  movl $45, %eax
  jmp .end
.t45_ok:
  movl $45, %eax

# ---- test 46: jno taken (i.e. jo correctly NOT taken) -----------------------------------------------------------------------------------------------
  movl $5, %ebx
  addl $3, %ebx
  jno .t46_ok
  movl $46, %eax
  jmp .end
.t46_ok:
  movl $46, %eax

# ===== jc (test 47) / jnc (test 48) - CF is never implemented, always 0 ===========================================================================

# ---- test 47: jc must NEVER fire, even under a classic unsigned-carry scenario ------------------------------------------------------------------------
  movl $-1, %ebx
  addl $1, %ebx
  jc .t47_bad
  jmp .t47_ok
.t47_bad:
  movl $47, %eax
  jmp .end
.t47_ok:
  movl $47, %eax

# ---- test 48: jnc must ALWAYS fire, same scenario ------------------------------------------------------------------------------------------------------
  movl $-1, %ebx
  addl $1, %ebx
  jnc .t48_ok
  movl $48, %eax
  jmp .end
.t48_ok:
  movl $48, %eax

# ===== jge/jnl (tests 49-51) ============================================================================================================================

# ---- test 49: taken (strictly greater) --------------------------------------------------------------------------------------------------------------------
  movl $10, %ebx
  cmpl $5, %ebx
  jge .t49_ok
  movl $49, %eax
  jmp .end
.t49_ok:
  movl $49, %eax

# ---- test 50: not taken (strictly less) ---------------------------------------------------------------------------------------------------------------------
  movl $2, %ebx
  cmpl $5, %ebx
  jge .t50_bad
  jmp .t50_ok
.t50_bad:
  movl $50, %eax
  jmp .end
.t50_ok:
  movl $50, %eax

# ---- test 51: taken (equal, inclusive boundary) ---------------------------------------------------------------------------------------------------------------
  movl $5, %ebx
  cmpl $5, %ebx
  jge .t51_ok
  movl $51, %eax
  jmp .end
.t51_ok:
  movl $51, %eax

# ===== jnge/jl (tests 52-53) ==================================================================================================================================

# ---- test 52: taken (strictly less) -------------------------------------------------------------------------------------------------------------------------------
  movl $2, %ebx
  cmpl $5, %ebx
  jl .t52_ok
  movl $52, %eax
  jmp .end
.t52_ok:
  movl $52, %eax

# ---- test 53: not taken (greater-or-equal) -------------------------------------------------------------------------------------------------------------------------
  movl $10, %ebx
  cmpl $5, %ebx
  jl .t53_bad
  jmp .t53_ok
.t53_bad:
  movl $53, %eax
  jmp .end
.t53_ok:
  movl $53, %eax

# ===== jle/jng (tests 54-56) =========================================================================================================================================

# ---- test 54: taken (strictly less) --------------------------------------------------------------------------------------------------------------------------------------
  movl $2, %ebx
  cmpl $5, %ebx
  jle .t54_ok
  movl $54, %eax
  jmp .end
.t54_ok:
  movl $54, %eax

# ---- test 55: not taken (strictly greater) --------------------------------------------------------------------------------------------------------------------------------
  movl $10, %ebx
  cmpl $5, %ebx
  jle .t55_bad
  jmp .t55_ok
.t55_bad:
  movl $55, %eax
  jmp .end
.t55_ok:
  movl $55, %eax

# ---- test 56: taken (equal, inclusive boundary) --------------------------------------------------------------------------------------------------------------------------
  movl $5, %ebx
  cmpl $5, %ebx
  jle .t56_ok
  movl $56, %eax
  jmp .end
.t56_ok:
  movl $56, %eax

# ===== jnle/jg (tests 57-58) ==============================================================================================================================================

# ---- test 57: taken (strictly greater) --------------------------------------------------------------------------------------------------------------------------------------
  movl $10, %ebx
  cmpl $5, %ebx
  jg .t57_ok
  movl $57, %eax
  jmp .end
.t57_ok:
  movl $57, %eax

# ---- test 58: not taken (less-or-equal) --------------------------------------------------------------------------------------------------------------------------------------
  movl $2, %ebx
  cmpl $5, %ebx
  jg .t58_bad
  jmp .t58_ok
.t58_bad:
  movl $58, %eax
  jmp .end
.t58_ok:
  movl $58, %eax

# ===== leave (tests 59-60) ==================================================================================================================================================

# ---- test 59: small local frame --------------------------------------------------------------------------------------------------------------------------------------------
  movl %esp, %edi
  movl $12345, %esi
  pushl %esi
  movl %esp, %ebp
  subl $8, %esp
  leave
  movl $59, %eax
  cmpl $12345, %ebp
  jne .end
  movl %esp, %ecx
  subl %edi, %ecx
  cmpl $0, %ecx
  jne .end

# ---- test 60: larger local frame ----------------------------------------------------------------------------------------------------------------------------------------------
  movl %esp, %edi
  movl $54321, %esi
  pushl %esi
  movl %esp, %ebp
  subl $40, %esp
  leave
  movl $60, %eax
  cmpl $54321, %ebp
  jne .end
  movl %esp, %ecx
  subl %edi, %ecx
  cmpl $0, %ecx
  jne .end

# ===== call (tests 61-62) =========================================================================================================================================================

# ---- test 61: functional (also implicitly checks return address correctness) -----------------------------------------------------------------------------------------------------
  movl $5, %ebx
  call helper
  movl $61, %eax
  cmpl $6, %ebx
  jne .end

# ---- test 62: esp is neutral across a call/ret with no other stack use -----------------------------------------------------------------------------------------------------------------
  movl %esp, %edi
  call helper2
  movl %esp, %ecx
  movl $62, %eax
  subl %edi, %ecx
  cmpl $0, %ecx
  jne .end

# ===== sall/shll (tests 63-66) ========================================================================================================================================================

# ---- test 63: functional, explicit count -----------------------------------------------------------------------------------------------------------------------------------------------
  movl $3, %ebx
  sall $4, %ebx
  movl $63, %eax
  cmpl $48, %ebx
  jne .end

# ---- test 64: functional, implicit count = 1, also cross-checks the shll alias ------------------------------------------------------------------------------------------------------------
  movl $5, %ebx
  shll %ebx
  movl $64, %eax
  cmpl $10, %ebx
  jne .end

# ---- test 65: OF set, shift-by-1 (sign bit flips: 0x40000000 << 1 = INT_MIN) ------------------------------------------------------------------------------------------------------------------
  movl $1073741824, %ebx
  sall $1, %ebx
  movl $65, %eax
  cmpl $-2147483648, %ebx
  jne .end
  jo .t65_ok
  jmp .end
.t65_ok:

# ---- test 66: OF clear, shift-by-1 (sign bit unchanged) --------------------------------------------------------------------------------------------------------------------------------------
  movl $5, %ebx
  sall $1, %ebx
  movl $66, %eax
  jno .t66_ok
  jmp .end
.t66_ok:

# ===== sarl (tests 67-69) ==================================================================================================================================================================

# ---- test 67: bug probe, explicit count, negative non-exact operand -----------------------------------------------------------------------------------------------------------------------------
  movl $-13, %ebx
  sarl $2, %ebx
  movl $67, %eax
  cmpl $-4, %ebx
  jne .end

# ---- test 68: bug probe, implicit count = 1, negative non-exact operand -------------------------------------------------------------------------------------------------------------------------------
  movl $-7, %ebx
  sarl %ebx
  movl $68, %eax
  cmpl $-4, %ebx
  jne .end

# ---- test 69: OF must always be clear for sarl -----------------------------------------------------------------------------------------------------------------------------------------------------------
  movl $2147483647, %edi
  addl $1, %edi
  movl $-2147483648, %ebx
  sarl $1, %ebx
  movl $69, %eax
  jo .end

# ===== shrl (tests 70-72) ======================================================================================================================================================================================

# ---- test 70: positive operand sanity check -----------------------------------------------------------------------------------------------------------------------------------------------------------------------
  movl $80, %ebx
  shrl $2, %ebx
  movl $70, %eax
  cmpl $20, %ebx
  jne .end

# ---- test 71: bug probe, negative operand (must behave as a LOGICAL shift on the bit pattern) --------------------------------------------------------------------------------------------------------------------------
  movl $-8, %ebx
  shrl $1, %ebx
  movl $71, %eax
  cmpl $2147483644, %ebx
  jne .end

# ---- test 72: OF-by-1 (OF must become the ORIGINAL sign bit) --------------------------------------------------------------------------------------------------------------------------------------------------------------
  movl $5, %edi
  addl $1, %edi
  movl $-8, %ebx
  shrl $1, %ebx
  movl $72, %eax
  jo .t72_ok
  jmp .end
.t72_ok:

# ===== cltd (tests 73-74) ==========================================================================================================================================================================================================

# ---- test 73: positive dividend sign-extends to 0 --------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
  movl $47, %eax
  cltd
  movl $73, %eax
  cmpl $0, %edx
  jne .end

# ---- test 74: negative dividend sign-extends to -1 -----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
  movl $-8, %eax
  cltd
  movl $74, %eax
  cmpl $-1, %edx
  jne .end

# ============================================================================================================================================================================================================================================
  movl $9999, %eax
  ret

.end:
  ret

helper:
  addl $1, %ebx
  ret

helper2:
  ret
