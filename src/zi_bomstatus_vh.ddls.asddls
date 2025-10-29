@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Stock request types'
@Metadata.ignorePropagatedAnnotations: true
@ObjectModel.usageType:{
    serviceQuality: #X,
    sizeCategory: #S,
    dataClass: #MIXED
}
@ObjectModel.resultSet.sizeCategory: #XS
@Search.searchable: true
define view entity ZI_BOMSTATUS_VH
  as select from DDCDS_CUSTOMER_DOMAIN_VALUE_T( p_domain_name: 'ZBOMSTATUS' )
{
      //      @UI.textArrangement: #TEXT_ONLY
      //      @UI.lineItem: [{ position: 10, importance: #HIGH }]
  key domain_name,
  key value_position,
      value_low,
      @Search.defaultSearchElement: true
      text


}
where
  language = $session.system_language
