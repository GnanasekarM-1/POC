public with sharing class IPRD_WorkOrderFromIB {
    // ------------------------NPS Related changes  ---------
    public string getUserLocaleKey()
    {
        return UserInfo.getLanguage();
    }
    public string getUserID()
    {
        return UserInfo.getUserId().substring(0, 15);
    }
    public string getUserOrgID()
    {
        return UserInfo.getOrganizationId().substring(0, 15);
    }

    // -------------------------------

String IB_WO_MAP;
String defaultRecordType;

//**************************************************Declaration for Globle variables....*****************************************///
SVMXC.COMM_Utils utils = new SVMXC.COMM_Utils();
SVMXC.COMM_Utils_ManageSettings settings = new SVMXC.COMM_Utils_ManageSettings();
Map<String, String> AllSubModuleSettings = settings.SVMX_getSettingList('IPRD009'); 
public Boolean btnisdisabled = false;
public Boolean getbtnisdisabled(){return btnisdisabled;}   

public String SelectedRT; 
public List<selectoption> options = new List<selectoption>();  
public String IBId = System.currentPageReference().getParameters().get('ibid'); 
public List<SVMXC__ServiceMax_Config_Data__c> fieldMapSetting = new List<SVMXC__ServiceMax_Config_Data__c> (); 
public SVMXC__Installed_Product__c souObjRec = new SVMXC__Installed_Product__c() ;
public SVMXC__Service_Order__c workOrder = new SVMXC__Service_Order__c();  // new WO created from IB.. // RecordTypeId = SelectedRT 
public SVMXC__Installed_Product__c iprd;
public List<RecordType> Rtype = new List<RecordType>(); //changed frm none to public 
public Boolean ValidRecords = true;
public Boolean isdisplay = false;
public String souObjFieldNames; 
public String SOQLHeader;
public list<String> Fieldname = new List<String>();
public Map<String,String> MapofPickListDefValue = new Map<String,String>();  

//**************************************************************Constructor**********************************************************//
public IPRD_WorkOrderFromIB()
{
    IB_WO_MAP = AllSubModuleSettings.get('SET001');
    defaultRecordType = AllSubModuleSettings.get('SET002');
    //Get all work order's record type
    Rtype = [Select id,Name From RecordType where SobjectType = 'SVMXC__Service_Order__c' ];
    system.debug('TEST :1'+Rtype);
    try{
        if(Rtype!=NULL && Rtype.size() == 0){
        options.add(new selectoption(System.Label.IPRD009_TAG005,System.Label.IPRD009_TAG005));
        SelectedRT = System.Label.IPRD009_TAG005;
        }
        else{
            for (RecordType r : Rtype){
                Options.add(new SelectOption(r.Id,r.Name));
                    if(defaultRecordType != null ){
                        if(defaultRecordType == r.Name)
                        SelectedRT = r.Id;
                    }
                }           
        }
        workOrder.OwnerId = Userinfo.getUserId();
        //SETTING UP DEFAULT PICKLIST VALUES
        Fieldname.add('SVMXC__Billing_Type__c');
        Fieldname.add('SVMXC__Priority__c');
        Fieldname.add('SVMXC__Order_Type__c');
        MapofPickListDefValue = utils.SVMX_getDefaultPicklistValue('SVMXC__Service_Order__c',FieldName);
        system.debug('MapofPickListDefValue'+MapofPickListDefValue);
        if(MapofPickListDefValue.size() > 0){
        if(MapofPickListDefValue.containsKey('SVMXC__Billing_Type__c'))
            workOrder.SVMXC__Billing_Type__c = MapofPickListDefValue.get('SVMXC__Billing_Type__c');
        if(MapofPickListDefValue.containsKey('SVMXC__Priority__c'))
            workOrder.SVMXC__Priority__c = MapofPickListDefValue.get('SVMXC__Priority__c');
        if(MapofPickListDefValue.containsKey('SVMXC__Order_Type__c')) 
            workOrder.SVMXC__Order_Type__c = MapofPickListDefValue.get('SVMXC__Order_Type__c');
        }
        //Entitlement check
        //if(AllSubModuleSettings.get('SET008') != null && AllSubModuleSettings.get('SET008').toLowercase()=='true')
        //  caseHeader.SVMXC__Perform_Auto_Entitlement__c = true;
        //else
        //  caseHeader.SVMXC__Perform_Auto_Entitlement__c = false;
    }
    catch(Exception e){
        ApexPages.AddMessage(new ApexPages.Message(ApexPages.Severity.Error, + e.getMessage()));
    }
    try{
        fieldMapSetting = settings.SVMX_getFieldMapping(IB_WO_MAP); 
        souObjFieldNames = '';
        for(SVMXC__ServiceMax_Config_Data__c fld:fieldMapSetting){
            if(souObjFieldNames.length() > 0){ 
                souObjFieldNames += ', '; 
            }
            if(fld.SVMXC__Source_Field_Name__c != null)
                souObjFieldNames += fld.SVMXC__Source_Field_Name__c;
        }
        SOQLHeader = '  SELECT '+souObjFieldNames+' FROM SVMXC__Installed_Product__c where Id=:IBId';
        souObjRec = Database.query(SOQLHeader);
        for(SVMXC__ServiceMax_Config_Data__c fld:fieldMapSetting){
            String targetFieldName = fld.SVMXC__Target_Field_Name__c;                    
            String sourceFieldName = fld.SVMXC__Source_Field_Name__c;
            Object souFldVal;
            
            if(sourceFieldName != null )
            souFldVal = souObjRec.get(sourceFieldName);
            
            if(souFldVal != null)
            {
            workOrder.put(targetFieldName, souFldVal);
            }
        }
        if(SelectedRT != System.Label.IPRD009_TAG005)
        workOrder.put('RecordtypeId',selectedRT);
    }    
    catch(Exception e){
        ApexPages.AddMessage(new ApexPages.Message(ApexPages.Severity.Error, + e.getMessage()));
    }
}



//*******************************************************All Getter & Setter Methods.....*****************************************//

public String getIBname(){
    If(IBId != null){ 
    
        List<String> queryFields = new List<String> {'name', 'Id'};
        
        if( ! COMM_SecurityUtils.getInstance().verifyFieldAccess( 'SVMXC__Installed_Product__c', queryFields, COMM_SecurityUtils.Access.Accessible ) ) {
          
            ApexPages.addMessage(new ApexPages.Message( ApexPages.Severity.Error, System.Label.COMM001_TAG142 ) );                    
            return null;
        }
        //SDL-SVMX-READ-FLS-ENFORCED
        iprd = [select id,name from SVMXC__Installed_Product__c where id =: IBId]; 
        return iprd.name;
    }
    else{
        ApexPages.AddMessage(new ApexPages.Message(ApexPages.Severity.Error,getTAG009())); 
        return null;
    }
} 
public SVMXC__Service_Order__c getworkOrder(){return workOrder;}
public String getTAG001() {return System.Label.IPRD009_TAG001; }
public String getTAG002() {return System.Label.IPRD009_TAG002; }
public String getTAG003() {return System.Label.IPRD009_TAG003; }
public String getTAG004() {return System.Label.IPRD009_TAG004; }
public String getTAG005() {return System.Label.IPRD009_TAG005; }
public String getTAG008() {return System.Label.IPRD009_TAG008; }
public String getTAG009() {return System.Label.IPRD009_TAG009; }
public String getTAG010() {return System.Label.IPRD009_TAG010; }
public String getTAG011() {return System.Label.IPRD009_TAG011; }
public String getHLPURL() {return System.Label.IPRD009_HLPURL; }

///*******************************************************Methods for selecting the record type.....*****************************************//

public List<selectoption> getRecordType(){
    return options;
}
public String getSelectedRT(){
    return SelectedRT;
}
public void setSelectedRT(String s){
this.SelectedRT = s;
}

//*****************************************************Method for display error message....**********************************************//    

public Boolean getIsDisplay(){
    isdisplay = false;
    if(IBId == null){
        isdisplay = false;
        return isdisplay;
    }
    else{
        isdisplay = true;
        return isdisplay;
    }
}

//*****************************************************all PageReference Methods....**********************************************//
public PageReference DoCancel(){
    if(IBId == null){
        PageReference homepage = new PageReference('/'+ 'home/home.jsp');
        return homepage;
    }
    PageReference newPage = new PageReference('/' + IBId);
    return newPage;
}
public PageReference CreateWO(){
    try{
        if(SelectedRT != System.Label.IPRD009_TAG005)
        workorder.put('RecordtypeId',selectedRT);
        //insert workorder;
    if( COMM_SecurityUtils.getInstance().verifyFieldAccess( workorder, COMM_SecurityUtils.Access.Createable ) ) {
        //SDL-SVM-XCREATE-UPDATE-FLS-ENFORCED
      insert workorder;
    } else {
      btnisdisabled = false;
      ApexPages.addMessage(new ApexPages.Message ( ApexPages.Severity.ERROR, System.Label.COMM001_TAG142 ) );
      return null;
    }
        PageReference WOPage = new PageReference('/' + workorder.Id);
         btnisdisabled = true; 
        return WOPage;
    }
    catch(exception e){
         btnisdisabled = false;
        ApexPages.AddMessage(new ApexPages.Message(ApexPages.Severity.Error, + e.getMessage()));
    }
    return null;
}

}