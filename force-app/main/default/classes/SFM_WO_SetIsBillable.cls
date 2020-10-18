public with sharing class SFM_WO_SetIsBillable 
{
    //Constructor
    public SFM_WO_SetIsBillable(){}
    
    public SVMXC.SFM_WrapperDef.SFM_PageData setIsBillable(SVMXC.SFM_WrapperDef.SFM_TargetRecord sfmtargetrec)
    {
         String Setting015 = '';
         String Setting016 = '';
         SVMXC.COMM_Utils_ManageSettings settings = new SVMXC.COMM_Utils_ManageSettings();
          SVMXC.SFM_BuildSobjectFromKeyValue sobjectfromkevalue = new SVMXC.SFM_BuildSobjectFromKeyValue();
         Map<String, String> AllSubModuleSettings = settings.SVMX_getSettingList('WORD005');
         if(AllSubModuleSettings.containskey('SET015'))
            Setting015 = AllSubModuleSettings.get('SET015');
         if(AllSubModuleSettings.containskey('SET016')) 
            Setting016 = AllSubModuleSettings.get('SET016');
        system.debug('sfmtargetrec'+sfmtargetrec);
        SVMXC.SFM_WrapperDef.SFM_TargetRecordObject HdrTargetRecordObject = new SVMXC.SFM_WrapperDef.SFM_TargetRecordObject();
        List<SVMXC.SFM_WrapperDef.SFM_TargetRecordObject> DtlTargetRecordObject = new List<SVMXC.SFM_WrapperDef.SFM_TargetRecordObject>();//Third member of the SFM_TargetRecord Class
        if(sfmtargetrec.headerRecord != null)   
            HdrTargetRecordObject = sfmtargetrec.headerRecord;
        if(sfmtargetrec.detailRecords != null)   
            DtlTargetRecordObject = sfmtargetrec.detailRecords;
        system.debug('HdrTargetRecordObject'+HdrTargetRecordObject);   
        system.debug('DtlTargetRecordObject'+DtlTargetRecordObject);   
        String HeaderObjName = '';
        List<SVMXC.SFM_WrapperDef.SFM_Record> HeaderRecord = new List<SVMXC.SFM_WrapperDef.SFM_Record>();
        Sobject HdrSObject;
        //Get the Header SFM Records...
        if(HdrTargetRecordObject.objName != null)
            HeaderObjName = HdrTargetRecordObject.objName;  
        if(HdrTargetRecordObject.records != null && HdrTargetRecordObject.records.size() > 0)
            HeaderRecord = HdrTargetRecordObject.records;
        map<String,Sobject> HeaderSobjMap = new map<String,Sobject>();
        list<SVMXC.SFM_WrapperDef.SFM_StringMap> HdrTargetRecordAsKeyValue = new list<SVMXC.SFM_WrapperDef.SFM_StringMap>();
        if(HeaderRecord.size() > 0)
        {
            if(HeaderRecord[0].targetRecordAsKeyValue != null && HeaderRecord[0].targetRecordAsKeyValue.size() > 0 && HeaderObjName != null && HeaderObjName.length() > 0)
            {
                HdrTargetRecordAsKeyValue = HeaderRecord[0].targetRecordAsKeyValue;
                HeaderSobjMap = sobjectfromkevalue.BuildSobjectFromKeyValue(HeaderRecord[0].targetRecordAsKeyValue,HeaderObjName,null,null);        
            }
        }
        system.debug('HdrTargetRecordAsKeyValue'+HdrTargetRecordAsKeyValue);
        if(HeaderSobjMap.size() > 0)
        {
            HdrSObject = HeaderSobjMap.values();
        }    
        if(DtlTargetRecordObject.size() > 0)
        {
            for(Integer i = 0;i<DtlTargetRecordObject.size();i++)
            {
                if(DtlTargetRecordObject[i].records != null && DtlTargetRecordObject[i].records.size() > 0)
                {
                    List<SVMXC.SFM_WrapperDef.SFM_Record> SfmReocrdlst = new List<SVMXC.SFM_WrapperDef.SFM_Record>(); 
                    SfmReocrdlst = DtlTargetRecordObject[i].records;
                    if(SfmReocrdlst.size() > 0)
                    {
                        for(Integer j = 0;j<SfmReocrdlst.size();j++)
                        {
                            list<SVMXC.SFM_WrapperDef.SFM_StringMap> DetailTargetRecordAsKeyValue = new list<SVMXC.SFM_WrapperDef.SFM_StringMap>();
                            list<SVMXC.SFM_WrapperDef.SFM_StringMap> DetailNewTargetRecordAsKeyValue = new list<SVMXC.SFM_WrapperDef.SFM_StringMap>();
                            DetailTargetRecordAsKeyValue = SfmReocrdlst[j].targetRecordAsKeyValue;
                            if(DetailTargetRecordAsKeyValue.size() > 0)
                            {
                                for(Integer k = 0;k<DetailTargetRecordAsKeyValue.size();k++)
                                {
                                    if(DetailTargetRecordAsKeyValue[k].key != null && DetailTargetRecordAsKeyValue[k].key.length() > 0)//&& DetailTargetRecordAsKeyValue[b].value != null && DetailTargetRecordAsKeyValue[b].value.length() > 0
                                    {
                                        if(DetailTargetRecordAsKeyValue[k].key == 'SVMXC__Is_Billable__c')
                                        {
                                            SVMXC.SFM_WrapperDef.SFM_StringMap temp = new SVMXC.SFM_WrapperDef.SFM_StringMap();
                                            temp.key = DetailTargetRecordAsKeyValue[k].key;
                                            if(Setting015 != null && Setting015.length() > 0 && Setting015.toUpperCase() == 'TRUE')
                                                temp.value = 'true';
                                            else if(Setting015 != null && Setting015.length() > 0 && Setting015.toUpperCase() == 'FALSE')
                                                temp.value = 'false';
                                            else if(Setting015 != null && Setting015.length() > 0 && Setting015.toUpperCase() == 'ENTITLEMENT')
                                            {
                                                if(Setting016 != null && Setting016.length() > 0)
                                                {
                                                    list<String> Stnglist = new list<String>(); 
                                                    Stnglist = Setting016.split(',');
                                                    system.debug('Stnglist'+Stnglist);
                                                    if(Stnglist.size() > 0 && HdrSObject.get('SVMXC__Billing_Type__c') != null)
                                                    {
                                                        String BillingType = String.valueof(HdrSObject.get('SVMXC__Billing_Type__c'));
                                                        system.debug('BillingType'+BillingType);
                                                        temp.value = 'true';
                                                        for(Integer a = 0;a<Stnglist.size();a++)
                                                        {
                                                            if(Stnglist[a].touppercase() == BillingType.touppercase())
                                                            {
                                                                temp.value = 'false';
                                                            }
                                                        }
                                                    }
                                                }
                                            }   
                                            if(DetailTargetRecordAsKeyValue[k].value1 != null)
                                                temp.value1 = DetailTargetRecordAsKeyValue[k].value1;
                                            system.debug('temp'+temp);
                                            DetailNewTargetRecordAsKeyValue.add(temp); 
                                        }
                                        else
                                        {
                                            DetailNewTargetRecordAsKeyValue.add(DetailTargetRecordAsKeyValue[k]);
                                        }       
                                    }
                                }
                                SfmReocrdlst[j].targetRecordAsKeyValue = null;
                                SfmReocrdlst[j].targetRecordAsKeyValue = DetailNewTargetRecordAsKeyValue;
                            }
                            
                        }   
                   }   
                }
            }
        }   
        SVMXC.SFM_WrapperDef.SFM_PageData PageData = new SVMXC.SFM_WrapperDef.SFM_PageData();
        SVMXC.SFM_buildPageData buildpagedata = new SVMXC.SFM_buildPageData();
        system.debug('sfmtargetrec'+sfmtargetrec);
        PageData = buildpagedata.SFM_buildPageData(sfmtargetrec);
        PageData.response.success = true;
        system.debug('PageData'+PageData);
        return PageData;
    }
}