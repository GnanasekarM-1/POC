/* Security Scanned */
public  with sharing class SCON_Renewal
{
     //-------------------NPS Related...
    public string getUserLocaleKey(){
        return UserInfo.getLanguage();
    }
    public string getUserID(){
        return UserInfo.getUserId().substring(0, 15);
    }
    public string getUserOrgID(){
        return UserInfo.getOrganizationId().substring(0, 15);
    }
    //---------------------------------
    String sId = System.currentPageReference().getParameters().get('id');

//============================================================================================================
    // Global Variable/Instanc creation by using Custom Object
//============================================================================================================
    COMM_Utils utils = new COMM_Utils();
    
    COMM_Utils_ManageTags commUtil = new COMM_Utils_ManageTags();
    SVMXC.COMM_Utils_ManageSettings msettUitl = new SVMXC.COMM_Utils_ManageSettings();

    SVMXC__Service_Contract__c  SContHeader = new SVMXC__Service_Contract__c();
    
    SVMXC__Service_Contract__c  NewSContHeader = new SVMXC__Service_Contract__c();
    public SVMXC__Service_Contract__c getNewSContHeader(){ return NewSContHeader;   }
    public void  setNewSContHeader( SVMXC__Service_Contract__c val){ NewSContHeader = val;}     
    
    public SVMXC__Service_Contract__c souObjRec = new SVMXC__Service_Contract__c() ;
    //public SVMXC__Service_Contract_Products__c SConProducts = new SVMXC__Service_Contract_Products__c();
    
    Map<String, String> AllSubModuleSettings = msettUitl.SVMX_getSettingList('SCON002');
    
    public List<SVMXC__ServiceMax_Config_Data__c> fieldMapSetting = new List<SVMXC__ServiceMax_Config_Data__c> ();
    
    public List<SVMXC__ServiceMax_Config_Data__c> fieldMapSetting3= new List<SVMXC__ServiceMax_Config_Data__c> ();
    public List<SVMXC__ServiceMax_Config_Data__c> fieldMapSetting4= new List<SVMXC__ServiceMax_Config_Data__c> ();
    public List<SVMXC__ServiceMax_Config_Data__c> fieldMapSetting5= new List<SVMXC__ServiceMax_Config_Data__c> ();
    public List<SVMXC__ServiceMax_Config_Data__c> fieldMapSetting6= new List<SVMXC__ServiceMax_Config_Data__c> ();
    
    //public List<SVMXC__Service_Contract_Products__c> chldProductHeader    =  new List<SVMXC__Service_Contract_Products__c>();
    public List<SVMXC__Service_Contract_Products__c> ExistingSCONTChildObjProd= new List<SVMXC__Service_Contract_Products__c> (); 
    
    //public List<SVMXC__Service_Contract_Products__c> chldProductHeader    =  new List<SVMXC__Service_Contract_Products__c>();
    List<SVMXC__Service_Contract_Sites__c> ExistingSCONTChildObjSites= new List<SVMXC__Service_Contract_Sites__c> (); 
    
    //public List<SVMXC__Service_Contract_Products__c> chldProductHeader    =  new List<SVMXC__Service_Contract_Products__c>();
    List<SVMXC__Service_Contract_Services__c> ExistingSCONTChildObjSvr= new List<SVMXC__Service_Contract_Services__c> (); 
    
    //public List<SVMXC__Service_Contract_Products__c> chldProductHeader    =  new List<SVMXC__Service_Contract_Products__c>();
    List<SVMXC__Service_Contract_Contacts__c> ExistingSCONTChildObjCont= new List<SVMXC__Service_Contract_Contacts__c> (); 

    List<SVMXC__Service_Contract__c> TempSCONTDetailArray = new List<SVMXC__Service_Contract__c> ();
    
    
    public Boolean IstoDisplay=true; // Flag to be used for Message
    public Boolean getIstoDisplay(){ return IstoDisplay;     }     
    public void setIstoDisplay(Boolean val) {IstoDisplay=val;     } 
    
    public Boolean DisplayContinue =false; // Flag to be used for Message
    public Boolean getDisplayContinue(){ return DisplayContinue;     }     
    public void setDisplayContinue(Boolean val) {DisplayContinue=val;     }
    
        
    SVMXC__Service_Contract_Sites__c SConSites = new SVMXC__Service_Contract_Sites__c();
    
    List<SVMXC__Service_Contract__c> TempSContArray = new List<SVMXC__Service_Contract__c> ();
    
    public SVMXC__ServiceMax_List__c SMaxList = new  SVMXC__ServiceMax_List__c();
    
    //Variables to store FieldNames for various Objects
    String smaxlfieldNames;
    String covrprodfieldNames;
    String covrsvrfieldNames;
    String covrstfieldNames;
    String covrcontfieldNames;
    String souObjFieldNames;
    String fieldNames;
    String SOQLHeader;
    String souObjFieldNames1;
    Boolean ValidRecords = true;
   
    
    public SVMXC__ServiceMax_List__c getSMaxList()  {       return SMaxList;    }   
    public void setSMaxList(SVMXC__ServiceMax_List__c aur)  {       SMaxList = aur; }
    
    
     
//===============================================================================================================
    //Variable  delartion  and get, set methods to check Service Contract status w
//===============================================================================================================             

    public Boolean showDetailBlock=true;
    public Boolean IsActivatedContract=true;//false; // Flag to be used for Message
    public Boolean getIsActivatedContract(){ return IsActivatedContract;     }     
    public void setIsActivatedContract(Boolean val) {IsActivatedContract=val;     }
    public Boolean AllowNullEntitleHistory=true; 
    
//===============================================================================================================
    //Message Tag list with Sub Module Id
    // Call a Method in UTIL class to return Tags
//===============================================================================================================   

    //public Map<String, String> svmxTagList = commUtil.SVMX_getTagList('SCON002');
    
//===============================================================================================================
    // To get Settings:
    // Call a Method in UTIL class to return Settings, Send SubModule ID for getting Settings
//===============================================================================================================

    public Map<String, String> svmxSettingList = msettUitl.SVMX_getSettingList('SCON002');
        
//============================================================================================================
    //TAG Methods for Transaction message
//============================================================================================================
                            
    public String getTAG001() {return system.label.SCON002_TAG001;}
    public String getTAG002() {return system.label.SCON002_TAG002;} 
    public String getTAG003() {return system.label.SCON002_TAG003;} 
    public String getTAG004() {return system.label.SCON002_TAG004;} 
    public String getTAG005() {return system.label.SCON002_TAG005;}
    public String getTAG006() {return system.label.SCON002_TAG006;} 
    public String getTAG007() {return system.label.SCON002_TAG007;} 
    public String getTAG008() {return system.label.SCON002_TAG008;} 
    public String getTAG009() {return system.label.SCON002_TAG009;} 
    public String getTAG010() {return system.label.SCON002_TAG010;}
    public String getTAG011() {return system.label.SCON002_TAG011;} 
    public String getTAG012() {return system.label.SCON002_TAG012;}
    public String getTAG013() {return system.label.SCON002_TAG013;} 
    public String getTAG014() {return system.label.SCON002_TAG014;} 
    public String getTAG015() {return system.label.SCON002_TAG015;} 
    public String getTAG017() {return system.label.SCON002_TAG017;} 
    public String getTAG018() {return system.label.SCON002_TAG018;} 
      
    public String getHLPURL() {return system.label.SCON002_HLPURL;}


    List<String> ErrorMessages = new  List<String> ();
    public void AddToErrorsList(String msg) { ErrorMessages.add(msg); }
    public List<String> getErrorsList() {    return ErrorMessages; }  
    
/*******************************************************************************************************************
    Method to Display Errors 
*******************************************************************************************************************/
    public void DisplayErrors()
    {
  //  System.Debug('ErrorMessages: ' + ErrorMessages.size());

        if( ErrorMessages.size()>0)
        {
            ValidRecords = false;  
            for (String msg : ErrorMessages)
            {
                ApexPages.AddMessage(new ApexPages.Message(ApexPages.Severity.Error,msg,'')) ;  
            }
        }   
            
    }    
/*******************************************************************************************************************
    Method to validate the availability of all the required Setting Values
*******************************************************************************************************************/
    public void ValidateAllSettings()
    {     
        if (AllSubModuleSettings.size()==0) 
        AddToErrorsList(getTAG018()); //Settings not available for the SubModule: Service Contract Renewal 
        else
        {    
//SET001    
            //Newly introduced setting to deal with defect no. 1522
            //Boolean AllChkBoxesTrue = AllSubModuleSettings.get('SET007');
            //if (AllChkBoxesTrue ==null)
            //  AddToErrorsList(getTAG018()); //Setting not available for : Setting for Service Contract Header field mapping 

            String SettingValue = AllSubModuleSettings.get('SET001'); 
            if (SettingValue ==null)    
            AddToErrorsList(getTAG018()); //Setting not available for : Setting for Service Contract Header field mapping 
//SET003            
            String SettingValue3 =AllSubModuleSettings.get('SET003'); 
            if (SettingValue3 ==null)   
                AddToErrorsList(getTAG018()); //Setting not available for : Setting for Service Contract Product field mapping 
//SET004     
            String SettingValue4 =AllSubModuleSettings.get('SET004');   
            if (SettingValue4 ==null) 
            AddToErrorsList(getTAG018()); //Setting not available for : Setting for Service Contract Service field mapping

//SET005        
            String SettingValue5 = AllSubModuleSettings.get('SET005');  
            if (SettingValue5 ==null)  
            AddToErrorsList(getTAG018()); //Setting not available for :Setting for Service Contract Location field mapping
//SET006            
            String SettingValue6 = AllSubModuleSettings.get('SET006');  
            if (SettingValue6 ==null) 
            AddToErrorsList(getTAG018()); //Setting not available for :Setting for Service Contract Contact field mapping
        }
    } 

//===============================================================================================================
    //Constructor
//===============================================================================================================
    
    public SCON_Renewal(ApexPages.StandardController controller)
    {
        DisplayErrors();
        if(ValidRecords==true)
        {
            DescripeObjandfields();
            //SContHeader = getSContractHeader();
              try
                {
                    SOQLHeader = '  SELECT '+fieldNames+' FROM SVMXC__Service_Contract__c where Id =:sId '; //\''+sId+'\'(commented by amar on 18/2/10 3:15 pm becasue of Security Review)
                    
                    SContHeader= Database.query(SOQLHeader);
                    SContHeader.Start_Date__c=null;
                    SContHeader.End_Date__c=null;
                } catch (Exception e){        
                        ApexPages.addMessage(new ApexPages.Message ( ApexPages.Severity.ERROR,e.getMessage(),''));
                    ////    return null;
            }
            NewSContHeader.Name = SContHeader.Name;
        
            //Newly introduced setting to deal with defect no. 1522
            Boolean AllChkBoxesTrue = false;//AllSubModuleSettings.get('SET007');
            if(AllChkBoxesTrue)
            {
                SMaxList.SVMXC__Copy_Covered_Products__c = true;
                SMaxList.SVMXC__Copy_Included_Services__c = true;
                SMaxList.SVMXC__Copy_Covered_Locations__c = true;
                SMaxList.SVMXC__Copy_Entitled_Contacts__c = true;
                SMaxList.SVMXC__Activate_Contract_Upon_Renewal__c = true;   
            }
            

        SCONTHeaderFieldMapp();
            ExistingSCONTChildObjProd = getContractProducts();
            ExistingSCONTChildObjSites = getContractSites();
            ExistingSCONTChildObjSvr = getContractServices();
            ExistingSCONTChildObjCont = getContractContacts(); 
            //NewSContHeader.End_Date__c=null;
            NewSContHeader.Renewal_Notes__c=null;
            if(NewSContHeader.Start_Date__c == null)
                NewSContHeader.Start_Date__c=System.today();
            NewSContHeader.SVMXC__Renewed_From__c = SContHeader.Id;
            DisplayContinue=false;
        SContVerify();
        }
        else
        {
            showDetailBlock =true;
        }
    }

    //SCON Verify method
    public void SContVerify()
    {
        Integer RenewCnt = [SELECT Count() FROM SVMXC__Service_Contract__c WHERE SVMXC__Renewed_From__c = :SContHeader.Id];
        System.Debug('This contract ' + SContHeader.Id + ' has been renewed : ' + RenewCnt + ' times.');
        if(RenewCnt > 0)
            {
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.error,getTAG011(),''));
            showDetailBlock=false;
            IstoDisplay=false;
            DisplayContinue=false;
            }
    }

    //Descrip fields and fieldvalues  method
    public void DescripeObjandfields()
    {       
            //for SMaxList Header
            //Schema.DescribeSObjectResult dsoResult1 = SVMXC__ServiceMax_List__c.sObjectType.getDescribe();
            //Map<String, SObjectField> smaxfieldMap = Schema.SObjectType.SVMXC__ServiceMax_List__c.fields.getMap();

            //build a list of all fieldnames for the object
            //List<String> smaxlfieldList = utils.SVMX_getFieldList(smaxfieldMap,true);      
            //smaxlfieldNames = utils.SVMX_getFieldNamesFromList(smaxlfieldList);
            
            //for SconCoveredProducts
            //Schema.DescribeSObjectResult dsoResult2 = SVMXC__Service_Contract_Products__c.sObjectType.getDescribe();
            //Map<String, SObjectField> covprodfieldMap = Schema.SObjectType.SVMXC__Service_Contract_Products__c.fields.getMap();
            
            //List<String> covrpfieldList = utils.SVMX_getFieldList(covprodfieldMap,true);      
            //covrprodfieldNames = utils.SVMX_getFieldNamesFromList(covrpfieldList);
            
            //for SconCovered Services
            //Schema.DescribeSObjectResult dsoResult3 = SVMXC__Service_Contract_Sites__c.sObjectType.getDescribe();
            //Map<String, SObjectField> covsvrfieldMap = Schema.SObjectType.SVMXC__Service_Contract_Sites__c.fields.getMap();
            
            //List<String> covrsrfieldList = utils.SVMX_getFieldList(covsvrfieldMap,true);      
            //covrsvrfieldNames = utils.SVMX_getFieldNamesFromList(covrsrfieldList);
            
            //for SconCovered Sites
            //Schema.DescribeSObjectResult dsoResult4 = SVMXC__Service_Contract_Services__c.sObjectType.getDescribe();
            //Map<String, SObjectField> covrsitesfieldMap = Schema.SObjectType.SVMXC__Service_Contract_Services__c.fields.getMap();
            
            //List<String> covrstfieldList = utils.SVMX_getFieldList(covrsitesfieldMap,true);      
            //covrstfieldNames = utils.SVMX_getFieldNamesFromList(covrstfieldList);
            
            //for SconCovered Contacts
            //Schema.DescribeSObjectResult dsoResult5 = SVMXC__Service_Contract_Contacts__c.sObjectType.getDescribe();
            //Map<String, SObjectField> covrcontfieldMap = Schema.SObjectType.SVMXC__Service_Contract_Contacts__c.fields.getMap();
            
            //List<String> covrconfieldList = utils.SVMX_getFieldList(covrcontfieldMap,true);      
            //covrcontfieldNames = utils.SVMX_getFieldNamesFromList(covrconfieldList);
            
            //Schema.DescribeSObjectResult souObj = SVMXC__Service_Contract__c.sObjectType.getDescribe();
            //Map<String, SObjectField> souObjfieldMap =Schema.SObjectType.SVMXC__Service_Contract__c.fields.getMap();
    
            //build a list of all fieldnames for the object
            //List<String> souObjFieldList = utils.SVMX_getFieldList(souObjfieldMap,true); 
            //souObjFieldNames = utils.SVMX_getFieldNamesFromList(souObjFieldList);
          
            // for SContract Header
            Schema.DescribeSObjectResult dsoResult = SVMXC__Service_Contract__c.sObjectType.getDescribe();
            Map<String, SObjectField> fieldMap = Schema.SObjectType.SVMXC__Service_Contract__c.fields.getMap();

            //build a list of all fieldnames for the object
            List<String> fieldList = utils.SVMX_getFieldList(fieldMap,true);      
            fieldNames = utils.SVMX_getFieldNamesFromList(fieldList);
    }
