@isTest
    private class CONF_SetupViews_UT
    {
        static testMethod void CONF_SetupViews_UT_Test()
        {
            CONF_SetupViews objSetupVew = new CONF_SetupViews();
            objSetupVew.quickSave();
            objSetupVew.saveNClose();
            objSetupVew.saveNAssign();
            
            objSetupVew.againLoad();
            
            RecordType ProcessRType = [select Id from RecordType where Name = 'View Definition' AND SobjectType= 'SVMXC__ServiceMax_Processes__c' Limit 1];
            RecordType ConfigRType = [select Id from RecordType where Name = 'Expressions' AND SobjectType=
            'SVMXC__ServiceMax_Config_Data__c' Limit 1];
            
            SVMXC__ServiceMax_Processes__c objSVMXPrcss = new SVMXC__ServiceMax_Processes__c(SVMXC__Source_Object_Name__c = 'SVMXC__Service_Order__c',SVMXC__Ownership_Type__c = 'All Records',SVMXC__Rule_Type__c = 'Custom View',SVMXC__ProcessID__c = 'testing1234',SVMXC__Name__c = 'testing1234',SVMXC__Advance_Expression__c = '',SVMXC__IsStandard__c = false,RecordTypeId = ProcessRType.Id);
            insert objSVMXPrcss;
            System.assertEquals(true,objSVMXPrcss.Id != null);
            
            SVMXC__ServiceMax_Config_Data__c objCfgDtaTemp = new SVMXC__ServiceMax_Config_Data__c(RecordTypeId = ConfigRType.Id, SVMXC__Object_Name2__c = 'SVMXC__Service_Order__c',SVMXC__Expression_Type__c = 'SRCH_Object_Fields',SVMXC__Field_Name__c = 'Name',SVMXC__Expression_Rule__c = objSVMXPrcss.Id);            
            insert objCfgDtaTemp;
            System.assertEquals(true, objCfgDtaTemp.Id != null);            
            
            SVMXC__ServiceMax_Config_Data__c objCfgDtaTemp2 = new SVMXC__ServiceMax_Config_Data__c(SVMXC__Field_Name__c = 'Name', SVMXC__Operator__c = 'isnull',SVMXC__Object_Name2__c = 'SVMXC__Service_Order__c',SVMXC__Expression_Type__c = 'SRCH_Object_Prefilter_Criteria',SVMXC__Sequence__c = 1,SVMXC__Expression_Rule__c = objSVMXPrcss.Id,RecordTypeId = ConfigRType.Id);            
            Insert objCfgDtaTemp2;
            System.assertEquals(true, objCfgDtaTemp2.Id != null);
            
            ApexPages.currentPage().getParameters().put('SVMX_ViewId',objSVMXPrcss.Id);
            ApexPages.currentPage().getParameters().put('SVMX_Mode','Clone');
            CONF_SetupViews objSetupVew123 = new CONF_SetupViews();
            
            List<selectOption> lstAllObj = new List<selectOption>();
            lstAllObj.add(new SelectOption('test1' , 'test1'));
            lstAllObj.add(new SelectOption('test2' , 'test2'));
            lstAllObj.add(new SelectOption('test3' , 'test3'));
            lstAllObj.add(new SelectOption('test4' , 'test4'));
            
            list<String> lstTest = new List<String>();
            lstTest.add('test1');
            lstTest.add('test2');
            lstTest.add('test3');
            
           // objSetupVew.strViewId = objSVMXPrcss.Id;
            
            objSetupVew.setObjSVMXPrcss(objSVMXPrcss);
            objSetupVew.quickSave();
            objSetupVew.saveNClose();
            objSetupVew.saveNAssign();
            
           // objSetupVew.strMode = 'Clone';
            objSetupVew.againLoad();
            objSetupVew.getQuery();                        
                                
            objSetupVew.getLstCfgDta();
            //objSetupVew.getLstCfgDta2();
            objSetupVew.getObjSVMXPrcss();
            objSetupVew.setObjSVMXPrcss(objSVMXPrcss);
            objSetupVew.getOwnerType();
            objSetupVew.getFildSelectLst();
            objSetupVew.getOperatorsSelectLst();
            objSetupVew.getLstAllObj();
            objSetupVew.setLstAllObj(lstAllObj);
            objSetupVew.getStrFildIN();
            objSetupVew.setStrFildIN(lstTest);
            objSetupVew.getStrFildOut();
            objSetupVew.setStrFildOut(lstTest);
            objSetupVew.getslctOptnIN();
            objSetupVew.setslctOptnIN(lstAllObj);
            objSetupVew.getslctOptnOut();
            objSetupVew.setslctOptnOut(lstAllObj);
            objSetupVew.setlstViewFor(lstAllObj);
            objSetupVew.getlstViewFor();       

            SVMXC__ServiceMax_Processes__c objSVMXPrcss1 = new SVMXC__ServiceMax_Processes__c(SVMXC__Source_Object_Name__c = 'SVMXC__Site__c',SVMXC__Ownership_Type__c = 'All Records',SVMXC__Rule_Type__c = 'Custom View',SVMXC__ProcessID__c = 'testing1234',SVMXC__Name__c = 'testing1234',SVMXC__Advance_Expression__c = '',SVMXC__IsStandard__c = false,RecordTypeId = ProcessRType.Id);
            insert objSVMXPrcss1;
            System.assertEquals(true,objSVMXPrcss1.Id != null);         
            objSetupVew.setObjSVMXPrcss(objSVMXPrcss1);
            objSetupVew.makeViewForPickList();
            objSetupVew.changeOfObj();
            objSetupVew.againLoad();
            objSetupVew.addExpRow();
            
            
            objSetupVew.moveOutWOFild();
            objSetupVew.moveInWOFild();         
            
            
            objSetupVew.quickSave();
            objSetupVew.saveNClose();
            objSetupVew.saveNAssign();
            objSetupVew.assign();
            
            objSetupVew.Cancel();
            
            Delete objSVMXPrcss;
            objSetupVew.againLoad();
            objSetupVew.selectedObjSerial = 1;
            objSetupVew.delExpRow();
            
            objSetupVew.Top();
            objSetupVew.Bottom();           
            objSetupVew.Up();
            objSetupVew.Down();
            
            //calling tags
            objSetupVew.getHLPURL();
            objSetupVew.getTAG001();
            objSetupVew.getTAG002();
            objSetupVew.getTAG003();
            objSetupVew.getTAG004();
            objSetupVew.getTAG005();
            objSetupVew.getTAG006();
            objSetupVew.getTAG007();
            objSetupVew.getTAG008();
            objSetupVew.getTAG009();
            objSetupVew.getTAG010();
            objSetupVew.getTAG011();
            objSetupVew.getTAG012();
            objSetupVew.getTAG013();
            objSetupVew.getTAG014();
            objSetupVew.getTAG015();
            objSetupVew.getTAG016();
            objSetupVew.getTAG031();
            objSetupVew.getTAG032();
            //objSetupVew.getTAG033();
            //objSetupVew.getTAG034();
            objSetupVew.getTAG036();
            objSetupVew.getTAG037();
            objSetupVew.getTAG039();
            objSetupVew.getTAG040();
            objSetupVew.getTAG041();
            objSetupVew.getTAG042();
            objSetupVew.getTAG043();
            objSetupVew.getTAG044();
            objSetupVew.getTAG045();
            objSetupVew.getTAG046();
            objSetupVew.getTAG047();
            objSetupVew.getTAG048();
            objSetupVew.getTAG049();
            objSetupVew.strFildOut.add('Data');
            objSetupVew.strFildIN.add('Data');            
            objSetupVew.strFildOut.add('Name');
            objSetupVew.strFildIN.add('Name');
            objSetupVew.strFildOut.add('Name');
            objSetupVew.strFildIN.add('Name');
            objSetupVew.Top();
            objSetupVew.Bottom();
            objSetupVew.Up();
            objSetupVew.Down();     
                   
            objSetupVew.getisErMsgBlk();
            objSetupVew.setisErMsgBlk();
            objSetupVew.getdisableSourceObj();
            objSetupVew.setdisableSourceObj();
        }
    }