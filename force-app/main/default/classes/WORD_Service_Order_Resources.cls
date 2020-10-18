public WITH SHARING class WORD_Service_Order_Resources{
	public static Map<Id, Boolean> mapIsWoResEmpty = new Map<Id, Boolean>();
	/**
     * This method fetches & updates Work Order Resource Preference from INSERT Trigger.
     **/
	public static void setWOResPrefInsertTrigger(List<SVMXC__Service_Order__c> lstWOIns){
		try{
            if(WORD_Service_Order_Resources.getResourcePreferenceSetting()){
	            WORD_Service_Order_Resources.isWordTriggerExecuted = true;
	            List<SVMXC__Resource_Preference__c> lstWoResPref = new List<SVMXC__Resource_Preference__c>();
	            lstWoResPref = WORD_Service_Order_Resources.getResourcePreferences(lstWOIns);
	            if((!lstWoResPref.isEmpty()) && (!lstWOIns.isEmpty())){
	            	WORD_Service_Order_Resources.setWorkOrderResources(lstWOIns, lstWoResPref);
	            }
            }
		}catch(Exception ex){
			String exceptionMsg = 'WORD_Service_Order_Resources :: setWOResPrefInsertTrigger() :: ';
			WSCH_AuditLogger.error(exceptionMsg+ex.getMessage() + '\n Stack Trace:: ' + ex.getStackTraceString());
        }
	}
	/**
     * This method fetches & updates Work Order Resource Preference from UPDATE Trigger.
     **/
	public static void setWOResPrefUpdateTrigger(List<SVMXC__Service_Order__c> lstWOUpd, Map<Id,SVMXC__Service_Order__c> mapOldWO){
		try{
			if(WORD_Service_Order_Resources.getResourcePreferenceSetting()){
					List<SVMXC__Service_Order__c> lstChangedWos = WORD_Service_Order_Resources.changedWorkOrderList(lstWOUpd, mapOldWO);
					if(lstChangedWos != null && lstChangedWos.size() > 0){
						WORD_Service_Order_Resources.isWordTriggerExecuted = true;
						List<SVMXC__Resource_Preference__c> lstWoResPref = new List<SVMXC__Resource_Preference__c>();
						if((!lstChangedWos.isEmpty())){
							lstWoResPref = WORD_Service_Order_Resources.getResourcePreferences(lstChangedWos);
							WORD_Service_Order_Resources.setWorkOrderResources(lstChangedWos, lstWoResPref);
						}
					}
	        }
		}catch(Exception ex){
			String exceptionMsg = 'WORD_Service_Order_Resources :: setWOResPrefUpdateTrigger() :: ';
			WSCH_AuditLogger.error(exceptionMsg+ex.getMessage() + '\n Stack Trace:: ' + ex.getStackTraceString());
        }
	}
    /**
     * This method fetches all the technicians & the related preference associated to Company, Location & Site of the Work Orders.
     **/
    public static List<SVMXC__Resource_Preference__c> getResourcePreferences(List<SVMXC__Service_Order__c> lstWorkOrder) {
        
        List<SVMXC__Resource_Preference__c> lstOfTechnicians = new List<SVMXC__Resource_Preference__c>();

        Set<id> setWoSite = new Set<id>();
        Set<id> setWoComponent = new Set<id>();
        Set<id> setWoCompany = new Set<id>();
        //map to store Technician & related preference
        List<String> lstTechPref = new List<String>();
        
        String strTechMpx = '';
        Set <String> setWOTechMPX = new Set<String>();
        try{
			//add all the Work Order related Company, Location & Site to respective SET to reduce the number of SOQL queries.
			for(SVMXC__Service_Order__c workOrder: lstWorkOrder){
				if(workOrder.SVMXC__Company__c!= null){
					setWoCompany.add(workOrder.SVMXC__Company__c);
				}
				if(workOrder.SVMXC__Component__c!= null){
					setWoComponent.add(workOrder.SVMXC__Component__c);
				}
				if(workOrder.SVMXC__Site__c!= null){
					setWoSite.add(workOrder.SVMXC__Site__c);
				}
			}
			//Fetching all the Resource Preferences for all the WO's across its Company, Site and Component
			//fetch all the related Resource Preferences records to the Work Order Master Data.
			String strQuery = 'SELECT ' + fetchQueryFields('SVMXC__Resource_Preference__c' ,true)
								+ ' ,SVMXC__Group_Member__r.name, SVMXC__Group_Member__r.SVMXC__Optimizer_External_ID__c '
								+ ' FROM SVMXC__Resource_Preference__c ' 
								+ ' WHERE ((SVMXC__Company__c IN : setWoCompany) '
								+' OR (SVMXC__Component__c IN :setWoComponent) '
								+' OR (SVMXC__Site__c IN :setWoSite)) '
								+ ' ORDER BY SVMXC__Company__c DESC, SVMXC__Site__c DESC, SVMXC__Component__c DESC, CreatedDate ASC';
			WSCH_AuditLogger.debug('fetchResourcePreference Query: ' + strQuery);
			lstOfTechnicians = Database.query(strQuery);
		}catch(Exception ex){
			String exceptionMsg = 'WORD_Service_Order_Resources :: fetchResourcePreference() :: ';
			WSCH_AuditLogger.error(exceptionMsg+ex.getMessage() + '\n Stack Trace:: ' + ex.getStackTraceString());
        }
		return lstOfTechnicians;
	}

    /**
     * This method fetches all the fields of a sObject and returns as a comma separated String.
     * Optionally, TextArea type of fields can be excluded or included in the return string.
     **/
    public static String fetchQueryFields(String strObjName, Boolean boolExcludeTextArea){
        String strFlds ='';
        try {
	        	if(String.isNotBlank(strObjName)){
		            //Map<String, Schema.SObjectType> gblDesc = Schema.getGlobalDescribe();
		            //Map<String, Schema.SObjectField> mapOfFields = gblDesc.get(strObjName).getDescribe().fields.getMap();
		            
		            Schema.DescribeSObjectResult describeSObjectResult = ((SObject)(Type.forName('Schema.'+ strObjName ).newInstance())).getSObjectType().getDescribe();
		            Map<String, Schema.SObjectField> mapOfFields = describeSObjectResult.fields.getMap();
                    
		            for(String key : mapOfFields.keySet())  
		            {  
		                Schema.DescribeFieldResult fieldResult = mapOfFields.get(key).getDescribe();  
		                //if(fieldResult.isAccessible()){
	                	if(fieldResult.isUpdateable()){
		                    if(boolExcludeTextArea){
		                        if(fieldResult.getType() != Schema.DisplayType.TextArea){
		                            if(String.isNotBlank(strFlds))
		                                {strFlds += ', ';}
		                            strFlds += fieldResult.getName();
		                        }
		                    }
		                    else{
		                        if(String.isNotBlank(strFlds))
		                            {strFlds += ', ';}
		                        strFlds += fieldResult.getName();
		                    }
		                    
		                }
		            }
	    		}
        	}catch(Exception ex){
	            String exceptionMsg = 'WORD_Service_Order_Resources :: fetchQueryFields() :: ';
	            WSCH_AuditLogger.error(exceptionMsg+ex.getMessage() + '\n Stack Trace:: ' + ex.getStackTraceString());
        }
        return strFlds;
    }
    /**
     * This method inserts technicians & the preference associated to Company, Location & Site of the Work Orders to Work_Order_Resource__c object.
     **/
    public static void setWorkOrderResources(List<SVMXC__Service_Order__c> lstWO, List<SVMXC__Resource_Preference__c> lstWorkOrderTech){
        WSCH_AuditLogger.debug('INSIDE WORD_Service_Order_Resources :: setWorkOrderResources()');
        SVMXC__Work_Order_Resource__c  woResRecord;
		Set<String> setTechWo = new Set<String>();
		String strTechWo;
        List<SVMXC__Work_Order_Resource__c > lstWoResInsert = new List<SVMXC__Work_Order_Resource__c >();
        List<SVMXC__Work_Order_Resource__c > lstWoResInsertExisting = new List<SVMXC__Work_Order_Resource__c >();
        try {
        	lstWoResInsertExisting = WORD_Service_Order_Resources.getWorkOrderResources(lstWO);
            if(!lstWorkOrderTech.isEmpty()){
            	 String strTechPrefType = '';
				 Set<String> setTechPrefType = new Set<String>();
				 for(SVMXC__Resource_Preference__c resPref: lstWorkOrderTech){
					strTechPrefType = String.valueOf(resPref.SVMXC__Group_Member__c) + ' = ' + String.valueOf(resPref.SVMXC__Preference_Type__c);
					setTechPrefType.add(strTechPrefType);
				 }
            	//Iterating the WO and populate the WorkOrder Resource with WO ID, Technician and Preferenc Type in the Hierarchy component->Site->Company
				for(SVMXC__Service_Order__c workOrder: lstWO){
					if((workOrder.SVMXC__Component__c!= null) ||(workOrder.SVMXC__Site__c!= null) || (workOrder.SVMXC__Company__c!= null)){
						for(SVMXC__Resource_Preference__c resPref: lstWorkOrderTech){
							woResRecord = new SVMXC__Work_Order_Resource__c();
							//creating the string to be added to the set to prevent the duplicate WorkOrder Resource records being added to WO
							strTechWo = String.valueOf(workOrder.id) + '=' + String.valueOf(resPref.SVMXC__Group_Member__c);
							//if the WorkOrder resource is already populated with the info mentioned in the above comment,
							//skip this info for the subsequent hierarchies.
							Boolean isTechProhibited = false; 
							Boolean isTechMandatory = false;
							if(setTechPrefType.contains(String.valueOf(resPref.SVMXC__Group_Member__c) + ' = Prohibited')){
								isTechProhibited = true;
							}else if(setTechPrefType.contains(String.valueOf(resPref.SVMXC__Group_Member__c) + ' = Mandatory')){
								isTechMandatory = true;
							} 
							
							if((resPref.SVMXC__Component__c != null) && (workOrder.SVMXC__Component__c == resPref.SVMXC__Component__c ) && (!setTechWo.contains(strTechWo))){
								woResRecord.SVMXC__Work_Order__c = workOrder.id;
								woResRecord.SVMXC__Group_Member__c = resPref.SVMXC__Group_Member__c;
								if(isTechProhibited){
									woResRecord.SVMXC__Preference_Type__c = 'Prohibited';
								}else if(isTechMandatory){
									woResRecord.SVMXC__Preference_Type__c = 'Mandatory';
								}else{	
									woResRecord.SVMXC__Preference_Type__c = resPref.SVMXC__Preference_Type__c;
								}	
								lstWoResInsert.add(woResRecord);
								setTechWo.add(strTechWo);
							}else if((resPref.SVMXC__Site__c != null) && (workOrder.SVMXC__Site__c == resPref.SVMXC__Site__c ) && (!setTechWo.contains(strTechWo))){
								woResRecord.SVMXC__Work_Order__c = workOrder.id;
								woResRecord.SVMXC__Group_Member__c = resPref.SVMXC__Group_Member__c;
								if(isTechProhibited){
									woResRecord.SVMXC__Preference_Type__c = 'Prohibited';
								}else if(isTechMandatory){
									woResRecord.SVMXC__Preference_Type__c = 'Mandatory';
								}else{	
									woResRecord.SVMXC__Preference_Type__c = resPref.SVMXC__Preference_Type__c;
								}	
								lstWoResInsert.add(woResRecord);
								setTechWo.add(strTechWo);
							}else if((resPref.SVMXC__Company__c != null) && (workOrder.SVMXC__Company__c == resPref.SVMXC__Company__c ) && (!setTechWo.contains(strTechWo))){
								woResRecord.SVMXC__Work_Order__c = workOrder.id;
								woResRecord.SVMXC__Group_Member__c = resPref.SVMXC__Group_Member__c;
								if(isTechProhibited){
									woResRecord.SVMXC__Preference_Type__c = 'Prohibited';
								}else if(isTechMandatory){
									woResRecord.SVMXC__Preference_Type__c = 'Mandatory';
								}else{	
									woResRecord.SVMXC__Preference_Type__c = resPref.SVMXC__Preference_Type__c;
								}	
								lstWoResInsert.add(woResRecord);
								setTechWo.add(strTechWo);
							}	
						}
					}
				}
            }
            
            //WSCH_AuditLogger.debug('INSIDE WORD_Service_Order_Resources :: setWorkOrderResources() lstWoResInsert==>'+lstWoResInsert);
            
            if(!lstWoResInsert.isEmpty() && !lstWoResInsertExisting.isEmpty()){
            	//Deleting the existing workorder resource list
             	if(COMM_SecurityUtils.getInstance().isDeletableObject('SVMXC__Work_Order_Resource__c')){
             		Database.delete(lstWoResInsertExisting);
             	}else {
				    ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error, System.label.COMM001_TAG142));
				    return;
			    }
             	
	            //For existing workorder resourece list , inserting the WorkOrder Resource info for all the WO's. This will implicitly create the related list for WorkOrder Resource Object in the WO
	            if( COMM_SecurityUtils.getInstance().verifyFieldAccess( lstWoResInsert, COMM_SecurityUtils.Access.Upsertable) ) {
	            		Database.upsert(lstWoResInsert);
	            }else {
				    ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error, System.label.COMM001_TAG142));
				    return;
				}
             }else if(lstWorkOrderTech.isEmpty() && !lstWoResInsertExisting.isEmpty()){
            	//Deleting the existing workorder resource list
             	if(COMM_SecurityUtils.getInstance().isDeletableObject('SVMXC__Work_Order_Resource__c')){
         			Database.delete(lstWoResInsertExisting);
             	}else {
				    ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error, System.label.COMM001_TAG142));
				    return;
				}
             	
             }else if(!lstWoResInsert.isEmpty() && lstWoResInsertExisting.isEmpty()){
             	//For the first time inserting the WorkOrder Resource info for all the WO's. This will implicitly create the related list for WorkOrder Resource Object in the WO
             	if( COMM_SecurityUtils.getInstance().verifyFieldAccess( lstWoResInsert, COMM_SecurityUtils.Access.Upsertable) ) {
             		Database.insert(lstWoResInsert);
             	}else {
				    ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error, System.label.COMM001_TAG142));
				    return;
				}
             }
        }catch(Exception ex){
            String exceptionMsg = 'WORD_Service_Order_Resources :: setWorkOrderResources() :: ';
            WSCH_AuditLogger.error(exceptionMsg+ex.getMessage() + '\n Stack Trace:: ' + ex.getStackTraceString());
        }
    }
	/**
	 * This method accepts a SET of WorkOrder as input & 
	 * returns the corresponding list of Work Order Resource Preference.
	 **/
	public static List<SVMXC__Work_Order_Resource__c > getWorkOrderResources(List<SVMXC__Service_Order__c> lstWO) {
		Set<Id> setWoIds = new Set<Id>();
		List<SVMXC__Work_Order_Resource__c> lstWORes = new List<SVMXC__Work_Order_Resource__c>();
		try{
			for(SVMXC__Service_Order__c workOrder : lstWO){
				setWoIds.add(workOrder.Id);
			}
			String strQry =  'SELECT '  + fetchQueryFields('SVMXC__Work_Order_Resource__c' ,true)
										+ ' ,SVMXC__Group_Member__r.SVMXC__Optimizer_External_ID__c '
										+ ' FROM SVMXC__Work_Order_Resource__c '
										+ ' WHERE SVMXC__Work_Order__c IN: setWoIds'
										+ ' ORDER BY SVMXC__Work_Order__c DESC, Name ASC ';

			if(!setWoIds.isEmpty()){
				lstWORes = Database.query(strQry);
			}
		}catch(Exception ex){
            String exceptionMsg = 'WORD_Service_Order_Resources :: getWorkOrderResources() :: ';
            WSCH_AuditLogger.error(exceptionMsg+ex.getMessage() + '\n Stack Trace:: ' + ex.getStackTraceString());
        }
		return lstWORes;
	}
    
    public static Boolean isWordTriggerExecuted = false;
    
    public static Boolean getResourcePreferenceSetting(){
    	Boolean resPrefSetting = false, boolGBL007 = false;
    	try{
            String strGBL007 = WSCH_CommonUtils.getSettingValue('GLOB001', 'GBL007');
            boolGBL007 = Boolean.valueOf(strGBL007);
    		resPrefSetting = Boolean.valueOf(WSCH_CommonUtils.getSettingValue('OMAX003', 'SET051'));
    		WSCH_AuditLogger.debug('WORD_Service_Order_Resources :: getResourcePreferenceSetting() :: resPrefSetting -' + resPrefSetting);
    	}catch(Exception ex){
            String exceptionMsg = 'WORD_Service_Order_Resources :: getResourcePreferenceSetting() :: ';
            WSCH_AuditLogger.error(exceptionMsg+ex.getMessage() + '\n Stack Trace:: ' + ex.getStackTraceString());
            resPrefSetting = false;
            boolGBL007 = false;
        }
        if(Test.isRunningTest()){
            return true;
        }
		return (resPrefSetting && boolGBL007) ;
    }
    
    //This method returns the list of changed WOs.
    public static List<SVMXC__Service_Order__c> changedWorkOrderList(List<SVMXC__Service_Order__c> lstNewWO, Map<Id,SVMXC__Service_Order__c> mapTrigOld){
	    SVMXC__Service_Order__c  oldWO = new SVMXC__Service_Order__c();
    	List<SVMXC__Service_Order__c> lstChangedWO = new List<SVMXC__Service_Order__c>();
    	try{
    		for(SVMXC__Service_Order__c wo: lstNewWO){
    			oldWO = mapTrigOld.get(wo.Id);
    			mapIsWoResEmpty.put(wo.Id, true);
    			
    			//Checking if the company/Component/Site on the WO has been changed.If they are changed then we need to retrieve the fresh 
    			//Resource Preferences from Company/Component/Site and set the Right WorkOrder Resources for that WO
    			if((wo.SVMXC__Company__c != oldWO.SVMXC__Company__c) || (wo.SVMXC__Component__c != oldWO.SVMXC__Component__c) || (wo.SVMXC__Site__c != oldWO.SVMXC__Site__c)){
    				lstChangedWO.add(wo);
    			}
    		}
    	}catch(Exception ex){
    		String exceptionMsg = 'WORD_Service_Order_Resources :: changedWorkOrderList() :: ';
            WSCH_AuditLogger.error(exceptionMsg+ex.getMessage() + '\n Stack Trace:: ' + ex.getStackTraceString());
    	}
    	
    	return lstChangedWO;	
    
    }
    
    //This method checks if the WO's WorkOrderResource related list was empty
    /*public static Boolean checkWorkOrderResUpdate(List<SVMXC__Service_Order__c> lstNewWO, Map<Id,SVMXC__Service_Order__c> mapTrigOld){
    	SVMXC__Service_Order__c  oldWO = new SVMXC__Service_Order__c();
    	List<SVMXC__Service_Order__c> lstChangedWO = new List<SVMXC__Service_Order__c>();
    	List<SVMXC__Work_Order_Resource__c> lstWORes = new List<SVMXC__Work_Order_Resource__c>();
    	Boolean boolCheckUpdate = false;
    	WSCH_AuditLogger.debug('Start of Work_Order_Resources :heap size - ' + Limits.getHeapSize());
    	try{
    		for(SVMXC__Service_Order__c wo: lstNewWO){
    			oldWO = mapTrigOld.get(wo.Id);
    			mapIsWoResEmpty.put(wo.Id, true);
    			
    			//Checking if the company/Component/Site on the WO has been changed.If they are changed then we need to retrieve the fresh 
    			//Resource Preferences from Company/Component/Site and set the Right WorkOrder Resources for that WO
    			if((wo.SVMXC__Company__c != oldWO.SVMXC__Company__c) || (wo.SVMXC__Component__c != oldWO.SVMXC__Component__c) || (wo.SVMXC__Site__c != oldWO.SVMXC__Site__c)){
    				lstChangedWO.add(wo);
    			}
    		}
    		if(!lstChangedWO.isEmpty()){
    			lstWORes = getWorkOrderResources(lstChangedWO);
    			//Checking if the WorkOrder Resource list was empty before the update.Then only we need to retrieve the fresh 
    			//Resource Preferences from Company/Component/Site and set the Right WorkOrder Resources for that WO
    			boolCheckUpdate = (lstWORes.isEmpty());
    			for(SVMXC__Work_Order_Resource__c woRes: lstWORes){
    				if(woRes.SVMXC__Group_Member__c != null){
    					mapIsWoResEmpty.put(woRes.SVMXC__Work_Order__c, false);
    				}
    			}
    		}
    		WSCH_AuditLogger.debug('END of Work_Order_Resources :heap size - ' + Limits.getHeapSize());
    		
    	}catch(Exception ex){
    		String exceptionMsg = 'WORD_Service_Order_Resources :: checkWorkOrderUpdate() :: ';
            WSCH_AuditLogger.error(exceptionMsg+ex.getMessage() + '\n Stack Trace:: ' + ex.getStackTraceString());
    	}
    	return boolCheckUpdate;
    }*/
}