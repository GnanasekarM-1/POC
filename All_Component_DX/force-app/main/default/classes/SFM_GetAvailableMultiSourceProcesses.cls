/* Security Scanned */
public with sharing class SFM_GetAvailableMultiSourceProcesses {

    public map<String, Schema.SObjectType> mapAllObjDesc = new map<String, Schema.SObjectType>();
    public map<String, Schema.SObjectType> mapObjAPINameDesc = new map<String, Schema.SObjectType>();
    public SFM_GetAvailableMultiSourceProcesses(){
        mapAllObjDesc = Schema.getGlobalDescribe();
        for(String str : mapAllObjDesc.keyset()){
            mapObjAPINameDesc.put(mapAllObjDesc.get(str).getDescribe().getName(),mapAllObjDesc.get(str));
        }
    }
    public SVMXC.SFM_WrapperDef.SFM_Response getAvailableMultiSourceProcesses(SVMXC.SFM_WrapperDef.SFM_Request request){
        SVMXC.SFM_WrapperDef.SFM_Response response = new SVMXC.SFM_WrapperDef.SFM_Response();
        String strObjectAPIName = '';
        String strSFMProcessId = '';
        String strSFMSFId = '';
        map<String,Schema.SObjectField> mapFieldDesc = new map<String,Schema.SObjectField>();
        
        if(request != null && request.stringMap != null && request.stringMap.size() > 0){
            for(Integer i = 0;i<request.stringMap.size();i++){
                if(request.stringMap[i].key == 'OBJECTAPINAME')
                    strObjectAPIName = request.stringMap[i].value;
                else if(request.stringMap[i].key == 'SFMPROCESSID')
                    strSFMProcessId = request.stringMap[i].value;
                else if(request.stringMap[i].key == 'SFMSFID')
                    strSFMSFId = request.stringMap[i].value;    
                        
            }
        }
        system.debug('strObjectAPIName'+strObjectAPIName);
        if(strObjectAPIName != '' && strObjectAPIName.length() > 0 && mapObjAPINameDesc.containskey(strObjectAPIName)){
            set<String> setWhiteListObject = new set<String>();
            map<String,list<String>> mapObjectNameRefFieldName = new map<String,list<String>>();
            map<String,String> mapFieldAPINameFieldLabel = new map<String,String>(); 
            //SVMXC.COMM_Utils comutils = new SVMXC.COMM_Utils();
            //Commented above line and added below for using latest version class of COMM_Utils for the defect BAC-4477
            SVMXC.COMM_Utils_V2 comutils = new SVMXC.COMM_Utils_V2();
            map<String,Boolean>  mapParmittedObject = comutils.SVMX_getPermittedStandardObjectList();
            //system.debug('mapParmittedObject :'+mapParmittedObject);
            setWhiteListObject = mapParmittedObject.keyset();
            //system.debug('setWhiteListObject :'+setWhiteListObject);
            mapFieldDesc = mapObjAPINameDesc.get(strObjectAPIName).getDescribe().fields.getMap();
            mapFieldDesc = comutils.removeDuplicateFields(mapFieldDesc); //Added for fixing defect BAC-4477
            for(String str : mapFieldDesc.keyset()){
                if(mapFieldDesc.get(str).getDescribe().getType().name() == 'REFERENCE'){
                    mapFieldAPINameFieldLabel.put(mapFieldDesc.get(str).getDescribe().getName(),mapFieldDesc.get(str).getDescribe().getLabel());
                    Schema.sObjectType sObj =  mapFieldDesc.get(str).getDescribe().getReferenceTo()[0];
                    if(sObj.getDescribe().isCustom()){
                        //system.debug('Field API Name :'+mapFieldDesc.get(str).getDescribe().getName());
                        //system.debug('Object Name :'+mapFieldDesc.get(str).getDescribe().getReferenceTo());
                        if(!mapObjectNameRefFieldName.containskey(sObj.getDescribe().getName()))
                            mapObjectNameRefFieldName.put(sObj.getDescribe().getName(),new list<String>());
                        mapObjectNameRefFieldName.get(sObj.getDescribe().getName()).add(mapFieldDesc.get(str).getDescribe().getName());
                    }   
                    else{
                        //system.debug('Field API Name :'+mapFieldDesc.get(str).getDescribe().getName());
                        //system.debug('Object Name :'+mapFieldDesc.get(str).getDescribe().getReferenceTo());
                        if(setWhiteListObject.contains(sObj.getDescribe().getName())){
                            if(!mapObjectNameRefFieldName.containskey(sObj.getDescribe().getName()))
                                mapObjectNameRefFieldName.put(sObj.getDescribe().getName(),new list<String>());
                            mapObjectNameRefFieldName.get(sObj.getDescribe().getName()).add(mapFieldDesc.get(str).getDescribe().getName());
                        }   
                    }
                }   
            }
            system.debug('mapObjectNameRefFieldName'+mapObjectNameRefFieldName);
            //Query Target Process Node Object 
            list<SVMXC__ServiceMax_Processes__c> lstTargetProcessNodeObj = new list<SVMXC__ServiceMax_Processes__c>();
            if(strSFMSFId != '' && strSFMSFId.length() > 0)
            {
                try{
                    //SDL-SVMX-FLS-NOT-ENFORCED-META-DATA
                    lstTargetProcessNodeObj = [Select Id, SVMXC__Process__c, SVMXC__Source_Object_Name__c from SVMXC__ServiceMax_Processes__c where recordtype.Name = 'Process Node Objects' and SVMXC__Type__c =: 'TARGET' and  SVMXC__Source_Object_Name__c =: strObjectAPIName and SVMXC__Process__c !=: strSFMSFId and SVMXC__Process__r.SVMXC__Purpose__c = 'SOURCE TO TARGET ALL'];
                }
                catch(QueryException ex){
                    response.message = ex.getMessage();
                    return response;
                }
            }
            else
            {
                try{
                    //SDL-SVMX-FLS-NOT-ENFORCED-META-DATA
                    lstTargetProcessNodeObj = [Select Id, SVMXC__Process__c, SVMXC__Source_Object_Name__c from SVMXC__ServiceMax_Processes__c where recordtype.Name = 'Process Node Objects' and SVMXC__Type__c =: 'TARGET' and  SVMXC__Source_Object_Name__c =: strObjectAPIName and SVMXC__Process__r.SVMXC__Purpose__c = 'SOURCE TO TARGET ALL'];
                }
                catch(QueryException ex){
                    response.message = ex.getMessage();
                    return response;
                }
            }       
            set<Id> setSFMID = new set<Id>(); 
            for(SVMXC__ServiceMax_Processes__c pro : lstTargetProcessNodeObj){
                setSFMID.add(pro.SVMXC__Process__c);
            }
            system.debug('lstTargetProcessNodeObj'+lstTargetProcessNodeObj);
            system.debug('setSFMID'+setSFMID);
            //Query Source Process Node Objects
            list<SVMXC__ServiceMax_Processes__c> lstSourceProcessNodeObj = new list<SVMXC__ServiceMax_Processes__c>(); 
            try{
                //SDL-SVMX-FLS-NOT-ENFORCED-META-DATA
                lstSourceProcessNodeObj = [Select Id, SVMXC__Process__c, SVMXC__Source_Object_Name__c from SVMXC__ServiceMax_Processes__c where recordtype.Name = 'Process Node Objects' and SVMXC__Type__c =: 'SOURCE' and SVMXC__Source_Object_Name__c IN : mapObjectNameRefFieldName.keyset() and SVMXC__Process__c IN : setSFMID];
            }
            catch(QueryException ex){
                response.message = ex.getMessage();
                return response;
            }
            
            map<String,set<Id>> mapSouceObjectSFMIds = new map<String,set<Id>>(); 
            system.debug('lstSourceProcessNodeObj'+lstSourceProcessNodeObj);
            for(SVMXC__ServiceMax_Processes__c pro : lstSourceProcessNodeObj){
                if(!mapSouceObjectSFMIds.containskey(pro.SVMXC__Source_Object_Name__c))
                    mapSouceObjectSFMIds.put(pro.SVMXC__Source_Object_Name__c,new set<Id>());
                mapSouceObjectSFMIds.get(pro.SVMXC__Source_Object_Name__c).add(pro.SVMXC__Process__c);
                    
            }
            system.debug('mapSouceObjectSFMIds'+mapSouceObjectSFMIds);
            //Query SFM Processes
            setSFMID.clear();
            for(String str : mapSouceObjectSFMIds.keyset()){
                setSFMID.addall(mapSouceObjectSFMIds.get(str));
            }
            system.debug('setSFMID'+setSFMID);
            map<Id,SVMXC__ServiceMax_Processes__c> mapSFMProcess = new map<Id,SVMXC__ServiceMax_Processes__c>();
            try{
                //SDL-SVMX-FLS-NOT-ENFORCED-META-DATA
                mapSFMProcess.putall([Select Id, SVMXC__ProcessID__c, SVMXC__Name__c from SVMXC__ServiceMax_Processes__c where Id IN : setSFMID]);
            }
            catch(QueryException ex){
                response.message = ex.getMessage();
                return response;
            }
            system.debug('mapSFMProcess'+mapSFMProcess);
            //Build Response..
            list<SVMXC.SFM_WrapperDef.SFM_StringSobjectMap> lstStringSobjMap = new list<SVMXC.SFM_WrapperDef.SFM_StringSobjectMap>();
            for(String strObjectName : mapSouceObjectSFMIds.keyset()){
                list<Sobject> lstSFMProcess = new list<Sobject>();
                String strFieldAPIName = '';
                String strFieldlabel = '';
                for(Id SFMId : mapSouceObjectSFMIds.get(strObjectName)){
                    if(mapSFMProcess.containskey(SFMId))
                        lstSFMProcess.add(mapSFMProcess.get(SFMId));
                }
                if(mapObjectNameRefFieldName.containskey(strObjectName)){
                    for(String strFieldName : mapObjectNameRefFieldName.get(strObjectName)){
                        strFieldAPIName = strFieldName;
                        if(mapFieldAPINameFieldLabel.containskey(strFieldAPIName))  
                            strFieldlabel = mapFieldAPINameFieldLabel.get(strFieldAPIName);
                        SVMXC.SFM_WrapperDef.SFM_StringSobjectMap stringSobjMap = new SVMXC.SFM_WrapperDef.SFM_StringSobjectMap(strFieldAPIName,strFieldlabel,lstSFMProcess);
                        lstStringSobjMap.add(stringSobjMap);    
                    }
                }   
            }
            system.debug('lstStringSobjMap: '+lstStringSobjMap);
            response.sobjectMap = lstStringSobjMap;
        }
        return response;
    }
    public List<SFM_WrapperDef2.SFM2_Dependency> getAvailableMultiSourceProcesses_v2(String targetObjName, List<String> processIds){
        
        if(targetObjName != null){
            Map<String, Set<String>> lookupObjectFieldsMap = new Map<String, Set<String>>();

            List<Schema.DescribeSObjectResult> sObjectResults = SFM_DesignerUtils.sobjectsFieldsDescribe(new List<String>{targetObjName});

            if(!sObjectResults.isEmpty()){
                Map<String, Schema.SObjectField> sobjectFields = sObjectResults[0].fields.getMap();
                for(Schema.SObjectField fld : sObjectFields.values()){
                    Schema.DescribeFieldResult fldDescribe = fld.getDescribe();

                    if(fldDescribe.isAccessible()){
                        if(fldDescribe.getType() == Schema.DisplayType.Reference){
                            Set<String> tempValues = new Set<String>();
                            String referenceObj =String.valueOf(fldDescribe.getReferenceTo()[0]);
                            if(lookupObjectFieldsMap.containsKey(referenceObj)){
                                tempValues = lookupObjectFieldsMap.get(referenceObj);
                            }
                            
                            tempValues.add(fldDescribe.getName());
                            lookupObjectFieldsMap.put(referenceObj, tempValues);
                        }
                    }
                }
            }

            String queryStr = 'SELECT Id, SVMXC__Process__c, SVMXC__Process__r.SVMXC__Name__c,  SVMXC__Process__r.SVMXC__Description__c, SVMXC__Source_Object_Name__c, SVMXC__Node_Source_Object_API__c FROM SVMXC__ServiceMax_Processes__c WHERE Recordtype.Name = \'Process Node Objects\'' +
                              + ' AND SVMXC__Type__c = \'TARGET\' AND SVMXC__Source_Object_Name__c =: targetObjName AND SVMXC__Process__r.SVMXC__Purpose__c = \'SOURCE TO TARGET ALL\'';
            
            if(processIds != null){
                queryStr += ' AND SVMXC__Process__c NOT IN : processIds ';
            }

            if(!lookupObjectFieldsMap.keySet().isEmpty()){
                Set<String> sourceObjAPINames = lookupObjectFieldsMap.keySet();
                System.debug(LoggingLevel.DEBUG, 'sourceObjAPINames : ' + sourceObjAPINames);
                queryStr += ' AND SVMXC__Node_Source_Object_API__c IN : sourceObjAPINames';
            }

            System.debug(LoggingLevel.DEBUG, 'queryStr : ' + queryStr);
            if(!COMM_SecurityUtils.getInstance().verifyFieldAccess('SVMXC__ServiceMax_Processes__c', new List<String>{'Id', 'SVMXC__Process__c', 'SVMXC__Name__c', 'SVMXC__Description__c', 'SVMXC__Node_Source_Object_API__c', 'SVMXC__Type__c', 'SVMXC__Purpose__c'}, COMM_SecurityUtils.Access.Accessible)){
                throw new COMM_SecurityUtils.SecurityAccessException( System.Label.COMM001_TAG142 );
            }
            List<SVMXC__ServiceMax_Processes__c> targetProcessNodes = (List<SVMXC__ServiceMax_Processes__c>)Database.query(queryStr);

            Map<String, List<SFM_WrapperDef2.SFM2_EntityDetail>> mutliSourceObjectMap = new Map<String, List<SFM_WrapperDef2.SFM2_EntityDetail>>();

            for(SVMXC__ServiceMax_Processes__c processNodeRecord : targetProcessNodes){
                
                if(processNodeRecord.SVMXC__Node_Source_Object_API__c != null && lookupObjectFieldsMap.containsKey(processNodeRecord.SVMXC__Node_Source_Object_API__c )){ 
                    
                    SFM_WrapperDef2.SFM2_EntityDetail entityDetail = new SFM_WrapperDef2.SFM2_EntityDetail();
                    entityDetail.entityId = processNodeRecord.SVMXC__Process__c;
                    entityDetail.entityName = processNodeRecord.SVMXC__Process__r.SVMXC__Name__c;
                    entityDetail.entityDescription = processNodeRecord.SVMXC__Process__r.SVMXC__Description__c;
                    
                    for(String lkpField : lookupObjectFieldsMap.get(processNodeRecord.SVMXC__Node_Source_Object_API__c)){

                        List<SFM_WrapperDef2.SFM2_EntityDetail> tempList = new List<SFM_WrapperDef2.SFM2_EntityDetail>();
                        
                        if(mutliSourceObjectMap.containsKey(lkpField)){
                            tempList = mutliSourceObjectMap.get(lkpField);

                        }

                        tempList.add(entityDetail);
                        mutliSourceObjectMap.put(lkpField, tempList);
                    }

                }
            }

            if(!mutliSourceObjectMap.isEmpty()){
                List<SFM_WrapperDef2.SFM2_Dependency> multiSourceProcessList = new List<SFM_WrapperDef2.SFM2_Dependency>();
                
                for(String lkpField : mutliSourceObjectMap.keySet()){
                    multiSourceProcessList.add(new SFM_WrapperDef2.SFM2_Dependency(lkpField, null, mutliSourceObjectMap.get(lkpField)));
                }

                return multiSourceProcessList;
            }
        }

        return null;
    }
}