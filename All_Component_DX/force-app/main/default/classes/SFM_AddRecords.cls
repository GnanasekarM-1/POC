public with sharing class SFM_AddRecords 
{
    public map<String, Schema.SObjectType> gd = new map<String, Schema.SObjectType>();
    public map<String, Schema.SObjectType> allobjmap  = new map<String, Schema.SObjectType>();
    SVMXC.COMM_Utils commutils = new SVMXC.COMM_Utils(); 
    SVMXC.SFM_Utils SFMUtils = new SVMXC.SFM_Utils();
    public SFM_addRecords()
    {
        gd = Schema.getGlobalDescribe();
        for(Schema.SObjectType s : gd.values())
        {
            allobjmap.put(s.getDescribe().getName(),s);
        }
        system.debug('allobjmap'+allobjmap);
    }
    public list<SVMXC.SFM_WrapperDef.SFM_PageDataSet> getSFM_AddRecords(SVMXC.SFM_WrapperDef.SFM_Request request)
    {
        String ProcessId = '';
        String Alias = '';
        String FieldAPIName = '';
        list<Sobject> Sobjlsit = new list<Sobject>();
        SVMXC.SFM_ApplyMapping Mapping = new SVMXC.SFM_ApplyMapping();
        SVMXC.SFM_WrapperDef.SFM_Request SFMRequest = new SVMXC.SFM_WrapperDef.SFM_Request();
        list<SVMXC.SFM_WrapperDef.SFM_PageDataSet> PageDataSetList = new list<SVMXC.SFM_WrapperDef.SFM_PageDataSet>(); 
        list<SVMXC.SFM_WrapperDef.SFM_Record> SFMRecordList = new list<SVMXC.SFM_WrapperDef.SFM_Record>();
        list<SVMXC.SFM_WrapperDef.SFM_StringMap> StringMapList = new list<SVMXC.SFM_WrapperDef.SFM_StringMap>(); 
        list<SVMXC.SFM_WrapperDef.SFM_StringListMap> StringListMap = new list<SVMXC.SFM_WrapperDef.SFM_StringListMap>();
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
        if(StringMapList.size() > 0)
        {
            for(Integer i = 0;i<StringMapList.size();i++)
            {
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
        {
            try
            {
                //SDL-SVMX-FLS-NOT-ENFORCED-META-DATA
                SFMProcess = [Select Name,SVMXC__Purpose__c, SVMXC__ProcessID__c,SVMXC__Type__c,SVMXC__Node_Parent__c,SVMXC__Source_Object_Name__c,SVMXC__Target_Object_Name__c,SVMXC__Submodule__c,SVMXC__Module__c,SVMXC__Sequence__c,SVMXC__Process__c,SVMXC__Node_Source_Object_API__c,SVMXC__Page_Layout__c,SVMXC__Target_Object_label__c,SVMXC__IsStandard__c,SVMXC__IsStandalone__c  From SVMXC__ServiceMax_Processes__c where RecordType.Name = 'Target Manager' and (id = :ProcessId OR SVMXC__ProcessID__c =: ProcessId OR SVMXC__Name__c =: ProcessId)];
            }
            catch(Exception ex)
            {
                SVMXC.SFM_WrapperDef.SFM_PageDataSet pagedataset = new SVMXC.SFM_WrapperDef.SFM_PageDataSet();
                pagedataset.response.message = system.label.SFM002_TAG057;
                pagedataset.response.success = false;
                PageDataSetList.add(pagedataset);
                return PageDataSetList; 
            }   
        }     
        if(SFMProcess != null && SFMProcess.id != null && Alias != null && Alias.length() > 0)
        {
            system.debug('SFMProcess'+SFMProcess.id);
            system.debug('Alias'+Alias);
            list<SVMXC__Page_Layout__c> page = new list<SVMXC__Page_Layout__c>();
            //SDL-SVMX-FLS-NOT-ENFORCED-META-DATA
            page = [select id from SVMXC__Page_Layout__c where id =: Alias];
            if(page.size() == 0)
            {
                SVMXC.SFM_WrapperDef.SFM_PageDataSet pagedataset = new SVMXC.SFM_WrapperDef.SFM_PageDataSet();
                pagedataset.response.message = system.label.SFM002_TAG057;
                pagedataset.response.success = false;
                PageDataSetList.add(pagedataset);
                return PageDataSetList;
            }    
            //SDL-SVMX-FLS-NOT-ENFORCED-META-DATA
            processNodeObject = [Select Name,SVMXC__ProcessID__c,SVMXC__Type__c,SVMXC__Final_Exception_Process__c,SVMXC__Node_Parent__c,SVMXC__Source_Object_Name__c,SVMXC__Target_Object_Name__c,SVMXC__Submodule__c,SVMXC__Module__c,SVMXC__Sequence__c,SVMXC__Process__c,SVMXC__Page_Layout__c,SVMXC__Node_Source_Object_API__c,SVMXC__Target_Object_label__c,SVMXC__IsStandard__c,SVMXC__IsStandalone__c  From SVMXC__ServiceMax_Processes__c where  SVMXC__Process__c =: SFMProcess.id and  SVMXC__Page_Layout__c =: Alias];
            system.debug('processNodeObject'+processNodeObject);
            if(SFMProcess.SVMXC__Page_Layout__c != null)
                //SDL-SVMX-FLS-NOT-ENFORCED-META-DATA
                PageLayout = [Select SVMXC__Type__c, SVMXC__Sequence__c, SVMXC__Page_Layout_ID__c, SVMXC__Page_Help__c, SVMXC__Object_Name__c, SVMXC__Multi_Add_Search_Object__c, SVMXC__Multi_Add_Search_Field__c, SVMXC__Multi_Add_Configuration__c, SVMXC__IsStandard__c, SVMXC__Help_URL__c, SVMXC__Header_Reference_Field__c, SVMXC__Header_Page_Layout__c,SVMXC__Name__c, SVMXC__Action_On_Zero_Lines__c,SVMXC__Allow_New_Lines__c, SVMXC__Allow_Delete_Lines__c,  OwnerId, Name, LastModifiedDate, LastModifiedById,  IsDeleted, Id, CreatedDate, CreatedById From SVMXC__Page_Layout__c where SVMXC__Header_Page_Layout__c =: SFMProcess.SVMXC__Page_Layout__c and id =: Alias];//
            if(PageLayout != null && PageLayout.id != null)
            {
                if(Userinfo.isMultiCurrencyOrganization())
                    //SDL-SVMX-FLS-NOT-ENFORCED-META-DATA
                    PageLayoutDetailList = [Select SVMXC__Title__c, SVMXC__Sequence__c, SVMXC__Section__c, SVMXC__Required__c, SVMXC__Related_Object_Name__c, SVMXC__Related_Object_Name_Field__c, SVMXC__Readonly__c, SVMXC__Page_Layout__c, SVMXC__Override_Related_Lookup__c, SVMXC__Named_Search__c, SVMXC__Named_Search__r.SVMXC__Default_Lookup_Column__c,  SVMXC__Lookup_Query_Field__c, SVMXC__Lookup_Context__c,  SVMXC__IsStandard__c, SVMXC__Field_API_Name__c, SVMXC__Display_Row__c, SVMXC__Display_Column__c, SVMXC__Detail_Type__c, SVMXC__DataType__c, Name, Id From SVMXC__Page_Layout_Detail__c where SVMXC__Page_Layout__c =: PageLayout.id and SVMXC__Detail_Type__c = 'Field'];
                else
                    //SDL-SVMX-FLS-NOT-ENFORCED-META-DATA
                    PageLayoutDetailList = [Select SVMXC__Title__c, SVMXC__Sequence__c, SVMXC__Section__c, SVMXC__Required__c, SVMXC__Related_Object_Name__c, SVMXC__Related_Object_Name_Field__c, SVMXC__Readonly__c, SVMXC__Page_Layout__c, SVMXC__Override_Related_Lookup__c, SVMXC__Named_Search__c, SVMXC__Named_Search__r.SVMXC__Default_Lookup_Column__c,  SVMXC__Lookup_Query_Field__c, SVMXC__Lookup_Context__c,  SVMXC__IsStandard__c, SVMXC__Field_API_Name__c, SVMXC__Display_Row__c, SVMXC__Display_Column__c, SVMXC__Detail_Type__c, SVMXC__DataType__c, Name, Id From SVMXC__Page_Layout_Detail__c where SVMXC__Page_Layout__c =: PageLayout.id and SVMXC__Detail_Type__c = 'Field' and SVMXC__Field_API_Name__c != 'CurrencyIsoCode'];  
            } 
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
                    Sobjlsit = Mapping.getValueMapping1(Sobjlsit,processNodeObject.SVMXC__Final_Exception_Process__c,allobjmap,SFMProcess.SVMXC__Purpose__c);
                //if its multiadd then put the Ids  from multiadd list..
                if(Sobjlsit.size() > 0 && MultiAddRecList.size() > 0 && FieldAPIName != null && FieldAPIName.length() > 0)
                {
                    for(Integer i = 0;i<Sobjlsit.size();i++)
                    {
                        Sobjlsit[i].put(FieldAPIName,MultiAddRecList[i]);
                    }
                }
                system.debug('Sobjlsit'+Sobjlsit);
                if(Sobjlsit.size() > 0)
                {
                    if(allobjmap.containskey(processNodeObject.SVMXC__Source_Object_Name__c))
                    {
                        map<String, Schema.SObjectField> mapAllField = new map<String, Schema.SObjectField>();
                        map<String, Schema.SObjectField> mapAPINameField = new map<String, Schema.SObjectField>();
                        list<String> lstDateTimeField = new list<String>();
                        mapAllField = allobjmap.get(processNodeObject.SVMXC__Source_Object_Name__c).getDescribe().fields.getMap();
                        if(mapAllField.size() > 0)
                        {
                            for(String s : mapAllField.keyset())
                            {
                                mapAPINameField.put(mapAllField.get(s).getDescribe().getName(),mapAllField.get(s));
                            }
                        }
                        //Loop all field describe and get datatime fields.
                        if(mapAPINameField.size() > 0)
                        {
                            for(String s : mapAPINameField.keyset())
                            {
                                Schema.DescribeFieldResult f = mapAPINameField.get(s).getDescribe();
                                if(f.isAccessible() && f.isCreateable() && f.isUpdateable() && f.getType() == schema.Displaytype.DateTime)//
                                {
                                    lstDateTimeField.add(s);
                                }
                            }
                        }
                        system.debug('lstDateTimeField: '+lstDateTimeField);
                        if(lstDateTimeField.size() > 0)
                        {
                            for(Integer i = 0;i<Sobjlsit.size();i++)
                            {
                                for(integer j = 0;j<lstDateTimeField.size();j++)
                                {
                                    system.debug('Header Field: '+lstDateTimeField[j]+'Value: '+Sobjlsit[i].get(lstDateTimeField[j]));
                                    if(Sobjlsit[i].get(lstDateTimeField[j]) != null)
                                    {
                                        String dat = (datetime.valueof(Sobjlsit[i].get(lstDateTimeField[j]))).format('yyyy-MM-dd HH:mm:ss');
                                        system.debug(lstDateTimeField[j]+': '+dat); 
                                        Sobjlsit[i].put(lstDateTimeField[j],Datetime.valueofgmt(dat));
                                    }    
                                }
                            } 
                        }    
                    }
                    
                }
                if(Sobjlsit.size() > 0 && PageLayoutDetailList.size() > 0)
                {
                    for(Integer i = 0;i<Sobjlsit.size();i++)
                    {
                        SVMXC.SFM_WrapperDef.SFM_PageDataSet PageDataSet = new SVMXC.SFM_WrapperDef.SFM_PageDataSet();
                        PageDataSet.sobjectinfo = Sobjlsit[i];
                        list<SVMXC.SFM_WrapperDef.SFM_BubbleWrapper> BubbleWrapperList = new list<SVMXC.SFM_WrapperDef.SFM_BubbleWrapper>();
                        for(Integer j = 0;j<PageLayoutDetailList.size();j++)
                        {
                            if(PageLayoutDetailList[j].SVMXC__Field_API_Name__c != null)
                            {
                                SVMXC.SFM_WrapperDef.SFM_BubbleWrapper BubbleWrapper = new SVMXC.SFM_WrapperDef.SFM_BubbleWrapper();
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
                                    
                                    SVMXC.SFM_WrapperDef.SFM_StringMap strmap = new SVMXC.SFM_WrapperDef.SFM_StringMap();
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