# ==========================================================================
# GDasm opcode test suite
#
# CONVENTIONS
# - %eax is RESERVED for the test counter/report register only.
# - Each test stamps "movl $N, %eax" right before any check that could jump
#   to .end, so on failure %eax holds the number of the first test that
#   failed. Counter is stamped via movl (not addl), since addl is itself
#   under test. If every test passes, %eax == 9999 at the final `ret`.
#
# TRUST ORDERING
# Every test reports failure via `jne .end` (or jo/jno/je/jl/etc against
# .end), so the harness already assumes cmpl/jne work. Tests 1-2 are a
# bootstrap that validates je/jne using only unconditional jmp as fallback,
# without relying on jne. Everything after is ordered so each block only
# depends on instructions already validated by an earlier block:
#   bootstrap -> add/sub/cmp/or/and/test -> idivl -> conditional jumps
#   -> pushl -> leave -> call -> shifts -> cltd -> popl -> leal
#
# KNOWN CAVEATS / ASSUMPTIONS BAKED INTO THIS FILE
# - pushl is assumed to decrement %esp by 1 word (standard convention).
# - leave is assumed to be full x86 semantics (mov %esp,%ebp; pop %ebp).
# - CF is not implemented for any instruction - always reads 0. jc is
#   expected to NEVER fire, jnc to ALWAYS fire.
# - OF is only implemented for: addl, subl, cmpl, sall/shll, andl, orl,
#   testl, sarl, shrl. For the bitwise ops (andl/orl/testl) the only sane
#   "OF implemented correctly" is "always cleared to 0" (real x86 behavior
#   for logical ops), so those tests dirty OF first via a scratch-register
#   overflow, then check it comes back clean.
# - ZF/SF are implemented uniformly, so not re-tested per instruction -
#   validated once via the bootstrap (ZF) and js/jns (SF), then implicitly
#   exercised by every other test's jne check.
# - Shift OF-by-1 uses the real x86-documented rule (SHL by 1: OF = 1 iff
#   sign bit changed; SHR by 1: OF = MSB of the ORIGINAL operand; SAR:
#   OF always 0). Real x86 leaves OF undefined for counts > 1, so no OF
#   test uses a count other than 1.
# - idivl is assumed to truncate toward zero (standard x86), which is what
#   the "different scale" tests are probing for, since GD's division
#   primitive is known to round inconsistently in some cases.
#
# INT_MAX = 2147483647, INT_MIN = -2147483648.
# ==========================================================================

main:

# ===== BOOTSTRAP (tests 1-2) ================================================

# ---- test 1: je fires when equal --------------------------------------
  movl $10, %ebx
  cmpl $10, %ebx
  je .boot1_ok
  movl $1, %eax
  jmp .end
.boot1_ok:
  movl $1, %eax

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
  cmpl $999, %ebx
  movl $15, %eax
  cmpl $10, %ebx
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

# ===== testl (tests 29-33) ======================================================================================================
# testl has three distinct dispatch paths: the same-register special case
# (testl %r,%r), and the generic imm-src / reg-src forms.

# ---- test 29: same-register form, ZF set (0 & 0 == 0) ----------------------------------------------------------------------------
  movl $0, %ebx
  testl %ebx, %ebx
  movl $29, %eax
  jne .end

# ---- test 30: same-register form, ZF clear (nonzero & itself == nonzero) ---------------------------------------------------------
  movl $5, %ebx
  testl %ebx, %ebx
  movl $30, %eax
  je .end

# ---- test 31: generic imm-src, functional + no write-back -------------------------------------------------------------------------
  movl $5, %ebx
  testl $2, %ebx           # 5 & 2 = 0 -> ZF set
  movl $31, %eax
  jne .end
  cmpl $5, %ebx               # testl must not modify its operand
  jne .end

# ---- test 32: generic reg-src, functional + no write-back -------------------------------------------------------------------------
  movl $6, %ebx
  movl $3, %ecx
  testl %ecx, %ebx            # 6 & 3 = 2 -> ZF clear
  movl $32, %eax
  je .end
  cmpl $6, %ebx
  jne .end

# ---- test 33: OF forced dirty first, then must come back clean ----------------------------------------------------------------------
  movl $2147483647, %edi
  addl $1, %edi
  movl $5, %ebx
  movl $2, %ecx
  testl %ecx, %ebx
  movl $33, %eax
  jo .end

# ===== idivl at different scales (tests 34-39) ===================================================================================
# x86 idivl truncates toward zero. GD's division primitive is known to round
# inconsistently, so these are genuine bug probes, not confidence checks.

