/**
 * The EVER_WOEntitlementImpl is a Service class that processes requests for Work Order/Product Serviced
 * Line Manual Entitlement Process.  
 * 
 *
 * @author Sachin S
 * @version 
 * @since 2016
 */
/*****************************************************************************************************
 *    ID        Name                   Date            Comment
 *****************************************************************************************************
 *              Sachin S               01 Mar 2016     Created.
 *****************************************************************************************************/


public with sharing class EVER_WOEntitlementImpl{

    Static Boolean matchContact;
    Static Boolean matchLocation;
    Static Boolean entitlementSupportOnLines;
    Static Boolean showExpiredEntitlement;
    Static Boolean showFutureEntitlement;
    Static Boolean coverageOnParentProduct; 
    Static Boolean coverageOnTopLevelProduct;
    Static Boolean coverageOnChildProduct;
    Static Boolean matchAccount;
    Static String sLAandValidityLevels;
    Static Boolean coverageOnPartProduct;
    Static Boolean coverageOnProductFamily;
    Static Boolean coverageOnProductLine;
    Static Date effectiveDateForEntitlement;
    Static Boolean serviceBasedEntitlement;
    Static Boolean showAllServices; 
    Static String entUsingWarrantyOrSC;
    Static String considerCountersOrDates;
    Static Map<String,String> settingsValueMap = new Map<String,String> {'SET001' => '', 'SET002' => '', 'SET003' => '', 'SET004' => '', 'SET005' => '',
                                                                    'SET006' => '', 'SET007' => '', 'SET008' => '', 'SET009' => '', 'SET010' => '',
                                                                    'SET011' => '', 'SET012' => '', 'SET013' => '', 'SET016' => '', 'SET017' => '','SET019' => '',
                                                                    'SET020' => '', 'SET021' => '', 'SET022' => '', 'SET023' => '', 'SET024' => '','SET026' => ''
                                                                    ,'SET027' => '' ,'SET028' => '','SET029'=> ''};
    @testVisible Map<String, String> AllSubModuleSettings = new Map<String, String>();      
    Map<Id,SVMXC__Entitlement_History__c> entitlementHistoryMap;                                                             
    
    public EVER_WOEntitlementImpl(){
        if(!Test.isRunningTest()){
            SVMXC.COMM_Utils_ManageSettings settings = new SVMXC.COMM_Utils_ManageSettings();
            AllSubModuleSettings = settings.SVMX_getSettingList('EVER005');
        }        
    }
        
    public EVER_WrapperDef.EVER_Response getWOEntitlementSettings() {
        EVER_WrapperDef.EVER_Settings defaultSettingValues = new EVER_WrapperDef.EVER_Settings(); 
        EVER_WrapperDef.EVER_Response response = new EVER_WrapperDef.EVER_Response();
        response.success = true;
        if(AllSubModuleSettings.isEmpty()){
           response.messageList.add(System.label.CONF023_TAG001); 
           response.success = false;
           return response;
        }else{
            for(String settingValue : settingsValueMap.keySet()){
                if(settingValue != 'SET029' && AllSubModuleSettings.containsKey(settingValue) && AllSubModuleSettings.get(settingValue) == null){
                   response.messageList.add(System.label.CONF023_TAG001); 
                   response.success = false;
                   break; 
                }
                settingsValueMap.put(settingValue,AllSubModuleSettings.get(settingValue));
            } 
            
            if(response.success){
               defaultSettingValues.showFutureEntitlement = settingsValueMap.get('SET001');
               defaultSettingValues.showExpiredEntitlement = settingsValueMap.get('SET002');
               defaultSettingValues.entitleUsingAccountOrProduct = settingsValueMap.get('SET003'); 
               defaultSettingValues.matchAccount = settingsValueMap.get('SET004');  
               defaultSettingValues.matchContact = settingsValueMap.get('SET005'); 
               defaultSettingValues.sLAandValidityLevels = settingsValueMap.get('SET006'); 
               defaultSettingValues.coverageOnParentProduct = settingsValueMap.get('SET007');
               defaultSettingValues.coverageOnTopLevelProduct = settingsValueMap.get('SET008');
               defaultSettingValues.coverageOnChildProduct = settingsValueMap.get('SET009');
               defaultSettingValues.coverageOnPartProduct = settingsValueMap.get('SET010');
               defaultSettingValues.coverageOnProductFamily = settingsValueMap.get('SET011');
               defaultSettingValues.coverageOnProductLine = settingsValueMap.get('SET012');  
               defaultSettingValues.noOfChildLevelItr = settingsValueMap.get('SET013');
               defaultSettingValues.allowEntitlementFilters = settingsValueMap.get('SET016');
               defaultSettingValues.setBillingType = settingsValueMap.get('SET017');
               defaultSettingValues.recordViewPage = settingsValueMap.get('SET019');
               defaultSettingValues.matchLocation = settingsValueMap.get('SET020'); 
               defaultSettingValues.effectiveDateForEntitlement = settingsValueMap.get('SET021'); 
               defaultSettingValues.serviceBasedEntitlement = settingsValueMap.get('SET022'); 
               defaultSettingValues.showAllServices = settingsValueMap.get('SET023'); 
               defaultSettingValues.entitlementSupportOnLines =  settingsValueMap.get('SET024'); 
               defaultSettingValues.showAllLines = settingsValueMap.get('SET026');
               defaultSettingValues.entUsingWarrantyOrSC = settingsValueMap.get('SET027');
               defaultSettingValues.considerCountersOrDates = settingsValueMap.get('SET028');
            }
        }
        response.EntitlementSettings = defaultSettingValues;
        return response;
    }    
    
    public EVER_WrapperDef.EVER_Response getWorkOrderDetails (EVER_WrapperDef.EVER_Request request) {
        Set<Id> entityIds = new Set<Id>(); //Set to hold IDs for which entitlement history records to be queried
        EVER_WrapperDef.EVER_Response response = new EVER_WrapperDef.EVER_Response();
        response.success = true;
        if(request == null || Request.entitlementSettings == null || request.headerId == null){
            response.success = false;
            response.messageList.add(System.Label.EVER001_TAG087); //Invalid Request
            return response;
        }
        entitlementSupportOnLines = (Request.entitlementSettings.entitlementSupportOnLines != null) ? boolean.valueof(Request.entitlementSettings.entitlementSupportOnLines): false;
        serviceBasedEntitlement = boolean.valueof(Request.entitlementSettings.serviceBasedEntitlement);
        showAllServices = boolean.valueof(Request.entitlementSettings.showAllServices);

        //entitlementSupportOnLines = boolean.valueof(Request.entitlementSettings.entitlementSupportOnLines);
        EVER_WrapperDef.EVER_HeaderRecord headerRecord;
        String workOrderId = request.headerId;
        String queryString;
        try{
            String effectiveDateString = Request.entitlementSettings.effectiveDateForEntitlement;
            queryString = getHeaderQueryString(effectiveDateString);
            queryString = queryString + ' FROM SVMXC__Service_Order__c WHERE Id = \'' + workOrderId + '\'';
            system.debug(logginglevel.info, 'queryString :' + queryString );
            SVMXC__Service_Order__c workOrderRecord = Database.query(queryString);  
            
            List<SVMXC__Service_Order_Line__c> productServicedList = new List<SVMXC__Service_Order_Line__c>();

            if(entitlementSupportOnLines){
                queryString = getDetailQueryString();
                queryString = queryString + ' FROM SVMXC__Service_Order_Line__c WHERE SVMXC__Service_Order__c = \'' + workOrderId + '\' AND RecordType.DeveloperName = \'Products_Serviced\'';

                productServicedList = Database.query(queryString);      
                
                for(SVMXC__Service_Order_Line__c workOrderLine : productServicedList){
                    entityIds.add(workOrderLine.Id);
                }   
            }


            entitlementHistoryMap = new Map<Id,SVMXC__Entitlement_History__c>();
            for(SVMXC__Entitlement_History__c histRecord : [SELECT SVMXC__Start_Date__c,SVMXC__End_Date__c,SVMXC__Work_Detail__c,SVMXC__Covered_By__c,SVMXC__Entitled_By_Service__c,
                                                              SVMXC__Service_Order__c FROM SVMXC__Entitlement_History__c WHERE (SVMXC__Service_Order__c =: workOrderId OR
                                                              SVMXC__Work_Detail__c IN : entityIds) AND SVMXC__Inactive_Date__c = null]){
                if(histRecord.SVMXC__Service_Order__c == workOrderId){
                    entitlementHistoryMap.put(histRecord.SVMXC__Service_Order__c,histRecord);    
                }else{
                    entitlementHistoryMap.put(histRecord.SVMXC__Work_Detail__c,histRecord);
                }    
            }

            headerRecord =  setheaderRecord(workOrderRecord);
            if(!productServicedList.isEmpty()){
                List<EVER_WrapperDef.EVER_DetailRecord> workDetailList = new List<EVER_WrapperDef.EVER_DetailRecord>();

                for(SVMXC__Service_Order_Line__c workOrderLine : productServicedList){
                    EVER_WrapperDef.EVER_DetailRecord workDetail = setDetailLineRecord(workOrderLine);
                    workDetailList.add(workDetail);
                }   

                headerRecord.listDetailRecords = workDetailList;
                    
            }
            response.headerRecord = headerRecord;
            response.EntitlementSettings = Request.entitlementSettings;            
        }catch(Exception ex){
            response.success = false;
            response.messageList.add( ex.getMessage() );
        }
        return response; 
    }

    public EVER_WrapperDef.EVER_Response checkEntitlement(EVER_WrapperDef.EVER_Request request){
       // SVMXC.COMM_Utils utils = new SVMXC.COMM_Utils();  
        EVER_WrapperDef.EVER_Response response = new EVER_WrapperDef.EVER_Response();
        response.success = true;
        system.debug(request + '---- ' +  Request.entitlementSettings +'------'+ request.headerId);
        if(request == null || Request.entitlementSettings == null || request.headerId == null){
            response.success = false;
            response.messageList.add(System.Label.EVER001_TAG087); //Invalid Request
            return response;
        }
        
        EVER_WrapperDef.EVER_Settings entitlementSettings = Request.entitlementSettings;
        
        entitlementSupportOnLines = (entitlementSettings.entitlementSupportOnLines != null && entitlementSettings.entitlementSupportOnLines.equalsIgnoreCase('True'))? true: false;
        matchContact = boolean.valueof(entitlementSettings.matchContact);
        matchLocation = boolean.valueof(entitlementSettings.matchLocation);
        matchAccount = boolean.valueof(entitlementSettings.matchAccount);
        showExpiredEntitlement = boolean.valueof(entitlementSettings.showExpiredEntitlement);
        showFutureEntitlement = boolean.valueof(entitlementSettings.showFutureEntitlement);        
        serviceBasedEntitlement = boolean.valueof(entitlementSettings.serviceBasedEntitlement);
        showAllServices = boolean.valueof(entitlementSettings.showAllServices);
        entUsingWarrantyOrSC = entitlementSettings.entUsingWarrantyOrSC;
        considerCountersOrDates = entitlementSettings.considerCountersOrDates;
        
        if(entitlementSupportOnLines && (request.detailLineIDs == null || request.detailLineIDs.isEmpty())){
            response.success = false;
            response.messageList.add(System.Label.EVER005_TAG105);
            return response;
        }

        String workOrderId = request.headerId;
        EVER_WrapperDef.EVER_HeaderRecord headerRecord;    
        String queryString;  
        try{
            List<String> productServicedLineIds =  request.detailLineIDs;
            if(productServicedLineIds == null){
               productServicedLineIds = new List<String>();
            }
            queryString =  getHeaderQueryString(entitlementSettings.effectiveDateForEntitlement);
            queryString = queryString + ' FROM SVMXC__Service_Order__c WHERE Id = \'' + workOrderId + '\'';
            system.debug(logginglevel.info, 'queryString :' + queryString );
            SVMXC__Service_Order__c workOrderRecord = Database.Query(queryString);

            List<SVMXC__Service_Order_Line__c> productServicedList = new List<SVMXC__Service_Order_Line__c>();

            if(entitlementSupportOnLines){
                queryString = getDetailQueryString();
                queryString = queryString + ' FROM SVMXC__Service_Order_Line__c WHERE SVMXC__Service_Order__c = \'' + workOrderId + '\' AND RecordType.DeveloperName = \'Products_Serviced\'';
                if(!productServicedLineIds.isEmpty())
                    queryString += ' AND ID IN : productServicedLineIds ';
                productServicedList = Database.query(queryString);      
 
            }

            entitlementHistoryMap = new Map<Id,SVMXC__Entitlement_History__c>();
            for(SVMXC__Entitlement_History__c histRecord : [SELECT SVMXC__Start_Date__c,SVMXC__End_Date__c,SVMXC__Work_Detail__c,SVMXC__Covered_By__c,SVMXC__Entitled_By_Service__c,
                                                              SVMXC__Service_Order__c FROM SVMXC__Entitlement_History__c WHERE (SVMXC__Service_Order__c =: workOrderId OR
                                                              SVMXC__Work_Detail__c IN : productServicedLineIds) AND SVMXC__Inactive_Date__c = null]){
                if(histRecord.SVMXC__Service_Order__c == workOrderId){
                    entitlementHistoryMap.put(histRecord.SVMXC__Service_Order__c,histRecord);    
                }else{
                    entitlementHistoryMap.put(histRecord.SVMXC__Work_Detail__c,histRecord);
                }    
            }

            //headerRecord = new EVER_WrapperDef.EVER_HeaderRecord(workOrderRecord); 
            headerRecord = setheaderRecord(workOrderRecord);


            if(!productServicedList.isEmpty()){
                List<EVER_WrapperDef.EVER_DetailRecord> lstdetailRecords = new List<EVER_WrapperDef.EVER_DetailRecord>();   
                for(SVMXC__Service_Order_Line__c workOrderLine : productServicedList){
                    EVER_WrapperDef.EVER_DetailRecord workDetail = setDetailLineRecord(workOrderLine);
                    lstdetailRecords.add(workDetail);
                }       
                headerRecord.listDetailRecords = lstdetailRecords;
            }
             
            if(effectiveDateForEntitlement == null){
                Object effectiveDate = workOrderRecord.get(entitlementSettings.effectiveDateForEntitlement);
                if(effectiveDate == null){
                    response.success = false;
                    response.messageList.add(System.Label.COMM001_TAG080 + ' ' + entitlementSettings.effectiveDateForEntitlement);
                    return response;
                }
                effectiveDateForEntitlement = date.valueof(effectiveDate);
            }

            Set<Id> serviceContractIds = new Set<Id>(); //All the Service Contract Ids
            List<EVER_WrapperDef.EVER_EntitlementInfo> tempEntitlementList = new List<EVER_WrapperDef.EVER_EntitlementInfo>();
            //Entitle using Account
            if(entitlementSettings.entitleUsingAccountOrProduct == 'Account'){
                if(workOrderRecord.SVMXC__Company__c == null ){
                    response.success = false;
                    response.messageList.add(System.Label.EVER005_TAG053);
                    return response;
                }

                List<SVMXC__Service_Contract__c> serviceContractRecords = new List<SVMXC__Service_Contract__c>();
                String SOQLHeader='';
                String where_clause ='';   
                String sConFields;    

                /*Populating FieldNames for Service Contract                      
                Schema.DescribeSObjectResult sObjectResult = SVMXC__Service_Contract__c.sObjectType.getDescribe();
                Map<String, SObjectField> sObjectFieldMap = Schema.SObjectType.SVMXC__Service_Contract__c.fields.getMap();
                List<String> sConFieldList = utils.SVMX_getFieldList(sObjectFieldMap,true);             
                sConFields = utils.SVMX_getFieldNamesFromList(sConFieldList);    */
                sConFields = 'Id, Name ,SVMXC__Start_Date__c, SVMXC__End_Date__c, SVMXC__Service_Level__c, SVMXC__Service_Level__r.Name'; 
                //sConFields +=' ,SVMXC__Service_Level__r.Name ';
                SOQLHeader    = '   SELECT '+ sConFields +' FROM SVMXC__Service_Contract__c  '; 
                where_clause += '   WHERE  SVMXC__Active__c =  true ';
                where_clause += '   AND  SVMXC__Company__c = \'' + workOrderRecord.SVMXC__Company__c  + '\' ';
                
                // Entitlement enhancement: Get the setting value for date fields instead of TODAY.
                if(!showExpiredEntitlement)
                    where_clause += ' AND SVMXC__End_Date__c >=: effectiveDateForEntitlement'; 
                if(!showFutureEntitlement)
                    where_clause +=  ' AND SVMXC__Start_Date__c <=: effectiveDateForEntitlement ';

                Set<String> SCIds = new Set<String>();
                if(matchContact)
                {   
                    //Need to Check : if(workOrderRecord.SVMXC__Contact__c != null){
                        List<SVMXC__Service_Contract_Contacts__c> coveredContacts = new List<SVMXC__Service_Contract_Contacts__c>();
                        CoveredContacts = [Select s.SystemModstamp, s.SVMXC__Service_Contract__c, s.SVMXC__Number_of_Service_Orders__c, s.SVMXC__Notes__c, s.SVMXC__Contact__c, s.Name, s.Id, s.CreatedDate, s.CreatedById From SVMXC__Service_Contract_Contacts__c s where SVMXC__Contact__c  =: workOrderRecord.SVMXC__Contact__c];
                        if(CoveredContacts.size() > 0)
                        {
                            for(SVMXC__Service_Contract_Contacts__c SCC : CoveredContacts)
                            {
                                if(SCC.SVMXC__Service_Contract__c != null)
                                    SCIds.add(SCC.SVMXC__Service_Contract__c);
                            }
                        }
                    //}    
                }
                
                // Entitlement enhancement: Query Covered Location to support Match Location.
                Set<String> setSCONLocId = new Set<String>();
                if(matchLocation)
                {
                    //Need to Check : if(workOrderRecord.SVMXC__Site__c == null){
                        List<SVMXC__Service_Contract_Sites__c> lstCoveredLocs = new List<SVMXC__Service_Contract_Sites__c>();
                        lstCoveredLocs = [Select SVMXC__Site__c, SVMXC__SLA_Terms__c, SVMXC__Service_Contract__c, Name, Id 
                                            From SVMXC__Service_Contract_Sites__c 
                                            where SVMXC__Site__c  =: workOrderRecord.SVMXC__Site__c];
                        if(lstCoveredLocs.size() > 0)
                        {
                            for(SVMXC__Service_Contract_Sites__c currLocation : lstCoveredLocs)
                            {
                                if(currLocation.SVMXC__Service_Contract__c != null)
                                    setSCONLocId.add(currLocation.SVMXC__Service_Contract__c);
                            }
                        }
                    //}    
                }
                
                SOQLHeader += where_clause + ' order by Name';
                if(entUsingWarrantyOrSC.toUpperCase() != 'WARRANTY'){
                    ServiceContractRecords = Database.query(SOQLHeader);    
                    List<EVER_WrapperDef.EVER_EntitlementInfo> listEntitlementInfo = new List<EVER_WrapperDef.EVER_EntitlementInfo>();
                    for (SVMXC__Service_Contract__c screc : ServiceContractRecords)
                    {
                        EVER_WrapperDef.EVER_EntitlementInfo entitlementInfo;
                        if(matchLocation || matchContact){  
                            if(matchLocation && setSCONLocId.size() > 0 && setSCONLocId.contains(screc.id)){
                                entitlementInfo = setEntitlementInfoScon(screc,entitlementInfo);
                                entitlementInfo.coveredBy = System.Label.COMM001_TAG099;
                            }

                            if(matchContact && SCIds.size() > 0 && SCIds.contains(screc.id)){
                                entitlementInfo = setEntitlementInfoScon(screc,entitlementInfo);
                                if(entitlementInfo.coveredBy == null)
                                    entitlementInfo.coveredBy = System.Label.EVER005_TAG009;
                                else
                                    entitlementInfo.coveredBy += ', ' + System.Label.EVER005_TAG009;    
                            }

                        }else{
                            entitlementInfo = setEntitlementInfoScon(screc,entitlementInfo);
                            entitlementInfo.coveredBy = System.Label.EVER005_TAG010;                       
                        }
                        if(entitlementInfo != null){
                           serviceContractIds.add(screc.Id); 
                           entitlementInfo.uniqueId = entitlementInfo.recordID + ((entitlementInfo.coveredBy != null) ? entitlementInfo.coveredBy : '');
                           listEntitlementInfo.add(entitlementInfo);
                        }
                    } 
                    if(!listEntitlementInfo.isEmpty()){
                        if(!entitlementSupportOnLines){
                            if(headerRecord.listEntitlementInfo == null){
                                headerRecord.listEntitlementInfo = new List<EVER_WrapperDef.EVER_EntitlementInfo>();
                            }
                            headerRecord.listEntitlementInfo = listEntitlementInfo;
                        }
                        else{
                            for(EVER_WrapperDef.EVER_DetailRecord detailRec : headerRecord.listDetailRecords){
                                if(detailRec.listEntitlementInfo == null){
                                    detailRec.listEntitlementInfo = new List<EVER_WrapperDef.EVER_EntitlementInfo>();
                                }
                                detailRec.listEntitlementInfo = listEntitlementInfo;
                            }
                        }
                        //headerRecord = setHeadervalues(headerRecord,listEntitlementInfo,entitlementSupportOnLines);
                    }
                }
                       
                response.headerRecord = headerRecord;
                    
            }

            //Entitlement based on Product
            if(entitlementSettings.entitleUsingAccountOrProduct == 'Product'){
                if(matchAccount && workOrderRecord.SVMXC__Company__c == null){
                    response.success = false;
                    response.messageList.add(System.Label.EVER005_TAG053);
                    return response;                    
                }

                if(matchContact && workOrderRecord.SVMXC__Contact__c == null){
                    response.success = false;
                    response.messageList.add(System.Label.EVER005_TAG054);
                    return response;                    
                }

                //Get all the qualified Installed based Ids
                Set<Id> installedBaseIds = new Set<Id>();   
                
                //Try if usage of the collections(Sets) can be avoided
                Set<Id> productIds = new Set<Id>(); 
                Set<String> productFamilySet = new Set<String>();
                Set<String> productLineSet = new Set<String>();
                
                /*Map<Id,Set<String>> iBProductMap = new Map<Id,Product>();
                Map<Id,Set<String>> iBProductFamilyMap = new Map<Id,Set<String>>();
                Map<Id,Set<String>> iBProductLineMap = new Map<Id,Set<String>>();*/

                if(!entitlementSupportOnLines){
                    if(workOrderRecord.SVMXC__Component__c != null){
                        Id componentId = workOrderRecord.SVMXC__Component__c;
                        installedBaseIds.add(componentId);
                        //checkFilterForWarranties(componentId);
                    }else{
                        response.success = false;
                        response.messageList.add(System.Label.EVER005_TAG055);
                        return response; 
                    }
                }else{          
                    for(SVMXC__Service_Order_Line__c workOrderLine : productServicedList){
                        if(workOrderLine.SVMXC__Serial_Number__c != null)
                            installedBaseIds.add(workOrderLine.SVMXC__Serial_Number__c);
                    }
                }   

                List<SVMXC__Warranty__c> warrantiesList = new List<SVMXC__Warranty__c>();
                Map<Id,SVMXC__Installed_Product__c> mapOfIBs = new Map<Id,SVMXC__Installed_Product__c>();
                Map<Id,List<SVMXC__Installed_Product__c>> childIBMap = new Map<Id,List<SVMXC__Installed_Product__c>>();

                //Boolean conversion of Settings for Parent, Top and Child

                coverageOnParentProduct = boolean.valueof(entitlementSettings.coverageOnParentProduct );
                coverageOnTopLevelProduct = boolean.valueof(entitlementSettings.coverageOnTopLevelProduct);
                coverageOnChildProduct = boolean.valueof(entitlementSettings.coverageOnChildProduct);
                sLAandValidityLevels =  entitlementSettings.sLAandValidityLevels;
                
                coverageOnPartProduct = boolean.valueof(entitlementSettings.coverageOnPartProduct);
                coverageOnProductFamily = boolean.valueof(entitlementSettings.coverageOnProductFamily);
                coverageOnProductLine = boolean.valueof(entitlementSettings.coverageOnProductLine);

                //Query for all IBs to get Parent and Top level IB Ids
                if(!installedBaseIds.isEmpty()){
                    mapOfIBs = getListOfQualifiedIBs(installedBaseIds);

                    for(SVMXC__Installed_Product__c installedProd : mapOfIBs.values()){

                        if(installedProd.SVMXC__Product__c != null){
                            if(coverageOnPartProduct)
                                productIds.add(installedProd.SVMXC__Product__c);
                            if(coverageOnProductFamily && installedProd.SVMXC__Product__r.Family != null) 
                                productFamilySet.add(installedProd.SVMXC__Product__r.Family);
                            if(coverageOnProductLine && installedProd.SVMXC__Product__r.SVMXC__Product_Line__c != null) 
                                productLineSet.add(installedProd.SVMXC__Product__r.SVMXC__Product_Line__c);
                        }   

                        if(coverageOnParentProduct && installedProd.SVMXC__Parent__c != null){
                            installedBaseIds.add(installedProd.SVMXC__Parent__c);
                            //To Do : check if parent product should also be included, if include part product is enabled
                            if(installedProd.SVMXC__Parent__r.SVMXC__Product__c != null){
                                if(coverageOnPartProduct)
                                    productIds.add(installedProd.SVMXC__Parent__r.SVMXC__Product__c);

                                if(coverageOnProductFamily && installedProd.SVMXC__Parent__r.SVMXC__Product__r.Family != null)  
                                    productFamilySet.add(installedProd.SVMXC__Parent__r.SVMXC__Product__r.Family);
                                
                                if(coverageOnProductLine && installedProd.SVMXC__Parent__r.SVMXC__Product__r.SVMXC__Product_Line__c != null)  
                                    productLineSet.add(installedProd.SVMXC__Parent__r.SVMXC__Product__r.SVMXC__Product_Line__c);                                  
                            }
                        }

                        if(coverageOnTopLevelProduct && installedProd.SVMXC__Top_Level__c != null){    
                            installedBaseIds.add(installedProd.SVMXC__Top_Level__c); 
                            //To Do : check if Top Level product should also be included, if include part product is enabled
                            if(installedProd.SVMXC__Top_Level__r.SVMXC__Product__c != null){
                                if(coverageOnPartProduct)
                                    productIds.add(installedProd.SVMXC__Top_Level__r.SVMXC__Product__c);

                                if(coverageOnProductFamily) 
                                    productFamilySet.add(installedProd.SVMXC__Top_Level__r.SVMXC__Product__r.Family);  

                                if(coverageOnProductLine && installedProd.SVMXC__Top_Level__r.SVMXC__Product__r.SVMXC__Product_Line__c != null)   
                                    productLineSet.add(installedProd.SVMXC__Top_Level__r.SVMXC__Product__r.SVMXC__Product_Line__c);                                                                   
                            }   
                        }    

                                
                    }                                                                       

                    //Check for child product and get all the child level product IBs based on no. of level down
                    if(coverageOnChildProduct){
                        /*Map<Id,Set<Id>> tempParentIBMap = new Map<Id,Set<Id>>();
                        tempParentIBMap = getChildIBs(mapOfIBs.keySet(),Integer.valueof(entitlementSettings.noOfChildLevelItr), tempParentIBMap);*/
                        
                        Map<Id,List<SVMXC__Installed_Product__c>> tempParentIBMap = new Map<Id,List<SVMXC__Installed_Product__c>>();
                        tempParentIBMap = getChildIBs(mapOfIBs.keySet(),Integer.valueof(entitlementSettings.noOfChildLevelItr), tempParentIBMap);


                        for(Id installedBaseId : mapOfIBs.keySet()){
                            if(tempParentIBMap.containsKey(installedBaseId)){
                                List<SVMXC__Installed_Product__c> childIBRecords = getIds(installedBaseId,tempParentIBMap,Integer.valueof(entitlementSettings.noOfChildLevelItr));
                                System.debug(logginglevel.info, 'Base IB : ' + installedBaseId + ' childRecords : ' + childIBRecords);
                                //List<SVMXC__Installed_Product__c> childIBs = new List<SVMXC__Installed_Product__c>();
                                for(SVMXC__Installed_Product__c iBRec: childIBRecords){
                                    //childIBs.add(iBRec);
                                    installedBaseIds.add(iBRec.Id);
                                    if(iBRec.SVMXC__Product__c != null){
                                    
                                        if(coverageOnPartProduct){
                                            productIds.add(iBRec.SVMXC__Product__c);
                                        }

                                        if(coverageOnProductFamily && iBRec.SVMXC__Product__r.Family != null){
                                            productFamilySet.add(iBRec.SVMXC__Product__r.Family);
                                        }

                                        if(coverageOnProductLine && iBRec.SVMXC__Product__r.SVMXC__Product_Line__c != null){    
                                            productLineSet.add(iBRec.SVMXC__Product__r.SVMXC__Product_Line__c);
                                        }    

                                    }    

                                }
                                childIBMap.put(installedBaseId, childIBRecords);
                                //installedBaseIds.addAll(childIds);
                            }
                        }
                        
                    }   

                    //BAC-4 consistent settings for Auto and Interactice Entitlements - Anush 4th July 2016
                    //Query for Warranty only if the options selected are either 'Warranty' or 'Both'
                    if(entUsingWarrantyOrSC.equalsIgnoreCase('WARRANTY') || entUsingWarrantyOrSC.equalsIgnoreCase('BOTH')) {
                        //Query String to get all the warranties for the qualified IBs
                        queryString = 'SELECT Id, Name,SVMXC__Select__c, SVMXC__Service_Template__c, ' +
                                  'SVMXC__Service_Template__r.Name,SVMXC__Start_Date__c, SVMXC__End_Date__c, ' +
                                  'SVMXC__Exclusions__c, SVMXC__Invoice_Required__c, SVMXC__Loaner_Provided__c, ' +
                                  'SVMXC__Onsite_Repair__c, SVMXC__RMA_Required__c, SVMXC__Shipment_Allowed__c, ' +
                                  'SVMXC__Transferable__c, SVMXC__Walk_in_Allowed__c ,SVMXC__Installed_Product__c,SVMXC__Installed_Product__r.Name,SVMXC__Installed_Product__r.SVMXC__Product__c FROM SVMXC__Warranty__c ' +
                                  'where SVMXC__Installed_Product__c IN : installedBaseIds ';
                        if(considerCountersOrDates.toUpperCase() == 'DATES' || considerCountersOrDates.toUpperCase() == 'BOTH'){
                            if(!showExpiredEntitlement)              
                                queryString +=   ' AND SVMXC__End_Date__c >=: effectiveDateForEntitlement ';
                            if(!showFutureEntitlement)   
                            queryString +=  ' AND  SVMXC__Start_Date__c <=: effectiveDateForEntitlement ';
                        }
                        System.debug(LoggingLevel.INFO, 'Warranty Query String :  ' + queryString);
                        warrantiesList = Database.query(queryString);
                        //Validating counters for the qualified warranties if selected option is either 'Counters' or 'Both'.
                        if(considerCountersOrDates.toUpperCase() == 'COUNTERS' || considerCountersOrDates.toUpperCase() == 'BOTH'){
                            Set<string> ibProductIDs = new Set<String>();
                            for(SVMXC__Warranty__c warranty : warrantiesList){
                                ibProductIDs.add(warranty.SVMXC__Installed_Product__r.SVMXC__Product__c);
                            }
                            Map<id,SVMXC__Service_Template__c> WarrantyTermsMap = new Map<id,SVMXC__Service_Template__c>([SELECT Id,(SELECT id,SVMXC__Coverage_Limit__c,SVMXC__Coverage_Starts_At__c,SVMXC__Counter_Definition__c,SVMXC__Product__c FROM SVMXC__Counter_Details__r WHERE SVMXC__Is_Counter_Active__c = true AND SVMXC__Product__c IN:ibProductIDs) FROM SVMXC__service_template__c]);

                            Map<id,SVMXC__Installed_Product__c> IBIDReadingMap = new Map<id,SVMXC__Installed_Product__c>([SELECT Id,(SELECT SVMXC__Counter_Reading__c,SVMXC__Counter_Definition__c,SVMXC__Counter_Definition__r.SVMXC__Counter_Type__c FROM SVMXC__Counter_Details__r WHERE SVMXC__Is_Latest__c = true) FROM SVMXC__Installed_Product__c WHERE id IN: installedBaseIds]);
                            //List<SVMXC__Warranty__c> tempWarrantyList = new List<SVMXC__Warranty__c>();
                            Map<ID,SVMXC__Warranty__c> warrantyTermWProductWarrantyMap = new Map<ID,SVMXC__Warranty__c>();
                            // Below loop checks if an IB reading is within the range of the Warranty Term readings.
                            // IB and Warranty Terms are linked via Product Warranty
                            for(SVMXC__Warranty__c warranty : warrantiesList){
                                String warrantyTermId = warranty.SVMXC__Service_Template__c;
                                String IBID = warranty.SVMXC__Installed_Product__c;
                                for(SVMXC__Counter_Details__c reading : IBIDReadingMap.get(IBID).SVMXC__Counter_Details__r){
                                    Decimal counterReading = reading.SVMXC__Counter_Reading__c;
                                    for(SVMXC__Counter_Details__c coverage : WarrantyTermsMap.get(warrantyTermId).SVMXC__Counter_Details__r){
                                        if(warranty.SVMXC__Installed_Product__r.SVMXC__Product__c == coverage.SVMXC__Product__c){
                                            if(reading.SVMXC__Counter_Definition__c == coverage.SVMXC__Counter_Definition__c){
                                                if(reading.SVMXC__Counter_Definition__r.SVMXC__Counter_Type__c == 'Increasing'){
                                                    if(coverage.SVMXC__Coverage_Starts_At__c <= counterReading && coverage.SVMXC__Coverage_Limit__c > counterReading){
                                                        //tempWarrantyList.add(warranty);
                                                        if(!warrantyTermWProductWarrantyMap.containsKey(IBID)){
                                                            warrantyTermWProductWarrantyMap.put(IBID,warranty);
                                                        }
                                                    }
                                                } else if(reading.SVMXC__Counter_Definition__r.SVMXC__Counter_Type__c == 'Decreasing') {
                                                    if(coverage.SVMXC__Coverage_Starts_At__c >= counterReading && coverage.SVMXC__Coverage_Limit__c < counterReading){
                                                        //tempWarrantyList.add(warranty);
                                                        if(!warrantyTermWProductWarrantyMap.containsKey(IBID)){
                                                            warrantyTermWProductWarrantyMap.put(IBID,warranty);
                                                        }
                                                    }
                                                }
                                                
                                            }

                                        }
                                    }
                                }
                            }
                            warrantiesList = warrantyTermWProductWarrantyMap.values();                            

                        }

                    }

                         
                } 

                //BAC-4 consistent settings for Auto ans Interactice Entitlements - Anush 4th July 2016
                
                //Create a warrant list map for the IBs only if the option selected is either 'Warranty' or 'Both'
                if(entUsingWarrantyOrSC.equalsIgnoreCase('WARRANTY') || entUsingWarrantyOrSC.equalsIgnoreCase('BOTH')) {
                     
                    Map<Id,List<EVER_WrapperDef.EVER_EntitlementInfo>> iBWarrantyMap = new Map<Id,List<EVER_WrapperDef.EVER_EntitlementInfo>>();
                    for(SVMXC__Warranty__c warrantyRecord : warrantiesList) {
                        List<EVER_WrapperDef.EVER_EntitlementInfo> tempEntitlementInfoList = new List<EVER_WrapperDef.EVER_EntitlementInfo>();
                        if(iBWarrantyMap.containsKey(warrantyRecord.SVMXC__Installed_Product__c))
                            tempEntitlementInfoList = iBWarrantyMap.get(warrantyRecord.SVMXC__Installed_Product__c);
                        tempEntitlementInfoList.add(setEntitlementInfoWarranty(warrantyRecord));    
                        iBWarrantyMap.put(warrantyRecord.SVMXC__Installed_Product__c,tempEntitlementInfoList);                        
                    }   

                    //Add the warranties info to the Header Record
                    
                    Id wOId;
                    if(!entitlementSupportOnLines){
                        if(workOrderRecord.SVMXC__Component__c != null){
                            if(iBWarrantyMap.containsKey(workOrderRecord.SVMXC__Component__c))
                                tempEntitlementList = iBWarrantyMap.get(workOrderRecord.SVMXC__Component__c);
                            
                            if(mapOfIBs.containsKey(workOrderRecord.SVMXC__Component__c)){
                                if(coverageOnParentProduct){
                                    wOId = mapOfIBs.get(workOrderRecord.SVMXC__Component__c).SVMXC__Parent__c;
                                    if(wOId != null && iBWarrantyMap.containsKey(wOId))
                                        tempEntitlementList.addAll(iBWarrantyMap.get(wOId));
                                }

                                if(coverageOnTopLevelProduct){
                                    wOId = mapOfIBs.get(workOrderRecord.SVMXC__Component__c).SVMXC__Top_Level__c;
                                    if(wOId != null && iBWarrantyMap.containsKey(wOId))
                                        tempEntitlementList.addAll(iBWarrantyMap.get(wOId));                        
                                }
                            }

                            if(coverageOnChildProduct){
                                if(childIBMap.containsKey(workOrderRecord.SVMXC__Component__c)){
                                    for(SVMXC__Installed_Product__c childIB : childIBMap.get(workOrderRecord.SVMXC__Component__c)) {
                                        if(iBWarrantyMap.containsKey(childIB.Id) && !iBWarrantyMap.get(childIB.Id).isEmpty())
                                            tempEntitlementList.addAll(iBWarrantyMap.get(childIB.Id));
                                    }
                                }
                            }
                        }   


                        if(tempEntitlementList != null && !tempEntitlementList.isEmpty()){
                           
                            if(headerRecord.listEntitlementInfo == null){
                                headerRecord.listEntitlementInfo = new List<EVER_WrapperDef.EVER_EntitlementInfo>();
                            }                            
                           
                            headerRecord.listEntitlementInfo.addAll(removeDuplicates(tempEntitlementList));
                        }

                    }else{
                        for(EVER_WrapperDef.EVER_DetailRecord detailRec : headerRecord.listDetailRecords){
                            tempEntitlementList = new List<EVER_WrapperDef.EVER_EntitlementInfo>();
                            if(detailRec.listEntitlementInfo != null && detailRec.listEntitlementInfo.size() > 0)
                                tempEntitlementList = detailRec.listEntitlementInfo;

                            if(detailRec.installedBaseId != null){
                                if(iBWarrantyMap.containsKey(detailRec.installedBaseId))
                                    tempEntitlementList.addAll(iBWarrantyMap.get(detailRec.installedBaseId));

                                if(mapOfIBs.containsKey(detailRec.installedBaseId)){
                                    if(coverageOnParentProduct){
                                        wOId = mapOfIBs.get(detailRec.installedBaseId).SVMXC__Parent__c;
                                        if(wOId != null && iBWarrantyMap.containsKey(wOId))
                                            tempEntitlementList.addAll(iBWarrantyMap.get(wOId));
                                    }

                                    if(coverageOnTopLevelProduct){
                                        wOId = mapOfIBs.get(detailRec.installedBaseId).SVMXC__Top_Level__c;
                                        if(wOId != null && iBWarrantyMap.containsKey(wOId))
                                            tempEntitlementList.addAll(iBWarrantyMap.get(wOId));                        
                                    }
                                }

                                if(coverageOnChildProduct){
                                    if(childIBMap.containsKey(detailRec.installedBaseId)){
                                        for(SVMXC__Installed_Product__c childIB : childIBMap.get(detailRec.installedBaseId)) {
                                            if(iBWarrantyMap.containsKey(childIB.Id) && !iBWarrantyMap.get(childIB.Id).isEmpty())
                                                tempEntitlementList.addAll(iBWarrantyMap.get(childIB.Id));
                                        }
                                    }
                                }                               
                            }    


                            if(tempEntitlementList != null && !tempEntitlementList.isEmpty()){     

                                if(detailRec.listEntitlementInfo == null){
                                    detailRec.listEntitlementInfo = new List<EVER_WrapperDef.EVER_EntitlementInfo>();
                                }  
                            
                                detailRec.listEntitlementInfo.addAll(removeDuplicates(tempEntitlementList)); 
                            }
                        }
                    }       
                }

                //BAC - 4 consistents setteings for Auto and Interactive entitlements - Anush 4th July 2016   
                //Get all the SCons for the qualified IBs (installedBaseIds) if the option selected is either 'Service Contract' or 'Both'
                if(entUsingWarrantyOrSC.equalsIgnoreCase('SERVICE CONTRACT') || entUsingWarrantyOrSC.equalsIgnoreCase('BOTH')) {
                    

                    queryString =  'SELECT Name, SVMXC__Service_Contract__c,SVMXC__SLA_Terms__c,SVMXC__SLA_Terms__r.Name, ' +
                                'SVMXC__Service_Contract__r.Name,  SVMXC__Service_Contract__r.SVMXC__Start_Date__c, ' +
                                'SVMXC__Service_Contract__r.SVMXC__End_Date__c, SVMXC__Service_Contract__r.SVMXC__Renewal_Date__c, ' +
                                'SVMXC__Service_Contract__r.SVMXC__Renewal_Number__c,' +
                                'SVMXC__Service_Contract__r.SVMXC__Service_Contract_Notes__c, ' +
                                'SVMXC__Service_Contract__r.SVMXC__Service_Level__c ,SVMXC__Service_Contract__r.SVMXC__Service_Level__r.Name, ' +
                                'SVMXC__Start_Date__c, SVMXC__End_Date__c , SVMXC__Product__c, '+
                                'SVMXC__Product_Line__c, SVMXC__Product_Family__c, SVMXC__Notes__c, SVMXC__Installed_Product__c, SVMXC__Installed_Product__r.SVMXC__Product__c '+
                                'FROM SVMXC__Service_Contract_Products__c ';
                    String select_clause = ' where (  SVMXC__Installed_Product__c IN : installedBaseIds ';


                    if(coverageOnPartProduct && !productIds.isEmpty()){
                        select_clause += '  OR SVMXC__Product__c IN : productIds ';
                    }           

                    if(coverageOnProductFamily && !productFamilySet.isEmpty()){
                        select_clause += ' OR SVMXC__Product_Family__c IN: productFamilySet ';
                    }         

                    if(coverageOnProductLine && !productLineSet.isEmpty()){
                        select_clause += ' OR SVMXC__Product_Line__c IN : productLineSet ';
                    }       
           
                    select_clause += ' ) ';
                    String where_clause = ' AND  (  SVMXC__Service_Contract__r.SVMXC__Active__c = true  ';
                    
                    System.debug(logginglevel.info, 'Effective Date : ' + effectiveDateForEntitlement);
                    if(considerCountersOrDates.toUpperCase() == 'DATES' || considerCountersOrDates.toUpperCase() == 'BOTH'){
                        if(sLAandValidityLevels.equalsIgnoreCase('Contract') || sLAandValidityLevels.equalsIgnoreCase('Contract header level')){ //To do : create static final variable
                            if(!showExpiredEntitlement)  
                                where_clause += ' AND SVMXC__Service_Contract__r.SVMXC__End_Date__c >=: effectiveDateForEntitlement '; 
                            if(!showFutureEntitlement)
                                where_clause +=  ' AND SVMXC__Service_Contract__r.SVMXC__Start_Date__c <=: effectiveDateForEntitlement '; 
                        }

                        if(sLAandValidityLevels.equalsIgnoreCase('Product') || sLAandValidityLevels.equalsIgnoreCase('Product or Location line level')){  //To do : create static final variable
                            if(!showExpiredEntitlement)  
                                where_clause += ' AND (SVMXC__End_Date__c >=: effectiveDateForEntitlement OR SVMXC__End_Date__c = null )'; 
                            if(!showFutureEntitlement)
                                where_clause +=   ' AND (SVMXC__Start_Date__c <=: effectiveDateForEntitlement OR SVMXC__Start_Date__c = null ) ';
                        }
                    }
                        

                    if(matchAccount){
                        where_clause += ' AND  SVMXC__Service_Contract__r.SVMXC__Company__c = \'' + workOrderRecord.SVMXC__Company__c + '\' ';
                    }

                    where_clause += ' ) ';
                    queryString += select_clause +  where_clause + '  ORDER BY SVMXC__Service_Contract__r.Name ';
                    System.debug(logginglevel.info,' Query String To get Covered Products : ' + queryString);

                    List<SVMXC__Service_Contract_Products__c> listCoveredProducts = Database.query(queryString); //Result without Contact Match

                    Set<Id> sConIDs = new Set<Id>(); //Scons matched with Work Order Contacts
                    //Applying Contact Match
                    if(matchContact){
                        List<SVMXC__Service_Contract_Products__c> tempListCoveredProducts = new List<SVMXC__Service_Contract_Products__c>();
                        for(SVMXC__Service_Contract_Contacts__c scontact : [SELECT SVMXC__Service_Contract__c FROM SVMXC__Service_Contract_Contacts__c WHERE 
                                                                                            SVMXC__Contact__c =: workOrderRecord.SVMXC__Contact__c]){
                            sConIDs.add(scontact.SVMXC__Service_Contract__c);
                        }

                        for(SVMXC__Service_Contract_Products__c covProduct : listCoveredProducts){
                            if(covProduct.SVMXC__Service_Contract__c != null && sConIDs.contains(covProduct.SVMXC__Service_Contract__c))
                                tempListCoveredProducts.add(covProduct);
                        }
                        System.debug(LoggingLevel.INFO, 'TempList Covered Products : ' + tempListCoveredProducts);
                        listCoveredProducts = tempListCoveredProducts;
                        //tempListCoveredProducts.clear();
                    }
                    //Validating counters for covered products
                    if(considerCountersOrDates.equalsIgnoreCase('COUNTERS') || considerCountersOrDates.equalsIgnoreCase('BOTH')){
                        sConIDs.clear();
                        //List<SVMXC__Service_Contract_Products__c> tempListCoveredProducts = new List<SVMXC__Service_Contract_Products__c>();
                        Map<ID,SVMXC__Service_Contract_Products__c> SconCoveredProductMap = new Map<ID,SVMXC__Service_Contract_Products__c>();
                        for(SVMXC__Service_Contract_Products__c covProduct : listCoveredProducts){
                            sConIDs.add(covProduct.SVMXC__Service_Contract__c);
                        }

                        Map<id,SVMXC__Installed_Product__c> IBReadingMap = new Map<id,SVMXC__Installed_Product__c>([Select id,(Select id,SVMXC__Counter_Reading__c,SVMXC__Counter_Definition__c,SVMXC__Counter_Definition__r.SVMXC__Counter_Type__c from SVMXC__Counter_Details__r where SVMXC__Is_Latest__c = true) from SVMXC__Installed_Product__c where id in: installedBaseIds]);
                        Map<id,SVMXC__Service_Contract__c> sconMap = new Map<id,SVMXC__Service_Contract__c>([Select id,(Select id,SVMXC__Coverage_Starts_At__c,SVMXC__Coverage_Limit__c,SVMXC__Counter_Definition__c,SVMXC__Product__c from SVMXC__Counter_Details__r where SVMXC__Is_Counter_Active__c = true) from SVMXC__Service_Contract__c where id in: sConIDs]);
                        //
                        for(SVMXC__Service_Contract_Products__c covProduct : listCoveredProducts){
                            String SConId = covProduct.SVMXC__Service_Contract__c;
                            String IBID = covProduct.SVMXC__Installed_Product__c;
                            // Below loop checks if an IB reading is within the range of the Service Contract readings.
                            // IB and Service Contracts are linked via Service Contract Products(Covered Products)
                            if(IBReadingMap.containsKey(IBID) && IBReadingMap.get(IBID).SVMXC__Counter_Details__r != null){
                               for(SVMXC__Counter_Details__c reading : IBReadingMap.get(IBID).SVMXC__Counter_Details__r){
                                    Decimal counterReading = reading.SVMXC__Counter_Reading__c;
                                    for(SVMXC__Counter_Details__c coverage : sconMap.get(SConId).SVMXC__Counter_Details__r){
                                        if(covProduct.SVMXC__Installed_Product__r.SVMXC__Product__c == coverage.SVMXC__Product__c
                                            && reading.SVMXC__Counter_Definition__c == coverage.SVMXC__Counter_Definition__c){

                                            if(reading.SVMXC__Counter_Definition__r.SVMXC__Counter_Type__c == 'Increasing'){

                                                if(coverage.SVMXC__Coverage_Starts_At__c <= counterReading && coverage.SVMXC__Coverage_Limit__c > counterReading){
                                                    //tempListCoveredProducts.add(covProduct);
                                                    if(!SconCoveredProductMap.containsKey(IBID)){
                                                        SconCoveredProductMap.put(IBID,covProduct);
                                                    }
                                                }

                                            } else if(reading.SVMXC__Counter_Definition__r.SVMXC__Counter_Type__c == 'Decreasing') {

                                                if(coverage.SVMXC__Coverage_Starts_At__c >= counterReading && coverage.SVMXC__Coverage_Limit__c < counterReading){
                                                    //tempListCoveredProducts.add(covProduct);
                                                    if(!SconCoveredProductMap.containsKey(IBID)){
                                                        SconCoveredProductMap.put(IBID,covProduct);
                                                    }
                                                
                                                }
                                                
                                            }

                                        }
                                        
                                    }
                                } 
                            }
                                
                        }
                        //listCoveredProducts = tempListCoveredProducts;
                        listCoveredProducts = SconCoveredProductMap.values();
                    }

                    Map<Id,SVMXC__Service_Contract_Sites__c> mapServiceContractIdAndCoveredLoc = new Map<Id,SVMXC__Service_Contract_Sites__c>();
                    Map<string,SVMXC__Service_Contract__c> mapLocBasedServiceContract = new Map<string,SVMXC__Service_Contract__c>();
                    if(matchLocation && workOrderRecord.SVMXC__Site__c != null){
                        List<SVMXC__Service_Contract_Sites__c> lstCoveredLocs = new List<SVMXC__Service_Contract_Sites__c>();
                        queryString = 'SELECT SVMXC__Site__c, SVMXC__SLA_Terms__c,SVMXC__SLA_Terms__r.Name, SVMXC__Service_Contract__c,SVMXC__Service_Contract__r.SVMXC__Active__c, ' +
                                      'SVMXC__Service_Contract__r.SVMXC__Start_Date__c,SVMXC__Service_Contract__r.SVMXC__End_Date__c, Name, Id, SVMXC__End_Date__c, SVMXC__Start_Date__c ' +
                                      'FROM SVMXC__Service_Contract_Sites__c WHERE SVMXC__Site__c  =\'' + workOrderRecord.SVMXC__Site__c + '\'  AND SVMXC__Service_Contract__r.SVMXC__Active__c = true ';
                        if(sLAandValidityLevels.equalsIgnoreCase('Contract') || sLAandValidityLevels.equalsIgnoreCase('Contract header level')){ //To do : create static final variable
                            if(!showExpiredEntitlement)  
                                queryString += ' AND SVMXC__Service_Contract__r.SVMXC__End_Date__c >=: effectiveDateForEntitlement '; 
                            if(!showFutureEntitlement)
                                queryString +=  ' AND SVMXC__Service_Contract__r.SVMXC__Start_Date__c <=: effectiveDateForEntitlement '; 
                        }

                        if(sLAandValidityLevels.equalsIgnoreCase('Product') || sLAandValidityLevels.equalsIgnoreCase('Product or Location line level')){  //To do : create static final variable
                            if(!showExpiredEntitlement)  
                                queryString += ' AND (SVMXC__End_Date__c >=: effectiveDateForEntitlement OR SVMXC__End_Date__c = null )'; 
                            if(!showFutureEntitlement)
                                queryString +=   ' AND (SVMXC__Start_Date__c <=: effectiveDateForEntitlement OR SVMXC__Start_Date__c = null ) ';
                        }      


                        /*if(matchAccount && workOrderRecord.SVMXC__Company__c != null){
                            queryString += ' AND  SVMXC__Service_Contract__r.SVMXC__Company__c = \'' + workOrderRecord.SVMXC__Company__c + '\' ';
                        }   

                        if(matchContact && sConIDs.size() > 0 )
                            queryString += ' AND SVMXC__Service_Contract__c IN : sConIDs ';    */   
                        System.debug('QueryString -- Covered Location ' + queryString);
                        lstCoveredLocs = Database.query(queryString);    
                        if(!lstCoveredLocs.isEmpty()){    
                            for(SVMXC__Service_Contract_Sites__c covLocation : lstCoveredLocs){
                                mapServiceContractIdAndCoveredLoc.put(covLocation.SVMXC__Service_Contract__c,covLocation);
                            }
                            Set<Id> tempKeySet = mapServiceContractIdAndCoveredLoc.keySet();
                            string strServiceContractQuery = ' SELECT SVMXC__Company__c,Name, SVMXC__End_Date__c, SVMXC__Start_Date__c, SVMXC__Service_Level__c, SVMXC__Service_Level__r.Name, Id FROM SVMXC__Service_Contract__c WHERE Id IN: tempKeySet AND SVMXC__Active__c =  true';
                            if(matchContact)
                                strServiceContractQuery += ' AND Id IN :sConIDs' ;  
                            if(matchAccount)
                                strServiceContractQuery += ' AND  SVMXC__Company__c = \'' + workOrderRecord.SVMXC__Company__c + '\' ';
                            if(!showExpiredEntitlement)
                                strServiceContractQuery += ' AND SVMXC__End_Date__c >=: effectiveDateForEntitlement'; 
                            if(!showFutureEntitlement)
                                strServiceContractQuery +=  ' AND SVMXC__Start_Date__c <=: effectiveDateForEntitlement ';
                            
                            System.debug('QueryString -- Covered Location Scons ' + strServiceContractQuery);
                            //Get the location based Service Contract
                            mapLocBasedServiceContract.putAll((list<SVMXC__Service_Contract__c>)Database.query(strServiceContractQuery));                        
                        }
                    }

                    //Create a Scontract List for IBs
                    System.debug(LoggingLevel.INFO, 'List of Covered Products : ' + listCoveredProducts);

                   // tempEntitlementList = new List<EVER_WrapperDef.EVER_EntitlementInfo>();

                    for(SVMXC__Service_Contract_Products__c covProduct : listCoveredProducts){
                        Id entityId;
                        SVMXC__Installed_Product__c installedProdRecord ;
                        SVMXC__Service_Contract__c tempSconRecord = new SVMXC__Service_Contract__c();


                        if(!entitlementSupportOnLines){            
                            entityId = headerRecord.installedBaseId;
                            EVER_WrapperDef.EVER_EntitlementInfo entitlementInfo;
                            System.debug(logginglevel.Info, 'Contains Key : ' +  mapOfIBs.containsKey(entityId));
                            if(mapOfIBs.containsKey(entityId)){ 
                                installedProdRecord = mapOfIBs.get(entityId);
                                System.debug(logginglevel.Info, 'installedProdRecord : ' +  mapOfIBs.containsKey(entityId));
                                entitlementInfo = checkSConMatchCriteria(installedProdRecord,covProduct,false);  
                                
                                //System.debug(logginglevel.Info, 'entitlementInfo : ' +  entitlementInfo.coveredBy);
                                
                                  
                                if(entitlementInfo == null && coverageOnChildProduct && childIBMap.containsKey(entityId) && childIBMap.get(entityId).size() > 0){
                                    for(SVMXC__Installed_Product__c childIb : childIBMap.get(entityId)){
                                        entitlementInfo = checkSConMatchCriteria(childIb,covProduct,true);
                                        if(entitlementInfo != null){
                                            break; 
                                        }
                                    }   
                                } 
                                
                            }
                            if(entitlementInfo != null){
                                EVER_WrapperDef.EVER_EntitlementInfo entitlementInfo1 = expiredFutureScons(entitlementInfo,covProduct);  
                                if(mapLocBasedServiceContract.containsKey(covProduct.SVMXC__Service_Contract__c)){
                                    mapLocBasedServiceContract.remove(covProduct.SVMXC__Service_Contract__c);
                                    entitlementInfo.coveredBy += ', ' + System.Label.COMM001_TAG099;
                                    entitlementInfo.uniqueId = entitlementInfo.recordId + ((entitlementInfo.coveredBy != null) ? entitlementInfo.coveredBy : '');
                                    entitlementInfo = updateSLA(entitlementInfo,covProduct,mapServiceContractIdAndCoveredLoc.get(entitlementInfo.recordId));
                                }else
                                    entitlementInfo = updateSLA(entitlementInfo,covProduct,null);     
                                
                                serviceContractIds.add(covProduct.SVMXC__Service_Contract__c);   


                                if(considerCountersOrDates.equalsIgnoreCase('Counters') || (entitlementInfo.startDate != null && entitlementInfo.endDate != null)){
                                    if(headerRecord.listEntitlementInfo == null){
                                        headerRecord.listEntitlementInfo = new List<EVER_WrapperDef.EVER_EntitlementInfo>();
                                    } 

                                    //tempEntitlementList.add(entitlementInfo);
                                    headerRecord.listEntitlementInfo.add(entitlementInfo); 
                                    if(entitlementInfo1 != null && entitlementInfo1.coveredBy != entitlementInfo.coveredBy) 
                                        //tempEntitlementList.add(entitlementInfo1);
                                        headerRecord.listEntitlementInfo.add(entitlementInfo1);     
                                }else{
                                    if(headerRecord.listEntitlementInfo == null){
                                        headerRecord.listEntitlementInfo = new List<EVER_WrapperDef.EVER_EntitlementInfo>();
                                    } 
                                    if(entitlementInfo1 != null)
                                        //tempEntitlementList.add(entitlementInfo1);
                                        headerRecord.listEntitlementInfo.add(entitlementInfo1);     
                                }    
                            }

                        }else{
                            for(EVER_WrapperDef.EVER_DetailRecord detailRec : headerRecord.listDetailRecords){
                                //tempEntitlementList = new List<EVER_WrapperDef.EVER_EntitlementInfo>();
                                entityId = detailRec.installedBaseId;
                                EVER_WrapperDef.EVER_EntitlementInfo entitlementInfo;
                                System.debug(logginglevel.Info, 'Contains Key : ' +  mapOfIBs.containsKey(entityId));
                                if(mapOfIBs.containsKey(entityId)){ 
                                    installedProdRecord = mapOfIBs.get(entityId);
                                    System.debug(logginglevel.Info, 'installedProdRecord : ' +  installedProdRecord);
                                    entitlementInfo = checkSConMatchCriteria(installedProdRecord,covProduct,false);
                                    System.debug(logginglevel.Info, 'entitlementInfo : ' +  entitlementInfo);      
                                    if(entitlementInfo == null && coverageOnChildProduct && childIBMap.containsKey(entityId) && childIBMap.get(entityId).size() > 0){
                                        for(SVMXC__Installed_Product__c childIb : childIBMap.get(entityId)){
                                            entitlementInfo = checkSConMatchCriteria(childIb,covProduct,true); 
                                            if(entitlementInfo != null)
                                                break; 
                                        }   
                                    }      
                                }
                                if(entitlementInfo != null){
                                    EVER_WrapperDef.EVER_EntitlementInfo entitlementInfo1 = expiredFutureScons(entitlementInfo,covProduct);
                                    System.debug(logginglevel.Info, 'entitlementInfo1 : ' +  entitlementInfo1);                                
                                    if(mapLocBasedServiceContract.containsKey(entitlementInfo.recordId)){
                                        System.debug(logginglevel.Info, 'entitlementInfo Location : ' +  entitlementInfo);
                                        mapLocBasedServiceContract.remove(covProduct.SVMXC__Service_Contract__c);
                                        entitlementInfo.coveredBy += ', ' + System.Label.COMM001_TAG099;
                                        entitlementInfo.uniqueId = entitlementInfo.recordId + ((entitlementInfo.coveredBy != null) ? entitlementInfo.coveredBy : '');
                                        System.debug(logginglevel.Info, 'entitlementInfo Location 2 : ' +  entitlementInfo);
                                        entitlementInfo = updateSLA(entitlementInfo,covProduct,mapServiceContractIdAndCoveredLoc.get(entitlementInfo.recordId));
                                    }else
                                        entitlementInfo = updateSLA(entitlementInfo,covProduct,null);     
                                    System.debug(logginglevel.Info, 'entitlementInfo Start Date' +  entitlementInfo);
                                    if(considerCountersOrDates.equalsIgnoreCase('Counters') || (entitlementInfo.startDate != null && entitlementInfo.endDate != null)){
                                        if(detailRec.listEntitlementInfo == null){
                                            detailRec.listEntitlementInfo = new List<EVER_WrapperDef.EVER_EntitlementInfo>();
                                        }
                                        detailRec.listEntitlementInfo.add(entitlementInfo); 
                                        if(entitlementInfo1 != null && entitlementInfo1.coveredBy != entitlementInfo.coveredBy) 
                                           detailRec.listEntitlementInfo.add(entitlementInfo1);     
                                    }else{
                                        if(detailRec.listEntitlementInfo == null){
                                            detailRec.listEntitlementInfo = new List<EVER_WrapperDef.EVER_EntitlementInfo>();
                                        }
                                        if(entitlementInfo1 != null)
                                            detailRec.listEntitlementInfo.add(entitlementInfo1);     
                                    }   
                                }

                                /*if(!tempEntitlementList.isEmpty()){
                                    
                                    if(detailRec.listEntitlementInfo == null){
                                        detailRec.listEntitlementInfo = new List<EVER_WrapperDef.EVER_EntitlementInfo>();
                                    }

                                    detailRec.listEntitlementInfo.addAll(removeDuplicates(tempEntitlementList)); 
                                }*/
                                
                            }
                        }

                        /*if(!tempEntitlementList.isEmpty()){
                            
                            if(headerRecord.listEntitlementInfo == null){
                                headerRecord.listEntitlementInfo = new List<EVER_WrapperDef.EVER_EntitlementInfo>();
                            }

                            headerRecord.listEntitlementInfo.addAll(removeDuplicates(tempEntitlementList)); 
                        }*/
                    }

                    if(mapLocBasedServiceContract.size() > 0)
                    {
                        tempEntitlementList = new List<EVER_WrapperDef.EVER_EntitlementInfo>();
                        for(Id sCONId : mapLocBasedServiceContract.keySet())    
                        {
                            EVER_WrapperDef.EVER_EntitlementInfo entitlementInfo = new EVER_WrapperDef.EVER_EntitlementInfo();
                            SVMXC__Service_Contract__c tempScontractRec = new SVMXC__Service_Contract__c();
                            tempScontractRec = mapLocBasedServiceContract.get(sCONId);
                            serviceContractIds.add(tempScontractRec.Id); 
                            entitlementInfo.recordId = tempScontractRec.Id;    
                            entitlementInfo.recordName = tempScontractRec.Name;
                            entitlementInfo.coveredBy = System.Label.COMM001_TAG099;   
                            entitlementInfo.startDate = localeDateFormat(tempScontractRec.SVMXC__Start_Date__c);
                            entitlementInfo.endDate = localeDateFormat(tempScontractRec.SVMXC__End_Date__c);
                            entitlementInfo.warrantyOrScon = 'scontract';
                            entitlementInfo.uniqueId = entitlementInfo.recordId + ((entitlementInfo.coveredBy != null) ? entitlementInfo.coveredBy : '');
                            SVMXC__Service_Contract_Sites__c coveredLocationRec = mapServiceContractIDANDCoveredLoc.get(tempScontractRec.Id);

                            if(sLAandValidityLevels == 'Contract' || sLAandValidityLevels == 'Contract header level')
                            {
                                entitlementInfo.sLARecordId = tempScontractRec.SVMXC__Service_Level__c;                          
                                entitlementInfo.sLARecordName = tempScontractRec.SVMXC__Service_Level__r.Name;
                                entitlementInfo.startDate = localeDateFormat(tempScontractRec.SVMXC__Start_Date__c);
                                entitlementInfo.endDate = localeDateFormat(tempScontractRec.SVMXC__End_Date__c);
                            }else if(sLAandValidityLevels =='Product' || sLAandValidityLevels == 'Product or Location line level'){
                                entitlementInfo = updateSLALocation(entitlementInfo, coveredLocationRec);
                            }
                            tempEntitlementList.add(entitlementInfo);
                        }

                        if(tempEntitlementList.size() > 0){
                            if(!entitlementSupportOnLines){  
                                if(headerRecord.listEntitlementInfo == null){
                                    headerRecord.listEntitlementInfo = new List<EVER_WrapperDef.EVER_EntitlementInfo>();
                                }
                                headerRecord.listEntitlementInfo.addAll(tempEntitlementList);  
                            }else{
                                
                                for(EVER_WrapperDef.EVER_DetailRecord detailRec : headerRecord.listDetailRecords){
                                    if(detailRec.listEntitlementInfo == null){
                                        detailRec.listEntitlementInfo = new List<EVER_WrapperDef.EVER_EntitlementInfo>();
                                    }
                                    detailRec.listEntitlementInfo.addAll(tempEntitlementList);
                                }
                            }    
                        }
                    }    
                }                  
            }
            

            if(headerRecord.listEntitlementInfo != null || headerRecord.listDetailRecords != null){
                
                if(!entitlementSupportOnLines){
                    
                    tempEntitlementList = headerRecord.listEntitlementInfo;
                    headerRecord.listEntitlementInfo = removeDuplicates(tempEntitlementList);

                }else{
                     
                     for(EVER_WrapperDef.EVER_DetailRecord detailRec : headerRecord.listDetailRecords){
                         tempEntitlementList = detailRec.listEntitlementInfo;
                         detailRec.listEntitlementInfo = removeDuplicates(tempEntitlementList);
                     }
                }
            }

            if(!entitlementSupportOnLines && serviceBasedEntitlement && !serviceContractIds.isEmpty()){  
                Map<Id,List<AvailableServices>> sortedCoveredServicesMap = getCoveredServices(serviceContractIds,workOrderId);
                if(!sortedCoveredServicesMap.isEmpty()){
                    for(EVER_WrapperDef.EVER_EntitlementInfo entitlementInfo : headerRecord.listEntitlementInfo){
                        if(entitlementInfo.warrantyOrScon == 'scontract'){
                            if(sortedCoveredServicesMap.containsKey(entitlementInfo.recordID)) {
                                List<EVER_WrapperDef.Ever_CoveredService> coveredServiceList = new List<EVER_WrapperDef.Ever_CoveredService>();
                                for(AvailableServices availServices : sortedCoveredServicesMap.get(entitlementInfo.recordID)){
                                    coveredServiceList.add(availServices.covServiceWrapRec);
                                }
                                if(!coveredServiceList.isEmpty()){
                                    coveredServiceList[0].selected = true;
                                    entitlementInfo.coveredService = coveredServiceList;
                                }
                            }
                        }
                    }
                }
            }
            response.headerRecord = headerRecord;
            response.messageList.add(System.Label.EVER005_TAG106);
        }catch(Exception ex){   
            response.success = false;
            response.messageList.add( ex.getMessage() );
            System.debug(logginglevel.Info, 'Stack Trace : ' + ex.getStackTraceString());
        }   

        return response;
    }

    List<EVER_WrapperDef.EVER_EntitlementInfo> removeDuplicates(List<EVER_WrapperDef.EVER_EntitlementInfo> entitlementList){
        
        List<EVER_WrapperDef.EVER_EntitlementInfo> tempList = new List<EVER_WrapperDef.EVER_EntitlementInfo>();
        Set<String> uniqueSet = new Set<String>();
        if(entitlementList!= null && entitlementList.size() > 0){ // Added for BAC-4313
            for(EVER_WrapperDef.EVER_EntitlementInfo entitlementInfoRec : entitlementList){
    
                if(!uniqueSet.contains(entitlementInfoRec.uniqueId)){
                    
                    uniqueSet.add(entitlementInfoRec.uniqueId);
                    tempList.add(entitlementInfoRec);
                }
    
            }
        }
        return tempList;
    }

    public EVER_WrapperDef.EVER_Response saveEntitlementInfo (EVER_WrapperDef.EVER_Request request) {
        
        EVER_WrapperDef.EVER_Response response = new EVER_WrapperDef.EVER_Response();
        response.success = true;

        if(request == null || request.entitlementInfoMap == null || Request.entitlementSettings == null ){
            response.success = false;
            response.messageList.add(System.Label.EVER001_TAG087); //Invalid Request
            return response;
        }        
        EVER_WrapperDef.EVER_Settings entitlementSettings = Request.entitlementSettings;
        if(!request.entitlementInfoMap.isEmpty()){
            List<EVER_WrapperDef.EVER_InfoMap> entitlementInfoMap = request.entitlementInfoMap;
            Map<Id,sObject> sObjectMapToUpdate = new Map<Id,sObject>();  //common sobject list used for updated history records & included services
            Map<Id,EVER_WrapperDef.EVER_EntitlementInfo> entitlementWOMap = new Map<Id,EVER_WrapperDef.EVER_EntitlementInfo>();
            Map<Id,SVMXC__Entitlement_History__c> entitlementInfoHistory = new Map<Id,SVMXC__Entitlement_History__c>();

            entitlementSupportOnLines = (entitlementSettings.entitlementSupportOnLines != null) ? boolean.valueof(entitlementSettings.entitlementSupportOnLines): false;            
            EVER_WrapperDef.EVER_InfoMap wOEntitlementInfo = new EVER_WrapperDef.EVER_InfoMap();
            EVER_WrapperDef.EVER_EntitlementInfo entitlementInfo;    
            SVMXC__Entitlement_History__c historyRecord; 
            
            Set<Id> recordIds = new Set<Id>(); //Contains Ids for querying entitlement history records for updating the inactive date incase of not covered
            
            if(!entitlementSupportOnLines){
                
                if(request.entitlementInfoMap.size() == 1){
                    wOEntitlementInfo = request.entitlementInfoMap[0];
                    entitlementInfo = wOEntitlementInfo.entitlementInfo;
                    SVMXC__Service_Order__c workOrderInstance = new SVMXC__Service_Order__c(Id = wOEntitlementInfo.recordID);
                    workOrderInstance.SVMXC__Warranty__c = null;
                    workOrderInstance.SVMXC__Service_Contract__c = null;
                    workOrderInstance.SVMXC__SLA_Terms__c = null;
                    workOrderInstance.SVMXC__Entitlement_Type__c = 'INTERACTIVE'; 
                    if(entitlementSettings.setBillingType.equalsIgnoreCase('True'))
                        workOrderInstance.SVMXC__Billing_Type__c = '';
                    workOrderInstance.SVMXC__Entitlement_Notes__c = entitlementInfo.entitlementNotes;                   
                    if(entitlementInfo.warrantyOrScon == 'warranty' || entitlementInfo.warrantyOrScon == 'scontract'){
                        historyRecord = new SVMXC__Entitlement_History__c();  
                        historyRecord.SVMXC__Date_of_entitlement__c = System.Today();
                        historyRecord.SVMXC__Inactive_Date__c = null;
                        historyRecord.SVMXC__Service_Order__c = wOEntitlementInfo.recordID;
                        
                        if(entitlementInfo.warrantyOrScon == 'warranty'){
                            if(entitlementSettings.setBillingType.equalsIgnoreCase('True'))
                               workOrderInstance.SVMXC__Billing_Type__c = 'Warranty'; 
                            workOrderInstance.SVMXC__Warranty__c = entitlementInfo.recordId;
                            historyRecord.SVMXC__Warranty__c = entitlementInfo.recordId;
                        }
                        else{
                            serviceBasedEntitlement = Boolean.valueof(entitlementSettings.serviceBasedEntitlement);
                            if(entitlementSettings.setBillingType.equalsIgnoreCase('True'))
                               workOrderInstance.SVMXC__Billing_Type__c = 'Contract'; 
                            if(serviceBasedEntitlement){   
                               SVMXC__Service_Contract_Services__c covServiceRec = setCoveredService(entitlementInfo.coveredService); 
                               if(covServiceRec != null){
                                   historyRecord.SVMXC__Entitled_By_Service__c = covServiceRec.Id;
                                   historyRecord.SVMXC__Entitled_Within_Threshold__c = (covServiceRec.SVMXC__Included_Units__c != null && covServiceRec.SVMXC__Included_Units__c >= covServiceRec.SVMXC__Consumed_Units__c ) ? True : False;
                                   workOrderInstance.SVMXC__Is_Service_Covered__c = true;
                                   sObjectMapToUpdate.put(covServiceRec.Id,covServiceRec);
                               }
                            }   
                            workOrderInstance.SVMXC__Service_Contract__c = entitlementInfo.recordId;
                            workOrderInstance.SVMXC__SLA_Terms__c = entitlementInfo.sLARecordId;
                            historyRecord.SVMXC__Service_Contract__c = entitlementInfo.recordId;
                            historyRecord.SVMXC__SLA_Terms__c = entitlementInfo.sLARecordId;
                        }

                        if(entitlementInfo.coveredBy != null ){
                            historyRecord.SVMXC__Covered_By__c = entitlementInfo.coveredBy;
                        }
                        
                        if(entitlementInfo.startDate != null && entitlementInfo.endDate != null){
                            historyRecord.SVMXC__Start_Date__c = Date.parse(entitlementInfo.startDate);
                            historyRecord.SVMXC__End_Date__c = Date.parse(entitlementInfo.endDate);
                            
                        } 
                        historyRecord.SVMXC__Entitlement_notes__c = entitlementInfo.entitlementNotes; 
                        entitlementInfoHistory.put(wOEntitlementInfo.recordID,historyRecord);
                        sObjectMapToUpdate = updateIncludedServiceCount(new Set<Id>{wOEntitlementInfo.recordID},sObjectMapToUpdate);
                    }else{
                        recordIds.add(wOEntitlementInfo.recordID);
                    }
                    workOrderInstance.SVMXC__Is_Entitlement_Performed__c = true;
                    entitlementWOMap.put(wOEntitlementInfo.recordID,entitlementInfo);
                    sObjectMapToUpdate.put(wOEntitlementInfo.recordID,(sObject)workOrderInstance);  
                }
            }else{
                //Set<Id> lineIds = new Set<Id>();
                for(EVER_WrapperDef.EVER_InfoMap workDetailInfo : entitlementInfoMap){
                    entitlementInfo = workDetailInfo.entitlementInfo;
                    SVMXC__Service_Order_Line__c  workDetailInstance = new SVMXC__Service_Order_Line__c (Id = workDetailInfo.recordID);
                    workDetailInstance.SVMXC__Product_Warranty__c = null;
                    workDetailInstance.SVMXC__Service_Maintenance_Contract__c = null;
                    workDetailInstance.SVMXC__Entitlement_Notes__c  = entitlementInfo.entitlementNotes;                      
                    if(entitlementInfo.warrantyOrScon == 'warranty' || entitlementInfo.warrantyOrScon == 'scontract'){
                       // lineIds.add(workDetailInfo.recordID);
                        historyRecord = new SVMXC__Entitlement_History__c(); 
                        historyRecord.SVMXC__Date_of_entitlement__c = System.Today();
                        historyRecord.SVMXC__Inactive_Date__c = null;
                        historyRecord.SVMXC__Work_Detail__c = workDetailInfo.recordID;                        
                        if(entitlementInfo.warrantyOrScon == 'warranty'){
                            workDetailInstance.SVMXC__Product_Warranty__c = entitlementInfo.recordId;
                            historyRecord.SVMXC__Warranty__c = entitlementInfo.recordId;
                        }
                        else{
                            workDetailInstance.SVMXC__Service_Maintenance_Contract__c = entitlementInfo.recordId;
                            historyRecord.SVMXC__Service_Contract__c = entitlementInfo.recordId;
                            //historyRecord.SVMXC__SLA_Terms__c = entitlementInfo.sLARecordId;                            
                            //workDetailInstance.SVMXC__SLA_Terms__c = entitlementInfo.sLARecordId;
                        }

                        if(entitlementInfo.coveredBy != null ){
                            historyRecord.SVMXC__Covered_By__c = entitlementInfo.coveredBy;
                        }
                        
                        //workOrderInstance.SVMXC__Entitlement_Type__c = 'INTERACTIVE';   
                        
                        if(entitlementInfo.startDate != null && entitlementInfo.endDate != null){
                            historyRecord.SVMXC__Start_Date__c = Date.parse(entitlementInfo.startDate);
                            historyRecord.SVMXC__End_Date__c = Date.parse(entitlementInfo.endDate);
                        } 
                        historyRecord.SVMXC__Entitlement_notes__c = entitlementInfo.entitlementNotes; 
                        entitlementInfoHistory.put(workDetailInfo.recordID,historyRecord);
                    }else{
                        recordIds.add(workDetailInfo.recordID);
                    }
                    workDetailInstance.SVMXC__Is_Entitlement_Performed__c = true;
                    entitlementWOMap.put(workDetailInfo.recordID,entitlementInfo);
                    sObjectMapToUpdate.put(workDetailInfo.recordID,(sObject)workDetailInstance);
                    
                }
                
                /* Included Services not supported for PS, can be used for future enhancement 
                if(lineIds.isEmpty()){
                    sObjectMapToUpdate = updateIncludedServiceCount(recordIds,sObjectMapToUpdate,'lines');
                }*/
            }

            try{
                if(!sObjectMapToUpdate.isEmpty()){
                    EVER_WrapperDef.EVER_HeaderRecord headerRecord = new EVER_WrapperDef.EVER_HeaderRecord();
                    List<Database.Saveresult> saveResultList = Database.update(sObjectMapToUpdate.values(), false);
                    List<EVER_WrapperDef.EVER_DetailRecord> detailsList = new List<EVER_WrapperDef.EVER_DetailRecord>();
                    //List<SVMXC__Entitlement_History__c> historyRecordsToUpdate = new List<SVMXC__Entitlement_History__c>();
                    for(Database.Saveresult sr : saveResultList){
                        if(sr.isSuccess()){
                            if(entitlementWOMap.containsKey(sr.getId())){
                               sObject tempSobj = sObjectMapToUpdate.get(sr.getId());
                               System.debug('sObject : ' + tempSobj);
                               EVER_WrapperDef.EVER_EntitlementInfo entitlementDetails = entitlementWOMap.get(sr.getId()); 
                               if(entitlementDetails != null)
                                    entitlementDetails.entitlementNotes = String.valueof(tempSobj.get('SVMXC__Entitlement_Notes__c')); 
                               if(!entitlementSupportOnLines){
                                   headerRecord.recordID = sr.getId();
                                   headerRecord.entitlementPerformed = true;
                                    //headerRecord.selectedEntitlementInfo = setSelectedHeaderEntitlementInfo((SVMXC__Service_Order__c)tempSobj);
                                   headerRecord.selectedEntitlementInfo = entitlementDetails;
                               }else{
                                    EVER_WrapperDef.EVER_DetailRecord detailRecord = new EVER_WrapperDef.EVER_DetailRecord();
                                    detailRecord.recordID = tempSobj.Id;
                                    detailRecord.entitlementPerformed = true;
                                    //detailRecord.selectedEntitlementInfo = setSelectedDetailEntitlementInfo((SVMXC__Service_Order_Line__c)tempSobj);
                                    detailRecord.selectedEntitlementInfo = entitlementDetails;
                                    detailsList.add(detailRecord);
                               }                                
                            } 
                        }else{
                            if(entitlementInfoHistory.containsKey(sr.getId()))
                               entitlementInfoHistory.remove(sr.getId());
                            response.warning = true;     
                            response.success = false;
                            response.messageList.add('Failed :' + sr.getId());
                            for(Database.Error err : sr.getErrors()) {
                                System.debug('The following error has occurred.');                    
                                System.debug(err.getStatusCode() + ': ' + err.getMessage());
                            }
                        }    
                    }

                    Set<Id> keySetIds = new Set<Id>();
                    if(!entitlementInfoHistory.isEmpty())
                        keySetIds.addAll(entitlementInfoHistory.keySet());
                    if(!recordIds.isEmpty())  
                       keySetIds.addAll(recordIds); 
                    if(!keySetIds.isEmpty()){
                        String hQueryStr = 'SELECT Id, SVMXC__Inactive_Date__c FROM SVMXC__Entitlement_History__c  WHERE SVMXC__Inactive_Date__c  = null AND ';
                        List<SVMXC__Entitlement_History__c> historyRecords = new List<SVMXC__Entitlement_History__c>();
  
                        if(!entitlementSupportOnLines)
                            hQueryStr += ' SVMXC__Service_Order__c IN : keySetIds ';
                        else
                            hQueryStr += ' SVMXC__Work_Detail__c IN : keySetIds ';
                        hQueryStr += ' ORDER BY CreatedDate DESC LIMIT 1000 ';    
                        System.debug(logginglevel.info, 'QueryString : ' + hQueryStr);
                        for(SVMXC__Entitlement_History__c historyRec : Database.query(hQueryStr)){
                            historyRec.SVMXC__Inactive_Date__c = System.Today(); 
                            historyRecords.add(historyRec);
                        } 
                        historyRecords.addAll(entitlementInfoHistory.values());   
                        //upsert historyRecords;
                        if(COMM_SecurityUtils.getInstance().verifyFieldAccess(historyRecords, COMM_SecurityUtils.Access.Upsertable)){
                            upsert historyRecords; //SDL-SVMX-CREATE-UPDATE-FLS-ENFORCED
                        }
                        else{
                            throw new COMM_SecurityUtils.SecurityAccessException(System.label.COMM001_TAG142);
                        }
                    }
                    headerRecord.listDetailRecords = detailsList;
                    response.headerRecord = headerRecord;
                    if(response.success)
                        response.messageList.add(System.Label.EVER005_TAG107);
                }    
            }catch(DmlException ex){
                response.success = false;
                response.messageList.add(ex.getMessage());
            }

        }
        return response;
    }   

    /* Do not delete
    Set<Id> getIds(Id currentId,Map<Id,Set<Id>> childIBMap){
        Set<Id> idSet = childIBMap.get(currentId);
        for(Id idVar : idSet){ 
            if(childIBMap.containsKey(idVar))
                idSet.addAll(getIds(idVar,childIBMap));
        }
        return idSet;
    }*/

    SVMXC__Service_Contract_Services__c setCoveredService(List<EVER_WrapperDef.Ever_CoveredService> coveredServiceList){
        SVMXC__Service_Contract_Services__c coveredServiceRecord;
        if(coveredServiceList!= null && !coveredServiceList.isEmpty()){
            for(EVER_WrapperDef.Ever_CoveredService covServiceRec : coveredServiceList){
                if(covServiceRec.selected != null && covServiceRec.selected){
                    coveredServiceRecord = new SVMXC__Service_Contract_Services__c();
                    coveredServiceRecord.Id = covServiceRec.recordID;
                    Decimal allowunits = (covServiceRec.allowedUnits != null) ? Decimal.valueOf(covServiceRec.allowedUnits) : null;
                    Decimal consumedUnits = (covServiceRec.consumedUnits != null) ? Decimal.valueOf(covServiceRec.consumedUnits) : 0;
                    coveredServiceRecord.SVMXC__Included_Units__c = allowunits;
                    coveredServiceRecord.SVMXC__Consumed_Units__c = ++consumedUnits;
                    covServiceRec.allowedUnits = String.valueof(coveredServiceRecord.SVMXC__Consumed_Units__c);
                    if(covServiceRec.availableUnits != System.Label.COMM001_TAG125 ){
                        Decimal availableUnits = allowunits - consumedUnits;
                        if(availableUnits < 0) 
                          availableUnits = 0;
                        covServiceRec.availableUnits = String.valueof(availableUnits);
                    }  
                    return coveredServiceRecord;
                } 
            }
        }
        return null;
    }

    String getHeaderQueryString(String effectiveDateString){
        String queryString = 'select Id, Name,SVMXC__Component__c, SVMXC__Component__r.Name,SVMXC__Component__r.SVMXC__Product_Name__c ,SVMXC__Company__c, SVMXC__Company__r.Name,SVMXC__Contact__c, SVMXC__Contact__r.Name, SVMXC__Service_Contract__c, ' +
                             'SVMXC__Site__c, SVMXC__Service_Contract__r.Name, SVMXC__Entitlement_Notes__c, SVMXC__SLA_Terms__c,SVMXC__SLA_Terms__r.Name, SVMXC__Is_Service_Covered__c , SVMXC__Warranty__c , SVMXC__Warranty__r.Name , SVMXC__Warranty__r.SVMXC__Installed_Product__r.Name,' +
                             'SVMXC__Warranty__r.SVMXC__Service_Template__c, SVMXC__Warranty__r.SVMXC__Service_Template__r.Name ,SVMXC__Warranty__r.SVMXC__Start_Date__c,SVMXC__Warranty__r.SVMXC__End_Date__c, SVMXC__Problem_Description__c, ' +
                             'SVMXC__Service_Contract__r.SVMXC__Start_Date__c , SVMXC__Service_Contract__r.SVMXC__End_Date__c , SVMXC__Is_Entitlement_Performed__c';
        if(effectiveDateString != null && !effectiveDateString.equalsIgnoreCase('Today'))
            queryString += ' , ' + effectiveDateString;
        else
            effectiveDateForEntitlement = date.today();   
       /* if(entitlementSupportOnLines){
            queryString +=' , ' + '(SELECT Id, Name, SVMXC__Is_Entitlement_Performed__c, SVMXC__Serial_Number__c,SVMXC__Serial_Number__r.Name,SVMXC__Serial_Number__r.SVMXC__Product_Name__c, SVMXC__Product__c,SVMXC__Service_Order__c,SVMXC__Service_Maintenance_Contract__c, ' +
                           'SVMXC__Service_Maintenance_Contract__r.Name ,SVMXC__Product_Warranty__c, SVMXC__Product_Warranty__r.Name,SVMXC__Product_Warranty__r.SVMXC__Service_Template__c, SVMXC__Entitlement_Notes__c, SVMXC__Work_Description__c, SVMXC__Product_Warranty__r.SVMXC__Installed_Product__r.Name, ' +
                            ' SVMXC__Product_Warranty__r.SVMXC__Start_Date__c, SVMXC__Product_Warranty__r.SVMXC__End_Date__c, SVMXC__Product_Warranty__r.SVMXC__Service_Template__r.Name, SVMXC__Service_Maintenance_Contract__r.SVMXC__Start_Date__c, SVMXC__Service_Maintenance_Contract__r.SVMXC__End_Date__c' +
                            ' FROM SVMXC__Service_Order_Line__r ' +
                            ' WHERE RecordType.DeveloperName = \'Products_Serviced\'';
            if(productServicedLineIds != null && !productServicedLineIds.isEmpty())
                queryString += ' AND ID IN : productServicedLineIds ';  
            queryString += ' )' ;             
        }*/
        return queryString;
    }
    
    String getDetailQueryString(){
        String queryString = 'SELECT Id, Name, SVMXC__Is_Entitlement_Performed__c, SVMXC__Serial_Number__c,SVMXC__Serial_Number__r.Name,SVMXC__Serial_Number__r.SVMXC__Product_Name__c, SVMXC__Product__c,SVMXC__Service_Order__c,SVMXC__Service_Maintenance_Contract__c, ' +
                             'SVMXC__Service_Maintenance_Contract__r.Name ,SVMXC__Product_Warranty__c, SVMXC__Product_Warranty__r.Name,SVMXC__Product_Warranty__r.SVMXC__Service_Template__c, SVMXC__Entitlement_Notes__c, SVMXC__Work_Description__c, SVMXC__Product_Warranty__r.SVMXC__Installed_Product__r.Name, ' +
                             'SVMXC__Product_Warranty__r.SVMXC__Start_Date__c, SVMXC__Product_Warranty__r.SVMXC__End_Date__c, SVMXC__Product_Warranty__r.SVMXC__Service_Template__r.Name, SVMXC__Service_Maintenance_Contract__r.SVMXC__Start_Date__c, SVMXC__Service_Maintenance_Contract__r.SVMXC__End_Date__c ' ;
        return queryString;                    
    }

    EVER_WrapperDef.EVER_EntitlementInfo expiredFutureScons(EVER_WrapperDef.EVER_EntitlementInfo entitlementInfo,SVMXC__Service_Contract_Products__c covProduct){
       EVER_WrapperDef.EVER_EntitlementInfo entitlementInfo1 = entitlementInfo.clone();
       if(showExpiredEntitlement && covProduct.SVMXC__End_Date__c < effectiveDateForEntitlement){
            entitlementInfo1.sLARecordId = covProduct.SVMXC__SLA_Terms__c;                      
            entitlementInfo1.sLARecordName = covProduct.SVMXC__SLA_Terms__r.Name;
            entitlementInfo1.startDate = localeDateFormat(covProduct.SVMXC__Start_Date__c);
            entitlementInfo1.endDate = localeDateFormat(covProduct.SVMXC__End_Date__c);  
            return entitlementInfo1;           
        }

        if(showFutureEntitlement && covProduct.SVMXC__Start_Date__c > effectiveDateForEntitlement){
            entitlementInfo1.sLARecordId = covProduct.SVMXC__SLA_Terms__c;                      
            entitlementInfo1.sLARecordName = covProduct.SVMXC__SLA_Terms__r.Name;
            entitlementInfo1.startDate = localeDateFormat(covProduct.SVMXC__Start_Date__c);
            entitlementInfo1.endDate = localeDateFormat(covProduct.SVMXC__End_Date__c);  
            return entitlementInfo1;                       
        }
        return null;
    }

    EVER_WrapperDef.EVER_EntitlementInfo checkSConMatchCriteria(SVMXC__Installed_Product__c installedProduct , SVMXC__Service_Contract_Products__c covProduct, Boolean onChild){
        EVER_WrapperDef.EVER_EntitlementInfo entitlementInfo;
        Boolean matchFound = false;
        String coveredBy;
        if(covProduct.SVMXC__Installed_Product__c != null && covProduct.SVMXC__Installed_Product__c == installedProduct.Id){
            matchFound = true;
            coveredBy = System.Label.EVER005_TAG011;
        }
        else if(!onChild && coverageOnParentProduct && covProduct.SVMXC__Installed_Product__c != null && (covProduct.SVMXC__Installed_Product__c == installedProduct.SVMXC__Parent__c)){
            matchFound = true;
            coveredBy = System.Label.EVER005_TAG011;
        }
        else if(!onChild && coverageOnTopLevelProduct && covProduct.SVMXC__Installed_Product__c != null && (covProduct.SVMXC__Installed_Product__c == installedProduct.SVMXC__Top_Level__c)){
            matchFound = true;
            coveredBy = System.Label.EVER005_TAG011;
        }
        else if(coverageOnPartProduct && covProduct.SVMXC__Product__c != null && (covProduct.SVMXC__Product__c == installedProduct.SVMXC__Product__c)){
            matchFound = true;
            coveredBy = System.Label.EVER005_TAG012;
        }
        else if(coverageOnProductFamily && covProduct.SVMXC__Product_Family__c != null && (covProduct.SVMXC__Product_Family__c == installedProduct.SVMXC__Product__r.Family)){
            matchFound = true;
            coveredBy = System.Label.EVER005_TAG013;
        }
        else if(coverageOnProductLine && covProduct.SVMXC__Product_Line__c != null && (covProduct.SVMXC__Product_Line__c == installedProduct.SVMXC__Product__r.SVMXC__Product_Line__c)){  
            matchFound = true;  
            coveredBy = System.Label.EVER005_TAG014;
        }
        
        if(matchFound){
            entitlementInfo = new EVER_WrapperDef.EVER_EntitlementInfo();
            entitlementInfo.warrantyOrScon = 'scontract';
            entitlementInfo.recordId = covProduct.SVMXC__Service_Contract__c;
            entitlementInfo.recordName = covProduct.SVMXC__Service_Contract__r.Name;
            entitlementInfo.coveredBy = coveredby;
            entitlementInfo.uniqueId =  entitlementInfo.recordId +  ((entitlementInfo.coveredBy != null) ? entitlementInfo.coveredBy : '');
            //entitlementInfo.startDate = covProduct.SVMXC__Service_Contract__r.SVMXC__Start_Date__c;
            //entitlementInfo.endDate = covProduct.SVMXC__Service_Contract__r.SVMXC__End_Date__c;
            //entitlementInfo.sLARecordId = covProduct.SVMXC__Service_Contract__r.SVMXC__Service_Level__c;
            //entitlementInfo.sLARecordName = covProduct.SVMXC__Service_Contract__r.SVMXC__Service_Level__r.Name;              
        }
        return entitlementInfo;
    }

    EVER_WrapperDef.EVER_EntitlementInfo updateSLA(EVER_WrapperDef.EVER_EntitlementInfo entitlementInfo, SVMXC__Service_Contract_Products__c covProduct, SVMXC__Service_Contract_Sites__c covLocation){
        if(sLAandValidityLevels == 'Contract' || sLAandValidityLevels == 'Contract header level')
        {
            entitlementInfo.sLARecordId = covProduct.SVMXC__Service_Contract__r.SVMXC__Service_Level__c;                          
            entitlementInfo.sLARecordName = covProduct.SVMXC__Service_Contract__r.SVMXC__Service_Level__r.Name;
            entitlementInfo.startDate = localeDateFormat(covProduct.SVMXC__Service_Contract__r.SVMXC__Start_Date__c);
            entitlementInfo.endDate = localeDateFormat(covProduct.SVMXC__Service_Contract__r.SVMXC__End_Date__c);
            return entitlementInfo;
        }
        else if(sLAandValidityLevels == 'Product' || sLAandValidityLevels == 'Product or Location line level'){
            if(covProduct.SVMXC__Start_Date__c != null && covProduct.SVMXC__End_Date__c != null){
                entitlementInfo.startDate = localeDateFormat(covProduct.SVMXC__Start_Date__c);
                entitlementInfo.endDate = localeDateFormat(covProduct.SVMXC__End_Date__c);   
                if(covProduct.SVMXC__Start_Date__c <= effectiveDateForEntitlement && covProduct.SVMXC__End_Date__c >= effectiveDateForEntitlement){
                    if(covProduct.SVMXC__SLA_Terms__c != null && String.valueOf(covProduct.SVMXC__SLA_Terms__c).length() > 0){
                        entitlementInfo.sLARecordId = covProduct.SVMXC__SLA_Terms__c;                      
                        entitlementInfo.sLARecordName = covProduct.SVMXC__SLA_Terms__r.Name;
                    }else{
                        entitlementInfo.sLARecordId = covProduct.SVMXC__Service_Contract__r.SVMXC__Service_Level__c;                          
                        entitlementInfo.sLARecordName = covProduct.SVMXC__Service_Contract__r.SVMXC__Service_Level__r.Name;                        
                    }                                     
                    return entitlementInfo;
                }else{
                    if(matchLocation && covLocation != null)
                        return updateSLALocation(entitlementInfo, covLocation);
                }

            }else{
                entitlementInfo.startDate = localeDateFormat(covProduct.SVMXC__Service_Contract__r.SVMXC__Start_Date__c);
                entitlementInfo.endDate = localeDateFormat(covProduct.SVMXC__Service_Contract__r.SVMXC__End_Date__c);         
                entitlementInfo.sLARecordId = covProduct.SVMXC__Service_Contract__r.SVMXC__Service_Level__c;                          
                entitlementInfo.sLARecordName = covProduct.SVMXC__Service_Contract__r.SVMXC__Service_Level__r.Name;                       
                if(covProduct.SVMXC__SLA_Terms__c != null && String.valueOf(covProduct.SVMXC__SLA_Terms__c).length() > 0){
                    entitlementInfo.sLARecordId = covProduct.SVMXC__SLA_Terms__c;                      
                    entitlementInfo.sLARecordName = covProduct.SVMXC__SLA_Terms__r.Name;        
                }   
                return entitlementInfo;             
            }        
        }        
        return entitlementInfo;

    }

    EVER_WrapperDef.EVER_EntitlementInfo updateSLALocation(EVER_WrapperDef.EVER_EntitlementInfo entitlementInfo, SVMXC__Service_Contract_Sites__c covLocation){
        if(covLocation.SVMXC__Start_Date__c != null && covLocation.SVMXC__End_Date__c != null){
            if(covLocation.SVMXC__Start_Date__c <= effectiveDateForEntitlement && covLocation.SVMXC__End_Date__c >= effectiveDateForEntitlement){
                entitlementInfo.startDate = localeDateFormat(covLocation.SVMXC__Start_Date__c);                        
                entitlementInfo.endDate = localeDateFormat(covLocation.SVMXC__End_Date__c);
                //entitlementInfo.sLARecordId = covLocation.SVMXC__Service_Contract__r.SVMXC__SLA_Terms__c;                      
                //entitlementInfo.sLARecordName = covLocation.SVMXC__Service_Contract__r.SVMXC__SLA_Terms__r.Name;                
                if(covLocation.SVMXC__SLA_Terms__c != null && String.valueOf(covLocation.SVMXC__SLA_Terms__c).length() > 0){
                    entitlementInfo.sLARecordId = covLocation.SVMXC__SLA_Terms__c;                      
                    entitlementInfo.sLARecordName = covLocation.SVMXC__SLA_Terms__r.Name;
                }
            }else if(showExpiredEntitlement && covLocation.SVMXC__End_Date__c < effectiveDateForEntitlement){
                entitlementInfo.sLARecordId = covLocation.SVMXC__SLA_Terms__c;                      
                entitlementInfo.sLARecordName = covLocation.SVMXC__SLA_Terms__r.Name;
                entitlementInfo.startDate = localeDateFormat(covLocation.SVMXC__Start_Date__c);
                entitlementInfo.endDate = localeDateFormat(covLocation.SVMXC__End_Date__c);
            }else if(showFutureEntitlement && covLocation.SVMXC__Start_Date__c > effectiveDateForEntitlement){
                entitlementInfo.sLARecordId = covLocation.SVMXC__SLA_Terms__c;                      
                entitlementInfo.sLARecordName = covLocation.SVMXC__SLA_Terms__r.Name;
                entitlementInfo.startDate = localeDateFormat(covLocation.SVMXC__Start_Date__c);
                entitlementInfo.endDate = localeDateFormat(covLocation.SVMXC__End_Date__c);
            }
            //entitlementInfo.coveredBy = System.Label.COMM001_TAG099;
        }else{
            entitlementInfo.startDate = localeDateFormat(covLocation.SVMXC__Service_Contract__r.SVMXC__Start_Date__c);                        
            entitlementInfo.endDate = localeDateFormat(covLocation.SVMXC__Service_Contract__r.SVMXC__End_Date__c);
            //entitlementInfo.sLARecordId = covLocation.SVMXC__Service_Contract__r.SVMXC__SLA_Terms__c;                      
            //entitlementInfo.sLARecordName = covLocation.SVMXC__Service_Contract__r.SVMXC__SLA_Terms__r.Name;             
            if(covLocation.SVMXC__SLA_Terms__c != null && String.valueOf(covLocation.SVMXC__SLA_Terms__c).length() > 0){
                entitlementInfo.sLARecordId = covLocation.SVMXC__SLA_Terms__c;                      
                entitlementInfo.sLARecordName = covLocation.SVMXC__SLA_Terms__r.Name;        
            }
            //entitlementInfo.coveredBy = System.Label.COMM001_TAG099;
        }
        return entitlementInfo;
    }



    List<SVMXC__Installed_Product__c> getIds(Id currentId,Map<Id,List<SVMXC__Installed_Product__c>> childIBMap,Integer n){
        List<SVMXC__Installed_Product__c> iBRecords = childIBMap.get(currentId);
        n-=1;
        System.debug(logginglevel.info, 'iBRecords : ' + iBRecords  + ' n : ' + n);
        if(n > 0){
            List<SVMXC__Installed_Product__c> itrList = new List<SVMXC__Installed_Product__c>();
            itrList.addAll(iBRecords);
            for(SVMXC__Installed_Product__c iBVar : itrList){ 
                if(childIBMap.containsKey(iBVar.Id))
                    iBRecords.addAll(getIds(iBVar.Id,childIBMap,n));
            }
        }
        System.debug(logginglevel.info, 'Return iBRecords : ' + iBRecords);
        return iBRecords;
    }    

    Map<Id,SVMXC__Installed_Product__c> getListOfQualifiedIBs (Set<Id> installedBaseIds) {
        Map<Id,SVMXC__Installed_Product__c> mapOfIBs = new Map<Id,SVMXC__Installed_Product__c> ([Select SVMXC__Zip__c, SVMXC__Top_Level__c, SVMXC__Street__c, SVMXC__Status__c, SVMXC__State__c, SVMXC__Site__c, SVMXC__Serial_Lot_Number__c, SVMXC__Sales_Order_Number__c, 
                                                                        SVMXC__Product__r.SVMXC__Stockable__c, SVMXC__Product__r.SVMXC__Select__c, SVMXC__Product__r.SVMXC__Product_Cost__c, SVMXC__Product__r.SVMXC__Enable_Serialized_Tracking__c, 
                                                                        SVMXC__Product__r.SVMXC__Unit_Of_Measure__c, SVMXC__Product__r.SVMXC__Tracking__c, SVMXC__Product__r.SVMXC__Product_Line__c, SVMXC__Product__r.SVMXC__Inherit_Parent_Warranty__c, 
                                                                        SVMXC__Product__r.IsDeleted, SVMXC__Product__r.Family, SVMXC__Product__r.SystemModstamp, SVMXC__Product__r.LastModifiedById, SVMXC__Product__r.LastModifiedDate, SVMXC__Product__r.CreatedById, 
                                                                        SVMXC__Product__r.CreatedDate, SVMXC__Product__r.IsActive, SVMXC__Product__r.Description, SVMXC__Product__r.ProductCode, SVMXC__Product__r.Name, SVMXC__Product__r.Id, SVMXC__Product__c, 
                                                                        SVMXC__Product_Name__c, SVMXC__Preferred_Technician__c, SVMXC__Parent__c, SVMXC__Longitude__c, SVMXC__Latitude__c, SVMXC__Last_Date_Shipped__c, SVMXC__Installation_Notes__c, SVMXC__Distributor_Contact__c, 
                                                                        SVMXC__Distributor_Company__c, SVMXC__Date_Shipped__c, SVMXC__Date_Ordered__c, SVMXC__Date_Installed__c, SVMXC__Country__c, SVMXC__Contact__c, SVMXC__Company__c, SVMXC__City__c, 
                                                                        SVMXC__Access_Hours__c, Name, Id, CreatedDate, CreatedById,
                                                                        SVMXC__Parent__r.SVMXC__Product__c,SVMXC__Parent__r.SVMXC__Product__r.Family,SVMXC__Parent__r.SVMXC__Product__r.SVMXC__Product_Line__c,
                                                                        SVMXC__Top_Level__r.SVMXC__Product__c,SVMXC__Top_Level__r.SVMXC__Product__r.Family,SVMXC__Top_Level__r.SVMXC__Product__r.SVMXC__Product_Line__c
                                                                        From SVMXC__Installed_Product__c  where Id IN : installedBaseIds ]);

        return mapOfIBs; 
    }

    /* Do not delete
    Map<Id,Set<Id>> getChildIBs(Set<Id> installedBaseIds, Integer n, Map<Id,Set<Id>> tempIBMap)
    {   
        if(n>0)
        {
            Set<Id> tempIBs = new Set<Id> ();
            for(SVMXC__Installed_Product__c installedProd : [SELECT Id,SVMXC__Parent__c,SVMXC__Product__c FROM SVMXC__Installed_Product__c WHERE SVMXC__Parent__c IN : installedBaseIds]){
                tempIBs.add(installedProd.Id);
                Set<Id> tempSet = new Set<Id>();
                if(tempIBMap.containskey(installedProd.SVMXC__Parent__c))
                    tempSet = tempIBMap.get(installedProd.SVMXC__Parent__c);
                tempSet.add(installedProd.Id);  
                tempIBMap.put(installedProd.SVMXC__Parent__c,tempSet);
            }   
            n -= 1;
            tempIBMap = getChildIBs (tempIBs, n,tempIBMap);
        }
        return tempIBMap;
    }*/   

    Map<Id,List<SVMXC__Installed_Product__c>> getChildIBs(Set<Id> installedBaseIds, Integer n, Map<Id,List<SVMXC__Installed_Product__c>> tempIBMap)
    {   
        if(n>0)
        {
            Set<Id> tempIBs = new Set<Id> ();
            for(SVMXC__Installed_Product__c installedProd : [SELECT Id, SVMXC__Top_Level__c, SVMXC__Parent__c, SVMXC__Product__c,SVMXC__Product__r.Family,SVMXC__Product__r.SVMXC__Product_Line__c 
                                                               FROM SVMXC__Installed_Product__c WHERE SVMXC__Parent__c IN : installedBaseIds]){
                tempIBs.add(installedProd.Id);
                List<SVMXC__Installed_Product__c> tempList = new List<SVMXC__Installed_Product__c>();
                boolean alreadyAdded = false; //To avoid duplicates in the list, if the PS lines have both parent and child IBs
                if(tempIBMap.containskey(installedProd.SVMXC__Parent__c)){
                    tempList = tempIBMap.get(installedProd.SVMXC__Parent__c);
                    for(SVMXC__Installed_Product__c childIBRec : tempList){
                        if(childIBRec.Id == installedProd.Id){
                            alreadyAdded = true;
                            break;
                        }
                    }
                }
                if(!alreadyAdded)
                    tempList.add(installedProd);  
                tempIBMap.put(installedProd.SVMXC__Parent__c,tempList);
            }   
            n -= 1;
            tempIBMap = getChildIBs (tempIBs, n,tempIBMap);
        }
        return tempIBMap;
    }   

    EVER_WrapperDef.EVER_EntitlementInfo setEntitlementInfoScon(SVMXC__Service_Contract__c sCon,EVER_WrapperDef.EVER_EntitlementInfo entitlementInfo){
        if(entitlementInfo == null){
            entitlementInfo = new EVER_WrapperDef.EVER_EntitlementInfo();
            entitlementInfo.warrantyOrScon = 'scontract';
            entitlementInfo.recordId = sCon.Id;
            entitlementInfo.recordName = sCon.Name;
            //entitlementInfo.coveredBy = ;
            entitlementInfo.startDate = localeDateFormat(sCon.SVMXC__Start_Date__c);
            entitlementInfo.endDate = localeDateFormat(sCon.SVMXC__End_Date__c);
            entitlementInfo.sLARecordId = sCon.SVMXC__Service_Level__c;
            entitlementInfo.sLARecordName = sCon.SVMXC__Service_Level__r.Name;
        }
        return entitlementInfo; 
    }

    String localeDateFormat(Date dateValue){
        return (dateValue != null) ? dateValue.format() : null;
    }

    EVER_WrapperDef.EVER_EntitlementInfo setEntitlementInfoWarranty(SVMXC__Warranty__c warrantyRec){
        EVER_WrapperDef.EVER_EntitlementInfo entitlementInfo = new EVER_WrapperDef.EVER_EntitlementInfo();
        entitlementInfo.warrantyOrScon = 'warranty';
        entitlementInfo.recordId = warrantyRec.Id;
        entitlementInfo.recordName = warrantyRec.Name;
        entitlementInfo.installedBaseName = warrantyRec.SVMXC__Installed_Product__r.Name;
        //entitlementInfo.coveredBy = ;
        entitlementInfo.startDate = localeDateFormat(warrantyRec.SVMXC__Start_Date__c);
        entitlementInfo.endDate = localeDateFormat(warrantyRec.SVMXC__End_Date__c);
        entitlementInfo.warrantyTermId = warrantyRec.SVMXC__Service_Template__c;
        entitlementInfo.warrantyTermName = warrantyRec.SVMXC__Service_Template__r.Name;
        entitlementInfo.uniqueId = entitlementInfo.recordID + ((entitlementInfo.coveredBy != null) ? entitlementInfo.coveredBy : '');
        return entitlementInfo; 
    }   


    EVER_WrapperDef.EVER_HeaderRecord setheaderRecord(SVMXC__Service_Order__c workOrderRec){
        //List<EVER_WrapperDef.EVER_DetailRecord> listDetailRecords;

        EVER_WrapperDef.EVER_HeaderRecord headerRecord = new EVER_WrapperDef.EVER_HeaderRecord();   
        headerRecord.recordID = workOrderRec.Id;
        headerRecord.recordName = workOrderRec.Name;
        headerRecord.accountName = workOrderRec.SVMXC__Company__r.Name;
        headerRecord.installedBaseName = workOrderRec.SVMXC__Component__r.Name;
        headerRecord.installedBaseId = workOrderRec.SVMXC__Component__c;
        headerRecord.contactName = workOrderRec.SVMXC__Contact__r.Name;
        headerRecord.productName = workOrderRec.SVMXC__Component__r.SVMXC__Product_Name__c;
        headerRecord.entitlementPerformed = workOrderRec.SVMXC__Is_Entitlement_Performed__c;
        headerRecord.selectedEntitlementInfo = setSelectedHeaderEntitlementInfo(workOrderRec);
        return headerRecord;
    } 

    EVER_WrapperDef.EVER_EntitlementInfo setSelectedHeaderEntitlementInfo(SVMXC__Service_Order__c workOrderRec){
        EVER_WrapperDef.EVER_EntitlementInfo entitlementInfo; 
        Id selectedCoveredService; 
        if(workOrderRec.SVMXC__Is_Entitlement_Performed__c){
            entitlementInfo = new EVER_WrapperDef.EVER_EntitlementInfo();
            entitlementInfo.entitlementNotes = workOrderRec.SVMXC__Entitlement_Notes__c;
            entitlementInfo.warrantyOrScon = 'notcovered';
            if(workOrderRec.SVMXC__Warranty__c != null || workOrderRec.SVMXC__Service_Contract__c != null){
                if(entitlementHistoryMap != null && entitlementHistoryMap.containsKey(workOrderRec.Id)){
                   SVMXC__Entitlement_History__c historyRec = entitlementHistoryMap.get(workOrderRec.Id);
                   entitlementInfo.startDate = localeDateFormat(historyRec.SVMXC__Start_Date__c);
                   entitlementInfo.endDate = localeDateFormat(historyRec.SVMXC__End_Date__c);
                   entitlementInfo.coveredBy = historyRec.SVMXC__Covered_By__c;
                   selectedCoveredService = historyRec.SVMXC__Entitled_By_Service__c;
                }            
                if(workOrderRec.SVMXC__Warranty__c != null){
                    entitlementInfo.warrantyOrScon = 'warranty';
                    entitlementInfo.recordId = workOrderRec.SVMXC__Warranty__c;
                    entitlementInfo.recordName = workOrderRec.SVMXC__Warranty__r.Name;
                    entitlementInfo.entitlementNotes = workOrderRec.SVMXC__Entitlement_Notes__c;
                    entitlementInfo.warrantyTermId = workOrderRec.SVMXC__Warranty__r.SVMXC__Service_Template__c;
                    entitlementInfo.warrantyTermName = workOrderRec.SVMXC__Warranty__r.SVMXC__Service_Template__r.Name;
                    entitlementInfo.installedBaseName = workOrderRec.SVMXC__Warranty__r.SVMXC__Installed_Product__r.Name;
                }else if(workOrderRec.SVMXC__Service_Contract__c != null){
                    entitlementInfo.warrantyOrScon = 'scontract';
                    entitlementInfo.recordId = workOrderRec.SVMXC__Service_Contract__c;
                    entitlementInfo.recordName = workOrderRec.SVMXC__Service_Contract__r.Name;
                    entitlementInfo.sLARecordId = workOrderRec.SVMXC__SLA_Terms__c;
                    entitlementInfo.sLARecordName = workOrderRec.SVMXC__SLA_Terms__r.Name;
                    if(serviceBasedEntitlement){
                        Set<Id> tempSet = new Set<Id>{workOrderRec.SVMXC__Service_Contract__c};
                        Map<Id,List<AvailableServices>> sortedCoveredServicesMap = getCoveredServices(tempSet,workOrderRec.Id); 
                        
                        if(!sortedCoveredServicesMap.isEmpty() && sortedCoveredServicesMap.containsKey(workOrderRec.SVMXC__Service_Contract__c)){
                            List<EVER_WrapperDef.Ever_CoveredService> coveredServiceList = new List<EVER_WrapperDef.Ever_CoveredService>();
                            for(AvailableServices availServices : sortedCoveredServicesMap.get(entitlementInfo.recordID)){
                                if(selectedCoveredService != null && availServices.covServiceWrapRec.recordID == selectedCoveredService)
                                    availServices.covServiceWrapRec.selected = true;
                                coveredServiceList.add(availServices.covServiceWrapRec);
                            }
                            entitlementInfo.coveredService = coveredServiceList;
                        }
                    }
                }   
                entitlementInfo.uniqueId = entitlementInfo.recordId + ((entitlementInfo.coveredBy != null) ? entitlementInfo.coveredBy : '');
            }
        }
        return entitlementInfo;
    }


    EVER_WrapperDef.EVER_DetailRecord setDetailLineRecord(SVMXC__Service_Order_Line__c workOrderLine){
        EVER_WrapperDef.EVER_DetailRecord detailRecord = new EVER_WrapperDef.EVER_DetailRecord();
        detailRecord.recordID = workOrderLine.Id;
        detailRecord.recordName = workOrderLine.Name;
        detailRecord.installedBaseName = workOrderLine.SVMXC__Serial_Number__r.Name;
        detailRecord.installedBaseId = workOrderLine.SVMXC__Serial_Number__c;
        detailRecord.productName = workOrderLine.SVMXC__Serial_Number__r.SVMXC__Product_Name__c ;
        detailRecord.entitlementPerformed = workOrderLine.SVMXC__Is_Entitlement_Performed__c;
        detailRecord.selectedEntitlementInfo = setSelectedDetailEntitlementInfo(workOrderLine);
        detailRecord.description = workOrderLine.SVMXC__Work_Description__c;
//      workOrderLine.SVMXC__Product__c;
        //detailRecord.listEntitlementInfo = enitlementInfo;
        return detailRecord;
    }

    EVER_WrapperDef.EVER_EntitlementInfo setSelectedDetailEntitlementInfo(SVMXC__Service_Order_Line__c workOrderLine){
        EVER_WrapperDef.EVER_EntitlementInfo entitlementInfo; 
        if(workOrderLine.SVMXC__Is_Entitlement_Performed__c){
            entitlementInfo = new EVER_WrapperDef.EVER_EntitlementInfo();
            entitlementInfo.entitlementNotes = workOrderLine.SVMXC__Entitlement_Notes__c;
            entitlementInfo.warrantyOrScon = 'notcovered';        
            if(workOrderLine.SVMXC__Product_Warranty__c != null || workOrderLine.SVMXC__Service_Maintenance_Contract__c != null){
                if(entitlementHistoryMap != null && entitlementHistoryMap.containsKey(workOrderLine.Id)){
                   SVMXC__Entitlement_History__c historyRec = entitlementHistoryMap.get(workOrderLine.Id);
                   entitlementInfo.startDate = localeDateFormat(historyRec.SVMXC__Start_Date__c);
                   entitlementInfo.endDate = localeDateFormat(historyRec.SVMXC__End_Date__c);
                   entitlementInfo.coveredBy = historyRec.SVMXC__Covered_By__c;
                }            
                if(workOrderLine.SVMXC__Product_Warranty__c != null){
                    entitlementInfo.warrantyOrScon = 'warranty';
                    entitlementInfo.recordId = workOrderLine.SVMXC__Product_Warranty__c;
                    entitlementInfo.recordName = workOrderLine.SVMXC__Product_Warranty__r.Name;
                    entitlementInfo.warrantyTermId = workOrderLine.SVMXC__Product_Warranty__r.SVMXC__Service_Template__c;
                    entitlementInfo.warrantyTermName = workOrderLine.SVMXC__Product_Warranty__r.SVMXC__Service_Template__r.Name;
                    entitlementInfo.installedBaseName = workOrderLine.SVMXC__Product_Warranty__r.SVMXC__Installed_Product__r.Name;
                }else if(workOrderLine.SVMXC__Service_Maintenance_Contract__c != null){
                    entitlementInfo.warrantyOrScon = 'scontract';
                    entitlementInfo.recordId = workOrderLine.SVMXC__Service_Maintenance_Contract__c;
                    entitlementInfo.recordName = workOrderLine.SVMXC__Service_Maintenance_Contract__r.Name;
                   // entitlementInfo.sLARecordId = workOrderLine.SVMXC__SLA_Terms__c;
                   // entitlementInfo.sLARecordName = workOrderLine.SVMXC__SLA_Terms__r.Name;
                }   
                entitlementInfo.uniqueId = entitlementInfo.recordId + ((entitlementInfo.coveredBy != null) ? entitlementInfo.coveredBy : '');
            }
        }
        return entitlementInfo;
    }
    
    public class AvailableServices implements Comparable{
        public EVER_WrapperDef.Ever_CoveredService covServiceWrapRec;
        public Decimal availableUnits;
        
        public availableServices(Id covId,Decimal alUnits,Decimal consUnits,String serName){
            covServiceWrapRec = new EVER_WrapperDef.Ever_CoveredService();
            covServiceWrapRec.recordID = covId;
            covServiceWrapRec.serviceName = serName;
            covServiceWrapRec.selected = false;
            alUnits = (alUnits != null) ? alUnits : 0;   // alUnits : 100000;
            consUnits = (consUnits != null) ? consUnits : 0;
            availableUnits = alUnits - consUnits ;
            covServiceWrapRec.allowedUnits = String.valueof(alUnits);
            covServiceWrapRec.consumedUnits = String.valueof(consUnits);
            covServiceWrapRec.availableUnits = String.valueof(availableUnits);
        }      

        public Integer compareTo(Object compareTo){
            availableServices compareToServices = (availableServices)compareTo;
            if(availableUnits == compareToServices.availableUnits) return 0;
            if(availableUnits > compareToServices.availableUnits) return -1;
            return 1;
        }
    }

    public Map<Id,List<AvailableServices>> getCoveredServices(Set<Id> serviceContractIds, Id recId){
        
        Map<Id,List<AvailableServices>> sortedCoveredServicesMap = new Map<Id,List<AvailableServices>>();     
        List<AvailableServices> availableServicesWrapperList = new List<AvailableServices>();
        Set<Id> expressionIds = new Set<Id>();
        Map<Id,SVMXC__Service_Contract_Services__c> coveredServicesMap = new Map<Id,SVMXC__Service_Contract_Services__c>([SELECT Id,SVMXC__Service__c, SVMXC__Service__r.Name, SVMXC__Is_Billable__c, SVMXC__Included_Units__c, SVMXC__Consumed_Units__c ,SVMXC__Service__r.SVMXC__Qualifying_Criteria__c, SVMXC__Service_Contract__c, 
                       SVMXC__Service__r.SVMXC__Tracked_On__c FROM SVMXC__Service_Contract_Services__c WHERE SVMXC__Service_Contract__c IN: serviceContractIds AND SVMXC__Service__c != null  AND SVMXC__Service__r.SVMXC__Tracked_On__c = 'Work Order']);
        
        for(SVMXC__Service_Contract_Services__c covServiceRec : coveredServicesMap.values()){
            if(covServiceRec.SVMXC__Service__r.SVMXC__Qualifying_Criteria__c != null){
                expressionIds.add(covServiceRec.SVMXC__Service__r.SVMXC__Qualifying_Criteria__c);
            }
            availableServicesWrapperList.add(new availableServices(covServiceRec.Id,covServiceRec.SVMXC__Included_Units__c,covServiceRec.SVMXC__Consumed_Units__c,covServiceRec.SVMXC__Service__r.Name));
        }    

        String expressionFields = '';
        Set<String> expressionFieldsSet = new Set<String>(); //To filter out duplicate fields
        Map<Id,List<SVMXC__ServiceMax_Config_Data__c>> expressionConfigMap = new Map<Id,List<SVMXC__ServiceMax_Config_Data__c>>();
        if(!expressionIds.isEmpty()){
            for(SVMXC__ServiceMax_Config_Data__c exprRec : [SELECT SVMXC__Target_Field_Name__c, SVMXC__Source_Field_Name__c, SVMXC__Sequence__c, SVMXC__Operator__c, SVMXC__Operand__c, SVMXC__Object_Name__c, 
                              SVMXC__Object_Name2__c, SVMXC__IsDefault__c, SVMXC__Internal_Value__c, SVMXC__Field_Relationship_Name__c, SVMXC__Field_Name__c, SVMXC__FKey_Name_Field__c, 
                              SVMXC__Expression_Type__c, SVMXC__Expression_Rule__c,SVMXC__Expression_Rule__r.SVMXC__Advance_Expression__c, SVMXC__Display_Value__c, SVMXC__Display_Type__c, RecordTypeId, Name FROM SVMXC__ServiceMax_Config_Data__c  
                              WHERE SVMXC__Expression_Rule__c IN: expressionIds AND RecordType.Name = 'Expressions' AND SVMXC__Expression_Type__c = 'EXP_Named']){
                List<SVMXC__ServiceMax_Config_Data__c> tempList = new List<SVMXC__ServiceMax_Config_Data__c>();
                String tempStr = (exprRec.SVMXC__Field_Name__c != null) ? exprRec.SVMXC__Field_Name__c.trim() : '';
                if(tempStr != '' && !expressionFieldsSet.contains(tempStr)){
                    expressionFieldsSet.add(tempStr);
                    expressionFields += tempStr + ', ';
                }

                if( exprRec.SVMXC__Display_Type__c != null && exprRec.SVMXC__Display_Type__c.equalsIgnoreCase('REFERENCE') ) {
                    if( exprRec.SVMXC__Field_Relationship_Name__c != null && exprRec.SVMXC__FKey_Name_Field__c != null ) {                    
                        tempStr = exprRec.SVMXC__Field_Relationship_Name__c + '.' + exprRec.SVMXC__FKey_Name_Field__c;
                        if(!expressionFieldsSet.contains(tempStr)){
                            expressionFieldsSet.add(tempStr);
                            expressionFields += tempStr + ', ';
                        }
                    }
                }                 
                
                if(expressionConfigMap.containsKey(exprRec.SVMXC__Expression_Rule__c)){
                    tempList = expressionConfigMap.get(exprRec.SVMXC__Expression_Rule__c);
                }
                tempList.add(exprRec);
                expressionConfigMap.put(exprRec.SVMXC__Expression_Rule__c,tempList);
            }
        }

        availableServicesWrapperList.sort();
        String queryStr = ' SELECT ' + expressionFields + ' Id FROM SVMXC__Service_Order__c WHERE Id = \'' + recId + '\'';
        sObject sobjWORec = Database.query(queryStr);
        
        for(availableServices availServicesRec : availableServicesWrapperList){
            
            SVMXC__Service_Contract_Services__c covSerRec = coveredServicesMap.get(availServicesRec.covServiceWrapRec.recordID);
            Boolean isRuleApplicable = false;
            List<AvailableServices> tempList = new List<AvailableServices>();

            Integer unlimited_Value_Equals = 0; //Default unlimited value
            
            if(AllSubModuleSettings.containsKey('SET029') && AllSubModuleSettings.get('SET029') != null && AllSubModuleSettings.get('SET029') != ''){
                unlimited_Value_Equals = Integer.valueof(AllSubModuleSettings.get('SET029'));
            }

            Decimal availUnits = Decimal.valueof(availServicesRec.covServiceWrapRec.availableUnits);
            availServicesRec.covServiceWrapRec.availableUnits = (availUnits < 0)?'0': availServicesRec.covServiceWrapRec.availableUnits;
            

            if(covSerRec.SVMXC__Included_Units__c == unlimited_Value_Equals || covSerRec.SVMXC__Included_Units__c == null){ 
             // availServicesRec.covServiceWrapRec.allowedUnits = unlimited_Value_Equals; 
               availServicesRec.covServiceWrapRec.availableUnits = System.Label.COMM001_TAG125;
            }
            
            if(sortedCoveredServicesMap.containsKey(covSerRec.SVMXC__Service_Contract__c))
               tempList = sortedCoveredServicesMap.get(covSerRec.SVMXC__Service_Contract__c);
            
            if(covSerRec.SVMXC__Service__r.SVMXC__Qualifying_Criteria__c != null && expressionConfigMap.containsKey(covSerRec.SVMXC__Service__r.SVMXC__Qualifying_Criteria__c)){
                List<SVMXC__ServiceMax_Config_Data__c> configRecList = expressionConfigMap.get(covSerRec.SVMXC__Service__r.SVMXC__Qualifying_Criteria__c);
                isRuleApplicable = new COMM_Utils.COMM_ExpressionParsing().SVMX_ExpressionParsing(sobjWORec, configRecList,configRecList[0].SVMXC__Expression_Rule__r.SVMXC__Advance_Expression__c);
                availServicesRec.covServiceWrapRec.tracked = System.Label.COMM001_TAG119;
                if(isRuleApplicable){
                    availServicesRec.covServiceWrapRec.isQualified = true;
                    tempList.add(availServicesRec);
                }else{
                    if(showAllServices != null && !showAllServices){
                       availServicesRec.covServiceWrapRec.isQualified = false; 
                       tempList.add(availServicesRec);
                    }
                }
                sortedCoveredServicesMap.put(covSerRec.SVMXC__Service_Contract__c,tempList);
            }else{
                availServicesRec.covServiceWrapRec.tracked = System.Label.COMM001_TAG119;
                availServicesRec.covServiceWrapRec.isQualified = true;
                tempList.add(availServicesRec);
                sortedCoveredServicesMap.put(covSerRec.SVMXC__Service_Contract__c,tempList);
            }
            
        }
        return sortedCoveredServicesMap;
    }

    Map<Id,sObject> updateIncludedServiceCount(Set<Id> entityIds, Map<Id,sObject> entityMap){
        String queryStr = 'SELECT Id, SVMXC__Entitled_By_Service__c,SVMXC__Entitled_By_Service__r.SVMXC__Consumed_Units__c FROM SVMXC__Entitlement_History__c WHERE SVMXC__Inactive_Date__c = NULL ' + 
                          'AND SVMXC__Entitled_By_Service__c != null AND SVMXC__Service_Order__c IN : entityIds';

        List<SVMXC__Entitlement_History__c> entitlementHistory = Database.Query(queryStr);
        
        for(SVMXC__Entitlement_History__c historyRec : entitlementHistory){
            SVMXC__Service_Contract_Services__c includedServiceRec = (SVMXC__Service_Contract_Services__c)historyRec.getsObject('SVMXC__Entitled_By_Service__r');
            System.debug(LoggingLevel.INFO, 'Included Service Record : ' + includedServiceRec);

            if(entityMap.containsKey(includedServiceRec.Id)){
                includedServiceRec = (SVMXC__Service_Contract_Services__c)entityMap.get(includedServiceRec.Id);
                if(includedServiceRec.SVMXC__Consumed_Units__c > 0)
                   includedServiceRec.SVMXC__Consumed_Units__c -= 1; 
            }else{
                Decimal consumedUnits = includedServiceRec.SVMXC__Consumed_Units__c;
                if(consumedUnits != null && consumedUnits > 0){
                    consumedUnits -= 1;  
                    includedServiceRec.SVMXC__Consumed_Units__c = consumedUnits; 
                    entityMap.put(includedServiceRec.Id,includedServiceRec);
                }              
            }

        }
        return entityMap;
    }

    /**
     * To get all the Entitlement History records related to Work order or PSLines 
     * BAC - 12 - Anush 5th May 2016
     */
   
     public EVER_WrapperDef.EVER_Response getEntitlementHistory(EVER_WrapperDef.EVER_Request request) {
        EVER_WrapperDef.EVER_Response response = new EVER_WrapperDef.EVER_Response();
        EVER_WrapperDef.EVER_HeaderRecord headerRecord = new EVER_WrapperDef.EVER_HeaderRecord();
        List<EVER_WrapperDef.EVER_EntitlementHistory> entitlementHistoryList = new List<EVER_WrapperDef.EVER_EntitlementHistory>();
        Map<String,List<EVER_WrapperDef.EVER_EntitlementHistory>> entitlementHistoryMap = new Map<String,List<EVER_WrapperDef.EVER_EntitlementHistory>>();
        //if(!entitlementSupportOnLines) {
        
        String headerID = request.headerId;
        for(SVMXC__Entitlement_History__c historyRec : [Select Id, Name, SVMXC__Covered_By__c, SVMXC__Date_of_entitlement__c, 
                                                                 SVMXC__Days_To_Warranty_Expiry__c, SVMXC__End_Date__c, 
                                                                 SVMXC__Entitled_By_Contact__r.Name, SVMXC__Entitled_By_IB__r.Name,
                                                                 SVMXC__Entitled_By_Service__r.Name, SVMXC__Entitled_By_Site__r.Name,
                                                                 SVMXC__Entitled_Within_Threshold__c, SVMXC__Exchange_Type__c, 
                                                                 SVMXC__Inactive_Date__c, SVMXC__Warranty__c, SVMXC__Warranty__r.Name, 
                                                                 SVMXC__Service_Contract__c, SVMXC__Service_Contract__r.Name, 
                                                                 SVMXC__SLA_Terms__c, SVMXC__SLA_Terms__r.Name,
                                                                 SVMXC__Start_Date__c
                                                          From SVMXC__Entitlement_History__c
                                                          Where SVMXC__Service_Order__c =: headerID OR SVMXC__Work_Detail__c =: headerID
                                                          Order By Name DESC]) {

            EVER_WrapperDef.EVER_EntitlementHistory entitlementHistory = populateEntitlementHistory(historyRec);
            entitlementHistoryList.add(entitlementHistory);
        }
        entitlementHistoryMap.put(request.headerID, entitlementHistoryList);
        headerRecord.entitlementHistoryMap = entitlementHistoryMap;
        headerRecord.recordID = request.headerID;
        response.headerRecord = headerRecord;
        
        return response;
    }
    
    private EVER_WrapperDef.EVER_EntitlementHistory populateEntitlementHistory(SVMXC__Entitlement_History__c historyRec) {
        EVER_WrapperDef.EVER_EntitlementHistory entitlementHistory = new EVER_WrapperDef.EVER_EntitlementHistory();
        entitlementHistory.recordId = historyRec.Id;
        entitlementHistory.recordName = historyRec.Name;
        entitlementHistory.coveredBy = historyRec.SVMXC__Covered_By__c;
        entitlementHistory.startDate = localeDateFormat(historyRec.SVMXC__Start_Date__c);
        entitlementHistory.endDate = localeDateFormat(historyRec.SVMXC__End_Date__c);
        entitlementHistory.dateOfEntitlement = localeDateFormat(historyRec.SVMXC__Date_of_entitlement__c);
        entitlementHistory.daysToWarrantyExpiry = String.valueof(historyRec.SVMXC__Days_To_Warranty_Expiry__c);
        entitlementHistory.entitledWithinThreshold = historyRec.SVMXC__Entitled_Within_Threshold__c;
        entitlementHistory.exchangeType = historyRec.SVMXC__Exchange_Type__c;
        entitlementHistory.inactiveDate = String.valueOf(historyRec.SVMXC__Inactive_Date__c);
        /*entitlementHistory.productWarrantID = historyRec.SVMXC__Warranty__c;
        entitlementHistory.productWarrantyName = historyRec.SVMXC__Warranty__r.Name;
        entitlementHistory.serviceContractID = historyRec.SVMXC__Service_Contract__c;
        entitlementHistory.serviceContractName = historyRec.SVMXC__Service_Contract__r.Name;*/
        if(historyRec.SVMXC__Warranty__c != null) {
            entitlementHistory.warrantyOrSconName = historyRec.SVMXC__Warranty__r.Name;
            entitlementHistory.warrantyOrSconId = historyRec.SVMXC__Warranty__c;
        }else if(historyRec.SVMXC__Service_Contract__c != null) {
            entitlementHistory.warrantyOrSconName = historyRec.SVMXC__Service_Contract__r.Name;
            entitlementHistory.warrantyOrSconId = historyRec.SVMXC__Service_Contract__c;
        }
        entitlementHistory.slaTermID = historyRec.SVMXC__SLA_Terms__c;
        entitlementHistory.slaTermName = historyRec.SVMXC__SLA_Terms__r.Name;
        entitlementHistory.entitledByContact = historyRec.SVMXC__Entitled_By_Contact__r.Name;
        entitlementHistory.entitledByIB = historyRec.SVMXC__Entitled_By_IB__r.Name;
        entitlementHistory.entitledByService = historyRec.SVMXC__Entitled_By_Service__r.Name;
        entitlementHistory.entitledBySite = historyRec.SVMXC__Entitled_By_Site__r.Name;
        return entitlementHistory;
    }  
    
}