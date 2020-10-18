public with sharing class SFM_ExecuteLookup 
{
    public SVMXC.SFM_WrapperDef.SFM_Response executeLookup(SVMXC.SFM_WrapperDef.SFM_Request request)
    {
        system.debug('request'+request);
        //SVMXC.SVMX_Constant_Utils constantUtils = new SVMXC.SVMX_Constant_Utils();
        SVMXC.SFM_WrapperDef.SFM_Response response = new SVMXC.SFM_WrapperDef.SFM_Response();
        //response.success = true;
        SVMXC.SFM_WrapperDef.SFM_LookupRequest lookupRequest = new SVMXC.SFM_WrapperDef.SFM_LookupRequest();
        Integer intLimit = 0;
        String strLimit = ' Limit ';
        String strObjectName = '';
        String strwhereclause = '';
        String strKeyword = '';
        String strPrefilterCriteria = '';
        String strContext = '';
        String strSearchOperator = '';
        String strSearchclause = '';
        String strQueryString = '';  // INDRESH: Change No 1
        map<Id,Sobject> mapSobject = new map<Id,Sobject>();
        set<Id> uniqueSetIds = new set<Id>();
        list<SVMXC.SFM_WrapperDef.SFM_FieldDefinition> searchFields  = new list<SVMXC.SFM_WrapperDef.SFM_FieldDefinition>();
        lookupRequest = request.lookupRequest;

        system.debug('strContext1 '+lookupRequest.contextMatchField + ' strContext2 ' + lookupRequest.contextValue);
        if(lookupRequest.contextMatchField != null && lookupRequest.contextValue != null)
            strContext += ' '+lookupRequest.contextMatchField+' = \''+ String.escapeSingleQuotes(lookupRequest.contextValue) +'\'';
        else if(lookupRequest.ContextMatchField != null && (lookupRequest.contextValue == '' || lookupRequest.contextValue ==null ))//Modified by Nidhi as part of BAC-4129. Added following condition : lookupRequest.contextValue ==null
            strContext += ' '+lookupRequest.contextMatchField+' = null';
        system.debug('strContext'+strContext);
        if(lookupRequest.keyword != null)
            strKeyword += lookupRequest.keyword;
        if(lookupRequest.operator != null)
            strSearchOperator += lookupRequest.operator;                 
        
        
        if(lookupRequest.lookupDef.objectName != null)
            strObjectName += lookupRequest.lookupDef.objectName;
        
        if(lookupRequest.lookupDef.lookupDefDetail.numberOfRecs != null){
            strLimit += String.valueof(Integer.valueof(lookupRequest.lookupDef.lookupDefDetail.numberOfRecs));
            intLimit = Integer.valueof(lookupRequest.lookupDef.lookupDefDetail.numberOfRecs);
        }else{  
            strLimit += '50';
            intLimit = 50;
        }
        system.debug(lookupRequest.lookupDef.lookupDefDetail.queryColumns + '-------');
        if(lookupRequest.lookupDef.lookupDefDetail.queryColumns != null)
                strQueryString += lookupRequest.lookupDef.lookupDefDetail.queryColumns;
        
        if(lookupRequest.lookupDef.lookupDefDetail.formfillFields != null && lookupRequest.lookupDef.lookupDefDetail.formfillFields.size() > 0){
            list<String> lstFields = new list<String>();
            set<String> setFields = new set<String>();
            lstFields = strQueryString.split(',');
            setFields.addall(lstFields);
            for(Integer i = 0;i<lookupRequest.lookupDef.lookupDefDetail.formfillFields.size();i++){
                //Here "Id" is always present in Lookup Defination (Default behavior) so don't add it again(From Form Fill)
                if(lookupRequest.lookupDef.lookupDefDetail.formfillFields[i].apiName.touppercase() != 'ID' )
                    setFields.add(lookupRequest.lookupDef.lookupDefDetail.formfillFields[i].apiName);   
            }
            strQueryString = '';
            
            system.debug(setFields + '-------');
            if(setFields.size() > 0){
                for(String str : setFields){
                    if(strQueryString != '' && strQueryString.length() > 0)
                        strQueryString += ', '+str;
                    else
                        strQueryString += str;
                }
            }
        }
        
        // INDRESH: Change No 2
        //strQueryString = 'select ' + strQueryString;
        
        /**  For defect : 017739, we will using Left Inner Join to overcome :Too many query rows: 50001 exception.
            With Left Inner Join, we can use only ID or Lookup fields. Therefore, checking if the lookup request has any advance filter criteria or not.
            If it has, then we should use only Id field.
        **/
        if(lookupRequest.lookupDef.advFilters != null && lookupRequest.lookupDef.advFilters.size() > 0){
            strQueryString = 'select Id' ;
        }
        else{
            strQueryString = 'select ' + strQueryString;
        }
        
        if(lookupRequest.lookupDef.lookupDefDetail.preFilterCriteria != null)
                strPrefilterCriteria += lookupRequest.lookupDef.lookupDefDetail.preFilterCriteria;  
        //Replace Constants if any
        //strPrefilterCriteria = constantUtils.replaceConstants(strPrefilterCriteria);          
            
        //Build Search string.
        
        if(lookupRequest.lookupDef.lookupDefDetail.searchFields != null  && strKeyword != null){
            searchFields = lookupRequest.lookupDef.lookupDefDetail.searchFields;
            system.debug('searchFields'+searchFields);
            Integer i = 0,l=searchFields.size();
            String strFieldAPIName = '';
            for(i=0;i<l;i++){
                 if(searchFields[i].apiName.toupperCase() != 'ID'){
                    strFieldAPIName = '';
                    if(searchFields[i].dataType != null && searchFields[i].dataType.equalsIgnoreCase('reference')){
                        strFieldAPIName = searchFields[i].fieldRelationshipName +'.'+searchFields[i].refObjectNameField;
                    }else{
                        strFieldAPIName = searchFields[i].apiName;
                    }
                    if(strSearchclause.length() > 0)
                            strSearchclause += ' OR ';
                    if(strSearchOperator != null && strSearchOperator.length() > 0 && strSearchOperator == 'eq')
                       strSearchclause += strFieldAPIName+' = \''+string.escapeSingleQuotes(strKeyword)+'\'';
                    else if(strSearchOperator != null && strSearchOperator.length() > 0 && strSearchOperator == 'contains')
                       strSearchclause += strFieldAPIName+' like \'%'+string.escapeSingleQuotes(strKeyword)+'%\'';
                    else if(strSearchOperator != null && strSearchOperator.length() > 0 && strSearchOperator == 'sw' )
                        strSearchclause += strFieldAPIName+' like \''+string.escapeSingleQuotes(strKeyword)+'%\'';
                    else if(strSearchOperator != null && strSearchOperator.length() > 0 && strSearchOperator == 'ew' )
                       strSearchclause += strFieldAPIName+' like \'%'+string.escapeSingleQuotes(strKeyword)+'\'';
                }           
            }
        }
        system.debug('strSearchclause'+strSearchclause);
        if(strObjectName != null && strObjectName.length() > 0){
            strQueryString += ' From '+strObjectName+' ';
            system.debug('strQueryString'+strQueryString);
            if(strPrefilterCriteria != null && strPrefilterCriteria.length() > 0){
                if(strwhereclause != null && strwhereclause.length() > 0)
                    strwhereclause += ' AND ( ' +strPrefilterCriteria+ ' ) ';
                else
                    strwhereclause += ' where ( ' +strPrefilterCriteria+ ' ) '; 
                system.debug('strwhereclause'+strwhereclause);
            }
            if(strSearchclause != null && strSearchclause.length() > 0){
                if(strwhereclause != null && strwhereclause.length() > 0)
                    strwhereclause += ' AND ( ' +strSearchclause+ ' ) ';
                else
                    strwhereclause += ' where ( ' +strSearchclause+ ' ) ';
                system.debug('strwhereclause'+strwhereclause);      
            }
            if(strContext != null && strContext.length() > 0){
                if(strwhereclause != null && strwhereclause.length() > 0)
                    strwhereclause += ' AND ( ' +strContext+ ' ) ';
                else
                    strwhereclause += ' where ( ' +strContext+ ' ) ';   
                system.debug('strwhereclause'+strwhereclause);  
            }
            list<Sobject> lstSobject = new list<Sobject>();     
            String parentObjStrQuery = '';
            
            if(strwhereclause != null && strwhereclause.length() > 0)
                parentObjStrQuery += strQueryString+strwhereclause;
            else 
                parentObjStrQuery += strQueryString;
            //Apply Limit if no advance filter 
            if(lookupRequest.lookupDef.advFilters == null || lookupRequest.lookupDef.advFilters.size() == 0){
                parentObjStrQuery += strLimit;
            }
            
            system.debug('parentObjStrQuery'+parentObjStrQuery);
            /*try{
                mapSobject.putall(database.query(strQuery));
                lstSobject = mapSobject.values();
                setIds.addall(mapSobject.keyset());
                system.debug('lstSobject'+lstSobject.size()+lstSobject);
            }
            catch(Exception ex){
                response.message = ex.getMessage();
                return response;
            }   */    
            system.debug('uniqueSetIds'+uniqueSetIds.size()+uniqueSetIds);
            system.debug(lookupRequest.lookupDef.advFilters);
            
            /**  For defect : 017739, if the lookup request had advance lookup filter; then use the Left Inner join query
             *   else, query the records as is as per default lookup functionality.
             *   Other than Advance lookup filter, all other functionalities of lookup should remain as is.
            **/
            if(lookupRequest.lookupDef.advFilters != null && lookupRequest.lookupDef.advFilters.size() > 0){
                lstSobject.clear();
                    
                for(Integer i = 0;i<lookupRequest.lookupDef.advFilters.size();i++){
                    if(lookupRequest.lookupDef.advFilters[i].lookupField != null && lookupRequest.lookupDef.advFilters[i].filterObject != null){
                        /**  For defect : 017739, Using Left Inner join; query the records for Advance lookup filter having records in Parent object query
                         *   Ex: Select field1, field2 from X where Id IN (Select parentfield1, parentfield2 from parent where parentfield2 != null)
                        **/
                        String strQuery = 'Select id, '+lookupRequest.lookupDef.advFilters[i].lookupField +' From '+lookupRequest.lookupDef.advFilters[i].filterObject+' where ' + lookupRequest.lookupDef.advFilters[i].lookupField+' IN  ('+ parentObjStrQuery+ ')';
                        system.debug('strQuery'+strQuery);
                        if(lookupRequest.lookupDef.advFilters[i].filterCriteria != null)
                            strQuery += ' AND ( '+lookupRequest.lookupDef.advFilters[i].filterCriteria+' ) ';
                        system.debug('strQuery'+strQuery);
                        list<Sobject> lstSobj = new list<Sobject>();
                        try{
                            lstSobj = database.query(strQuery);
                        }   
                        catch(Exception ex){
                            response.message = ex.getMessage(); 
                            response.success = false; //Added for the story BAC-4426
                            return response;
                        }
                        system.debug('lstSobj'+lstSobj.size()+lstSobj);
                         /**  For defect : 017739, Create a set of unique ids, which if formed by union of 2 query results.
                         **/
                        Set<Id> setId = new Set<Id>();
                        //setIds = new set<Id>();
                            
                            if(lstSobj != null && lstSobj.size() > 0){
                                if(uniqueSetIds != null && uniqueSetIds.size()>0){
                                    system.debug(setId.size() + '---------');
                                    for(Integer j = 0;j<lstSobj.size();j++){
                                        //setIds.add(lstSobj[j].get(lookupRequest.lookupDef.advFilters[i].lookupField));
                                        String lookupFieldId = String.valueof(lstSobj[j].get(lookupRequest.lookupDef.advFilters[i].lookupField));
                                        if(uniqueSetIds.contains(lookupFieldId)){
                                            setId.add(lookupFieldId);
                                        }
                                    }
                                    
                                    system.debug(setId.size());
                                    if(setId == null || setId.size() == 0){
                                        uniqueSetIds.clear(); 
                                        break;
                                    }
                                }
                                else{
                                    for(Integer j = 0;j<lstSobj.size();j++){
                                        uniqueSetIds.add(String.valueof(lstSobj[j].get(lookupRequest.lookupDef.advFilters[i].lookupField)));
                                    }
                                }
                            }
                            else{
                                uniqueSetIds.clear();
                                break;
                            }
                        
                        
                        /**  For defect : 017739, Once we have got unique ids from 2 queries; put those ids in SetIds to futher find the unique ids.
                         **/
                        if(setId != null && setId.size() >0){
                            uniqueSetIds.clear();
                            uniqueSetIds.addAll(setId);
                            setId.clear();
                        }
                        system.debug('uniqueSetIds:'+lookupRequest.lookupDef.advFilters[i].lookupField+uniqueSetIds.size()+uniqueSetIds);                 
                    }   
                }
                
                /**  For defect : 017739, Once we have found the valid parent Object records, we can query those records and show it in UI.
                **/
                String parentQuery = 'select ' + lookupRequest.lookupDef.lookupDefDetail.queryColumns + ' FROM ' + lookupRequest.lookupDef.objectName + ' WHERE ID IN :uniqueSetIds';
                
                
                try{
                    mapSobject.putall(database.query(parentQuery)); 
                    system.debug(mapSobject);
                }
                catch(Exception ex){
                    response.message = ex.getMessage();
                    response.success = false; //Added for the story BAC-4426
                    return response;
                } 
                
                system.debug('Final: '+uniqueSetIds.size()+uniqueSetIds);
                if(uniqueSetIds.size() > 0){
                    if(uniqueSetIds.size() > intLimit){
                        system.debug('Came here size >0');
                        list<Id> lstIds = new list<Id>();
                        lstIds.addall(uniqueSetIds);  
                        for(Integer i = 0;i<intLimit;i++){
                            if(mapSobject.containskey(lstIds[i]))
                                lstSobject.add(mapSobject.get(lstIds[i]));
                        }
                    }
                    else{
                        system.debug('Came here');
                        for(Id i : uniqueSetIds){
                            if(mapSobject.containskey(i))
                                lstSobject.add(mapSobject.get(i));
                        }       
                    }   
                }
            }
            else{
                try{
                    system.debug('parentObjStrQuery'+parentObjStrQuery);
                    mapSobject.putall(database.query(parentObjStrQuery));
                    lstSobject = mapSobject.values();
                    uniqueSetIds.addall(mapSobject.keyset());
                    system.debug('lstSobject'+lstSobject.size()+lstSobject);
                }
                catch(Exception ex){
                    response.message = ex.getMessage();
                    response.success = false; //Added for the story BAC-4426
                    return response;
                } 
            }
           
            //Applying fix defect 007196 to sort,unresolved values in auto resolve lookup are not sorted in SFM Delivery    
            lstSobject.sort();
            response.records = lstSobject;
        }
        
        system.debug('output:'+response.records.size()+response.records);
        system.debug('response : ' + response);
        return response;
    }

    //Added for the story BAC-4687 to resolve lookup field display values
    public SVMXC.SFM_WrapperDef.SFM_Response resolveLookup(SVMXC.SFM_WrapperDef.SFM_Request request){
        System.debug('Request: '+request);
        SVMXC.SFM_WrapperDef.SFM_Response response = new SVMXC.SFM_WrapperDef.SFM_Response();
        response.success = true;
        
        try{
            if(request != null && request.lstMapStringMap != null && request.lstMapStringMap.size() > 0){

                List<SVMXC.SFM_WrapperDef.SFM_MapStringMap> lstSFM_MapStringMap = request.lstMapStringMap;

                Map<String, Set<String>> mapObjectNameSetOfRecordIds = new Map<String, Set<String>>();
                Map<String, Map<String, String>> mapObjectNameRecIdConfigId = new Map<String, Map<String, String>>();
                Set<String> setConfigIds = new Set<String>();

                for(SVMXC.SFM_WrapperDef.SFM_MapStringMap objSFM_MapStringMap : lstSFM_MapStringMap){
                    String strObjectName = objSFM_MapStringMap.key;

                    if(!mapObjectNameSetOfRecordIds.containsKey(strObjectName)){
                        mapObjectNameSetOfRecordIds.put(strObjectName, new Set<String>());
                    }

                    if(!mapObjectNameRecIdConfigId.containsKey(strObjectName)){
                        mapObjectNameRecIdConfigId.put(strObjectName, new Map<String, String>());
                    }

                    if(objSFM_MapStringMap.valueMap != null && objSFM_MapStringMap.valueMap.size() > 0){

                        for(SVMXC.SFM_WrapperDef.SFM_StringMap objSFM_StringMap : objSFM_MapStringMap.valueMap){
                            String strRecordId = objSFM_StringMap.key;
                            String strLookupConfigId = objSFM_StringMap.value;

                            mapObjectNameSetOfRecordIds.get(strObjectName).add(strRecordId);
                            mapObjectNameRecIdConfigId.get(strObjectName).put(strRecordId, strLookupConfigId);

                            if(!String.isBlank(strLookupConfigId))
                                setConfigIds.add(strLookupConfigId);
                        }
                    }
                }

                //----Get Name field of all the objects
                Map<String, String> mapObjectAndNameField = new Map<String, String>();
                if(mapObjectNameSetOfRecordIds.size() > 0){

                    Schema.DescribeSobjectResult[] descResults = Schema.describeSObjects(new List<String>(mapObjectNameSetOfRecordIds.keyset()));

                    for(Schema.DescribeSobjectResult objDescSobjectRes : descResults){

                        for(Schema.SObjectField objSobjField : objDescSobjectRes.fields.getMap().values()){

                            Schema.DescribeFieldResult objDesFieldRes = objSobjField.getDescribe();

                            if(objDesFieldRes.isNameField()){
                                mapObjectAndNameField.put(objDescSobjectRes.getName(), objDesFieldRes.getName());
                                break;
                            }
                        }
                    }
                }
                //---------

                if(mapObjectNameSetOfRecordIds.size() > 0){

                    Map<String, String> mapConfigIdDisplayField = new Map<String, String>();
                    Map<String, Set<String>> mapObjectNameDisplayFields = new Map<String, Set<String>>();

                    List<SVMXC__ServiceMax_Processes__c> lstLookupConfig = [SELECT Id, SVMXC__Default_Lookup_Column__c, SVMXC__Source_Object_Name__c FROM SVMXC__ServiceMax_Processes__c WHERE Id IN: setConfigIds];

                    for(SVMXC__ServiceMax_Processes__c objConfig : lstLookupConfig){
                        mapConfigIdDisplayField.put(objConfig.Id, objConfig.SVMXC__Default_Lookup_Column__c);

                        if(!mapObjectNameDisplayFields.containsKey(objConfig.SVMXC__Source_Object_Name__c)){
                            mapObjectNameDisplayFields.put(objConfig.SVMXC__Source_Object_Name__c, new Set<String>());
                        }
                        mapObjectNameDisplayFields.get(objConfig.SVMXC__Source_Object_Name__c).add(objConfig.SVMXC__Default_Lookup_Column__c);
                    }

                    //add the name field in the map mapObjectNameDisplayFields
                    for(String strObj : mapObjectAndNameField.keyset()){
                        if(mapObjectNameDisplayFields.containskey(strObj)){
                            mapObjectNameDisplayFields.get(strObj).add(mapObjectAndNameField.get(strObj));
                        }
                        else{
                            mapObjectNameDisplayFields.put(strObj, new Set<String>{mapObjectAndNameField.get(strObj)});
                        }
                    }

                    List<SVMXC.SFM_WrapperDef.SFM_MapStringMap> lstFinalResult = new List<SVMXC.SFM_WrapperDef.SFM_MapStringMap>();
                    for(String strObjName : mapObjectNameSetOfRecordIds.keyset()){

                        Set<String> setIds = mapObjectNameSetOfRecordIds.get(strObjName);

                        if(setIds != null && setIds.size() > 0 && mapObjectNameDisplayFields.size() > 0 && mapObjectNameDisplayFields.containsKey(strObjName)){

                            Set<String> setOfFields = mapObjectNameDisplayFields.get(strObjName);
                            if(setOfFields.contains(null)){
                                setOfFields.remove(null);
                            }

                            String strFieldsToQuery = String.join(new List<String>(setOfFields), ',');
                            System.debug('strFieldsToQuery: '+strFieldsToQuery);

                            String strQuery = 'SELECT ' +strFieldsToQuery+ ' FROM ' +strObjName+ ' WHERE Id IN: setIds';
                            System.debug('strQuery: '+strQuery);

                            List<Sobject> lstRecords = Database.query(strQuery);
                            System.debug('lstRecords: '+lstRecords);

                            SVMXC.SFM_WrapperDef.SFM_MapStringMap objResultObjectRec = new SVMXC.SFM_WrapperDef.SFM_MapStringMap();
                            objResultObjectRec.key = strObjName;

                            List<SVMXC.SFM_WrapperDef.SFM_StringMap> lstResultSFM_StringMap = new List<SVMXC.SFM_WrapperDef.SFM_StringMap>();
                            Map<String, String> mapRecIdConfigId = mapObjectNameRecIdConfigId.get(strObjName);
                            
                            for(Sobject sobj : lstRecords){
                                SVMXC.SFM_WrapperDef.SFM_StringMap objResRecIdDisplayValue = new SVMXC.SFM_WrapperDef.SFM_StringMap();
                                
                                String strRecId = (String)sobj.get('Id');
                                objResRecIdDisplayValue.key = strRecId;
                                objResRecIdDisplayValue.value = String.valueOf(sobj.get(mapObjectAndNameField.get(strObjName)));

                                if(mapRecIdConfigId.size() > 0 && mapRecIdConfigId.containsKey(strRecId)){

                                    if(mapConfigIdDisplayField.size() > 0 && mapConfigIdDisplayField.containsKey(mapRecIdConfigId.get(strRecId))){

                                        String strValue = String.valueOf(sobj.get(mapConfigIdDisplayField.get(mapRecIdConfigId.get(strRecId))));

                                        if(!String.isBlank(strValue)){
                                            objResRecIdDisplayValue.value = strValue;
                                        }
                                    }
                                }
                                lstResultSFM_StringMap.add(objResRecIdDisplayValue);
                            }

                            objResultObjectRec.valueMap = lstResultSFM_StringMap;
                            lstFinalResult.add(objResultObjectRec);
                        }
                    }
                    response.MapStringMap = lstFinalResult;
                }
            }
            else{
                response.success = false;
                response.message = 'Invalid Request';
            }
        }
        catch(Exception ex){
            response.success = false;
            response.message = ex.getMessage();
            System.debug(LoggingLevel.WARN, 'Exception in resolveLookup method: ' + ex.getMessage());
            System.debug(LoggingLevel.WARN, 'StackTrace in resolveLookup method: ' + ex.getStackTraceString());
        }

        System.debug('Respone in resolveLookup: '+response);
        return response;
    }
}