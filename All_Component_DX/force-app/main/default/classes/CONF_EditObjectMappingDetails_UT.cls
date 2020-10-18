@isTest
Private class CONF_EditObjectMappingDetails_UT {
    
    
    private static List<RecordType> rtSVMX_Processes = new List<RecordType>();
    
    private static List<SVMXC__ServiceMax_Processes__c> SVMX_Process = new List<SVMXC__ServiceMax_Processes__c>();
    private static List<SVMXC__ServiceMax_Config_Data__c> SVMX_Config_Data = new List<SVMXC__ServiceMax_Config_Data__c>();
    
     private static SVMXC.CONF_EditObjectMappingDetails automapping;
    
    static testmethod void CONF_EditObjectMappingDetails_Test()
    {
       try
       {    
        String SOQLStatement = 'SELECT Id, Name,SobjectType FROM RecordType ';
        rtSVMX_Processes = Database.query(SOQLStatement);
        RecordType Rtypeconfig = [select Id from RecordType where Name=:'Field Mapping'and SobjectType=:'SVMXC__ServiceMax_Config_Data__c']; 
        system.assertNotEquals(Rtypeconfig,null);
        SVMXC__ServiceMax_Processes__c objMappingOne,objMappingTwo,objMappingThree,objMappingFour;
        
         for(RecordType rt : rtSVMX_Processes) //Loop to take a record type at a time
        {
            if(rt.Name == 'Object Mapping' && rt.SobjectType == 'SVMXC__ServiceMax_Processes__c')
            {
                 objMappingOne = new SVMXC__ServiceMax_Processes__c(
                                            RecordTypeId =rt.Id,
                                            SVMXC__Active__c = true,
                                            SVMXC__Name__c = 'Test Mapping',
                                            SVMXC__ModuleID__c = 'TESTONE1',
                                            SVMXC__IsStandard__c= false,
                                            SVMXC__Select__c = false,
                                            SVMXC__SOURCE_OBJECT_NAME__C = 'SVMXC__Booking_Window__c',
                                            SVMXC__TARGET_OBJECT_NAME__C = 'SVMXC__Booking_Window__c',
                                            SVMXC__TARGET_RECORD_TYPE__C = 'Settings',
                                            SVMXC__MAPID__C = 'CUSTOMMAP001'
                                            );
                insert objMappingOne;
            } 
        }
         
           
            
        for(RecordType rt : rtSVMX_Processes) //Loop to take a record type at a time
        {
            if(rt.Name == 'Field Mapping' && rt.SobjectType == 'SVMXC__ServiceMax_Config_Data__c')
            {
                        SVMXC__ServiceMax_Config_Data__c fieldMappingone = new SVMXC__ServiceMax_Config_Data__c(
                                            RecordTypeId =rt.Id,
                                            SVMXC__Active__c = true,
                                            SVMXC__MapID__c =objMappingOne.Id ,
                                            SVMXC__Source_Field_Name__c = 'Name',
                                            SVMXC__Target_Field_Name__c = 'Name'
                                            );
                insert fieldMappingone;
                
            } 
        }
		
		/*SVMXC__ServiceMax_Config_Data__c confobj = new SVMXC__ServiceMax_Config_Data__c(
                                            RecordTypeId =Rtypeconfig.Id,
                                            SVMXC__Active__c = true,
                                            SVMXC__MapID__c =objMappingOne.Id ,
                                            SVMXC__Source_Field_Name__c = 'Name',
                                            SVMXC__Target_Field_Name__c = 'Name'
                                            );*/
         List<String> lststr = new List<String>();
         lststr.add('Name');
        test.starttest();
		system.assertEquals(system.currentPageReference().getParameters().get('objMapId'),null);
        PageReference pageRef = new PageReference('Page.SVMXC.CONF_EditObjectMappingDetails');
        ApexPages.currentPage().getParameters().put('objMapId',objMappingOne.Id );
         ApexPages.currentPage().getParameters().put('sMode','sView' );
         automapping =new  SVMXC.CONF_EditObjectMappingDetails();
         system.assertEquals(system.currentPageReference().getParameters().get('objMapId'),objMappingOne.Id);
         system.assertEquals(system.currentPageReference().getParameters().get('sMode'),'sView');
         List<SVMXC.CONF_EditObjectMappingDetails.wrapper> wrapperlst = new List<SVMXC.CONF_EditObjectMappingDetails.wrapper>();
         automapping.getshowPageError();
         automapping.setshowPageError(true);
         automapping.getsourceObj();
         automapping.setsourceObj('SVMXC__ServiceMax_Processes__c');
         automapping.doValidateOMapRec();
         automapping.setwrapFldMap(wrapperlst);
         automapping.SVMX_doQuickSave();
         automapping.getTAG001();  
         automapping.getTAG002();
         automapping.getTAG003();
         automapping.getTAG004();
         automapping.getTAG005();
         automapping.getTAG006();
         automapping.getTAG007();
         automapping.getTAG008();
         automapping.getTAG009();
         automapping.getTAG010();
		 automapping.getTAG011();
         automapping.getTAG012();
         automapping.getTAG013();
         automapping.getTAG014();
         automapping.getTAG015();
         automapping.getTAG016();
         automapping.getTAG017();
         automapping.getTAG018();
         //automapping.getTAG019();
         automapping.getTAG020();
         automapping.getTAG021();
         //automapping.getTAG022();
         automapping.getTAG023();
         automapping.getTAG024();
         automapping.getTAG025();
         automapping.getTAG026();
         automapping.getTAG027();
         automapping.getTAG028();
         automapping.getHLPURL();
         
         //automapping.svmxTagList.clear();
         
         automapping.getTAG001();  
         automapping.getTAG002();
         automapping.getTAG003();
         automapping.getTAG004();
         automapping.getTAG005();
         automapping.getTAG006();
         automapping.getTAG007();
         automapping.getTAG008();
         automapping.getTAG009();
         automapping.getTAG010();
		 automapping.getTAG011();
         automapping.getTAG012();
         automapping.getTAG013();
         automapping.getTAG014();
         automapping.getTAG015();
         automapping.getTAG016();
         automapping.getTAG017();
         automapping.getTAG018();
        // automapping.getTAG019();
         automapping.getTAG020();
         automapping.getTAG021();
        // automapping.getTAG022();
         automapping.getTAG023();
         automapping.getTAG024();
         automapping.getTAG025();
         automapping.getTAG026();
         automapping.getTAG027();
         automapping.getTAG028();
         automapping.getHLPURL();
         
         automapping.setsourceObj('s');
         //automapping.getsourceObjOptions();
         automapping.gettargetObj();
         automapping.settargetObj('s');
         //automapping.gettargetObjOptions();
         //automapping.gettargetRTOptions();
         automapping.getreadOnly();
         automapping.getreadWrite();
         automapping.getdisAllowChangeObj();
         {
            ApexPages.currentPage().getParameters().put('objMapId',objMappingOne.Id );
             ApexPages.currentPage().getParameters().put('sMode','sView' );  
              
             automapping.SVMX_doCancel();
         
         }
            ApexPages.currentPage().getParameters().put('objMapId',objMappingOne.Id );
          ApexPages.currentPage().getParameters().put('sMode','sClone' );  
         automapping =new  SVMXC.CONF_EditObjectMappingDetails();
          
        ApexPages.currentPage().getParameters().put('objMapId',objMappingOne.Id );
        ApexPages.currentPage().getParameters().put('sMode','SNew' ); 
         automapping =new  SVMXC.CONF_EditObjectMappingDetails();
            
          
          automapping.buildRecordType();
          automapping.targetObj = 'SVMXC__ServiceMax_Processes__c';
          automapping.sourceObj = 'SVMXC__ServiceMax_Processes__c';
          automapping.targetRT = 'Settings';
          automapping.buildWrapperFldMapRecs();
         
          List<String> resL = automapping.SVMX_descObjAndGetFieldMap('SVMXC__ServiceMax_Processes__c');
          List<String> resL2 = automapping.SVMX_descObjAndGetFieldMapAllFields('SVMXC__ServiceMax_Processes__c');
         automapping.getoMaprec();
         automapping.getfldMapRecs();
         automapping.getwrapFldMap();
         automapping.SVMX_doSave();
         automapping.SVMX_populateRT();
         //automapping.SVMX_populateFMap();
         automapping.SVMX_doCancel();
         automapping.getFMapRecordTypes();
         automapping.getOMapRecordTypes();
         
         //SVMXC.CONF_EditObjectMappingDetails.wrapper objmapwrap = new SVMXC.CONF_EditObjectMappingDetails.wrapper(confobj,null,resL,null);
         //objmapwrap.getsourceOptions();
		test.stoptest();
       }
       catch(exception ex)
        {
            ApexPages.addMessage(new ApexPages.Message ( ApexPages.Severity.ERROR, ex.getMessage()));
        }   
          
        
      
    }//end of test method
    
    
}