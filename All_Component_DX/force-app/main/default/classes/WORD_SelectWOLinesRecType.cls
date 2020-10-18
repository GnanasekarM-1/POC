/* Security Scanned */
public  with sharing class WORD_SelectWOLinesRecType{


    //=========================================== URL Parameters ==============================================//
    String workorderId = System.currentPageReference().getParameters().get('id');
    
    
    //============================================== Global variables =========================================//
    String SelectedRecordType;
    String WorkDetails = 'SVMXC__Service_Order_Line__c';
    List<SelectOption> rTypeNames = new List<SelectOption>();
    Boolean ShowValidData = true;
    SVMXC__Service_Order__c WOHeader;

    String Usage = 'Usage/Consumption';
    Id UsgRecType = getUsgRecordTypes().Id;
    String UsgRecTypeName = getUsgRecordTypes().Name;

    String Est = 'Estimate';

    Id EstRecType = getEstRecordTypes().Id;
    String EstRecTypeName = getEstRecordTypes().Name;
    
    String Rr = 'Request/Receipt';
    Id ReqRecTypes = getReqRecTypes().Id;

    //================= Global Variables (with get & set methods) to manage display of Errors ===============//
    List<String> ErrorMessages = new  List<String> ();
    Boolean ValidRecords = true;
  
    public void AddToErrorsList(String msg) { ErrorMessages.add(msg); }
    public List<String> getErrorsList() {    return ErrorMessages; }  

    public Boolean DisplayBlockLevelMessage = false;
    public Boolean getDisplayBlockLevelMessage(){ return DisplayBlockLevelMessage; }
    public boolean GoToPage=false;
    public Boolean getGoToPage(){ return GoToPage; }

    //================================= Common Utility setting declaration =================================//
    SVMXC.COMM_Utils utils = new SVMXC.COMM_Utils();
    SVMXC.COMM_Utils_ManageSettings settings = new SVMXC.COMM_Utils_ManageSettings();
    
    //Create instance of UTIL Class
    SVMXC.COMM_Utils_ManageTags commUtil = new SVMXC.COMM_Utils_ManageTags();

    //======================================== Setting Definition =========================================//
    Map<String, String> AllSubModuleSettings = settings.SVMX_getSettingList('WORD005');
    String EstUsgVFPage = AllSubModuleSettings.get('SET001'); //setting to get  WORD_CreateWOEstUsgLines VF Page
    String ReqRsptVFPage = AllSubModuleSettings.get('SET002'); //setting to get WORD_CreateWOReqResLines VF Page

    //====================================== Getter & Setter methods ==========================================//
    public String getSelectedRecordType(){ return SelectedRecordType;}
    public void setSelectedRecordType(String RType) { SelectedRecordType = RType;  }

    public Boolean getShowValidData(){ return ShowValidData;} 
    public void setShowValidData(Boolean svd) {ShowValidData=svd;}



    //============================== Method to Display Errors/Warnings ======================================// 
    public void DisplayErrorsNWarnings(){
       
        if( ErrorMessages.size()>0)
            {
                ValidRecords = false;  
                DisplayBlockLevelMessage = false; 
                for (String msg : ErrorMessages)
                    {
                    ApexPages.AddMessage(new ApexPages.Message(ApexPages.Severity.Error,getTAG007(),msg)) ;  
                    }
            }   
    }


    //================================================ Constructor ============================================//
    public WORD_SelectWOLinesRecType(ApexPages.StandardController controller)
    {
        WOHeader = new SVMXC__Service_Order__c(); 
        WOHeader = getWOrderHeader();

        if (workorderId == null)
        {
           ShowValidData = false;
           AddToErrorsList(getTAG008());       //Source Object Work Order Id not found
        }

        ValidateAllSettings();   
        DisplayErrorsNWarnings();
    
    //Here we build the picklist
        try
        {   //SDL-SVMX-FLS-NOT-ENFORCED-META-DATA
            rt = [select Id,Name from RecordType where SobjectType='SVMXC__Service_Order_Line__c' ];
        }
        catch (Exception e)
        { 
            ApexPages.addMessage(new ApexPages.Message ( ApexPages.Severity.ERROR,getTAG007(),e.getMessage()));
        }
        Schema.DescribeSObjectResult WoLineSobj = Schema.SObjectType.SVMXC__Service_Order_Line__c;
        Map<Id,Schema.RecordTypeInfo> rtMapById = WoLineSobj.getRecordTypeInfosById();
        for(RecordType rtloop:rt)
        {
            /*Commented by naveen on 15/11/2010: fix is for tm lines not wrking for translations
            Schema.RecordTypeInfo rtById = rtMapById.get(rtloop.id);
            Map<String,Schema.RecordTypeInfo> rtMapByName = WoLineSobj.getRecordTypeInfosByName();
            Schema.RecordTypeInfo rtByName = rtMapByName.get(rtloop.name);
            
            if(rtByName.isAvailable())
            {
                rTypeNames.add(new SelectOption(rtloop.Id,rtloop.Name));
            }
            if(rtByName.isDefaultRecordTypeMapping())
                SelectedRecordType = rtloop.Id;*/
            Schema.RecordTypeInfo rtById = rtMapById.get(rtloop.id);
            if(rtById .isAvailable())
            {
                rTypeNames.add(new SelectOption(rtById.getRecordTypeId(),rtById.getName()));
            }
            if(rtById.isDefaultRecordTypeMapping())
                SelectedRecordType = rtById.getRecordTypeId();
        }
        if(rTypeNames.size()==1)
            GotoPage=true;
    }

    
    //===================================== Validation for all Settings ===================================//
     public void ValidateAllSettings(){
         
         if (EstUsgVFPage == null)
         {
             ShowValidData = false;
             AddToErrorsList(getTAG009()); //Setting not available for WORD_CreateWOEstUsgLines VF Page name
         }
            
         if (ReqRsptVFPage == null)
         {
             ShowValidData = false;
             AddToErrorsList(getTAG009()); //Setting not available for WORD_CreateWOReqResLines VF Page name
         }
    }




    //========================================== Retriving Source Object Record ===============================//
    public SVMXC__Service_Order__c getWOrderHeader() {
             
            try{
                String SOQLDetail = ' SELECT Id, Name From SVMXC__Service_Order__c where Id=\''+workorderId+'\'';
                WOHeader= Database.query(SOQLDetail);

                } catch (Exception e){ 
            ApexPages.addMessage(new ApexPages.Message ( ApexPages.Severity.ERROR,getTAG007(),e.getMessage()));
            return null;}

            return WOHeader;            
        }

    //============================ method to retrive all Work Details Record Types ============================//
    List<RecordType> rt = new List<RecordType> ();
    public List<SelectOption> getObjectRecordTypes()
    {
        return rTypeNames;
    }


    //========================== Method to retrive Usage/Consumption Record Type ==========================//
    public RecordType getUsgRecordTypes(){
        
        RecordType erUTypes;

        try{
            String SOQL  = 'SELECT Id,Name FROM RecordType where SobjectType  =\''+WorkDetails+'\' and Name=\''+Usage+'\' ';
            //SDL-SVMX-FLS-NOT-ENFORCED-META-DATA
            erUTypes = Database.query(SOQL);
            
           } catch (Exception e){ 
            ApexPages.addMessage(new ApexPages.Message ( ApexPages.Severity.ERROR,getTAG007(),e.getMessage()));
            return null;}

        return erUTypes;
    }


    //========================== Method to retrive Usage/Consumption Record Type ==========================//
    public RecordType getEstRecordTypes(){
        
        RecordType erETypes;

        try{
            String SOQL  = 'SELECT Id,Name  FROM RecordType where SobjectType  =\''+WorkDetails+'\' and Name=\''+Est+'\' ';
            //SDL-SVMX-FLS-NOT-ENFORCED-META-DATA
            erETypes = Database.query(SOQL);
            
           } catch (Exception e){ 
            ApexPages.addMessage(new ApexPages.Message ( ApexPages.Severity.ERROR,getTAG007(),e.getMessage()));
            return null;}

        return erETypes;
    }


    //========================== Method to retrive Usage/Consumption Record Type ==========================//
    public RecordType getReqRecTypes(){
                        RecordType ReqTypes;       
        try{
            String SOQL  = 'SELECT Id,Name  FROM RecordType where SobjectType  =\''+WorkDetails+'\' and Name=\''+Rr+'\' ';
            //SDL-SVMX-FLS-NOT-ENFORCED-META-DATA
            ReqTypes = Database.query(SOQL);
            
           } catch (Exception e){ 
            ApexPages.addMessage(new ApexPages.Message ( ApexPages.Severity.ERROR,getTAG007(),e.getMessage()));
            return null;}

        return ReqTypes;
    }

    //=================== Method executes on click of Add Lines button to launch diff pages ==================//
    public PageReference LaunchAddLines() {
        
        if(SelectedRecordType == EstRecType)
        {           
            PageReference newWOLPage = new PageReference('/apex/'+EstUsgVFPage+'?id='+workorderId+'&TargetRecordType='+EstRecTypeName);
            return newWOLPage;
        }

       else if(SelectedRecordType == UsgRecType)
        {           
            PageReference newWOLPage = new PageReference('/apex/'+EstUsgVFPage+'?id='+workorderId+'&TargetRecordType='+UsgRecTypeName);
            return newWOLPage;
        }

        else if(SelectedRecordType == ReqRecTypes)
        {
            PageReference newWOLPage = new PageReference('/apex/'+ReqRsptVFPage+'?id='+workorderId);
            return newWOLPage;
        }
        else
        {
                //set key prefix
                        Schema.DescribeSObjectResult SXferLine = SVMXC__Service_Order_Line__c.SObjectType.getDescribe(); 
                PageReference newWOLPage = new PageReference('/'+SXferLine.getKeyPrefix()+'/e?retURL=%2F'+workorderId+'&RecordType='+SelectedRecordType);
                return newWOLPage;
        }

        /*********Removing below lines as it is dead code which will never get executed . this is done while API upgrade *******/
        
        
       // PageReference scPage = new PageReference('/' + workorderId);
        //scPage.setRedirect(true);
       // return scPage;
    }
    
    
    //=============================== Method executes on click of Cancel button ==============================//
    public PageReference Cancel() {
        PageReference scPage = new PageReference('/' + workorderId);
        scPage.setRedirect(true);
        return scPage;   
    }

    //=========================================== Translation ===============================================//

     // Call a Method in UTIL class to return Tags, Send SubModule ID for getting TAGS
    //public Map<String, String> svmxTagList = commUtil.SVMX_getTagList('WORD005'); 

    // Ddefine getter method for each tag you have in VF page
    public String getTAG001(){ return system.label.WORD005_TAG001;} //Create Work Order Lines  
    public String getTAG002(){ return system.label.WORD005_TAG002;} //Add Lines To Work Order:  
    public String getTAG003(){ return system.label.WORD005_TAG003;} //Add Lines to Work Order Help  
    public String getTAG004(){ return system.label.WORD005_TAG004;} //Continue
    public String getTAG005(){ return system.label.WORD005_TAG005;} //Cancel
    public String getTAG006(){ return system.label.WORD005_TAG006;} //Select Work Details Record Type
    public String getTAG007(){ return system.label.WORD005_TAG007;} //Error:
    public String getTAG008(){ return system.label.WORD005_TAG008;} //No valid source record was not provided to create work order lines
    public String getTAG009(){ return system.label.WORD005_TAG009;} //An error occurred when trying to obtain configuration settings for this screen. Please contact your ServiceMax administrator immediately. 
    public String getHLPURL(){ return system.label.WORD005_HLPURL;}
 
}