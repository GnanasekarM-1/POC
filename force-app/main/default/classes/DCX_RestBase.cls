/*****************************************************************************
 *                       Copyright (C) 2019 ServiceMax, Inc
 *                               All rights reserved
 *
 *****************************************************************************/

/**
 * @author Madhusudhan HK
 * @version 19.2000
 * @since 2019
 */


global virtual class DCX_RestBase
{
    protected RestRequest request;
    protected RestResponse response;
    protected String strURLMapping;
    protected String strServiceName;
    protected String strMethodName;
    protected String strHttpMethod;

    protected DCX_RestBase(){  }

    /**
    *@description This class's constructor
    *@param req The request object got during the initial service call
    *@param res The response object got during the initial service call
    *@param strServiceName The name of the REST service. Usually this will be the name of the method which is to be invoked.
    */
    protected DCX_RestBase(RestRequest req, RestResponse res, String strServiceName)
    {
        system.debug('DCX_RestBase req. '+req);
        this.request = req;
        this.response = res;
        this.strServiceName = strServiceName;
        this.strURLMapping = strServiceName;
        String strURI = req.requestURI;
        this.strMethodName = strURI.substring(strURI.lastIndexOf('/') + 1);
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
        /*if (data instanceOf String){
            this.response.responseBody = Blob.toPdf(data.toString());
        } else {*/
            this.response.responseBody = Blob.valueOf(JSON.serialize(data));
            this.response.addHeader('Content-Type', 'application/json');
    //  }
    }
    
    protected String getParameter(String name)
    {
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
                System.debug(logginglevel.info, 'Http Request : ' + request);
        String strRequest = '';
        // only for the http GET method, the request body is available as a parameter in the URL
        if(strHttpMethod == 'GET')
        {
            strRequest = getParameter('getParams');
            system.debug('strRequest Get '+strRequest);
        }
        else
        {
            Blob data = request.requestBody;
            system.debug('request.requestBody '+request.requestBody);
            strRequest = data.toString();
            system.debug('strRequest else '+strRequest);
        }
          if(request.requestBody.size()>0) {
            system.debug('request.requestBody1 '+request.requestBody);
            Blob data = request.requestBody;
            strRequest = data.toString();
          }
           
        system.debug('Request data  strRequest'+ request.requestBody); 
        system.debug('The request JSON => ' + strRequest);
        if(strRequest != null && strRequest != '')
        {
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