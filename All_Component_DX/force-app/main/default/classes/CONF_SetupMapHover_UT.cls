/**
 * This class contains unit tests for validating the behavior of Apex classes
 * and triggers.
 *
 * Unit tests are class methods that verify whether a particular piece
 * of code is working properly. Unit test methods take no arguments,
 * commit no data to the database, and are flagged with the testMethod
 * keyword in the method definition.
 *
 * All test methods in an organization are executed whenever Apex code is deployed
 * to a production organization to confirm correctness, ensure code
 * coverage, and prevent regressions. All Apex classes are
 * required to have at least 75% code coverage in order to be deployed
 * to a production organization. In addition, all triggers must have some code coverage.
 * 
 * The @isTest class annotation indicates this class only contains test
 * methods. Classes defined with the @isTest annotation do not count against
 * the organization size limit for all Apex scripts.
 *
 * See the Apex Language Reference for more information about Testing and Code Coverage.
 */
@isTest
private class CONF_SetupMapHover_UT {

    static testMethod void CONF_SetupMapHoverTest1() {
        // TO DO: implement unit test
        
        //Create Data.
        list<RecordType> lstRecordType = new list<RecordType>();
        String strRuleRtypeId = '';
        String strExpressionRTypeId = '';
        lstRecordType = [Select Id, Name from RecordType WHERE SObjectType='SVMXC__ServiceMax_Processes__c' OR SObjectType='SVMXC__ServiceMax_Config_Data__c'];
        if(lstRecordType.size() > 0)
        {
            for(RecordType r : lstRecordType)
            {
                if(r.Name == 'SVMX Rule')
                    strRuleRtypeId = r.id;
                if(r.Name == 'Expressions')
                    strExpressionRTypeId = r.id;    
            }    
        }
        SVMXC__ServiceMax_Processes__c objProcess = new SVMXC__ServiceMax_Processes__c();
        objProcess.RecordTypeId = strRuleRtypeId;
        objProcess.SVMXC__Rule_Type__c = 'Column Info'; 
        objProcess.SVMXC__Source_Object_Name__c = 'SVMXC__Service_Order__c'; 
        objProcess.SVMXC__Name__c = 'Hover 1';  
        insert objProcess;
        SVMXC__ServiceMax_Processes__c objProcess1 = new SVMXC__ServiceMax_Processes__c();
        objProcess1.RecordTypeId = strRuleRtypeId;
        objProcess1.SVMXC__Rule_Type__c = 'Column Info'; 
        objProcess1.SVMXC__Source_Object_Name__c = 'SVMXC__Site__c'; 
        objProcess1.SVMXC__Name__c = 'Hover 2';
        insert objProcess1; 
        SVMXC__ServiceMax_Processes__c objProcess2 = new SVMXC__ServiceMax_Processes__c();
        objProcess2.RecordTypeId = strRuleRtypeId;
        objProcess2.SVMXC__Rule_Type__c = 'Column Info'; 
        objProcess2.SVMXC__Source_Object_Name__c = 'Account'; 
        objProcess2.SVMXC__Name__c = 'Hover 3';
        insert objProcess2;  
        SVMXC__ServiceMax_Processes__c objProcess3 = new SVMXC__ServiceMax_Processes__c();
        objProcess3.RecordTypeId = strRuleRtypeId;
        objProcess3.SVMXC__Rule_Type__c = 'Column Info'; 
        objProcess3.SVMXC__Source_Object_Name__c = 'SVMXC__Service_Group_Members__c'; 
        objProcess3.SVMXC__Name__c = 'Hover 4';
        insert objProcess3;  
        SVMXC__ServiceMax_Processes__c objProcess4 = new SVMXC__ServiceMax_Processes__c();
        objProcess4.RecordTypeId = strRuleRtypeId;
        objProcess4.SVMXC__Rule_Type__c = 'Column Info'; 
        objProcess4.SVMXC__Source_Object_Name__c = 'SVMXC__Service_Group__c'; 
        objProcess4.SVMXC__Name__c = 'Hover 5';
        insert objProcess4; 
        list<SVMXC__ServiceMax_Config_Data__c> lstConfigData = new list<SVMXC__ServiceMax_Config_Data__c>();
        SVMXC__ServiceMax_Config_Data__c configdata = new SVMXC__ServiceMax_Config_Data__c();
        configdata.RecordTypeId = strExpressionRTypeId;
        configdata.SVMXC__Expression_Rule__c  = objProcess.id;
        configdata.SVMXC__Expression_Type__c = 'Column Field';
        configdata.SVMXC__Field_Name__c = 'Name';
        configdata.SVMXC__Display_Type__c = 'STRING';
        configdata.SVMXC__Sequence__c=1.0000;
        lstConfigData.add(configdata);
        SVMXC__ServiceMax_Config_Data__c configdata1 = new SVMXC__ServiceMax_Config_Data__c();
        configdata1.RecordTypeId = strExpressionRTypeId;
        configdata1.SVMXC__Expression_Rule__c  = objProcess1.id;
        configdata1.SVMXC__Expression_Type__c = 'Column Field';
        configdata1.SVMXC__Field_Name__c = 'Name';
        configdata1.SVMXC__Display_Type__c = 'STRING';
        configdata1.SVMXC__Sequence__c=1.0000;
        lstConfigData.add(configdata1);
        SVMXC__ServiceMax_Config_Data__c configdata2 = new SVMXC__ServiceMax_Config_Data__c();
        configdata2.RecordTypeId = strExpressionRTypeId;
        configdata2.SVMXC__Expression_Rule__c  = objProcess2.id;
        configdata2.SVMXC__Expression_Type__c = 'Column Field';
        configdata2.SVMXC__Field_Name__c = 'Name';
        configdata2.SVMXC__Display_Type__c = 'STRING';
        configdata2.SVMXC__Sequence__c=1.0000;
        lstConfigData.add(configdata2);
        SVMXC__ServiceMax_Config_Data__c configdata3 = new SVMXC__ServiceMax_Config_Data__c();
        configdata3.RecordTypeId = strExpressionRTypeId;
        configdata3.SVMXC__Expression_Rule__c  = objProcess3.id;
        configdata3.SVMXC__Expression_Type__c = 'Column Field';
        configdata3.SVMXC__Field_Name__c = 'Name';
        configdata3.SVMXC__Display_Type__c = 'STRING';
        configdata3.SVMXC__Sequence__c=1.0000;
        lstConfigData.add(configdata3);
        SVMXC__ServiceMax_Config_Data__c configdata4 = new SVMXC__ServiceMax_Config_Data__c();
        configdata4.RecordTypeId = strExpressionRTypeId;
        configdata4.SVMXC__Expression_Rule__c  = objProcess.id;
        configdata4.SVMXC__Expression_Type__c = 'Column Field';
        configdata4.SVMXC__Field_Name__c = 'SVMXC__Company__c';
        configdata4.SVMXC__Display_Type__c = 'REFERENCE';
        configdata4.SVMXC__Sequence__c=2.0000;
        lstConfigData.add(configdata4);
        SVMXC__ServiceMax_Config_Data__c configdata5 = new SVMXC__ServiceMax_Config_Data__c();
        configdata5.RecordTypeId = strExpressionRTypeId;
        configdata5.SVMXC__Expression_Rule__c  = objProcess1.id;
        configdata5.SVMXC__Expression_Type__c = 'Column Field';
        configdata5.SVMXC__Field_Name__c = 'SVMXC__Account__c';
        configdata5.SVMXC__Display_Type__c = 'REFERENCE';
        configdata5.SVMXC__Sequence__c=2.0000;
        lstConfigData.add(configdata5);
        SVMXC__ServiceMax_Config_Data__c configdata6 = new SVMXC__ServiceMax_Config_Data__c();
        configdata6.RecordTypeId = strExpressionRTypeId;
        configdata6.SVMXC__Expression_Rule__c  = objProcess2.id;
        configdata6.SVMXC__Expression_Type__c = 'Column Field';
        configdata6.SVMXC__Field_Name__c = 'LastModifiedBy';
        configdata6.SVMXC__Display_Type__c = 'REFERENCE';
        configdata6.SVMXC__Sequence__c=2.0000;
        lstConfigData.add(configdata6);
        SVMXC__ServiceMax_Config_Data__c configdata7 = new SVMXC__ServiceMax_Config_Data__c();
        configdata7.RecordTypeId = strExpressionRTypeId;
        configdata7.SVMXC__Expression_Rule__c  = objProcess3.id;
        configdata7.SVMXC__Expression_Type__c = 'Column Field';
        configdata7.SVMXC__Field_Name__c = 'SVMXC__Break_Hours__c';
        configdata7.SVMXC__Display_Type__c = 'REFERENCE';
        configdata7.SVMXC__Sequence__c=2.0000;
        lstConfigData.add(configdata7);
        //insert lstConfigData;
        SVMXC__ServiceMax_Config_Data__c configdata8 = new SVMXC__ServiceMax_Config_Data__c();
        configdata8.RecordTypeId = strExpressionRTypeId;
        configdata8.SVMXC__Expression_Rule__c  = objProcess4.id;
        configdata8.SVMXC__Expression_Type__c = 'Column Field';
        configdata8.SVMXC__Field_Name__c = 'SVMXC__City__c';
        configdata8.SVMXC__Display_Type__c = 'TEXT';
        configdata8.SVMXC__Sequence__c=2.0000;
        lstConfigData.add(configdata8);
        SVMXC__ServiceMax_Config_Data__c configdata9 = new SVMXC__ServiceMax_Config_Data__c();
        configdata9.RecordTypeId = strExpressionRTypeId;
        configdata9.SVMXC__Expression_Rule__c  = objProcess4.id;
        configdata9.SVMXC__Expression_Type__c = 'Column Field';
        configdata9.SVMXC__Field_Name__c = 'Owner';
        configdata9.SVMXC__Display_Type__c = 'REFERENCE'; 
        configdata9.SVMXC__Sequence__c=3.0000;
        lstConfigData.add(configdata9);
        SVMXC__ServiceMax_Config_Data__c configdata10 = new SVMXC__ServiceMax_Config_Data__c();
        configdata10.RecordTypeId = strExpressionRTypeId;
        configdata10.SVMXC__Expression_Rule__c  = objProcess4.id;
        configdata10.SVMXC__Expression_Type__c = 'Column Field';
        configdata10.SVMXC__Field_Name__c = 'SVMXC__Country__c';
        configdata10.SVMXC__Display_Type__c = 'PICKLIST';
        configdata10.SVMXC__Sequence__c=4.0000;
        lstConfigData.add(configdata10);
        SVMXC__ServiceMax_Config_Data__c configdata11 = new SVMXC__ServiceMax_Config_Data__c();
        configdata11.RecordTypeId = strExpressionRTypeId;
        configdata11.SVMXC__Expression_Rule__c  = objProcess4.id;
        configdata11.SVMXC__Expression_Type__c = 'Column Field';
        configdata11.SVMXC__Field_Name__c = 'SVMXC__Email__c';
        configdata11.SVMXC__Display_Type__c = 'Email';
        configdata11.SVMXC__Sequence__c=5.0000;
        lstConfigData.add(configdata11);
        SVMXC__ServiceMax_Config_Data__c configdata12 = new SVMXC__ServiceMax_Config_Data__c();
        configdata12.RecordTypeId = strExpressionRTypeId;
        configdata12.SVMXC__Expression_Rule__c  = objProcess4.id;
        configdata12.SVMXC__Expression_Type__c = 'Column Field';
        configdata12.SVMXC__Field_Name__c = 'SVMXC__Active__c';
        configdata12.SVMXC__Display_Type__c = 'Checkbox';
        configdata12.SVMXC__Sequence__c=6.0000;
        lstConfigData.add(configdata12);
        SVMXC__ServiceMax_Config_Data__c configdata13 = new SVMXC__ServiceMax_Config_Data__c();
        configdata13.RecordTypeId = strExpressionRTypeId;
        configdata13.SVMXC__Expression_Rule__c  = objProcess3.id;
        configdata13.SVMXC__Expression_Type__c = 'Column Field';
        configdata13.SVMXC__Field_Name__c = 'Owner';
        configdata13.SVMXC__Display_Type__c = 'REFERENCE';
        configdata13.SVMXC__Sequence__c=3.0000;
        lstConfigData.add(configdata13);
        SVMXC__ServiceMax_Config_Data__c configdata14 = new SVMXC__ServiceMax_Config_Data__c();
        configdata14.RecordTypeId = strExpressionRTypeId;
        configdata14.SVMXC__Expression_Rule__c  = objProcess3.id;
        configdata14.SVMXC__Expression_Type__c = 'Column Field';
        configdata14.SVMXC__Field_Name__c = 'SVMXC__Country__c';
        configdata14.SVMXC__Display_Type__c = 'PICKLIST';
        configdata14.SVMXC__Sequence__c=4.0000;
        lstConfigData.add(configdata14);
        SVMXC__ServiceMax_Config_Data__c configdata15 = new SVMXC__ServiceMax_Config_Data__c();
        configdata15.RecordTypeId = strExpressionRTypeId;
        configdata15.SVMXC__Expression_Rule__c  = objProcess3.id;
        configdata15.SVMXC__Expression_Type__c = 'Column Field';
        configdata15.SVMXC__Field_Name__c = 'SVMXC__Email__c';
        configdata15.SVMXC__Display_Type__c = 'Email';
        configdata15.SVMXC__Sequence__c=5.0000;
        lstConfigData.add(configdata15);
        SVMXC__ServiceMax_Config_Data__c configdata16 = new SVMXC__ServiceMax_Config_Data__c();
        configdata16.RecordTypeId = strExpressionRTypeId;
        configdata16.SVMXC__Expression_Rule__c  = objProcess3.id;
        configdata16.SVMXC__Expression_Type__c = 'Column Field';
        configdata16.SVMXC__Field_Name__c = 'SVMXC__Active__c';
        configdata16.SVMXC__Display_Type__c = 'Checkbox';
        configdata16.SVMXC__Sequence__c=6.0000;
        lstConfigData.add(configdata16);
        SVMXC__ServiceMax_Config_Data__c configdata17 = new SVMXC__ServiceMax_Config_Data__c();
        configdata17.RecordTypeId = strExpressionRTypeId;
        configdata17.SVMXC__Expression_Rule__c  = objProcess2.id;
        configdata17.SVMXC__Expression_Type__c = 'Column Field';
        configdata17.SVMXC__Field_Name__c = 'LastModifiedBy';
        configdata17.SVMXC__Display_Type__c = 'REFERENCE';
        configdata17.SVMXC__Sequence__c=3.0000;
        lstConfigData.add(configdata17);
        SVMXC__ServiceMax_Config_Data__c configdata18 = new SVMXC__ServiceMax_Config_Data__c();
        configdata18.RecordTypeId = strExpressionRTypeId;
        configdata18.SVMXC__Expression_Rule__c  = objProcess2.id;
        configdata18.SVMXC__Expression_Type__c = 'Column Field';
        configdata18.SVMXC__Field_Name__c = 'Type';
        configdata18.SVMXC__Display_Type__c = 'PICKLIST';
        configdata18.SVMXC__Sequence__c=4.0000;
        lstConfigData.add(configdata18);
        SVMXC__ServiceMax_Config_Data__c configdata19 = new SVMXC__ServiceMax_Config_Data__c();
        configdata19.RecordTypeId = strExpressionRTypeId;
        configdata19.SVMXC__Expression_Rule__c  = objProcess2.id;
        configdata19.SVMXC__Expression_Type__c = 'Column Field';
        configdata19.SVMXC__Field_Name__c = 'Owner';
        configdata19.SVMXC__Display_Type__c = 'REFERENCE';
        configdata19.SVMXC__Sequence__c=5.0000;
        lstConfigData.add(configdata19);        
        SVMXC__ServiceMax_Config_Data__c configdata20 = new SVMXC__ServiceMax_Config_Data__c();
        configdata20.RecordTypeId = strExpressionRTypeId;
        configdata20.SVMXC__Expression_Rule__c  = objProcess2.id;
        configdata20.SVMXC__Expression_Type__c = 'Column Field';
        configdata20.SVMXC__Field_Name__c = 'CreatedBy';
        configdata20.SVMXC__Display_Type__c = 'REFERENCE';
        configdata20.SVMXC__Sequence__c=6.0000;
        lstConfigData.add(configdata20);
        SVMXC__ServiceMax_Config_Data__c configdata21 = new SVMXC__ServiceMax_Config_Data__c();
        configdata21.RecordTypeId = strExpressionRTypeId;
        configdata21.SVMXC__Expression_Rule__c  = objProcess2.id;
        configdata21.SVMXC__Expression_Type__c = 'Column Field';
        configdata21.SVMXC__Field_Name__c = 'Rating';
        configdata21.SVMXC__Display_Type__c = 'PICKLIST';
        configdata21.SVMXC__Sequence__c=7.0000;
        lstConfigData.add(configdata21);
        SVMXC__ServiceMax_Config_Data__c configdata22 = new SVMXC__ServiceMax_Config_Data__c();
        configdata22.RecordTypeId = strExpressionRTypeId;
        configdata22.SVMXC__Expression_Rule__c  = objProcess.id;
        configdata22.SVMXC__Expression_Type__c = 'Column Field';
        configdata22.SVMXC__Field_Name__c = 'SVMXC__Auto_Entitlement_Status__c';
        configdata22.SVMXC__Display_Type__c = 'Picklist';
        configdata22.SVMXC__Sequence__c=3.0000;
        lstConfigData.add(configdata22);
        SVMXC__ServiceMax_Config_Data__c configdata23 = new SVMXC__ServiceMax_Config_Data__c();
        configdata23.RecordTypeId = strExpressionRTypeId;
        configdata23.SVMXC__Expression_Rule__c  = objProcess.id;
        configdata23.SVMXC__Expression_Type__c = 'Column Field';
        configdata23.SVMXC__Field_Name__c = 'SVMXC__Auto_Entitlement_Status__c';
        configdata23.SVMXC__Display_Type__c = 'Picklist';
        configdata23.SVMXC__Sequence__c=4.0000;
        lstConfigData.add(configdata23);
        SVMXC__ServiceMax_Config_Data__c configdata24 = new SVMXC__ServiceMax_Config_Data__c();
        configdata24.RecordTypeId = strExpressionRTypeId;
        configdata24.SVMXC__Expression_Rule__c  = objProcess.id;
        configdata24.SVMXC__Expression_Type__c = 'Column Field';
        configdata24.SVMXC__Field_Name__c = 'SVMXC__Billing_Type__c';
        configdata24.SVMXC__Display_Type__c = 'Picklist';
        configdata24.SVMXC__Sequence__c=5.0000;
        lstConfigData.add(configdata24);
        SVMXC__ServiceMax_Config_Data__c configdata25 = new SVMXC__ServiceMax_Config_Data__c();
        configdata25.RecordTypeId = strExpressionRTypeId;
        configdata25.SVMXC__Expression_Rule__c  = objProcess.id;
        configdata25.SVMXC__Expression_Type__c = 'Column Field';
        configdata25.SVMXC__Field_Name__c = 'SVMXC__Company__c';
        configdata25.SVMXC__Display_Type__c = 'REFERENCE';
        configdata25.SVMXC__Sequence__c=6.0000;
        lstConfigData.add(configdata25);
        SVMXC__ServiceMax_Config_Data__c configdata26 = new SVMXC__ServiceMax_Config_Data__c();
        configdata26.RecordTypeId = strExpressionRTypeId;
        configdata26.SVMXC__Expression_Rule__c  = objProcess.id;
        configdata26.SVMXC__Expression_Type__c = 'Column Field';
        configdata26.SVMXC__Field_Name__c = 'SVMXC__Contact__c';
        configdata26.SVMXC__Display_Type__c = 'REFERENCE';
        configdata26.SVMXC__Sequence__c=7.0000;
        lstConfigData.add(configdata26);
        SVMXC__ServiceMax_Config_Data__c configdata27 = new SVMXC__ServiceMax_Config_Data__c();
        configdata27.RecordTypeId = strExpressionRTypeId;
        configdata27.SVMXC__Expression_Rule__c  = objProcess.id;
        configdata27.SVMXC__Expression_Type__c = 'Column Field';
        configdata27.SVMXC__Field_Name__c = 'SVMXC__Dispatch_Process__c';
        configdata27.SVMXC__Display_Type__c = 'REFERENCE';
        configdata27.SVMXC__Sequence__c=8.0000;
        lstConfigData.add(configdata27);
        SVMXC__ServiceMax_Config_Data__c configdata28 = new SVMXC__ServiceMax_Config_Data__c();
        configdata28.RecordTypeId = strExpressionRTypeId;
        configdata28.SVMXC__Expression_Rule__c  = objProcess.id;
        configdata28.SVMXC__Expression_Type__c = 'Column Field';
        configdata28.SVMXC__Field_Name__c = 'SVMXC__Preferred_Technician__c';
        configdata28.SVMXC__Display_Type__c = 'REFERENCE';
        configdata28.SVMXC__Sequence__c=9.0000;
        lstConfigData.add(configdata28);
        SVMXC__ServiceMax_Config_Data__c configdata29 = new SVMXC__ServiceMax_Config_Data__c();
        configdata29.RecordTypeId = strExpressionRTypeId;
        configdata29.SVMXC__Expression_Rule__c  = objProcess.id;
        configdata29.SVMXC__Expression_Type__c = 'Column Field';
        configdata29.SVMXC__Field_Name__c = 'SVMXC__PM_Plan__c';
        configdata29.SVMXC__Display_Type__c = 'REFERENCE';
        configdata29.SVMXC__Sequence__c=10.0000;
        lstConfigData.add(configdata29);
        
        insert lstConfigData;
        CONF_SetupMapHover obj = new CONF_SetupMapHover();
        obj.SVMX_Save();
        obj.SVMX_BackToSetupHome();
        obj.getisHdrMsg();
        obj.getHLPURL();
        obj.getTAG019();
        obj.getTAG001();
        obj.getTAG002();
        obj.getTAG003();
        obj.getTAG004();
        obj.getTAG005();
        obj.getTAG006();
        obj.getTAG007();
        obj.getTAG008();
        obj.getTAG009();
        obj.getTAG010();
        obj.getTAG011();
        obj.getTAG012();
        obj.getTAG013();
        obj.getTAG014();
        obj.getTAG015();
        obj.getTAG016();
        obj.getTAG017();
        obj.getTAG018();
        obj.getTAG019();
        obj.getTAG020();
        obj.getTAG021();
        obj.SaveMapHoverForWO();
        obj.SaveMapHoverForLocation();
        obj.SaveMapHoverForAccount();
        obj.SaveMapHoverForTechnician();
        obj.SaveMapHoverForTeam();
        delete objProcess;
        delete objProcess1;
        delete objProcess2;
        delete objProcess3;
        delete objProcess4;
        //delete lstConfigData;
        
    }
    static testMethod void CONF_SetupMapHoverTestForWO() {
    
        CONF_SetupMapHover obj = new CONF_SetupMapHover();
        obj.strWODisplayField1 = 'Name';
        obj.strWODisplayField2 = 'Name1';
        obj.strWODisplayField3 = 'Name2';
        obj.strWODisplayField4 = 'Name3';
        obj.strWODisplayField5 = 'Name4';
        obj.strWODisplayField6 = 'Name5';
        obj.strWODisplayField7 = 'Name6';
        obj.strWODisplayField8 = 'Name7';
        obj.strWODisplayField9 = 'Name8';
        obj.strWODisplayField10 = 'Name9';
        obj.SVMX_ValidateWO();
        
        obj.strWODisplayField1 = '';
        obj.strWODisplayField2 = '';
        obj.strWODisplayField3 = '';
        obj.strWODisplayField4 = '';
        obj.strWODisplayField5 = '';
        obj.strWODisplayField6 = '';
        obj.strWODisplayField7 = '';
        obj.strWODisplayField8 = '';
        obj.strWODisplayField9 = '';
        obj.strWODisplayField10 = '';
        obj.SVMX_ValidateWO();
        
        obj.strWODisplayField1 = 'Name';
        obj.SVMX_ValidateWO();
        
        obj.strWODisplayField2 = 'Name';
        obj.SVMX_ValidateWO();
        
        obj.strWODisplayField3 = 'Name';
        obj.SVMX_ValidateWO();
        
        obj.strWODisplayField4 = 'Name';
        obj.SVMX_ValidateWO();
        
        obj.strWODisplayField5 = 'Name';
        obj.SVMX_ValidateWO();
        
        obj.strWODisplayField6 = 'Name';
        obj.SVMX_ValidateWO();
        
        obj.strWODisplayField7 = 'Name';
        obj.SVMX_ValidateWO();
        
        obj.strWODisplayField8 = 'Name';
        obj.SVMX_ValidateWO();
        
        obj.strWODisplayField9 = 'Name';
        obj.SVMX_ValidateWO();
        
        obj.strWODisplayField10 = 'Name';
        obj.SVMX_ValidateWO();
    }
    static testMethod void CONF_SetupMapHoverTestForLoc() {
        
        CONF_SetupMapHover obj = new CONF_SetupMapHover();
        obj.strLocDisplayField1 = 'Name1';
        obj.strLocDisplayField2 = 'Name2';
        obj.strLocDisplayField3 = 'Name3';
        obj.strLocDisplayField4 = 'Name4';
        obj.strLocDisplayField5 = 'Name5';
        obj.strLocDisplayField6 = 'Name6';
        obj.strLocDisplayField7 = 'Name7';
        obj.strLocDisplayField8 = 'Name8';
        obj.strLocDisplayField9 = 'Name9';
        obj.strLocDisplayField10 = 'Name10';
        obj.SVMX_ValidateLoc();
        obj.strLocDisplayField1 = 'Name';
        obj.strLocDisplayField2 = 'Name';
        obj.strLocDisplayField3 = 'Name';
        obj.strLocDisplayField4 = 'Name';
        obj.strLocDisplayField5 = 'Name';
        obj.strLocDisplayField6 = 'Name';
        obj.strLocDisplayField7 = 'Name';
        obj.strLocDisplayField8 = 'Name';
        obj.strLocDisplayField9 = 'Name';
        obj.strLocDisplayField10 = 'Name';
        obj.SVMX_ValidateLoc();
    }
    static testMethod void CONF_SetupMapHoverTestForAcc() {
        CONF_SetupMapHover obj = new CONF_SetupMapHover();
        obj.strAccDisplayField1 = 'Name';
        obj.strAccDisplayField2 = 'Name1';
        obj.strAccDisplayField3 = 'Name2';
        obj.strAccDisplayField4 = 'Name3';
        obj.strAccDisplayField5 = 'Name4';
        obj.strAccDisplayField6 = 'Name5';
        obj.strAccDisplayField7 = 'Name6';
        obj.strAccDisplayField8 = 'Name7';
        obj.strAccDisplayField9 = 'Name8';
        obj.strAccDisplayField10 = 'Name9';
        obj.SVMX_ValidateAcc();
    
    }
    static testMethod void CONF_SetupMapHoverTestForTech() {
        CONF_SetupMapHover obj = new CONF_SetupMapHover();
        obj.strTechDisplayField1 = 'Name';
        obj.strTechDisplayField2 = 'Name1';
        obj.strTechDisplayField3 = 'Name2';
        obj.strTechDisplayField4 = 'Name3';
        obj.strTechDisplayField5 = 'Name4';
        obj.strTechDisplayField6 = 'Name5';
        obj.strTechDisplayField7 = 'Name6';
        obj.strTechDisplayField8 = 'Name7'; 
        obj.strTechDisplayField9 = 'Name8';
        obj.strTechDisplayField10 = 'Name9';
        obj.SVMX_ValidateTech();
    }
    
