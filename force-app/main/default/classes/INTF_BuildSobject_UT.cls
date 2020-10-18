@isTest
Private class INTF_BuildSobject_UT{
    static testMethod void INTF_BuildSobject_test(){
    
        //*****instance of class*****
        INTF_buildSobject buildSobj = new INTF_buildSobject ();
        
        //***** Data Creation*****
        
        list<RecordType> list_RType = [SELECT Id, Name, IsActive from RecordType where SobjectType = 'SVMXC__ServiceMax_Processes__c' AND NAME='Named Search' limit 1];
        System.assertEquals(true, list_RType != null);
        
        //*****Variable declaration for 1st Data*****
        String recordID = list_RType[0].Id;
        String objectName = 'SVMXC__ServiceMax_Processes__c';
        String parentColumnName;
        integer noOfSobjects = 1;
        
        //*****Variable declaration for 2nd Data*****
        String recordID_2 ;
        String objectName_2 = 'SVMXC__ServiceMax_Processes__c';
        String parentColumnName_2 = 'SVMXC__Assign_Work_Order_To__c';
        integer noOfSobjects_2 = 1;
        
        //*****Variable declaration for 3rd Data*****
        String recordID_3 ;
        String objectName_3 = 'SVMXC__ServiceMax_Processes__c';
        String parentColumnName_3 = 'SVMXC__Assign_Work_Order_To__c';
        integer noOfSobjects_3 ;
        
        //*****Variable declaration for 4th Data*****
        String recordID_4 = list_RType[0].Id;
        String objectName_4 = 'SVMXC__ServiceMax_Processes__c';
        String parentColumnName_4 = 'SVMXC__Assign_Work_Order_To__c';
        integer noOfSobjects_4 = 10;
        
        //String ObjectName = 'Case';
        //Map<String, Schema.SObjectType> mapStrSchema = new Map<String, Schema.SObjectType>();
        //mapStrSchema.put('ObjectName',Case.getSobjectType());
        //mapStrSchema.containskey(ObjectName);
        //System.debug('*****'+mapStrSchema.containskey(ObjectName));
        //System.debug('*****ObjectName.length()'+ObjectName.length());
        
        
        //*****Calling Method*****
        buildSobj.getINTF_BuildSobject(recordID,objectName,parentColumnName,noOfSobjects);
        buildSobj.getINTF_BuildSobject(recordID_2,objectName_2,parentColumnName_2,noOfSobjects_2);
        buildSobj.getINTF_BuildSobject(recordID_3,objectName_3,parentColumnName_3,noOfSobjects_3);
        buildSobj.getINTF_BuildSobject(recordID_4,objectName_4,parentColumnName_4,noOfSobjects_4);
        
        System.assertEquals(true, buildSobj.getINTF_BuildSobject(recordID,objectName,parentColumnName,noOfSobjects) != null);
        System.assertEquals(true, buildSobj.getINTF_BuildSobject(recordID_2,objectName_2,parentColumnName_2,noOfSobjects_2) != null);
        System.assertEquals(true, buildSobj.getINTF_BuildSobject(recordID_3,objectName_3,parentColumnName_3,noOfSobjects_3) != null);
        System.assertEquals(true, buildSobj.getINTF_BuildSobject(recordID_4,objectName_4,parentColumnName_4,noOfSobjects_4) != null);
    }
}