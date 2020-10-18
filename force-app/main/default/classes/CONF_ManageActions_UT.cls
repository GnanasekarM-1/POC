@isTest(SeeAllData=true)
private class CONF_ManageActions_UT 
{
    static testMethod void CONF_ManageActionsUnitTest() 
    {
        List<SelectOption> sortList = new List<SelectOption>();
        sortList.add(new SelectOption('B','B'));
        sortList.add(new SelectOption('A','A'));
        
        CONF_ManageActions mngActn = new CONF_ManageActions();
        mngActn.sortingSelectOption(sortList);
        List<SVMXC__ServiceMax_Processes__c> o = mngActn.getstandardActionsLst();
        mngActn.setstandardActionsLst(o);
        List<SVMXC__ServiceMax_Processes__c> c = mngActn.getcustomActionLst();
        mngActn.setcustomActionLst(c);
        List<SelectOption> ObjectsWithAction = mngActn.getObjectsWithAction();
        string val = mngActn.getSelectedSourceObject();
        val = '--None--';
        system.assert(val!=null);
        mngActn.setSelectedSourceObject(val);
        pagereference pgRef1 = mngActn.selectedObjectActions();
        pagereference pgRef2 = mngActn.StdView();
        pagereference pgRef3 = mngActn.StdClone();
        pagereference pgRef4 = mngActn.Stdbacktosetuphme();
        pagereference pgRef5 = mngActn.CustomNew();
        pagereference pgRef6 = mngActn.CustomEdit();
        pagereference pgRef7 = mngActn.CustomClone();
        pagereference pgRef8 = mngActn.CustomDelete();
        string s1 = mngActn.getTAG001();
        string s2 = mngActn.getTAG002();
        string s3 = mngActn.getTAG003();
        string s4 = mngActn.getTAG004();
        string s5 = mngActn.getTAG005();
        string s6 = mngActn.getTAG006();
        string s7 = mngActn.getTAG007();
        string s8 = mngActn.getTAG008();
        string s9 = mngActn.getTAG009();
        string s10 = mngActn.getTAG010();
        string s11 = mngActn.getTAG011();
        string s12 = mngActn.getTAG012();
        string s13 = mngActn.getTAG013();
        string s14 = mngActn.getTAG014();
        string s15 = mngActn.getTAG015();
        string s16 = mngActn.getTAG017();
        string s17 = mngActn.getTAG018();
        string s18 = mngActn.getTAG019();
        system.assert(s16!=null);
        system.assert(s17!=null);
        system.assert(s18!=null);
        //string s19 = mngActn.getTAG020();
        //string s20 = mngActn.getTAG021();
        string s21 = mngActn.getTAG022();
        s21 = mngActn.getHLPURL();
        //string s22 = mngActn.getTAG023();
        //string s23 = mngActn.getTAG024();
        //string s24 = mngActn.getTAG025();
        //string s25 = mngActn.getTAG026();
        string s26 = mngActn.getTAG028();
        //string s27 = mngActn.getTAG029();
        //string s28 = mngActn.getTAG030();
        string s29 = mngActn.getTAG031();
        string s30 = mngActn.getTAG032();
        string s31 = mngActn.getTAG033();
        //boolean b = mngActn.getDisableStdBtn();
        boolean b = mngActn.getDisableCusBtn();
        b = mngActn.getRender();
        //mngActn.setDisableStdBtn(b);
        mngActn.setDisableCusBtn(b);
        mngActn.setRender(b);
    }
    
    
    static testMethod void CONF_ManageActionsUnitTest1() 
    {
        String ActionRTypeId = '';
        String ActionRTypeId1 = '';
        
        RecordType Action_Rtype;
        RecordType Parameter_RType;
        //------------------ Querying the Record Types for the SF Action --------------------------
        Action_Rtype = [Select Id, SobjectType, Name From RecordType where SobjectType = 'SVMXC__ServiceMax_Processes__c' and Name = 'SF Action' Limit 1];
        ActionRTypeId = Action_Rtype.Id;
        
        //---------------- Querying the Record Types for the SF Action Parameter ------------------------
        Parameter_RType = [Select Id, SobjectType, Name From RecordType where SobjectType = 'SVMXC__ServiceMax_Config_Data__c' and Name = 'SF Action Parameter'];
        ActionRTypeId1 = Parameter_RType.Id;
        
        //List<SVMXC__ServiceMax_Processes__c> processLst = new List<SVMXC__ServiceMax_Processes__c>();
        SVMXC__ServiceMax_Processes__c process = new SVMXC__ServiceMax_Processes__c();
        process.SVMXC__Name__c = 'process12';
        process.RecordTypeId = ActionRTypeId;
        process.SVMXC__IsStandard__c = true;
        process.SVMXC__Source_Object_Name__c = 'SVMXC__Service_Order__c';
        process.SVMXC__Select__c = true;
        insert process;
        system.assert(process.SVMXC__Name__c!=null);
        system.assert(process.SVMXC__IsStandard__c == true);
        //processLst.add(process);
        
        SVMXC__ServiceMax_Processes__c process1 = new SVMXC__ServiceMax_Processes__c();
        process1.SVMXC__Name__c = 'process21';
        process1.RecordTypeId = ActionRTypeId;
        process1.SVMXC__IsStandard__c = false;
        process1.SVMXC__Source_Object_Name__c = 'SVMXC__Service_Order__c';
        process1.SVMXC__Select__c = true;
        insert process1;
        system.assert(process1.SVMXC__Name__c!=null);
        //processLst.add(process1);
        
        //insert processLst;
        
        CONF_ManageActions mngActn = new CONF_ManageActions();
        
        string val = 'SVMXC__Service_Order__c';
        system.assert(val!=null);
        mngActn.setSelectedSourceObject(val);
        
        pagereference pagRef = mngActn.selectedObjectActions();
        pagereference pagRef1 = mngActn.StdView();
        pagereference pagRef2 = mngActn.StdClone();
        pagereference pagRef3 = mngActn.CustomNew();
        pagereference pagRef4 = mngActn.CustomEdit();
        pagereference pagRef5 = mngActn.CustomClone();
        pagereference pagRef6 = mngActn.CustomDelete();
    }
    
