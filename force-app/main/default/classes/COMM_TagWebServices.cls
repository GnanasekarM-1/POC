global with sharing class COMM_TagWebServices {

    //wrapper class used, since a map cannot be returned in webservice.
    global class TagsMap
    {
      webservice String Key{get; set;}
      webservice String Value{get; set;}
      
      global TagsMap(String k, String v)
      {
        this.Key = k;
        this.Value = v;
      }    
    }
    Static Boolean IsSubModule;
    
    Static webservice List<TagsMap> TagdataforModule(String ModuleID)
    {
        IsSubModule = false;
        List<TagsMap> TagListValueM = TagvalueCalc(ModuleID);
        return TagListValueM;
    }
    
    Static webservice List<TagsMap> TagdataforSubmodule(String SubModuleID)
    {
        system.debug('amar'+system.now());
        IsSubModule = true;   
        List<TagsMap> TagListValueSM = TagvalueCalc(SubModuleID);
        system.debug('amar'+system.now());
        return TagListValueSM;
    }
    
    Static webservice List<TagsMap> TagvalueCalc(String SubModRModID)
    {
        Map<String,String> tagMap = new Map<String,String>();
        List<TagsMap> Taglist = new List<TagsMap>();
        COMM_TagsDefinition TagsDefn = new COMM_TagsDefinition();
        tagMap = TagsDefn.TagValues(SubModRModID);    
        TagsMap ResultTagMap;
        for(String Tagkv: Tagmap.keySet())
          {
                // For defect 040459: Change has been made to retrieve tags with ModuleID as FSA is using the tag with module id.
                // Ex - FSA008_TAG116
        
              if(IsSubModule==true && !Tagkv.startsWith('FSA') )
              {
                  List<String> Tag = Tagkv.split('-');
                  ResultTagMap = new TagsMap(Tag[1] , Tagmap.get(Tagkv));
                  System.debug('Labels +  '+Tag+'  VAl: '+Tagmap.get(Tagkv));
              }
              else
              {
                  String Tag = Tagkv.replace('-', '_');
                  ResultTagMap = new TagsMap(Tag , Tagmap.get(Tagkv));
                  System.debug('Labels +  '+Tag+'  VAl: '+Tagmap.get(Tagkv));
              }
              
          
              Taglist.add(ResultTagMap);
          }
        
        //Add Common Tags alwyas..
        map<String,String> commonTags = new map<String,String>();
        commonTags = TagsDefn.CommnaTags();
        for(String key : commonTags.keyset())
        {
            ResultTagMap = new TagsMap(key , commonTags.get(key));
            Taglist.add(ResultTagMap);
        }
        return Taglist;
    }

    Static public Map<String, String> getSFMDesignerTags(){
        Map<String, String> tagMap = new Map<String, String>();
        Designer_TagsDefinition.getSFMTags(tagMap);
        Designer_TagsDefinition.getNewDesignerTags(tagMap);

        Map<String, String> tagMap2 = new Map<String, String>();

        for(String tagKey : tagMap.keySet()){
            List<String> newTagList = tagKey.split('-');
            System.debug('Split Res ' + newTagList[1]);
            tagMap2.put(newTagList[1], tagMap.get(tagKey));       
        }
        
        tagMap.clear();
        Designer_TagsDefinition.getChecklistTags(tagMap2);
        tagMap2.putAll(new COMM_TagsDefinition().CommnaTags());

        return tagMap2;
    }
}