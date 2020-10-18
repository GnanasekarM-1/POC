public with sharing class CONF_TriggerControl{
 /*****************************************************************************
 *                       Copyright (C) 2016 ServiceMax, Inc
 *                               All rights reserved
 *
 *****************************************************************************/

/** 
 * The CONF_TriggerControl is controller class to disbale apex trigger execution
 * org wide/based on user/based on profile.
 *
 * @author Nidhi
 * @version 46
 * @since 2019
 */

    public CONF_TriggerControl(){ 
        
    }
    
    @RemoteAction
    public static String JsrGetTRCProcessList(String requestStr){
        try{
            List<string> objectList = new List<string>{'Case','SVMXC__Installed_Product__c','SVMXC__Parts_Request__c','SVMXC__Product_Stock__c','SVMXC__RMA_Shipment_Line__c','SVMXC__RMA_Shipment_Order__c','SVMXC__Parts_Request_Line__c','SVMXC__Service_Contract__c','SVMXC__Service_Contract_Products__c','SVMXC__Warranty__c','SVMXC__Site__c','SVMXC__Stock_Adjustment__c','SVMXC__Stock_History__c','SVMXC__Stock_Transfer__c','SVMXC__Service_Order__c','SVMXC__Service_Order_Line__c','User'};//List of transactional objects
            //List<TriggerControlDataClass> wrapperList = new List<TriggerControlDataClass>();
            CONF_TriggerControl.TriggerControlDataClassList objTriggerControlDataClassList = new CONF_TriggerControl.TriggerControlDataClassList();
            //Added for BAC-5307
            List<String> listSalesforceActiveProfileIds = new List<String>();
            
            objTriggerControlDataClassList.profileList = new List<OptionList>();
            for(Profile p : [Select id,Name From Profile limit 30000]){// Limit Appiled on this query as part of Defect 047207
                objTriggerControlDataClassList.profileList.add(new OptionList(p.Id,p.name));
                listSalesforceActiveProfileIds.add(String.valueOf(p.Id));
            }
            //End for BAC-5307
            Map<String,SVMXC__SM_ServiceMax_Trigger_Control__c> triggerControlSettings = SVMXC__SM_ServiceMax_Trigger_Control__c.getall();
            List<OptionList> listActiveUsers = new List<OptionList>();
            Map<Id,String> mapUserIdName = new Map<Id,String>();
            Set<Id> setActiveUserIds = new Set<Id>();
            List<SVMXC__Config_Change_Detail__c> configChangeList = new List<SVMXC__Config_Change_Detail__c>();
            List<SVMXC__SM_ServiceMax_Trigger_Control__c> listCS = new List<SVMXC__SM_ServiceMax_Trigger_Control__c>();//list of custom setting to update
            Set<String> existingUserSet = new Set<String>();
            Set<String> existingUserToQuery = new Set<String>();
            
            for(User u : [Select id,Name From User where isActive=true limit 10000]){// Limit Appiled on this query as part of Defect 047207
                listActiveUsers.add(new OptionList(u.Id,u.name)); 
                setActiveUserIds.add(u.Id); 
                mapUserIdName.put(u.id,u.Name);             
            }
            
             //Changes done by Nidhi as part of Defect 047207
            for(String userId : existingUserSet){ //If the limited queried result does not include already existing users in custom setting, query them again.
                if(!setActiveUserIds.contains(userId)){
                    existingUserToQuery.add(userId);
                }
            }

            for(User u : [Select id,Name From User where isActive=true And Id In :existingUserToQuery]){
                listActiveUsers.add(new OptionList(u.Id,u.name)); 
                setActiveUserIds.add(u.Id); 
                mapUserIdName.put(u.id,u.Name);             
            }
            
            //Changes done by Nidhi as part of Defect 047207 Ends Here
            
            //Handle Deactivated Users on Load
            for(SVMXC__SM_ServiceMax_Trigger_Control__c setting : triggerControlSettings.values()){
                List<String> settingUserList = new List<String>();
                List<String> settingUserListNew = new List<String>();
                Boolean checkRecordModifiedOrNot = false; //Added for BAC-5307
                if(!String.isBlank(setting.SVMXC__SM_Value__c)){
                    settingUserList = setting.SVMXC__SM_Value__c.split(',');
                    settingUserListNew = setting.SVMXC__SM_Value__c.split(',');
                }
                System.debug('settingUserListNew '+settingUserListNew);
                System.debug('settingUserList '+settingUserList);
                for(String userId : settingUserList){
                    if(userId.startsWithIgnoreCase('005') && !setActiveUserIds.contains(userId)){ // userId.startsWithIgnoreCase('005') Added for BAC-5307
                        checkRecordModifiedOrNot = true; //Added for BAC-5307
                        Integer index = settingUserList.indexOf(userId);
                        if(settingUserListNew.size() == 1){ //Added for BAC-5307
                            settingUserListNew.remove(0);
                        }else{
                            settingUserListNew.remove(index);
                        }
                        //settingUserListNew.remove(index); // Commented for BAC-5307
                    }else if(userId.startsWithIgnoreCase('00e') && !listSalesforceActiveProfileIds.contains(userId)){ //Added for BAC-5307
                        checkRecordModifiedOrNot = true;
                        Integer index = settingUserList.indexOf(userId);
                        System.debug('settingUserListNew '+settingUserListNew);
                        System.debug('userId '+userId);
                        System.debug('index '+index);
                        if(settingUserListNew.size() == 1){ //Added for BAC-5307
                            settingUserListNew.remove(0);
                        }else{
                            settingUserListNew.remove(index);
                        }
                    }
                }
                String updatedUserIds = '';
                String updatedUserNames = '';
                for(String userId : settingUserListNew){
                    if(mapUserIdName.containsKey(userId)){
                        updatedUserNames = mapUserIdName.get(userId) + ',';
                    }
                }
                if(!String.isBlank(updatedUserNames)){
                    updatedUserNames.removeEnd(',');
                }               
                updatedUserIds = String.join(settingUserListNew,',');
                setting.SVMXC__SM_Value__c = updatedUserIds;
                listCS.add(new SVMXC__SM_ServiceMax_Trigger_Control__c(Name=setting.Name,SVMXC__SM_Value__c=updatedUserIds));
                
                if(checkRecordModifiedOrNot){ //Added for BAC-5307
                    //configChangeList.add(auditTrailUpdate(setting.Name,setting.Name,setting.SVMXC__SM_Type__c,updatedUserIds,setting.SVMXC__SM_Is_Enabled__c));
                    configChangeList.add(auditTrailUpdate(setting.Name,setting.Name,setting.SVMXC__SM_Type__c,updatedUserNames,setting.SVMXC__SM_Is_Enabled__c));
                }
                //configChangeList.add(auditTrailUpdate(setting.Name,setting.Name,setting.SVMXC__SM_Type__c,updatedUserIds,setting.SVMXC__SM_Is_Enabled__c)); // Commented for BAC-5307
            }
            
            //update the custom setting after removing configured deactivated users and capture the changes in audit trail
            if( COMM_SecurityUtils.getInstance().verifyFieldAccess( listCS, COMM_SecurityUtils.Access.Upsertable) ) {
                if(listCS.size()>0)
                    upsert listCS Name;
                if(configChangeList.size()>0)
                    insert configChangeList;
            } else {
                throw new COMM_SecurityUtils.SecurityAccessException(System.label.COMM001_TAG142);
            } 
            
            Map<String, Schema.SObjectType> globaldesc = Schema.getGlobalDescribe(); 
            //get details from custom setting
            for(String obj : objectList){
                TriggerControlDataClass wrapperInstance = new TriggerControlDataClass();            
                wrapperInstance.typeOptionsList = new List<OptionList>();
                if(obj == 'SVMXC__Service_Order__c' || obj == 'Case' || obj=='User'){
                    wrapperInstance.typeOptionsList.add(new OptionList('0',system.label.CONF005_TEXT135));
                    wrapperInstance.typeOptionsList.add(new OptionList('1',system.label.CONF005_TEXT134));
                    wrapperInstance.typeOptionsList.add(new OptionList('2',system.label.CONF005_TEXT136));
                }else{
                    wrapperInstance.typeOptionsList.add(new OptionList('0',system.label.CONF005_TEXT134));
                    wrapperInstance.typeOptionsList.add(new OptionList('1',system.label.CONF005_TEXT136));
                }
                
                //Get user settings from custom setting 
                if(!triggerControlSettings.isEmpty() && triggerControlSettings.containsKey(obj) && triggerControlSettings.get(obj)!=null){
                    wrapperInstance.objectLabel = globaldesc.get(obj).getDescribe().getLabel();
                    wrapperInstance.objectName = triggerControlSettings.get(obj).SVMXC__SM_Object_Name__c;
                    wrapperInstance.selectedType = triggerControlSettings.get(obj).SVMXC__SM_Type__c;
                    wrapperInstance.isEnabled = triggerControlSettings.get(obj).SVMXC__SM_Is_Enabled__c;
                    if(!String.isBlank(triggerControlSettings.get(obj).SVMXC__SM_Value__c)){
                        //Changes done by Nidhi as part of Defect 047207
                        List<String> selectedUserList = new List<String>();
                        selectedUserList = triggerControlSettings.get(obj).SVMXC__SM_Value__c.split(',');
                        if(selectedUserList.size() == 1 && !mapUserIdName.isEmpty() && mapUserIdName.containsKey(selectedUserList[0])){
                            wrapperInstance.selectedUsersName = new List<String>();
                            wrapperInstance.selectedUsersName.add(mapUserIdName.get(selectedUserList[0]));
                        }//Changes done by Nidhi as part of Defect 047207 Ends Here
                        wrapperInstance.selectedUsers = triggerControlSettings.get(obj).SVMXC__SM_Value__c.split(',');
                    }
                    objTriggerControlDataClassList.lstWrapClass.add(wrapperInstance);
                }                       
                else if(globaldesc.containsKey(obj)){ //Apply default settings
                    wrapperInstance.objectLabel = globaldesc.get(obj).getDescribe().getLabel();
                    wrapperInstance.objectName = globaldesc.get(obj).getDescribe().getName();
                    wrapperInstance.isEnabled = true;
                    objTriggerControlDataClassList.lstWrapClass.add(wrapperInstance);
                }
                
            }
              
            string str = JSON.serialize(objTriggerControlDataClassList.lstWrapClass);
            List<TriggerControlDataClass> wrapperList = (List<TriggerControlDataClass>)JSON.deserialize(str,List<TriggerControlDataClass>.class);
            objTriggerControlDataClassList.userList = new List<OptionList>();
            objTriggerControlDataClassList.userList = listActiveUsers;
            
            /*Commented for BAC-5307
            objTriggerControlDataClassList.profileList = new List<OptionList>();
            for(Profile p : [Select id,Name From Profile]){
                objTriggerControlDataClassList.profileList.add(new OptionList(p.Id,p.name));
            }
            */
            objTriggerControlDataClassList.customTags.add(new OptionList('CONF005_TEXT119',system.label.CONF005_TEXT119));
            objTriggerControlDataClassList.customTags.add(new OptionList('CONF006_TAG030',system.label.CONF006_TAG030));
            
            objTriggerControlDataClassList.customTags.add(new OptionList('COMM001_TAG046',system.label.COMM001_TAG046 ));
            objTriggerControlDataClassList.customTags.add(new OptionList('COMM001_TAG040',system.label.COMM001_TAG040 ));
            objTriggerControlDataClassList.customTags.add(new OptionList('CONF006_TAG065',system.label.CONF006_TAG065));
            
            objTriggerControlDataClassList.customTags.add(new OptionList('CONF001_TAG004',system.label.CONF001_TAG004 ));
            objTriggerControlDataClassList.customTags.add(new OptionList('CONF016_TAG068',system.label.CONF016_TAG068 ));
            objTriggerControlDataClassList.customTags.add(new OptionList('CONF005_TEXT138',system.label.CONF005_TEXT138));
            objTriggerControlDataClassList.customTags.add(new OptionList('CONF005_TEXT127',system.label.CONF005_TEXT127));
            objTriggerControlDataClassList.customTags.add(new OptionList('CONF005_TEXT128',system.label.CONF005_TEXT128));
            objTriggerControlDataClassList.customTags.add(new OptionList('CONF005_TEXT129',system.label.CONF005_TEXT129));
            objTriggerControlDataClassList.customTags.add(new OptionList('CONF005_TEXT130',system.label.CONF005_TEXT130));
            objTriggerControlDataClassList.customTags.add(new OptionList('CONF005_TEXT131',system.label.CONF005_TEXT131));
            objTriggerControlDataClassList.customTags.add(new OptionList('COMM001_TAG064',system.label.COMM001_TAG064));
            objTriggerControlDataClassList.customTags.add(new OptionList('CONF005_TEXT133',system.label.CONF005_TEXT133));
            objTriggerControlDataClassList.customTags.add(new OptionList('CONF015_TAG017',system.label.CONF015_TAG017));
            objTriggerControlDataClassList.customTags.add(new OptionList('CONF004_TAG016',system.label.CONF004_TAG016));            
            objTriggerControlDataClassList.customTags.add(new OptionList('CONF005_TEXT134',system.label.CONF005_TEXT134)); 
            objTriggerControlDataClassList.customTags.add(new OptionList('CONF005_TEXT132',system.label.CONF005_TEXT132)); 
            objTriggerControlDataClassList.customTags.add(new OptionList('CONF005_TEXT132',system.label.CONF005_TEXT132)); 
            objTriggerControlDataClassList.customTags.add(new OptionList('CONF005_TEXT135',system.label.CONF005_TEXT135));
            objTriggerControlDataClassList.customTags.add(new OptionList('CONF005_TEXT136',system.label.CONF005_TEXT136));
            objTriggerControlDataClassList.customTags.add(new OptionList('CONF005_TEXT137',system.label.CONF005_TEXT137));
            objTriggerControlDataClassList.customTags.add(new OptionList('COMM001_TAG119',system.label.COMM001_TAG119));
            objTriggerControlDataClassList.customTags.add(new OptionList('COMM001_TAG120',system.label.COMM001_TAG120));
            
            //Changes done by Nidhi as part of Defect 047207
            objTriggerControlDataClassList.customTags.add(new OptionList('COMM001_TAG005',system.label.COMM001_TAG005));            
            objTriggerControlDataClassList.customTags.add(new OptionList('COMM001_TAG006',system.label.COMM001_TAG006)); 
            objTriggerControlDataClassList.customTags.add(new OptionList('COMM001_TAG007',system.label.COMM001_TAG007)); 
            objTriggerControlDataClassList.customTags.add(new OptionList('COMM001_TAG008',system.label.COMM001_TAG008)); 
            objTriggerControlDataClassList.customTags.add(new OptionList('COMM001_TAG009',system.label.COMM001_TAG009));
            objTriggerControlDataClassList.customTags.add(new OptionList('COMM001_TAG010',system.label.COMM001_TAG010));
            objTriggerControlDataClassList.customTags.add(new OptionList('COMM002_TAG038',system.label.COMM002_TAG038));
            objTriggerControlDataClassList.customTags.add(new OptionList('COMM002_TAG040',system.label.COMM002_TAG040));
            objTriggerControlDataClassList.customTags.add(new OptionList('COMM002_TAG039',system.label.COMM002_TAG039)); //Changes done by Nidhi as part of Defect 047207 Ends Here 
            /* Commented for BAC-5315. UI is going to handle this
            String returnUrl='';
            if(UserInfo.getUiThemeDisplayed()=='Theme4d' || UserInfo.getUiThemeDisplayed()=='Theme4u'){
                returnUrl = '/lightning/n/SVMXC__ServiceMax_Setup';
            }else{
                returnUrl ='/apex/SVMXC__CONF_SetupHome';
            }
            System.debug('returnUrl '+returnUrl);
            System.debug('UserInfo.getUiThemeDisplayed() '+UserInfo.getUiThemeDisplayed());
            objTriggerControlDataClassList.customTags.add(new OptionList('url',returnUrl));
            */
            CONF_TriggerControl.FinalData responseData = new CONF_TriggerControl.FinalData();
            responseData.data = objTriggerControlDataClassList;
            return JSON.serialize(responseData);
        }catch(Exception ex){
            throw ex;
        }
    }
    
    //Changes done by Nidhi as part of Defect 047207
    @RemoteAction
    public static String JsrGetUserRecords(String requestStr){
        Map<String, Object> request = (Map<String, Object>)JSON.deserializeUntyped(requestStr);
        String searchKeyword = String.valueOf(request.get('value'));
        List<OptionList> listActiveUsers = new List<OptionList>();
        CONF_TriggerControl.TriggerControlDataClassList objTriggerControlDataClassList = new CONF_TriggerControl.TriggerControlDataClassList();
        try{
            for(User u : [Select id,Name From User where isActive=true And Name like :'%'+searchKeyword + '%' limit 10000]){
                listActiveUsers.add(new OptionList(u.Id,u.name)); 
            }
            objTriggerControlDataClassList.userList = listActiveUsers;
            CONF_TriggerControl.FinalData responseData = new CONF_TriggerControl.FinalData();
            responseData.data = objTriggerControlDataClassList;
            return JSON.serialize(responseData);
        }catch(Exception ex){
            throw ex;
        }
    }
    //Changes done by Nidhi as part of Defect 047207 Ends Here 

    @RemoteAction
    public static void JsrSaveTRCProcessList(String userData){
        JSONParser parser = JSON.createParser(userData);
        List<TriggerControlDataClass> wrapperList = new List<TriggerControlDataClass>();
        while (parser.nextToken() != null) {
            if (parser.getCurrentToken() == JSONToken.START_ARRAY) {
                while (parser.nextToken() != null) {
                    if (parser.getCurrentToken() == JSONToken.START_OBJECT) {                        
                        TriggerControlDataClass wrp = (TriggerControlDataClass)parser.readValueAs(TriggerControlDataClass.class);                
                        wrapperList.add(wrp);
                    }
                }
            }
        }

        Map<String,SVMXC__SM_ServiceMax_Trigger_Control__c> triggerControlSettings = SVMXC__SM_ServiceMax_Trigger_Control__c.getall();
        List<SVMXC__SM_ServiceMax_Trigger_Control__c> listCS = new List<SVMXC__SM_ServiceMax_Trigger_Control__c>();
        List<SVMXC__Config_Change_Detail__c> configChangeList = new List<SVMXC__Config_Change_Detail__c>();
        for(TriggerControlDataClass wp : wrapperList){
            if((wp.isEnabled == false) || (triggerControlSettings.containskey(wp.objectName))){
                string userIds = null;
                string userNames = null;
                if(wp.selectedUsers!=null && wp.selectedUsers.size()>0){
                    userIds = String.join(wp.selectedUsers, ',');
                }
                if(wp.selectedUsersName!=null && wp.selectedUsersName.size()>0){
                    userNames = String.join(wp.selectedUsersName, ',');
                }                
                SVMXC__SM_ServiceMax_Trigger_Control__c cs = new SVMXC__SM_ServiceMax_Trigger_Control__c(Name=wp.objectName,SVMXC__SM_Object_Name__c=wp.objectName,SVMXC__SM_Is_Enabled__c=wp.isEnabled,SVMXC__SM_Type__c=wp.selectedType,SVMXC__SM_Value__c = userIds);
                
                if(!triggerControlSettings.containsKey(wp.objectName) || (triggerControlSettings.containsKey(wp.objectName) && (triggerControlSettings.get(wp.objectName).SVMXC__SM_Is_Enabled__c!= cs.SVMXC__SM_Is_Enabled__c || triggerControlSettings.get(wp.objectName).SVMXC__SM_Type__c!= cs.SVMXC__SM_Type__c || triggerControlSettings.get(wp.objectName).SVMXC__SM_Value__c!= cs.SVMXC__SM_Value__c))){//Update only if any changes done on the page.              
                    listCS.add(cs);
                    //update the changes in config change detail object(Audit Trail Info)
                    //configChangeList.add(auditTrailUpdate(wp.objectLabel,wp.objectName,wp.selectedType,userIds,wp.isEnabled));
                    configChangeList.add(auditTrailUpdate(wp.objectLabel,wp.objectName,wp.selectedType,userNames,wp.isEnabled));
                }
            }
        }
        
        if( COMM_SecurityUtils.getInstance().verifyFieldAccess( listCS, COMM_SecurityUtils.Access.Upsertable) ) {
            if(listCS.size()>0)
                upsert listCS Name;
            if(configChangeList.size()>0)
                insert configChangeList;
        } else {
            throw new COMM_SecurityUtils.SecurityAccessException(System.label.COMM001_TAG142);
        } 
    }
    
    //update the changes in config change detail object(Audit Trail Info)
    public static SVMXC__Config_Change_Detail__c auditTrailUpdate(String objectLabel,String objectName,String selectedType,String userIds,Boolean isEnabled){
        SVMXC__Config_Change_Detail__c configChange= new SVMXC__Config_Change_Detail__c();           
        configChange.SVMXC__User__c = userInfo.getUserID();
        configChange.SVMXC__Date__c = datetime.now();
        configChange.SVMXC__Action_Type__c = 'Modified';
        configChange.SVMXC__Entity_Name__c = 'Trigger Control';
        configChange.SVMXC__Action__c = 'Modified Trigger Status for '+objectLabel+'. Check Additional Information.';
        String additionalInfo = '';
        if(!String.isBlank(objectName)){
            additionalInfo += objectName+':';
        }
        if(!String.isBlank(selectedType)){
            additionalInfo += selectedType+':';
        }
        if(!String.isBlank(userIds)){
            additionalInfo += userIds+':';
        }
        if(isEnabled!=null){
            additionalInfo += isEnabled;
        }
        configChange.SVMXC__Additional_information__c = additionalInfo;
        configChange.SVMXC__Application__c = 'Browser';
        return configChange;
    }
    
    public class TriggerControlDataClass{
        public string objectLabel{get;set;}
        public string objectName{get;set;}
        public string selectedType{get;set;}
        public List<OptionList> typeOptionsList{get;set;}
        public List<string> selectedUsers{get;set;}
        public List<string> selectedUsersName{get;set;}
        public boolean isEnabled{get;set;}

        public TriggerControlDataClass(){
            
        }

    }
    public class OptionList{
        public String id;
        public String name;
        
        public OptionList(String Id,String Name){
            this.id = Id;
            this.name = Name;
        }
    }
    public class TriggerControlDataClassList{
        public List<CONF_TriggerControl.TriggerControlDataClass> lstWrapClass= new List<CONF_TriggerControl.TriggerControlDataClass>();
        public List<OptionList> userList = new List<OptionList>();
        public List<OptionList> profileList = new List<OptionList>();
        public List<OptionList> customTags = new List<OptionList>();
    }
    public class FinalData{
        public CONF_TriggerControl.TriggerControlDataClassList data = new CONF_TriggerControl.TriggerControlDataClassList();
        public Boolean success = true;
    }
    
    //This method is called from all the managed packaged triggers which can be bypassed.
    public static Boolean isTriggerEnabled(String objectName, String userId, String profileId){
        Boolean isEnabled = true;
        try{
            SVMXC__SM_ServiceMax_Trigger_Control__c triggerProperty = SVMXC__SM_ServiceMax_Trigger_Control__c.getInstance(objectName);
            if(triggerProperty != null && !triggerProperty.SVMXC__SM_Is_Enabled__c){
                if(triggerProperty.SVMXC__SM_Type__c.equalsIgnoreCase(system.label.CONF005_TEXT135)){
                    isEnabled = false;  
                }
                else{
                    List<String> listOfIds = new List<String>();
                    if(!String.isBlank(triggerProperty.SVMXC__SM_Value__c)){
                        listOfIds = triggerProperty.SVMXC__SM_Value__c.split(',');
                    }
                    if(listOfIds.contains(userId) || listOfIds.contains(profileId)){
                        isEnabled = false; 
                    } 
                }
            }else{
                    isEnabled = true; 
            }
        }
        catch (Exception e){
          System.debug('Exception: ' + e.getMessage());
        }
        return isEnabled;
    }
}