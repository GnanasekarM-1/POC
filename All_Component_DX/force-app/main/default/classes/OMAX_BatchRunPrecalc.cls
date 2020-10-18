global without sharing class OMAX_BatchRunPrecalc implements Database.Batchable<SObject>, Database.Stateful
{
    global String strQuery = '';
    global String strDispatchProcID = '';
    global String strTerritoryID = '';
    global String strSVMXJobID = '';
    global String strOptimaxStatus = 'Processing Complete';
    global Datetime dtmNow = system.now();

    global OMAX_BatchRunPrecalc(String strDPId, String strTId, String strJobId)
    {
        strDispatchProcID = strDPId;
        strTerritoryID = strTId;
        strSVMXJobID = strJobId;
        system.debug('Dispatch Process: ' + strDispatchProcID + '; Territory: ' + strTerritoryID + '; SVMX Job ID: ' + strSVMXJobID);

        /* Build a query to retrieve work orders belonging to the given territory that satisfy one of the following conditions:
         * a. Dispatch Process is null
         * b. Dispatch Process is not null, but it is not yet processed by OptiMax
         * c. Processed by OptiMax, but scheduled date time is in the future
         */
        strQuery = 'select id, Name, SVMXC__Dispatch_Now__c, SVMXC__Dispatch_Process__c, SVMXC__BatchUpdate__c, SVMXC__Primary_Territory__c, SVMXC__OptiMax_Status__c, SVMXC__Scheduled_Date_Time__c from SVMXC__Service_Order__c where SVMXC__Primary_Territory__c = :strTerritoryID AND (SVMXC__Dispatch_Process__c = null OR (SVMXC__Dispatch_Process__c = :strDispatchProcID AND (SVMXC__OptiMax_Status__c != :strOptimaxStatus OR SVMXC__Scheduled_Date_Time__c > :dtmNow)))';
    }

    global Database.QueryLocator start(Database.BatchableContext BC)
    {
        system.debug('Query: ' + strQuery);
        return Database.getQueryLocator(strQuery);
    }

    // Update all the work orders - set Dispatch Now & Batch Update to Yes to force run time pre-calc
    global void execute(Database.BatchableContext BC, List<sObject> lstSObject)
    {
        system.debug('sObjectList size: ' + lstSObject.size() + '; List: ' + lstSObject);
        List<SVMXC__Service_Order__c>  lstWorkOrder  = (List<SVMXC__Service_Order__c>)(lstSObject);
        List<SVMXC__Service_Order__c>  lstUpdateW0 = new List<SVMXC__Service_Order__c>();
        
		try
		{
	        if(lstWorkOrder != null && lstWorkOrder.size() > 0)
	        {
	            for(SVMXC__Service_Order__c WO : lstWorkOrder)
	            {
	                //if(WO.SVMXC__OptiMax_Status__c != strOptimaxStatus)
	                    //WO.SVMXC__Dispatch_Process__c = null;
	                WO.SVMXC__Dispatch_Now__c = 'Yes';      
	                Wo.SVMXC__BatchUpdate__c = 'Yes';
	                lstUpdateW0.add(WO);                
	            }
	        }
	        system.debug('Updated Work Order list size: ' + lstUpdateW0.size() + '; List: ' + lstUpdateW0);
	        update lstUpdateW0;
        }catch(exception ex){}
    }

    // Get the batch id and check if the batch executed successfully or failed, and update the SVMX Job record accordingly
    global void finish(Database.BatchableContext BC)
    {
        String strBatchId = '';
        AsyncApexJob objAsyncJob;

        if(BC != null && BC.getJobId() != null)
            strBatchId = BC.getJobId();
        if(strBatchId != null && strBatchId.length() > 0)
            objAsyncJob = [Select Id, Status, NumberOfErrors, ExtendedStatus From AsyncApexJob WHERE ID =: strBatchId];
        system.debug('Async Job for batch pre-calc run: ' + objAsyncJob + strSVMXJobID);

        SVMXC__SVMX_Jobs__c objSVMXJob = new SVMXC__SVMX_Jobs__c();
        if(objAsyncJob != null && objAsyncJob.Status.touppercase() == 'COMPLETED' && strSVMXJobID != null && strSVMXJobID.length() > 0 && objAsyncJob.NumberOfErrors == 0)
        {
            objSVMXJob = [Select SVMXC__Status__c, SVMXC__OptiMax_Message__c, Id From SVMXC__SVMX_Jobs__c  where Id =: strSVMXJobID and SVMXC__OptiMax_Message__c = 'Running Precalc'];
            if(objSVMXJob != null)
            {
                objSVMXJob.SVMXC__Status__c = '101';
                objSVMXJob.SVMXC__OptiMax_Message__c = 'Precalc Completed';
                update objSVMXJob;
            }   
        }
        else if (objAsyncJob != null && strSVMXJobID != null && strSVMXJobID.length() > 0 && objAsyncJob.NumberOfErrors > 0)
        {
            objSVMXJob = [Select SVMXC__Status__c, SVMXC__OptiMax_Message__c, Id From SVMXC__SVMX_Jobs__c  where Id = :strSVMXJobID];
            if(objSVMXJob != null)
            {
                objSVMXJob.SVMXC__Status__c = '-6';
                objSVMXJob.SVMXC__OptiMax_Message__c = 'Precalc Failure: ' + String.valueOf(objAsyncJob.ExtendedStatus);
                update objSVMXJob;
            }
        }
        system.debug('SVMX Job Record: ' + objSVMXJob);
    }
}