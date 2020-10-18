@isTest
private class WORD_CreateQuote_UT
{
    private static SVMXC.WORD_CreateQuote QTObject,QTObject1;
    private static Account account;
    private static Contact contact;
    private static Case case1;
    private static Product2 prod;
    private static SVMXC__Installed_Product__c ib;
    private static SVMXC__Service_Order__c workorder;
    private static RecordType rtEst;
    private static SVMXC__Service_Order_Line__c woestline1,woestline2,woestline3;
    private static List<SVMXC__Service_Order_Line__c> svoEstLineArray = new List<SVMXC__Service_Order_Line__c>();
    private static SVMXC__ServiceMax_Processes__c  svmxprocess = new SVMXC__ServiceMax_Processes__c();
    private static SVMXC__Quote__c quoteObject;
    private static SVMXC__Quote_Line__c quoteLineObject;

    //============================== Variables for Configuration Setting Data =================================//
    private static List<RecordType> rtSVMX_Processes = new List<RecordType>();
    private static List<RecordType> rtSVMX_ConfData = new List<RecordType>();

    //Objects for Profile Object    
    private static SVMXC__ServiceMax_Config_Data__c configProfile;
    
    //Objects for Module, Submodule
    private static SVMXC__ServiceMax_Processes__c module;
    private static SVMXC__ServiceMax_Processes__c subModule; 
    
    // Objects for Setting Def
    private static SVMXC__ServiceMax_Processes__c settingDefForCheckEstLines;

    //Objects for Setting Value
    private static SVMXC__ServiceMax_Config_Data__c settingValForCheckEstLines;

    //================================================ TestCases =============================================//
    static testMethod void WORD_CreateQuote_UT()
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


        contact = new Contact(          
                                        LastName='Last',
                                        AccountId = account.Id,
                                        Email='svmxmailfortest@servicemax.com'
                                        );
        insert contact;

        case1 = new Case(Status ='New', Priority = 'Medium', 
                                        Origin = 'Email',                                        
                                                                                
                                        ContactId =contact.Id,
                                        AccountId=account.Id
                                        ); 
        insert case1;

        prod = new Product2( 
                                        Name = 'TestProd',
                                        ProductCode = '123',
                                        IsActive = true
                                        );
        insert prod;

        workorder = new SVMXC__Service_Order__c(
                                        SVMXC__Company__c = account.Id,
                                        SVMXC__Contact__c = contact.Id,
                                        SVMXC__Case__c = case1.Id,
                                        SVMXC__Order_Status__c = 'Open',
                                        SVMXC__Priority__c = 'Medium',
                                        SVMXC__Order_Type__c = 'Field Service'
                                        );
        insert workorder;
        
        quoteObject =new SVMXC__Quote__c(
                                    
                                    SVMXC__Quote_Amount2__c =123,
                                    SVMXC__Company__c =account.Id,
                                    SVMXC__Contact__c =contact.Id,
                                    SVMXC__Status__c ='New',
                                    SVMXC__Service_Order__c =workorder.id
                                           );
       insert quoteObject;
       
       quoteLineObject=new SVMXC__Quote_Line__c(
                                    
                                    SVMXC__Quote__c = quoteObject.Id,
                                    SVMXC__Quantity2__c = 12,
                                    SVMXC__Line_Price2__c=13.00,
                                    SVMXC__Discount_Type__c='Percent',
                                    SVMXC__Discount__c=10
                                                    );
        insert quoteLineObject;

        rtEst = [SELECT Id , Name FROM RecordType WHERE Name = 'Estimate' AND SobjectType ='SVMXC__Service_Order_Line__c' Limit 1];

        woestline1 = new SVMXC__Service_Order_Line__c(
                                        RecordTypeId = rtEst.Id,
                                        SVMXC__Service_Order__c = workorder.Id,
                                        SVMXC__Line_Type__c = 'Parts',
                                        SVMXC__Product__c = prod.Id,
                                        SVMXC__Estimated_Quantity2__c = 2,
                                        SVMXC__Estimated_Price2__c = 50,
                                        SVMXC__Use_Price_From_Pricebook__c = false
                                        );
        insert woestline1;

        woestline2 = new SVMXC__Service_Order_Line__c(
                                        RecordTypeId = rtEst.Id,
                                        SVMXC__Service_Order__c = workorder.Id,
                                        SVMXC__Line_Type__c = 'Labor',
                                        SVMXC__Product__c = prod.Id,
                                        SVMXC__Estimated_Quantity2__c = 2,
                                        SVMXC__Estimated_Price2__c = 45,
                                        SVMXC__Use_Price_From_Pricebook__c = false
                                        );
        insert woestline2;
        
