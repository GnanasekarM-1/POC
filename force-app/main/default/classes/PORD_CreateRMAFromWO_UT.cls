@isTest
private with sharing class PORD_CreateRMAFromWO_UT
{
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
    private static SVMXC__Installed_Product__c IBObject ;
    
    
    private static SVMXC__Service_Order__c svo;
    private static SVMXC__Service_Order_Line__c svoRRLine1;
    
    /*******************************************************************************************************************
    Variables for Configuration Setting Data
    *******************************************************************************************************************/
    
    private static List<RecordType> AllRecordTypes  = new List<RecordType>();
    
    /*******************************************************************************************************************
    Test Method
    *******************************************************************************************************************/
    
    static testMethod void PORD_CreateRMAFromWO_Test()
        { 
       try{
        try{  
        AllRecordTypes =[SELECT Id , Name,SobjectType  FROM RecordType];
       } catch (Exception e){
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
        
        contact = new Contact(LastName='Last',AccountId =account.Id,Email='svmxmailfortest@servicemax.com');
        insert contact;
        system.assert(contact.LastName!=null);
        system.assert(contact.AccountId!=null);

        case1 = new Case(Status ='New', Priority = 'Medium', 
                                        Origin = 'Email',                                        
                                                                                    
                                        ContactId =contact.Id,
                                        AccountId=account.Id                                         
                                        ); 
        insert case1;
        system.assert(case1.Status!=null);

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
     system.assert(sourceLocation.SVMXC__Street__c!=null);
     system.assert(sourceLocation.SVMXC__State__c!=null);
     system.assert(sourceLocation.SVMXC__City__c!=null);
    
     destLocation = new SVMXC__Site__c(
                                        SVMXC__Zip__c ='90909090',
                                        SVMXC__Street__c ='ABC',
                                        SVMXC__State__c ='ABC',
                                        SVMXC__Country__c ='ABC',
                                        SVMXC__City__c ='ABC',
                                        SVMXC__Account__c=account.Id
                                        );
    insert destLocation;
     system.assert(destLocation.SVMXC__Street__c!=null);
     system.assert(destLocation.SVMXC__State__c!=null);
     system.assert(destLocation.SVMXC__City__c!=null);
       
   
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
    
    /*******************************************************************************************************************
    Configuring Standard Price for Product
    *******************************************************************************************************************/
    try{
      pbStd = [select name, IsActive from Pricebook2 where IsStandard = true limit 1 ];
      pbStd.IsActive = true;
      update pbStd ;
           } catch (Exception e){
           }
   
   /* Create a pricebook entries. */
    if(pbStd != null){
        pbe = new PricebookEntry();
        pbe.Pricebook2Id = pbStd.id;
        pbe.Product2Id   = prod.id;
        pbe.IsActive     = true;
        pbe.UnitPrice    = 10;    
        pbe.UseStandardPrice = false;   
        insert pbe; 
      }
    
    svo = new SVMXC__Service_Order__c (
                                        SVMXC__Case__c = case1.Id ,
                                        SVMXC__Company__c = account.Id , 
                                        SVMXC__Contact__c =contact.Id, 
                                        SVMXC__Order_Status__c = 'Open',
                                        SVMXC__Priority__c ='Medium',
                                        SVMXC__Order_Type__c='Field Service'
                                        );
    insert svo;
    
    svoRRLine1 = new SVMXC__Service_Order_Line__c(
                                        SVMXC__Service_Order__c = svo.Id, 
                                         
                                        RecordTypeId = rtRR.Id,
                                        SVMXC__Product__c = prod.Id);
    

    insert svoRRLine1;
    
    IBObject = new SVMXC__Installed_Product__c(
                    Name = 'Test IB1',
                    SVMXC__Status__c = 'Installed',
                    SVMXC__Product__c = prod.Id,
                    SVMXC__Date_Installed__c = System.Today(),
                    SVMXC__Contact__c = contact.Id,
                    SVMXC__Company__c = account.Id
                    );
    insert IBObject;
    
    case1.SVMXC__Component__c = IBObject.Id;
    update case1;
        
    svo.SVMXC__Component__c = IBObject.Id;
    update svo;
        
    shpLineObject2 = new SVMXC__RMA_Shipment_Line__c(
                                                    SVMXC__RMA_Shipment_Order__c=shpObject1.Id , 
                                                    RecordTypeId = rtSHPLine.Id ,
                                                    Serial_Number__c = IBObject.Id,
                                                    SVMXC__Line_Status__c ='Open',
                                                    SVMXC__Select__c = true,
                                                    SVMXC__Actual_Quantity2__c =3
                                                    ); 

        
    shpLineObject3 = new SVMXC__RMA_Shipment_Line__c(
                                                    SVMXC__RMA_Shipment_Order__c=shpObject1.Id , 
                                                    RecordTypeId = rtSHPLine.Id ,
                                                    Serial_Number__c = IBObject.Id,
                                                    SVMXC__Product__c = prod.Id,
                                                    SVMXC__Line_Status__c ='Open',
                                                    SVMXC__Select__c = true,
                                                    SVMXC__Actual_Quantity2__c =3,
                                                    SVMXC__Use_Price_From_Pricebook__c = true
                                                    ); 

    Test.startTest();
    /*******************************************************************************************************************
    Scenario to Launch Page with url parameters id 
    *******************************************************************************************************************/
       PageReference pageRef1 = new PageReference('Page.SVMXC.PORD_CreateRMAFromWO');
       system.assertNotEquals(svo.Id,null);
       pageRef1.getParameters().put('wid',svo.Id);
       Test.setCurrentPageReference(pageRef1); 
       ControllerObj1 = new SVMXC.PORD_CreateRMAFromWO ();
       ControllerObj1.getUserLocaleKey();
       ControllerObj1.getUserID();
       ControllerObj1.getUserOrgID();
       ControllerObj1.getSelectedRecordType();
       ControllerObj1.setSelectedRecordType('Shipment');
       ControllerObj1.getRecordTypes();
       ControllerObj1.getselectedLineRecordType();
       ControllerObj1.setselectedLineRecordType('Request/Receipt');
       ControllerObj1.getLineRecordTypes();
       ControllerObj1.getDisableSourceAddress();
       ControllerObj1.getLocationFromId(destLocation.Id);
       ControllerObj1.setAddressForTargetLoc();
       ControllerObj1.UpdateLineRecord();
       

    /*******************************************************************************************************************
    Scenario to qualify the method setAddress() with different Address Types
    *******************************************************************************************************************/
      
      ControllerObj1.SelectedAddressType = 'Account Shipping Address';
      ControllerObj1.setAddress();
      ControllerObj1.SelectedAddressType = 'Account Billing Address';      
      ControllerObj1.setAddress();
      ControllerObj1.SelectedAddressType = 'Contact Mailing Address';
      ControllerObj1.setAddress();
      ControllerObj1.SelectedAddressType = 'Contact Other Address';
      ControllerObj1.setAddress();
      ControllerObj1.SelectedAddressType = 'Installed Product Address';
      ControllerObj1.setAddress();
      ControllerObj1.SelectedAddressType = 'I will Enter a Location/Address';
      ControllerObj1.setAddress();
      ControllerObj1.SelectedAddressType = null;
      ControllerObj1.setAddress();
      
      SVMXC__RMA_Shipment_Order__c PO1 = new SVMXC__RMA_Shipment_Order__c();
      
      PO1 = ControllerObj1.getNewRMAShpipmentHeader();
      PO1.SVMXC__Source_Location__c = sourceLocation.Id;
      ControllerObj1.setNewRMAShpipmentHeader(PO1);
      ControllerObj1.setAddress();
      
        /*******************************************************************************************************************
        Scenario to Add a new Line to Shipment Order
        *******************************************************************************************************************/

        List<SVMXC__RMA_Shipment_Line__c> objArray1 = new List<SVMXC__RMA_Shipment_Line__c> ();
        objArray1.add(shpLineObject1);
        ControllerObj1.setNewRMAShpipmentLines( objArray1);    
        PageReference addLineRef = ControllerObj1.AddLine();
        
        /*******************************************************************************************************************
        Scenario to Remove a new Line to Shipment Order
        *******************************************************************************************************************/
        PageReference removeLineRef = ControllerObj1.RemoveLine();

        /*******************************************************************************************************************
        Scenario to populate Product and Product Price for  Line in Shipment Order
        *******************************************************************************************************************/
        List<SVMXC__RMA_Shipment_Line__c> objArray2 = new List<SVMXC__RMA_Shipment_Line__c> ();
        objArray2.add(shpLineObject2);
        objArray2.add(shpLineObject3);        
        ControllerObj1.setNewRMAShpipmentLines( objArray2);
        ControllerObj1.UpdateLineRecord();

        /*******************************************************************************************************************
        Scenario to Create Shipment Order with Lines
        *******************************************************************************************************************/
        PageReference clearWarnings   = ControllerObj1.ClearWarnings();
        
        /*******************************************************************************************************************
        Scenario to display Warnings
        *******************************************************************************************************************/
        ControllerObj1.AddToWarningsList('Msg');
        system.assert(ControllerObj1.getshowWarnings()!=null,'getshowWarnings assertion failed');
        ControllerObj1.getshowWarnings();
        ControllerObj1.DisplayErrorsNWarnings();

        /*******************************************************************************************************************
        Scenario to Cancel the creation of Shipment Order with Lines
        *******************************************************************************************************************/
        PageReference cancel = ControllerObj1.Cancel();

        /*******************************************************************************************************************
        Scenario to clear the Source and Destination address of Shipment Order 
        *******************************************************************************************************************/
        ControllerObj1.clearAddress('Source');
        ControllerObj1.clearAddress('Destination');

        /*******************************************************************************************************************
        Scenario to hide and display PageBlockTable
        *******************************************************************************************************************/
        ControllerObj1.setNewRMAShpipmentLines(objArray2);
        Boolean showTableCols = ControllerObj1.getDisplayTableColumns();
        system.assert(showTableCols==true);
        List<SVMXC__RMA_Shipment_Line__c> objArray3 = new List<SVMXC__RMA_Shipment_Line__c> (); 
        ControllerObj1.setNewRMAShpipmentLines(objArray3);     
        Boolean hideTableCols = ControllerObj1.getDisplayTableColumns();
        system.assert(hideTableCols==false);
        
        /*******************************************************************************************************************
        Scenario to qualify regular set & get methods
        *******************************************************************************************************************/
          ControllerObj1.setNewRMAShpipmentHeader(ControllerObj1.getNewRMAShpipmentHeader());
          List<SVMXC__RMA_Shipment_Line__c> NewShipmentLines = ControllerObj1.getNewRMAShpipmentLines();
          SVMXC__Service_Order__c WO2  = ControllerObj1.getWOHeader();
          Boolean chkAllLines = ControllerObj1.getCheckAllLines();
          ControllerObj1.setCheckAllLines(true);
          ControllerObj1.setshowWarnings(true);
          List<String> strList1 = ControllerObj1.getErrorsList();
          ControllerObj1.AddToWarningsList('msg');
          List<String> strList2 = ControllerObj1.getWarningsList();
          Boolean dblMesg = ControllerObj1.getDisplayBlockLevelMessage();
          system.assertEquals(dblMesg,false);
          Boolean dForm = ControllerObj1.getDisplayForm();
          system.assert(dForm);
          String strAddType = ControllerObj1.getSelectedAddressType();
          ControllerObj1.setSelectedAddressType(strAddType);
          List<SelectOption>SelOpt = ControllerObj1.getAddressTypes() ;    
            
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
        system.assert(ControllerObj1.getTAG036()!=null,'TAG036 assertion failed');
        system.assert(ControllerObj1.getTAG039()!=null,'TAG039 assertion failed');
        system.assert(ControllerObj1.getTAG044()!=null,'TAG044 assertion failed');
        system.assert(ControllerObj1.getTAG045()!=null,'TAG045 assertion failed');
        system.assert(ControllerObj1.getTAG046()!=null,'TAG046 assertion failed');
        //system.assert(ControllerObj1.getTAG047()!=null,'TAG047 assertion failed');
         //system.assert(ControllerObj1.getTAG049()!=null,'TAG049 assertion failed');
        system.assert(ControllerObj1.getHLPURL()!=null,'HLPURL assertion failed');
        system.assert(ControllerObj1.getTAG050()!=null,'TAG050 assertion failed');
        system.assert(ControllerObj1.getTAG051()!=null,'TAG051 assertion failed');
        system.assert(ControllerObj1.getTAG052()!=null,'TAG052 assertion failed');
        system.assert(ControllerObj1.getTAG053()!=null,'TAG053 assertion failed');
        system.assert(ControllerObj1.getTAG054()!=null,'TAG054 assertion failed');
       // ControllerObj1.svmxTagList.clear(); //Clearing the Tags ,so as to qualify the else part of ternary operator 
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
        system.assert(ControllerObj1.getTAG036()!=null,'TAG036 assertion failed');
        system.assert(ControllerObj1.getTAG039()!=null,'TAG039 assertion failed');
        system.assert(ControllerObj1.getTAG044()!=null,'TAG044 assertion failed');
        system.assert(ControllerObj1.getTAG045()!=null,'TAG045 assertion failed');
        system.assert(ControllerObj1.getTAG046()!=null,'TAG046 assertion failed');
        //system.assert(ControllerObj1.getTAG047()!=null,'TAG047 assertion failed');
        //system.assert(ControllerObj1.getTAG049()!=null,'TAG049 assertion failed');
        system.assert(ControllerObj1.getHLPURL()!=null,'HLPURL assertion failed');
        system.assert(ControllerObj1.getTAG050()!=null,'TAG050 assertion failed');
        system.assert(ControllerObj1.getTAG051()!=null,'TAG051 assertion failed');
        system.assert(ControllerObj1.getTAG052()!=null,'TAG052 assertion failed');
        system.assert(ControllerObj1.getTAG053()!=null,'TAG053 assertion failed');
        system.assert(ControllerObj1.getTAG054()!=null,'TAG054 assertion failed');
        
        /*******************************************************************************************************************
        Code to modify  Current Settings and applying different Scenarios
        *******************************************************************************************************************/
        //Clearing all the Settings
        ControllerObj1.AllSubModuleSettings.clear();
        ControllerObj1.ValidateAllSettings();
        PageReference pageRef3 = new PageReference('Page.SVMXC.PORD_CreateRMAFromWO');
        pageRef3.getParameters().put('wid',svo.Id);
        Test.setCurrentPageReference(pageRef1); 
         
        //Populating different values for Settings
       //Setng_ActionOnBlankFromAddress -SET007
       //Setng_ActionOnBlankToAddress  -SET008
       //Setng_usePriceFromPriceBook   -SET010
       //Setng_RMAPriceBookName - SET011
       ControllerObj1.AllSubModuleSettings.put('SET007','Disallow');
       ControllerObj1.AllSubModuleSettings.put('SET008','Disallow');
       ControllerObj1.AllSubModuleSettings.put('SET010','TRUE');
       ControllerObj1.AllSubModuleSettings.put('SET011',null);     
       ControllerObj1.ValidateAllSettings();

       SVMXC__RMA_Shipment_Order__c PO3 = new SVMXC__RMA_Shipment_Order__c();
       PO3 = ControllerObj1.getNewRMAShpipmentHeader();
       PO3.SVMXC__Source_Location__c = null;
       PO3.SVMXC__Destination_Location__c = null;
       ControllerObj1.setNewRMAShpipmentHeader(PO3);
       ControllerObj1.setAddress();
       ControllerObj1.clearAddress('Destination');
       ControllerObj1.clearAddress('Source');
       ControllerObj1.AddRMASHPHeader();
       ControllerObj1.AllSubModuleSettings.put('SET007','Warn');
       ControllerObj1.AllSubModuleSettings.put('SET008','Warn');
       ControllerObj1.AllSubModuleSettings.put('SET010','FALSE');      
       ControllerObj1.AllSubModuleSettings.put('SET011','No Price Book');
       ControllerObj1.ValidateAllSettings();
       
      PO3 = ControllerObj1.getNewRMAShpipmentHeader();
      PO3.SVMXC__Source_Location__c = null;
      PO3.SVMXC__Destination_Location__c = null;
      ControllerObj1.setNewRMAShpipmentHeader(PO3);
      ControllerObj1.setAddress();
      ControllerObj1.clearAddress('Destination');
      ControllerObj1.clearAddress('Source');
      ControllerObj1.AddRMASHPHeader();
      Test.stopTest();
         }catch(exception Ex){}
        }//Test Method
        
        
}