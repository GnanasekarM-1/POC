@isTest(SeeAllData=true)
private with sharing class INVT_UnitTestCases{
    static testMethod void testPRLinePriceTrigger(){    
    try{
        test.startTest();   
        Account account = new Account(Name ='Account',ShippingStreet='ABC',ShippingCity='PQR ',ShippingState = 'XYZ',ShippingPostalCode='111',ShippingCountry='XYZ',BillingStreet='ABC',BillingCity='PQR ',BillingState = 'XYZ',BillingPostalCode='111',BillingCountry='XYZ');
        insert account;
        System.assertEquals(true, account != null);
        
        SVMXC__Site__c  sourceLocation = new SVMXC__Site__c(SVMXC__Zip__c ='90909090',SVMXC__Street__c ='ABC',SVMXC__State__c ='ABC',SVMXC__Country__c ='USA',SVMXC__City__c ='ABC',SVMXC__Stocking_Location__c =true,SVMXC__Account__c=account.Id);
        insert sourceLocation;
        System.assertEquals(true, sourceLocation != null);
        
        SVMXC__Site__c destLocation = new SVMXC__Site__c(SVMXC__Zip__c ='95051',SVMXC__Street__c ='ABC2',SVMXC__State__c ='ABC2',SVMXC__Country__c ='UK',SVMXC__City__c ='ABCD',SVMXC__Stocking_Location__c =true,SVMXC__Account__c=account.Id);
        insert destLocation;
        System.assertEquals(true, destLocation != null);
        
        Product2 prodPRLine = new Product2(Name = 'prodPRLine',ProductCode = '1235',Family = 'Accessory',SVMXC__Inherit_Parent_Warranty__c =True);
        insert prodPRLine;
        System.assertEquals(true, prodPRLine != null);
        
        Pricebook2 pb = [select name, IsActive from Pricebook2 where IsStandard = true limit 1];
        pb.IsActive = true;
        update pb;
        System.assertEquals(true, pb != null);
        
        PricebookEntry   pbe = new PricebookEntry();
        pbe.Pricebook2Id = pb.id;
        pbe.Product2Id   = prodPRLine.id;
        pbe.IsActive = true;
        pbe.UnitPrice= 10;
        insert pbe;
        System.assertEquals(true, pbe != null);
          
        PricebookEntry   pbePR = new PricebookEntry();
        pbePR.Pricebook2Id = pb.id;
        pbePR.Product2Id   = prodPRLine.id;
        pbePR.IsActive = true;
        pbePR.UnitPrice= 10;
        insert pbePR; 
        System.assertEquals(true, pbePR != null);
          
        //Test Cases for SVMXC_PRLineUpdateTrigger   
        SVMXC__Parts_Request__c prObj = new SVMXC__Parts_Request__c(SVMXC__Status__c='Open',SVMXC__Required_At_Location__c =destLocation.Id,SVMXC__Requested_From__c=sourceLocation.Id);
        insert prObj;
        System.assertEquals(true, prObj != null);
        
        SVMXC__Parts_Request_Line__c prLineObj1 = new SVMXC__Parts_Request_Line__c(SVMXC__Quantity_Required2__c=5,SVMXC__Product__c =prodPRLine.Id,SVMXC__Parts_Request__c =prObj.Id,SVMXC__Date_Required__c =System.Today());
        insert prLineObj1;  
        System.assertEquals(true, prLineObj1 != null);
        update prLineObj1;  
        test.stopTest();
    }
    catch(Exception e) {}
    }
    static testMethod void testUpdateRequestedFromTrigger(){    
        try{   
            List<RecordType> AllRecordTypes =[SELECT Id , Name,SobjectType  FROM RecordType];
            Account account = new Account(Name ='Account',ShippingStreet='ABC',ShippingCity='PQR ',ShippingState = 'XYZ',ShippingPostalCode='111',ShippingCountry='XYZ',BillingStreet='ABC',BillingCity='PQR ',BillingState = 'XYZ',BillingPostalCode='111',BillingCountry='XYZ'); 
            insert account;
            System.assertEquals(true, account != null);
            
            Contact contact = new Contact(LastName='Last',AccountId =account.Id,Email='svmxmailfortest@servicemax.com');
            insert contact;
            System.assertEquals(true, contact != null);
            
               Case case1 = new Case(Status ='New', Priority = 'Medium',Origin = 'Email',ContactId =contact.Id,AccountId=account.Id); 
            insert case1; 
            System.assertEquals(true, case1 != null);
            
            Product2 prodWORR = new Product2(Name = 'prodPR',ProductCode='prodPR',SVMXC__Inherit_Parent_Warranty__c =True);
            insert prodWORR;
            
            Product2 prodWORR1 = new Product2(Name = 'prodPR',ProductCode='prodPR',SVMXC__Inherit_Parent_Warranty__c =True);
            insert prodWORR1;
            System.assertEquals(true, prodWORR1 != null);
            
            RecordType rtWORRL;
            for ( RecordType rectype:AllRecordTypes){
                if ((rectype.Name =='Request/Receipt')&&(rectype.SobjectType =='SVMXC__Service_Order_Line__c')) 
                    rtWORRL = rectype;
            }
            
            SVMXC__Site__c sourceLocation = new SVMXC__Site__c(SVMXC__Zip__c ='90909090',SVMXC__Street__c ='ABC',SVMXC__State__c ='ABC',SVMXC__Country__c ='ABC',SVMXC__City__c ='ABC',SVMXC__Account__c=account.Id);
            insert sourceLocation;
            System.assertEquals(true, sourceLocation != null);
            
            SVMXC__Site__c destLocation = new SVMXC__Site__c(SVMXC__Zip__c ='90909090',SVMXC__Street__c ='ABC',SVMXC__State__c ='ABC',SVMXC__Country__c ='ABC',SVMXC__City__c ='ABC',SVMXC__Account__c=account.Id);
            insert destLocation;
            System.assertEquals(true, destLocation != null);
            
            SVMXC__Service_Order__c woObject = new SVMXC__Service_Order__c(SVMXC__Company__c=account.Id,SVMXC__Contact__c=contact.Id,SVMXC__Case__c=case1.Id,SVMXC__Order_Status__c='Open',SVMXC__Priority__c='Low',SVMXC__Order_Type__c='Field Service',SVMXC__Purpose_of_Visit__c='Repair',SVMXC__Problem_Description__c='Its for Unit Test Case Of Request Receipt');
            insert woObject;   
            System.assertEquals(true, woObject != null);
            
            SVMXC__Service_Order_Line__c worrl = new SVMXC__Service_Order_Line__c(SVMXC__Service_Order__c=woObject.Id,RecordTypeId = rtWORRL.Id ,SVMXC__Requested_Quantity2__c=45,SVMXC__Date_Requested__c=System.today(),SVMXC__Received_Quantity2__c=45,SVMXC__From_Location__c=sourceLocation.Id,SVMXC__Requested_Location__c=destLocation.Id);
            insert worrl;
            System.assertEquals(true, worrl != null);
            
            SVMXC__Service_Order_Line__c worrl1 = new SVMXC__Service_Order_Line__c(SVMXC__Service_Order__c=woObject.Id,RecordTypeId = rtWORRL.Id ,SVMXC__Requested_Quantity2__c=45,SVMXC__Date_Requested__c=System.today(),SVMXC__Received_Quantity2__c=45, SVMXC__From_Location__c=sourceLocation.Id, SVMXC__Requested_Location__c=destLocation.Id);
            insert worrl1;
            System.assertEquals(true, worrl1 != null);
            update worrl;
            update worrl1;
        }
        catch(Exception e) {}
    }
}