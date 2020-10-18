/**
 Unit Test class for WSCH_Provider_SP_ErrorCodesMapper
**/

@isTest
public with sharing class WSCH_Provider_SP_ErrorCodesMapper_UT {
	
	public static Map<Integer, String> objErrorCode = new Map<Integer, String>();
	
	public static Map<Integer, String> customErrorCodeMap = new Map<Integer, String>();
	
	static testMethod void testTechnicianEvent() {
		
		Test.startTest();
		
//		Map<Integer,String> mapOfErrorCodes = WSCH_Provider_SP_ErrorCodesMapper.getErrorCodes();
		
		for(Integer i=0;i<objErrorCode.size();i++) {
			objErrorCode.get(i);
		}
		
		for(Integer i=0;i<customErrorCodeMap.size();i++) {
			customErrorCodeMap.get(i);
		}
		
		WSCH_Provider_SP_ErrorCodesMapper errorCodeMapper = new WSCH_Provider_SP_ErrorCodesMapper();
		WSCH_Provider_SP_ErrorCodesMapper.getStatusMsg(2);
		WSCH_Provider_SP_ErrorCodesMapper.getStatusMsg(12, WSCH_Provider_SP_ErrorCodesMapper.OFFER_APPT);
		WSCH_Provider_SP_ErrorCodesMapper.getStatusMsg(0, WSCH_Provider_SP_ErrorCodesMapper.OFFER_APPT);
		WSCH_Provider_SP_ErrorCodesMapper.isSuccess(0);
		
		/*
		 below code has been added to cover more code coverage of Jeopardy changes .
		*/
		WSCH_Provider_SP_ErrorCodesMapper.getViolationMessage('promise');		
		

		Test.stopTest();
	}
	
}