        RecordType[] rts = [SELECT Id, Name FROM RecordType WHERE SobjectType = 'SVMXC__ServiceMax_Processes__c'];

        for(RecordType rt : rts) //Loop to take a record type at a time
        {
            // Create Obj Record
            if(rt.Name == 'Object Mapping')
            {
                SVMXC__ServiceMax_Processes__c objmaping = new SVMXC__ServiceMax_Processes__c(
                                            RecordTypeId =rt.Id,
                                            SVMXC__MapID__c = 'CUSTOMMAP010',
                                            SVMXC__Name__c = 'Work Order To Quote',
                                            SVMXC__Source_Object_Name__c = 'SVMXC__Service_Order__c',
                                            SVMXC__Target_Object_Name__c = 'SVMXC__Quote__c',
                                            SVMXC__Active__c = true
                                             
                                            );
                insert objmaping;
                objmaping = svmxprocess;
        
            }
        }
        RecordType[] rts2 = [SELECT Id, Name FROM RecordType WHERE SobjectType = 'SVMXC__ServiceMax_Config_Data__c']; 
        for(RecordType rt : rts2) //Loop to take a record type at a time
        {
            // Create Fld Mappings Record
            if(rt.Name == 'Field Mapping')
            {
                SVMXC__ServiceMax_Config_Data__c fldmapping = new SVMXC__ServiceMax_Config_Data__c(
                                            RecordTypeId =rt.Id,
                                            SVMXC__MapID__c = svmxprocess.id,
                                            SVMXC__Target_Field_Name__c = 'SVMXC__Company__c',
                                            SVMXC__Source_Field_Name__c = 'SVMXC__Company__c' ,
                                            SVMXC__Active__c = true
                                            
                                            );
           insert fldmapping;
        
        SVMXC__ServiceMax_Config_Data__c fldmapping1 = new SVMXC__ServiceMax_Config_Data__c(
                                            RecordTypeId =rt.Id,
                                            SVMXC__MapID__c = svmxprocess.id,
                                            SVMXC__Target_Field_Name__c = 'SVMXC__Contact__c',
                                            SVMXC__Source_Field_Name__c = 'SVMXC__Contact__c' ,
                                            SVMXC__Active__c = true
                                            
                                            );
        insert fldmapping1;
        
           }
        }
        
