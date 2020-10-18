@isTest(SeeAllData=true)
Private class CONF_ManageModules_UT {
  static testMethod void CONF_ManageModules_Test()
  {
      try{        
      Test.startTest();
      SVMXC.CONF_ManageModules myPageCon = new SVMXC.CONF_ManageModules();
      SVMXC__ServiceMax_Processes__c module,moduleclone;
      RecordType[] rts = [SELECT Id, Name FROM RecordType WHERE SobjectType = 'SVMXC__ServiceMax_Processes__c' AND Name = 'Module'];




    
    SVMXC__ServiceMax_Processes__c mod = new SVMXC__ServiceMax_Processes__c(RecordTypeId =rts[0].Id,SVMXC__Active__c = true,SVMXC__Name__c = 'Moduletest001',SVMXC__ModuleID__c = 'CUSTOMTEST');
    insert mod;
    module = mod;


    
      // Verify that the Create Module Record was created  in the database.
      System.assertEquals('Moduletest001', module.SVMXC__Name__c);
      List<SVMXC__ServiceMax_Processes__c> serviceMaxProcesses;
      List<SVMXC__ServiceMax_Processes__c> cust_serviceMaxProcesses;
          List<SVMXC__ServiceMax_Processes__c> T_CL2 = myPageCon.getStandModule();
          List<SVMXC__ServiceMax_Processes__c> T_CL3 = myPageCon.getCustModule();
          Boolean T_CL4 = myPageCon.getIsCustAvail();
          Boolean T_CL5 = myPageCon.isValidData('Save');
          Boolean T_CL51 = myPageCon.isValidData('Del');
          PageReference T_CL6 = myPageCon.AddNewMod();
          PageReference T_CL7 = myPageCon.saveMod();          
          PageReference T_CL912 = myPageCon.MoveCustListSubmod();
          PageReference T_CL913 = myPageCon.MoveStdListSubmod();
          Boolean T_CL11 = myPageCon.getStdDisplayBlockLevelMessage();
          Boolean T_CL231 = myPageCon.getCustDisplayBlockLevelMessage();
          Integer T_CL12 = myPageCon.getcustSize();
          PageReference T_CL1r2 = myPageCon.deleteMod();
          PageReference T_CLer2 = myPageCon.GoSubMod();
          PageReference pageRef1 = new PageReference('Page.SVMXC.CONF_ManageModules');
      //Translations
      String Tags='';
      Tags = myPageCon.getTAG001();
      Tags = myPageCon.getTAG002();
      Tags = myPageCon.getTAG003();
      Tags = myPageCon.getTAG004();
      Tags = myPageCon.getTAG005();
      Tags = myPageCon.getTAG006();
      Tags = myPageCon.getTAG007();
      Tags = myPageCon.getTAG008();
      Tags = myPageCon.getTAG009();
      Tags = myPageCon.getTAG010();
      Tags = myPageCon.getTAG011();
      Tags = myPageCon.getTAG012();
      Tags = myPageCon.getTAG013();
      Tags = myPageCon.getTAG014();
      Tags = myPageCon.getTAG015();





























    
      Tags = myPageCon.getTAG018();

      Tags = myPageCon.getTAG020();

      Tags = myPageCon.getTAG022();
      Tags = myPageCon.getTAG023();
      Tags = myPageCon.getTAG024();
      Tags = myPageCon.getTAG025();
    Tags = myPageCon.getTAG026();
      Tags = myPageCon.getTAG027();
      Tags = myPageCon.getTAG028();
      Tags = myPageCon.getHLPURL();
      PageReference T_CL10 = myPageCon.GoSetupHome();
    
    SVMXC__ServiceMax_Processes__c mod1 = new SVMXC__ServiceMax_Processes__c(RecordTypeId =rts[0].Id,SVMXC__Active__c = true,SVMXC__Name__c = 'Moduletest00122',SVMXC__ModuleID__c = 'CUSTOMTEST12', SVMXC__IsStandard__c=true);
    insert mod1;
    
      SVMXC__ServiceMax_Processes__c smpobj=[Select SVMXC__ModuleID__c, SVMXC__Name__c, SVMXC__Description__c, SVMXC__Select__c From SVMXC__ServiceMax_Processes__c  where SVMXC__ModuleID__c = 'CUSTOMTEST12' AND RecordTypeId =: rts[0].Id AND SVMXC__IsStandard__c=true order by SVMXC__ModuleID__c limit 1];
           smpobj.SVMXC__Select__c = true;
           update smpobj;         
      System.assertEquals(true, smpobj.SVMXC__Select__c );
      //System.assertEquals(true, smpobj.SVMXC__Record_Type_Name__c=='Module');
    myPageCon = new SVMXC.CONF_ManageModules();
      PageReference T_CL9 = myPageCon.MoveStdListSubmod();


    T_CL9 = myPageCon.MoveCustListSubmod();
    
    
    SVMXC__ServiceMax_Processes__c mod11 = new SVMXC__ServiceMax_Processes__c(RecordTypeId =rts[0].Id,SVMXC__Active__c = true,SVMXC__Name__c = 'Moduletest001222',SVMXC__ModuleID__c = 'CUSTOMTEST121', SVMXC__IsStandard__c=false, SVMXC__Select__c = true);
    insert mod11;
    myPageCon = new SVMXC.CONF_ManageModules();
      T_CL9 = myPageCon.MoveStdListSubmod();
    T_CL9 = myPageCon.MoveCustListSubmod();
    T_CL9 = myPageCon.deleteMod();
      }
      catch(Exception ex)
       {
         ApexPages.addMessage(new ApexPages.Message ( ApexPages.Severity.ERROR, ex.getMessage()));
       }    
    
    }
}