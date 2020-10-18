global with sharing class COMM_Utils_ObjectMapping{
    public List<SVMXC__ServiceMax_Config_Data__c> fieldMapSettingRecords ;
    public SVMXC.COMM_Utils_ManageSettings settings ; 
    public  Map<String, Schema.SObjectType> allObjs = new Map<String, Schema.SObjectType>();
    public sObject targetObject;
    public List<sObject> listTargetObject;
    public String souObjFieldNames = '';
    public String tFName;
    public String sFName;
    public Object souFldVal;
    public SObjectType st ; 
    
    // This is the Wapper class which returns Response 
    global class ObjectMappingResult
    {
    
        public  List<SObject> listresultObj;
        public  Sobject resultObj;
        public  Boolean Success;       
        public  String ResultMsg;
       
        public ObjectMappingResult(List<SObject> so,Boolean bo,String str)
         {
            listresultObj =so;
            Success = bo;
            ResultMsg = str;
         }
          public ObjectMappingResult(SObject so,Boolean bo,String str)
         {
            resultObj =so;
            Success = bo;
            ResultMsg = str;
         }
    }
    
    public  COMM_Utils_ObjectMapping()
    {
        allObjs = Schema.getGlobalDescribe();
    }
      
    //This fuction get the input perameter of mapid, Where clouse of Quary and list of Sobject that we need and  return the Target object Record
   
   
    global  ObjectMappingResult getTargerRecordlist(String mid,String WhrClause,List<Sobject> listofRec)
    {
        listTargetObject = listofRec;
        String mapid = String.isNotBlank(mid) ? String.escapeSingleQuotes(mid) : mid; //#soqlInjectionFix
        ObjectMappingResult result;
        
        fieldMapSettingRecords = new List<SVMXC__ServiceMax_Config_Data__c>();
        settings = new SVMXC.COMM_Utils_ManageSettings();
        
        
      try
      {
        SVMXC__ServiceMax_Processes__c svmxcprocess = [Select SVMXC__Target_Object_Name__c, SVMXC__Source_Object_Name__c, SVMXC__MapID__c From SVMXC__ServiceMax_Processes__c where SVMXC__MapID__c=:mapid]; //SDL-SVMX-FLS-NOT-ENFORCED-META-DATA
        String sourceObjectName= svmxcprocess.SVMXC__Source_Object_Name__c;
        String targetObjectName= svmxcprocess.SVMXC__Target_Object_Name__c;
        fieldMapSettingRecords.clear();
        fieldMapSettingRecords = settings.SVMX_getFieldMapping(mapid);    
        //preparing the source object field to get the values source object
        souObjFieldNames = '';
        Set<String> setOfUniqueFldNames = new Set<String>();
        for(SVMXC__ServiceMax_Config_Data__c fld:fieldMapSettingRecords)
        {
            String s1 = fld.SVMXC__Source_Field_Name__c;
            if(s1 != null && setOfUniqueFldNames.contains(s1) == false) 
            {
                setOfUniqueFldNames.add(s1);
                    if (souObjFieldNames.length() > 0 ) 
                    { 
                        if(fld.SVMXC__Source_Field_Name__c != null)
                        souObjFieldNames += ', '; 
                    }
                     if(fld.SVMXC__Source_Field_Name__c != null) 
                    souObjFieldNames += s1;
            }
        }
       
        String SOQLHeader;
        SOQLHeader = '  SELECT '+ String.escapeSingleQuotes(souObjFieldNames) +' FROM '+ sourceObjectName + ' where ' + WhrClause;  //#soqlInjectionFix
        List<SObject> listSouObjRec = Database.query(SOQLHeader);    
        for(SObjectType s:allObjs.values())
        {
            if(s.getDescribe().getName() == targetObjectName)
            {   
                st = s;
            }
        }
 
       for(SObject souObjRec :listSouObjRec )
       { //Loop Multiple Recs and build result List
        //preparing the traget object using the target object name
          
         targetObject = st.newSObject();
          for(SVMXC__ServiceMax_Config_Data__c fld:fieldMapSettingRecords)
          {
             
                 tFName = fld.SVMXC__Target_Field_Name__c;
                 sFName = fld.SVMXC__Source_Field_Name__c;
                 if(sFName != null )
                 souFldVal = souObjRec.get(sFName);
                 if(souFldVal != null)
                 {
                    targetObject.put(tFName, souFldVal);
                 }
           }
           listTargetObject.add(targetObject);  
        }
         result =new ObjectMappingResult(listTargetObject,true,'Success');
         return result; 
        
            
       } //end of try
        catch(Exception excObj)
        {
         result = new ObjectMappingResult(listTargetObject,false,excObj.getMessage());
           return result;
       }
    
    }
    
    //This fuction get the input perameter of mapid and source object id and return the Target object Record
    
    global  ObjectMappingResult getTargerRecord(String mid,String sid)
    {
       
        String sourceobjectid = String.isNotBlank(sid) ? String.escapeSingleQuotes(sid) : sid; //#soqlInjectionFix
        String mapid = String.isNotBlank(mid) ? String.escapeSingleQuotes(mid) : mid; //#soqlInjectionFix
        ObjectMappingResult result;
        
        System.debug('mapid '+mid+' sourceobjectid '+sourceobjectid);
        
        fieldMapSettingRecords = new List<SVMXC__ServiceMax_Config_Data__c> ();
        settings = new SVMXC.COMM_Utils_ManageSettings();
       
        
      //try
      //{
        SVMXC__ServiceMax_Processes__c svmxcprocess = [Select SVMXC__Target_Object_Name__c, SVMXC__Source_Object_Name__c, SVMXC__MapID__c From SVMXC__ServiceMax_Processes__c where SVMXC__MapID__c=:mapid]; //SDL-SVMX-FLS-NOT-ENFORCED-META-DATA
        String sourceObjectName= svmxcprocess.SVMXC__Source_Object_Name__c;
        String targetObjectName= svmxcprocess.SVMXC__Target_Object_Name__c;
        fieldMapSettingRecords.clear();
        fieldMapSettingRecords = settings.SVMX_getFieldMapping( mapid);    
        //preparing the source object field to get the values source object
        souObjFieldNames = '';
        for(SVMXC__ServiceMax_Config_Data__c fld:fieldMapSettingRecords)
        {
            if (souObjFieldNames.length() > 0){
                if(fld.SVMXC__Source_Field_Name__c != null)
                souObjFieldNames += ', '; 
            }
            if(fld.SVMXC__Source_Field_Name__c != null) 
            souObjFieldNames += fld.SVMXC__Source_Field_Name__c;
        }
        
        String SOQLHeader = '  SELECT '+ souObjFieldNames +' from '+ sourceObjectName + ' where Id=\''+sourceobjectid+'\'';        
        SObject souObjRec = Database.query(SOQLHeader);    
        for(SObjectType s:allObjs.values())
        {
            if(s.getDescribe().getName() == targetObjectName)
            {   
                st = s;
            }
        }
       //for(SObject souObjRec :listSouObjRec )
       { //Loop Multiple Recs and build result List
        //preparing the traget object using the target object name
         
          targetObject = st.newSObject();
          
          for(SVMXC__ServiceMax_Config_Data__c fld:fieldMapSettingRecords)
             {
                
                 tFName = fld.SVMXC__Target_Field_Name__c;
                 sFName = fld.SVMXC__Source_Field_Name__c;
                 if(tFName !=null){
                     if(sFName != null)
                     {
                         souFldVal = souObjRec.get(sFName);
                         if(souFldVal != null)
                         {
                            targetObject.put(tFName, souFldVal);
                         }
                     }
                 }
             }  
       }
          
         result =new ObjectMappingResult(targetObject,true,'Success');
         return result; 
            
      // }//end of try
    ///    catch(Exception excObj)
   //     {
       //    result = new ObjectMappingResult(targetObject,false,excObj.getMessage());
       //    return result;
      //  }
            
        
    }
}