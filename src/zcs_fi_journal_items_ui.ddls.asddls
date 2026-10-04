@AbapCatalog.sqlViewName: 'ZCSFIJRNLITMUI'
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Journal Items - Consumption View'
@VDM.viewType: #CONSUMPTION
@Metadata.allowExtensions: true
@ObjectModel.usageType: { serviceQuality: #A, sizeCategory: #L, dataClass: #TRANSACTIONAL }
@Search.searchable: true
@UI.headerInfo: {
  typeName: 'Journal Item',
  typeNamePlural: 'Journal Items',
  title: { type: #STANDARD, value: 'AccountingDocument' }
}
define view ZCS_FI_JOURNAL_ITEMS_UI
  as select from ZCS_FI_JOURNAL_ITEMS
{
      @UI.lineItem: [ { position: 10 } ]
      @UI.selectionField: [ { position: 10 } ]
  key CompanyCode,

      @UI.lineItem: [ { position: 20 } ]
  key FiscalYear,

      @UI.lineItem: [ { position: 30 } ]
      @Search.defaultSearchElement: true
  key AccountingDocument,

      @UI.lineItem: [ { position: 40 } ]
  key LineItem,

      @UI.lineItem: [ { position: 50 } ]
      PostingDate,

      @UI.lineItem: [ { position: 60 } ]
      PostingPeriod,

      @UI.lineItem: [ { position: 70 } ]
      @Search.defaultSearchElement: true
      GLAccount,

      @UI.lineItem: [ { position: 80 } ]
      @Semantics.amount.currencyCode: 'CompanyCodeCurrency'
      AmountInCompanyCodeCurrency,

      @UI.lineItem: [ { position: 90 } ]
      CompanyCodeCurrency
}
