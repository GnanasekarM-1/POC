@isTest (seeAllData = true)
Private class CONF_SetupPMProcess_UT
{
    static testMethod void CONF_SetupPMProcess_UnitTest()
    {
    SVMXC__ServiceMax_Processes__c PMProcess1 = new SVMXC__ServiceMax_Processes__c();
        System.currentPageReference().getParameters().put('SVMX_Mode', 'New');
        
        RecordType PMProcess_Rtype = [select Id from RecordType where Name='PM Process'and SobjectType='SVMXC__ServiceMax_Processes__c' Limit 1];
        
        CONF_SetupPMProcess PMPlanobj1 = new CONF_SetupPMProcess();
        PMPlanobj1.strProcessName = 'PMProcess3cess000333';
        PMPlanobj1.strProcessID = 'PMProcess3cess000333';
        PMPlanobj1.strCreateWorkOrder = 'One Per Plan';
        PMPlanobj1.strSelectedExp = PMPlanobj1.getTAG009();
        PMPlanobj1.objPMPlanProcess.SVMXC__Email_On_Error__c = 'abc@abc.com';
        PMPlanobj1.objPMPlanProcess.Include_Parent__c = false;
        PMPlanobj1.strAssignWOto= PMPlanobj1.getTAG009();               
        RecordType ObjMap_Rtype = [select Id from RecordType where Name='Object Mapping'and SobjectType='SVMXC__ServiceMax_Processes__c' Limit 1];
        SVMXC__ServiceMax_Processes__c tempWOmap = new SVMXC__ServiceMax_Processes__c();
        tempWOmap.SVMXC__Name__c = 'PMProcess123564';
        tempWOmap.SVMXC__ProcessID__c = 'PMProcess123564';
        tempWOmap.SVMXC__MapID__c = 'PMProcess123564';
        tempWOmap.SVMXC__Description__c = 'PMProcess123564';        
        tempWOmap.RecordTypeId = ObjMap_Rtype.Id;
        insert tempWOmap;        
        PMPlanobj1.strSelectedWOmap=tempWOmap.id;
        SVMXC__ServiceMax_Config_Data__c confData3 = new SVMXC__ServiceMax_Config_Data__c();
        confData3.SVMXC__Sequence__c = 1;
        confData3.SVMXC__Run_At__c = '00:00 AM';
        confData3.SVMXC__Run_Type__c='Date of Month';
        PMPlanobj1.Chngruntype();
        confData3.SVMXC__Day_to_Run__c='15';
        PMPlanobj1.lstSchedules.add(confData3); 
        PMPlanobj1.quicksave();
        PMPlanobj1.saveClose();        
    }
    
    static testMethod void CONF_SetupPMProcess_UnitTest1()
    {
    SVMXC__ServiceMax_Processes__c PMProcess1 = new SVMXC__ServiceMax_Processes__c();
        System.currentPageReference().getParameters().put('SVMX_Mode', 'New');
        
        RecordType PMProcess_Rtype = [select Id from RecordType where Name='PM Process'and SobjectType='SVMXC__ServiceMax_Processes__c' Limit 1];
        
        CONF_SetupPMProcess PMPlanobj1 = new CONF_SetupPMProcess();
        PMPlanobj1.strProcessName = 'PMProcess3cess000333';
        PMPlanobj1.strProcessID = 'PMProcess3cess000333';
        
        PMPlanobj1.onChngCreateWO();
        PMPlanobj1.strCreateWorkOrder = 'One Per Plan';
        PMPlanobj1.onChngCreateWO();
         PMPlanobj1.strCreateWorkOrder = 'One Per Product';
        PMPlanobj1.onChngCreateWO();
        PMPlanobj1.strAssignWOto = PMPlanobj1.getTAG009();
        PMPlanobj1.visibilitycontrol();
        PMPlanobj1.quicksave();
        PMPlanobj1.strAssignWOto = 'Dispatcher';
        PMPlanobj1.visibilitycontrol();
        PMPlanobj1.quicksave();
        PMPlanobj1.strAssignWOto = 'Queue';
        PMPlanobj1.visibilitycontrol();
        PMPlanobj1.quicksave();
        PMPlanobj1.strAssignWOto = 'Team';
        PMPlanobj1.visibilitycontrol();
        PMPlanobj1.quicksave();
        PMPlanobj1.strAssignWOto = 'Technician';
        PMPlanobj1.visibilitycontrol();
        PMPlanobj1.quicksave();
        PMPlanobj1.objPMPlanProcess.Include_Parent__c = true;
        PMPlanobj1.visibilitycontrol();
        PMPlanobj1.objPMPlanProcess.Assign_Case_To__c =PMPlanobj1.getTAG009();
        PMPlanobj1.visibilitycontrol();
        PMPlanobj1.quicksave();
        PMPlanobj1.objPMPlanProcess.Assign_Case_To__c = 'User';
        PMPlanobj1.visibilitycontrol();
        PMPlanobj1.quicksave();
        PMPlanobj1.objPMPlanProcess.Assign_Case_To__c = 'Queue';
        PMPlanobj1.visibilitycontrol();
        PMPlanobj1.quicksave();
        PMPlanobj1.objPMPlanProcess.Include_Parent__c = false;
        PMPlanobj1.visibilitycontrol();
        PMPlanobj1.objPMPlanProcess.Include_Parent__c = true;
        PMPlanobj1.visibilitycontrol();
        PMPlanobj1.strSelectedExp = PMPlanobj1.getTAG009();
        PMPlanobj1.quicksave();
        PMPlanobj1.strCreateWorkOrder = PMPlanobj1.getTAG009();
        PMPlanobj1.quicksave();
        PMPlanobj1.strSelectedWOmap = PMPlanobj1.getTAG009();
        PMPlanobj1.quicksave();
        PMPlanobj1.strSelectedCasemap = PMPlanobj1.getTAG009();
        PMPlanobj1.quicksave();
        PMPlanobj1.NewExp();
        PMPlanobj1.getExpPM();
        PMPlanobj1.HdrDeleteRowExp();
        PMPlanobj1.GeneralInfo();
        PMPlanobj1.SrcUpd();
        PMPlanobj1.Schedules();
        PMPlanobj1.setobjPMPlanProcess(PMPlanobj1.getobjPMPlanProcess());
        PMPlanobj1.setlstSchedules(PMPlanobj1.getlstSchedules());
        PMPlanobj1.setintExpDetailSize(PMPlanobj1.getintExpDetailSize());
        PMPlanobj1.getlstCriteria();
        PMPlanobj1.setlstUpdateOperator(PMPlanobj1.getlstUpdateOperator());
        PMPlanobj1.lstCreateWOonpicklst.add(new SelectOption(PMPlanobj1.getTAG009(),PMPlanobj1.getTAG009()));
        PMPlanobj1.getlstCreateWOonpicklst();
        PMPlanobj1.lstWOmaptousepicklist.add(new SelectOption(PMPlanobj1.getTAG009(),PMPlanobj1.getTAG009()));
        PMPlanobj1.getlstWOmaptousepicklist();
        PMPlanobj1.getlstAssignWOpicklst();
        PMPlanobj1.getlstCasemaptousepicklst();
        PMPlanobj1.getlstOperatorSelectLst();
        PMPlanobj1.getintSeqVal();
        PMPlanobj1.getlstPMplanfield();
        PMPlanobj1.getlstQueuepicklstWO();
        PMPlanobj1.getlstQueuepicklstcase();
        PMPlanobj1.setsavedExpressionResultId(PMPlanobj1.getsavedExpressionResultId());
        PMPlanobj1.cancel();
        PMPlanobj1.getHLPURL();
        PMPlanobj1.getHLPTITLE();
        PMPlanobj1.getTAG001();
        PMPlanobj1.getTAG002();
        PMPlanobj1.getTAG003();
        PMPlanobj1.getTAG004();
        PMPlanobj1.getTAG005();
        PMPlanobj1.getTAG006();
        PMPlanobj1.getTAG007();
        PMPlanobj1.getTAG008();
        PMPlanobj1.getTAG009();
        PMPlanobj1.getTAG010();
        PMPlanobj1.getTAG011();
        PMPlanobj1.getTAG012();
        PMPlanobj1.getTAG013();
        PMPlanobj1.getTAG014();
        PMPlanobj1.getTAG015();
        PMPlanobj1.getTAG016();
        PMPlanobj1.getTAG017();
        PMPlanobj1.getTAG018();
        PMPlanobj1.getTAG019();
        PMPlanobj1.getTAG020();
        PMPlanobj1.getTAG021();
        PMPlanobj1.getTAG022();
        PMPlanobj1.getTAG023();
        PMPlanobj1.getTAG024();
        PMPlanobj1.getTAG025();
        PMPlanobj1.getTAG026();
        PMPlanobj1.getTAG027();
        PMPlanobj1.getTAG028();
        PMPlanobj1.getTAG029();
        PMPlanobj1.getTAG030();
        PMPlanobj1.getTAG031();
        PMPlanobj1.getTAG032();
        PMPlanobj1.getTAG033();
        PMPlanobj1.getTAG034();
        PMPlanobj1.getTAG035();
        PMPlanobj1.getTAG036();
        PMPlanobj1.getTAG037();
        PMPlanobj1.getTAG038();
        PMPlanobj1.getTAG039();
        PMPlanobj1.getTAG040();
        PMPlanobj1.getTAG041();
        PMPlanobj1.getTAG042();
        PMPlanobj1.getTAG043();
        PMPlanobj1.getTAG044();
        PMPlanobj1.getTAG045();
        PMPlanobj1.getTAG046();
        PMPlanobj1.getTAG047();
        PMPlanobj1.getTAG048();
        PMPlanobj1.getTAG049();
        PMPlanobj1.getTAG050();
        PMPlanobj1.getTAG051();
        PMPlanobj1.getTAG052();
        PMPlanobj1.getTAG053();
        PMPlanobj1.getTAG054();
        PMPlanobj1.getTAG055();
        PMPlanobj1.getTAG056();
        PMPlanobj1.getTAG057();
        PMPlanobj1.getTAG058();
        PMPlanobj1.getTAG059();
        PMPlanobj1.getTAG073();
        PMPlanobj1.getTAG074();
        PMPlanobj1.getTAG075();
        PMPlanobj1.getTAG076();
        PMPlanobj1.getTAG078();
        
       
        PMPlanobj1.strSelectedExp = PMPlanobj1.getTAG009();
        PMPlanobj1.objPMPlanProcess.SVMXC__Name__c='PMProcess3cess000333';
        PMPlanobj1.objPMPlanProcess.SVMXC__ProcessID__c = 'PMProcess3cess000333';
        PMPlanobj1.objPMPlanProcess.SVMXC__Email_On_Error__c = 'abc@abc.com';
        PMPlanobj1.strAssignWOto= PMPlanobj1.getTAG009();
        PMPlanobj1.quicksave();
       
        
        SVMXC__ServiceMax_Processes__c PMProcess2 = new SVMXC__ServiceMax_Processes__c();
        PMProcess2.SVMXC__Name__c = 'PMProcess123564';
        PMProcess2.SVMXC__ProcessID__c = 'PMProcess123564';
        PMProcess2.SVMXC__Description__c = 'PMProcess123564';
        PMProcess2.SVMXC__Email_On_Error__c = 'abc@abc.com';
        PMProcess2.RecordTypeId = PMProcess_Rtype.Id;
        
        insert PMProcess2;
        
        System.currentPageReference().getParameters().put('SVMX_Mode', 'Edit');
        System.currentPageReference().getParameters().put('SVMX_RecordId', PMProcess2.Id);
        CONF_SetupPMProcess PMplanobj2 = new CONF_SetupPMProcess();
        PMplanobj2.strProcessName='PMProcess123564';
        PMplanobj2.strProcessID='PMProcess123564';
        PMplanobj2.strSelectedExp = PMplanobj2.getTAG009();
        PMplanobj2.strAssignWOto=PMplanobj2.getTAG009();
        PMplanobj2.objPMPlanProcess.Include_Parent__c=true;
        PMplanobj2.objPMPlanProcess.Assign_Case_To__c=PMplanobj2.getTAG009();
        PMplanobj2.quickSave();
        PMplanobj2.saveClose();
        
        System.currentPageReference().getParameters().put('SVMX_Mode', 'Clone');
        CONF_SetupPMProcess PMObj2 = new CONF_SetupPMProcess();
        
        PMObj2.onChngExp();
        PMObj2.EditExp();
        PMObj2.HdrADDRowExp();
    }
    
   static testMethod void CONF_SetupPMProcess_UnitTest2()
    {
       System.currentPageReference().getParameters().put('SVMX_Mode', 'New');
        
        RecordType PMProcess_Rtype = [select Id from RecordType where Name='PM Process'and SobjectType='SVMXC__ServiceMax_Processes__c' Limit 1];
        RecordType ExpHdr_Rtype = [select Id from RecordType where Name='SVMX Rule'and SobjectType='SVMXC__ServiceMax_Processes__c' Limit 1];
        RecordType ExpDtl_Rtype = [select Id from RecordType where Name='Expressions'and SobjectType='SVMXC__ServiceMax_Config_Data__c' Limit 1];
        RecordType ExpSrcUpdate_Rtype = [select Id from RecordType where Name='Field Mapping'and SobjectType='SVMXC__ServiceMax_Config_Data__c' Limit 1];
        RecordType Schedule_Rtype = [select Id from RecordType where Name='Schedule'and SobjectType='SVMXC__ServiceMax_Config_Data__c' Limit 1];
        
         CONF_SetupPMProcess PMPlanobj3 = new CONF_SetupPMProcess();
        PMPlanobj3.strProcessName = 'WOProcess000101';
        PMPlanobj3.strProcessID = 'WOProcess000101';
        PMPlanobj3.strprocessDesc = 'WOProcess000101';
        PMPlanobj3.objPMPlanProcess.SVMXC__Email_On_Error__c = 'abc@abc.com';
        PMPlanobj3.objPMPlanProcess.SVMXC__Email_On_Success__c = 'abc@abc.com';
        PMPlanobj3.NewExp();
        PMPlanobj3.ExpPM.namedExpression.SVMXC__Name__c = 'TestExp000100';
        PMPlanobj3.ExpPM.namedExpression.SVMXC__ProcessID__c = 'TestExp000100';
        
        SVMXC__ServiceMax_Config_Data__c confData = new SVMXC__ServiceMax_Config_Data__c();
        confData.RecordTypeId = ExpDtl_Rtype.Id;
        confData.SVMXC__Field_Name__c = 'SVMXC__Active__c';
        confData.SVMXC__Operator__c = 'eq';
        confData.SVMXC__Operand__c = 'true';
        insert confData;
        PMPlanobj3.ExpPM.expressionDetails.add(confData);
       // PMPlanobj3.saveexps();
        PMPlanobj3.submitexp();
        PMPlanobj3.retrieveExpDetails('TestExp000100');
        PMPlanobj3.strselectedExp = 'TestExp000100';
        PMPlanobj3.onChngExp();
        PMPlanobj3.intSeqVal= 1;
        SVMXC__ServiceMax_Config_Data__c confData2 = new SVMXC__ServiceMax_Config_Data__c();
         confData2.SVMXC__Sequence__c = 1;
        confData2.SVMXC__Run_At__c = '00:00 AM';
        PMPlanobj3.quickSave();
        confData2.SVMXC__Run_Type__c=PMPlanobj3.getTAG009();
        PMPlanobj3.Chngruntype();
         PMPlanobj3.quickSave();
        confData2.SVMXC__Run_Type__c='Day of Week';
        PMPlanobj3.Chngruntype();
         PMPlanobj3.quickSave();
        confData2.SVMXC__Schedule_Days__c = 'Sunday';
         PMPlanobj3.quickSave();
       //confData2.SVMXC__Day_to_Run__c=null;
        PMPlanobj3.lstSchedules.add(confData2);
        
        PMPlanobj3.quickSave();
        PMPlanobj3.HdrDeleteRow();
        PMPlanobj3.strSelectedRow = '1';
        PMPlanobj3.lstSchedules_DelRow();
        PMPlanobj3.intSeqVal= 1;
        SVMXC__ServiceMax_Config_Data__c confData3 = new SVMXC__ServiceMax_Config_Data__c();
        confData3.SVMXC__Sequence__c = 1;
        confData3.SVMXC__Run_At__c = '00:00 AM';
        confData2.SVMXC__Run_Type__c='Date of Month';
        PMPlanobj3.Chngruntype();
        confData2.SVMXC__Day_to_Run__c='15';
        PMPlanobj3.lstSchedules.add(confData3);
        PMPlanobj3.strCreateWorkOrder=PMPlanobj3.getTAG039();
        
        
        PMPlanobj3.objPMPlanProcess.Include_Parent__c=false;
        PMPlanobj3.strSelectedCasemap=PMPlanobj3.getTAG009();
        
        PMPlanobj3.quickSave();
         CONF_SetupPMProcess PMPlanobj5 = new CONF_SetupPMProcess();
         PMPlanobj5.strProcessName = 'WOProcess0001034';
        PMPlanobj5.strProcessID = 'WOProcess0001034';
        PMPlanobj5.objPMPlanProcess.SVMXC__Email_On_Error__c = 'abc@abc.com';
        PMPlanobj5.strCreateWorkOrder=PMPlanobj5.getTAG039();
        SVMXC__ServiceMax_Processes__c SelectedWOmaptouse = new SVMXC__ServiceMax_Processes__c();
        SelectedWOmaptouse.SVMXC__Name__c = 'PMProcess123564';
        SelectedWOmaptouse.SVMXC__ProcessID__c = 'PMProcess123564';
        SelectedWOmaptouse.SVMXC__MapID__c = 'PMProcess123564';
        SelectedWOmaptouse.SVMXC__Description__c = 'PMProcess123564';   
        RecordType ObjMap_Rtype;
        ObjMap_Rtype = [select Id from RecordType where Name='Object Mapping'and SobjectType='SVMXC__ServiceMax_Processes__c' Limit 1];       
        SelectedWOmaptouse.RecordTypeId =ObjMap_Rtype.Id;
        
        insert SelectedWOmaptouse;
        PMPlanobj5.strSelectedWOmap=SelectedWOmaptouse.id;  
        PMPlanobj5.objPMPlanProcess.SVMXC__Node_Parent__c =SelectedWOmaptouse.id; 
        PMPlanobj5.objPMPlanProcess.Include_Parent__c=false;
         PMPlanobj5.quickSave();      
         PMPlanobj5.strAssignWOto= PMPlanobj5.getTAG009();
         PMPlanobj5.quickSave(); 
         PMPlanobj5.strAssignWOto ='Dispatcher';
          PMPlanobj5.quickSave(); 
         PMPlanobj5.strAssignWOto ='Queue';
         PMPlanobj5.quickSave(); 
        PMPlanobj5.strAssignWOto ='Team';
        PMPlanobj5.quickSave(); 
        PMPlanobj5.strSelectedCasemap = PMPlanobj5.getTAG009();
        PMPlanobj5.objPMPlanProcess.Assign_Case_To__c =PMPlanobj5.getTAG009();
        PMPlanobj5.objPMPlanProcess.Assign_Case_To__c = 'User';
        PMPlanobj5.strAssignWOto = 'Technician';
        PMPlanobj5.strSelectedQueueforWO='aaaaa';
        PMPlanobj5.strSelectedQueueforCase='aaaaa';
        PMPlanobj5.objPMPlanProcess.Frequency__c=null;
        
        PMPlanobj5.quickSave();
        PMPlanobj5.saveclose();
        
    }
    static testMethod void CONF_SetupPMProcess_UnitTest3()
    {
    System.currentPageReference().getParameters().put('SVMX_Mode', 'New');
        CONF_SetupPMProcess PMPlanobj4= new CONF_SetupPMProcess();
        PMPlanobj4.submitExp();
        SVMXC__ServiceMax_Processes__c PMProcess5 = new SVMXC__ServiceMax_Processes__c();
        PMPlanobj4.strProcessName = '';
        PMPlanobj4.strProcessID = 'processtest';
        PMProcess5.SVMXC__Name__c = '';
            PMPlanobj4.validation();
            PMPlanobj4.strProcessName = 'processtest';
            PMPlanobj4.strProcessID = '';
        PMProcess5.SVMXC__ProcessID__c = '';
            PMPlanobj4.validation();
            PMPlanobj4.strProcessName = 'processtest';
            PMPlanobj4.strProcessID = 'processtest';
        PMProcess5.SVMXC__ProcessID__c = 'processtest';
        PMProcess5.SVMXC__Email_On_Error__c = '';
        
        PMPlanobj4.validation();
         RecordType PMProcess_Rtype = [select Id from RecordType where Name='PM Process'and SobjectType='SVMXC__ServiceMax_Processes__c' Limit 1];
        SVMXC__ServiceMax_Processes__c PMProcess4 = new SVMXC__ServiceMax_Processes__c();
        PMProcess4.SVMXC__Name__c = 'PMProcess123564';
        PMProcess4.SVMXC__ProcessID__c = 'PMProcess123564';
        PMProcess4.SVMXC__Description__c = 'PMProcess123564';
        PMProcess4.SVMXC__Email_On_Error__c = 'abc@abc.com';
        PMProcess4.RecordTypeId = PMProcess_Rtype.Id;
        
        insert PMProcess4;
        System.currentPageReference().getParameters().put('SVMX_Mode', 'Clone');
        System.currentPageReference().getParameters().put('SVMX_RecordId', PMProcess4.Id);
        PMPlanobj4.setDefaultValues();
        PMPlanobj4.onChngLocBased();
        PMPlanobj4.retrieveRecordTypes();
        PMPlanobj4.preparingPicklists();
        PMPlanobj4.sortingSelectOption(new List<SelectOption>());
        PMPlanobj4.onChngSelectedTaskObject();
        PMPlanobj4.getTAG060();
        PMPlanobj4.getTAG061();
        PMPlanobj4.getTAG062();
        PMPlanobj4.getTAG063();
        PMPlanobj4.getTAG064();
        PMPlanobj4.getTAG065();
        PMPlanobj4.getTAG066();
        PMPlanobj4.getTAG067();
        PMPlanobj4.getTAG068();
        PMPlanobj4.getTAG069();
        PMPlanobj4.getTAG070();
        PMPlanobj4.getTAG071();
        PMPlanobj4.getTAG072();
        PMPlanobj4.getTAG077();
        PMPlanobj4.getTAG079();
        PMPlanobj4.getTAG080();
        PMPlanobj4.getTAG081();
        PMPlanobj4.getTAG082();
        PMPlanobj4.getTAG083();
        PMPlanobj4.getTAG084();
        PMPlanobj4.getTAG085();
        PMPlanobj4.getTAG086();
        PMPlanobj4.getTAG087();
        PMPlanobj4.getTAG088();
        PMPlanobj4.getTAG089();
        PMPlanobj4.getTAG090();
        PMPlanobj4.getTAG091();
        PMPlanobj4.getTAG092();
        PMPlanobj4.getisLocationCovered();
        PMPlanobj4.getlstWORefFieldsPicklist();
        PMPlanobj4.getlstTaskObjectpicklst();
        PMPlanobj4.getlstTaskmaptousepicklst();
        PMPlanobj4.getlstReqPartstousepicklst();
        PMPlanobj4.getlstTimeZones();
        PMPlanobj4.getOptnMappingLocToWO();
        
        PMPlanobj4.strAssignWOto = 'Dispatcher';
        PMPlanobj4.save();
        PMPlanobj4.strAssignWOto = 'Queue';
        PMPlanobj4.save();
        PMPlanobj4.strAssignWOto = 'Team';
        PMPlanobj4.save();
        PMPlanobj4.strAssignWOto = 'Technician';
        PMPlanobj4.save();
    } 
}