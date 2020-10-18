/* Security Scanned */
public  with sharing class SCON_Activation
{
    //----------------------NPS Related...
    public string getUserLocaleKey(){
        return UserInfo.getLanguage();
    }
    public string getUserID(){
        return UserInfo.getUserId().substring(0, 15);
    }
    public string getUserOrgID(){
        return UserInfo.getOrganizationId().substring(0, 15);
    }
    //------------------------------------
    
    String sId = System.currentPageReference().getParameters().get('id'); 

//===============================================================================================================
    //Create a instance of UTIL Class for TAGS, Settings and Field Values
//===============================================================================================================
    SVMXC.COMM_Utils utils = new SVMXC.COMM_Utils();

    SVMXC.COMM_Utils_ManageTags commUtil = new SVMXC.COMM_Utils_ManageTags();
    SVMXC.COMM_Utils_ManageSettings msettUitl = new SVMXC.COMM_Utils_ManageSettings();

//===============================================================================================================
    //Variable  to check Service Contract status with getter and setter methods
//===============================================================================================================             
    public Boolean IsActivatedContract=true; // Flag to be used for Message
    public Boolean getIsActivatedContract(){ return IsActivatedContract;     }     
    public void setIsActivatedContract(Boolean val) {IsActivatedContract=val;     }
    
    public Boolean IstoDisplay=true; // Flag to be used for Message
    public Boolean getIstoDisplay(){ return IstoDisplay;     }     
    public void setIstoDisplay(Boolean val) {IstoDisplay=val;     } 
     
    public Boolean DisplayActivate =true; // Flag to be used for Message
    public Boolean getDisplayActivate(){ return DisplayActivate;     }     
    public void setDisplayActivate(Boolean val) {DisplayActivate=val;     }
    
    public Boolean DisplayContinue =false; // Flag to be used for Message
    public Boolean getDisplayContinue(){ return DisplayContinue;     }     
    public void setDisplayContinue(Boolean val) {DisplayContinue=val;     }
    
    public Boolean showDetailBlock=true;
    public Boolean AllowNullCoveredProducts=true;
    public Boolean AllowNullCoveredSites=true;
    public Boolean AllowNullCoveredContacts=true;
    public Boolean AllowNullCoveredServices=true;
    Boolean ValidRecords = true;
    
    SVMXC__Service_Contract__c  SContHeader = new SVMXC__Service_Contract__c();   

    public Map<String, String> svmxSettingList = msettUitl.SVMX_getSettingList('SCON001');
    //public Map<String, String> svmxTagList = commUtil.SVMX_getTagList('SCON001');
   
//===============================================================================================================
    //Methods for Tags that we have in VF Page, One for each Tag)
    //getter method for each tag you have in VF page
//===============================================================================================================
        
    public String getTAG001(){ return system.label.SCON001_TAG001;}
    public String getTAG002(){ return system.label.SCON001_TAG002;}
    public String getTAG003(){ return system.label.SCON001_TAG003;}
    public String getTAG004(){ return system.label.SCON001_TAG004;}
    public String getTAG006(){ return system.label.SCON001_TAG006;}
    public String getTAG007(){ return system.label.SCON001_TAG007;}
    public String getTAG008(){ return system.label.SCON001_TAG008;}
    public String getTAG009(){ return system.label.SCON001_TAG009;}
    public String getTAG010(){ return system.label.SCON001_TAG010;}
    public String getTAG011(){ return system.label.SCON001_TAG011;}
    public String getTAG012(){ return system.label.SCON001_TAG012;}
    public String getTAG013(){ return system.label.SCON001_TAG013;}
    public String getTAG015(){ return system.label.SCON001_TAG015;}
    public String getTAG016(){ return system.label.SCON001_TAG016;}
    public String getTAG017(){ return system.label.SCON001_TAG017;}
    public String getTAG018(){ return system.label.SCON001_TAG018;}
    public String getTAG020(){ return system.label.SCON001_TAG020;}
    public String getTAG021(){ return system.label.SCON001_TAG021;}
    public String getHLPURL(){return system.label.SCON001_HLPURL;}            

    public String getSET001(){ return svmxSettingList.get('SET001') ;}

    
    List<String> ErrorMessages = new  List<String> ();
    public void AddToErrorsList(String msg) { ErrorMessages.add(msg); }
    public List<String> getErrorsList() {    return ErrorMessages; }  
//===============================================================================================================
    //Method for Settings we have used in Controller/Class, One for each Setting)
//===============================================================================================================   
    
    private String SetngForCoveredProds ;
    private String SetngForCoveredSites ;
    private String SetngForCoveredServices ;
    private String SetngForCoveredContacts ;//=svmxSettingList.get('SET004');// Allow | Disallow | Warn
   
   
   //Method to Display Errors 
    public void DisplayErrors()
    {
        if( ErrorMessages.size()>0)
        {
            ValidRecords = false;  
            for (String msg : ErrorMessages)
            {
                ApexPages.AddMessage(new ApexPages.Message(ApexPages.Severity.Error,msg,'')) ;
                showDetailBlock=false;
                DisplayActivate =false;
            }
        }   
            
    }    
    
    public void validateSettingValues()
    {
   
       if (svmxSettingList.size()==0) 
         AddToErrorsList(getTag021()); //Settings not available for the SubModule: Service Contract Activation 
//SET001
            SetngForCoveredProds= svmxSettingList.get('SET001');// Allow | Disallow | Warn 
            if (SetngForCoveredProds ==null)    
            AddToErrorsList(getTag021()); //Setting not available for : Service Contract Covered Product 
//SET002            
             SetngForCoveredSites= svmxSettingList.get('SET002');// Allow | Disallow | Warn; 
             if (SetngForCoveredSites ==null)   
                AddToErrorsList(getTag021()); //Setting not available for : Service Contract Covered Sites 
//SET003     
            SetngForCoveredServices=svmxSettingList.get('SET003');// Allow | Disallow | Warn;   
            if (SetngForCoveredServices ==null) 
            AddToErrorsList(getTag021()); //Setting not available for : Service Contract Covered Services
//SET004        
            SetngForCoveredContacts = svmxSettingList.get('SET004');  
            if (SetngForCoveredContacts ==null)  
            AddToErrorsList(getTag021()); //Setting not available for : Service Contract Covered Location */
    } 
        //String tst ;
    List<SVMXC__Service_Contract_Products__c>  CoveredProducts ;
    List<SVMXC__Service_Contract_Sites__c> CoveredSites;
    List<SVMXC__Service_Contract_Services__c>  CoveredServices ;
    List<SVMXC__Service_Contract_Contacts__c> CoveredContacts ; 
       
 //===============================================================================================================
    //Constructor and its calling on page load to validate SVMX Setting values.
 //===============================================================================================================
   public  void doSetUp()
        {
            SContHeader =getSContractHeader(); 
            if(SContHeader != null)
            {
                if(SContHeader.SVMXC__Active__c==false)
                    {
                            CoveredProducts =getContractProducts();
                            CoveredSites= getContractSites();
                            CoveredServices = getContractServices();
                            CoveredContacts =getContractContacts();
                            ValidateAllSettings();
                            if(SContHeader.SVMXC__End_Date__c < System.today()) 
                                {
                                ApexPages.addmessage(new ApexPages.message(ApexPages.severity.Error,getTAG009(),'')); //'End Date should be future Date'
                                showDetailBlock=false;
                                DisplayActivate=false;
                                }            
                    }
                else
                {
                     ApexPages.addmessage(new ApexPages.message(ApexPages.severity.Error,getTAG006(),''));
                     showDetailBlock=false;
                     DisplayActivate =false;           
                }  
            }      
            
        }

    public SCON_Activation(ApexPages.StandardController controller)
    {
        validateSettingValues();
        DisplayErrors();
        if (ValidRecords==true)
        {    
            doSetUp();       
        }   
    }  
          
//===============================================================================================================
    //Methods to through SVMX Setting Values for Activate SContract
//===============================================================================================================
    public void ValidateAllSettings()
    {   
        String ErrorFlg='N';
      //Validtion for Covered Products 
        if(CoveredProducts.size()==0 )
        {
              if (SetngForCoveredProds.toUpperCase() == 'DISALLOW')
              {
                //Show Message
                ApexPages.addmessage(new ApexPages.message(ApexPages.severity.Error,getTAG010(),''));//'error there is no product covered'));
                AllowNullCoveredProducts=false;
                DisplayActivate = false;
                DisplayContinue = false;
                showDetailBlock = false;
               
             } 
             
            if (SetngForCoveredProds.toUpperCase() =='WARN')
            {
                //Show Message
                ApexPages.addmessage(new ApexPages.message(ApexPages.severity.WARNING,getTAG015(),''));
                AllowNullCoveredProducts=true;
                DisplayActivate =false;
                DisplayContinue = true;
            }
            
            if (SetngForCoveredProds.toUpperCase() == 'ALLOW')
            {
                AllowNullCoveredProducts=true;
               
            }
             
        }
    
          
        //Validtion for Covered Sites
        if(CoveredSites.size()==0 )
        {
            if (SetngForCoveredSites.toUpperCase() =='DISALLOW')
            {
                ApexPages.addmessage(new ApexPages.message(ApexPages.severity.error,getTAG011(),''));
                AllowNullCoveredSites=false;
                showDetailBlock=false;
                DisplayActivate =false;
                DisplayContinue = false;
            }            
             
            if (SetngForCoveredSites.toUpperCase()=='WARN')
            {
                ApexPages.addmessage(new ApexPages.message(ApexPages.severity.WARNING,getTAG016(),''));
                AllowNullCoveredSites=true;
                DisplayActivate =false;
                DisplayContinue = true;
            }

            if (SetngForCoveredSites.toUpperCase()=='ALLOW')
            {
                AllowNullCoveredSites=true;
            }
            
        } 
          
                  
         //Validation for Covered Services           
        if(CoveredServices.size()==0 )
        {
            if (SetngForCoveredServices.toUpperCase()=='DISALLOW')
            {
                //Show Message
                ApexPages.addmessage(new ApexPages.message(ApexPages.severity.error,getTAG012(),''));
                AllowNullCoveredServices=false;
                showDetailBlock=false;
                DisplayActivate =false;
                DisplayContinue = false;
            }
           
            if (SetngForCoveredServices.toUpperCase()=='WARN')
            {
                //Show Message
                ApexPages.addmessage(new ApexPages.message(ApexPages.severity.WARNING,getTAG017(),''));
                AllowNullCoveredServices=true;
                DisplayActivate =false;
                DisplayContinue = true;
            }

            if (SetngForCoveredServices.toUpperCase()=='ALLOW')
            {
                AllowNullCoveredServices=true;
            }
        }               
    
        //Validation for Covered Contacts
        if(CoveredContacts.size()==0 )
        {
                
            if (SetngForCoveredContacts.toUpperCase()=='DISALLOW')
            {
                //Show Message
                ApexPages.addmessage(new ApexPages.message(ApexPages.severity.error,getTAG013(),''));
                AllowNullCoveredContacts=false;
                showDetailBlock=false;
                DisplayActivate =false;
                DisplayContinue = false;
                
            }
      
            if(SetngForCoveredContacts.toUpperCase()=='WARN')
            {
                //Show Message
                ApexPages.addmessage(new ApexPages.message(ApexPages.severity.WARNING,getTAG018(),''));
                AllowNullCoveredContacts=true;
                DisplayActivate =false;
                DisplayContinue = true;

            }
            
            if (SetngForCoveredContacts.toUpperCase()=='ALLOW')
            {
                AllowNullCoveredContacts=true;
            }
        }   
    }    
//===============================================================================================================
    //Method to render/re-render the page block based on SVMX Setting Values with getter and setter
//===============================================================================================================
    
    public Boolean getshowDetailBlock()
    {       
        //if(IsActivatedContract==true )//|| AllowNullCoveredProducts==false || AllowNullCoveredSites==false || AllowNullCoveredServices==false|| AllowNullCoveredContacts==false)
            //showDetailBlock=true;
            return showDetailBlock; 
    }
     
    public void setshowDetailBlock(Boolean val) 
    {
        showDetailBlock=val; 
    } 
    
//===============================================================================================================
    // Variable to store value for  SVMX_Setting Description field with getter and setter methods
//===============================================================================================================    
    
    Boolean showUpsellMessage=true;
    public Boolean getshowUpsellMessage(){ return showUpsellMessage; }     
    public void setshowUpsellMessage(Boolean icps) {showUpsellMessage=icps; } 

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

                    
            SOQLHeader = '  SELECT '+fieldNames+' FROM SVMXC__Service_Contract__c where Id =:sId'; //\''+sId+'\'(commented by amar on 18/2/10 4:00 pm becasue of Security Review)
            SContHeader= Database.query(SOQLHeader);

        } catch (Exception e){            
                    ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,e.getMessage(),''));      
                    return null;
                }
            return SContHeader;          
    }
