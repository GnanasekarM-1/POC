/*****************************************************************************
 *                       Copyright (C) 2016 ServiceMax, Inc
 *                               All rights reserved
 *
 *****************************************************************************/

/**
 * The PIQ_TechAttributeHistoryServicesUtils class will provide all the necessary utility features for PIQ_TechAttributeHistoryServices controller
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
 *              Jeevika Rao            07 Jul 2020     Display History - Group by Attribute and group by IB record
 *****************************************************************************************************/

public with sharing class PIQ_TechAttributeHistoryServicesUtils {

    public static boolean isLimitReached = false;
    public static Map<String, String> ibNameByIdMap = new Map<String, String>();
    public PIQ_TechAttributeHistoryServicesUtils() {

    }

    public static String buildProductQueryFilter(list<PIQ_Wrapper.attribute> techAttributes){
        String response = '';
        for(PIQ_Wrapper.attribute techAttr: techAttributes){
            if(!String.isBlank(response))
                response += ' AND ';
            if(techAttr.key == PIQ_Constants.FILTER_PRODUCTNAME){
                if(!string.isBlank(techAttr.operator)){
                    if(techAttr.operator == PIQ_Constants.OPERATOR_EQUALTO){
                        response += 'SVMXC__SM_Installed_Product_id__r.SVMXC__Product__r.Name = \'' + techAttr.value + '\'';
                    }
                    else if(techAttr.operator == PIQ_Constants.OPERATOR_NOTQUALTO){
                        response += 'SVMXC__SM_Installed_Product_id__r.SVMXC__Product__r.Name != \'' + techAttr.value + '\'';
                    }
                    else if(techAttr.operator == PIQ_Constants.OPERATOR_GREATERTHAN){
                        response += 'SVMXC__SM_Installed_Product_id__r.SVMXC__Product__r.Name > \'' + techAttr.value + '\'';
                    }
                    else if(techAttr.operator == PIQ_Constants.OPERATOR_GREATERTHANEQUAL){
                        response += 'SVMXC__SM_Installed_Product_id__r.SVMXC__Product__r.Name >= \'' + techAttr.value + '\'';
                    }
                    else if(techAttr.operator == PIQ_Constants.OPERATOR_LESSTHAN){
                        response += 'SVMXC__SM_Installed_Product_id__r.SVMXC__Product__r.Name < \'' + techAttr.value + '\'';
                    }
                    else if(techAttr.operator == PIQ_Constants.OPERATOR_LESSTHANEQUAL){
                        response += 'SVMXC__SM_Installed_Product_id__r.SVMXC__Product__r.Name <= \'' + techAttr.value + '\'';
                    }
                    else if(techAttr.operator == PIQ_Constants.OPERATOR_CONTAINS){
                        response += 'SVMXC__SM_Installed_Product_id__r.SVMXC__Product__r.Name LIKE \'%' + techAttr.value + '%\'';
                    }
                    else if(techAttr.operator == PIQ_Constants.OPERATOR_NOTCONTAINS){
                        response += '(NOT SVMXC__SM_Installed_Product_id__r.SVMXC__Product__r.Name LIKE \'%' + techAttr.value + '%\')';
                    }
                }
            }
            else if(techAttr.key == PIQ_Constants.FILTER_PRODUCTLINE){
                if(!string.isBlank(techAttr.operator)){
                    if(techAttr.operator == PIQ_Constants.OPERATOR_EQUALTO){
                        response += 'SVMXC__SM_Installed_Product_id__r.SVMXC__Product__r.SVMXC__Product_Line__c = \'' + techAttr.value + '\'';
                    }
                    else if(techAttr.operator == PIQ_Constants.OPERATOR_NOTQUALTO){
                        response += 'SVMXC__SM_Installed_Product_id__r.SVMXC__Product__r.SVMXC__Product_Line__c != \'' + techAttr.value + '\'';
                    }
                    else if(techAttr.operator == PIQ_Constants.OPERATOR_GREATERTHAN){
                        response += 'SVMXC__SM_Installed_Product_id__r.SVMXC__Product__r.SVMXC__Product_Line__c > \'' + techAttr.value + '\'';
                    }
                    else if(techAttr.operator == PIQ_Constants.OPERATOR_GREATERTHANEQUAL){
                        response += 'SVMXC__SM_Installed_Product_id__r.SVMXC__Product__r.SVMXC__Product_Line__c >= \'' + techAttr.value + '\'';
                    }
                    else if(techAttr.operator == PIQ_Constants.OPERATOR_LESSTHAN){
                        response += 'SVMXC__SM_Installed_Product_id__r.SVMXC__Product__r.SVMXC__Product_Line__c < \'' + techAttr.value + '\'';
                    }
                    else if(techAttr.operator == PIQ_Constants.OPERATOR_LESSTHANEQUAL){
                        response += 'SVMXC__SM_Installed_Product_id__r.SVMXC__Product__r.SVMXC__Product_Line__c <= \'' + techAttr.value + '\'';
                    }
                    else if(techAttr.operator == PIQ_Constants.OPERATOR_CONTAINS){
                        response += 'SVMXC__SM_Installed_Product_id__r.SVMXC__Product__r.SVMXC__Product_Line__c LIKE \'%' + techAttr.value + '%\'';
                    }
                    else if(techAttr.operator == PIQ_Constants.OPERATOR_NOTCONTAINS){
                        response += '(NOT SVMXC__SM_Installed_Product_id__r.SVMXC__Product__r.SVMXC__Product_Line__c LIKE \'%' + techAttr.value + '%\')';
                    }
                }
            }
            else if(techAttr.key == PIQ_Constants.FILTER_PRODUCTFAMILY){
                if(!string.isBlank(techAttr.operator)){
                    if(techAttr.operator == PIQ_Constants.OPERATOR_EQUALTO){
                        response += 'SVMXC__SM_Installed_Product_id__r.SVMXC__Product__r.Family = \'' + techAttr.value + '\'';
                    }
                    else if(techAttr.operator == PIQ_Constants.OPERATOR_NOTQUALTO){
                        response += 'SVMXC__SM_Installed_Product_id__r.SVMXC__Product__r.Family != \'' + techAttr.value + '\'';
                    }
                    else if(techAttr.operator == PIQ_Constants.OPERATOR_GREATERTHAN){
                        response += 'SVMXC__SM_Installed_Product_id__r.SVMXC__Product__r.Family > \'' + techAttr.value + '\'';
                    }
                    else if(techAttr.operator == PIQ_Constants.OPERATOR_GREATERTHANEQUAL){
                        response += 'SVMXC__SM_Installed_Product_id__r.SVMXC__Product__r.Family >= \'' + techAttr.value + '\'';
                    }
                    else if(techAttr.operator == PIQ_Constants.OPERATOR_LESSTHAN){
                        response += 'SVMXC__SM_Installed_Product_id__r.SVMXC__Product__r.Family < \'' + techAttr.value + '\'';
                    }
                    else if(techAttr.operator == PIQ_Constants.OPERATOR_LESSTHANEQUAL){
                        response += 'SVMXC__SM_Installed_Product_id__r.SVMXC__Product__r.Family <= \'' + techAttr.value + '\'';
                    }
                    else if(techAttr.operator == PIQ_Constants.OPERATOR_CONTAINS){
                        response += 'SVMXC__SM_Installed_Product_id__r.SVMXC__Product__r.Family LIKE \'%' + techAttr.value + '%\'';
                    }
                    else if(techAttr.operator == PIQ_Constants.OPERATOR_NOTCONTAINS){
                        response += '(NOT SVMXC__SM_Installed_Product_id__r.SVMXC__Product__r.Family LIKE \'%' + techAttr.value + '%\')';
                    }
                }
            }
        }
        system.debug('response: ' + response);
        return response;
    }


    public static String buildAttributeQueryFilter(list<PIQ_Wrapper.attribute> techAttributes){
        String response = '';
        for(PIQ_Wrapper.attribute techAttr: techAttributes){
            if(!String.isBlank(response))
                response += ' OR ';
            if(!string.isBlank(techAttr.field) && !string.isBlank(techAttr.operator)){
                if(!String.isBlank(techAttr.type) && techAttr.type.equals('Number')){
                    if(techAttr.operator == PIQ_Constants.OPERATOR_EQUALTO || techAttr.operator == PIQ_Constants.OPERATOR_CONTAINS){
                        response += '(SVMXC__SM_Attr_Name__c = \'' + techAttr.field + '\' AND SVMXC__SM_Number_Value__c = ' + Decimal.valueOf(techAttr.value) + ')';
                    }
                    else if(techAttr.operator == PIQ_Constants.OPERATOR_NOTQUALTO || techAttr.operator == PIQ_Constants.OPERATOR_NOTCONTAINS){
                        response += '(SVMXC__SM_Attr_Name__c = \'' + techAttr.field + '\' AND SVMXC__SM_Number_Value__c != ' + Decimal.valueOf(techAttr.value) + ')';
                    }
                    else if(techAttr.operator == PIQ_Constants.OPERATOR_GREATERTHAN){
                        response += '(SVMXC__SM_Attr_Name__c = \'' + techAttr.field + '\' AND SVMXC__SM_Number_Value__c > ' + Decimal.valueOf(techAttr.value) + ')';
                    }
                    else if(techAttr.operator == PIQ_Constants.OPERATOR_GREATERTHANEQUAL){
                        response += '(SVMXC__SM_Attr_Name__c = \'' + techAttr.field + '\' AND SVMXC__SM_Number_Value__c >= ' + Decimal.valueOf(techAttr.value) + ')';
                    }
                    else if(techAttr.operator == PIQ_Constants.OPERATOR_LESSTHAN){
                        response += '(SVMXC__SM_Attr_Name__c = \'' + techAttr.field + '\' AND SVMXC__SM_Number_Value__c < ' + Decimal.valueOf(techAttr.value) + ')';
                    }
                    else if(techAttr.operator == PIQ_Constants.OPERATOR_LESSTHANEQUAL){
                        response += '(SVMXC__SM_Attr_Name__c = \'' + techAttr.field + '\' AND SVMXC__SM_Number_Value__c <= ' + Decimal.valueOf(techAttr.value) + ')';
                    }
                }
                else{
                    if(techAttr.operator == PIQ_Constants.OPERATOR_EQUALTO){
                        response += '(SVMXC__SM_Attr_Name__c = \'' + techAttr.field + '\' AND SVMXC__SM_Attr_Value__c = \'' + techAttr.value + '\')';
                    }
                    else if(techAttr.operator == PIQ_Constants.OPERATOR_NOTQUALTO){
                        response += '(SVMXC__SM_Attr_Name__c = \'' + techAttr.field + '\' AND SVMXC__SM_Attr_Value__c != \'' + techAttr.value + '\')';
                    }
                    else if(techAttr.operator == PIQ_Constants.OPERATOR_GREATERTHAN){
                        response += '(SVMXC__SM_Attr_Name__c = \'' + techAttr.field + '\' AND SVMXC__SM_Attr_Value__c > \'' + techAttr.value + '\')';
                    }
                    else if(techAttr.operator == PIQ_Constants.OPERATOR_GREATERTHANEQUAL){
                        response += '(SVMXC__SM_Attr_Name__c = \'' + techAttr.field + '\' AND SVMXC__SM_Attr_Value__c >= \'' + techAttr.value + '\')';
                    }
                    else if(techAttr.operator == PIQ_Constants.OPERATOR_LESSTHAN){
                        response += '(SVMXC__SM_Attr_Name__c = \'' + techAttr.field + '\' AND SVMXC__SM_Attr_Value__c < \'' + techAttr.value + '\')';
                    }
                    else if(techAttr.operator == PIQ_Constants.OPERATOR_LESSTHANEQUAL){
                        response += '(SVMXC__SM_Attr_Name__c = \'' + techAttr.field + '\' AND SVMXC__SM_Attr_Value__c <= \'' + techAttr.value + '\')';
                    }
                    else if(techAttr.operator == PIQ_Constants.OPERATOR_CONTAINS){
                        response += '(SVMXC__SM_Attr_Name__c = \'' + techAttr.field + '\' AND SVMXC__SM_Attr_Value__c LIKE \'%' + techAttr.value + '%\')';
                    }
                    else if(techAttr.operator == PIQ_Constants.OPERATOR_NOTCONTAINS){
                        response += '(SVMXC__SM_Attr_Name__c = \'' + techAttr.field + '\' AND (NOT SVMXC__SM_Attr_Value__c LIKE \'%' + techAttr.value + '%\'))';
                    }
                }

            }
        }

        if(!String.isBlank(response)){
            response = '( ' + response + ' )';
        }
        system.debug('response: ' + response);
        return response;
    }

    public static list<SVMXC__SM_IB_Technical_Attributes__c> findLatestTechAttribute(list<PIQ_Wrapper.attribute> techAttributes, string additionalFilter){
        list<SVMXC__SM_IB_Technical_Attributes__c> response = new list<SVMXC__SM_IB_Technical_Attributes__c>();
        String strQuery = 'Select Id, SVMXC__SM_Installed_Product_id__c from SVMXC__SM_IB_Technical_Attributes__c where ';

        //Check if the tech attribute is available as part of the request
        if(techAttributes != null && !techAttributes.isEmpty()){
            strQuery += buildAttributeQueryFilter(techAttributes);

            if(!String.isBlank(additionalFilter)){
                strQuery += ' AND (' + additionalFilter + ')';
            }
        }
        else if(!String.isBlank(additionalFilter)){
            //If technical attribute is not available and only additional filter is available
            strQuery += additionalFilter;
        }
        else{
            //This is get all IB, as we are not 
        }

        //Set the limit of the query result to 40000
        //Set the order of result to be fetched based on latest updated technical attribute
        strQuery += ' order by LastModifiedDate desc limit 40000';  

        system.debug('Execute this query: ' + strQuery);
        response = Database.query(strQuery);
        return response;
    }
    //Actual code implimentation for getting installed product for the given technical attribute
    public static PIQ_Wrapper.PIQ_Response getIBforAnyTechAttribute(list<PIQ_Wrapper.attribute> techAttributes, String additionalFilter){
        
        PIQ_Wrapper.PIQ_Response response = new PIQ_Wrapper.PIQ_Response();
        list<SVMXC__SM_IB_Technical_Attributes__c> lstTechAttributes = new list<SVMXC__SM_IB_Technical_Attributes__c>();
        response.success = false;
        
        lstTechAttributes = findLatestTechAttribute(techAttributes, additionalFilter);
        system.debug('lstTechAttributes: ' + lstTechAttributes);

        if(lstTechAttributes.size() == 40000){ 
            response.code = 'LIMITREACHED';
            response.message = system.label.PRODIQ002_TAG018 + ' ' + system.label.PRODIQ002_TAG020; 
        }

        set<Id> setInstalledBaseIds = new set<Id>();
        for(SVMXC__SM_IB_Technical_Attributes__c techAttrObj: lstTechAttributes){
            setInstalledBaseIds.add(techAttrObj.SVMXC__SM_Installed_Product_id__c);
        }

        if(!setInstalledBaseIds.isEmpty()){
            response.lstInstalledProducts = [select Id, Name, SVMXC__Serial_Lot_Number__c, SVMXC__Asset_Tag__c  from SVMXC__Installed_Product__c where id IN: setInstalledBaseIds LIMIT 10000];
        }

        response.success = true;
        system.debug(LoggingLevel.DEBUG,'Get Installed Base: ' + response);
        return response;
    }


    //Actual code implimentation for getting installed product for the given technical attribute
    public static PIQ_Wrapper.PIQ_Response getIBforAllTechAttribute(list<PIQ_Wrapper.attribute> techAttributes, String additionalFilter){
        
        PIQ_Wrapper.PIQ_Response response = new PIQ_Wrapper.PIQ_Response();
        list<SVMXC__SM_IB_Technical_Attributes__c> lstTechAttributes = new list<SVMXC__SM_IB_Technical_Attributes__c>();
        set<Id> setInstalledBaseIds = new set<Id>();

        response.success = false;
        
        if(techAttributes.size() > 5){
            response.message = PIQ_Constants.ERROR_MAXIMUMFILTERREACHED;
            return response;
        }
        boolean isFirstTime = true;
        for(PIQ_Wrapper.attribute techArribute: techAttributes){
            lstTechAttributes = new list<SVMXC__SM_IB_Technical_Attributes__c>();
            lstTechAttributes = findLatestTechAttribute(new list<PIQ_Wrapper.attribute>{techArribute}, additionalFilter);

            if(lstTechAttributes.size() == 0){
                setInstalledBaseIds = new set<Id>();
                break;
            }
            if(lstTechAttributes.size() == 40000){ 
                response.code = 'LIMITREACHED';
                response.message = system.label.PRODIQ002_TAG018 + ' ' + system.label.PRODIQ002_TAG020; 
            }

            if(isFirstTime){
                for(SVMXC__SM_IB_Technical_Attributes__c techAttrObj: lstTechAttributes){
                    setInstalledBaseIds.add(techAttrObj.SVMXC__SM_Installed_Product_id__c);
                }
                isFirstTime = false;
            }else{
                set<Id> setTempInstalledBaseIds = new set<Id>();
                for(SVMXC__SM_IB_Technical_Attributes__c techAttrObj: lstTechAttributes){
                    if(setInstalledBaseIds.contains(techAttrObj.SVMXC__SM_Installed_Product_id__c))
                        setTempInstalledBaseIds.add(techAttrObj.SVMXC__SM_Installed_Product_id__c);
                }
                
                if(setTempInstalledBaseIds.size() == 0){
                    setInstalledBaseIds = new set<Id>();
                    break;
                }
                else{
                    setInstalledBaseIds = setTempInstalledBaseIds;
                }
            }
            system.debug('setInstalledBaseIds: ' + setInstalledBaseIds);
        }

        if(!setInstalledBaseIds.isEmpty()){
            response.lstInstalledProducts = [select Id, Name, SVMXC__Serial_Lot_Number__c, SVMXC__Asset_Tag__c from SVMXC__Installed_Product__c where id IN: setInstalledBaseIds LIMIT 10000];
        }

        response.success = true;
        system.debug(LoggingLevel.DEBUG,'Get Installed Base: ' + response);
        return response;
    }

    //Get the available attribute based on the selected Installed Product
    public static list<PIQ_Wrapper.attribute> getAllAttributesforIB(list<Id> lstIBIds){

        list<PIQ_Wrapper.attribute> response = new list<PIQ_Wrapper.attribute>();
        list<SVMXC__SM_IB_Technical_Attributes__c> lstTechAttrLatestValues = [select SVMXC__SM_Attr_Name__c, SVMXC__SM_IsActive__c, SVMXC__SM_Type__c from SVMXC__SM_IB_Technical_Attributes__c where SVMXC__SM_Installed_Product_id__c IN :lstIBIds];
        set<String> setUniquePorperties = new set<String>();
        for(SVMXC__SM_IB_Technical_Attributes__c objTechAttr: lstTechAttrLatestValues){
            //If attribute already added than don't add it again
            if(!setUniquePorperties.contains(objTechAttr.SVMXC__SM_Attr_Name__c)){
                PIQ_Wrapper.attribute attrItem = new PIQ_Wrapper.attribute(objTechAttr.SVMXC__SM_Attr_Name__c, objTechAttr.SVMXC__SM_IsActive__c);
                if(String.isBlank(objTechAttr.SVMXC__SM_Type__c))
                    attrItem.type = 'Text';
                else
                    attrItem.type = objTechAttr.SVMXC__SM_Type__c;
                response.add(attrItem);
                setUniquePorperties.add(objTechAttr.SVMXC__SM_Attr_Name__c);
            }
        }
        return response;
    }

    public static map<Id, map<string, String>> getInstalledBaseforAttribute(list<Id> lstIBIds, list<String> fields){
        map<Id, map<string, String>> response = new map<Id, map<string, String>>();
        system.debug('fields: ' + fields);
        list<SVMXC__SM_IB_Technical_Attributes__c> lstIBTechAttribute = [Select id, SVMXC__SM_Installed_Product_id__c, SVMXC__SM_Attr_Name__c, SVMXC__SM_Attr_Value__c from SVMXC__SM_IB_Technical_Attributes__c where SVMXC__SM_Installed_Product_id__c IN :lstIBIds and SVMXC__SM_Attr_Name__c IN: fields];
        for(SVMXC__SM_IB_Technical_Attributes__c objAttribute: lstIBTechAttribute ){
            map<string, String> mapTechAttr = new map<string, String>();
            if(response.get(objAttribute.SVMXC__SM_Installed_Product_id__c) != null){
                mapTechAttr = response.get(objAttribute.SVMXC__SM_Installed_Product_id__c);
            }
            mapTechAttr.put(objAttribute.SVMXC__SM_Attr_Name__c, objAttribute.SVMXC__SM_Attr_Value__c);
            response.put(objAttribute.SVMXC__SM_Installed_Product_id__c, mapTechAttr);
        }
        
        return response;
    }

    /********Display History - Group By Attribute and Group by Record ******/


    //Common method to query history records as per dates provided and return Map< IB_AttributeLabel <CapturedOn Date, Attribute Value>>
    public static Map<String, Map <Datetime, String>> getIBHistoryByDate(List<Id> installedProdIds, List<String> attributeNames, String strStartDate, String strEndDate){
            
        integer queryLimit = 50000;
        Date startDate = date.Today() - 30; //consider 30 days window by default
        Date endDate = date.Today() + 1;  //Adding 1 because it considers 12AM on that date.

        if(!String.isBlank(strStartDate)  && !String.isBlank(strEndDate) ){
            startDate = Date.valueOf(strStartDate);
            endDate = Date.valueOf(strEndDate) + 1;
        }else if(String.isBlank(strStartDate) && !String.isBlank(strEndDate)){
            startDate = Date.valueOf(strEndDate) - 30; //Start date will be 30 before End date
            endDate = Date.valueOf(strEndDate) + 1;
        }else if( !String.isBlank(strStartDate) && String.isBlank(strEndDate)){
            startDate = Date.valueOf(strStartDate);
            endDate = Date.today() + 1;
        }
        
        List<SVMXC__SM_IB_Attributes_History__c> lstHistory = [select Id,SVMXC__SM_Attr_Payload__c, SVMXC__SM_Installed_Product_Id__c, SVMXC__SM_Installed_Product_Id__r.Name ,SVMXC__SM_Captured_On__c from SVMXC__SM_IB_Attributes_History__c
                                                            where SVMXC__SM_Installed_Product_Id__c IN: installedProdIds  
                                                            AND SVMXC__SM_Captured_On__c >=: startDate AND SVMXC__SM_Captured_On__c <=: endDate
                                                            AND SVMXC__SM_Attr_Type__c = 'TECHNICAL' 
                                                            ORDER BY SVMXC__SM_Captured_On__c DESC LIMIT :queryLimit];

        system.debug(LoggingLevel.Debug,'*** History records queried = '+lstHistory);

        if(lstHistory != NULL && lstHistory.size() == queryLimit){
            isLimitReached = true;
        }

        //<IB_AttrLabel < IB <Date captured on, value>>
        Map<String, Map <Datetime, String>> attributeValuePerIBMap = new Map<String, Map<Datetime, String>>();  //Map< IBId__AttributeLabel, <Captured On, attribute Value>
        for(SVMXC__SM_IB_Attributes_History__c eachHistory: lstHistory){  

            if(!ibNameByIdMap.containsKey(eachHistory.SVMXC__SM_Installed_Product_Id__c)){
                ibNameByIdMap.put(eachHistory.SVMXC__SM_Installed_Product_Id__c, eachHistory.SVMXC__SM_Installed_Product_Id__r.Name);
            }
            
            TechnicalAttributeConfiguration.IbInstancePayload ibInstancePayload = (TechnicalAttributeConfiguration.IbInstancePayload)JSON.deserialize(eachHistory.SVMXC__SM_Attr_Payload__c, TechnicalAttributeConfiguration.IbInstancePayload.class); //deserialize the payload
            
            if(ibInstancePayload.fields != null && !ibInstancePayload.fields.isEmpty()){
                for(TechnicalAttributeConfiguration.AttributesCategory category: ibInstancePayload.fields){
                    for(TechnicalAttributeConfiguration.Attribute attValue :category.technicalAttributes){
                        if(attributeNames.contains(attValue.label)){  //This attribute was selected in the previous page for display
                            String uniqueKey = eachHistory.SVMXC__SM_Installed_Product_Id__c + '__' + attValue.label;

                            if(!attributeValuePerIBMap.containsKey(uniqueKey)){
                                attributeValuePerIBMap.put(uniqueKey, new Map<Datetime, string>());
                            }
                            attributeValuePerIBMap.get(uniqueKey).put(eachHistory.SVMXC__SM_Captured_On__c, attValue.defaultValue);
                        }
                    }
                }
            }
        }
            
        system.debug('*** attributeValuePerIBMap = '+attributeValuePerIBMap);
        return attributeValuePerIBMap;
    }

    //Group By Attribute
    public static PIQ_Wrapper.PIQ_History_Response getHistoryByAttribute(List<Id> installedProdIds, List<String> attributeNames, String startDate, String endDate){
           
        /*
            Inputs are: Start date, End date, List of attribute names, List of IB Ids
            For the given dates and Ibs - get the history for selected list of attributes 
            Parse History JSON payload 
            Prepare response
        */

        PIQ_Wrapper.PIQ_History_Response response = new PIQ_Wrapper.PIQ_History_Response();
        try{
            
            Map<String, Map <Datetime, String>> attributeValuePerIBMap = getIBHistoryByDate(installedProdIds, attributeNames, startDate, endDate);

            if(isLimitReached){
                //Query limit has been reached - there may be more history records to be processed - set message in the response
                response.message = system.label.PRODIQ002_TAG018 + ' ' + system.label.PRODIQ002_TAG020; //Displaying most recent history records and values'
                response.code = 'LIMITREACHED';
            }

            Map<String, Map<String, Map<Datetime, String>>> valuePerIbPerAttributeMap = new Map<String, Map<String, Map<Datetime, String>>>(); //Map< AttributeName < IbId <datetime, Value>>>

            //process attributeValuePerIBMap and put it in the response structure
            for(String eachKey : attributeValuePerIBMap.keySet()){
                List<String> splitStr = eachKey.split('__');
                String ibID = splitStr[0];
                String attrLabel = splitStr[1];
                
                system.debug(LoggingLevel.Debug,'*** eachKey = '+eachKey);
                system.debug(LoggingLevel.Debug,'*** ibID = '+ibID);
                system.debug(LoggingLevel.Debug,'*** attrLabel = '+attrLabel);

                if(!valuePerIbPerAttributeMap.containsKey(attrLabel)){
                    valuePerIbPerAttributeMap.put(attrLabel, new Map<String, Map<Datetime, String>>());
                }
                if(!valuePerIbPerAttributeMap.get(attrLabel).containsKey(ibID)){
                    valuePerIbPerAttributeMap.get(attrLabel).put(ibID, new Map<Datetime, String>());
                }
                valuePerIbPerAttributeMap.get(attrLabel).get(ibID).putAll(attributeValuePerIBMap.get(eachKey));
            }
                
            system.debug(LoggingLevel.Debug,'*** Three level Map valuePerIbPerAttributeMap = '+valuePerIbPerAttributeMap);

            List<PIQ_Wrapper.HistoryWrapper> attributeHistoryList = new List<PIQ_Wrapper.HistoryWrapper>();
            for(String eachLabel: valuePerIbPerAttributeMap.KeySet() ){

                List<PIQ_Wrapper.IBWrapper> ibWrapperList = new List<PIQ_Wrapper.IBWrapper>();
                for(String eachIB: valuePerIbPerAttributeMap.get(eachLabel).KeySet()){
                    List<PIQ_Wrapper.AttributeCapturedOn> historyList = new List<PIQ_Wrapper.AttributeCapturedOn>();
                    for(Datetime capturedOn: valuePerIbPerAttributeMap.get(eachLabel).get(eachIB).KeySet()){
                        historyList.add(new PIQ_Wrapper.AttributeCapturedOn (String.ValueOf(capturedOn), valuePerIbPerAttributeMap.get(eachLabel).get(eachIB).get(capturedOn)));
                    }
                    ibWrapperList.add(new PIQ_Wrapper.IBWrapper(eachIB, ibNameByIdMap.get(eachIB), '', historyList));
                }

                attributeHistoryList.add(new PIQ_Wrapper.HistoryWrapper(eachLabel, '', '', ibWrapperList));
            }
            response.historyWrapperList = attributeHistoryList; 
            response.success = true;

        }catch(Exception ex){
            System.debug(LoggingLevel.WARN, 'Exception while retrieving history records for IBs ' + ex.getMessage());
            response.success = false;
            response.error = ex.getMessage();
        }
        system.debug(LoggingLevel.WARN, '*** response = '+response);
            
        return response;
    }

    //Group By Record
    public static PIQ_Wrapper.PIQ_History_Response getHistoryByIB(List<Id> installedProdIds, List<String> attributeNames, String startDate, String endDate){
        PIQ_Wrapper.PIQ_History_Response response = new PIQ_Wrapper.PIQ_History_Response();
        try{
            
            Map<String, Map <Datetime, String>> attributeValuePerIBMap = getIBHistoryByDate(installedProdIds, attributeNames, startDate, endDate);

            if(isLimitReached){
                //Query limit has been reached - there may be more history records to be processed - set message in the response
                response.message = system.label.PRODIQ002_TAG018 + ' ' + system.label.PRODIQ002_TAG020; // 'Displaying most recent history records and values'
                response.code = 'LIMITREACHED';
            }

            //Process and form response as per IB
            Map<String, Map<String, Map<Datetime, String>>> valuePerAttributePerIBMap = new Map<String, Map<String, Map<Datetime, String>>>(); //Map< IBId < AttributeName <datetime, Value>>>
            //process attributeValuePerIBMap and put it in the response structure
            for(String eachKey : attributeValuePerIBMap.keySet()){
                List<String> splitStr = eachKey.split('__');
                String ibID = splitStr[0];
                String attrLabel = splitStr[1];
                
                system.debug(LoggingLevel.Debug,'*** eachKey = '+eachKey);
                system.debug(LoggingLevel.Debug,'*** ibID = '+ibID);
                system.debug(LoggingLevel.Debug,'*** attrLabel = '+attrLabel);

                if(!valuePerAttributePerIBMap.containsKey(ibID)){
                    valuePerAttributePerIBMap.put(ibID, new Map<String, Map<Datetime, String>>());
                }
                if(!valuePerAttributePerIBMap.get(ibID).containsKey(attrLabel)){
                    valuePerAttributePerIBMap.get(ibID).put(attrLabel, new Map<Datetime, String>());
                }
                valuePerAttributePerIBMap.get(ibID).get(attrLabel).putAll(attributeValuePerIBMap.get(eachKey));
            }
                
            system.debug(LoggingLevel.Debug,'*** Three level Map valuePerAttributePerIBMap = '+valuePerAttributePerIBMap);

            List<PIQ_Wrapper.HistoryWrapper> attributeHistoryList = new List<PIQ_Wrapper.HistoryWrapper>();
            for(String eachIB: valuePerAttributePerIBMap.KeySet() ){

                List<PIQ_Wrapper.IBWrapper> ibWrapperList = new List<PIQ_Wrapper.IBWrapper>();
                for(String eachLabel: valuePerAttributePerIBMap.get(eachIB).KeySet()){
                    List<PIQ_Wrapper.AttributeCapturedOn> historyList = new List<PIQ_Wrapper.AttributeCapturedOn>();
                    for(Datetime capturedOn: valuePerAttributePerIBMap.get(eachIB).get(eachLabel).KeySet()){
                        historyList.add(new PIQ_Wrapper.AttributeCapturedOn (String.ValueOf(capturedOn), valuePerAttributePerIBMap.get(eachIB).get(eachLabel).get(capturedOn)));
                    }
                    ibWrapperList.add(new PIQ_Wrapper.IBWrapper('', '', eachLabel, historyList));
                }

                attributeHistoryList.add(new PIQ_Wrapper.HistoryWrapper('', eachIB, ibNameByIdMap.get(eachIB), ibWrapperList));
            }
            response.historyWrapperList = attributeHistoryList;
            response.success = true;

        }catch(Exception ex){
            System.debug(LoggingLevel.WARN, 'Exception while retrieving history records for IBs ' + ex.getMessage());
            response.success = false;
            response.error = ex.getMessage();
        }
        system.debug(LoggingLevel.WARN, '*** response = '+response);    
        return response;
    }



}