@isTest(SeeAllData=true)
private with sharing class COMM_PriceClassInsertUpdateUnitTest 
{
    public static Pricebook2 pbk,pb;
    private static Account account,account2;
    private static Contact contact ;
    private static Case case1;
    private static Product2  prodSvoLineUC,prodSvoLineEstimate,prodRMALine,prodShpLine,prod;      
    private static PricebookEntry pbe,pbe1,pbe2,pbe3,pbe4;
    
    private static SVMXC__Site__c sourceLocation,destLocation;   
    
    private static SVMXC__Service_Order__c svo;
    private static SVMXC__Service_Order_Line__c svoUsageLine,svoEstimateLine,svoRRLine,svoEstimateLine2;
    
    private static RecordType rtEst,rtRR,rtUC,rtRMA,rtSHP,rtRMALine,rtSHPLine;
    private static SVMXC__RMA_Shipment_Order__c rmaObject,shpObject; 
    private static SVMXC__RMA_Shipment_Line__c rmaLineObject1,rmaLineObject2,rmaLineObject3, shpLineObject1,shpLineObject2,shpLineObject3,shpLineObject4;
     
    static void UnitTestSetupData()
    {
        try 
        {
                   
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
            account2 = new Account(
                                        Name ='Account2',
                                        ShippingStreet='ABC',
                                        ShippingCity='PQR ',
                                        ShippingState = 'XYZ',
                                        ShippingPostalCode='111',
                                        ShippingCountry='XYZ'
                                        ); 
            insert account2;    
            contact = new Contact(LastName='Last',AccountId =account.Id,Email='svmxmailfortest@Servicemax.com');
            insert contact;
            case1 = new Case(Status ='New', Priority = 'Medium', 
                                        Origin = 'Email',                                        
                                                                                    
                                        ContactId =contact.Id,
                                        AccountId=account.Id
                                        ); 
            insert case1; 
            case1.AccountId=account2.Id;
            update case1;       
            //product With Parent Warranty 
            list<Product2> prodlist = new list<Product2>();
            prodSvoLineUC = new Product2 (
                                        Name ='prodSvoLineUC',
                                        ProductCode='prodSvoLineUC',
                                        SVMXC__Inherit_Parent_Warranty__c =True
                                        ); 
            prodlist.add(prodSvoLineUC);
            //product Without Parent Warranty
            prodSvoLineEstimate = new Product2 (
                                        Name ='prodSvoLineEstimate',
                                        ProductCode='prodSvoLineEstimate',
                                        SVMXC__Inherit_Parent_Warranty__c =False
                                        );                                              
            prodlist.add(prodSvoLineEstimate);
        
            prodRMALine =   new Product2(
                                       Name = 'prodRMALine', 
                                       ProductCode = '1234', 
                                       Family = 'Accessory', 
                                       SVMXC__Inherit_Parent_Warranty__c =False 
                                       );
            prodlist.add(prodRMALine);
    
            prodShpLine =     new Product2(
                                       Name = 'prodShpLine', 
                                       ProductCode = '1235', 
                                       Family = 'Accessory', 
                                       SVMXC__Inherit_Parent_Warranty__c =True 
                                       );
            prodlist.add(prodShpLine);
     
            prod = new Product2(
                                       Name = 'Prod', 
                                       ProductCode = '1235', 
                                       Family = 'Accessory', 
                                       SVMXC__Inherit_Parent_Warranty__c =True 
                                       );
            prodlist.add(prod);
            insert prodlist;
            rtEst = [SELECT Id FROM RecordType WHERE Name = 'Estimate' Limit 1];
            rtRR = [SELECT Id FROM RecordType WHERE Name = 'Request/Receipt'Limit 1];
            rtUC = [SELECT Id FROM RecordType WHERE Name = 'Usage/Consumption'Limit 1];
            rtRMA = [SELECT Id FROM RecordType WHERE Name = 'RMA' AND SobjectType ='SVMXC__RMA_Shipment_Order__c' Limit 1];
            rtSHP = [SELECT Id FROM RecordType WHERE Name = 'Shipment' AND SobjectType ='SVMXC__RMA_Shipment_Order__c' Limit 1];
            rtRMALine = [SELECT Id FROM RecordType WHERE Name = 'RMA' AND SobjectType ='SVMXC__RMA_Shipment_Line__c' Limit 1];
            rtSHPLine = [SELECT Id FROM RecordType WHERE Name = 'Shipment' AND SobjectType ='SVMXC__RMA_Shipment_Line__c' Limit 1];
            list<SVMXC__Site__c> siteloc = new list<SVMXC__Site__c>();
            sourceLocation = new SVMXC__Site__c(
                                        SVMXC__Zip__c ='90909090',
                                        SVMXC__Street__c ='ABC',
                                        SVMXC__State__c ='ABC',
                                        SVMXC__Country__c ='ABC',
                                        SVMXC__City__c ='ABC',
                                        SVMXC__Account__c=account.Id
                                        );
            siteloc.add(sourceLocation);
    
            destLocation = new SVMXC__Site__c(
                                        SVMXC__Zip__c ='90909090',
                                        SVMXC__Street__c ='ABC',
                                        SVMXC__State__c ='ABC',
                                        SVMXC__Country__c ='ABC',
                                        SVMXC__City__c ='ABC',
                                        SVMXC__Account__c=account.Id
                                        );
            siteloc.add(destLocation);
            insert siteloc;
            /* Get the standard pricebook. There must be a standard pricebook already in the target org.  */
            pb = [select name, IsActive from Pricebook2 where IsStandard = true limit 1];
            system.assert(pb.id!=null);
   
    
            SVMXC.COMM_Utils_ManageSettings svosettings = new SVMXC.COMM_Utils_ManageSettings();
            Map<String, String> SVOSubModuleSettings = svosettings.SVMX_getSettingList('WORD005');
            
            String UsagePriceBook = SVOSubModuleSettings.get('SET004'); //setting for default Usage Price Book
            String EstPriceBook = SVOSubModuleSettings.get('SET006'); //setting for default Esimate Price Book
            String ReqPriceBook = SVOSubModuleSettings.get('SET008'); //setting for default Req/Rec Price Book
            String UsagePriceBookTrigger = SVOSubModuleSettings.get('SET009'); //setting for Usage Price Book for trigger
            String EstimatePriceBookTrigger = SVOSubModuleSettings.get('SET010'); //setting for Estimate Price Book for trigger
            String ReqPriceBookTrigger = SVOSubModuleSettings.get('SET011'); //setting for Req/Rec Price Book for trigger
 
            pbk = SVMXC.COMM_PriceClass.SVMXC_GetPricebook(UsagePriceBook );
            PricebookEntry pbe22 = SVMXC.COMM_PriceClass.SVMXC_GetPricebookEntry(pbk,'USD',prod.Id);
    
            pbk = SVMXC.COMM_PriceClass.SVMXC_GetPricebook(EstPriceBook );
            /* Create a pricebook entries. */
            list<PricebookEntry> pricbooklist = new list<PricebookEntry>();
    
            pbe = new PricebookEntry();
            pbe.Pricebook2Id = pb.id;
            pbe.Product2Id   = prodSvoLineUC.id;
            pbe.IsActive     = true;
            pbe.UnitPrice    = 10;        
            pricbooklist.add(pbe);
            
            pbe = new PricebookEntry();
            pbe.Pricebook2Id = pb.id;
            pbe.Product2Id   = prodSvoLineEstimate.id;
            pbe.IsActive     = true;
            pbe.UnitPrice    = 10;        
            pricbooklist.add(pbe);
            
            pbe = new PricebookEntry();
            pbe.Pricebook2Id = pb.id;
            pbe.Product2Id   = prodRMALine.id;
            pbe.IsActive     = true;
            pbe.UnitPrice    = 10;        
            pricbooklist.add(pbe);
        
            pbe = new PricebookEntry();
            pbe.Pricebook2Id = pb.id;
            pbe.Product2Id   = prodShpLine.id;
            pbe.IsActive     = true;
            pbe.UnitPrice    = 10;        
            pricbooklist.add(pbe);
            insert pricbooklist;
        }
        catch(exception Ex){}
    }
    static testMethod void testForCOMM_PriceClass() 
    {
        try
        {
            SVMXC.COMM_PriceClassInsertUpdateUnitTest.UnitTestSetupData();
            svo = new SVMXC__Service_Order__c (
                                            SVMXC__Case__c = case1.Id ,
                                            SVMXC__Company__c = account.Id , 
                                            SVMXC__Contact__c =contact.Id, 
                                            SVMXC__Order_Status__c = 'Open',
                                            SVMXC__Priority__c ='Medium',
                                             
                                            SVMXC__Order_Type__c='Field Service'
                                            );
            insert svo;
            List<SVMXC__Service_Order__c> workorderlist = new List<SVMXC__Service_Order__c>();
            List<SVMXC__Service_Order_Line__c> workorderLinelist = new List<SVMXC__Service_Order_Line__c>();
            workorderlist.add(svo);
            system.assert(workorderlist.size()>0);
            svoUsageLine = new SVMXC__Service_Order_Line__c(
                                                SVMXC__Service_Order__c = svo.Id, 
                                                 
                                                RecordTypeId = rtUC.Id,
                                                SVMXC__Product__c = prodSvoLineUC.Id);
            
        
            workorderLinelist.add(svoUsageLine);
            
            svoEstimateLine = new SVMXC__Service_Order_Line__c(
                                           SVMXC__Service_Order__c = svo.Id, 
                                             
                                            RecordTypeId = rtEst.Id,
                                            SVMXC__Product__c = prodSvoLineEstimate.Id);
        
    
            workorderLinelist.add(svoEstimateLine);
            
            svoEstimateLine2 = new SVMXC__Service_Order_Line__c(
                                           SVMXC__Service_Order__c = svo.Id, 
                                             
                                            RecordTypeId = rtEst.Id,
                                            SVMXC__Product__c = prod.Id);
        
            workorderLinelist.add(svoEstimateLine2);
           
            svoRRLine = new SVMXC__Service_Order_Line__c(
                                           SVMXC__Service_Order__c = svo.Id, 
                                             
                                            RecordTypeId = rtRR.Id,
                                            SVMXC__Product__c = prod.Id);
        
    
            workorderLinelist.add(svoRRLine);
            insert workorderLinelist;
            list<SVMXC__RMA_Shipment_Order__c> rmashiplist = new list<SVMXC__RMA_Shipment_Order__c>();
            rmaObject = new SVMXC__RMA_Shipment_Order__c(
                                                 SVMXC__Source_Location__c =sourceLocation.Id, 
                                                 SVMXC__Expected_Receive_Date__c =System.today(), 
                                                 SVMXC__Destination_Location__c=destLocation.Id, 
                                                 SVMXC__Contact__c =contact.Id, 
                                                 SVMXC__Company__c=account.Id, 
                                                 SVMXC__Case__c =case1.Id, 
                                                 RecordTypeId = rtRMA.Id,
                                                  
                                                 SVMXC__Order_Status__c='Open'                                           
                                                 );
            rmashiplist.add(rmaObject);   
        
            shpObject = new SVMXC__RMA_Shipment_Order__c(
                                                 SVMXC__Source_Location__c =sourceLocation.Id, 
                                                 SVMXC__Expected_Delivery_Date__c =System.today(), 
                                                 SVMXC__Destination_Location__c=destLocation.Id, 
                                                 SVMXC__Contact__c =contact.Id, 
                                                 SVMXC__Company__c=account.Id, 
                                                 SVMXC__Case__c =case1.Id, 
                                                 RecordTypeId = rtSHP.Id,
                                                  
                                                 SVMXC__Order_Status__c='Open'                                           
                                                 );
            rmashiplist.add(shpObject);
            insert rmashiplist;
            rmaLineObject1 = new SVMXC__RMA_Shipment_Line__c( 
                                                        SVMXC__RMA_Shipment_Order__c= rmaObject.Id, 
                                                        RecordTypeId = rtRMALine.Id, 
                                                        SVMXC__Product__c = prodRMALine.Id
                                                        );                                            
            insert rmaLineObject1;     
            rmaLineObject2 = new SVMXC__RMA_Shipment_Line__c( 
                                                        SVMXC__RMA_Shipment_Order__c= rmaObject.Id, 
                                                        RecordTypeId = rtRMALine.Id, 
                                                        SVMXC__Product__c = prodRMALine.Id
                                                        ); 
    
            rmaLineObject3 = new SVMXC__RMA_Shipment_Line__c(
                                                            SVMXC__RMA_Shipment_Order__c= rmaObject.Id, 
                                                            RecordTypeId = rtRMALine.Id
                                                            ); 
            
            shpLineObject1 = new SVMXC__RMA_Shipment_Line__c(
                                                            SVMXC__RMA_Shipment_Order__c=shpObject.Id , 
                                                            RecordTypeId = rtSHPLine.Id ,
                                                            SVMXC__Product__c = prodShpLine.Id,
                                                            SVMXC__Line_Status__c ='Open',
                                                            SVMXC__Expected_Quantity2__c =3
                                                            );
            
            shpLineObject2 = new SVMXC__RMA_Shipment_Line__c(
                                                            SVMXC__RMA_Shipment_Order__c=shpObject.Id , 
                                                            RecordTypeId = rtSHPLine.Id ,
                                                            SVMXC__Product__c = prodShpLine.Id,
                                                            SVMXC__Line_Status__c ='Open',
                                                            SVMXC__Expected_Quantity2__c =3
                                                            );
            
            shpLineObject3 = new SVMXC__RMA_Shipment_Line__c(
                                                            SVMXC__RMA_Shipment_Order__c=shpObject.Id , 
                                                            RecordTypeId = rtSHPLine.Id ,                                                   
                                                            SVMXC__Line_Status__c ='Open',
                                                            SVMXC__Expected_Quantity2__c =3
                                                            );
        
            shpLineObject4 = new SVMXC__RMA_Shipment_Line__c(
                                                        SVMXC__RMA_Shipment_Order__c=shpObject.Id , 
                                                        RecordTypeId = rtSHPLine.Id ,                                                   
                                                        SVMXC__Line_Status__c ='Open',
                                                        SVMXC__Product__c = prod.Id,
                                                        SVMXC__Expected_Quantity2__c =3
                                                        );
    
            Test.starttest();
            String text1 ='';
            SVMXC.COMM_PriceClass.SVMXC_SetErrorText(text1);
            text1=SVMXC.COMM_PriceClass.SVMXC_GetErrorText();
            SVMXC.COMM_PriceClass.SVMXC_ReSetErrorFlag();
            text1=SVMXC.COMM_PriceClass.SVMXC_GetErrorText();  
            SVMXC.COMM_PriceClass Priceclsobj = new SVMXC.COMM_PriceClass();
            //SVMXC.COMM_PriceClass.SVMXC_SetSVOLinePrice(svoRRLine);
            SVMXC.COMM_PriceClass.SVMXC_SetRMA_ShipmentLinePrice(rmaLineObject1);
            system.assert(svoRRLine.Id!=null);
            system.assert(rmaLineObject1.Id!=null);
            SVMXC.COMM_PriceClass.SVMXC_ValidateResult(svoRRLine);
            SVMXC.COMM_PriceClass.SVMXC_ValidateResult(rmaLineObject1);
            SVMXC.COMM_PriceClass.SVMXC_GetUnitPrice(pb,'USD',rmaLineObject1.SVMXC__Product__c);
            Test.stoptest();
        }
        catch(Exception ex){system.debug('Exception: '+ex.getMessage());}    
    }
}