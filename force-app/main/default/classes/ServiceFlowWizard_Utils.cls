/* Security Scanned */
public with sharing class ServiceFlowWizard_Utils{

/* Inv process return Maps declaration -Starts here */
    Map<String,List<SVMXC__ServiceMax_Processes__c>> Map_ObjNameInventoryActions = new Map<String,List<SVMXC__ServiceMax_Processes__c>>();//All Inv Actions map
    Map<String,List<SVMXC__ServiceMax_Processes__c>> Map_ObjNameInventoryAction = new Map<String,List<SVMXC__ServiceMax_Processes__c>>();//One Inv Action map
/* Inv process return Maps declaration - Ends here */

/* Sfm Actions return Maps - declaration - Starts here */
    Map<String,List<SVMXC__ServiceMax_Processes__c>> Map_ObjNameSfmActions = new Map<String,List<SVMXC__ServiceMax_Processes__c>>();//All Sfm Actions map
    Map<String,List<SVMXC__ServiceMax_Processes__c>> Map_ObjNameSfmAction = new Map<String,List<SVMXC__ServiceMax_Processes__c>>();//One Sfm Action map
/* Sfm Actions return Maps - declaration - Ends here */

/* Sfm Output Doc Actions return Maps - declaration - Starts here */
    Map<String,List<SVMXC__ServiceMax_Processes__c>> MapObjNameSfmOutputDocActions = new Map<String,List<SVMXC__ServiceMax_Processes__c>>();//All Sfm Output Doc Actions map
    Map<String,List<SVMXC__ServiceMax_Processes__c>> MapObjNameSfmOutputDocAction = new Map<String,List<SVMXC__ServiceMax_Processes__c>>();//One Sfm Output Doc Action map
/* Sfm Output Doc Actions return Maps - declaration - Ends here */

/* Sfm Actions return Maps - declaration - Starts here */
    Map<String,List<SVMXC__ServiceMax_Processes__c>> Map_ObjNameSfmBackgroundActions = new Map<String,List<SVMXC__ServiceMax_Processes__c>>();//All Sfm Actions map
    Map<String,List<SVMXC__ServiceMax_Processes__c>> Map_ObjNameSfmBackgroundAction = new Map<String,List<SVMXC__ServiceMax_Processes__c>>();//One Sfm Action map
/* Sfm Actions return Maps - declaration - Ends here */

/* Other Actions return Maps - declaration - Starts here */
    Map<String,List<SVMXC__ServiceMax_Processes__c>> Map_ObjNameOtherActions = new Map<String,List<SVMXC__ServiceMax_Processes__c>>();//All Sfm Actions map
    Map<String,List<SVMXC__ServiceMax_Processes__c>> Map_ObjNameOtherAction = new Map<String,List<SVMXC__ServiceMax_Processes__c>>();//One Sfm Action map
/* Other Actions return Maps - declaration - Ends here */

/* Receiving process / Delivery return Maps - declaration - Starts here */
    Map<String,List<SVMXC__ServiceMax_Processes__c>> Map_ObjNameReceive_DeliveryAction = new Map<String,List<SVMXC__ServiceMax_Processes__c>>();//One Sfm Action map
/* Receiving process / Delivery return Maps - declaration - Ends here */

/* Shipping process / picking return Maps - declaration - Starts here */
    Map<String,List<SVMXC__ServiceMax_Processes__c>> Map_ObjNamePicking_ShippingAction = new Map<String,List<SVMXC__ServiceMax_Processes__c>>();//One Sfm Action map
/* Shipping process / picking return Maps - declaration - Ends here */

/* Shipping process / picking return Maps - declaration - Starts here */
    Map<String,List<SVMXC__ServiceMax_Processes__c>> Map_InitiateReturnAction = new Map<String,List<SVMXC__ServiceMax_Processes__c>>();//One Sfm Action map
/* Shipping process / picking return Maps - declaration - Ends here */

/* Fulfillment process Maps - declaration - Starts here */
    Map<String,List<SVMXC__ServiceMax_Processes__c>> Map_FulfillmentProcessAction = new Map<String,List<SVMXC__ServiceMax_Processes__c>>();//One Sfm Action map
/* Fulfillment process Maps - declaration - Ends here */

/* Checklist Actions return Maps - declaration - Starts here */
    Map<String,List<SVMXC__ServiceMax_Processes__c>> MapObjNameChecklistActions = new Map<String,List<SVMXC__ServiceMax_Processes__c>>();//All Sfm Output Doc Actions map
    Map<String,List<SVMXC__ServiceMax_Processes__c>> MapObjNameChecklistAction = new Map<String,List<SVMXC__ServiceMax_Processes__c>>();//One Sfm Output Doc Action map
/* Checklist Actions return Maps - declaration - Ends here */

    //Method to Retrieve  the inventory processes (Inventory actions) for an object
    public Map<String,List<SVMXC__ServiceMax_Processes__c>> SVMX_GetInventoryActions(String ObjName){
        Map_ObjNameInventoryActions.clear();
        Map_ObjNameInventoryAction.clear();
        map<String,SVMXC__ServiceMax_Processes__c> mapInvProIdInvProRecord = new map<String,SVMXC__ServiceMax_Processes__c>();
        //Added SVMXC__Purpose__c for BAC-5190
        String QryStr = 'Select id, Name, SVMXC__Purpose__c, SVMXC__Custom_Action_Type__c, SVMXC__Submodule__r.SVMXC__SubmoduleID__c, SVMXC__Module__c, SVMXC__Module__r.SVMXC__ModuleId__c,SVMXC__Description__c,SVMXC__ProcessID__c,SVMXC__Submodule__c,SVMXC__IsStandard__c, SVMXC__Name__c from SVMXC__ServiceMax_Processes__c where recordtype.Name = \'Inventory Process\'';
        List<SVMXC__ServiceMax_Processes__c> InventoryProcesses = new List<SVMXC__ServiceMax_Processes__c>();
        
        InventoryProcesses = Database.query(QryStr); //SDL-SVMX-FLS-NOT-ENFORCED-META-DATA
        
        //system.debug('nnzzzz1'+InventoryProcesses);
        List<String> lstUniqueSettingKeys = new List<String>();
        for(SVMXC__ServiceMax_Processes__c InvProcessRec :InventoryProcesses){
            if( InvProcessRec.SVMXC__ProcessID__c != null && InvProcessRec.SVMXC__ProcessID__c != '' ){
                lstUniqueSettingKeys.add(InvProcessRec.SVMXC__ProcessID__c + '_SET025' );
                mapInvProIdInvProRecord.put(InvProcessRec.SVMXC__ProcessID__c ,InvProcessRec);
            }   
        }
        system.debug('lstUniqueSettingKeys'+lstUniqueSettingKeys);
        system.debug('mapInvProIdInvProRecord'+mapInvProIdInvProRecord);
        Map<String,String> mapUniqueIdObjName = new Map<String,String>();
        COMM_Utils_ManageSettings settingUtilsObj = new COMM_Utils_ManageSettings();
        mapUniqueIdObjName = settingUtilsObj.SVMX_getGlobalSettingList(lstUniqueSettingKeys);
        system.debug('mapUniqueIdObjName'+mapUniqueIdObjName);
        List<SVMXC__ServiceMax_Processes__c> lstInvProcessRecs = new List<SVMXC__ServiceMax_Processes__c>();
        //Loop through the objname unique list and build the result with the help of map
        if(ObjName != 'ALL'){
            set<String> setMatchedInvProId = new set<String>();
            for(String strUniqueId : mapUniqueIdObjName.keyset()){
                if(mapUniqueIdObjName.get(strUniqueId).equalsIgnoreCase(ObjName)){
                    setMatchedInvProId.add(strUniqueId.split('_SET025')[0]);
                }
            }
            for(SVMXC__ServiceMax_Processes__c InvProcessRec :InventoryProcesses){
                if(InvProcessRec.SVMXC__ProcessID__c != null && setMatchedInvProId.contains(InvProcessRec.SVMXC__ProcessID__c)){
                    if(!Map_ObjNameInventoryAction.containskey(ObjName))
                        Map_ObjNameInventoryAction.put(ObjName,new list<SVMXC__ServiceMax_Processes__c>());
                    Map_ObjNameInventoryAction.get(ObjName).add(InvProcessRec); 
                }
            }
        }
        else{
            map<String,list<String>> mapObjAPINameInvProIdList  = new map<String,list<String>>();
            for(String strKey  : mapUniqueIdObjName.keyset()){
                string strInvProId = strKey.split('_SET025')[0];
                String strObjectName = mapUniqueIdObjName.get(strKey);
                if(!mapObjAPINameInvProIdList.containsKey(strObjectName))
                    mapObjAPINameInvProIdList.put(strObjectName,new list<String>());
                mapObjAPINameInvProIdList.get(strObjectName).add(strInvProId);  
            }
            system.debug('mapObjAPINameInvProIdList'+mapObjAPINameInvProIdList);
            for(String strKey : mapObjAPINameInvProIdList.keyset()){
                String strObjectName = strKey;
                for(String strInvProId : mapObjAPINameInvProIdList.get(strObjectName)){
                    if(!Map_ObjNameInventoryAction.containskey(strObjectName))
                        Map_ObjNameInventoryAction.put(strObjectName,new list<SVMXC__ServiceMax_Processes__c>());
                    if(mapInvProIdInvProRecord.containskey(strInvProId)){
                        Map_ObjNameInventoryAction.get(strObjectName).add(mapInvProIdInvProRecord.get(strInvProId));    
                    }   
                }
            }
        }
        return Map_ObjNameInventoryAction;
    }

//Retrieve sfm actions and background execution process
public Map<String,List<SVMXC__ServiceMax_Processes__c>> SVMX_GetSFMActions(String ObjName){
    Map_ObjNameSfmActions.clear();
    Map_ObjNameSfmAction.clear();
    Map<String,SVMXC__ServiceMax_Processes__c> TempSFMMap = new Map<String,SVMXC__ServiceMax_Processes__c>();
    String QryStr = 'Select id, Name, SVMXC__Name__c, SVMXC__Custom_Action_Type__c, SVMXC__Description__c, SVMXC__ProcessID__c,SVMXC__Purpose__c from SVMXC__ServiceMax_Processes__c where recordtype.Name = \'Target Manager\'';
    List<SVMXC__ServiceMax_Processes__c> lstSfmProcess = new List<SVMXC__ServiceMax_Processes__c>();
    List<SVMXC__ServiceMax_Processes__c> lstSfmProcess_SOQL1 = new List<SVMXC__ServiceMax_Processes__c>();
    List<SVMXC__ServiceMax_Processes__c> lstSfmProcess_SOQL2 = new List<SVMXC__ServiceMax_Processes__c>();
    lstSfmProcess = Database.query(QryStr); //SDL-SVMX-FLS-NOT-ENFORCED-META-DATA
    system.debug('nnzzzz2'+lstSfmProcess);
    TempSFMMap.putAll(lstSfmProcess);
    
    //This is commented to consume less SOQL as part of BAC-3259
    //List<String> LstTargetManagerRecId_SOQL1 = new List<String>();
    //List<String> LstTargetManagerRecId_SOQL2 = new List<String>();

    //Added for consuming less SOQL for fetching process node record as part of BAC-3259
    Set<String> LstTargetManagerRecId_SOQL1 = new Set<String>();
    Set<String> LstTargetManagerRecId_SOQL2 = new Set<String>();
    
    for(SVMXC__ServiceMax_Processes__c SfmActionRec :lstSfmProcess)
    {
        if(SfmActionRec.SVMXC__Purpose__c == 'STANDALONE EDIT' || SfmActionRec.SVMXC__Purpose__c == 'STANDALONE CREATE')
            LstTargetManagerRecId_SOQL1.add(SfmActionRec.Id);
        else if(SfmActionRec.SVMXC__Purpose__c == 'SOURCE TO TARGET CHILD' || SfmActionRec.SVMXC__Purpose__c == 'SOURCE TO TARGET ALL')
            LstTargetManagerRecId_SOQL2.add(SfmActionRec.Id);
    }

    //This is commented to consume less SOQL as part of BAC-3259
    //lstSfmProcess_SOQL1 = Database.query('Select Id, SVMXC__Name__c, SVMXC__Description__c, SVMXC__ProcessID__c, SVMXC__Submodule__c, SVMXC__Process__c, SVMXC__Source_Object_Name__c from SVMXC__ServiceMax_Processes__c where recordtype.Name = \'Process Node Objects\' and SVMXC__Process__c IN: LstTargetManagerRecId_SOQL1 and SVMXC__Type__c  = \'TARGET\'');
    //lstSfmProcess_SOQL2 = Database.query('Select Id, SVMXC__Name__c, SVMXC__Description__c, SVMXC__ProcessID__c, SVMXC__Submodule__c, SVMXC__Process__c, SVMXC__Source_Object_Name__c from SVMXC__ServiceMax_Processes__c where recordtype.Name = \'Process Node Objects\' and SVMXC__Process__c IN: LstTargetManagerRecId_SOQL2 and SVMXC__Type__c  = \'SOURCE\'');

    //Added for consuming less SOQL for fetching process node record as part of BAC-3259
    
    List<SVMXC__ServiceMax_Processes__c> lstProcessNodeRecords = [SELECT Id, SVMXC__Name__c, SVMXC__Description__c, SVMXC__ProcessID__c, SVMXC__Submodule__c, SVMXC__Process__c, SVMXC__Source_Object_Name__c, SVMXC__Type__c FROM SVMXC__ServiceMax_Processes__c WHERE Recordtype.Name = 'Process Node Objects' AND ((SVMXC__Process__c IN: LstTargetManagerRecId_SOQL1 AND SVMXC__Type__c  = 'TARGET') OR (SVMXC__Process__c IN: LstTargetManagerRecId_SOQL2 AND SVMXC__Type__c  = 'SOURCE'))]; //SDL-SVMX-FLS-NOT-ENFORCED-META-DATA
    for(SVMXC__ServiceMax_Processes__c objProcessNode : lstProcessNodeRecords){
        if(LstTargetManagerRecId_SOQL1.contains(objProcessNode.SVMXC__Process__c) && objProcessNode.SVMXC__Type__c.equalsIgnoreCase('TARGET')){
            lstSfmProcess_SOQL1.add(objProcessNode);
        }
        else if(LstTargetManagerRecId_SOQL2.contains(objProcessNode.SVMXC__Process__c) && objProcessNode.SVMXC__Type__c.equalsIgnoreCase('SOURCE')){
            lstSfmProcess_SOQL2.add(objProcessNode);
        }
    }
    lstProcessNodeRecords.clear();


    //List 1 iteration 
    for(SVMXC__ServiceMax_Processes__c SfmActionRec: lstSfmProcess_SOQL1)
    {
        if(SfmActionRec.SVMXC__Source_Object_Name__c != null && Map_ObjNameSfmActions.ContainsKey(SfmActionRec.SVMXC__Source_Object_Name__c))
        {
            List<SVMXC__ServiceMax_Processes__c> TempSfmActionLst = new List<SVMXC__ServiceMax_Processes__c>();
            //TempSfmActionLst = (Map_ObjNameSfmActions.get(SfmActionRec.SVMXC__Source_Object_Name__c));
            TempSfmActionLst.addAll((Map_ObjNameSfmActions.get(SfmActionRec.SVMXC__Source_Object_Name__c)));
            if(SfmActionRec.SVMXC__Process__c != null)
                TempSfmActionLst.add(TempSFMMap.get(SfmActionRec.SVMXC__Process__c));
            Map_ObjNameSfmActions.put(SfmActionRec.SVMXC__Source_Object_Name__c, TempSfmActionLst);
        }
        else if(SfmActionRec.SVMXC__Source_Object_Name__c != null && !(Map_ObjNameSfmActions.ContainsKey(SfmActionRec.SVMXC__Source_Object_Name__c)))
        {
            Map_ObjNameSfmActions.put(SfmActionRec.SVMXC__Source_Object_Name__c, (new List<SVMXC__ServiceMax_Processes__c>()));
            if(SfmActionRec.SVMXC__Process__c != null)
                (Map_ObjNameSfmActions.get(SfmActionRec.SVMXC__Source_Object_Name__c)).add(TempSFMMap.get(SfmActionRec.SVMXC__Process__c));
        }
    }
    //List 2 iteration
    for(SVMXC__ServiceMax_Processes__c SfmActionRec: lstSfmProcess_SOQL2)
    {
        if(SfmActionRec.SVMXC__Source_Object_Name__c != null && Map_ObjNameSfmActions.ContainsKey(SfmActionRec.SVMXC__Source_Object_Name__c))
        {
            List<SVMXC__ServiceMax_Processes__c> TempSfmActionLst = new List<SVMXC__ServiceMax_Processes__c>();
            //TempSfmActionLst = (Map_ObjNameSfmActions.get(SfmActionRec.SVMXC__Source_Object_Name__c));
            TempSfmActionLst.addAll((Map_ObjNameSfmActions.get(SfmActionRec.SVMXC__Source_Object_Name__c)));
            if(SfmActionRec.SVMXC__Process__c != null)
                TempSfmActionLst.add(TempSFMMap.get(SfmActionRec.SVMXC__Process__c));
            Map_ObjNameSfmActions.put(SfmActionRec.SVMXC__Source_Object_Name__c, TempSfmActionLst);
        }
        else if(SfmActionRec.SVMXC__Source_Object_Name__c != null && !(Map_ObjNameSfmActions.ContainsKey(SfmActionRec.SVMXC__Source_Object_Name__c)))
        {
            Map_ObjNameSfmActions.put(SfmActionRec.SVMXC__Source_Object_Name__c, (new List<SVMXC__ServiceMax_Processes__c>()));
            if(SfmActionRec.SVMXC__Process__c != null)
                (Map_ObjNameSfmActions.get(SfmActionRec.SVMXC__Source_Object_Name__c)).add(TempSFMMap.get(SfmActionRec.SVMXC__Process__c));
        }
    }
    
    if( ObjName!= null && ObjName.toUpperCase() == 'ALL' )
        return Map_ObjNameSfmActions;
    else
        if(  ObjName!= null && Map_ObjNameSfmActions != null && Map_ObjNameSfmActions.get(ObjName) != null)
        {
            Map_ObjNameSfmAction.put(ObjName, Map_ObjNameSfmActions.get(ObjName));
            return Map_ObjNameSfmAction;
        }
        else
            return null;
}
//Retrieve sfm actions and background execution process
public Map<String,List<SVMXC__ServiceMax_Processes__c>> SVMX_GetSFMBackgroundActions(String ObjName){
    Map_ObjNameSfmBackgroundActions.clear();
    Map_ObjNameSfmBackgroundAction.clear();
    Map<String,SVMXC__ServiceMax_Processes__c> TempSFMMap = new Map<String,SVMXC__ServiceMax_Processes__c>();
    String QryStr = 'Select id, Name, SVMXC__Name__c, SVMXC__Custom_Action_Type__c, SVMXC__Description__c, SVMXC__ProcessID__c,SVMXC__Purpose__c from SVMXC__ServiceMax_Processes__c where recordtype.Name = \'Target Manager\'';
    List<SVMXC__ServiceMax_Processes__c> lstSfmProcess = new List<SVMXC__ServiceMax_Processes__c>();
    List<SVMXC__ServiceMax_Processes__c> lstSfmProcess_SOQL1 = new List<SVMXC__ServiceMax_Processes__c>();
    List<SVMXC__ServiceMax_Processes__c> lstSfmProcess_SOQL2 = new List<SVMXC__ServiceMax_Processes__c>();
    lstSfmProcess = Database.query(QryStr);
    system.debug('nnzzzz2'+lstSfmProcess);
    TempSFMMap.putAll(lstSfmProcess);
    
    //This is commented to consume less SOQL as part of BAC-3259
    //List<String> LstTargetManagerRecId_SOQL1 = new List<String>();
    //List<String> LstTargetManagerRecId_SOQL2 = new List<String>();

    //Added for consuming less SOQL for fetching process node record as part of BAC-3259
    Set<String> LstTargetManagerRecId_SOQL1 = new Set<String>();
    Set<String> LstTargetManagerRecId_SOQL2 = new Set<String>();
    
    for(SVMXC__ServiceMax_Processes__c SfmActionRec :lstSfmProcess)
    {
        if(SfmActionRec.SVMXC__Purpose__c == 'STANDALONE CREATE')
            LstTargetManagerRecId_SOQL1.add(SfmActionRec.Id);
        if(SfmActionRec.SVMXC__Purpose__c == 'SOURCE TO TARGET CHILD' || SfmActionRec.SVMXC__Purpose__c == 'SOURCE TO TARGET ALL')
            LstTargetManagerRecId_SOQL2.add(SfmActionRec.Id);
    }

    //This is commented to consume less SOQL as part of BAC-3259
    //lstSfmProcess_SOQL1 = Database.query('Select Id, SVMXC__Name__c, SVMXC__Description__c, SVMXC__ProcessID__c, SVMXC__Submodule__c, SVMXC__Process__c, SVMXC__Source_Object_Name__c from SVMXC__ServiceMax_Processes__c where recordtype.Name = \'Process Node Objects\' and SVMXC__Process__c IN: LstTargetManagerRecId_SOQL1 and SVMXC__Type__c  = \'TARGET\'');
    //lstSfmProcess_SOQL2 = Database.query('Select Id, SVMXC__Name__c, SVMXC__Description__c, SVMXC__ProcessID__c, SVMXC__Submodule__c, SVMXC__Process__c, SVMXC__Source_Object_Name__c from SVMXC__ServiceMax_Processes__c where recordtype.Name = \'Process Node Objects\' and SVMXC__Process__c IN: LstTargetManagerRecId_SOQL2 and SVMXC__Type__c  = \'SOURCE\'');

    //Added for consuming less SOQL for fetching process node record as part of BAC-3259
    
    List<SVMXC__ServiceMax_Processes__c> lstProcessNodeRecords = [SELECT Id, SVMXC__Name__c, SVMXC__Description__c, SVMXC__ProcessID__c, SVMXC__Submodule__c, SVMXC__Process__c, SVMXC__Source_Object_Name__c, SVMXC__Type__c FROM SVMXC__ServiceMax_Processes__c WHERE Recordtype.Name = 'Process Node Objects' AND ((SVMXC__Process__c IN: LstTargetManagerRecId_SOQL1 AND SVMXC__Type__c  = 'TARGET') OR (SVMXC__Process__c IN: LstTargetManagerRecId_SOQL2 AND SVMXC__Type__c  = 'SOURCE'))]; //SDL-SVMX-FLS-NOT-ENFORCED-META-DATA
    for(SVMXC__ServiceMax_Processes__c objProcessNode : lstProcessNodeRecords){
        if(LstTargetManagerRecId_SOQL1.contains(objProcessNode.SVMXC__Process__c) && objProcessNode.SVMXC__Type__c.equalsIgnoreCase('TARGET')){
            lstSfmProcess_SOQL1.add(objProcessNode);
        }
        else if(LstTargetManagerRecId_SOQL2.contains(objProcessNode.SVMXC__Process__c) && objProcessNode.SVMXC__Type__c.equalsIgnoreCase('SOURCE')){
            lstSfmProcess_SOQL2.add(objProcessNode);
        }
    }
    lstProcessNodeRecords.clear();

    //List 1 iteration 
    for(SVMXC__ServiceMax_Processes__c SfmActionRec: lstSfmProcess_SOQL1)
    {
        if(SfmActionRec.SVMXC__Source_Object_Name__c != null && Map_ObjNameSfmActions.ContainsKey(SfmActionRec.SVMXC__Source_Object_Name__c))
        {
            List<SVMXC__ServiceMax_Processes__c> TempSfmActionLst = new List<SVMXC__ServiceMax_Processes__c>();
            //TempSfmActionLst = (Map_ObjNameSfmActions.get(SfmActionRec.SVMXC__Source_Object_Name__c));
            TempSfmActionLst.addAll((Map_ObjNameSfmActions.get(SfmActionRec.SVMXC__Source_Object_Name__c)));
            if(SfmActionRec.SVMXC__Process__c != null)
                TempSfmActionLst.add(TempSFMMap.get(SfmActionRec.SVMXC__Process__c));
            Map_ObjNameSfmActions.put(SfmActionRec.SVMXC__Source_Object_Name__c, TempSfmActionLst);
        }
        else if(SfmActionRec.SVMXC__Source_Object_Name__c != null && !(Map_ObjNameSfmActions.ContainsKey(SfmActionRec.SVMXC__Source_Object_Name__c)))
        {
            Map_ObjNameSfmActions.put(SfmActionRec.SVMXC__Source_Object_Name__c, (new List<SVMXC__ServiceMax_Processes__c>()));
            if(SfmActionRec.SVMXC__Process__c != null)
                (Map_ObjNameSfmActions.get(SfmActionRec.SVMXC__Source_Object_Name__c)).add(TempSFMMap.get(SfmActionRec.SVMXC__Process__c));
        }
    }
    //List 2 iteration
    for(SVMXC__ServiceMax_Processes__c SfmActionRec: lstSfmProcess_SOQL2)
    {
        if(SfmActionRec.SVMXC__Source_Object_Name__c != null && Map_ObjNameSfmBackgroundActions.ContainsKey(SfmActionRec.SVMXC__Source_Object_Name__c))
        {
            List<SVMXC__ServiceMax_Processes__c> TempSfmActionLst = new List<SVMXC__ServiceMax_Processes__c>();
            //TempSfmActionLst = (Map_ObjNameSfmBackgroundActions.get(SfmActionRec.SVMXC__Source_Object_Name__c));
            TempSfmActionLst.addAll((Map_ObjNameSfmBackgroundActions.get(SfmActionRec.SVMXC__Source_Object_Name__c)));
            if(SfmActionRec.SVMXC__Process__c != null)
                TempSfmActionLst.add(TempSFMMap.get(SfmActionRec.SVMXC__Process__c));
            Map_ObjNameSfmBackgroundActions.put(SfmActionRec.SVMXC__Source_Object_Name__c, TempSfmActionLst);
        }
        else if(SfmActionRec.SVMXC__Source_Object_Name__c != null && !(Map_ObjNameSfmBackgroundActions.ContainsKey(SfmActionRec.SVMXC__Source_Object_Name__c)))
        {
            Map_ObjNameSfmBackgroundActions.put(SfmActionRec.SVMXC__Source_Object_Name__c, (new List<SVMXC__ServiceMax_Processes__c>()));
            if(SfmActionRec.SVMXC__Process__c != null)
                (Map_ObjNameSfmBackgroundActions.get(SfmActionRec.SVMXC__Source_Object_Name__c)).add(TempSFMMap.get(SfmActionRec.SVMXC__Process__c));
        }
    }

    if( ObjName!= null && ObjName.toUpperCase() == 'ALL' )
        return Map_ObjNameSfmBackgroundActions;
    else
        if(  ObjName!= null && Map_ObjNameSfmBackgroundActions != null && Map_ObjNameSfmBackgroundActions.get(ObjName) != null)
        {
            Map_ObjNameSfmBackgroundAction.put(ObjName, Map_ObjNameSfmBackgroundActions.get(ObjName));
            return Map_ObjNameSfmBackgroundAction;
        }
        else
            return null;
}
//Other Actions return method
public Map<String,List<SVMXC__ServiceMax_Processes__c>> SVMX_GetOtherActions(String ObjName){
    Map_ObjNameOtherActions.clear();
    Map_ObjNameOtherAction.clear();
    List<SVMXC__ServiceMax_Processes__c> OtherActionList = new List<SVMXC__ServiceMax_Processes__c>();
    //Added SVMXC__Purpose__c for BAC-5190
    OtherActionList = Database.query('Select Id, SVMXC__Purpose__c, SVMXC__Name__c, SVMXC__Custom_Action_Type__c, SVMXC__ProcessID__c, SVMXC__Description__c, SVMXC__Source_Object_Name__c from SVMXC__ServiceMax_Processes__c where recordType.Name = \'SF Action\''); //SDL-SVMX-FLS-NOT-ENFORCED-META-DATA
    system.debug('nnzzzz2'+OtherActionList);
    for(SVMXC__ServiceMax_Processes__c ActionRec :OtherActionList)
    {
        if( ActionRec.SVMXC__Source_Object_Name__c != null && Map_ObjNameOtherActions.containsKey(ActionRec.SVMXC__Source_Object_Name__c) )
        {
            List<SVMXC__ServiceMax_Processes__c> TempOthrActionRecLst = new List<SVMXC__ServiceMax_Processes__c>();
            TempOthrActionRecLst.addAll(Map_ObjNameOtherActions.get(ActionRec.SVMXC__Source_Object_Name__c));
            TempOthrActionRecLst.add(ActionRec);
            Map_ObjNameOtherActions.put(ActionRec.SVMXC__Source_Object_Name__c, TempOthrActionRecLst);
            //ActionRec
        }
        else
        {
            if( ActionRec.SVMXC__Source_Object_Name__c != null )
            {
                List<SVMXC__ServiceMax_Processes__c> TempOthrActionRecLst1 = new List<SVMXC__ServiceMax_Processes__c>();
                TempOthrActionRecLst1.add(ActionRec);
                Map_ObjNameOtherActions.put(ActionRec.SVMXC__Source_Object_Name__c, TempOthrActionRecLst1);
            }
        }
    }
    system.debug('nzzzz4'+ObjName);
    system.debug('nzzzz4'+Map_ObjNameOtherActions);
    system.debug('nzzzz4'+Map_ObjNameOtherActions.get(ObjName));
    if( ObjName!= null && ObjName.toUpperCase() == 'ALL' )
        return Map_ObjNameOtherActions;
    else
        if(  ObjName!= null && Map_ObjNameOtherActions != null && Map_ObjNameOtherActions.get(ObjName) != null)
        {
            Map_ObjNameOtherAction.put(ObjName, Map_ObjNameOtherActions.get(ObjName));
            return Map_ObjNameOtherAction;
        }
        else
            return null;
}



    public Map<String,List<SVMXC__ServiceMax_Processes__c>> SVMX_GetSFMOutputDocActions(String strObjName)
    {
        MapObjNameSfmOutputDocActions.clear();
        MapObjNameSfmOutputDocAction.clear();
        Map<Id, SVMXC__ServiceMax_Processes__c> MapSfmOutputDocAction = new Map<Id, SVMXC__ServiceMax_Processes__c>();
        List<SVMXC__ServiceMax_Processes__c> lstPrcssNode = new List<SVMXC__ServiceMax_Processes__c>();
        List<Id> lstIds = new List<Id>();
        
        lstPrcssNode = [Select SVMXC__Process__c, SVMXC__Source_Object_Name__c from SVMXC__ServiceMax_Processes__c where recordtype.Name = 'Process Node Objects' and SVMXC__Process__r.SVMXC__Purpose__c = 'OUTPUT DOCUMENT' and SVMXC__Type__c =: 'TARGET' ORDER BY SVMXC__Process__r.SVMXC__Name__c]; //SDL-SVMX-FLS-NOT-ENFORCED-META-DATA
        
        for(SVMXC__ServiceMax_Processes__c objPrcss : lstPrcssNode)
        {
            if(objPrcss.SVMXC__Process__c != null)
                lstIds.add(objPrcss.SVMXC__Process__c);
        }
        
        if(lstIds != null && lstIds.size() > 0)
            
            MapSfmOutputDocAction.putAll([Select id, Name, SVMXC__Name__c, SVMXC__Custom_Action_Type__c, SVMXC__Description__c, SVMXC__ProcessID__c, SVMXC__Source_Object_Name__c, SVMXC__Purpose__c from SVMXC__ServiceMax_Processes__c where Id IN: lstIds]); //SDL-SVMX-FLS-NOT-ENFORCED-META-DATA
        
        for(SVMXC__ServiceMax_Processes__c ActionRec :lstPrcssNode)
        {
            if(ActionRec.SVMXC__Source_Object_Name__c != null && MapObjNameSfmOutputDocActions.containsKey(ActionRec.SVMXC__Source_Object_Name__c) && MapObjNameSfmOutputDocActions.get(ActionRec.SVMXC__Source_Object_Name__c) != null)
            {
                List<SVMXC__ServiceMax_Processes__c> TempSfmOutputDocActionRecLst = new List<SVMXC__ServiceMax_Processes__c>();
                TempSfmOutputDocActionRecLst.addAll(MapObjNameSfmOutputDocActions.get(ActionRec.SVMXC__Source_Object_Name__c));
                TempSfmOutputDocActionRecLst.add(MapSfmOutputDocAction.get(ActionRec.SVMXC__Process__c));
                MapObjNameSfmOutputDocActions.put(ActionRec.SVMXC__Source_Object_Name__c, TempSfmOutputDocActionRecLst);
            }
            else if(MapSfmOutputDocAction != null && MapSfmOutputDocAction.containsKey(ActionRec.SVMXC__Process__c) && MapSfmOutputDocAction.get(ActionRec.SVMXC__Process__c) != null)
            {
                List<SVMXC__ServiceMax_Processes__c> TempSfmOutputDocActionRecLst1 = new List<SVMXC__ServiceMax_Processes__c>();
                TempSfmOutputDocActionRecLst1.add(MapSfmOutputDocAction.get(ActionRec.SVMXC__Process__c));
                MapObjNameSfmOutputDocActions.put(ActionRec.SVMXC__Source_Object_Name__c, TempSfmOutputDocActionRecLst1);
            }
        }
        if( strObjName!= null && strObjName.toUpperCase() == 'ALL' )
            return MapObjNameSfmOutputDocActions;
        else
            if(  strObjName!= null && MapObjNameSfmOutputDocActions != null && MapObjNameSfmOutputDocActions.containsKey(strObjName) && MapObjNameSfmOutputDocActions.get(strObjName) != null)
            {
                MapObjNameSfmOutputDocAction.put(strObjName, MapObjNameSfmOutputDocActions.get(strObjName));
                return MapObjNameSfmOutputDocAction;
            }
            else
                return null;
    }

    /* @Param strObjName : This can be either Object API Name or 'ALL'
       1. Gets all the Servicemax process records of type 'Processs Node Objects', type 'Source' (Since for Checklist Target is always Checklist Object) and 
          purpose 'Checklist'
       2. Gets all the Servicemax process records of type 'Target Manager' ie Process records for the node objects
       3. Creates a Map of Object API Name and the list of Serviemax Processes
       @Return : Returns map of Object and its corresponding Process depending on @Param value      
    */
    public Map<String,List<SVMXC__ServiceMax_Processes__c>> SVMX_GetChecklistActions(String strObjName)
    {
        MapObjNameChecklistActions.clear();
        MapObjNameChecklistAction.clear();
        Map<Id, SVMXC__ServiceMax_Processes__c> MapChecklistAction = new Map<Id, SVMXC__ServiceMax_Processes__c>();
        List<SVMXC__ServiceMax_Processes__c> lstPrcssNode = new List<SVMXC__ServiceMax_Processes__c>();
        List<Id> lstIds = new List<Id>();
        
        lstPrcssNode = [Select SVMXC__Process__c, SVMXC__Source_Object_Name__c from SVMXC__ServiceMax_Processes__c where recordtype.Name = 'Process Node Objects' and SVMXC__Process__r.SVMXC__Purpose__c = 'CHECKLIST' and SVMXC__Type__c =: 'SOURCE' ORDER BY SVMXC__Process__r.SVMXC__Name__c]; //SDL-SVMX-FLS-NOT-ENFORCED-META-DATA
        
        for(SVMXC__ServiceMax_Processes__c objPrcss : lstPrcssNode)
        {
            if(objPrcss.SVMXC__Process__c != null)
                lstIds.add(objPrcss.SVMXC__Process__c);
        }
        
        if(lstIds != null && lstIds.size() > 0)
            
            MapChecklistAction.putAll([Select id, Name, SVMXC__Name__c, SVMXC__Custom_Action_Type__c, SVMXC__Description__c, SVMXC__ProcessID__c, SVMXC__Source_Object_Name__c, SVMXC__Purpose__c from SVMXC__ServiceMax_Processes__c where Id IN: lstIds]); //SDL-SVMX-FLS-NOT-ENFORCED-META-DATA
        
        for(SVMXC__ServiceMax_Processes__c ActionRec :lstPrcssNode){
            List<SVMXC__ServiceMax_Processes__c> TempChecklistActionRecLst = new List<SVMXC__ServiceMax_Processes__c>();
            if(ActionRec.SVMXC__Source_Object_Name__c != null){
                if(MapObjNameChecklistActions.containsKey(ActionRec.SVMXC__Source_Object_Name__c))
                   TempChecklistActionRecLst = MapObjNameChecklistActions.get(ActionRec.SVMXC__Source_Object_Name__c);
                TempChecklistActionRecLst.add(MapChecklistAction.get(ActionRec.SVMXC__Process__c));  
                MapObjNameChecklistActions.put(ActionRec.SVMXC__Source_Object_Name__c,TempChecklistActionRecLst);
            }    
        }

        if( strObjName!= null && strObjName.toUpperCase() == 'ALL' )
            return MapObjNameChecklistActions;
        else
            if(  strObjName!= null && MapObjNameChecklistActions != null && MapObjNameChecklistActions.containsKey(strObjName) && MapObjNameChecklistActions.get(strObjName) != null)
            {
                MapObjNameChecklistAction.put(strObjName, MapObjNameChecklistActions.get(strObjName));
                return MapObjNameChecklistAction;
            }
            else
                return null;
    }    


//Get all receiving process / Delivery records
public Map<String,List<SVMXC__ServiceMax_Processes__c>> SVMX_GetReceive_DeliveryActions(String ObjName){
    Map_ObjNameReceive_DeliveryAction.clear();
    List<SVMXC__ServiceMax_Processes__c> Receive_DeliveryProcesses = new List<SVMXC__ServiceMax_Processes__c>();
    
    Receive_DeliveryProcesses = Database.query('Select Id, SVMXC__Name__c, SVMXC__Custom_Action_Type__c, SVMXC__ProcessID__c, SVMXC__Description__c, SVMXC__Source_Object_Name__c from SVMXC__ServiceMax_Processes__c where recordType.Name = \'Receiving Process\''); //SDL-SVMX-FLS-NOT-ENFORCED-META-DATA
    if(Receive_DeliveryProcesses != null && Receive_DeliveryProcesses.size() > 0)
    {
        Map_ObjNameReceive_DeliveryAction.put('SVMXC__RMA_Shipment_Order__c', Receive_DeliveryProcesses);
        return Map_ObjNameReceive_DeliveryAction;
    }
    return null;
}

//Get all shipping process / picking records
public Map<String,List<SVMXC__ServiceMax_Processes__c>> SVMX_GetPicking_ShippingActions(String ObjName){
    Map_ObjNamePicking_ShippingAction.clear();
    List<SVMXC__ServiceMax_Processes__c> Ship_PickProcesses = new List<SVMXC__ServiceMax_Processes__c>();
    
    Ship_PickProcesses = Database.query('Select Id, SVMXC__Name__c, SVMXC__Custom_Action_Type__c, SVMXC__ProcessID__c, SVMXC__Description__c, SVMXC__Source_Object_Name__c from SVMXC__ServiceMax_Processes__c where recordType.Name = \'Shipping Process\''); //SDL-SVMX-FLS-NOT-ENFORCED-META-DATA
    if(Ship_PickProcesses != null && Ship_PickProcesses.size() > 0)
    {
        Map_ObjNamePicking_ShippingAction.put('SVMXC__RMA_Shipment_Order__c', Ship_PickProcesses);
        return Map_ObjNamePicking_ShippingAction;
    }
    return null;
}

//Get all Initiate returns records
public Map<String,List<SVMXC__ServiceMax_Processes__c>> SVMX_GetInitiateReturnActions(String ObjName){
    Map_InitiateReturnAction.clear();
    List<SVMXC__ServiceMax_Processes__c> InitiateReturnProcesses = new List<SVMXC__ServiceMax_Processes__c>();
    
    InitiateReturnProcesses = Database.query('Select Id, SVMXC__Name__c, SVMXC__Custom_Action_Type__c, SVMXC__ProcessID__c, SVMXC__Description__c, SVMXC__Source_Object_Name__c from SVMXC__ServiceMax_Processes__c where recordType.Name = \'Initiate Return Process\''); //SDL-SVMX-FLS-NOT-ENFORCED-META-DATA
    if(InitiateReturnProcesses != null && InitiateReturnProcesses.size() > 0)
    {
        Map_InitiateReturnAction.put('Case', InitiateReturnProcesses);
        return Map_InitiateReturnAction;
    }
    return null;
}
//Get all Fulfillment Process records
public Map<String,List<SVMXC__ServiceMax_Processes__c>> SVMX_GetFulfillmentProcessActions(String ObjName){
    Map_FulfillmentProcessAction.clear();
    List<SVMXC__ServiceMax_Processes__c> FullfillmentProcesses = new List<SVMXC__ServiceMax_Processes__c>();
    
    FullfillmentProcesses = Database.query('Select Id, SVMXC__Name__c, SVMXC__Custom_Action_Type__c, SVMXC__ProcessID__c, SVMXC__Description__c, SVMXC__Source_Object_Name__c from SVMXC__ServiceMax_Processes__c where recordType.Name = \'Fulfillment Process\''); //SDL-SVMX-FLS-NOT-ENFORCED-META-DATA
    if(FullfillmentProcesses != null && FullfillmentProcesses.size() > 0)
    {
        Map_FulfillmentProcessAction.put('SVMXC__RMA_Shipment_Order__c', FullfillmentProcesses);
        return Map_FulfillmentProcessAction;
    }
    return null;
}


//Get All Object Name having sfw
public Map<String,List<SVMXC__ServiceMax_Processes__c>> SVMX_GetObjNamesNsfwRecs(String ObjName){
    List<SVMXC__ServiceMax_Processes__c> sfwLst = new List<SVMXC__ServiceMax_Processes__c>();
    Map<String,List<SVMXC__ServiceMax_Processes__c>> Map_sfwRecs = new Map<String,List<SVMXC__ServiceMax_Processes__c>>();
    
    sfwLst = Database.query('Select Id, SVMXC__Select__c, SVMXC__ProcessID__c, SVMXC__Name__c, SVMXC__Description__c, SVMXC__Source_Object_Name__c, LastModifiedById, SVMXC__IsStandard__c from SVMXC__ServiceMax_Processes__c where RecordType.Name = \'Wizard\' ORDER BY SVMXC__Name__c ASC'); //SDL-SVMX-FLS-NOT-ENFORCED-META-DATA

    for(SVMXC__ServiceMax_Processes__c  sfwRec :sfwLst)
    {
        if(sfwRec.SVMXC__Source_Object_Name__c != null && Map_sfwRecs.containsKey(sfwRec.SVMXC__Source_Object_Name__c))
        {
            List<SVMXC__ServiceMax_Processes__c> TempsfwLst = new List<SVMXC__ServiceMax_Processes__c>();
            TempsfwLst = Map_sfwRecs.get(sfwRec.SVMXC__Source_Object_Name__c);
            TempsfwLst.add(sfwRec);
            Map_sfwRecs.put(sfwRec.SVMXC__Source_Object_Name__c,TempsfwLst);
        }
        else if( sfwRec.SVMXC__Source_Object_Name__c != null && !(Map_sfwRecs.containsKey(sfwRec.SVMXC__Source_Object_Name__c)))
        {
            List<SVMXC__ServiceMax_Processes__c> TempsfwLst1 = new List<SVMXC__ServiceMax_Processes__c>();
            TempsfwLst1.add(sfwRec);
            Map_sfwRecs.put(sfwRec.SVMXC__Source_Object_Name__c,TempsfwLst1);
        }
    }
    if(ObjName!= null && ObjName.toUpperCase() == 'ALL')
        return Map_sfwRecs;
    else if( ObjName != null && Map_sfwRecs != null && Map_sfwRecs.get(ObjName) != null)
    {
        Map<String,List<SVMXC__ServiceMax_Processes__c>> TempMap_ObjectNamesfwRec = new Map<String,List<SVMXC__ServiceMax_Processes__c>>();
        TempMap_ObjectNamesfwRec.put(ObjName, Map_sfwRecs.get(ObjName));
        return TempMap_ObjectNamesfwRec;
    }
    return null;
}
    // Method Added By: Naveen V(15-Dec-2011) This method gets the record Id from which the 1st Wizard Step is initiated and the Id of the Next Wizard Step Configured And returns the URL for the Next Wizard Step.
    public string SVMX_GetNextStepURL(string recordId, string nxtWizardStepId)
    {
        string nxtStepURL = '';
        Map<String, String> svmxSettingList = new Map<String,String>();
        SVMXC.COMM_Utils_ManageSettings commSettings = new SVMXC.COMM_Utils_ManageSettings();
        //BAC-6188 React Delivery Change - Added 'SFM002'
        Map<String,Map<String,String>> mapAllSubmoduleSettings = commSettings.SVMX_getSettingList(new List<String>{'SFM002', 'GLOB001'});
        svmxSettingList = mapAllSubmoduleSettings.get('GLOB001');
        if (svmxSettingList != null) {
            nxtStepURL = svmxSettingList.get('GBL016') != null ? string.valueOf(svmxSettingList.get('GBL016')) : '';
        }
        system.debug('Default Home Page URL: ' + nxtStepURL);
        string SOQLStr;
        system.debug('Next Wizard Id: ' + nxtWizardStepId + ' : Record ID: ' + recordId);
        if(nxtWizardStepId != null && nxtWizardStepId != '' && nxtWizardStepId.length() > 0 && recordId != null && recordId != '' && recordId.length() > 0)
        {
            string keyPrefix = recordId.subString(0, 3);
            string ObjName = '';
            Map<String, Schema.SObjectType> allObjs = Schema.getGlobalDescribe();
            for(String Obj : allObjs.keySet())
            {
                Schema.DescribeSObjectResult R = allObjs.get(Obj).getDescribe();
                // Sharad 8/5/12 : change this condition from if(R.getKeyPrefix() == keyPrefix) to if(R.getKeyPrefix().equals(keyPrefix)), because it getting wrong object name
                if(R.getKeyPrefix() != null && R.getKeyPrefix().equals(keyPrefix))
                {
                    ObjName = R.getName();
                    break;
                }

            }
            try
            {
                system.debug('1. Id of step wizard: ' + nxtWizardStepId);
                SVMXC__ServiceMax_Processes__c wizardStep = new SVMXC__ServiceMax_Processes__c();
                
                wizardStep = [select Id, SVMXC__Module__c, SVMXC__Process__c, SVMXC__Handover__c, SVMXC__Process__r.Id, SVMXC__Name__c, SVMXC__ProcessID__c, SVMXC__Description__c, SVMXC__Action_Type__c, SVMXC__Action_URL__c,  SVMXC__Sequence__c, SVMXC__Submodule__c, SVMXC__IsStandard__c,SVMXC__Process__r.SVMXC__ProcessId__c, SVMXC__Process1__c, SVMXC__Mode_Of_Execution__c, SVMXC__Select_Template_At_Runtime__c from SVMXC__ServiceMax_Processes__c where Id =: nxtWizardStepId]; //SDL-SVMX-FLS-NOT-ENFORCED-META-DATA
                system.debug('2. Queried step wizard: ' + wizardStep);
                system.debug('nEXT Queried step wizard: ' + wizardStep.SVMXC__Process1__c);
                
                if(wizardStep != null)
                {
                    system.debug('3. Queried step wizard submodule: ' + wizardStep.SVMXC__Submodule__c);
                    if(wizardStep.SVMXC__Submodule__c != null)
                    {
                        SVMXC__ServiceMax_Processes__c expressionHeader = new SVMXC__ServiceMax_Processes__c();
                        string SOQLStr1 = 'select id,  Name, SVMXC__Sequence__c, SVMXC__Source_Object_Name__c, SVMXC__Name__c, SVMXC__SettingId__c, SVMXC__Description__c, SVMXC__Advance_Expression__c, SVMXC__Parent_Object_Criteria__c from SVMXC__ServiceMax_Processes__c where id = \'' + wizardStep.SVMXC__Submodule__c + '\' AND Recordtype.Name=\'SVMX Rule\' AND SVMXC__Rule_Type__c = \'Named Expression\'';
                        
                        expressionHeader = database.query(SOQLStr1); //SDL-SVMX-FLS-NOT-ENFORCED-META-DATA
                        system.debug('4. Expression Header: ' + expressionHeader + ' and the criteria is: ' + expressionHeader.SVMXC__Parent_Object_Criteria__c);
                        
                        if(expressionHeader != null && expressionHeader.SVMXC__Parent_Object_Criteria__c != null && expressionHeader.SVMXC__Parent_Object_Criteria__c != '')
                        {
                            string whereClause = expressionHeader.SVMXC__Parent_Object_Criteria__c;
                            SOQLStr = 'select id from ' + ObjName + ' where ' + 'id =\'' + recordId + '\' AND ' + whereClause;
                            system.debug('5. String to query: ' + SOQLStr);
                        }
                        else
                            SOQLStr = 'select id from ' + ObjName + ' where ' + 'id =\'' + recordId + '\'';
                    }
                    else
                        SOQLStr = 'select id from ' + ObjName + ' where ' + 'id =\'' + recordId + '\'';
                    List<sObject> tempObj = database.query(SOQLStr);
                    system.debug('6. queried Object: ' + tempObj);
                    system.debug('7. Action Type: ' + wizardStep.SVMXC__Action_Type__c);
                    string fieldString;
                    if(tempObj != null && tempObj.size() > 0)
                    {
                        system.debug('found Obj' + wizardStep.SVMXC__Action_Type__c);
                        String strPageName = 'SVMXC__SFM_TDM_Delivery';
                        if(svmxSettingList.containsKey('GBL021') && svmxSettingList.get('GBL021') != null )
                        {
                            if(svmxSettingList.get('GBL021').toUpperCase() == 'HTML5' && wizardStep.SVMXC__Mode_Of_Execution__c !='Background')
                                strPageName = 'SVMXC__ServiceMaxConsole';
                        }
                        if(wizardStep.SVMXC__Action_Type__c == null)
                        {
                            nxtStepURL = '/' + recordId;
                            COMM_SVMXC_Utils2 objCls = new COMM_SVMXC_Utils2();
                            nxtStepURL = objCls.GetCommunityPrefix(nxtStepURL);
                            return nxtStepURL;
                        }
                        else if (wizardStep.SVMXC__Action_Type__c.toUpperCase() == 'INVENTORY')
                        {
                            nxtStepURL = '/apex/SVMXC__INVT_SmartEngine?hdrId=' + recordId + '&SMid=' + wizardStep.SVMXC__Process__r.SVMXC__ProcessId__c;  
                        }
                        else if (wizardStep.SVMXC__Action_Type__c.toUpperCase() == 'SFM')
                        {
                            //BAC-6188 React Delivery Change
                            Boolean isLegacyEnabled = false;
                            Boolean isSFMLightning = false;
                            Map<String, String> deliverySettingList = mapAllSubmoduleSettings.get('SFM002');
                            if(deliverySettingList != null && deliverySettingList.containsKey('SET007') && String.isNotBlank(deliverySettingList.get('SET007'))){
                                isLegacyEnabled = Boolean.valueOf(deliverySettingList.get('SET007'));
                            }
                            if(deliverySettingList != null && deliverySettingList.containsKey('SET004') && deliverySettingList.get('SET004') != null && deliverySettingList.get('SET004').equalsIgnoreCase('Lightning')){
                                isSFMLightning = true;
                            }

                            if(isLegacyEnabled && isSFMLightning && wizardStep.SVMXC__Mode_Of_Execution__c !='Background'){//BAC-6345
                                strPageName = 'SVMXC__SFMDeliveryReactConsole';
                            }
                            
                        	nxtStepURL = '/apex/'+strPageName+'?SVMX_recordId=' + recordId + '&SVMX_action='+wizardStep.SVMXC__Action_Type__c.toUpperCase() + '&SVMX_processId=' + wizardStep.SVMXC__Process__r.SVMXC__ProcessId__c +'&SVMX_retURL=/' + recordId ;
                        	/*Added a condition for Background execution on 6th March 2012 by Shashank*/    
                            if(wizardStep.SVMXC__Mode_Of_Execution__c =='Background')
                                nxtStepURL = nxtStepURL + '&SVMX_Execution_Mode=SVMXAUTO';
                            if(wizardStep.SVMXC__Handover__c == true && wizardStep.SVMXC__Process1__c != null)
                                nxtStepURL = nxtStepURL + '&SVMX_NxtStepID=' + wizardStep.SVMXC__Process1__c;
                            system.debug('URL: ' + nxtStepURL);
                        }
                        else if(wizardStep.SVMXC__Action_Type__c.toUpperCase() == 'CHECKLIST'){
                            nxtStepURL = '/apex/'+strPageName+'?SVMX_recordId=' + recordId + '&SVMX_action='+wizardStep.SVMXC__Action_Type__c.toUpperCase() +'&SVMX_processId=' + wizardStep.SVMXC__Process__r.SVMXC__ProcessId__c +'&SVMX_retURL=/' + recordId ;
                        }
                        else if (wizardStep.SVMXC__Action_Type__c.toUpperCase() == 'OTHERS' && wizardStep.SVMXC__Process__c != null)
                        {
                            SVMXC__ServiceMax_Processes__c otherAction = new SVMXC__ServiceMax_Processes__c();
                            
                            otherAction = [select id, SVMXC__Name__c, SVMXC__ProcessID__c, SVMXC__Window_Height__c, SVMXC__Window_Width__c, SVMXC__Description__c, SVMXC__Source_Object_Name__c, SVMXC__Active__c, SVMXC__Target_Type__c, SVMXC__Target_URL__c, SVMXC__IsStandard__c, SVMXC__Show_Scrollbars__c, SVMXC__Open_As_Full_Window__c, SVMXC__Custom_Action_Type__c from SVMXC__ServiceMax_Processes__c Where Id =: wizardStep.SVMXC__Process__c]; //SDL-SVMX-FLS-NOT-ENFORCED-META-DATA
                            system.debug('8. Action Process: ' + otherAction + ' and the Target URL is: ' + otherAction.SVMXC__Target_URL__c);
                            if(otherAction != null)
                            {
                                String actUrl = '';
                                
                                //This code is adding by Sharad 0n 6/6/12 for checking it is Web Service or URL
                                String strActnType = otherAction.SVMXC__Custom_action_Type__c;
                                if(strActnType == 'Web-Service')
                                {
                                    String encoded = EncodingUtil.urlEncode(wizardStep.SVMXC__Name__c, 'UTF-8');
                                    
                                    actUrl += '../apex/SVMXC__SFM_ExecuteAPEX';
                                    actUrl += '?SVMX_recordId='+ recordId;
                                    actUrl += '&SVMX_title='+ encoded;
                                    actUrl += '&SVMX_processId='+ otherAction.SVMXC__ProcessId__c;
                                }
                                else
                                {
                                    actUrl += otherAction.SVMXC__Target_URL__c;
                                    if(ObjName != null && ObjName.length() > 0 && recordId != null )
                                    {
                                        Set<String> setFieldAPINames = new Set<String>();
                                        List<SVMXC__ServiceMax_Config_Data__c> lstActionParams = new List<SVMXC__ServiceMax_Config_Data__c>();
                                        
                                        lstActionParams = [Select Id, SVMXC__Object_Name__c, SVMXC__Parameter_Name__c, SVMXC__Parameter_Type__c, SVMXC__Parameter_Value__c, SVMXC__Expression_Rule__c, SVMXC__Dispatch_Process__c From SVMXC__ServiceMax_Config_Data__c Where SVMXC__Dispatch_Process__c =: otherAction.Id AND RecordType.Name = 'SF Action Parameter' AND SVMXC__Dispatch_Process__c != null]; //SDL-SVMX-FLS-NOT-ENFORCED-META-DATA
                                        system.debug('9. Action Process Parameters List: ' + lstActionParams + ' and the size of the List is: ' + lstActionParams.size());
                                        if(lstActionParams != null && lstActionParams.size() > 0)

                                        {
                                            for(SVMXC__ServiceMax_Config_Data__c p : lstActionParams)
                                            {
                                                if(p.SVMXC__Parameter_Type__c.toUpperCase() == 'FIELD NAME')
                                                {   

                                                    if(p.SVMXC__Parameter_Value__c != null )
                                                        setFieldAPINames.add((p.SVMXC__Parameter_Value__c).ToUpperCase());
                                                }
                                            }
                                        }

                                        if(setFieldAPINames != null && setFieldAPINames.size() > 0)
                                        {
                                            fieldString = ' ';
                                            for (String field : setFieldAPINames)
                                            {
                                                if(fieldString != ' ')
                                                    fieldString += ', ' + field;
                                                else
                                                    fieldString += field;
                                            }




                                        }

                                        system.debug('10. Fields to be Queried: ' + fieldString);
                                        sObject rec ;
                                        if(fieldString != null && fieldString.length() > 0)
                                        {
                                            SOQLStr = 'select ' + fieldString + ' from ' + ObjName + ' where ' + 'id =\'' + recordId + '\'';
                                            system.debug('11. Query String: ' + SOQLStr);
                                            rec = database.query(SOQLStr);
                                            system.debug('12. Record Queried: ' + rec);
                                        }
                                        if (lstActionParams != null)
                                        {
                                            Integer parameterCount = 0;
                                            for (SVMXC__ServiceMax_Config_Data__c p : lstActionParams)
                                            {
                                                If (parameterCount == 0)
                                                    actUrl += '?';
                                                else
                                                    actUrl += '&';

                                                actUrl += p.SVMXC__Parameter_Name__c + '=';
                                                

                                                if (p.SVMXC__Parameter_Type__c.toUpperCase() == 'VALUE')
                                                    //actUrl += p.SVMXC__Parameter_Value__c;
                                                    actUrl += EncodingUtil.urlEncode(p.SVMXC__Parameter_Value__c, 'UTF-8');
                                                else if (p.SVMXC__Parameter_Type__c.toUpperCase() == 'FIELD NAME' && rec != null && rec.get(p.SVMXC__Parameter_Value__c) != null)
                                                    //actUrl += rec.get(p.SVMXC__Parameter_Value__c);
                                                    actUrl += EncodingUtil.urlEncode(String.valueOf(rec.get(p.SVMXC__Parameter_Value__c)), 'UTF-8');
                                                parameterCount ++;
                                            }
                                            system.debug('13. URL created: ' + actUrl);

                                        }
                                    }

                                }
                                nxtStepURL = actUrl;
                            }
                            else
                                nxtStepURL = '/' + recordId;
                            
                            if(wizardStep.SVMXC__Handover__c == true && wizardStep.SVMXC__Process1__c != null)
                                nxtStepURL = nxtStepURL + '&SVMX_NxtStepID=' + wizardStep.SVMXC__Process1__c;
                            system.debug('URL: ' + nxtStepURL);
                        }/* 
                        else if(wizardStep.SVMXC__Action_Type__c.toUpperCase() == 'BACKGROUND_EXEC')
                        {
                            nxtStepURL = '/apex/SVMXC__SFM_TDM_Delivery?SVMX_recordId=' + recordId + '&SVMX_processId=' + wizardStep.SVMXC__Process__r.SVMXC__ProcessId__c + '&SVMX_Execution_Mode=SVMXAUTO&SVMX_retURL=/' + recordId ;
                        } */
                        else if(wizardStep.SVMXC__Action_Type__c.toUpperCase() == 'RECEIPT')
                        {
                            nxtStepURL = '/apex/SVMXC__APL_ProcessReceipts?SVMX_processId=' + wizardStep.SVMXC__Process__r.SVMXC__ProcessId__c + '&SVMX_recordID='+recordId + '&SVMX_retURL=/' + recordId;
                            
                            if(wizardStep.SVMXC__Handover__c == true && wizardStep.SVMXC__Process1__c != null)
                                nxtStepURL = nxtStepURL + '&SVMX_NxtStepID=' + wizardStep.SVMXC__Process1__c;
                            system.debug('URL: ' + nxtStepURL);
                        }
                        else if(wizardStep.SVMXC__Action_Type__c.toUpperCase() == 'DELIVERY')
                        {
                            nxtStepURL = '/apex/SVMXC__APL_DeliveryOnReceipt?SVMX_recordId=' + recordId + '&SVMX_processId=' + wizardStep.SVMXC__Process__r.SVMXC__ProcessId__c +'&SVMX_retURL=/' + recordId ;
                            if(wizardStep.SVMXC__Handover__c == true && wizardStep.SVMXC__Process1__c != null)
                                nxtStepURL = nxtStepURL + '&SVMX_NxtStepID=' + wizardStep.SVMXC__Process1__c;
                            system.debug('URL: ' + nxtStepURL);
                        }
                        else if(wizardStep.SVMXC__Action_Type__c.toUpperCase() == 'SHIP')
                        {
                            nxtStepURL = '/apex/SVMXC__APL_ConfirmShipment?SVMX_recordId=' + recordId + '&SVMX_processId=' + wizardStep.SVMXC__Process__r.SVMXC__ProcessId__c +'&SVMX_retURL=/' + recordId ;
                            if(wizardStep.SVMXC__Handover__c == true && wizardStep.SVMXC__Process1__c != null)
                                nxtStepURL = nxtStepURL + '&SVMX_NxtStepID=' + wizardStep.SVMXC__Process1__c;
                            system.debug('URL: ' + nxtStepURL);
                        }
                        else if(wizardStep.SVMXC__Action_Type__c.toUpperCase() == 'PICK_MOVE')
                        {
                            nxtStepURL = '/apex/SVMXC__APL_PickAndMove?SVMX_recordId=' + recordId + '&SVMX_processId=' + wizardStep.SVMXC__Process__r.SVMXC__ProcessId__c +'&SVMX_retURL=/' + recordId ;
                            if(wizardStep.SVMXC__Handover__c == true && wizardStep.SVMXC__Process1__c != null)
                                nxtStepURL = nxtStepURL + '&SVMX_NxtStepID=' + wizardStep.SVMXC__Process1__c;
                            system.debug('URL: ' + nxtStepURL);
                        }
                        else if(wizardStep.SVMXC__Action_Type__c.toUpperCase() == 'INITIATE_RETURN')
                        {
                            nxtStepURL = '/apex/SVMXC__APL_InitiateReturn?SVMX_recordId=' + recordId + '&SVMX_processId=' + wizardStep.SVMXC__Process__r.SVMXC__ProcessId__c +'&SVMX_retURL=/' + recordId ;
                            if(wizardStep.SVMXC__Handover__c == true && wizardStep.SVMXC__Process1__c != null)
                                nxtStepURL = nxtStepURL + '&SVMX_NxtStepID=' + wizardStep.SVMXC__Process1__c;
                            system.debug('URL: ' + nxtStepURL);
                        }
                        else if(wizardStep.SVMXC__Action_Type__c.toUpperCase() == 'FULFILLMENT')
                        {
                            nxtStepURL = '/apex/SVMXC__APL_FulfillmentConsole?SVMX_recordId=' + recordId + '&SVMX_processId=' + wizardStep.SVMXC__Process__r.SVMXC__ProcessId__c +'&SVMX_retURL=/' + recordId ;
                            if(wizardStep.SVMXC__Handover__c == true && wizardStep.SVMXC__Process1__c != null)
                                nxtStepURL = nxtStepURL + '&SVMX_NxtStepID=' + wizardStep.SVMXC__Process1__c;
                            system.debug('URL: ' + nxtStepURL);
                        }
                        else if(wizardStep.SVMXC__Action_Type__c.toUpperCase() == 'FULFILLMENT')
                        {
                            nxtStepURL = '/apex/SVMXC__APL_FulfillmentConsole?SVMX_recordId=' + recordId + '&SVMX_processId=' + wizardStep.SVMXC__Process__r.SVMXC__ProcessId__c +'&SVMX_retURL=/' + recordId ;
                            if(wizardStep.SVMXC__Handover__c == true && wizardStep.SVMXC__Process1__c != null)
                                nxtStepURL = nxtStepURL + '&SVMX_NxtStepID=' + wizardStep.SVMXC__Process1__c;
                            system.debug('URL: ' + nxtStepURL);
                        }
                        else if(wizardStep.SVMXC__Action_Type__c.toUpperCase() == 'OUTPUT_DOCUMENT')
                        {
                            // 11th March 2019, Fixed defect BAC-4731 and BAC-4729 removed .. prefix from /apex.
                            if(wizardStep.SVMXC__Select_Template_At_Runtime__c != true &&wizardStep.SVMXC__Process__r.SVMXC__ProcessId__c != null)
                                nxtStepURL = '/apex/SVMXC__OPDOC_Delivery?SVMX_recordId=' + recordId +'&SVMX_processId=' + wizardStep.SVMXC__Process__r.SVMXC__ProcessId__c +'&SVMX_retURL=/' + recordId ;
                            else
                                nxtStepURL= '/' + recordId;
                        }
                        else
                            nxtStepURL = '/' + recordId;
                    }
                    else
                        nxtStepURL = '/' + recordId;
                }
                else
                    nxtStepURL = '/' + recordId;
            }catch(exception ex)
            {
                system.debug('Exception and message');
                nxtStepURL = '/' + recordId;
            }
        }
        else if(recordId != null && recordId != '' && recordId.length() > 0)
            nxtStepURL = '/' + recordId;
        system.debug('14. URL Created at the last is: ' + nxtStepURL);
        COMM_SVMXC_Utils2 objCls = new COMM_SVMXC_Utils2();
        nxtStepURL = objCls.GetCommunityPrefix(nxtStepURL);
        system.debug('14. URL Created at the last is: ' + nxtStepURL);
        return nxtStepURL;
    }
}