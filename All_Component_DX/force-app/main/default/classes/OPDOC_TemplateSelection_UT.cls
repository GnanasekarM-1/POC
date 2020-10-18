/*
 * Unit Test class for OPDOC_TemplateSelection Controller Class
 * 
 */
@isTest()
class OPDOC_TemplateSelection_UT {
    static Map<String,Id> recordTypeMap = new Map<String,Id>(); 
    
    /*
     * Test method for positive scenario
     */ 
    static testmethod void OPDOC_TemplateSelection_testMethod(){
        getAllRecordtypes();
        Id woId = createWOTestRecord();
        Id targetManagerRecID = createTargetManagerRec();
        Id procesNodeRecID = createProcessNodeRec(targetManagerRecID);
        ApexPages.currentPage().getParameters().put('SVMX_processId',woId);
        
        test.startTest();
        OPDOC_TemplateSelection opdocCls = new OPDOC_TemplateSelection();
        System.assert(opdocCls.docWrapperList.size() > 0,'Error - No Templates found');
        opdocCls.getTag001();
        opdocCls.getTag003();
        opdocCls.getTag004();
        opdocCls.getTag005();
        opdocCls.Cancel();
        test.stopTest();
    }   
    
    /*
     * Creates Test record for Work Order 
     */
    static Id createWOTestRecord(){
        SVMXC__Service_Order__c wO = new SVMXC__Service_Order__c();
        wO.SVMXC__Order_Status__c = 'New';
        insert wO;
        return wO.Id;
    }
    
    /*
     * Creates Servicemax Process record of record type 'Target Manager'
     * for outputdoc. 
     */ 
    static Id createTargetManagerRec(){
        SVMXC__ServiceMax_Processes__c processRec = new SVMXC__ServiceMax_Processes__c();
        processRec.SVMXC__Name__c = 'Test OutputDoc';
        processRec.SVMXC__Rule_Type__c = 'Interactive';
        processRec.SVMXC__ProcessID__c = 'Test_OutputDoc';
        processRec.SVMXC__Purpose__c = 'OUTPUT DOCUMENT';
        processRec.RecordTypeId = recordTypeMap.get('Target Manager');
        insert processRec;
        return processRec.Id; 
    }
    
    /*
     * Creates Servicemax Process record of record type 'Process Node Objects'
     * for outputdoc. 
     */ 
    static Id createProcessNodeRec(Id targetManagerRecID){
        SVMXC__ServiceMax_Processes__c processRec = new SVMXC__ServiceMax_Processes__c();
        processRec.SVMXC__Process__c = targetManagerRecID;
        processRec.RecordTypeId = recordTypeMap.get('Process Node Objects');
        processRec.SVMXC__Source_Object_Name__c = 'SVMXC__Service_Order__c';
        processRec.SVMXC__Target_Object_label__c = 'Work Order';
        processRec.SVMXC__Mode_Of_Execution__c = 'Interactive';
        processRec.SVMXC__Type__c = 'Target'; 
        insert processRec;
        return processRec.Id;
    }
    
    /*
     * Static method to create a map of Record type name and ID
     */ 
    static void getAllRecordtypes(){
        for(Recordtype rec : [SELECT Id,Name FROM RecordType WHERE Name IN ('Target Manager','Process Node Objects')]){
            recordTypeMap.put(rec.Name,rec.Id);
        }
    }
}