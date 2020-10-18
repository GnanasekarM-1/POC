public with sharing class SFM_Designer
{ 
    public Boolean isUsageTrackingAllowed{get;set;}
    public Boolean isSandbox {
        get{
            if(isSandbox == null)
                return [SELECT isSandbox FROM Organization].isSandbox;
            else 
                return isSandbox;     
        }
    }
    public SFM_Designer() {
          
        COMM_Utils_ManageSettings commSettings = new COMM_Utils_ManageSettings();
        Map<String,String> usageTrackingSettings = commSettings.SVMX_getSettingList(SFM_DesignerUtils.USAGE_TRACKING_SETTINGS, SFM_DesignerUtils.SETTING_USAGE_TRACKING_ALLOW );
        String isAllow = usageTrackingSettings.get(SFM_DesignerUtils.SETTING_USAGE_TRACKING_ALLOW);
        isUsageTrackingAllowed = ('Allow').equalsIgnoreCase( isAllow ) ? true : false;
    }

    @RemoteAction
    public static Object JSRGetDisplayTags(String requestStr){
        
        SVMXC.SFM_WrapperDef2.SFM2_Request deserializedRequest = (SVMXC.SFM_WrapperDef2.SFM2_Request)
                    JSON.deserialize(requestStr, SVMXC.SFM_WrapperDef2.SFM2_Request.class);          
        return JSON.serialize(new SVMXC.SFMDesigner2ServiceImpl().getDisplayTags(deserializedRequest));
    }
    
    @RemoteAction
    public static Object JSRGetListOfProcesses(String requestStr){        
             
        SVMXC.SFM_WrapperDef2.SFM2_Request deserializedRequest = (SVMXC.SFM_WrapperDef2.SFM2_Request)
                    JSON.deserialize(requestStr, SVMXC.SFM_WrapperDef2.SFM2_Request.class);          
        return JSON.serialize(new SVMXC.SFMDesigner2ServiceImpl().getListOfProcesses(deserializedRequest));   
    }
    
    @RemoteAction
    public static Object JSRGetUserInfo(String requestStr){        
                   
        SVMXC.SFM_WrapperDef2.SFM2_Request deserializedRequest = (SVMXC.SFM_WrapperDef2.SFM2_Request)
                    JSON.deserialize(requestStr, SVMXC.SFM_WrapperDef2.SFM2_Request.class);          
        return JSON.serialize(new SVMXC.SFMDesigner2ServiceImpl().getUserInfo(deserializedRequest));       
    }
    
    @RemoteAction
    public static Object JSRGetSettingInfo(String requestStr){
        SVMXC.SFM_WrapperDef2.SFM2_Request deserializedRequest = (SVMXC.SFM_WrapperDef2.SFM2_Request)
                    JSON.deserialize(requestStr, SVMXC.SFM_WrapperDef2.SFM2_Request.class);
        return JSON.serialize(new SVMXC.SFMDesigner2ServiceImpl().getSettingInfo(deserializedRequest));
    }
    @RemoteAction
    public static Object JSRGetWhereUsedInfo(String requestStr){
                         
        SVMXC.SFM_WrapperDef2.SFM2_Request deserializedRequest = (SVMXC.SFM_WrapperDef2.SFM2_Request)
                    JSON.deserialize(requestStr, SVMXC.SFM_WrapperDef2.SFM2_Request.class);          
        return JSON.serialize(new SVMXC.SFMDesigner2ServiceImpl().getWhereUsedInfo(deserializedRequest));       
    } 
    
    @RemoteAction
    public static Object JSRGetSFMTagsList(String requestStr){        
                         
        SVMXC.SFM_WrapperDef2.SFM2_Request deserializedRequest = (SVMXC.SFM_WrapperDef2.SFM2_Request)
                    JSON.deserialize(requestStr, SVMXC.SFM_WrapperDef2.SFM2_Request.class);          
        return JSON.serialize(new SVMXC.SFMDesigner2ServiceImpl().getSFMTagsList(deserializedRequest));       
    }    

    @RemoteAction
    public static Object JSRCloneProcess(String requestStr){        
                         
        SVMXC.SFM_WrapperDef2.SFM2_Request deserializedRequest = (SVMXC.SFM_WrapperDef2.SFM2_Request)
                    JSON.deserialize(requestStr, SVMXC.SFM_WrapperDef2.SFM2_Request.class);          
        return JSON.serialize(new SVMXC.SFMDesigner2ServiceImpl().cloneSFMProcess(deserializedRequest));       
    }   
    

    @RemoteAction
    public static Object JSRGetsObjects(String requestStr){        
                         
        SVMXC.SFM_WrapperDef2.SFM2_Request deserializedRequest = (SVMXC.SFM_WrapperDef2.SFM2_Request)
                    JSON.deserialize(requestStr, SVMXC.SFM_WrapperDef2.SFM2_Request.class);          
        return JSON.serialize(new SVMXC.SFMDesigner2ServiceImpl().getUserPermittedObjects(deserializedRequest));       
    }   
    
    @RemoteAction
    public static Object JSRGetsObjectFields(String requestStr){        
                         
        SVMXC.SFM_WrapperDef2.SFM2_Request deserializedRequest = (SVMXC.SFM_WrapperDef2.SFM2_Request)
                    JSON.deserialize(requestStr, SVMXC.SFM_WrapperDef2.SFM2_Request.class);          
        return JSON.serialize(new SVMXC.SFMDesigner2ServiceImpl().getsObjectFields(deserializedRequest));       
    }      
    
    @RemoteAction
    public static Object JSRGetPropertyElements(String requestStr){        
                         
        SVMXC.SFM_WrapperDef2.SFM2_Request deserializedRequest = (SVMXC.SFM_WrapperDef2.SFM2_Request)
                    JSON.deserialize(requestStr, SVMXC.SFM_WrapperDef2.SFM2_Request.class);          
        return JSON.serialize(new SVMXC.SFMDesigner2ServiceImpl().getAllPropertyElements(deserializedRequest));       
    }  
    
    @RemoteAction
    public static Object JSRGetListOfRules(String requestStr){        
                         
        SVMXC.SFM_WrapperDef2.SFM2_Request deserializedRequest = (SVMXC.SFM_WrapperDef2.SFM2_Request)
                    JSON.deserialize(requestStr, SVMXC.SFM_WrapperDef2.SFM2_Request.class);          
        return JSON.serialize(new SVMXC.SFMDesigner2ServiceImpl().getListOfRules(deserializedRequest));       
    }  

    @RemoteAction
    public static Object JSRRemoveEntities(String requestStr){        
                         
        SVMXC.SFM_WrapperDef2.SFM2_Request deserializedRequest = (SVMXC.SFM_WrapperDef2.SFM2_Request)
                    JSON.deserialize(requestStr, SVMXC.SFM_WrapperDef2.SFM2_Request.class);          
        return JSON.serialize(new SVMXC.SFMDesigner2ServiceImpl().deleteEntites(deserializedRequest));       
    }  
    
    @RemoteAction
    public static Object JSRCloneRule(String requestStr){        
                         
        SVMXC.SFM_WrapperDef2.SFM2_Request deserializedRequest = (SVMXC.SFM_WrapperDef2.SFM2_Request)
                    JSON.deserialize(requestStr, SVMXC.SFM_WrapperDef2.SFM2_Request.class);          
        return JSON.serialize(new SVMXC.SFMDesigner2ServiceImpl().cloneRule(deserializedRequest));       
    }     

    @RemoteAction
    public static Object JSRSaveRule(String requestStr){        
                         
        SVMXC.SFM_WrapperDef2.SFM2_Request deserializedRequest = (SVMXC.SFM_WrapperDef2.SFM2_Request)
                    JSON.deserialize(requestStr, SVMXC.SFM_WrapperDef2.SFM2_Request.class);          
        return JSON.serialize(new SVMXC.SFMDesigner2ServiceImpl().saveRule(deserializedRequest));       
    }       

    @RemoteAction
    public static Object JSRGetOperators(String requestStr){        
                         
        SVMXC.SFM_WrapperDef2.SFM2_Request deserializedRequest = (SVMXC.SFM_WrapperDef2.SFM2_Request)
                    JSON.deserialize(requestStr, SVMXC.SFM_WrapperDef2.SFM2_Request.class);          
        return JSON.serialize(new SVMXC.SFMDesigner2ServiceImpl().getOperators(deserializedRequest));       
    }
    
    @RemoteAction
    public static Object JSRGetLookupRecords(String requestStr){        
                         
        SVMXC.SFM_WrapperDef2.SFM2_Request deserializedRequest = (SVMXC.SFM_WrapperDef2.SFM2_Request)
                    JSON.deserialize(requestStr, SVMXC.SFM_WrapperDef2.SFM2_Request.class);          
        return JSON.serialize(new SVMXC.SFMDesigner2ServiceImpl().getLookupRecords(deserializedRequest));       
    }   

    @RemoteAction
    public static Object JSRCheckDuplicateName(String requestStr){        
                         
        SVMXC.SFM_WrapperDef2.SFM2_Request deserializedRequest = (SVMXC.SFM_WrapperDef2.SFM2_Request)
                    JSON.deserialize(requestStr, SVMXC.SFM_WrapperDef2.SFM2_Request.class);          
        return JSON.serialize(new SVMXC.SFMDesigner2ServiceImpl().checkDuplicateName(deserializedRequest));       
    }   

    @RemoteAction
    public static Object JSRSaveProcess(String requestStr){        
                         
        SVMXC.SFM_WrapperDef2.SFM2_Request deserializedRequest = (SVMXC.SFM_WrapperDef2.SFM2_Request)
                    JSON.deserialize(requestStr, SVMXC.SFM_WrapperDef2.SFM2_Request.class);          
        return JSON.serialize(new SVMXC.SFMDesigner2ServiceImpl().saveSFMProcess(deserializedRequest));       
    }  
    
    @RemoteAction
    public static Object JSRGetLayouts(String requestStr){        
                         
        SVMXC.SFM_WrapperDef2.SFM2_Request deserializedRequest = (SVMXC.SFM_WrapperDef2.SFM2_Request)
                    JSON.deserialize(requestStr, SVMXC.SFM_WrapperDef2.SFM2_Request.class);          
        return JSON.serialize(new SVMXC.SFMDesigner2ServiceImpl().getListOfLayouts(deserializedRequest));       
    }  
    
    @RemoteAction
    public static Object JSRGetRelatedObjects(String requestStr){        
                         
        SVMXC.SFM_WrapperDef2.SFM2_Request deserializedRequest = (SVMXC.SFM_WrapperDef2.SFM2_Request)
                    JSON.deserialize(requestStr, SVMXC.SFM_WrapperDef2.SFM2_Request.class);          
        return JSON.serialize(new SVMXC.SFMDesigner2ServiceImpl().getRelatedObjects(deserializedRequest));       
    }  
    
    @RemoteAction
    public static Object JSRCloneLayout(String requestStr){        
                         
        SVMXC.SFM_WrapperDef2.SFM2_Request deserializedRequest = (SVMXC.SFM_WrapperDef2.SFM2_Request)
                    JSON.deserialize(requestStr, SVMXC.SFM_WrapperDef2.SFM2_Request.class);          
        return JSON.serialize(new SVMXC.SFMDesigner2ServiceImpl().cloneLayout(deserializedRequest));       
    }  
    
    @RemoteAction
    public static Object JSRGetFieldSets(String requestStr){        
                         
        SVMXC.SFM_WrapperDef2.SFM2_Request deserializedRequest = (SVMXC.SFM_WrapperDef2.SFM2_Request)
                    JSON.deserialize(requestStr, SVMXC.SFM_WrapperDef2.SFM2_Request.class);          
        return JSON.serialize(new SVMXC.SFMDesigner2ServiceImpl().getFieldSets(deserializedRequest));       
    }    

    @RemoteAction
    public static Object JSRSaveLayout(String requestStr){        
                         
        SVMXC.SFM_WrapperDef2.SFM2_Request deserializedRequest = (SVMXC.SFM_WrapperDef2.SFM2_Request)
                    JSON.deserialize(requestStr, SVMXC.SFM_WrapperDef2.SFM2_Request.class);          
        return JSON.serialize(new SVMXC.SFMDesigner2ServiceImpl().saveLayout(deserializedRequest));       
    }  

    @RemoteAction
    public static Object JSRCloneLookupConfig(String requestStr){        
                         
        SVMXC.SFM_WrapperDef2.SFM2_Request deserializedRequest = (SVMXC.SFM_WrapperDef2.SFM2_Request)
                    JSON.deserialize(requestStr, SVMXC.SFM_WrapperDef2.SFM2_Request.class);          
        return JSON.serialize(new SVMXC.SFMDesigner2ServiceImpl().cloneLookupConfig(deserializedRequest));       
    }  


    @RemoteAction
    public static Object JSRSaveLookupConfig(String requestStr){        
                         
        SVMXC.SFM_WrapperDef2.SFM2_Request deserializedRequest = (SVMXC.SFM_WrapperDef2.SFM2_Request)
                    JSON.deserialize(requestStr, SVMXC.SFM_WrapperDef2.SFM2_Request.class);          
        return JSON.serialize(new SVMXC.SFMDesigner2ServiceImpl().saveLookupConfig(deserializedRequest));       
    }   

    @RemoteAction
    public static Object JSRGetCodeSnippets(String requestStr){        
                         
        SVMXC.SFM_WrapperDef2.SFM2_Request deserializedRequest = (SVMXC.SFM_WrapperDef2.SFM2_Request)
                    JSON.deserialize(requestStr, SVMXC.SFM_WrapperDef2.SFM2_Request.class);          
        return JSON.serialize(new SVMXC.SFMDesigner2ServiceImpl().getCodeSnippets(deserializedRequest));       
    }       

    @RemoteAction
    public static Object JSRGetCustomActions(String requestStr){        
                         
        SVMXC.SFM_WrapperDef2.SFM2_Request deserializedRequest = (SVMXC.SFM_WrapperDef2.SFM2_Request)
                    JSON.deserialize(requestStr, SVMXC.SFM_WrapperDef2.SFM2_Request.class);          
        return JSON.serialize(new SVMXC.SFMDesigner2ServiceImpl().getCustomActions(deserializedRequest));       
    }

    @RemoteAction
    public static Object JSRGetMultiSourceProcess(String requestStr){        
                         
        SVMXC.SFM_WrapperDef2.SFM2_Request deserializedRequest = (SVMXC.SFM_WrapperDef2.SFM2_Request)
                    JSON.deserialize(requestStr, SVMXC.SFM_WrapperDef2.SFM2_Request.class);          
        return JSON.serialize(new SVMXC.SFMDesigner2ServiceImpl().getMultiSourceProcess(deserializedRequest));       
    }

    @RemoteAction
    public static Object JSRGetLinkedProcess(String requestStr){        
                         
        SVMXC.SFM_WrapperDef2.SFM2_Request deserializedRequest = (SVMXC.SFM_WrapperDef2.SFM2_Request)
                    JSON.deserialize(requestStr, SVMXC.SFM_WrapperDef2.SFM2_Request.class);          
        return JSON.serialize(new SVMXC.SFMDesigner2ServiceImpl().getLinkedProcess(deserializedRequest));       
    } 

    @RemoteAction
    public static Object JSRGetSFMFunctions(String requestStr){        
                         
        SVMXC.SFM_WrapperDef2.SFM2_Request deserializedRequest = (SVMXC.SFM_WrapperDef2.SFM2_Request)
                    JSON.deserialize(requestStr, SVMXC.SFM_WrapperDef2.SFM2_Request.class);          
        return JSON.serialize(new SVMXC.SFMDesigner2ServiceImpl().getSFMFunctions(deserializedRequest));       
    } 

    @RemoteAction
    public static Object JSRGetListOfTemplates(String requestStr){        
                         
        SVMXC.SFM_WrapperDef2.SFM2_Request deserializedRequest = (SVMXC.SFM_WrapperDef2.SFM2_Request)
                    JSON.deserialize(requestStr, SVMXC.SFM_WrapperDef2.SFM2_Request.class);          
        return JSON.serialize(new SVMXC.SFMDesigner2ServiceImpl().getListOfTemplates(deserializedRequest));       
    }  

    @RemoteAction
    public static Object JSRCloneTemplate(String requestStr){        
                         
        SVMXC.SFM_WrapperDef2.SFM2_Request deserializedRequest = (SVMXC.SFM_WrapperDef2.SFM2_Request)
                    JSON.deserialize(requestStr, SVMXC.SFM_WrapperDef2.SFM2_Request.class);          
        return JSON.serialize(new SVMXC.SFMDesigner2ServiceImpl().cloneDocTemplate(deserializedRequest));       
    } 

    @RemoteAction
    public static Object JSRSaveTemplate(String requestStr){        
                         
        SVMXC.SFM_WrapperDef2.SFM2_Request deserializedRequest = (SVMXC.SFM_WrapperDef2.SFM2_Request)
                    JSON.deserialize(requestStr, SVMXC.SFM_WrapperDef2.SFM2_Request.class);          
        return JSON.serialize(new SVMXC.SFMDesigner2ServiceImpl().saveTemplate(deserializedRequest));       
    } 
                 
    @RemoteAction
    public static Object JSRGetChecklistProcess(String requestStr){
        SVMXC.SFM_WrapperDef2.SFM2_Request deserializedRequest = (SVMXC.SFM_WrapperDef2.SFM2_Request)
                    JSON.deserialize(requestStr, SVMXC.SFM_WrapperDef2.SFM2_Request.class);
        return JSON.serialize(new SVMXC.SFMDesigner2ServiceImpl().getChecklistProcess(deserializedRequest));
    }
    
    @RemoteAction
    public static Object JSRGetChecklistQuestions(String requestStr){
        SVMXC.SFM_WrapperDef2.SFM2_Request deserializedRequest = (SVMXC.SFM_WrapperDef2.SFM2_Request)
                    JSON.deserialize(requestStr, SVMXC.SFM_WrapperDef2.SFM2_Request.class);
        return JSON.serialize(new SVMXC.SFMDesigner2ServiceImpl().getChecklistQuestions(deserializedRequest));
    }
    @RemoteAction
    public static Object JSRGetListOfQuestions(String requestStr){
        SVMXC.SFM_WrapperDef2.SFM2_Request deserializedRequest = (SVMXC.SFM_WrapperDef2.SFM2_Request)
                    JSON.deserialize(requestStr, SVMXC.SFM_WrapperDef2.SFM2_Request.class);
        return JSON.serialize(new SVMXC.SFMDesigner2ServiceImpl().getListOfQuestions(deserializedRequest));
    }
    @RemoteAction
    public static Object JSRGetListOfResponseSet(String requestStr){
        SVMXC.SFM_WrapperDef2.SFM2_Request deserializedRequest = (SVMXC.SFM_WrapperDef2.SFM2_Request)
                    JSON.deserialize(requestStr, SVMXC.SFM_WrapperDef2.SFM2_Request.class);
        return JSON.serialize(new SVMXC.SFMDesigner2ServiceImpl().getListOfResponseSet(deserializedRequest));
    }
    @RemoteAction
    public static Object JSRGetApiConfiguration(String requestStr){
        SVMXC.SFM_WrapperDef2.SFM2_Request deserializedRequest = (SVMXC.SFM_WrapperDef2.SFM2_Request)
                    JSON.deserialize(requestStr, SVMXC.SFM_WrapperDef2.SFM2_Request.class);
        return JSON.serialize(new SVMXC.SFMDesigner2ServiceImpl().getApiConfiguration(deserializedRequest));
    }
    @RemoteAction
    public static Object JSRSaveResponseSet(String requestStr){
        SVMXC.SFM_WrapperDef2.SFM2_Request deserializedRequest = (SVMXC.SFM_WrapperDef2.SFM2_Request)
                    JSON.deserialize(requestStr, SVMXC.SFM_WrapperDef2.SFM2_Request.class);
        return JSON.serialize(new SVMXC.SFMDesigner2ServiceImpl().saveResponseSet(deserializedRequest));
    }  
    @RemoteAction
    public static Object JSRSaveQuestionInfo(String requestStr){
        SVMXC.SFM_WrapperDef2.SFM2_Request deserializedRequest = (SVMXC.SFM_WrapperDef2.SFM2_Request)
                    JSON.deserialize(requestStr, SVMXC.SFM_WrapperDef2.SFM2_Request.class);
        return JSON.serialize(new SVMXC.SFMDesigner2ServiceImpl().saveQuestionInfo(deserializedRequest));
    }           
}