trigger SVMXC_CreateWarranty on SVMXC__Installed_Product__c (after insert, after update)
{
    //Added by Nidhi as part of BAC-5157, Disabling Trigger based on setting on Trigger Controls page.
    if(!CONF_TriggerControl.isTriggerEnabled('SVMXC__Installed_Product__c',userInfo.getUserId(),userInfo.getProfileId())){
        System.debug(Logginglevel.WARN,'SVMXC_CreateWarranty execution is skipped.');
        return;
    }
    SVMXC.COMM_Utils_ManageSettings settings = new SVMXC.COMM_Utils_ManageSettings();
    List<SVMXC__Installed_Product__c> validIbs =  new List<SVMXC__Installed_Product__c>();
    List<String> settingIdList = new List<String>();
    settingIdList.add('SET005');
    settingIdList.add('SET006');
    settingIdList.add('SET010');
    settingIdList.add('SET011');
    settingIdList.add('SET002');
    settingIdList.add('SET013'); // isCreateWarrantyForProdFamily Setting
    settingIdList.add('SET014'); // isCreateWarrantyForProdFamily Setting
    
    Map<String, String> AllSubModuleSettings = settings.SVMX_getSettingList('IPRD002', settingIdList);  
    String OnCreate = '';
    if(AllSubModuleSettings.containsKey('SET005')== true) OnCreate = AllSubModuleSettings.get('SET005'); //setting for Create Warranty on IB Creation
    String OnUpdate = '';
    if(AllSubModuleSettings.containsKey('SET006')== true) OnUpdate  = AllSubModuleSettings.get('SET006'); //setting for Create Warranty on IB Update
    
    for(SVMXC__Installed_Product__c ib: Trigger.new){
        if(ib.SVMXC__Product__c != NULL )
        {
            validIbs.add(ib);
        }
        
    }
    if (Trigger.isInsert){
        if (OnCreate.toUpperCase() == 'TRUE' && !SVMXC.SVMXC_CreateWarrantyClass.isWarrantyCreationExecuted()){
            //On Insert and when Create Warranty on IB Creation is true
            SVMXC.SVMXC_CreateWarrantyClass.SVMX_CreateWarranty(validIbs,AllSubModuleSettings); 
        }
    }
    else if (Trigger.isUpdate){
        if (OnUpdate.toUpperCase() == 'TRUE' && !SVMXC.SVMXC_CreateWarrantyClass.isWarrantyCreationExecuted()){
            //On Update and when Create Warranty on IB Update is true
            SVMXC.SVMXC_CreateWarrantyClass.SVMX_CreateWarranty(validIbs,AllSubModuleSettings);
        }
    }

/* Old trigger -Commented by GM 16Feb10
    SVMXC.COMM_Utils_ManageSettings settings = new SVMXC.COMM_Utils_ManageSettings();
    List<String> settingIdList = new List<String>();
    settingIdList.add('SET005');
    settingIdList.add('SET006');
    
    Map<String, String> AllSubModuleSettings = settings.SVMX_getSettingList('IPRD002', settingIdList);

    String OnCreate = '';
    if(AllSubModuleSettings.containsKey('SET005')== true) OnCreate = AllSubModuleSettings.get('SET005'); //setting for Create Warranty on IB Creation
    String OnUpdate = '';
    if(AllSubModuleSettings.containsKey('SET006')== true) OnUpdate  = AllSubModuleSettings.get('SET006'); //setting for Create Warranty on IB Update

    for (Integer i = 0; i < Trigger.new.size(); i++)
    {
        if (Trigger.isInsert)
        {
             if (OnCreate.toUpperCase() == 'TRUE')
             {//On Insert and when Create Warranty on IB Creation is true
                SVMXC.SVMXC_CreateWarrantyClass.SVMX_CreateWarranty(Trigger.new[i], AllSubModuleSettings);
             }
        }
        else if (Trigger.isUpdate)
        {
             if (OnUpdate.toUpperCase() == 'TRUE')
             {//On Update and when Create Warranty on IB Update is true
                SVMXC.SVMXC_CreateWarrantyClass.SVMX_CreateWarranty(Trigger.new[i]);
             }
        }
    }
*/
}