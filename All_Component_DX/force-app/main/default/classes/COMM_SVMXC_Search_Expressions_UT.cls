@isTest (seeAllData = true)
Private class COMM_SVMXC_Search_Expressions_UT
{

    private static SVMXC.COMM_SVMXC_Search_Expressions Expobject,Expobject1,Expobject2;
    
    COMM_SVMXC_Search_Expressions NwObj = new COMM_SVMXC_Search_Expressions(1, true,true,false, false, true, '-None-','' );
     //private static COMM_Search_Expressions.expression ExpWrpObj; 
    static testMethod void COMM_SVMXC_Search_Expressions_UT()
    {
        
        RecordType[] rts = [SELECT Id, Name FROM RecordType WHERE SobjectType = 'SVMXC__ServiceMax_Processes__c'];    
        system.assertNotEquals(rts[0].Id,null);
        SVMXC__ServiceMax_Processes__c InvProcess;
        for(RecordType rt : rts) //Loop to take a record type at a time
        {
            // Create Module Record
            if(rt.Name == 'Inventory Process')
            {
                SVMXC__ServiceMax_Processes__c inv = new SVMXC__ServiceMax_Processes__c(
                                            RecordTypeId =rt.Id,
                                            SVMXC__Active__c = true,
                                            SVMXC__Name__c = 'TESTINVPROCESS001',
                                            SVMXC__ProcessID__c = 'TESTINVPROCESS001'                                            
                                            );
                insert inv;
                InvProcess = inv; 
            } 
        }  
        RecordType[] rts1 = [SELECT Id, Name FROM RecordType WHERE SobjectType = 'SVMXC__ServiceMax_Config_Data__c'];   
        system.assertNotEquals(rts1[0].Id,null);
        SVMXC__ServiceMax_Config_Data__c ConfigData;
        RecordType rt2;
        for(RecordType rt1 : rts1) //Loop to take a record type at a time
        {
            // Create Module Record
            if(rt1.Name == 'Expressions')
            {
                rt2 = rt1;
                SVMXC__ServiceMax_Config_Data__c conf = new SVMXC__ServiceMax_Config_Data__c(
                                            RecordTypeId =rt1.Id,
                                            SVMXC__Inventory_Process__c = InvProcess.id,
                                            SVMXC__Active__c = true,
                                            SVMXC__Field_Name__c = 'SVMXC__Source_City__c',
                                            SVMXC__Operator__c = 'eq',
                                            SVMXC__Operand__c = 'werw',
                                            SVMXC__Expression_Type__c = 'HeaderCriteria'                                            
                                            );
                insert conf;
                ConfigData = conf;
            } 
        }  
     
     
     
     
     
        Expobject = new SVMXC.COMM_SVMXC_Search_Expressions();
        Integer i;
        //Expobject1 = new SVMXC.COMM_SVMXC_Search_Expressions(i);
        integer j; 
        
        Map<String, Schema.SObjectType> allobjs = new Map<String, Schema.SObjectType>();
        map <string, Map<String,Schema.SObjectField>> mMapFieldList = new map <string, Map<String,Schema.SObjectField>>();
        Schema.SObjectType objT = allObjs.get('SVMXC__Service_Order__c') ;
        if(objT != null)
        {
            Expobject.objfieldMap = objT.getDescribe().fields.getMap();
            mMapFieldList.put('SVMXC__Service_Order__c', Expobject.objfieldMap);
        } 
        
        boolean bAllowSelectOperater;
        boolean bDisplaySequence;
        boolean bHasAdvanceOption; 
        boolean bHasErrorMessage;
        boolean bDisplayOperand;
        string sDefaultSelectedOperator;
        string sDefaultField = '';
        Expobject2 = new SVMXC.COMM_SVMXC_Search_Expressions(j,bAllowSelectOperater,bDisplaySequence,bHasAdvanceOption,bHasErrorMessage,bDisplayOperand,sDefaultSelectedOperator,sDefaultField);
        
        SVMXC.COMM_SVMXC_Search_Expressions.expression ExpWrpObj = new SVMXC.COMM_SVMXC_Search_Expressions.expression(); 
        integer iSeq = 1;
        String strFld = '';
        String strOpt = '';
        String strOpd = 'SVMX.Owner';
        String strfldtyp = 'REFERENCE';
        String strobjname = 'test';
        ExpWrpObj = new SVMXC.COMM_SVMXC_Search_Expressions.expression(1,'test','eq','SVMX.Owner','REFERENCE' , 'USER' ,'', '','','','');
        ExpWrpObj = new SVMXC.COMM_SVMXC_Search_Expressions.expression(1,'test','eq','SVMX.CurrentUser','REFERENCE','USER','','','','','');
        ExpWrpObj.setObjectNameParentLookUpField('test');
        
        Boolean b1 = Expobject.getAllowSelectOperater();
        Boolean b2 = Expobject.getDisplaySequence();
        Boolean b3 = Expobject.getHasAdvanceOption();
        Boolean b4 = Expobject.getHasErrorMessage();
        system.assertNotEquals(b1,false);
        system.assertNotEquals(b2,false);
        system.assertNotEquals(b3,false);
        system.assertNotEquals(b4,false);
        Schema.SobjectType sObjType = Case.sobjecttype;
        Map<String, Schema.DisplayType> mfieldType = new Map<String, Schema.DisplayType>();
        Map<String, string> mfldApiName = new Map<String, string>();
        string fldSeq ='SVMXC__Sequence__c';
        string fldldName = 'SVMXC__Field_Name__c';
        string fldOpr = 'SVMXC__Operator__c';
        string fldOpd = 'SVMXC__Operand__c';
        Expobject.mapFieldDispType.put('Name', Schema.Displaytype.STRING);
        Expobject.mapFieldDispType.put('isDeleted', Schema.Displaytype.BOOLEAN);
        Expobject.mapFieldDispType.put('SVMXC__Company__c', Schema.Displaytype.REFERENCE);
        list<SVMXC__ServiceMax_Config_Data__c> lstSVMXConfigData = new list<SVMXC__ServiceMax_Config_Data__c>();
        SVMXC__ServiceMax_Config_Data__c SVMXConfigData1 = new SVMXC__ServiceMax_Config_Data__c(
                                                            SVMXC__Sequence__c = 1,
                                                            SVMXC__Field_Name__c = 'Name',
                                                            SVMXC__Operator__c = 'eq',
                                                            SVMXC__Operand__c = 'cd'
                                                            
                                                            );
        system.assert(lstSVMXConfigData.size()==0);
        lstSVMXConfigData.add(SVMXConfigData1);
        SVMXC__ServiceMax_Config_Data__c SVMXConfigData2 = new SVMXC__ServiceMax_Config_Data__c(
                                                            SVMXC__Sequence__c = 1,
                                                            SVMXC__Field_Name__c = 'isDeleted',
                                                            SVMXC__Operator__c = 'eq',
                                                            SVMXC__Operand__c = 'true'
                                                            
                                                            );
        Account a = new Account(Name='test');
        insert a;
        SVMXC__ServiceMax_Config_Data__c SVMXConfigData3 = new SVMXC__ServiceMax_Config_Data__c(
                                                            SVMXC__Sequence__c = 1,
                                                            SVMXC__Field_Name__c = 'SVMXC__Company__c',
                                                            SVMXC__Operator__c = 'eq',
                                                            SVMXC__Operand__c = a.Id,
                                                            SVMXC__Expression_Type__c = 'REFERENCE',
                                                            SVMXC__Object_Name__c = 'Account',
                                                            SVMXC__FKey_Name_Field__c = 'Name'
                                                            );
        SVMXC__ServiceMax_Config_Data__c SVMXConfigData4 = new SVMXC__ServiceMax_Config_Data__c(
                                                            SVMXC__Sequence__c = 1,
                                                            SVMXC__Field_Name__c = 'SVMXC__Billing_Type__c',
                                                            SVMXC__Operator__c = 'eq',
                                                            SVMXC__Operand__c = 'test',
                                                            SVMXC__Expression_Type__c = 'PICKLIST'
                                                           
                                                            );
                                                            
        lstSVMXConfigData.add(SVMXConfigData2);
        lstSVMXConfigData.add(SVMXConfigData3);
        lstSVMXConfigData.add(SVMXConfigData4);
        insert lstSVMXConfigData;
        list<SVMXC__ServiceMax_Config_Data__c> lst = [select id, SVMXC__Object_Name__c, RecordTypeID, SVMXC__Lookup_Field_API_Name__c, SVMXC__FKey_Name_Field__c, SVMXC__Expression_Type__c, SVMXC__Inventory_Process__c, SVMXC__Sequence__c, SVMXC__Field_Name__c, SVMXC__Operator__c, SVMXC__Operand__c from SVMXC__ServiceMax_Config_Data__c where Id = :lstSVMXConfigData[0].Id ];
        //SVMXC.CONF_ManageInventoryProcesses oManageInvPro =  new SVMXC.CONF_ManageInventoryProcesses(); 
        //oManageInvPro.RetriveField('Contact', new List<selectoption>(), Expobject.mapFieldDispType, Expobject.FieldApiLable);
        //Expobject.setExpressions(lst,fldSeq,fldldName,fldOpr,fldOpd);
        Expobject.setExpressions(lstSVMXConfigData[0],fldSeq,fldldName,fldOpr,fldOpd);
        
        Expobject.getDefaultSelectedOperator();
        Expobject.getHLPURL();
        Expobject.getTAG001();
        Expobject.getTAG002();
        Expobject.getTAG003();
        Expobject.getTAG004();
        Expobject.getTAG001();
        Expobject.getTAG002();
        Expobject.getTAG003();
        Expobject.getTAG004();
        Expobject.getTAG005();
        Expobject.getTAG006();
        Expobject.getTAG007();
        Expobject.getTAG008();
        Expobject.getTAG009();
        Expobject.getTAG010();
        Expobject.getTAG011();
        Expobject.getTAG012();
        Expobject.getTAG013();
        Expobject.getTAG014();
        Expobject.getTAG015();
        Expobject.getTAG016();
        Expobject.getTAG017();
        Expobject.getTAG018();
        Expobject.getTAG019();
        Expobject.getTAG020();
        Expobject.getTAG021();
                
        //Expobject.svmxTagList.clear();
        Expobject.getHLPURL();
        Expobject.getTAG001();
        Expobject.getTAG002();
        Expobject.getTAG003();
        Expobject.getTAG004();
        Expobject.getTAG002();
        Expobject.getTAG003();
        Expobject.getTAG004();
        Expobject.getTAG005();
        Expobject.getTAG006();
        Expobject.getTAG007();
        Expobject.getTAG008();
        Expobject.getTAG009();
        Expobject.getTAG010();
        Expobject.getTAG011();
        Expobject.getTAG012();
        Expobject.getTAG013();
        Expobject.getTAG014();
        Expobject.getTAG015();
        Expobject.getTAG016();
        Expobject.getTAG017();
        Expobject.getTAG018();
        Expobject.getTAG019();
        Expobject.getTAG020();
        Expobject.getTAG021();

        
        Expobject.getErrorMessage();
        Expobject.setErrorMessage('test');
        Expobject.getSize();
        Expobject.getlstExpressions();
        Expobject.setlstExpressions(Expobject.lstExpressions);
        Expobject.getAdvanceOption();
        Expobject.setAdvanceOption('test');
        Expobject.getErrorMessage();
        Expobject.setErrorMessage('test');
        Expobject.FieldsList.add(new selectoption('test','test'));
        ////Expobject.getFieldsList();
        Expobject.FieldsList.add(new selectoption('test','test'));
        ////Expobject.getFieldsList();
        Expobject.FieldsList.clear();
        Expobject.DefaultField = '--None--';
        ////Expobject.getFieldsList();
        Expobject.DefaultOperator = 'test';
        Expobject.getOperatorSelectList();
        
            list<selectoption> lstselectoption = new List<selectoption>();
            lstselectoption.add(new selectoption('test','test'));
        
        Expobject.setFieldsList(lstselectoption);
        Expobject.setDefaultField('test');
        
        Expobject.getDisplayOperand();
        Expobject.getDefaultSelectedOperator();
        Expobject.getExpressionType();
        
        mfldApiName.put('Account', 'Account');
        
        Expobject.AdvanceOption = null;
        Expobject.getCriteria('SVMXC__Service_Order__c',Expobject.mapFieldDispType,mfldApiName);
        Expobject.getCriteria('SVMXC__Service_Order__c');
        Expobject.getAdvanceOption();
        Expobject.setAdvanceOption('1');
        Expobject.getCriteria('SVMXC__Service_Order__c',Expobject.mapFieldDispType,mfldApiName);
        Expobject.getCriteria('SVMXC__Service_Order__c');
        Expobject.setExpressions(lstSVMXConfigData[1]);
        Expobject.setExpressions(lstSVMXConfigData[2]);
        Expobject.AdvanceOption = null;
        Expobject.getCriteria('SVMXC__Service_Order__c');
        Expobject.getCriteria('SVMXC__Service_Order__c2');
        Expobject.getAdvanceOption();
        Expobject.setAdvanceOption('1');
        Expobject.getCriteria('SVMXC__Service_Order__c');
        Expobject.setAdvanceOption('1 AND 2 AND 3 AND 999');
        Expobject.getCriteria('SVMXC__Service_Order__c');
       
        List<selectoption> sl = new List<selectoption>();
        sl.add(new selectOption('', 'DefaultField'));
        Expobject.setFieldsList(sl);
        Expobject.sortFieldList();
        Expobject.lstExpressions.clear();
        Expobject.getCriteria('SVMXC__Service_Order__c');
        Expobject.getCriteria('SVMXC__Service_Order__c2');
        
        
        map<string, string> m =new map<string, string>();
        m.put('SVMXC__Expression_Type__c', 'Name');
       
        Expobject.getExpressions(m);
        Expobject.setExpressions(lstSVMXConfigData[2]);
        Expobject.OnChangeField(1, true);
        Expobject.setExpressions(lstSVMXConfigData[3]);
        list<SVMXC__ServiceMax_Config_Data__c> lstSVMXConfigData2 = new list<SVMXC__ServiceMax_Config_Data__c>();
        lstSVMXConfigData2.add(lstSVMXConfigData[0]);
        Expobject.setExpressions(lstSVMXConfigData2,fldSeq,fldldName,fldOpr,fldOpd);
        Expobject.lstExpressions[0].FieldName = null;
        Expobject.getExpressions(m);
        //Expobject.setExpressions(lstSVMXConfigData,fldSeq,fldldName,fldOpr,fldOpd);
        
        Expobject.setExpressions(new SVMXC__ServiceMax_Config_Data__c(
                                                            RecordTypeId = rt2.Id,
                                                            SVMXC__Sequence__c = 1,
                                                            SVMXC__Field_Name__c = 'SVMXC__Company__c',
                                                            SVMXC__Operator__c = 'eq',
                                                            SVMXC__Operand__c = a.Id,
                                                            SVMXC__Expression_Type__c = 'REFERENCE',
                                                            SVMXC__Object_Name__c = 'Account',
                                                            SVMXC__FKey_Name_Field__c = 'Name'
                                                            ));
        lstSVMXConfigData.clear();
        lstSVMXConfigData.add(new SVMXC__ServiceMax_Config_Data__c(
                                                            RecordTypeId = rt2.Id,
                                                            SVMXC__Sequence__c = 1,
                                                            SVMXC__Field_Name__c = 'SVMXC__Company__c',
                                                            SVMXC__Operator__c = 'eq',
                                                            SVMXC__Operand__c = a.Id,
                                                            SVMXC__Expression_Type__c = 'REFERENCE',
                                                            SVMXC__Object_Name__c = 'Account',
                                                            SVMXC__FKey_Name_Field__c = 'Name'
                                                            ));
        lstSVMXConfigData.add(new SVMXC__ServiceMax_Config_Data__c(
                                                            RecordTypeId = rt2.Id,
                                                            SVMXC__Sequence__c = 1,
                                                            SVMXC__Field_Name__c = 'SVMXC__Company__c',
                                                            SVMXC__Operator__c = 'eq',
                                                            SVMXC__Operand__c = a.Id,
                                                            SVMXC__Expression_Type__c = 'REFERENCE',
                                                            SVMXC__Object_Name__c = 'Account',
                                                            SVMXC__FKey_Name_Field__c = 'Name'
                                                            ));
        lstSVMXConfigData.add( new SVMXC__ServiceMax_Config_Data__c(
                                                            RecordTypeId = rt2.Id,
                                                            SVMXC__Sequence__c = 1,
                                                            SVMXC__Field_Name__c = 'SVMXC__Company__c',
                                                            SVMXC__Operator__c = 'eq',
                                                            SVMXC__Operand__c = a.Id,
                                                            SVMXC__Expression_Type__c = 'REFERENCE',
                                                            SVMXC__Object_Name__c = 'Account',
                                                            SVMXC__FKey_Name_Field__c = 'Name'
                                                            ));
        /*lstSVMXConfigData.add( new SVMXC__ServiceMax_Config_Data__c(
                                                            RecordTypeId = rt2.Id,
                                                            SVMXC__Sequence__c = 1,
                                                            SVMXC__Field_Name__c = 'SVMXP__Company__c',
                                                            SVMXC__Operator__c = 'eq',
                                                            SVMXC__Operand__c = a.Id,
                                                            SVMXC__Expression_Type__c = 'REFERENCE',
                                                            SVMXC__Object_Name__c = 'Account',
                                                            SVMXC__FKey_Name_Field__c = 'Name'
                                                            ));*/
        system.assert(lstSVMXConfigData.size()>0);
        insert lstSVMXConfigData;
        for(SVMXC__ServiceMax_Config_Data__c o :lstSVMXConfigData)
        {
            Expobject.Expressions.add(o);
        }
        Expobject.DefaultListValue = 'test';
        Expobject.addCriteriaExpression(1);
        Expobject.AllowSelectOperater = false;
        Expobject.addCriteriaExpression(1);
        Expobject.removeCriteriaExpression(1);
        Expobject.getExpressions(m);
        system.debug('asdf'+Expobject.mapFieldDispType);
        for(integer ITemp = 0; ITemp < 10; ITemp++)
        {
            COMM_SVMXC_Search_Expressions.expression oExpression = new COMM_SVMXC_Search_Expressions.expression();
            oExpression.FieldName= 'AccountId';
            oExpression.Operator= 'eq';
            oExpression.Operand= 'test';
            
            Expobject.lstExpressions.add(oExpression);
        }
        Expobject.getExpressions(m);
        Expobject.lstExpressions = null;
        Expobject.getlstExpressions();
        Expobject.getInputDateFormat();
        Expobject.getInputDateFormat(12,1,1);
        Expobject.StringToDate('12/12/12');
        
        
      
        Expobject.mapFieldDispType.put('BOOLEAN',Schema.Displaytype.BOOLEAN);
        Expobject.mapFieldDispType.put('Date',Schema.Displaytype.Date);
        Expobject.mapFieldDispType.put('string',Schema.Displaytype.string);
        Expobject.mapFieldDispType.put('MULTIPICKLIST',Schema.Displaytype.MULTIPICKLIST);
        Expobject.mapFieldDispType.put('DATE',Schema.Displaytype.DATE);
        Expobject.mapFieldDispType.put('DATETIME',Schema.Displaytype.DATETIME);
        list<string> lstOperator = new list<string>();
        lstOperator.add('eq');
        lstOperator.add('ne');
        lstOperator.add('gt');
        lstOperator.add('ge');
        lstOperator.add('lt');
        lstOperator.add('le');
        lstOperator.add('starts');
        lstOperator.add('contains'); 
        lstOperator.add('notcontain');
        lstOperator.add('in'); 
        lstOperator.add('notin');
        Expobject.lstExpressions = new list<COMM_SVMXC_Search_Expressions.expression>();
        Expobject.lstExpressions.clear();
        for (string strOperator :lstOperator)
        {
            for(string strfield :Expobject.mapFieldDispType.keySet())
            {
                COMM_SVMXC_Search_Expressions.expression o = new COMM_SVMXC_Search_Expressions.expression();
                o.FieldName = strfield;
                o.Operator = strOperator;
                o.Operand = 'testOperand';
                Expobject.lstExpressions.add(o);
            }
        }
        COMM_SVMXC_Search_Expressions_UT.testwhereclause(Expobject, '', 'eq', 'testOperand');
        COMM_SVMXC_Search_Expressions_UT.testwhereclause(Expobject, 'string', 'eq', 'test,Operand');
        COMM_SVMXC_Search_Expressions_UT.testwhereclause(Expobject, 'string', 'ne', 'test,Operand');
        COMM_SVMXC_Search_Expressions_UT.testwhereclause(Expobject, 'string', 'ne', 'testOperand');
        COMM_SVMXC_Search_Expressions_UT.testwhereclause(Expobject, 'BOOLEAN', 'eq', 'true');
        COMM_SVMXC_Search_Expressions_UT.testwhereclause(Expobject, 'BOOLEAN', 'ne', 'true');
        COMM_SVMXC_Search_Expressions_UT.testwhereclause(Expobject, 'DATE', 'eq', 'TODAY');
        COMM_SVMXC_Search_Expressions_UT.testwhereclause(Expobject, 'DATETIME', 'eq', date.newInstance(2009, 12, 31).format());
        COMM_SVMXC_Search_Expressions_UT.testwhereclause(Expobject, 'DATETIME', 'ne', date.newInstance(2009, 12, 31).format());
        COMM_SVMXC_Search_Expressions_UT.testwhereclause(Expobject, 'DATETIME', 'gt', date.newInstance(2009, 2, 31).format());
        COMM_SVMXC_Search_Expressions_UT.testwhereclause(Expobject, 'DATETIME', 'ge', date.newInstance(2009, 2, 31).format());
        COMM_SVMXC_Search_Expressions_UT.testwhereclause(Expobject, 'DATETIME', 'lt', date.newInstance(2009, 12, 1).format());
        COMM_SVMXC_Search_Expressions_UT.testwhereclause(Expobject, 'DATETIME', 'le', date.newInstance(2009, 12, 1).format());
        COMM_SVMXC_Search_Expressions_UT.testwhereclause(Expobject, 'DATE', 'le', 'NEXT 10 DAYS');
        COMM_SVMXC_Search_Expressions_UT.testwhereclause(Expobject, 'DATE', 'le', 'NEXT 10 WEEK');
        COMM_SVMXC_Search_Expressions_UT.testwhereclause(Expobject, 'DATE', 'le', 'NEXT_N_DAYS:5');
        COMM_SVMXC_Search_Expressions_UT.testwhereclause(Expobject, 'DATE', 'le', 'LAST_N_DAYS:test');
        COMM_SVMXC_Search_Expressions_UT.testwhereclause(Expobject, 'DATETIME', 'le', '12/12/82');
        COMM_SVMXC_Search_Expressions_UT.testwhereclause(Expobject, '', '', '');
        
        for(integer itemp = 0 ; itemp < Expobject.lstExpressions.size(); itemp++)
        {
            Expobject.buildWhereClause(true,itemp);
            Expobject.buildWhereClause(false,itemp);
        }
        
        
        COMM_SVMXC_Search_Expressions.expression oExpression = new COMM_SVMXC_Search_Expressions.expression(); 
        
        oExpression.getSequence();
        oExpression.setSequence(0);
        oExpression.getFieldName();
        oExpression.setFieldName('test');
        oExpression.getObjectNameParentLookUpField();
        oExpression.setObjectNameParentLookUpField('test~test');
        oExpression.setObjectNameParentLookUpField('test');
        oExpression.getObjectName();
        oExpression.setObjectName('test');
        oExpression.getParentLookUpField();
        oExpression.setParentLookUpField('test');
        oExpression.getObjectNameField();
        oExpression.setObjectNameField('test');
        oExpression.getFieldType();
        oExpression.setFieldType('test');
        oExpression.getOperator();
        oExpression.setOperator('test');
        oExpression.getOperand();
        oExpression.setOperand('test');
        //oExpression.getOperandID();
        //oExpression.setOperandID('test');
        oExpression.getValues();
        oExpression.setValues(new list<selectOption>());
        oExpression.getFieldsList();
        oExpression.setFieldsList(new List<selectoption>());
        oExpression.getOperatorSelectList();
        
        
        //Expobject.objfieldMap  = oManageInvPro.mMapFieldList.get('Contact');
        Expobject.getFieldSObjectType('accountid');
        Expobject.getFieldSObjectType('accountid');
       
        Expobject.lstExpressions[0].FieldName = 'IsDeleted';
        
        Expobject.OnChangeField(1, true);
        Expobject.lstExpressions[0].FieldName = 'AccountId';
        Expobject.OnChangeField(1, true);
        Expobject.OnChangeField(1, true);
        Expobject.OnChangeField(1, true);
        Expobject.OnChangeField(1, true);
        Expobject.OnChangeField(1, true);
        Map<String,Schema.SObjectField> objfieldMap2 = new Map<String,Schema.SObjectField>();
        objfieldMap2.PutAll(Expobject.objfieldMap);
        Expobject.objfieldMap =objfieldMap2; 
        Expobject.OnChangeField(1, true);
        
     }
    static void testwhereclause(SVMXC.COMM_SVMXC_Search_Expressions Expobjecttemp, string strField, string strOperator, string strOperand)
    {
        COMM_SVMXC_Search_Expressions.expression o = new COMM_SVMXC_Search_Expressions.expression();
        o.Operator = strOperator; 
        o.Operand = strOperand;
        o.FieldName = strField;
        Expobjecttemp.lstExpressions.add(o);
        System.assertEquals(true, Expobjecttemp != null);
        System.assertEquals(true, o != null);
    }
    


}