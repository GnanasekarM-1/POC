public with sharing class APL_Utils 
{

    public class SVMXException extends Exception{}
    
    /*********************************************************************************************************************************
                                        Source Update Utility: Start
    *********************************************************************************************************************************/
    public List<Sobject> DoSourceUpdate(list<Sobject> lstSourceUpdateRecords, list<SVMXC__ServiceMax_Config_Data__c> lstSourceUpdatesFields,map<String,Schema.SObjectField> mapFieldDescribe)
    {
        system.debug('lstSourceUpdateRecords'+lstSourceUpdateRecords);
        system.debug('lstSourceUpdatesFields'+lstSourceUpdatesFields);
        system.debug('mapFieldDescribe'+mapFieldDescribe);
        list<Sobject> lstOutputSobject = new list<Sobject>();
        
        //COMM_PerformanceUtils.start('4.c.1.Source Updates _ LoopinglstSrceUpdateRec');
        
        for(Integer i = 0;i<lstSourceUpdateRecords.size();i++)
        {
            Sobject objSourceUpdateRec = lstSourceUpdateRecords[i];
            system.debug('objSourceUpdateRec'+objSourceUpdateRec);
            //COMM_PerformanceUtils.start('4.c.1.a.Source Updates _ LoopInsideLooplstSrceUpdateRec');
            for(Integer j = 0;j<lstSourceUpdatesFields.size();j++)
            {
                SVMXC__ServiceMax_Config_Data__c objConfigData = lstSourceUpdatesFields[j];
                if(objConfigData.SVMXC__Target_Field_Name__c != null && objConfigData.SVMXC__Action__c != null && objConfigData.SVMXC__Display_Value__c != null && mapFieldDescribe.containskey(objConfigData.SVMXC__Target_Field_Name__c))
                {
                    if(objConfigData.SVMXC__Action__c.touppercase() == 'SET')
                    {
                        system.debug('Enterd for set');
                        //Desctibe the field to check differen attributes of fields..
                        Schema.DescribeFieldResult f = mapFieldDescribe.get(objConfigData.SVMXC__Target_Field_Name__c).getDescribe();
                        if((f.getType() == schema.Displaytype.Double  || f.getType() == schema.Displaytype.Percent || f.getType() == schema.Displaytype.Currency)&& f.isUpdateable())//if Field Type is Double,persent,currency 
                        {
                            if(double.valueOf(objConfigData.SVMXC__Display_Value__c) != null )
                            {
                                objSourceUpdateRec.put(objConfigData.SVMXC__Target_Field_Name__c,(double.valueOf(objConfigData.SVMXC__Display_Value__c)));
                            }   
                        }
                        else if(f.getType() == schema.Displaytype.Boolean && f.isUpdateable())//if field type is Boolean
                        {
                            if(Boolean.valueof(objConfigData.SVMXC__Display_Value__c)!= null)
                            {
                                objSourceUpdateRec.put(objConfigData.SVMXC__Target_Field_Name__c,Boolean.valueof(objConfigData.SVMXC__Display_Value__c));
                            }   
                        }
                        else if(f.getType() == schema.Displaytype.DateTime && f.isUpdateable())//if field type is DateTime
                        {
                            system.debug('displayval'+objConfigData.SVMXC__Display_Value__c);
                            if(objConfigData.SVMXC__Display_Value__c.touppercase() == 'TODAY')
                            {
                                system.debug('Enterd for Today');
                                objSourceUpdateRec.put(objConfigData.SVMXC__Target_Field_Name__c,datetime.newInstance(system.today(), time.newInstance(0, 0, 0, 0)));
                            }   
                            else if(objConfigData.SVMXC__Display_Value__c.touppercase() == 'YESTERDAY')
                            {
                                system.debug('Enterd for YESTERDAY');
                                objSourceUpdateRec.put(objConfigData.SVMXC__Target_Field_Name__c,datetime.newInstance(system.today()-1, time.newInstance(0, 0, 0, 0)));
                            }       
                            else if(objConfigData.SVMXC__Display_Value__c.touppercase() == 'TOMORROW')
                            {
                                system.debug('Enterd for TOMORROW');
                                objSourceUpdateRec.put(objConfigData.SVMXC__Target_Field_Name__c,datetime.newInstance(system.today()+1, time.newInstance(0, 0, 0, 0)));
                            }
                            else if(objConfigData.SVMXC__Display_Value__c.touppercase() == 'NOW')
                            {
                                system.debug('Enterd for Now');
                                objSourceUpdateRec.put(objConfigData.SVMXC__Target_Field_Name__c,system.now());
                            }
                            else
                            {           
                                objSourceUpdateRec.put(objConfigData.SVMXC__Target_Field_Name__c,DateTime.valueof(objConfigData.SVMXC__Display_Value__c));
                            }
                                    
                        }
                        else if(f.getType() == schema.Displaytype.Date && f.isUpdateable())//if field type is Date
                        {
                            system.debug('displayval'+objConfigData.SVMXC__Display_Value__c);
                            if(objConfigData.SVMXC__Display_Value__c.touppercase() == 'TODAY')
                            {
                                system.debug('Enterd for Today');
                                objSourceUpdateRec.put(objConfigData.SVMXC__Target_Field_Name__c,system.today());
                            }   
                            else if(objConfigData.SVMXC__Display_Value__c.touppercase() == 'YESTERDAY')
                            {
                                system.debug('Enterd for YESTERDAY');
                                objSourceUpdateRec.put(objConfigData.SVMXC__Target_Field_Name__c,system.today() - 1);
                            }       
                            else if(objConfigData.SVMXC__Display_Value__c.touppercase() == 'TOMORROW')
                            {
                                system.debug('Enterd for TOMORROW');
                                objSourceUpdateRec.put(objConfigData.SVMXC__Target_Field_Name__c,system.today() + 1);
                            }
                            else
                            {           
                                objSourceUpdateRec.put(objConfigData.SVMXC__Target_Field_Name__c,date.valueof(objConfigData.SVMXC__Display_Value__c));
                            }
                        }
                        else if(f.getType() == schema.Displaytype.MultiPicklist && f.isUpdateable())//if field type is MultiPicklist
                        {
                            if(String.valueof(objConfigData.SVMXC__Display_Value__c) != null)
                            {
                                objSourceUpdateRec.put(objConfigData.SVMXC__Target_Field_Name__c,String.valueof(objConfigData.SVMXC__Display_Value__c));
                            }
                        }
                        else //else field type is REFERENCE,String 
                        {
                            if((String)objConfigData.SVMXC__Display_Value__c != null && f.isUpdateable())
                            {
                                objSourceUpdateRec.put(objConfigData.SVMXC__Target_Field_Name__c,(String)objConfigData.SVMXC__Display_Value__c);
                            }
                        }
                    }
                    else if(objConfigData.SVMXC__Action__c.touppercase() == 'INCREASE')
                    {
                        system.debug('Enter in Increase');
                        Double SourceRec = (Double)(objSourceUpdateRec.get(objConfigData.SVMXC__Target_Field_Name__c));
                        Double DisplayValue = Double.valueof(objConfigData.SVMXC__Display_Value__c);
                        system.debug('SourceRec'+SourceRec);
                        system.debug('DisplayValue'+DisplayValue);
                        Double val = 0;
                        //if both are not null
                        if(SourceRec != null && DisplayValue != null)
                        { 
                          val = SourceRec + DisplayValue;
                        }
                        else if(SourceRec == null && DisplayValue != null)
                        {
                          val = DisplayValue;
                        }  
                        system.debug('val'+val);
                        objSourceUpdateRec.put(objConfigData.SVMXC__Target_Field_Name__c,val);
                    }
                    else if(objConfigData.SVMXC__Action__c.touppercase() == 'DECREASE')
                    {
                        system.debug('Enter in decrease');
                        Double SourceRec = (Double)(objSourceUpdateRec.get(objConfigData.SVMXC__Target_Field_Name__c));
                        Double DisplayValue = Double.valueof(objConfigData.SVMXC__Display_Value__c);
                        system.debug('SourceRec'+SourceRec);
                        system.debug('DisplayValue'+DisplayValue);
                        Double val = 0;
                        if(SourceRec != null && DisplayValue != null)
                        {  
                          val = SourceRec - DisplayValue;
                        }
                        else if(SourceRec == null && DisplayValue != null)
                        {
                          val = val-DisplayValue;
                        }
                        system.debug('val'+val);
                        objSourceUpdateRec.put(objConfigData.SVMXC__Target_Field_Name__c,val);
                    }
                }
            }
            lstOutputSobject.add(objSourceUpdateRec);
            //COMM_PerformanceUtils.stop('4.c.1.a.Source Updates _ LoopInsideLooplstSrceUpdateRec');
        }
            
        //COMM_PerformanceUtils.stop('4.c.1.Source Updates _ LoopinglstSrceUpdateRec');
        
        system.debug('lstOutputSobject: '+lstOutputSobject);
        return lstOutputSobject;
    }
    /*********************************************************************************************************************************
                                        Source Update Utility: End
    *********************************************************************************************************************************/
    
    /*********************************************************************************************************************************
                                Expression parsing Utility for APL Route Calculation. 
    *********************************************************************************************************************************/
    public set<string> SetDateRange = new set<string>();
    public APL_Utils()
    {
        SetDateRange.add('THIS_WEEK');
        SetDateRange.add('NEXT_WEEK');
        SetDateRange.add('LAST_WEEK');
        SetDateRange.add('THIS_MONTH');
        SetDateRange.add('NEXT_MONTH');
        SetDateRange.add('LAST_MONTH');
        SetDateRange.add('NEXT_90_DATS');
        SetDateRange.add('LAST_90_DAYS');
    }
    
    public map<string, string> SVMX_ExpressionParsing(map<string, sObject> lstRec, map<Id, list<SVMXC__ServiceMax_Config_Data__c>> mapRulesExpressions, map<Id, SVMXC__ServiceMax_Processes__c> mapRules)
    {
        map<string, string> mapResult = new map<string, string>();
        list<SVMXC__ServiceMax_Processes__c> lstSortedRules = sortRuleList(mapRulesExpressions.KeySet(), mapRules);
        if(lstRec != null && lstSortedRules != null && lstSortedRules.size() > 0)
        {
            for(SVMXC__ServiceMax_Processes__c oSVMXProcess: lstSortedRules)
            {
                Id IdRule = oSVMXProcess.Id;
                if(mapRulesExpressions.ContainsKey(IdRule))
                {
                    boolean IsRuleApplicable = false;
                    system.debug('NewTest1'+lstRec);
                    system.debug('NewTest2'+mapRulesExpressions);
                    system.debug('NewTest3'+mapRules);
                    IsRuleApplicable = SVMX_ExpressionParsing(lstRec, mapRulesExpressions.get(IdRule), mapRules.get(IdRule)!= null? mapRules.get(IdRule).SVMXC__Advance_Expression__c : '');
                    if(IsRuleApplicable)
                    {
                        mapResult.put(IdRule, IdRule);
                        break;
                    }
                }
            }
        }
        system.debug('NewTest4'+mapResult);
        return mapResult;
    }
    
    public Boolean SVMX_ExpressionParsing(map<string, sObject> lstRec, list<SVMXC__ServiceMax_Config_Data__c> lstExpressions, string AdvExp)
    {
        if(lstExpressions == null || lstExpressions.size() == 0)
            return true;
        Map<Double,string> mapResult = new Map<Double,string>(); 
        string ExpVal;
        integer ExpKey;
        lstExpressions = sortingExpressionList(lstExpressions);
        for(SVMXC__ServiceMax_Config_Data__c oExpression: lstExpressions)
        {
            sObject sObj = lstRec.get(oExpression.SVMXC__Object_Name2__c);
            if(sObj == null)
                return false;
            mapResult.put(oExpression.SVMXC__Sequence__c,'F');
            string FieldType = oExpression.SVMXC__Display_Type__c ;
            if(FieldType != null && FieldType.length() > 0 && oExpression.SVMXC__Operator__c != null && oExpression.SVMXC__Operator__c.length() > 0 && oExpression.SVMXC__Field_Name__c != null)
            {
              // Added by Bala(Feb 21 2011): If field specified in expression is not available in org, the expression will be skipped
                try
                {
                    if( oExpression.get('SVMXC__Field_Name__c') != null )
                        sObj.get(oExpression.SVMXC__Field_Name__c);
                }
                catch(SObjectException ex)
                {
                    continue;
                }
                string strOperater = oExpression.SVMXC__Operator__c.ToUpperCase();
                string strFieldType = '';
                
                if( FieldType != null)
                  strFieldType = String.valueOf(FieldType.ToUpperCase());
                if(strFieldType == 'STRING' || strFieldType == 'COMBOBOX' || strFieldType == 'PICKLIST' || strFieldType == 'PHONE' || strFieldType == 'URL' || strFieldType == 'TEXTAREA')
                {
                    system.debug('Test-2'+strOperater);
                    if(strOperater == 'ISNULL')
                    {
                        if(sObj.get(oExpression.SVMXC__Field_Name__c) == null)
                            mapResult.put(oExpression.SVMXC__Sequence__c,'T');
                    }
                    else if(strOperater == 'ISNOTNULL')
                    {
                        if(sObj.get(oExpression.SVMXC__Field_Name__c) != null)
                            mapResult.put(oExpression.SVMXC__Sequence__c,'T');                  
                    }
                    string Val;
                    if(sObj.get(oExpression.SVMXC__Field_Name__c) != null)
                        val = string.valueOf(sObj.get(oExpression.SVMXC__Field_Name__c));
                    if(strOperater == 'EQ')
                    {
                        system.debug('Coming Here');
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
                    system.debug('Coming Here');
                    if(strOperater == 'ISNULL')
                    {
                        if(sObj.get(oExpression.SVMXC__Field_Name__c) == null)
                            mapResult.put(oExpression.SVMXC__Sequence__c,'T');
                    }
                    else if(strOperater == 'ISNOTNULL')
                    {
                        if(sObj.get(oExpression.SVMXC__Field_Name__c) != null)
                            mapResult.put(oExpression.SVMXC__Sequence__c,'T');
                    }
                    string Val;
                    if(sObj.get(oExpression.SVMXC__Field_Name__c) != null)
                        val = string.valueOf(sObj.get(oExpression.SVMXC__Field_Name__c));
                    if(strOperater == 'EQ')
                    {
                        if('TRUE' == oExpression.SVMXC__Operand__c.ToUpperCase() && (boolean)sObj.get(oExpression.SVMXC__Field_Name__c))
                            mapResult.put(oExpression.SVMXC__Sequence__c,'T');
                        if('FALSE' == oExpression.SVMXC__Operand__c.ToUpperCase() && !((boolean)sObj.get(oExpression.SVMXC__Field_Name__c)))
                            mapResult.put(oExpression.SVMXC__Sequence__c,'T');
                    }
                    else if(strOperater == 'NE')
                    {
                        if('TRUE' == oExpression.SVMXC__Operand__c.ToUpperCase() && !((boolean)sObj.get(oExpression.SVMXC__Field_Name__c)))
                            mapResult.put(oExpression.SVMXC__Sequence__c,'T');
                        if('FALSE' == oExpression.SVMXC__Operand__c.ToUpperCase() && (boolean)sObj.get(oExpression.SVMXC__Field_Name__c))
                            mapResult.put(oExpression.SVMXC__Sequence__c,'T');
                    }
                }
                else if(strFieldType == 'INTEGER')
                {
                    if(strOperater == 'ISNULL')
                    {
                        if(sObj.get(oExpression.SVMXC__Field_Name__c) == null)
                            mapResult.put(oExpression.SVMXC__Sequence__c,'T');
                    }
                    else if(strOperater == 'ISNOTNULL')
                    {
                        if(sObj.get(oExpression.SVMXC__Field_Name__c) != null)
                            mapResult.put(oExpression.SVMXC__Sequence__c,'T');
                    }
                    Integer Val;
                    if(sObj.get(oExpression.SVMXC__Field_Name__c) != null)
                        val = ((Decimal)sObj.get(oExpression.SVMXC__Field_Name__c)).IntValue();
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
                        if(sObj.get(oExpression.SVMXC__Field_Name__c) == null)
                            mapResult.put(oExpression.SVMXC__Sequence__c,'T');
                    }
                    else if(strOperater == 'ISNOTNULL')
                    {
                        if(sObj.get(oExpression.SVMXC__Field_Name__c) != null)
                            mapResult.put(oExpression.SVMXC__Sequence__c,'T');
                    }
                    DECIMAL Val;
                    if(sObj.get(oExpression.SVMXC__Field_Name__c) != null)
                        val = Decimal.valueOf(((Double)sObj.get(oExpression.SVMXC__Field_Name__c)));
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
                        if(sObj.get(oExpression.SVMXC__Field_Name__c) == null)
                            mapResult.put(oExpression.SVMXC__Sequence__c,'T');
                    }
                    else if(strOperater == 'ISNOTNULL')
                    {
                        if(sObj.get(oExpression.SVMXC__Field_Name__c) != null)
                            mapResult.put(oExpression.SVMXC__Sequence__c,'T');
                    }
                    DOUBLE Val;
                    if(sObj.get(oExpression.SVMXC__Field_Name__c) != null)
                        val = (DOUBLE)sObj.get(oExpression.SVMXC__Field_Name__c);
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
                else if(strFieldType == 'ID')
                {
                    if(strOperater == 'ISNULL')
                    {
                        if(sObj.get(oExpression.SVMXC__Field_Name__c) == null)
                            mapResult.put(oExpression.SVMXC__Sequence__c,'T');
                    }
                    else if(strOperater == 'ISNOTNULL')
                    {
                        if(sObj.get(oExpression.SVMXC__Field_Name__c) != null)
                            mapResult.put(oExpression.SVMXC__Sequence__c,'T');
                    }
                    Id Val;
                    if(sObj.get(oExpression.SVMXC__Field_Name__c) != null)
                        val = string.valueOf(sObj.get(oExpression.SVMXC__Field_Name__c));
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
                else if(strFieldType == 'REFERENCE')
                {
                    if(strOperater == 'ISNULL')
                    {
                        if(sObj.get(oExpression.SVMXC__Field_Name__c) == null)
                            mapResult.put(oExpression.SVMXC__Sequence__c,'T');
                    }
                    else if(strOperater == 'ISNOTNULL')
                    {
                        if(sObj.get(oExpression.SVMXC__Field_Name__c) != null)
                            mapResult.put(oExpression.SVMXC__Sequence__c,'T');
                    }
                    String Val;
                    SObject sobjInternalObjInQry = sObj.getSObject(oExpression.SVMXC__Field_Relationship_Name__c);
                    if(sobjInternalObjInQry != null &&  sobjInternalObjInQry.get(oExpression.SVMXC__FKey_Name_Field__c) != null)
                        val = string.valueOf(sobjInternalObjInQry.get(oExpression.SVMXC__FKey_Name_Field__c));
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
                            mapResult.put(oExpression.SVMXC__Sequence__c, 'T');
                        if(!setValues.contains(Val) && strOperater == 'NOTIN')
                            mapResult.put(oExpression.SVMXC__Sequence__c, 'T');
                    }
                }
                else if(strFieldType == 'DATE')
                {
                    if(strOperater == 'ISNULL')
                    {
                        if(sObj.get(oExpression.SVMXC__Field_Name__c) == null)
                            mapResult.put(oExpression.SVMXC__Sequence__c,'T');
                    }
                    else if(strOperater == 'ISNOTNULL')
                    {
                        if(sObj.get(oExpression.SVMXC__Field_Name__c) != null)
                            mapResult.put(oExpression.SVMXC__Sequence__c,'T');
                    }
                    Date Val;
                    if(sObj.get(oExpression.SVMXC__Field_Name__c) != null)
                        val = (date)sObj.get(oExpression.SVMXC__Field_Name__c);
                    if(strOperater == 'EQ')
                    {
                        if(SetDateRange.contains(oExpression.SVMXC__Operand__c))
                        {
                            if(isDateInRange(oExpression.SVMXC__Operand__c, Val))
                                mapResult.put(oExpression.SVMXC__Sequence__c,'T');
                        }
                        else if(Val == getDate(oExpression.SVMXC__Operand__c))
                            mapResult.put(oExpression.SVMXC__Sequence__c,'T');
                    }
                    else if(strOperater == 'NE')
                    {
                        if(SetDateRange.contains(oExpression.SVMXC__Operand__c))
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
                }
                else if(strFieldType == 'DATETIME')
                {
                    if(strOperater == 'ISNULL')
                    {
                        if(sObj.get(oExpression.SVMXC__Field_Name__c) == null)
                            mapResult.put(oExpression.SVMXC__Sequence__c,'T');
                    }
                    else if(strOperater == 'ISNOTNULL')
                    {
                        if(sObj.get(oExpression.SVMXC__Field_Name__c) != null)
                            mapResult.put(oExpression.SVMXC__Sequence__c,'T');
                    }
                    object Val;
                    if(sObj.get(oExpression.SVMXC__Field_Name__c) != null)
                        val = sObj.get(oExpression.SVMXC__Field_Name__c);
                    if(strOperater == 'EQ')
                    {
                        if(SetDateRange.contains(oExpression.SVMXC__Operand__c))
                        {
                            if(val != null && isDateTimeInRange(oExpression.SVMXC__Operand__c, Val))
                                mapResult.put(oExpression.SVMXC__Sequence__c,'T');
                        }
                        else if(Val == (object)getDateTime(oExpression.SVMXC__Operand__c))
                            mapResult.put(oExpression.SVMXC__Sequence__c,'T');
                    }
                    else if(strOperater == 'NE')
                    {
                        if(SetDateRange.contains(oExpression.SVMXC__Operand__c))
                        {
                            if(val != null && !isDateTimeInRange(oExpression.SVMXC__Operand__c, Val))
                                mapResult.put(oExpression.SVMXC__Sequence__c,'T');
                        }
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
            system.debug('Coming Here');
            set<string> setTemp = new set<string>();
            setTemp.addAll(mapResult.values());
            if(setTemp.size() == 0 || setTemp.Contains('F'))
                return false;
            else
                return true;
        }
        AdvExp = AdvExp.ToUpperCase();
        AdvExp = AdvExp.replaceAll('AND', ' && ');
        AdvExp = AdvExp.replaceAll('OR', ' || ');
        AdvExp = AdvExp.replaceAll('NOT', ' ! ');
        AdvExp = ' ' + AdvExp + ' ';
        for(integer k = 0; k < lstExpressions.size(); k++)
        {
            AdvExp = AdvExp.replace(string.valueOf(k+1),' ~' + string.valueOf(k+1) + '~ ');
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
    public boolean isValidString(string str)
    {
        if(str != null && str.length() > 0)
            return true;
        return false;
    }
    public Date getDate(String str)
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
    public boolean isDateInRange(string str, date ddate)
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
        return false;
    }
    public boolean isDateTimeInRange(string str, Object ddatetime)
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
        return false;
    }
    public DateTime getDateTime(String str)
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
    public List<SVMXC__ServiceMax_Config_Data__c> sortingExpressionList(List<SVMXC__ServiceMax_Config_Data__c> lstexp)
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
    public List<SVMXC__ServiceMax_Processes__c> sortRuleList(set<Id> lstRules, map<Id, SVMXC__ServiceMax_Processes__c> mapRules)
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
    /*
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
    }*/
    /*********************************************************************************************************************************
                                End Expression parsing Utility.
    *********************************************************************************************************************************/

  public list<SVMXC__RMA_Shipment_Order__c> checkHeaderQualification(list<SVMXC__RMA_Shipment_Order__c> lstOrders, String expressionId, SVMXC__ServiceMax_Processes__c Expression)
  {
    if(expressionId != NULL)
        Expression = [Select Id, Name, SVMXC__Source_Object_Name__c, SVMXC__Name__c, SVMXC__SettingId__c, SVMXC__Description__c, SVMXC__Advance_Expression__c, SVMXC__ProcessID__c, SVMXC__Parent_Object_Criteria__c, SVMXC__Child_Error_Msg2__c, SVMXC__IsStandard__c From SVMXC__ServiceMax_Processes__c where Recordtype.Name='SVMX Rule' AND SVMXC__Rule_Type__c = 'Named Expression' AND Id = :expressionId];
      else if(Expression == NULL)
        throw new SVMXException('INVALID REQUEST: Request doesnot pass expression details. Please check the process definition.');
      SVMXC.INTF_WebServicesDef.INTF_Expression SFMExpression = new SVMXC.INTF_WebServicesDef.INTF_Expression();
      if(Expression != null)
      {  
        SFMExpression.namedExpression = Expression;
          SVMXC.INTF_ParseExpression ExpParssig = new SVMXC.INTF_ParseExpression();
          lstOrders = ExpParssig.INTF_ParseExpression(lstOrders, SFMExpression);
      }
      else
        throw new SVMXException('DATA NOT AVAILABLE: Expression details are not available in organization. Please check the process definition.');
    return lstOrders;
  }
  
  public list<SVMXC__RMA_Shipment_Line__c> checkChildQualification(list<SVMXC__RMA_Shipment_Line__c> lstOrderLines,String expressionId, SVMXC__ServiceMax_Processes__c Expression)
  {
    if(expressionId != NULL)
        Expression = [Select Id, Name, SVMXC__Source_Object_Name__c, SVMXC__Name__c, SVMXC__SettingId__c, SVMXC__Description__c, SVMXC__Advance_Expression__c, SVMXC__ProcessID__c, SVMXC__Parent_Object_Criteria__c, SVMXC__Child_Error_Msg2__c, SVMXC__IsStandard__c From SVMXC__ServiceMax_Processes__c where Recordtype.Name='SVMX Rule' AND SVMXC__Rule_Type__c = 'Named Expression' AND Id = :expressionId];
      else if(Expression == NULL)
        throw new SVMXException('INVALID REQUEST: Request doesnot pass expression details. Please check the process definition.');
      SVMXC.INTF_WebServicesDef.INTF_Expression SFMExpression = new SVMXC.INTF_WebServicesDef.INTF_Expression();
      if(Expression != null)
      {
        SFMExpression.namedExpression = Expression;
          SVMXC.INTF_ParseExpression ExpParssig = new SVMXC.INTF_ParseExpression();
          lstOrderLines = ExpParssig.INTF_ParseExpression(lstOrderLines,SFMExpression);
      }
      else
        throw new SVMXException('DATA NOT AVAILABLE: Expression details are not available in organization. Please check the process definition.');
    return lstOrderLines;
  }
    public SVMXC.INTF_WebServicesDef.INTF_SFMResponse updateRouteCalculations(List<INTF_WebServicesDef.APL_OrderLineCollection> requestOrderLines, set<Id> uniqueOrderLines,String StrProcessType)//
    {
        SVMXC.INTF_WebServicesDef.INTF_SFMResponse response = new SVMXC.INTF_WebServicesDef.INTF_SFMResponse();
        response.success = true;
        try
        {
            map<Id, SVMXC__Route_Card__c> mapRouteCards = new map<Id, SVMXC__Route_Card__c>();
            map<Id, SVMXC__Route_Stop__c> mapRouteStops = new map<Id, SVMXC__Route_Stop__c>();
            map<Id, SVMXC__RMA_Shipment_Line__c> mapOrderLines = new map<Id, SVMXC__RMA_Shipment_Line__c>();
            map<String,list<SVMXC__Route_Stop__c>> mapRoutCardIdRouteStop = new map<String,list<SVMXC__Route_Stop__c>>(); 
            map<String, SVMXC__Route_Card__c> mapLineIdRouteCard = new map<String, SVMXC__Route_Card__c>();
            map<String, SVMXC__Route_Stop__c> mapLineIdOldRouteStopIdRouteStopList = new map<String, SVMXC__Route_Stop__c>();
            map<String,SVMXC__Route_Stop__c> mapRouteStopsAll = new map<String,SVMXC__Route_Stop__c>();
            set<String> RouteCardIds = new  set<String>();
            map<String,String> mapLineIdUniqueIdForClient = new map<String,String>();
            
            system.debug('requestOrderLines'+requestOrderLines.size()+requestOrderLines);
            mapRouteCards.putAll([Select SVMXC__Current_Stop__c, SVMXC__First_Stop__c, SVMXC__Last_Stop__c, SVMXC__Next_Stop__c, SVMXC__RMA__c, SVMXC__RMA_Line__c, SVMXC__Route_Type__c, SVMXC__Status__c, SVMXC__Supplier__c, SVMXC__Case__c, SVMXC__Case_Line__c, SVMXC__Customer__c from SVMXC__Route_Card__c where SVMXC__RMA_Line__c IN : uniqueOrderLines]);
            if(mapRouteCards.size() > 0)
            {
                mapRouteStops.putAll([Select SVMXC__Work_Order_Created__c, SVMXC__Stop_Number__c, SVMXC__Stop_Location__c, SVMXC__Shipped__c, SVMXC__Shipped_On__c, SVMXC__Shipped_By__c, SVMXC__Record_Card__c, SVMXC__Received__c, SVMXC__Received_On__c, SVMXC__Received_By__c, SVMXC__Picked__c, SVMXC__Picked_On__c, SVMXC__Picked_By__c, SVMXC__Next_Stop__c, SVMXC__Delivered__c, SVMXC__Delivered_On__c, SVMXC__Delivered_By__c, Name, Id From SVMXC__Route_Stop__c where SVMXC__Record_Card__c IN : mapRouteCards.keyset()]);
            }
            if(mapRouteStops.size() > 0)
            {
                for(String str : mapRouteStops.keyset())
                {
                    if(mapRoutCardIdRouteStop.containskey(mapRouteStops.get(str).SVMXC__Record_Card__c))
                    {
                        mapRoutCardIdRouteStop.get(mapRouteStops.get(str).SVMXC__Record_Card__c).add(mapRouteStops.get(str));
                    }
                    else
                    {
                        mapRoutCardIdRouteStop.put(mapRouteStops.get(str).SVMXC__Record_Card__c, new list<SVMXC__Route_Stop__c>());
                        mapRoutCardIdRouteStop.get(mapRouteStops.get(str).SVMXC__Record_Card__c).add(mapRouteStops.get(str));
                    }
                }
            }
            if(StrProcessType.toUpperCase() == 'PROCESSRECEIPT' || StrProcessType.toUpperCase() == 'PICKNMOVE')
            {
                for(INTF_WebServicesDef.APL_OrderLineCollection orderLine: requestOrderLines)
                {
                    mapOrderLines.put(orderLine.orderLineRecord.Id, orderLine.orderLineRecord);
                    mapLineIdUniqueIdForClient.put(orderLine.orderLineRecord.Id,orderLine.uniqueIdForClient);
                    if(orderLine != NULL && orderLine.clonedFromId != NULL && orderLine.orderLineRecord != NULL && orderLine.orderLineRecord.SVMXC__Route_Card__c != NULL && orderLine.orderLineRecord.SVMXC__Route_Stop__c != null)
                    {
                        system.debug('entered..'+orderLine.orderLineRecord.Name);
                        SVMXC__Route_Card__c clonedRouteCard = new SVMXC__Route_Card__c();
                        if(mapRouteCards.containskey(orderLine.orderLineRecord.SVMXC__Route_Card__c))
                            clonedRouteCard = mapRouteCards.get(orderLine.orderLineRecord.SVMXC__Route_Card__c).clone(false, true);
                        clonedRouteCard.SVMXC__RMA_Line__c = orderLine.orderLineRecord.Id;
                        clonedRouteCard.SVMXC__RMA__c = orderLine.orderLineRecord.SVMXC__RMA_Shipment_Order__c;
                        mapLineIdRouteCard.put(orderLine.orderLineRecord.Id,clonedRouteCard);
                        //Now Clone the Route Stops for the route card..
                        if(mapRoutCardIdRouteStop.containskey(orderLine.orderLineRecord.SVMXC__Route_Card__c))
                        {
                            list<SVMXC__Route_Stop__c> lstOldRouteStops = new list<SVMXC__Route_Stop__c>();
                            list<SVMXC__Route_Stop__c> lstClonedRouteStops = new list<SVMXC__Route_Stop__c>();
                            lstOldRouteStops = mapRoutCardIdRouteStop.get(orderLine.orderLineRecord.SVMXC__Route_Card__c);
                            if(lstOldRouteStops.size() > 0)
                            {
                                for(SVMXC__Route_Stop__c rs : lstOldRouteStops)
                                {
                                    String key = '';
                                    key += orderLine.orderLineRecord.id+'~'+rs.id;
                                    SVMXC__Route_Stop__c clonedRouteStop = rs.clone(false, true);
                                    mapLineIdOldRouteStopIdRouteStopList.put(key,clonedRouteStop);
                                }
                            }
                        }
                    }
                } 
                system.debug('mapLineIdUniqueIdForClient'+mapLineIdUniqueIdForClient.size()+mapLineIdUniqueIdForClient);
                system.debug('mapLineIdRouteCard'+mapLineIdRouteCard.size()+mapLineIdRouteCard);
                system.debug('mapLineIdOldRouteStopIdRouteStopList'+mapLineIdOldRouteStopIdRouteStopList.size()+mapLineIdOldRouteStopIdRouteStopList);  
                //Now insert the cloned route card..
                try
                {
                    if(mapLineIdRouteCard.size() > 0) {
                        if( COMM_SecurityUtils.getInstance().verifyFieldAccess( mapLineIdRouteCard.values(), COMM_SecurityUtils.Access.Createable ) ) {
                            insert mapLineIdRouteCard.values();
                        } else {
                            response.success = false;
                            response.message = System.Label.COMM001_TAG142;
                            return response;
                        }
                    }
                        
                }
                catch(System.DmlException e)
                {
                    list<String> LineIds = new list<String>();
                    LineIds.addall(mapLineIdRouteCard.keyset());
                    for (Integer i = 0; i < e.getNumDml(); i++) 
                    {
                        SVMXC.INTF_WebServicesDef.SVMXError error = new SVMXC.INTF_WebServicesDef.SVMXError(); 
                        error.errorMsg = e.getDmlMessage(i);
                        if(mapLineIdUniqueIdForClient.containskey(LineIds[i]))
                        {
                            error.errorMsg += ' For Unique Id: '+mapLineIdUniqueIdForClient.get(LineIds.get(i));
                            error.uniqueId = mapLineIdUniqueIdForClient.get(LineIds.get(i));
                        }   
                        response.errors.add(error);
                    }
                    response.success = false;
                    return response;
                }       
                //Now Loop the Cloned Route Stops and populate the new Route Card Id in those records
                if(mapLineIdOldRouteStopIdRouteStopList.size() > 0)
                {
                    
                    for(String str : mapLineIdOldRouteStopIdRouteStopList.keyset())
                    {
                        
                        list<String> lstString = new list<String>();
                        lstString = str.split('~');
                        if(mapLineIdRouteCard.containskey(lstString[0]))
                            mapLineIdOldRouteStopIdRouteStopList.get(str).SVMXC__Record_Card__c =  mapLineIdRouteCard.get(lstString[0]).id;
                    }
                }
                try
                {
                    if(mapLineIdOldRouteStopIdRouteStopList.size() > 0) {
                        if( COMM_SecurityUtils.getInstance().verifyFieldAccess( mapLineIdOldRouteStopIdRouteStopList.values(), COMM_SecurityUtils.Access.Createable ) ) {
                            insert mapLineIdOldRouteStopIdRouteStopList.values();
                        } else {
                            response.success = false;
                            response.message = System.Label.COMM001_TAG142;
                            return response;
                        }
                    }
                }
                catch(System.DmlException e)
                {
                    list<String> LineIds = new list<String>();
                    LineIds.addall(mapLineIdOldRouteStopIdRouteStopList.keyset());
                    for (Integer i = 0; i < e.getNumDml(); i++) 
                    {
                        SVMXC.INTF_WebServicesDef.SVMXError error = new SVMXC.INTF_WebServicesDef.SVMXError(); 
                        error.errorMsg = e.getDmlMessage(i);
                        list<String> lstString = new list<String>();
                        lstString = LineIds.get(i).split('~');
                        if(mapLineIdUniqueIdForClient.containskey(lstString[0]))
                        {
                            error.errorMsg += ' For Unique Id: '+mapLineIdUniqueIdForClient.get(lstString[0]);
                            error.uniqueId = mapLineIdUniqueIdForClient.get(lstString[0]);
                        }   
                        response.errors.add(error);
                    }
                    response.success = false;
                    return response;
                }   
                system.debug('mapLineIdOldRouteStopIdRouteStopList'+mapLineIdOldRouteStopIdRouteStopList.size()+mapLineIdOldRouteStopIdRouteStopList);
                //Now update the New Route Crad ID and Route Stop ID in The exsisting Order Line Record.
                if(mapOrderLines.size() > 0)
                {
                    for(String str : mapOrderLines.keyset())
                    {
                        
                        if(mapLineIdRouteCard.containskey(str))
                            mapOrderLines.get(str).SVMXC__Route_Card__c = mapLineIdRouteCard.get(str).id;
                        String key = mapOrderLines.get(str).id+'~'+ mapOrderLines.get(str).SVMXC__Route_Stop__c;
                        system.debug('amarkey: '+key);
                        if(mapLineIdOldRouteStopIdRouteStopList.containskey(key))
                            mapOrderLines.get(str).SVMXC__Route_Stop__c = mapLineIdOldRouteStopIdRouteStopList.get(key).id;
                    }
                }
                system.debug('mapOrderLines'+mapOrderLines.size()+mapOrderLines);
                try
                {
                    if(mapOrderLines.size() > 0) {
                        if( COMM_SecurityUtils.getInstance().verifyFieldAccess( mapOrderLines.values(), COMM_SecurityUtils.Access.Upsertable ) ) {
                            upsert mapOrderLines.values();
                        } else {
                            response.success = false;
                            response.message = System.Label.COMM001_TAG142;
                            return response;
                        }
                    }
                        
                }
                catch(System.DmlException e)
                {
                    list<Id> LineIds = new list<Id>();
                    LineIds.addall(mapOrderLines.keyset());
                    for (Integer i = 0; i < e.getNumDml(); i++) 
                    {
                        SVMXC.INTF_WebServicesDef.SVMXError error = new SVMXC.INTF_WebServicesDef.SVMXError(); 
                        error.errorMsg = e.getDmlMessage(i);
                        if(mapLineIdUniqueIdForClient.containskey(LineIds[i]))
                        {
                            error.errorMsg += ' For Unique Id: '+mapLineIdUniqueIdForClient.get(LineIds.get(i));
                            error.uniqueId = mapLineIdUniqueIdForClient.get(LineIds.get(i));
                        }   
                        response.errors.add(error);
                    }
                    response.success = false;
                    return response;
                }       
                //Now update the Route Steps for different Types of Processes
                set<String> RouteStopsIds = new set<String>();
                map<String,String> mapRouteCardIdLineId = new map<String,String>();
                if(StrProcessType.toUpperCase() == 'PROCESSRECEIPT')
                {
                    if(mapOrderLines.size() > 0)
                    {
                        for(String str : mapOrderLines.keyset())
                        {
                            if(mapOrderLines.get(str).SVMXC__Route_Stop__c != null && mapOrderLines.get(str).SVMXC__Received__c)
                                RouteStopsIds.add(mapOrderLines.get(str).SVMXC__Route_Stop__c);
                            if(mapOrderLines.get(str).SVMXC__Route_Card__c != null && mapOrderLines.get(str).SVMXC__Received__c)
                            {
                                RouteCardIds.add(mapOrderLines.get(str).SVMXC__Route_Card__c);
                                mapRouteCardIdLineId.put(mapOrderLines.get(str).SVMXC__Route_Card__c,mapOrderLines.get(str).id);
                            }      
                        }
                    }
                    if(RouteStopsIds.size() > 0)
                        mapRouteStopsAll.putall([Select SVMXC__Work_Order_Created__c, SVMXC__Stop_Number__c, SVMXC__Stop_Location__c, SVMXC__Shipped__c, SVMXC__Shipped_On__c, SVMXC__Shipped_By__c, SVMXC__Record_Card__c, SVMXC__Received__c, SVMXC__Received_On__c, SVMXC__Received_By__c, SVMXC__Picked__c, SVMXC__Picked_On__c, SVMXC__Picked_By__c, SVMXC__Next_Stop__c, SVMXC__Delivered__c, SVMXC__Delivered_On__c, SVMXC__Delivered_By__c, Name, Id From SVMXC__Route_Stop__c  where Id IN : RouteStopsIds]);
                    if(mapRouteStopsAll.size() > 0)
                    {
                        for(SVMXC__Route_Stop__c rs : mapRouteStopsAll.values())
                        {
                            rs.SVMXC__Received__c = true;
                            rs.SVMXC__Received_By__c = UserInfo.getUserId();
                            rs.SVMXC__Received_On__c = system.now();
                        }
                    }       
                }
                else if(StrProcessType.toUpperCase() == 'PICKNMOVE')
                {
                    if(mapOrderLines.size() > 0)
                    {
                        for(String str : mapOrderLines.keyset())
                        {
                            if(mapOrderLines.get(str).SVMXC__Route_Stop__c != null && mapOrderLines.get(str).SVMXC__Picked__c)
                                RouteStopsIds.add(mapOrderLines.get(str).SVMXC__Route_Stop__c);
                            if(mapOrderLines.get(str).SVMXC__Route_Card__c != null && mapOrderLines.get(str).SVMXC__Picked__c)
                            {
                                RouteCardIds.add(mapOrderLines.get(str).SVMXC__Route_Card__c);
                                mapRouteCardIdLineId.put(mapOrderLines.get(str).SVMXC__Route_Card__c,mapOrderLines.get(str).id);
                            }      
                        }
                    }
                    if(RouteStopsIds.size() > 0)
                        mapRouteStopsAll.putall([Select SVMXC__Work_Order_Created__c, SVMXC__Stop_Number__c, SVMXC__Stop_Location__c, SVMXC__Shipped__c, SVMXC__Shipped_On__c, SVMXC__Shipped_By__c, SVMXC__Record_Card__c, SVMXC__Received__c, SVMXC__Received_On__c, SVMXC__Received_By__c, SVMXC__Picked__c, SVMXC__Picked_On__c, SVMXC__Picked_By__c, SVMXC__Next_Stop__c, SVMXC__Delivered__c, SVMXC__Delivered_On__c, SVMXC__Delivered_By__c, Name, Id From SVMXC__Route_Stop__c  where Id IN : RouteStopsIds]);
                    if(mapRouteStopsAll.size() > 0)
                    {
                        for(SVMXC__Route_Stop__c rs :  mapRouteStopsAll.values())
                        {
                            rs.SVMXC__Picked__c = true;
                            rs.SVMXC__Picked_By__c = UserInfo.getUserId();
                            rs.SVMXC__Picked_On__c = system.now();
                        } 
                    }       
                }
                try
                {
                    if( COMM_SecurityUtils.getInstance().verifyFieldAccess( mapRouteStopsAll.values(), COMM_SecurityUtils.Access.Updateable ) ) {
                        update  mapRouteStopsAll.values();
                    } else {
                        response.success = false;
                        response.message = System.Label.COMM001_TAG142;
                        return response;
                    }                    
                }
                catch(System.DmlException e)
                {
                    for (Integer i = 0; i < e.getNumDml(); i++) 
                    {
                        SVMXC.INTF_WebServicesDef.SVMXError error = new SVMXC.INTF_WebServicesDef.SVMXError(); 
                        error.errorMsg = e.getDmlMessage(i);
                        if(mapRouteStopsAll.containskey(e.getDmlId(i)) && mapRouteCardIdLineId.containskey(mapRouteStopsAll.get(e.getDmlId(i)).SVMXC__Record_Card__c))
                        {
                            String strLineId = mapRouteCardIdLineId.get(mapRouteStopsAll.get(e.getDmlId(i)).SVMXC__Record_Card__c);
                            if(mapLineIdUniqueIdForClient.containskey(strLineId))
                            {
                                error.errorMsg += ' For Unique Id: '+mapLineIdUniqueIdForClient.get(strLineId);
                                error.uniqueId = mapLineIdUniqueIdForClient.get(strLineId);
                            }   
                        }   
                        response.errors.add(error);
                    }
                    response.success = false;
                    return response;
                }
                    
            }
            else if(StrProcessType.toUpperCase() == 'DELIVERYONRECEIPT' || StrProcessType.toUpperCase() == 'SHIPCONFIRM')
            {    
                set<String> RouteStopsIds = new set<String>();
                map<String,String> mapRouteCardIdLineId = new map<String,String>();
                for(INTF_WebServicesDef.APL_OrderLineCollection orderLine: requestOrderLines)
                {
                    if(orderLine.orderLineRecord.SVMXC__Route_Stop__c != null)  
                        RouteStopsIds.add(orderLine.orderLineRecord.SVMXC__Route_Stop__c);
                    if(orderLine.orderLineRecord.SVMXC__Route_Card__c != null) 
                    { 
                        RouteCardIds.add(orderLine.orderLineRecord.SVMXC__Route_Card__c);
                        mapRouteCardIdLineId.put(orderLine.orderLineRecord.SVMXC__Route_Card__c,orderLine.orderLineRecord.id);
                    }    
                }
                if(RouteStopsIds.size() > 0)
                    mapRouteStopsAll.putall([Select SVMXC__Work_Order_Created__c, SVMXC__Stop_Number__c, SVMXC__Stop_Location__c, SVMXC__Shipped__c, SVMXC__Shipped_On__c, SVMXC__Shipped_By__c, SVMXC__Record_Card__c, SVMXC__Received__c, SVMXC__Received_On__c, SVMXC__Received_By__c, SVMXC__Picked__c, SVMXC__Picked_On__c, SVMXC__Picked_By__c, SVMXC__Next_Stop__c, SVMXC__Delivered__c, SVMXC__Delivered_On__c, SVMXC__Delivered_By__c, Name,  Id From SVMXC__Route_Stop__c  where Id IN : RouteStopsIds]);
                if(mapRouteStopsAll.size() > 0)
                {
                    if(StrProcessType.toUpperCase() == 'DELIVERYONRECEIPT')
                    {
                        for(SVMXC__Route_Stop__c rs :  mapRouteStopsAll.values())
                        {
                            rs.SVMXC__Delivered__c = true;
                            rs.SVMXC__Delivered_By__c = UserInfo.getUserId();
                            rs.SVMXC__Delivered_On__c = system.now();
                        }   
                    }
                    else if(StrProcessType.toUpperCase() == 'SHIPCONFIRM')
                    {
                        for(SVMXC__Route_Stop__c rs :  mapRouteStopsAll.values())
                        {
                            rs.SVMXC__Shipped__c = true;
                            rs.SVMXC__Shipped_By__c = UserInfo.getUserId();
                            rs.SVMXC__Shipped_On__c = system.now();
                        }   
                    }
                    try
                    {
                        if( COMM_SecurityUtils.getInstance().verifyFieldAccess( mapRouteStopsAll.values(), COMM_SecurityUtils.Access.Updateable ) ) {
                            update  mapRouteStopsAll.values();
                        } else {
                            response.success = false;
                            response.message = System.Label.COMM001_TAG142;
                            return response;
                        }
                    }
                    catch(System.DmlException e)
                    {
                        for (Integer i = 0; i < e.getNumDml(); i++) 
                        {
                            SVMXC.INTF_WebServicesDef.SVMXError error = new SVMXC.INTF_WebServicesDef.SVMXError(); 
                            error.errorMsg = e.getDmlMessage(i);
                            if(mapRouteStopsAll.containskey(e.getDmlId(i)) && mapRouteCardIdLineId.containskey(mapRouteStopsAll.get(e.getDmlId(i)).SVMXC__Record_Card__c))
                            {
                                String strLineId = mapRouteCardIdLineId.get(mapRouteStopsAll.get(e.getDmlId(i)).SVMXC__Record_Card__c);
                                if(mapLineIdUniqueIdForClient.containskey(strLineId))
                                {
                                    error.errorMsg += ' For Unique Id: '+mapLineIdUniqueIdForClient.get(strLineId);
                                    error.uniqueId = mapLineIdUniqueIdForClient.get(strLineId);
                                }   
                            }   
                            response.errors.add(error);
                        }
                        response.success = false;
                        return response;
                    }
                }    
            }    
            //Update the Route Card for Process Receipt..
            if(StrProcessType.toUpperCase() == 'PROCESSRECEIPT' && RouteCardIds.size() > 0)
            {
                list<SVMXC__Route_Card__c> lstRouteCards = new list<SVMXC__Route_Card__c>();
                lstRouteCards = [Select SVMXC__Supplier__c, SVMXC__Status__c, SVMXC__Route_Type__c, SVMXC__RMA__c, SVMXC__RMA_Line__c, SVMXC__Next_Stop__c, SVMXC__Last_Stop__c, SVMXC__First_Stop__c, SVMXC__Customer__c, SVMXC__Current_Stop__c, SVMXC__Case__c, SVMXC__Case_Line__c, OwnerId, Name, Id From SVMXC__Route_Card__c where id IN :RouteCardIds];
                system.debug('lstRouteCards'+lstRouteCards.size()+lstRouteCards);
                map<String,SVMXC__RMA_Shipment_Line__c> mapRouteCardIdLineRecord = new map<String,SVMXC__RMA_Shipment_Line__c>();
                if(mapOrderLines.size() > 0)
                {
                    for(String str : mapOrderLines.keyset())
                    {
                        mapRouteCardIdLineRecord.put(mapOrderLines.get(str).SVMXC__Route_Card__c,mapOrderLines.get(str));
                    }
                }
                system.debug('mapRouteCardIdLineRecord'+mapRouteCardIdLineRecord.size()+mapRouteCardIdLineRecord);
                if(lstRouteCards.size() > 0)
                {
                    for(SVMXC__Route_Card__c rc : lstRouteCards)
                    {
                        //system.debug('amar'+rc.id+mapRouteCardIdLineRecord.containskey(rc.id)+mapRouteCardIdLineRecord.get(rc.id).SVMXC__Route_Stop__c+mapRouteStopsAll.containskey(mapRouteCardIdLineRecord.get(rc.id).SVMXC__Route_Stop__c));
                        if(rc.id != null && mapRouteCardIdLineRecord.containskey(rc.id) && mapRouteCardIdLineRecord.get(rc.id).SVMXC__Route_Stop__c != null && mapRouteStopsAll.containskey(mapRouteCardIdLineRecord.get(rc.id).SVMXC__Route_Stop__c)) 
                        {
                            system.debug('Entered..');
                            //If RAM Line's Route Stop's Stop Location is not null then update it in to Current Location of Route Card
                            if(mapRouteStopsAll.get(mapRouteCardIdLineRecord.get(rc.id).SVMXC__Route_Stop__c).SVMXC__Stop_Location__c != null)
                                rc.SVMXC__Current_Stop__c = mapRouteStopsAll.get(mapRouteCardIdLineRecord.get(rc.id).SVMXC__Route_Stop__c).SVMXC__Stop_Location__c;
                            if(mapRouteStopsAll.get(mapRouteCardIdLineRecord.get(rc.id).SVMXC__Route_Stop__c).SVMXC__Next_Stop__c != null)
                                rc.SVMXC__Next_Stop__c = mapRouteStopsAll.get(mapRouteCardIdLineRecord.get(rc.id).SVMXC__Route_Stop__c).SVMXC__Next_Stop__c;
                            else
                                rc.SVMXC__Status__c = 'Close';  
                        }
                    }
                    system.debug('lstRouteCards'+lstRouteCards.size()+lstRouteCards);
                    try
                    {
                        if( COMM_SecurityUtils.getInstance().verifyFieldAccess( lstRouteCards, COMM_SecurityUtils.Access.Updateable ) ) {
                            update lstRouteCards; //SDL-SVMX-CREATE-UPDATE-FLS-ENFORCED
                        } else {
                            response.success = false;
                            response.message = System.Label.COMM001_TAG142;
                            return response;
                        }
                    }
                    catch(System.DmlException e)
                    {
                        for (Integer i = 0; i < e.getNumDml(); i++) 
                        {
                            SVMXC.INTF_WebServicesDef.SVMXError error = new SVMXC.INTF_WebServicesDef.SVMXError(); 
                            error.errorMsg = e.getDmlMessage(i);
                            if(mapLineIdUniqueIdForClient.containskey(lstRouteCards.get(i).SVMXC__RMA_Line__c))
                            {
                                error.errorMsg += ' For Unique Id: '+mapLineIdUniqueIdForClient.get(lstRouteCards.get(i).SVMXC__RMA_Line__c);
                                error.uniqueId = mapLineIdUniqueIdForClient.get(lstRouteCards.get(i).SVMXC__RMA_Line__c);
                            }   
                            response.errors.add(error);
                        }
                        response.success = false;
                        return response;
                    }   
                }
                
            }
        }
        catch(Exception ex)
        {
            response.message = ex.getMessage();
            response.success = false;
        }
        return response;            
    }
    public SVMXC.INTF_WebServicesDef.INTF_SFMResponse CreateInternalExternalRMA(SVMXC.INTF_WebServicesDef.INTF_SFMRequest request)
    {
        system.debug('request'+request);
        SVMXC.INTF_WebServicesDef.APL_Order APLOrder = new SVMXC.INTF_WebServicesDef.APL_Order();
        SVMXC.INTF_WebServicesDef.INTF_SFMResponse response = new SVMXC.INTF_WebServicesDef.INTF_SFMResponse();
        APLOrder = request.aplOrder;
        system.debug('APLOrder'+APLOrder);
        RecordType RMAHeaderRecordType = [select id,Name,SobjectType from RecordType where Name = 'RMA' and SobjectType = 'SVMXC__RMA_Shipment_Order__c']; //SDL-SVMX-FLS-NOT-ENFORCED-META-DATA
        RecordType RMALineRecordType = [select id,Name,SobjectType from RecordType where Name = 'RMA' and SobjectType = 'SVMXC__RMA_Shipment_Line__c']; //SDL-SVMX-FLS-NOT-ENFORCED-META-DATA
        response.success = true;
        try
        {
            map<String, Schema.SObjectType> mapGlobalDescribe = new map<String, Schema.SObjectType>();
            map<String, Schema.SObjectType> mapAllObjDescribe  = new map<String, Schema.SObjectType>();
            SVMXC__ServiceMax_Processes__c svmxProcess = new SVMXC__ServiceMax_Processes__c();
            SVMXC__RMA_Shipment_Order__c orderHdrRecord = new SVMXC__RMA_Shipment_Order__c();
            list<SVMXC.INTF_WebServicesDef.APL_OrderLineCollection> orderLineCollection = new list<SVMXC.INTF_WebServicesDef.APL_OrderLineCollection>();
            svmxProcess = APLOrder.svmxProcess;
            orderHdrRecord = APLOrder.orderHdrRecord;
            orderLineCollection = APLOrder.orderLines;
            if(orderHdrRecord.SVMXC__Destination_Location__c != null)
            {
                map<String,SVMXC__Route_Stop__c> mapRouteStops = new map<String,SVMXC__Route_Stop__c>();
                map<String,map<String,String>> mapRouteCardIdMapStopNoRouteStopId = new map<String,map<String,String>>();
                map<String,SVMXC__RMA_Shipment_Line__c> mapShipmentOrderLine = new map<String,SVMXC__RMA_Shipment_Line__c>();
                list<SVMXC__Site__c> lstLocation = new list<SVMXC__Site__c>();
                SVMXC.INTF_ApplyMapping applyMapping = new SVMXC.INTF_ApplyMapping();
                
                mapGlobalDescribe = Schema.getGlobalDescribe();
                for(Schema.SObjectType s : mapGlobalDescribe.values())
                {
                    Schema.DescribeSObjectResult result = s.getDescribe();
                    mapAllObjDescribe.put(result.getName(),s);
                }
                system.debug('mapAllObjDescribe: '+mapAllObjDescribe); 
                lstLocation = [select Id, Name, RecordTypeId, SVMXC__Location_Type__c from SVMXC__Site__c where Id =: orderHdrRecord.SVMXC__Destination_Location__c and SVMXC__Location_Type__c = 'Supplier'];
                if(lstLocation.size() > 0 && svmxProcess.SVMXC__APL_Create_Supplier_RMA__c)
                {
                    system.debug('Entered for ERMA Creation..');
                    //First get the Master RMA From Shipment Order and then Create Intenal RMA from Master RMA..
                    String strMasterRMAId = '';
                    list<Sobject> LstExternalRMA = new list<Sobject>();
                    list<Sobject> LstInput = new list<Sobject>();
                    SVMXC__RMA_Shipment_Order__c ExternalRMA = new SVMXC__RMA_Shipment_Order__c();
                    if(orderHdrRecord.SVMXC__Master_Order__c != null)
                        strMasterRMAId = orderHdrRecord.SVMXC__Master_Order__c;
                    LstInput.add(ExternalRMA);
                    //Apply Mapping
                    if(LstInput.size() == 1 && svmxProcess.SVMXC__Process1__c != null)
                        LstExternalRMA = applyMapping.getApplyMapping(LstInput,svmxProcess.SVMXC__Process1__c,strMasterRMAId,false,mapAllObjDescribe);
                    system.debug('External RMA..' + LstExternalRMA);
                    //Loop External RMA and Populate the SVMXC_Master_Order__c from the Shipment Order
                    if(LstExternalRMA.size() == 1)
                    {
                        ExternalRMA = new SVMXC__RMA_Shipment_Order__c();
                        ExternalRMA = (SVMXC__RMA_Shipment_Order__c)LstExternalRMA[0];
                        if(orderHdrRecord.SVMXC__Master_Order__c != null)
                            ExternalRMA.SVMXC__Master_Order__c = orderHdrRecord.SVMXC__Master_Order__c;
                        ExternalRMA.SVMXC__Shipment_Reference__c = orderHdrRecord.id;     
                        if(orderHdrRecord.SVMXC__Source_Location__c != null)
                            ExternalRMA.SVMXC__Destination_Location__c = orderHdrRecord.SVMXC__Source_Location__c;
                        if(orderHdrRecord.SVMXC__Destination_Location__c != null)
                            ExternalRMA.SVMXC__Source_Location__c = orderHdrRecord.SVMXC__Destination_Location__c;  
                        ExternalRMA.RecordTypeId = RMAHeaderRecordType.id;
                        ExternalRMA.SVMXC__RMA_Type__c = 'External';
                        ExternalRMA.SVMXC__Fulfillment_Type__c = null;
                        if( COMM_SecurityUtils.getInstance().verifyFieldAccess( ExternalRMA, COMM_SecurityUtils.Access.Createable ) ) {
                            insert ExternalRMA; //SDL-SVMX-CREATE-UPDATE-FLS-ENFORCED
                        } else {
                            response.success = false;
                            response.message = System.Label.COMM001_TAG142;
                            return response;
                        }
                        
                        system.debug('External RMA2..' + ExternalRMA);
                    }
                    
                    map<String,SVMXC__RMA_Shipment_Line__c> mapMasterRMALine = new map<String,SVMXC__RMA_Shipment_Line__c>();
                    map<String,Sobject> mapExternalRMALins = new map<String,Sobject>();
                    map<String,Sobject> SourceRecIdTargetObjMap = new map<String,Sobject>();
                    set<String> setRouteCardIds = new set<String>();
                    Set<String> setMasterOrderLineIDs = new Set<String>();
                    
                    //Loop Shipment Order Lines and get all Master Order Lines IDs then Query Master Order Lines and then Apply mapping and create Internal RAM Lines..
                    if(orderLineCollection.size() > 0)
                    {
                        for(Integer i = 0;i<orderLineCollection.size();i++)
                        {
                            if(orderLineCollection[i].orderLineRecord.id != null)
                            {
                                mapShipmentOrderLine.put(orderLineCollection[i].orderLineRecord.SVMXC__Master_Order_Line__c,orderLineCollection[i].orderLineRecord);
                                if(orderLineCollection[i].orderLineRecord.SVMXC__Route_Card__c != null)
                                    setRouteCardIds.add(orderLineCollection[i].orderLineRecord.SVMXC__Route_Card__c);
                                if(orderLineCollection[i].orderLineRecord.SVMXC__Master_Order_Line__c != null)
                                    setMasterOrderLineIDs.add(orderLineCollection[i].orderLineRecord.SVMXC__Master_Order_Line__c);
                            }   
                        }
                    }
                    
                    //Query Master RAM Lines from Master RMA Line IDs
                    mapMasterRMALine.putall([Select Id From SVMXC__RMA_Shipment_Line__c where Id IN : setMasterOrderLineIDs]);
                    system.debug('mapMasterRMALine'+mapMasterRMALine.size()+mapMasterRMALine);
                    //Loop Master RAM Lines and and Create the Corrosponding Internal RAM and then apply for mapping.
                    if(mapMasterRMALine.size() > 0)
                    {
                        for(String str : mapMasterRMALine.keyset())
                        {
                            SVMXC__RMA_Shipment_Line__c RMALine = new SVMXC__RMA_Shipment_Line__c();
                            RMALine.SVMXC__RMA_Shipment_Order__c = ExternalRMA.id;
                            SourceRecIdTargetObjMap.put(str,RMALine);
                        }
                    }
                    system.debug('SourceRecIdTargetObjMap'+SourceRecIdTargetObjMap.size()+SourceRecIdTargetObjMap);
                    //Apply Mapping
                    if(SourceRecIdTargetObjMap.size() > 0 && svmxProcess.SVMXC__Process2__c != null)
                        mapExternalRMALins = applyMapping.getApplyMappingCore(svmxProcess.SVMXC__Process2__c,SourceRecIdTargetObjMap,false,mapAllObjDescribe);
                    system.debug('mapExternalRMALins'+mapExternalRMALins.size()+mapExternalRMALins);
                    list<SVMXC__RMA_Shipment_Line__c> lstExternalRMALine = new list<SVMXC__RMA_Shipment_Line__c>();
                    if(mapExternalRMALins.size() > 0)
                    {
                        for(String str : mapExternalRMALins.keyset())
                        {
                            SVMXC__RMA_Shipment_Line__c RMALine = new SVMXC__RMA_Shipment_Line__c();
                            RMALine = (SVMXC__RMA_Shipment_Line__c)mapExternalRMALins.get(str);
                            if(mapShipmentOrderLine.containskey(str))
                            {
                                // Update the SVMXC__Master_Order_Line__c in New ERAM from Shipment document..
                                RMALine.SVMXC__Master_Order_Line__c = mapShipmentOrderLine.get(str).SVMXC__Master_Order_Line__c;
                                RMALine.RecordTypeId = RMALineRecordType.id;
                                RMALine.SVMXC__Route_Stop__c = null;
                                lstExternalRMALine.add(RMALine);
                            }   
                        }
                    }
                    if(lstExternalRMALine.size() > 0)
                    {
                        
                        for(Integer i = 0;i<lstExternalRMALine.size();i++)
                        {
                            lstExternalRMALine[i].SVMXC__Route_Card__c = null;
                            lstExternalRMALine[i].SVMXC__Route_Stop__c = null;
                        }
                        if( COMM_SecurityUtils.getInstance().verifyFieldAccess( lstExternalRMALine, COMM_SecurityUtils.Access.Createable ) ) {
                            insert lstExternalRMALine; //SDL-SVMX-CREATE-UPDATE-FLS-ENFORCED
                        } else {
                            response.success = false;
                            response.message = System.Label.COMM001_TAG142;
                            return response;
                        }                        
                    }
                    //Now Query Route Cards and make them close them. They are no longer used because Supplier RMA is created.
                    if(setRouteCardIds.size() > 0)
                    {
                        map<String,SVMXC__Route_Card__c> mapRouteCard = new map<String,SVMXC__Route_Card__c>();
                        mapRouteCard.putall([select Id,SVMXC__Status__c,Name from SVMXC__Route_Card__c where Id IN : setRouteCardIds]);
                        if(mapRouteCard.size() > 0)
                        {
                            for(String str : mapRouteCard.keyset())
                            {
                                mapRouteCard.get(str).SVMXC__Status__c = 'Close';
                            }
                            if( COMM_SecurityUtils.getInstance().verifyFieldAccess( mapRouteCard.values(), COMM_SecurityUtils.Access.Updateable ) ) {
                                update mapRouteCard.values();
                            } else {
                                response.success = false;
                                response.message = System.Label.COMM001_TAG142;
                                return response;
                            }
                        }
                    }     
                }
                else //Create Internal RMA
                {
                    lstLocation = [select Id, Name, RecordTypeId, SVMXC__Location_Type__c from SVMXC__Site__c where Id =: orderHdrRecord.SVMXC__Destination_Location__c and RecordType.Name = 'Depot'];//and SVMXC__Location_Type__c = 'Internal' 
                    system.debug('lstLocation'+lstLocation.size()+lstLocation);
                    if(lstLocation.size() > 0 && svmxProcess.SVMXC__APL_Create_Internal_RMA__c)
                    {
                        //First get the Master RMA From Shipment Order and then Create Intenal RMA from Master RMA..
                        String strMasterRMAId = '';
                        list<Sobject> LstInternalRMA = new list<Sobject>();
                        list<Sobject> LstInput = new list<Sobject>();
                        LstInput.add(new SVMXC__RMA_Shipment_Order__c());
                        SVMXC__RMA_Shipment_Order__c InternalRMA = new SVMXC__RMA_Shipment_Order__c();
                        if(orderHdrRecord.SVMXC__Master_Order__c != null)
                            strMasterRMAId = orderHdrRecord.SVMXC__Master_Order__c;
                        //Apply Mapping
                        if(LstInput.size() == 1 && svmxProcess.SVMXC__Parent_Object__c != null)
                            LstInternalRMA = applyMapping.getApplyMapping(LstInput,svmxProcess.SVMXC__Parent_Object__c,strMasterRMAId,false,mapAllObjDescribe);
                        system.debug('LstInternalRMA'+LstInternalRMA.size()+LstInternalRMA);
                        //Loop Internal RMA and Populate the SVMXC_Master_Order__c from the Shipment Order
                        if(LstInternalRMA.size() == 1)
                        {
                            InternalRMA = (SVMXC__RMA_Shipment_Order__c)LstInternalRMA[0];
                            if(orderHdrRecord.SVMXC__Master_Order__c != null)
                                InternalRMA.SVMXC__Master_Order__c = orderHdrRecord.SVMXC__Master_Order__c;
                            InternalRMA.SVMXC__Shipment_Reference__c = orderHdrRecord.id;
                            if(orderHdrRecord.SVMXC__Destination_Location__c != null)
                                InternalRMA.SVMXC__Destination_Location__c = orderHdrRecord.SVMXC__Destination_Location__c;
                            if(orderHdrRecord.SVMXC__Source_Location__c != null)
                                InternalRMA.SVMXC__Source_Location__c = orderHdrRecord.SVMXC__Source_Location__c;   
                            InternalRMA.RecordTypeId = RMAHeaderRecordType.id;
                            InternalRMA.SVMXC__RMA_Type__c = 'Internal';
                            InternalRMA.SVMXC__Fulfillment_Type__c = null;
                            system.debug('InternalRMA'+InternalRMA);
                            if( COMM_SecurityUtils.getInstance().verifyFieldAccess( InternalRMA, COMM_SecurityUtils.Access.Createable ) ) {
                                insert InternalRMA; //SDL-SVMX-CREATE-UPDATE-FLS-ENFORCED
                            } else {
                                response.success = false;
                                response.message = System.Label.COMM001_TAG142;
                                return response;
                            }
                        }
                        
                        map<String,SVMXC__RMA_Shipment_Line__c> mapMasterRMALine = new map<String,SVMXC__RMA_Shipment_Line__c>();
                        map<String,Sobject> mapInternalRMALins = new map<String,Sobject>();
                        map<String,Sobject> SourceRecIdTargetObjMap = new map<String,Sobject>();
                        set<String> setRouteCardIds = new set<String>();
                        Set<String> setMasterOrderLineIDs = new Set<String>();
                        
                        //Loop Shipment Order Lines and get all Master Order Lines IDs then Query Master Order Lines and then Apply mapping and create Internal RAM Lines..
                        if(orderLineCollection.size() > 0)
                        {
                            for(Integer i = 0;i<orderLineCollection.size();i++)
                            {
                                if(orderLineCollection[i].orderLineRecord.id != null)
                                {
                                    mapShipmentOrderLine.put(orderLineCollection[i].orderLineRecord.SVMXC__Master_Order_Line__c,orderLineCollection[i].orderLineRecord);
                                    if(orderLineCollection[i].orderLineRecord.SVMXC__Route_Card__c != null)
                                        setRouteCardIds.add(orderLineCollection[i].orderLineRecord.SVMXC__Route_Card__c);
                                    if(orderLineCollection[i].orderLineRecord.SVMXC__Master_Order_Line__c != null)
                                        setMasterOrderLineIDs.add(orderLineCollection[i].orderLineRecord.SVMXC__Master_Order_Line__c);
                                }   
                            }
                        }
                        system.debug('mapShipmentOrderLine'+mapShipmentOrderLine.size()+mapShipmentOrderLine);
                        system.debug('setRouteCardIds'+setRouteCardIds.size()+setRouteCardIds);
                        //Query Master RAM Lines from Master RMA Line IDs
                        mapMasterRMALine.putall([Select SystemModstamp, SVMXC__Work_Order_Created__c, SVMXC__Warehouse__c, SVMXC__Use_Price_From_Pricebook__c, SVMXC__Total_Line_Price2__c, SVMXC__Shipped__c, SVMXC__Shipped_On__c, SVMXC__Shipped_By__c, SVMXC__Ship_Location__c, SVMXC__Service_Order__c, SVMXC__Service_Order_Line__c, SVMXC__Service_Engineer__c, SVMXC__Serial_Number__c, SVMXC__Serial_Number_List__c, SVMXC__Select__c, SVMXC__Sales_Order_Number__c, SVMXC__Route_Stop__c, SVMXC__Route_Card__c, SVMXC__Returned_Condition__c, SVMXC__Reconciliation_Action__c, SVMXC__Received__c, SVMXC__Received_On__c, SVMXC__Received_By__c, SVMXC__RMA_Shipment_Order__c, SVMXC__Product__c, SVMXC__Posted_To_Inventory__c, SVMXC__Picked__c, SVMXC__Picked_Qty__c, SVMXC__Picked_On__c, SVMXC__Picked_By__c, SVMXC__Parts_Request_Line__c, SVMXC__Packing_Instructions__c, SVMXC__Master_Order_Line__c, SVMXC__Line_Type__c, SVMXC__Line_Status__c, SVMXC__Line_Price2__c, SVMXC__Expected_Ship_Date__c, SVMXC__Expected_Receipt_Date__c, SVMXC__Expected_Quantity2__c, SVMXC__Expected_Condition__c, SVMXC__Disposition__c, SVMXC__Disposition_Instructions__c, SVMXC__Discount_Percentage__c, SVMXC__Delivery_Location__c, SVMXC__Delivered__c, SVMXC__Delivered_On__c, SVMXC__Delivered_By__c, SVMXC__Closed_On__c, SVMXC__Closed_By__c, SVMXC__Case_Line__c, SVMXC__Canceled_On__c, SVMXC__Canceled_By__c, SVMXC__Actual_Ship_Date__c, SVMXC__Actual_Receipt_Date__c, SVMXC__Actual_Quantity2__c, RecordTypeId, Name, LastModifiedDate, LastModifiedById,  IsDeleted, Id, CreatedDate, CreatedById From SVMXC__RMA_Shipment_Line__c where Id IN : setMasterOrderLineIDs]);
                        
                        //Loop Master RAM Lines and and Create the Corrosponding Internal RAM and then apply for mapping.
                        if(mapMasterRMALine.size() > 0)
                        {
                            for(String str : mapMasterRMALine.keyset())
                            {
                                SVMXC__RMA_Shipment_Line__c RMALine = new SVMXC__RMA_Shipment_Line__c();
                                SourceRecIdTargetObjMap.put(str,RMALine);
                            }
                        }
                        
                        //Apply Mapping
                        if(SourceRecIdTargetObjMap.size() > 0 && svmxProcess.SVMXC__Process__c != null)
                            mapInternalRMALins = applyMapping.getApplyMappingCore(svmxProcess.SVMXC__Process__c,SourceRecIdTargetObjMap,false,mapAllObjDescribe);
                        system.debug('mapInternalRMALins'+mapInternalRMALins.size()+mapInternalRMALins);
                        //Now Query the RouteStop and Create map<RouteCardId,Map<StopNumber,RouteStopId>> so we can populate Next Route Stop Id in IRMA..
                        if(setRouteCardIds.size() > 0)
                            mapRouteStops.putall([select Id,Name,SVMXC__Stop_Location__c,SVMXC__Next_Stop__c,SVMXC__Stop_Number__c, SVMXC__Record_Card__c from SVMXC__Route_Stop__c where SVMXC__Record_Card__c IN : setRouteCardIds]);
                        system.debug('mapRouteStops'+mapRouteStops.size()+mapRouteStops);
                        if(mapRouteStops.size() > 0)
                        {
                            for(String str:mapRouteStops.keyset())
                            {
                                if(mapRouteCardIdMapStopNoRouteStopId.containskey(mapRouteStops.get(str).SVMXC__Record_Card__c))
                                {
                                    mapRouteCardIdMapStopNoRouteStopId.get(mapRouteStops.get(str).SVMXC__Record_Card__c).put(String.valueOf(mapRouteStops.get(str).SVMXC__Stop_Number__c),mapRouteStops.get(str).id);
                                }
                                else
                                {
                                    mapRouteCardIdMapStopNoRouteStopId.put(mapRouteStops.get(str).SVMXC__Record_Card__c,new map<String,String>());
                                    mapRouteCardIdMapStopNoRouteStopId.get(mapRouteStops.get(str).SVMXC__Record_Card__c).put(String.valueOf(mapRouteStops.get(str).SVMXC__Stop_Number__c),mapRouteStops.get(str).id);
                                }
                            }
                        }
                        system.debug('mapRouteCardIdMapStopNoRouteStopId: '+mapRouteCardIdMapStopNoRouteStopId.size()+mapRouteCardIdMapStopNoRouteStopId);
                        list<SVMXC__RMA_Shipment_Line__c> lstInternalRMALine = new list<SVMXC__RMA_Shipment_Line__c>();
                        if(mapInternalRMALins.size() > 0)
                        {
                            for(String str : mapInternalRMALins.keyset())
                            {
                                SVMXC__RMA_Shipment_Line__c RMALine = new SVMXC__RMA_Shipment_Line__c();
                                RMALine = (SVMXC__RMA_Shipment_Line__c)mapInternalRMALins.get(str);
                                RMALine.SVMXC__RMA_Shipment_Order__c = InternalRMA.id;
                                RMALine.RecordTypeId = RMALineRecordType.id;
                                if(mapShipmentOrderLine.containskey(str))
                                {
                                    system.debug('amarenter1');
                                    // Update the SVMXC__Master_Order_Line__c in New IRAM from Shipment document..
                                    RMALine.SVMXC__Master_Order_Line__c = mapShipmentOrderLine.get(str).SVMXC__Master_Order_Line__c;
                                    RMALine.SVMXC__Route_Card__c =  mapShipmentOrderLine.get(str).SVMXC__Route_Card__c;
                                    if(mapRouteCardIdMapStopNoRouteStopId.containskey(mapShipmentOrderLine.get(str).SVMXC__Route_Card__c))
                                    {
                                        map<String,String> mapStopNoRoutStopId = new map<String,String>(); 
                                        mapStopNoRoutStopId = mapRouteCardIdMapStopNoRouteStopId.get(mapShipmentOrderLine.get(str).SVMXC__Route_Card__c);
                                        system.debug('amarenter2'+mapStopNoRoutStopId.size()+mapStopNoRoutStopId);
                                        if(mapStopNoRoutStopId.size() > 0)
                                        {
                                            Integer StopNo = 0;
                                            if(mapRouteStops.containskey(mapShipmentOrderLine.get(str).SVMXC__Route_Stop__c))
                                                StopNo = Integer.valueof(mapRouteStops.get(mapShipmentOrderLine.get(str).SVMXC__Route_Stop__c).SVMXC__Stop_Number__c);
                                            if(mapStopNoRoutStopId.containskey(String.valueof(StopNo + 1))) 
                                            {
                                                RMALine.SVMXC__Route_Stop__c = mapStopNoRoutStopId.get(String.valueof(StopNo + 1));
                                            }   
                                        }
                                    }
                                }
                                lstInternalRMALine.add(RMALine);  
                            }
                        }
                        system.debug('lstInternalRMALine'+lstInternalRMALine.size()+lstInternalRMALine);
                        if(lstInternalRMALine.size() > 0) {
                            if( COMM_SecurityUtils.getInstance().verifyFieldAccess( lstInternalRMALine, COMM_SecurityUtils.Access.Createable ) ) {
                                insert lstInternalRMALine; //SDL-SVMX-CREATE-UPDATE-FLS-ENFORCED
                            } else {
                                response.success = false;
                                response.message = System.Label.COMM001_TAG142;
                            }
                        }                            
                    }            
                }
           }
        }
        catch(Exception ex)
        {
            response.message = ex.getMessage();
            response.success = false;
        }
        return response;    
    }
    
    public List<SVMXC__ServiceMax_Config_Data__c> PopulateInfoForReferenceFields(List<SVMXC__ServiceMax_Config_Data__c> lstExprRows)
    {
        MAP<String,Schema.SObjectType> allObjs = Schema.getGlobalDescribe();

        Map<String,Map<String, SObjectField>> mapObjName_MapFldName_FldDescribe = new Map<String,Map<String, SObjectField>>();
        Map<String,Map<String,String>> mapFldApiName_FldRealName = new Map<String,Map<String,String>>();

        for(SVMXC__ServiceMax_Config_Data__c ExprRow:lstExprRows)
        {
            if(ExprRow == null || (ExprRow != null && (ExprRow.SVMXC__Object_Name2__c == null || ExprRow.SVMXC__Object_Name2__c == '')))
                continue;
            if(mapObjName_MapFldName_FldDescribe == null || !(mapObjName_MapFldName_FldDescribe.containsKey(ExprRow.SVMXC__Object_Name2__c)))
            {
                SFM_Utils ObjName_util = new SFM_Utils();
                String APIName_Obj = ObjName_util.getOriginalAPIName(ExprRow.SVMXC__Object_Name2__c, allObjs);
                system.debug('API Name of Object Name2: ' + APIName_Obj);
                
                Map<String, SObjectField> mapObjectFields = new Map<String, SObjectField>();
                Map<String,String> mapApiName_RealName_Field = new Map<String,String>();
                
                mapObjectFields = allObjs.get(APIName_Obj).getDescribe().fields.getMap();
                system.debug('Map of object fields: ' + mapObjectFields);
                
                for(String FieldApiName :mapObjectFields.keyset())
                {
                    mapApiName_RealName_Field.put(mapObjectFields.get(FieldApiName).getDescribe().getName(), FieldApiName);
                }
                system.debug('Map of name to field: ' + mapApiName_RealName_Field + ' to check family' + mapApiName_RealName_Field.get('family'));

                mapObjName_MapFldName_FldDescribe.put(ExprRow.SVMXC__Object_Name2__c, mapObjectFields);
                system.debug('Map of name to Map of name to field: ' + mapObjName_MapFldName_FldDescribe);
                mapFldApiName_FldRealName.put(ExprRow.SVMXC__Object_Name2__c, mapApiName_RealName_Field);
                system.debug('Map of object name to its real name: ' + mapObjName_MapFldName_FldDescribe);
            }
        }
        for(SVMXC__ServiceMax_Config_Data__c ExprRow:lstExprRows)
        {
            if(ExprRow.SVMXC__Field_Name__c == 'ServiceMax_NONE' || ExprRow.SVMXC__Field_Name__c == null)
                ExprRow.SVMXC__Field_Name__c = null;
            else
            {
                if(mapObjName_MapFldName_FldDescribe == null || mapFldApiName_FldRealName == null)
                    continue;
                
                Schema.SObjectField targetField = mapObjName_MapFldName_FldDescribe.get(ExprRow.SVMXC__Object_Name2__c).get(mapFldApiName_FldRealName.get(ExprRow.SVMXC__Object_Name2__c).get(ExprRow.SVMXC__Field_Name__c));
                system.debug('target field: ' + targetField);
                if(targetField != null)
                {
                    Schema.DescribeFieldResult targetFieldDesc = targetField.getDescribe();
                    system.debug('target field desc: ' + targetFieldDesc);
                    ExprRow.SVMXC__Display_Type__c = String.valueOf(targetFieldDesc.getType());
                    system.debug('SVMXC__Display_Type__c: ' + ExprRow.SVMXC__Display_Type__c);
                    if(ExprRow.SVMXC__Display_Type__c == 'Reference')
                    {
                        ExprRow.SVMXC__Field_Relationship_Name__c = targetFieldDesc.getRelationshipName();
                        
                        if(targetFieldDesc != NULL && targetFieldDesc.getReferenceTo() != NULL && targetFieldDesc.getReferenceTo().size() > 0)
                        {
                            if(targetFieldDesc.getReferenceTo()[0] == Group.SObjectType)
                                ExprRow.SVMXC__Object_Name__c = 'User';
                            else
                                ExprRow.SVMXC__Object_Name__c = string.valueOf(targetFieldDesc.getReferenceTo()[0]);
                        }
                        
                        if(targetFieldDesc.getReferenceTo()[0] == Account.SObjectType)
                            ExprRow.SVMXC__FKey_Name_Field__c = 'Name';
                        else
                        {
                            Map<String,Schema.SObjectField> R = targetFieldDesc.getReferenceTo()[0].getDescribe().fields.getMap();
                            for(String fieldKey1 : R.keySet())
                            {
                                Schema.SObjectField fsObj1 = R.get(fieldKey1);
                                Schema.DescribeFieldResult f1 = fsObj1.getDescribe();
                                if(f1.isNameField())
                                {
                                    ExprRow.SVMXC__FKey_Name_Field__c = f1.getName();
                                    break;
                                }
                            }
                        }   
                    }
                }//if statement of targetField ends here
            }//else ends here
        }//for statement ends here
        system.debug('list at the end: ' + lstExprRows);
        return lstExprRows;
    }
    
    //Expression validation is done here
    public SVMXC.SFM_validateExpression ValidateExp = new SVMXC.SFM_validateExpression();
    public SFM_WrapperDef.SFM_Response SFMResponse = new SFM_WrapperDef.SFM_Response();
    public Boolean validateExpression_DiffObjects(String AdvanceExpressionStr, List<SVMXC__ServiceMax_Config_Data__c> lstExpressionRows_WithObjName)
    {
        RecordType ExpressionHeader_Rtype = [select Id from RecordType where Name = 'SVMX Rule'and SobjectType = 'SVMXC__ServiceMax_Processes__c' Limit 1]; //SDL-SVMX-FLS-NOT-ENFORCED-META-DATA
        RecordType ExpressionsDetail_Rtype = [select Id from RecordType where Name = 'Expressions'and SobjectType = 'SVMXC__ServiceMax_Config_Data__c' Limit 1]; //SDL-SVMX-FLS-NOT-ENFORCED-META-DATA
        
        if(AdvanceExpressionStr != null && AdvanceExpressionStr.length() > 0)
        {
            //Advance expression validation happens here
            List<SFM_WrapperDef.SFM_Expression> LstSFM_Exp1 = new List<SFM_WrapperDef.SFM_Expression>();
            
            SVMXC__ServiceMax_Processes__c Dummy_ProcessObj1 = new SVMXC__ServiceMax_Processes__c();
            Dummy_ProcessObj1.SVMXC__Name__c = 'DummyProcess001(DO NOT USE)';
            Dummy_ProcessObj1.SVMXC__SettingId__c = 'DummyProcess001(DO NOT USE)';
            Dummy_ProcessObj1.SVMXC__ProcessId__c = 'HeaderExpression001(DO NOT USE)';
            Dummy_ProcessObj1.SVMXC__Description__c = 'Sample desc';
            Dummy_ProcessObj1.SVMXC__Advance_Expression__c = AdvanceExpressionStr;
            Dummy_ProcessObj1.RecordTypeId = ExpressionHeader_Rtype.Id;
            Dummy_ProcessObj1.SVMXC__Rule_Type__c = 'Named Expression';
            Dummy_ProcessObj1.SVMXC__Source_Object_Name__c = 'SVMXC__ServiceMax_Processes__c';
        
            List<SVMXC__ServiceMax_Config_Data__c> lstDummyConfigData = new List<SVMXC__ServiceMax_Config_Data__c>();
            for(SVMXC__ServiceMax_Config_Data__c expressionRow :lstExpressionRows_WithObjName)
            {
                lstDummyConfigData.add(new SVMXC__ServiceMax_Config_Data__c(RecordTypeId = ExpressionsDetail_Rtype.Id, SVMXC__Sequence__c = expressionRow.SVMXC__Sequence__c, SVMXC__Field_Name__c = 'SVMXC__Name__c', SVMXC__Operator__c = 'eq', SVMXC__Operand__c = 'DummyProcess001(Do Not use)', SVMXC__Display_Type__c = 'String', SVMXC__Expression_Type__c = 'EXP_Named'));
            }
            SFM_WrapperDef.SFM_Expression instanceSFM_Exp1 = new SFM_WrapperDef.SFM_Expression(Dummy_ProcessObj1, lstDummyConfigData);
            LstSFM_Exp1.add(instanceSFM_Exp1);
        
            //Create the request
            SFM_WrapperDef.SFM_Request_Expression oRequest = new SFM_WrapperDef.SFM_Request_Expression(LstSFM_Exp1);
            //Response
            SFMResponse = ValidateExp.SFM_validateExpression(oRequest);
    
            system.debug('0. Advance expression validation response'+SFMResponse);
    
            if( SFMResponse.success != null && !(Boolean.valueOf(SFMResponse.success)))
                return false;
        }
        system.debug('1. Advance Expression validation successfull');
        
        //Map to store ObjectName, related lstExpressions
        Map<String, List<SVMXC__ServiceMax_Config_Data__c>> mapObjName_LstExpressions = new Map<String, List<SVMXC__ServiceMax_Config_Data__c>>();
        
        //Loop through the expression records and build the above map
        for(SVMXC__ServiceMax_Config_Data__c exprRow :lstExpressionRows_WithObjName)
        {
            List<SVMXC__ServiceMax_Config_Data__c> tempLstExpressions = new List<SVMXC__ServiceMax_Config_Data__c>();
            if(exprRow.SVMXC__Object_Name2__c != null && mapObjName_LstExpressions.containsKey(exprRow.SVMXC__Object_Name2__c))
                tempLstExpressions.addAll(mapObjName_LstExpressions.get(exprRow.SVMXC__Object_Name2__c));
            tempLstExpressions.add(exprRow);
            mapObjName_LstExpressions.put(exprRow.SVMXC__Object_Name2__c, tempLstExpressions);
        }
        
        //List of SFM expressions to validate
        List<SFM_WrapperDef.SFM_Expression> LstSFM_Exp = new List<SFM_WrapperDef.SFM_Expression>();
    
        //Add the ObjectNames to the List
        for(String Expression_ObjectName :mapObjName_LstExpressions.keyset())
        {
            SVMXC__ServiceMax_Processes__c Dummy_ProcessObj = new SVMXC__ServiceMax_Processes__c();
            Dummy_ProcessObj.SVMXC__Name__c = 'DummyProcess001(DO NOT USE)';
            Dummy_ProcessObj.SVMXC__SettingId__c = 'DummyProcess001(DO NOT USE)';
            Dummy_ProcessObj.SVMXC__ProcessId__c = 'HeaderExpression001(DO NOT USE)';
            Dummy_ProcessObj.SVMXC__Description__c = 'Sample desc';
            Dummy_ProcessObj.SVMXC__Advance_Expression__c = null; 
            //Dummy_ProcessObj.SVMXC__Advance_Expression__c = ForwardShipment_Header.SVMXC__Advance_Expression__c; //required only in case of expressions present only for single object
            Dummy_ProcessObj.RecordTypeId = ExpressionHeader_Rtype.Id;
            Dummy_ProcessObj.SVMXC__Rule_Type__c = 'Named Expression';
            Dummy_ProcessObj.SVMXC__Source_Object_Name__c = Expression_ObjectName;
    
            SFM_WrapperDef.SFM_Expression instanceSFM_Exp = new SFM_WrapperDef.SFM_Expression(Dummy_ProcessObj,mapObjName_LstExpressions.get(Expression_ObjectName));
            LstSFM_Exp.add(instanceSFM_Exp);
        }
        //Create the request
        SFM_WrapperDef.SFM_Request_Expression oRequest1 = new SFM_WrapperDef.SFM_Request_Expression(LstSFM_Exp);
        //Response
        SFMResponse = ValidateExp.SFM_validateExpression(oRequest1);
        
        system.debug('2. Expression validation complete'+SFMResponse);
        
        if( SFMResponse.success != null && Boolean.valueOf(SFMResponse.success))
            return true;
        else
            return false;
    }

    //Expresssion - Build where clause for master detail object, query happens on line object
    public String BuildWhereClause_MasterDetailObjects(String ObjectName_BeingQueried, Map<String,String> mapObjName_RelationShipName, String AdvanceExpression, List<SVMXC__ServiceMax_Config_Data__c> lstExpressions, Map<String,Schema.Displaytype> fieldNameToDisplayType, Map<String,Schema.SObjectType>  mapFieldApiObjName, Map<String,String>  mapFieldRelName)
    {
        if(lstExpressions == null || lstExpressions.size() == 0)
            return null;
        
        SFM_ValidateExpression ValidateExp = new SFM_ValidateExpression();
        ValidateExp.mapFieldDispType = fieldNameToDisplayType;
        ValidateExp.mapFieldApiObjName = mapFieldApiObjName;
        ValidateExp.mapFieldRelName = mapFieldRelName;
        
        String ResultantWhereClause = '';
        map<integer, string> mapSeqToWhereClause = new map<integer, string>();
        
        system.debug('List of Expressions: ' + lstExpressions + ' size: ' + lstExpressions.size());
        
        for(SVMXC__ServiceMax_Config_Data__c expConfData : lstExpressions)
        {
            string advanceOptn = '';
            string tempWhereClause = '';
            List<SVMXC__ServiceMax_Config_Data__c> lstTempExp = new List<SVMXC__ServiceMax_Config_Data__c>();
            lstTempExp.add(expConfData);
            
            tempWhereClause = ValidateExp.getCriteria(expConfData.SVMXC__Object_Name2__c, advanceOptn, lstTempExp);
            
            system.debug('Where Clause for: ' + expConfData.SVMXC__Sequence__c + ' is: ' + tempWhereClause);
            
            if(expConfData.SVMXC__Object_Name2__c != ObjectName_BeingQueried)
            {
                tempWhereClause = mapObjName_RelationShipName.get(expConfData.SVMXC__Object_Name2__c) + '.' + tempWhereClause;
                tempWhereClause = tempWhereClause.replace('__r. ','__r.');
            }
            mapSeqToWhereClause.put(integer.valueOf(expConfData.SVMXC__Sequence__c), tempWhereClause);
        }
        system.debug('Map Seq to Where Clause: ' + mapSeqToWhereClause + ' and size is: ' + mapSeqToWhereClause.size());
        
        if(AdvanceExpression == null || AdvanceExpression == '' || AdvanceExpression.length() == 0)
        {
            if(mapSeqToWhereClause.size() > 1)
            {
                for(integer i : mapSeqToWhereClause.keySet())
                {
                    if(i == 1)
                        ResultantWhereClause = mapSeqToWhereClause.get(i);
                    else
                        ResultantWhereClause += ' AND ' + mapSeqToWhereClause.get(i);
                }
            }
            else
            {
                ResultantWhereClause = mapSeqToWhereClause.get(1);
            }
        }
        else
        {
            string criteriaNew = AdvanceExpression.toUpperCase();
            for(integer i = 1; i <= mapSeqToWhereClause.size(); i ++)
            {
                criteriaNew = criteriaNew.replace(string.valueOf(i), ' '+mapSeqToWhereClause.get(i)+' ');
            }
            ResultantWhereClause = criteriaNew;
        }
        system.debug('Resultant Where Clause: ' + ResultantWhereClause);
        
        return ResultantWhereClause;
    }
    //This method is used by process receipt to know whether serial no available for deopt.
    public SVMXC.INTF_WebServicesDef.INTF_SFMResponse getAvailableStockSerial(SVMXC.INTF_WebServicesDef.INTF_SFMRequest request)
    {
        
        system.debug('request'+request); 
        String strdepot = '';
        String strProcessId = '';
        list<String> productIds = new list<String>();
        SVMXC.INTF_WebServicesDef.INTF_SFMResponse response = new SVMXC.INTF_WebServicesDef.INTF_SFMResponse();
        list<SVMXC__Site__c> lstDepotLocation = new list<SVMXC__Site__c>();
        map<String,SVMXC__Site__c> mapDepotChild = new map<String,SVMXC__Site__c>();
        map<String,SVMXC__Product_Stock__c> mapProductStock = new map<String,SVMXC__Product_Stock__c>();
        map<String,SVMXC__Product_Serial__c> mapStockSerial = new map<String,SVMXC__Product_Serial__c>();
        list<SVMXC.INTF_WebServicesDef.SVMXMap> lstSVMXMap = new list<SVMXC.INTF_WebServicesDef.SVMXMap>(); 
        lstSVMXMap = request.valueMap;
        
        if(lstSVMXMap != null && lstSVMXMap.size() > 0)
        {
            for(Integer i = 0;i<lstSVMXMap.size();i++)
            {
                if(lstSVMXMap[i].key.touppercase() == 'DEPOTNAME' && lstSVMXMap[i].value != null)
                    strdepot = lstSVMXMap[i].value;
                else if(lstSVMXMap[i].key.touppercase() == 'PRODUCTID' && lstSVMXMap[i].values != null)
                    productIds = lstSVMXMap[i].values;  
                else if(lstSVMXMap[i].key.touppercase() == 'SVMX_PROCESSID' && lstSVMXMap[i].value != null)
                    strProcessId = lstSVMXMap[i].value;  
            }
        }
        system.debug('strProcessId'+strProcessId);
        system.debug('strdepot'+strdepot);
 //       system.debug('productIds'+productIds.size()+productIds);
        
        try
        {
            lstDepotLocation = [select id,Name,RecordTypeId From SVMXC__Site__c where id =: strdepot and RecordType.Name =: 'Depot'];
            if(lstDepotLocation.size() > 0)
            {
                mapDepotChild.putAll([select id,Name,RecordTypeId,SVMXC__Parent__c,SVMXC__IsReceiving_Location__c, SVMXC__Stocking_Location__c from SVMXC__Site__c where SVMXC__Parent__c =: lstDepotLocation[0].id and RecordType.Name = 'Depot Child' and SVMXC__Stocking_Location__c = true]);
                if(mapDepotChild.size() > 0)
                {
                    set<String> setLocation = new set<String>();
                    setLocation = mapDepotChild.keyset();
                    setLocation.remove(null);
                    map<String, Schema.SObjectField> mapProductStockDescribe = new map<String, Schema.SObjectField>();
                    String strfld = '';
                    mapProductStockDescribe = Schema.SObjectType.SVMXC__Product_Stock__c.fields.getMap();
                    //Commented as part of story BAC-3591 and added COMM_Utils_V2
                    //SVMXC.COMM_Utils commutils = new SVMXC.COMM_Utils();
                    SVMXC.COMM_Utils_V2 commutils = new SVMXC.COMM_Utils_V2();
                    list<String> lstPSFld = new list<String>();
                    if(mapProductStockDescribe.size() > 0)
                        lstPSFld = commutils.SVMX_getFieldList(mapProductStockDescribe,true);
                    if(lstPSFld.size() > 0)
                        strfld = commutils.SVMX_getFieldNamesFromList(lstPSFld);
                     String strQuery = 'Select '+strfld+ ' From  SVMXC__Product_Stock__c Where SVMXC__Status__c = \'Available\' and SVMXC__Product__c IN : productIds and SVMXC__Location__c IN : setLocation';
                    system.debug('strQuery'+strQuery);
                    mapProductStock.putAll((list<SVMXC__Product_Stock__c>)Database.query(strQuery));
                    if(mapProductStock.size() > 0)
                    {
                        set<String> setPSId = new set<String>();
                        setPSId = mapProductStock.keyset();
                        setPSId.remove(null);
                        String query = 'Select SystemModstamp, SVMXC__Product__c, SVMXC__Product_Stock__c, SVMXC__Active__c, Name, Id From SVMXC__Product_Serial__c where SVMXC__Product_Stock__c IN : setPSId';
                        mapStockSerial.putall((list<SVMXC__Product_Serial__c>)Database.query(query));
                    }    
                    system.debug('mapStockSerial'+mapStockSerial);
                    if(mapStockSerial.size() > 0)
                    {
                        list<String> lstPIDSN = new list<String>();
                        for(String str : mapStockSerial.keyset())
                        {
                            if(mapStockSerial.get(str).SVMXC__Product__c != null)
                            {
                                lstPIDSN.add(mapStockSerial.get(str).SVMXC__Product__c + '_' + mapStockSerial.get(str).Name);
                            }   
                        }
                        if(lstPIDSN.size () > 0)
                        {
                            response.values = lstPIDSN;
                            response.success = true;
                        }   
                    }
                }
                else
                {
                    throw new SVMXException('Given depot does not have receiving location');
                }
            }
            else
            {
                throw new SVMXException('Given Location is not depot');
            }
        }
        catch(Exception ex)
        {
            response.success = false;
            response.message = ex.getMessage();
        }
        system.debug('response'+response);        
            return response;    
    }
    public SVMXC.INTF_WebServicesDef.INTF_SFMResponse PartsOrderClosure(SVMXC.INTF_WebServicesDef.INTF_SFMRequest request)
    {
        Boolean doclosure = true;
        SVMXC.INTF_WebServicesDef.INTF_SFMResponse response = new SVMXC.INTF_WebServicesDef.INTF_SFMResponse();
        response.success = true;
        response.message = '';
        SVMXC.INTF_WebServicesDef.APL_Order aplOrder = new SVMXC.INTF_WebServicesDef.APL_Order();
        aplOrder = request.aplOrder;
        SVMXC.APL_Utils sourceUpdateUtil = new SVMXC.APL_Utils();
        list<SVMXC.INTF_WebServicesDef.SVMXMap> lstSVMXMap = new list<SVMXC.INTF_WebServicesDef.SVMXMap>();
        
        SVMXC__ServiceMax_Processes__c objSVMXProcess = new SVMXC__ServiceMax_Processes__c();
        SVMXC__RMA_Shipment_Order__c objPartsOrder = new SVMXC__RMA_Shipment_Order__c();
        String strProcessId = '';
        String strRecordId;
        String strProcessType = '';
        lstSVMXMap = request.valueMap;
        if(lstSVMXMap.size() > 0)
        {
            for(Integer i = 0;i<lstSVMXMap.size();i++)
            {
                if(lstSVMXMap[i].key.touppercase() == 'SVMX_RECORDID')
                    strRecordId = lstSVMXMap[i].value;
                else if(lstSVMXMap[i].key.toUppercase() == 'SVMX_PROCESSTYPE')
                    strProcessType = lstSVMXMap[i].value;
                else if(lstSVMXMap[i].key.toUppercase() == 'SVMX_PROCESSID')
                    strProcessId = lstSVMXMap[i].value;
            }
        }
        map<String,Schema.SObjectField> mapTempH = Schema.SObjectType.SVMXC__RMA_Shipment_Order__c.fields.getMap();
        map<String,Schema.SObjectField> mapPOFldDesc = new map<String,Schema.SObjectField>();
        if(strProcessId != null && strProcessId.length() > 0)
        {
            objSVMXProcess = [select id,SVMXC__ProcessID__c from SVMXC__ServiceMax_Processes__c where SVMXC__ProcessID__c =: strProcessId or id =: strProcessId]; //SDL-SVMX-FLS-NOT-ENFORCED-META-DATA
        }
        if(strRecordId != null && strRecordId.length() > 0)
        {
            //Commented as part of story BAC-3591 and added COMM_Utils_V2
            //SVMXC.COMM_Utils utils = new SVMXC.COMM_Utils();
            SVMXC.COMM_Utils_V2 utils = new SVMXC.COMM_Utils_V2();
            List<String> fieldList = utils.SVMX_getFieldList(mapTempH,true); 
            String fieldNames = utils.SVMX_getFieldNamesFromList(fieldList);
            String Query = 'select '+fieldNames+' from SVMXC__RMA_Shipment_Order__c where id =: strRecordId';
            system.debug('Query'+Query);
            objPartsOrder = database.query(Query);
            system.debug('objPartsOrder'+objPartsOrder);
        }   
        list<SVMXC__RMA_Shipment_Line__c> POlines = new list<SVMXC__RMA_Shipment_Line__c>();
        POlines = [select id,SVMXC__Received__c, SVMXC__Delivered__c, SVMXC__Picked__c, SVMXC__Shipped__c from SVMXC__RMA_Shipment_Line__c where SVMXC__RMA_Shipment_Order__c =: objPartsOrder.id];
        //If all lines are Received/Delivered/Picked/Shiped then do header updates..
        Boolean doHeaderUpdate = true;
        Boolean doLineHeaderClosoure = true;
        list<SVMXC__ServiceMax_Config_Data__c> lstConfigDataForSourceUpdateHeader = new list<SVMXC__ServiceMax_Config_Data__c>();
        if(POlines.size() > 0)
        {
            if(mapTempH.size() > 0)
            {
                for(String s : mapTempH.keyset())
                {
                    mapPOFldDesc.put(mapTempH.get(s).getDescribe().getName(),mapTempH.get(s));
                }
            }
            if(strProcessType == 'PROCESSRECEIPT')
            {
                for(SVMXC__RMA_Shipment_Line__c rsl : POlines)
                {
                    if(rsl.SVMXC__Received__c == false)
                        doHeaderUpdate = false;
                }
                if(doHeaderUpdate && objSVMXProcess != null && objSVMXProcess.id != null)
                    lstConfigDataForSourceUpdateHeader = [select id, RecordTypeId, SVMXC__Dispatch_Process__c, SVMXC__Target_Field_Name__c, SVMXC__Action__c, SVMXC__Display_Value__c, SVMXC__Configuration_Type__c from SVMXC__ServiceMax_Config_Data__c where RecordType.Name =: 'Field Mapping' and SVMXC__Configuration_Type__c = 'HEADER_UPD_ON_RECEIPT' and SVMXC__Dispatch_Process__c =: objSVMXProcess.id]; //SDL-SVMX-FLS-NOT-ENFORCED-META-DATA
            }
            else if(strProcessType == 'DELIVERYONRECEIPT')
            {
                for(SVMXC__RMA_Shipment_Line__c rsl : POlines)
                {
                    if(rsl.SVMXC__Delivered__c == false)
                    {
                        doHeaderUpdate = false;
                        doLineHeaderClosoure = false;
                    }   
                }
                if(doHeaderUpdate && objSVMXProcess != null && objSVMXProcess.id != null)
                    lstConfigDataForSourceUpdateHeader = [select id, RecordTypeId, SVMXC__Dispatch_Process__c, SVMXC__Target_Field_Name__c, SVMXC__Action__c, SVMXC__Display_Value__c, SVMXC__Configuration_Type__c from SVMXC__ServiceMax_Config_Data__c where RecordType.Name =: 'Field Mapping' and SVMXC__Configuration_Type__c = 'HEADER_UPD_ON_DELIVERY' and SVMXC__Dispatch_Process__c =: objSVMXProcess.id]; //SDL-SVMX-FLS-NOT-ENFORCED-META-DATA
            }
            else if(strProcessType == 'PICKNMOVE')
            {
                for(SVMXC__RMA_Shipment_Line__c rsl : POlines)
                {
                    if(rsl.SVMXC__Picked__c == false)
                        doHeaderUpdate = false;
                }
                if(doHeaderUpdate && objSVMXProcess != null && objSVMXProcess.id != null)
                    lstConfigDataForSourceUpdateHeader = [select id, RecordTypeId, SVMXC__Dispatch_Process__c, SVMXC__Target_Field_Name__c, SVMXC__Action__c, SVMXC__Display_Value__c, SVMXC__Configuration_Type__c from SVMXC__ServiceMax_Config_Data__c where RecordType.Name =: 'Field Mapping' and SVMXC__Configuration_Type__c = 'HEADER_UPD_ON_PICKING' and SVMXC__Dispatch_Process__c =: objSVMXProcess.id]; //SDL-SVMX-FLS-NOT-ENFORCED-META-DATA
            }
            else if(strProcessType == 'SHIPCONFIRM')
            {
                for(SVMXC__RMA_Shipment_Line__c rsl : POlines)
                {
                    if(rsl.SVMXC__Shipped__c == false)
                    {
                        doHeaderUpdate = false;
                        doLineHeaderClosoure = false;
                    }   
                }
                if(doHeaderUpdate && objSVMXProcess != null && objSVMXProcess.id != null)
                    lstConfigDataForSourceUpdateHeader = [select id, RecordTypeId, SVMXC__Dispatch_Process__c, SVMXC__Target_Field_Name__c, SVMXC__Action__c, SVMXC__Display_Value__c, SVMXC__Configuration_Type__c from SVMXC__ServiceMax_Config_Data__c where RecordType.Name =: 'Field Mapping' and SVMXC__Configuration_Type__c = 'HEADER_UPD_ON_SHIP' and SVMXC__Dispatch_Process__c =: objSVMXProcess.id]; //SDL-SVMX-FLS-NOT-ENFORCED-META-DATA
            }
            if(doHeaderUpdate)
            {
                if(lstConfigDataForSourceUpdateHeader.size() > 0 && objPartsOrder != null && mapPOFldDesc.size() > 0)//if Definition is Available then do the source update
                {
                    system.debug('lstConfigDataForSourceUpdateHeader'+lstConfigDataForSourceUpdateHeader);
                    list<SVMXC__RMA_Shipment_Order__c> lstTempList = new list<SVMXC__RMA_Shipment_Order__c>();
                    lstTempList.add(objPartsOrder);
                    list<SVMXC__RMA_Shipment_Order__c> lstOutput = sourceUpdateUtil.DoSourceUpdate(lstTempList,lstConfigDataForSourceUpdateHeader,mapPOFldDesc);
                    system.debug('lstOutput'+lstOutput);
                    if(lstOutput.size() > 0)
                        objPartsOrder = lstOutput[0];
                }
            }
        }    
        //Do Line and Header Closure
        if(doLineHeaderClosoure)//Setting needs to be added..
        {
            String strRMALineStatus = 'Completed';
            String strShipmentLineStatus = 'Completed';
            String strRMAHeaderStatus = 'Completed';
            String strShipmentHeaderStatus = 'Completed';
            Boolean allowClosureOnDelivery = true;
            Boolean allowClosureOnShipping = true;
            list<String> setLstForAPL002 = new list<String>();
            list<String> setLstForAPL003 = new list<String>();
            setLstForAPL002.add('SET001');
            setLstForAPL003.add('SET001');
            setLstForAPL002.add('SET002');
            setLstForAPL003.add('SET002');
            setLstForAPL002.add('SET007');
            setLstForAPL003.add('SET007');
            SVMXC.COMM_Utils_ManageSettings commSettings = new SVMXC.COMM_Utils_ManageSettings();
            map<String, String> svmxSettingListforAPL002 = commSettings.SVMX_getSettingList('APL002', setLstForAPL002);
            map<String, String> svmxSettingListforAPL003 = commSettings.SVMX_getSettingList('APL003', setLstForAPL003);
            if(svmxSettingListforAPL002.containskey('SET001'))
                strRMAHeaderStatus = svmxSettingListforAPL002.get('SET001');
            if(svmxSettingListforAPL003.containskey('SET001'))
                strShipmentHeaderStatus = svmxSettingListforAPL003.get('SET001');
            if(svmxSettingListforAPL002.containskey('SET002'))
                strRMALineStatus = svmxSettingListforAPL002.get('SET002');
            if(svmxSettingListforAPL003.containskey('SET002'))
                strShipmentLineStatus = svmxSettingListforAPL003.get('SET002');
            if(svmxSettingListforAPL002.containskey('SET007'))
                allowClosureOnDelivery = Boolean.valueof(svmxSettingListforAPL002.get('SET007'));
            if(svmxSettingListforAPL003.containskey('SET007'))
                allowClosureOnShipping = Boolean.valueof(svmxSettingListforAPL003.get('SET007'));   
                
            
            if(strProcessType == 'DELIVERYONRECEIPT' && allowClosureOnDelivery)
            {
                for(SVMXC__RMA_Shipment_Line__c rsl : POlines)
                {
                    rsl.SVMXC__Line_Status__c =  strRMALineStatus;
                }
                objPartsOrder.SVMXC__Order_Status__c = strRMAHeaderStatus;
                objPartsOrder.SVMXC__Closed_On__c = system.now();
                objPartsOrder.SVMXC__Closed_By__c = userinfo.getUserId();
            }
            else if(strProcessType == 'SHIPCONFIRM' && allowClosureOnShipping)
            {
                for(SVMXC__RMA_Shipment_Line__c rsl : POlines)
                {
                    rsl.SVMXC__Line_Status__c =  strShipmentLineStatus;
                }
                objPartsOrder.SVMXC__Order_Status__c = strShipmentHeaderStatus;
                objPartsOrder.SVMXC__Closed_On__c = system.now();
                objPartsOrder.SVMXC__Closed_By__c = userinfo.getUserId();
            }
        }
        Savepoint sp;
        sp = Database.setSavepoint();
        //Update line 
        try
        {
            if(POlines.size() > 0) {
                if( COMM_SecurityUtils.getInstance().verifyFieldAccess( POlines, COMM_SecurityUtils.Access.Updateable ) ) {
                    update POlines; //SDL-SVMX-CREATE-UPDATE-FLS-ENFORCED
                } else {
                    response.success = false;
                    response.message += System.Label.COMM001_TAG142;
                    Database.rollback(sp);
                    return response;
                }
            }
                
        }
        catch(System.DmlException e)
        {
            response.success = false;
            response.message += e.getDmlMessage(0);
            Database.rollback(sp);
            system.debug('response: '+response);
            return response;
        }
        try
        {
            if( objPartsOrder != null ) {
                
                if( COMM_SecurityUtils.getInstance().verifyFieldAccess( objPartsOrder, COMM_SecurityUtils.Access.Updateable ) ) {
                    update objPartsOrder; //SDL-SVMX-CREATE-UPDATE-FLS-ENFORCED
                } else {
                    response.success = false;
                    response.message += System.Label.COMM001_TAG142;
                    Database.rollback(sp);
                }    
            }            
        }
        catch(System.DmlException e)
        {
            response.message += e.getDmlMessage(0);
            response.success = false;
            Database.rollback(sp);
            return response;
        }    
        return response;
    }
    public SVMXC.INTF_WebServicesDef.INTF_SFMResponse getFieldsToQuery(SVMXC.INTF_WebServicesDef.INTF_SFMRequest request)
    {
        SVMXC.INTF_WebServicesDef.INTF_SFMResponse response = new SVMXC.INTF_WebServicesDef.INTF_SFMResponse();
        response.success = false;
        list<SVMXC.INTF_WebServicesDef.SVMXMap> lstSVMXMap = new list<SVMXC.INTF_WebServicesDef.SVMXMap>();
        list<SVMXC__ServiceMax_Config_Data__c> lstConfigData = new list<SVMXC__ServiceMax_Config_Data__c>();
        lstSVMXMap = request.valueMap;
        String strRecordId = '';
        String strProcessType = '';
        if(lstSVMXMap.size() > 0)
        {
            for(Integer i = 0;i<lstSVMXMap.size();i++)
            {
                if(lstSVMXMap[i].key.touppercase() == 'SVMX_RECORDID')
                    strRecordId = lstSVMXMap[i].value;
                else if(lstSVMXMap[i].key.touppercase() == 'SVMX_PROCESSTYPE')
                    strProcessType = lstSVMXMap[i].value;       
            }
        }
        if(strProcessType.toUpperCase() == 'PROCESSRECEIPT')
        {
            lstConfigData = [select Id, SVMXC__Dispatch_Process__c, SVMXC__Target_Field_Name__c, SVMXC__Configuration_Type__c from SVMXC__ServiceMax_Config_Data__c where SVMXC__Dispatch_Process__c =:strRecordId and  SVMXC__Configuration_Type__c = 'LINE_UPD_ON_RECEIPT']; //SDL-SVMX-FLS-NOT-ENFORCED-META-DATA
        }
        else if(strProcessType.toUpperCase() == 'DELIVERYONRECEIPT')
        {
            lstConfigData = [select Id, SVMXC__Dispatch_Process__c, SVMXC__Target_Field_Name__c, SVMXC__Configuration_Type__c from SVMXC__ServiceMax_Config_Data__c where SVMXC__Dispatch_Process__c =:strRecordId and  SVMXC__Configuration_Type__c = 'LINE_UPD_ON_DELIVERY']; //SDL-SVMX-FLS-NOT-ENFORCED-META-DATA
        }
        else if(strProcessType.toUpperCase() == 'PICKNMOVE')
        {
            lstConfigData = [select Id, SVMXC__Dispatch_Process__c, SVMXC__Target_Field_Name__c, SVMXC__Configuration_Type__c from SVMXC__ServiceMax_Config_Data__c where SVMXC__Dispatch_Process__c =:strRecordId and  SVMXC__Configuration_Type__c = 'LINE_UPD_ON_PICKING']; //SDL-SVMX-FLS-NOT-ENFORCED-META-DATA
        }
        else if(strProcessType.toUpperCase() == 'SHIPCONFIRM')
        {
            lstConfigData = [select Id, SVMXC__Dispatch_Process__c, SVMXC__Target_Field_Name__c, SVMXC__Configuration_Type__c from SVMXC__ServiceMax_Config_Data__c where SVMXC__Dispatch_Process__c =:strRecordId and  SVMXC__Configuration_Type__c = 'LINE_UPD_ON_SHIP']; //SDL-SVMX-FLS-NOT-ENFORCED-META-DATA
        }
        if(lstConfigData.size() > 0)
        {
            SVMXC.INTF_WebServicesDef.SVMXMap svmxmap = new SVMXC.INTF_WebServicesDef.SVMXMap();
            svmxmap.key = 'FIELDLIST';
            for(SVMXC__ServiceMax_Config_Data__c configData : lstConfigData)
            {
                if(configData.SVMXC__Target_Field_Name__c != null)
                    svmxmap.values.add(configData.SVMXC__Target_Field_Name__c);
            }
            response.success = true;
            response.valueMap.add(svmxmap);
        }
        return response;
    }
}