public with sharing class SFM_Mappings
{
    /** Start - NPS Related code **/
    public string getUserLocaleKey(){
        return UserInfo.getLanguage();
    }
    public string getUserID(){
        return UserInfo.getUserId().substring(0, 15);
    }
    public string getUserOrgID(){
        return UserInfo.getOrganizationId().substring(0, 15);
    }
    /** End - NPS Related code **/
    
    public string returnURL = '';
    public string getreturnURL(){return returnURL;}
    public SFM_Mappings()
    {
        if(ApexPages.currentPage().getParameters().containskey('SVMX_retURL'))
            returnURL = ApexPages.currentPage().getParameters().get('SVMX_retURL');
            
         //Added for the story BAC-4797
         if(UserInfo.getUiThemeDisplayed()=='Theme4d'|| UserInfo.getUiThemeDisplayed()=='Theme4u'){
             returnURL = '/lightning/n/SVMXC__ServiceMax_Setup';
         }
    }
    public String getuserAuthTag(){return system.label.SFM001_TAG088;}
    public String getloadingTag(){return system.label.SFM001_TAG102;}
    public String getloadingProcTag(){return system.label.SFM001_TAG090;}
    public String getwelcomeTag(){return system.label.SFM001_TAG021;} 
}