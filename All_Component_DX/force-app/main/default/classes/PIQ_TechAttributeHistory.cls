/*****************************************************************************
 *                       Copyright (C) 2019 ServiceMax, Inc
 *                               All rights reserved
 *
 *****************************************************************************/

/**
 * The PIQ_TechAttributeHistory contains all services related to display Installed Base Product IQ technical attributes.
 * 
 * @author Balasubramanian
 * @version 20.1
 * @since 2019
 */
/*****************************************************************************************************
 *    ID        Name                   Date            Comment
 *****************************************************************************************************
 *              Balasubramanian        01 Dec 2019     Created. 
 *****************************************************************************************************/
public with sharing class PIQ_TechAttributeHistory {
    public PIQ_TechAttributeHistory() {

    }

    @AuraEnabled(cacheable=true)
    public static TechAttributeResp getHistory(Id recordId, String startDate, String endDate) {
        TechAttributeResp response = getIBHistory(recordId, startDate, endDate);
        return response;
    }

    private static DateTime populateDateTime(String givenDate){
        DateTime response;
        String[] dateComp = givenDate.split('-');
        response = datetime.newInstance(Integer.valueOf(dateComp[0]), Integer.valueOf(dateComp[1]), Integer.valueOf(dateComp[2]));
        return response;
    }

    

    public class TechAttributeResp{
        @AuraEnabled
        public SVMXC__Installed_Product__c objInstalledBase{get; set;}
        @AuraEnabled
        public map<String, String> attributes{get; set;}
        @AuraEnabled
        public list<TechAttributeHistory> lstTechAttributes{get; set;}
        @AuraEnabled
        public Boolean success{get; set;}
        @AuraEnabled
        public String error{get; set;}

        public TechAttributeResp(){
            this.success = true;
            this.attributes = new map<String, String>();
            this.attributes.put('capturedOn', 'Captured On'); 
            this.lstTechAttributes = new list<TechAttributeHistory>();
        }
    }

    // Wrapper class to hold technical attribute history
    public class TechAttributeHistory{
        @AuraEnabled
        public String capturedOn{get; set;}
        @AuraEnabled
        public list<TechAttribute> attributes{get; set;}

        public TechAttributeHistory(datetime capturedOn){
            this.capturedOn = capturedOn.format('MM/dd/yyyy, hh:mm:ss a');
            this.attributes = new list<TechAttribute>();
        }
    }

    public class TechAttribute{
        @AuraEnabled
        public String type{get; set;}
        @AuraEnabled
        public String key{get; set;}
        @AuraEnabled
        public String value{get; set;}

        public TechAttribute(String type, String key, String value){
            this.type = type;
            Pattern nonAlphanumeric = Pattern.compile('[^a-zA-Z0-9]');
            Matcher matcher = nonAlphanumeric.matcher(key);
            this.key = matcher.replaceAll('');
            this.value = value;
        }
    }

    // Populate technical attribute history for the given IB
    public static TechAttributeResp getIBHistory(Id ibId, String startDate, String endDate){
        TechAttributeResp response = new TechAttributeResp();
        set<String> setAttributes = new set<String>();
        list<TechAttributeHistory> lstTechAttributes = new list<TechAttributeHistory>();
        list<SVMXC__SM_IB_Attributes_History__c> lstTechAttributesHistory = new list<SVMXC__SM_IB_Attributes_History__c>();
        
        try{
            //Perform access check
            /*
            List<String> queryFields = new List<String> {'Name'};
            if( ! COMM_SecurityUtils.getInstance().verifyFieldAccess( 'SVMXC__Installed_Product__c', queryFields, COMM_SecurityUtils.Access.Accessible ) ) {
                throw new COMM_SecurityUtils.SecurityAccessException( System.Label.COMM001_TAG142 );
            }
            queryFields = new List<String> {'SVMXC__SM_Attr_Payload__c', 'SVMXC__SM_Captured_On__c', 'SVMXC__SM_Instance_Template_Id__c', 'SVMXC__SM_Installed_Product_Id__c', 'SVMXC__SM_Attr_Type__c'};
            if( ! COMM_SecurityUtils.getInstance().verifyFieldAccess( 'SVMXC__SM_IB_Attributes_History__c', queryFields, COMM_SecurityUtils.Access.Accessible ) ) {
                throw new COMM_SecurityUtils.SecurityAccessException( System.Label.COMM001_TAG142 );
            }
            queryFields = new List<String> {'SVMXC__SM_Active__c'};
            if( ! COMM_SecurityUtils.getInstance().verifyFieldAccess( 'SVMXC__SM_Attributes_Template__c', queryFields, COMM_SecurityUtils.Access.Accessible ) ) {
                throw new COMM_SecurityUtils.SecurityAccessException( System.Label.COMM001_TAG142 );
            }
            queryFields = new List<String> {'SVMXC__SM_Instance_Template_Id__c'};
            if( ! COMM_SecurityUtils.getInstance().verifyFieldAccess( 'SVMXC__SM_IB_Attributes_Template_Instance__c', queryFields, COMM_SecurityUtils.Access.Accessible ) ) {
                throw new COMM_SecurityUtils.SecurityAccessException( System.Label.COMM001_TAG142 );
            }*/
            response.objInstalledBase = [select Id, Name from SVMXC__Installed_Product__c where Id = :ibId][0];
            // Populate technical attributes from SVMXC__SM_IB_Attributes_History__c object 
            if(!String.isBlank(startDate) && !String.isBlank(endDate)){
                DateTime startTime = populateDateTime(startDate);
                DateTime endTime = populateDateTime(endDate);
                // Check if start date is lessar than end date
                if(startTime > endTime){
                    response.success = false;
                    response.error = 'End date should be greater than start date';
                    return response;
                }
                endTime = endTime.addDays(1);
                system.debug('startTime: ' + startTime);
                system.debug('endDate: ' + endDate);
                lstTechAttributesHistory = [Select SVMXC__SM_Attr_Payload__c, SVMXC__SM_Captured_On__c, SVMXC__SM_Instance_Template_Id__r.SVMXC__SM_Instance_Template_Id__c from SVMXC__SM_IB_Attributes_History__c where 
                                                    SVMXC__SM_Installed_Product_Id__c = :ibId and SVMXC__SM_Captured_On__c >= :startTime and SVMXC__SM_Captured_On__c <= :endTime and SVMXC__SM_Attr_Type__c = 'TECHNICAL' and SVMXC__SM_Instance_Template_Id__r.SVMXC__SM_Instance_Template_Id__c != null 
                                                    order by SVMXC__SM_Captured_On__c desc limit 10000];
            }else if(!String.isBlank(startDate)){
                DateTime startTime = populateDateTime(startDate);
                lstTechAttributesHistory = [Select SVMXC__SM_Attr_Payload__c, SVMXC__SM_Captured_On__c, SVMXC__SM_Instance_Template_Id__r.SVMXC__SM_Instance_Template_Id__c from SVMXC__SM_IB_Attributes_History__c where 
                                                    SVMXC__SM_Installed_Product_Id__c = :ibId and SVMXC__SM_Captured_On__c >= :startTime and SVMXC__SM_Attr_Type__c = 'TECHNICAL' and SVMXC__SM_Instance_Template_Id__r.SVMXC__SM_Instance_Template_Id__c != null 
                                                    order by SVMXC__SM_Captured_On__c desc limit 10000];
            }else if(!String.isBlank(endDate)){
                DateTime endTime = populateDateTime(endDate);
                endTime = endTime.addDays(1);
                system.debug('endTime : ' + endTime);

                lstTechAttributesHistory = [Select SVMXC__SM_Attr_Payload__c, SVMXC__SM_Captured_On__c, SVMXC__SM_Instance_Template_Id__r.SVMXC__SM_Instance_Template_Id__c from SVMXC__SM_IB_Attributes_History__c where 
                                                    SVMXC__SM_Installed_Product_Id__c = :ibId and SVMXC__SM_Captured_On__c <= :endTime and SVMXC__SM_Attr_Type__c = 'TECHNICAL' and SVMXC__SM_Instance_Template_Id__r.SVMXC__SM_Instance_Template_Id__c != null 
                                                    order by SVMXC__SM_Captured_On__c desc limit 10000];
            }else{
                lstTechAttributesHistory = [Select SVMXC__SM_Attr_Payload__c, SVMXC__SM_Captured_On__c, SVMXC__SM_Instance_Template_Id__r.SVMXC__SM_Instance_Template_Id__c from SVMXC__SM_IB_Attributes_History__c where 
                                                    SVMXC__SM_Installed_Product_Id__c = :ibId and SVMXC__SM_Attr_Type__c = 'TECHNICAL' and SVMXC__SM_Instance_Template_Id__r.SVMXC__SM_Instance_Template_Id__c != null 
                                                    order by SVMXC__SM_Captured_On__c desc limit 10000];
            }

            //Filtering technical attribute which are from active template
            set<Id> allTemplateIds = new set<Id>();
            set<Id> activeTemplateIds = new set<Id>();
            for(SVMXC__SM_IB_Attributes_History__c attribute: lstTechAttributesHistory){
                allTemplateIds.add(attribute.SVMXC__SM_Instance_Template_Id__r.SVMXC__SM_Instance_Template_Id__c);
            }
            for(SVMXC__SM_Attributes_Template__c activeTemplate: [Select Id from SVMXC__SM_Attributes_Template__c where SVMXC__SM_Active__c = true and id IN :allTemplateIds]){
                activeTemplateIds.add(activeTemplate.Id);
            }

            // Parse the JSON and build the response structure that can be processed by the UI component
            for(SVMXC__SM_IB_Attributes_History__c attribute: lstTechAttributesHistory){
                if(!activeTemplateIds.contains(attribute.SVMXC__SM_Instance_Template_Id__r.SVMXC__SM_Instance_Template_Id__c) || attribute.SVMXC__SM_Attr_Payload__c == null){
                    continue;
                }
                TechnicalAttributeConfiguration.IbInstancePayload ibInstancePayload = (TechnicalAttributeConfiguration.IbInstancePayload)JSON.deserialize(attribute.SVMXC__SM_Attr_Payload__c, TechnicalAttributeConfiguration.IbInstancePayload.class);
                if(ibInstancePayload.fields != null && !ibInstancePayload.fields.isEmpty()){
                    TechAttributeHistory history = new TechAttributeHistory(attribute.SVMXC__SM_Captured_On__c);
                    for(TechnicalAttributeConfiguration.AttributesCategory category: ibInstancePayload.fields){
                        list<TechnicalAttributeConfiguration.Attribute> lstAttribute = new list<TechnicalAttributeConfiguration.Attribute>();
                        if(category.technicalAttributes != null)
                            lstAttribute = category.technicalAttributes;
                        for(TechnicalAttributeConfiguration.Attribute attValue :lstAttribute){
                            setAttributes.add(attValue.label);
                            history.attributes.add(new TechAttribute(attValue.format, attValue.label, attValue.defaultValue));
                        }
                    }
                    lstTechAttributes.add(history);
                }
            }
            for(String attr: setAttributes){
                Pattern nonAlphanumeric = Pattern.compile('[^a-zA-Z0-9]');
                Matcher matcher = nonAlphanumeric.matcher(attr);
                response.attributes.put(matcher.replaceAll(''), attr);
            }
            response.lstTechAttributes = lstTechAttributes;
        }
        catch(Exception ex){
            response.success = false;
            response.error = ex.getMessage();
            System.debug(LoggingLevel.WARN, 'Exception in PIQ_TechAttributeHistory.getIBHistory method: ' + ex.getMessage());
        }
        return response;
    }
}