//===============================================================================================================
    //Descrtion Method for SVMX_Setting Description field with getter and setter
//===============================================================================================================    
    
    Boolean showUpsellMessage=true;
    public Boolean getshowUpsellMessage()
    { 
        return showUpsellMessage; 
    } 
    
    public void setshowUpsellMessage(Boolean icps) 
    {
        showUpsellMessage=icps; 
    } 

//===============================================================================================================
    //Method to render/re-render the page block based on default values, getter and setter
//===============================================================================================================
    public Boolean getshowDetailBlock()
    {       
        return showDetailBlock; 
    }
     
    public void setshowDetailBlock(Boolean val) 
    {
        showDetailBlock=val; 
    } 
        
        
//===============================================================================================================
    //Method to get Contract Header
//===============================================================================================================
   
    public SVMXC__Service_Contract__c getSContractHeader() 
    {
      
            return SContHeader;            
    }

    //SVMX list Header
    public SVMXC__ServiceMax_List__c getSMaxListHeader() 
    {
        try
        {
            String fieldNames;
            String SOQLHeader;
                              
            //SOQLHeader = '  SELECT '+smaxlfieldNames+' FROM SVMXC__ServiceMax_List__c where Id=\''+sId+'\''; 
            //SMaxList= Database.query(SOQLHeader);
            
        } catch (Exception e){
            ApexPages.addMessage(new ApexPages.Message ( ApexPages.Severity.ERROR,e.getMessage(),''));
            return null;

            }
            return SMaxList;            
    }
    
    
