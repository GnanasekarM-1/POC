public class WORD_SetupDispatch_Methods
{
    
    //SVMXC.COMM_Utils_ManageSettings commSettings = new SVMXC.COMM_Utils_ManageSettings();
    //public Map<String, String> svmxSettingList = commSettings.SVMX_getSettingList('WORD015');
    //SVMXC.COMM_Utils_ManageTags commUtil = new SVMXC.COMM_Utils_ManageTags();
    //public Map<String, String> svmxTagList = commUtil.SVMX_getTagList('WORD015'); 
    
    public map<String,SObjectType> allObjs = new map<String,SObjectType>();
    public Map<String,Schema.SObjectField> objfieldMap = new Map<String,Schema.SObjectField>(); 
    public map <string, Map<String,Schema.SObjectField>> mMapFieldList = new map<string, Map<String,Schema.SObjectField>> ();
    public boolean IsEnterpriseLicense = false;
    public Map<String,Boolean> PermitedStndObjMap = new Map<String,Boolean>();
    SVMXC.COMM_Utils Utils = new SVMXC.COMM_Utils();
    //Constructor
    public WORD_SetupDispatch_Methods()
    {
        Map<String, Schema.SObjectType> gd = new Map<String, Schema.SObjectType>();
         //Added by amar on 19/Aug/10 Due to OEM Exercises
        IsEnterpriseLicense = utils.SVMX_isEnterpriseLicense();
        if(!IsEnterpriseLicense)
        {
             PermitedStndObjMap = utils.SVMX_getPermittedStandardObjectList();
        }
        gd = Schema.getGlobalDescribe(); 
        for(Schema.SObjectType lON : gd.values()) //Loop List of all Objects and describe each
        {
            Schema.DescribeSObjectResult D = lON.getDescribe();
            allObjs.put(D.getName(), lON);
        }
    }
    public string getHLPURL(){ return system.label.WORD015_HLPURL;}
    public String getTAG001(){ return system.label.WORD015_TAG001;}//Help
    public String getTAG002(){ return system.label.WORD015_TAG002;}//Processing...
    public String getTAG003(){ return system.label.WORD015_TAG003;}//Dispatch Process
    public String getTAG004(){ return system.label.WORD015_TAG004;}//Assignment Rules
    public String getTAG005(){ return system.label.WORD015_TAG005;}//Territories
    public String getTAG006(){ return system.label.WORD015_TAG006;}//Prioritization
    public String getTAG007(){ return system.label.WORD015_TAG007;}//Dispatch Preferences
    public String getTAG008(){ return system.label.WORD015_TAG008;}//OptiMax Cost Parameters
    public String getTAG009(){ return system.label.WORD015_TAG009;}//Scheduling
    public String getTAG010(){ return system.label.WORD015_TAG010;}//Process Name:
    public String getTAG011(){ return system.label.WORD015_TAG011;}//Description
    public String getTAG012(){ return system.label.WORD015_TAG012;}//Dispatch Method
    public String getTAG013(){ return system.label.WORD015_TAG013;}//Using the expression-builder below, define the criteria that allows work orders to be considered by this process.:Note that this criteria must be exclusive between processes.
    public String getTAG014(){ return system.label.WORD015_TAG014;}//Work Order Field
    public String getTAG015(){ return system.label.WORD015_TAG015;}//Operator
    public String getTAG016(){ return system.label.WORD015_TAG016;}//Value
    public String getTAG017(){ return system.label.WORD015_TAG017;}//Advanced Expression
    public String getTAG018(){ return system.label.WORD015_TAG018;}//<< Dispatch Processes
    public String getTAG019(){ return system.label.WORD015_TAG019;}//Next >>
    public String getTAG020() {return system.label.WORD015_TAG020;}//Use this section to define one or more rules to identify the target user or queue to assign the work order to. Users can be technicians or dispatchers.
    public String getTAG021() {return system.label.WORD015_TAG021;}//New Rule
    public String getTAG022() {return system.label.WORD015_TAG022;}//Edit Rule
    public String getTAG023() {return system.label.WORD015_TAG023;}//Delete Rule
    public String getTAG024() {return system.label.WORD015_TAG024;}//Rule Sequence
    public String getTAG025() {return system.label.WORD015_TAG025;}//Select
    public String getTAG026() {return system.label.WORD015_TAG026;}//Rule Name
    public String getTAG027() {return system.label.WORD015_TAG027;}//Description
    public String getTAG028() {return system.label.WORD015_TAG028;}//Assign Work Order To
    public String getTAG029() {return system.label.WORD015_TAG029;}//No Match Required
    public String getTAG030() {return system.label.WORD015_TAG030;}//Technician
    public String getTAG031() {return system.label.WORD015_TAG031;}//Dispatcher
    public String getTAG032() {return system.label.WORD015_TAG032;}//Queue
    public String getTAG033() {return system.label.WORD015_TAG033;}//--None--
    public String getTAG034() {return system.label.WORD015_TAG034;}//Schedule an event in user�s calendar
    public String getTAG035() {return system.label.WORD015_TAG035;}//If a work order does not match any of the rules above
    public String getTAG036() {return system.label.WORD015_TAG036;}//<< Process Definition
    public String getTAG037() {return system.label.WORD015_TAG037;}//Save
    public String getTAG038() {return system.label.WORD015_TAG038;}//Save And Close
    public String getTAG039() {return system.label.WORD015_TAG039;}//Select the territories that will use this dispatch process.
    public String getTAG040() {return system.label.WORD015_TAG040;}//<< Process Definition
    public String getTAG041() {return system.label.WORD015_TAG041;}//Prioritization >>
    public String getTAG042() {return system.label.WORD015_TAG042;}//In this section, you can setup 4 priority buckets for this dispatch process. Priority buckets help in determining the processing sequence of each work order in a batch.
    public String getTAG043() {return system.label.WORD015_TAG043;}//Match Product
    public String getTAG044() {return system.label.WORD015_TAG044;}//<< Territories
    public String getTAG045() {return system.label.WORD015_TAG045;}//Dispatch Preferences >>
    public String getTAG046() {return system.label.WORD015_TAG046;}//In this section, indicate your preferences for OptiMax, the dispatch optimization engine of ServiceMax.
    public String getTAG047() {return system.label.WORD015_TAG047;}//Specify whether technician�s expertise or product specialization is to be matched with the expertise / product specialization on work order 
    public String getTAG048() {return system.label.WORD015_TAG048;}//Match Expertise 
    public String getTAG049() {return system.label.WORD015_TAG049;}//Do you require OptiMax to consider if a technician is a preferred technician for the customer?
    public String getTAG050() {return system.label.WORD015_TAG050;}//Indicate the nature of technician�s route. Closed route ensures the technician returns to the starting location.
    public String getTAG051() {return system.label.WORD015_TAG051;}//Are you sure to delete the selected rules?
    public String getTAG052() {return system.label.WORD015_TAG052;}//When OptiMax processes the work orders for this dispatch process, please indicate the minimum and maximum time horizon for scheduling work orders.
    public String getTAG053() {return system.label.WORD015_TAG053;}//Yes
    public String getTAG054() {return system.label.WORD015_TAG054;}//No
    public String getTAG055() {return system.label.WORD015_TAG055;}//Calendar Search Start Date
    public String getTAG056() {return system.label.WORD015_TAG056;}//Calendar Search End Date
    public String getTAG057() {return system.label.WORD015_TAG057;}//Days
    public String getTAG058() {return system.label.WORD015_TAG058;}//<< Prioritization
    public String getTAG059() {return system.label.WORD015_TAG059;}//Cost Parameters >>
    public String getTAG060() {return system.label.WORD015_TAG060;}//Same Day
    public String getTAG061() {return system.label.WORD015_TAG061;}//Next Day
    public String getTAG062() {return system.label.WORD015_TAG062;}//In this section, you can fine tune various factors that will influence how OptiMax will perform dispatch optimization based on the cost of each factor.
    //public String getTAG063() {return system.label.WORD015_TAG063;}//Indicate how important Work Order time windows are. 1 is usually sufficient since this factor has a high internal weight.
    //public String getTAG064() {return system.label.WORD015_TAG064;}//Specify a weight for Total Distance traveled. Big values may result in neglection of other preferences.
    //public String getTAG065() {return system.label.WORD015_TAG065;}//Specify a weight for Route Distance. Higher value will ensure the maximum distance is not exceeded while routing
    //public String getTAG066() {return system.label.WORD015_TAG066;}//Specify a weight for Route Time. Higher value will ensure the maximum time is not exceeded while scheduling
    //public String getTAG067() {return system.label.WORD015_TAG067;}//Using a scale of 0 to N, indicate how critical it is to ensure expertise and/or product specialization
    //New Goal Changes
    public String getTAG063() {return system.label.WORD015_TAG063;}//New Value: Meeting the preferred time window //Indicate how important Work Order time windows are. 1 is usually sufficient since this factor has a high internal weight.
    public String getTAG064() {return system.label.WORD015_TAG064;}//New Value: Minimizing travel //{return 'Minimizing Travel Costs and Increase Tech Utilization';}//Specify a weight for Total Distance traveled. Big values may result in neglection of other preferences.
    public String getTAG065() {return system.label.WORD015_TAG065;}//New Value: Sending the preferred technician //{return 'Minimizing overtime schedules/cost';}//Specify a weight for Route Distance. Higher value will ensure the maximum distance is not exceeded while routing
    public String getTAG066() {return system.label.WORD015_TAG066;}//New Value: Minimizing overtime //{return 'Technician Preference and Dependency';}//Specify a weight for Route Time. Higher value will ensure the maximum time is not exceeded while scheduling
    public String getTAG067() {return system.label.WORD015_TAG067;}//New Value: Delivering service ASAP //Using a scale of 0 to N, indicate how critical it is to ensure expertise and/or product specialization
    public String getTAG068() {return system.label.WORD015_TAG068;}//<< Preferences
    public String getTAG069() {return system.label.WORD015_TAG069;}//Scheduling >>
    public String getTAG070() {return system.label.WORD015_TAG070;}//In this section, choose the frequency for processing work orders in this dispatch process and also specify recipients of notifications and alerts.
    public String getTAG071() {return system.label.WORD015_TAG071;}//Runs every
    public String getTAG072() {return system.label.WORD015_TAG072;}//Monday
    public String getTAG073() {return system.label.WORD015_TAG073;}//Tuesday
    public String getTAG074() {return system.label.WORD015_TAG074;}//Wednesday
    public String getTAG075() {return system.label.WORD015_TAG075;}//Thursday
    public String getTAG076() {return system.label.WORD015_TAG076;}//Friday
    public String getTAG077() {return system.label.WORD015_TAG077;}//Saturday
    public String getTAG078() {return system.label.WORD015_TAG078;}//Sunday
    public String getTAG079() {return system.label.WORD015_TAG079;}//Start Time
    public String getTAG080() {return system.label.WORD015_TAG080;}//Frequency
    public String getTAG081() {return system.label.WORD015_TAG081;}//Start Date
    public String getTAG082() {return system.label.WORD015_TAG082;}//End Date
    public String getTAG083() {return system.label.WORD015_TAG083;}//Send success notifications to this email address
    public String getTAG084() {return system.label.WORD015_TAG084;}//Send error notifications to this email address
    public String getTAG085() {return system.label.WORD015_TAG085;}//If work orders could not be assigned or scheduled to technicians by this process, indicate how to handle such exceptions:
    public String getTAG086() {return system.label.WORD015_TAG086;}//Or Send Work Order To This Dispatch Process
    public String getTAG087() {return system.label.WORD015_TAG087;}///<< Cost Parameters
    public String getTAG088() {return system.label.WORD015_TAG088;}//Territory
    public String getTAG089() {return system.label.WORD015_TAG089;}//Please select at least one rule to edit
    public String getTAG090() {return system.label.WORD015_TAG090;}//Cancel
    public String getTAG091() {return system.label.WORD015_TAG091;}//No Records To Display
    public String getTAG092() {return system.label.WORD015_TAG092;}//Please select a dispatch method
    public String getTAG093() {return system.label.WORD015_TAG093;}//Submit
    public String getTAG094() {return system.label.WORD015_TAG094;}//Processing sequence of Assignment Rules 
    public String getTAG095() {return system.label.WORD015_TAG095;}//Please enter a valid dispatch process name
    public String getTAG096() {return system.label.WORD015_TAG096;}//Another dispatch process already exists with this name
    public String getTAG097() {return system.label.WORD015_TAG097;}//Please enter a valid rule name
    public String getTAG098() {return system.label.WORD015_TAG098;}//Duplicate rule names are not allowed
    public String getTAG099() {return system.label.WORD015_TAG099;}//Please define a valid assignment rule for handling exceptions
    public String getTAG100() {return system.label.WORD015_TAG100;}//Please choose a valid Technician
    public String getTAG101() {return system.label.WORD015_TAG101;} //Please choose a valid Dispatcher
    public String getTAG102() {return system.label.WORD015_TAG102;}//Please choose a valid Queue
    public String getTAG103() {return system.label.WORD015_TAG103;}//Please choose a valid Assign To
    public String getTAG104() {return system.label.WORD015_TAG104;}//Please select at least one record to delete
    public String getTAG105() {return system.label.WORD015_TAG105;}//<< Cost Parameters
    public String getTAG106() {return system.label.WORD015_TAG106;}//Record(s)Saved
    public String getTAG107() {return system.label.WORD015_TAG107;}//Please select only one rule to edit
    public String getTAG108() {return system.label.WORD015_TAG108;}//Record(s) Deleted
    public String getTAG109() {return system.label.WORD015_TAG109;}//Please Enter Valid Data
    public String getTAG110() {return system.label.WORD015_TAG110;}//No Territory records found matching the keyword
    public String getTAG111() {return system.label.WORD015_TAG111;}//Keyword must be at least 2 characters long
    public String getTAG112() {return system.label.WORD015_TAG112;}//Please select at least one day for scheduling this dispatch process.
    public String getTAG113() {return system.label.WORD015_TAG113;}//+ svmxSettingList.get('SET001');Frequency must be Equal to or more then
    public String getTAG114() {return system.label.WORD015_TAG114;}//Start date must be earlier than end date
    public String getTAG115() {return system.label.WORD015_TAG115;}//Please enter a valid email address for success notifications
    public String getTAG116() {return system.label.WORD015_TAG116;}//Please enter a valid email address for error notifications
    public String getTAG117() {return system.label.WORD015_TAG117;}//Or Send Work Order To This Dispatch Process
    public String getTAG118() {return system.label.WORD015_TAG118;}//Please select a valid dispatch process to redirect OR assign the work order to a technician or dispatcher or queue 
    public String getTAG119() {return system.label.WORD015_TAG119;}//Critical
    public String getTAG120() {return system.label.WORD015_TAG120;}//High
    public String getTAG121() {return system.label.WORD015_TAG121;}//Medium
    public String getTAG122() {return system.label.WORD015_TAG122;}//Low
    public String getTAG123() {return system.label.WORD015_TAG123;}//Please select atleast territories to save
    public String getTAG124() {return system.label.WORD015_TAG124;}//Add Territory
    public String getTAG125() {return system.label.WORD015_TAG125;}//Delete Territory
    public String getTAG126() {return system.label.WORD015_TAG126;}//Select
    public String getTAG127() {return system.label.WORD015_TAG127;}//Territory
    public String getTAG128() {return system.label.WORD015_TAG128;}//Search Territory by entering the keyword
    public String getTAG129() {return system.label.WORD015_TAG129;}//Go!
    public String getTAG130() {return system.label.WORD015_TAG130;}//Add Selected
    public String getTAG131() {return system.label.WORD015_TAG131;}//Calendar Search Start Date must be earlier than Calendar Search End Date 
    public String getTAG132() {return system.label.WORD015_TAG132;}//Invalid Calendar Search Start Days
    public String getTAG133() {return system.label.WORD015_TAG133;}//Invalid Calendar Search End Days 
    public String getTAG134() {return system.label.WORD015_TAG134;}//Invalid Weight Time Window
    public String getTAG135() {return system.label.WORD015_TAG135;}//Invalid Weight Total Distance
    public String getTAG136() {return system.label.WORD015_TAG136;}//Invalid Weight Route Distance
    public String getTAG137() {return system.label.WORD015_TAG137;}//Invalid Weight Route Time
    public String getTAG138() {return system.label.WORD015_TAG138;}//Invalid Weight Node Type
    public String getTAG139() {return system.label.WORD015_TAG139;}//Dispatch Process definition is incomplete as it could not be saved on the OptiMax Server due to the following error:
    public String getTAG140() {return system.label.WORD015_TAG140;}//Back To Dispatch Process
    public String getTAG141() {return system.label.WORD015_TAG141;}//Dispatch Process saved successfully!
    public String getTAG142() {return system.label.WORD015_TAG142;}//Please select a valid value for Start Time (GMT)
    public String getTAG143() {return system.label.WORD015_TAG143;}//Please select a valid value for Start Date
    public String getTAG144() {return system.label.WORD015_TAG144;}//Start Date must be greater than or equal to today (GMT)
    public String getTAG145() {return system.label.WORD015_TAG145;}//Territory should not be blank
    public String getTAG146() {return system.label.WORD015_TAG146;}//This Territory is already associated with another dispatch process
    public String getTAG147() {return system.label.WORD015_TAG147;}// Reference for rescheduling Work Order
    public String getTAG148() {return system.label.WORD015_TAG148;}//Retain Appointment   
    public String getTAG149() {return system.label.WORD015_TAG149;}//Retain Assignment
    public String getTAG150() {return system.label.WORD015_TAG150;}//Start after
    public String getTAG151() {return system.label.WORD015_TAG151;}//days and Schedule for
    public String getTAG152() {return system.label.WORD015_TAG152;}//number of Days.
    public String getTAG153() {return system.label.WORD015_TAG153;}//Overtime Tolerance(Min)
    public String getTAG154() {return system.label.WORD015_TAG154;}//Dispatch Goals
    public String getTAG155() {return system.label.WORD015_TAG155;}//Delete
    public String getTAG156() {return system.label.WORD015_TAG156;}//Add Schedule
    public String getTAG157() {return system.label.WORD015_TAG157;}//Quick Add
    public String getTAG158() {return system.label.WORD015_TAG158;}//Select
    public String getTAG159() {return system.label.WORD015_TAG159;}//Type of run
    public String getTAG160() {return system.label.WORD015_TAG160;}//Run At
    public String getTAG161() {return system.label.WORD015_TAG161;}//Timezone
    public String getTAG162() {return system.label.WORD015_TAG162;}//Using the expression-builder below, define the unique criteria that allow work orders to be considered by incremental run.
    public String getTAG163() {return system.label.WORD015_TAG163;}//Please select �days� or �hours� as the lead time unit for Full run    
    public String getTAG165() {return system.label.WORD015_TAG165;}//End Time
    public String getTAG166() {return system.label.WORD015_TAG166;}//Add
    public String getTAG168() {return system.label.WORD015_TAG168;}//hours
    public String getTAG169() {return system.label.WORD015_TAG169;}//Full
    public String getTAG170() {return system.label.WORD015_TAG170;}//Incremental
    public String getTAG171() {return system.label.WORD015_TAG171;}//Full run:
    public String getTAG172() {return system.label.WORD015_TAG172;}//Incremental run:
    public String getTAG173() {return system.label.WORD015_TAG173;}//not valid because of duplicate runs
    public String getTAG174() {return system.label.WORD015_TAG174;}//For Full run start after > 0 
    public String getTAG175() {return system.label.WORD015_TAG175;}//For Incremental run start after > 0
    public String getTAG176() {return system.label.WORD015_TAG176;}//Full runs existing in between the incremental runs.
    public String getTAG177() {return system.label.WORD015_TAG177;}//Please select atleast one schedule to save.
    public String getTAG178() {return system.label.WORD015_TAG178;}//Are you sure to delete selected record(s)?
    public String getTAG179() {return system.label.WORD015_TAG180;}//'Match Eligibility'
    public String getTAG180() {return system.label.WORD015_TAG181;}//'Match Expertise'
    public String getTAG181() {return system.label.WORD015_TAG182;}//'Match Product Specialization'
    public String getTAG182() {return system.label.WORD015_TAG183;}//'Consider Preferred Technician '
    public String getTAG183() {return system.label.WORD015_TAG179;}//'Specify the Technician attribute to match against Work Order and their weightage. Values allowed are 1 to 10, with 10 denoting the highest weightage.'
    public String getTAG184() {return system.label.WORD015_TAG184;}//'Specify additional Technician parameters to be considered by OptiMax'
    public String getTAG185() {return system.label.WORD015_TAG185;}//'Zones'
    public String getTAG186() {return system.label.COMM001_TAG016;}//Active
    public String getTAG194() {return system.label.WORD015_TAG194;}//'Atleast one schedule has to be active'
    public String getTAG195() {return system.label.WORD015_TAG195;} // Dispatch Threshold (Minutes)
    public String getTAG196() {return system.label.WORD015_TAG196;} // Optimizer Sync Interval (Minutes)
    public String getTAG197() {return system.label.WORD015_TAG197;} // Schedule work orders for
    public String getTAG198() {return system.label.WORD015_TAG198;} // ECO Scheduling
    public String getTAG199() {return system.label.WORD015_TAG199;} // Please enter a value for dispatch threshold
    public String getTAG200() {return system.label.WORD015_TAG200;} // Dispatch Threshold value should be lesser than planning time horizon
    public String getTAG201() {return system.label.WORD015_TAG201;} // Please enter a value for optimizer sync interval
    public String getTAG202() {return system.label.WORD015_TAG202;} // This Territory does not have a Business Hour assigned
    public String getTAG203() {return system.label.WORD015_TAG203;} // This Territory does not have an active Business Hour assigned
    public String getTAG210() {return system.label.WORD015_TAG210;} // Total weight of the cost factors should be 100
    public String getTAG211() {return system.label.WORD015_TAG211;} // Capacity
    public String getTAG212() {return system.label.WORD015_TAG212;} // Capacity Threshold
    public String getTAG213() {return system.label.WORD015_TAG213;} // Define how the capacity threshold should be calculated
    public String getTAG214() {return system.label.WORD015_TAG214;} // Calculate capacity threshold per technician per day
    public String getTAG215() {return system.label.WORD015_TAG215;} // Please select only one rule to delete
    public String getTAG216() {return system.label.WORD015_TAG216;} // Define how jobs should be classified for the purpose of capacity limitation
    public String getTAG224() {return system.label.WORD015_TAG217;} // Please provide the correct advanced expression
    public String getTAG225() {return system.label.WORD015_TAG218;} // Enter a valid Capacity Threshold value 
    public String getTAG226() {return system.label.WORD015_TAG219;} // Capacity Threshold value cannot be greater than 100
    public String getTAG227() {return system.label.WORD015_TAG220;} // Capacity Threshold value cannot be lesser than or equal to 0
    
    public String getEcoDP()  {return 'Real Time Optimization';}
    public String getTAG204() {return System.Label.WORD014_TAG049;} // Inactive territory is being used
    public String getTAG205() {return system.label.WORD015_TAG205;} //Optimization Job Running Time Window
    public String getTAG206() {return system.label.WORD015_TAG206;} //24/7
    public String getTAG207() {return system.label.WORD015_TAG207;} //Territory Business Hours
    public String getTAG208() {return system.label.WORD015_TAG208;} //Before the shift begins, technicians should drive on their own time for up to (Minutes)
    public String getTAG209() {return system.label.WORD015_TAG209;} //After the shift ends, technicians should drive on their own time for up to (Minutes)
    public String getTAG217() {return system.label.COMM001_TAG112;}//'Please select only one Rule to perform this operation'
    public String getTAG218() {return system.label.COMM001_TAG111;}//'Please select a Rule to perform this operation'
    public String getTAG219() {return system.label.COMM001_TAG113;}//'Please enter a valid rule name'
    public string getTAG220() {return system.label.COMM001_TAG114;}//'Rule name should be at least 8 characters long'
    
    /** Introduced below 2 methods for LTP**/
    public string getTAG221(){return system.label.COMM001_TAG078;}//Run At
    public string getTAG222(){return system.label.COMM001_TAG079;}//'On These Days'
    public String getTAG223() {return system.label.COMM001_TAG103;}//Time zone
    public String getTAG228() {return system.label.WORD015_TAG221;}//Using the expression-builder below, define the unique criteria that allow work orders to be considered for long-term planning runs.
    public String getTAG229() {return system.label.WORD015_TAG222;}//Please indicate the time horizon for long-term planning.
    public String getTAG230() {return system.label.WORD015_TAG223;}//Please indicate when the Long-Term Planner should run.
    public String getlongTermPlannerDP() {return system.label.WORD015_TAG224;}//Long-Term Planner
    public String getTAG231() {return system.label.WORD015_TAG225;}//Run the Long-Term Planner (BETA)
     /*******************************************************Utility Methods**********************************************/
    public void RetriveField(String ObjName, List<selectOption> lst, Map<String,Schema.Displaytype> m, Map<String,String> m2)  //,list<sobject> ObjList
    {
        RetriveField(ObjName, lst, m, m2, null);
    }
    public void RetriveField2(String ObjName, List<selectOption> lst, Map<String,Schema.Displaytype> m, Map<String,String> m2, Schema.Displaytype DT)  //,list<sobject> ObjList
    {
        if(!mMapFieldList.containsKey(ObjName))
        {
            Schema.SObjectType objT = allObjs.get(objName) ;
            if(objT != null)
            {
                objfieldMap = objT.getDescribe().fields.getMap();
                mMapFieldList.put(ObjName, objfieldMap);
            }   
        }
        else
            objfieldMap = mMapFieldList.get(objName);
        for (String fieldKey : objfieldMap.keySet()) 
        {
            Schema.SObjectField fsObj = objfieldMap.get(fieldKey);
            Schema.DescribeFieldResult f = fsObj.getDescribe();
            if(DT != null && DT == f.getType())
            {
                Schema.SObjectType sobjRefTo = f.getReferenceTo()[0];
                Schema.DescribeSObjectResult dsobjresRefTo = sobjRefTo.getDescribe();
                lst.add(new SelectOption(dsobjresRefTo.getName() + '~' + f.getName(),dsobjresRefTo.getLabel() + '.' + f.getLabel()));
            }
            
            if(m != null)
                m.put(f.getName(), f.getType());
            if(m2 != null)
                m2.put(f.getName(),f.getLabel());   
        }
        sortingSelectOption(lst, true);
    }   
    public void RetriveField(String ObjName, List<selectOption> lst, Map<String,Schema.Displaytype> m, Map<String,String> m2, Schema.Displaytype DT)  //,list<sobject> ObjList
    {
        if(!mMapFieldList.containsKey(ObjName))
        {
                
            Schema.SObjectType objT = allObjs.get(objName); 
            if(objT != null)
            {
                objfieldMap = objT.getDescribe().fields.getMap();
                mMapFieldList.put(ObjName, objfieldMap);
            }   
        }
        else
            objfieldMap = mMapFieldList.get(objName);
            
        //-------Start-------Added for fixing defect BAC-4488
        if(objfieldMap != null && objfieldMap.size() > 0){
            COMM_Utils_V2 objCommUtilV2 = new COMM_Utils_V2();
            objfieldMap = objCommUtilV2.removeDuplicateFields(objfieldMap);
        }
        //-------End---------Added for fixing defect BAC-4488
        for (String fieldKey : objfieldMap.keySet()) 
        {
            Schema.SObjectField fsObj = objfieldMap.get(fieldKey);
            Schema.DescribeFieldResult f = fsObj.getDescribe();
            if(f.getType() == schema.Displaytype.REFERENCE)  
            {
                if(utils.SVMX_isObjectCustom(String.valueof(f.getReferenceTo()[0])))
                {
                    if(DT != null && DT == f.getType())
                        lst.add(new SelectOption(f.getName(),f.getLabel()));
                    if(DT == null)
                        lst.add(new SelectOption(f.getName(),f.getLabel()));
                    if(m != null)
                        m.put(f.getName(), f.getType());
                    if(m2 != null)
                        m2.put(f.getName(),f.getLabel());   
                }
                if(utils.SVMX_isObjectCustom(String.valueof(f.getReferenceTo()[0])) == false)
                {
                    if((PermitedStndObjMap.containsKey(String.valueof(f.getReferenceTo()[0])) || IsEnterpriseLicense))
                    {
                        if(DT != null && DT == f.getType())
                            lst.add(new SelectOption(f.getName(),f.getLabel()));
                        if(DT == null)
                            lst.add(new SelectOption(f.getName(),f.getLabel()));
                        if(m != null)
                            m.put(f.getName(), f.getType());
                        if(m2 != null)
                            m2.put(f.getName(),f.getLabel()); 
                    }
                }       
            }
            if(f.getType() != schema.Displaytype.REFERENCE)
            {
                if(DT != null && DT == f.getType())
                    lst.add(new SelectOption(f.getName(),f.getLabel()));
                if(DT == null)
                    lst.add(new SelectOption(f.getName(),f.getLabel()));
                if(m != null)
                    m.put(f.getName(), f.getType());
                if(m2 != null)
                    m2.put(f.getName(),f.getLabel()); 
            }
              
        }
        sortingSelectOption(lst, true);
    }         
    public void RetriveField(String ObjName, List<selectOption> lst, Map<String,Schema.Displaytype> m, Map<String,String> m2, Schema.Displaytype DT, string LCObjName)  //,list<sobject> ObjList
    {
        if(!mMapFieldList.containsKey(ObjName))
        {
            Schema.SObjectType objT = allObjs.get(objName) ;
            if(objT != null)
            {
                objfieldMap = objT.getDescribe().fields.getMap();
                mMapFieldList.put(ObjName, objfieldMap);
            }   
        }
        else
            objfieldMap = mMapFieldList.get(objName);
        for (String fieldKey : objfieldMap.keySet()) 
        {
            Schema.SObjectField fsObj = objfieldMap.get(fieldKey);
            Schema.DescribeFieldResult f = fsObj.getDescribe();
            if(schema.Displaytype.REFERENCE == f.getType() && string.valueOf(f.getReferenceTo()[0]) == LCObjName)
                lst.add(new SelectOption(f.getName(),f.getLabel()));
            if(m != null)
                m.put(f.getName(), f.getType());
            if(m2 != null)
                m2.put(f.getName(),f.getLabel());   
        }
        sortingSelectOption(lst, true);
    }
    
    public List<SelectOption> sortingSelectOption(List<SelectOption> so, boolean bSortByLabel)
    {
        try
        {
            map<string, selectOption> mapTemp = new map<string, SelectOption>();
            if(bSortByLabel)
            {
                 for(selectOption o :so)
                 {  
                    mapTemp.put(o.getLabel()+'-'+o.getValue(), o);
                 }
            }
            else
            {
                 for(selectOption o :so)
                 {
                     mapTemp.put(o.getValue()+'-'+o.getLabel(), o);
                 }
            }
            list<string> lstTemp = new list<string>();
            lstTemp.addAll(mapTemp.KeySet());
            lstTemp.sort();
            so.clear();
            for(string str: lstTemp)
            {       
                so.add(mapTemp.get(str));
            }
        }
        catch(exception ex)
        {
            ApexPages.addMessage(new ApexPages.Message ( ApexPages.Severity.ERROR, ex.getmessage()));
        }
        return so;
    }
    public map<String,String> SVMX_getPickListValues(String FieldName)
    {
        Map<String,String> MapOfPiclListvalues = new Map<String,String>();
        Map<String,Schema.SObjectField> objfieldMap = new Map<String,Schema.SObjectField>();
        objfieldMap = Schema.SObjectType.SVMXC__ServiceMax_Processes__c.fields.getMap(); 
        for(Schema.SObjectField fld:objfieldMap.values())
        {
            Schema.DescribeFieldResult FSO = fld.getDescribe();
            if(FSO != null && FSO.getname() == FieldName)
            {
                if(FSO.getType() == Schema.DisplayType.PickList)
                {
                    List<Schema.PicklistEntry> P = FSO.getPicklistValues(); // returing picklist values
                    for(integer v=0;v<p.size();v++)
                    {
                        MapOfPiclListvalues.put(p[v].getLabel(),p[v].getValue()); 
                    }
                }
            }  
        }
        return MapOfPiclListvalues;
    }
    
}