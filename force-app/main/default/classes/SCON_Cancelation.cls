public  with sharing class SCON_Cancelation
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
        
    SVMXC__Service_Contract__c  SContHeader = new SVMXC__Service_Contract__c();
    //List<SVMXC__Entitlement_History__c> SConEnHisy = new   List<SVMXC__Entitlement_History__c>();
    List<SVMXC__Entitlement_History__c> SConEnHisy = new List<SVMXC__Entitlement_History__c>();
    
//===============================================================================================================
    //Variable  delartion  and get, set methods to check Service Contract status w
//===============================================================================================================             

    public Boolean showDetailBlock=true;
    public Boolean IsActivatedContract=true;//false; // Flag to be used for Message
    public Boolean getIsActivatedContract(){ return IsActivatedContract;     }     
    public void setIsActivatedContract(Boolean val) {IsActivatedContract=val;     }
    public Boolean AllowNullEntitleHistory=true; 
    Integer EntHistAllCount = 0;
    Integer EntHistOpenCount = 0;
   
//============================================================================================================
    //Instace creation by using Util calss medhods
//============================================================================================================

    COMM_Utils utils = new COMM_Utils();
    
    COMM_Utils_ManageTags commUtil = new COMM_Utils_ManageTags();
    SVMXC.COMM_Utils_ManageSettings msettUitl = new SVMXC.COMM_Utils_ManageSettings();
    
//===============================================================================================================
    //Message Tag list with Sub Module Id
    // Call a Method in UTIL class to return Tags
//===============================================================================================================   

   //public Map<String, String> svmxTagList = commUtil.SVMX_getTagList('SCON003');
    
//===============================================================================================================
    // To get Settings:
    // Call a Method in UTIL class to return Settings, Send SubModule ID for getting Settings
//===============================================================================================================

   public Map<String, String> svmxSettingList = msettUitl.SVMX_getSettingList('SCON003');
    
//============================================================================================================
    //TAG Methods for Transaction message
//============================================================================================================
                            
    public String getTAG001(){ return system.label.SCON003_TAG001;}
    public String getTAG002(){ return system.label.SCON003_TAG002;}
    public String getTAG003(){ return system.label.SCON003_TAG003;}
    public String getTAG004(){ return system.label.SCON003_TAG004;}
    public String getTAG005(){ return system.label.SCON003_TAG005;}
    public String getTAG006(){ return system.label.SCON003_TAG006;}
    public String getTAG007(){ return system.label.SCON003_TAG007;}
    public String getTAG008(){ return system.label.SCON003_TAG008;}
    public String getTAG009(){ return system.label.SCON003_TAG009;}
    public String getTAG010(){ return system.label.SCON003_TAG010;}
    public String getTAG011(){ return system.label.SCON003_TAG011;}
    public String getTAG012(){ return system.label.SCON003_TAG012;}
    public String getTAG013(){ return system.label.SCON003_TAG013;}
    public String getTAG014(){ return system.label.SCON003_TAG014;}
    public String getTAG015(){ return system.label.SCON003_TAG015;}
    public String getHLPURL() {return system.label.SCON003_HLPURL;}
    
//=============================================================================================================
//Seting values methods
//=============================================================================================================
                                                        
    private String SetngForEntitleHistory1 = svmxSettingList.get('SET001'); // Allow | Disallow | Warn
    private String SetngForEntitleHistory2 = svmxSettingList.get('SET002');// Allow | Disallow | Warn
    private String SetngForCancellExpCont = svmxSettingList.get('SET003');// Allow | Disallow | Warn
    
//===============================================================================================================
    //Constructor
//===============================================================================================================
    
    public  SCON_Cancelation(ApexPages.StandardController controller)
    {
        SContHeader =getSContractHeader();
        getSContEntlHisy();
        if(SContHeader.SVMXC__Active__c == false)
        {          
         ApexPages.addmessage(new ApexPages.message(ApexPages.severity.error,getTAG008())); 
         IsActivatedContract =false;    
        }
        else
        {
            ValidateSettingsAndContrExp();
        }

    /*    ValidateContStatus();

        if (IsActivatedContract ==true)
        ValidateSettings();*/
    }
    
   

//===============================================================================================================
    //Method to Validat Setting Values