//===============================================================================================================
    //Method to get info about Product coverage of Activation of Contract
//===============================================================================================================
    
     public List<SVMXC__Service_Contract_Products__c> getContractProducts() 
     {
        List<SVMXC__Service_Contract_Products__c> SConProducts = new List<SVMXC__Service_Contract_Products__c>();
        try
        {
            String fieldNames;
            String SOQLHeader;
            
            SOQLHeader = '  SELECT '+covrprodfieldNames+' FROM SVMXC__Service_Contract_Products__c where SVMXC__Service_Contract__c =:sId';//\''+sId+'\'(commented by amar on 18/2/10 3:15 pm becasue of Security Review)
            
            SConProducts= Database.query(SOQLHeader);
             
        } catch (Exception e){
            ApexPages.addMessage(new ApexPages.Message ( ApexPages.Severity.ERROR,e.getMessage(),''));
            return null;

            }
            return SConProducts;            
    }            
    
//===============================================================================================================
    //Method to get info about Sites coverage of Activation of Contract
//===============================================================================================================    
    
    public List<SVMXC__Service_Contract_Sites__c> getContractSites() 
    {
        List<SVMXC__Service_Contract_Sites__c> SConSites = new List<SVMXC__Service_Contract_Sites__c>();
        try
        {

            String SOQLHeader;
            String fieldNames;
           
            SOQLHeader = '  SELECT '+covrstfieldNames+' FROM SVMXC__Service_Contract_Sites__c where SVMXC__Service_Contract__c =:sId';//\''+sId+'\'(commented by amar on 18/2/10 3:15 pm becasue of Security Review)
            
            SConSites= Database.query(SOQLHeader);
                 
        }catch (Exception e){
            ApexPages.addMessage(new ApexPages.Message ( ApexPages.Severity.ERROR,e.getMessage(),''));
            return null;

            }
            return SConSites;  

    } 
 
