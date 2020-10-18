@isTest
private class SVMX_Sequence_UT 
{
    static testMethod void SVMX_SequenceUnitTest() 
    {
    	// System Assert
	     Account testAccount = new Account(name='Test Company Name');
	     insert testAccount;
	     testAccount.billingState='CA';
	     update testAccount;
	     // Verify that the billingState field was updated in the database.
	     Account updatedAccount = [SELECT billingState FROM Account WHERE Id = :testAccount.Id];
	     System.assertEquals('CA', updatedAccount.billingState);
    	
        RecordType RtypeSVMX_Toolbar_Action = [Select Id, Name from RecordType where Name = 'SF Action' AND SObjectType = 'SVMXC__ServiceMax_Processes__c' Limit 1];
        SVMXC__ServiceMax_Processes__c ToolbarAction = new SVMXC__ServiceMax_Processes__c();
        ToolbarAction.SVMXC__Select__c = false;
        ToolbarAction.SVMXC__Sequence__c = 1 ;
        //ToolbarAction.SVMXC__Module__c = ToolbarRec.Id; //Toolbar defn lookup
        //ToolbarAction.SVMXC__Process__c = SampleProcess.Id;
        ToolbarAction.SVMXC__Name__c = 'ToolbarAction001';
        ToolbarAction.SVMXC__ProcessID__c = 'ToolbarAction001';
        ToolbarAction.SVMXC__SettingID__c = 'ToolbarAction001';
        ToolbarAction.SVMXC__Description__c = 'Sample Description';
        ToolbarAction.SVMXC__Action_Type__c = 'OTHERS';
        ToolbarAction.SVMXC__Action_URL__c = 'New url';
        //ToolbarAction.SVMXC__Submodule__c = ; //named expression lookup
        ToolbarAction.SVMXC__IsStandard__c = false;
        ToolbarAction.RecordTypeId = RtypeSVMX_Toolbar_Action.Id;
        ToolbarAction.SVMXC__Sequence__c = 1;
        //insert ToolbarAction;
        system.assert(ToolbarAction.SVMXC__Name__c!=null);
        system.assert(ToolbarAction.SVMXC__SettingID__c!=null);
        system.assert(ToolbarAction.SVMXC__Action_Type__c!=null);
        
        SVMXC__ServiceMax_Processes__c ToolbarAction1 = new SVMXC__ServiceMax_Processes__c();
        ToolbarAction1.SVMXC__Select__c = false;
        ToolbarAction1.SVMXC__Sequence__c = 1 ;
        //ToolbarAction1.SVMXC__Module__c = ToolbarRec.Id; //Toolbar defn lookup
        //ToolbarAction1.SVMXC__Process__c = SampleProcess.Id;
        ToolbarAction1.SVMXC__Name__c = 'ToolbarAction1001';
        ToolbarAction1.SVMXC__ProcessID__c = 'ToolbarAction002';
        ToolbarAction1.SVMXC__SettingID__c = 'ToolbarAction002';
        ToolbarAction1.SVMXC__Description__c = 'Sample Description';
        ToolbarAction1.SVMXC__Action_Type__c = 'OTHERS';
        ToolbarAction1.SVMXC__Action_URL__c = 'New url';
        //ToolbarAction1.SVMXC__Submodule__c = ; //named expression lookup
        ToolbarAction1.SVMXC__IsStandard__c = false;
        ToolbarAction1.RecordTypeId = RtypeSVMX_Toolbar_Action.Id;
        ToolbarAction1.SVMXC__Sequence__c = 2;
        //insert ToolbarAction1;
        system.assert(ToolbarAction1.SVMXC__SettingID__c!=null);
        system.assert(ToolbarAction1.SVMXC__Action_Type__c!=null);
        
        SVMX_Sequence seq = new SVMX_Sequence();
        SVMXC__ServiceMax_Processes__c[] lstProcess = seq.getTempProcessObjLst();
       /* SVMXC__ServiceMax_Processes__c process = new SVMXC__ServiceMax_Processes__c();
        process.SVMXC__Name__c = 'process123';
        SVMXC__ServiceMax_Processes__c process1 = new SVMXC__ServiceMax_Processes__c();
        process1.SVMXC__Name__c = 'process12345';*/
        lstProcess.add(ToolbarAction);
        lstProcess.add(ToolbarAction1);
        insert lstProcess;
        seq.setTempProcessObjLst(lstProcess);
        integer selIndex = 0;
        boolean isTop = true;
        seq.shuffle(selIndex,isTop);
        List<String> lstStr = new List<String>();
        string str1 = ToolbarAction.id;
        lstStr.clear();
        lstStr.add(str1);
        seq.setitems(lstStr);
        seq.Top();
        seq.UP();
        seq.Down();
        seq.Bottom();
        str1 = ToolbarAction.id;
        lstStr.clear();
        lstStr.add(str1);
        seq.setitems(lstStr);
        seq.Top();
        seq.UP();
        seq.Down();
        seq.Bottom();
        PageReference pagRef = seq.SVMX_Cancel();
        pagereference pagRef1 = seq.SVMX_SaveSequence();
        List<SelectOption> sltOptn = seq.getActionOptns();
        lstStr = seq.getitems();
        isTop = false;
        seq.shuffle(selIndex,isTop);
    }
   