//===============================================================================================================   
    public void ValidateSettingsAndContrExp()
    {
        // Setting1: Allow/Disallow/Warn if contract is linked to ANY entitlement
        // Setting2: Allow/Disallow/Warn if contract is linked to entitlements of currently open cases
    
        //Check if the contract has already been expired
        
        if(SContHeader.SVMXC__End_Date__c < System.today()) 
        {      
            if(SetngForCancellExpCont.toUpperCase()=='DISALLOW')
            {
                ApexPages.addmessage(new ApexPages.message(ApexPages.severity.error,getTAG009()));
                IsActivatedContract =false;
            }
           else if(SetngForCancellExpCont.toUpperCase()=='WARN')
           {
               ApexPages.addmessage(new ApexPages.message(ApexPages.severity.Warning,getTAG014()));
           }
        }
        else if(EntHistOpenCount > 0)
        {
            if (SetngForEntitleHistory2.toUpperCase()=='DISALLOW')
            {
                ApexPages.addmessage(new ApexPages.message(ApexPages.severity.error,getTAG011()));
                IsActivatedContract =false;
            }
            else if(SetngForEntitleHistory2.toUpperCase()=='WARN')
            {
                if(EntHistAllCount > 0)
                {
                    if (SetngForEntitleHistory1.toUpperCase()=='DISALLOW')
                    {
                        ApexPages.addmessage(new ApexPages.message(ApexPages.severity.error,getTAG010()));
                        IsActivatedContract =false;
                    }
                    else if(SetngForEntitleHistory1.toUpperCase()== 'WARN')
                    {
                        
                        ApexPages.addmessage(new ApexPages.message(ApexPages.severity.warning,getTAG013()));//mesg for open case
                        ApexPages.addmessage(new ApexPages.message(ApexPages.severity.warning,getTAG012()));//mesg for close case
                        AllowNullEntitleHistory=true;
                    }
                    else 
                    {
                        
                        ApexPages.addmessage(new ApexPages.message(ApexPages.severity.warning,getTAG013()));//mesg for open case
                        AllowNullEntitleHistory=true;
                    }
                }
            }
            else if(SetngForEntitleHistory2.toUpperCase()=='ALLOW')
            {
                if(EntHistAllCount > 0)
                {
                    if (SetngForEntitleHistory1.toUpperCase()=='DISALLOW')
                    {
                        ApexPages.addmessage(new ApexPages.message(ApexPages.severity.error,getTAG010()));
                        IsActivatedContract =false;
                    }
                    else if(SetngForEntitleHistory1.toUpperCase()== 'WARN')
                    {
                        ApexPages.addmessage(new ApexPages.message(ApexPages.severity.warning,getTAG012()));
                        AllowNullEntitleHistory=true;
                    }
                    else
                    {
                        AllowNullEntitleHistory=true;
                    }
                }
            }
        }
        else if(EntHistAllCount > 0)
        {
            if (SetngForEntitleHistory1.toUpperCase()=='DISALLOW')
            {
                ApexPages.addmessage(new ApexPages.message(ApexPages.severity.error,getTAG010()));
                IsActivatedContract =false;
            }
            else if(SetngForEntitleHistory1.toUpperCase()== 'WARN')
            {
                ApexPages.addmessage(new ApexPages.message(ApexPages.severity.warning,getTAG012()));//mesg for close case
                AllowNullEntitleHistory=true;
            }
            else
            {
                AllowNullEntitleHistory=true;
            }
        }
        else
        {
                AllowNullEntitleHistory=true;
        }
 
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
        if(IsActivatedContract==true)
            showDetailBlock=false;
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
        try
        {
            String fieldNames;
            String SOQLHeader;

            Schema.DescribeSObjectResult dsoResult = SVMXC__Service_Contract__c.sObjectType.getDescribe();
            Map<String, SObjectField> fieldMap = Schema.SObjectType.SVMXC__Service_Contract__c.fields.getMap();

           //build a list of all fieldnames for the object
            List<String> fieldList = utils.SVMX_getFieldList(fieldMap,true);      
            fieldNames = utils.SVMX_getFieldNamesFromList(fieldList);
                   
            SOQLHeader = '  SELECT '+fieldNames+'  FROM SVMXC__Service_Contract__c where Id =:sId'; //\''+sId+'\'(commented by amar on 18/2/10 3:15 pm becasue of Security Review)
            SContHeader= Database.query(SOQLHeader);

        } catch (Exception e)
            {
                
                   ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, e.getMessage()));      

            }
            return SContHeader;            
    }

//===============================================================================================================   
    //Entitlement History Object
//===============================================================================================================

    public Boolean getSContEntlHisy() 
    {
        try
        {
        EntHistAllCount = [Select count() From SVMXC__Entitlement_History__c
                                WHERE SVMXC__Service_Contract__c = :sId];

        EntHistOpenCount = [Select count() From SVMXC__Entitlement_History__c
                                WHERE SVMXC__Service_Contract__c = :sId
                            AND SVMXC__Case__r.IsClosed = false];
        }
    catch (Exception e) { return false; }

    return true;            
    }
    
//===============================================================================================================
    //Standar Methods to generate field values of current SObject
//===============================================================================================================            
    
    //method to check Work Order is available or what
    public static Boolean isFieldAvailable(List<String> fieldList,String fldName) 
    {
        String fieldNames = '';
        Boolean fieldAvailable =false;
        for (String field : fieldList) 
        {
            if (field==fldName)
                {
                fieldAvailable =true;
                break;  
                }
        }        
        return fieldAvailable;
    }  
//===============================================================================================================
    //Method to Deactivate Contract
//===============================================================================================================    
    
    public PageReference RevokeSContract()
    {
        if(SContHeader.SVMXC__Active__c =true)
        {
            SContHeader.SVMXC__Active__c =false;
            SContHeader.SVMXC__Canceled_By__c = UserInfo.getUserId();
            SContHeader.SVMXC__Canceled_On__c=System.now();
            //upsert SContHeader;
			if( COMM_SecurityUtils.getInstance().verifyFieldAccess( SContHeader, COMM_SecurityUtils.Access.Upsertable ) ) {
				upsert SContHeader;
			} else {
				ApexPages.addMessage(new ApexPages.Message ( ApexPages.Severity.ERROR, System.Label.COMM001_TAG142 ) );
				return null;
			}
            //PageReference p= new PageReference('/'+sId);
            PageReference p= new PageReference('/'+SContHeader.Id);
            return p;
        
        }
        return null;        
    }

//===============================================================================================================
    //Cancel Method to go back previous page
//===============================================================================================================
    
    public PageReference Cancel() 
    {
        //PageReference scPage = new PageReference('/' + sId);
        PageReference scPage = new PageReference('/' + SContHeader.Id);
        scPage.setRedirect(true);
        return scPage;   
    } 
}