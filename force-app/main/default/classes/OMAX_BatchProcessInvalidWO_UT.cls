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
private class OMAX_BatchProcessInvalidWO_UT {

 	static testMethod void OMAX_BatchRunQTL_InvalidWO_Test()
    {
		//Creating data 
		test.startTest();
    	/*list<string> lstSettings = new list<string>();        
        lstSettings.add('GLOB001_GBL007');
        List<SVMXC__ServiceMax_Config_Data__c> lstSettingValues = new List<SVMXC__ServiceMax_Config_Data__c>();
        lstSettingValues = [SELECT SVMXC__Internal_Value__c, SVMXC__Setting_Unique_ID__c FROM SVMXC__ServiceMax_Config_Data__c WHERE recordType.Name = 'Setting Value'
                            AND SVMXC__Setting_Unique_ID__c IN :lstSettings
                            AND SVMXC__Setting_Configuration_Profile__r.SVMXC__Active__c = true
                            AND SVMXC__Setting_Configuration_Profile__r.SVMXC__RecordType_Name__c = 'Configuration Profile' 
                            AND SVMXC__Setting_Configuration_Profile__r.SVMXC__Configuration_Type__c = 'Global'
                            ];                          
        lstSettingValues[0].SVMXC__Internal_Value__c='True';
        upsert lstSettingValues;*/
        case c = new case();
        Account account = new Account(
                                                Name = 'Account',
                                                ShippingStreet= 'ABC',
                                                ShippingCity= 'PQR ',
                                                ShippingState = 'XYZ',
                                                ShippingPostalCode= '111',
                                                ShippingCountry= 'XYZ',
                                                BillingStreet= 'ABC',
                                                BillingCity= 'PQR ',
                                                BillingState = 'XYZ',
                                                BillingPostalCode= '111',
                                                BillingCountry= 'XYZ'
                                                ); 
        insert account;
        System.assertEquals('Account', account.Name);
        
        List<BusinessHours> lBH = [ select WednesdayStartTime, WednesdayEndTime, TuesdayStartTime, TuesdayEndTime, ThursdayStartTime, ThursdayEndTime, SundayStartTime, SundayEndTime, SaturdayStartTime, SaturdayEndTime, MondayStartTime, MondayEndTime, IsDefault, IsActive, Id, FridayStartTime, FridayEndTime from BusinessHours where isDefault = true limit 1];
        
        
        Contact contact = new Contact(LastName= 'Last',AccountId =account.Id,Email= 'test@max.com');
        insert contact;
        System.assertEquals('Last', contact.LastName);
        SVMXC__Territory__c Territory2 = new SVMXC__Territory__c(Name= 'Territory2',SVMXC__Active__c =true,SVMXC__Territory_Code__c = 'Territory2',SVMXC__Parent_Territory__c =NULL,SVMXC__Per_Mile_Cost__c=2.0,SVMXC__Max_Distance__c=100,SVMXC__Average_Speed__c=50.0);
        insert Territory2;
        
        RecordType[] rts = [SELECT Id, Name, SobjectType FROM RecordType];
        SVMXC__ServiceMax_Processes__c svmxprocess = new SVMXC__ServiceMax_Processes__c();
        
        SVMXC__ServiceMax_Config_Data__c oConf = new SVMXC__ServiceMax_Config_Data__c();
        oConf.SVMXC__Expression_Type__c = 'DISP_Process_Entry';
        oConf.SVMXC__Field_Name__c = 'SVMXC__Zip__c';
        oConf.SVMXC__Display_Type__c = 'STRING';
        oConf.SVMXC__Operand__c = '11111111';
        oConf.SVMXC__Operator__c = 'eq';
        oConf.SVMXC__Expression_Rule__c = svmxprocess.Id;
        
        
        for(RecordType rt : rts) //Loop to take a record type at a time
        {
            if(rt.Name == 'Dispatch Process' && rt.SobjectType == 'SVMXC__ServiceMax_Processes__c')
            {
               svmxprocess.RecordTypeId = rt.ID;
            } 
             
            if(rt.Name == 'Expressions' && rt.SobjectType == 'SVMXC__ServiceMax_Config_Data__c')
            {
               oConf.RecordTypeId = rt.ID;
            } 
        }
        
        svmxprocess.SVMXC__Territory__c = Territory2.Id;
        svmxprocess.SVMXC__Description__c = 'abcd';
        svmxprocess.SVMXC__Dispatch_Method__c = 'Optimized Batch';
        svmxprocess.SVMXC__Assign_Work_Order_To__c = 'Technician';
        svmxprocess.SVMXC__Calendar_Start_Type__c = 'SAME DAY';
        svmxprocess.SVMXC__Calendar_End_Type__c = 'SAME DAY';
        svmxprocess.SVMXC__Expertise_Match_Enabled__c =true;
        svmxprocess.SVMXC__Product_Match_Enabled__c =true;
        svmxprocess.SVMXC__Preferred_Tech_Enabled__c =true;
        svmxprocess.SVMXC__Route_Type__c = 'CLOSED';
        svmxprocess.SVMXC__Distance_And_Time__c = 'Actual Distance And Time';
        svmxprocess.SVMXC__Weight_Time_Window__c =1.0000;
        svmxprocess.SVMXC__Weight_Route_Distance__c =1.0000;
        svmxprocess.SVMXC__Weight_Route_Time__c =1.0000;
        svmxprocess.SVMXC__Weight_Node_Type__c =1;
        svmxprocess.SVMXC__Dispatch_Process_Status__c = 'Complete';
        svmxprocess.SVMXC__Runs_Every_Monday__c =true;
        svmxprocess.SVMXC__Runs_Every_Tuesday__c =true;
        svmxprocess.SVMXC__Start_Time__c = '11:00 PM';
        svmxprocess.SVMXC__Frequency__c =1;
        svmxprocess.SVMXC__Full_Run_Unit__c = 'Days';
        svmxprocess.SVMXC__Start_Date__c = date.Today();
        svmxprocess.SVMXC__End_Date__c = date.Today().addDays(1);
        svmxprocess.SVMXC__Weight_Total_Distance__c =1.0000;
        svmxprocess.SVMXC__Calendar_Start_Days__c = 0;
        svmxprocess.SVMXC__Calendar_End_Days__c = 2;
        svmxprocess.SVMXC__Tolerance__c = 30;
        svmxprocess.SVMXC__ProcessID__c = 'PROCESS11';
        svmxprocess.SVMXC__SettingId__c = 'PROCESS11';
        svmxprocess.SVMXC__MapID__c = 'PROCESS11';
        svmxprocess.SVMXC__Name__c = 'PROCESS22';
        Insert svmxprocess;
              
        SVMXC__SVMX_Jobs__c inProgressJob = new SVMXC__SVMX_Jobs__c(SVMXC__SVMX_Process__c = svmxprocess.Id, SVMXC__Territory__c = Territory2.Id, SVMXC__OptiMax_Message__c = 'In Progress');        
        insert inProgressJob;
        
        
		list<SVMXC__Service_Order__c> lstWO1 = new list<SVMXC__Service_Order__c>();
        SVMXC__Service_Order__c nWO1 = new SVMXC__Service_Order__c();
        nWO1.SVMXC__Zip__c = '11111';           
        nWO1.SVMXC__Order_Status__c='Open';
        nWO1.SVMXC__Priority__c='Low';
        nWO1.SVMXC__Order_Type__c='Field Service';
        nWO1.SVMXC__Purpose_of_Visit__c='Repair';
        nWO1.SVMXC__Billing_Type__c = 'Paid';
        nWO1.SVMXC__City__c = 'Bangalore';
        nWO1.SVMXC__Dispatch_Process__c =  svmxprocess.id;
        nWO1.SVMXC__OptiMax_Error_Occurred__c = false;
        nWO1.SVMXC__OptiMax_Status__c = 'Not Completed';
        nWO1.SVMXC__Locked_By_DC__c = false;
        nWO1.SVMXC__Primary_Territory__c = Territory2.id;
        nWO1.Driving_Time__c = 60;
        lstWO1.add(nWO1);
        SVMXC__Service_Order__c nWO2 = new SVMXC__Service_Order__c();
        nWO2.SVMXC__Zip__c = '11111';           
        nWO2.SVMXC__Order_Status__c='Open';
        nWO2.SVMXC__Priority__c='Low';
        nWO2.SVMXC__Order_Type__c='Field Service';
        nWO2.SVMXC__Purpose_of_Visit__c='Repair';
        nWO2.SVMXC__Billing_Type__c = 'Paid';
        nWO2.SVMXC__City__c = 'Bangalore';
        nWO2.SVMXC__Dispatch_Process__c =  svmxprocess.id;
        nWO2.SVMXC__OptiMax_Error_Occurred__c = false;
        nWO2.SVMXC__OptiMax_Status__c = 'Not Completed';
        nWO2.SVMXC__Locked_By_DC__c = false;
        nWO2.SVMXC__Service_Duration__c = 60;
        nWO2.SVMXC__Primary_Territory__c = Territory2.id;
        nWO2.Driving_Time__c = 60;
        lstWO1.add(nWO2);
               
        SVMXC__Service_Order__c objWorkOrder = new SVMXC__Service_Order__c();
        objWorkOrder.SVMXC__OptiMax_Status__c = 'xyz';
        objWorkOrder.SVMXC__Dispatch_Process__c = svmxprocess.Id; 
        objWorkOrder.SVMXC__Primary_Territory__c = Territory2.id;
        objWorkOrder.SVMXC__Service_Duration__c = NULL;
        objWorkOrder.SVMXC__Dispatch_Priority__c = 0;
        objWorkOrder.SVMXC__Street__c = 'asdf';
        objWorkOrder.SVMXC__City__c = 'qwer';
        objWorkOrder.SVMXC__State__c = 'zxxcc';
        objWorkOrder.SVMXC__Zip__c = NULL;
        objWorkOrder.SVMXC__Country__c = 'xyz';
        objWorkOrder.SVMXC__QTL_Status__c = 'No Qualified Technicians (Disallow)';
        //insert objWorkOrder;
        lstWO1.add(objWorkOrder);
        insert lstWO1; 
        String strBadWorkOrderDetails='{"workItemName":"'+lstWO1[0].Name+'","workItemId":"'+lstWO1[0].Id+'","errorDetails":[{"errorType":"Dispatch Parameter Error","errorMessage":"Invalid Service Duration"},{"errorType":"Dispatch Parameter Error","errorMessage":"Invalid Zipcode"},{"errorType":"QTL Error","errorMessage":"Workorder disallowed due to No Qualified Technicians computed."}]};';
        
        String strLogger='Test';
        
		OMAX_BatchProcessInvalidWO objOMAX_BatchRunQTL= new OMAX_BatchProcessInvalidWO(strBadWorkOrderDetails, strLogger);
        Database.BatchableContext BC;
        list<sObject> lstsObject = new list<sObject>();
        lstsObject.add((sObject)lstWO1[0]);
        lstsObject.add((sObject)lstWO1[1]);
        objOMAX_BatchRunQTL.execute(BC,lstsObject);
        objOMAX_BatchRunQTL.finish(BC);
    	test.stopTest();
    }
}