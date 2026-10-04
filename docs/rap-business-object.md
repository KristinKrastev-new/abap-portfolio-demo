# RAP Business Object - Journal Item (read-only)

This folder of the portfolio shows a small **RAP** (ABAP RESTful Application
Programming Model) business object built on top of the CDS interface view
`ZCS_FI_JOURNAL_ITEMS`.

## Why read-only?

A journal entry line item is *created by the posting process*, not typed into
a maintenance UI. Exposing it as a writable (managed) BO would be artificial.
The correct RAP pattern for financial line items is a **read-only** BO, which
is also the most common RAP scenario in day-to-day S/4HANA work: expose CDS
data as an OData V4 service for Fiori elements.

## Object chain

```
ZCS_FI_JOURNAL_ITEMS            (CDS interface view - ACDOCA)
        |
        v
ZR_FI_JournalItem               (root view entity, provider contract
        |                        transactional_query + behavior definition)
        v
ZC_FI_JournalItem               (projection view entity + projection
        |                        behavior definition + metadata extension)
        v
ZSD_FI_JOURNALITEM              (service definition)
        |
        v
Service binding                 (OData V4 - UI, created in ADT)
```

| Object | File | Purpose |
| --- | --- | --- |
| `ZR_FI_JournalItem` (view entity) | `zr_fi_journalitem.ddls.asddls` | RAP root entity |
| `ZR_FI_JournalItem` (behavior) | `zr_fi_journalitem.bdef.asbdef` | `managed` + `read` behavior |
| `ZC_FI_JournalItem` (view entity) | `zc_fi_journalitem.ddls.asddls` | Consumer-facing projection |
| `ZC_FI_JournalItem` (behavior) | `zc_fi_journalitem.bdef.asbdef` | `projection` + `use` |
| `ZC_FI_JournalItem` (metadata ext.) | `zc_fi_journalitem.ddlx.asddlx` | UI annotations (`@UI.lineItem`, ...) |
| `ZSD_FI_JOURNALITEM` | `zsd_fi_journalitem.srvd.srvdsrv` | Service definition |

## Why the root / projection split?

- The **root entity** owns the behavior. Changing it changes what the BO can do.
- The **projection** is what consumers (apps, services) see. Different consumers
  can have different projections of the same BO, and UI annotations live here
  (or in a metadata extension) so they never pollute the business layer.
- **Service definitions** are reusable: the same definition can be exposed as an
  OData V2 *and* V4 binding without duplication.

## Publishing it as OData V4 (in ADT)

1. Activate all objects above (they depend on `ZCS_FI_JOURNAL_ITEMS`).
2. Create a **service binding** `ZSB_FI_JOURNALITEM`:
   - Binding type: **OData V4 - UI**
   - Service definition: `ZSD_FI_JOURNALITEM`
3. **Publish**. The entity set is `JournalItem`.
4. Use **Preview** in ADT to fetch `$metadata` and sample data, or consume it
   from a Fiori elements list report - the metadata extension already provides
   the list columns.

## Note

This is a portfolio template. As with all ABAP source shared outside a system,
activate it in your own release and adjust if an annotation or `provider
contract` keyword differs slightly on your S/4HANA version.
