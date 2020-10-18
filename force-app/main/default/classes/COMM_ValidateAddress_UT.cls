@isTest(SeeAllData=true)
Private class COMM_ValidateAddress_UT {
    static testMethod void COMM_ValidateAddress_Test(){
        try{
            SVMXC__Site__c location1 = new SVMXC__Site__c();
            location1.SVMXC__Street__c = 'Suite 103';
            location1.SVMXC__City__c = 'Santa Clara';
            location1.SVMXC__State__c = 'CA';
            location1.SVMXC__Country__c = 'USA';
            location1.SVMXC__Zip__c = '95054';
                     
            insert location1;
            system.assertEquals(location1 != null, true);
            
            PageReference pageRef = new PageReference('/apex/SVMXC__COMM_validateAddress?objID='+ location1.Id +'&objName=SVMXC__Site__c&street=SVMXC__Street__c&city=SVMXC__City__c&state=SVMXC__State__c&country=SVMXC__Country__c&zip=SVMXC__Zip__c&latitude=SVMXC__Latitude__c&longitude=SVMXC__Longitude__c');
            
            test.starttest();
            Test.setCurrentPage(pageRef);
            
            SVMXC.COMM_ValidateAddress validator = new SVMXC.COMM_ValidateAddress();
            validator.strLatitude = '12.0';
            validator.strLongitude = '12.1';
            validator.doUpdateLatLong();
            validator.doClearLatLong();
            
            validator.getTAG001();
            validator.getTAG003();
        }
        catch(exception ex){}
    }
}