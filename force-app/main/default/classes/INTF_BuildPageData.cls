public with sharing class INTF_BuildPageData
{
    public INTF_buildPageData(){}
    
    public SVMXC.INTF_WebServicesDef.INTF_PageData INTF_buildPageData(SVMXC.INTF_WebServicesDef.INTF_TargetRecord sfmtargetrec)
    {
        SVMXC.SFM_Utils SFMUtils = new SVMXC.SFM_Utils(); 
        SVMXC.INTF_WebServicesDef.INTF_TargetRecordObject HeaderRecord = new SVMXC.INTF_WebServicesDef.INTF_TargetRecordObject();
        system.debug('sfmtargetrecamar'+sfmtargetrec);
        list<SVMXC.INTF_WebServicesDef.INTF_TargetRecordObject> DetailRecords = new list<SVMXC.INTF_WebServicesDef.INTF_TargetRecordObject>();
        if(sfmtargetrec.headerRecord != null)
            HeaderRecord = sfmtargetrec.headerRecord;
        system.debug('HeaderRecord'+HeaderRecord);    
        if(sfmtargetrec.detailRecords != null && sfmtargetrec.detailRecords.size() > 0)
            DetailRecords = sfmtargetrec.detailRecords;     
        system.debug('DetailRecords'+DetailRecords);    
        SVMXC.INTF_WebServicesDef.INTF_PageDataSet PageDataSet = new SVMXC.INTF_WebServicesDef.INTF_PageDataSet();//INTF_PageDataSet
        //First Process The Header Record..
        list<SVMXC.INTF_WebServicesDef.INTF_StringMap> TargetRecordAsKeyValue = new list<SVMXC.INTF_WebServicesDef.INTF_StringMap>();  
        list<SVMXC.INTF_WebServicesDef.INTF_Record> HeaderSFMRecord = new list<SVMXC.INTF_WebServicesDef.INTF_Record>(); 
        if(HeaderRecord.records != null && HeaderRecord.records.size() > 0) 
            HeaderSFMRecord = HeaderRecord.records;
        PageDataSet.sourceRecordID = HeaderSFMRecord[0].sourceRecordId;
        TargetRecordAsKeyValue = HeaderSFMRecord[0].targetRecordAsKeyValue;
        String HdrPagelayoutId = '';
        if(HeaderRecord.pageLayoutId != null)
            HdrPagelayoutId = HeaderRecord.pageLayoutId;
        system.debug('HdrPagelayoutId'+HdrPagelayoutId);    
        system.debug('TargetRecordAsKeyValue'+TargetRecordAsKeyValue);
        //Get the Page Defination for populating the bubbleinfo and lookup fields with name and id
        list<SVMXC__Page_Layout_Detail__c> HeaderFieldList = new list<SVMXC__Page_Layout_Detail__c>();
        map<String,SVMXC__Page_Layout_Detail__c> HeaderFieldMap = new map<String,SVMXC__Page_Layout_Detail__c>(); 
        if(HdrPagelayoutId != null && HdrPagelayoutId.length() > 0)
            HeaderFieldList = [Select SystemModstamp, SVMXC__Title__c, SVMXC__Sequence__c, SVMXC__Section__c, SVMXC__Required__c, SVMXC__Related_Object_Name__c, SVMXC__Related_Object_Name_Field__c, SVMXC__Readonly__c, SVMXC__Page_Layout__c, SVMXC__Page_Layout_Detail_Id__c, SVMXC__Override_Related_Lookup__c, SVMXC__No_Of_Columns__c, SVMXC__Named_Search__c, SVMXC__Named_Search__r.SVMXC__Default_Lookup_Column__c ,SVMXC__Lookup_Query_Field__c, SVMXC__Lookup_Context__c, SVMXC__IsStandard__c, SVMXC__Installation_Key__c, SVMXC__Field_API_Name__c, SVMXC__Display_Row__c, SVMXC__Display_Column__c, SVMXC__Detail_Type__c, SVMXC__DataType__c, Name, LastModifiedDate, LastModifiedById,  IsDeleted, Id, CreatedDate, CreatedById From SVMXC__Page_Layout_Detail__c where SVMXC__Page_Layout__c =: HdrPagelayoutId and SVMXC__Detail_Type__c = 'Field'];   //SDL-SVMX-FLS-NOT-ENFORCED-META-DATA
        if(HeaderFieldList.size() > 0)
        {
            for(SVMXC__Page_Layout_Detail__c PLD : HeaderFieldList)
            {
                if(PLD.SVMXC__Field_API_Name__c != null)
                    HeaderFieldMap.put(PLD.SVMXC__Field_API_Name__c,PLD);
            }
        }
        system.debug('HeaderFieldMap'+HeaderFieldMap);
        list<SVMXC.INTF_WebServicesDef.INTF_BubbleWrapper> BubbleWrapperList = new list<SVMXC.INTF_WebServicesDef.INTF_BubbleWrapper>();
        if(HeaderFieldMap.size() > 0 && TargetRecordAsKeyValue.size() > 0)
        {
            
            for(Integer i = 0;i<TargetRecordAsKeyValue.size();i++)
            {
                SVMXC.INTF_WebServicesDef.INTF_BubbleWrapper BubbleWrapper = new SVMXC.INTF_WebServicesDef.INTF_BubbleWrapper();
                String DefaultValue = '';
                if(TargetRecordAsKeyValue[i].key != null)//HeaderFieldMap.containskey(TargetRecordAsKeyValue[i].key)
                {
                    if(TargetRecordAsKeyValue[i].value != null)
                        DefaultValue = TargetRecordAsKeyValue[i].value;
                    system.debug('TargetRecordAsKeyValue[i].key'+TargetRecordAsKeyValue[i].key);
                    BubbleWrapper.fieldapiname = TargetRecordAsKeyValue[i].key;
                    system.debug('DefaultValue'+DefaultValue);
                    if(HeaderFieldMap.containskey(TargetRecordAsKeyValue[i].key))
                    {
                        if(HeaderFieldMap.get(TargetRecordAsKeyValue[i].key).SVMXC__DataType__c != null && HeaderFieldMap.get(TargetRecordAsKeyValue[i].key).SVMXC__DataType__c.touppercase() != 'REFERENCE'&& DefaultValue != null && DefaultValue.length() > 0)
                        {
                            system.debug('Called Not REFERENCE');
                            BubbleWrapper.fieldvalue.key = DefaultValue; 
                            BubbleWrapper.fieldvalue.value = DefaultValue;
                        }
                        if(HeaderFieldMap.get(TargetRecordAsKeyValue[i].key).SVMXC__DataType__c.touppercase() == 'REFERENCE' && DefaultValue != null && DefaultValue.length() > 0)
                        {
                            system.debug('Called REFERENCE');
                            system.debug('Called REFERENCE'+HeaderFieldMap.get(TargetRecordAsKeyValue[i].key).SVMXC__Related_Object_Name__c+HeaderFieldMap.get(TargetRecordAsKeyValue[i].key).SVMXC__Related_Object_Name_Field__c);
                            SVMXC.INTF_WebServicesDef.INTF_StringMap strmap = new SVMXC.INTF_WebServicesDef.INTF_StringMap();
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
                        if(DefaultValue != null && DefaultValue.length() > 0)
                        {
                            BubbleWrapper.fieldvalue.key = DefaultValue; 
                            BubbleWrapper.fieldvalue.value = DefaultValue;
                        }   
                    }        
                }
                BubbleWrapperList.add(BubbleWrapper); 
            }      
        }
        //Assign the Bubble info to the INTF_PageDataSet..
        PageDataSet.bubbleInfo = BubbleWrapperList;
        //Jaysukh BAC - 3234
        List<INTF_WebServicesDef.INTF_StringMap> objList = new List<INTF_WebServicesDef.INTF_StringMap>();
        INTF_WebServicesDef.INTF_StringMap obj = new INTF_WebServicesDef.INTF_StringMap();
        obj.key= 'OBJECT_NAME';
        obj.value = HeaderRecord.objName;
        objList.add(obj);
        PageDataSet.objectInfoMap = objList;
        //Jaysukh BAC - 3234
        list<SVMXC.INTF_WebServicesDef.INTF_DetailDataSet> DetailDataSetList = new list<SVMXC.INTF_WebServicesDef.INTF_DetailDataSet>();
        if(DetailRecords.size() > 0)
        {
            system.debug('Entered.....');
            for(Integer i = 0;i<DetailRecords.size();i++)
            {
                list<SVMXC.INTF_WebServicesDef.INTF_Record> DetailSFMRecord = new list<SVMXC.INTF_WebServicesDef.INTF_Record>();
                SVMXC.INTF_WebServicesDef.INTF_DetailDataSet DetailDataSet = new SVMXC.INTF_WebServicesDef.INTF_DetailDataSet();
                String AliasName = DetailRecords[i].aliasName;
                DetailSFMRecord = DetailRecords[i].records;
                system.debug('DetailSFMRecord'+DetailSFMRecord);
                String DtlPageLayoutId = '';
                DtlPageLayoutId = DetailRecords[i].pageLayoutId;
                list<SVMXC__Page_Layout_Detail__c> DetailFieldList = new list<SVMXC__Page_Layout_Detail__c>();
                map<String,SVMXC__Page_Layout_Detail__c> DetailFieldMap = new map<String,SVMXC__Page_Layout_Detail__c>();
                if(DtlPageLayoutId != null && DtlPageLayoutId.length() > 0)
                    DetailFieldList = [Select SystemModstamp, SVMXC__Title__c, SVMXC__Sequence__c, SVMXC__Section__c, SVMXC__Required__c, SVMXC__Related_Object_Name__c, SVMXC__Related_Object_Name_Field__c, SVMXC__Readonly__c, SVMXC__Page_Layout__c, SVMXC__Page_Layout_Detail_Id__c, SVMXC__Override_Related_Lookup__c, SVMXC__No_Of_Columns__c, SVMXC__Named_Search__c, SVMXC__Named_Search__r.SVMXC__Default_Lookup_Column__c,SVMXC__Lookup_Query_Field__c, SVMXC__Lookup_Context__c, SVMXC__IsStandard__c, SVMXC__Installation_Key__c, SVMXC__Field_API_Name__c, SVMXC__Display_Row__c, SVMXC__Display_Column__c, SVMXC__Detail_Type__c, SVMXC__DataType__c, Name, LastModifiedDate, LastModifiedById,  IsDeleted, Id, CreatedDate, CreatedById From SVMXC__Page_Layout_Detail__c where SVMXC__Page_Layout__c =: DtlPageLayoutId and SVMXC__Detail_Type__c = 'Field'];   //SDL-SVMX-FLS-NOT-ENFORCED-META-DATA
                system.debug('DetailFieldList'+DetailFieldList);
                if(DetailFieldList.size() > 0)
                {
                    for(SVMXC__Page_Layout_Detail__c PLD : DetailFieldList)
                    {
                        if(PLD.SVMXC__Field_API_Name__c != null)
                            DetailFieldMap.put(PLD.SVMXC__Field_API_Name__c,PLD);
                    }
                }
                system.debug('DetailFieldMap'+DetailFieldMap);
                list<SVMXC.INTF_WebServicesDef.INTF_PageDataSet> DetailPageDataSetList = new list<SVMXC.INTF_WebServicesDef.INTF_PageDataSet>();
                if(DetailFieldList.size() > 0 && DetailFieldMap.size() > 0 && DetailSFMRecord != null && DetailSFMRecord.size() > 0)
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
                            list<SVMXC.INTF_WebServicesDef.INTF_StringMap> TempKeyValue = new list<SVMXC.INTF_WebServicesDef.INTF_StringMap>();
                            TempKeyValue = DetailSFMRecord[j].targetRecordAsKeyValue;
                            if(TempKeyValue.)
                        }
                    }*/
                    for(Integer j = 0;j<DetailSFMRecord.size();j++)
                    {
                        list<SVMXC.INTF_WebServicesDef.INTF_StringMap> DetailTargetRecordAsKeyValue = new list<SVMXC.INTF_WebServicesDef.INTF_StringMap>();
                        SVMXC.INTF_WebServicesDef.INTF_PageDataSet TempPageDataSet = new SVMXC.INTF_WebServicesDef.INTF_PageDataSet();
                        list<SVMXC.INTF_WebServicesDef.INTF_BubbleWrapper> DetailBubbleWrapperList = new list<SVMXC.INTF_WebServicesDef.INTF_BubbleWrapper>();
                        TempPageDataSet.sourceRecordID = DetailSFMRecord[j].sourceRecordId;
                        TempPageDataSet.rowIndex = DetailSFMRecord[j].rowIndex != null ? String.valueOf(DetailSFMRecord[j].rowIndex) : null ; //Added for the defect BAC-4534
                        DetailTargetRecordAsKeyValue = DetailSFMRecord[j].targetRecordAsKeyValue;
                        system.debug('DetailTargetRecordAsKeyValue'+DetailTargetRecordAsKeyValue);
                        if(DetailTargetRecordAsKeyValue.size() > 0)
                        {
                            for(Integer k = 0;k<DetailTargetRecordAsKeyValue.size();k++)
                            {
                                SVMXC.INTF_WebServicesDef.INTF_BubbleWrapper BubbleWrapper = new SVMXC.INTF_WebServicesDef.INTF_BubbleWrapper();
                                String DefaultValue = '';
                                if(DetailTargetRecordAsKeyValue[k].key != null )//&& DetailFieldMap.containskey(DetailTargetRecordAsKeyValue[k].key)
                                {
                                    if(DetailTargetRecordAsKeyValue[k].value != null)
                                        DefaultValue = DetailTargetRecordAsKeyValue[k].value;
                                    BubbleWrapper.fieldapiname = DetailTargetRecordAsKeyValue[k].key;
                                    system.debug('DefaultValue'+DetailFieldMap.get(DetailTargetRecordAsKeyValue[k].key)+','+DefaultValue);
                                    if(DetailFieldMap.containskey(DetailTargetRecordAsKeyValue[k].key))
                                    {
                                        if(DetailFieldMap.get(DetailTargetRecordAsKeyValue[k].key).SVMXC__DataType__c.touppercase() != 'REFERENCE'&& DefaultValue != null && DefaultValue.length() > 0)
                                        {
                                            system.debug('Called Not REFERENCE');
                                            BubbleWrapper.fieldvalue.key = DefaultValue; 
                                            BubbleWrapper.fieldvalue.value = DefaultValue;
                                        }
                                        if(DetailFieldMap.get(DetailTargetRecordAsKeyValue[k].key).SVMXC__DataType__c.touppercase() == 'REFERENCE' && DefaultValue != null && DefaultValue.length() > 0)
                                        {
                                            system.debug('Called REFERENCE');
                                            system.debug('Called REFERENCE'+DetailFieldMap.get(DetailTargetRecordAsKeyValue[k].key).SVMXC__Related_Object_Name__c+DetailFieldMap.get(DetailTargetRecordAsKeyValue[k].key).SVMXC__Related_Object_Name_Field__c);
                                            SVMXC.INTF_WebServicesDef.INTF_StringMap strmap = new SVMXC.INTF_WebServicesDef.INTF_StringMap();
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
                                        if(DefaultValue != null && DefaultValue.length() > 0)
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
                         //Jaysukh BAC - 3234
                            List<INTF_WebServicesDef.INTF_StringMap> objList1 = new List<INTF_WebServicesDef.INTF_StringMap>();
                            INTF_WebServicesDef.INTF_StringMap obj1 = new INTF_WebServicesDef.INTF_StringMap();
                            obj1.key= 'OBJECT_NAME';
                            obj1.value = DetailRecords[i].objName;
                            objList1.add(obj1);
                            TempPageDataSet.objectInfoMap = objList1;
                         //Jaysukh BAC - 3234
                           DetailPageDataSetList.add(TempPageDataSet);
                    }
                }
                DetailDataSet.pageDataSet = DetailPageDataSetList;
                DetailDataSet.aliasName = AliasName;
                system.debug('DetailDataSet'+DetailDataSet);
                DetailDataSetList.add(DetailDataSet);
            }
        }   
        SVMXC.INTF_WebServicesDef.INTF_PageData pagedata = new SVMXC.INTF_WebServicesDef.INTF_PageData();
        pagedata.eventType = sfmtargetrec.eventType;
        pagedata.pageDataSet =  PageDataSet;
        pagedata.detailDataSet = DetailDataSetList; 
        return pagedata;    
    }
}