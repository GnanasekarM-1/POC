public with sharing class OPDOC_DocumentViewer {
    public String strRecordName{get;set;}
    public String strRecordURL{get;set;}
    public Boolean salesforceFileGlobalValue{get;set;} // Added for BAC-2197
    public OPDOC_DocumentViewer() {
       salesforceFileGlobalValue = false;
        salesforceFileGlobalValue = COMM_FileHandlerUtilities.checkFileSetting(); // Added for BAC-2197
        
        String strRecordId = ApexPages.currentPage().getParameters().get('SVMX_RecId');        
        getRecordName(strRecordId);
    }
    
    private void getRecordName(String strRecordId){
        
        String strNamedField;
        String strObjName;
        if(strRecordId != null && strRecordId != '')
        {
            strRecordURL = '/'+strRecordId ;
            String ObjectKeyPrefix =  strRecordId.subString(0, 3);
            Map<String, Schema.SObjectType> allObjs = Schema.getGlobalDescribe();
            for(String Obj : allObjs.keySet())
            {
                Schema.DescribeSObjectResult R = allObjs.get(Obj).getDescribe();
                if(R.getKeyPrefix() != null && R.getKeyPrefix().equals(ObjectKeyPrefix))
                {
                    strObjName = R.getName();
                    for(String fld : R.fields.getMap().keySet())
                    {
                        if(R.fields.getMap().get(fld).getDescribe().isNameField())
                        {
                            strNamedField = R.fields.getMap().get(fld).getDescribe().getName();
                            break;
                        }
                    }
                    break;
                }
            }
            
            if(strNamedField != null && strNamedField.length() > 0 && strObjName!= null && strObjName.length() > 0)
            {
                String SOQLStr = 'select '+ strNamedField + ' from ' + strObjName + ' where ' + 'id =\'' + String.escapeSingleQuotes(strRecordId) + '\'';
                sObject ObjRec = database.query(SOQLStr);
                if(((String)ObjRec.get(strNamedField)) != null && ((String)ObjRec.get(strNamedField)).length() > 0)
                    strRecordName = (String)ObjRec.get(strNamedField);
            }
        }
    }
    
    public String getDocumentURL() {
        Id idAtt = ApexPages.currentPage().getParameters().get('SVMX_AttID');
        String sitePrefix  = getSitePrefix();
        if(sitePrefix != null && sitePrefix.length() > 0){
            sitePrefix  = sitePrefix;
        }else{
            sitePrefix  = '';
        }
        if(salesforceFileGlobalValue && idAtt != null){
             return sitePrefix + '/sfc/servlet.shepherd/version/download/' + idAtt;
        }else{
            return sitePrefix + '/servlet/servlet.FileDownload?file=' + idAtt;
        }
    }
    
    private String getSitePrefix(){
        //String sitePrefix = Site.getPrefix();
        String sitePrefix = Site.getPathPrefix();
        return sitePrefix ;
    }
    
    public PageReference deleteAttachment() {
        
        Id idAtt = ApexPages.currentPage().getParameters().get('SVMX_AttID');
        if( COMM_SecurityUtils.getInstance().isDeletableObject( 'Attachment' ) ) {            
            delete [Select Id from Attachment where id =: idAtt];
        } else {
            throw new COMM_SecurityUtils.SecurityAccessException( System.Label.COMM001_TAG142 );
        }
        
        // Added for salesforce file--BAC-2197
        
        if(salesforceFileGlobalValue && idAtt !=null){
            ContentVersion cvDetails = COMM_FileHandlerUtilities.getContentVersionDetails(String.valueOf(idAtt));
            if(cvDetails != null && cvDetails.ContentDocumentId != null){
                ContentDocument cdId = new ContentDocument();
                cdId.id = cvDetails.ContentDocumentId;
                System.debug('ContentDocument that going to be delete '+cdId);
                //delete the old salesforce file
                if( COMM_SecurityUtils.getInstance().isDeletableObject( 'ContentDocument' ) ) {
                    delete cdId;
                } else {
                    throw new COMM_SecurityUtils.SecurityAccessException( System.Label.COMM001_TAG142 );
                }
                
            }
        }
        //End --BAC-2197
        
        if(strRecordURL != null && strRecordURL.length() > 0)
        {  
                // start SFD-1790
                String sitePrefix  = getSitePrefix();
                if(String.isEmpty(sitePrefix)){
                    sitePrefix = '';
                }
                // end SFD-1790
          String baseURL = URL.getSalesforceBaseUrl().toExternalForm(); //Added for the Security fixes
            //PageReference ReturnObject = new PageReference(strRecordURL); //Commented for the Security fixes
            PageReference ReturnObject = new PageReference(baseURL +sitePrefix+strRecordURL);
            ReturnObject.setRedirect(true);
            return ReturnObject;
        }
        return null;
    }
    public String getTAG001(){return System.Label.SFM004_TAG001+' ';}//'Output Document generated for record: '
    public String getTAG002(){return System.Label.SFM004_TAG002+' '+strRecordName;}//'Output Document: '
    public String getTAG003(){return System.Label.SFM004_TAG004;}//'Delete the generated document'
    public String getTAG004(){return System.Label.SFM004_TAG016;}//'This action will delete all the file and its prior versions if any. Do you want to continue? Yes/ No' Added for BAC-4155
}