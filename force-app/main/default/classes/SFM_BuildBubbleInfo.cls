public with sharing class SFM_BuildBubbleInfo 
{
    public SFM_BuildBubbleInfo(){}
    
    public SVMXC.SFM_WrapperDef.SFM_BubbleWrapper getbubbleinfo(SFM_WrapperDef.SFM_Request prequest)
    {
        SVMXC.SFM_getLookUpConfigWithData GetLkD = new SVMXC.SFM_getLookUpConfigWithData();
        String strRecID = '';
        list<SVMXC.SFM_WrapperDef.SFM_StringMap> StrMapLst = new list<SVMXC.SFM_WrapperDef.SFM_StringMap>(); 
        SVMXC.SFM_WrapperDef.SFM_BubbleWrapper BubbleWrapper = new SVMXC.SFM_WrapperDef.SFM_BubbleWrapper();
        BubbleWrapper.response.success = true; //Added for the story BAC-4426
        list<SVMXC.SFM_WrapperDef.bubble_wp> BubbleWpList = new list<SVMXC.SFM_WrapperDef.bubble_wp>(); 
        SVMXC.SFM_WrapperDef.SFM_LookUpConfigData LookupConfigdata = new SVMXC.SFM_WrapperDef.SFM_LookUpConfigData();
        system.debug('prequest'+prequest);
        list<SVMXC.SFM_WrapperDef.SFM_StringMap> inputStrMapLst = new list<SVMXC.SFM_WrapperDef.SFM_StringMap>();
        inputStrMapLst = prequest.stringMap;
        if(inputStrMapLst.size() > 0)
        {
            for(SFM_WrapperDef.SFM_StringMap req: inputStrMapLst)
            {
                if(req.key.toUpperCase() == 'RECORDID')
                    strRecID = req.value;
            }       
        }
        list<SVMXC__ServiceMax_Processes__c> lstProcess = new list<SVMXC__ServiceMax_Processes__c>();
        if(strRecID != null && strRecID.length() > 0)
        {
            lstProcess = [select id from SVMXC__ServiceMax_Processes__c where id =: strRecID];//SDL-SVMX-FLS-NOT-ENFORCED-META-DATA
            //if comes from cache and not in database then throw error.
            if(lstProcess.size() == 0)
            {
                BubbleWrapper.response.message = system.label.SFM002_TAG057;
                BubbleWrapper.response.success = false;
                return BubbleWrapper;
            }
        }
        LookupConfigdata = GetLkD.getLookUpConfigWithData(prequest);
        system.debug('LookupConfigdata'+LookupConfigdata);
        if(LookupConfigdata.response.success = false)
        {
            BubbleWrapper.response = LookupConfigdata.response;
            BubbleWrapper.response.message = system.label.SFM002_TAG057;
            BubbleWrapper.response.success = false;
            return BubbleWrapper;
        }
        if(LookupConfigdata != null && LookupConfigdata.data != null && LookupConfigdata.data.size() > 0)
            BubbleWpList =  LookupConfigdata.data;
        system.debug('BubbleWpList'+BubbleWpList);
        if(BubbleWpList.size() > 0)
        {
            for(Integer i = 0;i<BubbleWpList.size();i++)
            {
                list<SVMXC.SFM_WrapperDef.SFM_StringFieldMap> StringFieldMap = new list<SVMXC.SFM_WrapperDef.SFM_StringFieldMap>(); 
                StringFieldMap = BubbleWpList[i].FieldMap;
                if(StringFieldMap.size() > 0)
                {
                    for(Integer j = 0;j< StringFieldMap.size();j++)
                    {
                        SVMXC.SFM_WrapperDef.SFM_StringMap strmap = new SVMXC.SFM_WrapperDef.SFM_StringMap();
                        strmap.key = StringFieldMap[j].key;
                        strmap.value = StringFieldMap[j].value;
                        StrMapLst.add(strmap);
                    }
                }       
            }
        }   
        system.debug('StrMapLst'+StrMapLst);    
        BubbleWrapper.bubbleinfo = StrMapLst;
        return BubbleWrapper;
    }
}