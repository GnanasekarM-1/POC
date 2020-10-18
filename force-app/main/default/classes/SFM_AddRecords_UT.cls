@isTest
private class SFM_AddRecords_UT
{
    static testMethod void SFM_AddRecords_Test()
    {   
        //-------------------------------DATA PREPARATION------------------------------------------------------------------//
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
        //Create Product2 Record for multi add
        Product2 pro = new Product2();
        pro.Name = 'Gear1';
        insert pro;
        system.assert(pro.Name!=null);
        
        Product2 pro1 = new Product2();
        pro1.Name = 'Gear2';
        insert pro1;
        system.assert(pro1.Name!=null);
        
        //Create valuemapping 
        SVMXC__ServiceMax_Processes__c objmap = new SVMXC__ServiceMax_Processes__c();
        objmap.RecordTypeId = ObjectMapping;
        objmap.SVMXC__Target_Object_Name__c = 'SVMXC__Service_Order_Line__c';
        objmap.SVMXC__Name__c = 'Value mapping for WD';
        objmap.SVMXC__MapID__c = 'customvmap001';
        insert objmap;
        system.assert(objmap.RecordTypeId!=null);
        system.assert(objmap.SVMXC__Target_Object_Name__c!=null);
        system.assert(objmap.SVMXC__Name__c!=null);
          
        list<SVMXC__ServiceMax_Config_Data__c> Fldmappinglst = new list<SVMXC__ServiceMax_Config_Data__c>();
        SVMXC__ServiceMax_Config_Data__c fldmap1 = new SVMXC__ServiceMax_Config_Data__c();
        fldmap1.RecordTypeId = Fieldmapping;
        fldmap1.SVMXC__Target_Field_Name__c = 'SVMXC__Activity_Type__c';
        fldmap1.SVMXC__Display_Value__c = 'Calibration';
        fldmap1.SVMXC__MapID__c = objmap.id;
        Fldmappinglst.add(fldmap1);
        SVMXC__ServiceMax_Config_Data__c fldmap2 = new SVMXC__ServiceMax_Config_Data__c();
        fldmap2.RecordTypeId = Fieldmapping;
        fldmap2.SVMXC__Target_Field_Name__c = 'SVMXC__Closed_On__c';
        fldmap2.SVMXC__Display_Value__c = 'TODAY';
        fldmap2.SVMXC__MapID__c = objmap.id;
        Fldmappinglst.add(fldmap2);
        SVMXC__ServiceMax_Config_Data__c fldmap3 = new SVMXC__ServiceMax_Config_Data__c();
        fldmap3.RecordTypeId = Fieldmapping;
        fldmap3.SVMXC__Target_Field_Name__c = 'SVMXC__Is_Billable__c';
        fldmap3.SVMXC__Display_Value__c = 'true';
        fldmap3.SVMXC__MapID__c = objmap.id;
        Fldmappinglst.add(fldmap3);
        insert Fldmappinglst;
        system.assert(Fldmappinglst.size()>0);
        
          
        //Create PageLayout
        SVMXC__Page_Layout__c pagelayout = new SVMXC__Page_Layout__c();
        pagelayout.SVMXC__Name__c = 'Workorder layout';
        pagelayout.SVMXC__Page_Layout_ID__c = 'CUSTOMPAGE001';
        pagelayout.SVMXC__Object_Name__c = 'SVMXC__Service_Order__c';
        pagelayout.SVMXC__Type__c = 'Header';
        insert pagelayout;
        SVMXC__Page_Layout__c pagelayout1 = new SVMXC__Page_Layout__c();
        pagelayout1.SVMXC__Name__c = 'WorkDetail layout';
        pagelayout1.SVMXC__Page_Layout_ID__c = 'WorkDetail';
        pagelayout1.SVMXC__Object_Name__c = 'SVMXC__Service_Order_Line__c';
        pagelayout1.SVMXC__Type__c = 'Detail';
        pagelayout1.SVMXC__Header_Page_Layout__c = pagelayout.id;
        pagelayout1.SVMXC__Allow_New_Lines__c = true;
        pagelayout1.SVMXC__Allow_Delete_Lines__c = true;
        pagelayout1.SVMXC__Multi_Add_Search_Object__c = 'Product2';
        pagelayout1.SVMXC__Multi_Add_Search_Field__c = 'SVMXC__Product__c';
        insert pagelayout1;
          
        //Create Fields
        list<SVMXC__Page_Layout_Detail__c> fieldlist = new list<SVMXC__Page_Layout_Detail__c>();
        SVMXC__Page_Layout_Detail__c field1 = new SVMXC__Page_Layout_Detail__c();
        field1.SVMXC__Field_API_Name__c = 'SVMXC__Product__c';
        field1.SVMXC__Page_Layout__c = pagelayout.id;
        field1.SVMXC__Detail_Type__c = 'Field';
        fieldlist.add(field1);
        SVMXC__Page_Layout_Detail__c field2 = new SVMXC__Page_Layout_Detail__c();
        field2.SVMXC__Field_API_Name__c = 'SVMXC__Activity_Type__c';
        field2.SVMXC__Page_Layout__c = pagelayout.id;
        field2.SVMXC__Detail_Type__c = 'Field';
        fieldlist.add(field2);
        SVMXC__Page_Layout_Detail__c field3 = new SVMXC__Page_Layout_Detail__c();
        field3.SVMXC__Field_API_Name__c = 'SVMXC__Activity_Type__c';
        field3.SVMXC__Page_Layout__c = pagelayout1.id;
        field3.SVMXC__Detail_Type__c = 'Field';
        field3.SVMXC__DataType__c = 'REFERENCE';
        fieldlist.add(field3);
        insert fieldlist;
        
        //Create Process
        SVMXC__ServiceMax_Processes__c SFMProcess1 = new SVMXC__ServiceMax_Processes__c();
        SFMProcess1.RecordTypeId = TargetManager;
        SFMProcess1.SVMXC__Name__c = 'SFMPROCESSNAME001';
        SFMProcess1.SVMXC__ProcessID__c = 'SFMPROCESSNAME001';
        SFMProcess1.SVMXC__Rule_Type__c = 'Interactive';
        SFMProcess1.SVMXC__IsStandalone__c = true;
        SFMProcess1.SVMXC__Page_Layout__c = pagelayout.id;
        SFMProcess1.SVMXC__Purpose__c = 'EDIT';
        insert SFMProcess1;
        
        
        SVMXC__ServiceMax_Processes__c SFMProcess = new SVMXC__ServiceMax_Processes__c();
        SFMProcess.RecordTypeId = TargetManager;
        SFMProcess.SVMXC__Name__c = 'SFMPROCESSNAME001';
        SFMProcess.SVMXC__ProcessID__c = 'SFMPROCESSNAME001';
        SFMProcess.SVMXC__Rule_Type__c = 'Interactive';
        SFMProcess.SVMXC__IsStandalone__c = true;
        SFMProcess.SVMXC__Page_Layout__c = pagelayout.id;
        SFMProcess.SVMXC__Purpose__c = 'EDIT';
        insert SFMProcess;
        
        SVMXC__ServiceMax_Processes__c SFMProcess2 = new SVMXC__ServiceMax_Processes__c();
        SFMProcess2.RecordTypeId = TargetManager;
        SFMProcess2.SVMXC__Name__c = 'SFMPROCESSNAME001';
        SFMProcess2.SVMXC__ProcessID__c = 'SFMPROCESSNAME001';
        SFMProcess2.SVMXC__Rule_Type__c = 'Interactive';
        SFMProcess2.SVMXC__IsStandalone__c = true;
        SFMProcess2.SVMXC__Page_Layout__c = pagelayout1.id;
        SFMProcess2.SVMXC__Purpose__c = 'EDIT';
        insert SFMProcess2;
          
        //Create Process Node Objects
        SVMXC__ServiceMax_Processes__c PNodeObj1 = new SVMXC__ServiceMax_Processes__c();
        PNodeObj1.RecordTypeId = ProcessNodeObj;
        PNodeObj1.SVMXC__Process__c = SFMProcess.id;
        PNodeObj1.SVMXC__Source_Object_Name__c = 'SVMXC__Service_Order__c';
        PNodeObj1.SVMXC__Type__c = 'TARGET';
        PNodeObj1.SVMXC__Page_Layout__c = pagelayout.id;
        insert PNodeObj1;
          
        SVMXC__ServiceMax_Processes__c PNodeObj2 = new SVMXC__ServiceMax_Processes__c();
        PNodeObj2.RecordTypeId = ProcessNodeObj;
        PNodeObj2.SVMXC__Process__c = SFMProcess.id;
        PNodeObj2.SVMXC__Source_Object_Name__c = 'SVMXC__Service_Order_Line__c';
        PNodeObj2.SVMXC__Type__c = 'TARGETCHILD';
        PNodeObj2.SVMXC__Node_Parent_API__c = 'SVMXC__Service_Order__c';
        PNodeObj2.SVMXC__Target_Object_label__c = 'WorkDetail';
        PNodeObj2.SVMXC__Parent_Column_Name__c = 'SVMXC__Service_Order__c';
        PNodeObj2.SVMXC__Final_Exception_Process__c = objmap.id;
        PNodeObj2.SVMXC__Page_Layout__c = pagelayout1.id;
        insert PNodeObj2;
        
        SVMXC__ServiceMax_Processes__c PNodeObj3 = new SVMXC__ServiceMax_Processes__c();
        PNodeObj3.RecordTypeId = ProcessNodeObj;
        PNodeObj3.SVMXC__Process__c = SFMProcess2.id;
        PNodeObj3.SVMXC__Source_Object_Name__c = 'SVMXC__Service_Order_Line__c';
        PNodeObj3.SVMXC__Type__c = 'TARGETCHILD';
        PNodeObj3.SVMXC__Node_Parent_API__c = 'SVMXC__Service_Order__c';
        PNodeObj3.SVMXC__Target_Object_label__c = 'WorkDetail1';        
        PNodeObj3.SVMXC__Parent_Column_Name__c = 'SVMXC__Service_Order__c';
        PNodeObj3.SVMXC__Final_Exception_Process__c = objmap.id;
        PNodeObj3.SVMXC__Page_Layout__c = pagelayout1.id;
        insert PNodeObj3;
          
        SFM_WrapperDef.SFM_StringMap sfmStringMap_Obj1 = new SFM_WrapperDef.SFM_StringMap();
        SFM_WrapperDef.SFM_StringMap sfmStringMap_Obj2 = new SFM_WrapperDef.SFM_StringMap();
        SFM_WrapperDef.SFM_StringMap sfmStringMap_Obj3 = new SFM_WrapperDef.SFM_StringMap();
        //SFM_WrapperDef.SFM_StringMap sfmStringMap_Obj4 = new SFM_WrapperDef.SFM_StringMap();
        SFM_WrapperDef.SFM_StringListMap  sfmStringListMap_Obj1 = new SFM_WrapperDef.SFM_StringListMap();
        List<SFM_WrapperDef.SFM_StringListMap> lst1_sfmStringMapObj = new List<SFM_WrapperDef.SFM_StringListMap>();
        lst1_sfmStringMapObj.add(sfmStringListMap_Obj1);
        List<SFM_WrapperDef.SFM_StringMap> lst2_sfmStringMapObj = new List<SFM_WrapperDef.SFM_StringMap>();
        sfmStringMap_Obj1.key = 'PROCESSID' ;
        sfmStringMap_Obj1.value = SFMProcess.id;
        sfmStringMap_Obj2.key = 'ALIAS' ;
        //sfmStringMap_Obj2.value = 'WorkDetail';
        sfmStringMap_Obj2.value = pagelayout1.Id;
        sfmStringMap_Obj3.key = 'FIELDAPINAME' ;
        sfmStringMap_Obj3.value = 'SVMXC__Product__c';
        //sfmStringMap_Obj4.key = 'FIELDAPINAME' ;
        //sfmStringMap_Obj4.value = 'SVMXC__Product__c';
        sfmStringListMap_Obj1.key = 'RECORDID';
        list<String> strlst = new list<String>();
        strlst.add(pro.id);
        strlst.add(pro1.id);
        sfmStringListMap_Obj1.valueList = strlst;
        lst2_sfmStringMapObj.add(sfmStringMap_Obj1);
        lst2_sfmStringMapObj.add(sfmStringMap_Obj2);
        lst2_sfmStringMapObj.add(sfmStringMap_Obj3);
        lst1_sfmStringMapObj.add(sfmStringListMap_Obj1);
        SVMXC.SFM_WrapperDef.SFM_Request request = new SVMXC.SFM_WrapperDef.SFM_Request();
        if(request != null)
        {
            request.setstringMap(lst2_sfmStringMapObj); 
            request.setstringListMap(lst1_sfmStringMapObj);
        }
        //------------------------------------------------INSTANTIATING THE CLASS------------------------------------------------//
        SFM_addRecords sfmAddRec_Obj = new SFM_addRecords();
        //-------------------------------------------------CALLING THE METHOD---------------------------------------------------//
        test.starttest();
        List<SVMXC.SFM_WrapperDef.SFM_PageDataSet>  lst_wrapperSfmRec_Obj1 = sfmAddRec_Obj.getSFM_AddRecords(request);
        test.stoptest(); 
    }//method
}//class