@isTest(seealldata = true)
private class INTF_IB_PopulateName_UT {
    static testMethod void INTF_IB_PopulateName_test(){

        /*-----------------------------------------DATA CREATION-------------------------------------------------*/
        //---------------------------------Creating RecordTypeList-----------------------------------------
        list<RecordType> RecordTypeList = new list<RecordType>();
        RecordTypeList = [Select SystemModstamp, SobjectType, NamespacePrefix, Name, LastModifiedDate, LastModifiedById, IsActive, Id, DeveloperName, Description, CreatedDate, CreatedById, BusinessProcessId From RecordType where SobjectType = 'SVMXC__ServiceMax_Processes__c'or SobjectType = 'SVMXC__ServiceMax_Config_Data__c'];
        String FldmappingId = '';
        String ProcessNodeobj = '';
        String TargetManager = '';
        if(RecordTypeList.size() > 0)
        {
            for(RecordType R : RecordTypeList)
            {
                if(R.Name == 'Field Mapping')
                    FldmappingId = R.id;
                if(R.Name == 'Process Node Objects')
                    ProcessNodeobj = R.id;
                if(R.Name == 'Target Manager')
                    TargetManager = R.id;       
            }
        }
        //---------------------------------Creating the process object-------------------------------------
        SVMXC__ServiceMax_Processes__c processNodes = new SVMXC__ServiceMax_Processes__c();
        processNodes.RecordTypeId = TargetManager;
        processNodes.SVMXC__Name__c = 'process1';
        processNodes.SVMXC__Description__c = 'newprocess1';
        processNodes.SVMXC__ProcessID__c = 'process1';
        processNodes.SVMXC__IsStandard__c = true;
        insert processNodes;
        
        system.assert(processNodes != null, true);
        
        SVMXC__ServiceMax_Processes__c NodeObj1 = new SVMXC__ServiceMax_Processes__c(); 
        NodeObj1.RecordTypeId = ProcessNodeobj;
        NodeObj1.SVMXC__Process__c = processNodes.id;
        NodeObj1.SVMXC__Source_Object_Name__c = 'SVMXC__Installed_Product__c';
        NodeObj1.SVMXC__Type__c = 'SOURCE';
        insert NodeObj1;
        system.assertEquals(NodeObj1.SVMXC__Process__c, processNodes.id);
        SVMXC__ServiceMax_Processes__c NodeObj3 = new SVMXC__ServiceMax_Processes__c();
        NodeObj3.RecordTypeId = ProcessNodeobj;
        NodeObj3.SVMXC__Process__c = processNodes.id;
        NodeObj3.SVMXC__Source_Object_Name__c = 'SVMXC__Installed_Product__c';
        NodeObj3.SVMXC__Type__c = 'TARGET';
        NodeObj3.SVMXC__Parent_Object__c = NodeObj1.id;
        insert NodeObj3;
        
        system.assertEquals(NodeObj3.SVMXC__Process__c, processNodes.id);
        Product2 pro= new Product2();
        pro.Family = 'Apple';
        pro.IsActive = true;
        pro.ProductCode = '0001';
        pro.Name = 'Apple';
        insert pro;
        SVMXC__Installed_Product__c IB1 = new SVMXC__Installed_Product__c();
        IB1.Name = 'TopLevel';
        IB1.SVMXC__Product__c = pro.id; 
        insert IB1;
        SVMXC__Installed_Product__c IB2 = new SVMXC__Installed_Product__c();
        IB2.Name = 'Parent';
        IB2.SVMXC__Product__c = pro.id;
        IB2.SVMXC__Parent__c =  IB1.id;
        insert IB2;
        SVMXC__Installed_Product__c IB3 = new SVMXC__Installed_Product__c();
        IB3.SVMXC__City__c = 'Bangalore';
        IB3.SVMXC__Country__c = 'India';
        IB3.SVMXC__Street__c = 'Cunninghum';
        IB3.SVMXC__Top_Level__c = IB1.id;
        IB3.SVMXC__Parent__c = IB2.id;
        insert IB3;
         
        //----------------------Creating List of StringMap for Header Target Record---------------------------
        List<INTF_WebServicesDef.INTF_StringMap> ListOfStringMap = new List<INTF_WebServicesDef.INTF_StringMap>();
        INTF_WebServicesDef.INTF_StringMap Stringmapcls1 = new INTF_WebServicesDef.INTF_StringMap('SVMXC__City__c','Bangalore');
        INTF_WebServicesDef.INTF_StringMap Stringmapcls2 = new INTF_WebServicesDef.INTF_StringMap('SVMXC__Country__c','India');
        INTF_WebServicesDef.INTF_StringMap Stringmapcls3 = new INTF_WebServicesDef.INTF_StringMap('SVMXC__Street__c','Cunninghum');
        ListOfStringMap.add(Stringmapcls1);
        ListOfStringMap.add(Stringmapcls2);
        ListOfStringMap.add(Stringmapcls3);
        
        //-----------------------------Creating List of INTF_Record for Header TargetRecObj----------------------------
        List<INTF_WebServicesDef.INTF_Record> SfmRecList1 = new List<INTF_WebServicesDef.INTF_Record>();
        INTF_WebServicesDef.INTF_Record SfmRec1 = new INTF_WebServicesDef.INTF_Record();
        SfmRec1.targetRecordId = IB3.id;
        SfmRec1.targetRecordAsKeyValue = ListOfStringMap;
        SfmRecList1.add(SfmRec1);
        
        system.assert(SfmRecList1 != null, true);
        
        //-------------------------------Creating Header Target Record Object-------------------------------------
        SVMXC.INTF_WebServicesDef.INTF_TargetRecordObject TargetRecObj = new SVMXC.INTF_WebServicesDef.INTF_TargetRecordObject();
        TargetRecObj.objName = 'SVMXC__Installed_Product__c';
        TargetRecObj.records =  SfmRecList1;
        
        system.assert(TargetRecObj != null, true);
        
        //---------------------------------Creating Target Record Object---------------------------------------
        SVMXC.INTF_WebServicesDef.INTF_TargetRecord sfmtargetrec = new SVMXC.INTF_WebServicesDef.INTF_TargetRecord();
        sfmtargetrec.sfmProcessId = processNodes.Id;
        sfmtargetrec.headerRecord = TargetRecObj;
        INTF_IB_PopulateName IBPopulateName = new INTF_IB_PopulateName();
        IBPopulateName.populateName(sfmtargetrec);
        
    }
}