    static testMethod void CONF_ManageActionsUnitTest2() 
    {
        String ActionRTypeId = '';
        String ActionRTypeId1 = '';
        
        RecordType Action_Rtype;
        RecordType Parameter_RType;
        //------------------ Querying the Record Types for the SF Action --------------------------
        Action_Rtype = [Select Id, SobjectType, Name From RecordType where SobjectType = 'SVMXC__ServiceMax_Processes__c' and Name = 'SF Action' Limit 1];
        ActionRTypeId = Action_Rtype.Id;
        
        //---------------- Querying the Record Types for the SF Action Parameter ------------------------
        Parameter_RType = [Select Id, SobjectType, Name From RecordType where SobjectType = 'SVMXC__ServiceMax_Config_Data__c' and Name = 'SF Action Parameter'];
        ActionRTypeId1 = Parameter_RType.Id;
        
        SVMXC__ServiceMax_Processes__c process = new SVMXC__ServiceMax_Processes__c();
        process.SVMXC__Name__c = 'process12';
        process.RecordTypeId = ActionRTypeId;
        process.SVMXC__IsStandard__c = true;
        process.SVMXC__Source_Object_Name__c = 'SVMXC__Service_Order__c';
        process.SVMXC__Select__c = true;
        insert process;
        system.assert(process.SVMXC__Name__c!=null);
        system.assert(process.SVMXC__Source_Object_Name__c!=null);
        
        SVMXC__ServiceMax_Processes__c process1 = new SVMXC__ServiceMax_Processes__c();
        process1.SVMXC__Name__c = 'process21';
        process1.RecordTypeId = ActionRTypeId;
        process1.SVMXC__IsStandard__c = false;
        process1.SVMXC__Source_Object_Name__c = 'SVMXC__Service_Order__c';
        process1.SVMXC__Select__c = true;
        insert process1;
        system.assert(process1.SVMXC__Name__c!=null);
        system.assert(process1.SVMXC__Source_Object_Name__c!=null);
        
        SVMXC__ServiceMax_Processes__c process2 = new SVMXC__ServiceMax_Processes__c();
        process2.SVMXC__Name__c = 'process12';
        process2.RecordTypeId = ActionRTypeId;
        process2.SVMXC__IsStandard__c = true;
        process2.SVMXC__Source_Object_Name__c = 'SVMXC__Service_Order__c';
        process2.SVMXC__Select__c = true;
        insert process2;
        system.assert(process2.SVMXC__Name__c!=null);
        
        SVMXC__ServiceMax_Processes__c process3 = new SVMXC__ServiceMax_Processes__c();
        process3.SVMXC__Name__c = 'process21';
        process3.RecordTypeId = ActionRTypeId;
        process3.SVMXC__IsStandard__c = false;
        process3.SVMXC__Source_Object_Name__c = 'SVMXC__Service_Order__c';
        process3.SVMXC__Select__c = true;
        insert process3;
        system.assert(process3.SVMXC__Name__c!=null);
        
        CONF_ManageActions mngActn = new CONF_ManageActions();
        
        string val = 'SVMXC__Service_Order__c';
        mngActn.setSelectedSourceObject(val);
        
        pagereference pagRef = mngActn.selectedObjectActions();
        pagereference pagRef1 = mngActn.StdView();
        pagereference pagRef2 = mngActn.StdClone();
        pagereference pagRef3 = mngActn.CustomNew();
        pagereference pagRef4 = mngActn.CustomEdit();
        pagereference pagRef5 = mngActn.CustomClone();
        pagereference pagRef6 = mngActn.CustomDelete();
    }
}