@isTest
private class SFM_DeployServiceFlow_UT
{
    static testMethod void SFM_DeployServiceFlow_UT_Test()       
    {
        /*********************** Data Creation ***************************/
        List<RecordType> RtypeLst = [SELECT Id, Name FROM RecordType WHERE SobjectType = 'SVMXC__ServiceMax_Processes__c' AND Name='Target Manager'];
        SVMXC__ServiceMax_Processes__c processNodes = new SVMXC__ServiceMax_Processes__c();
        processNodes.RecordTypeId=RtypeLst[0].Id;
        processNodes.SVMXC__Purpose__c = 'GENERATE REPORT';
        processNodes.SVMXC__IsDefault__C=true;
        processNodes.SVMXC__ProcessID__c='servicemax001';
        insert processNodes;
        System.assertEquals(true, processNodes != null);
        
        List<RecordType> RtypeLst1 = [SELECT Id, Name FROM RecordType WHERE SobjectType = 'SVMXC__ServiceMax_Processes__c'];
        SVMXC__ServiceMax_Processes__c processNodes1 = new SVMXC__ServiceMax_Processes__c();
        processNodes1.RecordTypeId=RtypeLst1[0].Id;
        processNodes1.SVMXC__Purpose__c = 'SOURCE TO TARGET CHILD';
        processNodes1.SVMXC__ProcessID__c='servicemax001';
        insert processNodes1;
        System.assertEquals(true, processNodes1 != null);
        
        /************************** Data creation for SOURCE OBJECT ***********************/
        SVMXC__ServiceMax_Processes__c sourceProcessNodeObject = new SVMXC__ServiceMax_Processes__c();
        sourceProcessNodeObject.RecordTypeId = RtypeLst[0].Id; 
        sourceProcessNodeObject.SVMXC__ProcessID__c='PROCESS12';
        sourceProcessNodeObject.SVMXC__Purpose__c = 'SOURCE TO TARGET CHILD';
        sourceProcessNodeObject.SVMXC__Source_Object_Name__c = 'Case';
        sourceProcessNodeObject.SVMXC__Type__c = 'SOURCE';
        sourceProcessNodeObject.SVMXC__Process__c = processNodes.Id;
        upsert sourceProcessNodeObject;
        System.assertEquals(true, sourceProcessNodeObject != null);
            
            
        /************************** Data creation for TARGET OBJECT ***********************/// 
        SVMXC__ServiceMax_Processes__c targetProcessNodeObject = new SVMXC__ServiceMax_Processes__c();
        targetProcessNodeObject.RecordTypeId = RtypeLst[0].Id;
        targetProcessNodeObject.SVMXC__ProcessID__c='PROCESS14';
        targetProcessNodeObject.SVMXC__Purpose__c = 'STANDALONE EDIT';
        targetProcessNodeObject.SVMXC__Source_Object_Name__c = 'SVMXC__Service_Order__c';
        targetProcessNodeObject.SVMXC__Type__c = 'TARGET';
        targetProcessNodeObject.SVMXC__Process__c = processNodes.Id;
        upsert targetProcessNodeObject;
        System.assertEquals(true, targetProcessNodeObject != null);
        
        /************************ Config Data ***********************************/
        SVMXC__ServiceMax_Config_Data__c ConfigData=new SVMXC__ServiceMax_Config_Data__c();
        List<SVMXC__ServiceMax_Config_Data__c> processSourceUpdates = new List<SVMXC__ServiceMax_Config_Data__c>();
        processSourceUpdates.add(ConfigData);
        
        /*********************** Create SFM_ProcessNodeDetail objects and add it into the list ************************/
        SFM_WrapperDef.SFM_ProcessNodeDetail processNodeSourceObject = new SFM_WrapperDef.SFM_ProcessNodeDetail(sourceProcessNodeObject, processSourceUpdates);
        SFM_WrapperDef.SFM_ProcessNodeDetail processNodeTargetObject = new SFM_WrapperDef.SFM_ProcessNodeDetail(targetProcessNodeObject, processSourceUpdates);  
        List<SFM_WrapperDef.SFM_ProcessNodeDetail> processNodeSourceObjectLst = new List<SFM_WrapperDef.SFM_ProcessNodeDetail>();
        processNodeSourceObjectLst.add(processNodeSourceObject);
        List<SFM_WrapperDef.SFM_ProcessNodeDetail> processNodeTargetObjectLst = new List<SFM_WrapperDef.SFM_ProcessNodeDetail>(); 
        processNodeTargetObjectLst.add(processNodeTargetObject); 
        System.assertEquals(true, processNodeTargetObjectLst.size()>0);
        System.assertEquals(true, processNodeSourceObjectLst.size()>0);
        
        /********************** Create instance of class and  Method calling ****************************/
        SFM_DeployServiceFlow DeployProcessObj= new SFM_DeployServiceFlow();
        SFM_WrapperDef.SFM_Request_ProcessNodeInfo request = new SFM_WrapperDef.SFM_Request_ProcessNodeInfo(processNodes, processNodeSourceObjectLst, processNodeTargetObjectLst);
        SFM_WrapperDef.SFM_Request_ProcessNodeInfo request1 = new SFM_WrapperDef.SFM_Request_ProcessNodeInfo(processNodes1, processNodeSourceObjectLst, processNodeTargetObjectLst);
        DeployProcessObj.SFM_DeployProcess(request);
        DeployProcessObj.SFM_DeployProcess(request1);
        
        
    }
    static testMethod void SFM_DeployProcess_UT_Test1() 
    {
        /*********************** Data Creation ***************************/
        List<RecordType> RtypeLst = [SELECT Id, Name FROM RecordType WHERE SobjectType = 'SVMXC__ServiceMax_Processes__c'];
        SVMXC__ServiceMax_Processes__c processNodes = new SVMXC__ServiceMax_Processes__c();
        processNodes.RecordTypeId=RtypeLst[0].Id;
        processNodes.SVMXC__Purpose__c = 'GENERATE REPORT';
        processNodes.SVMXC__ProcessID__c='servicemax001';
        insert processNodes;
        System.assertEquals(true, processNodes != null);
        
        /************************** Data creation for SOURCE OBJECT ***********************/
        SVMXC__ServiceMax_Processes__c sourceProcessNodeObject = new SVMXC__ServiceMax_Processes__c();
        sourceProcessNodeObject.RecordTypeId = RtypeLst[0].Id; 
        sourceProcessNodeObject.SVMXC__ProcessID__c='PROCESS12';
        sourceProcessNodeObject.SVMXC__Purpose__c = 'SOURCE TO TARGET CHILD';
        upsert sourceProcessNodeObject;
        System.assertEquals(true, sourceProcessNodeObject != null);
            
        /************************** Data creation for TARGET OBJECT ***********************/// 
        SVMXC__ServiceMax_Processes__c targetProcessNodeObject = new SVMXC__ServiceMax_Processes__c();
        targetProcessNodeObject.RecordTypeId = RtypeLst[0].Id;
        targetProcessNodeObject.SVMXC__ProcessID__c='PROCESS14';
        targetProcessNodeObject.SVMXC__Purpose__c = 'STANDALONE EDIT';
        upsert targetProcessNodeObject;
        System.assertEquals(true, targetProcessNodeObject != null);
        
        /************************ Config Data ***********************************/
        SVMXC__ServiceMax_Config_Data__c ConfigData=new SVMXC__ServiceMax_Config_Data__c();
        List<SVMXC__ServiceMax_Config_Data__c> processSourceUpdates = new List<SVMXC__ServiceMax_Config_Data__c>();
        processSourceUpdates.add(ConfigData);
        
        /*********************** Create SFM_ProcessNodeDetail objects and add it into the list ************************/
        SFM_WrapperDef.SFM_ProcessNodeDetail processNodeSourceObject = new SFM_WrapperDef.SFM_ProcessNodeDetail(sourceProcessNodeObject, processSourceUpdates);
        SFM_WrapperDef.SFM_ProcessNodeDetail processNodeTargetObject = new SFM_WrapperDef.SFM_ProcessNodeDetail(targetProcessNodeObject, processSourceUpdates);  
        List<SFM_WrapperDef.SFM_ProcessNodeDetail> processNodeSourceObjectLst = new List<SFM_WrapperDef.SFM_ProcessNodeDetail>();
        processNodeSourceObjectLst.add(processNodeSourceObject);
        List<SFM_WrapperDef.SFM_ProcessNodeDetail> processNodeTargetObjectLst = new List<SFM_WrapperDef.SFM_ProcessNodeDetail>(); 
        processNodeTargetObjectLst.add(processNodeTargetObject); 
        System.assertEquals(true, processNodeTargetObjectLst.size()>0);
        System.assertEquals(true, processNodeSourceObjectLst.size()>0);
        
        /********************** Create instance of class and  Method calling ****************************/
        SFM_DeployServiceFlow DeployProcessObj= new SFM_DeployServiceFlow();
        SFM_WrapperDef.SFM_Request_ProcessNodeInfo request = new SFM_WrapperDef.SFM_Request_ProcessNodeInfo(processNodes, processNodeSourceObjectLst, processNodeTargetObjectLst);
        DeployProcessObj.SFM_DeployProcess(request);
        SFM_WrapperDef.SFM_Request_ProcessNodeInfo request1 = new SFM_WrapperDef.SFM_Request_ProcessNodeInfo(null, null, null);
        DeployProcessObj.SFM_DeployProcess(request1);
    }
}