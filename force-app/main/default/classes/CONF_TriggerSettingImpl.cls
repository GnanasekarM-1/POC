public with sharing class CONF_TriggerSettingImpl {
    static final string STATUS_DISABLED ='DISABLED';
    static final string STATUS_ENABLED ='ENABLED';
     
    
     public class ObjectInfo {
        public String apiname;
        public String label;
        public ObjectInfo() {}
     }
     
     public class triggerEnableDisable{
         public String triggername; 
         public Boolean isenabled; 
         public triggerEnableDisable (){
         }
     }
     
     public class TriggerSetting_Request {
         public string objectname; 
         public List<triggerEnableDisable> triggersettingvalue; 
         public TriggerSetting_Request(){
         }
     }
     
     public class TriggerSetting_Response {
         public Boolean success ;
         public Boolean warning ;
         public List<ObjectInfo> objectlist;
         public List<triggerEnableDisable> triggersettingvalue; 
         public List<String> messagelist ;
         public TriggerSetting_Response(){
             messagelist = new List<String>();
         }
     }
    
     public TriggerSetting_Response getObjectName(TriggerSetting_Request request) {
        TriggerSetting_Response triggerSettingRes = new TriggerSetting_Response();
         
        List<ObjectInfo> listObjectName = new List<ObjectInfo>();
        try{
            Map <String, Schema.SObjectType> mapOrgObjectName = Schema.getGlobalDescribe();  
            // For now we give only Case Object
            for(String gd : mapOrgObjectName.keySet()){
                DescribeSObjectResult objectType = mapOrgObjectName.get(gd).getDescribe(); 
                if(objectType.getName().equalsIgnoreCase('Case') || objectType.getName().equalsIgnoreCase('SVMXC__Service_Order__c')){ //Added work order condition for fixing defect 044689
                    ObjectInfo objEle = new ObjectInfo();
                    objEle.apiname = objectType.getName(); 
                    objEle.label = objectType.getLabel(); 
                    listObjectName.add(objEle);    
                }
            }
            triggerSettingRes.success = true; 
            triggerSettingRes.objectlist = listObjectName   ;  
        }
        catch(Exception e){
            triggerSettingRes.success = false;
            triggerSettingRes.messageList = new List<String>();
            triggerSettingRes.messageList.add(e.getMessage());
        }
        return triggerSettingRes;
     }
     
     public TriggerSetting_Response getObjectTrigger(TriggerSetting_Request request) {
        TriggerSetting_Response triggerSettingRes = new TriggerSetting_Response();
        
        // Get all triggers associated with the object passed
        try{
            List<ApexTrigger> listapextrigger = [Select Name from ApexTrigger WHERE NamespacePrefix = 'SVMXC' AND TableEnumOrId =: request.objectname ]; //SDL-SVMX-FLS-NOT-ENFORCED-META-DATA 
                                                        
            List<triggerEnableDisable>  triggersettingvalue = new List<triggerEnableDisable> ();
            
            if(listapextrigger != null && listapextrigger.size() > 0){
                // For each trigger check if Property Elements are set? 
                // If yes, retrieve the value...
                // If No, default value for trigger is true
                // For Case, we are using PELE528
                //for (ApexTrigger triggerObj: listapextrigger){
                    SVMXC__ServiceMax_Property_Elements__c triggerProperty; //Added for fixing defect 044689
                    if(request.objectname != null && request.objectname.equalsIgnoreCase('Case')){ //Added if condition for fixing defect 044689
                        triggerProperty = SVMXC__ServiceMax_Property_Elements__c.getInstance('PELE528');
                        if(triggerProperty == null){
                            triggerProperty = new SVMXC__ServiceMax_Property_Elements__c();
                            triggerProperty.Name = 'PELE528';
                            triggerProperty.SVMXC__Element_Type__c = 'Packaged Trigger';
                            triggerProperty.SVMXC__Property_Key__c = 'SVMXC_CASE_Trigger1';
                            triggerProperty.SVMXC__Element_Value__c = STATUS_ENABLED;  
                        }
                    }
                    //-------Start--------Added else if condition for fixing defect 044689
                    else if(request.objectname != null && request.objectname.equalsIgnoreCase('SVMXC__Service_Order__c')){
                        triggerProperty = SVMXC__ServiceMax_Property_Elements__c.getInstance('PELE565');
                        if(triggerProperty == null){
                            triggerProperty = new SVMXC__ServiceMax_Property_Elements__c();
                            triggerProperty.Name = 'PELE565';
                            triggerProperty.SVMXC__Element_Type__c = 'Packaged Trigger';
                            triggerProperty.SVMXC__Property_Key__c = 'SVMXC_WORD_Trigger1';
                            triggerProperty.SVMXC__Element_Value__c = STATUS_ENABLED;  
                        }
                    }
                    //-------End--------Added else if condition for fixing defect 044689
                    
                    triggerEnableDisable propertySetValue = new triggerEnableDisable(); 
                    propertySetValue.triggername = triggerProperty.SVMXC__Property_Key__c; 
                    if(triggerProperty != null){
                        propertySetValue.isenabled = triggerProperty.SVMXC__Element_Value__c.equalsIgnoreCase(STATUS_DISABLED)? false : true; 
                    }
                    else{
                        propertySetValue.isenabled = true;
                    }
                    triggersettingvalue.add(propertySetValue); 
                //}
                
                triggerSettingRes.success = true;
                triggerSettingRes.triggersettingvalue = triggersettingvalue;
                
            }
            else{
                triggerSettingRes.success = false;
                triggerSettingRes.messageList = new List<String>();
                triggerSettingRes.messageList.add(System.Label.CONF043_TAG009);
            }  
        }
        catch(Exception e){
            triggerSettingRes.success = false;
            triggerSettingRes.messageList = new List<String>();
            triggerSettingRes.messageList.add(e.getMessage());
        }                                          
        
        return triggerSettingRes;
     }
     
     public TriggerSetting_Response saveTriggerSetting(TriggerSetting_Request request) {
         TriggerSetting_Response triggerSettingRes = new TriggerSetting_Response();
        
         try{
             if (request.triggersettingvalue != null && request.triggersettingvalue.size() > 0){
                 // For now we are enabling/ disabling only case trigger
                 // For Case, property key element is PELE528 
                 Map <String, SVMXC__ServiceMax_Property_Elements__c> mapPropertyEle = new Map <String,SVMXC__ServiceMax_Property_Elements__c>();
                 for (triggerEnableDisable triggerIns: request.triggersettingvalue){
                    
                    if(triggerIns.triggername.equalsIgnoreCase('SVMXC_CASE_Trigger1')){ //Added if condition for fixing defect 044689
                        SVMXC__ServiceMax_Property_Elements__c triggerProperty = SVMXC__ServiceMax_Property_Elements__c.getInstance('PELE528');
                        if(triggerProperty != null){
                            triggerProperty.SVMXC__Element_Value__c = triggerIns.isenabled? STATUS_ENABLED: STATUS_DISABLED;
                        }
                        else{
                            triggerProperty = new SVMXC__ServiceMax_Property_Elements__c();
                            triggerProperty.Name = 'PELE528';
                            triggerProperty.SVMXC__Element_Type__c = 'Packaged Trigger';
                            triggerProperty.SVMXC__Property_Key__c = 'SVMXC_CASE_Trigger1';
                            triggerProperty.SVMXC__Element_Value__c = triggerIns.isenabled? STATUS_ENABLED: STATUS_DISABLED;
                        }
                        mapPropertyEle.put('PELE528', triggerProperty);
                    }
                    //-------Start--------Added else if condition for fixing defect 044689
                    else if(triggerIns.triggername.equalsIgnoreCase('SVMXC_WORD_Trigger1')){
                        SVMXC__ServiceMax_Property_Elements__c triggerProperty = SVMXC__ServiceMax_Property_Elements__c.getInstance('PELE565');
                        if(triggerProperty != null){
                            triggerProperty.SVMXC__Element_Value__c = triggerIns.isenabled? STATUS_ENABLED: STATUS_DISABLED;
                        }
                        else{
                            triggerProperty = new SVMXC__ServiceMax_Property_Elements__c();
                            triggerProperty.Name = 'PELE565';
                            triggerProperty.SVMXC__Element_Type__c = 'Packaged Trigger';
                            triggerProperty.SVMXC__Property_Key__c = 'SVMXC_WORD_Trigger1';
                            triggerProperty.SVMXC__Element_Value__c = triggerIns.isenabled? STATUS_ENABLED: STATUS_DISABLED;    
                        }
                        mapPropertyEle.put('PELE565', triggerProperty);
                    }
                    //-------End----------Added else if condition for fixing defect 044689
                 }
                 
                 if( COMM_SecurityUtils.getInstance().verifyFieldAccess( mapPropertyEle.values(), COMM_SecurityUtils.Access.Upsertable) ) {
                     upsert mapPropertyEle.values();
                 } else {
                     throw new COMM_SecurityUtils.SecurityAccessException(System.label.COMM001_TAG142);
                 }    
             }
             
             triggerSettingRes.success = true;
             triggerSettingRes.messageList = new List<String>();
             triggerSettingRes.messageList.add( System.Label.CONF043_TAG010); 
         }
         catch(Exception e){
            triggerSettingRes.success = false;
            triggerSettingRes.messageList = new List<String>();
            triggerSettingRes.messageList.add(e.getMessage()); 
         }
         return triggerSettingRes;
     }
    
    // BAC-2699 - Implement Case_Trigger1
    // Input param - trigger Name and Setting Name
    public static boolean isTriggerEnabled(String triggerName, String settingName) { 
        Boolean isEnabled = true;
        try{
            SVMXC__ServiceMax_Property_Elements__c triggerProperty = SVMXC__ServiceMax_Property_Elements__c.getInstance(settingName);
            if(triggerProperty != null && triggerProperty.SVMXC__Property_Key__c.equalsIgnoreCase(triggerName) ){
                if(triggerProperty.SVMXC__Element_Value__c.equalsIgnoreCase(STATUS_DISABLED)){
                    isEnabled = false;  
                }
                else {
                    isEnabled = true; 
                }
            }
        }
        catch (Exception e){
          System.debug('Exception: ' + e.getMessage());
        }
        return isEnabled;
    }
   
}