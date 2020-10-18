global virtual class ComRestBase
{
    protected RestRequest request;
    protected RestResponse response;

    protected String strURLMapping;
    protected String strServiceName;
    protected String strMethodName;
    protected String strHttpMethod;

    protected ComRestBase(){  }

    //@description This class's constructor
    //@param req The request object got during the initial service call
    //@param res The response object got during the initial service call
    //@param strServiceName The name of the REST service. Usually this will be the name of the method which is to be invoked.
    protected ComRestBase(RestRequest req, RestResponse res, String strServiceName)
    {
        this.request = req;
        this.response = res;
        this.strServiceName = strServiceName;
        this.strURLMapping = strServiceName;
        
        String strURI = req.requestURI;
        System.debug('Request URI ==' + strURI);
        this.strMethodName = strURI.substring(strURI.lastIndexOf('/') + 1);
        System.debug('Method Name ==' + strMethodName);
    }

    /**
     * @description This method is called by this class itself to initiate a call to the actual method implementation. Sub-classes must override this method.
     * @param mi The object containing all the information about the method that needs to be executed.
     * @return Object The result of the method execution. This object is converted to a JSON string and returned to the calling consumer. 
     */
    virtual public Object invokeMethod(ComRestMethodInfo  mi) 
    {
        return null;
    }
    
    //HTTP GET call of the REST service
    public void invokeGet()
    {
        strHttpMethod = 'GET';
        ComRestMethodInfo  mi = new ComRestMethodInfo ();
        mi.MethodName = strMethodName;
        Object resp = invokeMethod(mi);
        if(resp != null)
        {
            this.buildResponse(resp);
        }
    }
    
    //HTTP POST call of the REST service
    public void invokePost()
    {
        strHttpMethod = 'POST';
        ComRestMethodInfo  mi = new ComRestMethodInfo ();
        mi.MethodName = strMethodName;
        Object resp = invokeMethod(mi);
        if(resp != null)
        {
            this.buildResponse(resp);
        }
    }
    
    //
    protected Object invokeMissingMethod()
    {
        ErrorMessage em = new ErrorMessage('METHOD_MISSING', 'The method ' + strMethodName + ' is missing!');
        return em;
    }
    
    /**
     * @description This method sets up the response data into the RestResponse object, which is returned back to the consumer.
     * @param data the response data 
     */
    protected void buildResponse(Object data)
    {
        System.debug(LoggingLevel.WARN, 'Heap Size Used before serializing=>' + Limits.getHeapSize());
        //String resp = this.serializeResponseFrom(data);
        //this.response.responseBody = Blob.valueOf(resp);
        this.response.responseBody = Blob.valueOf(JSON.serialize(data));
        System.debug(LoggingLevel.WARN, 'Heap Size Used after serializing=>' + Limits.getHeapSize());
    }
    
    protected String getParameter(String name)
    {
        //TODO: Remove this log
        System.debug('Total number of parameters =>' + request.params.size());
        return request.params.get(name);
    }
    
    //This method is used to serialize a JSON string to an APEX object.
    protected String serializeResponseFrom(Object data)
    {
        return JSON.serialize(data);
    }
    
    //This method is used to de-serialize an APEX object of type apexType from a JSON string.
    protected Object deserializeRequestTo(System.Type apexType)
    {
        System.debug('Attempt to de-serialize a JSON string to an APEX type is made');
        String strRequest = '';

        // only for the http GET method, the request body is available as a parameter in the URL
        if(strHttpMethod == 'GET')
        {
            strRequest = getParameter('getParams');
        }
        else
        {
            Blob data = request.requestBody;
            strRequest = data.toString();
        }
        System.debug('The request in JSON == ' + strRequest);
        if(strRequest != null && strRequest != '')
        {
            //JSONParser parser = JSON.createParser(strRequest);    
            //return parser.readValueAs(apexType);
            return JSON.deserialize(strRequest, apexType);
        }
        return null;
    }
    
    public class ErrorMessage
    {
        public String Error;
        public String Message;

        public ErrorMessage(String error, String message)
        {
            this.Error = error;
            this.Message = message;
        }
    }
}