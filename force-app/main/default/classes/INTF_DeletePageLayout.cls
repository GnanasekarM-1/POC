public with sharing class INTF_DeletePageLayout 
{
//Constructor
    public INTF_deletePageLayout(){}
    public INTF_WebServicesDef.INTF_Response INTF_DeletePageLayout(INTF_WebServicesDef.INTF_Request Prequest)
    {
        SVMXC.INTF_WebServicesDef.INTF_Response response = new SVMXC.INTF_WebServicesDef.INTF_Response();
        List<SVMXC.INTF_WebServicesDef.INTF_StringListMap> stringlstmap = new List<SVMXC.INTF_WebServicesDef.INTF_StringListMap>();
        List<String> StringLst = new List<String>();
        map<String,SVMXC__Page_Layout__c> AllPageLayoutRecs = new map<string,SVMXC__Page_Layout__c>(); 
        map<String,SVMXC__Page_Layout_Detail__c> AllDetailRecs = new map<String,SVMXC__Page_Layout_Detail__c>();
        map<String,SVMXC__SFM_Event__c> AllEventRecs = new map<String,SVMXC__SFM_Event__c>();
        set<String> RecordIds = new set<String>();
        set<String> HdrLayoutId = new set<String>(); 
        set<String> AllPageLayoutId = new set<String>(); 
        set<String> SectionId = new set<String>(); 
        set<String> AllDetailId = new set<String>(); 
        stringlstmap = Prequest.stringListMap;  
        system.debug('stringlstmap'+stringlstmap);
        string PartialDelete = '';
        if(stringlstmap.size() > 0)
        {
            for(Integer i = 0;i<stringlstmap.size();i++)
            {
                if(stringlstmap[i].key.touppercase() == 'RECORDID')
                {
                    StringLst = stringlstmap[i].valueList;
                }
                if(stringlstmap[i].key.touppercase() == 'PARTIALDELETE')
                {
                    PartialDelete = stringlstmap[i].key.touppercase();
                }
            }
        }
        system.debug('PartialDelete'+PartialDelete.length()+PartialDelete);
        if(StringLst.size() > 0)
        {
            for(Integer i = 0;i<StringLst.size();i++)
            {
                RecordIds.add(StringLst[i]);
            }
        }
        system.debug('RecordIds'+RecordIds);
        //Get the header layout 
        if(RecordIds.size() > 0)
        {
            AllPageLayoutRecs.putall([Select id From SVMXC__Page_Layout__c where Id IN : RecordIds]);
        }
        system.debug('AllPageLayoutRecs'+AllPageLayoutRecs.size()+AllPageLayoutRecs);
        if(AllPageLayoutRecs.size() > 0)
        {
            for(String s : AllPageLayoutRecs.keyset())
            {
                if(s != null)
                    HdrLayoutId.add(AllPageLayoutRecs.get(s).id);
            }
        }
        system.debug('HdrLayoutId'+HdrLayoutId);
        //Get the detail layout 
        if(HdrLayoutId.size() > 0)
        {
            AllPageLayoutRecs.putall([Select id,SVMXC__Header_Page_Layout__c From SVMXC__Page_Layout__c where SVMXC__Header_Page_Layout__c IN : HdrLayoutId]);
        }
        system.debug('AllPageLayoutRecs'+AllPageLayoutRecs.size()+AllPageLayoutRecs);
        if(AllPageLayoutRecs.size() > 0)
        {
            for(String s : AllPageLayoutRecs.keyset())
            {
                if(s != null)
                    AllPageLayoutId.add(s);
            }
        }
        system.debug('AllPageLayoutId'+AllPageLayoutId.size()+AllPageLayoutId);
        //Get all the section as well as the fiels of detail layout
        if(AllPageLayoutId.size() > 0)
        {
            AllDetailRecs.putall([Select id,SVMXC__Page_Layout__c From SVMXC__Page_Layout_Detail__c where SVMXC__Page_Layout__c IN : AllPageLayoutId]);
        }
        system.debug('AllDetailRecs'+AllDetailRecs.size()+AllDetailRecs);
        if(AllDetailRecs.size() > 0)
        {
            for(String s: AllDetailRecs.keyset())
            {
                if(s != null)
                    SectionId.add(s);
            }
        }//Get all the fields of the sections for the header layout 
        if(SectionId.size() > 0)
        {
            AllDetailRecs.putall([Select id,SVMXC__Section__c From SVMXC__Page_Layout_Detail__c where SVMXC__Section__c IN : SectionId]);
        }
        system.debug('AllDetailRecs'+AllDetailRecs.size()+AllDetailRecs);
        if(AllDetailRecs.size() != null)
        {
            for(String s : AllDetailRecs.keyset())
            {
                if(s != null)
                    AllDetailId.add(s);
            }
        }
        //Get the events associated with  SVMXC__Page_Layout_Detail__c object 
        if(AllDetailId.size() > 0 )
        {
            AllEventRecs.putall([Select id,SVMXC__Page_Layout_Detail__c From SVMXC__SFM_Event__c where SVMXC__Page_Layout_Detail__c IN : AllDetailId]);
        }
        system.debug('AllEventRecs'+AllEventRecs.size()+AllEventRecs);
        //Get the events associated with  SVMXC__Page_Layout__c object 
        if(AllPageLayoutId.size() > 0 )
        {
            AllEventRecs.putall([Select id,SVMXC__Page_Layout__c From SVMXC__SFM_Event__c where SVMXC__Page_Layout__c IN : AllPageLayoutId]);
        }
        system.debug('AllEventRecs'+AllEventRecs.size()+AllEventRecs);
        Savepoint sp;
        //try
        //{
            sp = Database.setSavepoint();
            List<SVMXC__Page_Layout__c> DeletePageLayoutRecs = new List<SVMXC__Page_Layout__c>(); 
            List<SVMXC__Page_Layout_Detail__c> DeleteDetailRecs = new List<SVMXC__Page_Layout_Detail__c>();
            List<SVMXC__SFM_Event__c> DeleteEventRecs = new List<SVMXC__SFM_Event__c>();
            //first delete events...
            if(AllEventRecs.size()>0)
            { 
                DeleteEventRecs = AllEventRecs.values();
                if(DeleteEventRecs.size() > 0){
                    if(COMM_SecurityUtils.getInstance().isDeletableObject('SVMXC__SFM_Event__c')){   //SDL-SVMX-DELETE-FLS-ENFORCED
                        delete DeleteEventRecs;
                    }
                }
            }   
            if(AllDetailRecs.size()>0)
            {
                 DeleteDetailRecs =  AllDetailRecs.values();
                 if(DeleteDetailRecs.size() > 0)
                     delete DeleteDetailRecs;   //SDL-SVMX-FLS-NOT-ENFORCED-META-DATA
            }   
            if(PartialDelete.length() == 0)
            {
                system.debug('entered');
                if(AllPageLayoutRecs.size()>0)
                {
                    DeletePageLayoutRecs = AllPageLayoutRecs.values();
                    if(DeletePageLayoutRecs.size() > 0)
                        delete DeletePageLayoutRecs;   //SDL-SVMX-FLS-NOT-ENFORCED-META-DATA
                }    
            }
                
        //}
        /*catch(exception ex){
            Database.rollback(sp);
            response.success = false;
            response.message = 'Record Not Deleted' + ex.getmessage() ;
        }*/ 
        return response;
    }
}