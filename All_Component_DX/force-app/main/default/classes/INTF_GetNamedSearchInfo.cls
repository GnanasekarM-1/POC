public with sharing class INTF_GetNamedSearchInfo 
{
     public INTF_getNamedSearchInfo(){}
     public INTF_WebServicesDef.INTF_Response_NamedSearchInfo getNamedSearchInfo(INTF_WebServicesDef.INTF_Request prequest)
     {
      SVMX_Debug log = new SVMX_Debug();
      List<INTF_WebServicesDef.INTF_NamedSearchInfo> NSI = new List<INTF_WebServicesDef.INTF_NamedSearchInfo>();
      List<INTF_WebServicesDef.INTF_StringMap> expressionDefinition = new List<INTF_WebServicesDef.INTF_StringMap>();
      List<INTF_WebServicesDef.INTF_NamedSearchInfo> namedsrchinfo = new List<INTF_WebServicesDef.INTF_NamedSearchInfo>();
      Map<string,list<SVMXC__ServiceMax_Config_Data__c>> MapNamedExpDetail = new Map<string,list<SVMXC__ServiceMax_Config_Data__c>>();
      Map<string,SVMXC__ServiceMax_Processes__c> MapNamedExp = new Map<string,SVMXC__ServiceMax_Processes__c>();
      list<SVMXC__ServiceMax_Processes__c > LstnamedSearch = new list<SVMXC__ServiceMax_Processes__c >(); 
      list<SVMXC__ServiceMax_Processes__c > LstnamedSearch1 = new list<SVMXC__ServiceMax_Processes__c >();
      list<SVMXC__ServiceMax_Config_Data__c> LstnamedSearchDetails = new list<SVMXC__ServiceMax_Config_Data__c>();
      Map<String, SVMXC__ServiceMax_Processes__c> searchHeaders_Map = new Map<String, SVMXC__ServiceMax_Processes__c>();
      list<string> namedsearchId = new list<string>();
      Map<String, String> searchType_Map = new Map<String, String>();
      list<string> namedsearchId1 = new list<string>();   
      List<INTF_WebServicesDef.INTF_NamedSearchInfoDetail> namedsrchinfodtl=new List<INTF_WebServicesDef.INTF_NamedSearchInfoDetail>();
      List<INTF_WebServicesDef.INTF_StringMap> requestedId = prequest.stringMap;
      String SFId;
      Map<String, List<SVMXC__ServiceMax_Processes__c>> searchHeaders_LMap = new Map<String, List<SVMXC__ServiceMax_Processes__c>>();
      List<SVMXC__ServiceMax_Processes__c> searchHeader_LTemp;
      SVMXC__ServiceMax_Processes__c namedSearch; 
      list<string> NSType = new list<string>();
      NSType.add('Search');
      NSType.add('Result');
      list<string> LCType = new list<string>();
      LCType.add('Search');
      LCType.add('Result');
      LCType.add('Bubble');
      log.login('SFM_getNamedSearchInfo', 'getNamedSearchInfo(INTF_WebServicesDef.INTF_Request prequest)');
      try
        {
          for(INTF_WebServicesDef.INTF_StringMap req: requestedId)
            {
                if(req.key.toUpperCase() == 'RECORDID')
                SFId = req.value;
               
            }
          if(SFId != null)
            {
                log.setlog('QUERY', 'Retrieve the Header for the given Id');
                LstnamedSearch = [SELECT Id, Name, SVMXC__Name__c,SVMXC__Source_Object_Name__c,SVMXC__Description__c ,SVMXC__ProcessID__c,SVMXC__Rule_Type__c,SVMXC__IsStandard__c,SVMXC__IsDefault__C,SVMXC__Active__c,SVMXC__Number_of_Lookup_Records__c,SVMXC__Default_Lookup_Column__c from SVMXC__ServiceMax_Processes__c where Recordtype.Name='Named Search' AND Id = :SFId];    //SDL-SVMX-FLS-NOT-ENFORCED-META-DATA
                
            }
          if(LstnamedSearch.size() > 0)
            {
                log.setlog('LOOPING-Start', 'Looping through list of servicemax processes to set map header and its ids');
                for(SVMXC__ServiceMax_Processes__c p : LstnamedSearch)
                {
                    namedsearchId.add(p.Id);
                    searchHeaders_Map.put(p.Id, p);
                    searchType_Map.put('SEARCHTYPE',p.SVMXC__Rule_Type__c);
                    searchHeader_LTemp = new List<SVMXC__ServiceMax_Processes__c>();
                    if(p.Id != NULL){
                    if(searchHeaders_LMap.get(p.Id) != NULL){
                        searchHeader_LTemp = searchHeaders_LMap.get(p.Id);
                    }
                    searchHeader_LTemp.add(p);
                    searchHeaders_LMap.put(p.Id, searchHeader_LTemp);
                }
               }
               log.setlog('LOOPING-Start', 'Looping through list of servicemax processes to set map header and its ids');
               log.setlog('QUERY', 'Retrieve the HeaderChild for the above  set ids');
               LstnamedSearch1 = [SELECT Id, Name, SVMXC__Source_Object_Name__c, SVMXC__Process__c ,SVMXC__Sequence__c,SVMXC__Module__c from SVMXC__ServiceMax_Processes__c where Recordtype.Name='Named Search' And SVMXC__Rule_Type__c='SRCH_OBJECT' And SVMXC__Module__c IN:namedsearchId];   //SDL-SVMX-FLS-NOT-ENFORCED-META-DATA
            }
          if(LstnamedSearch1.size() > 0)
            {
                for(SVMXC__ServiceMax_Processes__c p : LstnamedSearch1)
                {
                    namedsearchId1.add(p.Id);
                    list<SVMXC__ServiceMax_Config_Data__c> LstTemp = new list<SVMXC__ServiceMax_Config_Data__c>();
                    MapNamedExpDetail.put(p.Id,LstTemp);
                    MapNamedExp.put(p.Id,p);
                    
                }
                log.setlog('QUERY', 'Retrieve the Detail like fields  for the above process');
                for(string Key : searchType_Map.keySet())
                {
                    if(searchType_Map.get(Key) == 'SRCH_NAMED_SEARCH')
                    LstnamedSearchDetails = [SELECT SVMXC__Sequence__c,SVMXC__Search_Object_Field_Type__c,SVMXC__Field_Name__c, SVMXC__Expression_Rule__c, Name, Id,SVMXC__Object_Name__c,SVMXC__FKey_Name_Field__c,SVMXC__Display_Type__c,SVMXC__Field_Relationship_Name__c From SVMXC__ServiceMax_Config_Data__c where Recordtype.Name='Expressions' AND SVMXC__Expression_Type__c = 'SRCH_Object_Fields' And SVMXC__Search_Object_Field_Type__c IN:NSType And SVMXC__Expression_Rule__c IN:namedsearchId1];   //SDL-SVMX-FLS-NOT-ENFORCED-META-DATA
                    else
                    LstnamedSearchDetails = [SELECT SVMXC__Sequence__c,SVMXC__Search_Object_Field_Type__c,SVMXC__Field_Name__c, SVMXC__Expression_Rule__c, Name, Id,SVMXC__Object_Name__c,SVMXC__FKey_Name_Field__c,SVMXC__Display_Type__c,SVMXC__Field_Relationship_Name__c From SVMXC__ServiceMax_Config_Data__c where Recordtype.Name='Expressions' AND SVMXC__Expression_Type__c = 'SRCH_Object_Fields' And SVMXC__Search_Object_Field_Type__c IN:LCType And SVMXC__Expression_Rule__c IN:namedsearchId1];   //SDL-SVMX-FLS-NOT-ENFORCED-META-DATA
                    
                }
                
            }
           if(LstnamedSearchDetails.size() > 0)
            {
                for(SVMXC__ServiceMax_Config_Data__c Oconf : LstnamedSearchDetails)
                {
                    if(MapNamedExpDetail.containsKey(Oconf.SVMXC__Expression_Rule__c))
                        MapNamedExpDetail.get(Oconf.SVMXC__Expression_Rule__c).add(Oconf);
                }
                
            }
             if(MapNamedExpDetail.size() > 0)
            {    
                for(string Key : MapNamedExpDetail.keySet())
                {
                    INTF_WebServicesDef.INTF_NamedSearchInfoDetail oSFM_Exp = new INTF_WebServicesDef.INTF_NamedSearchInfoDetail(MapNamedExp.get(Key),MapNamedExpDetail.get(Key));
                    namedsrchinfodtl.add(oSFM_Exp);
                }
                
            } 
           for(String header: searchHeaders_LMap.keySet())
            {
                namedSearch = searchHeaders_Map.get(header);
                
            }
        }
        catch(exception ex)
        {
          log.setlog('ERROR', ex.getmessage());
        }
        log.logout();
        log.print();
        log.getlog();
        INTF_WebServicesDef.INTF_NamedSearchInfo oSFM_Exp1 = new INTF_WebServicesDef.INTF_NamedSearchInfo(namedSearch,namedsrchinfodtl);
        NSI.add(oSFM_Exp1);
        INTF_WebServicesDef.INTF_Response_NamedSearchInfo ResNamedSearch = new INTF_WebServicesDef.INTF_Response_NamedSearchInfo(NSI);
        return ResNamedSearch;
   
     }
}