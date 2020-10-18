global virtual class IOTRestBase {

    // The request object got during the initial service call
    protected RestRequest request;
    
    // The response object got during the initial service call
    protected RestResponse response;
    
    protected String urlMapping;
    protected String serviceName;
    protected String methodName;
    protected String versionNumber;
    protected String httpMethod;
    
    private String calculatedMethodName;
    
    private String[] versions;
    private String[] versionToMethodMapping;
    
    /**
     * !!! The empty constructor is available so that the rest implementations can be instantiated and used by-passing the
     * !!! the SFDC REST layer.
     */
    protected IOTRestBase(){
     // TODO: Implement versioning
    }
    
    /**
     * @description This class's constructor
     * @param req The request object got during the initial service call
     * @param res The response object got during the initial service call
     * @param serviceName The name of the REST service. Usually this will be class name of the service class. 
     */
    protected IOTRestBase(RestRequest req, RestResponse res, String serviceName){
        
        // version information, at the heart of API versioning. Refer to the design document for more information
        // TODO: finalize the version number
        versions = new String[3]; versionToMethodMapping = new String[3];
        versions[0] = '1.0'; versions[1] = '2.0'; versions[2] = '3.0';
        versionToMethodMapping[0] = 'Older'; versionToMethodMapping[1] = ''; 
        // end of API versioning
        
        this.request = req;
        this.response = res;
        this.serviceName = serviceName;
        this.urlMapping = '/svmx/rest/' + serviceName + '/';
        
        String uri = req.requestURI;
        System.debug('Request URI =>' + uri);
        
        // extract the method name, version number
        // TODO: URL validation
        String info = uri.substring(
                    uri.lastIndexOf(urlMapping) + urlMapping.length(), uri.lastIndexOf('/'));
        String[] items = info.split('/');
        this.methodName = items[0];
        this.versionNumber = items[1];
    }
    
    /**
     * @description This method is called by this class itself to initiate a call to the
                    actual method implementation. Sub-classes must override this method.
     * @param mi The object containing all the information about the method that needs to be executed.
     * @return Object The result of the method execution. This object is converted to a JSON string and returned to the calling consumer. 
     */
    virtual public Object invokeMethod(IOTRestMethodInfo mi) { 
        // TODO: throw as exception.
        // Sub-classes MUST provide an implementation for this.
        return null;
    }
    
    /**
     * @description This method is the handler for the HTTP GET call of the REST service 
     */
    public void invokeGet(){
        
        // Utility variable to indicate what is the actual http method.
        // TODO: Calculate this, similarly to what is done on the client
        httpMethod = 'GET';
        
        IOTRestMethodInfo mi = new IOTRestMethodInfo();
        mi.MethodName = methodName;
        mi.VersionNumber = versionNumber;
        Object resp = invokeMethod(mi);
        if(resp != null){
            this.buildResponse(resp);
        }
    }
    
    /**
     * @description This method is the handler for the HTTP POST call of the REST service 
     */
    public void invokePost(){
        // refer to invokeGet()
        httpMethod = 'POST';
        
        IOTRestMethodInfo mi = new IOTRestMethodInfo();
        mi.MethodName = methodName;
        mi.VersionNumber = versionNumber;
        Object resp = invokeMethod(mi);
        if(resp != null){
            this.buildResponse(resp);
        }
    }
    
    /**
     * @description This method is the handler for the HTTP PUT call of the REST service 
     */
    public void invokePut(){
        
        // refer to invokeGet()
        httpMethod = 'PUT';
        
        // right now, just delegate the call to GET
        this.invokeGet();
    }
    
    /**
     * @description This method is the handler for the HTTP DELETE call of the REST service 
     */
    public void invokeDelete(){
        
        // refer to invokeGet()
        httpMethod = 'DELETE';
        
        // right now, just delegate the call to GET
        this.invokeGet();
    }
    
    /**
     * @description This method is the default handler in case when an appropriate method is not found
                    in the implementation class.
       @return ErrorMessage the object containing the error related information. 
     */
    protected Object invokeMissingMethod(){
        ErrorMessage em = new ErrorMessage('MISSING_METHOD', 'The method ' + methodName + ' is missing!');
        return em;
    }
    
    /**
     * @description This method sets up the response data into the RestResponse object, which is returned back to the consumer.
     * @param data the response data 
     */
    protected void buildResponse(Object data){
        String resp = this.serializeResponseFrom(data);
        this.response.responseBody = Blob.valueOf(resp);
    }
    
    protected String getHeader(String name){
        //TODO
        return '';
    }
    
    protected String getParameter(String name){
        //TODO: Remove this log
        System.debug('Total number of parameters =>' + request.params.size());
        return request.params.get(name);
    }
    
    /**
     * @description This method is used to serialize the APEX object into JSON string.
     * @param data the response data 
     * @return String the JSON representation of the response data.
     */
    protected String serializeResponseFrom(Object data){
        return JSON.serialize(data);
    }

    /**
     * @description This method is used to de-serialize an APEX object from a JSON string.
     * @param apexType the type of the APEX object to which JSON has to be de-serialized into 
     * @return Object the APEX object created out of JSON string.
     */
    protected Object deserializeRequestTo(System.Type apexType){
        System.debug('Attempt to de-serialize a JSON string to an APEX type is made');
        
        String requestStr = '';
        
        // only for the http GET method, the request body is available as a parameter in the URL
        if(httpMethod == 'GET'){
            requestStr = getParameter('getParams');
        }else{
            Blob data = request.requestBody;
            requestStr = data.toString();
        }
        
        System.debug('The request JSON => ' + requestStr);
        
        if(requestStr != null && requestStr != ''){
            return JSON.deserialize(requestStr, apexType);
        }
        return null;
    }
    
    // Error message information
    public class ErrorMessage{
        public String ErrorCode;
        public String Message;
        public String ExceptionMessage;
        
        public ErrorMessage(String error, String message){
            this.ErrorCode = error;
            this.Message = message;
        }

        public ErrorMessage(String error, String message, String eMessage){
            this.ErrorCode = error;
            this.Message = message;
            this.ExceptionMessage = eMessage;
        }
    }
    // End of error message
}