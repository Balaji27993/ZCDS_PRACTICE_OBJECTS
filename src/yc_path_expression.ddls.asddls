@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Consumption view'
@Metadata.ignorePropagatedAnnotations: true
define view entity YC_PATH_EXPRESSION as select from YPATH_EXPRESSION
{
    key  travel_id,
        agency_id,
        customer_id,
        begin_date,
        CustomerFirstName,
        CustomerLastName,
        AgencyNmae,
        AgencyCity,
        @Semantics.amount.currencyCode: 'CurrencyCode'
        sum( AAFlightPrice ) as AAFlghtCurr,
        CurrencyCode,
        UsCity,
        /* Associations */
        _Agency,
        _Booking,
        _Customer
}
group by
  travel_id,
  agency_id,
  customer_id,
  begin_date,
  CustomerFirstName,
  CustomerLastName,
  AgencyNmae,
  AgencyCity,
  CurrencyCode,
  UsCity
