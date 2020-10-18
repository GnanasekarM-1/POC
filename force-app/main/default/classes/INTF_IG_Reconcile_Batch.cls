/*****************************************************************************
*                       Copyright (C) 2018 ServiceMax, Inc
*                               All rights reserved
*
*****************************************************************************/

/**
* The class INTF_IG_Reconcile_Batch -
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
global class INTF_IG_Reconcile_Batch implements Database.Batchable<sObject>{
  global final String mapping;
  global final String baseQuery;
  global final String jobRequestChildId;
  final String externalIdFieldName;
  global final Map<String, List<String>> refObjectQueries;
  final String contentDocumentId;
  Map<String, String> baseRefFieldObjects;
  Map<String, String> fieldsToUpdate;

  global INTF_IG_Reconcile_Batch(INTF_IG_ReconcileMappingObject mapping, String jobRequestChildIdLocal, String reconcileDate){
    refObjectQueries = new Map<String, List<String>>();
    baseRefFieldObjects = new Map<String, String>();
    fieldsToUpdate = new Map<String, String>();
    externalIdFieldName = mapping.baseobject_uid_field;
    jobRequestChildId = jobRequestChildIdLocal;
    baseQuery = prepareQueries(mapping, reconcileDate);
    System.debug('Base Query: ' + baseQuery);
    System.debug('Refs Object Queries' + refObjectQueries);
    //create the log file here
    contentDocumentId = createLogFile('JobId, ExternalId, Message');
    createDocumentLink();

  }

  global Database.QueryLocator start(Database.BatchableContext BC){
      return Database.getQueryLocator(baseQuery);
  }

  global void execute(Database.BatchableContext BC, 
                       List<sObject> baseData){

    Map<String, Set<String>> objectExtIds = executeBaseObjectQueryForExtIds(baseData, baseRefFieldObjects);

    //query and collect all ref field ids
    Map<String, String> allFieldsRefIds = executeRefOjbectQueriesForSFIds(refObjectQueries, objectExtIds);

    //now update the base records
    updateBaseRecords(baseData, allFieldsRefIds, fieldsToUpdate);
  }

  global void finish(Database.BatchableContext BC){
    //Check the job child update the job as completed if it's in progress
    String jobRequestId = updateChildJobAndGetParentRequestId();

    //now check the parent job request and it's child for completion
    String jobRequestStatus = 'Completed';
    
    //Check Field Security Check
    List<String> queryFieldsDT = new List<String> {'Id', 'SVMXC__IG_Job_Request__c', 'SVMXC__Status__c'};
    if( ! COMM_SecurityUtils.getInstance().verifyFieldAccess( 'SVMXC__SM_IG_Job_Child__c', queryFieldsDT, COMM_SecurityUtils.Access.Accessible ) ) {
        throw new COMM_SecurityUtils.SecurityAccessException( System.Label.COMM001_TAG142 );
    }
    //End of Check Field Security Check

    List<SVMXC__SM_IG_Job_Child__c> jobRequestChilds = [Select Id,SVMXC__Status__c from SVMXC__SM_IG_Job_Child__c 
                                    where SVMXC__IG_Job_Request__c =: jobRequestId and (SVMXC__Status__c=: 'Started' or SVMXC__Status__c=: 'In-Progress' or SVMXC__Status__c=: 'Failed')];
    if(jobRequestChilds.size() > 0){
        if(jobRequestChilds[0].SVMXC__Status__c == 'Started' || jobRequestChilds[0].SVMXC__Status__c == 'In-Progress'){
            jobRequestStatus = 'In-Progress';
        }else{
            jobRequestStatus = jobRequestChilds[0].SVMXC__Status__c;
        }
        
    }

    
    //now update the job request based on the child status
    SVMXC__SM_IG_Job_Request__c jobRequest = new SVMXC__SM_IG_Job_Request__c();
      jobRequest.id = jobRequestId;
    jobRequest.SVMXC__Status__c = jobRequestStatus;
    
    if(COMM_SecurityUtils.getInstance().verifyFieldAccess(jobRequest, COMM_SecurityUtils.Access.Updateable)){
        
        update jobRequest;
        
    } else {
        throw new COMM_SecurityUtils.SecurityAccessException( System.Label.COMM001_TAG142 );
    }
    
  }

  //update the child job
  private String updateChildJobAndGetParentRequestId(){
    //Check Field Security Check
    List<String> queryFieldsDTIg = new List<String> {'Id', 'SVMXC__Status__c', 'SVMXC__IG_Job_Request__c'};
    if( ! COMM_SecurityUtils.getInstance().verifyFieldAccess( 'SVMXC__SM_IG_Job_Child__c', queryFieldsDTIg, COMM_SecurityUtils.Access.Accessible ) ) {
        throw new COMM_SecurityUtils.SecurityAccessException( System.Label.COMM001_TAG142 );
    }
    //End of Check Field Security Check
    SVMXC__SM_IG_Job_Child__c job = [Select Id, SVMXC__Status__c, SVMXC__IG_Job_Request__c from SVMXC__SM_IG_Job_Child__c where id=: jobRequestChildId];
    if(job.SVMXC__Status__c == 'In-Progress' || job.SVMXC__Status__c == 'Started'){
      job.SVMXC__Status__c = 'Completed';
      if(COMM_SecurityUtils.getInstance().verifyFieldAccess(job, COMM_SecurityUtils.Access.Updateable)){
            
            update job;
            
        } else {
            throw new COMM_SecurityUtils.SecurityAccessException( System.Label.COMM001_TAG142 );
        }
      
    }
    return job.SVMXC__IG_Job_Request__c;
  }

  private void updateChildJob(String status){
      //Check Field Security Check
    List<String> queryFieldsDTIg = new List<String> {'Id', 'SVMXC__Status__c', 'SVMXC__IG_Job_Request__c'};
    if( ! COMM_SecurityUtils.getInstance().verifyFieldAccess( 'SVMXC__SM_IG_Job_Child__c', queryFieldsDTIg, COMM_SecurityUtils.Access.Accessible ) ) {
        throw new COMM_SecurityUtils.SecurityAccessException( System.Label.COMM001_TAG142 );
    }
    //End of Check Field Security Check
    SVMXC__SM_IG_Job_Child__c job = [Select Id, SVMXC__Status__c, SVMXC__IG_Job_Request__c from SVMXC__SM_IG_Job_Child__c where id=: jobRequestChildId];
    job.SVMXC__Status__c = status;
    if(COMM_SecurityUtils.getInstance().verifyFieldAccess(job, COMM_SecurityUtils.Access.Updateable)){
            
            update job;
            
        } else {
            throw new COMM_SecurityUtils.SecurityAccessException( System.Label.COMM001_TAG142 );
        }
   
  }

  //update base records with actual id's
  private void updateBaseRecords(List<SObject> baseData, 
                                              Map<String, String> allFieldsRefIds, Map<String, String> fieldsToUpdate){
    for(SObject currRec : baseData){
      for(String refFieldName : fieldsToUpdate.keySet()){
        String refFieldValue = (String)currRec.get(refFieldName);
        currRec.put(fieldsToUpdate.get(refFieldName), allFieldsRefIds.get(refFieldValue));
      }
    }
    System.debug('Base data with updated: ' + baseData);
    if(!COMM_SecurityUtils.getInstance().verifyFieldAccess(baseData, COMM_SecurityUtils.Access.Updateable)){
            
        throw new COMM_SecurityUtils.SecurityAccessException( System.Label.COMM001_TAG142 );
            
    }
    Database.SaveResult[] SaveResultList = Database.update(baseData, false);
    processUpdateResults(SaveResultList, baseData);
  }

  private void processUpdateResults(Database.SaveResult[] SaveResultList, List<SObject> baseData){
    List<String> logData = new List<String>();
    boolean isSuccess = true;
    for(integer i = 0; i < SaveResultList.size(); i++){
      String msg = baseData.get(i).id ;
      msg = msg + ',' + baseData.get(i).get(externalIdFieldName);
      If(!SaveResultList[i].isSuccess()){
          msg += ',';        
          for(Database.Error err: SaveResultList[i].getErrors()){  
              msg += err.getmessage();
          }
          isSuccess = false;
      }else{
        //msg = msg + ',' + '5h5oGRVwDXxnd3NUdd8imOixVYxLkYO3efouuxtarbjRVqLSmQlEWuOHLT7obzm3wH7lKcUlmLcbNCIXE0vBGV9nFWcha6xtCzFNAPs5Yn4DNZsOb6fptERtRqVlxSD8gNMre2ItlMHXEBk1AlYWeKwI6gZu6qDlxiujAbWfgh1JU5jlRfEgirj4cERrtnNipABWpgFK5OtdQRXoww3xZi93KgbcxE5QM8lSCoHp8zdUK8Hfecflwx6Vg34hMsZCzwdwoLWl1bZBi18RbGfOxkw1ONuUk64NxuvkNua2p6rwIEyjXdxk9VjCgIEzZOesaADbMRxiAAfU6chNGPP9eP76UBoTTIvVjnlWkRzirHSOiriCLNT4cCEKZVoTG870c4TyQDKcPIOg19Wf6v2Ou5mR8wmGNSTAG0giYTYLNVexKfCHjQVlaM2Vx8cmedUzZBGCza1rdp4JPFl4s5TeQGSaeAIfYP6gGeFmbe071lQxAIqLXZzczBkC9cLknMKicfbUyOGdHVBh8I16b0kqnjQZ30WziER607WwuQwtrgg7SGiBJIzXuzNTBmpVIjmkhDlo6mhSRfeYafiYCFqDRfhVPHNv3CBJ6Brr1eXit1D5OvavZxb8B7GnKSF6IB4XyeinT3kG1H3PWfS1hG7h7pu41UAd53YxhLyjUZhLgOzZJa9Ro62jNsDmnKRg4U9TrHXteoNsc0Onx11Q7M7phhXrkAOR7GaKuiekAdmo9lkqp7yWPAqu7SoihmesZkrm8D2YuQKMRhPkXChMIoCQ28kRFUsAihEyC81Z9KEsowpJOVhfTDI54kjZOVy5WE8z1LCeQj75Pb9XncgmmpIuzfbbJPonz2kHl0gCwZj7qVNfdJS7hbe9nHhzN4lauRKXfJXl6q7e4B2qR3ogAzOKT6NZHHQnTXKQkfBxttO641Uz48WZNi3odo9MKdGMtSLxaU83fgdVzSj2Gmdw3gj638sh26nPwX5GtUOvDj0e';
      }
      logData.add(msg);
    }
    
    //now upadate the child job as failed
    if(!isSuccess) updateChildJob('Failed');

    //now update the file with the exception list.
    createLogFile('\n' + string.join(logData,'\n'));
  }

  private String createLogFile(String errorMessage){
    Blob content = Blob.valueof(errorMessage);
    //get the existing version body data and append
    if(contentDocumentId != null){
      ContentVersion contentLatestFile = [SELECT VersionData FROM ContentVersion WHERE ContentDocumentId =: contentDocumentId AND IsLatest = true];
      String combinedDataAsHex = EncodingUtil.convertToHex(contentLatestFile.VersionData) + EncodingUtil.convertToHex(content);
      content = EncodingUtil.convertFromHex(combinedDataAsHex);
    }
    
    ContentVersion cv = new ContentVersion();
    cv.ContentLocation = 'S';
    cv.PathOnClient = jobRequestChildId + '.csv';
    cv.Title = jobRequestChildId;
    cv.VersionData = content;
    
    if(contentDocumentId != null){
      cv.ContentDocumentId = contentDocumentId;
    }
    insert cv;

    if(contentDocumentId == null){
      return [SELECT Id, ContentDocumentId FROM ContentVersion WHERE Id =: cv.Id].ContentDocumentId;
    }
    return null;
  }

  private void createDocumentLink(){
    ContentDocumentLink cdl = new ContentDocumentLink();
    cdl.ContentDocumentId = contentDocumentId;
    cdl.LinkedEntityId = jobRequestChildId;
    cdl.ShareType = 'I';
    insert cdl;
  }

  private string prepareQueries(INTF_IG_ReconcileMappingObject mappingObject, String reconcileDate){
     
    List<INTF_IG_ReconcileMappingObject.ReconcileMappingField> mappingFieldsInfo = 
                                                                            mappingObject.fields_to_update;
    String baseQuery = '';
    for(INTF_IG_ReconcileMappingObject.ReconcileMappingField currMappingField : mappingFieldsInfo){
        //query to fetch external id values for all reference mapped fields
        String baseRefUidField = currMappingField.baseobject_field_reference_uid;
        baseQuery += baseRefUidField + ', ';
        fieldsToUpdate.put(baseRefUidField, currMappingField.baseobject_field_to_update);

        //Store refUID field and its ref object for retrieval and process
        String refObjectName = currMappingField.referenceobject;
        baseRefFieldObjects.put(baseRefUidField, refObjectName);

        //query to fetch sfid values for external id's
        if(!refObjectQueries.keySet().contains(refObjectName)){
            String refObjectField = currMappingField.referenceobject_uid_field;
            List<String> fillers = new List<String>{refObjectName, refObjectField};
            //for objectname add the query and field. which will be used to query and retrieve results.
            refObjectQueries.put(refObjectName, new List<String> {String.format('Select Id, {1} from {0} where {1} in ', fillers), refObjectField});
        }
    }

    String whereClause = ' where CreatedDate >= ' + reconcileDate;
    
    return String.format('Select {0},{1} from {2}{3} and {0} != null Order By Id', new List<String>{externalIdFieldName, baseQuery.removeEnd(', '), mappingObject.baseobject, whereClause});
   }

  //execute base query, retreive ext ids for refernce fields and put it w.r.t ref object name
  private Map<String, Set<String>> executeBaseObjectQueryForExtIds(List<SObject> baseData, Map<String, String> baseRefFieldObjects){
    Map<String, Set<String>> objectExtIds = new Map<String, Set<String>>();
    for(SObject record: baseData){
      for(String refField : baseRefFieldObjects.keySet()){
        String objectName = baseRefFieldObjects.get(refField);
        if(!objectExtIds.keySet().contains(objectName)){
          objectExtIds.put(objectName, new Set<String>());
        }
        objectExtIds.get(objectName).add((String)record.get(refField));
      }
    }
    return objectExtIds;
  }

  //execute ref queries, retrieve id for extid's
  private Map<String, String> executeRefOjbectQueriesForSFIds(Map<String, List<String>> refObjectQueries, Map<String, Set<String>> objectExtIds){
    Map<String, String> allFieldsRefIds = new Map<String, String>();
    for(String refObject : refObjectQueries.keySet()){
      Set<String> extIds = objectExtIds.get(refObject);
      List<String> queryFields = refObjectQueries.get(refObject);
      String refObjectQuery = queryFields.get(0) + ':extIds';
      System.debug(refObjectQuery + ':' + objectExtIds);
      if(extIds != null && extIds.size() > 0){
        List<SObject> refRecords = Database.Query(refObjectQuery);
        collectRefIds(refRecords, allFieldsRefIds, queryFields.get(1));
      }
    }
    System.debug('Reference Fields Id and Values: ' + allFieldsRefIds);
    return allFieldsRefIds;
  }

  private void collectRefIds(List<SObject> refRecords, Map<String, String> allFieldsRefIds, String fieldName){
    for(SObject refRec: refRecords){
        String fieldValue = (String)refRec.get(fieldName);
        if(fieldValue != null)
        {
          allFieldsRefIds.put(fieldValue, (String)refRec.get('id'));
        }
    }
  }

}