public with sharing class WORD_ManageSkillMatchingRules
{    
    /** Start - NPS Related code **/
    public string getUserLocaleKey(){
        return UserInfo.getLanguage();
    }
    public string getUserID(){
        return UserInfo.getUserId().substring(0, 15);
    }
    public string getUserOrgID(){
        return UserInfo.getOrganizationId().substring(0, 15);
    }
    /** End - NPS Related code **/
    
    //CRUD security related functions
    public static COMM_SecurityUtils securityUtils = COMM_SecurityUtils.getInstance();
            
    
    //--------------------------------- Variables and Getter-Setter Methods -----------------------------------
    public string strProcessName{get;set;}
    public string strDescription{get;set;}
    public boolean isActive{get;set;} 
    public List<SVMXC__ServiceMax_Processes__c> lstSkillMatchRules = new List<SVMXC__ServiceMax_Processes__c>();    
    public List<SVMXC__ServiceMax_Processes__c> getlstSkillMatchRules(){return this.lstSkillMatchRules;}
    public List<selectoption> lstAvailableSkill = new List<selectoption>();    
    public List<selectoption> getlstAvailableSkill(){return this.lstAvailableSkill;}
    public SVMXC__ServiceMax_Processes__c objSkillMatch = new SVMXC__ServiceMax_Processes__c();
    public SVMXC__ServiceMax_Processes__c getobjSkillMatch(){return this.objSkillMatch;}
    public void setobjSkillMatch(SVMXC__ServiceMax_Processes__c proces){this.objSkillMatch = proces;} 
    public List<selectoption> lstWOfield = new List<selectoption>();
    public List<selectoption> getlstWOfield() {return this.lstWOfield;}
    public List<SelectOption> lstOperatorSelectLst = new List<SelectOption>();
    public List<SelectOption> getlstOperatorSelectLst(){return lstOperatorSelectLst;}
    public List<SelectOption> lstSkillCategory = new List<SelectOption>();
    public List<SelectOption> getlstSkillCategory(){return this.lstSkillCategory;} 
    public string strSelSkillCategory{get;set;}    
    public string[] strSelSkill = new List<String>();
    public boolean isrenderExprs{get;set;}  
    public string[] getstrSelSkill()
    {
        return strSelSkill;
    }    
    public void setstrSelSkill(string[] o)
    {
        this.strSelSkill = o;
    }
    public string  strParentNode{get;set;}
    public List<SVMXC__Skill__c > lstSkill = new List<SVMXC__Skill__c >();  
    public List<sobject > lstSkilltagSobj = new List<sobject>();
    public string StrDelIndex {get; set;}
    public string strAdvanceExp{get;set;}
    public boolean isnewSkillMatchRule{get;set;}  
    public boolean isRenderNew{get;set;}
    public boolean isRenderEdit{get;set;}
    public boolean isRenderSave{get;set;}
    public boolean isRenderDelete{get;set;}
    public boolean isRendercancel{get;set;} 
    public boolean isRenderParent{get;set;}
    public boolean isRenderTagSearch{get;set;}  
    public boolean isNewOrEdit{get;set;} 
    public boolean getisNewOrEdit(){return isNewOrEdit;}
    public void setisNewOrEdit(boolean val){this.isNewOrEdit = val;}
    public boolean IsValidProcess = true; 
    public List<SVMXC__ServiceMax_Config_Data__c> lstSkillMatchConfig = new List<SVMXC__ServiceMax_Config_Data__c>();
    public List<SVMXC__ServiceMax_Config_Data__c> getlstSkillMatchConfig(){return lstSkillMatchConfig;}   
    public void setlstSkillMatchConfig(List<SVMXC__ServiceMax_Config_Data__c> ConfigObj){lstSkillMatchConfig = ConfigObj;} 
    public List<SVMXC__ServiceMax_Config_Data__c> lstSkillMatchConfigDel = new List<SVMXC__ServiceMax_Config_Data__c>();   
    public List<SVMXC__ServiceMax_Config_Data__c> lstApplicableSkillsConfig = new List<SVMXC__ServiceMax_Config_Data__c>();
    public List<SVMXC__ServiceMax_Config_Data__c> getlstApplicableSkillsConfig(){return lstApplicableSkillsConfig;}   
    public void setlstApplicableSkillsConfig(List<SVMXC__ServiceMax_Config_Data__c> ConfigObj){lstApplicableSkillsConfig = ConfigObj;}
    public List<SVMXC__ServiceMax_Config_Data__c> lstSkillAppDel = new List<SVMXC__ServiceMax_Config_Data__c>();
    map<String,string > mapSkillidtoSkillRec = new map<String,string >();
    public integer getlstSkillMatchConfigSize(){return lstSkillMatchConfig.size();}
    public Integer intDetailSize = 0;
    public integer intExpDetailSize {get;set;}
    public boolean isRenderExp{get;set;}
    public boolean isCategoryandTagSearched;
    public string delIndex{get;set;}
    public string strSelectedExp{get;set;}    
    public SVMXC.COMM_SVMXC_Search_Expressions HdrExpressions = new SVMXC.COMM_SVMXC_Search_Expressions(2); 
    public boolean isrenderExpres{get;set;}
    public SVMXC__ServiceMax_Processes__c objSkillMatchEdit = new SVMXC__ServiceMax_Processes__c();   
    public string ExpHdr_Rtype_Id;
    public string ExpDtl_Rtype_Id; 
    public string ExpDtl_AppSkill_Id; 
    public List<ConfigExpWrapper> LstCriWrap = new List<ConfigExpWrapper>();
    public List<ConfigExpWrapper> getLstCriWrap(){ return this.LstCriWrap;}
    public void setLstCriWrap(List<ConfigExpWrapper> value){ this.LstCriWrap = value; }
    public integer getLstCriWrapSize(){return LstCriWrap.size();}
    public list<string> lstappSkill = new list<string>();
    map<String,SelectOption> mapSkill = new  map<String,SelectOption>();
    set<String> setAvailableSkill = new  set<String>();
    set<String> setApplicableSkill = new set<String>();
    public set<Id> setAvailSkillId = new set<Id>();    
    public set<Id> setParentsskillid = new set<Id>();   
    public Map<Id, Id> mapChildstoParrent =  new Map<Id, Id> {};
    public Map<Id , set<Id>> mapParrenttoChild = new Map<Id , set<Id>>(); 
    public map<integer, id> mapSeqtoParrentId = new map<integer, id>();
    public map<id, SVMXC__ServiceMax_Processes__c> mapAvailableSkillidtoRec = new map<id, SVMXC__ServiceMax_Processes__c>();
    Integer availCount = 0;
    public String XMLResult='';
    public string getXMLResult(){return XMLResult;}
    public SVMXC.SFM_WrapperDef.SFM_Response Save_Response = new SVMXC.SFM_WrapperDef.SFM_Response();   
    public  SVMXC.SFM_validateExpression ValidateExp = new SVMXC.SFM_validateExpression();
    public String strSkillid='';
    public String getstrSkillid(){return strSkillid;}
    public void setstrSkillid(String id){this.strSkillid=id; }    
    public string strConfirmationMsg;   
    public String getstrConfirmationMsg()
    {   
        return strConfirmationMsg;
    }
     public void setstrConfirmationMsg(String msgval){this.strConfirmationMsg = msgval; }
    public string StrSkillTagToMatch{get;set;} 
    public boolean displaySeqPopup = false;
    public boolean getdisplaySeqPopup(){ return displaySeqPopup; } 
    public boolean isRenderRuleSeq = false;  
    public boolean getisRenderRuleSeq(){ return isRenderRuleSeq; }
    public void setisRenderRuleSeq(boolean b){ this.isRenderRuleSeq = b; }
    public List<SelectOption> Seqoptions = new List<SelectOption>();  
    public string[] strSkillidRearrange = new String[]{};
    public integer selIndex = 0;
    
    public boolean IsValidExp = false;
    public boolean IsValidinfo = false;
    public list <SVMXC__ServiceMax_Processes__c> lstParentSkillMatchRules = new list <SVMXC__ServiceMax_Processes__c>();
    public set<String> setCriWrapIDtoRemove = new  set<String>();
    public SVMXC__Skill__c objSkill = new SVMXC__Skill__c ();  
    public SVMXC__Skill__c getobjSkill(){return this.objSkill;}
    public void setobjSkill(SVMXC__Skill__c proces){this.objSkill = proces;} 
    
    //----------------------------------------- Constructor -------------------------------------------
    public WORD_ManageSkillMatchingRules()
    {  
        retrieveRecordTypes();
        preparingPicklists();
        retrieveSkillMatchingRules();
        setDefaultValues();        
        buildSkillMatchingRulesTree(); 
    }
    //-------------------------------------------- Method to retrive all existing Skill Matching Rules --------------
    public void retrieveSkillMatchingRules()
    {
        lstSkillMatchRules.clear();
        lstSkillMatchRules = [select id, SVMXC__Name__c,SVMXC__Sequence__c,  SVMXC__Description__c, SVMXC__Active__c,SVMXC__Select__c , SVMXC__Parent_Object_Criteria__c, SVMXC__Source_Object_Name__c, SVMXC__Node_Parent__c,SVMXC__Advance_Expression__c from SVMXC__ServiceMax_Processes__c where  RecordTypeId =: ExpHdr_Rtype_Id And SVMXC__Rule_Type__c = 'Skill Matching'];  //SDL-SVMX-FLS-NOT-ENFORCED-META-DATA
        
    }
    //------------------------------------------- Method to populate picklists ------------------------------
    public void preparingPicklists()
    {
        map<string, boolean> lstStdObjAccToLicense = new map<string, boolean>();
        COMM_Utils comUtil = new COMM_Utils();
        lstStdObjAccToLicense = comUtil.SVMX_getPermittedStandardObjectList();
        
        lstWOfield.clear();
        lstWOfield.add(new SelectOption(getTAG038(),getTAG038()));
        Map<String,Schema.SObjectField> objfieldMap = new Map<String,Schema.SObjectField>();
        objfieldMap = SVMXC__Service_order__c.SObjectType.getDescribe().fields.getMap();                        
        for (String fieldKey : objfieldMap.keySet()) 
        {
            Schema.SObjectField fsObj = objfieldMap.get(fieldKey);
            Schema.DescribeFieldResult f = fsObj.getDescribe();
            if(f.isFilterable() && f.getType().name() != 'MULTIPICKLIST'){
                if(f.getType() == Schema.DisplayType.Reference)
                {
                    if(!comUtil.SVMX_isObjectCustom(String.valueof(f.getReferenceTo()[0])))
                    {
                        if(!lstStdObjAccToLicense.containsKey(String.valueof(f.getReferenceTo()[0])))
                        {
                            continue;
                        }
                    }
                }
                lstWOfield.add(new SelectOption(f.getName(),f.getLabel())); 
            }     
        }     
        objfieldMap.clear();            
                
        lstWOfield = sortingSelectOption(lstWOfield);
        
        lstOperatorSelectLst.clear();
        lstOperatorSelectLst.add(new SelectOption('SVMX.NONE', getTAG038()));
        lstOperatorSelectLst.add(new SelectOption('eq', getTAG020()));
        lstOperatorSelectLst.add(new SelectOption('ne', getTAG021()));
        lstOperatorSelectLst.add(new SelectOption('gt', getTAG022()));
        lstOperatorSelectLst.add(new SelectOption('ge', getTAG023()));
        lstOperatorSelectLst.add(new SelectOption('lt', getTAG024()));
        lstOperatorSelectLst.add(new SelectOption('le', getTAG025()));
        lstOperatorSelectLst.add(new SelectOption('starts', getTAG026()));
        lstOperatorSelectLst.add(new SelectOption('contains', getTAG027()));
        lstOperatorSelectLst.add(new SelectOption('notcontain', getTAG028()));
        lstOperatorSelectLst.add(new SelectOption('in', getTAG029()));
        lstOperatorSelectLst.add(new SelectOption('notin', getTAG030()));
        lstOperatorSelectLst.add(new SelectOption('isnull', getTAG031()));
        lstOperatorSelectLst.add(new SelectOption('isnotnull', getTAG032()));
       
        lstSkillCategory.add(new SelectOption(getTAG038(), getTAG038()));
        Schema.DescribeFieldResult F = SVMXC__Skill__c.SVMXC__Skill_Category__c.getDescribe();
        List<Schema.PicklistEntry> pick = F.getPicklistValues();
        for(Schema.PicklistEntry pv : pick)
            lstSkillCategory.add(new SelectOption(pv.getValue(),pv.getLabel()));            
            
    }
    //------------------------------------- Method to sort the Options of the PickList -------------------------------------
    public List<SelectOption> sortingSelectOption(List<SelectOption> sortList)
    {
        List<SelectOption> resultList = new List<SelectOption>();
        Map<String,List<SelectOption>> tempLst = new Map<String,List<SelectOption>>();
        for(SelectOption SO:sortList)
        {
            tempLst.put(SO.getLabel(), new List<SelectOption>()); 
            tempLst.get(SO.getLabel()).add(SO);
        }
        List<String> keys = new List<String>(tempLst.keySet());
        keys.sort();
        for(String key:keys)
           resultList.addAll(tempLst.get(key)); 
        
        return resultList;
    }
    //------------------------------------ Visibility controlof Tag search on VF page --------------------------
    public void isRenderTagSearch()
    {
        MAP<String,Schema.SObjectType> allObjs = Schema.getGlobalDescribe();
        if(allObjs.containskey('Skill__Tag') && allObjs.get('Skill__Tag').getDescribe().isAccessible())
            isRenderTagSearch = true;
        else 
            isRenderTagSearch = false;
        
    }
    
    
  //-------------------------------- Method to set Default Values for Variables ----------------------------
    public void setDefaultValues()
    {   
       
        isRenderExp=false;
        isRenderNew =true;
        isRenderEdit=true;
        isRenderSave=false;
        isRenderDelete=true;
        isRendercancel=false;
        displaySeqPopup = false;
        strProcessName = null;
        strDescription = null;
        strSelSkillCategory = null;
        isactive = true;
        strAdvanceExp = null  ;
        strSkillid = null;
        isNewOrEdit = false;
        isrenderExprs = false;
        IsValidinfo = false;
        isCategoryandTagSearched = false;
        lstSkillMatchConfig.clear();
        lstApplicableSkillsConfig.clear();
        LstCriWrap.clear();
        lstSkillAppDel.clear();
        setCriWrapIDtoRemove.clear();
        if(lstSkillMatchRules != null && lstSkillMatchRules.size()==0)
        {
            isRenderDelete = false;
            isRenderRuleSeq = false;
        }
        
    }
    // ----------------------------------------- Building data for Tree grid --------------------------------------
 
    public void buildSkillMatchingRulesTree()
    {
        retrieveSkillMatchingRules();
        mapAvailableSkillidtoRec.clear();
        XMLResult='<?xml version="1.0" encoding="UTF-8"?><rows>'; 
        for(SVMXC__ServiceMax_Processes__c SkillObj1: lstSkillMatchRules)
        {
            setAvailSkillId.add(SkillObj1.id);
            mapAvailableSkillidtoRec.put(SkillObj1.id,SkillObj1);
            if(SkillObj1.SVMXC__Node_Parent__c == null)
            {
                setParentsskillid.add(SkillObj1.id);
                mapSeqtoParrentId.put(integer.valueof(SkillObj1.SVMXC__Sequence__c),SkillObj1.id);
            }
            if(SkillObj1.SVMXC__Node_Parent__c != null)             
                mapChildstoParrent.put(SkillObj1.id,SkillObj1.SVMXC__Node_Parent__c);
            addTomapParrenttoChild(SkillObj1.SVMXC__Node_Parent__c, SkillObj1.id);            
        }        
        for(integer i = 0;i< mapSeqtoParrentId.size();i++)
        {
            AvailCount++;
            if(mapSeqtoParrentId.containskey(i))
                buildTree(mapSeqtoParrentId.get(i));
        }
        if(mapSeqtoParrentId != null && mapSeqtoParrentId.size() > 1)
            isRenderRuleSeq = true;
        XMLResult=XMLResult+'</rows>';
            System.debug('xml val: '+XMLResult);
    }
    //--------------------------------------Populating Parrent to child map -------------------------------
    public void addTomapParrenttoChild(Id PID, Id CID )
    {
        if(mapParrenttoChild.containsKey(PID))
            mapParrenttoChild.get(PID).add(CID);
        else
        { 
            set<Id> lst = new set<Id>();
            lst.add(CID);
            mapParrenttoChild.put(PID, lst);
        }
    }                                       

    // -----------------------------------------Constructing XML string for Tree Grid -------------------------------
    public void buildTree(String parentId)
    {
        set<id> childIDs= new set<id>();        
        //Removing Parrent Id from Available List
        setAvailSkillId.remove(parentId);
        if(mapAvailableSkillidtoRec.containskey(parentId))      
            XMLResult=XMLResult+'<row id="'+parentId+'" open="1"><cell>0</cell><cell image="../images/icons/award_star_gold_3.png">'+SpecialCharParser(mapAvailableSkillidtoRec.get(parentId).SVMXC__Name__c)+'</cell><cell>'+CheckNull(SpecialCharParser(mapAvailableSkillidtoRec.get(parentId).SVMXC__Description__c))+'</cell>';
            if(mapParrenttoChild.containskey(ParentId))
                childIDs=mapParrenttoChild.get(ParentId);
    
        if(childIDs!=NULL)
        {
            for(id childid: childIDs)
            {
                buildTree(childid);
                AvailCount++;
            }
        }
        XMLResult=XMLResult+'</row>'; 
    }
    //---------------------------------------- Parser for Special Characters -----------------------------------
    public String SpecialCharParser(String s)
    {
        if(s!=NULL)
        {
            s = s.replace('&', '&amp;');
            s = s.replace('<', '&lt;');
            s = s.replace('<','&#60;');
            s = s.replace('/"', '&quot;');
            s = s.replace('&','&#38;');
            s = s.replace('\'','&#39;');
            s = s.replace('<','&#60;');
            s = s.replace('>','&#62;');
            s = s.replace('\n',' ');
            return s;
        }
        return NULL;
    }
    //------------------------------------------- Method to handle null string -----------------------------
    public String CheckNull(String s)
    {
        if(s==NULL)
        return '';
        else
        return s;
    }

    //------------------------------------------- Method to create new Skill Matching Rules ----------------------
    public void newSkillMatchRule()
    {
        isRenderExp = true;
        isRenderNew =false;
        isRenderEdit=false;
        isRenderSave=true;
        isRenderDelete=false;
        isRendercancel=true;
        isactive =true;     
        isnewSkillMatchRule=true;
        isNewOrEdit = true;
        strAdvanceExp = null  ;
        isRenderTagSearch();
        lstSkillMatchConfig.clear();
        lstApplicableSkillsConfig.clear();
        setApplicableSkill.clear();
        setAvailableSkill.clear();
        lstAvailableSkill.clear();
        LstCriWrap.clear();
        lstSkillAppDel.clear();
        setCriWrapIDtoRemove.clear();
        lstSkillMatchConfigDel.clear();
        strProcessName = null;
        strDescription = null;
        StrSkillTagToMatch = null;
        strSelSkillCategory = null;
        strParentNode = null;
        HdrADDRow();
        HdrADDRow();
        buildSkillMatchingRulesTree();
        if(strSkillid != null && strSkillid != '')
        {

            if(mapChildstoParrent.containskey(strSkillid) && mapAvailableSkillidtoRec.containskey(strSkillid))   
            {
                strParentNode   = mapAvailableSkillidtoRec.get(mapAvailableSkillidtoRec.get(strSkillid).SVMXC__Node_Parent__c).SVMXC__Name__c; 
                isRenderParent = true;
            }          
            else if (mapAvailableSkillidtoRec.containskey(strSkillid))
            {
                strParentNode   = mapAvailableSkillidtoRec.get(strSkillid).SVMXC__Name__c;
                isRenderParent = true;
            }
        }       
        else
            isRenderParent = false;
    }
    //------------------------------------------- Method to Edit Skill Matching Rules ----------------------
    public  void editSkillMatchRule()
    {
        retrieveRecordTypes();
        isRenderExp = true;
        isRenderNew =false;
        isRenderEdit=false;
        isRenderSave=true;
        //isRenderDelete=false;
        isRendercancel=true;
        isNewOrEdit = true;
        isnewSkillMatchRule=false;
        StrSkillTagToMatch = null;
        isRenderTagSearch();
        lstSkillAppDel.clear();
        setCriWrapIDtoRemove.clear();
        setAvailableSkill.clear();
        lstAvailableSkill.clear();
        LstCriWrap.clear();  
        lstSkillMatchConfigDel.clear();
        objSkillMatchEdit = new SVMXC__ServiceMax_Processes__c();
       
            if(strSkillid != null && strSkillid != '') 
            {   

                if(mapChildstoParrent.containskey(strSkillid) && mapAvailableSkillidtoRec.containskey(strSkillid))   
                {
                    strParentNode   = mapAvailableSkillidtoRec.get(mapAvailableSkillidtoRec.get(strSkillid).SVMXC__Node_Parent__c).SVMXC__Name__c; 
                    isRenderParent = true;
                    strConfirmationMsg = getTAG057();   
                    setstrConfirmationMsg(getTAG057());                 
                    getstrConfirmationMsg();                 
                }
               
                else if(mapAvailableSkillidtoRec.containskey(strSkillid))
                {
                    strParentNode   = mapAvailableSkillidtoRec.get(strSkillid).SVMXC__Name__c;
                    isRenderParent = false;
                    strConfirmationMsg = getTAG064();
                    setstrConfirmationMsg(getTAG064());                 
                    getstrConfirmationMsg(); 
                }
        
                if(mapAvailableSkillidtoRec.containskey(strSkillid))
                {
                    objSkillMatchEdit = mapAvailableSkillidtoRec.get(strSkillid);
                
                strProcessName = objSkillMatchEdit.SVMXC__Name__c;
                strDescription = objSkillMatchEdit.SVMXC__Description__c;
                strAdvanceExp = objSkillMatchEdit.SVMXC__Advance_Expression__c;
            
                lstSkillMatchConfig.clear();
                lstSkillMatchConfig = [Select Id,SVMXC__Sequence__c,SVMXC__Field_Name__c,SVMXC__Operator__c,SVMXC__Operand__c,SVMXC__Object_Name__c,SVMXC__FKey_Name_Field__c,SVMXC__Lookup_Field_API_Name__c,SVMXC__Expression_Type__c,SVMXC__Expression_Rule__c, RecordTypeId From SVMXC__ServiceMax_Config_Data__c where SVMXC__Expression_Rule__c =: objSkillMatchEdit.id and SVMXC__Expression_Type__c = 'Skill_Eligibility' order by SVMXC__Sequence__c]; //SDL-SVMX-FLS-NOT-ENFORCED-META-DATA
                lstApplicableSkillsConfig.clear();
                lstApplicableSkillsConfig = [Select Id,SVMXC__Sequence__c,SVMXC__Skill__c, SVMXC__Skill__r.name,SVMXC__Minimum_Level__c,SVMXC__Required__c From SVMXC__ServiceMax_Config_Data__c where RecordTypeId =: ExpDtl_AppSkill_Id And SVMXC__Expression_Rule__c =: objSkillMatchEdit.id  order by SVMXC__Sequence__c];  //SDL-SVMX-FLS-NOT-ENFORCED-META-DATA
                }
            }
                
            else
                isRenderParent = false;
            LstCriWrap.clear();          
            setApplicableSkill.clear();
            for(SVMXC__ServiceMax_Config_Data__c confAppSkil :lstApplicableSkillsConfig)
            {
                ConfigExpWrapper WrapObj = new ConfigExpWrapper();
                WrapObj.objConf = confAppSkil;
                WrapObj.strselSkillName = confAppSkil.SVMXC__Skill__r.name;                
                setApplicableSkill.add(confAppSkil.SVMXC__Skill__c);
                LstCriWrap.add(WrapObj);
                
            }
    }
    //------------------------------------------- Method to Delete Skill Matching Rules ----------------------
    public PageReference deleteSkillMatchRule()
    {      
        list<SVMXC__ServiceMax_Processes__c> lstSkillMatchDel = new list<SVMXC__ServiceMax_Processes__c>();
        list<SVMXC__ServiceMax_Config_Data__c> lstconfig = new list<SVMXC__ServiceMax_Config_Data__c>();        
        List<id> lstIdtoDel = new List<id>();
          
        if(strSkillid != null && strSkillid != '')
        {
            lstIdtoDel.add(strSkillid);
            if(mapAvailableSkillidtoRec.containskey(strSkillid))
            {
                 if(mapParrenttoChild.containskey(strSkillid) && mapParrenttoChild.get(strSkillid) != null)
                {
                    lstSkillMatchDel.add(mapAvailableSkillidtoRec.get(strSkillid)); 
                    for(id childId : mapParrenttoChild.get(strSkillid))
                    {
                        if(childId != null)
                        {
                            lstSkillMatchDel.add(mapAvailableSkillidtoRec.get(childId));                        
                            lstIdtoDel.add(childId);
                        }
                    }
                    
                }
                else
                {
                    lstSkillMatchDel.add(mapAvailableSkillidtoRec.get(strSkillid)); 
                    
                }
            }
            Set<Id> setidDel = new Set<Id>();
            if(!lstIdtoDel.isempty())
                setidDel.addall(lstIdtoDel);
            if(setidDel.contains(null))
                setidDel.remove(null);
            if(setidDel != null && setidDel.size() > 0)
                lstconfig = [Select Id,Field_Name__c,SVMXC__Skill__r.name From SVMXC__ServiceMax_Config_Data__c where SVMXC__Expression_Rule__c IN :setidDel  and (RecordTypeId =: ExpDtl_AppSkill_Id or RecordTypeId =: ExpDtl_Rtype_Id)]; //SDL-SVMX-FLS-NOT-ENFORCED-META-DATA
            SVMXC__ServiceMax_Processes__c skillobj = new SVMXC__ServiceMax_Processes__c();
            list<SVMXC__ServiceMax_Processes__c> lstskillobj = new list<SVMXC__ServiceMax_Processes__c>();
            System.debug('mapParrenttoChild.containskey(strSkillid): '+mapParrenttoChild.containskey(strSkillid));
            System.debug('mapAvailableSkillidtoRec.get(strSkillid): '+mapAvailableSkillidtoRec.get(strSkillid));
            if(mapAvailableSkillidtoRec.containskey(strSkillid) && mapAvailableSkillidtoRec.get(strSkillid).SVMXC__Node_Parent__c == null)
            {
                    
                integer seqno;
                seqno = integer.valueof(mapAvailableSkillidtoRec.get(strSkillid).SVMXC__Sequence__c);
                //else
                    //seqno = integer.valueof(mapAvailableSkillidtoRec.get(mapChildstoParrent.get(strSkillid)).SVMXC__Sequence__c);
            
                for(integer i=seqno+1;i<= mapSeqtoParrentId.size();i++ )
                {
                        System.debug('mapAvailableSkillidtoRec.containskey(mapSeqtoParrentId.get(i)): '+mapAvailableSkillidtoRec.containskey(mapSeqtoParrentId.get(i)));
                    if(mapSeqtoParrentId.containskey(i) && mapAvailableSkillidtoRec.containskey(mapSeqtoParrentId.get(i)))
                    {                   
                        skillobj = mapAvailableSkillidtoRec.get(mapSeqtoParrentId.get(i));
                        skillobj.SVMXC__Sequence__c = skillobj.SVMXC__Sequence__c-1;                    
                        lstskillobj.add(skillobj);
                    }
                }
            
            }
            System.debug('lstskillobj: '+lstskillobj);
            System.debug('lstSkillMatchDel: '+lstSkillMatchDel);
            System.debug('strSkillid: '+strSkillid);
            if(!lstskillobj.isempty())
                upsert lstskillobj;     //SDL-SVMX-FLS-NOT-ENFORCED-META-DATA
        }           
        if(lstconfig.isEmpty() != true)
            delete lstconfig;    //SDL-SVMX-FLS-NOT-ENFORCED-META-DATA    
        if(lstSkillMatchDel.isEmpty() != true)          
            delete lstSkillMatchDel;    //SDL-SVMX-FLS-NOT-ENFORCED-META-DATA
        setDefaultValues();
        buildSkillMatchingRulesTree();
        String url = '/apex/SVMXC__WORD_ManageSkillMatchingRules';      
        PageReference SkillMatchRulesPage = new PageReference(url);
        SkillMatchRulesPage.setRedirect(true);
        return SkillMatchRulesPage; 
    }
   //------------------------------------------- Method to Search Skill based on Tags ----------------------
    public void searchSkillonCategoryandTag()
    {
        isCategoryandTagSearched = true;
        string strQueryString ='';
        string strkillCatg ='';
        lstSkill.clear();  
        strkillCatg=strSelSkillCategory;
        if(strSelSkillCategory == getTAG038() && (StrSkillTagToMatch == null || StrSkillTagToMatch == ''))
            lstSkill = [SELECT Id,Name FROM SVMXC__Skill__c where name != null and SVMXC__Active__c = true];
        if(strSelSkillCategory != getTAG038() && (StrSkillTagToMatch == null || StrSkillTagToMatch == ''))
             lstSkill = [SELECT Id,Name FROM SVMXC__Skill__c WHERE SVMXC__Skill_Category__c =:strSelSkillCategory and SVMXC__Active__c = true];     
        string strTagSearch='';
        string strTagSearch1='';
       // 
        lstappSkill.clear();
        lstAvailableSkill.clear();
        mapSkillidtoSkillRec.clear();
        mapSkill.clear();
        setAvailableSkill.clear();        
        if(StrSkillTagToMatch != null && StrSkillTagToMatch != '')
        {
            String strSkillTag = String.escapeSingleQuotes(StrSkillTagToMatch);           
            boolean isfirststr =true;  
            set<string> setTag = new set<string>();
            for(String strtag : strSkillTag.split(','))
            {
                setTag.add('%'+strtag+'%');
            }
            
            if(strSelSkillCategory == getTAG038() && (StrSkillTagToMatch != null && StrSkillTagToMatch != ''))
                strQueryString = 'SELECT ItemId,Item.name FROM SVMXC__Skill__Tag where name like : setTag ';
             
            if(strSelSkillCategory != getTAG038() && (StrSkillTagToMatch != null && StrSkillTagToMatch != ''))
                strQueryString = 'SELECT ItemId,Item.name FROM SVMXC__Skill__Tag where name like : setTag  and Item.SVMXC__Skill_Category__c =:strSelSkillCategory';   
            lstSkilltagSobj = Database.query(strQueryString);
           
            for(Sobject sobj :lstSkilltagSobj)   
            {           
                String skillName = String.valueOf(sobj.getSObject('Item').get('Name'));
                String skillId = String.valueOf(sobj.getSObject('Item').get('Id'));
               
                mapSkillidtoSkillRec.put(skillId, skillName);
                mapSkill.put(skillId,new SelectOption(skillId, skillName));
                if((!setApplicableSkill.contains(skillId)) && (!setAvailableSkill.contains(skillId)))
                {
                    lstAvailableSkill.add(new SelectOption(skillId, skillName));
                    
                    setAvailableSkill.add(skillId);
                }
                
            } 
        }
        else
        {
           
            for(SVMXC__Skill__c  skillobj: lstSkill)
            {
                mapSkillidtoSkillRec.put(skillobj.id, skillobj.name);
                mapSkill.put(skillobj.id,new SelectOption(skillobj.id, skillobj.name));
                if((!setApplicableSkill.contains(skillobj.id)) && (!setAvailableSkill.contains(skillobj.id)))
                {
                    lstAvailableSkill.add(new SelectOption(skillobj.id, skillobj.name));
                    
                    setAvailableSkill.add(skillobj.id);
                }
                
            }
        } 
        if(!lstAvailableSkill.isempty())
            lstAvailableSkill = sortingSelectOption(lstAvailableSkill);     
    }
    //------------------------------------------- Method to Save Skill Matching Rules ------------------------------------
    public void saveSkillMatchRule()
    {
        buildSkillMatchingRulesTree();
        retrieveRecordTypes();      
        IsValidProcess = true;
        isrenderExprs = false;
        IsValidExp = true;
        IsValidinfo = true;
        try
        {
            objSkillMatch = new SVMXC__ServiceMax_Processes__c();
            String strParentcriteria = '';           
            if(isnewSkillMatchRule)  
            {                
                if(setParentsskillid != null)
                    objSkillMatch.SVMXC__Sequence__c = setParentsskillid.size();
                  
                if(strSkillid != null && strSkillid != '')
                {                
                    if(mapChildstoParrent.containskey(strSkillid) && mapAvailableSkillidtoRec.containskey(strSkillid))
                        objSkillMatch.SVMXC__Node_Parent__c   = mapAvailableSkillidtoRec.get(strSkillid).SVMXC__Node_Parent__c;                    
                    else
                        objSkillMatch.SVMXC__Node_Parent__c   = strSkillid;
                    
                    objSkillMatch.SVMXC__Sequence__c   = 0;
                }
                else
                    objSkillMatch.SVMXC__Node_Parent__c   = null; 
            }   
            if(!isnewSkillMatchRule)  
            {           
                objSkillMatch = objSkillMatchEdit;
                objSkillMatch.SVMXC__Select__c = false;
            }
            validation();
           
            if(IsValidProcess)
            {                 
                if(lstSkillMatchConfig != null && lstSkillMatchConfig.size() >0)
                {
                    List<SVMXC__ServiceMax_Config_Data__c> lstSkillMatchConfigtemp = new List<SVMXC__ServiceMax_Config_Data__c>();
                    for(SVMXC__ServiceMax_Config_Data__c objconfdata : lstSkillMatchConfig)
                    {
                        if(objconfdata.SVMXC__Operator__c != null && objconfdata.SVMXC__Operator__c != getTAG038() && objconfdata.SVMXC__Field_Name__c != getTAG038())
                            lstSkillMatchConfigtemp.add(objconfdata);
                    }
                    lstSkillMatchConfig.clear();
                    lstSkillMatchConfig.addall(lstSkillMatchConfigtemp);
                }
                if(lstSkillMatchConfig != null && lstSkillMatchConfig.size() >0)
                {
                    List<SVMXC__ServiceMax_Config_Data__c> lstSkillMatchConfigtemp = new List<SVMXC__ServiceMax_Config_Data__c>();
                   
                   
                    integer seqval = 1;
                    for(SVMXC__ServiceMax_Config_Data__c Cnfig :lstSkillMatchConfig)
                    {
                        Cnfig.SVMXC__Sequence__c = seqval;
                        seqval = seqval+1;
                        lstSkillMatchConfigtemp.add(Cnfig);
                        
                    }
                    lstSkillMatchConfig.clear();
                    if(!lstSkillMatchConfigtemp.isempty())
                    lstSkillMatchConfig.addall(lstSkillMatchConfigtemp);
                   
                    boolean isExpVal;
                    isExpVal = submitExp(objSkillMatch,lstSkillMatchConfig,strAdvanceExp);
                     
                    if(!isExpVal)
                    {
                        isRenderExp = true;
                        isrenderExpres = true;
                        isrenderExprs = true;
                        IsValidExp = false;
                        Apexpages.addMessage(new Apexpages.Message(Apexpages.Severity.Error, getTAG062()));
                    }
                    
                    strParentcriteria = ValidateExp.getCriteria('SVMXC__Service_Order__c', strAdvanceExp, lstSkillMatchConfig ); 
                    if(strParentcriteria == 'ERROR')
                    {
                        isRenderExp = true;
                        isrenderExpres = true;
                        isrenderExprs = true;
                        IsValidExp = false;
                        Apexpages.addMessage(new Apexpages.Message(Apexpages.Severity.Error, getTAG062()));
                    }                   
               }   
                if(IsValidExp)
                {
                    objSkillMatch.SVMXC__Name__c = strProcessName; 
                    objSkillMatch.SVMXC__Description__c = strDescription;             
                    objSkillMatch.SVMXC__Active__c = isactive;
                    objSkillMatch.SVMXC__Advance_Expression__c = strAdvanceExp;  
                    objSkillMatch.SVMXC__Rule_Type__c = 'Skill Matching';
                    objSkillMatch.SVMXC__Source_Object_Name__c='SVMXC__Service_Order__c'; 
                    objSkillMatch.SVMXC__Parent_Object_Criteria__c = strParentcriteria;  
                    objSkillMatch.RecordTypeId = ExpHdr_Rtype_Id;           
                    Map<String,Schema.SObjectField> objfieldMap = new Map<String,Schema.SObjectField>();
                    objfieldMap = SVMXC__Service_Order__c.SObjectType.getDescribe().fields.getMap(); 
                    //CRUD  
                    if (!securityUtils.verifyFieldAccess(objSkillMatch, COMM_SecurityUtils.Access.Upsertable))      //SDL-SVMX-CREATE-UPDATE-FLS-ENFORCED
                        {
                            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error, System.label.COMM001_TAG142));
                        }           
                    else
                        {
                            upsert objSkillMatch;
                        }
                    //upsert objSkillMatch; 
                    integer seqval = 1;
                    for(SVMXC__ServiceMax_Config_Data__c confobj: lstSkillMatchConfig)
                    {
                        
                        confobj.SVMXC__Expression_Type__c = 'Skill_Eligibility';
                        confobj.RecordTypeId = ExpDtl_Rtype_Id;
                        confobj.SVMXC__Expression_Rule__c = objSkillMatch.id;                    
                        confobj.SVMXC__Sequence__c = seqval;  
                        seqval = seqval+1;                      
                        for (String fieldKey : objfieldMap.keySet()) 
                        {
                            Schema.SObjectField fsObj = objfieldMap.get(fieldKey);
                            Schema.DescribeFieldResult f = fsObj.getDescribe();
                            if(f.getName() == confobj.SVMXC__Field_Name__c)
                            {
                                confobj.SVMXC__Display_Type__c = f.getType().name();
                            }
                        }
                    }                
                    if(!lstSkillMatchConfigDel.isempty())                
                        delete lstSkillMatchConfigDel;      //SDL-SVMX-FLS-NOT-ENFORCED-META-DATA
                    if(lstSkillMatchConfig!= null && lstSkillMatchConfig.size()>0)
                        upsert lstSkillMatchConfig;    //SDL-SVMX-FLS-NOT-ENFORCED-META-DATA                
                    if(!lstSkillAppDel.isempty())
                        delete lstSkillAppDel;      //SDL-SVMX-FLS-NOT-ENFORCED-META-DATA
                    lstApplicableSkillsConfig.clear();
                    if(LstCriWrap != null && LstCriWrap.size() >0)
                    {
                        for(integer i=0; i<LstCriWrap.size();i++)
                        {
                            SVMXC__ServiceMax_Config_Data__c ConfigDataExp = new SVMXC__ServiceMax_Config_Data__c();                    
                            ConfigDataExp = LstCriWrap[i].objConf;                         
                            ConfigDataExp.RecordTypeId = ExpDtl_AppSkill_Id;
                            ConfigDataExp.SVMXC__Expression_Rule__c = objSkillMatch.id;
                           //ConfigDataExp.SVMXC__Minimum_Level__c = decimal.valueOf(LstCriWrap[i].strMinimumLevel) ;
                            if(!ConfigDataExp.SVMXC__Required__c)
                                ConfigDataExp.SVMXC__Minimum_Level__c = 0;
                            if(ConfigDataExp.SVMXC__Minimum_Level__c < 0)
                            {
                                
                                IsValidinfo = false;
                                isRenderExp = true;
                                isrenderExpres = true;
                                isrenderExprs = true;
                                Apexpages.addMessage(new Apexpages.Message(Apexpages.Severity.Error, getTAG009()));
                            }
                            
                            lstApplicableSkillsConfig.add(ConfigDataExp);                   
                        }
                        
                    }    
                    //CRUD
                    if(lstApplicableSkillsConfig != null && lstApplicableSkillsConfig.size() >0 && IsValidinfo)
                    {
                        if (!securityUtils.verifyFieldAccess(lstApplicableSkillsConfig, COMM_SecurityUtils.Access.Upsertable))      //SDL-SVMX-CREATE-UPDATE-FLS-ENFORCED
                        {
                            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error, System.label.COMM001_TAG142));
                        }           
                    else
                        {
                            upsert lstApplicableSkillsConfig;
                        }
                        //upsert lstApplicableSkillsConfig;
                    } 
                    if(IsValidinfo == true && IsValidExp == true )
                    {
                        setDefaultValues();
                    buildSkillMatchingRulesTree();
                    }
                }
                else
                {
                    isRenderExp = true;
                    isrenderExpres = true;
                    isrenderExprs = true;
                    Apexpages.addMessage(new Apexpages.Message(Apexpages.Severity.Error, getTAG062()));
                }
            }       
            else   
            {
               isRenderExp = true;
               isrenderExpres = true;
               isrenderExprs = true;
            }
            
        }
        catch (System.TypeException e) 
        {
            isRenderExp = true;
            isrenderExpres = true;
            isrenderExprs = true;
            Apexpages.addMessage(new Apexpages.Message(Apexpages.Severity.Error, getTAG009()));
        }
        catch(exception ex)
        {
            Apexpages.addMessage(new Apexpages.Message(Apexpages.Severity.Error, getTAG039()));
            
        }
        
            
        
    }
    //------------------------------------------- Method to Validate Skill Matching Rules ----------------------
    public void validation()
    {
        integer count = 0;
        IsValidProcess=true; 
        if(strProcessName == null || strProcessName == '')
        {
            IsValidProcess = false;
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error,getTAG051(),''));
        }            
        if( strProcessName.length() < 8 )   
        {
             IsValidProcess = false;
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error,getTAG061(),''));
        }   
        if( strProcessName.contains('^')== true )   
        {
            IsValidProcess = false;
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error,getTAG063(),''));
        } 
        if(isnewSkillMatchRule)
        {
            
            SVMXC__ServiceMax_Processes__c objSkillmatch = new  SVMXC__ServiceMax_Processes__c();
            objSkillmatch.SVMXC__Name__c = strProcessName;
            lstSkillMatchRules.add(objSkillmatch);
        }   
        for(SVMXC__ServiceMax_Processes__c objSkillmatch: lstSkillMatchRules)
        {
            if((!isnewSkillMatchRule) && strSkillid == String.valueof(objSkillmatch.id ))
            {
                 count = count+1;
            }
            else if(strProcessName == objSkillmatch.SVMXC__Name__c)
                count = count+1; 
        }    
        if(count > 1)
        {
            IsValidProcess = false;
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error,getTAG052(),''));
        }
        
    }
    
    public boolean submitExp(SVMXC__ServiceMax_Processes__c ProcessObj, List<SVMXC__ServiceMax_Config_Data__c> ExpConfigDataLst, string AdvExp)
    {          
        SVMXC.SFM_WrapperDef.SFM_Expression oSFM_Exp = new SVMXC.SFM_WrapperDef.SFM_Expression(ProcessObj,ExpConfigDataLst);
        oSFM_Exp.namedExpression = new SVMXC__ServiceMax_Processes__c(RecordTypeId = ExpHdr_Rtype_Id, SVMXC__Source_Object_Name__c = 'SVMXC__Service_Order__c',SVMXC__Advance_Expression__c=AdvExp);
        List<SVMXC.SFM_WrapperDef.SFM_Expression> LstSFM_Exp = new List<SVMXC.SFM_WrapperDef.SFM_Expression>();
        LstSFM_Exp.add(oSFM_Exp);
        SVMXC.SFM_WrapperDef.SFM_Request_Expression oRequest = new SVMXC.SFM_WrapperDef.SFM_Request_Expression(LstSFM_Exp);
        Save_Response = ValidateExp.SFM_validateExpression(oRequest);        
        if( Save_Response.success != null && Boolean.valueOf(Save_Response.success))
            return true;       
        else       
            return false;
           
    }
    
    //------------------------------------- Method to Cancelthe changes made to Skill Matching Rules ----------------------
    public PageReference cancelSkillMatchRule()
    {
     
        String url = '/apex/SVMXC__WORD_ManageSkillMatchingRules';      
        PageReference SkillMatchRulesPage = new PageReference(url);
        SkillMatchRulesPage.setRedirect(true);
        return SkillMatchRulesPage; 
    }
    //------------------------------------- Method to go to Setup Home Page ----------------------
    public PageReference SVMX_GoSetupHome()
    {
        //String url = '/apex/SVMXC__CONF_SetupHome'; 
        //Changes done by Nidhi as part of BAC-4747. Handling redirection on Lightning Experience
        String url='';
        if(UserInfo.getUiThemeDisplayed()=='Theme4d' || UserInfo.getUiThemeDisplayed()=='Theme4u'){
            url = '/lightning/n/SVMXC__ServiceMax_Setup';
        }else{
            url ='/apex/SVMXC__CONF_SetupHome';
        }            
        PageReference HomePage = new PageReference(url);
        HomePage.setRedirect(true);
        return HomePage; 
    }  
    //------------------------------------- Method to retrieve All the Record Types --------------------------------
    public void retrieveRecordTypes()
    {
        List<string> lstRCNames = new List<string>();
        lstRCNames.add('SVMX Rule');
        lstRCNames.add('Expressions');
        lstRCNames.add('Applicable Skills');
        List<string> lstObjs = new List<string>();
        lstObjs.add('SVMXC__ServiceMax_Processes__c');
        lstObjs.add('SVMXC__ServiceMax_Config_Data__c');
        
        for(RecordType RC: [select id, Name, SobjectType from RecordType where Name IN: lstRCNames and SobjectType IN: lstObjs])
        {
            if(RC.Name == 'SVMX Rule' && RC.SobjectType == 'SVMXC__ServiceMax_Processes__c')
                ExpHdr_Rtype_Id = RC.Id;
            if(RC.Name == 'Expressions' && RC.SobjectType == 'SVMXC__ServiceMax_Config_Data__c')
                ExpDtl_Rtype_Id = RC.Id;
            if(RC.Name == 'Applicable Skills' && RC.SobjectType == 'SVMXC__ServiceMax_Config_Data__c')
                ExpDtl_AppSkill_Id = RC.Id;
        }      
        
    }
     //-----------------------------------------Method to add Row to Expression ---------------------------------------------
    public void HdrADDRow()
    {
        try
        {          
            lstSkillMatchConfig.add(new SVMXC__ServiceMax_Config_Data__c(SVMXC__Sequence__c = Integer.valueOf(lstSkillMatchConfig.size() + 1)));            
        }
        catch(Exception ex)
        {
            ApexPages.addMessage(new ApexPages.Message ( ApexPages.Severity.ERROR,ex.getMessage()));
        }
        
    }
    
    
  
    
    //---------------------------- Methods to delete row from Expression details ------------------------------------------
    public void HdrDeleteRow()
    {
       
        integer IntVal;
        IntVal = integer.valueOf(StrDelIndex);            
        if(lstSkillMatchConfig.get(IntVal - 1).id != null)  
              lstSkillMatchConfigDel.add(lstSkillMatchConfig.get(IntVal - 1));
        lstSkillMatchConfig.remove(IntVal - 1); 
        if(IntVal <= lstSkillMatchConfig.size())
        for( integer i = IntVal; i <= lstSkillMatchConfig.size(); i++ )
            lstSkillMatchConfig[i-1].SVMXC__Sequence__c = i;            
        
          
    }
    
    //---------------------------------------- Add skills from applicable Skills ---------------------------    
    
    public void moveSkill()
    { 
        try
         {         
            if(strSelSkill != null)
            {
                for(string SelSkill:strSelSkill)
                {
                    if(LstCriWrap.isEmpty())        
                        LstCriWrap.add(new ConfigExpWrapper(new SVMXC__ServiceMax_Config_Data__c(SVMXC__Skill__c = SelSkill, SVMXC__Sequence__c =1,SVMXC__Minimum_Level__c = 0),mapSkillidtoSkillRec.get(SelSkill)) ); 
                    else
                        LstCriWrap.add(new ConfigExpWrapper(new SVMXC__ServiceMax_Config_Data__c(SVMXC__Skill__c = SelSkill, SVMXC__Sequence__c = Integer.valueOf(LstCriWrap.size() + 1),SVMXC__Minimum_Level__c = 0),mapSkillidtoSkillRec.get(SelSkill)));  lstappSkill.add(SelSkill);  
                
                    lstAvailableSkill.clear();                
                    setAvailableSkill.remove(SelSkill);
                    setApplicableSkill.add(SelSkill);
                }
            }
            
            for(string skillid: mapSkill.keyset())
            {
                if(!setApplicableSkill.contains(skillid))
                    lstAvailableSkill.add(mapSkill.get(skillid));
            }
        }
        catch(Exception ex)
        {
            ApexPages.addMessage(new ApexPages.Message ( ApexPages.Severity.ERROR,ex.getMessage()));
        }
        
    }
    //---------------------------------------- Remove skills from applicable Skills ---------------------------
    public void removeskill()
    {      
       
        for(integer i=0;i< LstCriWrap.size();i++)
        {
            if(LstCriWrap[i].IsSelected == true)
            {
                if(LstCriWrap[i].objConf !=null && LstCriWrap[i].objConf.id != null)
                    lstSkillAppDel.add(LstCriWrap[i].objConf);
                   
                   setCriWrapIDtoRemove.add(LstCriWrap[i].objConf.SVMXC__Skill__c);
                    
            }
        }
       
        if(!isCategoryandTagSearched)
        {
            string strQueryString;
            if(strSelSkillCategory == getTAG038() && (StrSkillTagToMatch == null || StrSkillTagToMatch == ''))
            strQueryString= 'SELECT Id,Name FROM SVMXC__Skill__c';
            lstSkill = Database.query(strQueryString);
            for(SVMXC__Skill__c  skillobj: lstSkill)
            {
                mapSkillidtoSkillRec.put(skillobj.id, skillobj.name);
                mapSkill.put(skillobj.id,new SelectOption(skillobj.id, skillobj.name));
            }
        }
        for(string strCriWrapSkillId : setCriWrapIDtoRemove)
        {
            setAvailableSkill.add(strCriWrapSkillId);
            setApplicableSkill.remove(strCriWrapSkillId);  
            for(integer i=0;i< LstCriWrap.size();i++)
            {
                if(LstCriWrap[i].objConf.SVMXC__Skill__c == strCriWrapSkillId)
                    LstCriWrap.remove(i); 
                
            }
        }
        if(!isCategoryandTagSearched)
        {lstAvailableSkill.clear();
            for(string strCriWrapSkillId : setCriWrapIDtoRemove)  
                lstAvailableSkill.add(mapSkill.get(strCriWrapSkillId));
        }
        if(isCategoryandTagSearched)
        {
            System.debug('isCategoryandTagSearched val'+isCategoryandTagSearched);
            lstAvailableSkill.clear();            
            System.debug('mapSkill val'+mapSkill);
            for(string skillid: setAvailableSkill)
            {
                if(!setApplicableSkill.contains(skillid))
                    lstAvailableSkill.add(mapSkill.get(skillid));
            } 
        }
    }
    
    //---------------------------------- Methods to reorder Skill rule Sequence --------------------------
     
    public void SVMX_OrderSequence()
    {
        isRenderNew =false;
        isRenderEdit=false;
        isRenderSave=false;
        isRenderDelete=false;
        isRendercancel=false;
        retrieveSkillMatchingRules();
        boolean DisableParntLst = true;
        lstParentSkillMatchRules.clear();
        lstParentSkillMatchRules = [select id, SVMXC__Name__c,SVMXC__Sequence__c,  SVMXC__Description__c, SVMXC__Active__c,SVMXC__Select__c , SVMXC__Parent_Object_Criteria__c, SVMXC__Source_Object_Name__c, SVMXC__Node_Parent__c,SVMXC__Advance_Expression__c from SVMXC__ServiceMax_Processes__c where  RecordTypeId =: ExpHdr_Rtype_Id And SVMXC__Rule_Type__c = 'Skill Matching' And SVMXC__Node_Parent__c = null order by SVMXC__Sequence__c];   //SDL-SVMX-FLS-NOT-ENFORCED-META-DATA
        //lstParentSkillMatchRules.addAll(lstParentSkillMatchRules);
       
        
        for(integer i=0;i<lstParentSkillMatchRules.size();i++)
        {
            if(lstParentSkillMatchRules[i].SVMXC__Select__c)           
                DisableParntLst = true;
           
        }
        if(DisableParntLst)
        {
            displaySeqPopup = true;           
            isRenderRuleSeq = false;
        }       
    }
    
    public List<SelectOption> getSeqoptions()
    {    
        Seqoptions = new List<SelectOption>();            
        if (lstParentSkillMatchRules.Size() >0)
        {
            for(SVMXC__ServiceMax_Processes__c s:lstParentSkillMatchRules)
            {                               
                if (s.SVMXC__Name__c != null)
                Seqoptions.add(new SelectOption(s.Id,s.SVMXC__Name__c));
            }
        }        
        return Seqoptions; 
    }
    public string[] getstrSkillidRearrange()
    {
        return strSkillidRearrange;
    }    
    public void setstrSkillidRearrange(string[] o)
    {
        this.strSkillidRearrange=o;
    }
    
    public void shuffle(integer selIndex, boolean isTop )
    {
        SVMXC__ServiceMax_Processes__c temp;
        
        if(isTop && lstParentSkillMatchRules.size() >= selIndex)
        {
            temp = lstParentSkillMatchRules[selIndex];
            for(integer j=selIndex;j>0;j--)
            {
                lstParentSkillMatchRules[j] = lstParentSkillMatchRules[j-1];
            }
            lstParentSkillMatchRules[0] = temp;
        }
        else if(lstParentSkillMatchRules.size() >= selIndex)
        {
            temp = lstParentSkillMatchRules[selIndex];
            for(integer j=selIndex;j<lstParentSkillMatchRules.size()-1;j++)
            {
                lstParentSkillMatchRules[j] = lstParentSkillMatchRules[j+1];
            }
            lstParentSkillMatchRules[lstParentSkillMatchRules.size()-1] = temp;
        }
    }   
    /*
    //------------------------------- Method to move Skill Rule up by one position -----------------------  
    public void UP()
    {    
        SVMXC__ServiceMax_Processes__c temp;
        for(integer j=0;j<lstParentSkillMatchRules.size();j++)
        {
            for(integer i=0;i<strSkillidRearrange.size();i++)
            {
                if(strSkillidRearrange[i]==lstParentSkillMatchRules[0].Id)
                {
                    lstParentSkillMatchRules[j] = lstParentSkillMatchRules[j];
                        //break;
                }
                else if(strSkillidRearrange[i]==lstParentSkillMatchRules[j].Id)
                {
                    temp = lstParentSkillMatchRules[j]; 
                    lstParentSkillMatchRules[j] = lstParentSkillMatchRules[j-1];
                    lstParentSkillMatchRules[j-1]=temp;                    
                    selIndex = j;
                   
                    lstParentSkillMatchRules[selIndex-1].SVMXC__Sequence__c=selIndex-1;
                    lstParentSkillMatchRules[selIndex].SVMXC__Sequence__c = selIndex;
                }
            }
        }
       
    }
    //------------------------------- Method to move Skill Rule down by one position -----------------------
    public void Down()
    {
        SVMXC__ServiceMax_Processes__c temp;
        for(integer j=lstParentSkillMatchRules.size()-1;j>=0;j--)
        {
            for(integer i=0;i<strSkillidRearrange.size();i++)
            {
                if(strSkillidRearrange[i]==lstParentSkillMatchRules[lstParentSkillMatchRules.size()-1].Id)
                {
                    lstParentSkillMatchRules[j] = lstParentSkillMatchRules[j];
                   // break;
                }
                else if(strSkillidRearrange[i]==lstParentSkillMatchRules[j].Id)
                {
                            temp = lstParentSkillMatchRules[j]; 
                            lstParentSkillMatchRules[j] = lstParentSkillMatchRules[j+1];
                            lstParentSkillMatchRules[j+1]=temp;                    
                            selIndex = j;
                            lstParentSkillMatchRules[selIndex+1].SVMXC__Sequence__c=selIndex+1;
                            lstParentSkillMatchRules[selIndex].SVMXC__Sequence__c = selIndex;
                }  
            }
        }
    }
    //------------------------------- Method to move Skill Rule to the top -----------------------
    public void Top()
    {
        SVMXC__ServiceMax_Processes__c temp;
        for(integer j=lstParentSkillMatchRules.size()-1;j>0;j--)
        {
            for(integer i=strSkillidRearrange.size()-1;i>=0;i--){
                if(strSkillidRearrange[i] == lstParentSkillMatchRules[j].Id)
                {
                    selIndex = j;
                    shuffle(selIndex, true);                   
                }
            }
        }       
    }
    //------------------------------- Method to move Skill Rule to bottom -----------------------
    public void Bottom(){
        SVMXC__ServiceMax_Processes__c temp;
        for(integer j=0;j<lstParentSkillMatchRules.size()-1;j++){
            for(integer i=0;i<strSkillidRearrange.size();i++){
                if(strSkillidRearrange[i] == lstParentSkillMatchRules[j].Id){
                    selIndex = j;                  
                    shuffle(selIndex, false); 
                }
            }
        }       
    }
    //-------------------------------------- Method to save rearrnged Skill Rule ----------------------------
    public pagereference SVMX_SaveSequence()
    {
        list<SVMXC__ServiceMax_Processes__c> lsttemp = new list<SVMXC__ServiceMax_Processes__c>();
        double t;
      
        for(integer i =0 ;i<lstParentSkillMatchRules.size();i++)
        {
            lstParentSkillMatchRules[i].SVMXC__Sequence__c=i;
        }
         update lstParentSkillMatchRules;
        setDefaultValues();
        buildSkillMatchingRulesTree();
        String url = '/apex/SVMXC__WORD_ManageSkillMatchingRules';      
        PageReference SkillMatchRulesPage = new PageReference(url);
        SkillMatchRulesPage.setRedirect(true);
        return SkillMatchRulesPage; 
    }
    */
    
    //------------------------------- Method to move Rule up by one position -----------------------    
    public void UP()
    {    
        SVMXC__ServiceMax_Processes__c temp;
        for(integer j=0;j<lstParentSkillMatchRules.size();j++)
        {
            for(integer i=0;i<strSkillidRearrange.size();i++)
            {
                if(strSkillidRearrange[i]==lstParentSkillMatchRules[0].Id)
                {
                    lstParentSkillMatchRules[j] = lstParentSkillMatchRules[j];
                        //break;
                }
                else if(strSkillidRearrange[i]==lstParentSkillMatchRules[j].Id)
                {
                    temp = lstParentSkillMatchRules[j]; 
                    lstParentSkillMatchRules[j] = lstParentSkillMatchRules[j-1];
                    lstParentSkillMatchRules[j-1]=temp;                    
                    selIndex = j;
                    //isUpAction = true;
                    //isDownAction=false;
                    //isTopAction=false;
                    //isBottomAction=false;
                    lstParentSkillMatchRules[selIndex-1].SVMXC__Sequence__c=selIndex-1;
                    lstParentSkillMatchRules[selIndex].SVMXC__Sequence__c = selIndex;
                }
            }
        }
       
    }
     //------------------------------- Method to move Rule down by one position -----------------------
    public void Down()
    {
        SVMXC__ServiceMax_Processes__c temp;
        for(integer j=lstParentSkillMatchRules.size()-1;j>=0;j--)
        {
            for(integer i=0;i<strSkillidRearrange.size();i++)
            {
                if(strSkillidRearrange[i]==lstParentSkillMatchRules[lstParentSkillMatchRules.size()-1].Id)
                {
                    lstParentSkillMatchRules[j] = lstParentSkillMatchRules[j];
                   // break;
                }
                else if(strSkillidRearrange[i]==lstParentSkillMatchRules[j].Id)
                {
                            temp = lstParentSkillMatchRules[j]; 
                            lstParentSkillMatchRules[j] = lstParentSkillMatchRules[j+1];
                            lstParentSkillMatchRules[j+1]=temp;                    
                            selIndex = j;
                            //isUpAction = false;
                            //isDownAction=true;
                            //isTopAction=false;
                            //isBottomAction=false;
                            lstParentSkillMatchRules[selIndex+1].SVMXC__Sequence__c=selIndex+1;
                            lstParentSkillMatchRules[selIndex].SVMXC__Sequence__c = selIndex;
                }  
            }
        }
    }
    //------------------------------- Method to move Rule to the top -----------------------
    public void Top()
    {
        SVMXC__ServiceMax_Processes__c temp;
        for(integer j=lstParentSkillMatchRules.size()-1;j>0;j--)
        {
            for(integer i = strSkillidRearrange.size()-1;i>=0;i--){
                if(strSkillidRearrange[i] == lstParentSkillMatchRules[j].Id)
                {
                    selIndex = j;
                    
                    shuffle(selIndex, true);                   
                }
            }
        }       
    }
    //------------------------------- Method to move Rule to bottom -----------------------
    public void Bottom(){
        SVMXC__ServiceMax_Processes__c temp;
        for(integer j=0;j<lstParentSkillMatchRules.size()-1;j++){
            for(integer i=0;i<strSkillidRearrange.size();i++){
                if(strSkillidRearrange[i] == lstParentSkillMatchRules[j].Id){
                    selIndex = j;
                                       
                    shuffle(selIndex, false); 
                }
            }
        }       
    }
    //-------------------------------------- Method to save rearrnged Rule ----------------------------
    public pagereference SVMX_SaveSequence()
    {
        list<SVMXC__ServiceMax_Processes__c> lsttemp = new list<SVMXC__ServiceMax_Processes__c>();
        double t;
      
        for(integer i =0 ;i<lstParentSkillMatchRules.size();i++)
        {
            lstParentSkillMatchRules[i].SVMXC__Sequence__c=i;
        }
        //CRUD
        if(lstParentSkillMatchRules != null && lstParentSkillMatchRules.size() > 0) 
                {
                    if (!securityUtils.verifyFieldAccess(lstParentSkillMatchRules, COMM_SecurityUtils.Access.Updateable))       //SDL-SVMX-CREATE-UPDATE-FLS-ENFORCED
                        {
                            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error, System.label.COMM001_TAG142));
                        }           
                    else
                        {
                            update lstParentSkillMatchRules;
                        }
                }
        //update lstParentSkillMatchRules;
        setDefaultValues();
        buildSkillMatchingRulesTree();
        String url = '/apex/SVMXC__WORD_ManageSkillMatchingRules';      
        PageReference SkillMatchRulesPage = new PageReference(url);
        SkillMatchRulesPage.setRedirect(true);
        return SkillMatchRulesPage;
       // return null;
        
    }
    //------------------------------------------------------Validate a given String------------------------------------
    public boolean IsValidString(String str)
    {
        if (str != null && str != '' && str.length() > 0)
            return true;
        else
            return false;
    }
   
    //---------------------------------------- Wrapper Class ----------------------------------------------------
    public class ConfigExpWrapper
    {
        public SVMXC__ServiceMax_Config_Data__c objConf = new SVMXC__ServiceMax_Config_Data__c();
        public SVMXC__ServiceMax_Config_Data__c getobjConf(){return this.objConf;}
        public void setobjConf(SVMXC__ServiceMax_Config_Data__c proces){this.objConf = proces;} 
        public String strselSkillName;
        public String getstrselSkillName(){return strselSkillName;}
        public void setstrselSkillName(String str){this.strselSkillName = str;}                  
        public boolean IsSelected;
        public boolean getIsSelected(){return IsSelected;}
        public void setIsSelected(boolean i){this.IsSelected = i;}
    
    //------------------------------------ Wrapper Constructor --------------------
        public ConfigExpWrapper()
        {
            IsSelected=false;
        }
        public ConfigExpWrapper(SVMXC__ServiceMax_Config_Data__c objCnf, string strSkillname)
        {
            objConf = objCnf;
            strselSkillName = strSkillname;
        }
}    
      //------------------------------------- Getter methods for the custom labels ----------------------------------
        
        public string getHLPURL() {return 'http://userdocs.servicemax.com';} 
        public string getTAG001(){return system.label.WORD021_TAG001;}//  'In this screen, you can create rules that dictate how to find technicians with matching skills for a Work Order.'
        public string getHLPTITLE() {return system.label.COMM001_TAG064;} // 'Help'
        public string getTAG002(){return system.label.COMM001_TAG107;} // 'New Rule'
        public string getTAG003(){return system.label.COMM001_TAG108;}  //'Edit Rule' 
        public string getTAG004(){return system.label.COMM001_TAG109;}//'Delete Rule'
        public string getTAG005(){return   system.label.COMM001_TAG039;}  // 'Save '
        public string getTAG006(){return system.label.COMM001_TAG040;}  // 'Cancel'
        public string getTAG007(){return system.label.COMM001_TAG041;}  // 'Processing'
        public string getTAG008(){return system.label.COMM001_TAG044;}  // 'Select'
        public string getTAG009(){return system.label.WORD021_TAG016;}  // 'Invalid data for Minimum Level'
        public string getTAG011(){return system.label.COMM001_TAG016;} // 'Active'
        public string getTAG012(){return system.label.WORD021_TAG002;} // Work Order criteria for this Skill Match Rule
        public string getTAG013(){return system.label.COMM001_TAG115;}  // 'Rule Name'
        public string getTAG014(){return system.label.COMM001_TAG017;} 
        public string getTAG015(){return 'Seq#';} 
        public string getTAG016(){return system.label.WORD021_TAG004;} //'Work Order Field'
        public string getTAG017(){return system.label.COMM002_TAG028;} 
        public string getTAG018(){return system.label.COMM002_TAG029;}         
        public string getTAG019(){return  system.label.COMM002_TAG024;} //'Advanced Expression'
        public String getTAG020() {return system.label.COMM002_TAG006;}//Equals
        public String getTAG021() {return system.label.COMM002_TAG007;}//Not Equal
        public String getTAG022() {return system.label.COMM002_TAG008;}//Greater Than
        public String getTAG023() {return system.label.COMM002_TAG009;}//Greater or Equal To
        public String getTAG024() {return system.label.COMM002_TAG010;}//Less Than
        public String getTAG025() {return system.label.COMM002_TAG011;}//Less or Equal To
        public String getTAG026() {return system.label.COMM002_TAG012;}//Starts With
        public String getTAG027() {return system.label.COMM002_TAG013;}//Contains
        public String getTAG028() {return system.label.COMM002_TAG014;}//Does Not Contain
        public String getTAG029() {return system.label.COMM002_TAG015;}//Includes
        public String getTAG030() {return system.label.COMM002_TAG016;}//Excludes
        public String getTAG031() {return system.label.COMM002_TAG022;}//Is Null
        public String getTAG032() {return system.label.COMM002_TAG023;}//Is Not Null
        public String getTAG033() {return system.label.WORD021_TAG005;}//'Select filter to apply on Skills: '
        public String getTAG034() {return system.label.WORD021_TAG006;}//'Skill Category'
        public String getTAG035() {return system.label.WORD021_TAG007;}//'Skill Tags'
        public string getTAG036(){return system.label.COMM002_TAG032;} // 'Add Row'
        public string getTAG037(){return system.label.COMM002_TAG033;}  // 'Delete Row'
        public String getTAG038() {return system.label.COMM002_TAG005;}//'--None--'
        public String getTAG039() {return system.label.COMM001_TAG077;}//'An unexpected error occurred. Please contact your ServiceMax Administrator.'
        public String getTAG040() {return system.label.COMM001_TAG113;}//'Please enter a valid rule name'
        public String getTAG041() {return system.label.COMM001_TAG111;}//'Please select a Rule to perform this operation'
        public String getTAG042() {return system.label.COMM001_TAG112;}//'Please select only one Rule to perform this operation'
        public String getTAG043() {return system.label.WORD021_TAG009;}//'Available Skills'
        public String getTAG044() {return system.label.COMM001_TAG036;}//
        public String getTAG045() {return system.label.COMM001_TAG037;}//
        public String getTAG046() {return system.label.WORD021_TAG010;}//'Applicable Skills'
        public String getTAG047() {return system.label.WORD021_TAG011;}//'Skill Name'
        public String getTAG048() {return system.label.WORD021_TAG012;}//'Minimum Level'
        public String getTAG049() {return system.label.WORD021_TAG013;}//'Required?'
        public String getTAG050() {return 'Rule';}
        public String getTAG051() {return  system.label.COMM001_TAG113;}//'Please enter a valid rule name'
        public String getTAG052() {return  system.label.WORD021_TAG014;}//'Duplicate Skill Matching Rule'
        public String getTAG053() {return system.label.COMM001_TAG046;}//Back To Setup Home
        public String getTAG054() {return system.label.COMM001_TAG077;}//'An unexpected error occurred. Please contact your ServiceMax Administrator.'      
        public String getTAG055() {return system.label.COMM002_TAG004;} //'Invalid expression'
        public String getTAG056() {return system.label.WORD021_TAG008;} //'Search'
        public String getTAG057() {return system.label.COMM001_TAG057;} //'Are you sure?'
        public String getTAG058() {return system.label.WORD021_TAG003;} //'Parent Rule Name'
        public String getTAG059() {return  system.label.COMM001_TAG110;}//'Rule Sequence'
        public String getTAG060() {return   system.label.WORD021_TAG017;}//'Sequence of Skill Matching Rules'
        public string getTAG061(){return system.label.COMM001_TAG114;}//'Rule name should be at least 8 characters long'
        public string getTAG062(){return system.label.COMM002_TAG004;} //'Invalid Expression'
        public string getTAG063(){return system.label.WORD021_TAG015;}//'Special character ^ is not allowed in Skill Matching Rule name'
        public string getTAG064(){return system.label.WORD021_TAG018;}//'All child rules will be deleted permanently. This cannot be rolled back. Do you still want to proceed?'
     }