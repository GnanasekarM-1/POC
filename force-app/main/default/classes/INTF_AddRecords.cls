public with sharing class INTF_AddRecords 
{
    public map<String, Schema.SObjectType> gd = new map<String, Schema.SObjectType>();
    public map<String, Schema.SObjectType> allobjmap  = new map<String, Schema.SObjectType>();
    SVMXC.COMM_Utils commutils = new SVMXC.COMM_Utils(); 
    SVMXC.SFM_Utils SFMUtils = new SVMXC.SFM_Utils(); 
    public INTF_addRecords()
    {
        gd = Schema.getGlobalDescribe();
        for(Schema.SObjectType s : gd.values())
        {
            allobjmap.put(s.getDescribe().getName(),s);
        }
        system.debug('allobjmap'+allobjmap);
    }
    public list<SVMXC.INTF_WebServicesDef.INTF_PageDataSet> getINTF_AddRecords(SVMXC.INTF_WebServicesDef.INTF_Request request)
    {
        String ProcessId = '';
        String Alias = '';
        String FieldAPIName = '';
        list<Sobject> Sobjlsit = new list<Sobject>();
        List<List<INTF_WebServicesDef.INTF_StringMap>> keyValueObject = new List<List<INTF_WebServicesDef.INTF_StringMap>>();
        SVMXC.INTF_ApplyMapping Mapping = new SVMXC.INTF_ApplyMapping();
        SVMXC.INTF_WebServicesDef.INTF_Request SFMRequest = new SVMXC.INTF_WebServicesDef.INTF_Request();
        list<SVMXC.INTF_WebServicesDef.INTF_PageDataSet> PageDataSetList = new list<SVMXC.INTF_WebServicesDef.INTF_PageDataSet>(); 
        list<SVMXC.INTF_WebServicesDef.INTF_Record> SFMRecordList = new list<SVMXC.INTF_WebServicesDef.INTF_Record>();
        list<SVMXC.INTF_WebServicesDef.INTF_StringMap> StringMapList = new list<SVMXC.INTF_WebServicesDef.INTF_StringMap>(); 
        list<SVMXC.INTF_WebServicesDef.INTF_StringListMap> StringListMap = new list<SVMXC.INTF_WebServicesDef.INTF_StringListMap>();
        list<String> MultiAddRecList = new list<String>(); 
        SVMXC__ServiceMax_Processes__c SFMProcess = new SVMXC__ServiceMax_Processes__c();
        SVMXC__ServiceMax_Processes__c processNodeObject = new SVMXC__ServiceMax_Processes__c();
        SVMXC__Page_Layout__c PageLayout = new SVMXC__Page_Layout__c();
        list<SVMXC__Page_Layout_Detail__c> PageLayoutDetailList = new list<SVMXC__Page_Layout_Detail__c>();
        if(request != null)
          SFMRequest = request;
        if(SFMRequest.stringMap != null && SFMRequest.stringMap.size() > 0)
          StringMapList = SFMRequest.stringMap;
        if(SFMRequest.stringListMap != null && SFMRequest.stringListMap.size() > 0)  
          StringListMap = SFMRequest.stringListMap;
        system.debug('StringMapList'+StringMapList);
        system.debug('StringListMap'+StringListMap);
        Boolean isiPad = false;
        if(StringMapList.size() > 0)
        {
            for(Integer i = 0;i<StringMapList.size();i++)
            {
                if(StringMapList[i].key.touppercase() == 'IPAD')
                {
                    isiPad = true;
                }
                if(StringMapList[i].key.touppercase() == 'PROCESSID')
                {
                    ProcessId = StringMapList[i].value;
                }
                if(StringMapList[i].key.touppercase() == 'ALIAS')
                {
                    Alias = StringMapList[i].value;
                }
                if(StringMapList[i].key.touppercase() == 'FIELDAPINAME')
                {
                    FieldAPIName = StringMapList[i].value;
                }
            }
        }
        if(StringListMap.size()  >  0 )
        {
            for(Integer i = 0;i<StringListMap.size();i++)
            {
                if(StringListMap[i].key.touppercase() == 'RECORDID')
                {
                    MultiAddRecList = StringListMap[i].valueList;
                }
            }
        }
        system.debug('MultiAddRecList'+MultiAddRecList);
        if(ProcessId != null && ProcessId.length() > 0)
          SFMProcess = [Select Name,SVMXC__ProcessID__c,SVMXC__Type__c,SVMXC__Node_Parent__c,SVMXC__Source_Object_Name__c,SVMXC__Target_Object_Name__c,SVMXC__Submodule__c,SVMXC__Module__c,SVMXC__Sequence__c,SVMXC__Process__c,SVMXC__Node_Source_Object_API__c,SVMXC__Page_Layout__c,SVMXC__Target_Object_label__c,SVMXC__IsStandard__c,SVMXC__IsStandalone__c  From SVMXC__ServiceMax_Processes__c where (id = :ProcessId OR SVMXC__ProcessID__c =: ProcessId OR SVMXC__Name__c =: ProcessId) AND RecordType.Name = 'Target Manager'];   //SDL-SVMX-FLS-NOT-ENFORCED-META-DATA
        if(SFMProcess != null && SFMProcess.id != null && Alias != null && Alias.length() > 0)
        {
            system.debug('Enterd');
            processNodeObject = [Select Name,SVMXC__ProcessID__c,SVMXC__Type__c,SVMXC__Final_Exception_Process__c,SVMXC__Node_Parent__c,SVMXC__Source_Object_Name__c,SVMXC__Target_Object_Name__c,SVMXC__Submodule__c,SVMXC__Module__c,SVMXC__Sequence__c,SVMXC__Process__c,SVMXC__Page_Layout__c,SVMXC__Node_Source_Object_API__c,SVMXC__Target_Object_label__c,SVMXC__IsStandard__c,SVMXC__IsStandalone__c  From SVMXC__ServiceMax_Processes__c where  SVMXC__Process__c =: SFMProcess.id and  SVMXC__Page_Layout__c =: Alias AND RecordType.Name = 'Process Node Objects']; //SDL-SVMX-FLS-NOT-ENFORCED-META-DATA
            system.debug('processNodeObject'+processNodeObject);
            if(SFMProcess.SVMXC__Page_Layout__c != null)
                PageLayout = [Select SVMXC__Type__c, SVMXC__Sequence__c, SVMXC__Page_Layout_ID__c, SVMXC__Page_Help__c, SVMXC__Object_Name__c, SVMXC__Multi_Add_Search_Object__c, SVMXC__Multi_Add_Search_Field__c, SVMXC__Multi_Add_Configuration__c, SVMXC__IsStandard__c, SVMXC__Help_URL__c, SVMXC__Header_Reference_Field__c, SVMXC__Header_Page_Layout__c,SVMXC__Name__c, SVMXC__Action_On_Zero_Lines__c,SVMXC__Allow_New_Lines__c, SVMXC__Allow_Delete_Lines__c,  OwnerId, Name, LastModifiedDate, LastModifiedById,  IsDeleted, Id, CreatedDate, CreatedById From SVMXC__Page_Layout__c where SVMXC__Header_Page_Layout__c =: SFMProcess.SVMXC__Page_Layout__c and id =: Alias]; //SDL-SVMX-FLS-NOT-ENFORCED-META-DATA
            if(PageLayout != null && PageLayout.id != null)
                PageLayoutDetailList = [Select SVMXC__Title__c, SVMXC__Sequence__c, SVMXC__Section__c, SVMXC__Required__c, SVMXC__Related_Object_Name__c, SVMXC__Related_Object_Name_Field__c, SVMXC__Readonly__c, SVMXC__Page_Layout__c, SVMXC__Override_Related_Lookup__c, SVMXC__Named_Search__c, SVMXC__Named_Search__r.SVMXC__Default_Lookup_Column__c,  SVMXC__Lookup_Query_Field__c, SVMXC__Lookup_Context__c,  SVMXC__IsStandard__c, SVMXC__Field_API_Name__c, SVMXC__Display_Row__c, SVMXC__Display_Column__c, SVMXC__Detail_Type__c, SVMXC__DataType__c, Name, Id From SVMXC__Page_Layout_Detail__c where SVMXC__Page_Layout__c =: PageLayout.id and SVMXC__Detail_Type__c = 'Field'];  //SDL-SVMX-FLS-NOT-ENFORCED-META-DATA
            if(processNodeObject != null && processNodeObject.SVMXC__Source_Object_Name__c != null)
            {
                system.debug('Enterd11');
                //It's not multiAdd
                if(MultiAddRecList.size() == 0 && allobjmap.containskey(processNodeObject.SVMXC__Source_Object_Name__c))
                {
                    Sobject Sobj = allobjmap.get(processNodeObject.SVMXC__Source_Object_Name__c).newSObject();
                    Sobjlsit.add(Sobj);
                }
                //It's a multiAdd..
                if(MultiAddRecList.size() > 0 && allobjmap.containskey(processNodeObject.SVMXC__Source_Object_Name__c))
                {
                    for(Integer i = 0;i<MultiAddRecList.size();i++)
                    {
                        Sobject Sobj = allobjmap.get(processNodeObject.SVMXC__Source_Object_Name__c).newSObject();
                        Sobjlsit.add(Sobj);
                    }
                }   
                system.debug('Sobjlsit'+Sobjlsit);
                if(processNodeObject.SVMXC__Final_Exception_Process__c != null)
                {
                    Sobjlsit = Mapping.getValueMapping(Sobjlsit,processNodeObject.SVMXC__Final_Exception_Process__c,allobjmap);
                    if(isiPad)
                    {
                        keyValueObject = Mapping.getValueMappingAsKeyValue(Sobjlsit,processNodeObject.SVMXC__Final_Exception_Process__c,allobjmap);
                        SVMXC.INTF_WebServicesDef.INTF_PageDataSet PageDataSet = new SVMXC.INTF_WebServicesDef.INTF_PageDataSet();
                        if(keyValueObject != NULL && keyValueObject.size() > 0)
                        {
                            PageDataSet.defaultObjectValue = keyValueObject[0];
                            PageDataSetList.add(PageDataSet);
                        }
                        system.debug('PageDataSetList'+PageDataSetList);
                        return PageDataSetList;
                    }
                }
                //if its multiadd then put the Ids  from multiadd list..
                if(Sobjlsit.size() > 0 && MultiAddRecList.size() > 0 && FieldAPIName != null && FieldAPIName.length() > 0)
                {
                    for(Integer i = 0;i<Sobjlsit.size();i++)
                    {
                        Sobjlsit[i].put(FieldAPIName,MultiAddRecList[i]);
                    }
                }
                system.debug('Sobjlsit'+Sobjlsit);
                if(Sobjlsit.size() > 0 && PageLayoutDetailList.size() > 0)
                {
                    for(Integer i = 0;i<Sobjlsit.size();i++)
                    {
                        SVMXC.INTF_WebServicesDef.INTF_PageDataSet PageDataSet = new SVMXC.INTF_WebServicesDef.INTF_PageDataSet();
                        PageDataSet.sobjectinfo = Sobjlsit[i];
                        list<SVMXC.INTF_WebServicesDef.INTF_BubbleWrapper> BubbleWrapperList = new list<SVMXC.INTF_WebServicesDef.INTF_BubbleWrapper>();
                        for(Integer j = 0;j<PageLayoutDetailList.size();j++)
                        {
                            if(PageLayoutDetailList[j].SVMXC__Field_API_Name__c != null)
                            {
                                SVMXC.INTF_WebServicesDef.INTF_BubbleWrapper BubbleWrapper = new SVMXC.INTF_WebServicesDef.INTF_BubbleWrapper();
                                String FieldName = PageLayoutDetailList[j].SVMXC__Field_API_Name__c;
                                BubbleWrapper.fieldapiname = FieldName;
                                String DefaultValue = '';
                                if(Sobjlsit[i].get(FieldName) != null)
                                    DefaultValue = String.valueof(Sobjlsit[i].get(FieldName));
                                system.debug('FieldName'+FieldName);
                                if(PageLayoutDetailList[j].SVMXC__DataType__c.touppercase() != 'REFERENCE' && DefaultValue != null && DefaultValue.length() > 0)
                                {
                                    system.debug('Called Not REFERENCE');
                                    BubbleWrapper.fieldvalue.key = DefaultValue; 
                                    BubbleWrapper.fieldvalue.value = DefaultValue;
                                }
                                if(PageLayoutDetailList[j].SVMXC__DataType__c.touppercase() == 'REFERENCE' && DefaultValue != null && DefaultValue.length() > 0)
                                {
                                    system.debug('Called REFERENCE'+DefaultValue);
                                    String key = DefaultValue;
                                    map<String,String> valuemap = new map<String,String>(); 
                                    if(PageLayoutDetailList[j].SVMXC__Named_Search__c != null && PageLayoutDetailList[j].SVMXC__Named_Search__r.SVMXC__Default_Lookup_Column__c != null && PageLayoutDetailList[j].SVMXC__Named_Search__r.SVMXC__Default_Lookup_Column__c != PageLayoutDetailList[j].SVMXC__Related_Object_Name_Field__c)
                                    {
                                        String FldName = PageLayoutDetailList[j].SVMXC__Related_Object_Name_Field__c + ','+ PageLayoutDetailList[j].SVMXC__Named_Search__r.SVMXC__Default_Lookup_Column__c;
                                        valuemap = SFMUtils.GetRelationshipData(new set<String>{DefaultValue},PageLayoutDetailList[j].SVMXC__Related_Object_Name__c,FldName);
                                    }
                                    else
                                    {
                                        valuemap = SFMUtils.GetRelationshipData(new set<String>{DefaultValue},PageLayoutDetailList[j].SVMXC__Related_Object_Name__c,PageLayoutDetailList[j].SVMXC__Related_Object_Name_Field__c);
                                    }   
                                    
                                    SVMXC.INTF_WebServicesDef.INTF_StringMap strmap = new SVMXC.INTF_WebServicesDef.INTF_StringMap();
                                    strmap.key = key;
                                    system.debug('valuemap'+valuemap);
                                    if(valuemap != null && valuemap.containskey(DefaultValue))
                                        strmap.value = valuemap.get(DefaultValue);   
                                    BubbleWrapper.fieldvalue = strmap;
                                    //Now start making the bubbleinfo for the Reference fields...
                                    //if(PageLayoutDetailList[j].SVMXC__Named_Search__c != null &&  PageLayoutDetailList[j].SVMXC__Related_Object_Name__c != null)
                                      //  BubbleWrapper.bubbleinfo = SFMUtils.getBubbleinfo(DefaultValue,PageLayoutDetailList[j].SVMXC__Named_Search__c,PageLayoutDetailList[j].SVMXC__Related_Object_Name__c);
                                }
                                BubbleWrapperList.add(BubbleWrapper);
                            }   
                        }
                        PageDataSet.bubbleInfo = BubbleWrapperList;
                        PageDataSetList.add(PageDataSet);
                    }
                }   
            }  
        }
        system.debug('PageDataSetList'+PageDataSetList.size()+PageDataSetList);
        return PageDataSetList;
    }
    
}