public with sharing class SFM_ValidateExpression 
{
    //Global Variables
    public Set<String> setSVMXLiterals = new Set<String> {'SVMX.CURRENTRECORD.', 'SVMX.CURRENTRECORDHEADER.', 'SVMX.USERTRUNK'};
    public Map<String,Schema.Displaytype>  mapFieldDispType = new Map<String,Schema.Displaytype>();
    public Map<String,String>  FieldApiLable = new Map<String,String>();
    //public Map<String, Schema.SObjectType> Allobjs = new Map<String, Schema.SObjectType>(); //Commented to avoid view state error BAC-4275
    //public Map<String, Schema.SObjectField> FieldMap = new Map<String, Schema.SObjectField>(); //Commented to avoid view state error BAC-4275
    public List<SFM_WrapperDef.SFM_StringMap> stringMap = new List<SFM_WrapperDef.SFM_StringMap>();
    public Map<String,Schema.SObjectType>  mapFieldApiObjName = new Map<String,Schema.SObjectType>();
    public Map<String,String>  mapFieldRelName = new Map<String,String>();
    public Boolean response_success;
    public String response_message;
    public String response_tagId;
    public Boolean s = false;
    public String msg;
    public String tid;
    boolean isValidCri;
  
    public String strAdvanceOption;
    SVMXC.SFM_Utils utils = new SVMXC.SFM_Utils();
  
    //Constructor
    public SFM_validateExpression()
    {
        //Commented to avoid view state error BAC-4275
        //Allobjs = Schema.getGlobalDescribe();
    }
    
    public SFM_WrapperDef.SFM_Response SFM_validateExpression(SFM_WrapperDef.SFM_Request_Expression ExpReq)
    {

        //Added for BAC-4275
        Map<String, Schema.SObjectField> FieldMap = new Map<String, Schema.SObjectField>();
        Map<String, Schema.SObjectType> Allobjs = new Map<String, Schema.SObjectType>();
        Allobjs = Schema.getGlobalDescribe();
        //End Added for BAC-4275
 
        String cWhereClause = '';
        String ObjectName = '';
        String AdvanceOption = '';
        String ObjectNameAPI='';

        SVMX_Debug  log = new SVMX_Debug();
        List<String> resultIds=new List<String>();
        List<SFM_WrapperDef.SFM_Expression> LstSFM_Expressions = ExpReq.expressions;
        List<SVMXC__ServiceMax_Processes__c> LstSFM_Process = new List<SVMXC__ServiceMax_Processes__c>();
        List<SVMXC__ServiceMax_Config_Data__c> LstSFM_ConfigData = new List<SVMXC__ServiceMax_Config_Data__c>();
        try
        {

            for(SFM_WrapperDef.SFM_Expression Expression: LstSFM_Expressions)
            {
                try{
                    Expression.namedExpression.SVMXC__Advance_Expression__c = Expression.namedExpression.SVMXC__Advance_Expression__c;
                }catch(exception ex){}
                
                ObjectName = Expression.namedExpression.SVMXC__Source_Object_Name__c;
                system.debug('Objectname'+ ObjectName);
                AdvanceOption = Expression.namedExpression.SVMXC__Advance_Expression__c;
                system.debug('AdvanceOption'+ AdvanceOption + '; ' + Expression.namedExpression.SVMXC__Advance_Expression__c);
                
                LstSFM_ConfigData = Expression.expressionDetails;
                system.debug('LstSFM_ConfigData'+ LstSFM_ConfigData);

                ObjectNameAPI = utils.getOriginalAPIName(ObjectName,Allobjs);
                system.debug('Objectname1'+ ObjectNameAPI);
                if(Allobjs.containskey(ObjectNameAPI))
                {
                    FieldMap = Allobjs.get(ObjectNameAPI).getDescribe().fields.getMap();
                    system.debug('FieldMap'+FieldMap.size());
                    if(FieldMap.size() > 0)
                    {
                        for(String s :FieldMap.keyset())
                        {
                            Schema.DescribeFieldResult F = FieldMap.get(s).getDescribe();
                            FieldApiLable.put(F.getName(),F.getLabel());                    
                            mapFieldDispType.put(F.getName(),F.getType());
                            if(F.getType() == Schema.DisplayType.REFERENCE)
                            {
                                mapFieldApiObjName.put(F.getName(),F.getReferenceTo()[0]);

                                mapFieldRelName.put(F.getName(),F.getRelationshipName());
                            }


                        }
                    }
                }
                String IsError = getCriteria(ObjectName,AdvanceOption,LstSFM_ConfigData);
                system.debug('IsError'+IsError);
                if(IsError == 'ERROR')
                {
                    response_success = false;
                    response_message=system.Label.SFM001_TAG180;//'Invalid Expression';
                }
                else
                {

                    response_success = true;
                    response_message=IsError;
                }

            }
          
        }
        catch (Exception ex){
            log.setlog('ERROR', ex.getmessage());
            response_success = false;
            response_message = ex.getmessage();
        }
        log.logout();
        log.print();
        log.getlog();
        SFM_WrapperDef.SFM_Response oResponse=new SFM_WrapperDef.SFM_Response();//(s,msg,tid,stringMap,log.getlog(),resultIds);
        oResponse.logMsg = log.getlog();
        oResponse.success = response_success;
        oResponse.message = response_message;
        oResponse.stringMap = stringMap;
        oResponse.resultIds = resultIds;
        return oResponse;

    }

    public string getCriteria(String ObjectName,String AdvanceOption,List<SVMXC__ServiceMax_Config_Data__c> lstExpressions)
    {
        system.debug('Entered getCriteria');
        system.debug('Opt'+AdvanceOption);
        boolean isAdvanceOption = true;
        string strCriteria = '';
        if (!(lstExpressions.size() > 0))
        {   
            return '';
        }
        else
        {
            for(SVMXC__ServiceMax_Config_Data__c objCgfDta : lstExpressions)
            {
                //to save literals in caps
                if(objCgfDta.SVMXC__Operand__c != NULL)
                {
                    System.debug(LoggingLevel.Warn, 'Exp detail before upper case : '+objCgfDta.SVMXC__Operand__c);
                    String strFinalVal = '';
                    if(objCgfDta.SVMXC__Operand__c.containsIgnoreCase('SVMX.CURRENTRECORDHEADER'))
                        strFinalVal = 'SVMX.CURRENTRECORDHEADER'+ ((objCgfDta.SVMXC__Operand__c.containsIgnoreCase('CURRENTRECORDHEADER.')) ? '.'+objCgfDta.SVMXC__Operand__c.substringAfterLast('.') : '');
                    else if(objCgfDta.SVMXC__Operand__c.containsIgnoreCase('SVMX.CURRENTRECORD'))
                        strFinalVal = 'SVMX.CURRENTRECORD'+ ((objCgfDta.SVMXC__Operand__c.containsIgnoreCase('CURRENTRECORD.') ? '.'+objCgfDta.SVMXC__Operand__c.substringAfterLast('.') : ''));
                    else if(objCgfDta.SVMXC__Operand__c.containsIgnoreCase('SVMX.USERTRUNK'))
                        strFinalVal = 'SVMX.USERTRUNK';
                    if(strFinalVal != '')
                        objCgfDta.SVMXC__Operand__c = strFinalVal;
                    System.debug(LoggingLevel.Warn, 'Exp detail after upper case : '+objCgfDta.SVMXC__Operand__c);
                    
                    //Check if any ServiceMax Constans are there and accoring to that update SVMXC__Parameter_Type__c field.
                    if(objCgfDta.SVMXC__Operand__c != NULL && objCgfDta.SVMXC__Operand__c.contains('SVMX.CURRENTRECORDHEADER.')){
                        objCgfDta.SVMXC__Parameter_Type__c = 'Header Field Value';
                    }
                    else if(objCgfDta.SVMXC__Operand__c != NULL && objCgfDta.SVMXC__Operand__c.contains('SVMX.CURRENTRECORD.')){
                        objCgfDta.SVMXC__Parameter_Type__c = 'Field Value';
                    }
                }
            }
        }
        if (AdvanceOption == null ||AdvanceOption=='')
        {
            system.debug('Entered AdvanceOption');
            strCriteria = '';
            integer intCount = 0;
            isAdvanceOption = false;
            if(lstExpressions.size() != 1)
            {
                for(integer i = 0; i <= lstExpressions.size()-1; i++)
                {
                    if (lstExpressions[i].SVMXC__Field_Name__c != null && lstExpressions[i].SVMXC__Field_Name__c != '' && lstExpressions[i].SVMXC__Operator__c != null && lstExpressions[i].SVMXC__Operator__c != '' && lstExpressions[i].SVMXC__Field_Name__c.length() > 0 && lstExpressions[i].SVMXC__Operator__c.length() > 0)
                    {
                        /*if(strCriteria != null && strCriteria.length() > 0)
                            strCriteria += ' AND ';
                        //Naveen K:29,Mar,2011:Issue:1891 Added the below two lines 
                        intCount = i + 1;
                        strCriteria += ' ~' + intCount + '~ ';*/ //commented by hh as adv exp not saving
                        if(strCriteria != null && strCriteria.length() > 0)
                            strCriteria += ' AND ';
                        strCriteria += i+1;
                    }
                }
            }
            else
            {
                if (lstExpressions[0].SVMXC__Field_Name__c != null && lstExpressions[0].SVMXC__Field_Name__c != '' && lstExpressions[0].SVMXC__Operator__c != null && lstExpressions[0].SVMXC__Operator__c != '' && lstExpressions[0].SVMXC__Field_Name__c.length() > 0 && lstExpressions[0].SVMXC__Operator__c.length() > 0)
                    strCriteria = string.valueOf(1);
            }
            
            system.debug('F0'+strAdvanceOption);
            system.debug('lstExpressions'+lstExpressions);
        }
        else
        {
            system.debug('Advelse'+AdvanceOption);
            strCriteria = AdvanceOption.toUpperCase();
            strCriteria = string.escapeSingleQuotes(strCriteria);
        }
        
        /* Neeraj(7th-Aug-2013) - This code is commented to support more than 9 expressions
        for(integer i=0; i < 1000; i++)
        {
            strCriteria = strCriteria.replace(string.valueOf(i),' ~'+i+'~ ');
        }*/
        
        /* Logic to support more than 9 expressions */
        Set<Integer> setAdvExprCount = new Set<Integer>();
        if(strCriteria != NULL && strCriteria.length() > 0)
        {
            String strTempCriteria = '';
            for(String S : strCriteria.splitByCharacterTypeCamelCase())
            {
                String valueAfterTrim = S.trim();
                if(valueAfterTrim != NULL && valueAfterTrim.length() > 0)
                {
                    if(valueAfterTrim.isNumeric())
                    {
                        setAdvExprCount.add(Integer.valueOf(valueAfterTrim));
                        valueAfterTrim = '~' + valueAfterTrim + '~';
                    }
                    strTempCriteria += valueAfterTrim + ' ';
                }
            }
            strCriteria = '';
            strCriteria = strTempCriteria;
        }
        System.debug(LoggingLevel.WARN, 'Updated Crit: ' + strCriteria);
        System.debug(LoggingLevel.WARN, 'Integer values used in Adv expression field are: ' + setAdvExprCount);
        
        String strQueryWhereClause = strCriteria;
        for(integer i=0; i<lstExpressions.size(); i++)
        {
            if(setAdvExprCount != NULL && setAdvExprCount.size() > 0 && !setAdvExprCount.contains(i+1)){
                return 'ERROR';
            }
                
            if(lstExpressions[i].SVMXC__Field_Name__c <> '' || lstExpressions[i].SVMXC__Operator__c <> '')
            {
                string s = buildWhereClause(false, lstExpressions[i]);
                system.debug(LoggingLevel.WARN, 'Current value of s : ' + s);
                if (s <> null && s.length() > 0)
                {
                    strCriteria = strCriteria.replace('~' + (i+1) + '~', s);
                    if(lstExpressions[i].SVMXC__Operand__c != NULL && (lstExpressions[i].SVMXC__Operand__c.contains('SVMX.CURRENTRECORD.') || lstExpressions[i].SVMXC__Operand__c.contains('SVMX.CURRENTRECORDHEADER.') || lstExpressions[i].SVMXC__Operand__c.contains('SVMX.USERTRUNK')))
                        strQueryWhereClause = strQueryWhereClause.replace('~' + (i+1) + '~', ' Id != NULL ');
                    else
                        strQueryWhereClause = strQueryWhereClause.replace('~' + (i+1) + '~', s);
                }
                else 
                    break;
            }
        }
        
        System.debug(LoggingLevel.WARN, 'Parent Object Crit: ' + strCriteria);
        System.debug(LoggingLevel.WARN, 'Quesry Where clause: ' + strQueryWhereClause);
        
        try
        {
            if(strQueryWhereClause != NULL && strQueryWhereClause.length() > 0)
                strQueryWhereClause = strQueryWhereClause.replace('SVMX.Now', 'today').replace('SVMX.NOW', 'today').replace('Now', 'today').replace('NOW', 'today').replace('\'TODAY\'', 'today').replace('\'Today\'', 'today').replace('\'TOMORROW\'', 'tomorrow').replace('\'Tomorrow\'', 'tomorrow').replace('\'YESTERDAY\'', 'yesterday').replace('\'Yesterday\'', 'yesterday');
            
            if(strCriteria  != NULL && strCriteria.length() > 0)
                strCriteria = strCriteria.replace('SVMX.Now', 'today').replace('SVMX.NOW', 'today').replace('Now', 'today').replace('NOW', 'today').replace('\'TODAY\'', 'today').replace('\'Today\'', 'today').replace('\'TOMORROW\'', 'tomorrow').replace('\'Tomorrow\'', 'tomorrow').replace('\'YESTERDAY\'', 'yesterday').replace('\'Yesterday\'', 'yesterday');
            
            System.debug(LoggingLevel.WARN, 'Query Where clause after modification: ' + strQueryWhereClause);
            System.debug(LoggingLevel.WARN, 'Where clause after modification: ' + strCriteria);
            
            if(strQueryWhereClause != NULL && strQueryWhereClause.length() > 0 && strCriteria  != NULL && strCriteria.length() > 0)
                list<sObject> lstTemp = database.query('Select Id From ' + ObjectName + ' Where ' + strQueryWhereClause + ' limit 0');
        }
        catch(Exception ex)
        {
            System.debug(LoggingLevel.WARN, 'Exception: ' + ex.getMessage());
            return 'ERROR';
        }
        System.debug(LoggingLevel.WARN, 'Parent Object Criteria: ' + strCriteria);
        return strCriteria;
    }
        
    public String buildWhereClause(boolean showDebugMessages, SVMXC__ServiceMax_Config_Data__c lstExp) 
    {
        system.debug(LoggingLevel.WARN, 'Cofig Data - ' + lstExp);
        SVMXC__ServiceMax_Config_Data__c  o = lstExp;
        String SearchOperator ='';
        String SearchValue ='';
        String searchField ='';  
        
        if(o != null && o.SVMXC__Operator__c != null)
            SearchOperator = string.escapeSingleQuotes(o.SVMXC__Operator__c);
        
        if(o != null && o.SVMXC__Operand__c != null)
            SearchValue = string.escapeSingleQuotes(o.SVMXC__Operand__c);
        
        if(o != null && o.SVMXC__Field_Name__c != null)
            searchField = string.escapeSingleQuotes(o.SVMXC__Field_Name__c);
        
        Schema.DisplayType fldType = mapFieldDispType.get(o.SVMXC__Field_Name__c);
        
        System.debug(LoggingLevel.WARN, 'Expression is: ' + searchField + ' - ' + SearchOperator + ' - ' + SearchValue);
        system.debug(LoggingLevel.WARN, 'Field Api Obj Name: ' + mapFieldApiObjName.get(o.SVMXC__Field_Name__c) + ', Field Type: ' + fldType);
        
        if(fldType == Schema.DisplayType.REFERENCE)
        {
            searchField = getNameFieldFromReferenceType(searchField, mapFieldApiObjName.get(o.SVMXC__Field_Name__c), mapFieldRelName.get(o.SVMXC__Field_Name__c));
            List<string> lstRefFlds = searchField.replace('.', ':').split(':');
            o.SVMXC__Field_Relationship_Name__c = lstRefFlds[0];
            o.SVMXC__FKey_Name_Field__c = lstRefFlds[1];
            
            if(o.SVMXC__Field_Name__c != NULL && (SearchValue.contains('SVMX.CURRENTRECORD.') || SearchValue.contains('SVMX.CURRENTRECORDHEADER.') || SearchValue.contains('SVMX.USERTRUNK')))
                searchField = string.escapeSingleQuotes(o.SVMXC__Field_Name__c);
        }
        
        //Update Operand for SVMX.CURRENTRECORD. & SVMX.CURRENTRECORDHEADER. (i.e. [SVMX.CURRENTRECORD.SVMXC__Priority__c])
        if(SearchValue != NULL && (SearchValue.contains('SVMX.CURRENTRECORD.') || SearchValue.contains('SVMX.CURRENTRECORDHEADER.'))){
            SearchValue = SearchValue.removeStart('[').removeEnd(']');
            SearchValue = '[' + SearchValue + ']';
        }
        
        String cWhereClause = '';
        if (searchField == null || searchField == '') 
            return '';
        
        // Get the field type, field name, and query friendly search value
        String fldValue='';
        if (SearchValue <> null)
            fldValue = SearchValue.trim();
        
        system.debug(LoggingLevel.WARN, 'Trimmed Field Value: ' + fldValue);
        
        // Start building the additional WHERE Clause
        cWhereClause += searchField;
        if (SearchOperator == 'isnull')
            return searchField + ' = null';
        if (SearchOperator == 'isnotnull') 
            return searchField + ' != null';
        
        // ERROR CHECKING LOGIC
        if (fldValue != NULL && fldType == Schema.DisplayType.BOOLEAN && !(fldValue == 'true' || fldValue == 'false' || fldValue.contains('SVMX.CURRENTRECORD.') || fldValue.contains('SVMX.CURRENTRECORDHEADER.')))
        {
            system.debug('Entered BOOLEAN Type');
            response_success = false;
            stringMap.add(new SFM_WrapperDef.SFM_StringMap('Value can only be TRUE or FALSE : '+ FieldApiLable.get(searchField),'Value can only be TRUE or FALSE : '+ FieldApiLable.get(searchField)));
            isValidCri = false;
            return '';
        }  
        if ((fldType == Schema.DisplayType.DATE || fldType == Schema.DisplayType.DATETIME || fldType == Schema.DisplayType.CURRENCY || fldType == Schema.DisplayType.DOUBLE || fldType == Schema.DisplayType.INTEGER || fldType == Schema.DisplayType.PHONE || fldType == Schema.DisplayType.BOOLEAN) 
        && !(fldValue != NULL && (fldValue.contains('SVMX.CURRENTRECORD.') || fldValue.contains('SVMX.CURRENTRECORDHEADER.'))) && (SearchOperator == 'starts' || SearchOperator == 'contains' || SearchOperator == 'notcontain' || SearchOperator == 'in' || SearchOperator == 'notin')) 
        {
            system.debug('Entered DATE Type');
            response_success = false;
            stringMap.add( new SFM_WrapperDef.SFM_StringMap('Invalid Operator for this Field Type : '+FieldApiLable.get(searchField),'Invalid Operator for this Field Type : '+FieldApiLable.get(searchField)));
            isValidCri = false;
            return '';
        }  

        String cCloseCharacter = '';
        String cOperator = '';
        
        //Support for IN and NOT IN for ID Field
        if (fldType == Schema.DisplayType.STRING || fldType == Schema.DisplayType.REFERENCE || fldType == Schema.DisplayType.EMAIL || fldType == Schema.DisplayType.PICKLIST || fldType == Schema.DisplayType.MULTIPICKLIST || fldType == Schema.DisplayType.TEXTAREA || fldType == Schema.DisplayType.ID) 
        {
            system.debug('Entered STRING Type');
            if (!fldValue.contains(',')) 
            {
              system.debug('No comma');
                // No comma, so just use =, <>
                if (SearchOperator == 'eq') 
                    cOperator = '=';
                if (SearchOperator == 'ne') 
                    cOperator = '<>';
            } 
            else 
            {
                // comma present and
                system.debug('comma');
                if (SearchOperator == 'eq' || SearchOperator == 'in')
                     cOperator = ' IN (';
                if (SearchOperator == 'ne' || SearchOperator == 'notin') 
                    cOperator = ' NOT IN (';
                cCloseCharacter = ')';
            }
        } 
        else 
        {
            system.debug('Entered Else Block STRING Type');
            if (SearchOperator == 'eq') cOperator = '=';
            if (SearchOperator == 'ne') cOperator = '<>';
        }
        
        if (SearchOperator == 'gt') cOperator = '>';
        if (SearchOperator == 'lt') cOperator = '<';
        if (SearchOperator == 'ge') cOperator = '>=';
        if (SearchOperator == 'le') cOperator = '<=';
        
        //Support for IN and NOT IN for ID Field
        //Added one more condition(fldType == Schema.DisplayType.COMBOBOX) to support Combobox type of field as part of defect fix BAC-3659
        if (fldType == Schema.DisplayType.COMBOBOX || fldType == Schema.DisplayType.STRING || fldType == Schema.DisplayType.REFERENCE || fldType == Schema.DisplayType.EMAIL || fldType == Schema.DisplayType.PICKLIST || fldType == Schema.DisplayType.MULTIPICKLIST || fldType == Schema.DisplayType.TEXTAREA || fldType == Schema.DisplayType.ID) {
            system.debug('Entered PickList Type');
            if(fldType != Schema.DisplayType.ID)
            {
                if (SearchOperator == 'starts') { cOperator = ' LIKE \''; cCloseCharacter = '%\''; }
                if (SearchOperator == 'contains') { cOperator = ' LIKE \'%'; cCloseCharacter = '%\'';  system.debug('Entered Contains'+cWhereClause);}
                if (SearchOperator == 'notcontain') {
                    // NOT LIKE requires parenthesis around the whole condition, including the fieldname 
                    cWhereClause = ' (NOT(' + searchField ; 
                    system.debug('Entered PickList Type'+cWhereClause);
                    cOperator = ' LIKE \'%'; 
                    cCloseCharacter = '%\'))'; 
                }
            }
            if (SearchOperator == 'in' && fldType == Schema.DisplayType.MULTIPICKLIST) { cOperator = ' INCLUDES ('; cCloseCharacter = ')'; }
            if (SearchOperator == 'notin' && fldType == Schema.DisplayType.MULTIPICKLIST) { cOperator = ' EXCLUDES ('; cCloseCharacter = ')'; }
            if (SearchOperator == 'in' && fldType <> Schema.DisplayType.MULTIPICKLIST) { cOperator = ' IN ('; cCloseCharacter = ')'; }
            if (SearchOperator == 'notin' && fldType <> Schema.DisplayType.MULTIPICKLIST) { cOperator = ' NOT IN ('; cCloseCharacter = ')'; }
        }
        cWhereClause += cOperator;
        system.debug('Entered PickList Type2'+cWhereClause);
        
        if (cOperator == '') {
            system.debug('cOperator'+cOperator);
            response_success = false;
            stringMap.add(new SFM_WrapperDef.SFM_StringMap('Invalid Operator for this Field Type : '+FieldApiLable.get(searchField),'Invalid Operator for this Field Type : '+FieldApiLable.get(searchField)));
            isValidCri = false;
            return '';
        }
        
        //Support for IN and NOT IN for ID Field
        //Added one more condition(fldType == Schema.DisplayType.COMBOBOX) to support Combobox type of field as part of defect fix BAC-3659
        if (fldType == Schema.DisplayType.COMBOBOX || fldType == Schema.DisplayType.STRING || fldType == Schema.DisplayType.REFERENCE || fldType == Schema.DisplayType.EMAIL || fldType == Schema.DisplayType.PICKLIST || fldType == Schema.DisplayType.MULTIPICKLIST || fldType == Schema.DisplayType.TEXTAREA || fldType == Schema.DisplayType.ID) {
            system.debug('Entered PickList Type3');
            if (cCloseCharacter.startsWith('%')) {
                cWhereClause += fldValue ;
                system.debug('Entered PickList Type31'+cWhereClause);
            } else if (!fldValue.contains(',')) {
                cWhereClause += '\'' + fldValue + '\'';
                system.debug('Entered PickList Type32'+cWhereClause);
            } else {
                String[] multValues = fldValue.split(',');
                for (String v : multValues) {
                    cWhereClause += '\'' + v.trim() + '\',';
                }
                cWhereClause = cWhereClause.subString(0, cWhereClause.length()-1);
                system.debug('Entered PickList Type33'+cWhereClause);
            }
        } 
        else if (fldType == Schema.DisplayType.DATE || fldType == Schema.DisplayType.DATETIME) 
        {
            if (fldValue.toUpperCase().equals('THIS_WEEK') || fldValue.toUpperCase().equals('THIS_MONTH') || fldValue.toUpperCase().equals('NEXT_WEEK') || fldValue.toUpperCase().equals('NEXT_MONTH') || fldValue.toUpperCase().equals('LAST_WEEK') || fldValue.toUpperCase().equals('LAST_MONTH') || fldValue.toUpperCase().equals('NEXT_90_DAYS') || fldValue.toUpperCase().equals('LAST_90_DAYS')) 
            {
              
            } 
            else if (fldValue.toUpperCase().startsWith('NEXT_N_DAYS:') || fldValue.toUpperCase().startsWith('LAST_N_DAYS:')) 
            {
                
                try
                {
                    if(!fldValue.endsWith(':') && fldValue.split(':').size() == 2 && integer.valueOf(fldValue.split(':')[1]) >= 0)
                    {
                    }
                    else
                    {
                      response_success = false;
                      stringMap.add( new SFM_WrapperDef.SFM_StringMap('Invalid Date Format : '+FieldApiLable.get(searchField),'Invalid Date Format : '+FieldApiLable.get(searchField)));
                      isValidCri = false;
                      return '';
                    }
                }
                catch(exception ex)
                {
                    response_success = false;
                    stringMap.add(new SFM_WrapperDef.SFM_StringMap('Invalid Date Format','Invalid Date Format'));
                    isValidCri = false;
                    return '';
                }
            }
            else if (fldValue.toUpperCase().equals('NOW') || fldValue.toUpperCase().equals('Now') || fldValue.toUpperCase().equals('SVMX.NOW') || fldValue.toUpperCase().equals('TODAY') || fldValue.toUpperCase().equals('YESTERDAY') || fldValue.toUpperCase().equals('TOMORROW')) 
            {
            }
            else if(fldValue != NULL && (fldValue.contains('SVMX.CURRENTRECORD.') || fldValue.contains('SVMX.CURRENTRECORDHEADER.')))
            {
                
            }
            else 
            {
                try 
                {
                    if (fldType == Schema.DisplayType.DATE)
                    {
                        date testDate = StringToDate(fldValue);
                        system.debug('date after method call:'+testDate);
                        // Rebuild the date String as YYYY-MM-DD
                        String m = testDate.month().format();
                        String d = testDate.day().format();
                        if (integer.valueOf(m) < 10) m = '0' + m;
                        if (integer.valueOf(d) < 10) d = '0' + d;
                        fldValue = testDate.year() + '-' + m + '-' + d;
                    }
                    else if (fldType == Schema.DisplayType.DATETIME)
                    {
                        datetime testDate = StringToDatetime(fldValue);
                        String m = testDate.month().format();
                        String d = testDate.day().format();
                        String hh = testDate.hour().format();
                        String mm = testDate.minute().format();
                        String ss = testDate.second().format();
                        if (integer.valueOf(m) < 10) m = '0' + m;
                        if (integer.valueOf(d) < 10) d = '0' + d;
                        if (integer.valueOf(hh) < 10) hh = '0' + hh;
                        if (integer.valueOf(mm) < 10) mm = '0' + mm;
                        if (integer.valueOf(ss) < 10) ss = '0' + ss;
                        fldValue = testDate.year() + '-' + m + '-' + d +'T'+ hh + ':' + mm + ':' + ss+'Z';
                    }
                    // For DATETIME types, must add the hours AND we need to make it a compound condition
                    //     (field >= START AND field <= END)
                    // Example: field = 12/31/2008 will be translated to
                    //      field >= 2008-12-31T00:00:00Z AND field <= 2008-12-31T23:59:59Z 
                    /* 
                    if (fldType == Schema.DisplayType.DATETIME)
                    {
                        datetime testDate = StringToDatetime(fldValue);
                        // This creates a DateTime at midnight in the users current timezone 
                        datetime testDateTm = datetime.newInstance(testDate.year(), testDate.month(),testDate.day());
                        
                        // If the operator is equals/not equals then need a range for the entire day
                        // if the operator is greater or less, then we can just use the datetime
                        // but we'll need to adjust based on midnight or 23:59:59pm
                        if (cOperator == '=') 
                        {
                            system.debug('Entered PickList Type34'+cWhereClause);  
                            cWhereClause = ' (' + searchField + ' >= ';   
                            system.debug('Entered PickList Type341'+cWhereClause);                       
                            fldValue = testDateTm.format('yyyy-MM-dd') + 'T00:00:00Z';                          
                            cWhereClause += fldValue + ' AND ' + searchField + ' <= ' ;
                            fldValue = testDateTm.format('yyyy-MM-dd') + 'T23:59:59Z';
                            cCloseCharacter = ')';                          
                        } 
                        else if (cOperator == '<>') 
                        {
                            cWhereClause = ' (' + searchField + ' < ';                          
                            fldValue = testDateTm.format('yyyy-MM-dd') + 'T00:00:00Z';                          
                            cWhereClause += fldValue + ' OR ' + searchField + ' > ' ;
                            fldValue = testDateTm.format('yyyy-MM-dd') + 'T23:59:59Z';                          
                            cCloseCharacter = ')';                          
                        } 
                        else if (cOperator == '<') 
                        {
                            fldValue = testDateTm.format('yyyy-MM-dd') + 'T00:00:00Z';                          
                        }
                        else if (cOperator == '<=') 
                        {
                            fldValue = testDateTm.format('yyyy-MM-dd') + 'T23:59:59Z';
                        }
                        else if (cOperator == '>') 
                        {
                            fldValue = testDateTm.format('yyyy-MM-dd') + 'T23:59:59Z';
                        }
                        else if (cOperator == '>=') 
                        {
                            fldValue = testDateTm.format('yyyy-MM-dd') + 'T00:00:00Z';                          
                        }
                    }
                    */
                }
                catch (exception ex) 
                {
                    response_success = false;
                    stringMap.add(new SFM_WrapperDef.SFM_StringMap('Invalid Date Format : '+FieldApiLable.get(searchField),'Invalid Date Format : '+FieldApiLable.get(searchField)));
                    isValidCri = false;
                    return '';
                }
            }
            system.debug('Date datatype :' + fldValue);
            cWhereClause += fldValue.replace(' ', ' ');//.toUpperCase();
            system.debug('Entered PickList Type35'+cWhereClause);  
        } 
        else if (fldType == Schema.DisplayType.CURRENCY || fldType == Schema.DisplayType.DOUBLE ||fldType == Schema.DisplayType.INTEGER || fldType == Schema.DisplayType.BOOLEAN || fldType == Schema.DisplayType.PERCENT) 
            cWhereClause += fldValue ;
        else 
            cWhereClause += '\'' + fldValue + '\''; 
        system.debug('Entered PickList Type55'+cWhereClause);  
        cWhereClause += cCloseCharacter ;
        system.debug('Entered PickList Type56'+cWhereClause);  
        system.debug('WhereClauseString'+cWhereClause);
        if (cWhereClause <> null) 
        {
          
            return cWhereClause; 
        } 
        else 
        { 
          return ''; 
        }

    }

    //Neeraj(March-6th): Commented this method, we expect salesforce date and datetime format.
    // Convert a Date String to a Date type using the IntputDateFormat value
    // to determine how the date format is constructed
    /*
    public Date StringToDate(String s)
    {
        // Due to regular expressions, split('.') does not work so replace all separators with a /
        // to force the process to work.
        s = s.replace('.', '/').replace('-', '/').replace('\\', '/');
                    
        String[] StringDate = s.split('/');
        getInputDateFormat() ;
                    
        Integer m = 0;
        Integer d = 0;
        Integer y = 0;
        system.debug('Test01'+StringDate[0]+'----'+StringDate[1]+'----'+InputDateFormat);
        if (InputDateFormat.subString(0,2) == 'MM') 
        {
            m = Integer.valueOf(StringDate[0]);
            d = Integer.valueOf(StringDate[1]);
            y = Integer.valueOf(StringDate[2]);
        }
        if (InputDateFormat.subString(0,2) == 'DD') 
        { 
            d = Integer.valueOf(StringDate[0]);
            m = Integer.valueOf(StringDate[1]);
            y = Integer.valueOf(StringDate[2]);
        }
        system.debug('InputDateFormat:'+InputDateFormat.subString(0,2));
        if (InputDateFormat.subString(0,2) == 'YY') 
        { 
            y = Integer.valueOf(StringDate[0]);
            m = Integer.valueOf(StringDate[1]);
            d = Integer.valueOf(StringDate[2]);
        }
        system.debug('Test01:'+y);
        if (y < 100 && y > 80) y += 1900;
        if (y < 100) y += 2000;
        return date.newInstance(y,m,d); 
    }*/
    //Neeraj(March-06): Changed this method, It works properly if date is salesforce format.
    public Date StringToDate(String s)
    {
        s = s.replace('.', '/').replace('-', '/').replace('\\', '/').replace(' ', '/');
        String[] StringDate = s.split('/');
        system.debug('Date details:'+StringDate);
        Integer m = 0;
        Integer d = 0;
        Integer y = 0;
        y = Integer.valueOf(StringDate[0]);
        m = Integer.valueOf(StringDate[1]);
        d = Integer.valueOf(StringDate[2]);
        return date.newInstance(y,m,d); 
    }
    //Neeraj(March-06): Newly added method, It works properly if datetime is salesforce format.
    public DateTime StringToDatetime(String s)
    {
        s = s.replace('.', '/').replace('-', '/').replace('\\', '/').replace(' ', '/').replace(':', '/');
        String[] StringDate = s.split('/');
        system.debug('Date details:'+StringDate);
        Integer m = 0;
        Integer d = 0;
        Integer y = 0;
        Integer hh = 0;
        Integer mm = 0;
        Integer ss = 0;
        y = Integer.valueOf(StringDate[0]);
        m = Integer.valueOf(StringDate[1]);
        d = Integer.valueOf(StringDate[2]);
        if(StringDate.size() > 3)
            hh = Integer.valueOf(StringDate[3]);
        if(StringDate.size() > 4)
            mm = Integer.valueOf(StringDate[4]);
        if(StringDate.size() > 5)
            ss = Integer.valueOf(StringDate[5]);
        return datetime.newInstance(y,m,d,hh,mm,ss);
    }

    private String InputDateSep = '/';
    private String InputDateFormat = '';
    public String getInputDateFormat() 
    {
        return getInputDateFormat(2009,12,31);     
    }
    public String getInputDateFormat(integer intYY, integer intMM, integer intDD) 
    {
        String dtTest = date.newInstance(intYY, intMM, IntDD).format();
        InputDateSep = dtTest.subString(2,3); 
        if (dtTest.subString(0,2) == '12') 
            InputDateFormat = 'MM' + InputDateSep + 'DD' + InputDateSep + 'YYYY';
        if (dtTest.subString(0,2) == '31') 
            InputDateFormat = 'DD' + InputDateSep + 'MM' + InputDateSep + 'YYYY';
        if (dtTest.subString(0,2) == '20') 
            InputDateFormat = 'YYYY' + InputDateSep + 'MM' + InputDateSep + 'DD';
        return 'MM/DD/YYYY';     
    }   

    public String getNameFieldFromReferenceType(String fieldName,Schema.Sobjecttype sObjectName,String relname)
    {
        if(sObjectName == Account.SObjectType)
            return relname+'.'+'Name';

        else
        {
            Map<String, Schema.SObjectField> FieldMap = new Map<String, Schema.SObjectField>();
            String nameField;
            system.debug('sObjectName'+sObjectName);
            system.debug('relname'+relname);
            FieldMap = sObjectName.getDescribe().fields.getMap();
            if(FieldMap.size() > 0)
            {
                for(String s :FieldMap.keyset())
                {
                    Schema.DescribeFieldResult fieldDesc = FieldMap.get(s).getDescribe();
                    if(fieldDesc.isNameField())
                    {
                    nameField = fieldDesc.getName();
                    break;
                    }
                }
                /*if(fieldName.contains('__c)'))
                {
                    return fieldName.substring(0,fieldName.length()-3) + '__r.' + nameField;    
                }
                else
                {
                    return fieldName+ '__r.' + nameField;   
                } */
                return relname+'.'+nameField;     
            }
            return null;
        }
    }
}