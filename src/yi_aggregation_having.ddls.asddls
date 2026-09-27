@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Aggeration and having sum'
@Metadata.ignorePropagatedAnnotations: true
/*
In below scenario it covered all having aggerated scenarios
Taking one parameter and we are passing amount to that and in having condition
checking with different scenarios
i want  Curr USD for booking is greaterthean 1000 the we can show in output
*/
/*
Key Points
--Normal simple sum will work
--Aggerated comperasion from input(parameter ) will work
--Normal case conditions will work
--Using Currency Fileds Inside Case won't work
--Using Cast inside having Caluse
--Arthmetic operations between aggerated functions
--Built in, Scaller functions won't work
--Condition: if a condition required currency amount inside case or type casting built in fnction 
--we need to use in Consumption view
*/
define view entity YI_AGGREGATION_HAVING
  with parameters
    p_minTotalSpend : /dmo/flight_price
  as select from /dmo/booking
{
  key booking_id,
      customer_id,
      @Semantics.amount.currencyCode: 'currency_code'
      sum( flight_price) as totalspend,
      count( * )         as TotalBooking,
      
      --Total avg spent on booking 
      //Div( cast( sum( flight_price ) as abap.curr( 16, 2 ) ) , count(*) ) as Avgspenderbooking,
       cast( ( cast( sum( flight_price ) as abap.dec(16, 2) ) / count( * ) ) as abap.dec(16, 2 ) ) as Avgspenderbooking,
      --Round
      round( cast( avg( flight_price as abap.curr( 16, 2 ) ) as abap.dec( 16, 2 ) ) , 0 ) as Roundavgprice,
      
      @Semantics.amount.currencyCode: 'currency_code'
      sum( case when currency_code = 'USD' 
       then cast( flight_price as  abap.curr( 16, 2 ) )  
       else cast( 0 as abap.curr( 16, 2 ) ) end ) as TotalUsdSpend,
      currency_code
      

      
}
//Standarding filtering
where
  $parameters.p_minTotalSpend >= 0

group by
  booking_id,
  customer_id,
  currency_code
--=====================================
--Valid Having Clause scenarios
--=====================================
having
  --scanrio1: simple aggeration
      sum( flight_price )                                      >= 500

  --Scenario2: Count Aggeration
  --the below condition is it will give group count
  and count( * )                                               >= 1

  //  --Scenrio3: Arthmetic ratio between aggerated (AVG
  //  and( sum( flight_price ) / count(*) ) >  100

  --Scenario4: Built-in functions

  //and round( avg( flight_price as abap.curr( 16, 2 ) ), 0  ) >=50

  --Scenario 5: Parameter Comparision againest and aggregate
  and sum( flight_price )                                      >= $parameters.p_minTotalSpend

  --Scenario 6: Conditionla logic ( Case When ) inside Aggregate
  --Below scenario is first it will chekc the curency code, if the code is USD
  -- Then it will check total USD bookings if there is no USD bookings
  -- then it will not show in output
  --if USD bookings at least 1 or greaterthan 1 then show in output
  and sum( case when currency_code = 'USD' then 1 else 0 end ) >= 0
  --similarlly 3 USD BOOKINGS
 // and sum( case when currency_code = 'USD' then 1 else 0 end ) >= 1
  --Specific Amount if booking USD more then 1000 dolors then show in output
    //and sum(  case when currency_code = 'USD' then cast ( flight_price as abap.dec( 16, 2 ) ) else 0 end ) > 1000
    //then flight_price else 0 end ) > 1000
   //  then cast(flight_price as abap.curr( 16, 2 ) )
   //  else cast( 0 as abap.curr( 16, 2 ) )end  ) >  1000
            
            
            
            
            
