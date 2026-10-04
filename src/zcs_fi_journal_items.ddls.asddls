@AbapCatalog.sqlViewName: 'ZCSFIJRNLITM'
@AbapCatalog.compiler.compareFilter: true
@AbapCatalog.preserveKey: true
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Journal Items - Interface View'
@VDM.viewType: #BASIC
define view ZCS_FI_JOURNAL_ITEMS
  as select from acdoca as Journal
    inner join t001 as CompanyCode on CompanyCode.bukrs = Journal.rbukrs
{
      Journal.rldnr     as LedgerId,
  key Journal.rbukrs    as CompanyCode,
  key Journal.gjahr     as FiscalYear,
  key Journal.belnr     as AccountingDocument,
  key Journal.docln     as LineItem,
      Journal.budat     as PostingDate,
      Journal.bldat     as DocumentDate,
      Journal.poper     as PostingPeriod,
      Journal.racct     as GLAccount,
      Journal.hsl       as AmountInCompanyCodeCurrency,
      CompanyCode.waers as CompanyCodeCurrency
}
where
      Journal.rldnr = '0L'
