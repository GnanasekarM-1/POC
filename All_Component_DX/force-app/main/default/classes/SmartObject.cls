/* Security Scanned */
global with sharing class SmartObject{
    global SmartObject(){}
    
    //Method for getGlobalDescribe of Smart Object
    public static Map<String, SmartObject.DescribeSmartObjectResult> getGlobalDescribe(){
        List<SVMXC__Object_Cache__c> lstSmartObject = new List<SVMXC__Object_Cache__c>();
        Map<String, SmartObject.DescribeSmartObjectResult> mapAPINameAndSmartObject = new Map<String, SmartObject.DescribeSmartObjectResult>();
        //SDL-SVMX-FLS-NOT-ENFORCED-META-DATA
        lstSmartObject = [SELECT SVMXC__Object_API_Name__c, SVMXC__Schema__c FROM SVMXC__Object_Cache__c];
        for(SVMXC__Object_Cache__c objSmartObject : lstSmartObject){
            String strAPIName = objSmartObject.SVMXC__Object_API_Name__c;
            String strJSONString = objSmartObject.SVMXC__Schema__c;
            //We are checking null condition because some org may have data in SVMXC__Object_Cache__c object with SVMXC__Schema__c fields as null value
            //This is possible from the older object cache implementation
            if(strJSONString != null && strJSONString != '' && strAPIName != null && strAPIName != ''){
                try{
                    SmartObject.DescribeSmartObjectResult objDescribeSmartObjectResult = (SmartObject.DescribeSmartObjectResult)JSON.deserialize(strJSONString, SmartObject.DescribeSmartObjectResult.class);
                    mapAPINameAndSmartObject.put(strAPIName, objDescribeSmartObjectResult);
                }
                catch(Exception ex){
                    System.debug(LoggingLevel.WARN, 'Not valid JSONSchema String : '+strJSONString +' ; --Error message-- : '+ex.getMessage()+ '; --Stack Trace String-- : '+ex.getStackTraceString());
                } 
            }
        }
        return mapAPINameAndSmartObject;
    }
    public Class SmartObjectRecord{
        public String Id;
        public String ObjectAPIName;
        public Map<String, Object> mapTargetRecordFieldValues;
        public SmartObjectRecord(){}
    }
    public with sharing class SmartObjectType{
        public SmartObjectType(){}
        
        //Method for getDescribe of Particular Smart Object
        public SmartObject.DescribeSmartObjectResult getDescribe(String objectAPIName){
            SmartObject.DescribeSmartObjectResult objDescribeSmartObjectResult = new SmartObject.DescribeSmartObjectResult();
            String strSmartObjectJSON = '';
            List<SVMXC__Object_Cache__c> lstSmartObject = new List<SVMXC__Object_Cache__c>();
            
            if(objectAPIName != null && objectAPIName != ''){
                //SDL-SVMX-FLS-NOT-ENFORCED-META-DATA
                lstSmartObject = [SELECT SVMXC__Schema__c FROM SVMXC__Object_Cache__c WHERE SVMXC__Object_API_Name__c =: objectAPIName];
                if(lstSmartObject.size()>0){
                    strSmartObjectJSON = lstSmartObject[0].SVMXC__Schema__c;
                    //We are checking null condition because some org may have data in SVMXC__Object_Cache__c object with SVMXC__Schema__c fields as null value
                    //This is possible from the older object cache implementation
                    if(strSmartObjectJSON != null && strSmartObjectJSON != ''){
                        try{
                            objDescribeSmartObjectResult = (SmartObject.DescribeSmartObjectResult)JSON.deserialize(strSmartObjectJSON, SmartObject.DescribeSmartObjectResult.class);
                            System.debug('objDescribeSmartObjectResult11 : '+objDescribeSmartObjectResult);
                        }
                        catch(Exception ex){
                            System.debug(LoggingLevel.WARN, 'Not valid JSONSchema String : '+strSmartObjectJSON +' ; --Error message-- : '+ex.getMessage()+ '; --Stack Trace String-- : '+ex.getStackTraceString());
                        }
                    }
                }
            }
            return objDescribeSmartObjectResult;
        }
    }
    global Class DescribeSmartObjectResult{
        webservice String name{set; get;}
        webservice String label{set; get;}
        webservice String createable{set; get;}
        webservice List<DescribeSmartFieldResult> fields = new List<DescribeSmartFieldResult>();
        global DescribeSmartObjectResult(){}
        public List<DescribeSmartFieldResult> getFields(){return fields;}
        public String getName(){ return name;}
        public String getLabel(){ return label;}
        public Map<String, SmartObject.SmartObjectField> getFieldMap(){
            Map<String, SmartObject.SmartObjectField> mapAPINameFieldObject = new Map<String, SmartObject.SmartObjectField>();
            for(DescribeSmartFieldResult obj : fields){
                mapAPINameFieldObject.put(obj.name, new SmartObject.SmartObjectField(obj));
            }
            return mapAPINameFieldObject;
        }
    }
    public Class SmartObjectField{
        public DescribeSmartFieldResult objDescribeSmartFieldResult;
        public void setobjDescribeSmartFieldResult(DescribeSmartFieldResult obj){
            objDescribeSmartFieldResult = obj;
        }
        public DescribeSmartFieldResult getobjDescribeSmartFieldResult(){
            return objDescribeSmartFieldResult;
        }
        public SmartObjectField(){}
        public SmartObjectField(DescribeSmartFieldResult SF){   objDescribeSmartFieldResult = SF;}
        public SmartObject.DescribeSmartFieldResult getDescribe(){
            if(objDescribeSmartFieldResult != null){
                SmartObject.DescribeSmartFieldResult objDescribeSmartFieldResult = new SmartObject.DescribeSmartFieldResult(objDescribeSmartFieldResult.name, objDescribeSmartFieldResult.label, objDescribeSmartFieldResult.type, objDescribeSmartFieldResult.length);
                return objDescribeSmartFieldResult;
            }
            return null;
        }
    }
    global class DescribeSmartFieldResult{
        webservice String name {set; get;}
        webservice String label {set; get;}
        webservice String type {set; get;}
        webservice String createable {set; get;}
        webservice String custom {set; get;}
        webservice String length {set; get;}
        webservice String updateable {set; get;}
        webservice String precision {set; get;}
        webservice String nameField {set; get;}
        webservice String referenceTo {set; get;}
        webservice String relationshipName {set; get;}
        webservice String picklistValues {set; get;}
        
        public String getLabel(){ return label;}
        public String getName(){ return name;}
        public String getType(){ return type;}
        public String getlength(){ return length;}
        public DescribeSmartFieldResult(){}
        public DescribeSmartFieldResult(String strName, String strLabel, String strType, String strLength){
            name = strName;
            label = strLabel;
            type = strType;
            length = strLength;
        }
    }
}