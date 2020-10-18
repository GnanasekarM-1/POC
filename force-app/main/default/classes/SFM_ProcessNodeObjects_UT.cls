@isTest
private class SFM_ProcessNodeObjects_UT
{
    static testMethod void getPocessNodeObjects_Test()
    {
        /*------------Data Creation------------*/
        List<RecordType> lstRecType = [SELECT Id, Name FROM RecordType WHERE SobjectType = 'SVMXC__ServiceMax_Processes__c' OR SobjectType = 'SVMXC__ServiceMax_Config_Data__c'];
        System.assertEquals(true, lstRecType != null);
        String TargetManager = '';
        String ObjectMapping = '';
        String Fieldmapping = '';
        String ProcessNodeObj = '';
        for(RecordType r : lstRecType)
        {
            if(r.Name == 'Target Manager')
                TargetManager = r.id;
            if(r.Name == 'Object Mapping')  
                ObjectMapping = r.id;
            if(r.Name == 'Field Mapping')
                Fieldmapping = r.id;    
            if(r.Name == 'Process Node Objects')    
                ProcessNodeObj = r.id;
        }
        //Create Process
        SVMXC__ServiceMax_Processes__c SFMProcess = new SVMXC__ServiceMax_Processes__c();
        SFMProcess.RecordTypeId = TargetManager;
        SFMProcess.SVMXC__Name__c = 'SFMPROCESSNAME001';
        SFMProcess.SVMXC__ProcessID__c = 'SFMPROCESSNAME001';
        SFMProcess.SVMXC__Rule_Type__c = 'Interactive';
        SFMProcess.SVMXC__IsStandalone__c = true;
        SFMProcess.SVMXC__Purpose__c = 'EDIT';
        insert SFMProcess;
        System.assertEquals(true, SFMProcess != null);
          
        //Create Process Node Objects
        SVMXC__ServiceMax_Processes__c PNodeObj1 = new SVMXC__ServiceMax_Processes__c();
        PNodeObj1.RecordTypeId = ProcessNodeObj;
        PNodeObj1.SVMXC__Process__c = SFMProcess.id;
        PNodeObj1.SVMXC__Source_Object_Name__c = 'SVMXC__Service_Order__c';
        PNodeObj1.SVMXC__Type__c = 'TARGET';
        insert PNodeObj1;
        System.assertEquals(true, PNodeObj1 != null);
          
        SVMXC__ServiceMax_Processes__c PNodeObj2 = new SVMXC__ServiceMax_Processes__c();
        PNodeObj2.RecordTypeId = ProcessNodeObj;
        PNodeObj2.SVMXC__Process__c = SFMProcess.id;
        PNodeObj2.SVMXC__Source_Object_Name__c = 'SVMXC__Service_Order_Line__c';
        PNodeObj2.SVMXC__Type__c = 'TARGETCHILD';
        PNodeObj2.SVMXC__Node_Parent_API__c = 'SVMXC__Service_Order__c';
        PNodeObj2.SVMXC__Target_Object_label__c = 'WorkDetail';
        PNodeObj2.SVMXC__Parent_Column_Name__c = 'SVMXC__Service_Order__c';
        insert PNodeObj2;
        System.assertEquals(true, PNodeObj2 != null);
        
        /*------------Instance Of Class---------*/ 
        SFM_processNodeObjects pobjn = new SFM_processNodeObjects();
        /*------------Method Calling------------*/
        pobjn.getPocessNodeObjects(SFMProcess.Id);
    }
}