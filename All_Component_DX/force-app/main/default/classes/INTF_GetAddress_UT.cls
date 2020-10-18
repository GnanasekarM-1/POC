@isTest
private class INTF_GetAddress_UT {

    static testMethod void myUnitTest() {
        //............................Data Creation.........................//
        SVMXC__Installed_Product__c ib = new SVMXC__Installed_Product__c ();
        ib.SVMXC__Street__c = 'Street';
        ib.SVMXC__City__c = 'City';
        ib.SVMXC__State__c = 'State';
        ib.SVMXC__Zip__c = 'Zip';
        ib.SVMXC__Country__c = 'Country';
        insert ib;
        System.assertEquals(true, ib != null);
                        
        //..........Instance of Class.............//
        INTF_buildSobjectFromKeyValue  BuildSobj_Keyvalue= new INTF_buildSobjectFromKeyValue();
        //Key value pair of workorder
        INTF_WebServicesDef.INTF_StringMap Stringmap1 = new INTF_WebServicesDef.INTF_StringMap('ADDRESSTYPE','TOADDRESS');
        INTF_WebServicesDef.INTF_StringMap Stringmap2= new INTF_WebServicesDef.INTF_StringMap('IBID',ib.id);
        INTF_WebServicesDef.INTF_StringMap Stringmapfrom1 = new INTF_WebServicesDef.INTF_StringMap('ADDRESSTYPE','FROMADDRESS');
        INTF_WebServicesDef.INTF_StringMap Stringmapto1 = new INTF_WebServicesDef.INTF_StringMap('ADDRESSTYPE','TOLOCATION');
        INTF_WebServicesDef.INTF_StringMap StringmapfromLoc1 = new INTF_WebServicesDef.INTF_StringMap('ADDRESSTYPE','FROMLOCATION');
        
 
        List<SVMXC.INTF_WebServicesDef.INTF_StringMap> stringmapLst= new List<SVMXC.INTF_WebServicesDef.INTF_StringMap>();
        stringmapLst.add(Stringmap1);
        stringmapLst.add(Stringmap2);
        System.assertEquals(true, stringmapLst!= null);
        
        List<SVMXC.INTF_WebServicesDef.INTF_StringMap> stringmapLstfrom= new List<SVMXC.INTF_WebServicesDef.INTF_StringMap>();
        stringmapLstfrom.add(Stringmapfrom1);
        stringmapLstfrom.add(Stringmap2);
        
        List<SVMXC.INTF_WebServicesDef.INTF_StringMap> stringmapLstto= new List<SVMXC.INTF_WebServicesDef.INTF_StringMap>();
        stringmapLstto.add(Stringmapto1);
        
        List<SVMXC.INTF_WebServicesDef.INTF_StringMap> stringmapLstFromLoc= new List<SVMXC.INTF_WebServicesDef.INTF_StringMap>();
        stringmapLstFromLoc.add(StringmapfromLoc1);
        

        //Key value pair of Workdetail
        



        //............Call Methods..............//
        //Sobject sobj =  BuildSobj_Keyvalue.BuildSobjectFromKeyValue(stringmapLst,ObjName1,RecId1);

        String ObjName ='SVMXC__Service_Order_Line__c';
        Account acc = new Account();
        acc.Name = 'Company';
        acc.BillingStreet = 'Street';
        acc.BillingCity= 'city';
        acc.BillingState = 'State';
        acc.BillingPostalCode = '60065';
        acc.BillingCountry = 'Country';
        
        insert acc;
        System.assertEquals(true, acc!= null);
        
        Account acc2 = new Account();
        acc2.Name = 'Company';
        acc2.ShippingStreet = 'ShippingStreet';
        acc2.ShippingState= 'ShippingState';
        acc2.ShippingPostalCode = 'ShippingPostalCode';
        acc2.ShippingCountry = 'ShippingCountry';
        acc2.ShippingCity = 'ShippingCity';
        insert acc2;
        System.assertEquals(true, acc2!= null);
        
        Contact cont = new Contact();
        cont.Account=acc2;
        cont.FirstName = 'FirstName';
        cont.LastName = 'LastName';
        insert cont;
        System.assertEquals(true, cont!= null);
        
        Contact cont2 = new Contact();
        cont2.Account=acc2;
        cont2.FirstName = 'FirstName';
        cont2.LastName = 'LastName';
        cont2.MailingStreet = 'MailingStreet';
        cont2.MailingCity = 'MailingCity';
        cont2.MailingState = 'MailingState';
        cont2.MailingPostalCode = 'MailingPostalCode';
        cont2.MailingCountry = 'MailingCountry';
        insert cont2;
        System.assertEquals(true, cont2!= null);
        
        Contact cont3 = new Contact();
        cont3.Account=acc2;
        cont3.FirstName = 'FirstName';
        cont3.LastName = 'LastName';
        cont3.OtherStreet = 'OtherStreet';
        cont3.OtherCity = 'OtherCity';
        cont3.OtherState = 'OtherState';
        cont3.OtherPostalCode = 'OtherPostalCode';
        cont3.OtherCountry = 'OtherCountry';
        insert cont3;
        System.assertEquals(true, cont3!= null);
        
        SVMXC__Site__c loc = new SVMXC__Site__c();
        loc.SVMXC__Street__c = 'SVMXC__Street__c';
        loc.SVMXC__City__c = 'SVMXC__City__c';
        loc.SVMXC__State__c = 'SVMXC__State__c';
        loc.SVMXC__Zip__c = 'SVMXC__Zip__c';
        loc.SVMXC__Country__c  = 'SVMXC__Country__c ';
        insert loc;
        System.assertEquals(true, loc!= null);
        
        SVMXC__RMA_Shipment_Order__c svoSObj = new SVMXC__RMA_Shipment_Order__c();  
        svoSObj.SVMXC__Address_Type__c = 'Account Billing Address';
        svoSObj.SVMXC__Company__c = acc.id;
        insert svoSObj;
        System.assertEquals(true, svoSObj!= null);
        
        SVMXC__RMA_Shipment_Order__c svoSObj1 = new SVMXC__RMA_Shipment_Order__c(); 
        svoSObj1.SVMXC__Address_Type__c = 'Account Shipping Address';
        svoSObj1.SVMXC__Contact__c = cont.Id;
        insert svoSObj1;
        System.assertEquals(true, svoSObj1!= null);
        
        SVMXC__RMA_Shipment_Order__c svoSObj2 = new SVMXC__RMA_Shipment_Order__c(); 
        svoSObj2.SVMXC__Address_Type__c = 'Contact Mailing Address';
        svoSObj2.SVMXC__Contact__c = cont2.Id;
        insert svoSObj2;
        System.assertEquals(true, svoSObj2!= null);
        
        SVMXC__RMA_Shipment_Order__c svoSObj3 = new SVMXC__RMA_Shipment_Order__c(); 
        svoSObj3.SVMXC__Address_Type__c = 'Contact Other Address';
        svoSObj3.SVMXC__Contact__c = cont3.Id;
        insert svoSObj3;
        System.assertEquals(true, svoSObj3!= null);
        
        SVMXC__RMA_Shipment_Order__c svoSObj4 = new SVMXC__RMA_Shipment_Order__c(); 
        svoSObj4.SVMXC__Address_Type__c = 'Installed Product Address';
        insert svoSObj4;
        System.assertEquals(true, svoSObj4!= null);
        
        SVMXC__RMA_Shipment_Order__c svoSObj5 = new SVMXC__RMA_Shipment_Order__c(); 
        svoSObj5.SVMXC__Address_Type__c = 'Installed Product Address';
        insert svoSObj5;
        System.assertEquals(true, svoSObj5!= null);
        
        SVMXC__RMA_Shipment_Order__c svoSObj6 = new SVMXC__RMA_Shipment_Order__c(); 
        svoSObj6.SVMXC__Address_Type__c = 'TOLOCATION';
        svoSObj6.SVMXC__Destination_Location__c = loc.id;
        insert svoSObj6;
        System.assertEquals(true, svoSObj6!= null);
        
        SVMXC__RMA_Shipment_Order__c svoSObj7 = new SVMXC__RMA_Shipment_Order__c(); 
        svoSObj7.SVMXC__Address_Type__c = 'TOLOCATION';
        svoSObj7.SVMXC__Source_Location__c = loc.id;
        insert svoSObj7;
        System.assertEquals(true, svoSObj7!= null);
        
        SVMXC.INTF_getAddress gtAddress = new SVMXC.INTF_getAddress();
        gtAddress.getAddress(svoSObj, stringmapLst);
        gtAddress.getAddress(svoSObj1, stringmapLst);
        gtAddress.getAddress(svoSObj2, stringmapLst);
        gtAddress.getAddress(svoSObj3, stringmapLst);
        gtAddress.getAddress(svoSObj4, stringmapLst);
        gtAddress.getAddress(svoSObj, stringmapLstfrom);
        gtAddress.getAddress(svoSObj1, stringmapLstfrom);
        gtAddress.getAddress(svoSObj2, stringmapLstfrom);
        gtAddress.getAddress(svoSObj3, stringmapLstfrom);
        gtAddress.getAddress(svoSObj4, stringmapLstfrom);
        gtAddress.getAddress(svoSObj6, stringmapLstto);
        gtAddress.getAddress(svoSObj7, stringmapLstFromLoc);
    }
}