public with sharing class INTF_WO_SetIsBillable 
{
	//Constructor
	public INTF_WO_SetIsBillable(){}
	
	public SVMXC.INTF_WebServicesDef.INTF_PageData setIsBillable(SVMXC.INTF_WebServicesDef.INTF_TargetRecord sfmtargetrec)
	{
		 String Setting015 = '';
		 String Setting016 = '';
		 SVMXC.COMM_Utils_ManageSettings settings = new SVMXC.COMM_Utils_ManageSettings();
		  SVMXC.INTF_BuildSobjectFromKeyValue sobjectfromkevalue = new SVMXC.INTF_BuildSobjectFromKeyValue();
		 Map<String, String> AllSubModuleSettings = settings.SVMX_getSettingList('WORD005');
    	 if(AllSubModuleSettings.containskey('SET015'))
    	 	Setting015 = AllSubModuleSettings.get('SET015');
    	 if(AllSubModuleSettings.containskey('SET016'))	
    	 	Setting016 = AllSubModuleSettings.get('SET016');
		system.debug('sfmtargetrec'+sfmtargetrec);
		SVMXC.INTF_WebServicesDef.INTF_TargetRecordObject HdrTargetRecordObject = new SVMXC.INTF_WebServicesDef.INTF_TargetRecordObject();
		List<SVMXC.INTF_WebServicesDef.INTF_TargetRecordObject> DtlTargetRecordObject = new List<SVMXC.INTF_WebServicesDef.INTF_TargetRecordObject>();//Third member of the INTF_TargetRecord Class
		if(sfmtargetrec.headerRecord != null)   
            HdrTargetRecordObject = sfmtargetrec.headerRecord;
        if(sfmtargetrec.detailRecords != null)   
            DtlTargetRecordObject = sfmtargetrec.detailRecords;
        system.debug('HdrTargetRecordObject'+HdrTargetRecordObject);   
        system.debug('DtlTargetRecordObject'+DtlTargetRecordObject);   
        String HeaderObjName = '';
        List<SVMXC.INTF_WebServicesDef.INTF_Record> HeaderRecord = new List<SVMXC.INTF_WebServicesDef.INTF_Record>();
        Sobject HdrSObject;
        //Get the Header SFM Records...
        if(HdrTargetRecordObject.objName != null)
            HeaderObjName = HdrTargetRecordObject.objName;  
        if(HdrTargetRecordObject.records != null && HdrTargetRecordObject.records.size() > 0)
            HeaderRecord = HdrTargetRecordObject.records;
        map<String,Sobject> HeaderSobjMap = new map<String,Sobject>();
        list<SVMXC.INTF_WebServicesDef.INTF_StringMap> HdrTargetRecordAsKeyValue = new list<SVMXC.INTF_WebServicesDef.INTF_StringMap>();
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
                    List<SVMXC.INTF_WebServicesDef.INTF_Record> SfmReocrdlst = new List<SVMXC.INTF_WebServicesDef.INTF_Record>(); 
                	SfmReocrdlst = DtlTargetRecordObject[i].records;
                	if(SfmReocrdlst.size() > 0)
                	{
                    	for(Integer j = 0;j<SfmReocrdlst.size();j++)
                    	{
                    		list<SVMXC.INTF_WebServicesDef.INTF_StringMap> DetailTargetRecordAsKeyValue = new list<SVMXC.INTF_WebServicesDef.INTF_StringMap>();
                    		list<SVMXC.INTF_WebServicesDef.INTF_StringMap> DetailNewTargetRecordAsKeyValue = new list<SVMXC.INTF_WebServicesDef.INTF_StringMap>();
                        	DetailTargetRecordAsKeyValue = SfmReocrdlst[j].targetRecordAsKeyValue;
                        	if(DetailTargetRecordAsKeyValue.size() > 0)
                        	{
                        		for(Integer k = 0;k<DetailTargetRecordAsKeyValue.size();k++)
                            	{
	                                if(DetailTargetRecordAsKeyValue[k].key != null && DetailTargetRecordAsKeyValue[k].key.length() > 0)//&& DetailTargetRecordAsKeyValue[b].value != null && DetailTargetRecordAsKeyValue[b].value.length() > 0
	                                {
	                                    if(DetailTargetRecordAsKeyValue[k].key == 'SVMXC__Is_Billable__c')
	                                    {
		                                    SVMXC.INTF_WebServicesDef.INTF_StringMap temp = new SVMXC.INTF_WebServicesDef.INTF_StringMap();
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
        SVMXC.INTF_WebServicesDef.INTF_PageData PageData = new SVMXC.INTF_WebServicesDef.INTF_PageData();
        SVMXC.INTF_buildPageData buildpagedata = new SVMXC.INTF_buildPageData();
        system.debug('sfmtargetrec'+sfmtargetrec);
        PageData = buildpagedata.INTF_buildPageData(sfmtargetrec);
        PageData.response.success = true;
        system.debug('PageData'+PageData);
        return PageData;
	}
}