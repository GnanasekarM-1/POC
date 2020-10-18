@RestResource(urlMapping='/svmx/rest/IG/*')
global class INTF_IG_ServiceInterface {
    
    @HttpGet
    global static void doGet() {
        
        try{
            RestRequest req = RestContext.request;
            RestResponse res = RestContext.response;
            invokeMethod(req, res, 'GET');
        }catch(Exception ex)
        {
           // throw new SVMXDEV.SFM_WrapperDef.PMaxException(ex); 
           throw ex;
        } 
    }
    
    @HttpPost
    global static void doPost() {
        try{
            RestRequest req = RestContext.request;
            RestResponse res = RestContext.response;
            invokeMethod(req, res, 'POST');
        }catch(Exception ex)
        {
            // throw new SVMXDEV.SFM_WrapperDef.PMaxException(ex); 
            throw ex;
        } 
    }

    private static void invokeMethod(RestRequest req, RestResponse res, String httpMethod){
        
        String urlMapping = '/svmx/rest/IG/';
        
        String uri = req.requestURI;
        System.debug('Request URI =>' + uri);
        
        // extract the method name, version number
        // TODO: URL validation
        String info = uri.substring(
                    uri.lastIndexOf(urlMapping) + urlMapping.length(), uri.lastIndexOf('/'));
        String[] items = info.split('/');
        String methodName = items[1];
        String versionNumber = items[0];
        IGResponse reconcileResponse = null;

        //invoke reconcile
        if(items.size() == 2 && methodName == 'reconcile' && versionNumber == '1.0' && httpMethod == 'POST'){
          reconcileResponse = invokeReconcile(req, httpMethod);
        } else if(items.size() == 4 && methodName == 'reconcile' && versionNumber == '1.0' && items[2] == 'getStatus' && httpMethod == 'GET') {
          reconcileResponse = invokeGetStatus(items[3]);
        }else{
          reconcileResponse = new IGResponse();
          reconcileResponse.Status = 'Failed';
          reconcileResponse.ErrorDetails = 'Service doesn\'t exists!';
        }
        System.debug('Method Name: ' + methodName);
        System.debug('Version Number: ' + versionNumber);
        buildResponse(reconcileResponse, res);
    }

    private static void buildResponse(IGResponse data, RestResponse res){
        String resp = JSON.serialize(data);
        res.responseBody = Blob.valueOf(resp);
        res.statusCode = 200;
    }

    private static IGResponse invokeReconcile(RestRequest req, String httpMethod){
        IGRequest request = (IGRequest)deserializeRequestTo(IGRequest.class, req, httpMethod);
        return INTF_IG_Reconcile.reconcileSVMX(request);
    }

    private static IGResponse invokeGetStatus(String jobId){
        IGResponse reconcileResponse = null;
        if(jobId != null && jobId.length() >= 15){
          reconcileResponse = INTF_IG_Reconcile.getStatus(jobId);
        }else{
          reconcileResponse = new IGResponse();
          reconcileResponse.Status = 'Failed';
          reconcileResponse.ErrorDetails = 'Invalid JobId';
        }
        return reconcileResponse;
    }

    public class IGRequest{
      public String ReconcileDate;
      public String JobId;
    }

    public class IGResponse{
      public String Status;
      public String JobId;
      public String ErrorDetails;
      public List<IGReconcileObject> ReconciledObjects;
    }

    public class IGReconcileObject{
        
        public IGReconcileObject(String objName, String stat, String logURL){
          ObjectName = objName;
          Status = stat;
          LogFileURL = logURL;
        }
        
        public String ObjectName;
        public String Status;
        public String LogFileURL;
        public String ErrorDetails;
    }

    private static Object deserializeRequestTo(System.Type apexType, RestRequest request, String httpMethod){
      System.debug('Attempt to de-serialize a JSON string to an APEX type is made');
        
      String requestStr = '';
      String reconcileDate = (request.params != null && request.params.get('ReconcileDate') != null) ? request.params.get('ReconcileDate') : null;
        
      // only for the http GET method, the request body is available as a parameter in the URL
      if(httpMethod == 'GET'){
          requestStr = reconcileDate != null ? String.format('{"ReconcileDate" :"{0}"}', new List<String>{reconcileDate}) : '{"ReconcileDate" : null}';
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
}