        Test.starttest();
        system.assertEquals(System.currentPageReference().getParameters().get('cid'),null);
        PageReference pageRef = new PageReference('Page.SVMXC.WORD_CreateQuote');
        pageRef.getParameters().put('cid',workorder.Id);
        Test.setCurrentPage(pageRef);
        QTObject = new SVMXC.WORD_CreateQuote();
        QTObject.getUserLocaleKey();
		QTObject.getUserID();
		QTObject.getUserOrgID();
        system.assertNotEquals(System.currentPageReference().getParameters().get('cid'),null);
        system.assertEquals(System.currentPageReference().getParameters().get('cid'),workorder.Id);
        pagereference cacl = QTObject.cancel();
        pagereference sav = QTObject.QuoteSave();
        pagereference adline = QTObject.AddLines();
        String Tag; 
        QTObject.QuoteSaveStatus='WARN';
        QTObject.getIsWarn();
        QTObject.IsWarn=true;
        QTObject.getIsWarn();
        system.assert(QTObject.getTAG001()!=null,'TAG001 assertion failed');
        system.assert(QTObject.getTAG002()!=null,'TAG002 assertion failed');
        system.assert(QTObject.getTAG003()!=null,'TAG003 assertion failed');
        system.assert(QTObject.getTAG004()!=null,'TAG004 assertion failed');
        system.assert(QTObject.getTAG005()!=null,'TAG005 assertion failed');
        system.assert(QTObject.getTAG006()!=null,'TAG006 assertion failed');
        system.assert(QTObject.getTAG007()!=null,'TAG007 assertion failed');
        system.assert(QTObject.getTAG008()!=null,'TAG008 assertion failed');
        system.assert(QTObject.getTAG009()!=null,'TAG009 assertion failed');
        //system.assert(QTObject.getTAG010()!=null,'TAG010 assertion failed');
        system.assert(QTObject.getTAG011()!=null,'TAG011 assertion failed');
        system.assert(QTObject.getTAG012()!=null,'TAG012 assertion failed');
        system.assert(QTObject.getTAG013()!=null,'TAG013 assertion failed');
        system.assert(QTObject.getTAG014()!=null,'TAG014 assertion failed');
        system.assert(QTObject.getTAG015()!=null,'TAG015 assertion failed');
        system.assert(QTObject.getTAG016()!=null,'TAG016 assertion failed');
        system.assert(QTObject.getTAG017()!=null,'TAG017 assertion failed');
        system.assert(QTObject.getTAG018()!=null,'TAG018 assertion failed');
        system.assert(QTObject.getTAG019()!=null,'TAG019 assertion failed');
        system.assert(QTObject.getTAG020()!=null,'TAG020 assertion failed');
        system.assert(QTObject.getTAG021()!=null,'TAG021 assertion failed');
        system.assert(QTObject.getTAG022()!=null,'TAG022 assertion failed');
        system.assert(QTObject.getTAG023()!=null,'TAG023 assertion failed');
        system.assert(QTObject.getTAG024()!=null,'TAG024 assertion failed');
        system.assert(QTObject.getTAG025()!=null,'TAG025 assertion failed');
        system.assert(QTObject.getTAG026()!=null,'TAG026 assertion failed');
        system.assert(QTObject.getTAG027()!=null,'TAG027 assertion failed');
        system.assert(QTObject.getTAG028()!=null,'TAG028 assertion failed');
        system.assert(QTObject.getTAG029()!=null,'TAG029 assertion failed');
        system.assert(QTObject.getTAG030()!=null,'TAG030 assertion failed');
        system.assert(QTObject.getTAG031()!=null,'TAG031 assertion failed');
        system.assert(QTObject.getTAG032()!=null,'TAG032 assertion failed');
        system.assert(QTObject.getTAG033()!=null,'TAG033 assertion failed');
        system.assert(QTObject.getTAG034()!=null,'TAG034 assertion failed');
        system.assert(QTObject.getTAG035()!=null,'TAG035 assertion failed');
        system.assert(QTObject.getTAG036()!=null,'TAG036 assertion failed');
        system.assert(QTObject.getTAG037()!=null,'TAG037 assertion failed');
        system.assert(QTObject.getTAG038()!=null,'TAG038 assertion failed');
        system.assert(QTObject.getTAG039()!=null,'TAG039 assertion failed');
        system.assert(QTObject.getTAG040()!=null,'TAG040 assertion failed');
        system.assert(QTObject.getTAG041()!=null,'TAG041 assertion failed');
        system.assert(QTObject.getTAG042()!=null,'TAG042 assertion failed');
        system.assert(QTObject.getTAG043()!=null,'TAG043 assertion failed');
        system.assert(QTObject.getTAG044()!=null,'TAG044 assertion failed');
        system.assert(QTObject.getTAG045()!=null,'TAG045 assertion failed');
        system.assert(QTObject.getTAG046()!=null,'TAG046 assertion failed');
        system.assert(QTObject.getTAG047()!=null,'TAG047 assertion failed');
        system.assert(QTObject.getHLPURL()!=null,'HLPURL assertion failed');
       // QTObject.svmxTagList.clear();
        system.assert(QTObject.getTAG001()!=null,'TAG001 assertion failed');
        system.assert(QTObject.getTAG002()!=null,'TAG002 assertion failed');
        system.assert(QTObject.getTAG003()!=null,'TAG003 assertion failed');
        system.assert(QTObject.getTAG004()!=null,'TAG004 assertion failed');
        system.assert(QTObject.getTAG005()!=null,'TAG005 assertion failed');
        system.assert(QTObject.getTAG006()!=null,'TAG006 assertion failed');
        system.assert(QTObject.getTAG007()!=null,'TAG007 assertion failed');
        system.assert(QTObject.getTAG008()!=null,'TAG008 assertion failed');
        system.assert(QTObject.getTAG009()!=null,'TAG009 assertion failed');
        //system.assert(QTObject.getTAG010()!=null,'TAG010 assertion failed');
        system.assert(QTObject.getTAG011()!=null,'TAG011 assertion failed');
        system.assert(QTObject.getTAG012()!=null,'TAG012 assertion failed');
        system.assert(QTObject.getTAG013()!=null,'TAG013 assertion failed');
        system.assert(QTObject.getTAG014()!=null,'TAG014 assertion failed');
        system.assert(QTObject.getTAG015()!=null,'TAG015 assertion failed');
        system.assert(QTObject.getTAG016()!=null,'TAG016 assertion failed');
        system.assert(QTObject.getTAG017()!=null,'TAG017 assertion failed');
        system.assert(QTObject.getTAG018()!=null,'TAG018 assertion failed');
        system.assert(QTObject.getTAG019()!=null,'TAG019 assertion failed');
        system.assert(QTObject.getTAG020()!=null,'TAG020 assertion failed');
        system.assert(QTObject.getTAG021()!=null,'TAG021 assertion failed');
        system.assert(QTObject.getTAG022()!=null,'TAG022 assertion failed');
        system.assert(QTObject.getTAG023()!=null,'TAG023 assertion failed');
        system.assert(QTObject.getTAG024()!=null,'TAG024 assertion failed');
        system.assert(QTObject.getTAG025()!=null,'TAG025 assertion failed');
        system.assert(QTObject.getTAG026()!=null,'TAG026 assertion failed');
        system.assert(QTObject.getTAG027()!=null,'TAG027 assertion failed');
        system.assert(QTObject.getTAG028()!=null,'TAG028 assertion failed');
        system.assert(QTObject.getTAG029()!=null,'TAG029 assertion failed');
        system.assert(QTObject.getTAG030()!=null,'TAG030 assertion failed');
        system.assert(QTObject.getTAG031()!=null,'TAG031 assertion failed');
        system.assert(QTObject.getTAG032()!=null,'TAG032 assertion failed');
        system.assert(QTObject.getTAG033()!=null,'TAG033 assertion failed');
        system.assert(QTObject.getTAG034()!=null,'TAG034 assertion failed');
        system.assert(QTObject.getTAG035()!=null,'TAG035 assertion failed');
        system.assert(QTObject.getTAG036()!=null,'TAG036 assertion failed');
        system.assert(QTObject.getTAG037()!=null,'TAG037 assertion failed');
        system.assert(QTObject.getTAG038()!=null,'TAG038 assertion failed');
        system.assert(QTObject.getTAG039()!=null,'TAG039 assertion failed');
        system.assert(QTObject.getTAG040()!=null,'TAG040 assertion failed');
        system.assert(QTObject.getTAG041()!=null,'TAG041 assertion failed');
        system.assert(QTObject.getTAG042()!=null,'TAG042 assertion failed');
        system.assert(QTObject.getTAG043()!=null,'TAG043 assertion failed');
        system.assert(QTObject.getTAG044()!=null,'TAG044 assertion failed');
        system.assert(QTObject.getTAG045()!=null,'TAG045 assertion failed');
        system.assert(QTObject.getTAG046()!=null,'TAG046 assertion failed');
        system.assert(QTObject.getTAG047()!=null,'TAG047 assertion failed');
        system.assert(QTObject.getHLPURL()!=null,'HLPURL assertion failed');
      
