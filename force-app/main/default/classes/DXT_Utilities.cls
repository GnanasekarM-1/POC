public with sharing class DXT_Utilities 
{
    
    /*
        Global Variable declaration
    */
    public DXT_Console.EngineResponse objResponse = new DXT_Console.EngineResponse();
    public Map<String, Schema.DescribeSObjectResult> mapAPINameObjDesc = new Map<String, Schema.DescribeSObjectResult>();
    public Map<String, String> mapHeaderFieldType = new Map<String, String>();
    public Map<String, String> mapChildFieldType = new Map<String, String>();
    public string strLogger = '';
    public Savepoint sp;
    public String strNowDate = '';
    
    /*
        Constructor it describe all the objects
    */
    public DXT_Utilities()
    {
        try
        {
            Map<String, Schema.SObjectType> allObjs = Schema.getGlobalDescribe();
            if(allObjs.size() > 0)
            {
                for(String s : allObjs.keyset())
                {
                    Schema.DescribeSObjectResult objDesc = allObjs.get(s).getDescribe();
                    if(!mapAPINameObjDesc.containskey(objDesc.getName()))
                        mapAPINameObjDesc.put(objDesc.getName(),objDesc);
                }
            }
            Datetime objDateTime = System.now();
            strNowDate =  objDateTime.format('MM/dd/YYYY');
            
        }
        catch(Exception ex)
        {
            strLogger += '\n Exception comes in constructor : ' + ex.getMessage();
            System.debug(logginglevel.WARN, strLogger);
        }
    }
    /*
        Method to generate a IIF File string
        Input: DXT_Console.EngineRequest wrapper class instance
        Output: DXT_Console.EngineResponse wrapper class instance
    */
    public DXT_Console.EngineResponse generateIIFFile(DXT_Console.EngineRequest qbkDeliverReq)
    {
        //DXT_Console.EngineResponse objResponse = new DXT_Console.EngineResponse();
        String strFinalFileString = '';
        sp = Database.setSavepoint();
        try
        {
            objResponse.isSucess = true;
            //block to create to sort the TRANS Wrapper
            List<DXT_Console.TransactionWrapper> tempLstTRANSWrper = new List<DXT_Console.TransactionWrapper>();
            Map<Integer, DXT_Console.TransactionWrapper> mapIndexVsTRANSWrper = new Map<Integer, DXT_Console.TransactionWrapper>();
            strLogger += '\n before sort TRANS List : ' + qbkDeliverReq.lstTRANSWrapper;
            getSortWrapper(tempLstTRANSWrper, mapIndexVsTRANSWrper, qbkDeliverReq.lstTRANSWrapper);
            strLogger += '\n after sort TRANS List : ' + tempLstTRANSWrper;
            //block end
            
            //block to create to sort the SPL Wrapper
            List<DXT_Console.TransactionWrapper> tempLstSPLWrper = new List<DXT_Console.TransactionWrapper>();
            Map<Integer, DXT_Console.TransactionWrapper> mapIndexVsSPLWrper = new Map<Integer, DXT_Console.TransactionWrapper>();
            strLogger += '\n before sort SPL List : ' + qbkDeliverReq.lstSPLWrapper;
            getSortWrapper(tempLstSPLWrper, mapIndexVsSPLWrper, qbkDeliverReq.lstSPLWrapper);
            strLogger += '\n after sort TRANS List : ' + tempLstSPLWrper;
            //block end
            
            strLogger += '\n final string before TRANS Header : ' + strFinalFileString;
            strFinalFileString = strFinalFileString+genrateTransHeader(tempLstTRANSWrper, true);
            strLogger += '\n final string after TRANS Header : ' + strFinalFileString;
            //Creating Header for SPL
            strLogger += '\n final string before SPL Header : ' + strFinalFileString;
            strFinalFileString = strFinalFileString+genrateTransHeader(tempLstSPLWrper, false);
            strLogger += '\n final string after SPL Header : ' + strFinalFileString;
            //creating TRANS and SPL Lines
            strLogger += '\n final string before adding Transections : ' + strFinalFileString;
            strFinalFileString = strFinalFileString+genrateTransNSplLines(qbkDeliverReq, tempLstTRANSWrper, tempLstSPLWrper);
            strLogger += '\n final string after adding Transections : ' + strFinalFileString;
            if(objResponse.isSucess)
            {
                strLogger += '\n logger before source update.';
                doSourceUpdate(qbkDeliverReq);
                strLogger += '\n logger after source update.';
                if(qbkDeliverReq.isSendmail)
                {
                    strLogger += '\n logger before sending mail.';
                    sendMailIIFFile(strFinalFileString, qbkDeliverReq.strEmailId);
                    strLogger += '\n logger after sending mail.';
                }
                else
                {
                    String temp = strFinalFileString.replaceAll('\\n','~NEXTLINE~');
                    temp = temp.replaceAll('\\t','~NEXTTAB~');
                    objResponse.strMessage = temp;
                }
            }
            System.debug(logginglevel.WARN, 'printing logs : '+strLogger);
        }
        catch(Exception ex)
        {
            strLogger += '\n Exception comes generateIIFFile : ' + ex.getMessage();
            System.debug(logginglevel.WARN, 'printing logs : '+strLogger);
            System.debug('exception come in generateIIFFile: '+ex);
            objResponse.isSucess =  false;
            objResponse.strMessage =  ex.getMessage();
            Database.rollback(sp);
        }
        return objResponse;
    }
    /*
        Method responsible for source update
        Input: DXT_Console.EngineRequest wrapper class instance
    */
    private void doSourceUpdate(DXT_Console.EngineRequest qbkDeliverReq)
    {
        APL_Utils objAPLUtils = new APL_Utils();
        List<String> lstStrngIds = qbkDeliverReq.lstHeaderIds;
        List<SVMXC__ServiceMax_Config_Data__c> lstSourceUpdateCfgDta = new List<SVMXC__ServiceMax_Config_Data__c>();
        map<String,Schema.SObjectField> mapFldDesc = new map<String,Schema.SObjectField>();
        string strReqFields = '';
        for(DXT_Console.SourceUpdateWrapper objSoruceWrper : qbkDeliverReq.lstSourceUpdate)
        {
            SVMXC__ServiceMax_Config_Data__c objCfgDta = new SVMXC__ServiceMax_Config_Data__c();
            objCfgDta.SVMXC__Target_Field_Name__c = objSoruceWrper.field;
            objCfgDta.SVMXC__Action__c = objSoruceWrper.operator;
            objCfgDta.SVMXC__Display_Value__c = objSoruceWrper.value;
            lstSourceUpdateCfgDta.add(objCfgDta);
            strReqFields += objSoruceWrper.field + ', ';
            
        }
        System.debug(Logginglevel.WARN,'Fields to query for source update: ' + strReqFields);
        List<sObject> lstsObjectToUpdate = new List<sObject>();
        lstsObjectToUpdate = database.query('Select ' + strReqFields + 'Id From '+qbkDeliverReq.strHeaderObjeName+' where id IN: lstStrngIds');
        map<String,Schema.SObjectField> mapSchemaObject = mapAPINameObjDesc.get(qbkDeliverReq.strHeaderObjeName).fields.getMap();
        if(mapSchemaObject.size() > 0)
        {
            for(String strCurrField : mapSchemaObject.keyset())
            {
                mapFldDesc.put(mapSchemaObject.get(strCurrField).getDescribe().getName(),mapSchemaObject.get(strCurrField));
            }
        }
        
        System.debug(Logginglevel.WARN,'Records before source update util are: ' + lstsObjectToUpdate);
        lstsObjectToUpdate = objAPLUtils.DoSourceUpdate( lstsObjectToUpdate , lstSourceUpdateCfgDta, mapFldDesc);
        System.debug(Logginglevel.WARN,'Records after source update util are: ' + lstsObjectToUpdate);
        //Update lstsObjectToUpdate;
        if(COMM_SecurityUtils.getInstance().verifyFieldAccess(lstsObjectToUpdate, COMM_SecurityUtils.Access.Updateable)){
		    update lstsObjectToUpdate; //SDL-SVMX-CREATE-UPDATE-FLS-ENFORCED
		} else {
		    throw new COMM_SecurityUtils.SecurityAccessException( System.Label.COMM001_TAG142 );
		}
    }
    /*
        Method to create a IIF extension file from string and send mail to specific mail ID
        Input: String for IIF file and mail ID
    */
    private void sendMailIIFFile(String strFileEntries,String strEmail)
    {
        Messaging.EmailFileAttachment csvFile = new Messaging.EmailFileAttachment();
        blob csvBlob = Blob.valueOf(strFileEntries);
        string csvname= getTAG001()+strNowDate+'.iif';
        csvFile.setFileName(csvname);
        csvFile.setBody(csvBlob);
        Messaging.SingleEmailMessage email =new Messaging.SingleEmailMessage();
        String[] toAddresses = new list<string> {strEmail};
        String subject = getTAG002()+' '+strNowDate;
        email.setSubject(subject);
        email.setToAddresses( toAddresses );
        email.setPlainTextBody(getTAG003());
        email.setFileAttachments(new Messaging.EmailFileAttachment[]{csvFile});
        Messaging.SendEmailResult [] mainsend = Messaging.sendEmail(new Messaging.SingleEmailMessage[] {email});
    }
    /*
        Method to sort wrapper list
    */
    private void getSortWrapper(List<DXT_Console.TransactionWrapper> tempLstWrper, Map<Integer, DXT_Console.TransactionWrapper> mapIndexVslstWrper, List<DXT_Console.TransactionWrapper> lstWrapper)
    {
        List<Integer> lstInt = new List<Integer>();
        for(DXT_Console.TransactionWrapper objWrpr : lstWrapper)
        {
            mapIndexVslstWrper.put(Integer.valueOf(objWrpr.fieldSeq), objWrpr);
            lstInt.add(Integer.valueOf(objWrpr.fieldSeq));
        }
        lstInt.sort();
        for(Integer intObj : lstInt)
            tempLstWrper.add(mapIndexVslstWrper.get(intObj));
        lstInt.clear();
    }
    
    /*
        Method to generate Headers of the transaction
    */
    private String genrateTransHeader(List<DXT_Console.TransactionWrapper> tempLstWrper, boolean isTRANS)
    {
        String strTemp = '';
        if(isTRANS)
            strTemp = '!TRANS';
        else
            strTemp = '!SPL';
        for(DXT_Console.TransactionWrapper objWrper : tempLstWrper)
        {
            strTemp = strTemp+'\t'+objWrper.label;
        }
        strTemp = strTemp+'\n';
        return strTemp;
    }
    /*
        Method to check whether given field is reference field or not
    */
    private boolean isReferenceField(String strField)
    {
        system.debug('field for check reference : '+strField+'=== is referenced : '+strField.contains('.'));
        return strField.contains('.');
    }
    
    /*
        Method to get value of reference field from the given record
    */
    private String getreferenceFieldValue(sObject ObjsObject, String strReferenceField)
    {
        try{
            String strRefFld = strReferenceField.substringBefore('.');
            String strTail = strReferenceField.substringAfter('.');
            return String.valueOf(ObjsObject.getSObject(strRefFld).get(strTail));
        }catch(Exception ex)
        {
            strLogger += '\n Exception comes getreferenceFieldValue : ' + ex.getMessage();
            return '';
        }
        
    }
    /*
        Method to get value according to datatype defined
    */
    private String getValueDataType(String strDataType, String strValue, String isNegative)
    {
        String strReturn = '';
        if(strValue != null && strValue != '')
        {
            if(strDataType == 'INTEGER')
            {
                Pattern MyPattern = Pattern.compile('[^\\w\\d]');
                strValue  = MyPattern.matcher(strValue).replaceAll('');
                Pattern MyPattern2 = Pattern.compile('[a-zA-Z]');
                strReturn  = MyPattern2.matcher(strValue).replaceAll('');
                System.debug('created integer from string : '+strReturn);
            }else if(strDataType == 'DATETIME' || strDataType == 'DATE')
            {
                Datetime objDateTime = DateTime.valueOf(strValue);
                strReturn = objDateTime.format('MM/dd/YY');
            }else if(strDataType == 'CURRENCY')
            {
                if(Decimal.valueOf(strValue) != Decimal.valueOf(0))
                {
                    if(isNegative != null && isNegative == 'Yes')
                        strReturn = '-'+String.valueOf(strValue);
                    else
                        strReturn =  String.valueOf(strValue);
                }
                else
                    strReturn =  strValue;
            }
            else
                strReturn = strValue;
        }
        else
            strReturn = '';
        return strReturn;
    }
    /*
        Method to get value of reference field from the given record
    */
    private String getModifyedValue(String strValue, String valueType, String isNegative, String strDataType)
    {
        String strReturn = '';
        try
        {
            if(strDataType != null && strDataType != '')
            {
                strReturn = getValueDataType(strDataType, strValue, isNegative);
            }
            else
            {
                strReturn = getValueDataType(valueType, strValue, isNegative);
            }
        }
        catch(Exception ex)
        {
            strLogger += '\n Exception comes getModifyedValue : ' + ex.getMessage();
            objResponse.isSucess =  false;
            objResponse.strMessage =  ex.getMessage();
        }
        return strReturn;
    }
    /*
        Method to get transactions for TRANS and SPL Lines
    */
    private String genrateTransNSplLines(DXT_Console.EngineRequest qbkDeliverReq , List<DXT_Console.TransactionWrapper> lstTRANSWrapper, List<DXT_Console.TransactionWrapper> lstSPLWrapper)
    {
        String strTransection = '';
        try
        {
            Map<String, List<sObject>> mapHdrIdVsChildlst = new Map<String, List<sObject>>();
            List<sObject> lstHdrObj = new List<sObject>();
            lstHdrObj = getHeaderObjLst(qbkDeliverReq.lstHeaderIds, lstTRANSWrapper, qbkDeliverReq.strHeaderObjeName);
            strLogger += '\n header record list : ' + lstHdrObj;
            Set<String> setHeaderObjField = new Set<String>();
            Set<String> setChildObjField = new Set<String>();
            for(DXT_Console.TransactionWrapper objWrper : lstTRANSWrapper)
            {
                if(objWrper.valueType == 'field')
                setHeaderObjField.add(objWrper.value);
            }
            
            for(DXT_Console.TransactionWrapper objWrper : lstSPLWrapper)
            {
                if(objWrper.valueType == 'field')
                setChildObjField.add(objWrper.value);
            }
            
            
            mapHdrIdVsChildlst = getChildObjLst(qbkDeliverReq.lstHeaderIds, lstSPLWrapper, qbkDeliverReq.strHeaderObjeName, qbkDeliverReq.strChildObjName, setHeaderObjField, setChildObjField, qbkDeliverReq.strChildCriteriaId);
            strLogger += '\n child record list : ' + mapHdrIdVsChildlst;
            //code for creating transection
            
            Integer count = 1;
            strTransection = strTransection+'!ENDTRNS\n';
            for(sObject ObjsObject : lstHdrObj)
            {
                
                //for WO
                strTransection = strTransection+'TRNS';
                for(DXT_Console.TransactionWrapper objWrper : lstTRANSWrapper)
                {
                    if(objWrper.valueType == 'field')
                    {
                        if(isReferenceField(objWrper.value))
                            strTransection = strTransection+'\t'+getModifyedValue(getreferenceFieldValue(ObjsObject, objWrper.value), mapHeaderFieldType.get(objWrper.value), objWrper.isNeg, objWrper.dataType);
                        else
                            strTransection = strTransection+'\t'+getModifyedValue(String.valueOf(ObjsObject.get(objWrper.value)), mapHeaderFieldType.get(objWrper.value), objWrper.isNeg, objWrper.dataType);
                    }
                    else if(objWrper.valueType == 'constant')
                        strTransection = strTransection+'\t'+objWrper.value;
                    else if(objWrper.valueType == 'function')
                        strTransection = strTransection+'\t'+count;
                }
                strTransection = strTransection+'\n';
                
                //for WO Detail
                if(mapHdrIdVsChildlst.containsKey(String.valueOf(ObjsObject.get('Id'))))
                {
                    for(sObject ObjsObject2 : mapHdrIdVsChildlst.get(String.valueOf(ObjsObject.get('Id'))))
                    {
                        count++;
                        strTransection = strTransection+'SPL';
                        for(DXT_Console.TransactionWrapper objWrper : lstSPLWrapper)
                        {
                            if(objWrper.valueType == 'field')
                            {
                                if(isReferenceField(objWrper.value))
                                    strTransection = strTransection+'\t'+getModifyedValue(getreferenceFieldValue(ObjsObject2, objWrper.value), mapChildFieldType.get(objWrper.value), objWrper.isNeg, objWrper.dataType);
                                else
                                    strTransection = strTransection+'\t'+getModifyedValue(String.valueOf(ObjsObject2.get(objWrper.value)), mapChildFieldType.get(objWrper.value), objWrper.isNeg, objWrper.dataType);
                            }
                            else if(objWrper.valueType == 'constant')
                                strTransection = strTransection+'\t'+objWrper.value;
                            else if(objWrper.valueType == 'function')
                                strTransection = strTransection+'\t'+count;
                        }
                        strTransection = strTransection+'\n';
                    }
                }
                
                strTransection = strTransection+'ENDTRNS\n';
                
                count++;
            }
        }
        catch(Exception ex)
        {
            strLogger += '\n Exception comes genrateTransNSplLines : ' + ex.getMessage();
        }
        return strTransection;
    }
    /*
        Method to get the list of header records
    */
    private List<sObject> getHeaderObjLst(List<String> lstHedrIds, List<DXT_Console.TransactionWrapper> lstTRANSWrapper, String strHeaderObjName)
    {
        List<sObject> lstHdrObj = new List<sObject>();
        try
        {
            String strQuery = getStringQuery(lstTRANSWrapper);
            strQuery = strQuery+' from '+strHeaderObjName+' where Id IN: lstHedrIds';
            strLogger += '\n Query for header : ' + strQuery;
            
            lstHdrObj = Database.query(strQuery);
            strLogger += '\n list of header record after query : ' + lstHdrObj;
        }
        catch(Exception ex)
        {
            strLogger += '\n Exception comes getHeaderObjLst : ' + ex.getMessage();
            objResponse.isSucess =  false;
            objResponse.strMessage =  ex.getMessage();
        }
        return lstHdrObj;
    }
    /*
        Method to get the list of child records
    */
    private Map<String, List<sObject>>  getChildObjLst(List<String> lstHrdIds, List<DXT_Console.TransactionWrapper> lstSPLWrapper, String strHeaderObj, String strChildObj, Set<String> setHeaderObjField, Set<String> setChildObjField, String strChildCriteriaId)
    {
        Map<String, List<sObject>> mapHdrIdVsChildlst = new Map<String, List<sObject>>();
        try
        {
            String strQuery = getStringQuery(lstSPLWrapper);
            String strMasterObjFildName = getChildObjNameField(strHeaderObj, strChildObj, setChildObjField);
            getMapHeaderFildVsType(strHeaderObj, setHeaderObjField);
            if(strMasterObjFildName != null)
                if(!strQuery.contains(strMasterObjFildName))
                    strQuery = strQuery+','+strMasterObjFildName;
            strQuery = strQuery+' from '+strChildObj+' where '+strMasterObjFildName+' IN: lstHrdIds';
            //block for getting child object criteria
            if(strChildCriteriaId != null && strChildCriteriaId != '')
            {
                List<SVMXC__ServiceMax_Processes__c> lstSVMXRule = new List<SVMXC__ServiceMax_Processes__c>();
                lstSVMXRule =  [SELECT Id, SVMXC__Parent_Object_Criteria__c FROM SVMXC__ServiceMax_Processes__c WHERE SVMXC__Record_Type_Name__c = 'SVMX Rule' AND SVMXC__Rule_Type__c = 'Named Expression'  AND SVMXC__ProcessID__c =: strChildCriteriaId Limit 1]; //SDL-SVMX-FLS-NOT-ENFORCED-META-DATA
                System.debug(logginglevel.WARN, 'lstSVMXRule in  methodForDeserialize() method : '+lstSVMXRule);
                String strCriteria ='';
                if(lstSVMXRule.size() > 0)
                    strCriteria = lstSVMXRule[0].SVMXC__Parent_Object_Criteria__c;
                if(strCriteria != null && strCriteria != '')
                    strQuery = strQuery+' AND '+strCriteria;
            }
            //block end
            List<sObject> lstchildObj = new List<sObject>();
            
            strLogger += '\n Query for child : ' + strQuery;
            lstchildObj = Database.query(strQuery);
            
            for(sObject objSobject : lstchildObj)
            {
                if(!mapHdrIdVsChildlst.containsKey(String.valueOf(objSobject.get(strMasterObjFildName))))
                    mapHdrIdVsChildlst.put(String.valueOf(objSobject.get(strMasterObjFildName)), new List<sObject>());
                       mapHdrIdVsChildlst.get(String.valueOf(objSobject.get(strMasterObjFildName))).add(objSobject);
            } 
        }
        catch(Exception ex)
        {
            strLogger += '\n Exception comes getChildObjLst : ' + ex.getMessage();
            objResponse.isSucess =  false;
            objResponse.strMessage =  ex.getMessage();
        }
        return mapHdrIdVsChildlst;
    }
    
    /*
        Method to get the query from the list for fields wrapper
    */
    private String getStringQuery(List<DXT_Console.TransactionWrapper> lstWrapper)
    {
        String queryFields = '';
        try
        {
            queryFields = 'Select ';
            List<sObject> lstSObject = new List<sObject>();
            Set<String> setFields = new Set<String>();
            for(DXT_Console.TransactionWrapper objWrpr : lstWrapper)
            {
                if(objWrpr.valueType == 'field')
                {
                    setFields.add(objWrpr.value);
                }
                
            }
            if(setFields.contains(null))
                setFields.remove(null);
                
            if(!(setFields.contains('Id') || setFields.contains('ID')))
                setFields.add('Id');
            for(String strObj : setFields)
            {
                queryFields = queryFields+strObj+',';
            }
            
            queryFields = queryFields.removeEnd(','); 
        }
        catch(Exception ex)
        {
            strLogger += '\n Exception comes getStringQuery : ' + ex.getMessage();
            objResponse.isSucess =  false;
            objResponse.strMessage =  ex.getMessage();
        }
        return queryFields;
    }
    
    /*
        Method to get map for header field vs field type
    */
    private void getMapHeaderFildVsType(String strHeaderObj, Set<String> setHeaderObjField)
    {
        try
        {
            Map<String,Schema.SObjectField> objfieldMap = new Map<String,Schema.SObjectField>();
            objfieldMap = mapAPINameObjDesc.get(strHeaderObj).fields.getMap();
            for(String strkey2 : objfieldMap.keyset())
            {
                Schema.DescribeFieldResult schmDescFildRstl = objfieldMap.get(strkey2).getDescribe();
                if(setHeaderObjField.contains(schmDescFildRstl.getName()))
                {
                    if(schmDescFildRstl.getType()  == Schema.DisplayType.REFERENCE && schmDescFildRstl.isNamePointing() == false)
                    {
                        Map<String,Schema.SObjectField> objfieldMap1 = new Map<String,Schema.SObjectField>();
                        objfieldMap1 = mapAPINameObjDesc.get(schmDescFildRstl.getReferenceTo()[0].getDescribe().getName()).fields.getMap();
                        Set<String> setReletiveObjField = new Set<String>();
                        String relationName = schmDescFildRstl.getRelationshipName();
                        for(String strfieldval : setHeaderObjField)
                            if(strfieldval.contains(relationName))
                                setReletiveObjField.add(strfieldval.substringAfter('.'));
                        for(String strkey3 : objfieldMap1.keyset())
                        {
                            Schema.DescribeFieldResult schmDescFildRstl2 = objfieldMap.get(strkey3).getDescribe();
                            if(setReletiveObjField.contains(schmDescFildRstl2.getName()) && schmDescFildRstl2.getType() != Schema.DisplayType.REFERENCE)
                            {
                                mapHeaderFieldType.put(relationName+'.'+schmDescFildRstl2.getName(), String.valueOf(schmDescFildRstl2.getType()));
                            }
                        }
                    }
                    else
                    {
                        mapHeaderFieldType.put(schmDescFildRstl.getName(), String.valueOf(schmDescFildRstl.getType()));
                    }
                }
                
            }
        }
        catch(Exception ex)
        {
            strLogger += '\n Exception comes getMapHeaderFildVsType : ' + ex.getMessage();
            objResponse.isSucess =  false;
            objResponse.strMessage =  ex.getMessage();
        }
    }
    
    /*
        Method to get map for child field vs field type
    */
    private String getChildObjNameField(String strMasterObjName, String strChildObjName, Set<String> setChildObjField)
    {
        String strFieldName = '';
        try
        {
            Map<String,Schema.SObjectField> objfieldMap = new Map<String,Schema.SObjectField>();
            objfieldMap = mapAPINameObjDesc.get(strChildObjName).fields.getMap();
            for(String strkey2 : objfieldMap.keyset())
            {
                Schema.DescribeFieldResult schmDescFildRstl = objfieldMap.get(strkey2).getDescribe();
                if(schmDescFildRstl.getType()  == Schema.DisplayType.REFERENCE && schmDescFildRstl.isCascadeDelete() == true && schmDescFildRstl.isNamePointing() == false && schmDescFildRstl.getReferenceTo()[0].getDescribe().getName() == strMasterObjName)
                    strFieldName = schmDescFildRstl.getName();
                if(setChildObjField.contains(schmDescFildRstl.getName()))
                {
                    if(schmDescFildRstl.getType()  == Schema.DisplayType.REFERENCE && schmDescFildRstl.isNamePointing() == false)
                    {
                        Map<String,Schema.SObjectField> objfieldMap1 = new Map<String,Schema.SObjectField>();
                        objfieldMap1 = mapAPINameObjDesc.get(schmDescFildRstl.getReferenceTo()[0].getDescribe().getName()).fields.getMap();
                        Set<String> setReletiveObjField = new Set<String>();
                        String relationName = schmDescFildRstl.getRelationshipName();
                        for(String strfieldval : setChildObjField)
                            if(strfieldval.contains(relationName))
                                setReletiveObjField.add(strfieldval.substringAfter('.'));
                        for(String strkey3 : objfieldMap1.keyset())
                        {
                            Schema.DescribeFieldResult schmDescFildRstl2 = objfieldMap.get(strkey3).getDescribe();
                            if(setReletiveObjField.contains(schmDescFildRstl2.getName()) && schmDescFildRstl2.getType() != Schema.DisplayType.REFERENCE)
                            {
                                mapChildFieldType.put(relationName+'.'+schmDescFildRstl2.getName(), String.valueOf(schmDescFildRstl2.getType()));
                            }
                        }
                    }
                    else
                    {
                        mapChildFieldType.put(schmDescFildRstl.getName(), String.valueOf(schmDescFildRstl.getType()));
                    }
                }
                
            }
        }
        catch(Exception ex)
        {
            strLogger += '\n Exception comes getChildObjNameField : ' + ex.getMessage();
            objResponse.isSucess =  false;
            objResponse.strMessage =  ex.getMessage();
        }
        return strFieldName;
    }
    //custom labels
    public String getTAG001(){return System.label.DXT001_TAG011;}//QB_Export_
    public String getTAG002(){return System.label.DXT001_TAG012;}//Servicemax Work Orders - Exported on:
    public String getTAG003(){return System.label.DXT001_TAG013;}//Attached file contains Work Orders exported in QuickBooks format.
}