//===============================================================================================================
    //Method to get info about Services coverage of Activation of Contract
//===============================================================================================================
     public List<SVMXC__Service_Contract_Services__c> getContractServices() 
     {
        List<SVMXC__Service_Contract_Services__c> SConServices = new List<SVMXC__Service_Contract_Services__c>();
        try
        {
            String SOQLHeader;
            String fieldNames;
            
            SOQLHeader = '  SELECT '+covrsvrfieldNames+' FROM SVMXC__Service_Contract_Services__c where SVMXC__Service_Contract__c =:sId';//\''+sId+'\'(commented by amar on 18/2/10 3:15 pm becasue of Security Review)
            SConServices= Database.query(SOQLHeader);
         
        }catch (Exception e){
            ApexPages.addMessage(new ApexPages.Message ( ApexPages.Severity.ERROR,e.getMessage(),''));
            return null;

            }
            return SConServices;
                                        
    } 
//===============================================================================================================
    //Method to get info about Contacts coverage of Activation of Contract
//===============================================================================================================
         
    public List<SVMXC__Service_Contract_Contacts__c> getContractContacts() 
    {
        List<SVMXC__Service_Contract_Contacts__c> SConContacts = new List<SVMXC__Service_Contract_Contacts__c>();   
        try
        {
            String SOQLHeader;
            String fieldNames;
            
            SOQLHeader = '  SELECT '+covrcontfieldNames+' FROM SVMXC__Service_Contract_Contacts__c where SVMXC__Service_Contract__c =:sId';//\''+sId+'\'(commented by amar on 18/2/10 3:15 pm becasue of Security Review)                
            SConContacts= Database.query(SOQLHeader);
                 
        } catch (Exception e){
                ApexPages.addMessage(new ApexPages.Message ( ApexPages.Severity.ERROR,e.getMessage(),''));
                return null;

                }
                    return SConContacts;       
   } 

