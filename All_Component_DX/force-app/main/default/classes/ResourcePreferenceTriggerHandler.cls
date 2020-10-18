public class ResourcePreferenceTriggerHandler {
    //This method fecthes all the resourcePreference records with the Technician Id as passed in the input parameter.
    public static List<Resource_Preference__c> getAllRes(Set<Id> techId){
        List<Resource_Preference__c> lstReturnRes = new List<Resource_Preference__c>();
        String strTrigQuery = '';
        try{
            if(WORD_Service_Order_Resources.getResourcePreferenceSetting()){
                // Using a single database query, find all the technicians in the database that have the same Company, Component or Site as any  of the technicians being inserted or updated.
                strTrigQuery = 'SELECT ' + WORD_Service_Order_Resources.fetchQueryFields('SVMXC__Resource_Preference__c' ,true)
                                        + ' FROM SVMXC__Resource_Preference__c '
                                        +  ' WHERE SVMXC__Group_Member__c IN :techId';
                WSCH_AuditLogger.debug('ResourcePreferenceTriggerHandler Query: ' + strTrigQuery);
                lstReturnRes =  Database.query(strTrigQuery);
            }
        }catch(exception ex){
            String exceptionMsg = 'ResourcePreferenceTriggerHandler :: getAllRes';
            WSCH_AuditLogger.error(exceptionMsg+ex.getMessage() + '\n Stack Trace:: ' + ex.getStackTraceString());
        }
        return lstReturnRes;
    }
    //This method prevents duplicate Resource Preference record.
    public static void checkResPrefList (List<Resource_Preference__c> lstAllResPref, List<Resource_Preference__c> lstResPref, String triggerMode){
        if(triggerMode == 'beforeInsert'){
            try{
                //for displaying error message when there are duplicate records in the insert context
                for (Integer i=0; i<lstResPref.size();i++){
                    for (Integer j=0; j<lstResPref.size();j++){
                        if(i!=j){
                            if(((lstResPref[i].SVMXC__Component__c != null) && (lstResPref[j].SVMXC__Component__c != null) && (lstResPref[i].SVMXC__Component__c == lstResPref[j].SVMXC__Component__c) && (lstResPref[i].SVMXC__Group_Member__c == lstResPref[j].SVMXC__Group_Member__c)) || ((lstResPref[i].SVMXC__Company__c != null) && (lstResPref[j].SVMXC__Company__c != null) && (lstResPref[i].SVMXC__Company__c == lstResPref[j].SVMXC__Company__c) && (lstResPref[i].SVMXC__Group_Member__c == lstResPref[j].SVMXC__Group_Member__c)) || ((lstResPref[i].SVMXC__Site__c != null) && (lstResPref[j].SVMXC__Site__c != null) && (lstResPref[i].SVMXC__Site__c == lstResPref[j].SVMXC__Site__c) && (lstResPref[i].SVMXC__Group_Member__c == lstResPref[j].SVMXC__Group_Member__c))){                     
                                lstResPref[i].SVMXC__Group_Member__c.addError(Label.DCON003_TAG080);
                            }
                        }
                    }
                }
                //for displaying error message when there are duplicate records existing in the system 
                for (Resource_Preference__c tech : lstAllResPref) {
                    for (Resource_Preference__c newTech : lstResPref) {
                        //Check if the same Technician-Company record is already existing.
                        if((newTech.SVMXC__Company__c == tech.SVMXC__Company__c) && (newTech.SVMXC__Company__c != null) && (tech.SVMXC__Company__c != null) && (newTech.SVMXC__Group_Member__c == tech.SVMXC__Group_Member__c)){
                            //newTech.SVMXC__Company__c.addError(Label.DCON003_TAG082);
                            newTech.SVMXC__Group_Member__c.addError(Label.DCON003_TAG080);
                        }
                        //Check if the same Technician-Component record is already existing.
                        if((newTech.SVMXC__Component__c == tech.SVMXC__Component__c) && (newTech.SVMXC__Component__c != null) && (tech.SVMXC__Component__c != null) && (newTech.SVMXC__Group_Member__c == tech.SVMXC__Group_Member__c)){
                            //newTech.SVMXC__Component__c.addError(Label.DCON003_TAG080);
                            newTech.SVMXC__Group_Member__c.addError(Label.DCON003_TAG080);
                        }
                        //Check if the same Technician-Site record is already existing.
                        if((newTech.SVMXC__Site__c == tech.SVMXC__Site__c) && (newTech.SVMXC__Site__c != null) && (tech.SVMXC__Site__c != null) && (newTech.SVMXC__Group_Member__c == tech.SVMXC__Group_Member__c)){
                            //newTech.SVMXC__Site__c.addError(Label.DCON003_TAG081);
                            newTech.SVMXC__Group_Member__c.addError(Label.DCON003_TAG080);
                        }
                    }
                }
            }catch(exception ex){
                String exceptionMsg = 'ResourcePreferenceTriggerHandler :: checkInsertResList';
                WSCH_AuditLogger.error(exceptionMsg+ex.getMessage() + '\n Stack Trace:: ' + ex.getStackTraceString());
            }
        }   
        if(triggerMode == 'beforeUpdate'){
            Boolean boolAddError;
            try{
                for (Resource_Preference__c newTech : lstResPref) {
                    for (Resource_Preference__c tech : lstAllResPref) {
                        
                        boolAddError = false;
                        //Check if the same Technician-Company record is already existing.
                        if(((newTech.SVMXC__Company__c != null) && (tech.SVMXC__Company__c != null) && (newTech.SVMXC__Company__c == tech.SVMXC__Company__c) && (newTech.SVMXC__Group_Member__c == tech.SVMXC__Group_Member__c)) || ((newTech.SVMXC__Component__c != null) && (tech.SVMXC__Component__c != null) && (newTech.SVMXC__Component__c == tech.SVMXC__Component__c) && (newTech.SVMXC__Group_Member__c == tech.SVMXC__Group_Member__c)) || ((newTech.SVMXC__Site__c != null) && (tech.SVMXC__Site__c != null) && (newTech.SVMXC__Site__c == tech.SVMXC__Site__c) && (newTech.SVMXC__Group_Member__c == tech.SVMXC__Group_Member__c))){
                            boolAddError = true;                
                            if(newTech.Id == tech.Id){
                                boolAddError = false;
                            }
                        }
                        if(boolAddError){
                            newTech.SVMXC__Group_Member__c.addError(Label.DCON003_TAG080);
                        }
                    }
                }
            }catch(exception ex){
                String exceptionMsg = 'ResourcePreferenceTriggerHandler :: checkUpdateResList';
                WSCH_AuditLogger.error(exceptionMsg+ex.getMessage() + '\n Stack Trace:: ' + ex.getStackTraceString());
            }       
        }
    }
}