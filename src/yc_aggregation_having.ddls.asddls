@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Composition Having Caluse'
@Metadata.ignorePropagatedAnnotations: true
/*
in Interface view having caluse we can't use the built in function so that
in interface view in element list get the data and here can add in where caluse
in consumption we can directly put the where caluse
*/
define view entity YC_AGGREGATION_HAVING
  with parameters
    p_minTotalSpend : /dmo/flight_price
  as select from YI_AGGREGATION_HAVING( p_minTotalSpend : $parameters.p_minTotalSpend )
{
  key booking_id,
      customer_id,
      @Semantics.amount.currencyCode: 'currency_code'
      totalspend,
      TotalBooking,
       @Semantics.amount.currencyCode: 'currency_code'
      TotalUsdSpend,
      currency_code,
      Avgspenderbooking,
      Roundavgprice
      

} where $parameters.p_minTotalSpend >= 0

--Total Amount spent
and totalspend >= 500

--Total Count
and TotalBooking >= 1

--replace: and( sum( flight_price ) / count(*) ) >  100
and Avgspenderbooking >= 100

--Having complex USD case 
and TotalUsdSpend >= 1000 