//===============================================================================================================
//SCONT Field Mapping;
//===============================================================================================================
    public void SCONTHeaderFieldMapp()
    {
        String SOQLHeader;
    
        try
        {
            String SettingValue =AllSubModuleSettings.get('SET001'); //Setting for SCONT field mapping     
            fieldMapSetting = msettUitl.SVMX_getFieldMapping( SettingValue); 
            system.debug('fieldMapSetting'+fieldMapSetting.size()+fieldMapSetting);
            souObjFieldNames = '';
            for(SVMXC__ServiceMax_Config_Data__c fld:fieldMapSetting)
            {
                if (souObjFieldNames.length() > 0) { souObjFieldNames += ', '; }
                souObjFieldNames += fld.SVMXC__Source_Field_Name__c;
        }

            SOQLHeader = '  SELECT '+souObjFieldNames   +' FROM SVMXC__Service_Contract__c where Id =:sId';//\''+sId+'\'(commented by amar on 18/2/10 3:15 pm becasue of Security Review) 
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
                     NewSContHeader.put(targetFieldName, souFldVal);
                }           
            }   
            
            if (souObjRec.SVMXC__Renewal_Number__c != null) //Increment the renewal number ; Added by GM : Nov11-09
                NewSContHeader.SVMXC__Renewal_Number__c = souObjRec.SVMXC__Renewal_Number__c + 1;             
            else
                NewSContHeader.SVMXC__Renewal_Number__c = 1; //First Renewal
                
        } catch (Exception e)
                {
                    ApexPages.addMessage(new ApexPages.Message ( ApexPages.Severity.ERROR,e.getMessage(),''));
                }
        NewSContHeader.SVMXC__Renewal_Date__c=system.today();

        // HS: 6/15/2009 Moved this block of code here so we have the 
        // field map definitions for all SC child records as well

            // Setting to get map ID for covered products
        String SettingValue3 =AllSubModuleSettings.get('SET003');
        fieldMapSetting3 = msettUitl.SVMX_getFieldMapping(SettingValue3);
    covrprodfieldNames = '';
    for(SVMXC__ServiceMax_Config_Data__c fld:fieldMapSetting3)
    {
        if (covrprodfieldNames.length() > 0) { covrprodfieldNames += ', '; }
        covrprodfieldNames += fld.SVMXC__Source_Field_Name__c;
    }

            // Setting to get map ID for included services
        String SettingValue4 =AllSubModuleSettings.get('SET004');
        fieldMapSetting4 = msettUitl.SVMX_getFieldMapping( SettingValue4); 
    covrsvrfieldNames = '';
    for(SVMXC__ServiceMax_Config_Data__c fld:fieldMapSetting4)
    {
        if (covrsvrfieldNames.length() > 0) { covrsvrfieldNames += ', '; }
        covrsvrfieldNames += fld.SVMXC__Source_Field_Name__c;
    }
        
            // Setting to get map ID for covered locations
        String SettingValue5 =AllSubModuleSettings.get('SET005');
        fieldMapSetting5 = msettUitl.SVMX_getFieldMapping( SettingValue5); 
    covrstfieldNames = '';
    for(SVMXC__ServiceMax_Config_Data__c fld:fieldMapSetting5)
    {
        if (covrstfieldNames.length() > 0) { covrstfieldNames += ', '; }
        covrstfieldNames += fld.SVMXC__Source_Field_Name__c;
    }
        
            // Setting to get map ID for entitled contacts
        String SettingValue6 =AllSubModuleSettings.get('SET006');
        fieldMapSetting6 = msettUitl.SVMX_getFieldMapping(SettingValue6); 
    covrcontfieldNames = '';
    for(SVMXC__ServiceMax_Config_Data__c fld:fieldMapSetting6)
    {
        if (covrcontfieldNames.length() > 0) { covrcontfieldNames += ', '; }
        covrcontfieldNames += fld.SVMXC__Source_Field_Name__c;
    }
    }
    
    public void SCONTChildFieldMapp()
    {
        List<SVMXC__Service_Contract_Products__c> childContractProducts_L = new List<SVMXC__Service_Contract_Products__c>();
        List<SVMXC__Service_Contract_Services__c> childServices_L = new List<SVMXC__Service_Contract_Services__c>();
        List<SVMXC__Service_Contract_Sites__c> childCoveredLoc_L = new List<SVMXC__Service_Contract_Sites__c>();
        List<SVMXC__Service_Contract_Contacts__c> childContractContacts_L = new List<SVMXC__Service_Contract_Contacts__c>();
        if(SMaxList.Copy_Covered_Products__c == true)
        {
            for(SVMXC__Service_Contract_Products__c child : ExistingSCONTChildObjProd)
            {
                SVMXC__Service_Contract_Products__c chldObj = new SVMXC__Service_Contract_Products__c();
                for(SVMXC__ServiceMax_Config_Data__c fld:fieldMapSetting3)
                {
                    String targetFieldName = fld.SVMXC__Target_Field_Name__c;
                    String sourceFieldName = fld.SVMXC__Source_Field_Name__c;
                    Object souFldVal;
                    if(sourceFieldName != null ){
                                    //souFldVal=chldObj.put(targetFieldName, souFldVal);
                                    souFldVal=child.get(sourceFieldName);
                                }
                    if(souFldVal != null)
                                {
                                      chldObj.put(targetFieldName, souFldVal);
                                }  //if
                }  //for 2
         
                chldObj.SVMXC__Service_Contract__c = NewSContHeader.Id;
                childContractProducts_L.add(chldObj);
            }//for1
        }//if
        
        
        if(SMaxList.Copy_Included_Services__c==true)
        {
            for (SVMXC__Service_Contract_Services__c childServices : ExistingSCONTChildObjSvr)
            {
                SVMXC__Service_Contract_Services__c chldObjSV = new SVMXC__Service_Contract_Services__c();
                
                for(SVMXC__ServiceMax_Config_Data__c fld:fieldMapSetting4)
                {
                    String targetFieldName = fld.SVMXC__Target_Field_Name__c;
                    String sourceFieldName = fld.SVMXC__Source_Field_Name__c;
                    Object souFldVal = childServices.get(sourceFieldName);
                                
                        if(souFldVal != null)
                        {
                            chldObjSV.put(targetFieldName, souFldVal);
                        }  //if
                }  //for 2
                
                chldObjSV.SVMXC__Service_Contract__c = NewSContHeader.Id;
                childServices_L.add(chldObjSV);
            }//for1
        }//if
        
            
        if(SMaxList.Copy_Covered_Locations__c==true)
        {
            for (SVMXC__Service_Contract_Sites__c childSite : ExistingSCONTChildObjSites)
            {
                SVMXC__Service_Contract_Sites__c chldObjST = new SVMXC__Service_Contract_Sites__c();
                
                for(SVMXC__ServiceMax_Config_Data__c fld:fieldMapSetting5)
                {
                    String targetFieldName = fld.SVMXC__Target_Field_Name__c;
                    String sourceFieldName = fld.SVMXC__Source_Field_Name__c;
                    Object souFldVal = childSite.get(sourceFieldName);
                                
                        if(souFldVal != null)
                        {
                            chldObjST.put(targetFieldName, souFldVal);
                        }  //if
                }  //for 2
                
                
                chldObjST.SVMXC__Service_Contract__c = NewSContHeader.Id;
                childCoveredLoc_L.add(chldObjST);
            }//for1
        }//if
        
            
        if(SMaxList.Copy_Entitled_Contacts__c==true)
        {
            for (SVMXC__Service_Contract_Contacts__c childContact : ExistingSCONTChildObjCont)
            {
                SVMXC__Service_Contract_Contacts__c chldObjCT = new SVMXC__Service_Contract_Contacts__c();
                
                
                for(SVMXC__ServiceMax_Config_Data__c fld:fieldMapSetting6)
                {
                    String targetFieldName = fld.SVMXC__Target_Field_Name__c;
                    String sourceFieldName = fld.SVMXC__Source_Field_Name__c;
                    Object souFldVal = childContact.get(sourceFieldName);
                                
                        if(souFldVal != null)
                        {
                            chldObjCT.put(targetFieldName, souFldVal);
                        }  //if
                }  //for 2
                
                
                chldObjCT.SVMXC__Service_Contract__c = NewSContHeader.Id;
                childContractContacts_L.add(chldObjCT);
            }//for1
        }//if
        
        //Insert all child datas
        Savepoint sp;
        try{
            sp = Database.setSavepoint();
            if(childContractProducts_L.size()>0){
                if(COMM_SecurityUtils.getInstance().verifyFieldAccess(childContractProducts_L, COMM_SecurityUtils.Access.Createable)){
                //SDL-SVMX-CREATE-UPDATE-FLS-ENFORCED
                insert childContractProducts_L;
            }
            else{
                throw new COMM_SecurityUtils.SecurityAccessException( System.Label.COMM001_TAG142 );
            }
            } 
            if(childServices_L.size()>0){
                if(COMM_SecurityUtils.getInstance().verifyFieldAccess(childServices_L, COMM_SecurityUtils.Access.Createable)){
                //SDL-SVMX-CREATE-UPDATE-FLS-ENFORCED
                insert childServices_L;
            }
            else{
                throw new COMM_SecurityUtils.SecurityAccessException( System.Label.COMM001_TAG142 );
            }
            } 
            if(childCoveredLoc_L.size()>0){
                if(COMM_SecurityUtils.getInstance().verifyFieldAccess(childCoveredLoc_L, COMM_SecurityUtils.Access.Createable)){
                //SDL-SVMX-CREATE-UPDATE-FLS-ENFORCED
                insert childCoveredLoc_L;
            }
            else{
                throw new COMM_SecurityUtils.SecurityAccessException( System.Label.COMM001_TAG142 );
            }
            } 
            if(childContractContacts_L.size()>0){
                if(COMM_SecurityUtils.getInstance().verifyFieldAccess(childContractContacts_L, COMM_SecurityUtils.Access.Createable)){
                //SDL-SVMX-CREATE-UPDATE-FLS-ENFORCED
                insert childContractContacts_L;
            }
            else{
                throw new COMM_SecurityUtils.SecurityAccessException( System.Label.COMM001_TAG142 );
            }
            } 
        }
        catch(exception ex){
            Database.rollback(sp);
        }
    }
    
    public void ValidateAllChildCvrage()
    {
        //if(SMaxList.Copy_Covered_Products__c ==false)
        //{
            //ApexPages.addmessage(new ApexPages.message(ApexPages.severity.WARNING,''));
        //}
    }
    
