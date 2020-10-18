@isTest
private class INTF_AddRecords_UT
{
    static testMethod void INTF_AddRecords_Test()
    {    
        List<RecordType> lstRecType = [SELECT Id, Name FROM RecordType WHERE SobjectType = 'SVMXC__ServiceMax_Processes__c' OR SobjectType = 'SVMXC__ServiceMax_Config_Data__c'];
        String TargetManager = '';
        String ObjectMapping = '';
        String Fieldmapping = '';
        String ProcessNodeObj = '';
        for(RecordType r : lstRecType)
        {
            if(r.Name == 'Target Manager')
                TargetManager = r.id;
            if(r.Name == 'Object Mapping')  
                ObjectMapping = r.id;
            if(r.Name == 'Field Mapping')
                Fieldmapping = r.id;    
            if(r.Name == 'Process Node Objects')    
                ProcessNodeObj = r.id;
        }   
        Product2 pro = new Product2();
        pro.Name = 'Gear1';
        insert pro;
        SVMXC__Page_Layout__c pagelayout = new SVMXC__Page_Layout__c();
        pagelayout.SVMXC__Name__c = 'Workorder layout';
        pagelayout.SVMXC__Page_Layout_ID__c = 'CUSTOMPAGE001';
        pagelayout.SVMXC__Object_Name__c = 'SVMXC__Service_Order__c';
        pagelayout.SVMXC__Type__c = 'Header';
        insert pagelayout;
        
        SVMXC__Page_Layout__c pagelayout1 = new SVMXC__Page_Layout__c();
        pagelayout1.SVMXC__Name__c = 'WorkDetail layout';
        pagelayout1.SVMXC__Page_Layout_ID__c = 'WorkDetail';
        pagelayout1.SVMXC__Object_Name__c = 'SVMXC__Service_Order__c';
        pagelayout1.SVMXC__Type__c = 'Detail';
        pagelayout1.SVMXC__Header_Page_Layout__c = pagelayout.id;
        pagelayout1.SVMXC__Allow_New_Lines__c = true;
        pagelayout1.SVMXC__Allow_Delete_Lines__c = true;
        pagelayout1.SVMXC__Multi_Add_Search_Object__c = 'Product2';
        pagelayout1.SVMXC__Multi_Add_Search_Field__c = 'SVMXC__Product__c';
        insert pagelayout1;
        
        SVMXC__Page_Layout_Detail__c field1 = new SVMXC__Page_Layout_Detail__c();
        field1.SVMXC__Field_API_Name__c = 'SVMXC__Product__c';
        field1.SVMXC__Page_Layout__c = pagelayout1.id;
        field1.SVMXC__Detail_Type__c = 'Field';
        field1.SVMXC__DataType__c = 'REFERENCE';
        insert field1;  
        
        SVMXC__ServiceMax_Processes__c SFMProcess1 = new SVMXC__ServiceMax_Processes__c();
        SFMProcess1.RecordTypeId = TargetManager;
        SFMProcess1.SVMXC__Name__c = 'SFMPROCESSNAME001';
        SFMProcess1.SVMXC__ProcessID__c = 'SFMPROCESSNAME001';
        SFMProcess1.SVMXC__Rule_Type__c = 'Interactive';
        SFMProcess1.SVMXC__IsStandalone__c = true;
        SFMProcess1.SVMXC__Page_Layout__c = pagelayout.id;
        SFMProcess1.SVMXC__Purpose__c = 'EDIT';
        SFMProcess1.SVMXC__Source_Object_Name__c = 'SVMXC__Service_Order__c';
        
        insert SFMProcess1;
        
        SVMXC__ServiceMax_Processes__c PNodeObj2 = new SVMXC__ServiceMax_Processes__c();
        PNodeObj2.RecordTypeId = ProcessNodeObj;
        PNodeObj2.SVMXC__Process__c = SFMProcess1.id;
        PNodeObj2.SVMXC__Source_Object_Name__c = 'SVMXC__Service_Order__c';
        PNodeObj2.SVMXC__Type__c = 'TARGETCHILD';
        PNodeObj2.SVMXC__Node_Parent_API__c = 'SVMXC__Service_Order__c';
        PNodeObj2.SVMXC__Target_Object_label__c = 'WorkDetail';
        PNodeObj2.SVMXC__Parent_Column_Name__c = 'SVMXC__Service_Order__c';
        PNodeObj2.SVMXC__Page_Layout__c = pagelayout1.id;
        //PNodeObj2.SVMXC__Final_Exception_Process__c = SFMProcess1.id;
        insert PNodeObj2;
                
        SVMXC.INTF_WebServicesDef.INTF_Request Request = new SVMXC.INTF_WebServicesDef.INTF_Request();
        List<SVMXC.INTF_WebServicesDef.INTF_StringMap> stringmapList = new List<SVMXC.INTF_WebServicesDef.INTF_StringMap>();
        
        SVMXC.INTF_WebServicesDef.INTF_StringMap strmap = new SVMXC.INTF_WebServicesDef.INTF_StringMap();
        SVMXC.INTF_WebServicesDef.INTF_StringMap strmap1 = new SVMXC.INTF_WebServicesDef.INTF_StringMap();
        SVMXC.INTF_WebServicesDef.INTF_StringMap strmap2 = new SVMXC.INTF_WebServicesDef.INTF_StringMap();
        SVMXC.INTF_WebServicesDef.INTF_StringMap strmap3 = new SVMXC.INTF_WebServicesDef.INTF_StringMap();
        SVMXC.INTF_WebServicesDef.INTF_StringMap strmap4 = new SVMXC.INTF_WebServicesDef.INTF_StringMap();
        
        
        strmap.key = 'PROCESSID';
        strmap.value = SFMProcess1.Id;
        strmap1.key = 'IPAD';
        strmap1.value = '';
        strmap2.key = 'ALIAS';
        strmap2.value = pagelayout1.Id;
        strmap3.key = 'RECORDID';
        strmap4.key = 'FIELDAPINAME';
        strmap4.value= 'SVMXC__Product__c';
        stringmapList.add(strmap);
        stringmapList.add(strmap1);
        stringmapList.add(strmap2);
        stringmapList.add(strmap3);
        stringmapList.add(strmap4);
        
        Request.stringMap = stringmapList;
        
        SVMXC.INTF_WebServicesDef.INTF_StringListMap strlstmap = new SVMXC.INTF_WebServicesDef.INTF_StringListMap();
        strlstmap.key = 'RECORDID';
        List<String> strLst = new List<String>();
        strLst.add(pro.Id);
        strlstmap.valueList = strLst;
        List<SVMXC.INTF_WebServicesDef.INTF_StringListMap> strlstmapList = new List<SVMXC.INTF_WebServicesDef.INTF_StringListMap>();
        strlstmapList.add(strlstmap);
        
        Request.stringListMap = strlstmapList; 
        INTF_AddRecords addRecords = new INTF_AddRecords();
        addRecords.getINTF_AddRecords(Request);
        }//method
}//class