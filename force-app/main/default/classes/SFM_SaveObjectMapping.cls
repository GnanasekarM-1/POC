/* Security Scanned */
public with sharing class SFM_SaveObjectMapping {
    
    public SFM_saveObjectMapping(){}
    public SFM_WrapperDef.SFM_Response SFM_saveObjectMapping(SFM_WrapperDef.SFM_Request_ObjectMap ObjReq){
        set<String> setServicemaxConstants = new set<String>{'Today','Tomorrow','Yesterday', 'Now', 'SVMX.USERTRUNK'};
        SFM_Utils utils = new SFM_Utils();
        SVMX_Debug  log = new SVMX_Debug();
        Boolean response_success = true;
        String response_message;
        String response_tagId; 
        String UniqueProcessId;
        String exprId;
        list<String> resultIds=new list<String>();
        list<String> recTypeNames = new list<String>();
        recTypeNames.add('SVMXC__ServiceMax_Processes__c~Object Mapping');
        recTypeNames.add('SVMXC__ServiceMax_Config_Data__c~Field Mapping');
        map<String, Id> objectRecType_Map = new map<String, Id>();
        objectRecType_Map = utils.getRecordTypes(recTypeNames);
        list<SFM_WrapperDef.SFM_StringMap> stringMap = new list<SFM_WrapperDef.SFM_StringMap>();
        list<SFM_WrapperDef.SFM_ObjectMap> LstSFM_ObjMap =ObjReq.objects;
        map<string,list<SVMXC__ServiceMax_Config_Data__c>> MapObjectMapField= new map<string,list<SVMXC__ServiceMax_Config_Data__c>>();
        map<string,SVMXC__ServiceMax_Processes__c> MapObjectMap = new map<string,SVMXC__ServiceMax_Processes__c>();
        list<string> LstObjectMapId = new list<string>();
        list<SVMXC__ServiceMax_Processes__c >  LstObjectMap = new list<SVMXC__ServiceMax_Processes__c >();  
        list<SVMXC__ServiceMax_Config_Data__c> LstField= new list<SVMXC__ServiceMax_Config_Data__c>();
        list<SVMXC__ServiceMax_Config_Data__c> LstObjField= new list<SVMXC__ServiceMax_Config_Data__c>();
        list<SFM_WrapperDef.SFM_ObjectMap> LstSFM_Obj = new list<SFM_WrapperDef.SFM_ObjectMap>();
        log.login('SFM_saveObjectMapping', 'SFM_saveObjectMapping(SFM_WrapperDef.SFM_Request_ObjectMap)');
        Savepoint sp;
        set<String>Ids=new set<String>();
        map<String, Schema.SObjectType> Allobjs = new map<String, Schema.SObjectType>();
        map<String, Schema.SObjectField> FieldMap1 = new map<String, Schema.SObjectField>();
        list<SVMXC__ServiceMax_Processes__c> uniquecheck = new list<SVMXC__ServiceMax_Processes__c>();
        try
        {
            log.setlog('SAVEPOINT', 'Setting up savepoint before upsert');
            sp = Database.setSavepoint();
            system.debug('LstSFM_ObjMap :'+LstSFM_ObjMap);
            
            for(SFM_WrapperDef.SFM_ObjectMap ObjectMap: LstSFM_ObjMap){
                if(ObjectMap.objectMap.Id != null){
                    Ids.add(ObjectMap.objectMap.Id);
                    exprId=ObjectMap.objectMap.Id;
                }
                SVMXC__ServiceMax_Processes__c obj = ObjectMap.objectMap;
                obj.RecordTypeId = objectRecType_Map.get('SVMXC__ServiceMax_Processes__c~Object Mapping');
                obj.SVMXC__MapID__c = obj.SVMXC__MapID__c;
                obj.SVMXC__Active__c = true;
                UniqueProcessId=obj.SVMXC__MapID__c;
                LstObjectMap.add(obj);
            }
            system.debug('exprId :'+exprId);
            system.debug('UniqueProcessId :'+UniqueProcessId);
            if(exprId!=null){
                
                LstObjField=[Select SVMXC__Display_Value__c,   SVMXC__Target_Field_Name__c, SVMXC__Source_Field_Name__c, Name, Id, SVMXC__Preference_2__c, SVMXC__Preference_3__c From SVMXC__ServiceMax_Config_Data__c where SVMXC__MapID__c = :exprId and Recordtype.Name='Field Mapping']; //SDL-SVMX-FLS-NOT-ENFORCED-META-DATA
                if(LstObjField.size()>0)
                    delete LstObjField;
             }
             if(LstObjectMap!=null && LstObjectMap.size()>0)
             {
                
                uniquecheck=[SELECT Id, Name, SVMXC__Name__c, SVMXC__Target_Object_Name__c, SVMXC__Source_Object_Name__c, SVMXC__MapID__c, SVMXC__Description__c from SVMXC__ServiceMax_Processes__c where SVMXC__MapID__c = :UniqueProcessId];  //SDL-SVMX-FLS-NOT-ENFORCED-META-DATA
                if(uniquecheck.size()>0){
                    if(uniquecheck[0].Id!=exprId){
                        response_success = false;
                        response_message=SYSTEM.Label.SFM001_TAG183;
                     }else{
                         
                        upsert LstObjectMap; //SDL-SVMX-FLS-NOT-ENFORCED-META-DATA
                        for(SVMXC__ServiceMax_Processes__c p : LstObjectMap){
                            resultIds.add(p.Id);
                            log.setlog('Result id ',+p.Id);
                        }
                        for(SFM_WrapperDef.SFM_FieldMapping fm: LstSFM_ObjMap[0].fields){
                            SVMXC__ServiceMax_Config_Data__c fieldMap = fm.fieldMapRecord;
                            fieldMap.RecordTypeId = objectRecType_Map.get('SVMXC__ServiceMax_Config_Data__c~Field Mapping');
                            fieldMap.SVMXC__MapID__c  = LstObjectMap[0].Id;
                            fieldMap.SVMXC__Active__c = true;
                            if(fieldMap.SVMXC__Source_Field_Name__c != null || fieldMap.SVMXC__Preference_2__c != null || fieldMap.SVMXC__Preference_3__c != null){
                                fieldMap.SVMXC__Parameter_Type__c = 'Field Value';
                            }
                            else if(fieldMap.SVMXC__Display_Value__c != null){
                                //to save literals in caps
                                String strFinalVal = '';
                                if(fieldMap.SVMXC__Display_Value__c.containsIgnoreCase('SVMX.CURRENTRECORDHEADER'))
                                    strFinalVal = 'SVMX.CURRENTRECORDHEADER'+ ((fieldMap.SVMXC__Display_Value__c.containsIgnoreCase('CURRENTRECORDHEADER.')) ? '.'+fieldMap.SVMXC__Display_Value__c.substringAfterLast('.') : '');
                                else if(fieldMap.SVMXC__Display_Value__c.containsIgnoreCase('SVMX.CURRENTRECORD'))
                                    strFinalVal = 'SVMX.CURRENTRECORD'+ ((fieldMap.SVMXC__Display_Value__c.containsIgnoreCase('CURRENTRECORD.') ? '.'+fieldMap.SVMXC__Display_Value__c.substringAfterLast('.') : ''));
                                else if(fieldMap.SVMXC__Display_Value__c.containsIgnoreCase('SVMX.USERTRUNK'))
                                    strFinalVal = 'SVMX.USERTRUNK';
                                if(strFinalVal != '')
                                    fieldMap.SVMXC__Display_Value__c = strFinalVal;
                                // done literals in caps
                                if(setServicemaxConstants.contains(fieldMap.SVMXC__Display_Value__c))
                                    fieldMap.SVMXC__Parameter_Type__c  = 'Constant';
                                else if(fieldMap.SVMXC__Display_Value__c.contains('SVMX.CURRENTRECORDHEADER.'))
                                    fieldMap.SVMXC__Parameter_Type__c = 'Header Field Value';
                                else if(fieldMap.SVMXC__Display_Value__c.contains('SVMX.CURRENTRECORD.'))
                                    fieldMap.SVMXC__Parameter_Type__c = 'Field Value';  
                                else    
                                    fieldMap.SVMXC__Parameter_Type__c = 'Value';
                            }
                            //If internal value is not null, means Id is there remove the label from SVMXC__Display_Value__c field
                            /*if(fieldMap.SVMXC__Internal_Value__c != NULL)
                                fieldMap.SVMXC__Display_Value__c = '';*/
                            LstField.add(fieldMap);
                        }
                        if(LstField!=null && LstField.size()>0)
                            
                            upsert LstField; //SDL-SVMX-FLS-NOT-ENFORCED-META-DATA
                        response_success = true;
                    }
                }
                else
                {
                    log.setlog('Entered true block', 'Entered true block');
                    system.debug('Entered true block');
                    
                    upsert LstObjectMap; //SDL-SVMX-FLS-NOT-ENFORCED-META-DATA
                    for(SVMXC__ServiceMax_Processes__c p : LstObjectMap){
                        resultIds.add(p.Id);
                        log.setlog('Result id ',+p.Id);
                    }
                    for(SFM_WrapperDef.SFM_FieldMapping fm: LstSFM_ObjMap[0].fields){
                        SVMXC__ServiceMax_Config_Data__c fieldMap = fm.fieldMapRecord;
                        fieldMap.RecordTypeId = objectRecType_Map.get('SVMXC__ServiceMax_Config_Data__c~Field Mapping');
                        fieldMap.SVMXC__MapID__c  = LstObjectMap[0].Id;
                        fieldMap.SVMXC__Active__c = true;
                        if(fieldMap.SVMXC__Source_Field_Name__c != null || fieldMap.SVMXC__Preference_2__c != null || fieldMap.SVMXC__Preference_3__c != null){
                            fieldMap.SVMXC__Parameter_Type__c = 'Field Value';
                        }
                        else if(fieldMap.SVMXC__Display_Value__c != null){
                            //to save literals in caps
                            String strFinalVal = '';
                            if(fieldMap.SVMXC__Display_Value__c.containsIgnoreCase('SVMX.CURRENTRECORDHEADER'))
                                strFinalVal = 'SVMX.CURRENTRECORDHEADER'+ ((fieldMap.SVMXC__Display_Value__c.containsIgnoreCase('CURRENTRECORDHEADER.')) ? '.'+fieldMap.SVMXC__Display_Value__c.substringAfterLast('.') : '');
                            else if(fieldMap.SVMXC__Display_Value__c.containsIgnoreCase('SVMX.CURRENTRECORD'))
                                strFinalVal = 'SVMX.CURRENTRECORD'+ ((fieldMap.SVMXC__Display_Value__c.containsIgnoreCase('CURRENTRECORD.') ? '.'+fieldMap.SVMXC__Display_Value__c.substringAfterLast('.') : ''));
                            else if(fieldMap.SVMXC__Display_Value__c.containsIgnoreCase('SVMX.USERTRUNK'))
                                strFinalVal = 'SVMX.USERTRUNK';
                            if(strFinalVal != '')
                                fieldMap.SVMXC__Display_Value__c = strFinalVal;
                            // done literals in caps
                            if(setServicemaxConstants.contains(fieldMap.SVMXC__Display_Value__c))
                                fieldMap.SVMXC__Parameter_Type__c  = 'Constant';
                            else if(fieldMap.SVMXC__Display_Value__c.contains('SVMX.CURRENTRECORDHEADER.'))
                                fieldMap.SVMXC__Parameter_Type__c = 'Header Field Value';
                            else if(fieldMap.SVMXC__Display_Value__c.contains('SVMX.CURRENTRECORD.'))
                                fieldMap.SVMXC__Parameter_Type__c = 'Field Value';  
                            else    
                                fieldMap.SVMXC__Parameter_Type__c = 'Value';
                         }
                        //If internal value is not null, means Id is there remove the label from SVMXC__Display_Value__c field
                        /*if(fieldMap.SVMXC__Internal_Value__c != NULL)
                            fieldMap.SVMXC__Display_Value__c = '';*/
                        LstField.add(fieldMap);
                    }
                    if(LstField!=null && LstField.size()>0)
                        
                        upsert LstField; //SDL-SVMX-FLS-NOT-ENFORCED-META-DATA
                    response_success = true;
                }
            }
        }
        catch (DmlException ex)
        {
            log.setlog('ERROR', ex.getDmlMessage(0));
            log.setlog('ROLLBACK', 'When fails rollback data donot commit');
            Database.rollback(sp);//When fails rollback data donot commit
            response_success = false;
            response_message = ex.getDmlMessage(0);
            
        }
        catch (Exception ex)
        {
            log.setlog('ERROR', ex.getmessage());
            log.setlog('ROLLBACK', 'When fails rollback data donot commit');
            Database.rollback(sp);//When fails rollback data donot commit
            response_success = false;
            response_message = ex.getmessage();
        }
        log.logout();
        log.print();
        SFM_WrapperDef.SFM_Response oResponse=new SFM_WrapperDef.SFM_Response();
        oResponse.resultIds = resultIds;  
        oResponse.logMsg = log.getlog();
        oResponse.success = response_success;
        oResponse.message = response_message;
        return oResponse;    
    }
}