global with sharing class COMM_Utils_ManageModules {

global SVMXC__ServiceMax_Processes__c SVMX_cloneSubModule(String existSubModuleId, String newSubModuleId, String installKey, String newModuleId, String newModuleSFDCId)
    {
            if(existSubModuleId != null && newSubModuleId != null && newSubModuleId.length() >0 && existSubModuleId.length() >0)
            {
                    SVMXC__ServiceMax_Processes__c exSubMod = [Select Id, SVMXC__Submodule__c, SVMXC__SubmoduleID__c, SVMXC__Record_Type_Name__c, SVMXC__Name__c, SVMXC__Module__c, SVMXC__ModuleID__c, SVMXC__IsStandard__c, SVMXC__IsPrivate__c, SVMXC__Installation_Key__c, SVMXC__Description__c, SVMXC__Active__c, Name From SVMXC__ServiceMax_Processes__c WHERE recordType.Name = 'Submodule' AND SVMXC__SubmoduleID__c = :existSubModuleId ]; //SDL-SVMX-FLS-NOT-ENFORCED-META-DATA
                                                        
                    SVMXC__ServiceMax_Processes__c nwSubModule =    exSubMod.clone(false, true);
                        nwSubModule.SVMXC__Installation_Key__c =  installKey;  
                        nwSubModule.SVMXC__SubmoduleID__c =  newSubModuleId;      
                        nwSubModule.SVMXC__Module__c = newModuleSFDCId;
                        nwSubModule.SVMXC__ModuleID__c = newModuleId;
                        nwSubModule.SVMXC__Name__c = nwSubModule.SVMXC__Name__c + ' - '+newSubModuleId;
                    
                    //insert  nwSubModule; //commented for the security scanner issue
                    if(COMM_SecurityUtils.getInstance().verifyFieldAccess(nwSubModule, COMM_SecurityUtils.Access.Createable)){
                        insert  nwSubModule; //SDL-SVMX-CREATE-UPDATE-FLS-ENFORCED
                    }else{
                        throw new COMM_SecurityUtils.SecurityAccessException(System.label.COMM001_TAG142);
                    }
                              
                return nwSubModule; //Error
            }
            else
                return null;
    }
}