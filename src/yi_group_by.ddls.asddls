@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Group by examples'
@Metadata.ignorePropagatedAnnotations: true
define view entity YI_GROUP_BY as select from /dmo/connection
{
    --Regular columns ( Row Level )-->Must be include in Group by list
    key carrier_id,
        connection_id,
        airport_from_id,
        
     --scaller functions
     concat( carrier_id, concat( '-' , airport_to_id ) ) as flightRootcode,  
     
     --Pure aggregate function
          count( * ) as Totalconnections,
     sum( distance ) as totalDistance,
     max( distance ) as Maxdistance,  
     
     --scaller function that wrappes and aggerate function
     
    // round( cast( avg( cast( distance as abap.dec( 16,2 ) ) ) , 0  as abap.dec(16, 2 ) ) as roundavgdistance,
     
     --complex aggerated function
     --avg distance
     cast( ( cast( sum( distance ) as abap.dec( 16, 2 ) ) / count( * ) ) as abap.dec( 16, 2 ) ) as avgdistance
     
     
     
      
} group by 
 carrier_id,
 connection_id,
 airport_from_id,
 airport_to_id
  
