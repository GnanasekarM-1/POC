/**
 * The SFM_ScheduledSFM_Utils is a Utility class that fetches Process and Process Node records
 * and stores them in static variables.
 * 
 *
 * @author Anush R G
 * @version 
 * @since 2016
 */
/*****************************************************************************************************
 *    ID        Name                   Date            Comment
 *****************************************************************************************************
 *              Anush R G               05 Aug 2016     Created.
 *****************************************************************************************************/
public class SFM_ScheduledSFM_Utils {
    
    public static list<SVMXC__ServiceMax_Processes__c> processList;
    public static SVMXC__ServiceMax_Processes__c SFMProcess;
    public static list<SVMXC__ServiceMax_Processes__c> processNodeList;
    public static String processId;
    
    public SFM_ScheduledSFM_Utils(){
    
    }
    
    // This method returns a List of SVMX Process records which are of type 'Target Manager' or 'Process Node' for the given process Id
    // To-Do: detailed comments, where and why it is used. Analysis on performance b/w old and new code. Try catch. Exceptions on number of records retreived
    // debug on Limits
    public static list<SVMXC__ServiceMax_Processes__c> querySFMProcess(String strProcessId){
    
        processList = [Select SVMXC__Type__c, RecordType.Name, SVMXC__Target_Record_Type__c,SVMXC__Dispatch_Process_Status__c, SVMXC__Target_Object_label__c, SVMXC__End_Date__c,
                              SVMXC__Target_Object_Name__c, SVMXC__Submodule__c, SVMXC__SubmoduleID__c, SVMXC__Source_Object_Name__c, SVMXC__Settings_Name__c, 
                              SVMXC__Setting_Unique_ID__c, SVMXC__SettingID__c, SVMXC__Sequence__c, SVMXC__Search_Order__c, SVMXC__Rule_Type__c, SVMXC__Purpose__c, 
                              SVMXC__Process__c, SVMXC__ProcessID__c,SVMXC__Parent_Object__c, SVMXC__Parent_Object_Criteria__c, SVMXC__Parent_Error_Msg__c,
                              SVMXC__Parent_Column_Name__c, SVMXC__Page_Layout__c, SVMXC__Node_Source_Object_API__c,SVMXC__Node_Parent_API__c,SVMXC__IsStandalone__c,
                              SVMXC__Node_Parent__c, SVMXC__Name__c, SVMXC__Module__c, SVMXC__ModuleID__c,SVMXC__MapID__c, SVMXC__MTTS_Minutes__c,SVMXC__IsStandard__c, 
                              SVMXC__IsPrivate__c, SVMXC__IsDefault__C,SVMXC__Final_Exception_Process__c, SVMXC__Expertise_Match_Enabled__c,SVMXC__Email_On_Success__c, 
                              SVMXC__Email_On_Error__c,SVMXC__Dispatch_Method__c, SVMXC__Description__c,SVMXC__Default_Value__c, SVMXC__Data_Type__c, SVMXC__Installation_Key__c,
                              SVMXC__Child_Object_Criteria__c,SVMXC__Advance_Expression__c, SVMXC__Active__c, RecordTypeId, OwnerId, Name, Id, CreatedDate, CreatedById,
                              SVMXC__Parent_Object__r.SVMXC__Type__c,SVMXC__Parent_Object__r.SVMXC__Parent_Column_Name__c,SVMXC__Values__c,SVMXC__Module__r.SVMXC__Source_Object_Name__c,
                              SVMXC__Module__r.SVMXC__Target_Object_Name__c, SVMXC__Submodule__r.SVMXC__Parent_Object_Criteria__c, SVMXC__Submodule__r.SVMXC__Source_Object_Name__c,
                              SVMXC__Child_Error_Msg__c,LastModifiedDate, LastModifiedById, LastActivityDate, IsDeleted
                        FROM SVMXC__ServiceMax_Processes__c 
                        WHERE (RecordType.Name = 'Target Manager' and SVMXC__ProcessID__c =: strProcessId ) or (RecordType.Name = 'Process Node Objects' and SVMXC__Process__r.SVMXC__ProcessID__c =: strProcessId)];
        
        return processList;
        
        }   
}