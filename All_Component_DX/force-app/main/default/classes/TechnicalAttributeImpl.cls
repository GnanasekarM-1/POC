public with sharing class TechnicalAttributeImpl {
    
    public enum source {WEB, MOBILE, API}
    public source calledfrom{get;set;}

    public TechnicalAttributeImpl(){
        calledfrom = source.API;
    }

    public TechnicalAttributeImpl(source source){
        calledfrom = source;
    }

    public Object getMetaData() {
        
        TechnicalAttributeUtils objUtils = new TechnicalAttributeUtils();   
        return objUtils.getMetaData();        
    }

    public Object getAttributesTemplateInstanceForIB(String ibId) {
        
        TechnicalAttributeUtils objUtils = new TechnicalAttributeUtils();   
        return objUtils.getAttributesTemplateInstanceForIB(ibId);        
    }

    public Object saveTechnicalAttributeDetails(String request) {
        
        TechnicalAttributeUtils objUtils = new TechnicalAttributeUtils(calledfrom);   
        return objUtils.saveTechnicalAttributeDetails(request);        
    }
    
    public Object getAllAttributesforIB(String request) {
        list<Id> lstIB = (List<Id>) JSON.deserialize(request, List<Id>.class);
        PIQ_TechAttributeHistoryServices objUtils = new PIQ_TechAttributeHistoryServices();   
        return objUtils.getAllAttributesforIB(lstIB);
    }


    public Object getIBDetails(String request) {
        PIQ_Wrapper.PIQ_IBDetailsReq req = (PIQ_Wrapper.PIQ_IBDetailsReq) JSON.deserialize(request, PIQ_Wrapper.PIQ_IBDetailsReq.class);
        PIQ_TechAttributeHistoryServices objUtils = new PIQ_TechAttributeHistoryServices();   
        return objUtils.getIBDetails(req.lstIbs, req.lstFields);
    }

    public Object getInstalledProductforTechnicalAttribute(String request) {
        PIQ_TechAttributeHistoryServices objUtils = new PIQ_TechAttributeHistoryServices();
        PIQ_Wrapper.PIQ_Request objReq = (PIQ_Wrapper.PIQ_Request) JSON.deserialize(request, PIQ_Wrapper.PIQ_Request.class);
        return objUtils.getInstalledProductforTechnicalAttribute(objReq);
    }

    /*
    This is just a static response, To get the available product filter that can be used in product filter option
    */
    public Object getAllProductFilter(String request) {
        PIQ_TechAttributeHistoryServices objUtils = new PIQ_TechAttributeHistoryServices();
        return objUtils.getAllProductFilter();
    }

    /*
    This is just a static response, To get the available product filter that can be used in product filter option
    */
    public Object getAllProductOperator(String request) {
        PIQ_TechAttributeHistoryServices objUtils = new PIQ_TechAttributeHistoryServices();
        return objUtils.getAllProductOperator();
    }

    /*
    This is just a static response, To get the available product filter that can be used in attribute filter option
    */
    public Object getAllAttributeOperator(String request) {
        PIQ_TechAttributeHistoryServices objUtils = new PIQ_TechAttributeHistoryServices();
        return objUtils.getAllAttributeOperator();
    }

    /*
    This is just a static response, to show possible secondary search on Installed product and technical attribute
    */
    public Object getAllAdditionalFilter(String request) {
        PIQ_TechAttributeHistoryServices objUtils = new PIQ_TechAttributeHistoryServices();
        return objUtils.getAllAdditionalFilter();
    }

    /*
    This is just a static response, to show possible fields that can be displayed as first column
    */
    public Object getPossibleFirstColumns(String request) {
        PIQ_TechAttributeHistoryServices objUtils = new PIQ_TechAttributeHistoryServices();
        return objUtils.getPossibleFirstColumns();
    }

    /*
    Used to identify the products based on product name
    */
    public Object filterProductName(String request) {
        PIQ_TechAttributeHistoryServices objUtils = new PIQ_TechAttributeHistoryServices();
        system.debug('request: ' + request);
        PIQ_Wrapper.PIQ_Request objReq = (PIQ_Wrapper.PIQ_Request) JSON.deserialize(request, PIQ_Wrapper.PIQ_Request.class);
        system.debug('objReq: ' + objReq);
        return objUtils.filterProductName(objReq.value);
    }

    /*
    Get History - Group by Record
    */
    public Object getAllHistoryGroupByRecord(String request) {
        PIQ_TechAttributeHistoryServices objUtils = new PIQ_TechAttributeHistoryServices();
        PIQ_Wrapper.PIQ_History_Request objReq = (PIQ_Wrapper.PIQ_History_Request) JSON.deserialize(request, PIQ_Wrapper.PIQ_History_Request.class);
        return objUtils.getAllHistoryGroupByRecord(objReq.ibIdList, objReq.attributeNameList , objReq.startDate , objReq.endDate);
    }

    /*
    Get History - Group by Attribute
    */
    public Object getAllHistoryGroupByAttribute(String request) {
        PIQ_TechAttributeHistoryServices objUtils = new PIQ_TechAttributeHistoryServices();
        PIQ_Wrapper.PIQ_History_Request objReq = (PIQ_Wrapper.PIQ_History_Request) JSON.deserialize(request, PIQ_Wrapper.PIQ_History_Request.class);
        return objUtils.getAllHistoryGroupByAttribute(objReq.ibIdList, objReq.attributeNameList , objReq.startDate , objReq.endDate);
    }
    
    /*
    This method is to get all the Custom labels/Tags information
    */
    public Object getAllTags(String request) {
        PIQ_TechAttributeHistoryServices objUtils = new PIQ_TechAttributeHistoryServices();
        system.debug(LoggingLevel.DEBUG,'*** Fetching custom labels');
        return objUtils.getAllTags();
    }

}