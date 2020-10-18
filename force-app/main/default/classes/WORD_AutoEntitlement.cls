/* Security Scanned */
public with sharing class WORD_AutoEntitlement
{
    public Boolean  isdiabledEntitlementOnWo;//added by NIDHI as part of BAC-4638
    public static Map<Id, Boolean> mapWOIdCheckEntitlement = new Map<Id, Boolean>();
    public static Map<Integer, Boolean> mapWOIndexCheckEntitlement = new Map<Integer, Boolean>();
    public map<Integer, SVMXC__Service_Order__c> mapWO = new map<Integer, SVMXC__Service_Order__c>();
    public map<Id, Id> mapCounterDefIB = new map<Id, Id>();
   // public map<Id, Integer> mapIBWOIndex = new map<Id, Integer>();
    public map<Id, SVMXC__Installed_Product__c> mapComponent = new map<Id, SVMXC__Installed_Product__c>();
    public map<Id, SVMXC__Installed_Product__c> mapComponentParentANDTopLevel = new map<Id, SVMXC__Installed_Product__c>();
    public static map<Id, SVMXC__ServiceMax_Processes__c> mapSVMXProcess = new map<Id, SVMXC__ServiceMax_Processes__c>();
    public map<Id, SVMXC__ServiceMax_Processes__c> mapEntRules = new map<Id, SVMXC__ServiceMax_Processes__c>();
    public map<Id, SVMXC__ServiceMax_Processes__c> mapCountersRules = new map<Id, SVMXC__ServiceMax_Processes__c>();
    public map<Id, list<SVMXC__Counter_Details__c>> mapCountersRulesDefinitions = new map<Id, list<SVMXC__Counter_Details__c>>();
    public static map<Id, SVMXC__ServiceMax_Config_Data__c> mapExpression = new map<Id, SVMXC__ServiceMax_Config_Data__c>();
    public map<Id, list<SVMXC__ServiceMax_Config_Data__c>> mapEntRuleExpression = new map<Id, list<SVMXC__ServiceMax_Config_Data__c>>();
    public map<Id, list<SVMXC__ServiceMax_Config_Data__c>> mapCountersRuleExpression = new map<Id, list<SVMXC__ServiceMax_Config_Data__c>>();
    public map<Id, list<Id>> mapIBWOList = new map<Id, list<Id>>();  
    public map<Integer, string> mapWOEntRule = new map<Integer, string>();
    public map<Id, string> mapProductCounterRule = new map<Id, string>();
    public set<Id> setComponent = new set<Id>();
    public map<Integer, Id> mapWOContact = new map<Integer, Id>();
    public map<Integer, Id> mapWOAccount = new map<Integer, Id>();
    //public map<Integer, Id> mapWOLocation = new map<Integer, Id>();
    public map<Id, Id> mapParentIB = new map<Id, Id>();
    public map<Id, Id> mapTopLevelIB = new map<Id, Id>();
    
    public set<Id> setParentProductId = new set<Id>();
    public set<Id> setTopLevelProductId = new set<Id>();
    
    public map<Id, Id> mapProductId = new map<Id, Id>();
    public set<Id> setCounterDefinitionId = new set<Id>();
    public map<Id, SVMXC__Warranty__c> mapProductWarranty = new map<Id, SVMXC__Warranty__c>();
    public map<Id, SVMXC__Service_Contract_Products__c> mapServiceContractCoverageIB = new map<Id, SVMXC__Service_Contract_Products__c>();
    public map<Id, List<SVMXC__Service_Contract_Products__c>> mapServiceContractCoverageProduct = new map<Id, List<SVMXC__Service_Contract_Products__c>>();
    public map<Id, map<Id, SVMXC__Counter_Details__c>> mapCounterCoverageIB = new map<Id, map<Id, SVMXC__Counter_Details__c>>();
    public map<Id, map<Id, SVMXC__Counter_Details__c>> mapCounterCoverageProduct = new map<Id, map<Id, SVMXC__Counter_Details__c>>();
    public map<Id, SVMXC__Counter_Details__c> mapCounterReadings = new map<Id, SVMXC__Counter_Details__c>();
    public map<Id, List<SVMXC__Counter_Details__c>> mapIBIDAndListCounterReadings = new map<Id, List<SVMXC__Counter_Details__c>>();
    public map<Id, SVMXC__Counter_Details__c> mapCounterDetails = new map<Id, SVMXC__Counter_Details__c>();
    public map<Id, SVMXC__Service_Contract_Contacts__c> mapEntitledContacts = new map<Id, SVMXC__Service_Contract_Contacts__c>();
    public map<Id, set<Id>> mapContactSC = new map<Id, set<Id>>();
    public map<Id, Product2> mapProduct = new map<Id, Product2>();
    //public map<Id, list<SVMXC__Warranty__c>> mapWOProductWarranty = new map<Id, list<SVMXC__Warranty__c>>();
    public map<Id, SVMXC__Warranty__c> mapWOProductWarranty = new map<Id, SVMXC__Warranty__c>();
    //public map<Id, list<SVMXC__Service_Contract_Products__c>> mapWOServiceContractCoverage = new map<Id, list<SVMXC__Service_Contract_Products__c>>();
    public map<Id, SVMXC__Service_Contract_Products__c> mapWOServiceContractCoverage = new map<Id, SVMXC__Service_Contract_Products__c>();
    //public map<Id, SVMXC__Service_Contract_Products__c> mapServiceContractCoverageCounter = new map<Id, SVMXC__Service_Contract_Products__c>();
    public map<Id, SVMXC__Counter_Details__c> mapCounterReading = new map<Id, SVMXC__Counter_Details__c>();
    
    public map<Id, list<SVMXC__Warranty__c>> mapIBProductWarranty = new map<Id, list<SVMXC__Warranty__c>>();
    public map<Id, list<SVMXC__Service_Contract_Products__c>> mapIBServiceContractCoverage = new map<Id, list<SVMXC__Service_Contract_Products__c>>();
    public map<Id, map<Id, SVMXC__Service_Contract__c>> mapIBServiceContractCoverageCounters = new map<Id, map<Id, SVMXC__Service_Contract__c>>();
    public map<Id, map<Id, SVMXC__Service_Template__c>> mapIBWarrantyTermsCounters = new map<Id, map<Id, SVMXC__Service_Template__c>>();    
    //public set<Id> setProductWarranty = new set<Id>();
    public SVMXC.COMM_SVMXC_Utils2.COMM_ExpressionParsing oExpressionParsing = new SVMXC.COMM_SVMXC_Utils2.COMM_ExpressionParsing();
    public Boolean IsWOEntitled = false;
    public Boolean SetBillingType = true;
    // created by sharad
    public String settingCovrPrdctNCntrct{get; set;}
    //public Map<String, String> mapSettings = new Map<String, String>();
    
    //Enhancement: Added to support Match Location in Auto Entitlement
    public static map<Integer, SVMXC__Service_Contract_Products__c> mapWOIndexContractIBCvrg = new map<Integer, SVMXC__Service_Contract_Products__c>();
    public map<Id, SVMXC__Service_Contract_Sites__c> mapEntitledLocation = new map<Id, SVMXC__Service_Contract_Sites__c>();
    public map<Id, list<SVMXC__Service_Contract__c>> mapLocationContractLst = new map<Id, list<SVMXC__Service_Contract__c>>();
    public Map<Id,List<SVMXC__Service_Contract__c>> mapAccountContractList;
    public map<Id, set<Id>> mapLocationSCON = new map<Id, set<Id>>();
    public map<Integer, Id> mapWOLocation = new map<Integer, Id>();
    public set<string> setContractIds = new set<string>();
    public string Setng_EntitleUsingFld = '';
    public Boolean IsException = false;
    public String strExecptin;
    
    //List to hold WO detail lines which will be updated with entitled Service Contracts/Warranties.
    public Static List<SVMXC__Service_Order_Line__c> productServicedLines = new List<SVMXC__Service_Order_Line__c>(); 
    public Map<Id,List<SVMXC__Service_Order_Line__c>> wODetailLineMap =  new Map<Id,List<SVMXC__Service_Order_Line__c>>(); //Map to hold Work order Id and it's associated product serviced IBs 
    public Static Map<Id,SVMXC__Service_Order_Line__c> oldWOServiceLinesMap = new Map<Id,SVMXC__Service_Order_Line__c>(); //Static Map to hold old set of Product Service records for Entitlement History creation.    
    public Map<Integer,boolean> performEntitlementOnWOMap = new Map<Integer,boolean>(); //If set to true entitlement will be performed on WO alone
    public Static Map<String,EntitlementInfoWrapper> entitlementInfoMap = new Map<String,EntitlementInfoWrapper>(); //Map of Warrant/Scon Ids and its details

    public Map <ID,List<SVMXC__Service_Contract_Sites__c> > mapServiceContractandCoveredLocations = new Map <ID, List<SVMXC__Service_Contract_Sites__c > > ();
      // variable for using web Service
      public Map<String, String> mapWOIDnSucess = new Map<String, String>();
      public boolean isWebServiceCall = false;
    
    
    public WORD_AutoEntitlement()
    {
         isdiabledEntitlementOnWo = false;
    }
    
    
    public Set<String> getFildtoWOQury()
    {
        List<SVMXC__ServiceMax_Processes__c> lstPrcss = new List<SVMXC__ServiceMax_Processes__c>();
        List<SVMXC__ServiceMax_Config_Data__c> lstExprss = new List<SVMXC__ServiceMax_Config_Data__c>();
        
        try{
            lstPrcss = new List<SVMXC__ServiceMax_Processes__c>();
            //SDL-SVMX-FLS-NOT-ENFORCED-META-DATA
            lstPrcss = [select Id from SVMXC__ServiceMax_Processes__c where RecordType.Name = 'SVMX Rule' AND (SVMXC__Rule_Type__c = 'Auto Entitlement WO' )];
            //SDL-SVMX-FLS-NOT-ENFORCED-META-DATA
            lstExprss = [select SVMXC__Field_Name__c from SVMXC__ServiceMax_Config_Data__c where RecordType.Name='Expressions' AND SVMXC__Expression_Rule__c IN :lstPrcss AND (SVMXC__Expression_Type__c = 'WO_Auto_Entitlement' )];
        }
        catch(Exception ex)
        {
            IsException = true;
            strExecptin = ex.getMessage();
        }
        Set<String> strFild = new Set<String>();
        for(SVMXC__ServiceMax_Config_Data__c configDate :lstExprss)
        {
            System.debug('getting field : '+configDate.SVMXC__Field_Name__c);
                if(configDate.SVMXC__Field_Name__c != null && configDate.SVMXC__Field_Name__c.length() > 0 )
                    strFild.add(configDate.SVMXC__Field_Name__c);
        }
        
        return strFild;
    }
    
    public INTF_WebServicesDef.INTF_Response SVMX_DoEntitlement(INTF_WebServicesDef.INTF_Request req)
    {
   
        
        mapWOIDnSucess.clear();
        isWebServiceCall = true;
        boolean isUpdateHistory = false;
        SVMXC.COMM_Utils_ManageSettings commSettings = new SVMXC.COMM_Utils_ManageSettings();
        INTF_WebServicesDef.INTF_Response objResponse = new INTF_WebServicesDef.INTF_Response();
        System.debug('Request is : '+req);
        List<String> lstIdsWO = new List<String>();

        for(String strVal: req.recordIds)
        {
            lstIdsWO.add(strVal);
        }
        system.debug('get list from perameter : '+lstIdsWO);
        
        //system.debug('get query list : '+getFildtoWOQury());
        try
        {
            if(lstIdsWO != null && lstIdsWO.size() > 0)
            {
                list<string> lstSubModules = new list<string>{'EVER007','IPRD003'};
                map<string, Map<String, String>> AllsvmxSettingList = new map<string, Map<String, String>>();
                AllsvmxSettingList = commSettings.SVMX_getSettingList(lstSubModules);
                Map<String, String> mapSettings = new Map<String, String>();
                if(AllsvmxSettingList != null && AllsvmxSettingList.containsKey('EVER007') && AllsvmxSettingList.get('EVER007') != null )
                {
                    Map<String, String> mapSetting1 = AllsvmxSettingList.get('EVER007');
                    if(mapSetting1 != null && mapSetting1.size() > 0)
                    {
                        for(string strSettingId : mapSetting1.keySet())
                        {
                            string setValue = mapSetting1.containsKey(strSettingId) ? mapSetting1.get(strSettingId) : '';
                            strSettingId = 'EVER007'+'_'+strSettingId;
                            mapSettings.put(strSettingId,setValue);
                        }
                    }
                }
                if(AllsvmxSettingList != null && AllsvmxSettingList.containsKey('IPRD003') && AllsvmxSettingList.get('IPRD003') != null )
                {
                    Map<String, String> mapSetting2 = AllsvmxSettingList.get('IPRD003');
                    if(mapSetting2 != null && mapSetting2.size() > 0)
                    {
                        for(string strSettingId : mapSetting2.keySet())
                        {
                            string setValue = mapSetting2.containsKey(strSettingId) ? mapSetting2.get(strSettingId) : '';
                            strSettingId = 'IPRD003'+'_'+strSettingId;
                            mapSettings.put(strSettingId,setValue);
                        }
                    }
                }
                
                // Entitlement by Web Service should always be performed without respecting global setting EVER007_SET001(Is Perform Auto Entitlement.)
                if(mapSettings.containsKey('EVER007_SET001') && mapSettings.get('EVER007_SET001') != null && mapSettings.get('EVER007_SET001').toUpperCase() == 'FALSE')
                {
                    isUpdateHistory = true;
                    mapSettings.put('EVER007_SET001', 'TRUE');
                }
                
                List<SVMXC__Service_Order__c> lstWOs = new List<SVMXC__Service_Order__c>();
                
                String strLoctnField = '';
                Set<String> setFields = new Set<String>();
                setFields = getFildtoWOQury();
                
                if(mapSettings.containsKey('EVER007_SET003') && mapSettings.get('EVER007_SET003') != null && (!mapSettings.get('EVER007_SET003').equalsIgnoreCase('Today') && !mapSettings.get('EVER007_SET003').equalsIgnoreCase('CreatedDate')))
                    setFields.add(mapSettings.get('EVER007_SET003'));

                
                
                if(strLoctnField != null && strLoctnField.length() > 0)
                    setFields.add(strLoctnField);
                    
                setFields.add('Id');
                setFields.add('SVMXC__Entitlement_Notes__c');
                setFields.add('SVMXC__Auto_Entitlement_Status__c');
                setFields.add('SVMXC__Perform_Auto_Entitlement__c');
                setFields.add('SVMXC__SLA_Terms__c');
                setFields.add('SVMXC__Component__c');
                setFields.add('SVMXC__Warranty__c');
                setFields.add('SVMXC__Service_Contract__c');
                setFields.add('SVMXC__Company__c');
                setFields.add('SVMXC__Contact__c');
                setFields.add('SVMXC__Billing_Type__c');
                setFields.add('SVMXC__Product__c');
                setFields.add('SVMXC__Is_Service_Covered__c');
                setFields.add('SVMXC__Top_Level__c');
                setFields.add('SVMXC__Site__c');
                setFields.add('CreatedDate');
                setFields.add('SVMXC__Is_Entitlement_Performed__c');
                
                
                list<SVMXC__Service__c> lstAvailServices = new list<SVMXC__Service__c>();
                list<SVMXC__ServiceMax_Config_Data__c> lstConfigExpr = new list<SVMXC__ServiceMax_Config_Data__c>();
                set<string> setProcessIds = new set<string>(); 
                lstAvailServices = [Select SVMXC__Qualifying_Criteria__c, Id from SVMXC__Service__c where SVMXC__Qualifying_Criteria__c != null AND SVMXC__Tracked_On__c = 'Work Order'];
                for(SVMXC__Service__c currService : lstAvailServices)
                {
                    if(currService.SVMXC__Qualifying_Criteria__c != null)
                        setProcessIds.add(currService.SVMXC__Qualifying_Criteria__c);   
                }
                    
                if(setProcessIds != null && setProcessIds.size() > 0)
                    //SDL-SVMX-FLS-NOT-ENFORCED-META-DATA
                    lstConfigExpr = [select SVMXC__Field_Name__c, Id from SVMXC__ServiceMax_Config_Data__c where SVMXC__Expression_Type__c = 'EXP_Named' AND RecordType.Name='Expressions' AND SVMXC__Expression_Rule__c IN: setProcessIds];
                
                for(SVMXC__ServiceMax_Config_Data__c currConfigData : lstConfigExpr)
                {
                    if(currConfigData.SVMXC__Field_Name__c != null && currConfigData.SVMXC__Field_Name__c != '')
                        setFields.add(currConfigData.SVMXC__Field_Name__c);
                }
                lstAvailServices.clear();
                lstConfigExpr.clear();
                setProcessIds.clear();
                
                
                
                String buildingFieldsQury = '';
                for(String field : setFields)
                {
                    if(buildingFieldsQury != null  && buildingFieldsQury.length() == 0 )
                        buildingFieldsQury = field;
                    else
                        buildingFieldsQury = buildingFieldsQury+' , '+field;
                }
                try
                {
                    String qury = 'select '+buildingFieldsQury+' from SVMXC__Service_Order__c where Id IN:lstIdsWO';
                    system.debug('query is : '+qury);
                    lstWOs = Database.query(qury);
                }
                catch(Exception ex)
                {
                    IsException = true;
                    if(mapSettings.containsKey('EVER007_SET003') && mapSettings.get('EVER007_SET003') != null)
                        strExecptin = System.Label.COMM001_TAG081 + ' ' +mapSettings.get('EVER007_SET003');
                    else
                        strExecptin = ex.getMessage();
                    
                }
                system.debug('get query WO : '+lstWOs );
                
                for(SVMXC__Service_Order__c WO : lstWOs)
                {
                    WO.SVMXC__Perform_Auto_Entitlement__c = true;
                    WO.SVMXC__Is_Entitlement_Performed__c = true; // Turn on this flag for Get Price. 
                }
                
                
                // Perform Entitlement by calling method SVMX_DoEntitlement.
                SVMX_DoEntitlement(lstWOs, mapSettings);
                
                // Update Entitlement history by calling method SVMX_UpdateEntitlementHistory.
                if(isUpdateHistory)
                {
                    SVMX_UpdateEntitlementHistory(lstWOs, lstWOs, mapSettings);
                }
                
                
                if(IsException != true)
                {
                    if(mapWOIDnSucess != null && mapWOIDnSucess.size() > 0 )
                    {
                        objResponse.valueMap = new List<SVMXC.INTF_WebServicesDef.SVMXMap>();
                        for(String ids : mapWOIDnSucess.keySet())
                        {
                            if(ids != null && ids.length() > 0)
                            {
                                if(mapWOIDnSucess.get(ids) != null)
                                {
                                    System.debug('IDS : '+mapWOIDnSucess.keySet());
                                    SVMXC.INTF_WebServicesDef.SVMXMap objSVMXMap = new SVMXC.INTF_WebServicesDef.SVMXMap();
                                    objSVMXMap.key = ids.substring(0,15);
                                    objSVMXMap.value = mapWOIDnSucess.get(ids);
                                    objResponse.valueMap.add(objSVMXMap);
                                }
                            }
                        }
                    }
                    for(SVMXC__Service_Order__c WO : lstWOs)
                        WO.SVMXC__Perform_Auto_Entitlement__c = false;
                    if(lstWOs != null && lstWOs.size() > 0){
                        if(COMM_SecurityUtils.getInstance().verifyFieldAccess(lstWOs, COMM_SecurityUtils.Access.Upsertable)){
                            //SDL-SVM-CREATE-UPDATE-FLS-ENFORCED
                             upsert lstWOs;
                        }
                        else{
                            throw new COMM_SecurityUtils.SecurityAccessException( System.Label.COMM001_TAG142 );
                        } 
                    }
                       
                    objResponse.success = true;
                }else
                {
                    objResponse.success = false;
                    objResponse.message = strExecptin;
                }
            }
        }
        catch(Exception ex)
        {
            objResponse.success = false;
            objResponse.message = ex.getMessage();
        }
       
        return objResponse;
    }  
    
    
    
    public void SVMX_DoEntitlement(list<SVMXC__Service_Order__c> lstWrkOrdr, Map<String, String> mapSettings)
    {
        String billingTypeValue; //Billing type value to be set when entitlement fails and auto calculate billing type is enabled
        // Entitlement enhancement: Setting to get the Date field of Case by which Entitlement validity can be checked.
        if(mapSettings.containsKey('EVER007_SET003') && mapSettings.get('EVER007_SET003') == null )
        {
            for(SVMXC__Service_Order__c objWO : lstWrkOrdr)
                objWO.addError(' '+ System.Label.COMM001_TAG081);
            return;
        }
        else if(mapSettings.containsKey('EVER007_SET003') && mapSettings.get('EVER007_SET003') != null )
            Setng_EntitleUsingFld = mapSettings.get('EVER007_SET003');
        //Added on 2/3/2011 Due to Defect 001402(By Amar)
        system.debug('mapSettings'+mapSettings);
        if(mapSettings.containsKey('EVER007_SET002') && mapSettings.get('EVER007_SET002').toUpperCase() == 'FALSE')
        {
            system.debug('entered'+SetBillingType);
            SetBillingType = false;
        }

        if(mapSettings.containsKey('EVER007_SET005') && mapSettings.get('EVER007_SET005') != null)
            billingTypeValue = mapSettings.get('EVER007_SET005');

        
        system.debug('SetBillingType'+SetBillingType);

        if(mapSettings.containsKey('EVER007_SET001') && mapSettings.get('EVER007_SET001').toUpperCase() == 'TRUE')
        {
            Set<Id> autoEntitlementWOIds = new Set<Id>(); //WO Ids of records on which child Auto Entitlement is enabled
            for(integer iIndex = 0; iIndex < lstWrkOrdr.size(); iIndex++)
            {
                /* Defect(8660): Save this static map to prevent Entitlement History records multiple times on edit of Work Order record. */
                if(lstWrkOrdr[iIndex].Id != NULL && String.valueOf(lstWrkOrdr[iIndex].Id).length() > 0)
                    mapWOIdCheckEntitlement.put(lstWrkOrdr[iIndex].Id, lstWrkOrdr[iIndex].SVMXC__Perform_Auto_Entitlement__c);
                else
                    mapWOIndexCheckEntitlement.put(iIndex, lstWrkOrdr[iIndex].SVMXC__Perform_Auto_Entitlement__c);
                
                SVMXC__Service_Order__c objWO = lstWrkOrdr[iIndex];
                if(objWO != null && objWO.SVMXC__Perform_Auto_Entitlement__c)
                {
                    if(objWO.Id != null)
                     autoEntitlementWOIds.add(objWO.Id);
                    mapWO.put(iIndex, objWO);
                    //objWO.SVMXC__Is_Entitlement_Performed__c = true; // Turn on this flag for Get Price. 
                    if(objWO.SVMXC__Component__c != NULL )
                    {
                        //mapIBWOIndex.put(objWO.SVMXC__Component__c, iIndex);
                        setComponent.add(objWO.SVMXC__Component__c);
                        if(!mapIBWOList.containsKey(objWO.SVMXC__Component__c))
                            mapIBWOList.put(objWO.SVMXC__Component__c, new list<Id>());
                        mapIBWOList.get(objWO.SVMXC__Component__c).add(objWO.Id);
                    }
                }
            }
            
            if(mapSVMXProcess.size() == 0 || mapExpression.size() == 0){
            
                mapSVMXProcess.putAll([SELECT Name, SVMXC__Allow_Override__c,SVMXC__Field_Name__c, SVMXC__Match_Contact__c, SVMXC__Include_Product__c, SVMXC__Match_Account__c, SVMXC__Pick_First_Match__c, SVMXC__Counter_Vs_Dates_Rule__c, SVMXC__Include_Parent__c, SVMXC__Include_Top_Level__c, SVMXC__Entitlement_Scope__c, SVMXC__Entitlement_By__c, SVMXC__Sequence__c, SVMXC__Name__c, SVMXC__Advance_Expression__c, SVMXC__Rule_Type__c, SVMXC__Process__c, SVMXC__Match_Location__c, SVMXC__Consider_Location_From__c, SVMXC__Consider_Location_From_Object__c,SVMXC__Enable_Child_Line_Entitlement__c,SVMXC__SM_Disable_AutoEntitlement__c, Id  from SVMXC__ServiceMax_Processes__c where RecordType.Name = 'SVMX Rule' AND (SVMXC__Rule_Type__c = 'Auto Entitlement WO' OR SVMXC__Rule_Type__c = 'Counters')]);
                
                if(mapSVMXProcess.size() > 0){
                    mapExpression.putAll([SELECT Id, SVMXC__Source_Field_Name__c, SVMXC__Target_Field_Name__c, SVMXC__Display_Type__c, SVMXC__Sequence__c, SVMXC__RecordType_Name__c, SVMXC__Operator__c, SVMXC__Operand__c, SVMXC__Object_Name__c, SVMXC__Lookup_Field_API_Name__c, SVMXC__Inventory_Process__c, SVMXC__Field_Name__c, SVMXC__FKey_Name_Field__c, SVMXC__Expression_Type__c, SVMXC__Expression_Rule__c from SVMXC__ServiceMax_Config_Data__c where RecordType.Name='Expressions' AND SVMXC__Expression_Rule__c IN :mapSVMXProcess.KeySet() AND (SVMXC__Expression_Type__c = 'WO_Auto_Entitlement' OR SVMXC__Expression_Type__c = 'IPRD_Counters')]);
                }
                
                mapEntRules.clear();
                mapEntRuleExpression.clear();
                mapCountersRules.clear();
                mapCountersRuleExpression.clear();
            }
            
            for(SVMXC__ServiceMax_Processes__c oSVMXProcess : mapSVMXProcess.Values())
            {
                if(oSVMXProcess.SVMXC__Rule_Type__c == 'Auto Entitlement WO')
                {
                    mapEntRules.put(oSVMXProcess.Id, oSVMXProcess);
                    mapEntRuleExpression.put(oSVMXProcess.Id, new List<SVMXC__ServiceMax_Config_Data__c>());
                }
                else if(oSVMXProcess.SVMXC__Rule_Type__c == 'Counters')
                    mapCountersRules.put(oSVMXProcess.Id, oSVMXProcess);
            }
            
            for(SVMXC__ServiceMax_Config_Data__c oExp: mapExpression.values())
            {
                if(oExp.SVMXC__Expression_Type__c == 'WO_Auto_Entitlement')
                {
                    if(!mapEntRuleExpression.containsKey(oExp.SVMXC__Expression_Rule__c))
                        mapEntRuleExpression.put(oExp.SVMXC__Expression_Rule__c, new List<SVMXC__ServiceMax_Config_Data__c>());
                    mapEntRuleExpression.get(oExp.SVMXC__Expression_Rule__c).add(oExp);
                }
                else if(oExp.SVMXC__Expression_Type__c == 'IPRD_Counters')
                {
                    if(!mapCountersRuleExpression.containsKey(oExp.SVMXC__Expression_Rule__c))
                        mapCountersRuleExpression.put(oExp.SVMXC__Expression_Rule__c, new List<SVMXC__ServiceMax_Config_Data__c>());
                    mapCountersRuleExpression.get(oExp.SVMXC__Expression_Rule__c).add(oExp);
                }
            }
            
            system.debug('mapEntRuleExpression='+mapEntRules);
            mapWOEntRule = oExpressionParsing.SVMX_ExpressionParsing(mapWO, mapEntRuleExpression, mapEntRules);
            system.debug('mapWOEntRule='+mapWOEntRule);
            string strWhereClouseProductWarranty;
            string strWhereClouseServiceContract;
            string strCounterWhereClouseProductWarranty;
            string strCounterWhereClouseServiceContract;
            Set<Id> wOLineIBs = new Set<Id>(); //The set will hold WO IB and Product Service IBs
            //string strdate = string.valueOf(date.Today());
           
            //Getting all the Product Seviced Lines associated with the WOs for which Perform Auto Entitlement is enabled
            if(!autoEntitlementWOIds.isEmpty()){
                for(SVMXC__Service_Order_Line__c woLine :[SELECT Id,SVMXC__Service_Order__c, SVMXC__Is_Entitlement_Performed__c,SVMXC__Service_Maintenance_Contract__c,SVMXC__Entitlement_Notes__c,SVMXC__Serial_Number__c,SVMXC__Product_Warranty__c
                                                            FROM SVMXC__Service_Order_Line__c WHERE SVMXC__Service_Order__c IN : autoEntitlementWOIds AND RecordType.DeveloperName = 'Products_Serviced'  ]){  //To Do : replace with Custom Label for Record type Name  
                     if(woLine.SVMXC__Serial_Number__c != null){
                         oldWOServiceLinesMap.put(woLine.Id,woLine.clone());  
                         //woLine.SVMXC__Auto_Entitlement_Status__c = '';
                         woLine.SVMXC__Product_Warranty__c = null;
                         woLine.SVMXC__Service_Maintenance_Contract__c = null;
                         woLine.SVMXC__Entitlement_Notes__c = null;
                         woLine.SVMXC__Is_Entitlement_Performed__c = false;
                         setComponent.add(woLine.SVMXC__Serial_Number__c); 
                         List<SVMXC__Service_Order_Line__c> tempList = new List<SVMXC__Service_Order_Line__c>();    
                         if(wODetailLineMap.containsKey(woLine.SVMXC__Service_Order__c))
                            tempList = wODetailLineMap.get(woLine.SVMXC__Service_Order__c);
                         tempList.add(woLine); 
                         wODetailLineMap.put(woLine.SVMXC__Service_Order__c,tempList);   
                         System.debug(LoggingLevel.INFO, 'woLine : ' + woLine);    
                     }
                }
            }

            System.debug(Logginglevel.Info, 'setComponent : ' + setComponent);
            //During SOQL optimization, populating this map from Work Order trigger.
            mapComponent.clear();
            if(setComponent != null && setComponent.size() > 0){
               for(SVMXC__Installed_Product__c iBRec : [select Id, SVMXC__Parent__c, SVMXC__Top_Level__c, SVMXC__Product__c from SVMXC__Installed_Product__c where Id in :setComponent]){
                    mapComponent.put(iBRec.Id,iBRec);   
               }
            }
            
            System.debug(Logginglevel.Info, 'mapComponent : size = ' + mapComponent.size() + ' values : ' + mapComponent);
            for(SVMXC__Installed_Product__c oIB :mapComponent.values())
            {
                mapProductId.put(oIB.Id, oIB.SVMXC__Product__c);
            }
            for(Integer iWOIndex :mapWOEntRule.KeySet())
            {
                SVMXC__Service_Order__c objWO = mapWO.get(iWOIndex);
                objWO.SVMXC__Warranty__c = null;
                objWO.SVMXC__Service_Contract__c = null;
                objWO.SVMXC__SLA_Terms__c = null;
                objWO.SVMXC__Entitlement_Notes__c = '';
                //Enhancement
                objWO.SVMXC__Is_Service_Covered__c = false;
                objWO.SVMXC__Auto_Entitlement_Status__c = '';
                objWO.SVMXC__Is_Entitlement_Performed__c = false;
                
                //In Work Order of new Work Order Rec, consider Today.(Because Created date or other date fields will be null)
                string strdate = null;
                try
                {
                    if(Setng_EntitleUsingFld.equalsIgnoreCase('Today') || Setng_EntitleUsingFld.equalsIgnoreCase('CreatedDate'))
                        strdate = string.valueOf(date.today());
                    else 
                        strdate = String.valueOf(date.valueOf(objWO.get(Setng_EntitleUsingFld)));
                    
                    if(strdate == null)
                    {
                        objWO.addError(' ' + System.Label.COMM001_TAG080 + ' ' +Setng_EntitleUsingFld);
                        return;
                    }
                }
                catch(exception ex)
                {
                    objWO.addError(' '+ System.Label.COMM001_TAG081 + ' ' +Setng_EntitleUsingFld);
                    return;
                }
          
                if(objWO != null )//&& objWO.SVMXC__Component__c != null)
                {
                    SVMXC__ServiceMax_Processes__c oEntRule = mapEntRules.get(mapWOEntRule.get(iWOIndex));
                    if(oEntRule != null)
                    {
                        performEntitlementOnWOMap.put(iWOIndex,true); //Map to check, if entitlement has to be performed on WO (By default set to true)
                        if(objWO.SVMXC__Component__c != null)    
                           wOLineIBs.add(objWO.SVMXC__Component__c);
                        Set<Id> productServiceIds = new Set<Id>();
                      /*  if(oEntRule.SVMXC__Enable_Child_Line_Entitlement__c && wODetailLineMap.containsKey(objWO.Id) && wODetailLineMap.get(objWO.Id) != null){
                            for(SVMXC__Service_Order_Line__c wOLine : wODetailLineMap.get(objWO.Id)){
                                if(wOLine.SVMXC__Serial_Number__c != null)
                                  productServiceIds.add(wOLine.SVMXC__Serial_Number__c);
                            }
                            if(!wODetailLineMap.get(objWO.Id).isEmpty())
                               performEntitlementOnWOMap.put(iWOIndex,false); 
                        } */
                        
                        if(oEntRule.SVMXC__Enable_Child_Line_Entitlement__c){
                            performEntitlementOnWOMap.put(iWOIndex,false); 
                            if(wODetailLineMap.containsKey(objWO.Id) && wODetailLineMap.get(objWO.Id) != null){
                                for(SVMXC__Service_Order_Line__c wOLine : wODetailLineMap.get(objWO.Id)){
                                    if(wOLine.SVMXC__Serial_Number__c != null)
                                      productServiceIds.add(wOLine.SVMXC__Serial_Number__c);
                                }
                            }
                        }

                        if(!productServiceIds.isEmpty() )
                            wOLineIBs.addAll(productServiceIds);
                        if(oEntRule.SVMXC__Include_Parent__c ){
                            if(objWO.SVMXC__Component__c != null){
                                if(mapComponent.get(objWO.SVMXC__Component__c) != null){
                                    Id parentComponentId = mapComponent.get(objWO.SVMXC__Component__c).SVMXC__Parent__c;
                                    if(parentComponentId != null){
                                        mapParentIB.put(objWO.SVMXC__Component__c, parentComponentId);
                                        wOLineIBs.add(parentComponentId);
                                    }    
                                }
                            }
                            System.debug(Logginglevel.Info, 'productServiceIds :' + productServiceIds);
                            for(Id detailIBId : productServiceIds){
                                if(!mapParentIB.containskey(detailIBId) && mapComponent.get(detailIBId) != null){
                                    Id parentComponentId = mapComponent.get(detailIBId).SVMXC__Parent__c;
                                    if(parentComponentId != null){
                                        mapParentIB.put(detailIBId, parentComponentId);
                                        wOLineIBs.add(parentComponentId);
                                    }
                                }
                            }
                            System.debug(Logginglevel.Info, 'mapParentIB : ' + mapParentIB);
                                    
                        }

                        if(oEntRule.SVMXC__Include_Top_Level__c){
                            if(objWO.SVMXC__Component__c != null){
                                if(mapComponent.get(objWO.SVMXC__Component__c) != null){
                                    Id parentComponentId = mapComponent.get(objWO.SVMXC__Component__c).SVMXC__Top_Level__c;
                                    if(parentComponentId != null){
                                        mapTopLevelIB.put(objWO.SVMXC__Component__c, parentComponentId);
                                        wOLineIBs.add(parentComponentId);
                                    }
                                }
                            }
                            System.debug(Logginglevel.Info, 'productServiceIds :' + productServiceIds);    
                            for(Id detailIBId : productServiceIds){
                                if(!mapTopLevelIB.containskey(detailIBId) && mapComponent.get(detailIBId) != null){
                                    Id parentComponentId = mapComponent.get(detailIBId).SVMXC__Top_Level__c;
                                    if(parentComponentId != null){
                                        mapTopLevelIB.put(detailIBId, parentComponentId);
                                        wOLineIBs.add(parentComponentId);
                                    }     
                                }
                            }
                            System.debug(Logginglevel.Info, 'mapTopLevelIB : ' + mapTopLevelIB);
                        }
                        
                        if(oEntRule.SVMXC__Entitlement_Scope__c == 'Warranties' || oEntRule.SVMXC__Entitlement_Scope__c == 'Both' )
                        {
                            /*Commented for the defect 020280 - Auto Entitlement through Warranty on Counters
                            if(oEntRule.SVMXC__Entitlement_By__c == 'Validity dates' || oEntRule.SVMXC__Entitlement_By__c == 'Both' || oEntRule.SVMXC__Entitlement_By__c == 'Counters')
                            {
                                if(strWhereClouseProductWarranty == null)
                                    strWhereClouseProductWarranty = '( ' + getIBStringFull(objWO, oEntRule) + ' AND SVMXC__Start_Date__c <= ' +strdate + ' AND SVMXC__End_Date__c >= ' + strdate + ' )';
                                else
                                    strWhereClouseProductWarranty += ' OR ( ' + getIBStringFull(objWO, oEntRule) + ' AND SVMXC__Start_Date__c <= ' +strdate + ' AND SVMXC__End_Date__c >= ' + strdate +' )';
                            }*/
                            
                            //This change is for fixing defect 021648
                            //if(oEntRule.SVMXC__Entitlement_By__c == 'Validity dates' || oEntRule.SVMXC__Entitlement_By__c == 'Both')
                            if(oEntRule.SVMXC__Entitlement_By__c == 'Validity dates')
                            {
                                if(strWhereClouseProductWarranty == null)
                                    strWhereClouseProductWarranty = '( SVMXC__Installed_Product__c IN : wOLineIBs AND SVMXC__Start_Date__c <= ' +strdate + ' AND SVMXC__End_Date__c >= ' + strdate + ' )';
                                else
                                    strWhereClouseProductWarranty += ' OR (SVMXC__Installed_Product__c IN : wOLineIBs AND SVMXC__Start_Date__c <=' +strdate + ' AND SVMXC__End_Date__c >= ' + strdate +' )';
                            }
                            //This change is for fixing defect 021648
                            //else if(oEntRule.SVMXC__Entitlement_By__c == 'Counters'){
                            else if(oEntRule.SVMXC__Entitlement_By__c == 'Counters' || oEntRule.SVMXC__Entitlement_By__c == 'Both'){
                                if(strWhereClouseProductWarranty == null)
                                   strWhereClouseProductWarranty = '( SVMXC__Installed_Product__c IN : wOLineIBs)';
                                else
                                   strWhereClouseProductWarranty += ' OR ( SVMXC__Installed_Product__c IN : wOLineIBs)';
                            }
                        }
                        if(oEntRule.SVMXC__Entitlement_Scope__c == 'Service Contracts' || oEntRule.SVMXC__Entitlement_Scope__c == 'Both' )
                        {
                            if(oEntRule.SVMXC__Include_Product__c)
                            {
                                system.debug(oEntRule.SVMXC__Entitlement_By__c + '----');
                                if(oEntRule.SVMXC__Entitlement_By__c == 'Validity dates' || oEntRule.SVMXC__Entitlement_By__c == 'Both')
                                {
                                    string trmpstrWhereClouseServiceContract = '';
                                    trmpstrWhereClouseServiceContract = ' (( SVMXC__Installed_Product__c IN : wOLineIBs OR SVMXC__Product__c = \'' + mapProductId.get(objWO.SVMXC__Component__c) + '\' ) AND ((SVMXC__Start_Date__c != null AND SVMXC__End_Date__c != null AND SVMXC__Start_Date__c <= ' +strdate + ' AND SVMXC__End_Date__c >= ' + strdate + ') OR ((SVMXC__Start_Date__c = null OR SVMXC__End_Date__c = null ) AND SVMXC__Service_Contract__r.SVMXC__Start_Date__c <= ' +strdate + ' AND SVMXC__Service_Contract__r.SVMXC__End_Date__c >= ' + strdate + ')) ';
                                    boolean isvalidQuery = true;
                                    if(oEntRule.SVMXC__Match_Account__c)
                                    {
                                        if(objWO.SVMXC__Company__c != null)
                                        {
                                            mapWOAccount.put(iWOIndex, objWO.SVMXC__Company__c);
                                            trmpstrWhereClouseServiceContract += ' AND SVMXC__Service_Contract__r.SVMXC__Company__c = \'' + objWO.SVMXC__Company__c + '\'';
                                        }
                                        else 
                                            isvalidQuery = false;
                                    }
                                    trmpstrWhereClouseServiceContract += ' ) ';
                                    if(oEntRule.SVMXC__Match_Contact__c && objWO.SVMXC__Contact__c != null)
                                        mapWOContact.put(iWOIndex, objWO.SVMXC__Contact__c);
                                    if(oEntRule.SVMXC__Match_Location__c && objWO.SVMXC__Site__c != null)
                                        mapWOLocation.put(iWOIndex, objWO.SVMXC__Site__c);
                                    if(isvalidQuery)
                                    {
                                        if(strWhereClouseServiceContract == null || strWhereClouseServiceContract.length() == 0)
                                            strWhereClouseServiceContract = trmpstrWhereClouseServiceContract;
                                        else
                                            strWhereClouseServiceContract += ' OR ' + trmpstrWhereClouseServiceContract;
                                    }
                                }
                                else if( oEntRule.SVMXC__Entitlement_By__c == 'Counters')
                                {
                                    if(oEntRule.SVMXC__Match_Account__c && objWO.SVMXC__Company__c != null)
                                        mapWOAccount.put(iWOIndex, objWO.SVMXC__Company__c);
                                    if(oEntRule.SVMXC__Match_Contact__c && objWO.SVMXC__Contact__c != null)
                                        mapWOContact.put(iWOIndex, objWO.SVMXC__Contact__c);
                                    if(oEntRule.SVMXC__Match_Location__c && objWO.SVMXC__Site__c != null)
                                        mapWOLocation.put(iWOIndex, objWO.SVMXC__Site__c);
                                }
                            }
                            else
                            {
                                if(oEntRule.SVMXC__Entitlement_By__c == 'Validity dates' || oEntRule.SVMXC__Entitlement_By__c == 'Both')
                                {
                                    string trmpstrWhereClouseServiceContract = '';
                                    trmpstrWhereClouseServiceContract = ' ( SVMXC__Installed_Product__c IN : wOLineIBs AND ((SVMXC__Start_Date__c != null AND SVMXC__End_Date__c != null AND SVMXC__Start_Date__c <= ' +strdate + ' AND SVMXC__End_Date__c >= ' + strdate + ') OR ((SVMXC__Start_Date__c = null OR SVMXC__End_Date__c = null ) AND SVMXC__Service_Contract__r.SVMXC__Start_Date__c <= ' +strdate + ' AND SVMXC__Service_Contract__r.SVMXC__End_Date__c >= ' + strdate + ')) ';
                                    boolean isvalidQuery = true;
                                    if(oEntRule.SVMXC__Match_Account__c)
                                    {
                                        if(objWO.SVMXC__Company__c != null)
                                        {
                                            mapWOAccount.put(iWOIndex, objWO.SVMXC__Company__c);
                                            trmpstrWhereClouseServiceContract += ' AND SVMXC__Service_Contract__r.SVMXC__Company__c = \'' + objWO.SVMXC__Company__c + '\'';
                                        }
                                        else 
                                            isvalidQuery = false;
                                    }
                                    trmpstrWhereClouseServiceContract += ' ) ';
                                    if(oEntRule.SVMXC__Match_Contact__c && objWO.SVMXC__Contact__c != null)
                                        mapWOContact.put(iWOIndex, objWO.SVMXC__Contact__c);
                                    if(oEntRule.SVMXC__Match_Location__c && objWO.SVMXC__Site__c != null)
                                        mapWOLocation.put(iWOIndex, objWO.SVMXC__Site__c);
                                    if(isvalidQuery)
                                    {
                                        if(strWhereClouseServiceContract == null || strWhereClouseServiceContract.length() == 0)
                                            strWhereClouseServiceContract = trmpstrWhereClouseServiceContract;
                                        else
                                            strWhereClouseServiceContract += ' OR ' + trmpstrWhereClouseServiceContract;
                                    }
                                }
                                else if( oEntRule.SVMXC__Entitlement_By__c == 'Counters')
                                {
                                    if(oEntRule.SVMXC__Match_Account__c && objWO.SVMXC__Company__c != null)
                                        mapWOAccount.put(iWOIndex, objWO.SVMXC__Company__c);
                                    if(oEntRule.SVMXC__Match_Contact__c && objWO.SVMXC__Contact__c != null)
                                        mapWOContact.put(iWOIndex, objWO.SVMXC__Contact__c);
                                    if(oEntRule.SVMXC__Match_Location__c && objWO.SVMXC__Site__c != null)
                                        mapWOLocation.put(iWOIndex, objWO.SVMXC__Site__c);
                                }
                            }
                        }
                        if((oEntRule.SVMXC__Field_Name__c == 'Account' || oEntRule.SVMXC__Match_Account__c) && objWO.SVMXC__Company__c != null)
                            mapWOAccount.put(iWOIndex, objWO.SVMXC__Company__c);
                        if(oEntRule.SVMXC__Match_Contact__c && objWO.SVMXC__Contact__c != null)
                            mapWOContact.put(iWOIndex, objWO.SVMXC__Contact__c);
                        if(oEntRule.SVMXC__Match_Location__c && objWO.SVMXC__site__c != null)
                            mapWOLocation.put(iWOIndex, objWO.SVMXC__Site__c);
                    }
                }
                /*else if(objWO != null)
                {
                    SVMXC__ServiceMax_Processes__c oEntRule = mapEntRules.get(mapWOEntRule.get(iWOIndex));
                    if(oEntRule != null )
                    {
                        if(oEntRule.SVMXC__Match_Account__c && objWO.SVMXC__Company__c != null)
                            mapWOAccount.put(iWOIndex, objWO.SVMXC__Company__c);
                        if(oEntRule.SVMXC__Match_Contact__c && objWO.SVMXC__Contact__c != null)
                            mapWOContact.put(iWOIndex, objWO.SVMXC__Contact__c);
                        if(oEntRule.SVMXC__Match_Location__c && objWO.SVMXC__site__c != null)
                            mapWOLocation.put(iWOIndex, objWO.SVMXC__Site__c);
 
                    }
                } */
            }
            if((mapParentIB != null && mapParentIB.size() > 0) || (mapTopLevelIB != null && mapTopLevelIB.size() > 0)){
                mapComponentParentANDTopLevel.putAll([select Id, SVMXC__Parent__c, SVMXC__Top_Level__c, SVMXC__Product__c from SVMXC__Installed_Product__c where Id in :mapParentIB.values() OR Id in :mapTopLevelIB.values()]);
            }
            for(SVMXC__Installed_Product__c oIB :mapComponentParentANDTopLevel.values())
            {
                mapProductId.put(oIB.Id, oIB.SVMXC__Product__c);
            }
            Set<Id> ibSet = new Set<Id>();
            ibSet.addAll(mapComponent.Keyset());
            ibSet.addAll(mapParentIB.values());
            ibSet.addAll(mapTopLevelIB.values());
            if(ibSet.contains(null))
                ibset.remove(null);
            set<ID> ProdIDs = new  set<ID>();
            ProdIDs.addAll(mapProductId.values());
            if(ProdIDs.contains(null))
                ProdIDs.remove(null);
             //Added for PB-Xray 107---Using old reading with single entry and latest reading if there are multiple reading entries for each counter definition
            List<SVMXC__Counter_Details__c> lstCounterReading =  new List<SVMXC__Counter_Details__c>();
            if (ibSet != null && ibSet.size() > 0 && ProdIDs != null && ProdIDs.size() > 0){
                lstCounterReading = [select Id, SVMXC__Service_Maintenance_Contract__r.Name, SVMXC__Service_Maintenance_Contract__r.SVMXC__Service_Level__c,  SVMXC__Coverage_Limit__c, SVMXC__Coverage_Starts_At__c, SVMXC__Product__c, SVMXC__Warranty_Terms__r.Id, SVMXC__Warranty_Terms__c, RecordType.Name, SVMXC__Installed_Product__c, SVMXC__Counter_Definition__r.SVMXC__Counter_Type__c, SVMXC__Service_Maintenance_Contract__r.Id, SVMXC__Counter_Definition__r.SVMXC__Max_Value__c, SVMXC__Counter_Definition__r.SVMXC__Min_Value__c, SVMXC__Counter_Reading__c, SVMXC__Counter_Definition__c, SVMXC__Service_Maintenance_Contract__r.SVMXC__Company__c, SVMXC__Service_Maintenance_Contract__r.SVMXC__Active__c, SVMXC__Is_Latest__c from SVMXC__Counter_Details__c where RecordType.Name = 'Reading' AND (SVMXC__Installed_Product__c IN :ibSet OR SVMXC__Product__c IN :ProdIDs)];
            }
            else if (ProdIDs != null && ProdIDs.size() > 0){
                lstCounterReading = [select Id, SVMXC__Service_Maintenance_Contract__r.Name, SVMXC__Service_Maintenance_Contract__r.SVMXC__Service_Level__c,  SVMXC__Coverage_Limit__c, SVMXC__Coverage_Starts_At__c, SVMXC__Product__c, SVMXC__Warranty_Terms__r.Id, SVMXC__Warranty_Terms__c, RecordType.Name, SVMXC__Installed_Product__c, SVMXC__Counter_Definition__r.SVMXC__Counter_Type__c, SVMXC__Service_Maintenance_Contract__r.Id, SVMXC__Counter_Definition__r.SVMXC__Max_Value__c, SVMXC__Counter_Definition__r.SVMXC__Min_Value__c, SVMXC__Counter_Reading__c, SVMXC__Counter_Definition__c, SVMXC__Service_Maintenance_Contract__r.SVMXC__Company__c, SVMXC__Service_Maintenance_Contract__r.SVMXC__Active__c, SVMXC__Is_Latest__c from SVMXC__Counter_Details__c where RecordType.Name = 'Reading' AND SVMXC__Product__c IN :ProdIDs];
            }
            else if (ibSet != null && ibSet.size() > 0){
                lstCounterReading = [select Id, SVMXC__Service_Maintenance_Contract__r.Name, SVMXC__Service_Maintenance_Contract__r.SVMXC__Service_Level__c,  SVMXC__Coverage_Limit__c, SVMXC__Coverage_Starts_At__c, SVMXC__Product__c, SVMXC__Warranty_Terms__r.Id, SVMXC__Warranty_Terms__c, RecordType.Name, SVMXC__Installed_Product__c, SVMXC__Counter_Definition__r.SVMXC__Counter_Type__c, SVMXC__Service_Maintenance_Contract__r.Id, SVMXC__Counter_Definition__r.SVMXC__Max_Value__c, SVMXC__Counter_Definition__r.SVMXC__Min_Value__c, SVMXC__Counter_Reading__c, SVMXC__Counter_Definition__c, SVMXC__Service_Maintenance_Contract__r.SVMXC__Company__c, SVMXC__Service_Maintenance_Contract__r.SVMXC__Active__c, SVMXC__Is_Latest__c from SVMXC__Counter_Details__c where RecordType.Name = 'Reading' AND SVMXC__Installed_Product__c IN :ibSet];
            }
            System.debug('NoOFReading : '+lstCounterReading.size());
            System.debug('ReadingRecord : '+lstCounterReading);
            
            Map<String, List<SVMXC__Counter_Details__c>> mapIBIdListReading = new Map<String, List<SVMXC__Counter_Details__c>>();
            for(SVMXC__Counter_Details__c objReading : lstCounterReading){
                if(!mapIBIdListReading.containsKey(objReading.SVMXC__Installed_Product__c))
                    mapIBIdListReading.put(objReading.SVMXC__Installed_Product__c, new List<SVMXC__Counter_Details__c>());
                mapIBIdListReading.get(objReading.SVMXC__Installed_Product__c).add(objReading);
            }
            System.debug('mapIBIdListReading size : '+mapIBIdListReading.size());
            System.debug('mapIBIdListReading : '+mapIBIdListReading);
            
            Map<String, List<SVMXC__Counter_Details__c>> mapDefinitionIdToReadingList;
            for(String objIBid : mapIBIdListReading.keySet()){
                mapDefinitionIdToReadingList = new Map<String, List<SVMXC__Counter_Details__c>>();
                for(SVMXC__Counter_Details__c objRead : mapIBIdListReading.get(objIBid)){
                    if(!mapDefinitionIdToReadingList.containsKey(objRead.SVMXC__Counter_Definition__c))
                        mapDefinitionIdToReadingList.put(objRead.SVMXC__Counter_Definition__c, new List<SVMXC__Counter_Details__c>());
                    mapDefinitionIdToReadingList.get(objRead.SVMXC__Counter_Definition__c).add(objRead);
                }
                System.debug('mapDefinitionIdToReadingList size : '+mapDefinitionIdToReadingList.size());
                System.debug('mapDefinitionIdToReadingList : '+mapDefinitionIdToReadingList);
                
                for(String DefId : mapDefinitionIdToReadingList.keySet()){
                    List<SVMXC__Counter_Details__c> lstReading = mapDefinitionIdToReadingList.get(DefId);
                    if(lstReading.size() == 1)
                        mapCounterDetails.put(lstReading[0].id, lstReading[0]);
                    else{
                        for(SVMXC__Counter_Details__c objRead : lstReading){
                            if(objRead.SVMXC__Is_Latest__c == true)
                                mapCounterDetails.put(objRead.id, objRead);
                        }
                    }
                }
            }
            System.debug('mapCounterDetails : '+mapCounterDetails);
            System.debug('mapCounterDetails Size: '+mapCounterDetails.size());
            
            if (ibSet != null && ibSet.size() > 0 && ProdIDs != null && ProdIDs.size() > 0)
            {
                mapCounterDetails.putAll([select Id, SVMXC__Service_Maintenance_Contract__r.Name, SVMXC__Service_Maintenance_Contract__r.SVMXC__Service_Level__c,  SVMXC__Coverage_Limit__c, SVMXC__Coverage_Starts_At__c, SVMXC__Product__c, SVMXC__Warranty_Terms__r.Id, SVMXC__Warranty_Terms__c, RecordType.Name, SVMXC__Installed_Product__c, SVMXC__Counter_Definition__r.SVMXC__Counter_Type__c, SVMXC__Service_Maintenance_Contract__r.Id, SVMXC__Counter_Definition__r.SVMXC__Max_Value__c, SVMXC__Counter_Definition__r.SVMXC__Min_Value__c, SVMXC__Counter_Reading__c, SVMXC__Counter_Definition__c, SVMXC__Service_Maintenance_Contract__r.SVMXC__Company__c, SVMXC__Service_Maintenance_Contract__r.SVMXC__Active__c from SVMXC__Counter_Details__c where (RecordType.Name = 'Coverage' AND (SVMXC__Warranty_Terms__c != NULL OR (SVMXC__Service_Maintenance_Contract__c != NULL AND SVMXC__Service_Maintenance_Contract__r.SVMXC__Active__c = TRUE))) AND (SVMXC__Installed_Product__c IN :ibSet OR SVMXC__Product__c IN :ProdIDs)]);
            }
            else if (ProdIDs != null && ProdIDs.size() > 0)
            {
                mapCounterDetails.putAll([select Id, SVMXC__Service_Maintenance_Contract__r.Name, SVMXC__Service_Maintenance_Contract__r.SVMXC__Service_Level__c,  SVMXC__Coverage_Limit__c, SVMXC__Coverage_Starts_At__c, SVMXC__Product__c, SVMXC__Warranty_Terms__r.Id, SVMXC__Warranty_Terms__c, RecordType.Name, SVMXC__Installed_Product__c, SVMXC__Counter_Definition__r.SVMXC__Counter_Type__c, SVMXC__Service_Maintenance_Contract__r.Id, SVMXC__Counter_Definition__r.SVMXC__Max_Value__c, SVMXC__Counter_Definition__r.SVMXC__Min_Value__c, SVMXC__Counter_Reading__c, SVMXC__Counter_Definition__c, SVMXC__Service_Maintenance_Contract__r.SVMXC__Company__c, SVMXC__Service_Maintenance_Contract__r.SVMXC__Active__c from SVMXC__Counter_Details__c where (RecordType.Name = 'Coverage' AND (SVMXC__Warranty_Terms__c != NULL OR (SVMXC__Service_Maintenance_Contract__c != NULL AND SVMXC__Service_Maintenance_Contract__r.SVMXC__Active__c = TRUE))) AND (SVMXC__Product__c IN :ProdIDs)]);
            }
            else if (ibSet != null && ibSet.size() > 0)
            {   
                mapCounterDetails.putAll([select Id, SVMXC__Service_Maintenance_Contract__r.Name, SVMXC__Service_Maintenance_Contract__r.SVMXC__Service_Level__c,  SVMXC__Coverage_Limit__c, SVMXC__Coverage_Starts_At__c, SVMXC__Product__c, SVMXC__Warranty_Terms__r.Id, SVMXC__Warranty_Terms__c, RecordType.Name, SVMXC__Installed_Product__c, SVMXC__Counter_Definition__r.SVMXC__Counter_Type__c, SVMXC__Service_Maintenance_Contract__r.Id, SVMXC__Counter_Definition__r.SVMXC__Max_Value__c, SVMXC__Counter_Definition__r.SVMXC__Min_Value__c, SVMXC__Counter_Reading__c, SVMXC__Counter_Definition__c, SVMXC__Service_Maintenance_Contract__r.SVMXC__Company__c, SVMXC__Service_Maintenance_Contract__r.SVMXC__Active__c from SVMXC__Counter_Details__c where (RecordType.Name = 'Coverage' AND (SVMXC__Warranty_Terms__c != NULL OR (SVMXC__Service_Maintenance_Contract__c != NULL AND SVMXC__Service_Maintenance_Contract__r.SVMXC__Active__c = TRUE))) AND (SVMXC__Installed_Product__c IN :ibSet)]);
            }
            System.debug('mapCounterDetails Size: '+mapCounterDetails.size());
            System.debug('mapCounterDetails : '+mapCounterDetails);
            
            for(SVMXC__Counter_Details__c oCD :mapCounterDetails.values())
            {
                if(oCD.RecordType.Name == 'Reading')
                {
                    if(oCD.SVMXC__Installed_Product__c != null)
                    {
                        //mapCounterReadings.put(oCD.SVMXC__Installed_Product__c, oCD); Commented for the Multiple counter reading defect 020165
                        if(!mapIBIDAndListCounterReadings.containsKey(oCD.SVMXC__Installed_Product__c))
                            mapIBIDAndListCounterReadings.put(oCD.SVMXC__Installed_Product__c, new List<SVMXC__Counter_Details__c>());
                        mapIBIDAndListCounterReadings.get(oCD.SVMXC__Installed_Product__c).add(oCD);
                        
                        setCounterDefinitionId.add(oCD.SVMXC__Counter_Definition__c);
                        mapCounterDefIB.put(oCD.SVMXC__Counter_Definition__c, oCD.SVMXC__Installed_Product__c);
                    }
                }
                if(oCD.RecordType.Name == 'Coverage')
                {
                    if(oCD.SVMXC__Installed_Product__c != null && oCD.SVMXC__Service_Maintenance_Contract__c != null && oCD.SVMXC__Service_Maintenance_Contract__r.SVMXC__Active__c == true)
                    {
                        if(!mapCounterCoverageIB.containsKey(oCD.SVMXC__Installed_Product__c))
                            mapCounterCoverageIB.put(oCD.SVMXC__Installed_Product__c, new map<Id, SVMXC__Counter_Details__c>());
                        mapCounterCoverageIB.get(oCD.SVMXC__Installed_Product__c).put(oCD.Id, oCD);
                    }
                    if(oCD.SVMXC__Product__c != null && oCD.SVMXC__Warranty_Terms__c != null)
                    {
                        if(!mapCounterCoverageProduct.containsKey(oCD.SVMXC__Product__c))
                            mapCounterCoverageProduct.put(oCD.SVMXC__Product__c, new map<Id, SVMXC__Counter_Details__c>());
                        mapCounterCoverageProduct.get(oCD.SVMXC__Product__c).put(oCD.Id, oCD);
                    }
                }
            }
            System.debug('mapIBIDAndListCounterReadings Size: '+mapIBIDAndListCounterReadings.size());
            System.debug('mapIBIDAndListCounterReadings: '+mapIBIDAndListCounterReadings);
            
            if(mapWOContact != null && mapWOContact.size() > 0){
                mapEntitledContacts.putAll([select Id, SVMXC__Contact__c, SVMXC__Service_Contract__c from SVMXC__Service_Contract_Contacts__c where SVMXC__Contact__c IN :mapWOContact.values()]);
            }
            for(SVMXC__Service_Contract_Contacts__c oSCC :mapEntitledContacts.values())
            {
                if(!mapContactSC.containsKey(oSCC.SVMXC__Contact__c))
                    mapContactSC.put(oSCC.SVMXC__Contact__c, new set<Id>());
                mapContactSC.get(oSCC.SVMXC__Contact__c).add(oSCC.SVMXC__Service_Contract__c);
            }
            
            if(mapWOLocation != null && mapWOLocation.size() > 0)
                mapEntitledLocation.putAll([select Id, SVMXC__SLA_Terms__c, SVMXC__Start_Date__c,  SVMXC__End_Date__c, SVMXC__site__c,SVMXC__Service_Contract__c, SVMXC__Service_Contract__r.Name  
                                                FROM SVMXC__Service_Contract_Sites__c 
                                                WHERE SVMXC__Service_Contract__r.SVMXC__Active__c = true 
                                                AND SVMXC__site__c IN :mapWOLocation.values()]);
            System.debug(LoggingLevel.INFO, 'mapEntitledLocation : '+mapEntitledLocation);                                    
            set<string> setSCONIds = new set<string>(); 
            for(SVMXC__Service_Contract_Sites__c currLocation :mapEntitledLocation.values())
            {
                if(!mapLocationSCON.containsKey(currLocation.SVMXC__site__c))
                    mapLocationSCON.put(currLocation.SVMXC__site__c, new set<Id>());
                mapLocationSCON.get(currLocation.SVMXC__site__c).add(currLocation.SVMXC__Service_Contract__c);
                setSCONIds.add(currLocation.SVMXC__Service_Contract__c);
                
                if(currLocation.SVMXC__Service_Contract__c != null){
                    if(!mapServiceContractandCoveredLocations.containsKey(currLocation.SVMXC__Service_Contract__c ))
                        mapServiceContractandCoveredLocations.put(currLocation.SVMXC__Service_Contract__c,  new List<SVMXC__Service_Contract_Sites__c>());  
                    mapServiceContractandCoveredLocations.get(currLocation.SVMXC__Service_Contract__c).add(currLocation);
                }
            }
            
            map<Id,SVMXC__Service_Contract__c> mapContract =  new map<Id,SVMXC__Service_Contract__c>();
            //BAC - 4 Enhancement
            Set<Id> accountIds = new Set<Id>();
            if(!mapWOAccount.values().isEmpty()){
                accountIds.addAll(mapWOAccount.values());
            }
            if(!setSCONIds.isEmpty() || !accountIds.isEmpty()){
                mapContract.putAll([select Id, Name, SVMXC__Start_Date__c,SVMXC__Active__c, SVMXC__Company__c, SVMXC__End_Date__c, SVMXC__Service_Level__c from SVMXC__Service_Contract__c where Id IN: setSCONIds OR SVMXC__Company__c IN: accountIds]);
            }
            
            for(SVMXC__Service_Contract_Sites__c currLocation :mapEntitledLocation.values())
            {
                if(!mapLocationContractLst.containsKey(currLocation.SVMXC__site__c))
                    mapLocationContractLst.put(currLocation.SVMXC__site__c, new list<SVMXC__Service_Contract__c>());
                if(mapContract.containsKey(currLocation.SVMXC__Service_Contract__c) && mapContract.get(currLocation.SVMXC__Service_Contract__c) != null)
                    mapLocationContractLst.get(currLocation.SVMXC__site__c).add(mapContract.get(currLocation.SVMXC__Service_Contract__c));
            }
            
            if(!accountIds.isEmpty()){
                mapAccountContractList = new Map<Id,List<SVMXC__Service_Contract__c>>();
                for(Id contractID : mapContract.keySet()){
                    Id accId = mapContract.get(contractID).SVMXC__Company__c;
                    if(accId != null && accountIds.contains(accId)){
                        List<SVMXC__Service_Contract__c> tempList = new List<SVMXC__Service_Contract__c>();
                        if(mapAccountContractList.containsKey(accId)){
                            tempList = mapAccountContractList.get(accId);
                        }
                        tempList.add(mapContract.get(contractID));
                        mapAccountContractList.put(accId,tempList);
                    }
                }
            }

            mapContract.clear();
            mapEntitledLocation.clear();
            
            if(strWhereClouseProductWarranty != null)
            {
                system.debug('wOLineIBs : ' + wOLineIBs);         
                mapProductWarranty.putALL((list<SVMXC__Warranty__c>)database.Query('select Id, Name, SVMXC__Start_Date__c, SVMXC__End_Date__c, SVMXC__Installed_Product__c,SVMXC__Service_Template__c from SVMXC__Warranty__c where ' + strWhereClouseProductWarranty));
                for(SVMXC__Warranty__c oPW :mapProductWarranty.Values())
                {
                    if(!mapIBProductWarranty.ContainsKey(oPW.SVMXC__Installed_Product__c))
                        mapIBProductWarranty.put(oPW.SVMXC__Installed_Product__c, new list<SVMXC__Warranty__c>());
                    mapIBProductWarranty.get(oPW.SVMXC__Installed_Product__c).add(oPW);
                }                
            }
            
            for(Id IdIB :mapComponent.KeySet())
            {
                //SVMXC__ServiceMax_Processes__c oEntRule = mapEntRules.get(mapWOEntRule.get(mapIBWOIndex.get(IdIB))); 
                //if(oEntRule != null && (oEntRule.SVMXC__Entitlement_By__c == 'Counters' || oEntRule.SVMXC__Entitlement_By__c == 'Both' ))
                //{
                    updateCounterMaps(IdIB);
                    if(mapParentIB.containsKey(IdIB) && mapParentIB.get(IdIB) != null){
                        updateCounterMaps(mapParentIB.get(IdIB));
                    }
                    if(mapTopLevelIB.containsKey(IdIB) && mapTopLevelIB.get(IdIB) != null){
                        updateCounterMaps(mapTopLevelIB.get(IdIB));    
                    }
                    
                //}
            }
            
            
            if(strWhereClouseServiceContract != null)
            {
                system.debug('strWhereClouseServiceContract='+strWhereClouseServiceContract);
                mapServiceContractCoverageIB.putAll((list<SVMXC__Service_Contract_Products__c>)database.Query('select Id, SVMXC__Service_Contract__r.SVMXC__Start_Date__c , SVMXC__Service_Contract__r.SVMXC__End_Date__c, SVMXC__Service_Contract__r.Name, SVMXC__Service_Contract__r.SVMXC__Service_Level__c, SVMXC__Service_Contract__r.SVMXC__Company__c, SVMXC__Installed_Product__c, SVMXC__Service_Contract__c, SVMXC__Start_Date__c, SVMXC__End_Date__c, SVMXC__SLA_Terms__c from SVMXC__Service_Contract_Products__c where SVMXC__Service_Contract__r.SVMXC__Active__c = true AND (' + strWhereClouseServiceContract + ')'));
                system.debug('mapServiceContractCoverageIB='+mapServiceContractCoverageIB);
                
                for(SVMXC__Service_Contract_Products__c oSC :mapServiceContractCoverageIB.Values())
                {
                    
                    if(!mapIBServiceContractCoverage.ContainsKey(oSC.SVMXC__Installed_Product__c))
                        mapIBServiceContractCoverage.put(oSC.SVMXC__Installed_Product__c, new list<SVMXC__Service_Contract_Products__c>());
                    mapIBServiceContractCoverage.get(oSC.SVMXC__Installed_Product__c).add(oSC);
                }
            }
            for(Integer iWOIndex = 0; iWOIndex < lstWrkOrdr.size(); iWOIndex++)
            {
                SVMXC__Service_Order__c objWO = lstWrkOrdr.get(iWOIndex);
                IsWOEntitled = false;
                 isdiabledEntitlementOnWo = false;
                Boolean onWorkOrder = true;
                if(mapWOEntRule.containsKey(iWOIndex))
                {
                    SVMXC__ServiceMax_Processes__c oEntRule = mapEntRules.get(mapWOEntRule.get(iWOIndex));
                    List<Id> componentsList = getcomponentOrderList(oEntRule,objWO.SVMXC__Component__c);
                   
                    if(performEntitlementOnWOMap.containskey(iWOIndex))
                        onWorkOrder = performEntitlementOnWOMap.get(iWOIndex);
                    EntitlementInfoWrapper entitlementInfoRec ;
                    System.debug('oEntRule :' + oEntRule);
                    if(oEntRule.SVMXC__Field_Name__c == 'Account' && objWO.SVMXC__Company__c != null){
                        if(onWorkOrder){
                            entitlementInfoRec = getAccServiceContractsOnValidityDates(objWO,oEntRule);  
                        }else if(wODetailLineMap.containsKey(objWO.Id) && wODetailLineMap.get(objWO.Id) != null){
                            getServiceContractOnDetailLines(oEntRule, wODetailLineMap.get(objWO.Id), 'AccountBased',objWO,iWOIndex); 
                        }    
                    }else if(oEntRule.SVMXC__Field_Name__c == 'Product'){ 
                        if(oEntRule.SVMXC__Entitlement_Scope__c == 'Warranties')
                        {
                            if(oEntRule.SVMXC__Entitlement_By__c == 'Both')
                            {
                                if(oEntRule.SVMXC__Counter_Vs_Dates_Rule__c == 'Whichever Is Valid')
                                {
                                    if(onWorkOrder){
                                        entitlementInfoRec = getWarrantyOnValidityDate(componentsList,objWO,oEntRule.SVMXC__SM_Disable_AutoEntitlement__c);
                                        if(entitlementInfoRec == null){
                                            entitlementInfoRec = getWarrantyOnCounters(componentsList,oEntRule.SVMXC__SM_Disable_AutoEntitlement__c);
                                        }  
                                    }else if(wODetailLineMap.containsKey(objWO.Id) && wODetailLineMap.get(objWO.Id) != null)
                                         getWarrantyOnDetailLines(oEntRule, wODetailLineMap.get(objWO.Id), 'Either',objWO);                                

                                }
                                else{
                                    if(onWorkOrder)
                                        entitlementInfoRec = getWarrantyOnBoth(componentsList,objWO,oEntRule.SVMXC__SM_Disable_AutoEntitlement__c);
                                    else if(wODetailLineMap.containsKey(objWO.Id) && wODetailLineMap.get(objWO.Id) != null)  
                                        getWarrantyOnDetailLines(oEntRule, wODetailLineMap.get(objWO.Id), 'Both',objWO);
                                }
                            }
                            else if(oEntRule.SVMXC__Entitlement_By__c == 'Counters'){ 
                                 if(onWorkOrder)
                                    entitlementInfoRec = getWarrantyOnCounters(componentsList,oEntRule.SVMXC__SM_Disable_AutoEntitlement__c);
                                 else if(wODetailLineMap.containsKey(objWO.Id) && wODetailLineMap.get(objWO.Id) != null)
                                    getWarrantyOnDetailLines(oEntRule, wODetailLineMap.get(objWO.Id), 'Counter',objWO);   
                            }
                            
                            else if(oEntRule.SVMXC__Entitlement_By__c == 'Validity dates'){
                                if(onWorkOrder)
                                    entitlementInfoRec = getWarrantyOnValidityDate(componentsList,objWO,oEntRule.SVMXC__SM_Disable_AutoEntitlement__c);
                                else if(wODetailLineMap.containsKey(objWO.Id) && wODetailLineMap.get(objWO.Id) != null)
                                  getWarrantyOnDetailLines(oEntRule, wODetailLineMap.get(objWO.Id), 'Validity',objWO);                             
                            }
                        }
                        else if(oEntRule.SVMXC__Entitlement_Scope__c == 'Service Contracts')
                        {
                            //SVMXC__Service_Contract_Products__c serviceContractProductRecord; 
                            SVMXC__Service_Contract__c serviceContractRecord;
                            if(oEntRule.SVMXC__Entitlement_By__c == 'Both')
                            {
                                if(oEntRule.SVMXC__Counter_Vs_Dates_Rule__c == 'Whichever Is Valid')
                                {
                                    if(onWorkOrder){
                                        entitlementInfoRec = getServiceContractOnValidityDate(componentsList,oEntRule,objWO,iWOIndex);
                                        if(entitlementInfoRec == null)
                                            entitlementInfoRec = getServiceContractOnCounters(componentsList,oEntRule,objWO,iWOIndex);
                                    }else if(wODetailLineMap.containsKey(objWO.Id) && wODetailLineMap.get(objWO.Id) != null)   
                                        getServiceContractOnDetailLines(oEntRule, wODetailLineMap.get(objWO.Id), 'Either',objWO,iWOIndex);                             
                                }
                                else if(oEntRule.SVMXC__Counter_Vs_Dates_Rule__c == 'Both Are Valid'){
                                    if(onWorkOrder){
                                        entitlementInfoRec = getServiceContractOnBoth(componentsList,oEntRule,objWO, iWOIndex);
                                    }else if(wODetailLineMap.containsKey(objWO.Id) && wODetailLineMap.get(objWO.Id) != null)   
                                        getServiceContractOnDetailLines(oEntRule, wODetailLineMap.get(objWO.Id), 'Both',objWO,iWOIndex);                             
                                }   
                            }
                            else if(oEntRule.SVMXC__Entitlement_By__c == 'Counters'){
                                    if(onWorkOrder)
                                        entitlementInfoRec = getServiceContractOnCounters(componentsList,oEntRule,objWO,iWOIndex);
                                    else if(wODetailLineMap.containsKey(objWO.Id) && wODetailLineMap.get(objWO.Id) != null)   
                                        getServiceContractOnDetailLines(oEntRule, wODetailLineMap.get(objWO.Id), 'Counter',objWO,iWOIndex);                             
                            }else if(oEntRule.SVMXC__Entitlement_By__c == 'Validity dates'){
                                if(onWorkOrder){
                                    entitlementInfoRec = getServiceContractOnValidityDate(componentsList,oEntRule,objWO,iWOIndex);
                                }
                                else if(wODetailLineMap.containsKey(objWO.Id) && wODetailLineMap.get(objWO.Id) != null)
                                    getServiceContractOnDetailLines(oEntRule, wODetailLineMap.get(objWO.Id), 'Validity',objWO,iWOIndex);                                     
                            }
                            /**//**/
                        } 
                        else if(oEntRule.SVMXC__Entitlement_Scope__c == 'Both')
                        {
                            if(oEntRule.SVMXC__Entitlement_By__c == 'Both')
                            {
                                if(oEntRule.SVMXC__Counter_Vs_Dates_Rule__c == 'Whichever Is Valid')
                                {
                                    if(oEntRule.SVMXC__Pick_First_Match__c == 'Service Contract')
                                    {
                                        if(onWorkOrder){
                                            entitlementInfoRec = getServiceContractOnValidityDate(componentsList,oEntRule,objWO,iWOIndex);
                                            if(entitlementInfoRec == null)
                                                entitlementInfoRec = getServiceContractOnCounters(componentsList,oEntRule,objWO,iWOIndex);
                                            if(entitlementInfoRec == null)
                                                entitlementInfoRec = getWarrantyOnValidityDate(componentsList,objWO,oEntRule.SVMXC__SM_Disable_AutoEntitlement__c);
                                            if(entitlementInfoRec == null)
                                                entitlementInfoRec = getWarrantyOnCounters(componentsList,oEntRule.SVMXC__SM_Disable_AutoEntitlement__c);
                                        }else if(wODetailLineMap.containsKey(objWO.Id) && wODetailLineMap.get(objWO.Id) != null)
                                            getSconOrWarrantyOnDetailLines(oEntRule, wODetailLineMap.get(objWO.Id), 'EitherFPScon', objWO,iWOIndex);    
                                    }
                                    else if(oEntRule.SVMXC__Pick_First_Match__c == 'Warranty')
                                    {
                                        if(onWorkOrder){
                                            entitlementInfoRec = getWarrantyOnValidityDate(componentsList,objWO,oEntRule.SVMXC__SM_Disable_AutoEntitlement__c);
                                            if(entitlementInfoRec == null)
                                                entitlementInfoRec = getWarrantyOnCounters(componentsList,oEntRule.SVMXC__SM_Disable_AutoEntitlement__c);
                                            if(entitlementInfoRec == null)
                                                entitlementInfoRec = getServiceContractOnValidityDate(componentsList,oEntRule,objWO,iWOIndex);
                                            if(entitlementInfoRec == null)
                                                entitlementInfoRec = getServiceContractOnCounters(componentsList, oEntRule,objWO, iWOIndex);
                                        }else if(wODetailLineMap.containsKey(objWO.Id) && wODetailLineMap.get(objWO.Id) != null)
                                            getSconOrWarrantyOnDetailLines(oEntRule, wODetailLineMap.get(objWO.Id), 'EitherFPWarranty', objWO,iWOIndex);        
                                    }
                                }
                                else if(oEntRule.SVMXC__Counter_Vs_Dates_Rule__c == 'Both Are Valid')
                                {
                                    if(oEntRule.SVMXC__Pick_First_Match__c == 'Service Contract')
                                    {
                                        if(onWorkOrder){
                                            entitlementInfoRec = getServiceContractOnBoth(componentsList,oEntRule,objWO,iWOIndex);
                                            if(entitlementInfoRec == null)
                                                entitlementInfoRec = getWarrantyOnBoth(componentsList,objWO,oEntRule.SVMXC__SM_Disable_AutoEntitlement__c);
                                        }else if(wODetailLineMap.containsKey(objWO.Id) && wODetailLineMap.get(objWO.Id) != null)   
                                            getSconOrWarrantyOnDetailLines(oEntRule, wODetailLineMap.get(objWO.Id), 'BothFPScon', objWO,iWOIndex);            
                                    }
                                    else if(oEntRule.SVMXC__Pick_First_Match__c == 'Warranty')
                                    {
                                        if(onWorkOrder){
                                            entitlementInfoRec = getWarrantyOnBoth(componentsList,objWO,oEntRule.SVMXC__SM_Disable_AutoEntitlement__c);
                                            if(entitlementInfoRec == null){
                                                entitlementInfoRec = getServiceContractOnBoth(componentsList, oEntRule,objWO,iWOIndex);
                                            }
                                        }else if(wODetailLineMap.containsKey(objWO.Id) && wODetailLineMap.get(objWO.Id) != null)
                                            getSconOrWarrantyOnDetailLines(oEntRule, wODetailLineMap.get(objWO.Id), 'BothFPWarranty', objWO,iWOIndex);                
                                    }
                                }
                            }
                            else if(oEntRule.SVMXC__Entitlement_By__c == 'Counters')
                            {
                                if(oEntRule.SVMXC__Pick_First_Match__c == 'Service Contract')
                                {
                                    if(onWorkOrder){
                                        entitlementInfoRec = getServiceContractOnCounters(componentsList,oEntRule,objWO,iWOIndex);
                                        if(entitlementInfoRec == null)
                                            entitlementInfoRec = getWarrantyOnCounters(componentsList,oEntRule.SVMXC__SM_Disable_AutoEntitlement__c);
                                    }else if(wODetailLineMap.containsKey(objWO.Id) && wODetailLineMap.get(objWO.Id) != null)
                                        getSconOrWarrantyOnDetailLines(oEntRule, wODetailLineMap.get(objWO.Id), 'CounterFPScon', objWO,iWOIndex);    
                                }
                                else if(oEntRule.SVMXC__Pick_First_Match__c == 'Warranty')
                                {
                                    if(onWorkOrder){
                                        entitlementInfoRec = getWarrantyOnCounters(componentsList,oEntRule.SVMXC__SM_Disable_AutoEntitlement__c);
                                        if(entitlementInfoRec == null)
                                            entitlementInfoRec = getServiceContractOnCounters(componentsList,oEntRule,objWO,iWOIndex);
                                    }else if(wODetailLineMap.containsKey(objWO.Id) && wODetailLineMap.get(objWO.Id) != null)
                                        getSconOrWarrantyOnDetailLines(oEntRule, wODetailLineMap.get(objWO.Id), 'CounterFPWarranty', objWO,iWOIndex);        
                                }
                            }
                            else if(oEntRule.SVMXC__Entitlement_By__c == 'Validity dates')
                            {
                                if(oEntRule.SVMXC__Pick_First_Match__c == 'Service Contract')
                                {
                                    if(onWorkOrder){
                                        entitlementInfoRec = getServiceContractOnValidityDate(componentsList,oEntRule,objWO,iWOIndex);
                                        if(entitlementInfoRec == null)
                                            entitlementInfoRec = getWarrantyOnValidityDate(componentsList,objWO,oEntRule.SVMXC__SM_Disable_AutoEntitlement__c);
                                    }else if(wODetailLineMap.containsKey(objWO.Id) && wODetailLineMap.get(objWO.Id) != null)
                                        getSconOrWarrantyOnDetailLines(oEntRule, wODetailLineMap.get(objWO.Id), 'ValidityFPScon', objWO,iWOIndex);            
                                }
                                else if(oEntRule.SVMXC__Pick_First_Match__c == 'Warranty')
                                {
                                    if(onWorkOrder){
                                        entitlementInfoRec = getWarrantyOnValidityDate(componentsList,objWO,oEntRule.SVMXC__SM_Disable_AutoEntitlement__c);
                                        if(entitlementInfoRec == null)
                                            entitlementInfoRec = getServiceContractOnValidityDate(componentsList,oEntRule,objWO,iWOIndex);
                                    }else if(wODetailLineMap.containsKey(objWO.Id) && wODetailLineMap.get(objWO.Id) != null)
                                        getSconOrWarrantyOnDetailLines(oEntRule, wODetailLineMap.get(objWO.Id), 'ValidityFPWarranty', objWO,iWOIndex);            
                                }
                            }
                        }
                    }                    
                    if(onWorkOrder && entitlementInfoRec != null){
                        entitlementInfoRec.ruleName = oEntRule.SVMXC__Name__c;
                        objWO = updateWOEntitlementInfo(objWO,entitlementInfoRec);
                    }        
                    objWO.SVMXC__Perform_Auto_Entitlement__c = false;
                    if(onWorkOrder){
                        objWO.SVMXC__Is_Entitlement_Performed__c = true;
                        if(!IsWOEntitled)
                        {
                            if(isWebServiceCall)
                                    mapWOIDnSucess.put(objWO.Id,'Failed');
                            //Following If condition added by NIDHI as part of BAC-4638                            
                            if( isdiabledEntitlementOnWo){
                                //This is the scenario when multiple warranties/service contracts exist on the Work Order, and user chooses to disable auto-entitlement.
                                //update following fields on work order
                                objWO.SVMXC__Auto_Entitlement_Status__c = 'Failed';
                                objWO.SVMXC__Entitlement_Notes__c = 'Work Order has Multiple Valid Entitlements';
                                objWO.SVMXC__Entitlement_Type__c = 'AUTO';
                                objWO.SVMXC__Warranty__c = null;
                                objWO.SVMXC__Service_Contract__c = null;
                                objWO.SVMXC__SLA_Terms__c = null;
                                objWO.SVMXC__Is_Entitlement_Performed__c = false;
                                if(SetBillingType && billingTypeValue != null)
                                   objWO.SVMXC__Billing_Type__c = billingTypeValue; 
                                objWO.SVMXC__Is_Service_Covered__c = false;
                            }else{
                                objWO.SVMXC__Warranty__c = null;
                                objWO.SVMXC__Service_Contract__c = null;
                                objWO.SVMXC__SLA_Terms__c = null;
                                objWO.SVMXC__Entitlement_Notes__c = '';
                                objWO.SVMXC__Auto_Entitlement_Status__c = 'Failed';
                                if(SetBillingType && billingTypeValue != null)
                                   objWO.SVMXC__Billing_Type__c = billingTypeValue; 
                                objWO.SVMXC__Is_Service_Covered__c = false;
                            }
                        }else{
                            if(isWebServiceCall)
                                mapWOIDnSucess.put(objWO.Id,'Success');
                            objWO.SVMXC__Entitlement_Type__c = 'AUTO';
                            objWO.SVMXC__Auto_Entitlement_Status__c = 'Success';
                            if(objWO.SVMXC__Service_Contract__c != null)
                                setContractIds.add(objWO.SVMXC__Service_Contract__c);
                        }
                        /*if(wODetailLineMap.containsKey(objWO.Id) && wODetailLineMap.get(objWO.Id) != null){
                            for(SVMXC__Service_Order_Line__c wDetailRec : wODetailLineMap.get(objWO.Id)){
                                //wDetailRec.SVMXC__Auto_Entitlement_Status__c = '';
                                productServicedLines.add(wDetailRec); 
                            }
                        } */                         
                    }
                }else{
                    if(objWO.SVMXC__Perform_Auto_Entitlement__c){
                        objWO.SVMXC__Perform_Auto_Entitlement__c = false;
                        if(onWorkOrder){
                            objWO.SVMXC__Is_Entitlement_Performed__c = true;
                            objWO.SVMXC__Warranty__c = null;
                            objWO.SVMXC__Service_Contract__c = null;
                            objWO.SVMXC__SLA_Terms__c = null;
                            objWO.SVMXC__Entitlement_Notes__c = '';
                            objWO.SVMXC__Auto_Entitlement_Status__c = 'Failed';
                            if(SetBillingType && billingTypeValue != null)
                                objWO.SVMXC__Billing_Type__c = billingTypeValue;                         
                            objWO.SVMXC__Is_Service_Covered__c = false;
                        }else{
                            if(wODetailLineMap.containsKey(objWO.Id) && wODetailLineMap.get(objWO.Id) != null){
                                for(SVMXC__Service_Order_Line__c wDetailRec : wODetailLineMap.get(objWO.Id)){
                                    //wDetailRec.SVMXC__Auto_Entitlement_Status__c = 'Failed';
                                    wDetailRec.SVMXC__Is_Entitlement_Performed__c = true;
                                    productServicedLines.add(wDetailRec); 
                                }
                            }     
                        }                   
                    }                      
                }
            }
            
            System.debug( 'Product Serviced List : ' + productServicedLines);
            //Enhancement: Update Threshold Count.
            if(mapSettings.containsKey('EVER007_SET004') && mapSettings.get('EVER007_SET004').toUpperCase() == 'TRUE')
            {
                map<integer, map<string,string>> mapWO_Status  = new map<integer, map<string,string>>(); 
                map<integer,string> mapIndexdWOService  = new map<integer,string>();
                map<string,SVMXC__Service_Contract_Services__c> mapEntitledService = new map<string,SVMXC__Service_Contract_Services__c>();  
                //set<string> setContractIds = new set<string>();
                /* for(integer i=0; i< lstWrkOrdr.size(); i++)
                {
                    mapIndexdWO.put(i,lstWrkOrdr[i]);
                    if(lstWrkOrdr[i].SVMXC__Service_Contract__c != null)
                    setContractIds.add(lstWrkOrdr[i].SVMXC__Service_Contract__c);
                } */
                
                // Identify the Covered service available in Service Contract for Work Order rec(s) by calling identifyServicesForIndexedRecs method.
                mapIndexdWOService  = new EVER_Entitlement_Utils().identifyServicesForIndexedRecs(null, mapWO);
                
                // If Service is available for list of Work Order, pass map of Work Order and applicable exp rule to manage threshold.
                if(mapIndexdWOService != null && mapIndexdWOService.size() > 0)
                {
                    mapWO_Status = new EVER_Entitlement_Utils().manageServiceThresholdCount(null, lstWrkOrdr, mapIndexdWOService);
                    if(setContractIds != null && setContractIds.size() > 0){
                        mapEntitledService.putAll([Select Id, Name, SVMXC__Service_Contract__c from SVMXC__Service_Contract_Services__c where Id IN: mapIndexdWOService.values() AND SVMXC__Service_Contract__c IN: setContractIds]);
                    }
                }
                system.debug('Work Order index with Service: '+mapIndexdWOService);
                system.debug('Work Order index with Status: '+mapWO_Status);
              
                for(integer index : mapWO.keySet())
                {
                    if((mapWO.get(index)).SVMXC__Service_Contract__c != null)
                    {
                        if(mapWO_Status.containsKey(index) && mapWO_Status.get(index) != null)
                        {
                            set<string> setIncludedServiceId = mapWO_Status.get(index).keySet();
                            list<string> lstStatus =  mapWO_Status.get(index).values();
                            if(setIncludedServiceId != null && setIncludedServiceId.size() == 1 && lstStatus != null && lstStatus.size() == 1)
                            {
                                if(mapEntitledService != null && mapEntitledService.get((mapIndexdWOService.get(index))) != null)
                                mapWO.get(index).SVMXC__Entitlement_Notes__c += '\nService Consumed: ' +  mapEntitledService.get(string.valueOf((mapIndexdWOService.get(index)))).Name;
                                if(lstStatus[0] == 'NOT_APPLICABLE')
                                mapWO.get(index).SVMXC__Is_Service_Covered__c = false;
                                else
                                mapWO.get(index).SVMXC__Is_Service_Covered__c = true;      
                            }
                            else
                                mapWO.get(index).SVMXC__Is_Service_Covered__c = false;
                        }
                        else
                            mapWO.get(index).SVMXC__Is_Service_Covered__c = false;
                    }
                    else
                        mapWO.get(index).SVMXC__Is_Service_Covered__c = false;
                }
            }
        }
    }


    public void SVMX_UpdateEntitlementHistory(list<SVMXC__Service_Order__c> lstNewWO, list<SVMXC__Service_Order__c> lstOldWO, Map<String, String> mapSettings)
    {
        system.debug('WOId - Perform Entitlememt Map: ' + mapWOIdCheckEntitlement + mapWOIndexCheckEntitlement);
        list<SVMXC__Entitlement_History__c> lstNewEntitlementHistory = new list<SVMXC__Entitlement_History__c>();
        set<Id> setWOId = new set<Id>();
        Set<Id> setWorkDetailIds = new Set<Id>();
        map<Id, Id> mapWOIdWarrantyId = new map<Id, Id>();
        map<Id, Id> mapWOIdServiceContractID = new map<Id, Id>();
        set<Id> setWarrantyId = new set<Id>();
        set<Id> setServiceContractId = new set<Id>();
        map<Id, SVMXC__Warranty__c> mapProductWarrantyHist = new map<Id, SVMXC__Warranty__c>();
        map<Id, SVMXC__Service_Contract__c> mapServiceContractHist = new map<Id, SVMXC__Service_Contract__c>();

        Map<Id,SVMXC__Service_Order_Line__c> newWOServiceLinesMap = new Map<Id,SVMXC__Service_Order_Line__c>(); 
        /* Defect(8660): Removed SVMXC__Inactive_Date__c = NULL from query to avoid SOQL Exception on high volume data, Since Total Entitlement History records (Entitlement History records queried below + new History reecord) will voilate the Governor Limit (more than 10000 DML Operations) */
        list<SVMXC__Entitlement_History__c> lstEntitlementHistory = new list<SVMXC__Entitlement_History__c>();                 

        if(mapSettings.containsKey('EVER007_SET001') && mapSettings.get('EVER007_SET001').toUpperCase() == 'TRUE')
        {
            for(integer iIndex = 0; iIndex < lstNewWO.size(); iIndex++)
            {
                SVMXC__Service_Order__c oOldWO;
                if(lstOldWO != null)
                    oOldWO = lstOldWO[iIndex];
                SVMXC__Service_Order__c oNewWO = lstNewWO[iIndex];
                
                /** Only enter below code section when Perform Entitlement is set to true for WO Record **/
                /*if((mapWOIdCheckEntitlement != NULL && mapWOIdCheckEntitlement.containsKey(oNewWO.Id) && mapWOIdCheckEntitlement.get(oNewWO.Id) == false) || (mapWOIndexCheckEntitlement != NULL && mapWOIndexCheckEntitlement.containsKey(iIndex) && mapWOIndexCheckEntitlement.get(iIndex) == false))
                    continue;*/

                //----Start-------Added for the defect fix 043858 and commented above line
                Boolean entitlementPerformedId = false;
                Boolean entitlementPerformedIndex = false;
                if(mapWOIdCheckEntitlement != NULL && mapWOIdCheckEntitlement.containsKey(oNewWO.Id)){
                    entitlementPerformedId = mapWOIdCheckEntitlement.get(oNewWO.Id);
                }
                if(mapWOIndexCheckEntitlement != NULL && mapWOIndexCheckEntitlement.containsKey(iIndex)){
                    entitlementPerformedIndex = mapWOIndexCheckEntitlement.get(iIndex);
                }
                if(!((entitlementPerformedId == true || entitlementPerformedIndex == true) && !(entitlementPerformedId == true && entitlementPerformedIndex == true))) {
                    continue;
                }
                //----End-------Added for the defect fix 043858 - Included below code in the if condition

                if(oOldWO == null && oNewWO.SVMXC__Entitlement_Type__c == 'AUTO' && !oNewWO.SVMXC__Perform_Auto_Entitlement__c)
                {
                    if(oNewWO.SVMXC__Warranty__c != null  || oNewWO.SVMXC__Service_Contract__c != null)
                    {
                        setWOId.add(oNewWO.Id);
                        if(oNewWO.SVMXC__Service_Contract__c != null)
                        {
                            setServiceContractId.add(oNewWO.SVMXC__Service_Contract__c);
                            mapWOIdServiceContractID.put(oNewWO.Id, oNewWO.SVMXC__Service_Contract__c);
                        }
                        if(oNewWO.SVMXC__Warranty__c != null)
                        {
                            setWarrantyId.add(oNewWO.SVMXC__Warranty__c);
                            mapWOIdWarrantyId.put(oNewWO.Id, oNewWO.SVMXC__Warranty__c);
                        }
                    }
                }
                else if(oNewWO.SVMXC__Entitlement_Type__c == 'AUTO' && oNewWO != null && oNewWO.Id != null && !oNewWO.SVMXC__Perform_Auto_Entitlement__c && ((oNewWO.SVMXC__Warranty__c != null && oNewWO.SVMXC__Warranty__c != oOldWO.SVMXC__Warranty__c)  || (oNewWO.SVMXC__Service_Contract__c != null )))
                {
                    setWOId.add(oNewWO.Id);
                    if(oNewWO.SVMXC__Service_Contract__c != null )
                    {
                        setServiceContractId.add(oNewWO.SVMXC__Service_Contract__c);
                        mapWOIdServiceContractID.put(oNewWO.Id, oNewWO.SVMXC__Service_Contract__c);
                    }
                    if(oNewWO.SVMXC__Warranty__c != null && oNewWO.SVMXC__Warranty__c != oOldWO.SVMXC__Warranty__c)
                    {
                        setWarrantyId.add(oNewWO.SVMXC__Warranty__c);
                        mapWOIdWarrantyId.put(oNewWO.Id, oNewWO.SVMXC__Warranty__c);
                    }
                }

                if(!productServicedLines.isEmpty()){
                    for(SVMXC__Service_Order_Line__c orderLine : productServicedLines){
                        newWOServiceLinesMap.put(orderLine.Id,orderLine); 
                        setWorkDetailIds.add(orderLine.Id);   
                        if(orderLine.SVMXC__Product_Warranty__c != null && (orderLine.SVMXC__Product_Warranty__c == oldWOServiceLinesMap.get(orderLine.Id).SVMXC__Product_Warranty__c))
                           setWorkDetailIds.remove(orderLine.Id);   
                    }                
                }

            }
            System.debug(Logginglevel.info, 'setWOId : '+setWOId + ' setWorkDetailIds : ' + setWorkDetailIds);
            if(setWOId.size() > 0 || setWorkDetailIds.size() > 0)
            {
                if(setWOId.contains(null))
                    setWOId.remove(null);
                    
                map<Id, list<SVMXC__Entitlement_History__c>> mapEntitlementHistory = new map<Id, list<SVMXC__Entitlement_History__c>>();
                if(setWarrantyId != null && setWarrantyId.size() > 0){
                    mapProductWarrantyHist.putALL([select Id, Name, SVMXC__Start_Date__c, SVMXC__End_Date__c from SVMXC__Warranty__c where ID IN :setWarrantyId]);
                }
                if(setServiceContractId != null && setServiceContractId.size() > 0){
                    mapServiceContractHist.putAll([select Id, Name, SVMXC__Start_Date__c, SVMXC__End_Date__c, SVMXC__Service_Level__c from SVMXC__Service_Contract__c where Id IN :setServiceContractId]);
                }
                

                lstEntitlementHistory = [select id, SVMXC__Inactive_Date__c from SVMXC__Entitlement_History__c where (SVMXC__Service_Order__c in :setWOId OR SVMXC__Work_Detail__c IN : setWorkDetailIds) AND SVMXC__Inactive_Date__c = NULL];// ASC NULLS FIRST Limit 5000];
                 //Enhancement.
                map<string,string> mapWOService  = new map<string,string>();
                map<string, map<string,string>> mapWO_Status  = new map<string, map<string,string>>(); 
                System.debug('EVER007_SET004 : '+mapSettings.get('EVER007_SET004').toUpperCase());
                if(mapSettings.containsKey('EVER007_SET004') && mapSettings.get('EVER007_SET004').toUpperCase() == 'TRUE')
                {
                    // Identify the Covered service available in Service Contract for Work Order rec(s) by calling identifyServicesForIndexedRecs method.
                    mapWOService  = new EVER_Entitlement_Utils().identifyServiceForWorkOrder(lstNewWO);
                    // Pass map of Work Order and applicable exp rule to manage threshold.
                    mapWO_Status = new EVER_Entitlement_Utils().manageServiceThresholdCount(lstNewWO, mapWOService, true);
                    system.debug('mapWO_Status : '+mapWO_Status);
                }

                for(SVMXC__Entitlement_History__c oEntHistory :lstEntitlementHistory)
                {
                    oEntHistory.SVMXC__Date_of_entitlement__c = date.Today();
                    oEntHistory.SVMXC__Inactive_Date__c = date.Today(); //Added During the Entitlement Enhancement.
                }
                for(integer iIndex = 0; iIndex < lstNewWO.size(); iIndex++)
                {
                    boolean IsServiceCovered = true; // Variable to check Is service Covrered?
                    SVMXC__Service_Order__c oOldWO;
                    if(lstOldWO != null)
                        oOldWO = lstOldWO[iIndex];
                    SVMXC__Service_Order__c oNewWO = lstNewWO[iIndex];
                    
                    /** Only enter below code section when Perform Entitlement is set to true for WO Record **/
                    /*if((mapWOIdCheckEntitlement != NULL && mapWOIdCheckEntitlement.containsKey(oNewWO.Id) && mapWOIdCheckEntitlement.get(oNewWO.Id) == false) || (mapWOIndexCheckEntitlement != NULL && mapWOIndexCheckEntitlement.containsKey(iIndex) && mapWOIndexCheckEntitlement.get(iIndex) == false))
                        continue;*/
                    
                    //----Start-------Added for the defect fix 043858 and commented above line
                    Boolean innerEntitlementPerformedId = false;
                    Boolean innerEntitlementPerformedIndex = false;
                    if(mapWOIdCheckEntitlement != NULL && mapWOIdCheckEntitlement.containsKey(oNewWO.Id)){
                        innerEntitlementPerformedId = mapWOIdCheckEntitlement.get(oNewWO.Id);
                    }
                    if(mapWOIndexCheckEntitlement != NULL && mapWOIndexCheckEntitlement.containsKey(iIndex)){
                        innerEntitlementPerformedIndex = mapWOIndexCheckEntitlement.get(iIndex);
                    }
                    if(!((innerEntitlementPerformedId == true || innerEntitlementPerformedIndex == true) && !(innerEntitlementPerformedId == true && innerEntitlementPerformedIndex == true))) {
                        continue;
                    }
                    //----End---------Added for the defect fix 043858

                    if(oOldWO == null)
                    {
                        if(oNewWO.SVMXC__Warranty__c != null  || oNewWO.SVMXC__Service_Contract__c != null)
                        {
                            if(oNewWO.SVMXC__Warranty__c != null )
                            {
                                SVMXC__Entitlement_History__c oEntitlementHistory = new SVMXC__Entitlement_History__c();
                                oEntitlementHistory.SVMXC__Service_Order__c = oNewWO.Id;
                                oEntitlementHistory.SVMXC__Date_of_Entitlement__c = date.Today();
                                Id WarrantyId = mapWOIdWarrantyId.get(oNewWO.Id);
                                oEntitlementHistory.SVMXC__Warranty__c = WarrantyId;
                                SVMXC__Warranty__c oPW = mapProductWarrantyHist.get(WarrantyId);
                                oEntitlementHistory.SVMXC__Start_Date__c = oPW.SVMXC__Start_Date__c; 
                                oEntitlementHistory.SVMXC__End_Date__c = oPW.SVMXC__End_Date__c;
                                oEntitlementHistory.SVMXC__Entitlement_Notes__c = oNewWO.SVMXC__Entitlement_Notes__c;/*'Entitled by ServiceMax auto-entitlement process.'+
                                                                                    '\nWarranty:' + oPW.Name + 
                                                                                    '\nStart Date:' + oPW.SVMXC__Start_Date__c +
                                                                                    '\nEnd Date:' + oPW.SVMXC__End_Date__c ;*/
                                lstNewEntitlementHistory.add(oEntitlementHistory);
                                
                            }
                            if(oNewWO.SVMXC__Service_Contract__c != null)
                            {
                                SVMXC__Entitlement_History__c oEntitlementHistory = new SVMXC__Entitlement_History__c();
                                oEntitlementHistory.SVMXC__Service_Order__c = oNewWO.Id;
                                
                                //Enhancement Code start..
                                if(mapSettings.containsKey('EVER007_SET004') && mapSettings.get('EVER007_SET004').toUpperCase() == 'TRUE')
                                {
                                    if(mapWO_Status.containsKey(oNewWO.Id) && mapWO_Status.get(oNewWO.Id) != null)
                                    {
                                      set<string> setIncludedServiceId = mapWO_Status.get(oNewWO.Id).keySet();
                                      list<string> lstStatus =  mapWO_Status.get(oNewWO.Id).values();
                                      if(setIncludedServiceId != null && setIncludedServiceId.size() == 1 && lstStatus != null && lstStatus.size() == 1)
                                      {
                                        if(lstStatus[0] == 'NOT_APPLICABLE')
                                        {
                                          oEntitlementHistory.SVMXC__Entitled_Within_Threshold__c = false;
                                          IsServiceCovered = false;
                                        }
                                        else
                                        {
                                          for(string currId : setIncludedServiceId)
                                            oEntitlementHistory.SVMXC__Entitled_By_Service__c = currId;
                                          if(lstStatus[0] == 'WITHIN_THRESHOLD')
                                               oEntitlementHistory.SVMXC__Entitled_Within_Threshold__c = true;
                                             else if(lstStatus[0] == 'OUTSIDE_THRESHOLD' || lstStatus[0] == 'NOT_APPLICABLE')
                                              {
                                                oEntitlementHistory.SVMXC__Entitled_Within_Threshold__c = false;
                                            }
                                        }
                                      }
                                    }
                                }

                                //Enhancement Code end.
                                oEntitlementHistory.SVMXC__Date_of_Entitlement__c = date.Today();
                                Id ServiceContractId = mapWOIdServiceContractID.get(oNewWO.Id);
                                oEntitlementHistory.SVMXC__Service_Contract__c = ServiceContractId;
                                SVMXC__Service_Contract__c oSC = mapServiceContractHist.get(ServiceContractId);
                                //If WO is entitled by Coverd Product, then populate the start and end date from Service Contract's Covered Product
                                if(mapWOIndexContractIBCvrg != NULL && mapWOIndexContractIBCvrg.containsKey(iIndex) && mapWOIndexContractIBCvrg.get(iIndex) != NULL)
                                {
                                    SVMXC__Service_Contract_Products__c objCoveredProduct = new SVMXC__Service_Contract_Products__c();
                                    objCoveredProduct = mapWOIndexContractIBCvrg.get(iIndex);
                                    oEntitlementHistory.SVMXC__Start_Date__c = getStartDate(objCoveredProduct);
                                    oEntitlementHistory.SVMXC__End_Date__c = getEndDate(objCoveredProduct);
                                    /*if(objCoveredProduct.SVMXC__SLA_Terms__c != NULL)
                                        oEntitlementHistory.SVMXC__SLA_Terms__c = objCoveredProduct.SVMXC__SLA_Terms__c;
                                    else
                                        oEntitlementHistory.SVMXC__SLA_Terms__c = oSC.SVMXC__Service_Level__c;
                                    */
                                    oEntitlementHistory.SVMXC__SLA_Terms__c = oNewWO.SVMXC__SLA_Terms__c;
                                }
                                else
                                {
                                    oEntitlementHistory.SVMXC__Start_Date__c = oSC.SVMXC__Start_Date__c; 
                                    oEntitlementHistory.SVMXC__End_Date__c = oSC.SVMXC__End_Date__c;
                                    oEntitlementHistory.SVMXC__SLA_Terms__c = oSC.SVMXC__Service_Level__c;
                                }
                    
                                oEntitlementHistory.SVMXC__Entitlement_Notes__c = oNewWO.SVMXC__Entitlement_Notes__c;/*'Entitled by ServiceMax auto-entitlement process.'+
                                                                                    '\nService Contract:' + oSC.Name + 
                                                                                    '\nStart Date:' + oSC.SVMXC__Start_Date__c +
                                                                                    '\nEnd Date:' + oSC.SVMXC__End_Date__c ;*/
                                lstNewEntitlementHistory.add(oEntitlementHistory);
                            }
                            
                        }
                    }
                    else if(oNewWO.SVMXC__Entitlement_Type__c == 'AUTO' && oNewWO != null && oNewWO.Id != null && !oNewWO.SVMXC__Perform_Auto_Entitlement__c && ((oNewWO.SVMXC__Warranty__c != null && oNewWO.SVMXC__Warranty__c != oOldWO.SVMXC__Warranty__c)  || (oNewWO.SVMXC__Service_Contract__c != null )))
                    {
                        if(oNewWO.SVMXC__Warranty__c != null  || oNewWO.SVMXC__Service_Contract__c != null)
                        {
                            if(oNewWO.SVMXC__Warranty__c != null && oNewWO.SVMXC__Warranty__c != oOldWO.SVMXC__Warranty__c)
                            {
                                SVMXC__Entitlement_History__c oEntitlementHistory = new SVMXC__Entitlement_History__c();
                                oEntitlementHistory.SVMXC__Service_Order__c = oNewWO.Id;
                                oEntitlementHistory.SVMXC__Date_of_Entitlement__c = date.Today();
                                Id WarrantyId = mapWOIdWarrantyId.get(oNewWO.Id);
                                oEntitlementHistory.SVMXC__Warranty__c = WarrantyId;
                                SVMXC__Warranty__c oPW = mapProductWarrantyHist.get(WarrantyId);
                                oEntitlementHistory.SVMXC__Start_Date__c = oPW.SVMXC__Start_Date__c; 
                                oEntitlementHistory.SVMXC__End_Date__c = oPW.SVMXC__End_Date__c;
                                oEntitlementHistory.SVMXC__Entitlement_Notes__c = oNewWO.SVMXC__Entitlement_Notes__c;/*'Entitled by ServiceMax auto-entitlement process.'+
                                                                                    '\nWarranty:' + oPW.Name + 
                                                                                    '\nStart Date:' + oPW.SVMXC__Start_Date__c +
                                                                                    '\nEnd Date:' + oPW.SVMXC__End_Date__c ;*/
                                lstNewEntitlementHistory.add(oEntitlementHistory);
                            }
                            if(oNewWO.SVMXC__Service_Contract__c != null )
                            {
                                SVMXC__Entitlement_History__c oEntitlementHistory = new SVMXC__Entitlement_History__c();
                                oEntitlementHistory.SVMXC__Service_Order__c = oNewWO.Id;
                                
                                
                                //Enhancement Code start..
                                if(mapWO_Status.containsKey(oNewWO.Id) && mapWO_Status.get(oNewWO.Id) != null)
                                {
                                    set<string> setIncludedServiceId = mapWO_Status.get(oNewWO.Id).keySet();
                                    list<string> lstStatus =  mapWO_Status.get(oNewWO.Id).values();
                                    if(setIncludedServiceId != null && setIncludedServiceId.size() == 1 && lstStatus != null && lstStatus.size() == 1)
                                    {
                                        if(lstStatus[0] == 'NOT_APPLICABLE')
                                        {
                                            oEntitlementHistory.SVMXC__Entitled_Within_Threshold__c = false;
                                            IsServiceCovered = false;
                                        }
                                        else
                                        {
                                            for(string currId : setIncludedServiceId)
                                                oEntitlementHistory.SVMXC__Entitled_By_Service__c = currId;
                                            if(lstStatus[0] == 'WITHIN_THRESHOLD')
                                                oEntitlementHistory.SVMXC__Entitled_Within_Threshold__c = true;
                                            else if(lstStatus[0] == 'OUTSIDE_THRESHOLD' || lstStatus[0] == 'NOT_APPLICABLE')
                                                oEntitlementHistory.SVMXC__Entitled_Within_Threshold__c = false;
                                        }
                                    }
                                }
                                
                        //Enhancement Code end.
                                
                                oEntitlementHistory.SVMXC__Date_of_Entitlement__c = date.Today();
                                Id ServiceContractId = mapWOIdServiceContractID.get(oNewWO.Id);
                                oEntitlementHistory.SVMXC__Service_Contract__c = ServiceContractId;
                                SVMXC__Service_Contract__c oSC = mapServiceContractHist.get(ServiceContractId);
                                //If WO is entitled by Coverd Product, then populate the start and end date from Service Contract's Covered Product
                                if(mapWOIndexContractIBCvrg != NULL && mapWOIndexContractIBCvrg.containsKey(iIndex) && mapWOIndexContractIBCvrg.get(iIndex) != NULL)
                                {
                                    SVMXC__Service_Contract_Products__c objCoveredProduct = new SVMXC__Service_Contract_Products__c();
                                    objCoveredProduct = mapWOIndexContractIBCvrg.get(iIndex);
                                    oEntitlementHistory.SVMXC__Start_Date__c = getStartDate(objCoveredProduct);
                                    oEntitlementHistory.SVMXC__End_Date__c = getEndDate(objCoveredProduct);
                                    /*if(objCoveredProduct.SVMXC__SLA_Terms__c != NULL)
                                        oEntitlementHistory.SVMXC__SLA_Terms__c = objCoveredProduct.SVMXC__SLA_Terms__c;
                                    else
                                        oEntitlementHistory.SVMXC__SLA_Terms__c = oSC.SVMXC__Service_Level__c;
                                    */
                                    oEntitlementHistory.SVMXC__SLA_Terms__c = oNewWO.SVMXC__SLA_Terms__c;
                                }
                                else
                                {
                                    oEntitlementHistory.SVMXC__Start_Date__c = oSC.SVMXC__Start_Date__c; 
                                    oEntitlementHistory.SVMXC__End_Date__c = oSC.SVMXC__End_Date__c;
                                    oEntitlementHistory.SVMXC__SLA_Terms__c = oSC.SVMXC__Service_Level__c;
                                }
                                
                                
                                oEntitlementHistory.SVMXC__Entitlement_Notes__c = oNewWO.SVMXC__Entitlement_Notes__c;/*'Entitled by ServiceMax auto-entitlement process.'+
                                                                                    '\nService Contract:' + oSC.Name + 
                                                                                    '\nStart Date:' + oSC.SVMXC__Start_Date__c +
                                                                                    '\nEnd Date:' + oSC.SVMXC__End_Date__c ;*/
                                lstNewEntitlementHistory.add(oEntitlementHistory);
                            }
                        }
                    }
                }
            }

            List<SVMXC__Entitlement_History__c> entHistoryListForWOLines = createEntitlementHistoryForWOLines(newWOServiceLinesMap);
            
            if(lstNewEntitlementHistory != null)
            {
                if(lstEntitlementHistory != null)
                    lstNewEntitlementHistory.addAll(lstEntitlementHistory);
                if(!entHistoryListForWOLines.isEmpty())
                   lstNewEntitlementHistory.addAll(entHistoryListForWOLines);  
                 if(COMM_SecurityUtils.getInstance().verifyFieldAccess(lstNewEntitlementHistory, COMM_SecurityUtils.Access.Upsertable)){
                     //SDL-SVM-CREATE-UPDATE-FLS-ENFORCED
                   upsert lstNewEntitlementHistory;
                }
                else{
                    throw new COMM_SecurityUtils.SecurityAccessException( System.Label.COMM001_TAG142 );
                } 
                
            }
            else
            {
                if(lstEntitlementHistory != null){
                    if(!entHistoryListForWOLines.isEmpty())
                        lstEntitlementHistory.addAll(entHistoryListForWOLines);
                    if(COMM_SecurityUtils.getInstance().verifyFieldAccess(lstEntitlementHistory, COMM_SecurityUtils.Access.Upsertable)){
                        //SDL-SVM-CREATE-UPDATE-FLS-ENFORCED
                        upsert lstEntitlementHistory;
                    }
                    else{
                        throw new COMM_SecurityUtils.SecurityAccessException( System.Label.COMM001_TAG142 );
                    } 
                   
                }
            }             
        }
    }

    public List<SVMXC__Entitlement_History__c> createEntitlementHistoryForWOLines(Map<Id,SVMXC__Service_Order_Line__c> newWOServiceLinesMap){
        List<SVMXC__Entitlement_History__c> entHistoryList = new List<SVMXC__Entitlement_History__c>();
        for(Id wDId : newWOServiceLinesMap.keySet()){
            SVMXC__Entitlement_History__c oEntitlementHistory;
            SVMXC__Service_Order_Line__c wOLine = newWOServiceLinesMap.get(wDId);
            System.debug(Logginglevel.info,'oldWOServiceLinesMap : ' + oldWOServiceLinesMap);
            if(!oldWOServiceLinesMap.Containskey(wDId)){
                oEntitlementHistory = createHistoryRecord(wOLine);
            }else{
                if(wOLine.SVMXC__Product_Warranty__c != null || woLine.SVMXC__Service_Maintenance_Contract__c != null){
                    if(wOLine.SVMXC__Product_Warranty__c != null && (wOLine.SVMXC__Product_Warranty__c != oldWOServiceLinesMap.get(wOLine.Id).SVMXC__Product_Warranty__c))
                        oEntitlementHistory = createHistoryRecord(wOLine);  
                    if(woLine.SVMXC__Service_Maintenance_Contract__c != null)  
                        oEntitlementHistory = createHistoryRecord(wOLine);          
                }  
            }
            if(oEntitlementHistory != null)
               entHistoryList.add(oEntitlementHistory); 
        }
        return entHistoryList;
    }

    public SVMXC__Entitlement_History__c createHistoryRecord(SVMXC__Service_Order_Line__c wOLine){
        SVMXC__Entitlement_History__c oEntitlementHistory  = new SVMXC__Entitlement_History__c();
        oEntitlementHistory.SVMXC__Work_Detail__c = wOLine.Id;
        oEntitlementHistory.SVMXC__Date_of_Entitlement__c = Date.Today();
        oEntitlementHistory.SVMXC__Entitlement_Notes__c = wOLine.SVMXC__Entitlement_Notes__c;
        if(wOLine.SVMXC__Product_Warranty__c != null){
            EntitlementInfoWrapper entitlementInfo = entitlementInfoMap.get(wOLine.SVMXC__Product_Warranty__c);
            oEntitlementHistory.SVMXC__Warranty__c = wOLine.SVMXC__Product_Warranty__c;
            if(entitlementInfo.startDate != null)
                oEntitlementHistory.SVMXC__Start_Date__c = Date.valueof(entitlementInfo.startDate); 
            if(entitlementInfo.endDate != null)
                oEntitlementHistory.SVMXC__End_Date__c = Date.valueof(entitlementInfo.endDate);        
        }else if(wOLine.SVMXC__Service_Maintenance_Contract__c != null){
            EntitlementInfoWrapper entitlementInfo = entitlementInfoMap.get(wOLine.SVMXC__Service_Maintenance_Contract__c);
            oEntitlementHistory.SVMXC__Service_Contract__c = wOLine.SVMXC__Service_Maintenance_Contract__c;
            if(entitlementInfo.startDate != null)
                oEntitlementHistory.SVMXC__Start_Date__c = Date.valueof(entitlementInfo.startDate); 
            if(entitlementInfo.endDate != null)    
                oEntitlementHistory.SVMXC__End_Date__c = Date.valueof(entitlementInfo.endDate); 
        }
        return oEntitlementHistory;
    }

    public date getStartDate(SVMXC__Service_Contract_Products__c oSCP)
    {
        if(oSCP.SVMXC__Start_Date__c != null || oSCP.SVMXC__End_Date__c != null)
            return oSCP.SVMXC__Start_Date__c;
        else
            return oSCP.SVMXC__Service_Contract__r.SVMXC__Start_Date__c;
    }
    
    public date getEndDate(SVMXC__Service_Contract_Products__c oSCP)
    {
        if(oSCP.SVMXC__Start_Date__c != null || oSCP.SVMXC__End_Date__c != null)
            return oSCP.SVMXC__End_Date__c;
        else
            return oSCP.SVMXC__Service_Contract__r.SVMXC__End_Date__c;
    }
    
    public String dateToString(date objDate)
    {
        String strDate = '';
        try
        {
            if(objDate != NULL)
            {
                String strMM = objDate.month().format() ;
                String strDD = objDate.day().format();
                if (integer.valueOf(strMM) < 10) strMM = '0' + strMM;
                if (integer.valueOf(strDD) < 10) strDD = '0' + strDD;
                strDate = String.valueOf(objDate.year()) + '-' + strMM + '-' + strDD;
            }
        }
        catch(exception ex){}
        return strDate;
    }
    
  /*  public string getIBStringFull(Set<Id> wOLineIBs, SVMXC__ServiceMax_Processes__c oEntRule)
    {
        string strIBWhereClouse = '';
        strIBWhereClouse = ' ( SVMXC__Installed_Product__c = \'' +objWO.SVMXC__Component__c + '\' ';
        if(oEntRule.SVMXC__Include_Parent__c && mapParentIB.get(objWO.SVMXC__Component__c) != null)
            strIBWhereClouse += ' OR SVMXC__Installed_Product__c = \'' + mapParentIB.get(objWO.SVMXC__Component__c) + '\' ';
        if(oEntRule.SVMXC__Include_Top_Level__c && mapTopLevelIB.get(objWO.SVMXC__Component__c) != null)
            strIBWhereClouse += ' OR SVMXC__Installed_Product__c = \'' + mapTopLevelIB.get(objWO.SVMXC__Component__c) + '\' ';
        strIBWhereClouse += ' )';
        return strIBWhereClouse;
    
    }*/

    public void updateProductServiceEntitlement(){
        try{
            System.debug('Product service Lines : ' + productServicedLines);
            if(!productServicedLines.isEmpty())
                update productServicedLines;
        }catch(DmlException e){
        }
    }

    public void updateCounterMaps(Id IdIB)
    {
        //if(mapCounterReadings.ContainsKey(IdIB)) Commented for the Multiple counter reading defect 020165
        if(mapIBIDAndListCounterReadings.ContainsKey(IdIB))
        {
            //SVMXC__Counter_Details__c oCR = mapCounterReadings.get(IdIB); Commented for the Multiple counter reading defect 020165
            for(SVMXC__Counter_Details__c oCR : mapIBIDAndListCounterReadings.get(IdIB)){
                map<Id, SVMXC__Counter_Details__c> m1 = mapCounterCoverageIB.get(IdIB);
                if(m1 != null)
                {
                    for(SVMXC__Counter_Details__c oCD :m1.values())
                    {
                        if(oCR.SVMXC__Counter_Definition__c == oCD.SVMXC__Counter_Definition__c)
                        {
                            if(oCR.SVMXC__Counter_Definition__r.SVMXC__Counter_Type__c == 'Increasing')
                            {
                                if(oCD.SVMXC__Coverage_Limit__c > oCR.SVMXC__Counter_Reading__c && oCD.SVMXC__Coverage_Starts_At__c <= oCR.SVMXC__Counter_Reading__c)
                                {
                                    SVMXC__Service_Contract__c oSC = (SVMXC__Service_Contract__c)oCD.getSObject('SVMXC__Service_Maintenance_Contract__r');
                                    if(oSC != null)
                                    {
                                        if(!mapIBServiceContractCoverageCounters.ContainsKey(IdIB))
                                            mapIBServiceContractCoverageCounters.put(IdIB, new map<Id, SVMXC__Service_Contract__c>());
                                        mapIBServiceContractCoverageCounters.get(IdIB).put(oSC.Id, oSC);
                                    }
                                }
                            }
                            else if(oCR.SVMXC__Counter_Definition__r.SVMXC__Counter_Type__c == 'Decreasing')
                            {
                                //if(oCD.SVMXC__Coverage_Limit__c >= oCR.SVMXC__Counter_Reading__c && oCD.SVMXC__Coverage_Starts_At__c < oCR.SVMXC__Counter_Reading__c) Commented for the Decreasing counter defect 019056
                                if(oCD.SVMXC__Coverage_Limit__c < oCR.SVMXC__Counter_Reading__c && oCD.SVMXC__Coverage_Starts_At__c >= oCR.SVMXC__Counter_Reading__c)
                                {
                                    SVMXC__Service_Contract__c oSC = (SVMXC__Service_Contract__c)oCD.getSObject('SVMXC__Service_Maintenance_Contract__r');
                                    if(oSC != null)
                                    {
                                        if(!mapIBServiceContractCoverageCounters.ContainsKey(IdIB))
                                            mapIBServiceContractCoverageCounters.put(IdIB, new map<Id, SVMXC__Service_Contract__c>());
                                        mapIBServiceContractCoverageCounters.get(IdIB).put(oSC.Id, oSC);
                                    }
                                }
                            }
                            fillMapContractNCoverProduct();
                        }
                    }
                }
                
                map<Id, SVMXC__Counter_Details__c> m2 = mapCounterCoverageProduct.get(mapProductId.get(IdIB));
                if(m2 != null)
                {
                    for(SVMXC__Counter_Details__c oCD :m2.values())
                    {
                        if(oCR.SVMXC__Counter_Definition__c == oCD.SVMXC__Counter_Definition__c)
                        {
                            //ID ProdId = mapProductId.get(IdIB);
                            SVMXC__Service_Template__c oWT1 = (SVMXC__Service_Template__c)oCD.getSObject('SVMXC__Warranty_Terms__r');
                            if(mapIBProductWarranty.containsKey(IdIB) && mapIBProductWarranty.get(IdIB) != null){
                              for(SVMXC__Warranty__c PW : mapIBProductWarranty.get(IdIB)){
                                if(oWT1.id == PW.SVMXC__Service_Template__c){
                                    if(oCR.SVMXC__Counter_Definition__r.SVMXC__Counter_Type__c == 'Increasing')
                                    {
                                        if(oCD.SVMXC__Coverage_Limit__c > oCR.SVMXC__Counter_Reading__c && oCD.SVMXC__Coverage_Starts_At__c <= oCR.SVMXC__Counter_Reading__c)
                                        {
                                            SVMXC__Service_Template__c oWT = (SVMXC__Service_Template__c)oCD.getSObject('SVMXC__Warranty_Terms__r');
                                            if(oWT != null)
                                            {
                                                if(!mapIBWarrantyTermsCounters.ContainsKey(IdIB)){
                                                    mapIBWarrantyTermsCounters.put(IdIB, new map<Id, SVMXC__Service_Template__c>());
                                                }
                                                mapIBWarrantyTermsCounters.get(IdIB).put(oWT.Id, oWT);
                                            }
                                        }
                                    }    
                                    
                                    
                                    else if(oCR.SVMXC__Counter_Definition__r.SVMXC__Counter_Type__c == 'Decreasing')
                                    {
                                        //if(oCD.SVMXC__Coverage_Limit__c >= oCR.SVMXC__Counter_Reading__c && oCD.SVMXC__Coverage_Starts_At__c < oCR.SVMXC__Counter_Reading__c) Commented for the Decreasing counter defect 019056
                                        if(oCD.SVMXC__Coverage_Limit__c < oCR.SVMXC__Counter_Reading__c && oCD.SVMXC__Coverage_Starts_At__c >= oCR.SVMXC__Counter_Reading__c)
                                        {
                                            SVMXC__Service_Template__c oWT = (SVMXC__Service_Template__c)oCD.getSObject('SVMXC__Warranty_Terms__r');
                                            if(oWT != null)
                                            {
                                                if(!mapIBWarrantyTermsCounters.ContainsKey(IdIB))
                                                    mapIBWarrantyTermsCounters.put(IdIB, new map<Id, SVMXC__Service_Template__c>());
                                                mapIBWarrantyTermsCounters.get(IdIB).put(oCD.Id, oWT);
                                            }
                                        }
                                    }
                                }        
                            }
                            }
                                    
                        }
                    }
                }
            }
        }
    }
    
    public void fillMapContractNCoverProduct()
    {
        List<String> SCONIds = new List<String>();
        if(mapIBServiceContractCoverageCounters != null && mapIBServiceContractCoverageCounters.size() > 0 )
        {
            for(String strKey : mapIBServiceContractCoverageCounters.keySet())
            {
                if(mapIBServiceContractCoverageCounters.get(strKey) != null)
                {
                    for(String strK : mapIBServiceContractCoverageCounters.get(strKey).keySet() )
                        SCONIds.add(strK);
                }
            }
            if(SCONIds != null && SCONIds.size() > 0)
            {
                //5- Dec- 2014/ Anchal
                // Defect fix - 012922, Add feilds - SVMXC__Service_Contract__r.SVMXC__Start_Date__c,  SVMXC__Service_Contract__r.SVMXC__End_Date__c to the Query 
                String strQueryCP = 'select SVMXC__Service_Contract__c, SVMXC__Service_Contract__r.SVMXC__Start_Date__c,  SVMXC__Service_Contract__r.SVMXC__End_Date__c, SVMXC__Start_Date__c, SVMXC__End_Date__c, SVMXC__Installed_Product__c, SVMXC__SLA_Terms__c from SVMXC__Service_Contract_Products__c where SVMXC__Service_Contract__c IN: SCONIds' ;
                List<SVMXC__Service_Contract_Products__c> lstObjSCP = Database.query(strQueryCP);
                if(lstObjSCP != null && lstObjSCP.size() > 0 )
                {
                    for(String strKey : mapIBServiceContractCoverageCounters.keySet())
                    {
                        if(mapIBServiceContractCoverageCounters.get(strKey) != null)
                        {
                            for(String strK : mapIBServiceContractCoverageCounters.get(strKey).keySet())
                            {
                                if(!(mapServiceContractCoverageProduct.containsKey(strK)))
                                {
                                    List<SVMXC__Service_Contract_Products__c> lstObjTempSCP = new List<SVMXC__Service_Contract_Products__c>();
                                    for(SVMXC__Service_Contract_Products__c SCP : lstObjSCP)
                                    {
                                        if(SCP.SVMXC__Service_Contract__c == strK)
                                            lstObjTempSCP.add(SCP);
                                    }
                                    mapServiceContractCoverageProduct.put(strK, lstObjTempSCP);
                                }
                            }
                        }
                    }
                }
            }
        }
    }
    
    
    public void SVMX_DeriveProdfrmIB(list<SVMXC__Service_Order__c> lstWrkOrdr, Map<String, String> mapSettings)
    {
        
        set<Id> setComponant = new set<Id>();
        for (Integer i = 0; i < lstWrkOrdr.size(); i++) 
        {
            if(lstWrkOrdr[i].SVMXC__Component__c != null)
                setComponant.add(lstWrkOrdr[i].SVMXC__Component__c);
        }
        map<Id, SVMXC__Installed_Product__c> mapIB = new map<Id, SVMXC__Installed_Product__c>(); 
        if(setComponant.size() > 0)
            mapIB.putAll([Select id,SVMXC__Product__c,SVMXC__Top_Level__c from SVMXC__Installed_Product__c where id IN :setComponant]);
        system.debug('mapIB'+mapIB);
        system.debug('setComponant'+setComponant);
        if(mapIB.size() > 0 && mapSettings.containsKey('IPRD003_SET007') && mapSettings.get('IPRD003_SET007').ToUpperCase() == 'TRUE') //Check added by GM 16Nov-09
        {
            for (Integer i = 0; i < lstWrkOrdr.size(); i++) 
            {
                if(lstWrkOrdr[i].SVMXC__Component__c != null && mapIB.get(lstWrkOrdr[i].SVMXC__Component__c) != null && mapIB.get(lstWrkOrdr[i].SVMXC__Component__c).SVMXC__Product__c != null)  
                    //system.debug('asdf000'+mapIB.get(lstWrkOrdr[i].SVMXC__Component__c).SVMXC__Product__c); 
                    lstWrkOrdr[i].SVMXC__Product__c = mapIB.get(lstWrkOrdr[i].SVMXC__Component__c).SVMXC__Product__c;
            }
        }
        if(mapIB.size() > 0 && mapSettings.containsKey('IPRD003_SET003') && mapSettings.get('IPRD003_SET003').ToUpperCase() == 'TRUE')//Added by amar due to enhancement bug no 001491 on 26th oct 2010
        {
            for (Integer i = 0; i < lstWrkOrdr.size(); i++) 
            {
                if(lstWrkOrdr[i].SVMXC__Component__c != null && mapIB.Containskey(lstWrkOrdr[i].SVMXC__Component__c) && mapIB.get(lstWrkOrdr[i].SVMXC__Component__c).SVMXC__Top_Level__c != null)  
                    lstWrkOrdr[i].SVMXC__Top_Level__c = mapIB.get(lstWrkOrdr[i].SVMXC__Component__c).SVMXC__Top_Level__c;
            }
        }
    }

    public List<Id> getcomponentOrderList(SVMXC__ServiceMax_Processes__c oEntRule, Id componentId){
        List<Id> componentOrderList = new List<String>{componentId};                                                    
        if(oEntRule.SVMXC__Include_Parent__c)
            componentOrderList.add(mapParentIB.get(componentId));   
        if(oEntRule.SVMXC__Include_Top_Level__c)    
            componentOrderList.add(mapTopLevelIB.get(componentId));   
        return componentOrderList;    
    }

    public SVMXC__Service_Order__c updateWOEntitlementInfo(SVMXC__Service_Order__c objWO, EntitlementInfoWrapper entitlementInfoRec){
        String entitlementNotes =  'Entitled by ServiceMax auto-entitlement process.'+
                                   '\nAuto-Entitlement Rule: ' + entitlementInfoRec.ruleName; 
        if(entitlementInfoRec.entType == 'Warranty'){
           objWO.SVMXC__Warranty__c =  entitlementInfoRec.sConOrWarrantyId; 
           entitlementNotes += '\nWarranty: ' + entitlementInfoRec.sConOrWarrantyName; 
        }
        if(entitlementInfoRec.entType == 'Contract'){
            objWO.SVMXC__Service_Contract__c = entitlementInfoRec.sConOrWarrantyId; 
            objWO.SVMXC__SLA_Terms__c = entitlementInfoRec.sLATerms;
            entitlementNotes += '\nService Contract: ' + entitlementInfoRec.sConOrWarrantyName;
        }
        if(entitlementInfoRec.startDate != null && entitlementInfoRec.endDate != null){
            entitlementNotes += '\nStart Date: ' + entitlementInfoRec.startDate +
                                '\nEnd Date: ' + entitlementInfoRec.endDate;
        }      
        objWO.SVMXC__Entitlement_Notes__c = entitlementNotes;                              
        objWO.SVMXC__Is_Entitlement_Performed__c = true;   
        //Added on 2/3/2011 Due to Defect 001402 (By Amar)
        if(SetBillingType == true)
            objWO.SVMXC__Billing_Type__c = entitlementInfoRec.entType;
        IsWOEntitled = true; 
        return objWO;         
    }


    public SVMXC__Service_Order_Line__c updateWODetailEntitlementInfo(SVMXC__Service_Order_Line__c objWOLine, EntitlementInfoWrapper entitlementInfoRec){
        String entitlementNotes =  'Entitled by ServiceMax auto-entitlement process.'+
                                   '\nAuto-Entitlement Rule: ' + entitlementInfoRec.ruleName;
        if(entitlementInfoRec.entType == 'Warranty'){
           objWOLine.SVMXC__Product_Warranty__c =  entitlementInfoRec.sConOrWarrantyId; 
           entitlementNotes += '\nWarranty: ' + entitlementInfoRec.sConOrWarrantyName; 
        }
        if(entitlementInfoRec.entType == 'Contract'){
            objWOLine.SVMXC__Service_Maintenance_Contract__c = entitlementInfoRec.sConOrWarrantyId; 
            entitlementNotes += '\nService Contract: ' + entitlementInfoRec.sConOrWarrantyName;
        }
        if(entitlementInfoRec.startDate != null && entitlementInfoRec.endDate != null){    
            entitlementNotes += '\nStart Date: ' + entitlementInfoRec.startDate +
                                '\nEnd Date: ' + entitlementInfoRec.endDate;
        }
        objWOLine.SVMXC__Entitlement_Notes__c = entitlementNotes;                                   
        objWOLine.SVMXC__Is_Entitlement_Performed__c = true;  
        entitlementInfoMap.put(entitlementInfoRec.sConOrWarrantyId,entitlementInfoRec); 
        return objWOLine;     
    }

    public EntitlementInfoWrapper getWarrantyOnValidityDate(List<Id> componentOrderList,SVMXC__Service_Order__c objWO,Boolean isDisabledAutoEntitlementOnRule){
        EntitlementInfoWrapper entitlementInfoRec;
        //Changes added by Nidhi as part of BAC-4638
        //In case of multiple warranties, execute following only if Disable auto-entitlement is false
        Set<Id> listWarranty = new Set<Id>();
        //In case of Entitlement Scope = 'Whichever Is Valid', dates validity is not done in the query, hence even expired warranties are there in mapIBProductWarranty
        //Filter expired warranties to resolve defect BAC-4756
        date dtEntitleusing = date.today();
        try{
            if(Setng_EntitleUsingFld != null && (!Setng_EntitleUsingFld.equalsIgnoreCase('Today')) && objWO.get(Setng_EntitleUsingFld) != null )
                dtEntitleusing = date.valueOf(String.valueOf(objWO.get(Setng_EntitleUsingFld)));
        }
        catch(exception ex){
            dtEntitleusing = date.today();
        } 
        
        for(Id component : componentOrderList){
            if(mapIBProductWarranty.get(component) != null){
                for(SVMXC__Warranty__c oPW : mapIBProductWarranty.get(component)){
                    if(oPW.SVMXC__Start_Date__c <= dtEntitleusing && oPW.SVMXC__End_Date__c >= dtEntitleusing ){
                        listWarranty.add(oPW.id); 
                    }
                } 
            }
        }  
        if(!(listWarranty.size()>1 && isDisabledAutoEntitlementOnRule) && ! isdiabledEntitlementOnWo){
            for(Id component : componentOrderList){
                if(entitlementInfoRec == null)
                   entitlementInfoRec = validateWarrantyOnDate(component,objWO);
                else
                   break;  
            }  
        }else{              
             isdiabledEntitlementOnWo = true;
        }
        return entitlementInfoRec;             
    }


    public EntitlementInfoWrapper validateWarrantyOnDate (Id componentID,SVMXC__Service_Order__c objWO){      
        EntitlementInfoWrapper entitlementInfoRec;
        date dtEntitleusing = date.today();
        try{
            if(Setng_EntitleUsingFld != null && (!Setng_EntitleUsingFld.equalsIgnoreCase('Today')) && objWO.get(Setng_EntitleUsingFld) != null )
                dtEntitleusing = date.valueOf(String.valueOf(objWO.get(Setng_EntitleUsingFld)));
        }
        catch(exception ex){
            dtEntitleusing = date.today();
        } 
        if(componentId != null && mapIBProductWarranty.get(componentId) != null && mapIBProductWarranty.get(componentId).size() > 0){       
            for(SVMXC__Warranty__c oPW : mapIBProductWarranty.get(componentId))
            {
                if(oPW.SVMXC__Start_Date__c <= dtEntitleusing && oPW.SVMXC__End_Date__c >= dtEntitleusing ){
                    entitlementInfoRec = new EntitlementInfoWrapper();
                    entitlementInfoRec.sConOrWarrantyId = oPW.Id;
                    entitlementInfoRec.startDate = dateToString(oPW.SVMXC__Start_Date__c);
                    entitlementInfoRec.endDate = dateToString(oPW.SVMXC__End_Date__c);
                    entitlementInfoRec.sConOrWarrantyName = oPW.Name;
                    entitlementInfoRec.entType = 'Warranty';
                    return entitlementInfoRec;
                }
            } 
        }
        return entitlementInfoRec;       
    }   
  
    public EntitlementInfoWrapper getServiceContractOnValidityDate(List<Id> componentOrderList,SVMXC__ServiceMax_Processes__c oEntRule,SVMXC__Service_Order__c  objWO,Integer iWOIndex){
        EntitlementInfoWrapper entitlementInfoRec;
        boolean locationChecked = false;        
        //Changes added by Nidhi as part of BAC-4638
        boolean isValidSC;
        //Converted listServiceContracts from List to Set of Ids to resolve defect BAC-4751
        Set<Id> listServiceContracts = new Set<Id>();//this list stores valid service contracts 
        for(Id component : componentOrderList){ 
            if(mapIBServiceContractCoverage.containsKey(component)){
                for(SVMXC__Service_Contract_Products__c osc: mapIBServiceContractCoverage.get(component)){
                    isValidSC = true;//boolean added to check Account match and Contact match rules on Auto Entitlement
                    if(oEntRule.SVMXC__Match_Contact__c)
                        {
                            if(!(objWO.SVMXC__Contact__c != null && mapContactSC.ContainsKey(objWO.SVMXC__Contact__c) && mapContactSC.get(objWO.SVMXC__Contact__c).contains(osc.SVMXC__Service_Contract__c)))
                                isValidSC = false;//this SC is not valid hence do not add to the list
                        }
                        if(oEntRule.SVMXC__Match_Account__c)
                        {
                            if(mapWOAccount.get(iWOIndex) != osc.SVMXC__Service_Contract__r.SVMXC__Company__c)
                                isValidSC = false;//this SC is not valid hence do not add to the list
                        }
                    if(isValidSC){
                        //Only valid SC are added to the list.
                        listServiceContracts.add(osc.SVMXC__Service_Contract__c); 
                    }
                }  
            }
        } 
        
        if(!(listServiceContracts.size()>1 && oEntRule.SVMXC__SM_Disable_AutoEntitlement__c) && ! isdiabledEntitlementOnWo){
            //In case of multiple Service Contracts, execute following only if Disable auto-entitlement is false
            for(Id component : componentOrderList){
                if(entitlementInfoRec == null){
                        entitlementInfoRec = validateServiceContractOnDate(component,oEntRule,objWO,iWOIndex);
                    
                        if(entitlementInfoRec == null && !locationChecked){ 
                            if(oEntRule.SVMXC__Match_Location__c && objWO.SVMXC__site__c != null)
                                entitlementInfoRec = getServiceContractOnLocation(oEntRule,objWO,iWOIndex);
                            locationChecked = true;    
                        }
                    
                }
                else
                   break;  
            } 
        }else{                  
            isdiabledEntitlementOnWo = true;
        }
        
        return entitlementInfoRec;             
    }    
    
    public EntitlementInfoWrapper getServiceContractOnCounters(List<Id> componentOrderList,SVMXC__ServiceMax_Processes__c oEntRule,SVMXC__Service_Order__c objWO,Integer iWOIndex)
    {
        EntitlementInfoWrapper entitlementInfoRec;
        //Changes added by Nidhi as part of BAC-4638        
        boolean isValidSC;
        Set<Id> listServiceContracts = new Set<Id>();//Get list of valid Service Contracts for this WO
        for(Id component : componentOrderList){
            if(mapIBServiceContractCoverageCounters.get(component) != null){
                for(SVMXC__Service_Contract__c osc: mapIBServiceContractCoverageCounters.get(component).values()){
                    isValidSC = true;//boolean added to check Account match and Contact match rules on Auto Entitlement
                    if(oEntRule.SVMXC__Match_Contact__c)
                        {
                            if(!(objWO.SVMXC__Contact__c != null && mapContactSC.ContainsKey(objWO.SVMXC__Contact__c) && mapContactSC.get(objWO.SVMXC__Contact__c).contains(osc.Id)))
                                isValidSC = false;//this SC is not valid hence do not add to the list
                        }
                        if(oEntRule.SVMXC__Match_Account__c)
                        {
                            if(mapWOAccount.get(iWOIndex) != osc.SVMXC__Company__c)
                                isValidSC = false;//this SC is not valid hence do not add to the list
                        }
                    if(isValidSC){
                        //Only valid SC are added to the list.
                        listServiceContracts.add(osc.Id); 
                    }
                } 
            }
        }   
        
        if(!(listServiceContracts.size()>1 && oEntRule.SVMXC__SM_Disable_AutoEntitlement__c) && ! isdiabledEntitlementOnWo){
            //In case of multiple Service Contracts, execute following only if Disable auto-entitlement is false
            for(Id component : componentOrderList){
                if(entitlementInfoRec == null)
                   entitlementInfoRec = validateServiceContractOnCounters(component,oEntRule,objWO,iWOIndex);
                else
                   break; 
            }        
        }else{                  
             isdiabledEntitlementOnWo = true;
        }
        return entitlementInfoRec;      

    }

    public EntitlementInfoWrapper getServiceContractOnBoth(List<Id> componentOrderList,SVMXC__ServiceMax_Processes__c oEntRule,SVMXC__Service_Order__c objWO,Integer iWOIndex){
        EntitlementInfoWrapper entitlementInfoRec;
        boolean locationChecked = false;
        //Changes added by Nidhi as part of BAC-4638 
        boolean isValidSC;
        Set<Id> listServiceContracts = new Set<Id>();//Get list of valid Service Contracts for this work order
        for(Id component : componentOrderList){   
            if(mapIBServiceContractCoverage.containsKey(component)){
                for(SVMXC__Service_Contract_Products__c osc: mapIBServiceContractCoverage.get(component)){
                    //loop through list of queried service contracts and verify counter detail exist for each of them, fixing defect BAC-4768                    
                    if(mapIBServiceContractCoverageCounters.get(component) != null && osc.SVMXC__Service_Contract__c!= null && mapIBServiceContractCoverageCounters.get(component).get(osc.SVMXC__Service_Contract__c) != null){
                
                        isValidSC = true;//boolean added to check Account match and Contact match rules on Auto Entitlement
                        if(oEntRule.SVMXC__Match_Contact__c)
                            {
                                if(!(objWO.SVMXC__Contact__c != null && mapContactSC.ContainsKey(objWO.SVMXC__Contact__c) && mapContactSC.get(objWO.SVMXC__Contact__c).contains(osc.SVMXC__Service_Contract__c)))
                                    isValidSC = false;//this SC is not valid hence do not add to the list
                            }
                            if(oEntRule.SVMXC__Match_Account__c)
                            {
                                if(mapWOAccount.get(iWOIndex) != osc.SVMXC__Service_Contract__r.SVMXC__Company__c)
                                    isValidSC = false;//this SC is not valid hence do not add to the list
                            }
                        if(isValidSC){
                            //Only valid SC are added to the list.
                            listServiceContracts.add(osc.SVMXC__Service_Contract__c); 
                        }
                    }
                }
            }    
                 
        }        
        if(!(listServiceContracts.size()>1 && oEntRule.SVMXC__SM_Disable_AutoEntitlement__c) && ! isdiabledEntitlementOnWo){
            //In case of multiple Service Contracts, execute following only if Disable auto-entitlement is false
            for(Id component : componentOrderList){
                if(entitlementInfoRec == null){               
                    entitlementInfoRec = validateServiceContractOnBoth(component,oEntRule,objWO,iWOIndex);
                
                    if(entitlementInfoRec == null && !locationChecked){ 
                        if(oEntRule.SVMXC__Match_Location__c && objWO.SVMXC__site__c != null)
                            entitlementInfoRec = getServiceContractOnLocation(oEntRule,objWO,iWOIndex);
                        locationChecked = true;    
                    }            
                }
                else
                   break;  
            } 
        }else{                  
            isdiabledEntitlementOnWo = true;
        }
        
        return entitlementInfoRec;          

    } 

    public EntitlementInfoWrapper validateServiceContractOnBoth(Id componentId,SVMXC__ServiceMax_Processes__c oEntRule, SVMXC__Service_Order__c objWO, Integer iWOIndex)
    {
        EntitlementInfoWrapper entitlementInfoRec;
        if(componentId != null && mapIBServiceContractCoverage.get(componentId) != null && mapIBServiceContractCoverage.get(componentId).size() > 0){
            date dtEntitleusing = date.today();
            try
            {
            if(Setng_EntitleUsingFld != null && (!Setng_EntitleUsingFld.equalsIgnoreCase('Today')) && objWO.get(Setng_EntitleUsingFld) != null )
                dtEntitleusing = date.valueOf(String.valueOf(objWO.get(Setng_EntitleUsingFld)));
            }
            catch(exception ex)
            {
                dtEntitleusing = date.today();
            }
            for(SVMXC__Service_Contract_Products__c oSCP :mapIBServiceContractCoverage.get(componentId))
            {
                date DateStart;
                date DateEnd;
                if(oSCP.SVMXC__Start_Date__c == null || oSCP.SVMXC__End_Date__c == null){
                    DateStart = oSCP.SVMXC__Service_Contract__r.SVMXC__Start_Date__c;
                    DateEnd = oSCP.SVMXC__Service_Contract__r.SVMXC__End_Date__c;
                }
                else{
                    if(oSCP.SVMXC__Service_Contract__r.SVMXC__Start_Date__c <= dtEntitleusing && oSCP.SVMXC__Service_Contract__r.SVMXC__End_Date__c >= dtEntitleusing){
                        DateStart = oSCP.SVMXC__Start_Date__c;
                        DateEnd = oSCP.SVMXC__End_Date__c; 
                    }
                }
                
                Boolean isValidSC = true;   
                
                if(DateStart <= dtEntitleusing && DateEnd  >= dtEntitleusing){
                    if(mapIBServiceContractCoverageCounters.get(componentId) != null && mapIBServiceContractCoverageCounters.get(componentId).get(oSCP.SVMXC__Service_Contract__c) != null){
                        
                        if(oEntRule.SVMXC__Match_Contact__c)
                        {
                            if(!(objWO.SVMXC__Contact__c != null && mapContactSC.ContainsKey(objWO.SVMXC__Contact__c) && mapContactSC.get(objWO.SVMXC__Contact__c).contains(oSCP.SVMXC__Service_Contract__c)))
                                isValidSC = false;
                        }
                    
                        if(oEntRule.SVMXC__Match_Account__c)
                        {
                            if(mapWOAccount.get(iWOIndex) != oSCP.SVMXC__Service_Contract__r.SVMXC__Company__c)
                                isValidSC = false;
                        }
                    
                        if(isValidSC){        
                            entitlementInfoRec = new EntitlementInfoWrapper();
                            entitlementInfoRec.sConOrWarrantyId = oSCP.SVMXC__Service_Contract__c;
                            entitlementInfoRec.sLATerms = oSCP.SVMXC__Service_Contract__r.SVMXC__Service_Level__c;
                            entitlementInfoRec.sConOrWarrantyName = oSCP.SVMXC__Service_Contract__r.Name;
                            entitlementInfoRec.entType = 'Contract';                            
                            if(oEntRule.SVMXC__Allow_Override__c){
                                DateStart = oSCP.SVMXC__Service_Contract__r.SVMXC__Start_Date__c;
                                DateEnd = oSCP.SVMXC__Service_Contract__r.SVMXC__End_Date__c; 
                            }else{
                                if(oSCP.SVMXC__SLA_Terms__c != null)
                                   entitlementInfoRec.sLATerms = oSCP.SVMXC__SLA_Terms__c;
                            }
                            entitlementInfoRec.startDate = dateToString(DateStart);
                            entitlementInfoRec.endDate = dateToString(DateEnd);
                            //Create map of WO index and Service Contract Covered Product for Entitlement History update.
                            mapWOIndexContractIBCvrg.put(iWOIndex, oSCP);
                            return entitlementInfoRec; 
                        }
                    }
                }
            }
        }    
        return entitlementInfoRec;
    }    
    
    public EntitlementInfoWrapper validateServiceContractOnCounters(Id componentId,SVMXC__ServiceMax_Processes__c oEntRule,SVMXC__Service_Order__c objWO,Integer iWOIndex){    
        EntitlementInfoWrapper entitlementInfoRec;
        if(componentId != null && mapIBServiceContractCoverageCounters.get(componentId) != null && mapIBServiceContractCoverageCounters.get(componentId).size() > 0){
            for(SVMXC__Service_Contract__c oSC :mapIBServiceContractCoverageCounters.get(componentId).values())
            {
                boolean isValidSC = true;
                if(oEntRule.SVMXC__Match_Contact__c)
                {
                    if(!(objWO.SVMXC__Contact__c != null && mapContactSC.ContainsKey(objWO.SVMXC__Contact__c) && mapContactSC.get(objWO.SVMXC__Contact__c).contains(oSC.Id)))
                        isValidSC = false;
                }
                if(oEntRule.SVMXC__Match_Account__c)
                {
                    if(mapWOAccount.get(iWOIndex) != oSC.SVMXC__Company__c)
                        isValidSC = false;
                }
                if(isValidSC)
                {
                    entitlementInfoRec = new EntitlementInfoWrapper();
                    entitlementInfoRec.sConOrWarrantyId = oSC.Id;
                    entitlementInfoRec.sLATerms = oSC.SVMXC__Service_Level__c;
                    entitlementInfoRec.sConOrWarrantyName = oSC.Name;
                    entitlementInfoRec.entType = 'Contract';                            
                    if(mapServiceContractCoverageProduct != null && mapServiceContractCoverageProduct.size() > 0 && mapServiceContractCoverageProduct.containsKey(oSC.Id) && mapServiceContractCoverageProduct.get(oSC.Id) != null)
                    {
                        for(SVMXC__Service_Contract_Products__c oSCP : mapServiceContractCoverageProduct.get(oSC.Id))
                        {
                            if(oSCP.SVMXC__Installed_Product__c == objWO.SVMXC__Component__c)
                            {   
                                if(!oEntRule.SVMXC__Allow_Override__c && oSCP.SVMXC__SLA_Terms__c != null)
                                    entitlementInfoRec.sLATerms = oSCP.SVMXC__SLA_Terms__c;
                                //Create map of WO index and Service Contract Covered Product for Entitlement History update.
                                mapWOIndexContractIBCvrg.put(iWOIndex, oSCP);
                                return entitlementInfoRec;
                            }
                        }
                    }
                    return entitlementInfoRec;
                }
            }
        }    
        return entitlementInfoRec;
    }

    public class EntitlementInfoWrapper{
        String entType{get;set;}
        Id sConOrWarrantyId{get;set;}
        Id sLATerms{get;set;}
        String ruleName{get;set;}
        String startDate{get;set;}
        String endDate{get;set;}
        String sConOrWarrantyName{get;set;}     
        public EntitlementInfoWrapper(){            
        }
    }    

    public EntitlementInfoWrapper validateServiceContractOnDate(Id componentID, SVMXC__ServiceMax_Processes__c oEntRule,SVMXC__Service_Order__c objWO,Integer iWOIndex){
        EntitlementInfoWrapper entitlementInfoRec;
        if(componentID != null && mapIBServiceContractCoverage.get(componentID) != null && mapIBServiceContractCoverage.get(componentID).size() > 0){
            for(SVMXC__Service_Contract_Products__c oSCP :mapIBServiceContractCoverage.get(componentID))
            {
                date dtEntitleusing = date.today();
                try
                {
                if(Setng_EntitleUsingFld != null && (!Setng_EntitleUsingFld.equalsIgnoreCase('Today')) && objWO.get(Setng_EntitleUsingFld) != null )
                    dtEntitleusing = date.valueOf(String.valueOf(objWO.get(Setng_EntitleUsingFld)));
                }
                catch(exception ex)
                {
                    dtEntitleusing = date.today();
                }                
                date DateStart;
                date DateEnd;
                if(oSCP.SVMXC__Start_Date__c == null || oSCP.SVMXC__End_Date__c == null){
                    DateStart = oSCP.SVMXC__Service_Contract__r.SVMXC__Start_Date__c;
                    DateEnd = oSCP.SVMXC__Service_Contract__r.SVMXC__End_Date__c;
                }
                else{
                    if(oSCP.SVMXC__Service_Contract__r.SVMXC__Start_Date__c <= dtEntitleusing && oSCP.SVMXC__Service_Contract__r.SVMXC__End_Date__c >= dtEntitleusing){
                        DateStart = oSCP.SVMXC__Start_Date__c;
                        DateEnd = oSCP.SVMXC__End_Date__c; 
                    }
                }
                
                boolean isValidSC = true;

                if(DateStart <= dtEntitleusing && DateEnd >= dtEntitleusing)
                {
                    if(oEntRule.SVMXC__Match_Contact__c)
                    {
                        if(!(objWO.SVMXC__Contact__c != null && mapContactSC.ContainsKey(objWO.SVMXC__Contact__c) && mapContactSC.get(objWO.SVMXC__Contact__c).contains(oSCP.SVMXC__Service_Contract__c)))
                            isValidSC = false;
                    }
                    if(oEntRule.SVMXC__Match_Account__c)
                    {
                        if(mapWOAccount.get(iWOIndex) != oSCP.SVMXC__Service_Contract__r.SVMXC__Company__c)
                            isValidSC = false;
                    }
                    
                    if(isValidSC){
                        //Create map of WO index and Service Contract Covered Product for Entitlement History update.
                        mapWOIndexContractIBCvrg.put(iWOIndex, oSCP);   
                        entitlementInfoRec = new EntitlementInfoWrapper();                     
                        entitlementInfoRec.entType = 'Contract';
                        entitlementInfoRec.sConOrWarrantyId = oSCP.SVMXC__Service_Contract__c;
                        entitlementInfoRec.sConOrWarrantyName = oSCP.SVMXC__Service_Contract__r.Name;
                        entitlementInfoRec.sLATerms = oSCP.SVMXC__Service_Contract__r.SVMXC__Service_Level__c;
                        if(oEntRule.SVMXC__Allow_Override__c){
                            DateStart = oSCP.SVMXC__Service_Contract__r.SVMXC__Start_Date__c;
                            DateEnd = oSCP.SVMXC__Service_Contract__r.SVMXC__End_Date__c;
                        }
                        else{
                            if(oSCP.SVMXC__SLA_Terms__c != null)
                                entitlementInfoRec.sLATerms = oSCP.SVMXC__SLA_Terms__c;
                        }                        
                        entitlementInfoRec.startDate = dateToString(DateStart);
                        entitlementInfoRec.endDate = dateToString(DateEnd);
                        return entitlementInfoRec;
                    }else if(oEntRule.SVMXC__Match_Location__c && objWO.SVMXC__site__c != null )
                        entitlementInfoRec = getServiceContractOnLocation(oEntRule,objWO,iWOIndex);
                }else if(oEntRule.SVMXC__Match_Location__c && objWO.SVMXC__site__c != null )
                    entitlementInfoRec = getServiceContractOnLocation(oEntRule,objWO,iWOIndex);
            }
        }   
        return entitlementInfoRec;
    }                

    public EntitlementInfoWrapper getWarrantyOnCounters(List<Id> componentOrderList,Boolean isDisabledAutoEntitlementOnRule){
        EntitlementInfoWrapper entitlementInfoRec;
        //Changes added by Nidhi as part of BAC-4638
        //In case of multiple warranties, execute following only if Disable auto-entitlement is false
        List<SVMXC__Warranty__c> listWarranty = new List<SVMXC__Warranty__c>();
        for(Id component : componentOrderList){
            if(mapIBWarrantyTermsCounters.get(component) != null && mapIBProductWarranty.get(component) != null){
                listWarranty.addAll(mapIBProductWarranty.get(component));            
            }           
        }   
        if(!(listWarranty.size()>1 && isDisabledAutoEntitlementOnRule) && ! isdiabledEntitlementOnWo){
            for(Id component : componentOrderList){
                if(entitlementInfoRec == null)
                      entitlementInfoRec = validateWarrantyOnCounters(component);
                else
                   break;  
            }  
        }else{                  
             isdiabledEntitlementOnWo = true;
        }
        return entitlementInfoRec;          
    }

    public EntitlementInfoWrapper getWarrantyOnBoth(List<Id> componentOrderList,SVMXC__Service_Order__c objWO,Boolean isDisabledAutoEntitlementOnRule){
        EntitlementInfoWrapper entitlementInfoRec;
        //Changes added by Nidhi as part of BAC-4638
        //In case of multiple warranties, execute following only if Disable auto-entitlement is false
        List<SVMXC__Warranty__c> listWarranty = new List<SVMXC__Warranty__c>();
        for(Id component : componentOrderList){
            //loop through list of queried warranties and verify counter detail exist for each of them, fixing defect BAC-4768
            if(mapIBProductWarranty.get(component) != null){
                for(SVMXC__Warranty__c oPW : mapIBProductWarranty.get(component)){                    
                    if(mapIBWarrantyTermsCounters.get(component) != null && oPW.SVMXC__Service_Template__c != null && mapIBWarrantyTermsCounters.get(component).get(oPW.SVMXC__Service_Template__c)!=null){
                        listWarranty.add(oPW); 
                    }
                } 
            }           
        } 
        if(!(listWarranty.size()>1 && isDisabledAutoEntitlementOnRule) && ! isdiabledEntitlementOnWo){
            for(Id component : componentOrderList){
                if(entitlementInfoRec == null)
                   entitlementInfoRec = validateWarrantyOnBoth(component,objWO);
                else
                   break;  
            }
        }else{                  
             isdiabledEntitlementOnWo = true;
        }
        return entitlementInfoRec;   
    }

    public void getWarrantyOnDetailLines(SVMXC__ServiceMax_Processes__c oEntRule, List<SVMXC__Service_Order_Line__c> wOChildIBs, String type, SVMXC__Service_Order__c objWO){
        for(SVMXC__Service_Order_Line__c productServiced : wOChildIBs){
            productServiced.SVMXC__Product_Warranty__c = null;
            productServiced.SVMXC__Service_Maintenance_Contract__c = null;
            productServiced.SVMXC__Entitlement_Notes__c = null;
            productServiced.SVMXC__Is_Entitlement_Performed__c = true;
            EntitlementInfoWrapper entitlementInfoRec;
            List<Id> componentOrderList = getcomponentOrderList(oEntRule,productServiced.SVMXC__Serial_Number__c);
            if(type == 'Either'){           
                entitlementInfoRec = getWarrantyOnValidityDate(componentOrderList,objWO,false);
                if(entitlementInfoRec == null){
                    entitlementInfoRec = getWarrantyOnCounters(componentOrderList,false); 
                }
            }else if(type == 'Both'){
                entitlementInfoRec = getWarrantyOnBoth(componentOrderList,objWO,false);
            }else if(type == 'Counter'){
                entitlementInfoRec = getWarrantyOnCounters(componentOrderList,false);
            }else if(type == 'Validity'){
                entitlementInfoRec = getWarrantyOnValidityDate(componentOrderList,objWO,false);
            }        
            if(entitlementInfoRec != null){
                entitlementInfoRec.ruleName = oEntRule.SVMXC__Name__c;
                System.debug(Logginglevel.INFO,'Detail Entitlement Info : ' + entitlementInfoRec);
                productServiced = updateWODetailEntitlementInfo(productServiced,entitlementInfoRec);
                //productServiced.SVMXC__Auto_Entitlement_Status__c = 'Success';
            }/*else
                productServiced.SVMXC__Auto_Entitlement_Status__c = 'Failed'; */
            productServicedLines.add(productServiced);  

        }    
    }

public void getServiceContractOnDetailLines(SVMXC__ServiceMax_Processes__c oEntRule, List<SVMXC__Service_Order_Line__c> wOChildIBs, String type, SVMXC__Service_Order__c objWO,Integer iWOIndex){
        for(SVMXC__Service_Order_Line__c productServiced : wOChildIBs){
            productServiced.SVMXC__Product_Warranty__c = null;
            productServiced.SVMXC__Service_Maintenance_Contract__c = null;
            productServiced.SVMXC__Entitlement_Notes__c = null;
            productServiced.SVMXC__Is_Entitlement_Performed__c = true;            
            EntitlementInfoWrapper entitlementInfoRec;
            List<Id> componentsList = getcomponentOrderList(oEntRule,productServiced.SVMXC__Serial_Number__c);
            if(type == 'Either') {
                entitlementInfoRec = getServiceContractOnValidityDate(componentsList,oEntRule,objWO,iWOIndex);
                if(entitlementInfoRec == null)
                        entitlementInfoRec = getServiceContractOnCounters(componentsList,oEntRule,objWO,iWOIndex);
            }else if(type == 'Both'){
                entitlementInfoRec = getServiceContractOnBoth(componentsList,oEntRule,objWO, iWOIndex);
            }else if(type == 'Counter'){
                entitlementInfoRec = getServiceContractOnCounters(componentsList,oEntRule,objWO,iWOIndex);
            }else if(type == 'Validity'){
                entitlementInfoRec = getServiceContractOnValidityDate(componentsList,oEntRule,objWO,iWOIndex);
            }else if(type == 'AccountBased'){
                entitlementInfoRec = getAccServiceContractsOnValidityDates(objWO,oEntRule);
            } 
            if(entitlementInfoRec != null){
                entitlementInfoRec.ruleName = oEntRule.SVMXC__Name__c;
                System.debug(Logginglevel.INFO,'Detail Entitlement Info : ' + entitlementInfoRec);
                productServiced = updateWODetailEntitlementInfo(productServiced,entitlementInfoRec);
                //productServiced.SVMXC__Auto_Entitlement_Status__c = 'Success';
            }/*else
                productServiced.SVMXC__Auto_Entitlement_Status__c = 'Failed'; */
            productServicedLines.add(productServiced);    
        }       
    }

    public void getSconOrWarrantyOnDetailLines(SVMXC__ServiceMax_Processes__c oEntRule,  List<SVMXC__Service_Order_Line__c> wOChildIBs, String type, SVMXC__Service_Order__c objWO,integer iWOIndex){
        for(SVMXC__Service_Order_Line__c productServiced : wOChildIBs){
            productServiced.SVMXC__Product_Warranty__c = null;
            productServiced.SVMXC__Service_Maintenance_Contract__c = null;
            productServiced.SVMXC__Entitlement_Notes__c = null;
            productServiced.SVMXC__Is_Entitlement_Performed__c = true;            
            EntitlementInfoWrapper entitlementInfoRec;
            List<Id> componentsList = getcomponentOrderList(oEntRule,productServiced.SVMXC__Serial_Number__c);
            if(type == 'EitherFPScon') { 
                entitlementInfoRec = getServiceContractOnValidityDate(componentsList,oEntRule,objWO,iWOIndex);
                if(entitlementInfoRec == null)
                    entitlementInfoRec = getServiceContractOnCounters(componentsList,oEntRule,objWO,iWOIndex);
                if(entitlementInfoRec == null)
                   entitlementInfoRec = getWarrantyOnBoth(componentsList,objWO,false);                   
            }else if(type == 'EitherFPWarranty'){
                entitlementInfoRec = getWarrantyOnValidityDate(componentsList,objWO,false);
                if(entitlementInfoRec == null)
                    entitlementInfoRec = getServiceContractOnValidityDate(componentsList,oEntRule,objWO,iWOIndex);
                if(entitlementInfoRec == null)
                    entitlementInfoRec = getServiceContractOnCounters(componentsList, oEntRule,objWO, iWOIndex);                
            }else if(type == 'BothFPScon'){
                entitlementInfoRec = getServiceContractOnBoth(componentsList,oEntRule,objWO,iWOIndex);
                if(entitlementInfoRec == null)
                    entitlementInfoRec = getWarrantyOnValidityDate(componentsList,objWO,false);                
            }else if(type == 'BothFPWarranty'){
                entitlementInfoRec = getWarrantyOnValidityDate(componentsList,objWO,false);
                if(entitlementInfoRec == null){
                    entitlementInfoRec = getServiceContractOnBoth(componentsList, oEntRule,objWO,iWOIndex);
                }                
            }else if(type == 'CounterFPScon'){
                entitlementInfoRec = getServiceContractOnCounters(componentsList,oEntRule,objWO,iWOIndex);
                if(entitlementInfoRec == null)
                    entitlementInfoRec = getWarrantyOnCounters(componentsList,false);                
            }else if(type == 'CounterFPWarranty'){
                entitlementInfoRec = getWarrantyOnCounters(componentsList,false);
                if(entitlementInfoRec == null)
                    entitlementInfoRec = getServiceContractOnCounters(componentsList,oEntRule,objWO,iWOIndex);                
            }else if(type == 'ValidityFPScon'){
                entitlementInfoRec = getServiceContractOnValidityDate(componentsList,oEntRule,objWO,iWOIndex);
                if(entitlementInfoRec == null)
                    entitlementInfoRec = getWarrantyOnValidityDate(componentsList,objWO,false);
            }else if(type == 'ValidityFPWarranty'){
                entitlementInfoRec = getWarrantyOnValidityDate(componentsList,objWO,false);
                if(entitlementInfoRec == null)
                    entitlementInfoRec = getServiceContractOnValidityDate(componentsList,oEntRule,objWO,iWOIndex);
            }
            if(entitlementInfoRec != null){
                entitlementInfoRec.ruleName = oEntRule.SVMXC__Name__c;
                System.debug(Logginglevel.INFO,'Detail Entitlement Info : ' + entitlementInfoRec);
                productServiced = updateWODetailEntitlementInfo(productServiced,entitlementInfoRec);
                //productServiced.SVMXC__Auto_Entitlement_Status__c = 'Success';
            }/*else
                productServiced.SVMXC__Auto_Entitlement_Status__c = 'Failed'; */
            productServicedLines.add(productServiced);   
        }        
    } 


    public EntitlementInfoWrapper validateWarrantyOnCounters(Id componentID){
        EntitlementInfoWrapper entitlementInfoRec;      
        if(componentID != null && mapIBProductWarranty.get(componentID) != null && mapIBProductWarranty.get(componentID).size() > 0){
            ID ProdId = mapProductId.get(componentID);
            for(SVMXC__Warranty__c oPW : mapIBProductWarranty.get(componentId))
            {
                if(mapIBWarrantyTermsCounters.get(componentID) != null && mapIBWarrantyTermsCounters.get(componentID).size() > 0){
                    entitlementInfoRec = new EntitlementInfoWrapper();
                    entitlementInfoRec.sConOrWarrantyId = oPW.Id;
                    //entitlementInfoRec.startDate = dateToString(oPW.SVMXC__Start_Date__c);
                    //entitlementInfoRec.endDate = dateToString(oPW.SVMXC__End_Date__c);
                    entitlementInfoRec.sConOrWarrantyName = oPW.Name;
                    entitlementInfoRec.entType = 'Warranty';
                    return entitlementInfoRec;
                }
            } 
        }
        return entitlementInfoRec; 
    }

    public EntitlementInfoWrapper validateWarrantyOnBoth(Id componentID,SVMXC__Service_Order__c objWO){
        EntitlementInfoWrapper entitlementInfoRec;       
        if(componentID != null && mapIBProductWarranty.get(componentID) != null && mapIBProductWarranty.get(componentID).size() > 0){
            ID ProdId = mapProductId.get(componentID);
            date dtEntitleusing = date.today();
            try
            {
            if(Setng_EntitleUsingFld != null && (!Setng_EntitleUsingFld.equalsIgnoreCase('Today')) && objWO.get(Setng_EntitleUsingFld) != null )
                dtEntitleusing = date.valueOf(String.valueOf(objWO.get(Setng_EntitleUsingFld)));
            }
            catch(exception ex)
            {
                dtEntitleusing = date.today();
            }        
            for(SVMXC__Warranty__c oPW : mapIBProductWarranty.get(componentId))
            {
                if(oPW.SVMXC__Start_Date__c <= dtEntitleusing && oPW.SVMXC__End_Date__c >= dtEntitleusing){
                   if(mapIBWarrantyTermsCounters.get(componentID) != null && mapIBWarrantyTermsCounters.get(componentID).size() > 0){
                        entitlementInfoRec = new EntitlementInfoWrapper();
                        entitlementInfoRec.sConOrWarrantyId = oPW.Id;
                        entitlementInfoRec.startDate = dateToString(oPW.SVMXC__Start_Date__c);
                        entitlementInfoRec.endDate = dateToString(oPW.SVMXC__End_Date__c);
                        entitlementInfoRec.sConOrWarrantyName = oPW.Name;
                        entitlementInfoRec.entType = 'Warranty';
                        return entitlementInfoRec;
                    }
                 }   
            } 
        }    
        return entitlementInfoRec; 
    }    

    public EntitlementInfoWrapper getServiceContractOnLocation(SVMXC__ServiceMax_Processes__c oEntRule, SVMXC__Service_Order__c objWO, Integer iWOIndex){
        EntitlementInfoWrapper entitlementInfoRec;
        //Changes done by Nidhi as part of BAC-4638
        //get number of valid service contracts
        Set<Id> listServiceContracts = new Set<Id>();//Get list of valid Service Contracts for this work order
        if(mapLocationContractLst.containsKey(objWO.SVMXC__site__c) && mapLocationContractLst.get(objWO.SVMXC__site__c).size()>0){
            for(SVMXC__Service_Contract__c objContract : mapLocationContractLst.get(objWO.SVMXC__site__c)){
                boolean isValidLocBasedContract = true;
                if(oEntRule.SVMXC__Match_Contact__c)
                {
                    if(!(objWO.SVMXC__Contact__c != null && mapContactSC.ContainsKey(objWO.SVMXC__Contact__c) && mapContactSC.get(objWO.SVMXC__Contact__c).contains(objContract.Id)))
                        isValidLocBasedContract = false;
                }
                if(oEntRule.SVMXC__Match_Account__c)
                {
                    if(mapWOAccount.get(iWOIndex) != objContract.SVMXC__Company__c)
                        isValidLocBasedContract = false;
                }
                if(isValidLocBasedContract){
                    listServiceContracts.add(objContract.id);
                }
            }
        }
        if(mapLocationContractLst.containsKey(objWO.SVMXC__site__c) && mapLocationContractLst.get(objWO.SVMXC__site__c) != null && mapLocationContractLst.get(objWO.SVMXC__site__c).size() > 0 && !(listServiceContracts.size() > 1 && oEntRule.SVMXC__SM_Disable_AutoEntitlement__c) && ! isdiabledEntitlementOnWo){
            System.debug(Logginglevel.Info, 'mapLocationContractLst : ' + mapLocationContractLst);
            for(SVMXC__Service_Contract__c objContract : mapLocationContractLst.get(objWO.SVMXC__site__c))
            {
                date dtEntitleusing = date.today();
                try
                {
                    if(Setng_EntitleUsingFld != null && (!Setng_EntitleUsingFld.equalsIgnoreCase('Today') && !Setng_EntitleUsingFld.equalsIgnoreCase('CreatedDate')) && objWO.get(Setng_EntitleUsingFld) != null )
                        dtEntitleusing = date.valueOf(String.valueOf(objWO.get(Setng_EntitleUsingFld)));
                }
                catch(exception ex)
                {
                    dtEntitleusing = date.today();
                }
                
                if(objContract.SVMXC__Start_Date__c <= dtEntitleusing  && objContract.SVMXC__End_Date__c >= dtEntitleusing)
                {
                    boolean isValidLocBasedContract = true;
                    if(oEntRule.SVMXC__Match_Contact__c)
                    {
                        if(!(objWO.SVMXC__Contact__c != null && mapContactSC.ContainsKey(objWO.SVMXC__Contact__c) && mapContactSC.get(objWO.SVMXC__Contact__c).contains(objContract.Id)))
                            isValidLocBasedContract = false;
                    }
                    if(oEntRule.SVMXC__Match_Account__c)
                    {
                        if(mapWOAccount.get(iWOIndex) != objContract.SVMXC__Company__c)
                            isValidLocBasedContract = false;
                    }
                    if(oEntRule.SVMXC__Allow_Override__c){
                        entitlementInfoRec = new EntitlementInfoWrapper();
                        System.debug(Logginglevel.Info, 'objContract : ' + objContract);
                        entitlementInfoRec.sConOrWarrantyId = objContract.Id;
                        entitlementInfoRec.sConOrWarrantyName = objContract.Name;
                        entitlementInfoRec.entType = 'Contract';
                        entitlementInfoRec.sLATerms = objContract.SVMXC__Service_Level__c;                        
                        entitlementInfoRec.startDate = dateToString(objContract.SVMXC__Start_Date__c);
                        entitlementInfoRec.endDate = dateToString(objContract.SVMXC__End_Date__c);
                    }else {
                        if(mapServiceContractandCoveredLocations != null && mapServiceContractandCoveredLocations.size() > 0){
                            List<SVMXC__Service_Contract_Sites__c> coveredLocationRec = mapServiceContractandCoveredLocations.get(objContract.Id);
                            for(SVMXC__Service_Contract_Sites__c covLocForServiceContract : coveredLocationRec ){ 
                                if(covLocForServiceContract.SVMXC__Site__c == objWO.SVMXC__Site__c){
                                    Date StartDate ; 
                                    Date EndDate ;
                                    if(covLocForServiceContract.SVMXC__Start_Date__c == null || covLocForServiceContract.SVMXC__End_Date__c == null) {
                                        StartDate = objContract.SVMXC__Start_Date__c; 
                                        EndDate = objContract.SVMXC__End_Date__c;
                                    }
                                    else{
                                        if(objContract.SVMXC__Start_Date__c  <= dtEntitleusing && objContract.SVMXC__End_Date__c  >= dtEntitleusing){ // Defect 024962 - Fix
                                            StartDate = covLocForServiceContract.SVMXC__Start_Date__c; 
                                            EndDate = covLocForServiceContract.SVMXC__End_Date__c; 
                                        }
                                    }
                                    
                                    if(StartDate <= dtEntitleusing  && EndDate >= dtEntitleusing){
                                        if(IsValidLocBasedContract){    
                                            entitlementInfoRec = new EntitlementInfoWrapper();
                                            System.debug(Logginglevel.Info, 'objContract : ' + objContract);
                                            entitlementInfoRec.sConOrWarrantyId = objContract.Id;
                                            entitlementInfoRec.sConOrWarrantyName = objContract.Name;
                                            entitlementInfoRec.entType = 'Contract';                                            
                                            if(covLocForServiceContract.SVMXC__SLA_Terms__c != null)
                                                entitlementInfoRec.sLATerms = covLocForServiceContract.SVMXC__SLA_Terms__c;
                                            else
                                                entitlementInfoRec.sLATerms = objContract.SVMXC__Service_Level__c;
                                            entitlementInfoRec.startDate = dateToString(StartDate);
                                            entitlementInfoRec.endDate = dateToString(EndDate);                                            
                                            return entitlementInfoRec;
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
            } 
        }else if(listServiceContracts.size() > 1 && oEntRule.SVMXC__SM_Disable_AutoEntitlement__c){                  
             isdiabledEntitlementOnWo = true;
        }              
        return entitlementInfoRec;
    }

    EntitlementInfoWrapper getAccServiceContractsOnValidityDates(SVMXC__Service_Order__c objWO,SVMXC__ServiceMax_Processes__c oEntRule){
        Set<Id> contactMatchIds = mapContactSC.containsKey(objWO.SVMXC__Contact__c)? mapContactSC.get(objWO.SVMXC__Contact__c):new Set<Id>();
        Set<Id> locationMatchIds = mapLocationSCON.containsKey(objWO.SVMXC__Site__c)? mapLocationSCON.get(objWO.SVMXC__Site__c):new Set<Id>();
        boolean validScon;
        EntitlementInfoWrapper entitlementInfoRec;
        System.debug(LoggingLevel.INFO, 'mapAccountContractList : ' + mapAccountContractList);
        if(mapAccountContractList.containsKey(objWO.SVMXC__Company__c)){
            for(SVMXC__Service_Contract__c sconRec : mapAccountContractList.get(objWO.SVMXC__Company__c)){
                if(sconRec.SVMXC__Active__c == true){
                    date dtEntitleusing = date.today();
                    if(Setng_EntitleUsingFld != null && (!Setng_EntitleUsingFld.equalsIgnoreCase('Today') && !Setng_EntitleUsingFld.equalsIgnoreCase('CreatedDate')) && objWO.get(Setng_EntitleUsingFld) != null )
                            dtEntitleusing = date.valueOf(String.valueOf(objWO.get(Setng_EntitleUsingFld)));               
                    if(sconRec.SVMXC__Start_Date__c <= dtEntitleusing && sconRec.SVMXC__End_Date__c >= dtEntitleusing){
                        validScon = true;
                        if(oEntRule.SVMXC__Match_Contact__c  && !contactMatchIds.contains(sconRec.Id)){
                            validScon = false;
                        }    
                        if(oEntRule.SVMXC__Match_Location__c && !locationMatchIds.contains(sconRec.Id)){
                            validScon = false;
                        }
                        if(validScon){
                            entitlementInfoRec = new EntitlementInfoWrapper();
                            entitlementInfoRec.sConOrWarrantyId = sconRec.Id;
                            entitlementInfoRec.sConOrWarrantyName = sconRec.Name;
                            entitlementInfoRec.entType = 'Contract';
                            entitlementInfoRec.sLATerms = sconRec.SVMXC__Service_Level__c;                        
                            entitlementInfoRec.startDate = dateToString(sconRec.SVMXC__Start_Date__c);
                            entitlementInfoRec.endDate = dateToString(sconRec.SVMXC__End_Date__c);
                            if(!oEntRule.SVMXC__Allow_Override__c && locationMatchIds != null && locationMatchIds.contains(sconRec.Id)){
                                if(mapServiceContractandCoveredLocations != null && mapServiceContractandCoveredLocations.containskey (sconRec.Id)){
                                    for(SVMXC__Service_Contract_Sites__c coveredLocationRec : mapServiceContractandCoveredLocations.get(sconRec.Id)){
                                        if(coveredLocationRec.Id == objWO.SVMXC__Site__c){
                                            if(coveredLocationRec.SVMXC__Start_Date__c != null && coveredLocationRec.SVMXC__End_Date__c != null && 
                                                coveredLocationRec.SVMXC__Start_Date__c <= dtEntitleusing && coveredLocationRec.SVMXC__End_Date__c >= dtEntitleusing){
                                                entitlementInfoRec.sLATerms = coveredLocationRec.SVMXC__SLA_Terms__c;
                                                entitlementInfoRec.startDate =  dateToString(coveredLocationRec.SVMXC__Start_Date__c);
                                                entitlementInfoRec.endDate = dateToString(coveredLocationRec.SVMXC__End_Date__c);
                                                return entitlementInfoRec;
                                            }
                                        }
                                    }
                                }    
                            }
                        }
                    }
                }
            }
        }
        return entitlementInfoRec;
    }

    //Webservice Method to perform AutoEntitlement on Work Order Added by Nidhi BAC-5144
    //Called from SFM_WebServicesDef
    public SVMXC.SFM_WrapperDef.SFM_PageData updateWoAfterSave(SFM_WrapperDef.SFM_TargetRecord request){
        system.debug('Request = ' + request);
        SVMXC.SFM_WrapperDef.SFM_PageData pagedata = new SVMXC.SFM_WrapperDef.SFM_PageData();
        map<String,Schema.SObjectType> Allobj = new map<String, Schema.SObjectType>();
        map<String, Schema.SObjectType> mapGlobalDesc = Schema.getGlobalDescribe();       
        
        if(!mapGlobalDesc.isEmpty()){
            for(Schema.SObjectType obj : mapGlobalDesc.values()){
                Schema.DescribeSObjectResult result = obj.getDescribe();
                Allobj.put(result.getName(), obj);
            }
        }
        SVMXC.SFM_ServicesDef def = new SVMXC.SFM_ServicesDef();
        Sobject headerSobj = def.SFM_Page_GetHeaderRecord(request, Allobj);
        SVMXC__Service_Order__c objWO = (SVMXC__Service_Order__c) headerSobj;
        //Get the new setting value SET006
        Boolean isEntitlementWebserviceEnabled = false;
        Map<String, String> svmxSettingListEVER007 = new Map<String,String>();
        SVMXC.COMM_Utils_ManageSettings commSettings = new SVMXC.COMM_Utils_ManageSettings();
        svmxSettingListEVER007 = commSettings.SVMX_getSettingList2('EVER007','SET006');
        if(svmxSettingListEVER007 != null && svmxSettingListEVER007.containsKey('SET006') && svmxSettingListEVER007.get('SET006') != null){
           isEntitlementWebserviceEnabled = boolean.valueOf(svmxSettingListEVER007.get('SET006'));
        }       
        try
        {
            //Perform update on WO only if SET006 is true.
            if(isEntitlementWebserviceEnabled && objWO != null && objWO.SVMXC__Perform_Auto_Entitlement__c){
                WORD_TriggerHandler.fromWebservice = true;
                update objWO;
                pagedata.response.message = 'Saved Successfully';
                pagedata.response.success = true;
                pagedata.response.messageType = 'SVMX_SUCCESS';
            }
            
        }
        catch(Exception ex)
        {
            pagedata .response.message = ex.getmessage();
            pagedata.response.success = false;
            pagedata.response.messageType = 'SVMX_ERROR';
            return pagedata;
        }
        
        system.debug('objWO = ' + objWO);
        system.debug('Response = ' + pagedata);
        return pagedata;
    }
}