# ---- test 34: small, positive / positive: 17 / 5 = 3 rem 2 ------------------------------------------------------------------
  movl $17, %eax
  cltd
  movl $5, %ecx
  idivl %ecx
  movl %eax, %esi
  movl %edx, %edi
  movl $34, %eax
  cmpl $3, %esi
  jne .end
  cmpl $2, %edi
  jne .end

# ---- test 35: small, negative / positive: -17 / 5 = -3 rem -2 ------------------------------------------------------------------
  movl $-17, %eax
  cltd
  movl $5, %ecx
  idivl %ecx
  movl %eax, %esi
  movl %edx, %edi
  movl $35, %eax
  cmpl $-3, %esi
  jne .end
  cmpl $-2, %edi
  jne .end

# ---- test 36: small, positive / negative: 17 / -5 = -3 rem 2 -------------------------------------------------------------------
  movl $17, %eax
  cltd
  movl $-5, %ecx
  idivl %ecx
  movl %eax, %esi
  movl %edx, %edi
  movl $36, %eax
  cmpl $-3, %esi
  jne .end
  cmpl $2, %edi
  jne .end

# ---- test 37: small, negative / negative: -17 / -5 = 3 rem -2 -------------------------------------------------------------------
  movl $-17, %eax
  cltd
  movl $-5, %ecx
  idivl %ecx
  movl %eax, %esi
  movl %edx, %edi
  movl $37, %eax
  cmpl $3, %esi
  jne .end
  cmpl $-2, %edi
  jne .end

# ---- test 38: larger scale, positive / positive: 987654321 / 12345 = 80004 rem 4941 ----------------------------------------------
  movl $987654321, %eax
  cltd
  movl $12345, %ecx
  idivl %ecx
  movl %eax, %esi
  movl %edx, %edi
  movl $38, %eax
  cmpl $80004, %esi
  jne .end
  cmpl $4941, %edi
  jne .end

# ---- test 39: larger scale, negative / positive: -987654321 / 12345 = -80004 rem -4941 --------------------------------------------
  movl $-987654321, %eax
  cltd
  movl $12345, %ecx
  idivl %ecx
  movl %eax, %esi
  movl %edx, %edi
  movl $39, %eax
  cmpl $-80004, %esi
  jne .end
  cmpl $-4941, %edi
  jne .end

# ===== jmp (tests 40-41) ==============================================================================================================
# addl/subl/cmpl/testl are trusted from this point on (validated above).

# ---- test 40: forward jump skips the instruction right after it ----------------------------------------------------------------------
  movl $1, %ebx
  jmp .t40_target
  movl $0, %ebx
.t40_target:
  movl $40, %eax
  cmpl $1, %ebx
  jne .end

# ---- test 41: backward jump (small counted loop) --------------------------------------------------------------------------------------
  movl $0, %ebx
  movl $5, %ecx
.t41_loop:
  addl $1, %ebx
  subl $1, %ecx
  cmpl $0, %ecx
  je .t41_done
  jmp .t41_loop
.t41_done:
  movl $41, %eax
  cmpl $5, %ebx
  jne .end

# ===== je/jz (tests 42-43) =================================================================================================================

# ---- test 42: taken -------------------------------------------------------------------------------------------------------------------------
  movl $5, %ebx
  cmpl $5, %ebx
  je .t42_ok
  movl $42, %eax
  jmp .end
.t42_ok:
  movl $42, %eax

# ---- test 43: not taken ----------------------------------------------------------------------------------------------------------------------
  movl $5, %ebx
  cmpl $7, %ebx
  je .t43_bad
  jmp .t43_ok
.t43_bad:
  movl $43, %eax
  jmp .end
.t43_ok:
  movl $43, %eax

# ===== jne/jnz (tests 44-45) ==================================================================================================================

# ---- test 44: taken --------------------------------------------------------------------------------------------------------------------------
  movl $5, %ebx
  cmpl $7, %ebx
  jne .t44_ok
  movl $44, %eax
  jmp .end
.t44_ok:
  movl $44, %eax

# ---- test 45: not taken -----------------------------------------------------------------------------------------------------------------------
  movl $5, %ebx
  cmpl $5, %ebx
  jne .t45_bad
  jmp .t45_ok
.t45_bad:
  movl $45, %eax
  jmp .end
.t45_ok:
  movl $45, %eax

# ===== js (tests 46-47) ========================================================================================================================

# ---- test 46: taken ---------------------------------------------------------------------------------------------------------------------------
  movl $3, %ebx
  cmpl $5, %ebx
  js .t46_ok
  movl $46, %eax
  jmp .end
.t46_ok:
  movl $46, %eax