    static testMethod void CONF_SetupMapHoverTestForTeam() {
        CONF_SetupMapHover obj = new CONF_SetupMapHover();
        obj.strTeamDisplayField1 = 'Name';
        obj.strTeamDisplayField2 = 'Name1';
        obj.strTeamDisplayField3 = 'Name2';
        obj.strTeamDisplayField4 = 'Name3';
        obj.strTeamDisplayField5 = 'Name4';
        obj.strTeamDisplayField6 = 'Name5';
        obj.strTeamDisplayField7 = 'Name6';
        obj.strTeamDisplayField8 = 'Name7'; 
        obj.strTeamDisplayField9 = 'Name8';
        obj.strTeamDisplayField10 = 'Name9';
        obj.SVMX_ValidateTeam();
        CONF_SetupMapHover obj1 = new CONF_SetupMapHover();
        obj1.strTeamDisplayField1 = 'Name';
        obj1.strTeamDisplayField2 = '--None--';
        obj1.strTeamDisplayField3 = '--None--';
        obj1.strTeamDisplayField4 = '--None--';
        obj1.strTeamDisplayField5 = '--None--';
        obj1.strTeamDisplayField6 = '--None--';
        obj1.strTeamDisplayField7 = '--None--';
        obj1.strTeamDisplayField8 = '--None--'; 
        obj1.strTeamDisplayField9 = '--None--';
        obj1.strTeamDisplayField10 = '--None--';
        obj1.SVMX_ValidateTeam();
        obj1.SVMX_ValidateTech();
        obj1.SVMX_ValidateAcc();
        obj1.SVMX_ValidateLoc();
        obj1.SVMX_ValidateWO();
        CONF_SetupMapHover obj2 = new CONF_SetupMapHover();
        obj2.strTeamDisplayField1 = 'Name';
        obj2.strTeamDisplayField2 = 'Name';
        obj2.strTeamDisplayField3 = 'Name';
        obj2.strTeamDisplayField4 = 'Name';
        obj2.strTeamDisplayField5 = 'Name';
        obj2.strTeamDisplayField6 = 'Name';
        obj2.strTeamDisplayField7 = 'Name';
        obj2.strTeamDisplayField8 = 'Name'; 
        obj2.strTeamDisplayField9 = 'Name';
        obj2.strTeamDisplayField10 = 'Name';
        obj2.SVMX_ValidateTeam();
        obj2.SVMX_ValidateTech();
        obj2.SVMX_ValidateAcc();
        obj2.SVMX_ValidateLoc();
        obj2.SVMX_ValidateWO();
    }
}