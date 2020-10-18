public  with sharing class CONF_POPUP_SettingValues{
//======================================== Parsing URL Parameters ===================================================// 
String Sid= System.currentPageReference().getParameters().get('sid'); 
String Pid= System.currentPageReference().getParameters().get('pid'); 
String Source= System.currentPageReference().getParameters().get('src'); 
public String getSource() {return Source;}
 
String moduleView=null;
SVMXC__ServiceMax_Processes__c conf_set = new SVMXC__ServiceMax_Processes__c();
SVMXC__ServiceMax_Config_Data__c conf_set_prof = new SVMXC__ServiceMax_Config_Data__c();
String Filter = '';

public String SelectedOpt {get; set;}
public List<SelectOption> OptionList = new List<SelectOption>();
public List<SelectOption> getOptionList(){
  return OptionList;
} 
//======================================== Simple Display Utility ===================================================// 
    //SVMXC.COMM_Utils_ManageTags commUtil = new SVMXC.COMM_Utils_ManageTags();
    //public Map<String, String> svmxTagList = commUtil.SVMX_getTagList('CONF013');

public String getTAG020() {return System.Label.CONF013_TAG020;} //'Standard Setting Values';
public String getTAG022() {return System.Label.CONF013_TAG022;} //'Submit';
public String getTAG023() {return System.Label.CONF013_TAG023;} //'Close';
public String getTAG024() {return System.Label.CONF013_TAG024;} //'Please select existing Setting';}
public String getTAG026() {return System.Label.CONF013_TAG026;} //'Error : Number';}
public String getTAG027() {return System.Label.CONF013_TAG027;} //'Enter a Valid Number';}
public String getTAG028() {return System.Label.CONF013_TAG028;} //'Error : Date';}
public String getTAG029() {return System.Label.CONF013_TAG029;} //'Enter a Valid Date';}
public String getTAG030() {return System.Label.CONF013_TAG030;} //'Save';}
public String getTAG031() {return System.Label.CONF013_TAG031;} //'Data Saved Sucessfully';}
public String getTAG032() {return System.Label.CONF013_TAG032;} //'Standard Setting Values Help';}
public String getTAG034() {return System.Label.CONF013_TAG034;} //'Requesting...
public String getTAG035() {return System.Label.CONF013_TAG035;} //'Choose Option
public String getTAG036() {return System.Label.CONF006_TAG062;} //'Settings Name'
public String getTAG037() {return System.Label.CONF006_TAG063;} //'Description'
public String getTAG038() {return System.Label.CONF006_TAG064;} //'Data Type'
public String getTAG039() {return system.label.CONF006_TAG075;} //DateTime Value
public String getHLPURL() {return System.Label.CONF013_HLPURL;}
//======================================== Constructure call ===================================================//      
public CONF_POPUP_SettingValues(){
onLoad();
}
public void onLoad(){
    if(Sid!=null)
    {
    conf_set = [SELECT SVMXC__Submodule__c,SVMXC__Description__c, SVMXC__SettingID__c, SVMXC__Settings_Name__c, SVMXC__Data_Type__c, Default_Value__c, Values__c from SVMXC__ServiceMax_Processes__c  where SVMXC__Record_Type_Name__c='Settings' and Id=:Sid limit 1]; //SDL-SVMX-FLS-NOT-ENFORCED-META-DATA
    if(Source!='MS')
    conf_set_prof = [SELECT SVMXC__Display_Value__c, SVMXC__Internal_Value__c from SVMXC__ServiceMax_Config_Data__c  where SVMXC__RecordType_Name__c='Setting Value' and SVMXC__Setting_ID__c=:Sid and SVMXC__Setting_Configuration_Profile__c = :PId limit 1]; //SDL-SVMX-FLS-NOT-ENFORCED-META-DATA
    }
    else{
    DisplayBlockLevelMessage = true;
    ApexPages.addMessage(new ApexPages.Message ( ApexPages.Severity.ERROR,getTAG024()));
    }
        String pickOption;
        List<String> PickOptionArray = new List<String> ();
        if(conf_set.Data_Type__c.toUpperCase() == 'PICKLIST')
        {
            pickOption = conf_set.Values__c;
            if(pickOption  != null){
                pickOption = pickOption.replace('~|~','~');
                PickOptionArray = pickOption.split('~');
                for(Integer i = 0; i < PickOptionArray.size();i++){
                    OptionList.add(new SelectOption(PickOptionArray[i],PickOptionArray[i]));
                }
            }
            SelectedOpt = conf_set_prof.SVMXC__Internal_Value__c;
        }
}
//========================================= Simple Display of Dummy Datas =============================================//
public SVMXC__ServiceMax_Config_Data__c display_data = new SVMXC__ServiceMax_Config_Data__c();
public SVMXC__Installed_Product__c display_lookup = new SVMXC__Installed_Product__c();

public SVMXC__ServiceMax_Config_Data__c getdisplay_data(){
try{
if(Source=='MS'){
        if(conf_set.Default_Value__c!=null)
        {
            if(conf_set.Data_Type__c.toUpperCase()=='DATE')
            {
                display_data.SVMXC__Enter_Date__c=date.valueOf(conf_set.Default_Value__c);
            }
            if(conf_set.Data_Type__c.toUpperCase()=='USER')
            {
                display_data.SVMXC__User__c=conf_set.Default_Value__c;
            }
            //BAC-5889 Date/Time setting
            if(conf_set.Data_Type__c.toUpperCase()=='Date/Time')
            {
                display_data.SVMXC__Previous_Execution_Started_On__c = Datetime.valueOfGmt(conf_set.Default_Value__c);
            }
        }
    }
else{
    if(conf_set_prof.SVMXC__Display_Value__c!=null)
    {
        if(conf_set.Data_Type__c.toUpperCase()=='DATE')
        {
            display_data.SVMXC__Enter_Date__c=date.valueOf(conf_set_prof.SVMXC__Display_Value__c);
        }
        if(conf_set.Data_Type__c.toUpperCase()=='USER')
        {
            display_data.SVMXC__User__c=conf_set_prof.SVMXC__Display_Value__c;
        }   
		//BAC-5889 Date/Time setting   
        if(conf_set.Data_Type__c.toUpperCase()=='Date/Time')
        {
            display_data.SVMXC__Previous_Execution_Started_On__c = Datetime.valueOfGmt(conf_set_prof.SVMXC__Display_Value__c);
        }       
    }
}
}catch (Exception ex){}
return display_data;}

public SVMXC__Installed_Product__c getdisplay_lookup(){
try{
if(Source=='MS'){ 
    if(conf_set.Default_Value__c!=null)
    {
        if(conf_set.Data_Type__c.toUpperCase()=='ACCOUNT')
        {
            display_lookup.SVMXC__Company__c=conf_set.Default_Value__c;
        }
        if(conf_set.Data_Type__c.toUpperCase()=='CONTACT')
        {
            display_lookup.SVMXC__Contact__c=conf_set.Default_Value__c;
        }
        if(conf_set.Data_Type__c.toUpperCase()=='LOCATION')
        {
            display_lookup.SVMXC__Site__c=conf_set.Default_Value__c;
        }       
    }
}
else{
    if(conf_set_prof.SVMXC__Display_Value__c!=null)
    {
        if(conf_set.Data_Type__c.toUpperCase()=='ACCOUNT')
        {
            display_lookup.SVMXC__Company__c=conf_set_prof.SVMXC__Display_Value__c;
        }
        if(conf_set.Data_Type__c.toUpperCase()=='CONTACT')
        {
            display_lookup.SVMXC__Contact__c=conf_set_prof.SVMXC__Display_Value__c;
        }
        if(conf_set.Data_Type__c.toUpperCase()=='LOCATION')
        {
            display_lookup.SVMXC__Site__c=conf_set_prof.SVMXC__Display_Value__c;
        }       
    }
}
}catch (Exception ex){}
return display_lookup;}

//========================================= Function : Display Selected Setting Values =============================================//
public SVMXC__ServiceMax_Processes__c getSMXSettings() {
    return conf_set;
}
public SVMXC__ServiceMax_Config_Data__c getSMXProfSettings() {
    return conf_set_prof;
}

    public List<SelectOption> getItems() 
    {
        List<SelectOption> options = new List<SelectOption>();
        options.add(new SelectOption('True','True'));
        options.add(new SelectOption('False','False'));
        
        return options;
    }

//======================================== Action for saving the custom Values and Default Values ===================================================//
public PageReference saveSet() {
boolean error=false;
try{
if(Source=='MS')
{
        //if(conf_set.Data_Type__c=='Picklist' ||conf_set.Data_Type__c=='Text'){}

        if(conf_set.Data_Type__c.toUpperCase()=='BOOLEAN')
        {
            if(slctradio==true)
            {
                 conf_set.Default_Value__c='True';
            }
            else
            {
                conf_set.Default_Value__c='False';
            }
        }
        else if(conf_set.Data_Type__c.toUpperCase()=='NUMBER'){
            try{
            conf_set.Default_Value__c=String.valueOf(integer.valueOf(conf_set.Default_Value__c));
            }
            catch (Exception ex){
                error=true;
                DisplayBlockLevelMessage = true;
                ApexPages.addMessage(new ApexPages.Message ( ApexPages.Severity.ERROR,getTAG026(),getTAG027()));    
            }
        }
        else if(conf_set.Data_Type__c.toUpperCase()=='DATE')
        {
            try{
            conf_set.Default_Value__c=String.valueOf(display_data.Enter_Date__c);
            }
            catch (Exception ex){
                error=true;
                DisplayBlockLevelMessage = true;
                ApexPages.addMessage(new ApexPages.Message ( ApexPages.Severity.ERROR,getTAG028(),getTAG029()));    
            }
        }
    	else if(conf_set.Data_Type__c.toUpperCase()=='Date/Time')//BAC-5889 Date/Time setting
        {
            try{
                conf_set.Default_Value__c = String.valueOfGmt(display_data.Previous_Execution_Started_On__c);
            }
            catch (Exception ex){
                error=true;
                DisplayBlockLevelMessage = true;
                ApexPages.addMessage(new ApexPages.Message ( ApexPages.Severity.ERROR,getTAG028(),getTAG029()));    
            }
        }
        else if(conf_set.Data_Type__c.toUpperCase()=='USER')
        {
            conf_set.Default_Value__c=display_data.User__c;
        }
        else if(conf_set.Data_Type__c.toUpperCase()=='ACCOUNT')
        {
            conf_set.Default_Value__c=display_lookup.SVMXC__Company__c;
        }
        else if(conf_set.Data_Type__c.toUpperCase()=='CONTACT')
        {
            conf_set.Default_Value__c=display_lookup.SVMXC__Contact__c;
        }
        else if(conf_set.Data_Type__c.toUpperCase()=='LOCATION')
        {
            conf_set.Default_Value__c=display_lookup.SVMXC__Site__c;
        }

        if(error==false){
             /*
                SECSCAN-822 : Security Fix
            */
            if(!COMM_SecurityUtils.getInstance().verifyFieldAccess(conf_set, COMM_SecurityUtils.Access.Updateable)){
                DisplayBlockLevelMessage = true;
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error, System.label.COMM001_TAG142,''));
                return null;
            }
            update conf_set; //SDL-SVMX-CREATE-UPDATE-FLS-ENFORCED
        }
}
else
{
        //BAC-4624 for Audit trial entry
        SVMXC__ServiceMax_Config_Data__c profileData = [Select Id, SVMXC__Profile_Name__c,SVMXC__Configuration_Type__c  From SVMXC__ServiceMax_Config_Data__c  where SVMXC__RecordType_Name__c='Configuration Profile' and Id =:Pid]; //SDL-SVMX-FLS-NOT-ENFORCED-META-DATA
        SVMXC__ServiceMax_Processes__c subModuleData = [Select Id,SVMXC__Name__C,SVMXC__Module__c from  SVMXC__ServiceMax_Processes__c where RecordType.Name = 'Submodule' and Id =:conf_set.SVMXC__Submodule__c]; //SDL-SVMX-FLS-NOT-ENFORCED-META-DATA
        SVMXC__ServiceMax_Processes__c moduleData = [Select Id,SVMXC__Name__C from  SVMXC__ServiceMax_Processes__c where RecordType.Name = 'Module' and Id =:subModuleData.SVMXC__Module__c]; //SDL-SVMX-FLS-NOT-ENFORCED-META-DATA
        
        String actionData = 'Changed ' + conf_set.SVMXC__SettingID__c + ' from value ' + conf_set_prof.SVMXC__Internal_Value__c + ' to ';
        
        if(conf_set.Data_Type__c.toUpperCase()=='PICKLIST')
        {
            conf_set_prof.SVMXC__Display_Value__c=SelectedOpt;
            actionData += SelectedOpt;
        }
        
        if(conf_set.Data_Type__c.toUpperCase()=='TEXT')
        {
            conf_set_prof.SVMXC__Internal_Value__c = conf_set_prof.SVMXC__Display_Value__c;
            actionData += conf_set_prof.SVMXC__Display_Value__c;
        }

        else if(conf_set.Data_Type__c.toUpperCase()=='BOOLEAN')
        {
            if(slctradio==true)
            {
                conf_set_prof.SVMXC__Display_Value__c='True';
                actionData += 'True';
            }
            else
            {
                conf_set_prof.SVMXC__Display_Value__c ='False';
                actionData += 'False';
            }
        }
        else if(conf_set.Data_Type__c.toUpperCase()=='NUMBER'){
            try{
                conf_set_prof.SVMXC__Display_Value__c=String.valueOf(integer.valueOf(conf_set_prof.SVMXC__Display_Value__c));
                actionData += String.valueOf(integer.valueOf(conf_set_prof.SVMXC__Display_Value__c));
            }
            catch (Exception ex){
                error=true;
                DisplayBlockLevelMessage = true;
                ApexPages.addMessage(new ApexPages.Message ( ApexPages.Severity.ERROR,getTAG026(),getTAG027()));            
            }
        }
        else if(conf_set.Data_Type__c.toUpperCase()=='DATE')
        {
            try{
                conf_set_prof.SVMXC__Display_Value__c=String.valueOf(display_data.Enter_Date__c);
                actionData += String.valueOf(display_data.Enter_Date__c);
            }
            catch (Exception ex){
                error=true;
                DisplayBlockLevelMessage = true;
                ApexPages.addMessage(new ApexPages.Message ( ApexPages.Severity.ERROR,getTAG028(),getTAG030()));     
            }
        }
    	else if(conf_set.Data_Type__c.toUpperCase()=='Date/Time')//BAC-5889 Date/Time setting
        {
            try{
                conf_set_prof.SVMXC__Display_Value__c = String.valueOfGmt(display_data.Previous_Execution_Started_On__c);
                actionData += String.valueOfGmt(display_data.Previous_Execution_Started_On__c);
            }
            catch (Exception ex){
                error=true;
                DisplayBlockLevelMessage = true;
                ApexPages.addMessage(new ApexPages.Message ( ApexPages.Severity.ERROR,getTAG028(),getTAG030()));     
            }
        }
        else if(conf_set.Data_Type__c.toUpperCase()=='USER')
        {
            conf_set_prof.SVMXC__Display_Value__c=display_data.User__c;
            actionData += display_data.User__c;
        }
        else if(conf_set.Data_Type__c.toUpperCase()=='ACCOUNT')
        {
            conf_set_prof.SVMXC__Display_Value__c=display_lookup.Company__c;
            actionData += display_lookup.Company__c;
        }
        else if(conf_set.Data_Type__c.toUpperCase()=='CONTACT')
        {
            conf_set_prof.SVMXC__Display_Value__c=display_lookup.Contact__c;
            actionData += display_lookup.Contact__c;
        }          
        else if(conf_set.Data_Type__c.toUpperCase()=='LOCATION')
        {
            conf_set_prof.SVMXC__Display_Value__c=display_lookup.Site__c;
            actionData += display_lookup.Site__c;
        } 
        conf_set_prof.SVMXC__Internal_Value__c=conf_set_prof.SVMXC__Display_Value__c;       
        if(error==false){
             /*
                SECSCAN-822 : Security Fix
            */            
            if(!COMM_SecurityUtils.getInstance().verifyFieldAccess(conf_set_prof, COMM_SecurityUtils.Access.Updateable)){
                DisplayBlockLevelMessage = true;
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error, System.label.COMM001_TAG142,''));
                return null;
            }

            update conf_set_prof; //SDL-SVMX-CREATE-UPDATE-FLS-ENFORCED
            
            actionData += ' for profile '+ profileData.SVMXC__Profile_Name__c + ' Module '+moduleData.SVMXC__Name__C + ' Submodule ' +subModuleData.SVMXC__Name__C;
            //BAC-4624 insert view servicemax configuration
            String entityName = profileData.SVMXC__Configuration_Type__c == 'Global' ? 'Org-wide Configuration' : 'Group-wide Configuration';
            COMM_Utils_V2 commUtils = new COMM_Utils_V2();
            commUtils.processServicemaxConfiguration(entityName,'Browser','Modified',actionData);
        }
}       
}catch (Exception ex){}
        if(error==false)
        {
                DisplayBlockLevelMessage = true;
                ApexPages.addMessage(new ApexPages.Message ( ApexPages.Severity.CONFIRM,getTAG030(),getTAG031()));  
        }
        return null;
}

