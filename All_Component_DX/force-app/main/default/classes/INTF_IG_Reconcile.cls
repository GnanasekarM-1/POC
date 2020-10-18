/*****************************************************************************
*                       Copyright (C) 2018 ServiceMax, Inc
*                               All rights reserved
*
*****************************************************************************/

/**
* The class INTF_IG_Reconcile -
*
* @author Naveen Koka
* @version V.02
* @since 2018
*/
/*****************************************************************************************************
*    ID        Name                     Date            Comment
*****************************************************************************************************
*              Naveen Koka          10th Aug 2018       Created. 
*           Soumyaranjan Pati       15th Oct 2018       Added CRUD/FLS check
*****************************************************************************************************/
public with sharing class INTF_IG_Reconcile {

    public static INTF_IG_ServiceInterface.IGResponse reconcileSVMX(INTF_IG_ServiceInterface.IGRequest request) {

        System.debug('Incoming Request: ' + request);
        INTF_IG_ServiceInterface.IGResponse response = INTF_IG_Validation_Util.validateRequest(request);
        if(response != null) return response;

        String reconcileJSON = INTF_IG_ReconcileMapping.getMappingJSON();
        List<INTF_IG_ReconcileMappingObject> reconList = (List<INTF_IG_ReconcileMappingObject>)JSON.deserializeStrict(reconcileJSON, List<INTF_IG_ReconcileMappingObject>.class);
        String jobId = createJobRequest(request);

        //reconcile date
        String reconcileDate = request.reconcileDate;
        String previousReconcileJobId = request.jobId;
        List<String> failedObjectNames = null;
        if(previousReconcileJobId != null){
            //get reconciled date
            reconcileDate = getReconciledDateFromJobId(previousReconcileJobId);
            //get failed objectNames
            failedObjectNames = getFailedObjectNames(previousReconcileJobId);
        }
        Map<String,Id> mapJobIdandBatchId = new Map<String,Id>();
        for(INTF_IG_ReconcileMappingObject reconObject : reconList){
          String baseObject = reconObject.baseobject;  
          if(failedObjectNames == null || failedObjectNames.contains(baseObject)){
            String recId = createJobRequestChild(jobId, baseObject);
            Id batchInstanceId = Database.executeBatch(new INTF_IG_Reconcile_Batch(reconObject, recId, reconcileDate));
            //updateJobRequestChild( recId , batchInstanceId);
            mapJobIdandBatchId.put(recId,batchInstanceId);
          } 
        }
        updateJobRequestChild(mapJobIdandBatchId);
        return createResponse(jobId, 'In-Progress', null);
    }

    private static String getReconciledDateFromJobId(String jobId){
        //Check Field Security Check
        List<String> queryFieldsDT = new List<String> {'Id', 'SVMXC__Status__c', 'SVMXC__Reconcile_From_Date__c'};
        if( ! COMM_SecurityUtils.getInstance().verifyFieldAccess( 'SVMXC__SM_IG_Job_Request__c', queryFieldsDT, COMM_SecurityUtils.Access.Accessible ) ) {
            throw new COMM_SecurityUtils.SecurityAccessException( System.Label.COMM001_TAG142 ); // COMM001_TAG142 - Insufficient permission to perform the operation. Please verify the object and field level permissions.
        }
         //End of Check Field Security Check
        List<SVMXC__SM_IG_Job_Request__c> jobRequests = [Select Id, SVMXC__Status__c, SVMXC__Reconcile_From_Date__c from SVMXC__SM_IG_Job_Request__c where Id =: jobId];
        return jobRequests.get(0).SVMXC__Reconcile_From_Date__c;
    }

    private static List<String> getFailedObjectNames(String jobId){
        //Check Field Security Check
        List<String> queryFieldsDT = new List<String> {'SVMXC__Object_Name__c', 'SVMXC__Status__c', 'SVMXC__IG_Job_Request__c'};
        if( ! COMM_SecurityUtils.getInstance().verifyFieldAccess( 'SVMXC__SM_IG_Job_Child__c', queryFieldsDT, COMM_SecurityUtils.Access.Accessible ) ) {
            throw new COMM_SecurityUtils.SecurityAccessException( System.Label.COMM001_TAG142 ); // COMM001_TAG142 - Insufficient permission to perform the operation. Please verify the object and field level permissions.
        }
         //End of Check Field Security Check
        List<SVMXC__SM_IG_Job_Child__c> jobRequestChilds = [Select SVMXC__Object_Name__c from SVMXC__SM_IG_Job_Child__c where SVMXC__IG_Job_Request__c=: jobId and SVMXC__Status__c='Failed'];
        List<String> failedObjectNames = new List<String>();
        for(SVMXC__SM_IG_Job_Child__c failedChild : jobRequestChilds){
            failedObjectNames.add(failedChild.SVMXC__Object_Name__c);
        }
        return failedObjectNames;
    }

    public static INTF_IG_ServiceInterface.IGResponse getStatus(String jobId){
        //Check Field Security Check
        List<String> queryFieldsDT = new List<String> {'Id', 'SVMXC__Object_Name__c', 'SVMXC__Status__c', 'SVMXC__Batch_Id__c', 'SVMXC__IG_Job_Request__c'};
        if( ! COMM_SecurityUtils.getInstance().verifyFieldAccess( 'SVMXC__SM_IG_Job_Child__c', queryFieldsDT, COMM_SecurityUtils.Access.Accessible ) ) {
            return createResponse('Failed', 'SVMXC__SM_IG_Job_Child__c '+System.Label.COMM001_TAG142, null); // COMM001_TAG142 - Insufficient permission to perform the operation. Please verify the object and field level permissions.
        }
         //End of Check Field Security Check
        
        Map<Id, SVMXC__SM_IG_Job_Child__c> jobRequestChilds = new Map<Id, SVMXC__SM_IG_Job_Child__c>();
        jobRequestChilds.putAll([Select Id, SVMXC__Object_Name__c, SVMXC__Status__c, 
                                          SVMXC__Batch_Id__c from SVMXC__SM_IG_Job_Child__c where SVMXC__IG_Job_Request__c=: jobId]);

        //get the file id's to send to client
        Map<String, String> linkEntityIdUrl = getFileLinks(jobRequestChilds.keySet());
        System.debug('Linked Entity URL: ' + linkEntityIdUrl);
                                        
        //Check Field Security Check
        List<String> queryFieldsDTIg = new List<String> {'Id', 'SVMXC__Status__c'};
        if( ! COMM_SecurityUtils.getInstance().verifyFieldAccess( 'SVMXC__SM_IG_Job_Request__c', queryFieldsDTIg, COMM_SecurityUtils.Access.Accessible ) ) {
            return createResponse('Failed', 'SVMXC__SM_IG_Job_Request__c ' + System.Label.COMM001_TAG142, null); // COMM001_TAG142 - Insufficient permission to perform the operation. Please verify the object and field level permissions.
        }
        //End of Check Field Security Check
        SVMXC__SM_IG_Job_Request__c jobRequest = [Select Id, SVMXC__Status__c from SVMXC__SM_IG_Job_Request__c where Id=: jobId];
      
        List<INTF_IG_ServiceInterface.IGReconcileObject> childUpdates = new List<INTF_IG_ServiceInterface.IGReconcileObject>();
        for(SVMXC__SM_IG_Job_Child__c child : jobRequestChilds.values()){
            childUpdates.add(new INTF_IG_ServiceInterface.IGReconcileObject(child.SVMXC__Object_Name__c, child.SVMXC__Status__c, linkEntityIdUrl.get(child.Id)));
        }
        System.debug('Child Updates: ' + childUpdates);
        return createResponse(jobId, jobRequest.SVMXC__Status__c, childUpdates);
    }

    private static Map<String, String> getFileLinks(Set<Id> entityIds){
        //get the content document id
        List<ContentDocumentLink> documentLinks = [SELECT LinkedEntityId, ContentDocumentId FROM ContentDocumentLink WHERE LinkedEntityId In: entityIds];
        Map<String, String> linkEntityIdUrl = new Map<String, String>();
        Map<String, String> contentDocIdLinkEntityId = new Map<String, String>();
        for(ContentDocumentLink link : documentLinks){
            contentDocIdLinkEntityId.put(link.ContentDocumentId, link.LinkedEntityId);
        }

        //get the content document version
        List<ContentVersion> documentsLatestVersion = [SELECT Id, ContentDocumentId FROM ContentVersion WHERE ContentDocumentId In: contentDocIdLinkEntityId.keySet() AND IsLatest = true];
        
        for(ContentVersion version : documentsLatestVersion){
            linkEntityIdUrl.put(contentDocIdLinkEntityId.get(version.ContentDocumentId), '/services/data/v43.0/sobjects/ContentVersion/' + version.Id + '/VersionData');
        }

        return linkEntityIdUrl;
    }

    private static INTF_IG_ServiceInterface.IGResponse createResponse(String jobId, String jobStatus, List<INTF_IG_ServiceInterface.IGReconcileObject> childUpdates){
        INTF_IG_ServiceInterface.IGResponse response = new INTF_IG_ServiceInterface.IGResponse();
        response.jobId = jobId;
        response.status = jobStatus;
        if(childUpdates != null){
          response.reconciledObjects = childUpdates;
        }
        return response;
    }
    
    private static String createJobRequest(INTF_IG_ServiceInterface.IGRequest request){
        SVMXC__SM_IG_Job_Request__c jobRequest = new SVMXC__SM_IG_Job_Request__c();
        jobRequest.SVMXC__Request__c = JSON.serialize(request);
        jobRequest.SVMXC__Status__c = 'Started';
        jobRequest.SVMXC__Reconcile_From_Date__c = request.ReconcileDate;
        if(COMM_SecurityUtils.getInstance().verifyFieldAccess(jobRequest, COMM_SecurityUtils.Access.Createable)){
            
            insert jobRequest;
            
        } else {
            throw new COMM_SecurityUtils.SecurityAccessException( System.Label.COMM001_TAG142 );
        }
        
        return jobRequest.Id;
    }
    
    private static String createJobRequestChild(String jobId, String objectName){
        SVMXC__SM_IG_Job_Child__c jobRequestChild = new SVMXC__SM_IG_Job_Child__c();
        jobRequestChild.SVMXC__IG_Job_Request__c = jobId;
        jobRequestChild.SVMXC__Object_Name__c = objectName;
        jobRequestChild.SVMXC__Status__c = 'Started';
        if(COMM_SecurityUtils.getInstance().verifyFieldAccess(jobRequestChild, COMM_SecurityUtils.Access.Createable)){
            
            insert jobRequestChild;
            
        } else {
            throw new COMM_SecurityUtils.SecurityAccessException( System.Label.COMM001_TAG142 );
        }
        return jobRequestChild.Id;
    }
    
    private static void updateJobRequestChild(String jobId, String batchId){
        //Check Field Security Check
        List<String> queryFieldsDTIg = new List<String> {'Id', 'SVMXC__Batch_Id__c'};
        if( ! COMM_SecurityUtils.getInstance().verifyFieldAccess( 'SVMXC__SM_IG_Job_Child__c', queryFieldsDTIg, COMM_SecurityUtils.Access.Accessible ) ) {
            throw new COMM_SecurityUtils.SecurityAccessException( System.Label.COMM001_TAG142 );
        }
        //End of Check Field Security Check
         
        SVMXC__SM_IG_Job_Child__c jobRequestChild = [Select SVMXC__Batch_Id__c from SVMXC__SM_IG_Job_Child__c where Id =: jobId];
        jobRequestChild.SVMXC__Batch_Id__c = batchId;
        
        if(COMM_SecurityUtils.getInstance().verifyFieldAccess(jobRequestChild, COMM_SecurityUtils.Access.Updateable)){
            
            update jobRequestChild;
            
        } else {
            throw new COMM_SecurityUtils.SecurityAccessException( System.Label.COMM001_TAG142 );
        }
        
        
    }
    private static void updateJobRequestChild(Map<String,Id> mapJobIdandBatchIds){
        
        List<SVMXC__SM_IG_Job_Child__c> lstIGJobChild = new List<SVMXC__SM_IG_Job_Child__c>();
        for(String igJobId : mapJobIdandBatchIds.keySet()){
            SVMXC__SM_IG_Job_Child__c tempSMjobId = new SVMXC__SM_IG_Job_Child__c();
            tempSMjobId.id = igJobId;
            tempSMjobId.SVMXC__Batch_Id__c = mapJobIdandBatchIds.get(igJobId);
            lstIGJobChild.add(tempSMjobId);
            
        }
        
        if(COMM_SecurityUtils.getInstance().verifyFieldAccess(lstIGJobChild, COMM_SecurityUtils.Access.Updateable)){
            if(lstIGJobChild.size() > 0)
            upsert lstIGJobChild;
            
        } else {
            throw new COMM_SecurityUtils.SecurityAccessException( System.Label.COMM001_TAG142 );
        }
        
        
    }
}