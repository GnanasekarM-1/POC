/* Security Scanned */
public with sharing class SFM_DeployExpression {

  Boolean isSucess = TRUE;
  String exprRecId;
  String exprDetailRecId;
  SVMX_Debug log = new SVMX_Debug();
  SFM_Utils utils = new SFM_Utils();
  List<SFM_WrapperDef.SFM_StringMap> sourceTargetExpressionId = new List<SFM_WrapperDef.SFM_StringMap>();

  public SFM_DeployExpression()
  {
    List<String> recTypeNames = new List<String>();
    recTypeNames.add('SVMXC__ServiceMax_Processes__c~SVMX Rule');
        recTypeNames.add('SVMXC__ServiceMax_Config_Data__c~Expressions');
    Map<String, Id> expRecType_Map = new Map<String, Id>();
    expRecType_Map = utils.getRecordTypes(recTypeNames);
    exprRecId = expRecType_Map.get('SVMXC__ServiceMax_Processes__c~SVMX Rule');  
    exprDetailRecId = expRecType_Map.get('SVMXC__ServiceMax_Config_Data__c~Expressions'); 
    }
    
  public SFM_WrapperDef.SFM_Response SFM_DeployExpression(SFM_WrapperDef.SFM_Request_Expression request)
  {
    SFM_WrapperDef.SFM_Response oResponse=new SFM_WrapperDef.SFM_Response();
    Map<String, SVMXC__ServiceMax_Processes__c> mapNamedExpression = new Map<String, SVMXC__ServiceMax_Processes__c>();
    Map<String, list<SVMXC__ServiceMax_Config_Data__c>> mapNamedExpressionDetails = new Map<String, list<SVMXC__ServiceMax_Config_Data__c>>();
    Set<String> requestedExpressionName = new Set<String>();
    Set<String> existingExpressionName = new Set<String>();
    List<String> createdExpressionName = new List<String>();
    Map<String,String> mapRequest = new Map<String,String>();
        mapRequest = utils.getStringMap(request.request.stringMap);
        
        //log.login('SFM_DeployExpression', 'SFM_DeployExpression\n');
    Savepoint sp = Database.setSavepoint();//Setting up save point
    try
        {
      for(SFM_WrapperDef.SFM_Expression expinfo: request.expressions)
      {
        SVMXC__ServiceMax_Processes__c expressionHeader = expinfo.namedExpression;
        expressionHeader.RecordTypeId = exprRecId;
        expressionHeader.SVMXC__Rule_Type__c = 'Named Expression';
        requestedExpressionName.add(expressionHeader.SVMXC__ProcessID__c);
        mapNamedExpression.put(expressionHeader.SVMXC__ProcessID__c, expressionHeader);
        mapNamedExpressionDetails.put(expressionHeader.SVMXC__ProcessID__c, expinfo.expressionDetails);
      }
      
      List<SVMXC__ServiceMax_Processes__c> availableNamedExpressions = new List<SVMXC__ServiceMax_Processes__c>();
      
      availableNamedExpressions = [Select Id, SVMXC__IsStandard__c, SVMXC__Source_Object_Name__c, SVMXC__Name__c, SVMXC__ProcessID__c From SVMXC__ServiceMax_Processes__c where Recordtype.Name='SVMX Rule' AND SVMXC__Rule_Type__c = 'Named Expression' AND SVMXC__ProcessID__c IN :requestedExpressionName]; //SDL-SVMX-FLS-NOT-ENFORCED-META-DATA
      
      // Data already available, check for object definition and push only expression details
      for(SVMXC__ServiceMax_Processes__c namedExpression: availableNamedExpressions)
      {
        String sourceExpressionId = mapNamedExpression.get(namedExpression.SVMXC__ProcessID__c).SVMXC__Node_Parent_API__c;
        sourceTargetExpressionId.add(new SFM_WrapperDef.SFM_StringMap(sourceExpressionId, namedExpression.Id));
        existingExpressionName.add(namedExpression.SVMXC__ProcessID__c);
        
        // If this is standard expression donot insert the records but set up the Id in response
        if(namedExpression.SVMXC__IsStandard__c == true)
        {
          log.setlog('INFO', system.label.CONF019_TAG029 + ' ' + namedExpression.SVMXC__ProcessID__c);
          log.setlog('FINE', system.label.CONF019_TAG057);
          // Skip processing this standard expression
          continue;
        }
        else
          log.setlog('INFO', system.label.CONF019_TAG030 + ' ' + namedExpression.SVMXC__ProcessID__c);
        
        // Check whether both named expressions are associate with same definitions
        if(namedExpression.SVMXC__Source_Object_Name__c == mapNamedExpression.get(namedExpression.SVMXC__ProcessID__c).SVMXC__Source_Object_Name__c)
        {
          if(mapNamedExpression.get(namedExpression.SVMXC__ProcessID__c).SVMXC__Advance_Expression__c != NULL || mapNamedExpression.get(namedExpression.SVMXC__ProcessID__c).SVMXC__Parent_Error_Msg__c != NULL)
          {
            if(mapNamedExpression.get(namedExpression.SVMXC__ProcessID__c).SVMXC__Advance_Expression__c != NULL)
              namedExpression.SVMXC__Advance_Expression__c = mapNamedExpression.get(namedExpression.SVMXC__ProcessID__c).SVMXC__Advance_Expression__c;
            if(mapNamedExpression.get(namedExpression.SVMXC__ProcessID__c).SVMXC__Parent_Error_Msg__c != NULL)
              namedExpression.SVMXC__Parent_Error_Msg__c = mapNamedExpression.get(namedExpression.SVMXC__ProcessID__c).SVMXC__Parent_Error_Msg__c;
          
            update namedExpression; //SDL-SVMX-FLS-NOT-ENFORCED-META-DATA
          }
          
          List<SVMXC__ServiceMax_Config_Data__c> lstExistingExpressionDetails = [Select Id From SVMXC__ServiceMax_Config_Data__c where Recordtype.Name='Expressions' AND SVMXC__Expression_Type__c = 'EXP_Named' And SVMXC__Expression_Rule__c =:namedExpression.Id]; //SDL-SVMX-FLS-NOT-ENFORCED-META-DATA
          if(lstExistingExpressionDetails.size()>0)
              
            delete lstExistingExpressionDetails; //SDL-SVMX-FLS-NOT-ENFORCED-META-DATA
          SFM_DeployExpressionDetails(namedExpression.Id, mapNamedExpressionDetails.get(namedExpression.SVMXC__ProcessID__c));
        }
        else
        {
          isSucess = FALSE;
          log.setlog('ERROR', system.label.CONF019_TAG031 + ' ' + namedExpression.SVMXC__ProcessID__c);
          log.setlog('ERROR', system.label.CONF019_TAG032 + ' ' + mapNamedExpression.get(namedExpression.SVMXC__ProcessID__c).SVMXC__Source_Object_Name__c);
          log.setlog('ERROR', system.label.CONF019_TAG033 + ' ' + namedExpression.SVMXC__Source_Object_Name__c);
        }
      }
      
      // If data not available in org create both header and expression details
      for(String namedExpresionUniqueId: mapNamedExpression.keySet())
      {
        if(!existingExpressionName.contains(namedExpresionUniqueId))
        {
          createdExpressionName.add(namedExpresionUniqueId);
          log.setlog('INFO', system.label.CONF019_TAG034 + namedExpresionUniqueId);
          SFM_DeployExpression(mapNamedExpression.get(namedExpresionUniqueId), mapNamedExpressionDetails.get(namedExpresionUniqueId));
        }
      }
        }
    catch (DmlException ex)
        {
          log.setlog('ERROR', ex.getDmlMessage(0));
            //log.setlog('ROLLBACK', 'When fails rollback data donot commit');
            Database.rollback(sp);
            isSucess = false;
            oResponse.message = ex.getDmlMessage(0);
      }
        catch (Exception ex)
        {
            log.setlog('ERROR', ex.getmessage());
            //log.setlog('ROLLBACK', 'When fails rollback data donot commit');
            Database.rollback(sp);
            isSucess = false;
            oResponse.message = ex.getmessage();
        }
        
        //log.logout();
        // Setup collective data
        List<String> requestedExpressions = new List<String>();
        List<String> existingExpressions = new List<String>();
        requestedExpressions.addAll(requestedExpressionName);
        existingExpressions.addAll(existingExpressionName);
    oResponse.StringLstMap.add(new SFM_WrapperDef.SFM_StringListMap('REQUEST', requestedExpressions));
    oResponse.StringLstMap.add(new SFM_WrapperDef.SFM_StringListMap('DEPLOYED_EXISTING', existingExpressions));
    oResponse.StringLstMap.add(new SFM_WrapperDef.SFM_StringListMap('DEPLOYED', createdExpressionName));
    oResponse.MapStringMap.add(new SFM_WrapperDef.SFM_MapStringMap('SOURCETARGETEXPRESSIONIDS', sourceTargetExpressionId));
    oResponse.resultIds.add(mapRequest.get('PROCESSID'));
    oResponse.logMsg = log.getlog();
    oResponse.success = isSucess;
    return oResponse;   
  }
  
  void SFM_DeployExpression(SVMXC__ServiceMax_Processes__c namedExpression, list<SVMXC__ServiceMax_Config_Data__c> expressionDetails)
  {
    String sourceExpressionId = namedExpression.SVMXC__Node_Parent_API__c;
    namedExpression.SVMXC__Node_Parent_API__c = '';
    namedExpression.RecordTypeId = exprRecId;
    namedExpression.SVMXC__Rule_Type__c = 'Named Expression';
    
    insert namedExpression; //SDL-SVMX-FLS-NOT-ENFORCED-META-DATA
    
    sourceTargetExpressionId.add(new SFM_WrapperDef.SFM_StringMap(sourceExpressionId, namedExpression.Id));
    
    SFM_DeployExpressionDetails(namedExpression.Id, expressionDetails);
  }
  
  void SFM_DeployExpressionDetails(Id expressionId, list<SVMXC__ServiceMax_Config_Data__c> expressionDetails)
  {
    system.debug('TEST LOG: ' + expressionDetails);
    for(SVMXC__ServiceMax_Config_Data__c expressDetail : expressionDetails)
    {
      expressDetail.RecordTypeId = exprDetailRecId;
      expressDetail.SVMXC__Expression_Type__c = 'EXP_Named';
      expressDetail.SVMXC__Expression_Rule__c = expressionId;
    }
    
    insert expressionDetails; //SDL-SVMX-FLS-NOT-ENFORCED-META-DATA
  }
  
}