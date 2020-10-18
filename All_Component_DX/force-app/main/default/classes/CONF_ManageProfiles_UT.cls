@isTest(SeeAllData=true)
Private class CONF_ManageProfiles_UT {

private static List<RecordType> rtConf  = new List<RecordType>();
           
 static testMethod void CONF_ManageProfiles_Test()
 {
    rtConf = [SELECT Id, Name FROM RecordType WHERE SobjectType = 'SVMXC__ServiceMax_Config_Data__c'];
            //// Create Config Profile:
        SVMXC__ServiceMax_Config_Data__c profData1 = new SVMXC__ServiceMax_Config_Data__c();
        SVMXC__ServiceMax_Config_Data__c profData2 = new SVMXC__ServiceMax_Config_Data__c();
        SVMXC__ServiceMax_Config_Data__c profData3 = new SVMXC__ServiceMax_Config_Data__c();
        SVMXC__ServiceMax_Config_Data__c profData4 = new SVMXC__ServiceMax_Config_Data__c();
        for(RecordType rt4 : rtConf) //Loop to take a record type at a time
        {
            // Create objMap Record, Link to Module
            if(rt4.Name == 'Configuration Profile')
            {
                SVMXC__ServiceMax_Config_Data__c prof1 = new SVMXC__ServiceMax_Config_Data__c(
                                            RecordTypeId =rt4.Id,
                                            SVMXC__Active__c = false,
                                            SVMXC__Profile_Name__c = 'Custom Config Profile',
                                            SVMXC__Description__c = 'Some Desc',
                                            SVMXC__CONFIGURATION_TYPE__C = 'Global',
                                            SVMXC__Select__c=true,
                                            SVMXC__IsDefault__c = false
                                            );
                profData1 = prof1;
                SVMXC__ServiceMax_Config_Data__c prof2 = new SVMXC__ServiceMax_Config_Data__c(
                                            RecordTypeId =rt4.Id,
                                            SVMXC__Active__c = false,
                                            SVMXC__Profile_Name__c = 'Custom Config Profile',
                                            SVMXC__Description__c = 'Some Desc',
                                            SVMXC__CONFIGURATION_TYPE__C = 'Global',
                                            SVMXC__Select__c=true,
                                            SVMXC__IsDefault__c = false
                                            );
                profData2 = prof2;
                SVMXC__ServiceMax_Config_Data__c prof3 = new SVMXC__ServiceMax_Config_Data__c(
                                            RecordTypeId =rt4.Id,
                                            SVMXC__Active__c = false,
                                            SVMXC__Profile_Name__c = 'Custom Config Profile',
                                            SVMXC__Description__c = 'Some Desc',
                                            SVMXC__CONFIGURATION_TYPE__C = 'Group',
                                            SVMXC__Select__c=true,
                                            SVMXC__IsDefault__c = false
                                            );
                profData3 = prof3;
                SVMXC__ServiceMax_Config_Data__c prof4 = new SVMXC__ServiceMax_Config_Data__c(
                                            RecordTypeId =rt4.Id,
                                            SVMXC__Active__c = false,
                                            SVMXC__Profile_Name__c = 'Custom Config Profile',
                                            SVMXC__Description__c = 'Some Desc',
                                            SVMXC__CONFIGURATION_TYPE__C = 'Group',
                                            SVMXC__Select__c=true,
                                            SVMXC__IsDefault__c = false
                                            );
                profData4 = prof4;                                

            } 
        }
        insert profData1;
        insert profData2;
        insert profData3;
        insert profData4;
        System.assertEquals('Custom Config Profile',profData1.SVMXC__Profile_Name__c = 'Custom Config Profile');
        System.assertEquals('Custom Config Profile',profData2.SVMXC__Profile_Name__c = 'Custom Config Profile');
        System.assertEquals('Custom Config Profile',profData3.SVMXC__Profile_Name__c = 'Custom Config Profile');
        System.assertEquals('Custom Config Profile',profData4.SVMXC__Profile_Name__c = 'Custom Config Profile');
        
  //try
  //{ 
    test.startTest();
    SVMXC.CONF_ManageProfiles myPageCon = new SVMXC.CONF_ManageProfiles();
    Boolean T_CL1 = myPageCon.getCheckAllLines();
    List<SVMXC__ServiceMax_Config_Data__c> T_CL2=myPageCon.getServiceLocalSettingDetails();
    List<SVMXC__ServiceMax_Config_Data__c> T_CL3 = myPageCon.getServiceGlobalSettingDetails();
    Boolean T_CL4 = myPageCon.getCheckboxField();
    PageReference T_CL5 = myPageCon.SourceScrn();
    Boolean T_CL6 = myPageCon.isGloValid('Edit');    
    Boolean T_CL61 = myPageCon.isGloValid('Clone'); 
    Boolean T_CL62 = myPageCon.isGloValid('Activate');
    Boolean T_CL63 = myPageCon.isGloValid('Delete');
    Boolean T_CL7 = myPageCon.isLocValid('Edit');
    Boolean T_CL71 = myPageCon.isLocValid('Clone'); 
    Boolean T_CL72 = myPageCon.isLocValid('Activate'); 
    Boolean T_CL73 = myPageCon.isLocValid('Delete');  
    PageReference T_CL8 = myPageCon.GloeditProf(); 
    {
    profData1.SVMXC__Active__c=true;
    update profData1;
    profData2.SVMXC__Select__c=false;
    update profData2;
    profData3.SVMXC__Active__c=true;
    update profData3;
    profData4.SVMXC__Select__c=false;
    update profData4;
    //SVMXC.CONF_ManageProfiles myPageCon1 = new SVMXC.CONF_ManageProfiles();
    //PageReference T_CL81 = myPageCon1.GloeditProf();
    //PageReference T_CL91 = myPageCon1.LoceditProf();
    //PageReference T_CL10 = myPageCon1.GlocloneProf(); 
   // PageReference T_CL11 = myPageCon1.LoccloneProf(); 
   // PageReference T_CL14 = myPageCon1.GloactProf();
    }
    {
    profData2.SVMXC__Select__c=false;
    update profData2;
    profData3.SVMXC__Select__c=false;
    update profData3;
    profData1.SVMXC__Select__c=false;
    update profData1;
    profData4.SVMXC__Select__c=false;
    update profData4;
    //SVMXC.CONF_ManageProfiles myPageCon2 = new SVMXC.CONF_ManageProfiles();
    //PageReference T_CL812 = myPageCon2.GloeditProf();
    //PageReference T_CL912 = myPageCon2.LoceditProf();
    //PageReference T_CL102 = myPageCon2.GlocloneProf(); 
   // PageReference T_CL112 = myPageCon2.LoccloneProf(); 
   // PageReference T_CL142 = myPageCon2.GloactProf();
   // PageReference T_CL123 = myPageCon2.GlodelProf(); 
   // PageReference T_CL133 = myPageCon2.LocdelProf(); 
    }
    
    PageReference T_CL9 = myPageCon.LoceditProf(); 
    PageReference T_CL10 = myPageCon.GlocloneProf(); 
    PageReference T_CL11 = myPageCon.LoccloneProf(); 
    PageReference T_CL12 = myPageCon.GlodelProf(); 
    PageReference T_CL13 = myPageCon.LocdelProf(); 
    PageReference T_CL14 = myPageCon.GloactProf();
    PageReference T_CL15 = myPageCon.GoSetupHome(); 
    Boolean T_CL16 = myPageCon.getGloDisplayBlockLevelMessage();
    Boolean T_CL236 = myPageCon.getGrpDisplayBlockLevelMessage(); 
    Boolean T_CL17 = myPageCon.getIsActivatedContract(); 
    PageReference T_CL18 = myPageCon.GoEditPage(); 
    PageReference T_CL19 = myPageCon.GoClone(); 
    
    myPageCon.setCheckAllLines(true);
    myPageCon.setCheckboxField(true);
 
    //Translations
     String str1 = myPageCon.getTAG001();
     String str2 = myPageCon.getTAG002();
     String str3 = myPageCon.getTAG003();
     String str4 = myPageCon.getTAG004();
     String str5 = myPageCon.getTAG005();
     String str6 = myPageCon.getTAG006();
     String str7 = myPageCon.getTAG007();
     String str8 = myPageCon.getTAG008();
     String str9 = myPageCon.getTAG009();
     String str10 = myPageCon.getTAG010();
     String str11 = myPageCon.getTAG011();
     String str12 = myPageCon.getTAG012();
     String str13 = myPageCon.getTAG013();
     String str14 = myPageCon.getTAG014();
     String str15 = myPageCon.getTAG015();
     String str16 = myPageCon.getTAG016();
     String str17 = myPageCon.getTAG017();
     String str18 = myPageCon.getTAG018();
     //String str19 = myPageCon.getTAG019();
     String str20 = myPageCon.getTAG020();
     String str21 = myPageCon.getTAG021();
     String str22 = myPageCon.getTAG022();
     String str23 = myPageCon.getTAG023();
     String str25 = myPageCon.getTAG055();
     String str26 = myPageCon.getTAG056();
     String str27 = myPageCon.getTAG059();
     String hlp   = myPageCon.getHLPURL();
        myPageCon.svmxSettingList.clear();
        myPageCon.getTAG001();
        myPageCon.getTAG002();
        myPageCon.getTAG003();
        myPageCon.getTAG004();
        myPageCon.getTAG005();
        myPageCon.getTAG006();
        myPageCon.getTAG007();
        myPageCon.getTAG008();
        myPageCon.getTAG009();
        myPageCon.getTAG010();
        myPageCon.getTAG011();
        myPageCon.getTAG012();
        myPageCon.getTAG013();
        myPageCon.getTAG014();
        myPageCon.getTAG015();
        myPageCon.getTAG016();
        myPageCon.getTAG017();
        myPageCon.getTAG018();
        //myPageCon.getTAG019();
        myPageCon.getTAG020();
        myPageCon.getTAG021();
        myPageCon.getTAG022();
        myPageCon.getTAG023();
        myPageCon.getTAG055();
        myPageCon.getTAG056();
        myPageCon.getTAG059();
        myPageCon.getHLPURL();
        test.stopTest();
         
  //}
 // catch(Exception ex)
     //  {
     //    ApexPages.addMessage(new ApexPages.Message ( ApexPages.Severity.ERROR, ex.getMessage()));
    //   } 
         
    }
}