public with sharing class SFM_Quote_Calc 
{
    
    SVMXC.SFM_BuildSobjectFromKeyValue sobjectfromkevalue = new SVMXC.SFM_BuildSobjectFromKeyValue();
    public map<String, Schema.SObjectType> gd = new Map<String, Schema.SObjectType>(); 
    public map<String,Schema.SObjectType> Allobj = new map<String,Schema.SObjectType>();
    public Decimal QuoteAmount = 0;
    public Decimal QuoteLinePrice = 0;
    public set<String> ErrorMsgList = new set<String>(); 
    public SVMXC__Quote__c QuoteHeader = new SVMXC__Quote__c();
    //Constructor
    public SFM_Quote_Calc()
    {
    	gd = Schema.getGlobalDescribe();
        if(gd.size() > 0)
        {
            for(Schema.SObjectType s : gd.values()) 
            {
                Schema.DescribeSObjectResult result = s.getDescribe();
            	Allobj.put(result.getName(),s);
            }
        }
        
    }
    public SVMXC.SFM_WrapperDef.SFM_PageData QuoteCalculation(SVMXC.SFM_WrapperDef.SFM_TargetRecord sfmtargetrec)
    {
        map<String,map<String,Schema.SObjectField>> AllFieldDescribe = new map<String,map<String,Schema.SObjectField>>();
        SVMXC.SFM_WrapperDef.SFM_TargetRecordObject HdrTargetRecordObject = new SVMXC.SFM_WrapperDef.SFM_TargetRecordObject();//Second member of the SFM_TargetRecord Class
        List<SVMXC.SFM_WrapperDef.SFM_TargetRecordObject> DtlTargetRecordObject = new List<SVMXC.SFM_WrapperDef.SFM_TargetRecordObject>();//Third member of the SFM_TargetRecord Class
        if(sfmtargetrec.headerRecord != null)
            HdrTargetRecordObject = sfmtargetrec.headerRecord;
        if(sfmtargetrec.detailRecords != null)   
            DtlTargetRecordObject = sfmtargetrec.detailRecords;
        system.debug('HdrTargetRecordObject'+HdrTargetRecordObject);
        system.debug('DtlTargetRecordObject'+DtlTargetRecordObject);    
        //Get the Header Sobject 
        String HeaderObjName = '';
        List<SVMXC.SFM_WrapperDef.SFM_Record> HeaderRecord = new List<SVMXC.SFM_WrapperDef.SFM_Record>();
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
            list<SVMXC__Quote__c> lstQuoteHeader = new list<SVMXC__Quote__c>();
			lstQuoteHeader = HeaderSobjMap.values();
			QuoteHeader = lstQuoteHeader[0];
        }
        system.debug('QuoteHeader'+QuoteHeader); 
        map<String,list<SVMXC__Quote_Line__c>> Finalmap = new map<String,list<SVMXC__Quote_Line__c>> ();
        if(DtlTargetRecordObject.size() > 0)
        {
            for(Integer i = 0;i<DtlTargetRecordObject.size();i++)
            {
                if(DtlTargetRecordObject[i].records != null && DtlTargetRecordObject[i].records.size() > 0)
                {
                    List<SVMXC.SFM_WrapperDef.SFM_Record> SfmReocrdlst = new List<SVMXC.SFM_WrapperDef.SFM_Record>(); 
                    SfmReocrdlst = DtlTargetRecordObject[i].records;
                    system.debug('SfmReocrdlst'+SfmReocrdlst);
                    String ObjectName = DtlTargetRecordObject[i].objName;
                    String ParentColumnName = DtlTargetRecordObject[i].parentColumnName;
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
                    if(SfmReocrdlst.size() > 0)
                    {
                        list<SVMXC__Quote_Line__c> QuoteLines = new list<SVMXC__Quote_Line__c>();
                       	map<String,list<Sobject>> DetailSobjMap = new map<String,list<Sobject>>();
                        if(SfmReocrdlst.size() > 0 && ObjectName != null && ObjectName.length() > 0 && ParentColumnName != null && ParentColumnName.length() > 0 ) 
                        {
                            DetailSobjMap = sobjectfromkevalue.BuildSobjectFromKeyValue2(SfmReocrdlst,ObjectName,ParentColumnName,null,AllFieldDescribe);//AllFieldDescribe
                        }
                        list<Sobject> DetailRecords = new list<Sobject>();
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
                        if(DetailRecords.size() > 0)
                        {
                        	for(integer a = 0;a<DetailRecords.size();a++)
                        	{
                        		QuoteLines.add((SVMXC__Quote_Line__c)DetailRecords[a]);
                        	}
                        }
                        Finalmap.put(DtlTargetRecordObject[i].aliasName,QuoteLines);
                    }
                }
            }           
        }
        system.debug('Finalmap'+Finalmap);
        if(IsValidate(Finalmap) == true)
        {
        	OnChangeItems(Finalmap);
        	OnchangeHeader();
        	//Create/update key/value for the Header object
	        list<SVMXC.SFM_WrapperDef.SFM_StringMap> TargetRecordAsKeyValue = new list<SVMXC.SFM_WrapperDef.SFM_StringMap>();
	        if(HdrTargetRecordAsKeyValue.size() > 0 && QuoteHeader != null)
	        {
	            for(Integer i = 0 ;i<HdrTargetRecordAsKeyValue.size();i++)
	            {
	                if(HdrTargetRecordAsKeyValue[i].key != null && HdrTargetRecordAsKeyValue[i].key.length() > 0)//&& HdrTargetRecordAsKeyValue[i].value != null && HdrTargetRecordAsKeyValue[i].value.length() > 0
	                {
	                    SVMXC.SFM_WrapperDef.SFM_StringMap temp = new SVMXC.SFM_WrapperDef.SFM_StringMap();
	                    temp.key = HdrTargetRecordAsKeyValue[i].key;
	                    temp.value = String.valueof(QuoteHeader.get(HdrTargetRecordAsKeyValue[i].key));
	                    if(HdrTargetRecordAsKeyValue[i].value1 != null)
	                    	temp.value1 = HdrTargetRecordAsKeyValue[i].value1;
	                    TargetRecordAsKeyValue.add(temp);
	                }   
	            }
	        }
	        HeaderRecord[0].targetRecordAsKeyValue = null;
	        HeaderRecord[0].targetRecordAsKeyValue = TargetRecordAsKeyValue;
	        //Create/update key/value for the Detail object
	        if(DtlTargetRecordObject.size() > 0)
	        {
	            //map<String,Schema.SObjectField> quoteLinefldmap =  Schema.SObjectType.SVMXC__Quote_Line__c.fields.getMap();
	            for(Integer i = 0;i<DtlTargetRecordObject.size();i++)
	            {   
	                if(DtlTargetRecordObject[i].records != null && DtlTargetRecordObject[i].records.size() > 0)
	                {
	                    List<SVMXC.SFM_WrapperDef.SFM_Record> SfmReocrdlst = new List<SVMXC.SFM_WrapperDef.SFM_Record>(); 
	                    SfmReocrdlst = DtlTargetRecordObject[i].records;
	                    list<SVMXC__Quote_Line__c> NewQuoteLines = new list<SVMXC__Quote_Line__c>(); 
	                    if(Finalmap.containskey(DtlTargetRecordObject[i].aliasName))
	                    	NewQuoteLines = Finalmap.get(DtlTargetRecordObject[i].aliasName);
	                    system.debug('NewQuoteLines'+NewQuoteLines);
	                    if(SfmReocrdlst.size() > 0 )//&& NewQuoteLines.size()>0
	                    {
	                        for(Integer a = 0;a<SfmReocrdlst.size();a++)
	                        {
	                            list<SVMXC.SFM_WrapperDef.SFM_StringMap> DetailTargetRecordAsKeyValue = new list<SVMXC.SFM_WrapperDef.SFM_StringMap>();
	                            list<SVMXC.SFM_WrapperDef.SFM_StringMap> DetailNewTargetRecordAsKeyValue = new list<SVMXC.SFM_WrapperDef.SFM_StringMap>();
	                            DetailTargetRecordAsKeyValue = SfmReocrdlst[a].targetRecordAsKeyValue;
	                            if(DetailTargetRecordAsKeyValue.size() > 0)
	                            {
	                                for(Integer b = 0;b<DetailTargetRecordAsKeyValue.size();b++)
	                                {
	                                    if(DetailTargetRecordAsKeyValue[b].key != null && DetailTargetRecordAsKeyValue[b].key.length() > 0 )//&& DetailTargetRecordAsKeyValue[b].value != null && DetailTargetRecordAsKeyValue[b].value.length() > 0
	                                    {
	                                        SVMXC.SFM_WrapperDef.SFM_StringMap temp = new SVMXC.SFM_WrapperDef.SFM_StringMap();
	                                        temp.key = DetailTargetRecordAsKeyValue[b].key;
	                                        //if(quoteLinefldmap.containskey(DetailTargetRecordAsKeyValue[b].key))
	                                        	temp.value = String.valueof(NewQuoteLines[a].get(DetailTargetRecordAsKeyValue[b].key));
	                                        if(DetailTargetRecordAsKeyValue[b].value1 != null)
	                                        	temp.value1 = DetailTargetRecordAsKeyValue[b].value1;
	                                        system.debug('temp'+temp);
	                                        DetailNewTargetRecordAsKeyValue.add(temp); 
	                                    }
	                                }
	                            }
	                            SfmReocrdlst[a].targetRecordAsKeyValue = null;
	                            SfmReocrdlst[a].targetRecordAsKeyValue = DetailNewTargetRecordAsKeyValue;
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
        else
        {
        	SVMXC.SFM_WrapperDef.SFM_PageData PageData = new SVMXC.SFM_WrapperDef.SFM_PageData();
        	PageData.eventType = sfmtargetrec.eventType;
        	PageData.response.success = false;
        	system.debug('ErrorMsgList'+ErrorMsgList.size()+ErrorMsgList);
        	if(ErrorMsgList.size() > 0)
        	{
        		for(String s : ErrorMsgList)
        		{
        			if(PageData.response.message == null)
        				PageData.response.message = s;
        			else
        				PageData.response.message += ','+s;
        		}
        	}
	        system.debug('PageData'+PageData);
	        return PageData;
        }	
    }
    public void OnChangeItems(map<String,list<SVMXC__Quote_Line__c>> Finalmap)
    {
        QuoteAmount=0;
        QuoteLinePrice=0;
        
        Decimal UnitLinePrice;
        Decimal UnitLineDiscount;
        if(Finalmap.size() > 0)
		{
			for(String s : Finalmap.keyset())
			{
				list<SVMXC__Quote_Line__c> QuoteLines = new list<SVMXC__Quote_Line__c>();
				QuoteLines = Finalmap.get(s);
				if(QuoteLines.size() > 0)
				{
					for(SVMXC__Quote_Line__c q:QuoteLines)
					{
						UnitLineDiscount=0;
						if(q.SVMXC__Quantity2__c != null && q.SVMXC__Unit_Price2__c != null)
						{
							if(q.SVMXC__Discount__c < 0 || q.SVMXC__Discount__c == null)
							{
								system.debug('Enteredddd');
								q.SVMXC__Discount__c = 0;
							}	
							if(q.SVMXC__Quantity2__c < 0)
								q.SVMXC__Quantity2__c = 0;
							if(q.SVMXC__Unit_Price2__c < 0)
								q.SVMXC__Unit_Price2__c = 0;		
							if(q.SVMXC__Discount_Type__c=='Percent')
							{
								if(q.SVMXC__Discount__c!=NULL && q.SVMXC__Unit_Price2__c!=NULL && q.SVMXC__Quantity2__c!=NULL)
									UnitLineDiscount= (q.SVMXC__Quantity2__c * q.SVMXC__Unit_Price2__c) * (q.SVMXC__Discount__c/100);
							}
							else if(q.SVMXC__Discount_Type__c=='Amount')
							{
								//q.SVMXC__Discount__c = q.SVMXC__Discount__c;
								if(q.SVMXC__Discount__c!=NULL)
									UnitLineDiscount = q.SVMXC__Discount__c;
							}
							else if(q.SVMXC__Discount_Type__c == Null)
							{
								q.SVMXC__Discount__c = null;
								UnitLineDiscount = 0;
							}
							if(UnitLineDiscount==NULL)
								UnitLineDiscount=0;
							if(q.SVMXC__Unit_Price2__c!=NULL && q.SVMXC__Quantity2__c!=NULL)
								UnitLinePrice = (q.SVMXC__Quantity2__c * q.SVMXC__Unit_Price2__c) - UnitLineDiscount;
							else
								UnitLinePrice=0;
							String UnitPriceStr = String.valueof(UnitLinePrice);
							system.debug('UnitPriceStr'+UnitPriceStr);
							if(UnitPriceStr.contains('.'))
							{
								list<String> strlst = new list<String>();
								UnitPriceStr = UnitPriceStr.replace('.','~');
								strlst = UnitPriceStr.split('~');
								system.debug('strlst'+strlst);
								if(strlst[1].length() > 3)
									strlst[1] = strlst[1].substring(0,3);
								q.SVMXC__Line_Price2__c = Decimal.valueof(strlst[0]+'.'+strlst[1]);	
							}
							else
							{	
								q.SVMXC__Line_Price2__c = Decimal.valueof(UnitPriceStr);
							}	
							system.debug('UnitLinePrice'+UnitLinePrice);
							QuoteLinePrice = QuoteLinePrice + q.SVMXC__Line_Price2__c;
						}
						system.debug('QuoteLinePrice'+QuoteLinePrice);
					}
				}
				Finalmap.put(s,QuoteLines);
			}
			system.debug('Finalmap'+Finalmap);	
		}        
    }   
    public void OnchangeHeader()
    {
        Decimal UnitLineDiscount=0;
        if(QuoteHeader.SVMXC__Discount__c < 0 || QuoteHeader.SVMXC__Discount__c == null)
        	QuoteHeader.SVMXC__Discount__c = 0;
        if(QuoteHeader.SVMXC__Discount_Type__c=='Percent')
        {
            if(QuoteHeader.SVMXC__Discount__c!=NULL && QuoteHeader.Total_Line_Price2__c!=NULL)
                UnitLineDiscount= (QuoteHeader.Total_Line_Price2__c) * (QuoteHeader.SVMXC__Discount__c/100);
        }
        else if(QuoteHeader.SVMXC__Discount_Type__c=='Amount')
        {
            if(QuoteHeader.SVMXC__Discount__c!=NULL)
                UnitLineDiscount= QuoteHeader.SVMXC__Discount__c;
        }
        else if(QuoteHeader.SVMXC__Discount_Type__c==NULL)
        {
            UnitLineDiscount= 0;
            QuoteHeader.SVMXC__Discount__c = null;
        } 
        QuoteAmount = QuoteLinePrice - UnitLineDiscount;
        system.debug('QuoteLinePrice'+QuoteLinePrice);
        system.debug('UnitLineDiscount'+UnitLineDiscount);
        system.debug('QuoteAmount'+QuoteAmount);
        String QuoteLinePriceStr = String.valueof(QuoteLinePrice);
        String QuoteAmountStr = String.valueof(QuoteAmount);
        system.debug('QuoteLinePriceStr'+QuoteLinePriceStr);
        system.debug('QuoteAmountStr'+QuoteAmountStr);
		if(QuoteLinePriceStr.contains('.'))
		{
			list<String> strlst = new list<String>();
			QuoteLinePriceStr = QuoteLinePriceStr.replace('.','~');
			strlst = QuoteLinePriceStr.split('~');
			system.debug('strlst'+strlst);
			if(strlst[1].length() > 3)
				strlst[1] = strlst[1].substring(0,3);
			QuoteHeader.SVMXC__Total_Line_Price2__c = Decimal.valueof(strlst[0]+'.'+strlst[1]);	
		}
		else
		{	
			QuoteHeader.SVMXC__Total_Line_Price2__c = Decimal.valueof(QuoteLinePriceStr);
		}
		if(QuoteAmountStr.contains('.'))
		{
			list<String> strlst = new list<String>();
			QuoteAmountStr = QuoteAmountStr.replace('.','~');
			strlst = QuoteAmountStr.split('~');
			system.debug('strlst'+strlst);
			if(strlst[1].length() > 3)
				strlst[1] = strlst[1].substring(0,3);
			QuoteHeader.SVMXC__Quote_Amount2__c = Decimal.valueof(strlst[0]+'.'+strlst[1]);	
		}
		else
		{	
			QuoteHeader.SVMXC__Quote_Amount2__c = Decimal.valueof(QuoteAmountStr);
		}	
    }
    //Validation method....
    public Boolean IsValidate(map<String,list<SVMXC__Quote_Line__c>> Finalmap)
    {
    	Boolean Isvalidate = true;
    	if(Finalmap.size() > 0)
    	{
    		for(String s : Finalmap.keyset())
			{
				list<SVMXC__Quote_Line__c> QuoteLines = new list<SVMXC__Quote_Line__c>();
				QuoteLines = Finalmap.get(s);
				if(QuoteLines.size() > 0)
        		{
			    	for(SVMXC__Quote_Line__c q:QuoteLines)
			        {
			    	 	if(q.SVMXC__Quantity2__c != null && q.SVMXC__Unit_Price2__c != null)
			         	{
			         		if(q.SVMXC__Discount_Type__c=='Percent' && q.SVMXC__Discount__c > 100)
			                {
			                	system.debug('1111111111111111111111');
			                	if(ErrorMsgList.contains(system.label.SFM002_TAG036) == false)
			                		ErrorMsgList.add(system.label.SFM002_TAG036);
			                	Isvalidate = false;
			        		}
			                if(q.SVMXC__Unit_Price2__c != null && q.SVMXC__Quantity2__c != null && q.SVMXC__Discount__c != null)
			                {
			                    if( q.SVMXC__Discount_Type__c == 'Amount' && q.SVMXC__Unit_Price2__c *q.SVMXC__Quantity2__c  < q.SVMXC__Discount__c)
			                    {
			                    	system.debug('1111111111111111111111');
			                		if(ErrorMsgList.contains(system.label.SFM002_TAG037) == false)
			                			ErrorMsgList.add(system.label.SFM002_TAG037);
			                		Isvalidate = false;
			                    }
			                }
			         	}
			        }
        		}
			}	
    	}
    	/*if(QuoteHeader.SVMXC__Valid_Until__c!=NULL)
        {
            integer numberDaysDue = QuoteHeader.SVMXC__Valid_Until__c.daysBetween(date.today());
            if(numberDaysDue>0)
            {		
            		if(ErrorMsgList.contains(system.label.SFM002_TAG052) == false)
        				ErrorMsgList.add(system.label.SFM002_TAG052);
    				Isvalidate = false;
            }
        }*/
    	if(QuoteHeader.SVMXC__Discount_Type__c=='Percent' && QuoteHeader.SVMXC__Discount__c > 100)
    	{
            system.debug('1111111111111111111111');
        	if(ErrorMsgList.contains(system.label.SFM002_TAG036) == false)
        		ErrorMsgList.add(system.label.SFM002_TAG036);
        	Isvalidate = false;
    	}
    	if(QuoteHeader.SVMXC__Total_Line_Price2__c != null || QuoteHeader.SVMXC__Discount__c != null)
    	{
            if(QuoteHeader.SVMXC__Discount_Type__c == 'Amount' && QuoteHeader.SVMXC__Total_Line_Price2__c <= QuoteHeader.SVMXC__Discount__c)
            {
            	system.debug('1111111111111111111111');
        		if(ErrorMsgList.contains(system.label.SFM002_TAG037) == false)
        			ErrorMsgList.add(system.label.SFM002_TAG037);
        		Isvalidate = false;
            }
    	}
    	return Isvalidate; 			
    }
}