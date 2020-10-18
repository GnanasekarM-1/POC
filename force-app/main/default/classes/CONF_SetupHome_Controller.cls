public with Sharing class CONF_SetupHome_Controller {
    public class SetupHomeWrapper{
        @AuraEnabled public String setupComponentTitle;
        @AuraEnabled public String helpBtnUrl;
        @AuraEnabled public String helpBtnLabel;
        @AuraEnabled public String versionLabel;
        @AuraEnabled public String versionNumber;
        @AuraEnabled public String licenseType;
        @AuraEnabled public String licenseDesc;
        @AuraEnabled public CONF_SetupHome_Controller.RecentlyVisitedWrapper recentlyVisited;
        @AuraEnabled public List<CONF_SetupHome_Controller.SetupHomeSectionWrapper> setupSections;
    }
    public class SetupHomeSectionWrapper{
        @AuraEnabled public String sectionId;
        @AuraEnabled public String sectionTitle;
        @AuraEnabled public String sectionDescription;
        @AuraEnabled public String isSectionEnabled;
        @AuraEnabled public List<CONF_SetupHome_Controller.SetupHomeButtonWrapper> buttonList;
    }
    public class SetupHomeButtonWrapper{
        @AuraEnabled public String buttonId;
        @AuraEnabled public String buttonLabel;
        @AuraEnabled public String buttonUrl;
        @AuraEnabled public String buttonDescription;
        @AuraEnabled public String isButtonEnabled;
    }
    public class RecentlyVisitedWrapper{
        @AuraEnabled public String recentlyVisitedTitle;
        @AuraEnabled public List<String> recentlyVisitedBtnIds;
    }

    @AuraEnabled
    public static SetupHomeWrapper getSetupHomeDetails(){
        Boolean isHtmlView; // Added for BAC-5169
        SVMXC.COMM_Utils objCOMM_Utils = new SVMXC.COMM_Utils();
        SVMXC.COMM_Utils_ManageSettings commSettings = new SVMXC.COMM_Utils_ManageSettings();        
        Map<String, String> svmxSettingToEnableAPL = commSettings.SVMX_getSettingList('GLOB001');
        Map<String, String> svmxSettingList = commSettings.SVMX_getSettingList('CONF005');
        // Added for BAC-5169
        if(commSettings.SVMX_getGlobalSettingList('SFM001_SET006').equalsIgnoreCase('HTML')){
            isHtmlView = true;
        }else{
            isHtmlView = false;
        }
        // End for BAC-5169
    
        MAP<String,Schema.SObjectType> allObjs = Schema.getGlobalDescribe();
        String SkillsHomeURL = '';
        Schema.SObjectType objT_SkillsHome = null;
        if( allObjs.get('SVMXC__Skill__c') != null )
            objT_SkillsHome = allObjs.get('SVMXC__Skill__c');
        else
            objT_SkillsHome = allObjs.get('Skill__c');
        if(objT_SkillsHome != null)
            SkillsHomeURL = '/' + String.valueOf(objT_SkillsHome.getDescribe().getkeyPrefix()) + '/l';
 
        String overnightPolicyHomeURL = '';
        Schema.SObjectType objT_OvernightPolicyHome;
        if( allObjs.get('SVMXC__SM_Overnight_Stay_Policy__c') != null )
            objT_OvernightPolicyHome = allObjs.get('SVMXC__SM_Overnight_Stay_Policy__c');
        else
            objT_OvernightPolicyHome = allObjs.get('SM_Overnight_Stay_Policy__c');
        if(objT_OvernightPolicyHome != null)
            overnightPolicyHomeURL = '/' + String.valueOf(objT_OvernightPolicyHome.getDescribe().getkeyPrefix()) + '/l';
        CONF_SetupHome_Controller.SetupHomeWrapper obj = new CONF_SetupHome_Controller.SetupHomeWrapper();
        obj.setupComponentTitle = 'ServiceMax '+ System.Label.CONF005_TAG006;
        obj.helpBtnUrl = System.Label.CONF005_HLPURL;
        obj.helpBtnLabel = System.Label.CONF005_TAG021;     
        obj.versionLabel = System.Label.CONF005_TAG004; 
        obj.versionNumber = String.valueOf(Decimal.valueOf(String.valueOf(System.requestVersion())).setScale(5));
        obj.licenseType = objCOMM_Utils.getSVMX_License();
        obj.licenseDesc = System.Label.CONF005_TAG005; 
        obj.setupSections = new List<CONF_SetupHome_Controller.SetupHomeSectionWrapper>();
        //SECTION1
        CONF_SetupHome_Controller.SetupHomeSectionWrapper sec1 = new CONF_SetupHome_Controller.SetupHomeSectionWrapper();
        sec1.sectionId = 'SECTION1';
        sec1.sectionTitle = System.Label.CONF005_NAME63;
        sec1.sectionDescription = System.Label.CONF005_DESC63;
        sec1.isSectionEnabled = 'true';
        //Buttons for Section 1
        sec1.buttonList = new List<CONF_SetupHome_Controller.SetupHomeButtonWrapper>();
        
        sec1.buttonList.add(createButtonWrapper('SECTION1_BTN1',System.Label.CONF005_TEXT11,svmxSettingList.containsKey('SET011')?svmxSettingList.get('SET011'):'',System.Label.CONF005_DESC11,'true'));
        
        sec1.buttonList.add(createButtonWrapper('SECTION1_BTN2',System.Label.CONF005_TEXT12,svmxSettingList.containsKey('SET012')?svmxSettingList.get('SET012'):'',System.Label.CONF005_DESC12,'true'));
        
        sec1.buttonList.add(createButtonWrapper('SECTION1_BTN3',System.Label.CONF005_TEXT119,svmxSettingList.containsKey('SET102')?svmxSettingList.get('SET102'):'',System.Label.CONF005_DESC119,'true'));
        
        sec1.buttonList.add(createButtonWrapper('SECTION1_BTN4',System.Label.CONF005_TEXT13,svmxSettingList.containsKey('SET013')?svmxSettingList.get('SET013'):'',System.Label.CONF005_DESC13,'true'));
        
        //BAC-4662 commented to hide Dispaly Tags
        //sec1.buttonList.add(createButtonWrapper('SECTION1_BTN5',System.Label.CONF005_TEXT14,svmxSettingList.containsKey('SET014')?svmxSettingList.get('SET014'):'',System.Label.CONF005_DESC14,'true'));
        
        sec1.buttonList.add(createButtonWrapper('SECTION1_BTN6',System.Label.CONF005_TEXT15,svmxSettingList.containsKey('SET015')?svmxSettingList.get('SET015'):'',System.Label.CONF005_DESC15,'true'));
        
        sec1.buttonList.add(createButtonWrapper('SECTION1_BTN7',System.Label.CONF005_TEXT17,svmxSettingList.containsKey('SET017')?svmxSettingList.get('SET017'):'',System.Label.CONF005_DESC17,'true'));
        
        sec1.buttonList.add(createButtonWrapper('SECTION1_BTN8',System.Label.CONF005_TEXT121,svmxSettingList.containsKey('SET104')?svmxSettingList.get('SET104'):'',System.Label.CONF005_DESC121,'true'));
        
        //BAC-5957
        sec1.buttonList.add(createButtonWrapper('SECTION1_BTN9',System.Label.CONF005_TEXT144,'',System.Label.CONF005_DESC128,'true'));
        
        obj.setupSections.add(sec1);
        
        //SECTION2
        CONF_SetupHome_Controller.SetupHomeSectionWrapper sec2 = new CONF_SetupHome_Controller.SetupHomeSectionWrapper();
        sec2.sectionId = 'SECTION2';
        sec2.sectionTitle = System.Label.CONF005_NAME64;
        sec2.sectionDescription = System.Label.CONF005_DESC64;
        sec2.isSectionEnabled = 'true';
        //Buttons for Section 2
        sec2.buttonList = new List<CONF_SetupHome_Controller.SetupHomeButtonWrapper>();
        
        //sec2.buttonList.add(createButtonWrapper('SECTION2_BTN1',System.Label.CONF005_TEXT18,svmxSettingList.containsKey('SET019')?svmxSettingList.get('SET019'):'',System.Label.CONF005_DESC18,'true'));
        //Commented above line and changed URL to the correct page for the issue SFD-2047.
        sec2.buttonList.add(createButtonWrapper('SECTION2_BTN1',System.Label.CONF005_TEXT18,svmxSettingList.containsKey('SET018')?svmxSettingList.get('SET018'):'',System.Label.CONF005_DESC18,'true'));
        
        //sec2.buttonList.add(createButtonWrapper('SECTION2_BTN2',System.Label.CONF005_TEXT19,svmxSettingList.containsKey('SET018')?svmxSettingList.get('SET018'):'',System.Label.CONF005_DESC19,'true'));
        //Commented above line and changed URL to the correct page for the issue SFD-2047.
        sec2.buttonList.add(createButtonWrapper('SECTION2_BTN2',System.Label.CONF005_TEXT19,svmxSettingList.containsKey('SET019')?svmxSettingList.get('SET019'):'',System.Label.CONF005_DESC19,'true'));
        
        sec2.buttonList.add(createButtonWrapper('SECTION2_BTN3',System.Label.CONF005_TEXT54,svmxSettingList.containsKey('SET074')?SkillsHomeURL:'',System.Label.CONF005_DESC54,'true'));
        
        sec2.buttonList.add(createButtonWrapper('SECTION2_BTN4',System.Label.CONF005_TEXT108,(svmxSettingList.containsKey('SET094')&&(!svmxSettingToEnableAPL.containsKey('GBL027') || Boolean.valueOf( svmxSettingToEnableAPL.get('GBL027'))))?svmxSettingList.get('SET094'):'',System.Label.CONF005_DESC107,'true'));
        
        //BAC-4730 moved Overnight Stay Policy eleventh section
        //sec2.buttonList.add(createButtonWrapper('SECTION2_BTN5',System.Label.CONF005_TEXT115,svmxSettingList.containsKey('SET100')?overnightPolicyHomeURL:'',System.Label.CONF005_DESC115,'true'));
        
        //BAC-4662 commented to hide Max Configuration
        //sec2.buttonList.add(createButtonWrapper('SECTION2_BTN6','Max Configuration',(svmxSettingToEnableAPL.containsKey('GBL00034')&&boolean.valueOf(svmxSettingToEnableAPL.get('GBL00034')))?'/apex/Max_Configuration':'','To push Work Orders to Max','true'));
        
        obj.setupSections.add(sec2);
        
        //SECTION3
        CONF_SetupHome_Controller.SetupHomeSectionWrapper sec3 = new CONF_SetupHome_Controller.SetupHomeSectionWrapper();
        sec3.sectionId = 'SECTION3';
        sec3.sectionTitle = System.Label.CONF005_NAME65;
        sec3.sectionDescription = System.Label.CONF005_DESC65;
        sec3.isSectionEnabled = 'true';
        sec3.buttonList = new List<CONF_SetupHome_Controller.SetupHomeButtonWrapper>();
        
        sec3.buttonList.add(createButtonWrapper('SECTION3_BTN1',System.Label.CONF005_TEXT26,svmxSettingList.containsKey('SET026')?svmxSettingList.get('SET026'):'',System.Label.CONF005_DESC26,'true'));
        
        String TaskTemplatesHomeURL = null;
        Schema.SObjectType objT_TaskTemplatesHome;
        //Task Template
        if( allObjs.get('SVMXC__Task_Template__c') != null )
            objT_TaskTemplatesHome = allObjs.get('SVMXC__Task_Template__c');
        else
            objT_TaskTemplatesHome = allObjs.get('Task_Template__c');
        
        if(objT_TaskTemplatesHome != null)
            TaskTemplatesHomeURL = '/' + String.valueOf(objT_TaskTemplatesHome.getDescribe().getkeyPrefix()) + '/l';
        
        sec3.buttonList.add(createButtonWrapper('SECTION3_BTN2',System.Label.CONF005_TEXT55,svmxSettingList.containsKey('SET072')?TaskTemplatesHomeURL:'',System.Label.CONF005_DESC55,'true'));
        
        String PMPlanTemplatesHomeURL = null;
        Schema.SObjectType objT_PMPlanTemplates;
        if( allObjs.get('SVMXC__PM_Plan_Template__c') != null )
            objT_PMPlanTemplates = allObjs.get('SVMXC__PM_Plan_Template__c');
        else
            objT_PMPlanTemplates = allObjs.get('PM_Plan_Template__c'); 
        
        if(objT_PMPlanTemplates != null)
            PMPlanTemplatesHomeURL = '/' + objT_PMPlanTemplates.getDescribe().getkeyPrefix() + '/l';
        sec3.buttonList.add(createButtonWrapper('SECTION3_BTN3',System.Label.CONF005_TEXT94,svmxSettingList.containsKey('SET083')?PMPlanTemplatesHomeURL:'',System.Label.CONF005_DESC94,'true'));
        
        sec3.buttonList.add(createButtonWrapper('SECTION3_BTN4',System.Label.CONF005_TEXT89,svmxSettingList.containsKey('SET078') && svmxSettingList.get('SET078') != '0'? svmxSettingList.get('SET078'):'',System.Label.CONF005_DESC89,'true'));
        
        sec3.buttonList.add(createButtonWrapper('SECTION3_BTN5',System.Label.CONF005_TEXT142,svmxSettingList.containsKey('SET112') && svmxSettingList.get('SET112') != '0'? svmxSettingList.get('SET112'):'',System.Label.CONF005_DESC142,'true')); //Added by Nidhi - BAC-5679
        obj.setupSections.add(sec3);
        
        //SECTION4
        CONF_SetupHome_Controller.SetupHomeSectionWrapper sec4 = new CONF_SetupHome_Controller.SetupHomeSectionWrapper();
        sec4.sectionId = 'SECTION4';
        sec4.sectionTitle = System.Label.CONF005_NAME66;
        sec4.sectionDescription = System.Label.CONF005_DESC66;
        sec4.isSectionEnabled = 'true';
        sec4.buttonList = new List<CONF_SetupHome_Controller.SetupHomeButtonWrapper>();
        //BAC-4730 moved some buttons to section11 as part of this story
        //Buttons for Section 4
        sec4.buttonList.add(createButtonWrapper('SECTION4_BTN1',System.Label.CONF005_TEXT29,svmxSettingList.containsKey('SET029')?svmxSettingList.get('SET029'):'',System.Label.CONF005_DESC29,'true'));        
        
        sec4.buttonList.add(createButtonWrapper('SECTION4_BTN2',System.Label.CONF005_TEXT28,svmxSettingList.containsKey('SET028')?svmxSettingList.get('SET028'):'',System.Label.CONF005_DESC28,'true'));               
        
        sec4.buttonList.add(createButtonWrapper('SECTION4_BTN3',System.Label.CONF005_TEXT62,svmxSettingList.containsKey('SET058')?svmxSettingList.get('SET058'):'',System.Label.CONF005_DESC62,'true'));        
        
        sec4.buttonList.add(createButtonWrapper('SECTION4_BTN4',System.Label.CONF005_TEXT84,svmxSettingList.containsKey('SET071') && svmxSettingList.get('SET071') != '0'? svmxSettingList.get('SET071'):'',System.Label.CONF005_DESC84,'true'));        
        
        sec4.buttonList.add(createButtonWrapper('SECTION4_BTN5',System.Label.CONF005_TEXT91,svmxSettingList.containsKey('SET081') && svmxSettingList.get('SET081') != '0'? svmxSettingList.get('SET081'):'',System.Label.CONF005_DESC91,'true'));        
        
        obj.setupSections.add(sec4);
        
        //SECTION5
        CONF_SetupHome_Controller.SetupHomeSectionWrapper sec5 = new CONF_SetupHome_Controller.SetupHomeSectionWrapper();
        sec5.sectionId = 'SECTION5';
        sec5.sectionTitle = System.Label.CONF005_NAME67;
        sec5.sectionDescription = System.Label.CONF005_DESC67;
        sec5.isSectionEnabled = 'true';
        //Buttons for Section 5
        sec5.buttonList = new List<CONF_SetupHome_Controller.SetupHomeButtonWrapper>();
        
        //BAC-4662 commented to hide Ipad Settings
        //sec5.buttonList.add(createButtonWrapper('SECTION5_BTN1',System.Label.CONF005_TEXT57,svmxSettingList.containsKey('SET053')?svmxSettingList.get('SET053'):'',System.Label.CONF005_DESC57,'true'));
        
        sec5.buttonList.add(createButtonWrapper('SECTION5_BTN2',System.Label.CONF005_TEXT60,svmxSettingList.containsKey('SET056')?svmxSettingList.get('SET056'):'',System.Label.CONF005_DESC60,'true'));
        
        sec5.buttonList.add(createButtonWrapper('SECTION5_BTN3',System.Label.CONF005_TEXT82, svmxSettingList.containsKey('SET069') && svmxSettingList.get('SET069') != '0' ? svmxSettingList.get('SET069'):'',System.Label.CONF005_DESC82,'true'));
        
        sec5.buttonList.add(createButtonWrapper('SECTION5_BTN4',System.Label.CONF005_TEXT104, svmxSettingList.containsKey('SET093') && svmxSettingList.get('SET093') != '0'? svmxSettingList.get('SET093'):'',System.Label.CONF005_DESC104,'true'));
        
        sec5.buttonList.add(createButtonWrapper('SECTION5_BTN5',System.Label.CONF005_TEXT118, svmxSettingList.containsKey('SET101') ? svmxSettingList.get('SET101'):'',System.Label.CONF005_DESC118,'true'));
        
        //BAC-4834 added below line for SFA button
        sec5.buttonList.add(createButtonWrapper('SECTION5_BTN6',System.Label.CONF005_TEXT122, svmxSettingList.containsKey('SET105') ? svmxSettingList.get('SET105'):'',System.Label.CONF005_DESC122,'true'));
        
        obj.setupSections.add(sec5);
        
        //SECTION6
        CONF_SetupHome_Controller.SetupHomeSectionWrapper sec6 = new CONF_SetupHome_Controller.SetupHomeSectionWrapper();
        sec6.sectionId = 'SECTION6';
        sec6.sectionTitle = System.Label.CONF005_NAME68;
        sec6.sectionDescription = System.Label.CONF005_DESC68;
        sec6.isSectionEnabled = 'true';
        //Buttons for Section 6
        sec6.buttonList = new List<CONF_SetupHome_Controller.SetupHomeButtonWrapper>();
        
        //sec6.buttonList.add(createButtonWrapper('SECTION6_BTN1',System.Label.CONF005_TEXT52, svmxSettingList.containsKey('SET052') ? svmxSettingList.get('SET052'):'',System.Label.CONF005_DESC52,'true')); // Commented for BAC-5169
        
        sec6.buttonList.add(createButtonWrapper('SECTION6_BTN2',System.Label.CONF005_TEXT59, svmxSettingList.containsKey('SET055')?svmxSettingList.get('SET055'):'',System.Label.CONF005_DESC59,'true'));
        
        sec6.buttonList.add(createButtonWrapper('SECTION6_BTN3',System.Label.CONF005_TEXT58, svmxSettingList.containsKey('SET054') ? svmxSettingList.get('SET054'):'',System.Label.CONF005_DESC58,'true'));
        
        sec6.buttonList.add(createButtonWrapper('SECTION6_BTN4',System.Label.CONF005_TEXT20, svmxSettingList.containsKey('SET020') ? svmxSettingList.get('SET020'):'',System.Label.CONF005_DESC20,'true'));
        
        sec6.buttonList.add(createButtonWrapper('SECTION6_BTN5',System.Label.CONF005_TEXT73,svmxSettingList.containsKey('SET070') && svmxSettingList.get('SET070') != '0' ? svmxSettingList.get('SET070'):'',System.Label.CONF005_DESC73,'true'));
         /* Commented for BAC-5169
        sec6.buttonList.add(createButtonWrapper('SECTION6_BTN6',System.Label.CONF005_TEXT85,svmxSettingList.containsKey('SET080') && svmxSettingList.get('SET080') != '0'? svmxSettingList.get('SET080'):'',System.Label.CONF005_DESC85,'true'));
        
        sec6.buttonList.add(createButtonWrapper('SECTION6_BTN7',System.Label.CONF005_TEXT16,svmxSettingList.containsKey('SET016')?svmxSettingList.get('SET016'):'',System.Label.CONF005_DESC16,'true'));
        
        sec6.buttonList.add(createButtonWrapper('SECTION6_BTN8',System.Label.CONF005_TEXT101,svmxSettingList.containsKey('SET090') && svmxSettingList.get('SET090') != '0'? svmxSettingList.get('SET090'):'',System.Label.CONF005_DESC101,'true'));
        */
            //Start BAC-5169
    if(isHtmlView){
      sec6.buttonList.add(createButtonWrapper('SECTION6_BTN6',System.Label.CONF005_TEXT85,svmxSettingList.containsKey('SET107') && svmxSettingList.get('SET107') != '0'? svmxSettingList.get('SET107'):'',System.Label.CONF005_DESC85,'true'));

      sec6.buttonList.add(createButtonWrapper('SECTION6_BTN7',System.Label.CONF005_TEXT16,svmxSettingList.containsKey('SET109')?svmxSettingList.get('SET109'):'',System.Label.CONF005_DESC16,'true'));

      sec6.buttonList.add(createButtonWrapper('SECTION6_BTN8',System.Label.CONF005_TEXT101,svmxSettingList.containsKey('SET108') && svmxSettingList.get('SET108') != '0'? svmxSettingList.get('SET108'):'',System.Label.CONF005_DESC101,'true'));
      
      sec6.buttonList.add(createButtonWrapper('SECTION6_BTN14',System.Label.CONF005_TEXT124,svmxSettingList.containsKey('SET110') ? svmxSettingList.get('SET110'):'',System.Label.CONF005_DESC124,'true'));  // Description for Smart Documents
      sec6.buttonList.add(createButtonWrapper('SECTION6_BTN15',System.Label.CONF005_TEXT125,svmxSettingList.containsKey('SET106') ? svmxSettingList.get('SET106'):'',System.Label.CONF005_DESC125,'true'));   // Description for Transactions    
    }else{
      sec6.buttonList.add(createButtonWrapper('SECTION6_BTN6',System.Label.CONF005_TEXT85,svmxSettingList.containsKey('SET080') && svmxSettingList.get('SET080') != '0'? svmxSettingList.get('SET080'):'',System.Label.CONF005_DESC85,'true'));

      sec6.buttonList.add(createButtonWrapper('SECTION6_BTN7',System.Label.CONF005_TEXT16,svmxSettingList.containsKey('SET016')?svmxSettingList.get('SET016'):'',System.Label.CONF005_DESC16,'true'));

      sec6.buttonList.add(createButtonWrapper('SECTION6_BTN8',System.Label.CONF005_TEXT101,svmxSettingList.containsKey('SET090') && svmxSettingList.get('SET090') != '0'? svmxSettingList.get('SET090'):'',System.Label.CONF005_DESC101,'true'));
      sec6.buttonList.add(createButtonWrapper('SECTION6_BTN1',System.Label.CONF005_TEXT52, svmxSettingList.containsKey('SET052') ? svmxSettingList.get('SET052')+'&isChecklistDisabled=true':'',System.Label.CONF005_DESC52,'true'));
    }
    // End BAC-5169
        sec6.buttonList.add(createButtonWrapper('SECTION6_BTN9',System.Label.CONF005_TEXT102,svmxSettingList.containsKey('SET091') && svmxSettingList.get('SET091') != '0'? svmxSettingList.get('SET091'):'',System.Label.CONF005_DESC102,'true'));
        
        sec6.buttonList.add(createButtonWrapper('SECTION6_BTN10',System.Label.CONF005_TEXT103,svmxSettingList.containsKey('SET092') && svmxSettingList.get('SET092') != '0'? svmxSettingList.get('SET092'):'',System.Label.CONF005_DESC103,'true'));        
        
        //Checklist URL 
        /* commented this code since a new section checklist is made as part of BAC-5170 arpit*/
       /* String checklistURL1 = '';
        if(svmxSettingList.containsKey('SET095')){
            if(svmxSettingToEnableAPL.containsKey('GBL029') && svmxSettingToEnableAPL.get('GBL029') != null && Boolean.valueOf(svmxSettingToEnableAPL.get('GBL029')))
                checklistURL1 = svmxSettingList.get('SET095');
        }
        sec6.buttonList.add(createButtonWrapper('SECTION6_BTN11',System.Label.CONF005_TEXT107,checklistURL1,System.Label.CONF005_DESC108,'true'));
        */
        /*commented this code since a new section checklist is made  as part of BAC-5170 end*/

        sec6.buttonList.add(createButtonWrapper('SECTION6_BTN12',System.Label.CONF005_TEXT112,svmxSettingList.containsKey('SET098') ? svmxSettingList.get('SET098') : '',System.Label.CONF005_DESC112,'true'));
        
        //sec6.buttonList.add(createButtonWrapper('SECTION6_BTN13',System.Label.CONF005_TEXT120, 'https://tools.servicemax.com:49494/MigrationTool/ChecklistLogin.jsp',System.Label.CONF005_DESC120,'true'));
        
        /* commented this code since a new section checklist is made as part of BAC-5170  and need to update wrapper's button id on subsequent buttons start arpit*/
        //sec6.buttonList.add(createButtonWrapper('SECTION6_BTN13',System.Label.CONF005_TEXT120,svmxSettingList.containsKey('SET103') ? svmxSettingList.get('SET103') : '',System.Label.CONF005_DESC120,'true'));

        /* commented this code since a new section checklist is made as part of BAC-5170*/ 
        
        
        obj.setupSections.add(sec6);
        
        //SECTION7
        CONF_SetupHome_Controller.SetupHomeSectionWrapper sec7 = new CONF_SetupHome_Controller.SetupHomeSectionWrapper();
        sec7.sectionId = 'SECTION7';
        sec7.sectionTitle = System.Label.CONF005_NAME77;
        sec7.sectionDescription = System.Label.CONF005_DESC77;
        //sec7.isSectionEnabled = 'false';
        //Commented above line and updated value based on setting value for fixing issue SFD-2053
        String strReverseLogisticEnabled = (svmxSettingToEnableAPL.containsKey('GBL014') && svmxSettingToEnableAPL.get('GBL014') != null && Boolean.valueOf(svmxSettingToEnableAPL.get('GBL014'))) ? 'true' : 'false';
        sec7.isSectionEnabled = strReverseLogisticEnabled;
        
        //Buttons for section 7
        sec7.buttonList = new List<CONF_SetupHome_Controller.SetupHomeButtonWrapper>();
        
        sec7.buttonList.add(createButtonWrapper('SECTION7_BTN1',System.Label.CONF005_TEXT75,svmxSettingList.containsKey('SET064') && svmxSettingList.get('SET064') != '0' ? svmxSettingList.get('SET064'):'',System.Label.CONF005_DESC75, strReverseLogisticEnabled)); //Added value strReverseLogisticEnabled for fixing defect SFD-2053 
        
        sec7.buttonList.add(createButtonWrapper('SECTION7_BTN2',System.Label.CONF005_TEXT74,svmxSettingList.containsKey('SET063')?svmxSettingList.get('SET063'):'',System.Label.CONF005_DESC74, strReverseLogisticEnabled)); //Added value strReverseLogisticEnabled for fixing defect SFD-2053
        
        sec7.buttonList.add(createButtonWrapper('SECTION7_BTN3',System.Label.CONF005_TEXT76,svmxSettingList.containsKey('SET065')? svmxSettingList.get('SET065'):'',System.Label.CONF005_DESC76, strReverseLogisticEnabled)); //Added value strReverseLogisticEnabled for fixing defect SFD-2053
        
        sec7.buttonList.add(createButtonWrapper('SECTION7_BTN4',System.Label.CONF005_TEXT70,svmxSettingList.containsKey('SET059')?svmxSettingList.get('SET059'):'',System.Label.CONF005_DESC70, strReverseLogisticEnabled)); //Added value strReverseLogisticEnabled for fixing defect SFD-2053
        
        sec7.buttonList.add(createButtonWrapper('SECTION7_BTN5',System.Label.CONF005_TEXT78,svmxSettingList.containsKey('SET062') && svmxSettingList.get('SET062') != '0'? svmxSettingList.get('SET062'):'',System.Label.CONF005_DESC78, strReverseLogisticEnabled)); //Added value strReverseLogisticEnabled for fixing defect SFD-2053
        
        sec7.buttonList.add(createButtonWrapper('SECTION7_BTN6',System.Label.CONF005_TEXT79,svmxSettingList.containsKey('SET066') && svmxSettingList.get('SET066') != '0'? svmxSettingList.get('SET066'):'',System.Label.CONF005_DESC79, strReverseLogisticEnabled)); //Added value strReverseLogisticEnabled for fixing defect SFD-2053
        
        sec7.buttonList.add(createButtonWrapper('SECTION7_BTN7',System.Label.CONF005_TEXT71,svmxSettingList.containsKey('SET060')?svmxSettingList.get('SET060'):'',System.Label.CONF005_DESC71, strReverseLogisticEnabled)); //Added value strReverseLogisticEnabled for fixing defect SFD-2053
        
        sec7.buttonList.add(createButtonWrapper('SECTION7_BTN8',System.Label.CONF005_TEXT81,svmxSettingList.containsKey('SET068') && svmxSettingList.get('SET068') != '0'? svmxSettingList.get('SET068'):'',System.Label.CONF005_DESC81, strReverseLogisticEnabled)); //Added value strReverseLogisticEnabled for fixing defect SFD-2053
        
        sec7.buttonList.add(createButtonWrapper('SECTION7_BTN9',System.Label.CONF005_TEXT80,svmxSettingList.containsKey('SET067') && svmxSettingList.get('SET067') != '0'? svmxSettingList.get('SET067'):'',System.Label.CONF005_DESC80, strReverseLogisticEnabled)); //Added value strReverseLogisticEnabled for fixing defect SFD-2053
        
        sec7.buttonList.add(createButtonWrapper('SECTION7_BTN10',System.Label.CONF005_TEXT72,svmxSettingList.containsKey('SET061') && svmxSettingList.get('SET061') != '0'? svmxSettingList.get('SET061'):'',System.Label.CONF005_DESC72, strReverseLogisticEnabled)); //Added value strReverseLogisticEnabled for fixing defect SFD-2053
        
        obj.setupSections.add(sec7);
        
        //SECTION8
        CONF_SetupHome_Controller.SetupHomeSectionWrapper sec8 = new CONF_SetupHome_Controller.SetupHomeSectionWrapper();
        sec8.sectionId = 'SECTION8';
        sec8.sectionTitle = System.Label.CONF005_NAME90;
        sec8.sectionDescription = System.Label.CONF005_DESC90;
        sec8.isSectionEnabled = 'true';
        //Buttons for Section 8
        sec8.buttonList = new List<CONF_SetupHome_Controller.SetupHomeButtonWrapper>();
        
        Schema.SObjectType objT_AvailableServicesHome;
        String AvailableServicesHomeURL = null;
        //Available services
        if( allObjs.get('SVMXC__Service__c') != null )
            objT_AvailableServicesHome = allObjs.get('SVMXC__Service__c');
        else
            objT_AvailableServicesHome = allObjs.get('Service__c');

        if(objT_AvailableServicesHome != null)
            AvailableServicesHomeURL = '/' + objT_AvailableServicesHome.getDescribe().getkeyPrefix() + '/l';        
        
        sec8.buttonList.add(createButtonWrapper('SECTION8_BTN1',System.Label.CONF005_TEXT53,svmxSettingList.containsKey('SET073') && svmxSettingList.get('SET073') !=null? AvailableServicesHomeURL:'',System.Label.CONF005_DESC53,'true'));
        
        String ActivityMasterHomeURL = null;
        Schema.SObjectType objT_ActivityMaster;
        if( allObjs.get('SVMXC__Activity_Master__c') != null )
            objT_ActivityMaster = allObjs.get('SVMXC__Activity_Master__c');
        else
            objT_ActivityMaster = allObjs.get('Activity_Master__c'); 
        
        if(objT_ActivityMaster != null)
            ActivityMasterHomeURL = '/' + objT_ActivityMaster.getDescribe().getkeyPrefix() + '/l';
        
        sec8.buttonList.add(createButtonWrapper('SECTION8_BTN2',System.Label.CONF005_TEXT93,svmxSettingList.containsKey('SET082') && svmxSettingList.get('SET082') !=null? ActivityMasterHomeURL:'',System.Label.CONF005_DESC93,'true'));
        
        String ServicePricebooksHomeURL = null;
        Schema.SObjectType objT_ServicePricebooks;
        if( allObjs.get('SVMXC__Service_Pricebook__c') != null )
            objT_ServicePricebooks = allObjs.get('SVMXC__Service_Pricebook__c');
        else
            objT_ServicePricebooks = allObjs.get('Service_Pricebook__c');
        
        if(objT_ServicePricebooks != null)
            ServicePricebooksHomeURL = '/' + objT_ServicePricebooks.getDescribe().getkeyPrefix() + '/l';
        
        sec8.buttonList.add(createButtonWrapper('SECTION8_BTN3',System.Label.CONF005_TEXT96,svmxSettingList.containsKey('SET085') && svmxSettingList.get('SET085') !=null? ServicePricebooksHomeURL:'',System.Label.CONF005_DESC96,'true'));
        
        String WarrantyTermsHomeURL = null;
        Schema.SObjectType objT_WarrantyTerms;
        if( allObjs.get('SVMXC__Service_Template__c') != null )
            objT_WarrantyTerms = allObjs.get('SVMXC__Service_Template__c');
        else
            objT_WarrantyTerms = allObjs.get('Service_Template__c');
        
         if(objT_WarrantyTerms != null)
            WarrantyTermsHomeURL = '/' + objT_WarrantyTerms.getDescribe().getkeyPrefix() + '/l';
        
        sec8.buttonList.add(createButtonWrapper('SECTION8_BTN4',System.Label.CONF005_TEXT97,svmxSettingList.containsKey('SET086') && svmxSettingList.get('SET086') !=null? WarrantyTermsHomeURL:'',System.Label.CONF005_DESC97,'true'));
        
        sec8.buttonList.add(createButtonWrapper('SECTION8_BTN5',System.Label.CONF005_TEXT27,svmxSettingList.containsKey('SET027')?svmxSettingList.get('SET027'):'',System.Label.CONF005_DESC27,'true'));
        
        String ServicePlansHomeURL = null;
        Schema.SObjectType objT_ServicePlans;
        if( allObjs.get('SVMXC__Service_Plan__c') != null )
            objT_ServicePlans = allObjs.get('SVMXC__Service_Plan__c');
        else
            objT_ServicePlans = allObjs.get('Service_Plan__c');
        
        if(objT_ServicePlans != null)
            ServicePlansHomeURL = '/' + objT_ServicePlans.getDescribe().getkeyPrefix() + '/l';
        
        sec8.buttonList.add(createButtonWrapper('SECTION8_BTN6',System.Label.CONF005_TEXT95,svmxSettingList.containsKey('SET084') && svmxSettingList.get('SET084') !=null?ServicePlansHomeURL:'',System.Label.CONF005_DESC95,'true'));
        
        sec8.buttonList.add(createButtonWrapper('SECTION8_BTN7',System.Label.CONF005_TEXT24,svmxSettingList.containsKey('SET024')?svmxSettingList.get('SET024'):'',System.Label.CONF005_DESC24,'true'));
        
        sec8.buttonList.add(createButtonWrapper('SECTION8_BTN8',System.Label.CONF005_TEXT86,svmxSettingList.containsKey('SET079') && svmxSettingList.get('SET079') != '0'? svmxSettingList.get('SET079'):'',System.Label.CONF005_DESC86,'true'));
        
        sec8.buttonList.add(createButtonWrapper('SECTION8_BTN9',System.Label.CONF005_TEXT87,svmxSettingList.containsKey('SET076') && svmxSettingList.get('SET076') != '0'? svmxSettingList.get('SET076'):'',System.Label.CONF005_DESC87,'true'));
        
        sec8.buttonList.add(createButtonWrapper('SECTION8_BTN10',System.Label.CONF005_TEXT88,svmxSettingList.containsKey('SET077') && svmxSettingList.get('SET077') != '0'? svmxSettingList.get('SET077'):'',System.Label.CONF005_DESC88,'true'));
        
        obj.setupSections.add(sec8);
        
        //SECTION9
        CONF_SetupHome_Controller.SetupHomeSectionWrapper sec9 = new CONF_SetupHome_Controller.SetupHomeSectionWrapper();
        sec9.sectionId = 'SECTION9';
        sec9.sectionTitle = System.Label.CONF005_NAME105;
        sec9.sectionDescription = System.Label.CONF005_DESC105;
        sec9.isSectionEnabled = 'true';
        //Buttons for Section 9
        sec9.buttonList = new List<CONF_SetupHome_Controller.SetupHomeButtonWrapper>();
        
        sec9.buttonList.add(createButtonWrapper('SECTION9_BTN1',System.Label.CONF005_TEXT106,svmxSettingList.containsKey('SET096')?svmxSettingList.get('SET096'):'',System.Label.CONF005_DESC106,'true'));
        
        //sec9.buttonList.add(createButtonWrapper('SECTION9_BTN2',System.Label.CONF005_TEXT111,svmxSettingList.containsKey('SET096')?svmxSettingList.get('SET096'):'',System.Label.CONF005_DESC111,'true'));
        //Commented above line and changed URL to the correct page for the issue SFD-2047.
        sec9.buttonList.add(createButtonWrapper('SECTION9_BTN2',System.Label.CONF005_TEXT111,'/apex/SVMXC__IOTSetup',System.Label.CONF005_DESC111,'true'));
        
        obj.setupSections.add(sec9);
        
        //SECTION10
        CONF_SetupHome_Controller.SetupHomeSectionWrapper sec10 = new CONF_SetupHome_Controller.SetupHomeSectionWrapper();
        sec10.sectionId = 'SECTION10';
        sec10.sectionTitle = System.Label.CONF005_NAME109;
        sec10.sectionDescription = System.Label.CONF005_DESC109;
        sec10.isSectionEnabled = 'true';
        //Buttons for Section 10
        sec10.buttonList = new List<CONF_SetupHome_Controller.SetupHomeButtonWrapper>(); 
        String SPMConfigURL = '';
        if(svmxSettingList.containsKey('SET097')){
            if(svmxSettingToEnableAPL.containsKey('GBL030') && svmxSettingToEnableAPL.get('GBL030') != null && Boolean.valueOf(svmxSettingToEnableAPL.get('GBL030'))){
                SPMConfigURL = svmxSettingList.get('SET097');
            }
        }
        sec10.buttonList.add(createButtonWrapper('SECTION10_BTN1',System.Label.CONF005_TEXT109,SPMConfigURL,System.Label.CONF005_DESC110,'true'));
        
        String optMetricURL = '';
        if(svmxSettingToEnableAPL.containsKey('GBL033') && svmxSettingToEnableAPL.get('GBL033') != null && Boolean.valueOf(svmxSettingToEnableAPL.get('GBL033'))){
            optMetricURL = '/apex/SVMXC__SPM_OPT_Configuration';
        }        
        
        //BAC-4915 commented the below line to hide from setup home
        //sec10.buttonList.add(createButtonWrapper('SECTION10_BTN2',System.Label.CONF005_TEXT113,optMetricURL,System.Label.CONF005_DESC113,'true'));
        
        obj.setupSections.add(sec10);
        
        //BAC-4730 regroup of Dispatch Console and Scheduling & Optimization
        //SECTION11
        CONF_SetupHome_Controller.SetupHomeSectionWrapper sec11 = new CONF_SetupHome_Controller.SetupHomeSectionWrapper();
        sec11.sectionId = 'SECTION11';
        sec11.sectionTitle = System.Label.CONF005_NAME123;
        sec11.sectionDescription = System.Label.CONF005_DESC123;
        sec11.isSectionEnabled = 'true';
        sec11.buttonList = new List<CONF_SetupHome_Controller.SetupHomeButtonWrapper>();
        //Buttons for Section 11
        //Booking window
        String BookingWindowsHomeURL = null;
        Schema.SObjectType objT_BookingWindowsHome;
        if( allObjs.get('SVMXC__Booking_Window__c') != null )
            objT_BookingWindowsHome = allObjs.get('SVMXC__Booking_Window__c');
        else
            objT_BookingWindowsHome = allObjs.get('Booking_Window__c');        
        if(objT_BookingWindowsHome != null)
            BookingWindowsHomeURL = '/' + String.valueOf(objT_BookingWindowsHome.getDescribe().getkeyPrefix()) + '/l';
        
        //BAC-4730 removed Booking Window
        //sec4.buttonList.add(createButtonWrapper('SECTION11_BTN1',System.Label.CONF005_TEXT56,svmxSettingList.containsKey('SET075')?BookingWindowsHomeURL:'',System.Label.CONF005_DESC56,'true'));        
        
        sec11.buttonList.add(createButtonWrapper('SECTION11_BTN2',System.Label.CONF005_TEXT21,svmxSettingList.containsKey('SET021')?svmxSettingList.get('SET021'):'',System.Label.CONF005_DESC21,'true'));        
        
        sec11.buttonList.add(createButtonWrapper('SECTION11_BTN3',System.Label.CONF005_TEXT22,svmxSettingList.containsKey('SET022')?svmxSettingList.get('SET022'):'',System.Label.CONF005_DESC22,'true'));        
        
        sec11.buttonList.add(createButtonWrapper('SECTION11_BTN4',System.Label.CONF005_TEXT23,svmxSettingList.containsKey('SET023')?svmxSettingList.get('SET023'):'',System.Label.CONF005_DESC23,'true'));        
        
        sec11.buttonList.add(createButtonWrapper('SECTION11_BTN5',System.Label.CONF005_TEXT25,svmxSettingList.containsKey('SET025')?svmxSettingList.get('SET025'):'',System.Label.CONF005_DESC25,'true'));
        
        sec11.buttonList.add(createButtonWrapper('SECTION11_BTN6',System.Label.CONF005_TEXT116,'/apex/SVMXC__WSCH_Provider_ECO_AppointmentWindowSetup',System.Label.CONF005_DESC116,'true'));        
        
        sec11.buttonList.add(createButtonWrapper('SECTION11_BTN7',System.Label.CONF005_TEXT99,svmxSettingList.containsKey('SET088') && svmxSettingList.get('SET088') != '0'? svmxSettingList.get('SET088'):'',System.Label.CONF005_DESC99,'true'));        
        
        sec11.buttonList.add(createButtonWrapper('SECTION11_BTN8',System.Label.CONF005_TEXT100,svmxSettingList.containsKey('SET089') && svmxSettingList.get('SET089') != '0'? svmxSettingList.get('SET089'):'',System.Label.CONF005_DESC100,'true'));
        
        sec11.buttonList.add(createButtonWrapper('SECTION11_BTN9',System.Label.CONF005_TEXT115,svmxSettingList.containsKey('SET100')?overnightPolicyHomeURL:'',System.Label.CONF005_DESC115,'true'));
        obj.setupSections.add(sec11);
        
        /* BAC-5170 changes start arpit */
        CONF_SetupHome_Controller.SetupHomeSectionWrapper sec12 = new CONF_SetupHome_Controller.SetupHomeSectionWrapper();
        sec12.sectionId = 'SECTION12';
        sec12.sectionTitle = System.Label.CONF007_GROUPNAME001; 
        sec12.sectionDescription = System.Label.CONF007_GROUPNAME001; 
        sec12.isSectionEnabled = 'true'; 
        sec12.buttonList = new List<CONF_SetupHome_Controller.SetupHomeButtonWrapper>();
        //String checklistURL = '';
        String isCheckListFeatureEnabled = svmxSettingToEnableAPL.containsKey('GBL029') && svmxSettingToEnableAPL.get('GBL029') != null && Boolean.valueOf(svmxSettingToEnableAPL.get('GBL029')) ? 'true' : 'false';
        sec12.buttonList.add(createButtonWrapper('SECTION12_BTN1',System.Label.CONF005_TEXT107,svmxSettingList.containsKey('SET095') ? svmxSettingList.get('SET095') : '',System.Label.CONF005_DESC108, isCheckListFeatureEnabled)); // Checklist Question Library
        sec12.buttonList.add(createButtonWrapper('SECTION12_BTN2',System.Label.CONF005_TEXT120,svmxSettingList.containsKey('SET103') ? svmxSettingList.get('SET103') : '',System.Label.CONF005_DESC120,isCheckListFeatureEnabled)); // Checklist Import
        if (isHtmlView) { //Added for BAC-5696
            sec12.buttonList.add(createButtonWrapper('SECTION12_BTN3',System.Label.CONF007_TEXT1,svmxSettingList.containsKey('SET111') ? svmxSettingList.get('SET111') : '',System.Label.CONF007_DESC1,isCheckListFeatureEnabled)); // Lightning Checklist Designer
        }else {
            sec12.buttonList.add(createButtonWrapper('SECTION12_BTN3',System.Label.CONF007_TEXT1,svmxSettingList.containsKey('SET052') ? svmxSettingList.get('SET052')+'&isStandAloneChecklist=true&enableChecklistTitle=true' : '',System.Label.CONF007_DESC1,isCheckListFeatureEnabled)); // Checklist Designer
        
        }
        //sec12.buttonList.add(createButtonWrapper('SECTION12_BTN3',System.Label.CONF007_TEXT1,svmxSettingList.containsKey('SET052') ? svmxSettingList.get('SET052')+'&isStandAloneChecklist=true&enableChecklistTitle=true' : '',System.Label.CONF007_DESC1,isCheckListFeatureEnabled)); // Checklist Designer  //Commented for BAC-5696
        obj.setupSections.add(sec12);
        /* BAC-5170 changes ends arpit */
        
        //Recently visited
        obj.recentlyVisited = new CONF_SetupHome_Controller.RecentlyVisitedWrapper();
        obj.recentlyVisited.recentlyVisitedTitle = System.Label.CONF005_TAG007;
        obj.recentlyVisited.recentlyVisitedBtnIds = new List<String>();
        List<SVMXC__SM_Recent_Items__c> listRecentItems = new List<SVMXC__SM_Recent_Items__c>();
        List<String> queryFields = new List<String>{'SVMXC__SM_Link_Id__c'};
        if( !COMM_SecurityUtils.getInstance().verifyFieldAccess( 'SVMXC__SM_Recent_Items__c', queryFields, COMM_SecurityUtils.Access.Accessible ) ) {
            throw new AuraHandledException( System.Label.COMM001_TAG142 );
        }//SDL-SVM-CREATE-UPDATE-FLS-ENFORCED
        listRecentItems = [Select Id,SVMXC__SM_Link_Id__c From SVMXC__SM_Recent_Items__c Where SVMXC__SM_User__c = :UserInfo.getUserId() order by LastModifiedDate desc];
        for(SVMXC__SM_Recent_Items__c recentItems : listRecentItems ){
            obj.recentlyVisited.recentlyVisitedBtnIds.add(recentItems.SVMXC__SM_Link_Id__c);
        }
        /*obj.recentlyVisited.recentlyVisitedBtnIds.add('SECTION2_BTN3');
        obj.recentlyVisited.recentlyVisitedBtnIds.add('SECTION3_BTN3');
        obj.recentlyVisited.recentlyVisitedBtnIds.add('SECTION4_BTN3');
        obj.recentlyVisited.recentlyVisitedBtnIds.add('SECTION2_BTN5');*/
        
        
        return obj;
    }

    @AuraEnabled
    public static SetupHomeButtonWrapper createButtonWrapper(String strButtonId,String strButtonLabel,String strButtonUrl,String strButtonDesc,String strButtonEnabled){
        CONF_SetupHome_Controller.SetupHomeButtonWrapper button = new CONF_SetupHome_Controller.SetupHomeButtonWrapper();
        button.buttonId = strButtonId;
        button.buttonLabel = strButtonLabel;   
        button.buttonUrl = strButtonUrl;
        button.buttonDescription = strButtonDesc;
        if(String.isBlank(strButtonUrl)){
            button.isButtonEnabled = 'false';
        }else{
            button.isButtonEnabled = strButtonEnabled;
        }
        return button;
    }
    
    @AuraEnabled
    public static void updateRecentItem(String strButtonId){
        Boolean check = false;//this is true if item already exists in the list
        List<SVMXC__SM_Recent_Items__c> listRecentItems = new List<SVMXC__SM_Recent_Items__c>();
        List<String> queryFields = new List<String>{'SVMXC__SM_Link_Id__c','SVMXC__SM_User__c'};
        if( !COMM_SecurityUtils.getInstance().verifyFieldAccess( 'SVMXC__SM_Recent_Items__c', queryFields, COMM_SecurityUtils.Access.Accessible ) ) {
            throw new AuraHandledException( System.Label.COMM001_TAG142 );
        }//SDL-SVM-CREATE-UPDATE-FLS-ENFORCED
        listRecentItems = [Select Id,SVMXC__SM_Link_Id__c,SVMXC__SM_User__c From SVMXC__SM_Recent_Items__c Where SVMXC__SM_User__c = :UserInfo.getUserId() order by LastModifiedDate Asc];
        system.debug('listRecentItems =='+listRecentItems);
        SVMXC__SM_Recent_Items__c itemToUpdate = new SVMXC__SM_Recent_Items__c();
        for(SVMXC__SM_Recent_Items__c recentItems : listRecentItems ){
            if(recentItems.SVMXC__SM_Link_Id__c == strButtonId){
                //Already Exists in the List
                //Bring it to the top
                //update the item if already existing in the list and list size is less than 10 
                itemToUpdate = recentItems;                              
                check = true;
                break;
            }
        }
        if(itemToUpdate.Id !=null) {
            if(COMM_SecurityUtils.getInstance().verifyFieldAccess( itemToUpdate, COMM_SecurityUtils.Access.Updateable )){
            //SDL-SVM-CREATE-UPDATE-FLS-ENFORCED
            update itemToUpdate;
            } else {
            throw new AuraHandledException(System.Label.COMM001_TAG142);
            }
        }
        
        if(!check && listRecentItems.size()<10){
            //item strButtonId does not exist in the list. Create a record with this item
            SVMXC__SM_Recent_Items__c newItem = new SVMXC__SM_Recent_Items__c(SVMXC__SM_Link_Id__c=strButtonId,SVMXC__SM_User__c = UserInfo.getUserId());
            Database.SaveResult result;
            if( COMM_SecurityUtils.getInstance().verifyFieldAccess( newItem, COMM_SecurityUtils.Access.Createable ) ) {
                //SDL-SVM-CREATE-UPDATE-FLS-ENFORCED
                result = Database.insert(newItem,false);
            } else {
                throw new AuraHandledException(System.Label.COMM001_TAG142);
            }
            
            system.debug('==='+result);
        }else if(!check && listRecentItems.size()==10){            
             //list size greater than 10, replace oldest record with this new item
             system.debug('==='+listRecentItems[0]);
             SVMXC__SM_Recent_Items__c itemToDelete = listRecentItems[0];
             if(COMM_SecurityUtils.getInstance().isDeletableObject( 'SVMXC__SM_Recent_Items__c' )){
              delete itemToDelete; //SDL-SVMX-DELETE-FLS-ENFORCED
            }
            else{
              throw new AuraHandledException(System.label.COMM001_TAG142);
            }
             
            SVMXC__SM_Recent_Items__c newItem = new SVMXC__SM_Recent_Items__c(SVMXC__SM_Link_Id__c=strButtonId,SVMXC__SM_User__c = UserInfo.getUserId());
            Database.SaveResult result;
            if( COMM_SecurityUtils.getInstance().verifyFieldAccess( newItem, COMM_SecurityUtils.Access.Createable ) ) {
                //SDL-SVM-CREATE-UPDATE-FLS-ENFORCED
                result = Database.insert(newItem,false);
            } else {
                throw new AuraHandledException(System.Label.COMM001_TAG142);
            }
            
             system.debug('==='+result);
             
        }
        
    }
    
    //BAC-5957
    @AuraEnabled
    public static void callPostPackageInstall(){
        TOOL_PostPackageInstall objTOOL_PostPackageInstall = new TOOL_PostPackageInstall();
        objTOOL_PostPackageInstall.manualInstall();
        
        SVMXC__ServiceMax_Properties__c objProperties = SVMXC__ServiceMax_Properties__c.getValues('TOOL001');
        objProperties.SVMXC__Value__c = 'Inprogress';
        update objProperties;
    }
    
    //BAC-5957
    @AuraEnabled
    public static Boolean checkToolSeedStatus(){
        Integer intMaxTimeCheckForButtonEnabled = 60;
        Boolean isButtonEnabled = true;
        SVMXC__ServiceMax_Properties__c objProperties = SVMXC__ServiceMax_Properties__c.getValues('TOOL001');
        if(objProperties != null && objProperties.SVMXC__Key__c.equalsIgnoreCase('Tool_Seed_Status')){
            Long propertiesModifiedTime = objProperties.LastModifiedDate.getTime();
            Long currentTime = System.now().getTime();
            Long minutesPast = ((currentTime - propertiesModifiedTime) / 1000) / 60;
            if(objProperties.SVMXC__Value__c.equalsIgnoreCase('Inprogress') && minutesPast >= intMaxTimeCheckForButtonEnabled){
                objProperties.SVMXC__Value__c = 'Completed';
                update objProperties;
                isButtonEnabled = true;
            }
            else{
                if(objProperties.SVMXC__Value__c.equalsIgnoreCase('Inprogress')){
                    isButtonEnabled = false;
                }
                else if(objProperties.SVMXC__Value__c.equalsIgnoreCase('Completed')){
                    isButtonEnabled = true;
                }
            }
        }
        return isButtonEnabled;
    }
}