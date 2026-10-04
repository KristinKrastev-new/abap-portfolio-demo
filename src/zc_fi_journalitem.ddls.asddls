@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Journal Item'
@Metadata.allowExtensions: true
define root view entity ZC_FI_JournalItem
  provider contract transactional_query
  as projection on ZR_FI_JournalItem
{
  key CompanyCode,
  key FiscalYear,
  key AccountingDocument,
  key LineItem,
      PostingDate,
      DocumentDate,
      PostingPeriod,
      GLAccount,
      AmountInCompanyCodeCurrency,
      CompanyCodeCurrency
}
