public with sharing class SFM_GetPrice 
{
    
    public map<String, Schema.SObjectType> gd = new Map<String, Schema.SObjectType>(); 
    public map<String,Schema.SObjectType> Allobj = new map<String,Schema.SObjectType>();
    public map<String,String> PrifixMap = new map<String,String>();
    SVMXC.SFM_BuildSobjectFromKeyValue sobjectfromkevalue = new SVMXC.SFM_BuildSobjectFromKeyValue();
    SVMXC.COMM_Utils_ManageSettings settings = new SVMXC.COMM_Utils_ManageSettings();
    //SVMXC.SFM_BuildSobject BuildSobject = new SVMXC.SFM_BuildSobject(); 
    //Constructor
    public SFM_getPrice()
    {
        gd = Schema.getGlobalDescribe();
        if(gd.size() > 0)
        {
            for(Schema.SObjectType s : gd.values()) 
            {
                Schema.DescribeSObjectResult result = s.getDescribe();
            	Allobj.put(result.getName(),s);
            	PrifixMap.put(result.getKeyPrefix(),result.getName());
            }
        }
    }
    //Method to get the Parts Order Lines'Get price method
    public SVMXC.SFM_WrapperDef.SFM_PageData SFM_PORD_GetPrice(SVMXC.SFM_WrapperDef.SFM_TargetRecord sfmtargetrec)
    {
        /*String SourceRecId = '';
        String PrifixId = '';
        String CurrncyIsoCode = '';
        Sobject SourceSobject;
        SVMXC.SFM_WrapperDef.SFM_TargetRecordObject HdrTargetRecordObject = new SVMXC.SFM_WrapperDef.SFM_TargetRecordObject();//Second member of the SFM_TargetRecord Class
        if(sfmtargetrec.headerRecord != null)
            HdrTargetRecordObject = sfmtargetrec.headerRecord;
        system.debug('HdrTargetRecordObject'+HdrTargetRecordObject);
        List<SVMXC.SFM_WrapperDef.SFM_Record> HeaderRecord = new List<SVMXC.SFM_WrapperDef.SFM_Record>();
        //Get the Header SFM Records...
        if(HdrTargetRecordObject.records != null && HdrTargetRecordObject.records.size() > 0)
            HeaderRecord = HdrTargetRecordObject.records;
        if(HeaderRecord.size() > 0 && HeaderRecord[0].sourceRecordId != null)
        	SourceRecId = HeaderRecord[0].sourceRecordId;
        if(SourceRecId != null && SourceRecId.length() > 0)
         	PrifixId = SourceRecId.substring(0,3);
        if(SourceRecId != null && SourceRecId.length() > 0 && PrifixId != null && PrifixId.length() > 0 && PrifixMap.size() > 0 && PrifixMap.containskey(PrifixId))
        {
        	String Query = 'Select id,CurrncyIsoCode from '+PrifixMap.get(PrifixId)+' Where Id = '+SourceRecId;
        	system.debug('Query'+Query);
        	SourceSobject = Database.query(Query);
        	system.debug('SourceSobject'+SourceSobject);
        	if(SourceSobject != null && SourceSobject.get('CurrncyIsoCode') != null)
        		CurrncyIsoCode = String.valueof(SourceSobject.get('CurrncyIsoCode'));
        }
        if(CurrncyIsoCode != null && CurrncyIsoCode.length() > 0)
        	return GetPrice(sfmtargetrec,'PORD002','SET011','SVMXC__Product__c','SVMXC__Use_Price_From_Pricebook__c','SVMXC__Line_Price2__c','CurrencyIsoCode',CurrncyIsoCode);
        else *///(Commented because decided to not implement this CurrncyIsoCode will come from mapping)	
        	return GetPrice(sfmtargetrec,'PORD002','SET011','SVMXC__Product__c','SVMXC__Use_Price_From_Pricebook__c','SVMXC__Line_Price2__c','CurrencyIsoCode',null);
    }
    //Method to get the Parts Request Lines' Get price method
    public SVMXC.SFM_WrapperDef.SFM_PageData SFM_PREQ_GetPrice(SVMXC.SFM_WrapperDef.SFM_TargetRecord sfmtargetrec)
    {
        return GetPrice(sfmtargetrec,'PREQ002','SET003','SVMXC__Product__c','SVMXC__Use_Price_From_Pricebook__c','SVMXC__Unit_Price2__c','CurrencyIsoCode',null);
    }
    //Method to get the Work Detail's Request Get price method
    public SVMXC.SFM_WrapperDef.SFM_PageData SFM_WORD_REQ_GetPrice(SVMXC.SFM_WrapperDef.SFM_TargetRecord sfmtargetrec)
    {
        return GetPrice(sfmtargetrec,'WORD005','SET008','SVMXC__Product__c','SVMXC__Use_Price_From_Pricebook__c','SVMXC__Actual_Price2__c','CurrencyIsoCode',null);
    }
    //Method to get the Work Detail's Usage Get price method
    public SVMXC.SFM_WrapperDef.SFM_PageData SFM_WORD_USG_GetPrice(SVMXC.SFM_WrapperDef.SFM_TargetRecord sfmtargetrec)
    {
        return GetPrice(sfmtargetrec,'WORD005','SET004','SVMXC__Product__c','SVMXC__Use_Price_From_Pricebook__c','SVMXC__Actual_Price2__c','CurrencyIsoCode',null);
    }
    //Method to get the Work Detail's Estimate Get price method
    public SVMXC.SFM_WrapperDef.SFM_PageData SFM_WORD_EST_GetPrice(SVMXC.SFM_WrapperDef.SFM_TargetRecord sfmtargetrec)
    {
        return GetPrice(sfmtargetrec,'WORD005','SET006','SVMXC__Product__c','SVMXC__Use_Price_From_Pricebook__c','SVMXC__Estimated_Price2__c','CurrencyIsoCode',null);
    }
    //Method to get the Stock Transefer Get price method
    public SVMXC.SFM_WrapperDef.SFM_PageData SFM_SXFR_GetPrice(SVMXC.SFM_WrapperDef.SFM_TargetRecord sfmtargetrec)
    {
        return GetPrice(sfmtargetrec,'SXFR002','SET003','SVMXC__Product__c','SVMXC__Use_Price_From_Pricebook__c','SVMXC__Unit_Price2__c','CurrencyIsoCode',null);
    }
    //Internal method wich return the Price
    public SVMXC.SFM_WrapperDef.SFM_PageData GetPrice(SVMXC.SFM_WrapperDef.SFM_TargetRecord sfmtargetrec,String SubmoduleId,String SettingId,String Product,String UsePriceFromPriceBook,String LinePrice,String CurrencyIsoCode,String SourceObjCurrencyIsoCode)
    {
        SVMXC.SFM_WrapperDef.SFM_PageData PageData = new SVMXC.SFM_WrapperDef.SFM_PageData();
        try
        {
	        map<String,map<String,Schema.SObjectField>> AllFieldDescribe = new map<String,map<String,Schema.SObjectField>>();
	        map<String, String> AllSubModuleSettings = new map<String, String>();
	        Pricebook2 priceBook = new Pricebook2();
	        if(SubmoduleId != null && SubmoduleId.length() > 0)
	            AllSubModuleSettings = settings.SVMX_getSettingList(SubmoduleId);
	        if(AllSubModuleSettings.size() > 0 && SettingId != null && SettingId.length() > 0)
	        {
	            String ShipmentPriceBook = AllSubModuleSettings.get(SettingId);
	            priceBook = SVMXC.COMM_PriceClass.SVMXC_GetPricebook(ShipmentPriceBook);
	            if(priceBook == null)
	            {
	            	PageData.response.success = false;
	        		PageData.response.message = system.Label.SFM002_TAG045;
			        return PageData;
	            }     
	        }
	        system.debug('priceBook'+priceBook);   
	        system.debug('sfmtargetrec'+sfmtargetrec);
	        SVMXC.SFM_WrapperDef.SFM_TargetRecordObject HdrTargetRecordObject = new SVMXC.SFM_WrapperDef.SFM_TargetRecordObject();//Second member of the SFM_TargetRecord Class
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
	        if(HdrTargetRecordObject.records.size() > 0)
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
	        if(HeaderSobjMap.size() > 0)
	        {
	            HdrSObject = HeaderSobjMap.values();
	        }
	        system.debug('HdrSObject'+HdrSObject);   
	        //Process Header Object 
	       /* if(Allobj.containskey(HeaderObjName) && HdrSObject != null && AllFieldDescribe.containskey(HeaderObjName) == false)
	        {
	            Map<String,Schema.SObjectField> FieldMap = new Map<String,Schema.SObjectField>();
	            FieldMap = Allobj.get(HeaderObjName).getDescribe().fields.getMap();
	            Map<String,Schema.SObjectField> HeaderFieldMap = new Map<String,Schema.SObjectField>(); 
	            if(FieldMap.size() > 0)
	            {
	                for(String s : FieldMap.keyset())
	                {
	                    HeaderFieldMap.put(FieldMap.get(s).getDescribe().getname(),FieldMap.get(s));
	                }
	                AllFieldDescribe.put(HeaderObjName,HeaderFieldMap);
	            }
	            system.debug('HeaderFieldMap'+HeaderFieldMap);
	            if(AllFieldDescribe.containskey(HeaderObjName))
	            {
	                Map<String,Schema.SObjectField> LocalFieldMap = new Map<String,Schema.SObjectField>();
	                LocalFieldMap = AllFieldDescribe.get(HeaderObjName);
	                if(LocalFieldMap.size() > 0 && LocalFieldMap.containskey(Product) && LocalFieldMap.containskey(UsePriceFromPriceBook) && LocalFieldMap.containskey(LinePrice))
	                {
	                    if(String.valueof(HdrSObject.get(Product)) != null && Boolean.valueof(HdrSObject.get(UsePriceFromPriceBook)) == true)
	                    {
	                        PricebookEntry pbe = new PricebookEntry();
	                        try
	                        {
	                            Id Proid = String.valueof(HdrSObject.get(Product));
	                            if(Userinfo.isMultiCurrencyOrganization() && LocalFieldMap.containskey(CurrencyIsoCode))
	                            {
	                                system.debug('CurrencyIsoCode'+HdrSObject.get(CurrencyIsoCode));
	                            	if(HdrSObject.get(CurrencyIsoCode) != null)
	                            	{
	                            		pbe = SVMXC.COMM_PriceClass.SVMXC_GetPricebookEntry(priceBook, string.valueOf(HdrSObject.get(CurrencyIsoCode)),Proid);
	                            	}
	                            	else
	                            	{
	                            		pbe = SVMXC.COMM_PriceClass.SVMXC_GetPricebookEntry(priceBook, Userinfo.getDefaultCurrency(),Proid); 
	                            	}
	                            }		
	                            else
	                                pbe = SVMXC.COMM_PriceClass.SVMXC_GetPricebookEntry(priceBook, null, Proid);
	                        }
	                        catch(Exception e){}
	                        if (pbe !=null)
	                            HdrSObject.put(LinePrice,pbe.UnitPrice);                             
	                    }
	                }
	            }    
	        }
	        //Create update key/value for the Header object
	        list<SVMXC.SFM_WrapperDef.SFM_StringMap> TargetRecordAsKeyValue = new list<SVMXC.SFM_WrapperDef.SFM_StringMap>();
	        if(HdrTargetRecordAsKeyValue.size() > 0 && HdrSObject != null)
	        {
	            for(Integer i = 0 ;i<HdrTargetRecordAsKeyValue.size();i++)
	            {
	                if(HdrTargetRecordAsKeyValue[i].key != null && HdrTargetRecordAsKeyValue[i].key.length() > 0)//&& HdrTargetRecordAsKeyValue[i].value != null && HdrTargetRecordAsKeyValue[i].value.length() > 0
	                {
	                    SVMXC.SFM_WrapperDef.SFM_StringMap temp = new SVMXC.SFM_WrapperDef.SFM_StringMap();
	                    temp.key = HdrTargetRecordAsKeyValue[i].key;
	                    temp.value = String.valueof(HdrSObject.get(HdrTargetRecordAsKeyValue[i].key));
	                    if(HdrTargetRecordAsKeyValue[i].value1 != null)
	                    	temp.value1 = HdrTargetRecordAsKeyValue[i].value1;
	                    TargetRecordAsKeyValue.add(temp);
	                }   
	            }
	        }
	        HeaderRecord[0].targetRecordAsKeyValue = null;
	        HeaderRecord[0].targetRecordAsKeyValue = TargetRecordAsKeyValue;*/
	        //now process the detail Reocrds..
	        map<Integer,List<SVMXC.SFM_WrapperDef.SFM_Record>> TargetRecMap = new map<Integer,List<SVMXC.SFM_WrapperDef.SFM_Record>>(); 
	        list<String> DetailObjName = new list<String>(); 
	        list<String> AliasNameList = new list<String>();
	        list<String> ParentColumnNameList = new list<String>();
	        if(DtlTargetRecordObject.size() > 0)
	        {
	            for(Integer i = 0;i<DtlTargetRecordObject.size();i++)
	            {
	                if(DtlTargetRecordObject[i].records != null && DtlTargetRecordObject[i].records.size() > 0 && DtlTargetRecordObject[i].objName != null && DtlTargetRecordObject[i].objName.length() > 0  && DtlTargetRecordObject[i].aliasName != null && DtlTargetRecordObject[i].aliasName.length() > 0 && DtlTargetRecordObject[i].parentColumnName != null && DtlTargetRecordObject[i].parentColumnName.length() > 0)
	                {
	                    system.debug('Entered');
	                    TargetRecMap.put(i,DtlTargetRecordObject[i].records);
	                    DetailObjName.add(DtlTargetRecordObject[i].objName);
	                    AliasNameList.add(DtlTargetRecordObject[i].aliasName);
	                    ParentColumnNameList.add(DtlTargetRecordObject[i].parentColumnName);
	                }   
	            }
	        }
	        system.debug('TargetRecMap'+TargetRecMap);
	        system.debug('DetailObjName'+DetailObjName);
	        if(TargetRecMap.size() > 0)
	        {
	            for(Integer i : TargetRecMap.keyset())
	            {
	                List<SVMXC.SFM_WrapperDef.SFM_Record> SfmReocrdlst = new List<SVMXC.SFM_WrapperDef.SFM_Record>(); 
	                SfmReocrdlst = TargetRecMap.get(i);
	                String ObjectName = '';
	                String AliasName = '';
	                String ParentColumnName = '';
	                if(DetailObjName[i] != null && DetailObjName[i].length() > 0)
	                    ObjectName = DetailObjName[i];
	                if(AliasNameList[i] != null && AliasNameList[i].length() > 0)
	                AliasName = AliasNameList[i];
	                if(ParentColumnNameList[i] != null && ParentColumnNameList[i].length() > 0)
	                    ParentColumnName = ParentColumnNameList[i];
	                map<String,Schema.SObjectField> DetailFieldMap = new map<String,Schema.SObjectField>(); 
	                if( ObjectName != null && ObjectName.length() > 0 && Allobj.containskey(ObjectName) && AllFieldDescribe.containskey(ObjectName) == false)
	                {
	                    Map<String,Schema.SObjectField> FieldMap = new Map<String,Schema.SObjectField>();
	                    FieldMap = Allobj.get(ObjectName).getDescribe().fields.getMap();
	                    if(FieldMap.size() > 0)
	                    {
	                        for(String s : FieldMap.keyset())
	                        {
	                            DetailFieldMap.put(FieldMap.get(s).getDescribe().getname(),FieldMap.get(s));
	                        }
	                        AllFieldDescribe.put(ObjectName,DetailFieldMap);
	                    }
	                }
	                system.debug('SfmReocrdlst'+SfmReocrdlst);
	                if(SfmReocrdlst.size() > 0)
	                {
	                    list<Sobject> DetailRecords = new list<Sobject>();
	                    map<String,list<Sobject>> DetailSobjMap = new map<String,list<Sobject>>();
                        if(SfmReocrdlst.size() > 0 && ObjectName != null && ObjectName.length() > 0 && ParentColumnName != null && ParentColumnName.length() > 0 ) 
                        {
                            DetailSobjMap = sobjectfromkevalue.BuildSobjectFromKeyValue2(SfmReocrdlst,ObjectName,ParentColumnName,null,AllFieldDescribe);//AllFieldDescribe
                        }
                        if(DetailSobjMap.size() > 0)
                        {
                            for(String s : DetailSobjMap.keyset())
                            {
                                if(s.touppercase() == 'INSERT')
                                {
                                    DetailRecords.addall(DetailSobjMap.get(s)); 
                                }
                                if(s.touppercase() == 'UPDATE')
                                {
                                    DetailRecords.addall(DetailSobjMap.get(s));
                                }
                            }
                        }
                        system.debug('DetailRecords'+DetailRecords);
	                    if(DetailRecords.size() > 0 && AllFieldDescribe.containskey(ObjectName))
	                    {
	                        Map<String,Schema.SObjectField> LocalFieldMap = new Map<String,Schema.SObjectField>();
	                        LocalFieldMap = AllFieldDescribe.get(ObjectName);
	                        Set<String> setProductId = new Set<String>(); 
	                        for(Integer k = 0;k<DetailRecords.size();k++)
	                        {
	                            if(LocalFieldMap.size() > 0 && LocalFieldMap.containskey(Product) && LocalFieldMap.containskey(UsePriceFromPriceBook) && LocalFieldMap.containskey(LinePrice))
	                            {
	                               system.debug('Enterddddddd1'+DetailRecords[k].get(Product)+DetailRecords[k].get(UsePriceFromPriceBook));
	                                if(String.valueof(DetailRecords[k].get(Product)) != null && String.valueof(DetailRecords[k].get(Product)).length() > 0 && String.valueof((DetailRecords[k].get(UsePriceFromPriceBook))).toUpperCase() == 'TRUE')
	                                {
	                                    system.debug('Enterddddddd1');
	                                    setProductId.add(String.valueof(DetailRecords[k].get(Product)));
	                                }
	                            } 
	                        }
	                        system.debug('setProductId'+setProductId);
	                        map<String,PricebookEntry> ProductIDPriceBookMap = new map<String,PricebookEntry>(); 
	                        if(setProductId.size() > 0 ) 
	                        {
	                        	if(Userinfo.isMultiCurrencyOrganization() && LocalFieldMap.containskey(CurrencyIsoCode))
                                {
                                	system.debug('CurrencyIsoCode'+HdrSObject.get(CurrencyIsoCode));
                                	if(SourceObjCurrencyIsoCode == null)
                                	{
                                		if(HdrSObject.get(CurrencyIsoCode) != null)
                                		{
                                			ProductIDPriceBookMap = GetUntiPriceFromPricebook(priceBook, string.valueOf(HdrSObject.get(CurrencyIsoCode)),setProductId);
                                		}
                                		else
                                		{
                                			ProductIDPriceBookMap = GetUntiPriceFromPricebook(priceBook, Userinfo.getDefaultCurrency(),setProductId); 
                                		}
                                	}
                                	else
                                	{
                                		ProductIDPriceBookMap = GetUntiPriceFromPricebook(priceBook,SourceObjCurrencyIsoCode,setProductId);
                                	}		
                                }
                                else
                                    ProductIDPriceBookMap = GetUntiPriceFromPricebook(priceBook, null, setProductId);
	                        }
	                        map<String,String> DetailMap = new map<String,String>();          
	                        if(ProductIDPriceBookMap.size() > 0) 
	                        {
	                        	for(Integer k = 0; k< DetailRecords.size();k++)
	                        	{  
	                        		if(DetailRecords[k].get(Product) != null && ProductIDPriceBookMap.containskey(String.valueof(DetailRecords[k].get(Product))) && Boolean.valueof(DetailRecords[k].get(UsePriceFromPriceBook)) == true)
	                        		{ 
	                        			DetailRecords[k].put(LinePrice,ProductIDPriceBookMap.get(String.valueof(DetailRecords[k].get(Product))).UnitPrice);
	                        			DetailMap.put(String.valueof(DetailRecords[k].get(Product)),String.valueof(ProductIDPriceBookMap.get(String.valueof(DetailRecords[k].get(Product))).UnitPrice));
	                        		}	
	                        	}
	                        } 
	                        system.debug('DetailRecords'+DetailRecords);
	                        system.debug('DetailMap'+DetailMap);
	                    	for(Integer a = 0;a<SfmReocrdlst.size();a++)
		                    {
		                        list<SVMXC.SFM_WrapperDef.SFM_StringMap> DetailTargetRecordAsKeyValue = new list<SVMXC.SFM_WrapperDef.SFM_StringMap>();
		                        DetailTargetRecordAsKeyValue = SfmReocrdlst[a].targetRecordAsKeyValue;
		                        if(DetailTargetRecordAsKeyValue.size() > 0)
	                        	{
		                            Boolean ISPriceBookTrue = false;
		                            String prod = '';
		                            for(Integer c = 0;c<DetailTargetRecordAsKeyValue.size();c++)
		                            {
		                                if(DetailTargetRecordAsKeyValue[c].key != null && DetailTargetRecordAsKeyValue[c].key.length() > 0 && DetailTargetRecordAsKeyValue[c].key == UsePriceFromPriceBook && DetailTargetRecordAsKeyValue[c].value.touppercase() == 'TRUE')
		                                	ISPriceBookTrue = true;
		                                if(DetailTargetRecordAsKeyValue[c].key != null && DetailTargetRecordAsKeyValue[c].key.length() > 0 && DetailTargetRecordAsKeyValue[c].key == Product && DetailTargetRecordAsKeyValue[c].value != null)
		                                	prod = DetailTargetRecordAsKeyValue[c].value;
		                            }
		                            for(Integer b = 0;b<DetailTargetRecordAsKeyValue.size();b++)
		                            {
		                            	if(DetailTargetRecordAsKeyValue[b].key != null && DetailTargetRecordAsKeyValue[b].key.length() > 0 && DetailTargetRecordAsKeyValue[b].key == LinePrice && ISPriceBookTrue)
		                            	{
		                            		if(Prod != null && Prod.length() > 0 && DetailMap.containskey(Prod))
		                                    	DetailTargetRecordAsKeyValue[b].value = String.valueof(DetailMap.get(prod));
				                        }
		                            }
	                        	}
	                        	SfmReocrdlst[a].targetRecordAsKeyValue = null;
	                        	SfmReocrdlst[a].targetRecordAsKeyValue = DetailTargetRecordAsKeyValue;
	                    	}
	                	}    
	            	}
	            }
	        }    	         
	        SVMXC.SFM_buildPageData buildpagedata = new SVMXC.SFM_buildPageData();
	        system.debug('sfmtargetrec'+sfmtargetrec);
	        PageData = buildpagedata.SFM_buildPageData(sfmtargetrec);
	        system.debug('PageData'+PageData);
	        PageData.response.success = true;
	        return PageData;
        }
        catch(Exception ex)
        {
        	PageData.response.success = false;
	        PageData.response.message = ex.getmessage();
	        system.debug('PageData'+PageData);
	        return PageData;
        }    
    }
    public map<String,PricebookEntry> GetUntiPriceFromPricebook(Pricebook2 PriceBook , String CurrencyIsoCode, set<String> ProductId)
    { 
		Boolean isMultiCurrency = UserInfo.isMultiCurrencyOrganization();
		if((PriceBook == null) || (ProductId.size() == null)){return null;}
		List<PricebookEntry> pbe2= new List<PricebookEntry>();   
		map<String,PricebookEntry> ProductIDPriceBookMap = new map<String,PricebookEntry>();       
		try 
		{
			string pbe2Query;
			string PBId = PriceBook.Id;
			if(isMultiCurrency)
				pbe2Query='SELECT Name,UnitPrice,IsActive,Product2Id,UseStandardPrice FROM PricebookEntry WHERE Pricebook2Id = :PBId AND CurrencyIsoCode = :CurrencyIsoCode AND Product2Id IN : ProductId AND IsActive = true';
			else
				pbe2Query = 'SELECT Name,UnitPrice,IsActive,Product2Id,UseStandardPrice FROM PricebookEntry WHERE Pricebook2Id = :PBId AND Product2Id IN : ProductId AND IsActive = true';
			
			system.debug('pbe2Query'+pbe2Query);
			pbe2 =database.query(pbe2Query);			
			system.debug('pbe2'+pbe2);
			if(pbe2.size() > 0)
			{
				for(PricebookEntry p : pbe2)
				{
					if(p.isActive == true && p.Product2Id != null && p.UnitPrice != null)
					{
						ProductIDPriceBookMap.put(p.Product2Id,p);
					}
				}
			}
			system.debug('ProductIDPriceBookMap'+ProductIDPriceBookMap);			
			return ProductIDPriceBookMap;
		}	
		catch(System.Exception qe ){
			return null;
		}
	}
}