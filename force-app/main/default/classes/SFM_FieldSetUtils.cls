/*
 *********************************************************************************************************************
 *    ID        Name                   Date            Comment
 **********************************************************************************************************************
 *              Jaysukh patel        26 Dec 2019        replaced Schema.getGlobalDescribe() with
 *                                                      comman describe method getGlobalDescribeCall describe method
 **********************************************************************************************************************
 */
public with sharing class SFM_FieldSetUtils {
    
    public Map<Id, Set<String>> mapFieldMapIdListOfFields = new Map<Id, Set<String>>(); //Added for the defect BAC-3884
    public Map<String,Set<String>> mapObjectNameFieldListSet = new Map<String,Set<String>>(); //Added for defect fix BAC-4032
    public Map<String,Set<String>> mapObjectNameFieldListForFormFill = new Map<String,Set<String>>();
    
    //Class Structure for Field Set and Sorting data stored in database.    
    public list<SVMXC.SFM_WrapperDef.FieldsetDefinition> SFM_getFieldSetDefinition(SVMXC.SFM_WrapperDef.SFM_Request request){
        system.debug(LoggingLevel.WARN,'request'+request);
        list<SVMXC.SFM_WrapperDef.FieldsetDefinition> fieldSetResponse = new list<SVMXC.SFM_WrapperDef.FieldsetDefinition>(); 
        SVMXC.SFM_WrapperDef.SFM_Response response = new SVMXC.SFM_WrapperDef.SFM_Response();
        set<String> setObectAPIName = new set<String>();
        map<String,Schema.SobjectType> mapAllObjDesc = new map<String,Schema.SobjectType>();
        map<String,Schema.SobjectType> mapAllObjAPINameDesc = new map<String,Schema.SobjectType>();
        //mapAllObjDesc = Schema.getGlobalDescribe();
        mapAllObjDesc = COMM_Utils_DescribeCall.getInstance().getGlobalDescribeCall();
        if(mapAllObjDesc.size() > 0){
            for(String str : mapAllObjDesc.keyset()){
                mapAllObjAPINameDesc.put(mapAllObjDesc.get(str).getDescribe().getName(),mapAllObjDesc.get(str));
            }
        }
        system.debug(LoggingLevel.WARN,'mapAllObjAPINameDesc'+mapAllObjAPINameDesc);
        if(request != null && request.stringListMap != null && request.stringListMap.size() > 0){
            Integer i = 0,m=request.stringListMap.size();
            for(i = 0;i < m;i++){
                if(request.stringListMap[i].key.equals('OBJECTAPINAME'))
                    setObectAPIName.addall(request.stringListMap[i].valueList);
            }
        }
        system.debug(LoggingLevel.WARN,'setObectAPIName'+setObectAPIName);
        if(setObectAPIName.size() > 0){
            for(String str : setObectAPIName){
                system.debug(LoggingLevel.WARN,'Entered'+mapAllObjAPINameDesc.containskey(str));
                if(mapAllObjAPINameDesc.containskey(str)){
                    map<String, Schema.FieldSet> mapObjectFieldSet = mapAllObjAPINameDesc.get(str).getDescribe().fieldSets.getMap();
                    list<SVMXC.SFM_WrapperDef.FieldSetInfo> fieldsetInfo = new list<SVMXC.SFM_WrapperDef.FieldSetInfo>();
                    for(String detailFieldSet : mapObjectFieldSet.keyset()){
                        fieldsetInfo.add(new SVMXC.SFM_WrapperDef.FieldSetInfo(mapObjectFieldSet.get(detailFieldSet).getName(),mapObjectFieldSet.get(detailFieldSet).getLabel()));
                    }
                    fieldSetResponse.add(new SVMXC.SFM_WrapperDef.FieldsetDefinition(str,fieldsetInfo));
                }
            }
        }
        system.debug(LoggingLevel.WARN,'fieldSetResponse'+fieldSetResponse);
        return fieldSetResponse;
    }
    //This method will accept Field set Defination and returns set of field of the field set,Page Layout, Mapping.
    public map<String,set<String>> SFM_buildFieldListFromFieldSet(map<String,SVMXC.SFM_WrapperDef.FieldSetWithSorting> mapAliasNameFieldSetWrapper,map<String, Schema.SObjectType> mapAllObjectDescribe){
        system.debug(LoggingLevel.WARN,'mapAliasNameFieldSetWrapper'+mapAliasNameFieldSetWrapper);
        map<String,set<String>> mapFieldSet = new map<String,set<String>>();
        map<String,set<String>> mapObjectNameListOfFieldSet =  new map<String,set<String>>(); 
        set<ID> setMapId = new set<ID>();
        set<ID> setPageId = new set<ID>();
        map<Id,set<String>> mapPageFieldSet = new map<Id,set<String>>();
        map<Id,set<String>> mapFieldMappingFieldSet = new map<Id,set<String>>();
        map<String,set<String>> mapObjectNameFieldSet = new map<String,set<String>>();
        
        Map<String, Set<String>> mapObjectVsFieldName = new Map<String, Set<String>>();
        String strHeaderLiteralValue = 'HEADER_FIELD_VALUE';
        String strCurrentRecord = 'SVMX.CURRENTRECORD.';
        String strCurrentRecordHeader = 'SVMX.CURRENTRECORDHEADER.';
        
        //Loop the input parameter and get Page Id, Map ID  and Field Set Name
        for(String str : mapAliasNameFieldSetWrapper.keyset()){
            if(mapAliasNameFieldSetWrapper.get(str).fieldMapId != null)
                setMapId.add(mapAliasNameFieldSetWrapper.get(str).fieldMapId);
            if(mapAliasNameFieldSetWrapper.get(str).valueMapId != null)
                setMapId.add(mapAliasNameFieldSetWrapper.get(str).valueMapId);
            // #newChangeOptiBGSFM For Background SFM we dont need to perform form fills and page layout relsted fields are not required
            if(!SFM_ParseProcess.isBackgroundExecution && mapAliasNameFieldSetWrapper.get(str).pageLayoutId != null)
                setPageId.add(mapAliasNameFieldSetWrapper.get(str).pageLayoutId);
            
            list<String> lstFieldSet =  mapAliasNameFieldSetWrapper.get(str).lstFieldSetAPIName;
            
            if(lstFieldSet.size() > 0){ //This condition is Added for code optimization BAC-2993
                if(mapObjectNameListOfFieldSet.containskey(mapAliasNameFieldSetWrapper.get(str).strObjectName)){
                    set<String> setFieldSet = mapObjectNameListOfFieldSet.get(mapAliasNameFieldSetWrapper.get(str).strObjectName);
                    setFieldSet.addall(lstFieldSet);
                    mapObjectNameListOfFieldSet.put(mapAliasNameFieldSetWrapper.get(str).strObjectName,setFieldSet);
                }
                else
                {
                    set<String> setFieldSet = new set<String>();
                    setFieldSet.addall(lstFieldSet);
                    mapObjectNameListOfFieldSet.put(mapAliasNameFieldSetWrapper.get(str).strObjectName,setFieldSet);
                }
            }
        }
        system.debug(LoggingLevel.WARN,'setMapId'+setMapId);
        system.debug(LoggingLevel.WARN,'setPageId'+setPageId);
        system.debug(LoggingLevel.WARN,'mapObjectNameListOfFieldSet'+mapObjectNameListOfFieldSet);
        //Get Fields for Page Layout and Mapping.
        list<SVMXC__Page_Layout_Detail__c> lstPageFields = new list<SVMXC__Page_Layout_Detail__c>();
        list<SVMXC__ServiceMax_Config_Data__c> lstMapFields = new list<SVMXC__ServiceMax_Config_Data__c>(); 
        if(setPageId.size() > 0){
            if(Userinfo.isMultiCurrencyOrganization()){
            //SDL-SVMX-FLS-NOT-ENFORCED-META-DATA
                ///Added SVMXC__Field_Mapping__c for the defect fix BAC-3884
                //Added two fields (SVMXC__Page_Layout__r.SVMXC__Object_Name__c, SVMXC__DataType__c) in query for fixing defect BAC-3773
                lstPageFields = [Select Id, SVMXC__Field_Mapping__c, SVMXC__Field_API_Name__c, SVMXC__Page_Layout__c, SVMXC__Page_Layout__r.SVMXC__Object_Name__c, SVMXC__DataType__c from SVMXC__Page_Layout_Detail__c where SVMXC__Page_Layout__c IN : setPageId and SVMXC__Detail_Type__c = 'Field' order by SVMXC__Page_Layout__c];
            }
            else{
            //SDL-SVMX-FLS-NOT-ENFORCED-META-DATA
                ///Added SVMXC__Field_Mapping__c for the defect fix BAC-3884
                //Added two fields (SVMXC__Page_Layout__r.SVMXC__Object_Name__c, SVMXC__DataType__c) in query for fixing defect BAC-3773
                lstPageFields = [Select Id, SVMXC__Field_Mapping__c, SVMXC__Field_API_Name__c, SVMXC__Page_Layout__c, SVMXC__Page_Layout__r.SVMXC__Object_Name__c, SVMXC__DataType__c from SVMXC__Page_Layout_Detail__c where SVMXC__Page_Layout__c IN : setPageId and SVMXC__Detail_Type__c = 'Field' and SVMXC__Field_API_Name__c != 'CurrencyIsoCode' order by SVMXC__Page_Layout__c];
            }   
        }
        system.debug(LoggingLevel.WARN,'lstPageFields'+lstPageFields);
        if(setMapId.size() > 0){
            if(Userinfo.isMultiCurrencyOrganization())
            //SDL-SVMX-FLS-NOT-ENFORCED-META-DATA
                lstMapFields = [Select Id, SVMXC__Target_Field_Name__c, SVMXC__MapID__c, SVMXC__Display_Value__c, SVMXC__Parameter_Type__c, SVMXC__MapID__r.SVMXC__Source_Object_Name__c, SVMXC__MapID__r.SVMXC__Target_Object_Name__c From SVMXC__ServiceMax_Config_Data__c where SVMXC__MapID__c IN : setMapId order by SVMXC__MapID__c];
            else
            //SDL-SVMX-FLS-NOT-ENFORCED-META-DATA
                lstMapFields = [Select Id, SVMXC__Target_Field_Name__c, SVMXC__MapID__c, SVMXC__Display_Value__c, SVMXC__Parameter_Type__c, SVMXC__MapID__r.SVMXC__Source_Object_Name__c, SVMXC__MapID__r.SVMXC__Target_Object_Name__c From SVMXC__ServiceMax_Config_Data__c where SVMXC__MapID__c IN : setMapId and SVMXC__Target_Field_Name__c != 'CurrencyIsoCode' order by SVMXC__MapID__c];   
        }
        system.debug(LoggingLevel.WARN,'lstMapFields'+lstMapFields);
       
        //---Start---Added for the defect fix BAC-3884
       // if(lstPageFields.size() > 0 ){ 
        if(!lstPageFields.isEmpty()  && !SFM_ParseProcess.isBackgroundExecution){ // #newChangeOptiBGSFM, page fields are not required in background SFM
            Set<Id> setFormFillIds = new Set<Id>();
            for(SVMXC__Page_Layout_Detail__c PLD : lstPageFields){
                if(PLD.SVMXC__Field_Mapping__c != null){
                    setFormFillIds.add(PLD.SVMXC__Field_Mapping__c);
                }
            }
            if(setFormFillIds.size() > 0){
            //SDL-SVMX-FLS-NOT-ENFORCED-META-DATA
                List<SVMXC__ServiceMax_Config_Data__c> lstMappingRecords = [SELECT SVMXC__Target_Field_Name__c, SVMXC__MapID__c, SVMXC__MapID__r.SVMXC__Target_Object_Name__c FROM SVMXC__ServiceMax_Config_Data__c WHERE SVMXC__MapID__c IN: setFormFillIds];
                for(SVMXC__ServiceMax_Config_Data__c obj : lstMappingRecords){
                    if(!mapFieldMapIdListOfFields.containsKey(obj.SVMXC__MapID__c)){
                        mapFieldMapIdListOfFields.put(obj.SVMXC__MapID__c, new Set<String>());
                    }
                    mapFieldMapIdListOfFields.get(obj.SVMXC__MapID__c).add(obj.SVMXC__Target_Field_Name__c);
                    
                    if(!mapObjectNameFieldListForFormFill.containsKey(obj.SVMXC__MapID__r.SVMXC__Target_Object_Name__c)){
                        mapObjectNameFieldListForFormFill.put(obj.SVMXC__MapID__r.SVMXC__Target_Object_Name__c, new Set<String>());
                    }
                    mapObjectNameFieldListForFormFill.get(obj.SVMXC__MapID__r.SVMXC__Target_Object_Name__c).add(obj.SVMXC__Target_Field_Name__c);
                }
            }
      //  }  // #newChangeOptiBGSFM, merged 2 ifs into one since condition was same only
        system.debug(LoggingLevel.WARN,'mapFieldMapIdListOfFields '+mapFieldMapIdListOfFields);
        //---End-----Added for the defect fix BAC-3884
        
       // if(lstPageFields.size() > 0 ){ // #newChangeOptiBGSFM, merged 2 ifs into one since condition was same only

            // Map<String,Map<String, Schema.sObjectField>> mapObjectAndFieldMap = new Map<String,Map<String, Schema.sObjectField>>(); #optiChange
            for(SVMXC__Page_Layout_Detail__c PLD : lstPageFields){
                if(mapPageFieldSet.containskey(PLD.SVMXC__Page_Layout__c)){
                    mapPageFieldSet.get(PLD.SVMXC__Page_Layout__c).add(PLD.SVMXC__Field_API_Name__c);
                }
                else{
                    mapPageFieldSet.put(PLD.SVMXC__Page_Layout__c,new set<String>());
                    mapPageFieldSet.get(PLD.SVMXC__Page_Layout__c).add(PLD.SVMXC__Field_API_Name__c);
                }

                //------Start----Added for fixing defect BAC-3773
                String strFieldApiName = PLD.SVMXC__Field_API_Name__c;
                String strObjName = PLD.SVMXC__Page_Layout__r.SVMXC__Object_Name__c;
                System.debug(LoggingLevel.INFO,'strFieldApiName: '+strFieldApiName);
                System.debug(LoggingLevel.INFO,'strObjName: '+strObjName);
                System.debug(LoggingLevel.INFO,'Field DataType: '+PLD.SVMXC__DataType__c);
                if(String.isNotBlank(strObjName) && String.isNotBlank(strFieldApiName) && String.isNotBlank(PLD.SVMXC__DataType__c) && PLD.SVMXC__DataType__c.equalsIgnoreCase('picklist')){
                    System.debug(LoggingLevel.INFO,'Entered in Controlling picklist logic');
                            Map<String, Schema.sObjectField> mapFieldMap = COMM_Utils_DescribeCall.getObjectFieldDetails(strObjName);
                            Schema.sObjectField sObjField = mapFieldMap.get(strFieldApiName);
                            if(sObjField != null ){
                                Schema.sObjectField controllerField = sObjField.getDescribe().getController();
                                if(controllerField != null){
                                    Schema.DescribeFieldResult describeControllingField = controllerField.getDescribe();
                                    if(describeControllingField.isAccessible()){
                                        System.debug(LoggingLevel.INFO,'API Name of Controller Field: '+describeControllingField.getName());
                                        mapPageFieldSet.get(PLD.SVMXC__Page_Layout__c).add(describeControllingField.getName());
                                    }
                                }
                            }
                }
                //------End----Added for fixing defect BAC-3773
                
                //----Start----Added for the defect fix BAC-3884
                if(PLD.SVMXC__Field_Mapping__c != null && mapFieldMapIdListOfFields.size() > 0 && mapFieldMapIdListOfFields.containsKey(PLD.SVMXC__Field_Mapping__c)){
                    mapPageFieldSet.get(PLD.SVMXC__Page_Layout__c).addAll(mapFieldMapIdListOfFields.get(PLD.SVMXC__Field_Mapping__c));
                }
                //----End-----Added for the defect fix BAC-3884
            } 
        }
        system.debug(LoggingLevel.WARN,'mapPageFieldSet'+mapPageFieldSet);
        if(lstMapFields.size() > 0){
            for(SVMXC__ServiceMax_Config_Data__c CD : lstMapFields){
                if(mapFieldMappingFieldSet.containskey(CD.SVMXC__MapID__c)){
                    mapFieldMappingFieldSet.get(CD.SVMXC__MapID__c).add(CD.SVMXC__Target_Field_Name__c);
                }
                else{
                    mapFieldMappingFieldSet.put(CD.SVMXC__MapID__c,new set<String>());
                    mapFieldMappingFieldSet.get(CD.SVMXC__MapID__c).add(CD.SVMXC__Target_Field_Name__c);
                }

                //------Start--------Added for the story BAC-3272
                //Added setting value check for the story BAC-3577 to control the behaviour of BAC-3272
                if(SFMDeliveryServiceImpl.isQueryOptimizerEnabled && CD.SVMXC__Parameter_Type__c != null && CD.SVMXC__Parameter_Type__c.equalsIgnoreCase('Field Value') && CD.SVMXC__Display_Value__c != null && CD.SVMXC__Display_Value__c.contains(strCurrentRecord)){
                    String strFieldAPIName;
                    List<String> lstString = CD.SVMXC__Display_Value__c.split(strCurrentRecord);
                    if(lstString != null && lstString.size() > 1){
                        strFieldAPIName = lstString[1];
                        String strObjName = CD.SVMXC__MapID__r.SVMXC__Target_Object_Name__c;
                        if(!mapObjectVsFieldName.containsKey(strObjName)){
                            mapObjectVsFieldName.put(strObjName, new Set<String>());
                        }
                        mapObjectVsFieldName.get(strObjName).add(strFieldAPIName);
                    }
                }
                //Added setting value check for the story BAC-3577 to control the behaviour of BAC-3272
                if(SFMDeliveryServiceImpl.isQueryOptimizerEnabled && CD.SVMXC__Parameter_Type__c != null && CD.SVMXC__Parameter_Type__c.equalsIgnoreCase('Header Field Value') && CD.SVMXC__Display_Value__c != null && CD.SVMXC__Display_Value__c.contains(strCurrentRecordHeader)){
                    String strFieldAPIName;
                    List<String> lstString = CD.SVMXC__Display_Value__c.split(strCurrentRecordHeader);
                    if(lstString != null && lstString.size() > 1){
                        strFieldAPIName = lstString[1];
                        if(!mapObjectVsFieldName.containsKey(strHeaderLiteralValue)){
                            mapObjectVsFieldName.put(strHeaderLiteralValue, new Set<String>());
                        }
                        mapObjectVsFieldName.get(strHeaderLiteralValue).add(strFieldAPIName);
                    }
                }
                //------End--------Added for the story BAC-3272
            }
            System.debug(LoggingLevel.WARN,'mapObjectVsFieldName: '+mapObjectVsFieldName);
        }
        system.debug(LoggingLevel.WARN,'mapFieldMappingFieldSet'+mapFieldMappingFieldSet);
        //For given Field Set describe field set.
        if(mapObjectNameListOfFieldSet.size() > 0){
            for(String objectName : mapObjectNameListOfFieldSet.keyset()){
               // if(COMM_Utils_DescribeCall.getObjectFieldSets(objectName) != NULL){// #optiChange
                  //  map<String, Schema.FieldSet> mapFieldSetT = mapAllObjectDescribe.get(objectName).getDescribe().fieldSets.getMap(); //optiChange
                    map<String, Schema.FieldSet> mapFieldSetT = COMM_Utils_DescribeCall.getObjectFieldSets(objectName); //optiChange
                    map<String, Schema.FieldSet> mapFieldSetAPINameDesc = new map<String, Schema.FieldSet>();
                    for(String str : mapFieldSetT.keyset()){
                        mapFieldSetAPINameDesc.put(mapFieldSetT.get(str).getName(),mapFieldSetT.get(str));
                    }
                    //system.debug(LoggingLevel.WARN,'mapFieldSetAPINameDesc'+mapFieldSetAPINameDesc);
                    set<String> FieldSetName = mapObjectNameListOfFieldSet.get(objectName);
                    //system.debug(LoggingLevel.WARN,'FieldSetName'+FieldSetName);
                    set<String> setFields = new set<String>();
                    for(String fldset : FieldSetName){
                        if(mapFieldSetAPINameDesc.containskey(fldset)){
                            list<Schema.FieldSetMember> lstFields = mapFieldSetAPINameDesc.get(fldset).getFields(); 
                            //system.debug(LoggingLevel.WARN,'FieldSetName'+FieldSetName);
                            for(Integer i = 0;i<lstFields.size();i++){
                                setFields.add(lstFields[i].getFieldPath());
                            }
                        }
                    }
                    //system.debug(LoggingLevel.WARN,'setFields'+setFields);
                    if(mapObjectNameFieldSet.containskey(objectName)){
                        mapObjectNameFieldSet.get(objectName).addall(setFields);
                    }
                    else{
                        mapObjectNameFieldSet.put(objectName,new set<String>());
                        mapObjectNameFieldSet.get(objectName).addall(setFields);
                    }   
               // }  // #optiChange
            }
            mapObjectNameFieldListSet = mapObjectNameFieldSet; //Added for defect fix BAC-4032
        }
        system.debug(LoggingLevel.WARN,'mapObjectNameFieldSet'+mapObjectNameFieldSet);
        for(String str : mapAliasNameFieldSetWrapper.keyset()){
            set<String> setFields = new set<String>();
            
            //Get Fields of Page Layout.
            if(mapAliasNameFieldSetWrapper.get(str).pageLayoutId != null && mapPageFieldSet.containskey(mapAliasNameFieldSetWrapper.get(str).pageLayoutId))
                setFields.addall(mapPageFieldSet.get(mapAliasNameFieldSetWrapper.get(str).pageLayoutId));
            //Get Fields of Field Mapping.
            if(mapAliasNameFieldSetWrapper.get(str).fieldMapId != null && mapFieldMappingFieldSet.containskey(mapAliasNameFieldSetWrapper.get(str).fieldMapId))
                setFields.addall(mapFieldMappingFieldSet.get(mapAliasNameFieldSetWrapper.get(str).fieldMapId));
            //Get Field of Value Mapping. 
            if(mapAliasNameFieldSetWrapper.get(str).valueMapId != null && mapFieldMappingFieldSet.containskey(mapAliasNameFieldSetWrapper.get(str).valueMapId))
                setFields.addall(mapFieldMappingFieldSet.get(mapAliasNameFieldSetWrapper.get(str).valueMapId));
            //Get Fields of Field Set.
            if(mapAliasNameFieldSetWrapper.get(str).strObjectName != null && mapObjectNameFieldSet.containskey(mapAliasNameFieldSetWrapper.get(str).strObjectName))
                setFields.addall(mapObjectNameFieldSet.get(mapAliasNameFieldSetWrapper.get(str).strObjectName));            
            
            if(mapFieldSet.containskey(mapAliasNameFieldSetWrapper.get(str).strObjectName)){
                mapFieldSet.get(mapAliasNameFieldSetWrapper.get(str).strObjectName).addall(setFields);
            }
            else{
                mapFieldSet.put(mapAliasNameFieldSetWrapper.get(str).strObjectName,new set<String>());
                mapFieldSet.get(mapAliasNameFieldSetWrapper.get(str).strObjectName).addall(setFields);
            }
        }

        //-------Start-------Added for the story BAC-3272
        //Added setting value check for the story BAC-3577 to control the behaviour of BAC-3272
        if(SFMDeliveryServiceImpl.isQueryOptimizerEnabled){
            for(String strObjName: mapObjectVsFieldName.keyset()){
                if(!mapFieldSet.containsKey(strObjName)){
                    mapFieldSet.put(strObjName, new Set<String>());
                }
                mapFieldSet.get(strObjName).addAll(mapObjectVsFieldName.get(strObjName));
            }
        }
        //-------End-------Added for the story BAC-3272

        system.debug(LoggingLevel.WARN,'mapFieldSet'+mapFieldSet);
        return mapFieldSet;
    }
}