//===============================================================================================================
    //Method to Renew Contract
//===============================================================================================================    
    public PageReference RenewSContract()
    {
                    
        //Contract Name/Number field Validation
        if(NewSContHeader.Name==null)
        {
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.error,getTAG013(),''));
            return null;
        }
        //Start Date and End date fields Validation
        if(NewSContHeader.Start_Date__c == null)
        {
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.error,getTAG015(),''));
            return null;
        }

        if(NewSContHeader.End_Date__c==null)
        {
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.error,getTAG014(),''));
            return null;
        }
        //Future date Validation
        if(NewSContHeader.Start_Date__c > NewSContHeader.End_Date__c || NewSContHeader.SVMXC__End_Date__c < system.today())
        {
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.error,getTAG017(),''));
            return null;
        }
    
        if (SMaxList.Activate_Contract_Upon_Renewal__c==true)
            {
                NewSContHeader.SVMXC__Active__c =true;
            }
        
    try {
        
        //insert NewSContHeader; 
        if( COMM_SecurityUtils.getInstance().verifyFieldAccess( NewSContHeader, COMM_SecurityUtils.Access.Createable ) ) {
            //SDL-SVM-CREATE-UPDATE-FLS-ENFORCED
            insert NewSContHeader;
        } else {
            ApexPages.addMessage(new ApexPages.Message ( ApexPages.Severity.ERROR, System.Label.COMM001_TAG142 ) );
            return null;
        }

        SCONTChildFieldMapp();
        }
    catch(Exception e)
        {
        ApexPages.addMessage(new ApexPages.Message ( ApexPages.Severity.ERROR,e.getMessage(),''));
        return null;
        }

        PageReference newChildPage = new PageReference('/' + NewSContHeader.Id);
        return newChildPage;
    }   
        
  
//===============================================================================================================
    //Cancel Method to go back previous page
//===============================================================================================================
    
    public PageReference Cancel() 
    {
        PageReference scPage = new PageReference('/' + sId);
        scPage.setRedirect(true);
        return scPage;   
    } 
}