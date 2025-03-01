; NOTE: Assertions have been autogenerated by utils/update_test_checks.py
; RUN: opt -passes=instcombine -S < %s | FileCheck %s

declare void @use.i1(i1)
declare void @use.i8(i8)

; Basic test

define i8 @andcond(i1 %inner.cond, i1 %alt.cond, i8 %inner.sel.trueval, i8 %inner.sel.falseval, i8 %outer.sel.trueval) {
; CHECK-LABEL: @andcond(
; CHECK-NEXT:    [[INNER_SEL:%.*]] = select i1 [[ALT_COND:%.*]], i8 [[OUTER_SEL_TRUEVAL:%.*]], i8 [[INNER_SEL_TRUEVAL:%.*]]
; CHECK-NEXT:    [[OUTER_SEL:%.*]] = select i1 [[INNER_COND:%.*]], i8 [[INNER_SEL]], i8 [[INNER_SEL_FALSEVAL:%.*]]
; CHECK-NEXT:    ret i8 [[OUTER_SEL]]
;
  %outer.cond = select i1 %inner.cond, i1 %alt.cond, i1 false ; and %inner.cond, %alt.cond
  %inner.sel = select i1 %inner.cond, i8 %inner.sel.trueval, i8 %inner.sel.falseval
  %outer.sel = select i1 %outer.cond, i8 %outer.sel.trueval, i8 %inner.sel
  ret i8 %outer.sel
}
define i8 @orcond(i1 %inner.cond, i1 %alt.cond, i8 %inner.sel.trueval, i8 %inner.sel.falseval, i8 %outer.sel.falseval) {
; CHECK-LABEL: @orcond(
; CHECK-NEXT:    [[INNER_SEL:%.*]] = select i1 [[ALT_COND:%.*]], i8 [[INNER_SEL_FALSEVAL:%.*]], i8 [[OUTER_SEL_FALSEVAL:%.*]]
; CHECK-NEXT:    [[OUTER_SEL:%.*]] = select i1 [[INNER_COND:%.*]], i8 [[INNER_SEL_TRUEVAL:%.*]], i8 [[INNER_SEL]]
; CHECK-NEXT:    ret i8 [[OUTER_SEL]]
;
  %outer.cond = select i1 %inner.cond, i1 true, i1 %alt.cond ; or %inner.cond, %alt.cond
  %inner.sel = select i1 %inner.cond, i8 %inner.sel.trueval, i8 %inner.sel.falseval
  %outer.sel = select i1 %outer.cond, i8 %inner.sel, i8 %outer.sel.falseval
  ret i8 %outer.sel
}

; Extra use tests (basic test, no inversions)

define i8 @andcond.extrause0(i1 %inner.cond, i1 %alt.cond, i8 %inner.sel.trueval, i8 %inner.sel.falseval, i8 %outer.sel.trueval) {
; CHECK-LABEL: @andcond.extrause0(
; CHECK-NEXT:    [[OUTER_COND:%.*]] = select i1 [[INNER_COND:%.*]], i1 [[ALT_COND:%.*]], i1 false
; CHECK-NEXT:    call void @use.i1(i1 [[OUTER_COND]])
; CHECK-NEXT:    [[INNER_SEL:%.*]] = select i1 [[ALT_COND]], i8 [[OUTER_SEL_TRUEVAL:%.*]], i8 [[INNER_SEL_TRUEVAL:%.*]]
; CHECK-NEXT:    [[OUTER_SEL:%.*]] = select i1 [[INNER_COND]], i8 [[INNER_SEL]], i8 [[INNER_SEL_FALSEVAL:%.*]]
; CHECK-NEXT:    ret i8 [[OUTER_SEL]]
;
  %outer.cond = select i1 %inner.cond, i1 %alt.cond, i1 false
  call void @use.i1(i1 %outer.cond)
  %inner.sel = select i1 %inner.cond, i8 %inner.sel.trueval, i8 %inner.sel.falseval
  %outer.sel = select i1 %outer.cond, i8 %outer.sel.trueval, i8 %inner.sel
  ret i8 %outer.sel
}
define i8 @orcond.extrause0(i1 %inner.cond, i1 %alt.cond, i8 %inner.sel.trueval, i8 %inner.sel.falseval, i8 %outer.sel.falseval) {
; CHECK-LABEL: @orcond.extrause0(
; CHECK-NEXT:    [[OUTER_COND:%.*]] = select i1 [[INNER_COND:%.*]], i1 true, i1 [[ALT_COND:%.*]]
; CHECK-NEXT:    call void @use.i1(i1 [[OUTER_COND]])
; CHECK-NEXT:    [[INNER_SEL:%.*]] = select i1 [[ALT_COND]], i8 [[INNER_SEL_FALSEVAL:%.*]], i8 [[OUTER_SEL_FALSEVAL:%.*]]
; CHECK-NEXT:    [[OUTER_SEL:%.*]] = select i1 [[INNER_COND]], i8 [[INNER_SEL_TRUEVAL:%.*]], i8 [[INNER_SEL]]
; CHECK-NEXT:    ret i8 [[OUTER_SEL]]
;
  %outer.cond = select i1 %inner.cond, i1 true, i1 %alt.cond
  call void @use.i1(i1 %outer.cond)
  %inner.sel = select i1 %inner.cond, i8 %inner.sel.trueval, i8 %inner.sel.falseval
  %outer.sel = select i1 %outer.cond, i8 %inner.sel, i8 %outer.sel.falseval
  ret i8 %outer.sel
}

define i8 @andcond.extrause1(i1 %inner.cond, i1 %alt.cond, i8 %inner.sel.trueval, i8 %inner.sel.falseval, i8 %outer.sel.trueval) {
; CHECK-LABEL: @andcond.extrause1(
; CHECK-NEXT:    [[TMP1:%.*]] = select i1 [[INNER_COND:%.*]], i8 [[INNER_SEL_TRUEVAL:%.*]], i8 [[INNER_SEL_FALSEVAL:%.*]]
; CHECK-NEXT:    call void @use.i8(i8 [[TMP1]])
; CHECK-NEXT:    [[INNER_SEL:%.*]] = select i1 [[ALT_COND:%.*]], i8 [[OUTER_SEL_TRUEVAL:%.*]], i8 [[INNER_SEL_TRUEVAL]]
; CHECK-NEXT:    [[OUTER_SEL:%.*]] = select i1 [[INNER_COND]], i8 [[INNER_SEL]], i8 [[INNER_SEL_FALSEVAL]]
; CHECK-NEXT:    ret i8 [[OUTER_SEL]]
;
  %outer.cond = select i1 %inner.cond, i1 %alt.cond, i1 false
  %inner.sel = select i1 %inner.cond, i8 %inner.sel.trueval, i8 %inner.sel.falseval
  call void @use.i8(i8 %inner.sel)
  %outer.sel = select i1 %outer.cond, i8 %outer.sel.trueval, i8 %inner.sel
  ret i8 %outer.sel
}
define i8 @orcond.extrause1(i1 %inner.cond, i1 %alt.cond, i8 %inner.sel.trueval, i8 %inner.sel.falseval, i8 %outer.sel.falseval) {
; CHECK-LABEL: @orcond.extrause1(
; CHECK-NEXT:    [[TMP1:%.*]] = select i1 [[INNER_COND:%.*]], i8 [[INNER_SEL_TRUEVAL:%.*]], i8 [[INNER_SEL_FALSEVAL:%.*]]
; CHECK-NEXT:    call void @use.i8(i8 [[TMP1]])
; CHECK-NEXT:    [[INNER_SEL:%.*]] = select i1 [[ALT_COND:%.*]], i8 [[INNER_SEL_FALSEVAL]], i8 [[OUTER_SEL_FALSEVAL:%.*]]
; CHECK-NEXT:    [[OUTER_SEL:%.*]] = select i1 [[INNER_COND]], i8 [[INNER_SEL_TRUEVAL]], i8 [[INNER_SEL]]
; CHECK-NEXT:    ret i8 [[OUTER_SEL]]
;
  %outer.cond = select i1 %inner.cond, i1 true, i1 %alt.cond
  %inner.sel = select i1 %inner.cond, i8 %inner.sel.trueval, i8 %inner.sel.falseval
  call void @use.i8(i8 %inner.sel)
  %outer.sel = select i1 %outer.cond, i8 %inner.sel, i8 %outer.sel.falseval
  ret i8 %outer.sel
}

define i8 @andcond.extrause2(i1 %inner.cond, i1 %alt.cond, i8 %inner.sel.trueval, i8 %inner.sel.falseval, i8 %outer.sel.trueval) {
; CHECK-LABEL: @andcond.extrause2(
; CHECK-NEXT:    [[OUTER_COND:%.*]] = select i1 [[INNER_COND:%.*]], i1 [[ALT_COND:%.*]], i1 false
; CHECK-NEXT:    call void @use.i1(i1 [[OUTER_COND]])
; CHECK-NEXT:    [[INNER_SEL:%.*]] = select i1 [[INNER_COND]], i8 [[INNER_SEL_TRUEVAL:%.*]], i8 [[INNER_SEL_FALSEVAL:%.*]]
; CHECK-NEXT:    call void @use.i8(i8 [[INNER_SEL]])
; CHECK-NEXT:    [[OUTER_SEL:%.*]] = select i1 [[OUTER_COND]], i8 [[OUTER_SEL_TRUEVAL:%.*]], i8 [[INNER_SEL]]
; CHECK-NEXT:    ret i8 [[OUTER_SEL]]
;
  %outer.cond = select i1 %inner.cond, i1 %alt.cond, i1 false
  call void @use.i1(i1 %outer.cond)
  %inner.sel = select i1 %inner.cond, i8 %inner.sel.trueval, i8 %inner.sel.falseval
  call void @use.i8(i8 %inner.sel)
  %outer.sel = select i1 %outer.cond, i8 %outer.sel.trueval, i8 %inner.sel
  ret i8 %outer.sel
}
define i8 @orcond.extrause2(i1 %inner.cond, i1 %alt.cond, i8 %inner.sel.trueval, i8 %inner.sel.falseval, i8 %outer.sel.falseval) {
; CHECK-LABEL: @orcond.extrause2(
; CHECK-NEXT:    [[OUTER_COND:%.*]] = select i1 [[INNER_COND:%.*]], i1 true, i1 [[ALT_COND:%.*]]
; CHECK-NEXT:    call void @use.i1(i1 [[OUTER_COND]])
; CHECK-NEXT:    [[INNER_SEL:%.*]] = select i1 [[INNER_COND]], i8 [[INNER_SEL_TRUEVAL:%.*]], i8 [[INNER_SEL_FALSEVAL:%.*]]
; CHECK-NEXT:    call void @use.i8(i8 [[INNER_SEL]])
; CHECK-NEXT:    [[OUTER_SEL:%.*]] = select i1 [[OUTER_COND]], i8 [[INNER_SEL]], i8 [[OUTER_SEL_FALSEVAL:%.*]]
; CHECK-NEXT:    ret i8 [[OUTER_SEL]]
;
  %outer.cond = select i1 %inner.cond, i1 true, i1 %alt.cond
  call void @use.i1(i1 %outer.cond)
  %inner.sel = select i1 %inner.cond, i8 %inner.sel.trueval, i8 %inner.sel.falseval
  call void @use.i8(i8 %inner.sel)
  %outer.sel = select i1 %outer.cond, i8 %inner.sel, i8 %outer.sel.falseval
  ret i8 %outer.sel
}

; Mismatched 'common' cond

define i8 @andcond.different.inner.cond(i1 %inner.cond.v0, i1 %inner.cond.v1, i1 %alt.cond, i8 %inner.sel.trueval, i8 %inner.sel.falseval, i8 %outer.sel.trueval) {
; CHECK-LABEL: @andcond.different.inner.cond(
; CHECK-NEXT:    [[OUTER_COND:%.*]] = select i1 [[INNER_COND_V0:%.*]], i1 [[ALT_COND:%.*]], i1 false
; CHECK-NEXT:    [[INNER_SEL:%.*]] = select i1 [[INNER_COND_V1:%.*]], i8 [[INNER_SEL_TRUEVAL:%.*]], i8 [[INNER_SEL_FALSEVAL:%.*]]
; CHECK-NEXT:    [[OUTER_SEL:%.*]] = select i1 [[OUTER_COND]], i8 [[OUTER_SEL_TRUEVAL:%.*]], i8 [[INNER_SEL]]
; CHECK-NEXT:    ret i8 [[OUTER_SEL]]
;

  %outer.cond = select i1 %inner.cond.v0, i1 %alt.cond, i1 false
  %inner.sel = select i1 %inner.cond.v1, i8 %inner.sel.trueval, i8 %inner.sel.falseval
  %outer.sel = select i1 %outer.cond, i8 %outer.sel.trueval, i8 %inner.sel
  ret i8 %outer.sel
}
define i8 @orcond.different.inner.cond(i1 %inner.cond.v0, i1 %inner.cond.v1, i1 %alt.cond, i8 %inner.sel.trueval, i8 %inner.sel.falseval, i8 %outer.sel.falseval) {
; CHECK-LABEL: @orcond.different.inner.cond(
; CHECK-NEXT:    [[OUTER_COND:%.*]] = select i1 [[INNER_COND_V0:%.*]], i1 true, i1 [[ALT_COND:%.*]]
; CHECK-NEXT:    [[INNER_SEL:%.*]] = select i1 [[INNER_COND_V1:%.*]], i8 [[INNER_SEL_TRUEVAL:%.*]], i8 [[INNER_SEL_FALSEVAL:%.*]]
; CHECK-NEXT:    [[OUTER_SEL:%.*]] = select i1 [[OUTER_COND]], i8 [[INNER_SEL]], i8 [[OUTER_SEL_FALSEVAL:%.*]]
; CHECK-NEXT:    ret i8 [[OUTER_SEL]]
;
  %outer.cond = select i1 %inner.cond.v0, i1 true, i1 %alt.cond
  %inner.sel = select i1 %inner.cond.v1, i8 %inner.sel.trueval, i8 %inner.sel.falseval
  %outer.sel = select i1 %outer.cond, i8 %inner.sel, i8 %outer.sel.falseval
  ret i8 %outer.sel
}

define i1 @andcond.different.inner.cond.both.inverted(i1 %inner.cond.v0, i1 %inner.cond.v1, i1 %alt.cond, i1 %inner.sel.trueval, i1 %inner.sel.falseval, i1 %outer.sel.trueval) {
; CHECK-LABEL: @andcond.different.inner.cond.both.inverted(
; CHECK-NEXT:    [[NOT_INNER_COND_0:%.*]] = xor i1 [[INNER_COND_V0:%.*]], true
; CHECK-NEXT:    [[OUTER_COND:%.*]] = select i1 [[NOT_INNER_COND_0]], i1 [[ALT_COND:%.*]], i1 false
; CHECK-NEXT:    [[NOT_INNER_COND_1:%.*]] = xor i1 [[INNER_COND_V1:%.*]], true
; CHECK-NEXT:    [[INNER_SEL:%.*]] = select i1 [[NOT_INNER_COND_1]], i1 [[INNER_SEL_FALSEVAL:%.*]], i1 false
; CHECK-NEXT:    [[OUTER_SEL:%.*]] = select i1 [[OUTER_COND]], i1 [[OUTER_SEL_TRUEVAL:%.*]], i1 [[INNER_SEL]]
; CHECK-NEXT:    ret i1 [[OUTER_SEL]]
;
  %not.inner.cond.0 = xor i1 %inner.cond.v0, -1
  %outer.cond = select i1 %not.inner.cond.0, i1 %alt.cond, i1 false ; and %inner.cond, %alt.cond
  %not.inner.cond.1 = xor i1 %inner.cond.v1, -1
  %inner.sel = select i1 %not.inner.cond.1, i1 %inner.sel.falseval, i1 false
  %outer.sel = select i1 %outer.cond, i1 %outer.sel.trueval, i1 %inner.sel
  ret i1 %outer.sel
}
define i1 @orcond.different.inner.cond.both.inverted(i1 %inner.cond.v0, i1 %inner.cond.v1, i1 %alt.cond, i1 %inner.sel.trueval, i1 %inner.sel.falseval, i1 %outer.sel.falseval) {
; CHECK-LABEL: @orcond.different.inner.cond.both.inverted(
; CHECK-NEXT:    [[NOT_INNER_COND_0:%.*]] = xor i1 [[INNER_COND_V0:%.*]], true
; CHECK-NEXT:    [[OUTER_COND:%.*]] = select i1 [[NOT_INNER_COND_0]], i1 true, i1 [[ALT_COND:%.*]]
; CHECK-NEXT:    [[NOT_INNER_COND_1:%.*]] = xor i1 [[INNER_COND_V1:%.*]], true
; CHECK-NEXT:    [[INNER_SEL:%.*]] = select i1 [[NOT_INNER_COND_1]], i1 true, i1 [[INNER_SEL_TRUEVAL:%.*]]
; CHECK-NEXT:    [[OUTER_SEL:%.*]] = select i1 [[OUTER_COND]], i1 [[INNER_SEL]], i1 [[OUTER_SEL_FALSEVAL:%.*]]
; CHECK-NEXT:    ret i1 [[OUTER_SEL]]
;
  %not.inner.cond.0 = xor i1 %inner.cond.v0, -1
  %outer.cond = select i1 %not.inner.cond.0, i1 true, i1 %alt.cond ; or %inner.cond, %alt.cond
  %not.inner.cond.1 = xor i1 %inner.cond.v1, -1
  %inner.sel = select i1 %not.inner.cond.1, i1 true, i1 %inner.sel.trueval
  %outer.sel = select i1 %outer.cond, i1 %inner.sel, i1 %outer.sel.falseval
  ret i1 %outer.sel
}

define i1 @andcond.different.inner.cond.inverted.in.outer.cond(i1 %inner.cond.v0, i1 %inner.cond.v1, i1 %alt.cond, i1 %inner.sel.trueval, i1 %inner.sel.falseval, i1 %outer.sel.trueval) {
; CHECK-LABEL: @andcond.different.inner.cond.inverted.in.outer.cond(
; CHECK-NEXT:    [[NOT_INNER_COND_0:%.*]] = xor i1 [[INNER_COND_V0:%.*]], true
; CHECK-NEXT:    [[OUTER_COND:%.*]] = select i1 [[NOT_INNER_COND_0]], i1 [[ALT_COND:%.*]], i1 false
; CHECK-NEXT:    [[INNER_SEL:%.*]] = select i1 [[INNER_COND_V1:%.*]], i1 [[INNER_SEL_FALSEVAL:%.*]], i1 false
; CHECK-NEXT:    [[OUTER_SEL:%.*]] = select i1 [[OUTER_COND]], i1 [[OUTER_SEL_TRUEVAL:%.*]], i1 [[INNER_SEL]]
; CHECK-NEXT:    ret i1 [[OUTER_SEL]]
;
  %not.inner.cond.0 = xor i1 %inner.cond.v0, -1
  %outer.cond = select i1 %not.inner.cond.0, i1 %alt.cond, i1 false ; and %inner.cond, %alt.cond
  %inner.sel = select i1 %inner.cond.v1, i1 %inner.sel.falseval, i1 false
  %outer.sel = select i1 %outer.cond, i1 %outer.sel.trueval, i1 %inner.sel
  ret i1 %outer.sel
}
define i1 @orcond.different.inner.cond.inverted.in.outer.cond(i1 %inner.cond.v0, i1 %inner.cond.v1, i1 %alt.cond, i1 %inner.sel.trueval, i1 %inner.sel.falseval, i1 %outer.sel.falseval) {
; CHECK-LABEL: @orcond.different.inner.cond.inverted.in.outer.cond(
; CHECK-NEXT:    [[NOT_INNER_COND_0:%.*]] = xor i1 [[INNER_COND_V0:%.*]], true
; CHECK-NEXT:    [[OUTER_COND:%.*]] = select i1 [[NOT_INNER_COND_0]], i1 true, i1 [[ALT_COND:%.*]]
; CHECK-NEXT:    [[INNER_SEL:%.*]] = select i1 [[INNER_COND_V1:%.*]], i1 true, i1 [[INNER_SEL_TRUEVAL:%.*]]
; CHECK-NEXT:    [[OUTER_SEL:%.*]] = select i1 [[OUTER_COND]], i1 [[INNER_SEL]], i1 [[OUTER_SEL_FALSEVAL:%.*]]
; CHECK-NEXT:    ret i1 [[OUTER_SEL]]
;
  %not.inner.cond.0 = xor i1 %inner.cond.v0, -1
  %outer.cond = select i1 %not.inner.cond.0, i1 true, i1 %alt.cond ; or %inner.cond, %alt.cond
  %inner.sel = select i1 %inner.cond.v1, i1 true, i1 %inner.sel.trueval
  %outer.sel = select i1 %outer.cond, i1 %inner.sel, i1 %outer.sel.falseval
  ret i1 %outer.sel
}

define i1 @andcond.different.inner.cond.inverted.in.inner.sel(i1 %inner.cond.v0, i1 %inner.cond.v1, i1 %alt.cond, i1 %inner.sel.trueval, i1 %inner.sel.falseval, i1 %outer.sel.trueval) {
; CHECK-LABEL: @andcond.different.inner.cond.inverted.in.inner.sel(
; CHECK-NEXT:    [[OUTER_COND:%.*]] = select i1 [[INNER_COND_V0:%.*]], i1 [[ALT_COND:%.*]], i1 false
; CHECK-NEXT:    [[NOT_INNER_COND_1:%.*]] = xor i1 [[INNER_COND_V1:%.*]], true
; CHECK-NEXT:    [[INNER_SEL:%.*]] = select i1 [[NOT_INNER_COND_1]], i1 [[INNER_SEL_FALSEVAL:%.*]], i1 false
; CHECK-NEXT:    [[OUTER_SEL:%.*]] = select i1 [[OUTER_COND]], i1 [[OUTER_SEL_TRUEVAL:%.*]], i1 [[INNER_SEL]]
; CHECK-NEXT:    ret i1 [[OUTER_SEL]]
;
  %outer.cond = select i1 %inner.cond.v0, i1 %alt.cond, i1 false ; and %inner.cond, %alt.cond
  %not.inner.cond.1 = xor i1 %inner.cond.v1, -1
  %inner.sel = select i1 %not.inner.cond.1, i1 %inner.sel.falseval, i1 false
  %outer.sel = select i1 %outer.cond, i1 %outer.sel.trueval, i1 %inner.sel
  ret i1 %outer.sel
}
define i1 @orcond.different.inner.cond.inverted.in.inner.sel(i1 %inner.cond.v0, i1 %inner.cond.v1, i1 %alt.cond, i1 %inner.sel.trueval, i1 %inner.sel.falseval, i1 %outer.sel.falseval) {
; CHECK-LABEL: @orcond.different.inner.cond.inverted.in.inner.sel(
; CHECK-NEXT:    [[OUTER_COND:%.*]] = select i1 [[INNER_COND_V0:%.*]], i1 true, i1 [[ALT_COND:%.*]]
; CHECK-NEXT:    [[NOT_INNER_COND_1:%.*]] = xor i1 [[INNER_COND_V1:%.*]], true
; CHECK-NEXT:    [[INNER_SEL:%.*]] = select i1 [[NOT_INNER_COND_1]], i1 true, i1 [[INNER_SEL_TRUEVAL:%.*]]
; CHECK-NEXT:    [[OUTER_SEL:%.*]] = select i1 [[OUTER_COND]], i1 [[INNER_SEL]], i1 [[OUTER_SEL_FALSEVAL:%.*]]
; CHECK-NEXT:    ret i1 [[OUTER_SEL]]
;
  %outer.cond = select i1 %inner.cond.v0, i1 true, i1 %alt.cond ; or %inner.cond, %alt.cond
  %not.inner.cond.1 = xor i1 %inner.cond.v1, -1
  %inner.sel = select i1 %not.inner.cond.1, i1 true, i1 %inner.sel.trueval
  %outer.sel = select i1 %outer.cond, i1 %inner.sel, i1 %outer.sel.falseval
  ret i1 %outer.sel
}

; Not an inversion
; Based on reproduced from https://reviews.llvm.org/D139275#4001580
define i8 @D139275_c4001580(i1 %c0, i1 %c1, i1 %c2, i8 %inner.sel.trueval, i8 %inner.sel.falseval, i8 %outer.sel.trueval) {
; CHECK-LABEL: @D139275_c4001580(
; CHECK-NEXT:    [[INNER_COND:%.*]] = xor i1 [[C0:%.*]], [[C1:%.*]]
; CHECK-NEXT:    [[OUTER_COND:%.*]] = and i1 [[C2:%.*]], [[C1]]
; CHECK-NEXT:    [[INNER_SEL:%.*]] = select i1 [[INNER_COND]], i8 [[INNER_SEL_TRUEVAL:%.*]], i8 [[INNER_SEL_FALSEVAL:%.*]]
; CHECK-NEXT:    [[OUTER_SEL:%.*]] = select i1 [[OUTER_COND]], i8 [[OUTER_SEL_TRUEVAL:%.*]], i8 [[INNER_SEL]]
; CHECK-NEXT:    ret i8 [[OUTER_SEL]]
;
  %inner.cond = xor i1 %c0, %c1
  %outer.cond = and i1 %c2, %c1
  %inner.sel = select i1 %inner.cond, i8 %inner.sel.trueval, i8 %inner.sel.falseval
  %outer.sel = select i1 %outer.cond, i8 %outer.sel.trueval, i8 %inner.sel
  ret i8 %outer.sel
}

; Tests with intervening inversions

; In %outer.sel, %outer.cond is inverted
define i1 @andcond.001.inv.outer.cond(i1 %inner.cond, i1 %alt.cond, i1 %inner.sel.trueval, i1 %inner.sel.falseval, i1 %outer.sel.trueval) {
; CHECK-LABEL: @andcond.001.inv.outer.cond(
; CHECK-NEXT:    [[NOT_ALT_COND:%.*]] = xor i1 [[ALT_COND:%.*]], true
; CHECK-NEXT:    [[INNER_SEL:%.*]] = select i1 [[NOT_ALT_COND]], i1 [[INNER_SEL_TRUEVAL:%.*]], i1 false
; CHECK-NEXT:    [[OUTER_SEL:%.*]] = select i1 [[INNER_COND:%.*]], i1 [[INNER_SEL]], i1 [[INNER_SEL_FALSEVAL:%.*]]
; CHECK-NEXT:    ret i1 [[OUTER_SEL]]
;
  %outer.cond = select i1 %inner.cond, i1 %alt.cond, i1 false ; and %inner.cond, %alt.cond
  %inner.sel = select i1 %inner.cond, i1 %inner.sel.trueval, i1 %inner.sel.falseval
  %not.outer.cond = xor i1 %outer.cond, -1
  %outer.sel = select i1 %not.outer.cond, i1 %inner.sel, i1 false
  ret i1 %outer.sel
}
define i1 @orcond.001.inv.outer.cond(i1 %inner.cond, i1 %alt.cond, i1 %inner.sel.trueval, i1 %inner.sel.falseval, i1 %outer.sel.falseval) {
; CHECK-LABEL: @orcond.001.inv.outer.cond(
; CHECK-NEXT:    [[NOT_ALT_COND:%.*]] = xor i1 [[ALT_COND:%.*]], true
; CHECK-NEXT:    [[INNER_SEL:%.*]] = select i1 [[NOT_ALT_COND]], i1 true, i1 [[INNER_SEL_FALSEVAL:%.*]]
; CHECK-NEXT:    [[OUTER_SEL:%.*]] = select i1 [[INNER_COND:%.*]], i1 [[INNER_SEL_TRUEVAL:%.*]], i1 [[INNER_SEL]]
; CHECK-NEXT:    ret i1 [[OUTER_SEL]]
;
  %outer.cond = select i1 %inner.cond, i1 true, i1 %alt.cond ; or %inner.cond, %alt.cond
  %inner.sel = select i1 %inner.cond, i1 %inner.sel.trueval, i1 %inner.sel.falseval
  %not.outer.cond = xor i1 %outer.cond, -1
  %outer.sel = select i1 %not.outer.cond, i1 true, i1 %inner.sel
  ret i1 %outer.sel
}

; In %inner.sel, %inner.cond is inverted
define i1 @andcond.010.inv.inner.cond.in.inner.sel(i1 %inner.cond, i1 %alt.cond, i1 %inner.sel.trueval, i1 %inner.sel.falseval, i1 %outer.sel.trueval) {
; CHECK-LABEL: @andcond.010.inv.inner.cond.in.inner.sel(
; CHECK-NEXT:    [[INNER_SEL:%.*]] = select i1 [[ALT_COND:%.*]], i1 [[OUTER_SEL_TRUEVAL:%.*]], i1 false
; CHECK-NEXT:    [[OUTER_SEL:%.*]] = select i1 [[INNER_COND:%.*]], i1 [[INNER_SEL]], i1 [[INNER_SEL_FALSEVAL:%.*]]
; CHECK-NEXT:    ret i1 [[OUTER_SEL]]
;
  %outer.cond = select i1 %inner.cond, i1 %alt.cond, i1 false ; and %inner.cond, %alt.cond
  %not.inner.cond = xor i1 %inner.cond, -1
  %inner.sel = select i1 %not.inner.cond, i1 %inner.sel.falseval, i1 false
  %outer.sel = select i1 %outer.cond, i1 %outer.sel.trueval, i1 %inner.sel
  ret i1 %outer.sel
}
define i1 @orcond.010.inv.inner.cond.in.inner.sel(i1 %inner.cond, i1 %alt.cond, i1 %inner.sel.trueval, i1 %inner.sel.falseval, i1 %outer.sel.falseval) {
; CHECK-LABEL: @orcond.010.inv.inner.cond.in.inner.sel(
; CHECK-NEXT:    [[INNER_SEL:%.*]] = select i1 [[ALT_COND:%.*]], i1 true, i1 [[OUTER_SEL_FALSEVAL:%.*]]
; CHECK-NEXT:    [[OUTER_SEL:%.*]] = select i1 [[INNER_COND:%.*]], i1 [[INNER_SEL_TRUEVAL:%.*]], i1 [[INNER_SEL]]
; CHECK-NEXT:    ret i1 [[OUTER_SEL]]
;
  %outer.cond = select i1 %inner.cond, i1 true, i1 %alt.cond ; or %inner.cond, %alt.cond
  %not.inner.cond = xor i1 %inner.cond, -1
  %inner.sel = select i1 %not.inner.cond, i1 true, i1 %inner.sel.trueval
  %outer.sel = select i1 %outer.cond, i1 %inner.sel, i1 %outer.sel.falseval
  ret i1 %outer.sel
}

; In %outer.cond, %inner.cond is inverted
define i8 @andcond.100.inv.inner.cond.in.outer.cond(i1 %inner.cond, i1 %alt.cond, i8 %inner.sel.trueval, i8 %inner.sel.falseval, i8 %outer.sel.trueval) {
; CHECK-LABEL: @andcond.100.inv.inner.cond.in.outer.cond(
; CHECK-NEXT:    [[INNER_SEL:%.*]] = select i1 [[ALT_COND:%.*]], i8 [[OUTER_SEL_TRUEVAL:%.*]], i8 [[INNER_SEL_FALSEVAL:%.*]]
; CHECK-NEXT:    [[OUTER_SEL:%.*]] = select i1 [[INNER_COND:%.*]], i8 [[INNER_SEL_TRUEVAL:%.*]], i8 [[INNER_SEL]]
; CHECK-NEXT:    ret i8 [[OUTER_SEL]]
;
  %not.inner.cond = xor i1 %inner.cond, -1
  %outer.cond = select i1 %not.inner.cond, i1 %alt.cond, i1 false ; and %inner.cond, %alt.cond
  %inner.sel = select i1 %inner.cond, i8 %inner.sel.trueval, i8 %inner.sel.falseval
  %outer.sel = select i1 %outer.cond, i8 %outer.sel.trueval, i8 %inner.sel
  ret i8 %outer.sel
}
define i8 @orcond.100.inv.inner.cond.in.outer.cond(i1 %inner.cond, i1 %alt.cond, i8 %inner.sel.trueval, i8 %inner.sel.falseval, i8 %outer.sel.falseval) {
; CHECK-LABEL: @orcond.100.inv.inner.cond.in.outer.cond(
; CHECK-NEXT:    [[INNER_SEL:%.*]] = select i1 [[ALT_COND:%.*]], i8 [[INNER_SEL_TRUEVAL:%.*]], i8 [[OUTER_SEL_FALSEVAL:%.*]]
; CHECK-NEXT:    [[OUTER_SEL:%.*]] = select i1 [[INNER_COND:%.*]], i8 [[INNER_SEL]], i8 [[INNER_SEL_FALSEVAL:%.*]]
; CHECK-NEXT:    ret i8 [[OUTER_SEL]]
;
  %not.inner.cond = xor i1 %inner.cond, -1
  %outer.cond = select i1 %not.inner.cond, i1 true, i1 %alt.cond ; or %inner.cond, %alt.cond
  %inner.sel = select i1 %inner.cond, i8 %inner.sel.trueval, i8 %inner.sel.falseval
  %outer.sel = select i1 %outer.cond, i8 %inner.sel, i8 %outer.sel.falseval
  ret i8 %outer.sel
}

; In %outer.sel, %outer.cond is inverted
; In %inner.sel, %inner.cond is inverted
define i1 @andcond.011.inv.outer.cond.inv.inner.cond.in.inner.sel(i1 %inner.cond, i1 %alt.cond, i1 %inner.sel.trueval, i1 %inner.sel.falseval, i1 %outer.sel.trueval) {
; CHECK-LABEL: @andcond.011.inv.outer.cond.inv.inner.cond.in.inner.sel(
; CHECK-NEXT:    [[NOT_INNER_COND:%.*]] = xor i1 [[INNER_COND:%.*]], true
; CHECK-NEXT:    [[TMP1:%.*]] = select i1 [[NOT_INNER_COND]], i1 true, i1 [[INNER_SEL_FALSEVAL:%.*]]
; CHECK-NEXT:    call void @use.i1(i1 [[TMP1]])
; CHECK-NEXT:    [[NOT_ALT_COND:%.*]] = xor i1 [[ALT_COND:%.*]], true
; CHECK-NEXT:    [[INNER_SEL:%.*]] = select i1 [[NOT_ALT_COND]], i1 [[INNER_SEL_FALSEVAL]], i1 false
; CHECK-NEXT:    [[NOT_INNER_COND1:%.*]] = xor i1 [[INNER_COND]], true
; CHECK-NEXT:    [[OUTER_SEL:%.*]] = select i1 [[NOT_INNER_COND1]], i1 true, i1 [[INNER_SEL]]
; CHECK-NEXT:    ret i1 [[OUTER_SEL]]
;
  %outer.cond = select i1 %inner.cond, i1 %alt.cond, i1 false ; and %inner.cond, %alt.cond
  %not.inner.cond = xor i1 %inner.cond, -1
  %inner.sel = select i1 %not.inner.cond, i1 true, i1 %inner.sel.falseval
  %not.outer.cond = xor i1 %outer.cond, -1
  call void @use.i1(i1 %inner.sel)
  %outer.sel = select i1 %not.outer.cond, i1 %inner.sel, i1 false
  ret i1 %outer.sel
}
define i1 @orcond.011.inv.outer.cond.inv.inner.cond.in.inner.sel(i1 %inner.cond, i1 %alt.cond, i1 %inner.sel.trueval, i1 %inner.sel.falseval, i1 %outer.sel.falseval) {
; CHECK-LABEL: @orcond.011.inv.outer.cond.inv.inner.cond.in.inner.sel(
; CHECK-NEXT:    [[NOT_INNER_COND:%.*]] = xor i1 [[INNER_COND:%.*]], true
; CHECK-NEXT:    [[TMP1:%.*]] = select i1 [[NOT_INNER_COND]], i1 [[INNER_SEL_TRUEVAL:%.*]], i1 false
; CHECK-NEXT:    call void @use.i1(i1 [[TMP1]])
; CHECK-NEXT:    [[NOT_ALT_COND:%.*]] = xor i1 [[ALT_COND:%.*]], true
; CHECK-NEXT:    [[INNER_SEL:%.*]] = select i1 [[NOT_ALT_COND]], i1 true, i1 [[INNER_SEL_TRUEVAL]]
; CHECK-NEXT:    [[NOT_INNER_COND1:%.*]] = xor i1 [[INNER_COND]], true
; CHECK-NEXT:    [[OUTER_SEL:%.*]] = select i1 [[NOT_INNER_COND1]], i1 [[INNER_SEL]], i1 false
; CHECK-NEXT:    ret i1 [[OUTER_SEL]]
;
  %outer.cond = select i1 %inner.cond, i1 true, i1 %alt.cond ; or %inner.cond, %alt.cond
  %not.inner.cond = xor i1 %inner.cond, -1
  %inner.sel = select i1 %not.inner.cond, i1 %inner.sel.trueval, i1 false
  call void @use.i1(i1 %inner.sel)
  %not.outer.cond = xor i1 %outer.cond, -1
  %outer.sel = select i1 %not.outer.cond, i1 true, i1 %inner.sel
  ret i1 %outer.sel
}

; In %outer.sel, %outer.cond is inverted
; In %outer.cond, %inner.cond is inverted
define i1 @andcond.101.inv.outer.cond.inv.inner.cond.in.outer.cond(i1 %inner.cond, i1 %alt.cond, i1 %inner.sel.trueval, i1 %inner.sel.falseval, i1 %outer.sel.trueval) {
; CHECK-LABEL: @andcond.101.inv.outer.cond.inv.inner.cond.in.outer.cond(
; CHECK-NEXT:    [[TMP1:%.*]] = select i1 [[INNER_COND:%.*]], i1 [[INNER_SEL_TRUEVAL:%.*]], i1 [[INNER_SEL_FALSEVAL:%.*]]
; CHECK-NEXT:    call void @use.i1(i1 [[TMP1]])
; CHECK-NEXT:    [[ALT_COND_NOT:%.*]] = xor i1 [[ALT_COND:%.*]], true
; CHECK-NEXT:    [[INNER_SEL:%.*]] = select i1 [[ALT_COND_NOT]], i1 [[INNER_SEL_FALSEVAL]], i1 false
; CHECK-NEXT:    [[OUTER_SEL:%.*]] = select i1 [[INNER_COND]], i1 [[INNER_SEL_TRUEVAL]], i1 [[INNER_SEL]]
; CHECK-NEXT:    ret i1 [[OUTER_SEL]]
;
  %not.inner.cond = xor i1 %inner.cond, -1
  %outer.cond = select i1 %not.inner.cond, i1 %alt.cond, i1 false ; and %inner.cond, %alt.cond
  %inner.sel = select i1 %inner.cond, i1 %inner.sel.trueval, i1 %inner.sel.falseval
  call void @use.i1(i1 %inner.sel)
  %not.outer.cond = xor i1 %outer.cond, -1
  %outer.sel = select i1 %not.outer.cond, i1 %inner.sel, i1 false
  ret i1 %outer.sel
}
define i1 @orcond.101.inv.outer.cond.inv.inner.cond.in.outer.cond(i1 %inner.cond, i1 %alt.cond, i1 %inner.sel.trueval, i1 %inner.sel.falseval, i1 %outer.sel.falseval) {
; CHECK-LABEL: @orcond.101.inv.outer.cond.inv.inner.cond.in.outer.cond(
; CHECK-NEXT:    [[TMP1:%.*]] = select i1 [[INNER_COND:%.*]], i1 [[INNER_SEL_TRUEVAL:%.*]], i1 [[INNER_SEL_FALSEVAL:%.*]]
; CHECK-NEXT:    call void @use.i1(i1 [[TMP1]])
; CHECK-NEXT:    [[ALT_COND_NOT:%.*]] = xor i1 [[ALT_COND:%.*]], true
; CHECK-NEXT:    [[INNER_SEL:%.*]] = select i1 [[ALT_COND_NOT]], i1 true, i1 [[INNER_SEL_TRUEVAL]]
; CHECK-NEXT:    [[OUTER_SEL:%.*]] = select i1 [[INNER_COND]], i1 [[INNER_SEL]], i1 [[INNER_SEL_FALSEVAL]]
; CHECK-NEXT:    ret i1 [[OUTER_SEL]]
;
  %not.inner.cond = xor i1 %inner.cond, -1
  %outer.cond = select i1 %not.inner.cond, i1 true, i1 %alt.cond ; or %inner.cond, %alt.cond
  %inner.sel = select i1 %inner.cond, i1 %inner.sel.trueval, i1 %inner.sel.falseval
  call void @use.i1(i1 %inner.sel)
  %not.outer.cond = xor i1 %outer.cond, -1
  %outer.sel = select i1 %not.outer.cond, i1 true, i1 %inner.sel
  ret i1 %outer.sel
}

; In %inner.sel, %inner.cond is inverted
; In %outer.cond, %inner.cond is inverted
define i1 @andcond.110.inv.inner.cond.in.inner.sel.inv.inner.cond.in.outer.cond(i1 %inner.cond, i1 %alt.cond, i1 %inner.sel.trueval, i1 %inner.sel.falseval, i1 %outer.sel.trueval) {
; CHECK-LABEL: @andcond.110.inv.inner.cond.in.inner.sel.inv.inner.cond.in.outer.cond(
; CHECK-NEXT:    [[NOT_INNER_COND_0:%.*]] = xor i1 [[INNER_COND:%.*]], true
; CHECK-NEXT:    [[INNER_SEL:%.*]] = select i1 [[ALT_COND:%.*]], i1 [[OUTER_SEL_TRUEVAL:%.*]], i1 [[INNER_SEL_FALSEVAL:%.*]]
; CHECK-NEXT:    [[OUTER_SEL:%.*]] = select i1 [[NOT_INNER_COND_0]], i1 [[INNER_SEL]], i1 false
; CHECK-NEXT:    ret i1 [[OUTER_SEL]]
;
  %not.inner.cond.0 = xor i1 %inner.cond, -1
  %outer.cond = select i1 %not.inner.cond.0, i1 %alt.cond, i1 false ; and %inner.cond, %alt.cond
  %not.inner.cond.1 = xor i1 %inner.cond, -1
  %inner.sel = select i1 %not.inner.cond.1, i1 %inner.sel.falseval, i1 false
  %outer.sel = select i1 %outer.cond, i1 %outer.sel.trueval, i1 %inner.sel
  ret i1 %outer.sel
}
define i1 @orcond.110.inv.inner.cond.in.inner.sel.inv.inner.cond.in.outer.cond(i1 %inner.cond, i1 %alt.cond, i1 %inner.sel.trueval, i1 %inner.sel.falseval, i1 %outer.sel.falseval) {
; CHECK-LABEL: @orcond.110.inv.inner.cond.in.inner.sel.inv.inner.cond.in.outer.cond(
; CHECK-NEXT:    [[NOT_INNER_COND_0:%.*]] = xor i1 [[INNER_COND:%.*]], true
; CHECK-NEXT:    [[INNER_SEL:%.*]] = select i1 [[ALT_COND:%.*]], i1 [[INNER_SEL_TRUEVAL:%.*]], i1 [[OUTER_SEL_FALSEVAL:%.*]]
; CHECK-NEXT:    [[OUTER_SEL:%.*]] = select i1 [[NOT_INNER_COND_0]], i1 true, i1 [[INNER_SEL]]
; CHECK-NEXT:    ret i1 [[OUTER_SEL]]
;
  %not.inner.cond.0 = xor i1 %inner.cond, -1
  %outer.cond = select i1 %not.inner.cond.0, i1 true, i1 %alt.cond ; or %inner.cond, %alt.cond
  %not.inner.cond.1 = xor i1 %inner.cond, -1
  %inner.sel = select i1 %not.inner.cond.1, i1 true, i1 %inner.sel.trueval
  %outer.sel = select i1 %outer.cond, i1 %inner.sel, i1 %outer.sel.falseval
  ret i1 %outer.sel
}

; In %outer.sel, %outer.cond is inverted
; In %inner.sel, %inner.cond is inverted
; In %outer.cond, %inner.cond is inverted
define i1 @andcond.111.inv.all.conds(i1 %inner.cond, i1 %alt.cond, i1 %inner.sel.trueval, i1 %inner.sel.falseval, i1 %outer.sel.trueval) {
; CHECK-LABEL: @andcond.111.inv.all.conds(
; CHECK-NEXT:    [[NOT_INNER_COND_0:%.*]] = xor i1 [[INNER_COND:%.*]], true
; CHECK-NEXT:    [[OUTER_COND:%.*]] = select i1 [[NOT_INNER_COND_0]], i1 [[ALT_COND:%.*]], i1 false
; CHECK-NEXT:    call void @use.i1(i1 [[OUTER_COND]])
; CHECK-NEXT:    [[NOT_INNER_COND_1:%.*]] = xor i1 [[INNER_COND]], true
; CHECK-NEXT:    [[TMP1:%.*]] = select i1 [[NOT_INNER_COND_1]], i1 [[INNER_SEL_FALSEVAL:%.*]], i1 false
; CHECK-NEXT:    call void @use.i1(i1 [[TMP1]])
; CHECK-NEXT:    [[TMP2:%.*]] = select i1 [[INNER_COND]], i1 true, i1 [[ALT_COND]]
; CHECK-NEXT:    [[TMP3:%.*]] = xor i1 [[TMP2]], true
; CHECK-NEXT:    [[OUTER_SEL:%.*]] = select i1 [[TMP3]], i1 [[INNER_SEL_FALSEVAL]], i1 false
; CHECK-NEXT:    ret i1 [[OUTER_SEL]]
;
  %not.inner.cond.0 = xor i1 %inner.cond, -1
  %outer.cond = select i1 %not.inner.cond.0, i1 %alt.cond, i1 false ; and %inner.cond, %alt.cond
  call void @use.i1(i1 %outer.cond)
  %not.inner.cond.1 = xor i1 %inner.cond, -1
  %inner.sel = select i1 %not.inner.cond.1, i1 %inner.sel.falseval, i1 false
  call void @use.i1(i1 %inner.sel)
  %not.outer.cond = xor i1 %outer.cond, -1
  %outer.sel = select i1 %not.outer.cond, i1 %inner.sel, i1 false
  ret i1 %outer.sel
}
define i1 @orcond.111.inv.all.conds(i1 %inner.cond, i1 %alt.cond, i1 %inner.sel.trueval, i1 %inner.sel.falseval, i1 %outer.sel.falseval) {
; CHECK-LABEL: @orcond.111.inv.all.conds(
; CHECK-NEXT:    [[NOT_INNER_COND_0:%.*]] = xor i1 [[INNER_COND:%.*]], true
; CHECK-NEXT:    [[OUTER_COND:%.*]] = select i1 [[NOT_INNER_COND_0]], i1 true, i1 [[ALT_COND:%.*]]
; CHECK-NEXT:    call void @use.i1(i1 [[OUTER_COND]])
; CHECK-NEXT:    [[NOT_INNER_COND_1:%.*]] = xor i1 [[INNER_COND]], true
; CHECK-NEXT:    [[TMP1:%.*]] = select i1 [[NOT_INNER_COND_1]], i1 true, i1 [[INNER_SEL_TRUEVAL:%.*]]
; CHECK-NEXT:    call void @use.i1(i1 [[TMP1]])
; CHECK-NEXT:    [[TMP2:%.*]] = select i1 [[INNER_COND]], i1 [[ALT_COND]], i1 false
; CHECK-NEXT:    [[TMP3:%.*]] = xor i1 [[TMP2]], true
; CHECK-NEXT:    [[OUTER_SEL:%.*]] = select i1 [[TMP3]], i1 true, i1 [[INNER_SEL_TRUEVAL]]
; CHECK-NEXT:    ret i1 [[OUTER_SEL]]
;
  %not.inner.cond.0 = xor i1 %inner.cond, -1
  %outer.cond = select i1 %not.inner.cond.0, i1 true, i1 %alt.cond ; or %inner.cond, %alt.cond
  call void @use.i1(i1 %outer.cond)
  %not.inner.cond.1 = xor i1 %inner.cond, -1
  %inner.sel = select i1 %not.inner.cond.1, i1 true, i1 %inner.sel.trueval
  call void @use.i1(i1 %inner.sel)
  %not.outer.cond = xor i1 %outer.cond, -1
  %outer.sel = select i1 %not.outer.cond, i1 true, i1 %inner.sel
  ret i1 %outer.sel
}

define i8 @test_implied_true(i8 %x) {
; CHECK-LABEL: @test_implied_true(
; CHECK-NEXT:    [[CMP2:%.*]] = icmp slt i8 [[X:%.*]], 0
; CHECK-NEXT:    [[SEL2:%.*]] = select i1 [[CMP2]], i8 0, i8 20
; CHECK-NEXT:    ret i8 [[SEL2]]
;
  %cmp1 = icmp slt i8 %x, 10
  %cmp2 = icmp slt i8 %x, 0
  %sel1 = select i1 %cmp1, i8 0, i8 5
  %sel2 = select i1 %cmp2, i8 %sel1, i8 20
  ret i8 %sel2
}

define <2 x i8> @test_implied_true_vec(<2 x i8> %x) {
; CHECK-LABEL: @test_implied_true_vec(
; CHECK-NEXT:    [[CMP2:%.*]] = icmp slt <2 x i8> [[X:%.*]], zeroinitializer
; CHECK-NEXT:    [[SEL2:%.*]] = select <2 x i1> [[CMP2]], <2 x i8> zeroinitializer, <2 x i8> splat (i8 20)
; CHECK-NEXT:    ret <2 x i8> [[SEL2]]
;
  %cmp1 = icmp slt <2 x i8> %x, <i8 10, i8 10>
  %cmp2 = icmp slt <2 x i8> %x, zeroinitializer
  %sel1 = select <2 x i1> %cmp1, <2 x i8> zeroinitializer, <2 x i8> <i8 5, i8 5>
  %sel2 = select <2 x i1> %cmp2, <2 x i8> %sel1, <2 x i8> <i8 20, i8 20>
  ret <2 x i8> %sel2
}

define i8 @test_implied_true_falseval(i8 %x) {
; CHECK-LABEL: @test_implied_true_falseval(
; CHECK-NEXT:    [[CMP2:%.*]] = icmp sgt i8 [[X:%.*]], 0
; CHECK-NEXT:    [[SEL2:%.*]] = select i1 [[CMP2]], i8 20, i8 0
; CHECK-NEXT:    ret i8 [[SEL2]]
;
  %cmp1 = icmp slt i8 %x, 10
  %cmp2 = icmp sgt i8 %x, 0
  %sel1 = select i1 %cmp1, i8 0, i8 5
  %sel2 = select i1 %cmp2, i8 20, i8 %sel1
  ret i8 %sel2
}

define i8 @test_implied_false(i8 %x) {
; CHECK-LABEL: @test_implied_false(
; CHECK-NEXT:    [[CMP2:%.*]] = icmp slt i8 [[X:%.*]], 0
; CHECK-NEXT:    [[SEL2:%.*]] = select i1 [[CMP2]], i8 5, i8 20
; CHECK-NEXT:    ret i8 [[SEL2]]
;
  %cmp1 = icmp sgt i8 %x, 10
  %cmp2 = icmp slt i8 %x, 0
  %sel1 = select i1 %cmp1, i8 0, i8 5
  %sel2 = select i1 %cmp2, i8 %sel1, i8 20
  ret i8 %sel2
}

; Negative tests

define i8 @test_imply_fail(i8 %x) {
; CHECK-LABEL: @test_imply_fail(
; CHECK-NEXT:    [[CMP1:%.*]] = icmp slt i8 [[X:%.*]], -10
; CHECK-NEXT:    [[CMP2:%.*]] = icmp slt i8 [[X]], 0
; CHECK-NEXT:    [[SEL1:%.*]] = select i1 [[CMP1]], i8 0, i8 5
; CHECK-NEXT:    [[SEL2:%.*]] = select i1 [[CMP2]], i8 [[SEL1]], i8 20
; CHECK-NEXT:    ret i8 [[SEL2]]
;
  %cmp1 = icmp slt i8 %x, -10
  %cmp2 = icmp slt i8 %x, 0
  %sel1 = select i1 %cmp1, i8 0, i8 5
  %sel2 = select i1 %cmp2, i8 %sel1, i8 20
  ret i8 %sel2
}

define <2 x i8> @test_imply_type_mismatch(<2 x i8> %x, i8 %y) {
; CHECK-LABEL: @test_imply_type_mismatch(
; CHECK-NEXT:    [[CMP1:%.*]] = icmp slt <2 x i8> [[X:%.*]], splat (i8 10)
; CHECK-NEXT:    [[CMP2:%.*]] = icmp slt i8 [[Y:%.*]], 0
; CHECK-NEXT:    [[SEL1:%.*]] = select <2 x i1> [[CMP1]], <2 x i8> zeroinitializer, <2 x i8> splat (i8 5)
; CHECK-NEXT:    [[SEL2:%.*]] = select i1 [[CMP2]], <2 x i8> [[SEL1]], <2 x i8> splat (i8 20)
; CHECK-NEXT:    ret <2 x i8> [[SEL2]]
;
  %cmp1 = icmp slt <2 x i8> %x, <i8 10, i8 10>
  %cmp2 = icmp slt i8 %y, 0
  %sel1 = select <2 x i1> %cmp1, <2 x i8> zeroinitializer, <2 x i8> <i8 5, i8 5>
  %sel2 = select i1 %cmp2, <2 x i8> %sel1, <2 x i8> <i8 20, i8 20>
  ret <2 x i8> %sel2
}

define <4 x i1> @test_dont_crash(i1 %cond, <4 x i1> %a, <4 x i1> %b) {
; CHECK-LABEL: @test_dont_crash(
; CHECK-NEXT:  entry:
; CHECK-NEXT:    [[SEL:%.*]] = select i1 [[COND:%.*]], <4 x i1> [[A:%.*]], <4 x i1> zeroinitializer
; CHECK-NEXT:    [[AND:%.*]] = and <4 x i1> [[SEL]], [[B:%.*]]
; CHECK-NEXT:    ret <4 x i1> [[AND]]
;
entry:
  %sel = select i1 %cond, <4 x i1> %a, <4 x i1> zeroinitializer
  %and = and <4 x i1> %sel, %b
  ret <4 x i1> %and
}
