@isTest
Private class SFM_DeletePageLayout_UT{
    static testMethod void SFM_DeletePageLayout_test(){ 
    
        //*****Variable declaration and data creation*****
        
        
        String val = 'true';
        List<String> List_value = new List<String>();
        
        List_value.add(val);
        SVMXC.SFM_WrapperDef.SFM_StringListMap REC_stringlistmap = new SVMXC.SFM_WrapperDef.SFM_StringListMap ('RECORDID',List_value);
        SVMXC.SFM_WrapperDef.SFM_StringListMap Partial_stringlistmaps = new SVMXC.SFM_WrapperDef.SFM_StringListMap ('PARTIALDELETE',List_value);
        
        
        SVMXC__Page_Layout__c page_layout = new SVMXC__Page_Layout__c();
        page_layout.SVMXC__Object_Name__c='Case';
        page_layout.SVMXC__Page_Layout_ID__c='Case Layout';
        page_layout.SVMXC__IsStandard__c=true;
        insert page_layout;
        System.assertEquals(true, page_layout != null);
        
        System.debug('*****page_layout.Id'+page_layout.Id);
        
        SVMXC__Page_Layout_Detail__c  page_layout_detail = new SVMXC__Page_Layout_Detail__c ();
        
        page_layout_detail.SVMXC__Page_Layout__c =page_layout.Id;
        
        insert page_layout_detail;
        System.assertEquals(true, page_layout_detail != null);
        
        System.debug('*****page_layout_detail.Id'+page_layout_detail.Id);
        
        SVMXC__SFM_Event__c  page_event = new SVMXC__SFM_Event__c ();
        page_event.SVMXC__Page_Layout__c  = page_layout.Id;
        insert page_event;
        System.assertEquals(true, page_event != null);
        
        //*****Instance of classes
        
        SFM_deletePageLayout delPageLayout = new SFM_deletePageLayout();
        SFM_WrapperDef.SFM_Request request = new SFM_WrapperDef.SFM_Request();
        
        //*****creating the Lists*****
        
        
        List<SVMXC.SFM_WrapperDef.SFM_StringListMap> List_stringlstmap = new List<SVMXC.SFM_WrapperDef.SFM_StringListMap>();
        List_stringlstmap.add(REC_stringlistmap);
        List_stringlstmap.add(Partial_stringlistmaps);
        request.stringListMap = List_stringlstmap;
        
        List<String> StringLst = new List<String>();
        StringLst.add(page_layout.id);
        request.stringListMap[0].valueList = StringLst;
        
        SVMXC.SFM_WrapperDef.SFM_StringMap stringMap = new  SVMXC.SFM_WrapperDef.SFM_StringMap();
        stringMap.key='RECREATE';
        stringMap.value='true';
        request.stringMap.add(stringMap);
        
        System.debug('*****List_stringlstmap'+List_stringlstmap);
        
        //*****Calling method*****
        
        delPageLayout.SFM_DeletePageLayout(request);
    }
}