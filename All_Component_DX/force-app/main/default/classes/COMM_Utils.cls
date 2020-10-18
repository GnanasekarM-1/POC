/**
*******************************************************************************************
 *    ID        Name                   Date            Comment
 ********************************************************************************************
 *              Jaysukh patel        26 Dec 2019        modified method SVMX_getDefaultPicklistValue
 ***************************************************************************************************
**/
global with sharing class COMM_Utils {
    
   //CRUD security related functions
    //public static COMM_SecurityUtils securityUtils = COMM_SecurityUtils.getInstance(); //Commented for code optimization BAC-2993
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
        String ObjName = objT.getDescribe().getName();
        Boolean IsCustomObject = objT.getDescribe().isCustom();
        Boolean IsCustomObjectsetting = objT.getDescribe().isCustomSetting(); //Added for 047736 
        if(ObjName.endsWith('Feed') || ObjName.endsWith('Tag') || ObjName.endsWith('History') || ObjName.endsWith('Share') || ObjName.endsWithIgnoreCase('mdt') || IsCustomObjectsetting) continue; //Added for 047736 remove metadata type and Custom Settings
        //system.debug('zzzzzzzzz1'+perStdObjMap);
        if(IsCustomObject && !(MapInternalObjectNamesLst != null && (MapInternalObjectNamesLst.containsKey(ObjName))))
        {
            QualifiedInternalObjectLst.put(ObjName, objT.getDescribe().getLabel());
        }
        else if(!(IsCustomObject))
        {
            if( ((MapInternalObjectNamesLst!= null && !(MapInternalObjectNamesLst.containsKey(ObjName))) || (MapInternalObjectNamesLst == null) ) && (perStdObjMap.containsKey(ObjName)) )
            {
                    QualifiedInternalObjectLst.put(ObjName, objT.getDescribe().getLabel());
            }
        }
        }
        //system.debug('zzzzzzzzz2'+perStdObjMap);
        for(String str :QualifiedInternalObjectLst.keyset()){
            //system.debug('zzzzzzzzz3'+str);
        }
        return QualifiedInternalObjectLst;
    }

    //Account a = new Account (CreatedDate=system.today(), name = 'A');
    
  // Returns if it's Enterprise License or Not
  public Boolean SVMX_updateLicenseType(String varACK3, String licenseType, String varACK2){
    Boolean retBoolean = false;
    
    if((varACK2 != null) && (varACK2.length() > 0)){
        try {
            Blob blob1 =  EncodingUtil.base64Decode(varACK2);
            if( !((blob1.toString()).equals('VGhhdHpXaGF0U2hlU2FpZA==')) ) return false;
        }catch(Exception ex) {
             return false;
        }
    } 
        
    List<SVMXC__ServiceMax_Properties__c> sprop = new List<SVMXC__ServiceMax_Properties__c>();
    sprop = [Select Id, Name, SVMXC__Key__c, SVMXC__Value__c from SVMXC__ServiceMax_Properties__c where SVMXC__Key__c = 'License Type' and Name = 'PROP001' Limit 1]; //SDL-SVMX-FLS-NOT-ENFORCED-META-DATA
    //Get the LicenseType by decrupting varACK3
    String deCruptedLicenseType = SVMX_decruptLicenseKey(varACK3);
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
        String strAction = '', strSVMXPropertyKey = '', strSVMXPropertyName = '', strSVMXPropertyValue = '', strSVMXPropertyId = '';
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
                }else if(currReq.name == 'Id')
                {
                    strSVMXPropertyId = currReq.value;
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
                    lstResponse.add(new COMM_Webservices.KeyValue('Id',lstSVMXProperty[0].Id));
                    lstResponse.add(new COMM_Webservices.KeyValue('Name',lstSVMXProperty[0].Name));
                    lstResponse.add(new COMM_Webservices.KeyValue('Key',lstSVMXProperty[0].SVMXC__Key__c));
                    lstResponse.add(new COMM_Webservices.KeyValue('Value',lstSVMXProperty[0].SVMXC__Value__c));
                    lstResponse.add(new COMM_Webservices.KeyValue('RECORDS',lstSVMXProperty.size() + ''));
                }else
                {
                    lstResponse.add(new COMM_Webservices.KeyValue('RECORDS','0'));
                }
            }
            else if(strAction != null && strAction.length() > 0 && strAction == 'UPDATE' && String.isNotBlank(strSVMXPropertyId) && String.isNotBlank(strSVMXPropertyValue)){
                //TOOL-2466 Update of ServiceMax Properties
                SVMXC__ServiceMax_Properties__c sp = new SVMXC__ServiceMax_Properties__c();
                sp.Id = strSVMXPropertyId;
                sp.SVMXC__Value__c = strSVMXPropertyValue;
                if(COMM_SecurityUtils.getInstance().verifyFieldAccess(sp, COMM_SecurityUtils.Access.Updateable)){
                    update sp; //SDL-SVMX-CREATE-UPDATE-FLS-ENFORCED
                }
                else{
                    throw new COMM_SecurityUtils.SecurityAccessException(System.label.COMM001_TAG142);
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
        List<SVMXC__ServiceMax_Properties__c> lstProps = [Select Id,Name,SVMXC__Key__c,SVMXC__Value__c from SVMXC__ServiceMax_Properties__c where SVMXC__Key__c =: key limit 1]; //SDL-SVMX-FLS-NOT-ENFORCED-META-DATA
        return lstProps;
    }
  
  
  public String SVMX_decruptLicenseKey(String varACK3){
    //Decrupt the varACK3 and return the LicenseType
    //Add code here to decrupt key
        Blob varACK1=EncodingUtil.base64Decode('Mm83T09S42nMo70pM5yBbA3EDQX5C4g8EUiX7QN76WQ=');
        String retStr = '';
        String OrgID;
        String licType;
        String DecStr = Crypto.decryptWithManagedIV('AES256', varACK1, EncodingUtil.base64Decode(varACK3)).toString();
        //Blob blob1 =  EncodingUtil.base64Decode(varACK3);                 
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
            String strvarACK2 = null;
            if(reqPropertyElements.name == 'DevKey')
                strvarACK2 = reqPropertyElements.value;
            if(strvarACK2 == null || !strvarACK2.equals('VGhhdHpXaGF0U2hlU2FpZA==')) return objResponse;
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
  
  public Boolean SVMX_updatePropertyElements(List<SVMXC__ServiceMax_Property_Elements__c> propEleLst, String varACK3, String licenseType,String varACK2){
    //Write logic to upsert the property elements
    if((varACK2 != null) && (varACK2.length() > 0)){
        try {
            Blob blob1 =  EncodingUtil.base64Decode(varACK2);
            if( !((blob1.toString()).equals('VGhhdHpXaGF0U2hlU2FpZA==')) ) return false;
        } catch(Exception ex) {
             return false;
        }
    } 
    
    try{
        String deCruptedLicenseType = SVMX_decruptLicenseKey(varACK3);
        if(licenseType != deCruptedLicenseType) return false;
        Set<String> propertyName = new Set<String>();
        List<SVMXC__ServiceMax_Property_Elements__c> upsertProperty = new List<SVMXC__ServiceMax_Property_Elements__c>();
        List<SVMXC__ServiceMax_Property_Elements__c> existingProperty = new List<SVMXC__ServiceMax_Property_Elements__c>();
        Map<String, SVMXC__ServiceMax_Property_Elements__c> propertyMap = new Map<String, SVMXC__ServiceMax_Property_Elements__c>();
        existingProperty = [Select Name, SVMXC__Property_Key__c, SVMXC__Element_Type__c, SVMXC__Element_Value__c from SVMXC__ServiceMax_Property_Elements__c where name like 'PELE%']; //SDL-SVMX-FLS-NOT-ENFORCED-META-DATA
        delete existingProperty; //SDL-SVMX-DELETE-FLS-ENFORCED
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
    global Map<String,String> SVMX_getDefaultPicklistValue(String ObjName, List<String> FieldName)
    {
    
        Map<String,String> mapofDefaulPickList = new Map<String,String>();
        mapofDefaulPickList = COMM_Utils_DescribeCall.getInstance().getDefaultPicklistValue(objName,fieldName);
        
        //old start
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
        return String.escapeSingleQuotes(fieldNames); //#soqlInjectionFix
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
                try {
                    if( oExpression.get('SVMXC__Field_Relationship_Name__c') != null && oExpression.get('SVMXC__FKey_Name_Field__c') != null ) {
                        referenceValue = (String) Rec.getSObject(oExpression.SVMXC__Field_Relationship_Name__c).get(oExpression.SVMXC__FKey_Name_Field__c);
                    }
                }
                catch( Exception ex ) {                    
                }  

                if(FieldType != null && FieldType.length() > 0 && oExpression.SVMXC__Operator__c != null && oExpression.SVMXC__Operator__c.length() > 0)
                {
                    string strOperater = oExpression.SVMXC__Operator__c.ToUpperCase();
                    
                    string strFieldType = FieldType.ToUpperCase();
                    if(strFieldType == 'STRING' || strFieldType == 'COMBOBOX' || strFieldType == 'PICKLIST' || strFieldType == 'PHONE' || strFieldType == 'URL' || strFieldType == 'TEXTAREA')
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
                            if(Val == oExpression.SVMXC__Operand__c)
                                mapResult.put(oExpression.SVMXC__Sequence__c,'T');
                        }
                        else if(strOperater == 'NE')
                        {
                            if(Val != oExpression.SVMXC__Operand__c)
                                mapResult.put(oExpression.SVMXC__Sequence__c,'T');
                        }
                        else if(strOperater == 'STARTS' )
                        {
                            if(Val != null)
                            {
                                if(Val.startsWith(oExpression.SVMXC__Operand__c))
                                    mapResult.put(oExpression.SVMXC__Sequence__c,'T');
                            }
                        }
                        else if(strOperater == 'CONTAINS')
                        {
                            if(Val != null)
                            {
                                if(Val.contains(oExpression.SVMXC__Operand__c))
                                    mapResult.put(oExpression.SVMXC__Sequence__c,'T');
                            }
                        }
                        else if(strOperater == 'NOTCONTAINS')
                        {
                            if(Val != null)
                            {
                                if(!Val.contains(oExpression.SVMXC__Operand__c))
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
                            if(setValues.contains(Val) && strOperater == 'IN')
                                mapResult.put(oExpression.SVMXC__Sequence__c,'T');
                            if(!setValues.contains(Val) && strOperater == 'NOTIN')
                                mapResult.put(oExpression.SVMXC__Sequence__c,'T');
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
                            if(Val == Integer.valueOf(oExpression.SVMXC__Operand__c))
                                mapResult.put(oExpression.SVMXC__Sequence__c,'T');
                        }
                        else if(strOperater == 'NE')
                        {
                            if(Val != Integer.valueOf(oExpression.SVMXC__Operand__c))
                                mapResult.put(oExpression.SVMXC__Sequence__c,'T');
                        }
                        else if(strOperater == 'LT')
                        {
                            if(Val < Integer.valueOf(oExpression.SVMXC__Operand__c))
                                mapResult.put(oExpression.SVMXC__Sequence__c,'T');
                        }
                        else if(strOperater == 'GT')
                        {
                            if(Val > Integer.valueOf(oExpression.SVMXC__Operand__c))
                                mapResult.put(oExpression.SVMXC__Sequence__c,'T');
                        }
                        else if(strOperater == 'LE')
                        {
                            if(Val <= Integer.valueOf(oExpression.SVMXC__Operand__c))
                                mapResult.put(oExpression.SVMXC__Sequence__c,'T');
                        }
                        else if(strOperater == 'GE')
                        {
                            if(Val >= Integer.valueOf(oExpression.SVMXC__Operand__c))
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
                            if(Val == DECIMAL.valueOf(oExpression.SVMXC__Operand__c))
                                mapResult.put(oExpression.SVMXC__Sequence__c,'T');
                        }
                        else if(strOperater == 'NE')
                        {
                            if(Val != DECIMAL.valueOf(oExpression.SVMXC__Operand__c))
                                mapResult.put(oExpression.SVMXC__Sequence__c,'T');
                        }
                        else if(strOperater == 'LT')
                        {
                            if(Val < DECIMAL.valueOf(oExpression.SVMXC__Operand__c))
                                mapResult.put(oExpression.SVMXC__Sequence__c,'T');
                        }
                        else if(strOperater == 'GT')
                        {
                            if(Val > DECIMAL.valueOf(oExpression.SVMXC__Operand__c))
                                mapResult.put(oExpression.SVMXC__Sequence__c,'T');
                        }
                        else if(strOperater == 'LE')
                        {
                            if(Val <= DECIMAL.valueOf(oExpression.SVMXC__Operand__c))
                                mapResult.put(oExpression.SVMXC__Sequence__c,'T');
                        }
                        else if(strOperater == 'GE')
                        {
                            if(Val >= DECIMAL.valueOf(oExpression.SVMXC__Operand__c))
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
                    else if(strFieldType == 'DOUBLE')
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
                            if(Val == DOUBLE.valueOf(oExpression.SVMXC__Operand__c))
                                mapResult.put(oExpression.SVMXC__Sequence__c,'T');
                        }
                        else if(strOperater == 'NE')
                        {
                            if(Val != DOUBLE.valueOf(oExpression.SVMXC__Operand__c))
                                mapResult.put(oExpression.SVMXC__Sequence__c,'T');
                        }
                        else if(strOperater == 'LT')
                        {
                            if(Val < DOUBLE.valueOf(oExpression.SVMXC__Operand__c))
                                mapResult.put(oExpression.SVMXC__Sequence__c,'T');
                        }
                        else if(strOperater == 'GT')
                        {
                            if(Val > DOUBLE.valueOf(oExpression.SVMXC__Operand__c))
                                mapResult.put(oExpression.SVMXC__Sequence__c,'T');
                        }
                        else if(strOperater == 'LE')
                        {
                            if(Val <= DOUBLE.valueOf(oExpression.SVMXC__Operand__c))
                                mapResult.put(oExpression.SVMXC__Sequence__c,'T');
                        }
                        else if(strOperater == 'GE')
                        {
                            if(Val >= DOUBLE.valueOf(oExpression.SVMXC__Operand__c))
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
                            System.debug(LoggingLevel.INFO, 'referenceValue : ' + referenceValue  + 'oExpression : ' + oExpression.SVMXC__Operand__c);
                            if( referenceValue != null ) { 
                                if( referenceValue == oExpression.SVMXC__Operand__c ) {
                                    mapResult.put(oExpression.SVMXC__Sequence__c,'T');
                                }
                            } else if(Val == (Id)oExpression.SVMXC__Operand__c)
                                mapResult.put(oExpression.SVMXC__Sequence__c,'T');                            

                        }
                        else if(strOperater == 'NE')
                        {
                            if( referenceValue != null ) {
                                if( referenceValue != oExpression.SVMXC__Operand__c ) {
                                    mapResult.put(oExpression.SVMXC__Sequence__c,'T');
                                }
                            } else if(Val != (Id)oExpression.SVMXC__Operand__c)
                                mapResult.put(oExpression.SVMXC__Sequence__c,'T');
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
                        system.debug(LoggingLevel.WARN, 'Field val = ' + val);
                        if(strOperater == 'EQ')
                        {
                            if(Val == (object)getDateTime(oExpression.SVMXC__Operand__c))
                                mapResult.put(oExpression.SVMXC__Sequence__c,'T');
                        }
                        else if(strOperater == 'NE')
                        {
                            if(Val != (object)getDateTime(oExpression.SVMXC__Operand__c))
                                mapResult.put(oExpression.SVMXC__Sequence__c,'T');
                        }
                        else if(strOperater == 'IN' || strOperater == 'NOTIN')
                        {
                            String[] multValues = oExpression.SVMXC__Operand__c.split(',');
                            set<object> setValues = new set<object>();
                            if(multValues != null)
                            {
                                for(string str: multValues)
                                {
                                    setValues.add((object)getDateTime(str));
                                }
                            }
                            if(setValues.contains(Val) && strOperater == 'IN')
                                mapResult.put(oExpression.SVMXC__Sequence__c,'T');
                            if(!setValues.contains(Val) && strOperater == 'NOTIN')
                                mapResult.put(oExpression.SVMXC__Sequence__c,'T');
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
            for(integer k = 0; k < lstExpressions.size(); k++)
            {
                AdvExp = AdvExp.replace(string.valueOf(k+1),' ~' + string.valueOf(k+1) + '~ ');
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
        private Date getDate(String str)
        {
            try
            {
                if(str != null && (str.toUpperCase() == 'TODAY' || str.toUpperCase() == 'SVMX.NOW'))
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
                    return Date.parse(str);
            }
            catch(exception ex)
            {
                ApexPages.AddMessage(new ApexPages.Message(ApexPages.Severity.ERROR, ex.getMessage()));
                return null;
            }
        }
        private DateTime getDateTime(String str)
        {
            try
            {
                if(str != null && str.toUpperCase() == 'SVMX.NOW')
                    return DateTime.now();
                else if(str != null && str.toUpperCase() == 'TODAY' )
                    return Datetime.newInstance(Date.today(), time.newInstance(0, 0, 0, 0));
                else if(str != null && str.toUpperCase() == 'TOMORROW')
                    return Datetime.newInstance(Date.today().addDays(1), time.newInstance(0, 0, 0, 0));
                else if(str != null && str.toUpperCase() == 'YESTERDAY')
                    return Datetime.newInstance(Date.today().addDays(-1), time.newInstance(0, 0, 0, 0));
                else if(str != null && str.toUpperCase().contains('NEXT_N_DAYS:'))
                    return Datetime.newInstance(Date.today().addDays(Integer.ValueOf(str.toUpperCase().split(':')[1])), time.newInstance(0, 0, 0, 0));
                else if(str != null && str.toUpperCase().contains('LAST_N_DAYS:'))
                    return Datetime.newInstance(Date.today().addDays(-1 * Integer.ValueOf(str.toUpperCase().split(':')[1])), time.newInstance(0, 0, 0, 0));
                else
                    return Datetime.parse(str.replace('/','-'));
            }
            catch(exception ex)
            {
                ApexPages.AddMessage(new ApexPages.Message(ApexPages.Severity.ERROR, ex.getMessage()));
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
                Map<String, Schema.SObjectType> allObjs = COMM_Utils_DescribeCall.getInstance().getGlobalDescribeCall();
                //Map<String, Schema.SObjectType> allObjs = Schema.getGlobalDescribe();
    
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
     public String DCON_getFieldNamesFromList(List<String> fieldList,List<String> pickList_L) {
        String fieldNames = '';
        for (String field : fieldList) {
            if (fieldNames.length()>0) {
                fieldNames += ',';
            }
            if(pickList_L.contains(field)){
                fieldNames += 'toLabel('+field+')';
            }
            else {
                fieldNames += field;
            }
           
        }        
        return fieldNames;
    } 
}