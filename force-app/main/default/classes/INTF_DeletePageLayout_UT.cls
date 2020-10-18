@isTest
Private class INTF_DeletePageLayout_UT{
    static testMethod void INTF_DeletePageLayout_test(){ 
    
        //*****Variable declaration and data creation*****
        
        
        String val = 'true';
        List<String> List_value = new List<String>();
        
        List_value.add(val);
        SVMXC.INTF_WebServicesDef.INTF_StringListMap REC_stringlistmap = new SVMXC.INTF_WebServicesDef.INTF_StringListMap ('RECORDID',List_value);
        SVMXC.INTF_WebServicesDef.INTF_StringListMap Partial_stringlistmaps = new SVMXC.INTF_WebServicesDef.INTF_StringListMap ('PARTIALDELETE',List_value);
        
        
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
        
        INTF_deletePageLayout delPageLayout = new INTF_deletePageLayout();
        INTF_WebServicesDef.INTF_Request request = new INTF_WebServicesDef.INTF_Request();
        
        //*****creating the Lists*****
        
        
        List<SVMXC.INTF_WebServicesDef.INTF_StringListMap> List_stringlstmap = new List<SVMXC.INTF_WebServicesDef.INTF_StringListMap>();
        List_stringlstmap.add(REC_stringlistmap);
        List_stringlstmap.add(Partial_stringlistmaps);
        request.stringListMap = List_stringlstmap;
        
        List<String> StringLst = new List<String>();
        StringLst.add(page_layout.id);
        request.stringListMap[0].valueList = StringLst;
        
        System.debug('*****List_stringlstmap'+List_stringlstmap);
        
        //*****Calling method*****
        
        delPageLayout.INTF_DeletePageLayout(request);
    }
}