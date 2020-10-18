/*--------------------------------------------File Definition ----------------------*/
    /*This Class holding the service required to create initial counter reading for the qualified IBs.
    Created as part of Sum 15 Sprint 5 for PB-XRAY 107 requirement*/
/* Security Scanned */
    public with sharing class IPRD_CreateInitialCounterReading implements SVMXC.SFM_ScheduledBatchInterface{
        //Constructor
        public IPRD_CreateInitialCounterReading(){}
        
        //Override method of the interface contains logic to create initial counter reading
        public SVMXC.SFM_WrapperDef.SFM_Response executeService(SVMXC.SFM_WrapperDef.SFM_Request objRequest){
            List<SVMXC__Counter_Details__c> lstNewCounterReading = new List<SVMXC__Counter_Details__c>();
            SVMXC.SFM_WrapperDef.SFM_Response objResponse = new SVMXC.SFM_WrapperDef.SFM_Response();
            objResponse.StringLstMap = new List<SVMXC.SFM_WrapperDef.SFM_StringListMap>();
            objResponse.success = true;
            objResponse.message = '';
            try{
                if(objRequest != null && objRequest.stringListMap != null && objRequest.stringListMap.size()>0){
                    List<String> lstInstalledProductIds = new List<String>();
                    SVMXC.SFM_WrapperDef.SFM_StringListMap objStringListMap = objRequest.stringListMap[0];
                    if(objStringListMap != null && objStringListMap.key != null && objStringListMap.key.equalsIgnoreCase('RECORDIDS') && objStringListMap.valueList != null){
                        for(String strIBID : objStringListMap.valueList)
                            lstInstalledProductIds.add(strIBID);
                    }
                    if(lstInstalledProductIds.size()>0){
                        //SDL-SVMX-FLS-NOT-ENFORCED-META-DATA
                        RecordType CounterReadingRecordType = [SELECT Id FROM RecordType WHERE Name=:'Reading' and SobjectType=:'SVMXC__Counter_Details__c'];
                        //SDL-SVMX-FLS-NOT-ENFORCED-META-DATA
                        List<SVMXC__ServiceMax_Processes__c> lstAllCounterRule=[SELECT Id,Name,SVMXC__Sequence__c,SVMXC__Advance_Expression__c,SVMXC__Description__c,SVMXC__Name__c,SVMXC__Select__c FROM SVMXC__ServiceMax_Processes__c WHERE RecordType.Name='SVMX Rule' and SVMXC__Rule_Type__c='Counters' ORDER BY SVMXC__Sequence__c];
                        
                        Map<Id, List<SVMXC__ServiceMax_Config_Data__c>> mapCounterIdListOfExpression = new Map<Id, List<SVMXC__ServiceMax_Config_Data__c>>();
                        Map<Id,SVMXC__ServiceMax_Processes__c> mapRuleIdRuleRec = new Map<Id,SVMXC__ServiceMax_Processes__c>();
                        if(lstAllCounterRule.size()>0){
                            List<Id> lstCounterRuleId = new List<Id>();
                            for(SVMXC__ServiceMax_Processes__c objProcess:lstAllCounterRule){
                                lstCounterRuleId.add(objProcess.Id);
                                mapRuleIdRuleRec.put(objProcess.Id,objProcess);
                                mapCounterIdListOfExpression.put(objProcess.Id,new list<SVMXC__ServiceMax_Config_Data__c>());
                            }
                            //SDL-SVMX-FLS-NOT-ENFORCED-META-DATA
                            List<SVMXC__ServiceMax_Config_Data__c> lstCounterExpressions = [SELECT SVMXC__Sequence__c, SVMXC__Display_Type__c,SVMXC__Operator__c, SVMXC__Operand__c, SVMXC__Object_Name__c, SVMXC__Lookup_Field_API_Name__c, SVMXC__Field_Name__c, SVMXC__FKey_Name_Field__c, SVMXC__Expression_Type__c, SVMXC__Expression_Rule__c, RecordTypeId FROM SVMXC__ServiceMax_Config_Data__c WHERE SVMXC__Expression_Rule__c IN:lstCounterRuleId and SVMXC__Expression_Type__c='IPRD_Counters' and RecordType.Name='Expressions'];
                            for(SVMXC__ServiceMax_Config_Data__c objConfigExp:lstCounterExpressions){
                                if(mapCounterIdListOfExpression.containsKey(objConfigExp.SVMXC__Expression_Rule__c))
                                    mapCounterIdListOfExpression.get(objConfigExp.SVMXC__Expression_Rule__c).add(objConfigExp);
                            }
                        }
                        System.debug(LoggingLevel.DEBUG,'mapCounterIdListOfExpression : '+mapCounterIdListOfExpression);
                        
                        Map<String, Schema.SObjectField> installedProductfieldMap = Schema.SObjectType.SVMXC__Installed_Product__c.fields.getMap();
                        String installedProductFields = SVMX_getFieldNamesFromList(SVMX_getFieldList(installedProductfieldMap));
                        String sqlQuery = 'SELECT '+installedProductFields+' FROM SVMXC__Installed_Product__c WHERE Id IN: lstInstalledProductIds';
                        List<SVMXC__Installed_Product__c> lstInstalledProductTemp = Database.query(sqlQuery);
                        System.debug(LoggingLevel.DEBUG,'lstInstalledProductTemp : '+lstInstalledProductTemp);
                        
                        List<String> lstProductIds = new List<String>();
                        for(SVMXC__Installed_Product__c objIB: lstInstalledProductTemp)
                            lstProductIds.add(objIB.SVMXC__Product__c);
                        System.debug(LoggingLevel.DEBUG,'lstProductIds : '+lstProductIds);
                        
                        //Query all required product
                        Map<String, Schema.SObjectField> product2FieldMap = Schema.SObjectType.Product2.fields.getMap();
                        String product2Fields = SVMX_getFieldNamesFromList(SVMX_getFieldList(product2FieldMap));
                        sqlQuery = 'SELECT '+product2Fields+' FROM Product2 WHERE Id IN: lstProductIds';
                        List<Product2> lstProduct2 = Database.query(sqlQuery);
                        
                        //Query all required counter reading for each IB
                        List<SVMXC__Counter_Details__c> lstCounterReading = new List<SVMXC__Counter_Details__c>();
                        Map<String, List<SVMXC__Counter_Details__c>> mapIBidToListConuterDetail = new Map<String, List<SVMXC__Counter_Details__c>>();
                        String strRecordType='Reading';
                        lstCounterReading = Database.Query('SELECT Id,SVMXC__Counter_Name__c, SVMXC__Installed_Product__c, SVMXC__Counter_Definition__c,SVMXC__Counter_Reading__c,SVMXC__Counter_Type__c,SVMXC__Grows_Reduces_By__c,SVMXC__Min_Value__c,SVMXC__Max_Value__c,SVMXC__Active__c,SVMXC__Select__c,SVMXC__Counter_Rule__c,SVMXC__Counter_Rule__r.Name FROM SVMXC__Counter_Details__c WHERE SVMXC__Installed_Product__c IN: lstInstalledProductIds and RecordType.Name=:strRecordType');
                        for(SVMXC__Counter_Details__c objCounterDetail : lstCounterReading){
                            if(!mapIBidToListConuterDetail.containsKey(objCounterDetail.SVMXC__Installed_Product__c))
                                mapIBidToListConuterDetail.put(objCounterDetail.SVMXC__Installed_Product__c, new List<SVMXC__Counter_Details__c>());
                            mapIBidToListConuterDetail.get(objCounterDetail.SVMXC__Installed_Product__c).add(objCounterDetail);
                        }
                        System.debug(LoggingLevel.DEBUG,'mapIBidToListConuterDetail : '+mapIBidToListConuterDetail);
                        
                        //Query valid counter definition list for the installed product
                        Map<String,Product2> mapProductIdToProduct = new Map<String,Product2>();
                        for(Product2 objProduct2 : lstProduct2)
                            mapProductIdToProduct.put(objProduct2.Id,objProduct2);
                        System.debug(LoggingLevel.DEBUG,'mapProductIdToProduct : '+mapProductIdToProduct);
                        
                        COMM_Utils.COMM_ExpressionParsing objCommUtils = new COMM_Utils.COMM_ExpressionParsing();
                        List<Id> lstValidCounterRuleIds = new List<Id>();
                        Map<String, String> mapValidProductIdToCounterRuleId = objCommUtils.SVMX_ExpressionParsing(mapProductIdToProduct,mapCounterIdListOfExpression,mapRuleIdRuleRec); 
                        for(SVMXC__ServiceMax_Processes__c objProcess:lstAllCounterRule){
                            for(String product2Id : lstProductIds){
                                if(mapValidProductIdToCounterRuleId != null && mapValidProductIdToCounterRuleId.containsKey(product2Id) && mapValidProductIdToCounterRuleId.get(product2Id) == objProcess.Id)
                                    lstValidCounterRuleIds.add(objProcess.Id);
                            }
                        }
                        System.debug(LoggingLevel.DEBUG,'lstValidCounterRuleIds : '+lstValidCounterRuleIds);
                        
                        List<SVMXC__Counter_Details__c> lstCounterDefinition = [SELECT Id,SVMXC__Counter_Name__c,SVMXC__Counter_Definition__c,SVMXC__Counter_Reading__c,SVMXC__Counter_Rule__c,SVMXC__Counter_Type__c,SVMXC__Grows_Reduces_By__c,SVMXC__Min_Value__c,SVMXC__Max_Value__c,SVMXC__Active__c,SVMXC__Select__c FROM SVMXC__Counter_Details__c WHERE SVMXC__Counter_Rule__c IN:lstValidCounterRuleIds and SVMXC__Active__c=:true and RecordType.Name=:'Definition'];
                        System.debug(LoggingLevel.DEBUG,'lstCounterDefinition : '+lstCounterDefinition);
                        
                        for(SVMXC__Installed_Product__c objInstalledProduct: lstInstalledProductTemp){
                            String strInstalledProductId = objInstalledProduct.id;
                            String strProductId = objInstalledProduct.SVMXC__Product__c;
                            
                            //Querying counter detail records of Reading type for the current installed product
                            List<SVMXC__Counter_Details__c> lstCounterRec = new List<SVMXC__Counter_Details__c>();
                            if(mapIBidToListConuterDetail != null && mapIBidToListConuterDetail.size()>0 && mapIBidToListConuterDetail.containsKey(strInstalledProductId))
                                lstCounterRec = mapIBidToListConuterDetail.get(strInstalledProductId);
                            
                            if(lstCounterRec.size()>0 || lstAllCounterRule.size()>0){
                                List<SVMXC__Counter_Details__c> lstCounterReadingTemp = new List<SVMXC__Counter_Details__c>();
                                for(SVMXC__Counter_Details__c objCounterDetail : lstCounterRec){          
                                    lstCounterReadingTemp.add(objCounterDetail);
                                }
                                
                                Boolean isReadingExist = false;
                                for(SVMXC__Counter_Details__c objCounterDefinition : lstCounterDefinition){
                                    if(mapValidProductIdToCounterRuleId.get(strProductId) == objCounterDefinition.SVMXC__Counter_Rule__c){
                                        isReadingExist = false;
                                        for(SVMXC__Counter_Details__c objCounterReading : lstCounterReadingTemp){
                                            if(objCounterDefinition.Id== objCounterReading.SVMXC__Counter_Definition__c)
                                                isReadingExist = true;
                                        }
                                        if(!isReadingExist){
                                            SVMXC__Counter_Details__c objNewReading = new SVMXC__Counter_Details__c();
                                            objNewReading.RecordTypeId = CounterReadingRecordType.Id;
                                            objNewReading.SVMXC__Counter_Name__c = objCounterDefinition.SVMXC__Counter_Name__c;
                                            objNewReading.SVMXC__Counter_Type__c = objCounterDefinition.SVMXC__Counter_Type__c;
                                            objNewReading.SVMXC__Counter_Definition__c = objCounterDefinition.Id;
                                            //objNewReading.SVMXC__Min_Value__c = objCounterDefinition.SVMXC__Min_Value__c;
                                            //objNewReading.SVMXC__Max_Value__c = objCounterDefinition.SVMXC__Max_Value__c;
                                            objNewReading.SVMXC__Installed_Product__c = strInstalledProductId;
                                            objNewReading.SVMXC__Product__c = strProductId;
                                            objNewReading.SVMXC__Is_Latest__c = true;
                                            objNewReading.SVMXC__Reading_Date__c = System.Now();
                                            if(objCounterDefinition.SVMXC__Counter_Type__c == 'Increasing')
                                                objNewReading.SVMXC__Counter_Reading__c = objCounterDefinition.SVMXC__Min_Value__c;
                                            else if(objCounterDefinition.SVMXC__Counter_Type__c == 'Decreasing')
                                                objNewReading.SVMXC__Counter_Reading__c = objCounterDefinition.SVMXC__Max_Value__c;
                                            lstNewCounterReading.add(objNewReading);
                                            System.debug(LoggingLevel.DEBUG,'objNewReading : '+objNewReading);
                                        }  
                                    }     
                                }
                            }
                        }
                    }
                }
                if(lstNewCounterReading.size() > 0){
                    if(COMM_SecurityUtils.getInstance().verifyFieldAccess(lstNewCounterReading, COMM_SecurityUtils.Access.Createable)){
                    //SDL-SVMX-CREATE-UPDATE-FLS-ENFORCED
                    insert lstNewCounterReading;
                    }
                    else{
                    throw new COMM_SecurityUtils.SecurityAccessException( System.Label.COMM001_TAG142 );
                    }
                    
                    System.debug(LoggingLevel.INFO,'Insert Successful');
                    Map<String, List<String>> mapInstalledIdToReadingIDs = new Map<String, List<String>>();
                    for(SVMXC__Counter_Details__c objCD : lstNewCounterReading){
                        if(!mapInstalledIdToReadingIDs.containsKey(objCD.SVMXC__Installed_Product__c))
                            mapInstalledIdToReadingIDs.put(objCD.SVMXC__Installed_Product__c, new List<String>());
                        mapInstalledIdToReadingIDs.get(objCD.SVMXC__Installed_Product__c).add(objCD.id);
                    }
                    for(String key : mapInstalledIdToReadingIDs.keyset()){
                        SVMXC.SFM_WrapperDef.SFM_StringListMap tempObject = new SVMXC.SFM_WrapperDef.SFM_StringListMap(key, mapInstalledIdToReadingIDs.get(key));
                        objResponse.StringLstMap.add(tempObject);
                    }
                }
            }
            catch(System.DmlException e){
                objResponse.success = false;
                for (Integer i = 0; i < e.getNumDml(); i++) {
                    objResponse.message = objResponse.message + e.getDmlMessage(i) + ':-->';
                }
                System.debug(LoggingLevel.ERROR, 'DmlException in IPRD_CreateInitialCounterReading method: ' + objResponse.message);
            }
            catch(System.QueryException ex){
                objResponse.success = false;
                objResponse.message = ex.getMessage();
                System.debug(LoggingLevel.ERROR, 'QueryException in IPRD_CreateInitialCounterReading method: ' + ex.getMessage());
            }
            catch(Exception ex){
                objResponse.success = false;
                objResponse.message = ex.getMessage();
                System.debug(LoggingLevel.ERROR, 'Exception in IPRD_CreateInitialCounterReading method: ' + ex.getMessage());
            }
            System.debug(LoggingLevel.DEBUG, 'Response of IPRD_CreateInitialCounterReading method: ' + objResponse);
            return objResponse;
        }
        
        //Method to get list of API name of the fields by passing fieldMap of a particular object
        private List<String> SVMX_getFieldList( Map<String,Schema.SObjectField> fieldMap){
            List<String> lstFieldNames = new List<String>();
            if(fieldMap != null && fieldMap.size()>0){
                for(Schema.SObjectField objSobjectF : fieldMap.values()){
                    String strFieldName = objSobjectF.getDescribe().getName();
                    lstFieldNames.add(strFieldName);
                }
            }
            return lstFieldNames;
        }
        
        //Method to get string of field api name for the SOQL
        private String SVMX_getFieldNamesFromList(List<String> lstFieldNames) {
            String strFieldNameWithComma = '';
            if(lstFieldNames != null){
                for (String field : lstFieldNames) {
                    if (strFieldNameWithComma.length()>0)
                        strFieldNameWithComma += ',';
                    strFieldNameWithComma += field;
                }
            }
            return strFieldNameWithComma;
        }
    }