/* Security Scanned */
public with sharing class SFM_GetOperators {
    public SFM_getOperators ()
    {
        
    }
    public SFM_WrapperDef.SFM_Response SFM_GetOperatorsList(SFM_WrapperDef.SFM_Request prequest)
    {
        SFM_Utils utils = new SFM_Utils();
        SFM_WrapperDef.SFM_Response reponse = new SFM_WrapperDef.SFM_Response();
        SVMX_Constants constant = new SVMX_Constants();
        Boolean response_success;
        String response_message;
        List<SFM_WrapperDef.SFM_StringMap> options = new List<SFM_WrapperDef.SFM_StringMap>();
        Map<String,String> getOperatorType = null;
        List<SFM_WrapperDef.SFM_MapStringMap> lstOperVals = new List<SFM_WrapperDef.SFM_MapStringMap>();
                
        String orgConstant = SVMX_Constants.constSVMXConstant;
        try
        {           
            getOperatorType = utils.getStringMap(prequest.stringMap);
            String operatorType=getOperatorType.get('OPERATORTYPE').toUpperCase();
            String objectName = getOperatorType.get('OBJECTNAME');
            if(operatorType != null && operatorType.equals('ALL'))
            {
                Map<String, String> values = null;
                values = constant.getDateOptions();     
                for(String value:values.keySet())
                {
                    options.add(new SFM_WrapperDef.SFM_StringMap(orgConstant,values.get(value)));
                }
                lstOperVals.add(new SFM_WrapperDef.SFM_MapStringMap('DATE',options));
                options = new List<SFM_WrapperDef.SFM_StringMap>();
                values = constant.getDateTimeOptions();     
                for(String value:values.keySet())
                {
                    options.add(new SFM_WrapperDef.SFM_StringMap(orgConstant,values.get(value)));
                }
                lstOperVals.add(new SFM_WrapperDef.SFM_MapStringMap('DATETIME',options));
                options = new List<SFM_WrapperDef.SFM_StringMap>();
                values = constant.getUserOptions();                     
                for(String value:values.keySet())
                {
                    options.add(new SFM_WrapperDef.SFM_StringMap(orgConstant,values.get(value)));
                }
                lstOperVals.add(new SFM_WrapperDef.SFM_MapStringMap('USER',options));               
                if(objectName != null)
                {
                    options = new List<SFM_WrapperDef.SFM_StringMap>();
                    
                    List<RecordType> recTypes = [SELECT Id, Name, SobjectType  FROM RecordType where SobjectType = :objectName]; //SDL-SVMX-FLS-NOT-ENFORCED-META-DATA
                    for(RecordType value:recTypes)
                    {
                        options.add(new SFM_WrapperDef.SFM_StringMap(value.Id,value.Name));
                    }
                    lstOperVals.add(new SFM_WrapperDef.SFM_MapStringMap('RECORDTYPE',options));
                }
                lstOperVals.add(new SFM_WrapperDef.SFM_MapStringMap('EXPRESSION',getExpression()));
                lstOperVals.add(new SFM_WrapperDef.SFM_MapStringMap('SOURCEUPDATE',getSourceUpdate())); 
                
                
            }else if(operatorType != null && operatorType.equals('DATE'))
            {
                Map<String, String> values = new Map<String, String>();
                values = constant.getDateOptions();     
                for(String value:values.keySet())
                {
                    options.add(new SFM_WrapperDef.SFM_StringMap(orgConstant,values.get(value)));
                }
                lstOperVals.add(new SFM_WrapperDef.SFM_MapStringMap('DATE',options));               
            }else if(operatorType != null && operatorType.equals('DATETIME'))
            {
                Map<String, String> values = new Map<String, String>();
                values = constant.getDateTimeOptions(); 
                for(String value:values.keySet())
                {
                    options.add(new SFM_WrapperDef.SFM_StringMap(orgConstant,values.get(value)));
                }
                lstOperVals.add(new SFM_WrapperDef.SFM_MapStringMap('DATETIME',options));               
            }else if(operatorType != null && operatorType.equals('USER'))
            {
                Map<String, String> values = new Map<String, String>();
                values = constant.getUserOptions();
                for(String value:values.keySet())
                {
                    options.add(new SFM_WrapperDef.SFM_StringMap(orgConstant,values.get(value)));
                }
                lstOperVals.add(new SFM_WrapperDef.SFM_MapStringMap('USER',options));                   
            }else if(operatorType != null && operatorType.equals('RECORDTYPE'))
            {
                
                List<RecordType> recTypes = [SELECT Id, Name, SobjectType  FROM RecordType where SobjectType = :objectName]; //SDL-SVMX-FLS-NOT-ENFORCED-META-DATA
                for(RecordType value:recTypes)
                {
                    options.add(new SFM_WrapperDef.SFM_StringMap(value.Id,value.Name));
                }
                lstOperVals.add(new SFM_WrapperDef.SFM_MapStringMap('RECORDTYPE',options));         
            }else if(operatorType != null && operatorType.equals('SOURCEUPDATE'))
            {
                lstOperVals.add(new SFM_WrapperDef.SFM_MapStringMap('SOURCEUPDATE',getSourceUpdate()));         
            }else if(operatorType != null && operatorType.equals('EXPRESSION'))
            {
                lstOperVals.add(new SFM_WrapperDef.SFM_MapStringMap('EXPRESSION',getExpression()));         
            }
            
            reponse.setMapStringMap(lstOperVals);
            reponse.success = true;         
            
        }catch(Exception ex)
        {
            reponse.success = false;
            reponse.message = ex.getmessage();
        }
        return reponse;
    }
    
    private List<SFM_WrapperDef.SFM_StringMap> getSourceUpdate()
    {
        List<SFM_WrapperDef.SFM_StringMap> options = new List<SFM_WrapperDef.SFM_StringMap>();
        options.add(new SFM_WrapperDef.SFM_StringMap('Increase',System.Label.SFM001_TAG160));//Increase
        options.add(new SFM_WrapperDef.SFM_StringMap('Decrease',System.Label.SFM001_TAG161));//Decrease
        options.add(new SFM_WrapperDef.SFM_StringMap('eq',System.Label.SFM001_TAG159));//Set
        return options;
    }
    private List<SFM_WrapperDef.SFM_StringMap> getExpression()
    {
        List<SFM_WrapperDef.SFM_StringMap> options = new List<SFM_WrapperDef.SFM_StringMap>();
        options.add(new SFM_WrapperDef.SFM_StringMap('eq', System.Label.SFM001_TAG187));// 'Equals'));
        options.add(new SFM_WrapperDef.SFM_StringMap('ne', System.Label.SFM001_TAG188));//'Not Equal'));
        options.add(new SFM_WrapperDef.SFM_StringMap('gt', System.Label.SFM001_TAG189));//'Greater Than'));
        options.add(new SFM_WrapperDef.SFM_StringMap('ge', System.Label.SFM001_TAG190));//'Greater or Equal To'));
        options.add(new SFM_WrapperDef.SFM_StringMap('lt', System.Label.SFM001_TAG191));//'Less Than'));
        options.add(new SFM_WrapperDef.SFM_StringMap('le', System.Label.SFM001_TAG192));//'Less or Equal To'));
        options.add(new SFM_WrapperDef.SFM_StringMap('starts', System.Label.SFM001_TAG193));//'Starts With'));
        options.add(new SFM_WrapperDef.SFM_StringMap('contains', System.Label.SFM001_TAG194));//'Contains'));
        options.add(new SFM_WrapperDef.SFM_StringMap('notcontain', System.Label.SFM001_TAG195));//'Does Not Contain'));
        options.add(new SFM_WrapperDef.SFM_StringMap('in', System.Label.SFM001_TAG196));//'Includes'));
        options.add(new SFM_WrapperDef.SFM_StringMap('notin', System.Label.SFM001_TAG197));//'Excludes'));
        options.add(new SFM_WrapperDef.SFM_StringMap('isnull', System.Label.COMM002_TAG022));//'Null'));
        options.add(new SFM_WrapperDef.SFM_StringMap('isnotnull', System.Label.COMM002_TAG023));//'Is not Null'));
        return options;
    }
    
    //Method to get operator based on field's data type
    public SFM_WrapperDef.SFM_Response SFM_GetExpressionOperators(SFM_WrapperDef.SFM_Request prequest)
    {
        SFM_WrapperDef.SFM_Response objSFMResp = new SFM_WrapperDef.SFM_Response();
        objSFMResp.stringMap = new List<SFM_WrapperDef.SFM_StringMap>();
        objSFMResp.MapStringMap = new List<SFM_WrapperDef.SFM_MapStringMap>();
        objSFMResp.success = true;

        try
        {
            objSFMResp = getDataTypeVsOperatorType(objSFMResp); //Get Data type Vs Operator type Information
            
            String strOperatorType = new SFM_Utils().getStringMap(prequest.stringMap).get('OPERATORTYPE');
            if(strOperatorType != NULL && strOperatorType.toUpperCase() == 'ALL')
            {
                objSFMResp.MapStringMap.add(new SFM_WrapperDef.SFM_MapStringMap('EXPRESSION',getExpression()));
                objSFMResp.MapStringMap.add(new SFM_WrapperDef.SFM_MapStringMap('SOURCEUPDATE', getSourceUpdate()));
                objSFMResp.MapStringMap.add(new SFM_WrapperDef.SFM_MapStringMap('ID', getIdOperators()));
                objSFMResp.MapStringMap.add(new SFM_WrapperDef.SFM_MapStringMap('STRING', getStringOperators()));
                objSFMResp.MapStringMap.add(new SFM_WrapperDef.SFM_MapStringMap('BOOLEAN', getBooleanOperators()));
                objSFMResp.MapStringMap.add(new SFM_WrapperDef.SFM_MapStringMap('NUMERIC', getNumericOperators()));
                objSFMResp.MapStringMap.add(new SFM_WrapperDef.SFM_MapStringMap('DATETIME', getDateTimeOperators()));
                objSFMResp.MapStringMap.add(new SFM_WrapperDef.SFM_MapStringMap('MULTIPICKLIST', getMultipicklistOperators()));
                objSFMResp.MapStringMap.add(new SFM_WrapperDef.SFM_MapStringMap('TEXTAREA', getTextAreaOperators()));
            }
            else if(strOperatorType != NULL && strOperatorType.toUpperCase() == 'SOURCEUPDATE')
                objSFMResp.MapStringMap.add(new SFM_WrapperDef.SFM_MapStringMap('SOURCEUPDATE', getSourceUpdate()));
            else if(strOperatorType != NULL && strOperatorType.toUpperCase() == 'ID')
                objSFMResp.MapStringMap.add(new SFM_WrapperDef.SFM_MapStringMap('ID', getIdOperators()));
            else if(strOperatorType != NULL && strOperatorType.toUpperCase() == 'STRING')
                objSFMResp.MapStringMap.add(new SFM_WrapperDef.SFM_MapStringMap('STRING', getStringOperators()));
            else if(strOperatorType != NULL && strOperatorType.toUpperCase() == 'BOOLEAN')
                objSFMResp.MapStringMap.add(new SFM_WrapperDef.SFM_MapStringMap('BOOLEAN', getBooleanOperators()));
            else if(strOperatorType != NULL && strOperatorType.toUpperCase() == 'NUMERIC')
                objSFMResp.MapStringMap.add(new SFM_WrapperDef.SFM_MapStringMap('NUMERIC', getNumericOperators()));
            else if(strOperatorType != NULL && strOperatorType.toUpperCase() == 'DATETIME')
                objSFMResp.MapStringMap.add(new SFM_WrapperDef.SFM_MapStringMap('DATETIME', getDateTimeOperators()));
            else if(strOperatorType != NULL && strOperatorType.toUpperCase() == 'MULTIPICKLIST')
                objSFMResp.MapStringMap.add(new SFM_WrapperDef.SFM_MapStringMap('MULTIPICKLIST', getMultipicklistOperators()));
            else if(strOperatorType != NULL && strOperatorType.toUpperCase() == 'TEXTAREA')
                objSFMResp.MapStringMap.add(new SFM_WrapperDef.SFM_MapStringMap('TEXTAREA', getTextAreaOperators()));   
            else
                objSFMResp.MapStringMap.add(new SFM_WrapperDef.SFM_MapStringMap('EXPRESSION',getExpression()));
        }
        catch(Exception ex)
        {
            objSFMResp.success = false;
            objSFMResp.message = ex.getmessage();
        }
        return objSFMResp;
    }
    
    private SFM_WrapperDef.SFM_Response getDataTypeVsOperatorType(SFM_WrapperDef.SFM_Response objSFMResp)
    {
        objSFMResp.stringMap = new List<SFM_WrapperDef.SFM_StringMap>();
        objSFMResp.stringMap.add(new SFM_WrapperDef.SFM_StringMap('STRING', 'STRING'));
        objSFMResp.stringMap.add(new SFM_WrapperDef.SFM_StringMap('TEXTAREA', 'TEXTAREA'));
        objSFMResp.stringMap.add(new SFM_WrapperDef.SFM_StringMap('URL', 'STRING'));
        objSFMResp.stringMap.add(new SFM_WrapperDef.SFM_StringMap('EMAIL', 'STRING'));
        objSFMResp.stringMap.add(new SFM_WrapperDef.SFM_StringMap('PHONE', 'STRING'));
        objSFMResp.stringMap.add(new SFM_WrapperDef.SFM_StringMap('PICKLIST', 'STRING'));
        objSFMResp.stringMap.add(new SFM_WrapperDef.SFM_StringMap('REFERENCE', 'STRING'));
        objSFMResp.stringMap.add(new SFM_WrapperDef.SFM_StringMap('COMBOBOX', 'STRING'));
        objSFMResp.stringMap.add(new SFM_WrapperDef.SFM_StringMap('MULTIPICKLIST', 'MULTIPICKLIST'));
        objSFMResp.stringMap.add(new SFM_WrapperDef.SFM_StringMap('INTEGER', 'NUMERIC'));
        objSFMResp.stringMap.add(new SFM_WrapperDef.SFM_StringMap('DOUBLE', 'NUMERIC'));
        objSFMResp.stringMap.add(new SFM_WrapperDef.SFM_StringMap('PERCENT', 'NUMERIC'));
        objSFMResp.stringMap.add(new SFM_WrapperDef.SFM_StringMap('CURRENCY', 'NUMERIC'));
        objSFMResp.stringMap.add(new SFM_WrapperDef.SFM_StringMap('BOOLEAN', 'BOOLEAN'));
        objSFMResp.stringMap.add(new SFM_WrapperDef.SFM_StringMap('DATE', 'DATETIME'));
        objSFMResp.stringMap.add(new SFM_WrapperDef.SFM_StringMap('DATETIME', 'DATETIME'));
        objSFMResp.stringMap.add(new SFM_WrapperDef.SFM_StringMap('ID', 'ID'));
        return objSFMResp;
    }
    
    private List<SFM_WrapperDef.SFM_StringMap> getStringOperators()
    {
        List<SFM_WrapperDef.SFM_StringMap> options = new List<SFM_WrapperDef.SFM_StringMap>();
        options.add(new SFM_WrapperDef.SFM_StringMap('eq', System.Label.SFM001_TAG187));// 'Equals'));
        options.add(new SFM_WrapperDef.SFM_StringMap('ne', System.Label.SFM001_TAG188));//'Not Equal'));
        options.add(new SFM_WrapperDef.SFM_StringMap('gt', System.Label.SFM001_TAG189));//'Greater Than'));
        options.add(new SFM_WrapperDef.SFM_StringMap('ge', System.Label.SFM001_TAG190));//'Greater or Equal To'));
        options.add(new SFM_WrapperDef.SFM_StringMap('lt', System.Label.SFM001_TAG191));//'Less Than'));
        options.add(new SFM_WrapperDef.SFM_StringMap('le', System.Label.SFM001_TAG192));//'Less or Equal To'));
        options.add(new SFM_WrapperDef.SFM_StringMap('starts', System.Label.SFM001_TAG193));//'Starts With'));
        options.add(new SFM_WrapperDef.SFM_StringMap('contains', System.Label.SFM001_TAG194));//'Contains'));
        options.add(new SFM_WrapperDef.SFM_StringMap('notcontain', System.Label.SFM001_TAG195));//'Does Not Contain'));
        options.add(new SFM_WrapperDef.SFM_StringMap('isnull', System.Label.COMM002_TAG022));//'Null'));
        options.add(new SFM_WrapperDef.SFM_StringMap('isnotnull', System.Label.COMM002_TAG023));//'Is not Null'));
        return options;
    }
    private List<SFM_WrapperDef.SFM_StringMap> getTextAreaOperators(){
        
        list<SFM_WrapperDef.SFM_StringMap> options = new list<SFM_WrapperDef.SFM_StringMap>();
        options.add(new SFM_WrapperDef.SFM_StringMap('isnull', System.Label.COMM002_TAG022));//'Null'));
        options.add(new SFM_WrapperDef.SFM_StringMap('isnotnull', System.Label.COMM002_TAG023));//'Is not Null'));
        return options;
    }
    private List<SFM_WrapperDef.SFM_StringMap> getNumericOperators()
    {
        List<SFM_WrapperDef.SFM_StringMap> options = new List<SFM_WrapperDef.SFM_StringMap>();
        options.add(new SFM_WrapperDef.SFM_StringMap('eq', System.Label.SFM001_TAG187));// 'Equals'
        options.add(new SFM_WrapperDef.SFM_StringMap('ne', System.Label.SFM001_TAG188));//'Not Equal'
        options.add(new SFM_WrapperDef.SFM_StringMap('gt', System.Label.SFM001_TAG189));//'Greater Than'
        options.add(new SFM_WrapperDef.SFM_StringMap('ge', System.Label.SFM001_TAG190));//'Greater or Equal To'
        options.add(new SFM_WrapperDef.SFM_StringMap('lt', System.Label.SFM001_TAG191));//'Less Than'
        options.add(new SFM_WrapperDef.SFM_StringMap('le', System.Label.SFM001_TAG192));//'Less or Equal To'
        options.add(new SFM_WrapperDef.SFM_StringMap('isnull', System.Label.COMM002_TAG022));//'Null'
        options.add(new SFM_WrapperDef.SFM_StringMap('isnotnull', System.Label.COMM002_TAG023));//'Is not Null'
        return options;
    }
    
    private List<SFM_WrapperDef.SFM_StringMap> getDateTimeOperators()
    {
        List<SFM_WrapperDef.SFM_StringMap> options = new List<SFM_WrapperDef.SFM_StringMap>();
        options.add(new SFM_WrapperDef.SFM_StringMap('eq', System.Label.SFM001_TAG187));// 'Equals'
        options.add(new SFM_WrapperDef.SFM_StringMap('ne', System.Label.SFM001_TAG188));//'Not Equal'
        options.add(new SFM_WrapperDef.SFM_StringMap('gt', System.Label.SFM001_TAG189));//'Greater Than'
        options.add(new SFM_WrapperDef.SFM_StringMap('ge', System.Label.SFM001_TAG190));//'Greater or Equal To'
        options.add(new SFM_WrapperDef.SFM_StringMap('lt', System.Label.SFM001_TAG191));//'Less Than'
        options.add(new SFM_WrapperDef.SFM_StringMap('le', System.Label.SFM001_TAG192));//'Less or Equal To'
        options.add(new SFM_WrapperDef.SFM_StringMap('isnull', System.Label.COMM002_TAG022));//'Null'
        options.add(new SFM_WrapperDef.SFM_StringMap('isnotnull', System.Label.COMM002_TAG023));//'Is not Null'
        return options;
    }
    
    private List<SFM_WrapperDef.SFM_StringMap> getIdOperators()
    {
        List<SFM_WrapperDef.SFM_StringMap> options = new List<SFM_WrapperDef.SFM_StringMap>();
        options.add(new SFM_WrapperDef.SFM_StringMap('eq', System.Label.SFM001_TAG187));// 'Equals'
        options.add(new SFM_WrapperDef.SFM_StringMap('ne', System.Label.SFM001_TAG188));//'Not Equal'
        options.add(new SFM_WrapperDef.SFM_StringMap('isnull', System.Label.COMM002_TAG022));//'Null'
        options.add(new SFM_WrapperDef.SFM_StringMap('isnotnull', System.Label.COMM002_TAG023));//'Is not Null'
        return options;
    }
    
    private List<SFM_WrapperDef.SFM_StringMap> getBooleanOperators()
    {
        List<SFM_WrapperDef.SFM_StringMap> options = new List<SFM_WrapperDef.SFM_StringMap>();
        options.add(new SFM_WrapperDef.SFM_StringMap('eq', System.Label.SFM001_TAG187));// 'Equals'
        options.add(new SFM_WrapperDef.SFM_StringMap('ne', System.Label.SFM001_TAG188));//'Not Equal'
        return options;
    }
    
    private List<SFM_WrapperDef.SFM_StringMap> getMultipicklistOperators()
    {
        List<SFM_WrapperDef.SFM_StringMap> options = new List<SFM_WrapperDef.SFM_StringMap>();
        options.add(new SFM_WrapperDef.SFM_StringMap('eq', System.Label.SFM001_TAG187));// 'Equals'
        options.add(new SFM_WrapperDef.SFM_StringMap('ne', System.Label.SFM001_TAG188));//'Not Equal'
        options.add(new SFM_WrapperDef.SFM_StringMap('isnull', System.Label.COMM002_TAG022));//'Null'
        options.add(new SFM_WrapperDef.SFM_StringMap('isnotnull', System.Label.COMM002_TAG023));//'Is not Null'
        options.add(new SFM_WrapperDef.SFM_StringMap('in', System.Label.SFM001_TAG196));//'Includes'));
        options.add(new SFM_WrapperDef.SFM_StringMap('notin', System.Label.SFM001_TAG197));//'Excludes'));
        return options;
    }
    
    //Method to get all literals for date, datetime, Recordtype, User etc
    public SFM_WrapperDef.SFM_Response SFM_GetConstants(SFM_WrapperDef.SFM_Request prequest)
    {
        SFM_WrapperDef.SFM_Response objSFMResp = new SFM_WrapperDef.SFM_Response();
        objSFMResp.MapStringMap = new List<SFM_WrapperDef.SFM_MapStringMap>();
        objSFMResp.success = true;
        
        List<SFM_WrapperDef.SFM_StringMap> lstStrMapForDate = new List<SFM_WrapperDef.SFM_StringMap>();
        List<SFM_WrapperDef.SFM_StringMap> lstStrMapForDateTime = new List<SFM_WrapperDef.SFM_StringMap>();
        List<SFM_WrapperDef.SFM_StringMap> lstStrMapForUser = new List<SFM_WrapperDef.SFM_StringMap>();
        List<SFM_WrapperDef.SFM_StringMap> lstStrMapForSite = new List<SFM_WrapperDef.SFM_StringMap>();
        List<SFM_WrapperDef.SFM_StringMap> lstStrMapForSetting = new List<SFM_WrapperDef.SFM_StringMap>();
        List<SFM_WrapperDef.SFM_StringMap> lstStrMapForRecType = new List<SFM_WrapperDef.SFM_StringMap>();
        List<SFM_WrapperDef.SFM_StringMap> lstStrMapgeoLocation = new List<SFM_WrapperDef.SFM_StringMap>(); //Added for BAC-4676
        Map<String, String> mapGeoLocationLiterals = new Map<String, String>(); //Added for BAC-4676
        Map<String, String> mapDateLiterals = new Map<String, String>();
        Map<String, String> mapDateTimeLiterals = new Map<String, String>();
        Map<String, String> mapUserLiterals = new Map<String, String>();
        Map<String, String> mapSiteLiterals = new Map<String, String>();
        Map<String, String> mapSettingLiterals = new Map<String, String>();
        
        try
        {           
            Map<String,String> getOperatorType = new SFM_Utils().getStringMap(prequest.stringMap);
            String strOperatorType = getOperatorType.get('OPERATORTYPE');
            String strObjectName = getOperatorType.get('OBJECTNAME');
            
            if(strOperatorType != NULL && strOperatorType.toUpperCase() == 'ALL')
            {
                //Added for BAC-4676
                mapGeoLocationLiterals = geolocationOptions();
                for(String geoLiteral : mapGeoLocationLiterals.keySet())
                    lstStrMapgeoLocation.add(new SFM_WrapperDef.SFM_StringMap(geoLiteral, mapGeoLocationLiterals.get(geoLiteral)));
                objSFMResp.MapStringMap.add(new SFM_WrapperDef.SFM_MapStringMap('NUMBER', lstStrMapgeoLocation));
                //End for BAC-4676
                mapDateLiterals = dateOptions();     
                for(String DateLiteral : mapDateLiterals.keySet())
                    lstStrMapForDate.add(new SFM_WrapperDef.SFM_StringMap(DateLiteral, mapDateLiterals.get(DateLiteral)));
                objSFMResp.MapStringMap.add(new SFM_WrapperDef.SFM_MapStringMap('DATE', lstStrMapForDate));

                mapDateTimeLiterals = dateTimeOptions();
                for(String DateTimeLiteral : mapDateTimeLiterals.keySet())
                    lstStrMapForDateTime.add(new SFM_WrapperDef.SFM_StringMap(DateTimeLiteral, mapDateTimeLiterals.get(DateTimeLiteral)));
                objSFMResp.MapStringMap.add(new SFM_WrapperDef.SFM_MapStringMap('DATETIME', lstStrMapForDateTime));

                mapUserLiterals = userOptions();
                for(String UserLiteral : mapUserLiterals.keySet())
                    lstStrMapForUser.add(new SFM_WrapperDef.SFM_StringMap(UserLiteral, mapUserLiterals.get(UserLiteral)));
                objSFMResp.MapStringMap.add(new SFM_WrapperDef.SFM_MapStringMap('USER', lstStrMapForUser));               
                
                mapSiteLiterals = siteOptions();
                for(String SiteLiteral : mapSiteLiterals.keySet())
                    lstStrMapForSite.add(new SFM_WrapperDef.SFM_StringMap(SiteLiteral, mapSiteLiterals.get(SiteLiteral)));
                objSFMResp.MapStringMap.add(new SFM_WrapperDef.SFM_MapStringMap('SVMXC__SITE__C', lstStrMapForSite));
                
                if(strObjectName != NULL && strObjectName.length() > 0)
                {
                    for(RecordType RT : [Select Id, Name From RecordType Where SobjectType =: strObjectName])
                        lstStrMapForRecType.add(new SFM_WrapperDef.SFM_StringMap(RT.Id, RT.Name));
                    objSFMResp.MapStringMap.add(new SFM_WrapperDef.SFM_MapStringMap('RECORDTYPE', lstStrMapForRecType));
                }
            }
            else if(strOperatorType != NULL && strOperatorType.toUpperCase() == 'NUMBER') //Added for BAC-4676
            {
                mapGeoLocationLiterals = geolocationOptions();
                for(String geoLiteral : mapGeoLocationLiterals.keySet())
                    lstStrMapgeoLocation.add(new SFM_WrapperDef.SFM_StringMap(geoLiteral, mapGeoLocationLiterals.get(geoLiteral)));
                objSFMResp.MapStringMap.add(new SFM_WrapperDef.SFM_MapStringMap('NUMBER', lstStrMapgeoLocation));
            }
            else if(strOperatorType != NULL && strOperatorType.toUpperCase() == 'DATE')
            {
                mapDateLiterals = dateOptions();     
                for(String DateLiteral : mapDateLiterals.keySet())
                    lstStrMapForDate.add(new SFM_WrapperDef.SFM_StringMap(DateLiteral, mapDateLiterals.get(DateLiteral)));
                objSFMResp.MapStringMap.add(new SFM_WrapperDef.SFM_MapStringMap('DATE', lstStrMapForDate));
            }
            else if(strOperatorType != NULL && strOperatorType.toUpperCase() == 'DATETIME')
            {
                mapDateTimeLiterals = dateTimeOptions();
                for(String DateTimeLiteral : mapDateTimeLiterals.keySet())
                    lstStrMapForDateTime.add(new SFM_WrapperDef.SFM_StringMap(DateTimeLiteral, mapDateTimeLiterals.get(DateTimeLiteral)));
                objSFMResp.MapStringMap.add(new SFM_WrapperDef.SFM_MapStringMap('DATETIME', lstStrMapForDateTime));
            }
            else if(strOperatorType != NULL && strOperatorType.toUpperCase() == 'USER')
            {
                mapUserLiterals = userOptions();
                for(String UserLiteral : mapUserLiterals.keySet())
                    lstStrMapForUser.add(new SFM_WrapperDef.SFM_StringMap(UserLiteral, mapUserLiterals.get(UserLiteral)));
                objSFMResp.MapStringMap.add(new SFM_WrapperDef.SFM_MapStringMap('USER', lstStrMapForUser));               
            }
            else if(strOperatorType != NULL && strOperatorType.toUpperCase() == 'SVMXC__SITE__C')
            {
                mapSiteLiterals = siteOptions();
                for(String SiteLiteral : mapSiteLiterals.keySet())
                    lstStrMapForSite.add(new SFM_WrapperDef.SFM_StringMap(SiteLiteral, mapSiteLiterals.get(SiteLiteral)));
                objSFMResp.MapStringMap.add(new SFM_WrapperDef.SFM_MapStringMap('SVMXC__SITE__C', lstStrMapForSite));
            }
            else if(strOperatorType != NULL && strOperatorType.toUpperCase() == 'CUSTOM_SETTINGS')
            {
                
            }
            else if(strOperatorType != NULL && strOperatorType.toUpperCase() == 'RECORDTYPE' && strObjectName != NULL && strObjectName.length() > 0)
            {
                for(RecordType RT : [Select Id, Name From RecordType Where SobjectType =: strObjectName])
                    lstStrMapForRecType.add(new SFM_WrapperDef.SFM_StringMap(RT.Id, RT.Name));
                objSFMResp.MapStringMap.add(new SFM_WrapperDef.SFM_MapStringMap('RECORDTYPE', lstStrMapForRecType));
            }
        }
        catch(Exception ex)
        {
            objSFMResp.success = false;
            objSFMResp.message = ex.getmessage();
        }
        return objSFMResp;
    }
    
    public Map<String, String> dateOptions()
    {
        Map<String, String> response = new Map<String, String>();
        response.put('TODAY', system.label.COMM001_TAG018);//'Today'
        response.put('TOMORROW', system.label.COMM001_TAG019);//'Tomorrow'
        response.put('YESTERDAY', system.label.COMM001_TAG020);//'Yesterday'
        return response;
    }
    //Added for BAC-4676
    public Map<String, String> geolocationOptions()
    {
        Map<String, String> response = new Map<String, String>();
        response.put('Geolocation.Latitude', system.label.SFM001_TAG735);//'Geolocation.Latitude'
        response.put('Geolocation.Longitude', system.label.SFM001_TAG736);//'Geolocation.Longitude'
        response.put('Geolocation.Accuracy', system.label.SFM001_TAG737);//'Geolocation.Accuracy'
        return response;
    }
    public Map<String, String> dateTimeOptions()
    {
        Map<String, String> response = new Map<String, String>();
        response.put('SVMX.NOW', system.label.COMM001_TAG021);//'Now'
        response.put('TODAY', system.label.COMM001_TAG018);//'Today'
        response.put('TOMORROW', system.label.COMM001_TAG019);//'Tomorrow'
        response.put('YESTERDAY', system.label.COMM001_TAG020);//'Yesterday'
        return response;
    }
    
    public Map<String, String> userOptions()
    {
        Map<String, String> response = new Map<String, String>();
        //response.put('SVMX.CURRENTUSERID', 'Current User ID');//system.label.COMM001_TAG022 - 'Current User'
        return response;
    }

    public Map<String, String> siteOptions()
    {
        Map<String, String> response = new Map<String, String>();
        response.put('SVMX.USERTRUNK', 'User Trunk');
        return response;
    }
    
    public Map<String, String> booleanOptions()
    {
        Map<String, String> response = new Map<String, String>();
        response.put('TRUE', 'true');
        response.put('FALSE', 'false');
        return response;
    }

/*Added 27-Mar-2017:Checklist:ST-57:Sourabh
  Description:This method returns exit criteria operators for each valid data type
*/
 public SFM_WrapperDef.SFM_Response SFM_GetChecklistExitOperators(SFM_WrapperDef.SFM_Request prequest)
    {
        SFM_WrapperDef.SFM_Response objSFMResp = new SFM_WrapperDef.SFM_Response();
        objSFMResp.stringMap = new List<SFM_WrapperDef.SFM_StringMap>();
        objSFMResp.MapStringMap = new List<SFM_WrapperDef.SFM_MapStringMap>();
        objSFMResp.success = true;

        try
        {
            objSFMResp = getDataTypeVsOperatorType(objSFMResp); //Get Data type Vs Operator type Information
            String strOperatorType = new SFM_Utils().getStringMap(prequest.stringMap).get('OPERATORTYPE');
            List<SFM_WrapperDef.SFM_StringMap> options; 
            if(strOperatorType != NULL && strOperatorType.toUpperCase() == 'ALL')
            {
                options = new List<SFM_WrapperDef.SFM_StringMap>();
                
                //--------------------------------  String ---------------------
                
                options.add(new SFM_WrapperDef.SFM_StringMap('eq', System.Label.SFM001_TAG187));// 'Equals'
                options.add(new SFM_WrapperDef.SFM_StringMap('ne', System.Label.SFM001_TAG188));//'Not Equal'
                options.add(new SFM_WrapperDef.SFM_StringMap('contains', System.Label.SFM001_TAG194));//'Contains'));
                options.add(new SFM_WrapperDef.SFM_StringMap('notcontain', System.Label.SFM001_TAG195));//'Does Not Contain'));
                options.add(new SFM_WrapperDef.SFM_StringMap('isnull', System.Label.COMM002_TAG022));//'Null'));
                options.add(new SFM_WrapperDef.SFM_StringMap('isnotnull', System.Label.COMM002_TAG023));//'Is not Null'));
                objSFMResp.MapStringMap.add(new SFM_WrapperDef.SFM_MapStringMap('TEXT', options));
                
            //---------------------------------------------------------------------
            
            //---------------------------------PICKLIST --------------------


                options = new List<SFM_WrapperDef.SFM_StringMap>();
                options.add(new SFM_WrapperDef.SFM_StringMap('eq', System.Label.SFM001_TAG187));// 'Equals'
                options.add(new SFM_WrapperDef.SFM_StringMap('ne', System.Label.SFM001_TAG188));//'Not Equal'
                options.add(new SFM_WrapperDef.SFM_StringMap('isnull', System.Label.COMM002_TAG022));//'Null'
                options.add(new SFM_WrapperDef.SFM_StringMap('isnotnull', System.Label.COMM002_TAG023));//'Is not Null'
                objSFMResp.MapStringMap.add(new SFM_WrapperDef.SFM_MapStringMap('PICKLIST', options)); 

                
                //-----------------------------------------------------------------------
                //----------------------------------- NUMERIC -------------------------
                options = new List<SFM_WrapperDef.SFM_StringMap>();
                options.add(new SFM_WrapperDef.SFM_StringMap('eq', System.Label.SFM001_TAG187));// 'Equals'
                 options.add(new SFM_WrapperDef.SFM_StringMap('ne', System.Label.SFM001_TAG188));//'Not Equal'
                options.add(new SFM_WrapperDef.SFM_StringMap('gt', System.Label.SFM001_TAG189));//'Greater Than'
                options.add(new SFM_WrapperDef.SFM_StringMap('ge', System.Label.SFM001_TAG190));//'Greater or Equal To'
                options.add(new SFM_WrapperDef.SFM_StringMap('lt', System.Label.SFM001_TAG191));//'Less Than'
                options.add(new SFM_WrapperDef.SFM_StringMap('le', System.Label.SFM001_TAG192));//'Less or Equal To'
                options.add(new SFM_WrapperDef.SFM_StringMap('isnull', System.Label.COMM002_TAG022));//'Null'
                options.add(new SFM_WrapperDef.SFM_StringMap('isnotnull', System.Label.COMM002_TAG023));//'Is not Null'
                objSFMResp.MapStringMap.add(new SFM_WrapperDef.SFM_MapStringMap('NUMBER', options));

                //-----------------------------------------------------------------------
                //----------------------------------- BOOLEAN -------------------------
                
                options = new List<SFM_WrapperDef.SFM_StringMap>();
                options.add(new SFM_WrapperDef.SFM_StringMap('eq', System.Label.SFM001_TAG187));// 'Equals'
                options.add(new SFM_WrapperDef.SFM_StringMap('ne', System.Label.SFM001_TAG188));//'Not Equal'
                options.add(new SFM_WrapperDef.SFM_StringMap('isnull', System.Label.COMM002_TAG022));//'Null'
                options.add(new SFM_WrapperDef.SFM_StringMap('isnotnull', System.Label.COMM002_TAG023));//'Is not Null'
                objSFMResp.MapStringMap.add(new SFM_WrapperDef.SFM_MapStringMap('RADIO BUTTON', options));

                //-----------------------------------------------------------------------
                //----------------------------------- DATETIME -------------------------
                
                
                options = new List<SFM_WrapperDef.SFM_StringMap>();
                options.add(new SFM_WrapperDef.SFM_StringMap('eq', System.Label.SFM001_TAG187));// 'Equals'
                options.add(new SFM_WrapperDef.SFM_StringMap('ne', System.Label.SFM001_TAG188));//'Not Equal'
                options.add(new SFM_WrapperDef.SFM_StringMap('gt', System.Label.SFM001_TAG189));//'Greater Than'
                options.add(new SFM_WrapperDef.SFM_StringMap('ge', System.Label.SFM001_TAG190));//'Greater or Equal To'
                options.add(new SFM_WrapperDef.SFM_StringMap('lt', System.Label.SFM001_TAG191));//'Less Than'
                options.add(new SFM_WrapperDef.SFM_StringMap('le', System.Label.SFM001_TAG192));//'Less or Equal To'
                options.add(new SFM_WrapperDef.SFM_StringMap('isnull', System.Label.COMM002_TAG022));//'Null'
                options.add(new SFM_WrapperDef.SFM_StringMap('isnotnull', System.Label.COMM002_TAG023));//'Is not Null'
                objSFMResp.MapStringMap.add(new SFM_WrapperDef.SFM_MapStringMap('DATETIME', options));
                objSFMResp.MapStringMap.add(new SFM_WrapperDef.SFM_MapStringMap('DATE', options));
            }
        }
        catch(Exception ex)
        {
            objSFMResp.success = false;
            objSFMResp.message = ex.getmessage();
        }
        return objSFMResp;
    }    
}