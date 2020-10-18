public  with sharing class CONF_FeatureSetup{

    public SVMXC.COMM_Utils_V2 comm_utils_v2 = new SVMXC.COMM_Utils_V2();
    public Boolean  getIsChecklistFeatureEnabled(){
        String userId = getUserID();
        Boolean isEnabled = false;
        if(Boolean.valueOf(isChecklistSettingEnabled))
            isEnabled = comm_utils_v2.isFeatureEnabled('CHECKLIST',userId);
        return isEnabled;
    }
    
    public string getUserLocaleKey(){
        return UserInfo.getLanguage();
    }
    public string getUserID(){
        return UserInfo.getUserId().substring(0, 15);
    }
    public string getUserOrgID(){
        return UserInfo.getOrganizationId().substring(0, 15);
    }
    
    public String GetSvmxLogoId()
    {
        List<Document> DocList = [Select Id, Name From Document where Name = 'ServiceMax Logo' limit 1]; //SDL-SVMX-FLS-NOT-ENFORCED-META-DATA
        if(DocList != null && DocList.size() > 0)
        {
            return '/servlet/servlet.FileDownload?file=' + DocList[0].Id;
        }
        else
            return 'File not found';
    }
    public SVMXC.COMM_Utils_ManageSettings commSettings = new SVMXC.COMM_Utils_ManageSettings();
    public Map<String, String> svmxSettingList = new Map<String,String>();
    public String isChecklistSettingEnabled = '';    
    
    // Translation
    public String getTagGroupName1() {return System.Label.CONF007_GROUPNAME001;}    // Checklist Manager.
    public String getTagGroupTitle1() {return System.Label.CONF007_GROUPTITLE001;}    // Checklist Manager.
    public String getTagGroupDes1() {return System.Label.CONF007_GROUPDEC001;}    // Checklist Dec.

    public String getTagName1() {return System.Label.CONF007_NAME1;}    // Checklist Designer.
    public String getTagTitle1() {return System.Label.CONF007_TEXT1;}    // Checklist Designer.
    public String getTagDesc1() {return System.Label.CONF007_DESC1;}    // Checklist Designer provides an interactive interface to define Checklist transactions. The configured Checklist transaction can then be deployed using SFM Wizard.

    public String getTagName2() {return System.Label.CONF007_NAME2;}    // Checklist Question Library.
    public String getTagTitle2() {return System.Label.CONF007_TEXT2;}    // Checklist Question Library.
    public String getTagDesc2() {return System.Label.CONF007_DESC2;}    // You can use this option to manage questions for checklist.

    public String getTagName3() {return System.Label.CONF007_NAME3;}    // Checklist Import.
    public String getTagTitle3() {return System.Label.CONF007_TEXT3;}    // Checklist Import.
    public String getTagDesc3() {return System.Label.CONF007_DESC3;}    // Use this option to launch the application with which you can import Checklists from an external file into ServiceMax application.

    public String getTAG001() {return System.Label.CONF007_TAG001;}    // Welcome to ServiceMax Feature Administration.
    public String getTAG002() {return System.Label.CONF007_TAG002;}    // You can use this screen to configure specific ServiceMax applications. If some or all buttons are disabled here, please contact your administrator.
    public String getTagGroupNote() {return System.Label.CONF005_TEXT83;}


    // URLs 
    //public String getTagURL120() {return System.Label.CONF007_URL1;} 
    //Commented above line for fixing issue BAC-4013 and added below line for respect setting value for button URL
    public String getTagURL120() {return svmxSettingList.containsKey('SET103') && svmxSettingList.get('SET103') != null ? svmxSettingList.get('SET103') : '';  } 
    //public String getTagURL52() {return svmxSettingList.containsKey('SET052')?svmxSettingList.get('SET052'):'';}//Commented for BAC-5682
    public String getTagURL52() { //Added for BAC-5682
        if(isHtmlView && svmxSettingList.containsKey('SET111')){ //Added for BAC-5627
            return svmxSettingList.get('SET111');
        }
        return svmxSettingList.containsKey('SET052')?svmxSettingList.get('SET052'):'';
    }
    public String getTagURL95(){
        if(svmxSettingList.containsKey('SET095')){
            if(Boolean.valueOf(isChecklistSettingEnabled))
                return svmxSettingList.get('SET095');
        }
        return '';
    }
    public String getTagHLPURL() {return System.Label.CONF007_HLPURL;} // 
    public String getTagGroupText1() {return System.Label.CONF005_TEXT63;}  //General App Administration
    public String getLicenseType(){ return comm_utils_v2.getSVMX_License(); }//Fetching License type of the product
    public String getVersionNo(){   return String.valueOf(Decimal.valueOf(String.valueOf(System.requestVersion())).setScale(5));    }//Fetching Version No. of the product
    public String getCONF005_TAG004(){  return System.Label.CONF005_TAG004; }//Version:
    public String getCONF005_TAG005(){  return System.Label.CONF005_TAG005; }//Servicemax respects all licensing permissions at runtime. Please ensure that each user is setup with the proper license type to gain access to specific features.    
    public Boolean isHtmlView{get;set;} //Added for BAC-5682
    public CONF_FeatureSetup()
    {
        try
        {
            isChecklistSettingEnabled = commSettings.SVMX_getGlobalSettingList('GLOB001_GBL029');
            svmxSettingList = commSettings.SVMX_getSettingList('CONF005');
            //Added for BAC-5682
            if(commSettings.SVMX_getGlobalSettingList('SFM001_SET006').equalsIgnoreCase('HTML')){
                isHtmlView = true;
            }else{
                isHtmlView = false;
            }
            //End for BAC-5682
 
        }
        catch(Exception ex)
        {
            ApexPages.addMessage(new ApexPages.Message ( ApexPages.Severity.ERROR,System.Label.COMM001_TAG106));
        }
        
    }

}