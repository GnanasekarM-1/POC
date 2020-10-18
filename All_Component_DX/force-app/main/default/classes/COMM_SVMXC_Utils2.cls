public with sharing class COMM_SVMXC_Utils2 
{
    public COMM_SVMXC_Utils2()
    {
        
    }
    
    // --- method created for getting community prefix
    public String GetCommunityPrefix(String strURL)
    {
        String strURLTest = '';
        // Changes related to BAC-2305
        //If the url is not a partial path, assuming it as external path.Hence not adding the community prefix
        // 14 March 2018 - This is for External Path like http:// www.google.com
        if(! String.isBlank(strURL) && !(strURL.startsWith('/') || strURL.startsWith('..')))
        {
            strURLTest = strURL;
        }
        // This method getprefix() is replaced with new getpathprefix() during API upgrade.
        
        else if(Site.getPathPrefix() != null && Site.getPathPrefix()!= '' )
        {
             // start - BAC-3753 - 14 March 2018 - This is for Community
            /*if(strURL.startsWith('..'))
                strURLTest =  Site.getPathPrefix()+strURL.removeStart('..');
            else*/

           // end - BAC-3753 - 14 March 2018 - This is for Community
                strURLTest =  Site.getPathPrefix()+strURL;
            //block for changed return URL
            if(strURL.contains('SVMX_retURL='))
                strURLTest = strURLTest.replace('SVMX_retURL=', 'SVMX_retURL='+Site.getPathPrefix()+'');
        }
        else
            strURLTest =  strURL; // 14 March 2018 - This is for relative path, no need to append prefix. 
        return strURLTest;
    } 
     // --- method created for getting community prefix for web service
    public String GetCommunityPrefix()
    {
        return Site.getPathPrefix();
    } 
    
    //-------------------- NPS Related...
    public string getUserLocaleKey(){
        return UserInfo.getLanguage();
    }
    public string getUserID(){
        return UserInfo.getUserId().substring(0, 15);
    }
    public string getUserOrgID(){
        return UserInfo.getOrganizationId().substring(0, 15);
    }
    //-----------------------------------
    
    public class COMM_ExpressionParsing
    {
        Map<Double,string> ExprsionMap = new Map<Double,string>();
        public map<Id, string> SVMX_ExpressionParsing(map<Id, sObject> lstRec, map<Id, list<SVMXC__ServiceMax_Config_Data__c>> mapRulesExpressions, map<Id, SVMXC__ServiceMax_Processes__c> mapRules)
        {
            map<Id, string> mapResult = new map<Id, string>();
            list<SVMXC__ServiceMax_Processes__c> lstSortedRules = sortRuleList(mapRulesExpressions.KeySet(), mapRules);
            if(lstRec != null)
            {
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
        public Boolean SVMX_ExpressionParsing(SObject Rec, list<SVMXC__ServiceMax_Config_Data__c> lstExpressions, string AdvExp)
        {
            if(lstExpressions == null || lstExpressions.size() == 0)
                return true;
            Map<Double,string> mapResult = new Map<Double,string>(); 
            string ExpVal;
            integer ExpKey;
            lstExpressions = sortingExpressionList(lstExpressions);
            for(SVMXC__ServiceMax_Config_Data__c oExpression: lstExpressions)
            {
                mapResult.put(oExpression.SVMXC__Sequence__c,'F');
                string FieldType = oExpression.SVMXC__Display_Type__c ;
                
                if(FieldType != null && FieldType.length() > 0 && oExpression.SVMXC__Operator__c != null && oExpression.SVMXC__Operator__c.length() > 0)
                {
                    string strOperater = oExpression.SVMXC__Operator__c.ToUpperCase();
                    string strFieldType = FieldType.ToUpperCase();
                    if(strFieldType == 'STRING' || strFieldType == 'COMBOBOX' || strFieldType == 'PICKLIST' || strFieldType == 'PHONE' || strFieldType == 'URL' || strFieldType == 'TEXTAREA')
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
                        else if(strOperater == 'NOTCONTAINS')
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
                            if(Val == (Id)oExpression.SVMXC__Operand__c)
                                mapResult.put(oExpression.SVMXC__Sequence__c,'T');
                        }
                        else if(strOperater == 'NE')
                        {
                            if(Val != (Id)oExpression.SVMXC__Operand__c)
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
                                    setValues.add((Id)str);
                                }
                            }
                            if(setValues.contains(Val) && strOperater == 'IN')
                                mapResult.put(oExpression.SVMXC__Sequence__c, 'T');
                            if(!setValues.contains(Val) && strOperater == 'NOTIN')
                                mapResult.put(oExpression.SVMXC__Sequence__c, 'T');
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
                            if(Val == getDate(oExpression.SVMXC__Operand__c))
                                mapResult.put(oExpression.SVMXC__Sequence__c,'T');
                        }
                        else if(strOperater == 'NE')
                        {
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
                    }
                    else if(strFieldType == 'DATETIME')
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
                        object Val;
                        if(Rec.get(oExpression.SVMXC__Field_Name__c) != null)
                            val = Rec.get(oExpression.SVMXC__Field_Name__c);
                        if(strOperater == 'EQ')
                        {
                            if(Val == (object)getDateTime(oExpression.SVMXC__Operand__c))
                                mapResult.put(oExpression.SVMXC__Sequence__c,'T');
                        }
                        else if(strOperater == 'NE')
                        {
                            if(Val != (object)getDateTime(oExpression.SVMXC__Operand__c))
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
            /*AdvExp = AdvExp.replaceAll('(', ' ( ');
            AdvExp = AdvExp.replaceAll(')', ' ) ');*/
            AdvExp = AdvExp.replaceAll('AND', ' && ');
            AdvExp = AdvExp.replaceAll('OR', ' || ');
            AdvExp = AdvExp.replaceAll('NOT', ' ! ');
            AdvExp = ' ' + AdvExp + ' ';
            for(integer k = 0; k < lstExpressions.size(); k++)
            {
                AdvExp = AdvExp.replace(string.valueOf(k+1),' ~' + string.valueOf(k+1) + '~ ');
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
        private Date getDate(String str)
        {
            try
            {
                if(str != null && (str.toUpperCase() == 'TODAY' || str.toUpperCase() == 'SVMX.NOW'))
                    return Date.today();
                else if(str != null && str.toUpperCase() == 'TOMORROW')
                    return Date.today().addDays(1);
                else if(str != null && str.toUpperCase() == 'YESTERDAY')
                    return Date.today().addDays(-1);
                else if(str != null && str.toUpperCase().contains('NEXT_N_DAYS:'))
                    return Date.today().addDays(Integer.ValueOf(str.toUpperCase().split(':')[1]) );
                else if(str != null && str.toUpperCase().contains('LAST_N_DAYS:'))
                    return Date.today().addDays(-1 * Integer.ValueOf(str.toUpperCase().split(':')[1]) );
                else 
                    return Date.parse(str);
            }
            catch(exception ex)
            {
                ApexPages.AddMessage(new ApexPages.Message(ApexPages.Severity.ERROR, ex.getMessage()));
                return null;
            }
        }
        private DateTime getDateTime(String str)
        {
            try
            {
                if(str != null && str.toUpperCase() == 'SVMX.NOW')
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
                else
                    return Datetime.parse(str.replace('/','-'));
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
        public List<SVMXC__ServiceMax_Processes__c> sortRuleList(List<SVMXC__ServiceMax_Processes__c> lstRule)
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
        }
        public boolean isValidString(string str)
        {
            if(str != null && str.length() > 0)
                return true;
            return false;
        }
    }
}