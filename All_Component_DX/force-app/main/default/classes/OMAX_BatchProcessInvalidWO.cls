global without sharing class OMAX_BatchProcessInvalidWO implements Database.Batchable<SObject>, Database.Stateful
{
    global String strQuery = '';
    global Map<String, String> mapInvalidWOErrors = new Map<String, String>();
        
    global OMAX_BatchProcessInvalidWO(String strBadWorkOrderDetails, String strLogger)
    {
        system.debug('Invalid workorders and its error details as JSON...'+strBadWorkOrderDetails);
        SMAX_OptiMax_Engine_Ext clsOMaxExtension = new SMAX_OptiMax_Engine_Ext();
        mapInvalidWOErrors = clsOMaxExtension.doCreateWOErrorMap(mapInvalidWOErrors,strBadWorkOrderDetails,strLogger);
        
        if(mapInvalidWOErrors != null && mapInvalidWOErrors.size() > 0){
            List<String> woNames = new List<String>(mapInvalidWOErrors.keyset());
            String inClause = String.format( '(\'\'{0}\'\')',new List<String> { String.join( new List<String>(woNames), '\',\'') });
            system.debug('inCluase string for the query....'+inClause);
            strQuery = 'Select Id, Name, SVMXC__OptiMax_Error_Text__c, SVMXC__Violation_Message__c, SVMXC__Violation_Status2__c from SVMXC__Service_Order__c where Name in '+inClause;          
        }       
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
        List<SVMXC__Service_Order__c>  lstUpdateWO = new List<SVMXC__Service_Order__c>();
        try
        {
            if(lstWorkOrder != null && lstWorkOrder.size() > 0)
            {
                for(SVMXC__Service_Order__c objWO : lstWorkOrder)
                {
                    objWO.SVMXC__OptiMax_Error_Text__c = mapInvalidWOErrors.get(objWO.Name);    
                    objWO.SVMXC__Violation_Message__c = mapInvalidWOErrors.get(objWO.Name);
                    objWO.SVMXC__Violation_Status2__c = 'Unscheduled - Bad Data';   
                    lstUpdateWO.add(objWO);                
                }
            }
            system.debug('Updated Work Order list size: ' + lstUpdateWO.size() + '; List: ' + lstUpdateWO);
            update lstUpdateWO;
        }catch(exception ex){}          
        
    }
    
    global void finish(Database.BatchableContext BC)
    {
        system.debug('Finished Work Order list update....: ');
    }       
    
}