/* Security Scanned */
public with sharing class SFM_GetListOfPageLayout 
{
    public SFM_WrapperDef.SFM_Response_PageList getListOfPageLayout(SFM_WrapperDef.SFM_Request_PageList PmaxReqPageLst)
    {
        SVMXC.SFM_WrapperDef.SFM_Response_PageList PageResponse = new SVMXC.SFM_WrapperDef.SFM_Response_PageList();
        try
        {
            List<SVMXC.SFM_WrapperDef.SFM_StringListMap> StringListMap = new List<SVMXC.SFM_WrapperDef.SFM_StringListMap>(); 
            List<SVMXC__Page_Layout__c> pagelayoutlst = new List<SVMXC__Page_Layout__c>();
            if(PmaxReqPageLst.request != null) 
                StringListMap = PmaxReqPageLst.request.stringListMap;
            system.debug('StringListMap'+StringListMap);
            String HdrObjectAPIName = '';
            List<String> DetailObjectAPINameLst = new List<String>();
            List<String> DetailObject = new List<String>();
            Set<String> DetailObjectSet = new Set<String>(); 
            if(StringListMap.size() > 0)
            {
                for(Integer i=0;i<StringListMap.size();i++)
                {
                    if(StringListMap[i].key.toUpperCase() == 'TARGET')
                    {
                        HdrObjectAPIName = StringListMap[i].valueList[0];
                    }
                    if(StringListMap[i].key.toUpperCase() == 'TARGETCHILD')
                    {
                        if(StringListMap[i].valueList != null)
                            DetailObjectAPINameLst = StringListMap[i].valueList;
                    }
                }
            }
            system.debug('HdrObjectAPIName'+HdrObjectAPIName);
            //system.debug('DetailObjectAPINameLst'+DetailObjectAPINameLst.size()+DetailObjectAPINameLst);
            if(DetailObjectAPINameLst.size() > 0)
            {
                for(Integer i= 0;i<DetailObjectAPINameLst.size();i++)
                {
                    DetailObject.add(DetailObjectAPINameLst[i]);
                    DetailObjectSet.add(DetailObjectAPINameLst[i]);
                }
            }
            system.debug('DetailObject'+DetailObject.size()+DetailObject);
            system.debug('DetailObjectSet'+DetailObjectSet.size()+DetailObjectSet);
            if(HdrObjectAPIName != null && HdrObjectAPIName.length() > 0 && DetailObject.size() == 0)
            {
                system.debug('Entered hear');
                map<String,List<string>> finalmap = new map<String,List<string>>();
                map<String,SVMXC__Page_Layout__c> hdrlayoutmap = new map<String,SVMXC__Page_Layout__c>();
                set<String> HeaderID = new set<String>(); 
                List<SVMXC__Page_Layout__c> hdrtempList = new List<SVMXC__Page_Layout__c>();
                List<SVMXC__Page_Layout__c> dtltempList = new List<SVMXC__Page_Layout__c>(); 
                
                hdrtempList = [Select SystemModstamp, SVMXC__Type__c,SVMXC__Name__c,SVMXC__Sequence__c, SVMXC__Page_Layout_ID__c, SVMXC__Page_Help__c, SVMXC__Object_Name__c, SVMXC__IsStandard__c, SVMXC__Help_URL__c, SVMXC__Header_Page_Layout__c,   SVMXC__Allow_Delete_Lines__c,  OwnerId, Name, LastModifiedDate, LastModifiedById,  IsDeleted, Id, CreatedDate, CreatedById From SVMXC__Page_Layout__c where SVMXC__Object_Name__c =: HdrObjectAPIName and SVMXC__Type__c = 'Header']; //SDL-SVMX-FLS-NOT-ENFORCED-META-DATA
                system.debug('hdrtempList'+hdrtempList.size()+hdrtempList);
                if(hdrtempList.size() > 0)
                {
                    for(SVMXC__Page_Layout__c PL : hdrtempList)
                    {
                        HeaderID.add(PL.id);
                        hdrlayoutmap.put(PL.id,PL);
                    }
                }
                
                dtltempList = [Select SystemModstamp, SVMXC__Type__c,SVMXC__Name__c, SVMXC__Sequence__c, SVMXC__Page_Layout_ID__c, SVMXC__Page_Help__c, SVMXC__Object_Name__c, SVMXC__IsStandard__c, SVMXC__Help_URL__c, SVMXC__Header_Page_Layout__c,   SVMXC__Allow_Delete_Lines__c,  OwnerId, Name, LastModifiedDate, LastModifiedById,  IsDeleted, Id, CreatedDate, CreatedById From SVMXC__Page_Layout__c where SVMXC__Header_Page_Layout__c IN : HeaderID]; //SDL-SVMX-FLS-NOT-ENFORCED-META-DATA
                system.debug('dtltempList'+dtltempList.size()+dtltempList);
                if(dtltempList.size() == 0)
                {
                    PageResponse.PageList = hdrtempList;
                }
                if(hdrlayoutmap.size() > 0 && dtltempList.size() > 0)
                {
                    for(String s: hdrlayoutmap.keyset())
                    {
                        List<string> temp = new List<string>();
                        for(SVMXC__Page_Layout__c PL : dtltempList)
                        {
                            if( s == PL.SVMXC__Header_Page_Layout__c)
                            {
                                temp.add(PL.SVMXC__Object_Name__c);
                            }
                        }
                        system.debug('temp'+temp.size()+temp);
                        finalmap.put(s,temp);
                    }
                }
                system.debug('finalmap'+finalmap);
                if(finalmap.size() > 0)
                {
                    for(String s : finalmap.keyset())
                    {
                        List<string> temp = new List<string>();
                        temp = finalmap.get(s);
                        if(DetailObject.size() == temp.size())
                        {
                            pagelayoutlst.add(hdrlayoutmap.get(s));
                        }
                    }
                }
                if(pagelayoutlst.size() > 0)
                {
                    PageResponse.PageList = pagelayoutlst;
                }
            }
            if(HdrObjectAPIName != null && HdrObjectAPIName.length() > 0 && DetailObject.size() > 0)
            {
                map<ID,SVMXC__Page_Layout__c> mapHeaderLayout = new map<ID,SVMXC__Page_Layout__c>();
                list<SVMXC__Page_Layout__c> lstDetailLayout = new list<SVMXC__Page_Layout__c>(); 
                map<ID,list<String>> mapPagelayoutIDDetilObjects = new map<ID,list<String>>(); 
                
                mapHeaderLayout.putall([Select SystemModstamp, SVMXC__Type__c,SVMXC__Name__c,SVMXC__Sequence__c, SVMXC__Page_Layout_ID__c, SVMXC__Page_Help__c, SVMXC__Object_Name__c, SVMXC__IsStandard__c, SVMXC__Help_URL__c, SVMXC__Header_Page_Layout__c,   SVMXC__Allow_Delete_Lines__c,  OwnerId, Name, LastModifiedDate, LastModifiedById,  IsDeleted, Id, CreatedDate, CreatedById From SVMXC__Page_Layout__c where SVMXC__Object_Name__c =: HdrObjectAPIName and SVMXC__Type__c = 'Header']); //SDL-SVMX-FLS-NOT-ENFORCED-META-DATA
                if(mapHeaderLayout.size() > 0){
                    
                  lstDetailLayout = [Select SystemModstamp, SVMXC__Type__c,SVMXC__Name__c, SVMXC__Sequence__c, SVMXC__Page_Layout_ID__c, SVMXC__Page_Help__c, SVMXC__Object_Name__c, SVMXC__IsStandard__c, SVMXC__Help_URL__c, SVMXC__Header_Page_Layout__c,   SVMXC__Allow_Delete_Lines__c,  OwnerId, Name, LastModifiedDate, LastModifiedById,  IsDeleted, Id, CreatedDate, CreatedById From SVMXC__Page_Layout__c where SVMXC__Header_Page_Layout__c IN : mapHeaderLayout.keyset() and SVMXC__Type__c = 'Detail' ];//and SVMXC__Object_Name__c IN : DetailObjectSet //SDL-SVMX-FLS-NOT-ENFORCED-META-DATA
                
                }
                system.debug('lstDetailLayout'+lstDetailLayout.size()+lstDetailLayout);
                if(lstDetailLayout.size() > 0){
                  for(SVMXC__Page_Layout__c detail : lstDetailLayout){
                    if(mapHeaderLayout.containskey(detail.SVMXC__Header_Page_Layout__c)){
                      if(mapPagelayoutIDDetilObjects.containskey(detail.SVMXC__Header_Page_Layout__c)){
                        mapPagelayoutIDDetilObjects.get(detail.SVMXC__Header_Page_Layout__c).add(detail.SVMXC__Object_Name__c);
                      }
                      else{
                        mapPagelayoutIDDetilObjects.put(detail.SVMXC__Header_Page_Layout__c,new list<String>());
                        mapPagelayoutIDDetilObjects.get(detail.SVMXC__Header_Page_Layout__c).add(detail.SVMXC__Object_Name__c);
                      }
                      
                    }
                  }
                }
                system.debug('mapPagelayoutIDDetilObjects'+mapPagelayoutIDDetilObjects.size()+mapPagelayoutIDDetilObjects);
                if(mapPagelayoutIDDetilObjects.size() > 0){
                    for(String s : mapPagelayoutIDDetilObjects.keyset()){
                        list<String> lstTemp = new list<String>();
                        lstTemp = mapPagelayoutIDDetilObjects.get(s);
                        if(DetailObject.size() == lstTemp.size()){
                            pagelayoutlst.add(mapHeaderLayout.get(s));
                        }
                    }
                }
            }
            system.debug('pagelayoutlst'+pagelayoutlst.size()+pagelayoutlst);
            if(pagelayoutlst.size() > 0){
                PageResponse.PageList = pagelayoutlst;
            }
                
        }
        catch(Exception ex)
        {
            PageResponse.response.success = false;
            PageResponse.response.message = 'Error'+ex.getmessage();
        }
        return PageResponse;    
    }


    public List<SFM_WrapperDef2.SFM2_ListViewDetails> getListOfPageLayout_V2(List<SFM_WrapperDef2.SFM2_ObjectInfo> layoutObjects){
        
        List<SVMXC__Page_Layout__c> layoutRecordsList = new List<SVMXC__Page_Layout__c>() ;
        List<SFM_WrapperDef2.SFM2_ListViewDetails> listViewDetails = new List<SFM_WrapperDef2.SFM2_ListViewDetails>();
        String parentObject;
        Map<String,String> objectAliasMap = new Map<String,String>();
        
        for(SFM_WrapperDef2.SFM2_ObjectInfo layoutObjectInfo : layoutObjects){
            if (layoutObjectInfo.objectType.equalsIgnoreCase('HEADER')){
                parentObject = layoutObjectInfo.apiName;
            } else {
                objectAliasMap.put(layoutObjectInfo.objectAlias, layoutObjectInfo.apiName);
            }   
        }

        List<String> tempObjectsList;
        Set<Id> qualifiedLayoutIds = new Set<Id>();

        if(!COMM_SecurityUtils.getInstance().verifyFieldAccess('SVMXC__Page_Layout__c', new List<String>{'Id', 'SVMXC__IsStandard__c', 'SVMXC__SM_Description__c', 'SVMXC__Name__c', 'SVMXC__Page_Layout_ID__c', 'SVMXC__Object_Name__c', 'LastModifiedDate', 'CreatedDate', 'CreatedBy.Name', 'LastModifiedBy.Name'}, COMM_SecurityUtils.Access.Accessible)){
            throw new COMM_SecurityUtils.SecurityAccessException( System.Label.COMM001_TAG142 );
        }

        for(SVMXC__Page_Layout__c layoutRecord : [SELECT Id, SVMXC__IsStandard__c, SVMXC__SM_Description__c, SVMXC__Name__c, SVMXC__Page_Layout_ID__c, LastModifiedDate, CreatedDate, CreatedBy.Name, LastModifiedBy.Name,
                                                     (SELECT Id, SVMXC__Object_Name__c, SVMXC__Page_Layout_ID__c FROM SVMXC__Page_Layouts__r) FROM SVMXC__Page_Layout__c 
                                                     WHERE SVMXC__Object_Name__c =: parentObject AND SVMXC__Type__c ='HEADER']){
            
            tempObjectsList = new List<String>();
            tempObjectsList.addAll(objectAliasMap.values());

            boolean hasAll = true;

            if( objectAliasMap.size() != layoutRecord.SVMXC__Page_Layouts__r.size()){ 
                hasAll = false;
                continue;
            }

            for(SVMXC__Page_Layout__c sectionRecord : layoutRecord.SVMXC__Page_Layouts__r){
                
                if(!objectAliasMap.keySet().contains(sectionRecord.SVMXC__Page_Layout_ID__c)){ //sectionRecord.SVMXC__Object_Name__c
                    hasAll = false;
                    continue;
                }else{
                    Integer i = tempObjectsList.indexOf(sectionRecord.SVMXC__Object_Name__c);
                    
                    if(i != -1)
                       tempObjectsList.remove(i); 
                }
            }

            if(tempObjectsList.isEmpty() && hasAll){
                layoutRecordsList.add(layoutRecord);
                qualifiedLayoutIds.add(layoutRecord.Id);
            }
        }

        if(!layoutRecordsList.isEmpty()){
            
            Set<Id> dependentProcessIds = SFM_GetEntityDependencies.entityDependencyCheck(qualifiedLayoutIds, SFM_DesignerUtils.entity_layout);
            for(SVMXC__Page_Layout__c layoutRecord : layoutRecordsList){
                SFM_WrapperDef2.SFM2_ListViewDetails listItem = new SFM_WrapperDef2.SFM2_ListViewDetails();

                SFM_WrapperDef2.SFM2_EntityDetail entityDetail = new SFM_WrapperDef2.SFM2_EntityDetail();
                
                entityDetail.entityId = layoutRecord.id;
                entityDetail.isStandard = layoutRecord.SVMXC__IsStandard__c;
                entityDetail.entityDescription = layoutRecord.SVMXC__SM_Description__c;
                entityDetail.entityName = layoutRecord.SVMXC__Name__c;
                entityDetail.lastModifiedDate = String.valueOfGmt(layoutRecord.LastModifiedDate);
                entityDetail.createdDate = String.valueOfGmt(layoutRecord.CreatedDate);
                entityDetail.createdBy = layoutRecord.CreatedBy.Name;
                entityDetail.lastModifiedBy = layoutRecord.LastModifiedBy.Name;
                listItem.entityDetail = entityDetail;
                if(dependentProcessIds.contains(layoutRecord.Id)){
                    listItem.dependencyExist = true;
                }
                listViewDetails.add(listItem);
            }
        }

        return listViewDetails;
    }
}