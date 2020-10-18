public  with sharing class CONF_SetupHome{

    //-----------------------NPS Related...
    public string getUserLocaleKey(){
        return UserInfo.getLanguage();
    }
    public string getUserID(){
        return UserInfo.getUserId().substring(0, 15);
    }
    public string getUserOrgID(){
        return UserInfo.getOrganizationId().substring(0, 15);
    }
   
   
    //-------------------------------------
    SVMXC.COMM_Utils objCOMM_Utils = new SVMXC.COMM_Utils();
    public String AvailableServicesHomeURL = null;
    public String SkillsHomeURL = null;
    public String TaskTemplatesHomeURL = null;
    public String BookingWindowsHomeURL = null;
    
    // added on 11/sep/2012
    public String ActivityMasterHomeURL = null;
    public String PMPlanTemplatesHomeURL = null;
    public String ServicePlansHomeURL = null;
    public String ServicePricebooksHomeURL = null;
    public String WarrantyTermsHomeURL = null;
    // added on 11/sep/2012
    
    public String strAPLDispaly = 'none'; // Currently It is visible, After introducing setting, default set to hide...
    public String getstrAPLDispaly(){return this.strAPLDispaly;}
    public String setstrAPLDispaly(String str){return this.strAPLDispaly = str;}
    
    
     //BEGIN : Spring '17 -Sadiya - Overnight Policy Changes
     public String overnightPolicyHomeURL = null;
    //END : Spring '17 -Sadiya - Overnight Policy Changes
    
    public String GetSvmxLogoId()
    {
        List<Document> DocList = [Select Id, Name From Document where Name = 'ServiceMax Logo' limit 1]; //SDL-SVMX-FLS-NOT-ENFORCED-META-DATA
        //List<Document> DocList = [Select Id, Name From Document where Name = 'SVMX_Logo' limit 1];
        //String retURL = ApexPages.currentPage().getHeaders().get('Host');
        if(DocList != null && DocList.size() > 0)
        {
            //return 'http://' + retURL + '/' + DocList[0].Id;
            return '/servlet/servlet.FileDownload?file=' + DocList[0].Id;
        }
        else
            return 'File not found';
    }
    public SVMXC.COMM_Utils_ManageSettings commSettings = new SVMXC.COMM_Utils_ManageSettings();
    public Map<String, String> svmxSettingList = new Map<String,String>();
    public Map<String, String> svmxSettingToEnableAPL = new Map<String,String>();
    public Integer intMaxTimeCheckForButtonEnabled = 60;
    
   
    //Neeraj(Sept-2nd): Removed string.escapeSingleQuotes method becouse of Translation issues.....
    public String getTAG001() {return System.Label.CONF005_TAG001;}    // Welcome to ServiceMax Setup Home.
    public String getTAG002() {return System.Label.CONF005_TAG002;}    // ServicMax Setup Home
    public String getTAG003() {return System.Label.CONF005_TAG003;}    // You can use this screen to configure ServiceMax application for your users.
    public String getTAG021() {return System.Label.CONF005_TAG021;}    // Setup Home Help display
    public String getHLPURL() {return System.Label.CONF005_HLPURL;}    // Help URL
    
    public String getTagTEXT11() {return System.Label.CONF005_TEXT11;}    // Modules
    public String getTagTEXT12() {return System.Label.CONF005_TEXT12;}    // Submodules
    public String getTagTEXT13() {return System.Label.CONF005_TEXT13;}    // Settings
    public String getTagTEXT14() {return System.Label.CONF005_TEXT14;}    // Display Tags
    public String getTagTEXT15() {return System.Label.CONF005_TEXT15;}    // Translations
    public String getTagTEXT16() {return System.Label.CONF005_TEXT16;}    // Object Mapping
    public String getTagTEXT17() {return System.Label.CONF005_TEXT17;}    // Configuration Profiles
    public String getTagTEXT104() {return System.Label.CONF005_TEXT104;}    // Configuration Profiles
    public String getTagTEXT18() {return System.Label.CONF005_TEXT18;}    // Service Org
    public String getTagTEXT19() {return System.Label.CONF005_TEXT19;}    // Territories
    public String getTagTEXT20() {return System.Label.CONF005_TEXT20;}    // Inventory Processes
    public String getTagTEXT21() {return System.Label.CONF005_TEXT21;}    // MTTS Rules
    public String getTagTEXT22() {return System.Label.CONF005_TEXT22;}    // Territory Match Rules
    public String getTagTEXT23() {return System.Label.CONF005_TEXT23;}    // Dispatch Processes
    public String getTagTEXT24() {return System.Label.CONF005_TEXT24;}    // Auto Entitlement Rules
    public String getTagTEXT25() {return System.Label.CONF005_TEXT25;}    // OptiMax Settings
    public String getTagTEXT26() {return System.Label.CONF005_TEXT26;}    // Counter Rules
    public String getTagTEXT27() {return System.Label.CONF005_TEXT27;}    // SLA terms
    public String getTagTEXT28() {return System.Label.CONF005_TEXT28;}    // Event Subject Rules
    public String getTagTEXT29() {return System.Label.CONF005_TEXT29;}    // Event Hover Rules
    public String getTagTEXT51() {return System.Label.CONF005_TEXT51;}    // Offline Profiles
    public String getTagTEXT52() {return System.Label.CONF005_TEXT52;}    // Process Designer
    public String getTagTEXT53() {return System.Label.CONF005_TEXT53;}    // Available Services Home
    public String getTagTEXT54() {return System.Label.CONF005_TEXT54;}    // Skills Home
    public String getTagTEXT55() {return System.Label.CONF005_TEXT55;}    // Task Templates Home
    public String getTagTEXT56() {return System.Label.CONF005_TEXT56;}    // Booking Windows Home
    public String getTagTEXT57() {return System.Label.CONF005_TEXT57;}    // iPad App Configuration
    
    public String getTagTEXT58() {return System.Label.CONF005_TEXT58;}    // Toolbars
    public String getTagTEXT59() {return System.Label.CONF005_TEXT59;}    // Actions
    public String getTagTEXT60() {return System.Label.CONF005_TEXT60;}    // Process Access
    public String getTagTEXT61() {return System.Label.CONF005_TEXT61;}    // TDM Migration Tool
    public String getTagTEXT62() {return System.Label.CONF005_TEXT62;}    // Dispatch Console Field Updates
    
    public String getTagTEXT70() {return System.Label.CONF005_TEXT70;}    // 'Receving Processes'
    public String getTagTEXT71() {return System.Label.CONF005_TEXT71;}    // 'Shipping Processes'
    public String getTagTEXT78() {return System.Label.CONF005_TEXT72;}     // 'Fulfillment process'
    public String getTagTEXT73() {return System.Label.CONF005_TEXT73;}    // 'Search Configuration'
    public String getTagTEXT74() {return System.Label.CONF005_TEXT74;}    // 'Routing Rules'
    
    public String getTagTEXT77() {return System.Label.CONF005_TEXT75;}     // Inventory Org Setup'
    public String getTagTEXT76() {return System.Label.CONF005_TEXT76;}    // 'Initiate Return Processes'
    public String getTagTEXT79() {return System.Label.CONF005_TEXT79;}      //'Forward Shipments'
    public String getTagTEXT80() {return System.Label.CONF005_TEXT80;}      //'Rev & Subs'
    public String getTagTEXT81() {return System.Label.CONF005_TEXT81;}     //'Outbound Route Calculation'
    public String getTagTEXT72() {return System.Label.CONF005_TEXT82;}    // 'Mobile Configuration
    public String getTagTEXT82() {return System.Label.CONF005_TEXT78;}     //'Delivery Rules' 
    public String getTagTEXT75() {return System.Label.CONF005_TEXT84;}    //Work Order Views
    public String getTagTEXT83() {return System.Label.CONF005_TEXT85;}       //'SFM Expressions'
    public String getTagTEXT84() {return System.Label.CONF005_TEXT87;}  //    'Service Contract Billing Process'
    public String getTagTEXT85() {return System.Label.CONF005_TEXT88;}  //    'Work Order Billing Process'
    public String getTagTEXT86() {return System.Label.CONF005_TEXT89;}  //   'Manage PM Process'
    public String getTagTEXT87() {return System.Label.CONF005_TEXT86;}  //  'Auto Entitlement Rules-Work Order'
    public String getTagTEXT88() {return System.Label.CONF005_TEXT91;}  //   'DC MAP Hover'     
    // added on 11/sep/2012
    public String getTagTEXT89() {return System.Label.CONF005_TEXT93;}//'Activity Master'
    public String getTagTEXT90() {return System.Label.CONF005_TEXT94;} //'PM Plan Templates'
    public String getTagTEXT91() {return System.Label.CONF005_TEXT95;} //'Service Plans'
    public String getTagTEXT92() {return System.Label.CONF005_TEXT96;} //'Service Pricebooks'
    public String getTagTEXT93() {return System.Label.CONF005_TEXT97;} //'Warranty Terms'
    public String getTagTEXT94() {return System.Label.CONF005_TEXT98;} //Server Cache
    public String getTagTEXT95() {return System.Label.CONF005_TEXT99;}//'Manage Technician Eligibility'
    public String getTagTEXT96() {return System.Label.CONF005_TEXT100;}//'Manage Skill Match Rules'
    public String getTagTEXT97() {return System.Label.CONF005_TEXT101;}//'SFM Business Rules'
    public String getTagTEXT98() {return System.Label.CONF005_TEXT102;}//'Scheduled SFM'
    public String getTagTEXT99() {return System.Label.CONF005_TEXT103;}//'Work Order Priority Rules'
    public String getTagTEXT100() {return System.Label.CONF005_TEXT104;}//'Notification'
    public String getTagTEXT101() {return System.Label.CONF005_TEXT106 ;}
    public String getTagTEXT102() {return System.Label.CONF005_TEXT107 ;} // Question Bank Manager
    public String getTagTEXT103() {return System.Label.CONF005_TEXT108 ;}  // Timesheet
    public String getTagTEXT105() {return System.Label.CONF005_TEXT109 ;}  // Service Performance Metrics Setup
    public String getTagTEXT106() {return System.Label.CONF005_TEXT111 ;}  //IOT Setup
    public String getTagTEXT107() {return System.Label.CONF005_TEXT112 ;}  // Application Filters
    public String getTagTEXT108() {return System.Label.CONF005_TEXT113 ;}  // Scheduled Service Performance Metrics Setup
    public String getTagTEXT115() {return System.Label.CONF005_TEXT115 ;}   // Spring17 - Sadiya - Overnight Set up 
    public String getTagTEXT116() {return System.Label.CONF005_TEXT116 ;}  //Spring 17 - Anush - Appointment Offers
    public String getTagTEXT127() {return System.Label.CONF005_TEXT144 ;}  //Deploy ServiceMax Configuration
    public String getTagTEXT126() {return System.Label.CONF005_TEXT142 ;}  //FCO - BAC-5679
    
    //Story 2396
     public String getTagTEXT118() {return System.Label.CONF005_TEXT118;}    // Spare Parts
    //Story 2396
    
    //Story 2396
    public String getTagTEXT119() {return System.Label.CONF005_TEXT119;}    // Trigger setting
    //Story 2396
    /*
        Story BAC-3445
        TBD : Create Custom Label
    */
    public String getTagTEXT120() {return System.Label.CONF005_TEXT120;} //Checklist import
    
    /*
        Story BAC-3825
    */
    public String getTagTEXT121() {return System.Label.CONF005_TEXT121;} //Feature Administartion
    
    //Story BAC-4834
    public String getTagTEXT122() {return System.Label.CONF005_TEXT122;} //Service Flow Automation(SFA) 
    //Start BAC-5151
    public String getTagTEXT123() {return System.Label.CONF007_NAME1;} // Checklist Designer.
    public String getTagTEXT124() {return System.Label.CONF005_TEXT124;}  // Smart Documents. //BAC-4764
    public String getTagTEXT125() {return System.Label.CONF005_TEXT125;} // Transaction. //BAC-4764
    //End BAC-5151

    public String getTagGroupText1() {return System.Label.CONF005_TEXT63;}  //General App Administration
    public String getTagGroupText2() {return System.Label.CONF005_TEXT64;}  //Define Service Organization    
    public String getTagGroupText3() {return System.Label.CONF005_TEXT65;}  //'Installed Base & PM' editing...
    public String getTagGroupText4() {return System.Label.CONF005_TEXT66;}  //Dispatch Management
    public String getTagGroupText5() {return System.Label.CONF005_TEXT67;}  //Mobile & Offline
    public String getTagGroupText6() {return System.Label.CONF005_TEXT68;}  //Service Flow Manager
    public String getTagGroupText7() {return System.Label.CONF005_TEXT77;}  // 'Advance Parts Logistics'
    public string getTagGroupText8() {return System.Label.CONF005_TEXT90;} //   'Warranties & Service Contracts' editing...
    public string getTagGroupText9() {return System.Label.CONF005_TEXT105;} 
    public string getTagGroupText10() {return System.Label.CONF005_TEXT110;} //Service Performance Metrics
    public string getTagGroupText11() {return System.Label.CONF005_TEXT123;} //Scheduling & Optimization
    public String getTagGroupText12() {return System.Label.CONF007_GROUPTITLE001;}    // Checklist Manager. BAC-5151
    public String getTagGroupDes12() {return System.Label.CONF007_GROUPDEC001;}    // Checklist Dec. BAC-5151
    // added on 11/sep/2012
    //public String getTagGroupText9() {return System.Label.CONF005_TEXT92;}//'Service Billing'
    // added on 11/sep/2012
    
    //Group discription:
    public String getTagGroupDes1() {return System.Label.CONF005_DESC63;}  //Options related to general administration of ServiceMax. This includes setting up of custom functionality such as Modules, Submodules etc. and configuring various user profiles.
    public String getTagGroupDes2() {return System.Label.CONF005_DESC64;}  //Options related to setting up various entities in your service organizations such as service teams, territories, technicians, skill sets etc.
    public String getTagGroupDes3() {return System.Label.CONF005_DESC65;}  //' 'This section includes options for managing installed product counters, defining & managing Preventive maintenance activities and configuring & scheduling the PM engine.' editing...
    public String getTagGroupDes4() {return System.Label.CONF005_DESC66;}  //This group contains various options related to interactive as well as automatic dispatching features of ServiceMax.
    public String getTagGroupDes5() {return System.Label.CONF005_DESC67;}  //Various configuration options available for the mobile and offline deployments of ServiceMax. This includes offline user profiles, data sets as well as options related to iPad mobile client.
    public String getTagGroupDes6() {return System.Label.CONF005_DESC68;}  //Options for managing SFM actions, SFM transactions, inventory processes and SFM wizards. SFM transactions can be migrated between two Salesforce instances using the SFM Migrator tool.
    
     public String getTagGroupDes7() {return System.Label.CONF005_DESC77 ;}  // 'Advance Parts Logistics'
     public String getTagGroupDes8() {return System.Label.CONF005_DESC90;}//   'This section provides options for managing entitlement definitions including Warranties, SLA\'s and Service Plans. It also includes options for configuring entitlements on case & work order and for setting up invoice generation processes.'
     public String getTagGroupDes9() {return System.Label.CONF005_DESC105;}
     public String getTagGroupDes10() {return System.Label.CONF005_DESC109;} //This group contains various setup and configuration options for Service Performance Metrics.
     public String getTagGroupDes11() {return System.Label.CONF005_DESC123;} //This group contains various setup and configuration options for Scheduling & Optimization.
     // added on 11/sep/2012
    //public String getTagGroupDes9() {return System.Label.CONF005_DESC92;}//'Service Billing'
    // added on 11/sep/2012
    
    // Group Name:
    public String getTagGroupName1() {return System.Label.CONF005_NAME63;}  //  App Administration
    public String getTagGroupName2() {return System.Label.CONF005_NAME64;}  //  Service Organization
    public String getTagGroupName3() {return System.Label.CONF005_NAME65;}  // 'Installed Base & PM' editing...
    public String getTagGroupName4() {return System.Label.CONF005_NAME66;}  //   Dispatch Management
    public String getTagGroupName5() {return System.Label.CONF005_NAME67;}  //   Mobile & Offline
    public String getTagGroupName6() {return System.Label.CONF005_NAME68;}   //  Service Flows  
    public String getTagGroupName7() {return System.Label.CONF005_NAME77;}  //     'Advance Parts Logistics'
    public String getTagGroupName8() {return System.Label.CONF005_NAME90;} //  'Warranties & Service Contracts' 
    public String getTagGroupName9() {return system.Label.CONF005_NAME105;}
    public String getTagGroupName10() {return system.Label.CONF005_NAME109;} //Service Performance Metrics
    public String getTagGroupName11() {return system.Label.CONF005_NAME123;} //Scheduling & Optimization
    public String getTagGroupName12() {return System.Label.CONF007_GROUPNAME001;}    // Checklist Manager. BAC-5151
    // added on 11/sep/2012
    //public String getTagGroupName9() {return System.Label.CONF005_NAME92;}//'Service Billing'
    // added on 11/sep/2012
    
    public String getTagGroupNote() {return System.Label.CONF005_TEXT83;}       //      Indicates pre-release item
    
    public String getTagDESC11() {return System.Label.CONF005_DESC11;}    // Module is a collection of related functionality. This screen lists the standard modules installed with ServiceMax and also allows to define custom modules that can be built as ServiceMax extensions.
    public String getTagDESC12() {return System.Label.CONF005_DESC12;}    // Submodule is a specific functionality within a module. This screen lists the standard submodules installed with ServiceMax and also allows to define custom submodules that can be built as ServiceMax extensions.
    public String getTagDESC13() {return System.Label.CONF005_DESC13;}    // Settings are configurable parameters based on which functionality in a submodule changes. This page lists the standard settings in a given submodule and also allows to define custom settings.
    public String getTagDESC14() {return System.Label.CONF005_DESC14;}    // Display Tags are used in all ServiceMax screens on buttons, labels as well as messages. This screen lists standard display tags installed with ServiceMax and also allows to define custom tags that can be used in ServiceMax extensions.
    public String getTagDESC15() {return System.Label.CONF005_DESC15;}    // The display tags in ServiceMax can be translated into all languages supported by the Salesforce platform. Using this screen, you can enter translations for the tags by selecting a language from the list.
    public String getTagDESC16() {return System.Label.CONF005_DESC16;}    // Record mapping is used when a new record is created using an existing record. For example, RMA from a Case. Using this screen, you can view existing field mappings and create new field mappings.
    public String getTagDESC17() {return System.Label.CONF005_DESC17;}    // Configuration Profile is a collection of setting values linked to one or more users, and comprise of org-wide settings or group-wide settings. This screen allows the definition of configuration profiles, defining their access rights, and specifying the setting values.
    public String getTagDESC18() {return System.Label.CONF005_DESC18;}    // This feature provides a streamlined way to manage your service organization. Using this link, you can create or edit service teams and manage technicians and their details like their expertise, product specializations and cost.
    public String getTagDESC19() {return System.Label.CONF005_DESC19;}    // This link launches an interactive tree-based hierarchical way to manage your service territories along with the scope of coverage for each territory as well as soft (adjacent) territories.
    public String getTagDESC20() {return System.Label.CONF005_DESC20;}    // Use this link to view the standard pre-configured inventory processes in ServiceMax and to create your custom inventory processes.
    public String getTagDESC21() {return System.Label.CONF005_DESC21;}    // This screen allows your organization to define rules based on work order information to calculate MTTS (Mean Time To Service). MTTS is used by OptiMax for advanced dispatch optimization.
    public String getTagDESC22() {return System.Label.CONF005_DESC22;}    // This feature enables your organization to define how primary territory for work orders are calculated. This is useful when service territories across your organization have varying types of coverage.
    public String getTagDESC23() {return System.Label.CONF005_DESC23;}    // This feature lists all the dispatch processes defined in ServiceMax and allows you to create new, edit or delete existing processes.
    public String getTagDESC24() {return System.Label.CONF005_DESC24;}    // This feature allows your organization to define rules based on Case information to perform automatic entitlement  for cases created.
    public String getTagDESC25() {return System.Label.CONF005_DESC25;}    // Using this screen, you can manage the OptiMax user credentials and also configure org-wide email IDs to receive OptiMax related notifications.
    public String getTagDESC26() {return System.Label.CONF005_DESC26;}    // This screen allows your organization to define applicable counters based on Product information. Counters are then used to define coverage in warranty or service contract, capture readings for installed products, and to verify entitlements.
    public String getTagDESC27() {return System.Label.CONF005_DESC27;}    // This feature provides the ability to create, modify or delete SLA Terms. For each SLA Terms, users can define the scope of commitment for response, restoration and resolution times, as well as the scope of services included.
    public String getTagDESC28() {return System.Label.CONF005_DESC28;}    // This screen allows your organization to define rules based on work order fields. This rule is used by dispatch console to determine the default Subject for new events.
    public String getTagDESC29() {return System.Label.CONF005_DESC29;}    // This screen allows your organization to define rules based on work order fields. This rule is used by dispatch console to display relevant information on event hovers in the calendar section.
    public String getTagDESC51() {return System.Label.CONF005_DESC51;}    // ServiceMax Offline profile represents a collection of datasets and their attributes, and can be associated with one or more Salesforce profiles. This page enables you to define Offline profiles, data sets and their access permissions.
    public String getTagDESC52() {return System.Label.CONF005_DESC52;}    // Process Designer
    public String getTagDESC53() {return System.Label.CONF005_DESC53;}    // Available Services Home
    public String getTagDESC54() {return System.Label.CONF005_DESC54;}    // Skills Home
    public String getTagDESC55() {return System.Label.CONF005_DESC55;}    // Task Templates Home
    public String getTagDESC56() {return System.Label.CONF005_DESC56;}    // Booking Windows Home
    public String getTagDESC57() {return System.Label.CONF005_DESC57;}    // iPad App Configuration
    public String getTagDESC58() {return System.Label.CONF005_DESC58;}    // Manage Toolbars
    public String getTagDESC59() {return System.Label.CONF005_DESC59;}    // Manage Actions
    public String getTagDESC60() {return System.Label.CONF005_DESC60;}    // Manage Process Access
    public String getTagDESC61() {return System.Label.CONF005_DESC61;}    // Manage TDM Migration Tool
    public String getTagDESC62() {return System.Label.CONF005_DESC62;}    // Dispatch Console Field Updates 
    
    public String getTagDESC70() {return System.Label.CONF005_DESC70;}    // 'Receving Processes'
    public String getTagDESC71() {return System.Label.CONF005_DESC71;}    // 'Shipping Processes'
    public String getTagDESC72() {return System.Label.CONF005_DESC82;}    // 'Use this screen to configure how your end users will use ServiceMax Mobile Client on iPad. You can configure data download criteria, frequency of synchronization, limits that may apply to the size of offline data and more.'
    public String getTagDESC73() {return System.Label.CONF005_DESC73;}    // 'Search Configuration'
    public String getTagDESC74() {return System.Label.CONF005_DESC74;}    // 'Routing Rules'
    public String getTagDESC75() {return System.Label.CONF005_DESC84;}    // 'Use this option to view standard Work Order Views or to create custom Work Order Views. View definition includes the Work Order fields to be filtered upon, pre-filter conditions, and how the results are displayed.'
    public String getTagDESC76() {return System.Label.CONF005_DESC76;}    //'Initiate Return Processes'
    public String getTagDESC77() {return System.Label.CONF005_DESC75;}      //'ServiceMax Locations description';}           
    public String getTagDESC78() {return System.Label.CONF005_DESC72;}      //'Fulfillment process description';}            
    public String getTagDESC79() {return System.Label.CONF005_DESC79;}      //'Forward Shipments description';} 
    public String getTagDESC80() {return System.Label.CONF005_DESC80;}      //'Rev & Subs description';} 
    public String getTagDESC81() {return System.Label.CONF005_DESC81;}      //'Outbound Route Calculation description';}
    public String getTagDESC82() {return System.Label.CONF005_DESC78;}      //'Delivery Rules description';}
    public String getTagDESC83() {return System.Label.CONF005_DESC85;}      //'Manage SFM Expressions';}  'Manage SFM Expressions'
    public String getTagDESC84() {return System.Label.CONF005_DESC87;}//   'Manage Service Contract Billing Process'
    public String getTagDESC85() {return System.Label.CONF005_DESC88;}//   'Manage Work Order Billing Process'
    public String getTagDESC86() {return System.Label.CONF005_DESC89;}//    'Manage PM Process'
    public String getTagDESC87() {return System.Label.CONF005_DESC86;}//   'Auto Entitlement Rules-Work Order'
    public String getTagDESC88() {return System.Label.CONF005_DESC91;}//   'DC MAP Hover'
    //public String getTagDESC89() {return 'SFM Mapping Description';}//   SFM Mapping Description
    // added on 11/sep/2012
    public String getTagDESC89() {return System.Label.CONF005_DESC93;}//'Activity Master definition is used to define the activity and price related to activity performed.'
    public String getTagDESC90() {return System.Label.CONF005_DESC94;} //'This is a template for creating preventive maintenance plan, it has definitions for products, schedules and tasks that are needs to be performed as part of Preventive Maintenance.'
    public String getTagDESC91() {return System.Label.CONF005_DESC95;} //'Service Plan is a template for creating service contract, it has all coverage information along with detail pricing terms.'
    public String getTagDESC92() {return System.Label.CONF005_DESC96;} //'Represents a price book that contains the list of services that your organization sells.'
    public String getTagDESC93() {return System.Label.CONF005_DESC97;} //'Warranty Template allows organizations to define and standardize their warranty offering and apply it for a range of products automatically. A warranty template can be used to define the type and scope of coverage in a warranty such as parts, labor and expenses, and can then be associated with one or more products. When installed product records are created in ServiceMax, warranty will be calculated automatically based on the pre-defined warranty template associated with the product.'
    // added on 11/sep/2012
    public String getTagDESC94() {return System.Label.CONF005_DESC98;}//Use this option to manage the SFM server cache. This cache contains the metadata of one or more sObjects used across all SFM processes. When such an sObject's metadata is changed, it is mandatory to update the cache using this option.
    public String getTagDESC95() {return System.Label.CONF005_DESC99;}//'This feature enables your organization to define eligibility for work orders. This information is used to find the eligible technician while assigning technician to a work order.'
    public String getTagDESC96() {return System.Label.CONF005_DESC100;}//'This feature enables your organization to define required and optional skills required to complete work orders. This information is used to find the most appropriate technician while assigning technician to a work order.'
    
    public String getTagDESC97() {return System.Label.CONF005_DESC101;}//'Use this option to view standard SFM Rules or to create custom SFM Rules. SFM Rules can be designed to show an error or confirmation message when the defined criteria are met. The criteria consist of expressions and optional advanced expression for the target object records.'
    public String getTagDESC98() {return System.Label.CONF005_DESC102;}//'Manage Scheduled SFM description'
    public String getTagDESC99() {return System.Label.CONF005_DESC103;}
    public String getTagDESC100() {return System.Label.CONF005_DESC104;}//You can use this option to configure push notification for ServiceMax mobile applications.
    public String getTagDESC101() {return System.Label.CONF005_DESC106;}
    public String getTagDESC102() {return System.Label.CONF005_DESC108;}  //'You can use this option to manage questions for checklist.'
    public String getTagDESC103() {return System.Label.CONF005_DESC110;}  //'Use this option to configure the Service Performance Metrics generation criteria and schedule. You can also check the job status of metrics generation.
    public String getTagDESC107() {return System.Label.CONF005_DESC107;} // You can use this option to create Timesheet Configuration
    public String getTagDESC105() {return System.Label.CONF005_DESC111;}
    public String getTagDESC106() {return System.Label.CONF005_DESC112;} // Use Application Filters to hide ServiceMax Wizards and Wizards from specific mobile applications or from online/browser users. These settings will be applied to all SFM Wizards and Wizard Steps that are used in a User Profile.
    public String getTagDESC104() {return System.Label.CONF005_DESC113;}  //Allows user to generate and purge reports on Technician Utilization and Drive Times based on specific criteria.
    public String getTagDESC115() {return System.Label.CONF005_DESC115;} //This feature allows to define a policy for overnight stay of technicians in an organization.
    public String getTagDESC116() {return System.Label.CONF005_DESC116;} //Spring17 - Anush - Appointment offers are an advanced form of booking windows. They are defined at the work order, not the case level and are currently utilized by the Optimizer to help negotiate low cost appointments times with your customers. Appointments offered may be either arrival windows, or a promise to complete work within the allotted window.
    
    
    //Story
     public String getTagDESC118() {return System.Label.CONF005_DESC118;}    // Spare Parts
   
    //Storg
     public String getTagDESC119() {return System.Label.CONF005_DESC119;}    // Trigger Enable Disable Setting
    /* BAC - 3825 - Feature Permission Description
     * */
    public String getTagDESC121() {return System.Label.CONF005_DESC121;}    // Feature Permission Description

    public String getTagDESC120() {return System.Label.CONF005_DESC120;}    // Checklist import Description
    
    //Story BAC-4834
    public String getTagDESC122() {return System.Label.CONF005_DESC122;}    // SFA Description
    //Start BAC-4764
    public String getTagDESC124() {return System.Label.CONF005_DESC124;}    // Description for Smart Documents
    public String getTagDESC125() {return System.Label.CONF005_DESC125;}    // Description for Transactions
    public String getTagDESC126() {return System.Label.CONF007_DESC1;}      // Checklist Designer provides an interactive interface to define Checklist transactions. The configured Checklist transaction can then be deployed using SFM Wizard.
    //End BAC-4764
    //Story TOOL-2382
    public String getTagDESC128() {return System.Label.CONF005_DESC128;}    //Deploy ServiceMax Configuration
    public String getTagDESC127() {return System.Label.CONF005_DESC142;}    //FCO BAC-5679
    public String getTagNAME11() {return System.Label.CONF005_NAME11;}    // Manage Modules
    public String getTagNAME12() {return System.Label.CONF005_NAME12;}    // Manage Submodules
    public String getTagNAME13() {return System.Label.CONF005_NAME13;}    // Manage Settings
    public String getTagNAME14() {return System.Label.CONF005_NAME14;}    // Manage Translations
    public String getTagNAME15() {return System.Label.CONF005_NAME15;}    // Manage Display Tags
    public String getTagNAME16() {return System.Label.CONF005_NAME16;}    // Manage Object Mapping
    public String getTagNAME17() {return System.Label.CONF005_NAME17;}    // Manage Configuration Profiles
    public String getTagNAME18() {return System.Label.CONF005_NAME18;}    // Manage Service Org
    public String getTagNAME19() {return System.Label.CONF005_NAME19;}    // Manage Territories
    public String getTagNAME20() {return System.Label.CONF005_NAME20;}    // Manage Inventory Processes
    public String getTagNAME21() {return System.Label.CONF005_NAME21;}    // Setup MTTS Rules
    public String getTagNAME22() {return System.Label.CONF005_NAME22;}    // Setup Territory Match Rules
    public String getTagNAME23() {return System.Label.CONF005_NAME23;}    // Manage Dispatch Processes
    public String getTagNAME24() {return System.Label.CONF005_NAME24;}    // Setup Auto Entitlement Rules
    public String getTagNAME25() {return System.Label.CONF005_NAME25;}    // Manage OptiMax Settings
    public String getTagNAME26() {return System.Label.CONF005_NAME26;}    // Setup Counter Rules
    public String getTagNAME27() {return System.Label.CONF005_NAME27;}    // Manage SLA terms
    public String getTagNAME28() {return System.Label.CONF005_NAME28;}    // Setup Event Subject Rules
    public String getTagNAME29() {return System.Label.CONF005_NAME29;}    // Setup Event Hover Rules
    public String getTagNAME51() {return System.Label.CONF005_NAME51;}    // Manage Offline Profiles
    public String getTagNAME52() {return System.Label.CONF005_NAME52;}    // Process Designer
    public String getTagNAME53() {return System.Label.CONF005_NAME53;}    // Available Services Home
    public String getTagNAME54() {return System.Label.CONF005_NAME54;}    // Skills Home
    public String getTagNAME55() {return System.Label.CONF005_NAME55;}    // Task Templates Home
    public String getTagNAME56() {return System.Label.CONF005_NAME56;}    // Booking Windows Home
    public String getTagNAME57() {return System.Label.CONF005_NAME57;}    // iPad App Configuration
    
    public String getTagNAME58() {return System.Label.CONF005_NAME58;}    // Manage Toolbars
    public String getTagNAME59() {return System.Label.CONF005_NAME59;}    // Manage Actions
    public String getTagNAME60() {return System.Label.CONF005_NAME60;}    // Manage Process Access
    public String getTagNAME61() {return System.Label.CONF005_NAME61;}    // Manage TDM Migration Tool
    public String getTagNAME62() {return System.Label.CONF005_NAME62;}    //Dispatch Console Field Updates
    
    public String getTagNAME70() {return System.Label.CONF005_NAME70;}      //  'Manage Receving Processes'
    public String getTagNAME71() {return System.Label.CONF005_NAME71;}      //'Manage Shipping Processes'
    public String getTagNAME72() {return System.Label.CONF005_NAME82;}       // 'Manage Mobile Configuration
    public String getTagNAME73() {return System.Label.CONF005_NAME73;}      // 'Manage Search Configuration'
    public String getTagNAME74() {return System.Label.CONF005_NAME74;}       // 'Manage Routing Rules'
    public String getTagNAME75() {return System.Label.CONF005_NAME84;}       // 'Work Order Views'
    public String getTagNAME76() {return System.Label.CONF005_NAME76;}      // 'Initiate Return Processes '
    public String getTagNAME77() {return System.Label.CONF005_NAME75;}      //'Manage ServiceMax Locations';}                 
    public String getTagNAME78() {return System.Label.CONF005_NAME72;}      //'Manage Fulfillment process';}    
    public String getTagNAME79() {return System.Label.CONF005_NAME79;}      //'Manage Forward Shipments';}               
    public String getTagNAME80() {return System.Label.CONF005_NAME80;}      //'Manage Rev & Subs';}                      
    public String getTagNAME81() {return System.Label.CONF005_NAME81;}      //'Manage Outbound Route Calculation';}      
    public String getTagNAME82() {return System.Label.CONF005_NAME78;}      //'Manage Delivery Rules';}            
    public String getTagNAME83() {return System.Label.CONF005_NAME85;}      //'SFM Expressions'  'SFM Expressions'
    public String getTagNAME84() {return System.Label.CONF005_NAME87;}      //'Manage Service Contract Billing process'
    public String getTagNAME85() {return System.Label.CONF005_NAME88;}      //Manage Work Order Billing process'
    public String getTagNAME86() {return System.Label.CONF005_NAME89;}      //'Manage PM process'
    public String getTagNAME87() {return System.Label.CONF005_NAME86;}      //'Auto Entitlement Rules-Work Order'
    public String getTagNAME88() {return System.Label.CONF005_NAME91;}      //'DC MAP Hover'
    // added on 11/sep/2012
    public String getTagNAME89() {return System.Label.CONF005_NAME93;}//'Activity Master'
    public String getTagNAME90() {return System.Label.CONF005_NAME94;} //'PM Plan Templates'
    public String getTagNAME91() {return System.Label.CONF005_NAME95;} //'Service Plans'
    public String getTagNAME92() {return System.Label.CONF005_NAME96;} //'Service Pricebooks'
    public String getTagNAME93() {return System.Label.CONF005_NAME97;} //'Warranty Terms'
    public String getTagNAME94() {return System.Label.CONF005_NAME98;} // Manage Server Cache
    public String getTagNAME95() {return System.Label.CONF005_NAME99;}//'Manage Technician Eligibility';
    public String getTagNAME96() {return System.Label.CONF005_NAME100;}//'Manage Skill Match Rules'
    public String getTagNAME97() {return System.Label.CONF005_NAME101;}//'Manage SFM Business Rules'
    public String getTagNAME98() {return System.Label.CONF005_NAME102;}//'Manage Scheduled SFM'
    public String getTagNAME99() {return System.Label.CONF005_NAME103;}//'Work Order Priority Rules'
    public String getTagNAME100() {return System.Label.CONF005_NAME104;}//'Notifications'
    public String getTagNAME101() {return System.Label.CONF005_NAME106;}
    public String getTagNAME102() {return System.Label.CONF005_NAME108;}  //Question Bank Manager
    public String getTagNAME103() {return System.Label.CONF005_NAME107;}    // Timesheet Configuration
    public String getTagNAME104() {return System.Label.CONF005_NAME110;}    // Service Performance Metrics Setup
    public String getTagNAME105() {return System.Label.CONF005_NAME111;}
    public String getTagNAME106() {return System.Label.CONF005_NAME112;}    // Manage Application Filters
    public String getTagNAME107() {return System.Label.CONF005_NAME113;} //Schedule Optimization Metrics Setup
    public String getTagNAME115() {return System.Label.CONF005_NAME115;} //Overnight Policy set up
    public String getTagNAME116() {return System.Label.CONF005_NAME116 ;} //Spring 17 - Anush - Appointment Offers.
    
    //Story 2396
    public String getTagNAME118() {return System.Label.CONF005_NAME118 ;}     // Spar Part Layout on hover over Label
    //Story 2396
    // added on 11/sep/2012
    
    // JIRA STORY - 
    //Story 2396
    public String getTagNAME119() {return System.Label.CONF005_NAME119 ;}    // Trigger Label
    
    public String getTagNAME121() {return System.Label.CONF005_NAME121 ;}    // Manage Feature Permission
    
    //Story BAC-4834
    public String getTagNAME122() {return System.Label.CONF005_NAME122 ;}    // Service Flow Automation(SFA)
    
    //Story TOOL-2382
    public String getTagNAME125() {return System.Label.CONF005_NAME125 ;}    //Deploy ServiceMax Configuration
    
    //Story BAC-5679
    public String getTagNAME123() {return System.Label.CONF005_NAME124 ;}    //Setup Change Order Configuration
    
    public String getTagURL11() {return svmxSettingList.containsKey('SET011')?svmxSettingList.get('SET011'):'';}
    public String getTagURL12() {return svmxSettingList.containsKey('SET012')?svmxSettingList.get('SET012'):'';}
    public String getTagURL13() {return svmxSettingList.containsKey('SET013')?svmxSettingList.get('SET013'):'';}
    public String getTagURL14() {return svmxSettingList.containsKey('SET014')?svmxSettingList.get('SET014'):'';}
    public String getTagURL15() {return svmxSettingList.containsKey('SET015')?svmxSettingList.get('SET015'):'';}
    //public String getTagURL16() {return svmxSettingList.containsKey('SET016')?svmxSettingList.get('SET016'):'';} //Commented for BAC-4764
    public String getTagURL17() {return svmxSettingList.containsKey('SET017')?svmxSettingList.get('SET017'):'';}
    public String getTagURL18() {return svmxSettingList.containsKey('SET018')?svmxSettingList.get('SET018'):'';}
    public String getTagURL19() {return svmxSettingList.containsKey('SET019')?svmxSettingList.get('SET019'):'';}
    public String getTagURL20() {return svmxSettingList.containsKey('SET020')?svmxSettingList.get('SET020'):'';}
    public String getTagURL21() {return svmxSettingList.containsKey('SET021')?svmxSettingList.get('SET021'):'';}
    public String getTagURL22() {return svmxSettingList.containsKey('SET022')?svmxSettingList.get('SET022'):'';}
    public String getTagURL23() {return svmxSettingList.containsKey('SET023')?svmxSettingList.get('SET023'):'';}
    public String getTagURL24() {return svmxSettingList.containsKey('SET024')?svmxSettingList.get('SET024'):'';}
    public String getTagURL25() {return svmxSettingList.containsKey('SET025')?svmxSettingList.get('SET025'):'';}
    public String getTagURL26() {return svmxSettingList.containsKey('SET026')?svmxSettingList.get('SET026'):'';}
    public String getTagURL125() {return svmxSettingList.containsKey('SET112')?svmxSettingList.get('SET112'):'';}//BAC-5679
    public String getTagURL27() {return svmxSettingList.containsKey('SET027')?svmxSettingList.get('SET027'):'';}
    public String getTagURL28() {return svmxSettingList.containsKey('SET028')?svmxSettingList.get('SET028'):'';}
    public String getTagURL29() {return svmxSettingList.containsKey('SET029')?svmxSettingList.get('SET029'):'';}
    public String getTagURL51() {return svmxSettingList.containsKey('SET051')?svmxSettingList.get('SET051'):'';}
    //public String getTagURL52() {return svmxSettingList.containsKey('SET052')?svmxSettingList.get('SET052'):'';} //Commented for BAC-5151
    //Start BAC-5151
    public Boolean IsChecklistFeatureEnabled{get;set;}
    public String getTagURL52(){
        if(isHtmlView && svmxSettingList.containsKey('SET111')){ //Added for BAC-5627
            if(svmxSettingToEnableAPL.containsKey('GBL029') && svmxSettingToEnableAPL.get('GBL029') != null && Boolean.valueOf(svmxSettingToEnableAPL.get('GBL029'))){
                IsChecklistFeatureEnabled = Boolean.valueOf(svmxSettingToEnableAPL.get('GBL029'));
            }
            return svmxSettingList.get('SET111');
        }
        if(svmxSettingList.containsKey('SET052')){
            if(svmxSettingToEnableAPL.containsKey('GBL029') && svmxSettingToEnableAPL.get('GBL029') != null && Boolean.valueOf(svmxSettingToEnableAPL.get('GBL029'))){
                IsChecklistFeatureEnabled = Boolean.valueOf(svmxSettingToEnableAPL.get('GBL029'));
            }
            return svmxSettingList.get('SET052');
        }
        return '';
     }//apex/SVMXC__SFM_TDM_Designer?SVMX_retURL=/apex/SVMXC__CONF_SetupHome
    //End BAC-5151
    public String getTagURL53() {
        if(svmxSettingList.containsKey('SET073') && svmxSettingList.get('SET073') !=null)
            return AvailableServicesHomeURL;
        else
            return '';
    }
    public String getTagURL54() {
        if(svmxSettingList.containsKey('SET074') && svmxSettingList.get('SET074') !=null)
            return SkillsHomeURL;
        else
            return '';
    }
    public String getTagURL55() {
        if(svmxSettingList.containsKey('SET072') && svmxSettingList.get('SET072') !=null)
            return TaskTemplatesHomeURL;
        else
            return '';
    }
    public String getTagURL56() {
        if(svmxSettingList.containsKey('SET075') && svmxSettingList.get('SET075') !=null)
            return BookingWindowsHomeURL;
        else
            return '';
    }
    public String getTagURL57() {return svmxSettingList.containsKey('SET053')?svmxSettingList.get('SET053'):'';}
    public String getTagURL58() {return svmxSettingList.containsKey('SET054')?svmxSettingList.get('SET054'):'';}
    public String getTagURL59() {return svmxSettingList.containsKey('SET055')?svmxSettingList.get('SET055'):'';}
    public String getTagURL60() {return svmxSettingList.containsKey('SET056')?svmxSettingList.get('SET056'):'';}
    public String getTagURL61() {return svmxSettingList.containsKey('SET057')?svmxSettingList.get('SET057'):'';}
    public String getTagURL62() {return svmxSettingList.containsKey('SET058')?svmxSettingList.get('SET058'):'';}
    
    public String getTagURL63() {return svmxSettingList.containsKey('SET059')?svmxSettingList.get('SET059'):'';}
    public String getTagURL64() {return svmxSettingList.containsKey('SET060')?svmxSettingList.get('SET060'):'';} 
    
    public String getTagURL65() {return svmxSettingList.containsKey('SET069') && svmxSettingList.get('SET069') != '0' ? svmxSettingList.get('SET069'):'';}
    public String getTagURL66(){return svmxSettingList.containsKey('SET070') && svmxSettingList.get('SET070') != '0' ? svmxSettingList.get('SET070'):'';}
    public String getTagURL67() {return svmxSettingList.containsKey('SET063')?svmxSettingList.get('SET063'):'';}
    public String getTagURL68() {return svmxSettingList.containsKey('SET071') && svmxSettingList.get('SET071') != '0'? svmxSettingList.get('SET071'):'';}
    public String getTagURL69() {return svmxSettingList.containsKey('SET065')? svmxSettingList.get('SET065'):'';}
    public String getTagURL70(){return svmxSettingList.containsKey('SET064') && svmxSettingList.get('SET064') != '0' ? svmxSettingList.get('SET064'):'';}
    public String getTagURL71(){return svmxSettingList.containsKey('SET061') && svmxSettingList.get('SET061') != '0'? svmxSettingList.get('SET061'):'';}    
    public String getTagURL72(){return svmxSettingList.containsKey('SET066') && svmxSettingList.get('SET066') != '0'? svmxSettingList.get('SET066'):'';}
    public String getTagURL73(){return svmxSettingList.containsKey('SET067') && svmxSettingList.get('SET067') != '0'? svmxSettingList.get('SET067'):'';}
    public String getTagURL74(){return svmxSettingList.containsKey('SET068') && svmxSettingList.get('SET068') != '0'? svmxSettingList.get('SET068'):'';}
    public String getTagURL75(){return svmxSettingList.containsKey('SET062') && svmxSettingList.get('SET062') != '0'? svmxSettingList.get('SET062'):'';}
    //public String getTagURL76(){return svmxSettingList.containsKey('SET080') && svmxSettingList.get('SET080') != '0'? svmxSettingList.get('SET080'):'';} //Commented for BAC-4764
    
    public String getTagURL77(){return svmxSettingList.containsKey('SET076') && svmxSettingList.get('SET076') != '0'? svmxSettingList.get('SET076'):'';}
    public String getTagURL78(){return svmxSettingList.containsKey('SET077') && svmxSettingList.get('SET077') != '0'? svmxSettingList.get('SET077'):'';}
    public String getTagURL79(){return svmxSettingList.containsKey('SET078') && svmxSettingList.get('SET078') != '0'? svmxSettingList.get('SET078'):'';}// ;
    public String getTagURL80(){return svmxSettingList.containsKey('SET079') && svmxSettingList.get('SET079') != '0'? svmxSettingList.get('SET079'):'';}
    public String getTagURL81(){return svmxSettingList.containsKey('SET081') && svmxSettingList.get('SET081') != '0'? svmxSettingList.get('SET081'):'';}
    public String getTagURL87(){return svmxSettingList.containsKey('SET087') && svmxSettingList.get('SET087') != '0'? svmxSettingList.get('SET087'):'';}//'../apex/SVMXC__COMM_CreateServerCache'
    
    //start story 2396
    public String getTagURL118(){return svmxSettingList.containsKey('SET101') ? svmxSettingList.get('SET101'):'';}
    //End story 2396
    //
    
     //start story BAC-2126
     public String getTagURL119(){return svmxSettingList.containsKey('SET102') ? svmxSettingList.get('SET102'):'';}
     //End story BAC-2126
     
    
     //start story BAC-3825
     public String getTagURL121(){return svmxSettingList.containsKey('SET104') ? svmxSettingList.get('SET104'):'';}
     //End story BAC-3825
     
     //start story BAC-4834
     public String getTagURL122(){return svmxSettingList.containsKey('SET105') ? svmxSettingList.get('SET105'):'';}
     
    //Start BAC-4764
     public String getTagURL16(){
        if(isHtmlView){
            return svmxSettingList.containsKey('SET109')?svmxSettingList.get('SET109'):''; // HTML view need to get from setting
        }else{
            return svmxSettingList.containsKey('SET016')?svmxSettingList.get('SET016'):''; //Flash view
        }
     }
     public String getTagURL90(){
        if(isHtmlView){
            return svmxSettingList.containsKey('SET108')?svmxSettingList.get('SET108'):''; // HTML view need to get from setting  
        }else{
            return svmxSettingList.containsKey('SET090')?svmxSettingList.get('SET090'):''; //Flash view
        }
     }
     public String getTagURL76(){
        if(isHtmlView){
            return svmxSettingList.containsKey('SET107')?svmxSettingList.get('SET107'):''; // HTML view
        }else{
            return svmxSettingList.containsKey('SET080')?svmxSettingList.get('SET080'):''; //Flash view
        }
     }
     public String getTagURL123(){return svmxSettingList.containsKey('SET106') ? svmxSettingList.get('SET106'):'';} //HTML transactions 2.0
     public String getTagURL124(){return svmxSettingList.containsKey('SET110') ? svmxSettingList.get('SET110'):'';} //OPDOC 2.0
     //End BAC-4764
    // added on 11/sep/2012
    public String getTAGURL82() {
        if(svmxSettingList.containsKey('SET082') && svmxSettingList.get('SET082') !=null)
            return ActivityMasterHomeURL;
        else
            return '';
    }
    
    public String getTAGURL83() {
        if(svmxSettingList.containsKey('SET083') && svmxSettingList.get('SET083') !=null)
            return PMPlanTemplatesHomeURL;
        else
            return '';
    }
    
    public String getTAGURL84() {
        if(svmxSettingList.containsKey('SET084') && svmxSettingList.get('SET084') !=null)
            return ServicePlansHomeURL;
        else
            return '';
    }

    public String getTAGURL85() {
        if(svmxSettingList.containsKey('SET085') && svmxSettingList.get('SET085') !=null)
            return ServicePricebooksHomeURL;
        else
            return '';
    }
    public String getTAGURL86() {
        if(svmxSettingList.containsKey('SET086') && svmxSettingList.get('SET086') !=null)
            return WarrantyTermsHomeURL;
        else
            return '';
    }
    // added on 11/sep/2012
    public String getTagURL88(){return svmxSettingList.containsKey('SET088') && svmxSettingList.get('SET088') != '0'? svmxSettingList.get('SET088'):'';}//'../apex/WORD_ManageTechEligilibilityRules'
    
    public String getTagURL89(){return svmxSettingList.containsKey('SET089') && svmxSettingList.get('SET089') != '0'? svmxSettingList.get('SET089'):'';}//'../apex/WORD_ManageSkillMatchingRules'
    //public String getTagURL90(){return svmxSettingList.containsKey('SET090') && svmxSettingList.get('SET090') != '0'? svmxSettingList.get('SET090'):'';}///apex/SVMXC__SFM_BusinessRules?SVMX_retURL=/apex/SVMXC__CONF_SetupHome // Commented for BAC-4764
    public String getTagURL91(){return svmxSettingList.containsKey('SET091') && svmxSettingList.get('SET091') != '0'? svmxSettingList.get('SET091'):'' ;}//  '/apex/SVMXC__CONF_ManageScheduledSFM?SVMX_retURL=/apex/SVMXC__CONF_SetupHome'
    
    //Added for the defect 013392
    public String getTagURL92(){return svmxSettingList.containsKey('SET092') && svmxSettingList.get('SET092') != '0'? svmxSettingList.get('SET092'):'' ;}//  '/apex/SVMXC__WSCH_FieldMatchingRules?SVMX_retURL=/apex/SVMXC__CONF_SetupHome'
    //commented for the defect 013392
    //public String getTagURL92(){return '/apex/SVMXC__WSCH_FieldMatchingRules?SVMX_retURL=/apex/SVMXC__CONF_SetupHome';}    //  '/apex/SVMXC__WSCH_FieldMatchingRules?SVMX_retURL=/apex/SVMXC__CONF_SetupHome'
    
    //public String getTagURL93(){return '/apex/SVMXC__CONF_ManagePushNotifications';}//'/apex/SVMXC__CONF_ManagePushNotifications'
    public String getTagURL93(){return svmxSettingList.containsKey('SET093') && svmxSettingList.get('SET093') != '0'? svmxSettingList.get('SET093'):'' ;}//'/apex/SVMXC__CONF_ManagePushNotifications'
    public String getTagURL94(){
        return svmxSettingList.containsKey('SET096')?svmxSettingList.get('SET096'):'';
    }//'/apex/SVMXC__ProductIQSetup'
    public String getTagURL95(){
        if(svmxSettingList.containsKey('SET095')){
            if(svmxSettingToEnableAPL.containsKey('GBL029') && svmxSettingToEnableAPL.get('GBL029') != null && Boolean.valueOf(svmxSettingToEnableAPL.get('GBL029')))
                return svmxSettingList.get('SET095');
        }
        return '';
    }//'/apex/SVMXC__CONF_QuestionBankManager'
    public String getTagHLPURL() {return System.Label.CONF005_HLPURL;} //Add New Setting   
    public String getTagURL96() { 
        if( svmxSettingList.containsKey( 'SET094' ) ) {
            if( !svmxSettingToEnableAPL.containsKey('GBL027') || Boolean.valueOf( svmxSettingToEnableAPL.get('GBL027') ) ) {
                return svmxSettingList.get( 'SET094' );    
            }            
        }
        return '';
    }
    public String getTagURL97(){
        if(svmxSettingList.containsKey('SET097')){
            if(svmxSettingToEnableAPL.containsKey('GBL030') && svmxSettingToEnableAPL.get('GBL030') != null && Boolean.valueOf(svmxSettingToEnableAPL.get('GBL030'))){
                return svmxSettingList.get('SET097');
            }
        }
        return '';
    }//apex/SPM_configuration
    
    public String getTagURL98(){
        //return svmxSettingList.containsKey('SET096')?svmxSettingList.get('SET096'):'';
        return '/apex/SVMXC__IOTSetup';
    }
    
    public String getTagURL99(){
        return svmxSettingList.containsKey('SET098') ? svmxSettingList.get('SET098') : '';
    }//apex/SVMXC__CONF_ApplicationFilters
    
    public String getTagURL100() {      
        if(svmxSettingToEnableAPL.containsKey('GBL033') && svmxSettingToEnableAPL.get('GBL033') != null && Boolean.valueOf(svmxSettingToEnableAPL.get('GBL033'))){      
            return '/apex/SVMXC__SPM_OPT_Configuration';        
        }       
        return '';      
    }
    // Story TOOL-2382
    public String getTagURL101() {
        return 'DONT_NAVIGATE';
    }
    //public String getTagURL97(){return '/apex/SPM_configuration' ;}//  '/apex/SPM_configuration'
    //public String getTagURL97(){return svmxSettingList.containsKey('SET097') && svmxSettingList.get('SET097') != '0'? svmxSettingList.get('SET092'):'' ;}//  '/apex/SPM_configuration'
    public String getTagURL116() {return '/apex/SVMXC__WSCH_Provider_ECO_AppointmentWindowSetup';} // SPRING17 - Anush - Appointment Offers
     //BEGIN : Spring '17 -Sadiya - Overnight Policy Changes
     public String getTagURL102(){
        
         if(svmxSettingList.containsKey('SET100') && svmxSettingList.get('SET100') !=null)
            return overnightPolicyHomeURL;
        else
            return '';
        }
    //END : Spring '17 -Sadiya - Overnight Policy Changes
    
    //public String getTagURL120() {return 'https://tools.servicemax.com:49494/MigrationTool/ChecklistLogin.jsp';} 
    //Commented above line for fixing issue BAC-4013 and added below line for respect setting value for button URL
    public String getTagURL120() {return svmxSettingList.containsKey('SET103') && svmxSettingList.get('SET103') != null ? svmxSettingList.get('SET103') : ''; } 
    public String getLicenseType(){ return objCOMM_Utils.getSVMX_License(); }//Fetching License type of the product
    public String getVersionNo(){   return String.valueOf(Decimal.valueOf(String.valueOf(System.requestVersion())).setScale(5));    }//Fetching Version No. of the product
    public String getCONF005_TAG004(){  return System.Label.CONF005_TAG004; }//Version:
    public String getCONF005_TAG005(){  return System.Label.CONF005_TAG005; }//Servicemax respects all licensing permissions at runtime. Please ensure that each user is setup with the proper license type to gain access to specific features.    
    public Boolean isHtmlView{get;set;} // Added for BAC-4764
    public CONF_SetupHome()
    {
        try
        {
            svmxSettingToEnableAPL = commSettings.SVMX_getSettingList('GLOB001');
            svmxSettingList = commSettings.SVMX_getSettingList('CONF005');
             intMaxTimeCheckForButtonEnabled = Integer.valueOf(commSettings.SVMX_getGlobalSettingList('CONF039_SET001'));
        }
        catch(Exception ex)
        {
            ApexPages.addMessage(new ApexPages.Message ( ApexPages.Severity.ERROR,getTAG004()));
        }
         // Added for BAC-4764
        if(commSettings.SVMX_getGlobalSettingList('SFM001_SET006').equalsIgnoreCase('HTML')){
            isHtmlView = true;
        }else{
            isHtmlView = false;
        }
         // End for BAC-4764
        /**************** Check for APL setting *********************/
        if(svmxSettingToEnableAPL.containsKey('GBL014') && (svmxSettingToEnableAPL.get('GBL014') != null) && (Boolean.valueOf(svmxSettingToEnableAPL.get('GBL014')) == true))
            strAPLDispaly = 'block';
        else
            strAPLDispaly = 'none';
        MAP<String,Schema.SObjectType> allObjs = Schema.getGlobalDescribe();    
        Schema.SObjectType objT_AvailableServicesHome;
        Schema.SObjectType objT_SkillsHome;
        Schema.SObjectType objT_TaskTemplatesHome;
        Schema.SObjectType objT_BookingWindowsHome;
        
        // new added on 11/sep/2012
        Schema.SObjectType objT_ActivityMaster;
        Schema.SObjectType objT_PMPlanTemplates;
        Schema.SObjectType objT_ServicePlans;
        Schema.SObjectType objT_ServicePricebooks;
        Schema.SObjectType objT_WarrantyTerms;
        // added on 11/sep/2012
        
         //BEGIN : Spring '17 -Sadiya - Overnight Policy Changes
         Schema.SObjectType objT_OvernightPolicyHome;
          if( allObjs.get('SVMXC__SM_Overnight_Stay_Policy__c') != null )
            objT_OvernightPolicyHome = allObjs.get('SVMXC__SM_Overnight_Stay_Policy__c');
        else
            objT_OvernightPolicyHome = allObjs.get('SM_Overnight_Stay_Policy__c');
           
        if(objT_OvernightPolicyHome != null)
            overnightPolicyHomeURL = '/' + String.valueOf(objT_OvernightPolicyHome.getDescribe().getkeyPrefix());
         
        //END : Spring '17 -Sadiya - Overnight Policy Changes
        
        
        //Available services
        if( allObjs.get('SVMXC__Service__c') != null )
            objT_AvailableServicesHome = allObjs.get('SVMXC__Service__c');
        else
            objT_AvailableServicesHome = allObjs.get('Service__c');

        //Skills
        /* Commented by Naveen V on 02/11/2011
        if( allObjs.get('SVMXC__Service_Group_Skills__c') != null )
            objT_SkillsHome = allObjs.get('SVMXC__Service_Group_Skills__c');
        else
            objT_SkillsHome = allObjs.get('Service_Group_Skills__c');
        
        */
        
        if( allObjs.get('SVMXC__Skill__c') != null )
            objT_SkillsHome = allObjs.get('SVMXC__Skill__c');               //Added by Naveen V on 02/11/2011
        else
            objT_SkillsHome = allObjs.get('Skill__c');
            
        system.debug('Skill Object: '+ objT_SkillsHome);
        
        //Task Template
        if( allObjs.get('SVMXC__Task_Template__c') != null )
            objT_TaskTemplatesHome = allObjs.get('SVMXC__Task_Template__c');
        else
            objT_TaskTemplatesHome = allObjs.get('Task_Template__c');

        //Booking window
        if( allObjs.get('SVMXC__Booking_Window__c') != null )
            objT_BookingWindowsHome = allObjs.get('SVMXC__Booking_Window__c');
        else
            objT_BookingWindowsHome = allObjs.get('Booking_Window__c');        
        
        
        // added on 11/sep/2012
        
        if( allObjs.get('SVMXC__Activity_Master__c') != null )
            objT_ActivityMaster = allObjs.get('SVMXC__Activity_Master__c');
        else
            objT_ActivityMaster = allObjs.get('Activity_Master__c'); 
        
        if( allObjs.get('SVMXC__PM_Plan_Template__c') != null )
            objT_PMPlanTemplates = allObjs.get('SVMXC__PM_Plan_Template__c');
        else
            objT_PMPlanTemplates = allObjs.get('PM_Plan_Template__c'); 
            
        if( allObjs.get('SVMXC__Service_Plan__c') != null )
            objT_ServicePlans = allObjs.get('SVMXC__Service_Plan__c');
        else
            objT_ServicePlans = allObjs.get('Service_Plan__c');
            
        if( allObjs.get('SVMXC__Service_Pricebook__c') != null )
            objT_ServicePricebooks = allObjs.get('SVMXC__Service_Pricebook__c');
        else
            objT_ServicePricebooks = allObjs.get('Service_Pricebook__c');
        
        if( allObjs.get('SVMXC__Service_Template__c') != null )
            objT_WarrantyTerms = allObjs.get('SVMXC__Service_Template__c');
        else
            objT_WarrantyTerms = allObjs.get('Service_Template__c');
        
        if(objT_ActivityMaster != null)
            ActivityMasterHomeURL = '/' + objT_ActivityMaster.getDescribe().getkeyPrefix() + '/l';
            
        if(objT_PMPlanTemplates != null)
            PMPlanTemplatesHomeURL = '/' + objT_PMPlanTemplates.getDescribe().getkeyPrefix() + '/l';
            
        if(objT_ServicePlans != null)
            ServicePlansHomeURL = '/' + objT_ServicePlans.getDescribe().getkeyPrefix() + '/l';
            
        if(objT_ServicePricebooks != null)
            ServicePricebooksHomeURL = '/' + objT_ServicePricebooks.getDescribe().getkeyPrefix() + '/l';
            
        if(objT_WarrantyTerms != null)
            WarrantyTermsHomeURL = '/' + objT_WarrantyTerms.getDescribe().getkeyPrefix() + '/l';
        
        // added on 11/sep/2012
        
        if(objT_AvailableServicesHome != null)
            AvailableServicesHomeURL = '/' + objT_AvailableServicesHome.getDescribe().getkeyPrefix() + '/l';
        
        if(objT_SkillsHome != null)
            SkillsHomeURL = '/' + String.valueOf(objT_SkillsHome.getDescribe().getkeyPrefix());
        
        system.debug('Skill home URL: '+ SkillsHomeURL);
        
        if(objT_TaskTemplatesHome != null)
            TaskTemplatesHomeURL = '/' + String.valueOf(objT_TaskTemplatesHome.getDescribe().getkeyPrefix()) + '/l';
        if(objT_BookingWindowsHome != null)
            BookingWindowsHomeURL = '/' + String.valueOf(objT_BookingWindowsHome.getDescribe().getkeyPrefix()) + '/l';
        
       //checking and setting button enable/disable state
        checkToolSeedStatus();     
    }
    
    //Page Load validation Method....
    public PageReference ValidatePage()
    {   
        try
        {
           //Changes for story BAC-5207
            if(UserInfo.getUiTheme() =='Theme4d' || UserInfo.getUiTheme() =='Theme4u')
            {
              String url = '/lightning/n/SVMXC__ServiceMax_Setup';
              PageReference pr = new PageReference(url);
              pr.setredirect(true);
              return pr;
            }
            if( svmxSettingList == null)
            {
                ApexPages.addMessage(new ApexPages.Message ( ApexPages.Severity.ERROR,'ServiceMax Installation is incomplete.'));
                return null;
            }
        }
        catch(Exception e)
        {
            ApexPages.addMessage(new ApexPages.Message ( ApexPages.Severity.ERROR,'ServiceMax Installation is incomplete.'));      
        }
        return null;
    }
    
    // Story TOOL-2382
    Boolean isButtonEnabled = true;
    Boolean isActionPollerEnabled = false;
    Integer pollerInterval = 60;
    public Boolean getIsButtonEnabled(){
        return isButtonEnabled;
    }
    public Boolean getIsActionPollerEnabled(){
        return isActionPollerEnabled;
    }
    public Integer getPollerInterval(){
        return pollerInterval;
    }
    public PageReference checkToolSeedStatus(){
        SVMXC__ServiceMax_Properties__c objProperties = SVMXC__ServiceMax_Properties__c.getValues('TOOL001');
        System.debug('Before objProperties: '+objProperties);
        if(objProperties != null && objProperties.SVMXC__Key__c.equalsIgnoreCase('Tool_Seed_Status')){
            //Check for maximum time limit of through setting CONF039_SET001 for enabling button again and update the properties value to 'Completed'
            Long propertiesModifiedTime = objProperties.LastModifiedDate.getTime();
            Long currentTime = System.now().getTime();
            Long minutesPast = ((currentTime - propertiesModifiedTime) / 1000) / 60;
            System.debug('minutesPast: '+minutesPast);
            System.debug('intMaxTimeCheckForButtonEnabled: '+intMaxTimeCheckForButtonEnabled);
            if(objProperties.SVMXC__Value__c.equalsIgnoreCase('Inprogress') && minutesPast <= intMaxTimeCheckForButtonEnabled){
                objProperties.SVMXC__Value__c = 'Completed';
                update objProperties;
                isButtonEnabled = true;
                isActionPollerEnabled = false;
                System.debug('After objProperties: '+objProperties);
            }
            else{
                if(objProperties.SVMXC__Value__c.equalsIgnoreCase('Inprogress')){
                    isButtonEnabled = false;
                    isActionPollerEnabled = true;
                }
                else if(objProperties.SVMXC__Value__c.equalsIgnoreCase('Completed')){
                    isButtonEnabled = true;
                    isActionPollerEnabled = false;
                }
            }
        }
        System.debug('isButtonEnabled: '+isButtonEnabled);
        return null;
    }
    public void callPostPackageInstall(){
        TOOL_PostPackageInstall objTOOL_PostPackageInstall = new TOOL_PostPackageInstall();
        objTOOL_PostPackageInstall.manualInstall();
        
        SVMXC__ServiceMax_Properties__c objProperties = SVMXC__ServiceMax_Properties__c.getValues('TOOL001');
        if(objProperties != null){
            objProperties.SVMXC__Value__c = 'Inprogress';
            update objProperties;
        }
        else{
            List<SVMXC__ServiceMax_Properties__c> customSettingList = new List<SVMXC__ServiceMax_Properties__c>();
            SVMXC__ServiceMax_Properties__c customSetting = new SVMXC__ServiceMax_Properties__c();
            customSetting.Name = 'TOOL001';
            customSetting.SVMXC__Key__c = 'Tool_Seed_Status';
            customSetting.SVMXC__Value__c = 'Inprogress';
            customSettingList.add(customSetting);
            
            if( COMM_SecurityUtils.getInstance().verifyFieldAccess( customSettingList, COMM_SecurityUtils.Access.Createable ) ) {
                insert customSettingList;
            } else {
                throw new COMM_SecurityUtils.SecurityAccessException( System.Label.COMM001_TAG142 );
            }
        }
        isActionPollerEnabled = true;
    }
    
    // custom label for error message
    public String getTAG004() {return System.Label.COMM001_TAG106;}//
}