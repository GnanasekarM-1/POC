public with sharing class APL_RoutingEngine
{
    public map<string, sObject> MapRecs = new map<string, sObject>();
    public map<Id, SVMXC__ServiceMax_Processes__c> mapRules = new map<Id, SVMXC__ServiceMax_Processes__c>();
    public map<Id, list<SVMXC__ServiceMax_Config_Data__c>> mapRulesExpressions = new  map<Id, list<SVMXC__ServiceMax_Config_Data__c>>();
    public LIST<SVMXC__ServiceMax_Processes__c> LstSVMXRoutRules = new LIST<SVMXC__ServiceMax_Processes__c>();
    public List<SVMXC__ServiceMax_Config_Data__c> lstExpressions = new List<SVMXC__ServiceMax_Config_Data__c>();
    public List<String> LstRulesId = new List<String>();    
    public APL_Utils APLUtilObj = new APL_Utils();
    public map<string, string> mapResult = null;

    /**************** Method to get Route for Caseline records. ********************/
    public INTF_WebServicesDef.INTF_SFMResponse APL_GetRouteInfo(INTF_WebServicesDef.INTF_SFMRequest doRouteCalcRequest)
    {
        INTF_WebServicesDef.INTF_SFMResponse objRespRouteResult = new INTF_WebServicesDef.INTF_SFMResponse();
        objRespRouteResult.valueMap = new List<INTF_WebServicesDef.SVMXMap>(); 
        List<RecordType> LstConfigRType = new List<RecordType>(); 
        String StrConfigExpId = ''; 
        Product2 objProduct = null;
        Account objAccount = null;
        SVMXC__Site__c  objLoc = null;
        Case objCase = null;
        SVMXC__Case_Line__c  objCaseLine = null;
        string strSobjectIdType = null;
        string strSobjectId = null;
        sObject sObjectName;
        string strRouteType = null;
        string strCaseId = null;
        objRespRouteResult.success = true;
        try
        {
            for(INTF_WebServicesDef.SVMXMap objTemp : doRouteCalcRequest.valueMap)
            {
                if(objTemp.key == 'RouteType')
                {
                    strRouteType = objTemp.value;
                }
                if(objTemp.key == 'CaseID')
                {
                    strCaseId = objTemp.value;
                }
            }
            
            LstConfigRType = [SELECT Id, Name FROM RecordType WHERE SobjectType = 'SVMXC__ServiceMax_Config_Data__c' AND Name='Expressions' ]; //SDL-SVMX-FLS-NOT-ENFORCED-META-DATA
            StrConfigExpId = LstConfigRType[0].Id;
            LstSVMXRoutRules = [select SVMXC__Select__c, SVMXC__Sequence__c, SVMXC__Active__c, SVMXC__APL_Route_Rule_Type__c , SVMXC__Name__C, SVMXC__Advance_Expression__c, SVMXC__IsStandard__c from  SVMXC__ServiceMax_Processes__c where SVMXC__Record_Type_Name__c ='SVMX Rule' And SVMXC__Rule_Type__c = 'Routing Rule' And SVMXC__Active__c =true And SVMXC__APL_Route_Rule_Type__c =: strRouteType ORDER BY SVMXC__Sequence__c ]; //SDL-SVMX-FLS-NOT-ENFORCED-META-DATA
            system.debug('List of Routing Rules: ' + LstSVMXRoutRules);
            
            for(SVMXC__ServiceMax_Processes__c oSVMXProcess: LstSVMXRoutRules)
            {
                Id IdRule = oSVMXProcess.Id;
                mapRules.put(IdRule,oSVMXProcess);
                LstRulesId.add(String.escapeSingleQuotes(String.valueOf(IdRule))); 
            }
            
            String StrExpQuery = ''; 
            lstExpressions.clear();
            StrExpQuery = 'Select SVMXC__FKey_Name_Field__c, SVMXC__Field_Relationship_Name__c, SVMXC__Object_Name2__c, SVMXC__Display_Type__c, SVMXC__Location__c, SVMXC__Dispatch_Process__c, SVMXC__Sequence__c, SVMXC__Select__c, SVMXC__RecordType_Name__c, SVMXC__Profile__c, SVMXC__Operator__c, SVMXC__Operand__c, SVMXC__Object_Name__c,  SVMXC__Field_Name__c,  SVMXC__Expression_Type__c, SVMXC__Expression_Rule__c, SVMXC__Description__c, SVMXC__Active__c, RecordTypeId From SVMXC__ServiceMax_Config_Data__c  where SVMXC__Dispatch_Process__r.Id IN: LstRulesId and SVMXC__Dispatch_Process__r.SVMXC__Rule_Type__c = \'Routing Rule\' and  RecordTypeId=\''+String.escapeSingleQuotes(StrConfigExpId)+'\'and SVMXC__Expression_Type__c =\'ROUTE_RULE_EXP\' Order By SVMXC__Dispatch_Process__r.SVMXC__Sequence__c';
            lstExpressions = Database.Query(StrExpQuery);
            
            if(lstExpressions == null || lstExpressions.size() == 0)
            {
                objRespRouteResult.success = true;
                for(INTF_WebServicesDef.SVMXMap objCurrentInfo : doRouteCalcRequest.valueMap)
                {
                    if(objCurrentInfo.key == 'ProductID')
                    {
                        objRespRouteResult.valueMap.add(new INTF_WebServicesDef.SVMXMap(string.valueOf('Product2'),objCurrentInfo.value));
                        break;
                    }
                }
                 
                objRespRouteResult.valueMap.add(new INTF_WebServicesDef.SVMXMap('RouteID', '-1'));
                return objRespRouteResult;
            }
            
            MapRecs.clear();
            String strAccountFldsQry = ''; 
            Set<String> setAccFlds = new Set<String>();
            String strProdFldsQry = ''; 
            Set<String> setPodFlds = new Set<String>();
            String strLocFldsQry = ''; 
            Set<String> setLocFlds = new Set<String>();
			
			String strCaseFldsQry = '';
			Set<String> setCaseFlds = new Set<String>();
			String strCaseLineFldsQry = '';
			Set<String> setCaseLineFlds = new Set<String>();
			
            for(SVMXC__ServiceMax_Config_Data__c oExpression: lstExpressions)
            {
                if(!mapRulesExpressions.containsKey(oExpression.SVMXC__Dispatch_Process__c))
                    mapRulesExpressions.put(oExpression.SVMXC__Dispatch_Process__c,new List<SVMXC__ServiceMax_Config_Data__c>());
				mapRulesExpressions.get(oExpression.SVMXC__Dispatch_Process__c).add(oExpression);
					
                if(oExpression.SVMXC__Object_Name2__c == 'Account')
                {
                    if(oExpression.SVMXC__Field_Name__c != null && oExpression.SVMXC__Field_Name__c.length() > 0 && !setAccFlds.contains(oExpression.SVMXC__Field_Name__c))
                    { 
                        setAccFlds.add(oExpression.SVMXC__Field_Name__c);
                        if(strAccountFldsQry.length() > 0)
                            strAccountFldsQry += ',';                          
                        strAccountFldsQry += oExpression.SVMXC__Field_Name__c;                        
                        if(oExpression.SVMXC__Display_Type__c == 'REFERENCE')
                        {
                            setAccFlds.add(oExpression.SVMXC__Field_Relationship_Name__c + '.' + oExpression.SVMXC__FKey_Name_Field__c);
                            strAccountFldsQry += ',' + oExpression.SVMXC__Field_Relationship_Name__c + '.' + oExpression.SVMXC__FKey_Name_Field__c;
                        }  
                    }
                }
                else if(oExpression.SVMXC__Object_Name2__c == 'Product2')
                {
                    if(oExpression.SVMXC__Field_Name__c != null && oExpression.SVMXC__Field_Name__c.length() > 0 && !setPodFlds.contains(oExpression.SVMXC__Field_Name__c))
                    { 
                        setPodFlds.add(oExpression.SVMXC__Field_Name__c);
                        if(strProdFldsQry.length() > 0)
                            strProdFldsQry += ',';
                        strProdFldsQry += oExpression.SVMXC__Field_Name__c;
                        if(oExpression.SVMXC__Display_Type__c == 'REFERENCE')
                        {
                            setPodFlds.add(oExpression.SVMXC__Field_Relationship_Name__c + '.' + oExpression.SVMXC__FKey_Name_Field__c);
                            strProdFldsQry += ',' + oExpression.SVMXC__Field_Relationship_Name__c + '.' + oExpression.SVMXC__FKey_Name_Field__c;
                        }  
                    }
                }
                else if(oExpression.SVMXC__Object_Name2__c == 'SVMXC__Site__c')
                {
                    if(oExpression.SVMXC__Field_Name__c != null && oExpression.SVMXC__Field_Name__c.length() > 0 && !setLocFlds.contains(oExpression.SVMXC__Field_Name__c))
                    { 
                        setLocFlds.add(oExpression.SVMXC__Field_Name__c);
                        if(strLocFldsQry.length() > 0)
                            strLocFldsQry += ',';
                        strLocFldsQry += oExpression.SVMXC__Field_Name__c;
                        if(oExpression.SVMXC__Display_Type__c == 'REFERENCE')
                        {
                            setLocFlds.add(oExpression.SVMXC__Field_Relationship_Name__c + '.' + oExpression.SVMXC__FKey_Name_Field__c);
                            strLocFldsQry += ',' + oExpression.SVMXC__Field_Relationship_Name__c + '.' + oExpression.SVMXC__FKey_Name_Field__c ;
                        } 
                    }
                }
				
				if(oExpression.SVMXC__Object_Name2__c == 'Case')
                {
                    if(oExpression.SVMXC__Field_Name__c != null && oExpression.SVMXC__Field_Name__c.length() > 0 && !setCaseFlds.contains(oExpression.SVMXC__Field_Name__c))
                    { 
                        setCaseFlds.add(oExpression.SVMXC__Field_Name__c);
                        if(strCaseFldsQry.length() > 0)
                            strCaseFldsQry += ',';                          
                        strCaseFldsQry += oExpression.SVMXC__Field_Name__c;                        
                        if(oExpression.SVMXC__Display_Type__c == 'REFERENCE')
                        {
                            setCaseFlds.add(oExpression.SVMXC__Field_Relationship_Name__c + '.' + oExpression.SVMXC__FKey_Name_Field__c);
                            strCaseFldsQry += ',' + oExpression.SVMXC__Field_Relationship_Name__c + '.' + oExpression.SVMXC__FKey_Name_Field__c;
                        }  
                    }
                }
				if(oExpression.SVMXC__Object_Name2__c == 'SVMXC__Case_Line__c')
                {
                    if(oExpression.SVMXC__Field_Name__c != null && oExpression.SVMXC__Field_Name__c.length() > 0 && !setCaseLineFlds.contains(oExpression.SVMXC__Field_Name__c))
                    { 
                        setCaseLineFlds.add(oExpression.SVMXC__Field_Name__c);
                        if(strCaseLineFldsQry.length() > 0)
                            strCaseLineFldsQry += ',';                          
                        strCaseLineFldsQry += oExpression.SVMXC__Field_Name__c;                        
                        if(oExpression.SVMXC__Display_Type__c == 'REFERENCE')
                        {
                            setCaseLineFlds.add(oExpression.SVMXC__Field_Relationship_Name__c + '.' + oExpression.SVMXC__FKey_Name_Field__c);
                            strCaseLineFldsQry += ',' + oExpression.SVMXC__Field_Relationship_Name__c + '.' + oExpression.SVMXC__FKey_Name_Field__c;
                        }  
                    }
                }
			}
            system.debug('Account qry: ' + strAccountFldsQry + ' Product qry: ' + strProdFldsQry + ' Location Qry: ' + strLocFldsQry);
			system.debug('Case qry: ' + strCaseFldsQry + ' Case Line qry: ' + strCaseLineFldsQry);
			
			string strObjectName = null;
            String strCaseLineId = null;
            for(INTF_WebServicesDef.SVMXMap objCurrentInfo : doRouteCalcRequest.valueMap)
            {
                strSobjectIdType = objCurrentInfo.key;
                strSobjectId = objCurrentInfo.value;
                if(strSobjectIdType == 'AccountID')
                {
                    strObjectName = 'Account';
                    if(strAccountFldsQry != null && strAccountFldsQry.length() > 0)
                    {
                        objAccount = database.query('Select ' + strAccountFldsQry + ' From Account' + ' where Id =: strSobjectId');
                        sObjectName = (sObject)objAccount;
                        MapRecs.put(strObjectName, sObjectName);
                    }
                    objRespRouteResult.valueMap.add(new INTF_WebServicesDef.SVMXMap(string.valueOf(strObjectName), strSobjectId));
                }
                else if(strSobjectIdType == 'ProductID')
                {
                    strObjectName = 'Product2';
                    if(strProdFldsQry != null && strProdFldsQry.length() > 0)
                    {
                        objProduct = database.query('Select ' + strProdFldsQry + ' From Product2' + ' where Id =: strSobjectId');
                        sObjectName = (sObject)objProduct;
                        MapRecs.put(strObjectName, sObjectName);
                    }
                    objRespRouteResult.valueMap.add(new INTF_WebServicesDef.SVMXMap(string.valueOf(strObjectName), strSobjectId));
                    
                }
				else if(strSobjectIdType == 'LocationID')
                {
                    strObjectName = 'SVMXC__Site__c';
                    if(strLocFldsQry != null && strLocFldsQry.length() > 0)
                    {
                        objLoc = database.query('Select ' + strLocFldsQry + ' From SVMXC__Site__c' + ' where Id =:  strSobjectId');
                        sObjectName = (sObject)objLoc;
                        MapRecs.put(strObjectName, sObjectName);
                    }
                    objRespRouteResult.valueMap.add(new INTF_WebServicesDef.SVMXMap(string.valueOf(strObjectName), strSobjectId));
                    
                }
				else if(strSobjectIdType == 'CaseId')
                {
                    strObjectName = 'Case';
                    if(strCaseFldsQry != null && strCaseFldsQry.length() > 0)
                    {
                        objCase = database.query('Select ' + strCaseFldsQry + ' From Case' + ' where Id =: strSobjectId');
                        sObjectName = (sObject)objCase;
                        MapRecs.put(strObjectName, sObjectName);
                    }
                    objRespRouteResult.valueMap.add(new INTF_WebServicesDef.SVMXMap(string.valueOf(strObjectName), strSobjectId));
                    
                }
				else if(strSobjectIdType == 'CaseLineId')
                {
                    strCaseLineId = strSobjectId;
                    strObjectName = 'SVMXC__Case_Line__c';
					if(strCaseLineFldsQry != null && strCaseLineFldsQry.length() > 0)
                    {
                        objCaseLine = database.query('Select ' + strCaseLineFldsQry + ' From SVMXC__Case_Line__c' + ' where Id =: strSobjectId');
                        sObjectName = (sObject)objCaseLine;
                        MapRecs.put(strObjectName, sObjectName);
                    }
                    objRespRouteResult.valueMap.add(new INTF_WebServicesDef.SVMXMap(string.valueOf(strObjectName), strSobjectId));
                    
                }
				else if(strSobjectIdType == 'RouteType')
                {
                    strObjectName = 'RouteType';
                    objRespRouteResult.valueMap.add(new INTF_WebServicesDef.SVMXMap(string.valueOf(strObjectName), strSobjectId));                  
                }               
            }
            
            /************ Call parsing utility ***************/
            mapResult = APLUtilObj.SVMX_ExpressionParsing(MapRecs, mapRulesExpressions, mapRules);
            System.debug('Result from Expression Parsing: ' + mapResult);
            
			INTF_WebServicesDef.SVMXMap objRespMap = new INTF_WebServicesDef.SVMXMap();
			objRespMap.values = new List<String>();
            /* this is required for batching in the Next call
            Map<String,SVMXC__Case_Line__c> mapCurrProCaseLines = new Map<String,SVMXC__Case_Line__c>();
            mapCurrProCaseLines.putAll([select id from SVMXC__Case_Line__c where (SVMXC__Product__c = :strProId) and SVMXC__Case__c = :strCaseId]);
            objRespMap.values = new List<String>();
            objRespMap.values.addAll(mapCurrProCaseLines.keySet()); */
			objRespMap.values.add(strCaseLineId);
            
			if(mapResult != null && mapResult.size() > 0)
            {
                for(string strRuleName : mapResult.KeySet())
                {
                    objRespMap.key = 'RouteID';
                    objRespMap.value = strRuleName;
                    break;
                }
            }
            else
            {
                objRespRouteResult.success = true;
                objRespMap.key = 'RouteID';
                objRespMap.value = '-1';
            }           
            objRespRouteResult.valueMap.add(objRespMap);
        }
        catch(Exception ex)
        {
            objRespRouteResult.success = false;
            objRespRouteResult.valueMap.add(new INTF_WebServicesDef.SVMXMap('Error', ex.getMessage()));
        }
        system.debug('Response from Get Route Info: ' + objRespRouteResult);
        return objRespRouteResult;
    }
    
	//This method is no longer exist and code has been migrated in APL_GetCaseInfo method to support Case and Case Line attribute in Inbound Routing. 
	public INTF_WebServicesDef.INTF_SFMResponse APL_GetAccountAndProductInfo(INTF_WebServicesDef.INTF_SFMRequest caseRequest)
	{
		INTF_WebServicesDef.INTF_SFMResponse objRespForRoutCalc = new INTF_WebServicesDef.INTF_SFMResponse();
		return objRespForRoutCalc;
	}
	
    /**************** Method to get Account and Product Info by calling Utility. ********************/
    public INTF_WebServicesDef.INTF_SFMResponse APL_GetCaseInfo(INTF_WebServicesDef.INTF_SFMRequest caseRequest)
    {
        INTF_WebServicesDef.INTF_SFMResponse objRespForRoutCalc = new INTF_WebServicesDef.INTF_SFMResponse();
        objRespForRoutCalc.valueMap = new List<INTF_WebServicesDef.SVMXMap>(); 
        INTF_WebServicesDef.SVMXMap objSVMXMapCaseLineInfo = new INTF_WebServicesDef.SVMXMap();
        objRespForRoutCalc.success = true;
		
		Case objCaseRec = null;       
        string strCaseID = null;  
        string strProcID = null;  
        string strProcCaseHeaderID = null;  
        string strProcCaesLineID = null;  
        string strGenInfoHdrCri = null;
        string strGenInfoLineCri = null;
        boolean isPerformRouteCalc = false;
        string strAccId = null;
        List<string> lstProdIds = new List<string>();
        Set<String> setProdIDs = new Set<string>();
        List<SVMXC__Case_Line__c> lstCaseLines = new List<SVMXC__Case_Line__c>();
        
        List<string> lstCaseLinesNotProcessed = new List<string>();
        try
        {
            List<INTF_WebServicesDef.SVMXMap> objCaseRequest = new List<INTF_WebServicesDef.SVMXMap>();
            objCaseRequest = caseRequest.valueMap;
            for(INTF_WebServicesDef.SVMXMap objCurrentInfo : objCaseRequest)
            {
                if(objCurrentInfo.key == 'ProcessId')
                    strProcID = objCurrentInfo.value;
                else if(objCurrentInfo.key == 'CaseId')
                    strCaseId = objCurrentInfo.value;
            }
            
            if(strProcID != null && strCaseId != null)
            {
                SVMXC__ServiceMax_Processes__c objProcDef = [Select Id, SVMXC__APL_Perform_Route_Calculations__c, SVMXC__Submodule__c, SVMXC__Node_Parent__c, SVMXC__Parent_Object__c, SVMXC__Process__c  From SVMXC__ServiceMax_Processes__c where SVMXC__ProcessId__c = :strProcID and Recordtype.Name='Initiate Return Process']; //SDL-SVMX-FLS-NOT-ENFORCED-META-DATA
                if(objProcDef != null)
                {
                    isPerformRouteCalc = objProcDef.SVMXC__APL_Perform_Route_Calculations__c;
                    strProcCaseHeaderID = objProcDef.SVMXC__Parent_Object__c; // Process ID for Case.
                    strProcCaesLineID = objProcDef.SVMXC__Process__c; // Process ID for Caseline.
                    strGenInfoHdrCri = objProcDef.SVMXC__Node_Parent__c; // Process ID for Caseline.
                    strGenInfoLineCri = objProcDef.SVMXC__Submodule__c; // Process ID for Caseline.
                }
            
                if(isPerformRouteCalc)
                {
                    String strWhereClause = '';
                    strWhereClause = buildWhereClause(strGenInfoHdrCri,strProcCaseHeaderID,false);
                    if(strWhereClause != null && strWhereClause.length() > 0)
                    {
                    	List<Case> lstCase = database.query('Select Id,Account.Id From Case where Id= :strCaseId AND ' +  strWhereClause);
                        if(lstCase == null || lstCase.size() == 0) 
                        {
							objRespForRoutCalc.success = false;
                            objRespForRoutCalc.valueMap.add(new INTF_WebServicesDef.SVMXMap('Error', getTAG002()));
                            return objRespForRoutCalc;
                        }
                    	else
                        	objCaseRec = lstCase[0];
                    }                    
                    strWhereClause = buildWhereClause(strGenInfoLineCri,strProcCaesLineID,false);
                    if(objCaseRec == null)
                        objCaseRec = [SELECT Id, Account.Id from Case where Id=:strCaseID];
            
                    if(objCaseRec != null)
                    {
                        strAccId = objCaseRec.AccountId;
                        objRespForRoutCalc.success = true;
                        if(strAccId != null)
							objRespForRoutCalc.value = strAccId;
						else
							objRespForRoutCalc.value = 'NO_ACCOUNT';
						
                        if(strWhereClause.length() > 0)
                            lstCaseLines = database.query('Select SVMXC__Case__c, SVMXC__Product__c  From SVMXC__Case_Line__c where SVMXC__Case__c =:  strCaseID AND ' + strWhereClause);
                        else 
                            lstCaseLines = database.query('Select SVMXC__Case__c, SVMXC__Product__c  From SVMXC__Case_Line__c where SVMXC__Case__c =:  strCaseID');
                        
                        if(lstCaseLines != null && lstCaseLines.size() > 0)
                        {
                            for(SVMXC__Case_Line__c CurrLine : lstCaseLines)
                            	objRespForRoutCalc.valueMap.add(new INTF_WebServicesDef.SVMXMap(CurrLine.SVMXC__Product__c,CurrLine.Id));
                        }
                    }
                    else
                    {
                        objRespForRoutCalc.success = false;
                        objRespForRoutCalc.valueMap.add(new INTF_WebServicesDef.SVMXMap('Error', ''));
                    }
                }
           }            
        }
        catch (Exception ex)
        {
            objRespForRoutCalc.success = false;          
            objRespForRoutCalc.valueMap.add(new INTF_WebServicesDef.SVMXMap('Error', ex.getMessage())); 
        }      
        system.debug('Request generated from GetAccountNProductInfo: '+objRespForRoutCalc);  
        return objRespForRoutCalc;
    }
    
         
    /**************** Method to get Route for Caseline records. ********************/
    public INTF_WebServicesDef.INTF_SFMResponse APL_UpdateRouteCardAndCaseLine(INTF_WebServicesDef.INTF_SFMRequest routeUpdateRequest)
    {
        INTF_WebServicesDef.INTF_SFMResponse objUpdateRouteResp = new INTF_WebServicesDef.INTF_SFMResponse();
        objUpdateRouteResp.valueMap = new List<INTF_WebServicesDef.SVMXMap>(); 
        List<INTF_WebServicesDef.SVMXMap> objCaseLineAndRuleInfo = new List<INTF_WebServicesDef.SVMXMap>();
        List<SVMXC__ServiceMax_Config_Data__c> lstLocConfigData = new List<SVMXC__ServiceMax_Config_Data__c>();
        SVMXC__ServiceMax_Processes__c objRuleProcess = new SVMXC__ServiceMax_Processes__c();
        List<SVMXC__Route_Stop__c> lstRouteStop = new List<SVMXC__Route_Stop__c>();
        string strProcessId = null;             
        string strObjNameForLoc = null;
        string strFieldNameForLoc = null; 
        string strProcCaseHeaderID = null;  
        string strProcCaesLineID = null;  
        string strGenInfoHdrCri = null;
        string strGenInfoLineCri = null;
        boolean isPerformRouteCalc = false;
        String strCustomerID = null;
        set<String> setNotConsideredProIDs = new set<String>();
        try
        {
            objCaseLineAndRuleInfo = routeUpdateRequest.valueMap;
            objUpdateRouteResp.success = true;
            string strProId = null;
            string strRuleId = null;
            string strCaseId = null;
            string strSobjectIdType = null;
            string strSobjectId = null;
            Map<Id,SVMXC__Case_Line__c> mapIdCaseLine = new Map<Id,SVMXC__Case_Line__c>();
            List<SVMXC__Case_Line__c> lstUpdateCaseLine = new List<SVMXC__Case_Line__c>();
            List<SVMXC__Route_Card__c> lstRouteCard = new List<SVMXC__Route_Card__c> ();
            SVMXC__Route_Card__c objRouteCard;
             List<String> lstCaseLineFrRes = new List<String>();
            List<String> lstCaseLinesFrReq = new List<String>();
            for(INTF_WebServicesDef.SVMXMap objCurrentInfo : objCaseLineAndRuleInfo)
            {
                strSobjectIdType = objCurrentInfo.key;
                strSobjectId = objCurrentInfo.value;
                if(strSobjectIdType == 'ProductId')
                    strProId = strSobjectId;
                else if(strSobjectIdType == 'RouteRuleId')
                    strRuleId = strSobjectId;
                else if(strSobjectIdType == 'CaseId')
                    strCaseId = strSobjectId;
                else if(objCurrentInfo.key == 'ProcessId')
                    strProcessId = strSobjectId;
                else if(objCurrentInfo.key == 'IsPerformRouteCalc')
                    isPerformRouteCalc = Boolean.valueOf(strSobjectId);
                else if(objCurrentInfo.key == 'CaseLines')
                    lstCaseLinesFrReq = objCurrentInfo.values;
            }
            system.debug('Obj Type: ' + strSobjectIdType);
            system.debug('Obj Id: ' + strSobjectId);
            system.debug('Process Id: ' + strProId);
            system.debug('Rule Id: ' + strRuleId);
            system.debug('Case Id: ' + strCaseId);
            system.debug('Process Id: ' + strProcessId);
            system.debug('Is Perform Route Calc: ' + isPerformRouteCalc);
            system.debug('List of Case Lines: ' + lstCaseLinesFrReq + ' and the size is: ' + lstCaseLinesFrReq.size());
            
            Case objReqCustomerInfo = [Select AccountId from Case where id =:strCaseId];
            strCustomerID = objReqCustomerInfo.AccountId;
            SVMXC__ServiceMax_Processes__c objProcDef = [Select Id, SVMXC__APL_Perform_Route_Calculations__c, SVMXC__Submodule__c, SVMXC__Node_Parent__c, SVMXC__Parent_Object__c, SVMXC__Process__c  From SVMXC__ServiceMax_Processes__c where SVMXC__ProcessId__c = :strProcessId and Recordtype.Name='Initiate Return Process']; //SDL-SVMX-FLS-NOT-ENFORCED-META-DATA
            if(objProcDef != null)
            {
                //isPerformRouteCalc = objProcDef.SVMXC__APL_Perform_Route_Calculations__c;
                strProcCaseHeaderID = objProcDef.SVMXC__Parent_Object__c; // Process ID for Case.
                strProcCaesLineID = objProcDef.SVMXC__Process__c; // Process ID for Caseline.
                strGenInfoHdrCri = objProcDef.SVMXC__Node_Parent__c; // Process ID for Caseline.
                strGenInfoLineCri = objProcDef.SVMXC__Submodule__c; // Process ID for Caseline.
            }
            
            SVMXC__Route_Stop__c objRouteStop;
            if(isPerformRouteCalc && strRuleId != null && strRuleId.length() > 0)
            {
                String strWhereClause = buildWhereClause(strGenInfoLineCri, strProcCaesLineID, false);
                if(strWhereClause.length() > 0)
                {
                    mapIdCaseLine.putAll((List<SVMXC__Case_Line__c>)database.query('Select SVMXC__Location__c, Name, SVMXC__Product__c,SVMXC__Product__r.ProductCode,  Id, SVMXC__Route_Card__c, SVMXC__Case__c From SVMXC__Case_Line__c where id in: lstCaseLinesFrReq and SVMXC__Product__c =: strProId and SVMXC__Case__c = :strCaseId and SVMXC__Route_Card__c = null and ' + strWhereClause));
                }else
                {
                    mapIdCaseLine.putAll([Select SVMXC__Location__c, Name, SVMXC__Product__c, SVMXC__Product__r.ProductCode, Id, SVMXC__Route_Card__c, SVMXC__Case__c From SVMXC__Case_Line__c where id in: lstCaseLinesFrReq and SVMXC__Product__c =: strProId and SVMXC__Case__c = :strCaseId and SVMXC__Route_Card__c = null]);              
                }
                lstLocConfigData = [Select SVMXC__Sequence__c, SVMXC__Location__c, SVMXC__Dispatch_Process__c, SVMXC__RecordType_Name__c, RecordTypeId, Id From SVMXC__ServiceMax_Config_Data__c where SVMXC__Dispatch_Process__c =: strRuleId and SVMXC__RecordType_Name__c ='Route Stops' Order By SVMXC__Sequence__c]; //SDL-SVMX-FLS-NOT-ENFORCED-META-DATA
                objRuleProcess = [Select Id, SVMXC__APL_Route_Rule_Type__c From SVMXC__ServiceMax_Processes__c where Id =: strRuleId and SVMXC__Record_Type_Name__c ='SVMX Rule' and SVMXC__Rule_Type__c = 'Routing Rule']; //SDL-SVMX-FLS-NOT-ENFORCED-META-DATA
                
                for(SVMXC__Case_Line__c objCurrentLine : mapIdCaseLine.values())
                {
                    objRouteCard = new SVMXC__Route_Card__c();
                    objRouteCard.SVMXC__Case__c = objCurrentLine.SVMXC__Case__c;
                    objRouteCard.SVMXC__Case_Line__c = objCurrentLine.Id;
                    objRouteCard.SVMXC__Route_Type__c = objRuleProcess.SVMXC__APL_Route_Rule_Type__c;
                    objRouteCard.SVMXC__First_Stop__c = lstLocConfigData[0].SVMXC__Location__c;
                    objRouteCard.SVMXC__Next_Stop__c = lstLocConfigData[0].SVMXC__Location__c;
                    objRouteCard.SVMXC__Last_Stop__c = lstLocConfigData[integer.valueOf(lstLocConfigData.size() - 1 )].SVMXC__Location__c;
                    objRouteCard.SVMXC__Status__c = 'Open';
                    objRouteCard.SVMXC__Customer__c = strCustomerID;
                    lstRouteCard.add(objRouteCard);
                    lstCaseLineFrRes.add(objCurrentLine.Id);
                }
                if(lstRouteCard != null && lstRouteCard.size() > 0)
                {   
                    if( COMM_SecurityUtils.getInstance().verifyFieldAccess( lstRouteCard, COMM_SecurityUtils.Access.Upsertable ) ) {
                        upsert lstRouteCard; //SDL-SVMX-CREATE-UPDATE-FLS-ENFORCED
                    } else {
                        throw new COMM_SecurityUtils.SecurityAccessException( System.Label.COMM001_TAG142 );
                    }
                    
                    integer intCarCnt = 0, intPrevCarCnt = -1;
                    
                    while(intCarCnt < lstRouteCard.size())
                    {   
                                            
                        for(SVMXC__ServiceMax_Config_Data__c objRutStops : lstLocConfigData)
                        {
                            objRouteStop = new SVMXC__Route_Stop__c();
                            objRouteStop.SVMXC__Record_Card__c = lstRouteCard[intCarCnt].id;
                            objRouteStop.SVMXC__Stop_Number__c = objRutStops.SVMXC__Sequence__c;
                            objRouteStop.SVMXC__Stop_Location__c = objRutStops.SVMXC__Location__c;
                            if(intPrevCarCnt == intCarCnt)
                            {
                                //placing the route stop for the previous next stop
                                lstRouteStop[lstRouteStop.size()-1].SVMXC__Next_Stop__c =  objRutStops.SVMXC__Location__c;
                            }
                            intPrevCarCnt = intCarCnt;
                            lstRouteStop.add(objRouteStop);
                        }
                        intCarCnt++;
                    }
                }
                            
                
            }else
            {
                system.debug('Entered Here in the False of Route Calc');
                String strWhereClause = buildWhereClause(strGenInfoLineCri, strProcCaesLineID, true);
                system.debug('Where Clause Build: ' + strWhereClause);
                String strInfo = '';
                SVMXC__ServiceMax_Processes__c objInitRetProcess = [Select Id, SVMXC__Consider_Location_From_Object__c, SVMXC__Consider_Location_From__c From SVMXC__ServiceMax_Processes__c where SVMXC__ProcessId__c = :strProcessId and Recordtype.Name='Initiate Return Process']; //SDL-SVMX-FLS-NOT-ENFORCED-META-DATA
                strObjNameForLoc = string.ValueOf(objInitRetProcess.SVMXC__Consider_Location_From_Object__c);
                strFieldNameForLoc = string.ValueOf(objInitRetProcess.SVMXC__Consider_Location_From__c);
                system.debug('Object: ' + strObjNameForLoc + ' and fields is: ' + strFieldNameForLoc);
                string stAttToQry = '';
                if(strObjNameForLoc == 'SVMXC__Case_Line__c' && strFieldNameForLoc.length() > 0)
                {
                    stAttToQry = ', ' + strFieldNameForLoc;
                }           
                
                /*String strProductWhereClause = '';
                if(isPerformRouteCalc)
                {
                    strProductWhereClause = ' and SVMXC__Product__c =: strProId ';
                }
                system.debug('Product Where Clause Build: ' + strProductWhereClause);
                if(strWhereClause.length() > 0)
                {
                    mapIdCaseLine.putAll((List<SVMXC__Case_Line__c>)database.query('Select  Id ,SVMXC__Case__c, SVMXC__Product__r.ProductCode ' + stAttToQry + ' From SVMXC__Case_Line__c where SVMXC__Case__c = :strCaseId and SVMXC__Route_Card__c != null'+ strProductWhereClause + ' and ' + strWhereClause));
                }else
                {
                    mapIdCaseLine.putAll((List<SVMXC__Case_Line__c>)database.query('Select SVMXC__Case__c, Id, SVMXC__Product__r.ProductCode ' + stAttToQry + ' From SVMXC__Case_Line__c where SVMXC__Case__c = :strCaseId and SVMXC__Route_Card__c != null' + strProductWhereClause));                              
                }*/
                
                string strQuerySOQL = '';
            	if(strWhereClause.length() > 0 && strProId != null && lstCaseLinesFrReq != null && lstCaseLinesFrReq.size() > 0)
				{
					strQuerySOQL = 'Select  Id ,SVMXC__Case__c, Name, SVMXC__Route_Card__c, SVMXC__Product__r.ProductCode ' + stAttToQry + ' From SVMXC__Case_Line__c where Id = \'' + lstCaseLinesFrReq[0] + '\' and SVMXC__Case__c = \'' + strCaseId + '\' and SVMXC__Product__c =\''+ strProId + '\' and SVMXC__Route_Card__c = null and ' + strWhereClause;
				}else if(strProId != null && lstCaseLinesFrReq != null && lstCaseLinesFrReq.size() > 0)
				{
					strQuerySOQL = 'Select  Id ,SVMXC__Case__c, Name, SVMXC__Route_Card__c, SVMXC__Product__r.ProductCode ' + stAttToQry + ' From SVMXC__Case_Line__c where Id = \'' + String.escapeSingleQuotes(lstCaseLinesFrReq[0]) + '\' and SVMXC__Case__c = \'' + String.escapeSingleQuotes(strCaseId) + '\' and SVMXC__Product__c =\''+ String.escapeSingleQuotes(strProId) + '\' and SVMXC__Route_Card__c = null';                          
				}else if(lstCaseLinesFrReq != null && lstCaseLinesFrReq.size() > 0)
				{
					strQuerySOQL = 'Select  Id ,SVMXC__Case__c, Name, SVMXC__Route_Card__c, SVMXC__Product__r.ProductCode ' + stAttToQry + ' From SVMXC__Case_Line__c where Id = \'' + String.escapeSingleQuotes(lstCaseLinesFrReq[0]) + '\'  and SVMXC__Case__c = \'' + String.escapeSingleQuotes(strCaseId) + '\' and SVMXC__Product__c = null and SVMXC__Route_Card__c = null';
				}
				
				//Added by Naveen Vasu
				/*else
					strQuerySOQL = 'Select  Id ,SVMXC__Case__c, Name, SVMXC__Route_Card__c, SVMXC__Product__r.ProductCode ' + stAttToQry + ' From SVMXC__Case_Line__c where SVMXC__Case__c = \'' + strCaseId + '\' and SVMXC__Route_Card__c = null';
                */
                
                system.debug('SOQL Query created: ' + strQuerySOQL);
                
                //If clause added by Naveen Vasu
                //if(strQuerySOQL != null && strQuerySOQL != '' && strQuerySOQL.length() > 0)
                
                mapIdCaseLine.putAll((List<SVMXC__Case_Line__c>)database.query(strQuerySOQL));
                
                system.debug('Case Line queried: ' + mapIdCaseLine + ' and size is: ' + mapIdCaseLine.size());
                
                Case objCase = new Case();              
                if(strObjNameForLoc == 'Case' && strFieldNameForLoc != null)
                    objCase = database.query('Select Id ,'+ strFieldNameForLoc +' From Case where Id =: strCaseId');
                else if(strObjNameForLoc == 'Account' && strFieldNameForLoc != null)
                    objCase = database.query('Select Id, SVMXC__Site__c, Account.' + strFieldNameForLoc + ' From Case where Id =: strCaseId');
                
                system.debug('Case queried: ' + objCase);
                
                String strRouteStop = null; 
                for(SVMXC__Case_Line__c objCurrentLine : mapIdCaseLine.values())
                {
                    objRouteCard = new SVMXC__Route_Card__c();
                    
                    objRouteCard.SVMXC__Case__c = objCurrentLine.SVMXC__Case__c;
                    objRouteCard.SVMXC__Case_Line__c = objCurrentLine.Id;
                    
                    if(strObjNameForLoc == 'Case')
                    {
                        strRouteStop = String.valueOf(objCase.get(strFieldNameForLoc));
                        if(strRouteStop != null && strRouteStop.length() > 0)
                        {
                            objRouteCard.SVMXC__First_Stop__c = strRouteStop;
                            objRouteCard.SVMXC__Next_Stop__c = strRouteStop;
                            objRouteCard.SVMXC__Last_Stop__c = strRouteStop;
                        }
						else
                        {
                            //This product doesn't matched and there is not location for the field configured in the process.
                            System.debug('Entered into not considered Product: ' + objCurrentLine.SVMXC__Product__r.ProductCode);
                            setNotConsideredProIDs.add(objCurrentLine.Name);
                            continue; 
                        }
                    }
                    else if(strObjNameForLoc == 'SVMXC__Case_Line__c')
                    {
                        strRouteStop = String.valueOf(objCurrentLine.get(strFieldNameForLoc));
                        if(strRouteStop != null && strRouteStop.length() > 0)
                        {
                            objRouteCard.SVMXC__First_Stop__c = strRouteStop;
                            objRouteCard.SVMXC__Next_Stop__c = strRouteStop;
                            objRouteCard.SVMXC__Last_Stop__c = strRouteStop;
                        }else
                        {
                            //This product doesn't matched and there is not location for the field configured in the process.
                            System.debug('Entered into not considered Product: ' + objCurrentLine.SVMXC__Product__r.ProductCode);
                            setNotConsideredProIDs.add(objCurrentLine.Name);
                            continue;
                        }
                    }
                    else if(strObjNameForLoc == 'Account')
                    {
                        objRouteCard.SVMXC__First_Stop__c = String.valueOf(objCase.Account.get(strFieldNameForLoc));
                        objRouteCard.SVMXC__Next_Stop__c = String.valueOf(objCase.Account.get(strFieldNameForLoc));
                        objRouteCard.SVMXC__Last_Stop__c = String.valueOf(objCase.Account.get(strFieldNameForLoc));
                    }
                    objRouteCard.SVMXC__Route_Type__c = 'Inbound';
                    objRouteCard.SVMXC__Status__c = 'Open';
                    objRouteCard.SVMXC__Customer__c = strCustomerID;
                    lstRouteCard.add(objRouteCard);
                }   
                system.debug('List of Route Card Created: ' + lstRouteCard);
                if(lstRouteCard != null && lstRouteCard.size() > 0)
                { 
                    if( COMM_SecurityUtils.getInstance().verifyFieldAccess( lstRouteCard, COMM_SecurityUtils.Access.Upsertable ) ) {
                        upsert lstRouteCard; //SDL-SVMX-CREATE-UPDATE-FLS-ENFORCED
                    } else {
                        throw new COMM_SecurityUtils.SecurityAccessException( System.Label.COMM001_TAG142 );
                    }
                    
                    //here updating the route stops
                    for(SVMXC__Route_Card__c Temp : lstRouteCard)
                    {
                        objRouteStop = new SVMXC__Route_Stop__c();
                        objRouteStop.SVMXC__Record_Card__c = Temp.Id;
                        objRouteStop.SVMXC__Stop_Number__c = 1;
                        objRouteStop.SVMXC__Stop_Location__c = Temp.SVMXC__First_Stop__c;             
                        lstRouteStop.add(objRouteStop);
                    }
                }           
                         
            }
            system.debug('List of Route Stop Created: ' + lstRouteStop);
            //here we are updating the route stops
            if(lstRouteStop != null && lstRouteStop.size() > 0)
            {
                if( COMM_SecurityUtils.getInstance().verifyFieldAccess( lstRouteStop, COMM_SecurityUtils.Access.Upsertable ) ) {
                    upsert lstRouteStop; //SDL-SVMX-CREATE-UPDATE-FLS-ENFORCED
                } else {
                    throw new COMM_SecurityUtils.SecurityAccessException( System.Label.COMM001_TAG142 );
                }               
            }  
            
            SVMXC__Case_Line__c objCurr;
            for(SVMXC__Route_Card__c objTemp : lstRouteCard)
            {
                objCurr = mapIdCaseLine.get(objTemp.SVMXC__Case_Line__c);
                objCurr.SVMXC__Route_Card__c = objTemp.id;
                lstUpdateCaseLine.add(objCurr);
            }
            
            system.debug('List of Case Lines updated: ' + lstUpdateCaseLine);
            
            if(lstUpdateCaseLine != null && lstUpdateCaseLine.size() > 0) {
                if( COMM_SecurityUtils.getInstance().verifyFieldAccess( lstUpdateCaseLine, COMM_SecurityUtils.Access.Upsertable ) ) {
                    upsert lstUpdateCaseLine; //SDL-SVMX-CREATE-UPDATE-FLS-ENFORCED
                } else {
                    throw new COMM_SecurityUtils.SecurityAccessException( System.Label.COMM001_TAG142 );
                }
            }
            
            if(lstCaseLineFrRes != null && lstCaseLineFrRes.size() > 0)
            	objUpdateRouteResp.values = lstCaseLineFrRes;
            if(setNotConsideredProIDs.size() > 0)
            {
                String strProInfo = '';
                for(String strProIDCode : setNotConsideredProIDs)
                {
                    strProInfo += strProIDCode + ', ';
                }
                strProInfo = strProInfo.substring(0, strProInfo.length()-2);
                objUpdateRouteResp.valueMap.add(new INTF_WebServicesDef.SVMXMap('Info', strProInfo));
            }
        }
        catch(exception ex)
        {
            objUpdateRouteResp.success = false;          
            objUpdateRouteResp.valueMap.add(new INTF_WebServicesDef.SVMXMap('Error', ex.getMessage()));
        }
        return objUpdateRouteResp;
    }
    
    /*
        Security Fix : SECSCAN-413 (SUM 17)
        Description : SOQL injection Vulnerability on field SVMXC__Parent_Object_Criteria__c
        Date : 03/08/2017 
    */
    private String buildWhereClause(String genExpr, String routExpr, boolean isOnlyGen)
    {
        String strWhereClause = '';
        SVMXC__ServiceMax_Processes__c objExpression = null;
        SVMXC__ServiceMax_Processes__c objExpression1 = null;
        if(genExpr != null && genExpr.length() > 0)
        {
            objExpression = [Select Id, Name,SVMXC__Parent_Object_Criteria__c From SVMXC__ServiceMax_Processes__c where Recordtype.Name = 'SVMX Rule' AND SVMXC__Rule_Type__c = 'Named Expression' AND Id = :genExpr]; //SDL-SVMX-FLS-NOT-ENFORCED-META-DATA
            if(objExpression != null && objExpression.SVMXC__Parent_Object_Criteria__c != null && objExpression.SVMXC__Parent_Object_Criteria__c.length() > 0)
            {
                strWhereClause = '( ' + String.escapeSingleQuotes(objExpression.SVMXC__Parent_Object_Criteria__c) + ' )';
            }
        }
        if(isOnlyGen) return strWhereClause;
        
        if(routExpr != null && routExpr.length() > 0)
        {
            objExpression1 = [Select Id, Name,SVMXC__Parent_Object_Criteria__c From SVMXC__ServiceMax_Processes__c where Recordtype.Name = 'SVMX Rule' AND SVMXC__Rule_Type__c = 'Named Expression' AND Id = :routExpr]; //SDL-SVMX-FLS-NOT-ENFORCED-META-DATA
            if(objExpression1 != null && objExpression1.SVMXC__Parent_Object_Criteria__c != null && objExpression1.SVMXC__Parent_Object_Criteria__c.length() > 0)
            {
                if(strWhereClause.length() > 0) strWhereClause += ' AND ';
                strWhereClause +=  '( ' + String.escapeSingleQuotes(objExpression1.SVMXC__Parent_Object_Criteria__c) + ' )';
            }
        }
        return strWhereClause;
    }
    
    /***********************Tags methods ***********************/
    public String getTAG002(){return System.Label.APL001_TAG025;} //'No valid case line available.'
}