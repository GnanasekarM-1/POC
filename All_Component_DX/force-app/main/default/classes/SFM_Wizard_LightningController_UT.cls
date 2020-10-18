@isTest
private class SFM_Wizard_LightningController_UT{

    static SVMXC__ServiceMax_Processes__c processNode;
    static SVMXC__Doc_Template__c docTemplate;
    static SVMXC__Doc_Template_Details__c docTemplateDetailHeader;
    static SVMXC__Doc_Template_Details__c docTemplateDetailChild;
    static SVMXC__ServiceMax_Processes__c processNodeTarget;
    static SVMXC__ServiceMax_Processes__c processNodeTargetChild;
    
    static testmethod void TestgetWizards(){
        SVMXC__Service_Order__c wo = new SVMXC__Service_Order__c();
        insert wo; 
        SFM_Wizard_LightningController.RecordWizard recordWizard= new SFM_Wizard_LightningController.RecordWizard();
        recordWizard = SFM_Wizard_LightningController.getWizards(wo.id);
        
       
        List<SFM_Wizard_LightningController.OutputDocTemplateWrapper> outputDocTemplate =  new List<SFM_Wizard_LightningController.OutputDocTemplateWrapper>();
        outputDocTemplate= SFM_Wizard_LightningController.getOutputDocTemplate (wo.id);
        
        // Create Test data and check positive flow
        prepareTestData();
        outputDocTemplate= SFM_Wizard_LightningController.getOutputDocTemplate (wo.id);
        // Instantiate the class 
        SFM_Wizard_LightningController.WizardStep wizstep = new  SFM_Wizard_LightningController.WizardStep();
         
    }
    
