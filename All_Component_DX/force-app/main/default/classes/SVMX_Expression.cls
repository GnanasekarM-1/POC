public with sharing class SVMX_Expression{


//Global describe for all objects is done here
    MAP<String,Schema.SObjectType> allObjs = Schema.getGlobalDescribe();
//Expression detail RecordType declaration
    RecordType ExpressionHeader_Rtype;
    RecordType ExpressionsDetail_Rtype;
public Integer ExpDetailSize = 0;
public Integer getExpDetailSize(){ return ExpDetailSize;}

//constructor
    public SVMX_Expression(){
        //Query for necessary RecordTypes
        String UrlReq= System.currentPageReference().getParameters().get('newid');
        //ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Confirm,'Hello world: '+UrlReq ,''));
        ExpressionHeader_Rtype = [select Id from RecordType where Name=:'SVMX Rule'and SobjectType=:'SVMXC__ServiceMax_Processes__c' Limit 1]; //SDL-SVMX-FLS-NOT-ENFORCED-META-DATA
        ExpressionsDetail_Rtype = [select Id from RecordType where Name=:'Expressions'and SobjectType=:'SVMXC__ServiceMax_Config_Data__c' Limit 1]; //SDL-SVMX-FLS-NOT-ENFORCED-META-DATA
        HdrExpressions.lstExpressions.clear();
        //ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Confirm,'Hello world1: '+objName ,''));
    }

// Source object name getter setter
    public String objName;
    public String getobjName()
    {
        return objName;
    }
    public void setobjName(String objName)
    {
        this.objName = objName;
    }

//Sfm utils instantiated and used to get the real object name
    SFM_Utils ObjName_util = new SFM_Utils();

//Field List for selected object
public List<SelectOption> Hdrfldlist = new List<SelectOption>();
public List<SelectOption> getHdrfldlist(){return Hdrfldlist;}

//Selected Object Api label
    public COMM_SVMXC_Search_Expressions HdrExpressions = new COMM_SVMXC_Search_Expressions(2);//Initialised, since it is required in 
    public String ObjLabel;
    public String getObjLabel(){
        if( objName != null && objName != '' )
        {
            String APIName = ObjName_util.getOriginalAPIName(objName, allObjs);
            if( APIName != null && allObjs.get(APIName) != null ) 
            {
                //populate the field list for the selected object
                Hdrfldlist.clear();
                Hdrfldlist.add(new SelectOption('None','--None--'));
                WORD_SetupDispatch_Methods DispMethods = new WORD_SetupDispatch_Methods();
                DispMethods.RetriveField(objName, Hdrfldlist, HdrExpressions.mapFieldDispType, HdrExpressions.FieldApiLable);
                return getTAG007() +' ' + allObjs.get(APIName).getDescribe().getlabel();
            }
            else
                return getTAG007();
        }
        else
            return getTAG007();
    }
    public void setObjLabel(String val){
        this.ObjLabel = val;
    }
//Selected Header Expression id
    public String SelectedExpId;
    public String getSelectedExpId(){
        return SelectedExpId;
    }
    public void setSelectedExpId(String val){
            this.SelectedExpId = val;
    }
//Sequence no. of the record currently dealing with - Related methods
    public string SelectedIndex;
    public string getSelectedIndex (){return this.SelectedIndex;}
    public void setSelectedIndex (string str){this.SelectedIndex = str;}

/* //Tag utility declaration
    public COMM_SVMXC_Utils3 TagUtility = new COMM_SVMXC_Utils3('CONF010');
    public COMM_SVMXC_Utils3 getTagUtility(){return this.TagUtility;} */

//Boolean to Disable fields
    public Boolean disableValue = false;
    public Boolean getDisableValue(){return disableValue;}

//Method which checks if string is valid or not
public boolean IsValidString(String str)
{
    if (str != null && str != '' && str.length() > 0)
        return true;
    else
        return false;
}

//Method which displays exception on page as required
public void AddException(String strErrorMessage)
{
    if(isValidString(strErrorMessage))
        ApexPages.addMessage(new ApexPages.Message ( ApexPages.Severity.ERROR, strErrorMessage));
    else
        ApexPages.addMessage(new ApexPages.Message ( ApexPages.Severity.ERROR, ''));
}

//Component mode declaration and related methods
    public String compMode;
    public String getcompMode(){
        return compMode;
    }
    public void setcompMode(String val){
        this.compMode = val;
    }

//Methods to add and delete rows of Expression details
public void HdrADDRow()
{
    try
    {
        SVMXC__ServiceMax_Config_Data__c NewExpDetailRec = new SVMXC__ServiceMax_Config_Data__c( RecordTypeId = ExpressionsDetail_Rtype.Id, SVMXC__Sequence__c = Integer.valueOf( expwrapperObj.ExpDetailLst.size() + 1 ) );
        Map_SequenceNumRec.put( Math.Round(Integer.valueOf( expwrapperObj.ExpDetailLst.size() + 1 )), NewExpDetailRec );
        expwrapperObj.ExpDetailLst.add( NewExpDetailRec );
        if(expwrapperObj.ExpDetailLst != null)
            ExpDetailSize = expwrapperObj.ExpDetailLst.size();
        else
            ExpDetailSize = 0;
    }
    catch(exception ex)
    {
        AddException(ex.getMessage());
    }
}
Map<Integer, SVMXC__ServiceMax_Config_Data__c> TempMap_SequenceNumRec = new Map<Integer, SVMXC__ServiceMax_Config_Data__c>();
public void HdrDeleteRow()
{ 
    try
    {
        system.debug('zzzzzzzzzz'+SelectedIndex);
        Map<Integer, SVMXC__ServiceMax_Config_Data__c> TempMap_SequenceNumRec = new Map<Integer, SVMXC__ServiceMax_Config_Data__c>();
        List<SVMXC__ServiceMax_Config_Data__c> Temp_ExpDetailsLst = new List<SVMXC__ServiceMax_Config_Data__c>();
        Integer SeqNumToSubtract = 0;
        
        for( integer i=0; i < expwrapperObj.ExpDetailLst.size(); i++ )
        {
            system.debug('aaaa' + i+ '  '+  SeqNumToSubtract + ' cccc ' + expwrapperObj.ExpDetailLst[i] + 'dddd' + SelectedIndex);
            system.debug('xyz : ' + Map_SequenceNumRec + ' xyz: '+ Map_SequenceNumRec.get(i + 1) + 'xyz: '+  (i + 1) + ' : ' + integer.valueOf(SelectedIndex));
            if( Map_SequenceNumRec != null && Map_SequenceNumRec.get(i + 1) != null && (i + 1) != integer.valueOf(SelectedIndex) )
            {
                TempMap_SequenceNumRec.put( i + 1 - SeqNumToSubtract, expwrapperObj.ExpDetailLst[i] );
                system.debug('newaaaa'+TempMap_SequenceNumRec);
            }
            else if ( Map_SequenceNumRec != null && Map_SequenceNumRec.get(i + 1) != null && ( (i + 1) == integer.valueOf(SelectedIndex)) )  
            {
                SeqNumToSubtract = 1;
            }
            system.debug('qqqqqqqq'+SeqNumToSubtract);
        }
        Map_SequenceNumRec.clear();
        if( TempMap_SequenceNumRec != null )
        {
            Map_SequenceNumRec.putAll(TempMap_SequenceNumRec);
        }
        Integer SequenceCounter = 0;
        for(integer SequenceNumber :Map_SequenceNumRec.keyset())
        {
            SequenceCounter++;
            if( Map_SequenceNumRec.get(SequenceNumber) != null )
            {
                SVMXC__ServiceMax_Config_Data__c TempDetailExprObj = new SVMXC__ServiceMax_Config_Data__c();
                TempDetailExprObj = Map_SequenceNumRec.get(SequenceNumber);
                TempDetailExprObj.SVMXC__Sequence__c = SequenceCounter;
                Temp_ExpDetailsLst.add(TempDetailExprObj);
            }
        }
        expwrapperObj.ExpDetailLst.clear();
        expwrapperObj.ExpDetailLst.addAll(Temp_ExpDetailsLst);
        if(expwrapperObj.ExpDetailLst != null)
            ExpDetailSize = expwrapperObj.ExpDetailLst.size();
        else
            ExpDetailSize = 0;
    }
    catch(exception ex)
    {
        AddException(ex.getMessage());
    }
}



//List of expressions obtained from sfm-getexpression in header class's constructor

//Save expression
//Save expression
public String savedExpressionResultId;
public String getsavedExpressionResultId() { return savedExpressionResultId;}
public void setsavedExpressionResultId(String val){this.savedExpressionResultId = val;}

public void SaveExpression(){
    if(expwrapperObj.ExpHeader != null && expwrapperObj.ExpHeader.SVMXC__Name__c != null && (expwrapperObj.ExpHeader.SVMXC__Name__c).length() > 0 &&  expwrapperObj.ExpHeader.SVMXC__ProcessID__c != null && (expwrapperObj.ExpHeader.SVMXC__ProcessID__c).length() > 0 )
    {
        SFM_WrapperDef.SFM_Response Save_Response = new SFM_WrapperDef.SFM_Response();
        try
        {
            expwrapperObj.ExpHeader.SVMXC__SettingId__c = expwrapperObj.ExpHeader.SVMXC__ProcessID__c;
            List<SVMXC__ServiceMax_Config_Data__c> ExpressionDetails2Save = new List<SVMXC__ServiceMax_Config_Data__c>(); 
            for(SVMXC__ServiceMax_Config_Data__c expressiondtlRec :expwrapperObj.ExpDetailLst)
            {
                if( (expressiondtlRec.SVMXC__Operator__c == null || expressiondtlRec.SVMXC__Operator__c == 'SVMX.NONE') && (expressiondtlRec.SVMXC__Operand__c == null || expressiondtlRec.SVMXC__Operand__c == '') && expressiondtlRec.SVMXC__Field_Name__c == 'None' )
                    continue;
                else
                    ExpressionDetails2Save.add(expressiondtlRec);
            }
            expwrapperObj.ExpDetailLst.clear();
            expwrapperObj.ExpDetailLst.addAll(ExpressionDetails2Save);
            ExpDetailSize = Math.Round(expwrapperObj.ExpDetailLst.size());
            SFM_WrapperDef.SFM_Expression oSFM_Exp = new SFM_WrapperDef.SFM_Expression(expwrapperObj.ExpHeader,expwrapperObj.ExpDetailLst);
            List<SFM_WrapperDef.SFM_Expression> LstSFM_Exp = new List<SFM_WrapperDef.SFM_Expression>();
            LstSFM_Exp.add(oSFM_Exp);
            SFM_WrapperDef.SFM_Request_Expression oRequest = new SFM_WrapperDef.SFM_Request_Expression(LstSFM_Exp);//s,msg,tid,strmap Commented for New Approach
            system.debug('Newsave'+oRequest);
            SVMXC.SFM_saveExpression saveExp = new SVMXC.SFM_saveExpression();
            //SFM_WrapperDef.SFM_Response Save_Response = new SFM_WrapperDef.SFM_Response(); //Instantiated outside, since its required in catch block
            Save_Response = saveExp.SFM_saveExpression(oRequest);
            system.debug('Exp1: '+Save_Response);
            if( Save_Response != null && Save_Response.success != null)
            {
                if(Boolean.valueOf(Save_Response.success))
                {
                    ApexPages.addMessage(new ApexPages.Message( ApexPages.Severity.Confirm, getTAG009()));
                    if( Save_Response.resultIds != null && Save_Response.resultIds.size() > 0 )
                    {
                        savedExpressionResultId = Save_Response.resultIds[0];
                        setsavedExpressionResultId(Save_Response.resultIds[0]);
                        system.debug('10.result id'+savedExpressionResultId);
                    }
                }
                else
                    ApexPages.addMessage(new ApexPages.Message( ApexPages.Severity.Error, '' + Save_Response.message ));
            }
            else
            {
                ApexPages.addMessage(new ApexPages.Message( ApexPages.Severity.Error, getTAG010()));
            }
        }
        catch(Exception ex)
        {
            if( Save_Response != null && Save_Response.message != null && Save_Response.success == false )
                ApexPages.addMessage(new ApexPages.Message ( ApexPages.Severity.ERROR, ''+Save_Response.message + ': ' + ex.getmessage()));
        }
    }
    else
    {
        if( expwrapperObj.ExpHeader == null || expwrapperObj.ExpHeader.SVMXC__Name__c == null || expwrapperObj.ExpHeader.SVMXC__Name__c == '' || (expwrapperObj.ExpHeader.SVMXC__Name__c).length() == 0 )
            ApexPages.addMessage(new ApexPages.Message ( ApexPages.Severity.ERROR, getTAG011()));
        if( expwrapperObj.ExpHeader == null || expwrapperObj.ExpHeader.SVMXC__ProcessID__c == null || expwrapperObj.ExpHeader.SVMXC__ProcessID__c == '' || (expwrapperObj.ExpHeader.SVMXC__ProcessID__c).length() == 0 )
            ApexPages.addMessage(new ApexPages.Message ( ApexPages.Severity.ERROR, getTAG012()));
    }
}


List<SelectOption> OperatorSelectLst = new List<SelectOption>();

public List<SelectOption> getOperatorSelectLst(){
    return OperatorSelectLst;
}

public class ExpressionWrapper{

public SVMXC__ServiceMax_Processes__c ExpHeader = new SVMXC__ServiceMax_Processes__c();
public List<SVMXC__ServiceMax_Config_Data__c> ExpDetailLst = new List<SVMXC__ServiceMax_Config_Data__c>();
public Boolean RenderAddButton = false;
public Boolean RenderDelButton = false;
/* Getter Setters - Starts here */

public SVMXC__ServiceMax_Processes__c getExpHeader(){
    //ExpHeader = Select Id, Name,SVMXC__Source_Object_Name__c, SVMXC__Name__c,SVMXC__SettingId__c,SVMXC__Description__c,SVMXC__Advance_Expression__c,SVMXC__ProcessID__c,SVMXC__Parent_Object_Criteria__c,SVMXC__Parent_Error_Msg__c,SVMXC__IsStandard__c From SVMXC__ServiceMax_Processes__c where Recordtype.Name='SVMX Rule' AND SVMXC__Rule_Type__c = 'Named Expression' AND Id = :ExpId
    return ExpHeader;
}
public void setExpHeader(SVMXC__ServiceMax_Processes__c ExpHdr){
    this.ExpHeader = ExpHdr;
}

public List<SVMXC__ServiceMax_Config_Data__c> getExpDetailLst(){
    return ExpDetailLst;
}
public void setExpDetailLst(List<SVMXC__ServiceMax_Config_Data__c> ExpDtlLst){
    this.ExpDetailLst = ExpDtlLst;
}

public Boolean getRenderAddButton(){
    return RenderAddButton;
}
public void setRenderAddButton(Boolean val){
    this.RenderAddButton = val;
}

public Boolean getRenderDelButton(){
    return RenderDelButton;
}
public void setRenderDelButton(Boolean val1){
    this.RenderDelButton = val1;
}
/* Getter Setters - Ends here */

// Constructor
public ExpressionWrapper(SVMXC__ServiceMax_Processes__c HeaderExpression, List<SVMXC__ServiceMax_Config_Data__c> DetailExpressionLst, Boolean DisplayAddButton, Boolean DisplayDelButton)
{
    this.ExpHeader = HeaderExpression;
    this.ExpDetailLst = DetailExpressionLst;
    this.RenderAddButton = DisplayAddButton;
    this.RenderDelButton = DisplayDelButton;
}
}

public Boolean DisableSave = true;
public Boolean getDisableSave() { return DisableSave; } 
public ExpressionWrapper expwrapperObj = new ExpressionWrapper(new SVMXC__ServiceMax_Processes__c(), new List<SVMXC__ServiceMax_Config_Data__c>(), true, false);
public ExpressionWrapper getexpwrapperObj(){system.debug('june2222'+SelectedExpId); return expwrapperObj;}
public void setexpwrapperObj(ExpressionWrapper value){ this.expwrapperObj = value; }
Map<Integer, SVMXC__ServiceMax_Config_Data__c> Map_SequenceNumRec = new Map<Integer, SVMXC__ServiceMax_Config_Data__c>();


public void DoTheInitialJob()
{
    ExpDetailSize = 0;
/* populate operand picklist values */
    OperatorSelectLst.clear();
    OperatorSelectLst.add(new SelectOption('SVMX.NONE','--None--'));
    OperatorSelectLst.add(new SelectOption('eq','Equals'));
    OperatorSelectLst.add(new SelectOption('ne','Not Equal'));
    OperatorSelectLst.add(new SelectOption('gt','Greater Than'));
    OperatorSelectLst.add(new SelectOption('ge','Greater or Equal To'));
    OperatorSelectLst.add(new SelectOption('lt','Less Than'));
    OperatorSelectLst.add(new SelectOption('le','Less or Equal To'));
    OperatorSelectLst.add(new SelectOption('starts','Starts With'));
    OperatorSelectLst.add(new SelectOption('contains','Contains'));
    OperatorSelectLst.add(new SelectOption('notcontain','Does Not Contain'));
    OperatorSelectLst.add(new SelectOption('in','Includes'));
    OperatorSelectLst.add(new SelectOption('notin','Excludes'));
    OperatorSelectLst.add(new SelectOption('isnull','Is Null'));
    OperatorSelectLst.add(new SelectOption('isnotnull','Is Not Null'));

/* populate operand picklist values */


    // Populate Named Expression
    //Build the string map
    List<SFM_WrapperDef.SFM_StringMap> stringMap = new List<SFM_WrapperDef.SFM_StringMap>();
    /*if( objName != null && objName != '' )
        stringMap.add(new SFM_WrapperDef.SFM_StringMap ('OBJECTNAME',objName));*/
    if( compMode != 'New' )
    {
        if( SelectedExpId != null && SelectedExpId != '' )
        {
            String ExprId = SelectedExpId;
            ExprId = ExprId.substring(0, 15);
            //stringMap.add(new SFM_WrapperDef.SFM_StringMap ('EXPRESSIONID',SelectedExpId));
            stringMap.add(new SFM_WrapperDef.SFM_StringMap ('EXPRESSIONID',ExprId));

            //Create the request
            SFM_WrapperDef.SFM_Request request = new SFM_WrapperDef.SFM_Request('','','',stringMap);
    
            //Result
            SFM_GetNamedExpressionList getExpCls = new SFM_GetNamedExpressionList();
            SFM_WrapperDef.SFM_Response_Expression ResEXP; // We make it available public, since it needs to be used by component also.
            ResEXP = getExpCls.SFM_getNamedExpressionList(request);
    
    
            //Create the picklist entries by looping through the resultant exp list obtained above
    
            Map<String, SVMXC__ServiceMax_Config_Data__c> Map_ConfigRecs = new Map<String, SVMXC__ServiceMax_Config_Data__c>();
            //Map<Integer, SVMXC__ServiceMax_Config_Data__c> Map_SequenceNumRec = new Map<Integer, SVMXC__ServiceMax_Config_Data__c>();//Declared public as required in hdrdelete
            List<SVMXC__ServiceMax_Config_Data__c> ModifiedExpressionDetailLst = new List<SVMXC__ServiceMax_Config_Data__c>();
            for(SFM_WrapperDef.SFM_Expression Sfm_Exp:ResEXP.expressions)
            {
                Integer tempHighestSeqNum = 0;
                Map_ConfigRecs.putAll(Sfm_Exp.expressionDetails);
                for( SVMXC__ServiceMax_Config_Data__c  Sfm_DetailExpression :Sfm_Exp.expressionDetails )
                {
                    if( Sfm_DetailExpression.SVMXC__Sequence__c != null )
                    {
                        Map_SequenceNumRec.put((Sfm_DetailExpression.SVMXC__Sequence__c).intvalue(), Sfm_DetailExpression);
                    }
                }
                If(Sfm_Exp.expressionDetails != null)
                    ExpDetailSize = Math.Round(Sfm_Exp.expressionDetails.size());
                for( integer i=1; i < Sfm_Exp.expressionDetails.size() + 1; i++ )
                {
                    if( Map_SequenceNumRec != null && Map_SequenceNumRec.get(i) != null )
                    {    
                        Map_SequenceNumRec.get(i).SVMXC__Sequence__c = Math.Round(Map_SequenceNumRec.get(i).SVMXC__Sequence__c);
                        ModifiedExpressionDetailLst.add(Map_SequenceNumRec.get(i));
                    }
                }
                
                if( Sfm_Exp.namedExpression != null && !(Sfm_Exp.namedExpression.SVMXC__IsStandard__c) )
                {
                    DisableSave = false;
                }
                expwrapperObj = new ExpressionWrapper(Sfm_Exp.namedExpression, ModifiedExpressionDetailLst, true, false);
                if(expwrapperObj.ExpDetailLst != null)
                    ExpDetailSize = expwrapperObj.ExpDetailLst.size();
            }
        }
    }
    else
    {
        expwrapperObj = new ExpressionWrapper(new SVMXC__ServiceMax_Processes__c( RecordTypeId = ExpressionHeader_Rtype.Id, SVMXC__Source_Object_Name__c = objName), new List<SVMXC__ServiceMax_Config_Data__c>(), true, false);
        HdrADDRow(); //Method called to add row
        HdrADDRow(); //Method called to add row
        if(expwrapperObj.ExpDetailLst != null)
            ExpDetailSize = expwrapperObj.ExpDetailLst.size();
        DisableSave = false;
    }
}
public String getTAG001(){ return  System.Label.CONF017_TAG001;}//'Save'
public String getTAG002(){ return  System.Label.CONF017_TAG002;}//'Cancel'
public String getTAG003(){ return  System.Label.CONF017_TAG003;}//'Expression Name'
public String getTAG004(){ return  System.Label.CONF017_TAG004;}//'Unique Id'
public String getTAG005(){ return  System.Label.CONF017_TAG005;}//'Advanced Expression'
public String getTAG006(){ return  System.Label.CONF017_TAG006;}//'Error message to display if a record does not meet the above criteria'//Field Name
public String getTAG007(){ return  System.Label.CONF017_TAG007;}//'Define expression for '
public String getTAG008(){ return  System.Label.CONF017_TAG008;}//'Define expression'//Processing...
public String getTAG009(){ return  System.Label.CONF017_TAG009;}//'Expression Record Saved successfully'
public String getTAG010(){ return  System.Label.CONF017_TAG010;}//'Internal Error Occured, Please Try Later'
public String getTAG011(){ return  System.Label.CONF017_TAG011;}//'Please enter a valid Expression Name'
public String getTAG012(){ return  System.Label.CONF017_TAG012;}//'Expression Id should be atleast 8 characters long'
public String getTAG013(){ return  System.Label.CONF017_TAG016; }//help title
public String getTAG014(){ return  System.Label.CONF017_HLPURL1; }//help url
public String getTAG015(){ return  System.Label.CONF017_TAG014; }//Operator
//public String getTAG016(){ return  System.Label.CONF017_TAG018; }//Value//TODO

}