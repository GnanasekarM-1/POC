/* Security Scanned */
public with sharing class SFM_ProcessNodeObjects
{
    public list<SVMXC__ServiceMax_Processes__c> ProcessNodeObjects = new list<SVMXC__ServiceMax_Processes__c>();
    public List<RecordType> RecordTypeList = new List<RecordType>(); 
    public String ProcessNodeObjRTypeID = '';
    public SFM_processNodeObjects()
    {
        //SDL-SVMX-FLS-NOT-ENFORCED-META-DATA
        /*RecordTypeList = [Select SystemModstamp, SobjectType, NamespacePrefix, Name, LastModifiedDate, LastModifiedById, IsActive, Id, DeveloperName, Description, CreatedDate, CreatedById, BusinessProcessId From RecordType where SobjectType = 'SVMXC__ServiceMax_Processes__c'];
        if(RecordTypeList.size() > 0)
        {
            for(RecordType r : RecordTypeList)
            {
                if(r.Name == 'Process Node Objects') 
                {
                    ProcessNodeObjRTypeID = r.id;
                }
            }
        }*/
        Map<String,Id> mapRecordTypeDetails = COMM_RecordTypeUtilities.getObjectRecordTypeId('SVMXC__ServiceMax_Processes__c',new List<String> {'Process_Node_Objects'});
        ProcessNodeObjRTypeID = mapRecordTypeDetails.get('Process_Node_Objects');
    }
    public list<SVMXC__ServiceMax_Processes__c> getPocessNodeObjects(String ProcessId)
    {
        if(ProcessId != null)
        //SDL-SVMX-FLS-NOT-ENFORCED-META-DATA
            ProcessNodeObjects = [Select Name,SVMXC__ProcessID__c,SVMXC__Type__c,SVMXC__Node_Parent__c,SVMXC__Source_Object_Name__c,SVMXC__Target_Object_Name__c,SVMXC__Submodule__c,SVMXC__Module__c,SVMXC__Sequence__c,SVMXC__Process__c,SVMXC__Node_Source_Object_API__c,SVMXC__Target_Object_label__c,SVMXC__IsStandard__c,SVMXC__IsStandalone__c  From SVMXC__ServiceMax_Processes__c where RecordType.DeveloperName = 'Process_Node_Objects' and SVMXC__Process__c =: ProcessId];    
        return ProcessNodeObjects;
    }
}