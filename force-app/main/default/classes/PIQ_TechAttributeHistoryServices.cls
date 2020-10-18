/*****************************************************************************
 *                       Copyright (C) 2016 ServiceMax, Inc
 *                               All rights reserved
 *
 *****************************************************************************/

/**
 * The PIQ_TechAttributeHistoryServices class will provide all the necessary services for technical attribute history feature
 * 
 *
 * @author Balasubramanian
 * @version 20.2
 * @since 2020
 */
/*****************************************************************************************************
 *    ID        Name                   Date            Comment
 *****************************************************************************************************
 *              Balasubramanian        13 May 2020     Created. 
 *****************************************************************************************************/

public with sharing class PIQ_TechAttributeHistoryServices {
    public PIQ_TechAttributeHistoryServices() {

    }

    private static final List<PIQ_Wrapper.attribute> PRODUCT_FILTERS = new List<PIQ_Wrapper.attribute> {
        new PIQ_Wrapper.attribute(PIQ_Constants.FILTER_PRODUCTNAME, system.label.PRODIQ002_TAG005),
        new PIQ_Wrapper.attribute(PIQ_Constants.FILTER_PRODUCTLINE, system.label.PRODIQ002_TAG006),
        new PIQ_Wrapper.attribute(PIQ_Constants.FILTER_PRODUCTFAMILY, system.label.PRODIQ002_TAG007)
    };

    private static final List<PIQ_Wrapper.attribute> ADDITIONAL_FILTERS = new List<PIQ_Wrapper.attribute> {
        new PIQ_Wrapper.attribute(PIQ_Constants.FILTER_TECHNICALATTRIBUTE, system.label.PRODIQ002_TAG038),
        new PIQ_Wrapper.attribute(PIQ_Constants.FILTER_INSTALLEDPRODUCT, system.label.PRODIQ002_TAG002)
    };

    private static final List<PIQ_Wrapper.attribute> PRODUCT_COMPARISON_OPERATORS = new List<PIQ_Wrapper.attribute> {
        new PIQ_Wrapper.attribute(PIQ_Constants.OPERATOR_EQUALTO, system.label.FCO001_TAG009),
        new PIQ_Wrapper.attribute(PIQ_Constants.OPERATOR_NOTQUALTO, system.label.FCO001_TAG010),
        new PIQ_Wrapper.attribute(PIQ_Constants.OPERATOR_CONTAINS, system.label.FCO001_TAG008),
        new PIQ_Wrapper.attribute(PIQ_Constants.OPERATOR_NOTCONTAINS, system.label.FCO001_TAG011)
    };

    private static final List<PIQ_Wrapper.attribute> COMPARISON_OPERATORS = new List<PIQ_Wrapper.attribute> {
        new PIQ_Wrapper.attribute(PIQ_Constants.OPERATOR_EQUALTO, system.label.FCO001_TAG009),
        new PIQ_Wrapper.attribute(PIQ_Constants.OPERATOR_NOTQUALTO, system.label.FCO001_TAG010),
        new PIQ_Wrapper.attribute(PIQ_Constants.OPERATOR_GREATERTHAN, system.label.FCO001_TAG017),
        new PIQ_Wrapper.attribute(PIQ_Constants.OPERATOR_GREATERTHANEQUAL, system.label.FCO001_TAG018),
        new PIQ_Wrapper.attribute(PIQ_Constants.OPERATOR_LESSTHAN, system.label.FCO001_TAG019),
        new PIQ_Wrapper.attribute(PIQ_Constants.OPERATOR_LESSTHANEQUAL, system.label.FCO001_TAG020),
        new PIQ_Wrapper.attribute(PIQ_Constants.OPERATOR_CONTAINS, system.label.FCO001_TAG008),
        new PIQ_Wrapper.attribute(PIQ_Constants.OPERATOR_NOTCONTAINS, system.label.FCO001_TAG011)
    };

    /*
    Get all latest technical attribute paramaeters for the given installed product
    */
    public object getAllAttributesforIB(list<Id> lstIBIds){
        try{
            system.debug('request: ' + lstIBIds);
            list<PIQ_Wrapper.attribute> response = PIQ_TechAttributeHistoryServicesUtils.getAllAttributesforIB(lstIBIds);
            PIQ_Wrapper.jsrData responseData = new PIQ_Wrapper.jsrData();
            responseData.data = response;
            return responseData;
        }
        catch(Exception ex){
            PIQ_Wrapper.PIQ_Response response = new PIQ_Wrapper.PIQ_Response();
            response.success = false;
            response.error = ex.getMessage();
            System.debug(LoggingLevel.WARN, 'Exception in PIQ_TechAttributeHistoryServices.getAllAttributesforIB method: ' + ex.getMessage());
            return response;
        }
    }

    /*
    We will be adding support to search on installed product in future releases
    */
    public object getInstalledProductforTechnicalAttribute(PIQ_Wrapper.PIQ_Request request){
        
        PIQ_Wrapper.PIQ_Response response = new PIQ_Wrapper.PIQ_Response();
        list<SVMXC__Installed_Product__c> lstInstalledProducts = new list<SVMXC__Installed_Product__c>();
        String additionalProductFilter = '';
        PIQ_Wrapper.expression expression = request.expression;

        system.debug('request: ' + request);
        
        try{
            //If we have criteria on product attributes, identify the installed product matching the product
            if(!expression.lstProductAttributes.isEmpty()){
                additionalProductFilter = PIQ_TechAttributeHistoryServicesUtils.buildProductQueryFilter(expression.lstProductAttributes);
            }

            if(expression.lstTechnicalAttributes == null || expression.lstTechnicalAttributes.size() == 0){
                request.operator = 'OR';
            }
            
            //Identify the installed product matching the latest value of technical attribute
            if(request.operator == 'AND'){
                response = PIQ_TechAttributeHistoryServicesUtils.getIBforAllTechAttribute(expression.lstTechnicalAttributes, additionalProductFilter);
            }else if(request.operator == 'OR'){
                response = PIQ_TechAttributeHistoryServicesUtils.getIBforAnyTechAttribute(expression.lstTechnicalAttributes, additionalProductFilter);
            }

            if(request.lstFields != null && request.lstFields.size() > 0){
                list<Id> lstIBIds = new list<Id>();
                for(SVMXC__Installed_Product__c objIB: response.lstInstalledProducts){
                    lstIBIds.add(objIB.Id);
                }
                
            }
        }
        catch(Exception ex){
            response.success = false;
            response.error = ex.getMessage();
            System.debug(LoggingLevel.WARN, 'Exception in PIQ_TechAttributeHistoryServices.getInstalledProductforTechnicalAttribute method: ' + ex.getMessage());
        }

        
        system.debug('response: ' + response.lstInstalledProducts);

        PIQ_Wrapper.jsrData responseData = new PIQ_Wrapper.jsrData();
        if(response.success && response.lstInstalledProducts != null && response.lstInstalledProducts.size() > 0){
            responseData.data = response;
        }
        else{
            responseData.data = new list<SVMXC__Installed_Product__c>();
            responseData.message = system.label.PRODIQ002_TAG016 + ' ' + system.label.PRODIQ002_TAG017 ; //'No records found. Please adjust filter to get result.'
        }
        return responseData;
    }

    /*
    This is just a static response, to show possible filters on product attribute
    */
    public object getAllProductFilter(){
        PIQ_Wrapper.jsrData responseData = new PIQ_Wrapper.jsrData();

        for(PIQ_Wrapper.attribute prodDef: PRODUCT_FILTERS){
            if(prodDef.key == PIQ_Constants.FILTER_PRODUCTFAMILY){
                list<PIQ_Wrapper.attribute> lstFields = new list<PIQ_Wrapper.attribute>();
                Schema.DescribeFieldResult fieldResult = Product2.Family.getDescribe();
                List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
                for( Schema.PicklistEntry pickListVal : ple){
                    lstFields.add(new PIQ_Wrapper.attribute(pickListVal.getValue(), pickListVal.getLabel()));
                }
                prodDef.lstFields = lstFields;
            }else if(prodDef.key == PIQ_Constants.FILTER_PRODUCTLINE){
                list<PIQ_Wrapper.attribute> lstFields = new list<PIQ_Wrapper.attribute>();
                Schema.DescribeFieldResult fieldResult = Product2.SVMXC__Product_Line__c.getDescribe();
                List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
                for( Schema.PicklistEntry pickListVal : ple){
                    lstFields.add(new PIQ_Wrapper.attribute(pickListVal.getValue(), pickListVal.getLabel()));
                }
                prodDef.lstFields = lstFields;
            }
        }
        responseData.data = PRODUCT_FILTERS;
        return responseData;
    }


    /*
    This is just a static response, get all operator for product filter
    */
    public object getAllProductOperator(){
        PIQ_Wrapper.jsrData responseData = new PIQ_Wrapper.jsrData();
        responseData.data = PRODUCT_COMPARISON_OPERATORS;
        return responseData;
    }

    /*
    This is just a static response, get all operator for attribute
    */
    public object getAllAttributeOperator(){
        PIQ_Wrapper.jsrData responseData = new PIQ_Wrapper.jsrData();
        responseData.data = COMPARISON_OPERATORS;
        return responseData;
    }

    /*
    This is just a static response, to show possible secondary search on Installed product and technical attribute
    */
    public object getAllAdditionalFilter(){
        PIQ_Wrapper.jsrData responseData = new PIQ_Wrapper.jsrData();
        responseData.data = ADDITIONAL_FILTERS;
        return responseData;
    }
    /*
    This is just a static response, to show possible fields that can be displayed as first column
    */
    public object getPossibleFirstColumns(){
        try{
            list<PIQ_Wrapper.attribute> response = new list<PIQ_Wrapper.attribute>();
            response.add(new PIQ_Wrapper.attribute(PIQ_Constants.FILTER_IBNAME, system.label.PRODIQ002_TAG061));
            response.add(new PIQ_Wrapper.attribute(PIQ_Constants.FILTER_IBASSETTAG, system.label.PRODIQ002_TAG062));
            response.add(new PIQ_Wrapper.attribute(PIQ_Constants.FILTER_IBSERIALNO, system.label.PRODIQ002_TAG063));

            PIQ_Wrapper.jsrData responseData = new PIQ_Wrapper.jsrData();
            responseData.data = response;
            return responseData;
        }
        catch(Exception ex){
            PIQ_Wrapper.PIQ_Response response = new PIQ_Wrapper.PIQ_Response();
            response.success = false;
            response.error = ex.getMessage();
            System.debug(LoggingLevel.WARN, 'Exception in PIQ_TechAttributeHistoryServices.getAllProductFilter method: ' + ex.getMessage());
            return response;
        }
    }

    /*
    Get all latest technical attribute paramaeters for the given installed product
    */
    public object getIBDetails(list<Id> lstIBIds, list<String> fields){
        try{
            system.debug('request: ' + lstIBIds);
            map<Id, map<string, String>> response = PIQ_TechAttributeHistoryServicesUtils.getInstalledBaseforAttribute(lstIBIds, fields);
            PIQ_Wrapper.jsrData responseData = new PIQ_Wrapper.jsrData();
            responseData.data = response;
            return responseData;
        }
        catch(Exception ex){
            PIQ_Wrapper.PIQ_Response response = new PIQ_Wrapper.PIQ_Response();
            response.success = false;
            response.error = ex.getMessage();
            System.debug(LoggingLevel.WARN, 'Exception in PIQ_TechAttributeHistoryServices.getAllAttributesforIB method: ' + ex.getMessage());
            return response;
        }
    }

    /*
    Used to identify the products based on product name
    */
    public object filterProductName(String productName){
        productName = '%' + String.escapeSingleQuotes(productName) + '%';
        productName = productName.replace('_', '\\_'); 
        //list<Product2> lstProduct = [Select Id, Name from Product2 where Name like :productName LIMIT 50000];
        list<Product2> lstProduct = Database.query('Select Id, Name from Product2 where Name like \''+ productName + '\' LIMIT 50000');
        PIQ_Wrapper.jsrData responseData = new PIQ_Wrapper.jsrData();
        responseData.data = lstProduct;
        return responseData;
    }

    /*
    Get History - Group By Record
    */
    public object getAllHistoryGroupByRecord(List<Id> installedProdIds, List<String> attributeNames, String strStartDate, String strEndDate){
        PIQ_Wrapper.PIQ_History_Response response = PIQ_TechAttributeHistoryServicesUtils.getHistoryByIB(installedProdIds, attributeNames, strStartDate, strEndDate);

        PIQ_Wrapper.jsrData responseData = new PIQ_Wrapper.jsrData();
        responseData.data = response;
        responseData.success = response.success;
        responseData.message = response.message;

        return responseData;
    }

    /*
    Get History - Group By Attribute
    */
    public object getAllHistoryGroupByAttribute(List<Id> installedProdIds, List<String> attributeNames, String strStartDate, String strEndDate){
        PIQ_Wrapper.PIQ_History_Response response = PIQ_TechAttributeHistoryServicesUtils.getHistoryByAttribute(installedProdIds, attributeNames, strStartDate, strEndDate);

        PIQ_Wrapper.jsrData responseData = new PIQ_Wrapper.jsrData();
        responseData.data = response;
        responseData.success = response.success;
        responseData.message = response.message;

        return responseData;
    }

    /*
    This is just a static response, get all Custom labels/Tags for UI
    */
    public object getAllTags(){
        PIQ_Wrapper.jsrData responseData = new PIQ_Wrapper.jsrData();
        responseData.data = ALL_TAGS;
        return responseData;
    }

    private static final List<PIQ_Wrapper.attribute> ALL_TAGS = new List<PIQ_Wrapper.attribute> {
        new PIQ_Wrapper.attribute('PRODIQ002_HLPURL', system.label.PRODIQ002_HLPURL),
        new PIQ_Wrapper.attribute('PRODIQ002_TAG001', system.label.PRODIQ002_TAG001),
        new PIQ_Wrapper.attribute('PRODIQ002_TAG002', system.label.PRODIQ002_TAG002),
        new PIQ_Wrapper.attribute('PRODIQ002_TAG003', system.label.PRODIQ002_TAG003),
        new PIQ_Wrapper.attribute('PRODIQ002_TAG004', system.label.PRODIQ002_TAG004),
        new PIQ_Wrapper.attribute('PRODIQ002_TAG005', system.label.PRODIQ002_TAG005),
        new PIQ_Wrapper.attribute('PRODIQ002_TAG006', system.label.PRODIQ002_TAG006),
        new PIQ_Wrapper.attribute('PRODIQ002_TAG007', system.label.PRODIQ002_TAG007),
        new PIQ_Wrapper.attribute('PRODIQ002_TAG008', system.label.PRODIQ002_TAG008),
        new PIQ_Wrapper.attribute('PRODIQ002_TAG009', system.label.PRODIQ002_TAG009),
        new PIQ_Wrapper.attribute('PRODIQ002_TAG010', system.label.PRODIQ002_TAG010),
        new PIQ_Wrapper.attribute('PRODIQ002_TAG011', system.label.PRODIQ002_TAG011),
        new PIQ_Wrapper.attribute('PRODIQ002_TAG012', system.label.PRODIQ002_TAG012),
        new PIQ_Wrapper.attribute('PRODIQ002_TAG013', system.label.PRODIQ002_TAG013),
        new PIQ_Wrapper.attribute('PRODIQ002_TAG014', system.label.PRODIQ002_TAG014),
        new PIQ_Wrapper.attribute('PRODIQ002_TAG015', system.label.PRODIQ002_TAG015),
        new PIQ_Wrapper.attribute('PRODIQ002_TAG016', system.label.PRODIQ002_TAG016),
        new PIQ_Wrapper.attribute('PRODIQ002_TAG017', system.label.PRODIQ002_TAG017),
        new PIQ_Wrapper.attribute('PRODIQ002_TAG018', system.label.PRODIQ002_TAG018),
        new PIQ_Wrapper.attribute('PRODIQ002_TAG019', system.label.PRODIQ002_TAG019),
        new PIQ_Wrapper.attribute('PRODIQ002_TAG020', system.label.PRODIQ002_TAG020),
        new PIQ_Wrapper.attribute('PRODIQ002_TAG021', system.label.PRODIQ002_TAG021),
        new PIQ_Wrapper.attribute('PRODIQ002_TAG022', system.label.PRODIQ002_TAG022),
        new PIQ_Wrapper.attribute('PRODIQ002_TAG023', system.label.PRODIQ002_TAG023),
        new PIQ_Wrapper.attribute('PRODIQ002_TAG024', system.label.PRODIQ002_TAG024),
        new PIQ_Wrapper.attribute('PRODIQ002_TAG025', system.label.PRODIQ002_TAG025),
        new PIQ_Wrapper.attribute('PRODIQ002_TAG026', system.label.PRODIQ002_TAG026),
        new PIQ_Wrapper.attribute('PRODIQ002_TAG027', system.label.PRODIQ002_TAG027),
        new PIQ_Wrapper.attribute('PRODIQ002_TAG028', system.label.PRODIQ002_TAG028),
        new PIQ_Wrapper.attribute('PRODIQ002_TAG029', system.label.PRODIQ002_TAG029),
        new PIQ_Wrapper.attribute('PRODIQ002_TAG030', system.label.PRODIQ002_TAG030),
        new PIQ_Wrapper.attribute('PRODIQ002_TAG031', system.label.PRODIQ002_TAG031),
        new PIQ_Wrapper.attribute('PRODIQ002_TAG032', system.label.PRODIQ002_TAG032),
        new PIQ_Wrapper.attribute('PRODIQ002_TAG033', system.label.PRODIQ002_TAG033),
        new PIQ_Wrapper.attribute('PRODIQ002_TAG034', system.label.PRODIQ002_TAG034),
        new PIQ_Wrapper.attribute('PRODIQ002_TAG035', system.label.PRODIQ002_TAG035),
        new PIQ_Wrapper.attribute('PRODIQ002_TAG036', system.label.PRODIQ002_TAG036),
        new PIQ_Wrapper.attribute('PRODIQ002_TAG037', system.label.PRODIQ002_TAG037),
        new PIQ_Wrapper.attribute('PRODIQ002_TAG038', system.label.PRODIQ002_TAG038),
        new PIQ_Wrapper.attribute('PRODIQ002_TAG039', system.label.PRODIQ002_TAG039),
        new PIQ_Wrapper.attribute('PRODIQ002_TAG040', system.label.PRODIQ002_TAG040),
        new PIQ_Wrapper.attribute('PRODIQ002_TAG041', system.label.PRODIQ002_TAG041),
        new PIQ_Wrapper.attribute('PRODIQ002_TAG042', system.label.PRODIQ002_TAG042),
        new PIQ_Wrapper.attribute('PRODIQ002_TAG043', system.label.PRODIQ002_TAG043),
        new PIQ_Wrapper.attribute('PRODIQ002_TAG044', system.label.PRODIQ002_TAG044),
        new PIQ_Wrapper.attribute('PRODIQ002_TAG045', system.label.PRODIQ002_TAG045),
        new PIQ_Wrapper.attribute('PRODIQ002_TAG046', system.label.PRODIQ002_TAG046),
        new PIQ_Wrapper.attribute('PRODIQ002_TAG047', system.label.PRODIQ002_TAG047),
        new PIQ_Wrapper.attribute('PRODIQ002_TAG048', system.label.PRODIQ002_TAG048),
        new PIQ_Wrapper.attribute('PRODIQ002_TAG049', system.label.PRODIQ002_TAG049),
        new PIQ_Wrapper.attribute('PRODIQ002_TAG050', system.label.PRODIQ002_TAG050),
        new PIQ_Wrapper.attribute('PRODIQ002_TAG051', system.label.PRODIQ002_TAG051),
        new PIQ_Wrapper.attribute('PRODIQ002_TAG052', system.label.PRODIQ002_TAG052),
        new PIQ_Wrapper.attribute('PRODIQ002_TAG053', system.label.PRODIQ002_TAG053),
        new PIQ_Wrapper.attribute('PRODIQ002_TAG054', system.label.PRODIQ002_TAG054),
        new PIQ_Wrapper.attribute('PRODIQ002_TAG055', system.label.PRODIQ002_TAG055),
        new PIQ_Wrapper.attribute('PRODIQ002_TAG056', system.label.PRODIQ002_TAG056),
        new PIQ_Wrapper.attribute('PRODIQ002_TAG057', system.label.PRODIQ002_TAG057),
        new PIQ_Wrapper.attribute('PRODIQ002_TAG058', system.label.PRODIQ002_TAG058),
        new PIQ_Wrapper.attribute('PRODIQ002_TAG059', system.label.PRODIQ002_TAG059),
        new PIQ_Wrapper.attribute('PRODIQ002_TAG060', system.label.PRODIQ002_TAG060),
        new PIQ_Wrapper.attribute('PRODIQ002_TAG061', system.label.PRODIQ002_TAG061),
        new PIQ_Wrapper.attribute('PRODIQ002_TAG062', system.label.PRODIQ002_TAG062),
        new PIQ_Wrapper.attribute('PRODIQ002_TAG063', system.label.PRODIQ002_TAG063),
        new PIQ_Wrapper.attribute('PRODIQ002_TAG064', system.label.PRODIQ002_TAG064),
        new PIQ_Wrapper.attribute('PRODIQ002_TAG065', system.label.PRODIQ002_TAG065),
        new PIQ_Wrapper.attribute('PRODIQ002_TAG066', system.label.PRODIQ002_TAG066),
        new PIQ_Wrapper.attribute('PRODIQ002_TAG067', system.label.PRODIQ002_TAG067),
        new PIQ_Wrapper.attribute('PRODIQ002_TAG068', system.label.PRODIQ002_TAG068),
        new PIQ_Wrapper.attribute('PRODIQ002_TAG069', system.label.PRODIQ002_TAG069),
        new PIQ_Wrapper.attribute('PRODIQ002_TAG070', system.label.PRODIQ002_TAG070),
        new PIQ_Wrapper.attribute('PRODIQ002_TAG071', system.label.PRODIQ002_TAG071),
        new PIQ_Wrapper.attribute('PRODIQ002_TAG072', system.label.PRODIQ002_TAG072),
        new PIQ_Wrapper.attribute('PRODIQ002_TAG073', system.label.PRODIQ002_TAG073),
        new PIQ_Wrapper.attribute('PRODIQ002_TAG074', system.label.PRODIQ002_TAG074),
        new PIQ_Wrapper.attribute('PRODIQ002_TAG075', system.label.PRODIQ002_TAG075),
        
        
        //Using FCO tags
        new PIQ_Wrapper.attribute('FCO002_TAG014', system.label.FCO002_TAG014), //Save
        new PIQ_Wrapper.attribute('FCO003_TAG026', system.label.FCO003_TAG026), //Cancel
        new PIQ_Wrapper.attribute('FCO001_TAG008', system.label.FCO001_TAG008), //Contains
        new PIQ_Wrapper.attribute('FCO001_TAG011', system.label.FCO001_TAG011), //does not contain
        new PIQ_Wrapper.attribute('FCO001_TAG009', system.label.FCO001_TAG009), //is equal to
        new PIQ_Wrapper.attribute('FCO001_TAG010', system.label.FCO001_TAG010), //is not equal to
        new PIQ_Wrapper.attribute('FCO001_TAG017', system.label.FCO001_TAG017), //is greater than
        new PIQ_Wrapper.attribute('FCO001_TAG018', system.label.FCO001_TAG018), //is greater than or equal to
        new PIQ_Wrapper.attribute('FCO001_TAG019', system.label.FCO001_TAG019), //is less than
        new PIQ_Wrapper.attribute('FCO001_TAG020', system.label.FCO001_TAG020) //is lesser than or equal to
    };
}