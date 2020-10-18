global class SFM_ServicesDef
{
	
	//webservice to convert sfmtarget to page data..
	webservice static SVMXC.SFM_WrapperDef.SFM_PageData SFM_BuildPageData_WS(SVMXC.SFM_WrapperDef.SFM_TargetRecord sfmtargetrec)
	{
		SVMXC.SFM_buildPageData buildpagedata = new SVMXC.SFM_buildPageData();
		return buildpagedata.SFM_buildPageData(sfmtargetrec);
	}
	//webservice mathod which will caluculate TO Address With Source object WorkOrder
	webservice static SVMXC.SFM_WrapperDef.SFM_PageData SFM_PORD_SelToAddressWO_WS(SVMXC.SFM_WrapperDef.SFM_TargetRecord sfmtargetrec)
	{
		SVMXC.SFM_PORDAddress Address = new SVMXC.SFM_PORDAddress();
		return Address.getSelToAddressWO(sfmtargetrec); 
	}
	//webservice mathod which will caluculate FROM Address With Source object WorkOrder
	webservice static SVMXC.SFM_WrapperDef.SFM_PageData SFM_PORD_SelFromAddressWO_WS(SVMXC.SFM_WrapperDef.SFM_TargetRecord sfmtargetrec)
	{
		SVMXC.SFM_PORDAddress Address = new SVMXC.SFM_PORDAddress();
		return Address.getSelFromAddressWO(sfmtargetrec); 
	}
	//webservice mathod which will caluculate TO Address With Source object Case
	webservice static SVMXC.SFM_WrapperDef.SFM_PageData SFM_PORD_SelToAddressCASE_WS(SVMXC.SFM_WrapperDef.SFM_TargetRecord sfmtargetrec)
	{
		SVMXC.SFM_PORDAddress Address = new SVMXC.SFM_PORDAddress();
		return Address.getSelToAddressCase(sfmtargetrec); 
	}
	//webservice mathod which will caluculate FROM Address With Source object Case
	webservice static SVMXC.SFM_WrapperDef.SFM_PageData SFM_PORD_SelFromAddressCASE_WS(SVMXC.SFM_WrapperDef.SFM_TargetRecord sfmtargetrec)
	{
		SVMXC.SFM_PORDAddress Address = new SVMXC.SFM_PORDAddress();
		return Address.getSelFromAddressCase(sfmtargetrec); 
	}
	//webservice mathod which will caluculate TO Location
	webservice static SVMXC.SFM_WrapperDef.SFM_PageData SFM_PORD_PopulateToLocation_WS(SVMXC.SFM_WrapperDef.SFM_TargetRecord sfmtargetrec)
	{
		SVMXC.SFM_PORDAddress Address = new SVMXC.SFM_PORDAddress();
		return Address.getPopulateToLocation(sfmtargetrec); 
	}
	//webservice mathod which will caluculate From Location 
	webservice static SVMXC.SFM_WrapperDef.SFM_PageData SFM_PORD_PopulateFromLocation_WS(SVMXC.SFM_WrapperDef.SFM_TargetRecord sfmtargetrec)
	{
		SVMXC.SFM_PORDAddress Address = new SVMXC.SFM_PORDAddress();
		return Address.getPopulateFromLocation(sfmtargetrec); 
	}
	//Webservice method for GetPrice for Parts Order Lines
	webservice static SVMXC.SFM_WrapperDef.SFM_PageData SFM_PORD_GetPrice_WS(SVMXC.SFM_WrapperDef.SFM_TargetRecord sfmtargetrec)
	{
		SVMXC.SFM_getPrice getprice = new SVMXC.SFM_getPrice();
		return getprice.SFM_PORD_GetPrice(sfmtargetrec); 
	}
	//Webservice method for GetPrice for Parts Request Lines
	webservice static SVMXC.SFM_WrapperDef.SFM_PageData SFM_PREQ_GetPrice_WS(SVMXC.SFM_WrapperDef.SFM_TargetRecord sfmtargetrec)
	{
		SVMXC.SFM_getPrice getprice = new SVMXC.SFM_getPrice();
		return getprice.SFM_PREQ_GetPrice(sfmtargetrec); 
	}
	//Webservice method for GetPrice for Work Detail's Request
	webservice static SVMXC.SFM_WrapperDef.SFM_PageData SFM_WORD_REQ_GetPrice_WS(SVMXC.SFM_WrapperDef.SFM_TargetRecord sfmtargetrec)
	{
		SVMXC.SFM_getPrice getprice = new SVMXC.SFM_getPrice();
		return getprice.SFM_WORD_REQ_GetPrice(sfmtargetrec); 
	}
	//Webservice method for GetPrice for Work Detail's Usage
	webservice static SVMXC.SFM_WrapperDef.SFM_PageData SFM_WORD_USG_GetPrice_WS(SVMXC.SFM_WrapperDef.SFM_TargetRecord sfmtargetrec)
	{
		SVMXC.SFM_getPrice getprice = new SVMXC.SFM_getPrice();
		return getprice.SFM_WORD_USG_GetPrice(sfmtargetrec); 
	}
	//Webservice method for GetPrice for Work Detail's Estimate
	webservice static SVMXC.SFM_WrapperDef.SFM_PageData SFM_WORD_EST_GetPrice_WS(SVMXC.SFM_WrapperDef.SFM_TargetRecord sfmtargetrec)
	{
		SVMXC.SFM_getPrice getprice = new SVMXC.SFM_getPrice();
		return getprice.SFM_WORD_EST_GetPrice(sfmtargetrec); 
	}
	//Webservice method for GetPrice for Stock Transfer lines
	webservice static SVMXC.SFM_WrapperDef.SFM_PageData SFM_SXFR_GetPrice_WS(SVMXC.SFM_WrapperDef.SFM_TargetRecord sfmtargetrec)
	{
		SVMXC.SFM_getPrice getprice = new SVMXC.SFM_getPrice();
		return getprice.SFM_SXFR_GetPrice(sfmtargetrec); 
	}
	//Webservice method to populate Name field from Serial number for IB
	webservice static SVMXC.SFM_WrapperDef.SFM_PageData SFM_IB_PopulateName_WS(SVMXC.SFM_WrapperDef.SFM_TargetRecord sfmtargetrec)
	{
		SVMXC.SFM_IB_PopulateName PN = new SVMXC.SFM_IB_PopulateName();
		return PN.populateName(sfmtargetrec); 
	}
	//Webservice method to set field  SVMXC__Is_Billable__c true for Process Create Usage for workorder
	webservice static SVMXC.SFM_WrapperDef.SFM_PageData SFM_WO_SetIsBillable_WS(SVMXC.SFM_WrapperDef.SFM_TargetRecord sfmtargetrec)
	{
		SVMXC.SFM_WO_SetIsBillable SIB = new SVMXC.SFM_WO_SetIsBillable();
		return SIB.setIsBillable(sfmtargetrec); 
	}
	//Webservice method for Quote calculation (Field Events)
	webservice static SVMXC.SFM_WrapperDef.SFM_PageData SFM_Quote_Calc_WS(SVMXC.SFM_WrapperDef.SFM_TargetRecord sfmtargetrec)
	{
		SVMXC.SFM_Quote_Calc QuoteCal = new SVMXC.SFM_Quote_Calc();
		return QuoteCal.QuoteCalculation(sfmtargetrec); 
	}
	//Global method that return Header Sobject
	global sobject SFM_Page_GetHeaderRecord(SVMXC.SFM_WrapperDef.SFM_TargetRecord sfmtargetrec,map<String,Schema.SObjectType> Allobj)
	{
		SVMXC.SFM_Utils utils = new SVMXC.SFM_Utils();
		return utils.SFM_Page_GetHeaderRecord(sfmtargetrec,Allobj) ;
	}
	//Global method that return Map<AilasName,List<Detail Sobject>>
	global map<String,List<Sobject>> SFM_Page_GetDetailRecords(SVMXC.SFM_WrapperDef.SFM_TargetRecord sfmtargetrec,map<String,Schema.SObjectType> Allobj)
	{
		SVMXC.SFM_Utils utils = new SVMXC.SFM_Utils();
		return utils.SFM_Page_GetDetailRecords(sfmtargetrec,Allobj) ;
	}
	//Global method that return SFM_PageData
	global SVMXC.SFM_WrapperDef.SFM_PageData SFM_Page_BuildResponse(SVMXC.SFM_WrapperDef.SFM_TargetRecord sfmtargetrec,Sobject headerSobject,map<String,List<Sobject>> detailRecordMap)
	{
		SVMXC.SFM_Utils utils = new SVMXC.SFM_Utils();
		return utils.SFM_Page_BuildResponse(sfmtargetrec,headerSobject,detailRecordMap) ;
	} 
}