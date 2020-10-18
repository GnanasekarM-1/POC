global class COMM_Utils_TargetObjectTest{
    
   
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
    global class TargetObjectResultTest
    {
    
        public  List<SObject> listresultObj;
        public  Sobject resultObj;
        public  Boolean Success;       
        public  String ResultMsg;
       
        public TargetObjectResultTest(List<SObject> so,Boolean bo,String str)
         {
            listresultObj =so;
            Success = bo;
            ResultMsg = str;
         }
          public TargetObjectResultTest(SObject so,Boolean bo,String str)
         {
            resultObj =so;
            Success = bo;
            ResultMsg = str;
         }
    }
    
    public  COMM_Utils_TargetObjectTest()
    {
        allObjs = Schema.getGlobalDescribe();
    }
      
    //This fuction get the input perameter of mapid, Where clouse of Quary and list of Sobject that we need and  return the Target object Record
   
   
    global  TargetObjectResultTest getTargerRecordlist(String mid,String WhrClause,List<Sobject> listofRec)
    {
        listTargetObject = listofRec;
        String mapid = mid;
        TargetObjectResultTest result;
        
        fieldMapSettingRecords = new List<SVMXC__ServiceMax_Config_Data__c>();
        settings = new SVMXC.COMM_Utils_ManageSettings();
        
        
      try
      {
        SVMXC__ServiceMax_Processes__c svmxcprocess = [Select SVMXC__Target_Object_Name__c, SVMXC__Source_Object_Name__c, SVMXC__MapID__c From SVMXC__ServiceMax_Processes__c where SVMXC__MapID__c=:mapid];
        String sourceObjectName= svmxcprocess.SVMXC__Source_Object_Name__c;
        String targetObjectName= svmxcprocess.SVMXC__Target_Object_Name__c;
        fieldMapSettingRecords.clear();
        fieldMapSettingRecords = settings.SVMX_getFieldMapping(mapid);    
        //preparing the source object field to get the values source object
        souObjFieldNames = '';
        for(SVMXC__ServiceMax_Config_Data__c fld:fieldMapSettingRecords)
        {
            if (souObjFieldNames.length() > 0) 
            { 
                souObjFieldNames += ', '; 
            }
            if(fld.SVMXC__Source_Field_Name__c != null) 
            souObjFieldNames += fld.SVMXC__Source_Field_Name__c;
        }
        
        
        String SOQLHeader = '  SELECT '+ souObjFieldNames +' FROM '+ sourceObjectName + ' where ' + WhrClause; //Id=\''+sourceobjectid+'\'';        
        List<SObject> listSouObjRec = Database.query(SOQLHeader);    
        for(SObjectType s:allObjs.values())
        {
            //Bala(29/1/21): Added the check for SiteHistory, since we are not able to describe SiteHistory object while packaging
            if(String.ValueOf(s) != 'SiteHistory' && s.getDescribe().getName() == targetObjectName)
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
          
         result =new TargetObjectResultTest(listTargetObject,true,'Success');
         return result; 
            
       } //end of try
        catch(Exception excObj)
        {
         result = new TargetObjectResultTest(listTargetObject,false,excObj.getMessage());
           return result;
       }
    
    }
    
    //This fuction get the input perameter of mapid and source object id and return the Target object Record
    
    global  TargetObjectResultTest getTargerRecord(String mid,String sid)
    {
       
        String sourceobjectid = sid;
        String mapid = mid;
        TargetObjectResultTest result;
        
        fieldMapSettingRecords = new List<SVMXC__ServiceMax_Config_Data__c> ();
        settings = new SVMXC.COMM_Utils_ManageSettings();
       
        
      //try
      //{
        SVMXC__ServiceMax_Processes__c svmxcprocess = [Select SVMXC__Target_Object_Name__c, SVMXC__Source_Object_Name__c, SVMXC__MapID__c From SVMXC__ServiceMax_Processes__c where SVMXC__MapID__c=:mapid];
        String sourceObjectName= svmxcprocess.SVMXC__Source_Object_Name__c;
        String targetObjectName= svmxcprocess.SVMXC__Target_Object_Name__c;
        fieldMapSettingRecords.clear();
        fieldMapSettingRecords = settings.SVMX_getFieldMapping( mapid);    
        //preparing the source object field to get the values source object
        souObjFieldNames = '';
        for(SVMXC__ServiceMax_Config_Data__c fld:fieldMapSettingRecords)
        {
            if (souObjFieldNames.length() > 0) 
            { 
                souObjFieldNames += ', '; 
            }
            if(fld.SVMXC__Source_Field_Name__c != null) 
            souObjFieldNames += fld.SVMXC__Source_Field_Name__c;
        }
        system.debug(LoggingLevel.INFO, souObjFieldNames + 'ZZZZZZZZZZZ:' + souObjFieldNames);
        
        String SOQLHeader = '  SELECT '+ souObjFieldNames +' FROM '+ sourceObjectName + ' where Id=\''+sourceobjectid+'\'';  
        List<SObject> listSouObjRec = Database.query(SOQLHeader);    
        for(SObjectType s:allObjs.values())
        {
            system.debug(LoggingLevel.INFO, 'SS:'+s);
            //Bala(29/1/21): Added the check for SiteHistory, since we are not able to describe SiteHistory object while packaging
            if(String.ValueOf(s) != 'SiteHistory' && s.getDescribe().getName() == targetObjectName)
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
             
       }
          
         result =new TargetObjectResultTest(targetObject,true,'Success');
         return result; 
            
      // }//end of try
    ///    catch(Exception excObj)
   //     {
       //    result = new TargetObjectResultTest(targetObject,false,excObj.getMessage());
       //    return result;
      //  }
            
        
    }
    
    
     

}