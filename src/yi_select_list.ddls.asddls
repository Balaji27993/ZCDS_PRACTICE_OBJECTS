@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Select list scenarios'
@Metadata.ignorePropagatedAnnotations: true
define view entity YI_SELECT_LIST
  as select from /dmo/travel as _Travel
  association [0..*] to /dmo/booking  as _booking  on $projection.travel_id = _booking.travel_id
  association [0..1] to /dmo/customer as _customer on $projection.customer_id = _customer.customer_id

{
      --================================
      -- Direct Columns
      --================================

  key travel_id,
      agency_id,
      customer_id,
      status,
      @Semantics.amount.currencyCode: 'currency_code'
      booking_fee,
      currency_code,

      --===============================
      -- Literals
      --===============================

      'Travel_Header'                                                                      as SourceSystem,
      100                                                                                  as defaultPriorityCode,
      0.18                                                                                 as TaxPercentage,
      '20260927'                                                                           as SystemGoliveDate,
      cast('EUR' as abap.cuky( 5 ) )                                                       as TargetCurrency,
      'USD'                                                                                as FixedCurrency,
      cast(0.00 as abap.dec( 16, 2 ))                                                      as BonusAmount,

      cast(abap.curr'50.00' as abap.dec(16,2 ) )                                           as FixedProcessingFee,

      --Using of literals 
      --scenario is for travle booking we want add the fixed processing fee
      
      cast( booking_fee as abap.dec(16,2 ) ) + cast( $projection.FixedProcessingFee as abap.dec(16, 2 ) ) as totalTravelPrice, 
      --====================================
      --Case statements
      --====================================

      case status
      when 'B' then 'Confiremd Flight'
      when 'X' then 'Cancelled flight'
      else 'pending'
      end                                                                                  as caseStatus,
      --====================================
      --scaller functions
      --====================================

      --string
      concat( 'TRV-', travel_id )                                                          as FormattedTravelId,

      --date function

      dats_days_between( begin_date, end_date )                                            as TripDuration,

      --Math currency filed

      cast( booking_fee as abap.dec( 16, 2 ) ) * cast( 1.18 as abap.dec(4, 2) ) as bookingwithtax,

      --====================================
      --path expressions
      --====================================

      _customer.first_name                                                                 as custfirstname,
      _customer.last_name                                                                  as CustLastNmae,
      concat( _customer.first_name, concat( '',_customer.last_name ) )                     as CustFullName,

      --====================================
      --Aggregation & Conditional Aggregation
      --====================================

      --i want count for no of booiking for each travle
      count( distinct( _booking.booking_id ) )                                             as Total_booing,

      --scaller wrapping aggregrate
      --Avg Ticket cost

      avg( cast(_booking.flight_price as abap.dec(16,2) ) as abap.dec(16,2 ) )             as AvgTicketPrice,

      round( avg( cast(_booking.flight_price as abap.dec(16,2) ) as abap.dec(16,2 ) ), 2 ) as AvgTicketroundPrice,

       --====================================
      --exposed Associations
      --====================================
     _booking,
     _customer
}
  
group by
  travel_id,
  agency_id,
  customer_id,
  booking_fee,
  currency_code,
  status,
  begin_date,
  end_date,
  _customer.first_name,
  _customer.last_name
  
  