# ---- test 47: not taken -----------------------------------------------------------------------------------------------------------------------
  movl $9, %ebx
  cmpl $5, %ebx
  js .t47_bad
  jmp .t47_ok
.t47_bad:
  movl $47, %eax
  jmp .end
.t47_ok:
  movl $47, %eax

# ===== jns (tests 48-49) ========================================================================================================================

# ---- test 48: taken ----------------------------------------------------------------------------------------------------------------------------
  movl $9, %ebx
  cmpl $5, %ebx
  jns .t48_ok
  movl $48, %eax
  jmp .end
.t48_ok:
  movl $48, %eax

# ---- test 49: not taken -------------------------------------------------------------------------------------------------------------------------
  movl $3, %ebx
  cmpl $5, %ebx
  jns .t49_bad
  jmp .t49_ok
.t49_bad:
  movl $49, %eax
  jmp .end
.t49_ok:
  movl $49, %eax

# ===== jo (test 50) / jno (test 51) =============================================================================================================

# ---- test 50: jo taken -----------------------------------------------------------------------------------------------------------------------------
  movl $2147483647, %ebx
  addl $1, %ebx
  jo .t50_ok
  movl $50, %eax
  jmp .end
.t50_ok:
  movl $50, %eax

# ---- test 51: jno taken (i.e. jo correctly NOT taken) -----------------------------------------------------------------------------------------------
  movl $5, %ebx
  addl $3, %ebx
  jno .t51_ok
  movl $51, %eax
  jmp .end
.t51_ok:
  movl $51, %eax

# ===== jc (test 52) / jnc (test 53) - CF is never implemented, always 0 ===========================================================================

# ---- test 52: jc must NEVER fire, even under a classic unsigned-carry scenario ------------------------------------------------------------------------
  movl $-1, %ebx
  addl $1, %ebx
  jc .t52_bad
  jmp .t52_ok
.t52_bad:
  movl $52, %eax
  jmp .end
.t52_ok:
  movl $52, %eax

# ---- test 53: jnc must ALWAYS fire, same scenario ------------------------------------------------------------------------------------------------------
  movl $-1, %ebx
  addl $1, %ebx
  jnc .t53_ok
  movl $53, %eax
  jmp .end
.t53_ok:
  movl $53, %eax

# ===== jge/jnl (tests 54-56) ============================================================================================================================

# ---- test 54: taken (strictly greater) --------------------------------------------------------------------------------------------------------------------
  movl $10, %ebx
  cmpl $5, %ebx
  jge .t54_ok
  movl $54, %eax
  jmp .end
.t54_ok:
  movl $54, %eax

# ---- test 55: not taken (strictly less) ---------------------------------------------------------------------------------------------------------------------
  movl $2, %ebx
  cmpl $5, %ebx
  jge .t55_bad
  jmp .t55_ok
.t55_bad:
  movl $55, %eax
  jmp .end
.t55_ok:
  movl $55, %eax

# ---- test 56: taken (equal, inclusive boundary) ---------------------------------------------------------------------------------------------------------------
  movl $5, %ebx
  cmpl $5, %ebx
  jge .t56_ok
  movl $56, %eax
  jmp .end
.t56_ok:
  movl $56, %eax

# ===== jnge/jl (tests 57-58) ==================================================================================================================================

# ---- test 57: taken (strictly less) -------------------------------------------------------------------------------------------------------------------------------
  movl $2, %ebx
  cmpl $5, %ebx
  jl .t57_ok
  movl $57, %eax
  jmp .end
.t57_ok:
  movl $57, %eax

# ---- test 58: not taken (greater-or-equal) -------------------------------------------------------------------------------------------------------------------------
  movl $10, %ebx
  cmpl $5, %ebx
  jl .t58_bad
  jmp .t58_ok
.t58_bad:
  movl $58, %eax
  jmp .end
.t58_ok:
  movl $58, %eax

# ===== jle/jng (tests 59-61) =========================================================================================================================================

# ---- test 59: taken (strictly less) --------------------------------------------------------------------------------------------------------------------------------------
  movl $2, %ebx
  cmpl $5, %ebx
  jle .t59_ok
  movl $59, %eax
  jmp .end
.t59_ok:
  movl $59, %eax

# ---- test 60: not taken (strictly greater) --------------------------------------------------------------------------------------------------------------------------------
  movl $10, %ebx
  cmpl $5, %ebx
  jle .t60_bad
  jmp .t60_ok
.t60_bad:
  movl $60, %eax
  jmp .end
.t60_ok:
  movl $60, %eax

# ---- test 61: taken (equal, inclusive boundary) --------------------------------------------------------------------------------------------------------------------------
  movl $5, %ebx
  cmpl $5, %ebx
  jle .t61_ok
  movl $61, %eax
  jmp .end
