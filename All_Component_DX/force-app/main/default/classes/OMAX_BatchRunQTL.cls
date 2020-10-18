global without sharing class OMAX_BatchRunQTL implements Database.Batchable<SObject>, Database.Stateful
{
    global String strQuery = '';
    global String strDispatchProcID = '';
    global String strTerritoryID = '';
    global String strSVMXJobID = '';
    global String strOptimaxStatus = 'Processing Complete';
    global Datetime dtmNow = system.now();
    //Invalid work orders map
    global Map<String, String> mapInvalidWOErrors = new Map<String, String>();

    global OMAX_BatchRunQTL(String strDPId, String strTId, String strJobId)
    {
    	//Code commented due to reuse this class for invalid work order batch processing.	
        strDispatchProcID = strDPId;
        strTerritoryID = strTId;
        strSVMXJobID = strJobId;
        system.debug('Dispatch Process: ' + strDispatchProcID + '; Territory: ' + strTerritoryID + '; SVMX Job ID: ' + strSVMXJobID);

        /* Build a query to retrieve work orders belonging to the given territory that satisfy one of the following conditions:
         * a. Dispatch Process is null
         * b. Dispatch Process is not null, but it is not yet processed by OptiMax
         * c. Processed by OptiMax, but scheduled date time is in the future
         */
        strQuery = 'select id, SVMXC__Primary_Territory__c from SVMXC__Service_Order__c where SVMXC__Primary_Territory__c = :strTerritoryID AND (SVMXC__Dispatch_Process__c = null OR (SVMXC__Dispatch_Process__c = :strDispatchProcID AND (SVMXC__OptiMax_Status__c != :strOptimaxStatus OR SVMXC__Scheduled_Date_Time__c > :dtmNow)))';
    }

    global Database.QueryLocator start(Database.BatchableContext BC)
    {
        system.debug('Query: ' + strQuery);
        return Database.getQueryLocator(strQuery);
    }

    // Update all the work orders - set Dispatch Now & Batch Update to Yes to force run time pre-calc
    global void execute(Database.BatchableContext BC, List<sObject> lstSObject)
    {
    	//Code commented due to reuse this class for invalid work order batch processing.
        system.debug('sObjectList size: ' + lstSObject.size() + '; List: ' + lstSObject);
        List<SVMXC__Service_Order__c>  lstWorkOrder  = (List<SVMXC__Service_Order__c>)(lstSObject);

        // Do Qualified Technician Calculations
        map<Id, list<Id>> mapTerritoryWorkOrder = new map<Id, List<Id>>();
        map<Id, list<SVMXC__Service_Order__c>> mapTerritoryObjWorkOrder = new map<Id, List<SVMXC__Service_Order__c>>();
        SMAX_OptiMax_EngineUtils clsQTLComputation = new SMAX_OptiMax_EngineUtils();
        for(SVMXC__Service_Order__c oWO : lstWorkOrder)
        {
            if(oWO.SVMXC__Primary_Territory__c != NULL)
            {
                list<Id> lstWOIds = new list<Id>();
                if(mapTerritoryWorkOrder == NULL || !mapTerritoryWorkOrder.containsKey(oWO.SVMXC__Primary_Territory__c)){
                    mapTerritoryWorkOrder.put(oWO.SVMXC__Primary_Territory__c, NULL);
                }
                
                if(mapTerritoryWorkOrder.get(oWO.SVMXC__Primary_Territory__c) != NULL){
                    lstWOIds = mapTerritoryWorkOrder.get(oWO.SVMXC__Primary_Territory__c);
                }
                lstWOIds.add(oWO.Id);
                
                mapTerritoryWorkOrder.put(oWO.SVMXC__Primary_Territory__c, lstWOIds);
            }
        }
        // Qualified Technician list computation begins
        for(Id territoryId: mapTerritoryWorkOrder.keySet())
        {
            list<Id> lstWOIds = new list<Id>();
            lstWOIds = mapTerritoryWorkOrder.get(territoryId);
            if(lstWOIds != NULL || lstWOIds.size() > 0)
            {
                clsQTLComputation.getDispatchProcessProperties(strDispatchProcID);
                map<Id, SVMXC__Service_Order__c> mapQTLWorkOrders = clsQTLComputation.buildQualifiedTechnicians(lstWOIds, NULL, territoryId);
                if(mapQTLWorkOrders.size() > 0)
                    upsert mapQTLWorkOrders.values();
            }
        }
        // Qualified Technician list computation ends
    }

    // Get the batch id and check if the batch executed successfully or failed, and update the SVMX Job record accordingly
    global void finish(Database.BatchableContext BC)
    {
    	//Code commented due to reuse this class for invalid work order batch processing.
        String strBatchId = '';
        AsyncApexJob objAsyncJob;

		try
		{
	        if(BC != null && BC.getJobId() != null)
	            strBatchId = BC.getJobId();
	        if(strBatchId != null && strBatchId.length() > 0)
	            objAsyncJob = [Select Id, Status, NumberOfErrors, ExtendedStatus From AsyncApexJob WHERE ID =: strBatchId];
	        system.debug('Async Job for batch pre-calc run: ' + objAsyncJob);
	
	        SVMXC__SVMX_Jobs__c objSVMXJob = new SVMXC__SVMX_Jobs__c();
	        if(objAsyncJob != null && objAsyncJob.Status.touppercase() == 'COMPLETED' && strSVMXJobID != null && strSVMXJobID.length() > 0 && objAsyncJob.NumberOfErrors == 0)
	        {
	            objSVMXJob = [Select SVMXC__Status__c, SVMXC__OptiMax_Message__c, Id From SVMXC__SVMX_Jobs__c  where Id =: strSVMXJobID and SVMXC__OptiMax_Message__c = 'Running QTL'];
	            if(objSVMXJob != null)
	            {
	                objSVMXJob.SVMXC__Status__c = '201';
	                objSVMXJob.SVMXC__OptiMax_Message__c = 'QTL Completed';
	                update objSVMXJob;
	            }
	        }
	        else if (objAsyncJob != null && strSVMXJobID != null && strSVMXJobID.length() > 0 && objAsyncJob.NumberOfErrors > 0)
	        {
	            objSVMXJob = [Select SVMXC__Status__c, SVMXC__OptiMax_Message__c, Id From SVMXC__SVMX_Jobs__c  where Id = :strSVMXJobID];
	            if(objSVMXJob != null)
	            {
	                objSVMXJob.SVMXC__Status__c = '-7';
	                objSVMXJob.SVMXC__OptiMax_Message__c = 'QTL Failure: ' + String.valueOf(objAsyncJob.ExtendedStatus);
	                update objSVMXJob;
	            }
	        }
	        system.debug('SVMX Job Record: ' + objSVMXJob);
		}catch(exception ex){}
    }
}