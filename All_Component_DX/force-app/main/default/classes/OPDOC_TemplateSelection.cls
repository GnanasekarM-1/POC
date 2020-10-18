/*****************************************************************************
 *                       Copyright (C) 2015 ServiceMax, Inc
 *                               All rights reserved
 *
 *****************************************************************************/

/**
 * The OPDOC_TemplateSelection class is a controller class for page OPDOC_TemplateSelection,
 * this gets the list of outputdoc process available for a record and provides a link for 
 * launching individual process. 
 * 
 *
 * @author Sachin S
 * @version 
 * @since 2015
 */
/*****************************************************************************************************
 *    ID        Name                   Date            Comment
 *****************************************************************************************************
 *              Sachin S               02 Dec 2015     Created.
 *****************************************************************************************************/
public with sharing class OPDOC_TemplateSelection {
    
    public Id recordId{get;set;}
    public List<processWrapper> docWrapperList{get;set;}
    public String recordName {get;set;} 
    public String getTag001(){ return System.Label.CONF016_TAG113;} //'Select Template'
    public String getTag003(){ return System.label.CONF016_TAG032;}//'Cancel'
    public String getTag004(){ return System.Label.CONF016_TAG115;}//'No Template is available for this Object'
    public String getTag005(){ return System.Label.CONF016_TAG121;} //Available output document template(s) for
    
    /**
     * Constructor
     */
    public OPDOC_TemplateSelection(){
        recordId = ApexPages.currentPage().getParameters().get('SVMX_processId');
		String returnBaseURL = URL.getSalesforceBaseUrl().toExternalForm();
        docWrapperList = new List<processWrapper>();
        if(recordId != null){
           String objName = recordId.getSObjectType().getDescribe().getName();
           String nameField = getObjNameField(objName);
           if(nameField != null){
              sObject sObjRec = Database.Query('SELECT ' + nameField +  ' FROM ' + objName + ' WHERE Id =: recordId' );
              recordName = (String)sObjRec.get(nameField);    
           }
           INTF_WebServicesDef.INTF_Response responseObj = new INTF_WebServicesDef.INTF_Response(); 
           responseObj = INTF_WebServicesDef.INTF_GetSFWOutputTemplate_WS(recordId);
           System.debug(logginglevel.INFO, 'Opdoc - responseObj  :' + responseObj );
           if(responseObj != null && responseObj.valueMap != null && responseObj.valueMap.size() > 0){
               System.debug(logginglevel.INFO, 'Opdoc - responseObj ValueMap :' + responseObj.valueMap );
               for(INTF_WebServicesDef.SVMXMap docItr : responseObj.valueMap){
                   SVMXC__ServiceMax_Processes__c processRec = (ServiceMax_Processes__c)docItr.record;
                   processWrapper processWrapRec = new processWrapper(processRec, recordId, returnBaseURL);
                   System.debug(logginglevel.INFO, 'Opdoc - responseObj  Wrapper Record:' + processWrapRec );
                   docWrapperList.add(processWrapRec );
               }
           }
        }   
        
    }
    
    /*
     * Method to get the API name of the Record Name field for the object 
     */
    public String getObjNameField(String objName){
        Map<String, SObjectField> fieldsMap = Schema.getGlobalDescribe().get(objName).getDescribe().fields.getMap();
        String nameField;
        for(String fieldName : fieldsMap.keySet()){
            DescribeFieldResult fieldResult = fieldsMap.get(fieldName).getDescribe();
            if(fieldResult.isNameField()){
               nameField = fieldResult.getName(); 
               break;   
            }    
        }
        return nameField;
    }
    
    /*
     * Wrapper class to wrap process record and the URL for launching the individual process
     */
    public class processWrapper{
        public String url{get;set;}
        public SVMXC__ServiceMax_Processes__c processRec {get;set;}
        public processWrapper(SVMXC__ServiceMax_Processes__c outputDoc,String objId, String returnBaseURL){
            this.processRec = outputDoc;
			this.url = '/apex/SVMXC__OPDOC_Delivery?SVMX_processId=' + processRec.SVMXC__ProcessID__c + '&SVMX_recordId=' + objId + '&SVMX_retURL=' + returnBaseURL + '/' + objId;
            //commented for the defect fix 026720
			//this.url = '/apex/SVMXC__OPDOC_Delivery?SVMX_processId=' + processRec.SVMXC__ProcessID__c + '&SVMX_recordId=' + objId + '&SVMX_retURL=' + objId;
        }
    }
    
    /*
     * Cancel method to invoke cancel - redirecting to the record detail page
     */ 
    public pageReference Cancel(){
        pageReference pageRef = new pageReference('/' + recordId );
        pageRef.setRedirect(true);
        return pageRef;
    }

}