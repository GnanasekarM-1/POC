public with sharing class COMM_SVMXC_SearchRecords 
{
    public string ObjName = system.currentPageReference().getParameters().get('ObjName');
        public string getObjName(){return this.ObjName;}
    public string ObjLable;
        public string getObjLable(){return this.ObjLable;}
        
    public string strSearch = system.currentPageReference().getParameters().get('Search');
        public string getstrSearch() {return this.strSearch;}
        public void setstrSearch(string str) {this.strSearch = str;}
        
    public string strNameField = system.currentPageReference().getParameters().get('NameField');
        public string getstrNameField() {return this.strNameField;}
        public void setstrNameField(string str) {this.strNameField = str;}
        
    public boolean isUserSearch = false;
        public boolean getisUserSearch() {return isUserSearch;}
    
    public string ExpressionType;
        public string getExpressionType(){return this.ExpressionType;}
        
    public list<wraper> lstSObj = new list<Wraper>();
        public list<wraper> getlstSObj(){return this.lstSObj;}
        
    //SVMXC.COMM_Utils_ManageTags commUtil = new SVMXC.COMM_Utils_ManageTags();
    //public Map<String, String> svmxTagList = commUtil.SVMX_getTagList('COMM002');
    
    public String getHLPURL() {return System.Label.COMM002_HLPURL;} //HLPURL
    public String getTAG022() {return System.Label.COMM002_TAG022;}
    public String getTAG023() {return System.Label.COMM002_TAG023;} 
    public String getTAG024() {return System.Label.COMM002_TAG024;}//Please select some record.
    public String getTAG025() {return System.Label.COMM002_TAG025;} 
    public String getTAG026() {return System.Label.COMM002_TAG026;} 
    public String getTAG027() {return System.Label.COMM002_TAG027;} 
    public String getTAG028() {return System.Label.COMM002_TAG028;} 
    public String getTAG029() {return System.Label.COMM002_TAG029;} 
    public String getTAG030() {return System.Label.COMM002_TAG030;} 
    public String getTAG031() {return System.Label.COMM002_TAG005;} 
    public String getTAG032() {return System.Label.COMM002_TAG032;} 
    public String getTAG033() {return System.Label.COMM002_TAG033;} 
    public String getTAG034() {return System.Label.COMM002_TAG034;} 
    public String getTAG035() {return System.Label.COMM002_TAG035;} 
    public String getTAG036() {return System.Label.COMM002_TAG004;} 
    public String getTAG037() {return System.Label.COMM002_TAG037;}    
    public String getTAG038() {return System.Label.COMM002_TAG038;}
    public String getTAG039() {return System.Label.COMM002_TAG039;}
    public String getTAG040() {return System.Label.COMM002_TAG040;}
    public String getTAG041() {return System.Label.COMM002_TAG041;}
    public transient Map<String, Schema.SObjectType> allobjs = Schema.getGlobalDescribe(); 

    public COMM_SVMXC_SearchRecords()
    {
        
    }
    public COMM_SVMXC_SearchRecords(string strname, string sSearch, string strfield, string strExpressionType)
    {
    
        ObjName = strname;
        if(ObjName != null && ObjName.toUpperCase() == 'USER')
            isUserSearch = true;
        if(allobjs.ContainsKey(ObjName))
        {
            Schema.DescribeSObjectResult D = allobjs.get(ObjName).getDescribe();
            ObjLable = D.getLabel();
        }
        strSearch = sSearch;
        strNameField = strfield;
        ExpressionType = strExpressionType;
        //
        if(ObjName != null && ObjName.length() > 0 && strSearch != null && strSearch.length() > 0 && strNameField != null && strNameField.length() > 0)
        {
            string strSearchCriteria = '';
            if(strSearch.contains(','))
            {
                String[] multValues = strSearch.split(',');
                for (String v : multValues) 
                {
                    if(strSearchCriteria.length() > 0)
                        strSearchCriteria += ' OR ' + string.escapeSingleQuotes(strNameField) + ' like \'%' + string.escapeSingleQuotes(v.trim()) + '%\'';
                    else
                        strSearchCriteria = ' ' + string.escapeSingleQuotes(strNameField) + ' like \'%' + string.escapeSingleQuotes(v.trim()) + '%\'';
                }
            }
            else 
                strSearchCriteria = ' ' + string.escapeSingleQuotes(strNameField) + ' like \'%' + string.escapeSingleQuotes(strSearch) + '%\'';
            list<sObject> lst = database.query('select ID, ' + string.escapeSingleQuotes(strNameField) + ' from '+ string.escapeSingleQuotes(ObjName) +' where ' + strSearchCriteria);
            if(lst != null & lst.size() > 0)
            {
                for(sObject o : lst)
                {
                    lstSObj.add( new wraper(o, (string)o.get('id'), (string)o.get(strNameField)));
                }
            }
            else
                lstSObj.clear();
        }
    }
    public void Do_Search()
    {
        lstSObj.clear();
        if(ObjName != null && ObjName.length() > 0 && strNameField != null && strNameField.length() > 0)
        {
            if(strSearch != null && strSearch.length() > 0)
            {
                string strSearchCriteria = '';
                if(strSearch.contains(','))
                {
                    String[] multValues = strSearch.split(',');
                    for (String v : multValues) 
                    {
                        if(strSearchCriteria.length() > 0)
                            strSearchCriteria += ' OR ' + string.escapeSingleQuotes(strNameField) + ' like \'%' + string.escapeSingleQuotes(v.trim()) + '%\'';
                        else
                            strSearchCriteria = ' ' + string.escapeSingleQuotes(strNameField) + ' like \'%' + string.escapeSingleQuotes(v.trim()) + '%\'';
                    }   
                }
                else 
                    strSearchCriteria = ' ' + string.escapeSingleQuotes(strNameField) + ' like \'%' + string.escapeSingleQuotes(strSearch) + '%\'';
                list<sObject> lst = database.query('select ID, ' + string.escapeSingleQuotes(strNameField) + ' from '+ string.escapeSingleQuotes(ObjName) +' where ' + strSearchCriteria);
                if(lst != null && lst.size() > 0)
                {
                    for(sObject o : lst)
                    {
                        lstSObj.add( new wraper(o, (string)o.get('id'), (string)o.get(strNameField)));
                    }
                }
                else 
                {
                    lstSObj.clear();
                    apexpages.addMessage( new apexpages.Message( ApexPages.severity.ERROR, getTAG022()));
                }
            }
            else 
                apexpages.addMessage( new apexpages.Message( ApexPages.severity.ERROR, getTAG023()));
        }
    }
    public string getselectedID()
    {
        string str = '';
        boolean isAnySelected = false;
        for(wraper w :lstSObj)
        {
            if(w.IsSelected)
            {
                if(str == null || str.length() == 0)
                    str = w.RecordID;
                else
                    str += ', ' + w.RecordID;
                isAnySelected = true;
            }
        }
        if(!isAnySelected)
        {
            apexpages.addMessage( new apexpages.Message( ApexPages.severity.ERROR, getTAG024()));
            return null;
        }
        return str;
    }
    public string getselectedLabel()
    {
        string str = '';
        for(wraper w :lstSObj)
        {
            if(w.IsSelected)
            {
                if(str == null || str.length() == 0)
                    str = w.RecordName;
                else
                    str += ', ' + w.RecordName;
            }
        }
        return str;
    }
    public Class wraper
    {
        public boolean IsSelected = false;
            public boolean getIsSelected(){return this.IsSelected;}
            public void setIsSelected(boolean b){this.IsSelected = b;}
        public sObject sObj;
            public sObject getsObj(){return this.sObj;}
            public void setsObj(sObject o){this.sObj = o;}
        public string RecordName;
            public string getRecordName(){return this.RecordName;}
        public string RecordID;
            public string getRecordID(){return this.RecordID;}
        
        public wraper(sObject o, string strID, string strName)
        {
            sObj = o;
            this.RecordName = strName;
            this.RecordID = strID;
        }
        //Constructor
         public wraper()        {        }
    }
    public string getDate()
    {
        integer i = 0;
        string strDate = '';
        wraperDate w;
        for(wraperDate w2 :lstDateOption)
        {
            if(w2.isSelect)
            {
                i += 1;
                w = w2;
            }
        }
        if(i > 1)
            apexpages.addMessage( new apexpages.Message( ApexPages.severity.ERROR, getTAG039()));
        else if(i == 0)
            apexpages.addMessage( new apexpages.Message( ApexPages.severity.ERROR, getTAG040()));
        else if(i == 1 && w != null)
        {
            if(w.isSelect && !w.isDate )
            {
                if(strDate.length() > 0)
                    strDate += ', ';
                strDate += w.getfulldateOperater();
            }
            else if(w.isSelect && w.isDate )
            {
                if(strDate.length() > 0)
                    strDate += ', ';
                strDate += w.sDate;
            }
            return strDate;
        }
        return null;
    }
    public Class wraperDate
    {
        public wraperDate()
        {
            
        }
         
        public boolean isSelect;
            public boolean getisSelect(){return this.isSelect;}
            public void setisSelect(boolean b){this.isSelect = b;}
            
        public boolean isDays = false;
            public boolean getisDays(){return this.isDays;}
            
        public boolean isDate = false;
            public boolean getisDate(){return this.isDate;}
            
        public string dateOperater;
            public string getdateOperater(){return this.dateOperater;}
            public string getfulldateOperater(){ if(isDays) return this.dateOperater + ':' + string.valueOf(days); else return this.dateOperater;}
            
       public string dateOperaterLabel;
            public string getdateOperaterLabel(){return this.dateOperaterLabel;}
            
        public string sDate;
            public string getsDate(){return this.sDate;}
            public void setsDate(string s){this.sDate = s;}
            
        public Integer days = 0;
            public Integer getdays(){return this.days;}
            public void setdays(Integer i){this.days = i;}
        public wraperDate(boolean bSelect, boolean bDays, boolean bDate, string strOperater, string OperaterLabel, string strdate, integer idays)
        {
            isSelect = bSelect;
            isDays = bDays;
            isDate = bDate;
            dateOperater = strOperater;
            dateOperaterLabel = OperaterLabel;
            sDate = strdate;
            days = idays;
        }
    }
    public list<wraperDate> lstDateOption = new list<wraperDate>();
        public list<wraperDate> getlstDateOption()
        {
            if(lstDateOption.size() == 0)
            {
                lstDateOption.add(new wraperDate(false, false, false, 'TODAY', getTAG041(), '', null ));
                lstDateOption.add(new wraperDate(false, false, false, 'TOMORROW', getTAG025(), '', null ));
                lstDateOption.add(new wraperDate(false, false, false, 'YESTERDAY', getTAG026(), '', null ));
                
                if(ExpressionType == 'CRITERIA')
                {
                    lstDateOption.add(new wraperDate(false, false, false, 'THIS_WEEK', getTAG027(), '', null ));
                    lstDateOption.add(new wraperDate(false, false, false, 'THIS_MONTH', getTAG028(), '', null ));
                    
                    lstDateOption.add(new wraperDate(false, false, false, 'NEXT_WEEK', getTAG029(), '', null ));
                    lstDateOption.add(new wraperDate(false, false, false, 'NEXT_MONTH', getTAG030(), '', null ));
                    lstDateOption.add(new wraperDate(false, false, false, 'NEXT_90_DAYS', getTAG031(), '', null ));
        
                    lstDateOption.add(new wraperDate(false, false, false, 'LAST_WEEK', getTAG032(), '', null ));
                    lstDateOption.add(new wraperDate(false, false, false, 'LAST_MONTH', getTAG033(), '', null ));
                    lstDateOption.add(new wraperDate(false, false, false, 'LAST_90_DAYS', getTAG034(), '', null ));
        
                    lstDateOption.add(new wraperDate(false, true, false, 'NEXT_N_DAYS', getTAG035(), '', null ));         
                    lstDateOption.add(new wraperDate(false, true, false, 'LAST_N_DAYS', getTAG036(), '', null ));
                    
                }
                else
                {
                    lstDateOption.add(new wraperDate(false, true, false, 'NEXT_N_DAYS', getTAG037(), '', null ));           
                    lstDateOption.add(new wraperDate(false, true, false, 'LAST_N_DAYS', getTAG038(), '', null ));
                }
                //lstDateOption.add(new wraperDate(false, false, true, 'DATE', 'Date', '', null ));
            }
            return this.lstDateOption;
        }
        public void setlstDateOption(list<wraperDate> w) {this.lstDateOption = w;}
}