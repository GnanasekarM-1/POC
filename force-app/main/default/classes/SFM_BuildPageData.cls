public with sharing class SFM_BuildPageData
{
    public SFM_buildPageData(){}
    
    public SVMXC.SFM_WrapperDef.SFM_PageData SFM_buildPageData(SVMXC.SFM_WrapperDef.SFM_TargetRecord sfmtargetrec)
    {
        SVMXC.SFM_Utils SFMUtils = new SVMXC.SFM_Utils(); 
        SVMXC.SFM_WrapperDef.SFM_TargetRecordObject HeaderRecord = new SVMXC.SFM_WrapperDef.SFM_TargetRecordObject();
        system.debug('sfmtargetrecamar'+sfmtargetrec);
        list<SVMXC.SFM_WrapperDef.SFM_TargetRecordObject> DetailRecords = new list<SVMXC.SFM_WrapperDef.SFM_TargetRecordObject>();
        if(sfmtargetrec.headerRecord != null)
            HeaderRecord = sfmtargetrec.headerRecord;
        system.debug('HeaderRecord'+HeaderRecord);    
        if(sfmtargetrec.detailRecords != null && sfmtargetrec.detailRecords.size() > 0)
            DetailRecords = sfmtargetrec.detailRecords;     
        system.debug('DetailRecords'+DetailRecords);    
        SVMXC.SFM_WrapperDef.SFM_PageDataSet PageDataSet = new SVMXC.SFM_WrapperDef.SFM_PageDataSet();//SFM_PageDataSet
        //First Process The Header Record..
        list<SVMXC.SFM_WrapperDef.SFM_StringMap> TargetRecordAsKeyValue = new list<SVMXC.SFM_WrapperDef.SFM_StringMap>();  
        list<SVMXC.SFM_WrapperDef.SFM_Record> HeaderSFMRecord = new list<SVMXC.SFM_WrapperDef.SFM_Record>(); 
        if(HeaderRecord.records != null && HeaderRecord.records.size() > 0) 
            HeaderSFMRecord = HeaderRecord.records;
        PageDataSet.sourceRecordID = HeaderSFMRecord[0].sourceRecordId;
        PageDataSet.sobjectinfo = HeaderSFMRecord[0].sobjectinfo;
        TargetRecordAsKeyValue = HeaderSFMRecord[0].targetRecordAsKeyValue;
        String HdrPagelayoutId = '';
        if(HeaderRecord.pageLayoutId != null)
            HdrPagelayoutId = HeaderRecord.pageLayoutId;
        system.debug('HdrPagelayoutId'+HdrPagelayoutId);    
        system.debug('TargetRecordAsKeyValue'+TargetRecordAsKeyValue);
        //Get the Page Defination for populating the bubbleinfo and lookup fields with name and id
        list<SVMXC__Page_Layout_Detail__c> HeaderFieldList = new list<SVMXC__Page_Layout_Detail__c>();
        map<String,SVMXC__Page_Layout_Detail__c> HeaderFieldMap = new map<String,SVMXC__Page_Layout_Detail__c>(); 
        //BAC-5357
        if(String.isNotEmpty(HdrPagelayoutId))
        {
          HeaderFieldList = [Select SystemModstamp, SVMXC__Title__c, SVMXC__Sequence__c, SVMXC__Section__c, SVMXC__Required__c, SVMXC__Related_Object_Name__c, SVMXC__Related_Object_Name_Field__c, SVMXC__Readonly__c, SVMXC__Page_Layout__c, SVMXC__Page_Layout_Detail_Id__c, SVMXC__Override_Related_Lookup__c, SVMXC__No_Of_Columns__c, SVMXC__Named_Search__c, SVMXC__Named_Search__r.SVMXC__Default_Lookup_Column__c ,SVMXC__Lookup_Query_Field__c, SVMXC__Lookup_Context__c, SVMXC__IsStandard__c, SVMXC__Installation_Key__c, SVMXC__Field_API_Name__c, SVMXC__Display_Row__c, SVMXC__Display_Column__c, SVMXC__Detail_Type__c, SVMXC__DataType__c, Name, LastModifiedDate, LastModifiedById, IsDeleted, Id, CreatedDate, CreatedById From SVMXC__Page_Layout_Detail__c where SVMXC__Page_Layout__c =: HdrPagelayoutId and SVMXC__Detail_Type__c = 'Field']; //SDL-SVMX-FLS-NOT-ENFORCED-META-DATA
        }
        if(!HeaderFieldList.isEmpty())
        {
            for(SVMXC__Page_Layout_Detail__c PLD : HeaderFieldList)
            {
                if(PLD.SVMXC__Field_API_Name__c != null)
                    HeaderFieldMap.put(PLD.SVMXC__Field_API_Name__c,PLD);
            }
        }
        system.debug('HeaderFieldMap'+HeaderFieldMap);
        list<SVMXC.SFM_WrapperDef.SFM_BubbleWrapper> BubbleWrapperList = new list<SVMXC.SFM_WrapperDef.SFM_BubbleWrapper>();
        //BAC-5357
        if(!HeaderFieldMap.isEmpty() && !TargetRecordAsKeyValue.isEmpty())
        {
            Integer sizeOfTargetRecordAsKeyValue = TargetRecordAsKeyValue.size();
            for(Integer i = 0;i<sizeOfTargetRecordAsKeyValue; i++)
            {
                SVMXC.SFM_WrapperDef.SFM_BubbleWrapper BubbleWrapper = new SVMXC.SFM_WrapperDef.SFM_BubbleWrapper(null);
                String DefaultValue = '';
                String targetRecordKey = TargetRecordAsKeyValue[i].key;
                if(targetRecordKey != null)//HeaderFieldMap.containskey(TargetRecordAsKeyValue[i].key)
                {
                    if(TargetRecordAsKeyValue[i].value != null)
                        DefaultValue = TargetRecordAsKeyValue[i].value;
                    system.debug('TargetRecordAsKeyValue[i].key'+targetRecordKey);
                    BubbleWrapper.fieldapiname = targetRecordKey ;
                    system.debug('DefaultValue'+DefaultValue);
                    Boolean isDefaultValueNotEmpty = String.isNotEmpty(DefaultValue);
                    if(HeaderFieldMap.containskey(targetRecordKey))
                    {
                        if(HeaderFieldMap.get(targetRecordKey).SVMXC__DataType__c != null && HeaderFieldMap.get(targetRecordKey).SVMXC__DataType__c.touppercase() != 'REFERENCE'&& isDefaultValueNotEmpty)
                        {
                            system.debug('Called Not REFERENCE');
                            BubbleWrapper.fieldvalue.key = DefaultValue; 
                            BubbleWrapper.fieldvalue.value = DefaultValue;
                        }
                        if(HeaderFieldMap.get(targetRecordKey).SVMXC__DataType__c.touppercase() == 'REFERENCE' && isDefaultValueNotEmpty)
                        {
                            system.debug('Called REFERENCE');
                            system.debug('Called REFERENCE'+HeaderFieldMap.get(targetRecordKey).SVMXC__Related_Object_Name__c+HeaderFieldMap.get(targetRecordKey).SVMXC__Related_Object_Name_Field__c);
                            SVMXC.SFM_WrapperDef.SFM_StringMap strmap = new SVMXC.SFM_WrapperDef.SFM_StringMap();
                            strmap.key = DefaultValue;
                            if(TargetRecordAsKeyValue[i].value1 != null)
                                strmap.value1 = TargetRecordAsKeyValue[i].value1;
                            if(TargetRecordAsKeyValue[i].value != null)
                                strmap.value = TargetRecordAsKeyValue[i].value;
                            BubbleWrapper.fieldvalue = strmap;
                            //Now start making the bubbleinfo for the Reference fields...
                           // if(HeaderFieldMap.get(TargetRecordAsKeyValue[i].key).SVMXC__Named_Search__c != null &&  HeaderFieldMap.get(TargetRecordAsKeyValue[i].key).SVMXC__Related_Object_Name__c != null)
                              //  BubbleWrapper.bubbleinfo = SFMUtils.getBubbleinfo(DefaultValue,HeaderFieldMap.get(TargetRecordAsKeyValue[i].key).SVMXC__Named_Search__c,HeaderFieldMap.get(TargetRecordAsKeyValue[i].key).SVMXC__Related_Object_Name__c);
                        } 
                    }
                    else
                    {
                        if(isDefaultValueNotEmpty)
                        {
                            BubbleWrapper.fieldvalue.key = DefaultValue; 
                            BubbleWrapper.fieldvalue.value = DefaultValue;
                        }   
                    }        
                }
                BubbleWrapperList.add(BubbleWrapper); 
            }      
        }
        //Assign the Bubble info to the SFM_PageDataSet..
        PageDataSet.bubbleInfo = BubbleWrapperList;
        list<SVMXC.SFM_WrapperDef.SFM_DetailDataSet> DetailDataSetList = new list<SVMXC.SFM_WrapperDef.SFM_DetailDataSet>();
        //BAC-5357
        if(!DetailRecords.isEmpty())
        {
            system.debug('Entered.....');
            Integer sizeOfDetailRecords = DetailRecords.size();
            for(Integer i = 0;i<sizeOfDetailRecords; i++)
            {
                list<SVMXC.SFM_WrapperDef.SFM_Record> DetailSFMRecord = new list<SVMXC.SFM_WrapperDef.SFM_Record>();
                SVMXC.SFM_WrapperDef.SFM_DetailDataSet DetailDataSet = new SVMXC.SFM_WrapperDef.SFM_DetailDataSet();
                String AliasName = DetailRecords[i].aliasName;
                DetailSFMRecord = DetailRecords[i].records;
                system.debug('DetailSFMRecord'+DetailSFMRecord);
                String DtlPageLayoutId = '';
                DtlPageLayoutId = DetailRecords[i].pageLayoutId;
                List<SVMXC__Page_Layout_Detail__c> DetailFieldList = new List<SVMXC__Page_Layout_Detail__c>();
                Map<String,SVMXC__Page_Layout_Detail__c> DetailFieldMap = new Map<String,SVMXC__Page_Layout_Detail__c>();
                //BAC-5357
                if(String.isNotEmpty(DtlPageLayoutId))
                
                    DetailFieldList = [Select SystemModstamp, SVMXC__Title__c, SVMXC__Sequence__c, SVMXC__Section__c, SVMXC__Required__c, SVMXC__Related_Object_Name__c, SVMXC__Related_Object_Name_Field__c, SVMXC__Readonly__c, SVMXC__Page_Layout__c, SVMXC__Page_Layout_Detail_Id__c, SVMXC__Override_Related_Lookup__c, SVMXC__No_Of_Columns__c, SVMXC__Named_Search__c, SVMXC__Named_Search__r.SVMXC__Default_Lookup_Column__c,SVMXC__Lookup_Query_Field__c, SVMXC__Lookup_Context__c, SVMXC__IsStandard__c, SVMXC__Installation_Key__c, SVMXC__Field_API_Name__c, SVMXC__Display_Row__c, SVMXC__Display_Column__c, SVMXC__Detail_Type__c, SVMXC__DataType__c, Name, LastModifiedDate, LastModifiedById, IsDeleted, Id, CreatedDate, CreatedById From SVMXC__Page_Layout_Detail__c where SVMXC__Page_Layout__c =: DtlPageLayoutId and SVMXC__Detail_Type__c = 'Field']; //SDL-SVMX-FLS-NOT-ENFORCED-META-DATA
                system.debug('DetailFieldList'+DetailFieldList);
                if(!DetailFieldList.isEmpty())
                {
                    for(SVMXC__Page_Layout_Detail__c PLD : DetailFieldList)
                    {
                        if(PLD.SVMXC__Field_API_Name__c != null)
                            DetailFieldMap.put(PLD.SVMXC__Field_API_Name__c,PLD);
                    }
                }
                system.debug('DetailFieldMap'+DetailFieldMap);
                list<SVMXC.SFM_WrapperDef.SFM_PageDataSet> DetailPageDataSetList = new list<SVMXC.SFM_WrapperDef.SFM_PageDataSet>();
                //BAC-5357
               if(!DetailFieldList.isEmpty() && !DetailFieldMap.isEmpty() && DetailSFMRecord != null && !DetailSFMRecord.isEmpty())
                {
                    /*map<String,String> FieldObjMap = new map<String,String>();
                    map<String,String> FieldNameFieldMap = new map<String,String>(); 
                    for(SVMXC__Page_Layout_Detail__c DtlFld : DetailFieldList)
                    {
                        if(DtlFld.SVMXC__DataType__c != null && DtlFld.SVMXC__DataType__c.touppercase() == 'REFERENCE' && DtlFld.SVMXC__Field_API_Name__c != null && DtlFld.SVMXC__Related_Object_Name__c != null && DtlFld.SVMXC__Related_Object_Name_Field__c != null)
                        {
                            FieldObjMap.put(DtlFld.SVMXC__Field_API_Name__c,DtlFld.SVMXC__Related_Object_Name__c);
                            FieldNameFieldMap.put(DtlFld.SVMXC__Field_API_Name__c,DtlFld.SVMXC__Related_Object_Name_Field__c);
                        }
                    }
                    if(FieldObjMap.size() > 0 && FieldNameFieldMap.size() > 0)
                    {
                        for(Integer a = 0;a<DetailSFMRecord.size();a++)
                        {
                            list<SVMXC.SFM_WrapperDef.SFM_StringMap> TempKeyValue = new list<SVMXC.SFM_WrapperDef.SFM_StringMap>();
                            TempKeyValue = DetailSFMRecord[j].targetRecordAsKeyValue;
                            if(TempKeyValue.)
                        }
                    }*/
                    Integer sizeOfDetailSFMRecord = DetailSFMRecord.size();
                    for(Integer j = 0;j<sizeOfDetailSFMRecord ;j++)
                    {
                        List<SVMXC.SFM_WrapperDef.SFM_StringMap> DetailTargetRecordAsKeyValue = new List<SVMXC.SFM_WrapperDef.SFM_StringMap>();
                        //BAC-5357
                        List<SVMXC.SFM_WrapperDef.SFM_BubbleWrapper> DetailBubbleWrapperList = new List<SVMXC.SFM_WrapperDef.SFM_BubbleWrapper>();
                        //TempPageDataSet.sourceRecordID = DetailSFMRecord[j].sourceRecordId;
                        DetailTargetRecordAsKeyValue = DetailSFMRecord[j].targetRecordAsKeyValue;
                        //TempPageDataSet.sobjectinfo = DetailSFMRecord[j].sobjectinfo;
                        String rowIndex =  DetailSFMRecord[j].rowIndex != null ? String.valueOf(DetailSFMRecord[j].rowIndex) : null ; //Added for the defect BAC-4534
                        system.debug('DetailTargetRecordAsKeyValue'+DetailTargetRecordAsKeyValue);
                         SVMXC.SFM_WrapperDef.SFM_PageDataSet TempPageDataSet = null;
                        TempPageDataSet = new SVMXC.SFM_WrapperDef.SFM_PageDataSet(DetailSFMRecord[j].sourceRecordId,DetailSFMRecord[j].sobjectinfo,rowIndex);
                        //BAC-5357
                        if(!DetailTargetRecordAsKeyValue.isEmpty())
                        {
                            Integer sizeOfDetailTargetRecordAsKeyValue = DetailTargetRecordAsKeyValue.size();
                            for(Integer k = 0;k<sizeOfDetailTargetRecordAsKeyValue;k++)
                            {
                               //BAC-5357
                                SVMXC.SFM_WrapperDef.SFM_BubbleWrapper BubbleWrapper = new SVMXC.SFM_WrapperDef.SFM_BubbleWrapper(null);
                                String detailTargetRecordKey = DetailTargetRecordAsKeyValue[k].key;
                                if(detailTargetRecordKey != null )//&& DetailFieldMap.containskey(DetailTargetRecordAsKeyValue[k].key)
                                {
                                    String DefaultValue = '';
                                    if(DetailTargetRecordAsKeyValue[k].value != null)
                                        DefaultValue = DetailTargetRecordAsKeyValue[k].value;
                                    BubbleWrapper.fieldapiname = detailTargetRecordKey;
                                    system.debug('DefaultValue'+DetailFieldMap.get(DetailTargetRecordAsKeyValue[k].key)+','+DefaultValue);
                                    Boolean isDefaultValueNotEmpty = String.isNotEmpty(DefaultValue);
                                    if(DetailFieldMap.containskey(detailTargetRecordKey))
                                    {
                                        if(DetailFieldMap.get(detailTargetRecordKey).SVMXC__DataType__c.touppercase() != 'REFERENCE'&& isDefaultValueNotEmpty)
                                        {
                                            system.debug('Called Not REFERENCE');
                                            BubbleWrapper.fieldvalue.key = DefaultValue; 
                                            BubbleWrapper.fieldvalue.value = DefaultValue;
                                        }
                                        if(DetailFieldMap.get(detailTargetRecordKey).SVMXC__DataType__c.touppercase() == 'REFERENCE' && isDefaultValueNotEmpty)
                                        {
                                            system.debug('Called REFERENCE');
                                            system.debug('Called REFERENCE'+DetailFieldMap.get(detailTargetRecordKey).SVMXC__Related_Object_Name__c+DetailFieldMap.get(detailTargetRecordKey).SVMXC__Related_Object_Name_Field__c);
                                            SVMXC.SFM_WrapperDef.SFM_StringMap strmap = new SVMXC.SFM_WrapperDef.SFM_StringMap();
                                            strmap.key = DefaultValue;
                                            if(DetailTargetRecordAsKeyValue[k].value1 != null)
                                                strmap.value1 = DetailTargetRecordAsKeyValue[k].value1;
                                            if(DetailTargetRecordAsKeyValue[k].value != null)
                                                strmap.value = DetailTargetRecordAsKeyValue[k].value;   
                                            BubbleWrapper.fieldvalue = strmap;
                                            //Now start making the bubbleinfo for the Reference fields...
                                            //if(DetailFieldMap.get(DetailTargetRecordAsKeyValue[k].key).SVMXC__Named_Search__c != null &&  DetailFieldMap.get(DetailTargetRecordAsKeyValue[k].key).SVMXC__Related_Object_Name__c != null)
                                                //BubbleWrapper.bubbleinfo = SFMUtils.getBubbleinfo(DefaultValue,DetailFieldMap.get(DetailTargetRecordAsKeyValue[k].key).SVMXC__Named_Search__c,DetailFieldMap.get(DetailTargetRecordAsKeyValue[k].key).SVMXC__Related_Object_Name__c);
                                        }
                                    }
                                    else
                                    {
                                        //BAC-5357
                                        if(isDefaultValueNotEmpty)
                                        {
                                            BubbleWrapper.fieldvalue.key = DefaultValue; 
                                            BubbleWrapper.fieldvalue.value = DefaultValue;
                                        }   
                                    }         
                                }
                                DetailBubbleWrapperList.add(BubbleWrapper);
                            }
                            TempPageDataSet.bubbleInfo = DetailBubbleWrapperList;
                        }
                        DetailPageDataSetList.add(TempPageDataSet);
                    }
                }
                DetailDataSet.pageDataSet = DetailPageDataSetList;
                DetailDataSet.aliasName = AliasName;
                system.debug('DetailDataSet'+DetailDataSet);
                DetailDataSetList.add(DetailDataSet);
            }
        }   
        SVMXC.SFM_WrapperDef.SFM_PageData pagedata = new SVMXC.SFM_WrapperDef.SFM_PageData();
        pagedata.eventType = sfmtargetrec.eventType;
        pagedata.pageDataSet =  PageDataSet;
        pagedata.detailDataSet = DetailDataSetList; 
        return pagedata;    
    }
}