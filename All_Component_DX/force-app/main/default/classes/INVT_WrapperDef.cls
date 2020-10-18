global class INVT_WrapperDef
{ 
    //Constructor
    global INVT_WrapperDef()    
    {
        
    }
    
    //wrapper class for message
    global class SVMXMessage {
        
        webservice String message {get;set;}
        webservice String details  {get;set;}
        webservice String key  {get;set;}
        
        global SVMXMessage(String message,String details){
            this.message = message;
            this.details = details;
        }
        global SVMXMessage(String message,String details,String key){
            this.message = message;
            this.details = details;
            this.key = key;
        }
        global SVMXMessage(){}
    }
    
    //Wrapper class for key value 
    global class INVT_StringMap
    {
        webservice String key {get;set;}
        webservice String value{get;set;}
        //webservice String value1{get;set;}
        //webservice String fieldsToNull{get;set;}
        
        global INVT_StringMap(String k,String v) 
        {
            key = k;
            value = v;
        }
        
        global INVT_StringMap(){
            
        }
    }
    global class INVT_StringListMap
    {
        webservice String key {get;set;}
        webservice List<String> valueList = new List<String>();
        //webservice String fieldsToNull{get;set;}
        
        global INVT_StringListMap(String key,List<String> valueList)
        {
            this.key = key;
            this.valueList = valueList;
        }
        global INVT_StringListMap()
        {
            
        }
        
        global List<String> getvalueList(){return valueList;}
        global void setvalueList(List<String> s ){valueList = s;}
    }
    
    //Wrapper class of INVT_Request
    global class INVT_Request
    {
        webservice  List<INVT_StringMap> listOfStringMap = new List<INVT_StringMap>(); 
        webservice  List<INVT_StringListMap> listOfStringlistMap = new List<INVT_StringListMap>();
        
        global INVT_Request()
        {
            
        }
        global List<INVT_StringMap> getListOfStringMap(){return listOfStringMap;}
        global void setListOfStringMap(List<INVT_StringMap> s){listOfStringMap = s ;}
        global List<INVT_StringListMap> getListOfStringlistMap(){return listOfStringlistMap;}
        global void setListOfStringlistMap(List<INVT_StringListMap> s){listOfStringlistMap = s ;}
    }
    
    //Wrapper class of INVT_Response
    global class INVT_Response
    {
        webservice  boolean success;
        webservice  boolean validationSuccess = true;
        webservice  List<SVMXMessage> listOfMessage = new List<SVMXMessage>();
        
        global INVT_Response()
        {
            
        }
        global boolean getSuccess(){return success;}
        global void setSuccess(boolean s){success = s ;}
        global List<SVMXMessage> getListOfMessage(){return listOfMessage;}
        global void setListOfMessage(List<SVMXMessage> s){listOfMessage = s ;}
        global boolean getValidationSuccess(){return validationSuccess;}
        global void setValidationSuccess(Boolean validationSuccess){this.validationSuccess = validationSuccess;}
    }
}