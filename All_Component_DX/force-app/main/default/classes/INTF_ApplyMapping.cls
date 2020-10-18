public with sharing class INTF_ApplyMapping 
{
    SVMXC.COMM_Utils commutils = new SVMXC.COMM_Utils(); 
    public INTF_applyMapping(){}
    public List<Sobject> getApplyMapping(List<Sobject> SobjList,String SFID,String SourceRecId,Boolean DoPopulateOwner,map<String,Schema.SObjectType> Allobj)
    {
        system.debug('SourceRecId'+SourceRecId);
        map<String, Schema.SObjectField> mapTargetFieldDesc = new map<String, Schema.SObjectField>();
        //SVMXC.INTF_WebServicesDef.INTF_ObjectMap ObjectMap = new SVMXC.INTF_WebServicesDef.INTF_ObjectMap();
        SVMXC.INTF_WebServicesDef.INTF_Request Request = new SVMXC.INTF_WebServicesDef.INTF_Request();
        List<SVMXC.INTF_WebServicesDef.INTF_StringMap> stringmapList = new List<SVMXC.INTF_WebServicesDef.INTF_StringMap>();
        SVMXC.INTF_WebServicesDef.INTF_StringMap strmap = new SVMXC.INTF_WebServicesDef.INTF_StringMap();
        strmap.key = 'RECORDID';
        strmap.value = SFID;
        stringmapList.add(strmap);
        Request.stringMap = stringmapList;
        SVMXC__ServiceMax_Processes__c MapHeader = new SVMXC__ServiceMax_Processes__c();
        MapHeader = [Select SVMXC__Type__c, SVMXC__Target_Record_Type__c, SVMXC__Target_Object_label__c,SVMXC__Target_Object_Name__c, SVMXC__Submodule__c, SVMXC__SubmoduleID__c, SVMXC__Source_Object_Name__c,SVMXC__Settings_Name__c, SVMXC__Setting_Unique_ID__c, SVMXC__SettingID__c, SVMXC__Sequence__c, SVMXC__Select__c,SVMXC__Search_Order__c, SVMXC__Rule_Type__c, SVMXC__Purpose__c, SVMXC__Process__c, SVMXC__ProcessID__c,SVMXC__Parent_Object__c, SVMXC__Parent_Object_Criteria__c, SVMXC__Parent_Error_Msg__c,SVMXC__Parent_Column_Name__c, SVMXC__Page_Layout__c, SVMXC__Node_Source_Object_API__c,SVMXC__Node_Parent_API__c, SVMXC__Node_Parent__c, SVMXC__Name__c, SVMXC__Module__c, SVMXC__ModuleID__c,SVMXC__MapID__c, SVMXC__MTTS_Minutes__c,SVMXC__IsStandard__c, SVMXC__IsStandalone__c, SVMXC__IsPrivate__c, SVMXC__IsDefault__C,SVMXC__Final_Exception_Process__c,SVMXC__End_Date__c, SVMXC__Email_On_Success__c,SVMXC__Email_On_Error__c, SVMXC__Dispatch_Method__c, SVMXC__Description__c,SVMXC__Default_Value__c, SVMXC__Data_Type__c,  SVMXC__Child_Object_Criteria__c,SVMXC__Child_Error_Msg__c,SVMXC__Advance_Expression__c,SVMXC__Active__c, RecordTypeId, OwnerId, Name,LastModifiedDate, LastModifiedById,  IsDeleted, Id, CreatedDate, CreatedById From SVMXC__ServiceMax_Processes__c  where Id =: SFID];   //SDL-SVMX-FLS-NOT-ENFORCED-META-DATA
        system.debug('MapHeader'+MapHeader);
        Sobject SourceObjRecord; 
        map<String, Schema.SObjectField> FieldMap = new map<String, Schema.SObjectField>();
        if(MapHeader.SVMXC__Source_Object_Name__c != null && Allobj.containskey(MapHeader.SVMXC__Source_Object_Name__c))    
        {
            List<String> fieldlist = new List<String>();
            string fields = '';
            FieldMap = Allobj.get(MapHeader.SVMXC__Source_Object_Name__c).getDescribe().fields.getMap();
            if(FieldMap.size() > 0)
                fieldlist = commutils.SVMX_getFieldList(FieldMap,true);
            if(fieldlist.size() > 0)
                fields = commutils.SVMX_getFieldNamesFromList(fieldlist);
            system.debug('FieldMap'+FieldMap);
            system.debug('fieldlist'+fieldlist);
            system.debug('fields'+fields);  
            if(fields != null && fields.length() > 0 && SourceRecId != null && SourceRecId.length() > 0)
            {
                String Query = 'Select ' + fields + ' from ' + MapHeader.SVMXC__Source_Object_Name__c + ' where id = ' +  '\''+SourceRecId+'\'';
                system.debug('Query'+Query);
                SourceObjRecord = Database.query(Query);
            }
        }
        system.debug('SourceObjRecord'+SourceObjRecord);
        //get the Field mapping records
        //List<SVMXC.INTF_WebServicesDef.INTF_FieldMapping> FieldMapWrapper = new List<SVMXC.INTF_WebServicesDef.INTF_FieldMapping>(); 
        List<SVMXC__ServiceMax_Config_Data__c> FieldMappingList = new List<SVMXC__ServiceMax_Config_Data__c>(); 
        if(MapHeader != null && MapHeader.id != null)
            FieldMappingList = [Select SystemModstamp, SVMXC__User__c, SVMXC__Target_Field_Name__c,SVMXC__Stock_Status__c,SVMXC__Stock_History_Line_Lookup_Field__c, SVMXC__Stock_History_Header_Lookup_Field__c, SVMXC__Source_Field_Name__c, SVMXC__Setting_Unique_ID__c, SVMXC__Setting_ID__c, SVMXC__Setting_Configuration_Profile__c, SVMXC__SettingID__c, SVMXC__Sequence__c, SVMXC__Select__c, SVMXC__Search_Object_Field_Type__c, SVMXC__Object_Name__c, SVMXC__FKey_Name_Field__c, SVMXC__RecordType_Name__c, SVMXC__Profile__c, SVMXC__Profile_Name__c, SVMXC__Preference_3__c, SVMXC__Preference_2__c,SVMXC__Operator__c, SVMXC__Operand__c, SVMXC__MapID__c, SVMXC__Lookup_Field_API_Name__c, SVMXC__Location_Type__c, SVMXC__Location_Field_Name__c, SVMXC__Location_Field_From__c, SVMXC__IsDefault__c, SVMXC__Inventory_Process__c,SVMXC__Internal_Value__c, SVMXC__Installation_Key__c,SVMXC__Field_Relationship_Name__c, SVMXC__Field_Name__c,SVMXC__Expression_Type__c, SVMXC__Expression_Rule__c, SVMXC__Enter_Date__c,SVMXC__Enable_Task__c, SVMXC__Enable_Calendar__c, SVMXC__Enable_Activity_Tracking_On__c,SVMXC__Display_Value__c, SVMXC__Display_Type__c, SVMXC__Display_Map_ID__c, SVMXC__Dispatch_Process__c,SVMXC__Description__c, SVMXC__Configuration_Type__c, SVMXC__Config_Profile_Name__c, SVMXC__Active__c,SVMXC__Action__c, SVMXC__Access_Configuration_Profile__c, RecordTypeId, OwnerId, Name, LastModifiedDate,LastModifiedById,  IsDeleted, Id,CreatedDate, CreatedById From SVMXC__ServiceMax_Config_Data__c  where SVMXC__MapID__c =: MapHeader.id];  //SDL-SVMX-FLS-NOT-ENFORCED-META-DATA
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
        if(MapHeader.SVMXC__Target_Object_Name__c != null && Allobj.containskey(MapHeader.SVMXC__Target_Object_Name__c))
        {
            map<String, Schema.SObjectField> LFieldMap = new map<String, Schema.SObjectField>();
            LFieldMap = Allobj.get(MapHeader.SVMXC__Target_Object_Name__c).getDescribe().fields.getMap();
            if(LFieldMap.size() > 0)
            {
                for(String s : LFieldMap.keyset())
                {
                    mapTargetFieldDesc.put(LFieldMap.get(s).getDescribe().getName(),LFieldMap.get(s));
                }
            }
        } 
        system.debug('mapTargetFieldDesc'+mapTargetFieldDesc);
        if(SobjList.size() > 0 && FieldMappingList.size() > 0)
        {
            List<RecordType> RecordtypeLst = new List<RecordType>();
            if(MapHeader.SVMXC__Target_Object_Name__c != null)
                RecordtypeLst = [Select SystemModstamp, SobjectType, NamespacePrefix, Name, LastModifiedDate, LastModifiedById, IsActive, Id, DeveloperName, Description, CreatedDate, CreatedById, BusinessProcessId From RecordType where SobjectType =: MapHeader.SVMXC__Target_Object_Name__c];   //SDL-SVMX-FLS-NOT-ENFORCED-META-DATA
            system.debug('RecordtypeLst'+RecordtypeLst);
            for(Integer i = 0;i<SobjList.size();i++)
            {
                if(DoPopulateOwner && TargetFieldsSet.size() > 0 && TargetFieldsSet.contains('OwnerId') == false && mapTargetFieldDesc.containskey('OwnerId'))
                {
                    SobjList[i].put('OwnerId',Userinfo.getUserId());
                }
                //check for the value map
                if(MapHeader.SVMXC__Source_Object_Name__c == null)
                {
                    system.debug('Enter for the value map');
                    for(Integer j = 0;j<FieldMappingList.size();j++)
                    {
                        if(FieldMappingList[j].SVMXC__Source_Field_Name__c != null && FieldMappingList[j].SVMXC__Display_Value__c != null)
                            SobjList[i].put(FieldMappingList[j].SVMXC__Source_Field_Name__c,FieldMappingList[j].SVMXC__Display_Value__c);
                    }
                }
                //Field Map
                if(MapHeader.SVMXC__Source_Object_Name__c != null)
                {
                    system.debug('Enter for the field map');
                    for(Integer j = 0;j<FieldMappingList.size();j++)
                    {
                        if(FieldMappingList[j].SVMXC__Target_Field_Name__c != null)
                        {
                            system.debug('Targer Field: '+FieldMappingList[j].SVMXC__Target_Field_Name__c);
                            if(FieldMappingList[j].SVMXC__Target_Field_Name__c == 'RecordTypeId')
                            {
                                system.debug('Display Val: '+FieldMappingList[j].SVMXC__Display_Value__c+'SourceFieldName :'+FieldMappingList[j].SVMXC__Source_Field_Name__c);
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
                            else
                            {
                                system.debug('Its not Record Type');
                                if(FieldMappingList[j].SVMXC__Source_Field_Name__c != null && String.valueof(SourceObjRecord.get(FieldMappingList[j].SVMXC__Source_Field_Name__c)) != null)
                                {   
                                    system.debug('Entered in first');
                                    SobjList[i].put(FieldMappingList[j].SVMXC__Target_Field_Name__c,SourceObjRecord.get(FieldMappingList[j].SVMXC__Source_Field_Name__c));
                                }    
                                else if(FieldMappingList[j].SVMXC__Source_Field_Name__c != null && String.valueof(SourceObjRecord.get(FieldMappingList[j].SVMXC__Source_Field_Name__c)) == null && FieldMappingList[j].SVMXC__Preference_2__c != null && String.valueof(SourceObjRecord.get(FieldMappingList[j].SVMXC__Preference_2__c)) != null)
                                {
                                    system.debug('Entered in second');
                                    SobjList[i].put(FieldMappingList[j].SVMXC__Target_Field_Name__c,SourceObjRecord.get(FieldMappingList[j].SVMXC__Preference_2__c));
                                }    
                                else if(FieldMappingList[j].SVMXC__Source_Field_Name__c != null && String.valueof(SourceObjRecord.get(FieldMappingList[j].SVMXC__Source_Field_Name__c)) == null && FieldMappingList[j].SVMXC__Preference_2__c != null && String.valueof(SourceObjRecord.get(FieldMappingList[j].SVMXC__Preference_2__c)) == null && FieldMappingList[j].SVMXC__Preference_3__c != null && String.valueof(SourceObjRecord.get(FieldMappingList[j].SVMXC__Preference_3__c)) != null)
                                {
                                    system.debug('Entered in third');
                                    SobjList[i].put(FieldMappingList[j].SVMXC__Target_Field_Name__c,SourceObjRecord.get(FieldMappingList[j].SVMXC__Preference_3__c));
                                }    
                                system.debug('zzzzzzzz1'+FieldMappingList[j].SVMXC__Target_Field_Name__c);
                                system.debug('zzzzzzzz2'+FieldMappingList[j].SVMXC__Display_Value__c);
                                system.debug('zzzzzzzz3'+FieldMappingList[j].SVMXC__Target_Field_Name__c);
                                system.debug('zzzzzzzz4'+mapTargetFieldDesc.containskey(FieldMappingList[j].SVMXC__Target_Field_Name__c));
                                if(FieldMappingList[j].SVMXC__Source_Field_Name__c  == null && FieldMappingList[j].SVMXC__Preference_2__c == null  && FieldMappingList[j].SVMXC__Preference_3__c == null && FieldMappingList[j].SVMXC__Display_Value__c != null && mapTargetFieldDesc.containskey(FieldMappingList[j].SVMXC__Target_Field_Name__c))
                                {
                                    //Desctibe the field to check differen attributes of fields..
                                    Schema.DescribeFieldResult f = mapTargetFieldDesc.get(FieldMappingList[j].SVMXC__Target_Field_Name__c).getDescribe();
                                    if((f.getType() == schema.Displaytype.Double  || f.getType() == schema.Displaytype.Percent || f.getType() == schema.Displaytype.Currency)&& f.isCreateable())//if Field Type is Double,persent,currency 
                                    {
                                        if(double.valueOf(FieldMappingList[j].SVMXC__Display_Value__c) != null )
                                        {
                                            SobjList[i].put(FieldMappingList[j].SVMXC__Target_Field_Name__c,(double.valueOf(FieldMappingList[j].SVMXC__Display_Value__c)));
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
                                        system.debug('asdf'+FieldMappingList[j].SVMXC__Display_Value__c);
                                        if(FieldMappingList[j].SVMXC__Display_Value__c.touppercase() == 'TODAY')
                                        {
                                            system.debug('Enterd for Today');
                                            SobjList[i].put(FieldMappingList[j].SVMXC__Target_Field_Name__c,datetime.newInstance(system.today(), time.newInstance(0, 0, 0, 0)));
                                        }   
                                        else if(FieldMappingList[j].SVMXC__Display_Value__c.touppercase() == 'YESTERDAY')
                                        {
                                            system.debug('Enterd for YESTERDAY');
                                            SobjList[i].put(FieldMappingList[j].SVMXC__Target_Field_Name__c,datetime.newInstance(system.today()-1, time.newInstance(0, 0, 0, 0)));
                                        }       
                                        else if(FieldMappingList[j].SVMXC__Display_Value__c.touppercase() == 'TOMORROW')
                                        {
                                            system.debug('Enterd for TOMORROW');
                                            SobjList[i].put(FieldMappingList[j].SVMXC__Target_Field_Name__c,datetime.newInstance(system.today()+1, time.newInstance(0, 0, 0, 0)));
                                        }
                                        else if(FieldMappingList[j].SVMXC__Display_Value__c.touppercase() == 'NOW')
                                        {
                                            system.debug('Enterd for NOW');
                                            SobjList[i].put(FieldMappingList[j].SVMXC__Target_Field_Name__c,system.now());
                                        }
                                        else
                                        {           
                                            SobjList[i].put(FieldMappingList[j].SVMXC__Target_Field_Name__c,DateTime.valueof(FieldMappingList[j].SVMXC__Display_Value__c));
                                        }
                                                
                                    }
                                    else if(f.getType() == schema.Displaytype.Date && f.isCreateable())//if field type is Date
                                    {
                                        system.debug('asdf'+FieldMappingList[j].SVMXC__Display_Value__c);
                                        if(FieldMappingList[j].SVMXC__Display_Value__c.touppercase() == 'TODAY')
                                        {
                                            system.debug('Enterd for Today');
                                            SobjList[i].put(FieldMappingList[j].SVMXC__Target_Field_Name__c,system.today());
                                        }   
                                        else if(FieldMappingList[j].SVMXC__Display_Value__c.touppercase() == 'YESTERDAY')
                                        {
                                            system.debug('Enterd for YESTERDAY');
                                            SobjList[i].put(FieldMappingList[j].SVMXC__Target_Field_Name__c,system.today() - 1);
                                        }       
                                        else if(FieldMappingList[j].SVMXC__Display_Value__c.touppercase() == 'TOMORROW')
                                        {
                                            system.debug('Enterd for TOMORROW');
                                            SobjList[i].put(FieldMappingList[j].SVMXC__Target_Field_Name__c,system.today() + 1);
                                        }
                                        else
                                        {           
                                            SobjList[i].put(FieldMappingList[j].SVMXC__Target_Field_Name__c,Date.valueof(FieldMappingList[j].SVMXC__Display_Value__c));
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
        system.debug('SobjList'+SobjList); 
        return SobjList;
    }
    public List<Sobject> getApplyMapping1(String SFID,map<String,Sobject> SourceRecIdTargetObjMap,Boolean DoPopulateOwner,map<String,Schema.SObjectType> Allobj)
    {
        return getApplyMappingCore(SFID, SourceRecIdTargetObjMap, DoPopulateOwner, Allobj).values();
    }
    
    public Map<String,Sobject> getApplyMappingCore(String SFID,map<String,Sobject> SourceRecIdTargetObjMap,Boolean DoPopulateOwner,map<String,Schema.SObjectType> Allobj)
    {
        system.debug('SourceRecIdTargetObjMap'+SourceRecIdTargetObjMap.size()+SourceRecIdTargetObjMap);
        map<String, Schema.SObjectField> FieldMap = new map<String, Schema.SObjectField>();
        map<String, Schema.SObjectField> mapTargetFieldDesc = new map<String, Schema.SObjectField>();
        //list<Sobject> SobjectList = new list<Sobject>();
        Map<String,Sobject> mapFinalSourceRecIdTargetObj = new Map<String,Sobject>();
        Set<String> SourceRecIds = new Set<String>();
        map<String,Sobject> SourceRecMap = new map<String,Sobject>(); 
        if(SourceRecIdTargetObjMap.size() > 0)
        {
            for(String s : SourceRecIdTargetObjMap.keyset())
            {
                SourceRecIds.add(s);
            }
        }
        SVMXC__ServiceMax_Processes__c MapHeader = new SVMXC__ServiceMax_Processes__c();
        MapHeader = [Select SVMXC__Type__c, SVMXC__Target_Record_Type__c, SVMXC__Target_Object_label__c,SVMXC__Target_Object_Name__c, SVMXC__Submodule__c, SVMXC__SubmoduleID__c, SVMXC__Source_Object_Name__c,SVMXC__Settings_Name__c, SVMXC__Setting_Unique_ID__c, SVMXC__SettingID__c, SVMXC__Sequence__c, SVMXC__Select__c,SVMXC__Search_Order__c, SVMXC__Rule_Type__c, SVMXC__Purpose__c, SVMXC__Process__c, SVMXC__ProcessID__c,SVMXC__Parent_Object__c, SVMXC__Parent_Object_Criteria__c, SVMXC__Parent_Error_Msg__c,SVMXC__Parent_Column_Name__c, SVMXC__Page_Layout__c, SVMXC__Node_Source_Object_API__c,SVMXC__Node_Parent_API__c, SVMXC__Node_Parent__c, SVMXC__Name__c, SVMXC__Module__c, SVMXC__ModuleID__c,SVMXC__MapID__c, SVMXC__MTTS_Minutes__c,SVMXC__IsStandard__c, SVMXC__IsStandalone__c, SVMXC__IsPrivate__c, SVMXC__IsDefault__C,SVMXC__Final_Exception_Process__c,SVMXC__End_Date__c, SVMXC__Email_On_Success__c,SVMXC__Email_On_Error__c, SVMXC__Dispatch_Method__c, SVMXC__Description__c,SVMXC__Default_Value__c, SVMXC__Data_Type__c,  SVMXC__Child_Object_Criteria__c,SVMXC__Child_Error_Msg__c,SVMXC__Advance_Expression__c,SVMXC__Active__c, RecordTypeId, OwnerId, Name,LastModifiedDate, LastModifiedById,  IsDeleted, Id, CreatedDate, CreatedById From SVMXC__ServiceMax_Processes__c  where Id =: SFID];   //SDL-SVMX-FLS-NOT-ENFORCED-META-DATA
        system.debug('MapHeader'+MapHeader);
        List<SVMXC__ServiceMax_Config_Data__c> FieldMappingList = new List<SVMXC__ServiceMax_Config_Data__c>(); 
        if(MapHeader != null && MapHeader.id != null)
            FieldMappingList = [Select SystemModstamp, SVMXC__User__c, SVMXC__Target_Field_Name__c,SVMXC__Stock_Status__c,SVMXC__Stock_History_Line_Lookup_Field__c, SVMXC__Stock_History_Header_Lookup_Field__c, SVMXC__Source_Field_Name__c, SVMXC__Setting_Unique_ID__c, SVMXC__Setting_ID__c, SVMXC__Setting_Configuration_Profile__c, SVMXC__SettingID__c, SVMXC__Sequence__c, SVMXC__Select__c, SVMXC__Search_Object_Field_Type__c, SVMXC__Object_Name__c, SVMXC__FKey_Name_Field__c, SVMXC__RecordType_Name__c, SVMXC__Profile__c, SVMXC__Profile_Name__c, SVMXC__Preference_3__c, SVMXC__Preference_2__c,SVMXC__Operator__c, SVMXC__Operand__c, SVMXC__MapID__c, SVMXC__Lookup_Field_API_Name__c, SVMXC__Location_Type__c, SVMXC__Location_Field_Name__c, SVMXC__Location_Field_From__c, SVMXC__IsDefault__c, SVMXC__Inventory_Process__c,SVMXC__Internal_Value__c, SVMXC__Installation_Key__c,SVMXC__Field_Relationship_Name__c, SVMXC__Field_Name__c,SVMXC__Expression_Type__c, SVMXC__Expression_Rule__c, SVMXC__Enter_Date__c,SVMXC__Enable_Task__c, SVMXC__Enable_Calendar__c, SVMXC__Enable_Activity_Tracking_On__c,SVMXC__Display_Value__c, SVMXC__Display_Type__c, SVMXC__Display_Map_ID__c, SVMXC__Dispatch_Process__c,SVMXC__Description__c, SVMXC__Configuration_Type__c, SVMXC__Config_Profile_Name__c, SVMXC__Active__c,SVMXC__Action__c, SVMXC__Access_Configuration_Profile__c, RecordTypeId, OwnerId, Name, LastModifiedDate,LastModifiedById,  IsDeleted, Id,CreatedDate, CreatedById From SVMXC__ServiceMax_Config_Data__c  where SVMXC__MapID__c =: MapHeader.id];   //SDL-SVMX-FLS-NOT-ENFORCED-META-DATA
        system.debug('FieldMappingList'+FieldMappingList.size()+FieldMappingList);
        set<String> TargetFieldsSet = new set<String>();
        Set<String> sourceFieldsSet = new Set<String>(); //Added for fixing defect 045064
        if(!(FieldMappingList.isEmpty()))
        {
            for(SVMXC__ServiceMax_Config_Data__c configData : FieldMappingList)
            {
                if(configData.SVMXC__Target_Field_Name__c != null)
                    TargetFieldsSet.add(configData.SVMXC__Target_Field_Name__c);

                //-----Start------Added for fixing defect 045064------------//
                if(configData.SVMXC__Source_Field_Name__c != null)
                    sourceFieldsSet.add(configData.SVMXC__Source_Field_Name__c);
                if(configData.SVMXC__Preference_2__c != null)
                    sourceFieldsSet.add(configData.SVMXC__Preference_2__c);
                if(configData.SVMXC__Preference_3__c != null)
                    sourceFieldsSet.add(configData.SVMXC__Preference_3__c);
                //------End-----Added for fixing defect 045064------------//
            }
        }
        System.debug('sourceFieldsSet: '+sourceFieldsSet);
        //Get the Target object Fields 
        if(MapHeader.SVMXC__Target_Object_Name__c != null && Allobj.containskey(MapHeader.SVMXC__Target_Object_Name__c))
        {
            map<String, Schema.SObjectField> LFieldMap = new map<String, Schema.SObjectField>();
            LFieldMap = Allobj.get(MapHeader.SVMXC__Target_Object_Name__c).getDescribe().fields.getMap();
            if(LFieldMap.size() > 0)
            {
                for(String s : LFieldMap.keyset())
                {
                    mapTargetFieldDesc.put(LFieldMap.get(s).getDescribe().getName(),LFieldMap.get(s));
                }
            }
        }  
        system.debug('mapTargetFieldDesc'+mapTargetFieldDesc);    
        //Get the Source Records...
        list<Sobject> SourceObjRecordlist = new list<Sobject>();
        system.debug('SourceObjName: '+MapHeader.SVMXC__Source_Object_Name__c+Allobj.containskey(MapHeader.SVMXC__Source_Object_Name__c));
        if(MapHeader.SVMXC__Source_Object_Name__c != null && Allobj.containskey(MapHeader.SVMXC__Source_Object_Name__c))    
        {
            //Added this if condition block for fixing defect 045064 - to avoid querying all the fields of source object and ass a result it will reduce heap memory
            String fields = '';
            if(sourceFieldsSet != null && sourceFieldsSet.size() > 0){
                List<String> lstSourceFields = new List<String>();
                lstSourceFields.addAll(sourceFieldsSet);
                fields = commutils.SVMX_getFieldNamesFromList(lstSourceFields);
            }
            else{
                List<String> fieldlist = new List<String>();
                FieldMap = Allobj.get(MapHeader.SVMXC__Source_Object_Name__c).getDescribe().fields.getMap();
                if(FieldMap.size() > 0)
                    fieldlist = commutils.SVMX_getFieldList(FieldMap,true);
                if(fieldlist.size() > 0)
                    fields = commutils.SVMX_getFieldNamesFromList(fieldlist);
                system.debug('FieldMap'+FieldMap);
                system.debug('fieldlist'+fieldlist);
                system.debug('fields'+fields); 
            }

            if(fields != null && fields.length() > 0 && SourceRecIds != null && SourceRecIds.size() > 0)
            {
                String Query = 'Select ' + fields + ' from ' + MapHeader.SVMXC__Source_Object_Name__c + ' where id  IN : SourceRecIds';     //= ' +  '\''+SourceRecId+'\'';
                system.debug('Query'+Query);
                SourceObjRecordlist = Database.query(Query);
            }
        }
        if(MapHeader.SVMXC__Target_Object_Name__c != null && MapHeader.SVMXC__Target_Object_Name__c.length() > 0 && Allobj.containskey(MapHeader.SVMXC__Target_Object_Name__c)){
            map<String, Schema.SObjectField> mapFieldDesc = Allobj.get(MapHeader.SVMXC__Target_Object_Name__c).getDescribe().fields.getMap();
            if(mapFieldDesc.size() > 0){
                for(String str : mapFieldDesc.keyset()){
                    mapTargetFieldDesc.put(mapFieldDesc.get(str).getDescribe().getName(),mapFieldDesc.get(str));
                }
            }
        }
        system.debug('SourceObjRecordlist'+SourceObjRecordlist);
        if(SourceObjRecordlist.size() > 0 && SourceRecIdTargetObjMap.size() > 0)
        {
            for(Integer i = 0;i<SourceObjRecordlist.size();i++)
            {
                if(SourceObjRecordlist[i].get('id') != null && SourceRecIdTargetObjMap.containskey(String.valueof(SourceObjRecordlist[i].get('id'))))
                    SourceRecMap.put(String.valueof(SourceObjRecordlist[i].get('id')),SourceObjRecordlist[i]);
            }
        }
        system.debug('SourceRecMap'+SourceRecMap);
        if(SourceRecIdTargetObjMap.size() > 0 && FieldMappingList.size() > 0 && SourceRecMap.size() > 0)
        {
            
            List<RecordType> RecordtypeLst = new List<RecordType>();
            if(MapHeader.SVMXC__Target_Object_Name__c != null)
                RecordtypeLst = [Select SystemModstamp, SobjectType, NamespacePrefix, Name, LastModifiedDate, LastModifiedById, IsActive, Id, DeveloperName, Description, CreatedDate, CreatedById, BusinessProcessId From RecordType where SobjectType =: MapHeader.SVMXC__Target_Object_Name__c];   //SDL-SVMX-FLS-NOT-ENFORCED-META-DATA
            system.debug('RecordtypeLst'+RecordtypeLst);
            for(String s1 : SourceRecIdTargetObjMap.keyset())
            {
                Sobject Sobj = SourceRecIdTargetObjMap.get(s1);
                system.debug('TargetRecord : '+Sobj);
                Sobject SourceObjRecord;
                if(SourceRecMap.containskey(s1))
                    SourceObjRecord = SourceRecMap.get(s1);
                if(DoPopulateOwner && TargetFieldsSet.size() > 0 && TargetFieldsSet.contains('OwnerId') == false && mapTargetFieldDesc.containskey('OwnerId'))
                {
                    Sobj.put('OwnerId',Userinfo.getUserId());
                }
                //check for the value map
                if(MapHeader.SVMXC__Source_Object_Name__c == null)
                {
                    system.debug('Enter for the value map');
                    for(Integer j = 0;j<FieldMappingList.size();j++)
                    {
                        if(FieldMappingList[j].SVMXC__Source_Field_Name__c != null && FieldMappingList[j].SVMXC__Display_Value__c != null)
                            Sobj.put(FieldMappingList[j].SVMXC__Source_Field_Name__c,FieldMappingList[j].SVMXC__Display_Value__c);
                    }
                }
                //Field Map
                if(MapHeader.SVMXC__Source_Object_Name__c != null)
                {
                    system.debug('Enter for the field map');
                    for(Integer j = 0;j<FieldMappingList.size();j++)
                    {
                        if(FieldMappingList[j].SVMXC__Target_Field_Name__c != null)
                        {
                            system.debug('asdfgh'+FieldMappingList[j].SVMXC__Target_Field_Name__c);
                            if(FieldMappingList[j].SVMXC__Target_Field_Name__c == 'RecordTypeId')
                            {
                                system.debug('Display Val: '+FieldMappingList[j].SVMXC__Display_Value__c+' SourceFieldName :'+FieldMappingList[j].SVMXC__Source_Field_Name__c);
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
                                    system.debug('Its Record Type'+RecordTypeId); 
                                    if(RecordTypeId != null && RecordTypeId.length() > 0)
                                        Sobj.put(FieldMappingList[j].SVMXC__Target_Field_Name__c,RecordTypeId);
                                }
                                else if(FieldMappingList[j].SVMXC__Source_Field_Name__c != null && SourceObjRecord.get(FieldMappingList[j].SVMXC__Source_Field_Name__c) !=  null)
                                {
                                    Sobj.put(FieldMappingList[j].SVMXC__Target_Field_Name__c,String.valueof(SourceObjRecord.get(FieldMappingList[j].SVMXC__Source_Field_Name__c)));
                                }        
                            }
                            else
                            {
                                system.debug('Its not Record Type'+FieldMappingList[j].SVMXC__Source_Field_Name__c + 'Source Object Record: ' + SourceObjRecord);
                                if(FieldMappingList[j].SVMXC__Source_Field_Name__c != null && SourceObjRecord.get(FieldMappingList[j].SVMXC__Source_Field_Name__c) != null && String.valueof(SourceObjRecord.get(FieldMappingList[j].SVMXC__Source_Field_Name__c)) != null)
                                {   
                                    system.debug('Entered in first'+ FieldMappingList[j].SVMXC__Target_Field_Name__c+' : '+FieldMappingList[j].SVMXC__Source_Field_Name__c + ' : '+SourceObjRecord.get(FieldMappingList[j].SVMXC__Source_Field_Name__c));
                                    Sobj.put(FieldMappingList[j].SVMXC__Target_Field_Name__c,SourceObjRecord.get(FieldMappingList[j].SVMXC__Source_Field_Name__c));
                                }    
                                else if(FieldMappingList[j].SVMXC__Source_Field_Name__c != null && SourceObjRecord.get(FieldMappingList[j].SVMXC__Source_Field_Name__c) == null && FieldMappingList[j].SVMXC__Preference_2__c != null && String.valueof(SourceObjRecord.get(FieldMappingList[j].SVMXC__Preference_2__c)) != null)
                                {
                                    system.debug('Entered in second');
                                    Sobj.put(FieldMappingList[j].SVMXC__Target_Field_Name__c,SourceObjRecord.get(FieldMappingList[j].SVMXC__Preference_2__c));
                                }    
                                else if(FieldMappingList[j].SVMXC__Source_Field_Name__c != null && SourceObjRecord.get(FieldMappingList[j].SVMXC__Source_Field_Name__c) == null && FieldMappingList[j].SVMXC__Preference_2__c != null && String.valueof(SourceObjRecord.get(FieldMappingList[j].SVMXC__Preference_2__c)) == null && FieldMappingList[j].SVMXC__Preference_3__c != null && String.valueof(SourceObjRecord.get(FieldMappingList[j].SVMXC__Preference_3__c)) != null)
                                {
                                    system.debug('Entered in third');
                                    Sobj.put(FieldMappingList[j].SVMXC__Target_Field_Name__c,SourceObjRecord.get(FieldMappingList[j].SVMXC__Preference_3__c));
                                }    
                                if(FieldMappingList[j].SVMXC__Source_Field_Name__c  == null && FieldMappingList[j].SVMXC__Preference_2__c == null  && FieldMappingList[j].SVMXC__Preference_3__c == null && FieldMappingList[j].SVMXC__Display_Value__c != null && mapTargetFieldDesc.containskey(FieldMappingList[j].SVMXC__Target_Field_Name__c))
                                {
                                    //Desctibe the field to check differen attributes of fields..
                                    Schema.DescribeFieldResult f = mapTargetFieldDesc.get(FieldMappingList[j].SVMXC__Target_Field_Name__c).getDescribe();
                                    if((f.getType() == schema.Displaytype.Double  || f.getType() == schema.Displaytype.Percent || f.getType() == schema.Displaytype.Currency)&& f.isCreateable())//if Field Type is Double,persent,currency 
                                    {
                                        if(double.valueOf(FieldMappingList[j].SVMXC__Display_Value__c) != null )
                                        {
                                            Sobj.put(FieldMappingList[j].SVMXC__Target_Field_Name__c,(double.valueOf(FieldMappingList[j].SVMXC__Display_Value__c)));
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
                                        system.debug('asdf'+FieldMappingList[j].SVMXC__Display_Value__c);
                                        if(FieldMappingList[j].SVMXC__Display_Value__c.touppercase() == 'TODAY')
                                        {
                                            system.debug('Enterd for Today');
                                            Sobj.put(FieldMappingList[j].SVMXC__Target_Field_Name__c,datetime.newInstance(system.today(), time.newInstance(0, 0, 0, 0)));
                                        }   
                                        else if(FieldMappingList[j].SVMXC__Display_Value__c.touppercase() == 'YESTERDAY')
                                        {
                                            system.debug('Enterd for YESTERDAY');
                                            Sobj.put(FieldMappingList[j].SVMXC__Target_Field_Name__c,datetime.newInstance(system.today()-1, time.newInstance(0, 0, 0, 0)));
                                        }       
                                        else if(FieldMappingList[j].SVMXC__Display_Value__c.touppercase() == 'TOMORROW')
                                        {
                                            system.debug('Enterd for TOMORROW');
                                            Sobj.put(FieldMappingList[j].SVMXC__Target_Field_Name__c,datetime.newInstance(system.today()+1, time.newInstance(0, 0, 0, 0)));
                                        }
                                        else if(FieldMappingList[j].SVMXC__Display_Value__c.touppercase() == 'NOW')
                                        {
                                            system.debug('Enterd for NOW');
                                            Sobj.put(FieldMappingList[j].SVMXC__Target_Field_Name__c,system.now());
                                        }
                                        else
                                        {           
                                            Sobj.put(FieldMappingList[j].SVMXC__Target_Field_Name__c,DateTime.valueof(FieldMappingList[j].SVMXC__Display_Value__c));
                                        }
                                                
                                    }
                                    else if(f.getType() == schema.Displaytype.Date && f.isCreateable())//if field type is Date
                                    {
                                        system.debug('asdf'+FieldMappingList[j].SVMXC__Display_Value__c);
                                        if(FieldMappingList[j].SVMXC__Display_Value__c.touppercase() == 'TODAY')
                                        {
                                            system.debug('Enterd for Today');
                                            Sobj.put(FieldMappingList[j].SVMXC__Target_Field_Name__c,system.today());
                                        }   
                                        else if(FieldMappingList[j].SVMXC__Display_Value__c.touppercase() == 'YESTERDAY')
                                        {
                                            system.debug('Enterd for YESTERDAY');
                                            Sobj.put(FieldMappingList[j].SVMXC__Target_Field_Name__c,system.today() - 1);
                                        }       
                                        else if(FieldMappingList[j].SVMXC__Display_Value__c.touppercase() == 'TOMORROW')
                                        {
                                            system.debug('Enterd for TOMORROW');
                                            Sobj.put(FieldMappingList[j].SVMXC__Target_Field_Name__c,system.today() + 1);
                                        }
                                        else
                                        {           
                                            Sobj.put(FieldMappingList[j].SVMXC__Target_Field_Name__c,Date.valueof(FieldMappingList[j].SVMXC__Display_Value__c));
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
                mapFinalSourceRecIdTargetObj.put(s1,Sobj);
                //SobjectList.add(Sobj);    
            }
        
        }
        system.debug('mapFinalSourceRecIdTargetObj'+mapFinalSourceRecIdTargetObj);
        return mapFinalSourceRecIdTargetObj;
    }
    public List<Sobject> getValueMapping(List<Sobject> SobjList,String SFID,map<String,Schema.SObjectType> Allobj)
    {
        SVMXC__ServiceMax_Processes__c MapHeader = new SVMXC__ServiceMax_Processes__c();
        List<SVMXC__ServiceMax_Config_Data__c> FieldMappingList = new List<SVMXC__ServiceMax_Config_Data__c>();
        MapHeader = [Select SVMXC__Type__c, SVMXC__Target_Record_Type__c, SVMXC__Target_Object_label__c,SVMXC__Target_Object_Name__c, SVMXC__Submodule__c, SVMXC__SubmoduleID__c, SVMXC__Source_Object_Name__c,SVMXC__Settings_Name__c, SVMXC__Setting_Unique_ID__c, SVMXC__SettingID__c, SVMXC__Sequence__c, SVMXC__Select__c,SVMXC__Search_Order__c, SVMXC__Rule_Type__c, SVMXC__Purpose__c, SVMXC__Process__c, SVMXC__ProcessID__c,SVMXC__Parent_Object__c, SVMXC__Parent_Object_Criteria__c, SVMXC__Parent_Error_Msg__c,SVMXC__Parent_Column_Name__c, SVMXC__Page_Layout__c, SVMXC__Node_Source_Object_API__c,SVMXC__Node_Parent_API__c, SVMXC__Node_Parent__c, SVMXC__Name__c, SVMXC__Module__c, SVMXC__ModuleID__c,SVMXC__MapID__c, SVMXC__MTTS_Minutes__c,SVMXC__IsStandard__c, SVMXC__IsStandalone__c, SVMXC__IsPrivate__c, SVMXC__IsDefault__C,SVMXC__Final_Exception_Process__c,SVMXC__End_Date__c, SVMXC__Email_On_Success__c,SVMXC__Email_On_Error__c, SVMXC__Dispatch_Method__c, SVMXC__Description__c,SVMXC__Default_Value__c, SVMXC__Data_Type__c,  SVMXC__Child_Object_Criteria__c,SVMXC__Child_Error_Msg__c,SVMXC__Advance_Expression__c,SVMXC__Active__c, RecordTypeId, OwnerId, Name,LastModifiedDate, LastModifiedById,  IsDeleted, Id, CreatedDate, CreatedById From SVMXC__ServiceMax_Processes__c  where Id =: SFID];system.debug('MapHeader'+MapHeader);   //SDL-SVMX-FLS-NOT-ENFORCED-META-DATA
        if(MapHeader != null && MapHeader.id != null)
            FieldMappingList = [Select SystemModstamp, SVMXC__Display_Value__c, SVMXC__User__c, SVMXC__Target_Field_Name__c, SVMXC__Stock_Status__c, SVMXC__Stock_History_Line_Lookup_Field__c, SVMXC__Stock_History_Header_Lookup_Field__c, SVMXC__Source_Field_Name__c, SVMXC__Setting_Unique_ID__c,  SVMXC__Setting_ID__c, SVMXC__Setting_Configuration_Profile__c, SVMXC__SettingID__c, SVMXC__Sequence__c, SVMXC__Select__c, SVMXC__Search_Object_Field_Type__c, SVMXC__Object_Name__c, SVMXC__FKey_Name_Field__c, SVMXC__RecordType_Name__c, SVMXC__Profile__c, SVMXC__Profile_Name__c, SVMXC__Preference_3__c, SVMXC__Preference_2__c, SVMXC__Operator__c, SVMXC__Operand__c, SVMXC__MapID__c, SVMXC__Lookup_Field_API_Name__c, SVMXC__Location_Type__c, SVMXC__Location_Field_Name__c, SVMXC__Location_Field_From__c, SVMXC__IsDefault__c, SVMXC__Inventory_Process__c, SVMXC__Internal_Value__c, SVMXC__Installation_Key__c, SVMXC__Display_Type__c, SVMXC__Field_Relationship_Name__c, SVMXC__Field_Name__c, SVMXC__Expression_Type__c, SVMXC__Expression_Rule__c, SVMXC__Enter_Date__c, SVMXC__Enable_Task__c, SVMXC__Enable_Calendar__c, SVMXC__Enable_Activity_Tracking_On__c, SVMXC__Display_Map_ID__c, SVMXC__Dispatch_Process__c, SVMXC__Description__c, SVMXC__Configuration_Type__c, SVMXC__Config_Profile_Name__c, SVMXC__Active__c, SVMXC__Action__c, SVMXC__Access_Configuration_Profile__c, RecordTypeId, OwnerId, Name, LastModifiedDate, LastModifiedById,  IsDeleted, Id,CreatedDate, CreatedById From SVMXC__ServiceMax_Config_Data__c  where SVMXC__MapID__c =: MapHeader.id];   //SDL-SVMX-FLS-NOT-ENFORCED-META-DATA
        system.debug('FieldMappingList'+FieldMappingList.size()+FieldMappingList);
        map<String, Schema.SObjectField> mapTargetFieldDesc = new map<String, Schema.SObjectField>();
        if(MapHeader.SVMXC__Target_Object_Name__c != null && Allobj.containskey(MapHeader.SVMXC__Target_Object_Name__c))
        {
            map<String, Schema.SObjectField> FieldMap = new map<String, Schema.SObjectField>();
            FieldMap = Allobj.get(MapHeader.SVMXC__Target_Object_Name__c).getDescribe().fields.getMap();
            if(FieldMap.size() > 0)
            {
                for(String s : FieldMap.keyset())
                {
                    mapTargetFieldDesc.put(FieldMap.get(s).getDescribe().getName(),FieldMap.get(s));
                }
            }
        }
        if(SobjList.size() > 0 && FieldMappingList.size() > 0 && mapTargetFieldDesc.size() > 0)
        {
            List<RecordType> RecordtypeLst = new List<RecordType>();
            if(MapHeader.SVMXC__Target_Object_Name__c != null)
                RecordtypeLst = [Select SystemModstamp, SobjectType, NamespacePrefix, Name, LastModifiedDate, LastModifiedById, IsActive, Id, DeveloperName, Description, CreatedDate, CreatedById, BusinessProcessId From RecordType where SobjectType =: MapHeader.SVMXC__Target_Object_Name__c];   //SDL-SVMX-FLS-NOT-ENFORCED-META-DATA
            for(Integer i=0;i<SobjList.size();i++)
            {
                for(Integer j = 0;j<FieldMappingList.size();j++)
                {
                    system.debug('zzzzzzzz1'+FieldMappingList[j].SVMXC__Target_Field_Name__c);
                    system.debug('zzzzzzzz2'+FieldMappingList[j].SVMXC__Display_Value__c);
                    system.debug('zzzzzzzz3'+FieldMappingList[j].SVMXC__Target_Field_Name__c);
                    system.debug('zzzzzzzz4'+mapTargetFieldDesc.containskey(FieldMappingList[j].SVMXC__Target_Field_Name__c));

                    if(FieldMappingList[j].SVMXC__Target_Field_Name__c != null && FieldMappingList[j].SVMXC__Display_Value__c != null && mapTargetFieldDesc.containskey(FieldMappingList[j].SVMXC__Target_Field_Name__c))
                    {
                        if(FieldMappingList[j].SVMXC__Target_Field_Name__c == 'RecordTypeId')
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
                        else
                        {
                            //Desctibe the field to check differen attributes of fields..
                            Schema.DescribeFieldResult f = mapTargetFieldDesc.get(FieldMappingList[j].SVMXC__Target_Field_Name__c).getDescribe();
                            if((f.getType() == schema.Displaytype.Double  || f.getType() == schema.Displaytype.Percent || f.getType() == schema.Displaytype.Currency)&& f.isCreateable())//if Field Type is Double,persent,currency 
                            {
                                if(double.valueOf(FieldMappingList[j].SVMXC__Display_Value__c) != null )
                                {
                                    SobjList[i].put(FieldMappingList[j].SVMXC__Target_Field_Name__c,(double.valueOf(FieldMappingList[j].SVMXC__Display_Value__c)));
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
                                system.debug('asdf'+FieldMappingList[j].SVMXC__Display_Value__c);
                                if(FieldMappingList[j].SVMXC__Display_Value__c.touppercase() == 'TODAY')
                                {
                                    system.debug('Enterd for Today');
                                    SobjList[i].put(FieldMappingList[j].SVMXC__Target_Field_Name__c,datetime.newInstance(system.today(), time.newInstance(0, 0, 0, 0)));
                                }   
                                else if(FieldMappingList[j].SVMXC__Display_Value__c.touppercase() == 'YESTERDAY')
                                {
                                    system.debug('Enterd for YESTERDAY');
                                    SobjList[i].put(FieldMappingList[j].SVMXC__Target_Field_Name__c,datetime.newInstance(system.today()-1, time.newInstance(0, 0, 0, 0)));
                                }       
                                else if(FieldMappingList[j].SVMXC__Display_Value__c.touppercase() == 'TOMORROW')
                                {
                                    system.debug('Enterd for TOMORROW');
                                    SobjList[i].put(FieldMappingList[j].SVMXC__Target_Field_Name__c,datetime.newInstance(system.today()+1, time.newInstance(0, 0, 0, 0)));
                                }
                                else if(FieldMappingList[j].SVMXC__Display_Value__c.touppercase() == 'NOW')
                                {
                                    system.debug('Enterd for NOW');
                                    SobjList[i].put(FieldMappingList[j].SVMXC__Target_Field_Name__c,system.now());
                                }
                                else
                                {           
                                    SobjList[i].put(FieldMappingList[j].SVMXC__Target_Field_Name__c,DateTime.valueof(FieldMappingList[j].SVMXC__Display_Value__c));
                                }
                                        
                            }
                            else if(f.getType() == schema.Displaytype.Date && f.isCreateable())//if field type is Date
                            {
                                system.debug('asdf'+FieldMappingList[j].SVMXC__Display_Value__c);
                                if(FieldMappingList[j].SVMXC__Display_Value__c.touppercase() == 'TODAY')
                                {
                                    system.debug('Enterd for Today');
                                    SobjList[i].put(FieldMappingList[j].SVMXC__Target_Field_Name__c,system.today());
                                }   
                                else if(FieldMappingList[j].SVMXC__Display_Value__c.touppercase() == 'YESTERDAY')
                                {
                                    system.debug('Enterd for YESTERDAY');
                                    SobjList[i].put(FieldMappingList[j].SVMXC__Target_Field_Name__c,system.today() - 1);
                                }       
                                else if(FieldMappingList[j].SVMXC__Display_Value__c.touppercase() == 'TOMORROW')
                                {
                                    system.debug('Enterd for TOMORROW');
                                    SobjList[i].put(FieldMappingList[j].SVMXC__Target_Field_Name__c,system.today() + 1);
                                }
                                else
                                {           
                                    SobjList[i].put(FieldMappingList[j].SVMXC__Target_Field_Name__c,Date.valueOf(FieldMappingList[j].SVMXC__Display_Value__c));
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
        return SobjList;
    }
    
    public List<List<INTF_WebServicesDef.INTF_StringMap>> getValueMappingAsKeyValue(List<Sobject> SobjList,String SFID,map<String,Schema.SObjectType> Allobj)
    {
        List<List<INTF_WebServicesDef.INTF_StringMap>> response = new List<List<INTF_WebServicesDef.INTF_StringMap>>();
        SVMXC__ServiceMax_Processes__c MapHeader = new SVMXC__ServiceMax_Processes__c();
        List<SVMXC__ServiceMax_Config_Data__c> FieldMappingList = new List<SVMXC__ServiceMax_Config_Data__c>();
        MapHeader = [Select SVMXC__Type__c, SVMXC__Target_Record_Type__c, SVMXC__Target_Object_label__c,SVMXC__Target_Object_Name__c, SVMXC__Submodule__c, SVMXC__SubmoduleID__c, SVMXC__Source_Object_Name__c,SVMXC__Settings_Name__c, SVMXC__Setting_Unique_ID__c, SVMXC__SettingID__c, SVMXC__Sequence__c, SVMXC__Select__c,SVMXC__Search_Order__c, SVMXC__Rule_Type__c, SVMXC__Purpose__c, SVMXC__Process__c, SVMXC__ProcessID__c,SVMXC__Parent_Object__c, SVMXC__Parent_Object_Criteria__c, SVMXC__Parent_Error_Msg__c,SVMXC__Parent_Column_Name__c, SVMXC__Page_Layout__c, SVMXC__Node_Source_Object_API__c,SVMXC__Node_Parent_API__c, SVMXC__Node_Parent__c, SVMXC__Name__c, SVMXC__Module__c, SVMXC__ModuleID__c,SVMXC__MapID__c, SVMXC__MTTS_Minutes__c,SVMXC__IsStandard__c, SVMXC__IsStandalone__c, SVMXC__IsPrivate__c, SVMXC__IsDefault__C,SVMXC__Final_Exception_Process__c,SVMXC__End_Date__c, SVMXC__Email_On_Success__c,SVMXC__Email_On_Error__c, SVMXC__Dispatch_Method__c, SVMXC__Description__c,SVMXC__Default_Value__c, SVMXC__Data_Type__c,  SVMXC__Child_Object_Criteria__c,SVMXC__Child_Error_Msg__c,SVMXC__Advance_Expression__c,SVMXC__Active__c, RecordTypeId, OwnerId, Name,LastModifiedDate, LastModifiedById,  IsDeleted, Id, CreatedDate, CreatedById From SVMXC__ServiceMax_Processes__c  where Id =: SFID];system.debug('MapHeader'+MapHeader);   //SDL-SVMX-FLS-NOT-ENFORCED-META-DATA
        if(MapHeader != null && MapHeader.id != null)
            FieldMappingList = [Select SystemModstamp, SVMXC__Display_Value__c, SVMXC__User__c, SVMXC__Target_Field_Name__c, SVMXC__Stock_Status__c, SVMXC__Stock_History_Line_Lookup_Field__c, SVMXC__Stock_History_Header_Lookup_Field__c, SVMXC__Source_Field_Name__c, SVMXC__Setting_Unique_ID__c,  SVMXC__Setting_ID__c, SVMXC__Setting_Configuration_Profile__c, SVMXC__SettingID__c, SVMXC__Sequence__c, SVMXC__Select__c, SVMXC__Search_Object_Field_Type__c, SVMXC__Object_Name__c, SVMXC__FKey_Name_Field__c, SVMXC__RecordType_Name__c, SVMXC__Profile__c, SVMXC__Profile_Name__c, SVMXC__Preference_3__c, SVMXC__Preference_2__c, SVMXC__Operator__c, SVMXC__Operand__c, SVMXC__MapID__c, SVMXC__Lookup_Field_API_Name__c, SVMXC__Location_Type__c, SVMXC__Location_Field_Name__c, SVMXC__Location_Field_From__c, SVMXC__IsDefault__c, SVMXC__Inventory_Process__c, SVMXC__Internal_Value__c, SVMXC__Installation_Key__c, SVMXC__Display_Type__c, SVMXC__Field_Relationship_Name__c, SVMXC__Field_Name__c, SVMXC__Expression_Type__c, SVMXC__Expression_Rule__c, SVMXC__Enter_Date__c, SVMXC__Enable_Task__c, SVMXC__Enable_Calendar__c, SVMXC__Enable_Activity_Tracking_On__c, SVMXC__Display_Map_ID__c, SVMXC__Dispatch_Process__c, SVMXC__Description__c, SVMXC__Configuration_Type__c, SVMXC__Config_Profile_Name__c, SVMXC__Active__c, SVMXC__Action__c, SVMXC__Access_Configuration_Profile__c, RecordTypeId, OwnerId, Name, LastModifiedDate, LastModifiedById,  IsDeleted, Id,CreatedDate, CreatedById From SVMXC__ServiceMax_Config_Data__c  where SVMXC__MapID__c =: MapHeader.id];  //SDL-SVMX-FLS-NOT-ENFORCED-META-DATA
        system.debug('FieldMappingList'+FieldMappingList.size()+FieldMappingList);
        map<String, Schema.SObjectField> mapTargetFieldDesc = new map<String, Schema.SObjectField>();
        if(MapHeader.SVMXC__Target_Object_Name__c != null && Allobj.containskey(MapHeader.SVMXC__Target_Object_Name__c))
        {
            map<String, Schema.SObjectField> FieldMap = new map<String, Schema.SObjectField>();
            FieldMap = Allobj.get(MapHeader.SVMXC__Target_Object_Name__c).getDescribe().fields.getMap();
            if(FieldMap.size() > 0)
            {
                for(String s : FieldMap.keyset())
                {
                    mapTargetFieldDesc.put(FieldMap.get(s).getDescribe().getName(),FieldMap.get(s));
                }
            }
        }
        if(SobjList.size() > 0 && FieldMappingList.size() > 0 && mapTargetFieldDesc.size() > 0)
        {
            List<RecordType> RecordtypeLst = new List<RecordType>();
            if(MapHeader.SVMXC__Target_Object_Name__c != null)
                RecordtypeLst = [Select SystemModstamp, SobjectType, NamespacePrefix, Name, LastModifiedDate, LastModifiedById, IsActive, Id, DeveloperName, Description, CreatedDate, CreatedById, BusinessProcessId From RecordType where SobjectType =: MapHeader.SVMXC__Target_Object_Name__c];   //SDL-SVMX-FLS-NOT-ENFORCED-META-DATA
            for(Integer i=0;i<SobjList.size();i++)
            {
                List<INTF_WebServicesDef.INTF_StringMap> response_WP = new List<INTF_WebServicesDef.INTF_StringMap>();
                for(Integer j = 0;j<FieldMappingList.size();j++)
                {
                    system.debug('zzzzzzzz1'+FieldMappingList[j].SVMXC__Target_Field_Name__c);
                    system.debug('zzzzzzzz2'+FieldMappingList[j].SVMXC__Display_Value__c);
                    system.debug('zzzzzzzz3'+FieldMappingList[j].SVMXC__Target_Field_Name__c);
                    system.debug('zzzzzzzz4'+mapTargetFieldDesc.containskey(FieldMappingList[j].SVMXC__Target_Field_Name__c));

                    if(FieldMappingList[j].SVMXC__Target_Field_Name__c != null && FieldMappingList[j].SVMXC__Display_Value__c != null && mapTargetFieldDesc.containskey(FieldMappingList[j].SVMXC__Target_Field_Name__c))
                    {
                        if(FieldMappingList[j].SVMXC__Target_Field_Name__c == 'RecordTypeId')
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
                                response_WP.add(new INTF_WebServicesDef.INTF_StringMap(FieldMappingList[j].SVMXC__Target_Field_Name__c, RecordTypeId));
                                //SobjList[i].put(FieldMappingList[j].SVMXC__Target_Field_Name__c,RecordTypeId);
                        }
                        else
                        {
                            //Desctibe the field to check differen attributes of fields..
                            Schema.DescribeFieldResult f = mapTargetFieldDesc.get(FieldMappingList[j].SVMXC__Target_Field_Name__c).getDescribe();
                            if((f.getType() == schema.Displaytype.Double  || f.getType() == schema.Displaytype.Percent || f.getType() == schema.Displaytype.Currency)&& f.isCreateable())//if Field Type is Double,persent,currency 
                            {
                                if(double.valueOf(FieldMappingList[j].SVMXC__Display_Value__c) != null )
                                {
                                    response_WP.add(new INTF_WebServicesDef.INTF_StringMap(FieldMappingList[j].SVMXC__Target_Field_Name__c, FieldMappingList[j].SVMXC__Display_Value__c));
                                    //SobjList[i].put(FieldMappingList[j].SVMXC__Target_Field_Name__c,(double.valueOf(FieldMappingList[j].SVMXC__Display_Value__c)));
                                }   
                            }
                            else if(f.getType() == schema.Displaytype.Integer && f.isCreateable())//if field type is Integer
                            {
                                if(Integer.valueof(FieldMappingList[j].SVMXC__Display_Value__c)!= null)
                                {
                                    response_WP.add(new INTF_WebServicesDef.INTF_StringMap(FieldMappingList[j].SVMXC__Target_Field_Name__c, FieldMappingList[j].SVMXC__Display_Value__c));
                                    //SobjList[i].put(FieldMappingList[j].SVMXC__Target_Field_Name__c,Integer.valueof(FieldMappingList[j].SVMXC__Display_Value__c));
                                }   
                            }
                            else if(f.getType() == schema.Displaytype.Boolean && f.isCreateable())//if field type is Boolean
                            {
                                if(Boolean.valueof(FieldMappingList[j].SVMXC__Display_Value__c)!= null)
                                {
                                    response_WP.add(new INTF_WebServicesDef.INTF_StringMap(FieldMappingList[j].SVMXC__Target_Field_Name__c, FieldMappingList[j].SVMXC__Display_Value__c));
                                    //SobjList[i].put(FieldMappingList[j].SVMXC__Target_Field_Name__c,Boolean.valueof(FieldMappingList[j].SVMXC__Display_Value__c));
                                }   
                            }
                            else if(f.getType() == schema.Displaytype.DateTime && f.isCreateable())//if field type is DateTime
                            {
                                system.debug('asdf'+FieldMappingList[j].SVMXC__Display_Value__c);
                                if(FieldMappingList[j].SVMXC__Display_Value__c.touppercase() == 'TODAY')
                                {
                                    response_WP.add(new INTF_WebServicesDef.INTF_StringMap(FieldMappingList[j].SVMXC__Target_Field_Name__c, string.valueOfgmt(datetime.newInstance(system.today(), time.newInstance(0, 0, 0, 0)))));
                                    //SobjList[i].put(FieldMappingList[j].SVMXC__Target_Field_Name__c,system.today());
                                }   
                                else if(FieldMappingList[j].SVMXC__Display_Value__c.touppercase() == 'YESTERDAY')
                                {
                                    response_WP.add(new INTF_WebServicesDef.INTF_StringMap(FieldMappingList[j].SVMXC__Target_Field_Name__c, string.valueOfgmt(datetime.newInstance(system.today()-1, time.newInstance(0, 0, 0, 0)))));
                                    //SobjList[i].put(FieldMappingList[j].SVMXC__Target_Field_Name__c,system.today() - 1);
                                }       
                                else if(FieldMappingList[j].SVMXC__Display_Value__c.touppercase() == 'TOMORROW')
                                {
                                    response_WP.add(new INTF_WebServicesDef.INTF_StringMap(FieldMappingList[j].SVMXC__Target_Field_Name__c, string.valueOfgmt(datetime.newInstance(system.today()+1, time.newInstance(0, 0, 0, 0)))));
                                    //SobjList[i].put(FieldMappingList[j].SVMXC__Target_Field_Name__c,system.today() + 1);
                                }
                                else if(FieldMappingList[j].SVMXC__Display_Value__c.touppercase() == 'NOW')
                                {
                                    response_WP.add(new INTF_WebServicesDef.INTF_StringMap(FieldMappingList[j].SVMXC__Target_Field_Name__c, String.valueofgmt(system.now())));
                                    //SobjList[i].put(FieldMappingList[j].SVMXC__Target_Field_Name__c,system.today() + 1);
                                }
                                else
                                {
                                    response_WP.add(new INTF_WebServicesDef.INTF_StringMap(FieldMappingList[j].SVMXC__Target_Field_Name__c, FieldMappingList[j].SVMXC__Display_Value__c));
                                    //SobjList[i].put(FieldMappingList[j].SVMXC__Target_Field_Name__c,FieldMappingList[j].SVMXC__Display_Value__c);
                                }
                                        
                            }
                            else if(f.getType() == schema.Displaytype.Date && f.isCreateable())//if field type is Date
                            {
                                system.debug('asdf'+FieldMappingList[j].SVMXC__Display_Value__c);
                                if(FieldMappingList[j].SVMXC__Display_Value__c.touppercase() == 'TODAY')
                                {
                                    response_WP.add(new INTF_WebServicesDef.INTF_StringMap(FieldMappingList[j].SVMXC__Target_Field_Name__c, String.valueof(system.today())));
                                    //SobjList[i].put(FieldMappingList[j].SVMXC__Target_Field_Name__c,system.today());
                                }   
                                else if(FieldMappingList[j].SVMXC__Display_Value__c.touppercase() == 'YESTERDAY')
                                {
                                    response_WP.add(new INTF_WebServicesDef.INTF_StringMap(FieldMappingList[j].SVMXC__Target_Field_Name__c, String.valueof(system.today() - 1)));
                                    //SobjList[i].put(FieldMappingList[j].SVMXC__Target_Field_Name__c,system.today() - 1);
                                }       
                                else if(FieldMappingList[j].SVMXC__Display_Value__c.touppercase() == 'TOMORROW')
                                {
                                    response_WP.add(new INTF_WebServicesDef.INTF_StringMap(FieldMappingList[j].SVMXC__Target_Field_Name__c, String.valueof(system.today() + 1)));
                                    //SobjList[i].put(FieldMappingList[j].SVMXC__Target_Field_Name__c,system.today() + 1);
                                }
                                else
                                {
                                    response_WP.add(new INTF_WebServicesDef.INTF_StringMap(FieldMappingList[j].SVMXC__Target_Field_Name__c, FieldMappingList[j].SVMXC__Display_Value__c));        
                                    //SobjList[i].put(FieldMappingList[j].SVMXC__Target_Field_Name__c,FieldMappingList[j].SVMXC__Display_Value__c);
                                }
                            }
                            else if(f.getType() == schema.Displaytype.MultiPicklist && f.isCreateable())//if field type is MultiPicklist
                            {
                                if(String.valueof(FieldMappingList[j].SVMXC__Display_Value__c) != null)
                                {
                                    response_WP.add(new INTF_WebServicesDef.INTF_StringMap(FieldMappingList[j].SVMXC__Target_Field_Name__c, String.valueof(FieldMappingList[j].SVMXC__Display_Value__c)));
                                    //SobjList[i].put(FieldMappingList[j].SVMXC__Target_Field_Name__c,String.valueof(FieldMappingList[j].SVMXC__Display_Value__c));
                                }
                            }
                            else //else field type is REFERENCE,String 
                            {
                                if((String)FieldMappingList[j].SVMXC__Display_Value__c != null && f.isCreateable())
                                {
                                    response_WP.add(new INTF_WebServicesDef.INTF_StringMap(FieldMappingList[j].SVMXC__Target_Field_Name__c, (String)FieldMappingList[j].SVMXC__Display_Value__c));
                                    //SobjList[i].put(FieldMappingList[j].SVMXC__Target_Field_Name__c,(String)FieldMappingList[j].SVMXC__Display_Value__c);
                                }
                            }
                        }    
                    }   
                }
                response.add(response_WP);
            }
        }
        system.debug('response::'+response);
        return response;
    }
}