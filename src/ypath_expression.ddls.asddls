@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Path expression'
@Metadata.ignorePropagatedAnnotations: true
define view entity YPATH_EXPRESSION
  as select from /dmo/travel as travel

  --1st association for Customer
  association [0..1] to /dmo/customer as _Customer on $projection.customer_id = _Customer.customer_id

  --2nd Assciation for Booking
  association [0..1] to /dmo/booking  as _Booking  on $projection.travel_id = _Booking.travel_id
  --3rd association carrier
  association [0..1] to /DMO/I_Agency as _Agency   on $projection.agency_id = _Agency.AgencyID
{
  key travel_id,
      agency_id,
      customer_id,
      begin_date,


      //==========================================
      --             Path Exprssions
      //==========================================

      --1 Single level path ( Travle -> Customer )

      _Customer.first_name   as CustomerFirstName,
      _Customer.last_name    as CustomerLastName,

      --2 Single level path ( Travle -> Agency )
      _Agency.Name           as AgencyNmae,
      _Agency.City           as AgencyCity,

      --3 Deep Path expression _Agency (Travel-> agency-> country -> country text)
      //  _Agency._Country._Text[ Language = $session.system_language ].CountryName as AgencyCountryNmae,

      --4 Deep path expression Via Booking ( Travle-> booking->Carrier)
      --Below path expression it won't work because both are indipendent and created in top of the table
      --if u want create like this we have create seperate view there we have associates with carrier
      --for this kind check in 3 step
      //_Booking._agency

      --5 Aggregation with filter on booking table
      //      @Semantics.amount.currencyCode: 'CurrencyCode'
      //      sum( _Booking.flight_price ) as ConfiremdFlightPrice,
      //      _Booking.currency_code as CurrencyCode,

      --Filtered path expression
      --We can't use aggregration function directly because of data type CURR
      --Below two syntax are not work because of data type issue.
      //SUM(_Booking[ carrier_id = 'AA'].flight_price ) as AAFlightPrice,
      //_Booking[ carrier_id = 'AA'].currency_code as AACurrencyCode,
      -- it will calculate the for each travel for number of bookings
      -- for AA carrier id it will give sum amount
      @Semantics.amount.currencyCode: 'CurrencyCode'
      
 -- If I want perform SUM operation in interface view then below syntax    
      //    sum(
      //      case
      //      --directly we can't use the curr data type we need additional casting
      //       // when _Booking.carrier_id = 'AA' then _Booking.flight_price
      //       -- cast both value and else value
      //       when _Booking.carrier_id = 'AA'
      //       then cast( _Booking.flight_price as abap.curr( 16, 2 ) )
      //        else cast( 0 as abap.curr( 16, 2 ) )
      //        end
      //        ) as AAFlightPrice,
--End      
      
--If I want perform SUM operation in Consumption view then below syntax
      case
        when _Booking.carrier_id = 'AA'
         then cast( _Booking.flight_price as abap.curr( 16, 2 ) )
          else cast( 0 as abap.curr( 16, 2 ) )
          end                as AAFlightPrice,
--end
      _Booking.currency_code as CurrencyCode,

      --Filterd path expression
      --if we use any Aggerated function then other path filter expression also we need use case
      --if data type curr then CAST + CASE
      // _Agency[1: CountryCode = 'US' ].City AS UsCity,
--If in interfcae level we have used Aggegrated Fnction below condition we have to use for Filter      
//      case
//       when _Agency.CountryCode = 'US' then _Agency.City
//       when _Agency.CountryCode = 'DE' then _Agency.City
//       else ''
//      end                    as UsCity,
--end

--If in interfcae level we are not used Aggegrated Fnction below condition we have to use for Filter
        //if any travel id for those agency country code is US or DE then we have to print the city 
        //other wise not.
      _Agency[ CountryCode = 'US'or CountryCode = 'DE'].City as UsCity,
--End      
      --Exposed Association
      _Agency,
      _Booking,
      _Customer
}

//  group by
//  travel_id,
//  agency_id,
//  customer_id,
//  begin_date,
//  _Customer.first_name,
//  _Customer.last_name,
//  _Agency.Name,
//  _Agency.City,
//  //_Booking.flight_price,
//  _Booking.currency_code,
//  _Agency.CountryCode
