# Exposing the CDS view as an OData service

The consumption view `ZCS_FI_JOURNAL_ITEMS_UI` is ready to be published as an
OData service so a Fiori/UI5 app (or any REST client) can read it. Steps in
Eclipse ADT (works the same way in S/4HANA 2022):

## 1. Service definition

Create `ZSD_FI_JOURNAL_ITEMS` in package `ZFI_JOURNAL`:

```abap
@EndUserText.label: 'Journal Items OData Service'
define service ZSD_FI_JOURNAL_ITEMS {
  expose ZCS_FI_JOURNAL_ITEMS_UI as JournalItems;
}
```

Separating the service *definition* from the service *binding* means the same
service can be exposed as V2 and V4 without duplicating the definition.

## 2. Service binding

Create `ZSB_FI_JOURNAL_ITEMS`:

- **Binding type:** `OData V4 - UI` (or `OData V2 - UI` if the consuming app
  is older).
- **Service definition:** `ZSD_FI_JOURNAL_ITEMS`.
- Activate, then click **Publish**.

## 3. Test it

In ADT, open the binding and use **Preview** to fetch metadata and sample data.
The entity set is `JournalItems`. Example metadata request:

```
/sap/opu/odata4/sap/zsb_fi_journal_items/srvd/sap/zsd_fi_journal_items/0001/$metadata
```

## 4. Front end (optional)

Register the service in `/IWFND/MAINT_SERVICE` and use it in an SAP Fiori
elements / freestyle UI5 app. Because `ZCS_FI_JOURNAL_ITEMS_UI` already carries
`@UI.lineItem` and `@UI.headerInfo` annotations, a Fiori elements list report
works with almost no extra code - the annotations *are* the UI.

## Why this matters

This shows the whole Moderne ABAP chain, not just a report: **table (ACDOCA)
-> interface view -> consumption view (+ annotations) -> service definition
-> binding -> OData -> Fiori.** That is the pipeline most S/4HANA customers
are moving their custom code onto.
