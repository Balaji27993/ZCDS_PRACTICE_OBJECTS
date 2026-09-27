@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Aggeration and grouping'
@Metadata.ignorePropagatedAnnotations: true
/*
 Calculate the total booking expenditure and total count of booking made per customer
  exculude customers whose total spent amount if less than 500.
  only we want USA currency code
*/
/*
Key points
we can use both where condition and having caluse
group by is nothing but its group the data based on the fileds mentinod in group list.
Having Caluse we can use only in aggerated function other wise we can't use
with out grouping can not use Having caluse
only where or group --we can use
where + group-- we can use
where + group + having -- we can use
group + having -- we can use
where + having --we can't use
all the filed list should be mentioned in group list
*/
define view entity YI_aggregation_group
  as select from /dmo/booking
{
  key booking_id           as booking_id,
      customer_id          as Customer_id,
      connection_id        as connection_id,
      //1. Calculate aggerated value total value
      @Semantics.amount.currencyCode: 'currency_code'
      sum ( flight_price ) as flight_price,
      //flight_price  as flight_price,
      currency_code        as currency_code,
      //2. Count total Number of bookings
      count( * )           as TotalBooking

}
 where currency_code = 'USD'
//3. Group by non-Aggerated value
group by
  booking_id,
  customer_id,
  connection_id,
  currency_code,
  //4. Filter on aggerated values.
  flight_price
having
  sum( flight_price) >= 500
