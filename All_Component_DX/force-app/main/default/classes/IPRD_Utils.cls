public with sharing class IPRD_Utils {
    
//======================================== Get Covered Product ===================================================//
// Input Parameters:
// Installed Product Record
// Output:
// Set of Covered products Ids for the given Installed Product
//=============================================================================================================//
public set<Id> SVMXC_Get_CoveredProducts(SVMXC__Installed_Product__c IProduct){
    set<Id> CoveredIds = new set<Id>();
    Product2 IP_Product = [SELECT Tracking__c,Product_Line__c,Family FROM Product2 where Id=:IProduct.Product__c];  
    //If both product family and line exist for the IB Product
    if(IP_Product.Family!=NULL && IP_Product.Product_Line__c!=NULL){
        for (SVMXC__Service_Template_Products__c stprod : [SELECT SVMXC__Service_Template__c 
                                        FROM SVMXC__Service_Template_Products__c 
                                        WHERE SVMXC__Product__c = :IProduct.Product__c
                                        OR SVMXC__Product_Family__c = :IP_Product.Family
                                        OR SVMXC__Product_Line__c = :IP_Product.Product_Line__c]){
                                            CoveredIds.add(stprod.SVMXC__Service_Template__c);
                                        }
    }
    //If only product family exist for the IB Product
    else if(IP_Product.Family!=NULL){
        for (SVMXC__Service_Template_Products__c stprod : [SELECT SVMXC__Service_Template__c 
                                        FROM SVMXC__Service_Template_Products__c 
                                        WHERE SVMXC__Product__c = :IProduct.Product__c
                                        OR SVMXC__Product_Family__c = :IP_Product.Family]){
                                            CoveredIds.add(stprod.SVMXC__Service_Template__c);
                                        }
    }
    //If only product line exist for the IB Product
    else if(IP_Product.Product_Line__c!=NULL){
        for (SVMXC__Service_Template_Products__c stprod : [SELECT SVMXC__Service_Template__c 
                                        FROM SVMXC__Service_Template_Products__c 
                                        WHERE SVMXC__Product__c = :IProduct.Product__c
                                        OR SVMXC__Product_Line__c = :IP_Product.Product_Line__c]){
                                            CoveredIds.add(stprod.SVMXC__Service_Template__c);
                                        }
    }
    else{
        for (SVMXC__Service_Template_Products__c stprod : [SELECT SVMXC__Service_Template__c 
                                        FROM SVMXC__Service_Template_Products__c 
                                        WHERE SVMXC__Product__c = :IProduct.Product__c]){
                                            CoveredIds.add(stprod.SVMXC__Service_Template__c);
                                        }
    }
    return CoveredIds;
}

//======================================== Creates Warranty ===================================================//
// Input Parameters:
// List of Installed Product Record
// Map of Installed Product Id to Warranty Terms
// Setting Value (isSetToday): If it is set true, This procedure allows to create warranty even if coverage effective date field is not available
// Output:
// Creates warranty for the given list Of IB's and list of warranty terms based on the  
//=============================================================================================================//
public class CreateWarrantyResult
{
     public String Status{get; set;}
     public String RetURL{get; set;}
     public set<String>  ResultSet {get; set;}
     
     public CreateWarrantyResult(String S, String R, set<String> RS)
     {
       Status = S;
       RetURL = R;
       ResultSet = RS;
     }
}  
public CreateWarrantyResult SVMXC_Set_CreateWarranty_IPW(List<SVMXC__Installed_Product__c> IProduct,Map<Id,list<SVMXC__Service_Template__c>> MapIBWar){

    List<Sobject> listso;
    Boolean bo;
    String str;
    Date startdate;
    Date enddate;
    Date enddate_time; 
    Date enddate_mtrl;
    Date enddate_exp;
    String whrClouse='';
    Boolean isSetToday;
    String Status='SUCCESS';
    set<String> ResultSet = new set<String>();
    List<SVMXC__Service_Template__c> WarrantyTermList= new List<SVMXC__Service_Template__c>();
    List<SVMXC__Warranty__c> WarrantyList = new List<SVMXC__Warranty__c>();
    List<SVMXC__Warranty__c> CreateWarrantyList = new List<SVMXC__Warranty__c>();
    Map<Id,SVMXC__Warranty__c> WTOWTTMAP = new Map<Id,SVMXC__Warranty__c>();

    CreateWarrantyResult ResultWarpper;  
    //Object Mapping Utility
    SVMXC.COMM_Utils_ObjectMapping targetutil = new SVMXC.COMM_Utils_ObjectMapping(); // Creating the instance of the TargetObject utility
    SVMXC.COMM_Utils_ObjectMapping.ObjectMappingResult ListResultObject = new SVMXC.COMM_Utils_ObjectMapping.ObjectMappingResult(listso,bo,str);//Creating the instance of the TargetObject utility's inner class

    //Getting Setting values
    SVMXC.COMM_Utils_ManageSettings settings = new SVMXC.COMM_Utils_ManageSettings();
    Map<String, String> AllSubModuleSettings = settings.SVMX_getSettingList('IPRD002'); 
    COMM_Utils_ManageTags commUtil = new COMM_Utils_ManageTags(); 
    //Map<String, String> svmxTagList = commUtil.SVMX_getTagList('IPRD002');
    String TAG038=system.label.IPRD002_TAG038; //Coverage for this warranty starts from
    String TAG039=system.label.IPRD002_TAG039; //but there is no data in this field
    String TAG040=system.label.IPRD002_TAG040; // but there is no such field in the Installed Product object
    String TAG041=system.label.IPRD002_TAG041; //Warranty term not defined properly
    String TAG042=system.label.IPRD002_TAG042; //Coverage effective from date was not specified for the warranty term.
    String TAG043=system.label.IPRD002_TAG043; //Warranty not available, no warranties have been defind properly
    String mapId  = AllSubModuleSettings.get('SET009');//Mapping from warranty term to warranty
    String StringisSetToday = AllSubModuleSettings.get('SET008'); //setting for Create Warranty on IB update
    //Checking IsTodays date is allowed when start date is not available in the IB
    if (StringisSetToday != null && StringisSetToday.toUpperCase() == 'TRUE')
    isSetToday=true;
    else
    isSetToday=false;
    //Get map of field labels
        Map<String,Schema.SObjectField> objfieldMap = new Map<String,Schema.SObjectField>();
        Map<String, Schema.SObjectType> allObjs; 
        Map<String,String> LabelFromName = new Map<String,String>();
        allObjs = Schema.getGlobalDescribe();
       // Schema.SObjectType objT = allObjs.get('installed_Product__c') ;
       // Changed as part of API upgrade
       Schema.SObjectType objT = allObjs.get('SVMXC__Installed_Product__c') ;
        objfieldMap = objT.getDescribe().fields.getMap();
        for (String fieldKey : objfieldMap.keySet()) 
        {
            Schema.SObjectField fsObj = objfieldMap.get(fieldKey);
            Schema.DescribeFieldResult f = fsObj.getDescribe();
            LabelFromName.put(f.getName(),f.getLabel());
        }
    
    String IdList='';
    //Create the warrenty term list from the warranty map
    for(list<SVMXC__Service_Template__c> warTermList : MapIBWar.values()){
        for(SVMXC__Service_Template__c w: warTermList){
            if(IdList!='' && IdList.length()>0)
                IdList+=',';
            IdList+='\''+w.Id+'\'';
        }
    }
           
    whrClouse='Id IN ('+IdList+')';
    //Create the product warranty for the warranty terms using the MAP comming from settings
    ListResultObject = targetutil.getTargerRecordlist(mapId,whrClouse,WarrantyList); 
    List<Sobject> listrecord = ListResultObject.listresultObj;
    system.debug('TESTPB1'+listrecord+isSetToday+StringisSetToday+IProduct);
    
    WarrantyList = (List<SVMXC__Warranty__c>)listrecord; 
    
    //Create a Map for WarrantyTerm.Id to Product warranty
    for(SVMXC__Warranty__c war: WarrantyList){
        WTOWTTMAP.put(war.SVMXC__Service_Template__c, war);
    }
    
    //For each IB create the product warranty 
    List<SVMXC__Service_Template__c> IBWarTerm;
    SVMXC__Warranty__c TempWar;
    for(SVMXC__Installed_Product__c IB: IProduct){
        IBWarTerm= new List<SVMXC__Service_Template__c>();
        if(MapIBWar.containsKey(IB.Id) && MapIBWar.get(IB.Id) != null)
            IBWarTerm = MapIBWar.get(IB.Id);
        system.debug('TEST!'+IB+IBWarTerm);
        for(SVMXC__Service_Template__c IBW: IBWarTerm){
            TempWar = new SVMXC__Warranty__c();
            if(WTOWTTMAP.get(IBW.Id) != NULL)// Added by bala 14-10-2011
                TempWar = WTOWTTMAP.get(IBW.Id).clone(false, true);
            //Proceed and create warranty only if the warranty definition is defined for the warranty term
            //Reset start date
            startdate = NULL;
            
            if(IBW.SVMXC__Coverage_Effective_From2__c!=null || isSetToday==true){// Start If API name exists
                //Set Start Date
                if (IBW.SVMXC__Coverage_Effective_From2__c!=null){
                    try{
                    if(IB.get(IBW.SVMXC__Coverage_Effective_From2__c) != NULL)
                    startdate = date.valueOf(IB.get(IBW.SVMXC__Coverage_Effective_From2__c));
                    else if(isSetToday==false)
                    Status= TAG038 + LabelFromName.get(IBW.SVMXC__Coverage_Effective_From2__c) + TAG039;
                    }
                    catch(Exception e) {if(isSetToday==false)Status= TAG038 + LabelFromName.get(IBW.SVMXC__Coverage_Effective_From2__c) + TAG040;}
                }
                if(isSetToday==true && startdate==NULL)
                    startdate = System.today();

                system.debug('TEST7'+startdate);
                
                
                //If start date exists find the end date 
                if(startdate!=null)
                {   
                    Date a;
                    Date b;
                      /**** 1. Number type need to be converted into double using longvalue() during API upgrade
                            2. Addtional null check added to avoid null pointer exception ************/ 
                      
                    if(IBW.SVMXC__Duration_of_Time_Coverage__c!=null) 
                    { 
                    enddate_time = SVMX_CalcWarrEndDate(startdate, 
                                                IBW.SVMXC__Duration_of_Time_Coverage__c.longvalue(),
                                                IBW.SVMXC__Unit_of_Time__c);
                    }
                    
                    if(IBW.SVMXC__Duration_of_Material_Coverage__c!=null)
                    {
                    enddate_mtrl = SVMX_CalcWarrEndDate(startdate, 
                                                IBW.SVMXC__Duration_of_Material_Coverage__c.longvalue(),
                                                IBW.SVMXC__Unit_of_Time_Material__c);
                    }                            
                    
                    
                    if(IBW.SVMXC__Duration_of_Expenses__c!=null)
                    {
                    enddate_exp = SVMX_CalcWarrEndDate(startdate, 
                                                IBW.SVMXC__Duration_of_Expenses__c.longvalue(),
                                                IBW.SVMXC__Unit_of_Time_Expenses__c);
                    }
                    system.debug('TESTPB2'+enddate_time+enddate_mtrl+enddate_exp);
                    // Overall end date of the warranty is the maximum of time/parts/expenses coverage end dates
                    if(enddate_time != NULL && enddate_mtrl != NULL && enddate_exp != NULL){
                        if (enddate_time >= enddate_mtrl && enddate_time >= enddate_exp)
                            enddate = enddate_time; 
                        else if (enddate_mtrl >= enddate_time && enddate_mtrl >= enddate_exp)
                            enddate = enddate_mtrl; 
                        else if (enddate_exp >= enddate_time && enddate_exp >= enddate_mtrl)
                            enddate = enddate_exp; 
                    }
                    else{
                        if(enddate_time!=NULL)a = enddate_time;
                        if(enddate_mtrl!=NULL){if(a==NULL)a = enddate_mtrl; else b = enddate_mtrl;}
                        if(enddate_exp!=NULL){if(a==NULL)a = enddate_exp; else b =enddate_exp;}
                        //Only a Exist
                        if(b==NULL)
                        enddate = a; 
                        else{
                            if(a > b)
                            enddate = a; else enddate = b;
                        }
                    }
                    system.debug('TESTPB3'+a+b+enddate);
                    //If end date exists create warranty
                    if(enddate != null && IB != null && TempWar != null) 
                    {
                        TempWar.SVMXC__Installed_Product__c=IB.Id;
                        TempWar.SVMXC__Start_Date__c=startdate;
                        TempWar.SVMXC__End_Date__c=enddate;
                        TempWar.SVMXC__End_Date_Time_Covered__c=enddate_time;
                        TempWar.SVMXC__End_Date_Material_Covered__c=enddate_mtrl;
                        TempWar.SVMXC__End_Date_Expenses_Covered__c=enddate_exp;
                    
                        CreateWarrantyList.add(TempWar);
                    }  
                    else{
                        Status= TAG041;
                    }              
                }
            }// Ends If API name exists
            else
                Status= TAG042;
        }
    }
                    
    if(CreateWarrantyList.size()>0){
        if( COMM_SecurityUtils.getInstance().verifyFieldAccess( CreateWarrantyList, COMM_SecurityUtils.Access.Createable ) ) {
            //SDL-SVMX-CREATE-UPDATE-FLS-ENFORCED
            insert CreateWarrantyList;//else Status='Warranty term doesnot have suceffient coverage information';
        } else {
            throw new COMM_SecurityUtils.SecurityAccessException( System.Label.COMM001_TAG142 );
        }
    }
    
    String FirstCreated;
    for(SVMXC__Warranty__c CW : CreateWarrantyList){
        if(FirstCreated==NULL)
        FirstCreated=CW.Id;
        ResultSet.add(String.valueof(CW.Id));
    }
    ResultWarpper = new CreateWarrantyResult(Status,FirstCreated,ResultSet);
    system.debug('TESTPB2'+ResultWarpper);
    return ResultWarpper;
}
       
public static Date SVMX_CalcWarrEndDate(Date dateStart, Double Units, String UoT)
        {
        if (Units == Null || UoT == Null) { return null;} //By GM 29July09
        
        if (Units <= 0 || UoT.length() <= 0) { return null; }
        
        Date dateEnd;
        Integer i;
        
        dateEnd = dateStart;
        // This loop is a NECESSITY because Apex code won't allow
        // casting of Units (Double) to add-days/months/years param (Integer)
        //for(i = 0; i < Units; i++)
        //    {   
        if (UoT == 'Days')
            dateEnd = dateEnd.addDays(Units.intValue());
        else if (UoT == 'Weeks')
            dateEnd = dateEnd.addDays(7 * Units.intValue());
        else if (UoT == 'Months')
            dateEnd = dateEnd.addMonths(Units.intValue());
        else if (UoT == 'Years')
            dateEnd = dateEnd.addYears(Units.intValue());
        else
            dateEnd = System.Today();
        //    }
        if ( (UoT == 'Days')|| (UoT == 'Weeks') ||(UoT == 'Months') ||(UoT == 'Years') ) 
        {               
            return(dateEnd-1);
        }
        else
            return(dateEnd);
       }
}