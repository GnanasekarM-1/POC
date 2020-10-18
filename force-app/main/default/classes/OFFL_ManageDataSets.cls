public with sharing class OFFL_ManageDataSets
{
    public String did = System.currentPageReference().getParameters().get('did');
    public String pid = System.currentPageReference().getParameters().get('pid');
       
    public boolean isEditMode = false;
        public boolean getisEditMode() {return isEditMode;}
    public boolean isValidCri = true;
        public boolean getisValidCri(){return isValidCri;}
    public boolean isHomeTab = false;
        public boolean getisHomeTab(){return isHomeTab;}
    public boolean AddChild = false;
        public boolean getAddChild(){return AddChild;}
        public void setAddChild(boolean b){this.AddChild = b;}
    
    
    public Map<String, Schema.SObjectType> allObjs = new Map<String, Schema.SObjectType>();
    public Map<String,String> mapObjApiLabel = new Map<String,String>();
    public Map<String,String> mapfldApiLabel = new Map<String,String>();
    public Map<String,String> mapfldApiName = new Map<String,String>();    
    public Map<String,String> mapfieldType = new Map<String,String>();
    public Map<String,String> mapExcludedObject = new Map<String,String> ();
    public Map<String,SVMXC__Offline_View__c> mapExstOfflViewObj = new Map<String,SVMXC__Offline_View__c> ();
    public Map<String,SVMXC__Offline_Object__c> mapExstOfflObj = new Map<String,SVMXC__Offline_Object__c> ();
    
    public List<SelectOption> lstSrcObjOpt  = new List<SelectOption>();
        public List<SelectOption> getlstSrcObjOpt () { return sortSelectOption(lstSrcObjOpt, true );}
    public List<SelectOption> lstOwnShipLimit = new List<SelectOption>();
        public List<SelectOption> getlstOwnShipLimit (){return lstOwnShipLimit;} 
    public List<SelectOption> lstFieldsOpt = new List<SelectOption>();
        public List<SelectOption> getlstFieldsOpt (){lstFieldsOpt = sortSelectOption(lstFieldsOpt, false); return  lstFieldsOpt;}
    public List<SelectOption> lstSFieldsOpt = new List<SelectOption>();
        public List<SelectOption> getlstSFieldsOpt (){return lstSFieldsOpt;}
    public List<SelectOption> lstFields = new List<SelectOption>();
        public List<SelectOption> getlstFields(){lstFields = sortSelectOption(lstFields, true);return lstFields;}
        
    public List<SVMXC__Offline_Dataset_Expression__c> lstOffl_DSExp = New List<SVMXC__Offline_Dataset_Expression__c>();
        public list<SVMXC__Offline_Dataset_Expression__c> getlstOffl_DSExp() {return lstOffl_DSExp;}
        public void setlstOffl_DSExp(list<SVMXC__Offline_Dataset_Expression__c> l) {this.lstOffl_DSExp=l;}
       
    public List<SVMXC__Offline_Dataset_Expression__c> lstOffl_DSExpDW = New List<SVMXC__Offline_Dataset_Expression__c>();
        public list<SVMXC__Offline_Dataset_Expression__c> getlstOffl_DSExpDW() {return lstOffl_DSExpDW;}
        public void setlstOffl_DSExpDW(list<SVMXC__Offline_Dataset_Expression__c> l) {this.lstOffl_DSExpDW=l;}
    public List<SVMXC__Offline_Dataset_Expression__c> lstOffl_DSExpLK = New List<SVMXC__Offline_Dataset_Expression__c>();
        public list<SVMXC__Offline_Dataset_Expression__c> getlstOffl_DSExpLK() {return lstOffl_DSExpLK;}
        public void setlstOffl_DSExpLK(list<SVMXC__Offline_Dataset_Expression__c> l) {this.lstOffl_DSExpLK=l;}
    public List<SVMXC__Offline_Dataset_Expression__c> lstOffl_DSExpAR = New List<SVMXC__Offline_Dataset_Expression__c>();
        public list<SVMXC__Offline_Dataset_Expression__c> getlstOffl_DSExpAR() {return lstOffl_DSExpAR;}
        public void setlstOffl_DSExpAR(list<SVMXC__Offline_Dataset_Expression__c> l) {this.lstOffl_DSExpAR=l;}

    public List<SVMXC__Offline_Dataset_Expression__c> lstTempOffl_DSExp  = New List<SVMXC__Offline_Dataset_Expression__c>();
        public list<SVMXC__Offline_Dataset_Expression__c> getlstTempOffl_DSExp() {return lstTempOffl_DSExp;}
        public void setlstTempOffl_DSExp(list<SVMXC__Offline_Dataset_Expression__c> l) {this.lstTempOffl_DSExp=l;}

    public List<String> lstAvlbFields = new List<String>();
        public List<String> getlstAvlbFields(){ return lstAvlbFields;}
        public void setlstAvlbFields(List<String> s) {this.lstAvlbFields=s;}
    public List<String> lstSelFields = new List<String>();
        public List<String> getlstSelFields(){ return lstSelFields;}
        public void setlstSelFields(List<String> s) {this.lstSelFields=s;}
    
    public integer intDSExpSize;
        public integer getintDSExpSize(){ return lstTempOffl_DSExp.size();}
    
    public Boolean showPageError =false;
    boolean isChild = true;
        public Boolean getshowPageError(){ return showPageError;}
        public void setshowPageError(Boolean b){ this.showPageError = b;}
    public SVMXC__Offline_Object__c oOfflObj = new SVMXC__Offline_Object__c ();
        public SVMXC__Offline_Object__c getoOfflObj(){ return oOfflObj;}
    public list<SVMXC__Offline_View__c> lstOfflView = new list<SVMXC__Offline_View__c> ();
        public list<SVMXC__Offline_View__c> getlstOfflView(){ return lstOfflView;}
    public list<SVMXC__Offline_Object__c> lstOfflObj_RefObj = new list<SVMXC__Offline_Object__c>();
        public list<SVMXC__Offline_Object__c> getlstOfflObj_RefObj(){return lstOfflObj_RefObj;}
        public void setlstOfflObj_RefObj(list<SVMXC__Offline_Object__c> l){this.lstOfflObj_RefObj=l;}
    
    public list<wraperOfflObj_RefObj> lstWrpOfflObj_RefObj = new list<wraperOfflObj_RefObj>();
        public list<wraperOfflObj_RefObj> getlstWrpOfflObj_RefObj(){return sortWrpOfflObj(lstWrpOfflObj_RefObj);}
        public void setlstWrpOfflObj_RefObj(list<wraperOfflObj_RefObj> w){this.lstWrpOfflObj_RefObj=w;}
    public list<SVMXC__Offline_Object__c> lstOfflObj_MstChdList = new list<SVMXC__Offline_Object__c>();
        public list<SVMXC__Offline_Object__c> getlstOfflObj_MstChdList(){return lstOfflObj_MstChdList ;}
    public list<SVMXC__Offline_Object__c > lstExtOfflObj = new list<SVMXC__Offline_Object__c >();
            
        
    public String strAdvanceOption;
        public String getstrAdvanceOption(){return strAdvanceOption;}
        public void setstrAdvanceOption(String strs){this.strAdvanceOption=strs;}
    public integer delind;
        public integer getdelind(){return null;}
        public void setdelind(integer strs){this.delind=strs;}
    public String strHomeObject ='';
        public String getstrHomeObject(){return strHomeObject;}
        
    public list<SVMXC__ServiceMax_Config_Data__c> lstOfflProfile = new list<SVMXC__ServiceMax_Config_Data__c>();
    
    //for OEM
    public  SVMXC.COMM_Utils util = new SVMXC.COMM_Utils();
    public boolean isEnterpriseLicense=true;
    //public boolean getisEnterpriseLicense() {return isEnterpriseLicense;}
    public Map<String,Boolean> PermittedObjectList = new Map<String,Boolean>();
    Set<String> AllowedObjects=new  Set<String>();
    
    
    public OFFL_ManageDataSets()
     {
        try
        {
             //for OEM
            isEnterpriseLicense=util.SVMX_isEnterpriseLicense();
            if (!isEnterpriseLicense)
            {
                PermittedObjectList=util.SVMX_getPermittedStandardObjectList();
                if(PermittedObjectList!=null)
                {
                    for(String strobj:PermittedObjectList.keySet())
                    {
                    AllowedObjects.add(strobj);
                    }
                }
                
            }
            //end OEM
             
             if(lstSrcObjOpt != null)
            lstSrcObjOpt.clear();
            //lstSrcObjOpt.add(new SelectOption(getTAG016(),getTAG016()));
            if(mapExstOfflViewObj != null)
            mapExstOfflViewObj.clear();
            if(lstFields != null)
            lstFields.clear();
            //lstFields.add(new SelectOption(getTAG016(),getTAG016()));
            filllstOwnShipLimit();   
            fillExcludedObjectMap();
            Map<String, Schema.SObjectType> tempallObjs = Schema.getGlobalDescribe();
            for(Schema.SObjectType lON : tempallObjs.values()) //Loop List of all Objects and describe each
            {
                Schema.DescribeSObjectResult D = lON.getDescribe();
                allObjs.put(D.getName(), lON);
                mapObjApiLabel.put(D.getName(),D.getLabel());
                //system.debug('mapObjApiLabelfull'+mapObjApiLabel);
                //system.debug('mapObjApiName '+D.getName());
                //system.debug('mapObjApiLabel '+D.getLabel());
            }
            
            if (did != null && IsValidSFID(did))
            {
                //system.debug('First loop');
                isEditMode = true;
                //SDL-SVMX-FLS-NOT-ENFORCED-META-DATA
                lstOfflObj_RefObj = [select id, SVMXC__Object_Name__c, SVMXC__Offline_Profile__c, SVMXC__User_Defined__c, SVMXC__Allow_Tab__c, SVMXC__Allow_Upload__c, SVMXC__SOQL_Query__c, SVMXC__Offline_Query__c, SVMXC__Allow_View_Override__c, SVMXC__Ownership_Limit__c, SVMXC__Lock_Criteria__c, SVMXC__Archival_Criteria__c, SVMXC__Use_Object_As_Home_Tab__c, SVMXC__Related_To__c, SVMXC__Parent_Object__c, SVMXC__Advanced_Download_Criteria__c, SVMXC__Advanced_Archival_Criteria__c, SVMXC__Advanced_Lock_Criteria__c, SVMXC__Allow_Attachment__c,SVMXC__Retain_Old_Records__c,SVMXC__Allow_API_Access__c from SVMXC__Offline_Object__c where Id=:did or SVMXC__Related_To__c =:did];
                for (SVMXC__Offline_Object__c o :lstOfflObj_RefObj)
                {
                    if (o.Id == did)
                    {
                        oOfflObj = o;
                    }
                    else if (o.SVMXC__Related_To__c == did && o.SVMXC__Parent_Object__c <> null)
                    {
                        AddChild = true;
                        lstOfflObj_MstChdList.add(o);   
                    }
                    else if (o.SVMXC__Related_To__c == did && o.SVMXC__Parent_Object__c == null)
                    {
                        wraperOfflObj_RefObj w = new wraperOfflObj_RefObj();
                        w.objOfflObj = o;
                        w.objOfflObj.SVMXC__Select__c = true;  
                        w.objObjlabel.SVMXC__Object_Name__c = mapObjApiLabel.get(o.SVMXC__Object_Name__c);
                        lstWrpOfflObj_RefObj.add(w);
                    }
                    
                }
                if (oOfflObj <> null )
                {
                    pid = oOfflObj.SVMXC__Offline_Profile__c ;
                    allowPageRender = true;
                    //SDL-SVMX-FLS-NOT-ENFORCED-META-DATA
                    lstOfflView =[select id, SVMXC__Field_Name__c, SVMXC__Display_Order__c from SVMXC__Offline_View__c where SVMXC__Object_Name__c = :did order by SVMXC__Display_Order__c];
                    for (SVMXC__Offline_View__c o:lstOfflView)
                    {
                        mapExstOfflViewObj.put(o.SVMXC__Field_Name__c,o);
                    }
                    //SDL-SVMX-FLS-NOT-ENFORCED-META-DATA
                    lstOffl_DSExp = [select Id, SVMXC__Type__c, SVMXC__Sequence__c, SVMXC__Operator__c, SVMXC__Operand__c, Name From SVMXC__Offline_Dataset_Expression__c where SVMXC__Offline_Object__c = :did order by SVMXC__Sequence__c];
                    for(SVMXC__Offline_Dataset_Expression__c oDExp :lstOffl_DSExp)
                    {
                        if(oDExp.SVMXC__Type__c == 'Download Criteria')
                            lstOffl_DSExpDW.add(oDExp);
                        else if(oDExp.SVMXC__Type__c == 'Lock Criteria')
                            lstOffl_DSExpLK.add(oDExp);
                        else if(oDExp.SVMXC__Type__c == 'Archival Criteria')
                            lstOffl_DSExpAR.add(oDExp);
                    }
                    Schema.SObjectType objT = allObjs.get(oOfflObj.SVMXC__Object_Name__c);
                    if(objT != null)
                    {
                    Schema.DescribeSObjectResult D = objT.getDescribe();
                    lstSrcObjOpt.add(new SelectOption(D.getName(),D.getLabel()));
                    }
                    SVMX_onSelectObject();
                    //SDL-SVMX-FLS-NOT-ENFORCED-META-DATA
                    lstExtOfflObj = [select id, SVMXC__Object_Name__c, SVMXC__Use_Object_As_Home_Tab__c, SVMXC__Allow_Attachment__c from SVMXC__Offline_Object__c where SVMXC__Offline_Profile__c = :oOfflObj.SVMXC__Offline_Profile__c and SVMXC__Related_To__c = null and SVMXC__Use_Object_As_Home_Tab__c = true];
                    if (lstExtOfflObj.size()>0 && lstExtOfflObj[0].SVMXC__Object_Name__c != oOfflObj.SVMXC__Object_Name__c)
                        strHomeObject = mapObjApiLabel.get(lstExtOfflObj[0].SVMXC__Object_Name__c);
                }
                else
                {
                    allowPageRender=false;
                    oOfflObj.id.addError(getTAG019());
                }
            }
            else
            {
                //system.debug('Second loop');
                if(IsValidSFID(pid)) 
                {
                    oOfflObj.SVMXC__Offline_Profile__c = pid;
                    //SDL-SVMX-FLS-NOT-ENFORCED-META-DATA
                    lstExtOfflObj = [select id, SVMXC__Object_Name__c, SVMXC__Offline_Profile__c, SVMXC__User_Defined__c, SVMXC__Allow_Tab__c, SVMXC__Allow_Upload__c, SVMXC__SOQL_Query__c, SVMXC__Offline_Query__c, SVMXC__Allow_View_Override__c, SVMXC__Ownership_Limit__c, SVMXC__Lock_Criteria__c, SVMXC__Archival_Criteria__c, SVMXC__Use_Object_As_Home_Tab__c, SVMXC__Related_To__c, SVMXC__Parent_Object__c,SVMXC__Advanced_Download_Criteria__c, SVMXC__Advanced_Archival_Criteria__c, SVMXC__Advanced_Lock_Criteria__c, SVMXC__Allow_Attachment__c,SVMXC__Retain_Old_Records__c,SVMXC__Allow_API_Access__c from SVMXC__Offline_Object__c where SVMXC__Offline_Profile__c = :oOfflObj.SVMXC__Offline_Profile__c and SVMXC__Related_To__c = null ];
                    //system.debug('lstExtOfflObj'+lstExtOfflObj);
                    allowPageRender = true;
                    isEditMode= false;
                    for(SVMXC__Offline_Object__c o :lstExtOfflObj)
                    {
                        mapExstOfflObj.put(o.SVMXC__Object_Name__c, o);
                        if (o.SVMXC__Use_Object_As_Home_Tab__c && o.SVMXC__Object_Name__c != oOfflObj.SVMXC__Object_Name__c)
                            strHomeObject = mapObjApiLabel.get(o.SVMXC__Object_Name__c);
                    }
                    for(Schema.SObjectType lON : allObjs.values()) //Loop List of all Objects and describe each
                    {
                        Schema.DescribeSObjectResult D = lON.getDescribe();
                        if(D.isAccessible() == true && D.isCustom() == true && !mapExstOfflObj.containsKey(D.getName()))
                            lstSrcObjOpt.add(new SelectOption(D.getName(),D.getLabel())); //Builing select Options for source object
                    }
                    //system.debug('lstSrcObjOpt'+lstSrcObjOpt);
                    addStandatdObjects();
                }
                else
                {
                    allowPageRender=false;
                    oOfflObj.id.addError(getTAG019());
                }
            }
            //SDL-SVMX-FLS-NOT-ENFORCED-META-DATA
            lstOfflProfile = [select SVMXC__Profile_Name__c from SVMXC__ServiceMax_Config_Data__c where id = :pid];
            SVMX_editDownload();
            if (!(lstTempOffl_DSExp.size() > 0))
            {
                for (integer j = 0; j < 2; j++) 
                {
                    addSearchExpression();
                }
            }
            else
            {
                integer j;
                integer iSize = lstTempOffl_DSExp.size();
                if(iSize > 0)
                {
                for(integer i = 0; i< iSize ; i++ )
                {
                    if(!(lstTempOffl_DSExp[i].SVMXC__Sequence__c == i + 1))
                    {
                        SVMXC__Offline_Dataset_Expression__c o = new SVMXC__Offline_Dataset_Expression__c(SVMXC__Sequence__c = i+1);
                        lstTempOffl_DSExp.add(i,o);
                    }
                }
                }
            }
        }
        catch(exception ex)
        {
            apexpages.addmessage(new apexpages.message(ApexPages.severity.ERROR, string.valueOf(ex)));
        }
    }
    private void addStandatdObjects()
    { 
        //for OEM
            if(PermittedObjectList.containsKey('Account') || isEnterpriseLicense) addObject('Account','Account');
            if(PermittedObjectList.containsKey('Case') || isEnterpriseLicense) addObject('Case','Case');
            if(PermittedObjectList.containsKey('Contact') || isEnterpriseLicense) addObject('Contact','Contact');
            if(PermittedObjectList.containsKey('Product2') || isEnterpriseLicense) addObject('Product2','Product2');
            if(PermittedObjectList.containsKey('Solution') || isEnterpriseLicense) addObject('Solution','Solution');
       //End OEM
       
    }
    private void filllstOwnShipLimit()
    {
        lstOwnShipLimit.add(new SelectOption('My Records',getTAG051()));
        lstOwnShipLimit.add(new SelectOption('All Records',getTAG052()));
    }
    private void fillExcludedObjectMap()
    {
        //for OEM
        /*if(PermittedObjectList.containsKey('User') || isEnterpriseLicense) mapExcludedObject.put('User','User');
        if(PermittedObjectList.containsKey('RecordType') || isEnterpriseLicense) mapExcludedObject.put('RecordType','RecordType');
        if(PermittedObjectList.containsKey('Group') || isEnterpriseLicense) mapExcludedObject.put('Group','Group');*/
        //End OEM
        mapExcludedObject.put('User','User');
        mapExcludedObject.put('RecordType','RecordType');
        mapExcludedObject.put('Group','Group');
       
    }
//======================================== Simple Display Utility ===================================================//    
    public SVMXC.COMM_Utils_ManageTags commUtil = new SVMXC.COMM_Utils_ManageTags();
    //public Map<String, String> svmxTagList = commUtil.SVMX_getTagList('OFFL003');
    
    public String getHLPURL() {return system.label.OFFL003_HLPURL;} //HLPURL
    public String getTAG001() {return system.label.OFFL003_TAG001;} //Save
    public String getTAG002() {return system.label.OFFL003_TAG002;} //Quick Save
    public String getTAG003() {return system.label.OFFL003_TAG003;} //Cancel
    public String getTAG004() {return system.label.OFFL003_TAG004;} //Object Name
    public String getTAG005() {return system.label.OFFL003_TAG005;} //Ownership Limit
    public String getTAG006() {return system.label.OFFL003_TAG006;} //Allow Upload Data from Offline  
    public String getTAG007() {return system.label.OFFL003_TAG007;} //Allow Tab in Offline
    public String getTAG008() {return system.label.OFFL003_TAG008;} //Set as Home Tab
    public String getTAG009() {return system.label.OFFL003_TAG009;} //Download Criteria
    public String getTAG010() {return system.label.OFFL003_TAG010;} //Lock Criteria
    public String getTAG011() {return system.label.OFFL003_TAG011;} //Archival Criteria
    public String getTAG012() {return system.label.OFFL003_TAG012;} //Define how objects should be processed in ServiceMax Offline
    public String getTAG013() {return system.label.OFFL003_TAG013;} //Salesforce Object Name
    public String getTAG014() {return system.label.OFFL003_TAG014;} //Download Related Record
    public String getTAG015() {return system.label.OFFL003_TAG015;} //Define a default Offline tab view
    public String getTAG016() {return system.label.OFFL003_TAG016;} //--None--
    public String getTAG017() {return system.label.OFFL003_TAG017;} //Please select the Object
    public String getTAG018() {return system.label.OFFL003_TAG018;} //Processing...
    public String getTAG019() {return system.label.OFFL003_TAG019;} //Invalid Data
    public String getTAG020() {return system.label.OFFL003_TAG020;} //Please select Fields
    public String getTAG021() {string str = '';if(lstOfflProfile.size() > 0) str = lstOfflProfile[0].SVMXC__Profile_Name__c; return system.label.OFFL003_TAG021 + ' ' + str ;} //Define Offline Dataset
    public String getTAG022() {return system.label.OFFL003_TAG022;} //Delete
    public String getTAG023() {return system.label.OFFL003_TAG023;} //Advance Option
    public String getTAG024() {return system.label.OFFL003_TAG024;} //Manage DataSet Help
    public String getTAG025() {return system.label.OFFL003_TAG025;} //Add Row
    public String getTAG026() {return system.label.OFFL003_TAG026;} //Note
    public String getTAG027() {return system.label.OFFL003_TAG027;} //Dates Must be Entered in ' + getInputDateFormat() + ' format or use special date literals (ex: THIS WEEK)
    public String getTAG028() {return system.label.OFFL003_TAG028;} //Field
    public String getTAG029() {return system.label.OFFL003_TAG029;} //Operator
    public String getTAG030() {return system.label.OFFL003_TAG030;} //Value
    public String getTAG031() {return system.label.OFFL003_TAG031;} //Invalid Date Format :
    public String getTAG032() {return system.label.OFFL003_TAG032;} //Invalid Operator for this Field Type :
    public String getTAG033() {return system.label.OFFL003_TAG033;} //Invalid Advance Option
    public String getTAG034() {return system.label.OFFL003_TAG034;} //Value can only be TRUE or FALSE
    public String getTAG035() {return system.label.OFFL003_TAG035;} //Tips
    public String getTAG036() {return system.label.OFFL003_TAG036;} //Delete Row
    public String getTAG037() {return system.label.OFFL003_TAG037;} //Are you sure you wish to continue?
    public String getTAG038() {return system.label.OFFL003_TAG038;} //Top
    public String getTAG039() {return system.label.OFFL003_TAG039;} //Up
    public String getTAG040() {return system.label.OFFL003_TAG040;} //Down
    public String getTAG041() {return system.label.OFFL003_TAG041;} //Bottom
    public String getTAG042() {return system.label.OFFL003_TAG042;} //Advance Option Help
    public String getTAG043() {return system.label.OFFL003_TAG043;} //Select Object
    public String getTAG044() {return system.label.OFFL003_TAG044;} //Available Fields
    public String getTAG045() {return system.label.OFFL003_TAG045;} //Add
    public String getTAG046() {return system.label.OFFL003_TAG046;} //Remove
    public String getTAG047() {return system.label.OFFL003_TAG047;} //Selected Fields
    public String getTAG048() {return system.label.OFFL003_TAG048 +' '+strHomeObject ;} //current home tab object ' + strHomeObject
    public String getTAG049() {return system.label.OFFL003_TAG049;} //Allow Child Objects
    public String getTAG050() {return system.label.OFFL003_TAG050;} //This is a child Object.
    public String getTAG051() {return system.label.OFFL003_TAG051;} //My Records. //By GM Nov132010
    public String getTAG052() {return system.label.OFFL003_TAG052;} //All records. //By GM Nov132010
    
//*****************************************Simple Display Utility ***************************************************//    
    
    
   public boolean IsValidSFID(String strSFID)
    {
        if (strSFID <> null && strSFID <> '' && strSFID.length() > 0)
            return true;
        else
            return false;
    }
 
      //----------------------------------Sorting Function-----------------------------------------------
    public List<wraperOfflObj_RefObj> sortWrpOfflObj(List<wraperOfflObj_RefObj> sortList)
    {
        wraperOfflObj_RefObj tempObj;               
        Integer size = sortList.size();
        Integer i,j;
        for(i=0;i<size;i++)
        {
            for(j=i+1;j<size;j++)
            {
                if(sortList[i].objObjlabel != null && sortList[j].objObjlabel != null && (sortList[i].objObjlabel.SVMXC__Object_Name__c.toUpperCase().compareTo(sortList[j].objObjlabel.SVMXC__Object_Name__c.toUpperCase()) > 0))
                {
                    tempObj = sortList[j];
                    sortList[j] = sortList[i];
                    sortList[i] = tempObj;
                }
            }
        }
        return sortList;
    }
    public List<SelectOption> sortSelectOption(List<SelectOption> sortList, Boolean AddDefault)
    {
        List<SelectOption> resultList = new List<SelectOption>();
        Map<String,List<SelectOption>> tempLst = new Map<String,List<SelectOption>>();
        for(SelectOption SO:sortList) {
            tempLst.put(SO.getLabel(), new List<SelectOption>()); 
            tempLst.get(SO.getLabel()).add(SO);
        }
        List<String> keys = new List<String>(tempLst.keySet());
        keys.sort();
        for(String key:keys) { resultList.addAll(tempLst.get(key)); }
        
        if(AddDefault && resultList!= null && resultList.size() > 0 && resultList[0].getValue() != getTAG016())
            resultList.add(0, new SelectOption(getTAG016(),getTAG016()));
        else if(AddDefault && sortList != null && sortList.size() == 0)
            resultList.add(new SelectOption(getTAG016(),getTAG016()));
        return resultList;        
       
    }
//-------------------------Button Events--------------------------------//    
    public PageReference SVMX_doCancel() //Called on Cancel from VF Page
    {
        if(isValidSFID(pid))
        {
            PageReference scrn = new PageReference('/apex/SVMXC__OFFL_ManageOfflineProfile?pid='+pid);
            scrn.setRedirect(true);
            return scrn;
        }
        else
        {
            return null;
        }
    }
    public PageReference SVMX_doSave() //Called on Save from VF Page
    {
        String strRes;
        try
        {
            if (isValidData())
                strRes = SVMX_processSave();
            if( strRes <> null) 
            {
                PageReference scrn = new PageReference('/apex/SVMXC__OFFL_ManageOfflineProfile?pid='+pid);
                scrn.setRedirect(true);
                return scrn;
            }
            else
                return null;
        }
        catch(Exception ex)
        {
            apexpages.addmessage(new apexpages.message(ApexPages.severity.ERROR, string.valueOf(ex)));
            return null;
        }
    }
    public PageReference SVMX_doQuickSave() //Called on 'Quick Save' from VF page
    {
        String strRes;
        try
        {
            if (isValidData())
                strRes = SVMX_processSave();
            if(strRes <> null) 
             {
                PageReference scrn = new PageReference('/apex/SVMXC__OFFL_ManageDataSets?did='+strRes);
                scrn.setRedirect(true);
                return scrn;
             }
             else
                 return null;
        }
        catch(Exception ex)
        {
            apexpages.addmessage(new apexpages.message(ApexPages.severity.ERROR, string.valueOf(ex)));
            return null;
        }
        return null;
    }
/*    
    public PageReference SVMX_doDelete()
    {
        Savepoint sp = Database.setSavepoint();
        try
        {
            if (oOfflObj <> null)
            {
                List<SVMXC__Offline_Object__c> lstOfflObjToDelete = new List<SVMXC__Offline_Object__c> ();
                lstOfflObjToDelete.add(oOfflObj);
                lstOfflObjToDelete.addAll(lstOfflObj_MstChdList);
                if (lstWrpOfflObj_RefObj.size() > 0)
                {
                    for(wraperOfflObj_RefObj w :lstWrpOfflObj_RefObj)
                    {
                        if(w.objOfflObj.id <> null)
                            lstOfflObjToDelete.add(w.objOfflObj);
                    }
                }
                if(lstOfflObjToDelete.size() > 0)
                    delete lstOfflObjToDelete;
                if(lstOfflView.size() > 0)
                    delete lstOfflView;
                if(lstOffl_DSExp.size() > 0)
                    delete lstOffl_DSExp;
                PageReference scrn = new PageReference('/apex/OFFL_ManageOfflineProfile?pid='+pid);
                scrn.setRedirect(true);
                return scrn;
            }
            else
            {
                allowPageRender=false;
                oOfflObj.id.addError(getTAG019());
                return null;
            }
        }
        catch(Exception ex)
        {
            Database.rollback(sp);
            apexpages.addmessage(new apexpages.message(ApexPages.severity.ERROR, string.valueOf(ex)));
            return null;
        }
    }
*/
    public boolean isValidData()
    {   
        if (oOfflObj <> null && oOfflObj.SVMXC__Object_Name__c == getTAG016())
        {
            apexpages.addmessage(new apexpages.message(ApexPages.severity.ERROR, getTAG017()));
            return false;
        }
        else 
            return true;
    }
    /*
    public void deleteDataSet(List<SVMXC__Offline_Object__c> lstOfflObjToDel)
    {
        set<ID> setId = new set<ID>();
        for (SVMXC__Offline_Object__c o :lstOfflObjToDel)
        {
            setId.add(o.id);
        }
        list<SVMXC__Offline_Object__c> lstOfflObj = [select id from SVMXC__Offline_Object__c where Id IN :setId or SVMXC__Related_To__c IN :setId or SVMXC__Parent_Object__c IN :setId];
        list<SVMXC__Offline_View__c > lstOfflView = [select id from SVMXC__Offline_View__c where SVMXC__Object_Name__c IN :setId];
        if (lstOfflObj.size()>0 )
            delete lstOfflObj;
        if (lstOfflView.size()>0 )
            delete lstOfflView;
    }
    */
    public String SVMX_processSave() 
    {
        SVMX_Update_Download();
        if (!isValidCri )
        {
            return null;
        }
        else if (isChild)
        {
            apexpages.addmessage(new apexpages.message(ApexPages.severity.ERROR, getTAG050()));
            return null;
        }
        else
        {
            Savepoint sp = Database.setSavepoint();
            try
            {
                if(lstOffl_DSExpDW.size() > 0 && oOfflObj.SVMXC__SOQL_Query__c <> null && oOfflObj.SVMXC__SOQL_Query__c.trim().length() > 0)
                {
                    try
                    {
                        string str = 'select id from '+ oOfflObj.SVMXC__Object_Name__c + ' where '+ oOfflObj.SVMXC__SOQL_Query__c +' limit 1 ';
                        list<SObject> lst = Database.query(str);
                    }
                    catch(exception ex)
                    {
                        isValidCri = false;
                        showPageError = true;
                        apexpages.addmessage(new apexpages.message(ApexPages.severity.ERROR, string.valueOf(ex)));
                        return null;
                    }
                    showPageError = false;
                }
                oOfflObj.SVMXC__User_Defined__c = true;
                oOfflObj.SVMXC__Offline_Query__c = oOfflObj.SVMXC__SOQL_Query__c;
                if(lstOffl_DSExpDW.size() == 0)
                    oOfflObj.SVMXC__Advanced_Download_Criteria__c = '';
                list<SVMXC__Offline_Object__c> lstUpOfflObj = new list<SVMXC__Offline_Object__c>(); 
                if(oOfflObj.SVMXC__Use_Object_As_Home_Tab__c)
                {
                    for(SVMXC__Offline_Object__c o :lstExtOfflObj)
                    {
                        if (o.SVMXC__Use_Object_As_Home_Tab__c && oOfflObj.id != o.ID)
                        {
                            o.SVMXC__Use_Object_As_Home_Tab__c = false;
                            lstUpOfflObj.add(o);
                        }
                    }
                }
                /*system.debug('AllowAttachment:'+oOfflObj.SVMXC__Allow_Attachment__c);
                if(oOfflObj.SVMXC__Allow_Attachment__c )
                {
                    SVMXC__Offline_Object__c oOffl = new SVMXC__Offline_Object__c();
                    oOffl.SVMXC__Object_Name__c='Attachment';
                    oOffl.SVMXC__User_Defined__c=false;
                    oOffl.SVMXC__Allow_Upload__c=true;
                    oOffl.SVMXC__Offline_Profile__c = oOfflObj.SVMXC__Offline_Profile__c;
                    lstUpOfflObj.add(oOffl);
                }*/
                lstUpOfflObj.add(oOfflObj);
                
                if( COMM_SecurityUtils.getInstance().verifyFieldAccess( lstUpOfflObj, COMM_SecurityUtils.Access.Upsertable ) ) {
                    //SDL-SVM-XCREATE-UPDATE-FLS-ENFORCED
                    upsert lstUpOfflObj;
                } else {
                    throw new COMM_SecurityUtils.SecurityAccessException( System.Label.COMM001_TAG142 );
                }
            
                String strOfflObj_Id = oOfflObj.id;
                if(oOfflObj.id <> null && strOfflObj_Id.length() > 0 )
                { 
                    List<SVMXC__Offline_Object__c> listOfflObjToDelete = new List<SVMXC__Offline_Object__c>(); 
                    if(lstOfflObj_RefObj != null)
                    lstOfflObj_RefObj.clear();
                    for (SVMXC__Offline_Object__c oOffl :lstOfflObj_MstChdList)
                    {
                        oOffl.SVMXC__User_Defined__c = true;
                        oOffl.SVMXC__Parent_Object__c = oOfflObj.SVMXC__Object_Name__c;
                        oOffl.SVMXC__Related_To__c = oOfflObj.id;
                        oOffl.SVMXC__Offline_Profile__c = oOfflObj.SVMXC__Offline_Profile__c;
                        oOffl.SVMXC__Allow_Upload__c = oOfflObj.SVMXC__Allow_Upload__c;
                        //oOffl.SVMXC__Allow_Attachment__c = oOfflObj.SVMXC__Allow_Attachment__c;
                        
                        if (AddChild)
                            lstOfflObj_RefObj.add(oOffl);
                        if( !AddChild && oOffl.id != null)
                            listOfflObjToDelete.add(oOffl);
                    }
                    
                    for(wraperOfflObj_RefObj w :lstWrpOfflObj_RefObj)
                    {
                        if (w.objOfflObj.SVMXC__Select__c)
                        {
                            SVMXC__Offline_Object__c oOffl = w.objOfflObj;
                            oOffl.SVMXC__User_Defined__c = true;
                            oOffl.SVMXC__Related_To__c = oOfflObj.id;
                            oOffl.SVMXC__Offline_Profile__c = oOfflObj.SVMXC__Offline_Profile__c;
                            lstOfflObj_RefObj.add(oOffL);
                        }
                        else if(w.objOfflObj.id <> null)
                            listOfflObjToDelete.add(w.objOfflObj);
                    }
                    if (lstOfflObj_RefObj.size()>0)
                        //SDL-SVMX-FLS-NOT-ENFORCED-META-DATA
                        upsert lstOfflObj_RefObj;
                    if (listOfflObjToDelete.size()>0)
                        //SDL-SVMX-FLS-NOT-ENFORCED-META-DATA
                        delete listOfflObjToDelete;
                    integer i=1;
                    list<SVMXC__Offline_View__c> lstOfflViewToDelete = new list<SVMXC__Offline_View__c>();
                    lstOfflViewToDelete.addAll(lstOfflView);
                    list<integer> lsti = new list<integer>();
                    for(SelectOption sopOfflView :lstSFieldsOpt)
                    {
                        boolean b = false;
                        integer j =1;
                        for (SVMXC__Offline_View__c oOfflView :lstOfflView)
                        {
                            if (oOfflView.SVMXC__Field_Name__c == sopOfflView.getValue())
                            {
                                lstOfflViewToDelete[j-1] = null;
                                oOfflView.SVMXC__Display_Order__c = i;
                                b = true;
                                break;
                            }   
                            j += 1;
                        }
                        if (!b)
                        {
                            SVMXC__Offline_View__c oOfflView = new SVMXC__Offline_View__c ();
                            oOfflView.SVMXC__Object_Name__c = oOfflObj.id;  
                            oOfflView.SVMXC__Field_Name__c = sopOfflView.getValue();
                            oOfflView.SVMXC__Display_Order__c =i;
                            lstOfflView.add(oOfflView);
                            b = false;
                        }
                        i+=1;
                    }
                    if(lstOfflView.size() > 0)
                        //SDL-SVMX-FLS-NOT-ENFORCED-META-DATA
                        upsert lstOfflView; 
                    list<SVMXC__Offline_View__c> lstOfflViewToDelete2 = new list<SVMXC__Offline_View__c>();
                    for(SVMXC__Offline_View__c o :lstOfflViewToDelete)
                    {
                        if(o <> null)
                            lstOfflViewToDelete2.add(o);
                    }
                    if(lstOfflViewToDelete2.size() > 0)
                        //SDL-SVMX-FLS-NOT-ENFORCED-META-DATA
                        delete lstOfflViewToDelete2;
                    List<SVMXC__Offline_Dataset_Expression__c> lstObjToDelete = new List<SVMXC__Offline_Dataset_Expression__c>();
                    list <SVMXC__Offline_Dataset_Expression__c > lstUpsertOffl_DSExp = new list <SVMXC__Offline_Dataset_Expression__c >(); 
                    if(lstUpsertOffl_DSExp != null)
                    lstUpsertOffl_DSExp.clear();
                    lstUpsertOffl_DSExp.addAll(lstOffl_DSExpDW);
                    lstUpsertOffl_DSExp.addAll(lstOffl_DSExpLK);
                    lstUpsertOffl_DSExp.addAll(lstOffl_DSExpAR);
                    for(SVMXC__Offline_Dataset_Expression__c  oUpODE :lstUpsertOffl_DSExp)
                    {
                        oUpODE.SVMXC__Offline_Object__c = oOfflObj.id;
                    }  
                    for(SVMXC__Offline_Dataset_Expression__c  oODE :lstOffl_DSExp)
                    {
                        boolean isIDExists= false;
                        for(SVMXC__Offline_Dataset_Expression__c  oUpODE :lstUpsertOffl_DSExp)
                        {
                            if(oODE.Id == oUpODE.Id)
                            {
                                if( oODE.Name == getTAG016() || oODE.SVMXC__Operator__c == getTAG016() )
                                    lstObjToDelete.add(oODE);
                                isIDExists=true;
                                break;
                            }
                        }   
                        if (!isIDExists)
                        {
                            if (oODE.id <> null)
                                lstObjToDelete.add(oODE);
                            isIDExists=false;
                        }
                    }
                    if (lstUpsertOffl_DSExp.size() > 0)
                        //SDL-SVMX-FLS-NOT-ENFORCED-META-DATA
                        upsert lstUpsertOffl_DSExp;
                    if (lstObjToDelete.size() > 0)
                        //SDL-SVMX-FLS-NOT-ENFORCED-META-DATA
                        delete lstObjToDelete;
                }
                return oOfflObj.Id;
            }
            catch(Exception ex)
            {
                Database.rollback(sp);
                apexpages.addmessage(new apexpages.message(ApexPages.severity.ERROR, string.valueOf(ex)));
                return null;
            }
        }
    }
    public PageReference SVMX_editLock()
    {
        if(lstOffl_DSExpLK != null && lstOffl_DSExpLK.size()>0)
        {
            if(lstTempOffl_DSExp != null)
            lstTempOffl_DSExp.clear();
            lstTempOffl_DSExp.addAll(lstOffl_DSExpLK);
            strAdvanceOption = oOfflObj.SVMXC__Advanced_Lock_Criteria__c;
        }   
        return null;
    }
    public PageReference SVMX_editDownload()
    {
        if(lstOffl_DSExpDW != null && lstOffl_DSExpDW.size()>0)
        {
            if(lstTempOffl_DSExp != null)
            lstTempOffl_DSExp.clear();
            lstTempOffl_DSExp.addAll(lstOffl_DSExpDW);
            strAdvanceOption = oOfflObj.SVMXC__Advanced_Download_Criteria__c;
        }
        return null;
    }
    public PageReference SVMX_editArchival()
    {
        if(lstOffl_DSExpAR.size()>0)
        {
            if(lstTempOffl_DSExp != null)
            lstTempOffl_DSExp.clear();
            lstTempOffl_DSExp.addAll(lstOffl_DSExpAR);
            strAdvanceOption = oOfflObj.SVMXC__Advanced_Archival_Criteria__c;
        }   
        return null;
    }
    public List<SVMXC__Offline_Dataset_Expression__c> updateExpLst(List<SVMXC__Offline_Dataset_Expression__c> lstODE, string strExpType )
    {
        if(lstTempOffl_DSExp.size() > 0 )
        {
            for (SVMXC__Offline_Dataset_Expression__c oTmpODE :lstTempOffl_DSExp)
            {
                if(oTmpODE.Name <> getTAG016() && oTmpODE.SVMXC__Operator__c <> getTAG016())
                {
                    boolean isExpAdded = false;
                    integer i=0;
                    for (SVMXC__Offline_Dataset_Expression__c oODE :lstODE)
                    {
                        if (oTmpODE.SVMXC__Sequence__c == oODE.SVMXC__Sequence__c )
                        {
                            lstODE[i].Name = oTmpODE.Name;
                            lstODE[i].SVMXC__Operator__c = oTmpODE.SVMXC__Operator__c;
                            lstODE[i].SVMXC__Operand__c = oTmpODE.SVMXC__Operand__c;
                            lstODE[i].SVMXC__Type__c = strExpType;
                            lstODE[i].SVMXC__Offline_Object__c = oOfflObj.Id;
                            isExpAdded = true;
                        }
                        i+=1;
                    }
                    if(!isExpAdded)
                    {
                        SVMXC__Offline_Dataset_Expression__c oODE = new SVMXC__Offline_Dataset_Expression__c();
                        oODE.SVMXC__Sequence__c = oTmpODE.SVMXC__Sequence__c;
                        oODE.Name = oTmpODE.Name;
                        oODE.SVMXC__Operator__c = oTmpODE.SVMXC__Operator__c;
                        oODE.SVMXC__Operand__c = oTmpODE.SVMXC__Operand__c;
                        oODE.SVMXC__Type__c = strExpType;
                        oODE.SVMXC__Offline_Object__c = oOfflObj.Id;
                        lstODE.add(oODE);
                        isExpAdded = false;
                    }
                }
            }
        }
        else
        {
            if(lstODE != null)
            lstODE.clear();
        }
        return lstODE;
    }
    public void SVMX_Update_Download() 
    {
        lstOffl_DSExpDW = updateExpLst(lstOffl_DSExpdw, 'Download Criteria'); 
        oOfflObj.SVMXC__SOQL_Query__c = getCriteria('Download Criteria');
        oOfflObj.SVMXC__Advanced_Download_Criteria__c = strAdvanceOption;
    }
    public Boolean SVMX_Update_Lock() 
    {
        lstOffl_DSExpLK = updateExpLst(lstOffl_DSExpLK, 'Lock Criteria'); 
        oOfflObj.SVMXC__Lock_Criteria__c = getCriteria('Lock Criteria');
        oOfflObj.SVMXC__Advanced_Lock_Criteria__c = strAdvanceOption;
        return null;
    }
    public Boolean SVMX_Update_Archival() 
    {
        lstOffl_DSExpAR = updateExpLst(lstOffl_DSExpAR, 'Archival Criteria');
        oOfflObj.SVMXC__Archival_Criteria__c = getCriteria('Archival Criteria') ;
        oOfflObj.SVMXC__Advanced_Archival_Criteria__c = strAdvanceOption; 
        return null;
    }
    public String getCriteria(string strType)
    {
        boolean isAdvanceOption = true;
        if (!(lstTempOffl_DSExp.size() > 0))
        {   
            return '';
        }
        if (strAdvanceOption == null || strAdvanceOption.trim().length() == 0 )
        {
            isAdvanceOption = false;
            if(lstTempOffl_DSExp.size() != 1)
            {
                for(integer i = 0; i <= lstTempOffl_DSExp.size()-1; i++)
                {
                    if (lstTempOffl_DSExp[i].Name != getTAG016() && lstTempOffl_DSExp[i].SVMXC__Operator__c != getTAG016())
                        strAdvanceOption += i+1;
                    if ( i != lstTempOffl_DSExp.size()-1 && lstTempOffl_DSExp[i+1].Name != getTAG016() && lstTempOffl_DSExp[i+1].SVMXC__Operator__c != getTAG016())
                    {
                        strAdvanceOption += ' AND ';
                       /* if (i == lstTempOffl_DSExp.size()- 2)
                            strAdvanceOption += i+2;*/
                    }
                }
            }
            else
            {
                if (lstTempOffl_DSExp[0].Name != getTAG016() && lstTempOffl_DSExp[0].SVMXC__Operator__c != getTAG016())
                    strAdvanceOption=string.valueOf(1);
            }
        }
        string strCriteria = strAdvanceOption.toUpperCase();
        for(integer i=1;i<=lstTempOffl_DSExp.size();i++)
        {
            if (lstTempOffl_DSExp[i-1].Name <> getTAG016() || lstTempOffl_DSExp[i-1].SVMXC__Operator__c <> getTAG016())
            {
                strCriteria = strCriteria.replace(string.valueOf(i),' ~'+i+'~ ');
            }
            else
            {
                if (strAdvanceOption.contains(string.ValueOf(i)))
                {
                    if(!(isAdvanceOption))
                        strAdvanceOption = '';
                    lstTempOffl_DSExp[i-1].Name.addError(getTAG033() + ':'+ mapfldApiName.get(lstTempOffl_DSExp[i-1].Name));
                    isValidCri = false;
                    showPageError = true;
                    return null;
                }
            }
        }
        for(integer i=0;i<lstTempOffl_DSExp.size();i++)
        {
            if (lstTempOffl_DSExp[i].Name <> getTAG016() || lstTempOffl_DSExp[i].SVMXC__Operator__c <> getTAG016())
            {
                string s = buildWhereClause(false, lstTempOffl_DSExp.get(i),i );
                if (s <> null && s.length() > 0)
                    strCriteria = strCriteria.replace('~'+(i+1)+'~', s);
                else break;
            }
        }
        return strCriteria;
    }
    public boolean isExpExists(string strFieldName, string strExpTypr)
    {
        for(SVMXC__Offline_Dataset_Expression__c o :lstOffl_DSExp)
        {
            if (o.SVMXC__Type__c == strExpTypr && o.Name == strFieldName)
                return true;
        }
        return false;
    }
    public void SVMX_addRow()
    {
        addSearchExpression();
    }
    public void SVMX_removeRow()
    {
         lstTempOffl_DSExp.remove(delind-1);
         //lstOffl_DSExpdw.remove(delind-1);
         for( integer i = delind; i <= lstTempOffl_DSExp.size(); i++ )
         {
            lstTempOffl_DSExp[i-1].SVMXC__Sequence__c = i;
            //lstOffl_DSExpdw[i-1].SVMXC__Sequence__c = i;
         }
         lstOffl_DSExpdw=lstTempOffl_DSExp;
    }

    public void SVMX_MoveUp()
    {
        for(Integer i=0 ; i<lstSelFields.size();i++)
        {
            for ( Integer j=0 ; j<lstSFieldsOpt.size();j++)
            {
                if ( lstSFieldsOpt.get(j).getValue() == lstSelFields[i])
                {
                    if (!(j==0))
                    {
                        lstSFieldsOpt.add(j-1, lstSFieldsOpt.get(j));
                        lstSFieldsOpt.remove(j+1);
                    }
                }
            }
        }
        
    }
    public void SVMX_MoveTop()
    {
        for(Integer i=0 ; i<lstSelFields.size();i++)
        {
            for ( Integer j=0 ; j<lstSFieldsOpt.size();j++)
            {
                if ( lstSFieldsOpt.get(j).getValue() == lstSelFields[i])
                {
                    if (!(j==0))
                    {
                        lstSFieldsOpt.add(0, lstSFieldsOpt.get(j));
                        lstSFieldsOpt.remove(j+1);
                    }
                }
            }
        }
    }
    public void SVMX_MoveDown()
    {
        for(Integer i=0 ; i<lstSelFields.size();i++)
        {
            for ( Integer j=lstSFieldsOpt.size()-1 ; j>=0;j--)
            {
                if ( lstSFieldsOpt.get(j).getValue() == lstSelFields[i])
                {
                    if (!(j==lstSFieldsOpt.size()-2))
                    {
                        if (!(j==lstSFieldsOpt.size()-1))
                        {
                            lstSFieldsOpt.add(j+2, lstSFieldsOpt.get(j));
                            lstSFieldsOpt.remove(j);
                        }
                    }
                    else
                    {   
                        lstSFieldsOpt.add(lstSFieldsOpt.get(j));
                        lstSFieldsOpt.remove(j);
                    }   
                }
            }
        }
    }
    public void SVMX_MoveBottom()
    {
        for(Integer i=0 ; i<lstSelFields.size();i++)
        {
            for ( Integer j=lstSFieldsOpt.size()-1 ; j>=0;j--)
            {
                if ( lstSFieldsOpt.get(j).getValue() == lstSelFields[i])
                {
                    if (!(j==lstSFieldsOpt.size()-1))
                    {
                        lstSFieldsOpt.add(lstSFieldsOpt.get(j));
                        lstSFieldsOpt.remove(j);
                    }
                }
            }
        }
    }
    public PageReference SVMX_onAddFields() 
    {
        Integer i;
        for(String fs: lstAvlbFields)
        {
            for(i = 0; i < lstFieldsOpt.size();i++)
            {
                if(fs == lstFieldsOpt[i].getvalue())
                {
                    lstSFieldsOpt.add(lstFieldsOpt.get(i));
                    lstFieldsOpt.remove(i);
                }
            }
        }
        return null;
    }
    public PageReference SVMX_onRemField() 
    {
        Integer i;
        for(String fs: lstSelFields)
        {
            for(i = 0; i < lstSFieldsOpt.size();i++)
            {
                if(fs == lstSFieldsOpt[i].getvalue())
                {
                    lstFieldsOpt.add(lstSFieldsOpt.get(i));
                    lstSFieldsOpt.remove(i);
                }
            }
        }
        return null;
    }
    public void SVMX_homeTabSelected()
    {
        if(oOfflObj.SVMXC__Use_Object_As_Home_Tab__c && strHomeObject != null && strHomeObject.length()>0 )
        { 
            showPageError = false;
            apexpages.addmessage(new apexpages.message(ApexPages.severity.WARNING, getTAG048()));
        } 
    }
    public PageReference SVMX_onSelectObject() 
    {
        //system.debug('Entered change method');
        try
        {
            if (!isEditMode)
            {
                //system.debug('entered not is edit mode');
                if(lstWrpOfflObj_RefObj != null)
                lstWrpOfflObj_RefObj.clear();
                if(lstFieldsOpt != null)
                lstFieldsOpt.clear();
                if(lstSFieldsOpt != null)
                lstSFieldsOpt.clear();
                if(lstFields != null)
                lstFields.clear();
                //lstFields.add(new SelectOption(getTAG016(),getTAG016()));
            }
            //system.debug('object selection'+oOfflObj.SVMXC__Object_Name__c);
            //system.debug('Tagtext '+getTAG016());
            if(oOfflObj.SVMXC__Object_Name__c == getTAG016())
            {
                return null;
            }
            List<Schema.ChildRelationship> C = (allObjs.get(oOfflObj.SVMXC__Object_Name__c)).getDescribe().getChildRelationships();
             system.debug('Did not enter ');
            for(Schema.ChildRelationship CR :C)
            {
                Schema.DescribeSObjectResult D = CR.getChildSObject().getDescribe(); 
                if(D.isAccessible() && CR.isCascadeDelete() && D.isCustom() )
                { 
                    if (!isRelatedObjExist(D.getName()))
                    {
                        SVMXC__Offline_Object__c objOfflObj = new SVMXC__Offline_Object__c();
                        objOfflObj.SVMXC__Object_Name__c = D.getName();
                        objOfflObj.SVMXC__Child_To_Parent_Field_Name__c = string.valueOf(CR.getField()); 
                        lstOfflObj_MstChdList.add(objOfflObj);
                    }
                }
            }
            //system.debug('lstOfflObj_MstChdList'+lstOfflObj_MstChdList);
            //system.debug('oOfflObj.SVMXC__Object_Name__c'+oOfflObj.SVMXC__Object_Name__c);
            SVMX_GetFields(oOfflObj.SVMXC__Object_Name__c);
            ProfDisplayBlockLevelMessage=false;
            headerDisplayBlockLevelMessage=false;
            headerRecDisplayBlockLevelMessage=false;
            return null;
        }
        catch(exception ex)
        {
            showPageError = false;
            apexpages.addmessage(new apexpages.message(ApexPages.severity.ERROR, string.valueOf(ex)));
            return null;
        }
    }  
   
    public void addObject(string strObjName, string strObjLabel)
    {
        if(!mapExstOfflObj.containsKey(strObjName))
        {
            lstSrcObjOpt.add(new SelectOption(strObjName,strObjLabel));
            mapObjApiLabel.put(strObjName,strObjLabel);
        }
    }
   
    public Boolean DisplayBlockLevelMessage = false;
        public Boolean getDisplayBlockLevelMessage(){ return DisplayBlockLevelMessage; }  
    public Boolean ProfDisplayBlockLevelMessage = false;
        public Boolean getProfDisplayBlockLevelMessage(){ return ProfDisplayBlockLevelMessage; }   
    public Boolean headerDisplayBlockLevelMessage = false;
        public Boolean getheaderDisplayBlockLevelMessage(){ return headerDisplayBlockLevelMessage; }   
    public Boolean headerRecDisplayBlockLevelMessage = false;
        public Boolean getheaderRecDisplayBlockLevelMessage(){ return headerRecDisplayBlockLevelMessage; }
    public Boolean allowPageRender = false;
        public Boolean getallowPageRender(){return allowPageRender;}
    
    public void SVMX_GetFields(String objName)
    {
        isChild = true;
        List<String> fldList = new List<String>();
        Map<String,Schema.SObjectField> objfieldMap = new Map<String,Schema.SObjectField>();
        Map<String,String> mapTempFldName = new Map<String,String>();
        Schema.SObjectType objT = allObjs.get(objName) ;
        if(objT != null)
        objfieldMap = objT.getDescribe().fields.getMap();
        for (String fieldKey : objfieldMap.keySet()) 
        {
            Schema.SObjectField fsObj = objfieldMap.get(fieldKey);
            Schema.DescribeFieldResult f = fsObj.getDescribe();
            
            mapfieldType.put(f.getName(),f.getType().name());
            mapfldApiLabel.put(f.getLabel(),f.getName());
            mapfldApiName.put(f.getName(),f.getLabel());
            if (!isEnterpriseLicense)
            {
                if(f.getType() == Schema.DisplayType.REFERENCE )
                     {
                         Schema.SObjectType sobjRefTo = f.getReferenceTo()[0];
                         if(sobjRefTo != null)
                         {
                         Schema.DescribeSObjectResult dsobjresRefTo = sobjRefTo.getDescribe();
                         if(AllowedObjects.contains(dsobjresRefTo.getName())||dsobjresRefTo.isCustom()||mapExcludedObject.containsKey(dsobjresRefTo.getName()))
                            {
                                lstFields.add(new SelectOption(f.getName(),f.getLabel()));
                            }
                         }
                        
                         
                
                     }
                     else
                     {
                        lstFields.add(new SelectOption(f.getName(),f.getLabel()));
                        
                     }
                
                
                
            }
            else
            {
                lstFields.add(new SelectOption(f.getName(),f.getLabel()));
            }
            if (f.getName() == 'ownerid' || objName == 'Product2')
                isChild = false;
            if(f.getType() == Schema.DisplayType.REFERENCE )
            {
                Schema.SObjectType sobjRefTo = f.getReferenceTo()[0];
                if(sobjRefTo != null)
                {
                   Schema.DescribeSObjectResult dsobjresRefTo = sobjRefTo.getDescribe();
                  if (!isRefObjExist(dsobjresRefTo.getName()))
                  {
                    
                    if(!(mapExcludedObject.containsKey(dsobjresRefTo.getName())))
                    {
                        system.debug('RefObjectname2'+dsobjresRefTo.getName());
                        if (!isEnterpriseLicense)
                        {
                            wraperOfflObj_RefObj w = new wraperOfflObj_RefObj();
                            SVMXC__Offline_Object__c objOfflObj = new SVMXC__Offline_Object__c();
                            
                            if(AllowedObjects.contains(dsobjresRefTo.getName())||dsobjresRefTo.isCustom())
                            {
                                objOfflObj.SVMXC__Object_Name__c = dsobjresRefTo.getName();
                                w.objOfflObj = objOfflObj; //Builing select Options for source object
                                w.objObjlabel.SVMXC__Object_Name__c = mapObjApiLabel.get(dsobjresRefTo.getName());
                                lstWrpOfflObj_RefObj.add(w);
                                
                            }
                      
                            
            
                        }
                        else
                        {
                        wraperOfflObj_RefObj w = new wraperOfflObj_RefObj();
                        SVMXC__Offline_Object__c objOfflObj = new SVMXC__Offline_Object__c();
                        objOfflObj.SVMXC__Object_Name__c = dsobjresRefTo.getName();
                        w.objOfflObj = objOfflObj; //Builing select Options for source object
                        w.objObjlabel.SVMXC__Object_Name__c = mapObjApiLabel.get(dsobjresRefTo.getName());
                        lstWrpOfflObj_RefObj.add(w);
                        }
                    }
                   }
                }
/*                 
                Map<String,Schema.SObjectField> objfieldMap2 = new Map<String,Schema.SObjectField>();
                if(dsobjresRefTo.getName() != 'User'){
                    objfieldMap2 = dsobjresRefTo.fields.getMap();
                    for (String fieldKey2 : objfieldMap2.keySet()) 
                    {
                        Schema.SObjectField fsObj2 = objfieldMap2.get(fieldKey2);
                        Schema.DescribeFieldResult f2 = fsObj2.getDescribe();
                        mapfldApiLabel.put(f.getLabel()+'.'+f2.getName() ,f.getRelationshipName()+'.'+f2.getName());
                        mapfieldType.put(f2.getName(),f2.getType().name());
                        lstFields.add(new SelectOption(f.getRelationshipName()+'.'+f2.getName() ,f.getLabel()+'.'+f2.getLabel()));
                        }
                        
                    }
*/                  
            }
            if(mapExstOfflViewObj.containsKey(f.getName()))
            {
                mapTempFldName.put(f.getName(),f.getLabel());
            }
            else
            { 
                if (!isEnterpriseLicense)
                 {
                     if(f.getType() == Schema.DisplayType.REFERENCE )
                     {
                         Schema.SObjectType sobjRefTo = f.getReferenceTo()[0];
                         if(sobjRefTo != null)
                         {
                         Schema.DescribeSObjectResult dsobjresRefTo = sobjRefTo.getDescribe();
                         if(AllowedObjects.contains(dsobjresRefTo.getName())||dsobjresRefTo.isCustom()||mapExcludedObject.containsKey(dsobjresRefTo.getName()))
                            {
                                lstFieldsOpt.add(new SelectOption(f.getName(),f.getLabel()));
                            }
                         }
                        
                         
                
                     }
                     else
                     {
                        lstFieldsOpt.add(new SelectOption(f.getName(),f.getLabel()));
                        
                     }
                        
                 }
                 else
                 {
                
                    lstFieldsOpt.add(new SelectOption(f.getName(),f.getLabel()));
                 }
            }
        }
        for(SVMXC__Offline_View__c o :lstOfflView)
        {
            if (mapTempFldName.get(o.SVMXC__Field_Name__c)<>null)
                lstSFieldsOpt.add(new SelectOption(o.SVMXC__Field_Name__c ,mapTempFldName.get(o.SVMXC__Field_Name__c)));
        }
        if(isChild)
        {
            lstWrpOfflObj_RefObj.clear();
            lstFieldsOpt.clear();
            lstSFieldsOpt.clear();
            lstFields.clear();
            //lstFields.add(new SelectOption(getTAG016(),getTAG016()));
            showPageError = false;
            apexpages.addmessage(new apexpages.message(ApexPages.severity.ERROR, getTAG050()));
        }
    }
    public boolean isRefObjExist(String strObjName)
    {
        for(wraperOfflObj_RefObj w :lstWrpOfflObj_RefObj )
        {
            if (w.objOfflObj.SVMXC__Object_Name__c == strObjName)
                return true;
        }
        return false;
    }
    public boolean isFieldObjExist (String strFieldName)
    {
        for (SVMXC__Offline_View__c o:lstOfflView)
        {
            if (o.SVMXC__Field_Name__c == strFieldName)
                return true;
        }
        return false;
    }
    
    public boolean isRelatedObjExist(String strObjName)
    {
        for(SVMXC__Offline_Object__c o :lstOfflObj_MstChdList )
        {
            if (o.SVMXC__Object_Name__c == strObjName)
                return true;
        }
        return false;
    }
    
    private void addSearchExpression()
    {
        SVMXC__Offline_Dataset_Expression__c objOffl_DSExp = new SVMXC__Offline_Dataset_Expression__c();
        objOffl_DSExp.SVMXC__Sequence__c = lstTempOffl_DSExp.size()+1;
        objOffl_DSExp.Name= '';
        objOffl_DSExp.SVMXC__Operator__c = '';
        objOffl_DSExp.SVMXC__Operand__c = '';
        lstTempOffl_DSExp.add(objOffl_DSExp);
    }
    private void removeSearchExpression()
    {
        lstTempOffl_DSExp.remove(lstTempOffl_DSExp.size()-1);
    }
    
    public class wraperOfflObj_RefObj
    {
        public wraperOfflObj_RefObj(){}
        public SVMXC__Offline_Object__c objOfflObj = new SVMXC__Offline_Object__c();
        public SVMXC__Offline_Object__c getobjOfflObj (){return objOfflObj;}
        public SVMXC__Offline_Object__c objObjlabel = new SVMXC__Offline_Object__c();
        public SVMXC__Offline_Object__c getobjObjlabel() {return objObjlabel;}
    }
    public List<SelectOption> getOperatorSelectList() {
        List<SelectOption> options = new List<SelectOption>();
        options.add(new selectOption(getTAG016(), getTAG016()));
        options.add(new selectOption('eq', System.Label.COMM002_TAG006));
        options.add(new selectOption('ne', System.Label.COMM002_TAG007));
        options.add(new selectOption('gt', System.Label.COMM002_TAG008));
        options.add(new selectOption('ge', System.Label.COMM002_TAG009));
        options.add(new selectOption('lt', System.Label.COMM002_TAG010));
        options.add(new selectOption('le', System.Label.COMM002_TAG011));
        options.add(new selectOption('starts', System.Label.COMM002_TAG012));
        options.add(new selectOption('contains',System.Label.COMM002_TAG013));
        options.add(new selectOption('notcontain', System.Label.COMM002_TAG014));
        options.add(new selectOption('in', System.Label.COMM002_TAG015));
        options.add(new selectOption('notin', System.Label.COMM002_TAG016));
        return options;
    }
    private String InputDateSep = '/';
    private String InputDateFormat = '';
    public String getInputDateFormat() 
    {
        return getInputDateFormat(2009,12,31);     
    }
    public String getInputDateFormat(integer intYY, integer intMM, integer intDD) 
    {
        String dtTest = date.newInstance(intYY, intMM, IntDD).format();
        InputDateSep = dtTest.subString(2,3); 
        if (dtTest.subString(0,2) == '12') 
            InputDateFormat = 'MM' + InputDateSep + 'DD' + InputDateSep + 'YYYY';
        if (dtTest.subString(0,2) == '31') 
            InputDateFormat = 'DD' + InputDateSep + 'MM' + InputDateSep + 'YYYY';
        if (dtTest.subString(0,2) == '20') 
            InputDateFormat = 'YYYY' + InputDateSep + 'MM' + InputDateSep + 'DD';
        return 'MM/DD/YYYY';     
    }
    public String buildWhereClause(boolean showDebugMessages, SVMXC__Offline_Dataset_Expression__c o, integer i) 
    {
        String SearchOperator =o.SVMXC__Operator__c;
        String SearchValue = o.SVMXC__Operand__c;
        String fldType = mapfieldType.get(o.Name);
        String searchField = o.Name;  
        boolean debugMode = showDebugMessages;
        String cWhereClause = '';
        if (searchField == null || searchField == '') 
        {
            return '';
        }            
        String[] arrssearchField = searchField.split(':');
        // Get the field type, field name, and query friendly search value
        String fldValue='';
        if (SearchValue <> null)
            fldValue = SearchValue.replace('\'', '\\\'').trim();
        // Start building the additional WHERE Clause
        cWhereClause += searchField;
        // ERROR CHECKING LOGIC
        if (fldType == 'BOOLEAN' && !(fldValue.toUpperCase() == 'TRUE' || fldValue.toUpperCase() == 'FALSE')) 
        {
            lstTempOffl_DSExp[i].addError(getTAG034() +':'+ mapfldApiName.get(searchField));
            isValidCri = false;
            showPageError = true;
            return '';
        }  
        if ((fldType == 'DATE' || fldType == 'DATETIME' || fldType == 'CURRENCY' || fldType == 'DOUBLE' || fldType == 'PHONE' || fldType == 'BOOLEAN') 
        && (SearchOperator == 'starts' || SearchOperator == 'contains' || SearchOperator == 'notcontain' || SearchOperator == 'in' || SearchOperator == 'notin')) 
        {
            lstTempOffl_DSExp[i].SVMXC__Operand__c.addError(getTAG032() + ':'+ mapfldApiName.get(searchField));
            isValidCri = false;
            showPageError = true;
            return '';
        }  

        // If this is a String/picklist type AND there is a comma in the search value
        // then assume that we'll use IN or NOT IN
        String cCloseCharacter = '';
        String cOperator = '';
        if (fldType == 'String' || fldType == 'EMAIL' || fldType == 'PICKLIST' || fldType == 'MULTIPICKLIST' || fldType == 'TEXTAREA') 
        {
            if (!fldValue.contains(',')) {
                // No comma, so just use =, <>
                if (SearchOperator == 'eq') cOperator = '=';
                if (SearchOperator == 'ne') cOperator = '<>';
            } else {
                // comma present and
                if (SearchOperator == 'eq' || SearchOperator == 'in') cOperator = ' IN (';
                if (SearchOperator == 'ne' || SearchOperator == 'notin') cOperator = ' NOT IN (';
                cCloseCharacter = ')';
            }
        } 
        else 
        {
            if (SearchOperator == 'eq') cOperator = '=';
            if (SearchOperator == 'ne') cOperator = '<>';
        }
        
        if (SearchOperator == 'gt') cOperator = '>';
        if (SearchOperator == 'lt') cOperator = '<';
        if (SearchOperator == 'ge') cOperator = '>=';
        if (SearchOperator == 'le') cOperator = '<=';
        
        if (fldType == 'String' || fldType == 'EMAIL' || fldType == 'PICKLIST' || fldType == 'MULTIPICKLIST' || fldType == 'TEXTAREA') {
            if (SearchOperator == 'starts') { cOperator = ' LIKE \''; cCloseCharacter = '%\''; }
            if (SearchOperator == 'contains') { cOperator = ' LIKE \'%'; cCloseCharacter = '%\''; }
            if (SearchOperator == 'notcontain') {
                // NOT LIKE requires parenthesis around the whole condition, including the fieldname 
                cWhereClause = ' (NOT(' + searchField ; 
                cOperator = ' LIKE \'%'; 
                cCloseCharacter = '%\'))'; 
            }
            if (SearchOperator == 'in' && fldType == 'MULTIPICKLIST') { cOperator = ' INCLUDES ('; cCloseCharacter = ')'; }
            if (SearchOperator == 'notin' && fldType == 'MULTIPICKLIST') { cOperator = ' EXCLUDES ('; cCloseCharacter = ')'; }
            if (SearchOperator == 'in' && fldType <> 'MULTIPICKLIST') { cOperator = ' IN ('; cCloseCharacter = ')'; }
            if (SearchOperator == 'notin' && fldType <> 'MULTIPICKLIST') { cOperator = ' NOT IN ('; cCloseCharacter = ')'; }
        }
        cWhereClause += cOperator;
        
        if (cOperator == '') {
            // ERROR
            lstTempOffl_DSExp[i].SVMXC__Operand__c.addError(getTAG032() +  ':'+ mapfldApiName.get(searchField));
            isValidCri = false;
            showPageError = true;
            return '';
        }
                
        if (fldType == 'String' || fldType == 'EMAIL' || fldType == 'PICKLIST' || fldType == 'MULTIPICKLIST' || fldType == 'TEXTAREA') {
        
            if (cCloseCharacter.startsWith('%')) {
                // Using LIKE ('Starts With' or 'Contains')
                cWhereClause += fldValue ;
            } else if (!fldValue.contains(',')) {
                // Standard single = value
                cWhereClause += '\'' + fldValue + '\'';
            } else {
                // Multiple Values (IN or NOT IN)
                String[] multValues = fldValue.split(',');
                for (String v : multValues) {
                    cWhereClause += '\'' + v.trim() + '\',';
                }
                cWhereClause = cWhereClause.subString(0, cWhereClause.length()-1);
            }
        } 
        else if (fldType == 'DATE' || fldType == 'DATETIME') {
            // For the various Date/Time constants (ex: LAST 60 DAYS) need an Underscore instead of space
            if (fldValue.toUpperCase().startsWith('NEXT') || fldValue.toUpperCase().startsWith('LAST')) 
            {
                // If this is NEXT xxx DAYS/MONTHS/YEARS etc., then need to reorder the criteria to
                // NEXT_N_DAYS:yyy
                String fldVal2 = fldValue.subString(5).trim().toUpperCase();
                if (fldVal2.contains(' ')) {
                    List<String> fldSplit = fldVal2.split(' ');
                    String fldNum = fldSplit[0].trim();
                    // If the 2nd word is one of these then no numbers, just a straight value
                    if (!(fldNum == 'WEEK' || fldNum == 'MONTH' || fldNum == 'QUARTER' || fldNum == 'YEAR' || fldNum == 'FISCAL')) {
                        String fldPeriod = '';
                        for (integer y = 1; y < fldSplit.size(); y++) {
                            fldPeriod += fldSplit[y].trim() + ' ';
                        }
                        fldPeriod = fldPeriod.trim();
                        fldValue = fldValue.subString(0,4).trim().toUpperCase() + '_N_' + fldPeriod + ':' + fldNum;
                    }
                } 
            } 
            else if (fldValue.toUpperCase().startsWith('TODAY') || fldValue.toUpperCase().startsWith('YESTERDAY')
                || fldValue.toUpperCase().startsWith('TOMORROW') || fldValue.toUpperCase().startsWith('THIS')) 
            {
                // No issues here
            }
            else 
            {
                try {
                    date testDate = StringToDate(fldValue);
                    // Rebuild the date String as YYYY-MM-DD
                    String m = testDate.month().format();
                    String d = testDate.day().format();
                    if (integer.valueOf(m) < 10) m = '0' + m;
                    if (integer.valueOf(d) < 10) d = '0' + d;
                    fldValue = testDate.year() + '-' + m + '-' + d;
                    
                    // For DATETIME types, must add the hours AND we need to make it a compound condition
                    //     (field >= START AND field <= END)
                    // Example: field = 12/31/2008 will be translated to
                    //      field >= 2008-12-31T00:00:00Z AND field <= 2008-12-31T23:59:59Z 
                    if (fldType == 'DATETIME') {
                        // This creates a DateTime at midnight in the users current timezone 
                        datetime testDateTm = datetime.newInstance(testDate.year(), testDate.month(),testDate.day());
                        
                        // If the operator is equals/not equals then need a range for the entire day
                        // if the operator is greater or less, then we can just use the datetime
                        // but we'll need to adjust based on midnight or 23:59:59pm
                        if (cOperator == '=') 
                        {
                            cWhereClause = ' (' + searchField + ' >= ';                         
                            fldValue = testDateTm.format('yyyy-MM-dd') + 'T00:00:00Z';                          
                            cWhereClause += fldValue + ' AND ' + searchField + ' <= ' ;
                            fldValue = testDateTm.format('yyyy-MM-dd') + 'T23:59:59Z';
                            cCloseCharacter = ')';                          
                        } else if (cOperator == '<>') {
                            cWhereClause = ' (' + searchField + ' < ';                          
                            fldValue = testDateTm.format('yyyy-MM-dd') + 'T00:00:00Z';                          
                            cWhereClause += fldValue + ' OR ' + searchField + ' > ' ;
                            fldValue = testDateTm.format('yyyy-MM-dd') + 'T23:59:59Z';                          
                            cCloseCharacter = ')';                          
                        } else if (cOperator == '<') {
                            fldValue = testDateTm.format('yyyy-MM-dd') + 'T00:00:00Z';                          
                        } else if (cOperator == '<=') {
                            fldValue = testDateTm.format('yyyy-MM-dd') + 'T23:59:59Z';
                        } else if (cOperator == '>') {
                            fldValue = testDateTm.format('yyyy-MM-dd') + 'T23:59:59Z';
                        } else if (cOperator == '>=') {
                            fldValue = testDateTm.format('yyyy-MM-dd') + 'T00:00:00Z';                          
                        }
                    }
                } catch (exception ex) 
                {
                    lstTempOffl_DSExp[i].SVMXC__Operand__c.addError( getTAG031()+ ':'+ mapfldApiName.get(searchField) +': ' + ex.getMessage());
                    isValidCri = false;
                    showPageError = true;
                    return '';
                }
            }    
            cWhereClause += fldValue.replace(' ', '_').toUpperCase();
        } else if (fldType == 'CURRENCY' || fldType == 'DOUBLE' || fldType == 'BOOLEAN') {
            cWhereClause += fldValue ;
        } else { 
            cWhereClause += '\'' + fldValue + '\''; 
        }
        cWhereClause += cCloseCharacter ;
        if (cWhereClause <> null) { isValidCri = true; showPageError = false; return cWhereClause; } else { return ''; }
    }
    
    // Convert a Date String to a Date type using the IntputDateFormat value
    // to determine how the date format is constructed
    public Date StringToDate(String s)
    {
        // Due to regular expressions, split('.') does not work so replace all separators with a /
        // to force the process to work.
        s = s.replace('.', '/').replace('-', '/').replace('\\', '/');
                    
        String[] StringDate = s.split('/');
        getInputDateFormat() ;
                    
        Integer m = 0;
        Integer d = 0;
        Integer y = 0;
        if (InputDateFormat.subString(0,2) == 'MM') 
        {
            m = Integer.valueOf(StringDate[0]);
            d = Integer.valueOf(StringDate[1]);
            y = Integer.valueOf(StringDate[2]);
        }
        if (InputDateFormat.subString(0,2) == 'DD') 
        { 
            d = Integer.valueOf(StringDate[0]);
            m = Integer.valueOf(StringDate[1]);
            y = Integer.valueOf(StringDate[2]);
        }
        if (InputDateFormat.subString(0,2) == 'YY') 
        { 
            y = Integer.valueOf(StringDate[0]);
            m = Integer.valueOf(StringDate[1]);
            d = Integer.valueOf(StringDate[2]);
        }
        
        if (y < 100 && y > 80) y += 1900;
        if (y < 100) y += 2000;
        return date.newInstance(y,m,d); 
    }
}