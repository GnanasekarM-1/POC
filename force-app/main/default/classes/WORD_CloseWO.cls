/* Security Scanned */
public  with sharing class WORD_CloseWO
{
    //URL Parameters
    String sId = (System.currentPageReference().getParameters().get('id') == null ) ? null : String.escapeSingleQuotes(System.currentPageReference().getParameters().get('id'));
  
    //Common Utility setting declaration //
    SVMXC.COMM_Utils utils = new SVMXC.COMM_Utils();

    SVMXC.COMM_Utils_ManageSettings msettUitl = new SVMXC.COMM_Utils_ManageSettings();
    //SVMXC.COMM_Utils_ManageSettings msettUitl = new SVMXC.COMM_Utils_ManageSettings();
    public Map<String, String> AllSubModuleSettings = msettUitl.SVMX_getSettingList('WORD001');
    
    //Create instance of UTIL Class
    SVMXC.COMM_Utils_ManageTags commUtil = new SVMXC.COMM_Utils_ManageTags();
    
    //public Map<String, String> svmxTagList = commUtil.SVMX_getTagList('WORD001');

    SVMXC__Service_Order__c  WOCHeader = new SVMXC__Service_Order__c();   
    
    //Setting Value
    private String fieldValSet = AllSubModuleSettings.get('SET003'); //Closed|Canceled;//
    
    
    //flag Declarations
    public Boolean DisplayContinue =false; // Flag to be used for Message
    public Boolean getDisplayContinue(){ return DisplayContinue;     }     
    public void setDisplayContinue(Boolean val) {DisplayContinue=val;     }
    
    public Boolean DisplayClose =true; // Flag to be used for Message
    public Boolean getDisplayClose(){ return DisplayClose;     }     
    public void setDisplayClose(Boolean val) {DisplayClose=val;     }
    
    public Boolean showDetailBlock=true;
    public Boolean AllowCloseWordOrder=true;
    
        
    public WORD_CloseWO(ApexPages.StandardController controller)
    {   
        SVMX_getWOCloseHeader();
        if(WOCHeader.SVMXC__Order_Status__c ==fieldValSet)
        {   
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,getTAG009(),getTAG006()));//;'Sorry, You can not close this Worke order since its already Closed/Canceled '));
            AllowCloseWordOrder=false;
            DisplayClose=false;
        } 
         WOCHeader.SVMXC__Order_Status__c = fieldValSet; //set from settings 'Closed';
    }

    public SVMXC__Service_Order__c  getWOCloseHeader()
    {
     return WOCHeader;
    }
    

    public Boolean getshowDetailBlock()
    {       
        if(AllowCloseWordOrder==false)
            showDetailBlock=false;
            return showDetailBlock;
    }
     
    public void setshowDetailBlock(Boolean val) 
    {
        showDetailBlock=val; 
    }
     
    //Retriving Source Object Data
    public void SVMX_getWOCloseHeader() 
    {
        try
        {
            String fieldNames;
            String SOQLHeader;

            Schema.DescribeSObjectResult dsoResult = SVMXC__Service_Order__c.sObjectType.getDescribe();
            Map<String, SObjectField> fieldMap = Schema.SObjectType.SVMXC__Service_Order__c.fields.getMap();

            //build a list of all fieldnames for the object
            List<String> fieldList = utils.SVMX_getFieldList(fieldMap,true);      
            fieldNames = utils.SVMX_getFieldNamesFromList(fieldList);
          
            SOQLHeader = '  SELECT '+fieldNames+' FROM SVMXC__Service_Order__c where Id=\''+sId+'\''; 
            WOCHeader= Database.query(SOQLHeader);
        } catch (Exception e){}
    } 

    public void setWOCloseHeader(SVMXC__Service_Order__c  word) 
    { 
        WOCHeader = word;
    }     
    
    public PageReference CloseWorkOrderConfirm()
    {
            
        ////if(WOCHeader.SVMXC__Order_Status__c != fieldValSet) 
        ////{
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.WARNING,getTAG008(),''));//'Are you sure'));
            //AllowCloseWordOrder=true;
            DisplayClose=false;
            DisplayContinue=true;       
        ////}
        return null;
    }
        
    public PageReference CloseWorkOrder()
    {
        try
        {
            WOCHeader.SVMXC__Order_Status__c = fieldValSet;//.put(fldNameToConsider,fieldValSet);
            WOCHeader.SVMXC__Closed_On__c = system.now(); //By GM 22Dec10
            WOCHeader.SVMXC__Closed_By__c = system.Userinfo.getUserId(); //By GM 22Dec10
            
            if( COMM_SecurityUtils.getInstance().verifyFieldAccess( WOCHeader, COMM_SecurityUtils.Access.Updateable ) ) {
            //SDL-SVM-CREATE-UPDATE-FLS-ENFORCED
                update WOCHeader;
            } else {
                throw new COMM_SecurityUtils.SecurityAccessException( System.Label.COMM001_TAG142 );
            }
        }
        catch (Exception e) {
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,getTAG009(),e.getMessage())); 
            return null;
        }
        PageReference WOCPage = new PageReference('/' + sId);
        //WOCPage.setRedirect(true);
        return WOCPage;
    }
    
    //Method executes on click of cancel button 
    public PageReference Cancel() 
    {
        PageReference scPage = new PageReference('/' + sId);
        scPage.setRedirect(true);
        return scPage;   
    }
    
    public String getTAG001(){ return system.label.WORD001_TAG001;}//   
    public String getTAG002(){ return system.label.WORD001_TAG002;}//      
    public String getTAG003(){ return system.label.WORD001_TAG003;}//
    public String getTAG004(){ return system.label.WORD001_TAG004;}// 
    public String getTAG005(){ return system.label.WORD001_TAG005;}//   
    public String getTAG006(){ return system.label.WORD001_TAG006;}//  
    public String getTAG007(){ return system.label.WORD001_TAG007;}//  
    public String getTAG008(){ return system.label.WORD001_TAG008;}// 
    public String getTAG009(){ return system.label.WORD001_TAG009;}//
    public String getHLPURL(){ return system.label.WORD001_HLPURL;}

}