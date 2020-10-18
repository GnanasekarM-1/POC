/* Security Scanned */
public with sharing class SFM_GetLookUpConfigWithData 
{
    public class SVMXException extends exception{}
    public SFM_getLookUpConfigWithData(){}
    public SFM_WrapperDef.SFM_LookUpConfigData getLookUpConfigWithData(SFM_WrapperDef.SFM_Request prequest)
    {
        SVMXC.SFM_WrapperDef.SFM_Response_NamedSearchInfo ResNamedSearch;
        SVMXC.SFM_WrapperDef.SFM_LookUpConfigData LKCD = new SVMXC.SFM_WrapperDef.SFM_LookUpConfigData();
        SVMXC__ServiceMax_Processes__c processNodes = new SVMXC__ServiceMax_Processes__c();//member of SFM_Response_ProcessNodeInfo
        List<SVMXC.SFM_WrapperDef.SFM_NamedSearchInfoDetail> processNodeSourceObject = new List<SVMXC.SFM_WrapperDef.SFM_NamedSearchInfoDetail>();//member of SFM_Response_ProcessNodeInfo
        SVMXC__ServiceMax_Processes__c processNodeObejct = new SVMXC__ServiceMax_Processes__c();
        list<SVMXC__ServiceMax_Processes__c > LstDflSearch = new list<SVMXC__ServiceMax_Processes__c >();
        set<String> DispFields = new set<String>();
        set<String> SearchFields = new set<String>();
        set<String> BubbleFields = new set<String>();
        set<String> DispFieldswithRef = new set<String>();
        set<String> SearchFieldswithRef = new set<String>();
        set<String> BubbleFieldswithRef = new set<String>();
        set<String> FinalFieldswithRef = new set<String>();
        Map<String, Schema.SObjectType> Allobjs = new Map<String, Schema.SObjectType>();
        Map<String, Schema.SObjectField> FieldMap = new Map<String, Schema.SObjectField>();
        Map<String, String> mainDispfldnames = new Map<String, String>();
        Map<String, String> mainBubblefldnames = new Map<String, String>();
        SVMXC.SFM_Utils utils = new SVMXC.SFM_Utils();
        String LkUpCnfgId;
        String LookUpConfgId;
        String Keyword;
        String sobjtname;
        String Defltfield;
        Integer NoOfRec;
        String Query = '';
        String ContextVal;
        String fldName;
        String InfoType;
        String SrchRecId;
        String searchOperator = '';
        List<sObject> Resultdata;
        List<SVMXC.SFM_WrapperDef.bubble_wp> Resultdata1 = new List<SVMXC.SFM_WrapperDef.bubble_wp>();
        Map<String, Id> objectRecType_Map = new Map<String, Id>();
        List<String> recTypeNames = new List<String>();
        recTypeNames.add('SVMXC__ServiceMax_Processes__c~Named Search');
        recTypeNames.add('SVMXC__ServiceMax_Config_Data__c~Expressions');
        objectRecType_Map = utils.getRecordTypes(recTypeNames);
        String ObjectName = '';
        SVMX_Debug log = new SVMX_Debug();
        String WhereClause = ' where ';
        String strLimit = '';
        String whereStr = '';
        String RltdobjName;
        String ObjectNameAPI;
        log.login('SFM_getLookUpConfigWithData', 'getLookUpConfigWithData(SFM_WrapperDef.SFM_Request prequest)');
        SVMXC__ServiceMax_Processes__c hdrnamedsrch = new SVMXC__ServiceMax_Processes__c();
        SVMXC__ServiceMax_Processes__c objectDetails = new SVMXC__ServiceMax_Processes__c();
        List<SVMXC__ServiceMax_Config_Data__c> fields = new List<SVMXC__ServiceMax_Config_Data__c>();
        List<SVMXC.SFM_WrapperDef.SFM_NamedSearchInfoDetail> CloneprocessNodeSourceObject = new List<SVMXC.SFM_WrapperDef.SFM_NamedSearchInfoDetail>();
        SFM_WrapperDef.SFM_NamedSearchInfoDetail oSFM_Exp;
        List<SFM_WrapperDef.SFM_NamedSearchInfo> NSI1 = new List<SFM_WrapperDef.SFM_NamedSearchInfo>();
        List<SFM_WrapperDef.SFM_StringMap> strmap = new List<SFM_WrapperDef.SFM_StringMap>();
        try
        {
            system.debug('prequest'+prequest);
            List<SFM_WrapperDef.SFM_StringMap> requestedData = prequest.stringMap;
            for(SFM_WrapperDef.SFM_StringMap req: requestedData)
            {
                if(req.key.toUpperCase() == 'RECORDID')
                    LkUpCnfgId = req.value;
                if(req.key.toUpperCase() == 'KEYWORD')
                    Keyword = req.value;
                if(req.key.toUpperCase() == 'OBJECTNAME')
                    sobjtname = req.value;
                if(req.key.toUpperCase() == 'DEFAULTCOLUMN')    
                    Defltfield=req.value;
                if(req.key.toUpperCase() == 'NOOFRECORDS')
                    NoOfRec =integer.ValueOf(req.value);
                if(req.key.toUpperCase() == 'CONTEXTVALUE')
                    ContextVal =req.value;
                if(req.key.toUpperCase() == 'FIELDNAME')
                    fldName =req.value;
                if(req.key.toUpperCase() == 'INFOTYPE')
                    InfoType =req.value;
                if(req.key.toUpperCase() == 'SEARCHRECORD')
                    SrchRecId =req.value;
                if(req.key.toUpperCase() == 'RELATEDOBJECTNAME')
                    RltdobjName =req.value;
                if(req.key.toUpperCase() == 'SEARCHOPERATOR')   
                    searchOperator = req.value;
            }
            system.debug('RECORDID'+LkUpCnfgId);
            system.debug('Keyword'+Keyword);
            system.debug('OBJECTNAME'+sobjtname);
            system.debug('DEFAULTCOLUMN'+Defltfield);
            system.debug('NOOFRECORDS'+NoOfRec);
            system.debug('ContextVal'+ContextVal);
            system.debug('FIELDNAME'+fldName);
            system.debug('InfoType'+InfoType);
            system.debug('SrchRecId'+SrchRecId);
            system.debug('searchOperator'+searchOperator);

            if(NoOfRec != null)
                strLimit = 'limit '+ NoOfRec;
            else
                strLimit = 'limit 50';
            
            if(LkUpCnfgId != null && LkUpCnfgId.length() > 0)
            {
                system.debug('Enter in lookup config not null');
                SVMXC.SFM_getNamedSearchInfo getnamedsearch = new SVMXC.SFM_getNamedSearchInfo();
                ResNamedSearch = getnamedsearch.getNamedSearchInfo(prequest);
                system.debug('ResNamedSearch : ' + ResNamedSearch);
                if(ResNamedSearch.response.success != null && !ResNamedSearch.response.success)
                {
                    LKCD.response = ResNamedSearch.response;
                    system.debug('LKCD'+LKCD);
                    return LKCD;
                }
                for(SFM_WrapperDef.SFM_NamedSearchInfo namedsrchinfo: ResNamedSearch.namedSearch)
                {
                    processNodes = namedsrchinfo.namedSearchHdr;
                    if(namedsrchinfo.namedSearchHdr.SVMXC__Number_of_Lookup_Records__c != null)
                    {
                        strLimit = '';
                        strLimit += 'limit ' +String.valueof(namedsrchinfo.namedSearchHdr.SVMXC__Number_of_Lookup_Records__c);
                    }   
                    processNodeSourceObject.addAll(namedsrchinfo.namedSearchDetails);

                }
                if(processNodeSourceObject.size()>0 && processNodeSourceObject!=null)
                {
                    for(Integer i = 0;i<processNodeSourceObject.size();i++)
                    {
                        SVMXC.SFM_WrapperDef.SFM_NamedSearchInfoDetail ProcessNodeDetail;
                        ProcessNodeDetail = processNodeSourceObject[i];
                        processNodeObejct = ProcessNodeDetail.objectDetails;
                        ObjectName=processNodeObejct.SVMXC__Source_Object_Name__c;
                        if(processNodeObejct.SVMXC__Parent_Object_Criteria__c != null)
                            WhereClause += ' ( '+ processNodeObejct.SVMXC__Parent_Object_Criteria__c + ') AND ';
                        system.debug('WhereClause: '+WhereClause);  
                        for(Integer j = 0;j<ProcessNodeDetail.fields.size();j++)
                        {
                            SVMXC__ServiceMax_Config_Data__c tempconfigdata = new SVMXC__ServiceMax_Config_Data__c();
                            tempconfigdata = ProcessNodeDetail.fields[j];
                            system.debug('tempconfigdata : ' + tempconfigdata);
                            if(tempconfigdata.SVMXC__Search_Object_Field_Type__c.toUpperCase()=='RESULT' && tempconfigdata.SVMXC__Field_Name__c != 'Id')
                            {
                                DispFields.add(tempconfigdata.SVMXC__Field_Name__c);
                                if(tempconfigdata.SVMXC__Display_Type__c != null && tempconfigdata.SVMXC__Display_Type__c.touppercase() == 'REFERENCE')
                                {
                                    String disp = '';
                                    disp = tempconfigdata.SVMXC__Field_Relationship_Name__c+'.'+tempconfigdata.SVMXC__FKey_Name_Field__c;
                                    mainDispfldnames.put(tempconfigdata.SVMXC__Field_Name__c,disp);
                                    DispFieldswithRef.add(disp);
                                }
                                else
                                {
                                    DispFieldswithRef.add(tempconfigdata.SVMXC__Field_Name__c);
                                    mainDispfldnames.put(tempconfigdata.SVMXC__Field_Name__c,tempconfigdata.SVMXC__Field_Name__c);
                                }
                            }
                            if(tempconfigdata.SVMXC__Search_Object_Field_Type__c.toUpperCase()=='SEARCH' && tempconfigdata.SVMXC__Field_Name__c != 'Id')
                            {
                                SearchFields.add(tempconfigdata.SVMXC__Field_Name__c);
                                if(tempconfigdata.SVMXC__Display_Type__c != null && tempconfigdata.SVMXC__Display_Type__c.touppercase() == 'REFERENCE')
                                {
                                    String srchp = '';
                                    srchp = tempconfigdata.SVMXC__Field_Relationship_Name__c +'.'+ tempconfigdata.SVMXC__FKey_Name_Field__c;
                                    SearchFieldswithRef.add(srchp);
                                }
                                else
                                {
                                    SearchFieldswithRef.add(tempconfigdata.SVMXC__Field_Name__c);
                                }
                            }
                            if(tempconfigdata.SVMXC__Search_Object_Field_Type__c.toUpperCase()=='BUBBLE' && tempconfigdata.SVMXC__Field_Name__c != 'Id')
                            {
                                BubbleFields.add(tempconfigdata.SVMXC__Field_Name__c);
                                if(tempconfigdata.SVMXC__Display_Type__c != null && tempconfigdata.SVMXC__Display_Type__c.touppercase() == 'REFERENCE')
                                {
                                    String Bubp = '';
                                    Bubp = tempconfigdata.SVMXC__Field_Relationship_Name__c+'.'+tempconfigdata.SVMXC__FKey_Name_Field__c;
                                    mainBubblefldnames.put(tempconfigdata.SVMXC__Field_Name__c,Bubp);
                                    BubbleFieldswithRef.add(Bubp);
                                }
                                else
                                {
                                    BubbleFieldswithRef.add(tempconfigdata.SVMXC__Field_Name__c);
                                    mainBubblefldnames.put(tempconfigdata.SVMXC__Field_Name__c,tempconfigdata.SVMXC__Field_Name__c);
                                }
                            }
                            system.debug('DispFieldswithRef'+DispFieldswithRef);
                            system.debug('BubbleFieldswithRef'+BubbleFieldswithRef);
                            system.debug('SearchFieldswithRef'+SearchFieldswithRef);
                        }
                    }
                }
                if(InfoType == null || InfoType == '')
                {
                    system.debug('TESTlllll: ' + Keyword + SearchFieldswithRef);
                    if(Keyword != null)
                    {
                        for(String sfield: SearchFieldswithRef)
                        {
                            if(sfield != '' || sfield != NULL)
                            {
                                if(whereStr != '')
                                    whereStr += ' OR ';
                                //whereStr += sfield+' like \'%'+string.escapeSingleQuotes(Keyword)+'%\'';
                                //Added by Amar on 10/Feb.2012 to support different keyword in lookup config search
                                if(searchOperator != null && searchOperator.length() > 0 && searchOperator == 'eq')
                                    whereStr += sfield+' = \''+string.escapeSingleQuotes(Keyword)+'\'';
                                else if(searchOperator != null && searchOperator.length() > 0 && searchOperator == 'contains')
                                    whereStr += sfield+' like \'%'+string.escapeSingleQuotes(Keyword)+'%\'';
                                else if(searchOperator != null && searchOperator.length() > 0 && searchOperator == 'sw')
                                    whereStr += sfield+' like \''+string.escapeSingleQuotes(Keyword)+'%\'';
                                else if(searchOperator != null && searchOperator.length() > 0 && searchOperator == 'ew')
                                    whereStr += sfield+' like \'%'+string.escapeSingleQuotes(Keyword)+'\'';
                            }
                            system.debug('amar'+whereStr);
                        }
                        if(ContextVal != null && fldName != null)
                            WhereClause += ' ( '+whereStr+' ) '+' AND '+ fldName +'='+'\''+ContextVal+'\''+ ' '+strLimit;
                        else
                            WhereClause += ' ( '+whereStr+' ) '+ ' '+strLimit;
                    }
                    else if(Keyword == null || Keyword == '')
                    {
                        if(ContextVal != null && fldName != null)
                            WhereClause += fldName +'='+'\''+ContextVal+'\''+ ' '+strLimit;
                        else
                            WhereClause=' '+strLimit;
                    }
                    system.debug('WhereClause: '+WhereClause);
                    if(DispFieldswithRef.size() > 0 && BubbleFieldswithRef.size() == 0)
                    {
                        if(DispFieldswithRef.contains(Defltfield))
                            Query='SELECT '+SVMX_getFieldNamesFromList(DispFieldswithRef)+ ',Id'+' FROM '+ ObjectName + +WhereClause;
                        else
                        {
                            if(Defltfield != null)
                                Query='SELECT '+SVMX_getFieldNamesFromList(DispFieldswithRef)+ ','+Defltfield+',Id'+' FROM '+ ObjectName + +WhereClause;
                            else
                                Query='SELECT '+SVMX_getFieldNamesFromList(DispFieldswithRef)+',Id'+' FROM '+ ObjectName + +WhereClause;
                        }
                        system.debug('DispFieldswithRef'+Query);
                        Resultdata=database.query(Query);
                    }
                    if(DispFieldswithRef.size() == 0 && BubbleFieldswithRef.size() > 0)
                    {
                        if(BubbleFieldswithRef.contains(Defltfield))
                            Query='SELECT '+SVMX_getFieldNamesFromList(BubbleFieldswithRef)+',Id'+' FROM '+ ObjectName + +WhereClause;
                        else
                        {
                            if(Defltfield != null)
                                Query='SELECT '+SVMX_getFieldNamesFromList(BubbleFieldswithRef)+','+Defltfield+',Id'+' FROM '+ ObjectName + +WhereClause;
                            else
                                Query='SELECT '+SVMX_getFieldNamesFromList(BubbleFieldswithRef)+',Id'+' FROM '+ ObjectName + +WhereClause;
                        }
                        system.debug('BubbleFieldswithRef'+Query);
                        Resultdata=database.query(Query);
                    }
                    if(DispFieldswithRef.size() > 0 && BubbleFieldswithRef.size() > 0)
                    {
                        for (String field1 : DispFieldswithRef)
                        {
                            FinalFieldswithRef.add(field1);
                        }
                        for (String field2 : BubbleFieldswithRef)
                        {
                            FinalFieldswithRef.add(field2);
                        }
                        if(FinalFieldswithRef.contains(Defltfield))
                            Query='SELECT '+SVMX_getFieldNamesFromList(FinalFieldswithRef)+',Id'+' FROM '+ ObjectName + +WhereClause;
                        else
                        {
                            if(Defltfield != null)
                                Query='SELECT '+SVMX_getFieldNamesFromList(FinalFieldswithRef)+ ','+Defltfield+',Id'+' FROM '+ ObjectName + +WhereClause;
                            else
                                Query='SELECT '+SVMX_getFieldNamesFromList(FinalFieldswithRef)+',Id'+' FROM '+ ObjectName + +WhereClause;
                        }
                        system.debug('AllFields'+Query);
                        Resultdata=database.query(Query);
                    } 
                    if(!DispFieldswithRef.contains(Defltfield) && Defltfield != null)
                        mainDispfldnames.put(Defltfield,Defltfield);
                    mainDispfldnames.put('Id','Id');
                    if(Resultdata != null)
                    {
                        for(sObject sobj: Resultdata)
                        {
                            List<SFM_WrapperDef.SFM_StringFieldMap> strmap1 = new List<SFM_WrapperDef.SFM_StringFieldMap>();
                            if(mainDispfldnames.size() > 0)
                            {
                                for (String field : mainDispfldnames.keyset())
                                {
                                    SFM_WrapperDef.SFM_StringFieldMap strmap2 = new SFM_WrapperDef.SFM_StringFieldMap();
                                    strmap2.Key = field;
                                    if(mainDispfldnames.get(field).contains('.'))
                                    {
                                        String objval = String.valueOf(sobj.getSObject(mainDispfldnames.get(field).split('\\.')[0]));
                                        if(objval == null)
                                            strmap2.value = '';
                                        else
                                            strmap2.value = String.valueOf(sobj.getSObject(mainDispfldnames.get(field).split('\\.')[0]).get(mainDispfldnames.get(field).split('\\.')[1]));
                                    }
                                    else
                                        strmap2.value = String.valueOf(sobj.get(mainDispfldnames.get(field)));
                                    strmap2.ftype = 'Result';
                                    strmap1.add(strmap2);
                                }
                            }
                            if(mainBubblefldnames.size() > 0)
                            {
                                for (String field : mainBubblefldnames.keyset())
                                {
                                    SFM_WrapperDef.SFM_StringFieldMap strmap2 = new SFM_WrapperDef.SFM_StringFieldMap();
                                    strmap2.Key = field;
                                    if(mainBubblefldnames.get(field).contains('.'))
                                    {
                                        String objval = String.valueOf(sobj.getSObject(mainBubblefldnames.get(field).split('\\.')[0]));
                                        if(objval == null)
                                            strmap2.value = '';
                                        else
                                            strmap2.value = String.valueOf(sobj.getSObject(mainBubblefldnames.get(field).split('\\.')[0]).get(mainBubblefldnames.get(field).split('\\.')[1]));
                                    }
                                    else
                                        strmap2.value = String.valueOf(sobj.get(mainBubblefldnames.get(field)));
                                    strmap2.ftype = 'Bubble';
                                    strmap1.add(strmap2);
                                }
                            }
                            SVMXC.SFM_WrapperDef.bubble_wp bbl = new SVMXC.SFM_WrapperDef.bubble_wp(strmap1);
                            Resultdata1.add(bbl);
                        }
                    }
                }//commneted for Keyword no null
                //start
                if(InfoType != null)
                {
                    if(InfoType.toUpperCase() == 'BUBBLE')
                    {
                        if(BubbleFieldswithRef.size() > 0)
                        {
                            //If info type is bubble then no need of using whereclause 
                            Query='SELECT '+SVMX_getFieldNamesFromList(BubbleFieldswithRef)+ ' FROM '+ ObjectName + ' where Id=\''+SrchRecId+'\'';
                            //Query='SELECT '+SVMX_getFieldNamesFromList(BubbleFieldswithRef)+ ' FROM '+ ObjectName + WhereClause + ' AND Id=\''+SrchRecId+'\'';
                            
                            Resultdata = database.query(Query);
                            if(Resultdata != null)
                            {
                                for(sObject sobj: Resultdata)
                                {
                                    List<SFM_WrapperDef.SFM_StringFieldMap> strmap1 = new List<SFM_WrapperDef.SFM_StringFieldMap>();
                                    if(mainBubblefldnames.size() > 0)
                                    {
                                        for (String field : mainBubblefldnames.keyset())
                                        {
                                            SFM_WrapperDef.SFM_StringFieldMap strmap2 = new SFM_WrapperDef.SFM_StringFieldMap();
                                            strmap2.Key = field;
                                            if(mainBubblefldnames.get(field).contains('.'))
                                            {
                                                String objval = String.valueOf(sobj.getSObject(mainBubblefldnames.get(field).split('\\.')[0]));
                                                if(objval == null)
                                                    strmap2.value = '';
                                                else
                                                    strmap2.value = String.valueOf(sobj.getSObject(mainBubblefldnames.get(field).split('\\.')[0]).get(mainBubblefldnames.get(field).split('\\.')[1]));
                                            }
                                            else
                                                strmap2.value = String.valueOf(sobj.get(mainBubblefldnames.get(field)));
                                            strmap2.ftype = 'Bubble';
                                            strmap1.add(strmap2);
                                        }
                                    }
                                    SVMXC.SFM_WrapperDef.bubble_wp bbl = new SVMXC.SFM_WrapperDef.bubble_wp(strmap1);
                                    Resultdata1.add(bbl);
                                }
                            }
                        }
                    }
                }
                //end
            }
            if(sobjtname != null && sobjtname.length() > 0)
            {
                system.debug('Enter in sobject not null');
                //SDL-SVMX-FLS-NOT-ENFORCED-META-DATA
                LstDflSearch = [SELECT Id, Name, SVMXC__Name__c,SVMXC__Source_Object_Name__c,SVMXC__Description__c ,SVMXC__ProcessID__c,SVMXC__Rule_Type__c,SVMXC__IsStandard__c,SVMXC__IsDefault__C,SVMXC__Active__c,SVMXC__Number_of_Lookup_Records__c,SVMXC__Default_Lookup_Column__c from SVMXC__ServiceMax_Processes__c where Recordtype.Name='Named Search' AND SVMXC__Source_Object_Name__c = : sobjtname And SVMXC__IsDefault__C = true order by SVMXC__IsStandard__c];
                system.debug('LstDflSearch'+LstDflSearch);
                if(LstDflSearch.size() > 0)
                {
                    LookUpConfgId = LstDflSearch[0].id;
                    system.debug('LookUpConfgId'+LookUpConfgId);
                    if(LookUpConfgId!=null)
                    {
                        List<SFM_WrapperDef.SFM_StringMap> stringMap123=new List<SFM_WrapperDef.SFM_StringMap>();
                        stringMap123.add(new SFM_WrapperDef.SFM_StringMap ('RECORDID',LookUpConfgId));
                        SFM_WrapperDef.SFM_Request request123 = new SFM_WrapperDef.SFM_Request('','','',stringMap123);
                        SVMXC.SFM_getNamedSearchInfo getnamedsearch = new SVMXC.SFM_getNamedSearchInfo();
                        ResNamedSearch = getnamedsearch.getNamedSearchInfo(request123);
                        system.debug('ResNamedSearch'+ResNamedSearch);
                        for(SFM_WrapperDef.SFM_NamedSearchInfo namedsrchinfo: ResNamedSearch.namedSearch)
                        {
                            processNodes = namedsrchinfo.namedSearchHdr;
                            processNodeSourceObject.addAll(namedsrchinfo.namedSearchDetails);
                        }
                        if(processNodeSourceObject.size()>0 && processNodeSourceObject!=null)
                        {
                            for(Integer i = 0;i<processNodeSourceObject.size();i++)
                            {
                                SVMXC.SFM_WrapperDef.SFM_NamedSearchInfoDetail ProcessNodeDetail;
                                ProcessNodeDetail = processNodeSourceObject[i];
                                processNodeObejct = ProcessNodeDetail.objectDetails;
                                ObjectName=processNodeObejct.SVMXC__Source_Object_Name__c;
                                if(processNodeObejct.SVMXC__Parent_Object_Criteria__c != null)
                                    WhereClause += ' ( '+ processNodeObejct.SVMXC__Parent_Object_Criteria__c + ') AND ';
                                system.debug('WhereClause: '+WhereClause);  
                                for(Integer j = 0;j<ProcessNodeDetail.fields.size();j++)
                                {
                                    SVMXC__ServiceMax_Config_Data__c tempconfigdata = new SVMXC__ServiceMax_Config_Data__c();
                                    tempconfigdata = ProcessNodeDetail.fields[j];
                                    if(tempconfigdata.SVMXC__Search_Object_Field_Type__c.toUpperCase()=='RESULT' && tempconfigdata.SVMXC__Field_Name__c != 'Id')
                                    {
                                        DispFields.add(tempconfigdata.SVMXC__Field_Name__c);
                                        if(tempconfigdata.SVMXC__Display_Type__c != null && tempconfigdata.SVMXC__Display_Type__c.touppercase() == 'REFERENCE')
                                        {
                                            String disp = '';
                                            disp = tempconfigdata.SVMXC__Field_Relationship_Name__c+'.'+tempconfigdata.SVMXC__FKey_Name_Field__c;
                                            mainDispfldnames.put(tempconfigdata.SVMXC__Field_Name__c,disp);
                                            DispFieldswithRef.add(disp);
                                        }
                                        else
                                        {
                                            DispFieldswithRef.add(tempconfigdata.SVMXC__Field_Name__c);
                                            mainDispfldnames.put(tempconfigdata.SVMXC__Field_Name__c,tempconfigdata.SVMXC__Field_Name__c);
                                            
                                        }
                                    }
                                    if(tempconfigdata.SVMXC__Search_Object_Field_Type__c.toUpperCase()=='SEARCH' && tempconfigdata.SVMXC__Field_Name__c != 'Id')
                                    {
                                        SearchFields.add(tempconfigdata.SVMXC__Field_Name__c);
                                        if(tempconfigdata.SVMXC__Display_Type__c != null && tempconfigdata.SVMXC__Display_Type__c.touppercase() == 'REFERENCE')
                                        {
                                            String srchp = '';
                                            srchp = tempconfigdata.SVMXC__Field_Relationship_Name__c +'.'+ tempconfigdata.SVMXC__FKey_Name_Field__c;
                                            SearchFieldswithRef.add(srchp);
                                        }   
                                        else
                                        {
                                            SearchFieldswithRef.add(tempconfigdata.SVMXC__Field_Name__c);
                                            
                                        }
                                    }
                                    if(tempconfigdata.SVMXC__Search_Object_Field_Type__c.toUpperCase()=='BUBBLE' && tempconfigdata.SVMXC__Field_Name__c != 'Id')
                                    {
                                        BubbleFields.add(tempconfigdata.SVMXC__Field_Name__c);
                                        if(tempconfigdata.SVMXC__Display_Type__c != null && tempconfigdata.SVMXC__Display_Type__c.touppercase() == 'REFERENCE')
                                        {
                                            String Bubp = '';
                                            Bubp = tempconfigdata.SVMXC__Field_Relationship_Name__c+'.'+tempconfigdata.SVMXC__FKey_Name_Field__c;
                                            mainBubblefldnames.put(tempconfigdata.SVMXC__Field_Name__c,Bubp);
                                            BubbleFieldswithRef.add(Bubp);
                                        }
                                        else
                                        {
                                            BubbleFieldswithRef.add(tempconfigdata.SVMXC__Field_Name__c);
                                            mainBubblefldnames.put(tempconfigdata.SVMXC__Field_Name__c,tempconfigdata.SVMXC__Field_Name__c);
                                        }
                                    }
                                }
                            }
                        }
                        system.debug('DispFieldswithRef'+DispFieldswithRef);
                        system.debug('BubbleFieldswithRef'+BubbleFieldswithRef);
                        String strAndUserActive = '';
                        String strUserActive = '';
                        if(ObjectName.toUpperCase() == 'USER')
                        {
                            strAndUserActive = ' and isActive = true ';
                            strUserActive = ' isActive = true ';
                        }
                        if(InfoType == null || InfoType == '')
                        {
                            system.debug('Enterd Here'+Keyword);
                            if(Keyword != null)
                            {
                                for(String sfield: SearchFieldswithRef)
                                {
                                    if(sfield != '' || sfield != NULL)
                                    {
                                        if(whereStr != '')
                                        whereStr += ' OR ';
                                        //whereStr += sfield+' like \'%'+string.escapeSingleQuotes(Keyword)+'%\'';
                                        //Added by Amar on 10/Feb.2012 to support different keyword in lookup config search
                                        if(searchOperator != null && searchOperator.length() > 0 && searchOperator == 'eq')
                                            whereStr += sfield+' = \''+string.escapeSingleQuotes(Keyword)+'\'';
                                        else if(searchOperator != null && searchOperator.length() > 0 && searchOperator == 'contains')
                                            whereStr += sfield+' like \'%'+string.escapeSingleQuotes(Keyword)+'%\'';
                                        else if(searchOperator != null && searchOperator.length() > 0 && searchOperator == 'sw')
                                            whereStr += sfield+' like \''+string.escapeSingleQuotes(Keyword)+'%\'';
                                        else if(searchOperator != null && searchOperator.length() > 0 && searchOperator == 'ew')
                                            whereStr += sfield+' like \'%'+string.escapeSingleQuotes(Keyword)+'\'';
                                    }
                                }
                                if(ContextVal != null && fldName != null)
                                    WhereClause += ' ( '+whereStr+' ) '+' AND '+ fldName +'='+'\''+ContextVal+'\''+ strAndUserActive + ' '+strLimit;
                                else
                                    WhereClause += ' ( '+whereStr+' ) '+ ' '+ strAndUserActive +strLimit;
                                system.debug('WhereClause'+WhereClause);
                            }
                            else if(Keyword == null || Keyword == '')
                            {
                                system.debug('Entered here'+ContextVal);
                                if(ContextVal != null && fldName != null)
                                    WhereClause += fldName +'='+'\''+ContextVal+'\''+ ' '+ strAndUserActive + strLimit;
                                else
                                    WhereClause=' '+ strUserActive + strLimit;
                                    system.debug('Entered here'+WhereClause);
                            }
                            if(DispFieldswithRef.size() > 0 && BubbleFieldswithRef.size() == 0)
                            {
                                if(DispFieldswithRef.contains(Defltfield))
                                    Query='SELECT '+SVMX_getFieldNamesFromList(DispFieldswithRef)+ ',Id'+' FROM '+ ObjectName + +WhereClause;
                                else
                                {
                                    if(Defltfield != null)
                                        Query='SELECT '+SVMX_getFieldNamesFromList(DispFieldswithRef)+ ','+Defltfield+',Id'+' FROM '+ ObjectName + +WhereClause;
                                    else
                                        Query='SELECT '+SVMX_getFieldNamesFromList(DispFieldswithRef)+',Id'+' FROM '+ ObjectName + +WhereClause;
                                }
                                Resultdata=database.query(Query);
                            }
                            if(DispFieldswithRef.size() == 0 && BubbleFieldswithRef.size() > 0)
                            {
                                if(BubbleFieldswithRef.contains(Defltfield))
                                    Query='SELECT '+SVMX_getFieldNamesFromList(BubbleFieldswithRef)+',Id'+' FROM '+ ObjectName + +WhereClause;
                                else
                                {
                                    if(Defltfield != null)
                                        Query='SELECT '+SVMX_getFieldNamesFromList(BubbleFieldswithRef)+','+Defltfield+',Id'+' FROM '+ ObjectName + +WhereClause;
                                    else
                                        Query='SELECT '+SVMX_getFieldNamesFromList(BubbleFieldswithRef)+',Id'+' FROM '+ ObjectName + +WhereClause;
                               }
                               Resultdata=database.query(Query);
                            }
                            if(DispFieldswithRef.size() > 0 && BubbleFieldswithRef.size() > 0)
                            {
                                for (String field1 : DispFieldswithRef)
                                {
                                    //if(field1 != 'Id')
                                    FinalFieldswithRef.add(field1);
                                }
                                for (String field2 : BubbleFieldswithRef)
                                {
                                    //if(field2 != 'Id')
                                    FinalFieldswithRef.add(field2);
                                }
                                if(FinalFieldswithRef.contains(Defltfield))
                                    Query='SELECT '+SVMX_getFieldNamesFromList(FinalFieldswithRef)+',Id'+' FROM '+ ObjectName + +WhereClause;
                                else
                                {   
                                    if(Defltfield != null)
                                        Query='SELECT '+SVMX_getFieldNamesFromList(FinalFieldswithRef)+ ','+Defltfield+',Id'+' FROM '+ ObjectName + +WhereClause;
                                    else
                                        Query='SELECT '+SVMX_getFieldNamesFromList(FinalFieldswithRef)+',Id'+' FROM '+ ObjectName + +WhereClause;
                                }
                                system.debug('Query:'+Query);
                                Resultdata=database.query(Query);
                            } 
                            if(!DispFieldswithRef.contains(Defltfield) && Defltfield != null)
                                mainDispfldnames.put(Defltfield,Defltfield);
                            mainDispfldnames.put('Id','Id');
                            system.debug('Resultdata'+Resultdata);
                            if(Resultdata != null)
                            {
                                for(sObject sobj: Resultdata)
                                {
                                    List<SFM_WrapperDef.SFM_StringFieldMap> strmap1 = new List<SFM_WrapperDef.SFM_StringFieldMap>();
                                    if(mainDispfldnames.size() > 0)
                                    {
                                        for (String field : mainDispfldnames.keyset())
                                        {
                                            SFM_WrapperDef.SFM_StringFieldMap strmap2 = new SFM_WrapperDef.SFM_StringFieldMap();
                                            strmap2.Key = field;
                                            if(mainDispfldnames.get(field).contains('.'))
                                            {
                                                String objval = String.valueOf(sobj.getSObject(mainDispfldnames.get(field).split('\\.')[0]));
                                                if(objval == null)
                                                    strmap2.value = '';
                                                else
                                                    strmap2.value = String.valueOf(sobj.getSObject(mainDispfldnames.get(field).split('\\.')[0]).get(mainDispfldnames.get(field).split('\\.')[1]));
                                            }
                                            else
                                                strmap2.value = String.valueOf(sobj.get(mainDispfldnames.get(field)));
                                            strmap2.ftype = 'Result';
                                            strmap1.add(strmap2);
                                        }
                                    }
                                    if(mainBubblefldnames.size() > 0)
                                    {
                                        for (String field : mainBubblefldnames.keyset())
                                        {
                                            SFM_WrapperDef.SFM_StringFieldMap strmap2 = new SFM_WrapperDef.SFM_StringFieldMap();
                                            strmap2.Key = field;
                                            if(mainBubblefldnames.get(field).contains('.'))
                                            {
                                                String objval = String.valueOf(sobj.getSObject(mainBubblefldnames.get(field).split('\\.')[0]));
                                                if(objval == null)
                                                    strmap2.value = '';
                                                else
                                                    strmap2.value = String.valueOf(sobj.getSObject(mainBubblefldnames.get(field).split('\\.')[0]).get(mainBubblefldnames.get(field).split('\\.')[1]));
                                            }
                                            else
                                                strmap2.value = String.valueOf(sobj.get(mainBubblefldnames.get(field)));
                                            strmap2.ftype = 'Bubble';
                                            strmap1.add(strmap2);
                                        }
                                    }
                                    SVMXC.SFM_WrapperDef.bubble_wp bbl = new SVMXC.SFM_WrapperDef.bubble_wp(strmap1);
                                    Resultdata1.add(bbl);
                                }
                            }
                        }//commneted for Keyword no null
                        //start
                        if(InfoType != null)
                        {
                            if(InfoType.toUpperCase() == 'BUBBLE')
                            {
                                if(BubbleFieldswithRef.size() > 0)
                                {
                                    //If info type is bubble then no need of using whereclause 
                                    Query='SELECT '+SVMX_getFieldNamesFromList(BubbleFieldswithRef)+ ' FROM '+ ObjectName + ' where Id=\''+SrchRecId+'\'';
                                    //Query='SELECT '+SVMX_getFieldNamesFromList(BubbleFieldswithRef)+ ' FROM '+ ObjectName + WhereClause + ' AND Id=\''+SrchRecId+'\'';
                                    Resultdata = database.query(Query);
                                    if(Resultdata != null)
                                    {
                                        for(sObject sobj: Resultdata)
                                        {
                                            List<SFM_WrapperDef.SFM_StringFieldMap> strmap1 = new List<SFM_WrapperDef.SFM_StringFieldMap>();
                                            if(mainBubblefldnames.size() > 0)
                                            {
                                                for (String field : mainBubblefldnames.keyset())
                                                {
                                                    SFM_WrapperDef.SFM_StringFieldMap strmap2 = new SFM_WrapperDef.SFM_StringFieldMap();
                                                    strmap2.Key = field;
                                                    if(mainBubblefldnames.get(field).contains('.'))
                                                    {
                                                        String objval = String.valueOf(sobj.getSObject(mainBubblefldnames.get(field).split('\\.')[0]));
                                                        if(objval == null)
                                                            strmap2.value = '';
                                                        else
                                                            strmap2.value = String.valueOf(sobj.getSObject(mainBubblefldnames.get(field).split('\\.')[0]).get(mainBubblefldnames.get(field).split('\\.')[1]));
                                                    }
                                                    else
                                                        strmap2.value = String.valueOf(sobj.get(mainBubblefldnames.get(field)));
                                                    strmap2.ftype = 'Bubble';
                                                    strmap1.add(strmap2);
                                                }
                                            }
                                            SVMXC.SFM_WrapperDef.bubble_wp bbl = new SVMXC.SFM_WrapperDef.bubble_wp(strmap1);
                                            Resultdata1.add(bbl);
                                        }
                                    }
                                }
                            }
                        }
                    }
                    //end of if id
                }
                //end123final
                else
                {
                    if(InfoType != null && InfoType.length() > 0 && InfoType.toUpperCase() == 'BUBBLE')
                    {   
                        if(SrchRecId == null || SrchRecId.length() == 0)
                            strLimit = 'limit 0';
                        else if(SrchRecId != null && SrchRecId.length() > 0)
                        {
                            String nameField;
                            Allobjs = Schema.getGlobalDescribe();
                            ObjectNameAPI = utils.getOriginalAPIName(sobjtname,Allobjs);
                            if(Allobjs.containskey(ObjectNameAPI))
                            {
                                if(Allobjs.get(ObjectNameAPI) == Account.SObjectType)
                                    nameField = 'Name';
                                else
                                {   
                                    FieldMap = Allobjs.get(ObjectNameAPI).getDescribe().fields.getMap();
                                    if(FieldMap.size() > 0)
                                    {
                                        for(String s :FieldMap.keyset())
                                        {
                                            Schema.DescribeFieldResult fieldDesc = FieldMap.get(s).getDescribe();
                                            if(fieldDesc.isNameField())
                                            {
                                                nameField = fieldDesc.getName();
                                                break;
                                            }

                                        }
                                    }
                                }   
                            }
                            String Query1 = 'SELECT '+nameField+' FROM '+ sobjtname + ' where id =: SrchRecId';  
                            system.debug('Query1'+Query1);
                            Resultdata = database.query(Query1);
                            system.debug('Resultdata'+Resultdata);
                            if(Resultdata != null)
                            {
                                for(sObject sobj: Resultdata)
                                {
                                    List<SFM_WrapperDef.SFM_StringFieldMap> strmap1 = new List<SFM_WrapperDef.SFM_StringFieldMap>();
                                    SFM_WrapperDef.SFM_StringFieldMap strmap2 = new SFM_WrapperDef.SFM_StringFieldMap();
                                    strmap2.Key = nameField;
                                    strmap2.value = String.valueOf(sobj.get(nameField));
                                    strmap2.ftype = 'Result';
                        
                                    SFM_WrapperDef.SFM_StringFieldMap strmap3 = new SFM_WrapperDef.SFM_StringFieldMap();
                                    strmap3.Key = 'Id';
                                    strmap3.value = String.valueOf(sobj.get('Id'));
                                    strmap3.ftype = 'Result';

                        
                                    strmap1.add(strmap2);
                                    strmap1.add(strmap3);
                                    SVMXC.SFM_WrapperDef.bubble_wp bbl = new SVMXC.SFM_WrapperDef.bubble_wp(strmap1);
                                    Resultdata1.add(bbl);
                                }
                            }
                            hdrnamedsrch.RecordTypeId = objectRecType_Map.get('SVMXC__ServiceMax_Processes__c~Named Search');
                            hdrnamedsrch.SVMXC__Rule_Type__c = 'SRCH_LOOKUP_CONFIG';
                            hdrnamedsrch.SVMXC__Source_Object_Name__c = sobjtname;

                            objectDetails.RecordTypeId = objectRecType_Map.get('SVMXC__ServiceMax_Processes__c~Named Search');
                            objectDetails.SVMXC__Source_Object_Name__c = sobjtname;

                            SVMXC__ServiceMax_Config_Data__c obj7 = new SVMXC__ServiceMax_Config_Data__c(SVMXC__Sequence__c=1,  
                            SVMXC__Search_Object_Field_Type__c = 'Bubble',SVMXC__Field_Name__c = nameField);
                            obj7.RecordTypeId=objectRecType_Map.get('SVMXC__ServiceMax_Config_Data__c~Expressions');
                            obj7.SVMXC__Expression_Type__c='SRCH_Object_Fields';
                            fields.add(obj7);
                        
                            CloneprocessNodeSourceObject.add(new SVMXC.SFM_WrapperDef.SFM_NamedSearchInfoDetail(objectDetails,fields));
                            SFM_WrapperDef.SFM_NamedSearchInfo oSFM_Exp1 = new SFM_WrapperDef.SFM_NamedSearchInfo(hdrnamedsrch,CloneprocessNodeSourceObject);
                            NSI1.add(oSFM_Exp1);
                            ResNamedSearch = new SFM_WrapperDef.SFM_Response_NamedSearchInfo(NSI1);
                        }
                    }
                    else
                    {   
                        String nameField;
                        Allobjs = Schema.getGlobalDescribe();
                        ObjectNameAPI = utils.getOriginalAPIName(sobjtname,Allobjs);
                        if(Allobjs.containskey(ObjectNameAPI))
                        {
                            if(Allobjs.get(ObjectNameAPI) == Account.SObjectType)
                                nameField = 'Name';
                            else
                            {   
                                FieldMap = Allobjs.get(ObjectNameAPI).getDescribe().fields.getMap();

                                if(FieldMap.size() > 0)
                                {
                                    for(String s :FieldMap.keyset())
                                    {
                                        Schema.DescribeFieldResult fieldDesc = FieldMap.get(s).getDescribe();
                                        if(fieldDesc.isNameField())
                                        {
                                            nameField = fieldDesc.getName();
                                            break;
                                        }
                                    }
                                }
                            }
                        }
                        if(Keyword != null)
                        {
                            if(ContextVal != null && fldName != null)
                                Query = 'SELECT Id,'+nameField+' FROM '+ sobjtname + ' where ' + nameField +' like \'%'+string.escapeSingleQuotes(Keyword)+'%\''+' AND '+ fldName +'='+'\''+ContextVal+'\''+ ' '+strLimit;
                            else
                                Query = 'SELECT Id,'+nameField+' FROM '+ sobjtname + ' where ' + nameField +' like \'%'+string.escapeSingleQuotes(Keyword)+'%\''+ ' '+strLimit;
                        }
                        else
                        {
                            if(ContextVal != null && fldName != null)
                                Query = 'SELECT Id,'+nameField+' FROM '+ sobjtname + ' where ' + fldName +'='+'\''+ContextVal+'\''+ ' '+strLimit;
                            else
                                Query = 'SELECT Id,'+nameField+' FROM '+ sobjtname+ ' '+strLimit;
                        }
                        system.debug('Query'+Query);
                        system.debug('Resultdata'+Resultdata);
                        Resultdata = database.query(Query);
                        if(Resultdata != null)
                        {
                            for(sObject sobj: Resultdata)
                            {
                                List<SFM_WrapperDef.SFM_StringFieldMap> strmap1 = new List<SFM_WrapperDef.SFM_StringFieldMap>();
                                SFM_WrapperDef.SFM_StringFieldMap strmap2 = new SFM_WrapperDef.SFM_StringFieldMap();
                                strmap2.Key = nameField;
                                strmap2.value = String.valueOf(sobj.get(nameField));
                                strmap2.ftype = 'Result';

                                SFM_WrapperDef.SFM_StringFieldMap strmap3 = new SFM_WrapperDef.SFM_StringFieldMap();
                                strmap3.Key = 'Id';
                                strmap3.value = String.valueOf(sobj.get('Id'));
                                strmap3.ftype = 'Result';


                                strmap1.add(strmap2);
                                strmap1.add(strmap3);
                                SVMXC.SFM_WrapperDef.bubble_wp bbl = new SVMXC.SFM_WrapperDef.bubble_wp(strmap1);
                                Resultdata1.add(bbl);
                           }
                        }
                        hdrnamedsrch.RecordTypeId = objectRecType_Map.get('SVMXC__ServiceMax_Processes__c~Named Search');
                        hdrnamedsrch.SVMXC__Rule_Type__c = 'SRCH_LOOKUP_CONFIG';
                        hdrnamedsrch.SVMXC__Source_Object_Name__c = sobjtname;

                        objectDetails.RecordTypeId = objectRecType_Map.get('SVMXC__ServiceMax_Processes__c~Named Search');
                        objectDetails.SVMXC__Source_Object_Name__c = sobjtname;

                        SVMXC__ServiceMax_Config_Data__c obj7 = new SVMXC__ServiceMax_Config_Data__c(SVMXC__Sequence__c=1,  
                        SVMXC__Search_Object_Field_Type__c = 'Bubble',SVMXC__Field_Name__c = nameField);
                        obj7.RecordTypeId=objectRecType_Map.get('SVMXC__ServiceMax_Config_Data__c~Expressions');
                        obj7.SVMXC__Expression_Type__c='SRCH_Object_Fields';
                        fields.add(obj7);
                        
                        CloneprocessNodeSourceObject.add(new SVMXC.SFM_WrapperDef.SFM_NamedSearchInfoDetail(objectDetails,fields));
                        SFM_WrapperDef.SFM_NamedSearchInfo oSFM_Exp1 = new SFM_WrapperDef.SFM_NamedSearchInfo(hdrnamedsrch,CloneprocessNodeSourceObject);
                        NSI1.add(oSFM_Exp1);
                        ResNamedSearch = new SFM_WrapperDef.SFM_Response_NamedSearchInfo(NSI1);
                    }
                }
            }
        }
        catch (Exception ex)
        {
            LKCD.response.success = false;
            LKCD.response.message = ex.getmessage();
            return LKCD;
        }
        log.logout();
        log.print();
        log.getlog();
        
        LKCD.namesearchinfo = ResNamedSearch;
        system.debug('lastResultdata1'+Resultdata1);
        LKCD.data = Resultdata1;
        return LKCD;
    }
    public String SVMX_getFieldNamesFromList(set<String> fieldList) 
    {
        String fieldNames = '';
        for (String field : fieldList) 
        {
            if (fieldNames.length()>0) 
                fieldNames += ',';
            fieldNames += field;
        }
        return fieldNames;
    }  
}