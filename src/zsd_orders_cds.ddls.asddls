@AbapCatalog.sqlViewName: 'ZSDORDERSV'
@AbapCatalog.compiler.compareFilter: true
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Country CDS View'

@UI.headerInfo: {
  typeName: 'Country',
  typeNamePlural: 'Countries',
  title: { value: 'Country' }
}

define view ZSD_ORDERS_CDS 
  as select from I_Country
{
      @UI.lineItem: [{ position: 10, label: 'Country Code', importance: #HIGH }]
      @UI.selectionField: [{ position: 10 }]
      @UI.identification: [{ position: 10 }]
  key Country,
  
      @UI.lineItem: [{ position: 20, label: 'ISO3 Code' }]
      @UI.identification: [{ position: 20 }]
      CountryThreeLetterISOCode,
      
      @UI.lineItem: [{ position: 30, label: 'ISO Code' }]
      CountryISOCode,
      
      @UI.lineItem: [{ position: 40, label: 'EU Member', criticality: 'EuCriticality' }]
      @UI.selectionField: [{ position: 20 }]
      IsEuropeanUnionMember,
      
      @UI.lineItem: [{ position: 50, label: 'EU Status' }]
      case IsEuropeanUnionMember
        when 'X' then 'EU Tag'
        else 'Nem EU'
      end as EuStatus,
      
      // Criticality mező (szín vezérlés)
      case IsEuropeanUnionMember
        when 'X' then 3  // 3 = Zöld (pozitív)
        else 1           // 1 = Piros (negatív)
      end as EuCriticality
}
