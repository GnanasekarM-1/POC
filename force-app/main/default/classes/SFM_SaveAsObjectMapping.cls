public with sharing class SFM_SaveAsObjectMapping{
    public SFM_saveAsObjectMapping(){}
    public SFM_WrapperDef.SFM_Response saveAsObjectMappingInfo(SFM_WrapperDef.SFM_Request_ObjectMap prequest)
     {
        List<SFM_WrapperDef.SFM_StringMap> stringMap = new List<SFM_WrapperDef.SFM_StringMap>();
        SVMX_Debug log = new SVMX_Debug();
        //List<SFM_WrapperDef.SFM_StringMap> requestedId = prequest.stringMap;
        String SFId;
        log.login('SFM_saveAsObjectMapping', 'saveAsObjectMappingInfo(SFM_WrapperDef.SFM_Request prequest)');
        Boolean response_success;
        String response_message;
        String response_tagId;
        SFM_Utils utils = new SFM_Utils();
        //List<SFM_WrapperDef.SFM_StringMap> response_stringMap = new List<SFM_WrapperDef.SFM_StringMap>();
        List<String> resultIds=new List<String>();
        Map<String, Id> objectRecType_Map = new Map<String, Id>();
        List<String> recTypeNames = new List<String>();
        recTypeNames.add('SVMXC__ServiceMax_Processes__c~Object Mapping');
        recTypeNames.add('SVMXC__ServiceMax_Config_Data__c~Field Mapping');
        objectRecType_Map = utils.getRecordTypes(recTypeNames);
        Savepoint sp;
        SFM_WrapperDef.SFM_Response response = new SFM_WrapperDef.SFM_Response();
        SVMXC__ServiceMax_Processes__c LstObjectMap = new SVMXC__ServiceMax_Processes__c();
        SVMXC__ServiceMax_Processes__c ClonedLstObjectMap = new SVMXC__ServiceMax_Processes__c();
        List<SFM_WrapperDef.SFM_FieldMapping> fieldMapping = new List<SFM_WrapperDef.SFM_FieldMapping>();
        List<SFM_WrapperDef.SFM_FieldMapping> ClonefieldMapping = new List<SFM_WrapperDef.SFM_FieldMapping>();
        List<SFM_WrapperDef.SFM_ObjectMap> ObjMapList =  prequest.objects;
        List<SFM_WrapperDef.SFM_ObjectMap> ObjMapList1=new List<SFM_WrapperDef.SFM_ObjectMap>();
       
        log.setlog('SAVEPOINT', 'Setting up savepoint before creating');
        sp = Database.setSavepoint();
        system.debug('Mainfdbfdf'+prequest);
        system.debug('Main123'+prequest.objects);
        
        
         for(SFM_WrapperDef.SFM_ObjectMap ObjMap: ObjMapList)
            {
                
               LstObjectMap=ObjMap.objectMap; 
               fieldMapping.addAll(ObjMap.fields);
               LstObjectMap.SVMXC__IsStandard__c = false;
               
            }
             SFM_WrapperDef.SFM_ObjectMap oSFM_ObjtMap = new SFM_WrapperDef.SFM_ObjectMap(LstObjectMap,fieldMapping);
             ObjMapList1.add(oSFM_ObjtMap);
             SFM_WrapperDef.SFM_Request_ObjectMap ReqObjmap = new SFM_WrapperDef.SFM_Request_ObjectMap(ObjMapList1);
            
        
        /*SVMXC.SFM_WrapperDef.SFM_Response_ObjectMap ResObjectMap;
        SVMXC.SFM_getObjectMapping getObjectMap = new SVMXC.SFM_getObjectMapping();
        ResObjectMap = getObjectMap.getDefaultFieldmapping(prequest);
        if(ResObjectMap!=null)
        {
           for(SFM_WrapperDef.SFM_ObjectMap ObjectMapinfo: ResObjectMap.objects)
             {
                    LstObjectMap = ObjectMapinfo.objectMap;
                    fieldMapping.addAll(ObjectMapinfo.fields);
                    if(LstObjectMap != null)
                    {
                      ClonedLstObjectMap = LstObjectMap.clone(false,true);
                      //ClonedLstObjectMap.SVMXC__Name__c = ClonedLstObjectMap.SVMXC__Name__c + ' ' + system.now();
                      //ClonedLstObjectMap.SVMXC__MapID__c = ClonedLstObjectMap.SVMXC__MapID__c + ' ' + system.now();
                      ClonedLstObjectMap.SVMXC__IsStandard__c = false;
                      ClonedLstObjectMap.RecordTypeId = objectRecType_Map.get('SVMXC__ServiceMax_Processes__c~Object Mapping');
                      
                    }
                   
             }
        }
          if(fieldMapping.size() > 0)
             {
                for(Integer i = 0;i<fieldMapping.size();i++)
                  {
                     SVMXC.SFM_WrapperDef.SFM_FieldMapping FM;
                     FM = fieldMapping[i];
                     SVMXC__ServiceMax_Config_Data__c fieldMapRecord = new SVMXC__ServiceMax_Config_Data__c();
                     List<SFM_WrapperDef.SFM_StringMap> sourceFields = new List<SFM_WrapperDef.SFM_StringMap>();
                     fieldMapRecord = FM.fieldMapRecord.clone(false,true);
                     fieldMapRecord.RecordTypeId = objectRecType_Map.get('SVMXC__ServiceMax_Config_Data__c~Field Mapping');
                     ClonefieldMapping.add(new SVMXC.SFM_WrapperDef.SFM_FieldMapping(fieldMapRecord,sourceFields));
                  }
            
             }
             SFM_WrapperDef.SFM_ObjectMap oSFM_ObjtMap = new SFM_WrapperDef.SFM_ObjectMap(ClonedLstObjectMap,ClonefieldMapping);
             ObjMapList.add(oSFM_ObjtMap);
             SFM_WrapperDef.SFM_Request_ObjectMap ReqObjmap = new SFM_WrapperDef.SFM_Request_ObjectMap(ObjMapList);*/
             SVMXC.SFM_saveObjectMapping saveObjtmap = new SVMXC.SFM_saveObjectMapping();
             return saveObjtmap.SFM_saveObjectMapping(ReqObjmap);
}
}