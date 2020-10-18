@isTest
Private class EVER_SCResults_UT {

static testMethod void EVER_SCResults_Test()
        {
            try
            {
     
            Account account = new Account(
                                            Name ='Account',
                                            ShippingStreet='ABC',
                                            ShippingCity='PQR ',
                                            ShippingState = 'XYZ',
                                            ShippingPostalCode='111',
                                            ShippingCountry='XYZ',
                                            BillingStreet='ABC',
                                            BillingCity='PQR ',
                                            BillingState = 'XYZ',
                                            BillingPostalCode='111',
                                            BillingCountry='XYZ'
                                            ); 
            insert account;
           test.starttest();
           SVMXC.EVER_SCResults obj1 = new SVMXC.EVER_SCResults();
            Id Idd = account.Id;
            obj1.setStartDate(System.Today());
            obj1.setEndDate(System.Today());
            obj1.setCoveredBy('CoveredBy' );
            obj1.setSCName('SCName ');
            obj1.setSCId(Idd);
            obj1.setSLAName('SLAName');
            obj1.setSLAID(Idd);
            obj1.setidSelectdIS(account.Id);
            obj1.setstrNameIS('testing');
            obj1.setstrUnitsAvl('testing');
            
            List<SVMXC__Service_Contract_Services__c> lstCS = new List<SVMXC__Service_Contract_Services__c>();
            SVMXC__Service_Contract_Services__c IncludedServices1 = new SVMXC__Service_Contract_Services__c();
            SVMXC__Service_Contract_Services__c IncludedServices2 = new SVMXC__Service_Contract_Services__c();
            lstCS.add(IncludedServices1);
            lstCS.add(IncludedServices2);
            
            List<SVMXC.EVER_SCResults.IncludedServicesWrapper> lstWrpr = new List<SVMXC.EVER_SCResults.IncludedServicesWrapper>();
            SVMXC.EVER_SCResults.IncludedServicesWrapper wrprObj1 = new SVMXC.EVER_SCResults.IncludedServicesWrapper();
            SVMXC.EVER_SCResults.IncludedServicesWrapper wrprObj2 = new SVMXC.EVER_SCResults.IncludedServicesWrapper();
            wrprObj2.strServiceName = '';
            wrprObj2.isQualified = false;        
            wrprObj2.strTracked = '';
            lstWrpr.add(wrprObj1);
            lstWrpr.add(wrprObj2);
            
            wrprObj2.setIncludedServices(IncludedServices1);
            wrprObj2.getIncludedServices();
            
            obj1.setlstISWrapper(lstWrpr);
            
           
            Date d = System.Today();
            String str;
            Boolean b;
            
            d = obj1.getStartDate();
            d  = obj1.getEndDate();
            str = obj1.getCoveredBy();
            str = obj1.getSCName();
            Idd= obj1.getSCId();
            str = obj1.getSLAName();
            Idd= obj1.getSLAID();
            System.assert(str!=null);
            b=obj1.getselected();
            obj1.setselected(true);
            obj1.getidSelectdIS();
            obj1.getstrNameIS();
            obj1.getstrUnitsAvl();
            obj1.getlstISWrapper();
            
            str = obj1.getSDate();
            str = obj1.getEDate();      
            obj1.setStartDate(null);
            obj1.setEndDate(null);              
            str = obj1.getSDate();
            str = obj1.getEDate();
            System.assertNotEquals(d,null);
            System.assertNotEquals(d,null);
            System.assertNotEquals(Idd,null);
            
            SVMXC.EVER_SCResults obj2 = new SVMXC.EVER_SCResults(d,d,'CoveredBy','SCName',Idd,'SLA');
            test.stoptest();
            
            
  }
  catch(Exception ex)
       {
         ApexPages.addMessage(new ApexPages.Message ( ApexPages.Severity.ERROR, ex.getMessage()));
       }

}
}