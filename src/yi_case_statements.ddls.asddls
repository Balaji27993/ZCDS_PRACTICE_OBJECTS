@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Case statements'
@Metadata.ignorePropagatedAnnotations: true
/*
In Where condition we can't add the case statemets
Case statement always we can use in select field list 
if in CURR Field casting rule is for ex we adding sum or avg we should exceptly we need 
perform casting operation
*/
define view entity YI_CASE_STATEMENTS
  as select from /dmo/booking as booking
    inner join   /dmo/travel  as travel on booking.travel_id = travel.travel_id

{
  key booking.booking_id,
      booking.carrier_id,
      booking.connection_id,
      travel.status,
      @Semantics.amount.currencyCode: 'currency_code'
      booking.flight_price,
      booking.currency_code,


      --simple case
      case travel.status
      when 'B' then 'Confiremd Flight'
      when 'X' then 'Cancelled flight'
      else 'pending'
      end                                                    as Booking_status,

      -- range condition
      case
      when booking.flight_price >= 100 and booking.flight_price <= 999 then 'Medium'
      when booking.flight_price > 1000 and booking.flight_price <= 9999 then 'VIP'
      else 'Standard'
      end                                                    as Ticket_type,

      -- Conditional aggregation
      @Semantics.amount.currencyCode: 'currency_code'
      sum( case
              when travel.status = 'B'
               then cast( booking.flight_price as abap.curr( 16, 2 ) )
                else  cast( 0 as abap.curr( 16, 2 ) )  end ) as TOTALACTIVESPEND
}
group by
  booking.booking_id,
  booking.carrier_id,
  booking.connection_id,
  travel.status,
  booking.flight_price,
  booking.currency_code
