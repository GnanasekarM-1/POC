@isTest 
private with sharing class INTF_ParseProcess_UT 
{

    public static map<String, Schema.SObjectType> allobjmap  = new map<String, Schema.SObjectType>();
    public static map<String, Schema.SObjectType> gd = new map<String, Schema.SObjectType>();
    
    public INTF_ParseProcess_UT()
    {
        gd = Schema.getGlobalDescribe();
        for(Schema.SObjectType s : gd.values())
        {
            Schema.DescribeSObjectResult result = s.getDescribe();
            allobjmap.put(result.getName(),s);
        } 
    }  
    
    static testMethod void ForStandAloneCreate()
    {
      String targetManager;
      String processNodeObjects;
      String objectMapping; 
      String fieldMapping;
      String expression;
      String SVMXRule;
      List<RecordType> RTypeList = [SELECT Id, Name,SobjectType,IsActive,DeveloperName from RecordType  where SobjectType = 'SVMXC__ServiceMax_Processes__c' OR  SobjectType = 'SVMXC__ServiceMax_Config_Data__c'];
        system.debug('RTypeList'+RTypeList);
        if(RTypeList.size() > 0)
        {
          for(RecordType r : RTypeList)
          {
            if(r.Name == 'Target Manager')
              targetManager = r.id;
            else if(r.Name ==  'Process Node Objects')
              processNodeObjects = r.id;
            else if(r.Name == 'Object Mapping')
              objectMapping = r.id;
            else if(r.Name == 'Field Mapping')
              fieldMapping = r.id;
            else if(r.Name == 'Expressions')
              expression = r.id;  
            else if(r.Name == 'SVMX Rule')
              SVMXRule = r.Name;    
          }
        }
      //Create PageHeader
      SVMXC__Page_Layout__c PageHeader = new SVMXC__Page_Layout__c();
      PageHeader.SVMXC__Name__c = 'PAGE00001';
      PageHeader.SVMXC__Object_Name__c = 'SVMXC__Quote__c';
      PageHeader.SVMXC__Type__c = 'Header';
      insert PageHeader;
      system.assert(PageHeader.SVMXC__Name__c != null);
      system.assert(PageHeader.SVMXC__Object_Name__c != null);
      
      //Create PageDetail
      SVMXC__Page_Layout__c PageDetail = new SVMXC__Page_Layout__c();
      PageDetail.SVMXC__Header_Page_Layout__c = PageHeader.id;
      PageDetail.SVMXC__Object_Name__c = 'SVMXC__Quote_Line__c';
      PageHeader.SVMXC__Type__c = 'Detail';
      insert PageDetail;
      system.assert(PageHeader.SVMXC__Type__c != null);
      
      //Create SFM Process Defination
      SVMXC__ServiceMax_Processes__c standaloneCreate = new SVMXC__ServiceMax_Processes__c();
      standaloneCreate.SVMXC__Name__c = 'CUSTOMPRO0001';
      standaloneCreate.RecordTypeId = targetManager;
      standaloneCreate.SVMXC__Purpose__c = 'STANDALONE CREATE';
      standaloneCreate.SVMXC__ProcessID__c = 'CUSTOMPRO0001';
      standaloneCreate.SVMXC__Page_Layout__c = PageHeader.id;
      insert standaloneCreate;
      system.assert(standaloneCreate.SVMXC__Purpose__c != null);
      system.assert(standaloneCreate.SVMXC__ProcessID__c != null);
      
      //Create Mapping For Header Record
      SVMXC__ServiceMax_Processes__c valMapHdr = new SVMXC__ServiceMax_Processes__c();
      valMapHdr.SVMXC__MapID__c = 'VMAP000001';
      valMapHdr.SVMXC__Target_Object_Name__c = 'SVMXC__Quote__c';
      valMapHdr.RecordTypeId = objectMapping;
      insert valMapHdr;
      //Create Mapping For Detail Record
      SVMXC__ServiceMax_Processes__c valMapDetail = new SVMXC__ServiceMax_Processes__c();
      valMapDetail.SVMXC__MapID__c = 'VMAP000002';
      valMapDetail.SVMXC__Target_Object_Name__c = 'SVMXC__Quote_Line__c';
      valMapDetail.RecordTypeId = objectMapping;
      insert valMapDetail;
      
      //Create Process Node object Records.
      list<SVMXC__ServiceMax_Processes__c> listProcessNodeObjects = new list<SVMXC__ServiceMax_Processes__c>();
      SVMXC__ServiceMax_Processes__c PNObject1 = new SVMXC__ServiceMax_Processes__c();
      PNObject1.RecordTypeId = processNodeObjects;
      PNObject1.SVMXC__Type__c = 'TARGET';
      PNObject1.SVMXC__Source_Object_Name__c = 'SVMXC__Quote__c';
      PNObject1.SVMXC__Process__c = standaloneCreate.id;
      PNObject1.SVMXC__Final_Exception_Process__c = valMapHdr.id;
      listProcessNodeObjects.add(PNObject1);
      
      SVMXC__ServiceMax_Processes__c PNObject2 = new SVMXC__ServiceMax_Processes__c();
      PNObject2.RecordTypeId = processNodeObjects;
      PNObject2.SVMXC__Type__c = 'TARGETCHILD';
      PNObject2.SVMXC__Page_Layout__c = PageDetail.id;
      PNObject2.SVMXC__Source_Object_Name__c = 'SVMXC__Quote_Line__c';
      PNObject2.SVMXC__Parent_Column_Name__c = 'SVMXC__Quote__c';
      PNObject2.SVMXC__Process__c = standaloneCreate.id;
      PNObject2.SVMXC__Final_Exception_Process__c = valMapDetail.id;
      listProcessNodeObjects.add(PNObject2);
      insert listProcessNodeObjects;
      Test.startTest();
      try
      {
        SVMXC.INTF_ParseProcess obj = new SVMXC.INTF_ParseProcess ();
        obj.getINTF_ParseProcess(standaloneCreate.id,Null,allobjmap);
      }
      catch(Exception ex)
      {
        system.debug('Exception: '+ex.getMessage());
      }  
      Test.stopTest();
    }  
    static testMethod void ForSourceToTargetAll()
    {
      String targetManager;
      String processNodeObjects;
      String objectMapping; 
      String fieldMapping;
      String expression;
      String SVMXRule;
      List<RecordType> RTypeList = [SELECT Id, Name,SobjectType,IsActive,DeveloperName from RecordType  where SobjectType = 'SVMXC__ServiceMax_Processes__c' OR  SobjectType = 'SVMXC__ServiceMax_Config_Data__c'];
        system.debug('RTypeList'+RTypeList);
        if(RTypeList.size() > 0)
        {
          for(RecordType r : RTypeList)
          {
            if(r.Name == 'Target Manager')
              targetManager = r.id;
            else if(r.Name ==  'Process Node Objects')
              processNodeObjects = r.id;
            else if(r.Name == 'Object Mapping')
              objectMapping = r.id;
            else if(r.Name == 'Field Mapping')
              fieldMapping = r.id;
            else if(r.Name == 'Expressions')
              expression = r.id;  
            else if(r.Name == 'SVMX Rule')
              SVMXRule = r.id;    
          }
        }
      //Create PageHeader
      SVMXC__Page_Layout__c PageHeader = new SVMXC__Page_Layout__c();
      PageHeader.SVMXC__Name__c = 'PAGE00001';
      PageHeader.SVMXC__Object_Name__c = 'SVMXC__Quote__c';
      PageHeader.SVMXC__Type__c = 'Header';
      insert PageHeader;
      //Create PageDetail
      SVMXC__Page_Layout__c PageDetail = new SVMXC__Page_Layout__c();
      PageDetail.SVMXC__Header_Page_Layout__c = PageHeader.id;
      PageDetail.SVMXC__Object_Name__c = 'SVMXC__Quote_Line__c';
      PageHeader.SVMXC__Type__c = 'Detail';
      insert PageDetail;
      
      //Create SFM Process Defination
      SVMXC__ServiceMax_Processes__c SourceToTargetAll = new SVMXC__ServiceMax_Processes__c();
      SourceToTargetAll.SVMXC__Name__c = 'CUSTOMPRO0001';
      SourceToTargetAll.RecordTypeId = targetManager;
      SourceToTargetAll.SVMXC__Purpose__c = 'SOURCE TO TARGET ALL';
      SourceToTargetAll.SVMXC__ProcessID__c = 'CUSTOMPRO0001';
      SourceToTargetAll.SVMXC__Page_Layout__c = PageHeader.id;
      insert SourceToTargetAll;
      
      //Create Mapping For Header Record
      SVMXC__ServiceMax_Processes__c valMapHdr = new SVMXC__ServiceMax_Processes__c();
      valMapHdr.SVMXC__MapID__c = 'VMAP000001';
      valMapHdr.SVMXC__Target_Object_Name__c = 'SVMXC__Quote__c';
      valMapHdr.RecordTypeId = objectMapping;
      insert valMapHdr;
      system.assert(valMapHdr.SVMXC__Target_Object_Name__c != null);
      system.assert(valMapHdr.SVMXC__MapID__c != null);
      
      //Create Mapping For Detail Record
      SVMXC__ServiceMax_Processes__c valMapDetail = new SVMXC__ServiceMax_Processes__c();
      valMapDetail.SVMXC__MapID__c = 'VMAP000002';
      valMapDetail.SVMXC__Target_Object_Name__c = 'SVMXC__Quote_Line__c';
      valMapDetail.RecordTypeId = objectMapping;
      insert valMapDetail;
        system.assert(valMapDetail.SVMXC__Target_Object_Name__c != null);
      system.assert(valMapDetail.SVMXC__MapID__c != null);
      
      //Create Expression Record
      SVMXC__ServiceMax_Processes__c ExpressionRec = new SVMXC__ServiceMax_Processes__c();
      ExpressionRec.RecordTypeId = SVMXRule;
      ExpressionRec.SVMXC__Rule_Type__c = 'Named Expression'; 
      ExpressionRec.SVMXC__Name__c = 'EXpression111';
      ExpressionRec.SVMXC__SettingID__c = 'EXpression111';
      insert ExpressionRec;
      system.assert(ExpressionRec.SVMXC__SettingID__c != null);
      system.assert(ExpressionRec.SVMXC__Rule_Type__c != null);
      
      //Create Process Node object Records.
      list<SVMXC__ServiceMax_Processes__c> listProcessNodeObjects = new list<SVMXC__ServiceMax_Processes__c>();
      SVMXC__ServiceMax_Processes__c PNObject1 = new SVMXC__ServiceMax_Processes__c();
      PNObject1.RecordTypeId = processNodeObjects;
      PNObject1.SVMXC__Type__c = 'TARGET';
      PNObject1.SVMXC__Source_Object_Name__c = 'SVMXC__Quote__c';
      PNObject1.SVMXC__Process__c = SourceToTargetAll.id;
      PNObject1.SVMXC__Submodule__c = ExpressionRec.id;
      PNObject1.SVMXC__Final_Exception_Process__c = valMapHdr.id;
      PNObject1.SVMXC__Module__c = valMapHdr.id;
      PNObject1.SVMXC__Node_Source_Object_API__c = 'SVMXC__Quote__c';
      listProcessNodeObjects.add(PNObject1);
      
      SVMXC__ServiceMax_Processes__c PNObject2 = new SVMXC__ServiceMax_Processes__c();
      PNObject2.RecordTypeId = processNodeObjects;
      PNObject2.SVMXC__Type__c = 'TARGETCHILD';
      PNObject2.SVMXC__Page_Layout__c = PageDetail.id;
      PNObject2.SVMXC__Source_Object_Name__c = 'SVMXC__Quote_Line__c';
      PNObject2.SVMXC__Parent_Column_Name__c = 'SVMXC__Quote__c';
      PNObject2.SVMXC__Process__c = SourceToTargetAll.id;
      PNObject2.SVMXC__Submodule__c = ExpressionRec.id;
      PNObject2.SVMXC__Module__c = valMapDetail.id;
      PNObject2.SVMXC__Final_Exception_Process__c = valMapDetail.id;
      PNObject2.SVMXC__Node_Source_Object_API__c = 'SVMXC__Quote_Line__c';
      listProcessNodeObjects.add(PNObject2);
      
      SVMXC__ServiceMax_Processes__c PNObject3 = new SVMXC__ServiceMax_Processes__c();
      PNObject3.RecordTypeId = processNodeObjects;
      PNObject3.SVMXC__Type__c = 'SOURCE';
      PNObject3.SVMXC__Source_Object_Name__c = 'SVMXC__Quote__c';
      PNObject3.SVMXC__Process__c = SourceToTargetAll.id;
      PNObject3.SVMXC__Final_Exception_Process__c = valMapHdr.id;
      listProcessNodeObjects.add(PNObject3);
      
      SVMXC__ServiceMax_Processes__c PNObject4 = new SVMXC__ServiceMax_Processes__c();
      PNObject4.RecordTypeId = processNodeObjects;
      PNObject4.SVMXC__Type__c = 'SOURCECHILD';
      PNObject4.SVMXC__Page_Layout__c = PageDetail.id;
      PNObject4.SVMXC__Source_Object_Name__c = 'SVMXC__Quote_Line__c';
      PNObject4.SVMXC__Parent_Column_Name__c = 'SVMXC__Quote__c';
      PNObject4.SVMXC__Process__c = SourceToTargetAll.id;
      PNObject4.SVMXC__Final_Exception_Process__c = valMapDetail.id;
      listProcessNodeObjects.add(PNObject4);
      insert listProcessNodeObjects;
      
      SVMXC__Quote__c Quote = new SVMXC__Quote__c();
      Quote.SVMXC__Discount__c  = 10;
      Quote.SVMXC__Discount_Type__c = 'amount';
      Quote.SVMXC__Valid_Until__c = system.today() + 15;
      insert Quote;
      SVMXC__Quote_Line__c QLine = new SVMXC__Quote_Line__c();
      QLine.SVMXC__Quote__c = Quote.id;
      QLine.SVMXC__Discount__c  = 10;
      QLine.SVMXC__Discount_Type__c = 'amount';
      insert QLine;
      Test.startTest();
      try
      {
        SVMXC.INTF_ParseProcess obj = new SVMXC.INTF_ParseProcess ();
        obj.getINTF_ParseProcess(SourceToTargetAll.id,Quote.id,allobjmap);
        
        PNObject2.SVMXC__Node_Source_Object_API__c = 'SVMXC__Quote__c';
        update PNObject2;
        obj.getINTF_ParseProcess(SourceToTargetAll.id,Quote.id,allobjmap);
      }
      catch(Exception ex)
      {
        system.debug('Exception: '+ex.getMessage());
      }
      Test.stopTest();
    }
    static testMethod void ForStandAloneEdit()
    {
      String targetManager;
      String processNodeObjects;
      String objectMapping; 
      String fieldMapping;
      String expression;
      String SVMXRule;
      List<RecordType> RTypeList = [SELECT Id, Name,SobjectType,IsActive,DeveloperName from RecordType  where SobjectType = 'SVMXC__ServiceMax_Processes__c' OR  SobjectType = 'SVMXC__ServiceMax_Config_Data__c'];
        system.debug('RTypeList'+RTypeList);
        if(RTypeList.size() > 0)
        {
          for(RecordType r : RTypeList)
          {
            if(r.Name == 'Target Manager')
              targetManager = r.id;
            else if(r.Name ==  'Process Node Objects')
              processNodeObjects = r.id;
            else if(r.Name == 'Object Mapping')
              objectMapping = r.id;
            else if(r.Name == 'Field Mapping')
              fieldMapping = r.id;
            else if(r.Name == 'Expressions')
              expression = r.id;  
            else if(r.Name == 'SVMX Rule')
              SVMXRule = r.id;    
          }
        }
      //Create PageHeader
      SVMXC__Page_Layout__c PageHeader = new SVMXC__Page_Layout__c();
      PageHeader.SVMXC__Name__c = 'PAGE00001';
      PageHeader.SVMXC__Object_Name__c = 'SVMXC__Quote__c';
      PageHeader.SVMXC__Type__c = 'Header';
      insert PageHeader;
      //Create PageDetail
      SVMXC__Page_Layout__c PageDetail = new SVMXC__Page_Layout__c();
      PageDetail.SVMXC__Header_Page_Layout__c = PageHeader.id;
      PageDetail.SVMXC__Object_Name__c = 'SVMXC__Quote_Line__c';
      PageHeader.SVMXC__Type__c = 'Detail';
      insert PageDetail;
      
      //Create SFM Process Defination
      SVMXC__ServiceMax_Processes__c StandAloneEdit = new SVMXC__ServiceMax_Processes__c();
      StandAloneEdit.SVMXC__Name__c = 'CUSTOMPRO0001';
      StandAloneEdit.RecordTypeId = targetManager;
      StandAloneEdit.SVMXC__Purpose__c = 'STANDALONE EDIT';
      StandAloneEdit.SVMXC__ProcessID__c = 'CUSTOMPRO0001';
      StandAloneEdit.SVMXC__Page_Layout__c = PageHeader.id;
      insert StandAloneEdit;
       system.assert(StandAloneEdit.SVMXC__ProcessID__c != null);
      system.assert(StandAloneEdit.SVMXC__Purpose__c != null);
      
      //Create Mapping For Header Record
      SVMXC__ServiceMax_Processes__c valMapHdr = new SVMXC__ServiceMax_Processes__c();
      valMapHdr.SVMXC__MapID__c = 'VMAP000001';
      valMapHdr.SVMXC__Target_Object_Name__c = 'SVMXC__Quote__c';
      valMapHdr.RecordTypeId = objectMapping;
      insert valMapHdr;
      //Create Mapping For Detail Record
      SVMXC__ServiceMax_Processes__c valMapDetail = new SVMXC__ServiceMax_Processes__c();
      valMapDetail.SVMXC__MapID__c = 'VMAP000002';
      valMapDetail.SVMXC__Target_Object_Name__c = 'SVMXC__Quote_Line__c';
      valMapDetail.RecordTypeId = objectMapping;
      insert valMapDetail;
      
      //Create Expression Record
      SVMXC__ServiceMax_Processes__c ExpressionRec = new SVMXC__ServiceMax_Processes__c();
      ExpressionRec.RecordTypeId = SVMXRule;
      ExpressionRec.SVMXC__Rule_Type__c = 'Named Expression'; 
      ExpressionRec.SVMXC__Name__c = 'EXpression111';
      ExpressionRec.SVMXC__SettingID__c = 'EXpression111';
      insert ExpressionRec;
      system.assert(ExpressionRec.SVMXC__SettingID__c != null);
      system.assert(ExpressionRec.SVMXC__Name__c != null);
      
      //Create Process Node object Records.
      list<SVMXC__ServiceMax_Processes__c> listProcessNodeObjects = new list<SVMXC__ServiceMax_Processes__c>();
      SVMXC__ServiceMax_Processes__c PNObject1 = new SVMXC__ServiceMax_Processes__c();
      PNObject1.RecordTypeId = processNodeObjects;
      PNObject1.SVMXC__Type__c = 'TARGET';
      PNObject1.SVMXC__Source_Object_Name__c = 'SVMXC__Quote__c';
      PNObject1.SVMXC__Process__c = StandAloneEdit.id;
      PNObject1.SVMXC__Submodule__c = ExpressionRec.id;
      PNObject1.SVMXC__Final_Exception_Process__c = valMapHdr.id;
      PNObject1.SVMXC__Module__c = valMapHdr.id;
      listProcessNodeObjects.add(PNObject1);
      system.assert(PNObject1.SVMXC__Source_Object_Name__c != null);
      system.assert(PNObject1.SVMXC__Type__c != null);
      
      SVMXC__ServiceMax_Processes__c PNObject2 = new SVMXC__ServiceMax_Processes__c();
      PNObject2.RecordTypeId = processNodeObjects;
      PNObject2.SVMXC__Type__c = 'TARGETCHILD';
      PNObject2.SVMXC__Page_Layout__c = PageDetail.id;
      PNObject2.SVMXC__Source_Object_Name__c = 'SVMXC__Quote_Line__c';
      PNObject2.SVMXC__Parent_Column_Name__c = 'SVMXC__Quote__c';
      PNObject2.SVMXC__Process__c = StandAloneEdit.id;
      PNObject2.SVMXC__Submodule__c = ExpressionRec.id;
      PNObject2.SVMXC__Module__c = valMapDetail.id;
      PNObject2.SVMXC__Final_Exception_Process__c = valMapDetail.id;
      listProcessNodeObjects.add(PNObject2);
      insert listProcessNodeObjects;
      
      SVMXC__Quote__c Quote = new SVMXC__Quote__c();
      Quote.SVMXC__Discount__c  = 10;
      Quote.SVMXC__Discount_Type__c = 'amount';
      Quote.SVMXC__Valid_Until__c = system.today() + 15;
      insert Quote;
      SVMXC__Quote_Line__c QLine = new SVMXC__Quote_Line__c();
      QLine.SVMXC__Quote__c = Quote.id;
      QLine.SVMXC__Discount__c  = 10;
      QLine.SVMXC__Discount_Type__c = 'amount';
      insert QLine;
      Test.startTest();
      try
      {
        SVMXC.INTF_ParseProcess obj = new SVMXC.INTF_ParseProcess ();
        obj.getINTF_ParseProcess(StandAloneEdit.id,Quote.id,allobjmap);
      }
      catch(Exception ex)
      {
        system.debug('Exception: '+ex.getMessage());
      }
      Test.stopTest();  
    }
    static testMethod void ForStandAloneView()
    {
      String targetManager;
      String processNodeObjects;
      String objectMapping; 
      String fieldMapping;
      String expression;
      String SVMXRule;
      List<RecordType> RTypeList = [SELECT Id, Name,SobjectType,IsActive,DeveloperName from RecordType  where SobjectType = 'SVMXC__ServiceMax_Processes__c' OR  SobjectType = 'SVMXC__ServiceMax_Config_Data__c'];
        system.debug('RTypeList'+RTypeList);
        if(RTypeList.size() > 0)
        {
          for(RecordType r : RTypeList)
          {
            if(r.Name == 'Target Manager')
              targetManager = r.id;
            else if(r.Name ==  'Process Node Objects')
              processNodeObjects = r.id;
            else if(r.Name == 'Object Mapping')
              objectMapping = r.id;
            else if(r.Name == 'Field Mapping')
              fieldMapping = r.id;
            else if(r.Name == 'Expressions')
              expression = r.id;  
            else if(r.Name == 'SVMX Rule')
              SVMXRule = r.id;    
          }
        }
      //Create PageHeader
      SVMXC__Page_Layout__c PageHeader = new SVMXC__Page_Layout__c();
      PageHeader.SVMXC__Name__c = 'PAGE00001';
      PageHeader.SVMXC__Object_Name__c = 'SVMXC__Quote__c';
      PageHeader.SVMXC__Type__c = 'Header';
      insert PageHeader;
      //Create PageDetail
      SVMXC__Page_Layout__c PageDetail = new SVMXC__Page_Layout__c();
      PageDetail.SVMXC__Header_Page_Layout__c = PageHeader.id;
      PageDetail.SVMXC__Object_Name__c = 'SVMXC__Quote_Line__c';
      PageHeader.SVMXC__Type__c = 'Detail';
      insert PageDetail;
      
      //Create SFM Process Defination
      SVMXC__ServiceMax_Processes__c StandAloneView = new SVMXC__ServiceMax_Processes__c();
      StandAloneView.SVMXC__Name__c = 'CUSTOMPRO0001';
      StandAloneView.RecordTypeId = targetManager;
      StandAloneView.SVMXC__Purpose__c = 'VIEW RECORD';
      StandAloneView.SVMXC__ProcessID__c = 'CUSTOMPRO0001';
      StandAloneView.SVMXC__Page_Layout__c = PageHeader.id;
      insert StandAloneView;
      
      //Create Expression Record
      SVMXC__ServiceMax_Processes__c ExpressionRec = new SVMXC__ServiceMax_Processes__c();
      ExpressionRec.RecordTypeId = SVMXRule;
      ExpressionRec.SVMXC__Rule_Type__c = 'Named Expression'; 
      ExpressionRec.SVMXC__Name__c = 'EXpression111';
      ExpressionRec.SVMXC__SettingID__c = 'EXpression111';
      insert ExpressionRec;
      
      //Create Process Node object Records.
      list<SVMXC__ServiceMax_Processes__c> listProcessNodeObjects = new list<SVMXC__ServiceMax_Processes__c>();
      SVMXC__ServiceMax_Processes__c PNObject1 = new SVMXC__ServiceMax_Processes__c();
      PNObject1.RecordTypeId = processNodeObjects;
      PNObject1.SVMXC__Type__c = 'TARGET';
      PNObject1.SVMXC__Source_Object_Name__c = 'SVMXC__Quote__c';
      PNObject1.SVMXC__Process__c = StandAloneView.id;
      PNObject1.SVMXC__Submodule__c = ExpressionRec.id;
      listProcessNodeObjects.add(PNObject1);
      system.assert(PNObject1.SVMXC__Source_Object_Name__c != null);
      system.assert(PNObject1.SVMXC__Type__c != null);
      
      SVMXC__ServiceMax_Processes__c PNObject2 = new SVMXC__ServiceMax_Processes__c();
      PNObject2.RecordTypeId = processNodeObjects;
      PNObject2.SVMXC__Type__c = 'TARGETCHILD';
      PNObject2.SVMXC__Page_Layout__c = PageDetail.id;
      PNObject2.SVMXC__Source_Object_Name__c = 'SVMXC__Quote_Line__c';
      PNObject2.SVMXC__Parent_Column_Name__c = 'SVMXC__Quote__c';
      PNObject2.SVMXC__Process__c = StandAloneView.id;
      PNObject2.SVMXC__Submodule__c = ExpressionRec.id;
      listProcessNodeObjects.add(PNObject2);
      insert listProcessNodeObjects;
      system.assert(PNObject2.SVMXC__Source_Object_Name__c != null);
      system.assert(PNObject2.SVMXC__Type__c != null);
      system.assert(listProcessNodeObjects.size() > 0);
      
      SVMXC__Quote__c Quote = new SVMXC__Quote__c();
      Quote.SVMXC__Discount__c  = 10;
      Quote.SVMXC__Discount_Type__c = 'amount';
      Quote.SVMXC__Valid_Until__c = system.today() + 15;
      insert Quote;
      SVMXC__Quote_Line__c QLine = new SVMXC__Quote_Line__c();
      QLine.SVMXC__Quote__c = Quote.id;
      QLine.SVMXC__Discount__c  = 10;
      QLine.SVMXC__Discount_Type__c = 'amount';
      insert QLine;
      Test.startTest();
      try
      {
        SVMXC.INTF_ParseProcess obj = new SVMXC.INTF_ParseProcess ();
        obj.getINTF_ParseProcess(StandAloneView.id,Quote.id,allobjmap);
      }
      catch(Exception ex)
      {
        system.debug('Exception: '+ex.getMessage());
      }
      Test.stopTest();  
    }
    static testMethod void ForSourceToTargetChild()
    {
      String targetManager;
      String processNodeObjects;
      String objectMapping; 
      String fieldMapping;
      String expression;
      String SVMXRule;
      List<RecordType> RTypeList = [SELECT Id, Name,SobjectType,IsActive,DeveloperName from RecordType  where SobjectType = 'SVMXC__ServiceMax_Processes__c' OR  SobjectType = 'SVMXC__ServiceMax_Config_Data__c'];
        system.debug('RTypeList'+RTypeList);
        if(RTypeList.size() > 0)
        {
          for(RecordType r : RTypeList)
          {
            if(r.Name == 'Target Manager')
              targetManager = r.id;
            else if(r.Name ==  'Process Node Objects')
              processNodeObjects = r.id;
            else if(r.Name == 'Object Mapping')
              objectMapping = r.id;
            else if(r.Name == 'Field Mapping')
              fieldMapping = r.id;
            else if(r.Name == 'Expressions')
              expression = r.id;  
            else if(r.Name == 'SVMX Rule')
              SVMXRule = r.id;    
          }
        }
      //Create PageHeader
      SVMXC__Page_Layout__c PageHeader = new SVMXC__Page_Layout__c();
      PageHeader.SVMXC__Name__c = 'PAGE00001';
      PageHeader.SVMXC__Object_Name__c = 'SVMXC__Quote__c';
      PageHeader.SVMXC__Type__c = 'Header';
      insert PageHeader;
      //Create PageDetail
      SVMXC__Page_Layout__c PageDetail = new SVMXC__Page_Layout__c();
      PageDetail.SVMXC__Header_Page_Layout__c = PageHeader.id;
      PageDetail.SVMXC__Object_Name__c = 'SVMXC__Quote_Line__c';
      PageHeader.SVMXC__Type__c = 'Detail';
      insert PageDetail;
      
      //Create SFM Process Defination
      SVMXC__ServiceMax_Processes__c SourceToTargetChild = new SVMXC__ServiceMax_Processes__c();
      SourceToTargetChild.SVMXC__Name__c = 'CUSTOMPRO0001';
      SourceToTargetChild.RecordTypeId = targetManager;
      SourceToTargetChild.SVMXC__Purpose__c = 'SOURCE TO TARGET CHILD';
      SourceToTargetChild.SVMXC__ProcessID__c = 'CUSTOMPRO0001';
      SourceToTargetChild.SVMXC__Page_Layout__c = PageHeader.id;
      insert SourceToTargetChild;
      
      //Create Mapping For Header Record
      SVMXC__ServiceMax_Processes__c valMapHdr = new SVMXC__ServiceMax_Processes__c();
      valMapHdr.SVMXC__MapID__c = 'VMAP000001';
      valMapHdr.SVMXC__Target_Object_Name__c = 'SVMXC__Quote__c';
      valMapHdr.RecordTypeId = objectMapping;
      insert valMapHdr;
      //Create Mapping For Detail Record
      SVMXC__ServiceMax_Processes__c valMapDetail = new SVMXC__ServiceMax_Processes__c();
      valMapDetail.SVMXC__MapID__c = 'VMAP000002';
      valMapDetail.SVMXC__Target_Object_Name__c = 'SVMXC__Quote_Line__c';
      valMapDetail.RecordTypeId = objectMapping;
      insert valMapDetail;
      
      //Create Expression Record
      SVMXC__ServiceMax_Processes__c ExpressionRec = new SVMXC__ServiceMax_Processes__c();
      ExpressionRec.RecordTypeId = SVMXRule;
      ExpressionRec.SVMXC__Rule_Type__c = 'Named Expression'; 
      ExpressionRec.SVMXC__Name__c = 'EXpression111';
      ExpressionRec.SVMXC__SettingID__c = 'EXpression111';
      insert ExpressionRec;
      
      //Create Process Node object Records.
      list<SVMXC__ServiceMax_Processes__c> listProcessNodeObjects = new list<SVMXC__ServiceMax_Processes__c>();
      SVMXC__ServiceMax_Processes__c PNObject1 = new SVMXC__ServiceMax_Processes__c();
      PNObject1.RecordTypeId = processNodeObjects;
      PNObject1.SVMXC__Type__c = 'TARGET';
      PNObject1.SVMXC__Source_Object_Name__c = 'SVMXC__Quote__c';
      PNObject1.SVMXC__Process__c = SourceToTargetChild.id;
      PNObject1.SVMXC__Submodule__c = ExpressionRec.id;
      PNObject1.SVMXC__Final_Exception_Process__c = valMapHdr.id;
      PNObject1.SVMXC__Module__c = valMapHdr.id;
      PNObject1.SVMXC__Node_Source_Object_API__c = 'SVMXC__Quote__c';
      listProcessNodeObjects.add(PNObject1);
      system.assert(PNObject1.SVMXC__Source_Object_Name__c != null);
      system.assert(PNObject1.SVMXC__Type__c != null);
      
      SVMXC__ServiceMax_Processes__c PNObject2 = new SVMXC__ServiceMax_Processes__c();
      PNObject2.RecordTypeId = processNodeObjects;
      PNObject2.SVMXC__Type__c = 'TARGETCHILD';
      PNObject2.SVMXC__Page_Layout__c = PageDetail.id;
      PNObject2.SVMXC__Source_Object_Name__c = 'SVMXC__Quote_Line__c';
      PNObject2.SVMXC__Parent_Column_Name__c = 'SVMXC__Quote__c';
      PNObject2.SVMXC__Process__c = SourceToTargetChild.id;
      PNObject2.SVMXC__Submodule__c = ExpressionRec.id;
      PNObject2.SVMXC__Module__c = valMapDetail.id;
      PNObject2.SVMXC__Final_Exception_Process__c = valMapDetail.id;
      PNObject2.SVMXC__Node_Source_Object_API__c = 'SVMXC__Quote_Line__c';
      listProcessNodeObjects.add(PNObject2);
       system.assert(PNObject2.SVMXC__Source_Object_Name__c != null);
      system.assert(PNObject2.SVMXC__Type__c != null);
      system.assert(listProcessNodeObjects.size() > 0);
      
      SVMXC__ServiceMax_Processes__c PNObject3 = new SVMXC__ServiceMax_Processes__c();
      PNObject3.RecordTypeId = processNodeObjects;
      PNObject3.SVMXC__Type__c = 'SOURCE';
      PNObject3.SVMXC__Source_Object_Name__c = 'SVMXC__Quote__c';
      PNObject3.SVMXC__Process__c = SourceToTargetChild.id;
      PNObject3.SVMXC__Final_Exception_Process__c = valMapHdr.id;
      listProcessNodeObjects.add(PNObject3);
      
      SVMXC__ServiceMax_Processes__c PNObject4 = new SVMXC__ServiceMax_Processes__c();
      PNObject4.RecordTypeId = processNodeObjects;
      PNObject4.SVMXC__Type__c = 'SOURCECHILD';
      PNObject4.SVMXC__Page_Layout__c = PageDetail.id;
      PNObject4.SVMXC__Source_Object_Name__c = 'SVMXC__Quote_Line__c';
      PNObject4.SVMXC__Parent_Column_Name__c = 'SVMXC__Quote__c';
      PNObject4.SVMXC__Process__c = SourceToTargetChild.id;
      PNObject4.SVMXC__Final_Exception_Process__c = valMapDetail.id;
      listProcessNodeObjects.add(PNObject4);
      insert listProcessNodeObjects;
      
      SVMXC__Quote__c Quote = new SVMXC__Quote__c();
      Quote.SVMXC__Discount__c  = 10;
      Quote.SVMXC__Discount_Type__c = 'amount';
      Quote.SVMXC__Valid_Until__c = system.today() + 15;
      insert Quote;
      SVMXC__Quote_Line__c QLine = new SVMXC__Quote_Line__c();
      QLine.SVMXC__Quote__c = Quote.id;
      QLine.SVMXC__Discount__c  = 10;
      QLine.SVMXC__Discount_Type__c = 'amount';
      insert QLine;
      Test.startTest();
      try
      {
        SVMXC.INTF_ParseProcess obj = new SVMXC.INTF_ParseProcess ();
        obj.getINTF_ParseProcess(SourceToTargetChild.id,Quote.id,allobjmap);
      }
      catch(Exception ex)
      {
        system.debug('Exception: '+ex.getMessage());
      }
      Test.stopTest();
      
    }   
}