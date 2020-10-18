public with sharing class COMM_SVMXC_Utils4 
{
    //Return the default val for a field in object
    //Map<String, Schema.SObjectType> allObjs = Schema.getGlobalDescribe();

    /*************************************Generic Parsing Functionality **********************************/
    Map<Double,string> ExprsionMap = new Map<Double,string>();  
    public set<string> SetDateRange = new set<string>();
    public COMM_SVMXC_Utils4()
    {

        SetDateRange.add('THIS_WEEK');
        SetDateRange.add('NEXT_WEEK');
        SetDateRange.add('LAST_WEEK');
        SetDateRange.add('THIS_MONTH');
        SetDateRange.add('NEXT_MONTH');
        SetDateRange.add('LAST_MONTH');
        SetDateRange.add('NEXT_90_DATS');
        SetDateRange.add('LAST_90_DAYS');
        SetDateRange.add('TODAY');
        SetDateRange.add('TOMORROW');
        SetDateRange.add('YESTERDAY');  
    }
    public map<Id, string> SVMX_ExpressionParsing(map<Id, sObject> lstRec, map<Id, list<SVMXC__ServiceMax_Config_Data__c>> mapRulesExpressions, map<Id, SVMXC__ServiceMax_Processes__c> mapRules)
    {
        map<Id, string> mapResult = new map<Id, string>();
        list<SVMXC__ServiceMax_Processes__c> lstSortedRules = sortRuleList(mapRulesExpressions.KeySet(), mapRules);
        if(lstRec != null)
        {
            //System.debug('List of Records1 :' + lstRec + ' Rule Expres: ' + mapRulesExpressions + 'mapRules: ' + mapRules);
            for(Id iIndex: lstRec.KeySet())
            {
                sObject sObj = lstRec.get(iIndex);
                for(SVMXC__ServiceMax_Processes__c oSVMXProcess: lstSortedRules)
                {
                    Id IdRule = oSVMXProcess.Id;
                    if(mapRulesExpressions.ContainsKey(IdRule))
                    {
                        boolean IsRuleApplicable = false;
                        IsRuleApplicable = SVMX_ExpressionParsing(sObj, mapRulesExpressions.get(IdRule), mapRules.get(IdRule)!= null? mapRules.get(IdRule).SVMXC__Advance_Expression__c : '');
                        if(IsRuleApplicable)
                        {
                            mapResult.put(iIndex, IdRule);
                            break;
                        }
                    }
                }
            }
        }
        return mapResult;
    }  
    public map<string, string> SVMX_ExpressionParsing(map<string, sObject> lstRec, map<Id, list<SVMXC__ServiceMax_Config_Data__c>> mapRulesExpressions, map<Id, SVMXC__ServiceMax_Processes__c> mapRules)
    {
        map<string, string> mapResult = new map<string, string>();
        list<SVMXC__ServiceMax_Processes__c> lstSortedRules = sortRuleList(mapRulesExpressions.KeySet(), mapRules);
        if(lstRec != null)
        {
            //System.debug('List of Records2 :' + lstRec + ' Rule Expres: ' + mapRulesExpressions + 'mapRules: ' + mapRules);
            for(string iIndex: lstRec.KeySet())
            {
                sObject sObj = lstRec.get(iIndex);
                for(SVMXC__ServiceMax_Processes__c oSVMXProcess: lstSortedRules)
                {
                    Id IdRule = oSVMXProcess.Id;
                    if(mapRulesExpressions.ContainsKey(IdRule))
                    {
                        boolean IsRuleApplicable = false;
                        IsRuleApplicable = SVMX_ExpressionParsing(sObj, mapRulesExpressions.get(IdRule), mapRules.get(IdRule)!= null? mapRules.get(IdRule).SVMXC__Advance_Expression__c : '');
                        if(IsRuleApplicable)
                        {
                            mapResult.put(iIndex, IdRule);
                            break;
                        }
                    }
                }
            }
        }
        return mapResult;
    }
    public map<Integer, string> SVMX_ExpressionParsing(map<integer, sObject> lstRec, map<Id, list<SVMXC__ServiceMax_Config_Data__c>> mapRulesExpressions, map<Id, SVMXC__ServiceMax_Processes__c> mapRules)
    {
        map<Integer, string> mapResult = new map<Integer, string>();
        list<SVMXC__ServiceMax_Processes__c> lstSortedRules = sortRuleList(mapRulesExpressions.KeySet(), mapRules);
        if(lstRec != null)
        {
            //System.debug('List of Records3 :' + lstRec + ' Rule Expres: ' + mapRulesExpressions + 'mapRules: ' + mapRules);
            for(Integer iIndex: lstRec.KeySet())
            {
                sObject sObj = lstRec.get(iIndex);
                for(SVMXC__ServiceMax_Processes__c oSVMXProcess: lstSortedRules)
                {
                    Id IdRule = oSVMXProcess.Id;
                    if(mapRulesExpressions.ContainsKey(IdRule))
                    {
                        boolean IsRuleApplicable = false;
                        IsRuleApplicable = SVMX_ExpressionParsing(sObj, mapRulesExpressions.get(IdRule), mapRules.get(IdRule)!= null? mapRules.get(IdRule).SVMXC__Advance_Expression__c : '');
                        if(IsRuleApplicable)
                        {
                            mapResult.put(iIndex, IdRule);
                            break;
                        }
                    }
                }
            }
        }
        return mapResult;
    }
    public string SVMX_ExpressionParsing(SObject Rec, map<Id, list<SVMXC__ServiceMax_Config_Data__c>> mapRulesExpressions, map<Id, SVMXC__ServiceMax_Processes__c> mapRules)
    {
        if(mapRulesExpressions != null)
        {
            for(SVMXC__ServiceMax_Processes__c oSVMXRule: sortRuleList(mapRulesExpressions.KeySet(), mapRules))
            {
                string IdRule = oSVMXRule.Id;
                boolean IsRuleApplicable = false;
                IsRuleApplicable = SVMX_ExpressionParsing(Rec, mapRulesExpressions.get(IdRule), mapRules.get(IdRule)!= null? mapRules.get(IdRule).SVMXC__Advance_Expression__c : '');
                if(IsRuleApplicable)
                    return IdRule;
            }
        }
        return null;
    }
    
    public set<Id> SVMX_GetAllMatchingExpression(SObject Rec, map<Id, list<SVMXC__ServiceMax_Config_Data__c>> mapRulesExpressions, map<Id, SVMXC__ServiceMax_Processes__c> mapRules)
    {
        set<Id> response = new set<Id>();
        if(mapRulesExpressions != null)
        {
            //We are not sorting based on sequence since we consider all rules with same priority
            for(SVMXC__ServiceMax_Processes__c oSVMXRule: mapRules.values())
            {
                boolean IsRuleApplicable = false;
                String IdRule = oSVMXRule.Id;
                String advExpr = mapRules.get(IdRule)!= null? mapRules.get(IdRule).SVMXC__Primary_Consolidation_Rule__c : '';
                if(advExpr == NULL)
                    advExpr = '';
                IsRuleApplicable = SVMX_ExpressionParsing(Rec, mapRulesExpressions.get(IdRule), advExpr);
                system.debug(logginglevel.WARN, 'TEST LOG: IsRuleApplicable ' + oSVMXRule.Id + '->' + IsRuleApplicable);
                if(IsRuleApplicable)
                    response.add(oSVMXRule.Id);
            }
        }
        return response;
    }

    // #defectFix 047252, created this method to take advance experssion value from correct field SVMXC__Advance_Expression__c
    public set<Id> SVMX_GetChildMatchingExpression(SObject Rec, map<Id, list<SVMXC__ServiceMax_Config_Data__c>> mapRulesExpressions, map<Id, SVMXC__ServiceMax_Processes__c> mapRules)
    {
        set<Id> response = new set<Id>();
        if(mapRulesExpressions != null)
        {
            //We are not sorting based on sequence since we consider all rules with same priority
            for(SVMXC__ServiceMax_Processes__c oSVMXRule: mapRules.values())
            {
                boolean IsRuleApplicable = false;
                String IdRule = oSVMXRule.Id;
                String advExpr = mapRules.get(IdRule)!= null? mapRules.get(IdRule).SVMXC__Advance_Expression__c : '';
                if(advExpr == NULL)
                    advExpr = '';
                IsRuleApplicable = SVMX_ExpressionParsing(Rec, mapRulesExpressions.get(IdRule), advExpr);
                system.debug(logginglevel.WARN, 'TEST LOG: IsRuleApplicable ' + oSVMXRule.Id + '->' + IsRuleApplicable);
                if(IsRuleApplicable)
                    response.add(oSVMXRule.Id);
            }
        }
        return response;
    }
    
    public string SVMX_ExpressionParsing(SObject Rec, map<Id, list<SVMXC__ServiceMax_Config_Data__c>> mapRulesExpressions, map<Id, SVMXC__ServiceMax_Processes__c> mapRules, boolean IsSortAssending)
    {
        if(mapRulesExpressions != null)
        {
            for(SVMXC__ServiceMax_Processes__c oSVMXRule: sortRuleList(mapRulesExpressions.KeySet(), mapRules, IsSortAssending))
            {
                string IdRule = oSVMXRule.Id;
                boolean IsRuleApplicable = false;
                IsRuleApplicable = SVMX_ExpressionParsing(Rec, mapRulesExpressions.get(IdRule), mapRules.get(IdRule)!= null? mapRules.get(IdRule).SVMXC__Advance_Expression__c : '');
                if(IsRuleApplicable)
                    return IdRule;
            }
        }
        return null;
    }
    
    public Boolean SVMX_ExpressionParsing(SObject Rec, list<SVMXC__ServiceMax_Config_Data__c> lstExpressions, string AdvExp,Boolean callOverloadedDT)
    {
     
        //commented below debug as part of defect 043920   
       // system.debug( 'SVMX_ExpressionParsing - enter; expressions ' + lstExpressions );
        if(lstExpressions == null || lstExpressions.size() == 0)
            return true;
        Map<Double,string> mapResult = new Map<Double,string>(); 
        string ExpVal;
        integer ExpKey;
        lstExpressions = sortingExpressionList(lstExpressions);
        //commented below debug as part of defect 043920 
       // system.debug( 'SVMX_ExpressionParsing - enter; expressions 22 ' + lstExpressions );
        for(SVMXC__ServiceMax_Config_Data__c oExpression: lstExpressions)
        {
            System.debug('oExpression '+oExpression.id);
            mapResult.put(oExpression.SVMXC__Sequence__c,'F');
            string FieldType = oExpression.SVMXC__Display_Type__c ;
            //system.debug(logginglevel.WARN, 'dtype:'+FieldType);
            if(FieldType != null && FieldType.length() > 0 && oExpression.SVMXC__Operator__c != null && oExpression.SVMXC__Operator__c.length() > 0 && oExpression.SVMXC__Field_Name__c != NULL && oExpression.SVMXC__Field_Name__c.length() > 0)
            {
                // Added by Bala(Feb 21 2011): If field specified in expression is not available in org, the expression will be skipped
                try
                {
                    if( oExpression.get('SVMXC__Field_Name__c') != null )
                        Rec.get(oExpression.SVMXC__Field_Name__c);
                }
                catch(SObjectException ex)
                {
                    System.debug( LoggingLevel.WARN, ex.getMessage() );
                    System.debug( LoggingLevel.WARN, ex.getStackTraceString() );
                    continue;
                }
                string strOperater = oExpression.SVMXC__Operator__c.ToUpperCase();
                string strFieldType = '';
                if( FieldType != null)
                    strFieldType = String.valueOf(FieldType.ToUpperCase());
                //commented below debug as part of defect 043920 
                //system.debug('expeeee'+strOperater);
                //system.debug('expeeee'+strFieldType);
                
                //system.debug('Rec '+Rec);
                String referenceValue = null;
                /*Added elseif condition to handle record type field in Sobjects -: Soumyaranjan*/
                try {
                    if( oExpression.get('SVMXC__Field_Relationship_Name__c') != null && oExpression.get('SVMXC__FKey_Name_Field__c') != null && Rec.getSObject(oExpression.SVMXC__Field_Relationship_Name__c) != null) {
                        referenceValue = (String) Rec.getSObject(oExpression.SVMXC__Field_Relationship_Name__c).get(oExpression.SVMXC__FKey_Name_Field__c);
                    }else if(oExpression.SVMXC__Field_Relationship_Name__c=='RecordType' && oExpression.SVMXC__Field_Name__c=='RecordTypeId' && oExpression.get('SVMXC__Operand__c') != null){
                        referenceValue = oExpression.SVMXC__Operand__c;
                    }
                }
                catch( Exception ex ) {
                    system.debug(LoggingLevel.DEBUG, 'Exception: Type - ' + ex.getTypeName() + '; Line No. - ' + ex.getLineNumber() + '; Cause - ' + ex.getCause() + '; Message - ' + ex.getMessage()+ '; Stack Trace - ' + ex.getStackTraceString());               
                }
                
                 if(strFieldType == 'STRING' ||strFieldType == 'COMBOBOX' || strFieldType == 'PICKLIST' || strFieldType == 'PHONE' || strFieldType == 'URL' || strFieldType == 'TEXTAREA' || strFieldType == 'EMAIL')
                {
                    if(strOperater == 'ISNULL')
                    {
                        if(Rec.get(oExpression.SVMXC__Field_Name__c) == null)
                            mapResult.put(oExpression.SVMXC__Sequence__c,'T');
                    }
                    else if(strOperater == 'ISNOTNULL')
                    {
                        if(Rec.get(oExpression.SVMXC__Field_Name__c) != null)
                            mapResult.put(oExpression.SVMXC__Sequence__c,'T');                  
                    }
                    string Val;
                    if(Rec.get(oExpression.SVMXC__Field_Name__c) != null)
                        val = string.valueOf(Rec.get(oExpression.SVMXC__Field_Name__c));
                    if(strOperater == 'EQ')
                    {
                        if(Val == oExpression.SVMXC__Operand__c)
                            mapResult.put(oExpression.SVMXC__Sequence__c,'T');
                    }
                    else if(strOperater == 'NE')
                    {
                        if(Val != oExpression.SVMXC__Operand__c)
                            mapResult.put(oExpression.SVMXC__Sequence__c,'T');
                    }
                    else if(strOperater == 'STARTS' )
                    {
                        if(Val != null)
                        {
                            if(Val.startsWith(oExpression.SVMXC__Operand__c))
                                mapResult.put(oExpression.SVMXC__Sequence__c,'T');
                        }
                    }
                    else if(strOperater == 'CONTAINS')
                    {
                        if(Val != null)
                        {
                            if(Val.contains(oExpression.SVMXC__Operand__c))
                                mapResult.put(oExpression.SVMXC__Sequence__c,'T');
                        }
                    }
                    else if(strOperater == 'NOTCONTAIN' || strOperater == 'NOTCONTAINS')
                    {
                        if(Val != null)
                        {
                            if(!Val.contains(oExpression.SVMXC__Operand__c))
                                mapResult.put(oExpression.SVMXC__Sequence__c,'T');
                        }
                    }
                    else if(strOperater == 'IN' || strOperater == 'NOTIN')
                    {
                        String[] multValues = oExpression.SVMXC__Operand__c.split(',');
                        set<string> setValues = new set<string>();
                        if(multValues != null)
                        {
                            for(string str: multValues)
                            {
                                setValues.add(str);
                            }
                        }
                        if(setValues.contains(Val) && strOperater == 'IN')
                            mapResult.put(oExpression.SVMXC__Sequence__c,'T');
                        if(!setValues.contains(Val) && strOperater == 'NOTIN')
                            mapResult.put(oExpression.SVMXC__Sequence__c,'T');
                    }
                    else if(strOperater == 'LT')
                    {
                        if(Val < oExpression.SVMXC__Operand__c)
                            mapResult.put(oExpression.SVMXC__Sequence__c,'T');
                    }
                    else if(strOperater == 'GT')
                    {
                        if(Val > oExpression.SVMXC__Operand__c)
                            mapResult.put(oExpression.SVMXC__Sequence__c,'T');
                    }
                    else if(strOperater == 'LE')
                    {
                        if(Val <= oExpression.SVMXC__Operand__c)
                            mapResult.put(oExpression.SVMXC__Sequence__c,'T');
                    }
                    else if(strOperater == 'GE')
                    {
                        if(Val >= oExpression.SVMXC__Operand__c)
                            mapResult.put(oExpression.SVMXC__Sequence__c,'T');
                    }
                }//mapFieldDisplayType.get(oExpression.SVMXC__Field_Name__c)=='REFERENCE'
                else if(strFieldType == 'BOOLEAN')
                {
                    if(strOperater == 'ISNULL')
                    {
                        if(Rec.get(oExpression.SVMXC__Field_Name__c) == null)
                            mapResult.put(oExpression.SVMXC__Sequence__c,'T');
                    }
                    else if(strOperater == 'ISNOTNULL')
                    {
                        if(Rec.get(oExpression.SVMXC__Field_Name__c) != null)
                            mapResult.put(oExpression.SVMXC__Sequence__c,'T');
                    }
                    string Val;
                    if(Rec.get(oExpression.SVMXC__Field_Name__c) != null)
                        val = string.valueOf(Rec.get(oExpression.SVMXC__Field_Name__c));
                    if(strOperater == 'EQ')
                    {
                        if('TRUE' == oExpression.SVMXC__Operand__c.ToUpperCase() && (boolean)Rec.get(oExpression.SVMXC__Field_Name__c))
                            mapResult.put(oExpression.SVMXC__Sequence__c,'T');
                        if('FALSE' == oExpression.SVMXC__Operand__c.ToUpperCase() && !((boolean)Rec.get(oExpression.SVMXC__Field_Name__c)))
                            mapResult.put(oExpression.SVMXC__Sequence__c,'T');
                    }
                    else if(strOperater == 'NE')
                    {
                        if('TRUE' == oExpression.SVMXC__Operand__c.ToUpperCase() && !((boolean)Rec.get(oExpression.SVMXC__Field_Name__c)))
                            mapResult.put(oExpression.SVMXC__Sequence__c,'T');
                        if('FALSE' == oExpression.SVMXC__Operand__c.ToUpperCase() && (boolean)Rec.get(oExpression.SVMXC__Field_Name__c))
                            mapResult.put(oExpression.SVMXC__Sequence__c,'T');
                    }
                }
                else if(strFieldType == 'INTEGER')
                {
                    if(strOperater == 'ISNULL')
                    {
                        if(Rec.get(oExpression.SVMXC__Field_Name__c) == null)
                            mapResult.put(oExpression.SVMXC__Sequence__c,'T');
                    }
                    else if(strOperater == 'ISNOTNULL')
                    {
                        if(Rec.get(oExpression.SVMXC__Field_Name__c) != null)
                            mapResult.put(oExpression.SVMXC__Sequence__c,'T');
                    }
                    Integer Val;
                    if(Rec.get(oExpression.SVMXC__Field_Name__c) != null)
                        val = ((Decimal)Rec.get(oExpression.SVMXC__Field_Name__c)).IntValue();
                    if(strOperater == 'EQ')
                    {
                        if(Val == Integer.valueOf(oExpression.SVMXC__Operand__c))
                            mapResult.put(oExpression.SVMXC__Sequence__c,'T');
                    }
                    else if(strOperater == 'NE')
                    {
                        if(Val != Integer.valueOf(oExpression.SVMXC__Operand__c))
                            mapResult.put(oExpression.SVMXC__Sequence__c,'T');
                    }
                    else if(strOperater == 'LT')
                    {
                        if(Val < Integer.valueOf(oExpression.SVMXC__Operand__c))
                            mapResult.put(oExpression.SVMXC__Sequence__c,'T');
                    }
                    else if(strOperater == 'GT')
                    {
                        if(Val > Integer.valueOf(oExpression.SVMXC__Operand__c))
                            mapResult.put(oExpression.SVMXC__Sequence__c,'T');
                    }
                    else if(strOperater == 'LE')
                    {
                        if(Val <= Integer.valueOf(oExpression.SVMXC__Operand__c))
                            mapResult.put(oExpression.SVMXC__Sequence__c,'T');
                    }
                    else if(strOperater == 'GE')
                    {
                        if(Val >= Integer.valueOf(oExpression.SVMXC__Operand__c))
                            mapResult.put(oExpression.SVMXC__Sequence__c,'T');
                    }
                    else if(strOperater == 'IN' || strOperater == 'NOTIN')
                    {
                        String[] multValues = oExpression.SVMXC__Operand__c.split(',');
                        set<Integer> setValues = new set<Integer>();
                        if(multValues != null)
                        {
                            for(string str: multValues)
                            {
                                setValues.add(integer.valueOf(str));
                            }
                        }
                        if(setValues.contains(Val) && strOperater == 'IN')
                            mapResult.put(oExpression.SVMXC__Sequence__c,'T');
                        if(!setValues.contains(Val) && strOperater == 'NOTIN')
                            mapResult.put(oExpression.SVMXC__Sequence__c,'T');
                    }
                }
                else if(strFieldType == 'CURRENCY' || strFieldType == 'DECIMAL')
                {
                    if(strOperater == 'ISNULL')
                    {
                        if(Rec.get(oExpression.SVMXC__Field_Name__c) == null)
                            mapResult.put(oExpression.SVMXC__Sequence__c,'T');
                    }
                    else if(strOperater == 'ISNOTNULL')
                    {
                        if(Rec.get(oExpression.SVMXC__Field_Name__c) != null)
                            mapResult.put(oExpression.SVMXC__Sequence__c,'T');
                    }
                    DECIMAL Val;
                    if(Rec.get(oExpression.SVMXC__Field_Name__c) != null)
                        val = Decimal.valueOf(((Double)Rec.get(oExpression.SVMXC__Field_Name__c)));
                    if(strOperater == 'EQ')
                    {
                        if(Val == DECIMAL.valueOf(oExpression.SVMXC__Operand__c))
                            mapResult.put(oExpression.SVMXC__Sequence__c,'T');
                    }
                    else if(strOperater == 'NE')
                    {
                        if(Val != DECIMAL.valueOf(oExpression.SVMXC__Operand__c))
                            mapResult.put(oExpression.SVMXC__Sequence__c,'T');
                    }
                    else if(strOperater == 'LT')
                    {
                        if(Val < DECIMAL.valueOf(oExpression.SVMXC__Operand__c))
                            mapResult.put(oExpression.SVMXC__Sequence__c,'T');
                    }
                    else if(strOperater == 'GT')
                    {
                        if(Val > DECIMAL.valueOf(oExpression.SVMXC__Operand__c))
                            mapResult.put(oExpression.SVMXC__Sequence__c,'T');
                    }
                    else if(strOperater == 'LE')
                    {
                        if(Val <= DECIMAL.valueOf(oExpression.SVMXC__Operand__c))
                            mapResult.put(oExpression.SVMXC__Sequence__c,'T');
                    }
                    else if(strOperater == 'GE')
                    {
                        if(Val >= DECIMAL.valueOf(oExpression.SVMXC__Operand__c))
                            mapResult.put(oExpression.SVMXC__Sequence__c,'T');
                    }
                    else if(strOperater == 'IN' || strOperater == 'NOTIN')
                    {
                        String[] multValues = oExpression.SVMXC__Operand__c.split(',');
                        set<DECIMAL> setValues = new set<DECIMAL>();
                        if(multValues != null)
                        {
                            for(string str: multValues)
                            {
                                setValues.add(DECIMAL.valueOf(str));
                            }
                        }
                        if(setValues.contains(Val) && strOperater == 'IN')
                            mapResult.put(oExpression.SVMXC__Sequence__c,'T');
                        if(!setValues.contains(Val) && strOperater == 'NOTIN')
                            mapResult.put(oExpression.SVMXC__Sequence__c,'T');
                    }
                }
                else if(strFieldType == 'DOUBLE')
                {
                    
                    if(strOperater == 'ISNULL')
                    {
                        if(Rec.get(oExpression.SVMXC__Field_Name__c) == null)
                            mapResult.put(oExpression.SVMXC__Sequence__c,'T');
                    }
                    else if(strOperater == 'ISNOTNULL')
                    {
                        if(Rec.get(oExpression.SVMXC__Field_Name__c) != null)
                            mapResult.put(oExpression.SVMXC__Sequence__c,'T');
                    }
                    DOUBLE Val;
                    if(Rec.get(oExpression.SVMXC__Field_Name__c) != null)
                        val = (DOUBLE)Rec.get(oExpression.SVMXC__Field_Name__c);
                    if(strOperater == 'EQ')
                    {
                        if(Val == DOUBLE.valueOf(oExpression.SVMXC__Operand__c))
                            mapResult.put(oExpression.SVMXC__Sequence__c,'T');
                    }
                    else if(strOperater == 'NE')
                    {
                        if(Val != DOUBLE.valueOf(oExpression.SVMXC__Operand__c))
                            mapResult.put(oExpression.SVMXC__Sequence__c,'T');
                    }
                    else if(strOperater == 'LT')
                    {
                        if(Val < DOUBLE.valueOf(oExpression.SVMXC__Operand__c))
                            mapResult.put(oExpression.SVMXC__Sequence__c,'T');
                    }
                    else if(strOperater == 'GT')
                    {
                        if(Val > DOUBLE.valueOf(oExpression.SVMXC__Operand__c))
                            mapResult.put(oExpression.SVMXC__Sequence__c,'T');
                    }
                    else if(strOperater == 'LE')
                    {
                        if(Val <= DOUBLE.valueOf(oExpression.SVMXC__Operand__c))
                            mapResult.put(oExpression.SVMXC__Sequence__c,'T');
                    }
                    else if(strOperater == 'GE')
                    {
                        if(Val >= DOUBLE.valueOf(oExpression.SVMXC__Operand__c))
                            mapResult.put(oExpression.SVMXC__Sequence__c,'T');
                    }
                    else if(strOperater == 'IN' || strOperater == 'NOTIN')
                    {
                        String[] multValues = oExpression.SVMXC__Operand__c.split(',');
                        set<DOUBLE> setValues = new set<DOUBLE>();
                        if(multValues != null)
                        {
                            for(string str: multValues)
                            {
                                setValues.add(DOUBLE.valueOf(str));
                            }
                        }
                        if(setValues.contains(Val) && strOperater == 'IN')
                            mapResult.put(oExpression.SVMXC__Sequence__c,'T');
                        if(!setValues.contains(Val) && strOperater == 'NOTIN')
                            mapResult.put(oExpression.SVMXC__Sequence__c,'T');
                    }
                }                
                else if(strFieldType == 'ID' || strFieldType == 'REFERENCE')
                {
                    if(strOperater == 'ISNULL')
                    {
                        if(Rec.get(oExpression.SVMXC__Field_Name__c) == null)
                            mapResult.put(oExpression.SVMXC__Sequence__c,'T');
                    }
                    else if(strOperater == 'ISNOTNULL')
                    {
                        if(Rec.get(oExpression.SVMXC__Field_Name__c) != null)
                            mapResult.put(oExpression.SVMXC__Sequence__c,'T');
                    }
                    Id Val;
                    if(Rec.get(oExpression.SVMXC__Field_Name__c) != null)
                        val = string.valueOf(Rec.get(oExpression.SVMXC__Field_Name__c));
                    if(strOperater == 'EQ')
                    {
                        if( referenceValue != null ) { 
                            if( referenceValue == oExpression.SVMXC__Operand__c ) {
                                mapResult.put(oExpression.SVMXC__Sequence__c,'T');
                            }
                        } else if(Val == (Id)oExpression.SVMXC__Operand__c)
                            mapResult.put(oExpression.SVMXC__Sequence__c,'T');
                    }
                    else if(strOperater == 'NE')
                    {
                        if( referenceValue != null ) {
                            if( referenceValue != oExpression.SVMXC__Operand__c ) {
                                mapResult.put(oExpression.SVMXC__Sequence__c,'T');
                            }
                        } else if(Val != (Id)oExpression.SVMXC__Operand__c)
                            mapResult.put(oExpression.SVMXC__Sequence__c,'T');
                    }
                    else if(strOperater == 'IN' || strOperater == 'NOTIN')
                    {
                        String[] multValues = oExpression.SVMXC__Operand__c.split(',');
                        set<string> setValues = new set<string>();
                        if(multValues != null)
                        {
                            for(string str: multValues)
                            {
                                setValues.add(str);
                            }
                        }
                        if( referenceValue != null ) {                            
                            if( setValues.contains( referenceValue ) ) {
                                mapResult.put(oExpression.SVMXC__Sequence__c,'T');
                            }
                        } else if(setValues.contains(Val) && strOperater == 'IN')
                            mapResult.put(oExpression.SVMXC__Sequence__c, 'T');
                        if(!setValues.contains(Val) && strOperater == 'NOTIN')
                            mapResult.put(oExpression.SVMXC__Sequence__c, 'T');
                    }
                    else if(strOperater == 'STARTS' )
                    {
                        if(Val != null)
                        {
                            if( referenceValue != null ) {
                                if( referenceValue.startsWith( oExpression.SVMXC__Operand__c ) ) {
                                    mapResult.put(oExpression.SVMXC__Sequence__c,'T');
                                }
                            } else if(string.valueof(Val).startsWith(oExpression.SVMXC__Operand__c))
                                mapResult.put(oExpression.SVMXC__Sequence__c,'T');
                        }
                    }
                    else if(strOperater == 'CONTAINS')
                    {
                        if(Val != null)
                        {
                            if( referenceValue != null ) {
                                if( referenceValue.contains( oExpression.SVMXC__Operand__c ) ) {
                                    mapResult.put(oExpression.SVMXC__Sequence__c,'T');
                                }
                            } else if(string.valueof(Val).contains(oExpression.SVMXC__Operand__c))
                                mapResult.put(oExpression.SVMXC__Sequence__c,'T');
                        }
                    }
                    else if(strOperater == 'NOTCONTAIN' || strOperater == 'NOTCONTAINS')
                    {
                        if(Val != null)
                        {
                            if( referenceValue != null ) {
                                if( !referenceValue.contains( oExpression.SVMXC__Operand__c ) ) {
                                    mapResult.put(oExpression.SVMXC__Sequence__c,'T');
                                }
                            } else if(!string.valueof(Val).contains(oExpression.SVMXC__Operand__c))
                                mapResult.put(oExpression.SVMXC__Sequence__c,'T');
                        }
                    }                    
                    else if(strOperater == 'LT')
                    {
                        if( referenceValue != null ) {
                            if( referenceValue < oExpression.SVMXC__Operand__c ) {
                                mapResult.put(oExpression.SVMXC__Sequence__c,'T');
                            }
                        } else if(string.valueof(Val) < oExpression.SVMXC__Operand__c)
                            mapResult.put(oExpression.SVMXC__Sequence__c,'T');
                    }
                    else if(strOperater == 'GT')
                    {
                        if( referenceValue != null ) {
                            if( referenceValue > oExpression.SVMXC__Operand__c ) {
                                mapResult.put(oExpression.SVMXC__Sequence__c,'T');
                            }
                        } else if(string.valueof(Val) > oExpression.SVMXC__Operand__c)
                            mapResult.put(oExpression.SVMXC__Sequence__c,'T');
                    }
                    else if(strOperater == 'LE')
                    {
                        if( referenceValue != null ) {
                            if( referenceValue <= oExpression.SVMXC__Operand__c ) {
                                mapResult.put(oExpression.SVMXC__Sequence__c,'T');
                            }
                        } else if(string.valueof(Val) <= oExpression.SVMXC__Operand__c)
                            mapResult.put(oExpression.SVMXC__Sequence__c,'T');
                    }
                    else if(strOperater == 'GE')
                    {
                        if( referenceValue != null ) {
                            if( referenceValue >= oExpression.SVMXC__Operand__c ) {
                                mapResult.put(oExpression.SVMXC__Sequence__c,'T');
                            }
                        } else if(string.valueof(Val) >= oExpression.SVMXC__Operand__c)
                            mapResult.put(oExpression.SVMXC__Sequence__c,'T');
                    }
                }
                else if(strFieldType == 'DATE')
                {
                    if(strOperater == 'ISNULL')
                    {
                        if(Rec.get(oExpression.SVMXC__Field_Name__c) == null)
                            mapResult.put(oExpression.SVMXC__Sequence__c,'T');
                    }
                    else if(strOperater == 'ISNOTNULL')
                    {
                        if(Rec.get(oExpression.SVMXC__Field_Name__c) != null)
                            mapResult.put(oExpression.SVMXC__Sequence__c,'T');
                    }
                    Date Val;
                    if(Rec.get(oExpression.SVMXC__Field_Name__c) != null)
                        val = (date)Rec.get(oExpression.SVMXC__Field_Name__c);
                    if(strOperater == 'EQ')
                    {
                         if(SetDateRange.contains(oExpression.SVMXC__Operand__c.toUpperCase()))
                        {
                            if(isDateInRange(oExpression.SVMXC__Operand__c, Val))
                                mapResult.put(oExpression.SVMXC__Sequence__c,'T');
                        }
                        else if(Val == getDate(oExpression.SVMXC__Operand__c))
                            mapResult.put(oExpression.SVMXC__Sequence__c,'T');
                    }
                    else if(strOperater == 'NE')
                    {
                         if(SetDateRange.contains(oExpression.SVMXC__Operand__c.toUpperCase()))
                        {
                            if(!(isDateInRange(oExpression.SVMXC__Operand__c, Val)))
                                mapResult.put(oExpression.SVMXC__Sequence__c,'T');
                        }
                        if(Val != getDate(oExpression.SVMXC__Operand__c))
                            mapResult.put(oExpression.SVMXC__Sequence__c,'T');
                    }
                    else if(strOperater == 'IN' || strOperater == 'NOTIN')
                    {
                        String[] multValues = oExpression.SVMXC__Operand__c.split(',');
                        set<Date> setValues = new set<Date>();
                        if(multValues != null)
                        {
                            for(string str: multValues)
                            {
                                setValues.add(getDate(str));
                            }
                        }
                        if(setValues.contains(Val) && strOperater == 'IN')
                            mapResult.put(oExpression.SVMXC__Sequence__c,'T');
                        if(!setValues.contains(Val) && strOperater == 'NOTIN')
                            mapResult.put(oExpression.SVMXC__Sequence__c,'T');
                    }
                    else if(strOperater == 'LT')
                    {
                        if(SetDateRange.contains(oExpression.SVMXC__Operand__c.toUpperCase()))
                        {
                            
                            if(val < getDate(oExpression.SVMXC__Operand__c))                            
                                mapResult.put(oExpression.SVMXC__Sequence__c,'T');                          
                        }
                        else if((Date)Val < Date.valueOf(oExpression.SVMXC__Operand__c))
                            mapResult.put(oExpression.SVMXC__Sequence__c,'T');
                    }
                    else if(strOperater == 'GT')
                    {   if(SetDateRange.contains(oExpression.SVMXC__Operand__c.toUpperCase()))
                        {
                            
                            if(val > getDate(oExpression.SVMXC__Operand__c))                            
                                mapResult.put(oExpression.SVMXC__Sequence__c,'T');
                        }
                        else if((Date)Val > Date.valueOf(oExpression.SVMXC__Operand__c))
                            mapResult.put(oExpression.SVMXC__Sequence__c,'T');
                    }
                    else if(strOperater == 'LE')
                    {   
                        if(SetDateRange.contains(oExpression.SVMXC__Operand__c.toUpperCase()))
                        {
                            if(val <= getDate(oExpression.SVMXC__Operand__c))
                                mapResult.put(oExpression.SVMXC__Sequence__c,'T');
                        }
                        else if((Date)Val <= Date.valueOf(oExpression.SVMXC__Operand__c))
                            mapResult.put(oExpression.SVMXC__Sequence__c,'T');
                    }
                    else if(strOperater == 'GE')
                    {
                        if(SetDateRange.contains(oExpression.SVMXC__Operand__c.toUpperCase()))
                        {
                            if(val >= getDate(oExpression.SVMXC__Operand__c))
                                mapResult.put(oExpression.SVMXC__Sequence__c,'T');
                        }
                        else if((Date)Val >= Date.valueOf(oExpression.SVMXC__Operand__c))
                            mapResult.put(oExpression.SVMXC__Sequence__c,'T');
                    }
                }
                else if(strFieldType == 'DATETIME')
                {
                    /*
                    New Code to ensure DateTime fields are compared in USER Locale. 
                    DateTime values are not Hard-Coded with '-' before conversion.
                    */
                    if(callOverloadedDT){

                        if(strOperater == 'ISNULL')
                        {
                            if(Rec.get(oExpression.SVMXC__Field_Name__c) == null)
                                mapResult.put(oExpression.SVMXC__Sequence__c,'T');
                        }
                        else if(strOperater == 'ISNOTNULL')
                        {
                            if(Rec.get(oExpression.SVMXC__Field_Name__c) != null)
                                mapResult.put(oExpression.SVMXC__Sequence__c,'T');
                        }
                        object Val;
                        if(Rec.get(oExpression.SVMXC__Field_Name__c) != null)
                            val = Rec.get(oExpression.SVMXC__Field_Name__c);
                        if(strOperater == 'EQ')
                        {
                            if(SetDateRange.contains(oExpression.SVMXC__Operand__c.toUpperCase()))
                            {
                                if(val != null && isDateTimeInRange(oExpression.SVMXC__Operand__c, Val))
                                    mapResult.put(oExpression.SVMXC__Sequence__c,'T');
                            }
                            else if(Val == (object)getDateTimeValueOF(oExpression.SVMXC__Operand__c))
                                mapResult.put(oExpression.SVMXC__Sequence__c,'T');
                        }
                        else if(strOperater == 'NE')
                        {
                            if(SetDateRange.contains(oExpression.SVMXC__Operand__c.toUpperCase()))
                            {   
                                if(val != null && !isDateTimeInRange(oExpression.SVMXC__Operand__c, Val))
                                    mapResult.put(oExpression.SVMXC__Sequence__c,'T');
                            }
                            else if(Val != (object)getDateTimeValueOF(oExpression.SVMXC__Operand__c))
                                mapResult.put(oExpression.SVMXC__Sequence__c,'T');
                        }
                        else if(strOperater == 'LT')
                        {
                            if(SetDateRange.contains(oExpression.SVMXC__Operand__c.toUpperCase()))
                            {
                                if(val != null && ((DateTime)val).date() < getDate(oExpression.SVMXC__Operand__c))
                                    mapResult.put(oExpression.SVMXC__Sequence__c,'T');
                            }
                            else if((DateTime)Val < getDateTimeValueOF(oExpression.SVMXC__Operand__c))
                                mapResult.put(oExpression.SVMXC__Sequence__c,'T');
                        }
                        else if(strOperater == 'GT')
                        {   if(SetDateRange.contains(oExpression.SVMXC__Operand__c.toUpperCase()))
                            {
                                if(val != null && ((DateTime)val).date()> getDate(oExpression.SVMXC__Operand__c))
                                    mapResult.put(oExpression.SVMXC__Sequence__c,'T');
                            }
                            else if((DateTime)Val > getDateTimeValueOF(oExpression.SVMXC__Operand__c))
                                mapResult.put(oExpression.SVMXC__Sequence__c,'T');
                        }
                        else if(strOperater == 'LE')
                        {   
                            if(SetDateRange.contains(oExpression.SVMXC__Operand__c.toUpperCase()))
                            {
                                if(val != null && ((DateTime)val).date() <= getDate(oExpression.SVMXC__Operand__c))
                                    mapResult.put(oExpression.SVMXC__Sequence__c,'T');
                            }
                            else if((DateTime)Val <= getDateTimeValueOF(oExpression.SVMXC__Operand__c))
                                mapResult.put(oExpression.SVMXC__Sequence__c,'T');
                        }
                        else if(strOperater == 'GE')
                        {
                            if(SetDateRange.contains(oExpression.SVMXC__Operand__c.toUpperCase()))
                            {                           
                                if(val != null && ((DateTime)val).date() >= getDate(oExpression.SVMXC__Operand__c))
                                    mapResult.put(oExpression.SVMXC__Sequence__c,'T');
                            }
                            else if((DateTime)Val >= getDateTimeValueOF(oExpression.SVMXC__Operand__c))
                                mapResult.put(oExpression.SVMXC__Sequence__c,'T');
                        }
                        else if(strOperater == 'IN' || strOperater == 'NOTIN')
                        {
                            String[] multValues = oExpression.SVMXC__Operand__c.split(',');
                            set<object> setValues = new set<object>();
                            if(multValues != null)
                            {
                                for(string str: multValues)
                                {
                                    setValues.add((object)getDateTimeValueOF(str));
                                }
                            }
                            if(setValues.contains(Val) && strOperater == 'IN')
                                mapResult.put(oExpression.SVMXC__Sequence__c,'T');
                            if(!setValues.contains(Val) && strOperater == 'NOTIN')
                                mapResult.put(oExpression.SVMXC__Sequence__c,'T');
                        }
    
                    }
                    else{

                        if(strOperater == 'ISNULL')
                        {
                            if(Rec.get(oExpression.SVMXC__Field_Name__c) == null)
                                mapResult.put(oExpression.SVMXC__Sequence__c,'T');
                        }
                        else if(strOperater == 'ISNOTNULL')
                        {
                            if(Rec.get(oExpression.SVMXC__Field_Name__c) != null)
                                mapResult.put(oExpression.SVMXC__Sequence__c,'T');
                        }
                        object Val;
                        if(Rec.get(oExpression.SVMXC__Field_Name__c) != null)
                            val = Rec.get(oExpression.SVMXC__Field_Name__c);
                        if(strOperater == 'EQ')
                        {
                            if(SetDateRange.contains(oExpression.SVMXC__Operand__c.toUpperCase()))
                            {
                                if(val != null && isDateTimeInRange(oExpression.SVMXC__Operand__c, Val))
                                    mapResult.put(oExpression.SVMXC__Sequence__c,'T');
                            }
                            else if(Val == (object)getDateTime(oExpression.SVMXC__Operand__c))
                                mapResult.put(oExpression.SVMXC__Sequence__c,'T');
                        }
                        else if(strOperater == 'NE')
                        {
                            if(SetDateRange.contains(oExpression.SVMXC__Operand__c.toUpperCase()))
                            {   
                                if(val != null && !isDateTimeInRange(oExpression.SVMXC__Operand__c, Val))
                                    mapResult.put(oExpression.SVMXC__Sequence__c,'T');
                            }
                            else if(Val != (object)getDateTime(oExpression.SVMXC__Operand__c))
                                mapResult.put(oExpression.SVMXC__Sequence__c,'T');
                        }
                        else if(strOperater == 'LT')
                        {
                            if(SetDateRange.contains(oExpression.SVMXC__Operand__c.toUpperCase()))
                            {
                                if(val != null && ((DateTime)val).date() < getDate(oExpression.SVMXC__Operand__c))
                                    mapResult.put(oExpression.SVMXC__Sequence__c,'T');
                            }
                            else if((DateTime)Val < getDateTime(oExpression.SVMXC__Operand__c))
                                mapResult.put(oExpression.SVMXC__Sequence__c,'T');
                        }
                        else if(strOperater == 'GT')
                        {   if(SetDateRange.contains(oExpression.SVMXC__Operand__c.toUpperCase()))
                            {
                                if(val != null && ((DateTime)val).date()> getDate(oExpression.SVMXC__Operand__c))
                                    mapResult.put(oExpression.SVMXC__Sequence__c,'T');
                            }
                            else if((DateTime)Val > getDateTime(oExpression.SVMXC__Operand__c))
                                mapResult.put(oExpression.SVMXC__Sequence__c,'T');
                        }
                        else if(strOperater == 'LE')
                        {   
                            if(SetDateRange.contains(oExpression.SVMXC__Operand__c.toUpperCase()))
                            {
                                if(val != null && ((DateTime)val).date() <= getDate(oExpression.SVMXC__Operand__c))
                                    mapResult.put(oExpression.SVMXC__Sequence__c,'T');
                            }
                            else if((DateTime)Val <= getDateTime(oExpression.SVMXC__Operand__c))
                                mapResult.put(oExpression.SVMXC__Sequence__c,'T');
                        }
                        else if(strOperater == 'GE')
                        {
                            if(SetDateRange.contains(oExpression.SVMXC__Operand__c.toUpperCase()))
                            {                           
                                if(val != null && ((DateTime)val).date() >= getDate(oExpression.SVMXC__Operand__c))
                                    mapResult.put(oExpression.SVMXC__Sequence__c,'T');
                            }
                            else if((DateTime)Val >= getDateTime(oExpression.SVMXC__Operand__c))
                                mapResult.put(oExpression.SVMXC__Sequence__c,'T');
                        }
                        else if(strOperater == 'IN' || strOperater == 'NOTIN')
                        {
                            String[] multValues = oExpression.SVMXC__Operand__c.split(',');
                            set<object> setValues = new set<object>();
                            if(multValues != null)
                            {
                                for(string str: multValues)
                                {
                                    setValues.add((object)getDateTime(str));
                                }
                            }
                            if(setValues.contains(Val) && strOperater == 'IN')
                                mapResult.put(oExpression.SVMXC__Sequence__c,'T');
                            if(!setValues.contains(Val) && strOperater == 'NOTIN')
                                mapResult.put(oExpression.SVMXC__Sequence__c,'T');
                        }
                    
                            
                    }
                    
                }
            }
        }
        
        system.debug(logginglevel.WARN, 'mapResult:'+mapResult);
        if(!isValidString(AdvExp))
        {
            set<string> setTemp = new set<string>();
            setTemp.addAll(mapResult.values());
            if(setTemp.size() == 0 || setTemp.Contains('F'))
                return false;
            else
                return true;
        }
        AdvExp = AdvExp.ToUpperCase();
        ///* Do not remove this part this is for future purpose.
        /*for( integer i=0; i<AdvExp.length(); i++)
        {
                string iSerialIndex = AdvExp.substring(i,i+1);
                if(iSerialIndex == '(')
                {
                    if(i+1!= AdvExp.length())
                        AdvExp = AdvExp.substring(0,i) + '$' +AdvExp.substring(i+1, AdvExp.length());
                    else
                        AdvExp = AdvExp.substring(0,i) + '$';
                }
                if(iSerialIndex == ')')
                {
                    if(i+1!= AdvExp.length())
                        AdvExp = AdvExp.substring(0,i) + '#' +AdvExp.substring(i+1, AdvExp.length());
                    else 
                        AdvExp = AdvExp.substring(0,i) + '#';
                }
        }
        //AdvExp = AdvExp.replaceAll('$', ' ( ');
        /*AdvExp = AdvExp.replaceAll('(', ' ( ');
        AdvExp = AdvExp.replaceAll(')', ' ) ');*/
        /*AdvExp = AdvExp.replaceAll('$', ' $ ');
        AdvExp = AdvExp.replaceAll('#', ' # ');*/
        AdvExp = AdvExp.replaceAll('AND', ' && ');
        AdvExp = AdvExp.replaceAll('OR', ' || ');
        AdvExp = AdvExp.replaceAll('NOT', ' ! ');
        AdvExp = AdvExp.replace('(', ' ( ');//Added by Nidhi as part of defect #046331
        AdvExp = AdvExp.replace(')', ' ) ');//Added by Nidhi as part of defect #046331
        AdvExp = ' ' + AdvExp + ' ';
        for(integer k = 0; k < lstExpressions.size(); k++)
        {
            AdvExp = AdvExp.replace(' ' + string.valueOf(k+1) + ' ',' ~' + string.valueOf(k+1) + '~ ');//Added by Nidhi as part of defect #046331
            //AdvExp = AdvExp.replace(string.valueOf(k+1),' ~' + string.valueOf(k+1) + '~ ');//Commented by Nidhi as part of defect #046331
            //AdvExp = AdvExp.replace(' ' + string.valueOf(k+1) + ' ',' ~' + string.valueOf(k+1) + '~ ');
            /*AdvExp = AdvExp.replace('(' + string.valueOf(k+1) + ' ','( ~' + string.valueOf(k+1) + '~ ');
            AdvExp = AdvExp.replace(' ' + string.valueOf(k+1) + ')',' ~' + string.valueOf(k+1) + '~ )');*/
        }
        for(integer k=0;k<lstExpressions.size();k++)
        {
            if(mapResult.containsKey(lstExpressions[k].SVMXC__Sequence__c) && lstExpressions[k].SVMXC__Sequence__c != null)
                AdvExp = AdvExp.replace('~' + string.valueOf(lstExpressions[k].SVMXC__Sequence__c.intValue()) + '~', mapResult.get(lstExpressions[k].SVMXC__Sequence__c));               
        }
        AdvExp = AdvExp.replaceAll(' ','');  
        String Temp = '';
        do
        {
            Temp = AdvExp;
            AdvExp  = AdvExp.replace('(F)','F').replace('!T','F').replace('!F','T').replace('(T)','T').replace('F&&F','F').replace('F&&T','F').replace('T&&F','F').replace('T&&T','T').replace('F||F','F').replace('F||T','T').replace('T||F','T').replace('T||T','T');
        }
        while(Temp != AdvExp);
        if(AdvExp=='T')
            return true;
        else
            return false;
    
    }
    
   
    public Boolean SVMX_ExpressionParsing(SObject Rec, list<SVMXC__ServiceMax_Config_Data__c> lstExpressions, string AdvExp)
    {
         return SVMX_ExpressionParsing(Rec,lstExpressions,AdvExp,false);
    }

    private Date getDate(String str)
    {
        system.debug(logginglevel.DEBUG, 'Date String - '+str);
        try
        {
            if(str != null && (str.toUpperCase() == 'TODAY' || str.toUpperCase() == 'SVMX.NOW' || str.toUpperCase() == 'NOW' ))
                return Date.today();
            else if(str != null && str.toUpperCase() == 'TOMORROW')
                return Date.today().addDays(1);
            else if(str != null && str.toUpperCase() == 'YESTERDAY')
                return Date.today().addDays(-1);
            else if(str != null && str.toUpperCase().contains('NEXT_N_DAYS:'))
                return Date.today().addDays(Integer.ValueOf(str.toUpperCase().split(':')[1]) );
            else if(str != null && str.toUpperCase().contains('LAST_N_DAYS:'))
                return Date.today().addDays(-1 * Integer.ValueOf(str.toUpperCase().split(':')[1]) );
             else if(str == null || str == '')
                return null;
            else 
                return Date.parse(str);
        }
        catch(exception ex)
        {
            ApexPages.AddMessage(new ApexPages.Message(ApexPages.Severity.ERROR, ex.getMessage()));
            return null;
        }
    }
    private boolean isDateInRange(string str, date ddate)
    {
        if(str == 'THIS_WEEK')
        {
            if(ddate >= date.today().toStartOfWeek() && ddate < date.today().toStartOfWeek().addDays(7))
                return true;
        }
        else if(str == 'LAST_WEEK')
        {
            if(ddate < date.today().toStartOfWeek() && ddate >= date.today().toStartOfWeek().addDays(-7))
                return true;
        }
        else if(str == 'NEXT_WEEK')
        {
            if(ddate <= date.today().toStartOfWeek().addDays(7) && ddate > date.today().toStartOfWeek().addDays(14))
                return true;
        }
        else if(str == 'THIS_MONTH')
        {
            if(ddate >= date.today().toStartOfMonth() && ddate < date.today().toStartOfMonth().addMonths(1))
                return true;
        }
        else if(str == 'LAST_MONTH')
        {
            if(ddate < date.today().toStartOfMonth() && ddate >= date.today().toStartOfMonth().addMonths(-1))
                return true;
        }
        else if(str == 'NEXT_MONTH')
        {
            if(ddate >= date.today().toStartOfMonth().addMonths(1) && ddate < date.today().toStartOfMonth().addMonths(2))
                return true;
        }
        else if(str == 'NEXT_90_DAYS')
        {
            if(ddate >= date.today().toStartOfWeek() && ddate < date.today().toStartOfWeek().addDays(90))
                return true;
        }
        else if(str == 'LAST_90_DAYS')
        {
            if(ddate < date.today().toStartOfWeek() && ddate >= date.today().toStartOfWeek().addDays(-90))
                return true;
        }
         else if(str.toUppercase() == 'TODAY')
        {
            if(ddate == date.today())
                return true;
        }
        else if(str.toUppercase() == 'YESTERDAY')
        {
            if(ddate == date.today().addDays(-1))
                return true;
        }
        else if(str.toUppercase() == 'TOMORROW')
        {
            if(ddate == date.today().addDays(1))
                return true;
        }
        return false;
    }
    private boolean isDateTimeInRange(string str, Object ddatetime)
    {
        if(str == 'THIS_WEEK')
        {
            if(((datetime)ddatetime).date() >= date.today().toStartOfWeek() && ((datetime)ddatetime).date() < date.today().toStartOfWeek().addDays(7))
                return true;
        }
        else if(str == 'LAST_WEEK')
        {
            if(((datetime)ddatetime).date() < date.today().toStartOfWeek() && ((datetime)ddatetime).date() >= date.today().toStartOfWeek().addDays(-7))
                return true;
        }
        else if(str == 'NEXT_WEEK')
        {
            if(((datetime)ddatetime).date() <= date.today().toStartOfWeek().addDays(7) && ((datetime)ddatetime).date() > date.today().toStartOfWeek().addDays(14))
                return true;
        }
        else if(str == 'THIS_MONTH')
        {
            if(((datetime)ddatetime).date() >= date.today().toStartOfMonth() && ((datetime)ddatetime).date() < date.today().toStartOfMonth().addMonths(1))
                return true;
        }
        else if(str == 'LAST_MONTH')
        {
            if(((datetime)ddatetime).date() < date.today().toStartOfMonth() && ((datetime)ddatetime).date() >= date.today().toStartOfMonth().addMonths(-1))
                return true;
        }
        else if(str == 'NEXT_MONTH')
        {
            if(((datetime)ddatetime).date() >= date.today().toStartOfMonth().addMonths(1) && ((datetime)ddatetime).date() < date.today().toStartOfMonth().addMonths(2))
                return true;
        }
        else if(str == 'NEXT_90_DAYS')
        {
            if(((datetime)ddatetime).date() >= date.today().toStartOfWeek() && ((datetime)ddatetime).date() < date.today().toStartOfWeek().addDays(90))
                return true;
        }
        else if(str == 'LAST_90_DAYS')
        {
            if(((datetime)ddatetime).date() < date.today().toStartOfWeek() && ((datetime)ddatetime).date() >= date.today().toStartOfWeek().addDays(-90))
                return true;
        }
        else if(str.toUppercase() == 'TODAY')
        {
            
            if(((datetime)ddatetime).date() == date.today())
                return true;
        }
        else if(str.toUppercase() == 'YESTERDAY')
        {
            if(((datetime)ddatetime).date() == date.today().addDays(-1))
                return true;
        }
        else if(str.toUppercase() == 'TOMORROW')
        {
            if(((datetime)ddatetime).date() == date.today().addDays(1))
                return true;
        }
        else if(str.toUppercase() == 'SVMX.NOW' || str.toUppercase() == 'NOW' )
        {
            if(((datetime)ddatetime) == DateTime.now())
                return true;
        }
        return false;
    }
    private DateTime getDateTime(String str)
    {
        try
        {
            if(str != null && ( str.toUpperCase() == 'SVMX.NOW' || str.toUpperCase() == 'NOW' ) )
                return DateTime.now();
            else if(str != null && str.toUpperCase() == 'TODAY' )
                return Datetime.newInstance(Date.today(), time.newInstance(0, 0, 0, 0));
            else if(str != null && str.toUpperCase() == 'TOMORROW')
                return Datetime.newInstance(Date.today().addDays(1), time.newInstance(0, 0, 0, 0));
            else if(str != null && str.toUpperCase() == 'YESTERDAY')
                return Datetime.newInstance(Date.today().addDays(-1), time.newInstance(0, 0, 0, 0));
            else if(str != null && str.toUpperCase().contains('NEXT_N_DAYS:'))
                return Datetime.newInstance(Date.today().addDays(Integer.ValueOf(str.toUpperCase().split(':')[1])), time.newInstance(0, 0, 0, 0));
            else if(str != null && str.toUpperCase().contains('LAST_N_DAYS:'))
                return Datetime.newInstance(Date.today().addDays(-1 * Integer.ValueOf(str.toUpperCase().split(':')[1])), time.newInstance(0, 0, 0, 0));
            else if(str == null || str == '')
                return null;   
            else
                return Datetime.parse(str.replace('/','-'));
        }
        catch(exception ex)
        {
            ApexPages.AddMessage(new ApexPages.Message(ApexPages.Severity.ERROR, ex.getMessage()));
            return null;
        }
    }
    
    /*
    New method convert DateTime fields to USER Locale.
    */
    private DateTime getDateTimeValueOF(String str)
    {
        try
        {
            if(str != null && ( str.toUpperCase() == 'SVMX.NOW' || str.toUpperCase() == 'NOW' ) )
                return DateTime.now();
            else if(str != null && str.toUpperCase() == 'TODAY' )
                return Datetime.newInstance(Date.today(), time.newInstance(0, 0, 0, 0));
            else if(str != null && str.toUpperCase() == 'TOMORROW')
                return Datetime.newInstance(Date.today().addDays(1), time.newInstance(0, 0, 0, 0));
            else if(str != null && str.toUpperCase() == 'YESTERDAY')
                return Datetime.newInstance(Date.today().addDays(-1), time.newInstance(0, 0, 0, 0));
            else if(str != null && str.toUpperCase().contains('NEXT_N_DAYS:'))
                return Datetime.newInstance(Date.today().addDays(Integer.ValueOf(str.toUpperCase().split(':')[1])), time.newInstance(0, 0, 0, 0));
            else if(str != null && str.toUpperCase().contains('LAST_N_DAYS:'))
                return Datetime.newInstance(Date.today().addDays(-1 * Integer.ValueOf(str.toUpperCase().split(':')[1])), time.newInstance(0, 0, 0, 0));
            else if(str == null || str == '')
                return null;   
            else
                return Datetime.ValueOf(str.replace('/','-'));
        }
        catch(exception ex)
        {
            ApexPages.AddMessage(new ApexPages.Message(ApexPages.Severity.ERROR, ex.getMessage()));
            return null;
        }
    }    
    private List<SVMXC__ServiceMax_Config_Data__c> sortingExpressionList(List<SVMXC__ServiceMax_Config_Data__c> lstexp)
    {
        map<Integer, SVMXC__ServiceMax_Config_Data__c> mapTemp = new map<Integer, SVMXC__ServiceMax_Config_Data__c>();
        for(SVMXC__ServiceMax_Config_Data__c oExp :lstexp)
        {   mapTemp.put(oExp.SVMXC__Sequence__c.intValue(),oExp);}
        list<Integer> lstTemp = new list<Integer>();
        lstTemp.addAll(mapTemp.KeySet());
        lstTemp.sort();
        lstexp.clear();
        for(Integer iIndex: lstTemp)
        {   lstexp.add(mapTemp.get(iIndex));}
        return lstexp;
    }
    private List<SVMXC__ServiceMax_Processes__c> sortRuleList(set<Id> lstRules, map<Id, SVMXC__ServiceMax_Processes__c> mapRules)
    {
        map<Integer, SVMXC__ServiceMax_Processes__c> mapTemp = new map<Integer, SVMXC__ServiceMax_Processes__c>();
        list<SVMXC__ServiceMax_Processes__c> lstTempRule = new list<SVMXC__ServiceMax_Processes__c>();
        for(Id strRule :lstRules)
        {   
            if(mapRules.ContainsKey(strRule))
            {
                SVMXC__ServiceMax_Processes__c oRule = mapRules.get(strRule);
                if(oRule.SVMXC__Sequence__c != null)
                    mapTemp.put(oRule.SVMXC__Sequence__c.intValue(),oRule);
                else 
                    lstTempRule.add(oRule);
            }
        }
        list<Integer> lstTemp = new list<Integer>();
        lstTemp.addAll(mapTemp.KeySet());
        lstTemp.sort();
        
        list<SVMXC__ServiceMax_Processes__c> lstRule = new list<SVMXC__ServiceMax_Processes__c>();
        for(Integer iIndex: lstTemp)
        {   lstRule.add(mapTemp.get(iIndex));}
        lstRule.addAll(lstTempRule);
        return lstRule;
    }
    private List<SVMXC__ServiceMax_Processes__c> sortRuleList(set<Id> lstRules, map<Id, SVMXC__ServiceMax_Processes__c> mapRules, boolean IsSortAssending)
    {
        map<Integer, SVMXC__ServiceMax_Processes__c> mapTemp = new map<Integer, SVMXC__ServiceMax_Processes__c>();
        list<SVMXC__ServiceMax_Processes__c> lstTempRule = new list<SVMXC__ServiceMax_Processes__c>();
        for(Id strRule :lstRules)
        {   
            if(mapRules.ContainsKey(strRule))
            {
                SVMXC__ServiceMax_Processes__c oRule = mapRules.get(strRule);
                if(oRule.SVMXC__Sequence__c != null)
                    mapTemp.put(oRule.SVMXC__Sequence__c.intValue(),oRule);
                else 
                    lstTempRule.add(oRule);
            }
        }
        list<Integer> lstTemp = new list<Integer>();
        lstTemp.addAll(mapTemp.KeySet());
        lstTemp.sort();
        
        list<SVMXC__ServiceMax_Processes__c> lstRule = new list<SVMXC__ServiceMax_Processes__c>();
        if(IsSortAssending)
        {
            for(Integer iIndex: lstTemp)
            {   lstRule.add(mapTemp.get(iIndex));}
            lstRule.addAll(lstTempRule);
        }
        else
        {
            for(Integer iIndex = lstTemp.size(); iIndex > 0; iIndex--)
            {   lstRule.add(mapTemp.get(lstTemp[iIndex - 1]));}
            lstRule.addAll(lstTempRule);
        }
        return lstRule;
    }
   /* private List<SVMXC__ServiceMax_Processes__c> sortRuleList(List<SVMXC__ServiceMax_Processes__c> lstRule)
    {
        map<Integer, SVMXC__ServiceMax_Processes__c> mapTemp = new map<Integer, SVMXC__ServiceMax_Processes__c>();
        list<SVMXC__ServiceMax_Processes__c> lstTempRule = new list<SVMXC__ServiceMax_Processes__c>();
        for(SVMXC__ServiceMax_Processes__c oRule :lstRule)
        {   
            if(oRule.SVMXC__Sequence__c != null)
                mapTemp.put(oRule.SVMXC__Sequence__c.intValue(),oRule);
            else 
                lstTempRule.add(oRule);
        }
        list<Integer> lstTemp = new list<Integer>();
        lstTemp.addAll(mapTemp.KeySet());
        lstTemp.sort();
        lstRule.clear();
        for(Integer iIndex: lstTemp)
        {   lstRule.add(mapTemp.get(iIndex));}
        lstRule.addAll(lstTempRule);
        return lstRule;
    }*/
    public boolean isValidString(string str)
    {
        if(str != null && str.length() > 0)
            return true;
        return false;
    }
    
    public set<Id> SearchTechnician2(list<SVMXC__Service_Group_Members__c> lstTechnician, list<SVMXC__Service_Group_Product__c> lstProductServiced, list<SVMXC__Service_Group_Skills__c> lstExpertise, list<SVMXC__Territory_Coverage__c> lstTerritoryCoverage, list<string> lstSearchString, list<string> lstField, boolean bMatchAll, boolean bMatchProduct, boolean bMatchExpertise, boolean bMatchTerritory)
    {
        set<Id> setIdSortedTechnician = new set<Id>();
        map<Id, set<Id>> mapTerritoryTechnician = new map<Id, set<Id>>();
        for(SVMXC__Service_Group_Members__c oTechnician :lstTechnician)
        {
            if(oTechnician.SVMXC__Service_Territory__c != null){
                if(!mapTerritoryTechnician.containskey(oTechnician.SVMXC__Service_Territory__c))
                    mapTerritoryTechnician.put(oTechnician.SVMXC__Service_Territory__c, new set<Id>());
                mapTerritoryTechnician.get(oTechnician.SVMXC__Service_Territory__c).add(oTechnician.Id);
            }
        }
        if(bMatchAll)
        {
            map<Id, map<string, boolean>> mapTechinicianValidity = new map<Id, map<string, boolean>>();
            if(lstSearchString != null && lstSearchString.size() > 0)
            {
                for(string strSearchString :lstSearchString)
                {
                    if(lstTechnician != null && lstTechnician.size() > 0)
                    {
                        for(SVMXC__Service_Group_Members__c oTechnician :lstTechnician)
                        {
                            if(!mapTechinicianValidity.containsKey(oTechnician.Id))
                            {
                                mapTechinicianValidity.put(oTechnician.Id, new map<string, boolean>());
                                mapTechinicianValidity.get(oTechnician.Id).put(strSearchString, false);
                            }
                            else
                            {
                                if(!mapTechinicianValidity.get(oTechnician.Id).containsKey(strSearchString))
                                    mapTechinicianValidity.get(oTechnician.Id).put(strSearchString, false);
                            }
                            for(string strField :lstField)
                            {
                                if(oTechnician.get(strField) != null && string.valueOf(oTechnician.get(strField)) != null && string.valueOf(oTechnician.get(strField)).toUpperCase().contains(strSearchString.toUpperCase()))
                                {
                                    mapTechinicianValidity.get(oTechnician.Id).put(strSearchString, true);
                                    break;
                                }
                            }
                        }
                    }
                    if(bMatchProduct && lstProductServiced != null && lstProductServiced.size() > 0)
                    {
                        for(SVMXC__Service_Group_Product__c oProductServiced :lstProductServiced)
                        {
                            if(!mapTechinicianValidity.containsKey(oProductServiced.SVMXC__Group_Member__c))
                            {
                                mapTechinicianValidity.put(oProductServiced.SVMXC__Group_Member__c, new map<string, boolean>());
                                mapTechinicianValidity.get(oProductServiced.SVMXC__Group_Member__c).put(strSearchString, false);
                            }
                            else
                            {
                                if(!mapTechinicianValidity.get(oProductServiced.SVMXC__Group_Member__c).containsKey(strSearchString))
                                    mapTechinicianValidity.get(oProductServiced.SVMXC__Group_Member__c).put(strSearchString, false);
                            }
                            if(oProductServiced.SVMXC__Product__r.Name != null && oProductServiced.SVMXC__Product__r.Name.toUpperCase().contains(strSearchString.toUpperCase()))
                                mapTechinicianValidity.get(oProductServiced.SVMXC__Group_Member__c).put(strSearchString, true);
                        }
                    }
                    if(bMatchExpertise && lstExpertise != null && lstExpertise.size() > 0)
                    {
                        for(SVMXC__Service_Group_Skills__c oExpertise :lstExpertise)
                        {
                            if(!mapTechinicianValidity.containsKey(oExpertise.SVMXC__Group_Member__c))
                            {
                                mapTechinicianValidity.put(oExpertise.SVMXC__Group_Member__c, new map<string, boolean>());
                                mapTechinicianValidity.get(oExpertise.SVMXC__Group_Member__c).put(strSearchString, false);
                            }
                            else
                            {
                                if(!mapTechinicianValidity.get(oExpertise.SVMXC__Group_Member__c).containsKey(strSearchString))
                                    mapTechinicianValidity.get(oExpertise.SVMXC__Group_Member__c).put(strSearchString, false);
                            }
                            if(oExpertise.SVMXC__Skill__r.Name != null && oExpertise.SVMXC__Skill__r.Name.toUpperCase().contains(strSearchString.toUpperCase()))
                                mapTechinicianValidity.get(oExpertise.SVMXC__Group_Member__c).put(strSearchString, true);
                        }
                    }
                    if(bMatchTerritory && lstTerritoryCoverage != null && lstTerritoryCoverage.size() > 0)
                    {
                        for(SVMXC__Territory_Coverage__c oTerritoryCoverage :lstTerritoryCoverage)
                        {
                            if(oTerritoryCoverage.SVMXC__Value__c != null && oTerritoryCoverage.SVMXC__Value__c.toUpperCase().contains(strSearchString.toUpperCase()))
                            {
                                set<Id> lstIdTechnician = new set<Id>();
                                lstIdTechnician = mapTerritoryTechnician.get(oTerritoryCoverage.SVMXC__Territory__c);
                                if(lstIdTechnician != NULL)
                                {
                                    for(Id IdTechnician :lstIdTechnician)
                                    {
                                        if(!mapTechinicianValidity.containsKey(IdTechnician))
                                            mapTechinicianValidity.put(IdTechnician, new map<string, boolean>());
                                        mapTechinicianValidity.get(IdTechnician).put(strSearchString, true);
                                    }
                                }
                            }
                        }
                    }
                }
            }
            
            if(mapTechinicianValidity != null && mapTechinicianValidity.size() > 0)
            {
                for(Id IdTechnician :mapTechinicianValidity.KeySet())
                {
                    map<string, Boolean> m = mapTechinicianValidity.get(IdTechnician);
                    boolean IsValidTechnician = true;
                    for(boolean b :m.values())
                    {
                        if(!b)
                        {
                            IsValidTechnician = false;
                            break;
                        }
                    }
                    if(IsValidTechnician)
                        setIdSortedTechnician.add(IdTechnician);
                }
            }
        }
        else
        {
            for(SVMXC__Service_Group_Members__c oTechnician :lstTechnician)
            {
                setIdSortedTechnician.add(oTechnician.Id);
            }
            for(SVMXC__Service_Group_Product__c oProductServiced :lstProductServiced)
            {
                setIdSortedTechnician.add(oProductServiced.SVMXC__Group_Member__c);
            }
            for(SVMXC__Service_Group_Skills__c oExpertise :lstExpertise)
            {
                setIdSortedTechnician.add(oExpertise.SVMXC__Group_Member__c);
            }
        }
        return setIdSortedTechnician;
    }
    public set<Id> SearchTeam(list<SVMXC__Service_Group__c> lstTeam, list<SVMXC__Service_Group_Product__c> lstProductServiced, list<SVMXC__Service_Group_Skills__c> lstExpertise, list<string> lstSearchString, list<string> lstField, boolean bMatchAll, boolean bMatchProduct, boolean bMatchExpertise)
    {
        set<Id> setIdSortedTeam = new set<Id>();
        if(bMatchAll)
        {
            map<Id, map<string, boolean>> mapTechinicianValidity = new map<Id, map<string, boolean>>();
            if(lstSearchString != null && lstSearchString.size() > 0)
            {
                for(string strSearchString :lstSearchString)
                {
                    if(lstTeam != null && lstTeam.size() > 0)
                    {
                        for(SVMXC__Service_Group__c oTeam :lstTeam)
                        {
                            if(!mapTechinicianValidity.containsKey(oTeam.Id))
                            {
                                mapTechinicianValidity.put(oTeam.Id, new map<string, boolean>());
                                mapTechinicianValidity.get(oTeam.Id).put(strSearchString, false);
                            }
                            else
                            {
                                if(!mapTechinicianValidity.get(oTeam.Id).containsKey(strSearchString))
                                    mapTechinicianValidity.get(oTeam.Id).put(strSearchString, false);
                            }
                            for(string strField :lstField)
                            {
                                if(oTeam.get(strField) != null && string.valueOf(oTeam.get(strField)) != null && string.valueOf(oTeam.get(strField)).toUpperCase().contains(strSearchString.toUpperCase()))
                                {
                                    mapTechinicianValidity.get(oTeam.Id).put(strSearchString, true);
                                    break;
                                }
                            }
                        }
                    }
                    if(bMatchProduct && lstProductServiced != null && lstProductServiced.size() > 0)
                    {
                        for(SVMXC__Service_Group_Product__c oProductServiced :lstProductServiced)
                        {
                            if(!mapTechinicianValidity.containsKey(oProductServiced.SVMXC__Service_Group__c))
                            {
                                mapTechinicianValidity.put(oProductServiced.SVMXC__Service_Group__c, new map<string, boolean>());
                                mapTechinicianValidity.get(oProductServiced.SVMXC__Service_Group__c).put(strSearchString, false);
                            }
                            else
                            {
                                if(!mapTechinicianValidity.get(oProductServiced.SVMXC__Service_Group__c).containsKey(strSearchString))
                                    mapTechinicianValidity.get(oProductServiced.SVMXC__Service_Group__c).put(strSearchString, false);
                            }
                            if(oProductServiced.SVMXC__Product__r.Name != null && oProductServiced.SVMXC__Product__r.Name.toUpperCase().contains(strSearchString.toUpperCase()))
                                mapTechinicianValidity.get(oProductServiced.SVMXC__Service_Group__c).put(strSearchString, true);
                        }
                    }
                    if(bMatchExpertise && lstExpertise != null && lstExpertise.size() > 0)
                    {
                        for(SVMXC__Service_Group_Skills__c oExpertise :lstExpertise)
                        {
                            if(!mapTechinicianValidity.containsKey(oExpertise.SVMXC__Service_Group__c))
                            {
                                mapTechinicianValidity.put(oExpertise.SVMXC__Service_Group__c, new map<string, boolean>());
                                mapTechinicianValidity.get(oExpertise.SVMXC__Service_Group__c).put(strSearchString, false);
                            }
                            else
                            {
                                if(!mapTechinicianValidity.get(oExpertise.SVMXC__Service_Group__c).containsKey(strSearchString))
                                    mapTechinicianValidity.get(oExpertise.SVMXC__Service_Group__c).put(strSearchString, false);
                            }
                            if(oExpertise.SVMXC__Skill__r.Name != null && oExpertise.SVMXC__Skill__r.Name.toUpperCase().contains(strSearchString.toUpperCase()))
                                mapTechinicianValidity.get(oExpertise.SVMXC__Service_Group__c).put(strSearchString, true);
                        }
                    }
                }
            }
            if(mapTechinicianValidity != null && mapTechinicianValidity.size() > 0)
            {
                for(Id IdTeam :mapTechinicianValidity.KeySet())
                {
                    map<string, Boolean> m = mapTechinicianValidity.get(IdTeam);
                    boolean IsValidTeam = true;
                    for(boolean b :m.values())
                    {
                        if(!b)
                        {
                            IsValidTeam = false;
                            break;
                        }
                    }
                    if(IsValidTeam)
                        setIdSortedTeam.add(IdTeam);
                }
            }
        }
        else
        {
            for(SVMXC__Service_Group__c oTeam :lstTeam)
            {
                setIdSortedTeam.add(oTeam.Id);
            }
            for(SVMXC__Service_Group_Product__c oProductServiced :lstProductServiced)
            {
                setIdSortedTeam.add(oProductServiced.SVMXC__Service_Group__c);
            }
            for(SVMXC__Service_Group_Skills__c oExpertise :lstExpertise)
            {
                setIdSortedTeam.add(oExpertise.SVMXC__Service_Group__c);
            }
        }
        return setIdSortedTeam;
    }
    
    public String Base64Decryption(String Encstr)
    {
        String Decodeddata;
        Boolean unfailed = false;
        try
        {
            if(unfailed==true)
                Decodeddata=Encstr;
            else
            {
                blob Decodeblob = EncodingUtil.base64Decode(Encstr);
                Decodeddata = Decodeblob.toString();
            }
        }
        catch(Exception ex)
        {
            unfailed=true;
            Decodeddata = Encstr;
        }
        return Decodeddata;
    }
    /*
    public set<Id> SearchTechnician(list<SVMXC__Service_Group_Members__c> lstTechnician, list<SVMXC__Service_Group_Product__c> lstProductServiced, list<SVMXC__Service_Group_Skills__c> lstExpertise, list<string> lstSearchString, list<string> lstField, boolean bMatchAll, boolean bMatchProduct, boolean bMatchExpertise)
    {
    }
    */
}