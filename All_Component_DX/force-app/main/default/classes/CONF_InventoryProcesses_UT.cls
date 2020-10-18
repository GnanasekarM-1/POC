@isTest(SeeAlldata=true)
Private class CONF_InventoryProcesses_UT{
    private static SVMXC.CONF_InventoryProcesses inobject;
    static testMethod void CONF_InventoryProcesses_UT(){
        RecordType[] rts = [SELECT Id, Name FROM RecordType WHERE SobjectType = 'SVMXC__ServiceMax_Processes__c'];    
        SVMXC__ServiceMax_Processes__c Process;
        list<SVMXC__ServiceMax_Processes__c> lstPro = new list<SVMXC__ServiceMax_Processes__c>();
        SVMXC__ServiceMax_Processes__c pro1;
        SVMXC__ServiceMax_Processes__c pro2;
        for(RecordType rt : rts){ //Loop to take a record type at a time
            // Create Module Record
            if(rt.Name == 'Inventory Process'){
                pro1 = new SVMXC__ServiceMax_Processes__c(RecordTypeId =rt.Id,SVMXC__ProcessID__c = 'CUSTOMINVPRO1',SVMXC__Name__c = 'Process Shipment',SVMXC__Description__c = 'Process Shipment',SVMXC__Active__c = true,SVMXC__IsStandard__c = false);
                lstPro.add(pro1);
                
                pro2 = new SVMXC__ServiceMax_Processes__c(RecordTypeId =rt.Id,SVMXC__ProcessID__c = 'CUSTOMINVPRO2',SVMXC__Name__c = 'Process Shipment1',SVMXC__Description__c = 'Process Shipment1',SVMXC__Active__c = true,SVMXC__IsStandard__c = false);
                lstPro.add(pro2);
                Process = pro1;
            }
        }
        insert lstPro;  
        PageReference pageRef1 = new PageReference('Page.SVMXC.CONF_InventoryProcesses');
        Test.setCurrentPageReference(pageRef1); 
        inobject = new SVMXC.CONF_InventoryProcesses(); 
        inobject.stdProcesses[0].SVMXC__Select__c = true;
        inobject.stdValidata();
        inobject.SVMX_View();
        inobject.SVMX_dostdClone();
        inobject.stdProcesses[1].SVMXC__Select__c = true;
        inobject.stdValidata();
        inobject.SVMX_View();
        inobject.SVMX_new();
        inobject.SVMX_dostdClone();
        inobject.stdProcesses[0].SVMXC__Select__c = false;
        inobject.stdProcesses[1].SVMXC__Select__c = false;
        inobject.getcustProcesses();
        inobject.custProcesses[0].SVMXC__Select__c = true;
        inobject.custValidata();
        inobject.SVMX_new();
        inobject.SVMX_doedit();
        inobject.SVMX_docustClone();
        inobject.custProcesses[1].SVMXC__Select__c = true;
        inobject.custValidata();
        inobject.SVMX_new();
        inobject.SVMX_doedit();
        inobject.SVMX_docustClone();
        inobject.getstdProcesses();
        inobject.getDisplayBlock1Message();
        inobject.getDisplayBlock2Message();
        
        inobject.SVMX_GoHome();
        inobject.SVMX_doDelete();
        
        system.assert(inobject.getHLPURL()!=null,'getHLPURL assertion failed');
        system.assert(inobject.getTAG001()!=null,'getTAG001 assertion failed');
        system.assert(inobject.getTAG002()!=null,'getTAG002 assertion failed');
        system.assert(inobject.getTAG003()!=null,'getTAG003 assertion failed');
        system.assert(inobject.getTAG004()!=null,'getTAG004 assertion failed');
        system.assert(inobject.getTAG005()!=null,'getTAG005 assertion failed');
        system.assert(inobject.getTAG006()!=null,'getTAG006 assertion failed');
        system.assert(inobject.getTAG007()!=null,'getTAG007 assertion failed');
        system.assert(inobject.getTAG008()!=null,'getTAG008 assertion failed');
        system.assert(inobject.getTAG009()!=null,'getTAG009 assertion failed');
        system.assert(inobject.getTAG010()!=null,'getTAG010 assertion failed');
        system.assert(inobject.getTAG011()!=null,'getTAG011 assertion failed');
        system.assert(inobject.getTAG012()!=null,'getTAG012 assertion failed');
        system.assert(inobject.getTAG013()!=null,'getTAG013 assertion failed');
        system.assert(inobject.getTAG014()!=null,'getTAG014 assertion failed');
        system.assert(inobject.getTAG015()!=null,'getTAG015 assertion failed');
        system.assert(inobject.getTAG016()!=null,'getTAG016 assertion failed');
        system.assert(inobject.getTAG017()!=null,'getTAG017 assertion failed');
        system.assert(inobject.getTAG018()!=null,'getTAG018 assertion failed');
        system.assert(inobject.getTAG019()!=null,'getTAG019 assertion failed');
        system.assert(inobject.getTAG020()!=null,'getTAG020 assertion failed');
        system.assert(inobject.getTAG021()!=null,'getTAG021 assertion failed');
        
        //inobject.svmxTagList.clear();
        
        system.assert(inobject.getHLPURL()!=null,'getHLPURL assertion failed');
        system.assert(inobject.getTAG001()!=null,'getTAG001 assertion failed');
        system.assert(inobject.getTAG002()!=null,'getTAG002 assertion failed');
        system.assert(inobject.getTAG003()!=null,'getTAG003 assertion failed');
        system.assert(inobject.getTAG004()!=null,'getTAG004 assertion failed');
        system.assert(inobject.getTAG005()!=null,'getTAG005 assertion failed');
        system.assert(inobject.getTAG006()!=null,'getTAG006 assertion failed');
        system.assert(inobject.getTAG007()!=null,'getTAG007 assertion failed');
        system.assert(inobject.getTAG008()!=null,'getTAG008 assertion failed');
        system.assert(inobject.getTAG009()!=null,'getTAG009 assertion failed');
        system.assert(inobject.getTAG010()!=null,'getTAG010 assertion failed');
        system.assert(inobject.getTAG011()!=null,'getTAG011 assertion failed');
        system.assert(inobject.getTAG012()!=null,'getTAG012 assertion failed');
        system.assert(inobject.getTAG013()!=null,'getTAG013 assertion failed');
        system.assert(inobject.getTAG014()!=null,'getTAG014 assertion failed');
        system.assert(inobject.getTAG015()!=null,'getTAG015 assertion failed');
        system.assert(inobject.getTAG016()!=null,'getTAG016 assertion failed');
        system.assert(inobject.getTAG017()!=null,'getTAG017 assertion failed');
        system.assert(inobject.getTAG018()!=null,'getTAG018 assertion failed');
        system.assert(inobject.getTAG019()!=null,'getTAG019 assertion failed');
        system.assert(inobject.getTAG020()!=null,'getTAG020 assertion failed');
        system.assert(inobject.getTAG021()!=null,'getTAG021 assertion failed');
        
        delete inobject.stdProcesses;
        inobject = new SVMXC.CONF_InventoryProcesses(); 
    }
}