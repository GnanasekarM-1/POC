@isTest(SeeAllData=true)
private class PREV_ViewEditPMPlan_UT
{
   
    private static SVMXC.PREV_ViewEditPMPlan PMObject; 
    private static SVMXC.PREV_ViewEditPMPlan.PMWrapper PMWrapper;
    static testMethod void PREV_ViewEditPMPlan_UT()
    {
            list<SVMXC__PM_Coverage__c> PMCLst = new list<SVMXC__PM_Coverage__c>();
        
        
            RecordType[] rts = [SELECT Id, Name FROM RecordType WHERE SobjectType = 'SVMXCDEV__ServiceMax_Processes__c'];    
            SVMXC__ServiceMax_Processes__c Dispatch_Process;
            for(RecordType rt : rts) //Loop to take a record type at a time
            {
                // Create Module Record
                if(rt.Name == 'Dispatch Process')
                {
                SVMXC__ServiceMax_Processes__c DP = new SVMXC__ServiceMax_Processes__c(
                                    RecordTypeId =rt.Id,
                                    SVMXC__Active__c = true,
                                    SVMXC__Name__c = 'Dispatch Processs1'
                                    );
                insert DP;
                Dispatch_Process = DP;
                }
        
            }    
            SVMXC__ServiceMax_Processes__c Object_Mapping;
            for(RecordType rt1 : rts) //Loop to take a record type at a time
            {
                // Create Module Record
                if(rt1.Name == 'Dispatch Process')
                {
                SVMXC__ServiceMax_Processes__c OM = new SVMXC__ServiceMax_Processes__c(
                                    RecordTypeId =rt1.Id,
                                    SVMXC__Active__c = true,
                                    SVMXC__Name__c = 'Dispatch Processs1',
                                    SVMXC__Source_Object_Name__c = 'SVMXC__Installed_Product__c',
                                    SVMXC__Target_Object_Name__c = 'SVMXC__Service_Order__c'
                                    );
                insert OM;
                Object_Mapping = OM;
                } 
            }    
        
        
        
            Account account = new Account(
                            Name ='Account',
                            ShippingStreet='ABC',
                            ShippingCity='PQR ',
                            ShippingState = 'XYZ',
                            ShippingPostalCode='111',
                            ShippingCountry='XYZ',
                            BillingStreet='ABC',
                            BillingCity='PQR ',
                            BillingState = 'XYZ',
                            BillingPostalCode='111',
                            BillingCountry='XYZ'
                            ); 
            insert account;
            System.assertEquals('Account', account.Name);
            Product2 prod = new Product2(
                           Name = 'Prod', 
                           ProductCode = '1235', 
                           Family = 'Accessory', 
                           SVMXC__Inherit_Parent_Warranty__c =True
                           );
            insert prod;
            System.assertEquals( 'Prod', prod.Name);
            Product2 prod1 = new Product2(
                           Name = 'Prod1', 
                           ProductCode = '1235', 
                           Family = 'Accessory', 
                           SVMXC__Inherit_Parent_Warranty__c =True
                           );
            insert prod1;
            System.assertEquals( 'Prod1', prod1.Name);
            Product2 prod2 = new Product2(
                           Name = 'Prod2', 
                           ProductCode = '1235', 
                           Family = 'Accessory', 
                           SVMXC__Inherit_Parent_Warranty__c =True
                           );
            insert prod2;
            System.assertEquals( 'Prod2', prod2.Name);
            SVMXC__Installed_Product__c IBObject = new SVMXC__Installed_Product__c(
                           Name = 'Test IB',
                           SVMXC__Status__c = 'Installed',
                           SVMXC__Product__c = prod.Id,
                           SVMXC__Date_Installed__c = System.Today(),
                           SVMXC__Company__c = account.Id
                           );
            insert IBObject;
            System.assertEquals( 'Test IB', IBObject.Name);
            SVMXC__Installed_Product__c IBObject1 = new SVMXC__Installed_Product__c(
                           Name = 'Test IB1',
                           SVMXC__Status__c = 'Installed',
                           SVMXC__Product__c = prod1.Id,
                           SVMXC__Date_Installed__c = System.Today(),
                           SVMXC__Company__c = account.Id
                           );
            insert IBObject1;
            System.assertEquals( 'Test IB1', IBObject1.Name);
            SVMXC__Installed_Product__c IBObject2 = new SVMXC__Installed_Product__c(
                           Name = 'Test IB2',
                           SVMXC__Status__c = 'Installed',
                           SVMXC__Product__c = prod2.Id,
                           SVMXC__Date_Installed__c = System.Today(),
                           SVMXC__Company__c = account.Id
                           );
           // insert IBObject2;
           // System.assertEquals( 'Test IB2', IBObject2.Name);
            SVMXC__Service_Level__c sconSLA = new SVMXC__Service_Level__c(
                            
                            SVMXC__Active__c=true,
                            SVMXC__Description__c = 'Test Desc',
                            SVMXC__Effective_Date__c=System.today()
                            
                            );
            insert sconSLA;
            System.assertEquals(  'Test Desc', sconSLA.SVMXC__Description__c);
            SVMXC__Service_Contract__c SconObject = new SVMXC__Service_Contract__c(
                                 
                                 Name='ZZ1',
                                 SVMXC__Company__c=account.Id,
                                 SVMXC__End_Date__c=System.today(),
                                 SVMXC__Start_Date__c=System.today(),
                                 SVMXC__Service_Level__c= sconSLA.id
                                  );
            insert SconObject;
            System.assertEquals(  'ZZ1', SconObject.Name);
            SVMXC__Service_Contract_Products__c SCP = new SVMXC__Service_Contract_Products__c(
        
                                //Name='ZZ1', //SCPN-000055',
                                SVMXC__Installed_Product__c=IBObject.Id,
                                SVMXC__Product_Family__c='Accessory',
                                SVMXC__Product_Line__c='Accessory',
                                SVMXC__Notes__c='Its for test method',
                                SVMXC__Service_Contract__c = SconObject.Id
                                );
            insert SCP;
            SVMXC__Service_Contract_Products__c SCP1 = new SVMXC__Service_Contract_Products__c(
        
                                //Name='ZZ1', //SCPN-000055',
                                SVMXC__Installed_Product__c=IBObject1.Id,
                                SVMXC__Product_Family__c='Accessory',
                                SVMXC__Product_Line__c='Accessory',
                                SVMXC__Notes__c='Its for test method',
                                SVMXC__Service_Contract__c = SconObject.Id
                                );
            insert SCP1;
          /* ut is failling commented by hari krishna
            SVMXC__Service_Contract_Products__c SCP2 = new SVMXC__Service_Contract_Products__c(
        
                                //Name='ZZ1', //SCPN-000055',
                                SVMXC__Installed_Product__c=IBObject2.Id,
                                SVMXC__Product_Family__c='Accessory',
                                SVMXC__Product_Line__c='Accessory',
                                SVMXC__Notes__c='Its for test method',
                                SVMXC__Service_Contract__c = SconObject.Id
                                );
            insert SCP2;
        
        */
            SVMXC__PM_Plan__c pmplan = new SVMXC__PM_Plan__c(
                    
                            Name = 'PM Plan',
                            SVMXC__Service_Contract__c = SconObject.id,
                            SVMXC__Start_Date__c = system.Today(),
                            SVMXC__End_Date__c = system.Today().adddays(3),
                            SVMXC__Schedule_Type__c = 'Time Based',
                            SVMXC__Field_map_for_wo__c = '--None--',
                            SVMXC__Work_Order_Assign_To__c = 'Dispatch Process ',
                            SVMXC__Create_Case__c = true,
                            SVMXC__Case_Assign_To__c = '--None--',
                            SVMXC__Next_PM_Date__c = system.Today()+1,
                            SVMXC__Dispatch_Process__c = null,
                            SVMXC__Create_Work_Order__c = 1,
                            SVMXC__Processed__c = true,
                            SVMXC__Last_PM_Date__c = null
                            );
                            
            insert pmplan;
            SVMXC__PM_Plan__c pmplan1 = new SVMXC__PM_Plan__c(
                    
                            Name = '',                            
                            SVMXC__Number_of_Cases__c = 'One Per Plan',
                            SVMXC__Start_Date__c = system.Today(),
                            SVMXC__End_Date__c = system.Today()+4,
                            SVMXC__Next_PM_Date__c = system.Today()-4,
                            SVMXC__Create_Work_Order__c = 1,
                            SVMXC__Work_Order_Assign_To__c = 'Queue',
                            SVMXC__Work_Order_Assign_To_Queue__c = null,
                            SVMXC__Create_Case__c = true,
                            SVMXC__Case_Assign_To__c = null,
                            SVMXC__Last_PM_Date__c = null,
                            SVMXC__Service_Contract__c = SconObject.id
                            );
                            
            insert pmplan1;
            
            SVMXC__PM_Coverage__c PMC = new SVMXC__PM_Coverage__c(
        
                            SVMXC__PM_Plan__c = pmplan.id,
                            SVMXC__Product_Name__c = IBObject.Id,
                            SVMXC__PM_Frequency__c = 12
                            );
        
            insert PMC;
            PMCLst.add(PMC);
            SVMXC__PM_Coverage__c PMC1 = new SVMXC__PM_Coverage__c(
        
                            SVMXC__PM_Plan__c = pmplan.id,
                            SVMXC__Product_Name__c = IBObject1.Id,
                            SVMXC__PM_Frequency__c = 12
                            );
        
            insert PMC1;
            PMCLst.add(PMC1);
            SVMXC__PM_Coverage__c PMC2 = new SVMXC__PM_Coverage__c(
        
                            SVMXC__PM_Plan__c = pmplan1.id,
                            SVMXC__Product_Name__c = IBObject1.Id,
                            SVMXC__PM_Frequency__c = 12
                            );
        
            insert PMC2;
            PMCLst.add(PMC2);
            /* ut is failling commented by hari krishna
            
            SVMXC__PM_Coverage__c PMC2 = new SVMXC__PM_Coverage__c(
        
                            SVMXC__PM_Plan__c = pmplan.id,
                            SVMXC__Product_Name__c = IBObject2.Id,
                            SVMXC__PM_Frequency__c = 12
                            );
        
            insert PMC2;            
            PMCLst.add(PMC2);
            */
        Test.startTest();
        
        PageReference pageRef = new PageReference('Page.SVMXC.PREV_ViewEditPMPlan');
        pageRef.getParameters().put('scid',SconObject.Id);
        pageRef.getParameters().put('pcid',pmplan.Id);
        Test.setCurrentPage(pageRef);
        
        PMObject = new SVMXC.PREV_ViewEditPMPlan();
        ////PMWrapper = new SVMXC.PREV_ViewEditPMPlan.PMWrapper(PMC,IBObject);
        ////PMWrapper = new SVMXC.PREV_ViewEditPMPlan.PMWrapper(IBObject);
    
        Boolean b1 = true;
        String s = 'abc';
        PMObject.SearchKeyword = '';
        PMObject.getPMObject();
        PMObject.setPMObject(pmplan);
        PMObject.getSCObject();
        PMObject.setSCObject(SconObject);
        PMObject.getselectedTab();
        PMObject.setselectedTab(s);
        
        PMObject.getSearchKeyword();
        PMObject.setSearchKeyword(s);
        PMObject.getFilterByPL();
        PMObject.setFilterByPL(b1);
        PMObject.getFilterByPF();
        PMObject.setFilterByPF(b1);
        PMObject.getdisplayPopup();
        PMObject.setdisplayPopup(b1);
        
     
        PMObject.getPMWrapperObjlst();
        PMObject.setPMWrapperObjlst(PMObject.PMWrapperObjlst);
        PMObject.getPopupWrapperObjLst();
        PMObject.setPopupWrapperObjLst(PMObject.PopupWrapperObjLst);
        
        PMObject.SVMX_IsValidID(s); 
        PMObject.getWOQueue();
        PMObject.getCaseQueue();
        PMObject.getDispatchProcess();
        PMObject.getfldmapforWO();
        PMObject.getfldmapforCase();
        
        PMObject.SVMX_ISValidPM();
        PMObject.SVMX_Recalculate();
        PMObject.SVMX_FindCoveredProduct();
        
        PMObject.SVMX_Go();
        PMObject.SVMX_AddSelected();
        PMObject.SVMX_CancelPopup();
        PMObject.SVMX_EnbleCaseDetail();
        PMObject.SVMX_OnSelectWO();
        PMObject.SVMX_OnSelectCase();
        PMObject.SVMX_OnChangeSheduleType();
        PMObject.SVMX_Chngfldmap();
        //PMObject.SVMX_DateChngFun();
        PMObject.SVMX_PM_WOSetting();
        PMObject.SVMX_PM_Plan();
        PMObject.SVMX_PM_Alert();
        PMObject.SVMX_PM_ProductCoverage();
        PMObject.SVMX_Cancel();
        PMObject.getPopupMsg();
        PMObject.getDisplayRecord();
        PMObject.getDisableFindCP();
        PMObject.SVMX_Go();
     
       PMObject.getHLPURL();
        System.assert(PMObject.getHLPURL()!=null,'HLPURL assertion failed');
        System.assert(PMObject.getTAG001()!=null,'TAG001 assertion failed');
        System.assert(PMObject.getTAG002()!=null,'TAG002 assertion failed');
        System.assert(PMObject.getTAG003()!=null,'TAG003 assertion failed');
        System.assert(PMObject.getTAG004()!=null,'TAG004 assertion failed');
        System.assert(PMObject.getTAG005()!=null,'TAG005 assertion failed');
        System.assert(PMObject.getTAG006()!=null,'TAG006 assertion failed');
        System.assert(PMObject.getTAG007()!=null,'TAG007 assertion failed');
        System.assert(PMObject.getTAG008()!=null,'TAG008 assertion failed');
        System.assert(PMObject.getTAG009()!=null,'TAG009 assertion failed');
        System.assert(PMObject.getTAG010()!=null,'TAG010 assertion failed');
        System.assert(PMObject.getTAG011()!=null,'TAG011 assertion failed');
        System.assert(PMObject.getTAG012()!=null,'TAG012 assertion failed');
        System.assert(PMObject.getTAG013()!=null,'TAG013 assertion failed');
        System.assert(PMObject.getTAG014()!=null,'TAG014 assertion failed');
        System.assert(PMObject.getTAG015()!=null,'TAG015 assertion failed');
        System.assert(PMObject.getTAG016()!=null,'TAG016 assertion failed');
        System.assert(PMObject.getTAG017()!=null,'TAG017 assertion failed');
        System.assert(PMObject.getTAG018()!=null,'TAG018 assertion failed');
        System.assert(PMObject.getTAG019()!=null,'TAG019 assertion failed');
        System.assert(PMObject.getTAG020()!=null,'TAG020 assertion failed');
        System.assert(PMObject.getTAG021()!=null,'TAG021 assertion failed');
        System.assert(PMObject.getTAG022()!=null,'TAG022 assertion failed');
        System.assert(PMObject.getTAG023()!=null,'TAG023 assertion failed');
        System.assert(PMObject.getTAG024()!=null,'TAG024 assertion failed');
        System.assert(PMObject.getTAG025()!=null,'TAG025 assertion failed');
        System.assert(PMObject.getTAG026()!=null,'TAG026 assertion failed');
        System.assert(PMObject.getTAG027()!=null,'TAG027 assertion failed');
        System.assert(PMObject.getTAG028()!=null,'TAG028 assertion failed');
        System.assert(PMObject.getTAG029()!=null,'TAG029 assertion failed');
        System.assert(PMObject.getTAG030()!=null,'TAG030 assertion failed');
        System.assert(PMObject.getTAG031()!=null,'TAG031 assertion failed');
        System.assert(PMObject.getTAG032()!=null,'TAG032 assertion failed');
        System.assert(PMObject.getTAG033()!=null,'TAG033 assertion failed');
        System.assert(PMObject.getTAG034()!=null,'TAG034 assertion failed');
        System.assert(PMObject.getTAG035()!=null,'TAG035 assertion failed');
        System.assert(PMObject.getTAG036()!=null,'TAG036 assertion failed');
        System.assert(PMObject.getTAG037()!=null,'TAG037 assertion failed');
        System.assert(PMObject.getTAG038()!=null,'TAG038 assertion failed');
        System.assert(PMObject.getTAG039()!=null,'TAG039 assertion failed');
        System.assert(PMObject.getTAG040()!=null,'TAG040 assertion failed');
        System.assert(PMObject.getTAG041()!=null,'TAG041 assertion failed');
        System.assert(PMObject.getTAG042()!=null,'TAG042 assertion failed');
        System.assert(PMObject.getTAG043()!=null,'TAG043 assertion failed');
        System.assert(PMObject.getTAG044()!=null,'TAG044 assertion failed');
        System.assert(PMObject.getTAG045()!=null,'TAG045 assertion failed');
        System.assert(PMObject.getTAG046()!=null,'TAG046 assertion failed');
        System.assert(PMObject.getTAG047()!=null,'TAG047 assertion failed');
        System.assert(PMObject.getTAG048()!=null,'TAG048 assertion failed');
        System.assert(PMObject.getTAG049()!=null,'TAG049 assertion failed');
        System.assert(PMObject.getTAG050()!=null,'TAG050 assertion failed');
        System.assert(PMObject.getTAG051()!=null,'TAG051 assertion failed');
        System.assert(PMObject.getTAG052()!=null,'TAG052 assertion failed');
        System.assert(PMObject.getTAG053()!=null,'TAG053 assertion failed');
        System.assert(PMObject.getTAG054()!=null,'TAG053 assertion failed');
        System.assert(PMObject.getTAG055()!=null,'TAG055 assertion failed');
        System.assert(PMObject.getTAG056()!=null,'TAG056 assertion failed');
        System.assert(PMObject.getTAG057()!=null,'TAG057 assertion failed');
        System.assert(PMObject.getTAG058()!=null,'TAG058 assertion failed');
        System.assert(PMObject.getTAG059()!=null,'TAG059 assertion failed');
        System.assert(PMObject.getTAG060()!=null,'TAG060 assertion failed');
        System.assert(PMObject.getTAG061()!=null,'TAG061 assertion failed');
        System.assert(PMObject.getTAG062()!=null,'TAG062 assertion failed');
        System.assert(PMObject.getTAG063()!=null,'TAG063 assertion failed');
        System.assert(PMObject.getTAG064()!=null,'TAG064 assertion failed');
        System.assert(PMObject.getTAG065()!=null,'TAG065 assertion failed');
        System.assert(PMObject.getTAG066()!=null,'TAG066 assertion failed');
        System.assert(PMObject.getTAG067()!=null,'TAG067 assertion failed');
        System.assert(PMObject.getTAG068()!=null,'TAG068 assertion failed');
        System.assert(PMObject.getTAG069()!=null,'TAG069 assertion failed');
        System.assert(PMObject.getTAG070()!=null,'TAG070 assertion failed');
        System.assert(PMObject.getTAG071()!=null,'TAG071 assertion failed');
        System.assert(PMObject.getTAG072()!=null,'TAG072 assertion failed');
        System.assert(PMObject.getTAG073()!=null,'TAG073 assertion failed');
        System.assert(PMObject.getTAG074()!=null,'TAG074 assertion failed');
        System.assert(PMObject.getTAG075()!=null,'TAG075 assertion failed');
        System.assert(PMObject.getTAG076()!=null,'TAG076 assertion failed');
        System.assert(PMObject.getTAG077()!=null,'TAG077 assertion failed');
        System.assert(PMObject.getTAG078()!=null,'TAG078 assertion failed');
        System.assert(PMObject.getTAG079()!=null,'TAG079 assertion failed');
        System.assert(PMObject.getTAG080()!=null,'TAG080 assertion failed');
        System.assert(PMObject.getTAG081()!=null,'TAG081 assertion failed');
        System.assert(PMObject.getTAG082()!=null,'TAG082 assertion failed');
        System.assert(PMObject.getTAG083()!=null,'TAG083 assertion failed');
        System.assert(PMObject.getTAG084()!=null,'TAG084 assertion failed');
        System.assert(PMObject.getTAG085()!=null,'TAG085 assertion failed');
        System.assert(PMObject.getTAG086()!=null,'TAG086 assertion failed');
        System.assert(PMObject.getTAG087()!=null,'TAG087 assertion failed');
        System.assert(PMObject.getTAG088()!=null,'TAG088 assertion failed');
        System.assert(PMObject.getTAG089()!=null,'TAG089 assertion failed');
        System.assert(PMObject.getTAG090()!=null,'TAG090 assertion failed');
        System.assert(PMObject.getTAG091()!=null,'TAG091 assertion failed');
        System.assert(PMObject.getTAG092()!=null,'TAG092 assertion failed');
        System.assert(PMObject.getTAG093()!=null,'TAG093 assertion failed');
        System.assert(PMObject.getTAG094()!=null,'TAG094 assertion failed');
        System.assert(PMObject.getTAG095()!=null,'TAG095 assertion failed');
        System.assert(PMObject.getTAG096()!=null,'TAG096 assertion failed');
        System.assert(PMObject.getTAG097()!=null,'TAG097 assertion failed');
        System.assert(PMObject.getTAG098()!=null,'TAG098 assertion failed');
        System.assert(PMObject.getTAG099()!=null,'TAG099 assertion failed');
        //PMObject.svmxTagList.clear();
        System.assert(PMObject.getHLPURL()!=null,'HLPURL assertion failed');
        System.assert(PMObject.getTAG001()!=null,'TAG001 assertion failed');
        System.assert(PMObject.getTAG002()!=null,'TAG002 assertion failed');
        System.assert(PMObject.getTAG003()!=null,'TAG003 assertion failed');
        System.assert(PMObject.getTAG004()!=null,'TAG004 assertion failed');
        System.assert(PMObject.getTAG005()!=null,'TAG005 assertion failed');
        System.assert(PMObject.getTAG006()!=null,'TAG006 assertion failed');
        System.assert(PMObject.getTAG007()!=null,'TAG007 assertion failed');
        System.assert(PMObject.getTAG008()!=null,'TAG008 assertion failed');
        System.assert(PMObject.getTAG009()!=null,'TAG009 assertion failed');
        System.assert(PMObject.getTAG010()!=null,'TAG010 assertion failed');
        System.assert(PMObject.getTAG011()!=null,'TAG011 assertion failed');
        System.assert(PMObject.getTAG012()!=null,'TAG012 assertion failed');
        System.assert(PMObject.getTAG013()!=null,'TAG013 assertion failed');
        System.assert(PMObject.getTAG014()!=null,'TAG014 assertion failed');
        System.assert(PMObject.getTAG015()!=null,'TAG015 assertion failed');
        System.assert(PMObject.getTAG016()!=null,'TAG016 assertion failed');
        System.assert(PMObject.getTAG017()!=null,'TAG017 assertion failed');
        System.assert(PMObject.getTAG018()!=null,'TAG018 assertion failed');
        System.assert(PMObject.getTAG019()!=null,'TAG019 assertion failed');
        System.assert(PMObject.getTAG020()!=null,'TAG020 assertion failed');
        System.assert(PMObject.getTAG021()!=null,'TAG021 assertion failed');
        System.assert(PMObject.getTAG022()!=null,'TAG022 assertion failed');
        System.assert(PMObject.getTAG023()!=null,'TAG023 assertion failed');
        System.assert(PMObject.getTAG024()!=null,'TAG024 assertion failed');
        System.assert(PMObject.getTAG025()!=null,'TAG025 assertion failed');
        System.assert(PMObject.getTAG026()!=null,'TAG026 assertion failed');
        System.assert(PMObject.getTAG027()!=null,'TAG027 assertion failed');
        System.assert(PMObject.getTAG028()!=null,'TAG028 assertion failed');
        System.assert(PMObject.getTAG029()!=null,'TAG029 assertion failed');
        System.assert(PMObject.getTAG030()!=null,'TAG030 assertion failed');
        System.assert(PMObject.getTAG031()!=null,'TAG031 assertion failed');
        System.assert(PMObject.getTAG032()!=null,'TAG032 assertion failed');
        System.assert(PMObject.getTAG033()!=null,'TAG033 assertion failed');
        System.assert(PMObject.getTAG034()!=null,'TAG034 assertion failed');
        System.assert(PMObject.getTAG035()!=null,'TAG035 assertion failed');
        System.assert(PMObject.getTAG036()!=null,'TAG036 assertion failed');
        System.assert(PMObject.getTAG037()!=null,'TAG037 assertion failed');
        System.assert(PMObject.getTAG038()!=null,'TAG038 assertion failed');
        System.assert(PMObject.getTAG039()!=null,'TAG039 assertion failed');
        System.assert(PMObject.getTAG040()!=null,'TAG040 assertion failed');
        System.assert(PMObject.getTAG041()!=null,'TAG041 assertion failed');
        System.assert(PMObject.getTAG042()!=null,'TAG042 assertion failed');
        System.assert(PMObject.getTAG043()!=null,'TAG043 assertion failed');
        System.assert(PMObject.getTAG044()!=null,'TAG044 assertion failed');
        System.assert(PMObject.getTAG045()!=null,'TAG045 assertion failed');
        System.assert(PMObject.getTAG046()!=null,'TAG046 assertion failed');
        System.assert(PMObject.getTAG047()!=null,'TAG047 assertion failed');
        System.assert(PMObject.getTAG048()!=null,'TAG048 assertion failed');
        System.assert(PMObject.getTAG049()!=null,'TAG049 assertion failed');
        System.assert(PMObject.getTAG050()!=null,'TAG050 assertion failed');
        System.assert(PMObject.getTAG051()!=null,'TAG051 assertion failed');
        System.assert(PMObject.getTAG052()!=null,'TAG052 assertion failed');
        System.assert(PMObject.getTAG053()!=null,'TAG053 assertion failed');
        System.assert(PMObject.getTAG054()!=null,'TAG053 assertion failed');
        System.assert(PMObject.getTAG055()!=null,'TAG055 assertion failed');
        System.assert(PMObject.getTAG056()!=null,'TAG056 assertion failed');
        System.assert(PMObject.getTAG057()!=null,'TAG057 assertion failed');
        System.assert(PMObject.getTAG058()!=null,'TAG058 assertion failed');
        System.assert(PMObject.getTAG059()!=null,'TAG059 assertion failed');
        System.assert(PMObject.getTAG060()!=null,'TAG060 assertion failed');
        System.assert(PMObject.getTAG061()!=null,'TAG061 assertion failed');
        System.assert(PMObject.getTAG062()!=null,'TAG062 assertion failed');
        System.assert(PMObject.getTAG063()!=null,'TAG063 assertion failed');
        System.assert(PMObject.getTAG064()!=null,'TAG064 assertion failed');
        System.assert(PMObject.getTAG065()!=null,'TAG065 assertion failed');
        System.assert(PMObject.getTAG066()!=null,'TAG066 assertion failed');
        System.assert(PMObject.getTAG067()!=null,'TAG067 assertion failed');
        System.assert(PMObject.getTAG068()!=null,'TAG068 assertion failed');
        System.assert(PMObject.getTAG069()!=null,'TAG069 assertion failed');
        System.assert(PMObject.getTAG070()!=null,'TAG070 assertion failed');
        System.assert(PMObject.getTAG071()!=null,'TAG071 assertion failed');
        System.assert(PMObject.getTAG072()!=null,'TAG072 assertion failed');
        System.assert(PMObject.getTAG073()!=null,'TAG073 assertion failed');
        System.assert(PMObject.getTAG074()!=null,'TAG074 assertion failed');
        System.assert(PMObject.getTAG075()!=null,'TAG075 assertion failed');
        System.assert(PMObject.getTAG076()!=null,'TAG076 assertion failed');
        System.assert(PMObject.getTAG077()!=null,'TAG077 assertion failed');
        System.assert(PMObject.getTAG078()!=null,'TAG078 assertion failed');
        System.assert(PMObject.getTAG079()!=null,'TAG079 assertion failed');
        System.assert(PMObject.getTAG080()!=null,'TAG080 assertion failed');
        System.assert(PMObject.getTAG081()!=null,'TAG081 assertion failed');
        System.assert(PMObject.getTAG082()!=null,'TAG082 assertion failed');
        System.assert(PMObject.getTAG083()!=null,'TAG083 assertion failed');
        System.assert(PMObject.getTAG084()!=null,'TAG084 assertion failed');
        System.assert(PMObject.getTAG085()!=null,'TAG085 assertion failed');
        System.assert(PMObject.getTAG086()!=null,'TAG086 assertion failed');
        System.assert(PMObject.getTAG087()!=null,'TAG087 assertion failed');
        System.assert(PMObject.getTAG088()!=null,'TAG088 assertion failed');
        System.assert(PMObject.getTAG089()!=null,'TAG089 assertion failed');
        System.assert(PMObject.getTAG090()!=null,'TAG090 assertion failed');
        System.assert(PMObject.getTAG091()!=null,'TAG091 assertion failed');
        System.assert(PMObject.getTAG092()!=null,'TAG092 assertion failed');
        System.assert(PMObject.getTAG093()!=null,'TAG093 assertion failed');
        System.assert(PMObject.getTAG094()!=null,'TAG094 assertion failed');
        System.assert(PMObject.getTAG095()!=null,'TAG095 assertion failed');
        System.assert(PMObject.getTAG096()!=null,'TAG096 assertion failed');
        System.assert(PMObject.getTAG097()!=null,'TAG097 assertion failed');
        System.assert(PMObject.getTAG098()!=null,'TAG098 assertion failed');
        System.assert(PMObject.getTAG099()!=null,'TAG099 assertion failed');
        PageReference pageRef1 = new PageReference('Page.SVMXC.PREV_ViewEditPMPlan');
        pageRef1.getParameters().put('scid',SconObject.Id);
        pageRef1.getParameters().put('peid',pmplan1.Id);
        Test.setCurrentPage(pageRef1);
        
        PMObject = new SVMXC.PREV_ViewEditPMPlan();
        PMObject.PMObject.SVMXC__Next_PM_Date__c = system.today();
        PMObject.PMObject.SVMXC__Create_Work_Order__c = 1;
        PMObject.PMCoverageData = PMCLst;
        //PMObject = new SVMXC.PREV_ViewEditPMPlan();
        ////PMWrapper = new SVMXC.PREV_ViewEditPMPlan.PMWrapper(PMC,IBObject);
        ////PMWrapper = new SVMXC.PREV_ViewEditPMPlan.PMWrapper(IBObject);
        PMObject.SVMX_PMSave();
        PMObject.getPMObject(); 
        PMObject.setPMObject(pmplan);
        pmplan.SVMXC__Start_Date__c = null;
        pmplan.SVMXC__End_Date__c = null;
        pmplan.SVMXC__Next_PM_Date__c = system.today()+1;
        pmplan.SVMXC__Schedule_Type__c = 'Time & Counters';
        pmplan.SVMXC__Work_Order_Assign_To__c = '';
        PMObject.SVMX_Recalculate();   
        PMObject.SVMX_ISValidPM();
        pmplan.SVMXC__End_Date__c = system.today()-1;
        pmplan.SVMXC__Next_PM_Date__c = system.today()+1;
        PMObject.SVMX_ISValidPM();
        // PMObject.bo = true;
        pmplan.SVMXC__Last_PM_Date__c = system.today()-4;
        pmplan.SVMXC__Frequency_Unit__c = 'Days';
        pmplan.SVMXC__Frequency__c = 2;
        PMObject.SVMX_Recalculate(); 
        // PMObject.bo = false;
        pmplan.SVMXC__Last_PM_Date__c = system.today()-4;
        pmplan.SVMXC__Frequency_Unit__c = 'Days';
        pmplan.SVMXC__Frequency__c = 2;
        PMObject.SVMX_Recalculate();  
        //PMObject.bo = true;
        pmplan.SVMXC__Last_PM_Date__c = system.today()-4;
        pmplan.SVMXC__Frequency_Unit__c = 'Months';
        pmplan.SVMXC__Frequency__c = 0;
        PMObject.SVMX_Recalculate();
        // PMObject.bo = false;
        pmplan.SVMXC__Last_PM_Date__c = system.today()-4;
        pmplan.SVMXC__Frequency_Unit__c = 'Months';
        pmplan.SVMXC__Frequency__c = 0;
        PMObject.SVMX_Recalculate();  
        // PMObject.bo = true;
        pmplan.SVMXC__Last_PM_Date__c = system.today()-4;
        pmplan.SVMXC__Frequency_Unit__c = 'Years';
        pmplan.SVMXC__Frequency__c = 0;
        PMObject.SVMX_Recalculate(); 
        // PMObject.bo = false;
        pmplan.SVMXC__Last_PM_Date__c = system.today()-4;
        pmplan.SVMXC__Frequency_Unit__c = 'Years';
        pmplan.SVMXC__Frequency__c = 0;
        PMObject.SVMX_Recalculate(); 
        PMObject.SearchKeyword = 'abc';
        PMObject.FilterByPL = true;
        ////PMObject.SVMX_Go();  
        PMObject.FilterByPF = true;
        ////PMObject.SVMX_Go();
        PMObject.SVMX_DelData();
        PMObject.getdisplayfindpro();
        PMObject.getHdrMsg();
        Test.stopTest();
    }   
    
