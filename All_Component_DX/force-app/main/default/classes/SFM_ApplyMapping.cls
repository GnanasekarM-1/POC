public with sharing class SFM_ApplyMapping 
{
    //SVMXC.COMM_Utils commutils = new SVMXC.COMM_Utils(); 
    SVMXC.COMM_Utils_V2 commutils = new SVMXC.COMM_Utils_V2(); 
    
    private static Map<String, List<RecordType>> targerObjectRecordTypeListMap = new Map<String, List<RecordType>>();
    public List<String> mappedFieldsForHeader = new List<String>(); //Added as part of Story BAC-3257
    
    public SFM_applyMapping(){}
    
    public List<Sobject> getApplyMapping(List<Sobject> SobjList,String mapSFID,String SourceRecId,Boolean DoPopulateOwner,map<String,Schema.SObjectType> Allobj)
    {
         return applyMappingForHeader(SobjList,mapSFID,SourceRecId,DoPopulateOwner,Allobj,null,null);
    }
    public List<Sobject> getApplyMapping1(String mapSFID,map<String,Sobject> SourceRecIdTargetObjMap,Boolean DoPopulateOwner,map<String,Schema.SObjectType> Allobj)
    {
        return getApplyMappingCore(mapSFID,SourceRecIdTargetObjMap,DoPopulateOwner,Allobj).values();
    }
    public map<String,Sobject> getApplyMappingCore(String mapSFID,map<String,Sobject> SourceRecIdTargetObjMap,Boolean DoPopulateOwner,map<String,Schema.SObjectType> Allobj)
    {
        return applyMappingForDetail(mapSFID,SourceRecIdTargetObjMap,DoPopulateOwner,Allobj,null,null,null);
    } 
    public map<String,Sobject> applyMappingForDetail(String mapSFID,map<String,Sobject> SourceRecIdTargetObjMap,Boolean DoPopulateOwner,map<String,Schema.SObjectType> Allobj,String strSourceObjNameParam,String strTargetObjNameParam,list<SVMXC__ServiceMax_Config_Data__c> lstFieldMappingParam)
    {
        return applyMappingForDetail(mapSFID,SourceRecIdTargetObjMap,DoPopulateOwner,Allobj,strSourceObjNameParam,strTargetObjNameParam,lstFieldMappingParam,null);
    } 
    public list<Sobject> applyMappingForHeader(List<Sobject> SobjList,String mapSFID,String SourceRecId,Boolean DoPopulateOwner,map<String,Schema.SObjectType> Allobj,String strSourceObjNameParam,String strTargetObjNameParam)
    {
        return applyMappingForHeader(SobjList,mapSFID,SourceRecId,DoPopulateOwner,Allobj,strSourceObjNameParam,strTargetObjNameParam,null);
    }
    public list<Sobject> applyMappingForHeader(List<Sobject> SobjList,String mapSFID,String SourceRecId,Boolean DoPopulateOwner,map<String,Schema.SObjectType> Allobj,String strSourceObjNameParam,String strTargetObjNameParam,Sobject SourceObjRecordParam)
    {
        system.debug('SourceRecId'+SourceRecId);
        system.debug('SourceObjRecordParam'+SourceObjRecordParam);
        String strSourceObjName = '';
        String strTargetObjName = '';
        //map<String, Schema.SObjectField> mapTargetFieldDesc = new map<String, Schema.SObjectField>();
        Map<String, Schema.DescribeFieldResult> mapFieldNameAndDescResult = new Map<String, Schema.DescribeFieldResult>();
        if(strSourceObjNameParam != null && strTargetObjNameParam != null)
        {
            strSourceObjName = strSourceObjNameParam;
            strTargetObjName = strTargetObjNameParam;
        }
        else if(mapSFID != null)
        {
            SVMXC__ServiceMax_Processes__c MapHeader = new SVMXC__ServiceMax_Processes__c();
            
            //Commented this query and added new one which has only required fields queried for the story BAC-4410
            //MapHeader = [Select SVMXC__Type__c, SVMXC__Target_Record_Type__c, SVMXC__Target_Object_label__c,SVMXC__Target_Object_Name__c, SVMXC__Submodule__c, SVMXC__SubmoduleID__c, SVMXC__Source_Object_Name__c,SVMXC__Settings_Name__c, SVMXC__Setting_Unique_ID__c, SVMXC__SettingID__c, SVMXC__Sequence__c, SVMXC__Select__c,SVMXC__Search_Order__c, SVMXC__Rule_Type__c, SVMXC__Purpose__c, SVMXC__Process__c, SVMXC__ProcessID__c,SVMXC__Parent_Object__c, SVMXC__Parent_Object_Criteria__c, SVMXC__Parent_Error_Msg__c,SVMXC__Parent_Column_Name__c, SVMXC__Page_Layout__c, SVMXC__Node_Source_Object_API__c,SVMXC__Node_Parent_API__c, SVMXC__Node_Parent__c, SVMXC__Name__c, SVMXC__Module__c, SVMXC__ModuleID__c,SVMXC__MapID__c, SVMXC__MTTS_Minutes__c,SVMXC__IsStandard__c, SVMXC__IsStandalone__c, SVMXC__IsPrivate__c, SVMXC__IsDefault__C,SVMXC__Final_Exception_Process__c,SVMXC__End_Date__c, SVMXC__Email_On_Success__c,SVMXC__Email_On_Error__c, SVMXC__Dispatch_Method__c, SVMXC__Description__c,SVMXC__Default_Value__c, SVMXC__Data_Type__c,  SVMXC__Child_Object_Criteria__c,SVMXC__Child_Error_Msg__c,SVMXC__Advance_Expression__c,SVMXC__Active__c, RecordTypeId, OwnerId, Name,LastModifiedDate, LastModifiedById, LastActivityDate, IsDeleted, Id, CreatedDate, CreatedById From SVMXC__ServiceMax_Processes__c  where Id =: mapSFID];
            MapHeader = [Select SVMXC__Target_Object_Name__c, SVMXC__Source_Object_Name__c From SVMXC__ServiceMax_Processes__c  where Id =: mapSFID]; //SDL-SVMX-FLS-NOT-ENFORCED-META-DATA
            strSourceObjName = MapHeader.SVMXC__Source_Object_Name__c;
            strTargetObjName = MapHeader.SVMXC__Target_Object_Name__c;
        }   
        Sobject SourceObjRecord = SourceObjRecordParam; 
        //if(strSourceObjName != null && Allobj.containskey(strSourceObjName) && SourceObjRecordParam == null)    // optiChange
        if(String.isNotBlank(strSourceObjName) && SourceObjRecordParam == null)    
        {
            map<String, Schema.SObjectField> FieldMap = new map<String, Schema.SObjectField>();
            List<String> fieldlist = new List<String>();
            string fields = '';
            //FieldMap = Allobj.get(strSourceObjName).getDescribe().fields.getMap(); #optiChange
            FieldMap = COMM_Utils_DescribeCall.getObjectFieldDetails(strSourceObjName); // #optiChange
            if(FieldMap != NULL && !FieldMap.isEmpty()) // #optiChange
                fieldlist = commutils.SVMX_getFieldList(FieldMap,true);
            if(fieldlist.size() > 0){
                fieldlist = commutils.checkDuplicateFields(fieldlist, strSourceObjName); //Added for the defect 043715
                fields = commutils.SVMX_getFieldNamesFromList(fieldlist);
            }
            system.debug('fields'+fields);  
            if(fields != null && fields.length() > 0 && SourceRecId != null && SourceRecId.length() > 0)
            {
                String Query = 'Select ' + fields + ' from ' + strSourceObjName + ' where id = ' +  '\''+SourceRecId+'\'';
                system.debug('Query'+Query);
                SourceObjRecord = Database.query(Query);
            }
        }
        system.debug('SourceObjRecord'+SourceObjRecord);
        //get the Field mapping records
        //List<SVMXC.SFM_WrapperDef.SFM_FieldMapping> FieldMapWrapper = new List<SVMXC.SFM_WrapperDef.SFM_FieldMapping>(); 
        List<SVMXC__ServiceMax_Config_Data__c> FieldMappingList = new List<SVMXC__ServiceMax_Config_Data__c>(); 
        if(mapSFID != null && mapSFID.length() > 0)
        {
            if(Userinfo.isMultiCurrencyOrganization())
                
                FieldMappingList = [Select SVMXC__Target_Field_Name__c, SVMXC__Source_Field_Name__c, SVMXC__Preference_3__c, SVMXC__Preference_2__c, SVMXC__MapID__c, SVMXC__Internal_Value__c, SVMXC__Display_Value__c, SVMXC__Configuration_Type__c,SVMXC__Active__c, RecordTypeId, Name, Id From SVMXC__ServiceMax_Config_Data__c where SVMXC__MapID__c =: mapSFID]; //SDL-SVMX-FLS-NOT-ENFORCED-META-DATA
            else
                
                FieldMappingList = [Select  SVMXC__Target_Field_Name__c, SVMXC__Source_Field_Name__c, SVMXC__Preference_3__c, SVMXC__Preference_2__c, SVMXC__MapID__c, SVMXC__Internal_Value__c, SVMXC__Display_Value__c, SVMXC__Configuration_Type__c,SVMXC__Active__c, RecordTypeId, Name, Id From SVMXC__ServiceMax_Config_Data__c where SVMXC__MapID__c =: mapSFID and SVMXC__Target_Field_Name__c != 'CurrencyIsoCode'];   //SDL-SVMX-FLS-NOT-ENFORCED-META-DATA
        }   
        system.debug('FieldMappingList'+FieldMappingList.size()+FieldMappingList);
        set<String> TargetFieldsSet = new set<String>(); 
        if(!(FieldMappingList.isEmpty()))
        {
            for(SVMXC__ServiceMax_Config_Data__c configData : FieldMappingList)
            {
                if(configData.SVMXC__Target_Field_Name__c != null)
                    TargetFieldsSet.add(configData.SVMXC__Target_Field_Name__c);
            }
        }
        System.debug('TargetFieldsSet: '+TargetFieldsSet);
        map<String, Schema.SObjectField> LocalFieldMap = new map<String, Schema.SObjectField>();
       // if(strTargetObjName != null && strTargetObjName.length() > 0 && Allobj.containskey(strTargetObjName)) #optiChange
        if(String.isNotBlank(strTargetObjName))
        {
            map<String, Schema.SObjectField> LFieldMap = new map<String, Schema.SObjectField>();
           // LFieldMap = Allobj.get(strTargetObjName).getDescribe().fields.getMap(); #optiChange
            LFieldMap = COMM_Utils_DescribeCall.getObjectFieldDetails(strTargetObjName);
            if(LFieldMap != NULL && !LFieldMap.isEmpty())
            {
                /*for(String s : LFieldMap.keyset())
                {
                    mapTargetFieldDesc.put(LFieldMap.get(s).getDescribe().getName(),LFieldMap.get(s));
                }*/
                Set<String> setFields = LFieldMap.keySet();
                for(String strField: TargetFieldsSet){
                    strField = strField.toLowerCase();
                    if(setFields.contains(strField)){
                        Schema.DescribeFieldResult objDFR = LFieldMap.get(strField).getDescribe();
                        mapFieldNameAndDescResult.put(objDFR.getName(), objDFR);
                    }
                }
                if(LFieldMap.containsKey('ownerid')){
                    Schema.DescribeFieldResult objDFR = LFieldMap.get('ownerid').getDescribe();
                    mapFieldNameAndDescResult.put(objDFR.getName(), objDFR);
                }
            }
        } 
        //System.debug('mapTargetFieldDesc'+mapTargetFieldDesc);
        System.debug('mapFieldNameAndDescResult: '+mapFieldNameAndDescResult);
        if(SobjList.size() > 0 && FieldMappingList.size() > 0)
        {
            List<RecordType> RecordtypeLst = new List<RecordType>();
            if(strTargetObjName != null)
                
                //Commented this query and added new one which has only required fields queried for the story BAC-4410
                //RecordtypeLst = [Select SystemModstamp, SobjectType, NamespacePrefix, Name, LastModifiedDate, LastModifiedById, IsActive, Id, DeveloperName, Description, CreatedDate, CreatedById, BusinessProcessId From RecordType where SobjectType =: strTargetObjName];
                RecordtypeLst = [Select Id, Name From RecordType where SobjectType =: strTargetObjName]; //SDL-SVMX-FLS-NOT-ENFORCED-META-DATA
            system.debug('RecordtypeLst'+RecordtypeLst);
            for(Integer i = 0;i<SobjList.size();i++)
            {
                //if(DoPopulateOwner && TargetFieldsSet.size() > 0 && TargetFieldsSet.contains('OwnerId') == false && mapTargetFieldDesc.containskey('OwnerId'))
                //Commented above line and added below one for checking owner id in Sobject for fixing defect 044816
                if(DoPopulateOwner && TargetFieldsSet.size() > 0 && TargetFieldsSet.contains('OwnerId') == false && mapFieldNameAndDescResult.containskey('OwnerId') && SobjList[i].get('OwnerId') == null)
                {
                    SobjList[i].put('OwnerId',Userinfo.getUserId());
                }
                //check for the value map
                if(strSourceObjName == null)
                {
                    for(Integer j = 0;j<FieldMappingList.size();j++)
                    {
                        if(FieldMappingList[j].SVMXC__Source_Field_Name__c != null && FieldMappingList[j].SVMXC__Display_Value__c != null)
                            SobjList[i].put(FieldMappingList[j].SVMXC__Source_Field_Name__c,FieldMappingList[j].SVMXC__Display_Value__c);
                    }
                }
                //Field Map
                if(strSourceObjName != null)
                {
                    for(Integer j = 0;j<FieldMappingList.size();j++)
                    {
                        if(FieldMappingList[j].SVMXC__Target_Field_Name__c != null && mapFieldNameAndDescResult.containskey(FieldMappingList[j].SVMXC__Target_Field_Name__c))
                        {
                            //Desctibe the field to check differen attributes of fields..
                            Schema.DescribeFieldResult f = mapFieldNameAndDescResult.get(FieldMappingList[j].SVMXC__Target_Field_Name__c);
                            if(FieldMappingList[j].SVMXC__Target_Field_Name__c == 'RecordTypeId' && f.isCreateable())
                            {
                                if(FieldMappingList[j].SVMXC__Display_Value__c != null)
                                {
                                    String RecordTypeId = '';
                                    if(RecordtypeLst.size() > 0)
                                    {
                                        for(RecordType r : RecordtypeLst)
                                        {
                                            if(FieldMappingList[j].SVMXC__Display_Value__c != null && r.Name.touppercase() == FieldMappingList[j].SVMXC__Display_Value__c.touppercase())
                                                RecordTypeId = r.id;
                                        }
                                    } 
                                    if(RecordTypeId != null && RecordTypeId.length() > 0)
                                        SobjList[i].put(FieldMappingList[j].SVMXC__Target_Field_Name__c,RecordTypeId);
                                }
                                else if(FieldMappingList[j].SVMXC__Source_Field_Name__c != null && SourceObjRecord.get(FieldMappingList[j].SVMXC__Source_Field_Name__c) != null)
                                {
                                    SobjList[i].put(FieldMappingList[j].SVMXC__Target_Field_Name__c,SourceObjRecord.get(FieldMappingList[j].SVMXC__Source_Field_Name__c));
                                }      
                            }
                            else if(FieldMappingList[j].SVMXC__Target_Field_Name__c != 'RecordTypeId' && f.isCreateable())
                            {
                                if(FieldMappingList[j].SVMXC__Source_Field_Name__c != null && SourceObjRecord.get(FieldMappingList[j].SVMXC__Source_Field_Name__c) != null)
                                {   
                                    SobjList[i].put(FieldMappingList[j].SVMXC__Target_Field_Name__c,SourceObjRecord.get(FieldMappingList[j].SVMXC__Source_Field_Name__c));
                                }    
                                else if(FieldMappingList[j].SVMXC__Source_Field_Name__c != null && FieldMappingList[j].SVMXC__Preference_2__c != null && SourceObjRecord.get(FieldMappingList[j].SVMXC__Source_Field_Name__c) == null && SourceObjRecord.get(FieldMappingList[j].SVMXC__Preference_2__c) != null)
                                {
                                    SobjList[i].put(FieldMappingList[j].SVMXC__Target_Field_Name__c,SourceObjRecord.get(FieldMappingList[j].SVMXC__Preference_2__c));
                                }    
                                else if(FieldMappingList[j].SVMXC__Source_Field_Name__c != null && SourceObjRecord.get(FieldMappingList[j].SVMXC__Source_Field_Name__c) == null && FieldMappingList[j].SVMXC__Preference_2__c != null && SourceObjRecord.get(FieldMappingList[j].SVMXC__Preference_2__c) == null && FieldMappingList[j].SVMXC__Preference_3__c != null && SourceObjRecord.get(FieldMappingList[j].SVMXC__Preference_3__c) != null)
                                {
                                    SobjList[i].put(FieldMappingList[j].SVMXC__Target_Field_Name__c,SourceObjRecord.get(FieldMappingList[j].SVMXC__Preference_3__c));
                                }    
                                if(FieldMappingList[j].SVMXC__Source_Field_Name__c  == null && FieldMappingList[j].SVMXC__Preference_2__c == null  && FieldMappingList[j].SVMXC__Preference_3__c == null && FieldMappingList[j].SVMXC__Display_Value__c != null && mapFieldNameAndDescResult.containskey(FieldMappingList[j].SVMXC__Target_Field_Name__c))
                                {
                                    system.debug('Entered Here'+FieldMappingList[j].SVMXC__Target_Field_Name__c+FieldMappingList[j].SVMXC__Display_Value__c);
                                    //Check for the Servicemax Constants..
                                    if(FieldMappingList[j].SVMXC__Display_Value__c.contains('SVMX.CURRENTRECORD.')){
                                        list<String> lstString = new list<String>();
                                        lstString = FieldMappingList[j].SVMXC__Display_Value__c.split('SVMX.CURRENTRECORD.');
                                        system.debug('Entered..'+FieldMappingList[j].SVMXC__Target_Field_Name__c+FieldMappingList[j].SVMXC__Display_Value__c+SobjList[i].get(lstString[1]));
                                        if(lstString.size() > 0)
                                            SobjList[i].put(FieldMappingList[j].SVMXC__Target_Field_Name__c,SobjList[i].get(lstString[1]));
                                    }
                                    else if(FieldMappingList[j].SVMXC__Display_Value__c.contains('SVMX.CURRENTRECORDHEADER.')){
                                        //If SVMX.CURRENTRECORDHEADER. found then to skip it put null value.
                                        SobjList[i].put(FieldMappingList[j].SVMXC__Target_Field_Name__c,null);
                                    }
                                    else if(FieldMappingList[j].SVMXC__Display_Value__c.contains('SVMX.CURRENTUSERID')){
                                        SobjList[i].put(FieldMappingList[j].SVMXC__Target_Field_Name__c,userinfo.getUserId());
                                    }
                                    else if(FieldMappingList[j].SVMXC__Display_Value__c.contains('SVMX.USERTRUNK')){
                                        SVMXC.SVMX_Constant_Utils constantUtils = new SVMXC.SVMX_Constant_Utils();
                                        system.debug('Entered..'+FieldMappingList[j].SVMXC__Target_Field_Name__c+constantUtils.getSVMXUserTrunkId());
                                        SobjList[i].put(FieldMappingList[j].SVMXC__Target_Field_Name__c,constantUtils.getSVMXUserTrunkId());
                                    }else if(FieldMappingList[j].SVMXC__Display_Value__c.contains('SVMX.GEOLOCATION.COORDS.LATITUDE') || FieldMappingList[j].SVMXC__Display_Value__c.contains('SVMX.GEOLOCATION.COORDS.LONGITUDE') || FieldMappingList[j].SVMXC__Display_Value__c.contains('SVMX.GEOLOCATION.COORDS.ACCURACY') || FieldMappingList[j].SVMXC__Display_Value__c.contains('SVMX.SETNULL')){ // Added for BAC-4889, BAC-5089
                                        //SobjList[i].put(FieldMappingList[j].SVMXC__Target_Field_Name__c,null);
                                    }
                                    else 
                                    {
                                        if((f.getType() == schema.Displaytype.Double  || f.getType() == schema.Displaytype.Percent || f.getType() == schema.Displaytype.Currency)&& f.isCreateable())//if Field Type is Double,persent,currency 
                                        {
                                            if(double.valueOf(FieldMappingList[j].SVMXC__Display_Value__c) != null )
                                            {
                                                SobjList[i].put(FieldMappingList[j].SVMXC__Target_Field_Name__c,double.valueOf(FieldMappingList[j].SVMXC__Display_Value__c));
                                            }   
                                        }
                                        else if(f.getType() == schema.Displaytype.Integer && f.isCreateable())//if field type is Integer
                                        {
                                            if(Integer.valueof(FieldMappingList[j].SVMXC__Display_Value__c)!= null)
                                            {
                                                SobjList[i].put(FieldMappingList[j].SVMXC__Target_Field_Name__c,Integer.valueof(FieldMappingList[j].SVMXC__Display_Value__c));
                                            }   
                                        }
                                        else if(f.getType() == schema.Displaytype.Boolean && f.isCreateable())//if field type is Boolean
                                        {
                                            if(Boolean.valueof(FieldMappingList[j].SVMXC__Display_Value__c)!= null)
                                            {
                                                SobjList[i].put(FieldMappingList[j].SVMXC__Target_Field_Name__c,Boolean.valueof(FieldMappingList[j].SVMXC__Display_Value__c));
                                            }   
                                        }
                                        else if(f.getType() == schema.Displaytype.DateTime && f.isCreateable())//if field type is DateTime
                                        {
                                           if(FieldMappingList[j].SVMXC__Display_Value__c.touppercase() == 'TODAY')
                                            {
                                                SobjList[i].put(FieldMappingList[j].SVMXC__Target_Field_Name__c,datetime.newInstance(system.today(), time.newInstance(0, 0, 0, 0)));
                                            }   
                                            else if(FieldMappingList[j].SVMXC__Display_Value__c.touppercase() == 'YESTERDAY')
                                            {
                                                SobjList[i].put(FieldMappingList[j].SVMXC__Target_Field_Name__c,datetime.newInstance(system.today()-1, time.newInstance(0, 0, 0, 0)));
                                            }       
                                            else if(FieldMappingList[j].SVMXC__Display_Value__c.touppercase() == 'TOMORROW')
                                            {
                                                SobjList[i].put(FieldMappingList[j].SVMXC__Target_Field_Name__c,datetime.newInstance(system.today()+1, time.newInstance(0, 0, 0, 0)));
                                            }
                                            else if(FieldMappingList[j].SVMXC__Display_Value__c.touppercase() == 'NOW')
                                            {
                                                SobjList[i].put(FieldMappingList[j].SVMXC__Target_Field_Name__c,system.now());
                                            }
                                            else
                                            {           
                                                SobjList[i].put(FieldMappingList[j].SVMXC__Target_Field_Name__c,DateTime.valueof(FieldMappingList[j].SVMXC__Display_Value__c));
                                            }
                                                    
                                        }
                                        else if(f.getType() == schema.Displaytype.Date && f.isCreateable())//if field type is Date
                                        {
                                            if(FieldMappingList[j].SVMXC__Display_Value__c.touppercase() == 'TODAY')
                                            {
                                                SobjList[i].put(FieldMappingList[j].SVMXC__Target_Field_Name__c,system.today());
                                            }   
                                            else if(FieldMappingList[j].SVMXC__Display_Value__c.touppercase() == 'YESTERDAY')
                                            {
                                                SobjList[i].put(FieldMappingList[j].SVMXC__Target_Field_Name__c,system.today() - 1);
                                            }       
                                            else if(FieldMappingList[j].SVMXC__Display_Value__c.touppercase() == 'TOMORROW')
                                            {
                                                SobjList[i].put(FieldMappingList[j].SVMXC__Target_Field_Name__c,system.today() + 1);
                                            }
                                            else
                                            {           
                                                SobjList[i].put(FieldMappingList[j].SVMXC__Target_Field_Name__c,Date.valueof(FieldMappingList[j].SVMXC__Display_Value__c));
                                            }
                                        }else if(f.getType() == schema.Displaytype.Time && f.isCreateable()){//if field type is Time - Added by Nidhi - BAC-5648
                                            if(FieldMappingList[j].SVMXC__Display_Value__c != null){
                                                Time timeValue = null;
                                                String str = String.valueOf(FieldMappingList[j].SVMXC__Display_Value__c);
                                                list<String> listTimeValue1 = new list<String>();
                                                listTimeValue1 = str.split('\\.');
                                                if(!String.isBlank(str) && listTimeValue1.size()>0){ 
                                                    str = listTimeValue1[0];
                                                    //String miliSec = listTimeValue1[1].removeEndIgnoreCase('z');  
                                                    String miliSec = '0';// Fixing defect BAC-3848
                                                    if(listTimeValue1.size()>1){
                                                        miliSec = listTimeValue1[1].removeEndIgnoreCase('z');    
                                                    }                                                      
                                                    list<String> listTimeValue2 = new list<String>();
                                                    listTimeValue2 = str.split(':');
                                                    timeValue = Time.newInstance(Integer.valueOf(listTimeValue2[0]), Integer.valueOf(listTimeValue2[1]), Integer.valueOf(listTimeValue2[2]),Integer.valueOf(miliSec));
                                                    SobjList[i].put(FieldMappingList[j].SVMXC__Target_Field_Name__c,timeValue);
                                                } 
                                            }                                       
                                        }
                                        else if(f.getType() == schema.Displaytype.MultiPicklist && f.isCreateable())//if field type is MultiPicklist
                                        {
                                            if(String.valueof(FieldMappingList[j].SVMXC__Display_Value__c) != null)
                                            {
                                                SobjList[i].put(FieldMappingList[j].SVMXC__Target_Field_Name__c,String.valueof(FieldMappingList[j].SVMXC__Display_Value__c));
                                            }
                                        }
                                        else //else field type is REFERENCE,String 
                                        {
                                            if((String)FieldMappingList[j].SVMXC__Display_Value__c != null && f.isCreateable())
                                            {
                                                SobjList[i].put(FieldMappingList[j].SVMXC__Target_Field_Name__c,(String)FieldMappingList[j].SVMXC__Display_Value__c);
                                            }
                                        }
                                    }        
                                }   
                            }       
                        }                                                
                    }       
                }   
            }
        }
        system.debug('SobjList'+SobjList); 
        return SobjList;
    }
    public map<String,Sobject> applyMappingForDetail(String mapSFID,map<String,Sobject> SourceRecIdTargetObjMap,Boolean DoPopulateOwner,map<String,Schema.SObjectType> Allobj,String strSourceObjNameParam,String strTargetObjNameParam,list<SVMXC__ServiceMax_Config_Data__c> lstFieldMappingParam, Sobject objCurrentRecHeader)
    {
        return applyMappingForDetail( mapSFID, SourceRecIdTargetObjMap,DoPopulateOwner,Allobj,strSourceObjNameParam,strTargetObjNameParam, lstFieldMappingParam, objCurrentRecHeader, new map<String,Sobject>() );
    }
    
    public map<String,Sobject> applyMappingForDetail(String mapSFID,map<String,Sobject> SourceRecIdTargetObjMap,Boolean DoPopulateOwner,map<String,Schema.SObjectType> Allobj,String strSourceObjNameParam,String strTargetObjNameParam,list<SVMXC__ServiceMax_Config_Data__c> lstFieldMappingParam, Sobject objCurrentRecHeader, map<String,Sobject> SourceRecMap)
    {
        //map<String, Schema.SObjectField> mapTargetFieldDesc = new map<String, Schema.SObjectField>();
        Map<String, Schema.DescribeFieldResult> mapFieldApiNameDescribeResult = new Map<String, Schema.DescribeFieldResult>();
        map<String, Schema.SObjectField> FieldMap = new map<String, Schema.SObjectField>();
        map<String,Sobject> mapFinalSourceRecIdTargetObj = new map<String,Sobject>();
        Set<String> SourceRecIds = new Set<String>();
         
        String strSourceObjName = '';
        String strTargetObjName = '';
        if(SourceRecIdTargetObjMap.size() > 0)
        {
            for(String s : SourceRecIdTargetObjMap.keyset())
            {
                SourceRecIds.add(s);
            }
        }
        system.debug('SourceRecIds'+SourceRecIds);
        if(strSourceObjNameParam != null && strTargetObjNameParam != null)
        {
            strSourceObjName = strSourceObjNameParam;
            strTargetObjName = strTargetObjNameParam;
        }
        else if(mapSFID != null)
        {
            SVMXC__ServiceMax_Processes__c MapHeader = new SVMXC__ServiceMax_Processes__c();
            
            //Commented this query and added new one which has only required fields queried for the story BAC-4410
            //MapHeader = [Select SVMXC__Type__c, SVMXC__Target_Record_Type__c, SVMXC__Target_Object_label__c,SVMXC__Target_Object_Name__c, SVMXC__Submodule__c, SVMXC__SubmoduleID__c, SVMXC__Source_Object_Name__c,SVMXC__Settings_Name__c, SVMXC__Setting_Unique_ID__c, SVMXC__SettingID__c, SVMXC__Sequence__c, SVMXC__Select__c,SVMXC__Search_Order__c, SVMXC__Rule_Type__c, SVMXC__Purpose__c, SVMXC__Process__c, SVMXC__ProcessID__c,SVMXC__Parent_Object__c, SVMXC__Parent_Object_Criteria__c, SVMXC__Parent_Error_Msg__c,SVMXC__Parent_Column_Name__c, SVMXC__Page_Layout__c, SVMXC__Node_Source_Object_API__c,SVMXC__Node_Parent_API__c, SVMXC__Node_Parent__c, SVMXC__Name__c, SVMXC__Module__c, SVMXC__ModuleID__c,SVMXC__MapID__c, SVMXC__MTTS_Minutes__c,SVMXC__IsStandard__c, SVMXC__IsStandalone__c, SVMXC__IsPrivate__c, SVMXC__IsDefault__C,SVMXC__Final_Exception_Process__c,SVMXC__End_Date__c, SVMXC__Email_On_Success__c,SVMXC__Email_On_Error__c, SVMXC__Dispatch_Method__c, SVMXC__Description__c,SVMXC__Default_Value__c, SVMXC__Data_Type__c,  SVMXC__Child_Object_Criteria__c,SVMXC__Child_Error_Msg__c,SVMXC__Advance_Expression__c,SVMXC__Active__c, RecordTypeId, OwnerId, Name,LastModifiedDate, LastModifiedById, LastActivityDate, IsDeleted, Id, CreatedDate, CreatedById From SVMXC__ServiceMax_Processes__c  where Id =: mapSFID];
            MapHeader = [Select SVMXC__Target_Object_Name__c, SVMXC__Source_Object_Name__c From SVMXC__ServiceMax_Processes__c  where Id =: mapSFID]; //SDL-SVMX-FLS-NOT-ENFORCED-META-DATA
            strSourceObjName = MapHeader.SVMXC__Source_Object_Name__c;
            strTargetObjName = MapHeader.SVMXC__Target_Object_Name__c;
        }
        List<SVMXC__ServiceMax_Config_Data__c> FieldMappingList = new List<SVMXC__ServiceMax_Config_Data__c>(); 
        if(lstFieldMappingParam != null && lstFieldMappingParam.size() > 0)
        {
            FieldMappingList = lstFieldMappingParam;
        }
        else if(lstFieldMappingParam == null && mapSFID != null && mapSFID.length() > 0)
        {
            if(Userinfo.isMultiCurrencyOrganization())
                
                FieldMappingList = [Select SVMXC__Target_Field_Name__c, SVMXC__Source_Field_Name__c, SVMXC__Preference_3__c, SVMXC__Preference_2__c, SVMXC__MapID__c, SVMXC__Internal_Value__c, SVMXC__Display_Value__c, SVMXC__Configuration_Type__c,SVMXC__Active__c, RecordTypeId, Name, Id From SVMXC__ServiceMax_Config_Data__c where SVMXC__MapID__c =: mapSFID]; //SDL-SVMX-FLS-NOT-ENFORCED-META-DATA
            else
                
                FieldMappingList = [Select  SVMXC__Target_Field_Name__c, SVMXC__Source_Field_Name__c, SVMXC__Preference_3__c, SVMXC__Preference_2__c, SVMXC__MapID__c, SVMXC__Internal_Value__c, SVMXC__Display_Value__c, SVMXC__Configuration_Type__c,SVMXC__Active__c, RecordTypeId, Name, Id From SVMXC__ServiceMax_Config_Data__c where SVMXC__MapID__c =: mapSFID and SVMXC__Target_Field_Name__c != 'CurrencyIsoCode'];   //SDL-SVMX-FLS-NOT-ENFORCED-META-DATA
        }   
        system.debug('FieldMappingList'+FieldMappingList.size()+FieldMappingList);
        set<String> TargetFieldsSet = new set<String>();
        Set<String> sourceFieldsSet = new Set<String>();//-----------Added for code optimization BAC-2993------------//
        if(!(FieldMappingList.isEmpty()))
        {
            for(SVMXC__ServiceMax_Config_Data__c configData : FieldMappingList)
            {
                if(configData.SVMXC__Target_Field_Name__c != null)
                    TargetFieldsSet.add(configData.SVMXC__Target_Field_Name__c);
                
                //-----Start------Added for code optimization BAC-2993------------//
                if(SFMDeliveryServiceImpl.isQueryOptimizerEnabled){ //Check added as part of story BAC-3256
                        //Here we are collecting all the fields used in the mapping for the source object.
                    if(configData.SVMXC__Source_Field_Name__c != null)
                        sourceFieldsSet.add(configData.SVMXC__Source_Field_Name__c);
                    if(configData.SVMXC__Preference_2__c != null)
                        sourceFieldsSet.add(configData.SVMXC__Preference_2__c);
                    if(configData.SVMXC__Preference_3__c != null)
                        sourceFieldsSet.add(configData.SVMXC__Preference_3__c);
                }
                //------End-----Added for code optimization BAC-2993------------//
            }
        }
        System.debug('TargetFieldsSet: '+TargetFieldsSet);
        System.debug('sourceFieldsSet: '+sourceFieldsSet);
        //Get the Target object Fields 
        //if(strTargetObjName != null && Allobj.containskey(strTargetObjName)) // #optiChange
        if(String.isNotBlank(strTargetObjName)) // #optiChange
        {
            map<String, Schema.SObjectField> LFieldMap = new map<String, Schema.SObjectField>();
           // LFieldMap = Allobj.get(strTargetObjName).getDescribe().fields.getMap(); #optiChange
            LFieldMap = COMM_Utils_DescribeCall.getObjectFieldDetails(strTargetObjName); // #optiChange
            if(LFieldMap != NULL && !LFieldMap.isEmpty())
            {
                /*for(String s : LFieldMap.keyset())
                {
                    mapTargetFieldDesc.put(LFieldMap.get(s).getDescribe().getName(),LFieldMap.get(s));
                }*/
                Set<String> setFields = LFieldMap.keySet();
                for(String strField: TargetFieldsSet){
                    strField = strField.toLowerCase();
                    if(setFields.contains(strField)){
                        Schema.DescribeFieldResult objDFR = LFieldMap.get(strField).getDescribe();
                        mapFieldApiNameDescribeResult.put(objDFR.getName(), objDFR);
                    }
                }
                if(LFieldMap.containsKey('ownerid')){
                    Schema.DescribeFieldResult objDFR = LFieldMap.get('ownerid').getDescribe();
                    mapFieldApiNameDescribeResult.put(objDFR.getName(), objDFR);
                }
            }
        } 
        //system.debug('mapTargetFieldDesc'+mapTargetFieldDesc);    
        System.debug('mapFieldApiNameDescribeResult: '+mapFieldApiNameDescribeResult);    
        //Get the Source Records...
        list<Sobject> SourceObjRecordlist = new list<Sobject>();
       // if(strSourceObjName != null && Allobj.containskey(strSourceObjName))   #optiChange
        if(strSourceObjName != null)    
        {   
            /* Commented for code optimization BAC-2993
            List<String> fieldlist = new List<String>();
            string fields = '';
            FieldMap = Allobj.get(strSourceObjName).getDescribe().fields.getMap();
            if(FieldMap.size() > 0)
                fieldlist = commutils.SVMX_getFieldList(FieldMap,true);
            if(fieldlist.size() > 0)
                fields = commutils.SVMX_getFieldNamesFromList(fieldlist);
            system.debug('fields'+fields);*/
           
            //------Start-----Added for code optimization BAC-2993------------//
            //This is implemented to avoid querying all the fields for the source object record.
            String fields = '';
            if(SFMDeliveryServiceImpl.isQueryOptimizerEnabled && sourceFieldsSet.size() > 0){ //Check added as part of story BAC-3256
                List<String> lstSourceFields = new List<String>();
                lstSourceFields.addAll(sourceFieldsSet);
                lstSourceFields = commutils.checkDuplicateFields(lstSourceFields, strSourceObjName); //Added for the defect 043715
                fields = commutils.SVMX_getFieldNamesFromList(lstSourceFields);
            }
            else{
                List<String> fieldlist = new List<String>();
                FieldMap = COMM_Utils_DescribeCall.getObjectFieldDetails(strSourceObjName);
                //FieldMap = Allobj.get(strSourceObjName).getDescribe().fields.getMap(); #optiChange
                if(FieldMap.size() > 0)
                   fieldlist = commutils.SVMX_getFieldList(FieldMap,true);
                if(fieldlist.size() > 0){
                    fieldlist = commutils.checkDuplicateFields(fieldlist, strSourceObjName); //Added for the defect 043715
                    fields = commutils.SVMX_getFieldNamesFromList(fieldlist);
                }
            }
            system.debug(LoggingLevel.WARN,'fields'+fields);
            //-----End------Added for code optimization BAC-2993------------//
            
            if(fields != null && fields.length() > 0 && SourceRecIds != null && SourceRecIds.size() > 0 && ( SourceRecMap == null || SourceRecMap.isEmpty() ) )
            {
                String Query = 'Select ' + fields + ' from ' + strSourceObjName + ' where id  IN : SourceRecIds';     //= ' +  '\''+SourceRecId+'\'';
                system.debug('Query'+Query);
                SourceRecMap.putall(Database.query(Query));
            }
        }
        system.debug('SourceRecMap'+SourceRecMap);
        if(SourceRecIdTargetObjMap.size() > 0 && FieldMappingList.size() > 0 && SourceRecMap.size() > 0)
        {
            
            List<RecordType> RecordtypeLst = new List<RecordType>();
            if(strTargetObjName != null ) {
                if( !targerObjectRecordTypeListMap.containsKey(strTargetObjName) ) {
                    
                    //Commented this query and added new one which has only required fields queried for the story BAC-4410
                    //RecordtypeLst = [Select SystemModstamp, SobjectType, NamespacePrefix, Name, LastModifiedDate, LastModifiedById, IsActive, Id, DeveloperName, Description, CreatedDate, CreatedById, BusinessProcessId From RecordType where SobjectType =: strTargetObjName];
                    RecordtypeLst = [Select Id, Name From RecordType where SobjectType =: strTargetObjName]; //SDL-SVMX-FLS-NOT-ENFORCED-META-DATA
                    targerObjectRecordTypeListMap.put(strTargetObjName, RecordtypeLst);
                }
                RecordtypeLst = targerObjectRecordTypeListMap.get( strTargetObjName );
            }
                
            system.debug('RecordtypeLst'+RecordtypeLst);
            for(String s1 : SourceRecIdTargetObjMap.keyset())
            {
                Sobject Sobj = SourceRecIdTargetObjMap.get(s1);
                Sobject SourceObjRecord;
                if(SourceRecMap.containskey(s1))
                    SourceObjRecord = SourceRecMap.get(s1);
                system.debug('SourceObjRecord'+SourceObjRecord);    
                if(DoPopulateOwner && TargetFieldsSet.size() > 0 && TargetFieldsSet.contains('OwnerId') == false && mapFieldApiNameDescribeResult.containskey('OwnerId'))
                {
                    Sobj.put('OwnerId',Userinfo.getUserId());
                }
                //check for the value map
                if(strSourceObjName == null)
                {
                    for(Integer j = 0;j<FieldMappingList.size();j++)
                    {
                        if(FieldMappingList[j].SVMXC__Source_Field_Name__c != null && FieldMappingList[j].SVMXC__Display_Value__c != null)
                            Sobj.put(FieldMappingList[j].SVMXC__Source_Field_Name__c,FieldMappingList[j].SVMXC__Display_Value__c);
                    }
                }
                //Field Map
                if(strSourceObjName != null)
                {
                    for(Integer j = 0;j<FieldMappingList.size();j++)
                    {
                        if(FieldMappingList[j].SVMXC__Target_Field_Name__c != null && mapFieldApiNameDescribeResult.containskey(FieldMappingList[j].SVMXC__Target_Field_Name__c))
                        {
                            //Desctibe the field to check differen attributes of fields..
                            Schema.DescribeFieldResult f = mapFieldApiNameDescribeResult.get(FieldMappingList[j].SVMXC__Target_Field_Name__c);
                            //Schema.DescribeFieldResult f = mapTargetFieldDesc.get(FieldMappingList[j].SVMXC__Target_Field_Name__c).getDescribe();
                            if(FieldMappingList[j].SVMXC__Target_Field_Name__c == 'RecordTypeId' && f.isCreateable())
                            {
                                if(FieldMappingList[j].SVMXC__Display_Value__c != null)
                                {
                                    String RecordTypeId = '';
                                    if(RecordtypeLst.size() > 0)
                                    { 
                                        for(RecordType r : RecordtypeLst)
                                        {
                                            if(FieldMappingList[j].SVMXC__Display_Value__c != null && r.Name.touppercase() == FieldMappingList[j].SVMXC__Display_Value__c.touppercase())
                                                RecordTypeId = r.id;
                                        }
                                    } 
                                    if(RecordTypeId != null && RecordTypeId.length() > 0)
                                        Sobj.put(FieldMappingList[j].SVMXC__Target_Field_Name__c,RecordTypeId);
                                }
                                else if(FieldMappingList[j].SVMXC__Source_Field_Name__c != null && SourceObjRecord.get(FieldMappingList[j].SVMXC__Source_Field_Name__c) != null)
                                {
                                    Sobj.put(FieldMappingList[j].SVMXC__Target_Field_Name__c,SourceObjRecord.get(FieldMappingList[j].SVMXC__Source_Field_Name__c));
                                }        
                            }
                            else if(FieldMappingList[j].SVMXC__Target_Field_Name__c != 'RecordTypeId' && f.isCreateable())
                            {
                                if(FieldMappingList[j].SVMXC__Source_Field_Name__c != null && String.valueof(SourceObjRecord.get(FieldMappingList[j].SVMXC__Source_Field_Name__c)) != null)
                                {   
                                    Sobj.put(FieldMappingList[j].SVMXC__Target_Field_Name__c,SourceObjRecord.get(FieldMappingList[j].SVMXC__Source_Field_Name__c));
                                }    
                                else if(FieldMappingList[j].SVMXC__Source_Field_Name__c != null && String.valueof(SourceObjRecord.get(FieldMappingList[j].SVMXC__Source_Field_Name__c)) == null && FieldMappingList[j].SVMXC__Preference_2__c != null && String.valueof(SourceObjRecord.get(FieldMappingList[j].SVMXC__Preference_2__c)) != null)
                                {
                                    Sobj.put(FieldMappingList[j].SVMXC__Target_Field_Name__c,SourceObjRecord.get(FieldMappingList[j].SVMXC__Preference_2__c));
                                }    
                                else if(FieldMappingList[j].SVMXC__Source_Field_Name__c != null && String.valueof(SourceObjRecord.get(FieldMappingList[j].SVMXC__Source_Field_Name__c)) == null && FieldMappingList[j].SVMXC__Preference_2__c != null && String.valueof(SourceObjRecord.get(FieldMappingList[j].SVMXC__Preference_2__c)) == null && FieldMappingList[j].SVMXC__Preference_3__c != null && String.valueof(SourceObjRecord.get(FieldMappingList[j].SVMXC__Preference_3__c)) != null)
                                {
                                    Sobj.put(FieldMappingList[j].SVMXC__Target_Field_Name__c,SourceObjRecord.get(FieldMappingList[j].SVMXC__Preference_3__c));
                                }    
                                if(FieldMappingList[j].SVMXC__Source_Field_Name__c  == null && FieldMappingList[j].SVMXC__Preference_2__c == null  && FieldMappingList[j].SVMXC__Preference_3__c == null && FieldMappingList[j].SVMXC__Display_Value__c != null && mapFieldApiNameDescribeResult.containskey(FieldMappingList[j].SVMXC__Target_Field_Name__c))
                                {
                                    //Check for the Servicemax Constants..
                                    if(FieldMappingList[j].SVMXC__Display_Value__c.contains('SVMX.CURRENTRECORD.')){
                                        list<String> lstString = new list<String>(); 
                                        lstString = FieldMappingList[j].SVMXC__Display_Value__c.split('SVMX.CURRENTRECORD.');
                                        if(lstString.size() > 0)
                                            Sobj.put(FieldMappingList[j].SVMXC__Target_Field_Name__c,Sobj.get(lstString[1]));
                                    }
                                    else if(FieldMappingList[j].SVMXC__Display_Value__c.contains('SVMX.CURRENTRECORDHEADER.')){
                                        list<String> lstString = new list<String>();
                                        lstString = FieldMappingList[j].SVMXC__Display_Value__c.split('SVMX.CURRENTRECORDHEADER.');
                                        if(lstString.size() > 0 && objCurrentRecHeader != null)
                                            Sobj.put(FieldMappingList[j].SVMXC__Target_Field_Name__c,objCurrentRecHeader.get(lstString[1]));
                                    }
                                    else if(FieldMappingList[j].SVMXC__Display_Value__c.contains('SVMX.CURRENTUSERID')){
                                        Sobj.put(FieldMappingList[j].SVMXC__Target_Field_Name__c,userinfo.getUserId());
                                    }
                                    else if(FieldMappingList[j].SVMXC__Display_Value__c.contains('SVMX.USERTRUNK')){
                                        SVMXC.SVMX_Constant_Utils constantUtils = new SVMXC.SVMX_Constant_Utils();
                                        Sobj.put(FieldMappingList[j].SVMXC__Target_Field_Name__c,constantUtils.getSVMXUserTrunkId());
                                    }else if(FieldMappingList[j].SVMXC__Display_Value__c.contains('SVMX.GEOLOCATION.COORDS.LATITUDE') || FieldMappingList[j].SVMXC__Display_Value__c.contains('SVMX.GEOLOCATION.COORDS.LONGITUDE') || FieldMappingList[j].SVMXC__Display_Value__c.contains('SVMX.GEOLOCATION.COORDS.ACCURACY') || FieldMappingList[j].SVMXC__Display_Value__c.contains('SVMX.SETNULL')){ // Added for BAC-4677, BAC-5089
                                    }
                                    else
                                    {   
                                        if((f.getType() == schema.Displaytype.Double  || f.getType() == schema.Displaytype.Percent || f.getType() == schema.Displaytype.Currency)&& f.isCreateable())//if Field Type is Double,persent,currency 
                                        {
                                            if(double.valueOf(FieldMappingList[j].SVMXC__Display_Value__c) != null )
                                            {
                                                Sobj.put(FieldMappingList[j].SVMXC__Target_Field_Name__c,double.valueOf(FieldMappingList[j].SVMXC__Display_Value__c));
                                            }   
                                        }
                                        else if(f.getType() == schema.Displaytype.Integer && f.isCreateable())//if field type is Integer
                                        {
                                            if(Integer.valueof(FieldMappingList[j].SVMXC__Display_Value__c)!= null)
                                            {
                                                Sobj.put(FieldMappingList[j].SVMXC__Target_Field_Name__c,Integer.valueof(FieldMappingList[j].SVMXC__Display_Value__c));
                                            }   
                                        }
                                        else if(f.getType() == schema.Displaytype.Boolean && f.isCreateable())//if field type is Boolean
                                        {
                                            if(Boolean.valueof(FieldMappingList[j].SVMXC__Display_Value__c)!= null)
                                            {
                                                Sobj.put(FieldMappingList[j].SVMXC__Target_Field_Name__c,Boolean.valueof(FieldMappingList[j].SVMXC__Display_Value__c));
                                            }   
                                        }
                                        else if(f.getType() == schema.Displaytype.DateTime && f.isCreateable())//if field type is DateTime
                                        {
                                            if(FieldMappingList[j].SVMXC__Display_Value__c.touppercase() == 'TODAY')
                                            {
                                                Sobj.put(FieldMappingList[j].SVMXC__Target_Field_Name__c,datetime.newInstance(system.today(), time.newInstance(0, 0, 0, 0)));
                                            }   
                                            else if(FieldMappingList[j].SVMXC__Display_Value__c.touppercase() == 'YESTERDAY')
                                            {
                                                Sobj.put(FieldMappingList[j].SVMXC__Target_Field_Name__c,datetime.newInstance(system.today()-1, time.newInstance(0, 0, 0, 0)));
                                            }       
                                            else if(FieldMappingList[j].SVMXC__Display_Value__c.touppercase() == 'TOMORROW')
                                            {
                                                Sobj.put(FieldMappingList[j].SVMXC__Target_Field_Name__c,datetime.newInstance(system.today()+1, time.newInstance(0, 0, 0, 0)));
                                            }
                                            else if(FieldMappingList[j].SVMXC__Display_Value__c.touppercase() == 'NOW')
                                            {
                                                Sobj.put(FieldMappingList[j].SVMXC__Target_Field_Name__c,system.now());
                                            }
                                            else
                                            {           
                                                Sobj.put(FieldMappingList[j].SVMXC__Target_Field_Name__c,DateTime.valueof(FieldMappingList[j].SVMXC__Display_Value__c));
                                            }
                                                    
                                        }
                                        else if(f.getType() == schema.Displaytype.Date && f.isCreateable())//if field type is Date
                                        {
                                            if(FieldMappingList[j].SVMXC__Display_Value__c.touppercase() == 'TODAY')
                                            {
                                                Sobj.put(FieldMappingList[j].SVMXC__Target_Field_Name__c,system.today());
                                            }   
                                            else if(FieldMappingList[j].SVMXC__Display_Value__c.touppercase() == 'YESTERDAY')
                                            {
                                                Sobj.put(FieldMappingList[j].SVMXC__Target_Field_Name__c,system.today() - 1);
                                            }       
                                            else if(FieldMappingList[j].SVMXC__Display_Value__c.touppercase() == 'TOMORROW')
                                            {
                                                Sobj.put(FieldMappingList[j].SVMXC__Target_Field_Name__c,system.today() + 1);
                                            }
                                            else
                                            {           
                                                Sobj.put(FieldMappingList[j].SVMXC__Target_Field_Name__c,Date.valueof(FieldMappingList[j].SVMXC__Display_Value__c));
                                            }
                                        }
                                        else if(f.getType() == schema.Displaytype.Time && f.isCreateable()){//if field type is Time - Added by Nidhi - BAC-5648
                                            if(FieldMappingList[j].SVMXC__Display_Value__c != null){
                                                Time timeValue = null;
                                                String str = String.valueOf(FieldMappingList[j].SVMXC__Display_Value__c);
                                                list<String> listTimeValue1 = new list<String>();
                                                listTimeValue1 = str.split('\\.');
                                                if(!String.isBlank(str) && listTimeValue1.size()>0){ 
                                                    str = listTimeValue1[0];
                                                    //String miliSec = listTimeValue1[1].removeEndIgnoreCase('z');   
                                                    String miliSec = '0';// Fixing defect BAC-3848
                                                    if(listTimeValue1.size()>1){
                                                        miliSec = listTimeValue1[1].removeEndIgnoreCase('z');    
                                                    }                                                   
                                                    list<String> listTimeValue2 = new list<String>();
                                                    listTimeValue2 = str.split(':');
                                                    timeValue = Time.newInstance(Integer.valueOf(listTimeValue2[0]), Integer.valueOf(listTimeValue2[1]), Integer.valueOf(listTimeValue2[2]),Integer.valueOf(miliSec));
                                                    Sobj.put(FieldMappingList[j].SVMXC__Target_Field_Name__c,timeValue);
                                                } 
                                            }                                       
                                        }
                                        else if(f.getType() == schema.Displaytype.MultiPicklist && f.isCreateable())//if field type is MultiPicklist
                                        {
                                            if(String.valueof(FieldMappingList[j].SVMXC__Display_Value__c) != null)
                                            {
                                                Sobj.put(FieldMappingList[j].SVMXC__Target_Field_Name__c,String.valueof(FieldMappingList[j].SVMXC__Display_Value__c));
                                            }
                                        }
                                        else //else field type is REFERENCE,String 
                                        {
                                            if((String)FieldMappingList[j].SVMXC__Display_Value__c != null && f.isCreateable())
                                            {
                                                Sobj.put(FieldMappingList[j].SVMXC__Target_Field_Name__c,(String)FieldMappingList[j].SVMXC__Display_Value__c);
                                            }
                                        }
                                    }        
                                }   
                            }       
                        }
                    }       
                }
                mapFinalSourceRecIdTargetObj.put(s1,Sobj);
                //SobjectList.add(Sobj);    
            }
        
        }
        system.debug('mapFinalSourceRecIdTargetObj:: '+mapFinalSourceRecIdTargetObj.size()+mapFinalSourceRecIdTargetObj);
        return mapFinalSourceRecIdTargetObj;
    }
    public List<Sobject> getValueMapping(List<Sobject> SobjList,String mapSFID,map<String,Schema.SObjectType> Allobj){
        return getValueMapping1(SobjList,mapSFID,Allobj,null);
    }
    public List<Sobject> getValueMapping1(List<Sobject> SobjList,String mapSFID,map<String,Schema.SObjectType> Allobj,String strProcessType){
        return getValueMapping1(SobjList,mapSFID,Allobj,strProcessType,null);
    }
    
    public List<Sobject> getValueMapping1(List<Sobject> SobjList,String mapSFID,map<String,Schema.SObjectType> Allobj,String strProcessType, Sobject objCurrentRecHeader)
    {
            mappedFieldsForHeader.clear(); //Added as part of Story BAC-3257
        SVMXC__ServiceMax_Processes__c MapHeader = new SVMXC__ServiceMax_Processes__c();
        List<SVMXC__ServiceMax_Config_Data__c> FieldMappingList = new List<SVMXC__ServiceMax_Config_Data__c>();
        
        //Commented this query and added new one which has only required fields queried for the story BAC-4410
        //MapHeader = [Select SVMXC__Type__c, SVMXC__Target_Record_Type__c, SVMXC__Target_Object_label__c,SVMXC__Target_Object_Name__c, SVMXC__Submodule__c, SVMXC__SubmoduleID__c, SVMXC__Source_Object_Name__c,SVMXC__Settings_Name__c, SVMXC__Setting_Unique_ID__c, SVMXC__SettingID__c, SVMXC__Sequence__c, SVMXC__Select__c,SVMXC__Search_Order__c, SVMXC__Rule_Type__c, SVMXC__Purpose__c, SVMXC__Process__c, SVMXC__ProcessID__c,SVMXC__Parent_Object__c, SVMXC__Parent_Object_Criteria__c, SVMXC__Parent_Error_Msg__c,SVMXC__Parent_Column_Name__c, SVMXC__Page_Layout__c, SVMXC__Node_Source_Object_API__c,SVMXC__Node_Parent_API__c, SVMXC__Node_Parent__c, SVMXC__Name__c, SVMXC__Module__c, SVMXC__ModuleID__c,SVMXC__MapID__c, SVMXC__MTTS_Minutes__c,SVMXC__IsStandard__c, SVMXC__IsStandalone__c, SVMXC__IsPrivate__c, SVMXC__IsDefault__C,SVMXC__Final_Exception_Process__c,SVMXC__End_Date__c, SVMXC__Email_On_Success__c,SVMXC__Email_On_Error__c, SVMXC__Dispatch_Method__c, SVMXC__Description__c,SVMXC__Default_Value__c, SVMXC__Data_Type__c,  SVMXC__Child_Object_Criteria__c,SVMXC__Child_Error_Msg__c,SVMXC__Advance_Expression__c,SVMXC__Active__c, RecordTypeId, OwnerId, Name,LastModifiedDate, LastModifiedById, LastActivityDate, IsDeleted, Id, CreatedDate, CreatedById From SVMXC__ServiceMax_Processes__c  where Id =: mapSFID];
        MapHeader = [Select Id, SVMXC__Target_Object_Name__c From SVMXC__ServiceMax_Processes__c  where Id =: mapSFID]; //SDL-SVMX-FLS-NOT-ENFORCED-META-DATA
        system.debug('MapHeader'+MapHeader);
        if(MapHeader != null && MapHeader.id != null){
            if(Userinfo.isMultiCurrencyOrganization()){
                //Commented this query and added new one which has only required fields queried for the story BAC-4410
                //FieldMappingList = [Select SystemModstamp, SVMXC__Display_Value__c, SVMXC__User__c, SVMXC__Target_Field_Name__c, SVMXC__Stock_Status__c, SVMXC__Stock_History_Line_Lookup_Field__c, SVMXC__Stock_History_Header_Lookup_Field__c, SVMXC__Source_Field_Name__c, SVMXC__Setting_Unique_ID__c,  SVMXC__Setting_ID__c, SVMXC__Setting_Configuration_Profile__c, SVMXC__SettingID__c, SVMXC__Sequence__c, SVMXC__Select__c, SVMXC__Search_Object_Field_Type__c, SVMXC__Object_Name__c, SVMXC__FKey_Name_Field__c, SVMXC__RecordType_Name__c, SVMXC__Profile__c, SVMXC__Profile_Name__c, SVMXC__Preference_3__c, SVMXC__Preference_2__c, SVMXC__Operator__c, SVMXC__Operand__c, SVMXC__MapID__c, SVMXC__Lookup_Field_API_Name__c, SVMXC__Location_Type__c, SVMXC__Location_Field_Name__c, SVMXC__Location_Field_From__c, SVMXC__IsDefault__c, SVMXC__Inventory_Process__c, SVMXC__Internal_Value__c, SVMXC__Installation_Key__c, SVMXC__Display_Type__c, SVMXC__Field_Relationship_Name__c, SVMXC__Field_Name__c, SVMXC__Expression_Type__c, SVMXC__Expression_Rule__c, SVMXC__Enter_Date__c, SVMXC__Enable_Task__c, SVMXC__Enable_Calendar__c, SVMXC__Enable_Activity_Tracking_On__c, SVMXC__Display_Map_ID__c, SVMXC__Dispatch_Process__c, SVMXC__Description__c, SVMXC__Configuration_Type__c, SVMXC__Config_Profile_Name__c, SVMXC__Active__c, SVMXC__Action__c, SVMXC__Access_Configuration_Profile__c, RecordTypeId, OwnerId, Name, LastModifiedDate, LastModifiedById, LastActivityDate, IsDeleted, Id,CreatedDate, CreatedById From SVMXC__ServiceMax_Config_Data__c  where SVMXC__MapID__c =: MapHeader.id];
                FieldMappingList = [Select SVMXC__Target_Field_Name__c, SVMXC__Display_Value__c From SVMXC__ServiceMax_Config_Data__c  where SVMXC__MapID__c =: MapHeader.id]; //SDL-SVMX-FLS-NOT-ENFORCED-META-DATA
            }
            else{
                //Commented this query and added new one which has only required fields queried for the story BAC-4410
                //FieldMappingList = [Select SystemModstamp, SVMXC__Display_Value__c, SVMXC__User__c, SVMXC__Target_Field_Name__c, SVMXC__Stock_Status__c, SVMXC__Stock_History_Line_Lookup_Field__c, SVMXC__Stock_History_Header_Lookup_Field__c, SVMXC__Source_Field_Name__c, SVMXC__Setting_Unique_ID__c,  SVMXC__Setting_ID__c, SVMXC__Setting_Configuration_Profile__c, SVMXC__SettingID__c, SVMXC__Sequence__c, SVMXC__Select__c, SVMXC__Search_Object_Field_Type__c, SVMXC__Object_Name__c, SVMXC__FKey_Name_Field__c, SVMXC__RecordType_Name__c, SVMXC__Profile__c, SVMXC__Profile_Name__c, SVMXC__Preference_3__c, SVMXC__Preference_2__c, SVMXC__Operator__c, SVMXC__Operand__c, SVMXC__MapID__c, SVMXC__Lookup_Field_API_Name__c, SVMXC__Location_Type__c, SVMXC__Location_Field_Name__c, SVMXC__Location_Field_From__c, SVMXC__IsDefault__c, SVMXC__Inventory_Process__c, SVMXC__Internal_Value__c, SVMXC__Installation_Key__c, SVMXC__Display_Type__c, SVMXC__Field_Relationship_Name__c, SVMXC__Field_Name__c, SVMXC__Expression_Type__c, SVMXC__Expression_Rule__c, SVMXC__Enter_Date__c, SVMXC__Enable_Task__c, SVMXC__Enable_Calendar__c, SVMXC__Enable_Activity_Tracking_On__c, SVMXC__Display_Map_ID__c, SVMXC__Dispatch_Process__c, SVMXC__Description__c, SVMXC__Configuration_Type__c, SVMXC__Config_Profile_Name__c, SVMXC__Active__c, SVMXC__Action__c, SVMXC__Access_Configuration_Profile__c, RecordTypeId, OwnerId, Name, LastModifiedDate, LastModifiedById, LastActivityDate, IsDeleted, Id,CreatedDate, CreatedById From SVMXC__ServiceMax_Config_Data__c  where SVMXC__MapID__c =: MapHeader.id and SVMXC__Target_Field_Name__c != 'CurrencyIsoCode'];
                FieldMappingList = [Select SVMXC__Target_Field_Name__c, SVMXC__Display_Value__c From SVMXC__ServiceMax_Config_Data__c  where SVMXC__MapID__c =: MapHeader.id and SVMXC__Target_Field_Name__c != 'CurrencyIsoCode']; //SDL-SVMX-FLS-NOT-ENFORCED-META-DATA
            }
        }  
        system.debug('FieldMappingList'+FieldMappingList.size()+FieldMappingList);
        Set<String> setTargetFields = new Set<String>();
        for(SVMXC__ServiceMax_Config_Data__c obj : FieldMappingList){
            if(obj.SVMXC__Target_Field_Name__c != null){
                setTargetFields.add(obj.SVMXC__Target_Field_Name__c);
            }
        }
        System.debug('setTargetFields: '+setTargetFields);

        //map<String, Schema.SObjectField> mapTargetFieldDesc = new map<String, Schema.SObjectField>();
        Map<String, Schema.DescribeFieldResult> mapFieldNameAndDescResult = new Map<String, Schema.DescribeFieldResult>();

        //if(MapHeader.SVMXC__Target_Object_Name__c != null && Allobj.containskey(MapHeader.SVMXC__Target_Object_Name__c)){
        if(MapHeader.SVMXC__Target_Object_Name__c != null){ // #optiChange
            map<String, Schema.SObjectField> FieldMap = new map<String, Schema.SObjectField>();
           // FieldMap = Allobj.get(MapHeader.SVMXC__Target_Object_Name__c).getDescribe().fields.getMap(); //#optiChange
           FieldMap = COMM_Utils_DescribeCall.getObjectFieldDetails(MapHeader.SVMXC__Target_Object_Name__c);
            if(FieldMap != NULL && !FieldMap.isEmpty()){
                /*for(String s : FieldMap.keyset()){
                    mapTargetFieldDesc.put(FieldMap.get(s).getDescribe().getName(),FieldMap.get(s));
                }*/
                Set<String> setFields = FieldMap.keySet();
                for(String strField: setTargetFields){
                    strField = strField.toLowerCase();
                    if(setFields.contains(strField)){
                        Schema.DescribeFieldResult objDFR = FieldMap.get(strField).getDescribe();
                        mapFieldNameAndDescResult.put(objDFR.getName(), objDFR);
                    }
                }
            }
        }
        System.debug('mapFieldNameAndDescResult: '+mapFieldNameAndDescResult);
        if(SobjList.size() > 0 && FieldMappingList.size() > 0 && mapFieldNameAndDescResult.size() > 0){
            List<RecordType> RecordtypeLst = new List<RecordType>();
            if(MapHeader.SVMXC__Target_Object_Name__c != null)
                
                //Commented this query and added new one which has only required fields queried for the story BAC-4410
                //RecordtypeLst = [Select SystemModstamp, SobjectType, NamespacePrefix, Name, LastModifiedDate, LastModifiedById, IsActive, Id, DeveloperName, Description, CreatedDate, CreatedById, BusinessProcessId From RecordType where SobjectType =: MapHeader.SVMXC__Target_Object_Name__c]; //SDL-SVMX-FLS-NOT-ENFORCED-META-DATA
                RecordtypeLst = [Select Id, Name From RecordType where SobjectType =: MapHeader.SVMXC__Target_Object_Name__c]; //SDL-SVMX-FLS-NOT-ENFORCED-META-DATA
            //If process type is edit process then check for updatable field condition.
            if(strProcessType != null && strProcessType == 'STANDALONE EDIT'){
                for(Integer i=0;i<SobjList.size();i++){
                    for(Integer j = 0;j<FieldMappingList.size();j++){
                        if(FieldMappingList[j].SVMXC__Target_Field_Name__c != null && FieldMappingList[j].SVMXC__Display_Value__c != null && mapFieldNameAndDescResult.containskey(FieldMappingList[j].SVMXC__Target_Field_Name__c)){
                            if(FieldMappingList[j].SVMXC__Target_Field_Name__c == 'RecordTypeId'){
                                String RecordTypeId = '';
                                if(RecordtypeLst.size() > 0){
                                    for(RecordType r : RecordtypeLst){
                                        if(FieldMappingList[j].SVMXC__Display_Value__c != null && r.Name.touppercase() == FieldMappingList[j].SVMXC__Display_Value__c.touppercase())
                                            RecordTypeId = r.id;
                                    }
                                }  
                                if(RecordTypeId != null && RecordTypeId.length() > 0){
                                    SobjList[i].put(FieldMappingList[j].SVMXC__Target_Field_Name__c,RecordTypeId);
                                    mappedFieldsForHeader.add(FieldMappingList[j].SVMXC__Target_Field_Name__c); //Added as part of Story BAC-3257
                                }
                            }
                            else{
                                //Desctibe the field to check differen attributes of fields..
                                Schema.DescribeFieldResult f = mapFieldNameAndDescResult.get(FieldMappingList[j].SVMXC__Target_Field_Name__c);
                                //Check for the Servicemax Constants..
                                if(FieldMappingList[j].SVMXC__Display_Value__c.contains('SVMX.CURRENTRECORD.')){
                                    list<String> lstString = new list<String>();
                                    lstString = FieldMappingList[j].SVMXC__Display_Value__c.split('SVMX.CURRENTRECORD.');
                                    if(lstString.size() > 0){
                                        SobjList[i].put(FieldMappingList[j].SVMXC__Target_Field_Name__c,SobjList[i].get(lstString[1]));
                                        mappedFieldsForHeader.add(FieldMappingList[j].SVMXC__Target_Field_Name__c); //Added as part of Story BAC-3257
                                    }
                                }
                                else if(FieldMappingList[j].SVMXC__Display_Value__c.contains('SVMX.CURRENTRECORDHEADER.')){
                                    list<String> lstString = new list<String>();
                                    lstString = FieldMappingList[j].SVMXC__Display_Value__c.split('SVMX.CURRENTRECORDHEADER.');
                                    if(lstString.size() > 0  && objCurrentRecHeader != null){
                                        SobjList[i].put(FieldMappingList[j].SVMXC__Target_Field_Name__c,objCurrentRecHeader.get(lstString[1]));
                                        mappedFieldsForHeader.add(FieldMappingList[j].SVMXC__Target_Field_Name__c); //Added as part of Story BAC-3257
                                    }
                                }
                                else if(FieldMappingList[j].SVMXC__Display_Value__c.contains('SVMX.CURRENTUSERID')){
                                    SobjList[i].put(FieldMappingList[j].SVMXC__Target_Field_Name__c,userinfo.getUserId());
                                    mappedFieldsForHeader.add(FieldMappingList[j].SVMXC__Target_Field_Name__c); //Added as part of Story BAC-3257
                                }
                                else if(FieldMappingList[j].SVMXC__Display_Value__c.contains('SVMX.USERTRUNK')){
                                    SVMXC.SVMX_Constant_Utils constantUtils = new SVMXC.SVMX_Constant_Utils();
                                    SobjList[i].put(FieldMappingList[j].SVMXC__Target_Field_Name__c,constantUtils.getSVMXUserTrunkId());
                                    mappedFieldsForHeader.add(FieldMappingList[j].SVMXC__Target_Field_Name__c); //Added as part of Story BAC-3257
                                }else if(FieldMappingList[j].SVMXC__Display_Value__c.contains('SVMX.GEOLOCATION.COORDS.LATITUDE') || FieldMappingList[j].SVMXC__Display_Value__c.contains('SVMX.GEOLOCATION.COORDS.LONGITUDE') || FieldMappingList[j].SVMXC__Display_Value__c.contains('SVMX.GEOLOCATION.COORDS.ACCURACY')){ // Added for BAC-4677
                                    //SobjList[i].put(FieldMappingList[j].SVMXC__Target_Field_Name__c,null);
                                    mappedFieldsForHeader.add(FieldMappingList[j].SVMXC__Target_Field_Name__c); //Added as part of Story Added for BAC-4677
                                }else if(FieldMappingList[j].SVMXC__Display_Value__c.contains('SVMX.SETNULL')){ //Added for BAC-5089
                                    mappedFieldsForHeader.add(FieldMappingList[j].SVMXC__Target_Field_Name__c);
                                }
                                else{
                                    if((f.getType() == schema.Displaytype.Double  || f.getType() == schema.Displaytype.Percent || f.getType() == schema.Displaytype.Currency)&& f.isUpdateable()){//if Field Type is Double,persent,currency 
                                        if(double.valueOf(FieldMappingList[j].SVMXC__Display_Value__c) != null ){
                                            SobjList[i].put(FieldMappingList[j].SVMXC__Target_Field_Name__c,double.valueOf(FieldMappingList[j].SVMXC__Display_Value__c));
                                            mappedFieldsForHeader.add(FieldMappingList[j].SVMXC__Target_Field_Name__c); //Added as part of Story BAC-3257
                                        }   
                                    }
                                    else if(f.getType() == schema.Displaytype.Integer && f.isUpdateable()){//if field type is Integer
                                        if(Integer.valueof(FieldMappingList[j].SVMXC__Display_Value__c)!= null){
                                            SobjList[i].put(FieldMappingList[j].SVMXC__Target_Field_Name__c,Integer.valueof(FieldMappingList[j].SVMXC__Display_Value__c));
                                            mappedFieldsForHeader.add(FieldMappingList[j].SVMXC__Target_Field_Name__c); //Added as part of Story BAC-3257
                                        }   
                                    }
                                    else if(f.getType() == schema.Displaytype.Boolean && f.isUpdateable()){//if field type is Boolean
                                        if(Boolean.valueof(FieldMappingList[j].SVMXC__Display_Value__c)!= null){
                                            SobjList[i].put(FieldMappingList[j].SVMXC__Target_Field_Name__c,Boolean.valueof(FieldMappingList[j].SVMXC__Display_Value__c));
                                            mappedFieldsForHeader.add(FieldMappingList[j].SVMXC__Target_Field_Name__c); //Added as part of Story BAC-3257
                                        }   
                                    }
                                    else if(f.getType() == schema.Displaytype.DateTime && f.isUpdateable()){//if field type is DateTime
                                        if(FieldMappingList[j].SVMXC__Display_Value__c.touppercase() == 'TODAY'){
                                            SobjList[i].put(FieldMappingList[j].SVMXC__Target_Field_Name__c,datetime.newInstance(system.today(), time.newInstance(0, 0, 0, 0)));//date.valueof(string.valueof(system.today()))
                                            mappedFieldsForHeader.add(FieldMappingList[j].SVMXC__Target_Field_Name__c); //Added as part of Story BAC-3257
                                        }                                    
                                        else if(FieldMappingList[j].SVMXC__Display_Value__c.touppercase() == 'YESTERDAY'){
                                            SobjList[i].put(FieldMappingList[j].SVMXC__Target_Field_Name__c,datetime.newInstance(system.today()-1, time.newInstance(0, 0, 0, 0)));//date.valueof(string.valueof(system.today()-1))
                                            mappedFieldsForHeader.add(FieldMappingList[j].SVMXC__Target_Field_Name__c); //Added as part of Story BAC-3257
                                        }       
                                        else if(FieldMappingList[j].SVMXC__Display_Value__c.touppercase() == 'TOMORROW'){
                                            SobjList[i].put(FieldMappingList[j].SVMXC__Target_Field_Name__c,datetime.newInstance(system.today()+1, time.newInstance(0, 0, 0, 0)));//date.valueof(string.valueof(system.today()+1))
                                            mappedFieldsForHeader.add(FieldMappingList[j].SVMXC__Target_Field_Name__c); //Added as part of Story BAC-3257
                                        }
                                        else if(FieldMappingList[j].SVMXC__Display_Value__c.touppercase() == 'NOW'){
                                            SobjList[i].put(FieldMappingList[j].SVMXC__Target_Field_Name__c,system.now());
                                            mappedFieldsForHeader.add(FieldMappingList[j].SVMXC__Target_Field_Name__c); //Added as part of Story BAC-3257
                                        }
                                        else{           
                                            SobjList[i].put(FieldMappingList[j].SVMXC__Target_Field_Name__c,DateTime.valueof(FieldMappingList[j].SVMXC__Display_Value__c));
                                            mappedFieldsForHeader.add(FieldMappingList[j].SVMXC__Target_Field_Name__c); //Added as part of Story BAC-3257
                                        }
                                                
                                    }
                                    else if(f.getType() == schema.Displaytype.Date && f.isUpdateable()){//if field type is Date
                                        if(FieldMappingList[j].SVMXC__Display_Value__c.touppercase() == 'TODAY'){
                                            SobjList[i].put(FieldMappingList[j].SVMXC__Target_Field_Name__c,system.today());
                                            mappedFieldsForHeader.add(FieldMappingList[j].SVMXC__Target_Field_Name__c); //Added as part of Story BAC-3257
                                        }   
                                        else if(FieldMappingList[j].SVMXC__Display_Value__c.touppercase() == 'YESTERDAY'){
                                            SobjList[i].put(FieldMappingList[j].SVMXC__Target_Field_Name__c,system.today() - 1);
                                            mappedFieldsForHeader.add(FieldMappingList[j].SVMXC__Target_Field_Name__c); //Added as part of Story BAC-3257
                                        }       
                                        else if(FieldMappingList[j].SVMXC__Display_Value__c.touppercase() == 'TOMORROW'){
                                            SobjList[i].put(FieldMappingList[j].SVMXC__Target_Field_Name__c,system.today() + 1);
                                            mappedFieldsForHeader.add(FieldMappingList[j].SVMXC__Target_Field_Name__c); //Added as part of Story BAC-3257
                                        }
                                        else{           
                                            SobjList[i].put(FieldMappingList[j].SVMXC__Target_Field_Name__c,Date.valueof(FieldMappingList[j].SVMXC__Display_Value__c));
                                            mappedFieldsForHeader.add(FieldMappingList[j].SVMXC__Target_Field_Name__c); //Added as part of Story BAC-3257
                                        }
                                    }else if(f.getType() == schema.Displaytype.Time && f.isUpdateable()){//if field type is Time - Added by Nidhi - BAC-5648
                                        if(FieldMappingList[j].SVMXC__Display_Value__c != null){
                                            Time timeValue = null;
                                            String str = String.valueOf(FieldMappingList[j].SVMXC__Display_Value__c);
                                            list<String> listTimeValue1 = new list<String>();
                                                listTimeValue1 = str.split('\\.');
                                                if(!String.isBlank(str) && listTimeValue1.size()>0){ 
                                                    str = listTimeValue1[0];
                                                    //String miliSec = listTimeValue1[1].removeEndIgnoreCase('z');    
                                                    String miliSec = '0';// Fixing defect BAC-3848
                                                    if(listTimeValue1.size()>1){
                                                        miliSec = listTimeValue1[1].removeEndIgnoreCase('z');    
                                                    }                                                    
                                                    list<String> listTimeValue2 = new list<String>();
                                                    listTimeValue2 = str.split(':');
                                                    timeValue = Time.newInstance(Integer.valueOf(listTimeValue2[0]), Integer.valueOf(listTimeValue2[1]), Integer.valueOf(listTimeValue2[2]),Integer.valueOf(miliSec));
                                                SobjList[i].put(FieldMappingList[j].SVMXC__Target_Field_Name__c,timeValue);
                                                mappedFieldsForHeader.add(FieldMappingList[j].SVMXC__Target_Field_Name__c); //Added as part of Story BAC-3257                                   
                                            } 
                                        }                                       
                                    }
                                    else if(f.getType() == schema.Displaytype.MultiPicklist && f.isUpdateable()){//if field type is MultiPicklist
                                        if(String.valueof(FieldMappingList[j].SVMXC__Display_Value__c) != null){
                                            SobjList[i].put(FieldMappingList[j].SVMXC__Target_Field_Name__c,String.valueof(FieldMappingList[j].SVMXC__Display_Value__c));
                                            mappedFieldsForHeader.add(FieldMappingList[j].SVMXC__Target_Field_Name__c); //Added as part of Story BAC-3257
                                        }
                                    }
                                    else{//else field type is REFERENCE,String 
                                        if((String)FieldMappingList[j].SVMXC__Display_Value__c != null && f.isUpdateable()){
                                            SobjList[i].put(FieldMappingList[j].SVMXC__Target_Field_Name__c,(String)FieldMappingList[j].SVMXC__Display_Value__c);
                                            mappedFieldsForHeader.add(FieldMappingList[j].SVMXC__Target_Field_Name__c); //Added as part of Story BAC-3257
                                        }
                                    }
                                }        
                            }    
                        }   
                    }
                }
            }
            else if(strProcessType == null || strProcessType != 'STANDALONE EDIT'){
                for(Integer i=0;i<SobjList.size();i++){
                    for(Integer j = 0;j<FieldMappingList.size();j++){
                        if(FieldMappingList[j].SVMXC__Target_Field_Name__c != null && FieldMappingList[j].SVMXC__Display_Value__c != null && mapFieldNameAndDescResult.containskey(FieldMappingList[j].SVMXC__Target_Field_Name__c)){
                            if(FieldMappingList[j].SVMXC__Target_Field_Name__c == 'RecordTypeId'){
                                String RecordTypeId = '';
                                if(RecordtypeLst.size() > 0){
                                    for(RecordType r : RecordtypeLst){
                                        if(FieldMappingList[j].SVMXC__Display_Value__c != null && r.Name.touppercase() == FieldMappingList[j].SVMXC__Display_Value__c.touppercase())
                                            RecordTypeId = r.id;
                                    }
                                }  
                                if(RecordTypeId != null && RecordTypeId.length() > 0)
                                    SobjList[i].put(FieldMappingList[j].SVMXC__Target_Field_Name__c,RecordTypeId);
                            }
                            else{
                                system.debug(LoggingLevel.WARN,'Entered Here'+FieldMappingList[j].SVMXC__Target_Field_Name__c+FieldMappingList[j].SVMXC__Display_Value__c);
                                //Desctibe the field to check differen attributes of fields..
                                Schema.DescribeFieldResult f = mapFieldNameAndDescResult.get(FieldMappingList[j].SVMXC__Target_Field_Name__c);
                                //Check for the Servicemax Constants..
                                if(FieldMappingList[j].SVMXC__Display_Value__c.contains('SVMX.CURRENTRECORD.')){
                                    list<String> lstString = new list<String>();
                                    lstString = FieldMappingList[j].SVMXC__Display_Value__c.split('SVMX.CURRENTRECORD.');
                                    if(lstString.size() > 0)
                                        SobjList[i].put(FieldMappingList[j].SVMXC__Target_Field_Name__c,SobjList[i].get(lstString[1]));
                                }
                                else if(FieldMappingList[j].SVMXC__Display_Value__c.contains('SVMX.CURRENTRECORDHEADER.')){
                                    list<String> lstString = new list<String>();
                                    lstString = FieldMappingList[j].SVMXC__Display_Value__c.split('SVMX.CURRENTRECORDHEADER.');
                                    if(lstString.size() > 0  && objCurrentRecHeader != null)
                                        SobjList[i].put(FieldMappingList[j].SVMXC__Target_Field_Name__c,objCurrentRecHeader.get(lstString[1]));
                                }
                                else if(FieldMappingList[j].SVMXC__Display_Value__c.contains('SVMX.CURRENTUSERID')){
                                    SobjList[i].put(FieldMappingList[j].SVMXC__Target_Field_Name__c,userinfo.getUserId());
                                }
                                else if(FieldMappingList[j].SVMXC__Display_Value__c.contains('SVMX.USERTRUNK')){
                                    SVMXC.SVMX_Constant_Utils constantUtils = new SVMXC.SVMX_Constant_Utils();
                                    SobjList[i].put(FieldMappingList[j].SVMXC__Target_Field_Name__c,constantUtils.getSVMXUserTrunkId());
                                }else if(FieldMappingList[j].SVMXC__Display_Value__c.contains('SVMX.GEOLOCATION.COORDS.LATITUDE') || FieldMappingList[j].SVMXC__Display_Value__c.contains('SVMX.GEOLOCATION.COORDS.LONGITUDE') || FieldMappingList[j].SVMXC__Display_Value__c.contains('SVMX.GEOLOCATION.COORDS.ACCURACY') || FieldMappingList[j].SVMXC__Display_Value__c.contains('SVMX.SETNULL')){ // Added for BAC-4677, BAC-5089
                                    //SobjList[i].put(FieldMappingList[j].SVMXC__Target_Field_Name__c,null);
                                    
                                }
                                else
                                {
                                    if((f.getType() == schema.Displaytype.Double  || f.getType() == schema.Displaytype.Percent || f.getType() == schema.Displaytype.Currency)&& f.isCreateable()){//if Field Type is Double,persent,currency
                                        if(double.valueOf(FieldMappingList[j].SVMXC__Display_Value__c) != null ){
                                            SobjList[i].put(FieldMappingList[j].SVMXC__Target_Field_Name__c,double.valueOf(FieldMappingList[j].SVMXC__Display_Value__c));
                                        }   
                                    }
                                    else if(f.getType() == schema.Displaytype.Integer && f.isCreateable()){//if field type is Integer
                                        if(Integer.valueof(FieldMappingList[j].SVMXC__Display_Value__c)!= null){
                                            SobjList[i].put(FieldMappingList[j].SVMXC__Target_Field_Name__c,Integer.valueof(FieldMappingList[j].SVMXC__Display_Value__c));
                                        }   
                                    }
                                    else if(f.getType() == schema.Displaytype.Boolean && f.isCreateable()){//if field type is Boolean
                                        if(Boolean.valueof(FieldMappingList[j].SVMXC__Display_Value__c)!= null){
                                            SobjList[i].put(FieldMappingList[j].SVMXC__Target_Field_Name__c,Boolean.valueof(FieldMappingList[j].SVMXC__Display_Value__c));
                                        }   
                                    }
                                    else if(f.getType() == schema.Displaytype.DateTime && f.isCreateable()){//if field type is DateTime
                                        if(FieldMappingList[j].SVMXC__Display_Value__c.touppercase() == 'TODAY'){
                                            SobjList[i].put(FieldMappingList[j].SVMXC__Target_Field_Name__c,datetime.newInstance(system.today(), time.newInstance(0, 0, 0, 0)));//date.valueof(string.valueof(system.today()))
                                        }                                    
                                        else if(FieldMappingList[j].SVMXC__Display_Value__c.touppercase() == 'YESTERDAY'){
                                            SobjList[i].put(FieldMappingList[j].SVMXC__Target_Field_Name__c,datetime.newInstance(system.today()-1, time.newInstance(0, 0, 0, 0)));//date.valueof(string.valueof(system.today()-1))
                                        }       
                                        else if(FieldMappingList[j].SVMXC__Display_Value__c.touppercase() == 'TOMORROW'){
                                            SobjList[i].put(FieldMappingList[j].SVMXC__Target_Field_Name__c,datetime.newInstance(system.today()+1, time.newInstance(0, 0, 0, 0)));//date.valueof(string.valueof(system.today()+1))
                                        }
                                        else if(FieldMappingList[j].SVMXC__Display_Value__c.touppercase() == 'NOW'){
                                            SobjList[i].put(FieldMappingList[j].SVMXC__Target_Field_Name__c,system.now());
                                        }
                                        else{           
                                            SobjList[i].put(FieldMappingList[j].SVMXC__Target_Field_Name__c,DateTime.valueof(FieldMappingList[j].SVMXC__Display_Value__c));
                                        }
                                    }
                                    else if(f.getType() == schema.Displaytype.Date && f.isCreateable()){//if field type is Date
                                        if(FieldMappingList[j].SVMXC__Display_Value__c.touppercase() == 'TODAY'){
                                            SobjList[i].put(FieldMappingList[j].SVMXC__Target_Field_Name__c,system.today());
                                        }   
                                        else if(FieldMappingList[j].SVMXC__Display_Value__c.touppercase() == 'YESTERDAY'){
                                            SobjList[i].put(FieldMappingList[j].SVMXC__Target_Field_Name__c,system.today() - 1);
                                        }       
                                        else if(FieldMappingList[j].SVMXC__Display_Value__c.touppercase() == 'TOMORROW'){
                                            SobjList[i].put(FieldMappingList[j].SVMXC__Target_Field_Name__c,system.today() + 1);
                                        }
                                        else{           
                                            SobjList[i].put(FieldMappingList[j].SVMXC__Target_Field_Name__c,Date.valueof(FieldMappingList[j].SVMXC__Display_Value__c));
                                        }
                                    }else if(f.getType() == schema.Displaytype.Time && f.isCreateable()){//if field type is Time - Added by Nidhi - BAC-5648
                                        if(FieldMappingList[j].SVMXC__Display_Value__c != null){
                                            Time timeValue = null;
                                            String str = String.valueOf(FieldMappingList[j].SVMXC__Display_Value__c);
                                            list<String> listTimeValue1 = new list<String>();
                                            listTimeValue1 = str.split('\\.');
                                            if(!String.isBlank(str) && listTimeValue1.size()>0){ 
                                                str = listTimeValue1[0];
                                                //String miliSec = listTimeValue1[1].removeEndIgnoreCase('z');
                                                String miliSec = '0';// Fixing defect BAC-3848
                                                if(listTimeValue1.size()>1){
                                                    miliSec = listTimeValue1[1].removeEndIgnoreCase('z');    
                                                }                                                  
                                                list<String> listTimeValue2 = new list<String>();
                                                listTimeValue2 = str.split(':');
                                                timeValue = Time.newInstance(Integer.valueOf(listTimeValue2[0]), Integer.valueOf(listTimeValue2[1]), Integer.valueOf(listTimeValue2[2]),Integer.valueOf(miliSec));
                                                SobjList[i].put(FieldMappingList[j].SVMXC__Target_Field_Name__c,timeValue);
                                            } 
                                        }                                       
                                    }
                                    else if(f.getType() == schema.Displaytype.MultiPicklist && f.isCreateable()){//if field type is MultiPicklist
                                        if(String.valueof(FieldMappingList[j].SVMXC__Display_Value__c) != null){
                                            SobjList[i].put(FieldMappingList[j].SVMXC__Target_Field_Name__c,String.valueof(FieldMappingList[j].SVMXC__Display_Value__c));
                                        }
                                    }
                                    else{ //else field type is REFERENCE,String 
                                        if((String)FieldMappingList[j].SVMXC__Display_Value__c != null && f.isCreateable()){
                                            SobjList[i].put(FieldMappingList[j].SVMXC__Target_Field_Name__c,(String)FieldMappingList[j].SVMXC__Display_Value__c);
                                        }
                                    }   
                                }
                            }    
                        }   
                    }
                }
            }
        }
        system.debug('SobjList: '+SobjList);
        return SobjList;
    }
    public list<SVMXC.SFM_WrapperDef.SFM_ObjectMapInfo> SFM_CreateMetaDataForFormFill(set<Id> setMapId){
        
        //Query Mapping records 
        list<SVMXC.SFM_WrapperDef.SFM_ObjectMapInfo> lstObjectMapInfo = new list<SVMXC.SFM_WrapperDef.SFM_ObjectMapInfo>(); 
        map<Id,list<SVMXC__ServiceMax_Config_Data__c>> mapObjMapIdFldMapList = new map<Id,list<SVMXC__ServiceMax_Config_Data__c>>();
        map<Id, SVMXC__ServiceMax_Processes__c> mapHeaderRecords = new map<Id, SVMXC__ServiceMax_Processes__c>();
        
        mapHeaderRecords.putall([select Id, Name, SVMXC__MapID__c, SVMXC__Name__c, SVMXC__Source_Object_Name__c, SVMXC__Target_Object_Name__c, SVMXC__Target_Record_Type__c, SVMXC__Description__c, SVMXC__IsStandard__c, SVMXC__Active__c From SVMXC__ServiceMax_Processes__c where RecordType.Name = 'Object Mapping' and Id IN : setMapId]); //SDL-SVMX-FLS-NOT-ENFORCED-META-DATA
        if(mapHeaderRecords.size() > 0){
            
            list<SVMXC__ServiceMax_Config_Data__c> lstFieldMapping = [select Id, SVMXC__Source_Field_Name__c, SVMXC__Target_Field_Name__c, SVMXC__Preference_2__c, SVMXC__Preference_3__c, SVMXC__Display_Value__c, SVMXC__Internal_Value__c, SVMXC__MapID__c, SVMXC__Configuration_Type__c From SVMXC__ServiceMax_Config_Data__c where RecordType.Name = 'Field Mapping' and SVMXC__Configuration_Type__c = 'Field Mapping' and SVMXC__MapID__c IN : mapHeaderRecords.keyset()]; //SDL-SVMX-FLS-NOT-ENFORCED-META-DATA
            if(lstFieldMapping.size() > 0){
                for(SVMXC__ServiceMax_Config_Data__c fldMapRec : lstFieldMapping){
                    if(!mapObjMapIdFldMapList.containskey(fldMapRec.SVMXC__MapID__c))
                        mapObjMapIdFldMapList.put(fldMapRec.SVMXC__MapID__c,new list<SVMXC__ServiceMax_Config_Data__c>());
                    mapObjMapIdFldMapList.get(fldMapRec.SVMXC__MapID__c).add(fldMapRec);  
                }
            }
            if(mapObjMapIdFldMapList.size() > 0){
                for(Id i : mapObjMapIdFldMapList.keyset()){
                    if(mapHeaderRecords.containskey(i)){
                        list<SVMXC.SFM_WrapperDef.SFM_FieldMapping> lstSFM_FieldMapping = new list<SVMXC.SFM_WrapperDef.SFM_FieldMapping>();
                        for(SVMXC__ServiceMax_Config_Data__c configData : mapObjMapIdFldMapList.get(i)){
                            SVMXC.SFM_WrapperDef.SFM_FieldMapping fldMapping = new SVMXC.SFM_WrapperDef.SFM_FieldMapping(configData,null);
                            lstSFM_FieldMapping.add(fldMapping);
                        }
                        SVMXC.SFM_WrapperDef.SFM_ObjectMap objectMap =  new SVMXC.SFM_WrapperDef.SFM_ObjectMap(mapHeaderRecords.get(i),lstSFM_FieldMapping);
                        SVMXC.SFM_WrapperDef.SFM_ObjectMapInfo objectMapInfo = new SVMXC.SFM_WrapperDef.SFM_ObjectMapInfo(i,objectMap);
                        lstObjectMapInfo.add(objectMapInfo);
                    }
                }
            }
        }
        system.debug(LoggingLevel.WARN,'lstObjectMapInfo'+lstObjectMapInfo);
        return lstObjectMapInfo;
    }
    
    //Added for supporting SMART OBJECT. This method is generic can support both SFDC and SMART OBJECT
    public map<String,Object> applyObjectMapping(String mapUniqueID, Map<Object,Object> SourceRecIdTargetObjMap, Map<String,Object> AdditionalParams)
    {
        Map<String,Map<String,Object>> SourceRecIdTargetObjMap_NEW = new Map<String,Map<String,Object>>();
        map<String, Schema.SObjectField> mapTargetFieldDesc = new map<String, Schema.SObjectField>();
        map<String, Schema.SObjectField> mapSourceFieldDesc = new map<String, Schema.SObjectField>();
        map<String, SmartObject.SmartObjectField> mapTargetFieldDesc_SMART = new map<String, SmartObject.SmartObjectField>();
        map<String, Schema.SObjectField> FieldMap = new map<String, Schema.SObjectField>();
        map<String,Object> mapFinalSourceRecIdTargetObj = new map<String,Object>();
        Set<String> SourceRecIds = new Set<String>();
        map<String,Sobject> SourceRecMap = new map<String,Sobject>(); 
        String strSourceObjName = '';
        String strTargetObjName = '';
        Boolean isTargetObjectSFDCObject = false;
        Boolean DoPopulateOwner = false;
        Map<String,Schema.SObjectType> AllSFDCObj = new Map<String,Schema.SObjectType>();
        Map<String,SmartObject.DescribeSmartObjectResult> AllSMARTObj  = new Map<String,SmartObject.DescribeSmartObjectResult>();
        
        //checking for data is there or not...if it is not there we are populating those variables (AllSFDCObj, AllSMARTObj...)
        if(AdditionalParams != null){
            if(AdditionalParams.containsKey('DoPopulateOwner') && AdditionalParams.get('DoPopulateOwner') != null && AdditionalParams.get('DoPopulateOwner') == 'true')
                DoPopulateOwner = true;
            if(AdditionalParams.containsKey('GetGlobalDescribe') && AdditionalParams.get('GetGlobalDescribe') != null)
                AllSFDCObj = (Map<String,Schema.SObjectType>) AdditionalParams.get('GetGlobalDescribe');
            else{
                Map<String, Schema.SObjectType> gd = Schema.getGlobalDescribe();
                if(gd.size() > 0){
                    for(Schema.SObjectType s : gd.values()){
                        Schema.DescribeSObjectResult result = s.getDescribe();
                        AllSFDCObj.put(result.getName(),s);
                    }
                }
            }
            if(AdditionalParams.containsKey('GetSmartObjectDescribe') && AdditionalParams.get('GetSmartObjectDescribe') != null)
                AllSMARTObj = (Map<String,SmartObject.DescribeSmartObjectResult>) AdditionalParams.get('GetSmartObjectDescribe');
            else
                AllSMARTObj = SmartObject.getGlobalDescribe();
            
        }
        
        
        for(Object key : SourceRecIdTargetObjMap.keyset()){
            Map<String, Object> mapSobject = new Map<String, Object>();
            Object genericObject = SourceRecIdTargetObjMap.get(key);
            //checking for generic Object is Smart object or not
            if(genericObject != null && genericObject instanceof SmartObject.SmartObjectRecord){
                SmartObject.SmartObjectRecord tempSmartObjectRecord = (SmartObject.SmartObjectRecord)genericObject;
                mapSobject = tempSmartObjectRecord.mapTargetRecordFieldValues;
            }
            //checking for generic Object is SFDC object or not
            else if(genericObject != null && genericObject instanceof SObject){
                SObject tempSObject = (SObject)genericObject;
                mapSobject = (Map<String, Object>) JSON.deserializeUntyped(JSON.serialize(tempSObject));
            }
            //checking key is Id or not in the map SourceRecIdTargetObjMap
            if(key instanceof String){
                SourceRecIds.add((String)key);
                SourceRecIdTargetObjMap_NEW.put((String)key, mapSobject);
            }
            //checking key is Sobject or not in the map SourceRecIdTargetObjMap
            else if(key instanceof SObject){
                SObject tempSObject1 = (SObject)key;
                SourceRecIdTargetObjMap_NEW.put((String)tempSObject1.get('Id'), mapSobject);
            }
        }
        System.debug(LoggingLevel.WARN, 'SourceRecIds'+SourceRecIds);
        System.debug(LoggingLevel.WARN, 'SourceRecIdTargetObjMap_NEW :'+SourceRecIdTargetObjMap_NEW);
        
        //querying header information of mapping
        if(mapUniqueID != null){
            SVMXC__ServiceMax_Processes__c MapHeader = new SVMXC__ServiceMax_Processes__c();
            
            MapHeader = [Select Id, SVMXC__Target_Object_Name__c, SVMXC__Source_Object_Name__c From SVMXC__ServiceMax_Processes__c  where SVMXC__MapID__c =: mapUniqueID]; //SDL-SVMX-FLS-NOT-ENFORCED-META-DATA
            strSourceObjName = MapHeader.SVMXC__Source_Object_Name__c;
            strTargetObjName = MapHeader.SVMXC__Target_Object_Name__c;
        }
        //checking source object is valid SFDC object or not
        if(strSourceObjName != null && !AllSFDCObj.containsKey(strSourceObjName)){
            System.debug('Error : Source object as other than SFDC are not supported');
            return null;
        }
        if(strTargetObjName != null && AllSFDCObj.containsKey(strTargetObjName))
            isTargetObjectSFDCObject = true;
        
        System.debug(LoggingLevel.WARN, 'strSourceObjName : '+strSourceObjName);
        System.debug(LoggingLevel.WARN, 'strTargetObjName : '+strTargetObjName);
        
        List<SVMXC__ServiceMax_Config_Data__c> FieldMappingList = new List<SVMXC__ServiceMax_Config_Data__c>(); 
        System.debug(LoggingLevel.WARN, 'mapUniqueID : '+mapUniqueID);
        //querying configData of mapping on basis of mapping id
        if(mapUniqueID != null && mapUniqueID.length() > 0){
            if(Userinfo.isMultiCurrencyOrganization())
                
                FieldMappingList = [Select SVMXC__Target_Field_Name__c, SVMXC__Source_Field_Name__c, SVMXC__Preference_3__c, SVMXC__Preference_2__c, SVMXC__MapID__c, SVMXC__Internal_Value__c, SVMXC__Display_Value__c, SVMXC__Configuration_Type__c,SVMXC__Active__c, RecordTypeId, Name, Id From SVMXC__ServiceMax_Config_Data__c where SVMXC__MapID__r.SVMXC__MapID__c =: mapUniqueID]; //SDL-SVMX-FLS-NOT-ENFORCED-META-DATA
            else
                
                FieldMappingList = [Select  SVMXC__Target_Field_Name__c, SVMXC__Source_Field_Name__c, SVMXC__Preference_3__c, SVMXC__Preference_2__c, SVMXC__MapID__c, SVMXC__Internal_Value__c, SVMXC__Display_Value__c, SVMXC__Configuration_Type__c,SVMXC__Active__c, RecordTypeId, Name, Id From SVMXC__ServiceMax_Config_Data__c where SVMXC__MapID__r.SVMXC__MapID__c =: mapUniqueID and SVMXC__Target_Field_Name__c != 'CurrencyIsoCode'];  //SDL-SVMX-FLS-NOT-ENFORCED-META-DATA 
        }
        System.debug(LoggingLevel.WARN, 'FieldMappingList : '+FieldMappingList.size()+FieldMappingList);
        
        Set<String> TargetFieldsSet = new Set<String>(); 
        //creating a set of target fields from configData
        if(!(FieldMappingList.isEmpty())){
            for(SVMXC__ServiceMax_Config_Data__c configData : FieldMappingList){
                if(configData.SVMXC__Target_Field_Name__c != null)
                    TargetFieldsSet.add(configData.SVMXC__Target_Field_Name__c);
            }
        }
        System.debug(LoggingLevel.WARN, 'TargetFieldsSet : '+TargetFieldsSet);
        
        //creating a map of name and describe of field
        if(strSourceObjName != null){
            map<String, Schema.SObjectField> LFieldMap1 = new map<String, Schema.SObjectField>();
            LFieldMap1 = AllSFDCObj.get(strSourceObjName).getDescribe().fields.getMap();
            if(LFieldMap1.size() > 0){
                for(String s : LFieldMap1.keyset()){
                    mapSourceFieldDesc.put(LFieldMap1.get(s).getDescribe().getName(),LFieldMap1.get(s));
                }
            }
        }
        System.debug(LoggingLevel.WARN, 'mapSourceFieldDesc : '+mapSourceFieldDesc);
        
        //Get the Target object Fields for SFDC object
        if(isTargetObjectSFDCObject){
            map<String, Schema.SObjectField> LFieldMap = new map<String, Schema.SObjectField>();
            LFieldMap = AllSFDCObj.get(strTargetObjName).getDescribe().fields.getMap();
            if(LFieldMap.size() > 0){
                for(String s : LFieldMap.keyset()){
                    mapTargetFieldDesc.put(LFieldMap.get(s).getDescribe().getName(),LFieldMap.get(s));
                }
            }
        }
        else if(strTargetObjName != null && AllSMARTObj != null && AllSMARTObj.size()>0 && AllSMARTObj.containskey(strTargetObjName)){//Get the Target object Fields for SMART Object
            map<String, SmartObject.SmartObjectField> mapTargetFieldMap = new map<String, SmartObject.SmartObjectField>();
            mapTargetFieldMap = AllSMARTObj.get(strTargetObjName).getFieldMap();
            if(mapTargetFieldMap.size() > 0){
                for(String s : mapTargetFieldMap.keyset()){
                    mapTargetFieldDesc_SMART.put(mapTargetFieldMap.get(s).getDescribe().getName(),mapTargetFieldMap.get(s));
                }
            }
        }
        System.debug(LoggingLevel.WARN, 'mapTargetFieldDesc : '+mapTargetFieldDesc);
        System.debug(LoggingLevel.WARN, 'mapTargetFieldDesc_SMART : '+mapTargetFieldDesc_SMART);
        
        //Get the Source Records on the basis of source record id...
        if(strSourceObjName != null && SourceRecIds != null && SourceRecIds.size() > 0){
            List<String> fieldlist = new List<String>();
            string fields = '';
            FieldMap = AllSFDCObj.get(strSourceObjName).getDescribe().fields.getMap();
            if(FieldMap.size() > 0)
                fieldlist = commutils.SVMX_getFieldList(FieldMap,true);
            if(fieldlist.size() > 0)
                fields = commutils.SVMX_getFieldNamesFromList(fieldlist);
           system.debug('fields'+fields);  
            if(fields != null && fields.length() > 0){
                String Query = 'Select ' + fields + ' from ' + strSourceObjName + ' where id  IN : SourceRecIds';     //= ' +  '\''+SourceRecId+'\'';
                system.debug('Query'+Query);
                SourceRecMap.putall(Database.query(Query));
            }
        }
        System.debug(LoggingLevel.WARN, 'SourceRecMap After Database query: '+SourceRecMap);
        
        //if source record is send in the map SourceRecIdTargetObjMap not ID then we are putting this source record in the SourceRecMap
        for(Object key : SourceRecIdTargetObjMap.keyset()){
            if(key instanceof SObject){
                SObject tempSObject1 = (SObject)key;
                SourceRecMap.put((String)tempSObject1.get('Id'), tempSObject1);
            }
        }
        
        if(SourceRecIdTargetObjMap_NEW.size() > 0 && FieldMappingList.size() > 0){
            List<RecordType> RecordtypeLst = new List<RecordType>();
            //querying record types only when target object is SFDC object
            if(isTargetObjectSFDCObject)
                
                RecordtypeLst = [Select SystemModstamp, SobjectType, NamespacePrefix, Name, LastModifiedDate, LastModifiedById, IsActive, Id, DeveloperName, Description, CreatedDate, CreatedById, BusinessProcessId From RecordType where SobjectType =: strTargetObjName]; //SDL-SVMX-FLS-NOT-ENFORCED-META-DATA
                System.debug(LoggingLevel.WARN, 'RecordtypeLst : '+RecordtypeLst);
            
            //here we are traversing on the basis of source record id and creating target object and putting that object in the result map
            for(String s1 : SourceRecIdTargetObjMap_NEW.keyset()){
                Map<String,Object> mapOfTargetObject = SourceRecIdTargetObjMap_NEW.get(s1);
                Sobject SourceObjRecord;
                if(SourceRecMap.size() > 0 && SourceRecMap.containskey(s1))
                    SourceObjRecord = SourceRecMap.get(s1);
                System.debug(LoggingLevel.WARN, 'SourceObjRecord : '+SourceObjRecord);

                if(isTargetObjectSFDCObject && DoPopulateOwner && TargetFieldsSet.size() > 0 && TargetFieldsSet.contains('OwnerId') == false && mapTargetFieldDesc.containskey('OwnerId') && mapOfTargetObject.containsKey('OwnerId'))
                    mapOfTargetObject.put('OwnerId',Userinfo.getUserId());
                
                //checking for the value map
                if(strSourceObjName == null){
                    for(Integer j = 0;j<FieldMappingList.size();j++){
                        if(FieldMappingList[j].SVMXC__Target_Field_Name__c != null && FieldMappingList[j].SVMXC__Display_Value__c != null && (mapTargetFieldDesc.containskey(FieldMappingList[j].SVMXC__Target_Field_Name__c) || mapTargetFieldDesc_SMART.containskey(FieldMappingList[j].SVMXC__Target_Field_Name__c))){
                            Schema.DescribeFieldResult f_SFDC;
                            SmartObject.DescribeSmartFieldResult f_SMART;
                            if(isTargetObjectSFDCObject)
                                f_SFDC = mapTargetFieldDesc.get(FieldMappingList[j].SVMXC__Target_Field_Name__c).getDescribe();
                            else
                                f_SMART = mapTargetFieldDesc_SMART.get(FieldMappingList[j].SVMXC__Target_Field_Name__c).getDescribe();
                            
                            if((isTargetObjectSFDCObject && f_SFDC.getType() == schema.Displaytype.DateTime && f_SFDC.isCreateable()) || (isTargetObjectSFDCObject == false && f_SMART.getType().toUppercase() == 'DATETIME')){    //if field type is DateTime
                                if(FieldMappingList[j].SVMXC__Display_Value__c.touppercase() == 'TODAY')
                                    mapOfTargetObject.put(FieldMappingList[j].SVMXC__Target_Field_Name__c,datetime.newInstance(system.today(), time.newInstance(0, 0, 0, 0)));
                                else if(FieldMappingList[j].SVMXC__Display_Value__c.touppercase() == 'YESTERDAY')
                                    mapOfTargetObject.put(FieldMappingList[j].SVMXC__Target_Field_Name__c,datetime.newInstance(system.today()-1, time.newInstance(0, 0, 0, 0)));    
                                else if(FieldMappingList[j].SVMXC__Display_Value__c.touppercase() == 'TOMORROW')
                                    mapOfTargetObject.put(FieldMappingList[j].SVMXC__Target_Field_Name__c,datetime.newInstance(system.today()+1, time.newInstance(0, 0, 0, 0)));
                                else if(FieldMappingList[j].SVMXC__Display_Value__c.touppercase() == 'NOW')
                                    mapOfTargetObject.put(FieldMappingList[j].SVMXC__Target_Field_Name__c,system.now());
                                else
                                    mapOfTargetObject.put(FieldMappingList[j].SVMXC__Target_Field_Name__c,DateTime.valueof(FieldMappingList[j].SVMXC__Display_Value__c));
                            }
                            else if((isTargetObjectSFDCObject && f_SFDC.getType() == schema.Displaytype.Date && f_SFDC.isCreateable()) || (isTargetObjectSFDCObject == false && f_SMART.getType().toUppercase() == 'DATE')){    //if field type is Date
                                if(FieldMappingList[j].SVMXC__Display_Value__c.touppercase() == 'TODAY')
                                    mapOfTargetObject.put(FieldMappingList[j].SVMXC__Target_Field_Name__c,system.today());
                                else if(FieldMappingList[j].SVMXC__Display_Value__c.touppercase() == 'YESTERDAY')
                                    mapOfTargetObject.put(FieldMappingList[j].SVMXC__Target_Field_Name__c,system.today() - 1);    
                                else if(FieldMappingList[j].SVMXC__Display_Value__c.touppercase() == 'TOMORROW')
                                    mapOfTargetObject.put(FieldMappingList[j].SVMXC__Target_Field_Name__c,system.today() + 1);
                                else
                                    mapOfTargetObject.put(FieldMappingList[j].SVMXC__Target_Field_Name__c,Date.valueof(FieldMappingList[j].SVMXC__Display_Value__c));
                            }
                            else
                                mapOfTargetObject.put(FieldMappingList[j].SVMXC__Target_Field_Name__c,FieldMappingList[j].SVMXC__Display_Value__c);
                        }
                    }
                }
                //checking for Field Map
                if(strSourceObjName != null){
                    for(Integer j = 0;j<FieldMappingList.size();j++){
                        if(FieldMappingList[j].SVMXC__Target_Field_Name__c != null && (mapTargetFieldDesc.containskey(FieldMappingList[j].SVMXC__Target_Field_Name__c) || mapTargetFieldDesc_SMART.containskey(FieldMappingList[j].SVMXC__Target_Field_Name__c))){
                            Schema.DescribeFieldResult sourceObjectDescribe;
                            Schema.DescribeFieldResult Preference_2ObjectDescribe;
                            Schema.DescribeFieldResult Preference_3ObjectDescribe;
                            if(FieldMappingList[j].SVMXC__Source_Field_Name__c != null && mapSourceFieldDesc.containskey(FieldMappingList[j].SVMXC__Source_Field_Name__c))
                                sourceObjectDescribe = mapSourceFieldDesc.get(FieldMappingList[j].SVMXC__Source_Field_Name__c).getDescribe();
                            if(FieldMappingList[j].SVMXC__Preference_2__c != null && mapSourceFieldDesc.containskey(FieldMappingList[j].SVMXC__Preference_2__c))
                                Preference_2ObjectDescribe = mapSourceFieldDesc.get(FieldMappingList[j].SVMXC__Preference_2__c).getDescribe();
                            if(FieldMappingList[j].SVMXC__Preference_3__c != null && mapSourceFieldDesc.containskey(FieldMappingList[j].SVMXC__Preference_3__c))
                                Preference_3ObjectDescribe = mapSourceFieldDesc.get(FieldMappingList[j].SVMXC__Preference_3__c).getDescribe();
                            
                            //Describe the field to check different attributes of fields..
                            Schema.DescribeFieldResult f_SFDC;
                            SmartObject.DescribeSmartFieldResult f_SMART;
                            
                            if(isTargetObjectSFDCObject)
                                f_SFDC = mapTargetFieldDesc.get(FieldMappingList[j].SVMXC__Target_Field_Name__c).getDescribe();
                            else
                                f_SMART = mapTargetFieldDesc_SMART.get(FieldMappingList[j].SVMXC__Target_Field_Name__c).getDescribe();
                            
                            if(isTargetObjectSFDCObject && FieldMappingList[j].SVMXC__Target_Field_Name__c == 'RecordTypeId' && f_SFDC.isCreateable()){
                                if(FieldMappingList[j].SVMXC__Display_Value__c != null){
                                    String RecordTypeId = '';
                                    if(RecordtypeLst.size() > 0){ 
                                        for(RecordType r : RecordtypeLst){
                                            if(FieldMappingList[j].SVMXC__Display_Value__c != null && r.Name.touppercase() == FieldMappingList[j].SVMXC__Display_Value__c.touppercase())
                                                RecordTypeId = r.id;
                                        }
                                    } 
                                    if(RecordTypeId != null && RecordTypeId.length() > 0)
                                        mapOfTargetObject.put(FieldMappingList[j].SVMXC__Target_Field_Name__c,RecordTypeId);
                                }
                                else if(FieldMappingList[j].SVMXC__Source_Field_Name__c != null && SourceObjRecord.get(FieldMappingList[j].SVMXC__Source_Field_Name__c) != null)
                                    mapOfTargetObject.put(FieldMappingList[j].SVMXC__Target_Field_Name__c,SourceObjRecord.get(FieldMappingList[j].SVMXC__Source_Field_Name__c));
                            }
                            else if((isTargetObjectSFDCObject && FieldMappingList[j].SVMXC__Target_Field_Name__c != 'RecordTypeId' && f_SFDC.isCreateable()) || isTargetObjectSFDCObject == false){
                                String strTargetFieldDataType = '';
                                if(f_SFDC != null)
                                    strTargetFieldDataType = String.valueOf(f_SFDC.getType());
                                //checking source field has value or not
                                if(FieldMappingList[j].SVMXC__Source_Field_Name__c != null && String.valueof(SourceObjRecord.get(FieldMappingList[j].SVMXC__Source_Field_Name__c)) != null){
                                    String strSourceFieldDataType = '';
                                    if(sourceObjectDescribe != null)
                                        strSourceFieldDataType = String.valueOf(sourceObjectDescribe.getType());
                                    //this condition is for handling serialization issue when source and target objects are SFDC objects
                                    if(strTargetFieldDataType.toUppercase() == 'DATE' && strSourceFieldDataType.toUppercase() == 'DATETIME')
                                        mapOfTargetObject.put(FieldMappingList[j].SVMXC__Target_Field_Name__c, Date.valueOf(SourceObjRecord.get(FieldMappingList[j].SVMXC__Source_Field_Name__c)));
                                    else
                                        mapOfTargetObject.put(FieldMappingList[j].SVMXC__Target_Field_Name__c, SourceObjRecord.get(FieldMappingList[j].SVMXC__Source_Field_Name__c));
                                }
                                //checking preference 2 field has value or not
                                else if(FieldMappingList[j].SVMXC__Source_Field_Name__c != null && String.valueof(SourceObjRecord.get(FieldMappingList[j].SVMXC__Source_Field_Name__c)) == null && FieldMappingList[j].SVMXC__Preference_2__c != null && String.valueof(SourceObjRecord.get(FieldMappingList[j].SVMXC__Preference_2__c)) != null){
                                    String strSourceFieldDataType = '';
                                    if(Preference_2ObjectDescribe != null)
                                        strSourceFieldDataType = String.valueOf(Preference_2ObjectDescribe.getType());
                                    //this condition is for handling serialization issue when source and target objects are SFDC objects
                                    if(strTargetFieldDataType.toUppercase() == 'DATE' && strSourceFieldDataType.toUppercase() == 'DATETIME')
                                        mapOfTargetObject.put(FieldMappingList[j].SVMXC__Target_Field_Name__c, Date.valueOf(SourceObjRecord.get(FieldMappingList[j].SVMXC__Preference_2__c)));
                                    else
                                        mapOfTargetObject.put(FieldMappingList[j].SVMXC__Target_Field_Name__c, SourceObjRecord.get(FieldMappingList[j].SVMXC__Preference_2__c));
                                }
                                //checking preference 3 field has value or not
                                else if(FieldMappingList[j].SVMXC__Source_Field_Name__c != null && String.valueof(SourceObjRecord.get(FieldMappingList[j].SVMXC__Source_Field_Name__c)) == null && FieldMappingList[j].SVMXC__Preference_2__c != null && String.valueof(SourceObjRecord.get(FieldMappingList[j].SVMXC__Preference_2__c)) == null && FieldMappingList[j].SVMXC__Preference_3__c != null && String.valueof(SourceObjRecord.get(FieldMappingList[j].SVMXC__Preference_3__c)) != null){
                                    String strSourceFieldDataType = '';
                                    if(Preference_3ObjectDescribe != null)
                                        strSourceFieldDataType = String.valueOf(Preference_3ObjectDescribe.getType());
                                    //this condition is for handling serialization issue when source and target objects are SFDC objects
                                    if(strTargetFieldDataType.toUppercase() == 'DATE' && strSourceFieldDataType.toUppercase() == 'DATETIME')
                                        mapOfTargetObject.put(FieldMappingList[j].SVMXC__Target_Field_Name__c, Date.valueOf(SourceObjRecord.get(FieldMappingList[j].SVMXC__Preference_3__c)));
                                    else
                                        mapOfTargetObject.put(FieldMappingList[j].SVMXC__Target_Field_Name__c, SourceObjRecord.get(FieldMappingList[j].SVMXC__Preference_3__c));
                                }
                                if(FieldMappingList[j].SVMXC__Source_Field_Name__c  == null && FieldMappingList[j].SVMXC__Preference_2__c == null  && FieldMappingList[j].SVMXC__Preference_3__c == null && FieldMappingList[j].SVMXC__Display_Value__c != null && (mapTargetFieldDesc.containskey(FieldMappingList[j].SVMXC__Target_Field_Name__c) || mapTargetFieldDesc_SMART.containskey(FieldMappingList[j].SVMXC__Target_Field_Name__c))){
                                    if((isTargetObjectSFDCObject && (f_SFDC.getType() == schema.Displaytype.Double  || f_SFDC.getType() == schema.Displaytype.Percent || f_SFDC.getType() == schema.Displaytype.Currency)) || (isTargetObjectSFDCObject == false && f_SMART.getType().toUppercase() == 'DOUBLE')){  //if Field Type is Double,percent,currency
                                        if(double.valueOf(FieldMappingList[j].SVMXC__Display_Value__c) != null )
                                            mapOfTargetObject.put(FieldMappingList[j].SVMXC__Target_Field_Name__c,double.valueOf(FieldMappingList[j].SVMXC__Display_Value__c));
                                    }
                                    else if((isTargetObjectSFDCObject && f_SFDC.getType() == schema.Displaytype.Integer) || (isTargetObjectSFDCObject == false && f_SMART.getType().toUppercase() == 'INTEGER')){  //if field type is Integer
                                        if(Integer.valueof(FieldMappingList[j].SVMXC__Display_Value__c)!= null)
                                            mapOfTargetObject.put(FieldMappingList[j].SVMXC__Target_Field_Name__c, Integer.valueOf(FieldMappingList[j].SVMXC__Display_Value__c));
                                    }
                                    else if((isTargetObjectSFDCObject && f_SFDC.getType() == schema.Displaytype.Boolean) || (isTargetObjectSFDCObject == false && f_SMART.getType().toUppercase() == 'BOOLEAN')){  //if field type is Boolean
                                        if(Boolean.valueof(FieldMappingList[j].SVMXC__Display_Value__c)!= null)
                                            mapOfTargetObject.put(FieldMappingList[j].SVMXC__Target_Field_Name__c, Boolean.valueOf(FieldMappingList[j].SVMXC__Display_Value__c));
                                    }
                                    else if((isTargetObjectSFDCObject && f_SFDC.getType() == schema.Displaytype.DateTime) || (isTargetObjectSFDCObject == false && f_SMART.getType().toUppercase() == 'DATETIME')){    //if field type is DateTime
                                        if(FieldMappingList[j].SVMXC__Display_Value__c.touppercase() == 'TODAY')
                                            mapOfTargetObject.put(FieldMappingList[j].SVMXC__Target_Field_Name__c,datetime.newInstance(system.today(), time.newInstance(0, 0, 0, 0)));
                                        else if(FieldMappingList[j].SVMXC__Display_Value__c.touppercase() == 'YESTERDAY')
                                            mapOfTargetObject.put(FieldMappingList[j].SVMXC__Target_Field_Name__c,datetime.newInstance(system.today()-1, time.newInstance(0, 0, 0, 0)));    
                                        else if(FieldMappingList[j].SVMXC__Display_Value__c.touppercase() == 'TOMORROW')
                                            mapOfTargetObject.put(FieldMappingList[j].SVMXC__Target_Field_Name__c,datetime.newInstance(system.today()+1, time.newInstance(0, 0, 0, 0)));
                                        else if(FieldMappingList[j].SVMXC__Display_Value__c.touppercase() == 'NOW')
                                            mapOfTargetObject.put(FieldMappingList[j].SVMXC__Target_Field_Name__c,system.now());
                                        else
                                            mapOfTargetObject.put(FieldMappingList[j].SVMXC__Target_Field_Name__c,DateTime.valueof(FieldMappingList[j].SVMXC__Display_Value__c));                                                
                                    }
                                    else if((isTargetObjectSFDCObject && f_SFDC.getType() == schema.Displaytype.Date) || (isTargetObjectSFDCObject == false && f_SMART.getType().toUppercase() == 'DATE')){    //if field type is Date
                                        if(FieldMappingList[j].SVMXC__Display_Value__c.touppercase() == 'TODAY')
                                            mapOfTargetObject.put(FieldMappingList[j].SVMXC__Target_Field_Name__c,system.today());
                                        else if(FieldMappingList[j].SVMXC__Display_Value__c.touppercase() == 'YESTERDAY')
                                            mapOfTargetObject.put(FieldMappingList[j].SVMXC__Target_Field_Name__c,system.today() - 1);    
                                        else if(FieldMappingList[j].SVMXC__Display_Value__c.touppercase() == 'TOMORROW')
                                            mapOfTargetObject.put(FieldMappingList[j].SVMXC__Target_Field_Name__c,system.today() + 1);
                                        else
                                            mapOfTargetObject.put(FieldMappingList[j].SVMXC__Target_Field_Name__c,Date.valueof(FieldMappingList[j].SVMXC__Display_Value__c));
                                    }else if(isTargetObjectSFDCObject && f_SFDC.getType() == schema.Displaytype.Time){//if field type is Time - Added by Nidhi - BAC-5648
                                        if(FieldMappingList[j].SVMXC__Display_Value__c != null){
                                            Time timeValue = null;
                                            String str = String.valueOf(FieldMappingList[j].SVMXC__Display_Value__c);
                                            list<String> listTimeValue1 = new list<String>();
                                            listTimeValue1 = str.split('\\.');
                                            if(!String.isBlank(str) && listTimeValue1.size()>0){ 
                                                str = listTimeValue1[0];
                                                //String miliSec = listTimeValue1[1].removeEndIgnoreCase('z'); 
                                                String miliSec = '0';// Fixing defect BAC-3848
                                                if(listTimeValue1.size()>1){
                                                    miliSec = listTimeValue1[1].removeEndIgnoreCase('z');    
                                                }                                                     
                                                list<String> listTimeValue2 = new list<String>();
                                                listTimeValue2 = str.split(':');
                                                timeValue = Time.newInstance(Integer.valueOf(listTimeValue2[0]), Integer.valueOf(listTimeValue2[1]), Integer.valueOf(listTimeValue2[2]),Integer.valueOf(miliSec));
                                                mapOfTargetObject.put(FieldMappingList[j].SVMXC__Target_Field_Name__c, timeValue);                                 
                                            } 
                                        }                                       
                                    }
                                    else if(isTargetObjectSFDCObject && f_SFDC.getType() == schema.Displaytype.MultiPicklist){ //if field type is MultiPicklist
                                        if(String.valueof(FieldMappingList[j].SVMXC__Display_Value__c) != null)
                                            mapOfTargetObject.put(FieldMappingList[j].SVMXC__Target_Field_Name__c,String.valueof(FieldMappingList[j].SVMXC__Display_Value__c));
                                    }
                                    else{   //else field type is REFERENCE,String
                                        if((isTargetObjectSFDCObject && (String)FieldMappingList[j].SVMXC__Display_Value__c != null) || (isTargetObjectSFDCObject == false && f_SMART.getType().toUppercase() == 'STRING'))
                                            mapOfTargetObject.put(FieldMappingList[j].SVMXC__Target_Field_Name__c,(String)FieldMappingList[j].SVMXC__Display_Value__c);
                                    }
                                }
                            }
                        }
                    }
                }
                System.debug(LoggingLevel.WARN, 'mapOfTargetObject : '+mapOfTargetObject);
                Object genObject;
                if(isTargetObjectSFDCObject){
                    String newJSON = JSON.serialize(mapOfTargetObject);
                    System.debug(LoggingLevel.WARN, 'newJSON : '+newJSON);
                    SObject objSobject = (SObject) JSON.deserialize(newJSON, Type.forName(strTargetObjName));
                    genObject = objSobject;
                }
                else{
                    SmartObject.SmartObjectRecord tempSmartObjectRecord = new SmartObject.SmartObjectRecord();
                    tempSmartObjectRecord.mapTargetRecordFieldValues = mapOfTargetObject;
                    tempSmartObjectRecord.ObjectAPIName = strTargetObjName;
                    genObject = tempSmartObjectRecord;
                }
                System.debug(LoggingLevel.WARN, 'genObject : '+genObject);
                mapFinalSourceRecIdTargetObj.put(s1,genObject);
            }
        }
        System.debug(LoggingLevel.WARN, 'mapFinalSourceRecIdTargetObj : '+mapFinalSourceRecIdTargetObj.size()+mapFinalSourceRecIdTargetObj);
        return mapFinalSourceRecIdTargetObj;
    }
}