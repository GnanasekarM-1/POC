@isTest(SeeAllData=true)
Private Class CONF_ManageDisplayTags_UT
{
    
    private static SVMXC.CONF_ManageDisplayTags MDTObject1 = new SVMXC.CONF_ManageDisplayTags();
    
    
   
        
    static testMethod void CONF_ManageDisplayTags_Test()
    {
       try
       {
        SVMXC.COMM_Utils utils = new SVMXC.COMM_Utils(); 
        SVMXC.COMM_Utils_ManageSettings commSettings = new SVMXC.COMM_Utils_ManageSettings();
        Map<String, String> svmxSettingList = commSettings.SVMX_getSettingList('CONF002');
        SVMXC.COMM_Utils_ManageTags commUtil = new SVMXC.COMM_Utils_ManageTags();
        Map<String, String> svmxTagList = commUtil.SVMX_getTagList('CONF002');
        
        //Create Module & Submodule
        RecordType[] rts = [SELECT Id, Name FROM RecordType WHERE SobjectType = 'SVMXC__ServiceMax_Processes__c'];    
        SVMXC__ServiceMax_Processes__c module;
        for(RecordType rt : rts) //Loop to take a record type at a time
        {
            // Create Module Record
            if(rt.Name == 'Module')
            {
                SVMXC__ServiceMax_Processes__c mod = new SVMXC__ServiceMax_Processes__c(
                                            RecordTypeId =rt.Id,
                                            SVMXC__Active__c = true,
                                            SVMXC__Name__c = 'Moduletest001',
                                            SVMXC__ModuleID__c = 'CUSTOMTEST'                                            
                                            );
                insert mod;
                module = mod;
            } 
        } 
       
        System.assertEquals('Moduletest001', module.SVMXC__Name__c) ;
        SVMXC__ServiceMax_Processes__c subModule;
        for(RecordType rt2 : rts) //Loop to take a record type at a time
        {
            // Create Sub-Module Record, Link to Module
            if(rt2.Name == 'Submodule')
            {
                SVMXC__ServiceMax_Processes__c subMod = new SVMXC__ServiceMax_Processes__c(
                                            RecordTypeId =rt2.Id,
                                            SVMXC__Active__c = true,
                                            SVMXC__Name__c = 'testSubModule',
                                            SVMXC__SubmoduleID__c = 'SBMTEST001',
                                            SVMXC__Module__c = module.Id                                            
                                            );
                insert subMod;
                subModule = subMod;
           } 
        }
        System.assertEquals('testSubModule', subModule.SVMXC__Name__c) ;
         //create tags, Link to SubModule, for Master Lang

        SVMXC__ServiceMax_Tags__c tagsmas = new SVMXC__ServiceMax_Tags__c(
                                            SVMXC__Tag_Text__c = 'My Tag text',
                                            SVMXC__Submodule__c = subModule.Id,
                                            SVMXC__Language__c = 'Master', 
                                             
                                            Name = 'TAGTST001'                                       
                                            );
        insert tagsmas;
        System.assertEquals('My Tag text', tagsmas.SVMXC__Tag_Text__c) ;
        SVMXC__ServiceMax_Tags__c tagsmas2 = new SVMXC__ServiceMax_Tags__c(
                                            SVMXC__Tag_Text__c = 'My Tag text2',
                                            SVMXC__Submodule__c = subModule.Id,
                                            SVMXC__Language__c = 'Master', 
                                            SVMXC__Select_Tag__c =True,
                                            Name = 'TAGTST002'                                       
                                            );
        insert tagsmas2;
        System.assertEquals('My Tag text2', tagsmas2.SVMXC__Tag_Text__c) ;
        delete tagsmas2;
        SVMXC__ServiceMax_Tags__c tagsmas3 = new SVMXC__ServiceMax_Tags__c(
                                            SVMXC__Tag_Text__c = '',
                                            SVMXC__Submodule__c = subModule.Id,
                                            SVMXC__Language__c = '', 
                                           SVMXC__Select_Tag__c =True,
                                            Name = ''                                        
                                            );
        insert tagsmas3; 
        
         
        SVMXC__ServiceMax_Tags__c tagsmas4 = new SVMXC__ServiceMax_Tags__c(
                                            SVMXC__Tag_Text__c = 'My Tag text',
                                            SVMXC__Submodule__c = subModule.Id,
                                            SVMXC__Language__c = 'Master',  
                                            Name = 'TAGTST001'                                       
                                            );
       insert tagsmas4; 
      
      SVMXC__ServiceMax_Tags__c tagsmas12 = new SVMXC__ServiceMax_Tags__c(
                                            SVMXC__Tag_Text__c = 'My Tag text',
                                            SVMXC__Submodule__c = subModule.Id,
                                            SVMXC__Language__c = 'Master', 
                                            SVMXC__Select_Tag__c = true,
                                            Name = 'TAGTST001'                                       
                                            );
       insert tagsmas12;
       
       SVMXC__ServiceMax_Tags__c tagsmas5 = new SVMXC__ServiceMax_Tags__c();
       delete tagsmas3;
       
       
        //Scenario to Launch Page without url parameters id      
        PageReference pageRef1 = new PageReference('Page.SVMXC.CONF_ManageDisplayTags');
        Test.setCurrentPageReference(pageRef1); 
        MDTObject1 = new SVMXC.CONF_ManageDisplayTags();
        MDTObject1.customtag.add(tagsmas12);
        MDTObject1.Save();
        SVMXC__ServiceMax_Tags__c tagsmas13 = new SVMXC__ServiceMax_Tags__c(
                                            SVMXC__Tag_Text__c = 'My Tag text',
                                            SVMXC__Submodule__c = subModule.Id,
                                            SVMXC__Language__c = 'Master', 
                                            SVMXC__Select_Tag__c = false,
                                            Name = 'TAGTST021'                                       
                                            );
       insert tagsmas13;
        pagereference pr1 = MDTObject1.del();
        MDTObject1.customtag.add(tagsmas13);
         
        pagereference pq = MDTObject1.del();
         
        
        //qualify all Getter Setter Method
     //   system.debug('amar'+svmxTagList);
         String str1 = MDTObject1.getTAG001();
         String str2 = MDTObject1.getTAG002(); 
         String str3 = MDTObject1.getTAG003();
         String str4 = MDTObject1.getTAG004();
         String str5 = MDTObject1.getTAG005();
         String str6 = MDTObject1.getTAG006();
      //   system.debug('amar1'+str6);
         String str7 = MDTObject1.getTAG007();
         String str8 = MDTObject1.getTAG008();
         String str9 = MDTObject1.getTAG009();
         String str10 = MDTObject1.getTAG010();
         String str11 = MDTObject1.getTAG011();
         String str12 = MDTObject1.getTAG012();
         String str13 = MDTObject1.getTAG013();
         String str14 = MDTObject1.getTAG014();
         String str15 = MDTObject1.getTAG015();
         String str16 = MDTObject1.getTAG016();
         String str17 = MDTObject1.getTAG017();
         String str18 = MDTObject1.getTAG018();
         String str20 = MDTObject1.getTAG020();
         String str21 = MDTObject1.getTAG021();
         String str22 = MDTObject1.getTAG022();
         String str23 = MDTObject1.getTAG023();
         String hlp  = MDTObject1.getHLPURL();
        //qualify all List Methods 
        
       //  MDTObject1.svmxTagList.clear();
     //    system.debug('amar2'+svmxTagList);
         String astr1 = MDTObject1.getTAG001();
         String astr2 = MDTObject1.getTAG002(); 
         String astr3 = MDTObject1.getTAG003();
         String astr4 = MDTObject1.getTAG004();
         String astr5 = MDTObject1.getTAG005();
         String astr6 = MDTObject1.getTAG006();
     //    system.debug('amar1'+astr6);
         String astr7 = MDTObject1.getTAG007();
         String astr8 = MDTObject1.getTAG008();
         String astr9 = MDTObject1.getTAG009();
         String astr10 = MDTObject1.getTAG010();
         String astr11 = MDTObject1.getTAG011();
         String astr12 = MDTObject1.getTAG012();
         String astr13 = MDTObject1.getTAG013();
         String astr14 = MDTObject1.getTAG014();
         String astr15 = MDTObject1.getTAG015();
         String astr16 = MDTObject1.getTAG016();
         String astr17 = MDTObject1.getTAG017();
         String astr18 = MDTObject1.getTAG018();
         String astr20 = MDTObject1.getTAG020();
         String astr21 = MDTObject1.getTAG021();
         String astr22 = MDTObject1.getTAG022();
         String astr23 = MDTObject1.getTAG023();
         String ahlp  = MDTObject1.getHLPURL();
         List<SelectOption> l1 = MDTObject1.getModule();
         List<SelectOption> l2 = MDTObject1.getSubModule();
         List<SVMXC__ServiceMax_Tags__c> l3 = MDTObject1.getCustomtag();
         List<SVMXC__ServiceMax_Tags__c> l4 = MDTObject1.getStandardtag();
        
        //Scenario to qualify all pageReference Methods
        PageReference addt = MDTObject1.AddTag();
        PageReference bh = MDTObject1.BacktoHome();
        PageReference sv = MDTObject1.Save();
        pagereference de = MDTObject1.del();
        
        PageReference ct = MDTObject1.Calltags();
        PageReference cs = MDTObject1.Callsubmodule();
                

     
        // qualify all Boolean Methods
         //quallify all Boolean 
         Boolean chkAll;
         List<sobject> listOfRecs; 
         String fldNameInList;
         object valToChk;
         boolean a = MDTObject1.getCheckAllLines();
         boolean b = MDTObject1.getDisplayTags();
         boolean c = MDTObject1.getDisplayBlockLevelMessage();
         boolean d = MDTObject1.getIsCustAvail();
         boolean e = MDTObject1.getIsStdAvail();
         boolean g = MDTObject1.isValidData();
         
        // void  h = 
         MDTObject1.setCheckAllLines(chkAll);
       }
       catch(Exception ex)
       {
         ApexPages.addMessage(new ApexPages.Message ( ApexPages.Severity.ERROR, ex.getMessage()));
       } 

}
    
  
}