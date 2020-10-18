/* Security Scanned */
public with sharing class SFM_DeletePageLayout 
{
  //Method to return exemptions
    public class SVMXException extends Exception {}
    
    //Constructor
    public SFM_deletePageLayout(){}
    public SFM_WrapperDef.SFM_Response SFM_DeletePageLayout(SFM_WrapperDef.SFM_Request Prequest)
    {
        SVMXC.SFM_WrapperDef.SFM_Response response = new SVMXC.SFM_WrapperDef.SFM_Response();
        List<SVMXC.SFM_WrapperDef.SFM_StringListMap> stringlstmap = new List<SVMXC.SFM_WrapperDef.SFM_StringListMap>();
        List<String> StringLst = new List<String>();
        List<SVMXC.SFM_WrapperDef.SFM_StringMap> stringMap = new List<SVMXC.SFM_WrapperDef.SFM_StringMap>();
        map<String,SVMXC__Page_Layout__c> AllPageLayoutRecs = new map<string,SVMXC__Page_Layout__c>(); 
        map<String,SVMXC__Page_Layout_Detail__c> AllDetailRecs = new map<String,SVMXC__Page_Layout_Detail__c>();
        map<String,SVMXC__SFM_Event__c> AllEventRecs = new map<String,SVMXC__SFM_Event__c>();
        set<String> RecordIds = new set<String>();
        set<String> HdrLayoutId = new set<String>(); 
        set<String> AllPageLayoutId = new set<String>(); 
        set<String> SectionId = new set<String>(); 
        set<String> AllDetailId = new set<String>(); 
        stringlstmap = Prequest.stringListMap;  
        stringMap = Prequest.stringMap;
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
        try
        {
            sp = Database.setSavepoint();
      List<SVMXC__Page_Layout__c> DeletePageLayoutRecs = new List<SVMXC__Page_Layout__c>(); 
            List<SVMXC__Page_Layout_Detail__c> DeleteDetailRecs = new List<SVMXC__Page_Layout_Detail__c>();
            List<SVMXC__SFM_Event__c> DeleteEventRecs = new List<SVMXC__SFM_Event__c>();
            //first delete events...
            if(AllEventRecs.size()>0)
            { 
                DeleteEventRecs = AllEventRecs.values();
                if(DeleteEventRecs.size() > 0)
                    //SDL-SVMX-FLS-NOT-ENFORCED-META-DATA
                    delete DeleteEventRecs;
            }   
            if(AllDetailRecs.size()>0)
            {
                 DeleteDetailRecs =  AllDetailRecs.values();
                 if(DeleteDetailRecs.size() > 0)
                     //SDL-SVMX-FLS-NOT-ENFORCED-META-DATA
                     delete DeleteDetailRecs;
            }
            Boolean isRecreate = false;
            String recreateVaule = '';
            //defect PQT BAC-2879 fixed 
          if(stringMap !=null && stringMap.size() > 0)
          {
              for(Integer i = 0;i<stringMap.size();i++)
              {
                  if(stringMap[i].key.touppercase() == 'RECREATE')
                  {   
                      isRecreate = Boolean.valueOf(stringMap[i].value);
                  }   
              }
          }
               
            if(isRecreate) {
                if(AllPageLayoutRecs.size()>0)
                {
                  system.debug('Entered Recreate : '+ AllPageLayoutRecs.size());
                    DeletePageLayoutRecs = AllPageLayoutRecs.values();
                    if(DeletePageLayoutRecs.size() > 0)
                        //SDL-SVMX-FLS-NOT-ENFORCED-META-DATA
                        delete DeletePageLayoutRecs;
                    response.success = true;
                        
                    system.debug('Successfull deleted the pagelayout and all page layout records.');    
                }
        } else {            
              if(PartialDelete.length() == 0)
              {
                  system.debug('entered');
                  // Integrity check, if the page is associated to any process this will throw exception
                  //SDL-SVMX-FLS-NOT-ENFORCED-META-DATA
              List<SVMXC__ServiceMax_Processes__c> processNodeObject = [Select Id, SVMXC__Module__c From SVMXC__ServiceMax_Processes__c 
                          where Recordtype.Name='Target Manager' AND SVMXC__Page_Layout__c IN :RecordIds];
            if(processNodeObject.size() > 0)
            {
              //throw new SVMXException(system.label.SFM001_TAG145);
              Database.rollback(sp);
                  response.success = false;
                  response.message = system.label.SFM001_TAG145;
            }  
            else
            {
                    if(AllPageLayoutRecs.size()>0)
                    {
                        DeletePageLayoutRecs = AllPageLayoutRecs.values();
                        if(DeletePageLayoutRecs.size() > 0)
                            //SDL-SVMX-FLS-NOT-ENFORCED-META-DATA
                            delete DeletePageLayoutRecs;
                    }
            }         
              }
            }
                
        }
        catch(SVMXException ex){
            Database.rollback(sp);
            response.success = false;
            response.message = ex.getmessage();
        }
        catch(exception ex){
            Database.rollback(sp);
            response.success = false;
            response.message = 'Record Not Deleted' + ex.getmessage() ;
        } 
        return response;
    }
}