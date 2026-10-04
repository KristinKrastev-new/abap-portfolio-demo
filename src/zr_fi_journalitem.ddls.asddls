@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Journal Item'
@Metadata.allowExtensions: true
define root view entity ZR_FI_JournalItem
  provider contract transactional_query
  as select from ZCS_FI_JournalItems
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