        system.assert(QTObject.getEstRecordTypes()!=null,'getEstRecordTypes assertion failed');
        QTObject.getEstRecordTypes();
        system.assert(QTObject.getCheckAllLines()==false,'getCheckAllLines assertion failed');
        QTObject.getCheckAllLines();
        system.assert(QTObject.getQuoteHeader()!=null,'getQuoteHeader assertion failed');
        QTObject.getQuoteHeader();
        system.assert(QTObject.getPrintQlines()!=null,'getPrintQlines assertion failed');
        QTObject.getPrintQlines();      
        system.assert(QTObject.isValidQuote()!=null,'isValidQuote assertion failed');
        QTObject.isValidQuote();
        QTObject.setCheckAllLines(true);
        
       RecordType rt = QTObject.getEstRecordTypes();
        
       SVMXC__Quote__c QO = QTObject.getQuoteHeader();
       List<SVMXC__Quote_Line__c> Qline = QTObject.getPrintQlines();
       {
       PageReference pageRef2 = new PageReference('Page.SVMXC.WORD_CreateQuote');
       pageRef2.getParameters().put('id',quoteObject.id);
       Test.setCurrentPage(pageRef2);
       
       SVMXC.WORD_CreateQuote wordcQ = new SVMXC.WORD_CreateQuote();
       wordcQ.OnChangeHeaderItems();
       wordcQ.getQuote_DisplayBlockLevelMessage();
       wordcQ.getQuote_DisplayBlockLevelMessage2();
       wordcQ.getQuoteLine_DisplayBlockLevelMessage();
       system.assertNotEquals(quoteObject.id,null);
       wordcQ.QOId=quoteObject.id;
       Boolean a =  wordcQ.getCheckAllLines();
       system.assertEquals(a,false);
       wordcQ.QuoteSave();
       wordcQ.getCheckAllLines();
       wordcQ.QuoteLines.clear();
       quoteLineObject.Select__c=true;
       wordcQ.QuoteLines.add(quoteLineObject);
       wordcQ.DeleteLines();
       wordcQ.getEstRecordTypes();
       wordcQ.getQuoteHeader();
       wordcQ.getPrintQlines();       
       wordcQ.isValidQuote();
       Test.stoptest();
       }    
}
}