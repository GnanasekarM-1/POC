/* Security Scanned */
public  with sharing class WORD_CreateWOFromCase{
    // ------------------------NPS Related changes  ---------
    public string getUserLocaleKey()
    {
        return UserInfo.getLanguage();
    }
    public string getUserID()
    {
        return UserInfo.getUserId().substring(0, 15);
    }
    public string getUserOrgID()
    {
        return UserInfo.getOrganizationId().substring(0, 15);
    }

    // -------------------------------
    
    //========================================= URL Parameters ===============================================//
    String caseId = String.escapeSingleQuotes(System.currentPageReference().getParameters().get('cid'));
 

    //========================================== Global Declarations =========================================//
    public String SelectedRecordType;
    public List<RecordType> rTypes = new List<RecordType> ();
    public List<SelectOption> rTypeNames = new List<SelectOption>();
    String LineSobjectType = 'SVMXC__Service_Order__c';
    Case CaseHeader;
    Boolean ShowValidData = true;
    Integer count=0;
    

    //=========== Global Variables (with get & set methods) to manage display of Warnings and Errors =========//

    List<String> ErrorMessages = new  List<String> ();
    Boolean ValidRecords = true;
 
    public void AddToErrorsList(String msg) { ErrorMessages.add(msg); }
    public List<String> getErrorsList() {    return ErrorMessages; }  

    public Boolean DisplayBlockLevelMessage = false;
    public Boolean getDisplayBlockLevelMessage(){ return DisplayBlockLevelMessage; }
    
    public Boolean btnisdisabled = false; 
    public Boolean getbtnisdisabled(){return btnisdisabled;} 
    

    

    //=============================== Object to retrive Settings & Translation =============================//
    public SVMXC.COMM_Utils utils = new SVMXC.COMM_Utils();
    public SVMXC.COMM_Utils_ManageSettings settings = new SVMXC.COMM_Utils_ManageSettings();

    //Create instance of UTIL Class
    // public SVMXC.COMM_Utils_ManageTags commUtil = new SVMXC.COMM_Utils_ManageTags();



    //===================================== List to store new lines =======================================//
    public List<SVMXC__ServiceMax_Config_Data__c> fieldMapSetting = new List<SVMXC__ServiceMax_Config_Data__c> ();

    
    //======================================== Setting Definition =========================================//
    public Map<String, String> AllSubModuleSettings = settings.SVMX_getSettingList('WORD004');
    String SettingValue = AllSubModuleSettings.containsKey('SET001')? AllSubModuleSettings.get('SET001') : ''; //Setting for WO field mapping
    String SelectRecTypeWOLVFPage = AllSubModuleSettings.containsKey('SET002')?AllSubModuleSettings.get('SET002') : ''; //Setting for wo select record type VF page name
    //String SetngForDefRecType = AllSubModuleSettings.containsKey('SET003')?AllSubModuleSettings.get('SET003') : ''; //Setting for Record Type set to Default
    String IsHeaderOnly = AllSubModuleSettings.containsKey('SET004')?AllSubModuleSettings.get('SET004') : ''; //Setting for Create header only on creating Work Order from Case
    
    //======================================= Getter & Setter =============================================//
    public String getSelectedRecordType(){ return SelectedRecordType;}
    public void setSelectedRecordType(String RType) { SelectedRecordType = RType;  }

    public Boolean getShowValidData(){ return ShowValidData; } 
    public void setShowValidData(Boolean svd) {ShowValidData=svd; }


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


    //======================================= Constructor =============================================//
    public WORD_CreateWOFromCase(){  //Changed from Std Controller to Custom By GM 29Jan10  :: ApexPages.StandardController controller
    
        if (caseId == null)
        {
            ShowValidData = false;
            AddToErrorsList(getTAG008());       //Source Object Case Id not found
        }
    
        ValidateAllSettings();   
        DisplayErrorsNWarnings();

               String souObjFieldNames;
        String SOQLHeader;

        try{
            fieldMapSetting = settings.SVMX_getFieldMapping( SettingValue); 
            souObjFieldNames = '';
            for(SVMXC__ServiceMax_Config_Data__c fld:fieldMapSetting)
            {
                if (souObjFieldNames.length() > 0) { souObjFieldNames += ', '; }
                souObjFieldNames += fld.SVMXC__Source_Field_Name__c;
            }
            SOQLHeader = '  SELECT '+souObjFieldNames+' FROM Case where Id=\''+caseId+'\''; 
            souObjRec = Database.query(SOQLHeader);

            //this is Target Obj Rec : WOrderHeader
            //Populate fields and corresponding values using fieldMap 
            WOrderHeader.OwnerId = UserInfo.getUserId();
            WOrderHeader.SVMXC__Order_Type__c = utils.SVMX_getDefaultPicklistValue('SVMXC__Service_Order__c', 'SVMXC__Order_Type__c');
            WOrderHeader.SVMXC__Priority__c = utils.SVMX_getDefaultPicklistValue('SVMXC__Service_Order__c', 'SVMXC__Priority__c');
            WOrderHeader.SVMXC__Billing_Type__c = utils.SVMX_getDefaultPicklistValue('SVMXC__Service_Order__c', 'SVMXC__Billing_Type__c');
                
             for(SVMXC__ServiceMax_Config_Data__c fld:fieldMapSetting)
             {
                 String targetFieldName = fld.SVMXC__Target_Field_Name__c;
                 String sourceFieldName = fld.SVMXC__Source_Field_Name__c;
                 Object souFldVal;

                 if(sourceFieldName != null )
                 souFldVal = souObjRec.get(sourceFieldName);

                 if(souFldVal != null)
                 {
                    WOrderHeader.put(targetFieldName, souFldVal);
                 }
             }
        } catch (Exception e){
                ApexPages.addMessage(new ApexPages.Message ( ApexPages.Severity.ERROR,getTAG007() ,e.getMessage()));
        }
 

        
            //Set Def User:
                  
            //Set Defult Picklist Value
                  

/*  String SOQL  = 'SELECT Id,Name  FROM RecordType where SobjectType  =\''+LineSobjectType+'\' ';        
        try{
            rTypes = Database.query(SOQL);
            //if(rTypes.size() > 0)
            //{
                for ( RecordType r : rTypes)
                        {
                          rTypeNames.add(new SelectOption(r.Name,r.Name));
                          //if(SetngForDefRecType == r.Name) SelectedRecordType = r.Id;
                        }           
            //} 
            
        } catch (Exception e){ ApexPages.addMessage(new ApexPages.Message ( ApexPages.Severity.ERROR,getTAG007() ,e.getMessage()));}
        
*/
    }


     public void ValidateAllSettings(){
     
     if(AllSubModuleSettings.size()==0)
     {
        ShowValidData = false;
        AddToErrorsList(getTag009()); //Settings not available for the SubModule: Create Work Order
     }

     if(SettingValue == null)
     {
        ShowValidData = false;
        AddToErrorsList(getTag009()); //Settings not available for the create work order field mapping 
     }
   
      if(SelectRecTypeWOLVFPage == null)
     {
        ShowValidData = false;
        AddToErrorsList(getTag009()); //Settings not available for Settings not available for WORD_SelectWOLinesRecType VF Page name
     }
         

    }

    //==================================== Retriving Source Object Record =================================//
    public Case souObjRec = new Case() ;
    
    public Case getCaseHeader(){
        try{
            String SOQLDetail = ' SELECT Id, CaseNumber,OwnerId From Case where Id=\''+caseId+'\'';
            CaseHeader= Database.query(SOQLDetail);
        } catch (Exception e){
                ApexPages.addMessage(new ApexPages.Message ( ApexPages.Severity.ERROR,getTAG007() ,e.getMessage()));}

        return CaseHeader;            
    } 


    //============================================ New Work Order record =======================================//

    public SVMXC__Service_Order__c WOrderHeader = new SVMXC__Service_Order__c();
    
    public SVMXC__Service_Order__c getWOHeader() {
        return WOrderHeader;            
    } 
   
    //============ Method used to decide whether to show the vf page or to create wo automatically =============//
    
   /* public PageReference createwo() {
        if(rTypes.size() > 1)
            return null;
        else
            {
               PageReference pr = newTargetObj();
                return pr;
            }
    }*/

    
    //============================ Method executes on click on Create Work Order Button ========================//
    
    public PageReference newTargetObj() {
/* By GM : Moved this to Constructor
        String souObjFieldNames;
        String SOQLHeader;


            fieldMapSetting = settings.SVMX_getFieldMapping( SettingValue); 

            //Schema.DescribeSObjectResult souObj = Case.sObjectType.getDescribe();
            //Map<String, SObjectField> souObjfieldMap = Schema.SObjectType.Case.fields.getMap();
            //build a list of all fieldnames for the object
            //List<String> souObjFieldList = utils.SVMX_getFieldList(souObjfieldMap,true); 
            //souObjFieldNames = utils.SVMX_getFieldNamesFromList(souObjFieldList);
  
            souObjFieldNames = '';
            for(SVMXC__ServiceMax_Config_Data__c fld:fieldMapSetting)
            {
                if (souObjFieldNames.length() > 0) { souObjFieldNames += ', '; }
                if (fld.SVMXC__Source_Field_Name__c != null) souObjFieldNames += fld.SVMXC__Source_Field_Name__c;
            }
            SOQLHeader = '  SELECT '+souObjFieldNames+' FROM Case where Id=\''+caseId+'\''; 
            souObjRec = Database.query(SOQLHeader);

            //this is Target Obj Rec : WOrderHeader
            //Populate fields and corresponding values using fieldMap 
                
             for(SVMXC__ServiceMax_Config_Data__c fld:fieldMapSetting)
             {
                 String targetFieldName = fld.SVMXC__Target_Field_Name__c;
                 String sourceFieldName = fld.SVMXC__Source_Field_Name__c;
                 Object souFldVal;

                 if(sourceFieldName != null )
                 souFldVal = souObjRec.get(sourceFieldName);

                 if(souFldVal != null)
                 {
                    WOrderHeader.put(targetFieldName, souFldVal);
                 }
             }
*/

        try{
            if( SelectedRecordType != null)
            {
                 WOrderHeader.put('RecordTypeId',SelectedRecordType);
            }
                    
        //insert WOrderHeader;
        if( COMM_SecurityUtils.getInstance().verifyFieldAccess( WOrderHeader, COMM_SecurityUtils.Access.Createable ) ) {
        //SDL-SVM-CREATE-UPDATE-FLS-ENFORCED
            insert WOrderHeader;
        } else {
            btnisdisabled = false;
            ApexPages.addMessage(new ApexPages.Message ( ApexPages.Severity.ERROR, System.Label.COMM001_TAG142 ) );
            return null;
        }
        } catch (Exception e){
            btnisdisabled = false;
                ApexPages.addMessage(new ApexPages.Message ( ApexPages.Severity.ERROR,getTAG007() ,e.getMessage()));
        return null;
        }

            if(IsHeaderOnly.toUpperCase()=='FALSE'){
            PageReference WOPage = new PageReference('/'+WOrderHeader.Id);
            WOPage.setRedirect(true);
            return WOPage;
            }
            else{
            PageReference newWOPage = new PageReference('/apex/'+SelectRecTypeWOLVFPage+'?Id='+WOrderHeader.Id);
            newWOPage.setRedirect(true);
            return newWOPage;
            }
    }

    //======================== Method for Work Order Record Type Picklist ==========================//
     public List<SelectOption> getObjectRecordTypes(){
        
        String SOQL  = 'SELECT Id,Name  FROM RecordType where SobjectType  =\''+LineSobjectType+'\' ';        
        try{
        //SDL-SVMX-FLS-NOT-ENFORCED-META-DATA
                rTypes = Database.query(SOQL);
                for ( RecordType r : rTypes)
                {
                    rTypeNames.add(new SelectOption(r.Id,r.Name));
                }
            } catch (Exception e){ ApexPages.addMessage(new ApexPages.Message ( ApexPages.Severity.ERROR,getTAG007() ,e.getMessage()));}

        return rTypeNames;
    }

     //============================== Method executes on click of Cancel Button =============================// 
     public PageReference Cancel() {
        PageReference scPage = new PageReference('/' + caseId);
        scPage.setRedirect(true);
        return scPage;   
     }

public Integer getRecTypSize(){
        return rTypeNames.size();
}
    //============================================= Translation  ===========================================// 
    // Call a Method in UTIL class to return Tags, Send SubModule ID for getting TAGS
       // public Map<String, String> svmxTagList = commUtil.SVMX_getTagList('WORD004'); 

    // Ddefine getter method for each tag you have in VF page
        public String getTAG001(){ return System.Label.WORD004_TAG001;} //Create WorkOrder
        public String getTAG002(){ return System.Label.WORD004_TAG002;} //Create Work Order From Case:
        public String getTAG003(){ return System.Label.WORD004_TAG003;} //Create Work Order Help
        public String getTAG004(){ return System.Label.WORD004_TAG004;} //Select Work Order Record Type
        public String getTAG005(){ return System.Label.WORD004_TAG005;} //Create Work Order (button)
        public String getTAG006(){ return System.Label.WORD004_TAG006;} //Cancel
        public String getTAG007(){ return System.Label.WORD004_TAG007;}  //Error in Create Work Order
        public String getTAG008(){ return System.Label.WORD004_TAG008;} //Source Object Case Id not found
        public String getTAG009(){ return System.Label.WORD004_TAG009;} //Settings not available for the SubModule: Create Work Order
        public String getTAG010(){ return System.Label.WORD004_TAG010;} //Settings not available for the SubModule: Create Work Order
        public String getHLPURL(){ return System.Label.WORD004_HLPURL;}
}