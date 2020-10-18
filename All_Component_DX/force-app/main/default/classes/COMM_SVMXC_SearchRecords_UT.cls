@isTest(seeAllData=true)
Private with sharing class COMM_SVMXC_SearchRecords_UT {
static testMethod void COMM_SVMXC_SearchRecords_UT()
    {
        SVMXC.COMM_SVMXC_SearchRecords searchRec = new SVMXC.COMM_SVMXC_SearchRecords();
        
        searchRec.ObjName = 'SVMXC__Service_Order__c';
            searchRec.getObjName();
            
        searchRec.strSearch = '';
            searchRec.getstrSearch();
            searchRec.setstrSearch(searchRec.strSearch );
            
        searchRec.strNameField = 'Name';
            searchRec.getstrNameField() ;
            searchRec.setstrNameField(searchRec.strNameField );
            
        searchRec.isUserSearch = false;
            searchRec.getisUserSearch();
        
        searchRec.ExpressionType ='eq';
            searchRec.getExpressionType();
            

        searchRec.getlstSObj();
        
        ////searchRec.COMM_SVMXDC_SearchRecords('Name', '', '', 'eq');
        
        searchRec.Do_Search();
        searchRec.getDate();
        
        SVMXC.COMM_SVMXC_SearchRecords.wraper searchRecWrap = new SVMXC.COMM_SVMXC_SearchRecords.wraper();
            searchRecWrap.sObj =  new SVMXC__Service_Order__c();  
            searchRecWrap.getsObj();
            searchRecWrap.getRecordName();
            searchRecWrap.setsObj(searchRecWrap.sObj);
            searchRecWrap.getRecordID();
            
        //// searchRecWrap(searchRecWrap.sObj,'RecName','RecId');      
        
        SVMXC.COMM_SVMXC_SearchRecords.wraperDate searchRecWrapDt = new SVMXC.COMM_SVMXC_SearchRecords.wraperDate();
            searchRecWrapDt.isSelect = true;
                searchRecWrapDt.getisSelect();
                searchRecWrapDt.setisSelect(searchRecWrapDt.isSelect );
                
            searchRecWrapDt.isDays = false;
                searchRecWrapDt.getisDays();
                
            searchRecWrapDt.isDate = false;
                searchRecWrapDt.getisDate();
                
            searchRecWrapDt.dateOperater = '';
                searchRecWrapDt.getdateOperater();
                searchRecWrapDt.getfulldateOperater();
                
           searchRecWrapDt.dateOperaterLabel ='';
                searchRecWrapDt.getdateOperaterLabel();
                
                searchRecWrapDt.getsDate();
                searchRecWrapDt.setsDate(null );
                
            searchRecWrapDt.days = 2;
                searchRecWrapDt.getdays();
                searchRecWrapDt.setdays(searchRecWrapDt.days );
        Contact c = new Contact( LastName= 'test');
        insert c;
        
        SVMXC.COMM_SVMXC_SearchRecords searchRec2 = new SVMXC.COMM_SVMXC_SearchRecords('Contact', 'test', 'Name', 'CRITERIA');
        searchRec2.getlstDateOption();
        searchRec2.Do_Search();
        searchRec2.lstDateOption[0].isSelect = true;
        system.assert(searchRec2.getDate()!=null);
        searchRec2.getDate();
        searchRec2.lstDateOption[1].isSelect = true;
        searchRec2.getDate();
        searchRec2.lstDateOption[0].isSelect = false;
        searchRec2.lstDateOption[1].isSelect = false;
        for(SVMXC.COMM_SVMXC_SearchRecords.wraperDate owraperDate :searchRec2.lstDateOption)
        {
            owraperDate.isSelect = true;
            searchRec2.getDate();
            owraperDate.isSelect = false;
        }
        
        SVMXC.COMM_SVMXC_SearchRecords searchRec3 = new SVMXC.COMM_SVMXC_SearchRecords('User', 'test', 'Name', 'test');
        searchRec3.getlstDateOption();
        searchRec3.setlstDateOption(new list<SVMXC.COMM_SVMXC_SearchRecords.wraperDate>());
        system.assert(searchRec.getTAG022()!=null,'TAG022 assertion failed');
        system.assert(searchRec.getTAG023()!=null,'TAG023 assertion failed');
        system.assert(searchRec.getTAG024()!=null,'TAG024 assertion failed');
        system.assert(searchRec.getTAG025()!=null,'TAG025 assertion failed');
        system.assert(searchRec.getTAG026()!=null,'TAG026 assertion failed');
        system.assert(searchRec.getTAG027()!=null,'TAG027 assertion failed');
        system.assert(searchRec.getTAG028()!=null,'TAG028 assertion failed');
        system.assert(searchRec.getTAG029()!=null,'TAG029 assertion failed');
        system.assert(searchRec.getTAG030()!=null,'TAG030 assertion failed');
        system.assert(searchRec.getTAG031()!=null,'TAG031 assertion failed');
        system.assert(searchRec.getTAG032()!=null,'TAG032 assertion failed');
        system.assert(searchRec.getTAG033()!=null,'TAG033 assertion failed');
        system.assert(searchRec.getTAG034()!=null,'TAG034 assertion failed');
        system.assert(searchRec.getTAG035()!=null,'TAG035 assertion failed');
        system.assert(searchRec.getTAG036()!=null,'TAG036 assertion failed');
        system.assert(searchRec.getTAG037()!=null,'TAG037 assertion failed');
        system.assert(searchRec.getTAG038()!=null,'TAG038 assertion failed');
        //searchRec.svmxTagList.clear();
        system.assert(searchRec.getTAG022()!=null,'TAG022 assertion failed');
        system.assert(searchRec.getTAG023()!=null,'TAG023 assertion failed');
        system.assert(searchRec.getTAG024()!=null,'TAG024 assertion failed');
        system.assert(searchRec.getTAG025()!=null,'TAG025 assertion failed');
        system.assert(searchRec.getTAG026()!=null,'TAG026 assertion failed');
        system.assert(searchRec.getTAG027()!=null,'TAG027 assertion failed');
        system.assert(searchRec.getTAG028()!=null,'TAG028 assertion failed');
        system.assert(searchRec.getTAG029()!=null,'TAG029 assertion failed');
        system.assert(searchRec.getTAG030()!=null,'TAG030 assertion failed');
        system.assert(searchRec.getTAG031()!=null,'TAG031 assertion failed');
        system.assert(searchRec.getTAG032()!=null,'TAG032 assertion failed');
        system.assert(searchRec.getTAG033()!=null,'TAG033 assertion failed');
        system.assert(searchRec.getTAG034()!=null,'TAG034 assertion failed');
        system.assert(searchRec.getTAG035()!=null,'TAG035 assertion failed');
        system.assert(searchRec.getTAG036()!=null,'TAG036 assertion failed');
        system.assert(searchRec.getTAG037()!=null,'TAG037 assertion failed');
        system.assert(searchRec.getTAG038()!=null,'TAG038 assertion failed');
    }
}