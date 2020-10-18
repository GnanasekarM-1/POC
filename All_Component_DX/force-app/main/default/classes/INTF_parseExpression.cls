public with sharing class INTF_parseExpression
{
    
    public map<String, Schema.SObjectType> gd = new map<String, Schema.SObjectType>();
    public map<String, Schema.SObjectType> allobjmap  = new map<String, Schema.SObjectType>();
    SVMXC.COMM_Utils commutils = new SVMXC.COMM_Utils(); 
    public INTF_parseExpression()
    {
        gd = Schema.getGlobalDescribe();
        for(Schema.SObjectType s : gd.values())
        {
            allobjmap.put(s.getDescribe().getName(),s);
        } 
    }
    
    public list<SObject> INTF_parseExpression (List<SObject> lstRecs,INTF_WebServicesDef.INTF_Expression expInfo)
    {
        try
        {
            map<String, Schema.SObjectField> Fieldmap = new map<String, Schema.SObjectField>();
            list<String> FieldLst = new list<String>(); 
            String FieldName = '';
            system.debug('Called INTF_ExpressionParsing'+lstRecs);
            SVMXC__ServiceMax_Processes__c expressionHeader = expinfo.namedExpression; 
            String strWhereClause = expressionHeader.SVMXC__Parent_Object_Criteria__c;
            system.debug('strWhereClause'+strWhereClause);
            String strIDs = '';
            String strQuery = '';
            if( strWhereClause != null)
            {
                system.debug('Entered in strWhereClause');
                system.debug('lstRecs'+lstRecs);
                List<SObject> lstValidRecs = new List<SObject>();
                if(lstRecs.size() > 0)
                {
                    for(SObject obj : lstRecs)
                    {
                        strIDs += '\'' + obj.Id + '\',';
                    }
                }
                system.debug('strIDs'+strIDs);  
                if(expressionHeader.SVMXC__Source_Object_Name__c != null && allobjmap.containskey(expressionHeader.SVMXC__Source_Object_Name__c))
                {
                    Fieldmap = allobjmap.get(expressionHeader.SVMXC__Source_Object_Name__c).getDescribe().fields.getMap();
                    if(Fieldmap.size() > 0)
                        FieldLst = commutils.SVMX_getFieldList(Fieldmap,true);
                    system.debug('FieldLst'+FieldLst);
                    if(FieldLst.size() > 0)
                        FieldName = commutils.SVMX_getFieldNamesFromList(FieldLst);
                    system.debug('FieldName'+FieldName);
                }   
                if(FieldName != null && FieldName.length() > 0 && strIDs != null && strIDs.length() > 0)
                {
                    strQuery = 'Select '+ FieldName +' from '+ expressionHeader.SVMXC__Source_Object_Name__c +' where ID in (' + strIDs.substring(0, strIDs.length()-1)+') And ( ' + strWhereClause +' )';
                }
                system.debug('strQuery product: '+strQuery);
                if(strQuery != null && strQuery.length() > 0)
                    lstValidRecs = database.query(strQuery);
                return lstValidRecs;                
            }else
            {
                system.debug('lstRecs'+lstRecs);
                return lstRecs;
            }
        }
        catch(Exception ex)
        {
            throw ex;
        }
        
    }
    public list<SObject> INTF_parseExpression1 (List<SObject> lstRecs,INTF_WebServicesDef.INTF_Expression expInfo)
    {
        try
        {
            map<String, Schema.SObjectField> Fieldmap = new map<String, Schema.SObjectField>();
            list<String> FieldLst = new list<String>(); 
            String FieldName = '';
            system.debug('Called INTF_ExpressionParsing'+lstRecs);
            SVMXC__ServiceMax_Processes__c expressionHeader = expinfo.namedExpression; 
            String strWhereClause = expressionHeader.SVMXC__Parent_Object_Criteria__c;
            system.debug('strWhereClause'+strWhereClause);
            String strIDs = '';
            String strQuery = '';
            if( strWhereClause != null)
            {
                system.debug('Entered in strWhereClause');
                system.debug('lstRecs'+lstRecs);
                List<SObject> lstValidRecs = new List<SObject>();
                if(lstRecs.size() > 0)
                {
                    for(SObject obj : lstRecs)
                    {
                        strIDs += '\'' + obj.Id + '\',';
                    }
                }
                system.debug('strIDs'+strIDs);  
                if(expressionHeader.SVMXC__Source_Object_Name__c != null && allobjmap.containskey(expressionHeader.SVMXC__Source_Object_Name__c))
                	strQuery = 'Select id from '+ expressionHeader.SVMXC__Source_Object_Name__c +' where ID in (' + strIDs.substring(0, strIDs.length()-1)+') And ( ' + strWhereClause +' )';
                system.debug('strQuery: '+strQuery);
                if(strQuery != null && strQuery.length() > 0)
                    lstValidRecs = database.query(strQuery);
                return lstValidRecs;                
            }
            else
            {
                system.debug('lstRecs'+lstRecs);
                return lstRecs;
            }
        }
        catch(Exception ex)
        {
            throw ex;
        }
        
    }

}