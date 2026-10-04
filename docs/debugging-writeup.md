# How I analyze and refactor legacy ABAP

A short write-up I use to explain my approach in interviews. The example is
Finance-flavoured because that is where I know the tables best, but the
method is language/area agnostic.

## The scenario (typical)

A `Z_` report from ~2011 is used to show G/L account balances per company code
and period. It is slow (30+ seconds) and "sometimes" shows wrong totals.

The original code looks roughly like this:

```abap
DATA: lt_bseg TYPE STANDARD TABLE OF bseg.

SELECT * FROM bkpf INTO TABLE lt_bkpf
  WHERE bukrs = p_bukrs AND gjahr = p_gjahr.

LOOP AT lt_bkpf INTO ls_bkpf.
  SELECT * FROM bseg INTO TABLE lt_bseg
    WHERE bukrs = ls_bkpf-bukrs
      AND belnr = ls_bkpf-belnr
      AND gjahr = ls_bkpf-gjahr.

  LOOP AT lt_bseg INTO ls_bseg.
    LOOP AT lt_out INTO ls_out.
      IF ls_out-hkont = ls_bseg-hkont.
        ls_out-dmbtr = ls_out-dmbtr + ls_bseg-dmbtr.
      ENDIF.
    ENDLOOP.
  ENDLOOP.
ENDLOOP.
```

## What is actually wrong

1. **`SELECT *` twice**, fetching far more columns than are displayed.
2. **A select inside a loop** over `BKPF` - the classic performance killer.
3. **A nested loop for aggregation** in ABAP instead of letting the database
   do the `SUM`.
4. **`BSEG`** is a compatibility view in S/4HANA; reading it hides the real
   Universal Journal (`ACDOCA`) and bypasses the new data model.
5. **No keys / no authorization check** - it happily sums across company codes
   the user cannot see.

## How I refactor it

I work in this order - understand, then measure, then change, then prove:

1. **Understand the requirement first.** What does the business actually need:
   balances, or a list of line items that finance then pivots? Ask before you
   touch anything. Half of "wrong numbers" is a misunderstood requirement.
2. **Measure before changing.** Run the report with `ST05` (SQL trace) and
   `SAT` (runtime analysis). Keep the "before" numbers so you can prove the
   improvement instead of claiming it.
3. **Move the work to the database.** One read, aggregated:

   ```abap
   SELECT racct, SUM( hsl ) AS amount
     FROM acdoca
     INTO TABLE @DATA(lt_balances)
     WHERE rldnr  = @c_leading_ledger
       AND rbukrs = @p_bukrs
       AND gjahr  = @p_gjahr
       AND poper BETWEEN @p_pfrom AND @p_pto
     GROUP BY racct.
   ```

4. **Push selection criteria into `WHERE`** and read only the columns you need.
   Never select all columns "just in case".
5. **Keep it readable.** No 400-line `START-OF-SELECTION` block. Data access
   in a class (`ZCL_FI_JOURNAL_READER`), presentation in another
   (`ZCL_FI_ALV_REPORT`), the report itself just wires them together.
6. **Prove it still behaves.** Regression-check against the old report on a
   few company codes/periods, then add ABAP Unit tests for the pure logic so
   the next change is safe.
7. **Think about authorization.** For finance data this is not optional - use
   the released authorization checks (e.g. `AUTHORITY-CHECK` on the relevant
   FI objects) so users only see what they are allowed to see.

## The result

Same output, a single aggregated database read instead of hundreds of nested
selects, and code a colleague can read on a Monday morning. That is the whole
job: make it correct, make it fast, make it maintainable - and be able to
explain *why*.
