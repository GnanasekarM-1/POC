/* Security Scanned */
public with sharing class SFM_SaveNamedSearch 
{
    Static Map<String, Schema.DescribeFieldResult> objectFieldDescribeMap;
    public SFM_saveNamedSearch(){}
    public SFM_WrapperDef.SFM_Response saveNamedSearch(SFM_WrapperDef.SFM_Request_NamedSearchInfo request)
    {
        Boolean response_success;
        String response_message;
        String response_tagId;
        Boolean isError = false;
        list<SVMXC.SFM_WrapperDef.SVMXMessage> lstMessage = new list<SVMXC.SFM_WrapperDef.SVMXMessage>();
        SFM_Utils utils = new SFM_Utils();
        SFM_WrapperDef.SFM_Response response = new SFM_WrapperDef.SFM_Response();
        List<SFM_WrapperDef.SFM_StringMap> response_stringMap = new List<SFM_WrapperDef.SFM_StringMap>();
        SVMX_Debug log = new SVMX_Debug();
        log.login('SFM_saveNamedSearch', 'saveNamedSearch');
        list<String> resultIds=new list<String>();
        Map<String, Schema.SObjectType> Allobjs = new Map<String, Schema.SObjectType>();
        Map<String, Schema.SObjectField> FieldMap = new Map<String, Schema.SObjectField>();
        list<SVMXC__ServiceMax_Processes__c> namedSearchHdr=new list<SVMXC__ServiceMax_Processes__c>();
        list<SFM_WrapperDef.SFM_NamedSearchInfoDetail> namedSearchDetails=new list<SFM_WrapperDef.SFM_NamedSearchInfoDetail>();
        list<SFM_WrapperDef.SFM_NamedSearchInfoDetail> advNamedSearchDetails = new list<SFM_WrapperDef.SFM_NamedSearchInfoDetail>();
        list<SVMXC__ServiceMax_Processes__c> namedSearchHdr2 = new List<SVMXC__ServiceMax_Processes__c>();
        map<String,SVMXC__ServiceMax_Processes__c> mapNameSearchHdr2 = new map<String,SVMXC__ServiceMax_Processes__c>();
        list<SVMXC__ServiceMax_Config_Data__c> fieldsData= new list<SVMXC__ServiceMax_Config_Data__c>();
        Map<String, Id> searchHeadersId_Map = new Map<String, Id>();
        Map<String, Id> objectRecType_Map = new Map<String, Id>();
        List<String> recTypeNames = new List<String>();
        recTypeNames.add('SVMXC__ServiceMax_Processes__c~Named Search');
        recTypeNames.add('SVMXC__ServiceMax_Config_Data__c~Expressions');
        objectRecType_Map = utils.getRecordTypes(recTypeNames);
        Savepoint sp;
        String nmdsrchId;
        Boolean isDefault=false;
        String srcObjname='';
        list<SVMXC__ServiceMax_Processes__c > LstnamedSearch1 = new list<SVMXC__ServiceMax_Processes__c >();
        List<SVMXC__ServiceMax_Processes__c> uniquecheck = new List<SVMXC__ServiceMax_Processes__c>();
        List<SVMXC__ServiceMax_Processes__c> Defaultcheck = new List<SVMXC__ServiceMax_Processes__c>();
        List<SVMXC__ServiceMax_Processes__c> LtnamedSearch = new List<SVMXC__ServiceMax_Processes__c>();
        String UniqueProcessId;
        list<string> namedsearchId1 = new list<string>();
        list<SVMXC__ServiceMax_Config_Data__c> LstnamedSearchDetails= new list<SVMXC__ServiceMax_Config_Data__c>();
        try
        {
            log.setlog('SAVEPOINT', 'Setting up savepoint before creating');
            sp = Database.setSavepoint();
            system.debug( 'request'+ request.namedSearch);
            system.debug( 'request'+ request);
            for(SFM_WrapperDef.SFM_NamedSearchInfo namedsrchinfo: request.namedSearch)
            {
                if(namedsrchinfo.namedSearchHdr.Id != null)
                {
                    nmdsrchId=namedsrchinfo.namedSearchHdr.Id;
                }   
            }
            //Loop Begins---Loop through the request and get the namedSearchHdr and the namedSearchDetails    
            for(SFM_WrapperDef.SFM_NamedSearchInfo namedsrchinfo: request.namedSearch)
            {
                
                SVMXC__ServiceMax_Processes__c tempObj1 = namedsrchinfo.namedSearchHdr;
                tempObj1.RecordTypeId = objectRecType_Map.get('SVMXC__ServiceMax_Processes__c~Named Search');
                if(tempObj1.SVMXC__ProcessID__c!=null ||tempObj1.SVMXC__ProcessID__c!='')
                {
                  tempObj1.SVMXC__ProcessID__c=tempObj1.SVMXC__ProcessID__c;
                }
                system.debug('Searchtype:'+tempObj1.SVMXC__Rule_Type__c);
                if(tempObj1.SVMXC__Rule_Type__c == 'SRCH_LOOKUP_CONFIG')
                {
                    system.debug('IsDefault:'+tempObj1.SVMXC__IsDefault__C);
                    system.debug('SrcObjectName:'+tempObj1.SVMXC__Source_Object_Name__c);
                    if(tempObj1.SVMXC__IsDefault__C==true && ! tempObj1.SVMXC__IsStandard__c)
                    {   
                        isDefault=true;
                        srcObjname=tempObj1.SVMXC__Source_Object_Name__c;
                    }
                }
                system.debug('IsDefault:'+isDefault);
                UniqueProcessId=tempObj1.SVMXC__ProcessID__c;
                system.debug('UniqueProcessId'+UniqueProcessId);
                system.debug('HeaderId0'+tempObj1.Id);
                namedSearchHdr.add(tempObj1);
                system.debug('NamedSearchHDR'+namedSearchHdr);
                system.debug('NamedSearch1'+namedsrchinfo.namedSearchDetails);
                if(namedsrchinfo.namedSearchDetails != null && namedsrchinfo.namedSearchDetails.size()>0)
                {
                    namedSearchDetails.addAll(namedsrchinfo.namedSearchDetails);
                }
                if(namedsrchinfo.advNamedSearchDetails != null && namedsrchinfo.advNamedSearchDetails.size()>0){
                    advNamedSearchDetails.addAll(namedsrchinfo.advNamedSearchDetails);
                }
            }
            //Loop Ends---Loop through the request and get the namedSearchHdr and the namedSearchDetails
            //Main header search inserted
            log.setlog('INSERT','Insert Main header search');
            system.debug('HeaderId'+namedSearchHdr[0].Id);
            //Begin-Insert main header search and its object deatils and fields data if unique else do not insert send the message
            if(namedSearchHdr.size() > 0)
            {
                if(UniqueProcessId!=null)
                {
                    
                    uniquecheck=[SELECT Id, Name, SVMXC__Name__c, SVMXC__Description__c ,SVMXC__ProcessID__c,SVMXC__Rule_Type__c,SVMXC__IsStandard__c,SVMXC__IsDefault__C,SVMXC__Active__c from SVMXC__ServiceMax_Processes__c where Recordtype.Name='Named Search' AND SVMXC__ProcessID__c = :UniqueProcessId]; //SDL-SVMX-FLS-NOT-ENFORCED-META-DATA
                }
                system.debug('USize'+uniquecheck.size());
                //if matching throw the error else if unique do the upsert
                if(uniquecheck.size()>0)
                {
                    if(uniquecheck[0].Id!=nmdsrchId)
                    {
                        system.debug('Entered false block');
                        response_success = false;
                        //response_message='Named Search cannot be saved as the process is not unique';
                        response_message = system.Label.SFM001_TAG181;
                    }
                    else
                    {
                        system.debug('Entered true block');
                        if(isDefault)
                        {
                            
                            Defaultcheck=[SELECT Id, Name, SVMXC__Name__c, SVMXC__Description__c ,SVMXC__Source_Object_Name__c,SVMXC__ProcessID__c,SVMXC__Rule_Type__c,SVMXC__IsStandard__c,SVMXC__IsDefault__C,SVMXC__Active__c from SVMXC__ServiceMax_Processes__c where Recordtype.Name='Named Search' AND SVMXC__IsDefault__C = true And SVMXC__Source_Object_Name__c = :srcObjname and SVMXC__IsStandard__c = false]; //SDL-SVMX-FLS-NOT-ENFORCED-META-DATA
                        }
                        system.debug('Defaultcheck'+Defaultcheck.size()+Defaultcheck);
                        if(Defaultcheck.size() > 0)
                        {
                            for(SVMXC__ServiceMax_Processes__c p : Defaultcheck)
                            {
                                p.SVMXC__IsDefault__C=false;
                                LtnamedSearch.add(p);
                            }
                            system.debug('LtnamedSearch'+LtnamedSearch);
                            
                            upsert LtnamedSearch; //SDL-SVMX-FLS-NOT-ENFORCED-META-DATA
                        }
                        
                        upsert namedSearchHdr; //SDL-SVMX-FLS-NOT-ENFORCED-META-DATA
                        //Returning the result id's for the saved ones.
                        for(SVMXC__ServiceMax_Processes__c NS: namedSearchHdr)
                        {
                            resultIds.add(NS.Id);
                        }
                        system.debug('Resultids'+resultIds.size());
                        //delete the Search details if the id is existing for the header to avoid duplicacy 
                        if(namedSearchHdr.size() > 0)
                        {
                            
                            LstnamedSearch1 = [SELECT Id, Name, SVMXC__Source_Object_Name__c, SVMXC__Process__c ,SVMXC__Sequence__c from SVMXC__ServiceMax_Processes__c where Recordtype.Name='Named Search' And SVMXC__Module__c IN:resultIds And (SVMXC__Rule_Type__c='SRCH_OBJECT' OR SVMXC__Rule_Type__c='SRCH_CRITERIA')]; //SDL-SVMX-FLS-NOT-ENFORCED-META-DATA
                        }
                        if(LstnamedSearch1.size() > 0)
                        {
                            for(SVMXC__ServiceMax_Processes__c p : LstnamedSearch1)
                            {
                                namedsearchId1.add(p.Id);
                            }
                            
                            LstnamedSearchDetails=[SELECT SVMXC__Sequence__c,SVMXC__Search_Object_Field_Type__c,SVMXC__Field_Name__c, SVMXC__Expression_Rule__c, Name, Id From SVMXC__ServiceMax_Config_Data__c where Recordtype.Name='Expressions' And SVMXC__Expression_Rule__c IN:namedsearchId1 AND (SVMXC__Expression_Type__c = 'SRCH_Object_Fields' OR SVMXC__Expression_Type__c = 'LKUP_Prefilter_Criteria' OR SVMXC__Expression_Type__c = 'LKUP_Criteria')]; //SDL-SVMX-FLS-NOT-ENFORCED-META-DATA
                        }
                        system.debug('LstnamedSearchDetails'+LstnamedSearchDetails.size()+LstnamedSearchDetails);
                        system.debug('LstnamedSearch1'+LstnamedSearch1.size()+LstnamedSearch1);
                        
                        delete LstnamedSearchDetails; //SDL-SVMX-FLS-NOT-ENFORCED-META-DATA
                        
                        delete LstnamedSearch1;  //SDL-SVMX-FLS-NOT-ENFORCED-META-DATA
                        if(namedSearchDetails!= null && namedSearchDetails.size()>0)
                        {
                            map<Integer,list<SVMXC__ServiceMax_Config_Data__c>> mapExpression = new map<Integer,list<SVMXC__ServiceMax_Config_Data__c>>();
                            map<Integer,String> mapParentColumnName = new map<Integer,String>(); 
                            map<Integer,String> mapHeaderID = new map<Integer,String>();
                            map<string,list<SVMXC__ServiceMax_Config_Data__c>> MapNamedExpDetail= new map<string,list<SVMXC__ServiceMax_Config_Data__c>>();
                            Integer i = 0;
                            String uniqueKey = '';
                            for(SFM_WrapperDef.SFM_NamedSearchInfoDetail namedsrchinfo1: namedSearchDetails)
                            {
                                uniqueKey = namedsrchinfo1.uniqueId;
                                SVMXC__ServiceMax_Processes__c tempObj = namedsrchinfo1.objectDetails;
                                tempObj.RecordTypeId = objectRecType_Map.get('SVMXC__ServiceMax_Processes__c~Named Search');
                                tempObj.SVMXC__Rule_Type__c='SRCH_OBJECT';
                                tempObj.SVMXC__Module__c = namedSearchHdr[0].Id;
                                namedSearchHdr2.add(tempObj);
                                system.debug('Stringobjname :'+namedsrchinfo1.objectDetails.SVMXC__Source_Object_Name__c);
                                system.debug('StringVal :'+namedsrchinfo1.fields);
                                if(namedsrchinfo1.objectDetails.SVMXC__Source_Object_Name__c != null && namedsrchinfo1.fields != null)
                                    MapNamedExpDetail.put(namedsrchinfo1.objectDetails.SVMXC__Source_Object_Name__c, namedsrchinfo1.fields);
                                if(namedsrchinfo1.expressionFields != null)
                                {
                                    mapExpression.put(i,namedsrchinfo1.expressionFields);
                                    i++;
                                }     
                            }
                            //Starts For Advance Details
                            //Main header child search inserted
                            log.setlog('INSERT','Main header child search');
                            
                            upsert namedSearchHdr2; //SDL-SVMX-FLS-NOT-ENFORCED-META-DATA
                            system.debug('MapNamedExpDetail :'+MapNamedExpDetail);
                            system.debug('mapExpression :'+mapExpression);
                            i = 0;
                            for(SVMXC__ServiceMax_Processes__c SH:namedSearchHdr2)
                            {
                                searchHeadersId_Map.put(SH.SVMXC__Source_Object_Name__c, SH.Id);
                                mapNameSearchHdr2.put(SH.Id,SH);
                                mapHeaderID.put(i,SH.id);
                                i++;
                            }
                            system.debug('mapNameSearchHdr2 :'+mapNameSearchHdr2);
                            system.debug('mapHeaderID :'+mapHeaderID);
                            //Inserting Fields for the the object.
                            for(String searchName: MapNamedExpDetail.keySet())
                            {   
                                if(searchHeadersId_Map.get(searchName)!=null)
                                {
                                    for(SVMXC__ServiceMax_Config_Data__c fields: MapNamedExpDetail.get(searchName))
                                    {
                                        fields.SVMXC__Expression_Rule__c = searchHeadersId_Map.get(searchName);
                                        fields.RecordTypeId=objectRecType_Map.get('SVMXC__ServiceMax_Config_Data__c~Expressions');
                                        fields.SVMXC__Expression_Type__c='SRCH_Object_Fields';
                                        String ObjectNameAPI='';
                                        //start
                                        if(fields.SVMXC__Display_Type__c.toUpperCase()=='REFERENCE')
                                        {
                                            Allobjs = Schema.getGlobalDescribe();
                                            ObjectNameAPI = utils.getOriginalAPIName(fields.SVMXC__Object_Name__c,Allobjs);
                                            system.debug('ObjectNameAPI'+ObjectNameAPI);
                                            if(Allobjs.containskey(ObjectNameAPI))
                                            {
                                                if(Allobjs.get(ObjectNameAPI) == Account.SObjectType)
                                                    fields.SVMXC__FKey_Name_Field__c ='Name';
                                                else
                                                {
                                                    FieldMap = Allobjs.get(ObjectNameAPI).getDescribe().fields.getMap();
                                                    system.debug('FieldMap'+FieldMap.size());
                                                    system.debug('FieldMap1'+FieldMap.keyset());
                                                    if(FieldMap.size() > 0)
                                                    {
                                                        for(String s :FieldMap.keyset())
                                                        {   
                                                            system.debug('FieldMap2'+s);
                                                            Schema.DescribeFieldResult fieldDesc = FieldMap.get(s).getDescribe();
                                                            //fields.SVMXC__Field_Relationship_Name__c=fieldDesc.getRelationshipName();
                                                            system.debug('FieldMap3'+fieldDesc.isNameField());
                                                            if(fieldDesc.isNameField())
                                                            {
                                                                fields.SVMXC__FKey_Name_Field__c = fieldDesc.getName();
                                                            }
                                                        }
                                                    }
                                                }
                                            }
                                            
                                        }
                                        //end
                                        fieldsData.add(fields);
                                    }
                                }
                            }
                            //Fields inserted
                            log.setlog('INSERT','Fields inserted');
                            system.debug('FieldsData'+fieldsData);
                            
                            upsert fieldsData; //SDL-SVMX-FLS-NOT-ENFORCED-META-DATA
                            list<SVMXC__ServiceMax_Config_Data__c> lstConfigDataFinal = new list<SVMXC__ServiceMax_Config_Data__c>();
                            if(mapExpression.size() > 0)
                            {
                                for(Integer inte : mapExpression.keyset())
                                {
                                    String strHdrId = '';
                                    list<SVMXC__ServiceMax_Config_Data__c> lstConfigData = new list<SVMXC__ServiceMax_Config_Data__c>(); 
                                    SVMXC__ServiceMax_Processes__c ProcessObj = new SVMXC__ServiceMax_Processes__c(); 
                                    if(mapHeaderID.containskey(inte))
                                    {
                                        strHdrId = mapHeaderID.get(inte);
                                        if(strHdrId != null && strHdrId.length() > 0 && mapNameSearchHdr2.containskey(strHdrID))
                                        {
                                            ProcessObj = mapNameSearchHdr2.get(strHdrID);
                                        }
                                        lstConfigData = mapExpression.get(inte);
                                    }
                                    if(lstConfigData.size() > 0 && ProcessObj != null && ProcessObj.SVMXC__Source_Object_Name__c != null)
                                    {
                                        SFM_ValidateExpression validExpObj = new SFM_ValidateExpression();
                                        SFM_WrapperDef.SFM_Expression oSFM_Exp = new SFM_WrapperDef.SFM_Expression(ProcessObj,lstConfigData);
                                        List<SFM_WrapperDef.SFM_Expression> LstSFM_Exp = new List<SFM_WrapperDef.SFM_Expression>();
                                        LstSFM_Exp.add(oSFM_Exp);
                                        SFM_WrapperDef.SFM_Request_Expression oRequest = new SFM_WrapperDef.SFM_Request_Expression(LstSFM_Exp);
                                        SFM_WrapperDef.SFM_Response Save_Response = validExpObj.SFM_validateExpression(oRequest);
                                        system.debug('Validation Response:'+Save_Response);
                                        if(Save_Response.success != null && Boolean.valueOf(Save_Response.success))
                                        {
                                            for(SVMXC__ServiceMax_Config_Data__c cd:lstConfigData)
                                            {
                                                cd.SVMXC__Expression_Rule__c = strHdrID;
                                                cd.RecordTypeId=objectRecType_Map.get('SVMXC__ServiceMax_Config_Data__c~Expressions');
                                                cd.SVMXC__Expression_Type__c='LKUP_Prefilter_Criteria';
                                                if(mapNameSearchHdr2.containskey(strHdrID))
                                                    mapNameSearchHdr2.get(strHdrID).SVMXC__Parent_Object_Criteria__c = Save_Response.message;
                                                lstConfigDataFinal.add(cd); 
                                            }
                                        }
                                        else
                                        {
                                            SVMXC.SFM_WrapperDef.SVMXMessage message = new SVMXC.SFM_WrapperDef.SVMXMessage(Save_Response.message,Save_Response.message,uniqueKey);
                                            lstMessage.add(message);
                                            isError = true;
                                        }   
                                    }       
                                }
                            }
                            if(lstConfigDataFinal.size() > 0)
                            {
                                system.debug('lstConfigDataFinal: '+lstConfigDataFinal);
                                
                                upsert lstConfigDataFinal; //SDL-SVMX-FLS-NOT-ENFORCED-META-DATA
                                
                                upsert mapNameSearchHdr2.values(); //SDL-SVMX-FLS-NOT-ENFORCED-META-DATA
                            }
                        }
                        system.debug('advNamedSearchDetails'+advNamedSearchDetails);
                        if(advNamedSearchDetails!= null && advNamedSearchDetails.size()>0)
                        {
                            map<String,list<SVMXC__ServiceMax_Config_Data__c>> mapExpression = new map<String,list<SVMXC__ServiceMax_Config_Data__c>>();
                            map<String,SVMXC__ServiceMax_Processes__c> mapUiqueKeyHeaderObject = new map<String,SVMXC__ServiceMax_Processes__c>();
                            for(SFM_WrapperDef.SFM_NamedSearchInfoDetail namedsrchinfo1: advNamedSearchDetails)
                            {
                                SVMXC__ServiceMax_Processes__c tempObj = namedsrchinfo1.objectDetails;
                                tempObj.RecordTypeId = objectRecType_Map.get('SVMXC__ServiceMax_Processes__c~Named Search');
                                tempObj.SVMXC__Rule_Type__c='SRCH_CRITERIA';
                                tempObj.SVMXC__Module__c = namedSearchHdr[0].Id;
                                mapUiqueKeyHeaderObject.put(namedsrchinfo1.uniqueId,tempObj);
                                system.debug('Stringobjname :'+namedsrchinfo1.objectDetails.SVMXC__Source_Object_Name__c);
                                system.debug('StringVal :'+namedsrchinfo1.fields);
                                if(namedsrchinfo1.expressionFields != null && namedsrchinfo1.uniqueId != null)
                                {
                                    mapExpression.put(namedsrchinfo1.uniqueId,namedsrchinfo1.expressionFields);
                                    
                                }     
                            }
                            //Starts For Advance Details
                            //Main header child search inserted
                            log.setlog('INSERT','Main header child search');
                            //upsert namedSearchHdr2;
                            
                            upsert mapUiqueKeyHeaderObject.values(); //SDL-SVMX-FLS-NOT-ENFORCED-META-DATA
                            system.debug('mapExpression :'+mapExpression);
                            list<SVMXC__ServiceMax_Config_Data__c> lstConfigDataFinal = new list<SVMXC__ServiceMax_Config_Data__c>();
                            if(mapExpression.size() > 0)
                            {
                                for(String uniqueKey : mapExpression.keyset())
                                {
                                    list<SVMXC__ServiceMax_Config_Data__c> lstConfigData = new list<SVMXC__ServiceMax_Config_Data__c>(); 
                                    SVMXC__ServiceMax_Processes__c ProcessObj = new SVMXC__ServiceMax_Processes__c(); 
                                    if(mapUiqueKeyHeaderObject.containskey(uniqueKey))
                                    {
                                        ProcessObj = mapUiqueKeyHeaderObject.get(uniqueKey);
                                        lstConfigData = mapExpression.get(uniqueKey);
                                        if(lstConfigData.size() > 0 && ProcessObj != null && ProcessObj.SVMXC__Source_Object_Name__c != null)
                                        {
                                            SFM_ValidateExpression validExpObj = new SFM_ValidateExpression();
                                            SFM_WrapperDef.SFM_Expression oSFM_Exp = new SFM_WrapperDef.SFM_Expression(ProcessObj,lstConfigData);
                                            List<SFM_WrapperDef.SFM_Expression> LstSFM_Exp = new List<SFM_WrapperDef.SFM_Expression>();
                                            LstSFM_Exp.add(oSFM_Exp);
                                            SFM_WrapperDef.SFM_Request_Expression oRequest = new SFM_WrapperDef.SFM_Request_Expression(LstSFM_Exp);
                                            SFM_WrapperDef.SFM_Response Save_Response = validExpObj.SFM_validateExpression(oRequest);
                                            system.debug('Validation Response:'+Save_Response);
                                            if(Save_Response.success != null && Boolean.valueOf(Save_Response.success))
                                            {
                                                for(SVMXC__ServiceMax_Config_Data__c cd:lstConfigData)
                                                {
                                                    cd.SVMXC__Expression_Rule__c = ProcessObj.id;
                                                    cd.RecordTypeId=objectRecType_Map.get('SVMXC__ServiceMax_Config_Data__c~Expressions');
                                                    cd.SVMXC__Expression_Type__c='LKUP_Criteria';
                                                    if(mapUiqueKeyHeaderObject.containskey(uniqueKey))
                                                        mapUiqueKeyHeaderObject.get(uniqueKey).SVMXC__Parent_Object_Criteria__c = Save_Response.message;
                                                    lstConfigDataFinal.add(cd); 
                                                }
                                            }
                                            else
                                            {
                                                SVMXC.SFM_WrapperDef.SVMXMessage message = new SVMXC.SFM_WrapperDef.SVMXMessage(Save_Response.message,Save_Response.message,uniqueKey);
                                                lstMessage.add(message);
                                                isError = true;
                                            }   
                                        } 
                                    }          
                                }
                            }
                            if(lstConfigDataFinal.size() > 0)
                            {
                                system.debug('lstConfigDataFinal: '+lstConfigDataFinal);
                                
                                upsert lstConfigDataFinal; //SDL-SVMX-FLS-NOT-ENFORCED-META-DATA
                                
                                upsert mapUiqueKeyHeaderObject.values(); //SDL-SVMX-FLS-NOT-ENFORCED-META-DATA
                            }
                        }
                        if(isError){
                            Database.rollback(sp);
                            response.success = false;
                            response.messages = lstMessage;
                            return response;
                        }
                        response_success = true;
                        //response_message='Inserted successfully';
                        //response_message= system.Label.SFM001_TAG182;(Comented due to tag exercises)
                    }
                }
                else
                {
                    system.debug('Entered true block');
                    system.debug('IsDefault1:'+isDefault);
                    if(isDefault)
                    {
                        
                        Defaultcheck=[SELECT Id, Name, SVMXC__Name__c, SVMXC__Description__c ,SVMXC__Source_Object_Name__c,SVMXC__ProcessID__c,SVMXC__Rule_Type__c,SVMXC__IsStandard__c,SVMXC__IsDefault__C,SVMXC__Active__c from SVMXC__ServiceMax_Processes__c where Recordtype.Name='Named Search' AND SVMXC__IsDefault__C = true And SVMXC__Source_Object_Name__c = :srcObjname and SVMXC__IsStandard__c = false]; //SDL-SVMX-FLS-NOT-ENFORCED-META-DATA
                    }
                    system.debug('Defaultcheck'+Defaultcheck);
                    if(Defaultcheck.size() > 0)
                    {
                        for(SVMXC__ServiceMax_Processes__c p : Defaultcheck)
                        {
                            p.SVMXC__IsDefault__C=false;
                            LtnamedSearch.add(p);
                        }
                       system.debug('LtnamedSearch'+LtnamedSearch);
                       
                       upsert LtnamedSearch; //SDL-SVMX-FLS-NOT-ENFORCED-META-DATA
                    }
                    upsert namedSearchHdr; //SDL-SVMX-FLS-NOT-ENFORCED-META-DATA
                    //Returning the result id's for the saved ones.
                    for(SVMXC__ServiceMax_Processes__c NS: namedSearchHdr)
                    {
                        resultIds.add(NS.Id);
                    }
                    system.debug('Resultids'+resultIds.size());
                    system.debug('Resultids1'+resultIds);
                    //delete the Search details if the id is existing for the header to avoid duplicacy 
                    if(namedSearchHdr.size() > 0)
                    {
                        
                        LstnamedSearch1 = [SELECT Id, Name, SVMXC__Source_Object_Name__c, SVMXC__Process__c ,SVMXC__Sequence__c from SVMXC__ServiceMax_Processes__c where Recordtype.Name='Named Search' And SVMXC__Module__c IN:resultIds And (SVMXC__Rule_Type__c='SRCH_OBJECT' OR SVMXC__Rule_Type__c='SRCH_CRITERIA')]; //SDL-SVMX-FLS-NOT-ENFORCED-META-DATA
                    }
                    if(LstnamedSearch1.size() > 0)
                    {
                        for(SVMXC__ServiceMax_Processes__c p : LstnamedSearch1)
                        {
                            namedsearchId1.add(p.Id);
                        }
                        
                        LstnamedSearchDetails=[SELECT SVMXC__Sequence__c,SVMXC__Search_Object_Field_Type__c,SVMXC__Field_Name__c, SVMXC__Expression_Rule__c, Name, Id From SVMXC__ServiceMax_Config_Data__c where Recordtype.Name='Expressions' And SVMXC__Expression_Rule__c IN:namedsearchId1 AND (SVMXC__Expression_Type__c = 'SRCH_Object_Fields' OR SVMXC__Expression_Type__c = 'LKUP_Prefilter_Criteria' OR SVMXC__Expression_Type__c = 'LKUP_Criteria')]; //SDL-SVMX-FLS-NOT-ENFORCED-META-DATA
                    }
                    
                    delete LstnamedSearchDetails; //SDL-SVMX-FLS-NOT-ENFORCED-META-DATA
                    
                    delete LstnamedSearch1;  //SDL-SVMX-FLS-NOT-ENFORCED-META-DATA
                    if(namedSearchDetails!= null && namedSearchDetails.size()>0)
                    {
                        map<Integer,list<SVMXC__ServiceMax_Config_Data__c>> mapExpression = new map<Integer,list<SVMXC__ServiceMax_Config_Data__c>>();
                        map<Integer,String> mapParentColumnName = new map<Integer,String>(); 
                        map<Integer,String> mapHeaderID = new map<Integer,String>();
                        map<string,list<SVMXC__ServiceMax_Config_Data__c>> MapNamedExpDetail= new map<string,list<SVMXC__ServiceMax_Config_Data__c>>();
                        Integer i = 0;
                        String uniqueKey = '';
                        for(SFM_WrapperDef.SFM_NamedSearchInfoDetail namedsrchinfo1: namedSearchDetails)
                        {
                            uniqueKey = namedsrchinfo1.uniqueId;
                            SVMXC__ServiceMax_Processes__c tempObj = namedsrchinfo1.objectDetails;
                            tempObj.RecordTypeId = objectRecType_Map.get('SVMXC__ServiceMax_Processes__c~Named Search');
                            tempObj.SVMXC__Rule_Type__c='SRCH_OBJECT';
                            tempObj.SVMXC__Module__c = namedSearchHdr[0].Id;
                            namedSearchHdr2.add(tempObj);
                            if(namedsrchinfo1.objectDetails.SVMXC__Source_Object_Name__c != null && namedsrchinfo1.fields != null)
                                MapNamedExpDetail.put(namedsrchinfo1.objectDetails.SVMXC__Source_Object_Name__c, namedsrchinfo1.fields);
                            if(namedsrchinfo1.expressionFields != null)  
                            {
                                mapExpression.put(i,namedsrchinfo1.expressionFields);
                                i++;
                            }   
                        }
                        //Main header child search inserted
                        log.setlog('INSERT','Main header child search');
                        
                        upsert namedSearchHdr2; //SDL-SVMX-FLS-NOT-ENFORCED-META-DATA
                        system.debug('mapExpression :'+mapExpression);
                        i = 0;
                        for(SVMXC__ServiceMax_Processes__c SH:namedSearchHdr2)
                        {
                            searchHeadersId_Map.put(SH.SVMXC__Source_Object_Name__c, SH.Id);
                            mapNameSearchHdr2.put(SH.Id,SH);
                            mapHeaderID.put(i,SH.id);
                            i++;
                        }
                        system.debug('mapNameSearchHdr2 :'+mapNameSearchHdr2);
                        system.debug('mapHeaderID :'+mapHeaderID);
                        //Inserting Fields for the the object.
                        for(String searchName: MapNamedExpDetail.keySet())
                        {
                            if(searchHeadersId_Map.get(searchName)!=null)
                            {
                                for(SVMXC__ServiceMax_Config_Data__c fields: MapNamedExpDetail.get(searchName))
                                {
                                    fields.SVMXC__Expression_Rule__c = searchHeadersId_Map.get(searchName);
                                    fields.RecordTypeId=objectRecType_Map.get('SVMXC__ServiceMax_Config_Data__c~Expressions');
                                    fields.SVMXC__Expression_Type__c='SRCH_Object_Fields';
                                    String ObjectNameAPI='';
                                    //start
                                    if(fields.SVMXC__Display_Type__c.toUpperCase()=='REFERENCE')
                                    {
                                        Allobjs = Schema.getGlobalDescribe();
                                        ObjectNameAPI = utils.getOriginalAPIName(fields.SVMXC__Object_Name__c,Allobjs);
                                        system.debug('ObjectNameAPI'+ObjectNameAPI);
                                        if(Allobjs.containskey(ObjectNameAPI))
                                        {
                                        if(Allobjs.get(ObjectNameAPI) == Account.SObjectType)
                                                fields.SVMXC__FKey_Name_Field__c ='Name';
                                            else



                                            {
                                                FieldMap = Allobjs.get(ObjectNameAPI).getDescribe().fields.getMap();
                                                system.debug('FieldMap'+FieldMap.size());
                                                system.debug('FieldMap1'+FieldMap.keyset());
                                                if(FieldMap.size() > 0)
                                                {
                                                    for(String s :FieldMap.keyset())
                                                    {
                                                        system.debug('FieldMap2'+s);
                                                        Schema.DescribeFieldResult fieldDesc = FieldMap.get(s).getDescribe();
                                                        system.debug('FieldMap3'+fieldDesc.isNameField());
                                                        if(fieldDesc.isNameField())
                                                        {
                                                            fields.SVMXC__FKey_Name_Field__c = fieldDesc.getName();
                                                        }
                                                    }
                                                }
                                            }
                                        }
                                    }
                                    //end
                                    fieldsData.add(fields);
                                }
                            }
                        }
                        //Fields inserted
                        log.setlog('INSERT','Fields inserted');
                        system.debug('FieldsData'+fieldsData);
                        
                        upsert fieldsData; //SDL-SVMX-FLS-NOT-ENFORCED-META-DATA
                        list<SVMXC__ServiceMax_Config_Data__c> lstConfigDataFinal = new list<SVMXC__ServiceMax_Config_Data__c>();
                        if(mapExpression.size() > 0)
                        {
                            for(Integer inte : mapExpression.keyset())
                            {
                                String strHdrId = '';
                                list<SVMXC__ServiceMax_Config_Data__c> lstConfigData = new list<SVMXC__ServiceMax_Config_Data__c>(); 
                                SVMXC__ServiceMax_Processes__c ProcessObj = new SVMXC__ServiceMax_Processes__c(); 
                                if(mapHeaderID.containskey(inte))
                                {
                                    strHdrId = mapHeaderID.get(inte);
                                    if(strHdrId != null && strHdrId.length() > 0 && mapNameSearchHdr2.containskey(strHdrID))
                                    {
                                        ProcessObj = mapNameSearchHdr2.get(strHdrID);
                                    }
                                    lstConfigData = mapExpression.get(inte);
                                }
                                system.debug('lstConfigData'+lstConfigData);
                                if(lstConfigData != null && lstConfigData.size() > 0 && ProcessObj != null && ProcessObj.SVMXC__Source_Object_Name__c != null)
                                {
                                    SFM_ValidateExpression validExpObj = new SFM_ValidateExpression();
                                    SFM_WrapperDef.SFM_Expression oSFM_Exp = new SFM_WrapperDef.SFM_Expression(ProcessObj,lstConfigData);
                                    List<SFM_WrapperDef.SFM_Expression> LstSFM_Exp = new List<SFM_WrapperDef.SFM_Expression>();
                                    LstSFM_Exp.add(oSFM_Exp);
                                    SFM_WrapperDef.SFM_Request_Expression oRequest = new SFM_WrapperDef.SFM_Request_Expression(LstSFM_Exp);
                                    SFM_WrapperDef.SFM_Response Save_Response = validExpObj.SFM_validateExpression(oRequest);
                                    system.debug('Validation Response:'+Save_Response);
                                    if(Save_Response.success != null && Boolean.valueOf(Save_Response.success))
                                    {
                                        for(SVMXC__ServiceMax_Config_Data__c cd:lstConfigData)
                                        {
                                            cd.SVMXC__Expression_Rule__c = strHdrID;
                                            cd.RecordTypeId=objectRecType_Map.get('SVMXC__ServiceMax_Config_Data__c~Expressions');
                                            cd.SVMXC__Expression_Type__c='LKUP_Prefilter_Criteria';
                                            if(mapNameSearchHdr2.containskey(strHdrID))
                                                mapNameSearchHdr2.get(strHdrID).SVMXC__Parent_Object_Criteria__c = Save_Response.message;
                                            lstConfigDataFinal.add(cd); 
                                        }
                                    }
                                    else
                                    {
                                        SVMXC.SFM_WrapperDef.SVMXMessage message = new SVMXC.SFM_WrapperDef.SVMXMessage(Save_Response.message,Save_Response.message,uniqueKey);
                                        lstMessage.add(message);
                                        isError = true;
                                    }   
                                }       
                            }
                        }
                        if(lstConfigDataFinal.size() > 0)
                        {
                            system.debug('lstConfigDataFinal: '+lstConfigDataFinal);
                            
                            upsert lstConfigDataFinal; //SDL-SVMX-FLS-NOT-ENFORCED-META-DATA
                            
                            upsert mapNameSearchHdr2.values(); //SDL-SVMX-FLS-NOT-ENFORCED-META-DATA
                        }
                    }
                    if(advNamedSearchDetails!= null && advNamedSearchDetails.size()>0)
                    {
                        map<String,list<SVMXC__ServiceMax_Config_Data__c>> mapExpression = new map<String,list<SVMXC__ServiceMax_Config_Data__c>>();
                        map<String,SVMXC__ServiceMax_Processes__c> mapUiqueKeyHeaderObject = new map<String,SVMXC__ServiceMax_Processes__c>();
                        for(SFM_WrapperDef.SFM_NamedSearchInfoDetail namedsrchinfo1: advNamedSearchDetails)
                        {
                            SVMXC__ServiceMax_Processes__c tempObj = namedsrchinfo1.objectDetails;
                            tempObj.RecordTypeId = objectRecType_Map.get('SVMXC__ServiceMax_Processes__c~Named Search');
                            tempObj.SVMXC__Rule_Type__c='SRCH_CRITERIA';
                            tempObj.SVMXC__Module__c = namedSearchHdr[0].Id;
                            mapUiqueKeyHeaderObject.put(namedsrchinfo1.uniqueId,tempObj);
                            system.debug('Stringobjname :'+namedsrchinfo1.objectDetails.SVMXC__Source_Object_Name__c);
                            system.debug('StringVal :'+namedsrchinfo1.fields);
                            if(namedsrchinfo1.expressionFields != null && namedsrchinfo1.uniqueId != null)
                            {
                                mapExpression.put(namedsrchinfo1.uniqueId,namedsrchinfo1.expressionFields);
                                
                            }     
                        }
                        //Starts For Advance Details
                        //Main header child search inserted
                        log.setlog('INSERT','Main header child search');
                        //upsert namedSearchHdr2;
                        upsert mapUiqueKeyHeaderObject.values(); //SDL-SVMX-FLS-NOT-ENFORCED-META-DATA
                        system.debug('mapExpression :'+mapExpression);
                        list<SVMXC__ServiceMax_Config_Data__c> lstConfigDataFinal = new list<SVMXC__ServiceMax_Config_Data__c>();
                        if(mapExpression.size() > 0)
                        {
                            for(String uniqueKey : mapExpression.keyset())
                            {
                                list<SVMXC__ServiceMax_Config_Data__c> lstConfigData = new list<SVMXC__ServiceMax_Config_Data__c>(); 
                                SVMXC__ServiceMax_Processes__c ProcessObj = new SVMXC__ServiceMax_Processes__c(); 
                                if(mapUiqueKeyHeaderObject.containskey(uniqueKey))
                                {
                                    ProcessObj = mapUiqueKeyHeaderObject.get(uniqueKey);
                                    lstConfigData = mapExpression.get(uniqueKey);
                                    if(lstConfigData.size() > 0 && ProcessObj != null && ProcessObj.SVMXC__Source_Object_Name__c != null)
                                    {
                                        SFM_ValidateExpression validExpObj = new SFM_ValidateExpression();
                                        SFM_WrapperDef.SFM_Expression oSFM_Exp = new SFM_WrapperDef.SFM_Expression(ProcessObj,lstConfigData);
                                        List<SFM_WrapperDef.SFM_Expression> LstSFM_Exp = new List<SFM_WrapperDef.SFM_Expression>();
                                        LstSFM_Exp.add(oSFM_Exp);
                                        SFM_WrapperDef.SFM_Request_Expression oRequest = new SFM_WrapperDef.SFM_Request_Expression(LstSFM_Exp);
                                        SFM_WrapperDef.SFM_Response Save_Response = validExpObj.SFM_validateExpression(oRequest);
                                        system.debug('Validation Response:'+Save_Response);
                                        if(Save_Response.success != null && Boolean.valueOf(Save_Response.success))
                                        {
                                            for(SVMXC__ServiceMax_Config_Data__c cd:lstConfigData)
                                            {
                                                cd.SVMXC__Expression_Rule__c = ProcessObj.id;
                                                cd.RecordTypeId=objectRecType_Map.get('SVMXC__ServiceMax_Config_Data__c~Expressions');
                                                cd.SVMXC__Expression_Type__c='LKUP_Criteria';
                                                if(mapUiqueKeyHeaderObject.containskey(uniqueKey))
                                                    mapUiqueKeyHeaderObject.get(uniqueKey).SVMXC__Parent_Object_Criteria__c = Save_Response.message;
                                                lstConfigDataFinal.add(cd); 
                                            }
                                        }
                                        else
                                        {
                                            SVMXC.SFM_WrapperDef.SVMXMessage message = new SVMXC.SFM_WrapperDef.SVMXMessage(Save_Response.message,Save_Response.message,uniqueKey);
                                            lstMessage.add(message);
                                            isError = true;
                                        }   
                                    } 
                                }          
                            }
                        }
                        if(lstConfigDataFinal.size() > 0)
                        {
                            system.debug('lstConfigDataFinal: '+lstConfigDataFinal);
                            
                            upsert lstConfigDataFinal; //SDL-SVMX-FLS-NOT-ENFORCED-META-DATA
                            
                            upsert mapUiqueKeyHeaderObject.values(); //SDL-SVMX-FLS-NOT-ENFORCED-META-DATA
                        }
                    }
                    if(isError){
                        Database.rollback(sp);
                        response.success = false;
                        response.messages = lstMessage;
                        system.debug('Error occured:'+response);
                        return response;
                    }
                    response_success = true;
                    response_message='Inserted successfully';
                }
                //end of unique check else block
            }
            //End-Insert main header search and its object deatils and fields data if unique else do not insert send the message
        }
        catch (DmlException ex)
        {
            log.setlog('ERROR', ex.getDmlMessage(0));
            log.setlog('ROLLBACK', 'When fails rollback data donot commit');
            Database.rollback(sp);//When fails rollback data donot commit
            response_success = false;
            response_message = ex.getDmlMessage(0);
        }
        catch(exception ex)
        {
            log.setlog('ERROR', ex.getmessage());
            log.setlog('ROLLBACK', 'When fails rollback data donot commit');
            Database.rollback(sp);
            response_success = false;
            response_message = ex.getmessage();
        }
        log.logout();
        log.print();
        response.logMsg = log.getlog();
        response.success = response_success;
        response.message = response_message;
        response.stringMap = response_stringMap;
        response.resultIds = resultIds;     
        return response;
    }

    /**
     * This method is used to save the lookupConfig details for the given 
     * wrapper object of type SFM_WrapperDef2.SFM2_LookupConfig
     * @param lookup config info details to be saved.
     */
    public void saveNamedSearch_v2(SFM_WrapperDef2.SFM2_LookupConfig lookupConfigInfo, COMM_AuditTrail.AuditData auditData){

        if(lookupConfigInfo != null){
            objectFieldDescribeMap = new Map<String,Schema.DescribeFieldResult>();
            Set<Id> filterIds = new Set<Id>();
            Set<Id> expressionIds = new Set<Id>();            
            SVMXC__ServiceMax_Processes__c lookupConfigHeader = new SVMXC__ServiceMax_Processes__c();

            String action = lookupConfigInfo.configDetail.entityId == null ? System.Label.AUDIT001_TAG049 + lookupConfigInfo.configDetail.entityName : System.Label.AUDIT001_TAG050 + lookupConfigInfo.configDetail.entityName;
            String actionType = lookupConfigInfo.configDetail.entityId == null ? System.Label.AUDIT001_TAG009 : System.Label.AUDIT001_TAG010;
            if(lookupConfigInfo.configDetail.entityId != null){
                lookupConfigHeader.Id = lookupConfigInfo.configDetail.entityId;
            }else{
                lookupConfigHeader.SVMXC__ProcessID__c =  SFM_DesignerUtils.generateUniqueId('LKP');           
            }

            lookupConfigHeader.SVMXC__Name__c = lookupConfigInfo.configDetail.entityName;
            lookupConfigHeader.SVMXC__IsStandard__c = lookupConfigInfo.configDetail.isStandard;
            lookupConfigHeader.SVMXC__Description__c = lookupConfigInfo.configDetail.entityDescription;
            lookupConfigHeader.SVMXC__Rule_Type__c = 'SRCH_LOOKUP_CONFIG';
            lookupConfigHeader.RecordTypeId = SFM_DesignerUtils.recordTypeIdMap.get('Named Search');
            lookupConfigHeader.SVMXC__Source_Object_Name__c = lookupConfigInfo.lookupObject;
            lookupConfigHeader.SVMXC__Default_Lookup_Column__c = lookupConfigInfo.defaultColumn;
            lookupConfigHeader.SVMXC__Number_of_Lookup_Records__c = lookupConfigInfo.lkpRecords;
            lookupConfigHeader.SVMXC__IsDefault__c  = lookupConfigInfo.isDefault;

            if(SFM_DesignerUtils.isEntityNameAlreadyUsed(lookupConfigHeader.SVMXC__Name__c , 'LOOKUPCONFIG', lookupConfigHeader.Id)){
                System.debug( System.LoggingLevel.ERROR, 'Duplicate Name already exists');
                throw new SFM_DesignerUtils.ServicemaxNestedException( System.Label.SFM001_TAG685 );
            }

            /*
                CRUD Security Check before executing the DML
            */
            if(!COMM_SecurityUtils.getInstance().verifyFieldAccess(lookupConfigHeader, COMM_SecurityUtils.Access.Upsertable)){
                throw new COMM_SecurityUtils.SecurityAccessException( System.Label.COMM001_TAG142 );
            } 
            
            Savepoint sPoint = Database.setSavepoint();

            try{
                upsert lookupConfigHeader;
                lookupConfigInfo.configDetail.entityId = lookupConfigHeader.Id;
                Map<String, SFM_WrapperDef2.SFM2_Rule> lkpSubModulesMap = new Map<String, SFM_WrapperDef2.SFM2_Rule>();
                List<SVMXC__ServiceMax_Processes__c> lkpSubModulesList = new List<SVMXC__ServiceMax_Processes__c>();

                if(lookupConfigInfo.lookupFilter != null){
                    SFM_WrapperDef2.SFM2_Rule lookupFilter = lookupConfigInfo.lookupFilter;

                    SVMXC__ServiceMax_Processes__c lookupFilterRecord = mapLookupFilterValues('LKP', lookupConfigInfo.lookupFilter, lookupConfigHeader.Id);
                    lkpSubModulesMap.put(lookupFilterRecord.SVMXC__ProcessID__c, lookupConfigInfo.lookupFilter);
                    lkpSubModulesList.add(lookupFilterRecord);

                }

                if(lookupConfigInfo.advancedFilters != null){
                    for(SFM_WrapperDef2.SFM2_Rule filterWrapperRec : lookupConfigInfo.advancedFilters){
                        SVMXC__ServiceMax_Processes__c lookupFilterRecord = mapLookupFilterValues('ADF', filterWrapperRec, lookupConfigHeader.Id);
                        lkpSubModulesMap.put(lookupFilterRecord.SVMXC__ProcessID__c, filterWrapperRec);
                        lkpSubModulesList.add(lookupFilterRecord);   

                    }
                }

                if(!lkpSubModulesList.isEmpty()){

                    /*
                        CRUD Security Check before executing the DML
                    */
                    if(!COMM_SecurityUtils.getInstance().verifyFieldAccess(lkpSubModulesList, COMM_SecurityUtils.Access.Upsertable)){
                        throw new COMM_SecurityUtils.SecurityAccessException( System.Label.COMM001_TAG142 );
                    } 

                    upsert lkpSubModulesList;

                    Map<String, SFM_WrapperDef2.SFM2_RuleExpression> ruleExpressionWrapperMap = new Map<String, SFM_WrapperDef2.SFM2_RuleExpression>();
                    List<SVMXC__ServiceMax_Config_Data__c> configRecordList = new List<SVMXC__ServiceMax_Config_Data__c>();

                    for(SVMXC__ServiceMax_Processes__c subModuleRec : lkpSubModulesList){
                        
                        if(lkpSubModulesMap.containsKey(subModuleRec.SVMXC__ProcessID__c)){
                            SFM_WrapperDef2.SFM2_Rule lookupFilter = lkpSubModulesMap.get(subModuleRec.SVMXC__ProcessID__c);
                            lookupFilter.ruleDetail.entityId = subModuleRec.Id;
                            filterIds.add(subModuleRec.Id);

                            if(lookupFilter.expressionsList != null){
                                
                                for(SFM_WrapperDef2.SFM2_RuleExpression expressionWrapRec : lookupFilter.expressionsList){
                                    SVMXC__ServiceMax_Config_Data__c expressionRec = new SFM_SaveExpression().mapDetailFieldValues(expressionWrapRec, expressionWrapRec.expressionId, subModuleRec.SVMXC__Rule_Type__c);
                                    String objectFieldKey = lookupFilter.sourceObject + expressionWrapRec.sourceField ;
                                    if(objectFieldDescribeMap.containsKey(objectFieldKey)){
                                        Schema.DescribeFieldResult fldDescribe = objectFieldDescribeMap.get(objectFieldKey);
                                        if(expressionWrapRec.sourceField != 'RecordTypeId' || expressionRec.SVMXC__Expression_Type__c == 'SRCH_Object_Fields'){
                                        expressionRec.SVMXC__Display_Type__c = String.valueOf(fldDescribe.getType());
                                        }
                                        if(fldDescribe.getType() == Schema.Displaytype.REFERENCE){
                                            expressionRec.SVMXC__Field_Relationship_Name__c = fldDescribe.getRelationshipName();
                                            String referenceTo = fldDescribe.getName().equalsIgnoreCase('OWNERID')? 'User' : String.valueOf(fldDescribe.getReferenceTo()[0]);
                                            expressionRec.SVMXC__Object_Name__c = referenceTo;
                                            List<Schema.DescribeSObjectResult> sObjectResults = SFM_DesignerUtils.sobjectsFieldsDescribe(new List<String>{referenceTo});
                                            Map<String, Schema.SObjectField> fieldResultMap = sObjectResults[0].fields.getMap();
                                            for(String fld : fieldResultMap.keySet()){
                                                Schema.DescribeFieldResult refFldDescribe = fieldResultMap.get(fld).getDescribe();
                                                if(refFldDescribe.isNameField()){
                                                    expressionRec.SVMXC__FKey_Name_Field__c = refFldDescribe.getName();
                                                    break;
                                    }
                                            }
                                        }
                                    }
                                    expressionRec.SVMXC__Expression_Rule__c = subModuleRec.Id;
                                    configRecordList.add(expressionRec);
                                    ruleExpressionWrapperMap.put(expressionRec.SVMXC__Expression_Rule__c + '' + expressionRec.SVMXC__Search_Object_Field_Type__c + '' +expressionRec.SVMXC__Sequence__c, expressionWrapRec);
                                }
                            }
                        }
                    }


                    if(!configRecordList.isEmpty()){
                        /*
                            CRUD Security Check before executing the DML
                        */
                        if(!COMM_SecurityUtils.getInstance().verifyFieldAccess(configRecordList, COMM_SecurityUtils.Access.Upsertable)){
                            throw new COMM_SecurityUtils.SecurityAccessException( System.Label.COMM001_TAG142 );
                        }

                        upsert configRecordList;

                        for(SVMXC__ServiceMax_Config_Data__c configRec : configRecordList){
                            String mapKey = configRec.SVMXC__Expression_Rule__c +  '' + configRec.SVMXC__Search_Object_Field_Type__c + ''  + configRec.SVMXC__Sequence__c;
                            if(ruleExpressionWrapperMap.containsKey(mapKey)){
                               SFM_WrapperDef2.SFM2_RuleExpression ruleExpression = ruleExpressionWrapperMap.get(mapKey);
                               ruleExpression.expressionId = configRec.Id;
                               expressionIds.add(configRec.Id);
                            }
                        }
                    }
                }
                // Create audit trail for lookup config creation or update.
                COMM_AuditTrail.AuditTrailInfo auditTrailInfo = new COMM_AuditTrail.AuditTrailInfo();

                auditTrailInfo.entityName = System.Label.AUDIT001_TAG007;
                auditTrailInfo.application = System.Label.AUDIT001_TAG007;
                auditTrailInfo.actionType = actionType;
                auditTrailInfo.action = action;
                auditTrailInfo.internalId = lookupConfigHeader.Id;
                COMM_AuditTrail.getInstance().logAudit(auditTrailInfo, auditData);
                deleteRecords(lookupConfigHeader.Id, filterIds, expressionIds);
            
            }catch(DmlException ex){
                Database.rollback( sPoint );
                System.debug( System.LoggingLevel.ERROR, 'Failed to Upsert Lookup Config with error : ' + ex.getStackTraceString());
                throw ex;
            }catch(Exception ex) {
                Database.rollback( sPoint );
                System.debug( System.LoggingLevel.ERROR, 'Exception occurred with error : ' + ex.getStackTraceString());
                throw ex;
            }    
        }
    }

    SVMXC__ServiceMax_Processes__c mapLookupFilterValues(String filterType, SFM_WrapperDef2.SFM2_Rule lookupFilter, Id headerId){
        SVMXC__ServiceMax_Processes__c lookupFilterRecord = new SVMXC__ServiceMax_Processes__c();
        if(lookupFilter.ruleDetail.entityId != null){
            lookupFilterRecord.Id = lookupFilter.ruleDetail.entityId;
            if(lookupFilterRecord.SVMXC__ProcessID__c == null){
                lookupFilterRecord.SVMXC__ProcessID__c = SFM_DesignerUtils.generateUniqueId(filterType);
            }
        }else{
            lookupFilterRecord.SVMXC__ProcessID__c = SFM_DesignerUtils.generateUniqueId(filterType);     
        }
        
        lookupFilterRecord.SVMXC__Name__c = lookupFilter.ruleDetail.entityName;
        lookupFilterRecord.SVMXC__Description__c = lookupFilter.ruleDetail.entityDescription;
        lookupFilterRecord.SVMXC__Rule_Type__c = filterType.equals('LKP')? 'SRCH_OBJECT' : 'SRCH_CRITERIA';
        lookupFilterRecord.RecordTypeId = SFM_DesignerUtils.recordTypeIdMap.get('Named Search');
        lookupFilterRecord.SVMXC__Source_Object_Name__c = lookupFilter.sourceObject;
        lookupFilterRecord.SVMXC__Module__c = headerId;
        lookupFilterRecord.SVMXC__Field_Name__c = lookupFilter.targetNodeId;     
        lookupFilterRecord.SVMXC__Allow_Override__c = lookupFilter.allowOverride;
        lookupFilterRecord.SVMXC__Default_On__c = lookupFilter.defaultOn;          
        lookupFilterRecord.SVMXC__Advance_Expression__c = lookupFilter.advanceExpression;
        lookupFilterRecord.SVMXC__Parent_Object_Criteria__c = getCriteria(lookupFilterRecord.SVMXC__Source_Object_Name__c, lookupFilterRecord.SVMXC__Advance_Expression__c, lookupFilter.expressionsList);
        return lookupFilterRecord;
    }

    void deleteRecords(Id lookupConfigId, Set<Id> filterIds, Set<Id> expressionIds){
        
        /*
            CRUD Security Check before executing the DML
        */
        if(!COMM_SecurityUtils.getInstance().isDeletableObject('SVMXC__ServiceMax_Config_Data__c')){
            throw new COMM_SecurityUtils.SecurityAccessException( System.Label.COMM001_TAG142 );
        }

        if(!COMM_SecurityUtils.getInstance().isDeletableObject('SVMXC__ServiceMax_Processes__c')){
            throw new COMM_SecurityUtils.SecurityAccessException( System.Label.COMM001_TAG142 );
        }        

        List<SVMXC__ServiceMax_Config_Data__c> configDeleteList = [SELECT Id FROM SVMXC__ServiceMax_Config_Data__c WHERE SVMXC__Expression_Rule__r.SVMXC__Module__c =: lookupConfigId AND Id NOT IN: expressionIds ];                
        
        List<SVMXC__ServiceMax_Processes__c> filterDeleteList =  [SELECT Id FROM SVMXC__ServiceMax_Processes__c WHERE SVMXC__Module__c =: lookupConfigId AND Id NOT IN: filterIds];  

        if(!configDeleteList.isEmpty()){
            delete configDeleteList;
        } 

        if(!filterDeleteList.isEmpty()){
            delete filterDeleteList;
        }

    }

    String getCriteria(String ObjectName,String advanceOption, List<SFM_WrapperDef2.SFM2_RuleExpression> expressionWrapperList){
        
        if(expressionWrapperList != null){

            Map<String, Schema.SObjectField> fieldResultMap;
            SFM_ValidateExpression expressionValidator = new SFM_ValidateExpression();
            List<Schema.DescribeSobjectResult> sobjectDescribeResult = SFM_DesignerUtils.sobjectsFieldsDescribe(new List<String>{ObjectName});             
            
            if(sobjectDescribeResult != null && sobjectDescribeResult.size() == 1){
                fieldResultMap = sobjectDescribeResult[0].fields.getMap();
            }

            List<SVMXC__ServiceMax_Config_Data__c> configList = new List<SVMXC__ServiceMax_Config_Data__c>();
            
            for(SFM_WrapperDef2.SFM2_RuleExpression expressionWrapRec : expressionWrapperList){
                    Schema.DescribeFieldResult fldDescribe = fieldResultMap.get(expressionWrapRec.sourceField).getDescribe();
                String objectFieldKey = ObjectName + expressionWrapRec.sourceField;
                objectFieldDescribeMap.put(objectFieldKey, fldDescribe);
                    expressionValidator.FieldApiLable.put(fldDescribe.getName(), fldDescribe.getLabel());
                    expressionValidator.mapFieldDispType.put(fldDescribe.getName(), fldDescribe.getType());  
                        
                    if(fldDescribe.getType() == Schema.Displaytype.REFERENCE ) {
                        expressionValidator.mapFieldApiObjName.put(fldDescribe.getName(),fldDescribe.getReferenceTo()[0]);
                        expressionValidator.mapFieldRelName.put(fldDescribe.getName(),fldDescribe.getRelationshipName());
                    }  
                if(expressionWrapRec.contextType == null){
                    SVMXC__ServiceMax_Config_Data__c expressionRec = new SFM_SaveExpression().mapDetailFieldValues(expressionWrapRec, expressionWrapRec.expressionId, SFM_DesignerUtils.entity_lkpConfig);
                    configList.add(expressionRec);
                }
            }

            return expressionValidator.getCriteria(ObjectName, advanceOption, configList);
            
        }

        return null;

    }
}