public with sharing class COMM_ValidateAddress{

    public SObject currentRecord;
    
    public String strLongitudeFieldName;
    public String strLatitudeFieldName;
    //DNS-572
    public String strHomeLongitudeFieldName;
    public String strHomeLatitudeFieldName;
    
    public String strAddress{get;set;}
    public String strReturnURL{get;set;}
    public String strGoogleUrl{get;set;}
    public String strResultMessage{get;set;}
    public string strDisplayImage{get;set;}
    public String strLatitude{get;set;}
    public String strLongitude{get;set;}
    
    public boolean isValidated{get;set;}
    public boolean isSuccess{get;set;}

    public boolean GBL005IsTrue{get;set;}
    
    public String getTAG001() {return System.Label.COMM001_TAG001;}//Error in validating address.
    public String getTAG002() {return System.Label.COMM001_TAG002;}//Please wait. Calculating Address Coordinates..
    public String getTAG003() {return System.Label.COMM001_TAG003;}//Google GeoCoder returned an error while processing your request. Please try this operation again. If the problem persists, contact your ServiceMax administrator with the following error
    public String getTAG004() {return System.Label.COMM001_TAG004;}//The address field is currently blank. Please enter a valid address and retry.
    public String getTAG011() {return System.Label.COMM001_TAG011;}//Address validated successfully.
    public String getTAG143() {return System.Label.COMM001_TAG143;}//GBL005 setting is false(Validate Address Feature not enabled).

    public COMM_ValidateAddress(){
        
        isSuccess = isValidated = false;
        strAddress = strReturnURL =  strGoogleUrl = strResultMessage = strDisplayImage = strLatitude = strLongitude ='';
        GBL005IsTrue = true;

        Map<String, String> mapParameters = System.currentPageReference().getParameters();
        SVMXC.COMM_Utils_ManageSettings commSettings = new SVMXC.COMM_Utils_ManageSettings();

        String strSettingGBL005 = 'False';
        //String strSettingGBL011 = 'gme-servicemaxinc';//Commented for BAC-6155
        //String strSettingGBL001 = 'AIzaSyCvPsxvCDUDZ7Aluu_gExTTOnDxh-QOi4Q'; //For Backoffice purpose.
        String strSettingGBL001 = ''; //For Backoffice purpose.
        String strRecordID = mapParameters.get('objID');
        String strObjectName = mapParameters.get('objName');
        
        strReturnURL = mapParameters.get('returnUrl');
        strLongitudeFieldName = mapParameters.get('longitude');
        strLatitudeFieldName = mapParameters.get('latitude');
        //DNS-572: Introduced new 'Home lat/lng' fields for Technician object
        strHomeLongitudeFieldName = mapParameters.get('homelongitude');
        strHomeLatitudeFieldName = mapParameters.get('homelatitude');

        Map<String, String> lstSVMXSetting = commSettings.SVMX_getSettingList('COMM001');
        if(lstSVMXSetting != null && lstSVMXSetting.size() >0){
            
            if(lstSVMXSetting.containsKey('GBL005')){
                strSettingGBL005 = lstSVMXSetting.get('GBL005');
            }
            /* Commented for BAC-6155
            if(lstSVMXSetting.containsKey('GBL011')){
                strSettingGBL011 = lstSVMXSetting.get('GBL011');
            }
            if(lstSVMXSetting.containsKey('GBL001')){
                strSettingGBL001 = lstSVMXSetting.get('GBL001');
            }*/
        }
        //Get it from ServiceMax properties Config Setting // Added for BAC-6155
        SVMXC__ServiceMax_Properties__c objProperties = SVMXC__ServiceMax_Properties__c.getValues('MAPS_API_KEY_CORE');
        if (objProperties != null && objProperties.SVMXC__Value__c != null) {
            strSettingGBL001 = objProperties.SVMXC__Value__c;
        }  
        //
        if(strSettingGBL005 != null && strSettingGBL005.toUppercase() == 'FALSE') {
            GBL005IsTrue = false;
        }
        
        if(strSettingGBL005 != null && strSettingGBL005.toUppercase() == 'TRUE'){
            
            strResultMessage = getTAG002();
            COMM_SVMXC_Utils2  objUtils2 = new COMM_SVMXC_Utils2();
            
            if(strReturnURL != null && strReturnURL.length() > 0){
                strReturnURL = '/'+strReturnURL;
            }
            else if(strRecordID != null && strRecordID.length() > 0){
                strReturnURL = '/'+strRecordID;
            }
            strReturnURL = objUtils2.GetCommunityPrefix(strReturnURL);
            
            //strGoogleUrl = 'https://maps.googleapis.com/maps/api/js?sensor=false&client='; Commented for BAC-6155
            strGoogleUrl = 'https://maps.googleapis.com/maps/api/js?key='; //Added for BAC-6155
            /* Commented for BAC-6155
            if(strSettingGBL011 != null && strSettingGBL011.length() > 0){
                strGoogleUrl += strSettingGBL011;
            }               
            else */if(strSettingGBL001 != null && strSettingGBL001.length() > 0){
                strGoogleUrl += strSettingGBL001; 
            }
            System.debug('strGoogleUrl '+strGoogleUrl);
            if(strObjectName != null && strObjectName.length() > 0 && strRecordID != null && strRecordID.length() > 0){
                
                boolean isValidObject = false;
                for(Schema.SObjectType sObjectType : Schema.getGlobalDescribe().values()){
                
                    if(strObjectName == sObjectType.getDescribe().getName()){
                        isValidObject = true;
                    }
                }
                
                if(isValidObject){
            
                    String strStreetFieldName = mapParameters.get('street');
                    String strCityFieldName = mapParameters.get('city');
                    String strStateFieldName = mapParameters.get('state');
                    String strCountryFieldName = mapParameters.get('country');
                    String strZipFieldName = mapParameters.get('zip');
                    
                    string strQuery = 'SELECT id';
                    if(isValidField(strStreetFieldName)){
                        strQuery +=  ',' + strStreetFieldName ;
                    }
                    if(isValidField(strCityFieldName)){
                        strQuery +=  ',' + strCityFieldName ;
                    }
                    if(isValidField(strStateFieldName)){
                        strQuery +=  ',' + strStateFieldName ;
                    }
                    if(isValidField(strCountryFieldName)){
                        strQuery +=  ',' + strCountryFieldName ;
                    }
                    if(isValidField(strZipFieldName)){
                        strQuery +=  ',' + strZipFieldName ;
                    }
                    strQuery +=' FROM ' + strObjectName +  ' WHERE id =:strRecordID  limit 1';

                    try{
                        List<SObject> lstRecord = Database.query(strQuery);
                        if(lstRecord != null && lstRecord.size() > 0){
                        
                            currentRecord = lstRecord[0]; 
                            if(isValidField(strStreetFieldName)){
                            
                                Pattern pat = Pattern.compile('(\n|\r|\r\n)+');
                                strAddress += pat.matcher(checkNull(String.valueOf(currentRecord.get(strStreetFieldName)))).replaceAll(',');  
                            }
                            if(isValidField(strCityFieldName)){
                                strAddress += checkNull(String.valueOf(currentRecord.get(strCityFieldName)));
                            }
                            if(isValidField(strStateFieldName)){
                                strAddress += checkNull(String.valueOf(currentRecord.get(strStateFieldName)));
                            }
                            if(isValidField(strCountryFieldName)){
                                strAddress += checkNull(String.valueOf(currentRecord.get(strCountryFieldName)));
                            }
                            if(isValidField(strZipFieldName)){
                                strAddress += checkNull(String.valueOf(currentRecord.get(strZipFieldName)));
                            }
                        }
                    }
                    catch(exception ex){
                        System.debug( LoggingLevel.ERROR, ex.getMessage() );
                        System.debug( LoggingLevel.ERROR, ex.getStackTraceString() );
                        apexpages.addmessage(new apexpages.message(ApexPages.severity.ERROR, ex.getMessage()));
                    }
                }
            }
        }
    }   
    
    private boolean isValidField(String strParam){
        
        if(strParam != null && strParam.length() > 0){
            return true;
        }
        return false;
    }
    
    private String checkNull(String strParam){
        
        if(strParam != null && strParam.length() > 0){
            return strParam + ',';
        }
        return '';
    }
    
    public void doUpdateLatLong(){
        
        strGoogleUrl = '';
        strDisplayImage = 'none';
        isValidated = true;
        isSuccess = false;
        
        try{
            if(strLongitude != null && strLatitude != null && 
                (double.valueOf(strLongitude) != 0 || double.valueOf(strLatitude) != 0)){
            
                currentRecord.put(strLatitudeFieldName, double.valueOf(strLatitude));
                currentRecord.put(strLongitudeFieldName, double.valueOf(strLongitude));
                //DNS-572: If not technician object, then do not update 'home lat/lng' fields
                if(strHomeLatitudeFieldName != NULL){
                    currentRecord.put(strHomeLatitudeFieldName, double.valueOf(strLatitude));
                }
                if(strHomeLongitudeFieldName != NULL){
                    currentRecord.put(strHomeLongitudeFieldName, double.valueOf(strLongitude));
                }
                
                //update currentRecord;
                if(COMM_SecurityUtils.getInstance().verifyFieldAccess(currentRecord, COMM_SecurityUtils.Access.Updateable)){
                    update currentRecord; //SDL-SVMX-CREATE-UPDATE-FLS-ENFORCED
                } else {
                    throw new COMM_SecurityUtils.SecurityAccessException( System.Label.COMM001_TAG142 );
                }
                
                isSuccess = true;
                strResultMessage = getTAG011();
            }
        }
        catch(exception ex){
            System.debug( LoggingLevel.ERROR, ex.getMessage() );
            System.debug( LoggingLevel.ERROR, ex.getStackTraceString() );
            apexpages.addmessage(new apexpages.message(ApexPages.severity.ERROR, ex.getMessage()));
        }
    }
    
    public void doClearLatLong(){
    
        strGoogleUrl = '';
        strDisplayImage = 'none';
        isValidated = true;
        isSuccess = false;
        
        if( currentRecord == null ) {
            apexpages.addmessage(new apexpages.message(ApexPages.severity.ERROR, strResultMessage = getTAG001() + '\n\n' + strResultMessage ) );
            return;
        }

        try{
            currentRecord.put(strLongitudeFieldName, null);
            currentRecord.put(strLatitudeFieldName, null);
            //DNS-572: If not technician object, then do not update 'home lat/lng' fields 
            if(strHomeLatitudeFieldName != NULL){
                currentRecord.put(strHomeLatitudeFieldName, null);
            }
            if(strHomeLongitudeFieldName != NULL){
                currentRecord.put(strHomeLongitudeFieldName, null);
            }

            //update currentRecord;
            if(COMM_SecurityUtils.getInstance().verifyFieldAccess(currentRecord, COMM_SecurityUtils.Access.Updateable)){
                update currentRecord; //SDL-SVMX-CREATE-UPDATE-FLS-ENFORCED
            } else {
                throw new COMM_SecurityUtils.SecurityAccessException( System.Label.COMM001_TAG142 );
            }           
            strResultMessage = getTAG001() + '\n\n' + strResultMessage;
            
        }
        catch(exception ex){
            System.debug( LoggingLevel.ERROR, ex.getMessage() );
            System.debug( LoggingLevel.ERROR, ex.getStackTraceString() );
            apexpages.addmessage(new apexpages.message(ApexPages.severity.ERROR, ex.getMessage()));
        }
    }
}