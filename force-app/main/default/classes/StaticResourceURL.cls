global with sharing class StaticResourceURL {

    @RemoteAction
    global static Object JsrGetAllStaticResources(String requestStr){
        List<StaticResource> resourceList= [SELECT Name, NamespacePrefix, SystemModStamp FROM StaticResource];
        List<StaticResourceInfo> ret = new List<StaticResourceInfo>();
        Integer i = 0, l = resourceList.size();
        for(i = 0; i < l; i++){
            StaticResourceInfo ri = new StaticResourceInfo();
            ri.Name = resourceList[i].Name;
            ri.Namespace = resourceList[i].NamespacePrefix;
            ri.Timestamp = resourceList[i].SystemModStamp.getTime();
            ret.add(ri);
        }
        return JSON.serialize(ret);
    }
    
    public class StaticResourceInfo {
        public String Name;
        public String Namespace;
        public Long Timestamp;
    }
}