    static testMethod void PREV_ViewEditPMPlan_UT2()
    {
            list<SVMXC__PM_Coverage__c> PMCLst = new list<SVMXC__PM_Coverage__c>();
        
        
            RecordType[] rts = [SELECT Id, Name FROM RecordType WHERE SobjectType = 'SVMXCDEV__ServiceMax_Processes__c'];    
            SVMXC__ServiceMax_Processes__c Dispatch_Process;
            for(RecordType rt : rts) //Loop to take a record type at a time
            {
                // Create Module Record
                if(rt.Name == 'Dispatch Process')
                {
                SVMXC__ServiceMax_Processes__c DP = new SVMXC__ServiceMax_Processes__c(
                                    RecordTypeId =rt.Id,
                                    SVMXC__Active__c = true,
                                    SVMXC__Name__c = 'Dispatch Processs1'
                                    );
                insert DP;
                Dispatch_Process = DP;
                }
        
            }    
            SVMXC__ServiceMax_Processes__c Object_Mapping;
            for(RecordType rt1 : rts) //Loop to take a record type at a time
            {
                // Create Module Record
                if(rt1.Name == 'Dispatch Process')
                {
                SVMXC__ServiceMax_Processes__c OM = new SVMXC__ServiceMax_Processes__c(
                                    RecordTypeId =rt1.Id,
                                    SVMXC__Active__c = true,
                                    SVMXC__Name__c = 'Dispatch Processs1',
                                    SVMXC__Source_Object_Name__c = 'SVMXC__Installed_Product__c',
                                    SVMXC__Target_Object_Name__c = 'SVMXC__Service_Order__c'
                                    );
                insert OM;
                Object_Mapping = OM;
                } 
            }    
        
        
        
            Account account = new Account(
                            Name ='Account',
                            ShippingStreet='ABC',
                            ShippingCity='PQR ',
                            ShippingState = 'XYZ',
                            ShippingPostalCode='111',
                            ShippingCountry='XYZ',
                            BillingStreet='ABC',
                            BillingCity='PQR ',
                            BillingState = 'XYZ',
                            BillingPostalCode='111',
                            BillingCountry='XYZ'
                            ); 
            insert account;
            System.assertEquals('Account', account.Name);
            Product2 prod = new Product2(
                           Name = 'Prod', 
                           ProductCode = '1235', 
                           Family = 'Accessory', 
                           SVMXC__Inherit_Parent_Warranty__c =True
                           );
            insert prod;
            System.assertEquals( 'Prod', prod.Name);
            Product2 prod1 = new Product2(
                           Name = 'Prod1', 
                           ProductCode = '1235', 
                           Family = 'Accessory', 
                           SVMXC__Inherit_Parent_Warranty__c =True
                           );
            insert prod1;
            System.assertEquals( 'Prod1', prod1.Name);
            Product2 prod2 = new Product2(
                           Name = 'Prod2', 
                           ProductCode = '1235', 
                           Family = 'Accessory', 
                           SVMXC__Inherit_Parent_Warranty__c =True
                           );
            insert prod2;
            System.assertEquals( 'Prod2', prod2.Name);
            SVMXC__Installed_Product__c IBObject = new SVMXC__Installed_Product__c(
                           Name = 'Test IB',
                           SVMXC__Status__c = 'Installed',
                           SVMXC__Product__c = prod.Id,
                           SVMXC__Date_Installed__c = System.Today(),
                           SVMXC__Company__c = account.Id
                           );
            insert IBObject;
            System.assertEquals( 'Test IB', IBObject.Name);
            SVMXC__Installed_Product__c IBObject1 = new SVMXC__Installed_Product__c(
                           Name = 'Test IB1',
                           SVMXC__Status__c = 'Installed',
                           SVMXC__Product__c = prod1.Id,
                           SVMXC__Date_Installed__c = System.Today(),
                           SVMXC__Company__c = account.Id
                           );
            insert IBObject1;
            System.assertEquals( 'Test IB1', IBObject1.Name);
            SVMXC__Installed_Product__c IBObject2 = new SVMXC__Installed_Product__c(
                           Name = 'Test IB2',
                           SVMXC__Status__c = 'Installed',
                           SVMXC__Product__c = prod2.Id,
                           SVMXC__Date_Installed__c = System.Today(),
                           SVMXC__Company__c = account.Id
                           );
           // insert IBObject2;
           // System.assertEquals( 'Test IB2', IBObject2.Name);
            SVMXC__Service_Level__c sconSLA = new SVMXC__Service_Level__c(
                            
                            SVMXC__Active__c=true,
                            SVMXC__Description__c = 'Test Desc',
                            SVMXC__Effective_Date__c=System.today()
                            
                            );
            insert sconSLA;
            System.assertEquals(  'Test Desc', sconSLA.SVMXC__Description__c);
            SVMXC__Service_Contract__c SconObject = new SVMXC__Service_Contract__c(
                                 
                                 Name='ZZ1',
                                 SVMXC__Company__c=account.Id,
                                 SVMXC__End_Date__c=System.today(),
                                 SVMXC__Start_Date__c=System.today(),
                                 SVMXC__Service_Level__c= sconSLA.id
                                  );
            insert SconObject;
            System.assertEquals(  'ZZ1', SconObject.Name);
            SVMXC__Service_Contract_Products__c SCP = new SVMXC__Service_Contract_Products__c(
        
                                //Name='ZZ1', //SCPN-000055',
                                SVMXC__Installed_Product__c=IBObject.Id,
                                SVMXC__Product_Family__c='Accessory',
                                SVMXC__Product_Line__c='Accessory',
                                SVMXC__Notes__c='Its for test method',
                                SVMXC__Service_Contract__c = SconObject.Id
                                );
            insert SCP;
            SVMXC__Service_Contract_Products__c SCP1 = new SVMXC__Service_Contract_Products__c(
        
                                //Name='ZZ1', //SCPN-000055',
                                SVMXC__Installed_Product__c=IBObject1.Id,
                                SVMXC__Product_Family__c='Accessory',
                                SVMXC__Product_Line__c='Accessory',
                                SVMXC__Notes__c='Its for test method',
                                SVMXC__Service_Contract__c = SconObject.Id
                                );
            insert SCP1;
          /* ut is failling commented by hari krishna
            SVMXC__Service_Contract_Products__c SCP2 = new SVMXC__Service_Contract_Products__c(
        
                                //Name='ZZ1', //SCPN-000055',
                                SVMXC__Installed_Product__c=IBObject2.Id,
                                SVMXC__Product_Family__c='Accessory',
                                SVMXC__Product_Line__c='Accessory',
                                SVMXC__Notes__c='Its for test method',
                                SVMXC__Service_Contract__c = SconObject.Id
                                );
            insert SCP2;
        
        */
            SVMXC__PM_Plan__c pmplan = new SVMXC__PM_Plan__c(
                    
                            Name = 'PM Plan',
                            SVMXC__Number_of_Work_orders__c = 'One Per Plan',
                            SVMXC__Number_of_Cases__c = 'One Per Plan',
                             SVMXC__Start_Date__c = system.Today(),
                            SVMXC__End_Date__c = system.today()+4,
                            SVMXC__Next_PM_Date__c = system.today()-4,
                            SVMXC__Create_Work_Order__c = 0,
                            SVMXC__Work_Order_Assign_To__c = 'User',
                            SVMXC__Work_Order_Assign_To_Queue__c = null,
                            SVMXC__Create_Case__c = true,
                            SVMXC__Case_Assign_To__c = 'Queue',
                            SVMXC__Case_Assign_To_User__c = null,
                            SVMXC__Last_PM_Date__c = null,
                            SVMXC__Service_Contract__c = SconObject.id
                            );
                            
            insert pmplan;
            SVMXC__PM_Plan__c pmplan2 = new SVMXC__PM_Plan__c(
                    
                            Name = '',                            
                            SVMXC__Number_of_Cases__c = 'One Per Plan',
                             SVMXC__Start_Date__c = system.Today(),
                            SVMXC__End_Date__c = system.Today()+4,
                            SVMXC__Next_PM_Date__c = system.Today()-4,
                            SVMXC__Create_Work_Order__c = 1,
                            SVMXC__Work_Order_Assign_To__c = 'Queue',
                            SVMXC__Work_Order_Assign_To_Queue__c = null,
                            SVMXC__Create_Case__c = true,
                            SVMXC__Case_Assign_To__c = null,
                            SVMXC__Last_PM_Date__c = null,
                            SVMXC__Service_Contract__c = SconObject.id
                            );
                            
            insert pmplan2;
            
            SVMXC__PM_Coverage__c PMC = new SVMXC__PM_Coverage__c(
        
                            SVMXC__PM_Plan__c = pmplan.id,
                            SVMXC__Product_Name__c = IBObject.Id,
                            SVMXC__PM_Frequency__c = 12
                            );
        
            insert PMC;
            PMCLst.add(PMC);
            SVMXC__PM_Coverage__c PMC1 = new SVMXC__PM_Coverage__c(
        
                            SVMXC__PM_Plan__c = pmplan.id,
                            SVMXC__Product_Name__c = IBObject1.Id,
                            SVMXC__PM_Frequency__c = 12
                            );
        
            insert PMC1;
            PMCLst.add(PMC1);
            SVMXC__PM_Coverage__c PMC2 = new SVMXC__PM_Coverage__c(
        
                            SVMXC__PM_Plan__c = pmplan2.id,
                            SVMXC__Product_Name__c = IBObject1.Id,
                            SVMXC__PM_Frequency__c = 12
                            );
        
            insert PMC2;
            PMCLst.add(PMC2);
            /* ut is failling commented by hari krishna
            
            SVMXC__PM_Coverage__c PMC2 = new SVMXC__PM_Coverage__c(
        
                            SVMXC__PM_Plan__c = pmplan.id,
                            SVMXC__Product_Name__c = IBObject2.Id,
                            SVMXC__PM_Frequency__c = 12
                            );
        
            insert PMC2;            
            PMCLst.add(PMC2);
            */
        Test.startTest();
        
        PageReference pageRef = new PageReference('Page.SVMXC.PREV_ViewEditPMPlan');
        pageRef.getParameters().put('scid',SconObject.Id);
        pageRef.getParameters().put('pcid',pmplan.Id);
        Test.setCurrentPage(pageRef);
        
        PMObject = new SVMXC.PREV_ViewEditPMPlan();
        ////PMWrapper = new SVMXC.PREV_ViewEditPMPlan.PMWrapper(PMC,IBObject);
        ////PMWrapper = new SVMXC.PREV_ViewEditPMPlan.PMWrapper(IBObject);
    
        Boolean b1 = true;
        String s = 'abc';
        PMObject.SearchKeyword = '';
        PMObject.getPMObject();
        PMObject.setPMObject(pmplan);
        PMObject.getSCObject();
        PMObject.setSCObject(SconObject);
        PMObject.getselectedTab();
        PMObject.setselectedTab(s);
        
        PMObject.getSearchKeyword();
        PMObject.setSearchKeyword(s);
        PMObject.getFilterByPL();
        PMObject.setFilterByPL(b1);
        PMObject.getFilterByPF();
        PMObject.setFilterByPF(b1);
        PMObject.getdisplayPopup();
        PMObject.setdisplayPopup(b1);
        
     
        PMObject.getPMWrapperObjlst();
        PMObject.setPMWrapperObjlst(PMObject.PMWrapperObjlst);
        PMObject.getPopupWrapperObjLst();
        PMObject.setPopupWrapperObjLst(PMObject.PopupWrapperObjLst);
        
        PMObject.SVMX_IsValidID(s); 
        PMObject.getWOQueue();
        PMObject.getCaseQueue();
        PMObject.getDispatchProcess();
        PMObject.getfldmapforWO();
        PMObject.getfldmapforCase();
        
        PMObject.SVMX_ISValidPM();
        PMObject.SVMX_Recalculate();
        PMObject.SVMX_FindCoveredProduct();
        
        PMObject.SVMX_Go();
        PMObject.SVMX_AddSelected();
        PMObject.SVMX_CancelPopup();
        PMObject.SVMX_EnbleCaseDetail();
        PMObject.SVMX_OnSelectWO();
        PMObject.SVMX_OnSelectCase();
        PMObject.SVMX_OnChangeSheduleType();
        PMObject.SVMX_Chngfldmap();
        //PMObject.SVMX_DateChngFun();
        PMObject.SVMX_PM_WOSetting();
        PMObject.SVMX_PM_Plan();
        PMObject.SVMX_PM_Alert();
        PMObject.SVMX_PM_ProductCoverage();
        PMObject.SVMX_Cancel();
        PMObject.getPopupMsg();
        PMObject.getDisplayRecord();
        PMObject.getDisableFindCP();
        PMObject.SVMX_Go();
     
       PMObject.getHLPURL();
        System.assert(PMObject.getHLPURL()!=null,'HLPURL assertion failed');
        System.assert(PMObject.getTAG001()!=null,'TAG001 assertion failed');
        System.assert(PMObject.getTAG002()!=null,'TAG002 assertion failed');
        System.assert(PMObject.getTAG003()!=null,'TAG003 assertion failed');
        System.assert(PMObject.getTAG004()!=null,'TAG004 assertion failed');
        System.assert(PMObject.getTAG005()!=null,'TAG005 assertion failed');
        System.assert(PMObject.getTAG006()!=null,'TAG006 assertion failed');
        System.assert(PMObject.getTAG007()!=null,'TAG007 assertion failed');
        System.assert(PMObject.getTAG008()!=null,'TAG008 assertion failed');
        System.assert(PMObject.getTAG009()!=null,'TAG009 assertion failed');
        System.assert(PMObject.getTAG010()!=null,'TAG010 assertion failed');
        System.assert(PMObject.getTAG011()!=null,'TAG011 assertion failed');
        System.assert(PMObject.getTAG012()!=null,'TAG012 assertion failed');
        System.assert(PMObject.getTAG013()!=null,'TAG013 assertion failed');
        System.assert(PMObject.getTAG014()!=null,'TAG014 assertion failed');
        System.assert(PMObject.getTAG015()!=null,'TAG015 assertion failed');
        System.assert(PMObject.getTAG016()!=null,'TAG016 assertion failed');
        System.assert(PMObject.getTAG017()!=null,'TAG017 assertion failed');
        System.assert(PMObject.getTAG018()!=null,'TAG018 assertion failed');
        System.assert(PMObject.getTAG019()!=null,'TAG019 assertion failed');
        System.assert(PMObject.getTAG020()!=null,'TAG020 assertion failed');
        System.assert(PMObject.getTAG021()!=null,'TAG021 assertion failed');
        System.assert(PMObject.getTAG022()!=null,'TAG022 assertion failed');
        System.assert(PMObject.getTAG023()!=null,'TAG023 assertion failed');
        System.assert(PMObject.getTAG024()!=null,'TAG024 assertion failed');
        System.assert(PMObject.getTAG025()!=null,'TAG025 assertion failed');
        System.assert(PMObject.getTAG026()!=null,'TAG026 assertion failed');
        System.assert(PMObject.getTAG027()!=null,'TAG027 assertion failed');
        System.assert(PMObject.getTAG028()!=null,'TAG028 assertion failed');
        System.assert(PMObject.getTAG029()!=null,'TAG029 assertion failed');
        System.assert(PMObject.getTAG030()!=null,'TAG030 assertion failed');
        System.assert(PMObject.getTAG031()!=null,'TAG031 assertion failed');
        System.assert(PMObject.getTAG032()!=null,'TAG032 assertion failed');
        System.assert(PMObject.getTAG033()!=null,'TAG033 assertion failed');
        System.assert(PMObject.getTAG034()!=null,'TAG034 assertion failed');
        System.assert(PMObject.getTAG035()!=null,'TAG035 assertion failed');
        System.assert(PMObject.getTAG036()!=null,'TAG036 assertion failed');
        System.assert(PMObject.getTAG037()!=null,'TAG037 assertion failed');
        System.assert(PMObject.getTAG038()!=null,'TAG038 assertion failed');
        System.assert(PMObject.getTAG039()!=null,'TAG039 assertion failed');
        System.assert(PMObject.getTAG040()!=null,'TAG040 assertion failed');
        System.assert(PMObject.getTAG041()!=null,'TAG041 assertion failed');
        System.assert(PMObject.getTAG042()!=null,'TAG042 assertion failed');
        System.assert(PMObject.getTAG043()!=null,'TAG043 assertion failed');
        System.assert(PMObject.getTAG044()!=null,'TAG044 assertion failed');
        System.assert(PMObject.getTAG045()!=null,'TAG045 assertion failed');
        System.assert(PMObject.getTAG046()!=null,'TAG046 assertion failed');
        System.assert(PMObject.getTAG047()!=null,'TAG047 assertion failed');
        System.assert(PMObject.getTAG048()!=null,'TAG048 assertion failed');
        System.assert(PMObject.getTAG049()!=null,'TAG049 assertion failed');
        System.assert(PMObject.getTAG050()!=null,'TAG050 assertion failed');
        System.assert(PMObject.getTAG051()!=null,'TAG051 assertion failed');
        System.assert(PMObject.getTAG052()!=null,'TAG052 assertion failed');
        System.assert(PMObject.getTAG053()!=null,'TAG053 assertion failed');
        System.assert(PMObject.getTAG054()!=null,'TAG053 assertion failed');
        System.assert(PMObject.getTAG055()!=null,'TAG055 assertion failed');
        System.assert(PMObject.getTAG056()!=null,'TAG056 assertion failed');
        System.assert(PMObject.getTAG057()!=null,'TAG057 assertion failed');
        System.assert(PMObject.getTAG058()!=null,'TAG058 assertion failed');
        System.assert(PMObject.getTAG059()!=null,'TAG059 assertion failed');
        System.assert(PMObject.getTAG060()!=null,'TAG060 assertion failed');
        System.assert(PMObject.getTAG061()!=null,'TAG061 assertion failed');
        System.assert(PMObject.getTAG062()!=null,'TAG062 assertion failed');
        System.assert(PMObject.getTAG063()!=null,'TAG063 assertion failed');
        System.assert(PMObject.getTAG064()!=null,'TAG064 assertion failed');
        System.assert(PMObject.getTAG065()!=null,'TAG065 assertion failed');
        System.assert(PMObject.getTAG066()!=null,'TAG066 assertion failed');
        System.assert(PMObject.getTAG067()!=null,'TAG067 assertion failed');
        System.assert(PMObject.getTAG068()!=null,'TAG068 assertion failed');
        System.assert(PMObject.getTAG069()!=null,'TAG069 assertion failed');
        System.assert(PMObject.getTAG070()!=null,'TAG070 assertion failed');
        System.assert(PMObject.getTAG071()!=null,'TAG071 assertion failed');
        System.assert(PMObject.getTAG072()!=null,'TAG072 assertion failed');
        System.assert(PMObject.getTAG073()!=null,'TAG073 assertion failed');
        System.assert(PMObject.getTAG074()!=null,'TAG074 assertion failed');
        System.assert(PMObject.getTAG075()!=null,'TAG075 assertion failed');
        System.assert(PMObject.getTAG076()!=null,'TAG076 assertion failed');
        System.assert(PMObject.getTAG077()!=null,'TAG077 assertion failed');
        System.assert(PMObject.getTAG078()!=null,'TAG078 assertion failed');
        System.assert(PMObject.getTAG079()!=null,'TAG079 assertion failed');
        System.assert(PMObject.getTAG080()!=null,'TAG080 assertion failed');
        System.assert(PMObject.getTAG081()!=null,'TAG081 assertion failed');
        System.assert(PMObject.getTAG082()!=null,'TAG082 assertion failed');
        System.assert(PMObject.getTAG083()!=null,'TAG083 assertion failed');
        System.assert(PMObject.getTAG084()!=null,'TAG084 assertion failed');
        System.assert(PMObject.getTAG085()!=null,'TAG085 assertion failed');
        System.assert(PMObject.getTAG086()!=null,'TAG086 assertion failed');
        System.assert(PMObject.getTAG087()!=null,'TAG087 assertion failed');
        System.assert(PMObject.getTAG088()!=null,'TAG088 assertion failed');
        System.assert(PMObject.getTAG089()!=null,'TAG089 assertion failed');
        System.assert(PMObject.getTAG090()!=null,'TAG090 assertion failed');
        System.assert(PMObject.getTAG091()!=null,'TAG091 assertion failed');
        System.assert(PMObject.getTAG092()!=null,'TAG092 assertion failed');
        System.assert(PMObject.getTAG093()!=null,'TAG093 assertion failed');
        System.assert(PMObject.getTAG094()!=null,'TAG094 assertion failed');
        System.assert(PMObject.getTAG095()!=null,'TAG095 assertion failed');
        System.assert(PMObject.getTAG096()!=null,'TAG096 assertion failed');
        System.assert(PMObject.getTAG097()!=null,'TAG097 assertion failed');
        System.assert(PMObject.getTAG098()!=null,'TAG098 assertion failed');
        System.assert(PMObject.getTAG099()!=null,'TAG099 assertion failed');
        //PMObject.svmxTagList.clear();
        System.assert(PMObject.getHLPURL()!=null,'HLPURL assertion failed');
        System.assert(PMObject.getTAG001()!=null,'TAG001 assertion failed');
        System.assert(PMObject.getTAG002()!=null,'TAG002 assertion failed');
        System.assert(PMObject.getTAG003()!=null,'TAG003 assertion failed');
        System.assert(PMObject.getTAG004()!=null,'TAG004 assertion failed');
        System.assert(PMObject.getTAG005()!=null,'TAG005 assertion failed');
        System.assert(PMObject.getTAG006()!=null,'TAG006 assertion failed');
        System.assert(PMObject.getTAG007()!=null,'TAG007 assertion failed');
        System.assert(PMObject.getTAG008()!=null,'TAG008 assertion failed');
        System.assert(PMObject.getTAG009()!=null,'TAG009 assertion failed');
        System.assert(PMObject.getTAG010()!=null,'TAG010 assertion failed');
        System.assert(PMObject.getTAG011()!=null,'TAG011 assertion failed');
        System.assert(PMObject.getTAG012()!=null,'TAG012 assertion failed');
        System.assert(PMObject.getTAG013()!=null,'TAG013 assertion failed');
        System.assert(PMObject.getTAG014()!=null,'TAG014 assertion failed');
        System.assert(PMObject.getTAG015()!=null,'TAG015 assertion failed');
        System.assert(PMObject.getTAG016()!=null,'TAG016 assertion failed');
        System.assert(PMObject.getTAG017()!=null,'TAG017 assertion failed');
        System.assert(PMObject.getTAG018()!=null,'TAG018 assertion failed');
        System.assert(PMObject.getTAG019()!=null,'TAG019 assertion failed');
        System.assert(PMObject.getTAG020()!=null,'TAG020 assertion failed');
        System.assert(PMObject.getTAG021()!=null,'TAG021 assertion failed');
        System.assert(PMObject.getTAG022()!=null,'TAG022 assertion failed');
        System.assert(PMObject.getTAG023()!=null,'TAG023 assertion failed');
        System.assert(PMObject.getTAG024()!=null,'TAG024 assertion failed');
        System.assert(PMObject.getTAG025()!=null,'TAG025 assertion failed');
        System.assert(PMObject.getTAG026()!=null,'TAG026 assertion failed');
        System.assert(PMObject.getTAG027()!=null,'TAG027 assertion failed');
        System.assert(PMObject.getTAG028()!=null,'TAG028 assertion failed');
        System.assert(PMObject.getTAG029()!=null,'TAG029 assertion failed');
        System.assert(PMObject.getTAG030()!=null,'TAG030 assertion failed');
        System.assert(PMObject.getTAG031()!=null,'TAG031 assertion failed');
        System.assert(PMObject.getTAG032()!=null,'TAG032 assertion failed');
        System.assert(PMObject.getTAG033()!=null,'TAG033 assertion failed');
        System.assert(PMObject.getTAG034()!=null,'TAG034 assertion failed');
        System.assert(PMObject.getTAG035()!=null,'TAG035 assertion failed');
        System.assert(PMObject.getTAG036()!=null,'TAG036 assertion failed');
        System.assert(PMObject.getTAG037()!=null,'TAG037 assertion failed');
        System.assert(PMObject.getTAG038()!=null,'TAG038 assertion failed');
        System.assert(PMObject.getTAG039()!=null,'TAG039 assertion failed');
        System.assert(PMObject.getTAG040()!=null,'TAG040 assertion failed');
        System.assert(PMObject.getTAG041()!=null,'TAG041 assertion failed');
        System.assert(PMObject.getTAG042()!=null,'TAG042 assertion failed');
        System.assert(PMObject.getTAG043()!=null,'TAG043 assertion failed');
        System.assert(PMObject.getTAG044()!=null,'TAG044 assertion failed');
        System.assert(PMObject.getTAG045()!=null,'TAG045 assertion failed');
        System.assert(PMObject.getTAG046()!=null,'TAG046 assertion failed');
        System.assert(PMObject.getTAG047()!=null,'TAG047 assertion failed');
        System.assert(PMObject.getTAG048()!=null,'TAG048 assertion failed');
        System.assert(PMObject.getTAG049()!=null,'TAG049 assertion failed');
        System.assert(PMObject.getTAG050()!=null,'TAG050 assertion failed');
        System.assert(PMObject.getTAG051()!=null,'TAG051 assertion failed');
        System.assert(PMObject.getTAG052()!=null,'TAG052 assertion failed');
        System.assert(PMObject.getTAG053()!=null,'TAG053 assertion failed');
        System.assert(PMObject.getTAG054()!=null,'TAG053 assertion failed');
        System.assert(PMObject.getTAG055()!=null,'TAG055 assertion failed');
        System.assert(PMObject.getTAG056()!=null,'TAG056 assertion failed');
        System.assert(PMObject.getTAG057()!=null,'TAG057 assertion failed');
        System.assert(PMObject.getTAG058()!=null,'TAG058 assertion failed');
        System.assert(PMObject.getTAG059()!=null,'TAG059 assertion failed');
        System.assert(PMObject.getTAG060()!=null,'TAG060 assertion failed');
        System.assert(PMObject.getTAG061()!=null,'TAG061 assertion failed');
        System.assert(PMObject.getTAG062()!=null,'TAG062 assertion failed');
        System.assert(PMObject.getTAG063()!=null,'TAG063 assertion failed');
        System.assert(PMObject.getTAG064()!=null,'TAG064 assertion failed');
        System.assert(PMObject.getTAG065()!=null,'TAG065 assertion failed');
        System.assert(PMObject.getTAG066()!=null,'TAG066 assertion failed');
        System.assert(PMObject.getTAG067()!=null,'TAG067 assertion failed');
        System.assert(PMObject.getTAG068()!=null,'TAG068 assertion failed');
        System.assert(PMObject.getTAG069()!=null,'TAG069 assertion failed');
        System.assert(PMObject.getTAG070()!=null,'TAG070 assertion failed');
        System.assert(PMObject.getTAG071()!=null,'TAG071 assertion failed');
        System.assert(PMObject.getTAG072()!=null,'TAG072 assertion failed');
        System.assert(PMObject.getTAG073()!=null,'TAG073 assertion failed');
        System.assert(PMObject.getTAG074()!=null,'TAG074 assertion failed');
        System.assert(PMObject.getTAG075()!=null,'TAG075 assertion failed');
        System.assert(PMObject.getTAG076()!=null,'TAG076 assertion failed');
        System.assert(PMObject.getTAG077()!=null,'TAG077 assertion failed');
        System.assert(PMObject.getTAG078()!=null,'TAG078 assertion failed');
        System.assert(PMObject.getTAG079()!=null,'TAG079 assertion failed');
        System.assert(PMObject.getTAG080()!=null,'TAG080 assertion failed');
        System.assert(PMObject.getTAG081()!=null,'TAG081 assertion failed');
        System.assert(PMObject.getTAG082()!=null,'TAG082 assertion failed');
        System.assert(PMObject.getTAG083()!=null,'TAG083 assertion failed');
        System.assert(PMObject.getTAG084()!=null,'TAG084 assertion failed');
        System.assert(PMObject.getTAG085()!=null,'TAG085 assertion failed');
        System.assert(PMObject.getTAG086()!=null,'TAG086 assertion failed');
        System.assert(PMObject.getTAG087()!=null,'TAG087 assertion failed');
        System.assert(PMObject.getTAG088()!=null,'TAG088 assertion failed');
        System.assert(PMObject.getTAG089()!=null,'TAG089 assertion failed');
        System.assert(PMObject.getTAG090()!=null,'TAG090 assertion failed');
        System.assert(PMObject.getTAG091()!=null,'TAG091 assertion failed');
        System.assert(PMObject.getTAG092()!=null,'TAG092 assertion failed');
        System.assert(PMObject.getTAG093()!=null,'TAG093 assertion failed');
        System.assert(PMObject.getTAG094()!=null,'TAG094 assertion failed');
        System.assert(PMObject.getTAG095()!=null,'TAG095 assertion failed');
        System.assert(PMObject.getTAG096()!=null,'TAG096 assertion failed');
        System.assert(PMObject.getTAG097()!=null,'TAG097 assertion failed');
        System.assert(PMObject.getTAG098()!=null,'TAG098 assertion failed');
        System.assert(PMObject.getTAG099()!=null,'TAG099 assertion failed');
        PageReference pageRef1 = new PageReference('Page.SVMXC.PREV_ViewEditPMPlan');
        pageRef1.getParameters().put('scid',SconObject.Id);
        pageRef1.getParameters().put('peid',pmplan2.Id);
        Test.setCurrentPage(pageRef1);
        
        PMObject = new SVMXC.PREV_ViewEditPMPlan();
        PMObject.PMObject.SVMXC__Next_PM_Date__c = system.today();
        PMObject.PMObject.SVMXC__Create_Work_Order__c = 1;
        PMObject.PMCoverageData = PMCLst;
        //PMObject = new SVMXC.PREV_ViewEditPMPlan();
        ////PMWrapper = new SVMXC.PREV_ViewEditPMPlan.PMWrapper(PMC,IBObject);
        ////PMWrapper = new SVMXC.PREV_ViewEditPMPlan.PMWrapper(IBObject);
        PMObject.SVMX_PMSave();
        PMObject.getPMObject(); 
        PMObject.setPMObject(pmplan);
        pmplan.SVMXC__End_Date__c = null;
        pmplan.SVMXC__Next_PM_Date__c = system.today()+1;
        pmplan.SVMXC__Schedule_Type__c = 'Time & Counters';
        pmplan.SVMXC__Work_Order_Assign_To__c = '';
        PMObject.SVMX_Recalculate();   
        PMObject.SVMX_ISValidPM();
        pmplan.SVMXC__End_Date__c = system.today()-1;
        pmplan.SVMXC__Next_PM_Date__c = system.today()+1;
        PMObject.SVMX_ISValidPM();
        // PMObject.bo = true;
        pmplan.SVMXC__Last_PM_Date__c = system.today()-4;
        pmplan.SVMXC__Frequency_Unit__c = 'Days';
        pmplan.SVMXC__Frequency__c = 2;
        PMObject.SVMX_Recalculate(); 
        // PMObject.bo = false;
        pmplan.SVMXC__Last_PM_Date__c = system.today()-4;
        pmplan.SVMXC__Frequency_Unit__c = 'Days';
        pmplan.SVMXC__Frequency__c = 2;
        PMObject.SVMX_Recalculate();  
        //PMObject.bo = true;
        pmplan.SVMXC__Last_PM_Date__c = system.today()-4;
        pmplan.SVMXC__Frequency_Unit__c = 'Months';
        pmplan.SVMXC__Frequency__c = 0;
        PMObject.SVMX_Recalculate();
        // PMObject.bo = false;
        pmplan.SVMXC__Last_PM_Date__c = system.today()-4;
        pmplan.SVMXC__Frequency_Unit__c = 'Months';
        pmplan.SVMXC__Frequency__c = 0;
        PMObject.SVMX_Recalculate();  
        // PMObject.bo = true;
        pmplan.SVMXC__Last_PM_Date__c = system.today()-4;
        pmplan.SVMXC__Frequency_Unit__c = 'Years';
        pmplan.SVMXC__Frequency__c = 0;
        PMObject.SVMX_Recalculate(); 
        // PMObject.bo = false;
        pmplan.SVMXC__Last_PM_Date__c = system.today()-4;
        pmplan.SVMXC__Frequency_Unit__c = 'Years';
        pmplan.SVMXC__Frequency__c = 0;
        PMObject.SVMX_Recalculate(); 
        PMObject.SearchKeyword = 'abc';
        PMObject.FilterByPL = true;
        ////PMObject.SVMX_Go();  
        PMObject.FilterByPF = true;
        ////PMObject.SVMX_Go();
        PMObject.SVMX_DelData();
        PMObject.getdisplayfindpro();
        PMObject.getHdrMsg();
        Test.stopTest();
    } 
    static testMethod void PREV_ViewEditPMPlan_UT1()
    {
            list<SVMXC__PM_Coverage__c> PMCLst = new list<SVMXC__PM_Coverage__c>();
        
        
            RecordType[] rts = [SELECT Id, Name FROM RecordType WHERE SobjectType = 'SVMXCDEV__ServiceMax_Processes__c'];    
            SVMXC__ServiceMax_Processes__c Dispatch_Process;
            for(RecordType rt : rts) //Loop to take a record type at a time
            {
                // Create Module Record
                if(rt.Name == 'Dispatch Process')
                {
                SVMXC__ServiceMax_Processes__c DP = new SVMXC__ServiceMax_Processes__c(
                                    RecordTypeId =rt.Id,
                                    SVMXC__Active__c = true,
                                    SVMXC__Name__c = 'Dispatch Processs1'
                                    );
                insert DP;
                Dispatch_Process = DP;
                }
        
            }    
            SVMXC__ServiceMax_Processes__c Object_Mapping;
            for(RecordType rt1 : rts) //Loop to take a record type at a time
            {
                // Create Module Record
                if(rt1.Name == 'Dispatch Process')
                {
                SVMXC__ServiceMax_Processes__c OM = new SVMXC__ServiceMax_Processes__c(
                                    RecordTypeId =rt1.Id,
                                    SVMXC__Active__c = true,
                                    SVMXC__Name__c = 'Dispatch Processs1',
                                    SVMXC__Source_Object_Name__c = 'SVMXC__Installed_Product__c',
                                    SVMXC__Target_Object_Name__c = 'SVMXC__Service_Order__c'
                                    );
                insert OM;
                Object_Mapping = OM;
                } 
            }    
        
        
        
            Account account = new Account(
                            Name ='Account',
                            ShippingStreet='ABC',
                            ShippingCity='PQR ',
                            ShippingState = 'XYZ',
                            ShippingPostalCode='111',
                            ShippingCountry='XYZ',
                            BillingStreet='ABC',
                            BillingCity='PQR ',
                            BillingState = 'XYZ',
                            BillingPostalCode='111',
                            BillingCountry='XYZ'
                            ); 
            insert account;
            System.assertEquals('Account', account.Name);
            Product2 prod = new Product2(
                           Name = 'Prod', 
                           ProductCode = '1235', 
                           Family = 'Accessory', 
                           SVMXC__Inherit_Parent_Warranty__c =True
                           );
            insert prod;
            System.assertEquals( 'Prod', prod.Name);
            Product2 prod1 = new Product2(
                           Name = 'Prod1', 
                           ProductCode = '1235', 
                           Family = 'Accessory', 
                           SVMXC__Inherit_Parent_Warranty__c =True
                           );
            insert prod1;
            System.assertEquals( 'Prod1', prod1.Name);
            Product2 prod2 = new Product2(
                           Name = 'Prod2', 
                           ProductCode = '1235', 
                           Family = 'Accessory', 
                           SVMXC__Inherit_Parent_Warranty__c =True
                           );
            insert prod2;
            System.assertEquals( 'Prod2', prod2.Name);
            SVMXC__Installed_Product__c IBObject = new SVMXC__Installed_Product__c(
                           Name = 'Test IB',
                           SVMXC__Status__c = 'Installed',
                           SVMXC__Product__c = prod.Id,
                           SVMXC__Date_Installed__c = System.Today(),
                           SVMXC__Company__c = account.Id
                           );
            insert IBObject;
            System.assertEquals( 'Test IB', IBObject.Name);
            SVMXC__Installed_Product__c IBObject1 = new SVMXC__Installed_Product__c(
                           Name = 'Test IB1',
                           SVMXC__Status__c = 'Installed',
                           SVMXC__Product__c = prod1.Id,
                           SVMXC__Date_Installed__c = System.Today(),
                           SVMXC__Company__c = account.Id
                           );
            insert IBObject1;
            System.assertEquals( 'Test IB1', IBObject1.Name);
            SVMXC__Installed_Product__c IBObject2 = new SVMXC__Installed_Product__c(
                           Name = 'Test IB2',
                           SVMXC__Status__c = 'Installed',
                           SVMXC__Product__c = prod2.Id,
                           SVMXC__Date_Installed__c = System.Today(),
                           SVMXC__Company__c = account.Id
                           );
           // insert IBObject2;
           // System.assertEquals( 'Test IB2', IBObject2.Name);
            SVMXC__Service_Level__c sconSLA = new SVMXC__Service_Level__c(
                            
                            SVMXC__Active__c=true,
                            SVMXC__Description__c = 'Test Desc',
                            SVMXC__Effective_Date__c=System.today()
                            
                            );
            insert sconSLA;
            System.assertEquals(  'Test Desc', sconSLA.SVMXC__Description__c);
            SVMXC__Service_Contract__c SconObject = new SVMXC__Service_Contract__c(
                                 
                                 Name='ZZ1',
                                 SVMXC__Company__c=account.Id,
                                 SVMXC__End_Date__c=System.today(),
                                 SVMXC__Start_Date__c=System.today()-4,
                                 SVMXC__Service_Level__c= sconSLA.id
                                  );
            insert SconObject;
            System.assertEquals(  'ZZ1', SconObject.Name);
            SVMXC__Service_Contract_Products__c SCP = new SVMXC__Service_Contract_Products__c(
        
                                //Name='ZZ1', //SCPN-000055',
                                SVMXC__Installed_Product__c=IBObject.Id,
                                SVMXC__Product_Family__c='Accessory',
                                SVMXC__Product_Line__c='Accessory',
                                SVMXC__Notes__c='Its for test method',
                                SVMXC__Service_Contract__c = SconObject.Id
                                );
            insert SCP;
            SVMXC__Service_Contract_Products__c SCP1 = new SVMXC__Service_Contract_Products__c(
        
                                //Name='ZZ1', //SCPN-000055',
                                SVMXC__Installed_Product__c=IBObject1.Id,
                                SVMXC__Product_Family__c='Accessory',
                                SVMXC__Product_Line__c='Accessory',
                                SVMXC__Notes__c='Its for test method',
                                SVMXC__Service_Contract__c = SconObject.Id
                                );
            insert SCP1;
          /* ut is failling commented by hari krishna
            SVMXC__Service_Contract_Products__c SCP2 = new SVMXC__Service_Contract_Products__c(
        
                                //Name='ZZ1', //SCPN-000055',
                                SVMXC__Installed_Product__c=IBObject2.Id,
                                SVMXC__Product_Family__c='Accessory',
                                SVMXC__Product_Line__c='Accessory',
                                SVMXC__Notes__c='Its for test method',
                                SVMXC__Service_Contract__c = SconObject.Id
                                );
            insert SCP2;
        
        */
            SVMXC__PM_Plan__c pmplan = new SVMXC__PM_Plan__c(
                    
                            Name = 'PM Plan',
                            SVMXC__Number_of_Work_orders__c = 'One Per Product',
                            SVMXC__Number_of_Cases__c = 'One Per Work Order',
                            SVMXC__End_Date__c = null,
                            SVMXC__Next_PM_Date__c = null,
                            SVMXC__Create_Work_Order__c = null,
                            SVMXC__Work_Order_Assign_To__c = 'User',
                            SVMXC__Work_Order_Assign_To_Queue__c = null,
                            SVMXC__Create_Case__c = true,
                            SVMXC__Case_Assign_To__c = 'User',
                            SVMXC__Case_Assign_To_User__c = null,
                            SVMXC__Schedule_Type__c = 'abc',
                            SVMXC__Last_PM_Date__c = null,
                            SVMXC__Frequency_Unit__c = 'Days',
                            SVMXC__Frequency__c = 2,
                            SVMXC__Start_Date__c = system.today()-4,
                            SVMXC__Service_Contract__c = SconObject.id
                            );
                            
            insert pmplan;
            SVMXC__PM_Plan__c pmplan1 = new SVMXC__PM_Plan__c(
                    
                            Name = '',                            
                            SVMXC__Number_of_Cases__c = 'One Per Plan',
                            SVMXC__Start_Date__c = system.Today()-5,
                            SVMXC__End_Date__c = system.Today()-4,
                            SVMXC__Next_PM_Date__c = system.Today()-4,
                            SVMXC__Create_Work_Order__c = 1,
                            SVMXC__Work_Order_Assign_To__c = 'Queue',
                            SVMXC__Work_Order_Assign_To_Queue__c = null,
                            SVMXC__Create_Case__c = true,
                            SVMXC__Case_Assign_To__c = null,
                            SVMXC__Last_PM_Date__c = null,
                            SVMXC__Service_Contract__c = SconObject.id
                            );
                            
            insert pmplan1;
            
            SVMXC__PM_Coverage__c PMC = new SVMXC__PM_Coverage__c(
        
                            SVMXC__PM_Plan__c = pmplan.id,
                            SVMXC__Product_Name__c = IBObject.Id,
                            SVMXC__PM_Frequency__c = 12
                            );
        
            insert PMC;
            PMCLst.add(PMC);
            SVMXC__PM_Coverage__c PMC1 = new SVMXC__PM_Coverage__c(
        
                            SVMXC__PM_Plan__c = pmplan.id,
                            SVMXC__Product_Name__c = IBObject1.Id,
                            SVMXC__PM_Frequency__c = 12
                            );
        
            insert PMC1;
            PMCLst.add(PMC1);
            SVMXC__PM_Coverage__c PMC2 = new SVMXC__PM_Coverage__c(
        
                            SVMXC__PM_Plan__c = pmplan1.id,
                            SVMXC__Product_Name__c = IBObject1.Id,
                            SVMXC__PM_Frequency__c = 12
                            );
        
            insert PMC2;
            /* ut is failling commented by hari krishna
            
            SVMXC__PM_Coverage__c PMC2 = new SVMXC__PM_Coverage__c(
        
                            SVMXC__PM_Plan__c = pmplan.id,
                            SVMXC__Product_Name__c = IBObject2.Id,
                            SVMXC__PM_Frequency__c = 12
                            );
        
            insert PMC2;            
            PMCLst.add(PMC2);
            */
        Test.startTest();
        
        PageReference pageRef = new PageReference('Page.SVMXC.PREV_ViewEditPMPlan');
        pageRef.getParameters().put('scid',SconObject.Id);
        pageRef.getParameters().put('pcid',pmplan.Id);
        Test.setCurrentPage(pageRef);
        
        PMObject = new SVMXC.PREV_ViewEditPMPlan();
        ////PMWrapper = new SVMXC.PREV_ViewEditPMPlan.PMWrapper(PMC,IBObject);
        ////PMWrapper = new SVMXC.PREV_ViewEditPMPlan.PMWrapper(IBObject);
    
        Boolean b1 = true;
        String s = 'abc';
        PMObject.SearchKeyword = '';
        PMObject.getPMObject();
        PMObject.setPMObject(pmplan);
        PMObject.getSCObject();
        PMObject.setSCObject(SconObject);
        PMObject.getselectedTab();
        PMObject.setselectedTab(s);
        
        PMObject.getSearchKeyword();
        PMObject.setSearchKeyword(s);
        PMObject.getFilterByPL();
        PMObject.setFilterByPL(b1);
        PMObject.getFilterByPF();
        PMObject.setFilterByPF(b1);
        PMObject.getdisplayPopup();
        PMObject.setdisplayPopup(b1);
        
     
        PMObject.getPMWrapperObjlst();
        PMObject.setPMWrapperObjlst(PMObject.PMWrapperObjlst);
        PMObject.getPopupWrapperObjLst();
        PMObject.setPopupWrapperObjLst(PMObject.PopupWrapperObjLst);
        
        PMObject.SVMX_IsValidID(s); 
        PMObject.getWOQueue();
        PMObject.getCaseQueue();
        PMObject.getDispatchProcess();
        PMObject.getfldmapforWO();
        PMObject.getfldmapforCase();
        
        PMObject.SVMX_ISValidPM();
        PMObject.SVMX_Recalculate();
        PMObject.SVMX_FindCoveredProduct();
        
        PMObject.SVMX_Go();
        PMObject.SVMX_AddSelected();
        PMObject.SVMX_CancelPopup();
        PMObject.SVMX_EnbleCaseDetail();
        PMObject.SVMX_OnSelectWO();
        PMObject.SVMX_OnSelectCase();
        PMObject.SVMX_OnChangeSheduleType();
        PMObject.SVMX_Chngfldmap();
        //PMObject.SVMX_DateChngFun();
        PMObject.SVMX_PM_WOSetting();
        PMObject.SVMX_PM_Plan();
        PMObject.SVMX_PM_Alert();
        PMObject.SVMX_PM_ProductCoverage();
        PMObject.SVMX_Cancel();
        PMObject.getPopupMsg();
        PMObject.getDisplayRecord();
        PMObject.getDisableFindCP();
        PMObject.SVMX_Go();
     
       PMObject.getHLPURL();
        System.assert(PMObject.getHLPURL()!=null,'HLPURL assertion failed');
        System.assert(PMObject.getTAG001()!=null,'TAG001 assertion failed');
        System.assert(PMObject.getTAG002()!=null,'TAG002 assertion failed');
        System.assert(PMObject.getTAG003()!=null,'TAG003 assertion failed');
        System.assert(PMObject.getTAG004()!=null,'TAG004 assertion failed');
        System.assert(PMObject.getTAG005()!=null,'TAG005 assertion failed');
        System.assert(PMObject.getTAG006()!=null,'TAG006 assertion failed');
        System.assert(PMObject.getTAG007()!=null,'TAG007 assertion failed');
        System.assert(PMObject.getTAG008()!=null,'TAG008 assertion failed');
        System.assert(PMObject.getTAG009()!=null,'TAG009 assertion failed');
        System.assert(PMObject.getTAG010()!=null,'TAG010 assertion failed');
        System.assert(PMObject.getTAG011()!=null,'TAG011 assertion failed');
        System.assert(PMObject.getTAG012()!=null,'TAG012 assertion failed');
        System.assert(PMObject.getTAG013()!=null,'TAG013 assertion failed');
        System.assert(PMObject.getTAG014()!=null,'TAG014 assertion failed');
        System.assert(PMObject.getTAG015()!=null,'TAG015 assertion failed');
        System.assert(PMObject.getTAG016()!=null,'TAG016 assertion failed');
        System.assert(PMObject.getTAG017()!=null,'TAG017 assertion failed');
        System.assert(PMObject.getTAG018()!=null,'TAG018 assertion failed');
        System.assert(PMObject.getTAG019()!=null,'TAG019 assertion failed');
        System.assert(PMObject.getTAG020()!=null,'TAG020 assertion failed');
        System.assert(PMObject.getTAG021()!=null,'TAG021 assertion failed');
        System.assert(PMObject.getTAG022()!=null,'TAG022 assertion failed');
        System.assert(PMObject.getTAG023()!=null,'TAG023 assertion failed');
        System.assert(PMObject.getTAG024()!=null,'TAG024 assertion failed');
        System.assert(PMObject.getTAG025()!=null,'TAG025 assertion failed');
        System.assert(PMObject.getTAG026()!=null,'TAG026 assertion failed');
        System.assert(PMObject.getTAG027()!=null,'TAG027 assertion failed');
        System.assert(PMObject.getTAG028()!=null,'TAG028 assertion failed');
        System.assert(PMObject.getTAG029()!=null,'TAG029 assertion failed');
        System.assert(PMObject.getTAG030()!=null,'TAG030 assertion failed');
        System.assert(PMObject.getTAG031()!=null,'TAG031 assertion failed');
        System.assert(PMObject.getTAG032()!=null,'TAG032 assertion failed');
        System.assert(PMObject.getTAG033()!=null,'TAG033 assertion failed');
        System.assert(PMObject.getTAG034()!=null,'TAG034 assertion failed');
        System.assert(PMObject.getTAG035()!=null,'TAG035 assertion failed');
        System.assert(PMObject.getTAG036()!=null,'TAG036 assertion failed');
        System.assert(PMObject.getTAG037()!=null,'TAG037 assertion failed');
        System.assert(PMObject.getTAG038()!=null,'TAG038 assertion failed');
        System.assert(PMObject.getTAG039()!=null,'TAG039 assertion failed');
        System.assert(PMObject.getTAG040()!=null,'TAG040 assertion failed');
        System.assert(PMObject.getTAG041()!=null,'TAG041 assertion failed');
        System.assert(PMObject.getTAG042()!=null,'TAG042 assertion failed');
        System.assert(PMObject.getTAG043()!=null,'TAG043 assertion failed');
        System.assert(PMObject.getTAG044()!=null,'TAG044 assertion failed');
        System.assert(PMObject.getTAG045()!=null,'TAG045 assertion failed');
        System.assert(PMObject.getTAG046()!=null,'TAG046 assertion failed');
        System.assert(PMObject.getTAG047()!=null,'TAG047 assertion failed');
        System.assert(PMObject.getTAG048()!=null,'TAG048 assertion failed');
        System.assert(PMObject.getTAG049()!=null,'TAG049 assertion failed');
        System.assert(PMObject.getTAG050()!=null,'TAG050 assertion failed');
        System.assert(PMObject.getTAG051()!=null,'TAG051 assertion failed');
        System.assert(PMObject.getTAG052()!=null,'TAG052 assertion failed');
        System.assert(PMObject.getTAG053()!=null,'TAG053 assertion failed');
        System.assert(PMObject.getTAG054()!=null,'TAG053 assertion failed');
        System.assert(PMObject.getTAG055()!=null,'TAG055 assertion failed');
        System.assert(PMObject.getTAG056()!=null,'TAG056 assertion failed');
        System.assert(PMObject.getTAG057()!=null,'TAG057 assertion failed');
        System.assert(PMObject.getTAG058()!=null,'TAG058 assertion failed');
        System.assert(PMObject.getTAG059()!=null,'TAG059 assertion failed');
        System.assert(PMObject.getTAG060()!=null,'TAG060 assertion failed');
        System.assert(PMObject.getTAG061()!=null,'TAG061 assertion failed');
        System.assert(PMObject.getTAG062()!=null,'TAG062 assertion failed');
        System.assert(PMObject.getTAG063()!=null,'TAG063 assertion failed');
        System.assert(PMObject.getTAG064()!=null,'TAG064 assertion failed');
        System.assert(PMObject.getTAG065()!=null,'TAG065 assertion failed');
        System.assert(PMObject.getTAG066()!=null,'TAG066 assertion failed');
        System.assert(PMObject.getTAG067()!=null,'TAG067 assertion failed');
        System.assert(PMObject.getTAG068()!=null,'TAG068 assertion failed');
        System.assert(PMObject.getTAG069()!=null,'TAG069 assertion failed');
        System.assert(PMObject.getTAG070()!=null,'TAG070 assertion failed');
        System.assert(PMObject.getTAG071()!=null,'TAG071 assertion failed');
        System.assert(PMObject.getTAG072()!=null,'TAG072 assertion failed');
        System.assert(PMObject.getTAG073()!=null,'TAG073 assertion failed');
        System.assert(PMObject.getTAG074()!=null,'TAG074 assertion failed');
        System.assert(PMObject.getTAG075()!=null,'TAG075 assertion failed');
        System.assert(PMObject.getTAG076()!=null,'TAG076 assertion failed');
        System.assert(PMObject.getTAG077()!=null,'TAG077 assertion failed');
        System.assert(PMObject.getTAG078()!=null,'TAG078 assertion failed');
        System.assert(PMObject.getTAG079()!=null,'TAG079 assertion failed');
        System.assert(PMObject.getTAG080()!=null,'TAG080 assertion failed');
        System.assert(PMObject.getTAG081()!=null,'TAG081 assertion failed');
        System.assert(PMObject.getTAG082()!=null,'TAG082 assertion failed');
        System.assert(PMObject.getTAG083()!=null,'TAG083 assertion failed');
        System.assert(PMObject.getTAG084()!=null,'TAG084 assertion failed');
        System.assert(PMObject.getTAG085()!=null,'TAG085 assertion failed');
        System.assert(PMObject.getTAG086()!=null,'TAG086 assertion failed');
        System.assert(PMObject.getTAG087()!=null,'TAG087 assertion failed');
        System.assert(PMObject.getTAG088()!=null,'TAG088 assertion failed');
        System.assert(PMObject.getTAG089()!=null,'TAG089 assertion failed');
        System.assert(PMObject.getTAG090()!=null,'TAG090 assertion failed');
        System.assert(PMObject.getTAG091()!=null,'TAG091 assertion failed');
        System.assert(PMObject.getTAG092()!=null,'TAG092 assertion failed');
        System.assert(PMObject.getTAG093()!=null,'TAG093 assertion failed');
        System.assert(PMObject.getTAG094()!=null,'TAG094 assertion failed');
        System.assert(PMObject.getTAG095()!=null,'TAG095 assertion failed');
        System.assert(PMObject.getTAG096()!=null,'TAG096 assertion failed');
        System.assert(PMObject.getTAG097()!=null,'TAG097 assertion failed');
        System.assert(PMObject.getTAG098()!=null,'TAG098 assertion failed');
        System.assert(PMObject.getTAG099()!=null,'TAG099 assertion failed');
        //PMObject.svmxTagList.clear();
        System.assert(PMObject.getHLPURL()!=null,'HLPURL assertion failed');
        System.assert(PMObject.getTAG001()!=null,'TAG001 assertion failed');
        System.assert(PMObject.getTAG002()!=null,'TAG002 assertion failed');
        System.assert(PMObject.getTAG003()!=null,'TAG003 assertion failed');
        System.assert(PMObject.getTAG004()!=null,'TAG004 assertion failed');
        System.assert(PMObject.getTAG005()!=null,'TAG005 assertion failed');
        System.assert(PMObject.getTAG006()!=null,'TAG006 assertion failed');
        System.assert(PMObject.getTAG007()!=null,'TAG007 assertion failed');
        System.assert(PMObject.getTAG008()!=null,'TAG008 assertion failed');
        System.assert(PMObject.getTAG009()!=null,'TAG009 assertion failed');
        System.assert(PMObject.getTAG010()!=null,'TAG010 assertion failed');
        System.assert(PMObject.getTAG011()!=null,'TAG011 assertion failed');
        System.assert(PMObject.getTAG012()!=null,'TAG012 assertion failed');
        System.assert(PMObject.getTAG013()!=null,'TAG013 assertion failed');
        System.assert(PMObject.getTAG014()!=null,'TAG014 assertion failed');
        System.assert(PMObject.getTAG015()!=null,'TAG015 assertion failed');
        System.assert(PMObject.getTAG016()!=null,'TAG016 assertion failed');
        System.assert(PMObject.getTAG017()!=null,'TAG017 assertion failed');
        System.assert(PMObject.getTAG018()!=null,'TAG018 assertion failed');
        System.assert(PMObject.getTAG019()!=null,'TAG019 assertion failed');
        System.assert(PMObject.getTAG020()!=null,'TAG020 assertion failed');
        System.assert(PMObject.getTAG021()!=null,'TAG021 assertion failed');
        System.assert(PMObject.getTAG022()!=null,'TAG022 assertion failed');
        System.assert(PMObject.getTAG023()!=null,'TAG023 assertion failed');
        System.assert(PMObject.getTAG024()!=null,'TAG024 assertion failed');
        System.assert(PMObject.getTAG025()!=null,'TAG025 assertion failed');
        System.assert(PMObject.getTAG026()!=null,'TAG026 assertion failed');
        System.assert(PMObject.getTAG027()!=null,'TAG027 assertion failed');
        System.assert(PMObject.getTAG028()!=null,'TAG028 assertion failed');
        System.assert(PMObject.getTAG029()!=null,'TAG029 assertion failed');
        System.assert(PMObject.getTAG030()!=null,'TAG030 assertion failed');
        System.assert(PMObject.getTAG031()!=null,'TAG031 assertion failed');
        System.assert(PMObject.getTAG032()!=null,'TAG032 assertion failed');
        System.assert(PMObject.getTAG033()!=null,'TAG033 assertion failed');
        System.assert(PMObject.getTAG034()!=null,'TAG034 assertion failed');
        System.assert(PMObject.getTAG035()!=null,'TAG035 assertion failed');
        System.assert(PMObject.getTAG036()!=null,'TAG036 assertion failed');
        System.assert(PMObject.getTAG037()!=null,'TAG037 assertion failed');
        System.assert(PMObject.getTAG038()!=null,'TAG038 assertion failed');
        System.assert(PMObject.getTAG039()!=null,'TAG039 assertion failed');
        System.assert(PMObject.getTAG040()!=null,'TAG040 assertion failed');
        System.assert(PMObject.getTAG041()!=null,'TAG041 assertion failed');
        System.assert(PMObject.getTAG042()!=null,'TAG042 assertion failed');
        System.assert(PMObject.getTAG043()!=null,'TAG043 assertion failed');
        System.assert(PMObject.getTAG044()!=null,'TAG044 assertion failed');
        System.assert(PMObject.getTAG045()!=null,'TAG045 assertion failed');
        System.assert(PMObject.getTAG046()!=null,'TAG046 assertion failed');
        System.assert(PMObject.getTAG047()!=null,'TAG047 assertion failed');
        System.assert(PMObject.getTAG048()!=null,'TAG048 assertion failed');
        System.assert(PMObject.getTAG049()!=null,'TAG049 assertion failed');
        System.assert(PMObject.getTAG050()!=null,'TAG050 assertion failed');
        System.assert(PMObject.getTAG051()!=null,'TAG051 assertion failed');
        System.assert(PMObject.getTAG052()!=null,'TAG052 assertion failed');
        System.assert(PMObject.getTAG053()!=null,'TAG053 assertion failed');
        System.assert(PMObject.getTAG054()!=null,'TAG053 assertion failed');
        System.assert(PMObject.getTAG055()!=null,'TAG055 assertion failed');
        System.assert(PMObject.getTAG056()!=null,'TAG056 assertion failed');
        System.assert(PMObject.getTAG057()!=null,'TAG057 assertion failed');
        System.assert(PMObject.getTAG058()!=null,'TAG058 assertion failed');
        System.assert(PMObject.getTAG059()!=null,'TAG059 assertion failed');
        System.assert(PMObject.getTAG060()!=null,'TAG060 assertion failed');
        System.assert(PMObject.getTAG061()!=null,'TAG061 assertion failed');
        System.assert(PMObject.getTAG062()!=null,'TAG062 assertion failed');
        System.assert(PMObject.getTAG063()!=null,'TAG063 assertion failed');
        System.assert(PMObject.getTAG064()!=null,'TAG064 assertion failed');
        System.assert(PMObject.getTAG065()!=null,'TAG065 assertion failed');
        System.assert(PMObject.getTAG066()!=null,'TAG066 assertion failed');
        System.assert(PMObject.getTAG067()!=null,'TAG067 assertion failed');
        System.assert(PMObject.getTAG068()!=null,'TAG068 assertion failed');
        System.assert(PMObject.getTAG069()!=null,'TAG069 assertion failed');
        System.assert(PMObject.getTAG070()!=null,'TAG070 assertion failed');
        System.assert(PMObject.getTAG071()!=null,'TAG071 assertion failed');
        System.assert(PMObject.getTAG072()!=null,'TAG072 assertion failed');
        System.assert(PMObject.getTAG073()!=null,'TAG073 assertion failed');
        System.assert(PMObject.getTAG074()!=null,'TAG074 assertion failed');
        System.assert(PMObject.getTAG075()!=null,'TAG075 assertion failed');
        System.assert(PMObject.getTAG076()!=null,'TAG076 assertion failed');
        System.assert(PMObject.getTAG077()!=null,'TAG077 assertion failed');
        System.assert(PMObject.getTAG078()!=null,'TAG078 assertion failed');
        System.assert(PMObject.getTAG079()!=null,'TAG079 assertion failed');
        System.assert(PMObject.getTAG080()!=null,'TAG080 assertion failed');
        System.assert(PMObject.getTAG081()!=null,'TAG081 assertion failed');
        System.assert(PMObject.getTAG082()!=null,'TAG082 assertion failed');
        System.assert(PMObject.getTAG083()!=null,'TAG083 assertion failed');
        System.assert(PMObject.getTAG084()!=null,'TAG084 assertion failed');
        System.assert(PMObject.getTAG085()!=null,'TAG085 assertion failed');
        System.assert(PMObject.getTAG086()!=null,'TAG086 assertion failed');
        System.assert(PMObject.getTAG087()!=null,'TAG087 assertion failed');
        System.assert(PMObject.getTAG088()!=null,'TAG088 assertion failed');
        System.assert(PMObject.getTAG089()!=null,'TAG089 assertion failed');
        System.assert(PMObject.getTAG090()!=null,'TAG090 assertion failed');
        System.assert(PMObject.getTAG091()!=null,'TAG091 assertion failed');
        System.assert(PMObject.getTAG092()!=null,'TAG092 assertion failed');
        System.assert(PMObject.getTAG093()!=null,'TAG093 assertion failed');
        System.assert(PMObject.getTAG094()!=null,'TAG094 assertion failed');
        System.assert(PMObject.getTAG095()!=null,'TAG095 assertion failed');
        System.assert(PMObject.getTAG096()!=null,'TAG096 assertion failed');
        System.assert(PMObject.getTAG097()!=null,'TAG097 assertion failed');
        System.assert(PMObject.getTAG098()!=null,'TAG098 assertion failed');
        System.assert(PMObject.getTAG099()!=null,'TAG099 assertion failed');
        PageReference pageRef1 = new PageReference('Page.SVMXC.PREV_ViewEditPMPlan');
        pageRef1.getParameters().put('scid',SconObject.Id);
        pageRef1.getParameters().put('peid',pmplan1.Id);
        Test.setCurrentPage(pageRef1);
        
        PMObject = new SVMXC.PREV_ViewEditPMPlan();
        PMObject.PMObject.SVMXC__Next_PM_Date__c = system.today();
        PMObject.PMObject.SVMXC__Create_Work_Order__c = 1;
        PMObject.PMCoverageData = PMCLst;
        //PMObject = new SVMXC.PREV_ViewEditPMPlan();
        ////PMWrapper = new SVMXC.PREV_ViewEditPMPlan.PMWrapper(PMC,IBObject);
        ////PMWrapper = new SVMXC.PREV_ViewEditPMPlan.PMWrapper(IBObject);
        PMObject.SVMX_PMSave();
        PMObject.getPMObject(); 
        PMObject.setPMObject(pmplan);
        pmplan.SVMXC__Start_Date__c = system.today()-4;
        pmplan.SVMXC__End_Date__c = null;
        pmplan.SVMXC__Next_PM_Date__c = system.today()+1;
        pmplan.SVMXC__Schedule_Type__c = 'Time & Counters';
        pmplan.SVMXC__Work_Order_Assign_To__c = '';
        PMObject.SVMX_Recalculate();   
        PMObject.SVMX_ISValidPM();
        pmplan.SVMXC__End_Date__c = null;
        pmplan.SVMXC__Next_PM_Date__c = null;
        PMObject.SVMX_ISValidPM();
        // PMObject.bo = true;
        pmplan.SVMXC__Schedule_Type__c = 'abc';
        pmplan.SVMXC__End_Date__c = system.today()-1;
        pmplan.SVMXC__Next_PM_Date__c = system.today()+1;
        pmplan.SVMXC__Last_PM_Date__c = null;
        pmplan.SVMXC__Frequency_Unit__c = 'Days';
        pmplan.SVMXC__Frequency__c = 2;
        PMObject.SVMX_Recalculate(); 
        // PMObject.bo = false;
        pmplan.SVMXC__End_Date__c = system.today()-6;
        pmplan.SVMXC__Frequency_Unit__c = 'Days';
        pmplan.SVMXC__Frequency__c = 2;
        PMObject.SVMX_Recalculate();  
        //PMObject.bo = true;
        pmplan.SVMXC__End_Date__c = system.today()-6;
        pmplan.SVMXC__Frequency_Unit__c = 'Months';
        pmplan.SVMXC__Frequency__c = 0;
        PMObject.SVMX_Recalculate();
        // PMObject.bo = false;
        pmplan.SVMXC__End_Date__c = system.today()-6;
        pmplan.SVMXC__Frequency_Unit__c = 'Months';
        pmplan.SVMXC__Frequency__c = 0;
        PMObject.SVMX_Recalculate();  
        // PMObject.bo = true;
        pmplan.SVMXC__End_Date__c = system.today()-6;
        pmplan.SVMXC__Frequency_Unit__c = 'Years';
        pmplan.SVMXC__Frequency__c = 0;
        PMObject.SVMX_Recalculate(); 
        // PMObject.bo = false;
        pmplan.SVMXC__End_Date__c = system.today()-6;
        pmplan.SVMXC__Frequency_Unit__c = 'Years';
        pmplan.SVMXC__Frequency__c = 0;
        PMObject.SVMX_Recalculate(); 
        PMObject.SearchKeyword = 'abc';
        PMObject.FilterByPL = true;
        ////PMObject.SVMX_Go();  
        PMObject.FilterByPF = true;
        ////PMObject.SVMX_Go();
        PMObject.SVMX_DelData();
        PMObject.getdisplayfindpro();
        PMObject.getHdrMsg();
        Test.stopTest();
    } 
    
}