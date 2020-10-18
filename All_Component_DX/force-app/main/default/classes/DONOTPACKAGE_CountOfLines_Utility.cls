Public class DONOTPACKAGE_CountOfLines_Utility {
    String apexClsCSV = 'NamespacePrefix, Name, ApiVersion,LengthWithoutComments,NumberOfLines'+'\n';
    String apexTriggerCSV = 'NamespacePrefix, Name, ApiVersion,LengthWithoutComments,NumberOfLines' + '\n';
    String apexPageCSV = 'Name, NamespacePrefix, APIVersion, ControllerKey, NumberOfLines, Description'+ '\n';
    Integer acrossAllClassesTotalLines =0;
    Integer acrossAllTriggersTotalLines =0;
    Integer acrossAllPagesTotalLines =0;
    Integer numberOfCls =0;
    Integer numberOfTriggers =0;
    Integer numberOfPages =0;

    public void DONOTPACKAGE_CountOfLines_Utility() {
        doCOL();
    }
    
    public void doCOL(){
        try{
            getApexCOL();
            getTriggerCOL();
            getPageCOL();
            doSendEmail();
            system.debug('Prcessing Completed');
        } catch (Exception ex){system.debug(ex.getMessage());}
    }
    public void getApexCOL(){
        Integer classLines = 0;
 
        for(ApexClass a : [SELECT Body, ApiVersion,LengthWithoutComments,Name,NamespacePrefix FROM ApexClass where NamespacePrefix = 'SVMXC' and (not (name Like '%DONOT%'))  order by Name]){
            List<String> lines = a.Body.split('\n');
            classLines = lines.size();
            acrossAllClassesTotalLines += classLines;
            apexClsCSV += a.NamespacePrefix + ',' + a.Name + ',' + a.ApiVersion + ',' + a.LengthWithoutComments + ',' + classLines + '\n';
            numberOfCls ++;
        }
        system.debug('Apex Class lines: ' + classLines);
    }
 
    public void getTriggerCOL(){
        Integer triggerLines = 0;
 
        for(ApexTrigger a : [SELECT Body, ApiVersion,LengthWithoutComments,Name,NamespacePrefix FROM ApexTrigger where NamespacePrefix = 'SVMXC' and (not (name Like '%DEMO%'))  order by Name]){
            List<String> lines = a.Body.split('\n');
            triggerLines = lines.size();
            acrossAllTriggersTotalLines += triggerLines;
            apexTriggerCSV += a.NamespacePrefix + ',' + a.Name + ',' + a.ApiVersion + ',' + a.LengthWithoutComments + ',' + triggerLines + '\n';
            numberOfTriggers ++;
        }
        system.debug('Apex Trigger lines: ' + triggerLines);
    }
    
    public void getPageCOL(){
        Integer pageLines = 0;
        for(ApexPage a : [SELECT Markup, APIVersion, ControllerKey,Description,MasterLabel,Name,NamespacePrefix FROM ApexPage WHERE Not (Name LIKE '%UIFW%') order by Name]){
            List<String> lines = a.Markup.split('\n');
            pageLines = lines.size();
            acrossAllPagesTotalLines += pageLines;
            apexPageCSV += a.NamespacePrefix + ',' + a.Name + ',' + a.ApiVersion + ',' + a.ControllerKey + ',' + pageLines + ',' + a.Description + '\n';
            numberOfPages ++;
        }
        system.debug('Apex Pages lines: ' + pageLines);
    }
    
     public void doSendEmail(){
     String emailBody = 'Count of Lines Summary:\n';
        emailBody += 'Total Lines of Code across ' +  String.valueOf(numberOfCls) + ' Apex Classes: ' + String.valueOf(acrossAllClassesTotalLines) + '\n';
        emailBody += 'Total Lines of Code across '  +  String.valueOf(numberOfTriggers) + ' Apex Triggers: ' + String.valueOf(acrossAllTriggersTotalLines) + '\n';
        emailBody += 'Total Lines of Code across ' +  String.valueOf(numberOfPages) + ' Apex Pages: ' + String.valueOf(acrossAllPagesTotalLines) + '\n';
    
        Messaging.SingleEmailMessage objMail = new Messaging.SingleEmailMessage();
            objMail.setToAddresses(new String[] {'shyam.hm@servicemax.com'});
            objMail.setSenderDisplayName('ServiceMax');
            objMail.setSubject('COL - Apex Classes, Triggers, Page');
            objMail.setBccSender(false);
            objMail.setUseSignature(false);
            objMail.setPlainTextBody(emailBody + '\n' + 'Checkout Attachments for file wise break-up.');
            
        Messaging.EmailFileAttachment efaCls = new Messaging.EmailFileAttachment();
            efaCls.setFileName('COL_Apex_Classes.csv');
            efaCls.setBody(Blob.valueof(apexClsCSV));

        Messaging.EmailFileAttachment efaTrigger = new Messaging.EmailFileAttachment();
            efaTrigger.setFileName('COL_Apex_Triggers.csv');
            efaTrigger.setBody(Blob.valueof(apexTriggerCSV));
            
        Messaging.EmailFileAttachment efaPage = new Messaging.EmailFileAttachment();
            efaPage.setFileName('COL_Apex_Pages.csv');
            efaPage.setBody(Blob.valueof(apexPageCSV));

        objMail.setFileAttachments(new Messaging.EmailFileAttachment[] {efaCls,efaTrigger, efaPage});

        Messaging.sendEmail(new Messaging.SingleEmailMessage[] { objMail });   
            
    }
}