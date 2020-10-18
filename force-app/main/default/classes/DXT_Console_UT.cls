@isTest(SeeAllData=true)
private class DXT_Console_UT 
{
    static testMethod void DXT_ConsoleTest() 
    {
        Account acc = new Account(Name = 'TestAccount');
        insert acc;
        
        Contact con =  new Contact(LastName = 'TestContact');
        insert con; 
        
        List<SVMXC__Service_Order__c> lstWorkOrder =  new List<SVMXC__Service_Order__c>();
        
        DateTime dt =  datetime.newInstance(2013, 12, 1, 12, 30, 2);
        SVMXC__Service_Order__c objWO1 = new SVMXC__Service_Order__c();
        objWO1.SVMXC__Order_Status__c = 'Closed';
        objWO1.SVMXC__Company__c = acc.id;
        objWO1.SVMXC__Contact__c = con.id;
        objWO1.SVMXC__Closed_On__c = dt;
        objWO1.SVMXC__Is_Exported__c = false;
        lstWorkOrder.add(objWO1);
        
        dt =  datetime.newInstance(2013, 12, 1, 12, 30, 2);
        SVMXC__Service_Order__c objWO2 = new SVMXC__Service_Order__c();
        objWO2.SVMXC__Order_Status__c = 'Closed';
        objWO2.SVMXC__Company__c = acc.id;
        objWO2.SVMXC__Contact__c = con.id;
        objWO2.SVMXC__Closed_On__c = dt;
        objWO2.SVMXC__Is_Exported__c = false;
        lstWorkOrder.add(objWO2);
        
        dt =  datetime.newInstance(2013, 12, 1, 12, 30, 2);
        SVMXC__Service_Order__c objWO3 = new SVMXC__Service_Order__c();
        objWO3.SVMXC__Order_Status__c = 'Closed';
        objWO3.SVMXC__Company__c = acc.id;
        objWO3.SVMXC__Contact__c = con.id;
        objWO3.SVMXC__Closed_On__c = dt;
        objWO3.SVMXC__Is_Exported__c = false;
        lstWorkOrder.add(objWO3);
        
        insert lstWorkOrder;
        
        SVMXC__Service_Order_Line__c objWODetail =  new SVMXC__Service_Order_Line__c();
        objWODetail.SVMXC__Service_Order__c = objWO1.id;
        insert objWODetail;
        
        /* RecordType rt = [SELECT Id FROM RecordType WHERE Name = 'Export Configuration' Limit 1];
        SVMXC__ServiceMax_Processes__c JSONConfigProcess = new SVMXC__ServiceMax_Processes__c();
        JSONConfigProcess.RecordTypeId = rt.id;
        JSONConfigProcess.SVMXC__IsDefault__c = true;
        JSONConfigProcess.SVMXC__IsStandard__c = true;
        JSONConfigProcess.SVMXC__Export_Configuration__c = '{"headerObjectAPIName": "SVMXC__Service_Order__c","childObjectAPIName":"SVMXC__Service_Order_Line__c", "headerEligibilityCriteriaID":"SVMXSTD:_Closed_Work_Orders_to_Export","childEligibilityCriteriaID": "SVMXSTD:Work_Details_to_Export", "filterDateField": "SVMXC__Closed_On__c", "defaultSortingField": "SVMXC__Closed_On__c", "sourceUpdate": [ { "field": "SVMXC__Is_Exported__c", "operator": "Set",  "value": "true" }  ], "displayFields": ["SVMXC__Company__c", "SVMXC__Contact__c", "SVMXC__Closed_On__c", "SVMXC__Total_Billable_Amount__c" ], "TRNS": [ { "label": "TRNSID", "fieldSeq": "1","value": "Name",  "valueType": "field",  "dateType": "INTEGER" },{ "label": "TRNSTYPE", "fieldSeq": "2", "value": "INVOICE", "valueType": "constant", "dateType": ""  },  {  "label": "DATE", "fieldSeq": "3","value": "SVMXC__Closed_On__c",  "valueType": "field",   "dateType": ""   },  {  "label": "ACCNT",  "fieldSeq": "4", "value": "Accounts Receivable", "valueType": "constant", "dateType": ""  }, {  "label": "NAME","fieldSeq": "5", "value": "SVMXC__Company__r.Name",  "valueType": "field", "dateType": ""  },{ "label": "CLASS", "fieldSeq": "6", "value": "",  "valueType": "constant", "dateType": ""  }, { "label": "AMOUNT", "fieldSeq": "7","value": "SVMXC__Total_Billable_Amount__c","isNeg": "No", "valueType": "field","dateType": "" }, { "label": "DOCNUM", "fieldSeq": "8", "value": "Name","isNeg": "No","valueType": "field","dateType": "INTEGER" }, { "label": "TOPRINT","fieldSeq": "9", "value": "Y", "valueType": "constant", "dateType": "" } ],"SPL": [ {  "label": "SPLID", "fieldSeq": "1", "value": "Name",            "isNeg": "No",            "valueType": "field",            "dateType": "INTEGER"        },        {            "label": "TRNSTYPE",            "fieldSeq": "2",            "value": "INVOICE",            "isNeg": "No",            "valueType": "constant",            "dateType": ""        },        {            "label": "DATE",            "fieldSeq": "3",            "value": "SVMXC__Closed_On__c",            "isNeg": "No",            "valueType": "field",            "dateType": ""        },        {            "label": "ACCNT",            "fieldSeq": "4",            "value": "Income..",            "isNeg": "No",            "valueType": "constant",            "dateType": ""       },        {            "label": "NAME",            "fieldSeq": "5",            "value": "",            "isNeg": "No",       "valueType": "constant",           "dateType": ""        },        {            "label": "AMOUNT",            "fieldSeq": "6",            "value": "SVMXC__Total_Line_Price__c",            "isNeg": "Yes",            "valueType": "field",            "dateType": ""        },        {            "label": "DOCNUM",            "fieldSeq": "7",            "value": "Name",            "isNeg": "No",            "valueType": "field",            "dateType": "INTEGER"        }    ]}';
        JSONConfigProcess.SVMXC__Name__c = 'Export Config Data';
        insert JSONConfigProcess;  */
        
        
        //ApexPages.currentPage().getParameters().put('id', JSONConfigProcess.id);
        
        DXT_Console objQuickBook =  new DXT_Console();
        objQuickBook.getmessageStatus();
        
        objQuickBook.sObjectId = lstWorkOrder[0].id + ',' + lstWorkOrder[1].id + ',';
        objQuickBook.exportData();
        objQuickBook.sObjectId = lstWorkOrder[2].id + ',';
        objQuickBook.saveIIFFile();
        list<SelectOption> options = objQuickBook.lstSize;
        String fileN = objQuickBook.strFileName;
        boolean b1 = objQuickBook.hasNext;
        boolean b2 = objQuickBook.hasPrevious;
        Integer b3 = objQuickBook.pageNumber;
        objQuickBook.strNavigateType = 'first';
        objQuickBook.Navigate();
        objQuickBook.strNavigateType = 'previous';
        objQuickBook.Navigate();
        objQuickBook.strNavigateType = 'next';
        objQuickBook.Navigate();
        objQuickBook.strNavigateType = 'last';
        objQuickBook.Navigate();
        objQuickBook.userSelectedNumber();
        
        objQuickBook.objCase.SVMXC__BW_Date__c = System.Today().addDays(-10);
        objQuickBook.objCase.SVMXC__Scheduled_Date__c = System.Today();
        objQuickBook.filterRecordsBetweenDates();
        
        DXT_Console.TransactionWrapper obj1 = new DXT_Console.TransactionWrapper('a', 'b', 'c', 'No', 'd','e');
        DXT_Console.sObjectWrapper obj2  = new DXT_Console.sObjectWrapper(false, new SVMXC__Service_Order__c());
        DXT_Console.EngineResponse obj3 = new DXT_Console.EngineResponse(false, 'msg');
        DXT_Console.EngineResponse obj4 = new DXT_Console.EngineResponse();
        DXT_Console.SourceUpdateWrapper obj5 = new DXT_Console.SourceUpdateWrapper('a','b','c');
        DXT_Console.EngineRequest obj6  = new DXT_Console.EngineRequest(new List<String>(), new List<DXT_Console.TransactionWrapper>(), new List<DXT_Console.TransactionWrapper>(), 'dlkfj@dfjkd.com', true, 'xyz', 'abc', 'pqr', new List<DXT_Console.SourceUpdateWrapper>());
        DXT_Console.JSONConfigWrapper obj7 = new DXT_Console.JSONConfigWrapper('xyz', 'aa', 'bb','xyz', 'aa', 'bb', new List<String>(), new List<DXT_Console.TransactionWrapper>(), new List<DXT_Console.TransactionWrapper>(), new List<DXT_Console.SourceUpdateWrapper>());
        
        objQuickBook.getTAG001();
        objQuickBook.getTAG002();
        objQuickBook.getTAG003();
        objQuickBook.getTAG004();
        objQuickBook.getTAG005();
        objQuickBook.getTAG006();
        objQuickBook.getTAG007();
        objQuickBook.getTAG008();
        objQuickBook.getTAG009();
        objQuickBook.getTAG010();
        objQuickBook.getTAG011();
        objQuickBook.getTAG012();
        objQuickBook.getTAG013();
        objQuickBook.getTAG014();
        objQuickBook.getTAG015();
        objQuickBook.getTAG016();
        objQuickBook.getTAG017();
        objQuickBook.getTAG018();
        objQuickBook.getTAG019();
        objQuickBook.getTAG020();
        objQuickBook.getTAG021();
        objQuickBook.getTAG022();
        objQuickBook.getTAG023();
        objQuickBook.getTAG024();
        objQuickBook.getHLPURL();
    }
}