@isTest
private with sharing class SFM_GetOperators_UT
{
    static testMethod void SFM_GetOperatorsUnitTest()
    {
        //--------Data Creation to satisfy the conditions in the Methods of the class-------------
         List<SFM_WrapperDef.SFM_StringMap> stringMap=new List<SFM_WrapperDef.SFM_StringMap>();
         
         //Creating data as per the required OPERATORTYPE as ALL and OBJECTNAME
         stringMap.add(new SFM_WrapperDef.SFM_StringMap ('OPERATORTYPE','ALL'));
         stringMap.add(new SFM_WrapperDef.SFM_StringMap ('OBJECTNAME','SVMXC__RMA_Shipment_Order__c'));
         SFM_WrapperDef.SFM_Request request = new SFM_WrapperDef.SFM_Request('','','',stringMap);
         
         //Creating object of the class and calling the method
         SFM_GetOperators getoperator = new SFM_GetOperators();
         getoperator.SFM_GetOperatorsList(request);
         
         //Creating data as per the required OPERATORTYPE as DATE and OBJECTNAME
         stringMap.add(new SFM_WrapperDef.SFM_StringMap ('OPERATORTYPE','DATE'));
         stringMap.add(new SFM_WrapperDef.SFM_StringMap ('OBJECTNAME','SVMXC__RMA_Shipment_Order__c'));
         SFM_WrapperDef.SFM_Request request1 = new SFM_WrapperDef.SFM_Request('','','',stringMap);
         
         //Creating object of the class and calling the method
         SFM_GetOperators getoperator1 = new SFM_GetOperators();
         getoperator1.SFM_GetOperatorsList(request1);                
         
         system.assertNotEquals(request,request1);
         
         //Creating data as per the required OPERATORTYPE as DATETIME and OBJECTNAME
         stringMap.add(new SFM_WrapperDef.SFM_StringMap ('OPERATORTYPE','DATETIME'));
         stringMap.add(new SFM_WrapperDef.SFM_StringMap ('OBJECTNAME','SVMXC__RMA_Shipment_Order__c'));
         SFM_WrapperDef.SFM_Request request2 = new SFM_WrapperDef.SFM_Request('','','',stringMap);
         
         //Creating object of the class and calling the method
         SFM_GetOperators getoperator2 = new SFM_GetOperators();
         getoperator2.SFM_GetOperatorsList(request2);                
         
         system.assertNotEquals(request,request2);
         system.assertNotEquals(request1,request2);
                          
         //Creating data as per the required OPERATORTYPE as USER and OBJECTNAME
         stringMap.add(new SFM_WrapperDef.SFM_StringMap ('OPERATORTYPE','USER'));
         stringMap.add(new SFM_WrapperDef.SFM_StringMap ('OBJECTNAME','SVMXC__RMA_Shipment_Order__c'));
         SFM_WrapperDef.SFM_Request request3 = new SFM_WrapperDef.SFM_Request('','','',stringMap);
         
         //Creating object of the class and calling the method
         SFM_GetOperators getoperator3 = new SFM_GetOperators();
         getoperator3.SFM_GetOperatorsList(request3);

         system.assertNotEquals(request,request3);
         system.assertNotEquals(request1,request3);
         system.assertNotEquals(request2,request3);
           
         //Creating data as per the required OPERATORTYPE as RECORDTYPE and OBJECTNAME                                      
         stringMap.add(new SFM_WrapperDef.SFM_StringMap ('OPERATORTYPE','RECORDTYPE'));
         stringMap.add(new SFM_WrapperDef.SFM_StringMap ('OBJECTNAME','SVMXC__RMA_Shipment_Order__c'));
         SFM_WrapperDef.SFM_Request request4 = new SFM_WrapperDef.SFM_Request('','','',stringMap);
         
         //Creating object of the class and calling the method
         SFM_GetOperators getoperator4 = new SFM_GetOperators();
         getoperator4.SFM_GetOperatorsList(request4); 

         system.assertNotEquals(request,request4);
         system.assertNotEquals(request1,request4);
         system.assertNotEquals(request2,request4);
         system.assertNotEquals(request3,request4);
                          
         //Creating data as per the required OPERATORTYPE as SOURCEUPDATE and OBJECTNAME
         stringMap.add(new SFM_WrapperDef.SFM_StringMap ('OPERATORTYPE','SOURCEUPDATE'));
         stringMap.add(new SFM_WrapperDef.SFM_StringMap ('OBJECTNAME','SVMXC__RMA_Shipment_Order__c'));
         SFM_WrapperDef.SFM_Request request5 = new SFM_WrapperDef.SFM_Request('','','',stringMap);
         
         //Creating object of the class and calling the method
         SFM_getOperators getoperator5 = new SFM_getOperators ();
         getoperator5.SFM_GetOperatorsList(request5); 

         system.assertNotEquals(request,request5);
         system.assertNotEquals(request1,request5);
         system.assertNotEquals(request2,request5);
         system.assertNotEquals(request3,request5);
         system.assertNotEquals(request4,request5);
                          
         //Creating data as per the required OPERATORTYPE as EXPRESSION and OBJECTNAME
         stringMap.add(new SFM_WrapperDef.SFM_StringMap ('OPERATORTYPE','EXPRESSION'));
         stringMap.add(new SFM_WrapperDef.SFM_StringMap ('OBJECTNAME','SVMXC__RMA_Shipment_Order__c'));
         SFM_WrapperDef.SFM_Request request6 = new SFM_WrapperDef.SFM_Request('','','',stringMap);
         
         //Creating object of the class and calling the method
         SFM_GetOperators getoperator6 = new SFM_GetOperators();
         getoperator6.SFM_GetOperatorsList(request6); 

         system.assertNotEquals(request,request6);
         system.assertNotEquals(request1,request6);
         system.assertNotEquals(request2,request6);
         system.assertNotEquals(request3,request6);
         system.assertNotEquals(request4,request6);
         system.assertNotEquals(request5,request6);
    }
    
    static testMethod void SFM_GetOperatorsUnitTest1()
    {
        SFM_GetOperators getoperator6 = new SFM_GetOperators();
        SFM_WrapperDef.SFM_Request request = new SFM_WrapperDef.SFM_Request();
        
        List<SFM_WrapperDef.SFM_StringMap> stringMap = new List<SFM_WrapperDef.SFM_StringMap>();
        stringMap.add(new SFM_WrapperDef.SFM_StringMap ('OPERATORTYPE','ALL'));
        stringMap.add(new SFM_WrapperDef.SFM_StringMap ('OBJECTNAME','SVMXC__RMA_Shipment_Order__c'));
        request.stringMap = stringMap;
        getoperator6.SFM_GetExpressionOperators(request);
        
        stringMap.clear();
        stringMap.add(new SFM_WrapperDef.SFM_StringMap ('OPERATORTYPE','EXPRESSION'));
        stringMap.add(new SFM_WrapperDef.SFM_StringMap ('OBJECTNAME','SVMXC__RMA_Shipment_Order__c'));
        request.stringMap = stringMap;
        getoperator6.SFM_GetExpressionOperators(request);
        
        stringMap.clear();
        stringMap.add(new SFM_WrapperDef.SFM_StringMap ('OPERATORTYPE','SOURCEUPDATE'));
        stringMap.add(new SFM_WrapperDef.SFM_StringMap ('OBJECTNAME','SVMXC__RMA_Shipment_Order__c'));
        request.stringMap = stringMap;
        getoperator6.SFM_GetExpressionOperators(request);
        
        stringMap.clear();
        stringMap.add(new SFM_WrapperDef.SFM_StringMap ('OPERATORTYPE','ID'));
        stringMap.add(new SFM_WrapperDef.SFM_StringMap ('OBJECTNAME','SVMXC__RMA_Shipment_Order__c'));
        request.stringMap = stringMap;
        getoperator6.SFM_GetExpressionOperators(request);
        
        stringMap.clear();
        stringMap.add(new SFM_WrapperDef.SFM_StringMap ('OPERATORTYPE','STRING'));
        stringMap.add(new SFM_WrapperDef.SFM_StringMap ('OBJECTNAME','SVMXC__RMA_Shipment_Order__c'));
        request.stringMap = stringMap;
        getoperator6.SFM_GetExpressionOperators(request);
        
        stringMap.clear();
        stringMap.add(new SFM_WrapperDef.SFM_StringMap ('OPERATORTYPE','BOOLEAN'));
        stringMap.add(new SFM_WrapperDef.SFM_StringMap ('OBJECTNAME','SVMXC__RMA_Shipment_Order__c'));
        request.stringMap = stringMap;
        getoperator6.SFM_GetExpressionOperators(request);
        
        stringMap.clear();
        stringMap.add(new SFM_WrapperDef.SFM_StringMap ('OPERATORTYPE','NUMERIC'));
        stringMap.add(new SFM_WrapperDef.SFM_StringMap ('OBJECTNAME','SVMXC__RMA_Shipment_Order__c'));
        request.stringMap = stringMap;
        getoperator6.SFM_GetExpressionOperators(request);
        
        stringMap.clear();
        stringMap.add(new SFM_WrapperDef.SFM_StringMap ('OPERATORTYPE','DATETIME'));
        stringMap.add(new SFM_WrapperDef.SFM_StringMap ('OBJECTNAME','SVMXC__RMA_Shipment_Order__c'));
        request.stringMap = stringMap;
        getoperator6.SFM_GetExpressionOperators(request);
        
        stringMap.clear();
        stringMap.add(new SFM_WrapperDef.SFM_StringMap ('OPERATORTYPE','MULTIPICKLIST'));
        stringMap.add(new SFM_WrapperDef.SFM_StringMap ('OBJECTNAME','SVMXC__RMA_Shipment_Order__c'));
        request.stringMap = stringMap;
        getoperator6.SFM_GetExpressionOperators(request);
    }
    
    
    static testMethod void SFM_GetOperatorsUnitTest2()
    {
        SFM_GetOperators getoperator6 = new SFM_GetOperators();
        SFM_WrapperDef.SFM_Request request = new SFM_WrapperDef.SFM_Request();
        
        List<SFM_WrapperDef.SFM_StringMap> stringMap = new List<SFM_WrapperDef.SFM_StringMap>();
        stringMap.add(new SFM_WrapperDef.SFM_StringMap ('OPERATORTYPE','ALL'));
        stringMap.add(new SFM_WrapperDef.SFM_StringMap ('OBJECTNAME','SVMXC__RMA_Shipment_Order__c'));
        request.stringMap = stringMap;
        getoperator6.SFM_GetConstants(request);
        
        stringMap.clear();
        stringMap.add(new SFM_WrapperDef.SFM_StringMap ('OPERATORTYPE','DATETIME'));
        stringMap.add(new SFM_WrapperDef.SFM_StringMap ('OBJECTNAME','SVMXC__RMA_Shipment_Order__c'));
        request.stringMap = stringMap;
        getoperator6.SFM_GetConstants(request);
        
        stringMap.clear();
        stringMap.add(new SFM_WrapperDef.SFM_StringMap ('OPERATORTYPE','DATE'));
        stringMap.add(new SFM_WrapperDef.SFM_StringMap ('OBJECTNAME','SVMXC__RMA_Shipment_Order__c'));
        request.stringMap = stringMap;
        getoperator6.SFM_GetConstants(request);
        
        stringMap.clear();
        stringMap.add(new SFM_WrapperDef.SFM_StringMap ('OPERATORTYPE','USER'));
        stringMap.add(new SFM_WrapperDef.SFM_StringMap ('OBJECTNAME','SVMXC__RMA_Shipment_Order__c'));
        request.stringMap = stringMap;
        getoperator6.SFM_GetConstants(request);
        
        stringMap.clear();
        stringMap.add(new SFM_WrapperDef.SFM_StringMap ('OPERATORTYPE','RECORDTYPE'));
        stringMap.add(new SFM_WrapperDef.SFM_StringMap ('OBJECTNAME','SVMXC__RMA_Shipment_Order__c'));
        request.stringMap = stringMap;
        getoperator6.SFM_GetConstants(request);
        
        stringMap.clear();
        stringMap.add(new SFM_WrapperDef.SFM_StringMap ('OPERATORTYPE','CUSTOM_SETTINGS'));
        stringMap.add(new SFM_WrapperDef.SFM_StringMap ('OBJECTNAME','SVMXC__RMA_Shipment_Order__c'));
        request.stringMap = stringMap;
        getoperator6.SFM_GetConstants(request);
        
        stringMap.clear();
        stringMap.add(new SFM_WrapperDef.SFM_StringMap ('OPERATORTYPE','SVMXC__Site__c'));
        stringMap.add(new SFM_WrapperDef.SFM_StringMap ('OBJECTNAME','SVMXC__RMA_Shipment_Order__c'));
        request.stringMap = stringMap;
        getoperator6.SFM_GetConstants(request);
    }   
    
}