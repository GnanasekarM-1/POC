public with Sharing class IPRD_WarrantyDefinition {
//======================================== Simple Display Utility ===================================================//
    COMM_Utils_ManageTags commUtil = new COMM_Utils_ManageTags();
    COMM_Utils_ManageSettings commSettings = new SVMXC.COMM_Utils_ManageSettings();
    //public Map<String, String> svmxSettingList = commSettings.SVMX_getSettingList('IPRD002');
    //public Map<String, String> svmxTagList = commUtil.SVMX_getTagList('IPRD002');
    
    //public String getTAG020() {return system.label.IPRD002_TAG020')?svmxTagList.get('TAG020') : '';} //Definition Detail
    public String getTAG021() {return system.label.IPRD002_TAG021;} //Warranty Definition Help
    public String getTAG022() {return system.label.IPRD002_TAG022;} //Save
    public String getTAG023() {return system.label.IPRD002_TAG023;} //Cancel
    public String getTAG024() {return system.label.IPRD002_TAG024;} //Warranty Coverage Starts for
    public String getTAG025() {return system.label.IPRD002_TAG025;} //Coverage Effective From
    public String getTAG026() {return system.label.IPRD002_TAG026;} //Unable to proceed. No warranty terms ID is available in the URL
    public String getTAG027() {return system.label.IPRD002_TAG027;} //Select Date Field
    public String getTAG030() {return system.label.IPRD002_TAG030;} //Loading... 
    public String getTAG044() {return system.label.IPRD002_TAG044;} 
    public String getHLPURL() {return system.label.IPRD002_HLPURL;}//HLPURL  
    
//========================================= Variables =============================================//
    Id WId= System.currentPageReference().getParameters().get('wid');
    SVMXC__Service_Template__c warrantyTerm = new SVMXC__Service_Template__c();
    public Map<String, Schema.SObjectType> allObjs;
    public List<SelectOption> AvailDate = new List<SelectOption>();
    public String Datec;
    Boolean IsValid = true;
    
    public Boolean getIsValid(){   return this.IsValid; }
    public String getWId(){   return this.WId; } 
    
//======================================== Constructure call ===================================================//  
    public IPRD_WarrantyDefinition(){
        if(WId!=NULL){
        warrantyTerm = [SELECT Id,Name,Coverage_Effective_From2__c From SVMXC__Service_Template__c where Id=:WId];
        system.debug('warrantyTerm '+ warrantyTerm);
        Datec=warrantyTerm.Coverage_Effective_From2__c; 
        allObjs = Schema.getGlobalDescribe();
        
        Map<String,Schema.SObjectField> objfieldMap = new Map<String,Schema.SObjectField>();
        //Schema.SObjectType objT = allObjs.get('Installed_Product__c') ;
        // Replaced the custom object name with fuly qualified name during api upgrade
         Schema.SObjectType objT = allObjs.get('SVMXC__Installed_Product__c') ;
        objfieldMap = objT.getDescribe().fields.getMap();
        AvailDate.add(new SelectOption('','-None-'));
        for (String fieldKey : objfieldMap.keySet()) 
        {
            Schema.SObjectField fsObj = objfieldMap.get(fieldKey);
            Schema.DescribeFieldResult f = fsObj.getDescribe();
            if(f.getType() == Schema.DisplayType.DATE )
            AvailDate.add(new SelectOption(f.getName(),f.getLabel()));
        }
        AvailDate=sortingSelectOption(AvailDate);
        }
        else{
            IsValid = false;
            ApexPages.addMessage(new ApexPages.Message ( ApexPages.Severity.ERROR,'',getTAG026())); 
        }
    }
    public SVMXC__Service_Template__c getwarrantyTerm(){
        return warrantyTerm;
    }

    //----------------------------------Sorting Function-----------------------------------------------
    public List<SelectOption> sortingSelectOption(List<SelectOption> so){
        SelectOption tempObj;         
                Integer size = so.size();
                Integer i,j;
                for(i=0;i<size;i++){
                  for(j=i+1;j<size;j++){
                      Integer result=so[i].getLabel().compareTo(so[j].getLabel());
                        if((so[i].getLabel().toUpperCase().compareTo(so[j].getLabel().toUpperCase()))>0){
                            tempObj = so[j];
                            so[j] = so[i];
                            so[i] = tempObj;
                        }
                    }
                }
                return so;
    }
//========================================= Function : Handles Profiles =============================================//
    public List<SelectOption> getAvailDate(){
      return AvailDate;
    }
    public String getDatec(){   return this.Datec; } 
    public void setDatec(String s){ this.Datec =s; }
    
//========================================= Page References for OnSave =============================================//
    public PageReference GoSave(){
    warrantyTerm.Coverage_Effective_From2__c=Datec;
    system.debug('TESTPB1:'+warrantyTerm.Coverage_Effective_From2__c);
    //update warrantyTerm;
    if(COMM_SecurityUtils.getInstance().verifyFieldAccess(warrantyTerm, COMM_SecurityUtils.Access.Updateable)){
        //SDL-SVM-XCREATE-UPDATE-FLS-ENFORCED
      update warrantyTerm;
    }
    else{
      ApexPages.addMessage(new ApexPages.Message ( ApexPages.Severity.ERROR, System.label.COMM001_TAG142));
      return null;
    }
    ApexPages.addMessage(new ApexPages.Message ( ApexPages.Severity.CONFIRM,getTAG044()));
    return NULL; 
    }
    
//========================================= Page References for OnCancel =============================================//
    public PageReference GoBack(){
      String url = '/';
      //if(svmxSettingList.containsKey('SET002') == true) url =svmxSettingList.get('SET002');
      //url='/'+WId;
      url='/'+warrantyTerm.Id;
      PageReference HomePage = new PageReference(url);
      HomePage.setRedirect(true);
      return HomePage; 
    }
}