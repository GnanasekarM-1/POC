/* Security Scanned */
public  with sharing class IPRD_CreateChildIB{
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

   

    //========================================== URL Parameters ==============================================//
    String parentIBId = System.currentPageReference().getParameters().get('parentid'); 


    //========================================== Global Declarations =========================================//
    Boolean InfoMessage=true;
    String SelectedRecordType;
    String LineSobjectType = 'SVMXC__Installed_Product__c';
    SVMXC__Installed_Product__c ibrecord = new SVMXC__Installed_Product__c();
    Boolean ShowValidData = true;
    Boolean ValidRecords = true;
   

    //=========== Global Variables (with get & set methods) to manage display of Warnings and Errors =========//
    List<String> ErrorMessages = new  List<String> ();
   
    public void AddToErrorsList(String msg) { ErrorMessages.add(msg); }
    public List<String> getErrorsList() {    return ErrorMessages; }  

    public Boolean DisplayBlockLevelMessage = false;
    public Boolean getDisplayBlockLevelMessage(){ return DisplayBlockLevelMessage; }
    public Boolean btnisdisabled = false;
    public Boolean getbtnisdisabled(){return btnisdisabled;}  


    //=============================== Object to retrive Settings & Translation =============================//
    SVMXC.COMM_Utils utils = new SVMXC.COMM_Utils();
    SVMXC.COMM_Utils_ManageSettings settings = new SVMXC.COMM_Utils_ManageSettings();

    //Create instance of UTIL Class
    //SVMXC.COMM_Utils_ManageTags commUtil = new SVMXC.COMM_Utils_ManageTags();


    //===================================== List to store new lines =======================================//
    public List<SVMXC__ServiceMax_Config_Data__c> fieldMapSetting = new List<SVMXC__ServiceMax_Config_Data__c> ();

  
    //======================================== Setting Definition =========================================//
    Map<String, String> AllSubModuleSettings = settings.SVMX_getSettingList('IPRD001'); // Create child IB  
    String SettingValue = AllSubModuleSettings.get('SET001'); //Mapid for create child ib
    // String SetngForReqProd = AllSubModuleSettings.get('SET002'); //setting for Product to be mandatory
    String SetngForReqSN = AllSubModuleSettings.get('SET003'); //setting for Serial Number to be mandatory
    String populateIBasTL = AllSubModuleSettings.get('SET004'); //Setting to Populate IB as TL if TL is Null?: By GM 16Jan10
   
   
    //======================================= Getter & Setter =============================================//
    public Boolean getInfoMessage(){ return InfoMessage; } 
    public void setInfoMessage(Boolean icps) {InfoMessage=icps; }
    
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
                    ApexPages.AddMessage(new ApexPages.Message(ApexPages.Severity.Error,getTAG013(),msg)) ;  
                    }
            }   
   
    }


    //============================================== Constructor ===========================================//
    public IPRD_CreateChildIB(ApexPages.StandardController controller){

        if (parentIBId == null)
        {
            ShowValidData = false;
            AddToErrorsList(getTAG014());       //Source Object Parent Id not found
        }
        
        ValidateAllSettings();   
        DisplayErrorsNWarnings();
    }


    public void ValidateAllSettings(){
         
         if(AllSubModuleSettings.size()==0 || AllSubModuleSettings == null)
         {
            ShowValidData = false;
            AddToErrorsList(getTag015()); //Settings not available for the SubModule: Create Child IB //TAG015
            
         }
        
         if(SettingValue == null)
         {
            ShowValidData = false;
            AddToErrorsList(getTag015()); //Settings not available for the Installed Product field mapping
            
         }
       
         //if(SetngForReqProd == null)
         //{
            //ShowValidData = false;
            //AddToErrorsList(getTag015()); //Settings not available for Product to be mandatory
         //}

         if(SetngForReqSN == null)
         {
            ShowValidData = false;
            AddToErrorsList(getTag015()); //Settings not available for Serial Number to be mandatory
         }
         
    }

    //==================================== Retriving Source Object Record =================================//
    public SVMXC__Installed_Product__c souObjRec = new SVMXC__Installed_Product__c() ;

    public SVMXC__Installed_Product__c getIBFields() {

        String SOQLDetail = ' SELECT Id, Name, SVMXC__Product__c, SVMXC__Product__r.Name, Serial_Lot_Number__c  From SVMXC__Installed_Product__c where Id=:parentIBId';//\''+parentIBId+'\'(commented by amar on 18/2/10 3:30 pm becasue of Security Review)

        ibrecord = Database.query(SOQLDetail); 
        return ibrecord;   
    }


    //============================================== New Child IB record ==================================//
    SVMXC__Installed_Product__c IProdHeader = new SVMXC__Installed_Product__c();

    public SVMXC__Installed_Product__c getIBHeader() {
    return IProdHeader;            
    } 

    //public void setIBHeader(SVMXC__Installed_Product__c ibrec) { IProdHeader = ibrec;}
    
    //============================================== Validation ===========================================//
    public Boolean isValidData(){

        ValidRecords = true;
        
        if(IProdHeader.SVMXC__Product__c == ibrecord.SVMXC__Product__c)
        {
            if(IProdHeader.SVMXC__Product__c != null)
            {
                //ApexPages.AddMessage(new ApexPages.Message(ApexPages.Severity.Error,'Child Product cannot be same as Parent Product')) ;
                IProdHeader.SVMXC__Product__c.addError(System.Label.IPRD001_TAG008);
                ValidRecords = false;
            }
        }

        //if(SetngForReqProd.toUpperCase() == 'TRUE')
        //{
            if(IProdHeader.SVMXC__Product__c == null)       // Product is always required
            {
                if((System.Label.IPRD001_TAG011!=null)&&(System.Label.IPRD001_TAG011!=''))
                {
                IProdHeader.SVMXC__Product__c.addError(System.Label.IPRD001_TAG011);
                ValidRecords = false;
                }
            }
        //}

        if(SetngForReqSN.toUpperCase() == 'TRUE')
        {
            if(IProdHeader.SVMXC__Serial_Lot_Number__c == null)
            {
                if((System.Label.IPRD001_TAG012)!=null &&(System.Label.IPRD001_TAG012!=''))
                {
                IProdHeader.SVMXC__Serial_Lot_Number__c.addError(System.Label.IPRD001_TAG012);
                ValidRecords = false;
                }
            }
        }   

        return ValidRecords;

    }
    
    //============================ Method executes on click on Create Child Button ==========================//
    public PageReference newTargetObj() {


        String souObjFieldNames;
        String SOQLHeader;
        String SLN; // = IProdHeader.Serial_Lot_Number__c;
        Id Prod;

        if(IProdHeader.SVMXC__Product__c == null)
        {prod = null;}
        else
        {Prod = IProdHeader.SVMXC__Product__c;}

        if(IProdHeader.Serial_Lot_Number__c == null)
        {SLN = null;}
        else
        {SLN = IProdHeader.Serial_Lot_Number__c;}
        if(isValidData())
    {
            try{

                fieldMapSetting = settings.SVMX_getFieldMapping( SettingValue); 

                //Schema.DescribeSObjectResult souObj = SVMXC__Installed_Product__c.sObjectType.getDescribe();
                //Map<String, SObjectField> souObjfieldMap = Schema.SObjectType.SVMXC__Installed_Product__c.fields.getMap();
                //build a list of all fieldnames for the object
                //List<String> souObjFieldList = utils.SVMX_getFieldList(souObjfieldMap,true); 
                //souObjFieldNames = utils.SVMX_getFieldNamesFromList(souObjFieldList);

                //souObjFieldNames +=' , SVMXC__Product__r.Name'; 

                 souObjFieldNames = '';
                 for(SVMXC__ServiceMax_Config_Data__c fld:fieldMapSetting)
                 {
                     if (souObjFieldNames.length() > 0) { souObjFieldNames += ', '; }
                     if(fld.SVMXC__Source_Field_Name__c != null) souObjFieldNames += fld.SVMXC__Source_Field_Name__c;
                 }

                SOQLHeader = '  SELECT '+souObjFieldNames+' FROM SVMXC__Installed_Product__c where Id =:parentIBId'; //\''+parentIBId+'\'(commented by amar on 18/2/10 3:30 pm becasue of Security Review)
                souObjRec = Database.query(SOQLHeader);

                //this is Target Obj Rec : IProdHeader
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
                          IProdHeader.put(targetFieldName, souFldVal);
                     }
                 }
                    
        if(SelectedRecordType != System.Label.IPRD001_TAG010)
        {
             IProdHeader.put('RecordTypeId',SelectedRecordType);
        }

        IProdHeader.SVMXC__Parent__c = parentIBId;                      
        if (SLN != null)
            IProdHeader.Name = SLN;
        else            // If serial number was not provided, set Name field to Product Name
            {
            Product2 p2 = [SELECT Name From Product2 WHERE Id = :Prod];
            IProdHeader.Name = p2.Name;
            }
        IProdHeader.Serial_Lot_Number__c = SLN; 
        IProdHeader.SVMXC__Product__c = Prod; //IProdHeader.SVMXC__Product__c;

        if(populateIBasTL.toUpperCase() == 'TRUE' && IProdHeader.SVMXC__Top_Level__c == null)IProdHeader.SVMXC__Top_Level__c = parentIBId; //By GM 16jan10
        //insert IProdHeader;
        if( COMM_SecurityUtils.getInstance().verifyFieldAccess( IProdHeader, COMM_SecurityUtils.Access.Createable ) ) {
            //SDL-SVM-CREATE-UPDATE-FLS-ENFORCED
            insert IProdHeader;
        } else {
            ApexPages.addMessage(new ApexPages.Message ( ApexPages.Severity.ERROR, System.Label.COMM001_TAG142 ) );
            return null;
        }
    }
    catch (Exception e)
        {
                ApexPages.addMessage(new ApexPages.Message ( ApexPages.Severity.ERROR,getTAG013() ,e.getMessage()));
            return null;
        }         
            
            PageReference newChildPage = new PageReference('/' + IProdHeader.Id + '');
            return newChildPage;
        }  
            
        return null;
    }


    //======================== Method for Installed Product Record Type Picklist ==========================//
    List<RecordType> rTypes = new List<RecordType> ();
    List<SelectOption> rTypeNames = new List<SelectOption>();
    public List<SelectOption> getObjectRecordTypes(){
          
        String SOQL  = 'SELECT Id,Name  FROM RecordType where SobjectType  =\''+LineSobjectType+'\' ';        
        try{
            //SDL-SVMX-FLS-NOT-ENFORCED-META-DATA
                rTypes = Database.query(SOQL);  
                rTypeNames.clear();//By GM on 16Jan10, clear the list of Rts
                if (rTypes.size()==0)
                    {
                        rTypeNames.add(new SelectOption(System.Label.IPRD001_TAG010,System.Label.IPRD001_TAG010));
                    }

                for (RecordType r : rTypes)
                {
                    rTypeNames.add(new SelectOption(r.Id,r.Name)); //Swaped Name and ID by GM 31May10
                }           
            
           } catch (Exception e){
                ApexPages.addMessage(new ApexPages.Message ( ApexPages.Severity.ERROR,getTAG013() ,e.getMessage()));
                return null;

           }   
        return rTypeNames;
    }


    //============================== Method executes on click of Cancel Button ==============================//
    public PageReference Cancel1() {       
        
        PageReference scPage = new PageReference('/' + ibrecord.id);            
        scPage.setRedirect(true);            
        return scPage;   
    }

 
    //=========================================== Translation ===============================================//
    // Call a Method in UTIL class to return Tags, Send SubModule ID for getting TAGS
    //public  Map<String, String> svmxTagList = commUtil.SVMX_getTagList('IPRD001');

    // Ddefine getter method for each tag you have in VF page
    public String getTAG001(){ return System.Label.IPRD001_TAG001;} //Create Child Installed Product
    public String getTAG002(){ return System.Label.IPRD001_TAG002;} //Create Child For:
    public String getTAG003(){ return System.Label.IPRD001_TAG003;} //Create Child Installed Product Help
    public String getTAG004(){ return System.Label.IPRD001_TAG004;} //Create Child
    public String getTAG005(){ return System.Label.IPRD001_TAG005;} //Cancel
    public String getTAG006(){ return System.Label.IPRD001_TAG006;} //Instructions
    public String getTAG007(){ return System.Label.IPRD001_TAG007;} //for creating child Installed Product
    public String getTAG008(){ return System.Label.IPRD001_TAG008;} //Child Product cannot be same as Parent Product
    public String getTAG009(){ return System.Label.IPRD001_TAG009;} //Child Record Type
    public String getTAG010(){ return System.Label.IPRD001_TAG010;} //Default
    public String getTAG011(){ return System.Label.IPRD001_TAG011;} //You must enter a Product
    public String getTAG012(){ return System.Label.IPRD001_TAG012;} //You must enter a Serial Number
    public String getTAG013(){ return System.Label.IPRD001_TAG013;} //Error in Create Child Installed Product
    public String getTAG014(){ return System.Label.IPRD001_TAG014;} //Source Object Parent Id not found
    public String getTAG015(){ return System.Label.IPRD001_TAG015;} //Settings not available for the SubModule: Create Child IB
    public String getHLPURL() {return System.Label.IPRD001_HLPURL;}
   /*
    public String getHLPURL()
    { 
        String hlpurl = svmxTagList.get('HLPURL');
        return hlpurl +'WORD002';
    } 
   */ 
}