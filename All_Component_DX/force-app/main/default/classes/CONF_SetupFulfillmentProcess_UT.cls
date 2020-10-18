@isTest
private with sharing class CONF_SetupFulfillmentProcess_UT
{
    static testMethod void CONF_SetupFulfillmentProcess_UnitTest() 
    {
        RecordType Rtype_expressions;
        RecordType Rtype_NamedExpression;
        RecordType Rtype_FulFillmentProcess;
        RecordType Rtype_Prod_Doc_Attributes;
        RecordType Rtype_FulFillmentLocation;
        
        Rtype_expressions = [select Id from RecordType where Name = 'Expressions' and SobjectType = 'SVMXC__ServiceMax_Config_Data__c' Limit 1];
        Rtype_NamedExpression = [select Id from RecordType where Name = 'SVMX Rule' and SobjectType = 'SVMXC__ServiceMax_Processes__c' Limit 1];
        Rtype_FulFillmentProcess = [select Id from RecordType where Name = 'Fulfillment Process' and SobjectType = 'SVMXC__ServiceMax_Processes__c' Limit 1];
        Rtype_Prod_Doc_Attributes = [Select Id, Name from RecordType where Name = 'Field Mapping' AND SObjectType = 'SVMXC__ServiceMax_Config_Data__c' Limit 1];
        Rtype_FulFillmentLocation = [Select Id, Name from RecordType where Name = 'Fulfillment Path' AND SObjectType = 'SVMXC__ServiceMax_Config_Data__c' Limit 1];
        
        SVMXC__ServiceMax_Processes__c fulfillment = new SVMXC__ServiceMax_Processes__c();
        fulfillment.SVMXC__Parent_Error_Msg__c = 'Parent Error Message';
        fulfillment.SVMXC__Child_Error_Msg__c = 'Child Error Message';
        fulfillment.SVMXC__Name__c = 'TestFulfillmentProcess0001';
        fulfillment.SVMXC__ProcessID__c = 'TestFulfillmentProcess0001';
        fulfillment.SVMXC__Description__c = 'To Unit Testing';
        fulfillment.SVMXC__Module__c = null;
        fulfillment.SVMXC__Submodule__c = null;
        fulfillment.SVMXC__Node_Parent__c = null;
        fulfillment.SVMXC__Final_Exception_Process__c = null;
        fulfillment.RecordTypeId = Rtype_FulFillmentProcess.Id;
        fulfillment.SVMXC__IsStandard__c = false;
        insert fulfillment;
        SVMXC__ServiceMax_Processes__c fulfillment11 = new SVMXC__ServiceMax_Processes__c();
        fulfillment11.SVMXC__Parent_Error_Msg__c = 'Parent Error Message';
        fulfillment11.SVMXC__Child_Error_Msg__c = 'Child Error Message';
        fulfillment11.SVMXC__Name__c = 'TestFulfillmentProcess0001';
        fulfillment11.SVMXC__ProcessID__c = 'TestFulfillmentProcess0001';
        fulfillment11.SVMXC__Description__c = 'To Unit Testing';
        fulfillment11.SVMXC__Module__c = null;
        fulfillment11.SVMXC__Submodule__c = null;
        fulfillment11.SVMXC__Node_Parent__c = null;
        fulfillment11.SVMXC__Final_Exception_Process__c = null;
        fulfillment11.RecordTypeId = Rtype_FulFillmentProcess.Id;
        fulfillment11.SVMXC__IsStandard__c = false;
        insert fulfillment11;
        //list <SVMXC__ServiceMax_Processes__c> lstprocessData = new List <SVMXC__ServiceMax_Processes__c>();
        
        
        List<SVMXC__ServiceMax_Config_Data__c> lstConfigData = new List<SVMXC__ServiceMax_Config_Data__c>();
        SVMXC__ServiceMax_Config_Data__c confData = new SVMXC__ServiceMax_Config_Data__c();
        confData.SVMXC__Dispatch_Process__c = fulfillment.Id;
        confData.SVMXC__Configuration_Type__c = 'DOCUMENT_ATTRIBUTE';
        confData.SVMXC__Sequence__c = 1;
        confData.SVMXC__Field_Name__c = 'SVMXC__Address_Type__c';
        confData.RecordTypeId = Rtype_Prod_Doc_Attributes.Id;
        lstConfigData.add(confData);
        
        SVMXC__ServiceMax_Config_Data__c confData1 = new SVMXC__ServiceMax_Config_Data__c();
        confData1.SVMXC__Dispatch_Process__c = fulfillment.Id;
        confData1.SVMXC__Configuration_Type__c = 'DOCUMENT_ATTRIBUTE';
        confData1.SVMXC__Sequence__c = 2;
        confData1.SVMXC__Field_Name__c = 'SVMXC__Address_Type__c';
        confData1.RecordTypeId = Rtype_Prod_Doc_Attributes.Id;
        lstConfigData.add(confData1);
        
        SVMXC__ServiceMax_Config_Data__c confData2 = new SVMXC__ServiceMax_Config_Data__c();
        confData2.SVMXC__Dispatch_Process__c = fulfillment.Id;
        confData2.SVMXC__Configuration_Type__c = 'DOCUMENT_ATTRIBUTE';
        confData2.SVMXC__Sequence__c = 3;
        confData2.SVMXC__Field_Name__c = 'SVMXC__Address_Type__c';
        confData2.RecordTypeId = Rtype_Prod_Doc_Attributes.Id;
        lstConfigData.add(confData2);
        
        SVMXC__ServiceMax_Config_Data__c confData3 = new SVMXC__ServiceMax_Config_Data__c();
        confData3.SVMXC__Dispatch_Process__c = fulfillment.Id;
        confData3.SVMXC__Configuration_Type__c = 'PRODUCT_ATTRIBUTE';
        confData3.SVMXC__Sequence__c = 1;
        confData3.SVMXC__Field_Name__c = 'SVMXC__Select__c';
        confData3.RecordTypeId = Rtype_Prod_Doc_Attributes.Id;
        lstConfigData.add(confData3);
        
        SVMXC__ServiceMax_Config_Data__c confData4 = new SVMXC__ServiceMax_Config_Data__c();
        confData4.SVMXC__Dispatch_Process__c = fulfillment.Id;
        confData4.SVMXC__Configuration_Type__c = 'PRODUCT_ATTRIBUTE';
        confData4.SVMXC__Sequence__c = 2;
        confData4.SVMXC__Field_Name__c = 'SVMXC__Select__c';
        confData4.RecordTypeId = Rtype_Prod_Doc_Attributes.Id;
        lstConfigData.add(confData4);
        
        SVMXC__Site__c loc = new SVMXC__Site__c();
        loc.Name = 'Mysore';
        insert loc;
        System.assertEquals('Mysore',loc.name);
        
        SVMXC__Site__c loc1 = new SVMXC__Site__c();
        loc1.Name = 'Bangalore';
        insert loc1;
        System.assertEquals('Bangalore',loc1.name);
        
        SVMXC__ServiceMax_Processes__c pathRule = new SVMXC__ServiceMax_Processes__c();
        pathRule.SVMXC__Process__c = fulfillment.Id;
        pathRule.SVMXC__Sequence__c = 1;
        pathRule.SVMXC__Select__c = true;
        pathRule.SVMXC__Rule_Type__c = 'FulFillment Path';
        pathRule.SVMXC__Default_Location__c = loc.Id;
        pathRule.SVMXC__Submodule__c = null;
        pathRule.SVMXC__IsDefault__c = true;
        pathRule.RecordTypeId = Rtype_NamedExpression.Id;
        insert pathRule;
        
        SVMXC__ServiceMax_Config_Data__c confData5 = new SVMXC__ServiceMax_Config_Data__c();
        confData5.RecordTypeId = Rtype_FulFillmentLocation.Id;
        confData5.SVMXC__Sequence__c = 1;
        confData5.SVMXC__Location__c = loc.Id;
        confData5.SVMXC__Dispatch_Process__c = pathRule.Id;
        lstConfigData.add(confData5);
        
        SVMXC__ServiceMax_Config_Data__c confData6 = new SVMXC__ServiceMax_Config_Data__c();
        confData6.RecordTypeId = Rtype_FulFillmentLocation.Id;
        confData6.SVMXC__Sequence__c = 1;
        confData6.SVMXC__Location__c = loc1.Id;
        confData6.SVMXC__Dispatch_Process__c = pathRule.Id;
        lstConfigData.add(confData6);
        
        
        insert lstConfigData;
        
       /*  CONF_SetupFulfillmentProcess fulfillmentProcess3 = new CONF_SetupFulfillmentProcess();
        fulfillmentProcess3.OnLoadAction(); */
        
        System.currentPageReference().getParameters().put('SVMX_RecordId', fulfillment.Id);
        
        CONF_SetupFulfillmentProcess fulfillmentProcess = new CONF_SetupFulfillmentProcess();
        
        
        
        fulfillmentProcess.OnLoadAction();
        fulfillmentProcess.QuickSave();
        fulfillmentProcess.SaveNClose();
        fulfillmentProcess.editPathRule();
        fulfillmentProcess.savePathRule();
        fulfillmentProcess.CreateNewPOCriteria();
        fulfillmentProcess.OnChangePOExpr();
        fulfillmentProcess.ViewEditPOCriteria();
        fulfillmentProcess.OnChangePOLineExpr();
        fulfillmentProcess.ViewEditPOLineCriteria();
        fulfillmentProcess.POCriteria_AddRow();
        //fulfillmentProcess.POCriteria_DelRow();
        fulfillmentProcess.CreateNewPOLineCriteria();
        fulfillmentProcess.POLineCriteria_AddRow();
        //fulfillmentProcess.POLineCriteria_DelRow();
        fulfillmentProcess.gotoGeneralInfoTab();
        fulfillmentProcess.gotoCriteriaMappingsTab();
        fulfillmentProcess.gotoFulfillmentPathTab();
        fulfillmentProcess.Cancel();
        fulfillmentProcess.deletePathRule();
        fulfillmentProcess.newPathRule();
        fulfillmentProcess.cancelPathRule();
        fulfillmentProcess.CreateNewProdCriteria();
        fulfillmentProcess.OnChangeProdExpr();
        fulfillmentProcess.ViewEditProdCriteria();
        fulfillmentProcess.ProdCriteria_AddRow();
        //fulfillmentProcess.ProdCriteria_DelRow();
        fulfillmentProcess.PopulateAvailableDepots();
        fulfillmentProcess.Depots_MoveRight();
        fulfillmentProcess.Depots_MoveLeft();
        fulfillmentProcess.ruleSequence();
        fulfillmentProcess.getSeqoptions();
        fulfillmentProcess.UP();
        fulfillmentProcess.Down();
        fulfillmentProcess.Top();
        fulfillmentProcess.Bottom();
        fulfillmentProcess.SVMX_SaveSequence();
        fulfillmentProcess.SVMX_PopupCancel();
        fulfillmentProcess.QuickSave();
        fulfillmentProcess.LstPOCriteria .add(confData5);
        fulfillmentProcess.LstPOCriteria .add(confData6);
        
        fulfillmentProcess.SelectedRow = '1';
        fulfillmentProcess.POLineCriteria_DelRow();
        fulfillmentProcess.POCriteria_DelRow();
        
        //----------- calling getter setters------------------
        fulfillmentProcess.getOperatorSelectLst();
        fulfillmentProcess.getlstDocumentFields();
        fulfillmentProcess.getlstDocumentLineFields();
        fulfillmentProcess.getlstProductFields();
        fulfillmentProcess.getlstProductExpr();
        fulfillmentProcess.getlstPOExpr();
        fulfillmentProcess.getlstPOLineExpr();
        fulfillmentProcess.getlstPOObjMap();
        fulfillmentProcess.getlstPOLineObjMap();
        fulfillmentProcess.getlstFulfillmentLocs();
        fulfillmentProcess.getlstParentDepots();
        List<String> lstStr = fulfillmentProcess.getavailableDepotsSelctd();
        fulfillmentProcess.setavailableDepotsSelctd(lstStr);
        fulfillmentProcess.getselectedDepotsSelctd();
        fulfillmentProcess.setselectedDepotsSelctd(lstStr);
        fulfillmentProcess.getAvailableDepotOptns();
        fulfillmentProcess.getSelectedDepotsOptns();
        SVMXC__ServiceMax_Processes__c pro = fulfillmentProcess.getPOExp();
        fulfillmentProcess.setPOExp(pro);
        fulfillmentProcess.getPOLineExp();
        fulfillmentProcess.setPOLineExp(pro);
        fulfillmentProcess.getProdExp();
        fulfillmentProcess.setProdExp(pro);
        List<SVMXC__ServiceMax_Config_Data__c> lst = fulfillmentProcess.getLstPOCriteria();
        fulfillmentProcess.setLstPOCriteria(lst);
        fulfillmentProcess.getLstPOLineCriteria();
        fulfillmentProcess.setLstPOLineCriteria(lst);
        fulfillmentProcess.getLstProdCriteria();
        fulfillmentProcess.setLstProdCriteria(lst);
        fulfillmentProcess.getFulfillmentProcess();
        fulfillmentProcess.setFulfillmentProcess(pro);
        List<SVMXC__ServiceMax_Processes__c> lstPro = fulfillmentProcess.getlstFulfillmentPathRules();
        fulfillmentProcess.setlstFulfillmentPathRules(lstPro);
        fulfillmentProcess.getfulfillmentPathRule();
        fulfillmentProcess.setfulfillmentPathRule(pro);
        fulfillmentProcess.getHLPURL();
        fulfillmentProcess.getTAG001();
        fulfillmentProcess.getTAG002();
        fulfillmentProcess.getTAG003();
        fulfillmentProcess.getTAG004();
        fulfillmentProcess.getTAG005();
        fulfillmentProcess.getTAG006();
        fulfillmentProcess.getTAG007();
        fulfillmentProcess.getTAG008();
        fulfillmentProcess.getTAG009();
        fulfillmentProcess.getTAG010();
        fulfillmentProcess.getTAG011();
        //fulfillmentProcess.getTAG012();
        //fulfillmentProcess.getTAG013();
        //fulfillmentProcess.getTAG014();
        fulfillmentProcess.getTAG015();
        fulfillmentProcess.getTAG016();
        fulfillmentProcess.getTAG017();
        fulfillmentProcess.getTAG018();
        fulfillmentProcess.getTAG019();
        fulfillmentProcess.getTAG020();
        fulfillmentProcess.getTAG021();
        fulfillmentProcess.getTAG022();
        fulfillmentProcess.getTAG023();
        fulfillmentProcess.getTAG024();
        fulfillmentProcess.getTAG025();
        fulfillmentProcess.getTAG026();
        fulfillmentProcess.getTAG027();
        fulfillmentProcess.getTAG028();
        fulfillmentProcess.getTAG029();
        fulfillmentProcess.getTAG030();
        fulfillmentProcess.getTAG031();
        fulfillmentProcess.getTAG032();
        fulfillmentProcess.getTAG033();
        fulfillmentProcess.getTAG034();
        fulfillmentProcess.getTAG035();
        fulfillmentProcess.getTAG036();
        fulfillmentProcess.getTAG037();
        fulfillmentProcess.getTAG038();
        fulfillmentProcess.getTAG039();
        fulfillmentProcess.getTAG040();
        fulfillmentProcess.getTAG041();
        fulfillmentProcess.getTAG042();
        fulfillmentProcess.getTAG043();
        fulfillmentProcess.getTAG044();
        fulfillmentProcess.getTAG060();
        fulfillmentProcess.getTAG061();
        fulfillmentProcess.getTAG062();
        fulfillmentProcess.getTAG064();
        fulfillmentProcess.getTAG065();
        fulfillmentProcess.getTAG066();
        fulfillmentProcess.getTAG067();
        fulfillmentProcess.getTAG068();
        fulfillmentProcess.getTAG069();
        fulfillmentProcess.getTAG070();
        fulfillmentProcess.getTAG071();
        fulfillmentProcess.getTAG072();
        fulfillmentProcess.getTAG073();
        fulfillmentProcess.getTAG074();
        fulfillmentProcess.getTAG075();
        fulfillmentProcess.getTAG076();
        fulfillmentProcess.getTAG077();
        fulfillmentProcess.getTAG078();
        fulfillmentProcess.getTAG079();
        fulfillmentProcess.getTAG080();
        fulfillmentProcess.getTAG081();
        fulfillmentProcess.getTAG082();
        fulfillmentProcess.getTAG083();
        fulfillmentProcess.getTAG084();
        fulfillmentProcess.getTAG085();
        fulfillmentProcess.getTAG086();
        fulfillmentProcess.getTAG087();
        fulfillmentProcess.getTAG088();
        fulfillmentProcess.getTAG089();
        fulfillmentProcess.getTAG090();
        fulfillmentProcess.getTAG091();
        
        
        lstConfigData.add(confData);
          fulfillmentProcess.saveProdExp();
          fulfillmentProcess.TempRuleLst.add(fulfillment);
        fulfillmentProcess.TempRuleLst.add(fulfillment11);
         fulfillmentProcess.shuffle(0,true);
           
        fulfillmentProcess.shuffle(0,false);
      fulfillmentProcess.submitExp(fulfillment,lstConfigData);
      
       fulfillmentProcess.savePathRule();
       //fulfillmentProcess.POCriteria_DelRow();
       lstConfigData.add(confData5);
       //fulfillmentProcess.POLineCriteria_DelRow();
       lstConfigData.add(confData5);
       fulfillmentProcess.SelectedRow='1';
         fulfillmentProcess.ProdCriteria_DelRow();
       //fulfillmentProcess.ProdCriteria_DelRow();
      //items.add('aa');
       // items.add('bb');
         fulfillmentProcess.UpLoc();
    }
    
    static testMethod void CONF_SetupFulfillmentProcess_UnitTest1() 
    {
        RecordType Rtype_FulFillmentProcess = [select Id from RecordType where Name = 'fulfillment Process' and SobjectType = 'SVMXC__ServiceMax_Processes__c' Limit 1];
        RecordType Rtype_NamedExpression = [select Id from RecordType where Name = 'SVMX Rule' and SobjectType = 'SVMXC__ServiceMax_Processes__c' Limit 1];
        RecordType Rtype_FulFillmentLocation = [Select Id, Name from RecordType where Name = 'fulfillment Path' AND SObjectType = 'SVMXC__ServiceMax_Config_Data__c' Limit 1];
        
        SVMXC__ServiceMax_Processes__c fulfillment1 = new SVMXC__ServiceMax_Processes__c();
        fulfillment1.SVMXC__Parent_Error_Msg__c = 'Parent Error Message';
        fulfillment1.SVMXC__Child_Error_Msg__c = 'Child Error Message';
        fulfillment1.SVMXC__Name__c = 'TestFulfillmentProcess0001';
        fulfillment1.SVMXC__ProcessID__c = 'TestFulfillmentProcess0001';
        fulfillment1.SVMXC__Description__c = 'To Unit Testing';
        fulfillment1.SVMXC__Module__c = null;
        fulfillment1.SVMXC__Submodule__c = null;
        fulfillment1.SVMXC__Node_Parent__c = null;
        fulfillment1.SVMXC__Final_Exception_Process__c = null;
        fulfillment1.RecordTypeId = Rtype_FulFillmentProcess.Id;
        fulfillment1.SVMXC__IsStandard__c = false;
        insert fulfillment1;
        
        SVMXC__Site__c loc = new SVMXC__Site__c();
        loc.Name = 'Mysore';
        insert loc;
        
        List<SVMXC__ServiceMax_Config_Data__c> lstConfigData = new List<SVMXC__ServiceMax_Config_Data__c>();
        
        SVMXC__ServiceMax_Processes__c pathRule = new SVMXC__ServiceMax_Processes__c();
        pathRule.SVMXC__Process__c = fulfillment1.Id;
        pathRule.SVMXC__Sequence__c = 1;
        pathRule.SVMXC__Select__c = true;
        pathRule.SVMXC__Rule_Type__c = 'fulfillment Path';
        pathRule.SVMXC__Default_Location__c = loc.Id;
        pathRule.SVMXC__Submodule__c = null;
        pathRule.SVMXC__IsDefault__c = true;
        pathRule.RecordTypeId = Rtype_NamedExpression.Id;
        insert pathRule;
        
        SVMXC__ServiceMax_Config_Data__c confData5 = new SVMXC__ServiceMax_Config_Data__c();
        confData5.RecordTypeId = Rtype_FulFillmentLocation.Id;
        confData5.SVMXC__Sequence__c = 1;
        confData5.SVMXC__Location__c = loc.Id;
        confData5.SVMXC__Dispatch_Process__c = pathRule.Id;
        lstConfigData.add(confData5);
        
        insert lstConfigData;
        

        System.currentPageReference().getParameters().put('SVMX_RecordId', fulfillment1.Id);
        
        System.currentPageReference().getParameters().put('SVMX_Mode', 'Clone');
        CONF_SetupFulfillmentProcess fulfillmentProcess1 = new CONF_SetupFulfillmentProcess();
        fulfillmentProcess1.OnLoadAction();
        fulfillmentProcess1.validate=true;
        fulfillmentProcess1.savePathRule();
        
        SVMXC__ServiceMax_Processes__c POLineExp = new SVMXC__ServiceMax_Processes__c();
        POLineExp.SVMXC__Parent_Error_Msg__c = 'Parent Error Message';
        POLineExp.SVMXC__Child_Error_Msg__c = 'Child Error Message';
        POLineExp.SVMXC__Name__c = null;
        POLineExp.SVMXC__ProcessID__c = null;
        POLineExp.SVMXC__Description__c = 'To Unit Testing';
        POLineExp.SVMXC__Module__c = null;
        POLineExp.SVMXC__Submodule__c = null;
        POLineExp.SVMXC__Node_Parent__c = null;
        POLineExp.SVMXC__Final_Exception_Process__c = null;
        POLineExp.RecordTypeId = Rtype_FulFillmentProcess.Id;
        POLineExp.SVMXC__IsStandard__c = false;
        insert POLineExp;
        fulfillmentProcess1.saveExp();
        
        SVMXC__ServiceMax_Config_Data__c confDat = new SVMXC__ServiceMax_Config_Data__c();
        confDat.SVMXC__Dispatch_Process__c = fulfillment1.Id;
        confDat.SVMXC__Configuration_Type__c = 'DOCUMENT_ATTRIBUTE';
        confDat.SVMXC__Sequence__c = 2;
        confDat.SVMXC__Field_Name__c = 'SVMXC__Address_Type__c';

        insert confDat;
        fulfillmentProcess1.LstPOCriteria.add(confDat); 
        
        
        
        fulfillmentProcess1.LstPOCriteria.add(confDat); 
        fulfillmentProcess1.LstPOLineCriteria.add(confDat); 
        fulfillmentProcess1.LstProdCriteria.add(confDat); 
        
        SVMXC__ServiceMax_Config_Data__c confDat1 = new SVMXC__ServiceMax_Config_Data__c();
        confDat1.SVMXC__Dispatch_Process__c = fulfillment1.Id;
        confDat1.SVMXC__Configuration_Type__c = 'DOCUMENT_ATTRIBUTE';
        confDat1.SVMXC__Sequence__c = 2;
        confDat1.SVMXC__Field_Name__c = 'SVMXC__Address_Type__c';
        
        insert confDat1;
        fulfillmentProcess1.LstPOCriteria.add(confDat1); 
        fulfillmentProcess1.LstPOLineCriteria.add(confDat1);
        fulfillmentProcess1.LstProdCriteria.add(confDat1);
        fulfillmentProcess1.ProdCriteria_AddRow();
        fulfillmentProcess1.POCriteria_AddRow();
        fulfillmentProcess1.POLineCriteria_AddRow();
        //fulfillmentProcess1.POLineCriteria_DelRow();
        //fulfillmentProcess1.ProdCriteria_DelRow();
        //fulfillmentProcess1.POCriteria_DelRow();
        fulfillmentProcess1.TempRuleLst.add(pathRule);
        fulfillmentProcess1.TempRuleLst.add(POLineExp);
        fulfillmentProcess1.items.add(POLineExp.id);
        fulfillmentProcess1.items.add(pathRule.id);
        fulfillmentProcess1.up();
        fulfillmentProcess1.down();
        fulfillmentProcess1.Top();
        fulfillmentProcess1.Bottom();
        fulfillmentProcess1.IsUpAction=true;
        fulfillmentProcess1.SVMX_SaveSequence();
        fulfillmentProcess1.IsUpAction=false;
        fulfillmentProcess1.IsDownAction=true;
        fulfillmentProcess1.SVMX_SaveSequence();
        fulfillmentProcess1.IsUpAction=false;
        fulfillmentProcess1.IsDownAction=false;
        fulfillmentProcess1.IsTopAction=true;
        fulfillmentProcess1.SVMX_SaveSequence();
        fulfillmentProcess1.IsUpAction=false;
        fulfillmentProcess1.IsDownAction=false;
        fulfillmentProcess1.IsTopAction=false;
        fulfillmentProcess1.IsBottomAction=true;
        fulfillmentProcess1.SVMX_SaveSequence();
        fulfillmentProcess1.getSeqoptions();
        fulfillmentProcess1.getitems();     
        fulfillmentProcess1.getrenderSeqPopup();
        
        fulfillmentProcess1.renderPOLineExprBlock=true;
        fulfillmentProcess1.LstPOLineCriteria.clear(); 
        fulfillmentProcess1.saveExp();

        
}
static testMethod void CONF_SetupFulfillmentProcess_UnitTest2() 
{
CONF_SetupFulfillmentProcess fulfillmentProcess4 = new CONF_SetupFulfillmentProcess();
list<string> strLst = new list<string>();
        string str = 'Bangalore';
        strLst.add(str);
        fulfillmentProcess4.setselectedDepotsSelctd(strLst);
        //fulfillmentProcess3.selectedDepotsSelctd.add('Bangalore');
         SVMXC__Site__c loc2 = new SVMXC__Site__c();
        loc2.Name = 'Mysore';
        insert loc2;
        SVMXC__Site__c loc3 = new SVMXC__Site__c();
        loc3.Name = 'Bangalore';
        insert loc3;
        fulfillmentProcess4.SelectedDepotsOptns.add(new SelectOption(loc2.Name, 'Mysore'));
        fulfillmentProcess4.SelectedDepotsOptns.add(new SelectOption(loc3.Name, 'Bangalore'));
        fulfillmentProcess4.TopLoc();
        fulfillmentProcess4.UpLoc();
        fulfillmentProcess4.DownLoc();
        fulfillmentProcess4.BottomLoc();
        }
}