//======================================== Set true to display blocklevel messges ===================================================//  
public Boolean DisplayBlockLevelMessage = false;
public Boolean getDisplayBlockLevelMessage(){ return DisplayBlockLevelMessage; }  

    Boolean slctradio; ////
    public Boolean getSlctradio() 
    {
        try{
        if(Source=='MS')
        {
            if(conf_set.Default_Value__c.toUpperCase() =='TRUE')
            {
                slctradio = true;
            }
            else if(conf_set.Default_Value__c.toUpperCase() == 'FALSE')
            {
                slctradio = false;
            }
        }
        else 
        {
             if(conf_set_prof.SVMXC__Display_Value__c.toUpperCase() == 'TRUE')
            {
                slctradio = true;
            }
            else if(conf_set_prof.SVMXC__Display_Value__c.toUpperCase() == 'FALSE')
            {
                slctradio = false;
            }
        }
        

        return slctradio;
        }catch (Exception ex){return null;}
    }
        public void setSlctradio(Boolean slctradio) 
    { 
        this.slctradio = slctradio; 
    }


    public List<SelectOption> getBooleans() 
    {
        try{
          List<SelectOption> booleans = new List<SelectOption>();   
          booleans.add(new SelectOption('True','True')); 
          booleans.add(new SelectOption('False','False')); 
          return booleans; 
          }catch (Exception ex){return null;}
    }
 
}