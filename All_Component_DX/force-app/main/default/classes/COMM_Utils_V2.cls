/**
Please use this class going forward for using legacy class COMM_Utils functionality.
 *******************************************************************************************
 *    ID        Name                   Date            Comment
 ********************************************************************************************
 *              Jaysukh patel        26 Dec 2019        modified method SVMX_getDefaultPicklistValue,
                                                        getSFDCSVMXInternalObjects
 ***************************************************************************************************
**/
global with sharing class COMM_Utils_V2 {
      
    public static Map<String, Set<String>> mapObjectNameAndListOfDupFields = new Map<String, Set<String>>();
    public static Map<String, List<String>> mapObjectNameAndProcessedFields = new Map<String, List<String>>();
    public static Map<String, Set<String>> mapObjectNameAndProcessedFieldsSet = new Map<String, Set<String>>();
    
    //CRUD security related functions
    //public static COMM_SecurityUtils securityUtils = COMM_SecurityUtils.getInstance();          
  // Returns if it's Enterprise License or Not
  Public Boolean SVMX_isEnterpriseLicense(){ 
    Boolean retBoolean = false;
    List<SVMXC__ServiceMax_Properties__c> sprop = new List<SVMXC__ServiceMax_Properties__c>();
    sprop = [Select Name, SVMXC__Key__c, SVMXC__Value__c from SVMXC__ServiceMax_Properties__c where SVMXC__Key__c = 'License Type' and Name = 'PROP001' Limit 1]; //SDL-SVMX-FLS-NOT-ENFORCED-META-DATA
    if (sprop != null && sprop.size() >0) {
        if(sprop[0].SVMXC__Value__c.toUpperCase() == 'ENTERPRISE')
            retBoolean = true;
    } 
    return retBoolean;
    }
    //new method by hh 15/07/2011
    public Map<String,String> getSFDCSVMXInternalObjects() 
    {
        Boolean isEntLicense = SVMX_isEnterpriseLicense();
        Map<String,Boolean> perStdObjMap = new Map<String,Boolean>();
        perStdObjMap = SVMX_getPermittedStandardObjectList();
        
        List<SVMXC__ServiceMax_Property_Elements__c> SFDCSVMX_InternalObjectList = [Select Name, SVMXC__Element_Type__c,SVMXC__Element_Value__c,     SVMXC__Property_Key__c from SVMXC__ServiceMax_Property_Elements__c where SVMXC__Property_Key__c = 'SFDC SVMX INTERNAL OBJLIST' ];
        Map<String,String> MapInternalObjectNamesLst = new Map<String,String>();
        Map<String,String> QualifiedInternalObjectLst = new Map<String,String>();
        for(SVMXC__ServiceMax_Property_Elements__c propertyEle : SFDCSVMX_InternalObjectList)
        {
            MapInternalObjectNamesLst.put(propertyEle.SVMXC__Element_Value__c, propertyEle.SVMXC__Element_Type__c);
        }
        //BAC-5355
        Map<String,Schema.SObjectType> allObjs = COMM_Utils_DescribeCall.getInstance().getGlobalDescribeCall();
        //MAP<String,Schema.SObjectType> allObjs = Schema.getGlobalDescribe();
        for(String key: allObjs.keySet())
          {
            Schema.SObjectType objT = allObjs.get(key) ;
            Schema.DescribeSObjectResult result = objT.getDescribe();
            
            String ObjName = result.getName();
            Boolean IsCustomObject = result.isCustom();
            if(ObjName.endsWith('Feed') || ObjName.endsWith('Tag') || ObjName.endsWith('History') || ObjName.endsWith('Share') ) continue;
            //system.debug('zzzzzzzzz1'+perStdObjMap);
            if(IsCustomObject && !(MapInternalObjectNamesLst != null && (MapInternalObjectNamesLst.containsKey(ObjName))))
            {
                //QualifiedInternalObjectLst.put(ObjName, objT.getDescribe().getLabel());
                QualifiedInternalObjectLst.put(ObjName, result.getLabel());
            }
            else if(!(IsCustomObject))
            {
                if( ((MapInternalObjectNamesLst!= null && !(MapInternalObjectNamesLst.containsKey(ObjName))) || (MapInternalObjectNamesLst == null) ) && (perStdObjMap.containsKey(ObjName)) )
                {      
                        //QualifiedInternalObjectLst.put(ObjName, objT.getDescribe().getLabel());
                        QualifiedInternalObjectLst.put(ObjName, result.getLabel());
                }
            }
         }
        //system.debug('zzzzzzzzz2'+perStdObjMap);
        /*for(String str :QualifiedInternalObjectLst.keyset()){
            //system.debug('zzzzzzzzz3'+str);
        }*/
        return QualifiedInternalObjectLst;
    }

    //Account a = new Account (CreatedDate=system.today(), name = 'A');
    
  // Returns if it's Enterprise License or Not
  public Boolean SVMX_updateLicenseType(String licenseKey, String licenseType, String devKey){
    Boolean retBoolean = false;
    
    if((devKey != null) && (devKey.length() > 0)){
        try {
            Blob blob1 =  EncodingUtil.base64Decode(devKey);
            if( !((blob1.toString()).equals('VGhhdHpXaGF0U2hlU2FpZA==')) ) return false;
        }catch(Exception ex) {
             return false;
        }
    } 
        
    List<SVMXC__ServiceMax_Properties__c> sprop = new List<SVMXC__ServiceMax_Properties__c>();
    sprop = [Select Id, Name, SVMXC__Key__c, SVMXC__Value__c from SVMXC__ServiceMax_Properties__c where SVMXC__Key__c = 'License Type' and Name = 'PROP001' Limit 1]; //SDL-SVMX-FLS-NOT-ENFORCED-META-DATA
    //Get the LicenseType by decrupting licenseKey
    String deCruptedLicenseType = SVMX_decruptLicenseKey(licenseKey);
    System.debug('TEST101:'+deCruptedLicenseType);
    if(licenseType.toUpperCase() != deCruptedLicenseType.toUpperCase()) return false;
    try{
        if (sprop != null && sprop.size() >0) {
            //Record already exist, Updated it
            for (SVMXC__ServiceMax_Properties__c sp :sprop){
                sp.SVMXC__Value__c = licenseType;
                try {
                    System.debug('TEST103:'+sp);
                    update sp; //SDL-SVMX-FLS-NOT-ENFORCED-META-DATA
                    retBoolean =true;
                } catch (Exception ex){ return false;}
            }
        }
        else {
            System.debug('TEST102:');
            //Record NOT exist, Create it
            SVMXC__ServiceMax_Properties__c sp = new SVMXC__ServiceMax_Properties__c();
            sp.Name = 'PROP001';
            sp.SVMXC__Key__c = 'License Type';
            sp.SVMXC__Value__c = licenseType;
            try {
                    insert sp; //SDL-SVMX-FLS-NOT-ENFORCED-META-DATA
                    retBoolean =true;               
                } catch (Exception ex){ return false;}
        }
    }
    catch(Exception ex) {       return false;       }
    return retBoolean;
  } 
  
  //this method is used to perform CURD operations on the ServiceMax Properties
    public List<COMM_Webservices.KeyValue> SVMX_CURD_OnServiceMaxProperties(List<COMM_Webservices.KeyValue> inputRequest)
    {
        List<COMM_Webservices.KeyValue> lstResponse = new List<COMM_Webservices.KeyValue>();
        String strAction = '', strSVMXPropertyKey = '', strSVMXPropertyName = '', strSVMXPropertyValue = '';
        try
        {
            for(COMM_Webservices.KeyValue currReq : inputRequest)
            {
                if(currReq.name == 'Action')
                {
                    strAction = currReq.value;
                }else if(currReq.name == 'Key')
                {
                    strSVMXPropertyKey = currReq.value;
                }else if(currReq.name == 'Value')
                {
                    strSVMXPropertyValue = currReq.value;
                }else if(currReq.name == 'Name')
                {
                    strSVMXPropertyName = currReq.value;
                }
            }
            if(strAction != null && strAction.length() > 0 && strAction == 'INSERT')
            {
                insertPropertyElement(strSVMXPropertyName,strSVMXPropertyKey,strSVMXPropertyValue);                 
            }else if(strAction != null && strAction.length() > 0 && strAction == 'READ')
            {
                List<SVMXC__ServiceMax_Properties__c> lstSVMXProperty = readPropertyElement(strSVMXPropertyKey);
                if(lstSVMXProperty != null && lstSVMXProperty.size() > 0)
                {
                    lstResponse.add(new COMM_Webservices.KeyValue('Name',lstSVMXProperty[0].Name));
                    lstResponse.add(new COMM_Webservices.KeyValue('Key',lstSVMXProperty[0].SVMXC__Key__c));
                    lstResponse.add(new COMM_Webservices.KeyValue('Value',lstSVMXProperty[0].SVMXC__Value__c));
                    lstResponse.add(new COMM_Webservices.KeyValue('RECORDS',lstSVMXProperty.size() + ''));
                }else
                {
                    lstResponse.add(new COMM_Webservices.KeyValue('RECORDS','0'));
                }
            }
            lstResponse.add(new COMM_Webservices.KeyValue('Success','TRUE'));           
            
        }catch(Exception Ex)
        {
            lstResponse.add(new COMM_Webservices.KeyValue('Error',Ex.getMessage()));
        }
        return lstResponse;
    }
    
    private void insertPropertyElement(string name,string key, string value)
    {
        SVMXC__ServiceMax_Properties__c sp = new SVMXC__ServiceMax_Properties__c();
        sp.Name = name;
        sp.SVMXC__Key__c = key;
        sp.SVMXC__Value__c = value;
        //insert sp; 
        if(COMM_SecurityUtils.getInstance().verifyFieldAccess(sp, COMM_SecurityUtils.Access.Createable)){
            insert sp; //SDL-SVMX-CREATE-UPDATE-FLS-ENFORCED
        }
        else{
            throw new COMM_SecurityUtils.SecurityAccessException(System.label.COMM001_TAG142);
        }
    }
    private List<SVMXC__ServiceMax_Properties__c> readPropertyElement(string key)
    {
        List<SVMXC__ServiceMax_Properties__c> lstProps = [Select Name,SVMXC__Key__c,SVMXC__Value__c from SVMXC__ServiceMax_Properties__c where SVMXC__Key__c =: key limit 1]; //SDL-SVMX-FLS-NOT-ENFORCED-META-DATA
        return lstProps;
    }
  
  
  public String SVMX_decruptLicenseKey(String licenseKey){
    //Decrupt the LicenseKey and return the LicenseType
    //Add code here to decrupt key
        Blob decryptoKey=EncodingUtil.base64Decode('Mm83T09S42nMo70pM5yBbA3EDQX5C4g8EUiX7QN76WQ=');
        String retStr = '';
        String OrgID;
        String licType;
        String DecStr = Crypto.decryptWithManagedIV('AES256', decryptoKey, EncodingUtil.base64Decode(licenseKey)).toString();
        //Blob blob1 =  EncodingUtil.base64Decode(licenseKey);                 
        //String DecStr = blob1.toString();
        List<String> sp = new List<String>();
        sp = DecStr.split('~', 2);
        System.debug('TEST 104:'+DecStr);
        System.debug('TEST 105:'+sp);
        if(sp.size()>1){
            OrgID = sp.get(0);
            licType = sp.get(1);
            
        System.debug('TEST 106:'+OrgID);
        System.debug('TEST 107:'+userInfo.getOrganizationId().subString(0,15));
            if (licType == null || OrgID == null || (OrgID != userInfo.getOrganizationId().subString(0,15)))
                return retStr;
            else 
                retStr = licType.toUpperCase();
        }
        
    return retStr;
  }
  
  
  
  public  List<SVMXC__ServiceMax_Property_Elements__c> SVMX_getPropertyElements( ){
    //Write logic to upsert the property elements
    List<SVMXC__ServiceMax_Property_Elements__c> propEleLst = new List<SVMXC__ServiceMax_Property_Elements__c>();
    try{
        propEleLst = [Select Name, SVMXC__Element_Type__c, SVMXC__Element_Value__c from SVMXC__ServiceMax_Property_Elements__c]; //SDL-SVMX-FLS-NOT-ENFORCED-META-DATA
        return propEleLst;
    }
    catch(Exception ex) {
        return propEleLst; //ex.getMessage();
    }
  }
  
  //CUD Says Create,Update and Delete and Action represents this
  public INTF_WebServicesDef.INTF_SFMResponse SVMX_CUD_OnPropertyElements(INTF_WebServicesDef.INTF_SFMRequest reqPropertyElements, String action)
  {
        INTF_WebServicesDef.INTF_SFMResponse objResponse = new INTF_WebServicesDef.INTF_SFMResponse();
        try
        {
            String strDevKey = null;
            if(reqPropertyElements.name == 'DevKey')
                strDevKey = reqPropertyElements.value;
            if(strDevKey == null || !strDevKey.equals('VGhhdHpXaGF0U2hlU2FpZA==')) return objResponse;
            if(action.equals('INSERT'))
            {
                if(reqPropertyElements.valueMap != null && reqPropertyElements.valueMap.size() > 0)
                {
                    List<SVMXC__ServiceMax_Property_Elements__c> lstInsertElements = new List<SVMXC__ServiceMax_Property_Elements__c>();
                    for(INTF_WebServicesDef.SVMXMap objParentInfo : reqPropertyElements.valueMap)
                    {
                        SVMXC__ServiceMax_Property_Elements__c objPropElement = new SVMXC__ServiceMax_Property_Elements__c();
                        for(INTF_WebServicesDef.SVMXMap objChildInfo : objParentInfo.valueMap)
                        {                   
                            if(objChildInfo.key == 'NAME')
                            {
                                objPropElement.Name = objChildInfo.value;
                            }
                            else if(objChildInfo.key == 'SVMXC__Property_Key__c')
                            {
                                objPropElement.SVMXC__Property_Key__c = objChildInfo.value;
                            }
                            else if(objChildInfo.key == 'SVMXC__Element_Type__c')
                            {
                                objPropElement.SVMXC__Element_Type__c = objChildInfo.value;
                            }
                            else if(objChildInfo.key == 'SVMXC__Element_Value__c')
                            {
                                objPropElement.SVMXC__Element_Value__c = objChildInfo.value;
                            }
                            
                        }
                        lstInsertElements.add(objPropElement);
                    }
                    insert lstInsertElements; //SDL-SVMX-FLS-NOT-ENFORCED-META-DATA
                }
            } 
            return objResponse;
        }catch(Exception ex)
        {
            throw ex;
        }   
  }
  
  public Boolean SVMX_updatePropertyElements(List<SVMXC__ServiceMax_Property_Elements__c> propEleLst, String licenseKey, String licenseType,String devKey){
    //Write logic to upsert the property elements
    if((devKey != null) && (devKey.length() > 0)){
        try {
            Blob blob1 =  EncodingUtil.base64Decode(devKey);
            if( !((blob1.toString()).equals('VGhhdHpXaGF0U2hlU2FpZA==')) ) return false;
        } catch(Exception ex) {
             return false;
        }
    } 
    
    try{
        String deCruptedLicenseType = SVMX_decruptLicenseKey(licenseKey);
        if(licenseType != deCruptedLicenseType) return false;
        Set<String> propertyName = new Set<String>();
        List<SVMXC__ServiceMax_Property_Elements__c> upsertProperty = new List<SVMXC__ServiceMax_Property_Elements__c>();
        List<SVMXC__ServiceMax_Property_Elements__c> existingProperty = new List<SVMXC__ServiceMax_Property_Elements__c>();
        Map<String, SVMXC__ServiceMax_Property_Elements__c> propertyMap = new Map<String, SVMXC__ServiceMax_Property_Elements__c>();
        existingProperty = [Select Name, SVMXC__Property_Key__c, SVMXC__Element_Type__c, SVMXC__Element_Value__c from SVMXC__ServiceMax_Property_Elements__c where name like 'PELE%']; //SDL-SVMX-FLS-NOT-ENFORCED-META-DATA
        delete existingProperty; //SDL-SVMX-FLS-NOT-ENFORCED-META-DATA
        /*for(SVMXC__ServiceMax_Property_Elements__c prop: existingProperty){
            propertyMap.put(prop.Name, prop);
            propertyName.add(prop.Name);
        }*/
        for(SVMXC__ServiceMax_Property_Elements__c prop: propEleLst){
            /*if(propertyName.contains(prop.Name)){
                SVMXC__ServiceMax_Property_Elements__c tpEle = propertyMap.get(prop.Name);
                tpEle.SVMXC__Element_Value__c = prop.SVMXC__Element_Value__c;
                tpEle.SVMXC__Element_Type__c = prop.SVMXC__Element_Type__c;
                tpEle.SVMXC__Property_Key__c = prop.SVMXC__Property_Key__c;
                upsertProperty.add(tpEle);
            }
            else*/
            upsertProperty.add(prop);
        }
        
        if( !upsertProperty.isEmpty() && COMM_SecurityUtils.getInstance().verifyFieldAccess( upsertProperty, COMM_SecurityUtils.Access.Upsertable ) ) {
            upsert upsertProperty; //SDL-SVMX-CREATE-UPDATE-FLS-ENFORCED
        } else {
            throw new COMM_SecurityUtils.SecurityAccessException( System.Label.COMM001_TAG142 );
        }
        
        return true;
    }
    catch(Exception ex) {
        return false; //ex.getMessage();
    }
  }
  
    //Added for the story BAC-4512
    public Boolean SVMX_UpdateGetPriceFields(List<SVMXC__GetPrice_Fields__c> lstGetPriceField, String licenseKey, String licenseType, String devKey){
        if((devKey != null) && (devKey.length() > 0)){
            try {
                Blob blob1 =  EncodingUtil.base64Decode(devKey);
                if( !((blob1.toString()).equals('VGhhdHpXaGF0U2hlU2FpZA==')) ) 
                    return false;
            }
            catch(Exception ex) {
                 return false;
            }
        }
        
        try {
            String deCruptedLicenseType = SVMX_decruptLicenseKey(licenseKey);
            if(licenseType != deCruptedLicenseType) 
                return false;
            
            List<SVMXC__GetPrice_Fields__c> existingGetPriceFields = [Select Id from SVMXC__GetPrice_Fields__c where name like 'GP%']; //SDL-SVMX-FLS-NOT-ENFORCED-META-DATA
            if(existingGetPriceFields.size() > 0){
                delete existingGetPriceFields; //SDL-SVMX-FLS-NOT-ENFORCED-META-DATA
            }
            if(lstGetPriceField.size() > 0){
                upsert lstGetPriceField; //SDL-SVMX-FLS-NOT-ENFORCED-META-DATA
            }
            return true;
        }
        catch(Exception ex) {
            System.debug('Exception in SVMX_UpdateGetPriceFields: '+ex.getMessage());
            return false;
        }
    }
  
    // Returns Standard Object Permitted for the SVMX License Type in the ORG
  public Map<String,Boolean> SVMX_getPermittedStandardObjectList(){
    Map<String,Boolean> retMap = new Map<String,Boolean>();
    List<SVMXC__ServiceMax_Properties__c> sprop = new List<SVMXC__ServiceMax_Properties__c>();
    sprop = [Select Name, SVMXC__Key__c, SVMXC__Value__c from SVMXC__ServiceMax_Properties__c where SVMXC__Key__c = 'License Type' and Name = 'PROP001' Limit 1]; //SDL-SVMX-FLS-NOT-ENFORCED-META-DATA
    if (sprop != null && sprop.size() >0) {
        String licenseType = sprop[0].SVMXC__Value__c;
        system.debug('licenseType'+licenseType);
        List<SVMXC__ServiceMax_Property_Elements__c> spropLst = new List<SVMXC__ServiceMax_Property_Elements__c>();
        spropLst = [Select Name, SVMXC__Element_Type__c, SVMXC__Element_Value__c from SVMXC__ServiceMax_Property_Elements__c where SVMXC__Property_Key__c =:licenseType ]; //SDL-SVMX-FLS-NOT-ENFORCED-META-DATA
        system.debug('spropLst'+spropLst);
        if(spropLst != null && spropLst.size() >0) {
            for(SVMXC__ServiceMax_Property_Elements__c sp: spropLst){
                String objName = String.valueOf(sp.SVMXC__Element_Value__c);
                system.debug('objName'+objName);
                retMap.put(objName, true);      
            }

        }
    }
    return retMap;
  }
  // this method return map of permitable object according to given license type
    public Map<String,Boolean> SVMX_getPermittedStandardObjectListAccToLicense(String strLicenseType){
        if(strLicenseType != '')
        {
            Map<String, Boolean> mapReturn = new Map<String, Boolean>();
            List<SVMXC__ServiceMax_Property_Elements__c> spropLst = new List<SVMXC__ServiceMax_Property_Elements__c>();
            spropLst = [Select Name, SVMXC__Element_Type__c, SVMXC__Element_Value__c, SVMXC__Property_Key__c  from SVMXC__ServiceMax_Property_Elements__c where SVMXC__Property_Key__c =: strLicenseType ];//'Enterprise' //SDL-SVMX-FLS-NOT-ENFORCED-META-DATA
            if(spropLst != null && spropLst.size() >0) {
                for(SVMXC__ServiceMax_Property_Elements__c sp: spropLst){
                    String strObjName = String.valueOf(sp.SVMXC__Element_Value__c);
                    mapReturn.put(strObjName, true);
                    System.debug('permission object : '+strObjName);
                }
            }
            return mapReturn;
        }else
            return SVMX_getPermittedStandardObjectList();
    }

// Returns Standard Object Permitted for the SVMX License Type in the ORG
  public  Boolean SVMX_isObjectCustom(String refObjName){
    Boolean retBoolean = false;
    Integer ind = 0;
    String objSuffix = '';
    if(refObjName == null || refObjName.length() == 0) return retBoolean;
    
    //Check if object is Custom/Standard? If '__c' exist at the end it's custom
    ind = refObjName.lastIndexOf('__');
    if(ind != -1)
    {
        objSuffix = refObjName.substring(ind,refObjName.length());
    }   
    if (objSuffix != null && objSuffix == '__c') {
        retBoolean = true;
    }
    return retBoolean;
  }
    
    
    
    // Returns Standard Object Permitted for the SVMX License Type in the ORG
  public  Boolean SVMX_isObjectLicensed(String refObjName){
    Boolean retBoolean = false;
    Integer ind = 0;
    String objSuffix = '';
    if(refObjName == null || refObjName.length() == 0) return retBoolean;
    
    //Check if object is Custom/Standard? If '__c' exist at the end it's custom
    ind = refObjName.lastIndexOf('__');
    if(ind != -1)
    {
        objSuffix = refObjName.substring(ind,refObjName.length());
    }
    if (objSuffix != null && objSuffix == '__c') {
        retBoolean = true;
    }
    else
    {
        List<SVMXC__ServiceMax_Properties__c> sprop = new List<SVMXC__ServiceMax_Properties__c>();
        sprop = [Select Name, SVMXC__Key__c, SVMXC__Value__c from SVMXC__ServiceMax_Properties__c where SVMXC__Key__c = 'License Type'  Limit 1]; //SDL-SVMX-FLS-NOT-ENFORCED-META-DATA
        
        if (sprop != null && sprop.size() >0) {
            String licenseType = sprop[0].SVMXC__Value__c;
            if(licenseType.toUpperCase() == 'ENTERPRISE') return true;
            
            List<SVMXC__ServiceMax_Property_Elements__c> spropLst = new List<SVMXC__ServiceMax_Property_Elements__c>();
            spropLst = [Select Name, SVMXC__Element_Type__c, SVMXC__Element_Value__c from SVMXC__ServiceMax_Property_Elements__c where SVMXC__Property_Key__c =:licenseType and SVMXC__Element_Value__c =: refObjName]; //SDL-SVMX-FLS-NOT-ENFORCED-META-DATA
            if(spropLst != null && spropLst.size() >0) {
                retBoolean = true;
            }
        }
    }
    return retBoolean;
  }


  global DateTime getDateTimeInTimezone(Date givenDate, Time givenTime, String timeZoneSidKey){
        DateTime tempDateTime = DateTime.newInstanceGmt(givenDate, givenTime);
        String gmtDateTimeStr = tempDateTime.formatGmt('yyyy-MM-dd HH:mm:ss');
        String tmzDateTimeStr = tempDateTime.format('yyyy-MM-dd HH:mm:ss', timeZoneSidKey);
        DateTime gmtDateTime = DateTime.valueOfGmt(gmtDateTimeStr);
        DateTime tmzDateTime = DateTime.valueOfGmt(tmzDateTimeStr);
        Long gmtMillisecs = gmtDateTime.getTime();
        Long tmzMillisecs = tmzDateTime.getTime();
        Integer tmzOffsetMins = Integer.valueOf(String.valueOf((gmtMillisecs - tmzMillisecs)/60000));
        DateTime retDateTime = gmtDateTime.addMinutes(tmzOffsetMins);
    
        // Check if the givenTime and returnedTime are the same.
        // If not (can happen during DST transition points), adjust the returned date time.
        String[] convTimeStr = retDateTime.format('HH:mm:ss', timeZoneSidKey).split(':');
        Time convTime = Time.newInstance(Integer.valueOf(convTimeStr[0]), Integer.valueOf(convTimeStr[1]), Integer.valueOf(convTimeStr[2]), 0);
        if (givenTime != convTime) {
            Integer givenHrMin = (givenTime.hour() * 60) + givenTime.minute();
            Integer convHrMin = (convTime.hour() * 60) + convTime.minute();
            Integer diff = givenHrMin - convHrMin;
            retDateTime = retDateTime.addMinutes(diff);
        }       
        return retDateTime;// Returns DateTime in Given TZ
    }
   
      //Return the default val for a field in object
    global String SVMX_getDefaultPicklistValue(String ObjName, String FieldName)
    {
        String DefVal = '';
        List<String> lstStr = new List<String>();
        lstStr.add(FieldName);
        Map<String,String> resMap = new Map<String,String>();
        resMap = SVMX_getDefaultPicklistValue(ObjName,lstStr);
        if(resMap.size()> 0)
        {
            if(resMap.containsKey(FieldName) && resMap.get(FieldName)!= null)
            {   
                DefVal = resMap.get(FieldName);
                return DefVal;
            }   
        }   
        return null;
    }
    global Map<String,String> SVMX_getDefaultPicklistValue(String objName, List<String> fieldName)
    {
        //BAC-5355 start
        Map<String,String> mapofDefaulPickList = new Map<String,String>();
        mapofDefaulPickList = COMM_Utils_DescribeCall.getInstance().getDefaultPicklistValue(objName,fieldName);
        
        //Old start
        /*
        Map<String, Schema.SObjectType> allObjs = Schema.getGlobalDescribe();
        string DefVal;
        system.debug('TEST1:'+ObjName+FieldName); 
        for(String s: allObjs.keyset()){
        system.debug('TEST222:'+s);
        }
        Map<String,String> MapofDefaulPickList = new Map<String,String>();
        List<Schema.SObjectType> listObjName = allObjs.values();

        Map<String,Schema.SObjectField> objfieldMap = new Map<String,Schema.SObjectField>();
        if(listObjName != null && listObjName.size() > 0)
        {
           // get the field map of selected Object
            for(Schema.SObjectType s:listObjName)
            {
                Schema.Describesobjectresult DSO = s.getDescribe();
                system.debug('TEST222:'+s);
                if(DSO != null && DSO.getname() == ObjName )
                {
                    objfieldMap = DSO.fields.getMap();
                    for(Integer i = 0; i < FieldName.size(); i++)
                    {     
                        for(Schema.SObjectField fld:objfieldMap.values())
                        {
                           Schema.DescribeFieldResult FSO = fld.getDescribe();
                          
                           if(FSO != null &&  FSO.getname() == FieldName[i])
                           {
                            
                                if(FSO.getType() == Schema.DisplayType.PickList)
                                {
                                    List<Schema.PicklistEntry> P = FSO.getPicklistValues(); // returing picklist values
                                    for(integer v=0;v<p.size();v++)
                                    {
                                        if(p[v].isDefaultValue()) // check for default value
                                        {
                                            DefVal = p[v].getValue();
                                            system.debug('DefVal'+DefVal);
                                            if(DefVal != null && DefVal.length()> 0)
                                                MapofDefaulPickList.put(FieldName[i],DefVal);
                                        }  
                                    }
                                 } 
                                 break;  
                             }
                         }  
                      }  
                       break;
                   }
                 
                }
            }
        system.debug('TEST2:'+MapofDefaulPickList);
        return MapofDefaulPickList;*/
        //old end
        //BAC-5355 End
        return mapofDefaulPickList;
    }
    global List<String> SVMX_getFieldList( Map<String,Schema.SObjectField> fieldMap, Boolean selectAllFields)
    {
        List<String> fieldList = new List<String>();        
        //build dynamic list of fieldnames
        for (String fieldKey : fieldMap.keySet()) 
            {
            Schema.SObjectField fsObj = fieldMap.get(fieldKey);
            Schema.DescribeFieldResult f = fsObj.getDescribe();
            String fieldName = f.getName();            
            if (selectAllFields == true) 
                {
                    fieldList.add(fieldName);
                    //System.debug('Adding '+fieldName);
                } 
            else {
                if (f.getName()=='Id' || f.isNameField() || f.isCustom()) {
                    fieldList.add(fieldName);
                    //System.debug('Adding :else: '+fieldName);
                }
            }
        }        
        return fieldList;
   }
 
   global String SVMX_getFieldNamesFromList(List<String> fieldList) {
        String fieldNames = '';
        for (String field : fieldList) {
            if (fieldNames.length()>0) {
                fieldNames += ',';
            }
            fieldNames += field;
        }        
        return fieldNames;
    }  

   global Boolean SVMX_IsValidInstallationKey(String InstKey, SObject obj, Map<String, String> svmxTagList) {
             //CanNot Remove this Method, because its packaged once
              return false;
    }
      
    global Boolean SVMX_IsValidInstallationKey(String InstKey, SObject obj) {
        Blob blob1 =  EncodingUtil.base64Decode(InstKey);                 
        String DecStr = blob1.toString();
        ////List<String> sp = new List<String>();
        ////sp = DecStr.split('~', 2);
        String OrgID = DecStr; ////sp.get(0);
        ////String NewDate = sp.get(1);
        if ( OrgID == null) ////NewDate == null ||
            {
            obj.addError('Invalid installation key.'); // 'Invalid installation key'
            return false;
            }
        else if (OrgID != userInfo.getOrganizationId().subString(0,15))
            {
            obj.addError('This installation key is not valid for your instance of ServiceMax.'); // 'This installation key is not valid for your instance of ServiceMax.'
            return false;
            }
        
        /* Not Supported Summer-10 Onwards: GM 25Aug10
        else
            {
            Date KeyDate = date.valueOf(NewDate);
            Date TodaysDate = date.Today();
       
            if (TodaysDate.daysBetween(KeyDate) < 0)
                {
                obj.addError('This installation key has expired. Please contact ServiceMax support.'); // 'This installation key has expired. Please contact ServiceMax support.'
                return false;
                }
            } */
           
        return true;
    } 
    
    /*************************************Generic Parsing Functionality **********************************/
    Map<Double,string> ExprsionMap = new Map<Double,string>();    
    global Boolean SVMX_ExpressionParsing(SObject Rec, Map<String,String>TypeMap, list<SVMXC__ServiceMax_Config_Data__c> ConfgLst, string AdvExp){
      string ExpVal ;
      integer ExpKey;
      String Temp;
      Boolean IsValidExp = false;
      for(integer i=0;i<ConfgLst.size();i++){
            ExprsionMap.put(ConfgLst[i].SVMXC__Sequence__c,'F');
            Object Obj= Rec.get(ConfgLst[i].SVMXC__Field_Name__c);            
            string Val=string.valueOf(Obj);
            if(TypeMap.get(ConfgLst[i].SVMXC__Field_Name__c)=='TEXTAREA' || TypeMap.get(ConfgLst[i].SVMXC__Field_Name__c)=='TEXT' || TypeMap.get(ConfgLst[i].SVMXC__Field_Name__c)=='PICKLIST' || TypeMap.get(ConfgLst[i].SVMXC__Field_Name__c)=='STRING'){
                  if(ConfgLst[i].SVMXC__Operator__c=='eq'){
                        if(Val==ConfgLst[i].SVMXC__Operand__c){
                              ExprsionMap.put(ConfgLst[i].SVMXC__Sequence__c,'T');  }                           
                  }
                  else if(ConfgLst[i].SVMXC__Operator__c == 'ne'){
                        if(Val!=ConfgLst[i].SVMXC__Operand__c){
                              ExprsionMap.put(ConfgLst[i].SVMXC__Sequence__c,'T');  }
                  }
                  else if(ConfgLst[i].SVMXC__Operator__c == 'starts'){
                        if(Val.startsWith(ConfgLst[i].SVMXC__Operand__c)){
                              ExprsionMap.put(ConfgLst[i].SVMXC__Sequence__c,'T');  }
                  }
                  else if(ConfgLst[i].SVMXC__Operator__c == 'contains'){
                    System.debug('value>>>>'+val+' and operand>>>>'+ConfgLst[i].SVMXC__Operand__c);
                        if(Val.contains(ConfgLst[i].SVMXC__Operand__c)){
                              ExprsionMap.put(ConfgLst[i].SVMXC__Sequence__c,'T');  }
                  }
            }           
            else if(TypeMap.get(ConfgLst[i].SVMXC__Field_Name__c)=='BOOLEAN' || TypeMap.get(ConfgLst[i].SVMXC__Field_Name__c)=='REFERENCE'){
                  if(ConfgLst[i].SVMXC__Operator__c=='eq'){
                        if(Val==ConfgLst[i].SVMXC__Operand__c){                           
                              ExprsionMap.put(ConfgLst[i].SVMXC__Sequence__c,'T');  }
                  }
                  else if(ConfgLst[i].SVMXC__Operator__c == 'ne'){
                        if(Val!=ConfgLst[i].SVMXC__Operand__c){                           
                              ExprsionMap.put(ConfgLst[i].SVMXC__Sequence__c,'T');  }
                  }
            }
            else if(TypeMap.get(ConfgLst[i].SVMXC__Field_Name__c)=='DATETIME' || TypeMap.get(ConfgLst[i].SVMXC__Field_Name__c)=='DATE' || TypeMap.get(ConfgLst[i].SVMXC__Field_Name__c)=='NUMBER' ){
                  if(ConfgLst[i].SVMXC__Operator__c=='eq'){
                        if(Val==ConfgLst[i].SVMXC__Operand__c){                           
                              ExprsionMap.put(ConfgLst[i].SVMXC__Sequence__c,'T');  }
                  }
                  else if(ConfgLst[i].SVMXC__Operator__c == 'ne'){
                        if(Val!=ConfgLst[i].SVMXC__Operand__c){                           
                              ExprsionMap.put(ConfgLst[i].SVMXC__Sequence__c,'T');  }
                  }
                  else if(ConfgLst[i].SVMXC__Operator__c == 'gt'){
                        if(Val > ConfgLst[i].SVMXC__Operand__c){                          
                              ExprsionMap.put(ConfgLst[i].SVMXC__Sequence__c,'T');  }
                  }
                  else if(ConfgLst[i].SVMXC__Operator__c == 'ge'){
                        if(Val>=ConfgLst[i].SVMXC__Operand__c){                           
                              ExprsionMap.put(ConfgLst[i].SVMXC__Sequence__c,'T');  }
                  }
                  else if(ConfgLst[i].SVMXC__Operator__c == 'lt'){
                        if(Val < ConfgLst[i].SVMXC__Operand__c){                          
                              ExprsionMap.put(ConfgLst[i].SVMXC__Sequence__c,'T');  }
                  }
                  else if(ConfgLst[i].SVMXC__Operator__c == 'le'){
                        if(Val<=ConfgLst[i].SVMXC__Operand__c){                           
                              ExprsionMap.put(ConfgLst[i].SVMXC__Sequence__c,'T');  }
                  }                 
            }           
      }
      if(AdvExp==null){           
          for(integer j=0;j<ConfgLst.size();j++){
            if(ConfgLst.size()==1){
                  AdvExp = string.valueOf(ConfgLst[j].SVMXC__Sequence__c.intValue());
            }
            else if(ConfgLst.size()>1){
                  if(AdvExp==null)
                        AdvExp = string.valueOf(ConfgLst[j].SVMXC__Sequence__c.intValue());
                  else
                        AdvExp = AdvExp +'&&' + string.valueOf(ConfgLst[j].SVMXC__Sequence__c.intValue());
            }
          }             
      }    
      else if(AdvExp!=null){              
            if(AdvExp.length()>1){
                  if(AdvExp.contains('AND') || AdvExp.contains('and')){
                        AdvExp = AdvExp.replace('AND', '&&');
                        AdvExp = AdvExp.replace('and', '&&');                       
                        AdvExp = AdvExp.replaceAll(' ','');                         
                  }
                  else if(AdvExp.contains('OR') || AdvExp.contains('or')){
                        AdvExp = AdvExp.replace('OR', '||');
                        AdvExp = AdvExp.replace('or', '||');
                        AdvExp = AdvExp.replaceAll(' ','');                         
                  }
            }
      }
      for(integer k=0;k<ConfgLst.size();k++){
            if(ExprsionMap.containsKey(ConfgLst[k].SVMXC__Sequence__c)){                  
                  ExpKey = ConfgLst[k].SVMXC__Sequence__c.intValue();
                  ExpVal = ExprsionMap.get(ConfgLst[k].SVMXC__Sequence__c);                     
                  AdvExp = AdvExp.replace(string.valueOf(ExpKey),ExpVal);                 
                  
            }
      }
      AdvExp = AdvExp.replace('T','1');
      AdvExp = AdvExp.replace('F','0');         
      do{
            Temp = AdvExp;
            AdvExp = AdvExp.replace('(0)','0');
            AdvExp = AdvExp.replace('(1)','1');
            AdvExp = AdvExp.replace('0&&0','0');
            AdvExp = AdvExp.replace('0&&1','0');
            AdvExp = AdvExp.replace('1&&0','0');
            AdvExp = AdvExp.replace('1&&1','1');
            AdvExp = AdvExp.replace('0||0','0');
            AdvExp = AdvExp.replace('0||1','1');
            AdvExp = AdvExp.replace('1||0','1');
            AdvExp = AdvExp.replace('1||1','1');
      }
      while(Temp!=AdvExp);
      if(AdvExp=='0')
            IsValidExp =  false;
      if(AdvExp=='1')
            IsValidExp =  true;
      return IsValidExp;
    }
    
    
     /*************************************Generic Parsing Functionality **********************************/
    public class COMM_ExpressionParsing
    {
        Map<Double,string> ExprsionMap = new Map<Double,string>();
        public map<Id, string> SVMX_ExpressionParsing(map<Id, sObject> lstRec, map<Id, list<SVMXC__ServiceMax_Config_Data__c>> mapRulesExpressions, map<Id, SVMXC__ServiceMax_Processes__c> mapRules)
        {
            map<Id, string> mapResult = new map<Id, string>();
            list<SVMXC__ServiceMax_Processes__c> lstSortedRules = sortRuleList(mapRulesExpressions.KeySet(), mapRules);
            system.debug('asdf' );
            if(lstRec != null)
            {
                system.debug('asdf3'+lstRec);
                for(Id iIndex: lstRec.KeySet())
                {
                    sObject sObj = lstRec.get(iIndex);
                    system.debug('asdf'+sObj );
                    for(SVMXC__ServiceMax_Processes__c oSVMXProcess: lstSortedRules)
                    {
                        Id IdRule = oSVMXProcess.Id;
                        if(mapRulesExpressions.ContainsKey(IdRule))
                        {
                            boolean IsRuleApplicable = false;
                            system.debug('asdf2'+mapRulesExpressions.get(IdRule));
                            IsRuleApplicable = SVMX_ExpressionParsing(sObj, mapRulesExpressions.get(IdRule), mapRules.get(IdRule)!= null? mapRules.get(IdRule).SVMXC__Advance_Expression__c : '');
                            if(IsRuleApplicable)
                            {
                                system.debug('asdf2'+iIndex+'='+IdRule);
                                mapResult.put(iIndex, IdRule);
                                break;
                            }
                        }
                    }
                }
            }
            return mapResult;
        }
        public map<string, string> SVMX_ExpressionParsing(map<string, sObject> lstRec, map<Id, list<SVMXC__ServiceMax_Config_Data__c>> mapRulesExpressions, map<Id, SVMXC__ServiceMax_Processes__c> mapRules)
        {
            map<string, string> mapResult = new map<string, string>();
            list<SVMXC__ServiceMax_Processes__c> lstSortedRules = sortRuleList(mapRulesExpressions.KeySet(), mapRules);
            if(lstRec != null)
            {
                for(string iIndex: lstRec.KeySet())
                {
                    sObject sObj = lstRec.get(iIndex);
                    system.debug('asdf'+sObj );
                    for(SVMXC__ServiceMax_Processes__c oSVMXProcess: lstSortedRules)
                    {
                        Id IdRule = oSVMXProcess.Id;
                        if(mapRulesExpressions.ContainsKey(IdRule))
                        {
                             system.debug('asdf2'+mapRulesExpressions.get(IdRule));
                             system.debug('asdf2'+iIndex+'='+IdRule);
                            boolean IsRuleApplicable = false;
                            IsRuleApplicable = SVMX_ExpressionParsing(sObj, mapRulesExpressions.get(IdRule), mapRules.get(IdRule)!= null? mapRules.get(IdRule).SVMXC__Advance_Expression__c : '');
                            if(IsRuleApplicable)
                            {
                                system.debug('asdf2'+iIndex+'='+IdRule);
                                mapResult.put(iIndex, IdRule);
                                break;
                            }
                        }
                    }
                }
            }
            return mapResult;
        }
        public map<Integer, string> SVMX_ExpressionParsing(map<integer, sObject> lstRec, map<Id, list<SVMXC__ServiceMax_Config_Data__c>> mapRulesExpressions, map<Id, SVMXC__ServiceMax_Processes__c> mapRules)
        {
            map<Integer, string> mapResult = new map<Integer, string>();
            list<SVMXC__ServiceMax_Processes__c> lstSortedRules = sortRuleList(mapRulesExpressions.KeySet(), mapRules);
            if(lstRec != null)
            {
                for(Integer iIndex: lstRec.KeySet())
                {
                    sObject sObj = lstRec.get(iIndex);
                    for(SVMXC__ServiceMax_Processes__c oSVMXProcess: lstSortedRules)
                    {
                        Id IdRule = oSVMXProcess.Id;
                        if(mapRulesExpressions.ContainsKey(IdRule))
                        {
                            boolean IsRuleApplicable = false;
                            IsRuleApplicable = SVMX_ExpressionParsing(sObj, mapRulesExpressions.get(IdRule), mapRules.get(IdRule)!= null? mapRules.get(IdRule).SVMXC__Advance_Expression__c : '');
                            if(IsRuleApplicable)
                            {
                                mapResult.put(iIndex, IdRule);
                                break;
                            }
                        }
                    }
                }
            }
            return mapResult;
        }
        public string SVMX_ExpressionParsing(SObject Rec, map<Id, list<SVMXC__ServiceMax_Config_Data__c>> mapRulesExpressions, map<Id, SVMXC__ServiceMax_Processes__c> mapRules)
        {
            if(mapRulesExpressions != null)
            {
                for(SVMXC__ServiceMax_Processes__c oSVMXRule: sortRuleList(mapRulesExpressions.KeySet(), mapRules))
                {
                    string IdRule = oSVMXRule.Id;
                    boolean IsRuleApplicable = false;
                    IsRuleApplicable = SVMX_ExpressionParsing(Rec, mapRulesExpressions.get(IdRule), mapRules.get(IdRule)!= null? mapRules.get(IdRule).SVMXC__Advance_Expression__c : '');
                    if(IsRuleApplicable)
                        return IdRule;
                }
            }
            return null;
        }

        // BAC-3670 - Added implementation for field of type "Date". 
        // We store the expression with operand "contains" which behaves exactly like "contain"
        // We store the expression with operand "NOTCONTAINS" which behaves exactly like "NOTCONTAIN"
        // Performing Date and Datetime compariosn in local format.
                    
        public Boolean SVMX_ExpressionParsing(SObject Rec, list<SVMXC__ServiceMax_Config_Data__c> lstExpressions, string AdvExp)
        {
            if(lstExpressions == null || lstExpressions.size() == 0)
                return true;
            Map<Double,string> mapResult = new Map<Double,string>(); 
            string ExpVal;
            integer ExpKey;
            lstExpressions = sortingExpressionList(lstExpressions);
            for(SVMXC__ServiceMax_Config_Data__c oExpression: lstExpressions)
            {
                mapResult.put(oExpression.SVMXC__Sequence__c,'F');
                string FieldType = oExpression.SVMXC__Display_Type__c ;
                
                String referenceValue = null;
                
                    if(oExpression.get('SVMXC__Field_Relationship_Name__c') != null && oExpression.get('SVMXC__FKey_Name_Field__c') != null ) {
                        try {
                            referenceValue = Rec.get(oExpression.SVMXC__Field_Name__c) != null ? (String) Rec.getSObject(oExpression.SVMXC__Field_Relationship_Name__c).get(oExpression.SVMXC__FKey_Name_Field__c): null;
                        }
                        catch( Exception ex ) {   
                            system.debug('Came to catch because: Relationship Object' + oExpression.get('SVMXC__Field_Relationship_Name__c') + ' and Name Field '+ oExpression.get('SVMXC__FKey_Name_Field__c'));                 
                            // BAC-3670 - When there is no reference value defined, skip the below execution and continue with nect expression
                        }
                    }
                
                
                if(FieldType != null && FieldType.length() > 0 && oExpression.SVMXC__Operator__c != null && oExpression.SVMXC__Operator__c.length() > 0)
                {
                    string strOperater = oExpression.SVMXC__Operator__c.ToUpperCase();
                    string strFieldType = FieldType.ToUpperCase();
                    
                    // BAC-3670 - For email field as well, it should evaluate as String. 
        
                    if(strFieldType == 'STRING' || strFieldType == 'MULTIPICKLIST' || strFieldType == 'COMBOBOX' || strFieldType == 'PICKLIST' || strFieldType == 'PHONE' || strFieldType == 'URL' || strFieldType == 'TEXTAREA' || strFieldType == 'EMAIL')
                    {
                        if(strOperater == 'ISNULL')
                        {
                            if(Rec.get(oExpression.SVMXC__Field_Name__c) == null)
                                mapResult.put(oExpression.SVMXC__Sequence__c,'T');
                        }
                        else if(strOperater == 'NOTNULL' || strOperater == 'ISNOTNULL')
                        {
                            if(Rec.get(oExpression.SVMXC__Field_Name__c) != null)
                                mapResult.put(oExpression.SVMXC__Sequence__c,'T');                  
                        }
                        string Val;
                        if(Rec.get(oExpression.SVMXC__Field_Name__c) != null)
                            val = string.valueOf(Rec.get(oExpression.SVMXC__Field_Name__c));
                        
                        if(strOperater == 'EQ')
                        {
                             //Fixed defect 043293: Only wizard load : To support multi value in Equal operator for Text and Picklist type of fields
                            if(INTF_GetServiceFlowWizard.isWizardExpression && (strFieldType == 'STRING' || strFieldType == 'PICKLIST' || strFieldType == 'MULTIPICKLIST') && Val != null) //Added this strFieldType == 'MULTIPICKLIST' condition for fixing defect 045853
                            {
                                oExpression.SVMXC__Operand__c = oExpression.SVMXC__Operand__c != null ? oExpression.SVMXC__Operand__c : ''; //Added this for fixing defect 045853
                                List<String> arrVal = (oExpression.SVMXC__Operand__c).split(',');
                                for(String str : arrVal)
                                {
                                    if(str == Val)
                                    {
                                        mapResult.put(oExpression.SVMXC__Sequence__c,'T');
                                    }
                                }
                            }
                            //Added this else if condition for fixing defect 045853
                            else if(INTF_GetServiceFlowWizard.isWizardExpression && (strFieldType == 'STRING' || strFieldType == 'PICKLIST' || strFieldType == 'MULTIPICKLIST') && Val == null){
                                if(oExpression.SVMXC__Operand__c == null){
                                    mapResult.put(oExpression.SVMXC__Sequence__c,'T');
                                }
                            }
                            else
                            {
                                if(Val != null && Val == oExpression.SVMXC__Operand__c)
                                    mapResult.put(oExpression.SVMXC__Sequence__c,'T');
                            }
                        }
                        else if(strOperater == 'NE')
                        {
                            //Fixed defect 043293: Only wizard load : To support multi value in Not Equal operator for Text and Picklist type of fields
                            //Please don't add Val == null in below if condition, not equal will not work when record value it self null
                            if(INTF_GetServiceFlowWizard.isWizardExpression && (strFieldType == 'STRING' || strFieldType == 'PICKLIST'))
                            {
                                boolean isContain = false; 
                                
                                //Added if condition for fixing defect 045853
                                if(oExpression.SVMXC__Operand__c != null){
                                    List<String> arrVal = (oExpression.SVMXC__Operand__c).split(',');
                                    for(String str : arrVal)
                                    {
                                        if(str == Val)
                                        {
                                            isContain = true;
                                            break;
                                        }
                                    }
                                }
                                //Added else if condition for fixing defect 045853
                                else if(oExpression.SVMXC__Operand__c == null && Val == null){
                                    isContain = true;
                                }
                                
                                if(!isContain)
                                {
                                        mapResult.put(oExpression.SVMXC__Sequence__c,'T');
                                }
                            }else
                            {
                                if(Val != null && Val != oExpression.SVMXC__Operand__c)
                                    mapResult.put(oExpression.SVMXC__Sequence__c,'T');
                            }
                            
                        }
                        else if(strOperater == 'STARTS' )
                        {
                            // customer defect 045855/045881 starts
                            /*if(Val != null)
                            {
                                if(Val.startsWith(oExpression.SVMXC__Operand__c))
                                    mapResult.put(oExpression.SVMXC__Sequence__c,'T');
                            }*/
                            if(Val != null && INTF_GetServiceFlowWizard.isWizardExpression)
                            {
                                if( !String.isBlank(oExpression.SVMXC__Operand__c) && Val.toUpperCase().startsWith(oExpression.SVMXC__Operand__c.toUpperCase()))
                                    mapResult.put(oExpression.SVMXC__Sequence__c,'T');
                            }
                            else if(Val != null)
                            {
                                if(Val.startsWith(oExpression.SVMXC__Operand__c))
                                    mapResult.put(oExpression.SVMXC__Sequence__c,'T');
                            }
                            // customer defect 045855/045881 ends
                        }
                        else if(strOperater == 'CONTAINS' || strOperater == 'CONTAIN')
                        {
                            // customer defect 045855/045881 starts
                           /* if(Val != null)
                            {
                                if(Val.contains(oExpression.SVMXC__Operand__c))                                     
                                    mapResult.put(oExpression.SVMXC__Sequence__c,'T');
                            }
                            */
                            if(Val != null && INTF_GetServiceFlowWizard.isWizardExpression){
                                if(!String.isBlank(oExpression.SVMXC__Operand__c) && Val.toUpperCase().contains(oExpression.SVMXC__Operand__c.toUpperCase()))
                                    mapResult.put(oExpression.SVMXC__Sequence__c,'T');
                            }
                            else if(Val != null)
                            {
                                if(Val.contains(oExpression.SVMXC__Operand__c))                                     
                                    mapResult.put(oExpression.SVMXC__Sequence__c,'T');
                            }
                            // customer defect 045855/045881 ends
                            
                        }
                        else if(strOperater == 'NOTCONTAINS' || strOperater == 'NOTCONTAIN')
                        {    
                                
                            if(Val != null)
                            {
                                if(String.isNotBlank(oExpression.SVMXC__Operand__c) && !Val.containsIgnoreCase(oExpression.SVMXC__Operand__c)) //#defectFix 047410, added String.isNotBlank(oExpression.SVMXDEV__Operand__c) and used containsIgnoreCase method instead of contains mr
                                    mapResult.put(oExpression.SVMXC__Sequence__c,'T');
                            }else if(String.isBlank(Val) && INTF_GetServiceFlowWizard.isWizardExpression){
                                //Added by NIDHI as part of 047226                            
                                //If the field value is null and operator is Does Not Contain, the wizard should be loaded.                             
                                mapResult.put(oExpression.SVMXC__Sequence__c,'T');
                            }
                        }
                        else if(strOperater == 'IN' || strOperater == 'NOTIN')
                        {
                            String[] multValues = oExpression.SVMXC__Operand__c.split(',');
                            set<string> setValues = new set<string>();
                            if(multValues != null)
                            {
                                for(string str: multValues)
                                {
                                    setValues.add(str);
                                }
                            }
                            
                            /*BAC-3752
                             * IN and NOTIN values are available only when it's a multiselect picklist
                             * Split the record Val using 
                             * For INClUDE condition- if Either of the values are present in record, process qualifies. If one value qualifies, we can skip the loop
                             * For EXCLUDE condition - Check all the values, if none of the values should be present. So loop has to be done for all values
                             * */
                            if(Val != null){
                                String[] recordFieldValues = Val.split(';');
                                set<string> setRecordValues = new set<string>();
                                if(recordFieldValues != null)
                                {
                                    for(string str: recordFieldValues)
                                    {
                                        setRecordValues.add(str);
                                    }
                                }
                                
                                Set <String> trueFalse = new Set <String>();
                                
                                for(String operandVal: setValues){
                                    if(strOperater == 'IN' && setRecordValues.contains(operandVal)){
                                        mapResult.put(oExpression.SVMXC__Sequence__c,'T');
                                        break;
                                    }
                                       
                                    // setRecordValues  == Test; test2
                                    // OperandVal -- Test, Test1
                                    if(strOperater == 'NOTIN'){
                                        trueFalse.add(String.valueOf(setRecordValues.contains(operandVal)));
                                    }    
                                }
                                
                                if(strOperater == 'NOTIN' && trueFalse.contains('false') && !trueFalse.contains('true')){
                                    mapResult.put(oExpression.SVMXC__Sequence__c,'T');
                                }    
                            }
                            
                        }
                    }//mapFieldDisplayType.get(oExpression.SVMXC__Field_Name__c)=='REFERENCE'
                    else if(strFieldType == 'BOOLEAN')
                    {
                        if(strOperater == 'ISNULL')
                        {
                            if(Rec.get(oExpression.SVMXC__Field_Name__c) == null)
                                mapResult.put(oExpression.SVMXC__Sequence__c,'T');
                        }
                        else if(strOperater == 'NOTNULL' || strOperater == 'ISNOTNULL')
                        {
                            if(Rec.get(oExpression.SVMXC__Field_Name__c) != null)
                                mapResult.put(oExpression.SVMXC__Sequence__c,'T');
                        }
                        string Val;
                        if(Rec.get(oExpression.SVMXC__Field_Name__c) != null)
                            val = string.valueOf(Rec.get(oExpression.SVMXC__Field_Name__c));
                        if(strOperater == 'EQ')
                        {
                            if('TRUE' == oExpression.SVMXC__Operand__c.ToUpperCase() && (boolean)Rec.get(oExpression.SVMXC__Field_Name__c))
                                mapResult.put(oExpression.SVMXC__Sequence__c,'T');
                            if('FALSE' == oExpression.SVMXC__Operand__c.ToUpperCase() && !((boolean)Rec.get(oExpression.SVMXC__Field_Name__c)))
                                mapResult.put(oExpression.SVMXC__Sequence__c,'T');
                        }
                        else if(strOperater == 'NE')
                        {
                            if('TRUE' == oExpression.SVMXC__Operand__c.ToUpperCase() && !((boolean)Rec.get(oExpression.SVMXC__Field_Name__c)))
                                mapResult.put(oExpression.SVMXC__Sequence__c,'T');
                            if('FALSE' == oExpression.SVMXC__Operand__c.ToUpperCase() && (boolean)Rec.get(oExpression.SVMXC__Field_Name__c))
                                mapResult.put(oExpression.SVMXC__Sequence__c,'T');
                        }
                    }
                    else if(strFieldType == 'INTEGER')
                    {
                        if(strOperater == 'ISNULL')
                        {
                            if(Rec.get(oExpression.SVMXC__Field_Name__c) == null)
                                mapResult.put(oExpression.SVMXC__Sequence__c,'T');
                        }
                        else if(strOperater == 'NOTNULL' || strOperater == 'ISNOTNULL')
                        {
                            if(Rec.get(oExpression.SVMXC__Field_Name__c) != null)
                                mapResult.put(oExpression.SVMXC__Sequence__c,'T');
                        }
                        Integer Val;
                        if(Rec.get(oExpression.SVMXC__Field_Name__c) != null)
                            val = ((Decimal)Rec.get(oExpression.SVMXC__Field_Name__c)).IntValue();
                        if(strOperater == 'EQ')
                        {
                            if(Val != null && Val == Integer.valueOf(oExpression.SVMXC__Operand__c))
                                mapResult.put(oExpression.SVMXC__Sequence__c,'T');
                        }
                        else if(strOperater == 'NE')
                        {
                            if(Val != null && Val != Integer.valueOf(oExpression.SVMXC__Operand__c))
                                mapResult.put(oExpression.SVMXC__Sequence__c,'T');
                        }
                        else if(strOperater == 'LT')
                        {
                            if(Val != null && Val < Integer.valueOf(oExpression.SVMXC__Operand__c))
                                mapResult.put(oExpression.SVMXC__Sequence__c,'T');
                        }
                        else if(strOperater == 'GT')
                        {
                            if(Val != null && Val > Integer.valueOf(oExpression.SVMXC__Operand__c))
                                mapResult.put(oExpression.SVMXC__Sequence__c,'T');
                        }
                        else if(strOperater == 'LE')
                        {
                            if(Val != null && Val <= Integer.valueOf(oExpression.SVMXC__Operand__c))
                                mapResult.put(oExpression.SVMXC__Sequence__c,'T');
                        }
                        else if(strOperater == 'GE')
                        {
                            if(Val != null && Val >= Integer.valueOf(oExpression.SVMXC__Operand__c))
                                mapResult.put(oExpression.SVMXC__Sequence__c,'T');
                        }
                        else if(strOperater == 'IN' || strOperater == 'NOTIN')
                        {
                            String[] multValues = oExpression.SVMXC__Operand__c.split(',');
                            set<Integer> setValues = new set<Integer>();
                            if(multValues != null)
                            {
                                for(string str: multValues)
                                {
                                    setValues.add(integer.valueOf(str));
                                }
                            }
                            if(setValues.contains(Val) && strOperater == 'IN')
                                mapResult.put(oExpression.SVMXC__Sequence__c,'T');
                            if(!setValues.contains(Val) && strOperater == 'NOTIN')
                                mapResult.put(oExpression.SVMXC__Sequence__c,'T');
                        }
                    }
                    else if(strFieldType == 'CURRENCY' || strFieldType == 'DECIMAL')
                    {
                        if(strOperater == 'ISNULL')
                        {
                            if(Rec.get(oExpression.SVMXC__Field_Name__c) == null)
                                mapResult.put(oExpression.SVMXC__Sequence__c,'T');
                        }
                        else if(strOperater == 'NOTNULL' || strOperater == 'ISNOTNULL')
                        {
                            if(Rec.get(oExpression.SVMXC__Field_Name__c) != null)
                                mapResult.put(oExpression.SVMXC__Sequence__c,'T');
                        }
                        DECIMAL Val;
                        if(Rec.get(oExpression.SVMXC__Field_Name__c) != null)
                            val = Decimal.valueOf(((Double)Rec.get(oExpression.SVMXC__Field_Name__c)));
                        if(strOperater == 'EQ')
                        {
                            if(Val != null && Val == DECIMAL.valueOf(oExpression.SVMXC__Operand__c))
                                mapResult.put(oExpression.SVMXC__Sequence__c,'T');
                        }
                        else if(strOperater == 'NE')
                        {
                            if(Val != null && Val != DECIMAL.valueOf(oExpression.SVMXC__Operand__c))
                                mapResult.put(oExpression.SVMXC__Sequence__c,'T');
                        }
                        else if(strOperater == 'LT')
                        {
                            if(Val != null && Val < DECIMAL.valueOf(oExpression.SVMXC__Operand__c))
                                mapResult.put(oExpression.SVMXC__Sequence__c,'T');
                        }
                        else if(strOperater == 'GT')
                        {
                            if(Val != null && Val > DECIMAL.valueOf(oExpression.SVMXC__Operand__c))
                                mapResult.put(oExpression.SVMXC__Sequence__c,'T');
                        }
                        else if(strOperater == 'LE')
                        {
                            if(Val != null && Val <= DECIMAL.valueOf(oExpression.SVMXC__Operand__c))
                                mapResult.put(oExpression.SVMXC__Sequence__c,'T');
                        }
                        else if(strOperater == 'GE')
                        {
                            if(Val != null && Val >= DECIMAL.valueOf(oExpression.SVMXC__Operand__c))
                                mapResult.put(oExpression.SVMXC__Sequence__c,'T');
                        }
                        else if(strOperater == 'IN' || strOperater == 'NOTIN')
                        {
                            String[] multValues = oExpression.SVMXC__Operand__c.split(',');
                            set<DECIMAL> setValues = new set<DECIMAL>();
                            if(multValues != null)
                            {
                                for(string str: multValues)
                                {
                                    setValues.add(DECIMAL.valueOf(str));
                                }
                            }
                            if(setValues.contains(Val) && strOperater == 'IN')
                                mapResult.put(oExpression.SVMXC__Sequence__c,'T');
                            if(!setValues.contains(Val) && strOperater == 'NOTIN')
                                mapResult.put(oExpression.SVMXC__Sequence__c,'T');
                        }
                    }
                    else if(strFieldType == 'DOUBLE' || strFieldType == 'PERCENT')
                    {
                        
                        if(strOperater == 'ISNULL')
                        {
                            if(Rec.get(oExpression.SVMXC__Field_Name__c) == null)
                                mapResult.put(oExpression.SVMXC__Sequence__c,'T');
                        }
                        else if(strOperater == 'NOTNULL' || strOperater == 'ISNOTNULL')
                        {
                            if(Rec.get(oExpression.SVMXC__Field_Name__c) != null)
                                mapResult.put(oExpression.SVMXC__Sequence__c,'T');
                        }
                        DOUBLE Val;
                        if(Rec.get(oExpression.SVMXC__Field_Name__c) != null)
                            val = (DOUBLE)Rec.get(oExpression.SVMXC__Field_Name__c);
                        if(strOperater == 'EQ')
                        {
                            if(Val != null && Val == DOUBLE.valueOf(oExpression.SVMXC__Operand__c))
                                mapResult.put(oExpression.SVMXC__Sequence__c,'T');
                        }
                        else if(strOperater == 'NE')
                        {
                            if(Val != null && Val != DOUBLE.valueOf(oExpression.SVMXC__Operand__c))
                                mapResult.put(oExpression.SVMXC__Sequence__c,'T');
                        }
                        else if(strOperater == 'LT')
                        {
                            if(Val != null && Val < DOUBLE.valueOf(oExpression.SVMXC__Operand__c))
                                mapResult.put(oExpression.SVMXC__Sequence__c,'T');
                        }
                        else if(strOperater == 'GT')
                        {
                            if(Val != null && Val > DOUBLE.valueOf(oExpression.SVMXC__Operand__c))
                                mapResult.put(oExpression.SVMXC__Sequence__c,'T');
                        }
                        else if(strOperater == 'LE')
                        {
                            if(Val != null && Val <= DOUBLE.valueOf(oExpression.SVMXC__Operand__c))
                                mapResult.put(oExpression.SVMXC__Sequence__c,'T');
                        }
                        else if(strOperater == 'GE')
                        {
                            if(Val != null && Val >= DOUBLE.valueOf(oExpression.SVMXC__Operand__c))
                                mapResult.put(oExpression.SVMXC__Sequence__c,'T');
                        }
                        else if(strOperater == 'IN' || strOperater == 'NOTIN')
                        {
                            String[] multValues = oExpression.SVMXC__Operand__c.split(',');
                            set<DOUBLE> setValues = new set<DOUBLE>();
                            if(multValues != null)
                            {
                                for(string str: multValues)
                                {
                                    setValues.add(DOUBLE.valueOf(str));
                                }
                            }
                            if(setValues.contains(Val) && strOperater == 'IN')
                                mapResult.put(oExpression.SVMXC__Sequence__c,'T');
                            if(!setValues.contains(Val) && strOperater == 'NOTIN')
                                mapResult.put(oExpression.SVMXC__Sequence__c,'T');
                        }
                    }
                    else if(strFieldType == 'ID' || strFieldType == 'REFERENCE')
                    {
                        if(strOperater == 'ISNULL')
                        {
                            if(Rec.get(oExpression.SVMXC__Field_Name__c) == null)
                                mapResult.put(oExpression.SVMXC__Sequence__c,'T');
                        }
                        else if(strOperater == 'NOTNULL' || strOperater == 'ISNOTNULL')
                        {
                            if(Rec.get(oExpression.SVMXC__Field_Name__c) != null)
                                mapResult.put(oExpression.SVMXC__Sequence__c,'T');
                        }
                        Id Val;
                        if(Rec.get(oExpression.SVMXC__Field_Name__c) != null)
                            val = string.valueOf(Rec.get(oExpression.SVMXC__Field_Name__c));
                        if(strOperater == 'EQ')
                        {
                            if( referenceValue != null ) {
                                // Start : Defect 045979 fixed  
                                if(INTF_GetServiceFlowWizard.isWizardExpression){
                                     oExpression.SVMXC__Operand__c = oExpression.SVMXC__Operand__c != null ? oExpression.SVMXC__Operand__c : ''; //Added this for fixing defect 045853
                                     List<String> arrVal = (oExpression.SVMXC__Operand__c).split(',');
                                     for(String str : arrVal)
                                     {
                                        if(str == referenceValue)
                                        {
                                            mapResult.put(oExpression.SVMXC__Sequence__c,'T');
                                            break;
                                        }
                                     }
                                 }//End Defect 045979 fixed  
                                 else if( referenceValue == oExpression.SVMXC__Operand__c ) {
                                    mapResult.put(oExpression.SVMXC__Sequence__c,'T');
                                 }
                                
                            } else if(Val != null && Val == (Id)oExpression.SVMXC__Operand__c){
                                mapResult.put(oExpression.SVMXC__Sequence__c,'T');             
                            } 
                            //Added else if condition for fixing defect 045853
                            else if(oExpression.SVMXC__Operand__c == null && Val == null){
                                mapResult.put(oExpression.SVMXC__Sequence__c,'T');
                            }
                        }
                        else if(strOperater == 'NE')
                        {
                            
                            if( referenceValue != null ) {
                                if( referenceValue != oExpression.SVMXC__Operand__c ) {
                                    mapResult.put(oExpression.SVMXC__Sequence__c,'T');
                                }
                            } else if(Val != null && Val != (Id)oExpression.SVMXC__Operand__c)
                                mapResult.put(oExpression.SVMXC__Sequence__c,'T');
                        }
                        else if(strOperater == 'STARTS' )
                        {
                            // customer defect 045855/045881 starts
                            /*if(referenceValue != null)
                            {
                                if(referenceValue.startsWith(oExpression.SVMXC__Operand__c))
                                    mapResult.put(oExpression.SVMXC__Sequence__c,'T');
                            }*/
                            if(referenceValue != null && INTF_GetServiceFlowWizard.isWizardExpression){
                                if(!String.isBlank(oExpression.SVMXC__Operand__c) && referenceValue.toUpperCase().startsWith(oExpression.SVMXC__Operand__c.toUpperCase()))
                                    mapResult.put(oExpression.SVMXC__Sequence__c,'T');
                            }
                            else if(referenceValue != null)
                            {
                                if(referenceValue.startsWith(oExpression.SVMXC__Operand__c))
                                    mapResult.put(oExpression.SVMXC__Sequence__c,'T');
                            }
                            // customer defect 045855/045881 ends
                            
                        }
                        else if(strOperater == 'CONTAINS' || strOperater == 'CONTAIN') 
                        {
                            // customer defect 045855/045881 starts
                            /*if(referenceValue != null)
                            {
                                if(referenceValue.contains(oExpression.SVMXC__Operand__c))
                                    mapResult.put(oExpression.SVMXC__Sequence__c,'T');
                            }*/
                            if(referenceValue != null && INTF_GetServiceFlowWizard.isWizardExpression)
                            {
                                if(!String.isBlank(oExpression.SVMXC__Operand__c) && referenceValue.toUpperCase().contains(oExpression.SVMXC__Operand__c.toUpperCase()))
                                    mapResult.put(oExpression.SVMXC__Sequence__c,'T');
                            }
                            else if(referenceValue != null)
                            {
                                if(referenceValue.contains(oExpression.SVMXC__Operand__c))
                                    mapResult.put(oExpression.SVMXC__Sequence__c,'T');
                            }
                            // customer defect 045855/045881 ends
                        }
                        else if(strOperater == 'NOTCONTAINS' || strOperater == 'NOTCONTAIN')
                        {
                                
                            if(referenceValue != null)
                            {
                                if(!referenceValue.containsIgnoreCase(oExpression.SVMXC__Operand__c)) //used containsIgnoreCase instead of contains #defectFix 047410
                                    mapResult.put(oExpression.SVMXC__Sequence__c,'T');
                            }else if(String.isBlank(referenceValue) && INTF_GetServiceFlowWizard.isWizardExpression){
                                //Added by NIDHI as part of 044011
                                //This is only on Wizard Load
                                //If the field value is null and operator is Does Not Contain, the wizard should be loaded.                             
                                mapResult.put(oExpression.SVMXC__Sequence__c,'T');
                            }
                            
                        }
                        else if(strOperater == 'IN' || strOperater == 'NOTIN')
                        {
                            
                            String[] multValues = oExpression.SVMXC__Operand__c.split(',');
                            set<string> setValues = new set<string>();
                            if(multValues != null)
                            {
                                for(string str: multValues)
                                {
                                    setValues.add(str);
                                }
                            }
                            if( referenceValue != null ) {                            
                                if( setValues.contains( referenceValue ) ) {
                                    mapResult.put(oExpression.SVMXC__Sequence__c,'T');
                                }
                            } else if(setValues.contains(Val) && strOperater == 'IN')
                                mapResult.put(oExpression.SVMXC__Sequence__c, 'T');
                            if(!setValues.contains(Val) && strOperater == 'NOTIN')
                                mapResult.put(oExpression.SVMXC__Sequence__c, 'T');
                        }
                    }
                    else if(strFieldType == 'DATETIME')
                    {
                        if(strOperater == 'ISNULL')
                        {
                            if(Rec.get(oExpression.SVMXC__Field_Name__c) == null)
                                mapResult.put(oExpression.SVMXC__Sequence__c,'T');
                        }
                        else if(strOperater == 'NOTNULL' || strOperater == 'ISNOTNULL')
                        {
                            if(Rec.get(oExpression.SVMXC__Field_Name__c) != null)
                                mapResult.put(oExpression.SVMXC__Sequence__c,'T');
                        }
                        object Val;
                        if(Rec.get(oExpression.SVMXC__Field_Name__c) != null)
                            val = Rec.get(oExpression.SVMXC__Field_Name__c);
                        
                        system.debug(LoggingLevel.WARN, 'Field val = ' + Rec.get(oExpression.SVMXC__Field_Name__c));
                        
                        if(strOperater == 'EQ')
                        {                           
                            system.debug('TEST ENTER1 ==Val=='+Val);
                            system.debug('getDateTime Result =='+getDateTime(oExpression.SVMXC__Operand__c, Datetime.valueOf(Val)));
                            //Changes done by NIDHI as part of defect 044708
                            //Fixing issue with LAST_N_DAYS criteria when operator is equals
                            if(INTF_GetServiceFlowWizard.isWizardExpression && oExpression.SVMXC__Operand__c.toUpperCase().contains('LAST_N_DAYS:')){
                                if(Val != null && (getDateTime(oExpression.SVMXC__Operand__c, Datetime.valueOf(Val)) < Datetime.valueOf(Val) &&  Datetime.valueOf(Val) < datetime.now() ))
                                    mapResult.put(oExpression.SVMXC__Sequence__c,'T');
                            }else if(INTF_GetServiceFlowWizard.isWizardExpression && oExpression.SVMXC__Operand__c.toUpperCase().contains('NEXT_N_DAYS:')){
                                if(Val != null && (datetime.now() < Datetime.valueOf(Val) && Datetime.valueOf(Val) < getDateTime(oExpression.SVMXC__Operand__c, Datetime.valueOf(Val))))
                                    mapResult.put(oExpression.SVMXC__Sequence__c,'T');
                            }else{
                                if(Val != null && (Datetime.valueOf(Val) == getDateTime(oExpression.SVMXC__Operand__c, Datetime.valueOf(Val))))
                                    mapResult.put(oExpression.SVMXC__Sequence__c,'T');
                            }
                        }
                        else if(strOperater == 'NE')
                        {      
                            //Changes done by NIDHI as part of BAC-4460
                            //Fixing issue with LAST_N_DAYS criteria when operator contains equals
                            if(INTF_GetServiceFlowWizard.isWizardExpression && oExpression.SVMXC__Operand__c.toUpperCase().contains('LAST_N_DAYS:')){
                                if(Val != null && (getDateTime(oExpression.SVMXC__Operand__c, Datetime.valueOf(Val)) > Datetime.valueOf(Val) ||  Datetime.valueOf(Val) > datetime.now() ))
                                    mapResult.put(oExpression.SVMXC__Sequence__c,'T');
                            }else if(INTF_GetServiceFlowWizard.isWizardExpression && oExpression.SVMXC__Operand__c.toUpperCase().contains('NEXT_N_DAYS:')){
                                if(Val != null && (datetime.now() > Datetime.valueOf(Val) || Datetime.valueOf(Val) > getDateTime(oExpression.SVMXC__Operand__c, Datetime.valueOf(Val))))
                                    mapResult.put(oExpression.SVMXC__Sequence__c,'T');
                            }else{
                                if(Val != null && (Datetime.valueOf(Val) != getDateTime(oExpression.SVMXC__Operand__c, Datetime.valueOf(Val))))
                                    mapResult.put(oExpression.SVMXC__Sequence__c,'T');
                            }
                            
                        }
                        else if(strOperater == 'IN' || strOperater == 'NOTIN')
                        {
                            String[] multValues = oExpression.SVMXC__Operand__c.split(',');
                            set<object> setValues = new set<object>();
                            if(multValues != null)
                            {
                                for(string str: multValues)
                                {
                                    setValues.add((object)getDateTime(str,  Datetime.valueOf(Val) ));
                                }
                            }
                            if(setValues.contains(Val) && strOperater == 'IN')
                                mapResult.put(oExpression.SVMXC__Sequence__c,'T');
                            if(!setValues.contains(Val) && strOperater == 'NOTIN')
                                mapResult.put(oExpression.SVMXC__Sequence__c,'T');
                        }
                        else if(strOperater == 'LT')
                        {
                            //Changes done by NIDHI as part of BAC-4460
                            //Fixing issue with NEXT_N_DAYS criteria when operator is LessThan
                            if(INTF_GetServiceFlowWizard.isWizardExpression && oExpression.SVMXC__Operand__c.toUpperCase().contains('NEXT_N_DAYS:')){
                                if(Val != null && (Datetime.valueOf(Val) < datetime.now() ))
                                    mapResult.put(oExpression.SVMXC__Sequence__c,'T');
                            }else{
                                if(Val != null && (Datetime.valueOf(Val) < getDateTime(oExpression.SVMXC__Operand__c, Datetime.valueOf(Val))))
                                mapResult.put(oExpression.SVMXC__Sequence__c,'T');
                            }
                        }
                        else if(strOperater == 'GT')
                        {
                            //Changes done by NIDHI as part of BAC-4460
                            //Fixing issue with LAST_N_DAYS criteria when operator is GreaterThan
                            if(INTF_GetServiceFlowWizard.isWizardExpression && oExpression.SVMXC__Operand__c.toUpperCase().contains('LAST_N_DAYS:')){
                                if(Val != null && (Datetime.valueOf(Val) > datetime.now() ))
                                    mapResult.put(oExpression.SVMXC__Sequence__c,'T');
                            }else{
                                if(Val != null && (Datetime.valueOf(Val)  > getDateTime(oExpression.SVMXC__Operand__c, Datetime.valueOf(Val))))
                                mapResult.put(oExpression.SVMXC__Sequence__c,'T');
                            }
                            
                        }
                        else if(strOperater == 'LE')
                        {
                            //Changes done by NIDHI as part of defect 044708
                            //Fixing issue with LAST_N_DAYS criteria when operator is equals
                            if(INTF_GetServiceFlowWizard.isWizardExpression && oExpression.SVMXC__Operand__c.toUpperCase().contains('LAST_N_DAYS:')){                                                             
                                if(Val != null && (getDateTime(oExpression.SVMXC__Operand__c, Datetime.valueOf(Val)) < Datetime.valueOf(Val) &&  Datetime.valueOf(Val) < datetime.now() ) || (Datetime.valueOf(Val)  < getDateTime(oExpression.SVMXC__Operand__c, Datetime.valueOf(Val))))
                                    mapResult.put(oExpression.SVMXC__Sequence__c,'T');    
                            }else{
                                if(Val != null && (Datetime.valueOf(Val)  <= getDateTime(oExpression.SVMXC__Operand__c, Datetime.valueOf(Val))))
                                mapResult.put(oExpression.SVMXC__Sequence__c,'T');
                            }
                        }
                        else if(strOperater == 'GE')
                        {
                            if(INTF_GetServiceFlowWizard.isWizardExpression && oExpression.SVMXC__Operand__c.toUpperCase().contains('NEXT_N_DAYS:')){
                                if(Val != null && (Datetime.valueOf(Val) > datetime.now()))
                                    mapResult.put(oExpression.SVMXC__Sequence__c,'T');
                            }else{
                                if(Val != null && (Datetime.valueOf(Val)  >= getDateTime(oExpression.SVMXC__Operand__c, Datetime.valueOf(Val))))
                                mapResult.put(oExpression.SVMXC__Sequence__c,'T');
                            }
                        }
                    }
                    else if(strFieldType == 'DATE')
                    {
                        if(strOperater == 'ISNULL')
                        {
                            if(Rec.get(oExpression.SVMXC__Field_Name__c) == null)
                                mapResult.put(oExpression.SVMXC__Sequence__c,'T');
                        }
                        else if(strOperater == 'NOTNULL' || strOperater == 'ISNOTNULL')
                        {
                            if(Rec.get(oExpression.SVMXC__Field_Name__c) != null)
                                mapResult.put(oExpression.SVMXC__Sequence__c,'T');
                        }
                        object Val;
                        if(Rec.get(oExpression.SVMXC__Field_Name__c) != null)
                            val = Rec.get(oExpression.SVMXC__Field_Name__c);
                        
                        if(strOperater == 'EQ')
                        {
                            //Changes done by NIDHI as part of BAC-4460
                            //Fixing issue with LAST_N_DAYS criteria when operator contains equals
                            if(INTF_GetServiceFlowWizard.isWizardExpression && oExpression.SVMXC__Operand__c.toUpperCase().contains('LAST_N_DAYS:')){
                                if(Val != null && (getDate(oExpression.SVMXC__Operand__c) <= Date.valueOf(Val) &&  Date.valueOf(Val) <= date.today() ))
                                    mapResult.put(oExpression.SVMXC__Sequence__c,'T');
                            }else if(INTF_GetServiceFlowWizard.isWizardExpression && oExpression.SVMXC__Operand__c.toUpperCase().contains('NEXT_N_DAYS:')){
                                if(Val != null && (date.today() <= Date.valueOf(Val) && Date.valueOf(Val) <= getDate(oExpression.SVMXC__Operand__c)))
                                    mapResult.put(oExpression.SVMXC__Sequence__c,'T');
                            }else{
                                if(val != null && (Date.valueOf(val) ==  getDate(oExpression.SVMXC__Operand__c)))
                                mapResult.put(oExpression.SVMXC__Sequence__c,'T');
                            }
                            
                        }
                        else if(strOperater == 'NE')
                        {
                            //Changes done by NIDHI as part of BAC-4460
                            //Fixing issue with LAST_N_DAYS criteria when operator contains equals
                            if(INTF_GetServiceFlowWizard.isWizardExpression && oExpression.SVMXC__Operand__c.toUpperCase().contains('LAST_N_DAYS:')){
                                if(Val != null && (getDate(oExpression.SVMXC__Operand__c) > Date.valueOf(Val) ||  Date.valueOf(Val) > Date.today() ))
                                    mapResult.put(oExpression.SVMXC__Sequence__c,'T');
                            }else if(INTF_GetServiceFlowWizard.isWizardExpression && oExpression.SVMXC__Operand__c.toUpperCase().contains('NEXT_N_DAYS:')){
                                if(Val != null && (date.today() > Date.valueOf(Val) || Date.valueOf(Val) > getDate(oExpression.SVMXC__Operand__c)))
                                    mapResult.put(oExpression.SVMXC__Sequence__c,'T');
                            }else{
                                if(val != null && (Date.valueOf(val) != getDate(oExpression.SVMXC__Operand__c)))
                                mapResult.put(oExpression.SVMXC__Sequence__c,'T');
                            }
                        }
                        else if(strOperater == 'IN' || strOperater == 'NOTIN')
                        {
                            String[] multValues = oExpression.SVMXC__Operand__c.split(',');
                            set<object> setValues = new set<object>();
                            if(multValues != null)
                            {
                                for(string str: multValues)
                                {
                                    setValues.add((object)getDate(str));
                                }
                            }
                            if(setValues.contains(Val) && strOperater == 'IN')
                                mapResult.put(oExpression.SVMXC__Sequence__c,'T');
                            if(!setValues.contains(Val) && strOperater == 'NOTIN')
                                mapResult.put(oExpression.SVMXC__Sequence__c,'T');
                        }
                        else if(strOperater == 'LT')
                        {
                            if(INTF_GetServiceFlowWizard.isWizardExpression && oExpression.SVMXC__Operand__c.toUpperCase().contains('NEXT_N_DAYS:')){
                                if(Val != null && (Date.valueOf(Val) < date.today()))
                                    mapResult.put(oExpression.SVMXC__Sequence__c,'T');
                            }else{
                                if(val != null && (Date.valueOf(val) < getDate(oExpression.SVMXC__Operand__c)))
                                mapResult.put(oExpression.SVMXC__Sequence__c,'T');
                            }
                        }
                        else if(strOperater == 'GT')
                        {
                            if(INTF_GetServiceFlowWizard.isWizardExpression && oExpression.SVMXC__Operand__c.toUpperCase().contains('LAST_N_DAYS:')){
                                if(Val != null && (Date.valueOf(Val) > date.today()))
                                    mapResult.put(oExpression.SVMXC__Sequence__c,'T');
                            }else{
                                if(val != null && (Date.valueOf(val) > getDate(oExpression.SVMXC__Operand__c)))
                                mapResult.put(oExpression.SVMXC__Sequence__c,'T');
                            }
                        }
                        else if(strOperater == 'LE')
                        {
                            //Changes done by NIDHI as part of BAC-4460
                            //Fixing issue with LAST_N_DAYS criteria when operator contains equals
                            if(INTF_GetServiceFlowWizard.isWizardExpression && oExpression.SVMXC__Operand__c.toUpperCase().contains('LAST_N_DAYS:')){                                                             
                                if(Val != null && (getDate(oExpression.SVMXC__Operand__c) <= Date.valueOf(Val) &&  Date.valueOf(Val) <= date.today() ) || (Date.valueOf(Val)  <= getDate(oExpression.SVMXC__Operand__c)))
                                    mapResult.put(oExpression.SVMXC__Sequence__c,'T');    
                            }else{
                                if(val != null && (Date.valueOf(val) <= getDate(oExpression.SVMXC__Operand__c)))
                                mapResult.put(oExpression.SVMXC__Sequence__c,'T');
                            }
                        }
                        else if(strOperater == 'GE')
                        {
                            if(INTF_GetServiceFlowWizard.isWizardExpression && oExpression.SVMXC__Operand__c.toUpperCase().contains('NEXT_N_DAYS:')){
                                if(Val != null && (Date.valueOf(Val) >= date.today()))
                                    mapResult.put(oExpression.SVMXC__Sequence__c,'T');
                            }else{
                                if(val != null && (Date.valueOf(val) >= getDate(oExpression.SVMXC__Operand__c)))
                                mapResult.put(oExpression.SVMXC__Sequence__c,'T');
                            }
                        }
                    }
                }
            }
            if(!isValidString(AdvExp))
            {
                set<string> setTemp = new set<string>();
                setTemp.addAll(mapResult.values());
                if(setTemp.size() == 0 || setTemp.Contains('F'))
                    return false;
                else
                    return true;
            }
            AdvExp = AdvExp.ToUpperCase();
            /*AdvExp = AdvExp.replaceAll('(', ' ( ');
            AdvExp = AdvExp.replaceAll(')', ' ) ');*/
            AdvExp = AdvExp.replaceAll('AND', ' && ');
            AdvExp = AdvExp.replaceAll('OR', ' || ');
            AdvExp = AdvExp.replaceAll('NOT', ' ! ');
            AdvExp = ' ' + AdvExp + ' ';
            
            /* BAC-3846 Anchal 
             * To make the expression unique, we shall create a Map of Sequence and it's corrsponding conversion
             * If sequence is 1, corresponding value is ~1~. 
             * */
            
            Map <String, String> mapUniqOrderSeq = new Map <String, String>();

            for(integer j =1 ;  j<= lstExpressions.size(); j++){
                mapUniqOrderSeq.put(String.valueOf(j), ' ~'+String.valueOf(j)+ '~ ');
            }
            
            for(integer k = 0; k < lstExpressions.size(); k++)
            {
                /* BAC-3846 Anchal 
                 * Using pattern compile and matcher class to perform and replace the sequence. 
                 * If sequence is 1, corresponding value is ~1~. 
                 * */
                String key = String.valueOf(k+1);
                String val = mapUniqOrderSeq.get(key);
            
                Pattern MyPatternKey = Pattern.compile('\\b'+ key+ '\\b');
                Matcher MyMatcherSub = MyPatternKey.matcher(AdvExp);
                AdvExp = MyMatcherSub.replaceAll(val);
                
                //AdvExp = AdvExp.replace(string.valueOf(k+1),' ~' + string.valueOf(k+1));
                //AdvExp = AdvExp.replace(' ' + string.valueOf(k+1) + ' ',' ~' + string.valueOf(k+1) + '~ ');
                /*AdvExp = AdvExp.replace('(' + string.valueOf(k+1) + ' ','( ~' + string.valueOf(k+1) + '~ ');
                AdvExp = AdvExp.replace(' ' + string.valueOf(k+1) + ')',' ~' + string.valueOf(k+1) + '~ )');*/
            }
            for(integer k=0;k<lstExpressions.size();k++)
            {
                if(mapResult.containsKey(lstExpressions[k].SVMXC__Sequence__c) && lstExpressions[k].SVMXC__Sequence__c != null)
                    AdvExp = AdvExp.replace('~' + string.valueOf(lstExpressions[k].SVMXC__Sequence__c.intValue()) + '~', mapResult.get(lstExpressions[k].SVMXC__Sequence__c));               
            }
            AdvExp = AdvExp.replaceAll(' ','');  
            String Temp = '';
            do
            {
                Temp = AdvExp;
                AdvExp  = AdvExp.replace('(F)','F').replace('!T','F').replace('!F','T').replace('(T)','T').replace('F&&F','F').replace('F&&T','F').replace('T&&F','F').replace('T&&T','T').replace('F||F','F').replace('F||T','T').replace('T||F','T').replace('T||T','T');
            }
            while(Temp != AdvExp);
            if(AdvExp=='T')
                return true;
            else
                return false;
        }

        // BAC-3670 - Added the method for Date calculation while using field of type "Date"
        private Date getDate(String str)
        {
            try
            {
                if(str != null && (str.toUpperCase() == 'TODAY' || str.toUpperCase() == 'SVMX.NOW' || str.toUpperCase() == 'NOW'))
                    return Date.today();
                else if(str != null && str.toUpperCase() == 'TOMORROW')
                    return Date.today().addDays(1);
                else if(str != null && str.toUpperCase() == 'YESTERDAY')
                    return Date.today().addDays(-1);
                else if(str != null && str.toUpperCase().contains('NEXT_N_DAYS:'))
                    return Date.today().addDays(Integer.ValueOf(str.toUpperCase().split(':')[1]) );
                else if(str != null && str.toUpperCase().contains('LAST_N_DAYS:'))
                    return Date.today().addDays(-1 * Integer.ValueOf(str.toUpperCase().split(':')[1]) );
                else 
                    return Date.valueOf(str);
            }
            catch(exception ex)
            {
                ApexPages.AddMessage(new ApexPages.Message(ApexPages.Severity.ERROR, ex.getMessage()));
                return null;
            }
        }

        private DateTime getDateTime(String str, Datetime operandVal)
        {
            try
            {
                if(str != null && ( str.toUpperCase() == 'SVMX.NOW' || str.toUpperCase() == 'NOW' ))
                    return DateTime.now(); 
                else if(str != null && str.toUpperCase() == 'TODAY' ){ 
                    // BAC-3670 - When the value to be compared with is today, then pass the same timestamp as Operand for comparison to happen. 
                    return Datetime.newInstance(Date.today(), Time.newInstance(operandVal.hour(), operandVal.minute(), operandVal.second(), operandVal.millisecond()) );
                }
                else if(str != null && str.toUpperCase() == 'TOMORROW')
                    return Datetime.newInstance(Date.today().addDays(1), Time.newInstance(operandVal.hour(), operandVal.minute(), operandVal.second(), operandVal.millisecond()) );
                else if(str != null && str.toUpperCase() == 'YESTERDAY')
                    return Datetime.newInstance(Date.today().addDays(-1), Time.newInstance(operandVal.hour(), operandVal.minute(), operandVal.second(), operandVal.millisecond()) );
                else if(str != null && str.toUpperCase().contains('NEXT_N_DAYS:'))
                    return Datetime.newInstance(Date.today().addDays(Integer.ValueOf(str.toUpperCase().split(':')[1])), time.newInstance(0, 0, 0, 0));
                else if(str != null && str.toUpperCase().contains('LAST_N_DAYS:')){
                    return Datetime.newInstance(Date.today().addDays(-1 * Integer.ValueOf(str.toUpperCase().split(':')[1])), time.newInstance(0, 0, 0, 0));
                }
                else{
                    // return Datetime.parse(str.replace('/','-'));
                    //BAC-3559 : Date time parse fix 
                    return Datetime.valueOf(str);
                }
            }
            catch(exception ex)
            {
                //ApexPages.AddMessage(new ApexPages.Message(ApexPages.Severity.ERROR, ex.getMessage()));
                return null;
            }
        }
        private List<SVMXC__ServiceMax_Config_Data__c> sortingExpressionList(List<SVMXC__ServiceMax_Config_Data__c> lstexp)
        {
            map<Integer, SVMXC__ServiceMax_Config_Data__c> mapTemp = new map<Integer, SVMXC__ServiceMax_Config_Data__c>();
            for(SVMXC__ServiceMax_Config_Data__c oExp :lstexp)
            {   mapTemp.put(oExp.SVMXC__Sequence__c.intValue(),oExp);}
            list<Integer> lstTemp = new list<Integer>();
            lstTemp.addAll(mapTemp.KeySet());
            lstTemp.sort();
            lstexp.clear();
            for(Integer iIndex: lstTemp)
            {   lstexp.add(mapTemp.get(iIndex));}
            return lstexp;
        }
        private List<SVMXC__ServiceMax_Processes__c> sortRuleList(set<Id> lstRules, map<Id, SVMXC__ServiceMax_Processes__c> mapRules)
        {
            map<Integer, SVMXC__ServiceMax_Processes__c> mapTemp = new map<Integer, SVMXC__ServiceMax_Processes__c>();
            list<SVMXC__ServiceMax_Processes__c> lstTempRule = new list<SVMXC__ServiceMax_Processes__c>();
            for(Id strRule :lstRules)
            {   
                if(mapRules.ContainsKey(strRule))
                {
                    SVMXC__ServiceMax_Processes__c oRule = mapRules.get(strRule);
                    if(oRule.SVMXC__Sequence__c != null)
                        mapTemp.put(oRule.SVMXC__Sequence__c.intValue(),oRule);
                    else 
                        lstTempRule.add(oRule);
                }
            }
            list<Integer> lstTemp = new list<Integer>();
            lstTemp.addAll(mapTemp.KeySet());
            lstTemp.sort();
            
            list<SVMXC__ServiceMax_Processes__c> lstRule = new list<SVMXC__ServiceMax_Processes__c>();
            for(Integer iIndex: lstTemp)
            {   lstRule.add(mapTemp.get(iIndex));}
            lstRule.addAll(lstTempRule);
            return lstRule;
        }
        private List<SVMXC__ServiceMax_Processes__c> sortRuleList(List<SVMXC__ServiceMax_Processes__c> lstRule)
        {
            map<Integer, SVMXC__ServiceMax_Processes__c> mapTemp = new map<Integer, SVMXC__ServiceMax_Processes__c>();
            list<SVMXC__ServiceMax_Processes__c> lstTempRule = new list<SVMXC__ServiceMax_Processes__c>();
            for(SVMXC__ServiceMax_Processes__c oRule :lstRule)
            {   
                if(oRule.SVMXC__Sequence__c != null)
                    mapTemp.put(oRule.SVMXC__Sequence__c.intValue(),oRule);
                else 
                    lstTempRule.add(oRule);
            }
            list<Integer> lstTemp = new list<Integer>();
            lstTemp.addAll(mapTemp.KeySet());
            lstTemp.sort();
            lstRule.clear();
            for(Integer iIndex: lstTemp)
            {   lstRule.add(mapTemp.get(iIndex));}
            lstRule.addAll(lstTempRule);
            return lstRule;
        }
        public boolean isValidString(string str)
        {
            if(str != null && str.length() > 0)
                return true;
            return false;
        }
    }
    
    public boolean SVMX_Named_Expressions_Upd_Ref_Flds()
    {
        boolean isSucess = true;
        try{
            List<SVMXC__ServiceMax_Properties__c> lstProperty = new List<SVMXC__ServiceMax_Properties__c>();
            lstProperty = readPropertyElement('SVMX_NAMED_EXPRESSIONS_UPD_REF_FLDS');
            System.debug(LoggingLevel.Warn,'read property element : '+lstProperty);
            if(lstProperty == null || lstProperty.size() == 0)
            {
                List<SVMXC__ServiceMax_Config_Data__c> lstCfgDtaNmdExps = new List<SVMXC__ServiceMax_Config_Data__c>();
                Map<String, Map<String, String>> mapObjctNameVsMap = new Map<String, Map<String, String>>();
                Map<String,Boolean> PermittedStandardObjectList = new Map<String,Boolean>();
                Map<String, Schema.DescribeSObjectResult> mapAPINameObjDesc = new Map<String, Schema.DescribeSObjectResult>();
                //SVMXC.COMM_Utils commutils = new SVMXC.COMM_Utils();
                Map<String,Schema.SObjectField> objfieldMap = new Map<String,Schema.SObjectField>();
                Map<String, String> mapObjectVsNamedFild = new Map<String, String>();
                //BAC-5355
                //Map<String, Schema.SObjectType> allObjs = Schema.getGlobalDescribe();
                Map<String, Schema.SObjectType> allObjs  = COMM_Utils_DescribeCall.getInstance().getGlobalDescribeCall();
    
                lstCfgDtaNmdExps = [Select Id, SVMXC__Field_Name__c, SVMXC__Field_Relationship_Name__c, SVMXC__FKey_Name_Field__c, SVMXC__Expression_Rule__r.SVMXC__Source_Object_Name__c from SVMXC__ServiceMax_Config_Data__c where SVMXC__Expression_Type__c = 'EXP_Named' and RecordType.Name = 'Expressions' and SVMXC__Display_Type__c = 'REFERENCE' and SVMXC__Expression_Rule__c IN (Select Id from SVMXC__ServiceMax_Processes__c where SVMXC__Rule_Type__c = 'Named Expression' and RecordType.Name = 'SVMX Rule') and SVMXC__Expression_Rule__c != null and (SVMXC__Field_Relationship_Name__c = null OR  SVMXC__FKey_Name_Field__c = null)]; //SDL-SVMX-FLS-NOT-ENFORCED-META-DATA

            
                if(lstCfgDtaNmdExps != null && lstCfgDtaNmdExps.size() >0)
                {
                    for(SVMXC__ServiceMax_Config_Data__c ObjConfigData : lstCfgDtaNmdExps)
                    {
                        if(!mapObjctNameVsMap.containsKey(ObjConfigData.SVMXC__Expression_Rule__r.SVMXC__Source_Object_Name__c))
                            mapObjctNameVsMap.put(ObjConfigData.SVMXC__Expression_Rule__r.SVMXC__Source_Object_Name__c, new Map<String, String>());
                        if(!mapObjctNameVsMap.get(ObjConfigData.SVMXC__Expression_Rule__r.SVMXC__Source_Object_Name__c).containsKey(ObjConfigData.SVMXC__Field_Name__c))
                            mapObjctNameVsMap.get(ObjConfigData.SVMXC__Expression_Rule__r.SVMXC__Source_Object_Name__c).put(ObjConfigData.SVMXC__Field_Name__c, '');
                    }

                    if(allObjs.size() > 0)
                    {
                        for(String s : allObjs.keyset())
                        {
                            Schema.DescribeSObjectResult objDesc = allObjs.get(s).getDescribe();
                            if(!mapAPINameObjDesc.containskey(objDesc.getName()))
                              mapAPINameObjDesc.put(objDesc.getName(),objDesc);
                        }
                    }

                    PermittedStandardObjectList = SVMX_getPermittedStandardObjectListAccToLicense('Enterprise');
                    
                    if(mapAPINameObjDesc.size() > 0)
                    {
                        for(String strKey : mapAPINameObjDesc.keyset())
                        {
                            if((PermittedStandardObjectList.size() > 0 && PermittedStandardObjectList.containsKey(strKey)) || strKey == 'BusinessHours')
                            {
                                objfieldMap = mapAPINameObjDesc.get(strKey).fields.getMap();
                                for(String strkey2 : objfieldMap.keyset())
                                {
                                    Schema.DescribeFieldResult schmDescFildRstl = objfieldMap.get(strkey2).getDescribe();
                                    if(schmDescFildRstl.isNameField())
                                    {
                                        mapObjectVsNamedFild.put(strKey , schmDescFildRstl.getName());
                                        break;
                                    }
                                }
                            }
                            else
                            {
                                if(mapAPINameObjDesc.get(strKey).isCustom())
                                    mapObjectVsNamedFild.put(strKey, 'Name');
                            }
                        }
                        Map<String, String> mapTemp = new Map<String, String>();
                        for(String strKey : mapAPINameObjDesc.keyset())
                        {
                            mapTemp = new Map<String, String>();
                            if(mapObjctNameVsMap.containskey(strKey))
                            {
                                mapTemp = mapObjctNameVsMap.get(strKey);
                                objfieldMap = mapAPINameObjDesc.get(strKey).fields.getMap();
                                for(String strkey2 : objfieldMap.keyset())
                                {
                                    Schema.DescribeFieldResult schmDescFildRstl = objfieldMap.get(strkey2).getDescribe();
                                    String stRobjctName = '';
                                    String strRletionshpName = '';
                                    if(mapTemp.containskey(schmDescFildRstl.getName())  && mapTemp.get(schmDescFildRstl.getName()) != 'WhoId' && mapTemp.get(schmDescFildRstl.getName()) != 'WhatId' )
                                    {
                                        System.debug('schmDescFildRstl : '+schmDescFildRstl.ReferenceTo);
                                        List<Schema.SObjectType> lstSobjecType = schmDescFildRstl.ReferenceTo;
                                        if(lstSobjecType.size() > 1)
                                        {
                                            for(Schema.SObjectType schmSobjctTyp : lstSobjecType)
                                            {
                                                if(schmSobjctTyp.getDescribe().getName() == 'User')
                                                    stRobjctName = schmSobjctTyp.getDescribe().getName();
                                            }
                                        }
                                        else
                                        {
                                            if(lstSobjecType.size() == 1)
                                            {
                                                stRobjctName = lstSobjecType[0].getDescribe().getName();
                                            }
                                        }
                                        
                                        strRletionshpName = schmDescFildRstl.getRelationshipName();
                                        String strfinalValue = '';
                                        if(mapObjectVsNamedFild.containskey(stRobjctName))
                                            strfinalValue = strRletionshpName+'.'+mapObjectVsNamedFild.get(stRobjctName);
                                        else
                                            strfinalValue = strRletionshpName+'.';
                                        mapTemp.put(schmDescFildRstl.getName(), strfinalValue);
                                        mapObjctNameVsMap.get(strKey).putAll(mapTemp);
                                    }
                                }   
                            }
                        }
                    }

                    for(SVMXC__ServiceMax_Config_Data__c ObjConfigData : lstCfgDtaNmdExps)
                    {
                        if(mapObjctNameVsMap.containsKey(ObjConfigData.SVMXC__Expression_Rule__r.SVMXC__Source_Object_Name__c))
                        {
                            if(mapObjctNameVsMap.get(ObjConfigData.SVMXC__Expression_Rule__r.SVMXC__Source_Object_Name__c).containsKey(ObjConfigData.SVMXC__Field_Name__c))
                            {
                                String rltionshipNameedFld = mapObjctNameVsMap.get(ObjConfigData.SVMXC__Expression_Rule__r.SVMXC__Source_Object_Name__c).get(ObjConfigData.SVMXC__Field_Name__c);
                                System.debug('fields : '+rltionshipNameedFld);
                                if(rltionshipNameedFld != null && rltionshipNameedFld != ''){
                                    List<string> lstRefFlds = rltionshipNameedFld.replace('.', ':').split(':');
                                    System.debug('fields2 : '+lstRefFlds);
                                    ObjConfigData.SVMXC__Field_Relationship_Name__c = lstRefFlds[0]; 
                                    ObjConfigData.SVMXC__FKey_Name_Field__c = lstRefFlds[1]; 
                                }
                            }
                        }
                    }
                    update lstCfgDtaNmdExps; //SDL-SVMX-FLS-NOT-ENFORCED-META-DATA
                    insertPropertyElement('COMP002','SVMX_NAMED_EXPRESSIONS_UPD_REF_FLDS','TRUE');
                }
            
            }
        }
        catch(Exception ex)
        {
            isSucess = false;
            System.debug(LoggingLevel.Warn,' log in catch : '+ex.getMessage() );
            return isSucess;
        }
        return isSucess;
    }
    
    //Method to get ServiceMax license of the customer org
    public String getSVMX_License(){
        List<SVMXC__ServiceMax_Properties__c> objSVMXProperties = new List<SVMXC__ServiceMax_Properties__c>();
       
        List<String> queryFields = new List<String> {'SVMXC__Value__c'};
        if( ! COMM_SecurityUtils.getInstance().verifyFieldAccess( 'SVMXC__ServiceMax_Properties__c', queryFields, COMM_SecurityUtils.Access.Accessible ) ) {        
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error, System.label.COMM001_TAG142));
            return null;
        }        
        
        objSVMXProperties = [Select SVMXC__Value__c from SVMXC__ServiceMax_Properties__c where SVMXC__Key__c = 'License Type' and Name = 'PROP001' Limit 1]; //SDL-SVMX-READ-FLS-ENFORCED
        
        if (objSVMXProperties != null && objSVMXProperties.size() >0){
            return objSVMXProperties[0].SVMXC__Value__c;
        }
        return '';
    }
    
    /*
     Defect 040333 -  SOQL on record type object gives all the record types associated to Profile. 
     We will be filtering it out using Schema.recordtypeinfo
    */
    
    /*public static List<String> getObjectAvailRecordType(String objectName){
    
        Schema.SObjectType sobjectTypeParam = Schema.getGlobalDescribe().get(objectName);
        
        List<String> recordTypeNames = new List<String>();
            
        if(sobjectTypeParam != null) {
            List<RecordTypeInfo> objectRecordTypeinfo = sobjectTypeParam.getDescribe().getRecordTypeInfos();
            if (objectRecordTypeinfo.size() > 1) {
                for (RecordTypeInfo recordInfo : objectRecordTypeinfo) {
                   if (recordInfo.isAvailable() && !recordInfo.isMaster())
                        recordTypeNames.add(recordInfo.getName());
                }
            } 
            else recordTypeNames.add(objectRecordTypeinfo[0].getName());
        
            }
               
        return recordTypeNames;
    } */
    /*Defect 42506: Re- written above method to use recordType Id instead of Name */
    public static List<ID> getObjectAvailRecordType(String objectName){
    
        //BAC-5355 start
        //Schema.SObjectType sobjectTypeParam = Schema.getGlobalDescribe().get(objectName);
         Schema.SObjectType sobjectTypeParam = COMM_Utils_DescribeCall.getInstance().getGlobalDescribeCall().get(objectName);
        //BAC-5355 start End
        
          List<ID> recordTypeIds = new List<ID>();  
        if(sobjectTypeParam != null) {
            List<RecordTypeInfo> objectRecordTypeinfo = sobjectTypeParam.getDescribe().getRecordTypeInfos();
            if (objectRecordTypeinfo.size() > 1) {
                for (RecordTypeInfo recordInfo : objectRecordTypeinfo) {
                   if (recordInfo.isAvailable() && !recordInfo.isMaster())
                        recordTypeIds.add(recordInfo.getRecordTypeId());
                }
            } 
            else if(!objectRecordTypeinfo.isEmpty())//Defect 042254 : excluding the object which doesn't have record type
            {
                recordTypeIds.add(objectRecordTypeinfo[0].getRecordTypeId());
            }
               
        }        
        return recordTypeIds;
    
    }
    
    /*
    New method introduced for fixing this issue SFD-973 where we will not be able to find feild api name with namespace
    This method is for returning field map for the send object where we will
    have namespace for the key in the map because of higher API version of class
    */
    public static Map<String,Schema.SObjectField> getFieldMapForTheObject(String strObjectName){
            /*
            Map<String,Schema.SObjectField> fieldMap = new Map<String,Schema.SObjectField>();
            Map<String, Schema.SObjectType> globalDesc = Schema.getGlobalDescribe();
            if(strObjectName != null && globalDesc.containsKey(strObjectName)){
                Schema.SObjectType sObjType = globalDesc.get(strObjectName);
                fieldMap = sObjType.getDescribe().fields.getMap();
            }
            globalDesc.clear();
            return fieldMap;*/
                        //Below Field detial method retuns FieldMap of object
            Map<String,Schema.SObjectField> fieldMap = COMM_Utils_DescribeCall.getObjectFieldDetails(strObjectName);
            if(fieldMap == null)
            {
                 fieldMap = new Map<String, Schema.sObjectField>();
            }
            return fieldMap;
    }
    

    //Application Features 
    public Boolean isFeatureEnabled(String fName , String userId){
        Boolean isEnabled = false;
        String featureApplicationId = '';
        List<SVMXC__SM_Application_Feature__c> applicationFeatureList = new List<SVMXC__SM_Application_Feature__c>();
        applicationFeatureList = [SELECT Id from SVMXC__SM_Application_Feature__c WHERE SVMXC__SM_Feature_Name__c =:fName]; //SDL-SVMX-FLS-NOT-ENFORCED-META-DATA
        if(applicationFeatureList!=null && applicationFeatureList.size() > 0){
            featureApplicationId = applicationFeatureList[0].Id;
            Integer count = [SELECT count() FROM SVMXC__SM_Feature_Permission__c WHERE SVMXC__SM_User__c =:userId AND  SVMXC__SM_Application_Feature__c=:featureApplicationId];
            if(count>0)isEnabled = true;  
        }
        return isEnabled;
    }

    public Map<String,Boolean> getFeaturePermissionInfo(String fName, List<String> userIdList){
        Map<String,Boolean> userMap = new Map<String,Boolean>();
        for(String userId:userIdList){
            userMap.put(userId, false);
        }
        List<SVMXC__SM_Feature_Permission__c> featurePermissionList = new List<SVMXC__SM_Feature_Permission__c>();
         List<SVMXC__SM_Application_Feature__c> applicationFeature = [SELECT Id from SVMXC__SM_Application_Feature__c WHERE SVMXC__SM_Feature_Name__c =:fName]; //SDL-SVMX-FLS-NOT-ENFORCED-META-DATA
         if(applicationFeature !=null && applicationFeature.size()>0){
           String applicationFeatureId = applicationFeature[0].Id;
           featurePermissionList = [SELECT Id,SVMXC__SM_User__c FROM SVMXC__SM_Feature_Permission__c WHERE SVMXC__SM_User__c IN :userIdList AND  SVMXC__SM_Application_Feature__c=:applicationFeatureId]; //SDL-SVMX-FLS-NOT-ENFORCED-META-DATA
         }
         for(SVMXC__SM_Feature_Permission__c featurePermission:featurePermissionList){
            userMap.put(featurePermission.SVMXC__SM_User__c, true);
         }
         return userMap;
    }
    
    //New Method for removing duplicate field entry from the list - this takes list of fields and returns list of fields - 043715
    public List<String> checkDuplicateFields(List<String> lstFields, String strObjName){
        Set<String> setOfManagedFieldWithoutNamespace = new Set<String>();
        List<String> resultListOfField = new List<String>();

            for(String field : lstFields) {
                if(field.startsWithIgnoreCase('SVMXC__')) {
                    setOfManagedFieldWithoutNamespace.add(field.removeStartIgnoreCase('SVMXC__').toUpperCase()); //Added toUpperCase method for addressing issue 045513
                } 
            }
        
            for(String field : lstFields) {
                if(!setOfManagedFieldWithoutNamespace.contains(field.toUpperCase())){ //Added toUpperCase method for addressing issue 045513
                    resultListOfField.add(field);
                }
                else{
                    if(mapObjectNameAndListOfDupFields != null && !mapObjectNameAndListOfDupFields.containsKey(strObjName))
                        mapObjectNameAndListOfDupFields.put(strObjName, new Set<String>());
                    mapObjectNameAndListOfDupFields.get(strObjName).add(field);
                }
            }
            mapObjectNameAndProcessedFields.put(strObjName, resultListOfField);
            return resultListOfField;
    }

    //New Method for removing duplicate field entry from the list - this takes set of fields and returns set of fields - 043715
    public Set<String> checkDuplicateFields(Set<String> lstFields, String strObjName){
        Set<String> setOfManagedFieldWithoutNamespace = new Set<String>();
        Set<String> resultListOfField = new Set<String>();
       
            for(String field : lstFields) {
                if(field.startsWithIgnoreCase('SVMXC__')){
                    setOfManagedFieldWithoutNamespace.add(field.removeStartIgnoreCase('SVMXC__').toUpperCase()); //Added toUpperCase method for addressing issue 045513
                  } 
            }
        
            for(String field : lstFields) {
                if(!setOfManagedFieldWithoutNamespace.contains(field.toUpperCase())){ //Added toUpperCase method for addressing issue 045513
                    resultListOfField.add(field);
                }
                else{
                    if(mapObjectNameAndListOfDupFields != null && !mapObjectNameAndListOfDupFields.containsKey(strObjName))
                        mapObjectNameAndListOfDupFields.put(strObjName, new Set<String>());
                    mapObjectNameAndListOfDupFields.get(strObjName).add(field);
                }
            }
            mapObjectNameAndProcessedFieldsSet.put(strObjName, resultListOfField);
            return resultListOfField;
    }
    
    //New Method for removing duplicate field entry from the fieldMap - 043715 - BAC-4401
    public Map<String,Schema.SObjectField> removeDuplicateFields(Map<String,Schema.SObjectField> fieldMap){
      Set<String> setOfManagedFieldWithoutNamespace = new Set<String>();
      Map<String,Schema.SObjectField> mapResultFieldMap = new Map<String,Schema.SObjectField>();
      
      if(fieldMap != null && fieldMap.size() > 0){
        mapResultFieldMap = fieldMap.clone();
        for(String field : fieldMap.keyset()) {
              if(field.startsWithIgnoreCase('SVMXC__')){
                  setOfManagedFieldWithoutNamespace.add(field.removeStartIgnoreCase('SVMXC__').toUpperCase()); //Added toUpperCase method for addressing issue 045513
              }
          }
          System.debug('setOfManagedFieldWithoutNamespace: '+setOfManagedFieldWithoutNamespace);
      
          for(String field : fieldMap.keyset()) {
            if(setOfManagedFieldWithoutNamespace.contains(field.toUpperCase())){ //Added toUpperCase method for addressing issue 045513
                  mapResultFieldMap.remove(field);
              }
          }
      }
        return mapResultFieldMap;
    }
    
    // BAC-4624 - New method for auit trial entry
    public void processServicemaxConfiguration(String entityName,String application,String actionType,String action) {
        try{
            SVMXC__Config_Change_Detail__c configurationData = new SVMXC__Config_Change_Detail__c();
            configurationData.SVMXC__Entity_Name__c = entityName;
            configurationData.SVMXC__Application__c = application;
            configurationData.SVMXC__Action_Type__c = actionType;
            if(action.length() > 255){
                configurationData.SVMXC__Additional_information__c = action;
                configurationData.SVMXC__Action__c = 'Check additional information for details';
            }
            else{
                configurationData.SVMXC__Action__c = action;
            }
            configurationData.SVMXC__User__c = userInfo.getUserId();
            configurationData.SVMXC__Date__c = DateTime.now();
            if(COMM_SecurityUtils.getInstance().verifyFieldAccess(configurationData, COMM_SecurityUtils.Access.Createable)){
                insert configurationData; //SDL-SVMX-CREATE-UPDATE-FLS-ENFORCED
            }
            else{
                throw new COMM_SecurityUtils.SecurityAccessException(System.label.COMM001_TAG142);
            }
        }
        catch(Exception ex){
            System.debug(LoggingLevel.Warn,' log in catch : '+ex.getMessage() );
        }
    }
}