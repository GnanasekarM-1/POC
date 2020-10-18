public with sharing class CONF_ManagePushNotifications 
{
    public boolean IsHdrMsg = false;
    public boolean getIsHdrMsg(){return this.IsHdrMsg;}
    public List<SVMXC__ServiceMax_Config_Data__c> lstNotificationConfigs = new List<SVMXC__ServiceMax_Config_Data__c>();
    public List<SVMXC__ServiceMax_Config_Data__c> getlstNotificationConfigs(){return lstNotificationConfigs;}
    
    //public List<SVMXC__SVMX_Job_Logs__c> lstNotificationLogs = new List<SVMXC__SVMX_Job_Logs__c>();
    //public List<SVMXC__SVMX_Job_Logs__c> getlstNotificationLogs(){return lstNotificationLogs;}
    public Map<Id,SVMXC__SVMX_Job_Logs__c> mapJobLogDetails{get;set;} //Added for 045444/IPAD-4859
    map<String, String> mapObjAPINameToLabel = new map<String, String>();
    public Map<String,String> getmapObjAPINameToLabel() {return mapObjAPINameToLabel;}
    
    public CONF_ManagePushNotifications()
    {
        lstNotificationConfigs = [select Id, SVMXC__Select__c, SVMXC__Active__c , SVMXC__Profile_Name__c, SVMXC__Object_Name__c, SVMXC__Profile__c, SVMXC__Dispatch_Process__c, SVMXC__Dispatch_Process__r.SVMXC__Advance_Expression__c, SVMXC__Parameter_Name__c, SVMXC__Parameter_Value__c, SVMXC__Internal_Value__c, SVMXC__Description__c, SVMXC__FKey_Name_Field__c, LastModifiedDate, LastModifiedBy.Name from SVMXC__ServiceMax_Config_Data__c where RecordType.Name = 'Mobile Configuration' AND SVMXC__Display_Type__c = 'Push Notification' AND (SVMXC__Object_Name__c = 'SVMXC__Service_Order__c' OR SVMXC__Object_Name__c = 'Event' OR SVMXC__Object_Name__c = 'SVMXC__SVMX_Event__c') ORDER BY CreatedDate]; //SDL-SVMX-FLS-NOT-ENFORCED-META-DATA
        //lstNotificationLogs = [Select Id, CreatedDate, LastModifiedDate, LastModifiedBy.Name, SVMXC__Apex_CPU_Time__c, SVMXC__Call_Status__c, SVMXC__Log_level__c, SVMXC__Event_Name__c, SVMXC__Event_Type__c, SVMXC__Message__c, SVMXC__Profile_Id__c, SVMXC__Type__c from SVMXC__SVMX_Job_Logs__c where SVMXC__Operation__c = 'PUSH NOTIFICATION' AND SVMXC__Call_Status__c = 'SENT' ORDER BY SVMXC__Event_Name__c]; //SDL-SVMX-FLS-NOT-ENFORCED-META-DATA
        mapJobLogDetails = new Map<Id,SVMXC__SVMX_Job_Logs__c>([Select Id, CreatedDate, LastModifiedDate, LastModifiedBy.Name, SVMXC__Apex_CPU_Time__c, SVMXC__Call_Status__c, SVMXC__Log_level__c, SVMXC__Event_Name__c, SVMXC__Event_Type__c, SVMXC__Message__c, SVMXC__Profile_Id__c, SVMXC__Type__c from SVMXC__SVMX_Job_Logs__c where SVMXC__Operation__c = 'PUSH NOTIFICATION' AND SVMXC__Call_Status__c = 'SENT' ORDER BY SVMXC__Event_Name__c]); //Added for 045444/IPAD-4859
        
        for(SVMXC__SVMX_Job_Logs__c eachLog : mapJobLogDetails.values()) 
        {
            system.debug(LoggingLevel.WARN, 'Created DateTime = ' + eachLog.CreatedDate + '; LastModified Date Time = ' + eachLog.LastModifiedDate);
            system.debug(LoggingLevel.WARN, 'Created Date = ' + (eachLog.CreatedDate).dateGMT() + '; LastModifiedDate = ' + (eachLog.LastModifiedDate).dateGMT());
            
            /*if(eachLog.LastModifiedDate < (DateTime.now()).dateGMT())
            {
                eachLog.SVMXC__Log_level__c = 0;
            }*/
            if(eachLog.SVMXC__Apex_CPU_Time__c != null && eachLog.SVMXC__Apex_CPU_Time__c > 0)
            {
                Integer intDays = ((eachLog.CreatedDate).dateGMT()).daysBetween((eachLog.LastModifiedDate).dateGMT());
                Integer intSendCount = Integer.valueOf(eachLog.SVMXC__Apex_CPU_Time__c);
                if(intDays == null || intDays <= 0)
                    intDays = 1;
                eachLog.SVMXC__Apex_CPU_Time__c = intSendCount/intDays;
            }
        }
        
        map<String, Schema.SObjectType> allObjs = Schema.getGlobalDescribe();
        
        for(String objName : allObjs.keyset())
        {
            try
            {
                Schema.DescribeSObjectResult objDesc = allObjs.get(objName).getDescribe();
                mapObjAPINameToLabel.put(objDesc.getName(), objDesc.getLabel());
            }
            catch(Exception ex)
            {
                system.debug(LoggingLevel.WARN, 'Exception = ' + ex.getMessage());
            }
        }
    }
    
    public PageReference SVMXEdit() 
    {
        Integer intCount = 0;
        String strNotificationId='';
        
        for(SVMXC__ServiceMax_Config_Data__c eachNotifctn : lstNotificationConfigs)
        {
            if(eachNotifctn.SVMXC__Select__c == true)
            {
                intCount++;
            }
        }
        
        if(intCount == 0)
        {
            IsHdrMsg = true;
            ApexPages.addMessage(new ApexPages.Message ( ApexPages.Severity.Error,getTAG016()));
        }
        else if(intCount > 1)
        {
            IsHdrMsg = true;
            ApexPages.addMessage(new ApexPages.Message (ApexPages.Severity.Error, getTAG019() ));
        }
        else
        {
            for(SVMXC__ServiceMax_Config_Data__c eachNotifctn : lstNotificationConfigs)
            {
                if(eachNotifctn.SVMXC__Select__c == true)
                {
                    strNotificationId = eachNotifctn.id;
                    PageReference pageRef = new PageReference('/apex/CONF_PushNotifications');
                    pageRef.setRedirect(true);
                    pageRef.getParameters().put('SVMX_RecordId',strNotificationId);
                    return pageRef;
                }
            }
        }
        return null;
    }
    
    public PageReference SVMXDelete()
    {
        IsHdrMsg = false;
        Integer intCount = 0;
        PageReference pageref1 = null;
        List<Integer> selectedConfigs = new List<Integer>();
        List<SVMXC__ServiceMax_Config_Data__c> lstConfigsToDelete = new List<SVMXC__ServiceMax_Config_Data__c>();
        
        for(SVMXC__ServiceMax_Config_Data__c eachNotifctn : lstNotificationConfigs)
        {
            if(eachNotifctn.SVMXC__Select__c == true)
            {
                lstConfigsToDelete.add(eachNotifctn);
                selectedConfigs.add(intCount);
                system.debug(LoggingLevel.WARN, 'Notification to delete = ' + eachNotifctn);
            }
            intCount++;
        }
        
        if(lstConfigsToDelete.size() == 0)
        {
            IsHdrMsg = true;
            ApexPages.addMessage(new ApexPages.Message ( ApexPages.Severity.ERROR,getTAG016()));
            return null;
        }
        try
        {
            system.debug(LoggingLevel.WARN, 'List of Configs to Delete = ' + lstConfigsToDelete + '; Size = ' + lstConfigsToDelete.size());
            if(lstConfigsToDelete != null && lstConfigsToDelete.size() > 0) {  
                  /*
                    SECSCAN-822 : Security Fix
                */
                if(!COMM_SecurityUtils.getInstance().isDeletableObject( 'SVMXC__ServiceMax_Config_Data__c' ) ) {
                    ApexPages.addMessage(new ApexPages.Message ( ApexPages.Severity.ERROR,System.Label.COMM001_TAG142 ));
                    return null;
                } 
                delete lstConfigsToDelete; //SDL-SVMX-DELETE-FLS-ENFORCED
                
            }   
            IsHdrMsg = true;
            for(Integer i = selectedConfigs.size()-1; i>=0; i--)
                lstNotificationConfigs.remove(selectedConfigs.get(i));
            ApexPages.addMessage(new ApexPages.Message (ApexPages.Severity.CONFIRM, getTAG017()));
            pageref1= new PageReference('/apex/CONF_ManagePushNotifications');
            pageRef1.setRedirect(true); 
            return null;      
        }
        catch(exception ex)
        {
            IsHdrMsg = true;
            ApexPages.addMessage(new ApexPages.Message (ApexPages.Severity.Error,ex.getMessage()));
            return null;
        }
    }
    
    public PageReference BackToSetupHome() 
    {
        //Changes done by Nidhi as part of BAC-4747. Handling redirection on Lightning Experience
        String url='';
        if(UserInfo.getUiThemeDisplayed()=='Theme4d' || UserInfo.getUiThemeDisplayed()=='Theme4u'){
            url = '/lightning/n/SVMXC__ServiceMax_Setup';
        }else{
            url ='/apex/CONF_SetupHome';
        }
        PageReference pRef = new PageReference(url);  
        return pRef;
    }
    
    public pagereference SVMXNew()
    {
        PageReference pageref= new PageReference('/apex/CONF_PushNotifications');
        return pageref;
    }
    
    public string getHLPURL() {return system.label.CONF031_HLPURL;} //'Help URL'
    public string getHLPTITLE() {return system.label.COMM001_TAG064;} //'Help Title'
    public String getTAG001(){return System.Label.COMM001_TAG043;} //'View'
    public String getTAG002(){return System.Label.CONF031_TAG001;} //'Standard Searches'
    
    public String getTAG003(){return System.Label.COMM001_TAG044;}//Select
    public String getTAG004(){return System.Label.CONF040_TAG032;} //'Name'
    public String getTAG005(){return System.Label.CONF040_TAG033;} //'Type'
    public String getTAG006(){return System.Label.CONF040_TAG034;} //Status
    public String getTAG007(){return System.Label.CONF040_TAG035;} //'Updated'
    public String getTAG012(){return System.Label.COMM001_TAG046;} //'Back To Setup Home'
    public String getTAG013(){return System.Label.COMM001_TAG047;} //'New'
    public String getTAG014(){return System.Label.COMM001_TAG048;} //'Edit'
    public String getTAG015(){return System.Label.COMM001_TAG049;} //'Delete'
    public String getTAG016(){return System.Label.COMM001_TAG050;} //'Please select atleast one process.'
    public String getTAG017(){return System.Label.COMM001_TAG052;} //'Record(s) Deleted'
    public String getTAG018(){return System.Label.COMM001_TAG057;} //'Are you sure?'
    public String getTAG019(){return System.Label.COMM001_TAG051;} //'Please select only one process.'
    public String getTAG020(){return System.Label.CONF040_TAG002;} //'Sent Today'
    public String getTAG021(){return System.Label.CONF040_TAG003;} //'Daily Avg'
    public String getTAG022(){return System.Label.CONF040_TAG004;} //'Recipients'
    public String getTAG023(){return System.Label.CONF040_TAG017;} //'ON'
    public String getTAG024(){return System.Label.CONF040_TAG018;} //'OFF'
    public String getTAG025(){return System.Label.CONF040_TAG040;} //'Alert List'
    public String getTAG026(){return System.Label.CONF040_TAG041;} //'Alert Logs'
}