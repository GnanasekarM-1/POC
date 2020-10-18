public with Sharing class IPRD_IBTree{
    
    public String topLevelIBId ='';
    set<String> lstIBField = new set<String>();
    set<String> lstDateField = new set<String>();
    
    Map<String, Integer> mapFieldSequence =  new Map<String, Integer>();
    map<String, String> mapFieldNameLabel =  new map<String, String> ();        
    
    public String IBID{get; set;}
    public String strErrorMessage{get; set;}
    public String strTreeData{get; set;}
    public String strColumnNames{get; set;}
    public String strColumnLabels{get; set;}
    public boolean isDisplayPopup{get; set;}
    public String strSelectedFields {get; set;}
    public String strCommunityName {get; set;}
    public Boolean hasRecordId {get; set;} //Added for fixing issue 047717

    public String getTAG001() {return System.Label.IPRD004_TAG001;} //IB Fields List';}
    public String getTAG003() {return System.Label.IPRD004_TAG003;} //Add';}
    public String getTAG004() {return System.Label.IPRD004_TAG004;} //Remove';}
    public String getTAG005() {return System.Label.IPRD004_TAG005;} //Available Fields';}
    public String getTAG006() {return System.Label.IPRD004_TAG006;} //Selected Fields';}
    public String getTAG007() {return System.Label.IPRD004_TAG007;} //Save';}
    public String getTAG008() {return System.Label.IPRD004_TAG008;} //Loading...';}
    public String getTAG009() {return System.Label.IPRD004_TAG009;} //Cancel';}
    public String getTAG010() {return System.Label.IPRD004_TAG010;} //Themes:';}
    public String getTAG011() {return System.Label.IPRD004_TAG011;} //Sky Blue';}
    public String getTAG012() {return System.Label.IPRD004_TAG012;} //Blue';}
    public String getTAG013() {return System.Label.IPRD004_TAG013;} //Modern';}
    public String getTAG014() {return System.Label.IPRD004_TAG014;} //Glassy Black';}
    public String getTAG015() {return System.Label.IPRD004_TAG015;} //Light';}
    public String getTAG017() {return System.Label.IPRD004_TAG017;} //Settings';}
    public String getTAG018() {return System.Label.IPRD004_TAG018;} //IB tree doesnot support more than 1000 records';}
    public String getTAG019() {return System.Label.IPRD004_TAG019;} //Installed Product Id is not available';}
    public String getTAG020() {return System.Label.IPRD004_TAG020;} // (GMT)';}
    public String getTAG021() {return System.Label.IPRD004_TAG021;} // You are allowed to select only 10 fields at a time in IB tree.
    public String getTAG022() {return System.Label.IPRD004_TAG022;} // Minimum one field should be present in selected field list.
    public String getTAG023() {return System.Label.IPRD004_TAG023;}
    
    public IPRD_IBTree(ApexPages.StandardController stdController){
        
        isDisplayPopup = false;
        IBID = stdController.getId();
        
        if(String.isNotBlank(IBID)){
        hasRecordId = true; //Added for fixing issue 047717
            getFields();
            if(Site.getPathPrefix() != null)
                strCommunityName = Site.getPathPrefix();
        }
        else {
            hasRecordId = false; //Added for fixing issue 047717
            strErrorMessage = getTAG019();
        }
    }   
    
    public void getFields(){
        
        map<String,Schema.SObjectField> fieldMap = Schema.SObjectType.SVMXC__Installed_Product__c.fields.getMap();
          /****************duplicate Check *******************************************/
        COMM_Utils_V2 objCommUtilV2 = new COMM_Utils_V2();
        fieldMap = objCommUtilV2.removeDuplicateFields(fieldMap);
        /*******************************************************************************/
        for (String key : fieldMap.keySet()){

            Schema.DescribeFieldResult fieldResult = fieldMap.get(key).getDescribe();
            if(!(fieldResult.getName().equalsIgnoreCase('Id') || fieldResult.isNameField())) {
            
                lstIBField.add(fieldResult.getName());
                
                if(fieldResult.getType() == Schema.DisplayType.DATETIME ){
                
                    lstDateField.add(fieldResult.getName());
                    mapFieldNameLabel.put(fieldResult.getName(), fieldResult.getLabel()+ ' ' + getTAG020());
                }
                else{
                    mapFieldNameLabel.put(fieldResult.getName(), fieldResult.getLabel());
                }
            }
        }
    }
    
    public pageReference loadCookie(){

        Boolean isValid=true;
        if(strSelectedFields != null && !strSelectedFields.equals('')){
        
            String tempStr ='';
            Boolean isSequence=false;
            List<String> lstField = strSelectedFields.split(',');            
            try{
                for(String str: lstField){
                    if(isSequence){
                    
                        mapFieldSequence.put(tempStr, Integer.valueOf(str));
                        isSequence = false; 
                    }
                    else{
                    
                       // if(lstIBField.contains(str) == true){ //#change
                        if(lstIBField.contains(str)){
                            tempStr = str;
                            isSequence = true;
                        }
                        else{
                        
                            isValid = false;
                            break;
                        }
                    }                                                   
                }
               
            }
            catch(exception ex){
                isValid = false;
            }
        }
        
        //if(isValid == false || mapFieldSequence.size() == 0) //#change
        if(!isValid || mapFieldSequence.isEmpty())
        {
            mapFieldSequence.put('SVMXC__Product_Name__c', 0);
            mapFieldSequence.put('SVMXC__Serial_Lot_Number__c', 1);
            mapFieldSequence.put('SVMXC__Status__c', 2);
            mapFieldSequence.put('SVMXC__City__c', 3);
            mapFieldSequence.put('SVMXC__Country__c', 4);
            
            strSelectedFields = 'SVMXC__Product_Name__c,0,SVMXC__Serial_Lot_Number__c,1,SVMXC__Status__c,2,SVMXC__City__c,3,SVMXC__Country__c,4';
        }
        onLoad();
        return null;
    }   

    public void onLoad(){
        Map<String, String> referenceFieldNameMap = new Map<String, String> ();    
        Map<String, String> stdObjectFieldMap = new Map<String, String>{'Case' => 'CaseNumber',
                                                                    'Solution' => 'SolutionName',
                                                                    'Task' => 'Subject',
                                                                    'Event' => 'Subject',
                                                                    'Contract' => 'ContractNumber',
                                                                    'OrderItem' => 'OrderItemNumber',
                                                                    'Order' => 'OrderNumber'
                                                                   };    
        map<Integer, String> tempMapFieldSequence =  new map<Integer, String> {};       
        map<Integer, String> mapSequenceFieldName = new map<Integer, String>();
        map<Integer, String> mapSequenceFieldLabel = new map<Integer, String>();
        String strFields = 'Id, Name, SVMXC__Parent__c, SVMXC__Top_Level__c';
        Set<String> picklistSet = new Set<String>();
        Set<String> referenceSet = new Set<String>();
        Map<String, String> referenceFieldMap = new Map<String, String> ();

                                                    

        try
        {
            if(String.isBlank(topLevelIBId)){
                
                List<SVMXC__Installed_Product__c> lstInstalledBase = [Select SVMXC__Top_Level__c From SVMXC__Installed_Product__c where Id =: String.escapeSingleQuotes(IBID) limit 1];
                
                if(lstInstalledBase != null && !lstInstalledBase.isEmpty()){ 

                    if(lstInstalledBase[0].SVMXC__Top_Level__c != null){
                        topLevelIBId = lstInstalledBase[0].SVMXC__Top_Level__c;
                    }
                    else{
                        topLevelIBId = IBID;
                    }
                }
                else{
                
                    strErrorMessage = getTAG019();
                    return;
                }
            }

           
            for(String str: mapFieldSequence.keySet()){
                tempMapFieldSequence.put(mapFieldSequence.get(str), str);
            }
            //Jaysukh : Added below code for defect 040574(Picklist translated value was not displaying in IB tree)
            Map<String, Schema.SObjectField> fieldMap = Schema.SObjectType.SVMXC__Installed_Product__c.fields.getMap();
            /****************duplicate Check *******************************************/
        COMM_Utils_V2 objCommUtilV2 = new COMM_Utils_V2();
        fieldMap = objCommUtilV2.removeDuplicateFields(fieldMap);
        /*******************************************************************************/


            for(Integer ind : tempMapFieldSequence.keySet()){
                Schema.DescribeFieldResult fieldResult = fieldMap.get(tempMapFieldSequence.get(ind)).getDescribe();
                if(fieldResult.getType() == Schema.DisplayType.PICKLIST)
                {
                    //Jaysukh 040574:Added toLabel in query for retrving picklist field translated value based on user language
                    strFields += ',toLabel(' + tempMapFieldSequence.get(ind) +')';
                }
                else if(fieldResult.getType() == Schema.DisplayType.REFERENCE){
                    String fieldAPIName = tempMapFieldSequence.get(ind);
                    String objectName = String.valueOf(fieldMap.get(tempMapFieldSequence.get(ind)).getDescribe().getReferenceTo()[0].getDescribe().getName());                    
                    System.debug('reference##'+objectName);
                    if(fieldAPIName.contains('__c')){
                        fieldAPIName = fieldAPIName.removeEnd('__c')+'__r';
                        referenceFieldMap.put(tempMapFieldSequence.get(ind),fieldAPIName); 
                        if(!stdObjectFieldMap.containsKey(objectName)){
                            fieldAPIName = fieldAPIName+'.Name';
                        }
                        else{
                            fieldAPIName = fieldAPIName+'.'+stdObjectFieldMap.get(objectName);
                            referenceFieldNameMap.put(tempMapFieldSequence.get(ind), stdObjectFieldMap.get(objectName));
                        }
                    }
                    else{
                        fieldAPIName = fieldAPIName.removeEnd('Id')+'.Name';
                        referenceFieldMap.put(tempMapFieldSequence.get(ind),'Owner');
                        System.debug('original '+tempMapFieldSequence.get(ind)+' converted is '+fieldAPIName);
                    }
                    strFields += ',' + tempMapFieldSequence.get(ind);
                    strFields += ',' + fieldAPIName;
                }
                else if(!(tempMapFieldSequence.get(ind).equals('SVMXC__Parent__c') || tempMapFieldSequence.get(ind).equals('SVMXC__Top_Level__c'))){
                    strFields += ',' + tempMapFieldSequence.get(ind);
                }
                mapSequenceFieldName.put(ind, tempMapFieldSequence.get(ind));
                mapSequenceFieldLabel.put(ind, mapFieldNameLabel.get(tempMapFieldSequence.get(ind)));
            }
         
            topLevelIBId = String.escapeSingleQuotes(topLevelIBId);
            List<SVMXC__Installed_Product__c> lstInstalledBase = Database.query('SELECT '+ String.escapeSingleQuotes(strFields) +' from SVMXC__Installed_Product__c where SVMXC__Top_Level__c =: topLevelIBId OR Id =: topLevelIBId');
            
            List<map<String, String>> lstIB = new List<map<String, String>>();
            String q = 'SELECT '+ String.escapeSingleQuotes(strFields) +' from SVMXC__Installed_Product__c where SVMXC__Top_Level__c =: topLevelIBId OR Id =: topLevelIBId';
             for(SVMXC__Installed_Product__c objIB: Database.query('SELECT '+ String.escapeSingleQuotes(strFields) +' from SVMXC__Installed_Product__c where SVMXC__Top_Level__c =: topLevelIBId OR Id =: topLevelIBId')){
                Map<String, Object> fieldsToValue = objIB.getPopulatedFieldsAsMap();
               
                map<String, String> IBRecord = new map<String, String>();
                for(String str: mapFieldSequence.keySet()){
                    if(objIB.get(str) != null){
                        if(lstDateField.contains(str)){
                            IBRecord.put(str, dateTime.valueOf(String.valueOf(objIB.get(str)).replace('^','&#94;')).format());
                        }
                        else if(referenceFieldMap.containsKey(str)){
                            String correnspondingField = referenceFieldMap.get(str);
                            sObject referenceObject = (sObject) fieldsToValue.get(correnspondingField);
                            Map<String, Object> referenceFieldsToValue = referenceObject.getPopulatedFieldsAsMap();
                            String newValue;
                            if(!referenceFieldNameMap.containsKey(str)){
                                newValue = String.valueOf(referenceFieldsToValue.get('Name'));
                            }
                            else{
                                newValue = String.valueOf(referenceFieldsToValue.get(referenceFieldNameMap.get(str)));
                            }
                            IBRecord.put(str, '<a href="/'+objIB.get(str)+'" target="_blank" >'+newValue+'</a>');
                        }
                        else{
                            IBRecord.put(str, String.valueOf(objIB.get(str)).replace('^','&#94;').escapeHtml4());
                        }
                    }
                    else{
                        IBRecord.put(str, '');
                    }
                }
                
                // Check if mapFieldSequence don't contains top level field, add that to IBRecord
                
                if(!mapFieldSequence.containsKey('SVMXC__Top_Level__c')){
                    if(String.isNotBlank(String.valueOf(objIB.get('SVMXC__Top_Level__c')))){
                        IBRecord.put('SVMXC__Top_Level__c', String.valueOf(objIB.get('SVMXC__Top_Level__c')).replace('^','&#94;').escapeHtml4());
                    }
                }
                
                IBRecord.put('Id', String.valueOf(objIB.get('Id')).escapeHtml4());
                
                if(objIB.get('SVMXC__Parent__c') != null){
                    IBRecord.put('SVMXC__Parent__c', String.valueOf(objIB.get('SVMXC__Parent__c')).escapeHtml4());
                }
                else{ 
                    IBRecord.put('SVMXC__Parent__c', '');
                }
                
                if(objIB.get('Name') != null){
                    IBRecord.put('Name', String.valueOf(objIB.get('Name')).escapeHtml4());
                }
                else{ 
                    IBRecord.put('Name', '');
                }
                lstIB.add(IBRecord);
                
                
            }
            strTreeData = JSON.serialize(lstIB);
            strColumnNames = JSON.serialize(mapSequenceFieldName);
            strColumnLabels = JSON.serialize(mapSequenceFieldLabel);
        }
        catch (Exception ex)
        {
            System.debug('error on '+ex.getLineNumber()) ;
            ApexPages.addMessage(new ApexPages.Message ( ApexPages.Severity.ERROR,ex.getMessage()));   
            return;
        }
    }

    public List<String> SIBFields = new List<String>();
    public List<String> AIBFields = new List<String>();
    
    public List<SelectOption> AvailFields = new List<SelectOption>();
    public List<SelectOption> getAvailFields(){
      return AvailFields;
    }  
    
    public List<SelectOption> SelectedFields = new List<SelectOption>();
    public List<SelectOption> getSelectedFields(){
      return SelectedFields;
    }  
    
    public String[] getOptions(){ 
        return Options;
    }

    public void setOptions(String[] Options){
        this.Options= Options;
    }
    
    public List<String> AFields = new List<String>(); //Base
    public List<String> getAFields(){   return this.AFields; }  
    public void setAFields(String[] s){ this.AFields =s; } 

    public List<String> SFields = new List<String>();  //To
    public List<String> getSFields(){  return this.SFields; }  
    public void setSFields(String[] s){ this.SFields =s; } 
    
    String[] Options= new String[]{'Status','Serial/Lot Number'};

    public PageReference ShowPopUp()
    {
        isDisplayPopup = true;
        mapFieldNamesFromList(lstIBField);           
        return null;
    }
    
    public PageReference SaveListPP(){
    
        strSelectedFields = '';
        for(SelectOption s: SelectedFields){
        
            if(strSelectedFields != ''){
                strSelectedFields += ',';   
            }
            strSelectedFields += s.getValue()+ ',' + mapFieldSequence.get(s.getValue());
        }

        onload();
        isDisplayPopup =false;
        
        return null;
    }
     
    public PageReference ClosePP(){
    
        isDisplayPopup =false;
        return null;
    }

    public void mapFieldNamesFromList(set<String> fieldList) 
    { 
        AvailFields.clear();
        AIBFields.clear();
        SelectedFields.clear();
        SIBFields.clear();

        Map<Integer, String> tempList_Sequence =  new Map<Integer, String> {};   
        for(String s: mapFieldSequence.keySet())
            tempList_Sequence.put(mapFieldSequence.get(s),s);
        
        for(String field : fieldList) 
        {
            if(mapFieldNameLabel.get(field)!=NULL)
            {
                if(!mapFieldSequence.containsKey(field))
                {
                    AvailFields.add(new SelectOption(field,mapFieldNameLabel.get(field)));
                    AIBFields.add(field);
                }
            }
        }

            for(integer i=0;i<tempList_Sequence.size();i++)
            {
                if(mapFieldNameLabel.containsKey(tempList_Sequence.get(i))){
                    SelectedFields.add(new SelectOption(tempList_Sequence.get(i),mapFieldNameLabel.get(tempList_Sequence.get(i))));
                    SIBFields.add(tempList_Sequence.get(i));
                }
            }
        AvailFields=sortingSelectAvailIBOption(AvailFields);
    } 
    
    public PageReference OnAddFields()
    {
        List<Integer> selectedLines = new List<Integer>();
        Integer i;
        //if(SelectedFields.size()+AFields.size() <= 10){
        for(String fs: AFields)
        {
            for(i = 0; i < AIBFields.size();i++)
            {
                    if(fs == AIBFields[i])
                    {
                        selectedLines.add(i);
                        SelectedFields.add(AvailFields.get(i));
                        SIBFields.add(AIBFields[i]);
                        mapFieldSequence.put(AIBFields[i],SelectedFields.size()-1);
                    }
            }
        }
        selectedLines.sort();
        for (i=selectedLines.size()-1;i>=0;i--)
        {
            AvailFields.remove(selectedLines.get(i));
            AIBFields.remove(selectedLines.get(i));
        }
       // }
       // else{
            //Error message when more than 10 fields are there
            //ApexPages.addMessage(new ApexPages.Message ( ApexPages.Severity.ERROR, getTAG021() )); 
       // }
            //SelectedFields=sortingSelectSelectedIBOption(SelectedFields);
        return null;
    }
    /*******************************************************************************************************/

    public PageReference onRemFields()
    {
        List<Integer> selectedLines = new List<Integer>();
        Integer i;
       
        if(SelectedFields.size() != SFields.size())
        {
        for(String ps: SFields)
        {
                for(i = 0; i < SIBFields.size();i++)
                {
                     if(ps == SIBFields[i])
                     {
                         selectedLines.add(i);
                         AvailFields.add(SelectedFields.get(i));
                         AIBFields.add(SIBFields[i]);  
                         ReorderSequence(SIBFields[i]);                  
                     }  
                }
            }
            selectedLines.sort();
            for (i=selectedLines.size()-1;i>=0;i--)
            {
                SelectedFields.remove(selectedLines.get(i));
                SIBFields.remove(selectedLines.get(i));
            }
        }
        else
        {
            //Error message when we try to remove all selected fields
            ApexPages.addMessage(new ApexPages.Message ( ApexPages.Severity.ERROR, getTAG022() ));  
        }
            AvailFields=sortingSelectAvailIBOption(AvailFields);
        return null;
    }

    public void ReorderSequence(String St)
    {
        Integer Pos = mapFieldSequence.get(St);
        for(String s:mapFieldSequence.keySet())
        { 
                if(mapFieldSequence.get(s)>Pos)
                mapFieldSequence.put(s, mapFieldSequence.get(s)-1);
        }
        mapFieldSequence.remove(St);
    }

        //----------------------------------Sorting Function-----------------------------------------------
    public List<SelectOption> sortingSelectAvailIBOption(List<SelectOption> so){
        SelectOption tempObj; 
        String tempLst;              
        Integer size = so.size();
        Integer i,j;
        for(i=0;i<size;i++){
            for(j=i+1;j<size;j++){
                Integer result=so[i].getLabel().compareTo(so[j].getLabel());
                if((so[i].getLabel().toUpperCase().compareTo(so[j].getLabel().toUpperCase()))>0){
                    tempObj = so[j];
                    so[j] = so[i];
                    so[i] = tempObj;
                    tempLst = AIBFields[j];
                    AIBFields[j] = AIBFields[i];
                    AIBFields[i] = tempLst;
                }
            }
        }
        return so;
    }
        
 
    public void Top()
    {
        integer IntSelIndex;
        SVMXC__ServiceMax_Processes__c temp;
        for(integer j=SelectedFields.size()-1;j>0;j--)
        {
            for(integer i=SFields.size()-1;i>=0;i--)
            {
                if(SFields[i] == SelectedFields[j].getValue())
                {
                    IntSelIndex = j;
                    
                    shuffle(IntSelIndex);     
                }
            }
        }
        sortList_Sequence();
        RearrangeList();        
    }
    
    public void shuffle(integer IntSelIndex)
    {
        SelectOption temp;
        
          temp = SelectedFields[IntSelIndex];
          for(integer j=IntSelIndex;j>0;j--)
          {
            SelectedFields[j] = SelectedFields[j-1];
          }
          SelectedFields[0] = temp;
        
        
    }  
   
    public void sortList_Sequence()
    {   try
        {
            mapFieldSequence.clear();
            for(integer ival=0;ival<SelectedFields.size();ival++)
                mapFieldSequence.put(SelectedFields[ival].getValue(),ival);
        }catch(Exception ex){}
    }
    
    

 
    public void UP()
    {
        SelectOption temp;
        integer selIndex;
   
        for(integer j=0;j<SelectedFields.size();j++)
        {
            for(integer i=0;i<SFields.size();i++)
            {
                if(SFields[i]==SelectedFields[0].getValue())
                {
                   SelectedFields[j] = SelectedFields[j];
                    break;
                }
                else if(SFields[i]==SelectedFields[j].getValue())
                {
                    temp = SelectedFields[j]; 
                    SelectedFields[j] = SelectedFields[j-1];
                    SelectedFields[j-1]=temp;    
                    
                }
            }
        }
        sortList_Sequence();  
        RearrangeList();
    }


    public void Down()
    {
        SelectOption temp;
        
        for(integer j=SelectedFields.size()-1;j>=0;j--)
        {
            for(integer i=0;i<SFields.size();i++)
            {
                if(SFields[i]==SelectedFields[SelectedFields.size()-1].getvalue())
                    SelectedFields[j] = SelectedFields[j];
                else if(SFields[i]==SelectedFields[j].getvalue())
                {
                    temp = SelectedFields[j]; 
                    SelectedFields[j] = SelectedFields[j+1];
                    SelectedFields[j+1]=temp;
                }  
            }
        }
        sortList_Sequence();
        RearrangeList();
    }

    public void Bottom()
    {
        SelectOption temp;
        
        for(integer j=0;j<SelectedFields.size()-1;j++)
        {
            for(integer i=0;i<SFields.size();i++)
            {
                if(SFields[i] == SelectedFields[j].getvalue())
                {                                       
                    temp = SelectedFields[j];
                    for(integer k=j;k<SelectedFields.size()-1;k++)
                        SelectedFields[k] = SelectedFields[k+1];
                    
                    SelectedFields[SelectedFields.size()-1] = temp;
                }
            }
        }
        sortList_Sequence();
        RearrangeList();
    }

    public void SwapSelectedList(Integer i, Integer j){
        try{
            SelectOption temp;
            if(SelectedFields[i] != NULL && SelectedFields[j] != NULL){
                temp = SelectedFields[i];
                SelectedFields[i] = SelectedFields[j];
                SelectedFields[j] = temp;
                mapFieldSequence.put(SelectedFields[j].getValue(),j);
                mapFieldSequence.put(SelectedFields[i].getValue(),i);
            }
        }catch(Exception ex){}
    }

    public void RearrangeList()
    {
       
        Map<Integer, String> tempList_Sequence =  new Map<Integer, String> {};
        SIBFields.clear();
        for(String s: mapFieldSequence.keySet())
            tempList_Sequence.put(mapFieldSequence.get(s),s);                
        if(tempList_Sequence != null && tempList_Sequence.size() > 0)
        { 
          for(integer s=0;s<tempList_Sequence.size();s++)
            SIBFields.add(tempList_Sequence.get(s));
        }
    }
}