    static void prepareTestData(){
        //Get the recordtypes
         List<RecordType> lstRecType = [SELECT Id, Name FROM RecordType WHERE SobjectType = 'SVMXC__ServiceMax_Processes__c'];
         String targetManager, processNodeObj;
         for(RecordType r : lstRecType){
            if(r.Name == 'Target Manager')
                targetManager = r.id;
            if(r.Name == 'Process Node Objects')    
                processNodeObj = r.id;
         }
        //Create Doc Template
        docTemplate = new SVMXC__Doc_Template__c();
        docTemplate.SVMXC__Template_Id__c = 'DOCTEMP001';
        insert docTemplate;
        
        //Create Doc Template Details
        docTemplateDetailHeader = new SVMXC__Doc_Template_Details__c();
        docTemplateDetailHeader.SVMXC__Doc_Template__c = docTemplate.Id;
        docTemplateDetailHeader.SVMXC__Type__c = 'Header';
        docTemplateDetailHeader.SVMXC__Object_Name__c = 'SVMXC__Service_Order__c';
        docTemplateDetailHeader.SVMXC__Alias__c = 'wo';
        docTemplateDetailHeader.SVMXC__Fields__c = '{\"Metadata\":[' +
            '{\"OBJ\" : \"SVMXC__Service_Order__c\",\"FN\" : \"SVMXC__City__c\",\"TYP\" : \"Text\"},' +
            '{\"OBJ\" : \"SVMXC__Service_Order__c\",\"FN\" : \"SVMXC__Configuration_After__c\",\"TYP\" : \"LongTextArea\"},' +
            '{\"OBJ\" : \"SVMXC__Service_Order__c\",\"FN\" : \"SVMXC__Country__c\",\"TYP\" : \"Picklist\"},' +
            '{\"OBJ\" : \"SVMXC__Service_Order__c\",\"FN\" : \"SVMXC__Is_Entitlement_Performed__c\",\"TYP\" : \"Checkbox\"},' +
            '{\"OBJ\" : \"SVMXC__Service_Order__c\",\"FN\" : \"SVMXC__Latitude__c\",\"TYP\" : \"Number\"},' +
            '{\"OBJ\" : \"SVMXC__Service_Order__c\",\"FN\" : \"SVMXC__Case__c\",\"TYP\" : \"Reference\",\"RLN\" : \"SVMXC__Case__r\",\"ROBJ\" : \"Case\",\"RFN\" : \"CaseNumber\",\"RTYP\" : \"Text\"},' +
            '{\"OBJ\" : \"SVMXC__Service_Order__c\",\"FN\" : \"SVMXC__Case__c\",\"TYP\" : \"Reference\",\"RLN\" : \"SVMXC__Case__r\",\"ROBJ\" : \"Case\",\"RFN\" : \"AccountId\",\"RTYP\" : \"Reference\",\"RLN2\" : \"Account\",\"ROBJ2\" : \"Account\",\"RFN2\" : \"CreatedDate\",\"RTYP2\" : \"Text\"},' +
            '{\"OBJ\" : \"SVMXC__Service_Order__c\",\"FN\" : \"SVMXC__Case__c\",\"TYP\" : \"Reference\",\"RLN\" : \"SVMXC__Case__r\",\"ROBJ\" : \"Case\",\"RFN\" : \"SVMXC__SLA_Terms__c\",\"RTYP\" : \"Reference\",\"RLN2\" : \"SVMXC__SLA_Terms__r\",\"ROBJ2\" : \"SVMXC__Service_Level__c\",\"RFN2\" : \"SVMXC__Active__c\",\"RTYP2\" : \"Checkbox\"}' +
            ']}';
        docTemplateDetailHeader.SVMXC__SOQL__c = 'SVMXC__City__c,SVMXC__Configuration_After__c,SVMXC__Country__c,SVMXC__Is_Entitlement_Performed__c,SVMXC__Latitude__c,SVMXC__Case__r.CaseNumber,SVMXC__Case__r.Account.CreatedDate,SVMXC__Case__r.SVMXC__SLA_Terms__r.SVMXC__Active__c';
        docTemplateDetailHeader.SVMXC__Header_Reference_Field__c = 'Id';
        insert docTemplateDetailHeader;

        docTemplateDetailChild = new SVMXC__Doc_Template_Details__c(
            SVMXC__Doc_Template__c = docTemplate.Id,   
            SVMXC__Type__c = 'Detail_Object', 
            SVMXC__Object_Name__c = 'SVMXC__Checklist__c',   
            SVMXC__Doc_Template_Detail_Id__c = 'Checklist (Work Order)',
            SVMXC__Alias__c = 'Checklist__Work_Order_', 
            SVMXC__Fields__c = '{"Metadata":[{"FN":"SVMXC__ChecklistProcessID__c","RLN":"SVMXC__ChecklistProcessID__r","RTYP":"string","ROBJ":"SVMXC__ServiceMax_Processes__c","TYP":"reference","OBJ":"SVMXC__Checklist__c","RFN":"SVMXC__Name__c"},{"FN":"SVMXC__Completed_By__c","RLN":"SVMXC__Completed_By__r","RTYP":"string","ROBJ":"User","TYP":"reference","OBJ":"SVMXC__Checklist__c","RFN":"Name"},{"TYP":"datetime","FN":"SVMXC__Completed_On__c","OBJ":"SVMXC__Checklist__c"},{"TYP":"picklist","FN":"SVMXC__Status__c","OBJ":"SVMXC__Checklist__c"}]}', 
            SVMXC__SOQL__c = 'SVMXC__ChecklistProcessID__r.SVMXC__Name__c, SVMXC__Completed_By__r.Name, SVMXC__Completed_On__c, SVMXC__Status__c',
            SVMXC__Header_Reference_Field__c = 'SVMXC__Work_Order__c'
        );
        insert docTemplateDetailChild;
        
        //Create 
        processNode = new SVMXC__ServiceMax_Processes__c();
        processNode.RecordTypeId = targetManager;
        processNode.SVMXC__ProcessID__c = 'OPDOC001';
        processNode.SVMXC__Doc_Template__c = docTemplate.Id;
        processNode.SVMXC__Purpose__c = 'OUTPUT DOCUMENT';
        insert processNode;
        
        //Create Process Node Object Target
        processNodeTarget = new SVMXC__ServiceMax_Processes__c();
        processNodeTarget.RecordTypeId = processNodeObj;      
        processNodeTarget.SVMXC__ProcessID__c = 'PROCNODE001';
        processNodeTarget.SVMXC__Process__c = processNode.Id;
        processNodeTarget.SVMXC__Doc_Template_Details__c = docTemplateDetailHeader.Id;
        processNodeTarget.SVMXC__Type__c = 'TARGET';
        processNodeTarget.SVMXC__Source_Object_Name__c = 'SVMXC__Service_Order__c';
        insert processNodeTarget;

        //Create Process Node Object Target child
        processNodeTargetChild = new SVMXC__ServiceMax_Processes__c();
        processNodeTargetChild.RecordTypeId = processNodeObj;      
        processNodeTargetChild.SVMXC__ProcessID__c = 'PROCNODE001';
        processNodeTargetChild.SVMXC__Process__c = processNode.Id;
        processNodeTargetChild.SVMXC__Doc_Template_Details__c = docTemplateDetailChild.Id;
        processNodeTargetChild.SVMXC__Type__c = 'TARGETCHILD';
        insert processNodeTargetChild;
        
        String document = '<div data=\'$D.wo.SVMXC__City__c\'>City</div> ' +
            '<div data=\'$D.wo.SVMXC__Configuration_After__c\'>SVMXC__Configuration_After__c</div>' +
            '<div data=\'$D.wo.SVMXC__Country__c\'>SVMXC__Country__c</div>' +
            '<div data=\'$D.wo.SVMXC__Is_Entitlement_Performed__c\'>SVMXC__Is_Entitlement_Performed__c</div>' +
            '<div data=\'$D.wo.SVMXC__Latitude__c\'>SVMXC__Latitude__c</div>' +
            '<div data=\'$D.wo.SVMXC__Case__c.CaseNumber\'>SVMXC__Case__c</div>' +
            '<div data=\'$D.wo.SVMXC__Case__c.AccountId.CreatedDate\'>SVMXC__Case__c.Account.CreatedDate</div>' +
            '<div data=\'$D.wo.SVMXC__Case__c.SVMXC__SLA_Terms__c.SVMXC__Active__c\'>SVMXC__Case__c.SVMXC__SLA_Terms__c.SVMXC__Active__c</div>';
        
        Attachment attach = new Attachment();
        Blob myBlob = Blob.valueof(document);
        attach.Body = myBlob;
        attach.Name = 'OutputDoc';
        attach.IsPrivate = false;
        attach.ParentId = docTemplate.Id;
        insert attach;
    }
}