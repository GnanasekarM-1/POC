public with sharing class COMM_SVMXC_Search_Expressions //latest Updated On 3/29/2010
{
    boolean isValidCri;
    boolean showPageError;
    boolean fst = true;
    public boolean AllowSelectOperater = true;
        public boolean getAllowSelectOperater(){return AllowSelectOperater;}
    public boolean DisplaySequence = true;
        public boolean getDisplaySequence(){return DisplaySequence;}
    public boolean DisplayOperand = true;
        public boolean getDisplayOperand(){return DisplayOperand;}
    public boolean HasAdvanceOption = true;
        public boolean getHasAdvanceOption(){return HasAdvanceOption;}
    public boolean HasErrorMessage = true;
        public boolean getHasErrorMessage(){return HasErrorMessage;}
    public string ExpressionName = '';
        
    public string DefaultSelectedOperator;
        public string getDefaultSelectedOperator(){return this.DefaultSelectedOperator;}
        
    public string ExpressionType;
        public string getExpressionType(){return this.ExpressionType;}      
        
    public list<SelectOption> OperatorSelectList = new list<SelectOption>();
    
    public list<string> FieldTypes = new list<string>();
    
    public integer Size;    
        public integer getSize(){return this.lstExpressions.size();}
    public list<SVMXC__ServiceMax_Config_Data__c> Expressions = new list<SVMXC__ServiceMax_Config_Data__c>();
    //public list<SObject> Expressions;
    
    public list<expression> lstExpressions = new list<expression>();
        public list<expression> getlstExpressions()
        { 
            if (lstExpressions == null || (lstExpressions.size() == 0 && fst)) 
            { 
                addCriteriaExpression(expSize); 
                fst = false;
            }
            else
            {
                sortexpressionlist();
                integer j;
                integer iSize = 0;
                if(lstExpressions.size() > 0)
                    iSize = lstExpressions[lstExpressions.size()-1].sequence;
                for(integer i = 0; i< iSize ; i++ )
                {
                    if(!(lstExpressions[i].Sequence == i + 1))
                        lstExpressions.add(i, new expression(i+1, '', '', '', '', '', '', '', '', getTAG005(), ExpressionName));
                }
            }
            return lstExpressions;
        }
        public void setlstExpressions(list<expression> lst){this.lstExpressions = lst;}
    public string AdvanceOption = '';
        public string getAdvanceOption(){return AdvanceOption;}
        public void setAdvanceOption(string str){this.AdvanceOption = str;}
    public string ErrorMessage;
        public string getErrorMessage(){return ErrorMessage;}
        public void setErrorMessage(string str){this.ErrorMessage = str;}
    public Map<String,String>  FieldApiLable = new Map<String,String>();
    public Map<String,Schema.Displaytype>  mapFieldDispType = new Map<String,Schema.Displaytype>();
    public Map<String, Schema.SObjectField> TempfieldsMap = new Map<String, Schema.SObjectField>(); 
    public Map<String, Schema.SObjectField> fieldsMap = new Map<String, Schema.SObjectField>();
    public Map<String,Schema.SObjectField> objfieldMap = new Map<String,Schema.SObjectField>();
    public Map<String,Schema.SObjectField> objfieldMap2 = new Map<String,Schema.SObjectField>();
    public List<selectoption> FieldsList = new List<selectoption>();  //list of fields values
        public List<selectoption> getFieldsList()
        {
            if(FieldsList == null)
                FieldsList = new List<selectoption>();
            if (FieldsList.size() == 0 ) 
                FieldsList.add(new selectOption('SVMX.NONE', getTAG005())); 
            else if (FieldsList.size() > 0 && FieldsList[0].getValue() != null && FieldsList[0].getValue() != 'SVMX.NONE') //
                FieldsList.add(0, new selectOption('SVMX.NONE', getTAG005()));
            return FieldsList;
            //FieldsList = sortFieldList();if (FieldsList.size() == 0 ) FieldsList.add(new selectOption('', getTAG005())); return FieldsList;
        }
        public void setFieldsList(List<selectoption> lst) {FieldsList=lst;}
    public string DefaultOperator;
    public string DefaultField;
    public void setDefaultField(string s){this.DefaultField = s; for(expression e :lstExpressions){e.DefaultField =s; }}  
    public string DefaultListValue; 
    private integer expSize=0;
    public COMM_SVMXC_Search_Expressions()
    {
        //
    }
    public COMM_SVMXC_Search_Expressions(integer i)
    {
        expSize = i;
        //addCriteriaExpression(expSize);
    }
    public COMM_SVMXC_Search_Expressions(integer i, boolean bAllowSelectOperater, boolean bDisplaySequence, boolean bHasAdvanceOption, boolean bHasErrorMessage, boolean bDisplayOperand, string sDefaultSelectedOperator, string sDefaultField )
    {
        expSize = i;
        this.DisplaySequence = bDisplaySequence;
        this.HasAdvanceOption = bHasAdvanceOption;
        this.HasErrorMessage = bHasErrorMessage;
        this.DefaultSelectedOperator = sDefaultSelectedOperator;
        this.AllowSelectOperater = bAllowSelectOperater;
        this.DisplayOperand = bDisplayOperand;
        setDefaultField(sDefaultField);
    }
    //SVMXC.COMM_Utils_ManageTags commUtil = new SVMXC.COMM_Utils_ManageTags();
    //public Map<String, String> svmxTagList = commUtil.SVMX_getTagList('COMM002');
    
    public String getHLPURL() {return System.Label.COMM002_HLPURL;} //HLPURL
    public String getTAG001() {return System.Label.COMM002_TAG001;} //Value can only be TRUE or FALSE
    public String getTAG002() {return System.Label.COMM002_TAG002;} //Invalid Operator for this Field Type :
    public String getTAG003() {return System.Label.COMM002_TAG003;} //Invalid Date Format :
    public String getTAG004() {return System.Label.COMM002_TAG004;} //Invalid Advance Option:
    public String getTAG005() {return System.Label.COMM002_TAG005;}
    public String getTAG006() {return System.Label.COMM002_TAG006;}
    public String getTAG007() {return System.Label.COMM002_TAG007;}
    public String getTAG008() {return System.Label.COMM002_TAG008;}
    public String getTAG009() {return System.Label.COMM002_TAG009;}
    public String getTAG010() {return System.Label.COMM002_TAG010;}
    public String getTAG011() {return System.Label.COMM002_TAG011;}
    public String getTAG012() {return System.Label.COMM002_TAG012;}
    public String getTAG013() {return System.Label.COMM002_TAG013;}
    public String getTAG014() {return System.Label.COMM002_TAG014;}
    public String getTAG015() {return System.Label.COMM002_TAG015;}
    public String getTAG016() {return System.Label.COMM002_TAG016;}
    public String getTAG017() {return System.Label.COMM002_TAG017;}
    public String getTAG018() {return System.Label.COMM002_TAG018;}
    public String getTAG019() {return System.Label.COMM002_TAG019;}
    public String getTAG020() {return System.Label.COMM002_TAG020;}
    public String getTAG021() {return System.Label.COMM002_TAG021;}
    public String getTAG022() {return System.Label.COMM002_TAG022;}
    public String getTAG023() {return System.Label.COMM002_TAG023;}
    public list<selectOption> sortFieldList()
    {
        //try
        //{
            map<string, selectOption> mapTemp = new map<string, SelectOption>();
            for(selectOption o :FieldsList)
            {
                mapTemp.put(o.getLabel()+'-'+o.getValue(), o);
            }
            list<string> lstTemp = new list<string>();
            lstTemp.addAll(mapTemp.KeySet());
            lstTemp.sort();
            if(lstTemp.size()>0)
            {
                FieldsList.clear();
                for(string str: lstTemp)
                {
                    FieldsList.add(mapTemp.get(str));
                }
            }
            return FieldsList;
        /*}
        catch(exception ex)
        {
            return FieldsList;
        }*/
    }
    public void sortexpressionlist()
    {
        //try
        //{
            map<integer, expression> mapTemp = new map<integer, expression>();
            for(expression e :lstExpressions)
            {
                mapTemp.put(e.sequence, e);
            }
            list<Integer> lstTemp = new list<Integer>();
            lstTemp.addAll(mapTemp.KeySet());
            lstTemp.sort();
            if(lstTemp.size()>0)
            {
                lstExpressions.clear();
                for(Integer i: lstTemp)
                {
                    lstExpressions.add(mapTemp.get(i));
                }
            }
            //return FieldsList;
        /*}
        catch(exception ex)
        {
            return FieldsList;
        }*/
    }
    public string getCriteria(String ObjectName, Map<String, Schema.DisplayType> mfieldType, Map<String, string> mfldApiName)
    {
        mapFieldDispType = mfieldType;
        FieldApiLable = mfldApiName;
        return getCriteria(ObjectName);     
    }
    
    public string getCriteria(String ObjectName)
    {
        boolean isAdvanceOption = true;
        isValidCri = true;
        string strCriteria = '';
        
        if (!(lstExpressions.size() > 0))
        {
            AdvanceOption = '';
            return '';
        }
        Map<String, Schema.SObjectType> allobjmap = new Map<String, Schema.SObjectType>();
        Map<String, Schema.SObjectType> allObjs = new Map<String, Schema.SObjectType>();
        allObjs = Schema.getGlobalDescribe();
        for(Schema.SObjectType s : allObjs.values())
        {
            Schema.DescribeSObjectResult objDesc = s.getDescribe();
            allobjmap.put(objDesc.getName(),s);
        }
        if(allobjmap.containsKey(ObjectName))
        {
        Schema.DescribeSObjectResult objDesc = allobjmap.get(ObjectName).getDescribe(); 
        TempfieldsMap = objDesc.fields.getMap();
        for(String s : TempfieldsMap.keyset())
        {
            String APIName = TempfieldsMap.get(s).getDescribe().getName();
            fieldsMap.put(APIName,TempfieldsMap.get(s));
        }
        }
        if (AdvanceOption == null || AdvanceOption.trim().length() == 0 )
        {
            strCriteria = '';
            isAdvanceOption = false;
            if(lstExpressions.size() != 1)
            {
                for(integer i = 0; i <= lstExpressions.size()-1; i++)
                {
                    if (lstExpressions[i].FieldName != null && lstExpressions[i].FieldName != 'SVMX.NONE' && lstExpressions[i].Operator != null && lstExpressions[i].Operator != 'SVMX.NONE' && lstExpressions[i].FieldName.length() > 0 && lstExpressions[i].Operator.length() > 0)
                    {
                        if(strCriteria != null && strCriteria.length() > 0)
                            strCriteria += ' AND ';
                        strCriteria += i+1;
                    }
                    //if ( i != lstExpressions.size()-1 && lstExpressions[i+1].FieldName != null && lstExpressions[i].FieldName != 'SVMX.NONE' && lstExpressions[i+1].Operator != null && lstExpressions[i].Operator != 'SVMX.NONE' && lstExpressions[i+1].FieldName.length() > 0 && lstExpressions[i+1].Operator.length() > 0)
                        
                }
            }
            else
            {
                if (lstExpressions[0].FieldName != null && lstExpressions[0].FieldName != 'SVMX.NONE' && lstExpressions[0].Operator != null && lstExpressions[0].Operator != 'SVMX.NONE' && lstExpressions[0].FieldName.length() > 0 && lstExpressions[0].Operator.length() > 0)
                    strCriteria = string.valueOf(1);
            }
        }
        else
            strCriteria = AdvanceOption.toUpperCase();
        strCriteria = string.escapeSingleQuotes(strCriteria);
        //if(strCriteria != Null && strCriteria.length() > 0)
            //AdvanceOption = strCriteria.toUpperCase();
        /*strCriteria.replace('(',' ( ');
        strCriteria.replace(')',' ) ');*/
        system.debug('asdf'+strCriteria);
        for(integer i=0; i < 1000; i++)
        {
            strCriteria = strCriteria.replace(string.valueOf(i),' ~'+i+'~ ');
        }
        /*for(integer i=1;i<=lstExpressions.size();i++)
        {
            if (lstExpressions[i-1].FieldName != null && lstExpressions[i-1].FieldName != 'SVMX.NONE' && lstExpressions[i-1].FieldName.length() > 0 && lstExpressions[i-1].Operator.length() > 0 && lstExpressions[i-1].Operator != null && lstExpressions[i-1].Operator != 'SVMX.NONE')
            {
                if (AdvanceOption.contains(string.ValueOf(i)))
                {
                    if(!(isAdvanceOption))
                        AdvanceOption = '';
                    AddException(ExpressionName, FieldApiLable.get(lstExpressions[i-1].FieldName) + ': '+ getTAG004());
                    //apexpages.addMessage( new apexpages.Message( ApexPages.severity.ERROR,  ExpressionName + ': '+ FieldApiLable.get(lstExpressions[i-1].FieldName) + ': '+ getTAG004()));
                    isValidCri = false;
                    showPageError = true;
                    return null;
                }
            }
        }*/
        for(integer i=0; i < lstExpressions.size(); i++)
        {
            if (lstExpressions[i].FieldName <> null && lstExpressions[i].FieldName != 'SVMX.NONE' && lstExpressions[i].FieldName <> '' && lstExpressions[i].Operator <> null && lstExpressions[i].Operator != 'SVMX.NONE' && lstExpressions[i].Operator <> '')
            {
                string s = buildWhereClause(false, i);
                if (s <> null && s.length() > 0)
                    strCriteria = strCriteria.replace('~'+(i+1)+'~', s);
            }
        }
        string strCriteria2;
        Boolean IsCriteriaError = false;
        try
        {
            /*for(integer i=0; i < 1000; i++)
            {
                if(strCriteria.Contains('~'+(i+1)+'~'))
                {
                    isValidCri = false;
                    showPageError = true;
                    AddException(ExpressionName, getTAG004());
                    return 'ERROR';
                }
            }*/
            if (strCriteria  <> null && strCriteria.length() > 0)
            {
                IsCriteriaError = true;
                strCriteria2 = strCriteria.toUpperCase().replace('SVMX.CURRENTUSER',  UserInfo.getUserId() );
                strCriteria2 = strCriteria2.toUpperCase().replace('SVMX.OWNER',  UserInfo.getUserId() );
                strCriteria2 = strCriteria2.replace('SVMX.Now', 'TODAY');
                strCriteria2 = strCriteria2.replace('SVMX.now', 'TODAY');
                strCriteria2 = strCriteria2.replace('SVMX.NOW', 'TODAY');
        //Commented as part of Checkmarx Security issues fixes
                //list<sObject> lstTemp = database.query('select id from '+ ObjectName +' where ' + strCriteria2 + ' limit 0'); //On 22Mar10 -GM Added: escapeSingleQuotes
            }
        }
        catch(Exception ex)
        {
            system.debug('asdf'+'select id from '+ ObjectName +' where ' + strCriteria2 + ' limit 0');
            system.debug('asdf'+ex.getMessage());
            if(isValidCri)
            {
                if(IsCriteriaError)
                    AddException(ExpressionName, getTAG004());
                else
                    AddException(ExpressionName, ex.getMessage());
            }
            return 'ERROR';
        }
        return strCriteria;
    }
    
    public void setExpressions( list<SVMXC__ServiceMax_Config_Data__c> lst, string fldSeq, string fldldName, string fldOpr, string fldOpd)
    {
        for(SVMXC__ServiceMax_Config_Data__c o: lst)
        {
            setExpressions(o,fldSeq, fldldName, fldOpr, fldOpd);
        }
    }
    public void setExpressions( SVMXC__ServiceMax_Config_Data__c sObj)
    {
        Expressions.add(sObj);
        lstExpressions.add(new expression(((Decimal)(sObj.SVMXC__Sequence__c)).intValue() , sObj.SVMXC__Field_Name__c, sObj.SVMXC__Operator__c, sObj.SVMXC__Operand__c, mapFieldDispType.containsKey(sObj.SVMXC__Field_Name__c)?mapFieldDispType.get(sObj.SVMXC__Field_Name__c).name() : '', sObj.SVMXC__Object_Name__c, sObj.SVMXC__FKey_Name_Field__c, sObj.SVMXC__Object_Name__c, sObj.SVMXC__Lookup_Field_API_Name__c, getTAG005(), ExpressionName));
        OnChangeField(lstExpressions.size(), false);
        fst = false;
    }
    public void setExpressions( SVMXC__ServiceMax_Config_Data__c sObj, string fldSeq, string fldldName, string fldOpr, string fldOpd)
    {
        Expressions.add(sObj);
        lstExpressions.add(new expression(((Decimal)(sObj.get(fldSeq))).intValue(), (String)sObj.get(fldldName), (String)sObj.get(fldOpr), (String)sObj.get(fldOpd), mapFieldDispType.get((String)sObj.get(fldldName)).name() , (String)sObj.get('SVMXC__Object_Name__c') , (String)sObj.get('SVMXC__FKey_Name_Field__c'), (String)sObj.get('SVMXC__Object_Name__c'), (String)sObj.get('SVMXC__Lookup_Field_API_Name__c'), getTAG005(), ExpressionName));
        OnChangeField(lstExpressions.size(), false);
        fst = false;
    }
    Map<String,Schema.SObjectType> MapFieldSObjectType = new Map<String,Schema.SObjectType>();
    public Schema.SObjectType getFieldSObjectType(String FieldName)
    {
        if(MapFieldSObjectType.containsKey(FieldName))
            return MapFieldSObjectType.get(FieldName);
        else
        {
            if(objfieldMap != null && objfieldMap.containsKey(FieldName))
            {
                MapFieldSObjectType.put(FieldName, objfieldMap.get(FieldName).getDescribe().getReferenceTo()[0]);
                return MapFieldSObjectType.get(FieldName);
            }
            return null;
        }
    }
    map<string, string> mapObjectNameField = new map<string, string>(); 
    public void OnChangeField(integer iIndex, boolean clearOperand)
    {
        System.debug( LoggingLevel.INFO, 'lstExpressions: ' + lstExpressions[iIndex-1]);
        lstExpressions[iIndex-1].FieldType =  mapFieldDispType.containsKey(lstExpressions[iIndex-1].FieldName)? mapFieldDispType.get(lstExpressions[iIndex-1].FieldName).name() : '';
        if(lstExpressions[iIndex-1].FieldType.toUpperCase() == 'BOOLEAN' )
        {
            lstExpressions[iIndex-1].Values.add(new selectOption('False', 'False'));
            lstExpressions[iIndex-1].Values.add(new selectOption('True', 'True'));
            if(clearOperand)
                lstExpressions[iIndex-1].Operand = '';
            
        }
        else if(lstExpressions[iIndex-1].FieldType.toUpperCase() == 'REFERENCE')
        {
            Schema.SObjectType sobjRefTo  = getFieldSObjectType(lstExpressions[iIndex-1].FieldName);
            System.debug('sobjRefTo: ' + sobjRefTo );            
            if(sobjRefTo != null)
            {
                if (sobjRefTo == Account.SObjectType)
                {                   
                    lstExpressions[iIndex-1].ObjectNameField = 'Name';
                }
                else
                {
                    lstExpressions[iIndex-1].ObjectName = sobjRefTo.getDescribe().getName();
                    objfieldMap2 = sobjRefTo.getDescribe().fields.getMap();
                    for (String fieldKey : objfieldMap2.keySet()) 
                    {
                        if (mapObjectNameField.containsKey(fieldKey))
                            lstExpressions[iIndex-1].ObjectNameField = mapObjectNameField.get(fieldKey);
                        else
                        {
                            Schema.DescribeFieldResult f = objfieldMap2.get(fieldKey).getDescribe();
                            if(f.isNameField())
                            {
                                mapObjectNameField.put(fieldKey, f.getName());
                                lstExpressions[iIndex-1].ObjectNameField = f.getName();
                            }
                        }
                    }
                }
            }
            if(clearOperand)
                lstExpressions[iIndex-1].Operand = '';
        }
        else if(lstExpressions[iIndex-1].FieldType.toUpperCase() == 'PICKLIST')
        {
            lstExpressions[iIndex-1].Values.clear();
            Schema.DescribeFieldResult f;
            if(objfieldMap.containsKey(lstExpressions[iIndex-1].FieldName))
                f = objfieldMap.get(lstExpressions[iIndex-1].FieldName).getDescribe();
            else
            {
                for(string s :objfieldMap.keySet())
                {
                    Schema.DescribeFieldResult f2 = objfieldMap.get(s).getDescribe();
                    if(lstExpressions[iIndex-1].FieldName.toUpperCase() == f2.getName() )
                    {
                        f = f2;
                        break;
                    }
                }
            }
            if(f != null)
            {
                lstExpressions[iIndex-1].Values.add(new SelectOption('SVMX.NONE', DefaultListValue));
                for(Schema.PicklistEntry p: f.getPicklistValues() )
                {
                    if(p.isActive())
                        lstExpressions[iIndex-1].Values.add(new SelectOption(p.getValue(), p.getLabel()));
                }
            }
            if(clearOperand)
                lstExpressions[iIndex-1].Operand = '';
        }
    }
    public void getExpressions(Map<String, string> mProperties)
    {
        try
        {//*/
            list<SVMXC__ServiceMax_Config_Data__c> dellst = new list<SVMXC__ServiceMax_Config_Data__c>();
         
            integer i = Expressions.size();
            integer j = lstExpressions.size();
            system.debug('asdf'+i+'='+j);
            for(integer k=0; k < ((Expressions.size() > lstExpressions.size())? Expressions.size(): lstExpressions.size()); k++)
            {
                if(k < i && k < j)
                {
                    string s = Expressions[k].ID;
                    if(lstExpressions[k].FieldName != null && lstExpressions[k].FieldName != 'SVMX.NONE' && lstExpressions[k].Operator != null && lstExpressions[k].Operator != 'SVMX.NONE' && lstExpressions[k].FieldName.length() > 0 && lstExpressions[k].Operator.length() > 0)
                    {
                        for(string str :mProperties.keySet())
                        {
                            Expressions[k].put(str, mProperties.get(str));
                        }
                        Expressions[k].SVMXC__Sequence__c = lstExpressions[k].Sequence;
                        Expressions[k].SVMXC__Field_Name__c = lstExpressions[k].FieldName;
                        Expressions[k].SVMXC__Operator__c = lstExpressions[k].Operator;
                        Expressions[k].SVMXC__Operand__c = lstExpressions[k].Operand;
                        if(mapFieldDispType.containsKey(lstExpressions[k].FieldName))
                            Expressions[k].SVMXC__Display_Type__c = mapFieldDispType.get(lstExpressions[k].FieldName).name();
                        /*if(mapFieldDispType.get(lstExpressions[k].FieldName) == Schema.Displaytype.REFERENCE )
                        {*/
                            Expressions[k].SVMXC__Object_Name__c = lstExpressions[k].ObjectName;
                            Expressions[k].SVMXC__FKey_Name_Field__c = lstExpressions[k].ObjectNameField;
                            Expressions[k].SVMXC__Lookup_Field_API_Name__c = lstExpressions[k].ParentLookUpField;
                        // Defect 011802 fix
                        if( Expressions[k].SVMXC__Object_Name__c == null && 
                            Expressions[k].SVMXC__Operand__c != null && 
                            Expressions[k].SVMXC__Operand__c.toUpperCase().equals('SVMX.CURRENTUSER') ) {
                          
                                Expressions[k].SVMXC__Object_Name__c = 'User';
                        }
                        //}
                    }
                    else if(Expressions[k].ID != null && s.length() > 0)
                    {
                        dellst.add(Expressions[k]);
                    }
                }
                else if(k < Expressions.size() && k >= lstExpressions.size())
                {
                    dellst.add(Expressions[k]);
                }
                else if(k >= Expressions.size() && k < lstExpressions.size())
                {
                    if(lstExpressions[k].FieldName != null && lstExpressions[k].FieldName != 'SVMX.NONE' && lstExpressions[k].Operator != null && lstExpressions[k].Operator != 'SVMX.NONE' && lstExpressions[k].FieldName.length() > 0 && lstExpressions[k].Operator.length() > 0)
                    {
                        SVMXC__ServiceMax_Config_Data__c o = new SVMXC__ServiceMax_Config_Data__c();
                        for(string str :mProperties.keySet())
                        {
                            o.put(str, mProperties.get(str));
                        }
                        o.SVMXC__Sequence__c = lstExpressions[k].Sequence;
                        o.SVMXC__Field_Name__c = lstExpressions[k].FieldName;
                        o.SVMXC__Operator__c = lstExpressions[k].Operator;
                        o.SVMXC__Operand__c = lstExpressions[k].Operand;
                        if(mapFieldDispType.containsKey(lstExpressions[k].FieldName))
                            o.SVMXC__Display_Type__c = mapFieldDispType.get(lstExpressions[k].FieldName).name();
                        /*if(mapFieldDispType.get(lstExpressions[k].FieldName) == Schema.Displaytype.REFERENCE )
                        {*/
                            o.SVMXC__Object_Name__c =  lstExpressions[k].ObjectName;
                            o.SVMXC__FKey_Name_Field__c = lstExpressions[k].ObjectNameField;
                            o.SVMXC__Lookup_Field_API_Name__c = lstExpressions[k].ParentLookUpField;
                        
                          // Defect 011802 fix
                          if( o.SVMXC__Object_Name__c == null && o.SVMXC__Operand__c != null && 
                            o.SVMXC__Operand__c.toUpperCase().equals('SVMX.CURRENTUSER') ) {                          
                                o.SVMXC__Object_Name__c = 'User';
                          }
                        //}
                        
                        Expressions.add(o);
                    }
                }
            }
            if(Expressions != null && Expressions.size() > 0){
        //upsert Expressions;
        if(COMM_SecurityUtils.getInstance().verifyFieldAccess(Expressions, COMM_SecurityUtils.Access.Upsertable)){
          upsert Expressions; //SDL-SVMX-CREATE-UPDATE-FLS-ENFORCED
        }
        else{
          throw new COMM_SecurityUtils.SecurityAccessException(System.label.COMM001_TAG142);
        }
      }
            if(dellst != null && dellst.size() > 0){
        //delete dellst;
        if(COMM_SecurityUtils.getInstance().isDeletableObject('SVMXC__ServiceMax_Config_Data__c')){
          delete dellst; //SDL-SVMX-DELETE-FLS-ENFORCED
        }
        else{
          throw new COMM_SecurityUtils.SecurityAccessException(System.label.COMM001_TAG142);
        }
      }
            system.debug('asdfexp'+Expressions);
        }
        catch ( exception ex)
        {
            system.debug('asdfex'+ex);
        }//*/
    }
    
    public void addCriteriaExpression(integer iIndex)
    {
        for (integer i = 0; i < iIndex; i++)
        {
            expression objExp = new expression();
            objExp.Sequence = lstExpressions.size()+1;
            objExp.FieldName = 'SVMX.NONE';
            if(AllowSelectOperater)
                objExp.Operator = 'SVMX.NONE';
            else
                objExp.Operator = DefaultSelectedOperator;
            objExp.Operand = '';
            //objExp.OperandID = '';
            lstExpressions.add(objExp);
        }
    }
    
    public void removeCriteriaExpression(integer iIndex)
    {
        lstExpressions.remove(iIndex - 1);
        for( integer i = iIndex; i <= lstExpressions.size(); i++ )
        {
            lstExpressions[i-1].Sequence = i;
        }
    }
    
    /*private List<SelectOption> sortingSelectOption(List<SelectOption> lstSO)
    {
        
        map<string, selectOption> mapTemp = new map<string, SelectOption>();
        for(selectOption o :lstSO)
        {
            mapTemp.put(o.getLabel()+'-'+o.getValue(), o);
        }
        list<string> lstTemp = new list<string>();
        lstTemp.addAll(mapTemp.KeySet());
        lstTemp.sort();
        lstSO.clear();
        for(string str: lstTemp)
        {
            lstSO.add(mapTemp.get(str));
        }
        return lstSO;
    }*/
    public List<SelectOption> getOperatorSelectList() 
    {
        List<SelectOption> options = new List<SelectOption>();
        options.add(new selectOption('SVMX.NONE', getTAG005()));
        options.add(new selectOption('eq', getTAG006()));
        options.add(new selectOption('ne', getTAG007()));
        options.add(new selectOption('gt', getTAG008()));
        options.add(new selectOption('ge', getTAG009()));
        options.add(new selectOption('lt', getTAG010()));
        options.add(new selectOption('le', getTAG011()));
        options.add(new selectOption('starts', getTAG012()));
        options.add(new selectOption('contains', getTAG013()));
        options.add(new selectOption('notcontain', getTAG014()));
        options.add(new selectOption('in', getTAG015()));
        options.add(new selectOption('notin',getTAG016()));
        options.add(new selectOption('isnull', getTAG022()));
        options.add(new selectOption('isnotnull',getTAG023()));
        return options;
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
    public String buildWhereClause(boolean showDebugMessages,  integer i) 
    {
        expression o = lstExpressions.get(i);
        String SearchOperator = '';
        String SearchValue = '';
        String searchField = '';  
        
        if(o != null && o.Operator != null)
            SearchOperator = string.escapeSingleQuotes(o.Operator);
        //if(o != null && o.getOperandID() != null)
            SearchValue = string.escapeSingleQuotes(o.Operand);
        if(o != null && o.FieldName != null)
            searchField = string.escapeSingleQuotes(o.FieldName);
        
        //Schema.DisplayType fldType = mapFieldDispType.get(o.FieldName);//commented due to bug no.2483.
        Schema.DescribeFieldResult DesResult;
        Schema.DisplayType fldType;
        if(fieldsMap.containsKey(searchField))
        {
           DesResult = fieldsMap.get(searchField).getDescribe();
           fldType = DesResult.getType();
        }
       
        boolean debugMode = showDebugMessages;
        String cWhereClause = '';
        if (searchField == null || searchField == '') 
            return '';
        String[] arrssearchField = searchField.split(':');
        // Get the field type, field name, and query friendly search value
        String fldValue='';
        if (SearchValue <> null)
            fldValue = SearchValue.trim();
        // Start building the additional WHERE Clause
        cWhereClause += searchField;
         if (SearchOperator == 'isnull')
            return searchField + ' = null';
        if (SearchOperator == 'isnotnull') 
            return searchField + ' != null';
        // ERROR CHECKING LOGIC
        if (fldType == Schema.DisplayType.BOOLEAN && !(fldValue.toUpperCase() == 'TRUE' || fldValue.toUpperCase() == 'FALSE')) 
        {
            AddException(ExpressionName, getTAG001() +': '+ FieldApiLable.get(searchField));
            isValidCri = false;
            showPageError = true;
            return '';
        }  
        if ((fldType == Schema.DisplayType.DATE || fldType == Schema.DisplayType.DATETIME || fldType == Schema.DisplayType.CURRENCY || fldType == Schema.DisplayType.DOUBLE || fldType == Schema.DisplayType.PHONE || fldType == Schema.DisplayType.BOOLEAN) 
        && (SearchOperator == 'starts' || SearchOperator == 'contains' || SearchOperator == 'notcontain' || SearchOperator == 'in' || SearchOperator == 'notin')) 
        {
            AddException(ExpressionName, getTAG002() + ': '+ FieldApiLable.get(searchField));
            isValidCri = false;
            showPageError = true;
            return '';
        }  

        String cCloseCharacter = '';
        String cOperator = '';
        
        if (fldType == Schema.DisplayType.STRING || fldType == Schema.DisplayType.REFERENCE || fldType == Schema.DisplayType.EMAIL || fldType == Schema.DisplayType.PICKLIST || fldType == Schema.DisplayType.MULTIPICKLIST || fldType == Schema.DisplayType.TEXTAREA  ) 
        {
            if (!fldValue.contains(',')) 
            {
                // No comma, so just use =, <>
                if (SearchOperator == 'eq') 
                    cOperator = '=';
                if (SearchOperator == 'ne') 
                    cOperator = '<>';
            } 
            else 
            {
                // comma present and
                if (SearchOperator == 'eq' || SearchOperator == 'in')
                     cOperator = ' IN (';
                if (SearchOperator == 'ne' || SearchOperator == 'notin') 
                    cOperator = ' NOT IN (';
                cCloseCharacter = ')';
            }
        } 
        else 
        {
            if (SearchOperator == 'eq') cOperator = '=';
            if (SearchOperator == 'ne') cOperator = '<>';
        }
        
        if (SearchOperator == 'gt') cOperator = '>';
        if (SearchOperator == 'lt') cOperator = '<';
        if (SearchOperator == 'ge') cOperator = '>=';
        if (SearchOperator == 'le') cOperator = '<=';
        
        if (fldType == Schema.DisplayType.STRING || fldType == Schema.DisplayType.REFERENCE || fldType == Schema.DisplayType.EMAIL || fldType == Schema.DisplayType.PICKLIST || fldType == Schema.DisplayType.MULTIPICKLIST || fldType == Schema.DisplayType.TEXTAREA) {
            if (SearchOperator == 'starts') { cOperator = ' LIKE \''; cCloseCharacter = '%\''; }
            if (SearchOperator == 'contains') { cOperator = ' LIKE \'%'; cCloseCharacter = '%\''; }
            if (SearchOperator == 'notcontain') {
                // NOT LIKE requires parenthesis around the whole condition, including the fieldname 
                cWhereClause = ' (NOT(' + searchField ; 
                cOperator = ' LIKE \'%'; 
                cCloseCharacter = '%\'))'; 
            }
            if (SearchOperator == 'in' && fldType == Schema.DisplayType.MULTIPICKLIST) { cOperator = ' INCLUDES ('; cCloseCharacter = ')'; }
            if (SearchOperator == 'notin' && fldType == Schema.DisplayType.MULTIPICKLIST) { cOperator = ' EXCLUDES ('; cCloseCharacter = ')'; }
            if (SearchOperator == 'in' && fldType <> Schema.DisplayType.MULTIPICKLIST) { cOperator = ' IN ('; cCloseCharacter = ')'; }
            if (SearchOperator == 'notin' && fldType <> Schema.DisplayType.MULTIPICKLIST) { cOperator = ' NOT IN ('; cCloseCharacter = ')'; }
        }
        cWhereClause += cOperator;
        
        if (cOperator == '') {
            AddException(ExpressionName, getTAG002() + ': '+ FieldApiLable.get(searchField));
            isValidCri = false;
            showPageError = true;
            return '';
        }
                
        if (fldType == Schema.DisplayType.STRING || fldType == Schema.DisplayType.REFERENCE || fldType == Schema.DisplayType.EMAIL || fldType == Schema.DisplayType.PICKLIST || fldType == Schema.DisplayType.MULTIPICKLIST || fldType == Schema.DisplayType.TEXTAREA) {
        
            if (cCloseCharacter.startsWith('%')) {
                cWhereClause += fldValue ;
            } else if (!fldValue.contains(',')) {
                cWhereClause += '\'' + fldValue + '\'';
            } else {
                String[] multValues = fldValue.split(',');
                for (String v : multValues) {
                    cWhereClause += '\'' + v.trim() + '\',';
                }
                cWhereClause = cWhereClause.subString(0, cWhereClause.length()-1);
            }
        } 
        else if (fldType == Schema.DisplayType.DATE || fldType == Schema.DisplayType.DATETIME) 
        {
            if (fldValue.toUpperCase().equals('THIS_WEEK') || fldValue.toUpperCase().equals('THIS_MONTH') || fldValue.toUpperCase().equals('NEXT_WEEK') || fldValue.toUpperCase().equals('NEXT_MONTH') || fldValue.toUpperCase().equals('LAST_WEEK') || fldValue.toUpperCase().equals('LAST_MONTH') || fldValue.toUpperCase().equals('NEXT_90_DAYS') || fldValue.toUpperCase().equals('LAST_90_DAYS')) 
            {
                if(ExpressionType == 'UPDATES')
                {
                    isValidCri = false;
                    showPageError = true;
                    AddException(ExpressionName, getTAG003()+ ': '+ FieldApiLable.get(searchField));
                    return '';
                }
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
                        AddException(ExpressionName, getTAG003() + ': '+ FieldApiLable.get(searchField));
                        isValidCri = false;
                        showPageError = true;
                        return '';
                    }
                }
                catch(exception ex)
                {
                    AddException(ExpressionName, getTAG003());
                    isValidCri = false;
                    showPageError = true;
                    return '';
                }
            }
            else if (fldValue.toUpperCase().equals('SVMX.NOW') || fldValue.toUpperCase().equals('TODAY') || fldValue.toUpperCase().equals('YESTERDAY') || fldValue.toUpperCase().equals('TOMORROW')) 
            {
            }
            else 
            {
                try 
                {
                    date testDate = StringToDate(fldValue);
                    // Rebuild the date String as YYYY-MM-DD
                    String m = testDate.month().format();
                    String d = testDate.day().format();
                    if (integer.valueOf(m) < 10) m = '0' + m;
                    if (integer.valueOf(d) < 10) d = '0' + d;
                    fldValue = testDate.year() + '-' + m + '-' + d;
                    
                    // For DATETIME types, must add the hours AND we need to make it a compound condition
                    //     (field >= START AND field <= END)
                    // Example: field = 12/31/2008 will be translated to
                    //      field >= 2008-12-31T00:00:00Z AND field <= 2008-12-31T23:59:59Z 
                    if (fldType == Schema.DisplayType.DATETIME) {
                        // This creates a DateTime at midnight in the users current timezone 
                        datetime testDateTm = datetime.newInstance(testDate.year(), testDate.month(),testDate.day());
                        
                        // If the operator is equals/not equals then need a range for the entire day
                        // if the operator is greater or less, then we can just use the datetime
                        // but we'll need to adjust based on midnight or 23:59:59pm
                        if (cOperator == '=') 
                        {
                            cWhereClause = ' (' + searchField + ' >= ';                         
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
                }
                catch (exception ex) 
                {
                    AddException(ExpressionName, getTAG003()+ ': '+ FieldApiLable.get(searchField)); 
                    isValidCri = false;
                    showPageError = true;
                    return '';
                }
            }    
            cWhereClause += fldValue.replace(' ', ' ').toUpperCase();
        } 
        else if (fldType == Schema.DisplayType.CURRENCY || fldType == Schema.DisplayType.DOUBLE || fldType == Schema.DisplayType.BOOLEAN) 
            cWhereClause += fldValue ;
        else 
            cWhereClause += '\'' + fldValue + '\''; 
        cWhereClause += cCloseCharacter ;
        if (cWhereClause <> null) {showPageError = false; return cWhereClause; } else { return ''; }
    }
    
    // Convert a Date String to a Date type using the IntputDateFormat value
    // to determine how the date format is constructed
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
        if (InputDateFormat.subString(0,2) == 'YY') 
        { 
            y = Integer.valueOf(StringDate[0]);
            m = Integer.valueOf(StringDate[1]);
            d = Integer.valueOf(StringDate[2]);
        }
        
        if (y < 100 && y > 80) y += 1900;
        if (y < 100) y += 2000;
        return date.newInstance(y,m,d); 
    }
    public class expression
    {
        public Integer Sequence;
            public Integer getSequence(){return Sequence;}
            public void setSequence(Integer i){this.Sequence = i;}
        
        public string FieldName;
            public string getFieldName(){return FieldName;}
            public void setFieldName(string str){this.FieldName = str;}
        
        public string ObjectNameParentLookUpField;
            public string getObjectNameParentLookUpField()
            {
                return this.ObjectName+'~'+this.ParentLookUpField;
            }
            public void setObjectNameParentLookUpField(string str)
            {
                if(str == 'SVMX.NONE')
                    str = '';
                this.ObjectNameParentLookUpField = str;
                try
                {
                    list<string> lst = str.split('~');
                    if(lst != null && lst.size() > 1)
                    {
                        ObjectName = lst[0];
                        ParentLookUpField = lst[1];
                    }
                }
                catch(exception ex)
                {
                }
            }
        
        public string ObjectName;
            public string getObjectName(){return ObjectName;}
            public void setObjectName(string str){this.ObjectName = str;}
        
        public string ParentLookUpField;
            public string getParentLookUpField(){return ParentLookUpField;}
            public void setParentLookUpField(string str){this.ParentLookUpField = str;}
        
        public string ObjectNameField;
            public string getObjectNameField(){return ObjectNameField;}
            public void setObjectNameField(string str){this.ObjectNameField = str;}
        
        public string FieldType='';
            public string getFieldType(){return FieldType;}
            public void setFieldType(string str){this.FieldType = str;}
        
        public string Operator;
            public string getOperator(){return Operator;}
            public void setOperator(string str){this.Operator = str;}
        
        public string Operand;
            public string getOperand(){return Operand;}
            public void setOperand(string str){this.Operand = str;}
            
        /*public string OperandID;
            public string getOperandID(){if(FieldType.toUpperCase() == 'REFERENCE') return OperandID; else return Operand;}
            public void setOperandID(string str){this.OperandID = str;}*/
            
        public list<selectOption> Values = new list<selectOption>();
            public list<selectOption> getValues() {return this.Values;}
            public void setValues(list<selectOption> lst){this.Values = lst;}
        
        public string DefaultField='--None--'; //On 22Mar10, GM replaced '--None--' with getTAG005()
        
        public List<selectoption> FieldsList = new List<selectoption>();  
            public List<selectoption> getFieldsList()
            {
                if(FieldsList == null)
                    FieldsList = new List<selectoption>();
                if (FieldsList.size() == 0 ) 
                    FieldsList.add(new selectOption('SVMX.NONE', DefaultField)); 
                else if (FieldsList.size() > 0 && FieldsList[0].getValue() != null && FieldsList[0].getValue() != 'SVMX.NONE') //On 22Mar10 GM replaced: '' with 'SVMX.NONE'
                    FieldsList.add(0, new selectOption('SVMX.NONE', DefaultField));
                return FieldsList;
            }
            public void setFieldsList(List<selectoption> lst) {FieldsList=lst;}
        
        public list<SelectOption> OperatorSelectList = new list<SelectOption>();
            public List<SelectOption> getOperatorSelectList() 
            {
                List<SelectOption> options = new List<SelectOption>();
                options.add(new selectOption('SVMX.NONE' , '--None--')); //On 22Mar10, GM replaced '--None--' with getTAG005()
                options.add(new selectOption('set', 'Set'));
                options.add(new selectOption('increase', 'Increase'));
                options.add(new selectOption('decrease', 'Decrease'));
                return options;
            }
        public string ExpressionName = '';
        
        public expression()
        {
        }
        public expression(integer iSeq, string strFld, string strOpt, string strOpd, string strType, string strObjName, string strObjNameField, string strObjectName, string strParentLookUpField, string strDefaultField, string strExpressionName)
        {
            this.Sequence = iSeq;
            this.FieldName = strFld;
            this.Operator = strOpt;
            this.Operand = strOpd;
            this.FieldType = strType;
            this.DefaultField = strDefaultField;
            this.ObjectName = strObjectName;
            this.ParentLookUpField = strParentLookUpField;
            this.ExpressionName = strExpressionName;
            //this.OperandID = Operand;
            /*if( FieldType == 'REFERENCE')
            {
                if(strObjName != null && Operand != null &&  Operand != 'SVMX.NONE' && Operand != '')
                {
                    ObjectName = strObjName;
                    ObjectNameField = strObjNameField;
                    OperandID = Operand;
                    if(Operand  == 'SVMX.Owner' )
                    {
                        Operand = 'Record Owner';
                    }
                    else if(Operand  == 'SVMX.CurrentUser' )
                    {
                        Operand = 'Current User';   //By Gm replaced 'Current User' with 'SVMX.CurrentUser'
                    }
                    else
                    {
                        try
                        {
                            string operater = '=';
                            string cWhereClause = '';
                            if(Operand.contains(','))
                            {
                                operater = ' IN ';
                                String[] multValues = Operand.split(',');
                                for (String v : multValues) 
                                {
                                    system.debug('asdf'+v);
                                    if(cWhereClause.length() > 0)
                                        cWhereClause += ',\'' + string.escapeSingleQuotes(v.trim()) + '\'';
                                    else
                                        cWhereClause = '\'' + string.escapeSingleQuotes(v.trim()) + '\''; 
                                }   
                                cWhereClause = ' ( '+cWhereClause+' ) ';
                            }
                            else
                                cWhereClause = '\'' + string.escapeSingleQuotes(Operand)+ '\'';
                            system.debug('asdf'+'where id '+ operater + cWhereClause);
                            list<sObject> lsto = database.query('select ' + ObjectNameField + ' from ' + ObjectName +' where id '+ operater + cWhereClause );
                            if(lsto != null && lsto.size() > 0)
                            {
                                Operand = '';
                                for(sObject o: lsto)
                                {
                                    if(Operand.length() > 0)
                                        Operand += ', ' + (string)o.get(ObjectNameField);
                                    else
                                        Operand = (string)o.get(ObjectNameField);
                                }
                            }
                        }
                        catch (Exception ex)
                        {
                            AddException(ExpressionName , ex.getMessage());
                        }
                    }
                }
            }
            else if(FieldType == 'PICKLIST')
            {}*/
        }
        public void AddException(String StrExpressionName, string strMessage)
        {
            if(strMessage != null & strMessage.length() > 0)
            {
                if(StrExpressionName != null && StrExpressionName.length() > 0)
                    apexpages.addMessage(new apexpages.message(ApexPages.severity.ERROR, ExpressionName + ': '+ strMessage));
                else 
                    apexpages.addMessage(new apexpages.message(ApexPages.severity.ERROR, strMessage));
            }
            else 
            {
                if(StrExpressionName != null && StrExpressionName.length() > 0)
                    apexpages.addMessage(new apexpages.message(ApexPages.severity.ERROR, ExpressionName));
                else 
                    apexpages.addMessage(new apexpages.message(ApexPages.severity.ERROR, ''));
            }
        }
    }
    public void AddException(String StrExpressionName, string strMessage)
    {
        if(strMessage != null & strMessage.length() > 0)
        {
            if(StrExpressionName != null && StrExpressionName.length() > 0)
                apexpages.addMessage(new apexpages.message(ApexPages.severity.ERROR, ExpressionName + ': '+ strMessage));
            else 
                apexpages.addMessage(new apexpages.message(ApexPages.severity.ERROR, strMessage));
        }
        else 
        {
            if(StrExpressionName != null && StrExpressionName.length() > 0)
                apexpages.addMessage(new apexpages.message(ApexPages.severity.ERROR, ExpressionName));
            else 
                apexpages.addMessage(new apexpages.message(ApexPages.severity.ERROR, ''));
        }
    }
}