//===============================================================================================================
    //Method to get info about Product coverage of Activation of Contract
//===============================================================================================================
    
    public List<SVMXC__Service_Contract_Products__c> getContractProducts() 
    {
        List<SVMXC__Service_Contract_Products__c> SConProducts = new List<SVMXC__Service_Contract_Products__c>();
        try
        {
            String SOQLHeader;
    
            SOQLHeader = '  SELECT Id,Name FROM SVMXC__Service_Contract_Products__c where SVMXC__Service_Contract__c =:sId'; //\''+sId+'\'(commented by amar on 18/2/10 4:00 pm becasue of Security Review) 
            SConProducts= Database.query(SOQLHeader);
             
        } catch (Exception e)
            {
                   ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,e.getMessage(),''));      
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
    
            SOQLHeader = '  SELECT Id,Name FROM SVMXC__Service_Contract_Sites__c where SVMXC__Service_Contract__c =:sId'; //\''+sId+'\'(commented by amar on 18/2/10 4:00 pm becasue of Security Review) 
            SConSites= Database.query(SOQLHeader);
                 
        } catch (Exception e)
            {
                   ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,e.getMessage(),''));  
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
                
                SOQLHeader = 'SELECT Id,Name FROM SVMXC__Service_Contract_Services__c where SVMXC__Service_Contract__c =:sId'; //\''+sId+'\'(commented by amar on 18/2/10 4:00 pm becasue of Security Review) 
                SConServices= Database.query(SOQLHeader);
             
            } catch (Exception e)
                {
                   ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,e.getMessage(),''));    
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
    
            SOQLHeader = '  SELECT Id,Name FROM SVMXC__Service_Contract_Contacts__c where SVMXC__Service_Contract__c =:sId'; //\''+sId+'\'(commented by amar on 18/2/10 4:00 pm becasue of Security Review) 
            SConContacts= Database.query(SOQLHeader);
                 
        } catch (Exception e)
            {
                   ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,e.getMessage(),''));      
                   return null;
            }
                    return SConContacts;            
    } 
//===============================================================================================================
    //Method to Activate Contract
//===============================================================================================================    
    
    public PageReference ActivateContract()
    {
            
       if(showDetailBlock==true)
        {
            SContHeader.SVMXC__Active__c =true;
            //upsert SContHeader;
            if( COMM_SecurityUtils.getInstance().verifyFieldAccess( SContHeader, COMM_SecurityUtils.Access.Upsertable ) ) {
                //SDL-SVM-CREATE-UPDATE-FLS-ENFORCED
                upsert SContHeader;
            } else {
                ApexPages.addMessage(new ApexPages.Message ( ApexPages.Severity.ERROR, System.Label.COMM001_TAG142 ) );
                return null;
            }
           // PageReference p= new PageReference('/'+sId);
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