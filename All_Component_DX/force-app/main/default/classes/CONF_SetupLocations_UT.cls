@isTest
Private class CONF_SetupLocations_UT 
{
    static testMethod void CONF_SetupLocations_UT_Test()
    {
        RecordType RTDepotParent = [select id, Name from RecordType where Name = 'Depot Parent'and SobjectType='SVMXC__Site__c' Limit 1];
        RecordType RTDepot = [select id, Name from RecordType where Name = 'Depot'and SobjectType='SVMXC__Site__c' Limit 1];
        RecordType RTDepotChild = [select id, Name from RecordType where Name = 'Depot Child'and SobjectType='SVMXC__Site__c' Limit 1];
        
        SVMXC__Site__c loc1 = new SVMXC__Site__c();
        loc1.RecordTypeId = RTDepotParent.Id;
        loc1.Name = 'Mysore';
        insert loc1;
        
        SVMXC__Site__c loc2 = new SVMXC__Site__c();
        loc2.RecordTypeId = RTDepot.Id;
        loc2.SVMXC__Location_Type__c = 'Supplier';
        loc2.Name = 'Bangalore';
        insert loc2;
        
        loc2.SVMXC__Parent__c = loc1.Id;
        update loc2;
        
        SVMXC__Site__c loc3 = new SVMXC__Site__c();
        loc3.RecordTypeId = RTDepotChild.Id;
        loc3.SVMXC__IsDefault_Delivery__c = true;
        loc3.SVMXC__Parent__c = loc2.Id;
        loc3.IsGood_Stock__c = true;
        loc3.Name = 'Hubli';
        insert loc3;
        
        CONF_SetupLocations.depotChildLocWrapper wrap = new CONF_SetupLocations.depotChildLocWrapper();
        wrap.getLoc();
        
        CONF_SetupLocations setupLoc = new CONF_SetupLocations();
        setupLoc.locID = loc1.Id;
        setupLoc.QuerySelLoc();
        setupLoc.onChngLocType();
        setupLoc.locID = loc2.Id;
        setupLoc.QuerySelLoc();
        setupLoc.quickSave();
        setupLoc.onChngLocType();
        setupLoc.addTopLevel();
        setupLoc.cancel();
        setupLoc.addDepotChild();
        setupLoc.deleteDepotChild();
        setupLoc.addLevel();
        setupLoc.addDepot();
        setupLoc.getValidateAddress();
        setupLoc.outboundRouting();
        setupLoc.deleteLoc();
        setupLoc.saveClose();
        List<CONF_SetupLocations.depotChildLocWrapper> xwrap = setupLoc.getLstDepotChildLocWrap();
        setupLoc.setLstDepotChildLocWrap(xwrap);
        List<SVMXC__Site__c> lst = setupLoc.getlstDipotChildLocToDisplay();
        setupLoc.setlstDipotChildLocToDisplay(lst);
        setupLoc.getlstLocType();
        setupLoc.getlstFunction();
        setupLoc.cancelToNew();
        setupLoc.getTAG001();
        setupLoc.getTAG002();
        setupLoc.getTAG003();
        setupLoc.getTAG004();
        setupLoc.getTAG005();
        setupLoc.getTAG006();
        setupLoc.getTAG007();
        setupLoc.getTAG008();
        setupLoc.getTAG009();
        setupLoc.getTAG010();
        setupLoc.getTAG011();
        setupLoc.getTAG012();
        setupLoc.getTAG013();
        setupLoc.getTAG014();
        setupLoc.getTAG015();
        setupLoc.getTAG016();
        setupLoc.getTAG017();
        setupLoc.getTAG018();
        setupLoc.getTAG019();
        setupLoc.getTAG020();
        setupLoc.getTAG021();
        setupLoc.getTAG022();
        setupLoc.getTAG024();
        setupLoc.getTAG025();
        setupLoc.getTAG026();
        setupLoc.getTAG031();
        setupLoc.getTAG050();
        setupLoc.getTAG051();
        setupLoc.getTAG052();
        setupLoc.getTAG041();
        setupLoc.getTAG042();
        setupLoc.getTAG043();
        setupLoc.getTAG034();
        setupLoc.getTAG045();
        setupLoc.getTAG046();
        setupLoc.getTAG047();
        setupLoc.getTAG048();
    }
}