   static testMethod void SVMX_SequenceUnitTest1() 
    {
    	// System Assert
	     Account testAccount = new Account(name='Test Company Name');
	     insert testAccount;
	     testAccount.billingState='CA';
	     update testAccount;
	     // Verify that the billingState field was updated in the database.
	     Account updatedAccount = [SELECT billingState FROM Account WHERE Id = :testAccount.Id];
	     System.assertEquals('CA', updatedAccount.billingState);
    	
        RecordType RtypeSVMX_Toolbar_Action = [Select Id, Name from RecordType where Name = 'SF Action' AND SObjectType = 'SVMXC__ServiceMax_Processes__c' Limit 1];
        SVMXC__ServiceMax_Processes__c ToolbarAction = new SVMXC__ServiceMax_Processes__c();
        ToolbarAction.SVMXC__Select__c = false;
        ToolbarAction.SVMXC__Sequence__c = 1 ;
        //ToolbarAction.SVMXC__Module__c = ToolbarRec.Id; //Toolbar defn lookup
        //ToolbarAction.SVMXC__Process__c = SampleProcess.Id;
        ToolbarAction.SVMXC__Name__c = 'ToolbarAction001';
        ToolbarAction.SVMXC__ProcessID__c = 'ToolbarAction001';
        ToolbarAction.SVMXC__SettingID__c = 'ToolbarAction001';
        ToolbarAction.SVMXC__Description__c = 'Sample Description';
        ToolbarAction.SVMXC__Action_Type__c = 'OTHERS';
        ToolbarAction.SVMXC__Action_URL__c = 'New url';
        //ToolbarAction.SVMXC__Submodule__c = ; //named expression lookup
        ToolbarAction.SVMXC__IsStandard__c = false;
        ToolbarAction.RecordTypeId = RtypeSVMX_Toolbar_Action.Id;
        ToolbarAction.SVMXC__Sequence__c = 1;
        //insert ToolbarAction;
        system.assert(ToolbarAction.SVMXC__SettingID__c!=null);
        system.assert(ToolbarAction.SVMXC__Action_Type__c!=null);
        
         SVMXC__ServiceMax_Processes__c ToolbarAction1 = new SVMXC__ServiceMax_Processes__c();
        ToolbarAction1.SVMXC__Select__c = false;
        ToolbarAction1.SVMXC__Sequence__c = 1 ;
        //ToolbarAction1.SVMXC__Module__c = ToolbarRec.Id; //Toolbar defn lookup
        //ToolbarAction1.SVMXC__Process__c = SampleProcess.Id;
        ToolbarAction1.SVMXC__Name__c = 'ToolbarAction1001';
        ToolbarAction1.SVMXC__ProcessID__c = 'ToolbarAction002';
        ToolbarAction1.SVMXC__SettingID__c = 'ToolbarAction002';
        ToolbarAction1.SVMXC__Description__c = 'Sample Description';
        ToolbarAction1.SVMXC__Action_Type__c = 'OTHERS';
        ToolbarAction1.SVMXC__Action_URL__c = 'New url';
        //ToolbarAction1.SVMXC__Submodule__c = ; //named expression lookup
        ToolbarAction1.SVMXC__IsStandard__c = false;
        ToolbarAction1.RecordTypeId = RtypeSVMX_Toolbar_Action.Id;
        ToolbarAction1.SVMXC__Sequence__c = 2;
        //insert ToolbarAction1;
         system.assert(ToolbarAction1.SVMXC__SettingID__c!=null);
        system.assert(ToolbarAction1.SVMXC__Action_Type__c!=null);

        SVMX_Sequence seq = new SVMX_Sequence();
        SVMXC__ServiceMax_Processes__c[] lstProcess = seq.getTempProcessObjLst();
        /*SVMXC__ServiceMax_Processes__c process = new SVMXC__ServiceMax_Processes__c();
        process.SVMXC__Name__c = 'process123';
        SVMXC__ServiceMax_Processes__c process1 = new SVMXC__ServiceMax_Processes__c();
        process1.SVMXC__Name__c = 'process12345';*/
        lstProcess.add(ToolbarAction);
        lstProcess.add(ToolbarAction1);
        insert lstProcess;
        seq.setTempProcessObjLst(lstProcess);
        integer selIndex = 0;
        boolean isTop = true;
        seq.shuffle(selIndex,isTop);
        List<String> lstStr = new List<String>();
        //string str1 = process1.id;
        lstStr.clear();
        //lstStr.add(str1);
        seq.setitems(lstStr);
        seq.Top();
        pagereference pagRef1 = seq.SVMX_SaveSequence();
        seq.UP();
        pagRef1 = seq.SVMX_SaveSequence();
        seq.Bottom();
        pagRef1 = seq.SVMX_SaveSequence();
        PageReference pagRef = seq.SVMX_Cancel();
        List<SelectOption> sltOptn = seq.getActionOptns();
        lstStr = seq.getitems();
        isTop = false;
        seq.shuffle(selIndex,isTop);
        seq.getTAG001();
        seq.getTAG002();
        seq.getTAG003();
        seq.isUpAction = true;
        seq.SVMX_SaveSequence();
        seq.isUpAction = false;
        seq.isDownAction = false;
        seq.isTopAction = true;
        seq.SVMX_SaveSequence();
        seq.isUpAction = false;
        seq.isDownAction = false;
        seq.isTopAction = false;
        seq.isBottomAction = true;
        seq.SVMX_SaveSequence();
        seq.getTAG004();    
        seq.getTAG005();
        seq.getTAG006();
    } 
}