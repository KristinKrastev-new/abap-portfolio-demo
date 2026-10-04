# SAP ABAP Portfolio - S/4HANA Finance Demo

**Author:** Kristin Krastev · GitHub: [KristinKrastev-new](https://github.com/KristinKrastev-new)

A small, self-contained ABAP portfolio project built on **S/4HANA 2022
(ABAP 7.57)** with a focus on **Finance (FI)** and the **Universal Journal
(table `ACDOCA`)**.

It is structured the way I like to build production code: thin callers,
single-responsibility classes, typed interfaces, unit tests, and modern
S/4HANA data access (Universal Journal / CDS views) instead of classic
`BSEG` selects.

## What this demonstrates

| Artefact | Skill shown |
| --- | --- |
| `ZCL_FI_JOURNAL_READER` | ABAP OO, clean code, Open SQL on `ACDOCA`, fail-fast validation |
| `ZCX_FI_JOURNAL_ERROR` | Message-based (T100) exception class |
| `ZCL_FI_ALV_REPORT` | Separation of UI from data, SALV |
| `ZFI_JOURNAL_REPORT` | Thin report layer / dependency wiring |
| `zcl_fi_journal_reader.clas.testclasses` | ABAP Unit, test-driven mindset |
| `ZCS_FI_JOURNAL_ITEMS` | CDS interface view (VDM `#BASIC`) on the Universal Journal |
| `ZCS_FI_JOURNAL_ITEMS_UI` | CDS consumption view + UI annotations (Fiori / analytics) |
| `ZR_FI_JOURNALITEM` + `ZC_FI_JOURNALITEM` | Read-only **RAP** business object (root & projection view entities + behavior definitions) |
| `ZSD_FI_JOURNALITEM` | RAP service definition (publish as an OData V4 binding) |
| [docs/rap-business-object.md](docs/rap-business-object.md) | Read-only RAP BO explained |
| [docs/debugging-writeup.md](docs/debugging-writeup.md) | How I analyse and refactor legacy ABAP |
| [docs/odata-service.md](docs/odata-service.md) | Exposing a CDS view as an OData service |

## Architecture

```
ZFI_JOURNAL_REPORT (report - wiring only)
        |
        v
ZCL_FI_JOURNAL_READER  --->  ACDOCA (Universal Journal)
        |                     + T001 (company code currency)
        v
ZCL_FI_ALV_REPORT (SALV presentation)
```

Data access, presentation and orchestration are three separate things. Each
piece can change (or be tested) without touching the others.

## Repository layout

```
abap-portfolio-demo/
├── .abapgit.xml                     # abapGit repo settings
├── src/
│   ├── zcl_fi_journal_reader.clas.abap
│   ├── zcl_fi_journal_reader.clas.testclasses.abap
│   ├── zcl_fi_alv_report.clas.abap
│   ├── zcx_fi_journal_error.clas.abap
│   ├── zfi_journal_report.prog.abap
│   ├── zcs_fi_journal_items.ddls.asddls
│   ├── zcs_fi_journal_items_ui.ddls.asddls
│   ├── zr_fi_journalitem.ddls.asddls          # RAP root view entity
│   ├── zr_fi_journalitem.bdef.asbdef          # RAP root behavior definition
│   ├── zc_fi_journalitem.ddls.asddls          # RAP projection view entity
│   ├── zc_fi_journalitem.bdef.asbdef          # RAP projection behavior definition
│   ├── zc_fi_journalitem.ddlx.asddlx          # UI metadata extension
│   └── zsd_fi_journalitem.srvd.srvdsrv        # RAP service definition
└── docs/
    ├── debugging-writeup.md
    ├── odata-service.md
    └── rap-business-object.md
```

## How to run it

Prerequisites:

- An S/4HANA system (2022 or later recommended) with the standard test data,
  or any company code/fiscal year that actually has journal entries.
- A message class `ZFI_JOURNAL` with:
  - `001` - "Company code is mandatory"
  - `002` - "Fiscal year is mandatory"

Then:

1. Create the objects in package `ZFI_JOURNAL` (copy/paste the sources into
   Eclipse ADT / SE80, or import via **abapGit**).
2. Run `ZFI_JOURNAL_REPORT` (`SE38`), enter a company code and fiscal year
   that have postings, and execute.
3. Run the unit tests with `Ctrl+Shift+F10` in ADT (or `SE38` -> Execute ->
   Unit Tests).

## Notes and assumptions

- **Field names:** this project reads `ACDOCA` directly. Field names such as
  `HSL` (amount in company code currency) and `POPER` (posting period) are
  valid on current releases, but always confirm against your release's `ACDOCA`
  definition - S/4HANA evolves.
- **Leading ledger:** `0L` is the standard leading ledger. If your system uses
  a different one, change `ZCL_FI_JOURNAL_READER=>C_LEADING_LEDGER`.
- **Object metadata:** the small `*.xml` files abapGit uses to serialise
  objects are intentionally not committed so the sources stay readable. Create
  the objects once in your system and let abapGit generate them, or paste the
  sources manually.
- This is demo/portfolio code, not a shipped product. Treat the write-up in
  `docs/` as the "why", and the code as the "how".

## License

MIT - see [LICENSE](LICENSE).