.t61_ok:
  movl $61, %eax

# ===== jnle/jg (tests 62-63) ==============================================================================================================================================

# ---- test 62: taken (strictly greater) --------------------------------------------------------------------------------------------------------------------------------------
  movl $10, %ebx
  cmpl $5, %ebx
  jg .t62_ok
  movl $62, %eax
  jmp .end
.t62_ok:
  movl $62, %eax

# ---- test 63: not taken (less-or-equal) --------------------------------------------------------------------------------------------------------------------------------------
  movl $2, %ebx
  cmpl $5, %ebx
  jg .t63_bad
  jmp .t63_ok
.t63_bad:
  movl $63, %eax
  jmp .end
.t63_ok:
  movl $63, %eax

# ===== pushl (tests 64-65) ==================================================================================================================================================
# Reads pushed value back via manual `movl (%esp),reg`, not popl.

# ---- test 64: immediate source ------------------------------------------------------------------------------------------------------------------------------------------
  movl %esp, %edi
  pushl $777
  movl (%esp), %ecx
  movl %esp, %ebx
  movl $64, %eax
  cmpl $777, %ecx
  jne .end
  subl %ebx, %edi           # edi = old_esp - new_esp -> expect 1 (one word lower)
  cmpl $1, %edi
  jne .end
  addl $4, %esp                # manually undo the push (avoiding popl)

# ---- test 65: register source ------------------------------------------------------------------------------------------------------------------------------------------
  movl %esp, %edi
  movl $888, %esi
  pushl %esi
  movl (%esp), %ecx
  movl %esp, %ebx
  movl $65, %eax
  cmpl $888, %ecx
  jne .end
  subl %ebx, %edi
  cmpl $1, %edi
  jne .end
  addl $4, %esp

# ===== leave (tests 66-67) ==================================================================================================================================================

# ---- test 66: small local frame --------------------------------------------------------------------------------------------------------------------------------------------
  movl %esp, %edi
  movl $12345, %esi
  pushl %esi
  movl %esp, %ebp
  subl $8, %esp
  leave
  movl $66, %eax
  cmpl $12345, %ebp
  jne .end
  movl %esp, %ecx
  subl %edi, %ecx
  cmpl $0, %ecx
  jne .end

# ---- test 67: larger local frame ----------------------------------------------------------------------------------------------------------------------------------------------
  movl %esp, %edi
  movl $54321, %esi
  pushl %esi
  movl %esp, %ebp
  subl $40, %esp
  leave
  movl $67, %eax
  cmpl $54321, %ebp
  jne .end
  movl %esp, %ecx
  subl %edi, %ecx
  cmpl $0, %ecx
  jne .end

# ===== call (tests 68-69) =========================================================================================================================================================

# ---- test 68: functional (also implicitly checks return address correctness) -----------------------------------------------------------------------------------------------------
  movl $5, %ebx
  call helper
  movl $68, %eax
  cmpl $6, %ebx
  jne .end

# ---- test 69: esp is neutral across a call/ret with no other stack use -----------------------------------------------------------------------------------------------------------------
  movl %esp, %edi
  call helper2
  movl %esp, %ecx
  movl $69, %eax
  subl %edi, %ecx
  cmpl $0, %ecx
  jne .end

# ===== sall/shll (tests 70-73) ========================================================================================================================================================

# ---- test 70: functional, explicit count -----------------------------------------------------------------------------------------------------------------------------------------------
  movl $3, %ebx
  sall $4, %ebx
  movl $70, %eax
  cmpl $48, %ebx
  jne .end

# ---- test 71: functional, implicit count = 1, also cross-checks the shll alias ------------------------------------------------------------------------------------------------------------
  movl $5, %ebx
  shll %ebx
  movl $71, %eax
  cmpl $10, %ebx
  jne .end

# ---- test 72: OF set, shift-by-1 (sign bit flips: 0x40000000 << 1 = INT_MIN) ------------------------------------------------------------------------------------------------------------------
  movl $1073741824, %ebx
  sall $1, %ebx
  movl $72, %eax
  jo .t72_of_ok        # check OF immediately - a cmpl here first would clobber it
  jmp .end
.t72_of_ok:
  cmpl $-2147483648, %ebx
  jne .end

# ---- test 73: OF clear, shift-by-1 (sign bit unchanged) --------------------------------------------------------------------------------------------------------------------------------------
  movl $5, %ebx
  sall $1, %ebx
  movl $73, %eax
  jno .t73_ok
  jmp .end
.t73_ok:

