@isTest
private class OFFL_OfflineProfiles_UT {
    static testMethod void OFFL_OfflineProfiles_Test(){
        //Dummy Data Creation for coverage
        RecordType erTypes;
        erTypes  = [SELECT Id,Name  FROM RecordType where SobjectType  ='SVMXC__ServiceMax_Config_Data__c' and Name='Offline Profile'];       
        Id OfRecId=erTypes.Id;
        SVMXC__ServiceMax_Config_Data__c SeedRec1= new SVMXC__ServiceMax_Config_Data__c(RecordTypeId=OfRecId, SVMXC__Profile_Name__c='Test', SVMXC__Select__c=true,SVMXC__Active__c=false);
        insert SeedRec1;
        SVMXC__ServiceMax_Config_Data__c SeedRec1A= new SVMXC__ServiceMax_Config_Data__c(RecordTypeId=OfRecId, SVMXC__Profile_Name__c='Test', SVMXC__Select__c=true,SVMXC__Active__c=true);
        insert SeedRec1A;
        SVMXC__ServiceMax_Config_Data__c SeedRec2= new SVMXC__ServiceMax_Config_Data__c(RecordTypeId=OfRecId, SVMXC__Profile_Name__c='Test', SVMXC__Select__c=false);
        insert SeedRec2;
        SVMXC__Offline_Object__c SeedRecObj1= new SVMXC__Offline_Object__c(SVMXC__Offline_Profile__c=SeedRec1.Id);
        insert SeedRecObj1;
        SVMXC__Offline_View__c SeedRecView1= new SVMXC__Offline_View__c(SVMXC__Object_Name__c=SeedRecObj1.Id);
        insert SeedRecView1;
        SVMXC__Offline_Dataset_Expression__c SeedRecExp1= new SVMXC__Offline_Dataset_Expression__c(SVMXC__Offline_Object__c=SeedRecObj1.Id);
        insert SeedRecExp1;
        SVMXC.OFFL_OfflineProfiles myPageCon = new SVMXC.OFFL_OfflineProfiles();
        
        test.starttest();
        //Translations      
        system.assert(myPageCon.getTAG001()!=null,'getTAG001 assertion failed');
        system.assert(myPageCon.getTAG002()!=null,'getTAG002 assertion failed');
        system.assert(myPageCon.getTAG003()!=null,'getTAG003 assertion failed');
        system.assert(myPageCon.getTAG004()!=null,'getTAG004 assertion failed');
        system.assert(myPageCon.getTAG005()!=null,'getTAG005 assertion failed');
        system.assert(myPageCon.getTAG006()!=null,'getTAG006 assertion failed');
        system.assert(myPageCon.getTAG007()!=null,'getTAG007 assertion failed');
        system.assert(myPageCon.getTAG008()!=null,'getTAG008 assertion failed');
        system.assert(myPageCon.getTAG009()!=null,'getTAG009 assertion failed');
        system.assert(myPageCon.getTAG010()!=null,'getTAG010 assertion failed');
        system.assert(myPageCon.getTAG011()!=null,'getTAG011 assertion failed');
        system.assert(myPageCon.getTAG012()!=null,'getTAG012 assertion failed');
        system.assert(myPageCon.getTAG013()!=null,'getTAG013 assertion failed');
        system.assert(myPageCon.getTAG014()!=null,'getTAG014 assertion failed');
        system.assert(myPageCon.getTAG015()!=null,'getTAG015 assertion failed');
        system.assert(myPageCon.getTAG016()!=null,'getTAG016 assertion failed');
        system.assert(myPageCon.getTAG017()!=null,'getTAG017 assertion failed');
        system.assert(myPageCon.getTAG018()!=null,'getTAG018 assertion failed');
        system.assert(myPageCon.getTAG021()!=null,'getTAG021 assertion failed');
        system.assert(myPageCon.getTAG022()!=null,'getTAG022 assertion failed');
        system.assert(myPageCon.getTAG023()!=null,'getTAG023 assertion failed');
        system.assert(myPageCon.getTAG024()!=null,'getTAG024 assertion failed');
        system.assert(myPageCon.getTAG025()!=null,'getTAG025 assertion failed');
        system.assert(myPageCon.getTAG026()!=null,'getTAG026 assertion failed');
        system.assert(myPageCon.getHLPURL()!=null,'getHLPURL assertion failed');
        system.assert(myPageCon.getSET001()!=null,'getSET001 assertion failed');
        
        //myPageCon.svmxTagList.clear();
        
        //Method calling for coverage
        system.assert(myPageCon.getEstRecordTypes()!=null,'getEstRecordTypes assertion failed');
        system.assert(myPageCon.getIsListAvail()!=null,'getIsListAvail assertion failed');
        system.assert(myPageCon.getcustSize()!=null,'getcustSize assertion failed');
        
        myPageCon.isValid('Edit');
        myPageCon.isValid('Clone');
        myPageCon.DelProf();
        myPageCon.DelProf();
        myPageCon.EditProf(); 
        myPageCon.CloneProf();               
        myPageCon.ActProf();
        myPageCon.OfflSVMXprofiles[0].SVMXC__Select__c=true;
        myPageCon.EditProf();
        myPageCon.CloneProf();        
        myPageCon.ActProf();
        myPageCon.OfflSVMXprofiles[0].SVMXC__Select__c=true;
        myPageCon.DeActProf();
        myPageCon.DeActProf();
        myPageCon.GoEditPage();
        myPageCon.GoClonePage();    
        myPageCon.NewProf();
        myPageCon.GoSetupHome();
        
        system.assert(myPageCon.getOfflineBlockLevelMessage()!=null,'getOfflineBlockLevelMessage assertion failed');
        system.assert(myPageCon.getCheckAllLines()!=null,'getCheckAllLines assertion failed');
        myPageCon.setCheckAllLines(true);
        myPageCon.setCheckAllLines(false);
        system.assert(myPageCon.getOfflSVMXprofiles()!=null,'getOfflSVMXprofiles assertion failed');
        test.stoptest();
    }
}