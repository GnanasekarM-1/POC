global with sharing class SFMSearchDelivery {

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
    public string urlPath  {get; set;} 
    public SFMSearchDelivery(){
        // Jaysukh: BAC - 3517
        // Based on Showheader beaviour URL needs to be modified.
        // a) If showheader = true; replace inline =1 with ''
        // b) If showheader = false; keep URL as is
        // And assign the newly created appened with BaseURl. It should serve community as well.
        String redirectUrl =  ApexPages.currentPage().getUrl();
        //Defect 043621 : Added below condition to work sfm search when site prefix is available
        if(Site.getPrefix() !=null && Site.getPrefix()!= '')
        {
            redirectUrl = Site.getPrefix() + redirectUrl;
        }
        Boolean showHeader =  Boolean.valueOf(ApexPages.currentPage().getParameters().get('showHeader'));
         
         if(showHeader && redirectUrl.contains('inline=1')){
             urlPath  = System.URL.getSalesforceBaseUrl().toExternalForm()+  redirectUrl.replace('inline=1','');
         }
    }
    
    public String getSearchInfo(){

        return JSON.serialize(
            new SVMXC.SFMSearchDeliveryServiceImpl().getSearchInfoInternal(
                new SVMXC.SFMSearchDeliveryServiceImpl.SearchInfoRequest()
            )
        );
    }
    
    //Added for the story BAC-4063 to sending userinfo to the client
    public String getUserInfo(){
        return JSON.serialize(
            new SVMXC.SFMDeliveryServiceImpl().getUserInfoInternal()
        );
    }
    
    @RemoteAction
    global static Object JsrGetSearchInfo(String requestStr){
        
        SVMXC.SFMSearchDeliveryServiceImpl.SearchInfoRequest sir = new SVMXC.SFMSearchDeliveryServiceImpl.SearchInfoRequest();
        return JSON.serialize(new SVMXC.SFMSearchDeliveryServiceImpl().getSearchInfoInternal(sir));
    }
    
    @RemoteAction
    global static Object JsrGetSearchResult(String requestStr){
        
        SVMXC.SFMSearchDeliveryServiceImpl.SearchResultRequest srr = (SVMXC.SFMSearchDeliveryServiceImpl.SearchResultRequest)
                    JSON.deserialize(requestStr, SVMXC.SFMSearchDeliveryServiceImpl.SearchResultRequest.class);
        return JSON.serialize(new SVMXC.SFMSearchDeliveryServiceImpl().getSearchResultInternal(srr  ));
    }
    
    @RemoteAction
    global static Object JsrGetWizardInfo(String requestStr){
        
        SVMXC.SFMWizardDeliveryServiceImpl.WizardInfoRequest wir = (SVMXC.SFMWizardDeliveryServiceImpl.WizardInfoRequest)
                    JSON.deserialize(requestStr, SVMXC.SFMWizardDeliveryServiceImpl.WizardInfoRequest.class);

        return JSON.serialize(new SVMXC.SFMWizardDeliveryServiceImpl().getWizardInfoInternal(wir));
    }
}