# ===== sarl (tests 74-76) ==================================================================================================================================================================

# ---- test 74: bug probe, explicit count, negative non-exact operand -----------------------------------------------------------------------------------------------------------------------------
  movl $-13, %ebx
  sarl $2, %ebx
  movl $74, %eax
  cmpl $-4, %ebx
  jne .end

# ---- test 75: bug probe, implicit count = 1, negative non-exact operand -------------------------------------------------------------------------------------------------------------------------------
  movl $-7, %ebx
  sarl %ebx
  movl $75, %eax
  cmpl $-4, %ebx
  jne .end

# ---- test 76: OF must always be clear for sarl -----------------------------------------------------------------------------------------------------------------------------------------------------------
  movl $2147483647, %edi
  addl $1, %edi
  movl $-2147483648, %ebx
  sarl $1, %ebx
  movl $76, %eax
  jo .end

# ===== shrl (tests 77-79) ======================================================================================================================================================================================

# ---- test 77: positive operand sanity check -----------------------------------------------------------------------------------------------------------------------------------------------------------------------
  movl $80, %ebx
  shrl $2, %ebx
  movl $77, %eax
  cmpl $20, %ebx
  jne .end

# ---- test 78: bug probe, negative operand (must behave as a LOGICAL shift on the bit pattern) --------------------------------------------------------------------------------------------------------------------------
  movl $-8, %ebx
  shrl $1, %ebx
  movl $78, %eax
  cmpl $2147483644, %ebx
  jne .end

# ---- test 79: OF-by-1 (OF must become the ORIGINAL sign bit) --------------------------------------------------------------------------------------------------------------------------------------------------------------
  movl $5, %edi
  addl $1, %edi
  movl $-8, %ebx
  shrl $1, %ebx
  movl $79, %eax
  jo .t79_ok
  jmp .end
.t79_ok:

# ===== cltd (tests 80-81) ==========================================================================================================================================================================================================

# ---- test 80: positive dividend sign-extends to 0 --------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
  movl $47, %eax
  cltd
  movl $80, %eax
  cmpl $0, %edx
  jne .end

# ---- test 81: negative dividend sign-extends to -1 -----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
  movl $-8, %eax
  cltd
  movl $81, %eax
  cmpl $-1, %edx
  jne .end

# ===== popl (test 82) ================================================================================================================================================================================

# ---- test 82: pop restores the pushed value and esp -----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
  movl %esp, %edi
  movl $8642, %esi
  pushl %esi
  popl %ecx
  movl $82, %eax
  cmpl $8642, %ecx
  jne .end
  movl %esp, %ebx
  subl %edi, %ebx
  cmpl $0, %ebx               # esp must be back to exactly original
  jne .end

# ===== leal (tests 83-88) ================================================================================================================================================================================
# Covers every addressing-mode shape the parser accepts: full form, base
# only, offset+base, base+index (no scale), offset+index+scale (no base),
# and base+index+scale (no offset). None of these dereference memory - leal
# only computes an address value.

# ---- test 83: full form, offset(base,index,scale) ----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
  movl $100, %ebx
  movl $3, %ecx
  leal 8(%ebx,%ecx,4), %edx     # word-addressed: edx = 3*(4/4) + 100 + 8/4 = 105 (NOT 120 - base is used as-is, only the compile-time scale/offset literals get /4'd)
  movl $83, %eax
  cmpl $105, %edx
  jne .end

# ---- test 84: base only, (base) -----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
  movl $555, %ebx
  leal (%ebx), %edx             # edx = 555
  movl $84, %eax
  cmpl $555, %edx
  jne .end

# ---- test 85: offset(base), no index/scale -------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
  movl $100, %ebx
  leal 40(%ebx), %edx           # edx = 100 + 40/4 = 110
  movl $85, %eax
  cmpl $110, %edx
  jne .end

# ---- test 86: (base,index), no scale/offset -------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
  movl $50, %ebx
  movl $7, %ecx
  leal (%ebx,%ecx), %edx        # edx = 50 + 7 = 57
  movl $86, %eax
  cmpl $57, %edx
  jne .end

# ---- test 87: offset(,index,scale), no base -------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
  movl $9, %ecx
  leal 20(,%ecx,8), %edx        # edx = 9*(8/4) + 20/4 = 18 + 5 = 23
  movl $87, %eax
  cmpl $23, %edx
  jne .end

# ---- test 88: (base,index,scale), no offset -------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
  movl $50, %ebx
  movl $9, %ecx
  leal (%ebx,%ecx,8), %edx      # edx = 9*(8/4) + 50 = 18 + 50 = 68
  movl $88, %eax
  cmpl $68, %edx
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