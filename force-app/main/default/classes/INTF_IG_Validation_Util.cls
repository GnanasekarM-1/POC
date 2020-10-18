/*****************************************************************************
*                       Copyright (C) 2018 ServiceMax, Inc
*                               All rights reserved
*
*****************************************************************************/

/**
* The class INTF_IG_Validation_Util -
*
* @author Naveen Koka
* @version V.02
* @since 2018
*/
/*****************************************************************************************************
*    ID        Name                     Date            Comment
*****************************************************************************************************
*              Naveen Koka                              Created. 
*           Soumyaranjan Pati       15th Oct 2018       Added CRUD/FLS check
*****************************************************************************************************/
public class INTF_IG_Validation_Util {

    public static INTF_IG_ServiceInterface.IGResponse validateRequest(INTF_IG_ServiceInterface.IGRequest request){
      String reconcileDate = request.reconcileDate;
      String jobId = request.jobId;
      INTF_IG_ServiceInterface.IGResponse response = null;
      if( jobId != null && jobId.length() > 0){
        response = validateJobId(jobId);
      }else if(reconcileDate == null || reconcileDate.length() == 0){
        response = createResponse('Failed', 'Please provide a reconcile date.');
      } else {
        try {
            Datetime dt = Datetime.valueOfGmt(reconcileDate.replace('T', ' '));
        } catch (Exception e) {
          response = createResponse('Failed', 'Reconcile Datetime is invalid. Please provide a valid Datetime string(Format: yyyy-MM-ddTHH:mm:ssZ).');
        }
      }
      return response;
    }

    private static INTF_IG_ServiceInterface.IGResponse validateJobId(String jobId){
        INTF_IG_ServiceInterface.IGResponse response = null;
        //Check Field Security Check
        List<String> queryFieldsDT = new List<String> {'Id', 'SVMXC__Status__c'};
        if( ! COMM_SecurityUtils.getInstance().verifyFieldAccess( 'SVMXC__SM_IG_Job_Request__c', queryFieldsDT, COMM_SecurityUtils.Access.Accessible ) ) {
            response = createResponse('Failed', System.Label.COMM001_TAG142); // COMM001_TAG142 - Insufficient permission to perform the operation. Please verify the object and field level permissions.
            return response;
        }
         //End of Check Field Security Check
        List<SVMXC__SM_IG_Job_Request__c> jobRequests = [Select Id, SVMXC__Status__c from SVMXC__SM_IG_Job_Request__c where Id =: jobId];
        
        if(jobRequests == null || jobRequests.size() == 0){
          response = createResponse('Failed', 'Invalid JobId.');
          return response;
        } 
        
        SVMXC__SM_IG_Job_Request__c jobRequest = jobRequests[0];
        if(jobRequest.SVMXC__Status__c == 'Completed'){
          response = createResponse('Success', 'The provided JobId is completed.');
        } else if(jobRequest.SVMXC__Status__c == 'In-Progress' || jobRequest.SVMXC__Status__c == 'Started'){
          response = createResponse('Success', 'The provided JobId is in-progress.');
        }
        return response;
    }

    private static INTF_IG_ServiceInterface.IGResponse createResponse(String jobStatus, String errorMessage){
        INTF_IG_ServiceInterface.IGResponse response = new INTF_IG_ServiceInterface.IGResponse();
        response.Status = jobStatus;
        response.ErrorDetails = errorMessage;
        return response;
    }

}