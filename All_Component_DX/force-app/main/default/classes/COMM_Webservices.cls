global with sharing class COMM_Webservices {
    /*
     *Type : Wrapper Class
     *Used : "Key value" wrapper class
     *Desc : This is an additional parameter
     */
    global class KeyValue
    {
        webservice String name{get;set;}
        webservice String value{get;set;}
        global KeyValue()
        {}
        global KeyValue(String name, String value)
        {
        this.name = name;
        this.value = value;
        }
    }
    /*
     *Type : Webservice Method
     *Used : OptiMax Webservices
     *Desc  : To identify the version of running Apex Code
     */
    WebService static  List<KeyValue> SVMX_GetSvmxVersion(List<KeyValue> request)
    {
        List<KeyValue> response = new List<KeyValue>();
        String VersionNumber = String.valueOf(Decimal.valueOf(String.valueOf(System.requestVersion())).setScale(5));
        response.add(new KeyValue('VERSION', VersionNumber));
        return response;
    }
    
    //This method to retrieve svmx license type
    WebService static Boolean SVMX_isEnterpriseLicense_WS()
    {
        COMM_Utils cu = new COMM_Utils();
        return cu.SVMX_isEnterpriseLicense();
    }
    

    //This method to check if License is permitted for given object
    WebService static Boolean SVMX_isObjectLicensed_WS(String refObjName)
    { 
        COMM_Utils cu = new COMM_Utils();
        return cu.SVMX_isObjectLicensed(refObjName);
    }
        
    
    //Get list of permitted standard objects  in the Org
    WebService static List<String> SVMX_getPermittedStandardObjectList_WS()
    {
        COMM_Utils cu = new COMM_Utils();
        Map<String,Boolean> retMap = new Map<String,Boolean>();
        retMap = cu.SVMX_getPermittedStandardObjectList();
        List<String> retList = new List<String>();
        for (String s : retMap.keySet())
        {
            retList.add(s);
        }
        return retList;
    }
    
    //This method to Update svmx license type
    WebService static Boolean SVMX_updateLicenseType_WS(String licenseKey, String licenseType,String devKey)
    { 
        COMM_Utils cu = new COMM_Utils();
        return cu.SVMX_updateLicenseType(licenseKey,licenseType,devKey);
    }
    
    //This method to Get svmx property elements
    WebService static List<SVMXC__ServiceMax_Property_Elements__c> SVMX_getPropertyElements_WS()
    { 
        COMM_Utils cu = new COMM_Utils();
        return cu.SVMX_getPropertyElements();
    }
    
    //This method to Update svmx property elements
    WebService static Boolean SVMX_updatePropertyElements_WS(List<SVMXC__ServiceMax_Property_Elements__c> propEleLst, String licenseKey, String licenseType, String devKey)
    { 
        COMM_Utils cu = new COMM_Utils();
        return cu.SVMX_updatePropertyElements(propEleLst, licenseKey,  licenseType,devKey);
    }
    
    //Added for the story BAC-4512
    WebService static Boolean SVMX_UpdateGetPriceFields_WS(List<SVMXC__GetPrice_Fields__c> lstGetPriceField, String licenseKey, String licenseType, String devKey)
    { 
        COMM_Utils_V2 objCOMM_UtilsV2 = new COMM_Utils_V2();
        return objCOMM_UtilsV2.SVMX_UpdateGetPriceFields(lstGetPriceField, licenseKey, licenseType, devKey);
    }
    
    WebService static Boolean SVMX_createSchedulersForAPLUDAT_WS(String strParam,Boolean isAPL)
    { 
       if(strParam != null && strParam.length() > 0 && strParam == 'SCON')
       {
           SVMXC.SCON_Scheduler objSCONScheduler = new SVMXC.SCON_Scheduler();
           system.schedule('ServiceMax SCON Scheduler','0 0 * ? * *',objSCONScheduler );
           return true;
       }
       else if(isAPL)
       {
            SVMXC.APL_ForwardShipmentEngine objShipRemaining = new SVMXC.APL_ForwardShipmentEngine();
            system.schedule('ServiceMax APL Scheduler','0 0 * ? * *',objShipRemaining );
            return true;
       }
       else if(!isAPL)
       {
            SVMXC.UDAT_CustomerUsageScheduler objUDCSched = new SVMXC.UDAT_CustomerUsageScheduler();
            system.schedule('ServiceMax UDAT Scheduler','0 0 * ? * *',objUDCSched);
            return true;
       }
       else if(strParam != null && strParam.length() > 0 && strParam == 'Notifications' && !isAPL)
       {
           SVMXC.SchedulePushNotifications objNotificationScheduler = new SVMXC.SchedulePushNotifications();
           System.schedule('Schedule Push Notifications', '0 0 0 * * * *' , objNotificationScheduler);
           return true;
       }
       return false;
       
    }
    WebService static List<KeyValue> SVMX_CURD_OnServiceMaxProperties_WS(List<KeyValue> inputRequest)
    { 
        COMM_Utils cu = new COMM_Utils();
        return cu.SVMX_CURD_OnServiceMaxProperties(inputRequest);
    }
    //Webservices For Create Server Cache..
    webservice static String saveDescribeLayoutCache_WS(String recordTypePicklist, String strObjectName){
        system.debug('============' + recordTypePicklist);
        SVMXC.COMM_ServerCacheUtils saveIt = new SVMXC.COMM_ServerCacheUtils ();
        saveIt.saveDescribeLayoutCache(recordTypePicklist,strObjectName);
        return 'Success';
    }
    
    webservice static String saveDescribeObjectCache_WS(String dependendPicklist, String strObjectName){
        system.debug('============' + dependendPicklist);
        SVMXC.COMM_ServerCacheUtils saveIt = new SVMXC.COMM_ServerCacheUtils ();
        saveIt.saveDescribeObjectCache(dependendPicklist,strObjectName);
        return 'Success';
    }
    webservice static list<ObjectDefination>  getObjectDefination_WS(){
        SVMXC.COMM_ServerCacheUtils getDefination = new SVMXC.COMM_ServerCacheUtils ();
        return getDefination.getObjectDefinationForServceCache();
        
    }
    //Structure for Create Server Cache..
    global class ObjectDefination{
        webservice String objectName{get;set;}
        webservice String objectLabel{get;set;}
        webservice list<String> recordTypeId = new list<String>();
        webservice list<String> picklistFields = new list<String>();
        
        global ObjectDefination(String objectName, list<String> recordTypeId, list<String> picklistFields){
            this.objectName = objectName;
            this.recordTypeId = recordTypeId;
            this.picklistFields = picklistFields;
        }
        global ObjectDefination(String objectName, list<String> recordTypeId, list<String> picklistFields,String objectLabel){
            this.objectName = objectName;
            this.objectLabel = objectLabel;
            this.recordTypeId = recordTypeId;
            this.picklistFields = picklistFields;
        }
        global ObjectDefination(){}
    }
    // creating a generic WS method to call verious method
    WebService static List<KeyValue> SVMX_doPerform_WS(List<KeyValue> request)
    {
        COMM_Utils objCommUtil = new COMM_Utils();
        List<KeyValue> lstResponse = new List<KeyValue>();
        for(KeyValue keyVal : request)
        {
            if(keyVal.name.toUpperCase() == 'SVMX_NAMED_EXPRESSIONS_UPD_REF_FLDS')
            {
                KeyValue objKeyVal = new KeyValue();
                objKeyVal.name = keyVal.name;
                objKeyVal.value = String.valueOf(objCommUtil.SVMX_Named_Expressions_Upd_Ref_Flds());
                lstResponse.add(objKeyVal);
            }
        }
        return lstResponse;
    }
    
    //This method to check object and field permission
    WebService static List<KeyValue> checkPermission(List<String> objectList, String accessType)
    {   
        return new List<KeyValue>();
    }
}