public with sharing class SORG_ManageTeamTech {
    
    //-------------------NPS Related...
    public string getUserLocaleKey(){
        return UserInfo.getLanguage();
    }
    public string getUserID(){
        return UserInfo.getUserId().substring(0, 15);
    }
    public string getUserOrgID(){
        return UserInfo.getOrganizationId().substring(0, 15);
    }
    
    //Translations   
    public String getGBL001() {return (svmxSettingList != null && svmxSettingList.containsKey('GBL001'))?svmxSettingList.get('GBL001') : 'ABQIAAAAB0wwxr_S8iKOQA_rHFtvlhQrroEcTVXxNCBMYghN-z6V4Vps5BRsJnPQt8nVzwKal0A9wognXYZwLQ';}
    public String getGBL006() {return (svmxSettingList != null && svmxSettingList.containsKey('GBL006'))?svmxSettingList.get('GBL006') : 'Kilometer';}
    public String getGBL011() {return (svmxSettingList != null && svmxSettingList.containsKey('GBL011'))?svmxSettingList.get('GBL011') : 'gme-servicemaxinc';}
    
    public String getTAG001() {return system.label.SORG001_TAG001 ;}// 'New Service Team';}
    public String getTAG002() {return system.label.SORG001_TAG002;}// 'New Technician';}
    public String getTAG003() {return system.label.SORG001_TAG003;}// 'Edit';}
    public String getTAG004() {return system.label.SORG001_TAG004;}// 'Delete';}
    public String getTAG005() {return system.label.SORG001_TAG005;}// 'Back to Setup Home';}
    //Translation for search Panel
    public String getTAG006() {return system.label.SORG001_TAG006;}// 'Search';}
    public String getTAG007() {return system.label.SORG001_TAG007;}// 'Enter keyword to filter the list below ';}
    public String getTAG008() {return system.label.SORG001_TAG008;}// 'Go!';}
    public String getTAG009() {return system.label.SORG001_TAG009;}// 'Filter By Expertise';}
    public String getTAG010() {return system.label.SORG001_TAG010;}// 'Filter By Product ';}
    //Translation for New/Edit Team PopUp
    public String getTAG011() {return system.label.SORG001_TAG011;}// 'Save';}
    public String getTAG012() {return system.label.SORG001_TAG012;}// 'Cancel';}
    public String getTAG013() {return system.label.SORG001_TAG013;}// 'Add/Edit Team';}
    public String getTAG014() {return system.label.SORG001_TAG014;}// 'Record Type';}
    public String getTAG015() {return system.label.SORG001_TAG015;}// 'Street';}
    public String getTAG016() {return system.label.SORG001_TAG016;}// 'Name';}
    public String getTAG017() {return system.label.SORG001_TAG017;}// 'City';}
    public String getTAG018() {return system.label.SORG001_TAG018;}// 'Group Code';}
    public String getTAG019() {return system.label.SORG001_TAG019;}// 'State';}
    public String getTAG020() {return system.label.SORG001_TAG020;}// 'Group Type';}
    public String getTAG021() {return system.label.SORG001_TAG021;}// 'Zip';}
    public String getTAG022() {return system.label.SORG001_TAG022;}// 'Active';}
    public String getTAG023() {return system.label.SORG001_TAG023;}// 'Country';}
    public String getTAG024() {return system.label.SORG001_TAG024;}// 'Description';}
    public String getTAG025() {return system.label.SORG001_TAG025;}// 'Team Phone';}
    public String getTAG026() {return system.label.SORG001_TAG026;}// 'Team Email';}
    //Translation for New/Edit Tech PopUp
    public String getTAG027() {return system.label.SORG001_TAG027;}// 'Save';}
    public String getTAG028() {return system.label.SORG001_TAG028;}// 'Cancel';}
    public String getTAG029() {return system.label.SORG001_TAG029;}// 'Add/Edit Technician';}
    public String getTAG030() {return system.label.SORG001_TAG030;}// 'Technician Name';}
    public String getTAG031() {return system.label.SORG001_TAG031;}// 'Street';}
    public String getTAG032() {return system.label.SORG001_TAG032;}// 'Service Team';}
    public String getTAG033() {return system.label.SORG001_TAG033;}// 'City';}
    public String getTAG034() {return system.label.SORG001_TAG034;}// 'Role';}
    public String getTAG035() {return system.label.SORG001_TAG035;}// 'State';}
    public String getTAG036() {return system.label.SORG001_TAG036;}// 'Active';}
    public String getTAG037() {return system.label.SORG001_TAG037;}// 'Zip';}
    public String getTAG038() {return system.label.SORG001_TAG038;}// 'Salesforce User';}
    public String getTAG039() {return system.label.SORG001_TAG039;}// 'Country';}
    public String getTAG040() {return system.label.SORG001_TAG040;}// 'Enable Scheduling';}
    public String getTAG041() {return system.label.SORG001_TAG041;}// 'Phone Number';}
    public String getTAG042() {return system.label.SORG001_TAG042;}// 'Service Territory';}
    public String getTAG043() {return system.label.SORG001_TAG043;}// 'Email';}
    public String getTAG044() {return system.label.SORG001_TAG044;}// 'Inventory Location';}
    public String getTAG045() {return system.label.SORG001_TAG045;}// 'Create Automatically';}
    public String getTAG046() {return system.label.SORG001_TAG046;}// 'Working Hours';}
    public String getTAG047() {return system.label.SORG001_TAG047;}// 'Overtime Hours';}
    public String getTAG048() {return system.label.SORG001_TAG048;}// 'Break Hours';}
    //public String getTAG049() {return system.label.SORG001_TAG049;}// 'Break Type';}
    //public String getTAG050() {return system.label.SORG001_TAG050;}// 'Break Duration in Minutes';}
    public String getTAG051() {return system.label.SORG001_TAG051;}// 'Additional Information';}
    //Translation for Child Tabs
    public String getTAG052() {return system.label.SORG001_TAG052;}// 'Expertise';}
    public String getTAG053() {return system.label.SORG001_TAG053;}// 'Add Expertise';}
    public String getTAG054() {return system.label.SORG001_TAG054;}// 'Delete';}
    public String getTAG055() {return system.label.SORG001_TAG055;}// 'Save';}
    //public String getTAG056() {return system.label.SORG001_TAG056;}// 'Select';}  
    public String getTAG057() {return system.label.SORG001_TAG057;}// 'Skill Name';}
    public String getTAG058() {return system.label.SORG001_TAG058;}// 'Skill Level';}
    public String getTAG059() {return system.label.SORG001_TAG059;}// 'Search Skills by entering a keyword';}
    public String getTAG060() {return system.label.SORG001_TAG060;}// 'Go!';}
    public String getTAG061() {return system.label.SORG001_TAG061;}// 'Add Selected';}
    public String getTAG062() {return system.label.SORG001_TAG062;}// 'Cancel';}
    public String getTAG063() {return system.label.SORG001_TAG063;}// 'Select';}
    public String getTAG064() {return system.label.SORG001_TAG064;}// 'Skill Name';}
    
    public String getTAG065() {return system.label.SORG001_TAG065;}// 'Product';}
    public String getTAG066() {return system.label.SORG001_TAG066;}// 'Add Product';}
    public String getTAG067() {return system.label.SORG001_TAG067;}// 'Delete';}
    public String getTAG068() {return system.label.SORG001_TAG068;}// 'Save';}
    //public String getTAG069() {return system.label.SORG001_TAG069;}// 'Select';}  
    public String getTAG070() {return system.label.SORG001_TAG070;}// 'Product Name';}
    public String getTAG071() {return system.label.SORG001_TAG071;}// 'Search Product by entering a keyword';}
    public String getTAG072() {return system.label.SORG001_TAG072;}// 'Go!';}
    public String getTAG073() {return system.label.SORG001_TAG073;}// 'Add Selected';}
    public String getTAG074() {return system.label.SORG001_TAG074;}// 'Cancel';}
    public String getTAG075() {return system.label.SORG001_TAG075;}// 'Select';}
    public String getTAG076() {return system.label.SORG001_TAG076;}//  'Product Name';}
    
    public String getTAG077() {return system.label.SORG001_TAG077;}// 'Cost';}
    public String getTAG078() {return system.label.SORG001_TAG078;}// 'Add Cost Record';}
    public String getTAG079() {return system.label.SORG001_TAG079;}// 'Delete';}
    public String getTAG080() {return system.label.SORG001_TAG080;}// 'Save';}
    //public String getTAG081() {return system.label.SORG001_TAG081;}// 'Select';}
    public String getTAG082() {return system.label.SORG001_TAG082;}// 'Cost Category';}
    public String getTAG083() {return system.label.SORG001_TAG083;}// 'Hourly Cost';}
    public String getTAG084() {return system.label.SORG001_TAG084;}// 'Billable Amount';}
    public String getTAG085() {return system.label.SORG001_TAG085;}// 'Currency';}
    
    public String getTAG086() {return system.label.SORG001_TAG086;}// 'Team Technician Management Console';}
    public String getTAG087() {return system.label.SORG001_TAG087;}// 'Requesting.....';} 
    public String getTAG088() {return system.label.SORG001_TAG088;}// 'Processing.....';}
    
    public String getTAG089() {return system.label.SORG001_TAG089;}// 'Duplicate Service Team Name';}
    public String getTAG090() {return system.label.SORG001_TAG090;}// 'Enter Team Name';}
    public String getTAG091() {return system.label.SORG001_TAG091;}// 'Please Select one record to delete';}
    public String getTAG092() {return system.label.SORG001_TAG092;}// 'Please select at least one record first';}
    public String getTAG093() {return system.label.SORG001_TAG093;}// 'Please create at least one expertise record to save';}
    public String getTAG094() {return system.label.SORG001_TAG094;}// 'Please select a Skill';}
    public String getTAG095() {return system.label.SORG001_TAG095;}// : 'Please create at least one Product record to save';}
    public String getTAG096() {return system.label.SORG001_TAG096;}// : 'Please select a Product';}
    public String getTAG097() {return system.label.SORG001_TAG097;}// : 'Please create at least one Cost record to save';}
    public String getTAG098() {return system.label.SORG001_TAG098;}// : 'Please enter hourly cost or billable amount';}
    public String getTAG099() {return system.label.SORG001_TAG099;}// 'Please select at least one record to delete';}
    public String getTAG100() {return system.label.SORG001_TAG100;}// 'Please enter a keyword first';}
    public String getTAG101() {return system.label.SORG001_TAG101;}// 'No service teams or technicians found matching the keyword';}
    public String getTAG102() {return system.label.SORG001_TAG102;}// 'No skill records found matching the keyword';}
    public String getTAG103() {return system.label.SORG001_TAG103;}// 'No products found matching the keyword';}
    public String getTAG104() {return system.label.SORG001_TAG104;}// 'Enter Technician Name';}
    public String getTAG105() {return system.label.SORG001_TAG105;}// 'Are you sure to proceed?';}
    public String getTAG106() {return system.label.SORG001_TAG106;}// 'All coverage information such as technicians, expertise, product, locations and labor cost for this service team will be removed permanently. This cannot be rolled back. Are you sure to proceed?';}
    public String getTAG107() {return system.label.SORG001_TAG107;}// 'All coverage information such as expertise, product, location and cost for this technician will be removed permanently. This cannot be rolled back. Are you sure to proceed?';}
    
    public String getTAG108() {return system.label.SORG001_TAG108;}// 'Home Base';}
    public String getTAG109() {return system.label.SORG001_TAG109;}// 'Add Home Base';}
    //public String getTAG110() {return system.label.SORG001_TAG110')?svmxTagList.get('TAG110') : 'From';}
    //public String getTAG111() {return system.label.SORG001_TAG111')?svmxTagList.get('TAG111') : 'To';}
    //public String getTAG112() {return system.label.SORG001_TAG112')?svmxTagList.get('TAG112') : 'Start Date';}
    public String getTAG113() {return system.label.SORG001_TAG113;}// 'IsCurrent';}
    public String getTAG114() {return system.label.SORG001_TAG114;}// 'Street';}
    public String getTAG115() {return system.label.SORG001_TAG115;}// 'City';}
    public String getTAG116() {return system.label.SORG001_TAG116;}// 'State';}
    public String getTAG117() {return system.label.SORG001_TAG117;}// 'Zip';}
    public String getTAG118() {return system.label.SORG001_TAG118;}// 'Country';}
    public String getTAG119() {return system.label.SORG001_TAG119;}// 'No user records found matching the keyword';}
    public String getTAG120() {return system.label.SORG001_TAG120;}// 'Please create at least one dispatcher record to save';}
    public String getTAG121() {return system.label.SORG001_TAG121;}// 'Please select a user';}
    public String getTAG122() {return system.label.SORG001_TAG122;}// 'Dispatcher';}
    public String getTAG123() {return system.label.SORG001_TAG123;}// 'Add Dispatcher';}
    public String getTAG124() {return system.label.SORG001_TAG124;}// 'Dispatcher Name';}
    public String getTAG125() {return system.label.SORG001_TAG125;}// 'User Name';}
    public String getTAG126() {return system.label.SORG001_TAG126;}// 'Search Dispatcher by entering a keyword';} 
    public String getTAG127() {return system.label.SORG001_TAG127;}// 'Only one home base can be set as current';} 
    //public String getTAG128() {return system.label.SORG001_TAG128')?svmxTagList.get('TAG128') : 'Thursday';} 
    //public String getTAG129() {return system.label.SORG001_TAG129')?svmxTagList.get('TAG129') : 'Friday';} 
    //public String getTAG130() {return system.label.SORG001_TAG130')?svmxTagList.get('TAG130') : 'Saturday';} 
    //public String getTAG131() {return system.label.SORG001_TAG131')?svmxTagList.get('TAG131') : 'Sunday';}
    //public String getTAG132() {return system.label.SORG001_TAG132')?svmxTagList.get('TAG132') : 'Please enter a valid start and end date';} 
    //public String getTAG133() {return system.label.SORG001_TAG133')?svmxTagList.get('TAG133') : 'Start date must be earlier than end date';} 
    public String getTAG134() {return system.label.SORG001_TAG134;}// 'Working Hours and overtime hours cannot be the same';} 
    public String getTAG135() {return system.label.SORG001_TAG135;}// 'Working Hours and Break hours cannot be the same';}
    
    public String getTAG136() {return system.label.SORG001_TAG136;}// 'List has No records to display';}
    public String getTAG137() {return system.label.SORG001_TAG137;}// 'Please select a service team or technician record to edit';}
    public String getTAG138() {return system.label.SORG001_TAG138;}// 'Please select a Team to create Technician';}
    public String getTAG139() {return system.label.SORG001_TAG139;}// 'All address elements can not be blank for a record';}
    //public String getTAG140() {return system.label.SORG001_TAG140')?svmxTagList.get('TAG140') : 'Please select one Home base record to edit';}        
    //public String getTAG141() {return system.label.SORG001_TAG141')?svmxTagList.get('TAG141') : 'This address is the same as the address on technician record. Home Base addresses must be different';}   
    //public String getTAG142() {return system.label.SORG001_TAG142')?svmxTagList.get('TAG142') : 'End date must be a future date';}   
    //public String getTAG143() {return system.label.SORG001_TAG143')?svmxTagList.get('TAG143') : 'Days';}   
    public String getTAG144() {return system.label.SORG001_TAG144;}// 'Duplicate Records';}   
    public String getTAG145() {return system.label.SORG001_TAG145;}// 'More than 1000 teams found. Only 1000 teams are supported in this release of ServiceMax. Please report this to your ServiceMax administrator.';}
    public String getTAG146() {return system.label.SORG001_TAG146;}// 'More than 1000 technicians found. Only 1000 technicians are supported in this release of ServiceMax. Please report this to your ServiceMax administrator.';}
    public String getTAG147() {return system.label.SORG001_TAG147;}// '';}
    public String getTAG148() {return system.label.SORG001_TAG148;}// 'City';}
    public String getTAG149() {return system.label.SORG001_TAG149;}// 'Country';}
    public String getTAG150() {return system.label.SORG001_TAG150;}// 'Phone';}
    public String getTAG151() {return system.label.SORG001_TAG151;}// 'Average Driving Speed';}//Average Speed
    public String getTAG152() {return system.label.SORG001_TAG152;}// 'Cost';}//per mile cost
    public String getTAG153() {return system.label.SORG001_TAG153;}// 'Max Round Trip Distance Daily';}// Max Distance
    public String getTAG154() {return system.label.SORG001_TAG154;}// 'Per Hour Cost';}
    public String getTAG155() {return system.label.SORG001_TAG155;}// 'Max Daily Hours';}// MMax Daily Hours With Break
    public String getTAG156() {return system.label.SORG001_TAG156;}// 'Fixed Cost';}
    public String getTAG157() {return system.label.SORG001_TAG157;}// 'Max Hours';}//Max Weekly Hours With Daily Break
    //public String getTAG158() {return system.label.SORG001_TAG158;}// 'Capacity';}
    public String getTAG159() {return system.label.SORG001_TAG159;}// 'Dispatch Factors';}
    public String getTAG160() {return system.label.SORG001_TAG160;}// 'Team/Resource';}
    public String getTAG161() {return system.label.SORG001_TAG161;}// 'ServiceMax Manage Service Org Help';}
    public String getHLPURL() {return system.label.SORG001_HLPURL;}
    //public String getTAG162() {return system.label.SORG001_TAG162;}// 'Daily Break Time (Minutes)';}
    //public String getTAG163() {return system.label.SORG001_TAG163;}// 'Max Working Hours Per Day';}
    public String getTAG164() {return system.label.SORG001_TAG164;}// '(Miles/Hour)';}
    public String getTAG165() {return system.label.SORG001_TAG165;}// '(KM/Hour)';}
    public String getTAG166() {return system.label.SORG001_TAG166;}// '(Miles)';}
    public String getTAG167() {return system.label.SORG001_TAG167;}//  '(Kilometer)';}
    public String getTAG168() {return system.label.SORG001_TAG168;}// 'Per Mile';}
    public String getTAG169() {return system.label.SORG001_TAG169;}// 'Per KM)';}
    public String getTAG170() {return system.label.SORG001_TAG170;}// 'Average Drive Time';}
    public String getTAG171() {return system.label.SORG001_TAG171;}// 'Reset';}
    public String getTAG172() {return system.label.SORG001_TAG172;}//  'Start Date';}
    public String getTAG173() {return system.label.SORG001_TAG173;}// 'End Date';}
    
    
    /********** Variable Declaration **********/
    
    public Map<String, String> svmxSettingList;
    public transient String XMLResultAsJSON ='';
    public string getXMLResult(){String xmlResult = XMLResultAsJSON;XMLResultAsJSON = ''; return xmlResult;}
    public void setXMLResult(String xmlResult){}
    
    boolean RenderDispatchTab = false;
    boolean PrdctSearch = false;
    boolean ExptSearch = false;
    boolean RenderAllTabs = false;
    boolean SearchClicked = false;
    boolean DisableButtons = false;
    boolean EnableScheduling=true;
    boolean displayResetBtn =false;
    boolean EnableAutoCheckBox = false;
    boolean CreateAutoLoc = false;
    boolean renderBreakDuration = false;
    boolean isTTExist=false;
    
    public boolean getExptSearch(){ return ExptSearch;} 
    public void setExptSearch(boolean f){this.ExptSearch=f;}
    public boolean getPrdctSearch(){return PrdctSearch;}    
    public void setPrdctSearch(boolean f){this.PrdctSearch=f;}
    public boolean getRenderAllTabs(){   return RenderAllTabs;}
    public void setRenderAllTabs(boolean b){this.RenderAllTabs =b;}     
    public boolean getSearchClicked(){   return SearchClicked;}
    public void setSearchClicked(boolean b){this.SearchClicked =b;} 
    public boolean getDisableButtons(){   return DisableButtons;}
    public void setDisableButtons(boolean b){this.DisableButtons =b;}
    public boolean getRenderDispatchTab(){return RenderDispatchTab; }
    public void setRenderDispatchTab(boolean b){this.RenderDispatchTab = b;}
    public boolean getdisplayResetBtn(){return displayResetBtn;}
    public boolean getEnableScheduling(){ return EnableScheduling; }
    public void setEnableScheduling(boolean b){ this.EnableScheduling=b; }
    public boolean getEnableAutoCheckBox(){return EnableAutoCheckBox;}
    public void setEnableAutoCheckBox(boolean b){this.EnableAutoCheckBox = b;}
    public boolean getCreateAutoLoc(){return CreateAutoLoc;}
    public void setCreateAutoLoc(boolean b){this.CreateAutoLoc = b;}
    public boolean getrenderBreakDuration(){ return renderBreakDuration; }
    public void setrenderBreakDuration(boolean b){ this.renderBreakDuration=b; }
    public boolean getTeamTechExist(){ return isTTExist; }
    public void setTeamTechExist(boolean b){ this.isTTExist=b; }
    
    boolean CheckAllExprt=false; 
    boolean CheckAllPrdct=false;
    boolean CheckAllDisp = false;
    boolean CheckAllCost=false; 
    boolean CheckAllHmeBase=false;
    
    public boolean getCheckAllExprt() {return CheckAllExprt;  }
    public boolean getCheckAllPrdct() {return CheckAllPrdct;  }
    public boolean getCheckAllCost() {return CheckAllCost;  }
    public boolean getCheckAllDisp() {return CheckAllDisp;  }
    public boolean getCheckAllHmeBase() {return CheckAllHmeBase;  }
    public void setCheckAllExprt(boolean chkAll){CheckAllExprt=chkAll;}
    public void setCheckAllPrdct(boolean chkAll){CheckAllPrdct=chkAll;}
    public void setCheckAllCost(boolean chkAll){CheckAllCost=chkAll;}
    public void setCheckAllDisp(boolean chkAll){CheckAllDisp=chkAll;}
    public void setCheckAllHmeBase(boolean chkAll){CheckAllHmeBase=chkAll;} 
    
    String TeamId='';
    string showOnlySel='';
    string googleUrl = '';
    string ConfirmMesg; 
    string RecTypeName;
    string GroupType;
    string Role;
    string BreakTyp;
    Integer serachLimit =50;
    
    public String getTeamId(){return TeamId;}
    public void setTeamId(String id){this.TeamId=id;}
    public String getShowOnlySel(){return showOnlySel;}
    public void setShowOnlySel(String showSelected){this.showOnlySel=showSelected;}
    public string getgoogleUrl(){return this.googleUrl;}
    public string getConfirmMesg(){return ConfirmMesg;}
    public void setConfirmMesg(string s){this.ConfirmMesg=s;}
    public string getRecTypeName(){ return RecTypeName;   }
    public void setRecTypeName(string r){ this.RecTypeName=r;}  
    public string getGroupType(){ return GroupType;   }
    public void setGroupType(string r){ this.GroupType=r;}
    public string getRole(){ return Role;   }
    public void setRole(string r){ this.Role=r;}
    public string getBreakTyp(){ return BreakTyp;   }
    public void setBreakTyp(string r){ this.BreakTyp=r;}
    
    public double longitude;
    public double latitude; 
    public string lstlongitude;
    public string lstlatitude;
    public string Speed;
    public string Distance;
    public string Cost;
    public string selectedTeamId;
    
    public double getlongitude(){ return longitude;}        
    public void setlongitude(double s) {
        if(s != 0 ){
            this.longitude=s;
        }
    }
    public double getlatitude(){ return latitude;}      
    public void setlatitude(double s) {
        if(s != 0){
            this.latitude=s;
        }
    }
    public string getlstlongitude(){ return lstlongitude;}      
    public void setlstlongitude(string s){ this.lstlongitude=s;}     
    public string getlstlatitude(){ return lstlatitude;}        
    public void setlstlatitude(string s){ this.lstlatitude=s;}
    public string getSpeed(){ return Speed;}        
    public void setSpeed(string s){ this.Speed=s;}
    public string getDistance(){ return Distance;}      
    public void setDistance(string s){ this.Distance=s;}
    public string getCost(){ return Cost;}      
    public void setCost(string s){ this.Cost=s;}
    
    public boolean DisplayTopBlockLevelMessage = false;
    public boolean DisplayBotBlockLevelMessage = false;
    public boolean DisplayPPLevelMessage = false;
    
    public boolean getDisplayTopBlockLevelMessage(){ return DisplayTopBlockLevelMessage; }
    public boolean getDisplayBotBlockLevelMessage(){ return DisplayBotBlockLevelMessage; }
    public boolean getDisplayPPLevelMessage(){ return DisplayPPLevelMessage; } 
    
    public SVMXC__Service_Group__c objTeam =new SVMXC__Service_Group__c();
    public SVMXC__Service_Group_Members__c  objTech = new SVMXC__Service_Group_Members__c();
    public SVMXC__Service_Group__c selectedTeam =new SVMXC__Service_Group__c();
    public SVMXC__Service_Group_Members__c selectedTeamMember =new SVMXC__Service_Group_Members__c();
    
    public SVMXC__Service_Group__c getTeam(){return objTeam;}
    public SVMXC__Service_Group_Members__c getTech(){return objTech;}
    
    boolean teamEditMode=false;
    boolean techEditMode = false;
    boolean displayTeamPopup=false;
    boolean displayTechPopup = false;
    
    public boolean geteditmode(){return teamEditMode;}   
    public void seteditmode(boolean f){this.teamEditMode=f;}
    public boolean getTechEditMode(){return techEditMode;}   
    public void setTechEditMode(boolean f){this.techEditMode=f;}
    public boolean getdisplayTeamPopup(){ return displayTeamPopup; }
    public boolean getdisplayTechPopup(){ return displayTechPopup; } 
    
    boolean HomeBaseTab = false;
    boolean AddrsError = false; 
    public boolean getHomeBaseTab(){return HomeBaseTab; }
    public void setHomeBaseTab(boolean b){this.HomeBaseTab = b;}
    public integer getaddline (){return lstHomeBase.size();}
    public void setaddline (Integer i){}
    public boolean getAddrsError(){return AddrsError; }
    public void setAddrsError(boolean b){this.AddrsError = b;}
    
    public List<SVMXC__Service_Group_Skills__c> lstGroupExpertise = new List<SVMXC__Service_Group_Skills__c>();
    public list<SVMXC__Service_Group_Costs__c> lstLaborCost = new list<SVMXC__Service_Group_Costs__c>();
    public List<SVMXC__Service_Group_Product__c> lstGroupProduct = new List<SVMXC__Service_Group_Product__c>();
    public List<SVMXC__Service_Group_Site__c> lstHomeBase = new List<SVMXC__Service_Group_Site__c>();
    public List<SVMXC__Dispatcher_Access__c> lstGroupDispatcher = new List<SVMXC__Dispatcher_Access__c>();
    
    public List<SVMXC__Service_Group_Skills__c> getExprtList(){return  lstGroupExpertise;}
    public List<SVMXC__Service_Group_Product__c> getprodList(){return lstGroupProduct;}
    public List<SVMXC__Service_Group_Costs__c> getLaborCostList(){ return lstLaborCost;}
    public List<SVMXC__Service_Group_Site__c> getHomeBaseList(){return lstHomeBase;}
    public List<SVMXC__Dispatcher_Access__c> getDsptchrList(){return lstGroupDispatcher;}
    
    public SVMXC__Service_Group_Site__c objHomeBase;
    public List<User> lstUser = new List<User>();
    public List<Product2> lstExpertiseProduct = new List<Product2>();
    public List<SVMXC__Skill__c> lstExpertiseSkill = new List<SVMXC__Skill__c>();
    
    public List<User> getUserList(){return lstUser;}
    public List<Product2> getPrdcts(){ return lstExpertiseProduct;}
    public List<SVMXC__Skill__c> getSkillList(){return lstExpertiseSkill;}
    public SVMXC__Service_Group_Site__c getHomeBaseObj(){return objHomeBase;}
    
    /********** Variable Declaration Ends**********/
    
    
    public SORG_ManageTeamTech(){  
        SVMXC.COMM_Utils_ManageSettings commSettings = new SVMXC.COMM_Utils_ManageSettings();
        svmxSettingList = commSettings.SVMX_getSettingList('SORG001');
        
        if(svmxSettingList!=null && svmxSettingList.containsKey('SET003'))
            serachLimit = Integer.valueOf(svmxSettingList.get('SET003'));
        
        if(getGBL011()!=null && getGBL011()!=''){
            googleUrl = 'https://maps.googleapis.com/maps/api/js?sensor=false&client='; 
            googleUrl+=getGBL011();
        }               
        else{
            googleUrl = 'https://maps.googleapis.com/maps/api/js?sensor=false&client=';
            googleUrl+=getGBL001();
        }
        
        if(getGBL006()=='Mile'){
            Speed = getTAG151() +' '+getTAG164();
            Distance = getTAG153() +' ' + getTAG166();
            Cost = getTAG152() +' '+ getTAG168();
        }
        else if(getGBL006()=='Kilometer'){
            Speed = getTAG151() +' '+ getTAG165();
            Distance = getTAG153() +' '+ getTAG167();
            Cost = getTAG152() +' '+ getTAG169();
        }
        
        TeamId = System.currentPageReference().getParameters().get('TId'); 
        ShowOnlySel = System.currentPageReference().getParameters().get('ShowOnlySel');
        
        if(TeamId!='' && TeamId !=null && ShowOnlySel =='1'){
            list<SVMXC__Service_Group__c> lstTeam = [Select Id, Name From SVMXC__Service_Group__c where Name != '' AND Id =:TeamId limit 1];
            
            if(lstTeam.isEmpty()){
                list<SVMXC__Service_Group_Members__c> lstTech = [Select Id, Name, SVMXC__Service_Group__c from SVMXC__Service_Group_Members__c where  Name != '' AND Id =: TeamId limit 1];
                if(!lstTech.isEmpty())
                    selectedTeamId = lstTech[0].SVMXC__Service_Group__c;
            }   
            else selectedTeamId = lstTeam[0].Id; 
        }
        onLoad();
    }
    
    public void onLoad(){ 
        isTTExist = false;
        activateBlockMsg('TOP');
        set<Id> lstTeamId = new set<Id>();
        list<SVMXC__Service_Group__c> lstTeam = new list<SVMXC__Service_Group__c>();
        list<SVMXC__Service_Group_Members__c> lstTech = new list<SVMXC__Service_Group_Members__c>();
        try{
            UnloadTeam();
            if(showOnlySel !='1'){
                lstTech = [Select Id, Name, SVMXC__City__c, SVMXC__Country__c, SVMXC__Phone__c, SVMXC__Service_Group__c, SVMXC__Service_Group__r.Name from SVMXC__Service_Group_Members__c where  Name != '' AND SVMXC__Service_Group__c !=null order by SVMXC__Service_Group__r.Name,Name asc];
                
                lstTeam = [Select Id,  SVMXC__Phone__c,  SVMXC__Country__c, SVMXC__City__c, Name From SVMXC__Service_Group__c where Name != '' order by Name asc];
            }
            else if(selectedTeamId !='' && selectedTeamId!=null){
                lstTeam = [Select Id, SVMXC__Phone__c, SVMXC__Country__c, SVMXC__City__c, Name From SVMXC__Service_Group__c where Name != '' AND Id =:selectedTeamId limit 1];
                
                lstTech = [Select Id, Name, SVMXC__City__c, SVMXC__Country__c, SVMXC__Phone__c, SVMXC__Service_Group__c, SVMXC__Service_Group__r.Name from SVMXC__Service_Group_Members__c where  Name != '' AND SVMXC__Service_Group__c =:selectedTeamId order by SVMXC__Service_Group__r.Name,Name asc];
            }
            getXMLResultAsJSON(lstTeam, lstTech);
        }
        catch (Exception ex){
            ApexPages.addMessage(new ApexPages.Message ( ApexPages.Severity.ERROR, ex.getMessage())); 
        }
    }
    
    public void SVMX_AdvTeamSearch(){ 
        String searchText = Keyword;
        boolean isPrdctSearch = PrdctSearch;
        boolean isExptSearch = ExptSearch;
        UnloadTeam();
        TeamId ='';
        Keyword = searchText;
        PrdctSearch = isPrdctSearch;
        ExptSearch = isExptSearch;
        SearchClicked = displayResetBtn = true;
        activateBlockMsg('TOP');
        
        string strKeyword;
        if(!(Keyword==null || Keyword=='')){
            set<Id> lstTeamId = new set<Id>();    
            list<SVMXC__Service_Group__c> lstTeam = new list<SVMXC__Service_Group__c>();
            list<SVMXC__Service_Group_Members__c> lstTech = new list<SVMXC__Service_Group_Members__c>();
            try{
                if(Keyword.contains('\''))
                    strKeyword = String.escapeSingleQuotes(Keyword.replaceAll('\'', '\\\''));
                else
                    strKeyword = String.escapeSingleQuotes(Keyword);
                system.debug(logginglevel.warn,'Keyword:  '+Keyword);   
                if(PrdctSearch || ExptSearch){  
                    // String ExpString = 'Select SVMXC__Skill__c,SVMXC__Skill__r.Name, SVMXC__Service_Group__c From SVMXC__Service_Group_Skills__c where SVMXC__Skill__r.Name like \'%'+String.escapeSingleQuotes(Keyword.replace('\'', '\\\''))+'%\'';
                    
                    string ExpString;
                    
                    ExpString = 'Select SVMXC__Skill__c,SVMXC__Skill__r.Name, SVMXC__Service_Group__c From SVMXC__Service_Group_Skills__c where SVMXC__Skill__r.Name like \'%'+strKeyword+'%\'';
                    
                    //String PrdString = 'Select SVMXC__Service_Group__c, SVMXC__Product__c,SVMXC__Product__r.Name  From SVMXC__Service_Group_Product__c where SVMXC__Product__r.Name like \'%'+String.escapeSingleQuotes(Keyword.replace('\'', '\\\''))+'%\'';
                    string PrdString;
                    
                    PrdString = 'Select SVMXC__Service_Group__c, SVMXC__Product__c,SVMXC__Product__r.Name  From SVMXC__Service_Group_Product__c where SVMXC__Product__r.Name like \'%'+strKeyword+'%\'';
                    
                    
                    if(showOnlySel=='1'){
                        ExpString += ' AND SVMXC__Service_Group__c =\''+selectedTeamId+'\'';  
                        PrdString += ' AND SVMXC__Service_Group__c =\''+selectedTeamId+'\''; 
                    }
                    
                    if(ExptSearch){
                        for(SVMXC__Service_Group_Skills__c objGroupExpertise :Database.query(ExpString))
                            lstTeamId.add(objGroupExpertise.SVMXC__Service_Group__c);     
                    }
                    if(PrdctSearch){
                        for(SVMXC__Service_Group_Product__c objGroupProduct :Database.query(PrdString))
                            lstTeamId.add(objGroupProduct.SVMXC__Service_Group__c);     
                    }
                    lstTech = [Select Id, Name, SVMXC__City__c, SVMXC__Country__c, SVMXC__Phone__c, SVMXC__Service_Group__c, SVMXC__Service_Group__r.Name from SVMXC__Service_Group_Members__c where SVMXC__Service_Group__c in:lstTeamId order by SVMXC__Service_Group__r.Name,Name asc];
                    
                    lstTeam = [Select Id,  SVMXC__Phone__c,  SVMXC__Country__c, SVMXC__City__c, Name From SVMXC__Service_Group__c where  Name != '' AND Id in:lstTeamId order by Name asc];
                }               
                else{ 
                    if(showOnlySel !='1'){
                        string strTech;
                        //lstTech =  [Select Id, Name, SVMXC__Service_Group__c from SVMXC__Service_Group_Members__c where Name like:'%'+String.escapeSingleQuotes(Keyword)+'%' order by Name asc];
                        strTech =  'Select Id, Name, SVMXC__Service_Group__c from SVMXC__Service_Group_Members__c where Name like \'%'+ strKeyword +'%\' order by Name asc';
                        
                        system.debug(logginglevel.warn,'strTech:  '+strTech);
                        
                        lstTech = Database.query(strTech);
                        if(!lstTech.isEmpty()){
                            lstTeamId.add(lstTech[0].SVMXC__Service_Group__c);
                            for(SVMXC__Service_Group_Members__c tech : lstTech){
                                if(tech.SVMXC__Service_Group__c!=null && !lstTeamId.contains(tech.SVMXC__Service_Group__c))
                                    lstTeamId.add(tech.SVMXC__Service_Group__c);
                            }
                        }
                        
                        // lstTeam = [Select Id,  SVMXC__Phone__c,  SVMXC__Country__c, SVMXC__City__c, Name From SVMXC__Service_Group__c where  Name != '' AND (Id in:lstTeamId OR Name like:'%'+String.escapeSingleQuotes(Keyword)+'%') order by Name asc];
                        string strTeam;
                        
                        strTeam = 'Select Id,  SVMXC__Phone__c,  SVMXC__Country__c, SVMXC__City__c, Name From SVMXC__Service_Group__c where  Name != \'\' AND (Id in:lstTeamId OR Name like \'%'+strKeyword +'%\') order by Name asc';
                        lstTeam = Database.query(strTeam);
                        if(!lstTeam.isEmpty())
                            lstTech =  [Select Id, Name, SVMXC__City__c, SVMXC__Country__c, SVMXC__Phone__c, SVMXC__Service_Group__c, SVMXC__Service_Group__r.Name from SVMXC__Service_Group_Members__c where SVMXC__Service_Group__c in:lstTeam order by SVMXC__Service_Group__r.Name,Name asc];
                    }
                    else if(selectedTeamId !='' && selectedTeamId!=null){
                        //lstTech =  [Select Id, Name, SVMXC__City__c, SVMXC__Country__c, SVMXC__Phone__c, SVMXC__Service_Group__c, SVMXC__Service_Group__r.Name from SVMXC__Service_Group_Members__c where (Name like:'%'+String.escapeSingleQuotes(Keyword)+'%' OR SVMXC__Service_Group__r.Name like:'%'+String.escapeSingleQuotes(Keyword)+'%') AND SVMXC__Service_Group__c =:selectedTeamId order by SVMXC__Service_Group__r.Name,Name asc];
                        
                        string strTech1;
                        strTech1 =  'Select Id, Name, SVMXC__City__c, SVMXC__Country__c, SVMXC__Phone__c, SVMXC__Service_Group__c, SVMXC__Service_Group__r.Name from SVMXC__Service_Group_Members__c where (Name like \'%'+strKeyword+'%\' OR SVMXC__Service_Group__r.Name like \'%'+strKeyword+'%\') AND SVMXC__Service_Group__c =:selectedTeamId order by SVMXC__Service_Group__r.Name,Name asc';
                        lstTech = Database.query(strTech1);
                        if(!lstTech.isEmpty())
                            lstTeam = [Select Id,  SVMXC__Phone__c,  SVMXC__Country__c, SVMXC__City__c, Name From SVMXC__Service_Group__c where Name != '' AND Id =:selectedTeamId limit 1];
                        else{
                            string StrTeam1;
                            //lstTeam = [Select Id,  SVMXC__Phone__c,  SVMXC__Country__c, SVMXC__City__c, Name From SVMXC__Service_Group__c where Name like:'%'+Keyword+'%' AND Id =:selectedTeamId limit 1];
                            
                            StrTeam1 = 'Select Id,  SVMXC__Phone__c,  SVMXC__Country__c, SVMXC__City__c, Name From SVMXC__Service_Group__c where Name like \'%'+strKeyword+'%\' AND Id =:selectedTeamId limit 1';
                            lstTeam = Database.query(StrTeam1);  
                            
                        }
                    }
                }
                lstTeamId.clear();
                getXMLResultAsJSON(lstTeam, lstTech);
            }
            catch (Exception ex){
                ApexPages.addMessage(new ApexPages.Message ( ApexPages.Severity.ERROR, ex.getMessage())); 
            }
        }
        else ApexPages.addMessage(new ApexPages.Message ( ApexPages.Severity.ERROR, getTAG100()));      
    }
    
    void getXMLResultAsJSON(list<SVMXC__Service_Group__c> lstTeam, list<SVMXC__Service_Group_Members__c> lstTech){
        XMLResultAsJSON ='';
        //Fixed defect 043837: If Site prefix is available we are adding to generate the URL
        // String prefix=Site.getPrefix(); This method is outdated in the latest API
        String prefix=Site.getPathPrefix();
        if(prefix!=null && prefix!='')
        {
            prefix = prefix+'/';
        }else
        {
            prefix = '/';
        }
     
        map<Id,string> mapTeamIdXMLData =new map<Id,string>();
        for(SVMXC__Service_Group_Members__c tech : lstTech){
            list<String> techData = (tech.Name+':'+tech.SVMXC__City__c+':'+tech.SVMXC__Country__c+':'+tech.SVMXC__Phone__c).replace('&', '&amp;').replace('<', '&lt;').replace('>', '&gt;').replace('/"', '&quot;').replace('null',' ').replace('&','&#38;').replace('^','&#94;').replace('<','&#60;').replace('>','&#62;').replace('\n',' ').replace('/','&#47;').replace('\\','&#92;').replace('"','&#34;').replace('\'','&#39;').split(':',5); 
            //Fixed defect 043837: If Site prefix is available we are adding to generate the URL
                if(!mapTeamIdXMLData.containsKey(tech.SVMXC__Service_Group__r.Id))
                    mapTeamIdXMLData.put(tech.SVMXC__Service_Group__r.Id, '<row id=\''+tech.Id+'\' open=\'1\'><cell>0</cell><cell image=\'../images/icons/user.png\'><![CDATA[<a href='+prefix+tech.Id+'>'+techData[0]+'</a>]]></cell><cell>'+techData[1]+'</cell><cell>'+techData[2]+'</cell><cell>'+techData[3]+'</cell></row>');
                else 
                    mapTeamIdXMLData.put(tech.SVMXC__Service_Group__r.Id, mapTeamIdXMLData.get(tech.SVMXC__Service_Group__r.Id)+'<row id=\''+tech.Id+'\' open=\'1\'><cell>0</cell><cell image=\'../images/icons/user.png\'><![CDATA[<a href='+prefix+tech.Id+'>'+techData[0]+'</a>]]></cell><cell>'+techData[1]+'</cell><cell>'+techData[2]+'</cell><cell>'+techData[3]+'</cell></row>');
            
            if(!isTTExist && String.valueOf(tech.Id) == TeamId )
                isTTExist =true;    
            
        }
        lstTech.clear();
        
        integer count=0;
        map<integer,String> mapTeamXmlData =new map<integer,String>();
        for(SVMXC__Service_Group__c team: lstTeam){
            list<String> teamData =(team.name+':'+team.SVMXC__City__c+':'+team.SVMXC__Country__c+':'+team.SVMXC__Phone__c).replace('&', '&amp;').replace('<', '&lt;').replace('>', '&gt;').replace('/"', '&quot;').replace('null',' ').replace('&','&#38;').replace('^','&#94;').replace('<','&#60;').replace('>','&#62;').replace('\n',' ').replace('/','&#47;').replace('\\','&#92;').replace('"','&#34;').replace('\'','&#39;').split(':',4);
            //Fixed defect 043837: If Site prefix is available we are adding to generate the URL
            if(!mapTeamIdXMLData.containsKey(team.Id))
                mapTeamXmlData.put(count++,'<row id=\''+team.Id+'\' open=\'1\'><cell>0</cell><cell image=\'../images/icons/user.png\'><![CDATA[<a href='+prefix+team.Id+'>'+teamData[0]+'</a>]]></cell><cell>'+teamData[1]+'</cell><cell>'+teamData[2]+'</cell><cell>'+teamData[3]+'</cell>');               
            else
                mapTeamXmlData.put(count++,'<row id=\''+team.Id+'\' open=\'1\'><cell>0</cell><cell image=\'../images/icons/user.png\'><![CDATA[<a href='+prefix+team.Id+'>'+teamData[0]+'</a>]]></cell><cell>'+teamData[1]+'</cell><cell>'+teamData[2]+'</cell><cell>'+teamData[3]+'</cell>'+mapTeamIdXMLData.get(team.Id));
            
            if(!isTTExist && String.valueOf(team.Id) == TeamId )
                isTTExist =true;    
            
        } 
        lstTeam.clear();
        mapTeamIdXmlData.clear();
        
        if(mapTeamXmlData.size()>0)
            XMLResultAsJSON = JSON.serialize(mapTeamXmlData);
        else if(SearchClicked)
            ApexPages.addMessage(new ApexPages.Message ( ApexPages.Severity.ERROR, getTAG101()));
        else ApexPages.addMessage(new ApexPages.Message ( ApexPages.Severity.ERROR, getTAG136()));
        mapTeamXmlData.clear();
    }
    
    public PageReference loadTeam(){
        if(TeamId!=null && TeamId!=''){
            try{
                UnloadTeam();
                activateBlockMsg('TOP');    
                boolean isTTExist =true;
                list<SVMXC__Service_Group__c> lstServiceGroup = [select Id from SVMXC__Service_Group__c where Id =:TeamId limit 1]; 
                if(lstServiceGroup.size()>0){
                    selectedTeam = lstServiceGroup[0];
                    
                    lstGroupExpertise=[Select SVMXC__Skill__c,SVMXC__Skill__r.Id, SVMXC__Select__c,SVMXC__Skill_Level__c, SVMXC__Service_Group__c, SVMXC__Group_Member__c, SVMXC__Availability_Start_Date__c,SVMXC__Availability_End_Date__c, Name From SVMXC__Service_Group_Skills__c where SVMXC__Service_Group__c =:selectedTeam.id and SVMXC__Group_Member__c=:null];
                    
                    lstGroupProduct=[Select SVMXC__Select__c,SVMXC__Service_Group__c, SVMXC__Product__c, Name From SVMXC__Service_Group_Product__c  where SVMXC__Service_Group__c =:selectedTeam.id and SVMXC__Group_Member__c=:null];
                    
                    lstLaborCost=[Select Id,SVMXC__Service_Group__c, SVMXC__Hourly_Cost2__c, SVMXC__Group_Member__c, SVMXC__Cost_Category__c, SVMXC__Billable_Cost2__c, SVMXC__Select__c From SVMXC__Service_Group_Costs__c where SVMXC__Service_Group__c =:selectedTeam.id and SVMXC__Group_Member__c=:null];
                    
                    if(lstGroupExpertise.size()>0 || lstGroupProduct.size()>0 || lstLaborCost.size()>0)
                        ConfirmMesg = getTAG106();
                    else ConfirmMesg = getTAG105();
                    
                    HomeBaseTab = false;
                    RenderDispatchTab = true;
                }
                else{
                    list<SVMXC__Service_Group_Members__c> lstServiceGroupMember = [select Id,SVMXC__Service_Group__c from SVMXC__Service_Group_Members__c where Id =:TeamId limit 1]; 
                    if(lstServiceGroupMember.size()>0){
                        selectedTeamMember = lstServiceGroupMember[0];
                        
                        lstGroupExpertise=[Select SVMXC__Skill__c, SVMXC__Skill__r.Id,SVMXC__Select__c,SVMXC__Skill_Level__c, SVMXC__Service_Group__c, SVMXC__Group_Member__c, SVMXC__Availability_Start_Date__c,SVMXC__Availability_End_Date__c, Name From SVMXC__Service_Group_Skills__c where SVMXC__Group_Member__c=:selectedTeamMember.id];
                        
                        lstGroupProduct=[Select SVMXC__Select__c,SVMXC__Service_Group__c, SVMXC__Product__c, Name From SVMXC__Service_Group_Product__c  where SVMXC__Group_Member__c=:selectedTeamMember.id];
                        
                        lstLaborCost=[Select Id,SVMXC__Service_Group__c, SVMXC__Hourly_Cost2__c, SVMXC__Group_Member__c, SVMXC__Cost_Category__c, SVMXC__Billable_Cost2__c, SVMXC__Select__c From SVMXC__Service_Group_Costs__c where  SVMXC__Group_Member__c=:selectedTeamMember.id];
                        
                        if(lstGroupExpertise.size()>0 || lstGroupProduct.size()>0 || lstLaborCost.size()>0)
                            ConfirmMesg = getTAG107();
                        else ConfirmMesg = getTAG105();
                        
                        HomeBaseTab = true;
                        RenderDispatchTab = false;
                    }
                    else isTTExist =false;
                }
                
                if(isTTExist){
                    lstHomeBase = [Select SVMXC__Site__c, SVMXC__IsCurrent__c,SVMXC__Select__c,SVMXC__Days__c,SVMXC__Service_Group__c, SVMXC__Zip__c, SVMXC__Working_Hours__c, SVMXC__Technician_Equipment__c, SVMXC__Street__c, SVMXC__State__c, SVMXC__Start_Date__c, SVMXC__Overtime_Hours__c, SVMXC__Longitude__c, SVMXC__Latitude__c, SVMXC__End_Date__c, SVMXC__Country__c, SVMXC__City__c, SVMXC__Break_Hours__c, RecordTypeId, Id From SVMXC__Service_Group_Site__c where SVMXC__Technician_Equipment__c=:TeamId and RecordType.Name='Home Bases' order by CreatedDate asc];
                    
                    lstGroupDispatcher = [select Id,Name,SVMXC__Select__c,SVMXC__Service_Team__c,SVMXC__Dispatcher__c from SVMXC__Dispatcher_Access__c where SVMXC__Service_Team__c=:TeamId];
                    
                    RenderAllTabs = true;
                }
                else ApexPages.addMessage(new ApexPages.Message (ApexPages.Severity.ERROR, getTAG092()));
            }
            catch(Exception ex){
                UnloadTeam();
                ApexPages.addMessage(new ApexPages.Message (ApexPages.Severity.ERROR, ex.getMessage()));
            }
        }
        else ApexPages.addMessage(new ApexPages.Message (ApexPages.Severity.ERROR, getTAG092()));
        return  null;      
    }
    
    public PageReference UnloadTeam(){
        selectedTeam =new SVMXC__Service_Group__c();
        selectedTeamMember=new SVMXC__Service_Group_Members__c();
        objTeam =new SVMXC__Service_Group__c();
        objTech = new SVMXC__Service_Group_Members__c();
        lstGroupExpertise.clear();
        lstGroupProduct.clear();
        lstLaborCost.clear();
        lstHomeBase.clear();  
        lstGroupDispatcher.clear();
        lstExpertiseSkill.clear();
        lstExpertiseProduct.clear();
        lstUser.clear();
        uncheckCheckbox();
        teamEditMode= techEditMode = displayTeamPopup = displayTechPopup = RenderAllTabs = displayResetBtn = SearchClicked = HomeBaseTab = RenderDispatchTab = DisableButtons = PrdctSearch = ExptSearch = false;
        keyword = ExprtKywrd = PrdctKywrd = DispKywrd ='';
        return null;        
    }
    
    
    
    /*************** Team Attributes (New,Edit,Delete,Show,Save,Cancel Functioanlity Methods) Block Starts***************/
    
    public Void SVMX_AddnewTeam(){ 
        teamEditMode=false;
        displayTechPopup=false;
        displayTeamPopup=true;
        DisableButtons = true;
        SearchClicked = false;  
        Schema.DescribeFieldResult f = SVMXC__Service_Group__c.SVMXC__Group_Type__c.getDescribe();    
        for(Schema.PicklistEntry pe : f.getPicklistValues()) {        
            if(pe.isDefaultValue()) 
                GroupType =  pe.getLabel();
        }
        objTeam = new SVMXC__Service_Group__c();
        if(GroupType!=null || GroupType!='')
            objTeam.SVMXC__Group_Type__c = GroupType;       
    }       
    
    public PageReference SVMX_SaveTeam(){
        try {
            activateBlockMsg('POPUP');      
            if(objTeam.Name!=null){
                List<SVMXC__Service_Group__c> lstServiceGroup= [Select name from SVMXC__Service_Group__c where name =:objTeam.Name limit 1];
                if(lstServiceGroup.size() >0 && !teamEditMode)
                    ApexPages.addMessage(new ApexPages.Message ( ApexPages.Severity.ERROR,getTAG089()));                    
                else{          
                    //This condition added by Naveen V : 21/July/2011
                    if((objTeam.Street__c == null || objTeam.Street__c == '') && (objTeam.City__c == null || objTeam.City__c == '') && (objTeam.State__c == null || objTeam.State__c == '') && (objTeam.Zip__c == null || objTeam.Zip__c == '') && (objTeam.Country__c == null || objTeam.Country__c == '--None--')){
                        latitude = null;
                        longitude = null;
                    }
                    objTeam.SVMXC__Latitude__c = latitude; //(commented by amar on 12/3/10 at 12:40 PM)
                    objTeam.SVMXC__Longitude__c = longitude; //(commented by amar on 12/3/10 at 12:40 PM)
                    
                    //upsert objTeam;
                    if( COMM_SecurityUtils.getInstance().verifyFieldAccess( objTeam, COMM_SecurityUtils.Access.Upsertable ) ) { //SDL-SVMX-CREATE-UPDATE-FLS-ENFORCED
                        upsert objTeam;
                    } else {
                        ApexPages.addMessage(new ApexPages.Message ( ApexPages.Severity.ERROR, System.Label.COMM001_TAG142 ) );
                        return null;
                    }
                    if(objTeam.id!=null)
                        selectedTeamId = TeamId = objTeam.id;
                    
                    ApexPages.addMessage(new ApexPages.Message ( ApexPages.Severity.CONFIRM,system.label.COMM001_TAG058,''));
                    onLoad();
                }
            }
            else
                ApexPages.addMessage(new ApexPages.Message ( ApexPages.Severity.ERROR, getTAG090()));
        }            
        catch(Exception e){
            ApexPages.addMessage(new ApexPages.Message ( ApexPages.Severity.ERROR,e.getMessage()));
        }
        return null;
    }
    
    public Void SVMX_AddnewTech(){
        if(TeamId!=null && TeamId!='' && TeamId==selectedTeam.Id){
            displayTechPopup=true;
            displayTeamPopup=false; 
            DisableButtons = true;
            SearchClicked = false;
            techEditMode = false;
            EnableAutoCheckBox = true;
            EnableScheduling = true;
            Schema.DescribeFieldResult g = SVMXC__Service_Group_Members__c.SVMXC__Break_Type__c.getDescribe();
            Schema.DescribeFieldResult f = SVMXC__Service_Group_Members__c.SVMXC__Role__c.getDescribe();        
            for(Schema.PicklistEntry pe : f.getPicklistValues()) {        
                if(pe.isDefaultValue()) 
                    Role =  pe.getLabel();
            }
            for(Schema.PicklistEntry bpe : g.getPicklistValues()){      
                if(bpe.isDefaultValue()) 
                    BreakTyp = bpe.getLabel();
            }
            objTech = new SVMXC__Service_Group_Members__c();
            if(Role!=null || Role!='')
                objTech.SVMXC__Role__c = Role;
            objTech.SVMXC__Service_Group__c= selectedTeam.Id;
            objTech.SVMXC__Break_Type__c = 'Fixed';
            if(objTech.Salesforce_User__c!=null)
                EnableScheduling=false;
            showBreakDuration();
        }
        else{
            activateBlockMsg('TOP');
            displayTechPopup=false;
            displayTeamPopup=false; 
            DisableButtons = false;
            ApexPages.addMessage(new ApexPages.Message ( ApexPages.Severity.ERROR,getTAG138()));
        } 
    }   
    
    public PageReference SVMX_SaveTech(){           
        try{
            activateBlockMsg('POPUP');
            if(objTech.Name!=null){ 
                objTech.SVMXC__Break_Type__c = 'Fixed';
                list<SVMXC__Territory__c> lstTerritory= new list<SVMXC__Territory__c>();   
                
                if(objTech.Service_Territory__c!=null ){
                    lstTerritory = [Select Id,Name,SVMXC__Break_Hours__c, SVMXC__Average_Driving_Time__c, SVMXC__Territory_s_Business_Hours__c,SVMXC__Description__c,SVMXC__Parent_Territory__c,SVMXC__Active__c,SVMXC__Territory_Code__c, SVMXC__Per_Mile_Cost__c, SVMXC__Per_Hour_Cost__c, SVMXC__Max_Hours__c, SVMXC__Max_Distance__c, SVMXC__Max_Daily_Hours__c, SVMXC__Fixed_Cost__c, SVMXC__Average_Speed__c From SVMXC__Territory__c where id =:objTech.Service_Territory__c];
                }
                
                if(objTech.SVMXC__Average_Speed__c ==null && lstTerritory.size()>0)
                    objTech.SVMXC__Average_Speed__c = lstTerritory[0].SVMXC__Average_Speed__c;
                
                if(objTech.SVMXC__Per_Mile_Cost__c ==null && lstTerritory.size()>0)
                    objTech.SVMXC__Per_Mile_Cost__c = lstTerritory[0].SVMXC__Per_Mile_Cost__c;
                
                if(objTech.SVMXC__Max_Distance__c ==null && lstTerritory.size()>0)
                    objTech.SVMXC__Max_Distance__c = lstTerritory[0].SVMXC__Max_Distance__c;
                
                if(objTech.SVMXC__Per_Hour_Cost__c ==null && lstTerritory.size()>0)
                    objTech.SVMXC__Per_Hour_Cost__c = lstTerritory[0].SVMXC__Per_Hour_Cost__c;
                
                if(objTech.SVMXC__Max_Daily_Hours__c ==null && lstTerritory.size()>0)
                    objTech.SVMXC__Max_Daily_Hours__c = lstTerritory[0].SVMXC__Max_Daily_Hours__c;
                
                if(objTech.SVMXC__Fixed_Cost__c ==null && lstTerritory.size()>0)
                    objTech.SVMXC__Fixed_Cost__c = lstTerritory[0].SVMXC__Fixed_Cost__c;
                
                if(objTech.SVMXC__Max_Hours__c ==null && lstTerritory.size()>0)
                    objTech.SVMXC__Max_Hours__c = lstTerritory[0].SVMXC__Max_Hours__c;
                
                if(objTech.SVMXC__Break_Hours__c ==null && lstTerritory.size()>0)
                    objTech.SVMXC__Break_Hours__c = lstTerritory[0].SVMXC__Break_Hours__c; 
                
                //Neeraj(Nov-15th): added due to handle average drive time(Defect-002645)
                if(objTech.SVMXC__Average_Drive_Time__c!=null && lstTerritory.size()>0 && !techEditMode)
                    objTech.SVMXC__Average_Drive_Time__c = lstTerritory[0].SVMXC__Average_Driving_Time__c;
                
                //This condition added by Naveen V : 21/July/2011
                if((objTech.Street__c == null || objTech.Street__c == '') && (objTech.City__c == null || objTech.City__c == '') && (objTech.State__c == null || objTech.State__c == '') && (objTech.Zip__c == null || objTech.Zip__c == '') && (objTech.Country__c == null || objTech.Country__c == '--None--')){
                    latitude = null;
                    longitude = null;
                }
                objTech.SVMXC__Latitude__c = latitude;
                objTech.SVMXC__Longitude__c = longitude;
                
                boolean IsOvrTimSame = false;
                boolean IsBrkTimSame = false;
                
                if(objTech.Working_Hours__c!=null){
                    if(objTech.SVMXC__Overtime_Hours__c!=null){
                        if(objTech.Working_Hours__c==objTech.SVMXC__Overtime_Hours__c)
                            IsOvrTimSame = true;
                    }
                    else if(objTech.Break_Hours__c!=null){
                        if(objTech.Working_Hours__c==objTech.Break_Hours__c)
                            IsBrkTimSame = true;
                    }
                }
                else if(lstTerritory.size()>0 && !techEditMode)
                    objTech.Working_Hours__c = lstTerritory[0].SVMXC__Territory_s_Business_Hours__c;
                
                if(IsOvrTimSame){
                    ApexPages.addMessage(new ApexPages.Message ( ApexPages.Severity.ERROR, getTAG134()));
                    IsOvrTimSame = false;
                }
                else if(IsBrkTimSame){
                    ApexPages.addMessage(new ApexPages.Message ( ApexPages.Severity.ERROR, getTAG135()));
                    IsBrkTimSame = false;
                }   
                else {
                    if(!techEditMode){                
                        if(CreateAutoLoc==true && objTech.SVMXC__Inventory_Location__c==null){   
                            SVMXC__Site__c TechLoc = new SVMXC__Site__c();
                            TechLoc.Name = objTech.Name;
                            TechLoc.SVMXC__Street__c = objTech.Street__c;
                            TechLoc.SVMXC__City__c = objTech.City__c;
                            TechLoc.SVMXC__State__c = objTech.State__c;
                            TechLoc.SVMXC__Zip__c = objTech.Zip__c;
                            TechLoc.SVMXC__Country__c = objTech.Country__c;
                            TechLoc.SVMXC__Site_Phone__c = objTech.Phone__c; 
                            
                            if(Schema.SObjectType.SVMXC__Site__c.fields.getMap().containsKey('Stocking_Location__c'))
                                TechLoc.put('SVMXC__Stocking_Location__c',true);
                            //insert TechLoc;
                            if( COMM_SecurityUtils.getInstance().verifyFieldAccess( TechLoc, COMM_SecurityUtils.Access.Createable ) ) {     //SDL-SVMX-CREATE-UPDATE-FLS-ENFORCED
                                insert TechLoc;
                            } else {
                                activateBlockMsg('POPUP');
                                ApexPages.addMessage(new ApexPages.Message ( ApexPages.Severity.ERROR, System.Label.COMM001_TAG142 ) );
                                return null;
                            }
                            objTech.Inventory_Location__c = TechLoc.Id;                        
                        }
                        CreateAutoLoc=false;
                        EnableScheduling = true;
                    }
                    //upsert objTech;
                    if( COMM_SecurityUtils.getInstance().verifyFieldAccess( objTech, COMM_SecurityUtils.Access.Upsertable ) ) { //SDL-SVMX-CREATE-UPDATE-FLS-ENFORCED
                        upsert objTech;
                    } else {
                        activateBlockMsg('POPUP');
                        ApexPages.addMessage(new ApexPages.Message ( ApexPages.Severity.ERROR, System.Label.COMM001_TAG142 ) );
                        return null;
                    }
                    if(objTech.Id !=null)
                        TeamId = objTech.Id;
                    ApexPages.addMessage(new ApexPages.Message ( ApexPages.Severity.CONFIRM,system.label.COMM001_TAG058,''));
                    onLoad();
                }                       
            }
            else ApexPages.addMessage(new ApexPages.Message (ApexPages.Severity.ERROR, getTAG104()));    
        }
        catch(exception ex){
            activateBlockMsg('POPUP');
            ApexPages.addMessage(new ApexPages.Message ( ApexPages.Severity.ERROR, ex.getMessage()));
        }
        return null;
    }
    
    public void SVMX_EditTeamTech(){
        boolean isTTExist =true;
        if(TeamId!=null && TeamId!='' && (TeamId == selectedTeam.Id || TeamId == selectedTeamMember.Id)){
            activateBlockMsg('POPUP');
            DisableButtons = true;
            EnableAutoCheckBox = false;  
            SearchClicked = false;
            objTeam = new SVMXC__Service_Group__c();
            objTech = new SVMXC__Service_Group_Members__c();
            if(TeamId == selectedTeam.Id){
                list<SVMXC__Service_Group__c> lstServiceGroup = [Select Id,SVMXC__Group_Type__c, SVMXC__Group_Code__c, SVMXC__Description__c, SVMXC__Active__c, SVMXC__Zip__c, SVMXC__Street__c, SVMXC__State__c, SVMXC__Phone__c, SVMXC__Email__c, SVMXC__Country__c, SVMXC__City__c,RecordTypeId, Name From SVMXC__Service_Group__c where Id=:selectedTeam.Id]; 
                if(lstServiceGroup.size()>0){
                    displayTeamPopup = true;
                    displayTechPopup = false;
                    techEditMode = false;   
                    teamEditMode=true;
                    objTeam = lstServiceGroup[0];
                    objTeam.SVMXC__Latitude__c = latitude; 
                    objTeam.SVMXC__Longitude__c = longitude; 
                    RecTypeName=objTeam.RecordTypeId;
                }
                else isTTExist =false;
            }
            else if(TeamId == selectedTeamMember.Id){
                list<SVMXC__Service_Group_Members__c> lstServiceGroupMember = [Select SVMXC__Average_Drive_Time__c,SVMXC__Average_Speed__c,SVMXC__Per_Mile_Cost__c,SVMXC__Max_Distance__c,SVMXC__Per_Hour_Cost__c,SVMXC__Max_Daily_Hours__c,SVMXC__Fixed_Cost__c,SVMXC__Max_Hours__c,SVMXC__Service_Group__c, Break_Type__c,Break_Duration__c, SVMXC__Role__c, SVMXC__Member_information__c, SVMXC__Active__c, SVMXC__Zip__c, SVMXC__Working_Hours__c,SVMXC__Overtime_Hours__c, SVMXC__Street__c, SVMXC__State__c, SVMXC__Service_Territory__c, SVMXC__Salesforce_User__c, SVMXC__Phone__c, SVMXC__Enable_Scheduling__c, SVMXC__Inventory_Location__c,  SVMXC__Email__c, SVMXC__Country__c, SVMXC__City__c, SVMXC__Break_Hours__c, Name, Id From SVMXC__Service_Group_Members__c  where Id=:selectedTeamMember.Id]; 
                if(lstServiceGroupMember.size()>0){
                    teamEditMode=false;           
                    techEditMode = true;
                    displayTeamPopup = false;
                    displayTechPopup = true;
                    objTech = lstServiceGroupMember[0];
                    objTech.SVMXC__Latitude__c = latitude;
                    objTech.SVMXC__Longitude__c = longitude; 
                    if(objTech.Salesforce_User__c!=null)
                        EnableScheduling = true; //Fix for defect# 018746, changed from false to true                
                }
                else isTTExist =false;
            }
        }
        else isTTExist =false;
        
        if(!isTTExist){
            activateBlockMsg('TOP');
            displayTechPopup=false;
            displayTeamPopup=false;
            DisableButtons = false;
            techEditMode = false;   
            teamEditMode = false;
            ApexPages.addMessage(new ApexPages.Message ( ApexPages.Severity.ERROR,getTAG137()));
        }
        else showBreakDuration();
    }   
    
    public pageReference SVMX_DelTeamTechwithChild(){
        activateBlockMsg('TOP');
        try{
            if(TeamId!=null && TeamId!='' && (TeamId == selectedTeam.Id || TeamId == selectedTeamMember.Id)){
                if(TeamId == selectedTeam.Id){
                    if( COMM_SecurityUtils.getInstance().isDeletableObject( 'SVMXC__Dispatcher_Access__c' ) ) {     //SDL-SVMX-DELETE-FLS-ENFORCED                       
                        delete [select Id from SVMXC__Dispatcher_Access__c where SVMXC__Service_Team__c=:selectedTeam.Id];
                    } else {
                        ApexPages.addMessage(new ApexPages.Message ( ApexPages.Severity.ERROR,System.Label.COMM001_TAG142 ));
                        return null;
                    }
                    
                    if( COMM_SecurityUtils.getInstance().isDeletableObject( 'SVMXC__Service_Group__c' ) ) {  //SDL-SVMX-DELETE-FLS-ENFORCED                      
                        delete selectedTeam;
                    } else {
                        ApexPages.addMessage(new ApexPages.Message ( ApexPages.Severity.ERROR,System.Label.COMM001_TAG142 ));
                        return null;
                    }
                    
                    ApexPages.addMessage(new ApexPages.Message ( ApexPages.Severity.CONFIRM,system.label.COMM001_TAG052));
                }
                else if(TeamId == selectedTeamMember.Id){
                    
                    if( COMM_SecurityUtils.getInstance().isDeletableObject( 'SVMXC__Service_Group_Skills__c' ) ) {      //SDL-SVMX-DELETE-FLS-ENFORCED                 
                        delete [select Id from SVMXC__Service_Group_Skills__c where SVMXC__Group_Member__c=:selectedTeamMember.Id]; 
                    } else {
                        ApexPages.addMessage(new ApexPages.Message ( ApexPages.Severity.ERROR,System.Label.COMM001_TAG142 ));
                        return null;
                    }
                    
                    if( COMM_SecurityUtils.getInstance().isDeletableObject( 'SVMXC__Service_Group_Product__c' ) ) {     //SDL-SVMX-DELETE-FLS-ENFORCED               
                        delete [select Id from SVMXC__Service_Group_Product__c where SVMXC__Group_Member__c=:selectedTeamMember.Id];
                    } else {
                        ApexPages.addMessage(new ApexPages.Message ( ApexPages.Severity.ERROR,System.Label.COMM001_TAG142 ));
                        return null;
                    }
                    
                    if( COMM_SecurityUtils.getInstance().isDeletableObject( 'SVMXC__Service_Group_Costs__c' ) ) {       //SDL-SVMX-DELETE-FLS-ENFORCED                     
                        delete [select Id from SVMXC__Service_Group_Costs__c where SVMXC__Group_Member__c=:selectedTeamMember.Id];
                    } else {
                        ApexPages.addMessage(new ApexPages.Message ( ApexPages.Severity.ERROR,System.Label.COMM001_TAG142 ));
                        return null;
                    }
                    
                    if( COMM_SecurityUtils.getInstance().isDeletableObject( 'SVMXC__Service_Group_Members__c' ) ) {     //SDL-SVMX-DELETE-FLS-ENFORCED                    
                        delete selectedTeamMember;
                    } else {
                        ApexPages.addMessage(new ApexPages.Message ( ApexPages.Severity.ERROR,System.Label.COMM001_TAG142 ));
                        return null;
                    }
                    ApexPages.addMessage(new ApexPages.Message ( ApexPages.Severity.CONFIRM,system.label.COMM001_TAG052));
                } 
            }
            else ApexPages.addMessage(new ApexPages.Message ( ApexPages.Severity.ERROR,getTAG091())); 
            onLoad();
        }
        catch(Exception e){
            ApexPages.addMessage(new ApexPages.Message ( ApexPages.Severity.ERROR,e.getMessage()));
        }
        return null;
    }    
    
    public pageReference TechPopUpCancel(){  
        DisableButtons = false;
        displayTechPopup=false;
        return null;
    }
    
    public pageReference TeamPopUpCancel(){  
        displayTeamPopup=false;
        DisableButtons = false;
        return null;
    }
    
    
    /*************** Child Tab Attributes (New,Save Functioanlity Methods( Expertise, Product, Labor Cost)) Block Starts***************/
    
    public void SVMX_AddExprt(){                 
        if(TeamId!=null && TeamId!='' && (TeamId == selectedTeam.Id || TeamId == selectedTeamMember.Id)){  
            uncheckCheckbox();
            activateBlockMsg('BOT');
            SVMXC__Service_Group_Skills__c objGroupExpertise = new SVMXC__Service_Group_Skills__c(); 
            if(TeamId == selectedTeam.Id){
                objGroupExpertise.SVMXC__Service_Group__c = selectedTeam.Id;
                lstGroupExpertise.add(objGroupExpertise);
            }
            else if(TeamId == selectedTeamMember.Id){
                objGroupExpertise.SVMXC__Group_Member__c = selectedTeamMember.Id;
                objGroupExpertise.SVMXC__Service_Group__c = selectedTeamMember.SVMXC__Service_Group__c;
                lstGroupExpertise.add(objGroupExpertise);
            }
            for(integer i=0;i<lstGroupExpertise.size();i++)
                lstGroupExpertise[i].SVMXC__Select__c= false; 
        }
        else{ 
            UnloadTeam();
            activateBlockMsg('TOP');
            ApexPages.addMessage(new ApexPages.Message ( ApexPages.Severity.ERROR,getTAG092()));        
        }   
    }
    
    public void SVMX_AddPrdct(){             
        if(TeamId!=null && TeamId!='' && (TeamId == selectedTeam.Id || TeamId == selectedTeamMember.Id)){
            uncheckCheckbox();
            activateBlockMsg('BOT');
            SVMXC__Service_Group_Product__c objGroupProduct = new SVMXC__Service_Group_Product__c();  
            if(TeamId == selectedTeam.Id){
                objGroupProduct.SVMXC__Service_Group__c = selectedTeam.Id;
                lstGroupProduct.add(objGroupProduct);
            }
            else if(TeamId == selectedTeamMember.Id){
                objGroupProduct.SVMXC__Group_Member__c = selectedTeamMember.Id;
                objGroupProduct.SVMXC__Service_Group__c = selectedTeamMember.SVMXC__Service_Group__c;
                lstGroupProduct.add(objGroupProduct);
            }
            for(integer i=0;i<lstGroupProduct.size();i++)
                lstGroupProduct[i].SVMXC__Select__c= false;      
        }
        else{ 
            UnloadTeam();
            activateBlockMsg('TOP');
            ApexPages.addMessage(new ApexPages.Message ( ApexPages.Severity.ERROR,getTAG092()));        
        }
    }   
    
    public void SVMX_AddnewCostRec(){
        if(TeamId!=null && TeamId!='' && (TeamId == selectedTeam.Id || TeamId == selectedTeamMember.Id)){
            uncheckCheckbox();
            activateBlockMsg('BOT');
            SVMXC__Service_Group_Costs__c objLaborCost = new SVMXC__Service_Group_Costs__c();
            if(TeamId == selectedTeam.Id){
                objLaborCost.SVMXC__Service_Group__c = selectedTeam.Id;
                lstLaborCost.add(objLaborCost);
            }
            else if(TeamId == selectedTeamMember.Id){
                objLaborCost.SVMXC__Group_Member__c = selectedTeamMember.Id;
                objLaborCost.SVMXC__Service_Group__c = selectedTeamMember.SVMXC__Service_Group__c;
                lstLaborCost.add(objLaborCost);
            }
            for(integer i=0;i<lstLaborCost.size();i++)
                lstLaborCost[i].SVMXC__Select__c= false;
        }
        else{ 
            UnloadTeam();
            activateBlockMsg('TOP');
            ApexPages.addMessage(new ApexPages.Message ( ApexPages.Severity.ERROR,getTAG092()));    
        }
    }  
    
    public void SVMX_AddHomeBase(){
        if(TeamId!=null && TeamId!='' && TeamId == selectedTeamMember.Id){
            uncheckCheckbox();
            activateBlockMsg('BOT');       
            RecordType recordTypeHomeBase = [select Id from RecordType where Name=:'Home Bases' and SobjectType = 'SVMXC__Service_Group_Site__c'];  //SDL-SVMX-FLS-NOT-ENFORCED-META-DATA
            objHomeBase = new SVMXC__Service_Group_Site__c (); 
            objHomeBase.RecordTypeId = recordTypeHomeBase.Id;
            objHomeBase.SVMXC__Technician_Equipment__c = selectedTeamMember.Id;
            objHomeBase.SVMXC__Service_Group__c = selectedTeamMember.SVMXC__Service_Group__c;
            lstHomeBase.add(objHomeBase);
            for(integer i=0;i<lstHomeBase.size();i++)
                lstHomeBase[i].SVMXC__Select__c= false;
        } 
        else{ 
            UnloadTeam();
            activateBlockMsg('TOP');
            ApexPages.addMessage(new ApexPages.Message ( ApexPages.Severity.ERROR,getTAG092()));        
        }
    }
    
    public void SVMX_AddDisptacher(){                            
        if(TeamId!=null && TeamId!='' &&  TeamId == selectedTeam.Id){ 
            uncheckCheckbox();
            activateBlockMsg('TOP');  
            SVMXC__Dispatcher_Access__c objDispatcher = new SVMXC__Dispatcher_Access__c(); 
            objDispatcher.SVMXC__Service_Team__c = selectedTeam.Id;
            lstGroupDispatcher.add(objDispatcher); 
            for(integer i=0;i<lstGroupDispatcher.size();i++)
                lstGroupDispatcher[i].SVMXC__Select__c= false;
        } 
        else{ 
            UnloadTeam();
            activateBlockMsg('TOP');
            ApexPages.addMessage(new ApexPages.Message ( ApexPages.Severity.ERROR,getTAG092()));      
        }
    }
    
    public void SVMX_AddSkilltoExpertise(){
        if(TeamId!=null && TeamId!='' && (TeamId == selectedTeam.Id || TeamId == selectedTeamMember.Id)){
            uncheckCheckbox();
            boolean isSkillExist = false;
            boolean isSkillSelected = false;
            activateBlockMsg('BOT');
            for(integer i=0;i<lstExpertiseSkill.size();i++){
                if(lstExpertiseSkill[i].SVMXC__Select__c){
                    isSkillSelected =true;
                    for(integer j=0;j<lstGroupExpertise.size();j++){                    
                        if(lstExpertiseSkill[i].Id==lstGroupExpertise[j].SVMXC__Skill__c)
                            isSkillExist = true;
                    }
                    if(!isSkillExist){                                
                        SVMXC__Service_Group_Skills__c objGroupExpertise = new SVMXC__Service_Group_Skills__c();
                        objGroupExpertise.SVMXC__Skill__c = lstExpertiseSkill[i].Id;
                        if(TeamId == selectedTeam.Id){
                            objGroupExpertise.SVMXC__Service_Group__c = selectedTeam.Id;
                            lstGroupExpertise.add(objGroupExpertise);
                        }
                        else if(TeamId == selectedTeamMember.Id){
                            objGroupExpertise.SVMXC__Group_Member__c = selectedTeamMember.Id;
                            objGroupExpertise.SVMXC__Service_Group__c = selectedTeamMember.SVMXC__Service_Group__c;
                            lstGroupExpertise.add(objGroupExpertise);
                        }
                    }
                    lstExpertiseSkill[i].SVMXC__Select__c=false;
                    isSkillExist = false;
                }                                              
            }        
            if(!isSkillSelected || lstExpertiseSkill.size()==0)
                apexPages.addMessage(new ApexPages.Message ( ApexPages.Severity.ERROR,getTAG092()));  
        }
        else{
            UnloadTeam();
            activateBlockMsg('TOP');
            ApexPages.addMessage(new ApexPages.Message ( ApexPages.Severity.ERROR,getTAG092()));        
        }
    }
    
    public void SVMX_AddPrdcttoSrvcPrdct(){
        if(TeamId!=null && TeamId!='' && (TeamId == selectedTeam.Id || TeamId == selectedTeamMember.Id)){
            uncheckCheckbox();
            boolean isProdExist = false;  
            boolean isProdSelected = false;
            activateBlockMsg('BOT');       
            for(integer i=0;i<lstExpertiseProduct.size();i++){
                if(lstExpertiseProduct[i].SVMXC__Select__c){ 
                    isProdSelected =true;
                    for(integer j=0;j<lstGroupProduct.size();j++){                    
                        if(lstExpertiseProduct[i].Id == lstGroupProduct[j].SVMXC__Product__c)
                            isProdExist = true;
                    }
                    if(!isProdExist){                                
                        lstExpertiseProduct[i].SVMXC__Select__c=false;
                        SVMXC__Service_Group_Product__c objGroupProduct = new SVMXC__Service_Group_Product__c();
                        objGroupProduct.SVMXC__Product__c = lstExpertiseProduct[i].Id; 
                        if(TeamId == selectedTeam.Id){
                            objGroupProduct.SVMXC__Service_Group__c = selectedTeam.Id;
                            lstGroupProduct.add(objGroupProduct);
                        }
                        else if(TeamId == selectedTeamMember.Id){
                            objGroupProduct.SVMXC__Group_Member__c = selectedTeamMember.Id;
                            objGroupProduct.SVMXC__Service_Group__c = selectedTeamMember.SVMXC__Service_Group__c;
                            lstGroupProduct.add(objGroupProduct);
                        }
                    }
                    lstExpertiseProduct[i].SVMXC__Select__c=false;
                    isProdExist = false;
                }                                              
            } 
            if(!isProdSelected || lstExpertiseProduct.size()==0)
                apexPages.addMessage(new ApexPages.Message ( ApexPages.Severity.ERROR,getTAG092()));  
        }       
        else{
            UnloadTeam();
            activateBlockMsg('TOP');
            ApexPages.addMessage(new ApexPages.Message ( ApexPages.Severity.ERROR,getTAG092()));        
        }
    }
    
    public void SVMX_AddUsertoDispatch(){
        if(TeamId!=null && TeamId!='' && (TeamId == selectedTeam.Id)){ 
            uncheckCheckbox();
            boolean isUserExist = false;
            boolean isUserSelected = false;
            activateBlockMsg('BOT'); 
            for(integer i=0;i<lstUser.size();i++){
                if(lstUser[i].SVMXC__Select__c){ 
                    isUserSelected =true;
                    for(integer j=0;j<lstGroupDispatcher.size();j++){                    
                        if(lstUser[i].Id == lstGroupDispatcher[j].SVMXC__Dispatcher__c)
                            isUserExist = true;
                    }
                    if(!isUserExist){                                
                        SVMXC__Dispatcher_Access__c objDispatcherAccess = new SVMXC__Dispatcher_Access__c();       
                        objDispatcherAccess.SVMXC__Dispatcher__c = lstUser[i].Id;  
                        objDispatcherAccess.SVMXC__Service_Team__c=TeamId;
                        lstGroupDispatcher.add(objDispatcherAccess);
                    }
                    lstUser[i].SVMXC__Select__c=false;
                    isUserExist = false;
                }                                              
            } 
            if(!isUserSelected || lstUser.size()==0)
                apexPages.addMessage(new ApexPages.Message ( ApexPages.Severity.ERROR,getTAG092()));  
        }       
        else{
            UnloadTeam();
            activateBlockMsg('TOP');
            ApexPages.addMessage(new ApexPages.Message ( ApexPages.Severity.ERROR,getTAG092()));   
        }  
    }
    
    public pageReference SVMX_SaveExptToTeam(){
        if(TeamId!=null && TeamId!='' && (TeamId == selectedTeam.Id || TeamId == selectedTeamMember.Id)){
            uncheckCheckbox();
            activateBlockMsg('BOT');
            boolean DoSave = true;
            Set<String> lstExpertiseSkill =new Set<String>();
            try{
                for(SVMXC__Service_Group_Skills__c objGroupExpertise : lstGroupExpertise){
                    if(objGroupExpertise.SVMXC__Skill__c ==null){
                        DoSave = false;
                        ApexPages.addMessage(new ApexPages.Message ( ApexPages.Severity.ERROR,getTAG094()));
                        break;
                    }
                    else{
                        if(!lstExpertiseSkill.contains(objGroupExpertise.SVMXC__Skill__c)){
                            objGroupExpertise.Select__c = false;
                            lstExpertiseSkill.add(objGroupExpertise.SVMXC__Skill__c);
                        }
                        else{
                            DoSave = false;
                            ApexPages.addMessage(new ApexPages.Message ( ApexPages.Severity.ERROR,getTAG144()));
                            break;
                        }                                                                   
                    }
                }          
                if(lstGroupExpertise.size()==0) 
                    ApexPages.addMessage(new ApexPages.Message ( ApexPages.Severity.ERROR,getTAG093()));
                else if(DoSave){
                    if(COMM_SecurityUtils.getInstance().verifyFieldAccess(lstGroupExpertise, COMM_SecurityUtils.Access.Upsertable)){    //SDL-SVMX-CREATE-UPDATE-FLS-ENFORCED
                        upsert lstGroupExpertise;
                    } else {
                        throw new COMM_SecurityUtils.SecurityAccessException(System.label.COMM001_TAG142);
                    }
                    //upsert lstGroupExpertise;
                    ApexPages.addMessage(new ApexPages.Message ( ApexPages.Severity.CONFIRM,system.label.COMM001_TAG058,''));
                }
            }
            catch (Exception ex){
                ApexPages.addMessage(new ApexPages.Message ( ApexPages.Severity.ERROR, ex.getMessage())); 
            }
        }       
        else{
            UnloadTeam();
            activateBlockMsg('TOP');
            ApexPages.addMessage(new ApexPages.Message ( ApexPages.Severity.ERROR,getTAG092()));   
        }  
        return null;
    }
    
    public pageReference SVMX_SaveProdToTeam(){  
        if(TeamId!=null && TeamId!='' && (TeamId == selectedTeam.Id || TeamId == selectedTeamMember.Id)){
            uncheckCheckbox();
            activateBlockMsg('BOT'); 
            boolean DoSave = true;
            Set<String> lstExpertiseProduct =new Set<String>();
            try{
                for(SVMXC__Service_Group_Product__c objGroupProduct : lstGroupProduct){
                    if(objGroupProduct.SVMXC__Product__c ==null){
                        DoSave = false;
                        ApexPages.addMessage(new ApexPages.Message ( ApexPages.Severity.ERROR,getTAG096()));
                        break;
                    }
                    else{
                        if(!lstExpertiseProduct.contains(objGroupProduct.SVMXC__Product__c)){
                            objGroupProduct.Select__c = false;
                            lstExpertiseProduct.add(objGroupProduct.SVMXC__Product__c);
                        }
                        else{
                            DoSave = false;
                            ApexPages.addMessage(new ApexPages.Message ( ApexPages.Severity.ERROR,getTAG144()));
                            break;
                        }                                                                   
                    }
                }   
                if(lstGroupProduct.size()==0) 
                    ApexPages.addMessage(new ApexPages.Message ( ApexPages.Severity.ERROR,getTAG095()));
                else if(DoSave){
                    if(COMM_SecurityUtils.getInstance().verifyFieldAccess(lstGroupProduct, COMM_SecurityUtils.Access.Upsertable)){  //SDL-SVMX-CREATE-UPDATE-FLS-ENFORCED
                        upsert lstGroupProduct;
                    } else {
                        throw new COMM_SecurityUtils.SecurityAccessException(System.label.COMM001_TAG142);
                    }
                    //upsert lstGroupProduct;
                    ApexPages.addMessage(new ApexPages.Message ( ApexPages.Severity.CONFIRM,system.label.COMM001_TAG058,''));
                }
            }
            catch (Exception ex){
                ApexPages.addMessage(new ApexPages.Message ( ApexPages.Severity.ERROR, ex.getMessage())); 
            }
        }
        else{
            UnloadTeam();
            activateBlockMsg('TOP');
            ApexPages.addMessage(new ApexPages.Message ( ApexPages.Severity.ERROR,getTAG092()));   
        }  
        return null;
    }
    
    public void SVMX_SaveCostToTeam(){ 
        if(TeamId!=null && TeamId!='' && (TeamId == selectedTeam.Id || TeamId == selectedTeamMember.Id)){
            uncheckCheckbox();
            activateBlockMsg('BOT');
            boolean DoSave = true;
            try{
                for(SVMXC__Service_Group_Costs__c objLaborCost : lstLaborCost){
                    if(objLaborCost.SVMXC__Hourly_Cost2__c==null && objLaborCost.SVMXC__Billable_Cost2__c==null){
                        DoSave = false;
                        ApexPages.addMessage(new ApexPages.Message ( ApexPages.Severity.ERROR,getTAG098()));
                        break;
                    }
                }   
                if(lstLaborCost.size()==0) 
                    ApexPages.addMessage(new ApexPages.Message ( ApexPages.Severity.ERROR,getTAG097()));
                else if(DoSave){
                    if(COMM_SecurityUtils.getInstance().verifyFieldAccess(lstLaborCost, COMM_SecurityUtils.Access.Upsertable)){ //SDL-SVMX-CREATE-UPDATE-FLS-ENFORCED
                        upsert lstLaborCost;
                    } else {
                        throw new COMM_SecurityUtils.SecurityAccessException(System.label.COMM001_TAG142);
                    }
                    //upsert lstLaborCost;
                    ApexPages.addMessage(new ApexPages.Message ( ApexPages.Severity.CONFIRM,system.label.COMM001_TAG058,''));
                }
            }
            catch (Exception ex){
                ApexPages.addMessage(new ApexPages.Message ( ApexPages.Severity.ERROR, ex.getMessage())); 
            } 
        }
        else{
            UnloadTeam();
            activateBlockMsg('TOP');
            ApexPages.addMessage(new ApexPages.Message ( ApexPages.Severity.ERROR,getTAG092()));   
        }
    }
    
    public pageReference SVMX_SaveHomeBase(){ 
        if(TeamId!=null && TeamId!='' && TeamId == selectedTeamMember.Id){
            uncheckCheckbox();
            activateBlockMsg('BOT'); 
            Map<integer,double> latMap = new Map<integer,double>();
            Map<integer,double> lonMap = new Map<integer,double>();
            list<string> TempLatLst = new list<string>();
            list<string> TempLonLst = new list<string>();
            list<string> lstlat = new list<string>();
            list<string> lstlon = new list<string>();
            integer Current=0;
            boolean IsError = true;
            boolean IsNull = false;
            String url;         
            AddrsError = false; 
            try{
                if(lstHomeBase.size()>0){
                    if(lstlatitude.length()>0 && lstlongitude.length()>0){
                        system.debug('lstlatitude'+lstlatitude);
                        system.debug('lstlongitude'+lstlongitude);
                        lstlat = lstlatitude.split(',');
                        lstlon = lstlongitude.split(',');               
                        for(integer l=0;l<lstlat.size();l++){
                            TempLatLst = new list<string>();
                            TempLatLst = lstlat[l].split('~');
                            latMap.put(integer.valueOf(TempLatLst[0]),Double.valueOf(TempLatLst[1]));
                        }
                        for(integer l=0;l<lstlon.size();l++){
                            TempLonLst = new list<string>();
                            TempLonLst = lstlon[l].split('~');
                            lonMap.put(integer.valueOf(TempLonLst[0]),Double.valueOf(TempLonLst[1]));
                        }
                    }
                    for(integer i=0;i<lstHomeBase.size();i++){
                        if(lstHomeBase[i].Street__c==null && lstHomeBase[i].City__c==null && lstHomeBase[i].State__c==null && lstHomeBase[i].Zip__c== null && (lstHomeBase[i].Country__c==null || lstHomeBase[i].Country__c=='--None--')){
                            AddrsError = true;
                            ApexPages.addMessage(new ApexPages.Message ( ApexPages.Severity.ERROR, getTAG139()));
                            IsNull=true;
                        }
                        else{
                            if(lstHomeBase[i].SVMXC__IsCurrent__c ){
                                current=current+1;                      
                            }               
                        }                           
                    }
                    if(!IsNull){
                        if(current>1){
                            AddrsError = true;                  
                            ApexPages.addMessage(new ApexPages.Message ( ApexPages.Severity.ERROR, getTAG127()));                                   
                        }
                    }
                    if(!AddrsError){                
                        for(integer j=0;j<lstHomeBase.size();j++){                 
                            if(latMap.containsKey(j) && lonMap.containsKey(j)){
                                system.debug('latMap'+latMap.get(j));
                                system.debug('latMap'+lonMap.get(j));
                                lstHomeBase[j].SVMXC__Latitude__c = latMap.get(j);
                                lstHomeBase[j].SVMXC__Longitude__c = lonMap.get(j);
                            }
                        }                               
                        //upsert lstHomeBase;  
                        if( COMM_SecurityUtils.getInstance().verifyFieldAccess( lstHomeBase, COMM_SecurityUtils.Access.Upsertable ) ) {     //SDL-SVMX-CREATE-UPDATE-FLS-ENFORCED
                            upsert lstHomeBase;
                        } else {
                            ApexPages.addMessage(new ApexPages.Message ( ApexPages.Severity.ERROR, System.Label.COMM001_TAG142 ) );
                            return null;
                        }
                        ApexPages.addMessage(new ApexPages.Message ( ApexPages.Severity.CONFIRM,system.label.COMM001_TAG058,''));
                    } 
                }     
            }
            catch (Exception ex){
                ApexPages.addMessage(new ApexPages.Message ( ApexPages.Severity.ERROR, ex.getMessage())); 
            }
        }
        else{
            UnloadTeam();
            activateBlockMsg('TOP');
            ApexPages.addMessage(new ApexPages.Message ( ApexPages.Severity.ERROR,getTAG092()));   
        }
        return null;         
    }
    
    public pageReference SVMX_SaveDispToTeam(){
        if(TeamId!=null && TeamId!='' && TeamId == selectedTeam.Id){
            uncheckCheckbox();
            activateBlockMsg('BOT'); 
            boolean DoSave = true;
            Set<String> lstTeamDispatcher =new Set<String>();
            try{
                for(SVMXC__Dispatcher_Access__c objGroupDispatcher  : lstGroupDispatcher){
                    if(objGroupDispatcher.SVMXC__Dispatcher__c ==null){
                        DoSave = false;
                        ApexPages.addMessage(new ApexPages.Message ( ApexPages.Severity.ERROR,getTAG096()));
                        break;
                    }
                    else{
                        if(!lstTeamDispatcher.contains(objGroupDispatcher.SVMXC__Dispatcher__c)){
                            objGroupDispatcher.Select__c = false;
                            lstTeamDispatcher.add(objGroupDispatcher.SVMXC__Dispatcher__c);
                        }
                        else{
                            DoSave = false;
                            ApexPages.addMessage(new ApexPages.Message ( ApexPages.Severity.ERROR,getTAG144()));
                            break;
                        }                                                                   
                    }
                }     
                if(lstGroupDispatcher.size()==0) 
                    ApexPages.addMessage(new ApexPages.Message ( ApexPages.Severity.ERROR,getTAG095()));
                else if(DoSave){
                    if(COMM_SecurityUtils.getInstance().verifyFieldAccess(lstGroupDispatcher, COMM_SecurityUtils.Access.Upsertable)){   //SDL-SVMX-CREATE-UPDATE-FLS-ENFORCED
                        upsert lstGroupDispatcher;
                    } else {
                        throw new COMM_SecurityUtils.SecurityAccessException(System.label.COMM001_TAG142);
                    }
                    //upsert lstGroupDispatcher;
                    ApexPages.addMessage(new ApexPages.Message ( ApexPages.Severity.CONFIRM,system.label.COMM001_TAG058,''));
                }
            }
            catch (Exception ex){
                ApexPages.addMessage(new ApexPages.Message ( ApexPages.Severity.ERROR, ex.getMessage())); 
            }
        }
        else{
            UnloadTeam();
            activateBlockMsg('TOP');
            ApexPages.addMessage(new ApexPages.Message ( ApexPages.Severity.ERROR,getTAG092()));   
        }
        return null;
    }
    
    public pageReference SVMX_DelExprt(){
        if(TeamId!=null && TeamId!='' && (TeamId == selectedTeam.Id || TeamId == selectedTeamMember.Id)){
            uncheckCheckbox();
            activateBlockMsg('BOT'); 
            boolean DelExprtCountRec=false;
            List<SVMXC__Service_Group_Skills__c> ExprtIDs = new List<SVMXC__Service_Group_Skills__c>();
            List<SVMXC__Service_Group_Skills__c> TempExprtIDs = new List<SVMXC__Service_Group_Skills__c>();
            try{
                for(integer i=0;i<lstGroupExpertise.size();i++){
                    if(lstGroupExpertise[i].SVMXC__Select__c){
                        DelExprtCountRec=true;
                        if(lstGroupExpertise[i].Id != NULL)
                            ExprtIDs.add(lstGroupExpertise[i]);      
                    }
                    else TempExprtIDs.add(lstGroupExpertise[i]); 
                }
                if(DelExprtCountRec){
                    if( COMM_SecurityUtils.getInstance().isDeletableObject( 'SVMXC__Service_Group_Skills__c' ) ) {    //SDL-SVMX-DELETE-FLS-ENFORCED                    
                        delete ExprtIDs;
                    } else {
                        ApexPages.addMessage(new ApexPages.Message ( ApexPages.Severity.ERROR,System.Label.COMM001_TAG142 ));
                        return null;
                    }
                    
                    lstGroupExpertise.clear();
                    lstGroupExpertise = TempExprtIDs;
                    ApexPages.addMessage(new ApexPages.Message ( ApexPages.Severity.CONFIRM,system.label.COMM001_TAG052));
                }   
                else ApexPages.addMessage(new ApexPages.Message ( ApexPages.Severity.ERROR,getTAG099()));
            }
            catch (Exception ex){
                ApexPages.addMessage(new ApexPages.Message ( ApexPages.Severity.ERROR, ex.getMessage())); 
            }
        }
        else{
            UnloadTeam();
            activateBlockMsg('TOP');
            ApexPages.addMessage(new ApexPages.Message ( ApexPages.Severity.ERROR,getTAG092()));   
        }
        return null;
    }
    
    public pageReference SVMX_DelPrdct(){  
        if(TeamId!=null && TeamId!='' && (TeamId == selectedTeam.Id || TeamId == selectedTeamMember.Id)){
            uncheckCheckbox();
            activateBlockMsg('BOT'); 
            boolean DelPrdctCountRec=false;
            List<SVMXC__Service_Group_Product__c> PrdctIDs = new List<SVMXC__Service_Group_Product__c>();
            List<SVMXC__Service_Group_Product__c> TempPrdctIDs = new List<SVMXC__Service_Group_Product__c>();
            try{
                for(integer i=0;i<lstGroupProduct.size();i++){
                    if(lstGroupProduct[i].SVMXC__Select__c){
                        DelPrdctCountRec=true;
                        if(lstGroupProduct[i].Id!=NULL)
                            PrdctIDs.add(lstGroupProduct[i]);        
                    }
                    else
                        TempPrdctIDs.add(lstGroupProduct[i]);  
                }
                if(DelPrdctCountRec){
                    if( COMM_SecurityUtils.getInstance().isDeletableObject( 'SVMXC__Service_Group_Product__c' ) ) {  //SDL-SVMX-DELETE-FLS-ENFORCED                      
                        delete PrdctIDs;
                    } else {
                        ApexPages.addMessage(new ApexPages.Message ( ApexPages.Severity.ERROR,System.Label.COMM001_TAG142 ));
                        return null;
                    }
                    
                    lstGroupProduct.clear();
                    lstGroupProduct =  TempPrdctIDs;
                    ApexPages.addMessage(new ApexPages.Message ( ApexPages.Severity.CONFIRM,system.label.COMM001_TAG052));
                }   
                else ApexPages.addMessage(new ApexPages.Message ( ApexPages.Severity.ERROR,getTAG099()));
            }
            catch (Exception ex){
                ApexPages.addMessage(new ApexPages.Message ( ApexPages.Severity.ERROR, ex.getMessage())); 
            }  
        }
        else{
            UnloadTeam();
            activateBlockMsg('TOP');
            ApexPages.addMessage(new ApexPages.Message ( ApexPages.Severity.ERROR,getTAG092()));   
        }
        return null;
    }
    
    public pageReference SVMX_DelCostRec(){
        if(TeamId!=null && TeamId!='' && (TeamId == selectedTeam.Id || TeamId == selectedTeamMember.Id)){
            uncheckCheckbox();
            activateBlockMsg('BOT'); 
            boolean DelCostCountRec=false;
            List<SVMXC__Service_Group_Costs__c> CostIDs = new List<SVMXC__Service_Group_Costs__c>();
            List<SVMXC__Service_Group_Costs__c> TempCosttIDs = new List<SVMXC__Service_Group_Costs__c>();
            try{
                for(integer i=0;i<lstLaborCost.size();i++){
                    if(lstLaborCost[i].SVMXC__Select__c){
                        DelCostCountRec=true;
                        if(lstLaborCost[i].Id!=NULL)
                            CostIDs.add(lstLaborCost[i]);        
                    }
                    else
                        TempCosttIDs.add(lstLaborCost[i]); 
                }
                if(DelCostCountRec){
                    if( COMM_SecurityUtils.getInstance().isDeletableObject( 'SVMXC__Service_Group_Costs__c' ) ) {   //SDL-SVMX-DELETE-FLS-ENFORCED                       
                        delete CostIDs;
                    } else {
                        ApexPages.addMessage(new ApexPages.Message ( ApexPages.Severity.ERROR,System.Label.COMM001_TAG142 ));
                        return null;
                    }
                    
                    lstLaborCost.clear();
                    lstLaborCost = TempCosttIDs;
                    ApexPages.addMessage(new ApexPages.Message ( ApexPages.Severity.CONFIRM,system.label.COMM001_TAG052));
                }   
                else ApexPages.addMessage(new ApexPages.Message ( ApexPages.Severity.ERROR,getTAG099()));
            }
            catch (Exception ex){
                ApexPages.addMessage(new ApexPages.Message ( ApexPages.Severity.ERROR, ex.getMessage())); 
            }
        }
        else{
            UnloadTeam();
            activateBlockMsg('TOP');
            ApexPages.addMessage(new ApexPages.Message ( ApexPages.Severity.ERROR,getTAG092()));   
        }
        return null;
    }
    
    public pageReference SVMX_DelHomeBaseRec(){
        if(TeamId!=null && TeamId!='' && TeamId == selectedTeamMember.Id){
            uncheckCheckbox();
            activateBlockMsg('BOT'); 
            boolean DelHomeBseCountRec = false;     
            List<SVMXC__Service_Group_Site__c> HomeBIDs = new List<SVMXC__Service_Group_Site__c>();
            List<SVMXC__Service_Group_Site__c> TempHomebIDs = new List<SVMXC__Service_Group_Site__c>();
            try{ 
                for(integer i=0;i<lstHomeBase.size();i++){
                    if(lstHomeBase[i].SVMXC__Select__c){
                        DelHomeBseCountRec=true;
                        if(lstHomeBase[i].Id!=NULL)
                            HomeBIDs.add(lstHomeBase[i]);        
                    }
                    else
                        TempHomebIDs.add(lstHomeBase[i]);  
                }
                if(DelHomeBseCountRec){
                    if( COMM_SecurityUtils.getInstance().isDeletableObject( 'SVMXC__Service_Group_Site__c' ) ) {     //SDL-SVMX-DELETE-FLS-ENFORCED                   
                        delete HomeBIDs;
                    } else {
                        ApexPages.addMessage(new ApexPages.Message ( ApexPages.Severity.ERROR,System.Label.COMM001_TAG142 ));
                        return null;
                    }
                    
                    lstHomeBase.clear();
                    DelHomeBseCountRec=false;   
                    lstHomeBase = TempHomebIDs;
                    ApexPages.addMessage(new ApexPages.Message ( ApexPages.Severity.CONFIRM,system.label.COMM001_TAG052));
                }   
                else ApexPages.addMessage(new ApexPages.Message ( ApexPages.Severity.ERROR,getTAG099()));
            }
            catch (Exception ex){
                ApexPages.addMessage(new ApexPages.Message ( ApexPages.Severity.ERROR, ex.getMessage())); 
            }
        }
        else{
            UnloadTeam();
            activateBlockMsg('TOP');
            ApexPages.addMessage(new ApexPages.Message ( ApexPages.Severity.ERROR,getTAG092()));   
        }
        return null;
    }
    
    public pageReference SVMX_DelDisptch(){ 
        if(TeamId!=null && TeamId!='' && (TeamId == selectedTeam.Id || TeamId == selectedTeamMember.Id)){
            uncheckCheckbox();
            activateBlockMsg('BOT'); 
            boolean DelDispCountRec =false;   
            List<SVMXC__Dispatcher_Access__c> DispIDs = new List<SVMXC__Dispatcher_Access__c>();
            List<SVMXC__Dispatcher_Access__c> TempDispIDs = new List<SVMXC__Dispatcher_Access__c>();            
            try{
                for(integer i=0;i<lstGroupDispatcher.size();i++){
                    if(lstGroupDispatcher[i].SVMXC__Select__c){
                        DelDispCountRec=true;
                        if(lstGroupDispatcher[i].Id!=NULL)
                            DispIDs.add(lstGroupDispatcher[i]);     
                    }
                    else
                        TempDispIDs.add(lstGroupDispatcher[i]); 
                }
                if(DelDispCountRec){
                    
                    if( COMM_SecurityUtils.getInstance().isDeletableObject( 'SVMXC__Dispatcher_Access__c' ) ) {       //SDL-SVMX-DELETE-FLS-ENFORCED                 
                        delete DispIDs;
                    } else {
                        ApexPages.addMessage(new ApexPages.Message ( ApexPages.Severity.ERROR,System.Label.COMM001_TAG142 ));
                        return null;
                    }
                    
                    lstGroupDispatcher.clear();
                    lstGroupDispatcher = TempDispIDs; 
                    ApexPages.addMessage(new ApexPages.Message ( ApexPages.Severity.CONFIRM,system.label.COMM001_TAG052));
                }   
                else ApexPages.addMessage(new ApexPages.Message ( ApexPages.Severity.ERROR,getTAG099()));
            }
            catch (Exception ex){
                ApexPages.addMessage(new ApexPages.Message ( ApexPages.Severity.ERROR, ex.getMessage())); 
            }
        }
        else{
            UnloadTeam();
            activateBlockMsg('TOP');
            ApexPages.addMessage(new ApexPages.Message ( ApexPages.Severity.ERROR,getTAG092()));   
        }
        return null;
    }
    
    
    /*************  SEARCH BLOCK STARTS ***************/    
    
    public string Keyword; 
    public string ExprtKywrd;
    public string PrdctKywrd; 
    public string DispKywrd;
    public string getKeyword(){return Keyword;} 
    public void setKeyword(string k){this.Keyword=k;}
    public string getDispKywrd(){return DispKywrd; }
    public void setDispKywrd(string k){ this.DispKywrd=k;}
    public string getExprtKywrd(){return ExprtKywrd;}   
    public void setExprtKywrd(string k){this.ExprtKywrd=k;}
    public string getPrdctKywrd(){return PrdctKywrd;}   
    public void setPrdctKywrd(string p){this.PrdctKywrd=p;}
    
    //Skill Search Functionality
    public void SVMX_ExprtSearch(){
        activateBlockMsg('BOT');                
        if(ExprtKywrd==null || ExprtKywrd=='')
            ApexPages.addMessage(new ApexPages.Message ( ApexPages.Severity.ERROR, getTAG100()));
        else{
            try{
                lstExpertiseSkill.clear();
                
                //string strQueryExpertise = 'Select Id, Name, SVMXC__Select__c From SVMXC__Skill__c where Name like \'%'+ExprtKywrd.replaceAll('\'', '\\\\\'')+'%\' order by Name limit serachLimit';
                string strQueryExpertise,strExpertise;
                if(ExprtKywrd.contains('\''))
                    strExpertise = String.escapeSingleQuotes(ExprtKywrd.replaceAll('\'', '\\\''));
                else
                    strExpertise = String.escapeSingleQuotes(ExprtKywrd);
                strQueryExpertise = 'Select Id, Name, SVMXC__Select__c From SVMXC__Skill__c where Name like \'%'+strExpertise+'%\' order by Name limit: serachLimit';
                
                system.debug(logginglevel.warn,'strQueryExpertise: '+strQueryExpertise);
                lstExpertiseSkill = Database.query(strQueryExpertise);
                
                
                if(lstExpertiseSkill.size() <= 0)
                    ApexPages.addMessage(new ApexPages.Message ( ApexPages.Severity.ERROR, getTAG102()));         
            }
            catch (Exception ex){
                ApexPages.addMessage(new ApexPages.Message ( ApexPages.Severity.ERROR, ex.getMessage())); 
            } 
        }          
    }   
    
    //Product Search Functionality
    public void SVMX_PrdctSearch(){ 
        activateBlockMsg('BOT'); 
        if(PrdctKywrd==null || PrdctKywrd=='')
            ApexPages.addMessage(new ApexPages.Message ( ApexPages.Severity.ERROR, getTAG100()));
        else{
            try{
                lstExpertiseProduct.clear();
                //lstExpertiseProduct=[Select Name, Id, SVMXC__Select__c From Product2 where Name like:'%'+String.escapeSingleQuotes(PrdctKywrd.replace('\'', '\\\''))+'%' order by Name limit: serachLimit];
                string strQueryProdExpertise,strProdExpertise;
                if(PrdctKywrd.contains('\''))
                    strProdExpertise = String.escapeSingleQuotes(PrdctKywrd.replaceAll('\'', '\\\''));
                else
                    strProdExpertise = String.escapeSingleQuotes(PrdctKywrd);
                strQueryProdExpertise = 'Select Name, Id, SVMXC__Select__c From Product2 where Name like \'%'+strProdExpertise+'%\' order by Name limit: serachLimit';
                
                system.debug(logginglevel.warn,'strQueryProdExpertise: '+strQueryProdExpertise);
                lstExpertiseProduct = Database.query(strQueryProdExpertise);
                if(lstExpertiseProduct.size()<=0)
                    ApexPages.addMessage(new ApexPages.Message ( ApexPages.Severity.ERROR, getTAG103()));         
            }
            catch (Exception ex){
                ApexPages.addMessage(new ApexPages.Message ( ApexPages.Severity.ERROR, ex.getMessage())); 
            } 
        }    
    }
    
    //Dspatcher Search Functionality
    public void SVMX_DispatchSearch(){
        activateBlockMsg('BOT');                         
        if(DispKywrd==null || DispKywrd=='')
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, getTAG100()));
        else{   
            try{
                lstUser.clear();
                //lstUser=[Select Id, Name, SVMXC__Select__c From User where Name like:'%'+String.escapeSingleQuotes(DispKywrd.replace('\'', '\\\''))+'%' order by Name limit: serachLimit];
                string strQueryDispatcher,strDispatcher;
                if(DispKywrd.contains('\''))
                    strDispatcher = String.escapeSingleQuotes(DispKywrd.replaceAll('\'', '\\\''));
                else
                    strDispatcher = String.escapeSingleQuotes(DispKywrd);
                
                strQueryDispatcher = 'Select Id, Name, SVMXC__Select__c From User where Name like \'%'+strDispatcher+'%\' order by Name limit: serachLimit';
                
                system.debug(logginglevel.warn,'strQueryDispatcher: '+strQueryDispatcher);
                lstUser = Database.query(strQueryDispatcher);
                if(lstUser.size()<=0)
                    ApexPages.addMessage(new ApexPages.Message ( ApexPages.Severity.ERROR, getTAG119()));
            }
            catch (Exception ex){
                ApexPages.addMessage(new ApexPages.Message ( ApexPages.Severity.ERROR, ex.getMessage())); 
            } 
        }          
    }   
    
    public void SkillSearchCancel(){
        lstExpertiseSkill.clear();
        ExprtKywrd='';
        
    }
    public void PrdctSearchCancel(){        
        PrdctKywrd = '';
        lstExpertiseProduct.clear();
    }
    
    public void UserSearchCancel(){
        lstUser.clear();
        DispKywrd='';
    }
    
    public void SVMX_Reset(){  
        UnloadTeam();
        TeamId ='';
        onLoad();
    }
    
    /*************  SEARCH BLOCK ENDS ***************/
    
    
    public void activateBlockMsg(String s){
        deActivateAllMsg();
        if(s=='POPUP')  
            DisplayPPLevelMessage=true;
        else if(s=='TOP')       
            DisplayTopBlockLevelMessage=true;
        else if(s=='BOT')       
            DisplayBotBlockLevelMessage=true;
    }
    
    public void deActivateAllMsg(){
        DisplayPPLevelMessage=false;
        DisplayTopBlockLevelMessage=false;
        DisplayBotBlockLevelMessage=false;
    } 
    
    public void uncheckCheckbox(){
        CheckAllExprt=false; 
        CheckAllPrdct=false;
        CheckAllCost=false; 
        CheckAllHmeBase=false;
        CheckAllDisp = false;
    }  
    
    public PageReference SVMX_GoSetupHome(){
        //Changes done by Nidhi as part of BAC-4747. Handling redirection on Lightning Experience
        //String url = '/apex/SVMXC__CONF_SetupHome';
        //if(svmxSettingList.containsKey('SET001') == true) url =svmxSettingList.get('SET001');
        String url = '';
        if(svmxSettingList.containsKey('SET001') == true){
            if(UserInfo.getUiThemeDisplayed()=='Theme4d' || UserInfo.getUiThemeDisplayed()=='Theme4u'){
                url = '/lightning/n/SVMXC__ServiceMax_Setup';
            }else{
                url =svmxSettingList.get('SET001');
            }
        }else{
            if(UserInfo.getUiThemeDisplayed()=='Theme4d' || UserInfo.getUiThemeDisplayed()=='Theme4u'){
                url = '/lightning/n/SVMXC__ServiceMax_Setup';
            }else{
                url = '/apex/SVMXC__CONF_SetupHome';
            }           
        }
        //Changes done by Nidhi ends here     
        PageReference HomePage = new PageReference(url);
        HomePage.setRedirect(true);
        return HomePage; 
    }
    
    public void DisableAutoChkbox(){
        if(!techEditMode){      
            if(objTech.SVMXC__Inventory_Location__c!=null)
                EnableAutoCheckBox = false;
            else
                EnableAutoCheckBox = true;
        }
    }
    
    public void showBreakDuration(){
        if(objTech.SVMXC__Break_Type__c=='Time Window')
            renderBreakDuration= true;
        else
            renderBreakDuration= false;
    }
    
    public  List<SelectOption> getTeamRecType(){
        List<SelectOption> options = new List<SelectOption>();  
        list<RecordType> Rtype = [select Id,Name from RecordType where Name=:'Technician' or Name=:'Equipment' order by Name desc];  //SDL-SVMX-FLS-NOT-ENFORCED-META-DATA   
        if (Rtype!=null){
            for(RecordType R:Rtype){
                if (R.Name != null){
                    options.add(new SelectOption(R.Id,R.Name));                 
                }
            }
        }
        return options; 
    }
    
    public void showEnableScheduling(){   
        if(objTech.Salesforce_User__c!=null){
            User u=[select Email,Street,City,State,PostalCode,Country,Phone from User where Id=:objTech.Salesforce_User__c];
            if(objTech.Street__c==null && objTech.City__c==null && objTech.State__c==null && objTech.Zip__c==null && objTech.Country__c==null){
                objTech.Street__c = u.Street;
                objTech.City__c = u.City;
                objTech.State__c = u.State;
                objTech.Zip__c = u.PostalCode;
                objTech.Country__c = u.Country;
            }
            if(objTech.SVMXC__Email__c==null){
                objTech.SVMXC__Email__c = u.Email; }
            if(objTech.SVMXC__Phone__c==null){
                objTech.SVMXC__Phone__c=u.Phone; }         
        }                      
        EnableScheduling = true; //Fix for defect# 018746, changed from false to true
    }
}