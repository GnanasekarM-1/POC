public with sharing class INTF_SaveTargetRecords
{
    public List<RecordType> RecordTypeList = new List<RecordType>(); 
    public String FldMapRTypeID = '';
    public String PNodeObjRTypeID = '';
    public map<String, Schema.SObjectType> gd = new Map<String, Schema.SObjectType>(); 
    public map<String,Schema.SObjectType> Allobj = new map<String,Schema.SObjectType>();
    SVMXC.COMM_Utils commutils = new SVMXC.COMM_Utils(); 
    SVMXC.INTF_buildSobjectFromKeyValue sobjectfromkevalue = new SVMXC.INTF_buildSobjectFromKeyValue();
    SVMXC.INTF_buildSobject BuildSobject = new SVMXC.INTF_buildSobject(); 
    public INTF_SaveTargetRecords()
    {
        RecordTypeList = [Select SystemModstamp, SobjectType, NamespacePrefix, Name, LastModifiedDate, LastModifiedById, IsActive, Id, DeveloperName, Description, CreatedDate, CreatedById, BusinessProcessId From RecordType where SobjectType = 'SVMXC__ServiceMax_Processes__c' or SobjectType = 'SVMXC__ServiceMax_Config_Data__c'];   //SDL-SVMX-FLS-NOT-ENFORCED-META-DATA
        if(RecordTypeList.size() > 0)
        {
            for(RecordType r : RecordTypeList) 
            {
                if(r.Name == 'Field Mapping') 
                {
                    FldMapRTypeID = r.id;
                }
                if(r.Name == 'Process Node Objects') 
                {
                    PNodeObjRTypeID = r.id;
                }
            }
        }
        gd = Schema.getGlobalDescribe();
        if(gd.size() > 0)
        {
            for(String s : gd.keyset())
            {
                Allobj.put(gd.get(s).getDescribe().getName(),gd.get(s));
            }
        }
    }
    public SVMXC.INTF_WebServicesDef.INTF_Response SaveTargetRecords(SVMXC.INTF_WebServicesDef.INTF_TargetRecord sfmtargetrec)
    {
        SVMXC.INTF_WebServicesDef.INTF_Response SFMResponse = new SVMXC.INTF_WebServicesDef.INTF_Response();
        map<String,map<String,Schema.SObjectField>> AllFieldDescribe = new map<String,map<String,Schema.SObjectField>>();
        DCON_Utils dcUtils = new DCON_Utils();
        String UserId = Userinfo.getUserId();
        User UserDetail = [SELECT TimeZoneSidKey from User where Id =: UserId];   //SDL-SVMX-FLS-NOT-ENFORCED-META-DATA
        String timeZone = UserDetail.TimeZoneSidKey;
        system.debug('timeZone'+timeZone);
        savepoint sp;
        try
        {
            sp = Database.setSavepoint();
            map<String,Sobject> HeaderSobjMap = new map<String,Sobject>(); 
            SVMXC__ServiceMax_Processes__c SFMProcess = new SVMXC__ServiceMax_Processes__c();
            SVMXC.INTF_WebServicesDef.INTF_TargetRecord SFMTargerRecord = new SVMXC.INTF_WebServicesDef.INTF_TargetRecord();
            if(sfmtargetrec != null) 
                SFMTargerRecord = sfmtargetrec;
            system.debug('SFMTargerRecord'+SFMTargerRecord);

            /***********************************************************************/
            //Neeraj(22-02-2012): Added two conditon two handle special charector.(Defect-003381)
            if(SFMTargerRecord.headerRecord != null)
            {
                if(SFMTargerRecord.headerRecord.records != null && SFMTargerRecord.headerRecord.records.size() > 0)
                {
                    for(INTF_WebServicesDef.INTF_Record TempRec : SFMTargerRecord.headerRecord.records)
                    {
                        if(TempRec.targetRecordAsKeyValue.size() > 0)
                        {
                            for(INTF_WebServicesDef.INTF_StringMap strMap : TempRec.targetRecordAsKeyValue)
                            {
                                if(strMap.value != null && strMap.value != '')
                                {
                                    strMap.value = strMap.value.replace('&amp;', '&');
                                    strMap.value = strMap.value.replace('&apos;', '\'');
                                    strMap.value = strMap.value.replace('&lt;', '<');
                                    strMap.value = strMap.value.replace('&gt;', '>');
                                    strMap.value = strMap.value.replace('&quot;', '"');
                                }
                                if(strMap.value1 != null && strMap.value1 != '')
                                {
                                    strMap.value1 = strMap.value1.replace('&amp;', '&');
                                    strMap.value1 = strMap.value1.replace('&apos;', '\'');
                                    strMap.value1 = strMap.value1.replace('&lt;', '<');
                                    strMap.value1 = strMap.value1.replace('&gt;', '>');
                                    strMap.value1 = strMap.value1.replace('&quot;', '"');
                                }
                            }
                        }
                    }
                }
            }
            //Neeraj(22-02-2012): Handling for details records.
            system.debug('detailRecords-001'+SFMTargerRecord.detailRecords);
            if(SFMTargerRecord.detailRecords != null && SFMTargerRecord.detailRecords.size() > 0)
            {
                for( INTF_WebServicesDef.INTF_TargetRecordObject TargetRecObj : SFMTargerRecord.detailRecords)
                {
                    if(TargetRecObj.records != null && TargetRecObj.records.size() > 0)
                    {
                        for(INTF_WebServicesDef.INTF_Record TempRec : TargetRecObj.records)
                        {
                            if(TempRec.targetRecordAsKeyValue.size() > 0)
                            {
                                for(INTF_WebServicesDef.INTF_StringMap strMap : TempRec.targetRecordAsKeyValue)
                                {
                                    if(strMap.value != null && strMap.value != '')
                                    {
                                        strMap.value = strMap.value.replace('&amp;', '&');
                                        strMap.value = strMap.value.replace('&apos;', '\'');
                                        strMap.value = strMap.value.replace('&lt;', '<');
                                        strMap.value = strMap.value.replace('&gt;', '>');
                                        strMap.value = strMap.value.replace('&quot;', '"');
                                    }
                                    if(strMap.value1 != null && strMap.value1 != '')
                                    {
                                        strMap.value1 = strMap.value1.replace('&amp;', '&');
                                        strMap.value1 = strMap.value1.replace('&apos;', '\'');
                                        strMap.value1 = strMap.value1.replace('&lt;', '<');
                                        strMap.value1 = strMap.value1.replace('&gt;', '>');
                                        strMap.value1 = strMap.value1.replace('&quot;', '"');
                                    }
                                }
                            }
                        }
                    }
                }
            }
            /***********************************************************************/
            
            String SFMID = '';//first member of the INTF_TargetRecord Class
            String ProcessId = '';
            SVMXC.INTF_WebServicesDef.INTF_TargetRecordObject HdrTargetRecordObject = new SVMXC.INTF_WebServicesDef.INTF_TargetRecordObject();//Second member of the INTF_TargetRecord Class
            List<SVMXC.INTF_WebServicesDef.INTF_TargetRecordObject> DtlTargetRecordObject = new List<SVMXC.INTF_WebServicesDef.INTF_TargetRecordObject>();//Third member of the INTF_TargetRecord Class
            //Get the Process Id
            if(SFMTargerRecord.sfmProcessId != null)
                SFMID = SFMTargerRecord.sfmProcessId;
            if(SFMID != null && SFMID.length() > 0)    //SDL-SVMX-FLS-NOT-ENFORCED-META-DATA
                SFMProcess = [Select SVMXC__Type__c, SVMXC__Target_Record_Type__c, SVMXC__Target_Object_label__c, 
        SVMXC__Target_Object_Name__c, SVMXC__Submodule__c, SVMXC__SubmoduleID__c, SVMXC__Source_Object_Name__c, 
        SVMXC__Settings_Name__c, SVMXC__Setting_Unique_ID__c, SVMXC__SettingID__c, SVMXC__Sequence__c, SVMXC__Select__c,
        SVMXC__Search_Order__c, SVMXC__Rule_Type__c, SVMXC__Purpose__c, SVMXC__Process__c, SVMXC__ProcessID__c, SVMXC__Preferred_Tech_Enabled__c, SVMXC__Pick_First_Match__c, 
        SVMXC__Parent_Object__c, SVMXC__Parent_Object_Criteria__c, SVMXC__Parent_Error_Msg__c, 
        SVMXC__Parent_Column_Name__c, SVMXC__Page_Layout__c, SVMXC__Node_Source_Object_API__c, 
        SVMXC__Node_Parent_API__c, SVMXC__Node_Parent__c, SVMXC__Name__c, SVMXC__Module__c, SVMXC__ModuleID__c, 
        SVMXC__Match_Contact__c, SVMXC__Match_Account__c, SVMXC__MapID__c, SVMXC__MTTS_Minutes__c, 
        SVMXC__IsStandard__c, SVMXC__IsStandalone__c, SVMXC__IsPrivate__c, SVMXC__IsDefault__C, 
        SVMXC__Installation_Key__c, SVMXC__Include_Top_Level__c, SVMXC__Include_Product__c, SVMXC__Include_Parent__c,  
        SVMXC__Frequency__c, SVMXC__Final_Exception_Process__c, SVMXC__Expertise_Match_Enabled__c, 
        SVMXC__Entitlement_Scope__c, SVMXC__Entitlement_By__c, SVMXC__End_Date__c, SVMXC__Email_On_Success__c, 
        SVMXC__Email_On_Error__c, SVMXC__Distance_And_Time__c,  SVMXC__Dispatch_Method__c, SVMXC__Description__c, 
        SVMXC__Default_Value__c, SVMXC__Data_Type__c, SVMXC__Counter_Vs_Dates_Rule__c, SVMXC__Child_Object_Criteria__c,
        SVMXC__Child_Error_Msg__c, SVMXC__Calendar_Start_Type__c, SVMXC__Calendar_Start_Days__c, 
        SVMXC__Calendar_End_Type__c, SVMXC__Calendar_End_Days__c, SVMXC__Assign_Work_Order_To__c, 
        SVMXC__Assign_To_Technician__c, SVMXC__Assign_To_Queue__c, SVMXC__Assign_To_Dispatcher__c, 
        SVMXC__Advance_Expression__c, SVMXC__Active__c, RecordTypeId, OwnerId, Name, 
        LastModifiedDate, LastModifiedById,  IsDeleted, Id, CreatedDate, CreatedById From SVMXC__ServiceMax_Processes__c where RecordType.Name = 'Target Manager' and (SVMXC__ProcessID__c =: SFMID OR Id =: SFMID)];
            if(SFMProcess != null && SFMProcess.id != null)
                ProcessId = SFMProcess.id;
            //get the Header Reocrd...
            if(SFMTargerRecord.headerRecord != null)
                HdrTargetRecordObject = SFMTargerRecord.headerRecord;
            //get the details records....
            if(SFMTargerRecord.detailRecords != null && SFMTargerRecord.detailRecords.size() > 0)
                DtlTargetRecordObject = SFMTargerRecord.detailRecords;
            system.debug('DtlTargetRecordObject'+SFMTargerRecord.detailRecords);   
            system.debug('DtlTargetRecordObject'+DtlTargetRecordObject.size()+DtlTargetRecordObject);   
            //first process the Header of the INTF_TargetRecordObject
            String HeaderObjName = '';//for the first member of INTF_TargetRecordObject
            List<SVMXC.INTF_WebServicesDef.INTF_Record> HeaderRecord = new List<SVMXC.INTF_WebServicesDef.INTF_Record>();//for the third member of INTF_TargetRecordObject
            //get the Header Object Name
            if(HdrTargetRecordObject.objName != null)
                HeaderObjName = HdrTargetRecordObject.objName;
            system.debug('HeaderObjName'+HeaderObjName);    
            //Get the Header SFM Records...
            if(HdrTargetRecordObject.records.size() > 0)
                HeaderRecord = HdrTargetRecordObject.records;
            system.debug('HeaderRecord'+HeaderRecord.size()+HeaderRecord);    
            String HdrSourceUpdateRecId = '';
            Sobject HdrSObject;
            //First do the Field describe and put it in all describe
            map<String, Schema.SObjectField> FieldMap = new map<String, Schema.SObjectField>();
            map<String, Schema.SObjectField> HeaderFieldMap = new map<String, Schema.SObjectField>();
            if(Allobj.containskey(HeaderObjName) && AllFieldDescribe.containskey(HeaderObjName) == false)
                FieldMap = Allobj.get(HeaderObjName).getDescribe().fields.getMap();
            if(FieldMap.size() > 0)
            {
                for(String s : FieldMap.keyset())
                {
                    HeaderFieldMap.put(FieldMap.get(s).getDescribe().getName(),FieldMap.get(s));
                }
                if(HeaderFieldMap.size() > 0)
                {
                    AllFieldDescribe.put(HeaderObjName,HeaderFieldMap);
                }
            } 
            if(HeaderRecord.size() > 0)
            {
                if(HeaderRecord[0].sourceRecordId != null)  
                    HdrSourceUpdateRecId = HeaderRecord[0].sourceRecordId;
                if(HeaderRecord[0].targetRecordAsKeyValue != null && HeaderRecord[0].targetRecordAsKeyValue.size() > 0 && HeaderObjName != null && HeaderObjName.length() > 0)
                {
                    HeaderSobjMap = sobjectfromkevalue.BuildSobjectFromKeyValue(HeaderRecord[0].targetRecordAsKeyValue,HeaderObjName,null,null);//AllFieldDescribe        
                }
            }
            system.debug('HeaderSobjMap'+HeaderSobjMap);
            if(HeaderSobjMap.size() > 0 && HeaderObjName != null && HeaderObjName.length() > 0)
            {
                HdrSObject = HeaderSobjMap.values();
                /*map<String, Schema.SObjectField> LocalFldMap = new map<String, Schema.SObjectField>();
                if(AllFieldDescribe.containskey(HeaderObjName))
                    LocalFldMap = AllFieldDescribe.get(HeaderObjName);
                if(LocalFldMap.size() > 0)
                {
                    for(String s : LocalFldMap.keyset())
                    {
                        Schema.DescribeFieldResult f = LocalFldMap.get(s).getDescribe();
                        if(f.isAccessible() && f.isCreateable() && f.isUpdateable() && f.getType() == schema.Displaytype.DateTime)
                        {
                            if(HdrSObject.get(s) != null)
                            {
                                system.debug('zzzzzz'+HdrSObject.get(s));
                                Datetime dt = dcUtils.getDateTimeInTimezone(DateTime.valueof(HdrSObject.get(s)).dateGmt(), DateTime.valueof(HdrSObject.get(s)).timeGmt(), timeZone);
                                system.debug('zzzzzz'+DateTime.valueof(HdrSObject.get(s)).dateGmt());
                                system.debug('zzzzzz'+DateTime.valueof(HdrSObject.get(s)).timeGmt());
                                system.debug('zzzzzz'+dt); 
                                HdrSObject.put(s,dt);
                            }
                        }
                    }
                }*/
            }
            system.debug('HdrSObject'+HdrSObject);
            if(HdrSObject != null)
            {
                if(COMM_SecurityUtils.getInstance().verifyFieldAccess(new List<SObject>{HdrSObject} , COMM_SecurityUtils.Access.Upsertable)){   //SDL-SVMX-CREATE-UPDATE-FLS-ENFORCED
                    upsert HdrSObject;
                    system.debug('Its upserted');
                }
            }    
           //Do Header Source Update...
            if(ProcessId != null && ProcessId.length() > 0 && HdrSobject != null && HdrSourceUpdateRecId != null && HdrSourceUpdateRecId.length() > 0 && HeaderObjName != null && HeaderObjName.length() > 0)
                DoHeaderSourceObjectUpdate(ProcessId,HdrSobject,HdrSourceUpdateRecId,HeaderObjName,null,AllFieldDescribe);       
            //now process the detail Reocrds..
            list<Sobject> DetailRecordsForUpdate = new list<Sobject>();
            list<Sobject> DetailRecordsForInsert = new list<Sobject>();
            Map<Integer,List<SVMXC.INTF_WebServicesDef.INTF_Record>> TargetRecMap = new Map<Integer,List<SVMXC.INTF_WebServicesDef.INTF_Record>>(); 
            map<Integer,String> DetailObjName = new map<Integer,String>();
            map<Integer,String> AliasNameMap = new map<Integer,String>(); 
            map<Integer,String> ParentColumnNameMap = new map<Integer,String>();
            map<Integer,List<String>> DeleteRecordIdMap = new map<Integer,List<String>>();
            if(DtlTargetRecordObject.size() > 0)
            {
                for(Integer i = 0;i<DtlTargetRecordObject.size();i++)
                {
                    if(DtlTargetRecordObject[i].records != null && DtlTargetRecordObject[i].records.size() > 0 )
                        TargetRecMap.put(i,DtlTargetRecordObject[i].records);
                    if(DtlTargetRecordObject[i].objName != null && DtlTargetRecordObject[i].objName.length() > 0)
                        DetailObjName.put(i,DtlTargetRecordObject[i].objName);
                    if(DtlTargetRecordObject[i].aliasName != null && DtlTargetRecordObject[i].aliasName.length() > 0)
                        AliasNameMap.put(i,DtlTargetRecordObject[i].aliasName);  
                    if(DtlTargetRecordObject[i].parentColumnName != null && DtlTargetRecordObject[i].parentColumnName.length() > 0)
                        ParentColumnNameMap.put(i,DtlTargetRecordObject[i].parentColumnName);
                    if(DtlTargetRecordObject[i].deleteRecID != null && DtlTargetRecordObject[i].deleteRecID.size() > 0)
                        DeleteRecordIdMap.put(i,DtlTargetRecordObject[i].deleteRecID);//recordIds to be delete          
                }
            }
            system.debug('TargetRecMap'+TargetRecMap);
            system.debug('DetailObjName'+DetailObjName);
            system.debug('AliasNameMap'+AliasNameMap);
            system.debug('ParentColumnNameMap'+ParentColumnNameMap);
            system.debug('DeleteRecordIdMap'+DeleteRecordIdMap);
            if(TargetRecMap.size() > 0)
            {
                for(Integer i : TargetRecMap.keyset())
                {
                    List<SVMXC.INTF_WebServicesDef.INTF_Record> SfmReocrdlst = new List<SVMXC.INTF_WebServicesDef.INTF_Record>(); 
                    SVMXC__ServiceMax_Processes__c DetailNodeObject = new  SVMXC__ServiceMax_Processes__c();
                    list<SVMXC__ServiceMax_Config_Data__c> DetailSourceUpdates = new list<SVMXC__ServiceMax_Config_Data__c>();
                    set<String> DetailSourceUpdateIds = new set<String>();
                    if(TargetRecMap.containskey(i))
                        SfmReocrdlst = TargetRecMap.get(i);
                    String ObjectName = '';
                    String AliasName = '';
                    String ParentColumnName = '';
                    list<String> DetailSourceRecUpdateIds = new list<String>(); 
                    if(DetailObjName.containskey(i))
                        ObjectName = DetailObjName.get(i);
                    if(AliasNameMap.containskey(i))
                        AliasName = AliasNameMap.get(i);
                    if(ParentColumnNameMap.containskey(i))
                        ParentColumnName = ParentColumnNameMap.get(i);
                    Map<String,Schema.SObjectField> DetailFieldMap = new Map<String,Schema.SObjectField>(); 
                    if( ObjectName != null && ObjectName.length() > 0 && Allobj.containskey(ObjectName) && AllFieldDescribe.containskey(ObjectName)== false)
                    {
                        Map<String,Schema.SObjectField> DFieldMap = new Map<String,Schema.SObjectField>();
                        DFieldMap = Allobj.get(ObjectName).getDescribe().fields.getMap();
                        if(DFieldMap.size() > 0)
                        {
                            for(String s : DFieldMap.keyset())
                            {
                                DetailFieldMap.put(DFieldMap.get(s).getDescribe().getname(),DFieldMap.get(s));
                            }
                            AllFieldDescribe.put(ObjectName,DetailFieldMap);
                        }
                    }
                    system.debug('AllFieldDescribe'+AllFieldDescribe);
                    system.debug('SfmReocrdlst'+SfmReocrdlst.size()+SfmReocrdlst);
                    if(SfmReocrdlst.size() > 0)
                    {
                        DetailRecordsForUpdate = new list<Sobject>();
                        DetailRecordsForInsert = new list<Sobject>();  
                        //Build the Detail Sobject from key-value 
                        map<String,list<Sobject>> DetailSobjMap = new map<String,list<Sobject>>();
                        if(SfmReocrdlst.size() > 0 && ObjectName != null && ObjectName.length() > 0 && ParentColumnName != null && ParentColumnName.length() > 0 && String.valueof(HdrSObject.get('Id')) != null && String.valueof(HdrSObject.get('Id')).length() > 0) 
                        {
                            DetailSobjMap = sobjectfromkevalue.BuildSobjectFromKeyValue2(SfmReocrdlst,ObjectName,ParentColumnName,String.valueof(HdrSObject.get('Id')),AllFieldDescribe);//AllFieldDescribe
                        }   
                        system.debug('DetailSobjMap'+DetailSobjMap);
                        if(DetailSobjMap.size() > 0)
                        {
                            for(String s : DetailSobjMap.keyset())
                            {
                                if(s.touppercase() == 'INSERT')
                                {
                                    DetailRecordsForInsert.addall(DetailSobjMap.get(s)); 
                                }
                                if(s.touppercase() == 'UPDATE')
                                {
                                    DetailRecordsForUpdate.addall(DetailSobjMap.get(s));
                                }
                            }
                        }
                        system.debug('DetailRecordsForInsert'+DetailRecordsForInsert);
                        system.debug('DetailRecordsForUpdate'+DetailRecordsForUpdate);
                        map<String,Sobject> SourceRecIdTargetObjMap = new map<String,Sobject>();
                        for(Integer j = 0;j<SfmReocrdlst.size();j++)
                        {
                            if(SfmReocrdlst[j].sourceRecordId != null && DetailSobjMap.containskey(SfmReocrdlst[j].sourceRecordId))
                            {
                                list<Sobject> temp = new list<Sobject>();
                                temp = DetailSobjMap.get(SfmReocrdlst[j].sourceRecordId);
                                SourceRecIdTargetObjMap.put(SfmReocrdlst[j].sourceRecordId,temp[0]);
                            }   
                                
                        } 
                        if(DetailRecordsForInsert.size() > 0)
                        {
                            //special handaling for the DateTime
                            if(AllFieldDescribe.containskey(ObjectName))
                            {
                                map<String, Schema.SObjectField> DtlFieldMap = new map<String, Schema.SObjectField>();
                                DtlFieldMap = AllFieldDescribe.get(ObjectName);
                                if(DtlFieldMap.size() > 0)
                                {
                                    for(String s : DtlFieldMap.keyset())
                                    {
                                        Schema.DescribeFieldResult f = DtlFieldMap.get(s).getDescribe();
                                        if(f.isAccessible() && f.isCreateable() && f.getType() == schema.Displaytype.DateTime)
                                        {
                                            for(Integer j = 0;j<DetailRecordsForInsert.size();j++)
                                            {
                                                /*
                                                if(DetailRecordsForInsert[j].get(s) != null)
                                                {
                                                    system.debug('zzzzzz'+DetailRecordsForInsert[j].get(s));
                                                    Datetime dt = dcUtils.getDateTimeInTimezone(DateTime.valueof(DetailRecordsForInsert[j].get(s)).dateGmt(), DateTime.valueof(DetailRecordsForInsert[j].get(s)).timeGmt(), timeZone);
                                                    system.debug('zzzzzz'+DateTime.valueof(DetailRecordsForInsert[j].get(s)).dateGmt());
                                                    system.debug('zzzzzz'+DateTime.valueof(DetailRecordsForInsert[j].get(s)).timeGmt());
                                                    system.debug('zzzzzz'+dt); 
                                                    DetailRecordsForInsert[j].put(s,dt);
                                                }*/
                                                //special handaling for currencyISOCode field in detail record.
                                                if(Userinfo.isMultiCurrencyOrganization() && DtlFieldMap.containskey('CurrencyIsoCode'))
                                                {
                                                    if(DetailRecordsForInsert[j].get('CurrencyIsoCode') == null && HdrSObject.get('CurrencyIsoCode') != null)
                                                    {
                                                        DetailRecordsForInsert[j].put('CurrencyIsoCode',HdrSObject.get('CurrencyIsoCode'));
                                                    }
                                                }
                                            }
                                        }
                                    }
                                }
                            }
                            system.debug('DetailRecordsForInsert'+DetailRecordsForInsert);
                            if(COMM_SecurityUtils.getInstance().verifyFieldAccess(DetailRecordsForInsert , COMM_SecurityUtils.Access.Createable)){   //SDL-SVMX-CREATE-UPDATE-FLS-ENFORCED
                                insert DetailRecordsForInsert;
                            }
                        }
                        if(DetailRecordsForUpdate.size() > 0)
                        {
                            /*
                            //special handaling for the DateTime
                            if(AllFieldDescribe.containskey(ObjectName))
                            {
                                map<String, Schema.SObjectField> DtlFieldMap = new map<String, Schema.SObjectField>();
                                DtlFieldMap = AllFieldDescribe.get(ObjectName);
                                if(DtlFieldMap.size() > 0)
                                {
                                    for(String s : DtlFieldMap.keyset())
                                    {
                                        Schema.DescribeFieldResult f = DtlFieldMap.get(s).getDescribe();
                                        if(f.isAccessible() && f.isUpdateable() && f.getType() == schema.Displaytype.DateTime)
                                        {
                                            for(Integer j = 0;j<DetailRecordsForUpdate.size();j++)
                                            {
                                                if(DetailRecordsForUpdate[j].get(s) != null)
                                                {
                                                    system.debug('zzzzzz'+DetailRecordsForUpdate[j].get(s));
                                                    Datetime dt = dcUtils.getDateTimeInTimezone(DateTime.valueof(DetailRecordsForUpdate[j].get(s)).dateGmt(), DateTime.valueof(DetailRecordsForUpdate[j].get(s)).timeGmt(), timeZone);
                                                    system.debug('zzzzzz'+DateTime.valueof(DetailRecordsForUpdate[j].get(s)).dateGmt());
                                                    system.debug('zzzzzz'+DateTime.valueof(DetailRecordsForUpdate[j].get(s)).timeGmt());
                                                    system.debug('zzzzzz'+dt); 
                                                    DetailRecordsForUpdate[j].put(s,dt);
                                                }
                                            }
                                        }
                                    }
                                }
                            }*/
                            system.debug('DetailRecordsForUpdate'+DetailRecordsForUpdate);
                            if(COMM_SecurityUtils.getInstance().verifyFieldAccess(DetailRecordsForUpdate , COMM_SecurityUtils.Access.Updateable)){   //SDL-SVMX-CREATE-UPDATE-FLS-ENFORCED
                                update DetailRecordsForUpdate;
                            }
                        }
                        //Start Processing the Detail source update
                        DoDetailsSourceObjectUpdate(ProcessId,SourceRecIdTargetObjMap,ObjectName,AliasName,AllFieldDescribe);
                    }     
                }
            }
            //Delete operation..
            if(DeleteRecordIdMap.size() > 0)
            {
                for(Integer i : DeleteRecordIdMap.keyset())
                {
                    String ObjectName = '';
                    List<String> DelIds = new List<String>();
                    List<Sobject> DeleteRecordsForDelete = new List<Sobject>(); 
                    if(DeleteRecordIdMap.containskey(i))
                        DelIds = DeleteRecordIdMap.get(i);
                    if(DetailObjName.containskey(i))
                        ObjectName = DetailObjName.get(i);
                    String DelRecId = '';
                    if(DelIds.size() > 0)
                    {
                        for(Integer a = 0;a<DelIds.size();a++)
                        {
                            if(DelRecId.length() > 0)
                                DelRecId += ',';
                            DelRecId  += '\'' + DelIds[a] + '\'';
                        }
                    }
                    if(DelRecId != null && DelRecId.length() > 0 && ObjectName != null && ObjectName.length() > 0)   
                    {
                        String Query = 'Select Id From ' + ObjectName + ' Where Id IN (' + DelRecId+')';
                        system.debug('Query'+Query);
                        DeleteRecordsForDelete = Database.Query(Query);
                    }
                    system.debug('DeleteRecordsForDelete'+DeleteRecordsForDelete.size()+DeleteRecordsForDelete);
                    if(DeleteRecordsForDelete.size() > 0)
                    {
                        delete DeleteRecordsForDelete;
                    }
                }
            }       
            SFMResponse.success = true;
            SFMResponse.eventType = sfmtargetrec.eventType;
            SFMResponse.message = system.Label.SFM001_TAG184;//'Saved Succefully';
            if(HdrSObject.get('Id') != null)
                SFMResponse.resultIds.add(String.valueof(HdrSObject.get('Id')));
        }
        catch(Exception ex)
        {
            Database.rollback(sp);
            SFMResponse.success = false;
            SFMResponse.eventType = sfmtargetrec.eventType;
            SFMResponse.message = ex.getmessage();
        }    
        return SFMResponse;
    }
    public void DoHeaderSourceObjectUpdate(String SFMId,Sobject TargetSobject,String SourceUpdateRecId,String ObjName,String AliasName,map<String,map<String,Schema.SObjectField>> AllFieldDescribe)
    {
        system.debug('Entered for Sourceupdate');
        system.debug('SFMId'+SFMId);
        system.debug('TargetSobject'+TargetSobject);
        system.debug('SourceUpdateRecId'+SourceUpdateRecId);
        system.debug('ObjName'+ObjName);
        system.debug('AliasName'+AliasName);
        system.debug('AllFieldDescribe'+AllFieldDescribe);
        map<String,Schema.SObjectField> LocalFieldMap = new Map<String,Schema.SObjectField>();
        map<String, Schema.SObjectField> SourceFieldMap = new map<String, Schema.SObjectField>();
        SVMXC__ServiceMax_Processes__c ProcessNodeObject = new  SVMXC__ServiceMax_Processes__c();
        list<SVMXC__ServiceMax_Config_Data__c> SourceUpdatesFields = new list<SVMXC__ServiceMax_Config_Data__c>();
        Sobject SourceUpdateRec;
        String SourceObjectName = '';
        String TargetObjectName = '';
        if(AllFieldDescribe.containskey(ObjName))
            LocalFieldMap = AllFieldDescribe.get(ObjName);
        //Start Processing for the Header source update.
        //first get the process node object from the sfm process 
        if(SFMId != null && PNodeObjRTypeID != null && PNodeObjRTypeID.length() > 0)
        {
            if(ObjName != null && AliasName == null)
                ProcessNodeObject = [select id,Name,RecordTypeId,SVMXC__ProcessID__c,SVMXC__Process__c,SVMXC__Source_Object_Name__c,SVMXC__Submodule__c,SVMXC__Module__c,SVMXC__Final_Exception_Process__c,SVMXC__Sequence__c,SVMXC__Node_Parent_API__c,SVMXC__Node_Source_Object_API__c,SVMXC__Node_Parent__c,SVMXC__Parent_Object__c,SVMXC__Target_Object_label__c,SVMXC__Type__c,SVMXC__Page_Layout__c,SVMXC__Parent_Column_Name__c from SVMXC__ServiceMax_Processes__c where RecordTypeId =: PNodeObjRTypeID and SVMXC__Process__c =: SFMId and SVMXC__Source_Object_Name__c =: ObjName and SVMXC__Type__c = 'TARGET'];   //SDL-SVMX-FLS-NOT-ENFORCED-META-DATA
            if(ObjName != null && AliasName != null)
                ProcessNodeObject = [select id,Name,RecordTypeId,SVMXC__ProcessID__c,SVMXC__Process__c,SVMXC__Source_Object_Name__c,SVMXC__Submodule__c,SVMXC__Module__c,SVMXC__Final_Exception_Process__c,SVMXC__Sequence__c,SVMXC__Node_Parent_API__c,SVMXC__Node_Source_Object_API__c,SVMXC__Node_Parent__c,SVMXC__Parent_Object__c,SVMXC__Target_Object_label__c,SVMXC__Type__c,SVMXC__Page_Layout__c,SVMXC__Parent_Column_Name__c from SVMXC__ServiceMax_Processes__c where RecordTypeId =: PNodeObjRTypeID and SVMXC__Process__c =: SFMId and SVMXC__Page_Layout__c =: AliasName and SVMXC__Type__c = 'TARGETCHILD'];    //SDL-SVMX-FLS-NOT-ENFORCED-META-DATA
        }
        //second Query the Source update defination & Source update Data from sfmid for the header object...
        if(ProcessNodeObject != null && ProcessNodeObject.id != null)
            SourceUpdatesFields = [select id,Name,SVMXC__Dispatch_Process__c,SVMXC__MapID__c,SVMXC__MapID__r.SVMXC__Source_Object_Name__c,SVMXC__Source_Field_Name__c,SVMXC__Setting_ID__c,SVMXC__Setting_ID__r.SVMXC__Source_Object_Name__c,SVMXC__Setting_ID__r.SVMXC__Node_Source_Object_API__c,SVMXC__Target_Field_Name__c,SVMXC__Action__c,SVMXC__Display_Value__c,SVMXC__Configuration_Type__c,SVMXC__Object_Name__c,SVMXC__FKey_Name_Field__c,SVMXC__Field_Relationship_Name__c,SVMXC__Display_Type__c,RecordTypeId from SVMXC__ServiceMax_Config_Data__c where SVMXC__Setting_ID__c =: ProcessNodeObject.id and RecordTypeId =: FldMapRTypeID and SVMXC__Configuration_Type__c = 'Source Update'];   //SDL-SVMX-FLS-NOT-ENFORCED-META-DATA
        if(SourceUpdatesFields.size() > 0)
        {
            SourceObjectName = SourceUpdatesFields[0].SVMXC__Setting_ID__r.SVMXC__Node_Source_Object_API__c;
            TargetObjectName = SourceUpdatesFields[0].SVMXC__Setting_ID__r.SVMXC__Source_Object_Name__c;
            if(SourceObjectName != null && SourceObjectName.length() > 0 && SourceUpdateRecId != null && SourceUpdateRecId.length() > 0)
            {
                if(Allobj.containskey(SourceObjectName) && AllFieldDescribe.containskey(SourceObjectName) == false)
                {
                    map<String, Schema.SObjectField> LFieldMap = new map<String, Schema.SObjectField>();
                    LFieldMap = Allobj.get(SourceObjectName).getDescribe().fields.getMap();
                    if(LFieldMap.size() > 0)
                    {
                        for(String s : LFieldMap.keyset())
                        {
                            SourceFieldMap.put(LFieldMap.get(s).getDescribe().getName(),LFieldMap.get(s));
                        }
                    }
                    AllFieldDescribe.put(SourceObjectName,SourceFieldMap);
                }
                else if(Allobj.containskey(SourceObjectName) && AllFieldDescribe.containskey(SourceObjectName))
                {
                    SourceFieldMap = AllFieldDescribe.get(SourceObjectName);
                }
                list<Sobject> SobjList = new list<Sobject>(); 
                SobjList = BuildSobject.getINTF_BuildSobject(SourceUpdateRecId,SourceObjectName,null,null);
                if(SobjList.size() > 0)
                    SourceUpdateRec = SobjList[0];
            }   
        }
        if(SourceUpdatesFields.size() > 0 && SourceUpdateRec != null && TargetSobject != null && LocalFieldMap.size() > 0)
        {
            for(Integer i = 0;i<SourceUpdatesFields.size();i++)
            {
                if(SourceUpdatesFields[i].SVMXC__Source_Field_Name__c != null )
                {
                    //Check for Set
                    if(SourceUpdatesFields[i].SVMXC__Action__c.touppercase() == 'SET' )//EQ
                    {
                        system.debug('Entered for set');  
                        //if Target field API Name is null and value is not null..
                        if(SourceUpdatesFields[i].SVMXC__Target_Field_Name__c == null && SourceUpdatesFields[i].SVMXC__Display_Value__c != null)
                        {
                            //Desctibe the field to check differen attributes of fields..
                            Schema.DescribeFieldResult f = SourceFieldMap.get(SourceUpdatesFields[i].SVMXC__Source_Field_Name__c).getDescribe();
                            if((f.getType() == schema.Displaytype.Double  || f.getType() == schema.Displaytype.Percent || f.getType() == schema.Displaytype.Currency)&& f.isCreateable())//if Field Type is Double,persent,currency 
                            {
                                if(double.valueOf(SourceUpdatesFields[i].SVMXC__Source_Field_Name__c) != null )
                                {
                                    SourceUpdateRec.put(SourceUpdatesFields[i].SVMXC__Source_Field_Name__c,(double.valueOf(SourceUpdatesFields[i].SVMXC__Display_Value__c)));
                                }   
                            }
                            else if(f.getType() == schema.Displaytype.Integer && f.isCreateable())//if field type is Integer
                            {
                                if(Integer.valueof(SourceUpdatesFields[i].SVMXC__Display_Value__c)!= null)
                                {
                                    SourceUpdateRec.put(SourceUpdatesFields[i].SVMXC__Source_Field_Name__c,Integer.valueof(SourceUpdatesFields[i].SVMXC__Display_Value__c));
                                }   
                            }
                            else if(f.getType() == schema.Displaytype.Boolean && f.isCreateable())//if field type is Boolean
                            {
                                if(Boolean.valueof(SourceUpdatesFields[i].SVMXC__Display_Value__c)!= null)
                                {
                                    SourceUpdateRec.put(SourceUpdatesFields[i].SVMXC__Source_Field_Name__c,Boolean.valueof(SourceUpdatesFields[i].SVMXC__Display_Value__c));
                                }   
                            }
                            else if(f.getType() == schema.Displaytype.DateTime && f.isCreateable())//if field type is DateTime
                            {
                                if(SourceUpdatesFields[i].SVMXC__Display_Value__c.touppercase() == 'TODAY')
                                {
                                    system.debug('Enterd for Today');
                                    SourceUpdateRec.put(SourceUpdatesFields[i].SVMXC__Source_Field_Name__c,system.today());
                                }   
                                else if(SourceUpdatesFields[i].SVMXC__Display_Value__c.touppercase() == 'YESTERDAY')
                                {
                                    system.debug('Enterd for YESTERDAY');
                                    SourceUpdateRec.put(SourceUpdatesFields[i].SVMXC__Source_Field_Name__c,system.today() - 1);
                                }       
                                else if(SourceUpdatesFields[i].SVMXC__Display_Value__c.touppercase() == 'TOMORROW')
                                {
                                    system.debug('Enterd for TOMORROW');
                                    SourceUpdateRec.put(SourceUpdatesFields[i].SVMXC__Source_Field_Name__c,system.today() + 1);
                                }
                                else if(SourceUpdatesFields[i].SVMXC__Display_Value__c.touppercase() == 'NOW')
                                {
                                    system.debug('Enterd for NOW');
                                    SourceUpdateRec.put(SourceUpdatesFields[i].SVMXC__Source_Field_Name__c,system.now());
                                }
                                else
                                {           
                                    SourceUpdateRec.put(SourceUpdatesFields[i].SVMXC__Source_Field_Name__c,DateTime.valueof(SourceUpdatesFields[i].SVMXC__Display_Value__c));
                                }
                                        
                            }
                            else if(f.getType() == schema.Displaytype.Date && f.isCreateable())//if field type is Date
                            {
                                if(SourceUpdatesFields[i].SVMXC__Display_Value__c.touppercase() == 'TODAY')
                                {
                                    system.debug('Enterd for Today');
                                    SourceUpdateRec.put(SourceUpdatesFields[i].SVMXC__Source_Field_Name__c,system.today());
                                }   
                                else if(SourceUpdatesFields[i].SVMXC__Display_Value__c.touppercase() == 'YESTERDAY')
                                {
                                    system.debug('Enterd for YESTERDAY');
                                    SourceUpdateRec.put(SourceUpdatesFields[i].SVMXC__Source_Field_Name__c,system.today() - 1);
                                }       
                                else if(SourceUpdatesFields[i].SVMXC__Display_Value__c.touppercase() == 'TOMORROW')
                                {
                                    system.debug('Enterd for TOMORROW');
                                    SourceUpdateRec.put(SourceUpdatesFields[i].SVMXC__Source_Field_Name__c,system.today() + 1);
                                }
                                else
                                {           
                                    SourceUpdateRec.put(SourceUpdatesFields[i].SVMXC__Source_Field_Name__c,Date.valueof(SourceUpdatesFields[i].SVMXC__Display_Value__c));
                                }
                            }
                            else if(f.getType() == schema.Displaytype.MultiPicklist && f.isCreateable())//if field type is MultiPicklist
                            {
                                if(String.valueof(SourceUpdatesFields[i].SVMXC__Display_Value__c) != null)
                                {
                                    SourceUpdateRec.put(SourceUpdatesFields[i].SVMXC__Source_Field_Name__c,String.valueof(SourceUpdatesFields[i].SVMXC__Display_Value__c));
                                }
                            }
                            else //else field type is REFERENCE,String 
                            {
                                if((String)SourceUpdatesFields[i].SVMXC__Display_Value__c != null && f.isCreateable())
                                {
                                    SourceUpdateRec.put(SourceUpdatesFields[i].SVMXC__Source_Field_Name__c,(String)SourceUpdatesFields[i].SVMXC__Display_Value__c);
                                }
                            }
                        }    
                        //if Target field API Name is not null and value is null..   
                        if(SourceUpdatesFields[i].SVMXC__Target_Field_Name__c != null && SourceUpdatesFields[i].SVMXC__Display_Value__c == null)
                        {
                            //Desctibe the field to check differen attributes of fields..
                            Schema.DescribeFieldResult f = SourceFieldMap.get(SourceUpdatesFields[i].SVMXC__Source_Field_Name__c).getDescribe();
                            if((f.getType() == schema.Displaytype.Double  || f.getType() == schema.Displaytype.Percent || f.getType() == schema.Displaytype.Currency)&& f.isUpdateable())//if Field Type is Double,persent,currency 
                            {
                                if(double.valueOf(TargetSobject.get(SourceUpdatesFields[i].SVMXC__Target_Field_Name__c)) != null )
                                {
                                    SourceUpdateRec.put(SourceUpdatesFields[i].SVMXC__Source_Field_Name__c,(double.valueOf(TargetSobject.get(SourceUpdatesFields[i].SVMXC__Target_Field_Name__c))));
                                }   
                            }
                            else if(f.getType() == schema.Displaytype.Integer && f.isUpdateable())//if field type is Integer
                            {
                                if(Integer.valueof(TargetSobject.get(SourceUpdatesFields[i].SVMXC__Target_Field_Name__c))!= null)
                                {
                                    SourceUpdateRec.put(SourceUpdatesFields[i].SVMXC__Source_Field_Name__c,Integer.valueof(TargetSobject.get(SourceUpdatesFields[i].SVMXC__Target_Field_Name__c)));
                                }   
                            }
                            else if(f.getType() == schema.Displaytype.Boolean && f.isUpdateable())//if field type is Boolean
                            {
                                if(Boolean.valueof(TargetSobject.get(SourceUpdatesFields[i].SVMXC__Target_Field_Name__c))!= null)
                                {
                                    SourceUpdateRec.put(SourceUpdatesFields[i].SVMXC__Source_Field_Name__c,Boolean.valueof(TargetSobject.get(SourceUpdatesFields[i].SVMXC__Target_Field_Name__c)));
                                }   
                            }
                            else if(f.getType() == schema.Displaytype.DateTime && f.isUpdateable())//if field type is DateTime
                            {
                                system.debug('asdf'+TargetSobject.get(SourceUpdatesFields[i].SVMXC__Target_Field_Name__c));
                                if(DateTime.valueOf(TargetSobject.get(SourceUpdatesFields[i].SVMXC__Target_Field_Name__c)) != null)
                                {
                                    SourceUpdateRec.put(SourceUpdatesFields[i].SVMXC__Source_Field_Name__c,DateTime.valueOf(TargetSobject.get(SourceUpdatesFields[i].SVMXC__Target_Field_Name__c)));
                                }   
                            }
                            else if(f.getType() == schema.Displaytype.Date && f.isUpdateable())//if field type is Date
                            {
                                system.debug('asdf'+TargetSobject.get(SourceUpdatesFields[i].SVMXC__Target_Field_Name__c));
                                if(Date.valueOf(TargetSobject.get(SourceUpdatesFields[i].SVMXC__Target_Field_Name__c)) != null)
                                {
                                    SourceUpdateRec.put(SourceUpdatesFields[i].SVMXC__Source_Field_Name__c,Date.valueOf(TargetSobject.get(SourceUpdatesFields[i].SVMXC__Target_Field_Name__c)));
                                }
                            }
                            else if(f.getType() == schema.Displaytype.MultiPicklist && f.isUpdateable())//if field type is MultiPicklist
                            {
                                if(String.valueof(TargetSobject.get(SourceUpdatesFields[i].SVMXC__Target_Field_Name__c)) != null)
                                {
                                    SourceUpdateRec.put(SourceUpdatesFields[i].SVMXC__Source_Field_Name__c,String.valueof(TargetSobject.get(SourceUpdatesFields[i].SVMXC__Target_Field_Name__c)));
                                }
                            }
                            else //else field type is REFERENCE,String 
                            {
                                if((String)TargetSobject.get(SourceUpdatesFields[i].SVMXC__Target_Field_Name__c) != null && f.isUpdateable())
                                {
                                    SourceUpdateRec.put(SourceUpdatesFields[i].SVMXC__Source_Field_Name__c,(String)TargetSobject.get(SourceUpdatesFields[i].SVMXC__Target_Field_Name__c));
                                }
                            }
                        }
                    }//set over
                    //Check for Increase
                    if(SourceUpdatesFields[i].SVMXC__Action__c.touppercase() == 'INCREASE' )
                    {
                        //if Source field is not null and value is null..
                        system.debug('Enterd for increase');
                        if(SourceUpdatesFields[i].SVMXC__Target_Field_Name__c != null && SourceUpdatesFields[i].SVMXC__Display_Value__c == null)
                        {   
                            //if(TargetSobject.get(SourceUpdatesFields[i].SVMXC__Target_Field_Name__c) != null )//&& SourceUpdateRec.get(SourceUpdatesFields[i].SVMXC__Source_Field_Name__c) != null
                            //{
                                Double SourceRec = (Double)(SourceUpdateRec.get(SourceUpdatesFields[i].SVMXC__Source_Field_Name__c));
                                Double TargetRec = (Double)(TargetSobject.get(SourceUpdatesFields[i].SVMXC__Target_Field_Name__c));
                                Double val = 0;
                                //if both are not null add them
                                if(SourceRec != null && TargetRec != null)
                                {
                                    val = SourceRec + TargetRec;
                                }   
                                //if target is null then consider target as zero and add the source as it is    
                                else if(TargetRec == null && SourceRec != null)
                                {
                                    val = SourceRec;
                                }
                                else if(SourceRec == null && TargetRec != null)
                                {
                                    val = TargetRec;
                                }
                                SourceUpdateRec.put(SourceUpdatesFields[i].SVMXC__Source_Field_Name__c,val);
                            //}
                        }
                        //if Source field is null and value is not null..
                        if(SourceUpdatesFields[i].SVMXC__Target_Field_Name__c == null && SourceUpdatesFields[i].SVMXC__Display_Value__c != null)//&& SourceUpdateRec.get(SourceUpdatesFields[i].SVMXC__Source_Field_Name__c) != null
                        {   
                            Double SourceRec = (Double)(SourceUpdateRec.get(SourceUpdatesFields[i].SVMXC__Source_Field_Name__c));
                            Double DisplayValue = Double.valueof(SourceUpdatesFields[i].SVMXC__Display_Value__c);
                            Double val = 0;
                            //if both are not null
                            if(SourceRec != null && DisplayValue != null)
                            { 
                                val = SourceRec + DisplayValue;
                            }
                            else if(SourceRec == null && DisplayValue != null)
                            {
                                val = DisplayValue;
                            }   
                            SourceUpdateRec.put(SourceUpdatesFields[i].SVMXC__Source_Field_Name__c,val);
                        }       
                    }//increase over
                    //Check for Decrease
                    if(SourceUpdatesFields[i].SVMXC__Action__c.touppercase() == 'DECREASE' )
                    {
                        
                        //if Source field is not null and value is null..
                        if(SourceUpdatesFields[i].SVMXC__Target_Field_Name__c != null && SourceUpdatesFields[i].SVMXC__Display_Value__c == null)
                        {   
                            //if(TargetSobject.get(SourceUpdatesFields[i].SVMXC__Target_Field_Name__c) != null && SourceUpdateRec.get(SourceUpdatesFields[i].SVMXC__Source_Field_Name__c) != null)
                            //{
                                Double SourceRec = (Double)(SourceUpdateRec.get(SourceUpdatesFields[i].SVMXC__Source_Field_Name__c));
                                Double TargetRec = (Double)(TargetSobject.get(SourceUpdatesFields[i].SVMXC__Target_Field_Name__c));
                                Double val = 0;
                                if(SourceRec != null && TargetRec !=null)
                                { 
                                    val = SourceRec - TargetRec;
                                }
                                else if(SourceRec == null && TargetRec != null)
                                {
                                    val = val-TargetRec;
                                }
                                SourceUpdateRec.put(SourceUpdatesFields[i].SVMXC__Source_Field_Name__c,val);
                            //}
                        }
                        //if Source field is null and value is not null..
                        if(SourceUpdatesFields[i].SVMXC__Target_Field_Name__c == null && SourceUpdatesFields[i].SVMXC__Display_Value__c != null )//&& SourceUpdateRec.get(SourceUpdatesFields[i].SVMXC__Source_Field_Name__c) != null
                        {   
                            Double SourceRec = (Double)(SourceUpdateRec.get(SourceUpdatesFields[i].SVMXC__Source_Field_Name__c));
                            Double DisplayValue = Double.valueof(SourceUpdatesFields[i].SVMXC__Display_Value__c);
                            Double val = 0;
                            if(SourceRec != null && DisplayValue != null)
                            {   
                                val = SourceRec - DisplayValue;
                            }
                            else if(SourceRec == null && DisplayValue != null)
                            {
                                val = val-DisplayValue;
                            }   
                            SourceUpdateRec.put(SourceUpdatesFields[i].SVMXC__Source_Field_Name__c,val);
                        }   
                    }//decrease over
                }       
            }
            
            if(COMM_SecurityUtils.getInstance().verifyFieldAccess(new List<SObject>{SourceUpdateRec} , COMM_SecurityUtils.Access.Updateable)){   //SDL-SVMX-CREATE-UPDATE-FLS-ENFORCED
                update SourceUpdateRec;
            }
        }
    }
    public void DoDetailsSourceObjectUpdate(String SFMId,map<String,Sobject> SourceRecIdTargetObjMap,String ObjName,String AliasName,map<String,map<String,Schema.SObjectField>> AllFieldDescribe)
    {
        Set<String> SourceUpdateRecIds = new Set<String>();
        if(SourceRecIdTargetObjMap.size() > 0)
        {
            for(String s: SourceRecIdTargetObjMap.keyset())
            {
                SourceUpdateRecIds.add(s);
            }
        }
        map<String,Sobject> SourceRecIdSourceObjMap = new map<String,Sobject>();
        list<Sobject> SobjList = new list<Sobject>();
        system.debug('Entered for Sourceupdate');
        system.debug('SFMId'+SFMId);
        system.debug('SourceUpdateRecIds'+SourceUpdateRecIds);
        system.debug('ObjName'+ObjName);
        system.debug('AliasName'+AliasName);
        system.debug('AllFieldDescribe'+AllFieldDescribe);
        map<String,Schema.SObjectField> LocalFieldMap = new Map<String,Schema.SObjectField>();
        map<String, Schema.SObjectField> SourceFieldMap = new map<String, Schema.SObjectField>();
        List<SVMXC__ServiceMax_Processes__c> ProcessNodeObject = new  List<SVMXC__ServiceMax_Processes__c>();
        list<SVMXC__ServiceMax_Config_Data__c> SourceUpdatesFields = new list<SVMXC__ServiceMax_Config_Data__c>();
        String SourceObjectName = '';
        String TargetObjectName = '';
        if(AllFieldDescribe.containskey(ObjName))
            LocalFieldMap = AllFieldDescribe.get(ObjName);
        //Start Processing for the Header source update.
        //first get the process node object from the sfm process 
        if(SFMId != null && PNodeObjRTypeID != null && PNodeObjRTypeID.length() > 0)
        {
            
            if(ObjName != null && AliasName == null)
                ProcessNodeObject = [select id,Name,RecordTypeId,SVMXC__ProcessID__c,SVMXC__Process__c,SVMXC__Source_Object_Name__c,SVMXC__Submodule__c,SVMXC__Module__c,SVMXC__Final_Exception_Process__c,SVMXC__Sequence__c,SVMXC__Node_Parent_API__c,SVMXC__Node_Source_Object_API__c,SVMXC__Node_Parent__c,SVMXC__Parent_Object__c,SVMXC__Target_Object_label__c,SVMXC__Type__c,SVMXC__Page_Layout__c,SVMXC__Parent_Column_Name__c from SVMXC__ServiceMax_Processes__c where RecordTypeId =: PNodeObjRTypeID and SVMXC__Process__c =: SFMId and SVMXC__Source_Object_Name__c =: ObjName and SVMXC__Type__c = 'TARGET'];    //SDL-SVMX-FLS-NOT-ENFORCED-META-DATA
            if(ObjName != null && AliasName != null)
                ProcessNodeObject = [select id,Name,RecordTypeId,SVMXC__ProcessID__c,SVMXC__Process__c,SVMXC__Source_Object_Name__c,SVMXC__Submodule__c,SVMXC__Module__c,SVMXC__Final_Exception_Process__c,SVMXC__Sequence__c,SVMXC__Node_Parent_API__c,SVMXC__Node_Source_Object_API__c,SVMXC__Node_Parent__c,SVMXC__Parent_Object__c,SVMXC__Target_Object_label__c,SVMXC__Type__c,SVMXC__Page_Layout__c,SVMXC__Parent_Column_Name__c from SVMXC__ServiceMax_Processes__c where RecordTypeId =: PNodeObjRTypeID and SVMXC__Process__c =: SFMId and SVMXC__Page_Layout__c =: AliasName and SVMXC__Type__c = 'TARGETCHILD'];    //SDL-SVMX-FLS-NOT-ENFORCED-META-DATA
        }   
        //second Query the Source update defination & Source update Data from sfmid for the header object...
        if(ProcessNodeObject != null && ProcessNodeObject.size() > 0 && ProcessNodeObject[0].id != null)
            SourceUpdatesFields = [select id,Name,SVMXC__Dispatch_Process__c,SVMXC__MapID__c,SVMXC__MapID__r.SVMXC__Source_Object_Name__c,SVMXC__Source_Field_Name__c,SVMXC__Setting_ID__c,SVMXC__Setting_ID__r.SVMXC__Source_Object_Name__c,SVMXC__Setting_ID__r.SVMXC__Node_Source_Object_API__c,SVMXC__Target_Field_Name__c,SVMXC__Action__c,SVMXC__Display_Value__c,SVMXC__Configuration_Type__c,SVMXC__Object_Name__c,SVMXC__FKey_Name_Field__c,SVMXC__Field_Relationship_Name__c,SVMXC__Display_Type__c,RecordTypeId from SVMXC__ServiceMax_Config_Data__c where SVMXC__Setting_ID__c =: ProcessNodeObject[0].id and RecordTypeId =: FldMapRTypeID and SVMXC__Configuration_Type__c = 'Source Update'];   //SDL-SVMX-FLS-NOT-ENFORCED-META-DATA
        if(SourceUpdatesFields.size() > 0)
        {
            SourceObjectName = SourceUpdatesFields[0].SVMXC__Setting_ID__r.SVMXC__Node_Source_Object_API__c;
            TargetObjectName = SourceUpdatesFields[0].SVMXC__Setting_ID__r.SVMXC__Source_Object_Name__c;
            if(SourceObjectName != null && SourceObjectName.length() > 0 && SourceUpdateRecIds != null && SourceUpdateRecIds.size() > 0)
            {
                if(Allobj.containskey(SourceObjectName) && AllFieldDescribe.containskey(SourceObjectName) == false)
                {
                    map<String, Schema.SObjectField> LFieldMap = new map<String, Schema.SObjectField>();
                    map<String, Schema.SObjectField> LSourceFieldMap = new map<String, Schema.SObjectField>();
                    LFieldMap = Allobj.get(SourceObjectName).getDescribe().fields.getMap();
                    if(LFieldMap.size() > 0)
                    {
                        for(String s : LFieldMap.keyset())
                        {
                            LSourceFieldMap.put(LFieldMap.get(s).getDescribe().getName(),LFieldMap.get(s));
                        }
                    }
                    AllFieldDescribe.put(SourceObjectName,LSourceFieldMap);
                    LSourceFieldMap = AllFieldDescribe.get(SourceObjectName);
                    SobjList = BuildSobject.getINTF_BuildSobject2(SourceUpdateRecIds,SourceObjectName,null,AllFieldDescribe);
                }
                else if(Allobj.containskey(SourceObjectName) && AllFieldDescribe.containskey(SourceObjectName))
                {
                    SobjList = BuildSobject.getINTF_BuildSobject2(SourceUpdateRecIds,SourceObjectName,null,AllFieldDescribe);
                    SourceFieldMap = AllFieldDescribe.get(SourceObjectName);
                }
                system.debug('SobjList'+SobjList);  
            }   
        }
        if(SobjList.size() > 0 && SourceRecIdTargetObjMap.size() > 0)
        {
            for(Integer i = 0;i<SobjList.size();i++)
            {
                if(SobjList[i].get('Id') != null && SourceRecIdTargetObjMap.containskey(String.valueof(SobjList[i].get('Id')))) 
                    SourceRecIdSourceObjMap.put(String.valueof(SobjList[i].get('Id')),SobjList[i]);
            }
        }
        list<Sobject> UpdateRecords = new list<Sobject> ();
        if(SourceUpdatesFields.size() > 0 && SourceRecIdSourceObjMap.size() > 0 && SourceRecIdTargetObjMap.size() > 0 && LocalFieldMap.size() > 0)
        {
            
            for(String s: SourceRecIdTargetObjMap.keyset())
            {
            
                Sobject SourceUpdateRec;
                Sobject TargetSobject = SourceRecIdTargetObjMap.get(s); 
                if(SourceRecIdSourceObjMap.containskey(s))
                    SourceUpdateRec = SourceRecIdSourceObjMap.get(s);
                if(SourceUpdateRec != null && TargetSobject != null)    
                {
                    for(Integer i = 0;i<SourceUpdatesFields.size();i++)
                    {
                        if(SourceUpdatesFields[i].SVMXC__Source_Field_Name__c != null && SourceFieldMap.containskey(SourceUpdatesFields[i].SVMXC__Source_Field_Name__c))
                        {
                            //Check for Set
                            if(SourceUpdatesFields[i].SVMXC__Action__c.touppercase() == 'SET' )//EQ
                            {
                                //if Target field API Name is null and value is not null..
                                if(SourceUpdatesFields[i].SVMXC__Target_Field_Name__c == null && SourceUpdatesFields[i].SVMXC__Display_Value__c != null)
                                {
                                   //Desctibe the field to check differen attributes of fields..
                                    Schema.DescribeFieldResult f = SourceFieldMap.get(SourceUpdatesFields[i].SVMXC__Source_Field_Name__c).getDescribe();
                                    if((f.getType() == schema.Displaytype.Double  || f.getType() == schema.Displaytype.Percent || f.getType() == schema.Displaytype.Currency)&& f.isCreateable())//if Field Type is Double,persent,currency 
                                    {
                                        if(double.valueOf(SourceUpdatesFields[i].SVMXC__Source_Field_Name__c) != null )
                                        {
                                            SourceUpdateRec.put(SourceUpdatesFields[i].SVMXC__Source_Field_Name__c,(double.valueOf(SourceUpdatesFields[i].SVMXC__Display_Value__c)));
                                        }   
                                    }
                                    else if(f.getType() == schema.Displaytype.Integer && f.isCreateable())//if field type is Integer
                                    {
                                        if(Integer.valueof(SourceUpdatesFields[i].SVMXC__Display_Value__c)!= null)
                                        {
                                            SourceUpdateRec.put(SourceUpdatesFields[i].SVMXC__Source_Field_Name__c,Integer.valueof(SourceUpdatesFields[i].SVMXC__Display_Value__c));
                                        }   
                                    }
                                    else if(f.getType() == schema.Displaytype.Boolean && f.isCreateable())//if field type is Boolean
                                    {
                                        if(Boolean.valueof(SourceUpdatesFields[i].SVMXC__Display_Value__c)!= null)
                                        {
                                            SourceUpdateRec.put(SourceUpdatesFields[i].SVMXC__Source_Field_Name__c,Boolean.valueof(SourceUpdatesFields[i].SVMXC__Display_Value__c));
                                        }   
                                    }
                                    else if(f.getType() == schema.Displaytype.DateTime && f.isCreateable())//if field type is DateTime
                                    {
                                        if(SourceUpdatesFields[i].SVMXC__Display_Value__c.touppercase() == 'TODAY')
                                        {
                                            system.debug('Enterd for Today');
                                            SourceUpdateRec.put(SourceUpdatesFields[i].SVMXC__Source_Field_Name__c,system.today());
                                        }   
                                        else if(SourceUpdatesFields[i].SVMXC__Display_Value__c.touppercase() == 'YESTERDAY')
                                        {
                                            system.debug('Enterd for YESTERDAY');
                                            SourceUpdateRec.put(SourceUpdatesFields[i].SVMXC__Source_Field_Name__c,system.today() - 1);
                                        }       
                                        else if(SourceUpdatesFields[i].SVMXC__Display_Value__c.touppercase() == 'TOMORROW')
                                        {
                                            system.debug('Enterd for TOMORROW');
                                            SourceUpdateRec.put(SourceUpdatesFields[i].SVMXC__Source_Field_Name__c,system.today() + 1);
                                        }
                                        else if(SourceUpdatesFields[i].SVMXC__Display_Value__c.touppercase() == 'NOW')
                                        {
                                            system.debug('Enterd for TOMORROW');
                                            SourceUpdateRec.put(SourceUpdatesFields[i].SVMXC__Source_Field_Name__c,system.now());
                                        }
                                        else
                                        {           
                                            SourceUpdateRec.put(SourceUpdatesFields[i].SVMXC__Source_Field_Name__c,DateTime.valueof(SourceUpdatesFields[i].SVMXC__Display_Value__c));
                                        }
                                                
                                    }
                                    else if(f.getType() == schema.Displaytype.Date && f.isCreateable())//if field type is Date
                                    {
                                        if(SourceUpdatesFields[i].SVMXC__Display_Value__c.touppercase() == 'TODAY')
                                        {
                                            system.debug('Enterd for Today');
                                            SourceUpdateRec.put(SourceUpdatesFields[i].SVMXC__Source_Field_Name__c,system.today());
                                        }   
                                        else if(SourceUpdatesFields[i].SVMXC__Display_Value__c.touppercase() == 'YESTERDAY')
                                        {
                                            system.debug('Enterd for YESTERDAY');
                                            SourceUpdateRec.put(SourceUpdatesFields[i].SVMXC__Source_Field_Name__c,system.today() - 1);
                                        }       
                                        else if(SourceUpdatesFields[i].SVMXC__Display_Value__c.touppercase() == 'TOMORROW')
                                        {
                                            system.debug('Enterd for TOMORROW');
                                            SourceUpdateRec.put(SourceUpdatesFields[i].SVMXC__Source_Field_Name__c,system.today() + 1);
                                        }
                                        else
                                        {           
                                            SourceUpdateRec.put(SourceUpdatesFields[i].SVMXC__Source_Field_Name__c,Date.valueof(SourceUpdatesFields[i].SVMXC__Display_Value__c));
                                        }
                                    }
                                    else if(f.getType() == schema.Displaytype.MultiPicklist && f.isCreateable())//if field type is MultiPicklist
                                    {
                                        if(String.valueof(SourceUpdatesFields[i].SVMXC__Display_Value__c) != null)
                                        {
                                            SourceUpdateRec.put(SourceUpdatesFields[i].SVMXC__Source_Field_Name__c,String.valueof(SourceUpdatesFields[i].SVMXC__Display_Value__c));
                                        }
                                    }
                                    else //else field type is REFERENCE,String 
                                    {
                                        if((String)SourceUpdatesFields[i].SVMXC__Display_Value__c != null && f.isCreateable())
                                        {
                                            SourceUpdateRec.put(SourceUpdatesFields[i].SVMXC__Source_Field_Name__c,(String)SourceUpdatesFields[i].SVMXC__Display_Value__c);
                                        }
                                    }
                                }    
                                //if Target field API Name is not null and value is null..   
                                if(SourceUpdatesFields[i].SVMXC__Target_Field_Name__c != null && SourceUpdatesFields[i].SVMXC__Display_Value__c == null)
                                {
                                    //Desctibe the field to check differen attributes of fields..
                                    Schema.DescribeFieldResult f = SourceFieldMap.get(SourceUpdatesFields[i].SVMXC__Source_Field_Name__c).getDescribe();
                                    if((f.getType() == schema.Displaytype.Double  || f.getType() == schema.Displaytype.Percent || f.getType() == schema.Displaytype.Currency)&& f.isUpdateable())//if Field Type is Double,persent,currency 
                                    {
                                        if(double.valueOf(TargetSobject.get(SourceUpdatesFields[i].SVMXC__Target_Field_Name__c)) != null )
                                        {
                                            SourceUpdateRec.put(SourceUpdatesFields[i].SVMXC__Source_Field_Name__c,(double.valueOf(TargetSobject.get(SourceUpdatesFields[i].SVMXC__Target_Field_Name__c))));
                                        }   
                                    }
                                    else if(f.getType() == schema.Displaytype.Integer && f.isUpdateable())//if field type is Integer
                                    {
                                        if(Integer.valueof(TargetSobject.get(SourceUpdatesFields[i].SVMXC__Target_Field_Name__c))!= null)
                                        {
                                            SourceUpdateRec.put(SourceUpdatesFields[i].SVMXC__Source_Field_Name__c,Integer.valueof(TargetSobject.get(SourceUpdatesFields[i].SVMXC__Target_Field_Name__c)));
                                        }   
                                    }
                                    else if(f.getType() == schema.Displaytype.Boolean && f.isUpdateable())//if field type is Boolean
                                    {
                                        if(Boolean.valueof(TargetSobject.get(SourceUpdatesFields[i].SVMXC__Target_Field_Name__c))!= null)
                                        {
                                            SourceUpdateRec.put(SourceUpdatesFields[i].SVMXC__Source_Field_Name__c,Boolean.valueof(TargetSobject.get(SourceUpdatesFields[i].SVMXC__Target_Field_Name__c)));
                                        }   
                                    }
                                    else if(f.getType() == schema.Displaytype.DateTime && f.isUpdateable())//if field type is DateTime
                                    {
                                        system.debug('asdf'+TargetSobject.get(SourceUpdatesFields[i].SVMXC__Target_Field_Name__c));
                                        if(DateTime.valueOf(TargetSobject.get(SourceUpdatesFields[i].SVMXC__Target_Field_Name__c)) != null)
                                        {
                                            SourceUpdateRec.put(SourceUpdatesFields[i].SVMXC__Source_Field_Name__c,DateTime.valueOf(TargetSobject.get(SourceUpdatesFields[i].SVMXC__Target_Field_Name__c)));
                                        }   
                                    }
                                    else if(f.getType() == schema.Displaytype.Date && f.isUpdateable())//if field type is Date
                                    {
                                        system.debug('asdf'+TargetSobject.get(SourceUpdatesFields[i].SVMXC__Target_Field_Name__c));
                                        if(Date.valueOf(TargetSobject.get(SourceUpdatesFields[i].SVMXC__Target_Field_Name__c)) != null)
                                        {
                                            SourceUpdateRec.put(SourceUpdatesFields[i].SVMXC__Source_Field_Name__c,Date.valueOf(TargetSobject.get(SourceUpdatesFields[i].SVMXC__Target_Field_Name__c)));
                                        }
                                    }
                                    else if(f.getType() == schema.Displaytype.MultiPicklist && f.isUpdateable())//if field type is MultiPicklist
                                    {
                                        if(String.valueof(TargetSobject.get(SourceUpdatesFields[i].SVMXC__Target_Field_Name__c)) != null)
                                        {
                                            SourceUpdateRec.put(SourceUpdatesFields[i].SVMXC__Source_Field_Name__c,String.valueof(TargetSobject.get(SourceUpdatesFields[i].SVMXC__Target_Field_Name__c)));
                                        }
                                    }
                                    else //else field type is REFERENCE,String 
                                    {
                                        if((String)TargetSobject.get(SourceUpdatesFields[i].SVMXC__Target_Field_Name__c) != null && f.isUpdateable())
                                        {
                                            SourceUpdateRec.put(SourceUpdatesFields[i].SVMXC__Source_Field_Name__c,(String)TargetSobject.get(SourceUpdatesFields[i].SVMXC__Target_Field_Name__c));
                                        }
                                    }
                                }
                            }//set over
                            //Check for Increase
                            if(SourceUpdatesFields[i].SVMXC__Action__c.touppercase() == 'INCREASE' )
                            {
                                system.debug('Enter in Increase');
                                //if Source field is not null and value is null..
                                if(SourceUpdatesFields[i].SVMXC__Target_Field_Name__c != null && SourceUpdatesFields[i].SVMXC__Display_Value__c == null)
                                {   
                                    //if(TargetSobject.get(SourceUpdatesFields[i].SVMXC__Target_Field_Name__c) != null && SourceUpdateRec.get(SourceUpdatesFields[i].SVMXC__Source_Field_Name__c) != null)
                                   //{
                                        Double SourceRec = (Double)(SourceUpdateRec.get(SourceUpdatesFields[i].SVMXC__Source_Field_Name__c));
                                        Double TargetRec = (Double)(TargetSobject.get(SourceUpdatesFields[i].SVMXC__Target_Field_Name__c));
                                        Double val = 0;
                                        //if both are not null add them
                                        if(SourceRec != null && TargetRec != null)
                                        {
                                            val = SourceRec + TargetRec;
                                        }   
                                        //if target is null then consider target as zero and add the source as it is    
                                        else if(TargetRec == null && SourceRec != null)
                                        {
                                            val = SourceRec;
                                        }
                                        else if(SourceRec == null && TargetRec != null)
                                        {
                                            val = TargetRec;
                                        }
                                        SourceUpdateRec.put(SourceUpdatesFields[i].SVMXC__Source_Field_Name__c,val);
                                   // }
                                }
                                //if Source field is null and value is not null..
                                if(SourceUpdatesFields[i].SVMXC__Target_Field_Name__c == null && SourceUpdatesFields[i].SVMXC__Display_Value__c != null )//&& SourceUpdateRec.get(SourceUpdatesFields[i].SVMXC__Source_Field_Name__c) != null
                                {   
                                    Double SourceRec = (Double)(SourceUpdateRec.get(SourceUpdatesFields[i].SVMXC__Source_Field_Name__c));
                                    Double DisplayValue = Double.valueof(SourceUpdatesFields[i].SVMXC__Display_Value__c);
                                    Double val = 0;
                                    //if both are not null
                                    if(SourceRec != null && DisplayValue != null)
                                    { 
                                        val = SourceRec + DisplayValue;
                                    }
                                    else if(SourceRec == null && DisplayValue != null)
                                    {
                                        val = DisplayValue;
                                    }   
                                    SourceUpdateRec.put(SourceUpdatesFields[i].SVMXC__Source_Field_Name__c,val);
                                }       
                            }//increase over
                            //Check for Decrease
                            if(SourceUpdatesFields[i].SVMXC__Action__c.touppercase() == 'DECREASE' )
                            {
                                system.debug('Enter in decrease');
                                //if Source field is not null and value is null..
                                if(SourceUpdatesFields[i].SVMXC__Target_Field_Name__c != null && SourceUpdatesFields[i].SVMXC__Display_Value__c == null)
                                {   
                                    //if(TargetSobject.get(SourceUpdatesFields[i].SVMXC__Target_Field_Name__c) != null && SourceUpdateRec.get(SourceUpdatesFields[i].SVMXC__Source_Field_Name__c) != null)
                                    //{
                                        Double SourceRec = (Double)(SourceUpdateRec.get(SourceUpdatesFields[i].SVMXC__Source_Field_Name__c));
                                        Double TargetRec = (Double)(TargetSobject.get(SourceUpdatesFields[i].SVMXC__Target_Field_Name__c));
                                        Double val = 0;
                                        if(SourceRec != null && TargetRec !=null)
                                        { 
                                            val = SourceRec - TargetRec;
                                        }
                                        else if(SourceRec == null && TargetRec != null)
                                        {
                                            val = val-TargetRec;
                                        }
                                        SourceUpdateRec.put(SourceUpdatesFields[i].SVMXC__Source_Field_Name__c,val);
                                    //}
                                }
                                //if Source field is null and value is not null..
                                if(SourceUpdatesFields[i].SVMXC__Target_Field_Name__c == null && SourceUpdatesFields[i].SVMXC__Display_Value__c != null )//&& SourceUpdateRec.get(SourceUpdatesFields[i].SVMXC__Source_Field_Name__c) != null
                                {   
                                    Double SourceRec = (Double)(SourceUpdateRec.get(SourceUpdatesFields[i].SVMXC__Source_Field_Name__c));
                                    Double DisplayValue = Double.valueof(SourceUpdatesFields[i].SVMXC__Display_Value__c);
                                    Double val = 0;
                                    if(SourceRec != null && DisplayValue != null)
                                    {   
                                        val = SourceRec - DisplayValue;
                                    }
                                    else if(SourceRec == null && DisplayValue != null)
                                    {
                                        val = val-DisplayValue;
                                    }
                                    SourceUpdateRec.put(SourceUpdatesFields[i].SVMXC__Source_Field_Name__c,val);
                                }   
                            }//decrease over
                        }       
                    }
                }    
                system.debug('SourceUpdateRec'+SourceUpdateRec);
                UpdateRecords.add(SourceUpdateRec);
            }
            system.debug('UpdateRecords'+UpdateRecords);
            
            if(COMM_SecurityUtils.getInstance().verifyFieldAccess(UpdateRecords , COMM_SecurityUtils.Access.Updateable)){   //SDL-SVMX-CREATE-UPDATE-FLS-ENFORCED
                update UpdateRecords;
            }
        }
    }   
}