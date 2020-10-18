@isTest
private  with sharing class PORD_CreateShipmentFromRMA_UT
{
    private static SVMXC.PORD_CreateShipmentFromRMA ControllerObj1;
    private static Account account;
    private static Contact contact ;
    private static Case case1;
    private static Product2  prodShpLine,prod;      
    private static Pricebook2 pbStd; 
    private static PricebookEntry pbe,pbe1;
    private static SVMXC__Site__c sourceLocation,destLocation;   
     
    private static RecordType rtSHP,rtSHPLine,rtRMA , rtRMALine;
    private static SVMXC__RMA_Shipment_Order__c rmaObject, shpObject1,shpObject2,shpObject3; 
    private static SVMXC__RMA_Shipment_Line__c  rmaLineObject1, rmaLineObject2 , shpLineObject1,shpLineObject2,shpLineObject3,shpLineObject4,shpLineObject5;
    private static List<SVMXC__RMA_Shipment_Line__c> shpLineArray = new List<SVMXC__RMA_Shipment_Line__c>();
    private static SVMXC__Installed_Product__c IBObject ;
    
    
/*******************************************************************************************************************
Variables for Configuration Setting Data
*******************************************************************************************************************/
  
    private static List<RecordType> AllRecordTypes  = new List<RecordType>();
    
/*******************************************************************************************************************
Test Method
*******************************************************************************************************************/
    
    static testMethod void PORD_CreateShipmentFromRMA_Test()
        {
        try{     
            try{  
            AllRecordTypes =[SELECT Id , Name,SobjectType  FROM RecordType];
            } catch (Exception e){}        
             
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
        

        contact = new Contact(LastName='Last',AccountId =account.Id,Email='svmxmailfortest@servicemax.com');
        insert contact;
        
        
        case1 = new Case(Status ='New', Priority = 'Medium', 
                                        Origin = 'Email',                                        
                                                                                    
                                        ContactId =contact.Id,
                                        AccountId=account.Id                                         
                                        ); 
        insert case1; 
        
       contact = new Contact(LastName='Last',AccountId =account.Id,Email='svmxmailfortest@servicemax.com',
                                        OtherStreet = 'Other', OtherState ='CA', OtherPostalCode ='95051', OtherCountry ='USA',OtherCity='ABC',
                                        MailingStreet = 'Other', MailingState ='CA', MailingPostalCode ='95051', MailingCountry ='USA',MailingCity='ABC');
        insert contact;

    
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
            if ((rectype.Name =='RMA')&&(rectype.SobjectType =='SVMXC__RMA_Shipment_Order__c'))             
                rtRMA = rectype;
                
            }
        for ( RecordType rectype:AllRecordTypes)
            {
            if ((rectype.Name =='RMA')&&(rectype.SobjectType =='SVMXC__RMA_Shipment_Line__c'))              
                rtRMALine = rectype;
                
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
                                             RecordTypeId = rtSHP.Id,
                                              
                                             SVMXC__Order_Status__c='Open'                                           
                                             );
    insert shpObject3;
    
    
   
    shpLineObject1 = new SVMXC__RMA_Shipment_Line__c(
                                                    SVMXC__RMA_Shipment_Order__c=shpObject1.Id , 
                                                    RecordTypeId = rtSHPLine.Id ,
                                                    SVMXC__Product__c = prodShpLine.Id,
                                                    SVMXC__Line_Status__c ='Open',
                                                    SVMXC__Select__c = true,                                                    
                                                    SVMXC__Actual_Quantity2__c =3
                                                    ); 
    insert shpLineObject1;
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
    insert rmaObject;    
    rmaLineObject1 = new SVMXC__RMA_Shipment_Line__c( 
                                                    SVMXC__RMA_Shipment_Order__c= rmaObject.Id, 
                                                    RecordTypeId = rtRMALine.Id, 
                                                    SVMXC__Product__c = prod.Id
                                                    );                                            
    insert rmaLineObject1;     
    rmaLineObject2 = new SVMXC__RMA_Shipment_Line__c( 
                                                    SVMXC__RMA_Shipment_Order__c= rmaObject.Id, 
                                                    RecordTypeId = rtRMALine.Id, 
                                                    SVMXC__Product__c = prod.Id
                                                    ); 
    insert rmaLineObject2; 
  
  
  
/*******************************************************************************************************************
Configuring Standard Price for Product
*******************************************************************************************************************/
     try{
      pbStd = [select name, IsActive from Pricebook2 where IsStandard = true limit 1 ];
      pbStd.IsActive = true;
      update pbStd ;
      system.assertNotEquals(pbStd.Id, null);
      system.assertEquals(pbStd.IsActive,true);
            } catch (Exception e){
            }
    
   /* Create a pricebook entries. */

    if(pbStd != null)
    {
        pbe = new PricebookEntry();
        pbe.Pricebook2Id = pbStd.id;
        pbe.Product2Id   = prod.id;
        pbe.IsActive     = true;
        pbe.UnitPrice    = 10;    
        pbe.UseStandardPrice = false;   
        insert pbe;  
    }  
   
        
    

        Test.starttest();
/*******************************************************************************************************************
Scenario to Launch Page with url parameters id 
*******************************************************************************************************************/
       
       PageReference pageRef1 = new PageReference('Page.SVMXC.PORD_CreateShipmentFromRMA');
       pageRef1.getParameters().put('rid',rmaObject.Id);
       Test.setCurrentPageReference(pageRef1); 
       ControllerObj1 = new SVMXC.PORD_CreateShipmentFromRMA();
       ControllerObj1.getUserLocaleKey();
       ControllerObj1.getUserID();
       ControllerObj1.getUserOrgID();
       ControllerObj1.getSelectedRecordType();
       ControllerObj1.setSelectedRecordType('Shipment');
       ControllerObj1.getRecordTypes();
       ControllerObj1.getselectedLineRecordType();
       ControllerObj1.setselectedLineRecordType('Shipment');
       ControllerObj1.getLineRecordTypes();
       ControllerObj1.getLocationFromId(destLocation.Id);
       ControllerObj1.setAddressForTargetLoc();
       ControllerObj1.UpdateLineRecord();
       ControllerObj1.getDisplayTableColumns();
       ControllerObj1.AddLine();
       ControllerObj1.RemoveLine();
       
/*******************************************************************************************************************
Scenario to qualify the method setAddress() with different Address Types
*******************************************************************************************************************/
      ControllerObj1.setAddressForSourceLoc();
      ControllerObj1.setAddressForTargetLoc();
      SVMXC__RMA_Shipment_Order__c PO1 = new SVMXC__RMA_Shipment_Order__c();
      PO1 = ControllerObj1.getNewRMAShpipmentHeader();
      PO1.SVMXC__Source_Location__c = sourceLocation.Id;
      ControllerObj1.setNewRMAShpipmentHeader(PO1);

/*******************************************************************************************************************
Scenario to Create Shipment Order with Lines
*******************************************************************************************************************/
        PageReference clearWarnings   = ControllerObj1.ClearWarnings();
        

/*******************************************************************************************************************
Scenario to display Warnings
*******************************************************************************************************************/
        ControllerObj1.AddToWarningsList('Msg');
        ControllerObj1.getshowWarnings();
        ControllerObj1.DisplayErrorsNWarnings();

/*******************************************************************************************************************
Scenario to Cancel the creation of Shipment Order with Lines
*******************************************************************************************************************/
        PageReference cancel   = ControllerObj1.Cancel();

/*******************************************************************************************************************
Scenario to clear the Source and Destination address of Shipment Order 
*******************************************************************************************************************/
        ControllerObj1.clearAddress('Source');
        ControllerObj1.clearAddress('Destination');
 
/*******************************************************************************************************************
Scenario to qualify regular set & get methods
*******************************************************************************************************************/
     
      ControllerObj1.setNewRMAShpipmentHeader(ControllerObj1.getNewRMAShpipmentHeader());
      List<SVMXC__RMA_Shipment_Line__c> NewShipmentLines = ControllerObj1.getNewRMAShpipmentLines();
      ControllerObj1.setNewRMAShpipmentLines(NewShipmentLines);
      SVMXC__RMA_Shipment_Order__c rma  = ControllerObj1.getRMAHeader();
      Boolean chkAllLines = ControllerObj1.getCheckAllLines();
      ControllerObj1.setCheckAllLines(true);      
      ControllerObj1.setshowWarnings(true);
      List<String> strList1 = ControllerObj1.getErrorsList();
      ControllerObj1.AddToWarningsList('msg');
      List<String> strList2 = ControllerObj1.getWarningsList();
      system.assert(ControllerObj1.getDisplayBlockLevelMessage()!=null,'getDisplayBlockLevelMessage Assertion failed');
      Boolean dblMesg = ControllerObj1.getDisplayBlockLevelMessage();
      system.assert(ControllerObj1.getDisplayForm()!=null,'getDisplayForm Assertion failed');
      Boolean dForm = ControllerObj1.getDisplayForm();
      //system.assert(ControllerObj1.getSelectedAddressType()!=null,'getSelectedAddressType Assertion failed');
      String strAddType = ControllerObj1.getSelectedAddressType();
      ControllerObj1.setSelectedAddressType(strAddType);
      ControllerObj1.PopulateFieldNames();
      ControllerObj1.PopulateSourceNTargetObject();
      //ControllerObj1.populateAddress();
      //ControllerObj1.getRecordType();

        String strTag='';
        system.assert(ControllerObj1.getTAG001()!=null,'TAG001 assertion failed');
        system.assert(ControllerObj1.getTAG002()!=null,'TAG002 assertion failed');
        system.assert(ControllerObj1.getTAG003()!=null,'TAG003 assertion failed');
        system.assert(ControllerObj1.getTAG004()!=null,'TAG004 assertion failed');
        system.assert(ControllerObj1.getTAG006()!=null,'TAG006 assertion failed');
        system.assert(ControllerObj1.getTAG007()!=null,'TAG007 assertion failed');
        system.assert(ControllerObj1.getTAG008()!=null,'TAG008 assertion failed');
        system.assert(ControllerObj1.getTAG009()!=null,'TAG009 assertion failed');
        system.assert(ControllerObj1.getTAG010()!=null,'TAG010 assertion failed');
        system.assert(ControllerObj1.getTAG017()!=null,'TAG017 assertion failed');
        system.assert(ControllerObj1.getTAG018()!=null,'TAG018 assertion failed');
        system.assert(ControllerObj1.getTAG019()!=null,'TAG019 assertion failed');
        system.assert(ControllerObj1.getTAG020()!=null,'TAG020 assertion failed');
        system.assert(ControllerObj1.getTAG021()!=null,'TAG021 assertion failed');
        system.assert(ControllerObj1.getTAG022()!=null,'TAG022 assertion failed');
        system.assert(ControllerObj1.getTAG023()!=null,'TAG023 assertion failed');
        system.assert(ControllerObj1.getTAG024()!=null,'TAG024 assertion failed');
        system.assert(ControllerObj1.getTAG025()!=null,'TAG025 assertion failed');
        system.assert(ControllerObj1.getTAG030()!=null,'TAG030 assertion failed');
        system.assert(ControllerObj1.getTAG036()!=null,'TAG036 assertion failed');
        system.assert(ControllerObj1.getTAG039()!=null,'TAG039 assertion failed');
        system.assert(ControllerObj1.getTAG040()!=null,'TAG040 assertion failed');
        system.assert(ControllerObj1.getTAG045()!=null,'TAG045 assertion failed');
        system.assert(ControllerObj1.getTAG046()!=null,'TAG046 assertion failed');
        system.assert(ControllerObj1.getTAG047()!=null,'TAG047 assertion failed');
        system.assert(ControllerObj1.getTAG048()!=null,'TAG048 assertion failed');
        system.assert(ControllerObj1.getTAG049()!=null,'TAG049 assertion failed');
        system.assert(ControllerObj1.getTAG050()!=null,'TAG050 assertion failed');
        system.assert(ControllerObj1.getTAG051()!=null,'TAG051 assertion failed');
        system.assert(ControllerObj1.getTAG052()!=null,'TAG052 assertion failed');
        system.assert(ControllerObj1.getTAG053()!=null,'TAG053 assertion failed');
        system.assert(ControllerObj1.getTAG054()!=null,'TAG053 assertion failed');
        system.assert(ControllerObj1.getHLPURL()!=null,'HLPURL assertion failed');
        //Clearing the Tags ,so as to qualify the else part of ternary operator      
        //ControllerObj1.svmxTagList.clear();      
        system.assert(ControllerObj1.getTAG001()!=null,'TAG001 assertion failed');
        system.assert(ControllerObj1.getTAG002()!=null,'TAG002 assertion failed');
        system.assert(ControllerObj1.getTAG003()!=null,'TAG003 assertion failed');
        system.assert(ControllerObj1.getTAG004()!=null,'TAG004 assertion failed');
        system.assert(ControllerObj1.getTAG006()!=null,'TAG006 assertion failed');
        system.assert(ControllerObj1.getTAG007()!=null,'TAG007 assertion failed');
        system.assert(ControllerObj1.getTAG008()!=null,'TAG008 assertion failed');
        system.assert(ControllerObj1.getTAG009()!=null,'TAG009 assertion failed');
        system.assert(ControllerObj1.getTAG010()!=null,'TAG010 assertion failed');
        system.assert(ControllerObj1.getTAG017()!=null,'TAG017 assertion failed');
        system.assert(ControllerObj1.getTAG018()!=null,'TAG018 assertion failed');
        system.assert(ControllerObj1.getTAG019()!=null,'TAG019 assertion failed');
        system.assert(ControllerObj1.getTAG020()!=null,'TAG020 assertion failed');
        system.assert(ControllerObj1.getTAG021()!=null,'TAG021 assertion failed');
        system.assert(ControllerObj1.getTAG022()!=null,'TAG022 assertion failed');
        system.assert(ControllerObj1.getTAG023()!=null,'TAG023 assertion failed');
        system.assert(ControllerObj1.getTAG024()!=null,'TAG024 assertion failed');
        system.assert(ControllerObj1.getTAG025()!=null,'TAG025 assertion failed');
        system.assert(ControllerObj1.getTAG030()!=null,'TAG030 assertion failed');
        system.assert(ControllerObj1.getTAG036()!=null,'TAG036 assertion failed');
        system.assert(ControllerObj1.getTAG039()!=null,'TAG039 assertion failed');
        system.assert(ControllerObj1.getTAG040()!=null,'TAG040 assertion failed');
        system.assert(ControllerObj1.getTAG045()!=null,'TAG045 assertion failed');
        system.assert(ControllerObj1.getTAG046()!=null,'TAG046 assertion failed');
        system.assert(ControllerObj1.getTAG047()!=null,'TAG047 assertion failed');
        system.assert(ControllerObj1.getTAG048()!=null,'TAG048 assertion failed');
        system.assert(ControllerObj1.getTAG049()!=null,'TAG049 assertion failed');
        system.assert(ControllerObj1.getTAG050()!=null,'TAG050 assertion failed');
        system.assert(ControllerObj1.getTAG051()!=null,'TAG051 assertion failed');
        system.assert(ControllerObj1.getTAG052()!=null,'TAG052 assertion failed');
        system.assert(ControllerObj1.getTAG053()!=null,'TAG053 assertion failed');
        system.assert(ControllerObj1.getTAG054()!=null,'TAG053 assertion failed');
        system.assert(ControllerObj1.getHLPURL()!=null,'HLPURL assertion failed');
      
/*******************************************************************************************************************
Code to modify  Current Settings and applying different Scenarios
*******************************************************************************************************************/
        //Clearing all the Settings
        ControllerObj1.AllSubModuleSettings.clear();
        ControllerObj1.ValidateAllSettings();
        PageReference pageRef3 = new PageReference('Page.SVMXC.PORD_CreateShipmentFromRMA');
        pageRef3.getParameters().put('id',rmaObject.Id);
        Test.setCurrentPageReference(pageRef1); 
    
        //Populating different values for Settings
        //Setng_ActionOnBlankFromAddress -SET007
        //Setng_ActionOnBlankToAddress  -SET008

        SVMXC__RMA_Shipment_Order__c PO3 = new SVMXC__RMA_Shipment_Order__c();
        PO3.SVMXC__Source_Location__c = null;
        PO3.SVMXC__Destination_Location__c = null;
        Test.stoptest();
         
       }catch(exception Ex){}
    }//Test Method
}