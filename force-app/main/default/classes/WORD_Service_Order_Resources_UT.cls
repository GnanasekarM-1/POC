@isTest
(SeeAllData = false)
public class WORD_Service_Order_Resources_UT{
    static testMethod void testGetResourcePreference(){
        WSCH_TestDataFactory.createOptimizationSettings('OptiMax,ServicePower', 'True');
        SVMXC__Territory__c territory1 = new SVMXC__Territory__c();
        territory1.name = 'UK Region';
        territory1.SVMXC__Optimizer_External_ID__c = 'UK01';
        territory1.SVMXC__Optimizer_Last_Timestamp__c='';
        insert territory1;

        SVMXC__Service_Group__c team = new SVMXC__Service_Group__c();
        team.Name = 'testTeam';

        insert team;

        SVMXC__Service_Group_Members__c technician = new SVMXC__Service_Group_Members__c();
        technician.Name = 'John';
        technician.SVMXC__Optimizer_External_ID__c = 'TM001';
        technician.SVMXC__Service_Group__c  = team.Id;
        technician.SVMXC__Service_Territory__c = territory1.Id;

        insert technician;

        SVMXC__Site__c siteObject = new SVMXC__Site__c();
        siteObject.Name = 'Site1';

        insert siteObject;

        Account accountObject = new Account();
        accountObject.AccountNumber = '0011';
        accountObject.Name = 'Test Name';

        insert accountObject;
        
        Contact cont = new Contact();
        cont.LastName='Last';
        cont.AccountId =accountObject.Id;
        cont.Email='svmxmailfortest@servicemax.com';
        
        insert cont;
        
        Product2 prodCloseWO = new Product2();
        prodCloseWO.Name = 'prodPR';
        prodCloseWO.ProductCode='prodPR';
        prodCloseWO.SVMXC__Inherit_Parent_Warranty__c =True;
        
        insert prodCloseWO;
        
        SVMXC__Installed_Product__c IBObject = new SVMXC__Installed_Product__c();
        IBObject.Name = 'Test IB1';
        IBObject.SVMXC__Status__c = 'Installed';
        IBObject.SVMXC__Product__c = prodCloseWO.Id;
        IBObject.SVMXC__Date_Installed__c = System.Today();
        IBObject.SVMXC__Contact__c = cont.Id;
        IBObject.SVMXC__Company__c = accountObject.Id;
        
        insert IBObject;

        Datetime startTime = Datetime.now();
        Datetime endTime = startTime.addHours(2);
        
        SVMXC__Service_Order__c bookJobWorkOrder = new SVMXC__Service_Order__c();
        bookJobWorkOrder.SVMXC__Zip__c = '75001';
        bookJobWorkOrder.SVMXC__Service_Duration__c = 3600.00;
        bookJobWorkOrder.SVMXC__Preferred_Start_Time__c = startTime;
        bookJobWorkOrder.SVMXC__Preferred_End_Time__c = endTime;
        bookJobWorkOrder.SVMXC__Preferred_Technician__c = technician.Id;
        bookJobWorkOrder.SVMXC__Skill_Set__c = '[{"skillName":"hardware","skillLevel":5,"skillId":"a1RG0000002fCLLMA2","isSkillMandatory":true},{"skillName":"software","skillLevel":5,"skillId":"a1RG0000002fCLQMA2","isSkillMandatory":true}]';
        bookJobWorkOrder.SVMXC__Site__c = siteObject.Id;
        bookJobWorkOrder.SVMXC__Company__c = accountObject.Id;

        insert bookJobWorkOrder;

        SVMXC__Resource_Preference__c resPref = new SVMXC__Resource_Preference__c();
        resPref.SVMXC__Company__c = accountObject.Id;
        resPref.SVMXC__Component__c = IBObject.id;
        resPref.SVMXC__Site__c = siteObject.id;
        resPref.SVMXC__Group_Member__c = technician.id;
        resPref.SVMXC__Preference_Type__c = 'Preferred';
        
        insert resPref;
        
        List<SVMXC__Service_Order__c> lstWO = new List<SVMXC__Service_Order__c>();
        lstWO.add(bookJobWorkOrder);
        List<SVMXC__Resource_Preference__c> lstResPref  = new List<SVMXC__Resource_Preference__c>();
        lstResPref = WORD_Service_Order_Resources.getResourcePreferences(lstWO);
        Map<Id,SVMXC__Service_Order__c> mapOldWO = new Map<Id,SVMXC__Service_Order__c>();
        mapOldWO.put(bookJobWorkOrder.id, bookJobWorkOrder);
        
        WORD_Service_Order_Resources.setWorkOrderResources(lstWO,lstResPref);
        WORD_Service_Order_Resources.getWorkOrderResources(lstWO);
        //WORD_Service_Order_Resources.checkWorkOrderResUpdate(lstWO, mapOldWO);
    }
}