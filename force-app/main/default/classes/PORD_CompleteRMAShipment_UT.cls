@isTest(SeeAllData=true)
private class PORD_CompleteRMAShipment_UT {
  
  private static SVMXC.PORD_CreateRMAFromWO ControllerObj1;
    private static Account account;
    private static Contact contact ;
    private static Case case1;
    private static Product2  prodShpLine,prod;      
    private static Pricebook2 pbStd; 
    private static PricebookEntry pbe,pbe1;
    private static SVMXC__Site__c sourceLocation,destLocation;   
     
    private static RecordType rtSHP,rtSHPLine,rtRR ;
    private static SVMXC__RMA_Shipment_Order__c shpObject1,shpObject2,shpObject3;
    private static SVMXC__RMA_Shipment_Line__c  shpLineObject1,shpLineObject2,shpLineObject3,shpLineObject4,shpLineObject5;
    private static List<SVMXC__RMA_Shipment_Line__c> shpLineArray = new List<SVMXC__RMA_Shipment_Line__c>();

    static testMethod void UnitTest1() {
  
         
        List<RecordType> AllRecordTypes = [SELECT Id , Name,SobjectType  FROM RecordType];
        RecordType rtype = [Select Id,Name from RecordType where SobjectType = 'SVMXC__RMA_Shipment_Order__c' AND Name='RMA' limit 1];
             
        account = new Account(
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
        system.assert(account.Name!=null);
        system.assert(account.ShippingStreet!=null);
        system.assert(account.ShippingState!=null);
        
        contact = new Contact(LastName='Last',AccountId =account.Id,Email='svmxmailfortest@servicemax.com',
                                        OtherStreet = 'Other', OtherState ='CA', OtherPostalCode ='95051', OtherCountry ='USA',OtherCity='ABC',
                                        MailingStreet = 'Other', MailingState ='CA', MailingPostalCode ='95051', MailingCountry ='USA',MailingCity='ABC');
        insert contact;

        case1 = new Case(Status ='New', Priority = 'Medium', 
                                        Origin = 'Email',                                        
                                                                                    
                                        ContactId =contact.Id,
                                        AccountId=account.Id                                         
                                        ); 
        insert case1;
        system.assert(case1.Status!=null);

        prodShpLine =     new Product2(
                                       Name = 'prodShpLine', 
                                       ProductCode = '1235', 
                                       Family = 'Accessory', 
                                       SVMXC__Inherit_Parent_Warranty__c =True 
                                       );
                                       
        insert prodShpLine;
     
        prod =       new Product2(
                                       Name = 'Prod', 
                                       ProductCode = '1235', 
                                       Family = 'Accessory', 
                                       SVMXC__Inherit_Parent_Warranty__c =True 
                                       );
                                       
        insert prod;


        for ( RecordType rectype:AllRecordTypes)
            {
            if ((rectype.Name =='Shipment')&&(rectype.SobjectType =='SVMXC__RMA_Shipment_Order__c'))                
                rtSHP = rectype;
                
            }
        for ( RecordType rectype:AllRecordTypes)
            {
            if ((rectype.Name =='Shipment')&&(rectype.SobjectType =='SVMXC__RMA_Shipment_Line__c'))             
                rtSHPLine = rectype;
                
            }
        for ( RecordType rectype:AllRecordTypes)
            {
            if ((rectype.Name =='Request/Receipt')&&(rectype.SobjectType =='SVMXC__Service_Order_Line__c'))             
                rtRR = rectype;
                
            }   
     sourceLocation = new SVMXC__Site__c(
                                        SVMXC__Zip__c ='90909090',
                                        SVMXC__Street__c ='ABC',
                                        SVMXC__State__c ='ABC',
                                        SVMXC__Country__c ='ABC',
                                        SVMXC__City__c ='ABC',
                                        SVMXC__Account__c=account.Id
                                        );
     insert sourceLocation;
    
     destLocation = new SVMXC__Site__c(
                                        SVMXC__Zip__c ='90909090',
                                        SVMXC__Street__c ='ABC',
                                        SVMXC__State__c ='ABC',
                                        SVMXC__Country__c ='ABC',
                                        SVMXC__City__c ='ABC',
                                        SVMXC__Account__c=account.Id
                                        );
    insert destLocation;
       
   
    shpObject1 = new SVMXC__RMA_Shipment_Order__c(
                                             SVMXC__Source_Location__c =sourceLocation.Id, 
                                             SVMXC__Expected_Delivery_Date__c =System.today(), 
                                             SVMXC__Destination_Location__c=destLocation.Id, 
                                             SVMXC__Contact__c =contact.Id, 
                                             SVMXC__Company__c=account.Id, 
                                             SVMXC__Case__c =case1.Id, 
                                             RecordTypeId = rtSHP.Id,
                                              
                                             SVMXC__Order_Status__c='Open'                                           
                                             );
    insert shpObject1;

     shpObject2 = new SVMXC__RMA_Shipment_Order__c(
                                             SVMXC__Source_Location__c =sourceLocation.Id, 
                                             SVMXC__Expected_Delivery_Date__c =System.today(), 
                                             SVMXC__Destination_Location__c=destLocation.Id, 
                                             SVMXC__Contact__c =contact.Id, 
                                             SVMXC__Company__c=account.Id, 
                                             SVMXC__Case__c =case1.Id, 
                                             RecordTypeId = rtSHP.Id,
                                              
                                             SVMXC__Order_Status__c='Open'                                           
                                             );
    insert shpObject2;
    
    shpObject3 = new SVMXC__RMA_Shipment_Order__c(
                                             SVMXC__Source_Location__c =sourceLocation.Id, 
                                             SVMXC__Expected_Delivery_Date__c =System.today(), 
                                             SVMXC__Destination_Location__c=destLocation.Id, 
                                             SVMXC__Contact__c =contact.Id, 
                                             SVMXC__Company__c=account.Id, 
                                             SVMXC__Case__c =case1.Id, 
                                             RecordTypeId = rtype.Id,// recordtype is RMA
                                             SVMXC__Order_Status__c = 'Open'
                                             );
    insert shpObject3;
  
  shpLineObject1 = new SVMXC__RMA_Shipment_Line__c(
                                                    SVMXC__RMA_Shipment_Order__c=shpObject3.Id , 
                                                    RecordTypeId = rtSHPLine.Id ,
                                                    SVMXC__Product__c = prodShpLine.Id,
                                                    SVMXC__Line_Status__c ='Open',
                                                    SVMXC__Select__c = true,
                                                    SVMXC__Actual_Quantity2__c =3
                                                    ); 
    insert shpLineObject1;
  
  system.currentPageReference().getParameters().put('RecId', shpObject3.Id);
  PORD_CompleteRMAShipment CompleteRmaShipment = new PORD_CompleteRMAShipment();
  CompleteRmaShipment.getDisableCommit();
  CompleteRmaShipment.getdisplayImage();
  CompleteRmaShipment.getTAG001();
  CompleteRmaShipment.getTAG002();
  CompleteRmaShipment.getTAG003();
  CompleteRmaShipment.getTAG004();
  CompleteRmaShipment.getTAG005();
  CompleteRmaShipment.getTAG006();
  CompleteRmaShipment.getTAG007();
  CompleteRmaShipment.getTAG008();
  CompleteRmaShipment.getTAG009();
  CompleteRmaShipment.getTAG010();
  CompleteRmaShipment.getTAG011();
  CompleteRmaShipment.getTAG012();
  CompleteRmaShipment.getTAG013();
  CompleteRmaShipment.getTAG014();
  CompleteRmaShipment.getHLPURL();
  CompleteRmaShipment.SVMXC_CompleteRMA(shpObject3.Id);
  CompleteRmaShipment.SVMX_SaveRMAShipment();
  CompleteRmaShipment.SVMXC_GoBacktoRecord();
  }
  static testMethod void UnitTest2() {
        List<RecordType> AllRecordTypes = [SELECT Id , Name,SobjectType  FROM RecordType];
        RecordType rtype = [Select Id,Name from RecordType where SobjectType = 'SVMXC__RMA_Shipment_Order__c' AND Name='RMA' limit 1];
        for ( RecordType rectype:AllRecordTypes)
        {
          if ((rectype.Name =='Shipment')&&(rectype.SobjectType =='SVMXC__RMA_Shipment_Line__c'))             
              rtSHPLine = rectype;
        }
        
        account = new Account(
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
        system.assert(account.Name!=null);
        system.assert(account.ShippingStreet!=null);
        system.assert(account.ShippingState!=null);
        
        contact = new Contact(LastName='Last',AccountId =account.Id,Email='svmxmailfortest@servicemax.com',
                                        OtherStreet = 'Other', OtherState ='CA', OtherPostalCode ='95051', OtherCountry ='USA',OtherCity='ABC',
                                        MailingStreet = 'Other', MailingState ='CA', MailingPostalCode ='95051', MailingCountry ='USA',MailingCity='ABC');
        insert contact;

        case1 = new Case(Status ='New', Priority = 'Medium', 
                                        Origin = 'Email',                                        
                                                                                    
                                        ContactId =contact.Id,
                                        AccountId=account.Id                                         
                                        ); 
        insert case1;
        system.assert(case1.Status!=null);

        prodShpLine =     new Product2(
                                       Name = 'prodShpLine', 
                                       ProductCode = '1235', 
                                       Family = 'Accessory', 
                                       SVMXC__Inherit_Parent_Warranty__c =True 
                                       );
                                       
        insert prodShpLine;
     
        prod =       new Product2(
                                       Name = 'Prod', 
                                       ProductCode = '1235', 
                                       Family = 'Accessory', 
                                       SVMXC__Inherit_Parent_Warranty__c =True 
                                       );
                                       
        insert prod;
     sourceLocation = new SVMXC__Site__c(
                                        SVMXC__Zip__c ='90909090',
                                        SVMXC__Street__c ='ABC',
                                        SVMXC__State__c ='ABC',
                                        SVMXC__Country__c ='ABC',
                                        SVMXC__City__c ='ABC',
                                        SVMXC__Account__c=account.Id
                                        );
     insert sourceLocation;
    
     destLocation = new SVMXC__Site__c(
                                        SVMXC__Zip__c ='90909090',
                                        SVMXC__Street__c ='ABC',
                                        SVMXC__State__c ='ABC',
                                        SVMXC__Country__c ='ABC',
                                        SVMXC__City__c ='ABC',
                                        SVMXC__Account__c=account.Id
                                        );
    insert destLocation;

    shpObject3 = new SVMXC__RMA_Shipment_Order__c(
                                             SVMXC__Source_Location__c =sourceLocation.Id, 
                                             SVMXC__Expected_Delivery_Date__c =System.today(), 
                                             SVMXC__Destination_Location__c=destLocation.Id, 
                                             SVMXC__Contact__c =contact.Id, 
                                             SVMXC__Company__c=account.Id, 
                                             SVMXC__Case__c =case1.Id, 
                                             RecordTypeId = rtype.Id,// recordtype is RMA
                                             SVMXC__Order_Status__c = 'Closed'
                                             );
    insert shpObject3;
  
  shpLineObject1 = new SVMXC__RMA_Shipment_Line__c(
                                                    SVMXC__RMA_Shipment_Order__c=shpObject3.Id , 
                                                    RecordTypeId = rtSHPLine.Id ,
                                                    SVMXC__Product__c = prodShpLine.Id,
                                                    SVMXC__Line_Status__c ='Closed',
                                                    SVMXC__Select__c = true,
                                                    SVMXC__Actual_Quantity2__c =3
                                                    ); 
    insert shpLineObject1;
  
  system.currentPageReference().getParameters().put('RecId', shpObject3.Id);
  PORD_CompleteRMAShipment CompleteRmaShipment = new PORD_CompleteRMAShipment();
  CompleteRmaShipment.getDisableCommit();
  CompleteRmaShipment.getdisplayImage();
  CompleteRmaShipment.getTAG001();
  CompleteRmaShipment.getTAG002();
  CompleteRmaShipment.getTAG003();
  CompleteRmaShipment.getTAG004();
  CompleteRmaShipment.getTAG005();
  CompleteRmaShipment.getTAG006();
  CompleteRmaShipment.getTAG007();
  CompleteRmaShipment.getTAG008();
  CompleteRmaShipment.getTAG009();
  CompleteRmaShipment.getTAG010();
  CompleteRmaShipment.getTAG011();
  CompleteRmaShipment.getTAG012();
  CompleteRmaShipment.getTAG013();
  CompleteRmaShipment.getTAG014();
  CompleteRmaShipment.getHLPURL();
  CompleteRmaShipment.SVMXC_CompleteRMA(shpObject3.Id);
  CompleteRmaShipment.SVMX_SaveRMAShipment();
  CompleteRmaShipment.SVMXC_GoBacktoRecord();
  }
  static testMethod void UnitTest3() {
        List<RecordType> AllRecordTypes = [SELECT Id , Name,SobjectType  FROM RecordType];
        RecordType rtype = [Select Id,Name from RecordType where SobjectType = 'SVMXC__RMA_Shipment_Order__c' AND Name='RMA' limit 1];
        for ( RecordType rectype:AllRecordTypes)
        {
          if ((rectype.Name =='Shipment')&&(rectype.SobjectType =='SVMXC__RMA_Shipment_Line__c'))             
              rtSHPLine = rectype;
        }
        account = new Account(
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
        system.assert(account.Name!=null);
        system.assert(account.ShippingStreet!=null);
        system.assert(account.ShippingState!=null);
        
        contact = new Contact(LastName='Last',AccountId =account.Id,Email='svmxmailfortest@servicemax.com',
                                        OtherStreet = 'Other', OtherState ='CA', OtherPostalCode ='95051', OtherCountry ='USA',OtherCity='ABC',
                                        MailingStreet = 'Other', MailingState ='CA', MailingPostalCode ='95051', MailingCountry ='USA',MailingCity='ABC');
        insert contact;

        case1 = new Case(Status ='New', Priority = 'Medium', 
                                        Origin = 'Email',                                        
                                                                                    
                                        ContactId =contact.Id,
                                        AccountId=account.Id                                         
                                        ); 
        insert case1;
        system.assert(case1.Status!=null);

        prodShpLine =     new Product2(
                                       Name = 'prodShpLine', 
                                       ProductCode = '1235', 
                                       Family = 'Accessory', 
                                       SVMXC__Inherit_Parent_Warranty__c =True 
                                       );
                                       
        insert prodShpLine;
     
        prod =       new Product2(
                                       Name = 'Prod', 
                                       ProductCode = '1235', 
                                       Family = 'Accessory', 
                                       SVMXC__Inherit_Parent_Warranty__c =True 
                                       );
                                       
        insert prod;
     sourceLocation = new SVMXC__Site__c(
                                        SVMXC__Zip__c ='90909090',
                                        SVMXC__Street__c ='ABC',
                                        SVMXC__State__c ='ABC',
                                        SVMXC__Country__c ='ABC',
                                        SVMXC__City__c ='ABC',
                                        SVMXC__Account__c=account.Id
                                        );
     insert sourceLocation;
    
     destLocation = new SVMXC__Site__c(
                                        SVMXC__Zip__c ='90909090',
                                        SVMXC__Street__c ='ABC',
                                        SVMXC__State__c ='ABC',
                                        SVMXC__Country__c ='ABC',
                                        SVMXC__City__c ='ABC',
                                        SVMXC__Account__c=account.Id
                                        );
    insert destLocation;

    shpObject3 = new SVMXC__RMA_Shipment_Order__c(
                                             SVMXC__Source_Location__c =sourceLocation.Id, 
                                             SVMXC__Expected_Delivery_Date__c =System.today(), 
                                             SVMXC__Destination_Location__c=destLocation.Id, 
                                             SVMXC__Contact__c =contact.Id, 
                                             SVMXC__Company__c=account.Id, 
                                             SVMXC__Case__c =case1.Id, 
                                             RecordTypeId = rtype.Id,// recordtype is RMA
                                             SVMXC__Order_Status__c = 'Open'
                                             );
    insert shpObject3;
  
  shpLineObject1 = new SVMXC__RMA_Shipment_Line__c(
                                                    SVMXC__RMA_Shipment_Order__c=shpObject3.Id , 
                                                    RecordTypeId = rtSHPLine.Id ,
                                                    SVMXC__Product__c = prodShpLine.Id,
                                                    SVMXC__Line_Status__c ='Cancelled',
                                                    SVMXC__Select__c = true,
                                                    SVMXC__Actual_Quantity2__c =3
                                                    ); 
    insert shpLineObject1;
  
  system.currentPageReference().getParameters().put('RecId', shpObject3.Id);
  PORD_CompleteRMAShipment CompleteRmaShipment = new PORD_CompleteRMAShipment();

  CompleteRmaShipment.SVMXC_CompleteShipment(shpObject3.Id);
  CompleteRmaShipment.SVMX_SaveRMAShipment();
  CompleteRmaShipment.SVMXC_GoBacktoRecord();
  }
  
}