/**
    DataMapper class is used to Map the WorkOrder data into the request the object
    before sending it to the bookJob() call
*/
public with sharing class WSCH_Provider_SP_DataMapper {
    
    /** strNoOfDays stores the setting value for the no. of days to be added to get the end dateTime **/
    public static String strNoOfDays;
    public static List<BusinessHours> lstOfDefaultBussHr;
    public static Map<String, Id> mapOfOptExtIdAndTerritoryId;
    public static Map<Id, SVMXC__Service_Level__c> mapOfServiceLevelIdAndServiceLevelObj;
    public static Map<Id, SVMXC__Service_Contract__c> mapOfServiceContractIdAndServiceContractObj;
    public static Map<Id, SVMXC__Territory__c> mapOfTerritoryIdAndTerritoryObj;
    public static Map<Id, BusinessHours> mapOfBussHrIdAndBussHrObj;
    public static List<BusinessHours> lstOfAllBusinessHours;
    public static List<SVMXC__Service_Order__c> woList = new List<SVMXC__Service_Order__c>();
    
    static {
        WSCH_AuditLogger.debug('WSCH_Provider_SP_DataMapper::Inside static block: Begin');
        initializeSetting();
        initializeDefaultBussHr();
        runSOQLs();
        WSCH_AuditLogger.debug('WSCH_Provider_SP_DataMapper::Inside static block: End');
    }
    
    public static String getServicePowerMPXString(String svmxTechPref){
        Map<String, String> techPref = new Map<String, String>();
        techPref.put('None', 'None');
        techPref.put('Preferred', 'Preferred');
        techPref.put('Mandatory', 'Mandatory'); 
        techPref.put('PreferredOrdered', 'PreferredOrdered');
        techPref.put('PreferredOrdered', 'MandatoryOrdered');
        techPref.put('Prohibited', 'MandatoryNot');

        return techPref.get(svmxtechPref);
    }
    public static void initializeSetting() {
        String strTempNoOfDays = WSCH_CommonUtils.getSettingValue('DCON004','SET012');
        WSCH_AuditLogger.debug('WSCH_Provider_SP_DataMapper::initializeSetting()::initializeSetting()::after setting retrieval: strTempNoOfDays - ' + strTempNoOfDays);
        
        if(strTempNoOfDays != null && String.isNotBlank(strTempNoOfDays)) {
            strNoOfDays = strTempNoOfDays;
            WSCH_AuditLogger.debug('WSCH_Provider_SP_DataMapper::initializeSetting()::initializeSetting()::if setting is existing: strNoOfDays - ' + strNoOfDays);
        } else {
            strNoOfDays = '7';  /* Set 7 as default value if there is not setting value */
            WSCH_AuditLogger.debug('WSCH_Provider_SP_DataMapper::initializeSetting()::if setting is not existing: strNoOfDays - ' + strNoOfDays);
        }
       WSCH_AuditLogger.debug('WSCH_Provider_SP_DataMapper::initializeSetting()::final value: strNoOfDays - ' + strNoOfDays);
    }
    
    /*  Querying the default business hour  */
    public static void initializeDefaultBussHr() {
        WSCH_AuditLogger.debug('WSCH_Provider_SP_DataMapper::initializeDefaultBussHr(): start');
        try{
            lstOfDefaultBussHr = [SELECT Id,IsActive,IsDefault,TimeZoneSidKey,MondayStartTime,MondayEndTime,
                                  TuesdayStartTime,TuesdayEndTime,WednesdayStartTime,WednesdayEndTime,
                                  ThursdayStartTime,ThursdayEndTime,FridayStartTime,FridayEndTime,SaturdayStartTime,
                                  SaturdayEndTime,SundayStartTime,SundayEndTime FROM BusinessHours
                                  WHERE IsDefault = TRUE AND IsActive = TRUE];
            
            WSCH_AuditLogger.debug('WSCH_Provider_SP_DataMapper::initializeDefaultBussHr(): end');
        }catch(Exception ex){
            WSCH_AuditLogger.error('WSCH_Provider_SP_DataMapper :: initializeDefaultBussHr :: ' + ex.getMessage() + '\n Stack Trace:: ' + ex.getStackTraceString());
        }
    }
    
    public static void runSOQLs() {
        WSCH_AuditLogger.debug('WSCH_Provider_SP_DataMapper::runSOQLs(): start');
        try{
            /* creating a map of Optmizer External ID and Territory ID */
            mapOfOptExtIdAndTerritoryId = new Map<String , Id>();
            mapOfTerritoryIdAndTerritoryObj = new Map<Id, SVMXC__Territory__c>();
            List<SVMXC__Territory__c> lstOfTerritories = [SELECT Id,SVMXC__Optimizer_External_ID__c,SVMXC__Territory_s_Business_Hours__c,SVMXC__Optimizer_Connection_Name__c FROM SVMXC__Territory__c WHERE SVMXC__Optimizer_External_ID__c != ''];
            if(lstOfTerritories != null && lstOfTerritories.size() > 0) {
                for(SVMXC__Territory__c eachTerritory : lstOfTerritories) {
                    mapOfOptExtIdAndTerritoryId.put(eachTerritory.SVMXC__Optimizer_External_ID__c, eachTerritory.Id);
                    mapOfTerritoryIdAndTerritoryObj.put(eachTerritory.Id, eachTerritory);
                }
            }
            WSCH_AuditLogger.debug('mapOfOptExtIdAndTerritoryId - ' + mapOfOptExtIdAndTerritoryId);
            WSCH_AuditLogger.debug('mapOfTerritoryIdAndTerritoryObj - ' + mapOfTerritoryIdAndTerritoryObj);
            
            
            /* creating a map of Service Level ID and Service Level Object */
            mapOfServiceLevelIdAndServiceLevelObj = new Map<Id, SVMXC__Service_Level__c>();
            WSCH_AuditLogger.debug('WSCH_Provider_SP_DataMapper::runSOQLs(): setSLAId SIZE- ' + WSCH_Constants.setSLAIds.size());
            List<SVMXC__Service_Level__c> lstOfServiceLevelObj = new List<SVMXC__Service_Level__c>();
            if(!WSCH_Constants.setSLAIds.isEmpty()){
                lstOfServiceLevelObj = [SELECT Id,SVMXC__Business_Hours__c FROM SVMXC__Service_Level__c WHERE Id IN :WSCH_Constants.setSLAIds];
            }
            if(lstOfServiceLevelObj != null && lstOfServiceLevelObj.size() > 0) {
                for(SVMXC__Service_Level__c eachServiceLevelObj : lstOfServiceLevelObj) {
                    mapOfServiceLevelIdAndServiceLevelObj.put(eachServiceLevelObj.Id, eachServiceLevelObj);
                }
            }
            WSCH_AuditLogger.debug('mapOfServiceLevelIdAndServiceLevelObj - ' + mapOfServiceLevelIdAndServiceLevelObj);
            
            /* creating a map of Service Contract ID and Service Contract Object */
            mapOfServiceContractIdAndServiceContractObj = new Map<Id, SVMXC__Service_Contract__c>();
            WSCH_AuditLogger.debug('WSCH_Provider_SP_DataMapper::runSOQLs(): setServiceContracts SIZE - ' + WSCH_Constants.setServiceContractIds.size());
            List<SVMXC__Service_Contract__c> lstOfServiceContractObj = new List<SVMXC__Service_Contract__c>();
            if(!WSCH_Constants.setServiceContractIds.isEmpty()){
                lstOfServiceContractObj = [SELECT Id,SVMXC__Active__c,SVMXC__Business_Hours__c FROM SVMXC__Service_Contract__c WHERE SVMXC__Active__c = true AND Id IN :WSCH_Constants.setServiceContractIds];
            }
            
            if(lstOfServiceContractObj != null && lstOfServiceContractObj.size() > 0) {
                for(SVMXC__Service_Contract__c eachServiceContractObj : lstOfServiceContractObj) {
                    mapOfServiceContractIdAndServiceContractObj.put(eachServiceContractObj.Id, eachServiceContractObj);
                }
            }
            WSCH_AuditLogger.debug('mapOfServiceContractIdAndServiceContractObj - ' + mapOfServiceContractIdAndServiceContractObj);
            
            
            /* creating a map of TerritoryID and Territory Object */
            //mapOfTerritoryIdAndTerritoryObj = new Map<Id, SVMXC__Territory__c>();
            //List<SVMXC__Territory__c> lstOfTerritoryObj = [SELECT Id,SVMXC__Territory_s_Business_Hours__c FROM SVMXC__Territory__c];
            
            /*if(lstOfTerritoryObj != null && lstOfTerritoryObj.size() > 0) {
for(SVMXC__Territory__c eachTerritoryObj : lstOfTerritoryObj) {
mapOfTerritoryIdAndTerritoryObj.put(eachTerritoryObj.Id, eachTerritoryObj);
}
}
WSCH_AuditLogger.debug('mapOfTerritoryIdAndTerritoryObj - ' + mapOfTerritoryIdAndTerritoryObj);*/
            
            /* creating a map of Business Hour ID and Business Hour Object */
            mapOfBussHrIdAndBussHrObj = new Map<Id, BusinessHours>();
            lstOfAllBusinessHours = [SELECT Id,IsActive,IsDefault,TimeZoneSidKey,MondayStartTime,MondayEndTime,
                                     TuesdayStartTime,TuesdayEndTime,WednesdayStartTime,WednesdayEndTime,
                                     ThursdayStartTime,ThursdayEndTime,FridayStartTime,FridayEndTime,SaturdayStartTime,
                                     SaturdayEndTime,SundayStartTime,SundayEndTime FROM BusinessHours
                                     WHERE IsActive = TRUE LIMIT 49999];
            
            if(lstOfAllBusinessHours != null && lstOfAllBusinessHours.size() > 0) {
                for(BusinessHours eachBussHrObj : lstOfAllBusinessHours) {
                    mapOfBussHrIdAndBussHrObj.put(eachBussHrObj.Id, eachBussHrObj);
                }
            }
            WSCH_AuditLogger.debug('mapOfBussHrIdAndBussHrObj - ' + mapOfBussHrIdAndBussHrObj);
            
            WSCH_AuditLogger.debug('WSCH_Provider_SP_DataMapper::runSOQLs(): end');
        }catch(Exception ex){
            WSCH_AuditLogger.error('WSCH_Provider_SP_DataMapper :: runSOQLs :: ' + ex.getMessage() + '\n Stack Trace:: ' + ex.getStackTraceString());
        }
    }
    
    public static WSCH_Provider_SP_StubsV91.JobBookRequest mapBookJobRequest(SVMXC__Service_Order__c workOrder) {
        
        WSCH_AuditLogger.debug('WSCH_Provider_SP_DataMapper::mapBookJobRequest()::Start: No of Queries used in this transaction so far: ' + Limits.getQueries());
        
        WSCH_Provider_SP_StubsV91.JobBookRequest request_x = new WSCH_Provider_SP_StubsV91.JobBookRequest();
        request_x.login = fetchLoginInfo();
        //request_x.login = fetchLoginInfo(workOrder.id);
        
        //String strMapId = getSFMMappingId(WSCH_Constants.API_BOOK_JOB);
        //fetch the SFM Mapping Id as per the Work Order Connection Name
        String strMapId = getSpSFMMappingId(WSCH_Constants.API_BOOK_JOB, WSCH_Provider_SP_RealTimeOptimizer.mapWoConName.get(workOrder.Id));
        map<String,Object> mapfieldvalues = new map<String,Object>();
        if(String.isNotBlank(strMapId)) {
            mapfieldvalues = getSmartObjectRecords(strMapId, workOrder);
            WSCH_AuditLogger.debug('WSCH_Provider_SP_DataMapper::mapBookJobRequest:mapfieldvalues: '+mapfieldvalues);
        }
        
        if(mapfieldvalues != null && mapfieldvalues.size() > 0){
            WSCH_AuditLogger.debug('WSCH_Provider_SP_DataMapper::mapBookJobRequest:Start assignment..');
            
            /*if(mapfieldvalues.get('jobID') != null){
                request_x.jobID = String.valueOf(mapfieldvalues.get('jobID')); 
            }*/

            if(mapfieldvalues.get('jobType') != null){
                request_x.jobType = String.valueOf(mapfieldvalues.get('jobType'));
            }

            if(mapfieldvalues.get('allowRebook') != null){
                request_x.allowRebook = Boolean.valueOf(mapfieldvalues.get('allowRebook'));
            }
            
            if(mapfieldvalues.get('postcode') != null){
                request_x.postcode = String.valueOf(mapfieldvalues.get('postcode'));
            }
            
            if(mapfieldvalues.get('extraDuration')!=null){
                request_x.extraDuration = ''+Integer.valueOf(mapfieldvalues.get('extraDuration'));
            }
            
            if(mapfieldvalues.get('extraOverhead')!=null){
                request_x.extraOverhead = Integer.valueOf(mapfieldvalues.get('extraOverhead'));
            }
            
            if(mapfieldvalues.get('reqUnit.unitType')!=null){
                if(request_x.reqUnit == null){
                    request_x.reqUnit = new WSCH_Provider_SP_StubsV91.ReqUnit();
                }
                request_x.reqUnit.unitType = String.valueOf(mapfieldvalues.get('reqUnit.unitType'));
            }
            
            if(mapfieldvalues.get('reqUnit.RUID')!=null){
                if(request_x.reqUnit == null){
                    request_x.reqUnit = new WSCH_Provider_SP_StubsV91.ReqUnit();
                }
                request_x.reqUnit.RUID = String.valueOf(mapfieldvalues.get('reqUnit.RUID'));
            }
            
            if(mapfieldvalues.get('priority') != null){
                integer priority = Integer.valueOf(mapfieldvalues.get('priority'));
                if(priority < 1) {
                    request_x.priority = String.ValueOf(WSCH_Constants.INT_DEFAULT_PRIORITY);
                } else if (priority > 99) {
                    request_x.priority = String.ValueOf(WSCH_Constants.INT_MAX_PRIORITY);
                } else {
                    request_x.priority = String.ValueOf(priority);
                }               
            }
            
            if(mapfieldvalues.get('importance') != null){
                integer importance = Integer.valueOf(mapfieldvalues.get('importance'));
                request_x.importance= String.valueOf(importance);
            }
            
            if(mapfieldvalues.get('bookLoc') != null){
                request_x.bookLoc = String.valueOf(mapfieldvalues.get('bookLoc'));
            }
            
            if(mapfieldvalues.get('contractEarliest') != null){
                DateTime preferredStart = Datetime.valueOf(mapfieldvalues.get('contractEarliest'));
                request_x.contractEarliest = WSCH_DateUtils.getSPDateTime(preferredStart);
            }
            
            if(mapfieldvalues.get('contractLatest') != null){
                DateTime preferredEnd = Datetime.valueOf(mapfieldvalues.get('contractLatest'));
                request_x.contractLatest = WSCH_DateUtils.getSPDateTime(preferredEnd);
            }
            
            WSCH_Provider_SP_StubsV91.JobBookBookOptions bookOptions = new WSCH_Provider_SP_StubsV91.JobBookBookOptions();
            Boolean isOptionsMapped = false;
            if(mapfieldvalues.get('bookOptions.AllowEmpOT') != null){
                bookOptions.AllowEmpOT = Boolean.valueOf(mapfieldvalues.get('bookOptions.AllowEmpOT'));
                isOptionsMapped = true;
            }
            if(mapfieldvalues.get('bookOptions.SpareIgnVanStock') != null){
                bookOptions.SpareIgnVanStock = Boolean.valueOf(mapfieldvalues.get('bookOptions.SpareIgnVanStock'));
                isOptionsMapped = true;
            }                       
            if(mapfieldvalues.get('bookOptions.FixToEmp') != null){
                bookOptions.FixToEmp = Boolean.valueOf(mapfieldvalues.get('bookOptions.FixToEmp'));
                isOptionsMapped = true;
            }
            if(mapfieldvalues.get('bookOptions.ServAsAccHours') != null){
                bookOptions.ServAsAccHours = Boolean.valueOf(mapfieldvalues.get('bookOptions.ServAsAccHours'));
                isOptionsMapped = true;
            }                       
            if(mapfieldvalues.get('bookOptions.CallToFix') != null){
                bookOptions.CallToFix = Boolean.valueOf(mapfieldvalues.get('bookOptions.CallToFix'));
                isOptionsMapped = true;
            }
            if(mapfieldvalues.get('bookOptions.ReqConfirm') != null){
                bookOptions.ReqConfirm = Boolean.valueOf(mapfieldvalues.get('bookOptions.ReqConfirm'));
                isOptionsMapped = true;
            }                       
            if(mapfieldvalues.get('bookOptions.NonConsecShift') != null){
                bookOptions.NonConsecShift = Boolean.valueOf(mapfieldvalues.get('bookOptions.NonConsecShift'));
                isOptionsMapped = true;
            }
            if(mapfieldvalues.get('bookOptions.ConsecShift') != null){
                bookOptions.ConsecShift = Boolean.valueOf(mapfieldvalues.get('bookOptions.ConsecShift'));
                isOptionsMapped = true;
            }                       
            if(mapfieldvalues.get('bookOptions.ContigShift') != null){
                bookOptions.ContigShift = Boolean.valueOf(mapfieldvalues.get('bookOptions.ContigShift'));
                isOptionsMapped = true;
            }                       
            if(isOptionsMapped)
                request_x.bookOptions = bookOptions;
            
            WSCH_Provider_SP_StubsV91.JobBookForceOptions forceOptions = new WSCH_Provider_SP_StubsV91.JobBookForceOptions();
            Boolean isForceOptionsMapped = false;
            if(mapfieldvalues.get('forceOptions.InTray') != null){
                forceOptions.InTray = Boolean.valueOf(mapfieldvalues.get('forceOptions.InTray'));
                isForceOptionsMapped = true;
            }
            if(mapfieldvalues.get('forceOptions.InTrayWithSkill') != null){
                forceOptions.InTrayWithSkill = Boolean.valueOf(mapfieldvalues.get('forceOptions.InTrayWithSkill'));
                isForceOptionsMapped = true;
            }
            if(mapfieldvalues.get('forceOptions.InTrayAfterAll') != null){
                forceOptions.InTrayAfterAll = Boolean.valueOf(mapfieldvalues.get('forceOptions.InTrayAfterAll'));
                isForceOptionsMapped = true;
            }
            if(mapfieldvalues.get('forceOptions.SpareForceGo') != null){
                forceOptions.SpareForceGo = Boolean.valueOf(mapfieldvalues.get('forceOptions.SpareForceGo'));
                isForceOptionsMapped = true;
            }        
            if(mapfieldvalues.get('forceOptions.Reassign') != null){
                forceOptions.Reassign = Boolean.valueOf(mapfieldvalues.get('forceOptions.Reassign'));
                isForceOptionsMapped = true;
            }
            if(mapfieldvalues.get('forceOptions.IgnoreCapacity') != null){
                forceOptions.IgnoreCapacity = Boolean.valueOf(mapfieldvalues.get('forceOptions.IgnoreCapacity'));
                isForceOptionsMapped = true;
            }
            if(mapfieldvalues.get('forceOptions.NoTravel') != null){
                forceOptions.NoTravel = Boolean.valueOf(mapfieldvalues.get('forceOptions.NoTravel'));
                isForceOptionsMapped = true;
            }
            if(mapfieldvalues.get('forceOptions.NoLocalKnowledge') != null){
                forceOptions.NoLocalKnowledge = Boolean.valueOf(mapfieldvalues.get('forceOptions.NoLocalKnowledge'));
                isForceOptionsMapped = true;
            }  
            if(isForceOptionsMapped)                            
                request_x.forceOptions = forceOptions;
            
            if(mapfieldvalues.get('deliverySize')!=null){
                request_x.deliverySize = Integer.valueOf(mapfieldvalues.get('deliverySize'));
            } 
            
            if(mapfieldvalues.get('pickupSize')!=null){
                request_x.pickupSize = Integer.valueOf(mapfieldvalues.get('pickupSize'));
            }                   
                        
            if(mapfieldvalues.get('siteID')!=null){
                request_x.siteID = String.valueOf(mapfieldvalues.get('siteID'));
            }
            
            if(mapfieldvalues.get('groupID')!=null){
                request_x.groupID = String.valueOf(mapfieldvalues.get('groupID'));
            }

            if(mapfieldvalues.get('capacityCategory')!=null){
                request_x.capacityCategory = String.valueOf(mapfieldvalues.get('capacityCategory'));
            }
            
            //mapping customer
            WSCH_Provider_SP_StubsV91.Customer customer = new WSCH_Provider_SP_StubsV91.Customer();
            Boolean isCustMapped = false;
            if(mapfieldvalues.get('customer.custID')!=null){
                customer.custID = String.valueOf(mapfieldvalues.get('customer.custID'));
                isCustMapped = true;
            }

            if(mapfieldvalues.get('customer.custName')!=null){
                customer.custName = String.valueOf(mapfieldvalues.get('customer.custName'));
                isCustMapped = true;
            }
            
            //mapping for customer address
            List<String> lstCustAddress = new List<String>();
            if(mapfieldvalues.get('customer.custAddress.1')!=null){
                lstCustAddress.add(String.valueOf(mapfieldvalues.get('customer.custAddress.1')));
                isCustMapped = true;
            }
            
            if(mapfieldvalues.get('customer.custAddress.2')!=null){
                lstCustAddress.add(String.valueOf(mapfieldvalues.get('customer.custAddress.2')));
                isCustMapped = true;
            }                               
            
            if(mapfieldvalues.get('customer.custAddress.3')!=null){
                lstCustAddress.add(String.valueOf(mapfieldvalues.get('customer.custAddress.3')));
                isCustMapped = true;
            }
            
            if(mapfieldvalues.get('customer.custAddress.4')!=null){
                lstCustAddress.add(String.valueOf(mapfieldvalues.get('customer.custAddress.4')));
                isCustMapped = true;
            }
            if(lstCustAddress.size() > 0)
                customer.custAddress = lstCustAddress;
                
            //customer contact mapping
            if(mapfieldvalues.get('customer.contactName')!=null){
                customer.contactName = String.valueOf(mapfieldvalues.get('customer.contactName'));
                isCustMapped = true;
            }
            
            //customer phone mapping
            List<String> lstPhone = new List<String>();
            if(mapfieldvalues.get('customer.phoneNum.1')!=null){
                lstPhone.add(String.valueOf(mapfieldvalues.get('customer.phoneNum.1')));
                isCustMapped = true;
            }
            if(mapfieldvalues.get('customer.phoneNum.2')!=null){
                lstPhone.add(String.valueOf(mapfieldvalues.get('customer.phoneNum.2')));
                isCustMapped = true;
            }
            customer.phoneNum = lstPhone;
            if(isCustMapped)
                request_x.customer = customer;
            
            List<String> lstDesc = new List<String>();
            if(mapfieldvalues.get('desc.1')!=null){
                String descStr = String.valueOf(mapfieldvalues.get('desc.1'));
                if(descStr.length() > 500){
                    descStr=descStr.substring(0, 499);
                }           
                lstDesc.add(descStr);
            }
            if(mapfieldvalues.get('desc.2')!=null){
                String descStr = String.valueOf(mapfieldvalues.get('desc.2'));
                if(descStr.length() > 500){
                    descStr=descStr.substring(0, 499);
                }           
                lstDesc.add(descStr);
            }
            if(mapfieldvalues.get('desc.3')!=null){
                String descStr = String.valueOf(mapfieldvalues.get('desc.3'));
                if(descStr.length() > 500){
                    descStr=descStr.substring(0, 499);
                }           
                lstDesc.add(descStr);
            }
            if(mapfieldvalues.get('desc.4')!=null){
                String descStr = String.valueOf(mapfieldvalues.get('desc.4'));
                if(descStr.length() > 500){
                    descStr=descStr.substring(0, 499);
                }           
                lstDesc.add(descStr);
            }           
            request_x.desc_x = lstDesc;   
                     
            /*if(mapfieldvalues.get('desc_x')!=null) {
                List<String> descList = new List<String>();
                String mainStr = String.valueOf(mapfieldvalues.get('desc_x'));
                //validate the max length(500) of the string for SP
                String[] descStr = mainStr.split('(?<=\\G.{499})');
                //only save first 4 elements of the list for SP
                for(Integer i=0; i < descStr.size(); i++) {
                   descList.add(descStr[i]);
                   if(i == 3) break;
                }
                request_x.desc_x=descList;
            }*/

            if(mapfieldvalues.get('desc2')!=null) {
                String descStr = String.valueOf(mapfieldvalues.get('desc2'));
                //validate the max lenth of the string for SP
                if(descStr.length() > 3500){
                    request_x.desc2=descStr.substring(0, 3499);
                } else {
                    request_x.desc2=descStr;
                }
            }            
            WSCH_AuditLogger.debug('WSCH_Provider_SP_DataMapper::mapBookJobRequest:End assignment..');                      
            //WSCH_AuditLogger.debug('WSCH_Provider_SP_DataMapper::mapBookJobRequest:customMap:request_x: ' + request_x);
        }

        if(String.isBlank(request_x.jobID)) {
            request_x.jobID = WSCH_CommonUtils.getWorkItemId(WSCH_Constants.WORKORDER_OPTIMIZATION_ID_FIELD, workOrder);
        }

        if(String.isBlank(request_x.jobType)) {
            request_x.jobType = WSCH_CommonUtils.getSettingValue('DCON004','SET002');
        }

        if(String.isBlank(request_x.postcode)) {
            request_x.postcode = workOrder.SVMXC__Zip__c;
        }
        
        if(request_x.allowRebook == null)
            request_x.allowRebook = true;       //it is false unless if the same work order is being sent to book it again
        
        if(String.isBlank(request_x.extraDuration)){
            if(workOrder.SVMXC__Service_Duration__c != null) {
                request_x.extraDuration = ''+workOrder.SVMXC__Service_Duration__c.intvalue()/60;
            } /*else {
                request_x.extraDuration = '0';
                //this is a tentative fix to handle when service duration is not calculated during precalc
            }   */         
        }

        //  request_x.extraOverhead = 0;
        WSCH_Provider_SP_StubsV91.ReqSkills extraSkills = new WSCH_Provider_SP_StubsV91.ReqSkills();
        extraSkills = fetchExtraSkills(workOrder);
        if(extraSkills.reqSkills != null && extraSkills.reqSkills.size()> 0 ){
            request_x.extraSkills=extraSkills;
        }

        /*WSCH_Provider_SP_StubsV91.ReqEmp reqEmp = new WSCH_Provider_SP_StubsV91.ReqEmp();
        List<WSCH_Provider_SP_StubsV91.ReqEmp> lstEmp = new List<WSCH_Provider_SP_StubsV91.ReqEmp>();
        reqEmp=fetchReqEmp(workOrder);
        if(reqEmp != null){
            lstEmp.add(reqEmp);
            WSCH_Provider_SP_StubsV91.ListReqEmps lstReqEmps = new WSCH_Provider_SP_StubsV91.ListReqEmps();
            lstReqEmps.reqEmp=lstEmp;
            request_x.listReqEmps=lstReqEmps;
        }*/
        //if(WORD_Service_Order_Resources.getResourcePreferenceSetting()){
            WSCH_Provider_SP_StubsV91.ListReqEmps lstReqEmps = new WSCH_Provider_SP_StubsV91.ListReqEmps();
            lstReqEmps = fetchListReqEmps(workOrder.id, workOrder.SVMXC__Preferred_Technician__r.SVMXC__Optimizer_External_ID__c);
            if(lstReqEmps != null){
                request_x.listReqEmps = lstReqEmps;
            }
        //}
        
        if(String.isBlank(request_x.priority)) {
            request_x.priority = resolveDispatchPriority(workOrder);
        }

        if(String.isBlank(request_x.importance)) {
            request_x.importance=WSCH_Constants.STR_IMPORTANCE;
        }
        
        if(String.isBlank(request_x.contractEarliest) && workOrder.SVMXC__Preferred_Start_Time__c != null) {
            request_x.contractEarliest = WSCH_DateUtils.getSPDateTime(workOrder.SVMXC__Preferred_Start_Time__c);
        }

        if(String.isBlank(request_x.contractLatest))
            request_x.contractLatest = formatPreferredEndTime(workOrder);

        //request_x.accHoursPatts = fetchAccHoursPatts(workOrder);

        if(String.isBlank(request_x.siteID) && workOrder.SVMXC__Site__c != null) {
            //SVMXC__Site__c siteObj = getSiteBySiteId(workOrder.SVMXC__Site__c);
            //request_x.siteID = siteObj.Name;
            request_x.siteID = workOrder.SVMXC__Site__r.Name;
        }

        if(request_x.customer == null){
            WSCH_Provider_SP_StubsV91.Customer customer = new WSCH_Provider_SP_StubsV91.Customer();
            WSCH_AuditLogger.debug('workOrder.SVMXC__Company__r.Name - ' + workOrder.SVMXC__Company__r.Name);
            WSCH_AuditLogger.debug('workOrder.SVMXC__Company__r.Id - ' + workOrder.SVMXC__Company__r.Id);
            WSCH_AuditLogger.debug('workOrder.SVMXC__Company__r.AccountNumber - ' + workOrder.SVMXC__Company__r.AccountNumber);
            
            /*Account objectAccount = getAccountFromCompanyId(workOrder.SVMXC__Company__c);
            if(objectAccount != null) {
                customer.custID = objectAccount.AccountNumber;
                customer.custName = objectAccount.Name;
            }*/
            
            customer.custID = workOrder.SVMXC__Company__r.AccountNumber;
            customer.custName = workOrder.SVMXC__Company__r.Name;
            
            List<String> lstCustAddress = new List<String>();
            lstCustAddress.add(workOrder.SVMXC__Street__c);
            lstCustAddress.add(workOrder.SVMXC__City__c);
            lstCustAddress.add(workOrder.SVMXC__State__c);
            lstCustAddress.add(workOrder.SVMXC__Country__c);
            customer.custAddress = lstCustAddress;
    
            WSCH_AuditLogger.debug('workOrder.SVMXC__Contact__r.FirstName - ' + workOrder.SVMXC__Contact__r.FirstName);
            WSCH_AuditLogger.debug('workOrder.SVMXC__Contact__r.LastName - ' + workOrder.SVMXC__Contact__r.LastName);
            WSCH_AuditLogger.debug('workOrder.SVMXC__Contact__r.Phone - ' + workOrder.SVMXC__Contact__r.Phone);
            
            if(String.isNotEmpty(workOrder.SVMXC__Contact__r.FirstName) && String.isNotEmpty(workOrder.SVMXC__Contact__r.LastName)) {
                customer.contactName = workOrder.SVMXC__Contact__r.FirstName + ' ' + workOrder.SVMXC__Contact__r.LastName;
            } else if(String.isNotEmpty(workOrder.SVMXC__Contact__r.FirstName)) {
                customer.contactName = workOrder.SVMXC__Contact__r.FirstName ;
            } else if(String.isNotEmpty(workOrder.SVMXC__Contact__r.LastName)) {
                customer.contactName = workOrder.SVMXC__Contact__r.LastName;
            }
            List<String> lstPhone = new List<String>();
            //lstPhone.add(workOrder.SVMXC__WOContact_sPhNum__c);
            lstPhone.add(workOrder.SVMXC__Contact__r.Phone);
            customer.phoneNum = lstPhone;
            
            request_x.customer = customer;
        }
        

        //modifying request for the job book through calendar view using technician slots
        //"strStartTime - strEndTime, strDay, strDate, 'true', strHorizonStartGmtDt, strHorizonEndGmtDt"
        //Kundan@HybridBooking- Commented below code to implement Hybrid booking Logic below.
        /*if(workOrder.SVMXC__Appointment_Promised_Time_Slot__c != null){
            String[] apptPromiseSlotArray = workOrder.SVMXC__Appointment_Promised_Time_Slot__c.split(',',9);
            if(apptPromiseSlotArray != null && apptPromiseSlotArray.size() == 9) {
                //request_x.contractEarliest=formatPreferredStartTime(apptPromiseSlotArray[0]+','+apptPromiseSlotArray[2]);
                //request_x.contractLatest = formatPreferredEndTime(apptPromiseSlotArray[0]+','+apptPromiseSlotArray[2]);
                //request_x.contractEarliest = WSCH_DateUtils.getSPDateTime(DateTime.valueOfGmt(apptPromiseSlotArray[7]));
                //request_x.contractLatest = WSCH_DateUtils.getSPDateTime(DateTime.valueOfGmt(apptPromiseSlotArray[8]));
                Integer tzOffSetinMinutes = Integer.valueOf(apptPromiseSlotArray[6].trim());
                WSCH_AuditLogger.debug('WSCH_Provider_SP_DataMapper::mapBookJobRequest::tzOffSetinMinutes-'+tzOffSetinMinutes);
                //request_x.accHoursPatts = fetchAccHoursPatts(workOrder,apptPromiseSlotArray[4].trim(),apptPromiseSlotArray[5].trim(),tzOffSetinMinutes);
                
                //below request object contains the Holiday dates/ holiday hours which overrides the accessHours being sent for an Apoointment Request
                closedAccHoursOvrs = getClosedAccHoursOvrs(workOrder,apptPromiseSlotArray[4].trim(),apptPromiseSlotArray[5].trim(),tzOffSetinMinutes);
                if(closedAccHoursOvrs.closedHours != null && closedAccHoursOvrs.closedHours.size() > 0) {
                    request_x.closedAccHoursOvrs = closedAccHoursOvrs; 
                }
                if(closedAccHoursOvrs == null || closedAccHoursOvrs.closedHours.size() <= 0) {
                    closedAccHoursOvrs = getClosedAccHoursOvrs(workOrder, null, null, null);
                    request_x.closedAccHoursOvrs = closedAccHoursOvrs; 
                }
            }
        }*/
        
        //below request object contains the Holiday dates/ holiday hours which overrides the accessHours being sent
        // if already not populated by Appointmtment Request. This will be the case of BookJob, not SLA Job.
        //Kundan@HybridBooking 
        WSCH_Provider_SP_StubsV91.ClosedAccHoursOvrs closedAccHoursOvrs;
        
        Integer apptDays = 5;
        try{
            //String apptDaysSetting = String.valueof(SVMXC.WSCH_CommonUtils.getSettingValue('DCON003', 'SET013'));
            String apptDaysSetting = String.valueof(SVMXC.WSCH_CommonUtils.getSettingValue('DCON004', 'SET018'));
            //if(String.isNotBlank(apptDaysSetting) && apptDaysSetting.trim() != '0'){
            if(String.isNotBlank(apptDaysSetting)){
                apptDays = Integer.valueof(apptDaysSetting.trim());
            }
        }catch (Exception ex) {
            String exceptionMsg = 'WSCH_Provider_SP_DataMapper :: mapBookJobRequest() :: ';
            WSCH_AuditLogger.error(exceptionMsg+ex.getMessage() + ex.getMessage() + '\n Stack Trace:: ' + ex.getStackTraceString());
        }
        if(WSCH_Provider_SP_Appointments_Calendar.isEarlyArrivalSelected != null && !(WSCH_Provider_SP_Appointments_Calendar.isEarlyArrivalSelected) && workOrder.SVMXC__Appointment_Promised_Time_Slot__c != null){  
            
            String[] apptPromiseSlotArray = workOrder.SVMXC__Appointment_Promised_Time_Slot__c.split(',',9);          
            Integer tzOffSetinMinutes = Integer.valueOf(apptPromiseSlotArray[6].trim());
            DateTime svcStartDate = datetime.valueofGMT(apptPromiseSlotArray[7].trim());
            String serviceStartDate = String.valueof(svcStartDate.formatGmt('yyyy-MM-dd'));
            DateTime svcEndDate = (DateTime.valueofGMT(apptPromiseSlotArray[8].trim()));
            //commenting the below code as the setting DCON003_SET01111 does not exist in Dev Org.
            String serviceEndDate = String.valueof((svcEndDate.addDays(apptDays)).formatGmt('yyyy-MM-dd'));
            //String serviceEndDate = String.valueof((svcEndDate.addDays(5)).formatGmt('yyyy-MM-dd'));
            
            request_x.contractEarliest = String.valueof(((DateTime.valueofGMT(apptPromiseSlotArray[7].trim())).formatGMT('yyyy-MM-dd HH:mm')).replace(' ','T'));
            request_x.contractLatest = String.valueof(((DateTime.valueofGMT(apptPromiseSlotArray[8].trim())).formatGMT('yyyy-MM-dd HH:mm')).replace(' ','T'));
            //request_x.contractEarliest = String.valueof((System.now().formatGMT('yyyy-MM-dd HH:mm')).replace(' ','T'));
            //request_x.contractLatest = String.valueof(((DateTime.valueofGMT(apptPromiseSlotArray[8].trim()).addMinutes(-30)).formatGMT('yyyy-MM-dd HH:mm')).replace(' ','T'));
            
            request_x.accHoursPatts = fetchAccHoursPatts(workOrder,serviceStartDate, serviceEndDate, tzOffSetinMinutes);
            
            closedAccHoursOvrs = getClosedAccHoursOvrs(workOrder,serviceStartDate,serviceEndDate,tzOffSetinMinutes);

            WSCH_Provider_SP_StubsV91.DateAndTimeRange dateRange = new WSCH_Provider_SP_StubsV91.DateAndTimeRange();
            dateRange.start = apptPromiseSlotArray[2].trim() + 'T00:00';
            String[] endTime = (apptPromiseSlotArray[0].trim()).split('-');
            dateRange.end_x = apptPromiseSlotArray[2].trim() + 'T' + endTime[0].trim();
            
            closedAccHoursOvrs.closedHours.add(dateRange);
            WSCH_AuditLogger.debug('WSCH_Provider_SP_DataMapper::mapBookJobRequest()::closedAccHoursOvrs'+closedAccHoursOvrs);
            request_x.closedAccHoursOvrs = closedAccHoursOvrs;
            
        }
        else if(WSCH_Provider_SP_Appointments_Calendar.isEarlyArrivalSelected != null && workOrder.SVMXC__Appointment_Promised_Time_Slot__c != null){    
            String[] apptPromiseSlotArray = workOrder.SVMXC__Appointment_Promised_Time_Slot__c.split(',',9);
            Integer tzOffSetinMinutes = Integer.valueOf(apptPromiseSlotArray[6].trim());    
            String serviceStartDate = String.valueof(System.now().formatGmt('yyyy-MM-dd'));
            DateTime svcEndDate = (DateTime.valueofGMT(apptPromiseSlotArray[8].trim()));
            //commenting the below code as the setting DCON003_SET01111 does not exist in Dev Org.
            String serviceEndDate = String.valueof((svcEndDate.addDays(apptDays)).formatGmt('yyyy-MM-dd'));
            //String serviceEndDate = String.valueof((svcEndDate.addDays(5)).formatGmt('yyyy-MM-dd'));
            request_x.contractEarliest = String.valueof((System.now().formatGMT('yyyy-MM-dd HH:mm')).replace(' ','T'));
            request_x.contractLatest = String.valueof(((DateTime.valueofGMT(apptPromiseSlotArray[8].trim())).formatGMT('yyyy-MM-dd HH:mm')).replace(' ','T'));
            //request_x.contractEarliest = String.valueof((System.now().formatGMT('yyyy-MM-dd HH:mm')).replace(' ','T'));
            //request_x.contractLatest = String.valueof(((DateTime.valueofGMT(apptPromiseSlotArray[8].trim()).addMinutes(-30)).formatGMT('yyyy-MM-dd HH:mm')).replace(' ','T'));
            
            request_x.accHoursPatts = fetchAccHoursPatts(workOrder,serviceStartDate, serviceEndDate, tzOffSetinMinutes);
            closedAccHoursOvrs = getClosedAccHoursOvrs(workOrder,serviceStartDate,serviceEndDate,tzOffSetinMinutes);
        }
        //Automatic SLA Job Booking
        else{
            String serviceEndDate;
            if(String.isNotBlank(request_x.contractLatest)){
                serviceEndDate =  String.valueof(((DateTime.valueofGMT((request_x.contractLatest).replace('T',' ')+':00')).addDays(apptDays)).formatGmt('yyyy-MM-dd'));
            }
            String serviceStartDate = String.valueof(System.now().formatGmt('yyyy-MM-dd'));
            if(String.isNotBlank(request_x.contractEarliest)){
                serviceStartDate = String.valueof(((DateTime.valueofGMT((request_x.contractEarliest).replace('T',' ')+':00'))).formatGmt('yyyy-MM-dd'));
            }
            request_x.accHoursPatts = fetchAccHoursPatts(workOrder,serviceStartDate, serviceEndDate, null);
            //request_x.accHoursPatts = fetchAccHoursPatts(workOrder);
        }
        
        if(closedAccHoursOvrs == null || closedAccHoursOvrs.closedHours.size() <= 0) {
            closedAccHoursOvrs = getClosedAccHoursOvrs(workOrder, null, null, null);
        }
        if(closedAccHoursOvrs.closedHours != null && closedAccHoursOvrs.closedHours.size() > 0) {
            request_x.closedAccHoursOvrs = closedAccHoursOvrs; 
        }
        
        /*REMOVED Hybrid Booking & added below code*/
        /*WSCH_Provider_SP_StubsV91.ClosedAccHoursOvrs closedAccHoursOvrs;
        //modifying request for the job book through calendar view using technician slots
        //"strStartTime - strEndTime, strDay, strDate, 'true', strHorizonStartGmtDt, strHorizonEndGmtDt"
        if(workOrder.SVMXC__Appointment_Promised_Time_Slot__c != null){       
            String[] apptPromiseSlotArray = workOrder.SVMXC__Appointment_Promised_Time_Slot__c.split(',',9);
            if(apptPromiseSlotArray != null && apptPromiseSlotArray.size() == 9) {
                //request_x.contractEarliest=formatPreferredStartTime(apptPromiseSlotArray[0]+','+apptPromiseSlotArray[2]);
                //request_x.contractLatest = formatPreferredEndTime(apptPromiseSlotArray[0]+','+apptPromiseSlotArray[2]);
                request_x.contractEarliest = WSCH_DateUtils.getSPDateTime(DateTime.valueOfGmt(apptPromiseSlotArray[7]));
                request_x.contractLatest = WSCH_DateUtils.getSPDateTime(DateTime.valueOfGmt(apptPromiseSlotArray[8]));
                Integer tzOffSetinMinutes = Integer.valueOf(apptPromiseSlotArray[6].trim());
                WSCH_AuditLogger.debug('WSCH_Provider_SP_DataMapper::mapBookJobRequest::tzOffSetinMinutes-'+tzOffSetinMinutes);
                request_x.accHoursPatts = fetchAccHoursPatts(workOrder,apptPromiseSlotArray[4].trim(),apptPromiseSlotArray[5].trim(),tzOffSetinMinutes);
                
                //below request object contains the Holiday dates/ holiday hours which overrides the accessHours being sent
                closedAccHoursOvrs = getClosedAccHoursOvrs(workOrder,apptPromiseSlotArray[4].trim(),apptPromiseSlotArray[5].trim(),tzOffSetinMinutes);
                if(closedAccHoursOvrs.closedHours != null && closedAccHoursOvrs.closedHours.size() > 0) {
                    request_x.closedAccHoursOvrs = closedAccHoursOvrs; 
                }
            }
        }
        //below request object contains the Holiday dates/ holiday hours which overrides the accessHours being sent
        //WSCH_Provider_SP_StubsV91.ClosedAccHoursOvrs closedAccHoursOvrs = getClosedAccHoursOvrs(workOrder, null, null, null);
        if(closedAccHoursOvrs == null){
            closedAccHoursOvrs = getClosedAccHoursOvrs(workOrder, null, null, null);
            if(closedAccHoursOvrs.closedHours != null && closedAccHoursOvrs.closedHours.size() > 0) {
                request_x.closedAccHoursOvrs = closedAccHoursOvrs; 
            }
        }
        if((request_x.accHoursPatts == null) || (request_x.accHoursPatts.accHoursPatt == null)){
            request_x.accHoursPatts = fetchAccHoursPatts(workOrder);
        }*/
        
        WSCH_AuditLogger.debug('WSCH_Provider_SP_DataMapper::mapBookJobRequest()::end: No of Queries used in this transaction so far: ' + Limits.getQueries());
        return request_x;
    }

    public static void mapBookJobResponse(SVMXC__Service_Order__c workOrder, WSCH_Provider_SP_StubsV91.JobBookResponse jobResponse) {
        String errorText=null;
        if (jobResponse != null) {
            WSCH_Provider_SP_StubsV91.ReturnCode returnCode = jobResponse.result;
            WSCH_Provider_SP_StubsV91.BookInfo bookInfo = jobResponse.bookJobInfo;
            //based on the response code set the appropriate message on the WO Optimax status.
            if(WSCH_Provider_SP_ErrorCodesMapper.isSuccess(returnCode.code)){
                workOrder.SVMXC__OptiMax_Status__c = WSCH_Constants.STATUS_OPT_TENTATIVE;
                //update the workorder primary territory from the bookInfo response
                if(null != bookInfo.FRU){
                    //String territoryId = WSCH_CommonUtils.fetchTerritoryIdByExternalId(bookInfo.FRU);
                    //retrieve the territoryId based on the optimizerExternalId frm the map that is populated earlier in static block
                    String territoryId = mapOfOptExtIdAndTerritoryId.get(bookInfo.FRU);
                    WSCH_AuditLogger.debug('WSCH_Provider_SP_DataMapper:: mapBookJobResponse(): territoryId - ' + territoryId);
                    //If Successful Callout Set the Work Order Connection Name Field with the SP Connection Name 
                    if(!WSCH_Provider_SP_RealTimeOptimizer.mapWoConName.isEmpty()){
                        workOrder.SVMXC__Optimizer_Connection_Name__c = workOrder.SVMXC__Optimizer_Connection_Name__c == null?WSCH_Provider_SP_RealTimeOptimizer.mapWoConName.get(workOrder.Id):workOrder.SVMXC__Optimizer_Connection_Name__c;
                    }
                    //update the workorder status and error text if territory not configured in servicemax side.
                    if(String.isNotBlank(territoryId)) {
                        workOrder.SVMXC__Primary_Territory__c=territoryId;
                        workOrder.SVMXC__Service_Zone_ID__c=bookInfo.FRU;
                        //update Territory record Connection Name
                        SVMXC__Territory__c territory = mapOfTerritoryIdAndTerritoryObj.get(Id.valueOf(territoryId));
                        if((territory.SVMXC__Optimizer_Connection_Name__c == null) || (String.isBlank(territory.SVMXC__Optimizer_Connection_Name__c))){
                            territory.SVMXC__Optimizer_Connection_Name__c = workOrder.SVMXC__Optimizer_Connection_Name__c;
                            //Database.update(territory);
                            WSCH_Provider_SP_RealTimeOptimizer.lstTerrUpd.add(territory);
                        }
                        if(isAppointmentWO(workOrder)){
                            errorText = 'Previous appointment is lost due to an update on the work order. Kindly rebook an appointment for this work order to fix the appointment.';
                            WSCH_CommonUtils.setOptimizerErrorText(workOrder, errorText);
                        }
                    } else {
                        workOrder.SVMXC__OptiMax_Status__c = WSCH_Constants.STATUS_OPT_DATA_SYNC_ERROR;
                        errorText = 'Workorder is scheduled for a Territory is not configured in ServiceMax side. Please create/update territory with external Id -'+bookInfo.FRU;
                        WSCH_CommonUtils.setOptimizerErrorText(workOrder, errorText);
                    }
                }
            } else {
                workOrder.SVMXC__OptiMax_Status__c = WSCH_CommonUtils.resolveOptimaxStatus(workOrder.SVMXC__OptiMax_Status__c, 'OPT_ERROR');
                //if SLA bookjob through appointment is not successful, delete the new slot info stored in apptPromiseSlot 
                //and copy the old booking info if there is already any previous appt for this WO.
                if(String.isNotBlank(WSCH_Provider_SP_Appointments_Calendar.strOldApptPromiseSlot)) {
                    workOrder.SVMXC__Appointment_Promised_Time_Slot__c = WSCH_Provider_SP_Appointments_Calendar.strOldApptPromiseSlot;
                }
                
                //if SLA bookjob through appointment is not successful, delete the new slot info stored in bookedAppointmentSlot 
                //and copy the old booking info if there is already any previous appt for this WO.
                if(String.isNotBlank(WSCH_Provider_SP_Appointments_Calendar.strOldApptBookedSlot)) {
                    workOrder.SVMXC__Booked_Appointment_Slot__c = WSCH_Provider_SP_Appointments_Calendar.strOldApptBookedSlot;
                }
            }
            errorText = 'Return Code:' + returnCode.code + ' | Return Type:' + returnCode.type_x + ' | Return Note:' + returnCode.errNote + ' | Return Msg:' + WSCH_Provider_SP_ErrorCodesMapper.getStatusMsg(returnCode.code);
            WSCH_CommonUtils.setOptimizerErrorText(workOrder, errorText);
        } else {
            WSCH_AuditLogger.error('Failed to map return code for book job as responce is null.');
        }
    }

    public static boolean isAppointmentWO(SVMXC__Service_Order__c newWO) {

        Boolean isApptWO = false;
        if(newWO != null && newWO.SVMXC__Appointment_Promised_Time_Slot__c != null){
            String[] apptPromiseSlotArray = newWO.SVMXC__Appointment_Promised_Time_Slot__c.split(',',7);
            if(apptPromiseSlotArray.size() > 3){
                if(apptPromiseSlotArray != null && apptPromiseSlotArray[3].trim().equals('true')) {
                    isApptWO = true;
                }
            }
            WSCH_AuditLogger.debug('WSCH_Provider_SP_DataMapper::isAppointmentWO::isApptWO :'+isApptWO);
        }
        return isApptWO;
    }

    public static void mapUpdateAPIReturnCode (SVMXC__Service_Order__c workOrder, WSCH_Provider_SP_StubsV91.ReturnCode returnCode) {
        //set the status code on the work order.
        if(workOrder != null && returnCode != null) {
            //based on the response code set the appropriate message on the WO Optimax status.
            if(WSCH_Provider_SP_ErrorCodesMapper.isSuccess(returnCode.code)){
                workOrder.SVMXC__OptiMax_Status__c = WSCH_Constants.STATUS_OPT_TENTATIVE;
                //If Successful Callout Set the Work Order Connection Name Field with the SP Connection Name 
                if(!WSCH_Provider_SP_RealTimeOptimizer.mapWoConName.isEmpty()){
                    //workOrder.SVMXC__Optimizer_Connection_Name__c = WSCH_Provider_SP_RealTimeOptimizer.mapDpIdSpUrl.get(workOrder.SVMXC__Dispatch_Process__c);
                    workOrder.SVMXC__Optimizer_Connection_Name__c = workOrder.SVMXC__Optimizer_Connection_Name__c == null?WSCH_Provider_SP_RealTimeOptimizer.mapWoConName.get(workOrder.Id):workOrder.SVMXC__Optimizer_Connection_Name__c;
                }
            } else {
                workOrder.SVMXC__OptiMax_Status__c = WSCH_CommonUtils.resolveOptimaxStatus(workOrder.SVMXC__OptiMax_Status__c, 'OPT_ERROR');
            }
            String errorText = 'Return Code:' + returnCode.code + ' | Return Type:' + returnCode.type_x + ' | Return Note:' + returnCode.errNote + ' | Return Msg:' + WSCH_Provider_SP_ErrorCodesMapper.getStatusMsg(returnCode.code);
            WSCH_CommonUtils.setOptimizerErrorText(workOrder, errorText);
        }
    }

    public static WSCH_Provider_SP_StubsV91.GetChangedWorkItemsRequest mapGetChangedWorkItemsRequest(String fru, String timeStamp) {

        WSCH_Provider_SP_StubsV91.GetChangedWorkItemsRequest request_x = new WSCH_Provider_SP_StubsV91.GetChangedWorkItemsRequest();
        request_x.login = fetchLoginInfo();
        request_x.FRUID = fru;
        if(null != timestamp) {
            request_x.timeStampIn = timeStamp; //fetchTimeStampIn(workOrder);
        }
        return request_x;
    }

    public static WSCH_WorkOrderUpdateResponse mapGetChangedWorkItemsResponse(WSCH_Provider_SP_StubsV91.GetChangedWorkItemsResponse changedResponse) {

        WSCH_WorkOrderUpdateResponse woUpdateResponse = new WSCH_WorkOrderUpdateResponse();
        WSCH_WorkOrderResponse woResponse = new WSCH_WorkOrderResponse();
        List<WSCH_TechnicianEvent>  lstTechEvent = new List<WSCH_TechnicianEvent>();
        Set<String> workItemIds = new Set<String>();
        WSCH_TechnicianEvent techEvent;
        
        List<WSCH_Provider_SP_Push_Stubs.WorkItem> lstWorkItem = new List<WSCH_Provider_SP_Push_Stubs.WorkItem>();
        WSCH_Provider_SP_Push_Stubs.WorkItem workItem;
        
        if(changedResponse != null && WSCH_Provider_SP_ErrorCodesMapper.isSuccess(changedResponse.result.code) && changedResponse.workItem != null) {
            for(WSCH_Provider_SP_StubsV91.GCJWorkItemAttr eachWorkItem : changedResponse.workItem) {
                if(WSCH_Constants.STR_WORKITEM_TYPE.equalsIgnoreCase(eachWorkItem.workItemType)) {

                    //create a TechEvent object and populate it from response data
                    techEvent = new WSCH_TechnicianEvent();
                    techEvent.setWorkOrderID(eachWorkItem.workItemID);
                    techEvent.setIsFixed(eachWorkItem.isFixed);
                    workItemIds.add(eachWorkItem.workItemID);
                    WSCH_Provider_SP_StubsV91.GCJAttr attr = eachWorkItem.attr;
                    if(attr != null) {
                        techEvent.setTechnicianExternalID(attr.empID);
                        techEvent.setStartDateTime(WSCH_DateUtils.parseSPDateTimeGmt(attr.start));
                        techEvent.setArrivalDateTime(WSCH_DateUtils.parseSPDateTimeGmt(attr.arrival));
                        techEvent.setFinishDateTime(WSCH_DateUtils.parseSPDateTimeGmt(attr.finish));
                        techEvent.setDispatchStatus(attr.disStatus);
                    }
                    /*
                     Below logic has been added for the Managing the Jeopardy Error Messages
                    */
                    WSCH_Provider_SP_StubsV91.JeopConditions jobJeopardy = eachWorkItem.jobJeopardy;
                    Set<String> violationMsgSet = new Set<String>();
                    if (jobJeopardy != null) {
                        techEvent.setViolationMessage('');
                        Map<String,Object> jeopardyStatusMap = jobJeopardy.getAttributes();
                        Set<String> jeopardyStatusList = jeopardyStatusMap.keySet();
                        for(String jeopardyStatusName : jeopardyStatusList) {
                            String jeopardyStatusValue = String.valueOf(jeopardyStatusMap.get(jeopardyStatusName));
                            if(jeopardyStatusValue !=null && !jeopardyStatusName.endsWith('_type_info') && String.isNotBlank(jeopardyStatusValue)) {
                                  String errorMessage = WSCH_Provider_SP_ErrorCodesMapper.getViolationMessage(jeopardyStatusName);
                                  violationMsgSet.add(errorMessage);
                            }
                        }
                        if(violationMsgSet.size()>0) {
                          List<String> voilationMsgList = new List<String>(violationMsgSet);
                          String violationMessage = String.join(voilationMsgList, '\n');
                          techEvent.setViolationMessage(violationMessage);
                        }
                    }
                    lstTechEvent.add(techEvent);
                }else if(WSCH_Constants.STR_WORKITEM_TYPE_SA.equalsIgnoreCase(eachWorkItem.workItemType)){
                    String workType = 'activity';
                    WSCH_Provider_SP_Push_Stubs.Booking booking = new WSCH_Provider_SP_Push_Stubs.Booking();
                    WSCH_Provider_SP_Push_Stubs.Task task = new WSCH_Provider_SP_Push_Stubs.Task();
                    WSCH_Provider_SP_StubsV91.GCJAttr attr = eachWorkItem.attr;
                    workItem = new WSCH_Provider_SP_Push_Stubs.WorkItem();
                    if(attr != null) {
                        booking.tech=attr.empID;
                        booking.start=WSCH_DateUtils.getSFDateAndTime(attr.start);
                        booking.arr=WSCH_DateUtils.getSFDateAndTime(attr.arrival);
                        booking.end_x=WSCH_DateUtils.getSFDateAndTime(attr.finish);
                        if('Earmarked'.equalsIgnoreCase(attr.disStatus)){
                            task.action = 'NOTIFIED';
                            workItem.pullState='NOTIFIED';
                        }else if('Tentative'.equalsIgnoreCase(attr.disStatus)){
                            task.action = 'PLANNED';
                            workItem.pullState='PLANNED';
                        }
                    }
                    task.tied = eachWorkItem.isFixed;
                    
                    //workItem = new WSCH_Provider_SP_Push_Stubs.WorkItem();                                        
                    workItem.id = eachWorkItem.workItemID;
                    workItem.task = task;
                    workItem.Booking = booking;
                    workItem.type = workType;
                    //WSCH_AuditLogger.debug('WSCH_Provider_SP_DataMapper::mapGetChangedWorkItemsResponse::workItem :'+workItem);
                    lstWorkItem.add(workItem);
                }
            }
            //Updating the techevent with work Order Id using WorkItemId.
            Map<String,String> workItemsIdToWoId = WSCH_CommonUtils.getWorkItemIds(WSCH_Constants.WORKORDER_OPTIMIZATION_ID_FIELD, new List<String>(workItemIds));
            for(WSCH_TechnicianEvent event : lstTechEvent) {
                event.setWorkOrderID(workItemsIdToWoId.get(event.getWorkOrderID()));
            }
            woResponse.getLstTechEvent().addAll(lstTechEvent);
            //WSCH_AuditLogger.debug('WSCH_Provider_SP_DataMapper::mapGetChangedWorkItemsResponse::lstWorkItem :'+lstWorkItem);
            woResponse.getLstWorkItem().addAll(lstWorkItem);
            //WSCH_AuditLogger.debug('WSCH_Provider_SP_DataMapper::mapGetChangedWorkItemsResponse::woResponse :'+woResponse);
        }
        woUpdateResponse.setWoResponse(woResponse);
        woUpdateResponse.setTimeStampOut(changedResponse.timeStampOut);
        woUpdateResponse.setMore(changedResponse.more);
        return woUpdateResponse;
    }

    public static WSCH_Provider_SP_StubsV91.ApptOfferRequest mapApptOfferRequest(SVMXC__Service_Order__c workOrder, WSCH_ApptParam apptParamObj, Integer size, Integer currentIndex){
        
        WSCH_AuditLogger.debug('Inside mapApptOfferRequest');
        WSCH_Provider_SP_StubsV91.ApptOfferRequest apptOfferReq = new WSCH_Provider_SP_StubsV91.ApptOfferRequest();
        apptOfferReq.login = fetchLoginInfo();
        //get the timezone info from work order
        String strWOTimeZone = getWOTimeZone(workOrder);
        
        //String strMapId = getSFMMappingId(WSCH_Constants.API_OFFER_APPT);
        //fetch the SFM Mapping Id as per the Work Order Connection Name
        String strMapId = getSpSFMMappingId(WSCH_Constants.API_OFFER_APPT, WSCH_Provider_SP_RealTimeOptimizer.mapWoConName.get(workOrder.Id));
        map<String,Object> mapfieldvalues = new map<String,Object>();
        if(String.isNotBlank(strMapId)) {
            mapfieldvalues = getSmartObjectRecords(strMapId, workOrder);
            WSCH_AuditLogger.debug('WSCH_Provider_SP_DataMapper::mapApptOfferRequest:mapfieldvalues: '+mapfieldvalues);
        }
        
        if(mapfieldvalues != null && mapfieldvalues.size() > 0){
            WSCH_AuditLogger.debug('WSCH_Provider_SP_DataMapper::mapApptOfferRequest:Start mapping assignment..');
            
            if(mapfieldvalues.get('numReq') != null){
                apptOfferReq.numReq = Integer.valueOf(mapfieldvalues.get('numReq'));
            }
            
            if(mapfieldvalues.get('numReqType') != null){
                apptOfferReq.numReqType = String.valueOf(mapfieldvalues.get('numReqType'));
            }
                        
            if(mapfieldvalues.get('jobType') != null){
                apptOfferReq.jobType = String.valueOf(mapfieldvalues.get('jobType'));
            }

            if(mapfieldvalues.get('promSet') != null){
                apptOfferReq.promSet = String.valueOf(mapfieldvalues.get('promSet'));
            }

            if(mapfieldvalues.get('postcode') != null){
                apptOfferReq.postcode = String.valueOf(mapfieldvalues.get('postcode'));
            }
            
            if(mapfieldvalues.get('extraDuration')!=null){
                apptOfferReq.extraDuration = ''+Integer.valueOf(mapfieldvalues.get('extraDuration'));
            }
            
            if(mapfieldvalues.get('extraOverhead')!=null){
                apptOfferReq.extraOverhead = Integer.valueOf(mapfieldvalues.get('extraOverhead'));
            }
             
            if(mapfieldvalues.get('stdExtraDuration')!=null){
                apptOfferReq.stdExtraDuration = String.valueOf(mapfieldvalues.get('stdExtraDuration'));
            }

            if(mapfieldvalues.get('reqUnit.unitType')!=null){
                if(apptOfferReq.reqUnit == null){
                    apptOfferReq.reqUnit = new WSCH_Provider_SP_StubsV91.ReqUnit();
                }
                apptOfferReq.reqUnit.unitType = String.valueOf(mapfieldvalues.get('reqUnit.unitType'));
            }
            
            if(mapfieldvalues.get('reqUnit.RUID')!=null){
                if(apptOfferReq.reqUnit == null){
                    apptOfferReq.reqUnit = new WSCH_Provider_SP_StubsV91.ReqUnit();
                }
                apptOfferReq.reqUnit.RUID = String.valueOf(mapfieldvalues.get('reqUnit.RUID'));
            }

            if(mapfieldvalues.get('days')!=null){
                apptOfferReq.days = String.valueOf(mapfieldvalues.get('days'));
            }
             
            WSCH_Provider_SP_StubsV91.DateOptTime startDate = new WSCH_Provider_SP_StubsV91.DateOptTime();
            WSCH_Provider_SP_StubsV91.DateOptTime endDate = new WSCH_Provider_SP_StubsV91.DateOptTime();
            if(mapfieldvalues.get('start.date') != null){
                DateTime appointmentStart = Datetime.valueOf(mapfieldvalues.get('start.date'));
                startDate.date_x = WSCH_DateUtils.getDateFromDT(appointmentStart, strWOTimeZone, 'gmt');
                startDate.time_x = WSCH_DateUtils.getTimeFromDT(appointmentStart, strWOTimeZone, 'gmt');                
                apptOfferReq.start = startDate;
                
                if(mapfieldvalues.get('end.date') == null){
                    DateTime appointmentEnd;
                    String strNoOfDaysInCalSetting;
                    String strTempCalDaysSetting = WSCH_CommonUtils.getSettingValue('DCON003','SET008');
                    if(strTempCalDaysSetting != null && String.isNotBlank(strTempCalDaysSetting)) {
                        strNoOfDaysInCalSetting = strTempCalDaysSetting;
                    } else {
                        strNoOfDaysInCalSetting = '7';  /* Set 7 as default value if there is not setting value */
                    }
                    appointmentEnd = appointmentStart.addDays(Integer.valueOf(strNoOfDaysInCalSetting) - 1);
                    endDate.date_x = WSCH_DateUtils.getDateFromDT(appointmentEnd, strWOTimeZone, 'gmt');
                    endDate.time_x = WSCH_DateUtils.getTimeFromDT(appointmentEnd, strWOTimeZone, 'gmt');
                    apptOfferReq.end_x = endDate; 
                }
            }
               
            if(mapfieldvalues.get('end.date') != null){
                DateTime appointmentEnd = Datetime.valueOf(mapfieldvalues.get('end.date'));
                endDate.date_x = WSCH_DateUtils.getDateFromDT(appointmentEnd, strWOTimeZone, 'gmt');
                endDate.time_x = WSCH_DateUtils.getTimeFromDT(appointmentEnd, strWOTimeZone, 'gmt');
                apptOfferReq.end_x = endDate;               
            }

            if(mapfieldvalues.get('preferredDate')!=null){
                apptOfferReq.preferredDate = String.valueOf(mapfieldvalues.get('preferredDate'));
            }           
            
            WSCH_Provider_SP_StubsV91.Band band = new WSCH_Provider_SP_StubsV91.Band();
            if(mapfieldvalues.get('band.timeBandID') != null){
                band.timeBandID = String.valueOf(mapfieldvalues.get('band.timeBandID'));
            }
            if(mapfieldvalues.get('band.start') != null){
                DateTime promStart = Datetime.valueOf(mapfieldvalues.get('band.start'));
                band.start = WSCH_DateUtils.getSPDateTime(promStart);
            }
            if(mapfieldvalues.get('band.end') != null){
                DateTime promEnd = Datetime.valueOf(mapfieldvalues.get('band.end'));
                band.end_x = WSCH_DateUtils.getSPDateTime(promEnd);
            }           
            apptOfferReq.band = band;
             
            if(mapfieldvalues.get('importance') != null){
                integer importance = Integer.valueOf(mapfieldvalues.get('importance'));
                apptOfferReq.importance= String.valueOf(importance);
            }
                                    
            WSCH_Provider_SP_StubsV91.ApptOfferOfferOptions offerOptions = new WSCH_Provider_SP_StubsV91.ApptOfferOfferOptions();
            Boolean isOfferMapped = false;
            if(mapfieldvalues.get('offerOptions.AllowEmpOT') != null){
                offerOptions.AllowEmpOT = Boolean.valueOf(mapfieldvalues.get('offerOptions.AllowEmpOT'));
                isOfferMapped = true;
            }
            if(mapfieldvalues.get('offerOptions.OfferTextEmpID') != null){
                offerOptions.OfferTextEmpID = Boolean.valueOf(mapfieldvalues.get('offerOptions.OfferTextEmpID'));
                isOfferMapped = true;
            }                       
            if(mapfieldvalues.get('offerOptions.DupUseEmpID') != null){
                offerOptions.DupUseEmpID = Boolean.valueOf(mapfieldvalues.get('offerOptions.DupUseEmpID'));
                isOfferMapped = true;
            }                       
            if(mapfieldvalues.get('offerOptions.SpareIgnVanStock') != null){
                offerOptions.SpareIgnVanStock = Boolean.valueOf(mapfieldvalues.get('offerOptions.SpareIgnVanStock'));
                isOfferMapped = true;
            }
            if(mapfieldvalues.get('offerOptions.OfferTextCost') != null){
                offerOptions.OfferTextCost = Boolean.valueOf(mapfieldvalues.get('offerOptions.OfferTextCost'));
                isOfferMapped = true;
            }                       
            if(mapfieldvalues.get('offerOptions.NonConsecShift') != null){
                offerOptions.NonConsecShift = Boolean.valueOf(mapfieldvalues.get('offerOptions.NonConsecShift'));
                isOfferMapped = true;
            }                       
            if(mapfieldvalues.get('offerOptions.ConsecShift') != null){
                offerOptions.ConsecShift = Boolean.valueOf(mapfieldvalues.get('offerOptions.ConsecShift'));
                isOfferMapped = true;
            }
            if(mapfieldvalues.get('offerOptions.ContigShift') != null){
                offerOptions.ContigShift = Boolean.valueOf(mapfieldvalues.get('offerOptions.ContigShift'));
                isOfferMapped = true;
            }                       
            if(isOfferMapped)
                apptOfferReq.offerOptions = offerOptions;   
            
            WSCH_Provider_SP_StubsV91.ApptOfferForceOptions forceOptions = new WSCH_Provider_SP_StubsV91.ApptOfferForceOptions();
            Boolean isForceMapped = false;
            if(mapfieldvalues.get('forceOptions.InTray') != null){
                forceOptions.InTray = Boolean.valueOf(mapfieldvalues.get('forceOptions.InTray'));
                isForceMapped = true;
            }
            if(mapfieldvalues.get('forceOptions.InTrayWithSkill') != null){
                forceOptions.InTrayWithSkill = Boolean.valueOf(mapfieldvalues.get('forceOptions.InTrayWithSkill'));
                isForceMapped = true;
            }
            if(mapfieldvalues.get('forceOptions.SpareForceGo') != null){
                forceOptions.SpareForceGo = Boolean.valueOf(mapfieldvalues.get('forceOptions.SpareForceGo'));
                isForceMapped = true;
            }        
            if(mapfieldvalues.get('forceOptions.Reassign') != null){
                forceOptions.Reassign = Boolean.valueOf(mapfieldvalues.get('forceOptions.Reassign'));
                isForceMapped = true;
            }
            if(mapfieldvalues.get('forceOptions.IgnoreCapacity') != null){
                forceOptions.IgnoreCapacity = Boolean.valueOf(mapfieldvalues.get('forceOptions.IgnoreCapacity'));
                isForceMapped = true;
            }
            if(mapfieldvalues.get('forceOptions.NoTravel') != null){
                forceOptions.NoTravel = Boolean.valueOf(mapfieldvalues.get('forceOptions.NoTravel'));
                isForceMapped = true;
            }
            if(mapfieldvalues.get('forceOptions.NoLocalKnowledge') != null){
                forceOptions.NoLocalKnowledge = Boolean.valueOf(mapfieldvalues.get('forceOptions.NoLocalKnowledge'));
                isForceMapped = true;
            }
            if(isForceMapped)                               
                apptOfferReq.forceOptions = forceOptions;
            
            if(mapfieldvalues.get('deliverySize')!=null){
                apptOfferReq.deliverySize = Integer.valueOf(mapfieldvalues.get('deliverySize'));
            } 
            
            if(mapfieldvalues.get('pickupSize')!=null){
                apptOfferReq.pickupSize = Integer.valueOf(mapfieldvalues.get('pickupSize'));
            }                   
                        
            if(mapfieldvalues.get('siteID')!=null){
                apptOfferReq.siteID = String.valueOf(mapfieldvalues.get('siteID'));
            }
            
            if(mapfieldvalues.get('groupID')!=null){
                apptOfferReq.groupID = String.valueOf(mapfieldvalues.get('groupID'));
            }

            if(mapfieldvalues.get('capacityCategory')!=null){
                apptOfferReq.capacityCategory = String.valueOf(mapfieldvalues.get('capacityCategory'));
            }                           
            WSCH_AuditLogger.debug('WSCH_Provider_SP_DataMapper::mapApptOfferRequest:End mapping assignment..');
            WSCH_AuditLogger.debug('WSCH_Provider_SP_DataMapper::mapApptOfferRequest:customMap:request_x: ' + apptOfferReq);
        }
        
        if(apptOfferReq.numReq == null)
            apptOfferReq.numReq = size;
        
        if(apptOfferReq.numReqType == null)
            apptOfferReq.numReqType = WSCH_Constants.STR_NUM_REQ_TYPE;
        
        apptOfferReq.index = currentIndex;

        if(String.isBlank(apptOfferReq.jobType)) {
            apptOfferReq.jobType = WSCH_CommonUtils.getSettingValue('DCON004','SET002');
        }

        if(String.isBlank(apptOfferReq.postcode)) {
            apptOfferReq.postcode = workOrder.SVMXC__Zip__c;
        }

        if(String.isBlank(apptOfferReq.promSet)) {
            apptOfferReq.promSet = WSCH_CommonUtils.getSettingValue('DCON004','SET001');
        }

        if(String.isBlank(apptOfferReq.extraDuration)) {
            if(workOrder.SVMXC__Service_Duration__c != null) {
                apptOfferReq.extraDuration = ''+workOrder.SVMXC__Service_Duration__c.intvalue()/60;
            } /*else {
                apptOfferReq.extraDuration = '0';
                //this is a tentative fix to handle when service duration is not calculated during precalc
            }*/
        }

        WSCH_Provider_SP_StubsV91.ReqSkills extraSkills = new WSCH_Provider_SP_StubsV91.ReqSkills();
        extraSkills = fetchExtraSkills(workOrder);
        if(extraSkills.reqSkills != null && extraSkills.reqSkills.size()> 0 ){
            apptOfferReq.extraSkills=extraSkills;
        }

        /*WSCH_Provider_SP_StubsV91.ReqEmps reqEmps = new WSCH_Provider_SP_StubsV91.ReqEmps();
        reqEmps=fetchReqEmps(workOrder);
        if(reqEmps !=null){
            apptOfferReq.reqEmps=reqEmps;
        }*/
        
        /*WSCH_Provider_SP_StubsV91.ReqEmp reqEmp = new WSCH_Provider_SP_StubsV91.ReqEmp();
        List<WSCH_Provider_SP_StubsV91.ReqEmp> lstEmp = new List<WSCH_Provider_SP_StubsV91.ReqEmp>();
        reqEmp=fetchReqEmp(workOrder);
        if(reqEmp != null){
            lstEmp.add(reqEmp);
            WSCH_Provider_SP_StubsV91.ListReqEmps lstReqEmps = new WSCH_Provider_SP_StubsV91.ListReqEmps();
            lstReqEmps.reqEmp=lstEmp;
            apptOfferReq.listReqEmps=lstReqEmps;
        }*/
        //if(WORD_Service_Order_Resources.getResourcePreferenceSetting()){
            WSCH_Provider_SP_StubsV91.ListReqEmps lstReqEmps = new WSCH_Provider_SP_StubsV91.ListReqEmps();
            lstReqEmps = fetchListReqEmps(workOrder.id, workOrder.SVMXC__Preferred_Technician__r.SVMXC__Optimizer_External_ID__c);
            if(lstReqEmps != null){
                apptOfferReq.listReqEmps = lstReqEmps;
            }
       //}
        

        //Set offerTestCost to true is you want the response to include the cost of the slot.
        if(apptOfferReq.offerOptions == null){
            WSCH_Provider_SP_StubsV91.ApptOfferOfferOptions offerOptions = new WSCH_Provider_SP_StubsV91.ApptOfferOfferOptions();
            offerOptions.OfferTextCost = true;
            offerOptions.OfferTextEmpID = true;
            apptOfferReq.offerOptions = offerOptions;
        }
        
        
        if(apptOfferReq.start == null){
            WSCH_Provider_SP_StubsV91.DateOptTime startDate = new WSCH_Provider_SP_StubsV91.DateOptTime();
            DateTime startDateTime = DateTime.now();
            startDate.date_x = WSCH_DateUtils.getDateFromDT(startDateTime, strWOTimeZone, 'gmt');
            startDate.time_x = WSCH_DateUtils.getTimeFromDT(startDateTime, strWOTimeZone, 'gmt');
            apptOfferReq.start = startDate;
        }
        
        if(apptOfferReq.end_x == null){
            WSCH_Provider_SP_StubsV91.DateOptTime endDate = new WSCH_Provider_SP_StubsV91.DateOptTime();
            String strNoOfDaysInCalSetting;
            String strTempCalDaysSetting = WSCH_CommonUtils.getSettingValue('DCON003','SET008');
            if(strTempCalDaysSetting != null && String.isNotBlank(strTempCalDaysSetting)) {
                strNoOfDaysInCalSetting = strTempCalDaysSetting;
            } else {
                strNoOfDaysInCalSetting = '7';  /* Set 7 as default value if there is not setting value */
            }
            DateTime endDateTime = DateTime.now().addDays(Integer.valueOf(strNoOfDaysInCalSetting) - 1);
            endDate.date_x = WSCH_DateUtils.getDateFromDT(endDateTime, strWOTimeZone, 'gmt');
            //endDate.time_x = WSCH_DateUtils.getTimeFromDT(endDateTime, strWOTimeZone, 'gmt');
            endDate.time_x = '2400';    //hard coding this value to the last hour of the day, only for the enddate. This was done to fix 
            apptOfferReq.end_x = endDate;    //the issue where the current time component was considered even for the end
        }                                // date which used to restrict the appointment slots within that time frame
        
        //Resolves boundary dates for calendar view of offer appointments.
        WSCH_AuditLogger.debug('WSCH_Provider_SP_DataMapper::mapApptOfferRequest:: apptParamObj: '+apptParamObj);
        resolveOfferApptDates(apptOfferReq,workOrder,apptParamObj,strWOTimeZone);

        //WSCH_AuditLogger.debug('WSCH_Provider_SP_DataMapper::mapApptOfferRequest:finalMap:request_x: ' + apptOfferReq);
        
        return apptOfferReq;
    }
    

    public static void mapApptOfferResponse(WSCH_Provider_SP_StubsV91.ApptOfferResponse offerResponse, WSCH_AppointmentsResponse techSlotResponse){
        List<WSCH_Appointment> appointmentList = new List<WSCH_Appointment>();
        WSCH_Appointment techSlot;
        if(offerResponse !=null){
            if(WSCH_Provider_SP_ErrorCodesMapper.isSuccess(offerResponse.returnCode.code)){
                for(WSCH_Provider_SP_StubsV91.Offer slot : offerResponse.offers.offer){
                    techSlot=new WSCH_Appointment();
                    techSlot.setDay(slot.day);
                    techSlot.setTechExternalId(slot.empID);
                    techSlot.setEndDateTime(WSCH_DateUtils.parseSPDateTimeNew(slot.end_x));
                    techSlot.setFRU(slot.FRU);
                    techSlot.setIRU(slot.IRU);
                    techSlot.setDRU(slot.DRU);
                    techSlot.setOfferText(slot.offerText);
                    techSlot.setOfferToken(slot.offerToken);
                    techSlot.setPromBand(slot.promBand);
                    techSlot.setPromType(slot.promType);
                    //strStartDateTime used for list view. TODO: Need to modify in list view implementation and remove the value setting.
                    techSlot.setStrStartDateTime(slot.start);
                    //StartDateTime is used for calendar view.
                    techSlot.setStartDateTime(WSCH_DateUtils.parseSPDateTimeNew(slot.start));
                    techSlot.setTravelTime(slot.travelTime);
                    techSlot.setIntTimeZoneOffset(WSCH_DateUtils.getIntOffsetFromSPDate(slot.start));
                    appointmentList.add(techSlot);
                }
                updateApptByTechId(appointmentList);
                techSlotResponse.appointmentList = appointmentList;
                techSlotResponse.viewMore = offerResponse.offers.more;
            }
            techSlotResponse.statusCode = offerResponse.returnCode.code;
            techSlotResponse.statusMessage = WSCH_Provider_SP_ErrorCodesMapper.getStatusMsg(offerResponse.returnCode.code, WSCH_Provider_SP_ErrorCodesMapper.OFFER_APPT);
        }
    }

    /**
        Folloing mapper used to mapp the request of

         SP API.
    */
    public static WSCH_Provider_SP_StubsV91.ApptBookRequest mapApptBookRequest(SVMXC__Service_Order__c workOrder, WSCH_Appointment slot){

        WSCH_Provider_SP_StubsV91.ApptBookRequest request_x = new WSCH_Provider_SP_StubsV91.ApptBookRequest();
        request_x.login = fetchLoginInfo();

        //String strMapId = getSFMMappingId(WSCH_Constants.API_BOOK_APPT);
        //fetch the SFM Mapping Id as per the Work Order Connection Name
        String strMapId = getSpSFMMappingId(WSCH_Constants.API_BOOK_APPT, WSCH_Provider_SP_RealTimeOptimizer.mapWoConName.get(workOrder.Id));
        map<String,Object> mapfieldvalues = new map<String,Object>();
        if(String.isNotBlank(strMapId)) {
            WSCH_AuditLogger.debug('Start of getSmartObjectRecords(): No of Queries used in this transaction so far: ' + Limits.getQueries());
            mapfieldvalues = getSmartObjectRecords(strMapId, workOrder);
            WSCH_AuditLogger.debug('End of getSmartObjectRecords(): No of Queries used in this transaction so far: ' + Limits.getQueries());
            WSCH_AuditLogger.debug('WSCH_Provider_SP_DataMapper::mapApptBookRequest:mapfieldvalues: '+mapfieldvalues);
        }

         if(mapfieldvalues != null && mapfieldvalues.size() > 0){
            WSCH_AuditLogger.debug('WSCH_Provider_SP_DataMapper::mapApptBookRequest:Start mapping assignment..');

            /*if(mapfieldvalues.get('jobID') != null){
                request_x.jobID = String.valueOf(mapfieldvalues.get('jobID')); 
            }*/

            if(mapfieldvalues.get('jobType') != null){
                request_x.jobType = String.valueOf(mapfieldvalues.get('jobType'));
            }

            if(mapfieldvalues.get('postcode') != null){
                request_x.postcode = String.valueOf(mapfieldvalues.get('postcode'));
            }
                        
            if(mapfieldvalues.get('date') != null){
                request_x.date_x = String.valueOf(mapfieldvalues.get('date'));
            }
            
            if(mapfieldvalues.get('allowRebook') != null){
                request_x.allowRebook = Boolean.valueOf(mapfieldvalues.get('allowRebook'));
            }
                        
            if(mapfieldvalues.get('extraDuration')!=null){
                request_x.extraDuration = ''+Integer.valueOf(mapfieldvalues.get('extraDuration'));
            }
            
            if(mapfieldvalues.get('extraOverhead')!=null){
                request_x.extraOverhead = Integer.valueOf(mapfieldvalues.get('extraOverhead'));
            }
            
            if(mapfieldvalues.get('sameUnit')!=null){
                request_x.sameUnit = String.valueOf(mapfieldvalues.get('sameUnit'));
            }

            if(mapfieldvalues.get('stdExtraDuration')!=null){
                request_x.stdExtraDuration = String.valueOf(mapfieldvalues.get('stdExtraDuration'));
            }

            if(mapfieldvalues.get('bookLoc') != null){
                request_x.bookLoc = String.valueOf(mapfieldvalues.get('bookLoc'));
            }
                                    
            if(mapfieldvalues.get('priority') != null){
                integer priority = Integer.valueOf(mapfieldvalues.get('priority'));
                if(priority < 1) {
                    request_x.priority = String.ValueOf(WSCH_Constants.INT_DEFAULT_PRIORITY);
                } else if (priority > 99) {
                    request_x.priority = String.ValueOf(WSCH_Constants.INT_MAX_PRIORITY);
                } else {
                    request_x.priority = String.ValueOf(priority);
                }               
            }
            
            if(mapfieldvalues.get('importance') != null){
                integer importance = Integer.valueOf(mapfieldvalues.get('importance'));
                request_x.importance= String.valueOf(importance);
            }
            
            WSCH_Provider_SP_StubsV91.Band promBand = new WSCH_Provider_SP_StubsV91.Band();
            Boolean isPromBandMapped = false;
            if(mapfieldvalues.get('promBand.timeBandID') != null){
                promBand.timeBandID = String.valueOf(mapfieldvalues.get('promBand.timeBandID'));
                isPromBandMapped = true;
            }
            if(mapfieldvalues.get('promBand.start') != null){
                DateTime promStart = Datetime.valueOf(mapfieldvalues.get('promBand.start'));
                promBand.start = WSCH_DateUtils.getSPDateTime(promStart);
                isPromBandMapped = true;
            }
            if(mapfieldvalues.get('promBand.end') != null){
                DateTime promEnd = Datetime.valueOf(mapfieldvalues.get('promBand.end'));
                promBand.end_x = WSCH_DateUtils.getSPDateTime(promEnd);
                isPromBandMapped = true;
            }
            if(isPromBandMapped)        
                request_x.promBand = promBand;
                        
            WSCH_Provider_SP_StubsV91.ApptBookBookOptions bookOptions = new WSCH_Provider_SP_StubsV91.ApptBookBookOptions();
            Boolean isBookOptionsMapped = false;
            if(mapfieldvalues.get('bookOptions.AllowEmpOT') != null){
                bookOptions.AllowEmpOT = Boolean.valueOf(mapfieldvalues.get('bookOptions.AllowEmpOT'));
                isBookOptionsMapped = true;
            }
            if(mapfieldvalues.get('bookOptions.SpareIgnVanStock') != null){
                bookOptions.SpareIgnVanStock = Boolean.valueOf(mapfieldvalues.get('bookOptions.SpareIgnVanStock'));
                isBookOptionsMapped = true;
            }                       
            if(mapfieldvalues.get('bookOptions.ReqConfirm') != null){
                bookOptions.ReqConfirm = Boolean.valueOf(mapfieldvalues.get('bookOptions.ReqConfirm'));
                isBookOptionsMapped = true;
            }
            if(isBookOptionsMapped)                     
                request_x.bookOptions = bookOptions;
            
            WSCH_Provider_SP_StubsV91.ApptBookForceOptions forceOptions = new WSCH_Provider_SP_StubsV91.ApptBookForceOptions();
            Boolean isForceOptionsMapped = false;
            if(mapfieldvalues.get('forceOptions.InTray') != null){
                forceOptions.InTray = Boolean.valueOf(mapfieldvalues.get('forceOptions.InTray'));
                isForceOptionsMapped = true;
            }
            if(mapfieldvalues.get('forceOptions.InTrayWithSkill') != null){
                forceOptions.InTrayWithSkill = Boolean.valueOf(mapfieldvalues.get('forceOptions.InTrayWithSkill'));
                isForceOptionsMapped = true;
            }
            if(mapfieldvalues.get('forceOptions.SpareForceGo') != null){
                forceOptions.SpareForceGo = Boolean.valueOf(mapfieldvalues.get('forceOptions.SpareForceGo'));
                isForceOptionsMapped = true;
            }        
            if(mapfieldvalues.get('forceOptions.Reassign') != null){
                forceOptions.Reassign = Boolean.valueOf(mapfieldvalues.get('forceOptions.Reassign'));
                isForceOptionsMapped = true;
            }
            if(mapfieldvalues.get('forceOptions.IgnoreCapacity') != null){
                forceOptions.IgnoreCapacity = Boolean.valueOf(mapfieldvalues.get('forceOptions.IgnoreCapacity'));
                isForceOptionsMapped = true;
            }
            if(mapfieldvalues.get('forceOptions.NoTravel') != null){
                forceOptions.NoTravel = Boolean.valueOf(mapfieldvalues.get('forceOptions.NoTravel'));
                isForceOptionsMapped = true;
            }
            if(mapfieldvalues.get('forceOptions.NoLocalKnowledge') != null){
                forceOptions.NoLocalKnowledge = Boolean.valueOf(mapfieldvalues.get('forceOptions.NoLocalKnowledge'));
                isForceOptionsMapped = true;
            }
            if(isForceOptionsMapped)                                
                request_x.forceOptions = forceOptions;
            
            if(mapfieldvalues.get('deliverySize')!=null){
                request_x.deliverySize = Integer.valueOf(mapfieldvalues.get('deliverySize'));
            } 
            
            if(mapfieldvalues.get('pickupSize')!=null){
                request_x.pickupSize = Integer.valueOf(mapfieldvalues.get('pickupSize'));
            }                   
                        
            if(mapfieldvalues.get('siteID')!=null){
                request_x.siteID = String.valueOf(mapfieldvalues.get('siteID'));
            }
            
            if(mapfieldvalues.get('groupID')!=null){
                request_x.groupID = String.valueOf(mapfieldvalues.get('groupID'));
            }

            if(mapfieldvalues.get('capacityCategory')!=null){
                request_x.capacityCategory = String.valueOf(mapfieldvalues.get('capacityCategory'));
            }
            
            //mapping customer
            WSCH_Provider_SP_StubsV91.Customer customer = new WSCH_Provider_SP_StubsV91.Customer();
            Boolean isCustMapped = false;
            if(mapfieldvalues.get('customer.custID')!=null){
                customer.custID = String.valueOf(mapfieldvalues.get('customer.custID'));
                isCustMapped = true;
            }

            if(mapfieldvalues.get('customer.custName')!=null){
                customer.custName = String.valueOf(mapfieldvalues.get('customer.custName'));
                isCustMapped = true;
            }
            
            //mapping for customer address
            List<String> lstCustAddress = new List<String>();
            if(mapfieldvalues.get('customer.custAddress.1')!=null){
                lstCustAddress.add(String.valueOf(mapfieldvalues.get('customer.custAddress.1')));
                isCustMapped = true;
            }
            
            if(mapfieldvalues.get('customer.custAddress.2')!=null){
                lstCustAddress.add(String.valueOf(mapfieldvalues.get('customer.custAddress.2')));
                isCustMapped = true;
            }                               
            
            if(mapfieldvalues.get('customer.custAddress.3')!=null){
                lstCustAddress.add(String.valueOf(mapfieldvalues.get('customer.custAddress.3')));
                isCustMapped = true;
            }
            
            if(mapfieldvalues.get('customer.custAddress.4')!=null){
                lstCustAddress.add(String.valueOf(mapfieldvalues.get('customer.custAddress.4')));
                isCustMapped = true;
            }
            if(lstCustAddress.size() > 0)
                customer.custAddress = lstCustAddress;
                
            //customer contact mapping
            if(mapfieldvalues.get('customer.contactName')!=null){
                customer.contactName = String.valueOf(mapfieldvalues.get('customer.contactName'));
                isCustMapped = true;
            }
            
            //customer phone mapping
            List<String> lstPhone = new List<String>();
            if(mapfieldvalues.get('customer.phoneNum.1')!=null){
                lstPhone.add(String.valueOf(mapfieldvalues.get('customer.phoneNum.1')));
                isCustMapped = true;
            }
            if(mapfieldvalues.get('customer.phoneNum.2')!=null){
                lstPhone.add(String.valueOf(mapfieldvalues.get('customer.phoneNum.2')));
                isCustMapped = true;
            }
            customer.phoneNum = lstPhone;
            if(isCustMapped)
                request_x.customer = customer;
            
            List<String> lstDesc = new List<String>();
            if(mapfieldvalues.get('desc.1')!=null){
                String descStr = String.valueOf(mapfieldvalues.get('desc.1'));
                if(descStr.length() > 500){
                    descStr=descStr.substring(0, 499);
                }           
                lstDesc.add(descStr);
            }
            if(mapfieldvalues.get('desc.2')!=null){
                String descStr = String.valueOf(mapfieldvalues.get('desc.2'));
                if(descStr.length() > 500){
                    descStr=descStr.substring(0, 499);
                }           
                lstDesc.add(descStr);
            }
            if(mapfieldvalues.get('desc.3')!=null){
                String descStr = String.valueOf(mapfieldvalues.get('desc.3'));
                if(descStr.length() > 500){
                    descStr=descStr.substring(0, 499);
                }           
                lstDesc.add(descStr);
            }
            if(mapfieldvalues.get('desc.4')!=null){
                String descStr = String.valueOf(mapfieldvalues.get('desc.4'));
                if(descStr.length() > 500){
                    descStr=descStr.substring(0, 499);
                }           
                lstDesc.add(descStr);
            }           
            request_x.desc_x = lstDesc;   
                     
            /*if(mapfieldvalues.get('desc_x')!=null) {
                List<String> descList = new List<String>();
                String mainStr = String.valueOf(mapfieldvalues.get('desc_x'));
                //validate the max length(500) of the string for SP
                String[] descStr = mainStr.split('(?<=\\G.{499})');
                //only save first 4 elements of the list for SP
                for(Integer i=0; i < descStr.size(); i++) {
                   descList.add(descStr[i]);
                   if(i == 3) break;
                }
                request_x.desc_x=descList;
            }*/

            if(mapfieldvalues.get('desc2')!=null) {
                String descStr = String.valueOf(mapfieldvalues.get('desc2'));
                //validate the max lenth of the string for SP
                if(descStr.length() > 3500){
                    request_x.desc2=descStr.substring(0, 3499);
                } else {
                    request_x.desc2=descStr;
                }
            }            
            WSCH_AuditLogger.debug('WSCH_Provider_SP_DataMapper::mapApptBookRequest:End mapping assignment..');                     
            //WSCH_AuditLogger.debug('WSCH_Provider_SP_DataMapper::mapApptBookRequest:customMap:request_x: ' + request_x);
         }
        
        if(String.isBlank(request_x.jobID)) {
            request_x.jobID = WSCH_CommonUtils.getWorkItemId(WSCH_Constants.WORKORDER_OPTIMIZATION_ID_FIELD, workOrder);
        }

        if(String.isBlank(request_x.jobType)) {
            request_x.jobType = WSCH_CommonUtils.getSettingValue('DCON004','SET002');
        }

        if(String.isBlank(request_x.postcode)) {
            request_x.postcode = workOrder.SVMXC__Zip__c;
        }

        //Getting only Date Component from the stored DateTime String.
        request_x.date_x = slot.getStrStartDateTime().split('T',2)[0].trim();
        
        if(request_x.allowRebook == null)
            request_x.allowRebook = true;

        if(String.isBlank(request_x.extraDuration)) {
            if(workOrder.SVMXC__Service_Duration__c != null) {
                request_x.extraDuration = ''+workOrder.SVMXC__Service_Duration__c.intvalue()/60;
            } /*else {
                request_x.extraDuration = '0';
                //this is a tentative fix to handle when service duration is not calculated during precalc
            } */       
        }

        if(String.isBlank(request_x.priority)) {
            request_x.priority = resolveDispatchPriority(workOrder);
        }

        if(String.isBlank(request_x.importance)) {
            request_x.importance = WSCH_Constants.STR_IMPORTANCE;
        }

        request_x.offerToken = slot.getOfferToken();

        //set the promBand received in offerAppt response to respect the slot
        if(request_x.promBand == null){
            WSCH_Provider_SP_StubsV91.Band promBand = new WSCH_Provider_SP_StubsV91.Band();
            promBand.timeBandID = slot.getPromBand();
            request_x.promBand = promBand;
        }

        WSCH_Provider_SP_StubsV91.ReqSkills extraSkills = new WSCH_Provider_SP_StubsV91.ReqSkills();
        extraSkills = fetchExtraSkills(workOrder);
        if(extraSkills.reqSkills != null && extraSkills.reqSkills.size()> 0 ){
            request_x.extraSkills=extraSkills;
        }

        /*WSCH_Provider_SP_StubsV91.ReqEmps reqEmps = new WSCH_Provider_SP_StubsV91.ReqEmps();
        reqEmps=fetchReqEmps(workOrder);
        if(reqEmps !=null){
            request_x.reqEmps=reqEmps;
        }*/
        
        /*WSCH_Provider_SP_StubsV91.ReqEmp reqEmp = new WSCH_Provider_SP_StubsV91.ReqEmp();
        List<WSCH_Provider_SP_StubsV91.ReqEmp> lstEmp = new List<WSCH_Provider_SP_StubsV91.ReqEmp>();
        reqEmp=fetchReqEmp(workOrder);
        if(reqEmp != null){
            lstEmp.add(reqEmp);
            WSCH_Provider_SP_StubsV91.ListReqEmps lstReqEmps = new WSCH_Provider_SP_StubsV91.ListReqEmps();
            lstReqEmps.reqEmp=lstEmp;
            request_x.listReqEmps=lstReqEmps;
        }*/
        //if(WORD_Service_Order_Resources.getResourcePreferenceSetting()){
            WSCH_Provider_SP_StubsV91.ListReqEmps lstReqEmps = new WSCH_Provider_SP_StubsV91.ListReqEmps();
            lstReqEmps = fetchListReqEmps(workOrder.id, workOrder.SVMXC__Preferred_Technician__r.SVMXC__Optimizer_External_ID__c);
            if(lstReqEmps != null){
                request_x.listReqEmps = lstReqEmps;
            }
        //}
        
        if(workOrder.SVMXC__Site__c != null && String.isBlank(request_x.siteID))
        {
            //SVMXC__Site__c siteObj = getSiteBySiteId(workOrder.SVMXC__Site__c);
            //request_x.siteID = siteObj.Name;
            request_x.siteID = workOrder.SVMXC__Site__r.Name;
        }

        if(request_x.customer == null){
            WSCH_Provider_SP_StubsV91.Customer customer = new WSCH_Provider_SP_StubsV91.Customer();         
            /*Account objectAccount = getAccountFromCompanyId(workOrder.SVMXC__Company__c);
            if(objectAccount != null) {
                customer.custID = objectAccount.AccountNumber;
                customer.custName = objectAccount.Name;
            }*/
            
            customer.custID = workOrder.SVMXC__Company__r.AccountNumber;
            customer.custName = workOrder.SVMXC__Company__r.Name;
    
            List<String> lstCustAddress = new List<String>();
            lstCustAddress.add(workOrder.SVMXC__Street__c);
            lstCustAddress.add(workOrder.SVMXC__City__c);
            lstCustAddress.add(workOrder.SVMXC__State__c);
            lstCustAddress.add(workOrder.SVMXC__Country__c);
            customer.custAddress = lstCustAddress;
    
       
            if(String.isNotEmpty(workOrder.SVMXC__Contact__r.FirstName) && String.isNotEmpty(workOrder.SVMXC__Contact__r.LastName)) {
                customer.contactName = workOrder.SVMXC__Contact__r.FirstName + ' ' + workOrder.SVMXC__Contact__r.LastName;
            } else if(String.isNotEmpty(workOrder.SVMXC__Contact__r.FirstName)) {
                customer.contactName = workOrder.SVMXC__Contact__r.FirstName ;
            } else if(String.isNotEmpty(workOrder.SVMXC__Contact__r.LastName)) {
                customer.contactName = workOrder.SVMXC__Contact__r.LastName;
            }
            List<String> lstPhone = new List<String>();
            //lstPhone.add(workOrder.SVMXC__WOContact_sPhNum__c);
            lstPhone.add(workOrder.SVMXC__Contact__r.Phone);
            customer.phoneNum = lstPhone;
            
            request_x.customer = customer;
        }

        //WSCH_AuditLogger.debug('WSCH_Provider_SP_DataMapper::mapApptBookRequest:finalMap:request_x: ' + request_x);

        return request_x;
    }

    /**
        Folloing mapper used to mapp the response of BookAppt SP API.
    */
    public static void mapApptBookResponse(WSCH_Provider_SP_StubsV91.ApptBookResponse bookResponse, WSCH_AppointmentsResponse techSlotResponse,SVMXC__Service_Order__c workOrder){
        List<WSCH_Appointment> appointmentList = new List<WSCH_Appointment>();
        WSCH_Appointment techSlot;
        String territoryId = '';
        if(bookResponse !=null){
            techSlot = new WSCH_Appointment();
            if(bookResponse.bookInfo != null) {
                if(bookResponse.bookInfo.empID != null) {
                    techSlot.setTechExternalId(bookResponse.bookInfo.empID);
                }
                if(bookResponse.bookInfo.FRU != null) {
                    techSlot.setFRU(bookResponse.bookInfo.FRU);
                    //update the workorder primary territory from the bookAppt response
                    //String territoryId = WSCH_CommonUtils.fetchTerritoryIdByExternalId(bookResponse.bookInfo.FRU);
                    //retrieve the territoryId based on the optimizerExternalId frm the map that is populated earlier in static block
                    territoryId = mapOfOptExtIdAndTerritoryId.get(bookResponse.bookInfo.FRU);
                    WSCH_AuditLogger.debug('WSCH_Provider_SP_DataMapper:: mapApptBookResponse(): territoryId - ' + territoryId);
                    workOrder.SVMXC__Primary_Territory__c=territoryId;
                    workOrder.SVMXC__Service_Zone_ID__c=bookResponse.bookInfo.FRU;
                }
                if(bookResponse.bookInfo.IRU != null) {
                    techSlot.setIRU(bookResponse.bookInfo.IRU);
                }
            }
            WSCH_Provider_SP_StubsV91.ReturnCode returnCode = bookResponse.return_x;
            techSlotResponse.statusCode = returnCode.code;
            techSlotResponse.statusMessage = returnCode.errNote;
            appointmentList.add(techSlot);
            techSlotResponse.appointmentList = appointmentList;
            String errorText = 'Return Code:' + returnCode.code + ' | Return Type:' + returnCode.type_x + ' | Return Note:' + returnCode.errNote + ' | Return Msg:' + WSCH_Provider_SP_ErrorCodesMapper.getStatusMsg(returnCode.code);
            WSCH_CommonUtils.setOptimizerErrorText(workOrder, errorText);
            //update the workorder status and error text if territory not configured in servicemax side.
            if(null == workOrder.SVMXC__Primary_Territory__c){
                workOrder.SVMXC__OptiMax_Status__c = WSCH_Constants.STATUS_OPT_DATA_SYNC_ERROR;
                errorText = 'Workorder is scheduled for a Territory is not configured in ServiceMax side. Please create/update territory with external Id -'+bookResponse.bookInfo.FRU;
                WSCH_CommonUtils.setOptimizerErrorText(workOrder, errorText);
            }
            
            if(!WSCH_Provider_SP_ErrorCodesMapper.isSuccess(returnCode.code)) {
                //if book appointment is not successful, delete the new slot info stored in apptPromiseSlot and copy the old booking info
                //if there is already any previous appt for this WO.
                if(String.isNotBlank(WSCH_Provider_SP_Appointments_Calendar.strOldApptPromiseSlot)) {
                    workOrder.SVMXC__Appointment_Promised_Time_Slot__c = WSCH_Provider_SP_Appointments_Calendar.strOldApptPromiseSlot;
                }
                
                //if book appointment is not successful, delete the new slot info stored in bookedAppointmentSlot 
                //and copy the old booking info if there is already any previous appt for this WO.
                if(String.isNotBlank(WSCH_Provider_SP_Appointments_Calendar.strOldApptBookedSlot)) {
                    workOrder.SVMXC__Booked_Appointment_Slot__c = WSCH_Provider_SP_Appointments_Calendar.strOldApptBookedSlot;
                }
            }
            //If Successful Callout Set the Work Order Connection Name Field with the SP Connection Name
            if(WSCH_Provider_SP_ErrorCodesMapper.isSuccess(returnCode.code)) {
                if(!WSCH_Provider_SP_RealTimeOptimizer.mapWoConName.isEmpty()){
                    workOrder.SVMXC__Optimizer_Connection_Name__c = workOrder.SVMXC__Optimizer_Connection_Name__c == null?WSCH_Provider_SP_RealTimeOptimizer.mapWoConName.get(workOrder.Id):workOrder.SVMXC__Optimizer_Connection_Name__c;
                }
                //update Territory record Connection Name
                if(String.isNotBlank(territoryId)){
                    SVMXC__Territory__c territory = mapOfTerritoryIdAndTerritoryObj.get(Id.valueOf(territoryId));
                    if((territory.SVMXC__Optimizer_Connection_Name__c == null) || (String.isBlank(territory.SVMXC__Optimizer_Connection_Name__c))){
                        territory.SVMXC__Optimizer_Connection_Name__c = workOrder.SVMXC__Optimizer_Connection_Name__c;
                        //Database.update(territory);
                        WSCH_Provider_SP_RealTimeOptimizer.lstTerrUpd.add(territory);
                    }
                }
            }
        }
    }

    /**
        This method creates a ChangeWorkItemStatusRequest mapper
    **/
    public static WSCH_Provider_SP_StubsV91.ChangeWorkItemStatusRequest mapWorkItemStatusChange(SVMXC__Service_Order__c workOrder,
                                                        String woStatus,Datetime updateDateTime) {
        WSCH_Provider_SP_StubsV91.ChangeWorkItemStatusRequest request_x = new WSCH_Provider_SP_StubsV91.ChangeWorkItemStatusRequest();

        WSCH_Provider_SP_StubsV91.WorkItemStatusChange workItemStatusChange = new WSCH_Provider_SP_StubsV91.WorkItemStatusChange();
        workItemStatusChange.workItemType = WSCH_Constants.STR_WORKITEM_TYPE;
        workItemStatusChange.workItemID = WSCH_CommonUtils.getWorkItemId(WSCH_Constants.WORKORDER_OPTIMIZATION_ID_FIELD, workOrder);
        workItemStatusChange.newStatus = woStatus;
        workItemStatusChange.dateTime_x = WSCH_DateUtils.getSPDateTime(updateDateTime);
        request_x.login = fetchLoginInfo();
        request_x.workItemStatusChange = workItemStatusChange;
        return request_x;
    }

    /**
        This method creates a GetJobStatusRequest mapper
    **/
    public static WSCH_Provider_SP_StubsV91.GetJobStatusRequest mapGetJobStatusRequest(SVMXC__Service_Order__c workOrder) {

        WSCH_Provider_SP_StubsV91.GetJobStatusRequest request_x = new WSCH_Provider_SP_StubsV91.GetJobStatusRequest();
        request_x.jobID = WSCH_CommonUtils.getWorkItemId(WSCH_Constants.WORKORDER_OPTIMIZATION_ID_FIELD, workOrder);
        request_x.login = fetchLoginInfo();
        return request_x;
    }
    
    /**
        This method creates a ActTypeFindFromDesc Request mapper
    **/
    public static WSCH_Provider_SP_StubsV91.ActTypeFindFromDescRequest mapActTypeFindFromDescRequest(SVMXC__SVMX_Optimizer__c event) {
        
        WSCH_Provider_SP_StubsV91.ActTypeFindFromDescRequest request_x = new WSCH_Provider_SP_StubsV91.ActTypeFindFromDescRequest();
        request_x.login = fetchLoginInfo();
        
        if(WSCH_CommonUtils.isSVMXEvent(event)) {
            SVMXC__SVMX_Event__c SVMXEvent = WSCH_CommonUtils.fetchSVMXEventObjectById(event.SVMXC__WhatId__c);
            WSCH_AuditLogger.debug('SFEvent.SVMXC__Type__c - ' + SVMXEvent.SVMXC__Type__c);
            if(SVMXEvent.SVMXC__Type__c != null && SVMXEvent.SVMXC__Type__c != 'null') {
                WSCH_AuditLogger.debug('Inside If() SFEvent.SVMXC__Type__c - ' + SVMXEvent.SVMXC__Type__c);
                request_x.Desc_x = SVMXEvent.SVMXC__Type__c;
            }
        } else if (WSCH_CommonUtils.isSFEvent(event)) {

            Event SFEvent = WSCH_CommonUtils.fetchSFEventObjectById(event.SVMXC__WhatId__c);
            WSCH_AuditLogger.debug('SFEvent.Type - ' + SFEvent.Type);
            if(SFEvent.Type != null && SFEvent.Type != 'null') {
                WSCH_AuditLogger.debug('Inside If() SFEvent.Type - ' + SFEvent.Type);
                request_x.Desc_x = SFEvent.Type;
            }
        }
        return request_x;
    }
    
    /**
        This method creates a ActTypeFindFromDesc Response mapper
    **/
    public static String getActTypeFindFromDescResponse(WSCH_Provider_SP_StubsV91.ActTypeFindFromDescResponse response) {
        
        String strActTypeNum;
        if(response != null && response.result != null) {
            WSCH_Provider_SP_StubsV91.ReturnCode returnCode = response.result;
            //based on the response code set the appropriate message on the WO Optimax status.
            if(WSCH_Provider_SP_ErrorCodesMapper.isSuccess(returnCode.code)) {
                strActTypeNum = response.ActTypeNum;
            } 
        }
        return strActTypeNum;
    }

    /**
        This method maps and create a EmpAddActRequest object.
    */
    public static WSCH_Provider_SP_StubsV91.EmpAddActRequest mapEmpAddActRequest(SVMXC__SVMX_Optimizer__c event) {

        WSCH_Provider_SP_StubsV91.EmpAddActRequest empAddActReq = new WSCH_Provider_SP_StubsV91.EmpAddActRequest();
        empAddActReq.login = fetchLoginInfo();
        //empAddActReq.actType = WSCH_Constants.STR_ACTTYPE;
        //empAddActReq.Dispatch=true;
        empAddActReq.locType = WSCH_Constants.STR_LOCTYPE;
        WSCH_Provider_SP_StubsV91.ActOptions options = new WSCH_Provider_SP_StubsV91.ActOptions();
        options.CheckJobsShuffle = true;
        empAddActReq.options = options;

        if(WSCH_CommonUtils.isSVMXEvent(event)) {

            SVMXC__SVMX_Event__c SVMXEvent = WSCH_CommonUtils.fetchSVMXEventObjectById(event.SVMXC__WhatId__c);
            SVMXC__Service_Group_Members__c technician = WSCH_CommonUtils.fetchTechnicianById(SVMXEvent.SVMXC__Technician__c);
            empAddActReq.empID = technician.SVMXC__Optimizer_External_ID__c;
            empAddActReq.expectedStart = formatNonWODateTime(technician,SVMXEvent.SVMXC__StartDateTime__c);
            if(SVMXEvent.SVMXC__DurationInMinutes__c != null) {
                empAddActReq.Duration = String.valueOf(SVMXEvent.SVMXC__DurationInMinutes__c);
            } else {
                empAddActReq.expectedEnd = formatNonWODateTime(technician,SVMXEvent.SVMXC__EndDateTime__c);
            }
        } else if (WSCH_CommonUtils.isSFEvent(event)) {

            Event SFEvent = WSCH_CommonUtils.fetchSFEventObjectById(event.SVMXC__WhatId__c);
            SVMXC__Service_Group_Members__c technician = WSCH_CommonUtils.fetchSFUserTechnicianId(SFEvent.OwnerId);
            empAddActReq.empID = technician.SVMXC__Optimizer_External_ID__c;
            empAddActReq.expectedStart = formatNonWODateTime(technician,SFEvent.StartDateTime);
            if(SFEvent.DurationInMinutes != null) {
                empAddActReq.Duration = String.valueOf(SFEvent.DurationInMinutes);
            } else {
                empAddActReq.expectedEnd = formatNonWODateTime(technician,SFEvent.EndDateTime);
            }
        }

/*       empAddActReq.locPostcode = locPostcode;
         empAddActReq.notes = notes;
         empAddActReq.TZType = TZType;
         empAddActReq.Dispatch = Dispatch;
         empAddActReq.TravelMode = TravelMode;
         empAddActReq.expectedEnd = expectedEnd; */
         return empAddActReq;
    }

    /**
        Following method maps the EmpAddActResponse to non work order events.
    */
    public static void  mapEmpAddActResponse(WSCH_Provider_SP_StubsV91.EmpAddActResponse response,SVMXC__SVMX_Optimizer__c event) {
        if(response != null && response.result != null) {
             WSCH_Provider_SP_StubsV91.ReturnCode returnCode = response.result;
            //based on the response code set the appropriate message on the WO Optimax status.
            if(WSCH_Provider_SP_ErrorCodesMapper.isSuccess(returnCode.code)) {
                event.SVMXC__Optimizer_Status__c = WSCH_Constants.STATUS_OPT_COMPLETED;
                event.SVMXC__Optimizer_External_Id__c = response.actID;
            } else {
                event.SVMXC__Optimizer_Status__c = WSCH_CommonUtils.resolveOptimaxStatus(event.SVMXC__Optimizer_Status__c, 'OPT_ERROR');
            }
            event.SVMXC__Optimizer_Error_Text__c = 'Return Code:' + returnCode.code + ' | Return Type:' + returnCode.type_x + ' | Return Note:' + returnCode.errNote + ' | Return Msg:' + WSCH_Provider_SP_ErrorCodesMapper.getStatusMsg(returnCode.code);
        }
    }

    /**
        This method maps and create a ActDeleteRequest object.
    */
    public static WSCH_Provider_SP_StubsV91.ActDeleteRequest mapActDeleteRequest(SVMXC__SVMX_Optimizer__c event) {

        WSCH_Provider_SP_StubsV91.ActDeleteRequest empActDelReq = new WSCH_Provider_SP_StubsV91.ActDeleteRequest();
        empActDelReq.login = fetchLoginInfo();
        empActDelReq.actID=event.SVMXC__Optimizer_External_Id__c;
        return empActDelReq;
    }

    /**
        Following method marks the ActDelete to non work order events.
    */
    public static void  mapActDeleteResponse(WSCH_Provider_SP_StubsV91.StandardResponse response,SVMXC__SVMX_Optimizer__c event) {
        if(response != null && response.result != null) {
             WSCH_Provider_SP_StubsV91.ReturnCode returnCode = response.result;
            //based on the response code set the appropriate message on the WO Optimax status.
            if(WSCH_Provider_SP_ErrorCodesMapper.isSuccess(returnCode.code)) {
                event.SVMXC__Optimizer_Status__c = WSCH_Constants.STATUS_OPT_COMPLETED;
            } else {
                event.SVMXC__Optimizer_Status__c = WSCH_CommonUtils.resolveOptimaxStatus(event.SVMXC__Optimizer_Status__c, 'OPT_ERROR');
            }
            event.SVMXC__Optimizer_Error_Text__c = 'Return Code:' + returnCode.code + ' | Return Type:' + returnCode.type_x + ' | Return Note:' + returnCode.errNote + ' | Return Msg:' + WSCH_Provider_SP_ErrorCodesMapper.getStatusMsg(returnCode.code);
        }
    }

      /**
        This method maps and create a ActUpdateRequest object.
    */
    public static WSCH_Provider_SP_StubsV91.ActUpdateRequest mapActUpdateRequest(SVMXC__SVMX_Optimizer__c event) {

        WSCH_Provider_SP_StubsV91.ActUpdateRequest empActUpdateReq = new WSCH_Provider_SP_StubsV91.ActUpdateRequest();
        empActUpdateReq.login = fetchLoginInfo();
        WSCH_Provider_SP_StubsV91.ActOptions options = new WSCH_Provider_SP_StubsV91.ActOptions();
        options.CheckJobsShuffle = true;
        empActUpdateReq.options = options;
        if(WSCH_CommonUtils.isSVMXEvent(event)) {

            SVMXC__SVMX_Event__c SVMXEvent = WSCH_CommonUtils.fetchSVMXEventObjectById(event.SVMXC__WhatId__c);
            SVMXC__Service_Group_Members__c technician = WSCH_CommonUtils.fetchTechnicianById(SVMXEvent.SVMXC__Technician__c);
            empActUpdateReq.actID=event.SVMXC__Optimizer_External_Id__c;
            empActUpdateReq.expectedStart =  formatNonWODateTime(technician, SVMXEvent.SVMXC__StartDateTime__c);
            if(SVMXEvent.SVMXC__DurationInMinutes__c != null) {
                empActUpdateReq.Duration = String.valueOf(SVMXEvent.SVMXC__DurationInMinutes__c);
            } else {
                empActUpdateReq.expectedEnd = formatNonWODateTime(technician,SVMXEvent.SVMXC__EndDateTime__c);
            }
        } else if (WSCH_CommonUtils.isSFEvent(event)) {

            Event SFEvent = WSCH_CommonUtils.fetchSFEventObjectById(event.SVMXC__WhatId__c);
            SVMXC__Service_Group_Members__c technician = WSCH_CommonUtils.fetchSFUserTechnicianId(SFEvent.OwnerId);
            empActUpdateReq.actID = event.SVMXC__Optimizer_External_ID__c;
            empActUpdateReq.expectedStart = formatNonWODateTime(technician,SFEvent.StartDateTime);
            if(SFEvent.DurationInMinutes != null) {
                empActUpdateReq.Duration = String.valueOf(SFEvent.DurationInMinutes);
            } else {
                empActUpdateReq.expectedEnd = formatNonWODateTime(technician,SFEvent.EndDateTime);
            }
        }
        return empActUpdateReq;
    }

      /**
        Following method maps the ActUpdate responce to non work order events.
    */
    public static void  mapActUpdateResponse(WSCH_Provider_SP_StubsV91.ReturnCode response,SVMXC__SVMX_Optimizer__c event) {
        WSCH_Provider_SP_StubsV91.ReturnCode returnCode = response;
        //based on the response code set the appropriate message on the WO Optimax status.
        if(returnCode !=null) {
           if(WSCH_Provider_SP_ErrorCodesMapper.isSuccess(returnCode.code)) {
             event.SVMXC__Optimizer_Status__c = WSCH_Constants.STATUS_OPT_COMPLETED;
           } else {
             event.SVMXC__Optimizer_Status__c = WSCH_CommonUtils.resolveOptimaxStatus(event.SVMXC__Optimizer_Status__c, 'OPT_ERROR');
         }
          event.SVMXC__Optimizer_Error_Text__c = 'Return Code:' + returnCode.code + ' | Return Type:' + returnCode.type_x + ' | Return Note:' + returnCode.errNote + ' | Return Msg:' + WSCH_Provider_SP_ErrorCodesMapper.getStatusMsg(returnCode.code);
        }

     }

    /**
        Following method maps and create JobUpdateRequest from work order.
    */
    public static  WSCH_Provider_SP_StubsV91.JobUpdateRequest mapUpdateJobRequest (SVMXC__Service_Order__c workOrder) {

        WSCH_Provider_SP_StubsV91.JobUpdateRequest jobUpdateRequest = new WSCH_Provider_SP_StubsV91.JobUpdateRequest();
        jobUpdateRequest.login = fetchLoginInfo();

        //String strMapId = getSFMMappingId(WSCH_Constants.API_UPDATE_JOB);
        //fetch the SFM Mapping Id as per the Work Order Connection Name
        String strMapId = getSpSFMMappingId(WSCH_Constants.API_UPDATE_JOB, WSCH_Provider_SP_RealTimeOptimizer.mapWoConName.get(workOrder.Id));
        map<String,Object> mapfieldvalues = new map<String,Object>();
        if(String.isNotBlank(strMapId)) {
            mapfieldvalues = getSmartObjectRecords(strMapId, workOrder);
            WSCH_AuditLogger.debug('WSCH_Provider_SP_DataMapper::mapUpdateJobRequest:mapfieldvalues: '+mapfieldvalues);
        }

        if(mapfieldvalues != null && mapfieldvalues.size() > 0){
            WSCH_AuditLogger.debug('WSCH_Provider_SP_DataMapper::mapUpdateJobRequest:Start assignment..');
            
            /*if(mapfieldvalues.get('jobID') != null){
                jobUpdateRequest.jobID = String.valueOf(mapfieldvalues.get('jobID'));
            }*/
            
            if(mapfieldvalues.get('priority') != null){
                integer priority = Integer.valueOf(mapfieldvalues.get('priority'));
                if(priority < 1) {
                    jobUpdateRequest.priority = String.ValueOf(WSCH_Constants.INT_DEFAULT_PRIORITY);
                } else if (priority > 99) {
                    jobUpdateRequest.priority = String.ValueOf(WSCH_Constants.INT_MAX_PRIORITY);
                } else {
                    jobUpdateRequest.priority = String.ValueOf(priority);
                }               
            }

            if(mapfieldvalues.get('importance') != null){
                integer importance = Integer.valueOf(mapfieldvalues.get('importance'));
                jobUpdateRequest.importance= String.valueOf(importance);
            }
 
            if(mapfieldvalues.get('checkEmp') != null){
                jobUpdateRequest.checkEmp = String.valueOf(mapfieldvalues.get('checkEmp'));
            }
                                
            //mapping customer
            WSCH_Provider_SP_StubsV91.Customer customer = new WSCH_Provider_SP_StubsV91.Customer();
            Boolean isCustMapped = false;
            if(mapfieldvalues.get('customer.custID')!=null){
                customer.custID = String.valueOf(mapfieldvalues.get('customer.custID'));
                isCustMapped = true;
            }

            if(mapfieldvalues.get('customer.custName')!=null){
                customer.custName = String.valueOf(mapfieldvalues.get('customer.custName'));
                isCustMapped = true;
            }
            
            //mapping for customer address
            List<String> lstCustAddress = new List<String>();
            if(mapfieldvalues.get('customer.custAddress.1')!=null){
                lstCustAddress.add(String.valueOf(mapfieldvalues.get('customer.custAddress.1')));
                isCustMapped = true;
            }
            
            if(mapfieldvalues.get('customer.custAddress.2')!=null){
                lstCustAddress.add(String.valueOf(mapfieldvalues.get('customer.custAddress.2')));
                isCustMapped = true;
            }                               
            
            if(mapfieldvalues.get('customer.custAddress.3')!=null){
                lstCustAddress.add(String.valueOf(mapfieldvalues.get('customer.custAddress.3')));
                isCustMapped = true;
            }
            
            if(mapfieldvalues.get('customer.custAddress.4')!=null){
                lstCustAddress.add(String.valueOf(mapfieldvalues.get('customer.custAddress.4')));
                isCustMapped = true;
            }
            if(lstCustAddress.size() > 0)
                customer.custAddress = lstCustAddress;
                
            //customer contact mapping
            if(mapfieldvalues.get('customer.contactName')!=null){
                customer.contactName = String.valueOf(mapfieldvalues.get('customer.contactName'));
                isCustMapped = true;
            }
            
            //customer phone mapping
            List<String> lstPhone = new List<String>();
            if(mapfieldvalues.get('customer.phoneNum.1')!=null){
                lstPhone.add(String.valueOf(mapfieldvalues.get('customer.phoneNum.1')));
                isCustMapped = true;
            }
            if(mapfieldvalues.get('customer.phoneNum.2')!=null){
                lstPhone.add(String.valueOf(mapfieldvalues.get('customer.phoneNum.2')));
                isCustMapped = true;
            }
            customer.phoneNum = lstPhone;
            if(isCustMapped)
                jobUpdateRequest.customer = customer;
            
            WSCH_Provider_SP_StubsV91.JobUpdateOptions options = new WSCH_Provider_SP_StubsV91.JobUpdateOptions();
            Boolean isOptionsMapped = false;
            if(mapfieldvalues.get('options.FixtoEmp') != null){
                options.FixtoEmp = Boolean.valueOf(mapfieldvalues.get('options.FixtoEmp'));
                isOptionsMapped = true;
            }
            if(mapfieldvalues.get('options.UseAccessHours') != null){
                options.UseAccessHours = Boolean.valueOf(mapfieldvalues.get('options.UseAccessHours'));
                isOptionsMapped = true;
            }                       
            if(mapfieldvalues.get('options.SetNotFixed') != null){
                options.SetNotFixed = Boolean.valueOf(mapfieldvalues.get('options.SetNotFixed'));
                isOptionsMapped = true;
            }  
            if(mapfieldvalues.get('options.SetUnEarmark') != null){
                options.SetUnEarmark = Boolean.valueOf(mapfieldvalues.get('options.SetUnEarmark'));
                isOptionsMapped = true;
            }
            if(mapfieldvalues.get('options.SetDispStatusBack') != null){
                options.SetDispStatusBack = Boolean.valueOf(mapfieldvalues.get('options.SetDispStatusBack'));
                isOptionsMapped = true;
            }                       
            if(mapfieldvalues.get('options.SetConfirmed') != null){
                options.SetConfirmed = Boolean.valueOf(mapfieldvalues.get('options.SetConfirmed'));
                isOptionsMapped = true;
            } 
            if(mapfieldvalues.get('options.RemoveMandatory') != null){
                options.RemoveMandatory = Boolean.valueOf(mapfieldvalues.get('options.RemoveMandatory'));
                isOptionsMapped = true;
            }
            if(isOptionsMapped)                                                         
                jobUpdateRequest.options = options;
            WSCH_AuditLogger.debug('WSCH_Provider_SP_DataMapper::mapUpdateJobRequest:End assignment..');            
            //WSCH_AuditLogger.debug('WSCH_Provider_SP_DataMapper::mapUpdateJobRequest:customMap:request_x: ' + jobUpdateRequest);
        }        
        
        if(String.isBlank(jobUpdateRequest.jobID)) {
            jobUpdateRequest.jobID = WSCH_CommonUtils.getWorkItemId(WSCH_Constants.WORKORDER_OPTIMIZATION_ID_FIELD, workOrder); 
        }
        
        if(String.isBlank(jobUpdateRequest.priority)) {
            jobUpdateRequest.priority = resolveDispatchPriority(workOrder); 
        }
        
        if(jobUpdateRequest.customer == null){
            WSCH_Provider_SP_StubsV91.Customer customer = new WSCH_Provider_SP_StubsV91.Customer();         
            /*Account objectAccount = getAccountFromCompanyId(workOrder.SVMXC__Company__c);
            if(objectAccount != null) {
                customer.custID = objectAccount.AccountNumber;
                customer.custName = objectAccount.Name;
            }*/
            
            customer.custID = workOrder.SVMXC__Company__r.AccountNumber;
            customer.custName = workOrder.SVMXC__Company__r.Name;
    
            List<String> lstCustAddress = new List<String>();
            lstCustAddress.add(workOrder.SVMXC__Street__c);
            lstCustAddress.add(workOrder.SVMXC__City__c);
            lstCustAddress.add(workOrder.SVMXC__State__c);
            lstCustAddress.add(workOrder.SVMXC__Country__c);
            customer.custAddress = lstCustAddress;
    
            /*Contact objectContact = getContactFromContactId(workOrder.SVMXC__Contact__c);
            if(objectContact != null) {
                if(String.isNotEmpty(objectContact.FirstName) && String.isNotEmpty(objectContact.LastName)) {
                    customer.contactName = objectContact.FirstName + ' ' + objectContact.LastName;
                } else if(String.isNotEmpty(objectContact.FirstName)) {
                    customer.contactName = objectContact.FirstName ;
                } else if(String.isNotEmpty(objectContact.LastName)) {
                    customer.contactName = objectContact.LastName;
                }
                List<String> lstPhone = new List<String>();
                lstPhone.add(objectContact.Phone);
                customer.phoneNum = lstPhone;
            }*/
            
            if(String.isNotEmpty(workOrder.SVMXC__Contact__r.FirstName) && String.isNotEmpty(workOrder.SVMXC__Contact__r.LastName)) {
                customer.contactName = workOrder.SVMXC__Contact__r.FirstName + ' ' + workOrder.SVMXC__Contact__r.LastName;
            } else if(String.isNotEmpty(workOrder.SVMXC__Contact__r.FirstName)) {
                customer.contactName = workOrder.SVMXC__Contact__r.FirstName ;
            } else if(String.isNotEmpty(workOrder.SVMXC__Contact__r.LastName)) {
                customer.contactName = workOrder.SVMXC__Contact__r.LastName;
            }
            List<String> lstPhone = new List<String>();
            lstPhone.add(workOrder.SVMXC__Contact__r.Phone);
            customer.phoneNum = lstPhone;
            
            jobUpdateRequest.customer = customer;
        }        

        //WSCH_AuditLogger.debug('WSCH_Provider_SP_DataMapper::mapUpdateJobRequest:finalMap:request_x: ' + jobUpdateRequest);

        return jobUpdateRequest;
    }

      /**
        Following method maps and create JobUpdateRequest for Unfix from work order.
    */
    public static  WSCH_Provider_SP_StubsV91.JobUpdateRequest mapUnfixJobRequest (SVMXC__Service_Order__c workOrder) {

        WSCH_Provider_SP_StubsV91.JobUpdateRequest jobUpdateRequest = new WSCH_Provider_SP_StubsV91.JobUpdateRequest();
        jobUpdateRequest.login = fetchLoginInfo();
        jobUpdateRequest.jobID = WSCH_CommonUtils.getWorkItemId(WSCH_Constants.WORKORDER_OPTIMIZATION_ID_FIELD, workOrder);
        jobUpdateRequest.priority = resolveDispatchPriority(workOrder);
        if(String.isNotBlank(workOrder.SVMXC__Contact__r.Name)) {
            WSCH_Provider_SP_StubsV91.Customer customer = new WSCH_Provider_SP_StubsV91.Customer();
            customer.custID = workOrder.SVMXC__Contact__c;
            customer.custName = workOrder.SVMXC__Contact__r.Name;
            jobUpdateRequest.customer = customer;
        }
        jobUpdateRequest.options = new WSCH_Provider_SP_StubsV91.JobUpdateOptions();
        jobUpdateRequest.options.SetNotFixed = true;

        return jobUpdateRequest;
    }

    /**
        Following creats and maps cancel job request from Work order.
    */
    public static WSCH_Provider_SP_StubsV91.JobCancelRequest mapCancelJobRequest (SVMXC__Service_Order__c workOrder) {

        WSCH_Provider_SP_StubsV91.JobCancelRequest cancelJobRequest = new WSCH_Provider_SP_StubsV91.JobCancelRequest();
        cancelJobRequest.login = fetchLoginInfo();
        cancelJobRequest.jobID = WSCH_CommonUtils.getWorkItemId(WSCH_Constants.WORKORDER_OPTIMIZATION_ID_FIELD, workOrder);
        return cancelJobRequest;
    }

    /**
        Following creats and maps cancel job request from Work order(SVMXC__SVMX_Optimizer__c), When Work order gets deleted.
    */
    public static WSCH_Provider_SP_StubsV91.JobCancelRequest mapCancelJobRequest (SVMXC__SVMX_Optimizer__c workOrder) {

        WSCH_Provider_SP_StubsV91.JobCancelRequest cancelJobRequest = new WSCH_Provider_SP_StubsV91.JobCancelRequest();
        cancelJobRequest.login = fetchLoginInfo();
        cancelJobRequest.jobID = workOrder.SVMXC__WhatId__c;
        return cancelJobRequest;
    }

    /**
        Following maps cancel job responce to Work order.
    */
    public static void mapCancelJobResponse (WSCH_Provider_SP_StubsV91.JobCancelResponse response, SVMXC__Service_Order__c workOrder) {
        //set the status code on the work order.
        if(workOrder != null && response != null) {
            WSCH_Provider_SP_StubsV91.ReturnCode returnCode = response.result;
            //based on the response code set the appropriate message on the WO Optimax status.
            if(WSCH_Provider_SP_ErrorCodesMapper.isSuccess(returnCode.code)){
                workOrder.SVMXC__OptiMax_Status__c = WSCH_Constants.STATUS_OPT_COMPLETED;
                //Empty the Work Order Connection Name if Successful Cancel Job
                workOrder.SVMXC__Optimizer_Connection_Name__c = null;
            } else {
                workOrder.SVMXC__OptiMax_Status__c = WSCH_CommonUtils.resolveOptimaxStatus(workOrder.SVMXC__OptiMax_Status__c, 'OPT_ERROR');
            }
            String errorText = 'Return Code:' + returnCode.code + ' | Return Type:' + returnCode.type_x + ' | Return Note:' + returnCode.errNote + ' | Return Msg:' + WSCH_Provider_SP_ErrorCodesMapper.getStatusMsg(returnCode.code);
            WSCH_CommonUtils.setOptimizerErrorText(workOrder, errorText);
        }
    }

    /**
        Following maps cancel job responce to Work order(SVMXC__SVMX_Optimizer__c), When Work Order gets deleted.
    */
    public static void mapCancelJobResponse (WSCH_Provider_SP_StubsV91.JobCancelResponse response, SVMXC__SVMX_Optimizer__c workOrder) {
        //set the status code on the work order.
        if(workOrder != null && response != null) {
            WSCH_Provider_SP_StubsV91.ReturnCode returnCode = response.result;
            //based on the response code set the appropriate message on the WO Optimax status.
            if(WSCH_Provider_SP_ErrorCodesMapper.isSuccess(returnCode.code)){
                workOrder.SVMXC__Optimizer_Status__c = WSCH_Constants.STATUS_OPT_COMPLETED;
            } else {
                workOrder.SVMXC__Optimizer_Status__c = WSCH_CommonUtils.resolveOptimaxStatus(workOrder.SVMXC__Optimizer_Status__c, 'OPT_ERROR');
            }
            workOrder.SVMXC__Optimizer_Error_Text__c = 'Return Code:' + returnCode.code + ' | Return Type:' + returnCode.type_x + ' | Return Note:' + returnCode.errNote + ' | Return Msg:' + WSCH_Provider_SP_ErrorCodesMapper.getStatusMsg(returnCode.code);
        }
    }

    /**
        Following creats and maps forcefix job request from Work order.
    */
    public static WSCH_Provider_SP_StubsV91.ForceFixJobRequest mapForceFixJobRequest (SVMXC__Service_Order__c workOrder) {

        WSCH_Provider_SP_StubsV91.ForceFixJobRequest forceFixJobRequest = new WSCH_Provider_SP_StubsV91.ForceFixJobRequest();
        forceFixJobRequest.login = fetchLoginInfo();
        forceFixJobRequest.jobID = WSCH_CommonUtils.getWorkItemId(WSCH_Constants.WORKORDER_OPTIMIZATION_ID_FIELD, workOrder);
        forceFixJobRequest.empID = WSCH_CommonUtils.fetchTechnicianById(workOrder.SVMXC__Group_Member__c).SVMXC__Optimizer_External_ID__c;
        DateTime startDateTime = NULL;
        if(workOrder.SVMXC__Driving_Time__c != NULL){
            startDateTime = workOrder.SVMXC__Scheduled_Date_Time__c.addMinutes(-Integer.valueOf(workOrder.SVMXC__Driving_Time__c));
        }else{
            startDateTime = workOrder.SVMXC__Scheduled_Date_Time__c;
        }
        forceFixJobRequest.startDateTime = formatPreferredStartTime(startDateTime);
        WSCH_Provider_SP_StubsV91.ForceFixJobOptions forceFixJobOptions = new WSCH_Provider_SP_StubsV91.ForceFixJobOptions();
        forceFixJobOptions.IgnAll = true; //All the overrides are applied
        forceFixJobRequest.options = forceFixJobOptions;
        return forceFixJobRequest;
    }

    public static WSCH_Provider_SP_StubsV91.spLogin mapSPLoginRequest(String dbUser, String dbPassword, String spUser) {

        WSCH_Provider_SP_StubsV91.spLogin spLoginReq = new WSCH_Provider_SP_StubsV91.spLogin();
        spLoginReq.databaseUser = dbUser;
        spLoginReq.password = dbPassword;
        spLoginReq.spUser = spUser;
        return spLoginReq;
    }

    /**
        Map the ChangeJobStatusRequest for Dispatch Client API.
    **/
    public static WSCH_WorkOrderResponse mapDispOutputRequest(WSCH_Provider_SP_DispatchClient.DispJobEarmarked dispJobEarmarked,String workOrderId,String dispatchStatus) {

        WSCH_WorkOrderResponse woResponse = new WSCH_WorkOrderResponse();
        List<WSCH_TechnicianEvent>  lstTechEvent = new List<WSCH_TechnicianEvent>();
        WSCH_TechnicianEvent techEvent = new WSCH_TechnicianEvent();
        techEvent.setWorkOrderID(workOrderId);
        techEvent.setTechnicianExternalID(dispJobEarmarked.empID);
        if(String.isNotBlank(dispJobEarmarked.ETS)){
            techEvent.setStartDateTime(WSCH_DateUtils.parseSPDateTimeGmt(dispJobEarmarked.ETS));
        }
        if(String.isNotBlank(dispJobEarmarked.ETA)){
            techEvent.setArrivalDateTime(WSCH_DateUtils.parseSPDateTimeGmt(dispJobEarmarked.ETA));
        }
        if(String.isNotBlank(dispJobEarmarked.ETF)){
            techEvent.setFinishDateTime(WSCH_DateUtils.parseSPDateTimeGmt(dispJobEarmarked.ETF));
        }
        techEvent.setDispatchStatus(dispatchStatus);
        lstTechEvent.add(techEvent);
        woResponse.getLstTechEvent().addAll(lstTechEvent);
        return woResponse;
    }

    /**
        This method returns the Account object for a Company ID
    **/
    public static Account getAccountFromCompanyId(String companyId) {

        Account objectAccount;
        if(companyId != null) {
            List<Account> lstAccount = [SELECT Id, AccountNumber, Name FROM Account WHERE Id =: companyId];
            if(lstAccount != null && lstAccount.size() > 0) {
                objectAccount = lstAccount[0];
            }
        }
        return objectAccount;
    }

    /**
        This method returns the Contact object for a contact ID
    **/
    public static Contact getContactFromContactId(String contactId) {

        Contact objectContact;
        if(contactId != null) {
            List<Contact> lstContact = [SELECT FirstName, LastName, Phone, MobilePhone FROM Contact WHERE Id =: contactId];
            if(lstContact != null && lstContact.size() > 0) {
                objectContact = lstContact[0];
            }
        }
        return objectContact;
    }

    /**
        This method returns the Site object for a Site ID
    **/
    /*public static SVMXC__Site__c getSiteBySiteId(String siteId) {

        SVMXC__Site__c objectSite;
        if(siteId != null) {
            List<SVMXC__Site__c> lstSite = [SELECT Name FROM SVMXC__Site__c WHERE Id =: siteId];
            if(lstSite != null && lstSite.size() > 0) {
                objectSite = lstSite[0];
            }
        }
        return objectSite;
    }*/

    /**
        This method returns the login details of ServicePower database
    **/
    /*public static WSCH_Provider_SP_StubsV91.spLogin fetchLoginInfo() {
        WSCH_Provider_SP_StubsV91.spLogin servicePowerLogin = new WSCH_Provider_SP_StubsV91.spLogin();
        List<SVMXC__ServiceMax_Properties__c> SPsettinglist = new List<SVMXC__ServiceMax_Properties__c>();
        String spUser,dbUser,dbPassWord;
        //caching SP private settings.
        if(WSCH_Constants.allSPsettinglist == NULL || WSCH_Constants.allSPsettinglist.size() == 0){
            WSCH_Constants.allSPsettinglist = [Select Name, SVMXC__Key__c, SVMXC__Value__c from SVMXC__ServiceMax_Properties__c where Name in ('SP001','SP002','SP003','SP004','SP005','SP006','SP007') ];
        }
        SPsettinglist = WSCH_Constants.allSPsettinglist;

        for(SVMXC__ServiceMax_Properties__c setting :SPsettinglist)
        {
            if(setting.Name == 'SP001')
                spUser = decryption1(setting.SVMXC__Value__c);

            if(setting.Name == 'SP002')
                dbUser = decryption1(setting.SVMXC__Value__c);

            if(setting.Name == 'SP003')
                dbPassWord = decryption1(setting.SVMXC__Value__c);

        }
        servicePowerLogin.databaseUser=dbUser;
        servicePowerLogin.password = dbPassWord;
        servicePowerLogin.spUser = spUser;
        
        //servicePowerLogin.databaseUser='smax_user';
        //servicePowerLogin.password = 'smaxapi99';
        //servicePowerLogin.spUser = 'smaxapi';
        return servicePowerLogin;
    }*/
    
    /**
        This method returns the login details of ServicePower database from the New Data Model only from the Default Connection if configured
        in Optimization Settings page
    **/
    public static WSCH_Provider_SP_StubsV91.spLogin fetchLoginInfo() {
        WSCH_Provider_SP_StubsV91.spLogin servicePowerLogin = new WSCH_Provider_SP_StubsV91.spLogin();
        Map<String, SVMXC__ServiceMax_Properties__c> allSpSettings = new Map<String, SVMXC__ServiceMax_Properties__c>();
        SVMXC__ServiceMax_Properties__c instanceName = new SVMXC__ServiceMax_Properties__c();
        String spUser,dbUser,dbPassWord,strDefaultConNum;
        
        try {
            allSpSettings = SVMXC__ServiceMax_Properties__c.getAll();
            if((allSpSettings != null) && (!allSpSettings.isEmpty())) {
                //WSCH_AuditLogger.debug('allSpSetings.keySet(): ' + allSpSettings.keySet());
                for(String strCon: allSpSettings.keySet()) {
                    instanceName = allSpSettings.get(strCon);
                    if(strCon.contains('SP_CON_02') && ('true'.equalsIgnoreCase(allSpSettings.get('SP_CON_02_' + (instanceName.Name).right(2)).SVMXC__Value__c))) {
                        strDefaultConNum = (instanceName.Name).right(2);
                    }
                }
                
                if(String.isNotBlank(strDefaultConNum)) {
                    dbUser = decryption1(allSpSettings.get('SP_CON_05_' + strDefaultConNum).SVMXC__Value__c);
                    dbPassWord = decryption1(allSpSettings.get('SP_CON_07_' + strDefaultConNum).SVMXC__Value__c);
                    spUser = decryption1(allSpSettings.get('SP_CON_06_' + strDefaultConNum).SVMXC__Value__c);
                                
                    servicePowerLogin.databaseUser=dbUser;
                    servicePowerLogin.password = dbPassWord;
                    servicePowerLogin.spUser = spUser;
                } else {
                    WSCH_AuditLogger.ERROR('WSCH_Provider_SP_DataMapper :: fetchLoginInfo(): No Default Connection available');
                    throw new WSCH_EXCEPTION('WSCH_Provider_SP_DataMapper :: fetchLoginInfo(): No Default Connection available');
                }
            } 
        } catch(Exception ex) {
            String exceptionMsg = 'WSCH_Provider_SP_DataMapper :: fetchLoginInfo() :: ';
            WSCH_AuditLogger.error(exceptionMsg+ex.getMessage() + '\n Stack Trace:: ' + ex.getStackTraceString());
            if(String.isBlank(strDefaultConNum)){
                throw new WSCH_Exception('No Default Connection available. Please create a Default Connection in Optimization Settings tab under ServiceMax Setup');
            }
        }
        return servicePowerLogin;
    }
    
    public static WSCH_Provider_SP_StubsV91.spLogin getSPCredentials(String strSpInstName){
        WSCH_Provider_SP_StubsV91.spLogin servicePowerLogin = new WSCH_Provider_SP_StubsV91.spLogin();
        Map<String, SVMXC__ServiceMax_Properties__c> allSpSettings = new Map<String, SVMXC__ServiceMax_Properties__c>();
        SVMXC__ServiceMax_Properties__c instanceName = new SVMXC__ServiceMax_Properties__c();
        String spUser,dbUser,dbPassWord, strGBL23, strConNum, strDefaultConnNum;
        try{
            if(String.isNotBlank(strSpInstName)){
                allSpSettings = SVMXC__ServiceMax_Properties__c.getAll();
                if((allSpSettings != null) && (!allSpSettings.isEmpty())){
                    for(String strCon: allSpSettings.keySet()){
                        instanceName = allSpSettings.get(strCon);
                        if (('ServicePower Connection Name'.equalsIgnoreCase(instanceName.SVMXC__Key__c)) &&
                            ('true'.equalsIgnoreCase(allSpSettings.get('SP_CON_01_' + (instanceName.Name).right(2)).SVMXC__Value__c))){
                                if((strSpInstName.equalsIgnoreCase(instanceName.SVMXC__Value__c))){
                                    strConNum = (instanceName.Name).right(2);
                                }
                                if(('ServicePower Connection Default'.equalsIgnoreCase(instanceName.SVMXC__Key__c)) &&
                                   ('true'.equalsIgnoreCase(allSpSettings.get('SP_CON_02_' + (instanceName.Name).right(2)).SVMXC__Value__c))){
                                       strDefaultConnNum = (instanceName.Name).right(2);
                                   }
                            }
                    }
                    //WSCH_AuditLogger.debug('###strConNum: ' + strConNum);
                    //strConNum = strConNum==null?strDefaultConnNum:strConNum;
                    
                    dbUser = decryption1(allSpSettings.get('SP_CON_05_' + strConNum).SVMXC__Value__c);
                    dbPassWord = decryption1(allSpSettings.get('SP_CON_07_' + strConNum).SVMXC__Value__c);
                    spUser = decryption1(allSpSettings.get('SP_CON_06_' + strConNum).SVMXC__Value__c);
                    
                    servicePowerLogin.databaseUser=dbUser;
                    servicePowerLogin.password = dbPassWord;
                    servicePowerLogin.spUser = spUser;
                }else{
                    WSCH_AuditLogger.ERROR('WSCH_Provider_SP_DataMapper :: getSPCredentials: No Valid Connection Name');
                    throw new WSCH_EXCEPTION('WSCH_Provider_SP_DataMapper :: getSPCredentials: No Valid Connection Name');
                }
            }
        }catch(Exception ex){
            String exceptionMsg = 'WSCH_Provider_SP_DataMapper :: getSPCredentials() :: ';
            WSCH_AuditLogger.error(exceptionMsg+ex.getMessage() + '\n Stack Trace:: ' + ex.getStackTraceString());
            if(String.isBlank(strConNum)){
                throw new WSCH_Exception('No Active Service Power Instance');
            }
        }
        return servicePowerLogin;
    }

    public static String decryption1(String Encstr)
            {
                String Decodeddata;
                boolean unfailed=false;
                try{
                    if(String.isNotBlank(Encstr)){
                        if(unfailed==true)
                            Decodeddata=Encstr;
                        else{
                            blob Decodeblob = EncodingUtil.base64Decode(Encstr);
                            Decodeddata = Decodeblob.toString();
                        }
                    }
                }
                catch(Exception ex){
                    unfailed=true;
                    Decodeddata = Encstr;
                    WSCH_AuditLogger.error('WSCH_Provider_SP_DataMapper::decryption1():Exception occured..'+ex.getMessage() + '\n Stack Trace:: ' + ex.getStackTraceString());
                    //WSCH_AuditLogger.finish();
                }
                return Decodeddata;
    }
    /**
    This method builds the SkillSet object in ServicePower format from the WorkOrder SkillSet object
    **/
    private static WSCH_Provider_SP_StubsV91.ReqSkills fetchExtraSkills(SVMXC__Service_Order__c workOrder)
    {
        //Parse the skillSet which is in JSON format and extract the skillName and skillLevel from it
        WSCH_Provider_SP_StubsV91.ReqSkills extraSkills = new WSCH_Provider_SP_StubsV91.ReqSkills();
        if(workOrder != null && String.isNotEmpty(workOrder.SVMXC__Skill_Set__c)) {
            JSONParser parser = JSON.createParser(workOrder.SVMXC__Skill_Set__c);
            List<String> lstOfSkillName = new List<String>();
            List<String> lstOfSkillLevel = new List<String>();
            while(parser.nextToken() != null)
            {
                if ((parser.getCurrentToken() == JSONToken.FIELD_NAME) && (parser.getText() == WSCH_Constants.STR_SKILL_NAME)) {
                    //extract the skillName
                    parser.nextToken();
                    lstOfSkillName.add(parser.getText());
                } else if((parser.getCurrentToken() == JSONToken.FIELD_NAME) && (parser.getText() == WSCH_Constants.STR_SKILL_LEVEL)) {
                    //extract the skillLevel
                    parser.nextToken();
                    lstOfSkillLevel.add(parser.getText());
                }
            }
            extraSkills.reqSkills = new List<WSCH_Provider_SP_StubsV91.SkillWithLevel>();
            WSCH_Provider_SP_StubsV91.SkillWithLevel skillWithLevel;
            for(Integer i=0; i< lstOfSkillName.size(); i++) {
                skillWithLevel = new WSCH_Provider_SP_StubsV91.SkillWithLevel();
                skillWithLevel.skillID = lstOfSkillName.get(i);
                skillWithLevel.skillLevel = lstOfSkillLevel.get(i);
                extraSkills.reqSkills.add(skillWithLevel);
            }
        }
        return extraSkills;
    }

    private static WSCH_Provider_SP_StubsV91.ReqEmps fetchReqEmps(SVMXC__Service_Order__c workOrder) {

        WSCH_Provider_SP_StubsV91.ReqEmps reqEmps;

        //if Preferred technician is set on the WorkOrder, set the same on the ServicePower request object
        if(workOrder.SVMXC__Preferred_Technician__c != null) {

            //query the technician object using this technicianID and fetch the externalID from that technician
            List<SVMXC__Service_Group_Members__c> lstOfTechnicians = [SELECT SVMXC__Optimizer_External_ID__c FROM
                                                                SVMXC__Service_Group_Members__c WHERE Id =: workOrder.SVMXC__Preferred_Technician__c];
            if(lstOfTechnicians != null && lstOfTechnicians.size() > 0) {
                SVMXC__Service_Group_Members__c technician = lstOfTechnicians.get(0);
                String[] empIDs = new String[]{technician.SVMXC__Optimizer_External_ID__c};
                reqEmps = new WSCH_Provider_SP_StubsV91.ReqEmps();
                reqEmps.empIDs = empIDs;    //fetch the externalID from the technician object queried above
                reqEmps.MPX = WSCH_Constants.STR_REQ_EMP_MPX; //Preferred or PrefOrdered as per ServicePower
            }
        }

        return reqEmps;
    }

    /**
    This method builds the employee object in ServicePower format from the WorkOrder Technician Object
    **/
    private static WSCH_Provider_SP_StubsV91.ReqEmp fetchReqEmp(SVMXC__Service_Order__c workOrder) {

        WSCH_Provider_SP_StubsV91.ReqEmp reqEmp;

        //if Preferred technician is set on the WorkOrder, set the same on the ServicePower request object
        if(workOrder.SVMXC__Preferred_Technician__c != null) {

            //query the technician object using this technicianID and fetch the externalID from that technician
            List<SVMXC__Service_Group_Members__c> lstOfTechnicians = [SELECT SVMXC__Optimizer_External_ID__c FROM
                                                                SVMXC__Service_Group_Members__c WHERE Id =: workOrder.SVMXC__Preferred_Technician__c];
            if(lstOfTechnicians != null && lstOfTechnicians.size() > 0) {
                SVMXC__Service_Group_Members__c technician = lstOfTechnicians.get(0);
                reqEmp = new WSCH_Provider_SP_StubsV91.ReqEmp();
                reqEmp.empID = technician.SVMXC__Optimizer_External_ID__c;    //fetch the externalID from the technician object queried above
                reqEmp.MPX = WSCH_Constants.STR_REQ_EMP_MPX; //Preferred or PrefOrdered as per ServicePower
            }
        }

        return reqEmp;
    }


    /**
    This method builds the AccHoursPatts object in ServicePower format from the WorkOrder Date and Time
    **/
    public static WSCH_Provider_SP_StubsV91.AccHoursPatts fetchAccHoursPatts(SVMXC__Service_Order__c workOrder) {
        WSCH_Provider_SP_StubsV91.AccHoursPatts objAccHoursPatts = new WSCH_Provider_SP_StubsV91.AccHoursPatts();
        //set horizon dates for access hours
        Datetime startTime;
        if(null != workOrder.SVMXC__Preferred_Start_Time__c){
            startTime = workOrder.SVMXC__Preferred_Start_Time__c;
        } else {
            startTime = Datetime.now();
        }
        
        Datetime endTime = startTime.addDays(Integer.valueOf(strNoOfDays));
        if(null != workOrder.SVMXC__Preferred_End_Time__c && workOrder.SVMXC__Preferred_End_Time__c > endTime){
                endTime = workOrder.SVMXC__Preferred_End_Time__c;
        } 
        

        WSCH_Provider_SP_StubsV91.AccHoursPatt accHrPatt = new WSCH_Provider_SP_StubsV91.AccHoursPatt();
        accHrPatt.dateRange = new WSCH_Provider_SP_StubsV91.DateRange();
        accHrPatt.dateRange.start = WSCH_DateUtils.getSPDate(startTime);
        accHrPatt.dateRange.end_x = WSCH_DateUtils.getSPDate(endTime);
        accHrPatt.daysAndTimes = getDayTimePeriod(workOrder);
        List<WSCH_Provider_SP_StubsV91.AccHoursPatt> accHoursPattLst = new List<WSCH_Provider_SP_StubsV91.AccHoursPatt>();
        accHoursPattLst.add(accHrPatt);
        objAccHoursPatts.accHoursPatt = accHoursPattLst;
        return objAccHoursPatts;
    }

    public static List<WSCH_Provider_SP_StubsV91.DayAndTimePeriod> getDayTimePeriod(SVMXC__Service_Order__c workOrder) {
        List<WSCH_Provider_SP_StubsV91.DayAndTimePeriod> weekTimes;
        List<BusinessHours> lstOfBusinessHours = new List<BusinessHours>();

        if(workOrder.SVMXC__Preferred_Business_Hours__c != null) {
            lstOfBusinessHours = getBusinessHoursById(workOrder.SVMXC__Preferred_Business_Hours__c);
        } else {
            lstOfBusinessHours = getBusinessHoursByWO(workOrder);
        }
        //system.debug('lstOfBusinessHours '+lstOfBusinessHours);
        weekTimes=setWeekTimes(lstOfBusinessHours,null);
        return weekTimes;
    }

    private static List<BusinessHours> getBusinessHoursByWO(SVMXC__Service_Order__c workOrder) {
        List<BusinessHours> lstOfBusinessHours = new List<BusinessHours>();
        boolean isfound=false;

        if(workOrder.SVMXC__SLA_Terms__c != null) {
            List<SVMXC__Service_Level__c> slaList = new List<SVMXC__Service_Level__c>();
            //slaList=[SELECT SVMXC__Business_Hours__c,Id FROM SVMXC__Service_Level__c WHERE Id =: workOrder.SVMXC__SLA_Terms__c];
            if(mapOfServiceLevelIdAndServiceLevelObj != null && mapOfServiceLevelIdAndServiceLevelObj.size() > 0) {
                slaList.add(mapOfServiceLevelIdAndServiceLevelObj.get(workOrder.SVMXC__SLA_Terms__c));
                    if(slaList[0].SVMXC__Business_Hours__c != null){
                        WSCH_AuditLogger.debug('WSCH_Provider_SP_DataMapper::getBusinessHoursByWO:: SLA Business Hr : '+slaList[0].SVMXC__Business_Hours__c);
                        lstOfBusinessHours=getBusinessHoursById(slaList[0].SVMXC__Business_Hours__c);
                        isfound=true;
                    }
            }
        }
        
        if(!isfound && workOrder.SVMXC__Service_Contract__c != null){
            //SVMXC__Service_Contract__c serviceContr = [SELECT Id,SVMXC__Active__c,SVMXC__Business_Hours__c FROM SVMXC__Service_Contract__c WHERE Id =: workOrder.SVMXC__Service_Contract__c AND SVMXC__Active__c = true];
            if(mapOfServiceContractIdAndServiceContractObj != null && mapOfServiceContractIdAndServiceContractObj.size() > 0) {
                SVMXC__Service_Contract__c serviceContr = mapOfServiceContractIdAndServiceContractObj.get(workOrder.SVMXC__Service_Contract__c);
                if(serviceContr != null && serviceContr.SVMXC__Business_Hours__c != null){
                    WSCH_AuditLogger.debug('WSCH_Provider_SP_DataMapper::getBusinessHoursByWO:: Contract Business Hr : '+serviceContr.SVMXC__Business_Hours__c);
                    lstOfBusinessHours=getBusinessHoursById(serviceContr.SVMXC__Business_Hours__c);
                    isfound=true;
                }
            }
        }
        
        if(!isfound && workOrder.SVMXC__Primary_Territory__c != null) {
            //SVMXC__Territory__c territory = [SELECT Id,SVMXC__Territory_s_Business_Hours__c FROM SVMXC__Territory__c WHERE Id =: workOrder.SVMXC__Primary_Territory__c];
            if(mapOfTerritoryIdAndTerritoryObj != null && mapOfTerritoryIdAndTerritoryObj.size() > 0) {
                SVMXC__Territory__c territory = mapOfTerritoryIdAndTerritoryObj.get(workOrder.SVMXC__Primary_Territory__c);
                if(territory != null && territory.SVMXC__Territory_s_Business_Hours__c != null){
                    WSCH_AuditLogger.debug('WSCH_Provider_SP_DataMapper::getBusinessHoursByWO:: Territory Business Hr : '+territory.SVMXC__Territory_s_Business_Hours__c);
                    lstOfBusinessHours=getBusinessHoursById(territory.SVMXC__Territory_s_Business_Hours__c);
                    isfound=true;
                }
            }
        }

        if((lstOfBusinessHours.isEmpty()) || (lstOfBusinessHours == null)){
            //fetch default business hour
            /*lstOfBusinessHours = [SELECT Id,IsActive,IsDefault,TimeZoneSidKey,MondayStartTime,MondayEndTime,
                                TuesdayStartTime,TuesdayEndTime,WednesdayStartTime,WednesdayEndTime,
                                ThursdayStartTime,ThursdayEndTime,FridayStartTime,FridayEndTime,SaturdayStartTime,
                                SaturdayEndTime,SundayStartTime,SundayEndTime FROM BusinessHours
                                WHERE IsDefault = TRUE AND IsActive = TRUE];*/
            //assigning the default business hour that has been queried earlier in static block                                
            lstOfBusinessHours = lstOfDefaultBussHr;                         
            WSCH_AuditLogger.debug('WSCH_Provider_SP_DataMapper::getBusinessHoursByWO:: Default Business Hr : '+lstOfBusinessHours[0]);              
        }
        return lstOfBusinessHours;
    }

    public static List<WSCH_Provider_SP_StubsV91.DayAndTimePeriod> setWeekTimes(List<BusinessHours> lstOfBusinessHours, Integer tzOffsetinMinutes){
        List<WSCH_Provider_SP_StubsV91.DayAndTimePeriod> weekTimes = new List<WSCH_Provider_SP_StubsV91.DayAndTimePeriod>();
        BusinessHours bh;
        if(!lstOfBusinessHours.isEmpty()) {
            bh = lstOfBusinessHours.get(0);
            WSCH_AuditLogger.debug('WSCH_Provider_SP_DataMapper::setWeekTimes:: Business Hr Time Zone : '+bh.TimeZoneSidKey);
            WSCH_AuditLogger.debug('WSCH_Provider_SP_DataMapper::setWeekTimes:: tzOffsetinMinutes : '+tzOffsetinMinutes);
            weekTimes = new List<WSCH_Provider_SP_StubsV91.DayAndTimePeriod>();
            WSCH_Provider_SP_StubsV91.DayAndTimePeriod period;

            if(null != bh.MondayStartTime && null != bh.MondayEndTime) {
                period = new WSCH_Provider_SP_StubsV91.DayAndTimePeriod();
                period.day = 'Mon';
                if(tzOffSetinMinutes == null || tzOffSetinMinutes == -1 || tzOffSetinMinutes == 1){
                    period.start = WSCH_DateUtils.formatSPTime(bh.MondayStartTime, bh.TimeZoneSidKey);
                    period.end_x = WSCH_DateUtils.formatSPEndTime(bh.MondayEndTime, bh.TimeZoneSidKey);
                }else{
                    period.start = WSCH_DateUtils.formatSPTime(bh.MondayStartTime,tzOffsetinMinutes);
                    period.end_x = WSCH_DateUtils.formatSPEndTime(bh.MondayEndTime,tzOffsetinMinutes);
                }
                weekTimes.add(period);
            }

            if(null != bh.TuesdayStartTime && null != bh.TuesdayEndTime) {
                period = new WSCH_Provider_SP_StubsV91.DayAndTimePeriod();
                period.day = 'Tue';
                if(tzOffSetinMinutes == null || tzOffSetinMinutes == -1 || tzOffSetinMinutes == 1){
                    period.start = WSCH_DateUtils.formatSPTime(bh.TuesdayStartTime, bh.TimeZoneSidKey);
                    period.end_x = WSCH_DateUtils.formatSPEndTime(bh.TuesdayEndTime, bh.TimeZoneSidKey);
                }else{
                    period.start = WSCH_DateUtils.formatSPTime(bh.TuesdayStartTime,tzOffSetinMinutes);
                    period.end_x = WSCH_DateUtils.formatSPEndTime(bh.TuesdayEndTime,tzOffSetinMinutes);
                }
                weekTimes.add(period);
            }

            if(null != bh.WednesdayStartTime && null != bh.WednesdayEndTime) {
                period = new WSCH_Provider_SP_StubsV91.DayAndTimePeriod();
                period.day = 'Wed';
                if(tzOffSetinMinutes == null || tzOffSetinMinutes == -1 || tzOffSetinMinutes == 1){
                    period.start = WSCH_DateUtils.formatSPTime(bh.WednesdayStartTime, bh.TimeZoneSidKey);
                    period.end_x = WSCH_DateUtils.formatSPEndTime(bh.WednesdayEndTime, bh.TimeZoneSidKey);
                }else{
                    period.start = WSCH_DateUtils.formatSPTime(bh.WednesdayStartTime,tzOffSetinMinutes);
                    period.end_x = WSCH_DateUtils.formatSPEndTime(bh.WednesdayEndTime,tzOffSetinMinutes);
                }
                weekTimes.add(period);
            }

            if(null != bh.ThursdayStartTime && null != bh.ThursdayEndTime) {
                period = new WSCH_Provider_SP_StubsV91.DayAndTimePeriod();
                period.day = 'Thu';
                if(tzOffSetinMinutes == null || tzOffSetinMinutes == -1 || tzOffSetinMinutes == 1){
                    period.start = WSCH_DateUtils.formatSPTime(bh.ThursdayStartTime, bh.TimeZoneSidKey);
                    period.end_x = WSCH_DateUtils.formatSPEndTime(bh.ThursdayEndTime, bh.TimeZoneSidKey);
                }else{
                    period.start = WSCH_DateUtils.formatSPTime(bh.ThursdayStartTime,tzOffSetinMinutes);
                    period.end_x = WSCH_DateUtils.formatSPEndTime(bh.ThursdayEndTime,tzOffSetinMinutes);
                }
                weekTimes.add(period);
            }

            if(null != bh.FridayStartTime && null != bh.FridayEndTime) {
                period = new WSCH_Provider_SP_StubsV91.DayAndTimePeriod();
                period.day = 'Fri';
                if(tzOffSetinMinutes == null || tzOffSetinMinutes == -1 || tzOffSetinMinutes == 1){
                    period.start = WSCH_DateUtils.formatSPTime(bh.FridayStartTime, bh.TimeZoneSidKey);
                    period.end_x = WSCH_DateUtils.formatSPEndTime(bh.FridayEndTime, bh.TimeZoneSidKey);
                }else{
                    period.start = WSCH_DateUtils.formatSPTime(bh.FridayStartTime,tzOffSetinMinutes);
                    period.end_x = WSCH_DateUtils.formatSPEndTime(bh.FridayEndTime,tzOffSetinMinutes);
                }
                weekTimes.add(period);
            }

            if(null != bh.SaturdayStartTime && null != bh.SaturdayEndTime) {
                period = new WSCH_Provider_SP_StubsV91.DayAndTimePeriod();
                period.day = 'Sat';
                if(tzOffSetinMinutes == null || tzOffSetinMinutes == -1 || tzOffSetinMinutes == 1){
                    period.start = WSCH_DateUtils.formatSPTime(bh.SaturdayStartTime, bh.TimeZoneSidKey);
                    period.end_x = WSCH_DateUtils.formatSPEndTime(bh.SaturdayEndTime, bh.TimeZoneSidKey);
                }else{
                    period.start = WSCH_DateUtils.formatSPTime(bh.SaturdayStartTime,tzOffSetinMinutes);
                    period.end_x = WSCH_DateUtils.formatSPEndTime(bh.SaturdayEndTime,tzOffSetinMinutes);
                }             
                weekTimes.add(period);
            }

            if(null != bh.SundayStartTime && null != bh.SundayEndTime) {
                period = new WSCH_Provider_SP_StubsV91.DayAndTimePeriod();
                period.day = 'Sun';
                if(tzOffSetinMinutes == null || tzOffSetinMinutes == -1 || tzOffSetinMinutes == 1){
                    period.start = WSCH_DateUtils.formatSPTime(bh.SundayStartTime, bh.TimeZoneSidKey);
                    period.end_x = WSCH_DateUtils.formatSPEndTime(bh.SundayEndTime, bh.TimeZoneSidKey);
                }else{
                    period.start = WSCH_DateUtils.formatSPTime(bh.SundayStartTime,tzOffSetinMinutes);
                    period.end_x = WSCH_DateUtils.formatSPEndTime(bh.SundayEndTime,tzOffSetinMinutes);
                }
                weekTimes.add(period);
            }
        }
        return weekTimes;
    }

    private static String formatPreferredStartTime(DateTime preferredStartTime){
        String strPreferredStartTime;
        if(preferredStartTime == null){
           preferredStartTime = Datetime.now();
        }
        strPreferredStartTime = WSCH_DateUtils.getSPDateTime(preferredStartTime);
        return strPreferredStartTime;
    }

    private static String formatPreferredEndTime(DateTime preferredEndTime){
        String strPreferredEndTime;
        if(preferredEndTime == null){
            preferredEndTime = Datetime.now().addDays(Integer.valueOf(strNoOfDays));
        }
        strPreferredEndTime = WSCH_DateUtils.getSPDateTime(preferredEndTime);
        return strPreferredEndTime;
    }

    //calculate preferred end datetime based on preferred start datetime.
    private static String formatPreferredEndTime(SVMXC__Service_Order__c workOrder){
        String strPreferredEndTime;
        DateTime preferredStartTime = workOrder.SVMXC__Preferred_Start_Time__c;
        DateTime preferredEndtime = workOrder.SVMXC__Preferred_End_Time__c;
        if(preferredStartTime == null && preferredEndtime == null){
            preferredEndtime = Datetime.now().addDays(Integer.valueOf(strNoOfDays));
        } else if(preferredStartTime != null && preferredEndtime == null) {
            preferredEndtime = preferredStartTime.addDays(Integer.valueOf(strNoOfDays));
        }
        strPreferredEndTime = WSCH_DateUtils.getSPDateTime(preferredEndtime);
        return strPreferredEndTime;
    }

    private static List<BusinessHours> getBusinessHoursById(String strId) {
        List<BusinessHours> lstOfBusinessHours = new List<BusinessHours>();
        if(null != strId){
            /*lstOfBusinessHours = [SELECT Id,IsActive,IsDefault,TimeZoneSidKey,MondayStartTime,MondayEndTime,
                                TuesdayStartTime,TuesdayEndTime,WednesdayStartTime,WednesdayEndTime,
                                ThursdayStartTime,ThursdayEndTime,FridayStartTime,FridayEndTime,SaturdayStartTime,
                                SaturdayEndTime,SundayStartTime,SundayEndTime FROM BusinessHours
                                WHERE Id =: strId AND IsActive = TRUE];*/
           if((mapOfBussHrIdAndBussHrObj != null) && (mapOfBussHrIdAndBussHrObj.size() > 0) && (mapOfBussHrIdAndBussHrObj.get(strId) != null)) {
                lstOfBusinessHours.add(mapOfBussHrIdAndBussHrObj.get(strId));
           }                     
        }
        return lstOfBusinessHours;
    }


    /**
        Followig method resolves the dispatch priority for a work order.
        If dispatch priority is invalid in work order it considers the default setting.
        If default setting value is invalid it considers WSCH_Constants.INT_DEFAULT_PRIORITY , which is 50.
        If final priority value is more than 99 , it returns WSCH_Constants.INT_MAX_PRIORITY , which is 99.
    **/
    private static String resolveDispatchPriority(SVMXC__Service_Order__c workOrder) {

        Integer priority = WSCH_Constants.INT_DEFAULT_PRIORITY;
        try {
            if(workOrder.SVMXC__Dispatch_Priority__c != null) {
                priority = workOrder.SVMXC__Dispatch_Priority__c.intValue();
            } else {
                String defaultPriority = WSCH_CommonUtils.getSettingValue('OMAX003','SET003');
                if(defaultPriority != null) {
                    priority = Integer.valueOf(defaultPriority);
                }
            }

            if(priority < 1) {
                return String.ValueOf(WSCH_Constants.INT_DEFAULT_PRIORITY);
            } else if (priority > 99) {
                return String.ValueOf(WSCH_Constants.INT_MAX_PRIORITY);
            } else {
                return String.ValueOf(priority);
            }
        } catch (Exception ex){
            WSCH_AuditLogger.error('WSCH_Provider_SP_DataMapper::resolveDispatchPriority():Exception occured..'+ex.getMessage() + '\n Stack Trace:: ' + ex.getStackTraceString());
            //WSCH_AuditLogger.finish();
            return String.ValueOf(WSCH_Constants.INT_DEFAULT_PRIORITY);
        }
    }

    /**
        Following method formats the Non WO (Standard Activity Date and time) as per following logic.

        1. The date and time need to be formatted according to the technician time zone.
        2. If the Technician has a SalesForce id associated with it,get the SF user?s time zone.
        3. If the Technician doesn?t have a SalesForce id, then determine the time zone based on the following logic.
            a. Get the time zone of the Working Hours;
            b. If not defined, get the time zone of the Territory?s Business Hours;
            c. If not defined, get the time zone of the Company?s Default Time Zone;

        Post Formatting the date time is returned in SP Format.
    **/
    private static String formatNonWODateTime (SVMXC__Service_Group_Members__c technician, Datetime nonWODateTime) {
        
        String timeZoneSIDKey;
        String spDateTimeFormat = 'yyyy-MM-dd\'T\'HH:mm';
        try{
            //Checks if the technician is associated with a salesforce user for time zone.
            String sfUserId = technician.SVMXC__Salesforce_User__c;
            if(String.isNotBlank(sfUserId)) {
                User sfUser = [SELECT ID,TimeZoneSidKey FROM USER WHERE ID = :sfUserId];
                timeZoneSIDKey = sfUser.TimeZoneSidKey;
                if(String.isNotBlank(timeZoneSIDKey)){
                    WSCH_AuditLogger.debug('Data Mapper : formatNonWODateTime : SFUserTimezone : '+timeZoneSIDKey);
                    return WSCH_DateUtils.formatDateTime(nonWODateTime, timeZoneSIDKey, spDateTimeFormat);
                }
            }
            
            //Check the business hours of the technician for time zone, if technician not found to be associted with sales force user.
            String workingHoursId = technician.SVMXC__Working_Hours__c;
            if(String.isNotBlank(workingHoursId)) {
                BusinessHours businessHours = getBusinessHoursById(workingHoursId).get(0);
                timeZoneSIDKey = businessHours.TimeZoneSidKey;
                if(String.isNotBlank(timeZoneSIDKey)){
                    WSCH_AuditLogger.debug('Data Mapper : formatNonWODateTime : TechBusinessHourTimeZone : '+timeZoneSIDKey);
                    return WSCH_DateUtils.formatDateTime(nonWODateTime, timeZoneSIDKey, spDateTimeFormat);
                }
            }
            
            //If time zone not found in the above scenario's looks territorry Business Hours for time zone.
            String territoryId = technician.SVMXC__Service_Territory__r.Id;
            if(String.isNotBlank(territoryId)){
                SVMXC__Territory__c territory = [SELECT ID,SVMXC__Territory_s_Business_Hours__c FROM SVMXC__Territory__c WHERE ID = :territoryId];
                if(String.isNotBlank(territory.SVMXC__Territory_s_Business_Hours__c)){
                    BusinessHours businessHours = getBusinessHoursById(territory.SVMXC__Territory_s_Business_Hours__c).get(0);
                    timeZoneSIDKey = businessHours.TimeZoneSidKey;
                }
                if(String.isNotBlank(timeZoneSIDKey)){
                    WSCH_AuditLogger.debug('Data Mapper : formatNonWODateTime : TerritoryBusinessHourTimeZone : '+timeZoneSIDKey);
                    return WSCH_DateUtils.formatDateTime(nonWODateTime, timeZoneSIDKey, spDateTimeFormat);
                }
            }
            
            //If timezone not found in all the above scenario.It is extracted from Company default business hour time zone.
            BusinessHours businessHours = [SELECT Id,TimeZoneSidKey FROM BusinessHours WHERE IsDefault = TRUE AND IsActive = TRUE LIMIT 1];
            timeZoneSIDKey = businessHours.TimeZoneSidKey;
            WSCH_AuditLogger.debug('Data Mapper : formatNonWODateTime : CompanyDefaultTimeZone : '+timeZoneSIDKey);
        }catch(Exception ex){
            WSCH_AuditLogger.error('WSCH_Provider_SP_DataMapper :: formatNonWODateTime :: ' + ex.getMessage() + '\n Stack Trace:: ' + ex.getStackTraceString());
        }
        return WSCH_DateUtils.formatDateTime(nonWODateTime, timeZoneSIDKey, spDateTimeFormat);
    }
    
    /**
    Following method to update the technicians of appointments corresponding to the externals Ids.
    This method will optimise the number of DML queries to fetch the technicians.
    **/
    private static void updateApptByTechId(List<WSCH_Appointment> appointments) {
        
        Set<String> externalIds = new Set<String>();
        try{
            for (WSCH_Appointment appointment : appointments ) {
                externalIds.add(appointment.getTechExternalId());
            }
            List<SVMXC__Service_Group_Members__c> technicians = [SELECT ID, Name, SVMXC__Optimizer_External_ID__c from SVMXC__Service_Group_Members__c where SVMXC__Optimizer_External_ID__c IN :externalIds];
            Map<String,SVMXC__Service_Group_Members__c> techByExternalId =new  Map<String,SVMXC__Service_Group_Members__c>();
            for(SVMXC__Service_Group_Members__c technician : technicians) {
                techByExternalId.put(technician.SVMXC__Optimizer_External_ID__c, technician);
            }
            //Populating technicians object in appointments.
            for (WSCH_Appointment appointment : appointments ) {
                appointment.setTechnician(techByExternalId.get(appointment.getTechExternalId()));
            }
        }catch(Exception ex){
            WSCH_AuditLogger.error('WSCH_Provider_SP_DataMapper :: updateApptByTechId :: ' + ex.getMessage() + '\n Stack Trace:: ' + ex.getStackTraceString());
        }
    }

    /**
        Following methods sets the boundary values for the dates of Offer appointment if the view type is calenadar.
    **/
    private static void resolveOfferApptDates(WSCH_Provider_SP_StubsV91.ApptOfferRequest apptOfferReq,SVMXC__Service_Order__c workOrder, WSCH_ApptParam apptParamObj, String strTimeZone){
        
        WSCH_AuditLogger.debug('Inside resolveOfferApptDates()');
        String viewType = 'List'; //Default Value
        Integer numberOfDays = 30; //Default Value

        String settingsViewType = WSCH_CommonUtils.getSettingValue('DCON003','SET006');
        viewType = String.isNotBlank(settingsViewType) ?  settingsViewType : viewType;

        //Don't set day related options if list view.
        if (viewType.equalsIgnoreCase('List')){
            return;
        }
        WSCH_Provider_SP_StubsV91.DateOptTime startDate = new WSCH_Provider_SP_StubsV91.DateOptTime();
        WSCH_Provider_SP_StubsV91.DateOptTime endDate = new WSCH_Provider_SP_StubsV91.DateOptTime();
        if(apptParamObj != null && apptParamObj.startDateTime != null && apptParamObj.endDateTime != null) {
            WSCH_AuditLogger.debug('WSCH_Provider_SP_DataMapper::resolveOfferApptDates:: apptParamObj: '+apptParamObj);
            startDate.date_x = WSCH_DateUtils.getDateFromDT(apptParamObj.startDateTime, strTimeZone, 'usr');
            startDate.time_x = WSCH_DateUtils.getTimeFromDT(apptParamObj.startDateTime, strTimeZone, 'usr');
                            
            endDate.date_x = WSCH_DateUtils.getDateFromDT(apptParamObj.endDateTime, strTimeZone, 'usr');
            endDate.time_x = WSCH_DateUtils.getTimeFromDT(apptParamObj.endDateTime, strTimeZone, 'usr');
            if(endDate.time_x =='0000'){
                endDate.time_x='2400';
            }
            apptOfferReq.start = startDate;
            apptOfferReq.end_x = endDate;
        } 
    }
    
    private static string getWOTimeZone(SVMXC__Service_Order__c workOrder){
        //get the time zone info from Work Order preferred business hours, if not available, get it from LoggedIn user
        String strTimeZone;
        List<BusinessHours> lstOfBusinessHours = new List<BusinessHours>();
        if(workOrder.SVMXC__Preferred_Business_Hours__c != null)
            lstOfBusinessHours = getBusinessHoursById(workOrder.SVMXC__Preferred_Business_Hours__c);
        
        if(lstOfBusinessHours != null && lstOfBusinessHours.size() > 0) {
            strTimeZone = lstOfBusinessHours[0].TimeZoneSidKey;
        } else if(UserInfo.getTimeZone() != null) {
            strTimeZone = String.valueOf(UserInfo.getTimeZone());
        }
        return strTimeZone;     
    } 
    
    private static String formatPreferredEndTime(String appointmentSlot){
        String[] strDateTimeSplit = appointmentSlot.split(',');
        String[] strSlotComponent = strDateTimeSplit[0].split('-');
        String strStartTime = strSlotComponent[0].trim();
        String strEndTime = strSlotComponent[1].trim();
        String strDate = strDateTimeSplit[1].trim();
        String strContractLatest=strDate+'T'+strEndTime;
        WSCH_AuditLogger.debug('WSCH_Provider_SP_DataMapper::formatPreferredEndTime:: strContractLatest: '+strContractLatest);
        return strContractLatest;
    }
    
    private static String formatPreferredStartTime(String appointmentSlot){
        String[] strDateTimeSplit = appointmentSlot.split(',');
        String[] strSlotComponent = strDateTimeSplit[0].split('-');
        String strStartTime = strSlotComponent[0].trim();
        String strEndTime = strSlotComponent[1].trim();
        String strDate = strDateTimeSplit[1].trim();
        String strContractEarliest=strDate+'T'+strStartTime;
        WSCH_AuditLogger.debug('WSCH_Provider_SP_DataMapper::formatPreferredStartTime:: strContractEarliest: '+strContractEarliest);
        return strContractEarliest;
    }    
    
    public static WSCH_Provider_SP_StubsV91.AccHoursPatts fetchAccHoursPatts(SVMXC__Service_Order__c workOrder,String startDate, String endDate, Integer tzOffsetinMinutes) { 
        WSCH_Provider_SP_StubsV91.AccHoursPatts objAccHoursPatts = new WSCH_Provider_SP_StubsV91.AccHoursPatts();
        WSCH_Provider_SP_StubsV91.AccHoursPatt accHrPatt = new WSCH_Provider_SP_StubsV91.AccHoursPatt();
        accHrPatt.dateRange = new WSCH_Provider_SP_StubsV91.DateRange();
        accHrPatt.dateRange.start = startDate;
        accHrPatt.dateRange.end_x = endDate;
        if(tzOffSetinMinutes == null || tzOffSetinMinutes == -1 || tzOffSetinMinutes == 1){
            accHrPatt.daysAndTimes = getDayTimePeriod(workOrder);   
        }else{
            accHrPatt.daysAndTimes = getDayTimePeriod(workOrder,tzOffsetinMinutes);
        }
        
        List<WSCH_Provider_SP_StubsV91.AccHoursPatt> accHoursPattLst = new List<WSCH_Provider_SP_StubsV91.AccHoursPatt>();
        accHoursPattLst.add(accHrPatt);
        objAccHoursPatts.accHoursPatt = accHoursPattLst;
        return objAccHoursPatts;        
    }

    public static List<WSCH_Provider_SP_StubsV91.DayAndTimePeriod> getDayTimePeriod(SVMXC__Service_Order__c workOrder,Integer tzOffsetinMinutes) {
        List<WSCH_Provider_SP_StubsV91.DayAndTimePeriod> weekTimes;
        List<BusinessHours> lstOfBusinessHours = new List<BusinessHours>();

        if(workOrder.SVMXC__Preferred_Business_Hours__c != null) {
            lstOfBusinessHours = getBusinessHoursById(workOrder.SVMXC__Preferred_Business_Hours__c);
        } else {
            lstOfBusinessHours = getBusinessHoursByWO(workOrder);
        }
        weekTimes=setWeekTimes(lstOfBusinessHours,tzOffsetinMinutes);
        return weekTimes;
    }

    public static String getSFMMappingId(String apiName) {
        String strMapId;
        List<SVMXC__ServiceMax_Properties__c> SPsettinglist = new List<SVMXC__ServiceMax_Properties__c>();
        String spUser,dbUser,dbPassWord;
        //caching SP private settings.
        if(WSCH_Constants.allSPsettinglist == NULL || WSCH_Constants.allSPsettinglist.size() == 0){
            WSCH_Constants.allSPsettinglist = [Select Name, SVMXC__Key__c, SVMXC__Value__c from SVMXC__ServiceMax_Properties__c where Name in ('SP001','SP002','SP003','SP004','SP005','SP006','SP007') ];
            //System.debug('WSCH_Constants.allSPsettinglist-->'+WSCH_Constants.allSPsettinglist);
        }
        SPsettinglist = WSCH_Constants.allSPsettinglist;
        
        for(SVMXC__ServiceMax_Properties__c setting :SPsettinglist)
        {
            if(setting.Name == 'SP004' && apiName.equals(WSCH_Constants.API_OFFER_APPT))
                strMapId = decryption1(setting.SVMXC__Value__c);

            if(setting.Name == 'SP005' && apiName.equals(WSCH_Constants.API_BOOK_APPT))
                strMapId = decryption1(setting.SVMXC__Value__c);

            if(setting.Name == 'SP006' && apiName.equals(WSCH_Constants.API_BOOK_JOB))
                strMapId = decryption1(setting.SVMXC__Value__c);

            if(setting.Name == 'SP007' && apiName.equals(WSCH_Constants.API_UPDATE_JOB))
                strMapId = decryption1(setting.SVMXC__Value__c);
        }
        WSCH_AuditLogger.debug('WSCH_Provider_SP_DataMapper::getSFMMappingId: '+strMapId);
        return strMapId;
    }
    //This Method fetches the SFM Mapping Id corresponding to the Work Order Connection Name
    public static String getSpSFMMappingId(String apiName, String strSpInstName) {
        String strMapId = '';
        String strMapVal = '';
        try{
            Map<String, SVMXC__ServiceMax_Properties__c> allSpSettings = new Map<String, SVMXC__ServiceMax_Properties__c>();
            SVMXC__ServiceMax_Properties__c instanceName = new SVMXC__ServiceMax_Properties__c();
            String strGBL23, strConNum, strDefaultConnNum;
            if(String.isNotBlank(strSpInstName)){
                allSpSettings = SVMXC__ServiceMax_Properties__c.getAll();
                if((allSpSettings != null) && (!allSpSettings.isEmpty())){
                    for(String strCon: allSpSettings.keySet()){
                        instanceName = allSpSettings.get(strCon);
                        if (('ServicePower Connection Name'.equalsIgnoreCase(instanceName.SVMXC__Key__c)) &&
                            ('true'.equalsIgnoreCase(allSpSettings.get('SP_CON_01_' + (instanceName.Name).right(2)).SVMXC__Value__c))){
                                if((strSpInstName.equalsIgnoreCase(instanceName.SVMXC__Value__c))){
                                    strConNum = (instanceName.Name).right(2);
                                    WSCH_AuditLogger.debug('WSCH_Provider_SP_DataMapper :: getSpSFMMappingId: connection name - ' + strConNum);
                                }
                            }
                    }
                    if(apiName.equals(WSCH_Constants.API_OFFER_APPT)){
                        strMapVal = allSpSettings.get('SP_API_11_' + strConNum).SVMXC__Value__c;
                        if (String.isNotBlank(strMapVal) && (!strMapVal.containsIgnoreCase('--None--'))){
                            strMapId = allSpSettings.get('SP_API_11_' + strConNum).SVMXC__Value__c;
                            //strMapId = decryption1(allSpSettings.get('SP_API_11_' + strConNum).SVMXC__Value__c);
                        }
                    }else if(apiName.equals(WSCH_Constants.API_BOOK_APPT)){
                        strMapVal = allSpSettings.get('SP_API_12_' + strConNum).SVMXC__Value__c;
                        if (String.isNotBlank(strMapVal) && (!strMapVal.containsIgnoreCase('--None--'))){
                            strMapId = allSpSettings.get('SP_API_12_' + strConNum).SVMXC__Value__c;
                            //strMapId = decryption1(allSpSettings.get('SP_API_12_' + strConNum).SVMXC__Value__c);
                        }
                    }else if(apiName.equals(WSCH_Constants.API_BOOK_JOB)){
                        strMapVal = allSpSettings.get('SP_API_13_' + strConNum).SVMXC__Value__c;
                        if (String.isNotBlank(strMapVal) && (!strMapVal.containsIgnoreCase('--None--'))){
                            strMapId = allSpSettings.get('SP_API_13_' + strConNum).SVMXC__Value__c;
                            //strMapId = decryption1(allSpSettings.get('SP_API_13_' + strConNum).SVMXC__Value__c);
                        }
                    }else if(apiName.equals(WSCH_Constants.API_UPDATE_JOB)){
                        strMapVal = allSpSettings.get('SP_API_14_' + strConNum).SVMXC__Value__c;
                        if (String.isNotBlank(strMapVal) && (!strMapVal.containsIgnoreCase('--None--'))){
                            strMapId = allSpSettings.get('SP_API_14_' + strConNum).SVMXC__Value__c;
                            //strMapId = decryption1(allSpSettings.get('SP_API_14_' + strConNum).SVMXC__Value__c);
                        }
                    }   
                }else{
                    WSCH_AuditLogger.ERROR('WSCH_Provider_SP_DataMapper :: getSpSFMMappingId: No Valid Connection Name');
                    throw new WSCH_EXCEPTION('WSCH_Provider_SP_DataMapper :: getSpSFMMappingId: No Valid Connection Name');
                }
            }
            //if No Valid Connection details, then get the API Mapping from GBL023 settings(Old Data Model)
            else{
                strMapId = getSFMMappingId(apiName);
            }
        }catch(Exception ex){
            strMapId = '';
            WSCH_AuditLogger.error('WSCH_Provider_SP_DataMapper :: getSpSFMMappingId :: ' + ex.getMessage() + '\n Stack Trace:: ' + ex.getStackTraceString());
        }
        WSCH_AuditLogger.debug('WSCH_Provider_SP_DataMapper::getSpSFMMappingId: '+strMapId + ' apiName: ' + apiName +' strSpInstName: ' + strSpInstName);
        return strMapId;
    }
    
    public static map<String,Object> getSmartObjectRecords(String strMapId, SVMXC__Service_Order__c workOrder) {
        Map<Object,Object> SourceRecIdTargetObjMap  = new Map<Object,Object>();
        SourceRecIdTargetObjMap.put(workOrder, null);
        
        Map<String,Schema.SObjectType> AllSFDCObj = Schema.getGlobalDescribe();
        Map<String,SmartObject.DescribeSmartObjectResult> AllSMARTObj = SmartObject.getGlobalDescribe();
        
        Map<String,Object> AdditionalParams = new Map<String,Object>();
        AdditionalParams.put('GetGlobalDescribe', AllSFDCObj);
        AdditionalParams.put('GetSmartObjectDescribe', AllSMARTObj);
        AdditionalParams.put('DO_POPULATE_OWNER','false');
        SFM_ApplyMapping objSFM_ApplyMapping = new SFM_ApplyMapping();
        map<String,Object> mapResult = objSFM_ApplyMapping.applyObjectMapping(strMapId, SourceRecIdTargetObjMap, AdditionalParams);
        map<String,Object> mapfieldvalues;
        if(mapResult != null && mapResult.size() > 0)
            mapfieldvalues = ((SmartObject.SmartObjectRecord)mapResult.get(workOrder.Id)).mapTargetRecordFieldValues;
        
        //WSCH_AuditLogger.debug('WSCH_Provider_SP_DataMapper::getSmartObjectRecords: mapfieldvalues: '+mapfieldvalues);
        if(null != mapfieldvalues && mapfieldvalues.size() > 0) {
            return mapfieldvalues;
        }
        return null;
    }
    
    public static WSCH_Provider_SP_StubsV91.ClosedAccHoursOvrs getClosedAccHoursOvrs(SVMXC__Service_Order__c workOrder, String strStartDate, String strEndDate, Integer tzOffsetinMinutes) {
        WSCH_AuditLogger.debug('WSCH_Provider_SP_DataMapper::getClosedAccHoursOvrs()::Start: No of Queries used in this transaction so far: ' + Limits.getQueries());
        WSCH_AuditLogger.debug('WSCH_Provider_SP_DataMapper::getClosedAccHoursOvrs: start');
        
        List<BusinessHours> lstOfBusinessHours = new List<BusinessHours>();
        if(workOrder.SVMXC__Preferred_Business_Hours__c != null) {
            lstOfBusinessHours = getBusinessHoursById(workOrder.SVMXC__Preferred_Business_Hours__c);
        } else {
            lstOfBusinessHours = getBusinessHoursByWO(workOrder);
        }
        
        BusinessHours businessHr = lstOfBusinessHours.get(0);
        WSCH_AuditLogger.debug('businessHr - ' + businessHr);
        
        Date startDate, endDate;
        
        if((strStartDate != null && String.isNotEmpty(strStartDate)) && (strEndDate != null && String.isNotEmpty(strEndDate))) {
            startDate = Date.valueOf(strStartDate);
            endDate = Date.valueOf(strEndDate);
        } else {
            Datetime startTime;
            if(null != workOrder.SVMXC__Preferred_Start_Time__c){
                startTime = workOrder.SVMXC__Preferred_Start_Time__c;
            } else {
                startTime = Datetime.now();
            }
            
            Datetime endTime = startTime.addDays(Integer.valueOf(strNoOfDays));
            if(null != workOrder.SVMXC__Preferred_End_Time__c && workOrder.SVMXC__Preferred_End_Time__c > endTime){
                endTime = workOrder.SVMXC__Preferred_End_Time__c;
            }
            
            startDate = startTime.dateGMT();
            endDate = endTime.dateGMT();
        }
        WSCH_Provider_SP_StubsV91.ClosedAccHoursOvrs closedAccHoursOvrs = new WSCH_Provider_SP_StubsV91.ClosedAccHoursOvrs();
        closedAccHoursOvrs.closedHours = WSCH_CommonUtils.getClosedHours(startDate, endDate, businessHr, tzOffSetinMinutes);
        
        WSCH_AuditLogger.debug('WSCH_Provider_SP_DataMapper::getClosedAccHoursOvrs: startDate - ' + startDate);
        WSCH_AuditLogger.debug('WSCH_Provider_SP_DataMapper::getClosedAccHoursOvrs: endDate - ' + endDate);
        
        WSCH_AuditLogger.debug('WSCH_Provider_SP_DataMapper::getClosedAccHoursOvrs()::End: No of Queries used in this transaction so far: ' + Limits.getQueries());
        
        return closedAccHoursOvrs;
    }
    /*
        This method fetches the Technician details and MPX status of the Technician for the WorkOrder.
        This method respects the contraint of ONLY 10 Technicians to be sent to ServicePower.
    */
    private static WSCH_Provider_SP_StubsV91.ListReqEmps fetchListReqEmps(Id woID, String strPrefTechExtId){

        WSCH_Provider_SP_StubsV91.ReqEmp reqEmp;
        List<String> lstTech = new List<String>();
        List<WSCH_Provider_SP_StubsV91.ReqEmp> lstEmp = new List<WSCH_Provider_SP_StubsV91.ReqEmp>();
        WSCH_Provider_SP_StubsV91.ListReqEmps listReqEmp = new WSCH_Provider_SP_StubsV91.ListReqEmps();
        Integer lstSize = 0;
        Boolean isOnlyPreferred = true;
        try{
            //if(WORD_Service_Order_Resources.getResourcePreferenceSetting()){
                if(!WSCH_Provider_SP_RealTimeOptimizer.mapWrkOrdResPref.isEmpty()){
                    lstTech = WSCH_Provider_SP_RealTimeOptimizer.mapWrkOrdResPref.get(woID);
                }
                List<String> lstProcess = processList(lstTech);
                lstSize = (lstProcess.size() > WSCH_Constants.TECH_MPX_SIZE ? WSCH_Constants.TECH_MPX_SIZE : lstProcess.size());
                for(Integer i=0; i<lstSize; i++){
                    reqEmp = new WSCH_Provider_SP_StubsV91.ReqEmp();
                    reqEmp.empID = lstProcess[i].split('=',0).get(0);
                    reqEmp.MPX = getServicePowerMPXString(lstProcess[i].split('=',0).get(1));
                    lstEmp.add(reqEmp);
                    if((strPrefTechExtId != null) && (lstProcess[i].containsIgnoreCase('Mandatory') || lstProcess[i].containsIgnoreCase(strPrefTechExtId))){
                        isOnlyPreferred = false;
                    }
                }
            //}
            if((strPrefTechExtId != null) && (lstEmp.size() < WSCH_Constants.TECH_MPX_SIZE) && isOnlyPreferred){
                reqEmp = new WSCH_Provider_SP_StubsV91.ReqEmp();
                reqEmp.empID = strPrefTechExtId;
                reqEmp.MPX = 'Preferred';
                lstEmp.add(reqEmp);
            }
            if(lstEmp.size()>0){
            listReqEmp.reqEmp = lstEmp;
            }
            else{
                listReqEmp = null;
            }
            WSCH_AuditLogger.DEBUG('WSCH_Provider_SP_DataMapper: WOID: ' + woID + ' : lstEmp: ' + lstEmp);
        }catch(Exception ex){
                String exceptionMsg = 'WSCH_Provider_SP_DataMapper :: fetchListReqEmps() :: ';
                WSCH_AuditLogger.error(exceptionMsg+ex.getMessage() + '\n Stack Trace:: ' + ex.getStackTraceString());
        }
        return listReqEmp;
    }
     /*
      * This method returns the list of technicians on the basis of their preferences.
      * The Order of Preference is as: Mandatory, then Prohibited and then Preferred.
      */
    private static List<String> processList(List<String> lstStr){
        List<String> lstReturn = new List<String>();
        //Select only the MANDATORY Technicians.
        try{
            for(String str: lstStr){
                if(str.containsIgnoreCase('Mandatory')){
                    lstReturn.add(str);
                }
            }
            //If No Mandatory technicians then Select Prohibited Technicians.
            if(lstReturn.isEmpty()){
                for(String str: lstStr){
                    if(str.containsIgnoreCase('Prohibited')){
                        lstReturn.add(str);
                    }
                }
                //At last add the rest of the Technicians other than Mandatory or Prohibited.
                for(String str: lstStr){
                    if(!(str.containsIgnoreCase('Prohibited') || str.containsIgnoreCase('Mandatory'))){
                        lstReturn.add(str);
                    }
                }
            }

        }catch(Exception ex){
            String exceptionMsg = 'WSCH_Provider_SP_DataMapper :: processList() :: ';
            WSCH_AuditLogger.error(exceptionMsg+ex.getMessage() + '\n Stack Trace:: ' + ex.getStackTraceString());
        }
        //If No Mandatory, and No Prohibited technicians then return the original list.
        if(lstReturn.isEmpty()){
            return lstStr;
        }else{
            return lstReturn;
        }
     }
    
    public static WSCH_Provider_SP_StubsV91.BookDependencyGroupRequest mapBookDependencyGroupRequest(String multiJobId, List<SVMXC__Service_Order_Dependency__c>  service_Order_Group_Dependency) {

        WSCH_AuditLogger.debug('WSCH_Provider_SP_DataMapper::BookDependencyGroupRequest()::Start: No of Queries used in this transaction so far: ' + Limits.getQueries());
        
        WSCH_Provider_SP_StubsV91.BookDependencyGroupRequest request_x = new WSCH_Provider_SP_StubsV91.BookDependencyGroupRequest();
        request_x.login = fetchLoginInfo();
        
        Set<String> WO_Ids = new Set<String>();
        Map<Id, SVMXC__Service_Order__c> workOrderMap = new Map<Id, SVMXC__Service_Order__c>();

        for(SVMXC__Service_Order_Dependency__c groupDependencyRecords: service_Order_Group_Dependency){
            WO_Ids.add(string.valueof(groupDependencyRecords.SVMXC__Primary_Work_Order__c));
            WO_Ids.add(string.valueof(groupDependencyRecords.SVMXC__Secondary_Work_Order__c));
        }
        List<String> WoIdList = new List<String>();
        WoIdList.addAll(WO_Ids);
        /*
        Map<String, Schema.SObjectField> fieldMap = Schema.SObjectType.SVMXC__Service_Order__c.fields.getMap();
        String workOrderFields;// = String.valueof(fieldMap.keyset());
        //workOrderFields = workOrderFields.replace('{','');
        //workOrderFields = workOrderFields.replace('}','');

        for(String s : fieldMap.keySet()) {
            if(workOrderFields == null){
                workOrderFields = s + ',';
            }
            else{
                workOrderFields += s + ',';
            }
        }

        workOrderFields =workOrderFields.removeEnd(',');
                
        String queryString;
        queryString = 'SELECT '+workOrderFields+',SVMXC__Preferred_Technician__r.SVMXC__Optimizer_External_ID__c, SVMXC__Company__r.AccountNumber, SVMXC__Company__r.Name, SVMXC__Company__r.Id, SVMXC__Site__r.Name, SVMXC__Contact__r.FirstName, SVMXC__Contact__r.LastName, SVMXC__Contact__r.Phone From SVMXC__Service_Order__c where Id IN : '+ 'WO_Ids';
        woList = Database.query(queryString);*/
        woList = WSCH_CommonUtils.fetchWorkOrders(WoIdList);
        System.debug('woList-->'+woList);
        for(SVMXC__Service_Order__c WO: woList){
            workOrderMap.put(WO.id, WO);
        }
        
        if(String.isBlank(request_x.multiJobID)) {
            request_x.multiJobID = multiJobId;
        }
        
        WSCH_Provider_SP_StubsV91.BDGBookOptions bookOption = new WSCH_Provider_SP_StubsV91.BDGBookOptions();
        bookOption.AllowRebookAll = true;
        request_x.bookOptions = bookOption;
        List<WSCH_Provider_SP_StubsV91.BDGJob> bookDependencyGroupWorkOrder = new List<WSCH_Provider_SP_StubsV91.BDGJob>();
        List<WSCH_Provider_SP_StubsV91.JobDep> dependencyPairDetail = new List<WSCH_Provider_SP_StubsV91.JobDep>();
        
        for(SVMXC__Service_Order__c dependentWO: workOrderMap.values()){
           /* SVMXC__Service_Order__c depWorkOrder = new SVMXC__Service_Order__c();
            SVMXC__Service_Order__c targetWorkOrder = new SVMXC__Service_Order__c();
            depWorkOrder = workOrderMap.get(bookDependencyPair.SVMXC__Primary_Work_Order__c);
            targetWorkOrder = workOrderMap.get(bookDependencyPair.SVMXC__Secondary_Work_Order__c);
            System.debug('depWorkOrder-->'+depWorkOrder);
            System.debug('targetWorkOrder-->'+targetWorkOrder);*/
            if(isBooked(dependentWO)){
                if(dependentWO.SVMXC__Dependency_Group__c!=null){
                    bookDependencyGroupWorkOrder.add(getBookDependencyGroupWorkOrderDetail(dependentWO));
                }
            }
            else{
                bookDependencyGroupWorkOrder.add(getBookDependencyGroupWorkOrderDetail(dependentWO));
            }            
            
        }
        for(SVMXC__Service_Order_Dependency__c bookDependencyPair: service_Order_Group_Dependency){
            dependencyPairDetail.add(WorkOrderDependency(bookDependencyPair));
        }
        request_x.job = bookDependencyGroupWorkOrder;
        request_x.jobDep = dependencyPairDetail;
        system.debug('dataMapper::request_x-->'+request_x);
        return request_x;
}

public static boolean isBooked(SVMXC__Service_Order__c workOrdr){
    if(workOrdr.SVMXC__Work_Order_Scheduling_Status__c != null && workOrdr.SVMXC__Dispatch_Status__c == null && workOrdr.SVMXC__Dispatch_Status__c == 'Assigned'){
        return true;
    }
    else{
        return false;
    }
}

public static WSCH_Provider_SP_StubsV91.BDGJob getBookDependencyGroupWorkOrderDetail(SVMXC__Service_Order__c dependencyGroupWO){

    WSCH_Provider_SP_StubsV91.JobBookRequest bookJobRequest = mapBookJobRequest(dependencyGroupWO);
    WSCH_Provider_SP_StubsV91.BDGJob bookDependencyGroupWOrequest = new WSCH_Provider_SP_StubsV91.BDGJob();
    bookDependencyGroupWOrequest.jobID = dependencyGroupWO.Name;
    bookDependencyGroupWOrequest.jobType = bookJobRequest.jobType; 
    bookDependencyGroupWOrequest.postcode = bookJobRequest.postcode;
    bookDependencyGroupWOrequest.allowRebook = bookJobRequest.allowRebook;
    bookDependencyGroupWOrequest.extraDuration = bookJobRequest.extraDuration;
    bookDependencyGroupWOrequest.extraOverhead = bookJobRequest.extraOverhead;
    if((bookJobRequest.extraSkills != null) && ( bookJobRequest.extraSkills.reqSkills != null)){
        bookDependencyGroupWOrequest.extraSkills = bookJobRequest.extraSkills;
    }
    bookDependencyGroupWOrequest.reqEmps = bookJobRequest.reqEmps;
    WSCH_AuditLogger.debug('ReqEmps-->'+bookJobRequest.listReqEmps);
    if((bookJobRequest.listReqEmps != null) && ( bookJobRequest.listReqEmps.reqEmp != null)){
        bookDependencyGroupWOrequest.listReqEmps = bookJobRequest.listReqEmps;
    }
    bookDependencyGroupWOrequest.priority = bookJobRequest.priority;
    bookDependencyGroupWOrequest.importance = bookJobRequest.importance;
    bookDependencyGroupWOrequest.contractEarliest = bookJobRequest.contractEarliest;
    bookDependencyGroupWOrequest.contractLatest = bookJobRequest.contractLatest;
    bookDependencyGroupWOrequest.accHoursPatts = bookJobRequest.accHoursPatts;
    bookDependencyGroupWOrequest.closedAccHoursOvrs = bookJobRequest.closedAccHoursOvrs;
    bookDependencyGroupWOrequest.siteID = bookJobRequest.siteID;
    bookDependencyGroupWOrequest.customer = bookJobRequest.customer;
    
    return bookDependencyGroupWOrequest;
}

public static WSCH_Provider_SP_StubsV91.JobDep WorkOrderDependency(SVMXC__Service_Order_Dependency__c dependentWOs){
    WSCH_Provider_SP_StubsV91.JobDep depWOdetails = new WSCH_Provider_SP_StubsV91.JobDep();
    depWOdetails.targJobID = dependentWOs.SVMXC__Primary_Work_Order__r.Name;
    if(dependentWOs.SVMXC__Time_Dependency__c == 'Set Arrival Time of Secondary relative to the Arrival Time of Primary'){
        depWOdetails.depJobsTime = 'ETA';
        depWOdetails.targJobsTime = 'ETA';
    }
    else if(dependentWOs.SVMXC__Time_Dependency__c == 'Set End Time of Secondary relative to the End Time of Primary'){
        depWOdetails.depJobsTime = 'ETF';
        depWOdetails.targJobsTime = 'ETF';
    }
    else if(dependentWOs.SVMXC__Time_Dependency__c == 'Set End Time of Secondary relative to the Arrival Time of Primary'){
        depWOdetails.depJobsTime = 'ETF';
        depWOdetails.targJobsTime = 'ETA';
    }
    else if(dependentWOs.SVMXC__Time_Dependency__c == 'Set Arrival Time of Secondary relative to the End Time of Primary'){
        depWOdetails.depJobsTime = 'ETA';
        depWOdetails.targJobsTime = 'ETF';
    }
    //depWOdetails.depJobsTime = dependentWOs.SVMXC__Dependent_Scheduled_Time__c;
    
    depWOdetails.depJobID = dependentWOs.SVMXC__Secondary_Work_Order__r.Name;
    //depWOdetails.targJobsTime = dependentWOs.SVMXC__Target_Scheduled_Time__c;

    depWOdetails.earliestTime = integer.valueof(dependentWOs.SVMXC__Maximum_Time_Deviation__c);
    if(dependentWOs.SVMXC__Maximum_Time_Deviation_Units__c == 'Minutes'){
        depWOdetails.earliestTimeUnits = 'mins';
    }
    else if(dependentWOs.SVMXC__Maximum_Time_Deviation_Units__c == 'Hours'){
        depWOdetails.earliestTimeUnits = 'hours';
    }
    else if(dependentWOs.SVMXC__Maximum_Time_Deviation_Units__c == 'Days'){
        depWOdetails.earliestTimeUnits = 'days';
    }

    depWOdetails.latestTime = integer.valueof(dependentWOs.SVMXC__Minimum_Time_Deviation__c);
    if(dependentWOs.SVMXC__Minimum_Time_Deviation_Units__c == 'Minutes'){
        depWOdetails.latestTimeUnits = 'mins';
    }
    else if(dependentWOs.SVMXC__Minimum_Time_Deviation_Units__c == 'Hours'){
        depWOdetails.latestTimeUnits = 'hours';
    }
    else if(dependentWOs.SVMXC__Minimum_Time_Deviation_Units__c == 'Days'){
        depWOdetails.latestTimeUnits = 'days';
    }

    depWOdetails.targetTime = integer.valueof(dependentWOs.SVMXC__Targeted_Time_Difference__c);
    if(dependentWOs.SVMXC__Targeted_Time_Difference_Units__c == 'Minutes'){
        depWOdetails.targetTimeUnits = 'mins';
    }
    else if(dependentWOs.SVMXC__Targeted_Time_Difference_Units__c == 'Hours'){
        depWOdetails.targetTimeUnits = 'hours';
    }
    else if(dependentWOs.SVMXC__Targeted_Time_Difference_Units__c == 'Days'){
        depWOdetails.targetTimeUnits = 'days';
    }

    depWOdetails.costID = dependentWOs.SVMXC__Targeted_Time_Variance_Cost_ID__c;
    if(dependentWOs.SVMXC__Resource_Dependency__c == 'Different Resource'){
        depWOdetails.depEmpType = 'diff';
    }else if(dependentWOs.SVMXC__Resource_Dependency__c == 'Same Resource'){
        depWOdetails.depEmpType = 'same';
    }else{
        depWOdetails.depEmpType = 'none';
    }       
    
    return depWOdetails;
}

    public static void mapBookBookDependencyGroupResponse(SVMXC__Dependency_Management__c dependencyManagementRecord, List<Service_Order_Dependency__c> serviceOrderList, WSCH_Provider_SP_StubsV91.BookDependencyGroupResponse bookDependencyResponse) {
        String errorText=null;
        if (bookDependencyResponse != null) {
            WSCH_Provider_SP_StubsV91.ReturnCode returnCode = bookDependencyResponse.result;
            system.debug('WSCH_Provider_SP_ErrorCodesMapper.isSuccess(returnCode.code)-->'+WSCH_Provider_SP_ErrorCodesMapper.isSuccess(returnCode.code));
            //based on the response code set the appropriate message on the WO Optimax status.
            List<SVMXC__Service_Order__c> dependencyGroupWoList = new List<SVMXC__Service_Order__c>();
            if(WSCH_Provider_SP_ErrorCodesMapper.isSuccess(returnCode.code)){
                
                dependencyManagementRecord.SVMXC__Status__c= WSCH_Constants.STATUS_OPT_COMPLETED;
                for(SVMXC__Service_Order__c WO: woList){
                    //if(WO.SVMXC__Dependency_Group__c == null){
                    if(!WSCH_Provider_SP_RealTimeOptimizer.mapWoConName.isEmpty()){
                        WO.SVMXC__Optimizer_Connection_Name__c = WO.SVMXC__Optimizer_Connection_Name__c == null?WSCH_Provider_SP_RealTimeOptimizer.mapWoConName.get(WO.Id):WO.SVMXC__Optimizer_Connection_Name__c;
                    }
                    WO.SVMXC__OptiMax_Status__c = WSCH_Constants.STATUS_OPT_TENTATIVE;
                    WO.SVMXC__Dependency_Group__c = serviceOrderList[0].SVMXC__Dependency_Group__c;
                    //WO.SVMXC__OptiMax_Error_Text__c = system.label.DCON003_TAG099;
                    system.debug('WO.SVMXC__OptiMax_Error_Text__c-->' + WO.SVMXC__OptiMax_Error_Text__c);
                    WSCH_CommonUtils.setOptimizerErrorText(WO, system.label.DCON003_TAG099);
                    system.debug('1WO.SVMXC__OptiMax_Error_Text__c-->' + WO.SVMXC__OptiMax_Error_Text__c);
                    system.debug('WO.SVMXC__Dependency_Group__c-->' + WO.SVMXC__Dependency_Group__c);
                    dependencyGroupWoList.add(WO);
                    //}
                }
                Set<Id> WoIds = new Set<Id>();
                for(Service_Order_Dependency__c svcOrdrRecord: serviceOrderList){
                    WoIds.add(svcOrdrRecord.SVMXC__Primary_Work_Order__c);
                    WoIds.add(svcOrdrRecord.SVMXC__Secondary_Work_Order__c);
                }
                System.debug('Datamapper:WoIds-->'+WoIds);
                List<SVMXC__Service_Order__c> oldWoList = new List<SVMXC__Service_Order__c>();
                Map<String, Schema.SObjectField> fieldMap = Schema.SObjectType.SVMXC__Service_Order__c.fields.getMap();
                String serviceOrderFields;
                for(String s : fieldMap.keySet()) {
                    if(serviceOrderFields == null){
                        serviceOrderFields = s + ',';
                    }
                    else{
                        serviceOrderFields += s + ',';
                    }
                }
                serviceOrderFields =serviceOrderFields + ' SVMXC__Dependency_Group__r.Name';
                List<Id> workorderIds = new List<Id>();
                workorderIds.addAll(WoIds);
                String queryString;
                String dependencyManagementRecordId = dependencyManagementRecord.Id;
                WSCH_AuditLogger.debug('Datamapper::dependencyManagementRecordId:'+dependencyManagementRecordId+'  workorderIds:'+workorderIds);
                queryString = 'SELECT '+serviceOrderFields+' From SVMXC__Service_Order__c where SVMXC__Dependency_Group__c =: '+ 'dependencyManagementRecordId'+' AND Id NOT IN: '+'workorderIds';
                oldWoList = Database.query(queryString);
                WSCH_AuditLogger.debug('Datamapper:oldWoList:'+oldWoList);
                //oldWoList = [SELECT Id, name, SVMXC__Dependency_Group__c from SVMXC__Service_Order__c where SVMXC__Dependency_Group__c=: dependencyManagementRecord.Id AND Id NOT IN: WoIds];
                Set<SVMXC__Service_Order__c> updateOldWoSet = new Set<SVMXC__Service_Order__c>();
                if(oldWoList != null){
                    for(SVMXC__Service_Order__c changeWO: oldWoList){
                        changeWO.SVMXC__Dependency_Group__c = null;
                        changeWO.SVMXC__Scheduling_Change_Token__c = 'CHANGE_CANCEL_WO';
                        updateOldWoSet.add(changeWO);
                    }
                    deleteRelatedEventsFromOldDependendentWO(updateOldWoSet);
                } 
            }else{
                dependencyManagementRecord.SVMXC__Status__c= WSCH_Constants.STATUS_OPT_ERROR;
                
                for(SVMXC__Service_Order__c WO: woList){
                        WO.SVMXC__OptiMax_Status__c = WSCH_Constants.STATUS_OPT_ERROR;
                        //WO.SVMXC__OptiMax_Error_Text__c = system.label.DCON003_TAG100;
                        WSCH_CommonUtils.setOptimizerErrorText(WO, system.label.DCON003_TAG100);
                        dependencyGroupWoList.add(WO);
                }
            }
            errorText = 'Return Code:' + returnCode.code + ' | Return Type:' + returnCode.type_x + ' | Return Note:' + returnCode.errNote + ' | Return Msg:' + WSCH_Provider_SP_ErrorCodesMapper.getStatusMsg(returnCode.code);
            system.debug('errorText-->'+errorText);
            WSCH_CommonUtils.setOptimizerErrorText(dependencyManagementRecord, errorText);
            WSCH_OptimizedSchedulingService.triggerExecuted = true;
            
            if(dependencyGroupWoList != null && dependencyGroupWoList.size() > 0) {
	            if( COMM_SecurityUtils.getInstance().verifyFieldAccess( dependencyGroupWoList, COMM_SecurityUtils.Access.Updateable) ) {
	            	update dependencyGroupWoList; 
	            }
        	}
            
            if(dependencyManagementRecord != null) {
	            if( COMM_SecurityUtils.getInstance().verifyFieldAccess( dependencyManagementRecord, COMM_SecurityUtils.Access.Updateable) ) {
	            	update dependencyManagementRecord; 
	            }
        	}
        }
        else {
            WSCH_AuditLogger.error('Failed to map return code for book dependency group as response is null.');
        }
    }
    
    public static void deleteRelatedEventsFromOldDependendentWO(Set<SVMXC__Service_Order__c> workOrders) {
        List<String> cancelWoList = new List<String>();
        List<SVMXC__Service_Order__c> cancelAndUpdateOldDependencyWOs = new List<SVMXC__Service_Order__c>();
        for(SVMXC__Service_Order__c workOrder : workOrders) {
            if(workOrder.SVMXC__Scheduling_Change_Token__c != NULL && workOrder.SVMXC__Scheduling_Change_Token__c.equalsIgnoreCase('CHANGE_CANCEL_WO')) {
                if(workOrder.SVMXC__Group_Member__c != NULL){
                    workOrder.SVMXC__Last_Dispatch_Event__c = 'UnAssigned';
                }
                if(workOrder.SVMXC__Group_Member__c == NULL && workOrder.SVMXC__Service_Group__c != NULL){
                    workOrder.SVMXC__Last_Dispatch_Event__c = 'UnQueued';
                }
                workOrder.SVMXC__Service_Group__c = NULL;
                workOrder.SVMXC__Group_Member__c = NULL;
                workOrder.SVMXC__Scheduled_Date_Time__c = NULL;
                workOrder.SVMXC__Scheduled_Date__c = NULL;
                workOrder.SVMXC__Work_Order_Scheduling_Status__c = 'Cancelled';
                workOrder.SVMXC__Appointment_Promised_Time_Slot__c = null;
                cancelWoList.add(workOrder.Id);
                cancelAndUpdateOldDependencyWOs.add(workOrder);
            }
        }
        WSCH_AuditLogger.debug('WSCH_CommonUtils:deleteWORelatedEventsOnCancel:cancelWoList ' + cancelWoList);
        if (cancelWoList.size() > 0){
            List<Event> SalesforceEventList = new List<Event>();
            SalesforceEventList = [SELECT Id from Event where WhatId IN :cancelWoList];
            WSCH_AuditLogger.debug('WSCH_CommonUtils:deleteWORelatedEventsOnCancel:SalesforceEventList ' + SalesforceEventList);
            List<SVMXC__SVMX_Event__c> ServiceMaxEventList = new List<SVMXC__SVMX_Event__c>();
            ServiceMaxEventList = [SELECT Id from SVMXC__SVMX_Event__c where SVMXC__WhatId__c IN :cancelWoList];
            WSCH_AuditLogger.debug('WSCH_CommonUtils:deleteWORelatedEventsOnCancel:ServiceMaxEventList ' + ServiceMaxEventList);
            WSCH_OptimizedSchedulingService.triggerExecuted = true;
            //if(SalesforceEventList.size()>0)delete SalesforceEventList;
            //if(ServiceMaxEventList.size()>0)delete ServiceMaxEventList;
            if(SalesforceEventList.size()>0)WSCH_CRUD_Helper.deleteListEvents(SalesforceEventList);
            if(ServiceMaxEventList.size()>0)WSCH_CRUD_Helper.deleteListEvents(ServiceMaxEventList);
        }
        //update cancelAndUpdateOldDependencyWOs;
        // -CRUD
        if( COMM_SecurityUtils.getInstance().verifyFieldAccess( cancelAndUpdateOldDependencyWOs, COMM_SecurityUtils.Access.Updateable) ) {
            update cancelAndUpdateOldDependencyWOs;
        } else {
            throw new COMM_SecurityUtils.SecurityAccessException( System.Label.COMM001_TAG142 );
        }       
    }
    
    public static WSCH_Provider_SP_StubsV91.CancelDependencyGroupRequest mapCancelBookDependencyGroupRequest(String multiJobId){
        WSCH_Provider_SP_StubsV91.CancelDependencyGroupRequest request_x = new WSCH_Provider_SP_StubsV91.CancelDependencyGroupRequest();
        request_x.login = fetchLoginInfo();
        request_x.multiJobID = multiJobId;
        return request_x;
    }
}